

select tpseg[57].ts from mpseq_1101138_traj where mpid = 9023 and segid=;

select * from mpseq_1101138_traj where mpid = 9023 and segid = 1;

select mpid, segid, start_time, end_time, rect, tpseg,
 count_rangeSpatioTemporal(tpseg, 0.0, 0.0, 360.0, 180.0, timestamp '2008-02-02 13:30:44', timestamp '2008-02-08 17:39:19')
 from mpseq_1816933_traj where mpid = 1 and segid = 1;

select sum(count_rangeSpatioTemporal(tpseg, 0.0, 0.0, 360.0, 180.0, timestamp '2008-02-02 13:30:44', timestamp '2008-02-08 17:39:19'))
 from mpseq_1816933_traj where mpid = 1 and segid = 1;

select sum(count_rangeSpatioTemporal(tpseg, 0.0, 0.0, 360.0, 180.0, timestamp '2008-02-02 13:30:44', timestamp '2008-02-08 17:39:19'))
 from mpseq_1816933_traj;

select sum(count_rangeSpatioTemporal(tpseg, 116.0, 39.0, 117.0, 41.0, '2008-02-02 13:30:44', '2008-02-08 17:39:19'))
 from mpseq_1816933_traj;


-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : count_rangeSpatioTemporal(tpoint[], float, float, float, float, timestamp, timestamp)
-- PARAMETER : tpoint[](tpoint Array), float(X min), float(Y min), float(X max), float(Y max), timestamp(시작 시간), timestamp(종료 시간)
-- RETURNS : integer(범위에 속하는 개수)
-- CREATED BY YOO KI HYUN

CREATE OR REPLACE FUNCTION count_rangeSpatioTemporal(tpoint[], float, float, float, float, timestamp, timestamp) RETURNS integer AS
$$
DECLARE
	input_tpArray		alias for $1;
	input_minx		alias for $2;
	input_miny		alias for $3;
	input_maxx		alias for $4;
	input_maxy		alias for $5;
	input_startTime		alias for $6;
	input_endTime		alias for $7;
	
	sql_text	varchar;

	i		integer;
	array_length	integer;

	result		integer;
BEGIN	
	EXECUTE 'SELECT ARRAY_LENGTH($1, 1)'
	INTO array_length USING input_tpArray;

	i := 0;
	result := 0;
	
	FOR i IN 1..array_length LOOP
		IF (ST_X(input_tpArray[i].pnt) >= input_minx AND ST_X(input_tpArray[i].pnt) <= input_maxx) AND 
		 (ST_Y(input_tpArray[i].pnt) >= input_miny AND ST_Y(input_tpArray[i].pnt) <= input_maxy) AND 
		 (input_tpArray[i].ts >= input_startTime AND input_tpArray[i].ts <= input_endTime) THEN
			result := result + 1;
		else
			-- raise notice 'x : %, y : %', ST_X(input_tpArray[i].pnt), ST_Y(input_tpArray[i].pnt);
		END IF;
	END LOOP;

	RETURN result;
END
$$
LANGUAGE 'plpgsql';


-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : count_rangeSpatioTemporal(tpoint[], float, float, float, float, varchar, varchar)
-- PARAMETER : tpoint[](tpoint Array), float(X min), float(Y min), float(X max), float(Y max), varchar(시작 시간), varchar(종료 시간)
-- RETURNS : integer(범위에 속하는 개수)
-- CREATED BY YOO KI HYUN

CREATE OR REPLACE FUNCTION count_rangeSpatioTemporal(tpoint[], float, float, float, float, varchar, varchar) RETURNS integer AS
$$
DECLARE
	input_tpArray		alias for $1;
	input_minx		alias for $2;
	input_miny		alias for $3;
	input_maxx		alias for $4;
	input_maxy		alias for $5;
	input_startTime		alias for $6;
	input_endTime		alias for $7;

	startTime	timestamp;
	endTime		timestamp;

	sql_text	varchar;

	i		integer;
	array_length	integer;

	result		integer;
BEGIN	
	EXECUTE 'SELECT ARRAY_LENGTH($1, 1)'
	INTO array_length USING input_tpArray;

	startTime := input_startTime;
	endTime := input_endTime;
	
	i := 0;
	result := 0;
	
	FOR i IN 1..array_length LOOP
		IF (ST_X(input_tpArray[i].pnt) >= input_minx AND ST_X(input_tpArray[i].pnt) <= input_maxx) AND 
		 (ST_Y(input_tpArray[i].pnt) >= input_miny AND ST_Y(input_tpArray[i].pnt) <= input_maxy) AND 
		 (input_tpArray[i].ts >= startTime AND input_tpArray[i].ts <= endTime) THEN
			result := result + 1;
		else
			-- raise notice 'x : %, y : %', ST_X(input_tpArray[i].pnt), ST_Y(input_tpArray[i].pnt);
		END IF;
	END LOOP;

	RETURN result;
END
$$
LANGUAGE 'plpgsql';