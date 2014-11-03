
-- TT_present 테스트
select TT_present(ARRAY[ (tpoint(st_point(1000, 1000), TIMESTAMP '2010-01-26 15:40:40+9') ),
					   (tpoint(st_point(1200, 1100), TIMESTAMP '2010-01-26 15:46:40+9') ),
					   (tpoint(st_point(1400, 1050), TIMESTAMP '2010-01-26 15:49:40+9') ),
					   (tpoint(st_point(2000, 2000), TIMESTAMP '2010-01-26 15:57:40+9') ) ]::tpoint[], TIMESTAMP '2010-01-26 15:40:40+9');


-- TT_trajectory 테스트
select ST_AsText(TT_trajectory(ARRAY[ (tpoint(st_point(1000, 1000), TIMESTAMP '2010-01-26 15:40:40+9') ),
					   (tpoint(st_point(1200, 1100), TIMESTAMP '2010-01-26 15:46:40+9') ),
					   (tpoint(st_point(1400, 1050), TIMESTAMP '2010-01-26 15:49:40+9') ),
					   (tpoint(st_point(2000, 2000), TIMESTAMP '2010-01-26 15:57:40+9') ) ]::tpoint[]));


-- TT_length 테스트
select TT_length(ARRAY[ (tpoint(st_point(1000, 1000), TIMESTAMP '2010-01-26 15:40:40+9') ),
					   (tpoint(st_point(1200, 1100), TIMESTAMP '2010-01-26 15:46:40+9') ),
					   (tpoint(st_point(1400, 1050), TIMESTAMP '2010-01-26 15:49:40+9') ),
					   (tpoint(st_point(2000, 2000), TIMESTAMP '2010-01-26 15:57:40+9') ) ]::tpoint[]);
					   

-- TT_deftime 테스트
select TT_deftime(ARRAY[ (tpoint(st_point(1000, 1000), TIMESTAMP '2010-01-26 15:40:40+9') ),
					   (tpoint(st_point(1200, 1100), TIMESTAMP '2010-01-26 15:46:40+9') ),
					   (tpoint(st_point(1400, 1050), TIMESTAMP '2010-01-26 15:49:40+9') ),
					   (tpoint(st_point(2000, 2000), TIMESTAMP '2010-01-26 15:57:40+9') ) ]::tpoint[]);



-- TT_Equals 테스트
select TT_Equals(TT_PERIOD(TIMESTAMP '2010-01-26 15:55:40+9', TIMESTAMP '2010-01-26 15:55:40+9'), 
			TT_PERIOD(TIMESTAMP '2010-01-26 15:55:40+9', TIMESTAMP '2010-01-26 15:55:40+9'));



-- TT_Before 테스트
select TT_Before(TT_PERIOD(TIMESTAMP '2010-01-26 15:50:40+9', TIMESTAMP '2010-01-26 15:55:40+9'), 
			TT_PERIOD(TIMESTAMP '2010-01-26 15:55:41+9', TIMESTAMP '2010-01-26 15:56:40+9'));



-- TT_Meets 테스트
select TT_Meets(TT_PERIOD(TIMESTAMP '2010-01-26 15:55:40+9', TIMESTAMP '2010-01-26 15:55:41+9'), 
			TT_PERIOD(TIMESTAMP '2010-01-26 15:50:40+9', TIMESTAMP '2010-01-26 15:55:41+9'));

			

-- TT_Overlaps 테스트
select TT_Overlaps(TT_PERIOD(TIMESTAMP '2010-01-26 15:48:40+9', TIMESTAMP '2010-01-26 15:50:40+9'), 
			TT_PERIOD(TIMESTAMP '2010-01-26 15:50:40+9', TIMESTAMP '2010-01-26 15:55:40+9'));



-- TT_During 테스트
select TT_During(TT_PERIOD(TIMESTAMP '2010-01-26 15:48:40+9', TIMESTAMP '2010-01-26 15:54:40+9'), 
			TT_PERIOD(TIMESTAMP '2010-01-26 15:45:40+9', TIMESTAMP '2010-01-26 15:55:40+9'));



-- TT_Starts 테스트
select TT_Starts(TT_PERIOD(TIMESTAMP '2010-01-26 15:41:40+9', TIMESTAMP '2010-01-26 15:54:40+9'), 
			TT_PERIOD(TIMESTAMP '2010-01-26 15:45:40+9', TIMESTAMP '2010-01-26 15:50:40+9'));



-- TT_Finishes 테스트
select TT_Finishes(TT_PERIOD(TIMESTAMP '2010-01-26 15:46:40+9', TIMESTAMP '2010-01-26 15:50:40+9'), 
			TT_PERIOD(TIMESTAMP '2010-01-26 15:45:40+9', TIMESTAMP '2010-01-26 15:50:40+9'));



-- TT_Finishes 테스트
select TT_Intersects(TT_PERIOD(TIMESTAMP '2010-01-26 15:51:40+9', TIMESTAMP '2010-01-26 15:55:40+9'), 
			TT_PERIOD(TIMESTAMP '2010-01-26 15:50:40+9', TIMESTAMP '2010-01-26 15:50:44+9'));



-- TT_Isnull 테스트
select TT_Isnull(NULL);



select ST_AsText(getLineString(getPresent_bools(ARRAY[ (tpoint(st_point(1000, 1000), TIMESTAMP '2010-01-26 15:40:40+9') ),
					   (tpoint(st_point(1200, 1100), TIMESTAMP '2010-01-26 15:46:40+9') ),
					   (tpoint(st_point(1400, 1050), TIMESTAMP '2010-01-26 15:49:40+9') ),
					   (tpoint(st_point(2000, 2000), TIMESTAMP '2010-01-26 15:57:40+9') ) ]::tpoint[])));


select ST_length(getLineString(getPresent_bools(ARRAY[ (tpoint(st_point(1000, 1000), TIMESTAMP '2010-01-26 15:40:40+9') ),
					   (tpoint(st_point(1200, 1100), TIMESTAMP '2010-01-26 15:46:40+9') ),
					   (tpoint(st_point(1400, 1050), TIMESTAMP '2010-01-26 15:49:40+9') ),
					   (tpoint(st_point(2000, 2000), TIMESTAMP '2010-01-26 15:57:40+9') ) ]::tpoint[])));


