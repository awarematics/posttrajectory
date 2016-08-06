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




-- TABLE trajectory_columns 정의 --
CREATE TABLE trajectory_columns
(
	f_table_catalog character varying(256) NOT NULL,
	f_table_schema character varying(256) NOT NULL,
	f_table_name character varying(256) NOT NULL,
	f_trajectory_column character varying(256) NOT NULL,
	f_trajectory_segtable_name character varying(256) NOT NULL,
	trajectory_compress character varying(256),
	coord_dimension integer,
	srid integer,
	"type" character varying(30),
	f_segtableoid character varying(256) NOT NULL,
	f_sequence_name character varying(256) NOT NULL,
	tpseg_size	integer
)
WITH (
  OIDS=TRUE
);


--- 테스트용 데이터

create table taxi(
	taxi_id integer,
	taxi_number varchar,
	taxi_model varchar,
	taxi_driver varchar
);

-- 컬럼 추가
select addtrajectorycolumn('public', 'taxi', 'traj', 4326, 'MOVINGPOINT', 2, 150);
