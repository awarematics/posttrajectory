
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
-- TJ_Passes(tpoint[], geometry)
-- TJ_begin(periods)
-- TJ_end(periods)
-- TJ_period(timestamp, timestamp)
-- TJ_equals(periods, peridos)
-- TJ_before(periods, periods)
-- TJ_meets(periods, periods)
-- TJ_overlaps(periods, periods)
-- TJ_overlaps(tpoint[], periods)
-- TJ_During(periods, periods)
-- TJ_starts(periods, periods)
-- TJ_finishes(periods, periods)
-- TJ_intersects(periods, periods)
-- TJ_isnull(periods)
-- TJ_periods(tpoint[])
-- TJ_enter(trajectory, box2d)
-- TJ_enter(trajectory, geometry)
-- TJ_enter(trajectory, geometry, periods)
-- TJ_leave(trajectory, geometry, peirods)




-- FUNCTION DEFINITION
-- DESCRIPTION : 
-- NAME : TJ_val(tpoint)
-- RETURNS : tpoint -> geometry
-- CREATED BY YOO KI HYUN

-- START TJ_val:

CREATE OR REPLACE FUNCTION TJ_val(tpoint) RETURNS geometry AS 
$$
DECLARE
	input_tpoint 	alias for $1;
BEGIN
	RETURN input_tpoint.pnt;
END
$$
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION TJ_inst(tpoint) RETURNS TIMESTAMP AS 
$$
DECLARE
	input_tpoint 	alias for $1;
BEGIN
	RETURN input_tpoint.ts;
END
$$

LANGUAGE 'plpgsql';


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
		
		distance = ST_Distance( tp1.pnt, tp2.pnt );
		aMreal[i] := distance;
	END LOOP;

	RETURN aMreal;
END
$$
LANGUAGE 'plpgsql';



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


CREATE OR REPLACE FUNCTION _TJ_Passes(geom1 geometry, geom2 geometry, tpoint_arr tpoint[])
  RETURNS boolean AS
'SELECT $1 && $2 AND TJ_passes($3,$2)'
  LANGUAGE sql IMMUTABLE
  COST 100;
  
  
CREATE OR REPLACE FUNCTION TP_BEGIN(periods) RETURNS TIMESTAMP AS 
$$
DECLARE
	input_period	alias for $1;
BEGIN
	RETURN input_period.startTime;
END
$$
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION TJ_END(periods) RETURNS TIMESTAMP AS 
$$
DECLARE
	input_period 	alias for $1;
BEGIN
	RETURN input_period.endTime;
END
$$
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION TJ_PERIOD(TIMESTAMP, TIMESTAMP) RETURNS periods AS 
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


CREATE OR REPLACE FUNCTION TJ_PERIOD(TIMESTAMP with timezone, TIMESTAMP with timezone) RETURNS periods AS 
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



CREATE OR REPLACE FUNCTION TJ_Equals(periods, periods) RETURNS boolean AS
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


CREATE OR REPLACE FUNCTION TJ_Before(periods, periods) RETURNS boolean AS
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


CREATE OR REPLACE FUNCTION TJ_Meets(periods, periods) RETURNS boolean AS
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


CREATE OR REPLACE FUNCTION TJ_Overlaps(periods, periods) RETURNS boolean AS
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


CREATE OR REPLACE FUNCTION TJ_During(periods, periods) RETURNS boolean AS
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


CREATE OR REPLACE FUNCTION TJ_Starts(periods, periods) RETURNS boolean AS
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


CREATE OR REPLACE FUNCTION TJ_Finishes(periods, periods) RETURNS boolean AS
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


CREATE OR REPLACE FUNCTION TJ_Intersects(periods, periods) RETURNS boolean AS
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


CREATE OR REPLACE FUNCTION TJ_Isnull(periods) RETURNS boolean AS
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


CREATE OR REPLACE FUNCTION TJ_PERIODS(tpoint[]) RETURNS periods AS
$$
DECLARE
	tpoints			alias for $1;
	start_time			timestamp;
	end_time			timestamp;
	sql					text;
    array_size			integer;
    result_periods		periods;

