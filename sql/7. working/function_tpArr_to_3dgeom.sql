﻿
-- Function: public.tparr_to_3dgeom(tpoint[])

-- DROP FUNCTION public.tparr_to_3dgeom(tpoint[]);

CREATE OR REPLACE FUNCTION public.tparr_to_3dgeom(tpoint[])
  RETURNS SETOF geometry AS
$BODY$
DECLARE
	tpArr				ALIAS FOR $1;

	i				integer;
	array_max			integer;
	ts_to_double			double precision;
	
	return_geoms			geometry;
BEGIN
	EXECUTE 'SELECT ARRAY_UPPER($1, 1)'
	INTO array_max USING tpArr;

	i := 1;
	
	WHILE( i <= array_max ) LOOP
		EXECUTE 'SELECT EXTRACT(EPOCH FROM TIMESTAMP WITH TIME ZONE ' || quote_literal(tpArr[i].ts) || ')' INTO ts_to_double;
		return_geoms := st_makePoint(ST_X(tpArr[i].pnt), ST_Y(tpArr[i].pnt), ts_to_double);
		
		i := i+1;
		RETURN NEXT return_geoms;
	END LOOP;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.tparr_to_3dgeom(tpoint[])
  OWNER TO postgres;


select GeometryType(tpArr_to_3dgeom(tpseg)) from mpseq_1074501_traj where mpid=1 and segid=1;