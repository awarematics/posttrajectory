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
-- OPERATOR
----------------------------------------------------------------------------------

CREATE OPERATOR CLASS gist_box2d_ops
	FOR TYPE geometry USING GIST AS	
	OPERATOR	1	<  ,
	OPERATOR	2	<= ,
	OPERATOR	3	=  ,
	OPERATOR	4	>= ,
	OPERATOR	5	>  ,
	FUNCTION	1	gbt_bpchar_consistent (internal, bpchar , int2, oid, internal),
	FUNCTION	2	gbt_text_union (bytea, internal),
	FUNCTION	3	gbt_bpchar_compress (internal),
	FUNCTION	4	gbt_var_decompress (internal),
	FUNCTION	5	gbt_text_penalty (internal, internal, internal),
	FUNCTION	6	gbt_text_picksplit (internal, internal),
	FUNCTION	7	gbt_text_same (internal, internal, internal),
	STORAGE			box2d;
