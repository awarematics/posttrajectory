slice  //  enter  // leave

slice : linestring과 area을 주었을때 영역을 나눈다.
인자값 : 궤적, 영역
리턴값 : set of trajectory[]

select * from stay((select traj from bus_100 where id = 1), 'LINESTRING(15000 18000, 30000 30000)');


-- 인터섹션 사용 예
select astext(	( select st_intersection( 
						( select geometryfromtext('LINESTRING(20 130, 80 170, 170 190, 140 70, 190 80, 210 140, 230 80, 210 90, 270 160, 350 120)' ) ) ,
						( select st_geometry('BOX(130 50, 300 220)'::box2d ) 
					     ) 
					  ) 
				  ) );


-- 인터섹션후 첫번째 라인스트링을 가져오기 select astext( select st_geometryn ( st_intersection ( geometry, geometry ) ) );
select astext( ( select st_geometryn( ( select st_intersection( 
						( select geometryfromtext('LINESTRING(20 130, 80 170, 170 190, 140 70, 190 80, 210 140, 230 80, 210 90, 270 160, 350 120)' ) ) ,
						( select st_geometry('BOX(130 50, 300 220)'::box2d ) 
					     ) 
					  ) 
				  ) , 1)
			  ) );


-- geometry의 갯수를 가져오기
select st_numgeometries(	( select st_intersection( 
						( select geometryfromtext('LINESTRING(20 130, 80 170, 170 190, 140 70, 190 80, 210 140, 230 80, 210 90, 270 160, 350 120)' ) ) ,
						( select st_geometry('BOX(130 50, 300 220)'::box2d ) 
					     ) 
					  ) 
				  ) );



enter : disjoint(geometry, geometry), overlap(geometry, geometry), inside(realte(geometry, geomety) = ..f..f...)

leave : inside(realte(geometry, geomety) = ..f..f...), overlap(geometry, geometry), disjoint(geometry, geomety)


pass = enter -> leave

select traj from bus_50 where trajectory_select(traj, TIMESTAMP '2011-01-01 00:00:00', TIMESTAMP '2011-01-02 00:00:00')


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
LANGUAGE 'plpgsql'

select array_upper( ( select getIntersectTpoint( ( select traj from pass_test where id = 1), st_geometry( 'BOX(17 6, 29 31)'::BOX2D) ) ), 1)



CREATE OR REPLACE FUNCTION aa_enter(trajectory, geometry, out starttime timestamp[], out endtime timestamp[]) AS
$$
DECLARE
	user_traj			alias for $1;
	input_geometry			alias for $2;
	f_trajectory_segtable_name	text;

	sql				text;
	data				record;
	isIntersect			boolean;

	intersect_tpseg			tpoint[];
	tpoint_to_Linestring		geometry;
	
	inetersectionLinestrings	geometry;
	differenceLinestrings		geometry;
	boundarypoint			geometry;
	
	differencecount			integer;
	intersectioncount		integer;

	isIntersects			boolean;
	isdisjoint			boolean;
	iscoveredby			boolean;
	isinside			boolean;

	i				integer;
	j				integer;
	tpoint_size			integer;
	nowtpointnumber			integer;
	lineequaltpoint			tpoint[];
	lineequaltpoint_size		integer;

	diffline			geometry;
	numberofdifflinetopoint		integer;
	intersectsdiff			geometry[];
	numberofintersectsdiff		integer;
	
	interline			geometry;
	numberofinterlinetopoint	integer;
	intersectsinner			geometry[];
	
	sequenceOfgeometry		geometry[];
	sequenceOfdiff_starttime	timestamp[];
	sequenceOfdiff_endtime		timestamp[];
	sequenceOfinter_starttime	timestamp[];
	sequenceOfinter_endtime		timestamp[];

	searchpoint			geometry;
	is_line_tp_equal		boolean;
		
	
