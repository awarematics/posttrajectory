



#include "postgres.h"

#include "access/gist.h"
#include "access/skey.h"
#include "utils/builtins.h"
//#include "gserialized_gist.h"  
#include "WTBtree_gist.h"
#include "./geohash/geohash.h"

#define WTBtree_LessStrategyNumber		1
#define WTBtree_LessEqualStrategyNumber		2
#define WTBtree_EqualStrategyNumber		3
#define WTBtree_GreaterEqualStrategyNumber	4
#define WTBtree_GreaterStrategyNumber		5
#define WTBtree_NotEqualStrategyNumber		6

#define KEY_SIZE 13


#define FLAGS_GET_BBOX(flags) (((flags) & 0x04)>>2)


/**********************************************************************
**  BOX2DF structure. 
**
**  This is a 2-dimensional key for simple cartesian indexes, 
**  with backwards compatible behavior to previous indexes in
**  PostGIS
*/

typedef struct
{
	float xmin, xmax, ymin, ymax;
} BOX2DF;


/******************************************************************
* GBOX structure. 
* We include the flags (information about dimensinality), 
* so we don't have to constantly pass them
* into functions that use the GBOX.
*/
typedef struct
{
	uint8_t flags;
	double xmin;
	double xmax;
	double ymin;
	double ymax;
	double zmin;
	double zmax;
	double mmin;
	double mmax;
} GBOX;


/******************************************************************
* GSERIALIZED
*/
typedef struct
{
	uint32_t size; /* For PgSQL use only, use VAR* macros to manipulate. */
	uint8_t srid[3]; /* 24 bits of SRID */
	uint8_t flags; /* HasZ, HasM, HasBBox, IsGeodetic, IsReadOnly */
	uint8_t data[1]; /* See gserialized.txt */
} GSERIALIZED;


/* Variable length key */
typedef bytea GBT_VARKEY;

/* Better readable key */
typedef struct
{
	bytea	   *lower,
			   *upper;
} GBT_VARKEY_R;



PG_MODULE_MAGIC;
Datum WTBtree_gist_consistent_2d(PG_FUNCTION_ARGS);
Datum WTBtree_consistent(PG_FUNCTION_ARGS);
Datum WTBtree_union(PG_FUNCTION_ARGS);
Datum WTBtree_compress(PG_FUNCTION_ARGS);
Datum WTBtree_decompress(PG_FUNCTION_ARGS);
Datum WTBtree_penalty(PG_FUNCTION_ARGS);
Datum WTBtree_same(PG_FUNCTION_ARGS);
Datum WTBtree_picksplit(PG_FUNCTION_ARGS);


/*
** GiST support methods
*/
PG_FUNCTION_INFO_V1(WTBtree_gist_consistent_2d);
PG_FUNCTION_INFO_V1(WTBtree_consistent);
PG_FUNCTION_INFO_V1(WTBtree_compress);
PG_FUNCTION_INFO_V1(WTBtree_decompress);
PG_FUNCTION_INFO_V1(WTBtree_penalty);
PG_FUNCTION_INFO_V1(WTBtree_picksplit);
PG_FUNCTION_INFO_V1(WTBtree_union);
PG_FUNCTION_INFO_V1(WTBtree_same);


/* Returns a better readable representaion of variable key ( sets pointer ) */
GBT_VARKEY_R
gbt_var_key_readable(const GBT_VARKEY *k)
{
	GBT_VARKEY_R r;

	r.lower = (bytea *) &(((char *) k)[VARHDRSZ]);
	if (VARSIZE(k) > (VARHDRSZ + (VARSIZE(r.lower))))
		r.upper = (bytea *) &(((char *) k)[VARHDRSZ + INTALIGN(VARSIZE(r.lower))]);
	else
		r.upper = r.lower;
	return r;
}


// wkey를 중간 노드 키(IKEY)로 변환
INTERNAL_KEY* leafKey_to_internaKey(LEAF_KEY w)
{
	INTERNAL_KEY *ikey;

	ikey = palloc(sizeof(INTERNAL_KEY));

	memcpy(ikey->lower, w, KEY_SIZE); 
	memcpy(ikey->upper, w, KEY_SIZE);

	return ikey;
}



