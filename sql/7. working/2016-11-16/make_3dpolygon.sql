-- drop function make_3dpolygon(tpoint[]);

CREATE OR REPLACE FUNCTION make_3dpolygon(tpoint[]) RETURNS geometry AS
$BODY$
DECLARE
	input_tpArr	alias for $1;
	
	max_size	integer;
	now_count	integer;

	geom_prefix	text;	
	geom_suffix	text;
	geom_temp	text;
	
	ouput_tpArr	geometry;

BEGIN
	execute 'select array_upper($1, 1)'
	into max_size using input_tpArr;

	geom_prefix := 'LINESTRINGM(';
	geom_suffix := '';
	now_count := 1;
	while max_size >= now_count loop
		-- ouput_tpArr[now_count] := input_tpArr[now_count];
		geom_suffix := geom_suffix || st_x(input_tpArr[now_count].pnt) || ' ' || st_y(input_tpArr[now_count].pnt) || ' ' || todouble(input_tpArr[now_count].ts);

		if now_count = 1 then 
			geom_temp := st_x(input_tpArr[now_count].pnt) || ' ' || st_y(input_tpArr[now_count].pnt) || ' ' || todouble(input_tpArr[now_count].ts);
		end if;
		
		now_count := now_count + 1;		
		
		if now_count <= max_size then
			geom_suffix := geom_suffix || ', ';
		else 
			geom_suffix := geom_suffix || ', ' || geom_temp;
		end if;
		
	end loop;
	geom_prefix := 'LINESTRINGM(' || geom_suffix || ')';

	-- raise notice '%', geom_suffix;
	-- raise notice '%', st_astext(ST_MakePolygon(ST_GeomFromText(geom_prefix)));

	ouput_tpArr := ST_MakePolygon(ST_GeomFromText(geom_prefix));
	return ouput_tpArr;
END;
$BODY$
LANGUAGE 'plpgsql';

select st_astext(make_3dpolygon(tpseg)) from mpseq_1844528_traj where mpid=1 and segid=1;