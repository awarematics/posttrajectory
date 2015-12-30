
delete from wtraj;

select * from wtraj;

CREATE or replace FUNCTION insert_wtraj() RETURNS integer AS $$
DECLARE

wk varchar;
j integer;

BEGIN


FOR i IN 1..600 LOOP

j = i;

if (j>10)
then
	j = 1;
end if;

wk = j;

EXECUTE 'INSERT INTO wtraj values(' || i || ', wkeyIn(' || quote_literal(wk) || '))';

END LOOP;

RETURN 1;
END;
$$ LANGUAGE plpgsql;

select insert_wtraj();



drop function insert_wtraj();


INSERT INTO wtraj values(2, wkeyIn('54'));


select * from wtraj where wk = wkeyIn('12') and id = 1;