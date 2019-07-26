mysqldumpslow /data/slow.log
Reading mysql slow query log from /data/slow.log
Count: 1  Time=0.00s (0s)  Lock=0.00s (0s)  Rows=17.0 (17), root[root]@[192.168.45.1]
  SELECT STATE AS Status, ROUND(SUM(DURATION),N) AS Duration, CONCAT(ROUND(SUM(DURATION)/N.N*N,N), 'S') AS Percentage FROM INFORMATION_SCHEMA.PROFILING WHERE QUERY_ID=N GROUP BY SEQ, STATE ORDER BY SEQ
Count: 1  Time=0.00s (0s)  Lock=0.00s (0s)  Rows=0.0 (0), 0users@0hosts
  bin/mysqld, Version: N.N.N-log (MySQL Community Server (GPL)). started with:
--修改slow_log表存储引擎 
set global slow_query_log=0;
alter table mysql.slow_log engine = myisam;
set global slow_query_log=1;
mysql> select concat("oracle","mysql") from dual;
+--------------------------+
| concat("oracle","mysql") |
+--------------------------+
| oraclemysql              |
+--------------------------+
1 row in set (0.00 sec) 
mysql> select cast(232432432 as  char) from dual;
+--------------------------+
| cast(232432432 as  char) |
+--------------------------+
| 232432432                |
+--------------------------+
1 row in set (0.00 sec)
mysql>
mysql> select now(6);     
+----------------------------+
| now(6)                     |
+----------------------------+
| 2018-03-11 17:10:53.982080 |
+----------------------------+
1 row in set (0.00 sec)
mysql> select now();
+---------------------+
| now()               |
+---------------------+
| 2018-03-11 17:11:45 |
+---------------------+
1 row in set (0.00 sec)
mysql>  select now(6);
+----------------------------+
| now(6)                     |
+----------------------------+
| 2018-03-11 17:15:00.301739 |
+----------------------------+
1 row in set (0.00 sec)
mysql>  select current_timestamp(6);
+----------------------------+
| current_timestamp(6)       |
+----------------------------+
| 2018-03-11 17:15:12.392042 |
+----------------------------+
1 row in set (0.00 sec)
mysql> select now(),sysdate(),sleep(2),sysdate() from dual;
+---------------------+---------------------+----------+---------------------+
| now()               | sysdate()           | sleep(2) | sysdate()           |
+---------------------+---------------------+----------+---------------------+
| 2018-03-11 17:16:12 | 2018-03-11 17:16:12 |        0 | 2018-03-11 17:16:14 |
+---------------------+---------------------+----------+---------------------+
1 row in set (2.00 sec)
mysql> select sysdate(6) from dual;
+----------------------------+
| sysdate(6)                 |
+----------------------------+
| 2018-03-11 17:17:04.553088 |
+----------------------------+
1 row in set (0.00 sec)
mysql> select now(6),sysdate(6) from dual;
+----------------------------+----------------------------+
| now(6)                     | sysdate(6)                 |
+----------------------------+----------------------------+
| 2018-03-11 17:18:08.181805 | 2018-03-11 17:18:08.181906 |
+----------------------------+----------------------------+
1 row in set (0.00 sec)
mysql> select date_add(now(),interval -7 day);
+---------------------------------+
| date_add(now(),interval -7 day) |
+---------------------------------+
| 2018-03-04 17:18:58             |
+---------------------------------+
1 row in set (0.00 sec)
CREATE TABLE t1 ( ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, dt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP );
mysql> select @@gtid_mode;
+-------------+
| @@gtid_mode |
+-------------+
| ON          |
+-------------+
1 row in set (0.00 sec)
select emp_no,first_name,last_name from employees where emp_no = any(select emp_no from dept_manager);
select emp_no,first_name,last_name from employees where emp_no = all(select emp_no from dept_manager);
select emp_no,first_name,last_name from employees where emp_no in (select emp_no from dept_manager);
explain select emp_no,first_name,last_name from employees where emp_no in (select emp_no from dept_manager);\G
explain extended select emp_no,first_name,last_name from employees where emp_no in (select emp_no from dept_manager)\G
mysql> insert into a values (2);
Query OK, 1 row affected (0.00 sec)
mysql> select * from a;
+------+
| a    |
+------+
|    1 |
|    2 |
+------+
2 rows in set (0.00 sec)
mysql> insert into a values (3);
Query OK, 1 row affected (0.10 sec)
mysql> insert into a values (3),(4),(5);
Query OK, 3 rows affected (0.01 sec)
Records: 3  Duplicates: 0  Warnings: 0
mysql> insert into a select 8;
Query OK, 1 row affected (0.00 sec)
Records: 1  Duplicates: 0  Warnings: 0

![](D:\github\blog\mysql\pictures\Image [3].png)

