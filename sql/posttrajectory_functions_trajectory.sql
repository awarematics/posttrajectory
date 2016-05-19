
-- TJ_val(tpoint)
-- TJ_inst(tpoint)
-- TJ_present(tpoint[], TIMESTAMP)
-- TJ_trajectory(tpoint[])
-- TJ_length(tpoint[])
-- TJ_deftime(tpoint[])
-- TJ_atInstant(tpoint[], TIMESTAMP)
-- TJ_distance(geometry, geometry)
-- TJ_distance(tpoint[], tpoint[])
-- TJ_initial(tpoint[])
-- TJ_inside(geometry, geometry)
-- TJ_atPeriods(tpoint[], periods)
-- TJ_at(tpoint[], geometry)


-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : TJ_val(tpoint)
-- RETURNS : tpoint -> geometry
-- CREATED BY YOO KI HYUN

-- START TJ_val:

DROP FUNCTION IF EXISTS TJ_val(tpoint);

CREATE OR REPLACE FUNCTION TJ_val(tpoint) RETURNS geometry AS 
$$
DECLARE
	input_tpoint 	alias for $1;
BEGIN
	RETURN input_tpoint.pnt;
END
$$
LANGUAGE 'plpgsql';

-- END TJ_val:
------------------------------------------------------------------------------------------


-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : TJ_inst(tpoint)
-- RETURNS : tpoint -> TIMESTAMP
-- CREATED BY YOO KI HYUN

-- START TJ_inst:

DROP FUNCTION IF EXISTS TJ_inst(tpoint);

CREATE OR REPLACE FUNCTION TJ_inst(tpoint) RETURNS TIMESTAMP AS 
$$
DECLARE
	input_tpoint 	alias for $1;
BEGIN
	RETURN input_tpoint.ts;
END
$$

LANGUAGE 'plpgsql';

-- END TJ_inst:
------------------------------------------------------------------------------------------


-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : TJ_present(tpoint[], TIMESTAMP)
-- RETURNS : tpoint[], TIMESTAMP -> boolean
-- CREATED BY YOO KI HYUN

-- START TJ_present:

DROP FUNCTION IF EXISTS TJ_present(tpoint[], TIMESTAMP);

CREATE OR REPLACE FUNCTION TJ_present(tpoint[], TIMESTAMP) RETURNS boolean AS
$$
DECLARE
	tpoint_arr	alias for $1;
	instant		alias for $2;	
	
	startTime	Timestamp;
	endTime		Timestamp;
	
BEGIN
	startTime := TJ_inst(tpoint_arr[array_lower(tpoint_arr, 1)]);
	endTime := TJ_inst(tpoint_arr[array_upper(tpoint_arr, 1)]);
	
	IF (startTime <= instant AND endTime >= instant) THEN
		RETURN true;
	ELSE 
		RETURN false;
	END IF;

	RETURN false;
END
$$
LANGUAGE 'plpgsql';

-- END TJ_inst:
------------------------------------------------------------------------------------------


-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : TJ_trajectory(tpoint[])
-- RETURNS : tpoint[] -> geometry
-- CREATED BY YOO KI HYUN

-- START TJ_trajectory:

DROP FUNCTION IF EXISTS TJ_trajectory(tpoint[]);

CREATE OR REPLACE FUNCTION TJ_trajectory(tpoint[]) RETURNS geometry AS
$$
DECLARE
	tpoint_arr	alias for $1;
	
	temp		Text;
	txt_arr		Text[];

	result_traj	geometry;	
BEGIN
	temp := '';

	FOR i IN array_lower(tpoint_arr, 1)..array_upper(tpoint_arr, 1) LOOP
		temp := temp || cast(ST_X(TJ_val(tpoint_arr[i])) as Text) || ' ' || cast(ST_Y(TJ_val(tpoint_arr[i])) as Text);
		txt_arr := array_append(txt_arr, temp);
		
		temp := '';
	END LOOP;

	temp := '';

	FOR i IN array_lower(txt_arr, 1)..(array_upper(txt_arr, 1)-1) LOOP
		temp := temp || txt_arr[i] || ', ';
	END LOOP;

	temp := temp || txt_arr[array_upper(txt_arr, 1)];

	result_traj = ST_LineFromText('LINESTRING(' || temp || ')');
	
	RETURN result_traj;
	
END
$$
LANGUAGE 'plpgsql';

-- END TJ_trajectory:
------------------------------------------------------------------------------------------


-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : TJ_length(tpoint[])
-- RETURNS : tpoint[] -> real
-- CREATED BY YOO KI HYUN

-- START TJ_length:

DROP FUNCTION IF EXISTS TJ_length(tpoint[]);

CREATE OR REPLACE FUNCTION TJ_length(tpoint[]) RETURNS real AS
$$
DECLARE
	tpoint_arr	alias for $1;
	
	temp		Text;
	txt_arr		Text[];

	length		real;	
