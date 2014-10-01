delete from trajectory_columns;

drop table mpseq_84919_traj;

drop sequence taxi_traj_mpointid_seq cascade;

drop trigger delete_mpoint_seg;
drop trigger insert_tirgger;

drop function delete_mpoint_seg() cascade;
drop function insert_trigger() cascade;

drop table taxi cascade;



--- 테스트용 데이터

create table taxi(
	taxi_id integer,
	taxi_number varchar,
	taxi_model varchar,
	taxi_driver varchar
);

-- 컬럼 추가
select addtrajectorycolumn('public', 'taxi', 'traj', 4326, 'MOVINGPOINT', 2, 10);

select * from taxi;
delete from taxi;


-- 데이터구축 (INSERT)
insert into taxi values(1, '57NU2001', 'Optima', 'hongkd7');
insert into taxi values(2, '57NU2002', 'SonataYF', 'hongkd7');
insert into taxi values(3, '57NU2003', 'Optima', 'hongkd7');
insert into taxi values(4, '57NU2004', 'SonataYF', 'hongkd7');
insert into taxi values(5, '57NU2005', 'Optima', 'hongkd7');


insert into taxi values(6, '57누2006', '소나타YF', 'hongkd7');
insert into taxi values(7, '57누2007', '옵티마', 'hongkd7');
insert into taxi values(8, '57누2008', '옵티마', 'hongkd7');
insert into taxi values(9, '57누2009', '소나타YF', 'hongkd7');
insert into taxi values(10, '57누2010', '소나타YF', 'hongkd7');





select * from taxi;




--최초 삽입  첫번째 row 생성
update taxi set traj = append(traj, tpoint(st_point(200, 200),TIMESTAMP '2010-01-25 12:05:30+09')) 
		where taxi_id = 1;
-- mpseg 추가
update taxi set traj = append(traj, tpoint(st_point(300, 240),TIMESTAMP '2010-01-26 12:07:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(1254, 2354),TIMESTAMP '2010-01-26 12:11:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(2364, 12),TIMESTAMP '2010-01-26 12:12:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(325, 1254),TIMESTAMP '2010-01-26 12:13:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(567, 697),TIMESTAMP '2010-01-26 12:14:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(6987, 3215),TIMESTAMP '2010-01-26 12:15:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(321, 111),TIMESTAMP '2010-01-26 12:16:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(426, 357),TIMESTAMP '2010-01-26 12:17:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(567, 1254),TIMESTAMP '2010-01-26 12:18:40+09')) 
		where taxi_id = 1;
