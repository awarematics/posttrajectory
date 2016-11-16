
-- select getCondition_cells(geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(110.7366413, 25.77352625))));

-- DROP FUNCTION getcondition_cells(box2d);

CREATE OR REPLACE FUNCTION getCondition_cells(box2d) RETURNS boolean AS
$$
DECLARE
	rect				alias for $1;

	cell_cnt			integer;
	current_cnt			integer;
	
	cell_id				integer;
	
	sql				text;
	return_bool			boolean;
BEGIN
	
	sql := 'select count(*) from cell_lookup($1)';

	EXECUTE sql INTO cell_cnt USING rect;

	if (cell_cnt > 0) then
		RETURN true;
	else
		RETURN false;
	end if;
END
$$
LANGUAGE 'plpgsql';