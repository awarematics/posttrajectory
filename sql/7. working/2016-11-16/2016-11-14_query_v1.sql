-- Non Index, 전체 데이터셋
select *
  from mpseq_1844374_traj;


-- 3D R-tree Index, 전체 데이터셋
explain select *
  from mpseq_1844374_traj where make_3dpolygon(tpseg)   
 &&& make_3dpolygon(ST_MakeBox2D(ST_makePoint(0.38908, 0.78912), ST_makePoint(140.44457, 49.92335)), 
 timestamp without time zone '2008-02-02 10:00:00', timestamp without time zone '2008-02-09 13:28:33');


-- 3D R-tree Index with Temporal Table, 전체 데이터셋
select * from taxi_ex1_100k 
 where ptraj_passes_3d_id(traj, make_3dpolygon(ST_MakeBox2D(ST_makePoint(0.38908, 0.78912), ST_makePoint(140.44457, 49.92335)), 
 timestamp without time zone '2008-02-02 10:00:00', timestamp without time zone '2008-02-09 13:28:33'));
 


-- Non Index, 시간 조건 질의
select * from mpseq_1844374_traj where
 tp_overlaps(tp_period(start_time, end_time), tp_period(timestamp without time zone '2008-02-01 10:00:00', timestamp without time zone '2008-02-02 17:29:32'));

결과 갯수 => 969

-- 3D R-tree Index, 시간 조건 질의
select *
  from mpseq_1844374_traj where make_3dpolygon(tpseg)   
 &&& make_3dpolygon(ST_MakeBox2D(ST_makePoint(0.38908, 0.78912), ST_makePoint(140.44457, 49.92335)), 
 timestamp without time zone '2008-02-01 10:00:00', timestamp without time zone '2008-02-02 17:29:32');

결과 갯수 => 969



-- Non Index, 공간 조건 질의
select * from mpseq_1844374_traj where
 rect && ST_MakeBox2D(ST_makePoint(116.38908, 39.78912), ST_makePoint(140.44457, 49.92335));

결과 갯수 => 795


-- 3D R-tree Index, 공간 조건 질의

select *
  from mpseq_1844374_traj where make_3dpolygon(tpseg)   
 &&& make_3dpolygon(ST_MakeBox2D(ST_makePoint(104.374765, 32.12484), ST_makePoint(107.063666, 33.874814)), 
 timestamp without time zone '2008-02-01 10:00:00', timestamp without time zone '2008-02-09 17:29:32');
 
explain select count(*)
  from mpseq_1844374_traj where make_3dpolygon(tpseg)   
 &&& make_3dpolygon(ST_MakeBox2D(ST_makePoint(104.374765, 32.12484), ST_makePoint(107.063666, 33.874814)), 
 timestamp without time zone '2008-02-02 13:30:00', timestamp without time zone '2008-02-02 13:31:15');

explain select count(*) from mpseq_1844374_traj where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& ST_3DMakeBox(ST_makePoint(116.38908, 39.78912 ,todouble(timestamp without time zone '2010-02-01 10:00:00')),
  ST_makePoint(140.44457, 49.92335, todouble(timestamp without time zone '2010-02-02 17:29:32')));

  
결과 갯수 => 795


-- Non Index, (공간 시간) 조건 질의
select * from mpseq_1844374_traj where
 rect && ST_MakeBox2D(ST_makePoint(116.38908, 39.78912), ST_makePoint(140.44457, 49.92335))
  and tp_overlaps(tp_period(start_time, end_time), tp_period(timestamp without time zone '2008-02-01 10:00:00', timestamp without time zone '2008-02-02 17:29:32'));

결과 갯수 => 762


-- 3D R-tree Index, (공간 시간) 조건 질의
explain select *
  from mpseq_1844374_traj where make_3dpolygon(tpseg)   
 &&& make_3dpolygon(ST_MakeBox2D(ST_makePoint(116.38908, 39.78912), ST_makePoint(140.44457, 49.92335)), 
 timestamp without time zone '2008-02-01 10:00:00', timestamp without time zone '2008-02-02 17:29:32');


explain select count(*)
  from mpseq_1844374_traj where make_3dpolygon(tpseg)   
 &&& ST_3DMakeBox(ST_makePoint(116.38908, 39.78912 ,todouble(timestamp without time zone '2010-02-01 10:00:00')),
  ST_makePoint(140.44457, 49.92335, todouble(timestamp without time zone '2010-02-02 17:29:32')));


explain select count(*) from mpseq_1844374_traj where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& ST_3DMakeBox(ST_makePoint(116.38908, 39.78912 ,todouble(timestamp without time zone '2010-02-01 10:00:00')),
  ST_makePoint(140.44457, 49.92335, todouble(timestamp without time zone '2010-02-02 17:29:32')));

  


결과 갯수 => 762


