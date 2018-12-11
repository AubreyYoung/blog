alter table system.WBS_SUBPHOTO  storage(next 3m);
[^Notes]: 此语句不能更新lob segment的next_extent,只能更新表segment的next_extent
alter table system.wbs_subphoto  modify lob(zp) (storage (next 2m));
[^Notes]: 此语句能更新lob segment zp 的next_extent，更新为2m
[参考文档](https://docs.oracle.com/en/database/oracle/oracle-database/18/sqlrf/storage_clause.html#GUID-C5A67610-3160-41E9-8D48-03206BD5ED15 )

另外，alter table wbs_subphoto modify lob(zp) (allocate extent (size 1024M));中的 allocate extent不更新dba_segments中的zp 这个lob segment的dba_segments.next_extent，allocate extent能更新dba_segments中的zp 这个lob segment的 dba_segments.bytes