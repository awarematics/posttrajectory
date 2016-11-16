select tpseg[1].ts, todouble(tpseg[1].ts), tpseg[150].ts, todouble(tpseg[150].ts), start_time, end_time
from mpseq_1844528_traj where mpid=1 and segid=1;
"2008-02-02 13:32:03",    1201959123   1201959122
"2008-02-02 16:51:09",    1201971069

select todouble(timestamp without time zone '2008-02-01 13:32:02');
select todouble(timestamp without time zone '2008-02-02 13:28:32');
select to_timestamp(1201958912);

select make_3dpolygon(tpseg) 
 &&& ST_MakePolygon(ST_GeomFromText(
'LINESTRINGM(116.38908 39.78912 0, 116.44457 39.92335 0, 116.44457 39.92335 0, 116.38908 39.78912 0)'
)) from mpseq_1844528_traj where mpid=1 and segid=1;


select make_3dpolygon(tpseg) 
 &&& make_3dpolygon(ST_MakeBox2D(ST_makePoint(116.38908, 39.78912), ST_makePoint(116.44457, 39.92335)), timestamp without time zone '2008-02-02 10:00:00', timestamp without time zone '2008-02-02 13:28:33')
  from mpseq_1844528_traj where mpid=1 and segid=1;

select make_3dpolygon(tpseg) 
 &&& ptraj_index_to3dgeom(ST_MakeBox2D(ST_makePoint(116.38908, 39.78912), ST_makePoint(116.44457, 39.92335)), timestamp without time zone '2008-02-02 10:00:00', timestamp without time zone '2008-02-02 10:28:32')
  from mpseq_1844528_traj where mpid=1 and segid=1;

select st_astext(make_3dpolygon(ST_MakeBox2D(ST_makePoint(116.38908, 39.78912), ST_makePoint(116.44457, 39.92335)), timestamp without time zone '2008-02-02 10:00:00', timestamp without time zone '2008-02-02 13:28:32'));
select st_astext(ptraj_index_to3dgeom(ST_MakeBox2D(ST_makePoint(116.38908, 39.78912), ST_makePoint(116.44457, 39.92335)), timestamp without time zone '2008-02-02 10:00:00', timestamp without time zone '2008-02-02 10:28:32'));

select make_3dpolygon(tpseg) 
 &&& geometry(ST_3DMakeBox(ST_makePoint(116.38908, 39.78912 ,0),
  ST_makePoint(116.44457, 39.92335, 0)))
from mpseq_1844528_traj where mpid=1 and segid=1;

select ST_MakeBox2D(ST_makePoint(116.38908, 39.78912), ST_makePoint(116.44457, 39.92335));
select st_astext(make_3dpolygon(ST_MakeBox2D(ST_makePoint(116.38908, 39.78912), ST_makePoint(116.44457, 39.92335)), timestamp without time zone '2010-01-02 10:00:00', timestamp without time zone '2010-01-02 10:00:00')); 

select st_astext(geometry(ST_3DMakeBox(ST_makePoint(116.38908, 39.78912 ,todouble(timestamp without time zone '2010-01-02 10:00:00')),
  ST_makePoint(116.44457, 39.92335, todouble(timestamp without time zone '2010-01-02 11:00:00')))));
  
select box2d(make_3dpolygon(tpseg)) from mpseq_1844528_traj where mpid=1 and segid=1;
"BOX(116.38908 39.78912,116.44457 39.92335)"

select box3d(ST_MakePolygon(ST_GeomFromText(
'LINESTRINGM(116.38908 39.78912 1201872722, 116.44457 39.92335 1201959122, 116.44457 39.92335 1201959122, 116.38908 39.78912 1201872722)'
)));
"BOX3D(116.43523 40.92157 0,117.44457 40.92287 0)"

select st_astext(ST_MakePolygon(ST_GeomFromText(
'LINESTRINGM(116.38908 39.78912 1201872722, 116.44457 39.92335 1201959122, 116.44457 39.92335 1201959122, 116.38908 39.78912 1201872722)'
)));

select make_3dpolygon(tpseg)
 &&& ST_MakePolygon(ST_GeomFromText(
'LINESTRINGM(116.44457 39.92157 1, 117.44043 39.9219 1, 116.4404 39.92192 1, 116.43528 39.9228 1, 116.43523 39.92287 1, 116.44457 39.92157 1)'
)) from mpseq_1844528_traj where mpid=1 and segid=1;


select count(*) from mpseq_1844374_traj where ptraj_index_to3dgeom(geometry(rect)::box2d, start_time, end_time)
 &&& ST_3DMakeBox(ST_makePoint(108.45223, 22.91412 ,todouble(timestamp without time zone '2010-01-02 10:00:00')),
  ST_makePoint(117.589875, 34.351745, todouble(timestamp without time zone '2010-01-02 11:00:00')))
and TJ_Passes(tpseg, geometry(ST_MakeBox2D(ST_Point(108.45223, 22.91412), ST_Point(117.589875, 34.351745)))); 


select ST_3DMakeBox(ST_makePoint(108.45223, 22.91412 ,1),
  ST_makePoint(117.589875, 34.351745, 2))
   &&& ST_3DMakeBox(ST_makePoint(119.45223, 35.91412 ,1),
  ST_makePoint(119.589875, 36.351745, 2));



SELECT tbl1.column1, tbl2.column1, tbl1.column2 &&& tbl2.column2 AS overlaps_3d,
tbl1.column2 && tbl2.column2 AS overlaps_2d
FROM ( VALUES
(1, 'LINESTRING Z(0 0 1, 3 3 2)'::geometry),
(2, 'LINESTRING Z(1 2 0, 0 5 -1)'::geometry)) AS tbl1,
( VALUES
(3, 'LINESTRING Z(1 2 3, 4 6 5)'::geometry)) AS tbl2;

SELECT box3d(ST_MakePolygon(ST_GeomFromText('LINESTRINGM(75 29 1,77 29 1,77 29 2, 75 29 2)')));

SELECT st_astext(ST_MakePolygon(ST_GeomFromText('LINESTRINGM(75 29 1,77 29 1,77 29 2, 75 29 2)')));

SELECT st_astext(ST_MakePolygon(ST_GeomFromText('LINESTRINGM(75.15 29.53 1,77 29 1,77 29 1, 75.15 29.53 2)')));


SELECT ST_AsEWKT(ST_Force3DM('POLYGON((0 0 1,0 5 1,5 0 1,0 0 1),(1 1 1,3 1 1,1 3 1,1 1 1))'));
SELECT ST_AsEWKT(ST_Force3DM('POLYGON((0 0 1,0 5 1,5 0 1,0 0 1),(1 1 1,3 1 1,1 3 1,1 1 1))'));
