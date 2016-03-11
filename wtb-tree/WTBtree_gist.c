

#include <string.h>
#include "postgres.h"

#include "access/gist.h"
#include "access/skey.h"

#include "lwgeom_log.h"   
#include "WTBtree_gist.h"

#define WTBtree_LessStrategyNumber		1
#define WTBtree_LessEqualStrategyNumber		2
#define WTBtree_EqualStrategyNumber		3
#define WTBtree_GreaterEqualStrategyNumber	4
#define WTBtree_GreaterStrategyNumber		5
#define WTBtree_NotEqualStrategyNumber		6

PG_MODULE_MAGIC;

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
PG_FUNCTION_INFO_V1(WTBtree_consistent);
PG_FUNCTION_INFO_V1(WTBtree_compress);
PG_FUNCTION_INFO_V1(WTBtree_decompress);
PG_FUNCTION_INFO_V1(WTBtree_penalty);
PG_FUNCTION_INFO_V1(WTBtree_picksplit);
PG_FUNCTION_INFO_V1(WTBtree_union);
PG_FUNCTION_INFO_V1(WTBtree_same);


// wkey를 Leaf 노드 키(LKEY)로 변환
WTB_KEY_IN_LKey* range_key_to_node_key(wkey w)
{
	printf("FN(range_key_to_node_key) : wkey is %s\n", w);

	WTB_KEY_IN_LKey *LKEY;
	char temp[35];

	strcpy(temp, w);

	//printf("w size is %d\n", strlen(w));
	printf("FN(range_key_to_node_key) : w[0] is %c\n", *w);

	//if (*w == 'l')
	//{
		printf("FN(range_key_to_node_key) :	if (*w == 'l')\n");
		LKEY = (WTB_KEY_IN_LKey *)palloc(sizeof(WTB_KEY_IN_LKey));
		memcpy((char*)LKEY, (char*)temp, sizeof(WTB_KEY_IN_LKey));		
	//}

	return LKEY;
}

// wkey를 중간 노드 키(IKEY)로 변환
WTB_KEY_IN_IKey* node_key_to_range_key(wkey w)
{
	
}

wkey* range_key_to_wkey(WTB_KEY_IN_IKey *ikey)
{
	wkey *w;
	char temp[25];
	
	temp[0] = 'i';

	strcpy(temp, ikey->lower);
	strcat(temp, ikey->upper);	

	w = (wkey *)palloc(sizeof(wkey));
	memcpy((char*)w, (char*)temp, sizeof(wkey));		
		
	return w;
}

bool char_gt(const void *query, const char *key)
{	
	bool		result;

	result = (strcmp(query, key) > 0);

	return result;
}

bool char_ge(const void *query, const char *key)
{	
	bool		result;

	result = (strcmp(query, key) >= 0);

	return result;
}

bool char_eq(const void *query, const char *key)
{	
	bool		result;
	int		len1, len2;

	len1 = strlen(query);
	len2 = strlen(key);
	
	if (len1 != len2)
	{
		result = false;
	} else
	{		
		result = (strcmp(query, key) == 0);
	}
	
	return result;
}

bool char_lt(const void *query, const char *key)
{	
	bool		result;

	result = (strcmp(query, key) < 0);

	return result;
}

bool char_le(const void *query, const char *key)
{	
	bool		result;

	result = (strcmp(query, key) <= 0);

	return result;
}

int char_cmp(const void *query, const char *key)
{	
	int		result;

	result = strcmp(query, key);

	return result;
}

