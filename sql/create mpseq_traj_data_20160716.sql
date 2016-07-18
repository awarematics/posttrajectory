-- Table: public.mpseq_traj_data

-- DROP TABLE public.mpseq_traj_data;

CREATE TABLE public.mpseq_traj_data
(
  id bigserial,
  carnumber char(100),  
  mpcount integer,
  rect geometry,
  tpseg tpoint[]
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.mpseq_traj_data
  OWNER TO postgres;
