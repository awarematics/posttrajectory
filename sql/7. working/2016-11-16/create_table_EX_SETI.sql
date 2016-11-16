select * from mpseq_SETI_traj_v100k;
select * from mpseq_SETI_traj_v300k;
select * from mpseq_SETI_traj_v500k;
select * from mpseq_SETI_traj_v700k;
select * from mpseq_SETI_traj_v900k;


CREATE TABLE public.mpseq_SETI_traj_v100k
(
  mpid integer,
  segid integer,
  next_segid integer,
  before_segid integer,
  mpcount integer,
  rect box2d,
  start_time timestamp without time zone,
  end_time timestamp without time zone,
  tpseg tpoint[]
)
WITH (
  OIDS=FALSE
);


CREATE TABLE public.mpseq_SETI_traj_v300k
(
  mpid integer,
  segid integer,
  next_segid integer,
  before_segid integer,
  mpcount integer,
  rect box2d,
  start_time timestamp without time zone,
  end_time timestamp without time zone,
  tpseg tpoint[]
)
WITH (
  OIDS=FALSE
);



CREATE TABLE public.mpseq_SETI_traj_v500k
(
  mpid integer,
  segid integer,
  next_segid integer,
  before_segid integer,
  mpcount integer,
  rect box2d,
  start_time timestamp without time zone,
  end_time timestamp without time zone,
  tpseg tpoint[]
)
WITH (
  OIDS=FALSE
);



CREATE TABLE public.mpseq_SETI_traj_v700k
(
  mpid integer,
  segid integer,
  next_segid integer,
  before_segid integer,
  mpcount integer,
  rect box2d,
  start_time timestamp without time zone,
  end_time timestamp without time zone,
  tpseg tpoint[]
)
WITH (
  OIDS=FALSE
);


CREATE TABLE public.mpseq_SETI_traj_v900k
(
  mpid integer,
  segid integer,
  next_segid integer,
  before_segid integer,
  mpcount integer,
  rect box2d,
  start_time timestamp without time zone,
  end_time timestamp without time zone,
  tpseg tpoint[]
)
WITH (
  OIDS=FALSE
);
