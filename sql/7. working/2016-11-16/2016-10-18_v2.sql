
select * from getQuery_Condition_cells(geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(110.7366413, 25.77352625))));

select * from (select * from getQuery_Condition_cells(geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(110.7366413, 25.77352625))))) as cond
 where TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(110.7366413, 25.77352625)))); 

select * from mpseq_1101121_traj
 where TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(110.7366413, 25.77352625)))); 

select * from mpseq_1101121_traj where (cellid(rect) = 1 OR cellid(rect) = 2 OR cellid(rect) = 11 OR cellid(rect) = 12)
 and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(110.7366413, 25.77352625)))); ;

select * from mpseq_1101121_traj where TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(110.7366413, 25.77352625))));