#include "postgres.h"
#include <string.h>
#include "fmgr.h"
#include "utils/geo_decls.h"
#include "datatype/posttraj.h"

#ifdef PG_MODULE_MAGIC
PG_MODULE_MAGIC;
#endif

PG_FUNCTION_INFO_V1(tj_val);

// RETURN POINT 
Datum
tj_val(PG_FUNCTION_ARGS)
{
	/* Here, the pass-by-reference nature of Point is not hidden. */
	Tpoint *tp = PG_GETARG_TPOINT_TP(0);

	Point *new_point = (Point *)palloc(sizeof(Point));

	new_point->x = tp->p->x;
	new_point->y = tp->p->y;
	PG_RETURN_POINT_P(new_point);
}

PG_FUNCTION_INFO_V1(tj_inst);

// RETURN TIMESTAMP 
Datum
tj_val(PG_FUNCTION_ARGS)
{
	/* Here, the pass-by-reference nature of Point is not hidden. */
	Tpoint *tp = PG_GETARG_TPOINT_TP(0);

	Timestamp *new_timestamp = (Timestamp *)palloc(sizeof(Timestamp));

	new_timestamp = tp->t;
	PG_RETURN_TIMESTAMP(new_timestamp);
}

PG_FUNCTION_INFO_V1(tj_tpoint);

// RETURN TPOINT 
Datum
tj_tpoint(PG_FUNCTION_ARGS)
{
	/* Here, the pass-by-reference nature of Point is not hidden. */
	Point *pt = PG_GETARG_POINT_P(0);
	Timestamp *ts = PG_GETARG_TIMESTAMP(1);

	Point *new_point = (Point *)palloc(sizeof(Point));
	Timestamp *new_timestamp = (Timestamp *)palloc(sizeof(Timestamp));

	Tpoint *new_tpoint = (Tpoint *)palloc(sizeof(Tpoint));

	new_tpoint->p = new_point;
	new_tpoint->p = new_timestamp;
	PG_RETURN_TPOINT_TP(new_tpoint);
}












