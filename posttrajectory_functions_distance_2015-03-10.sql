

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
-- NAME : TT_distance(tpoint[], tpoint[])
-- RETURNS : tpoint[], tpoint[] -> mreal
-- CREATED BY YOO KI HYUN

-- START TT_distance:

-- DROP FUNCTION TT_distance(tpoint[], tpoint[]);

CREATE OR REPLACE FUNCTION TT_distance(tpoint[], tpoint[]) RETURNS mreal AS
$$
DECLARE
	geom_line1	alias for $1;
	geom_line2	alias for $2;

	result_real	mreal;
BEGIN
	result_real = ST_Distance(geom_line1, geom_line2);

	RETURN result_real;
END
$$
LANGUAGE 'plpgsql';

-- END TT_distance:
------------------------------------------------------------------------------------------