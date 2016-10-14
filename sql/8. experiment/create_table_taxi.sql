

--- 테스트용 데이터

create table taxi(
	taxi_id integer,
	taxi_number varchar,
	taxi_model varchar,
	taxi_driver varchar
);

-- 컬럼 추가
select addtrajectorycolumn('public', 'taxi', 'traj', 4326, 'MOVINGPOINT', 2, 150);


--- 테스트용 데이터

create table taxi2(
	taxi_id integer,
	taxi_number varchar,
	taxi_model varchar,
	taxi_driver varchar
);

-- 컬럼 추가
select addtrajectorycolumn('public', 'taxi2', 'traj', 4326, 'MOVINGPOINT', 2, 150);


--- 테스트용 데이터

create table taxi3(
	taxi_id integer,
	taxi_number varchar,
	taxi_model varchar,
	taxi_driver varchar
);

-- 컬럼 추가
select addtrajectorycolumn('public', 'taxi3', 'traj', 4326, 'MOVINGPOINT', 2, 150);
