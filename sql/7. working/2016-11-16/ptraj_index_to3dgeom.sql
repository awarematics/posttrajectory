-- Function: public.ptraj_index_to3dgeom(box2d, timestamp without time zone, timestamp without time zone)

-- DROP FUNCTION public.ptraj_index_to3dgeom(box2d, timestamp without time zone, timestamp without time zone);

CREATE OR REPLACE FUNCTION public.ptraj_index_to3dgeom(
    box2d,
    timestamp without time zone,
    timestamp without time zone)
  RETURNS geometry AS
$BODY$
DECLARE
	input_box			ALIAS FOR $1;
	start_time			ALIAS FOR $2;
	end_time			ALIAS FOR $3;

	xmin				float;
	ymin				float;
	zmin				float;
	xmax				float;
	ymax				float;
	zmax				float;

	output_geom			geometry;
BEGIN
	xmin := ST_XMin(input_box);
	ymin := ST_YMin(input_box);
	zmin := toDouble(start_time);
	xmax := ST_XMax(input_box);
	ymax := ST_YMax(input_box);
	zmax := toDouble(end_time);

	output_geom := ST_MakeLine(ST_MakePoint(xmin, ymin, zmin), ST_MakePoint(xmax, ymax, zmax));
	
	RETURN output_geom;
END
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;
ALTER FUNCTION public.ptraj_index_to3dgeom(box2d, timestamp without time zone, timestamp without time zone)
  OWNER TO postgres;
