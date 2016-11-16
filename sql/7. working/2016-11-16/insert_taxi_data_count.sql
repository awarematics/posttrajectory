
select insert_taxi_data_count('t_drive_data','taxi_ex1_100k',2100);
select insert_taxi_data_count('t_drive_data','taxi_ex1_300k',2100);
select insert_taxi_data_count('t_drive_data','taxi_ex1_500k',2100);
select insert_taxi_data_count('t_drive_data','taxi_ex1_700k',2100);
select insert_taxi_data_count('t_drive_data','taxi_ex1_900k',2100);

CREATE OR REPLACE FUNCTION insert_taxi_data_count(varchar, varchar, integer) RETURNS integer AS
$BODY$
DECLARE
	src_tb				alias for $1;
	taxi_tb				alias for $2;
	taxiData_count			alias for $3;
	
	taxi_cnt			integer;
	temp_cnt			integer;
	licenseplate			varchar;
	
	sql				varchar;
	duplicateChk_sql		varchar;
	insert_sql			varchar;

	
BEGIN

	sql := 'select max(taxi_id) from ' || taxi_tb;

	execute sql into taxi_cnt;
	-- raise notice '%', taxi_cnt;

	if (taxi_cnt is null) then
		taxi_cnt := 0;
	end if;

	sql := 'select licenseplate from ' || src_tb || ' group by licenseplate having count(licenseplate) > $1 order by licenseplate;';
	-- sql := 'select licenseplate from ' || src_tb || ' group by licenseplate order by licenseplate;';

	duplicateChk_sql := 'select count(*) from ' || taxi_tb || ' where taxi_number = $1;';
	
	insert_sql := 'insert into ' || taxi_tb || ' values($1, $2, $2, $2)';

	for licenseplate in execute sql using taxiData_count loop

		execute duplicateChk_sql using licenseplate into temp_cnt;

		if (temp_cnt < 1) then
			-- 중복된게 없을 때,
			taxi_cnt := taxi_cnt + 1;
			execute insert_sql using taxi_cnt, licenseplate;
		else
			-- 중복된게 있을 때,
		end if;
	end loop;
	
	return taxi_cnt;
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE STRICT
COST 100;

select insert_taxi_data_all('t_drive_data');

select insert_seti_data_all('t_drive_data', 100);



delete from taxi;

delete from mpseq_2613426_traj;

select max(taxi_id) from taxi;

select traj from taxi;