BEGIN
	temp := '';

	FOR i IN array_lower(tpoint_arr, 1)..array_upper(tpoint_arr, 1) LOOP
		temp := temp || cast(ST_X(TJ_val(tpoint_arr[i])) as Text) || ' ' || cast(ST_Y(TJ_val(tpoint_arr[i])) as Text);
		txt_arr := array_append(txt_arr, temp);
		
		temp := '';
	END LOOP;

	temp := '';

	FOR i IN array_lower(txt_arr, 1)..(array_upper(txt_arr, 1)-1) LOOP
		temp := temp || txt_arr[i] || ', ';
	END LOOP;

	temp := temp || txt_arr[array_upper(txt_arr, 1)];

	length = ST_Length(ST_LineFromText('LINESTRING(' || temp || ')'));

	RETURN length;
	
END
$$
LANGUAGE 'plpgsql';

-- END TJ_length:
------------------------------------------------------------------------------------------


-- FUNCTION DEFINITION
-- DESCRIPTION : Mpoint 를 입력받고, Mpoint의 PERIOD를 반환. 
-- NAME : TJ_deftime(tpoint[])
-- RETURNS : tpoint[] -> timestamp[]
-- CREATED BY YOO KI HYUN

-- START TJ_deftime:

DROP FUNCTION IF EXISTS TJ_deftime(tpoint[]);

CREATE OR REPLACE FUNCTION TJ_deftime(tpoint[]) RETURNS timestamp[] AS
$$
DECLARE
	tpoint_arr	alias for $1;
	
	time_arr	Timestamp[];

BEGIN
	time_arr[1] := TJ_inst(tpoint_arr[array_lower(tpoint_arr, 1)]);
	time_arr[2] := TJ_inst(tpoint_arr[array_upper(tpoint_arr, 1)]);

	RETURN time_arr;
END
$$
LANGUAGE 'plpgsql';

-- END TJ_deftime:
------------------------------------------------------------------------------------------




















-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : TJ_atInstant(tpoint[], TIMESTAMP)
-- RETURNS : tpoint[], TIMESTAMP -> tpoint
-- CREATED BY YOO KI HYUN

-- START TJ_atInstant:

DROP FUNCTION IF EXISTS TJ_atInstant(tpoint[], TIMESTAMP);

CREATE OR REPLACE FUNCTION TJ_atInstant(tpoint[], TIMESTAMP) RETURNS tpoint AS
$$
DECLARE
	tpoint_arr		alias for $1;
	instant			alias for $2;

	result_tpoint		tpoint;
BEGIN

	FOR i IN array_lower(tpoint_arr, 1)..(array_upper(tpoint_arr, 1)-1) LOOP
		IF (TJ_inst(tpoint_arr[i]) = instant) THEN
			result_tpoint = tpoint_arr[i];		
		ELSIF (TJ_inst(tpoint_arr[i]) < instant AND TJ_inst(tpoint_arr[i+1]) > instant) THEN
			result_tpoint = tpoint(UT_getMidPoint(tpoint_arr[i], tpoint_arr[i+1], instant), instant);
		--ELSIF (TJ_inst(tpoint_arr[1]) > instant || TJ_inst(tpoint_arr[array_upper(tpoint_arr, 1)]) < instant) THEN
			--result_tpoint = 		
		END IF;	
	END LOOP;
	
	IF (TJ_inst(tpoint_arr[array_upper(tpoint_arr, 1)]) = instant) THEN
		result_tpoint = tpoint_arr[array_upper(tpoint_arr, 1)];		
	END IF;	

	RETURN result_tpoint;
END
$$
LANGUAGE 'plpgsql';

-- END TJ_atInstant:
------------------------------------------------------------------------------------------



-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : TJ_distance(geometry, geometry)
-- RETURNS : geometry, geometry -> real
-- CREATED BY YOO KI HYUN

-- START TJ_distance:

DROP FUNCTION IF EXISTS TJ_distance(geometry, geometry);

CREATE OR REPLACE FUNCTION TJ_distance(geometry, geometry) RETURNS real AS
$$
DECLARE
	geom_line1	alias for $1;
	geom_line2	alias for $2;

	result_real	real;
BEGIN
	result_real = ST_Distance(geom_line1, geom_line2);

	RETURN result_real;
END
$$
LANGUAGE 'plpgsql';

-- END TJ_distance:
------------------------------------------------------------------------------------------



-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : TJ_distance(tpoint[], tpoint[])
-- RETURNS : tpoint[], tpoint[] -> real[]
-- CREATED BY YOO KI HYUN

-- START TJ_distance:

DROP FUNCTION IF EXISTS TJ_distance(tpoint[], tpoint[]);

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
-- NAME : TJ_initial(tpoint[])
-- RETURNS : tpoint[] -> tpoint
-- CREATED BY YOO KI HYUN

-- START TJ_initial:

DROP FUNCTION IF EXISTS TJ_initial(tpoint[]);

