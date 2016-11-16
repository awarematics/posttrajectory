

-- NTT(Non Temporary Table) Experiment
select count(*) from mpseq_1844374_traj where
  TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))); 


select count(*) from mpseq_1844374_traj where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))
  and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745))));


select count(*) from mpseq_1844374_traj where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_3DMakeBox(ST_makePoint(108.45223, 22.91412 ,todouble(timestamp without time zone '2010-02-02 10:00:00')),
  ST_makePoint(117.589875, 34.351745, todouble(timestamp without time zone '2010-02-02 11:00:00'))))
and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))); 


select count(*) from mpseq_1844374_traj where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& ST_3DMakeBox(ST_makePoint(108.45223, 22.91412 ,todouble(timestamp without time zone '2010-02-02 10:00:00')),
  ST_makePoint(117.589875, 34.351745, todouble(timestamp without time zone '2010-02-02 11:00:00')))
and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))); 



-- TT(Temporary Table) Experiment
select count(*) from taxi_ex1_100k 
 where ptraj_passes_id(traj, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745))));

select st_astext(geometry(ST_3DMakeBox(ST_makePoint(108.45223, 22.91412 ,todouble(timestamp without time zone '2010-02-02 10:00:00')),
  ST_makePoint(117.589875, 34.351745, todouble(timestamp without time zone '2010-02-02 11:00:00')))));

select ST_3DMakeBox(ST_makePoint(108.45223, 22.91412 ,todouble(timestamp without time zone '2010-02-02 10:00:00')),
  ST_makePoint(117.589875, 34.351745, todouble(timestamp without time zone '2010-02-02 11:00:00')));