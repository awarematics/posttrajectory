


-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : TT_Passes(tpoint[], geometry)
-- RETURNS : tpoint[], geometry -> boolean
-- CREATED BY YOO KI HYUN

-- START TT_Passes:

-- DROP FUNCTION TT_Passes(tpoint[], geometry);

CREATE OR REPLACE FUNCTION TT_Passes(tpoint[], geometry) RETURNS boolean AS
$$
DECLARE
	tpoint_arr	alias for $1;
	temp_geom	alias for $2;

	temp_line	geometry;
	temp_bool	boolean;
	
BEGIN
	temp_line := TT_trajectory(tpoint_arr);


	temp_bool := ST_Intersects(temp_line, temp_geom);
	
	RETURN temp_bool;
	
END
$$
LANGUAGE 'plpgsql';

-- END TT_Passes:
------------------------------------------------------------------------------------------



-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : _TT_Passes(geometry, geometry, tpoint[])
-- RETURNS : geometry, geometry, tpoint[] -> boolean
-- CREATED BY YOO KI HYUN

-- START _TT_Passes:

-- DROP FUNCTION _TT_Passes(geometry, geometry, tpoint[]);

CREATE OR REPLACE FUNCTION _TT_Passes(geom1 geometry, geom2 geometry, tpoint_arr tpoint[])
  RETURNS boolean AS
'SELECT $1 && $2 AND TT_passes($3,$2)'
  LANGUAGE sql IMMUTABLE
  COST 100;
  
-- END _TT_Passes:
------------------------------------------------------------------------------------------