static bool box2df_overlaps(const BOX2DF *a, const BOX2DF *b)
{
	if ( ! a || ! b ) return FALSE; /* TODO: might be smarter for EMPTY */

	if ( (a->xmin > b->xmax) || (b->xmin > a->xmax) ||
	     (a->ymin > b->ymax) || (b->ymin > a->ymax) )
	{
		return FALSE;
	}

	return TRUE;
}

static bool box2df_contains(const BOX2DF *a, const BOX2DF *b)
{
	if ( ! a || ! b ) return FALSE; /* TODO: might be smarter for EMPTY */

	if ( (a->xmin > b->xmin) || (a->xmax < b->xmax) ||
	     (a->ymin > b->ymin) || (a->ymax < b->ymax) )
	{
		return FALSE;
	}

	return TRUE;
}

static bool box2df_within(const BOX2DF *a, const BOX2DF *b)
{
	if ( ! a || ! b ) return FALSE; /* TODO: might be smarter for EMPTY */

	//POSTGIS_DEBUG(5, "entered function");
	return box2df_contains(b,a);
}

static bool box2df_equals(const BOX2DF *a, const BOX2DF *b)
{
	if ( a &&  b ) {
		if ( (a->xmin != b->xmin) || (a->xmax != b->xmax) ||
		     (a->ymin != b->ymin) || (a->ymax != b->ymax) )
		{
			return FALSE;
		}
		return TRUE;
	} else if ( a || b ) {
		/* one empty, one not */
		return FALSE;
	} else {
		/* both empty */
		return TRUE;
	}
}

static bool box2df_overleft(const BOX2DF *a, const BOX2DF *b)
{
	if ( ! a || ! b ) return FALSE; /* TODO: might be smarter for EMPTY */

	/* a.xmax <= b.xmax */
	return a->xmax <= b->xmax;
}

static bool box2df_left(const BOX2DF *a, const BOX2DF *b)
{
	if ( ! a || ! b ) return FALSE; /* TODO: might be smarter for EMPTY */

	/* a.xmax < b.xmin */
	return a->xmax < b->xmin;
}

static bool box2df_right(const BOX2DF *a, const BOX2DF *b)
{
	if ( ! a || ! b ) return FALSE; /* TODO: might be smarter for EMPTY */

	/* a.xmin > b.xmax */
	return a->xmin > b->xmax;
}

static bool box2df_overright(const BOX2DF *a, const BOX2DF *b)
{
	if ( ! a || ! b ) return FALSE; /* TODO: might be smarter for EMPTY */

	/* a.xmin >= b.xmin */
	return a->xmin >= b->xmin;
}

static bool box2df_overbelow(const BOX2DF *a, const BOX2DF *b)
{
	if ( ! a || ! b ) return FALSE; /* TODO: might be smarter for EMPTY */

	/* a.ymax <= b.ymax */
	return a->ymax <= b->ymax;
}

static bool box2df_below(const BOX2DF *a, const BOX2DF *b)
{
	if ( ! a || ! b ) return FALSE; /* TODO: might be smarter for EMPTY */

	/* a.ymax < b.ymin */
	return a->ymax < b->ymin;
}

static bool box2df_above(const BOX2DF *a, const BOX2DF *b)
{
	if ( ! a || ! b ) return FALSE; /* TODO: might be smarter for EMPTY */

	/* a.ymin > b.ymax */
	return a->ymin > b->ymax;
}

static bool box2df_overabove(const BOX2DF *a, const BOX2DF *b)
{
	if ( ! a || ! b ) return FALSE; /* TODO: might be smarter for EMPTY */

	/* a.ymin >= b.ymin */
	return a->ymin >= b->ymin;
}


bool char_gt(const void *query, const char *key)
{	
	printf("char_gt");
	bool		result;

	if (memcmp(query, key, KEY_SIZE) > 0) {
		result = true;
	} else {
		result = false;
	}

	return result;
}

bool char_ge(const void *query, const char *key)
{	
	printf("char_ge");
	bool		result;

	if (memcmp(query, key, KEY_SIZE) >= 0) {
		result = true;
	} else {
		result = false;
	}

	return result;
}

bool char_eq(const void *query, const char *key)
{	
	printf("char_eq");
	bool		result;
	
	if (memcmp(query, key, KEY_SIZE) != 0)
	{
		result = false;
	} else
	{		
		result = true;
	}
	
	return result;
}

bool char_lt(const void *query, const char *key)
{	
	printf("char_lt");
	bool		result;

	if (memcmp(query, key, KEY_SIZE) < 0) {
		result = true;
	} else {
		result = false;
	}

	return result;
}

