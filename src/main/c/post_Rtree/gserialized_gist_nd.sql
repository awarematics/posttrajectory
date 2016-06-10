\set post_Rtree_LIB '/usr/local/posttrajectory/test/post_Rtree/lib/post_Rtree'


-- Availability: 2.0.0
CREATE OR REPLACE FUNCTION geometry_gist_consistent_nd(internal,geometry,int4) 
	RETURNS bool 
	AS '$libdir/postgis-2.2' ,'gserialized_gist_consistent'
	LANGUAGE 'c';

-- Availability: 2.0.0
CREATE OR REPLACE FUNCTION geometry_gist_compress_nd(internal) 
	RETURNS internal 
	AS '$libdir/postgis-2.2','gserialized_gist_compress'
	LANGUAGE 'c';

-- Availability: 2.0.0
CREATE OR REPLACE FUNCTION geometry_gist_penalty_nd(internal,internal,internal) 
	RETURNS internal 
	AS '$libdir/postgis-2.2' ,'gserialized_gist_penalty'
	LANGUAGE 'c';

-- Availability: 2.0.0
CREATE OR REPLACE FUNCTION geometry_gist_picksplit_nd(internal, internal) 
	RETURNS internal 
	AS '$libdir/postgis-2.2' ,'gserialized_gist_picksplit'
	LANGUAGE 'c';

-- Availability: 2.0.0
CREATE OR REPLACE FUNCTION geometry_gist_union_nd(bytea, internal) 
	RETURNS internal 
	AS '$libdir/postgis-2.2' ,'gserialized_gist_union'
	LANGUAGE 'c';

-- Availability: 2.0.0
CREATE OR REPLACE FUNCTION geometry_gist_same_nd(geometry, geometry, internal) 
	RETURNS internal 
	AS '$libdir/postgis-2.2' ,'gserialized_gist_same'
	LANGUAGE 'c';

-- Availability: 2.0.0
CREATE OR REPLACE FUNCTION geometry_gist_decompress_nd(internal) 
	RETURNS internal 
	AS '$libdir/postgis-2.2' ,'gserialized_gist_decompress'
	LANGUAGE 'c';

----------------------------------------------------------------------------------
-- OPERATOR
----------------------------------------------------------------------------------

CREATE OPERATOR CLASS gist_tpArr_ops_3d
	FOR TYPE tpoint[] USING GIST AS
	STORAGE 	gidx,	
--	OPERATOR        3        &&&	,
--	OPERATOR        6        ~=	,
--	OPERATOR        7        ~	,
--	OPERATOR        8        @	,
	-- Availability: 2.2.0
--	OPERATOR        13       <<->> FOR ORDER BY pg_catalog.float_ops,
	-- Availability: 2.2.0
--	OPERATOR        20       |=| FOR ORDER BY pg_catalog.float_ops,
	-- Availability: 2.2.0	FUNCTION        8        geometry_gist_distance_nd (internal, geometry, int4),
	FUNCTION        1        geometry_gist_consistent_nd (internal, geometry, int4),
	FUNCTION        2        geometry_gist_union_nd (bytea, internal),
	FUNCTION        3        geometry_gist_compress_nd (internal),
	FUNCTION        4        geometry_gist_decompress_nd (internal),
	FUNCTION        5        geometry_gist_penalty_nd (internal, internal, internal),
	FUNCTION        6        geometry_gist_picksplit_nd (internal, internal),
	FUNCTION        7        geometry_gist_same_nd (geometry, geometry, internal);