Datum WTBtree_consistent(PG_FUNCTION_ARGS)
{	
	printf("------------------consistent\n");

	GISTENTRY  *entry = (GISTENTRY *) PG_GETARG_POINTER(0);	
	void	   *query = (void *) DatumGetTextP(PG_GETARG_DATUM(1));
	StrategyNumber strategy = (StrategyNumber) PG_GETARG_UINT16(2);
	bool		result;	
	/* Oid		subtype = PG_GETARG_OID(3); */
	
	/* PostgreSQL 8.4 and later require the RECHECK flag to be set here,
	   rather than being supplied as part of the operator class definition */
	bool	   *recheck = (bool *) PG_GETARG_POINTER(4);

	wkey key;

	strcpy(key, DatumGetPointer(entry->key));

	WTB_KEY_IN_IKey *ikey = node_key_to_range_key(key);	

	/* We set recheck to false to avoid repeatedly pulling every "possibly matched" geometry
	   out during index scans. For cases when the geometries are large, rechecking
	   can make things twice as slow. */
	*recheck = false;
	
	switch (strategy)
	{
		case WTBtree_LessStrategyNumber:
			if (GIST_LEAF(entry))
				result = char_lt(query, ikey->lower);
			else
				result = char_cmp(query, ikey->upper) <= 0;
			break;	
		case WTBtree_LessEqualStrategyNumber:
			if (GIST_LEAF(entry))
				result = char_le(query, ikey->lower);
			else
				result = char_cmp(query, ikey->upper) <= 0;
			break;
		case WTBtree_EqualStrategyNumber:
			if (GIST_LEAF(entry))
				result = char_le(query, ikey->lower);
			else
				result =
					(char_cmp(query, ikey->lower) >= 0 &&
					 char_cmp(query, ikey->upper) <= 0);
			break;
		case WTBtree_GreaterEqualStrategyNumber:
			if (GIST_LEAF(entry))
				result = char_ge(query, ikey->lower);
			else
				result = char_cmp(query, ikey->lower) >= 0;
			break;		
		case WTBtree_GreaterStrategyNumber:
			if (GIST_LEAF(entry))
				result = char_gt(query, ikey->lower);
			else
				result = char_cmp(query, ikey->lower) >= 0;
			break;			
		case WTBtree_NotEqualStrategyNumber:
			result = !(char_eq(query, ikey->lower) && char_eq(query, ikey->upper));
			break;
		default:
			result = FALSE;
	}

	PG_RETURN_BOOL(result);
}

