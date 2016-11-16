CREATE INDEX gist_3dgeom_mpseq_notseti_traj_v100k
  ON public.mpseq_notseti_traj_v100k
  USING gist
  (ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time) gist_geometry_ops_nd);


CREATE INDEX gist_3dgeom_mpseq_notseti_traj_v300k
  ON public.mpseq_notseti_traj_v300k
  USING gist
  (ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time) gist_geometry_ops_nd);


CREATE INDEX gist_3dgeom_mpseq_notseti_traj_v500k
  ON public.mpseq_notseti_traj_v500k
  USING gist
  (ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time) gist_geometry_ops_nd);


CREATE INDEX gist_3dgeom_mpseq_notseti_traj_v700k
  ON public.mpseq_notseti_traj_v700k
  USING gist
  (ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time) gist_geometry_ops_nd);


CREATE INDEX gist_3dgeom_mpseq_notseti_traj_v900k
  ON public.mpseq_notseti_traj_v900k
  USING gist
  (ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time) gist_geometry_ops_nd);