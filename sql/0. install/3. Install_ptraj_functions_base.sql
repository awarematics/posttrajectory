
/*

CREATE OR REPLACE FUNCTION getBox2D(tpoint[]) RETURNS geometry;
CREATE OR REPLACE FUNCTION delete_mpoint_seg() RETURNS trigger;
CREATE OR REPLACE FUNCTION insert_trigger() RETURNS trigger;
CREATE OR REPLACE FUNCTION tj_AddTrajectoryColumn(character varying, character varying, character varying, 
	integer, character varying, integer) RETURNS text;
CREATE OR REPLACE FUNCTION tj_AddTrajectoryColumn(character varying, character varying, character varying, 
	integer, character varying, integer, integer) RETURNS text;
CREATE OR REPLACE FUNCTION tj_tpoint(geometry, timestamp) RETURNS tpoint;
CREATE OR REPLACE FUNCTION tj_append(trajectory, geometry, timestamp) RETURNS trajectory;
CREATE OR REPLACE FUNCTION tj_append(trajectory, tpoint[]) RETURNS trajectory;
CREATE OR REPLACE FUNCTION tj_append(trajectory, tpoint) RETURNS trajectory;
CREATE OR REPLACE FUNCTION tj_remove(trajectory, timestamp, integer) RETURNS trajectory;
CREATE OR REPLACE FUNCTION tj_remove(trajectory, timestamp, timestamp) RETURNS trajectory;
CREATE OR REPLACE FUNCTION tj_modify(trajectory, tpoint) RETURNS trajectory;
CREATE OR REPLACE FUNCTION tj_modify(trajectory, tpoint[]) RETURNS trajectory;
CREATE OR REPLACE FUNCTION tj_modify(trajectory, timestamp, timestamp, tpoint[]) RETURNS trajectory;
CREATE OR REPLACE FUNCTION tj_slice(trajectory, timestamp, timestamp) RETURNS tpoint[];
CREATE OR REPLACE FUNCTION tj_slice(trajectory, double, double, double, double) RETURNS tpoint[];
CREATE OR REPLACE FUNCTION tj_slice(trajectory, geometry) RETURNS tpoint[];
--CREATE OR REPLACE FUNCTION getrectintrajectory_record(double precision, double precision, double precision, double precision, trajectory) RETURNS tpoint[];
CREATE OR REPLACE FUNCTION getIntersectTpoint(trajectory, geometry) RETURNS tpoint[];
CREATE OR REPLACE FUNCTION getPointArray(tpoint[]) RETURNS geometry[];
CREATE OR REPLACE FUNCTION getRect_trajectory(trajectory) RETURNS setof box2d;
CREATE OR REPLACE FUNCTION getStartTime(trajectory) RETURNS timestamp;
CREATE OR REPLACE FUNCTION getEndTime(trajectory) RETURNS timestamp;
CREATE OR REPLACE FUNCTION getTimeStamp(integer) RETURNS timestamp;
CREATE OR REPLACE FUNCTION getTimestamp(integer) RETURNS timestamp;
create or replace function getTpointArrayInfo(tpoint[]) returns setof text;
CREATE OR REPLACE FUNCTION getTrajectoryarrayinfo(tpoint[], OUT tpoint text, OUT ptime_timestamp timestamp) RETURNS SETOF record;
CREATE OR REPLACE FUNCTION getIntersectTpoint(trajectory, geometry) RETURNS tpoint[];
CREATE OR REPLACE FUNCTION tpoint_to_linestring(tpoint[]) RETURNS geometry;
CREATE OR REPLACE FUNCTION TJ_MINDISTANCE(trajectory, geometry) RETURNS mdouble 
CREATE OR REPLACE FUNCTION TJ_MAXDISTANCE(trajectory, geometry) RETURNS mdouble 
CREATE OR REPLACE FUNCTION TJ_CALCULATETPOINT(tpoint, tpoint, tpoint) RETURN tpoint
CREATE OR REPLACE FUNCTION TJ_DISTANCE(trajectory, geometry) RETURNS mdouble[]
CREATE OR REPLACE FUNCTION tj_getDistance(mdouble) RETURNS double precision 
CREATE OR REPLACE FUNCTION TJ_PERIOD(trajectory) RETURNS periods
CREATE OR REPLACE FUNCTION TJ_COMMONPERIOD(periods, periods) RETURNS periods
*/


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
	delete_trajectory	trajectory;
	delete_id		integer;
	
	records			record;
	delete_record		record;
	
    BEGIN
	execute 'select f_trajectory_segtable_name, f_trajectory_column from trajectory_columns where f_table_name = ' || quote_literal(TG_RELNAME)
	into records;

	-- traj값 가져오는부분 수정해야함.
	delete_record := OLD;

	/*
	execute 'select ' || column_name || ' from ' || delete_record
	into delete_trajectory;
	*/
	
	delete_trajectory := OLD.traj;
	delete_id := delete_trajectory.moid;
	
	execute 'DELETE FROM ' || quote_ident(records.f_trajectory_segtable_name) || ' WHERE mpid = ' || delete_id;

	return NULL;

    END;
$delete_mpoint_seg$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION public.insert_trigger()
  RETURNS trigger AS
