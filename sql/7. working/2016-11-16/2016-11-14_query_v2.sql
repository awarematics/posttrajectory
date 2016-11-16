

select * from mpseq_1844374_traj
 where rect && ST_MakeBox2D(ST_makePoint(104.374765, 32.12484), ST_makePoint(107.063666, 33.874814));

=> 14

explain 
select * from mpseq_1844374_traj
 where make_3dpolygon(rect, start_time, end_time)
  &&& make_3dpolygon(ST_MakeBox2D(ST_makePoint(104.374765, 32.12484), ST_makePoint(107.063666, 33.874814)),
   timestamp without time zone '2008-02-02 13:30:00', timestamp without time zone '2008-02-02 13:31:15');


explain 
select * from mpseq_1844374_traj
 where make_3dpolygon(rect, start_time, end_time)
  &&& ST_3DMakeBox(ST_makePoint(104.374765, 32.12484 ,todouble(timestamp without time zone '2008-02-02 13:30:00')),
   ST_makePoint(107.063666, 33.874814, todouble(timestamp without time zone '2008-02-07 13:31:15')));




explain analyze
select * from mpseq_1844374_traj
 where ptraj_index_to3dgeom(rect, start_time, end_time)
  &&& ST_3DMakeBox(ST_makePoint(104.374765, 32.12484 ,todouble(timestamp without time zone '2008-02-02 13:30:00')),
   ST_makePoint(107.063666, 33.874814, todouble(timestamp without time zone '2008-02-07 13:31:15')));



explain (format json)
select * from mpseq_1844374_traj
 where ptraj_index_to3dgeom(rect, start_time, end_time)
  &&& make_3dpolygon(ST_MakeBox2D(ST_makePoint(104.374765, 32.12484), ST_makePoint(107.063666, 33.874814)),
   timestamp without time zone '2008-02-02 13:30:00', timestamp without time zone '2008-02-07 13:31:15');


=> 12

explain
select * from mpseq_1844374_traj
 where make_3dpolygon(rect, start_time, end_time)
  &&& make_3dpolygon(ST_MakeBox2D(ST_makePoint(104.374765, 32.12484), ST_makePoint(107.063666, 33.874814)),
   timestamp without time zone '2008-02-02 13:30:00', timestamp without time zone '2008-02-02 13:31:15');

=> 3

select count(*) from mpseq_1844374_traj
 where make_3dpolygon(rect, start_time, end_time)   
  &&& make_3dpolygon(ST_MakeBox2D(ST_makePoint(104.374765, 32.12484), ST_makePoint(107.063666, 33.874814)), 
   timestamp without time zone '2008-02-02 13:30:00', timestamp without time zone '2008-02-07 13:31:15');


 

explain select count(*) from mpseq_1844374_traj where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& ST_3DMakeBox(ST_makePoint(116.38908, 39.78912 ,todouble(timestamp without time zone '2010-02-01 10:00:00')),
  ST_makePoint(140.44457, 49.92335, todouble(timestamp without time zone '2010-02-02 17:29:32')));



  explain select count(*)
  from mpseq_1844374_traj where make_3dpolygon(tpseg)   
 &&& make_3dpolygon(ST_MakeBox2D(ST_makePoint(104.374765, 32.12484), ST_makePoint(107.063666, 33.874814)), 
 timestamp without time zone '2008-02-02 13:30:00', timestamp without time zone '2008-02-02 13:31:15');

explain select count(*) from mpseq_1844374_traj where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& ST_3DMakeBox(ST_makePoint(116.38908, 39.78912 ,todouble(timestamp without time zone '2010-02-01 10:00:00')),
  ST_makePoint(140.44457, 49.92335, todouble(timestamp without time zone '2010-02-02 17:29:32')));