
-- Not SETI

-- No Index
select count(*) from mpseq_notseti_traj_v100k where
  TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))); 

-- Index
select count(*) from mpseq_notseti_traj_v500k where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))
  and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))); 


select count(*) from mpseq_notseti_traj_v900k where TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745))))
and ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745))); 


-- SETI*

-- No Index
select count(*) from mpseq_seti_traj_v700k where
  TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))); 

-- Index
select count(*) from mpseq_seti_traj_v900k where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))
  and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))); 


select count(*) from mpseq_seti_traj_v900k where TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745))))
and ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745))); 


select st_astext(geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745))));