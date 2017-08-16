PostTrajectory Project
==============

PostTrajectory is a trajectory and moving objects management system which have been developed on PostgreSQL/PostGIS. 
This system have been developed by Awarematics Group, School of Computer, Information, and Communication Engineering, Kunsan National University. Any comments and contributions are welcomed.

## Current Members

<pre>
Pyung Woo Yang, Kunsan National University and Turbosoft Inc., manner7979@gmail.com 
Kwang Woo Nam, Kunsan National University, kwnam@kunsan.ac.kr
</pre>

## Alumni
Kihyun Yoo, Kunsan National University


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
select tj_addtrajectorycolumn('public', 'taxi', 'traj', 4326, 'MOVINGPOINT', 2, 10);
</pre>

## Insert Moving Objects

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
SET    traj = tj_append(traj, tpoint(st_point(200, 200),TIMESTAMP '2010-01-25 12:05:30+09')) 
WHERE  taxi_id = 1;

## To be
## MPOINT is ( x y t, x y t, ...) = (float float long, float float long, ...)
UPDATE taxi 
SET    traj = tj_append(traj, 'MPOINT( 100 100 5000, 150 150 5001)') 
WHERE  taxi_id = 1;
</pre>


## View All Moving Objects
<pre>
select * from taxi;
</pre>

## Append GPS Stream or a Trajectories in a Moving Object
<pre>

-- new update statement
UPDATE taxi 
SET traj = tj_append(traj, ARRAY[ ( tpoint(st_point(1510, 1210),TIMESTAMP '2010-01-26 15:21:40+09') ), 
					   ( tpoint(st_point(1320, 1220),TIMESTAMP '2010-01-26 15:25:40+09') ), 
					   ( tpoint(st_point(1405, 1175),TIMESTAMP '2010-01-26 15:29:40+09') ), 
					   ( tpoint(st_point(1461, 1037),TIMESTAMP '2010-01-26 15:36:40+09') ) ]::tpoint[] )
WHERE  taxi_id = 1;

## To be
UPDATE taxi 
SET traj = tj_append(traj, 'MPOINT (1510 1210 5003, 1320 1220 5004, 1405 1175 5005, 1461 1037 5006)' )  
WHERE taxi_id = 1;

</pre>

## Remove GPS Stream or Partial Trajectory in a Moving Object
<pre>
-- reomve 
UPDATE taxi 
SET traj = tj_remove(traj, TIMESTAMP '2010-01-26 12:33:40+09', TIMESTAMP '2010-01-26 12:37:40+09')
WHERE taxi_id = 1;

## To be
UPDATE taxi 
SET traj = tj_remove(traj, 'PERIOD( TIMESTAMP( 2010-01-26 12:33:40+09), TIMESTAMP(2010-01-26 12:37:40+09) )' )
WHERE taxi_id = 1;

UPDATE taxi 
SET traj = tj_remove(traj, 'PERIOD( 5001, 5003)' )
WHERE taxi_id = 1;
</pre>


## Slicing Trjactories
<pre>
select tj_slice( traj, TIMESTAMP '2010-01-26 14:50:40+09', TIMESTAMP '2010-01-26 15:20:40+09')
from taxi;

## To be
select tj_slice( traj, 'PERIOD(5003, 5005)')
from taxi;
</pre>

## Spatial Slicing 
<pre>
select tj_slice(traj, geometry('POLYGON ( ( 300 200, 300 300, 440 300, 440 200, 300 200 ) )')
from taxi;
</pre>

## Spatial Slicing and Temporal Slicing
<pre>
SELECT tj_slice( traj, TIMESTAMP '2010-01-26 12:15:30+09', TIMESTAMP '2010-01-26 12:17:00+09'), tj_slice(traj, geometry('POLYGON ( ( 300 200, 300 300, 440 300, 440 200, 300 200 ) )'))
from taxi;

SELECT tj_slice( traj, TIMESTAMP '2010-01-26 14:50:40+09', timestamp '2010-01-26 15:20:40+09')
from taxi
where tj_overlap( tj_slice(traj, geometry('POLYGON ( ( 300 200, 300 300, 440 300, 440 200, 300 200 ) )')), 
						tj_period(TIMESTAMP '2010-01-26 15:00:00+09', TIMESTAMP '2010-01-27 00:00:00+09'));


## To be
SELECT tj_slice( traj, TIMESTAMP '2011-02-20 17:13:00', TIMESTAMP '2011-02-20 17:26:00')
from taxi
where tj_overlap( tj_slice(traj, GeomFromText('POLYGON(15000 18000, 30000 30000, 15000 18000)')), 'PERIOD( 5003, 5008 ')); 

</pre>

## Enter Function and Predicates
<pre>
select taxi_id, tj_enter(traj, box2d(geometry('POLYGON ( ( 300 200, 300 300, 440 300, 440 200, 300 200 ) )'))::box2d)
from taxi

SELECT taxi_id, taxi_number
from taxi
where tj_enter(traj, geometry('POLYGON ( ( 300 200, 300 300, 440 300, 440 200, 300 200 ) )'))


## To be
SELECT taxi_id, taxi_number
from taxi
WHERE tj_enter( traj, GeomFromText('POLYGON(15000 18000, 30000 30000, 15000 18000)', 'PERIOD( 5003, 5008 )'));


</pre>

## Example queries for distance function
1. m_distance : MDouble
2. m_mindistance : minimum distance of MDouble
3. m_maxdistance : maximum distance of MDouble

<pre>
SELECT taxi_id, taxi_numer, 
       tj_distance(traj, geometry('Point( 50 50 )' ),
       tj_mindistance(traj, geometry('Point( 50 50 )' ), 
       tj_maxdistance(traj, geometry('Point( 50 50 )' )
FROM taxi;

SELECT taxi_id, bus_id, tj_distance( t.traj, b.traj)
FROM taxi t, bus b;

SELECT taxi_id, taxi_number 
FROM taxi
WHERE tj_getDistance( tj_mindistance(traj,  geometry('Point( 50 50 )') ) < 20;

SELECT taxi_id, taxi_number, tj_slice( traj, TIMESTAMP '2011-02-20 17:13:00', TIMESTAMP '2011-02-20 17:26:00')
FROM taxi 
WHERE tj_getDistance( tj_mindistance( tj_slice( traj, TIMESTAMP '2011-02-20 17:13:00', TIMESTAMP '2011-02-20 17:26:00'), 
                     geometry('Point( 50 50 )') ) < 50;

SELECT tj_distance(b.traj, t.traj) 
FROM taxi t, bus b 
WHERE tj_mindistance(t.traj, b.traj,  TIMESTAMP '2011-02-20 17:13:00', TIMESTAMP '2011-02-20 17:26:00') < 100m;

</pre>

## Install Environment
<pre>
1. PostgresQL 9.6
2. postGIS 2.3
3. Python 3.2

</pre>
