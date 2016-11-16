

--- 테스트용 데이터

create table taxi_ex2_200k(
	taxi_id integer,
	taxi_number varchar,
	taxi_model varchar,
	taxi_driver varchar
);

-- 컬럼 추가
select addtrajectorycolumn('public', 'taxi_ex2_200k', 'traj', 4326, 'MOVINGPOINT', 2, 150);


--- 테스트용 데이터

create table taxi_ex2_400k(
	taxi_id integer,
	taxi_number varchar,
	taxi_model varchar,
	taxi_driver varchar
);

-- 컬럼 추가
select addtrajectorycolumn('public', 'taxi_ex2_400k', 'traj', 4326, 'MOVINGPOINT', 2, 150);


--- 테스트용 데이터

create table taxi_ex2_600k(
	taxi_id integer,
	taxi_number varchar,
	taxi_model varchar,
	taxi_driver varchar
);

-- 컬럼 추가
select addtrajectorycolumn('public', 'taxi_ex2_600k', 'traj', 4326, 'MOVINGPOINT', 2, 150);



--- 테스트용 데이터

create table taxi_ex2_800k(
	taxi_id integer,
	taxi_number varchar,
	taxi_model varchar,
	taxi_driver varchar
);

-- 컬럼 추가
select addtrajectorycolumn('public', 'taxi_ex2_800k', 'traj', 4326, 'MOVINGPOINT', 2, 150);



--- 테스트용 데이터

create table taxi_ex2_1000k(
	taxi_id integer,
	taxi_number varchar,
	taxi_model varchar,
	taxi_driver varchar
);

-- 컬럼 추가
select addtrajectorycolumn('public', 'taxi_ex2_1000k', 'traj', 4326, 'MOVINGPOINT', 2, 150);


select insert_taxi_data_count('t_drive_data','taxi_ex2_200k',2100);
select insert_taxi_data_count('t_drive_data','taxi_ex2_400k',2100);
select insert_taxi_data_count('t_drive_data','taxi_ex2_600k',2100);
select insert_taxi_data_count('t_drive_data','taxi_ex2_800k',2100);
select insert_taxi_data_count('t_drive_data','taxi_ex2_1000k',2100);