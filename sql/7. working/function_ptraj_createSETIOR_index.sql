
-- select ptraj_createSETIOR_index();
﻿﻿

-- Function: public.ptraj_createSETIOR_index()

-- DROP FUNCTION public.ptraj_createSETIOR_index();

CREATE OR REPLACE FUNCTION public.ptraj_createSETIOR_index()
  RETURNS void AS
$$
DECLARE
	f_trajectory_segtable_name	char(200);

	sql				text;
	
	cnt_partition			integer;
	i				integer;
BEGIN
	sql := 'SELECT f_trajectory_segtable_name FROM trajectory_columns;';
	EXECUTE sql INTO f_trajectory_segtable_name;

	sql := 'SELECT COUNT(*) FROM static_partition_conf';
	EXECUTE sql INTO cnt_partition;

	FOR i IN 1..cnt_partition LOOP
		sql := 'CREATE INDEX gist_SETIOR_idx' || i || ' ON ' || f_trajectory_segtable_name;
		sql := sql || ' USING gist(ST_MakeLine(ST_MakePoint(toDouble(start_time), 0.0), ST_MakePoint(toDouble(end_time), 0.0))) WHERE cellid(rect) = ' || i;
		RAISE notice '%', sql;
		EXECUTE sql;
	END LOOP;

END
$$
  LANGUAGE plpgsql VOLATILE;
