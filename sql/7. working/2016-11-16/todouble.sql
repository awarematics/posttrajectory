-- Function: public.todouble(timestamp without time zone)

-- DROP FUNCTION public.todouble(timestamp without time zone);

CREATE OR REPLACE FUNCTION public.todouble(timestamp without time zone)
  RETURNS double precision AS
$BODY$
DECLARE
	ts				ALIAS FOR $1;

	ts_to_double			double precision;
BEGIN
	if ts is null then
		raise notice 'null';
		return null;
	else
		EXECUTE 'SELECT EXTRACT(EPOCH FROM TIMESTAMP WITHOUT TIME ZONE ' || quote_literal(ts) || ')' INTO ts_to_double;

		RETURN ts_to_double;
	end if;
END
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;
ALTER FUNCTION public.todouble(timestamp without time zone)
  OWNER TO postgres;



-- Function: public.todouble(timestamp with time zone)

-- DROP FUNCTION public.todouble(timestamp with time zone);

CREATE OR REPLACE FUNCTION public.todouble(timestamp with time zone)
  RETURNS double precision AS
$BODY$
DECLARE
	ts				ALIAS FOR $1;

	ts_to_double			double precision;
BEGIN
	if ts is null then
		raise notice 'null';
		return null;
	else
		EXECUTE 'SELECT EXTRACT(EPOCH FROM TIMESTAMP WITH TIME ZONE ' || quote_literal(ts) || ')' INTO ts_to_double;

		RETURN ts_to_double;
	end if;
END
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;
ALTER FUNCTION public.todouble(timestamp with time zone)
  OWNER TO postgres;


