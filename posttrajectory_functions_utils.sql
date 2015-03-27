

-- FUNCTION DEFINITION
-- DESCRIPTION : 두 개의 시공간 좌표와 그 사이의 시간값을 이용하여 시간값에서의 좌표를 구하는 함수
-- NAME : UT_getMidPoint(tpoint, tpoint, timestamp with time zone)
-- RETURNS : tpoint, tpoint, timestamp with time zone -> geometry
-- CREATED BY YOO KI HYUN

-- START UT_getMidPoint:

DROP FUNCTION IF EXISTS UT_getMidPoint(tpoint, tpoint, timestamp);

CREATE OR REPLACE FUNCTION UT_getMidPoint(tpoint, tpoint, timestamp) RETURNS geometry AS 
$$
DECLARE
	input_tpoint1 	alias for $1;
	input_tpoint2 	alias for $2;
	input_instant 	alias for $3;

	first_x1		float;
	first_y1		float;
	
	second_x2		float;
	second_y2		float;
	
	t1			float;
	t2			float;

	result_x		float;
	result_y		float;

	result_point		geometry;
BEGIN

	first_x1 = ST_X(input_tpoint1.point);	-- 첫번째 포인트의 X 좌표
	first_y1 = ST_Y(input_tpoint1.point);	-- 첫번째 포인트의 Y 좌표

	second_x2 = ST_X(input_tpoint2.point);	-- 두번째 포인트의 X 좌표
	second_y2 = ST_Y(input_tpoint2.point);	-- 두번째 포인트의 Y 좌표
	
	t1 = UT_getIntervalTime(input_tpoint1.t, input_instant);	-- 첫번째 시간 간격
	t2 = UT_getIntervalTime(input_instant, input_tpoint2.t);	-- 두번째 시간 간격

	result_x = (second_x2*t1 + first_x1*t2)/(t1+t2);	-- 결과 X 좌표
	result_y = (second_y2*t1 + first_y1*t2)/(t1+t2);	-- 결과 Y 좌표

	result_point = ST_Point(result_x, result_y);		-- 결과 포인트
	
	RETURN result_point;
END
$$
LANGUAGE 'plpgsql';


--TEST UT_getMidPoint


select ST_AsText(UT_getMidPoint(
	tpoint(st_point(1000, 1000), TIMESTAMP '2010-01-26 15:40:40+9'), 
	tpoint(st_point(1200, 1100), TIMESTAMP '2010-01-26 15:46:40+9'), 
	TIMESTAMP '2010-01-26 15:44:40+9'));


-- END UT_getMidPoint:
------------------------------------------------------------------------------------------



-- FUNCTION DEFINITION
-- DESCRIPTION : 주어진 두 시간에서의 시간 간격을 구하는 함수
-- NAME : UT_getIntervalTime(timestamp, timestamp)
-- RETURNS : timestamp, timestamp -> float
-- CREATED BY YOO KI HYUN

-- START UT_getIntervalTime:

DROP FUNCTION IF EXISTS UT_getIntervalTime(timestamp, timestamp);

CREATE OR REPLACE FUNCTION UT_getIntervalTime(timestamp with time zone, timestamp with time zone) RETURNS float AS 
$$
DECLARE
	input_t1 	alias for $1;
	input_t2 	alias for $2;

	result_t	float;
BEGIN

	result_t = extract(epoch from age(input_t2, input_t1));

	RETURN result_t;
END
$$
LANGUAGE 'plpgsql';


--TEST UT_getIntervalTime


select UT_getIntervalTime(TIMESTAMP '2010-01-26 15:47:40+9', TIMESTAMP '2010-01-26 15:55:40+9');


-- END UT_getIntervalTime:
------------------------------------------------------------------------------------------



-- FUNCTION DEFINITION
-- DESCRIPTION : 주어진 배열을 정렬하는 함수
-- NAME :  UT_array_sort(anyarray)
-- RETURNS : anyarray -> TABLE (sorted_array anyarray)
-- CREATED BY 

-- START UT_array_sort:

DROP FUNCTION IF EXISTS UT_array_sort(anyarray);

CREATE OR REPLACE FUNCTION UT_array_sort(array_vals_to_sort anyarray)	RETURNS TABLE (sorted_array anyarray) AS 
	$BODY$
		BEGIN
			RETURN QUERY SELECT
				ARRAY_AGG(val) AS sorted_array
			FROM
				(
					SELECT
						UNNEST(array_vals_to_sort) AS val
					ORDER BY
						val
				) AS sorted_vals
			;
		END;
	$BODY$
LANGUAGE plpgsql;

-- END UT_array_sort:
------------------------------------------------------------------------------------------



-- FUNCTION DEFINITION
-- DESCRIPTION : 주어진 배열의 중복을 제거하는 함수
-- NAME :  UT_array_unique(IN anyarray)
-- RETURNS : anyarray -> anyarray
-- CREATED BY 

-- START UT_array_unique:

DROP FUNCTION IF EXISTS UT_array_unique(IN anyarray);

CREATE OR REPLACE FUNCTION UT_array_unique(IN anyarray) RETURNS anyarray AS
	$BODY$
		SELECT ARRAY(
			SELECT DISTINCT $1[s.i] FROM generate_series(array_lower($1,1), array_upper($1,1)) AS s(i)	ORDER BY 1);
	$BODY$
LANGUAGE sql
	COST 100
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
	
-- END UT_array_unique:
------------------------------------------------------------------------------------------


