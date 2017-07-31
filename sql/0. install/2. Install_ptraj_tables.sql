
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
