﻿/*
  Function : cellid(box2d)
  Input : box2d
  Output : integer

*/

-- Function: public.cellid(box2d)

-- DROP FUNCTION public.cellid(box2d);

CREATE OR REPLACE FUNCTION public.cellid(box2d)
  RETURNS integer AS
$BODY$
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

		IF (ST_EQUALS(rect, tmp_box)) THEN
			cell_id := i;
			-- raise notice '%', tmp_box;
		END IF;
	END LOOP;
	
	RETURN cell_id;
END
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;
ALTER FUNCTION public.cellid(box2d)
  OWNER TO postgres;



select cellid(rect) from mpseq_1752934_traj where mpid=1 and segid=1;

SELECT id FROM static_partition WHERE ST_INTERSECTS(partition, st_makebox2d(st_point(116.355506896973, 39.8445587158203), st_point(116.424026489258, 39.907112121582)));

"BOX(116.355506896973 39.8445587158203,116.424026489258 39.907112121582)"

SELECT id, static_partition.partition FROM static_partition, mpseq_1078133_traj
 WHERE mpseq_1078133_traj.mpid=1 and mpseq_1078133_traj.segid=1 and ST_equals(mpseq_1078133_traj.rect, static_partition.partition);

 SELECT static_partition.partition FROM static_partition, mpseq_1074501_traj
 WHERE mpseq_1074501_traj.mpid=1 and mpseq_1074501_traj.segid=1 and ST_INTERSECTS(mpseq_1074501_traj.rect, static_partition.partition);

 "BOX(116.432512 39.8107681274414,116.545285 39.932358)"

 "BOX(116.432512 39.846651,116.545285 39.932358)"
