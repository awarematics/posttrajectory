

/*
*
* select ptraj_insertTraj_v2('1131');
*
*/


CREATE OR REPLACE FUNCTION ptraj_insertTraj_v2(varchar) RETURNS boolean AS
$BODY$
DECLARE
	carNum		alias for $1;
	
	taxi_rcd	record;
	data_rcd	record;
	
	sql		varchar;
	taxi_id		integer;

BEGIN
	sql := 'SELECT MAX(taxi_id) FROM taxi';
	EXECUTE sql INTO taxi_id;

	IF (taxi_id IS NULL) THEN
		-- raise notice 'taxi id is null!';
		taxi_id := 1;
	END IF;
	
	EXECUTE 'INSERT INTO taxi VALUES ($1, $2, $2, $2)'
	USING taxi_id, carNum;
	
	sql := 'SELECT taxi_id, taxi_number, traj FROM taxi where taxi_id = $1';
	EXECUTE sql INTO taxi_rcd USING taxi_id;
	
	sql := 'SELECT mpcount, tpseg FROM mpseq_traj_data WHERE carnumber = $1 ORDER BY id';

	FOR data_rcd IN EXECUTE sql USING taxi_rcd.taxi_number LOOP
		-- raise notice '%, %', data_rcd.mpcount, data_rcd.tpseg;
		FOR i IN 1..data_rcd.mpcount LOOP
			-- raise notice '%', st_astext(tmp.tpseg[i].pnt);
			EXECUTE 'update taxi set traj = append($1, $2) where taxi_id = $3'
			USING taxi_rcd.traj, data_rcd.tpseg[i], taxi_rcd.taxi_id;
		END LOOP;
	END LOOP;

	return true;
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE STRICT
COST 100;


