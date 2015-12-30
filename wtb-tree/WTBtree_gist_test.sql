
DROP FUNCTION wkeyIn(char);

DROP TYPE wkey;

CREATE TYPE wkey as (
	wkey char(2)
);



CREATE TABLE wtraj (
	id int,
	wk wkey
);

create or replace function wkeyIn(char) returns wkey as
$$
declare 
	wk alias for $1;
	result wkey;
begin 
	result.wkey = wk;
	return result;
end
$$
language 'plpgsql';

delete from wtraj;

select * from wtraj;

explain
select * from wtraj where wk = wkeyIn('2');

select wkeyIn('2');

CREATE INDEX wtraj_gist ON wtraj USING gist(wk); 

DROP INDEX public.wtraj_gist;
