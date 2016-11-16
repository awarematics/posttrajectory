﻿/*
  Function : getBox2dFromConf(geometry)
  Input : geometry
  Output : box2d

*/

-- Function: public.getBox2dFromConf(geometry)

-- DROP FUNCTION public.getBox2dFromConf(geometry);

CREATE OR REPLACE FUNCTION public.getBox2dFromConf(geometry)
  RETURNS box2d AS
$BODY$
DECLARE
	geom		alias for $1;

	tmp_conf	varchar;
	tmp_box		box2d;
	
	cell_id		integer;
	
	sql		varchar;
	
	result_box	box2d;
BEGIN
	

	FOR i IN 1..100 LOOP
		sql := 'ptraj.cell_' || i;
		
		tmp_conf := current_setting(sql);

		tmp_box := ST_MakeBox2D(ST_PointFromText(split_part(tmp_conf, ',',1)), ST_PointFromText(split_part(tmp_conf, ',',2)));
		-- raise notice '%', tmp_box;

		IF (ST_Intersects(tmp_box, geom)) THEN
			return tmp_box;
			-- raise notice '%', tmp_box;
		END IF;
	END LOOP;
	
	RETURN cell_id;
END
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;



select getBox2dFromConf(ST_POINT(116.41843, 39.97084));
