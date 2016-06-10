-- Availability: 2.0.0
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

drop operator class gist_tpArr_ops_3d USING GIST;