bool char_le(const void *query, const char *key)
{	
	printf("char_le");
	bool		result;

	if (memcmp(query, key, KEY_SIZE) <= 0) {
		result = true;
	} else {
		result = false;
	}

	return result;
}

int char_cmp(const void *query, const char *key)
{	
	printf("char_cmp");
	int		result;

	result = memcmp(query, key, KEY_SIZE);

	return result;
}




/**
* Peak into a #GSERIALIZED datum to find the bounding box. If the
* box is there, copy it out and return it. If not, calculate the box from the
* full object and return the box based on that. If no box is available,
* return #LW_FAILURE, otherwise #LW_SUCCESS.
*/
static int 
gserialized_datum_get_box2df_p(Datum gsdatum, BOX2DF *box2df)
{
	GSERIALIZED *gpart;
	uint8_t flags;
	int result = 0;

	/*
	** The most info we need is the 8 bytes of serialized header plus the 
	** of floats necessary to hold the bounding box.
	*/
	if (VARATT_IS_EXTENDED(gsdatum)) 
	{ 
		gpart = (GSERIALIZED*)PG_DETOAST_DATUM_SLICE(gsdatum, 0, 8 + sizeof(BOX2DF)); 
	} 
	else 
	{ 
		gpart = (GSERIALIZED*)PG_DETOAST_DATUM(gsdatum); 
	} 

	flags = gpart->flags;


	/* Do we even have a serialized bounding box? */
	if ( FLAGS_GET_BBOX(flags) )
	{
		/* Yes! Copy it out into the box! */
		memcpy(box2df, gpart->data, sizeof(BOX2DF));
		result = 1;
	}
	else
	{
		/* No, we need to calculate it from the full object. */
		GBOX gbox;
		GSERIALIZED *g = (GSERIALIZED*)PG_DETOAST_DATUM(gsdatum);

/*
		LWGEOM *lwgeom = lwgeom_from_gserialized(g);
		if ( lwgeom_calculate_gbox(lwgeom, &gbox) == LW_FAILURE )
		{
			POSTGIS_DEBUG(4, "could not calculate bbox, returning failure");
			lwgeom_free(lwgeom);
			return LW_FAILURE;
		}
		lwgeom_free(lwgeom);
*/
//		result = box2df_from_gbox_p(&gbox, box2df);
	}

	printf("BOX2DF(%f %f, %f %f)\n", box2df->xmin, box2df->ymin, box2df->xmax, box2df->ymax);
	return result;
}


char *convert_GeoHash_from_box2d(char *geoH1, char *geoH2, int size_n)
{
	char *result;
	
	result = (char *) palloc(size_n);

	int i, r_cnt;

	r_cnt = size_n;

	for(i=0; i<size_n; i++)
	{
		if(memcmp(geoH1, geoH2, r_cnt) == 0)
		{
			memcpy(result, geoH1, size_n);
			break;
		} else {
			geoH1[r_cnt-1] = '0';
		}
		r_cnt--;
	}	
	
	return result;
}

char *WTBtree_convertGeoHash(GISTENTRY *entry, int size)
{
	char *minPnt, *maxPnt, *cvtGeoHash;

	BOX2DF *box2df;
	box2df = (BOX2DF *) palloc(sizeof(BOX2DF));

	GSERIALIZED *gpart;
	uint8_t flags;

	if (VARATT_IS_EXTENDED(entry->key)) 
	{ 
		printf("true\n");
		gpart = (GSERIALIZED*)PG_DETOAST_DATUM_SLICE(entry->key, 0, 8 + sizeof(BOX2DF)); 

		printf("gpart->size : %d\n", gpart->size);
		printf("gpart->flags : %d\n", gpart->flags);

		flags = gpart->flags;
		
	} 
	else 
	{ 
		printf("false\n");
	//	gpart = (GSERIALIZED*)PG_DETOAST_DATUM(gsdatum); 
	} 

	if ( FLAGS_GET_BBOX(flags) )
	{
	
		printf("IsFlags : %d\n", flags);

		memcpy(box2df, gpart->data, sizeof(BOX2DF));
		//result = LW_SUCCESS;

		printf("----------------: %f\n", box2df->xmin);
		printf("----------------: %f\n", box2df->ymin);
		printf("----------------: %f\n", box2df->xmax);
		printf("----------------: %f\n", box2df->ymax);
	
		minPnt = (char*) palloc(size);
		maxPnt = (char*) palloc(size);
		cvtGeoHash = (char*) palloc(size);

		memcpy(minPnt, geohash_encode((double) box2df->ymin, (double) box2df->xmin, size), size);
		memcpy(maxPnt, geohash_encode((double) box2df->ymax, (double) box2df->xmax, size), size);

		cvtGeoHash = convert_GeoHash_from_box2d(minPnt, maxPnt, size);

		printf("-----------geohash_encode : %s\n", cvtGeoHash);	

	}
	else
	{
		printf("NotFlags : %d\n", flags);

		/*
		GBOX gbox;
		GSERIALIZED *g = (GSERIALIZED*)PG_DETOAST_DATUM(entry->key);

		LWGEOM *lwgeom = lwgeom_from_gserialized(g);
		if ( lwgeom_calculate_gbox(lwgeom, &gbox) == LW_FAILURE )
		{
			POSTGIS_DEBUG(4, "could not calculate bbox, returning failure");
			lwgeom_free(lwgeom);
			return LW_FAILURE;
		}
		lwgeom_free(lwgeom);
		result = box2df_from_gbox_p(&gbox, box2df);
*/

	}

	return cvtGeoHash;
}

