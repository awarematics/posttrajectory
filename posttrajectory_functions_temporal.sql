
-- TT_BEGIN(periods)
-- TT_END(periods)
-- TT_PERIOD(TIMESTAMP, TIMESTAMP)
-- TT_Equals(periods, periods)
-- TT_Before(periods, periods)
-- TT_Meets(periods, periods)
-- TT_Overlaps(periods, periods)
-- TT_During(periods, periods)
-- TT_Starts(periods, periods)
-- TT_Finishes(periods, periods)
-- TT_Intersects(periods, periods)
-- TT_Isnull(periods)



-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : TT_BEGIN(periods)
-- RETURNS : periods -> TIMESTAMP
-- CREATED BY YOO KI HYUN

-- START TT_BEGIN:

-- DROP FUNCTION TT_BEGIN(periods);

CREATE OR REPLACE FUNCTION TT_BEGIN(periods) RETURNS TIMESTAMP AS 
$$
DECLARE
	input_period	alias for $1;
BEGIN
	RETURN input_period.startTime;
END
$$
LANGUAGE 'plpgsql';

-- END TT_BEGIN:
------------------------------------------------------------------------------------------


-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : TT_END(periods)
-- RETURNS : periods -> TIMESTAMP
-- CREATED BY YOO KI HYUN

-- START TT_END:

-- DROP FUNCTION TT_END(periods);

CREATE OR REPLACE FUNCTION TT_END(periods) RETURNS TIMESTAMP AS 
$$
DECLARE
	input_period 	alias for $1;
BEGIN
	RETURN input_period.endTime;
END
$$
LANGUAGE 'plpgsql';

-- END TT_END:
------------------------------------------------------------------------------------------


-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : TT_PERIOD(TIMESTAMP, TIMESTAMP)
-- RETURNS : TIMESTAMP, TIMESTAMP -> PERIODS
-- CREATED BY YOO KI HYUN

-- START TT_PERIOD:

-- DROP FUNCTION TT_PERIOD(TIMESTAMP, TIMESTAMP);

CREATE OR REPLACE FUNCTION TT_PERIOD(TIMESTAMP, TIMESTAMP) RETURNS periods AS 
$$
DECLARE
	startTime		alias for $1;
	endTime			alias for $2;
	result_periods		periods;
	
BEGIN
	result_periods.startTime := startTime;
	result_periods.endTime := endTime;	

	RETURN result_periods;
END
$$
LANGUAGE 'plpgsql';

-- END TT_PERIOD:
------------------------------------------------------------------------------------------


-- FUNCTION DEFINITION
-- DESCRIPTION : 두 개의 periods의 동등 확인
-- NAME : TT_Equals(periods, periods)
-- RETURNS : periods, periods -> boolean
-- CREATED BY YOO KI HYUN

-- START TT_Equals:

-- DROP FUNCTION TT_Equals(periods, periods);

CREATE OR REPLACE FUNCTION TT_Equals(periods, periods) RETURNS boolean AS
$$
DECLARE
	period1		alias for $1;
	period2		alias for $2;
	
BEGIN
	IF period1.startTime = period2.startTime 
		AND period1.endTime = period2.endTime THEN

		RETURN true;
	END IF;
	
	RETURN false;
END
$$
LANGUAGE 'plpgsql';

-- END TT_Equals:
------------------------------------------------------------------------------------------


-- FUNCTION DEFINITION
-- DESCRIPTION : 두 개의 periods의 Before 확인
-- NAME : TT_Before(periods, periods)
-- RETURNS : periods, periods -> boolean
-- CREATED BY YOO KI HYUN

-- START TT_Before:

-- DROP FUNCTION TT_Before(periods, periods);

CREATE OR REPLACE FUNCTION TT_Before(periods, periods) RETURNS boolean AS
$$
DECLARE
	period1		alias for $1;
	period2		alias for $2;
	
BEGIN
	IF period1.endTime < period2.startTime THEN

		RETURN true;
	END IF;
	
	RETURN false;
END
$$
LANGUAGE 'plpgsql';

-- END TT_Before:
------------------------------------------------------------------------------------------


-- FUNCTION DEFINITION
-- DESCRIPTION : 두 개의 periods의 연결 확인
-- NAME : TT_Meets(periods, periods)
-- RETURNS : periods, periods -> boolean
-- CREATED BY YOO KI HYUN

-- START TT_Meets:

-- DROP FUNCTION TT_Meets(periods, periods);

CREATE OR REPLACE FUNCTION TT_Meets(periods, periods) RETURNS boolean AS
$$
DECLARE
	period1		alias for $1;
	period2		alias for $2;
	
BEGIN
	IF period1.endTime = period2.startTime 
		OR period2.endTime = period1.startTime THEN

		RETURN true;
	END IF;
	
	RETURN false;
END
$$
LANGUAGE 'plpgsql';

-- END TT_Meets:
------------------------------------------------------------------------------------------


-- FUNCTION DEFINITION
-- DESCRIPTION : 두 개의 periods의 중첩 확인
-- NAME : TT_Overlaps(periods, periods)
-- RETURNS : period, period -> boolean
-- CREATED BY YOO KI HYUN

