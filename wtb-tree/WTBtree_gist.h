

// 12���� geohash string Ű��
typedef char LEAF_KEY[12];


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
	char lower[12];	// Lower Key
	char upper[12];	// Upper Key
} INTERNAL_KEY;
