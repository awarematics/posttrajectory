select * from mpseq_1875286_traj;

"BOX(115.762346 38.926795,117.589875 41.21432)"

select count(*) from mpseq_1875286_traj where geometry(rect) && geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589, 39.351745)));

select count(*) from mpseq_1875286_traj where
  TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))); 

-- Index
select count(*) from mpseq_1875286_traj where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))
  and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))); 


select count(*) from mpseq_1875286_traj where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(126.72752, 45.78937)))
  and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(126.72752, 45.78937)))); 


select count(*) from mpseq_1875286_traj;
select count(*) from mpseq_1875286_traj where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_3DMakeBox(ST_makePoint(108.45223, 22.91412,todouble(timestamp without time zone '2010-02-01 10:00:00')),
  ST_makePoint(126.72752, 45.78937, todouble(timestamp without time zone '2010-02-20 11:00:00'))))
   and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(126.72752, 45.78937)))); 




select count(*) from mpseq_1875286_traj where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(126.72752, 45.78937)))
  and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))); 


select count(*) from mpseq_1875286_traj where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))
  and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))); 