



#include "postgres.h"

#include "access/gist.h"
#include "access/skey.h"
#include "utils/builtins.h"

#include "WTBtree_gist.h"

#define WTBtree_LessStrategyNumber		1
#define WTBtree_LessEqualStrategyNumber		2
#define WTBtree_EqualStrategyNumber		3
#define WTBtree_GreaterEqualStrategyNumber	4
#define WTBtree_GreaterStrategyNumber		5
#define WTBtree_NotEqualStrategyNumber		6

#define KEY_SIZE 12


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



// wkey를 중간 노드 키(IKEY)로 변환
INTERNAL_KEY* leafKey_to_internaKey(LEAF_KEY w)
{
	INTERNAL_KEY *ikey;

	ikey = palloc(sizeof(INTERNAL_KEY));

	memcpy(ikey->lower, w, KEY_SIZE); 
	memcpy(ikey->upper, w, KEY_SIZE);

	return ikey;
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

	LEAF_KEY key;

	memcpy(key, DatumGetPointer(entry->key), KEY_SIZE);

	INTERNAL_KEY *ikey = leafKey_to_internaKey(key);	

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
		printf("entry_in->leafKey is False!---------------------------------");
		PG_RETURN_POINTER(entry_in);
	}  

	if ( DatumGetPointer(entry_in->key) == NULL )
	{
		printf("entry_in->key is NULL!--------------------------------------");
		gistentryinit(*entry_out, (Datum) 0, entry_in->rel,
		              entry_in->page, entry_in->offset, FALSE);
		
		PG_RETURN_POINTER(entry_out);
	}

	//printf("entry_in->key is %s\n", entry_in->key);

//	leaf = (LEAF_KEY *) palloc(sizeof(LEAF_KEY));
//	memcpy(leaf, DatumGetPointer(entry_in->key), KEY_SIZE);

	//printf("leaf is %s\n", leaf);
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
	char temp[KEY_SIZE];

	memcpy(temp, w, KEY_SIZE);

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

