

--- 테스트용 데이터

create table taxi_ex1_100k(
	taxi_id integer,
	taxi_number varchar,
	taxi_model varchar,
	taxi_driver varchar
);

-- 컬럼 추가
select addtrajectorycolumn('public', 'taxi_ex1_100k', 'traj', 4326, 'MOVINGPOINT', 2, 150);


--- 테스트용 데이터

create table taxi_ex1_300k(
	taxi_id integer,
	taxi_number varchar,
	taxi_model varchar,
	taxi_driver varchar
);

-- 컬럼 추가
select addtrajectorycolumn('public', 'taxi_ex1_300k', 'traj', 4326, 'MOVINGPOINT', 2, 150);


--- 테스트용 데이터

create table taxi_ex1_500k(
	taxi_id integer,
	taxi_number varchar,
	taxi_model varchar,
	taxi_driver varchar
);

-- 컬럼 추가
select addtrajectorycolumn('public', 'taxi_ex1_500k', 'traj', 4326, 'MOVINGPOINT', 2, 150);



--- 테스트용 데이터

create table taxi_ex1_700k(
	taxi_id integer,
	taxi_number varchar,
	taxi_model varchar,
	taxi_driver varchar
);

-- 컬럼 추가
select addtrajectorycolumn('public', 'taxi_ex1_700k', 'traj', 4326, 'MOVINGPOINT', 2, 150);



--- 테스트용 데이터

create table taxi_ex1_900k(
	taxi_id integer,
	taxi_number varchar,
	taxi_model varchar,
	taxi_driver varchar
);

-- 컬럼 추가
select addtrajectorycolumn('public', 'taxi_ex1_900k', 'traj', 4326, 'MOVINGPOINT', 2, 150);



select insert_taxi_data_count('t_drive_data','taxi_ex1_100k',2100);
select insert_taxi_data_count('t_drive_data','taxi_ex1_300k',2100);
select insert_taxi_data_count('t_drive_data','taxi_ex1_500k',2100);
select insert_taxi_data_count('t_drive_data','taxi_ex1_700k',2100);
select insert_taxi_data_count('t_drive_data','taxi_ex1_900k',2100);