```
mysql> set @rn:=0;
Query OK, 0 rows affected (0.00 sec)
mysql> select @rn;
+------+
| @rn  |
+------+
|    0 |
+------+
1 row in set (0.00 sec)
mysql> select @rn:=@rn+1,e.* from employees e limit 10;
+------------+--------+------------+------------+-----------+--------+------------+
| @rn:=@rn+1 | emp_no | birth_date | first_name | last_name | gender | hire_date  |
+------------+--------+------------+------------+-----------+--------+------------+
|          1 |  10001 | 1953-09-02 | Georgi     | Facello   | M      | 1986-06-26 |
|          2 |  10002 | 1964-06-02 | Bezalel    | Simmel    | F      | 1985-11-21 |
|          3 |  10003 | 1959-12-03 | Parto      | Bamford   | M      | 1986-08-28 |
|          4 |  10004 | 1954-05-01 | Chirstian  | Koblick   | M      | 1986-12-01 |
|          5 |  10005 | 1955-01-21 | Kyoichi    | Maliniak  | M      | 1989-09-12 |
|          6 |  10006 | 1953-04-20 | Anneke     | Preusig   | F      | 1989-06-02 |
|          7 |  10007 | 1957-05-23 | Tzvetan    | Zielinski | F      | 1989-02-10 |
|          8 |  10008 | 1958-02-19 | Saniya     | Kalloufi  | M      | 1994-09-15 |
|          9 |  10009 | 1952-04-19 | Sumant     | Peac      | F      | 1985-02-18 |
|         10 |  10010 | 1963-06-01 | Duangkaew  | Piveteau  | F      | 1989-08-24 |
+------------+--------+------------+------------+-----------+--------+------------+
10 rows in set (0.00 sec)
mysql> select @rn:=@rn+1,e.* from employees e,(select @rn:=0) t limit 10,5;
+------------+--------+------------+------------+-----------+--------+------------+
| @rn:=@rn+1 | emp_no | birth_date | first_name | last_name | gender | hire_date  |
+------------+--------+------------+------------+-----------+--------+------------+
|          1 |  10011 | 1953-11-07 | Mary       | Sluis     | F      | 1990-01-22 |
|          2 |  10012 | 1960-10-04 | Patricio   | Bridgland | M      | 1992-12-18 |
|          3 |  10013 | 1963-06-07 | Eberhardt  | Terkki    | M      | 1985-10-20 |
|          4 |  10014 | 1956-02-12 | Berni      | Genin     | M      | 1987-03-11 |
|          5 |  10015 | 1959-08-19 | Guoxiang   | Nooteboom | M      | 1987-07-02 |
+------------+--------+------------+------------+-----------+--------+------------+
5 rows in set (0.00 sec)
mysql> select (select count(1) from employees b where b.emp_no <= a.emp_no) as rn,  emp_no,CONCAT(last_name," ",first_name) name,gender,hire_date from employees a limit 10,5;
+------+--------+--------------------+--------+------------+
| rn   | emp_no | name               | gender | hire_date  |
+------+--------+--------------------+--------+------------+
|   11 |  10011 | Sluis Mary         | F      | 1990-01-22 |
|   12 |  10012 | Bridgland Patricio | M      | 1992-12-18 |
|   13 |  10013 | Terkki Eberhardt   | M      | 1985-10-20 |
|   14 |  10014 | Genin Berni        | M      | 1987-03-11 |
|   15 |  10015 | Nooteboom Guoxiang | M      | 1987-07-02 |
+------+--------+--------------------+--------+------------+
5 rows in set (0.27 sec)
mysql>
###EXPLAIN/DESC JSON
mysql> desc FORMAT = JSON select * from employees where emp_no = 23344\G
********* 1. row *********
EXPLAIN: {
  "query_block": {
    "select_id": 1,
    "cost_info": {
      "query_cost": "1.00"
    },
    "table": {
      "table_name": "employees",
      "access_type": "const",
      "possible_keys": [
        "PRIMARY"
      ],
      "key": "PRIMARY",
      "used_key_parts": [
        "emp_no"
      ],
      "key_length": "4",
      "ref": [
        "const"
      ],
      "rows_examined_per_scan": 1,
      "rows_produced_per_join": 1,
      "filtered": "100.00",
      "cost_info": {
        "read_cost": "0.00",
        "eval_cost": "0.20",
        "prefix_cost": "0.00",
        "data_read_per_join": "136"
      },
      "used_columns": [
        "emp_no",
        "birth_date",
        "first_name",
        "last_name",
        "gender",
        "hire_date"
      ]
    }
  }
}
1 row in set, 1 warning (0.00 sec)
mysql> explain FORMAT = JSON select * from employees where emp_no = 23344;
+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| EXPLAIN                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| {
  "query_block": {
    "select_id": 1,
    "cost_info": {
      "query_cost": "1.00"
    },
    "table": {
      "table_name": "employees",
      "access_type": "const",
      "possible_keys": [
        "PRIMARY"
      ],
      "key": "PRIMARY",
      "used_key_parts": [
        "emp_no"
      ],
      "key_length": "4",
      "ref": [
        "const"
      ],
      "rows_examined_per_scan": 1,
      "rows_produced_per_join": 1,
      "filtered": "100.00",
      "cost_info": {
        "read_cost": "0.00",
        "eval_cost": "0.20",
        "prefix_cost": "0.00",
        "data_read_per_join": "136"
      },
      "used_columns": [
        "emp_no",
        "birth_date",
        "first_name",
        "last_name",
        "gender",
        "hire_date"
      ]
    }
  }
} |
+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
1 row in set, 1 warning (0.00 sec)
use sys
select * from  x$schema_index_statistics limit 1 \G
USE information_schema;
SELECT
     t.TABLE_SCHEMA,t.TABLE_NAME,INDEX_NAME, CARDINALITY, TABLE_ROWS,
     CARDINALITY/TABLE_ROWS AS SELETIVITY
FROM
    TABLES t,
    STATISTICS s
WHERE
    t.table_schema = s.table_schema
        AND t.table_name = s.table_name
        AND t.table_schema = 'dbt3';
SELECT
     t.TABLE_SCHEMA,t.TABLE_NAME,INDEX_NAME, CARDINALITY, TABLE_ROWS, CARDINALITY/TABLE_ROWS AS SELETIVITY
FROM
    TABLES t,
    (SELECT table_schema,table_name,index_name,CARDINALITY,MAX(seq_in_index) FROM STATISTICS GROUP BY table_schema,table_name,index_name) s
WHERE
    t.table_schema = s.table_schema
        AND t.table_name = s.table_name
        AND t.table_schema = 'dbt3'
ORDER BY SELETIVITY;
SELECT
     t.TABLE_SCHEMA,t.TABLE_NAME,INDEX_NAME, CARDINALITY, TABLE_ROWS, CARDINALITY/TABLE_ROWS AS SELETIVITY
FROM
    TABLES t,
    (
        SELECT     
            table_schema,
            table_name,
            index_name,
            cardinality
        FROM STATISTICS
        WHERE (table_schema,table_name,index_name,seq_in_index) IN (
        SELECT
            table_schema,
            table_name,
            index_name,
            MAX(seq_in_index)
        FROM
            STATISTICS
        GROUP BY table_schema , table_name , index_name )
    ) s
WHERE
    t.table_schema = s.table_schema
        AND t.table_name = s.table_name
        AND t.table_schema = 'employees'
ORDER BY SELETIVITY;
ANALYZE TABLE employees;
mysql> select * from employees force index(idx_birth_date) where emp_no=10002;
+--------+------------+------------+-----------+--------+------------+
| emp_no | birth_date | first_name | last_name | gender | hire_date  |
+--------+------------+------------+-----------+--------+------------+
|  10002 | 1964-06-02 | Bezalel    | Simmel    | F      | 1985-11-21 |
+--------+------------+------------+-----------+--------+------------+
1 row in set (0.11 sec)
mysql> desc format=json select * from employees force index(idx_birth_date) where emp_no=10002;
+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| EXPLAIN                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| {
  "query_block": {
    "select_id": 1,
    "cost_info": {
      "query_cost": "358394.20"
    },
    "table": {
      "table_name": "employees",
      "access_type": "ALL",
      "rows_examined_per_scan": 298661,
      "rows_produced_per_join": 0,
      "filtered": "0.00",
      "cost_info": {
        "read_cost": "358394.00",
        "eval_cost": "0.20",
        "prefix_cost": "358394.20",
        "data_read_per_join": "135"
      },
      "used_columns": [
        "emp_no",
        "birth_date",
        "first_name",
        "last_name",
        "gender",
        "hire_date"
      ],
      "attached_condition": "(`employees`.`employees`.`emp_no` = 10002)"
    }
  }
} |
+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
1 row in set, 1 warning (0.00 sec)
creata table a(1 int) data directory='/test';
drop table sbtest6,sbtest7,sbtest8,sbtest9,sbtest10;
###soft link
###general tablespace
create tablespace ts1 add datafile '/test/test01.ibd' file block size=8192;
creata table a(1 int) tablespace=ts1;
###只创建表结构
create table test like employees;
mysql> select database();
+------------+
| database() |
+------------+
| sampdb     |
+------------+
1 row in set (0.00 sec)
mysql> set global innodb_cmp_per_index_enabled = 1;
Query OK, 0 rows affected (0.00 sec)
mysql> show variables like 'innodb_%index%';
+----------------------------------+-------+
| Variable_name                    | Value |
+----------------------------------+-------+
| innodb_adaptive_hash_index       | ON    |
| innodb_adaptive_hash_index_parts | 8     |
| innodb_cmp_per_index_enabled     | ON    |
+----------------------------------+-------+
3 rows in set (0.00 sec)
mysql> create table t3 (a int) compression="zlib";
Query OK, 0 rows affected (5.48 sec)
(root@localhost) [mytest]> show variables like '%join%buffer%';
+------------------+-----------+
| Variable_name    | Value     |
+------------------+-----------+
| join_buffer_size | 134217728 |
+------------------+-----------+
1 row in set (0.00 sec)
(root@localhost) [mytest]> select 134217728/1024/1024;
+---------------------+
| 134217728/1024/1024 |
+---------------------+
|        128.00000000 |
+---------------------+
1 row in set (0.00 sec)
(root@localhost) [employees]> set global optimizer_switch='mrr_cost_based=off';
(root@localhost) [employees]> show variables like 'optimizer_switch';
+------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Variable_name    | Value                                                                                                                                                                                                                                                                                                                                                                                                            |
+------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| optimizer_switch | index_merge=on,index_merge_union=on,index_merge_sort_union=on,index_merge_intersection=on,engine_condition_pushdown=on,index_condition_pushdown=on,mrr=on,mrr_cost_based=on,block_nested_loop=on,batched_key_access=off,materialization=on,semijoin=on,loosescan=on,firstmatch=on,duplicateweedout=on,subquery_materialization_cost_based=on,use_index_extensions=on,condition_fanout_filter=on,derived_merge=on |
+------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)
(root@localhost) [employees]> desc salaries;
+-----------+---------+------+-----+---------+-------+
| Field     | Type    | Null | Key | Default | Extra |
+-----------+---------+------+-----+---------+-------+
| emp_no    | int(11) | NO   | PRI | NULL    |       |
| salary    | int(11) | NO   |     | NULL    |       |
| from_date | date    | NO   | PRI | NULL    |       |
| to_date   | date    | NO   |     | NULL    |       |
+-----------+---------+------+-----+---------+-------+
4 rows in set (0.00 sec)
(root@localhost) [employees]> explain select /*+ MRR(salaries) */ * from salaries where salary>1000 and salary <40000\G
********* 1. row *********
           id: 1
  select_type: SIMPLE
        table: salaries
   partitions: NULL
         type: ALL
possible_keys: NULL
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 2648578
     filtered: 11.11
        Extra: Using where
1 row in set, 1 warning (0.00 sec)
(root@localhost) [employees]> alter table salaries add index idx_salary(salary);
Query OK, 0 rows affected (11.08 sec)
Records: 0  Duplicates: 0  Warnings: 0
(root@localhost) [employees]> desc salaries;                    
+-----------+---------+------+-----+---------+-------+
| Field     | Type    | Null | Key | Default | Extra |
+-----------+---------+------+-----+---------+-------+
| emp_no    | int(11) | NO   | PRI | NULL    |       |
| salary    | int(11) | NO   | MUL | NULL    |       |
| from_date | date    | NO   | PRI | NULL    |       |
| to_date   | date    | NO   |     | NULL    |       |
+-----------+---------+------+-----+---------+-------+
4 rows in set (0.00 sec)
(root@localhost) [employees]> explain select /*+ MRR(salaries) */ * from salaries where salary>1000 and salary <40000\G
********* 1. row *********
           id: 1
  select_type: SIMPLE
        table: salaries
   partitions: NULL
         type: range
possible_keys: idx_salary
          key: idx_salary
      key_len: 4
          ref: NULL
         rows: 23606
     filtered: 100.00
        Extra: Using index condition; Using MRR
1 row in set, 1 warning (0.00 sec)
(root@localhost) [employees]>
(root@localhost) [employees]> show engine innodb mutex;
+--------+-----------------------------+------------+
| Type   | Name                        | Status     |
+--------+-----------------------------+------------+
| InnoDB | rwlock: dict0dict.cc:1183   | waits=3    |
| InnoDB | rwlock: log0log.cc:838      | waits=17   |
| InnoDB | sum rwlock: buf0buf.cc:1460 | waits=1386 |
+--------+-----------------------------+------------+
3 rows in set (0.14 sec)
set  tx_isolation='read-uncommitted';
select @@tx_isolation
select @@transaction_isolation;
show processlist;
(root@localhost) [sys]> select @@tx_isolation;
+----------------+
| @@tx_isolation |
+----------------+
| READ-COMMITTED |
+----------------+
1 row in set, 1 warning (0.00 sec)
一个事务所作的修改对其他事务是不可见的，好似是串行执行的
(root@localhost) [mytest]> show variables like '%autoinc%';
+--------------------------+-------+
| Variable_name            | Value |
+--------------------------+-------+
| innodb_autoinc_lock_mode | 1     |
+--------------------------+-------+
1 row in set (0.00 sec)
(root@localhost) [(none)]> show variables like '%max_connections%';
+-----------------+-------+
| Variable_name   | Value |
+-----------------+-------+
| max_connections | 800   |
+-----------------+-------+
1 row in set (0.00 sec)
(root@localhost) [(none)]> show status like '%connect%';
+-----------------------------------------------+---------------------+
| Variable_name                                 | Value               |
+-----------------------------------------------+---------------------+
| Aborted_connects                              | 0                   |
| Connection_errors_accept                      | 0                   |
| Connection_errors_internal                    | 0                   |
| Connection_errors_max_connections             | 0                   |
| Connection_errors_peer_address                | 0                   |
| Connection_errors_select                      | 0                   |
| Connection_errors_tcpwrap                     | 0                   |
| Connections                                   | 3                   |
| Locked_connects                               | 0                   |
| Max_used_connections                          | 1                   |
| Max_used_connections_time                     | 2018-03-27 13:32:03 |
| Performance_schema_session_connect_attrs_lost | 0                   |
| Ssl_client_connects                           | 0                   |
| Ssl_connect_renegotiates                      | 0                   |
| Ssl_finished_connects                         | 0                   |
| Threads_connected                             | 1                   |
+-----------------------------------------------+---------------------+
16 rows in set (0.00 sec)
(root@localhost) [(none)]> show variables like '%double%';
+--------------------+-------+
| Variable_name      | Value |
+--------------------+-------+
| innodb_doublewrite | ON    |
+--------------------+-------+
1 row in set (0.00 sec)
(root@localhost) [(none)]> show status like  "%InnoDB_dblwr%";
+----------------------------+-------+
| Variable_name              | Value |
+----------------------------+-------+
| Innodb_dblwr_pages_written | 2     |
| Innodb_dblwr_writes        | 1     |
+----------------------------+-------+
2 rows in set (0.00 sec)
(root@localhost) [(none)]> show master status;
+------------+----------+--------------+------------------+--------------------------------------------+
| File       | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set                          |
+------------+----------+--------------+------------------+--------------------------------------------+
| bin.000044 |      194 |              |                  | 1cb93d00-21ba-11e8-937b-000c29b8e623:1-395 |
+------------+----------+--------------+------------------+--------------------------------------------+
1 row in set (0.00 sec)
(root@localhost) [(none)]> show binlog events in 'bin.000044';
+------------+-----+----------------+-----------+-------------+--------------------------------------------+
| Log_name   | Pos | Event_type     | Server_id | End_log_pos | Info                                       |
+------------+-----+----------------+-----------+-------------+--------------------------------------------+
| bin.000044 |   4 | Format_desc    |        11 |         123 | Server ver: 5.7.21-log, Binlog ver: 4      |
| bin.000044 | 123 | Previous_gtids |        11 |         194 | 1cb93d00-21ba-11e8-937b-000c29b8e623:1-395 |
+------------+-----+----------------+-----------+-------------+--------------------------------------------+
2 rows in set (0.00 sec)
(root@localhost) [(none)]> flush binary logs;
Query OK, 0 rows affected (0.35 sec)
mysql> purge binary logs before sysdate();
Query OK, 0 rows affected, 1 warning (0.00 sec)
mysql>  purge binary logs before "2018-04-04 13:58:14";
Query OK, 0 rows affected, 1 warning (0.00 sec)
(root@localhost) [(none)]> show master status;
+------------+----------+--------------+------------------+--------------------------------------------+
| File       | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set                          |
+------------+----------+--------------+------------------+--------------------------------------------+
| bin.000045 |      194 |              |                  | 1cb93d00-21ba-11e8-937b-000c29b8e623:1-395 |
+------------+----------+--------------+------------------+--------------------------------------------+
1 row in set (0.00 sec)
+------------+-----+----------------+-----------+-------------+--------------------------------------------+
| Log_name   | Pos | Event_type     | Server_id | End_log_pos | Info                                       |
+------------+-----+----------------+-----------+-------------+--------------------------------------------+
| bin.000044 |   4 | Format_desc    |        11 |         123 | Server ver: 5.7.21-log, Binlog ver: 4      |
| bin.000044 | 123 | Previous_gtids |        11 |         194 | 1cb93d00-21ba-11e8-937b-000c29b8e623:1-395 |
| bin.000044 | 194 | Rotate         |        11 |         235 | bin.000045;pos=4                           |
+------------+-----+----------------+-----------+-------------+--------------------------------------------+
3 rows in set (0.00 sec)
(root@localhost) [(none)]> SHOW GLOBAL STATUS like 'binlog%';
+----------------------------+-------+
| Variable_name              | Value |
+----------------------------+-------+
| Binlog_cache_disk_use      | 0     |
| Binlog_cache_use           | 0     |
| Binlog_stmt_cache_disk_use | 0     |
| Binlog_stmt_cache_use      | 0     |
+----------------------------+-------+
4 rows in set (0.00 sec)


(root@localhost) [information_schema]> show variables like 'max_heap%';
+---------------------+----------+
| Variable_name       | Value    |
+---------------------+----------+
| max_heap_table_size | 16777216 |
+---------------------+----------+
1 row in set (0.00 sec)
(root@localhost) [information_schema]> show table status like 'TABLES%'\G
********* 1. row *********
           Name: TABLES
         Engine: MEMORY
        Version: 10
     Row_format: Fixed
           Rows: NULL
Avg_row_length: 9441
    Data_length: 0
Max_data_length: 16757775
   Index_length: 0
      Data_free: 0
Auto_increment: NULL
    Create_time: 2018-03-29 10:44:18
    Update_time: NULL
     Check_time: NULL
      Collation: utf8_general_ci
       Checksum: NULL
Create_options: max_rows=1777
        Comment:
(root@localhost) [mytest]> show engines;
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
| Engine             | Support | Comment                                                        | Transactions | XA   | Savepoints |
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
| MEMORY             | YES     | Hash based, stored in memory, useful for temporary tables      | NO           | NO   | NO         |
| CSV                | YES     | CSV storage engine                                             | NO           | NO   | NO         |
| MRG_MYISAM         | YES     | Collection of identical MyISAM tables                          | NO           | NO   | NO         |
| BLACKHOLE          | YES     | /dev/null storage engine (anything you write to it disappears) | NO           | NO   | NO         |
| InnoDB             | DEFAULT | Supports transactions, row-level locking, and foreign keys     | YES          | YES  | YES        |
| PERFORMANCE_SCHEMA | YES     | Performance Schema                                             | NO           | NO   | NO         |
| ARCHIVE            | YES     | Archive storage engine                                         | NO           | NO   | NO         |
| MyISAM             | YES     | MyISAM storage engine                                          | NO           | NO   | NO         |
| FEDERATED          | NO      | Federated MySQL storage engine                                 | NULL         | NULL | NULL       |
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
9 rows in set (0.00 sec)
mysql> create table remote_fed(id int auto_increment not null,c1 varchar(10) not null default '',c2 char(10) not null default '',primary key(id))engine=innodb;
Query OK, 0 rows affected (0.59 sec)
mysql> show create table remote_fed;
+------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Table      | Create Table                                                                                                                                                                                                  |
+------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| remote_fed | CREATE TABLE remote_fed (
  id int(11) NOT NULL AUTO_INCREMENT,
  c1 varchar(10) NOT NULL DEFAULT '',
  c2 char(10) NOT NULL DEFAULT '',
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 |
+------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.13 sec)
mysql> insert into remote_fed(c1,c2) values ('aaa','bbb'),('ccc','ddd');
Query OK, 2 rows affected (0.61 sec)
Records: 2  Duplicates: 0  Warnings: 0
mysql> commit;
Query OK, 0 rows affected (0.00 sec)
mysql> select * from remote_fed;
+----+-----+-----+
| id | c1  | c2  |
+----+-----+-----+
|  1 | aaa | bbb |
|  2 | ccc | ddd |
+----+-----+-----+
2 rows in set (0.00 sec)
mysql> grant select,update,insert,delete on mytest.remote_fed to fed_link@'192.168.45.%' identified by 'oracle';
Query OK, 0 rows affected, 1 warning (0.34 sec)
(root@localhost) [mytest]> CREATE TABLE remote_fed (
    ->   `id` int(11) NOT NULL AUTO_INCREMENT,
    ->   `c1` varchar(10) NOT NULL DEFAULT '',
    ->   `c2` char(10) NOT NULL DEFAULT '',
    ->   PRIMARY KEY (`id`)
    -> ) ENGINE=^C
(root@localhost) [mytest]> CREATE TABLE local_fed (
    ->   `id` int(11) NOT NULL AUTO_INCREMENT,
    ->   `c1` varchar(10) NOT NULL DEFAULT '',
    ->   `c2` char(10) NOT NULL DEFAULT '',
    ->   PRIMARY KEY (`id`)
    -> ) ENGINE=federated connection='<mysql://fed_link:oracle@192.168.45.84:3306/mytest/remote_fed>';
Query OK, 0 rows affected (5.37 sec)
(root@localhost) [mytest]> show create table local_fed;
+-----------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Table     | Create Table                                                                                                                                                                                                                                                                              |
+-----------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| local_fed | CREATE TABLE local_fed (
  id int(11) NOT NULL AUTO_INCREMENT,
  c1 varchar(10) NOT NULL DEFAULT '',
  c2 char(10) NOT NULL DEFAULT '',
  PRIMARY KEY (id)
) ENGINE=FEDERATED DEFAULT CHARSET=utf8mb4 CONNECTION='mysql://fed_link:oracle@192.168.45.84:3306/mytest/remote_fed' |
+-----------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)
(root@localhost) [mytest]> show variables like '%autocommit%';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| autocommit    | ON    |
+---------------+-------+
1 row in set (0.00 sec)
(root@localhost) [mytest]> show variables like '%iso%';      
+-----------------------+----------------+
| Variable_name         | Value          |
+-----------------------+----------------+
| transaction_isolation | READ-COMMITTED |
| tx_isolation          | READ-COMMITTED |
+-----------------------+----------------+
2 rows in set (0.00 sec)
[root@centos mytest]# mysqld --help --verbose|grep my.cnf
/etc/my.cnf /etc/mysql/my.cnf /usr/local/mysql/etc/my.cnf ~/.my.cnf
                      my.cnf, $MYSQL_TCP_PORT, /etc/services, built-in default
```

