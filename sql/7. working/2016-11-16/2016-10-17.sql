ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(110.7366413, 25.77352625))

select cell_lookup(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(110.7366413, 25.77352625)));

select * from mpseq_1101121_traj where (cellid(rect) = 1 OR cellid(rect) = 2 OR cellid(rect) = 11 OR cellid(rect) = 12)
 and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(110.7366413, 25.77352625)))); ;

select * from mpseq_1101121_traj where TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(110.7366413, 25.77352625))));

select * from mpseq_1101121_traj where (cellid(rect) = 1 OR cellid(rect) = 2 OR cellid(rect) = 11 OR cellid(rect) = 12)


-- Total Set
select * from mpseq_seti_traj_v500k
 where TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))); 


select * from mpseq_seti_traj_v500k
 where TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))); 



select * from getQuery_Condition_cells(geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745))));

select * from (select * from getQuery_Condition_cells(geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745))))) as cond
 where TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))); 


(cellid(rect) = 1 OR cellid(rect) = 2 OR cellid(rect) = 3 OR cellid(rect) = 4 OR cellid(rect) = 5 OR cellid(rect) = 6 OR cellid(rect) = 11 OR cellid(rect) = 12 OR cellid(rect) = 13 OR cellid(rect) = 14 OR cellid(rect) = 15 OR cellid(rect) = 16 OR cellid(rect) = 21 OR cellid(rect) = 22 OR cellid(rect) = 23 OR cellid(rect) = 24 OR cellid(rect) = 25 OR cellid(rect) = 26 OR cellid(rect) = 31 OR cellid(rect) = 32 OR cellid(rect) = 33 OR cellid(rect) = 34 OR cellid(rect) = 35 OR cellid(rect) = 36 OR cellid(rect) = 41 OR cellid(rect) = 42 OR cellid(rect) = 43 OR cellid(rect) = 44 OR cellid(rect) = 45 OR cellid(rect) = 46 OR cellid(rect) = 51 OR cellid(rect) = 52 OR cellid(rect) = 53 OR cellid(rect) = 54 OR cellid(rect) = 55 OR cellid(rect) = 56)


select * from mpseq_seti_traj_v500k where (cellid(rect) = 1 OR cellid(rect) = 2 OR cellid(rect) = 3 OR cellid(rect) = 4 OR cellid(rect) = 5 OR cellid(rect) = 6 OR cellid(rect) = 11 OR cellid(rect) = 12 OR cellid(rect) = 13 OR cellid(rect) = 14 OR cellid(rect) = 15 OR cellid(rect) = 16 OR cellid(rect) = 21 OR cellid(rect) = 22 OR cellid(rect) = 23 OR cellid(rect) = 24 OR cellid(rect) = 25 OR cellid(rect) = 26 OR cellid(rect) = 31 OR cellid(rect) = 32 OR cellid(rect) = 33 OR cellid(rect) = 34 OR cellid(rect) = 35 OR cellid(rect) = 36 OR cellid(rect) = 41 OR cellid(rect) = 42 OR cellid(rect) = 43 OR cellid(rect) = 44 OR cellid(rect) = 45 OR cellid(rect) = 46 OR cellid(rect) = 51 OR cellid(rect) = 52 OR cellid(rect) = 53 OR cellid(rect) = 54 OR cellid(rect) = 55 OR cellid(rect) = 56)
 or TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))); 

 "BOX(115.762346 38.926795,117.589875 41.21432)"
 "BOX(115.762346 38.926795,117.589875 41.21432)"
 "BOX(115.762346 38.926795,117.589875 41.21432)"
 "BOX(119.417404 38.926795,121.244933 41.21432)"
 "BOX(115.762346 38.926795,117.589875 41.21432)"
 