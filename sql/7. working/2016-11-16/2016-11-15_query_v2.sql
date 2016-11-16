
/*
 Query Window Size : 2%
 
 100k : mpseq_1844374_traj

 300k : mpseq_1844528_traj

 500k : mpseq_1844545_traj

 700k : mpseq_1844562_traj

 900k : mpseq_1844579_traj

*/
-- No Index

-- 100k
explain analyze
select * from mpseq_1844374_traj where rect
 && ST_MakeBox2D(ST_makePoint(116.0, 39.9), ST_makePoint(116.2, 40.14))
  and tp_overlaps(tp_period(start_time, end_time), tp_period(timestamp without time zone '2008-02-02 13:30:00', timestamp without time zone '2008-02-02 15:54:46'));

-- 300k
explain analyze
select * from mpseq_1844528_traj where rect
 && ST_MakeBox2D(ST_makePoint(116.0, 39.9), ST_makePoint(116.2, 40.14))
  and tp_overlaps(tp_period(start_time, end_time), tp_period(timestamp without time zone '2008-02-02 13:30:00', timestamp without time zone '2008-02-02 15:54:46'));
  
-- 500k
explain analyze
select * from mpseq_1844545_traj where rect
 && ST_MakeBox2D(ST_makePoint(116.0, 39.9), ST_makePoint(116.2, 40.14))
  and tp_overlaps(tp_period(start_time, end_time), tp_period(timestamp without time zone '2008-02-02 13:30:00', timestamp without time zone '2008-02-02 15:54:46'));

-- 700k
explain analyze
select * from mpseq_1844562_traj where rect
 && ST_MakeBox2D(ST_makePoint(116.0, 39.9), ST_makePoint(116.2, 40.14))
  and tp_overlaps(tp_period(start_time, end_time), tp_period(timestamp without time zone '2008-02-02 13:30:00', timestamp without time zone '2008-02-02 15:54:46'));

-- 900k
explain analyze
select * from mpseq_1844579_traj where rect
 && ST_MakeBox2D(ST_makePoint(116.0, 39.9), ST_makePoint(116.2, 40.14))
  and tp_overlaps(tp_period(start_time, end_time), tp_period(timestamp without time zone '2008-02-02 13:30:00', timestamp without time zone '2008-02-02 15:54:46'));

----------------------------------------------------------------------------------------------------------------------------


-- 3DR-tree-NTT

-- 100k
explain analyze
select * from mpseq_1844374_traj where make_3dpolygon(rect, start_time, end_time)
 &&& make_3dpolygon(ST_MakeBox2D(ST_makePoint(116.00000, 39.90000), ST_makePoint(116.20000, 40.14000)),
  timestamp without time zone '2008-02-02 13:30:44', timestamp without time zone '2008-02-02 15:54:46');
  
-- 300k
explain analyze
select * from mpseq_1844528_traj where make_3dpolygon(rect, start_time, end_time)
 &&& make_3dpolygon(ST_MakeBox2D(ST_makePoint(116.00000, 39.90000), ST_makePoint(116.20000, 40.14000)),
  timestamp without time zone '2008-02-02 13:30:44', timestamp without time zone '2008-02-02 15:54:46');

-- 500k
explain analyze
select * from mpseq_1844545_traj where make_3dpolygon(rect, start_time, end_time)
 &&& make_3dpolygon(ST_MakeBox2D(ST_makePoint(116.00000, 39.90000), ST_makePoint(116.20000, 40.14000)),
  timestamp without time zone '2008-02-02 13:30:44', timestamp without time zone '2008-02-02 15:54:46');

-- 700k
explain analyze
select * from mpseq_1844562_traj where make_3dpolygon(rect, start_time, end_time)
 &&& make_3dpolygon(ST_MakeBox2D(ST_makePoint(116.00000, 39.90000), ST_makePoint(116.20000, 40.14000)),
  timestamp without time zone '2008-02-02 13:30:44', timestamp without time zone '2008-02-02 15:54:46');
  
-- 900k
explain analyze
select * from mpseq_1844579_traj where make_3dpolygon(rect, start_time, end_time)
 &&& make_3dpolygon(ST_MakeBox2D(ST_makePoint(116.00000, 39.90000), ST_makePoint(116.20000, 40.14000)),
  timestamp without time zone '2008-02-02 13:30:44', timestamp without time zone '2008-02-02 15:54:46');
  
----------------------------------------------------------------------------------------------------------------------------