-- 11번째 삽입 2번째 row 생성
update taxi set traj = append(traj, tpoint(st_point(1035, 2354),TIMESTAMP '2010-01-26 12:30:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(5875, 3548),TIMESTAMP '2010-01-26 12:30:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(2354, 6786),TIMESTAMP '2010-01-26 12:31:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(657, 359),TIMESTAMP '2010-01-26 12:33:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(659, 360),TIMESTAMP '2010-01-26 12:34:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(670, 365),TIMESTAMP '2010-01-26 12:35:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(680, 379),TIMESTAMP '2010-01-26 12:36:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(700, 400),TIMESTAMP '2010-01-26 12:37:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(800, 500),TIMESTAMP '2010-01-26 12:38:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(850, 423),TIMESTAMP '2010-01-26 12:39:40+09')) 
		where taxi_id = 1;
--21번째 삽입 3번째 row 생성
update taxi set traj = append(traj, tpoint(st_point(960, 560),TIMESTAMP '2010-01-26 13:01:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(1230, 830),TIMESTAMP '2010-01-26 13:02:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(1200, 860),TIMESTAMP '2010-01-26 13:04:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(1600, 900),TIMESTAMP '2010-01-26 13:07:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(1563, 983),TIMESTAMP '2010-01-26 13:10:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(1510, 910),TIMESTAMP '2010-01-26 13:15:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(1430, 1000),TIMESTAMP '2010-01-26 13:18:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(1350, 1100),TIMESTAMP '2010-01-26 13:20:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(1230, 1020),TIMESTAMP '2010-01-26 13:25:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(1200, 1000),TIMESTAMP '2010-01-26 13:27:40+09')) 
		where taxi_id = 1;
--31번째 삽입 4번째 row 생성
update taxi set traj = append(traj, tpoint(st_point(1156, 1020),TIMESTAMP '2010-01-26 14:00:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(1100, 980),TIMESTAMP '2010-01-26 14:01:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(1053, 940),TIMESTAMP '2010-01-26 14:05:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(1010, 895),TIMESTAMP '2010-01-26 14:10:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(987, 842),TIMESTAMP '2010-01-26 14:15:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(952, 900),TIMESTAMP '2010-01-26 14:16:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(910, 910),TIMESTAMP '2010-01-26 14:19:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(810, 1000),TIMESTAMP '2010-01-26 14:30:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(720, 825),TIMESTAMP '2010-01-26 14:48:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(1000, 1000),TIMESTAMP '2010-01-26 14:50:40+09')) 
		where taxi_id = 1;

--41번째 삽입 5번째 row 생성
update taxi set traj = append(traj, tpoint(st_point(1100, 1000),TIMESTAMP '2010-01-26 14:53:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(1200, 950),TIMESTAMP '2010-01-26 14:58:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(1300, 1060),TIMESTAMP '2010-01-26 15:05:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(1400, 970),TIMESTAMP '2010-01-26 15:12:40+09')) 
		where taxi_id = 1;
update taxi set traj = append(traj, tpoint(st_point(1500, 1200),TIMESTAMP '2010-01-26 15:18:40+09')) 
		where taxi_id = 1;


update taxi set traj = append(traj, tpoint(st_point(350, 260),TIMESTAMP '2010-01-26 15:20:40+09')) 
		where taxi_id = 2;
update taxi set traj = append(traj, tpoint(st_point(310, 210),TIMESTAMP '2010-01-26 15:35:40+09')) 
		where taxi_id = 3;
update taxi set traj = append(traj, tpoint(st_point(1000, 1500),TIMESTAMP '2010-01-26 15:39:40+09')) 
		where taxi_id = 4;
update taxi set traj = append(traj, tpoint(st_point(267, 3257),TIMESTAMP '2010-01-26 15:43:40+09')) 
		where taxi_id = 2;
update taxi set traj = append(traj, tpoint(st_point(3246, 2367),TIMESTAMP '2010-01-26 15:45:40+09')) 
		where taxi_id = 2;
update taxi set traj = append(traj, tpoint(st_point(3267, 9875),TIMESTAMP '2010-01-26 15:47:40+09')) 
		where taxi_id = 2;
update taxi set traj = append(traj, tpoint(st_point(9546, 9873),TIMESTAMP '2010-01-26 15:50:40+09')) 
		where taxi_id = 2;
update taxi set traj = append(traj, tpoint(st_point(2354, 2315),TIMESTAMP '2010-01-26 15:56:40+09')) 
		where taxi_id = 2;



-- append(trajcetory, tpoint[]) 테스트 4개만 추가
update taxi set traj = append(traj, ARRAY[ ( tpoint(st_point(1510, 1210),TIMESTAMP '2010-01-26 15:21:40+09') ), 
					   ( tpoint(st_point(1320, 1220),TIMESTAMP '2010-01-26 15:25:40+09') ), 
					   ( tpoint(st_point(1405, 1175),TIMESTAMP '2010-01-26 15:29:40+09') ), 
					   ( tpoint(st_point(1461, 1037),TIMESTAMP '2010-01-26 15:36:40+09') ) ]::tpoint[] )  
		where taxi_id = 1;

-- append(trajcetory, tpoint[]) 테스트 5개를 더 추가함으로써 새로운 6번째 row 생성
update taxi set traj = append(traj, ARRAY[ ( tpoint(st_point(1201, 1201),TIMESTAMP '2010-01-26 15:39:40+09') ), 
					   ( tpoint(st_point(1025, 1025),TIMESTAMP '2010-01-26 15:40:40+09') ), 
					   ( tpoint(st_point(1453, 1452),TIMESTAMP '2010-01-26 15:46:40+09') ),
					   ( tpoint(st_point(1315, 1300),TIMESTAMP '2010-01-26 15:49:40+09') ), 
					   ( tpoint(st_point(1236, 1475),TIMESTAMP '2010-01-26 15:57:40+09') ) ]::tpoint[] )  
		where taxi_id = 1;


select * from taxi;

-- reomve 테스트 
--3번째 row의 값 5개 삭제
update taxi set traj = remove(traj, TIMESTAMP '2010-01-26 12:33:40+09', TIMESTAMP '2010-01-26 12:37:40+09')
	where taxi_id = 1;


-- 삭제 1row 이상을 삭제하게 되면(row에 tpseg값이 하나도 없게되면) row를 삭제해주는 실험
update taxi set traj = remove(traj, TIMESTAMP '2010-01-26 12:18:40+09', TIMESTAMP '2010-01-26 12:45:40+09')
	where taxi_id = 1;




--modify 테스트
update taxi set traj = modify(traj, tpoint(st_point(1000, 1000), TIMESTAMP '2010-01-26 15:40:40+9'))
	where taxi_id = 1;

--modify(trajectory, tpoint[]) 테스트
update taxi set traj = modify(traj, ARRAY[ (tpoint(st_point(1000, 1000), TIMESTAMP '2010-01-26 15:40:40+9') ),
					   (tpoint(st_point(1200, 1100), TIMESTAMP '2010-01-26 15:46:40+9') ),
					   (tpoint(st_point(1400, 1050), TIMESTAMP '2010-01-26 15:49:40+9') ),
					   (tpoint(st_point(2000, 2000), TIMESTAMP '2010-01-26 15:57:40+9') ) ]::tpoint[] )
	where taxi_id = 1;


update taxi set traj = modify(traj, ARRAY[ (tpoint(st_point(0000, 0000), TIMESTAMP '2010-01-26 15:40:40+9') ),
					   (tpoint(st_point(0000, 0000), TIMESTAMP '2010-01-26 15:46:40+9') ),
					   (tpoint(st_point(0000, 0000), TIMESTAMP '2010-01-26 15:49:40+9') ),
					   (tpoint(st_point(0000, 0000), TIMESTAMP '2010-01-26 15:57:40+9') ) ]::tpoint[] )
	where taxi_id = 1;


-- modify(trajectory, timestamp, timestamp, tpoint[]) 테스트
-- 사용자 입력시간과 tpoint[]의 시간이 contain 되지 않을때
update taxi set traj = modify(traj, TIMESTAMP '2010-01-26 14:00:40+9', TIMESTAMP '2010-01-26 14:03:40+9',
			      ARRAY[ (tpoint(st_point(0000, 0000), TIMESTAMP '2010-01-26 15:00:40+9') ),
			             (tpoint(st_point(0000, 0000), TIMESTAMP '2010-01-26 15:01:40+9') ),
				     (tpoint(st_point(0000, 0000), TIMESTAMP '2010-01-26 15:02:40+9') ),
				     (tpoint(st_point(0000, 0000), TIMESTAMP '2010-01-26 15:03:40+9') ) ]::tpoint[] )
	where taxi_id = 1;


-- 시작시간과 끝시간, tpoint[]값을 줬을때 modify
update taxi set traj = modify(traj, TIMESTAMP '2010-01-26 15:00:40+9', TIMESTAMP '2010-01-26 15:03:40+9',
			      ARRAY[ (tpoint(st_point(0000, 0000), TIMESTAMP '2010-01-26 15:00:40+9') ),
			             (tpoint(st_point(0000, 0000), TIMESTAMP '2010-01-26 15:01:40+9') ),
				     (tpoint(st_point(0000, 0000), TIMESTAMP '2010-01-26 15:02:40+9') ),
				     (tpoint(st_point(0000, 0000), TIMESTAMP '2010-01-26 15:03:40+9') ) ]::tpoint[] )
	where taxi_id = 1;






-- 인터섹션 사용 예
select astext(	( select st_intersection( 
						( select geometryfromtext('LINESTRING(20 130, 80 170, 170 190, 140 70, 190 80, 210 140, 230 80, 210 90, 270 160, 350 120)' ) ) ,
						( select st_geometry('BOX(130 50, 300 220)'::box2d ) 
					     ) 
					  ) 
				  ) );


-- 인터섹션후 첫번째 라인스트링을 가져오기 select astext( select st_geometryn ( st_intersection ( geometry, geometry ) ) );
select astext( ( select st_geometryn( ( select st_intersection( 
						( select geometryfromtext('LINESTRING(20 130, 80 170, 170 190, 140 70, 190 80, 210 140, 230 80, 210 90, 270 160, 350 120)' ) ) ,
						( select st_geometry('BOX(130 50, 300 220)'::box2d ) 
					     ) 
					  ) 
				  ) , 1)
			  ) );


-- geometry의 갯수를 가져오기
select st_numgeometries(	( select st_intersection( 
						( select geometryfromtext('LINESTRING(20 130, 80 170, 170 190, 140 70, 190 80, 210 140, 230 80, 210 90, 270 160, 350 120)' ) ) ,
						( select st_geometry('BOX(130 50, 300 220)'::box2d ) 
					     ) 
					  ) 
				  ) );




// slice 고칠것 	
//select slice('member', TIMESTAMP '2011-02-20 17:13:00', TIMESTAMP '2011-02-20 17:26:00');

// 다음 처럼 되게 고칠것
select slice( traj, TIMESTAMP '2011-02-20 17:13:00', TIMESTAMP '2011-02-20 17:26:00')
from taxi;

select name
from student;

select stay(traj, 'LINESTRING(15000 18000, 30000 30000)') 
from taxi;


select slice( traj, TIMESTAMP '2011-02-20 17:13:00', TIMESTAMP '2011-02-20 17:26:00'), stay(traj, 'LINESTRING(15000 18000, 30000 30000)')
from taxi;


select aa_enter( traj, st_geometry('BOX(17 6, 29 31)'::box2d) 
from taxi;

select slice( traj, st_geometry('BOX(17 6, 29 31)'::box2d) ),  aa_enter( traj, st_geometry('BOX(17 6, 29 31)'::box2d) )
from taxi;




delete from mpseq_543940_traj;
