

// 12���� geohash string Ű��
typedef char LEAF_KEY[16];


// ����(range) ���� ���� ������ ����
/*
typedef struct
{		
	char nkey[12];	// Node Key
} WTB_KEY_IN_LKey;
*/

// ���� ������ ����
typedef struct
{
	char lower[16];	// Lower Key
	char upper[16];	// Upper Key
} INTERNAL_KEY;

typedef char khyoo[16];
