
-- TYPE tpoint 정의 --
CREATE TYPE tpoint as(
	pnt	geometry,			-- Point type
	ts	timestamp with time zone	-- Timestamp type
);


-- TYPE trajectory 정의 --
CREATE TYPE trajectory as(
	segtableoid	oid,
	moid		integer	
);


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


-- tpoint[]를 받아서 box2d(geometry)를 리턴해준다.
CREATE OR REPLACE FUNCTION getBox2D(tpoint[]) RETURNS geometry AS
$$
DECLARE
	array_tpoint	alias for $1;
	array_max	integer;
	array_lower	integer;	
	i		integer;
	new_rect	geometry;
BEGIN
	EXECUTE 'select array_upper($1, 1)'
	INTO array_max USING array_tpoint;

	EXECUTE 'select array_lower($1, 1)'
	INTO array_lower USING array_tpoint;

	i := array_lower;

	EXECUTE 'select st_makebox2d($1, $1)::geometry'
	INTO new_rect USING array_tpoint[i].pnt;

	i := i+1;

	WHILE( i <= array_max ) LOOP
		EXECUTE 'select st_combine_bbox($1::box2d, $2)::geometry'
		INTO new_rect USING new_rect, array_tpoint[i].pnt;
		i := i+1;
	END LOOP;

	RETURN new_rect;

END
$$
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION delete_mpoint_seg() RETURNS trigger AS $delete_mpoint_seg$
DECLARE
	segtable_name		text;
	column_name		text;
	delete_trajectory	trajectory;
	delete_id		integer;

	delete_record		record;
	
    BEGIN
	execute 'select f_trajectory_segtable_name from trajectory_columns where f_table_name = ' || quote_literal(TG_RELNAME)
	into segtable_name;

	execute 'select f_trajectory_column from trajectory_columns where f_table_name = ' || quote_literal(TG_RELNAME)
	into column_name;

	-- traj값 가져오는부분 수정해야함.
	delete_record := OLD;

	/*
	execute 'select ' || column_name || ' from ' || delete_record
	into delete_trajectory;
	*/
	
	delete_trajectory := OLD.traj;
	delete_id := delete_trajectory.moid;
	
	execute 'DELETE FROM ' || quote_ident(segtable_name) || ' WHERE mpid = ' || delete_id;

	return NULL;

    END;
$delete_mpoint_seg$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION insert_trigger() RETURNS trigger AS $$
	# 해당 테이블의 이름을 가져온다.
	table_name = TD["table_name"]

	#segtable_oid를 가져온다. 
	plan = plpy.prepare("select f_segtableoid::oid from trajectory_columns where f_table_name = $1", ["text"])
	segtable_oid = plpy.execute(plan, [table_name])

	#segcolumn_name를 가져온다.
	plan = plpy.prepare("select f_trajectory_column::text from trajectory_columns where f_table_name = $1", ["text"])
	segcolumn_name = plpy.execute(plan, [table_name])

	#sequence_name를 가져온다.
	plan = plpy.prepare("select f_sequence_name from trajectory_columns where f_table_name = $1", ["text"])	
	sequence_name = plpy.execute(plan, [table_name])

	#sequence_name를 이용하여 삽입할 sequence를 결정한다.
	plan = plpy.prepare("select nextval($1)", ["text"])
	moid = plpy.execute(plan, [sequence_name[0]["f_sequence_name"]])

	#user maked column(trajectoryColumn)의 값을 삽입해준다.
	TD["new"][segcolumn_name[0]['f_trajectory_column']] = (int(segtable_oid[0]["f_segtableoid"]), int(moid[0]["nextval"]))
	
	#TD["new"][segcolumn_name[0]['f_trajectory_column']] = int(segtable_oid[0]["f_segtableoid"])
	#TD["new"] = {[segcolumn_name[0]['f_trajectory_column']]:int(segtable_oid[0]["f_segtableoid"])}
	
	return "MODIFY"
	
$$ LANGUAGE plpythonu;


-- AddTrajectoryColumn 함수 array 크기를 지정해주지 않는다.
CREATE OR REPLACE FUNCTION AddTrajectoryColumn(character varying, character varying, character varying, 
						integer, character varying, integer)
  RETURNS text AS
$BODY$
DECLARE
	f_schema_name 	alias for $1;
	f_table_name 	alias for $2;
	f_column_name 	alias for $3;
	srid		alias for $4;
	new_type 	alias for $5;
	dimension 	alias for $6;
	real_schema name;
	sql text;
	table_oid text;
	f_trajectory_segtable_name text;
	f_sequence_name	text;
	f_segtable_oid	oid;

BEGIN

	-- Verify geometry type
	IF ( NOT  (new_type = 'MOVINGPOINT') )
	THEN
		RAISE EXCEPTION 'Invalid type name - valid ones are:
		MOVINGPOINT';
		RETURN 'fail';
	END IF;

	--verify SRID
	
	-- Verify schema  테이블에 catalog_name & schema_name 추가
	IF ( f_schema_name IS NOT NULL AND f_schema_name != '' ) THEN
		sql := 'SELECT nspname FROM pg_namespace ' ||
			'WHERE text(nspname) = ' || quote_literal(f_schema_name) ||
			'LIMIT 1';
		RAISE DEBUG '%', sql;
		EXECUTE sql INTO real_schema;

		IF ( real_schema IS NULL ) THEN
			RAISE EXCEPTION 'Schema % is not a valid schemaname', quote_literal(f_schema_name);
			RETURN 'fail';
		END IF;
	END IF;

	IF ( real_schema IS NULL ) THEN
		RAISE DEBUG 'Detecting schema';
		sql := 'SELECT n.nspname AS schemaname ' ||
			'FROM pg_catalog.pg_class c ' ||
			  'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace ' ||
			'WHERE c.relkind = ' || quote_literal('r') ||
			' AND n.nspname NOT IN (' || quote_literal('pg_catalog') || ', ' || quote_literal('pg_toast') || ')' ||
			' AND pg_catalog.pg_table_is_visible(c.oid)' ||
			' AND c.relname = ' || quote_literal(f_table_name);
		RAISE DEBUG '%', sql;
		EXECUTE sql INTO real_schema;

		IF ( real_schema IS NULL ) THEN
			RAISE EXCEPTION 'Table % does not occur in the search_path', quote_literal(f_table_name);
			RETURN 'fail';
		END IF;
	END IF;

	-- 삽입될 테이블의 OID를 알아본다.
	sql := 'select '|| quote_literal(f_table_name) ||'::regclass::oid';
	RAISE DEBUG '%', sql;
	EXECUTE sql INTO table_oid;


	f_sequence_name = quote_ident(f_table_name) || '_' || quote_ident(f_column_name) || '_mpointid_seq';

	-- 시퀀스 삽입전 기존에 만든 시퀀스 삭제(배포버젼에서는 삭제 해야함)
	--drop SEQUENCE taxi_traj_mpointid_seq;
	-- user maked table의 mpoint 컬럼에 자동증가속성을 부여해준다.
	sql := 'CREATE SEQUENCE ' || quote_ident(f_sequence_name) || ' START 1';
	RAISE DEBUG '%', sql;
	EXECUTE sql;

	-- Add trajectory column to table
	sql := 'ALTER TABLE ' || quote_ident(f_table_name) || 
		' ADD ' || quote_ident(f_column_name) || ' trajectory';
	RAISE DEBUG '%', sql;
	EXECUTE sql;	


	-- Delete stale record in geometry_columns (if any)
	sql := 'DELETE FROM trajectory_columns WHERE
		f_table_name = ' || quote_literal(f_table_name) ||
		' AND f_trajectory_column = ' || quote_literal(f_column_name);
	RAISE DEBUG '%', sql;
	EXECUTE sql;

	sql := 'DELETE FROM trajectory_columns WHERE
		f_table_catalog = ' || quote_literal('') ||
		' AND f_table_schema = ' ||quote_literal(real_schema) ||
		' AND f_table_name = ' || quote_literal(f_table_name) ||
		' AND f_trajectory_column = ' || quote_literal(f_column_name);
	RAISE DEBUG '%', sql;
	EXECUTE sql;

	

	f_trajectory_segtable_name := 'mpseq_' || table_oid || '_' || f_column_name;

	
	--table_name의 column_name을 위한 mppsegtable 생성
	EXECUTE 'CREATE TABLE ' || f_trajectory_segtable_name || ' 
		(
			mpid		integer,
			segid		integer,
			next_segid	integer,
			before_segid	integer,
			mpcount		integer,
			rect		geometry,
			start_time	timestamp with time zone,
			end_time	timestamp with time zone,
			tpseg		tpoint[]
		)';

