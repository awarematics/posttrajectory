﻿-- Function: public.ptraj_index_to3dgeom(box2d, timestamp without time zone, timestamp without time zone)

-- DROP FUNCTION public.ptraj_index_to3dgeom(box2d, timestamp without time zone, timestamp without time zone);

CREATE OR REPLACE FUNCTION public.ptraj_index_to3dgeom(
    box2d,
    timestamp without time zone,
    timestamp without time zone)
  RETURNS geometry AS
$$
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
$$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;
ALTER FUNCTION public.ptraj_index_to3dgeom(box2d, timestamp without time zone, timestamp without time zone)
  OWNER TO postgres;


select st_asewkt(ptraj_index_to3dgeom(rect, start_time, end_time)) from mpseq_2491759_traj where mpid=9226 and segid=1;  

select st_astext(ptraj_index_to3dgeom(geometry(rect), start_time, end_time)) from mpseq_2124049_traj where mpid=1 and segid=1;

SELECT geometry(ST_3DMakeBox(ST_MakePoint(-989502.1875, 528439.5625, 10),ST_MakePoint(-987121.375 ,529933.1875, 10))) As abb3d;