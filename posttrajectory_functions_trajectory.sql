
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

























