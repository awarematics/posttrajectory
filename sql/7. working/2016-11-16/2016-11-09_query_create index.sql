

-- 100k, 300k, 500k, 700k, 900k

-- DROP INDEX public.gist_3dgeom_mpseq_1844374_traj;

CREATE INDEX gist_3dgeom_mpseq_1844374_traj
  ON public.mpseq_1844374_traj
  USING gist
   (make_3dpolygon(rect, start_time, end_time) gist_geometry_ops_nd);


-- DROP INDEX public.gist_3dgeom_mpseq_1844528_traj;

CREATE INDEX gist_3dgeom_mpseq_1844528_traj
  ON public.mpseq_1844528_traj
  USING gist
   (make_3dpolygon(rect, start_time, end_time) gist_geometry_ops_nd);


-- DROP INDEX public.gist_3dgeom_mpseq_1844545_traj;

CREATE INDEX gist_3dgeom_mpseq_1844545_traj
  ON public.mpseq_1844545_traj
  USING gist
   (make_3dpolygon(rect, start_time, end_time) gist_geometry_ops_nd);


-- DROP INDEX public.gist_3dgeom_mpseq_1844562_traj;

CREATE INDEX gist_3dgeom_mpseq_1844562_traj
  ON public.mpseq_1844562_traj
  USING gist
   (make_3dpolygon(rect, start_time, end_time) gist_geometry_ops_nd);


-- DROP INDEX public.gist_3dgeom_mpseq_1844579_traj;

CREATE INDEX gist_3dgeom_mpseq_1844579_traj
  ON public.mpseq_1844579_traj
  USING gist
   (make_3dpolygon(rect, start_time, end_time) gist_geometry_ops_nd);




-- 200k, 400k, 600k, 800k, 1000k

-- DROP INDEX public.gist_3dgeom_mpseq_1875286_traj;

CREATE INDEX gist_3dgeom_mpseq_1875286_traj
  ON public.mpseq_1875286_traj
  USING gist
   (make_3dpolygon(rect, start_time, end_time) gist_geometry_ops_nd);


-- DROP INDEX public.gist_3dgeom_mpseq_1875303_traj;

CREATE INDEX gist_3dgeom_mpseq_1875303_traj
  ON public.mpseq_1875303_traj
  USING gist
   (make_3dpolygon(rect, start_time, end_time) gist_geometry_ops_nd);


-- DROP INDEX public.gist_3dgeom_mpseq_1875320_traj;

CREATE INDEX gist_3dgeom_mpseq_1875320_traj
  ON public.mpseq_1875320_traj
  USING gist
   (make_3dpolygon(rect, start_time, end_time) gist_geometry_ops_nd);


-- DROP INDEX public.gist_3dgeom_mpseq_1875337_traj;

CREATE INDEX gist_3dgeom_mpseq_1875337_traj
  ON public.mpseq_1875337_traj
  USING gist
   (make_3dpolygon(rect, start_time, end_time) gist_geometry_ops_nd);

  
-- DROP INDEX public.gist_3dgeom_mpseq_1875354_traj;

CREATE INDEX gist_3dgeom_mpseq_1875354_traj
  ON public.mpseq_1875354_traj
  USING gist
   (make_3dpolygon(rect, start_time, end_time) gist_geometry_ops_nd);