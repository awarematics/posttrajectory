


#define FLAGS_GET_BBOX(flags) (((flags) & 0x04)>>2)


/**********************************************************************
**  BOX2DF structure. 
**
**  This is a 2-dimensional key for simple cartesian indexes, 
**  with backwards compatible behavior to previous indexes in
**  PostGIS
*/

typedef struct
{
	float xmin, xmax, ymin, ymax;
} BOX2DF;


/******************************************************************
* GBOX structure. 
* We include the flags (information about dimensinality), 
* so we don't have to constantly pass them
* into functions that use the GBOX.
*/
typedef struct
{
	uint8_t flags;
	double xmin;
	double xmax;
	double ymin;
	double ymax;
	double zmin;
	double zmax;
	double mmin;
	double mmax;
} GBOX;


/******************************************************************
* GSERIALIZED
*/
typedef struct
{
	uint32_t size; /* For PgSQL use only, use VAR* macros to manipulate. */
	uint8_t srid[3]; /* 24 bits of SRID */
	uint8_t flags; /* HasZ, HasM, HasBBox, IsGeodetic, IsReadOnly */
	uint8_t data[1]; /* See gserialized.txt */
} GSERIALIZED;


// 12개의 geohash string 키값
typedef char LEAF_KEY[16];


// 범위(range) 값을 단일 값으로 저장
/*
typedef struct
{		
	char nkey[12];	// Node Key
} WTB_KEY_IN_LKey;
*/

// 범위 값으로 저장
typedef struct
{
	char lower[16];	// Lower Key
	char upper[16];	// Upper Key
} INTERNAL_KEY;

typedef char khyoo[16];
