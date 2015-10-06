
CREATE FUNCTION g_salary_consistent(internal,_int4,int,oid,internal)
RETURNS bool
AS '$libdir/postgis-2.1'
LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION g_salary_compress(internal)
RETURNS internal
AS '$libdir/postgis-2.1'
LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION g_salary_decompress(internal)
RETURNS internal
AS '$libdir/postgis-2.1'
LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION g_salary_penalty(internal,internal,internal)
RETURNS internal
AS '$libdir/postgis-2.1'
LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION g_salary_picksplit(internal, internal)
RETURNS internal
AS '$libdir/postgis-2.1'
LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION g_salary_union(internal, internal)
RETURNS _int4
AS '$libdir/postgis-2.1'
LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION g_salary_same(_int4, _int4, internal)
RETURNS internal
AS '$libdir/postgis-2.1'
LANGUAGE C IMMUTABLE STRICT;


-- Create the operator class for indexing

CREATE OPERATOR CLASS gist_salary_ops
DEFAULT FOR TYPE _int4 USING gist AS	
	FUNCTION	1	g_salary_consistent (internal, _int4, int, oid, internal),
	FUNCTION	2	g_salary_union (internal, internal),
	FUNCTION	3	g_salary_compress (internal),
	FUNCTION	4	g_salary_decompress (internal),
	FUNCTION	5	g_salary_penalty (internal, internal, internal),
	FUNCTION	6	g_salary_picksplit (internal, internal),
	FUNCTION	7	g_salary_same (_int4, _int4, internal);