static inline bool gserialized_gist_consistent_leaf_2d(BOX2DF *key, BOX2DF *query, StrategyNumber strategy)
{
	bool retval;
	
	switch (strategy)
	{

	/* Basic overlaps */
	case RTOverlapStrategyNumber:
		retval = (bool) box2df_overlaps(key, query);
		break;
	case RTSameStrategyNumber:
		retval = (bool) box2df_equals(key, query);
		break;
	case RTContainsStrategyNumber:
	case RTOldContainsStrategyNumber:
		retval = (bool) box2df_contains(key, query);
		break;
	case RTContainedByStrategyNumber:
	case RTOldContainedByStrategyNumber:
		retval = (bool) box2df_contains(query, key);
		break;
		
	/* To one side */
	case RTAboveStrategyNumber:
		retval = (bool) box2df_above(key, query);
		break;
	case RTBelowStrategyNumber:
		retval = (bool) box2df_below(key, query);
		break;
	case RTRightStrategyNumber:
		retval = (bool) box2df_right(key, query);
		break;
	case RTLeftStrategyNumber:
		retval = (bool) box2df_left(key, query);
		break;

	/* Overlapping to one side */
	case RTOverAboveStrategyNumber:
		retval = (bool) box2df_overabove(key, query);
		break;
	case RTOverBelowStrategyNumber:
		retval = (bool) box2df_overbelow(key, query);
		break;
	case RTOverRightStrategyNumber:
		retval = (bool) box2df_overright(key, query);
		break;
	case RTOverLeftStrategyNumber:
		retval = (bool) box2df_overleft(key, query);
		break;		
		
	default:
		retval = FALSE;
	}

	return (retval);
}

static inline bool gserialized_gist_consistent_internal_2d(BOX2DF *key, BOX2DF *query, StrategyNumber strategy)
{
	bool retval;
	
	switch (strategy)
	{
		
	/* Basic overlaps */
	case RTOverlapStrategyNumber:
		retval = (bool) box2df_overlaps(key, query);
		break;
	case RTSameStrategyNumber:
	case RTContainsStrategyNumber:
	case RTOldContainsStrategyNumber:
		retval = (bool) box2df_contains(key, query);
		break;
	case RTContainedByStrategyNumber:
	case RTOldContainedByStrategyNumber:
		retval = (bool) box2df_overlaps(key, query);
		break;
		
	/* To one side */
	case RTAboveStrategyNumber:
		retval = (bool)(!box2df_overbelow(key, query));
		break;
	case RTBelowStrategyNumber:
		retval = (bool)(!box2df_overabove(key, query));
		break;
	case RTRightStrategyNumber:
		retval = (bool)(!box2df_overleft(key, query));
		break;
	case RTLeftStrategyNumber:
		retval = (bool)(!box2df_overright(key, query));
		break;

	/* Overlapping to one side */
	case RTOverAboveStrategyNumber:
		retval = (bool)(!box2df_below(key, query));
		break;
	case RTOverBelowStrategyNumber:
		retval = (bool)(!box2df_above(key, query));
		break;
	case RTOverRightStrategyNumber:
		retval = (bool)(!box2df_left(key, query));
		break;
	case RTOverLeftStrategyNumber:
		retval = (bool)(!box2df_right(key, query));
		break;
		
	default:
		retval = FALSE;
	}

	return (retval);
}

