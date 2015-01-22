PostTrajectory Project
==============




## Creation Trajectory Table

<pre>
create table taxi(
	taxi_id integer,
	taxi_number varchar,
	taxi_model varchar,
	taxi_driver varchar
);
</pre>

## Adding Trajectory Column

<pre>
select addtrajectorycolumn('public', 'taxi', 'traj', 4326, 'MOVINGPOINT', 2, 10);
</pre>

## Insert an Moving Object

<pre>
insert into taxi values(1, '57NU2001', 'Optima', 'hongkd7');
insert into taxi values(2, '57NU2002', 'SonataYF', 'hongkd7');
insert into taxi values(3, '57NU2003', 'Optima', 'hongkd7');
insert into taxi values(4, '57NU2004', 'SonataYF', 'hongkd7');
insert into taxi values(5, '57NU2005', 'Optima', 'hongkd7');
</pre>

## Append GPS or a Trajectory Point in a Moving Object
<pre>
UPDATE taxi 
SET    traj = append(traj, tpoint(st_point(200, 200),TIMESTAMP '2010-01-25 12:05:30+09')) 
WHERE  taxi_id = 1;
</pre>


## View All Moving Objects
<pre>
select * from taxi;
</pre>

## Append GPS Stream or a Trajectort in a Moving Object
<pre>
-- append(trajcetory, tpoint[]) 테스트 4개만 추가
update taxi set traj = append(traj, ARRAY[ ( tpoint(st_point(1510, 1210),TIMESTAMP '2010-01-26 15:21:40+09') ), 
					   ( tpoint(st_point(1320, 1220),TIMESTAMP '2010-01-26 15:25:40+09') ), 
					   ( tpoint(st_point(1405, 1175),TIMESTAMP '2010-01-26 15:29:40+09') ), 
					   ( tpoint(st_point(1461, 1037),TIMESTAMP '2010-01-26 15:36:40+09') ) ]::tpoint[] )  
		where taxi_id = 1;
</pre>

## Remove GPS Stream or Partial Trajectory in a Moving Object
<pre>
-- reomve 테스트 
--3번째 row의 값 5개 삭제
update taxi set traj = remove(traj, TIMESTAMP '2010-01-26 12:33:40+09', TIMESTAMP '2010-01-26 12:37:40+09')
	where taxi_id = 1;


-- 삭제 1row 이상을 삭제하게 되면(row에 tpseg값이 하나도 없게되면) row를 삭제해주는 실험
update taxi set traj = remove(traj, TIMESTAMP '2010-01-26 12:18:40+09', TIMESTAMP '2010-01-26 12:45:40+09')
	where taxi_id = 1;
</pre>


## Update GPS Stream or Partial Trajectory in a Moving Object
<pre>
--modify 테스트
update taxi set traj = modify(traj, tpoint(st_point(1000, 1000), TIMESTAMP '2010-01-26 15:40:40+9'))
	where taxi_id = 1;

--modify(trajectory, tpoint[]) 테스트
update taxi set traj = modify(traj, ARRAY[ (tpoint(st_point(1000, 1000), TIMESTAMP '2010-01-26 15:40:40+9') ),
					   (tpoint(st_point(1200, 1100), TIMESTAMP '2010-01-26 15:46:40+9') ),
					   (tpoint(st_point(1400, 1050), TIMESTAMP '2010-01-26 15:49:40+9') ),
					   (tpoint(st_point(2000, 2000), TIMESTAMP '2010-01-26 15:57:40+9') ) ]::tpoint[] )
	where taxi_id = 1;


update taxi set traj = modify(traj, ARRAY[ (tpoint(st_point(0000, 0000), TIMESTAMP '2010-01-26 15:40:40+9') ),
					   (tpoint(st_point(0000, 0000), TIMESTAMP '2010-01-26 15:46:40+9') ),
					   (tpoint(st_point(0000, 0000), TIMESTAMP '2010-01-26 15:49:40+9') ),
					   (tpoint(st_point(0000, 0000), TIMESTAMP '2010-01-26 15:57:40+9') ) ]::tpoint[] )
	where taxi_id = 1;


-- modify(trajectory, timestamp, timestamp, tpoint[]) 테스트
-- 사용자 입력시간과 tpoint[]의 시간이 contain 되지 않을때
update taxi set traj = modify(traj, TIMESTAMP '2010-01-26 14:00:40+9', TIMESTAMP '2010-01-26 14:03:40+9',
			      ARRAY[ (tpoint(st_point(0000, 0000), TIMESTAMP '2010-01-26 15:00:40+9') ),
			             (tpoint(st_point(0000, 0000), TIMESTAMP '2010-01-26 15:01:40+9') ),
				     (tpoint(st_point(0000, 0000), TIMESTAMP '2010-01-26 15:02:40+9') ),
				     (tpoint(st_point(0000, 0000), TIMESTAMP '2010-01-26 15:03:40+9') ) ]::tpoint[] )
	where taxi_id = 1;


-- 시작시간과 끝시간, tpoint[]값을 줬을때 modify
update taxi set traj = modify(traj, TIMESTAMP '2010-01-26 15:00:40+9', TIMESTAMP '2010-01-26 15:03:40+9',
			      ARRAY[ (tpoint(st_point(0000, 0000), TIMESTAMP '2010-01-26 15:00:40+9') ),
			             (tpoint(st_point(0000, 0000), TIMESTAMP '2010-01-26 15:01:40+9') ),
				     (tpoint(st_point(0000, 0000), TIMESTAMP '2010-01-26 15:02:40+9') ),
				     (tpoint(st_point(0000, 0000), TIMESTAMP '2010-01-26 15:03:40+9') ) ]::tpoint[] )
	where taxi_id = 1;

</pre>


## Slicing Trjactories
<pre>
select slice( traj, TIMESTAMP '2011-02-20 17:13:00', TIMESTAMP '2011-02-20 17:26:00')
from taxi;
</pre>

## Spatial Slicing 
<pre>
select stay(traj, 'LINESTRING(15000 18000, 30000 30000)') 
from taxi;
</pre>

## Spatial Slicing and Temporal Slicing
<pre>
select slice( traj, TIMESTAMP '2011-02-20 17:13:00', TIMESTAMP '2011-02-20 17:26:00'), stay(traj, 'LINESTRING(15000 18000, 30000 30000)')
from taxi;
</pre>

## Enter Function and Predicates
<pre>
select aa_enter( traj, st_geometry('BOX(17 6, 29 31)'::box2d) 
from taxi;

select slice( traj, st_geometry('BOX(17 6, 29 31)'::box2d) ),  aa_enter( traj, st_geometry('BOX(17 6, 29 31)'::box2d) )
from taxi;

</pre>

## Install Environment
<pre>
1. PostgresQL 9.3
2. postGIS 2.1.3
3. Python 3.2

</pre>

