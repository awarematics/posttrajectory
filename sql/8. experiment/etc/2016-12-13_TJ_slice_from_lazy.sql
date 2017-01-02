

-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : TJ_slice_from_seg_v3(trajectory, geometry, periods)
-- PARAMETER : trajectory, geometry, periods
-- RETURNS : tpoint[]
-- CREATED BY YOO KI HYUN

-- START TJ_slice_from_seg_v3:

DROP FUNCTION IF EXISTS TJ_slice_from_seg_v3(trajectory, geometry, periods);

CREATE OR REPLACE FUNCTION TJ_slice_from_seg_v3(trajectory, geometry, periods) RETURNS tpoint[] AS
$$
DECLARE
	input_trajectory		alias for $1;
	input_polygon			alias for $2;
	input_period			alias for $3;

	session_id			varchar;
	session_key 			varchar;
	session_value			varchar;
		
	traj_prefix			char(10);
	traj_suffix			char(10);
	
	traj_segtable_name		varchar;
	tmp_table_id			varchar;
	tmp_table_seg			varchar;
	
	sql_text			varchar;
	text_from_geom			varchar;

	cnt				integer;	
	result				tpoint[];
BEGIN		
	traj_prefix := current_setting('traj.prefix');
	traj_suffix := current_setting('traj.suffix');
		
	traj_segtable_name := traj_prefix || input_trajectory.segtableoid || traj_suffix;
	
	text_from_geom := box2d(input_polygon);

	session_key := traj_segtable_name || '.passes.' || text_from_geom;

	-- raise notice 'session_key : %', session_key;		
	
	BEGIN
		session_value := current_setting(session_key);
	EXCEPTION when undefined_object then
		perform set_config(session_key, '0', false);	     
		session_value := current_setting(session_key);
	END;	

	tmp_table_id := 'tmp_' || traj_segtable_name;
	tmp_table_seg := 'tmp_' || traj_segtable_name || '_Seg';
	
	IF session_value = '0' THEN
		

		raise notice 'No Temp';

		sql_text := 'SELECT mp.tpseg FROM ' || traj_segtable_name || ' mp';
		sql_text := sql_text || ' WHERE mp.mpid = ' || input_trajectory.moid;
		sql_text := sql_text || ' AND rect && $1';
		sql_text := sql_text || ' AND tp_overlaps(periods(start_time, end_time), periods($2, $3))';
				
		EXECUTE sql_text USING input_polygon, input_period.starttime, input_period.endtime INTO result;

		return result;
	ELSIF session_value <> '0' THEN

		raise notice 'is Temp';

		sql_text := 'select count(*) from pg_tables where tablename = $1';
		EXECUTE sql_text USING quote_ident(tmp_table_seg) INTO cnt;
		raise notice '%', cnt;
		
		IF cnt = 0 THEN
			sql_text := 'CREATE TEMPORARY TABLE ' || tmp_table_seg || ' as ';
			sql_text := sql_text || 'SELECT mp.mpid, mp.rect, mp.start_time, mp.end_time, mp.tpseg FROM ' || traj_segtable_name || ' mp';
			sql_text := sql_text || ' WHERE make_3dpolygon(mp.rect, mp.start_time, mp.end_time) &&& make_3dpolygon($1, $2, $3)';
			
			EXECUTE sql_text USING input_polygon, input_period.starttime, input_period.endtime;		
		END IF;	
		
		sql_text := 'SELECT mp.tpseg FROM ' || tmp_table_seg || ' mp';				
		sql_text := sql_text || ' WHERE mp.mpid = ' || input_trajectory.moid;
					
		EXECUTE sql_text USING input_polygon, input_period.starttime, input_period.endtime INTO result;

		return result;
	END IF;		

	return result;	
	
END
$$
LANGUAGE 'plpgsql';

-- END TJ_slice_from_seg_v3:
------------------------------------------------------------------------------------------

select * from mpseq_1816916_traj where mpid=18685 and segid=1;

select (tpseg[1]).pnt from mpseq_1816916_traj where mpid=18685 and segid=1;

select periods(timestamp '2008-02-02 13:37:43', timestamp '2008-02-03 03:18:32');

select array_length(TJ_atPeriods(tpseg, periods(timestamp '2008-02-02 13:50:43', timestamp '2008-02-03 03:18:32')), 1) from mpseq_1816916_traj where mpid=18685 and segid=1;

select (TJ_atPeriods(tpseg, periods(timestamp '2008-02-02 13:38:43', timestamp '2008-02-03 03:18:32')))[1].ts from mpseq_1816916_traj where mpid=18685 and segid=1;


select st_astext((TJ_atPeriods(tpseg, periods(timestamp '2008-02-02 13:37:43', timestamp '2008-02-03 03:18:32'))).ts) from mpseq_1816916_traj where mpid=18685 and segid=1;
