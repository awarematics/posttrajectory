
-- SETI* Query
select mpid from mpseq_17992_traj group by mpid order by mpid;

select mpid from mpseq_17992_traj group by mpid having sum(mpcount) > 2100 and mpid !=0 order by mpid;

select count(*) as cnt, sum(mpcount), mpid from mpseq_17992_traj group by mpid;

select count(*) as cnt, sum(mpcount), mpid from mpseq_17992_traj group by mpid having count(*) = 1;

select count(*) as cnt, sum(mpcount), mpid from mpseq_17992_traj group by mpid having sum(mpcount) > 2100;


-- Not SETI* Query
select mpid from mpseq_247024_traj group by mpid;

select mpid from mpseq_247024_traj group by mpid having sum(mpcount) > 2100 and mpid != 0 order by mpid;

select count(*) as cnt, sum(mpcount), mpid from mpseq_247024_traj group by mpid;

select count(*) as cnt, sum(mpcount), mpid from mpseq_247024_traj group by mpid having count(*) = 1;

select count(*) as cnt, sum(mpcount), mpid from mpseq_247024_traj group by mpid having sum(mpcount) > 2100;



-- General Query
select carnumber from mpseq_traj_data group by carnumber;

select count(*) as cnt, sum(mpcount), carnumber from mpseq_traj_data group by carnumber having count(*) >= 1;

select count(*) as cnt, sum(mpcount), carnumber from mpseq_traj_data group by carnumber having sum(mpcount) <1000 ;


select count(*) as cnt from (select carnumber from mpseq_traj_data group by carnumber) as carNumber;


select * from mpseq_traj_data where carnumber='6957';

select count(*) from mpseq_traj_data where carnumber='6957';

select count(*) as cnt, sum(mpcount), carnumber from mpseq_traj_data group by carnumber having count(*) > 100;


select count(*) as cnt, sum(mpcount), carnumber from mpseq_traj_data group by carnumber having count(*) = 633;


select carnumber from mpseq_traj_data group by carnumber limit 5;


select sum(mpcount) from mpseq_traj_data where carnumber='1131' limit 2;

select mpcount from mpseq_traj_data where carnumber='1131' order by id desc;


select sum(subTraj.mpcount) from (select * from mpseq_traj_data where carnumber='1131' order by id desc limit 2) as subTraj;

select sum(subTraj.mpcount) from (select * from mpseq_traj_data where carnumber='1131' order by id limit 2) as subTraj;

94920


select sum(subTraj.mpcount) from (select * from mpseq_traj_data where carnumber='1131' order by id limit 2) as subTraj;

