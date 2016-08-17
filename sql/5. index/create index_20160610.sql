

-- Get geometry(linestring) from tpoint Array
CREATE INDEX mpseq_347630_traj_gist
 ON mpseq_347630_traj
  USING gist(tpArr_to_geom(tpseg) gist_geometry_ops_2d);  

