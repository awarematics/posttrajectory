
-- 100k : spatial min, max


-- 100k : time min, max
select min(start_time), max(end_time) from mpseq_1844374_traj;
"2008-02-02 13:30:44";"2008-02-06 00:28:44"

-- 300k : time min, max
select min(start_time), max(end_time) from mpseq_1844528_traj;
"2008-02-02 13:30:44";"2008-02-06 15:04:54"

-- 500k : time min, max
select min(start_time), max(end_time) from mpseq_1844545_traj;
"2008-02-02 13:30:44";"2008-02-07 10:17:52"

-- 700k : time min, max
select min(start_time), max(end_time) from mpseq_1844562_traj;
"2008-02-02 13:30:44";"2008-02-07 12:15:46"

-- 900k : time min, max
select min(start_time), max(end_time) from mpseq_1844579_traj;
"2008-02-02 13:30:44";"2008-02-07 13:32:26"