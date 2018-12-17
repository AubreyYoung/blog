> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://blog.csdn.net/newhappy2008/article/details/6708828 版权声明：本文为博主原创文章，未经博主允许不得转载。 https://blog.csdn.net/newhappy2008/article/details/6708828 <link rel="stylesheet" href="https://csdnimg.cn/release/phoenix/template/css/ck_htmledit_views-d7e2a68c7c.css">

     在网上看到 eygle 写的一篇关于分区表和本地索引的文章，感觉总结的挺好，特转了过来。

**     Oracle** 的**分区技术**在某些条件下可以极大的提高**查询**的性能，所以被广泛采用。从产品上说，分区技术是 Oracle 企业版中独立收费的一个**组件**。以下是对于分区及**本地索引**的一个示例。

　　首先根据字典表创建一个测试分区表：

|       SQL> connect eygle/eygle
　　Connected.
　　SQL> CREATE TABLE dbobjs
　　2 (OBJECT_ID NUMBER NOT NULL,
　　3 OBJECT_NAME varchar2(128),
　　4 CREATED DATE NOT NULL
　　5 )
　　6 PARTITION BY RANGE (CREATED)
　　7 (PARTITION dbobjs_06 VALUES LESS THAN (TO_DATE('01/01/2007', 'DD/MM/YYYY')),
　　8 PARTITION dbobjs_07 VALUES LESS THAN (TO_DATE('01/01/2008', 'DD/MM/YYYY')));
　　Table created.
　　SQL> COL segment_name for a20
　　SQL> COL PARTITION_NAME for a20
　　SQL> SELECT segment_name, partition_name, tablespace_name
　　2 FROM dba_segments
　　3 WHERE segment_name = 'DBOBJS';
　　SEGMENT_NAME PARTITION_NAME TABLESPACE_NAME
　　-------------------- -------------------- ------------------------------
　　DBOBJS DBOBJS_06 EYGLE
　　DBOBJS DBOBJS_07 EYGLE |

　　创建一个 Local 索引，注意这里可以将不同分区的索引指定创建到不同的**表空间**：

|       SQL> CREATE INDEX dbobjs_idx ON dbobjs (created) LOCAL
　　2 (PARTITION dbobjs_06 TABLESPACE users,
　　3 PARTITION dbobjs_07 TABLESPACE users
　　4 );
　　Index created. |

　　这个子句可以进一步调整为类似：

|       CREATE INDEX dbobjs_idx ON dbobjs (created) LOCAL
　　(PARTITION dbobjs_06 TABLESPACE users,
　　PARTITION dbobjs_07 TABLESPACE users
　　) TABLESPACE users; |

通过统一的 tablespace 子句为索引指定表空间。

|       SQL> COL segment_name for a20
　　SQL> COL PARTITION_NAME for a20
　　SQL> SELECT segment_name, partition_name, tablespace_name
　　2 FROM dba_segments
　　3 WHERE segment_name = 'DBOBJS_IDX';
　　SEGMENT_NAME PARTITION_NAME TABLESPACE_NAME
　　-------------------- -------------------- ------------------------------
　　DBOBJS_IDX DBOBJS_06 USERS
　　DBOBJS_IDX DBOBJS_07 USERS
　　SQL> insert into dbobjs
　　2 select object_id,object_name,created
　　3 from dba_objects where created
　　6227 rows created.
　　SQL> commit;
　　Commit complete.
　　SQL> select count(*) from dbobjs partition (DBOBJS_06);
　　COUNT(*)
　　----------
　　6154
　　SQL> select count(*) from dbobjs partition (dbobjs_07);
　　COUNT(*)
　　----------
　　73 |

　　我们可以通过查询来对比一下分区表和非分区表的查询性能差异：

