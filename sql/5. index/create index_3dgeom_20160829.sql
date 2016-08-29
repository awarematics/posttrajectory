
CREATE INDEX gist_3dgeom_mpseq_2124049_traj
 ON mpseq_2124049_traj
  USING gist(ptraj_index_to3dgeom(geometry(rect), start_time, end_time) gist_geometry_ops_nd);