![](D:\github\blog\mysql\pictures\Image [4].png)

(root@localhost) [mytest]> show variables where variable_name='wait_timeout' or variable_name='interactive_timeout';

+---------------------+-------+

| Variable_name       | Value |

+---------------------+-------+

| interactive_timeout | 1800  |

| wait_timeout        | 1800  |

+---------------------+-------+

2 rows in set (0.00 sec)





(root@localhost) [mytest]> set global wait_timeout=3600;set global interactive_timeout=3600;

Query OK, 0 rows affected (0.00 sec)



Query OK, 0 rows affected (0.00 sec)



(root@localhost) [mytest]> show variables where variable_name='wait_timeout' or variable_name='interactive_timeout';  ###这两个参数需同时修改，否则mysql选择其中大的参数，这两个参数只对新建链接有效

+---------------------+-------+

| Variable_name       | Value |

+---------------------+-------+

| interactive_timeout | 1800  |

| wait_timeout        | 1800  |

+---------------------+-------+

2 rows in set (0.00 sec)







[root@centos mytest]# mysql

Welcome to the MySQL monitor.  Commands end with ; or \g.

Your MySQL connection id is 3

Server version: 5.7.21-log MySQL Community Server (GPL)



Copyright (c) 2000, 2018, Oracle and/or its affiliates. All rights reserved.



