
-- FUNCTION TEST
-- 1), 2) 교차하지않는 직선과 교차하는 직선 테스트

-- postTrajectory 구현된 함수(UT_getIntersect, UT_getIntersectPoint) 테스트

-- 1) 교차하지 않는 직선

select UT_getIntersect(
	tpoint(st_point(1006, 1004), TIMESTAMP '2010-01-26 15:40:40+9'), 
	tpoint(st_point(1202, 1105), TIMESTAMP '2010-01-26 15:46:40+9'), 
	tpoint(st_point(2000, 1000), TIMESTAMP '2010-01-26 15:40:40+9'),
	tpoint(st_point(1105, 1200), TIMESTAMP '2010-01-26 15:40:40+9'));


select ST_AsText(UT_getIntersectPoint(
	tpoint(st_point(1006, 1004), TIMESTAMP '2010-01-26 15:40:40+9'), 
	tpoint(st_point(1202, 1105), TIMESTAMP '2010-01-26 15:46:40+9'), 
	tpoint(st_point(2000, 1000), TIMESTAMP '2010-01-26 15:40:40+9'),
	tpoint(st_point(1105, 1200), TIMESTAMP '2010-01-26 15:40:40+9')));

-- 2) 교차하는 직선

select UT_getIntersect(
	tpoint(st_point(1006, 1004), TIMESTAMP '2010-01-26 15:40:40+9'), 
	tpoint(st_point(1202, 1105), TIMESTAMP '2010-01-26 15:46:40+9'), 
	tpoint(st_point(2000, 1000), TIMESTAMP '2010-01-26 15:40:40+9'),
	tpoint(st_point(1105, 1100), TIMESTAMP '2010-01-26 15:40:40+9'));


select ST_AsText(UT_getIntersectPoint(
	tpoint(st_point(1006, 1004), TIMESTAMP '2010-01-26 15:40:40+9'), 
	tpoint(st_point(1202, 1105), TIMESTAMP '2010-01-26 15:46:40+9'), 
	tpoint(st_point(2000, 1000), TIMESTAMP '2010-01-26 15:40:40+9'),
	tpoint(st_point(1105, 1100), TIMESTAMP '2010-01-26 15:40:40+9')));

-- END:
------------------------------------------------------------------------------------------

-- PostGIS 함수(ST_Intersects, ST_Intersection) 테스트

-- 1) 교차하지 않는 직선

SELECT ST_Intersects(
	ST_GeomFromText('LINESTRING(1006 1004, 1202 1105)' ), 
	ST_GeomFromText('LINESTRING(2000 1000, 1205 1100)' ));


SELECT ST_AsText(ST_Intersection(
	ST_GeomFromText('LINESTRING(1006 1004, 1202 1105)' ), 
	ST_GeomFromText('LINESTRING(2000 1000, 1205 1100)' )));

-- 2) 교차하는 직선

SELECT ST_Intersects(
	ST_GeomFromText('LINESTRING(1006 1004, 1202 1105)' ), 
	ST_GeomFromText('LINESTRING(2000 1000, 1105 1100)' ));


SELECT ST_AsText(ST_Intersection(
	ST_GeomFromText('LINESTRING(1006 1004, 1202 1105)' ), 
	ST_GeomFromText('LINESTRING(2000 1000, 1105 1100)' )));

-- END:
------------------------------------------------------------------------------------------


-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : UT_getIntersect(tpoint, tpoint, tpoint, tpoint)
-- RETURNS : tpoint, tpoint, tpoint, tpoint -> boolean
-- CREATED BY YOO KI HYUN

-- START UT_getIntersect:

CREATE OR REPLACE FUNCTION UT_getIntersect(tpoint, tpoint, tpoint, tpoint) RETURNS boolean AS 
$$
DECLARE
	inputA_S 	alias for $1;
	inputA_F 	alias for $2;	
	inputB_S 	alias for $3;	
	inputB_F 	alias for $4;	

	t		float;
	_t		float;

	s		float;
	_s		float;

	under		float;

	a1_x		float;
	a1_y		float;
	
	a2_x		float;
	a2_y		float;

	b1_x		float;
	b1_y		float;
	
	b2_x		float;
	b2_y		float;
	
