

-- TYPE DEFINITION
-- DESCRIPTION : 
-- NAME : mreal
-- CREATED BY YOO KI HYUN

-- START TYPE mreal:

-- DROP TYPE mreal;

CREATE TYPE mreal as(
	mreal		real[]
);

-- END TYPE mreal:
------------------------------------------------------------------------------------------



-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : TJ_distance(tpoint[], tpoint[])
-- RETURNS : tpoint[], tpoint[] -> mreal
-- CREATED BY YOO KI HYUN

-- START TJ_distance:

-- DROP FUNCTION TJ_distance(tpoint[], tpoint[]);

CREATE OR REPLACE FUNCTION TJ_distance(tpoint[], tpoint[]) RETURNS real[] AS
$$
DECLARE
	mp1	alias for $1;
	mp2	alias for $2;

	i 		int;
	timeArr		TIMESTAMP[];

	tp1		tpoint;
	tp2		tpoint;
	distance	real;
	
	aMreal		real[];
	
BEGIN

	timeArr = UT_getSweepTimes( mp1, mp2 );
	
	FOR i IN 1..(array_length(timeArr, 1)) LOOP	
		tp1 := TJ_atInstant(mp1, timeArr[i]);
		tp2 := TJ_atInstant(mp2, timeArr[i]);
		
		distance = ST_Distance( tp1.point, tp2.point );
		aMreal[i] := distance;
	END LOOP;

	RETURN aMreal;
END
$$
LANGUAGE 'plpgsql';

-- END TJ_distance:
------------------------------------------------------------------------------------------



-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : UT_getSweepTimes(tpoint[], tpoint[])
-- RETURNS : tpoint[], tpoint[] -> TIMESTAMP[]
-- CREATED BY YOO KI HYUN

-- START UT_getSweepTimes:

-- DROP FUNCTION UT_getSweepTimes(tpoint[], tpoint[]);


CREATE OR REPLACE FUNCTION UT_getSweepTimes(tpoint[], tpoint[]) RETURNS TIMESTAMP[] AS
$$
DECLARE
	mp1	alias for $1;
	mp2	alias for $2;
	mp3	tpoint[];
	
	i 			int;
	timeArr		TIMESTAMP[];	
BEGIN

	mp3 := array_cat(mp1, mp2);

	FOR i IN 1..(array_length(mp3, 1)) LOOP
	
	timeArr[i] := mp3[i].t;	
	--RAISE NOTICE 'i is %', timeArr[i];	
	
	END LOOP;

	timeArr = array_sort(array_unique(timeArr));
	
	RETURN timeArr;
END
$$
LANGUAGE 'plpgsql';

-- END UT_getSweepTimes:
------------------------------------------------------------------------------------------

 
