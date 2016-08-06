


CREATE OR REPLACE FUNCTION tpArr_to_geom(tpoint[]) RETURNS geometry AS
$$
DECLARE
	array_tpoint	alias for $1;
	array_max	integer;
	array_lower	integer;	
	i		integer;
	geoms		geometry ARRAY;
	makeLine	geometry;
BEGIN
	EXECUTE 'select array_upper($1, 1)'
	INTO array_max USING array_tpoint;

	EXECUTE 'select array_lower($1, 1)'
	INTO array_lower USING array_tpoint;

	i := array_lower;
	
	WHILE( i <= array_max ) LOOP
		geoms := geoms || array_tpoint[i].pnt;
		
		i := i+1;
	END LOOP;

	makeLine := st_makeline(geoms);
	
	RETURN makeLine;
END
$$
LANGUAGE 'plpgsql' IMMUTABLE;
