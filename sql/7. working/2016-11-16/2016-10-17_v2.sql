
-- total
select count(*) from mpseq_seti_traj_v900k
 where TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(126.72752, 45.78937)))); 


select * from mpseq_seti_traj_v900k
 where TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(126.72752, 45.78937)))); 
 

-- 1/2 bottom
select count(*) from mpseq_seti_traj_v900k
 where TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))); 


select * from mpseq_seti_traj_v900k
 where TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))); 


-- 1/2 top
select count(*) from mpseq_seti_traj_v900k
 where TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(117.589875, 34.351745), ST_Point(126.72752, 45.78937)))); 


select * from mpseq_seti_traj_v900k
 where TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(117.589875, 34.351745), ST_Point(126.72752, 45.78937)))); 
 

select * from (select * from getQuery_Condition_cells(geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(126.72752, 45.78937))))) as cond
 where TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))); 


select count(*) from (select * from getQuery_Condition_cells(geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(110.7366413, 25.77352625))))) as cond
 where TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(110.7366413, 25.77352625)))); 


select count(*) from (select * from getQuery_Condition_cells(geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(110.7366413, 25.77352625))))) as cond
 where TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(110.7366413, 25.77352625)))); 


 ST_Point(108.45223, 22.91412), ST_Point(126.72752, 45.78937)

 ST_Point(108.45223, 22.91412), ST_Point(109.5944356, 24.34382313)

 ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)