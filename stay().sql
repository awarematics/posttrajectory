CREATE OR REPLACE FUNCTION stay(trajectory, text) RETURNS setof text AS
$$
DECLARE
	user_traj	alias for $1;
	user_rect	alias for $2;
	f_trajectory_segtable_name	text;
	sql				text;
	data				record;
	rect_text			text;
	time_stamp	TIMESTAMP;
	time_stamp2	TIMESTAMP;
	rect_origin	geometry;
BEGIN
	sql := 'select relname from pg_catalog.pg_class c
	where c.oid = '|| user_traj.segtableoid;
	RAISE DEBUG '%', sql;
	EXECUTE sql INTO f_trajectory_segtable_name;

	EXECUTE 'select GeometryFromText(' || quote_literal(user_rect) || ')'
	into rect_origin;

	sql := 'select * from ' || quote_ident(f_trajectory_segtable_name) || ' where mpid = ' || user_traj.moid;
	FOR data IN EXECUTE sql LOOP
		IF( intersects(rect_origin, data.rect) = TRUE ) THEN
			EXECUTE 'select getbbox( $1 )'
			INTO rect_text USING data.rect;
			return next rect_text;
		END IF;

	END LOOP;

END
$$
LANGUAGE 'plpgsql'

drop function stay(text);

select * from stay((select traj from bus_100 where id = 1), 'LINESTRING(15000 18000, 30000 30000)');


select * from stay((select traj from bus_100 where id = 1), 'LINESTRING(150000 180000, 300000 300000)');
