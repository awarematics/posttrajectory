
--  FUNCTION Post_TJ_pass(trajectory, geometry)

DROP FUNCTION Post_TJ_pass(trajectory, geometry);

CREATE OR REPLACE FUNCTION Post_TJ_pass(trajectory, geometry) RETURNS boolean AS
$$
DECLARE
	input_trajectory		alias for $1;
	input_polygon			alias for $2;

	session_key 		text;
	session_value		text;
	
	traj_prefix			char(10);
	traj_suffix			char(10);
	traj_segtable_name	char(50);
	sql_text			char(100);
			
	cnt				integer;	
BEGIN		

	traj_prefix := 'mpseq_';
	traj_suffix := '_traj';
		
	traj_segtable_name := traj_prefix || input_trajectory.segtableoid || traj_suffix;
		
	session_key := traj_segtable_name;
	
	perform set_config(session_key, session_value, false);

	session_value := current_setting(session_key);
	
	if (session_value = null) then
		perform set_config(session_key, 1, false);
	else
		sql_text := ' select count(*) from ' || traj_segtable_name || ' mp where mp.mpid = ' || input_trajectory.moid || ' AND TJ_passes((mp).tpseg, $1)';
	
		EXECUTE sql_text INTO cnt USING input_polygon;

		IF cnt > 0 THEN
			RETURN true;
		ELSE
			RETURN false;
		END IF;
	end if;

END
$$
LANGUAGE 'plpgsql';

select taxi_id, taxi_number, traj, taxi_model from taxi 
 where Post_TJ_pass(taxi.traj, st_geomfromtext('polygon((116.44989 39.86646,116.44989 39.87334,118.47135 39.87334,118.47135 39.86646,116.44989 39.86646))'));

