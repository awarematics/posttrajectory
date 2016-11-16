
select * from getQuery_Condition_cells(geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(110.7366413, 25.77352625))));

-- result : 199

select * from (select * from getQuery_Condition_cells(geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(110.7366413, 25.77352625))))) as cond
 where TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(110.7366413, 25.77352625)))); 

-- result : 195

select * from mpseq_1101121_traj
 where TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(110.7366413, 25.77352625)))); 

-- result : 592



"ptraj.cell_1 = 'Point(108.45223 22.91412),Point(110.279759 25.201645)'"
"ptraj.cell_2 = 'Point(108.45223 25.201645),Point(110.279759 27.48917)'"
"ptraj.cell_11 = 'Point(110.279759 22.91412),Point(112.107288 25.201645)'"
"ptraj.cell_12 = 'Point(110.279759 25.201645),Point(112.107288 27.48917)'"



"BOX(108.45223 22.91412,110.279759 25.201645)"


"BOX(115.762346 38.926795,117.589875 41.21432)"

select cellid(ST_MakeBox2D(ST_Point(115.762346, 38.926795), ST_Point(117.589875, 41.21432)));