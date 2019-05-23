## 1.1 高水位

```plsql
SELECT table_name,
       ROUND((blocks * 8), 2) "高水位空间 k",
       ROUND((num_rows * avg_row_len / 1024), 2) "真实使用空间 k",
       ROUND((blocks * 10 / 100) * 8, 2) "预留空间(pctfree) k",
       ROUND((blocks * 8 - (num_rows * avg_row_len / 1024) -
             blocks * 8 * 10 / 100),
             2) "浪费空间 k"
  FROM dba_tables
 WHERE owner = 'JNAFC'
   and table_name = 'B_JY_REC_HIS'
   and temporary = 'N'
 ORDER BY 5 DESC;
```

## 1.2 rman校验

```plsql
restore validate database; 
```

## 1.3 report_sql

```plsql
set long 99999
set pages 0
set linesize 200
col status format a20
col username format a30
col module format a20
col program format a20
col sql_id format a20
col sql_text format a50
select STATUS,USERNAME,MODULE,PROGRAM,SQL_ID,SQL_TEXT from v$sql_monitor;

//找到对应的sql和sqlid
SET LONG 1000000
SET LONGCHUNKSIZE 1000000
SET LINESIZE 1000
SET PAGESIZE 0
SET TRIM ON
SET TRIMSPOOL ON
SET ECHO OFF
SET FEEDBACK OFF
spool report_sql_monitor_text.txt
SELECT DBMS_SQLTUNE.REPORT_SQL_MONITOR(
  SQL_ID       => '57baju1d4rc8u',                     ---->修改这个地方的sql_id
  TYPE         => 'TEXT',
  REPORT_LEVEL => 'ALL') AS REPORT
FROM dual;
spool off

或者跑一下sqltrpt 
```

## 1.4 分区表

```plsql
select partition_name from DBA_tab_partitions where table_name='WBXT'
```

## 1.5 长事务

```plsql
v$session_longops
```
## 1.6 SQL_ID、SQL文本

```plsql
####SELECT SID FROM V$MYSTAT WHERE ROWNUM =1;
跑SQL
select SID,USERNAME,SQL_ID,SOFAR,TOTALWORK,START_TIME from v$session_longops where sid=xxx;
```

## 1.7 收集统计信息

```plsql
查看统计信息收集情况
select table_name,partition_name,num_rows,last_analyzed from dba_tab_partitions where table_name='B_JY_REC_HIS';

（1）对于单表的统计信息收集
a)适用于Oracle 11g及其以上版本
EXEC DBMS_STATS.GATHER_TABLE_STATS(OWNNAME=>'SCOTT',TABNAME=>'EMP',PARTNAME=>'B_TRADE1810',ESTIMATE_PERCENT=>DBMS_STATS.AUTO_SAMPLE_SIZE,CASCADE=>TRUE,METHOD_OPT=>'FOR ALL COLUMNS SIZE REPEAT');
b）适用于Oracle 9i/10g
EXEC DBMS_STATS.GATHER_TABLE_STATS(OWNNAME=>'SCOTT',TABNAME=>'EMP',PARTNAME=>'B_TRADE1810',ESTIMATE_PERCENT=>30,,CASCADE=>TRUE,METHOD_OPT=>'FOR ALL COLUMNS SIZE REPEAT');
     
（2）对于单个schema的统计信息收集
a)适用于Oracle 11g及其以上版本
EXEC DBMS_STATS.GATHER_SCHEMA_STATS(OWNNAME=>'SCOTT',ESTIMATE_PERCENT=>DBMS_STATS.AUTO_SAMPLE_SIZE,CASCADE=>TRUE,METHOD_OPT=>'FOR ALL COLUMNS SIZE REPEAT');
b）适用于Oracle 9i/10g
EXEC DBMS_STATS.GATHER_SCHEMA_STATS(OWNNAME=>'SCOTT',ESTIMATE_PERCENT=>30,,CASCADE=>TRUE,METHOD_OPT=>'FOR ALL COLUMNS SIZE REPEAT');
注：DEGREE=>4 开启并行
```

## 1.8 Oracle hint

### NO_INDEX

NO_INDEX Hint的格式
- **/*+ NO_INDEX(目标表 目标索引) */**
select /*+ no_index(emp pk_emp) */empno,ename,sal,job from emp where empno=7369 and mgr=7902 and deptno=20;

- **/*+ NO_INDEX(目标表 目标索引1 目标索引2 ······ 目标索引n) */**
select /*+ no_index(emp idx_emp_mgr idx_emp_dept) */empno,ename,sal,job from emp where empno=7369 and mgr=7902 and deptno=20;