$BODY$
DECLARE	
	segtable_oid		text;
	segcolumn_name		text;
	sequence_name		text;
	moid			text;
	
	sql_text		text;
	records			record;
	
 BEGIN	
	sql_text := 'select f_segtableoid, f_trajectory_column, f_sequence_name from trajectory_columns where f_table_name = ' || quote_literal(TG_RELNAME);
	
	--f_segtableoid, f_trajectory_column, f_sequence_name 가져온다. 
	execute sql_text into records;
	
	segtable_oid := records.f_segtableoid;
	segcolumn_name := records.f_trajectory_column;
	sequence_name := records.f_sequence_name;

	sql_text := 'select nextval(' || quote_literal(sequence_name) || ')';
		
	--sequence_name를 이용하여 삽입할 sequence를 결정한다.
	execute sql_text into moid;

	/*
	RAISE NOTICE 'sql_text : %', sql_text;
	RAISE NOTICE 'segtable_oid : %', segtable_oid;
	RAISE NOTICE 'segcolumn_name : %', segcolumn_name;
	RAISE NOTICE 'sequence_name : %', sequence_name;
	RAISE NOTICE 'moid : %', moid;
	*/
	
	--user maked column(trajectoryColumn)의 값을 삽입해준다.
	NEW.traj = (segtable_oid, moid);	
		
	return NEW;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
  
  
  