--	execute pg_sleep(1);
	
	sql := 'select '|| quote_literal(f_trajectory_segtable_name) ||'::regclass::oid';
	RAISE DEBUG '%', sql;
	EXECUTE sql INTO f_segtable_oid;

	-- Add record in geometry_columns  compress 추가 어떻게 할건지.
	sql := 'INSERT INTO trajectory_columns (f_table_catalog, f_table_schema, f_table_name, ' ||
			'f_trajectory_column, f_trajectory_segtable_name, coord_dimension, srid, type, '|| 
			'f_segtableoid, f_sequence_name)' ||
		' VALUES (' ||
		quote_literal('') || ',' ||
		quote_literal(real_schema) || ',' ||
		quote_literal(f_table_name) || ',' ||
		quote_literal(f_column_name) || ',' ||
		quote_literal(f_trajectory_segtable_name) || ',' || 
		dimension::text || ',' ||
		srid::text || ',' ||
		quote_literal(new_type) || ', ' ||
		quote_literal(f_segtable_oid) || ', ' ||
		quote_literal(f_sequence_name) || ')';
	RAISE DEBUG '%', sql;
	EXECUTE sql;

	-- traj칼럽의 초기값을 설정
	sql := 'UPDATE ' || quote_ident(f_table_name)|| ' SET ' || quote_ident(f_column_name) || '.moid '
		|| '= NEXTVAL(' || quote_literal(f_sequence_name) ||'), ' || quote_ident(f_column_name) || '.segtableoid = ' || f_segtable_oid;
	RAISE DEBUG '%', sql;
	EXECUTE sql;



	EXECUTE 'CREATE TRIGGER insert_trigger 
		BEFORE INSERT ON ' || quote_ident(f_table_name) || ' FOR EACH ROW EXECUTE PROCEDURE insert_trigger()';


	
	EXECUTE 'CREATE TRIGGER delete_mpoint_seg 
		AFTER DELETE ON ' || quote_ident(f_table_name) || ' FOR EACH ROW EXECUTE PROCEDURE delete_mpoint_seg()';



	RETURN
		real_schema || '.' ||
		f_table_name || '.' || f_column_name ||
		' SRID:' || srid::text ||
		' TYPE:' || new_type ||
		' DIMS:' || dimension::text || ' ';

END;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE STRICT
  COST 100;
ALTER FUNCTION AddTrajectoryColumn(character varying, character varying, character varying, integer, character varying, integer) OWNER TO postgres;
COMMENT ON FUNCTION AddTrajectoryColumn(character varying, character varying, character varying, integer, character varying, integer) IS 
					'args: schema_name, table_name, column_name, srid, type, dimentrion';


-- AddTrajectoryColumn 함수 tpseg 크기를 지정해줘야 한다.
CREATE OR REPLACE FUNCTION AddTrajectoryColumn(character varying, character varying, character varying, 
						integer, character varying, integer, integer)
  RETURNS text AS
$BODY$
DECLARE
	f_schema_name 	alias for $1;
	f_table_name 	alias for $2;
	f_column_name 	alias for $3;
	srid		alias for $4;
	new_type 	alias for $5;
	dimension 	alias for $6;
	tpseg_size	alias for $7;
	real_schema name;
	sql text;
	table_oid text;
	f_trajectory_segtable_name text;
	f_sequence_name	text;
	f_segtable_oid	oid;

BEGIN

	-- Verify geometry type
	IF ( NOT  (new_type = 'MOVINGPOINT') )
	THEN
		RAISE EXCEPTION 'Invalid type name - valid ones are:
		MOVINGPOINT';
		RETURN 'fail';
	END IF;

	--verify SRID
	

	-- Verify schema  테이블에 catalog_name & schema_name 추가
	IF ( f_schema_name IS NOT NULL AND f_schema_name != '' ) THEN
		sql := 'SELECT nspname FROM pg_namespace ' ||
			'WHERE text(nspname) = ' || quote_literal(f_schema_name) ||
			'LIMIT 1';
		RAISE DEBUG '%', sql;
		EXECUTE sql INTO real_schema;

		IF ( real_schema IS NULL ) THEN
			RAISE EXCEPTION 'Schema % is not a valid schemaname', quote_literal(f_schema_name);
			RETURN 'fail';
		END IF;
	END IF;

	IF ( real_schema IS NULL ) THEN
		RAISE DEBUG 'Detecting schema';
		sql := 'SELECT n.nspname AS schemaname ' ||
			'FROM pg_catalog.pg_class c ' ||
			  'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace ' ||
			'WHERE c.relkind = ' || quote_literal('r') ||
			' AND n.nspname NOT IN (' || quote_literal('pg_catalog') || ', ' || quote_literal('pg_toast') || ')' ||
			' AND pg_catalog.pg_table_is_visible(c.oid)' ||
			' AND c.relname = ' || quote_literal(f_table_name);
		RAISE DEBUG '%', sql;
		EXECUTE sql INTO real_schema;

		IF ( real_schema IS NULL ) THEN
			RAISE EXCEPTION 'Table % does not occur in the search_path', quote_literal(f_table_name);
			RETURN 'fail';
		END IF;
	END IF;

	-- 삽입될 테이블의 OID를 알아본다.
	sql := 'select '|| quote_literal(f_table_name) ||'::regclass::oid';
	RAISE DEBUG '%', sql;
	EXECUTE sql INTO table_oid;


	f_sequence_name = quote_ident(f_table_name) || '_' || quote_ident(f_column_name) || '_mpointid_seq';

	-- 시퀀스 삽입전 기존에 만든 시퀀스 삭제(배포버젼에서는 삭제 해야함)
	--drop SEQUENCE taxi_traj_mpointid_seq;
	-- user maked table의 mpoint 컬럼에 자동증가속성을 부여해준다.
	sql := 'CREATE SEQUENCE ' || quote_ident(f_sequence_name) || ' START 1';
	RAISE DEBUG '%', sql;
	EXECUTE sql;

	-- Add trajectory column to table
	sql := 'ALTER TABLE ' || quote_ident(f_table_name) || 
		' ADD ' || quote_ident(f_column_name) || ' trajectory';
	RAISE DEBUG '%', sql;
	EXECUTE sql;	


	-- Delete stale record in geometry_columns (if any)
	sql := 'DELETE FROM trajectory_columns WHERE
		f_table_name = ' || quote_literal(f_table_name) ||
		' AND f_trajectory_column = ' || quote_literal(f_column_name);
	RAISE DEBUG '%', sql;
	EXECUTE sql;

	sql := 'DELETE FROM trajectory_columns WHERE
		f_table_catalog = ' || quote_literal('') ||
		' AND f_table_schema = ' ||quote_literal(real_schema) ||
		' AND f_table_name = ' || quote_literal(f_table_name) ||
		' AND f_trajectory_column = ' || quote_literal(f_column_name);
	RAISE DEBUG '%', sql;
	EXECUTE sql;
	

	f_trajectory_segtable_name := 'mpseq_' || table_oid || '_' || f_column_name;

	
	--table_name의 column_name을 위한 mppsegtable 생성
	EXECUTE 'CREATE TABLE ' || f_trajectory_segtable_name || ' 
		(
			mpid		integer,
			segid		integer,
			next_segid	integer,
			before_segid	integer,
			mpcount		integer,
			rect		geometry,
			start_time	timestamp with time zone,
			end_time	timestamp with time zone,
			tpseg		tpoint[]
		)';

