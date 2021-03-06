
/*
*
*   For example : select ptraj_getPointArr(traj) from taxi where taxi_number = '100';
*
*/


-- Function: public.ptraj_getPointArr(trajectory)

-- DROP FUNCTION public.ptraj_getPointArr(trajectory);

CREATE OR REPLACE FUNCTION public.ptraj_getPointArr(trajectory)
  RETURNS SETOF text AS
$BODY$
DECLARE	
	c_trajectory 			alias for $1;
	
	traj_prefix			char(50);
	traj_suffix			char(50);

	f_trajectory_segtable_name	char(200);
	
	sql				text;
	
	data				record;
	tmp				record;
BEGIN
	traj_prefix := current_setting('traj.prefix');
	traj_suffix := current_setting('traj.suffix');
	
	f_trajectory_segtable_name := traj_prefix || c_trajectory.segtableoid || traj_suffix;

	sql := 'select tpseg from ' || quote_ident(f_trajectory_segtable_name) || ' WHERE mpid = '|| c_trajectory.moid || ' order by segid';

	-- raise notice '%', traj_prefix;
	FOR data IN EXECUTE sql LOOP
		FOR tmp IN EXECUTE 'select _getpointarr($1)' USING data.tpseg LOOP
			RETURN NEXT tmp;
		END LOOP;
	END LOOP;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.ptraj_getPointArr(trajectory)
  OWNER TO postgres;

  

-- Function: public._getPointArr(tpoint[])

-- DROP FUNCTION public._getPointArr(tpoint[]);

CREATE OR REPLACE FUNCTION public._getPointArr(tpoint[])
  RETURNS SETOF text AS
$BODY$
DECLARE
	tpseg	alias for $1;

	max_size	integer;
	now_count	integer;
	tmp		record;
	
	return_data	text;

BEGIN
	execute 'select array_upper($1, 1)'
	into max_size using tpseg;
	now_count := 1;
	while max_size >= now_count loop
		execute 'select st_x($1) as x, st_y($1) as y'
		into tmp using tpseg[now_count].pnt;

		return_data := tmp.x || ',' || tmp.y;
		
		now_count := now_count + 1;
		return next return_data;
	end loop;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public._getPointArr(tpoint[])
  OWNER TO postgres;
