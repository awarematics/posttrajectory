
  select TJ_slice_from_base(traj
 , ST_MakeBox2D(ST_makePoint(116.00000, 39.90000), ST_makePoint(116.30000, 40.00000))
  , periods(timestamp without time zone '2008-02-02 13:30:44', timestamp without time zone '2008-02-02 21:30:54'))
   from taxi2
   where tj_pass_tt_from_id(traj
 , ST_MakeBox2D(ST_makePoint(116.00000, 39.90000), ST_makePoint(116.30000, 40.00000))
  , periods(timestamp without time zone '2008-02-02 13:30:44', timestamp without time zone '2008-02-02 21:30:54'));

9200 -> 4912

3:48 -> 52.9


 drop table "tmp_mpseq_1101138_traj";

 drop table "tmp_mpseq_1101138_traj_seg";

 taxi_lazy_ex1_600m

  select TJ_slice_from_base(traj
 , ST_MakeBox2D(ST_makePoint(116.30000, 39.90000), ST_makePoint(116.35000, 39.93000))
  , periods(timestamp without time zone '2008-02-02 15:54:46', timestamp without time zone '2008-02-02 16:37:58'))
   from taxi_lazy_ex1_600m
   where tj_pass_tt_from_id(traj
 , ST_MakeBox2D(ST_makePoint(116.30000, 39.90000), ST_makePoint(116.35000, 39.93000))
  , periods(timestamp without time zone '2008-02-02 15:54:46', timestamp without time zone '2008-02-02 16:37:58'));

=> 2408 -> 2166

select * from pg_tables where tablename like 'tmp_%';