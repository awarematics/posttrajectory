\set WTBtree_LIB '/usr/local/posttrajectory/test/WTBtree_gist/lib/WTBtree_gist'


CREATE TABLE wtraj (
	id int,
	wk char(10)
);


CREATE OR REPLACE FUNCTION WTBtree_consistent(internal,int4,int,oid,internal)
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
CREATE OR REPLACE FUNCTION wtb_lt(query char(10), wk char(10))
RETURNS bool
AS :'WTBtree_LIB', 'char_lt'
LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION wtb_le(query char(10), wk char(10))
RETURNS bool
AS :'WTBtree_LIB', 'char_le'
LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION wtb_gt(query char(10), wk char(10))
RETURNS bool
AS :'WTBtree_LIB', 'char_gt'
LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION wtb_ge(query char(10), wk char(10))
RETURNS bool
AS :'WTBtree_LIB', 'char_ge'
LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION wtb_eq(query char(10), wk char(10))
RETURNS bool
AS :'WTBtree_LIB', 'char_eq'
LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OPERATOR < (
	LEFTARG = char(10), RIGHTARG = char(10), PROCEDURE = wtb_lt,
	COMMUTATOR = '<'
);

CREATE OPERATOR <= (
	LEFTARG = char(10), RIGHTARG = char(10), PROCEDURE = wtb_le,
	COMMUTATOR = '<='
);

CREATE OPERATOR = (
	LEFTARG = char(10), RIGHTARG = char(10), PROCEDURE = wtb_eq,
	COMMUTATOR = '='
);

CREATE OPERATOR >= (
	LEFTARG = char(10), RIGHTARG = char(10), PROCEDURE = wtb_ge,
	COMMUTATOR = '>='
);
CREATE OPERATOR > (
	LEFTARG = char(10), RIGHTARG = char(10), PROCEDURE = wtb_gt,
	COMMUTATOR = '>'
);

CREATE OPERATOR CLASS WTBtree_gist_ops
DEFAULT FOR TYPE char(10) USING gist
AS
	OPERATOR	1	<  ,
	OPERATOR	2	<= ,
	OPERATOR	3	=  ,
	OPERATOR	4	>= ,
	OPERATOR	5	>  ,
	FUNCTION	1	WTBtree_consistent (internal, int4, int, oid, internal),
	FUNCTION	2	WTBtree_union (internal, internal),
	FUNCTION	3	WTBtree_compress (internal),
	FUNCTION	4	WTBtree_decompress (internal),
	FUNCTION	5	WTBtree_penalty (internal, internal, internal),
	FUNCTION	6	WTBtree_picksplit (internal, internal),
	FUNCTION	7	WTBtree_same (internal, internal, internal);