BEGIN
		
	
	sql := 'select array_upper($1, 1)';
	execute sql into array_size using tpoints;
	if(tpoints IS NOT NULL) then
		start_time := tpoints[1].ts;
		end_time := tpoints[array_size].ts;
	
		result_periods.startTime := start_time;
		result_periods.endTime := end_time;
        return result_periods;
    else
    	return NULL;
	end if;
END
$$
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION TJ_PERIODS(tpoint[]) RETURNS periods AS
$$
DECLARE
	tpoints			alias for $1;
	start_time			timestamp;
	end_time			timestamp;
	sql					text;
    array_size			integer;
    result_periods		periods;

BEGIN
	if(tpoints IS NOT NULL) then
		start_time := tpoints[1].ts;
		end_time := tpoints[array_size].ts;
	
		result_periods.startTime := start_time;
		result_periods.endTime := end_time;
        return result_periods;
    else
    	return NULL;
	end if;
END
$$
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION TJ_OVERLAP(tpoint[], periods) RETURNS boolean AS
$BODY$
DECLARE
	input_tpoints		alias for $1;
	input_periods		alias for $2;
	tpoints_periods		periods;

    tpoints_starttime	timestamp;
    tpoints_endtime		timestamp;
    sql					text;
	    
	return_value		boolean;
    
BEGIN
	if(input_tpoints is not null) then
		sql := 'select tp_begin(TP_PERIODS($1))';
		execute sql into tpoints_starttime using input_tpoints;
        
        sql := 'select tp_end(TP_PERIODS($1))';
		execute sql into tpoints_endtime using input_tpoints;
		
        tpoints_periods.startTime := tpoints_starttime;
        tpoints_periods.endTime := tpoints_endtime;
        
		sql := 'select TP_OVERLAPS($1, $2)';
		execute sql into return_value using tpoints_periods, input_periods;
		return return_value;
	else 
    	return false;
	end if;	
END
$BODY$
LANGUAGE 'plpgsql' VOLATILE
COST 100;


CREATE OR REPLACE FUNCTION TJ_ENTER(trajectory, box2d) RETURNS BOOLEAN AS
$$
DECLARE
	f_trajectory			alias for $1;
	input_box2d				alias for $2;
    result_value			boolean;
    input_geometry			geometry;
    sql						text;

BEGIN
    sql := 'select geometry($1)';
    execute sql into input_geometry using input_box2d;
    
    sql := 'select TT_ENTER($1, $2)';
    execute sql into result_value using f_trajectory, input_geometry;
    
    return result_value;
END
$$
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION TJ_ENTER(trajectory, geometry) RETURNS BOOLEAN AS
$$
DECLARE
	f_trajectory			alias for $1;
	input_geometry				alias for $2;
	f_trajectory_segtable_name	char(200);
	min_segid			integer;
	max_segid			integer;
	maxseg_size			integer;
	tpseg_arr				tpoint[];
	first_tpoint			tpoint;
	last_tpoint			tpoint;
	data				record;
	sql					text;
	intersects_start	boolean;
	intersects_end	boolean;
	traj_prefix			char(50);
	
BEGIN
	traj_prefix := 'mpseq_' ;
		
	f_trajectory_segtable_name := traj_prefix || f_trajectory.segtableoid;
	
	sql := 'select min(segid) from ' || quote_ident(f_trajectory_segtable_name) || ' where mpid = ' || f_trajectory.moid;
	execute sql into min_segid;

	sql := 'select max(segid) from ' || quote_ident(f_trajectory_segtable_name) || ' where mpid = ' || f_trajectory.moid;
	execute sql into max_segid;

	execute format('select mpcount from ' || quote_ident(f_trajectory_segtable_name) || ' where mpid = $1 and segid = $2')
	into maxseg_size using f_trajectory.moid, max_segid;

	execute format('select tpseg from ' || quote_ident(f_trajectory_segtable_name) || ' where mpid = $1 and segid = $2')
	into tpseg_arr using f_trajectory.moid, min_segid;
    first_tpoint.pnt := tpseg_arr[1].pnt;
    first_tpoint.ts := tpseg_arr[1].ts;
	
	execute format('select tpseg from ' || quote_ident(f_trajectory_segtable_name) || ' where mpid = $1 and segid = $2')
	into tpseg_arr using f_trajectory.moid, max_segid;
	last_tpoint.pnt := tpseg_arr[maxseg_size].pnt;
    last_tpoint.ts := tpseg_arr[maxseg_size].ts;

	sql := 'select st_intersects($1, $2)';
	execute sql into intersects_start using first_tpoint.pnt, input_geometry;
	
	sql := 'select st_intersects($1, $2 )';
	execute sql into intersects_end using last_tpoint.pnt, input_geometry;

	if intersects_start then
    	if intersects_end then 
			return false;
        else 
        	return true;
		end if;
	else
    	if intersects_start then
        	return true;
		else 
        	return false;
		end if;
	end if;