|       SQL> set autotrace on
　　SQL> select count(*) from dbobjs where created < to_date('01/01/2008','dd/mm/yyyy');
　　COUNT(*)
　　----------
　　6227
　　Execution Plan
　　----------------------------------------------------------
　　0 SELECT STATEMENT ptimizer=CHOOSE (Cost=1 Card=1 Bytes=9)
　　1 0 SORT (AGGREGATE)
　　2 1 PARTITION RANGE (ALL)
　　3 2 INDEX (RANGE SCAN) OF 'DBOBJS_IDX' (NON-UNIQUE) (Cost=2 Card=8 Bytes=72)
　　Statistics
　　----------------------------------------------------------
　　0 recursive calls
　　0 db block gets
　　25 consistent gets
　　0 physical reads
　　0 redo size
　　380 bytes sent via SQL*Net to client
　　503 bytes received via SQL*Net from client
　　2 SQL*Net roundtrips to/from client
　　0 sorts (memory)
　　0 sorts (disk)
　　1 rows processed
　　SQL> select count(*) from dbobjs where created < to_date('01/01/2007','dd/mm/yyyy');
　　COUNT(*)
　　----------
　　6154
　　Execution Plan
　　----------------------------------------------------------
　　0 SELECT STATEMENT ptimizer=CHOOSE (Cost=1 Card=1 Bytes=9)
　　1 0 SORT (AGGREGATE)
　　2 1 INDEX (RANGE SCAN) OF 'DBOBJS_IDX' (NON-UNIQUE) (Cost=2 Card=4 Bytes=36)
　　Statistics
　　----------------------------------------------------------
　　0 recursive calls
　　0 db block gets
　　24 consistent gets
　　0 physical reads
　　0 redo size
　　380 bytes sent via SQL*Net to client
　　503 bytes received via SQL*Net from client
　　2 SQL*Net roundtrips to/from client
　　0 sorts (memory)
　　0 sorts (disk)
　　1 rows processed
　　SQL> select count(distinct(object_name)) from dbobjs where created < to_date('01/01/2007','dd/mm/yyyy');
　　COUNT(DISTINCT(OBJECT_NAME))
　　----------------------------
　　4753
　　Execution Plan
　　----------------------------------------------------------
　　0 SELECT STATEMENT ptimizer=CHOOSE (Cost=1 Card=1 Bytes=75)
　　1 0 SORT (GROUP BY)
　　2 1 TABLE ACCESS (BY LOCAL INDEX ROWID) OF 'DBOBJS' (Cost=1 Card=4 Bytes=300)
　　3 2 INDEX (RANGE SCAN) OF 'DBOBJS_IDX' (NON-UNIQUE) (Cost=2 Card=1)
　　Statistics
　　----------------------------------------------------------
　　0 recursive calls
　　0 db block gets
　　101 consistent gets
　　0 physical reads
　　0 redo size
　　400 bytes sent via SQL*Net to client
　　503 bytes received via SQL*Net from client
　　2 SQL*Net roundtrips to/from client
　　1 sorts (memory)
　　0 sorts (disk)
　　1 rows processed |

对于非分区表的测试：

|       SQL> CREATE TABLE dbobjs2
　　2 (object_id NUMBER NOT NULL,
　　3 object_name VARCHAR2(128),
　　4 created DATE NOT NULL
　　5 );
　　Table created.
　　SQL> CREATE INDEX dbobjs_idx2 ON dbobjs2 (created);
　　Index created.
　　SQL> insert into dbobjs2
　　2 select object_id,object_name,created
　　3 from dba_objects where created
　　6227 rows created.
　　SQL> commit;
　　Commit complete.
　　SQL> select count(distinct(object_name)) from dbobjs2 where created < to_date('01/01/2007','dd/mm/yyyy');
　　COUNT(DISTINCT(OBJECT_NAME))
　　----------------------------
　　4753
　　Execution Plan
　　----------------------------------------------------------
　　0 SELECT STATEMENT ptimizer=CHOOSE
　　1 0 SORT (GROUP BY)
　　2 1 TABLE ACCESS (BY INDEX ROWID) OF 'DBOBJS2'
　　3 2 INDEX (RANGE SCAN) OF 'DBOBJS_IDX2' (NON-UNIQUE)
　　Statistics
　　----------------------------------------------------------
　　0 recursive calls
　　0 db block gets
　　2670 consistent gets
　　0 physical reads
　　1332 redo size
　　400 bytes sent via SQL*Net to client
　　503 bytes received via SQL*Net from client
　　2 SQL*Net roundtrips to/from client
　　1 sorts (memory)
　　0 sorts (disk)
　　1 rows processed |

　　当增加表分区时，LOCAL 索引被自动维护：

|       SQL> ALTER TABLE dbobjs
　　2 ADD PARTITION dbobjs_08 VALUES LESS THAN (TO_DATE('01/01/2009', 'DD/MM/YYYY'));
　　Table altered.
　　SQL> set autotrace off
　　SQL> COL segment_name for a20
　　SQL> COL PARTITION_NAME for a20
　　SQL> SELECT segment_name, partition_name, tablespace_name
　　2 FROM dba_segments
　　3 WHERE segment_name = 'DBOBJS_IDX';
　　SEGMENT_NAME PARTITION_NAME TABLESPACE_NAME
　　-------------------- -------------------- ------------------------------
　　DBOBJS_IDX DBOBJS_06 USERS
　　DBOBJS_IDX DBOBJS_07 USERS
　　DBOBJS_IDX DBOBJS_08 EYGLE
　　SQL> SELECT segment_name, partition_name, tablespace_name
　　2 FROM dba_segments
　　3 WHERE segment_name = 'DBOBJS';
　　SEGMENT_NAME PARTITION_NAME TABLESPACE_NAME
　　-------------------- -------------------- ------------------------------
　　DBOBJS DBOBJS_06 EYGLE
　　DBOBJS DBOBJS_07 EYGLE
　　DBOBJS DBOBJS_08 EYGLE |

### <a></a>PS：我建了几个 oracle QQ 群，欢迎数据库爱好者加入。

### <a></a>Oracle 专家 QQ1 群：60632593    

### <a></a>Oracle 专家 QQ2 群：60618621     

### <a></a>Oracle 专家 QQ3 群：23145225

-The End-