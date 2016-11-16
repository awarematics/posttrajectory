
-- Test 1
select * from mpseq_17992_traj where mpid=2 and segid=1;

select tpseg[118].ts from mpseq_17992_traj where mpid=2 and segid=651;

select * from taxi order by traj limit 5;



select * from mpseq_17992_traj where mpid=0 and segid=1;

select mpid, segid, start_time from mpseq_17992_traj group by mpid, segid, start_time having mpid=0 order by segid;


select tpseg[101] from mpseq_247024_traj_v100k where mpid=2 and segid=4;


select mpid from mpseq_247024_traj group by mpid having sum(mpcount) > 2100 and mpid !=0 order by mpid;






-- Test 2
insert into mpseq_247024_traj_v100k (select mpid, segid, next_segid, before_segid, mpcount, rect, start_time, end_time, _getTpointArrFromCount(tpseg, 150) as tpseg from mpseq_247024_traj where mpid = 3 and segid = 1)

select distinct mpid, segid, next_segid, before_segid, mpcount, start_time, end_time, _getTpointArrFromCount(tpseg, 150) as tpseg from mpseq_247024_traj where mpid = 3 and segid = 1;


select mpid, segid, next_segid, before_segid, mpcount, rect, start_time, end_time, _getTpointArrFromCount(tpseg, 150) as tpseg from mpseq_247024_traj where mpid = 3 and segid = 1;


select distinct mpid from mpseq_17992_traj where mpid = 3 and segid = 1;