BEGIN
	sql := 'select relname from pg_catalog.pg_class c
		where c.oid = '|| user_traj.segtableoid;
	RAISE DEBUG '%', sql;
	EXECUTE sql INTO f_trajectory_segtable_name;

	--traj의 모든 tpoint segment를 검색하여 주여진 영역과 intersection이 일어나는 영역들을 tpoint[]형태로 리턴
	EXECUTE 'select getIntersectTpoint( $1, $2 )' INTO intersect_tpseg USING user_traj, input_geometry;
	
	--구해진 tpoint[]를 geometry(point[])로 변환
	EXECUTE 'select tpoint_to_linestring( $1 )' INTO tpoint_to_Linestring USING intersect_tpseg;

	--구해진 linestring를 이용하여 intersetion과 difference를 실행한다.
	EXECUTE 'select st_intersection( $1, $2 )' INTO inetersectionLinestrings USING tpoint_to_Linestring, input_geometry;
	EXECUTE 'select st_difference( $1, $2 )' INTO differenceLinestrings USING tpoint_to_Linestring, input_geometry;
	
	-- 구해진 differencelinestring중에 해당 영역과 intersects 되는지를 확인한다.
	-- intersects가 되지 않는다면 해당 linestring는 검사할 필요가 없다.
	EXECUTE 'select st_numgeometries( $1 )' INTO differencecount USING differenceLinestrings;

	i := 1;
	nowtpointnumber := 1;
	
	EXECUTE 'select array_upper( $1, 1)' INTO tpoint_size USING intersect_tpseg;

	-- differencelinestring들중 해당 영역과 intersects 되는 라인만을 찾는다.
	WHILE ( differencecount >= i) LOOP
		-- i번째 diffenencelinestring를 가져온다.
		EXECUTE 'select st_geometryn( $1, $2)' INTO diffline USING differenceLinestrings, i;
		-- i번째 differencelinestring가 해당 영역과 intersects 되는지 확인
		EXECUTE 'select st_intersects( $1, $2 )' INTO isIntersects USING diffline, input_geometry;

		IF( isIntersects ) THEN
			EXECUTE 'select array_append($1, $2)' INTO intersectsdiff USING intersectsdiff, diffline;
		END IF;
	END LOOP;
	
	-- tpoint[i] 번째 점이 overlap되는 linestring를 찾는다.
	WHILE( intersect_tpseg > i ) LOOP
		EXECUTE 'select array_upper( $1, 1 )' INTO numberofintersectsdiff USING intersectsdiff;
		j := 1;
		WHILE ( intersectsdiff_size > j)
			EXECUTE 'select st_coverdby( $1, $2)' INTO is_line_tp_equal USING intersect_tpseg[i], intersectsdiff[j];
			IF( is_line_tp_equal ) THEN
				EXECUTE 'select array_append( $1, $2)' INTO lineequaltpoint USING lineequaltpoint, intersect_tpseg[i];
				i := i+1;
				EXIT;
			END IF;
		END LOOP;
		
	--linestring의 순서대로 검사 
	WHILE( differencecount >= i) LOOP
		-- differencelinstrings에서 line를 하나씩 가져온다.
		sql := 'select st_geometryn( $1, $2 )';
		EXECUTE sql INTO diffline USING differenceLinestrings, i;
		raise notice 'differenceLinestrings, i : %', diffline;

		-- 주어진 linestring에 일치하는 tpoint[]를 찾는다.
		-- 먼저 linestring의 point갯수를 가져와서 tpoint[]의 현재 점부터 검사를 한다.  
		sql := 'select st_numpoints( $1 )';
		EXECUTE sql INTO numberofdifflinetopoint USING diffline;
		raise notice 'numberofdifflinetopoint 에 데이터 삽입 : %',numberofdifflinetopoint;
	
		nowtpointnumber := 1;
		j := 1;
		WHILE(  numberofdifflinetopoint > j  AND nowtpointnumber <= tpoint_size ) LOOP
			-- linestring의 point와 tpoint의 현재 point을 비교하기 위하여 linestring의 point을 가져온다.
			--EXECUTE 'select st_pointn( $1, $2 )' INTO searchpoint USING diffline, j;

			EXECUTE 'select st_coveredby( $1, $2 )' INTO is_line_tp_equal USING intersect_tpseg[nowtpointnumber].p, diffline;

			IF(is_line_tp_equal) THEN
				--만약 linestring의 point와 tpoint의 point가 같다면 lineequaltpoint에 tpoint를 삽입해준다.
				sql := 'select array_append( $1, $2)';
				EXECUTE sql INTO lineequaltpoint USING lineequaltpoint, intersect_tpseg[nowtpointnumber];
				raise notice 'tpoint[] 에 데이터 삽입%', sql;
				j := j+1;
				nowtpointnumber := nowtpointnumber+1;
				
			ELSE
				IF( numberofdifflinetopoint > 2 AND j = 1 ) THEN
				j := j + 1;
				RAISE notice 'j 출력 : ,  %' , j;
				ELSE
				-- 같지 않다면 lineequaltpoint를 초기화 해주고 linestring의 처음부터 다시 검사.
					lineequaltpoint := null;
					
					j := 1;
					nowtpointnumber := nowtpointnumber+1;
				END IF;
			END IF;
		END LOOP;
		
		IF( lineequaltpoint IS NOT NULL ) THEN
			--EXECUTE 'select st_pointn( $1, $2 )' INTO searchpoint USING diffline, numberofdifflinetopoint;

			EXECUTE 'select st_coveredby( $1, $2 )' INTO is_line_tp_equal USING intersect_tpseg[nowtpointnumber].p, diffline;

			IF(is_line_tp_equal) THEN
				EXECUTE 'select array_append( $1, $2)' INTO lineequaltpoint USING lineequaltpoint, intersect_tpseg[nowtpointnumber];
				nowtpointnumber := nowtpointnumber+1;
			ELSE
				
			END IF;
			EXECUTE 'select array_upper( $1, 1 )' INTO lineequaltpoint_size USING lineequaltpoint;			
		END IF;
		sequenceOfdiff_starttime[i] := lineequaltpoint[1].ptime;
		sequenceOfdiff_endtime[i] := lineequaltpoint[lineequaltpoint_size].ptime;

		i := i + 1;
	END LOOP;

	starttime := sequenceOfdiff_starttime;
	endtime := sequenceOfdiff_endtime;
		
END
$$
LANGUAGE 'plpgsql'

select aa_enter( ( select traj from pass_test where id = 1) , (select st_geometry('BOX(17 6, 29 31)'::box2d) ) )