

CREATE OR REPLACE FUNCTION Post_Traj_passes_id(trajectory, geometry) RETURNS boolean AS
$$
DECLARE
	input_trajectory		alias for $1;
	input_polygon			alias for $2;

	session_id			text;
	session_key 			text;
	session_value			text;
		
	traj_prefix			char(10);
	traj_suffix			char(10);
	
	traj_segtable_name		text;
	
	sql_text			varchar;
	text_from_geom			text;
		
	cnt				integer;	
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
	
	IF session_value = '0' THEN
		perform set_config(session_key, '1', false);

		sql_text := 'CREATE TEMPORARY TABLE tmp_segtable as ';
		sql_text := sql_text || 'SELECT mp.mpid FROM ' || traj_segtable_name || ' mp';
		sql_text := sql_text || ' WHERE mp.rect && $1 AND TT_Passes(mp.tpseg, $1)';
		-- raise notice '%', sql_text;		

		EXECUTE sql_text USING input_polygon;
	END IF;

	sql_text := 'SELECT COUNT(*) FROM tmp_segtable tmp WHERE tmp.mpid = ' || input_trajectory.moid;
	
	EXECUTE sql_text INTO cnt;

	IF cnt > 0 THEN
		RETURN true;
	ELSE
		RETURN false;
	END IF;	
END
$$
LANGUAGE 'plpgsql';



