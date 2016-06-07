
select * from traj_geom order by id;

select id, st_astext(traj) from traj_geom;

delete from traj_geom;

drop table traj_geom;


CREATE TABLE public.traj_geom
(
  id serial,
  traj geometry
);



drop table traj_text;

delete from traj_text;

select * from traj_text order by id;

CREATE TABLE public.traj_text
(
  id serial,
  traj char(34)
);



CREATE INDEX wtraj_gist ON wtraj USING gist(wk); 


DROP INDEX wtraj_gist;

insert into traj_text(traj) values(ST_GeoHash(st_point(116.319876,40.008304), 12));