PostTrajectory Project
==============

PostTrajectory is an trajectory and moving objects management system on PostgreSQL/PostGIS. 
This system have been developed by Awarematics Group, School of Computer, Information, and Communication Engineering, Kunsan National University. Any comments and contributions are welcomed.

## Members
Kihyun Yoo, Kunsan National University
Pyung Woo Yang, Kunsan National University
Kwang Woo Nam, Kunsan National University

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
## MPOINT is ( x y t, x y t, ...) = (float float long, float float long, ...)
UPDATE taxi 
SET    traj = append(traj, 'MPOINT( 100 100 5000, 150 150 5001)') 
WHERE  taxi_id = 1;

## To be deprecated
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

-- new update statement
UPDATE taxi 
SET traj = append(traj, 'MPOINT (1510, 1210 5003, 1320 1220 5004, 1405 1175 5005, 1461 1037 5006)' )  
WHERE taxi_id = 1;

-- To be deprecated
UPDATE taxi 
SET traj = append(traj, ARRAY[ ( tpoint(st_point(1510, 1210),TIMESTAMP '2010-01-26 15:21:40+09') ), 
					   ( tpoint(st_point(1320, 1220),TIMESTAMP '2010-01-26 15:25:40+09') ), 
					   ( tpoint(st_point(1405, 1175),TIMESTAMP '2010-01-26 15:29:40+09') ), 
					   ( tpoint(st_point(1461, 1037),TIMESTAMP '2010-01-26 15:36:40+09') ) ]::tpoint[] )
</pre>

## Remove GPS Stream or Partial Trajectory in a Moving Object
<pre>
-- reomve 

-- new statement
UPDATE taxi 
SET traj = remove(traj, 'PERIOD( TIMESTAMP( 2010-01-26 12:33:40+09), TIMESTAMP(2010-01-26 12:37:40+09) )' )
WHERE taxi_id = 1;

UPDATE taxi 
SET traj = remove(traj, 'PERIOD( 5001, 5003)' )
WHERE taxi_id = 1;

-- To be deprecated
UPDATE taxi 
SET traj = remove(traj, TIMESTAMP '2010-01-26 12:33:40+09', TIMESTAMP '2010-01-26 12:37:40+09')
WHERE taxi_id = 1;
</pre>


## Update GPS Stream or Partial Trajectory in a Moving Object
<pre>
-- new statement
-- if it is needed the point to be changed at the specific time, 
-- modify ( traj, point, atTimeCondition )
UPDATE taxi 
SET traj = modify(traj, st_point(1000, 1000), 'TIMESTAMP(2010-01-26 15:40:40+9)');
WHERE taxi_id = 1;

-- new statement
-- modify(trajectory, MPoint, duringPeriodCondition ) 테스트
update taxi set traj = modify(traj, 'MPOINT( 1000 1000 5005, 1200 1100 5006, 1400 1050 5007, 2000 2000 5008 )', 
                                    'PERIOD( 5005, 5008 )');

-- To be deprecated
-- modify(trajectory, tpoint[])
update taxi set traj = modify(traj, ARRAY[ (tpoint(st_point(1000, 1000), TIMESTAMP '2010-01-26 15:40:40+9') ),
					   (tpoint(st_point(1200, 1100), TIMESTAMP '2010-01-26 15:46:40+9') ),
					   (tpoint(st_point(1400, 1050), TIMESTAMP '2010-01-26 15:49:40+9') ),
					   (tpoint(st_point(2000, 2000), TIMESTAMP '2010-01-26 15:57:40+9') ) ]::tpoint[] )
	where taxi_id = 1;

-- to be deprecated
-- modify(trajectory, timestamp, timestamp, tpoint[]) 
update taxi set traj = modify(traj, TIMESTAMP '2010-01-26 14:00:40+9', TIMESTAMP '2010-01-26 14:03:40+9',
			      ARRAY[ (tpoint(st_point(0000, 0000), TIMESTAMP '2010-01-26 15:00:40+9') ),
			             (tpoint(st_point(0000, 0000), TIMESTAMP '2010-01-26 15:01:40+9') ),
				     (tpoint(st_point(0000, 0000), TIMESTAMP '2010-01-26 15:02:40+9') ),
				     (tpoint(st_point(0000, 0000), TIMESTAMP '2010-01-26 15:03:40+9') ) ]::tpoint[] )
	where taxi_id = 1;


