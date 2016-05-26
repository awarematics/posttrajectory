CREATE OR REPLACE FUNCTION Post_TJ_pass(trajectory, geometry) RETURNS boolean AS
$$
DECLARE
	input_trajectory		alias for $1;
	input_polygon			alias for $2;

	session_key 		text;
	session_value		text;
	
	traj_prefix			char(10);
	traj_suffix			char(10);
	
	traj_segtable_name	text;
	
	sql_text			varchar;
	text_from_geom		text;
		
	cnt				integer;	
BEGIN		

	traj_prefix := 'mpseq_';
	traj_suffix := '_traj';
		
	traj_segtable_name := traj_prefix || input_trajectory.segtableoid || traj_suffix;
		
	sql_text := 'select box2d($1)';

	EXECUTE sql_text INTO text_from_geom USING input_polygon;

	session_key := traj_segtable_name || '.pass.' || text_from_geom;

	BEGIN
		session_value := current_setting(session_key);
	EXCEPTION when undefined_object then
		perform set_config(session_key, '0', false);	     
		session_value := current_setting(session_key);
	END;
		
	IF session_value = '0' THEN
		perform set_config(session_key, '1', false);

		IF EXISTS (SELECT relname FROM pg_class WHERE relname='tmp_segtable') THEN
			sql_text := 'SELECT mp.mpid FROM ' || traj_segtable_name || ' mp';
			sql_text := sql_text || ' WHERE mp.rect && $1';
			--raise notice '%', sql_text;
		ELSE		
			sql_text := 'CREATE TEMPORARY TABLE tmp_segtable as ';
			sql_text := sql_text || 'SELECT mp.mpid FROM ' || traj_segtable_name || ' mp';
			sql_text := sql_text || ' WHERE mp.rect && $1';
			--raise notice '%', sql_text;
		END IF;	
	END IF;
			
	EXECUTE sql_text USING input_polygon;

	sql_text := 'SELECT COUNT(*) FROM tmp_segtable tmp WHERE tmp.mpid = ' || input_trajectory.moid;

	raise notice '%', sql_text;
	EXECUTE sql_text INTO cnt;

	IF cnt > 0 THEN
		RETURN true;
	ELSE
		RETURN false;
	END IF;	
END
$$
LANGUAGE 'plpgsql';