CREATE OR REPLACE FUNCTION TJ_initial(tpoint[]) RETURNS tpoint AS
$$
DECLARE
	tpoint_arr		alias for $1;

	result_tpoint		tpoint;
BEGIN
	result_tpoint = tpoint_arr[0];		
	
	RETURN result_tpoint;
END
$$
LANGUAGE 'plpgsql';

-- END TJ_initial:
------------------------------------------------------------------------------------------



-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : TJ_inside(geometry, geometry)
-- RETURNS : geometry, geometry -> boolean
-- CREATED BY YOO KI HYUN

-- START TJ_inside:

DROP FUNCTION IF EXISTS TJ_inside(geometry, geometry);

CREATE OR REPLACE FUNCTION TJ_inside(geometry, geometry) RETURNS boolean AS
$$
DECLARE
	geom_point	alias for $1;
	geom_region	alias for $2;

	result_bool	boolean;
BEGIN
	result_bool = ST_Within(geom_point, geom_region);

	RETURN result_bool;
END
$$
LANGUAGE 'plpgsql';

-- END TJ_inside:
------------------------------------------------------------------------------------------



-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : TJ_atPeriods(tpoint[], periods)
-- RETURNS : tpoint[], periods -> tpoint[]
-- CREATED BY YOO KI HYUN

-- START TJ_atPeriods:

DROP FUNCTION IF EXISTS TJ_atPeriods(tpoint[], periods);

CREATE OR REPLACE FUNCTION TJ_atPeriods(tpoint[], periods) RETURNS tpoint[] AS
$$
DECLARE
	tpoint_arr		alias for $1;
	input_periods		alias for $2;

	start_point		geometry;
	end_point		geometry;
	
	first_idx		int;
	last_idx		int;
	
	result_tpoint_arr	tpoint[];
BEGIN

	FOR i IN array_lower(tpoint_arr, 1)..array_upper(tpoint_arr, 1) LOOP
		IF (TJ_inst(tpoint_arr[i]) = input_periods.startTime) THEN
			first_idx = i;		
		ELSIF (TJ_inst(tpoint_arr[i]) = input_periods.endTime) THEN
			last_idx = i;
		END IF;	
	END LOOP;

	FOR i IN first_idx..last_idx LOOP
		result_tpoint_arr := tpoint_arr[i];
	END LOOP;

	RETURN result_tpoint_arr;
	
END
$$
LANGUAGE 'plpgsql';

-- END TJ_atPeriods:
------------------------------------------------------------------------------------------



-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : TJ_at(tpoint[], geometry)
-- RETURNS : tpoint[], geometry -> tpoint[]
-- CREATED BY YOO KI HYUN

-- START TJ_at:

DROP FUNCTION IF EXISTS TJ_at(tpoint[], geometry);

CREATE OR REPLACE FUNCTION TJ_at(tpoint[], geometry) RETURNS tpoint[] AS
$$
DECLARE
	tpoint_arr		alias for $1;
	input_region		alias for $2;

	temp_traj		geometry;
	
	result_geom		geometry;
	result_tpoint_arr	tpoint[];
BEGIN

	temp_traj = TJ_trajectory(tpoint_arr);

	result_geom = ST_intersection(temp_traj, input_region);

	RETURN result_tpoint_arr;
	
END
$$
LANGUAGE 'plpgsql';

-- END TJ_at:
------------------------------------------------------------------------------------------




-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : TJ_Passes(tpoint[], geometry)
-- RETURNS : tpoint[], geometry -> boolean
-- CREATED BY YOO KI HYUN

-- START TJ_Passes:

-- DROP FUNCTION TJ_Passes(tpoint[], geometry);

CREATE OR REPLACE FUNCTION TJ_Passes(tpoint[], geometry) RETURNS boolean AS
$$
DECLARE
	tpoint_arr	alias for $1;
	temp_geom	alias for $2;

	temp_line	geometry;
	temp_bool	boolean;
	
BEGIN
	temp_line := TJ_trajectory(tpoint_arr);


	temp_bool := ST_Intersects(temp_line, temp_geom);
	
	RETURN temp_bool;
	
END
$$
LANGUAGE 'plpgsql';

-- END TJ_Passes:
------------------------------------------------------------------------------------------



-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : _TJ_Passes(geometry, geometry, tpoint[])
-- RETURNS : geometry, geometry, tpoint[] -> boolean
-- CREATED BY YOO KI HYUN

-- START _TJ_Passes:

-- DROP FUNCTION _TJ_Passes(geometry, geometry, tpoint[]);

CREATE OR REPLACE FUNCTION _TJ_Passes(geom1 geometry, geom2 geometry, tpoint_arr tpoint[])
  RETURNS boolean AS
'SELECT $1 && $2 AND TJ_passes($3,$2)'
  LANGUAGE sql IMMUTABLE
  COST 100;
  
-- END _TJ_Passes:
------------------------------------------------------------------------------------------







