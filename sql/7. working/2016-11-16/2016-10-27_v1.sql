

select st_astext(tpseg[1].pnt), rect from mpseq_1101121_traj
 where mpid = 1 and segid = 18 and ST_Intersects(tpseg[4].pnt, rect); 


select st_astext(tpseg[1].pnt), rect from mpseq_1101121_traj
 where mpid = 1 and segid = 18; 

"POINT(116.45804 39.86973)"
"POINT(116.45828 39.8697)"

select * from mpseq_1101121_traj
 where seti_passes(rect, tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(110.7366413, 25.77352625)))); 

 
select * from mpseq_1101121_traj
 where seti_passes(rect, tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(110.7366413, 25.77352625)))) and mpid = 1 and segid = 17; 


"POINT(116.45804 39.86973)"
"POINT(116.45828 39.8697)"




"BOX(115.762346 38.926795,117.589875 41.21432)"

"POINT(116.43787 39.92043)"