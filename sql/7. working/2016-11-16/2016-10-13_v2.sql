
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


mpseq_1101121_traj(SETI*)
mpseq_1101138_traj(3DR-tree)
mpseq_1345639_traj(No Index)


-- 2D Box
select count(*) from mpseq_1101121_traj where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(126.72752, 45.78937)));

select count(*) from mpseq_1101138_traj where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(126.72752, 45.78937)));
 
select count(*) from mpseq_1345639_traj where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(126.72752, 45.78937)));


-- 3D Box
select count(*) from mpseq_1101121_traj where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_3DMakeBox(ST_makePoint(108.45223, 22.91412,todouble(timestamp '2010-02-02 10:00:00')),
  ST_makePoint(126.72752, 45.78937, todouble(timestamp '2010-02-02 11:00:00'))));

select count(*) from mpseq_1101138_traj where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_3DMakeBox(ST_makePoint(108.45223, 22.91412,todouble(timestamp '2010-02-02 10:00:00')),
  ST_makePoint(126.72752, 45.78937, todouble(timestamp '2010-02-02 11:00:00'))));
 
select count(*) from mpseq_1345639_traj where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_3DMakeBox(ST_makePoint(108.45223, 22.91412,todouble(timestamp '2010-02-02 10:00:00')),
  ST_makePoint(126.72752, 45.78937, todouble(timestamp '2010-02-02 11:00:00'))));


 select todouble(timestamp '2008-02-02 10:00:00');