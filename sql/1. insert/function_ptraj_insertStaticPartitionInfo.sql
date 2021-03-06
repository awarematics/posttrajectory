﻿

/*
*
* select ptraj_insertStaticPartitionInfo(10, 10);
*
*/


CREATE OR REPLACE FUNCTION ptraj_insertStaticPartitionInfo(INTEGER, INTEGER) RETURNS BOOLEAN AS
$$
DECLARE
	x_split		alias for $1;
	y_split		alias for $2;
	
	schemeName	varchar;
	tableName	varchar;
	
	minX		float;
	minY		float;
	maxX		float;
	maxY		float;

	x_unit		float;
	y_unit		float;

	split_minX	float;
	split_minY	float;
	split_maxX	float;
	split_maxY	float;

	tmp_box		box2d;

	isTable		integer;
	idx		integer;
	
	sql		varchar;

	result		boolean;
BEGIN
	
	schemeName := 'public';
	tableName := 'static_partition';

	minX := 0.0;
	minY := 0.0;
	maxX := 0.0;
	maxY := 0.0;

	sql := 'SELECT box2d(rect) FROM mpseq_traj_data ORDER BY id';
	FOR tmp_box IN EXECUTE sql LOOP
		-- raise notice '%', tmp_box;
		IF (ST_XMin(tmp_box) <= minX OR minX = 0.0) THEN
			minX := ST_XMin(tmp_box);
		END IF;
		IF (ST_YMin(tmp_box) <= minY OR minY = 0.0) THEN
			minY := ST_YMin(tmp_box);
		END IF;
		IF (ST_XMax(tmp_box) >= maxX OR maxX = 0.0) THEN
			maxX := ST_XMax(tmp_box);
		END IF;
		IF (ST_YMax(tmp_box) >= maxY OR maxY = 0.0) THEN
			maxY := ST_YMax(tmp_box);
		END IF;
	END LOOP;
	
	/*
	raise notice '%, %, %, %', minX, minY, maxX, maxY;
	*/

	x_unit := (maxX-minX) / x_split;
	y_unit := (maxY-minY) / y_split;

	idx := 0;

	EXECUTE 'SELECT COUNT(*) FROM pg_tables WHERE schemaname = $1 AND tablename = $2' USING schemeName, tableName
	 INTO isTable;
	
	-- raise notice '%', isTable;

	IF (isTable = 0) THEN
		EXECUTE 'CREATE TABLE ' || schemeName || '.' || tableName || '(
				id		integer,
				partition	box2d	
			)';
	ELSE
		EXECUTE 'DELETE FROM ' || tableName;
	END IF;

	FOR i IN 1..x_split LOOP
		FOR j IN 1..y_split LOOP
			-- raise notice '%, %', i, j;
			-- raise notice '%, %, %, %', minX+(x_unit*i)-x_unit, minY+(y_unit*j)-y_unit, minX+(x_unit*i), minY+(y_unit*j);
			split_minX := minX+(x_unit*i)-x_unit;
			split_minY := minY+(y_unit*j)-y_unit;
			split_maxX := minX+(x_unit*i);
			split_maxY := minY+(y_unit*j);
			
			tmp_box := ST_MakeBox2D(ST_Point(split_minX, split_minY), ST_Point(split_maxX, split_maxY));
			
			EXECUTE 'INSERT INTO ' || tableName || ' VALUES($1, $2)' USING (idx+j), tmp_box;
		END LOOP;
		idx := i * y_split;
	END LOOP;

	IF (idx = (x_split * y_split)) THEN
		result := true;
	ELSE
		result := false;
	END IF;
	
	RETURN result;
END
$$
LANGUAGE 'plpgsql';
