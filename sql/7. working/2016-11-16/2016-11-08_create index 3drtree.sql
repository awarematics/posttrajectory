CREATE INDEX gist_3dgeom_mpseq_1875286_traj
  ON public.mpseq_1875286_traj
  USING gist
  (ptraj_index_to3dgeom(rect, start_time, end_time) gist_geometry_ops_nd);

CREATE INDEX gist_3dgeom_mpseq_1875303_traj
  ON public.mpseq_1875303_traj
  USING gist
  (ptraj_index_to3dgeom(rect, start_time, end_time) gist_geometry_ops_nd);


CREATE INDEX gist_3dgeom_mpseq_1875320_traj
  ON public.mpseq_1875320_traj
  USING gist
  (ptraj_index_to3dgeom(rect, start_time, end_time) gist_geometry_ops_nd);



CREATE INDEX gist_3dgeom_mpseq_1875337_traj
  ON public.mpseq_1875337_traj
  USING gist
  (ptraj_index_to3dgeom(rect, start_time, end_time) gist_geometry_ops_nd);



CREATE INDEX gist_3dgeom_mpseq_1875354_traj
  ON public.mpseq_1875354_traj
  USING gist
  (ptraj_index_to3dgeom(rect, start_time, end_time) gist_geometry_ops_nd);










select sum(mpcount) from mpseq_1875286_traj;

select sum(mpcount) from mpseq_1875303_traj;

select sum(mpcount) from mpseq_1875320_traj;

select sum(mpcount) from mpseq_1875337_traj;

select sum(mpcount) from mpseq_1875354_traj;