Datum WTBtree_consistent(PG_FUNCTION_ARGS)
{	
	printf("------------------consistent\n");

	GISTENTRY  *entry = (GISTENTRY *) PG_GETARG_POINTER(0);	
	void	   *query = (void *) DatumGetTextP(PG_GETARG_DATUM(1));
	StrategyNumber strategy = (StrategyNumber) PG_GETARG_UINT16(2);
	bool		result;	
	/* Oid		subtype = PG_GETARG_OID(3); */
	
/*
GBT_VARKEY *orge = (GBT_VARKEY *) DatumGetPointer(entry->key);
GBT_VARKEY_R ok;

ok = gbt_var_key_readable(orge);

printf("ok.lower : %s\n", ok.lower);
printf("VARDATA(ok.lower) : %s\n", VARDATA(ok.lower));
printf("VARDATA(ok.upper) : %s\n", VARDATA(ok.upper));

printf("VARDATA_4B(ok.lower) : %s\n", VARDATA_4B(ok.lower));
printf("VARDATA_4B(ok.upper) : %s\n", VARDATA_4B(ok.upper));

*/

	BOX2DF query_gbox_index;
	gserialized_datum_get_box2df_p(query, &query_gbox_index);

	if (GIST_LEAF(entry))
	{
		result = gserialized_gist_consistent_leaf_2d(
		             (BOX2DF*)DatumGetPointer(entry->key),
		             &query_gbox_index, strategy);
	}
	else
	{
		result = gserialized_gist_consistent_internal_2d(
		             (BOX2DF*)DatumGetPointer(entry->key),
		             &query_gbox_index, strategy);
	}



/*
	int size = 12;
	char *minPnt, *maxPnt, *cvtGeoHash;

	minPnt = (char*) palloc(size);
	maxPnt = (char*) palloc(size);
	cvtGeoHash = (char*) palloc(size);

	
	memcpy(minPnt, geohash_encode((double) query_gbox_index.ymin, (double) query_gbox_index.xmin, size), size);
	memcpy(maxPnt, geohash_encode((double) query_gbox_index.ymax, (double) query_gbox_index.xmax, size), size);

	cvtGeoHash = convert_GeoHash_from_box2d(minPnt, maxPnt, size);

	printf("-----------geohash_encode : %s\n", cvtGeoHash);	
*/
	/* PostgreSQL 8.4 and later require the RECHECK flag to be set here,
	   rather than being supplied as part of the operator class definition */

/*
	bool	   *recheck = (bool *) PG_GETARG_POINTER(4);

	LEAF_KEY key;

	memcpy(key, DatumGetPointer(entry->key), KEY_SIZE);

	INTERNAL_KEY *ikey = leafKey_to_internaKey(key);	


	*recheck = false;
*/	


	PG_RETURN_BOOL(result);
}

void
WTBtree_key_union(Datum *u, LEAF_KEY leaf_cur)
{	
	//printf("------------------key_union\n");


	if (DatumGetPointer(u))
	{		
		
		*u = PointerGetDatum(leaf_cur);

	//	printf("------------------key_union_5\n");
	}
	else
	{
		//printf("------------------key_union_8\n");
		INTERNAL_KEY *ikey;


		*u = PointerGetDatum(leaf_cur);
		//printf("------------------key_union_9\n");
	}
}

Datum WTBtree_union(PG_FUNCTION_ARGS)
{
	printf("------------------union\n");

	GistEntryVector	*entryvec = (GistEntryVector *) PG_GETARG_POINTER(0);
	int *sizep = (int *) PG_GETARG_POINTER(1); /* Size of the return value */
	int	numranges, i;
	Datum out;
	LEAF_KEY leaf_cur;
	
	numranges = entryvec->n;
	
	memcpy(leaf_cur, DatumGetPointer(entryvec->vector[0].key), KEY_SIZE);

	//POSTGIS_DEBUGF(4, "numranges is %d", numranges);
	
	for ( i = 1; i < numranges; i++ )
	{
		memcpy(leaf_cur, DatumGetPointer(entryvec->vector[i].key), KEY_SIZE);
		//WTBtree_key_union(&out, wkey_cur);
	}
	
	*sizep = sizeof(LEAF_KEY);
	
	PG_RETURN_POINTER(out);
}

