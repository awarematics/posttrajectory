


CREATE OR REPLACE FUNCTION insert_seti_data_all(varchar, varchar, integer) RETURNS integer AS
$BODY$
DECLARE
	src_tb				alias for $1;
	taxi_tb				alias for $2;
	max_count			alias for $3;

	taxi_cnt			integer;
	licenseplate			varchar;
	
	meta_data_sql			varchar;
	taxi_data_sql			varchar;
	insert_sql			varchar;
	traj_sql			varchar;
	traj_data_sql			varchar;
	traj_data_cnt_sql		varchar;

	temp_partition_equal		boolean;
	temp_meta_data			record;
	temp_traj			record;
	temp_traj_data			record;

	traj_data_cnt			integer;
	temp_traj_data_cnt		integer;

	traj_prefix			char(50);
	traj_suffix			char(50);
	
	f_trajectory_segtable_name	char(200);
	table_oid			char(100);
	mpid				integer;
	segid				integer;
	mp_count			integer;
	rect				box2d;
	start_time			timestamp without time zone;
	end_time			timestamp without time zone;

	tp				tpoint;
	tp_arr				tpoint[];

	idx				integer;
BEGIN
	traj_prefix := current_setting('traj.prefix');
	traj_suffix := current_setting('traj.suffix');

	--meta_data_sql := 'select tpseg_size from trajectory_columns where f_trajectory_segtable_name = ' || quote_literal(f_trajectory_segtable_name);
	--EXECUTE meta_data_sql INTO temp_meta_data;

	taxi_data_sql := 'select taxi_number from ' || taxi_tb || ' order by taxi_id;';

	traj_sql := 'select (traj).segtableoid as table_oid, (traj).moid as mpid from ' || taxi_tb || ' where taxi_number = $1;';

	traj_data_sql := 'select moid, lat, lon, ts from ' || src_tb || ' where licenseplate = $1 order by moid;';

	taxi_cnt := insert_taxi_data_all(src_tb, taxi_tb);
	idx := 1;
	
	temp_partition_equal := true;
	
	for licenseplate in execute taxi_data_sql loop
		raise notice 'T : %/%, ID : %', idx, taxi_cnt, licenseplate;
		idx := idx + 1;
		
		execute traj_sql using licenseplate into temp_traj;
		-- raise notice '%, %', temp_traj.table_oid, temp_traj.mpid;
		
		f_trajectory_segtable_name := traj_prefix || temp_traj.table_oid || traj_suffix;
		-- raise notice '%', f_trajectory_segtable_name;

		mpid := temp_traj.mpid;
		segid := 1;
		mp_count := 0;
		tp_arr := null;
		
		traj_data_cnt_sql := 'select count(*) from ' || src_tb || ' where licenseplate = $1;';
		execute traj_data_cnt_sql using licenseplate into traj_data_cnt;
		
		temp_traj_data_cnt := 0;
		--raise notice 'traj_data_cnt : %', traj_data_cnt;
		
		for temp_traj_data in execute traj_data_sql using licenseplate loop
			-- raise notice '%', temp_traj_data.moid;
			
			temp_traj_data_cnt := temp_traj_data_cnt + 1;
			
			if (max_count >= mp_count) then
				mp_count := mp_count + 1;
				
				tp := tpoint(ST_POINT(temp_traj_data.lat, temp_traj_data.lon), temp_traj_data.ts);

				if (mp_count = 1) then
					tp_arr := array[tp];
					rect := getBox2dFromConf(ST_POINT(temp_traj_data.lat, temp_traj_data.lon));
				elsif (mp_count > 1) then
					tp_arr := tp_arr || tp;

					if (not st_equals(rect, getBox2dFromConf(ST_POINT(temp_traj_data.lat, temp_traj_data.lon)))) then
						temp_partition_equal := false;
						raise notice '%', cellid(getBox2dFromConf(ST_POINT(temp_traj_data.lat, temp_traj_data.lon)));
					else
						temp_partition_equal := true;
					end if;
				end if;
				
				
			end if;
			--raise notice '%', tp;
			--raise notice '%', tp_arr;
			--raise notice 'temp_traj_data_cnt : %', temp_traj_data_cnt;
			if (max_count = mp_count) OR (traj_data_cnt = temp_traj_data_cnt) then

				start_time := tp_arr[1].ts;
				end_time := tp_arr[array_length(tp_arr, 1)].ts;
				insert_sql := 'insert into ' || f_trajectory_segtable_name || ' values($1, $2, $3, $4, $5, $6, $7, $8, $9);';

				execute insert_sql using mpid, segid, (segid+1), (segid-1), mp_count, rect, start_time, end_time, tp_arr;
				rect := getBox2dFromConf(ST_POINT(temp_traj_data.lat, temp_traj_data.lon));
				segid := segid + 1;
				mp_count := 0;
			end if;

			if (not temp_partition_equal) then
				-- raise notice 'split part';

				start_time := tp_arr[1].ts;
				end_time := tp_arr[array_length(tp_arr, 1)].ts;
				insert_sql := 'insert into ' || f_trajectory_segtable_name || ' values($1, $2, $3, $4, $5, $6, $7, $8, $9);';

				execute insert_sql using mpid, segid, (segid+1), (segid-1), mp_count, rect, start_time, end_time, tp_arr;
				segid := segid + 1;
				mp_count := 2;
				rect := getBox2dFromConf(ST_POINT(temp_traj_data.lat, temp_traj_data.lon));
				tp_arr := array[tp_arr[array_length(tp_arr, 1)-1]] || array[tp];
			end if;
		end loop;
	end loop;
	
	return 1000;
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE STRICT
COST 100;

select insert_seti_data_all('t_drive_data', 'taxi', 150);



delete from taxi;

delete from mpseq_2616944_traj;

select max(taxi_id) from taxi;

select traj from taxi;