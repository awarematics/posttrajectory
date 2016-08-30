CREATE OR REPLACE FUNCTION public.toDouble(TIMESTAMP WITHOUT TIME ZONE)
  RETURNS double precision AS
$$
DECLARE
	ts				ALIAS FOR $1;

	i				integer;
	array_max			integer;
	ts_to_double			double precision;
	
	return_geoms			geometry;
BEGIN
	EXECUTE 'SELECT EXTRACT(EPOCH FROM TIMESTAMP WITH TIME ZONE ' || quote_literal(ts) || ')' INTO ts_to_double;

	RETURN ts_to_double;
END
$$
  LANGUAGE plpgsql IMMUTABLE;