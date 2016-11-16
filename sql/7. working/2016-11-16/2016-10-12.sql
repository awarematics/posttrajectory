select mpid from mpseq_1101138_traj group by mpid having sum(mpcount) > 2100 and mpid !=0 order by mpid;



select *
 from mpseq_1101138_traj where mpid = 7235 and segid = 1;


insert into mpseq_notseti_traj_v100k 
 (select mpid, segid, next_segid, before_segid, mpcount, rect, start_time, end_time, _getTpointArrFromCount(tpseg, $1) as tpseg
  from mpseq_1101138_traj where mpid = $2 and segid = $3);



  select distinct mpid, segid, next_segid, before_segid, mpcount, geometry(rect), start_time, end_time, _getTpointArrFromCount(tpseg, 100) as tpseg
  from mpseq_1101138_traj where mpid = 7235 and segid = 1;


  select mpid, segid, next_segid, before_segid, mpcount, rect, start_time, end_time, _getTpointArrFromCount(tpseg, 100) as tpseg
  from mpseq_1101138_traj group by mpid, segid, next_segid, before_segid, mpcount, rect, start_time, end_time, _getTpointArrFromCount(tpseg, 100)
   having mpid = 7235 and segid = 1;