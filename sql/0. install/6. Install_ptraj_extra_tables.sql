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


-- Table: public.static_partition

-- DROP TABLE public.static_partition;

CREATE TABLE public.static_partition
(
  id integer,
  partition box2d
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.static_partition
  OWNER TO postgres;
  

--- 테스트용 데이터

create table taxi(
	taxi_id integer,
	taxi_number varchar,
	taxi_model varchar,
	taxi_driver varchar
);  
