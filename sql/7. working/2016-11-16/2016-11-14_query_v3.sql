select min(start_time), max(end_time)
  from mpseq_1844374_traj;

select min(st_xmin(rect)), min(st_ymin(rect)), max(st_xmin(rect)), max(st_ymin(rect))
 from mpseq_1844374_traj where st_xmin(rect) > 100 and st_ymin(rect) > 25;

select st_xmin(rect), mpid, segid, start_time, end_time, tpseg
 from mpseq_1844374_traj where st_xmin(rect) = 0;


select start_time from mpseq_1844374_traj group by mpid, start_time order by start_time;
 
select end_time from mpseq_1844374_traj group by mpid, end_time order by end_time;

106.38702, 25.17141


select min(st_xmin(rect)) from mpseq_1844374_traj where st_xmin(rect) > 100 and st_ymin(rect) > 25;


select min(st_ymin(rect)) from mpseq_1844374_traj where st_xmin(rect) > 100 and st_ymin(rect) > 25;


select max(st_xmin(rect)) from mpseq_1844374_traj where st_xmin(rect) > 100 and st_ymin(rect) > 25;


select max(st_ymin(rect)) from mpseq_1844374_traj where st_xmin(rect) > 100 and st_ymin(rect) > 25;


select st_astext(tpseg[1].pnt) from mpseq_1844374_traj;

"POINT(116.44457 39.92157)"


114.0, 39.0

118.0, 41.5

select * from mpseq_1844374_traj where st_xmin(rect) <= 110 and st_ymin(rect) <= 35;

select * from mpseq_1844374_traj where (st_xmin(rect) <= 110 and st_ymin(rect) <= 35)
 or (st_xmax(rect) >= 120 and st_ymax(rect) >= 42);



select min(st_xmin(rect)), min(st_ymin(rect)), max(st_xmin(rect)), max(st_ymin(rect))
 from mpseq_1844374_traj where (st_xmin(rect) >= 110 and st_ymin(rect) >= 35)
  and (st_xmax(rect) <= 120 and st_ymax(rect) <= 42);


select count(*)
 from mpseq_1844579_traj;

 
select count(*)
 from mpseq_1844579_traj where (st_xmin(rect) >= 109 and st_ymin(rect) >= 34)
  and (st_xmax(rect) <= 120 and st_ymax(rect) <= 42);


select count(*)
 from mpseq_1844579_traj where (st_xmin(rect) <= 109 and st_ymin(rect) <= 34)
  or (st_xmax(rect) >= 120 and st_ymax(rect) >= 42);



