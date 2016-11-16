
-- 100k
select count(*) from mpseq_notseti_traj_v100k where TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))); 


select count(*) from mpseq_notseti_traj_v100k where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))
  and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))); 



select count(*) from mpseq_notseti_traj_v100k where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(113.0210525, 28.6329325)))
  and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(113.0210525, 28.6329325)))); 



select count(*) from mpseq_notseti_traj_v100k where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(110.7366413, 25.77352625)))
  and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(110.7366413, 25.77352625)))); 



select count(*) from mpseq_notseti_traj_v100k where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(109.5944356, 24.34382313)))
  and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(109.5944356, 24.34382313)))); 


-- 300k
select count(*) from mpseq_notseti_traj_v300k where TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))); 


select count(*) from mpseq_notseti_traj_v300k where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))
  and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))); 
  

select count(*) from mpseq_notseti_traj_v300k where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(113.0210525, 28.6329325)))
  and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(113.0210525, 28.6329325)))); 



select count(*) from mpseq_notseti_traj_v300k where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(110.7366413, 25.77352625)))
  and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(110.7366413, 25.77352625)))); 



select count(*) from mpseq_notseti_traj_v300k where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(109.5944356, 24.34382313)))
  and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(109.5944356, 24.34382313)))); 


-- 500k
select count(*) from mpseq_notseti_traj_v500k where TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))); 


select count(*) from mpseq_notseti_traj_v500k where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))
  and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))); 
  

select count(*) from mpseq_notseti_traj_v500k where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(113.0210525, 28.6329325)))
  and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(113.0210525, 28.6329325)))); 



select count(*) from mpseq_notseti_traj_v500k where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(110.7366413, 25.77352625)))
  and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(110.7366413, 25.77352625)))); 



select count(*) from mpseq_notseti_traj_v500k where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(109.5944356, 24.34382313)))
  and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(109.5944356, 24.34382313)))); 



-- 700k
select count(*) from mpseq_notseti_traj_v700k where TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))); 


select count(*) from mpseq_notseti_traj_v700k where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))
  and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))); 
  

select count(*) from mpseq_notseti_traj_v700k where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(113.0210525, 28.6329325)))
  and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(113.0210525, 28.6329325)))); 



select count(*) from mpseq_notseti_traj_v700k where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(110.7366413, 25.77352625)))
  and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(110.7366413, 25.77352625)))); 



select count(*) from mpseq_notseti_traj_v700k where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(109.5944356, 24.34382313)))
  and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(109.5944356, 24.34382313)))); 



-- 900k
select count(*) from mpseq_notseti_traj_v900k where TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))); 



select count(*) from mpseq_notseti_traj_v900k where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))
  and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))); 



select count(*) from mpseq_notseti_traj_v900k where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(113.0210525, 28.6329325)))
  and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(113.0210525, 28.6329325)))); 



select count(*) from mpseq_notseti_traj_v900k where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(110.7366413, 25.77352625)))
  and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(110.7366413, 25.77352625)))); 



select count(*) from mpseq_notseti_traj_v900k where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(109.5944356, 24.34382313)))
  and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(109.5944356, 24.34382313)))); 

  