GISTENTRY *
WTBtree_var_compress(GISTENTRY *entry)
{
	GISTENTRY  *retval;

	if (entry->leafkey)
	{
		LEAF_KEY	   *leaf = (LEAF_KEY *) DatumGetPointer(PG_DETOAST_DATUM(entry->key));

		retval = palloc(sizeof(GISTENTRY));
		gistentryinit(*retval, PointerGetDatum(leaf),
					  entry->rel, entry->page,
					  entry->offset, TRUE);
	}
	else
		retval = entry;

	return (retval);
}

Datum WTBtree_compress(PG_FUNCTION_ARGS)
{
	printf("------------------compress\n");

	GISTENTRY *entry_in = (GISTENTRY *) PG_GETARG_POINTER(0);
	GISTENTRY *entry_out = NULL;

	LEAF_KEY *leaf;
	//WTB_KEY_IN_LEAF_KEY *LEAF_KEY;

/*
printf("GISTENTRY size : %d\n", sizeof(GISTENTRY));
printf("entry_out->key size : %d\n", sizeof(entry_out->key));
printf("Relation size : %d\n", sizeof(Relation));
printf("Page size : %d\n", sizeof(Page));
printf("OffsetNumber size : %d\n", sizeof(OffsetNumber));
printf("bool size : %d\n", sizeof(bool));

printf("GIST_SPLITVEC size : %d\n", sizeof(GIST_SPLITVEC));
printf("GistEntryVector size : %d\n", sizeof(GistEntryVector));
*/


//memcpy(tmp, DatumGetPointer(PG_DETOAST_DATUM(entry_in->key)), 12);

//printf("entry_in 16진수 값 : %x, key : %s\n", DatumGetPointer(PG_DETOAST_DATUM(entry_in->key))[0], tmp);

/*
printf("entry_in->key : %s\n", DatumGetPointer(entry_in->key));
printf("entry_in->key 16진수 값 : %x, key : %s\n", DatumGetPointer(entry_in->key)[0], DatumGetPointer(entry_in->key));
printf("strlen(entry_in->key) : %d\n", strlen(DatumGetPointer(entry_in->key)));
*/

printf("Leaf %d\n", entry_in->leafkey);

	if (!entry_in->leafkey)
	{		 
		printf("Leaf is NOT!---------------------------------");
		PG_RETURN_POINTER(entry_in);
	}  

printf("After Leaf  %d\n", entry_in->leafkey);
	printf("entry_in->key is %s\n", entry_in->key);
/*
	if (VARATT_IS_EXTENDED(entry_in->key)) {
		printf("if (VARATT_IS_EXTENDED(entry_in->key)) {\n\n");
	}
*/
//	entry_out = (GISTENTRY *) palloc(sizeof(GISTENTRY));
	
	if ( DatumGetPointer(entry_in->key) == NULL )
	{
		printf("entry_in->key is NOT!---------------------------------");
		gistentryinit(*entry_out, (Datum) 0, entry_in->rel,
		              entry_in->page, entry_in->offset, FALSE);
		
		PG_RETURN_POINTER(entry_out);
	}

	printf("entry_in->key is %s\n", entry_in->key);

//	leaf = (LEAF_KEY *) palloc(sizeof(LEAF_KEY));
//	memcpy(leaf, DatumGetPointer(entry_in->key), KEY_SIZE);

	printf("leaf is %s\n", leaf);
	//memcpy(leaf, "1234", KEY_SIZE);

/*
	printf("leaf is %s\n", leaf);

	int i;
	for (i = 0; i<14; i++)
	{
		printf("leaf is %x\n", leaf[i]);
	}
*/

	/* Prepare GISTENTRY for return. */
	
/*
printf("entry_in : %s\n", entry_in->key);
printf("DatumGetPointer(entry_in) : %s\n", DatumGetPointer(entry_in->key));
*/

	Datum		d = DirectFunctionCall1(rtrim1, entry_in->key);

	GISTENTRY trim;
	//leaf = (LEAF_KEY) DatumGetPointer(entry_in->key);
	gistentryinit(trim, d,
	              entry_in->rel, entry_in->page, entry_in->offset, TRUE);

	entry_out = WTBtree_var_compress(&trim);

	
/*
printf("DatumGetPointer(PG_DETOAST_DATUM(entry_in->key)) : %s\n", DatumGetPointer(PG_DETOAST_DATUM(entry_in->key)));
printf("d : %s\n", DatumGetPointer(d));
printf("entry_out : %s\n", entry_out->key);
printf("entry_out 16진수 값 : %x, key : %s\n", DatumGetPointer(entry_out->key)[0], DatumGetPointer(entry_out->key));
printf("entry_out 12번째 자리 16진수 값 : %x, key : %s\n", DatumGetPointer(entry_out->key)[11], entry_out->key);
printf("entry_out 13번째 자리 16진수 값 : %x, key : %s\n", DatumGetPointer(entry_out->key)[12], entry_out->key);
*/

	PG_RETURN_POINTER(entry_out);
}