Oracle is a registered trademark of Oracle Corporation and/or its

affiliates. Other names may be trademarks of their respective

owners.



Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.



(root@localhost) [(none)]> show variables where variable_name='wait_timeout' or variable_name='interactive_timeout';

+---------------------+-------+

| Variable_name       | Value |

+---------------------+-------+

| interactive_timeout | 3600  |

| wait_timeout        | 3600  |

+---------------------+-------+

2 rows in set (0.00 sec)



(root@localhost) [mytest]> show variables like 'sort_buffer_size';

ERROR 2006 (HY000): MySQL server has gone away

No connection. Trying to reconnect...

Connection id:    4

Current database: mytest



+------------------+----------+

| Variable_name    | Value    |

+------------------+----------+

| sort_buffer_size | 33554432 |

+------------------+----------+

1 row in set (0.01 sec)



(root@localhost) [mytest]> show variables like 'join_buffer_size';    

+------------------+-----------+

| Variable_name    | Value     |

+------------------+-----------+

| join_buffer_size | 134217728 |

+------------------+-----------+

1 row in set (0.00 sec)



(root@localhost) [mytest]> show variables like 'read_buffer_size';    

+------------------+----------+

| Variable_name    | Value    |

+------------------+----------+

| read_buffer_size | 16777216 |

