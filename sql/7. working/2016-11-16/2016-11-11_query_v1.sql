
select count(*)
  from mpseq_1844528_traj where make_3dpolygon(tpseg)   
 &&& make_3dpolygon(ST_MakeBox2D(ST_makePoint(116.38908, 39.78912), ST_makePoint(116.44457, 39.92335)), 
 timestamp without time zone '2008-02-02 10:00:00', timestamp without time zone '2008-02-02 17:29:32');


 select count(*)
  from mpseq_1844528_traj where start_time >= timestamp without time zone '2008-02-02 10:00:00' and end_time <= timestamp without time zone '2008-02-02 17:29:32';

select count(*)
  from mpseq_1844528_traj where tp_overlaps(tp_period(start_time, end_time),
 tp_period(timestamp without time zone '2008-02-02 10:00:00', timestamp without time zone '2008-02-02 17:29:32'));
  
 select *
  from mpseq_1844528_traj



  "2008-02-02 13:32:03"

  "2008-02-02 16:51:09"

select tp_overlaps(tp_period(timestamp without time zone '2008-02-02 10:00:00', timestamp without time zone '2008-02-02 17:29:32'),
 tp_period(timestamp without time zone '2008-02-02 10:00:00', timestamp without time zone '2008-02-02 17:29:32'));

select count(*)
  from mpseq_1844374_traj where tp_overlaps(tp_period(start_time, end_time),
 tp_period(timestamp without time zone '2008-02-02 10:00:00', timestamp without time zone '2008-02-02 13:32:03')) and mpid=751 and segid=1;


select count(*)
  from mpseq_1844374_traj where tp_overlaps(tp_period(start_time, end_time),
 tp_period(timestamp without time zone '2008-02-01 10:00:00', timestamp without time zone '2008-02-02 13:32:11'))
  and  rect && ST_MakeBox2D(ST_makePoint(0.38908, 0.78912), ST_makePoint(140.44457, 49.92335)) 




select todouble(timestamp without time zone '"2008-02-02 13:32:03"');
select * from mpseq_1844374_traj where mpid=751 and segid=1;

select make_3dpolygon(tpseg)   
 &&& make_3dpolygon(ST_MakeBox2D(ST_makePoint(116.38908, 39.78912), ST_makePoint(116.44457, 39.92335)), 
 timestamp without time zone '2008-02-02 10:00:00', timestamp without time zone '2008-02-02 13:32:03')
  from mpseq_1844374_traj where mpid=751 and segid=1;


select *
  from mpseq_1844374_traj;

select * from taxi_ex1_100k 
 where ptraj_passes_3d_id(traj, make_3dpolygon(ST_MakeBox2D(ST_makePoint(0.38908, 0.78912), ST_makePoint(140.44457, 49.92335)), 
 timestamp without time zone '2008-02-02 10:00:00', timestamp without time zone '2008-02-09 13:28:33'));
 


select count(*)
  from mpseq_1844374_traj where make_3dpolygon(tpseg)   
 &&& make_3dpolygon(ST_MakeBox2D(ST_makePoint(0.38908, 0.78912), ST_makePoint(140.44457, 49.92335)), 
 timestamp without time zone '2008-02-02 10:00:00', timestamp without time zone '2008-02-09 13:28:33');

 

select count(*) from taxi_ex1_100k 
 where ptraj_passes_3d_id(traj, st_geomfromtext('polygon((0.38908 0.78912,0.38908 49.92335,140.38908 49.92335,140.38908 0.92335,0.38908 0.78912))'))



select count(*) from taxi_ex1_100k 
 where ptraj_passes_3d_id(traj, make_3dpolygon(ST_MakeBox2D(ST_makePoint(0.38908, 0.78912), ST_makePoint(140.44457, 49.92335)), 
 timestamp without time zone '2008-02-02 10:00:00', timestamp without time zone '2008-02-09 13:28:33'));
 

  
select count(*)
  from mpseq_1844374_traj where make_3dpolygon(tpseg)   
 &&& make_3dpolygon(ST_MakeBox2D(ST_makePoint(0.38908, 0.78912), ST_makePoint(140.44457, 49.92335)), 
 timestamp without time zone '2008-02-02 10:00:00', timestamp without time zone '2008-02-09 13:28:33');

select *
  from mpseq_1844374_traj where rect
   && ST_MakeBox2D(ST_makePoint(116.38908, 39.78912), ST_makePoint(140.44457, 49.92335)), 
 timestamp without time zone '2008-02-02 10:00:00', timestamp without time zone '2008-02-09 13:28:33');


select *
  from mpseq_1844374_traj where make_3dpolygon(tpseg)   
 &&& make_3dpolygon(ST_MakeBox2D(ST_makePoint(116.38908, 39.78912), ST_makePoint(140.44457, 49.92335)), 
 timestamp without time zone '2008-02-02 10:00:00', timestamp without time zone '2008-02-02 13:28:33');


 mpseq_1844374_traj