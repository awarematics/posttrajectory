
/*
	Make partition from box2d value 
	(box2d, x-split size, y-split size)
*/

CREATE OR REPLACE FUNCTION post_makePartitionFromBox2d(box2d, integer, integer) RETURNS boolean AS
$$
DECLARE
	total_box	alias for $1;
	x_split		alias for $2;
	y_split 	alias for $3;
	
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

	partition	box2d;

	idx		integer;
	
	result		boolean;
BEGIN		
	minX := st_xmin(total_box);
	minY := st_ymin(total_box);
	maxX := st_xmax(total_box);
	maxY := st_ymax(total_box);

	x_unit := (maxX-minX) / x_split;
	y_unit := (maxY-minY) / y_split;

	idx := 0;
	
	FOR i IN 1..x_split LOOP
		FOR j IN 1..y_split LOOP
			-- raise notice '%, %', i, j;
			-- raise notice '%, %, %, %', minX+(x_unit*i)-x_unit, minY+(y_unit*j)-y_unit, minX+(x_unit*i), minY+(y_unit*j);
			split_minX := minX+(x_unit*i)-x_unit;
			split_minY := minY+(y_unit*j)-y_unit;
			split_maxX := minX+(x_unit*i);
			split_maxY := minY+(y_unit*j);
			
			partition := ST_MakeBox2D(ST_Point(split_minX, split_minY), ST_Point(split_maxX, split_maxY));
			
			EXECUTE 'INSERT INTO partition_info VALUES($1, $2)' USING (idx+j), partition;		
		END LOOP;
		idx := i * y_split;
	END LOOP;

	result := true;
	
	RETURN result;
END
$$
LANGUAGE 'plpgsql';