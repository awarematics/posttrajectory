
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


CREATE OR REPLACE FUNCTION append(trajectory, tpoint) RETURNS trajectory AS
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

	part_id				integer;
	cnt				integer;
	
	sql				text;

	next_segid			integer;
	max_tpseg_count			integer;
	tp_seg_size			integer;

	--새로운 row로 데이터 삽입을 할때 segid값을 정하기 위한 변수
	new_segid			integer;
BEGIN
	traj_prefix := current_setting('traj.prefix');
	traj_suffix := current_setting('traj.suffix');
		
	f_trajectory_segtable_name := traj_prefix || f_trajectroy.segtableoid || traj_suffix;

	-- tpseg_size 
	sql := 'select tpseg_size from trajectory_columns ' ||
		' where f_trajectory_segtable_name = ' || quote_literal(f_trajectory_segtable_name);
	RAISE DEBUG '%', sql;
	EXECUTE sql INTO tp_seg_size;	
 
	-- 최초로 삽입될 때
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
		
		-- partition_info => return id
		sql := 'select id from partition_info where st_intersects(partition, $1);';
		RAISE DEBUG '%', sql;
		EXECUTE sql INTO part_id USING tp.pnt;
		
		-- next_segid가 null인 segid값이 있고 tpseg가 꽉 차지 않았다면 현재 segid값에 데이터를 삽입
		IF( segid IS NOT NULL AND max_tpseg_count < tp_seg_size) THEN-----조건문에 tpseg의 최대값을 넣어줘야함. 현재는 3

			EXECUTE 'select count(*) from ' || quote_ident(f_trajectory_segtable_name) || ' where mpid = $1 and segid = $2 and partid = $3'			
			EXECUTE sql INTO cnt USING mpid, segid, part_id;

			IF( cnt > 0 ) THEN
		
				EXECUTE 'UPDATE ' || quote_ident(f_trajectory_segtable_name) || 
					' set mpcount = mpcount+1, rect = st_combine_bbox( rect::box2d, $1), end_time = $2, tpseg = array_append(tpseg, $3) 
					where mpid = $4 and segid = $5 '
				USING tp.pnt, tp.ts, tp, mpid, segid;
			ELSE

				EXECUTE 'UPDATE ' || quote_ident(f_trajectory_segtable_name) || 
					' set mpcount = mpcount+1, rect = st_combine_bbox( rect::box2d, $1), end_time = $2, tpseg = array_append(tpseg, $3) 
					where mpid = $4 and segid = $5 '
				USING tp.pnt, tp.ts, tp, mpid, segid;

				
				EXECUTE 'select MAX(segid) from ' || quote_ident(f_trajectory_segtable_name) || ' where mpid = $1'
				INTO new_segid USING mpid;

				EXECUTE 'INSERT INTO ' || quote_ident(f_trajectory_segtable_name) ||'(mpid, segid, before_segid, partid, mpcount, rect, start_time, end_time, tpseg) 
					VALUES( $1,  ' || new_segid+1 || ', $2, $4, 1, st_makebox2d( $3, $3), TIMESTAMP ' || quote_literal(tp.ts) || ' , TIMESTAMP ' || quote_literal(tp.ts) ||
					' , ARRAY[( $3 , TIMESTAMP ' || quote_literal(tp.ts) || ')]::tpoint[])'
				USING f_trajectroy.moid, segid, tp.pnt, part_id;
				
				-- 새로운 segid값에 데이터를 삽입후 전에 사용하던 segid에 next_segid값을 설정해준다.
				EXECUTE 'UPDATE ' || quote_ident(f_trajectory_segtable_name) || 
					' set next_segid = ' || new_segid+1 || ' where mpid = $1 and segid = $2'
				USING mpid, segid;
			
			END IF;
						
		-- next_segid가 null이 아니거나 tpseg가 꽉 찾다면 새로운 segid를 생성하여 데이터를 삽입하여야 한다. 
		ELSE 	
			-- next_segid가 null이 아니라면 새로운 row를 생성하여 삽입
			-- 삽입전 최대 segid값을 알아야 한다.
			EXECUTE 'select MAX(segid) from ' || quote_ident(f_trajectory_segtable_name) || ' where mpid = $1'
			INTO new_segid USING mpid;

			EXECUTE 'INSERT INTO ' || quote_ident(f_trajectory_segtable_name) ||'(mpid, segid, before_segid, partid, mpcount, rect, start_time, end_time, tpseg) 
				VALUES( $1,  ' || new_segid+1 || ', $2, $4, 1, st_makebox2d( $3, $3), TIMESTAMP ' || quote_literal(tp.ts) || ' , TIMESTAMP ' || quote_literal(tp.ts) ||
				' , ARRAY[( $3 , TIMESTAMP ' || quote_literal(tp.ts) || ')]::tpoint[])'
			USING f_trajectroy.moid, segid, tp.pnt, part_id;
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

