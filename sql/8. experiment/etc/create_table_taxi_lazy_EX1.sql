

--- 테스트용 데이터

create table taxi_lazy_ex1_300m(
	taxi_id integer,
	taxi_number varchar,
	taxi_model varchar,
	taxi_driver varchar
);

-- 컬럼 추가
select addtrajectorycolumn('public', 'taxi_lazy_ex1_300m', 'traj', 4326, 'MOVINGPOINT', 2, 150);


--- 테스트용 데이터

create table taxi_lazy_ex1_600m(
	taxi_id integer,
	taxi_number varchar,
	taxi_model varchar,
	taxi_driver varchar
);

-- 컬럼 추가
select addtrajectorycolumn('public', 'taxi_lazy_ex1_600m', 'traj', 4326, 'MOVINGPOINT', 2, 150);


--- 테스트용 데이터

create table taxi_lazy_ex1_900m(
	taxi_id integer,
	taxi_number varchar,
	taxi_model varchar,
	taxi_driver varchar
);

-- 컬럼 추가
select addtrajectorycolumn('public', 'taxi_lazy_ex1_900m', 'traj', 4326, 'MOVINGPOINT', 2, 150);



--- 테스트용 데이터

create table taxi_lazy_ex1_1200m(
	taxi_id integer,
	taxi_number varchar,
	taxi_model varchar,
	taxi_driver varchar
);

-- 컬럼 추가
select addtrajectorycolumn('public', 'taxi_lazy_ex1_1200m', 'traj', 4326, 'MOVINGPOINT', 2, 150);



--- 테스트용 데이터

create table taxi_lazy_ex1_1500m(
	taxi_id integer,
	taxi_number varchar,
	taxi_model varchar,
	taxi_driver varchar
);

-- 컬럼 추가
select addtrajectorycolumn('public', 'taxi_lazy_ex1_1500m', 'traj', 4326, 'MOVINGPOINT', 2, 150);



select insert_taxi_data_count('t_drive_data','taxi_lazy_ex1_300m',1000, 1600);
select insert_taxi_data_count('t_drive_data','taxi_lazy_ex1_600m',1000, 1730);
select insert_taxi_data_count('t_drive_data','taxi_lazy_ex1_900m',1000, 2500);
select insert_taxi_data_count('t_drive_data','taxi_lazy_ex1_1200m',1000, 10000);
select insert_taxi_data_count('t_drive_data','taxi_lazy_ex1_1500m',1000, 200000);