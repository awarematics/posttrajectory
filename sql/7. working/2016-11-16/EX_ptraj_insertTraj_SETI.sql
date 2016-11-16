select sum(mpcount) from mpseq_seti_traj_v100k;
select sum(mpcount) from mpseq_seti_traj_v300k;
select sum(mpcount) from mpseq_seti_traj_v500k;
select sum(mpcount) from mpseq_seti_traj_v700k;
select sum(mpcount) from mpseq_seti_traj_v900k;


/*
*
* select EX_ptraj_insertTraj_SETI(100, 300, 500, 700, 900);
*
*/

-- select EX_ptraj_insertTraj_SETI(100, 300, 500, 700, 900);

CREATE OR REPLACE FUNCTION EX_ptraj_insertTraj_SETI(integer, integer, integer, integer, integer) RETURNS void AS
$BODY$
DECLARE

	input_cnt1	alias for $1;
	input_cnt2	alias for $2;
	input_cnt3	alias for $3;
	input_cnt4	alias for $4;
	input_cnt5	alias for $5;

	tmp_cnt1	integer;
	limit_cnt	integer;
	tp_cnt		integer;

	now_count	integer;
	mpid		integer;
	
	main_sql	varchar;
	sql		varchar;
	sql2		varchar;
	
	data_rcd	record;
