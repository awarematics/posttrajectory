﻿


-- TYPE DEFINITION
-- DESCRIPTION : 
-- NAME : tpoint
-- CREATED BY YOO KI HYUN

-- START TYPE tpoint:

DROP TYPE IF EXISTS tpoint;

CREATE TYPE tpoint as(
	pnt	geometry,			-- Point type
	ts	timestamp			-- Timestamp type
);

-- END TYPE tpoint:
------------------------------------------------------------------------------------------



-- TYPE DEFINITION
-- DESCRIPTION : 
-- NAME : trajectory
-- CREATED BY YOO KI HYUN

-- START TYPE trajectory:

CREATE TYPE trajectory as(
	segtableoid	oid,
	moid		integer	
);

-- END TYPE trajectory:
------------------------------------------------------------------------------------------



-- TYPE DEFINITION
-- DESCRIPTION : 
-- NAME : periods
-- CREATED BY YOO KI HYUN

-- START TYPE periods:

DROP TYPE IF EXISTS periods;

CREATE TYPE periods as(
	startTime	timestamp,
	endTime		timestamp
);

-- END TYPE periods:
------------------------------------------------------------------------------------------



-- TYPE DEFINITION
-- DESCRIPTION : 
-- NAME : mbool
-- CREATED BY YOO KI HYUN

-- START TYPE mbool:

DROP TYPE IF EXISTS mbool;

CREATE TYPE mbool as(
	mbool		boolean[]
);

-- END TYPE mbool:
------------------------------------------------------------------------------------------



-- TYPE DEFINITION
-- DESCRIPTION : 
-- NAME : mpoint
-- CREATED BY YOO KI HYUN

-- START TYPE mpoint:

DROP TYPE IF EXISTS mpoint;

CREATE TYPE mpoint as(
	mpoint		tpoint[]
);

-- END TYPE mpoint:
------------------------------------------------------------------------------------------



-- TYPE DEFINITION
-- DESCRIPTION : 
-- NAME : mreal
-- CREATED BY YOO KI HYUN

-- START TYPE mreal:

DROP TYPE IF EXISTS mreal;

CREATE TYPE mreal as(
	mreal		real[]
);

-- END TYPE mreal:
------------------------------------------------------------------------------------------



-- TYPE DEFINITION
-- DESCRIPTION : 
-- NAME : periods
-- CREATED BY YOO KI HYUN

-- START TYPE periods:

DROP TYPE IF EXISTS periods;

CREATE TYPE periods as(
	startTime	timestamp,
	endTime		timestamp
);

-- END TYPE periods:
------------------------------------------------------------------------------------------


-- TYPE DEFINITION
-- DESCRIPTION : 
-- NAME : mdouble
-- CREATED BY Pyoung Woo Yang

CREATE TYPE MDouble as(
	distance	double precision,
	ts		timestamp
);

-- END TYPE periods:
------------------------------------------------------------------------------------------

