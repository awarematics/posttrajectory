
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

DROP FUNCTION append(trajectory, tpoint);

CREATE OR REPLACE FUNCTION append(trajectory, tpoint) RETURNS trajectory AS
$BODY$
DECLARE
	f_trajectroy			alias for $1;
	tp				alias for $2;

	traj_prefix			char(50);
	traj_suffix			char(50);
	
	f_trajectory_segtable_name	char(200);
	table_oid			char(100);
	mpid				integer;d
	segid				integer;
	mp_count			integer;
	mp_seq				record;

	part_id				integer;
	cnt_mpid			integer;
	cnt				integer;
	
	sql				text;

	next_segid			integer;
	tp_seg_size			integer;

	--새로운 row로 데이터 삽입을 할때 segid값을 정하기 위한 변수
	new_segid			integer;
BEGIN
	traj_prefix := current_setting('traj.prefix');
	traj_suffix := current_setting('traj.suffix');
		
	f_trajectory_segtable_name := traj_prefix || f_trajectroy.segtableoid || traj_suffix;

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

	-- partition_info => return id
	sql := 'SELECT id FROM partition_info WHERE ST_INTERSECTS(partition, $1);';
	RAISE DEBUG '%', sql;
	EXECUTE sql INTO part_id USING tp.pnt;
	
	-- 최초로 삽입될 때
	IF (cnt_mpid < 1) THEN
		-- RAISE NOTICE '최초 삽입';
		
		-- mpid, segid, start_time, end_time, tpseg 삽입
		EXECUTE 'INSERT INTO ' || quote_ident(f_trajectory_segtable_name) || '(mpid, segid, mpcount, partid, rect, start_time, end_time, tpseg) 
			VALUES($1, 1, 1, $2, st_makebox2d($3, $3), TIMESTAMP '|| quote_literal(tp.ts) || ', TIMESTAMP  '|| quote_literal(tp.ts) || ', ARRAY[($3, TIMESTAMP ' || quote_literal(tp.ts) || ')]::tpoint[])'
		USING mpid, part_id, tp.pnt;
	END IF;
	
	-- 최초 삽입은 아닐때
	IF(cnt_mpid > 0) THEN
		-- 삽입할 포인터의 row를 결정해 주어야 한다. 
		EXECUTE 'SELECT MAX(segid) FROM ' || quote_ident(f_trajectory_segtable_name) || ' WHERE mpid = $1'
		INTO segid USING mpid;
		
		-- tpseg가 꽉찼는지 확인하기 위하여 배열의 최대 크기를 가져온다
		sql := 'SELECT mpcount, tpseg FROM ' || quote_ident(f_trajectory_segtable_name) || ' WHERE mpid = ' || f_trajectroy.moid || ' AND segid = ' || segid;
		RAISE DEBUG '%', sql;
		EXECUTE sql INTO mp_seq;
		
		-- next_segid가 null인 segid값이 있고 tpseg가 꽉 차지 않았다면 현재 segid값에 데이터를 삽입
		IF(mp_seq.mpcount < tp_seg_size) THEN
			
			EXECUTE 'UPDATE ' || quote_ident(f_trajectory_segtable_name) || 
				' SET mpcount = mpcount+1, rect = st_combine_bbox(rect::box2d, $1), end_time = $2, tpseg = array_append(tpseg, $3) 
				WHERE mpid = $4 AND segid = $5 '
			USING tp.pnt, tp.ts, tp, mpid, segid;

			-- 현재 append 하려는 레코드의 partition_id 가 같은지를 검사하기 위한 count(*) 검색
			EXECUTE 'SELECT COUNT(*) FROM ' || quote_ident(f_trajectory_segtable_name) || ' WHERE mpid = $1 AND segid = $2 AND partid = $3'
			INTO cnt USING mpid, segid, part_id;

			-- cnt가 0일 경우, 현재 append 하려는 레코드의 partition_id 가 다름, 새로운 segid를 생성하고, 새로운 레코드의 처음으로 삽입
			IF(cnt < 1) THEN
				new_segid := segid + 1;

				EXECUTE 'INSERT INTO ' || quote_ident(f_trajectory_segtable_name) || '(mpid, segid, before_segid, mpcount, partid, rect, start_time, end_time, tpseg) 
					VALUES($1, ' || new_segid || ', $2, 2, $4, st_makebox2d( $3, $3 ), TIMESTAMP ' || quote_literal(tp.ts) || ' , TIMESTAMP ' || quote_literal(tp.ts) ||
					', ARRAY[($5), ($3, TIMESTAMP ' || quote_literal(tp.ts) || ')]::tpoint[])'
				USING mpid, segid, tp.pnt, part_id, mp_seq.tpseg[mp_seq.mpcount];
				
				-- 새로운 segid값에 데이터를 삽입후 전에 사용하던 segid에 next_segid값을 설정해준다.
				EXECUTE 'UPDATE ' || quote_ident(f_trajectory_segtable_name) || 
					' SET next_segid = ' || new_segid || ' WHERE mpid = $1 AND segid = $2'
				USING mpid, segid;
			END IF;
						
		-- tpseg가 꽉 찾다면 새로운 segid를 생성하여 데이터를 삽입하여야 한다. 
		ELSE 	
			-- next_segid가 null이 아니라면 새로운 row를 생성하여 삽입
			-- 삽입전 최대 segid값을 알아야 한다.
			new_segid := segid + 1;

			-- 현재 append 하려는 레코드의 partition_id 가 같은지를 검사하기 위한 count(*) 검색
			EXECUTE 'SELECT COUNT(*) FROM ' || quote_ident(f_trajectory_segtable_name) || ' WHERE mpid = $1 AND segid = $2 AND partid = $3'
			INTO cnt USING mpid, segid, part_id;

			-- cnt가 0일 경우, 현재 append 하려는 레코드의 partition_id 가 다름, 새로운 segid를 생성하고, 새로운 레코드의 처음으로 삽입
			IF(cnt < 1) THEN
				
				EXECUTE 'INSERT INTO ' || quote_ident(f_trajectory_segtable_name) || '(mpid, segid, before_segid, mpcount, partid, rect, start_time, end_time, tpseg) 
					VALUES($1, ' || new_segid || ', $2, 2, $4, st_makebox2d( $3, $3 ), TIMESTAMP ' || quote_literal(tp.ts) || ' , TIMESTAMP ' || quote_literal(tp.ts) ||
					', ARRAY[($5), ($3, TIMESTAMP ' || quote_literal(tp.ts) || ')]::tpoint[])'
				USING mpid, segid, tp.pnt, part_id, mp_seq.tpseg[mp_seq.mpcount];
			ELSE
				EXECUTE 'INSERT INTO ' || quote_ident(f_trajectory_segtable_name) ||'(mpid, segid, before_segid, mpcount, partid, rect, start_time, end_time, tpseg) 
					VALUES($1,  ' || new_segid+1 || ', $2, 1, $4, st_makebox2d( $3, $3 ), TIMESTAMP ' || quote_literal(tp.ts) || ' , TIMESTAMP ' || quote_literal(tp.ts) ||
					' , ARRAY[($3, TIMESTAMP ' || quote_literal(tp.ts) || ')]::tpoint[])'
				USING mpid, segid, tp.pnt, part_id;
			END IF;
			-- 새로운 segid값에 데이터를 삽입후 전에 사용하던 segid에 next_segid값을 설정해준다.
			EXECUTE 'UPDATE ' || quote_ident(f_trajectory_segtable_name) || 
				' SET next_segid = ' || new_segid+1 || ' WHERE mpid = $1 AND segid = $2'
			USING mpid, segid;
		END IF;
	END IF;

	return f_trajectroy;
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE STRICT
COST 100;
ALTER FUNCTION append(trajectory, tpoint) OWNER TO postgres;
COMMENT ON FUNCTION append(trajectory, tpoint) IS 'args: trajectory columl name, tpoint';