--	execute pg_sleep(1);

	EXECUTE 'ALTER TABLE ' || f_trajectory_segtable_name || '
		ALTER COLUMN tpseg SET STORAGE EXTERNAL';
	
	sql := 'select '|| quote_literal(f_trajectory_segtable_name) ||'::regclass::oid';
	RAISE DEBUG '%', sql;
	EXECUTE sql INTO f_segtable_oid;

	-- Add record in geometry_columns  compress 추가 어떻게 할건지.
	sql := 'INSERT INTO trajectory_columns (f_table_catalog, f_table_schema, f_table_name, ' ||
			'f_trajectory_column, f_trajectory_segtable_name, coord_dimension, srid, type, '|| 
			'f_segtableoid, f_sequence_name, tpseg_size)' ||
		' VALUES (' ||
		quote_literal('') || ',' ||
		quote_literal(real_schema) || ',' ||
		quote_literal(f_table_name) || ',' ||
		quote_literal(f_column_name) || ',' ||
		quote_literal(f_trajectory_segtable_name) || ',' || 
		dimension::text || ',' ||
		srid::text || ',' ||
		quote_literal(new_type) || ', ' ||
		quote_literal(f_segtable_oid) || ', ' ||
		quote_literal(f_sequence_name) || ', ' ||
		tpseg_size || ')';
	RAISE DEBUG '%', sql;
	EXECUTE sql;

	-- traj칼럽의 초기값을 설정
	sql := 'UPDATE ' || quote_ident(f_table_name)|| ' SET ' || quote_ident(f_column_name) || '.moid '
		|| '= NEXTVAL(' || quote_literal(f_sequence_name) ||'), ' || quote_ident(f_column_name) || '.segtableoid = ' || f_segtable_oid;
	RAISE DEBUG '%', sql;
	EXECUTE sql;


	EXECUTE 'CREATE TRIGGER insert_trigger 
		BEFORE INSERT ON ' || quote_ident(f_table_name) || ' FOR EACH ROW EXECUTE PROCEDURE insert_trigger()';

	
	EXECUTE 'CREATE TRIGGER delete_mpoint_seg 
		AFTER DELETE ON ' || quote_ident(f_table_name) || ' FOR EACH ROW EXECUTE PROCEDURE delete_mpoint_seg()';


	RETURN
		real_schema || '.' ||
		f_table_name || '.' || f_column_name ||
		' SRID:' || srid::text ||
		' TYPE:' || new_type ||
		' DIMS:' || dimension::text || ' ';

END;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE STRICT
  COST 100;
  
ALTER FUNCTION AddTrajectoryColumn(character varying, character varying, character varying, integer, character varying, integer) OWNER TO postgres;
COMMENT ON FUNCTION AddTrajectoryColumn(character varying, character varying, character varying, integer, character varying, integer) IS 
					'args: schema_name, table_name, column_name, srid, type, dimentrion';



/*
	두개 text를 받아서 tpoint 형으로 리턴해주는 함수
*/


CREATE OR REPLACE FUNCTION tpoint(geometry, timestamp) RETURNS tpoint AS
$$
DECLARE
	time_point	alias for $1;
	time_stamp	alias for $2;
	tp	tpoint;
BEGIN	
	tp.pnt := time_point;
	tp.ts := time_stamp;

	RETURN tp;
END
$$
  LANGUAGE 'plpgsql' VOLATILE STRICT
  COST 100;


CREATE OR REPLACE FUNCTION getTimeStamp(integer ) RETURNS timestamp AS
$$
DECLARE
	input_interval		alias for $1;

	base_time		TIMESTAMP with time zone;

	data_time		TIMESTAMP with time zone;

	text_interval		text;
	
BEGIN	
	
	base_time := '2010-01-01 12:00:00+9';
	text_interval := input_interval || ' minute';

	EXECUTE 'select TIMESTAMP ' || quote_literal(base_time)
	INTO base_time;
	

	EXECUTE 'select TIMESTAMP ' || quote_literal(base_time)  || ' + interval ' || quote_literal(text_interval)
	INTO data_time;

	RETURN data_time;
END
$$
LANGUAGE 'plpgsql' VOLATILE STRICT
COST 100;


/*
	trajcetory와 tpoint를 받아서 입력해주는 함수
*/

CREATE OR REPLACE FUNCTION append(trajectory, geometry, timestamp ) RETURNS trajectory AS
$$
DECLARE
	inpuut_trajectory	alias for $1;
	inpuut_geometry		alias for $2;
	input_time		alias for $3;
BEGIN
	execute 'select append( $1, tpoint( $2, $3 ) )'
	using inpuut_trajectory, inpuut_geometry, input_time;
END
$$
LANGUAGE 'plpgsql' VOLATILE STRICT
COST 100;



-- 인자값으로 tpoint의 array를 받는 append함수
CREATE OR REPLACE FUNCTION append(trajectory, tpoint[]) RETURNS trajectory AS
$$
DECLARE
	c_trajectory	alias for $1;
	array_tpoint	alias for $2;

	f_trajectory_segtable_name	text;
	f_table_name			text;
	array_size	integer;

	i		integer;
	sql		text;
BEGIN
	execute 'select array_upper( $1, 1)'
	into array_size using array_tpoint;

	i := 1;

	WHILE( i <= array_size ) LOOP
		execute 'select append( $1, $2[$3] )'
		using c_trajectory, array_tpoint, i;
		 i := i+1;
	END LOOP;

	RETURN c_trajectory;
END
$$
LANGUAGE 'plpgsql' VOLATILE STRICT
COST 100;


CREATE OR REPLACE FUNCTION append(trajectory, tpoint ) RETURNS trajectory AS
$BODY$
DECLARE
	f_trajectroy alias for $1;
	tp  alias for $2;
	f_trajectory_segtable_name text;
	table_oid text;
	mpid	integer;
	segid	integer;
	mp_count integer;
	sql	text;

	next_segid	integer;
	max_tpseg_count	integer;
	tp_seg_size	integer;

	--새로운 row로 데이터 삽입을 할때 segid값을 정하기 위한 변수
	new_segid	integer;
