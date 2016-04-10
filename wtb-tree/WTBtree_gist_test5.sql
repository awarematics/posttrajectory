create table wtraj_varchar
(
	id int,
	wk varchar
);


CREATE or replace FUNCTION insert_wtraj_varchar() RETURNS integer AS $$
DECLARE

wk varchar;

BEGIN


FOR i IN 101..300 LOOP

wk = 'kunsan000';
wk = wk || i;

EXECUTE 'INSERT INTO wtraj_varchar values(' || i || ', ' || quote_literal(wk) || ')';

END LOOP;

RETURN 1;
END;
$$ LANGUAGE plpgsql;

delete from wtraj_varchar;

select * from wtraj_varchar;

explain
select * from wtraj_varchar where id >= 100 and id <150;




select insert_wtraj_varchar();

CREATE INDEX wtraj_varchar_gist ON wtraj_varchar USING gist(wk); 

