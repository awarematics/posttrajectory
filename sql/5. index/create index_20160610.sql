

-- Get geometry(linestring) from tpoint Array
CREATE INDEX mpseq_1074501_traj_3dgist2
 ON mpseq_1074501_traj
  USING gist(tparr_to_3dgeom(tpseg) gist_geometry_ops_nd) where mpid=1 and segid=1;;  



select st_xmin(rect) from mpseq_1074501_traj;