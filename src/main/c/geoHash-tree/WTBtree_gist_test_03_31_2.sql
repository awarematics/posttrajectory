create table test_01 (
id integer,
test khyoo)

delete from test_01;

select * from test_01;

insert into test_01 values(1, 'khyoh');

create type khyoo;

DROP FUNCTION khyoo_in(cstring);

DROP FUNCTION khyoo_out(khyoo);

drop type khyoo;

DROP TABLE test_01;

DROP TABLE wtraj;

drop type type_01;

create type type_01 as (
t text
)

drop table test_02;

create table test_02 (
id integer,
test type_01);	

delete from test_02;

select * from test_02

insert into test_02 values(1, insert_type('rqweerdh'));

drop function insert_type(text)

create or replace function insert_type(text) returns type_01 as
$$
declare
	src alias for $1;
	dest type_01;
begin
	dest.t = src;
	return dest;
end
$$
language 'plpgsql' volatile strict cost 100;
	

