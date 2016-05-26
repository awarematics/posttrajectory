#include "WTBtree_gist.h"

// wkey를 Leaf 노드 키(LKEY)로 변환
WTB_KEY_IN_LKey* range_key_to_node_key(wkey *w)
{
	WTB_KEY_IN_LKey *LKEY;
	char temp[12];
	int i;

	for (i=0; i<sizeof(temp); i++)
	{
		temp[i] = *w[i+1];
	}	

	if (*w[0]=='l') // Leaf Node
	{
		LKEY = (WTB_KEY_IN_LKey *)palloc(sizeof(WTB_KEY_IN_LKey));
		memcpy((char*)LKEY, (char*)temp, sizeof(WTB_KEY_IN_LKey));		
	}
	return LKEY;
}

// wkey를 중간 노드 키(IKEY)로 변환
WTB_KEY_IN_IKey* node_key_to_range_key(wkey *w)
{
	WTB_KEY_IN_IKey *IKEY;	
	char temp[25];
	char lKey[12], rKey[12];
	
	strcpy(temp, w);
	
	if (temp[0]=='i') // Intermediate Node
	{
		int i;
				
		for (i=0; i<12; i++)
		{
			lKey[i] = temp[i+1];
			rKey[i] = temp[i+13];
		}
		
		strcpy(IKEY->lower, lKey);
		strcpy(IKEY->upper, rKey);
	} else 
	{
		for (i=0; i<12; i++)
		{
			lKey[i] = temp[i+1];		
		}
		strcpy(IKEY->lower, lKey);
		strcpy(IKEY->upper, lKey);
	}
	return IKEY;
}


wkey* range_key_to_wkey(WTB_KEY_IN_IKey *ikey)
{
	wkey *w;
	char temp[25];	

	temp[0] = 'i';
	int i;

	for (i=0; i<12; i++)
	{
		temp[i+1] = ikey->lower[i];
		temp[i+13] = ikey->upper[i];
	}		

	w = (wkey *)palloc(sizeof(wkey));
	memcpy((char*)w, (char*)temp, sizeof(wkey));		

	return w;
}

// MBR 값을 GeoHash 값으로 변환
char* WTBtree_util_MBRtoGeohash(WTB_KEY_IN_IKey *IKEY)
{
	int precision = 12;		
	char minGeohash[12], maxGeohash[12];
	bool cmp = true;		
	
	do 
	{
		minGeohash = (char *) geohash_encode(xmin, ymin, precision);
		maxGeohash = (char *) geohash_encode(xmax, ymax, precision);
	
		if (minGeohash = maxGeohash) 
		{
			cmp = true;	
		} else 
		{
			cmp = false;
		}
		
		precision--;
	} while (!cmp);
		
	return minGeohash;
}
