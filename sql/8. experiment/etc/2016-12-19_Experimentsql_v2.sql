
  select TJ_slice_from_seg_v2(traj
 , ST_MakeBox2D(ST_makePoint(116.30000, 39.90000), ST_makePoint(116.35000, 39.93000))
  , periods(timestamp without time zone '2008-02-02 15:54:46', timestamp without time zone '2008-02-02 16:37:58'))
   from taxi_lazy_ex1_600m
   where tj_pass_tt_from_seg(traj
 , ST_MakeBox2D(ST_makePoint(116.30000, 39.90000), ST_makePoint(116.35000, 39.93000))
  , periods(timestamp without time zone '2008-02-02 15:54:46', timestamp without time zone '2008-02-02 16:37:58'));



9200 -> 4912

3:23 -> 23.0


select * from pg_tables where tablename like 'tmp_%';


 drop table "tmp_mpseq_1101138_traj";

 drop table "tmp_mpseq_1101138_traj_seg";

 