+------------------+----------+

1 row in set (0.00 sec)



(root@localhost) [mytest]> show variables like 'read_rnd_buffer_size';

+----------------------+----------+

| Variable_name        | Value    |

+----------------------+----------+

| read_rnd_buffer_size | 33554432 |

+----------------------+----------+

1 row in set (0.00 sec)

![](D:\github\blog\mysql\pictures\Image [5].png)

(root@localhost) [mytest]> show variables like 'innodb_buffer_pool_size';          

+-------------------------+------------+

| Variable_name           | Value      |

+-------------------------+------------+

| innodb_buffer_pool_size | 6442450944 |

+-------------------------+------------+

1 row in set (0.00 sec)

(root@localhost) [mytest]> select sum(index_length) from information_schema.tables where engine='myisam';

+-------------------+

| sum(index_length) |

+-------------------+

|             44032 |

+-------------------+

1 row in set (0.73 sec)



(root@localhost) [mytest]> show variables like 'key_buffer_size';

+-----------------+---------+

| Variable_name   | Value   |

+-----------------+---------+

| key_buffer_size | 8388608 |

+-----------------+---------+

1 row in set (0.00 sec)



(root@localhost) [mytest]> show variables like 'innodb_log_file_size';

+----------------------+------------+

| Variable_name        | Value      |

