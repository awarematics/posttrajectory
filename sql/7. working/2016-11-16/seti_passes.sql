-- Function: public.seti_passes(box2d, tpoint[], geometry)

-- DROP FUNCTION public.seti_passes(box2d, tpoint[], geometry);

CREATE OR REPLACE FUNCTION public.seti_passes(
    box2d,
    tpoint[],
    geometry)
  RETURNS boolean AS
$BODY$
DECLARE
	rect		alias for $1;
	tpseg		alias for $2;
	query_geom	alias for $3;

	rect_to_geom	geometry;
	arr_size	integer;
	
	temp_tpseg	tpoint[];		
BEGIN	
	rect_to_geom := geometry(rect);

	arr_size := array_length(tpseg, 1);

	-- raise notice '%', arr_size;

	temp_tpseg := array_cat(temp_tpseg, tpseg);
	
	IF (ST_Intersects(tpseg[1].pnt, rect_to_geom)) THEN
		-- raise notice 'Start Point Intersects';
		
		IF (ST_Intersects(tpseg[arr_size].pnt, rect_to_geom)) THEN
			--raise notice 'Start, Last Point Intersects';
			
		ELSE 
			--raise notice 'Start Point Intersects, Last Point Not Intersects';
			temp_tpseg[arr_size] := temp_tpseg[arr_size-1];
		END IF;
	ELSE 
		--raise notice 'Start Point Not ST_Intersects';

		IF (ST_Intersects(tpseg[arr_size].pnt, rect_to_geom)) THEN
			--raise notice 'Start Point Not Intersects, Last Point Intersects';
			temp_tpseg[1] := temp_tpseg[2];
		ELSE 
			--raise notice 'Start, Last Point Not Intersects';
			temp_tpseg[1] := temp_tpseg[2];
			temp_tpseg[arr_size] := temp_tpseg[arr_size-1];
		END IF;
	END IF;

	RETURN tj_passes(temp_tpseg, query_geom);
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
