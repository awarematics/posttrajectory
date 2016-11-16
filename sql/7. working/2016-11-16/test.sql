
select sum(mpcount) from mpseq_17992_traj;

17,574,707

select sum(mpcount) from mpseq_247024_traj; 

19,347,622


select min(start_time), max(end_time) from mpseq_247024_traj; 

start_time : "2008-02-02 13:30:44";

end_time : "2008-02-08 17:39:19"


select sum(mpcount) from mpseq_247024_traj where start_time>=timestamp '2008-02-02 00:00:00' and end_time <= timestamp '2008-02-02 13:30:44'; 

select max(start_time) from mpseq_247024_traj limit 10000; 