-- START TT_Overlaps:

-- DROP FUNCTION TT_Overlaps(periods, periods);

CREATE OR REPLACE FUNCTION TT_Overlaps(periods, periods) RETURNS boolean AS
$$
DECLARE
	period1		alias for $1;
	period2		alias for $2;
	
BEGIN
	IF (period1.startTime < period2.startTime AND period2.startTime < period1.endTime) 
		OR (period2.startTime < period1.startTime AND period1.startTime < period2.endTime) THEN

		RETURN true;
	END IF;
	
	RETURN false;
END
$$
LANGUAGE 'plpgsql';

-- END TT_Overlaps:
------------------------------------------------------------------------------------------


-- FUNCTION DEFINITION
-- DESCRIPTION : 두 개의 periods의 포함 확인
-- NAME : TT_During(periods, periods)
-- RETURNS : period, period -> boolean
-- CREATED BY YOO KI HYUN

-- START TT_During:

-- DROP FUNCTION TT_During(periods, periods);

CREATE OR REPLACE FUNCTION TT_During(periods, periods) RETURNS boolean AS
$$
DECLARE
	period1		alias for $1;
	period2		alias for $2;
	
BEGIN
	IF (period2.startTime < period1.startTime AND period1.endTime < period2.endTime) 
		OR (period1.startTime < period2.startTime AND period2.endTime < period1.endTime) THEN

		RETURN true;
	END IF;
	
	RETURN false;
END
$$
LANGUAGE 'plpgsql';

-- END TT_During:
------------------------------------------------------------------------------------------


-- FUNCTION DEFINITION
-- DESCRIPTION : 두 개의 periods의 시작점 확인
-- NAME : TT_Starts(periods, periods)
-- RETURNS : period, period -> boolean
-- CREATED BY YOO KI HYUN

-- START TT_Starts:

-- DROP FUNCTION TT_Starts(periods, periods);

CREATE OR REPLACE FUNCTION TT_Starts(periods, periods) RETURNS boolean AS
$$
DECLARE
	period1		alias for $1;
	period2		alias for $2;
	
BEGIN
	IF (period1.startTime = period2.startTime AND period1.endTime < period2.endTime) 
		OR (period1.startTime = period2.startTime AND period2.endTime < period1.endTime) THEN

		RETURN true;
	END IF;
	
	RETURN false;
END
$$
LANGUAGE 'plpgsql';

-- END TT_Starts:
------------------------------------------------------------------------------------------


-- FUNCTION DEFINITION
-- DESCRIPTION : 두 개의 periods의 끝나는점 확인
-- NAME : TT_Finishes(periods, periods)
-- RETURNS : period, period -> boolean
-- CREATED BY YOO KI HYUN

-- START TT_Finishes:

-- DROP FUNCTION TT_Finishes(periods, periods);

CREATE OR REPLACE FUNCTION TT_Finishes(periods, periods) RETURNS boolean AS
$$
DECLARE
	period1		alias for $1;
	period2		alias for $2;
	
BEGIN
	IF (period1.startTime < period2.startTime AND period1.endTime = period2.endTime) 
		OR (period2.startTime < period1.startTime AND period1.endTime = period2.endTime) THEN

		RETURN true;
	END IF;
	
	RETURN false;
END
$$
LANGUAGE 'plpgsql';

-- END TT_Finishes:
------------------------------------------------------------------------------------------


-- FUNCTION DEFINITION
-- DESCRIPTION : 두 개의 periods의 교차 확인
-- NAME : TT_Intersects(periods, periods)
-- RETURNS : period, period -> boolean
-- CREATED BY YOO KI HYUN

-- START TT_Intersects:

-- DROP FUNCTION TT_Intersects(periods, periods);

CREATE OR REPLACE FUNCTION TT_Intersects(periods, periods) RETURNS boolean AS
$$
DECLARE
	period1		alias for $1;
	period2		alias for $2;
	
BEGIN
	IF TT_Meets(period1, period2) OR TT_Overlaps(period1, period2)
		OR TT_During(period1, period2) OR TT_Starts(period1, period2) 
		OR TT_Finishes(period1, period2) THEN

		RETURN true;
	END IF;
	
	RETURN false;
END
$$
LANGUAGE 'plpgsql';

-- END TT_Intersects:
------------------------------------------------------------------------------------------


-- FUNCTION DEFINITION
-- DESCRIPTION : 한 개의 periods의 Null 확인
-- NAME : TT_Isnull(periods)
-- RETURNS : period, period -> boolean
-- CREATED BY YOO KI HYUN

-- START TT_Isnull:

-- DROP FUNCTION TT_Isnull(periods, periods);

CREATE OR REPLACE FUNCTION TT_Isnull(periods) RETURNS boolean AS
$$
DECLARE
	period1		alias for $1;
	
BEGIN
	IF period1.startTime = NULL OR period1.endTime = NULL THEN

		RETURN true;
	END IF;
	
	RETURN false;
END
$$
LANGUAGE 'plpgsql';

-- END TT_Isnull:
------------------------------------------------------------------------------------------

