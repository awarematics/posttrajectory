create table wtraj_text
(
	id int,
	wk text
);


CREATE or replace FUNCTION insert_wtraj_text() RETURNS integer AS $$
DECLARE

wk text;

BEGIN


FOR i IN 101..300 LOOP

wk = 'kunsan000';
wk = wk || i;

EXECUTE 'INSERT INTO wtraj_text values(' || i || ', ' || quote_literal(wk) || ')';

END LOOP;

RETURN 1;
END;
$$ LANGUAGE plpgsql;

delete from wtraj_text;

select * from wtraj_text;

explain
select * from wtraj_text where id >= 100 and id <150;




select insert_wtraj_text();

CREATE INDEX wtraj_text_gist ON wtraj_text USING gist(wk); 

