
select tpseg[57].ts from mpseq_1101138_traj where mpid = 9023 and segid=;

select * from mpseq_1101138_traj where mpid = 9023 and segid = 1;

select mpid, segid, start_time, end_time, rect, tpseg,
 count_rangeTime(tpseg, timestamp '2008-02-02 13:30:49', timestamp '2008-02-02 13:31:09')
 from mpseq_1101138_traj where mpid = 1 and segid = 1;

select sum(count_rangeTime(tpseg, timestamp '2008-02-02 13:30:49', timestamp '2008-02-02 13:44:09'))
 from mpseq_1101138_traj where mpid = 1 and segid = 1;


-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : count_rangeTime(tpoint[], timestamp, timestamp)
-- PARAMETER : tpoint[](tpoint Array), timestamp(시작 시간), timestamp(종료 시간)
-- RETURNS : integer(범위에 속하는 개수)
-- CREATED BY YOO KI HYUN

CREATE OR REPLACE FUNCTION count_rangeTime(tpoint[], timestamp, timestamp) RETURNS integer AS
$$
DECLARE
	input_tpArray		alias for $1;
	input_startTime		alias for $2;
	input_endTime		alias for $3;

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
		IF (input_tpArray[i].ts >= input_startTime AND input_tpArray[i].ts <= input_endTime) THEN
			result := result + 1;
		END IF;
	END LOOP;

	RETURN result;
END
$$
LANGUAGE 'plpgsql';


-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : count_rangeTime(tpoint[], varchar, varchar)
-- PARAMETER : tpoint[](tpoint Array), varchar(시작 시간), varchar(종료 시간)
-- RETURNS : integer(범위에 속하는 개수)
-- CREATED BY YOO KI HYUN

CREATE OR REPLACE FUNCTION count_rangeTime(tpoint[], varchar, varchar) RETURNS integer AS
$$
DECLARE
	input_tpArray		alias for $1;
	input_startTime		alias for $2;
	input_endTime		alias for $3;

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
		IF (input_tpArray[i].ts >= startTime AND input_tpArray[i].ts <= endTime) THEN
			result := result + 1;
		END IF;
	END LOOP;

	RETURN result;
END
$$
LANGUAGE 'plpgsql';