</pre>


## Slicing Trjactories
<pre>
select slice( traj, 'TIMESTAMP(2011-02-20 17:13:00)', 'TIMESTAMP(2011-02-20 17:26:00)')
from taxi;

select slice( traj, 'PERIOD(5003, 5005)')
from taxi;
</pre>

## Spatial Slicing 
<pre>
select slice(traj, GeomFromText('POLYGON(15000 18000, 30000 30000, 15000 18000)')) 
from taxi;
</pre>

## Spatial Slicing and Temporal Slicing
<pre>
SELECT slice( traj, TIMESTAMP '2011-02-20 17:13:00', TIMESTAMP '2011-02-20 17:26:00'), slice(traj, 'POLYGON(15000 18000, 30000 30000, 15000 18000)')
from taxi;

SELECT slice( traj, TIMESTAMP '2011-02-20 17:13:00', TIMESTAMP '2011-02-20 17:26:00')
from taxi
where T_OVERLAP( slice(traj, GeomFromText('POLYGON(15000 18000, 30000 30000, 15000 18000)')), 'PERIOD( 5003, 5008 ')); 

SELECT slice( traj, TIMESTAMP '2011-02-20 17:13:00', TIMESTAMP '2011-02-20 17:26:00')
from taxi
where T_OVERLAP( slice(traj, GeomFromText('POLYGON(15000 18000, 30000 30000, 15000 18000)')), 'PERIOD( 5003, 5008 )');
</pre>

## Enter Function and Predicates
<pre>
SELECT TT_enter( traj, st_geometry('BOX(17 6, 29 31)'::box2d) 
from taxi;

SELECT taxi_id, taxi_number
from taxi
WHERE TT_enter( traj, GeomFromText('POLYGON(15000 18000, 30000 30000, 15000 18000)'));

SELECT taxi_id, taxi_number
from taxi
WHERE TT_enter( traj, GeomFromText('POLYGON(15000 18000, 30000 30000, 15000 18000)', 'PERIOD( 5003, 5008 )'));

SELECT slice( traj, st_geometry('BOX(17 6, 29 31)'::box2d) ),  aa_enter( traj, st_geometry('BOX(17 6, 29 31)'::box2d) )
from taxi;

</pre>

## Example queries for distance function
1. m_distance : MDouble
2. m_mindistance : minimum distance of MDouble
3. m_maxdistance : maximum distance of MDouble

<pre>
SELECT taxi_id, taxi_numer, 
       m_distance(traj, GeomFromText('Point( 50 50 )' ),
       m_mindistance(traj, GeomFromText('Point( 50 50 )' ), 
       m_maxdistance(traj, GeomFromText('Point( 50 50 )' )
FROM taxi;

SELECT taxi_id, bus_id, distance( t.traj, b.traj)
FROM taxi t, bus b;

SELECT taxi_id, taxi_number 
FROM taxi
WHERE m_mindistance(traj,  GeomFromText('Point( 50 50 )') < 20;

SELECT taxi_id, taxi_number, slice( traj, TIMESTAMP '2011-02-20 17:13:00', TIMESTAMP '2011-02-20 17:26:00')
FROM taxi 
WHERE m_mindistance( slice( traj, TIMESTAMP '2011-02-20 17:13:00', TIMESTAMP '2011-02-20 17:26:00'), 
                     GeomFromText('Point( 50 50 )') < 50;

SELECT m_distance(b.traj, t.traj) 
FROM taxi t, bus b 
WHERE m_mindistance(t.traj, b.traj,  TIMESTAMP '2011-02-20 17:13:00', TIMESTAMP '2011-02-20 17:26:00') < 100m;

</pre>

## Install Environment
<pre>
1. PostgresQL 9.3
2. postGIS 2.1.3
3. Python 3.2

</pre>



