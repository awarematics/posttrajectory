

﻿﻿/*
  Function : cellid_from_tb(box2d)
  Input : box2d
  Output : integer
*/


CREATE OR REPLACE FUNCTION cellid_from_tb(box2d) RETURNS INTEGER AS
$$
DECLARE
	rect		alias for $1;
	
	part_id		integer;
	
	sql		varchar;
BEGIN
	sql := 'SELECT id FROM static_partition WHERE ST_EQUALS(partition, $1);';

	EXECUTE sql INTO part_id USING rect;
	
	RETURN part_id;
END
$$
LANGUAGE 'plpgsql' IMMUTABLE;

"BOX(117.589875 41.21432,119.417404 43.501845)"

SELECT id FROM static_partition WHERE ST_EQUALS(partition,st_makebox2d(st_point(117.589875, 41.21432), st_point(117.589875, 43.501845)));

select cellid_from_tb(rect) from mpseq_1752934_traj where mpid=10337 and segid=3;

select cellid(rect) from mpseq_1752934_traj where mpid=10337 and segid=1;

SELECT id FROM static_partition WHERE ST_INTERSECTS(partition, st_makebox2d(st_point(116.355506896973, 39.8445587158203), st_point(116.424026489258, 39.907112121582)));

"BOX(116.355506896973 39.8445587158203,116.424026489258 39.907112121582)"

SELECT id, static_partition.partition FROM static_partition, mpseq_1078133_traj
 WHERE mpseq_1078133_traj.mpid=1 and mpseq_1078133_traj.segid=1 and ST_equals(mpseq_1078133_traj.rect, static_partition.partition);

 SELECT static_partition.partition FROM static_partition, mpseq_1074501_traj
 WHERE mpseq_1074501_traj.mpid=1 and mpseq_1074501_traj.segid=1 and ST_INTERSECTS(mpseq_1074501_traj.rect, static_partition.partition);
