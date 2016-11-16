-- Function: public.ptraj_createsetior_index_EXP()

-- DROP FUNCTION public.ptraj_createsetior_index_EXP();

select ptraj_createsetior_index_EXP();

CREATE OR REPLACE FUNCTION public.ptraj_createsetior_index_EXP()
  RETURNS void AS
$BODY$
DECLARE
	f_trajectory_segtable_name	char(200);

	sql				text;
	
	cnt_partition			integer;
	i				integer;
BEGIN
	f_trajectory_segtable_name := 'mpseq_seti_traj_v100k';

	sql := 'SELECT COUNT(*) FROM static_partition_conf';
	EXECUTE sql INTO cnt_partition;

	FOR i IN 1..cnt_partition LOOP
		sql := 'CREATE INDEX gist_SETIOR_v100k_idx' || i || ' ON ' || f_trajectory_segtable_name;
		sql := sql || ' USING gist(ST_MakeLine(ST_MakePoint(toDouble(start_time), 0.0), ST_MakePoint(toDouble(end_time), 0.0))) WHERE cellid(rect) = ' || i;
		RAISE notice '%', sql;
		EXECUTE sql;
	END LOOP;

	f_trajectory_segtable_name := 'mpseq_seti_traj_v300k';

	sql := 'SELECT COUNT(*) FROM static_partition_conf';
	EXECUTE sql INTO cnt_partition;

	FOR i IN 1..cnt_partition LOOP
		sql := 'CREATE INDEX gist_SETIOR_v300k_idx' || i || ' ON ' || f_trajectory_segtable_name;
		sql := sql || ' USING gist(ST_MakeLine(ST_MakePoint(toDouble(start_time), 0.0), ST_MakePoint(toDouble(end_time), 0.0))) WHERE cellid(rect) = ' || i;
		RAISE notice '%', sql;
		EXECUTE sql;
	END LOOP;

	f_trajectory_segtable_name := 'mpseq_seti_traj_v500k';

	sql := 'SELECT COUNT(*) FROM static_partition_conf';
	EXECUTE sql INTO cnt_partition;

	FOR i IN 1..cnt_partition LOOP
		sql := 'CREATE INDEX gist_SETIOR_v500k_idx' || i || ' ON ' || f_trajectory_segtable_name;
		sql := sql || ' USING gist(ST_MakeLine(ST_MakePoint(toDouble(start_time), 0.0), ST_MakePoint(toDouble(end_time), 0.0))) WHERE cellid(rect) = ' || i;
		RAISE notice '%', sql;
		EXECUTE sql;
	END LOOP;

	f_trajectory_segtable_name := 'mpseq_seti_traj_v700k';

	sql := 'SELECT COUNT(*) FROM static_partition_conf';
	EXECUTE sql INTO cnt_partition;

	FOR i IN 1..cnt_partition LOOP
		sql := 'CREATE INDEX gist_SETIOR_v700k_idx' || i || ' ON ' || f_trajectory_segtable_name;
		sql := sql || ' USING gist(ST_MakeLine(ST_MakePoint(toDouble(start_time), 0.0), ST_MakePoint(toDouble(end_time), 0.0))) WHERE cellid(rect) = ' || i;
		RAISE notice '%', sql;
		EXECUTE sql;
	END LOOP;

	f_trajectory_segtable_name := 'mpseq_seti_traj_v900k';

	sql := 'SELECT COUNT(*) FROM static_partition_conf';
	EXECUTE sql INTO cnt_partition;

	FOR i IN 1..cnt_partition LOOP
		sql := 'CREATE INDEX gist_SETIOR_v900k_idx' || i || ' ON ' || f_trajectory_segtable_name;
		sql := sql || ' USING gist(ST_MakeLine(ST_MakePoint(toDouble(start_time), 0.0), ST_MakePoint(toDouble(end_time), 0.0))) WHERE cellid(rect) = ' || i;
		RAISE notice '%', sql;
		EXECUTE sql;
	END LOOP;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
