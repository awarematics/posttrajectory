
-- TT_val(tpoint)
-- TT_inst(tpoint)
-- TT_present(tpoint[], TIMESTAMP)
-- TT_trajectory(tpoint[])
-- TT_length(tpoint[])
-- TT_deftime(tpoint[])



-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : TT_val(tpoint)
-- RETURNS : tpoint -> geometry
-- CREATED BY YOO KI HYUN

-- START TT_val:

-- DROP FUNCTION TT_val(tpoint);

CREATE OR REPLACE FUNCTION TT_val(tpoint) RETURNS geometry AS 
$$
DECLARE
	input_tpoint 	alias for $1;
BEGIN
	RETURN input_tpoint.p;
END
$$
LANGUAGE 'plpgsql';

-- END TT_val:
------------------------------------------------------------------------------------------


-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : TT_inst(tpoint)
-- RETURNS : tpoint -> TIMESTAMP
-- CREATED BY YOO KI HYUN

-- START TT_inst:

-- DROP FUNCTION TT_inst(tpoint);

CREATE OR REPLACE FUNCTION TT_inst(tpoint) RETURNS TIMESTAMP AS 
$$
DECLARE
	input_tpoint 	alias for $1;
BEGIN
	RETURN input_tpoint.ptime;
END
$$

LANGUAGE 'plpgsql';

-- END TT_inst:
------------------------------------------------------------------------------------------


-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : TT_present(tpoint[], TIMESTAMP)
-- RETURNS : tpoint[], TIMESTAMP -> boolean
-- CREATED BY YOO KI HYUN

-- START TT_present:

-- DROP FUNCTION TT_present(tpoint[], TIMESTAMP);

CREATE OR REPLACE FUNCTION TT_present(tpoint[], TIMESTAMP) RETURNS boolean AS
$$
DECLARE
	tpoint_arr	alias for $1;
	instant		alias for $2;	
	
	startTime	Timestamp;
	endTime		Timestamp;
	
BEGIN
	startTime := TT_inst(tpoint_arr[array_lower(tpoint_arr, 1)]);
	endTime := TT_inst(tpoint_arr[array_upper(tpoint_arr, 1)]);
	
	IF (startTime <= instant AND endTime >= instant) THEN
		RETURN true;
	ELSE 
		RETURN false;
	END IF;

	RETURN false;
END
$$
LANGUAGE 'plpgsql';

-- END TT_inst:
------------------------------------------------------------------------------------------


-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : TT_trajectory(tpoint[])
-- RETURNS : tpoint[] -> geometry
-- CREATED BY YOO KI HYUN

-- START TT_trajectory:

-- DROP FUNCTION TT_trajectory(tpoint[]);

CREATE OR REPLACE FUNCTION TT_trajectory(tpoint[]) RETURNS geometry AS
$$
DECLARE
	tpoint_arr	alias for $1;
	
	temp		Text;
	txt_arr		Text[];

	result_traj	geometry;	
BEGIN
	temp := '';

	FOR i IN array_lower(tpoint_arr, 1)..array_upper(tpoint_arr, 1) LOOP
		temp := temp || cast(ST_X(TT_val(tpoint_arr[i])) as Text) || ' ' || cast(ST_Y(TT_val(tpoint_arr[i])) as Text);
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

-- END TT_trajectory:
------------------------------------------------------------------------------------------


-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : TT_length(tpoint[])
-- RETURNS : tpoint[] -> real
-- CREATED BY YOO KI HYUN

-- START TT_length:

-- DROP FUNCTION TT_length(tpoint[]);

CREATE OR REPLACE FUNCTION TT_length(tpoint[]) RETURNS real AS
$$
DECLARE
	tpoint_arr	alias for $1;
	
	temp		Text;
	txt_arr		Text[];

	length		real;	
BEGIN
	temp := '';

	FOR i IN array_lower(tpoint_arr, 1)..array_upper(tpoint_arr, 1) LOOP
		temp := temp || cast(ST_X(TT_val(tpoint_arr[i])) as Text) || ' ' || cast(ST_Y(TT_val(tpoint_arr[i])) as Text);
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

-- END TT_length:
------------------------------------------------------------------------------------------


