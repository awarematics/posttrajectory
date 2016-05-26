CREATE or replace FUNCTION insert_wtraj() RETURNS integer AS $$
DECLARE

wk char(12);

BEGIN


FOR i IN 100..400 LOOP

wk = 'kunsan00';
wk = wk || i;

EXECUTE 'INSERT INTO wtraj values(' || i || ', ' || quote_literal(wk) || ')';

END LOOP;

RETURN 1;
END;
$$ LANGUAGE plpgsql;

delete from wtraj;

select count(*) from wtraj;

explain
select * from wtraj where wk>='kunsan001000' and wk<='kunsan001501';

insert into wtraj values (1, 'kunsan001000');


select insert_wtraj();

CREATE INDEX wtraj_gist ON wtraj USING gist(wk); 




select insert_wtraj4();

select insert_wtraj3();

select insert_wtraj1();

select insert_wtraj6();

select insert_wtraj5();

select insert_wtraj2();

CREATE INDEX wtraj_gist ON wtraj USING gist(wk); 




DROP INDEX public.wtraj_gist;

drop function insert_wtraj();
 


INSERT INTO wtraj values(2, 'kunsan');

update wtraj set wk = 'test' where id = 1;

delete from wtraj where id = 3;

DROP OPERATOR CLASS WTBtree_gist_ops using gist;

drop table wtraj;


select * from wtraj where wk = wkeyIn('12') and id = 1;
