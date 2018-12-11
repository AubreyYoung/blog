# mysql 读写比例统计

之前的做法是
com_select : (com_insert + com_update + com_delete)
但这样的统计是不准确的，主要是因为如下的原因：
当query_cache开启的时候，如果一个查询语句在query_cache中命中了，那么server只会增加 qcache_hits的统计，而不会增加com_select.
所以正确的做法应该是
(com_select + qcache_hists) : (com_insert + com_update +com_delete)