Datum WTBtree_decompress(PG_FUNCTION_ARGS)
{
	// decompress 불필요
	PG_RETURN_POINTER(PG_GETARG_POINTER(0));
}

 int
WTBtree_node_cp_len(LEAF_KEY w)
{
//	WTB_KEY_IN_IKey *ikey = node_key_to_range_key(w);

	char temp[KEY_SIZE];

	//printf("FN(WTBtree_node_cp_len) : wkey is %s\n", w);

	memcpy(temp, w, KEY_SIZE);

//	printf("FN(WTBtree_node_cp_len) : temp is %s\n", temp);

	int 		i = 0;
	int		l = 0;
	int		t1len = VARSIZE(temp) - VARHDRSZ;
	int		t2len = VARSIZE(temp) - VARHDRSZ;
	int		ml = Min(t1len, t2len);
	char	   *p1 = VARDATA(temp);
	char	   *p2 = VARDATA(temp);

	if (ml == 0)
		return 0;

	while (i < ml)
	{		
		if (*p1 != *p2)
		{
			return i;	
		}

		p1++;
		p2++;
		l--;
		i++;
	}
	return (ml);				/* lower == upper */
}

/*
** GiST support function. Calculate the "penalty" cost of adding this entry into an existing entry.
** Calculate the change in volume of the old entry once the new entry is added.
*/
Datum WTBtree_penalty(PG_FUNCTION_ARGS)
{
	printf("------------------penalty\n");

	GISTENTRY  *o = (GISTENTRY *) PG_GETARG_POINTER(0);
	GISTENTRY  *n = (GISTENTRY *) PG_GETARG_POINTER(1);
	float	   *result = (float *) PG_GETARG_POINTER(2);
	LEAF_KEY origKey, newKey;
	
	printf("---------o->key : %s\n", o->key);

	memcpy(origKey, DatumGetPointer(o->key), KEY_SIZE);
	memcpy(newKey, DatumGetPointer(n->key), KEY_SIZE);

printf("%x\n", origKey[0]);
printf("%x\n", origKey[1]);
	printf("---------origkey : %s\n", origKey);
	printf("---------newkey : %s\n", newKey);

	if ( (origKey == NULL) && (newKey == NULL) )
	{		
		*result = 0.0;
		PG_RETURN_FLOAT8(*result);
	}

	Datum		d = PointerGetDatum(0);
	double		dres;
	int		ol, ul;
	
	
	WTBtree_key_union(&d, origKey);
	ol = WTBtree_node_cp_len(DatumGetPointer(d));
	WTBtree_key_union(&d, newKey);
	ul = WTBtree_node_cp_len(DatumGetPointer(d));
	
	if (ul < ol)
	{
		dres = (ol - ul);	/* reduction of common prefix len */
	}	
	
	*result += FLT_MIN;
	*result += (float) (dres / ((double) (ol + 1)));
//	*result *= (FLT_MAX / (o->rel->rd_att->natts + 1));
		
	PG_RETURN_POINTER(result);
}


Datum
WTBtree_same(PG_FUNCTION_ARGS)
{
	LEAF_KEY *w1 = (LEAF_KEY *)PG_GETARG_POINTER(0);
	LEAF_KEY *w2 = (LEAF_KEY *)PG_GETARG_POINTER(1);
	bool *result = (bool *) PG_GETARG_POINTER(2);

	
	
	PG_RETURN_POINTER(result);
}


