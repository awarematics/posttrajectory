select * from mpseq_1101121_traj where TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(126.72752, 45.78937)))); 

-- 전체 사이즈
select count(*) from mpseq_1101121_traj where TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(126.72752, 45.78937))))

-- 1 사이즈
select count(*) from mpseq_1101121_traj where TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745))))

-- 2 사이즈
select count(*) from mpseq_1101121_traj where TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(117.589875, 34.351745), ST_Point(126.72752, 45.78937))))

-- 3 사이즈
select count(*) from mpseq_1101121_traj where TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 34.351745), ST_Point(117.589875, 45.78937))))

-- 4 사이즈
select count(*) from mpseq_1101121_traj where TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(117.589875, 22.91412), ST_Point(126.72752, 34.351745))))

select * from mpseq_1101121_traj where mpcount = 1;



select count(*) from mpseq_1101138_traj where TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(109.5944356, 24.34382313))));



select count(*) from mpseq_1101138_traj where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(109.5944356, 24.34382313)))
  and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(109.5944356, 24.34382313)))); 