- **/*+ NO_INDEX(目标表) */**
select /*+ no_index(emp) */empno,ename,sal,job from emp where empno=7369 and mgr=7902 and deptno=20;

```sql
05:53:05 scott@EE> select empno,ename,sal,job from emp where empno=7369 and mgr=7902 and deptno=20;
EMPNO ENAME             SAL JOB
---------- ---------- ---------- ---------
7369 SMITH             800 CLERK
Elapsed: 00:00:00.01
Execution Plan
----------------------------------------------------------
Plan hash value: 2949544139
--------------------------------------------------------------------------------------
| Id  | Operation                   | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |        |     1 |    29 |     1   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS BY INDEX ROWID| EMP    |     1 |    29 |     1   (0)| 00:00:01 |
|*  2 |   INDEX UNIQUE SCAN         | PK_EMP |     1 |       |     0   (0)| 00:00:01 |
--------------------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
1 - filter("MGR"=7902 AND "DEPTNO"=20)
2 - access("EMPNO"=7369)
Statistics
----------------------------------------------------------
0  recursive calls
0  db block gets
2  consistent gets
0  physical reads
0  redo size
736  bytes sent via SQL*Net to client
523  bytes received via SQL*Net from client
2  SQL*Net roundtrips to/from client
0  sorts (memory)
0  sorts (disk)
1  rows processed
05:53:14 scott@EE> select /*+ no_index(emp) */empno,ename,sal,job from emp where empno=7369 and mgr=7902 and deptno=20;
EMPNO ENAME             SAL JOB
---------- ---------- ---------- ---------
7369 SMITH             800 CLERK
Elapsed: 00:00:00.00
Execution Plan
----------------------------------------------------------
Plan hash value: 3956160932
--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |     1 |    29 |     3   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| EMP  |     1 |    29 |     3   (0)| 00:00:01 |
--------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
1 - filter("EMPNO"=7369 AND "MGR"=7902 AND "DEPTNO"=20)
Statistics
----------------------------------------------------------
1  recursive calls
0  db block gets
8  consistent gets
0  physical reads
0  redo size
736  bytes sent via SQL*Net to client
523  bytes received via SQL*Net from client
2  SQL*Net roundtrips to/from client
0  sorts (memory)
0  sorts (disk)
1  rows processed
05:53:26 scott@EE> select /*+ no_index(emp pk_emp) */empno,ename,sal,job from emp where empno=7369 and mgr=7902 and deptno=20;
EMPNO ENAME             SAL JOB
---------- ---------- ---------- ---------
7369 SMITH             800 CLERK
Elapsed: 00:00:00.00
Execution Plan
----------------------------------------------------------
Plan hash value: 2059184959
-------------------------------------------------------------------------------------------
| Id  | Operation                   | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |             |     1 |    29 |     2   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS BY INDEX ROWID| EMP         |     1 |    29 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_EMP_MGR |     2 |       |     1   (0)| 00:00:01 |
-------------------------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
1 - filter("EMPNO"=7369 AND "DEPTNO"=20)
2 - access("MGR"=7902)
Statistics
----------------------------------------------------------
1  recursive calls
2  db block gets
2  consistent gets
0  physical reads
0  redo size
736  bytes sent via SQL*Net to client
523  bytes received via SQL*Net from client
2  SQL*Net roundtrips to/from client
0  sorts (memory)
0  sorts (disk)
1  rows processed
05:53:35 scott@EE> select /*+ no_index(emp idx_emp_mgr idx_emp_dept) */empno,ename,sal,job from emp where empno=7369 and mgr=7902 and deptno=20;
EMPNO ENAME             SAL JOB
---------- ---------- ---------- ---------
7369 SMITH             800 CLERK
Elapsed: 00:00:00.01
Execution Plan
----------------------------------------------------------
Plan hash value: 2949544139
--------------------------------------------------------------------------------------
| Id  | Operation                   | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |        |     1 |    29 |     1   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS BY INDEX ROWID| EMP    |     1 |    29 |     1   (0)| 00:00:01 |
|*  2 |   INDEX UNIQUE SCAN         | PK_EMP |     1 |       |     0   (0)| 00:00:01 |
--------------------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
1 - filter("MGR"=7902 AND "DEPTNO"=20)
2 - access("EMPNO"=7369)
Statistics
----------------------------------------------------------
1  recursive calls
0  db block gets
2  consistent gets
0  physical reads
0  redo size
736  bytes sent via SQL*Net to client
523  bytes received via SQL*Net from client
2  SQL*Net roundtrips to/from client
0  sorts (memory)
0  sorts (disk)
1  rows processed
```

