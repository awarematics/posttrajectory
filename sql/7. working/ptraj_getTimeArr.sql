﻿-- Function: public.ptraj_gettrajinfo(trajectory)

-- DROP FUNCTION public.ptraj_gettrajinfo(trajectory);

CREATE OR REPLACE FUNCTION public.ptraj_getTimeArr(tpoint[])
  RETURNS SETOF double AS
$BODY$
DECLARE		
	tpArr				ALIAS FOR $1;

	i				integer;
	array_max			integer;
	ts_to_double			double precision;
	
	return_double			double precision;
BEGIN	
	EXECUTE 'SELECT ARRAY_UPPER($1, 1)'
	INTO array_max USING tpArr;

	i := 1;

	WHILE( i <= array_max ) LOOP
		EXECUTE 'SELECT EXTRACT(EPOCH FROM TIMESTAMP WITH TIME ZONE ' || quote_literal(tpArr[i].ts) || ')' INTO ts_to_double;
		geoms := geoms || st_makePoint(ts_to_double, 0.0);
		
		i := i+1;
		RETURN NEXT return_double;
	END LOOP;
	
	-- raise notice '%', traj_prefix;
	FOR data IN EXECUTE sql LOOP
		FOR tmp IN EXECUTE 'SELECT _getTrajInfo($1)' USING data.tpseg LOOP
			RETURN NEXT tmp;
		END LOOP;
	END LOOP;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.ptraj_gettrajinfo(trajectory)
  OWNER TO postgres;