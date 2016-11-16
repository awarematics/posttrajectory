-- 

/*
 Data Size : 500k
 
 2% : mpseq_1844374_traj

 4% : mpseq_1844528_traj

 6% : mpseq_1844545_traj

 8% : mpseq_1844562_traj

 10% : mpseq_1844579_traj

*/

-- No Index

-- 2%
explain analyze
select * from mpseq_1844545_traj where rect
 && ST_MakeBox2D(ST_makePoint(116.0, 39.9), ST_makePoint(116.2, 40.04))
  and tp_overlaps(tp_period(start_time, end_time), tp_period(timestamp without time zone '2008-02-02 13:30:00', timestamp without time zone '2008-02-02 15:54:46'));

-- 4%
explain analyze
select * from mpseq_1844545_traj where rect
 && ST_MakeBox2D(ST_makePoint(116.0, 39.9), ST_makePoint(116.4, 40.18))
  and tp_overlaps(tp_period(start_time, end_time), tp_period(timestamp without time zone '2008-02-02 13:30:00', timestamp without time zone '2008-02-02 18:18:48'));
  
-- 6%
explain analyze
select * from mpseq_1844545_traj where rect
 && ST_MakeBox2D(ST_makePoint(116.0, 39.9), ST_makePoint(116.6, 40.32))
  and tp_overlaps(tp_period(start_time, end_time), tp_period(timestamp without time zone '2008-02-02 13:30:00', timestamp without time zone '2008-02-02 20:42:50'));

-- 8%
explain analyze
select * from mpseq_1844545_traj where rect
 && ST_MakeBox2D(ST_makePoint(116.0, 39.9), ST_makePoint(116.8, 40.46))
  and tp_overlaps(tp_period(start_time, end_time), tp_period(timestamp without time zone '2008-02-02 13:30:00', timestamp without time zone '2008-02-02 23:06:52'));

-- 10%
explain analyze
select * from mpseq_1844545_traj where rect
 && ST_MakeBox2D(ST_makePoint(116.0, 39.9), ST_makePoint(117.0, 40.6))
  and tp_overlaps(tp_period(start_time, end_time), tp_period(timestamp without time zone '2008-02-02 13:30:00', timestamp without time zone '2008-02-03 01:30:54'));


----------------------------------------------------------------------------------------------------------------------------


-- 3DR-tree-NTT

-- 2%
explain analyze
select * from mpseq_1844545_traj where make_3dpolygon(rect, start_time, end_time)
 &&& make_3dpolygon(ST_MakeBox2D(ST_makePoint(116.00000, 39.90000), ST_makePoint(116.20000, 40.04000)),
  timestamp without time zone '2008-02-02 13:30:44', timestamp without time zone '2008-02-02 15:54:46');


-- 4%
explain analyze
select * from mpseq_1844545_traj where make_3dpolygon(rect, start_time, end_time)
 &&& make_3dpolygon(ST_MakeBox2D(ST_makePoint(116.00000, 39.90000), ST_makePoint(116.40000, 40.18000)),
  timestamp without time zone '2008-02-02 13:30:44', timestamp without time zone '2008-02-02 18:18:48');


-- 6%
explain analyze
select * from mpseq_1844545_traj where make_3dpolygon(rect, start_time, end_time)
 &&& make_3dpolygon(ST_MakeBox2D(ST_makePoint(116.00000, 39.90000), ST_makePoint(116.60000, 40.32000)),
  timestamp without time zone '2008-02-02 13:30:44', timestamp without time zone '2008-02-02 20:42:50');


-- 8%
explain analyze
select * from mpseq_1844545_traj where make_3dpolygon(rect, start_time, end_time)
 &&& make_3dpolygon(ST_MakeBox2D(ST_makePoint(116.00000, 39.90000), ST_makePoint(116.80000, 40.46000)),
  timestamp without time zone '2008-02-02 13:30:44', timestamp without time zone '2008-02-02 23:06:52');


-- 10%
explain analyze
select * from mpseq_1844545_traj where make_3dpolygon(rect, start_time, end_time)
 &&& make_3dpolygon(ST_MakeBox2D(ST_makePoint(116.00000, 39.90000), ST_makePoint(117.00000, 40.60000)),
  timestamp without time zone '2008-02-02 13:30:44', timestamp without time zone '2008-02-03 01:30:54');