## 1.9 SQLPLUS配置

```plsql
1. SHOW
03:43:23 sys@EE> show linesize
linesize 80

2. AUTOTRACE开启
SQL> @?/rdbms/admin/utlxplan.sql
Table created.
SQL> grant dba to scott;
Grant succeeded.
SQL> @?/rdbms/admin/utlxplan.sql
Table created.

3. SQLPLUS配置
define _editor=vi
set serveroutput on size 1000000
set trimspool on
set long 5000
set linesize 9999
set pagesize 9999
column plan_plus_exp format a80
column global_name new_value gname
set termout off
define gname=idle
column global_name new_value gname
select lower(user) || '@' || substr( global_name, 1, decode( dot, 0, length(global_name), dot-1) ) global_name
  from (select global_name, instr(global_name,'.') dot from global_name );
set sqlprompt '&gname> '
set termout on
set timing on
set time on
```

## 1.10 开启并行

### 更改表的并行

```plsql
方法一：alter table table_name parallel;
06:26:19 scott@EE> select table_name,degree from dba_tables where table_name='EMP';
TABLE_NAME                     DEGREE
------------------------------ ----------------------------------------
EMP                            1
06:25:45 scott@EE> alter table emp parallel;
Table altered.
06:25:58 scott@EE> select table_name,degree from dba_tables where table_name='EMP';
TABLE_NAME                     DEGREE
------------------------------ ----------------------------------------
EMP                            DEFAULT

方法二：alter table table_name parallel n;
```

### 并行hint

```plsql
a) /* PARALLEL(table,<degree>) */
b) /* NO_PARALLEL(table) */
c) /* PARALLEL_INDEX(table,[index,<degree>]) */
d) /* NO_PARALLEL_INDEX(table,[index]) */
e) /* PQ_DISTRIBUTE(table,out,in) */

06:46:48 scott@EE> select /*+ parallel(t1) */ count(*) from t1;
COUNT(*)
----------
0
Elapsed: 00:00:00.01
Execution Plan
----------------------------------------------------------
Plan hash value: 3110199320
--------------------------------------------------------------------------------------------------------
| Id  | Operation              | Name     | Rows  | Cost (%CPU)| Time     |    TQ  |IN-OUT| PQ Distrib |
--------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT       |          |     1 |     2   (0)| 00:00:01 |        |      |            |
|   1 |  SORT AGGREGATE        |          |     1 |            |          |        |      |            |
|   2 |   PX COORDINATOR       |          |       |            |          |        |      |            |
|   3 |    PX SEND QC (RANDOM) | :TQ10000 |     1 |            |          |  Q1,00 | P->S | QC (RAND)  |
|   4 |     SORT AGGREGATE     |          |     1 |            |          |  Q1,00 | PCWP |            |
|   5 |      PX BLOCK ITERATOR |          |     1 |     2   (0)| 00:00:01 |  Q1,00 | PCWC |            |
|   6 |       TABLE ACCESS FULL| T1       |     1 |     2   (0)| 00:00:01 |  Q1,00 | PCWP |            |
--------------------------------------------------------------------------------------------------------
Note
-----
- dynamic sampling used for this statement (level=2)
Statistics
----------------------------------------------------------
0  recursive calls
0  db block gets
0  consistent gets
0  physical reads
0  redo size
525  bytes sent via SQL*Net to client
523  bytes received via SQL*Net from client
2  SQL*Net roundtrips to/from client
0  sorts (memory)
0  sorts (disk)
1  rows processed
06:46:51 scott@EE> select  count(*) from t1;
COUNT(*)
----------
0
Elapsed: 00:00:00.01
Execution Plan
----------------------------------------------------------
Plan hash value: 3724264953
-------------------------------------------------------------------
| Id  | Operation          | Name | Rows  | Cost (%CPU)| Time     |
-------------------------------------------------------------------
|   0 | SELECT STATEMENT   |      |     1 |     2   (0)| 00:00:01 |
|   1 |  SORT AGGREGATE    |      |     1 |            |          |
|   2 |   TABLE ACCESS FULL| T1   |     1 |     2   (0)| 00:00:01 |
-------------------------------------------------------------------
Note
-----
- dynamic sampling used for this statement (level=2)
Statistics
----------------------------------------------------------
1  recursive calls
0  db block gets
0  consistent gets
0  physical reads
0  redo size
525  bytes sent via SQL*Net to client
523  bytes received via SQL*Net from client
2  SQL*Net roundtrips to/from client
0  sorts (memory)
0  sorts (disk)
1  rows processed
```
### alter session