+----------------------+------------+

| innodb_log_file_size | 8589934592 |

+----------------------+------------+

1 row in set (0.00 sec)



(root@localhost) [mytest]> show variables like 'innodb_log_files_in_group';

+---------------------------+-------+

| Variable_name             | Value |

+---------------------------+-------+

| innodb_log_files_in_group | 2     |

+---------------------------+-------+

1 row in set (0.00 sec)

(root@localhost) [mytest]> show variables like 'innodb_log_buffer_size';

+------------------------+----------+

| Variable_name          | Value    |

+------------------------+----------+

| innodb_log_buffer_size | 33554432 |

+------------------------+----------+

1 row in set (0.00 sec)



(root@localhost) [mytest]> show variables like 'innodb_flush_log_at_trx_commit';

+--------------------------------+-------+

| Variable_name                  | Value |

+--------------------------------+-------+

| innodb_flush_log_at_trx_commit | 1     |

+--------------------------------+-------+

1 row in set (0.00 sec)



(root@localhost) [mytest]> show variables like 'innodb_flush_method';

+---------------------+----------+

| Variable_name       | Value    |

+---------------------+----------+

| innodb_flush_method | O_DIRECT |

+---------------------+----------+

1 row in set (0.00 sec)



(root@localhost) [mytest]> show variables like 'innodb_file_per_table';

