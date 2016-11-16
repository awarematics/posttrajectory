
-- select getCondition_cells_v2(geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(110.7366413, 25.77352625))));

CREATE OR REPLACE FUNCTION getCondition_cells_v2(box2d) RETURNS text AS
$$
DECLARE
	rect				alias for $1;

	cell_cnt			integer;
	current_cnt			integer;
	
	cell_id				integer;
	
	sql				text;
	return_txt			text;
	
BEGIN
	return_txt := '';
	sql := 'select count(*) from cell_lookup($1)';

	EXECUTE sql INTO cell_cnt USING rect;

	current_cnt := 0;
	
	sql := 'select cell_lookup($1)';
	FOR cell_id IN EXECUTE sql USING rect LOOP		
		return_txt := return_txt || 'cellid(rect) = ' || cell_id;	
		current_cnt := current_cnt + 1;

		if (current_cnt < cell_cnt) then
			return_txt := return_txt || ' OR ';
		end if;
	END LOOP;

	RETURN return_txt;
END
$$
LANGUAGE 'plpgsql';