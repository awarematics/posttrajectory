
DROP OPERATOR CLASS WTBtree_gist_ops using gist;

DROP TYPE khyoo cascade;

DROP TABLE wtraj;

DROP FUNCTION WTBtree_compress(internal);

DROP FUNCTION WTBtree_consistent(internal, bpchar, int2, oid, internal);

DROP FUNCTION WTBtree_decompress(internal);

DROP FUNCTION WTBtree_penalty(internal, internal, internal);

DROP FUNCTION WTBtree_picksplit(internal, internal);

DROP FUNCTION WTBtree_same(internal, internal, internal);

DROP FUNCTION WTBtree_union(internal, internal);
