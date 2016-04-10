\set WTBtree_LIB '/usr/local/posttrajectory/test/WTBtree_gist/lib/WTBtree_gist'


CREATE TABLE wtraj (
	id int,
	wk char(12)
);


CREATE OR REPLACE FUNCTION WTBtree_consistent(internal,bpchar,int2,oid,internal)
RETURNS bool
AS :'WTBtree_LIB','WTBtree_consistent'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION WTBtree_compress(internal)
RETURNS internal
AS :'WTBtree_LIB','WTBtree_compress'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION WTBtree_decompress(internal)
RETURNS internal
AS :'WTBtree_LIB','WTBtree_decompress'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION WTBtree_penalty(internal,internal,internal)
RETURNS internal
AS :'WTBtree_LIB','WTBtree_penalty'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION WTBtree_picksplit(internal, internal)
RETURNS internal
AS :'WTBtree_LIB','WTBtree_picksplit'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION WTBtree_union(internal, internal)
RETURNS internal
AS :'WTBtree_LIB','WTBtree_union'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION WTBtree_same(internal, internal, internal)
RETURNS internal
AS :'WTBtree_LIB','WTBtree_same'
LANGUAGE C IMMUTABLE STRICT;

----------------------------------------------------------------------------------
-- khyoo
----------------------------------------------------------------------------------

CREATE TYPE khyoo;

CREATE OR REPLACE FUNCTION khyoo_in(cstring)
	RETURNS khyoo
	AS :'WTBtree_LIB','khyoo_in'
	LANGUAGE 'c' IMMUTABLE STRICT; 

CREATE OR REPLACE FUNCTION khyoo_out(khyoo)
	RETURNS cstring
	AS :'WTBtree_LIB','khyoo_out'
	LANGUAGE 'c' IMMUTABLE STRICT; 

CREATE TYPE khyoo (
	internallength = 16,
	input = khyoo_in,
	output = khyoo_out,
	storage = plain
);



----------------------------------------------------------------------------------
-- OPERATOR
----------------------------------------------------------------------------------

CREATE OPERATOR CLASS WTBtree_gist_ops
DEFAULT FOR TYPE bpchar USING gist
AS
	OPERATOR	1	<  ,
	OPERATOR	2	<= ,
	OPERATOR	3	=  ,
	OPERATOR	4	>= ,
	OPERATOR	5	>  ,
	FUNCTION	1	WTBtree_consistent (internal, bpchar, int2, oid, internal),
	FUNCTION	2	WTBtree_union (internal, internal),
	FUNCTION	3	WTBtree_compress (internal),
	FUNCTION	4	WTBtree_decompress (internal),
	FUNCTION	5	WTBtree_penalty (internal, internal, internal),
	FUNCTION	6	WTBtree_picksplit (internal, internal),
	FUNCTION	7	WTBtree_same (internal, internal, internal);

