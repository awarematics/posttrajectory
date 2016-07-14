-- Table: public.mpseq_527042_traj

-- DROP TABLE public.mpseq_527042_traj;

CREATE TABLE public.mpseq_527042_traj
(
  mpid integer,
  segid integer,
  next_segid integer,
  before_segid integer,
  mpcount integer,
  rect box2d,
  rect_geom geometry,
  start_time timestamp with time zone,
  end_time timestamp with time zone,
  tpseg tpoint[]
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.mpseq_527042_traj
  OWNER TO postgres;
ALTER TABLE public.mpseq_527042_traj ALTER COLUMN tpseg SET STORAGE EXTERNAL;



-- Table: public.partition_info

-- DROP TABLE public.partition_info;

CREATE TABLE public.partition_info
(
  id integer,
  partition box2d
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.partition_info
  OWNER TO postgres;
