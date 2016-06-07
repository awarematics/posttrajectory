
--  FUNCTION Post_Traj_passes_base(trajectory, geometry)

DROP FUNCTION Post_Traj_passes_base(trajectory, geometry);

CREATE OR REPLACE FUNCTION Post_Traj_passes_base(trajectory, geometry) RETURNS boolean AS
$$
DECLARE
	input_trajectory		alias for $1;
	input_polygon			alias for $2;

	traj_prefix			char(10);
	traj_suffix			char(10);
	
	traj_segtable_name		char(50);
	
	sql_text			text;
				
	cnt				integer;	
BEGIN		

	traj_prefix := current_setting('traj.prefix');
	traj_suffix := current_setting('traj.suffix');
		
	traj_segtable_name := traj_prefix || input_trajectory.segtableoid || traj_suffix;

	-- sql_text := 'SELECT COUNT(*) FROM ' || traj_segtable_name || ' mp WHERE mp.mpid = ' || input_trajectory.moid || ' AND TJ_Passes((mp).tpseg, $1) AND mpcount = 150';

	sql_text := 'SELECT COUNT(*) FROM ' || traj_segtable_name || ' mp WHERE mp.mpid = ' || input_trajectory.moid || ' AND TJ_Passes((mp).tpseg, $1)';
	
	EXECUTE sql_text INTO cnt USING input_polygon;

	IF cnt > 0 THEN
		RETURN true;
	ELSE
		RETURN false;
	END IF;
	
END
$$
LANGUAGE 'plpgsql';

