DROP INDEX public.gist_3dgeom_mpseq_notseti_traj_v100k;

CREATE INDEX gist_3dgeom_mpseq_notseti_traj_v100k
  ON public.mpseq_notseti_traj_v100k
  USING gist
  (ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time) gist_geometry_ops_nd);

select mpid, segid, tpseg[1].ts, start_time, end_time, tpseg[array_length(tpseg, 1)].ts from mpseq_notseti_traj_v100k; 

select ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time) from mpseq_notseti_traj_v100k where mpid=2 and segid =1; 

select mpid, segid, tpseg[1].ts, start_time, end_time, tpseg[mpcount].ts, mpcount from mpseq_notseti_traj_v100k where mpid=1748 and segid =1; 

update mpseq_notseti_traj_v100k set end_time = tpseg[mpcount].ts;


select array_length(tpseg, 1) from mpseq_notseti_traj_v100k;


mpseq_1875286_traj

select mpid, segid, tpseg[1].ts, start_time, end_time, tpseg[mpcount].ts from mpseq_1875286_traj where mpid=1 and segid =1; 

update mpseq_1875286_traj set end_time = end_time + time '00:01' where mpid = 1 and segid =1;

"2008-02-02 16:51:09"

select mpid, segid, st_astext(tpseg[1].pnt), tpseg[1].ts, start_time, end_time, tpseg[mpcount].ts, mpcount, array_length(tpseg, 1)  from mpseq_notseti_traj_v100k where mpid=1748 and segid =1; 

select mpid, segid, st_astext(tpseg[1].pnt), tpseg[1].ts, tpseg  from mpseq_notseti_traj_v100k where mpid=1748 and segid =1; 

select mpid, segid, st_astext(tpseg[1].pnt), tpseg[1].ts, end_time, tpseg[mpcount].ts, mpcount from mpseq_notseti_traj_v100k where tpseg[mpcount] is null;