END
$$
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION TJ_ENTER(trajectory, geometry, periods) RETURNS BOOLEAN AS
$$
DECLARE
	f_trajectory			alias for $1;
	input_geometry				alias for $2;
    input_periods			alias for $3;
	f_trajectory_segtable_name	char(200);
	sliced_tpseg			tpoint[];
	sliced_linestring		geometry;
	trajectory_size		integer;
	first_tpoint			tpoint;
	last_tpoint			tpoint;
	data				record;
	sql					text;
	intersects_start	boolean;
	intersects_end	boolean;
	traj_prefix			char(50);
	
BEGIN
	traj_prefix := 'mpseq_' ;
		
	f_trajectory_segtable_name := traj_prefix || f_trajectory.segtableoid;
	
	sql := 'select slice($1, $2, $3)';
	execute sql into sliced_tpseg using f_trajectory, input_periods.startTime, input_periods.endTime;
	
	if sliced_tpseg is not null then
		sql := 'select array_upper($1, 1)';
		execute sql into trajectory_size using sliced_tpseg;

		first_tpoint.pnt := sliced_tpseg[1].pnt;
		first_tpoint.ts := sliced_tpseg[1].ts;
		
		last_tpoint.pnt := sliced_tpseg[trajectory_size].pnt;
		last_tpoint.ts := sliced_tpseg[trajectory_size].ts;
		
		sql := 'select st_intersects($1, $2)';
		execute sql into intersects_start using first_tpoint.pnt, input_geometry;
		
		sql := 'select st_intersects($1, $2 )';
		execute sql into intersects_end using last_tpoint.pnt, input_geometry;

		if intersects_start then
			return false;
		else 
			if intersects_end then
				return true;
			else
				return false;
			end if;
		end if;
		
	else
		return false;
	end if;
END
$$
LANGUAGE 'plpgsql';
	
	
CREATE OR REPLACE FUNCTION TJ_LEAVE(trajectory, geometry, periods) RETURNS BOOLEAN AS
$$
DECLARE
	f_trajectory			alias for $1;
	input_geometry				alias for $2;
    input_periods			alias for $3;
	f_trajectory_segtable_name	char(200);
	sliced_tpseg			tpoint[];
	sliced_linestring		geometry;
	trajectory_size		integer;
	first_tpoint			tpoint;
	last_tpoint			tpoint;
	data				record;
	sql					text;
	intersects_start	boolean;
	intersects_end	boolean;
	traj_prefix			char(50);
BEGIN
	traj_prefix := 'mpseq_' ;
		
	f_trajectory_segtable_name := traj_prefix || f_trajectory.segtableoid;
	
	sql := 'select slice($1, $2, $3)';
	execute sql into sliced_tpseg using f_trajectory, input_periods.startTime, input_periods.endTime;
	if sliced_tpseg is not null then
		sql := 'select array_upper($1, 1)';
		execute sql into trajectory_size using sliced_tpseg;

		first_tpoint.pnt := sliced_tpseg[1].pnt;
		first_tpoint.ts := sliced_tpseg[1].ts;
		
		last_tpoint.pnt := sliced_tpseg[trajectory_size].pnt;
		last_tpoint.ts := sliced_tpseg[trajectory_size].ts;
		
		sql := 'select st_intersects($1, $2)';
		execute sql into intersects_start using first_tpoint.pnt, input_geometry;
		
		sql := 'select st_intersects($1, $2 )';
		execute sql into intersects_end using last_tpoint.pnt, input_geometry;

		if intersects_start then
			if intersects_end then
            	return false;
			else
            	return true;
			end if;
		else
        	return false;
		end if;
	else
    	return false;
	end if;
	
END
$$
LANGUAGE 'plpgsql';
