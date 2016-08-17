
/*
	Merge box2d from geometry value 
*/
CREATE OR REPLACE FUNCTION ptraj_mergeBox2d(geometry) RETURNS box2d AS
$$
DECLARE
	geom		alias for $1;

	minX		float;
	minY		float;
	maxX		float;
	maxY		float;

	g_minX		float;
	g_minY		float;
	g_maxX		float;
	g_maxY		float;
	
	total_box	box2d;
BEGIN
	total_box := geom;
	
	minX := st_xmin(total_box);
	minY := st_ymin(total_box);
	maxX := st_xmax(total_box);
	maxY := st_ymax(total_box);
	
	g_minX = cast(current_setting('traj.xmin') as double precision);
	g_minY = cast(current_setting('traj.ymin') as double precision);
	g_maxX = cast(current_setting('traj.xmax') as double precision);
	g_maxY = cast(current_setting('traj.ymax') as double precision);

	-- raise notice '%, %, %, %', g_minX, g_minY, g_maxX, g_maxY;
	
	if (g_minX = 0.0 and g_minY = 0.0 and g_maxX = 0.0 and g_maxY = 0.0) then
		g_minX := minX;
		g_minY := minY;
		g_maxX := maxX;
		g_maxY := maxY;
	end if;

	if (minX <= g_minX) then		
		EXECUTE 'select set_config(' || quote_literal('traj.xmin') || ', ' || quote_literal(minX) || ', true)';	
		g_minX := minX;
	end if;
	if (minY <= g_minY) then
		EXECUTE 'select set_config(' || quote_literal('traj.ymin') || ', ' || quote_literal(minY) || ', true)';			
		g_minY := minY;
	end if;
	if (maxX >= g_maxX) then
		EXECUTE 'select set_config(' || quote_literal('traj.xmax') || ', ' || quote_literal(maxX) || ', true)';			
		g_maxX := maxX;
	end if;
	if (maxY >= g_maxY) then
		EXECUTE 'select set_config(' || quote_literal('traj.ymax') || ', ' || quote_literal(maxY) || ', true)';			
		g_maxY := maxY;
	end if;
	
	/*
	g_minX = cast(current_setting('traj.xmin') as double precision);
	g_minY = cast(current_setting('traj.ymin') as double precision);
	g_maxX = cast(current_setting('traj.xmax') as double precision);
	g_maxY = cast(current_setting('traj.ymax') as double precision);

	raise notice '%, %, %, %', g_minX, g_minY, g_maxX, g_maxY;
	*/
	
	total_box := ST_MakeBox2D(ST_Point(g_minX, g_minY), ST_Point(g_maxX ,g_maxY));
	
	RETURN total_box;
END
$$
LANGUAGE 'plpgsql';