```plsql
a)alter session force parallel query;
b)alter session force parallel query parallel n;
c)alter session force parallel dml;
d)alter session force parallel dml parallel n;
e)alter session enable parallel dml;
  /*+ hint DML */
```

## 1.11 清空缓存

**alter system flush shared_pool**

The `FLUSH` `SHARED_POOL` clause lets you clear data from the shared pool in the system global area (SGA). The shared pool stores:

- Cached data dictionary information and
- Shared SQL and PL/SQL areas for SQL statements, stored procedures, function, packages, and triggers.

This statement does not clear global application context information, nor does it clear shared SQL and PL/SQL areas for items that are currently being executed. You can use this clause regardless of whether your instance has the database dismounted or mounted, open or closed.

将使library cache和data dictionary cache以前保存的sql执行计划全部清空，但不会清空共享sql区或者共享pl/sql区里面缓存的最近被执行的条目。刷新共享池可以帮助合并碎片（small chunks），释放少数共享池资源，暂时解决shared_pool中的碎片问题。但是，这种做法通常是不被推荐的。原因如下：

- Flush Shared Pool会导致当前未使用的cursor被清除出共享池，如果这些SQL随后需要执行，那么数据库将经历大量的硬解析，系统将会经历严重的CPU争用，数据库将会产生激烈的Latch竞争。
- 如果应用没有使用绑定变量，大量类似SQL不停执行，那么Flush Shared Pool可能只能带来短暂的改善，数据库很快就会回到原来的状态。
- 如果Shared Pool很大，并且系统非常繁忙，刷新Shared Pool可能会导致系统挂起，对于类似系统尽量在系统空闲时进行。

**alter system flush buffer_cache**

The `FLUSH` `BUFFER_CACHE` clause lets you clear all data from the buffer cache in the system global area (SGA), including the `KEEP`, `RECYCLE`, and `DEFAULT` buffer pools.

**alter system flush global context**

The `FLUSH` `GLOBAL` `CONTEXT` clause lets you flush all global application context information from the shared pool in the system global area (SGA). You can use this clause regardless of whether your instance has the database dismounted or mounted, open or closed.

**alter system flush  redo**

Use the `FLUSH` `REDO` clause to flush redo data from a primary database to a standby database and to optionally wait for the flushed redo data to be applied to a physical or logical standby database.

This clause can allow a failover to be performed on the target standby database without data loss, even if the primary database is not in a zero data loss data protection mode, provided that all redo data that has been generated by the primary database can be flushed to the standby database.

The `FLUSH` `REDO` clause must be issued on a mounted, but not open, primary database.

ALTER SYSTEM FLUSH REDO TO target_db_name [[NO] CONFIRM APPLY]

```plsql
//清空shared_pool
alter system flush shared_pool;
//清空buffer cache
alter system flush buffer_cache
//清空SGA
alter system flush global context;
//清空备机redo
ALTER SYSTEM FLUSH REDO TO target_db_name [[NO] CONFIRM APPLY]；
```

## 1.12 重建控制文件

```plsql
create controlfile reuse database dave noresetlogs archivelog
LOGFILE
GROUP 1 '/u01/app/oracle/oradata/dave/redo01.log',
GROUP 2 '/u01/app/oracle/oradata/dave/redo02.log',
GROUP 3 '/u01/app/oracle/oradata/dave/redo03.log'
DATAFILE
'/u01/app/oracle/oradata/dave/sysaux01.dbf',
'/u01/app/oracle/oradata/dave/system01.dbf',
'/u01/app/oracle/oradata/dave/undotbs01.dbf',
'/u01/app/oracle/oradata/dave/users01.dbf'
CHARACTER SET ZHS16GBK;
```

## 1.13 EXPDP/IMPDP

```PLSQL
expdp scott/tiger directory=dump_dir dumpfile=tab.dmp logfile=exp.log;

expdp newccs/hfccs123 directory=dump_backup_dir dumpfile=customer_551.dmp
tables=custaddr,custcontact,customer,custphone logfile=551.log parallel=3;

impdp newccs/hfccs123 directory=dump_backup_dir dumpfile=customer_551.dmp tables=custaddr,custcontact,customer,custphone logfile=551.log parallel=3;

//table_exists_action，system，sysaux表空间存在业务数据可先建表，再使用此参数导入数据
table_exists_action=truncate append
```