+-----------------------+-------+

| Variable_name         | Value |

+-----------------------+-------+

| innodb_file_per_table | ON    |

+-----------------------+-------+

1 row in set (0.00 sec)



(root@localhost) [mytest]> show variables like 'innodb_doublewrite';

+--------------------+-------+

| Variable_name      | Value |

+--------------------+-------+

| innodb_doublewrite | ON    |

+--------------------+-------+

1 row in set (0.00 sec)

\###myisam

(root@localhost) [mytest]> show variables like 'delay_key_write';   ###OFF ON ALL

+-----------------+-------+

| Variable_name   | Value |

+-----------------+-------+

| delay_key_write | ON    |

+-----------------+-------+

1 row in set (0.00 sec)



(root@localhost) [mytest]> show variables like 'expire_logs_days';

+------------------+-------+

| Variable_name    | Value |

+------------------+-------+

| expire_logs_days | 90    |

+------------------+-------+

1 row in set (0.00 sec)

(root@localhost) [mytest]> show variables like 'max_allowed_packet';    ###需主从一致

+--------------------+----------+

| Variable_name      | Value    |

+--------------------+----------+

| max_allowed_packet | 16777216 |

+--------------------+----------+

1 row in set (0.00 sec)



(root@localhost) [mytest]> show variables like 'skip_name_resolve';

+-------------------+-------+

| Variable_name     | Value |

+-------------------+-------+

| skip_name_resolve | ON    |

+-------------------+-------+

1 row in set (0.00 sec)

![](D:\github\blog\mysql\pictures\Image [6].png)

(root@localhost) [mytest]> show global variables like 'read_only';   ###从库启用

+---------------+-------+

| Variable_name | Value |

+---------------+-------+

| read_only     | OFF   |

+---------------+-------+

1 row in set (0.00 sec)

![](D:\github\blog\mysql\pictures\Image [7].png)



(root@localhost) [mytest]> show global variables like 'sync_binlog';

+---------------+-------+

| Variable_name | Value |

+---------------+-------+

| sync_binlog   | 1     |

+---------------+-------+

1 row in set (0.00 sec)

![](D:\github\blog\mysql\pictures\Image [8].png)

(root@localhost) [mytest]> show global variables like '%_table_size';

+---------------------+----------+

| Variable_name       | Value    |

+---------------------+----------+

| max_heap_table_size | 16777216 |

| tmp_table_size      | 67108864 |

+---------------------+----------+

2 rows in set (0.00 sec)

(root@localhost) [mytest]> show global variables like 'max_connections';

+-----------------+-------+

| Variable_name   | Value |

+-----------------+-------+

| max_connections | 800   |

+-----------------+-------+

1 row in set (0.00 sec)

![](D:\github\blog\mysql\pictures\Image [9].png)

![](D:\github\blog\mysql\pictures\Image [10].png)

![](D:\github\blog\mysql\pictures\Image [11].png)

![](D:\github\blog\mysql\pictures\Image [12].png)

![](D:\github\blog\mysql\pictures\Image [13].png)

[root@centos ~]# mysqlslap --concurrency=1,50,100,200 --iterations=3 --number-int-cols=5 --number-char-cols=5 --auto-generate-sql --auto-generate-sql-add-autoincrement --engine=myisam,innodb --number-of-queries=10 --create-schema=sbtest;

Benchmark

```
    Running for engine myisam

    Average number of seconds to run all queries: 0.017 seconds

    Minimum number of seconds to run all queries: 0.012 seconds

    Maximum number of seconds to run all queries: 0.029 seconds

    Number of clients running queries: 1

    Average number of queries per client: 10
```



Benchmark

```
    Running for engine myisam

    Average number of seconds to run all queries: 2.206 seconds

    Minimum number of seconds to run all queries: 1.302 seconds

    Maximum number of seconds to run all queries: 3.151 seconds

    Number of clients running queries: 50

    Average number of queries per client: 0
```



Benchmark

