

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