
CREATE INDEX gist_3dgeom_mpseq_2368582_traj
 ON mpseq_2368582_traj
  USING gist(ptraj_index_to3dgeom(rect, start_time, end_time) gist_geometry_ops_nd);

