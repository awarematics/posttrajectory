﻿/*
  Function : cellid(box2d)
  Input : box2d
  Output : integer

*/

CREATE OR REPLACE FUNCTION cellid(box2d) RETURNS INTEGER AS
$$
DECLARE
	rect		alias for $1;
	
	part_id		integer;
	
	sql		varchar;
BEGIN
	sql := 'SELECT id FROM static_partition WHERE ST_CoveredBy(partition, $1);';

	EXECUTE sql INTO part_id USING rect;
	
	RETURN part_id;
END
$$
LANGUAGE 'plpgsql' IMMUTABLE;


select cellid(rect) from mpseq_1074501_traj where mpid=1 and segid=1;

SELECT id FROM static_partition WHERE ST_INTERSECTS(partition, st_makebox2d(st_point(116.355506896973, 39.8445587158203), st_point(116.424026489258, 39.907112121582)));

"BOX(116.355506896973 39.8445587158203,116.424026489258 39.907112121582)"

SELECT static_partition.partition FROM static_partition, mpseq_1074501_traj
 WHERE mpseq_1074501_traj.mpid=1 and mpseq_1074501_traj.segid=1 and ST_Covers(mpseq_1074501_traj.rect, static_partition.partition);

 SELECT static_partition.partition FROM static_partition, mpseq_1074501_traj
 WHERE mpseq_1074501_traj.mpid=1 and mpseq_1074501_traj.segid=1 and ST_INTERSECTS(mpseq_1074501_traj.rect, static_partition.partition);

 "BOX(116.432512 39.8107681274414,116.545285 39.932358)"

 "BOX(116.432512 39.846651,116.545285 39.932358)"
