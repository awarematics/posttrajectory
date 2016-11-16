create function insert_dataset() returns integer as
$BODY$
DECLARE
	src_tb		varchar;
	taxi_tb		varchar;
	
	sql		varchar;
BEGIN

	src_tb := 't_drive_data';
	
	taxi_tb := 'taxi_1000k';	
	sql := 'select insert_base_data_count($1, $2, 150, 1000);';	
	execute sql using src_tb, taxi_tb;
	
	return 1000;
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE STRICT
COST 100;

select insert_dataset();