

PG_MODULE_MAGIC;

// 12���� geohash string Ű��
typedef char wkey[25];


// ����(range) ���� ���� ������ ����
typedef struct
{		
	char nkey[12];	// Node Key
} WTB_KEY_IN_LKey;


// ���� ������ ����
typedef struct
{
	char lower[12];	// Lower Key
	char upper[12];	// Upper Key
} WTB_KEY_IN_IKey;
