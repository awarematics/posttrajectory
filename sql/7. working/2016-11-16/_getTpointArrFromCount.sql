
/*
*
* select _getTpointArrFromCount(integer);
*
*/

select * from mpseq_17992_traj where mpid=2 limit 3;

select array_upper((_getTpointArrFromCount(tpseg, 30)), 1) from mpseq_247024_traj where mpid=2 order by segid limit 3;

select(_getTpointArrFromCount(tpseg, 200))[150] from mpseq_247024_traj where mpid=2 order by segid limit 3;

-- drop function _getTpointArrFromCount(integer);

CREATE OR REPLACE FUNCTION _getTpointArrFromCount(tpoint[], integer) RETURNS tpoint[] AS
$BODY$
DECLARE
	input_tpArr	alias for $1;
	input_cnt	alias for $2;

	max_size	integer;
	now_count	integer;
	
	ouput_tpArr	tpoint[];

BEGIN
	execute 'select array_upper($1, 1)'
	into max_size using input_tpArr;

	now_count := 1;
	while input_cnt >= now_count loop
		ouput_tpArr[now_count] := input_tpArr[now_count];
		now_count := now_count + 1;		
	end loop;

	return ouput_tpArr;
END;
$BODY$
LANGUAGE 'plpgsql';