-- FUNCTION DEFINITION
-- DESCRIPTION : Mpoint 를 입력받고, Mpoint의 PERIOD를 반환. 
-- NAME : TT_deftime(tpoint[])
-- RETURNS : tpoint[] -> timestamp[]
-- CREATED BY YOO KI HYUN

-- START TT_deftime:

-- DROP FUNCTION TT_deftime(tpoint[]);

CREATE OR REPLACE FUNCTION TT_deftime(tpoint[]) RETURNS timestamp[] AS
$$
DECLARE
	tpoint_arr	alias for $1;
	
	time_arr	Timestamp[];

BEGIN
	time_arr[1] := TT_inst(tpoint_arr[array_lower(tpoint_arr, 1)]);
	time_arr[2] := TT_inst(tpoint_arr[array_upper(tpoint_arr, 1)]);

	RETURN time_arr;
END
$$
LANGUAGE 'plpgsql';

-- END TT_deftime:
------------------------------------------------------------------------------------------




















-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : TT_atinstant(tpoint[], TIMESTAMP)
-- RETURNS : tpoint[], TIMESTAMP -> tpoint
-- CREATED BY YOO KI HYUN

-- START TT_atinstant:

-- DROP FUNCTION TT_atinstant(tpoint[], TIMESTAMP);

CREATE OR REPLACE FUNCTION TT_atinstant(tpoint[], TIMESTAMP) RETURNS tpoint AS
$$
DECLARE
	tpoint_arr		alias for $1;
	instant			alias for $2;

	result_tpoint		tpoint;
BEGIN

	FOR i IN array_lower(tpoint_arr, 1)..array_upper(tpoint_arr, 1) LOOP
		IF (TT_inst(tpoint_arr[i]) = instant) THEN
			result_tpoint = tpoint_arr[i];		
		END IF;	
	END LOOP;

	RETURN result_tpoint;
END
$$
LANGUAGE 'plpgsql';

-- END TT_atinstant:
------------------------------------------------------------------------------------------



-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : TT_distance(geometry, geometry)
-- RETURNS : geometry, geometry -> real
-- CREATED BY YOO KI HYUN

-- START TT_distance:

-- DROP FUNCTION TT_distance(geometry, geometry);

CREATE OR REPLACE FUNCTION TT_distance(geometry, geometry) RETURNS real AS
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

-- END TT_distance:
------------------------------------------------------------------------------------------



-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : TT_initial(tpoint[])
-- RETURNS : tpoint[] -> tpoint
-- CREATED BY YOO KI HYUN

-- START TT_initial:

-- DROP FUNCTION TT_initial(tpoint[]);

CREATE OR REPLACE FUNCTION TT_initial(tpoint[]) RETURNS tpoint AS
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

-- END TT_initial:
------------------------------------------------------------------------------------------



-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : TT_inside(geometry, geometry)
-- RETURNS : geometry, geometry -> boolean
-- CREATED BY YOO KI HYUN

-- START TT_inside:

-- DROP FUNCTION TT_inside(geometry, geometry);

CREATE OR REPLACE FUNCTION TT_inside(geometry, geometry) RETURNS boolean AS
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

-- END TT_inside:
------------------------------------------------------------------------------------------



-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : TT_atperiods(tpoint[], periods)
-- RETURNS : tpoint[], periods -> tpoint[]
-- CREATED BY YOO KI HYUN

-- START TT_atperiods:

-- DROP FUNCTION TT_atperiods(tpoint[], periods);

CREATE OR REPLACE FUNCTION TT_atperiods(tpoint[], periods) RETURNS tpoint[] AS
$$
DECLARE
	tpoint_arr		alias for $1;
	input_periods		alias for $2;

	first_idx		int;
	last_idx		int;
	
	result_tpoint_arr	tpoint[];
BEGIN

	FOR i IN array_lower(tpoint_arr, 1)..array_upper(tpoint_arr, 1) LOOP
		IF (TT_inst(tpoint_arr[i]) = input_periods.startTime) THEN
			first_idx = i;		
		ELSIF (TT_inst(tpoint_arr[i]) = input_periods.endTime) THEN
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

-- END TT_atperiods:
------------------------------------------------------------------------------------------














