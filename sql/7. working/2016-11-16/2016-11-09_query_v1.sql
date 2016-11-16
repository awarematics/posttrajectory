
update mpseq_1875286_traj set rect = box2d(tpoint_to_linestring(tpseg)) where mpid=25 and segid =1;

update mpseq_1875286_traj set rect = box2d(tpoint_to_linestring(tpseg))


-- 100k, 300k, 500k, 700k, 900k
select (traj).segtableoid from taxi_ex1_100k limit 1;
1844374

select (traj).segtableoid from taxi_ex1_300k limit 1;
1844528

select (traj).segtableoid from taxi_ex1_500k limit 1;
1844545

select (traj).segtableoid from taxi_ex1_700k limit 1;
1844562

select (traj).segtableoid from taxi_ex1_900k limit 1;
1844579


-- 200k, 400k, 600k, 800k, 1000k
select (traj).segtableoid from taxi_ex2_200k limit 1;
1875286

select (traj).segtableoid from taxi_ex2_400k limit 1;
1875303

select (traj).segtableoid from taxi_ex2_600k limit 1;
1875320

select (traj).segtableoid from taxi_ex2_800k limit 1;
1875337

select (traj).segtableoid from taxi_ex2_1000k limit 1;
1875354
