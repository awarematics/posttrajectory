
DROP OPERATOR CLASS WTBtree_gist_ops using gist;

DROP OPERATOR < (char(10), char(10));

DROP OPERATOR <= (char(10), char(10));

DROP OPERATOR = (char(10), char(10));

DROP OPERATOR >= (char(10), char(10));

DROP OPERATOR > (char(10), char(10));

DROP FUNCTION wtb_lt(query char(10), wk char(10));

DROP FUNCTION wtb_le(query char(10), wk char(10));

DROP FUNCTION wtb_gt(query char(10), wk char(10));

DROP FUNCTION wtb_ge(query char(10), wk char(10));

DROP FUNCTION wtb_eq(query char(10), wk char(10));

DROP TABLE wtraj;

DROP FUNCTION WTBtree_compress(internal);

DROP FUNCTION WTBtree_consistent(internal, integer, integer, oid, internal);

DROP FUNCTION WTBtree_decompress(internal);

DROP FUNCTION WTBtree_penalty(internal, internal, internal);

DROP FUNCTION WTBtree_picksplit(internal, internal);

DROP FUNCTION WTBtree_same(internal, internal, internal);

DROP FUNCTION WTBtree_union(internal, internal);
