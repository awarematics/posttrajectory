select mpid from mpseq_1413448_traj
 where Post_TJ_pass(st_geomfromtext('polygon((116.44989 39.86646,116.44989 39.87334,118.47135 39.87334,118.47135 39.86646,116.44989 39.86646))'))

explain
select taxi_id, taxi_number, traj, taxi_model from taxi 
 where Post_TJ_pass(taxi.traj, st_geomfromtext('polygon((116.44989 39.86646,116.44989 39.87334,118.47135 39.87334,118.47135 39.86646,116.44989 39.86646))'))


select count(*) from taxi 
 where Post_TJ_pass(taxi.traj, st_geomfromtext('polygon((116.44989 39.86646,116.44989 39.87334,118.47135 39.87334,118.47135 39.86646,116.44989 39.86646))'))


 select count(*) from mpseq_1413448_traj

 CREATE INDEX mpseq_1413448_traj_gist ON mpseq_1413448_traj USING gist(rect);  