BEGIN	
	main_sql := 'select mpid from mpseq_1101121_traj group by mpid having sum(mpcount) > 2100 and mpid !=0 order by mpid;';

	FOR mpid IN EXECUTE main_sql LOOP
		-- SIZE : 100
		tp_cnt := 150;
		tmp_cnt1 := input_cnt1;
		
		if tmp_cnt1 > tp_cnt then	
			if (tmp_cnt1 % tp_cnt) > 0 then
				limit_cnt := (tmp_cnt1 /tp_cnt) + 1;
			else 
				limit_cnt := (tmp_cnt1 / tp_cnt);
			end if;
		else 
			limit_cnt := 1;
		end if;
			
		sql := 'insert into mpseq_seti_traj_v100k';
		sql := sql || ' (select mpid, segid, next_segid, before_segid, mpcount, rect, start_time, end_time, _getTpointArrFromCount(tpseg, $1) as tpseg';
		sql := sql || ' from mpseq_1101121_traj where mpid = $2 and segid = $3);';

		now_count := 1;
		while limit_cnt >= now_count loop
			if tmp_cnt1 > tp_cnt then
				tmp_cnt1 := tmp_cnt1 - tp_cnt;
				-- raise notice 'segid : %, mpcount : %, start_time : %', taxi_rcd.segid, taxi_rcd.mpcount, taxi_rcd.start_time;			
			else 
				tp_cnt := tmp_cnt1;
			end if;
			
			execute sql using tp_cnt, mpid, now_count;

			sql2 := 'update mpseq_seti_traj_v100k set mpcount = $1 where mpid = $2 and segid = $3';

			execute sql2 using tp_cnt, mpid, now_count;
			-- raise notice 'count : %', data_rcd.cnt;

			now_count := now_count + 1;
		END LOOP;	


		-- SIZE : 300
		tp_cnt := 150;
		tmp_cnt1 := input_cnt2;
		
		if tmp_cnt1 > tp_cnt then	
			if (tmp_cnt1 % tp_cnt) > 0 then
				limit_cnt := (tmp_cnt1 /tp_cnt) + 1;
			else 
				limit_cnt := (tmp_cnt1 / tp_cnt);
			end if;
		else 
			limit_cnt := 1;
		end if;
			
		sql := 'insert into mpseq_seti_traj_v300k';
		sql := sql || ' (select mpid, segid, next_segid, before_segid, mpcount, rect, start_time, end_time, _getTpointArrFromCount(tpseg, $1) as tpseg';
		sql := sql || ' from mpseq_1101121_traj where mpid = $2 and segid = $3);';

		now_count := 1;
		while limit_cnt >= now_count loop
			if tmp_cnt1 > tp_cnt then
				tmp_cnt1 := tmp_cnt1 - tp_cnt;
				-- raise notice 'segid : %, mpcount : %, start_time : %', taxi_rcd.segid, taxi_rcd.mpcount, taxi_rcd.start_time;			
			else 
				tp_cnt := tmp_cnt1;
			end if;
			
			execute sql using tp_cnt, mpid, now_count;

			sql2 := 'update mpseq_seti_traj_v300k set mpcount = $1 where mpid = $2 and segid = $3';

			execute sql2 using tp_cnt, mpid, now_count;
			-- raise notice 'count : %', data_rcd.cnt;

			now_count := now_count + 1;
		END LOOP;


		-- SIZE : 500
		tp_cnt := 150;
		tmp_cnt1 := input_cnt3;
		
		if tmp_cnt1 > tp_cnt then	
			if (tmp_cnt1 % tp_cnt) > 0 then
				limit_cnt := (tmp_cnt1 /tp_cnt) + 1;
			else 
				limit_cnt := (tmp_cnt1 / tp_cnt);
			end if;
		else 
			limit_cnt := 1;
		end if;
			
		sql := 'insert into mpseq_seti_traj_v500k';
		sql := sql || ' (select mpid, segid, next_segid, before_segid, mpcount, rect, start_time, end_time, _getTpointArrFromCount(tpseg, $1) as tpseg';
		sql := sql || ' from mpseq_1101121_traj where mpid = $2 and segid = $3);';

		now_count := 1;
		while limit_cnt >= now_count loop
			if tmp_cnt1 > tp_cnt then
				tmp_cnt1 := tmp_cnt1 - tp_cnt;
				-- raise notice 'segid : %, mpcount : %, start_time : %', taxi_rcd.segid, taxi_rcd.mpcount, taxi_rcd.start_time;			
			else 
				tp_cnt := tmp_cnt1;
			end if;
			
			execute sql using tp_cnt, mpid, now_count;

			sql2 := 'update mpseq_seti_traj_v500k set mpcount = $1 where mpid = $2 and segid = $3';

			execute sql2 using tp_cnt, mpid, now_count;
			-- raise notice 'count : %', data_rcd.cnt;

			now_count := now_count + 1;
		END LOOP;


		-- SIZE : 700
		tp_cnt := 150;
		tmp_cnt1 := input_cnt4;
		
		if tmp_cnt1 > tp_cnt then	
			if (tmp_cnt1 % tp_cnt) > 0 then
				limit_cnt := (tmp_cnt1 /tp_cnt) + 1;
			else 
				limit_cnt := (tmp_cnt1 / tp_cnt);
			end if;
		else 
			limit_cnt := 1;
		end if;
			
		sql := 'insert into mpseq_seti_traj_v700k';
		sql := sql || ' (select mpid, segid, next_segid, before_segid, mpcount, rect, start_time, end_time, _getTpointArrFromCount(tpseg, $1) as tpseg';
		sql := sql || ' from mpseq_1101121_traj where mpid = $2 and segid = $3);';

		now_count := 1;
		while limit_cnt >= now_count loop
			if tmp_cnt1 > tp_cnt then
				tmp_cnt1 := tmp_cnt1 - tp_cnt;
				-- raise notice 'segid : %, mpcount : %, start_time : %', taxi_rcd.segid, taxi_rcd.mpcount, taxi_rcd.start_time;			
			else 
				tp_cnt := tmp_cnt1;
			end if;
			
			execute sql using tp_cnt, mpid, now_count;

			sql2 := 'update mpseq_seti_traj_v700k set mpcount = $1 where mpid = $2 and segid = $3';

			execute sql2 using tp_cnt, mpid, now_count;
			-- raise notice 'count : %', data_rcd.cnt;

			now_count := now_count + 1;
		END LOOP;


		-- SIZE : 900
		tp_cnt := 150;
		tmp_cnt1 := input_cnt5;
		
		if tmp_cnt1 > tp_cnt then	
			if (tmp_cnt1 % tp_cnt) > 0 then
				limit_cnt := (tmp_cnt1 /tp_cnt) + 1;
			else 
				limit_cnt := (tmp_cnt1 / tp_cnt);
			end if;
		else 
			limit_cnt := 1;
		end if;
			
		sql := 'insert into mpseq_seti_traj_v900k';
		sql := sql || ' (select mpid, segid, next_segid, before_segid, mpcount, rect, start_time, end_time, _getTpointArrFromCount(tpseg, $1) as tpseg';
		sql := sql || ' from mpseq_1101121_traj where mpid = $2 and segid = $3);';

		now_count := 1;
		while limit_cnt >= now_count loop
			if tmp_cnt1 > tp_cnt then
				tmp_cnt1 := tmp_cnt1 - tp_cnt;
				-- raise notice 'segid : %, mpcount : %, start_time : %', taxi_rcd.segid, taxi_rcd.mpcount, taxi_rcd.start_time;			
			else 
				tp_cnt := tmp_cnt1;
			end if;
			
			execute sql using tp_cnt, mpid, now_count;

			sql2 := 'update mpseq_seti_traj_v900k set mpcount = $1 where mpid = $2 and segid = $3';

			execute sql2 using tp_cnt, mpid, now_count;
			-- raise notice 'count : %', data_rcd.cnt;

			now_count := now_count + 1;
		END LOOP;
	END LOOP;
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE STRICT
COST 100;