```
    Running for engine myisam

    Average number of seconds to run all queries: 3.641 seconds

    Minimum number of seconds to run all queries: 2.936 seconds

    Maximum number of seconds to run all queries: 4.780 seconds

    Number of clients running queries: 100

    Average number of queries per client: 0
```



Benchmark

```
    Running for engine myisam

    Average number of seconds to run all queries: 6.584 seconds

    Minimum number of seconds to run all queries: 5.821 seconds

    Maximum number of seconds to run all queries: 8.078 seconds

    Number of clients running queries: 200

    Average number of queries per client: 0
```



Benchmark

```
    Running for engine innodb

    Average number of seconds to run all queries: 0.012 seconds

    Minimum number of seconds to run all queries: 0.012 seconds

    Maximum number of seconds to run all queries: 0.013 seconds

    Number of clients running queries: 1

    Average number of queries per client: 10
```



Benchmark

```
    Running for engine innodb

    Average number of seconds to run all queries: 0.375 seconds

    Minimum number of seconds to run all queries: 0.223 seconds

    Maximum number of seconds to run all queries: 0.622 seconds

    Number of clients running queries: 50

    Average number of queries per client: 0
```



Benchmark

```
    Running for engine innodb

    Average number of seconds to run all queries: 0.958 seconds

    Minimum number of seconds to run all queries: 0.855 seconds

    Maximum number of seconds to run all queries: 1.123 seconds

    Number of clients running queries: 100

    Average number of queries per client: 0
```



Benchmark

```
    Running for engine innodb

    Average number of seconds to run all queries: 1.355 seconds

    Minimum number of seconds to run all queries: 0.984 seconds

    Maximum number of seconds to run all queries: 1.836 seconds

    Number of clients running queries: 200

    Average number of queries per client: 0
```





[root@centos ~]# mysqlslap --concurrency=1,50,100,200 --iterations=3 --number-int-cols=5 --number-char-cols=5 --auto-generate-sql --auto-generate-sql-add-autoincrement --engine=myisam,innodb --number-of-queries=10 --create-schema=sbtest --only-print|more

DROP SCHEMA IF EXISTS `sbtest`;

CREATE SCHEMA `sbtest`;

use sbtest;

set default_storage_engine=`myisam`;

CREATE TABLE `t1` (id serial,intcol1 INT(32) ,intcol2 INT(32) ,intcol3 INT(32) ,intcol4 INT(32) ,intcol5 INT(32) ,charcol1 VARCHAR(128),charcol2 VARCHAR(128

),charcol3 VARCHAR(128),charcol4 VARCHAR(128),charcol5 VARCHAR(128));

INSERT INTO t1 VALUES (NULL,1804289383,846930886,1681692777,1714636915,1957747793,'vmC9127qJNm06sGB8R92q2j7vTiiITRDGXM9ZLzkdekbWtmXKwZ2qG1llkRw5m9DHOFilEREk

3q7oce8O3BEJC0woJsm6uzFAEynLH2xCsw1KQ1lT4zg9rdxBLb97R','GHZ65mNzkSrYT3zWoSbg9cNePQr1bzSk81qDgE4Oanw3rnPfGsBHSbnu1evTdFDe83ro9w4jjteQg4yoo9xHck3WNqzs54W5zEm9

2ikdRF48B2oz3m8gMBAl11Wy50','w46i58Giekxik0cYzfA8BZBLADEg3JhzGfZDoqvQQk0Akcic7lcJInYSsf



\###sysbench

<https://github.com/akopytov/sysbench#linux>



[root@centos tools]# sysbench --test=cpu --cpu-max-prime=10000 run

WARNING: the --test option is deprecated. You can pass a script name or path on the command line without any options.

sysbench 1.0.13 (using bundled LuaJIT 2.1.0-beta2)



Running the test with following options:

Number of threads: 1

Initializing random number generator from current time





Prime numbers limit: 10000



Initializing worker threads...



Threads started!



CPU speed:

```
events per second:   914.21
```



General statistics:

```
total time:                          10.0004s

total number of events:              9144
```



Latency (ms):

```
     min:                                    1.04

     avg:                                    1.09

     max:                                    2.30

     95th percentile:                        1.16

     sum:                                 9993.36
```



Threads fairness:

```
events (avg/stddev):           9144.0000/0.00

execution time (avg/stddev):   9.9934/0.00
```



sysbench /usr/share/sysbench/oltp_read_only.lua --mysql-host=127.0.0.1 --mysql-port=3306 --mysql-user=root --mysql-password='oracle' --mysql-db=mytest --db-driver=mysql --tables=10 --table-size=1000000 --report-interval=10 --threads=128 --time=120 prepare



sysbench /usr/share/sysbench/oltp_read_only.lua --mysql-host=127.0.0.1 --mysql-port=3306 --mysql-user=root --mysql-password='oracle' --mysql-db=mytest --db-driver=mysql --tables=10 --table-size=1000000 --report-interval=10 --threads=128 --time=120 run

## mysqlbinlog命令查看binglog_format=row的日志

在配置文件中配置有`binglog_format=row`的数据库产生的 binglog 日志是不能以正常的`mysqlbinlog logfile`的方式打开的, 默认情况下只能看到一些经过base-64编码的信息

- 从MySQL 5.1.28开始，mysqlbinlog多了个参数–verbose(或-v)，将改动生成带注释的语句，如果使用两次这个参数(如-v -v)，会生成字段的类型、长度、是否为null等属性信息
- 加–base64-output=DECODE-ROWS参数还可以去掉BINLOG开头的信息

```
mysqlbinlog -v -v --base64-output=DECODE-ROWS mysql-bin.000003
```