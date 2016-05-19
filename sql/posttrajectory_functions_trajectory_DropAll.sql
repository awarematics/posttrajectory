DROP FUNCTION IF EXISTS TJ_val(tpoint);

DROP FUNCTION IF EXISTS TJ_inst(tpoint);

DROP FUNCTION IF EXISTS TJ_present(tpoint[], TIMESTAMP);

DROP FUNCTION IF EXISTS TJ_trajectory(tpoint[]);

DROP FUNCTION IF EXISTS TJ_length(tpoint[]);

DROP FUNCTION IF EXISTS TJ_deftime(tpoint[]);

DROP FUNCTION IF EXISTS TJ_atInstant(tpoint[], TIMESTAMP);

DROP FUNCTION IF EXISTS TJ_distance(geometry, geometry);

DROP FUNCTION IF EXISTS TJ_distance(tpoint[], tpoint[]);

DROP FUNCTION IF EXISTS TJ_initial(tpoint[]);

DROP FUNCTION IF EXISTS TJ_inside(geometry, geometry);

DROP FUNCTION IF EXISTS TJ_atPeriods(tpoint[], periods);

DROP FUNCTION IF EXISTS TJ_at(tpoint[], geometry);

DROP FUNCTION TJ_Passes(tpoint[], geometry);

DROP FUNCTION _TJ_Passes(geometry, geometry, tpoint[]);