BEGIN

	a1_x = ST_X(inputA_S.point);	-- A의 스타트 포인트 X 좌표
	a1_y = ST_Y(inputA_S.point);	-- A의 스타트 포인트 Y 좌표

	a2_x = ST_X(inputA_F.point);	-- A의 피니시 포인트 X 좌표
	a2_y = ST_Y(inputA_F.point);	-- A의 피니시 포인트 Y 좌표

	b1_x = ST_X(inputB_S.point);	-- B의 스타트 포인트 X 좌표
	b1_y = ST_Y(inputB_S.point);	-- B의 스타트 포인트 Y 좌표

	b2_x = ST_X(inputB_F.point);	-- B의 피니시 포인트 X 좌표
	b2_y = ST_Y(inputB_F.point);	-- B의 피니시 포인트 Y 좌표
	
	under = (b2_y-b1_y)*(a2_x-a1_x) - (b2_x-b1_x)*(a2_y-a1_y);	-- 평행 인자 계산	

	RAISE NOTICE 'under is %', under;
	
	RAISE NOTICE 'a1_x is %', a1_x;
	RAISE NOTICE 'a1_y is %', a1_y;
	RAISE NOTICE 'a2_x is %', a2_x;
	RAISE NOTICE 'a2_y is %', a2_y;
	RAISE NOTICE 'b1_x is %', b1_x;
	RAISE NOTICE 'b1_y is %', b1_y;
	RAISE NOTICE 'b2_x is %', b2_x;
	RAISE NOTICE 'b2_y is %', b2_y;
	
	IF (under = 0) THEN
		RETURN false;
	END IF;

	_t = (b2_x-b1_x)*(a1_y-b1_y) - (b2_y-b1_y)*(a1_x-b1_x);
	_s = (a2_x-a1_x)*(a1_y-b1_y) - (a2_y-a1_y)*(a1_x-b1_x);

	t = _t/under;
	s = _s/under;
	
	IF (t<0.0 OR t>1.0 OR s<0.0 OR s>1.0) THEN 
		RETURN false;
	END IF;
	IF (_t = 0 AND _s = 0) THEN 
		RETURN false;
	END IF;
	
	RETURN true;
END
$$
LANGUAGE 'plpgsql';

-- END UT_getIntersect:
------------------------------------------------------------------------------------------



-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : UT_getIntersectPoint(tpoint, tpoint, tpoint, tpoint)
-- RETURNS : tpoint, tpoint, tpoint, tpoint -> geometry
-- CREATED BY YOO KI HYUN

-- START UT_getIntersectPoint:

CREATE OR REPLACE FUNCTION UT_getIntersectPoint(tpoint, tpoint, tpoint, tpoint) RETURNS geometry AS 
$$
DECLARE
	inputA_S 	alias for $1;
	inputA_F 	alias for $2;	
	inputB_S 	alias for $3;	
	inputB_F 	alias for $4;	

	t		float;
	_t		float;

	s		float;
	_s		float;

	under		float;

	a1_x		float;
	a1_y		float;
	
	a2_x		float;
	a2_y		float;

	b1_x		float;
	b1_y		float;
	
	b2_x		float;
	b2_y		float;
	
	result_x	float;
	result_y	float;

	result_point	geometry;
BEGIN

	a1_x = ST_X(inputA_S.point);	-- A의 스타트 포인트 X 좌표
	a1_y = ST_Y(inputA_S.point);	-- A의 스타트 포인트 Y 좌표

	a2_x = ST_X(inputA_F.point);	-- A의 피니시 포인트 X 좌표
	a2_y = ST_Y(inputA_F.point);	-- A의 피니시 포인트 Y 좌표

	b1_x = ST_X(inputB_S.point);	-- B의 스타트 포인트 X 좌표
	b1_y = ST_Y(inputB_S.point);	-- B의 스타트 포인트 Y 좌표

	b2_x = ST_X(inputB_F.point);	-- B의 피니시 포인트 X 좌표
	b2_y = ST_Y(inputB_F.point);	-- B의 피니시 포인트 Y 좌표
	
	under = (b2_y-b1_y)*(a2_x-a1_x) - (b2_x-b1_x)*(a2_y-a1_y);	-- 평행 인자 계산	

	RAISE NOTICE 'under is %', under;
	
	RAISE NOTICE 'a1_x is %', a1_x;
	RAISE NOTICE 'a1_y is %', a1_y;
	RAISE NOTICE 'a2_x is %', a2_x;
	RAISE NOTICE 'a2_y is %', a2_y;
	RAISE NOTICE 'b1_x is %', b1_x;
	RAISE NOTICE 'b1_y is %', b1_y;
	RAISE NOTICE 'b2_x is %', b2_x;
	RAISE NOTICE 'b2_y is %', b2_y;
	
	IF (under = 0) THEN
		RETURN ST_Point(0, 0);
	END IF;

	_t = (b2_x-b1_x)*(a1_y-b1_y) - (b2_y-b1_y)*(a1_x-b1_x);
	_s = (a2_x-a1_x)*(a1_y-b1_y) - (a2_y-a1_y)*(a1_x-b1_x);

	t = _t/under;
	s = _s/under;
	
	result_x = a1_x + t * (a2_x-a1_x);	-- 결과 X 좌표
	result_y = a1_y + t * (a2_y-a1_y);	-- 결과 Y 좌표

	result_point = ST_Point(result_x, result_y);		-- 결과 포인트

	IF (t<0.0 OR t>1.0 OR s<0.0 OR s>1.0) THEN 
		RETURN ST_Point(0, 0);
	END IF;
	IF (_t = 0 AND _s = 0) THEN 
		RETURN ST_Point(0, 0);
	END IF;
	
	RETURN result_point;
END
$$
LANGUAGE 'plpgsql';

-- END UT_getIntersectPoint:
------------------------------------------------------------------------------------------