void
WTBtree_key_union(Datum *u, wkey wkey_cur)
{	
	printf("------------------key_union\n");

	printf("\nwkey_cur is %s\n", wkey_cur);

	WTB_KEY_IN_IKey *cur_ikey;
	WTB_KEY_IN_IKey *new_ikey;

	//printf("------------------key_union_1\n");

	if (DatumGetPointer(u))
	{		
		//printf("------------------key_union_2\n");

		WTB_KEY_IN_IKey *ikey;

		//printf("------------------key_union_3\n");

		strcpy(ikey->lower, wkey_cur);

		//printf("------------------key_union_4\n");

		strcpy(ikey->upper, wkey_cur);

		*u = PointerGetDatum(range_key_to_wkey(ikey));

		//printf("------------------key_union_5\n");
	}
	else
	{
		//printf("------------------key_union_8\n");
		WTB_KEY_IN_IKey *ikey;

		strcpy(ikey->lower, wkey_cur);
		strcpy(ikey->upper, wkey_cur);

		*u = PointerGetDatum(range_key_to_wkey(ikey));
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
	wkey wkey_cur;
	
	numranges = entryvec->n;
	
	strcpy(wkey_cur, DatumGetPointer(entryvec->vector[0].key));

	//POSTGIS_DEBUGF(4, "numranges is %d", numranges);
	
	for ( i = 1; i < numranges; i++ )
	{
		strcpy(wkey_cur, DatumGetPointer(entryvec->vector[i].key));
		WTBtree_key_union(&out, wkey_cur);
	}
	
	*sizep = sizeof(wkey);
	
	PG_RETURN_POINTER(out);
}


Datum WTBtree_compress(PG_FUNCTION_ARGS)
{
	printf("------------------compress\n");

	GISTENTRY *entry_in = (GISTENTRY *) PG_GETARG_POINTER(0);
	GISTENTRY *entry_out = NULL;
	wkey leaf;
	WTB_KEY_IN_LKey *LKEY;

/*
printf("GISTENTRY size : %d\n", sizeof(GISTENTRY));
printf("Datum size : %d\n", sizeof(((GISTENTRY*)0)->key));
printf("Relation size : %d\n", sizeof(Relation));
printf("Page size : %d\n", sizeof(Page));
printf("OffsetNumber size : %d\n", sizeof(OffsetNumber));
printf("bool size : %d\n", sizeof(bool));

printf("GIST_SPLITVEC size : %d\n", sizeof(GIST_SPLITVEC));
printf("GistEntryVector size : %d\n", sizeof(GistEntryVector));
*/

	// Leaf 키가 아닐 때,
	if ( ! entry_in->leafkey )
	{		
		PG_RETURN_POINTER(entry_in);
	}

	entry_out = palloc(sizeof(GISTENTRY));
	
	if ( DatumGetPointer(entry_in->key) == NULL )
	{
		gistentryinit(*entry_out, (Datum) 0, entry_in->rel,
		              entry_in->page, entry_in->offset, FALSE);
		
		PG_RETURN_POINTER(entry_out);
	}

	strcpy(leaf, DatumGetPointer(entry_in->key));

	printf("leaf is %s\n", leaf);

	//*(leaf+0) = 'l';

	LKEY = range_key_to_node_key(leaf);

	/* Prepare GISTENTRY for return. */
	gistentryinit(*entry_out, PointerGetDatum(LKEY),
	              entry_in->rel, entry_in->page, entry_in->offset, TRUE);

	PG_RETURN_POINTER(entry_out);
}

Datum WTBtree_decompress(PG_FUNCTION_ARGS)
{
	// decompress 불필요
	PG_RETURN_POINTER(PG_GETARG_POINTER(0));
}

 int
WTBtree_node_cp_len(wkey w)
{
	WTB_KEY_IN_IKey *ikey = node_key_to_range_key(w);
	int		i = 0;
	int		l = 0;
	int		t1len = VARSIZE(ikey->lower) - VARHDRSZ;
	int		t2len = VARSIZE(ikey->upper) - VARHDRSZ;
	int		ml = Min(t1len, t2len);
	char	   *p1 = VARDATA(ikey->lower);
	char	   *p2 = VARDATA(ikey->upper);

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
	wkey origKey, newKey;
	
	strcpy(origKey, DatumGetPointer(o->key));
	strcpy(newKey, DatumGetPointer(n->key));
	
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
	wkey *w1 = (wkey *)PG_GETARG_POINTER(0);
	wkey *w2 = (wkey *)PG_GETARG_POINTER(1);
	bool *result = (bool *) PG_GETARG_POINTER(2);

	
	
	PG_RETURN_POINTER(result);
}


Datum
WTBtree_picksplit(PG_FUNCTION_ARGS)
{
	printf("------------------picksplit\n");

	GistEntryVector *entryvec = (GistEntryVector *) PG_GETARG_POINTER(0);
	GIST_SPLITVEC *v = (GIST_SPLITVEC *) PG_GETARG_POINTER(1);
	
	OffsetNumber i, maxoff = entryvec->n - 1;
	OffsetNumber *left, *right;
	
	int nbytes;
		
	wkey cur, unionL, unionR;

	nbytes = (maxoff + 1) * sizeof(OffsetNumber);	
	
	v->spl_left = (OffsetNumber *) palloc(nbytes);
	left = v->spl_left;
	v->spl_right = (OffsetNumber *) palloc(nbytes);	
	right = v->spl_right;
	v->spl_ldatum = PointerGetDatum(0);
	v->spl_rdatum = PointerGetDatum(0);
	v->spl_nleft = 0;
	v->spl_nright = 0;
	
			  
	printf("entryvec->n is %d\n", entryvec->n - 1);
	printf("maxoff is %d\n", maxoff);
	
	//printf("------------------test 1\n");

	strcpy(cur, DatumGetPointer(entryvec->vector[1].key));

	//printf("------------------test 2\n");

	for (i = FirstOffsetNumber; i <= maxoff; i = OffsetNumberNext(i))
	{
		//printf("------------------test 4\n");

		strcpy(cur, DatumGetPointer(entryvec->vector[i].key));

		//printf("------------------test 5\n");


		if (i <= (maxoff - FirstOffsetNumber + 1) / 2)
		{
			//printf("--------- %d _ left node\n", i);

			// Left node
			WTBtree_key_union(&v->spl_ldatum, cur);

			//printf("---------left node 1\n");

			//v->spl_left[v->spl_nleft] = i;

			//printf("---------left node 2\n");

			v->spl_nleft++;
			//printf("---------left node 3\n");
		}
		else
		{
			//printf("--------- %d _ right node\n", i);

			// Right node
			WTBtree_key_union(&v->spl_rdatum, cur);

			//printf("---------right node 1\n");

			//v->spl_right[v->spl_nright] = i;

			//printf("---------right node 2\n");

			v->spl_nright++;
			//printf("---------right node 3\n");
		}
	}
	
	
	PG_RETURN_POINTER(v);
}

