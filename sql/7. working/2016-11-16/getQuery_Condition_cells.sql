
-- select * from getQuery_Condition_cells(geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(110.7366413, 25.77352625))));

-- Function: public.getquery_condition_cells(box2d)

-- DROP FUNCTION public.getquery_condition_cells(box2d);

CREATE OR REPLACE FUNCTION public.getquery_condition_cells(box2d)
  RETURNS SETOF mpseq_1101121_traj AS
$BODY$
DECLARE
	rect				alias for $1;

	cond_cell			text;
	sql				text;
	
	r				mpseq_1101121_traj%rowtype;
BEGIN
	cond_cell := getCondition_cells_v2(geometry(rect));

	raise notice '%', cond_cell;

	sql := 'select * from mpseq_1101121_traj where (' || cond_cell || ');';
	-- raise notice '%', sql;
	
	FOR r IN execute sql using rect LOOP				
		return next r;
	END LOOP;		
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.getquery_condition_cells(box2d)
  OWNER TO postgres;