BEGIN

	sql := 'select relname from pg_catalog.pg_class c
		where c.oid = '|| f_trajectroy.segtableoid;
	RAISE DEBUG '%', sql;
	EXECUTE sql INTO f_trajectory_segtable_name;
	
	-- 현재 trajectory_segtable의 mpid값을 가져온다 
	sql := 'select mpid from ' || quote_ident(f_trajectory_segtable_name) || 
		' where mpid = ' || f_trajectroy.moid;
	RAISE DEBUG '%', sql;
	EXECUTE sql INTO mpid;

	sql := 'select tpseg_size from trajectory_columns ' ||
		' where f_trajectory_segtable_name = ' || quote_literal(f_trajectory_segtable_name);
	RAISE DEBUG '%', sql;
	EXECUTE sql INTO tp_seg_size;

	-- mpid가 최초로 삽입될 때
	IF ( mpid IS NULL) THEN
		-- mpid, segid, start_time, end_time, tpseg 삽입
		EXECUTE 'INSERT INTO ' || quote_ident(f_trajectory_segtable_name) ||'(mpid, segid, mpcount, rect, start_time, end_time, tpseg) 
			VALUES( $1 , 1, 1, st_makebox2d( $2, $2 ), TIMESTAMP '|| quote_literal(tp.ts) || '  , TIMESTAMP  '|| quote_literal(tp.ts) || 
			' , ARRAY[(  $2 , TIMESTAMP  '|| quote_literal(tp.ts) || ')]::tpoint[]) '
		USING f_trajectroy.moid, tp.pnt;
	END IF;
	-- 최초 삽입은 아닐때
	IF( mpid IS NOT NULL) THEN
		-- 삽입할 포인터의 row를 결정해 주어야 한다. 
		-- next_segid가 null이라면 마지막 seg이므로 이 row에 삽입을 하면된다.
		sql := 'select segid from ' || quote_ident(f_trajectory_segtable_name) ||
				' where mpid = ' || f_trajectroy.moid || ' and next_segid IS NULL';
		RAISE DEBUG '%', sql;
		EXECUTE sql INTO segid;

		-- tpseg가 꽉찼는지 확인하기 위하여 배열의 최대 크기를 가져온다
		sql := 'select array_upper((select tpseg from ' || quote_ident(f_trajectory_segtable_name) || 
			' where mpid = ' || f_trajectroy.moid || ' and segid = ' || segid || '), 1)';
		RAISE DEBUG '%', sql;
		EXECUTE sql INTO max_tpseg_count;
		
		-- next_segid가 null인 segid값이 있고 tpseg가 꽉 차지 않았다면 현재 segid값에 데이터를 삽입
		IF( segid IS NOT NULL AND max_tpseg_count < tp_seg_size) THEN-----조건문에 tpseg의 최대값을 넣어줘야함. 현재는 3
			EXECUTE 'UPDATE ' || quote_ident(f_trajectory_segtable_name) || 
				' set mpcount = mpcount+1, rect = st_combine_bbox( rect::box2d, $1), end_time = $2, tpseg = array_append(tpseg, $3) 
				where mpid = $4 and segid = $5 '
			USING tp.pnt, tp.ts, tp, mpid, segid;
		-- next_segid가 null이 아니거나 tpseg가 꽉 찾다면 새로운 segid를 생성하여 데이터를 삽입하여야 한다. 
		ELSE 
			-- next_segid가 null이 아니라면 새로운 row를 생성하여 삽입
			-- 삽입전 최대 segid값을 알아야 한다.
			EXECUTE 'select MAX(segid) from ' || quote_ident(f_trajectory_segtable_name) || ' where mpid = $1'
			INTO new_segid USING mpid;

			EXECUTE 'INSERT INTO ' || quote_ident(f_trajectory_segtable_name) ||'(mpid, segid, before_segid, mpcount, rect, start_time, end_time, tpseg) 
				VALUES( $1,  ' || new_segid+1 || ', $2, 1, st_makebox2d( $3, $3), TIMESTAMP ' || quote_literal(tp.ts) || ' , TIMESTAMP ' || quote_literal(tp.ts) ||
				' , ARRAY[( $3 , TIMESTAMP ' || quote_literal(tp.ts) || ')]::tpoint[])'
			USING f_trajectroy.moid, segid, tp.pnt;
			-- 새로운 segid값에 데이터를 삽입후 전에 사용하던 segid에 next_segid값을 설정해준다.
			EXECUTE 'UPDATE ' || quote_ident(f_trajectory_segtable_name) || 
				' set next_segid = ' || new_segid+1 || ' where mpid = $1 and segid = $2'
			USING mpid, segid;
				
		END IF;

	END IF;

	return
		f_trajectroy;

END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE STRICT
COST 100;
ALTER FUNCTION append(trajectory, tpoint) OWNER TO postgres;
COMMENT ON FUNCTION append(trajectory, tpoint) IS 'args: trajectory columl name, tpoint';


-- 삭제시 시작시간과 시간간격(초단위)을 입력하면 삭제를 해준다.
CREATE OR REPLACE FUNCTION remove(trajectory, timestamp, integer) RETURNS trajectory AS
$$
DECLARE
	c_trajectory	alias for $1;
	start_time	alias for $2;
	time_interval	alias for $3;
	end_time	TIMESTAMP with time zone;
	text_interval	text;
BEGIN
	text_interval := time_interval || ' seconds';
	EXECUTE 'select TIMESTAMP ' || quote_literal(start_time)  || ' + interval ' || quote_literal(text_interval)
	INTO end_time;

	EXECUTE 'select remove(' || c_trajectory || ', TIMESTAMP ' || quote_literal(start_time) ||
		', TIMESTAMP ' || quote_literal(end_time) || ')';
		
	RETURN c_trajectory;
END
$$
LANGUAGE 'plpgsql' ;


CREATE OR REPLACE FUNCTION remove(trajectory, timestamp, timestamp) RETURNS trajectory AS
$$
DECLARE
	c_trajectory 			alias for $1;
	start_time			alias for $2;
	end_time			alias for $3;
	result_tp			tpoint[];

	f_trajectory_segtable_name	text;
	data				RECORD;
	tpseg_data			tpoint[];
	sql				text;
	mpcount				integer;
	new_mpcount			integer;
	new_tpseg			tpoint[];
	new_tpoint			tpoint;

	i				integer;
	j				integer;
	tpseg_size			integer;

	--row가 삭제시 필요한 next_id와 before_segid를 읽어오기 위한 변수
	new_next_segid			integer;
	new_before_segid		integer;
	-- 새로운 rect를 위한 변수
	new_rect			geometry;

BEGIN
	sql := 'select relname from pg_catalog.pg_class c
		WHERE c.oid = '|| c_trajectory.segtableoid;
	RAISE DEBUG '%', sql;
	EXECUTE sql INTO f_trajectory_segtable_name;

	sql := 'select * from ' || quote_ident(f_trajectory_segtable_name) ||
		' WHERE mpid = '|| c_trajectory.moid;

	
	FOR data IN EXECUTE sql LOOP 
		j := 1;
		i := 1;
		mpcount := data.mpcount;
		result_tp := data.tpseg;
		-- 현재 row의 tpseg 크기를 가져온다.
		EXECUTE 'select array_upper( $1 , 1)' INTO tpseg_size USING data.tpseg;
		IF( ( data.start_time <= end_time ) AND ( data.end_time >= start_time ) ) THEN
			WHILE( i <=  tpseg_size ) LOOP
				-- 새로운 값이 들어갈 위치를 찾는다.
				IF( ( result_tp[i].ptime >= start_time ) AND ( result_tp[i].ptime <= end_time ) ) THEN
					EXECUTE 'UPDATE ' || quote_ident(f_trajectory_segtable_name) || 
						' SET tpseg[$1] = NULL WHERE mpid = ' || data.mpid || ' and segid = ' || data.segid 
					USING i;
				END IF;
					
				EXECUTE 'select tpseg[' || i || '].p from ' || quote_ident(f_trajectory_segtable_name) || 
					' WHERE mpid = ' || data.mpid || ' and segid = ' || data.segid 
				INTO new_tpoint.pnt;

				EXECUTE 'select tpseg[' || i || '].ptime from ' || quote_ident(f_trajectory_segtable_name) || 
					' WHERE mpid = ' || data.mpid || ' and segid = ' || data.segid 
				INTO new_tpoint.ts;

				-- tpseg의 값을 수정하였다면 새로운 tpseg로 붙여주어 나중에 row에 새로운 tpseg로 변경해준다.
				IF( new_tpoint IS NOT NULL) THEN
					new_tpseg[j] := new_tpoint;

					EXECUTE 'update ' || quote_ident(f_trajectory_segtable_name) || 
					' set start_time = $1[(SELECT array_lower( $1 , 1))].ptime , end_time = $1[(SELECT array_upper( $1 , 1))].ptime ' ||
					'WHERE mpid = ' || data.mpid || ' and segid = ' || data.segid
					USING new_tpseg;

					-- while루프 안으로 들어왔다면 변경할 값이 있다는 것이기에 rect도 변경을 해주어야 한다.
					IF( i = 1) THEN
						execute 'update ' || quote_ident(f_trajectory_segtable_name) ||
							' set rect = ( select st_makebox2d( $1, $1) ) ' ||
							' where mpid = $2 and segid = $2'
						using new_tpseg[i].p, data.mpid, data.segid;
					ELSE
						execute 'select rect from ' || quote_ident(f_trajectory_segtable_name) ||
							' where mpid = $1 and segid = $2' 
						into new_rect using data.mpid, data.segid;
						execute 'update ' || quote_ident(f_trajectory_segtable_name) ||
							' set rect = ( select st_combine_bbox( $1::box2d, $2.p ) ) ' ||
							' where mpid = $3 and segid = $4'
						using new_rect, new_tpseg[j], data.mpid, data.segid;
					j := j+1;
					END IF;
				END IF;
				i := i+1;


			END LOOP;

			-- 새로운 tpseg의 크기를 가져와서 mpcount를 설정해준다.
			EXECUTE 'select array_upper( $1, 1)' INTO new_mpcount USING new_tpseg;
				
			EXECUTE 'update ' || quote_ident(f_trajectory_segtable_name) ||
				' set tpseg = $1, mpcount = $2 where mpid = ' || data.mpid || ' and segid = ' || data.segid
			USING new_tpseg, new_mpcount;

			IF(new_mpcount IS NULL) THEN
				-- 원본 데이터에서 현재 row의 next_segid를 가져온다.(실행하지 않아도 됨.)
				EXECUTE 'select next_segid from ' || quote_ident(f_trajectory_segtable_name) || ' where mpid = $1 and segid = $2'
				INTO new_next_segid USING data.mpid, data.segid;

				-- 원본 데이터에서 현재 row의 before_segid를 가져온다.
				EXECUTE 'select before_segid from ' || quote_ident(f_trajectory_segtable_name) || ' where mpid = $1 and segid = $2'
				INTO new_before_segid USING data.mpid, data.segid;
				
				-- tpseg의 크기가 0이면 앞 row의 next_segid 를 바꿔준다.
				EXECUTE 'update ' || quote_ident(f_trajectory_segtable_name) || ' set next_segid = $1 where mpid = $2 and next_segid = $3'
				USING new_next_segid, data.mpid, data.segid;

				-- tpseg의 크기가 0이면 쉬 row의 before_segid 를 바꿔준다.
				EXECUTE 'update ' || quote_ident(f_trajectory_segtable_name) || ' set before_segid = $1 where mpid = $2 and before_segid = $3'
				USING new_before_segid, data.mpid, data.segid;
					
				-- tpseg의 크기가 0이면 로우를 삭제
				EXECUTE 'delete from ' || quote_ident(f_trajectory_segtable_name) || ' where mpid = $1 and segid = $2'
				USING data.mpid, data.segid;
			END IF;
			--다음 루프를 위하여 new_tpseg를 초기화
			new_tpseg := NULL;
		END IF;		
	END LOOP;

	RETURN c_trajectory;
END
$$
LANGUAGE 'plpgsql' ;


CREATE OR REPLACE FUNCTION modify(trajectory, tpoint) RETURNS trajectory AS
$$
DECLARE
	c_trajectory			alias for $1;
	c_tpoint			alias for $2;
	c_trajectory_segtable_name	text;

	sql				text;
	i				integer;
	tpseg_size			integer;
	tp_seg				tpoint[];
	c_rect				geometry;
	data				RECORD;
	
BEGIN

	sql := 'select relname from pg_catalog.pg_class c
		WHERE c.oid = '|| c_trajectory.segtableoid;
	RAISE DEBUG '%', sql;
	EXECUTE sql INTO c_trajectory_segtable_name;

	sql := 'select * from ' || quote_ident(c_trajectory_segtable_name) || ' where mpid = ' || c_trajectory.moid;
	
	FOR data IN EXECUTE sql LOOP
		i := 1;
		execute 'select array_upper( $1 , 1)'
		into tpseg_size using data.tpseg;
		tp_seg := data.tpseg;
		-- 현 ROW의 시작시간과 끝시간을 가져와서 변경될 포인트의 시간이 포함되는지 확인한다.
		-- 조건을 만족하면 현 tpseg의 포인트가 변경되어야 함을 나타낸다. 
		IF( c_tpoint.ptime >= data.start_time AND c_tpoint.ptime <= data.end_time ) THEN
			-- tpseg에 변화가 생기면 rect를 변경해주기 위하여 현재의 rect를 불러온다.


			WHILE( i <= tpseg_size  ) LOOP
				IF( tp_seg[i].ts = c_tpoint.ts ) THEN
					execute 'update ' || quote_ident(c_trajectory_segtable_name) || 
						' set tpseg[$1] = $2 where mpid = $3 and segid = $4'
					using i, c_tpoint, data.mpid, data.segid;

				END IF;
				-- 기존의 box2d에서 새로운 점으로 tpseg가 변경되면 그 점을 포함한 box2d로 변경을 해준다.
				-- 새로운 점이 들어옴으로써 tpseg를 전부 다시 계산하여 box2d를 만들어준다. 
				-- 많은 연산이 필요하다는 단점이 있다.
				IF( i = 1) THEN
					execute 'update ' || quote_ident(c_trajectory_segtable_name) ||
						' set rect = ( select st_makebox2d( $1, $1) ) ' ||
						' where mpid = $2 and segid = $3'
					using tp_seg[i].pnt, data.mpid, data.segid;
				ELSE
					execute 'select rect from ' || quote_ident(c_trajectory_segtable_name) ||
						' where mpid = $1 and segid = $2' 
					into c_rect using data.mpid, data.segid;
					execute 'update ' || quote_ident(c_trajectory_segtable_name) ||
						' set rect = ( select st_combine_bbox( $1::box2d, $2.p ) ) ' ||
						' where mpid = $3 and segid = $4'
					using c_rect, c_tpoint, data.mpid, data.segid;

				END IF;
				i := i+1;
			END LOOP;
		END IF;
	END LOOP;

	RETURN c_trajectory;

END
$$
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION modify(trajectory, tpoint[]) RETURNS trajectory AS
$$
DECLARE
	c_trajectory	alias for $1;
	array_tpoint	alias for $2;

	array_size	integer;
	i		integer;
	sql		text;
BEGIN
	execute 'select array_upper( $1, 1)'
	into array_size using array_tpoint;

	i := 1;

	WHILE( i <= array_size ) LOOP
		execute 'select modify( $1, $2[$3] )'
		using c_trajectory, array_tpoint, i;
		 i := i+1;
	END LOOP;

	RETURN c_trajectory;
END
$$
LANGUAGE 'plpgsql';


-- 데이터의 수정 함수, trajectory와 시작시간, 끝시간, 변경할 데이터를 입력해야 한다.
CREATE OR REPLACE FUNCTION modify(trajectory, timestamp, timestamp, tpoint[]) RETURNS trajectory AS
$$
DECLARE
	c_trajectory			alias for $1;
	c_start_time			alias for $2;
	c_end_time			alias for $3;
	c_tpoint			alias for $4;
	c_trajectory_segtable_name	text;


	tpoint_max_size			integer;
	tpoint_min_size			integer;
	sql				text;
	i				integer;
	tpseg_size			integer;
	tp_seg				tpoint[];
	data				RECORD;
	tpseg_max_size			integer;
	--tpseg를 임시 저장하기 위한 temp
	tpseg_temp1			tpoint[];
	tpseg_temp2			tpoint[];
	tpseg_temp3			tpoint[];
	tpseg_temp3_size		integer;
	new_tpseg			tpoint[];
	-- 새로운 tpseg의 크기를 알기 위한 변수
	new_tpseg_size			integer;
	-- 새로운 row 생성시
	new_rect			geometry;
	max_segid			integer;
	new_next_segid			integer;
	new_before_segid		integer;
	new_row_segid			integer;
BEGIN
	sql := 'select relname from pg_catalog.pg_class c
		WHERE c.oid = '|| c_trajectory.segtableoid;
	RAISE DEBUG '%', sql;
	EXECUTE sql INTO c_trajectory_segtable_name;

	EXECUTE 'select array_upper($1, 1)'
	INTO tpoint_max_size USING c_tpoint; 

	EXECUTE 'select array_lower($1, 1)'
	INTO tpoint_min_size USING c_tpoint;


	sql := 'select tpseg_size from trajectory_columns ' ||
		' where f_trajectory_segtable_name = ' || quote_literal(c_trajectory_segtable_name);
	RAISE DEBUG '%', sql;
	EXECUTE sql INTO tpseg_max_size;

	sql := 'select * from ' || quote_ident(c_trajectory_segtable_name) || ' where mpid = ' || c_trajectory.moid || 
		' order by start_time';

	IF( (c_start_time <= c_tpoint[tpoint_min_size].ts) AND (c_end_time >= c_tpoint[tpoint_max_size].ts)) THEN
	-- 사용자 입력 시간과 tpoint[]의 시간이 contain되었을 때
		FOR data IN EXECUTE sql LOOP
			-- 읽어온 row에 사용자 입력 데이터로 변환되어야 할 데이터가 있을때
			IF( ( data.start_time <= c_end_time ) AND ( data.end_time >= c_start_time ) ) THEN
				IF( data.start_time <= c_start_time ) THEN
					i := 1;
					tp_seg := data.tpseg;
					WHILE( i <= data.mpcount ) LOOP
						-- 사용자가 입력한 start_time보다 저장된 데이터(tpseg)의 시간이 같거나 크다면
						-- 현재의 앞부분까지가 보존해야 할 데이터이다.
						IF( c_start_time > tp_seg[i].ts AND c_start_time <= tp_seg[i+1].ts) THEN
							tpseg_temp1 := tp_seg[1:i];
						END IF;
						-- 사용자가 입력한 end_time보다 저장된 데이터(tpseg)의 시간이 더 크다면
						-- 현재부터 보존해야 할 데이터이다.
						IF( c_end_time < tp_seg[i].ts AND c_end_time >= tp_seg[i-1].ts) THEN
							tpseg_temp2 := tp_seg[i:data.mpcount];
							i := data.mpcount;
						END IF;
						i := i+1;
					END LOOP;
					-- temp3에 원본 데이터의 보존해야할 앞부분과 사용자가 입력한 데이터를 합해준다.

					EXECUTE 'select array_cat($1, $2)'
					INTO tpseg_temp3 USING tpseg_temp1, c_tpoint;

					-- temp3에 원본 데이터의 보존해야할 데이터의 뒷부분을 넣어준다.
					EXECUTE 'select array_cat( $1, $2)'
					INTO tpseg_temp3 USING tpseg_temp3, tpseg_temp2;

					EXECUTE 'select array_upper($1, 1)'
					INTO tpseg_temp3_size USING tpseg_temp3;

					new_tpseg := tpseg_temp3;
					-- 새로운 tpseg의 크기가 tpseg_max_size보다 작거나 같다면 그냥 update(삽입) 해주면 된다.
					IF( tpseg_temp3_size <= tpseg_max_size ) THEN
						EXECUTE 'update ' || quote_ident(c_trajectory_segtable_name) ||
							' set tpseg = $1, start_time = $2, end_time = $3, mpcount = $4 where mpid = $5 and segid = $6'
						USING new_tpseg, new_tpseg[1].ts, new_tpseg[tpseg_temp3_size].ts, tpseg_temp3_size, data.mpid, data.segid;
						-- rect 계산
						EXECUTE 'select getBox2D($1)'
						INTO new_rect USING new_tpseg;
						-- rect 갱신
						EXECUTE 'update ' || quote_ident(c_trajectory_segtable_name) ||
							' set rect = $1 where mpid = $2 and segid = $3'
						USING new_rect, data.mpid, data.segid;

						
						
					-- 업데이트해야 할 tpseg가 tpseg_max_size보다 크다면
					ELSE 
						-- 우선 현재row에 데이터를 tpseg_max_size개만 삽입해준다.
						new_tpseg := tpseg_temp3[1:tpseg_max_size];
						EXECUTE 'update '  || quote_ident(c_trajectory_segtable_name) ||
							' set tpseg = $1, start_time = $2, end_time = $3, mpcount = $4 where mpid = $5 and segid = $6'
						USING new_tpseg, new_tpseg[1].ts, new_tpseg[tpseg_max_size].ts, tpseg_max_size, data.mpid, data.segid;

						EXECUTE 'select getBox2D($1)'
						INTO new_rect USING new_tpseg;
						EXECUTE 'update ' || quote_ident(c_trajectory_segtable_name) ||
							' set rect = $1 where mpid = $2 and segid = $3'
						USING new_rect, data.mpid, data.segid;
							
						-- 현 row의 next_segid값을 가져와서 다음에 만들 row의 next_segid값을 준비한다.
						EXECUTE 'select next_segid from ' || quote_ident(c_trajectory_segtable_name) ||
								' where mpid = $1 and segid = $2'
						INTO new_next_segid USING data.mpid, data.segid;
						-- 현 row가 다음에 만들 row의 before_segid값이 된다.
						new_before_segid = data.segid;
						WHILE ( tpseg_temp3_size > tpseg_max_size ) LOOP
							tpseg_temp3 := tpseg_temp3[tpseg_max_size + 1:tpseg_temp3_size];

							-- new_tpseg에 최대 크기만큼 붙여준다(새로운 row에 삽입될 데이터이다.)
							new_tpseg := tpseg_temp3[1:tpseg_max_size];

							EXECUTE 'select array_upper($1, 1)'
							INTO tpseg_temp3_size USING tpseg_temp3;

							EXECUTE 'select array_upper($1, 1)'
							INTO new_tpseg_size USING new_tpseg;

							-- max_segid를 계산해야 한다. 							
							EXECUTE 'select max(segid) from ' || quote_ident(c_trajectory_segtable_name) ||
									' where mpid = $1'
							INTO max_segid USING data.mpid;
							
							new_row_segid := max_segid+1;
								
							EXECUTE 'INSERT INTO ' || quote_ident(c_trajectory_segtable_name) || 
									'(mpid, segid, next_segid, before_segid, mpcount, start_time, end_time, tpseg) ' || 
									'values($1, $2, $3, $4, $5, $6, $7, $8)'
							USING data.mpid, new_row_segid, new_next_segid, new_before_segid, new_tpseg_size, new_tpseg[1].ts, new_tpseg[new_tpseg_size].ts, new_tpseg;

							EXECUTE 'select getBox2D($1)'
							INTO new_rect USING new_tpseg;

							EXECUTE 'UPDATE ' || quote_ident(c_trajectory_segtable_name) || 
								' set rect = getBox2D($1) where mpid = $2 and segid = $3'
							USING new_tpseg, data.mpid, new_row_segid;

							-- 현재 row의 next_segid를 갱신
							EXECUTE 'UPDATE ' || quote_ident(c_trajectory_segtable_name) || 
								' set next_segid = $1 where mpid = $2 and segid = $3'
							USING new_row_segid, data.mpid, new_before_segid;

							-- 현재 row의 next_segid값을 가진 row의 before_segid값을 갱신
							EXECUTE 'UPDATE ' || quote_ident(c_trajectory_segtable_name) || 
								' set before_segid = $1 where mpid = $2 and segid = $3'
							USING new_row_segid, data.mpid, new_next_segid;

							new_before_segid := new_row_segid;


						END LOOP;
					END IF;
				ELSIF( ( data.start_time > c_start_time ) AND ( data.end_time <= c_end_time ) ) THEN
					-- row 삭제전 자신을 next_segid, before_segid로 가지고 있던 데이터들을 변경해주어야 한다.
					EXECUTE 'update ' || quote_ident(c_trajectory_segtable_name) || 
						' set next_segid = $1 where mpid = $2 and next_segid = $3'
					USING data.next_segid, data.mpid, data.segid;

					EXECUTE 'update ' || quote_ident(c_trajectory_segtable_name) || 
						' set before_segid = $1 where mpid = $2 and before_segid = $3'
					USING data.before_segid, data.mpid, data.segid;

					-- row 삭제
					EXECUTE 'DELETE FROM ' || quote_ident(c_trajectory_segtable_name) || 
						' where mpid = $1 and segid = $2'
					USING data.mpid, data.segid;

				ELSIF( data.end_time > c_end_time ) THEN
					-- row의 데이터 일부분 삭제
					-- 변경하고자 하는 데이터의 끝부분이 현재 row의 일부분에 있다면 해당되는 데이터만 삭제를 해준다.
					EXECUTE 'select remove(' || c_trajectory || ', TIMESTAMP ' || quote_literal(data.start_time) || ', TIMESTAMP ' || quote_literal(c_end_time) || ')';
				ELSE

				END IF;
					
			END IF;
		END LOOP;
		
	ELSE
		-- 사용자 입력시간과 tpoint[]의 시간이 contain 되지 않을때
		RAISE NOTICE 'data time dose not match';
	END IF;

	RETURN c_trajectory;
END
$$
LANGUAGE 'plpgsql';


--SELECT 함수 trajectory와 시작시간 끝시간을 입력해야 한다.
CREATE OR REPLACE FUNCTION trajectory_select(trajectory, timestamp, timestamp) RETURNS tpoint[] AS
$$
DECLARE
	c_trajectory	alias for $1;
	start_time	alias for $2;
	end_time	alias for $3;


	c_trajectory_segtable_name	text;
	data				RECORD;
	tp_seg		tpoint[];
	new_tpseg	tpoint[];
	i		integer;
	sql		text;
	
BEGIN
	sql := 'select relname from pg_catalog.pg_class c
		WHERE c.oid = '|| c_trajectory.segtableoid;
	RAISE DEBUG '%', sql;
	EXECUTE sql INTO c_trajectory_segtable_name;

	sql := 'select * from ' || quote_ident(c_trajectory_segtable_name) || ' where mpid = ' || c_trajectory.moid || 
		' order by start_time';

	FOR data IN EXECUTE sql LOOP
		IF( data.start_time <= end_time OR data.end_time <= start_time ) THEN
			tp_seg := data.tpseg;

			i := 1;

			WHILE( i <= data.mpcount ) LOOP
				IF( tp_seg[i].ts >= start_time AND tp_seg[i].ts <= end_time ) THEN
					IF( new_tpseg = NULL  ) THEN
						new_tpseg := tp_seg[1:i];
					ELSE
						EXECUTE 'select array_append($1, $2)'
						INTO new_tpseg USING new_tpseg, tp_seg[i];
					END IF;
				END IF;
				i := i+1;
			END LOOP;
		END IF;
	END LOOP;

	RETURN new_tpseg;
END
$$
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION getrectintrajectory_record(double precision, double precision, double precision, double precision, trajectory)
  RETURNS tpoint[] AS
$BODY$
DECLARE
	x1				alias for $1;
	y1				alias for $2;
	x2				alias for $3;
	y2				alias for $4;
	f_trajectory			alias for $5;
	isIntersect_box2d		boolean;
	isOverlap_point			boolean;
	tpoint_MaxNumber		integer;
	nowTpsegNumber			integer;
	tpseg				tpoint[];
	user_rect			box2d;
	select_tpoint			tpoint;
	return_data			text;

	f_trajectory_segtable_name	text;
	sql				text;
	data				record;

	return_value			tpoint[];
BEGIN
	
	sql := 'select relname from pg_catalog.pg_class c
		where c.oid = '|| f_trajectory.segtableoid;
	RAISE DEBUG '%', sql;
	EXECUTE sql INTO f_trajectory_segtable_name;


	EXECUTE 'select st_makebox2d(st_point($1, $2), st_point($3, $4))'
	into user_rect using x1, y1, x2, y2;
	
	sql := 'select * from ' || quote_ident(f_trajectory_segtable_name) || ' where mpid = ' || f_trajectory.moid;
	FOR data IN EXECUTE sql LOOP
		execute 'select st_box2d_intersects((select st_box2d($1)), $2)'
		into isIntersect_box2d using data.rect, user_rect;
		IF(isIntersect_box2d) THEN
			tpseg := data.tpseg;
			nowTpsegNumber := 1;
			sql := 'select array_upper($1, 1)';
			EXECUTE sql INTO tpoint_MaxNumber using tpseg;
			WHILE tpoint_MaxNumber >= nowTpsegNumber LOOP
				EXECUTE 'select st_box2d_overlap($1, (select st_box2d($2)))'
				INTO isOverlap_point USING user_rect, tpseg[nowTpsegNumber].pnt;
				IF(isOverlap_point) THEN
					select_tpoint := tpseg[nowTpsegNumber];
					--execute 'select st_astext($1)'
					--into return_data using select_tpoint.p;
					return_value := return_value || select_tpoint;

				END IF;
				nowTpsegNumber := nowTpsegNumber + 1;
				
			END LOOP;
		END IF;
	END LOOP;
	return return_value;
END

$BODY$
LANGUAGE 'plpgsql' VOLATILE
COST 100;
  
  
CREATE OR REPLACE FUNCTION getEndTime(trajectory) RETURNS timestamp without time zone AS
$BODY$
DECLARE
	user_traj			alias for $1;

	f_trajectory_segtable_name	text;
	sql			text;

	end_time		TIMESTAMP with time zone;

	
BEGIN	
	sql := 'select relname from pg_catalog.pg_class c
		where c.oid = '|| user_traj.segtableoid;
	RAISE DEBUG '%', sql;
	EXECUTE sql INTO f_trajectory_segtable_name;

	sql := 'select end_time from ' || quote_ident(f_trajectory_segtable_name) || ' where mpid = ' || user_traj.moid || ' and next_segid is null';
	EXECUTE sql INTO end_time;

	RETURN end_time;
END
$BODY$
LANGUAGE 'plpgsql' VOLATILE STRICT
COST 100;


--traj와 영역을 주면 해당 영역에 교차하는 tpoint가 있는 segment의 모든 tpoint를 리턴해준다.
CREATE OR REPLACE FUNCTION getIntersectTpoint(trajectory, geometry) RETURNS tpoint[] AS
$$
DECLARE
	user_traj			alias for $1;
	input_geometry			alias for $2;
	f_trajectory_segtable_name	text;

	sql				text;
	data				record;
	isIntersect			boolean;
	intersect_tpseg			tpoint[];

BEGIN
	sql := 'select relname from pg_catalog.pg_class c
		where c.oid = '|| user_traj.segtableoid;
	RAISE DEBUG '%', sql;
	EXECUTE sql INTO f_trajectory_segtable_name;
	
	sql := 'select * from ' || quote_ident(f_trajectory_segtable_name) || ' where mpid = ' || user_traj.moid;
	FOR data IN EXECUTE sql LOOP
		sql := 'select st_intersects( $1 , $2 )';
		EXECUTE sql INTO isIntersect USING data.rect, input_geometry;

		IF(isIntersect) THEN
			EXECUTE 'select array_cat( $1, $2)'
			INTO intersect_tpseg USING intersect_tpseg, data.tpseg;
		END IF;
	END LOOP;

	RETURN intersect_tpseg;
END
$$
LANGUAGE 'plpgsql';


--tpoint array를 주면 geometry[](포인트[])를 리턴해준다.
CREATE OR REPLACE FUNCTION getPointArray(tpoint[]) RETURNS geometry[] AS
$$
DECLARE
	input_tpoint	alias for $1;
	return_value	geometry[];

	sql_text		text;
	array_size		int;
	tpoint_data		tpoint;

	i			int;

BEGIN
	sql_text := 'select array_upper( $1, 1)';
	EXECUTE sql_text INTO array_size USING input_tpoint; 
	i := 1;
	WHILE array_size >= i LOOP
		
		EXECUTE 'select array_append($1, $2)'
		INTO return_value USING return_value, input_tpoint[i].pnt;
		i := i+1;
	END LOOP;
	
	RETURN return_value;
	
END
$$
LANGUAGE 'plpgsql';


-- seg table의 rect 정보를 보기 위한 함수
--drop function getRect_trajectory(trajectory) 

CREATE OR REPLACE FUNCTION getRect_trajectory(trajectory) RETURNS setof box2d AS
$$
DECLARE
	user_traj			alias for $1;
	f_trajectory_segtable_name	text;
	sql				text;
	data				record;
	rect				box2d;
BEGIN
	sql := 'select relname from pg_catalog.pg_class c
		where c.oid = '|| user_traj.segtableoid;
	RAISE DEBUG '%', sql;
	EXECUTE sql INTO f_trajectory_segtable_name;
	
	sql := 'select * from ' || quote_ident(f_trajectory_segtable_name) || ' where mpid = ' || user_traj.moid;
	FOR data IN EXECUTE sql LOOP
		execute 'select getbbox( $1 )'
		into rect using data.rect;
		return next rect;
	END LOOP;
	
END
$$
LANGUAGE 'plpgsql';


-- Function: gettimestamp(integer)

-- DROP FUNCTION gettimestamp(integer);

CREATE OR REPLACE FUNCTION getStartTime(trajectory)
  RETURNS timestamp without time zone AS
$BODY$
DECLARE
	user_traj			alias for $1;

	f_trajectory_segtable_name	text;
	sql			text;

	start_time		TIMESTAMP with time zone;

	
BEGIN	
	sql := 'select relname from pg_catalog.pg_class c
		where c.oid = '|| user_traj.segtableoid;
	RAISE DEBUG '%', sql;
	EXECUTE sql INTO f_trajectory_segtable_name;

	sql := 'select start_time from ' || quote_ident(f_trajectory_segtable_name) || ' where mpid = ' || user_traj.moid || ' and before_segid is null';
	EXECUTE sql INTO start_time;

	RETURN start_time;
END
$BODY$
LANGUAGE 'plpgsql' VOLATILE STRICT
COST 100;


CREATE OR REPLACE FUNCTION gettimestamp(integer)
  RETURNS timestamp without time zone AS
$BODY$
DECLARE
	input_interval		alias for $1;

	base_time		TIMESTAMP with time zone;

	data_time		TIMESTAMP with time zone;

	text_interval		text;
	
BEGIN	
	
	base_time := '2011-01-01 12:00:00+9';
	text_interval := input_interval || ' minute';

	EXECUTE 'select TIMESTAMP ' || quote_literal(base_time)
	INTO base_time;
	

	EXECUTE 'select TIMESTAMP ' || quote_literal(base_time)  || ' + interval ' || quote_literal(text_interval)
	INTO data_time;

	RETURN data_time;
END
$BODY$
  LANGUAGE 'plpgsql' VOLATILE STRICT
  COST 100;
ALTER FUNCTION gettimestamp(integer) OWNER TO postgres;

--mpseg 테이블의 tpseg정보를 텍스트로 보기위한 함수
create or replace function getTpointArrayInfo(tpoint[]) returns setof text as
$$
declare
	tpseg	alias for $1;

	max_size	integer;
	now_count	integer;
	return_data	text;

begin
	execute 'select array_upper($1, 1)'
	into max_size using tpseg;
	now_count := 1;
	while max_size >= now_count loop
		execute 'select st_astext($1)'
		into return_data using tpseg[now_count].p;
		now_count := now_count + 1;
		return next return_data;
	end loop;
end
$$
language 'plpgsql';


CREATE OR REPLACE FUNCTION getTrajectoryarrayinfo(tpoint[],  OUT tpoint text, OUT ptime_timestamp timestamp without time zone)
  RETURNS SETOF record AS
$BODY$
declare
	tpseg	alias for $1;

	max_size	integer;
	now_count	integer;
	return_data	text;

begin
	execute 'select array_upper($1, 1)'
	into max_size using tpseg;
	now_count := 1;
	while max_size >= now_count loop
		execute 'select st_astext($1)'
		into tpoint using tpseg[now_count].p;
		ptime_timestamp := tpseg[now_count].ptime;

		now_count := now_count+1;
		return next;
	end loop;

	return;
end
$BODY$
LANGUAGE 'plpgsql' VOLATILE;


CREATE OR REPLACE FUNCTION getIntersectTpoint(trajectory, geometry) RETURNS tpoint[] AS
$$
DECLARE
	user_traj			alias for $1;
	input_geometry			alias for $2;
	f_trajectory_segtable_name	text;

	sql				text;
	data				record;
	isIntersect			boolean;
	intersect_tpseg			tpoint[];
	
BEGIN
	sql := 'select relname from pg_catalog.pg_class c
		where c.oid = '|| user_traj.segtableoid;
	RAISE DEBUG '%', sql;
	EXECUTE sql INTO f_trajectory_segtable_name;
	
	sql := 'select * from ' || quote_ident(f_trajectory_segtable_name) || ' where mpid = ' || user_traj.moid;
	FOR data IN EXECUTE sql LOOP
		sql := 'select st_intersects( $1 , $2 )';
		EXECUTE sql INTO isIntersect USING data.rect, input_geometry;

		IF(isIntersect) THEN
			EXECUTE 'select array_cat( $1, $2)'
			INTO intersect_tpseg USING intersect_tpseg, data.tpseg;
		END IF;
	END LOOP;

	RETURN intersect_tpseg;
END
$$
LANGUAGE 'plpgsql';



--tpoint[]를 입력하면 linestring를 리턴해주는 함수
CREATE OR REPLACE FUNCTION tpoint_to_linestring(tpoint[]) RETURNS geometry AS
$$
DECLARE
	input_tpoint	alias for $1;

	tpoinA_to_geometryA	geometry[];
	tpoint_to_Linestring	geometry;
BEGIN
	--tpoint[]를 point[]로 변환
	EXECUTE 'select getpointarray( $1 )' INTO tpoinA_to_geometryA USING input_tpoint;

	--구해진 point[]를 이용하여 linestring를 구한다.
	EXECUTE 'select st_makeline( $1 )' INTO tpoint_to_Linestring USING tpoinA_to_geometryA;

	RETURN tpoint_to_Linestring;
END
$$
LANGUAGE 'plpgsql';




