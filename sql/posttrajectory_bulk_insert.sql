

CREATE OR REPLACE FUNCTION read(file text, mpcnt integer)  
  RETURNS text AS $$
    DECLARE
      delim		text;
      tmp_table 	text;

      taxi_cnt		integer;
      taxi_number	text;
    BEGIN
      file := quote_literal(file);
      tmp_table := 'tmp_table';
      delim := quote_literal(',');
      
      -- tmp_table := 'COPY test FROM ' || file || ' delimiter ' || content;
      -- raise notice '%', tmp_table;

      EXECUTE 'CREATE TEMP TABLE ' || tmp_table || ' (taxiId integer, ts timestamp with time zone, lati float, long float)';
      EXECUTE 'COPY ' || tmp_table || ' FROM ' || file || ' delimiter ' || delim;
      
      EXECUTE 'SELECT count(*) FROM taxi_02' INTO taxi_cnt;
      taxi_cnt = taxi_cnt + 1;

      raise notice '%', taxi_cnt;

      EXECUTE 'SELECT taxiid FROM tmp_table' INTO taxi_number;
            
      EXECUTE 'INSERT INTO taxi_02(taxi_id, taxi_number, taxi_model, taxi_driver) VALUES($1, $2, $2, $2)' USING taxi_cnt, taxi_number;

      EXECUTE 'DROP TABLE ' || tmp_table;
      
      RETURN tmp_table;
    END;
  $$ LANGUAGE plpgsql VOLATILE;

drop table tmp_table;
  
select read('/home/postgres/1131.txt', 150);

select count(*) from tmp_table;

select * from tmp_table;

delete from taxi_02;

select * from taxi_02;