Datum
WTBtree_picksplit(PG_FUNCTION_ARGS)
{
	printf("------------------picksplit\n");

	GistEntryVector *entryvec = (GistEntryVector *) PG_GETARG_POINTER(0);
	GIST_SPLITVEC *v = (GIST_SPLITVEC *) PG_GETARG_POINTER(1);
	
	OffsetNumber i, j, maxoff = entryvec->n - 1;
	OffsetNumber *left, *right;
	
	int nbytes;
		
	LEAF_KEY cur, unionL, unionR;

	// sizeof(OffsetNumber) : 2
	// sizeof(OffsetNumber*) : 8
	nbytes = (maxoff + 1) * sizeof(OffsetNumber);	

	v->spl_left = (OffsetNumber *) palloc(nbytes);
	left = v->spl_left;
	v->spl_right = (OffsetNumber *) palloc(nbytes);	
	right = v->spl_right;
	v->spl_ldatum = PointerGetDatum(0);
	v->spl_rdatum = PointerGetDatum(0);
	v->spl_nleft = 0;
	v->spl_nright = 0;
/*
	printf("left : %p\n", left);
	printf("right : %p\n", right);

	printf("Before sorting\n");
*/

//printf("16진수 값 : %x, key : %s\n", DatumGetPointer(entryvec->vector[1].key)[0], entryvec->vector[1].key);
/*
	for (i = FirstOffsetNumber; i <= maxoff; i = OffsetNumberNext(i))
	{
		printf("%d, key : %s\n", i, entryvec->vector[i].key);

	}
*/
	/* Bubble sort */
/*
	char *tmp_entrykey;
	tmp_entrykey = (char *)palloc(KEY_SIZE);

	for (i = FirstOffsetNumber; i < maxoff; i = OffsetNumberNext(i))
	{
		for (j = FirstOffsetNumber; j <= maxoff-j; j = OffsetNumberNext(j))
		{
			if (memcmp(DatumGetPointer(entryvec->vector[j].key), DatumGetPointer(entryvec->vector[j+1].key), KEY_SIZE) > 0)
			{
					memcpy(tmp_entrykey, DatumGetPointer(entryvec->vector[j].key), KEY_SIZE);
					memcpy(DatumGetPointer(entryvec->vector[j].key), DatumGetPointer(entryvec->vector[j+1].key), KEY_SIZE);
					memcpy(DatumGetPointer(entryvec->vector[j+1].key), tmp_entrykey, KEY_SIZE);
			}
		}
	}
*/
//	printf("After sorting\n");
/*
	for (i = FirstOffsetNumber; i <= maxoff; i = OffsetNumberNext(i))
	{
		printf("%d, key : %s\n", i, entryvec->vector[i].key);

	}
*/
/*
	printf("entryvec->n is %d\n", entryvec->n);
	printf("maxoff is %d\n", maxoff);
*/
	// FirstOffsetNumber : 1
	for (i = FirstOffsetNumber; i <= maxoff; i = OffsetNumberNext(i))
	{
		//printf("------------------test 4\n");

		memcpy(cur, DatumGetPointer(entryvec->vector[i].key), KEY_SIZE);


		//printf("cur : %s\n", cur);

		if (i <= (maxoff - FirstOffsetNumber + 1) / 2)
		{
			//printf("--------- %d _ left node\n", i);

			// Left node
			WTBtree_key_union(&v->spl_ldatum, cur);
//printf("left cur : %s\n", &v->spl_ldatum);
			//printf("---------left node 1\n");
			//printf("---------v->spl_nleft : %d\n", v->spl_nleft);
			//printf("---------i : %d\n", i);
			v->spl_left[v->spl_nleft] = i;
	
			//printf("---------left node 2\n");

			v->spl_nleft++;
			//printf("---------left node 3\n");
		}
		else
		{
		//	printf("--------- %d _ right node\n", i);

			// Right node
			WTBtree_key_union(&v->spl_rdatum, cur);
	//	printf("right cur : %s\n", &v->spl_rdatum);
			//printf("---------right node 1\n");
			//printf("---------v->spl_nright : %d\n", v->spl_nright);
			//printf("---------i : %d\n", i);
			v->spl_right[v->spl_nright] = i;

			//printf("---------right node 2\n");

			v->spl_nright++;
			//printf("---------right node 3\n");
		}
	}
	/*
for (i = FirstOffsetNumber; i <= maxoff; i = OffsetNumberNext(i))
	{

printf("DatumGetPointer(entryvec->vector[%d].key) : %s\n",i, DatumGetPointer(entryvec->vector[i].key));
}
*/
	
	PG_RETURN_POINTER(v);
}

