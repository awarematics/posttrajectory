
-- TP_BEGIN(periods)
-- TP_END(periods)
-- TP_PERIOD(TIMESTAMP, TIMESTAMP)
-- TP_Equals(periods, periods)
-- TP_Before(periods, periods)
-- TP_Meets(periods, periods)
-- TP_Overlaps(periods, periods)
-- TP_During(periods, periods)
-- TP_Starts(periods, periods)
-- TP_Finishes(periods, periods)
-- TP_Intersects(periods, periods)
-- TP_Isnull(periods)



-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : TP_BEGIN(periods)
-- RETURNS : periods -> TIMESTAMP
-- CREATED BY YOO KI HYUN

-- START TP_BEGIN:

-- DROP FUNCTION TP_BEGIN(periods);

CREATE OR REPLACE FUNCTION TP_BEGIN(periods) RETURNS TIMESTAMP AS 
$$
DECLARE
	input_period	alias for $1;
BEGIN
	RETURN input_period.startTime;
END
$$
LANGUAGE 'plpgsql';

-- END TP_BEGIN:
------------------------------------------------------------------------------------------


-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : TP_END(periods)
-- RETURNS : periods -> TIMESTAMP
-- CREATED BY YOO KI HYUN

-- START TP_END:

-- DROP FUNCTION TP_END(periods);

CREATE OR REPLACE FUNCTION TP_END(periods) RETURNS TIMESTAMP AS 
$$
DECLARE
	input_period 	alias for $1;
BEGIN
	RETURN input_period.endTime;
END
$$
LANGUAGE 'plpgsql';

-- END TP_END:
------------------------------------------------------------------------------------------


-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : TP_PERIOD(TIMESTAMP, TIMESTAMP)
-- RETURNS : TIMESTAMP, TIMESTAMP -> PERIODS
-- CREATED BY YOO KI HYUN

-- START TP_PERIOD:

-- DROP FUNCTION TP_PERIOD(TIMESTAMP, TIMESTAMP);

CREATE OR REPLACE FUNCTION TP_PERIOD(TIMESTAMP, TIMESTAMP) RETURNS periods AS 
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

-- END TP_PERIOD:
------------------------------------------------------------------------------------------


-- FUNCTION DEFINITION
-- DESCRIPTION : 두 개의 periods의 동등 확인
-- NAME : TP_Equals(periods, periods)
-- RETURNS : periods, periods -> boolean
-- CREATED BY YOO KI HYUN

-- START TP_Equals:

-- DROP FUNCTION TP_Equals(periods, periods);

CREATE OR REPLACE FUNCTION TP_Equals(periods, periods) RETURNS boolean AS
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

-- END TP_Equals:
------------------------------------------------------------------------------------------


-- FUNCTION DEFINITION
-- DESCRIPTION : 두 개의 periods의 Before 확인
-- NAME : TP_Before(periods, periods)
-- RETURNS : periods, periods -> boolean
-- CREATED BY YOO KI HYUN

-- START TP_Before:

-- DROP FUNCTION TP_Before(periods, periods);

CREATE OR REPLACE FUNCTION TP_Before(periods, periods) RETURNS boolean AS
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

-- END TP_Before:
------------------------------------------------------------------------------------------


-- FUNCTION DEFINITION
-- DESCRIPTION : 두 개의 periods의 연결 확인
-- NAME : TP_Meets(periods, periods)
-- RETURNS : periods, periods -> boolean
-- CREATED BY YOO KI HYUN

-- START TP_Meets:

-- DROP FUNCTION TP_Meets(periods, periods);

CREATE OR REPLACE FUNCTION TP_Meets(periods, periods) RETURNS boolean AS
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

-- END TP_Meets:
------------------------------------------------------------------------------------------


-- FUNCTION DEFINITION
-- DESCRIPTION : 두 개의 periods의 중첩 확인
-- NAME : TP_Overlaps(periods, periods)
-- RETURNS : period, period -> boolean
-- CREATED BY YOO KI HYUN

-- START TP_Overlaps:

-- DROP FUNCTION TP_Overlaps(periods, periods);

CREATE OR REPLACE FUNCTION TP_Overlaps(periods, periods) RETURNS boolean AS
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

-- END TP_Overlaps:
------------------------------------------------------------------------------------------


-- FUNCTION DEFINITION
-- DESCRIPTION : 두 개의 periods의 포함 확인
-- NAME : TP_During(periods, periods)
-- RETURNS : period, period -> boolean
-- CREATED BY YOO KI HYUN

-- START TP_During:

-- DROP FUNCTION TP_During(periods, periods);

CREATE OR REPLACE FUNCTION TP_During(periods, periods) RETURNS boolean AS
$$
DECLARE
	period1		alias for $1;
	period2		alias for $2;
	
BEGIN
	IF (period2.startTime <= period1.startTime AND period1.endTime <= period2.endTime) 
		OR (period1.startTime <= period2.startTime AND period2.endTime <= period1.endTime) THEN

		RETURN true;
	END IF;
	
	RETURN false;
END
$$
LANGUAGE 'plpgsql';

-- END TP_During:
------------------------------------------------------------------------------------------


-- FUNCTION DEFINITION
-- DESCRIPTION : 두 개의 periods의 시작점 확인
-- NAME : TP_Starts(periods, periods)
-- RETURNS : period, period -> boolean
-- CREATED BY YOO KI HYUN

-- START TP_Starts:

-- DROP FUNCTION TP_Starts(periods, periods);

CREATE OR REPLACE FUNCTION TP_Starts(periods, periods) RETURNS boolean AS
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

-- END TP_Starts:
------------------------------------------------------------------------------------------


-- FUNCTION DEFINITION
-- DESCRIPTION : 두 개의 periods의 끝나는점 확인
-- NAME : TP_Finishes(periods, periods)
-- RETURNS : period, period -> boolean
-- CREATED BY YOO KI HYUN

-- START TP_Finishes:

-- DROP FUNCTION TP_Finishes(periods, periods);

CREATE OR REPLACE FUNCTION TP_Finishes(periods, periods) RETURNS boolean AS
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

-- END TP_Finishes:
------------------------------------------------------------------------------------------


-- FUNCTION DEFINITION
-- DESCRIPTION : 두 개의 periods의 교차 확인
-- NAME : TP_Intersects(periods, periods)
-- RETURNS : period, period -> boolean
-- CREATED BY YOO KI HYUN

-- START TP_Intersects:

-- DROP FUNCTION TP_Intersects(periods, periods);

CREATE OR REPLACE FUNCTION TP_Intersects(periods, periods) RETURNS boolean AS
$$
DECLARE
	period1		alias for $1;
	period2		alias for $2;
	
BEGIN
	IF TP_Meets(period1, period2) OR TP_Overlaps(period1, period2)
		OR TP_During(period1, period2) OR TP_Starts(period1, period2) 
		OR TP_Finishes(period1, period2) THEN

		RETURN true;
	END IF;
	
	RETURN false;
END
$$
LANGUAGE 'plpgsql';

-- END TP_Intersects:
------------------------------------------------------------------------------------------


-- FUNCTION DEFINITION
-- DESCRIPTION : 한 개의 periods의 Null 확인
-- NAME : TP_Isnull(periods)
-- RETURNS : period, period -> boolean
-- CREATED BY YOO KI HYUN

-- START TP_Isnull:

-- DROP FUNCTION TP_Isnull(periods, periods);

CREATE OR REPLACE FUNCTION TP_Isnull(periods) RETURNS boolean AS
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

-- END TP_Isnull:
------------------------------------------------------------------------------------------

