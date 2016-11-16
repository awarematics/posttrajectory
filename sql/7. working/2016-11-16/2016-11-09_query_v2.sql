select count(*) from mpseq_notseti_traj_v100k;


select count(*) from mpseq_notseti_traj_v100k where
  TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))); 

select * from mpseq_notseti_traj_v100k order by mpid limit 5;

select * from mpseq_notseti_traj_v100k where
  TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))); 


-- Index

select count(*) from mpseq_notseti_traj_v100k where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))
  and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))); 


select count(*) from mpseq_notseti_traj_v100k where TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745))))
and ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745))); 


select count(*) from mpseq_notseti_traj_v100k where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& geometry(ST_3DMakeBox(ST_makePoint(108.45223, 22.91412 ,todouble(timestamp '2010-02-02 10:00:00')),
  ST_makePoint(117.589875, 34.351745, todouble(timestamp '2010-02-09 11:00:00'))))
and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))); 


select count(*) from taxi 
 where Post_Traj_passes_seg(taxi.traj, st_geomfromtext('polygon((116.44989 39.86646,116.44989 39.87334,118.47135 39.87334,118.47135 39.86646,116.44989 39.86646))'))
