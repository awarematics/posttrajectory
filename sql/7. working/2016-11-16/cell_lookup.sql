-- select cell_lookup(geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745))));
-- select count(*) from cell_lookup(geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745))));


DROP FUNCTION cell_lookup(box2d);

CREATE OR REPLACE FUNCTION public.cell_lookup(box2d)
  RETURNS setof integer AS
$$
DECLARE
	rect		alias for $1;

	tmp_conf	varchar;
	tmp_box		box2d;
	
	cell_id		integer;
	
	sql		varchar;
BEGIN
	FOR i IN 1..100 LOOP
		sql := 'ptraj.cell_' || i;
		
		tmp_conf := current_setting(sql);

		tmp_box := ST_MakeBox2D(ST_PointFromText(split_part(tmp_conf, ',',1)), ST_PointFromText(split_part(tmp_conf, ',',2)));
		-- raise notice '%', tmp_box;

		IF (ST_intersects(rect, tmp_box)) THEN
			cell_id := i;
			-- raise notice '%', cell_id;
			return next cell_id;
		END IF;
	END LOOP;
END
$$
LANGUAGE plpgsql IMMUTABLE
  COST 100;

