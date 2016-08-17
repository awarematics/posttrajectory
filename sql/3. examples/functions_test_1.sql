

-- _TJ_passes 테스트
explain analyze
select st_asText(tl_spsb_statn.geom) from tl_spsb_statn, mpseq_18491_traj
 where _TJ_passes(mpseq_18491_traj.rect, tl_spsb_statn.geom, mpseq_18491_traj.tpseg)
  AND  mpseq_18491_traj.segid != 1;

-- TJ_present 테스트
select TJ_present(ARRAY[ (tpoint(st_point(1000, 1000), TIMESTAMP '2010-01-26 15:40:40+9') ),
					   (tpoint(st_point(1200, 1100), TIMESTAMP '2010-01-26 15:46:40+9') ),
					   (tpoint(st_point(1400, 1050), TIMESTAMP '2010-01-26 15:49:40+9') ),
					   (tpoint(st_point(2000, 2000), TIMESTAMP '2010-01-26 15:57:40+9') ) ]::tpoint[], TIMESTAMP '2010-01-26 15:40:40+9');


-- TJ_trajectory 테스트
select ST_AsText(TJ_trajectory(ARRAY[ (tpoint(st_point(1000, 1000), TIMESTAMP '2010-01-26 15:40:40+9') ),
					   (tpoint(st_point(1200, 1100), TIMESTAMP '2010-01-26 15:46:40+9') ),
					   (tpoint(st_point(1400, 1050), TIMESTAMP '2010-01-26 15:49:40+9') ),
					   (tpoint(st_point(2000, 2000), TIMESTAMP '2010-01-26 15:57:40+9') ) ]::tpoint[]));


-- TJ_length 테스트
select TJ_length(ARRAY[ (tpoint(st_point(1000, 1000), TIMESTAMP '2010-01-26 15:40:40+9') ),
					   (tpoint(st_point(1200, 1100), TIMESTAMP '2010-01-26 15:46:40+9') ),
					   (tpoint(st_point(1400, 1050), TIMESTAMP '2010-01-26 15:49:40+9') ),
					   (tpoint(st_point(2000, 2000), TIMESTAMP '2010-01-26 15:57:40+9') ) ]::tpoint[]);
					   

-- TJ_deftime 테스트
select TJ_deftime(ARRAY[ (tpoint(st_point(1000, 1000), TIMESTAMP '2010-01-26 15:40:40+9') ),
					   (tpoint(st_point(1200, 1100), TIMESTAMP '2010-01-26 15:46:40+9') ),
					   (tpoint(st_point(1400, 1050), TIMESTAMP '2010-01-26 15:49:40+9') ),
					   (tpoint(st_point(2000, 2000), TIMESTAMP '2010-01-26 15:57:40+9') ) ]::tpoint[]);



-- TJ_Equals 테스트
select TJ_Equals(TJ_PERIOD(TIMESTAMP '2010-01-26 15:55:40+9', TIMESTAMP '2010-01-26 15:55:40+9'), 
			TJ_PERIOD(TIMESTAMP '2010-01-26 15:55:40+9', TIMESTAMP '2010-01-26 15:55:40+9'));



-- TJ_Before 테스트
select TJ_Before(TJ_PERIOD(TIMESTAMP '2010-01-26 15:50:40+9', TIMESTAMP '2010-01-26 15:55:40+9'), 
			TJ_PERIOD(TIMESTAMP '2010-01-26 15:55:41+9', TIMESTAMP '2010-01-26 15:56:40+9'));



-- TJ_Meets 테스트
select TJ_Meets(TJ_PERIOD(TIMESTAMP '2010-01-26 15:55:40+9', TIMESTAMP '2010-01-26 15:55:41+9'), 
			TJ_PERIOD(TIMESTAMP '2010-01-26 15:50:40+9', TIMESTAMP '2010-01-26 15:55:41+9'));

			

-- TJ_Overlaps 테스트
select TJ_Overlaps(TJ_PERIOD(TIMESTAMP '2010-01-26 15:48:40+9', TIMESTAMP '2010-01-26 15:50:40+9'), 
			TJ_PERIOD(TIMESTAMP '2010-01-26 15:50:40+9', TIMESTAMP '2010-01-26 15:55:40+9'));



-- TJ_During 테스트
select TJ_During(TJ_PERIOD(TIMESTAMP '2010-01-26 15:48:40+9', TIMESTAMP '2010-01-26 15:54:40+9'), 
			TJ_PERIOD(TIMESTAMP '2010-01-26 15:45:40+9', TIMESTAMP '2010-01-26 15:55:40+9'));



-- TJ_Starts 테스트
select TJ_Starts(TJ_PERIOD(TIMESTAMP '2010-01-26 15:41:40+9', TIMESTAMP '2010-01-26 15:54:40+9'), 
			TJ_PERIOD(TIMESTAMP '2010-01-26 15:45:40+9', TIMESTAMP '2010-01-26 15:50:40+9'));



-- TJ_Finishes 테스트
select TJ_Finishes(TJ_PERIOD(TIMESTAMP '2010-01-26 15:46:40+9', TIMESTAMP '2010-01-26 15:50:40+9'), 
			TJ_PERIOD(TIMESTAMP '2010-01-26 15:45:40+9', TIMESTAMP '2010-01-26 15:50:40+9'));



-- TJ_Finishes 테스트
select TJ_Intersects(TJ_PERIOD(TIMESTAMP '2010-01-26 15:51:40+9', TIMESTAMP '2010-01-26 15:55:40+9'), 
			TJ_PERIOD(TIMESTAMP '2010-01-26 15:50:40+9', TIMESTAMP '2010-01-26 15:50:44+9'));



-- TJ_Isnull 테스트
select TJ_Isnull(NULL);



select ST_AsText(getLineString(getPresent_bools(ARRAY[ (tpoint(st_point(1000, 1000), TIMESTAMP '2010-01-26 15:40:40+9') ),
					   (tpoint(st_point(1200, 1100), TIMESTAMP '2010-01-26 15:46:40+9') ),
					   (tpoint(st_point(1400, 1050), TIMESTAMP '2010-01-26 15:49:40+9') ),
					   (tpoint(st_point(2000, 2000), TIMESTAMP '2010-01-26 15:57:40+9') ) ]::tpoint[])));


select ST_length(getLineString(getPresent_bools(ARRAY[ (tpoint(st_point(1000, 1000), TIMESTAMP '2010-01-26 15:40:40+9') ),
					   (tpoint(st_point(1200, 1100), TIMESTAMP '2010-01-26 15:46:40+9') ),
					   (tpoint(st_point(1400, 1050), TIMESTAMP '2010-01-26 15:49:40+9') ),
					   (tpoint(st_point(2000, 2000), TIMESTAMP '2010-01-26 15:57:40+9') ) ]::tpoint[])));


