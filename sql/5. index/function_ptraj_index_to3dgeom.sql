﻿-- Function: public.ptraj_index_to3dgeom(geometry, timestamp without time zone, timestamp without time zone)

-- DROP FUNCTION public.ptraj_index_to3dgeom(geometry, timestamp without time zone, timestamp without time zone);

CREATE OR REPLACE FUNCTION public.ptraj_index_to3dgeom(
    geometry,
    timestamp without time zone,
    timestamp without time zone)
  RETURNS geometry AS
$BODY$
DECLARE
	input_geom			ALIAS FOR $1;
	start_time			ALIAS FOR $2;
	end_time			ALIAS FOR $3;

	i				integer;
	sql				varchar;
	txt				varchar;
	data				RECORD;
	tmp_box3d			geometry;
	
	output_geom			geometry;
BEGIN
	sql := 'SELECT ST_X((ST_DumpPoints($1)).geom) AS X, ST_Y((ST_DumpPoints($1)).geom) AS Y';

	txt := 'LINESTRING(';
	i := 1;
	
	FOR data IN EXECUTE sql USING input_geom LOOP
		if (i > 1) then
		txt := txt || ',';
		end if;
		
		txt := txt || data.x || ' ' || data.y || ' ' || toDouble(end_time);
		i := i + 1;
	END LOOP;

	txt := txt || ')';
	
	-- raise notice '%', txt;

	output_geom := ST_Polygon(ST_GeomFromText(txt), 4326);
	
	RETURN output_geom;
END
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;
ALTER FUNCTION public.ptraj_index_to3dgeom(geometry, timestamp without time zone, timestamp without time zone)
  OWNER TO postgres;


select ptraj_index_to3dgeom(geometry(rect), start_time, end_time) from mpseq_2124049_traj where mpid=1 and segid=1;  

select st_astext(ptraj_index_to3dgeom(geometry(rect), start_time, end_time)) from mpseq_2124049_traj where mpid=1 and segid=1;

SELECT geometry(ST_3DMakeBox(ST_MakePoint(-989502.1875, 528439.5625, 10),ST_MakePoint(-987121.375 ,529933.1875, 10))) As abb3d;