CREATE OR REPLACE FUNCTION tj_AddTrajectoryColumn(character varying, character varying, character varying, 
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
	
	resultvalue text;
BEGIN

	execute 'select addTrajectoryColumn($1, $2, $3, $4, $5, $6, 10)'
	into resultvalue using f_schema_name, f_table_name, f_column_name, srid, new_type, dimension;
	
	RETURN resultvalue;
	
END;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE STRICT
  COST 100;
ALTER FUNCTION tj_AddTrajectoryColumn(character varying, character varying, character varying, integer, character varying, integer) OWNER TO postgres;
COMMENT ON FUNCTION tj_AddTrajectoryColumn(character varying, character varying, character varying, integer, character varying, integer) IS 
					'args: schema_name, table_name, column_name, srid, type, dimentrion';


CREATE OR REPLACE FUNCTION tj_AddTrajectoryColumn(character varying, character varying, character varying, 
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
	temp_segtable_name text;
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
	

	temp_segtable_name := 'mpseq_' || table_oid || '_' || f_column_name;

	
	--table_name의 column_name을 위한 mppsegtable 생성
	EXECUTE 'CREATE TABLE ' || temp_segtable_name || ' 
		(
			mpid		integer,
			segid		integer,
			next_segid	integer,
			before_segid	integer,
			mpcount		integer,
			rect		box2d,
			start_time	timestamp,
			end_time	timestamp,
			tpseg		tpoint[]
		)';

--	execute pg_sleep(1);

-- segtable_id setting and alter table name
	sql := 'select '|| quote_literal(temp_segtable_name) ||'::regclass::oid';
	RAISE DEBUG '%', sql;
	EXECUTE sql INTO f_segtable_oid;
	
	-- segment table name
	f_trajectory_segtable_name := 'mpseq_' || f_segtable_oid ;
	
	EXECUTE 'ALTER TABLE ' || quote_ident(temp_segtable_name) || ' RENAME TO ' || quote_ident(f_trajectory_segtable_name);
--	EXECUTE 'ALTER TABLE ' || quote_ident(f_trajectory_segtable_name) || '
--		ALTER COLUMN tpseg SET STORAGE EXTERNAL';
	

	/*
	sql := 'select '|| quote_literal(f_trajectory_segtable_name) ||'::regclass::oid';
	RAISE DEBUG '%', sql;
	EXECUTE sql INTO f_segtable_oid;
	*/

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
  
ALTER FUNCTION tj_AddTrajectoryColumn(character varying, character varying, character varying, integer, character varying, integer) OWNER TO postgres;
COMMENT ON FUNCTION tj_AddTrajectoryColumn(character varying, character varying, character varying, integer, character varying, integer) IS 
					'args: schema_name, table_name, column_name, srid, type, dimentrion';
                    

CREATE OR REPLACE FUNCTION tj_tpoint(geometry, timestamp) RETURNS tpoint AS
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
  


CREATE OR REPLACE FUNCTION TJ_append(trajectory, geometry, timestamp) RETURNS trajectory AS
$$
DECLARE
	inpuut_trajectory	alias for $1;
	inpuut_geometry		alias for $2;
	input_time		alias for $3;
BEGIN
	execute 'select TJ_append( $1, tj_tpoint( $2, $3 ) )'
	using inpuut_trajectory, inpuut_geometry, input_time;
END
$$
LANGUAGE 'plpgsql' VOLATILE STRICT
COST 100;

CREATE OR REPLACE FUNCTION TJ_append(trajectory, tpoint[]) RETURNS trajectory AS
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
	execute 'select array_upper( $1, 1 )'
	into array_size using array_tpoint;

	i := 1;

	WHILE( i <= array_size ) LOOP
		execute 'select TJ_append( $1, $2[$3] )'
		using c_trajectory, array_tpoint, i;
		 i := i+1;
	END LOOP;

	RETURN c_trajectory;
END
$$
LANGUAGE 'plpgsql' VOLATILE STRICT
COST 100;


CREATE OR REPLACE FUNCTION TJ_append(trajectory, tpoint) RETURNS trajectory AS
$BODY$
DECLARE
	f_trajectroy			alias for $1;
	tp				alias for $2;

	traj_prefix			char(50);
	traj_suffix			char(50);
	
	f_trajectory_segtable_name	char(200);
	table_oid			char(100);
	mpid				integer;
	segid				integer;
	mp_count			integer;
	mp_seq				record;
	max_tpseg_count	integer;

	cnt_mpid			integer;
	
	sql				text;

	next_segid			integer;
	tp_seg_size			integer;

	--새로운 row로 데이터 삽입을 할때 segid값을 정하기 위한 변수
	new_segid			integer;
BEGIN
	-- traj_prefix := current_setting('traj.prefix');
	-- traj_suffix := current_setting('traj.suffix');
	
	traj_prefix := 'mpseq_' ;
		
	f_trajectory_segtable_name := traj_prefix || f_trajectroy.segtableoid ;

	mpid := f_trajectroy.moid;
	
	-- 현재 trajectory_segtable의 mpid가 유효한지 검사
	sql := 'SELECT COUNT(*) FROM ' || quote_ident(f_trajectory_segtable_name) || 
		' WHERE mpid = ' || f_trajectroy.moid;
	RAISE DEBUG '%', sql;
	EXECUTE sql INTO cnt_mpid;
	
	-- tpseg_size 
	sql := 'select tpseg_size from trajectory_columns where f_trajectory_segtable_name = ' || quote_literal(f_trajectory_segtable_name);
	RAISE DEBUG '%', sql;
	EXECUTE sql INTO tp_seg_size;

	-- 최초로 삽입될 때
	IF (cnt_mpid < 1) THEN
		-- RAISE NOTICE '최초 삽입';
		
		-- mpid, segid, start_time, end_time, tpseg 삽입
		EXECUTE 'INSERT INTO ' || quote_ident(f_trajectory_segtable_name) || '(mpid, segid, mpcount, rect, start_time, end_time, tpseg) 
			VALUES($1, 1, 1, st_makebox2d( $2, $2), TIMESTAMP '|| quote_literal(tp.ts) || ', TIMESTAMP  '|| quote_literal(tp.ts) || ', ARRAY[($2, TIMESTAMP ' || quote_literal(tp.ts) || ')]::tpoint[])'
		USING mpid, tp.pnt;
	END IF;
	
	-- 최초 삽입은 아닐때
	IF(cnt_mpid > 0) THEN

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
				' set mpcount = mpcount+1, rect = st_combinebbox( rect::box2d, $1), end_time = $2, tpseg = array_append(tpseg, $3) 
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

	return f_trajectroy;
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE STRICT
COST 100;
ALTER FUNCTION TJ_append(trajectory, tpoint) OWNER TO postgres;


CREATE OR REPLACE FUNCTION tj_remove(trajectory, timestamp, integer) RETURNS trajectory AS
$$
DECLARE
	c_trajectory	alias for $1;
	start_time	alias for $2;
	time_interval	alias for $3;
	end_time	TIMESTAMP;
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


CREATE OR REPLACE FUNCTION tj_remove(trajectory, timestamp, timestamp) RETURNS trajectory AS
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
	
	traj_prefix	text;

	--row가 삭제시 필요한 next_id와 before_segid를 읽어오기 위한 변수
	new_next_segid			integer;
	new_before_segid		integer;
	-- 새로운 rect를 위한 변수
	new_rect			geometry;

BEGIN
	traj_prefix := 'mpseq_' ;
		
	f_trajectory_segtable_name := traj_prefix || c_trajectory.segtableoid ;

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
				IF( ( result_tp[i].ts >= start_time ) AND ( result_tp[i].ts <= end_time ) ) THEN
					EXECUTE 'UPDATE ' || quote_ident(f_trajectory_segtable_name) || 
						' SET tpseg[$1] = NULL WHERE mpid = ' || data.mpid || ' and segid = ' || data.segid 
					USING i;
				END IF;
					
				EXECUTE 'select tpseg[$1].pnt from ' || quote_ident(f_trajectory_segtable_name) || 
					' WHERE mpid = ' || data.mpid || ' and segid = ' || data.segid 
				INTO new_tpoint.pnt USING i;

				EXECUTE 'select tpseg[$1].ts from ' || quote_ident(f_trajectory_segtable_name) || 
					' WHERE mpid = ' || data.mpid || ' and segid = ' || data.segid 
				INTO new_tpoint.ts USING i;

				-- tpseg의 값을 수정하였다면 새로운 tpseg로 붙여주어 나중에 row에 새로운 tpseg로 변경해준다.
				IF( new_tpoint IS NOT NULL) THEN
					new_tpseg[j] := new_tpoint;

					EXECUTE 'update ' || quote_ident(f_trajectory_segtable_name) || 
					' set start_time = $1[(SELECT array_lower( $1 , 1))].ts , end_time = $1[(SELECT array_upper( $1 , 1))].ts ' ||
					'WHERE mpid = ' || data.mpid || ' and segid = ' || data.segid
					USING new_tpseg;

					-- while루프 안으로 들어왔다면 z	
					IF( j = 1) THEN
						execute 'update ' || quote_ident(f_trajectory_segtable_name) ||
							' set rect = ( select st_makebox2d( $1, $1) ) ' ||
							' where mpid = $2 and segid = $3'
						using new_tpseg[1].pnt, data.mpid, data.segid;
					ELSE
						execute 'select rect from ' || quote_ident(f_trajectory_segtable_name) ||
							' where mpid = $1 and segid = $2' 
						into new_rect using data.mpid, data.segid;
						execute 'update ' || quote_ident(f_trajectory_segtable_name) ||
							' set rect = ( select st_combinebbox( $1::box2d, $2.pnt ) ) ' ||
							' where mpid = $3 and segid = $4'
						using new_rect, new_tpseg[j], data.mpid, data.segid;
					END IF;
					j := j+1;
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
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION tj_slice(trajectory, timestamp, timestamp) RETURNS tpoint[] AS
$$
DECLARE
	c_trajectory	alias for $1;
	start_time	alias for $2;
	end_time	alias for $3;

	traj_prefix			char(50);
	traj_suffix			char(50);
	
	c_trajectory_segtable_name	char(200);
	
	data				RECORD;
	tp_seg		tpoint[];
	new_tpseg	tpoint[];
	i		integer;
	sql		text;
	
BEGIN
	-- traj_prefix := current_setting('traj.prefix');
	-- traj_suffix := current_setting('traj.suffix');
	
	traj_prefix := 'mpseq_' ;
		
	c_trajectory_segtable_name := traj_prefix || c_trajectory.segtableoid;
	
	sql := 'select * from ' || quote_ident(c_trajectory_segtable_name) || ' where mpid = ' || c_trajectory.moid || 
		' order by start_time';

	FOR data IN EXECUTE sql LOOP
		IF( data.start_time <= end_time OR data.end_time <= start_time ) THEN
			tp_seg := data.tpseg;

			i := 1;

			WHILE( i <= data.mpcount ) LOOP
				IF( tp_seg[i].ts >= start_time AND tp_seg[i].ts <= end_time ) THEN
					EXECUTE 'select array_append($1, $2)'
					INTO new_tpseg USING new_tpseg, tp_seg[i];
				END IF;
				i := i+1;
			END LOOP;
		END IF;
	END LOOP;

	RETURN new_tpseg;
END
$$
LANGUAGE 'plpgsql';


-- TJ_SLICE 함수 trajectory와 4개의 좌표를 입력한다. 
CREATE OR REPLACE FUNCTION tj_slice(trajectory, double precision, double precision, double precision, double precision)
  RETURNS tpoint[] AS
$BODY$
DECLARE
	x1				alias for $2;
	y1				alias for $3;
	x2				alias for $4;
	y2				alias for $5;
	f_trajectory			alias for $1;
	isIntersect_box2d		boolean;
	isOverlap_point			boolean;
	tpoint_MaxNumber		integer;
	nowTpsegNumber			integer;
	tpseg				tpoint[];
	user_rect			box2d;
	select_tpoint			tpoint;
	return_data			text;

	traj_prefix			char(50);
	traj_suffix			char(50);
	
	f_trajectory_segtable_name	char(200);
	
	sql				text;
	data				record;

	return_value			tpoint[];
    
BEGIN
	
	-- traj_prefix := current_setting('traj.prefix');
	-- traj_suffix := current_setting('traj.suffix');
	
	traj_prefix := 'mpseq_' ;
		
	f_trajectory_segtable_name := traj_prefix || f_trajectory.segtableoid;

	EXECUTE 'select st_makebox2d(st_point($1, $2), st_point($3, $4))'
	into user_rect using x1, y1, x2, y2;
	
	sql := 'select * from ' || quote_ident(f_trajectory_segtable_name) || ' where mpid = ' || f_trajectory.moid;
    
	FOR data IN EXECUTE sql LOOP
		execute 'select st_intersects(( select geometry( $1 ) ), ( select geometry( $2) ) )'
		into isIntersect_box2d using data.rect, user_rect;
        RAISE NOTICE 'rect intersects(%, %)', data.mpid, isIntersect_box2d;
		IF(isIntersect_box2d) THEN
			tpseg := data.tpseg;
			nowTpsegNumber := 1;
			sql := 'select array_upper($1, 1)';
			EXECUTE sql INTO tpoint_MaxNumber using tpseg;
			WHILE tpoint_MaxNumber >= nowTpsegNumber LOOP
				EXECUTE 'select st_intersects( ( select geometry( $1 ) ), $2)'
				INTO isOverlap_point USING user_rect, tpseg[nowTpsegNumber].pnt;
--                RAISE NOTICE 'point overlaps(%)', isOverlap_point;
				IF(isOverlap_point) THEN
					select_tpoint := tpseg[nowTpsegNumber];
					--execute 'select st_astext($1)'
					--into return_data using select_tpoint.p;
                    EXECUTE 'select array_append($1, $2)'
					INTO return_value USING return_value, select_tpoint;
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

-- TJ_SLICE 함수 trajectory와 geometry를 입력한다.
CREATE OR REPLACE FUNCTION tj_slice(trajectory, geometry)
  RETURNS tpoint[] AS
$BODY$
DECLARE
	input_geometry		alias for $2;
	f_trajectory			alias for $1;
	isIntersect_box2d		boolean;
	isOverlap_point			boolean;
	tpoint_MaxNumber		integer;
	nowTpsegNumber			integer;
	tpseg				tpoint[];
	select_tpoint			tpoint;
	return_data			text;

	traj_prefix			char(50);
	traj_suffix			char(50);
	
	f_trajectory_segtable_name	char(200);
	
	sql				text;
	data				record;

	return_value			tpoint[];
    
BEGIN
	
	-- traj_prefix := current_setting('traj.prefix');
	-- traj_suffix := current_setting('traj.suffix');
	
	traj_prefix := 'mpseq_' ;
		
	f_trajectory_segtable_name := traj_prefix || f_trajectory.segtableoid;

	sql := 'select * from ' || quote_ident(f_trajectory_segtable_name) || ' where mpid = ' || f_trajectory.moid;
    
	FOR data IN EXECUTE sql LOOP
		execute 'select st_intersects(( select geometry( $1 ) ), ( select geometry( $2) ) )'
		into isIntersect_box2d using data.rect, input_geometry;
        RAISE NOTICE 'rect intersects(%, %)', data.mpid, isIntersect_box2d;
		IF(isIntersect_box2d) THEN
			tpseg := data.tpseg;
			nowTpsegNumber := 1;
			sql := 'select array_upper($1, 1)';
			EXECUTE sql INTO tpoint_MaxNumber using tpseg;
			WHILE tpoint_MaxNumber >= nowTpsegNumber LOOP
				EXECUTE 'select st_intersects( ( select geometry( $1 ) ), $2)'
				INTO isOverlap_point USING input_geometry, tpseg[nowTpsegNumber].pnt;
--                RAISE NOTICE 'point overlaps(%)', isOverlap_point;
				IF(isOverlap_point) THEN
					select_tpoint := tpseg[nowTpsegNumber];
					--execute 'select st_astext($1)'
					--into return_data using select_tpoint.p;
                    EXECUTE 'select array_append($1, $2)'
					INTO return_value USING return_value, select_tpoint;
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

	traj_prefix			char(50);
	traj_suffix			char(50);
	
	f_trajectory_segtable_name	char(200);
	
	sql				text;
	data				record;

	return_value			tpoint[];
BEGIN
	
	-- traj_prefix := current_setting('traj.prefix');
	-- traj_suffix := current_setting('traj.suffix');
	
	traj_prefix := 'mpseq_' ;
		
	f_trajectory_segtable_name := traj_prefix || f_trajectroy.segtableoid || traj_suffix;

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
  
  
--traj와 영역을 주면 해당 영역에 교차하는 tpoint가 있는 segment의 모든 tpoint를 리턴해준다.
CREATE OR REPLACE FUNCTION getIntersectTpoint(trajectory, geometry) RETURNS tpoint[] AS
$$
DECLARE
	user_traj			alias for $1;
	input_geometry			alias for $2;
	
	traj_prefix			char(50);
	traj_suffix			char(50);
	
	f_trajectory_segtable_name	char(200);
	
	sql				text;
	data				record;
	isIntersect			boolean;
	intersect_tpseg			tpoint[];

BEGIN
	-- traj_prefix := current_setting('traj.prefix');
	-- traj_suffix := current_setting('traj.suffix');
		
	traj_prefix := 'mpseq_' ;
			
	f_trajectory_segtable_name := traj_prefix || user_traj.segtableoid || traj_suffix;
	
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
	
	traj_prefix			char(50);
	traj_suffix			char(50);
	
	f_trajectory_segtable_name	char(200);
	
	sql				text;
	data				record;
	rect				box2d;
BEGIN
	-- traj_prefix := current_setting('traj.prefix');
	-- traj_suffix := current_setting('traj.suffix');
	
	traj_prefix := 'mpseq_' ;
		
	f_trajectory_segtable_name := traj_prefix || user_traj.segtableoid || traj_suffix;
	
	sql := 'select * from ' || quote_ident(f_trajectory_segtable_name) || ' where mpid = ' || user_traj.moid;
	FOR data IN EXECUTE sql LOOP
		execute 'select getbbox( $1 )'
		into rect using data.rect;
		return next rect;
	END LOOP;
	
END
$$
LANGUAGE 'plpgsql';


-- Function: getStartTime(trajectory) RETURNS timestamp;

-- DROP FUNCTION getStartTime(trajectory);

CREATE OR REPLACE FUNCTION getStartTime(trajectory) RETURNS timestamp AS
$BODY$
DECLARE
	user_traj			alias for $1;

	traj_prefix			char(50);
	traj_suffix			char(50);
	
	f_trajectory_segtable_name	char(200);
	
	sql			text;

	start_time		TIMESTAMP;

	
BEGIN	
	-- traj_prefix := current_setting('traj.prefix');
	-- traj_suffix := current_setting('traj.suffix');
	
	traj_prefix := 'mpseq_' ;
		
	f_trajectory_segtable_name := traj_prefix || user_traj.segtableoid || traj_suffix;

	sql := 'select start_time from ' || quote_ident(f_trajectory_segtable_name) || ' where mpid = ' || user_traj.moid || ' and before_segid is null';
	EXECUTE sql INTO start_time;

	RETURN start_time;
END
$BODY$
LANGUAGE 'plpgsql' VOLATILE STRICT
COST 100;


-- Function: getEndTime(trajectory) RETURNS timestamp;

-- DROP FUNCTION getEndTime(trajectory);

CREATE OR REPLACE FUNCTION getEndTime(trajectory) RETURNS timestamp AS
$BODY$
DECLARE
	user_traj			alias for $1;

	traj_prefix			char(50);
	traj_suffix			char(50);
	
	f_trajectory_segtable_name	char(200);
	
	sql			text;

	end_time		TIMESTAMP;

	
BEGIN	
	
	-- traj_prefix := current_setting('traj.prefix');
	-- traj_suffix := current_setting('traj.suffix');
	
	traj_prefix := 'mpseq_' ;
		
	f_trajectory_segtable_name := traj_prefix || user_traj.segtableoid || traj_suffix;

	sql := 'select end_time from ' || quote_ident(f_trajectory_segtable_name) || ' where mpid = ' || user_traj.moid || ' and next_segid is null';
	EXECUTE sql INTO end_time;

	RETURN end_time;
END
$BODY$
LANGUAGE 'plpgsql' VOLATILE STRICT
COST 100;


-- Function: getTimeStamp(integer) RETURNS timestamp;

-- DROP FUNCTION getTimeStamp(integer);

CREATE OR REPLACE FUNCTION getTimeStamp(integer) RETURNS timestamp AS
$$
DECLARE
	input_interval		alias for $1;

	base_time		TIMESTAMP;

	data_time		TIMESTAMP;

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


-- Function: getTimeStamp(integer) RETURNS timestamp;

-- DROP FUNCTION getTimeStamp(integer);

CREATE OR REPLACE FUNCTION getTimeStamp(integer) RETURNS timestamp AS
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


/*
	FUNCTION : getTpointArrayInfo()
	Modify by : khyoo1221@gmail.com
	Modified Date : 2016-08-03
*/


CREATE OR REPLACE FUNCTION getTpointArrayInfo(tpoint[]) returns SETOF text AS
$$
DECLARE
	tpseg	alias for $1;

	max_size	integer;
	now_count	integer;
	tmp		record;
	
	return_data	text;

BEGIN
	execute 'select array_upper($1, 1)'
	into max_size using tpseg;
	now_count := 1;
	while max_size >= now_count loop
		execute 'select st_x($1) as x, st_y($1) as y, $2 as ts'
		into tmp using tpseg[now_count].pnt, tpseg[now_count].ts;

		return_data := tmp.x || ',' || tmp.y || ',' || tmp.ts;
		
		now_count := now_count + 1;
		return next return_data;
	end loop;
END
$$
language 'plpgsql';


--mpseg 테이블의 tpseg정보를 텍스트로 보기위한 함수
CREATE OR REPLACE FUNCTION getTpointArrayPointInfo(tpoint[]) returns SETOF text AS
$$
DECLARE
	tpseg	alias for $1;

	max_size	integer;
	now_count	integer;
	return_data	text;

BEGIN
	execute 'select array_upper($1, 1)'
	into max_size using tpseg;
	now_count := 1;
	while max_size >= now_count loop
		execute 'select st_astext($1)'
		into return_data using tpseg[now_count].pnt;
		now_count := now_count + 1;
		return next return_data;
	end loop;
END
$$
language 'plpgsql';


CREATE OR REPLACE FUNCTION getTrajectoryarrayinfo(tpoint[],  OUT tpoint text, OUT ptime_timestamp timestamp)
  RETURNS SETOF record AS
$BODY$
DECLARE
	tpseg	alias for $1;

	max_size	integer;
	now_count	integer;
	return_data	text;

BEGIN
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
END
$BODY$
LANGUAGE 'plpgsql' VOLATILE;


CREATE OR REPLACE FUNCTION getIntersectTpoint(trajectory, geometry) RETURNS tpoint[] AS
$$
DECLARE
	user_traj			alias for $1;
	input_geometry			alias for $2;
	
	traj_prefix			char(50);
	traj_suffix			char(50);
	
	f_trajectory_segtable_name	char(200);

	sql				text;
	data				record;
	isIntersect			boolean;
	intersect_tpseg			tpoint[];
	
BEGIN

	-- traj_prefix := current_setting('traj.prefix');
	-- traj_suffix := current_setting('traj.suffix');
	
	traj_prefix := 'mpseq_' ;
		
	f_trajectory_segtable_name := traj_prefix || user_traj.segtableoid || traj_suffix;
	
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




CREATE OR REPLACE FUNCTION tj_periods(timestamp, timestamp) RETURNS periods AS
$$
DECLARE
	start_time	alias for $1;
	end_time	alias for $2;
	p		periods;
BEGIN	
	p.starttime := start_time;
	p.endtime := end_time;

	RETURN p;
END
$$
  LANGUAGE 'plpgsql' VOLATILE STRICT
  COST 100;


CREATE OR REPLACE FUNCTION TJ_MINDISTANCE(trajectory, geometry) RETURNS mdouble AS
$$
DECLARE
	f_trajectory				alias for $1;
	input_geometry			alias for $2;
	f_trajectory_segtable_name		char(200);
	before_segid				integer;
	next_segid				integer;
	temp_tpseg				tpoint[];
	min_mdouble			mdouble;
	min_double				double precision;
	min_time					timestamp;
	temp_mindouble		double precision;
	sql						text;
	traj_prefix				char(50);
	data						record;
	i						integer;
	
BEGIN
	traj_prefix := 'mpseq_' ;
		
	f_trajectory_segtable_name := traj_prefix || f_trajectory.segtableoid;

	sql := 'select * from ' || quote_ident(f_trajectory_segtable_name) || ' where mpid = ' || f_trajectory.moid || 
		' order by start_time';
	
	min_double := 0;
	FOR data IN EXECUTE sql LOOP
		temp_tpseg := data.tpseg;
		i := 1;
		if min_double = 0 then
			sql := 'select st_distance($1, $2)';
			execute sql into min_double using temp_tpseg[1].pnt, input_geometry;
			min_mdouble.distance := min_double;
			min_mdouble.ts := temp_tpseg[1].ts;
			i := i+1;
		end if;
		WHILE( i <= data.mpcount ) LOOP
			sql := 'select st_distance($1, $2)';
			execute sql into temp_mindouble using temp_tpseg[i].pnt, input_geometry;
			if min_double > temp_mindouble then
				min_double := temp_mindouble;
				min_time := temp_tpseg[i].ts;
			end if;
			i := i+1;
		END LOOP;
	END LOOP;
	
	min_mdouble.distance := min_double;
    	if min_time is not null then 
		min_mdouble.ts := min_time;
	end if; 
	
	return min_mdouble;
	
END
$$
LANGUAGE 'plpgsql';
	

CREATE OR REPLACE FUNCTION TJ_MAXDISTANCE(trajectory, geometry) RETURNS mdouble AS
$$
DECLARE
	f_trajectory				alias for $1;
	input_geometry			alias for $2;
	f_trajectory_segtable_name		char(200);
	before_segid				integer;
	next_segid				integer;
	temp_tpseg				tpoint[];
	max_mdouble			mdouble;
	max_double				double precision;
	max_time					timestamp;
	temp_maxdouble		double precision;
	sql						text;
	traj_prefix				char(50);
	data						record;
	i						integer;
	
BEGIN
	traj_prefix := 'mpseq_' ;
		
	f_trajectory_segtable_name := traj_prefix || f_trajectory.segtableoid;

	sql := 'select * from ' || quote_ident(f_trajectory_segtable_name) || ' where mpid = ' || f_trajectory.moid || 
		' order by start_time';
	
	max_double := 0;
	FOR data IN EXECUTE sql LOOP
		temp_tpseg := data.tpseg;
		i := 1;
		if max_double = 0 then
			sql := 'select st_distance($1, $2)';
			execute sql into max_double using temp_tpseg[1].pnt, input_geometry;
			max_mdouble.distance := max_double;
			max_mdouble.ts := temp_tpseg[1].ts;
			i := i+1;
		end if;
		WHILE( i <= data.mpcount ) LOOP
			sql := 'select st_distance($1, $2)';
			execute sql into temp_maxdouble using temp_tpseg[i].pnt, input_geometry;
			if max_double < temp_maxdouble then
				max_double := temp_maxdouble;
				max_time := temp_tpseg[i].ts;
			end if;
			i := i+1;
		END LOOP;
	END LOOP;
	
	max_mdouble.distance := max_double;
    if max_time is not null then 
		max_mdouble.ts := max_time;
	end if; 
	
	return max_mdouble;
	
END
$$
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION TJ_CALCULATETPOINT(tpoint, tpoint, tpoint) RETURNS tpoint AS
$$
DECLARE
	tpoint1					alias for $1;
	tpoint2					alias for $2;
	tpoint3					alias for $3;
	
    time_period				double precision;
    p1time					double precision;
    p2time					double precision;
    d_input_time			double precision;
    
    x_distance				double precision;
    y_distance				double precision;
    time_per_distance_x		double precision;
    time_per_distance_y		double precision;
	x1						double precision;
    x2						double precision;
    y1						double precision;
    y2						double precision;
    new_x					double precision;
    new_y					double precision;
       
	sql						text;
    
    calculated_tpoint		tpoint;
BEGIN
	
    sql := 'select extract(epoch from $1)';
    execute sql into p1time using tpoint1.ts;
    raise notice 'p1time : %', p1time;
    
    sql := 'select extract(epoch from $1)';
    execute sql into p2time using tpoint2.ts;
    raise notice 'p2time : %', p2time;
    
    time_period := p2time - p1time;
    raise notice 'time_period : %', time_period;
    
    sql := 'select st_x($1)';
    execute sql into x1 using tpoint1.pnt;
    raise notice 'point x1 : %', x1;
    
    sql := 'select st_y($1)';
    execute sql into y1 using tpoint1.pnt;
    raise notice 'point y1 : %', y1;
    
    sql := 'select st_x($1)';
    execute sql into x2 using tpoint2.pnt;
    raise notice 'point x2 : %', x2;
    sql := 'select st_y($1)';
    execute sql into y2 using tpoint2.pnt;
    raise notice 'point x2 : %', y2;
    
    x_distance := x2 - x1;
    raise notice 'x_distance : %', x_distance;
    y_distance := y2 - y1;
    raise notice 'y_distance : %', y_distance;
    
    time_per_distance_x := x_distance / time_period;
    raise notice 'time_per_distance_x : %', time_per_distance_x;
    
    time_per_distance_y := y_distance / time_period;
    raise notice 'time_per_distance_y : %', time_per_distance_y;
    
	sql := 'select extract(epoch from $1)';
    execute sql into d_input_time using tpoint3.ts;
    raise notice 'd_input_time : %', d_input_time;
	
	
    if x2 - x1 > 0 then
    	new_x := time_per_distance_x * (p2time - d_input_time ) + ( x2 - x1 );
        raise notice 'p2time - d_input_time : %', p2time - d_input_time;
        raise notice 'new_x : %', new_x;
        
    else
    	new_x := x1;
    end if;
    
    if y2 - y1 > 0 then
		new_y := time_per_distance_y * (p2time - d_input_time ) + (y2 - y1);
	else
    	new_y = y1;
	end if;
    
    sql := 'select st_makepoint($1, $2)';
    execute sql into calculated_tpoint.pnt using new_x, new_y;
    
    calculated_tpoint.ts := tpoint3.ts;
    
    return calculated_tpoint;
	
END
$$
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION TJ_DISTANCE(trajectory, geometry) RETURNS mdouble[] AS
$$
DECLARE
	f_trajectory					alias for $1;
	input_geometry					alias for $2;
	f_trajectory_segtable_name		char(200);
	temp_tpseg						tpoint[];
	temp_distance					double precision;
	sql								text;
	traj_prefix						char(50);
	data							record;
	i								integer;
	result_value					mdouble[];
    temp_mdouble					mdouble;
	
BEGIN
	traj_prefix := 'mpseq_' ;
		
	f_trajectory_segtable_name := traj_prefix || f_trajectory.segtableoid;

	sql := 'select * from ' || quote_ident(f_trajectory_segtable_name) || ' where mpid = ' || f_trajectory.moid || 
		' order by start_time';
	
	FOR data IN EXECUTE sql LOOP
		temp_tpseg := data.tpseg;
		i := 1;
		WHILE( i <= data.mpcount ) LOOP
			sql := 'select st_distance($1, $2)';
			execute sql into temp_distance using temp_tpseg[i].pnt, input_geometry;
            temp_mdouble.distance := temp_distance;
            temp_mdouble.ts := temp_tpseg[i].ts;
			
			sql := 'select array_append($1, $2)';
			execute sql into result_value using result_value, temp_mdouble;
			raise notice '%', sql;
			i := i+1;
		END LOOP;
	END LOOP;
	
	return result_value;
	
END
$$
LANGUAGE 'plpgsql';

select taxi_id, tj_distance(traj, geometry('point( 345 275 )') )
from taxi;


CREATE OR REPLACE FUNCTION tj_getDistance(mdouble) RETURNS double precision AS
$$
DECLARE
	input_mdouble			alias for $1;

BEGIN
	
    return input_mdouble.distance;
	
END
$$
LANGUAGE 'plpgsql';



CREATE OR REPLACE FUNCTION TJ_PERIOD(trajectory) RETURNS periods AS
$$
DECLARE
	c_trajectory1					alias for $1;
    f_trajectory_segtable_name		char(200);
    traj_prefix						char(50);
    data							record;
	sql						text;
    new_period				periods;
    start_time				timestamp;
    end_time				timestamp;

BEGIN
	traj_prefix := 'mpseq_' ;
		
	f_trajectory_segtable_name := traj_prefix || c_trajectory1.segtableoid;
    
    sql := 'select * from ' || quote_ident(f_trajectory_segtable_name) || ' where mpid = ' || c_trajectory1.moid || 
		' order by start_time';
    start_time := null;
    end_time := null;
    FOR data IN EXECUTE sql LOOP
		if start_time is null then
        	start_time := data.start_time;
		else
        	if start_time > data.start_time then
            	start_time := data.start_time;
			end if;
		end if;
        
        if end_time is null then
        	end_time := data.end_time;
		else
        	if end_time < data.end_time then
            	end_time := data.end_time;
			end if;
		end if;
	END LOOP;
    
    new_period.startTime := start_time;
    new_period.endTime := end_time;
	
    return new_period;
	
END
$$
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION TJ_COMMONPERIOD(periods, periods) RETURNS periods AS
$$
DECLARE
	periods1					alias for $1;
    periods2					alias for $2;
    new_period					periods;

BEGIN
	IF periods1.startTime < periods2.startTime THEN
    	new_period.startTime := periods2.startTime;
	ELSE
    	new_period.startTime := periods1.startTime;
	END IF;
    
    IF periods1.endTime < periods2.endTime THEN
    	new_period.endTime := periods1.endTime;
	ELSE
    	new_period.endTime := periods2.endTime;
	END IF;

	return new_period;
	
END
$$
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION tj_getMidPOINT(tpoint, tpoint, timestamp) RETURNS tpoint AS
$$
DECLARE
	first_tpoint		alias for $1;
	second_tpoint		alias for $2;
	compare_time		alias for $3;
    
    first_time			double precision;
    second_time			double precision;
    base_time			double precision;
    time_difference		double precision;
    base_to_first_diff	double precision;
    
    first_point			geometry;
    second_point		geometry;
   
   	first_x				float;
    first_y				float;
    
    second_x			float;
    second_y			float;
    
    new_point_x			float;
    new_point_y			float;
    
    new_tpoint			tpoint;
	
    sql					text;
BEGIN

	sql := 'SELECT EXTRACT(EPOCH FROM $1)';
    execute sql into first_time using first_tpoint.ts;
        
    execute sql into second_time using second_tpoint.ts;
   
    execute sql into base_time using compare_time;
    
    time_difference := second_time - first_time;
    
    base_to_first_diff := base_time - first_time;

	first_point := first_tpoint.pnt;
    second_point := second_tpoint.pnt;

	sql := 'select st_x(st_centroid($1))';
    execute sql into first_x using first_point;
    
    sql := 'select st_y(st_centroid($1))';
    execute sql into first_y using first_point;
    
    sql := 'select st_x(st_centroid($1))';
    execute sql into second_x using second_point;
    
    sql := 'select st_y(st_centroid($1))';
    execute sql into second_y using second_point;
    
	new_point_x := first_x + ( ( second_x-first_x ) / time_difference * base_to_first_diff );
    raise notice 'new_x %', new_point_x;
    new_point_y := first_y + ( ( second_y-first_y ) / time_difference * base_to_first_diff );
	raise notice 'new_y %', new_point_y;

	sql := 'select st_point( $1, $2 )';
    execute sql into new_tpoint.pnt using new_point_x, new_point_y;
    
    new_tpoint.ts := compare_time;

	RETURN new_tpoint;
END
$$
LANGUAGE 'plpgsql';
