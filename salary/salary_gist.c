
#include "postgres.h"

#include "access/gist.h"
#include "access/skey.h"


/*
** GiST support methods
*/
PG_FUNCTION_INFO_V1(g_salary_consistent);
PG_FUNCTION_INFO_V1(g_salary_compress);
PG_FUNCTION_INFO_V1(g_salary_decompress);
PG_FUNCTION_INFO_V1(g_salary_penalty);
PG_FUNCTION_INFO_V1(g_salary_picksplit);
PG_FUNCTION_INFO_V1(g_salary_union);
PG_FUNCTION_INFO_V1(g_salary_same);


Datum
g_salary_consistent(PG_FUNCTION_ARGS)
{
	
	PG_RETURN_BOOL(retval);
}


Datum
g_salary_union(PG_FUNCTION_ARGS)
{
	
	PG_RETURN_POINTER(res);
}


Datum
g_salary_compress(PG_FUNCTION_ARGS)
{
	
	PG_RETURN_POINTER(entry);
}

Datum
g_salary_decompress(PG_FUNCTION_ARGS)
{
	
	PG_RETURN_POINTER(retval);
}


Datum
g_salary_penalty(PG_FUNCTION_ARGS)
{
	
	PG_RETURN_POINTER(result);
}


Datum
g_salary_same(PG_FUNCTION_ARGS)
{
	
	PG_RETURN_POINTER(result);
}


Datum
g_salary_picksplit(PG_FUNCTION_ARGS)
{
	

	PG_RETURN_POINTER(v);
}
