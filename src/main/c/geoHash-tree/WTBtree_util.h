



extern WTB_KEY_IN_LKey *range_key_to_node_key(wkey *w);

extern WTB_KEY_IN_IKey *node_key_to_range_key(wkey *w);

extern wkey* range_key_to_wkey(WTB_KEY_IN_IKey *ikey);

extern char *WTBtree_util_MBRtoGeohash(WTB_KEY_IN_IKey *ikey);
