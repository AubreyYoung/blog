```
[root@centos tpcc-mysql]# mysql tpcc1000 -e "show tables";
+--------------------+
| Tables_in_tpcc1000 |
+--------------------+
| customer           |
| district           |
| history            |
| item               |
| new_orders         |
| order_line         |
| orders             |
| stock              |
| warehouse          |
+--------------------+
```
```
## [root@centos tpcc-mysql]# ./tpcc_start  -h localhost -P 3306 -d tpcc1000 -u root -p oracle -S /tmp/mysql.sock -w 10 -c 10 -r 2 -l 5 -i 5 -f tpcc_20180408_01 -t trx_20180408

- ###easy### TPC-C Load Generator *

------

option h with value 'localhost'
option P with value '3306'
option d with value 'tpcc1000'
option u with value 'root'
option p with value 'oracle'
option S (socket) with value '/tmp/mysql.sock'
option w with value '10'
option c with value '10'
option r with value '2'
option l with value '5'
option i with value '5'
option f with value 'tpcc_20180408_01'
option t with value 'trx_20180408'
<Parameters>

[server]: localhost
[port]: 3306
[DBname]: tpcc1000
[user]: root
[pass]: oracle
[warehouse]: 10
[connection]: 10
[rampup]: 2	"sec."
[measure]: 5	"sec."

RAMP-UP TIME.(2 sec.)
MEASURING START.
   5, trx: 179, 95%: 681.363, 99%: 886.175, max_rt: 1107.724, 177|739.591, 18|58.454, 16|1517.137, 17|285.032
STOPPING THREADS..........
<Raw Results>
  [0] sc:0 lt:179  rt:0  fl:0 avg_rt: 203.9 (5)
  [1] sc:0 lt:177  rt:0  fl:0 avg_rt: 105.3 (5)
  [2] sc:15 lt:3  rt:0  fl:0 avg_rt: 7.5 (5)
  [3] sc:0 lt:16  rt:0  fl:0 avg_rt: 765.0 (80)
  [4] sc:8 lt:9  rt:0  fl:0 avg_rt: 55.3 (20)
in 5 sec.
<Raw Results2(sum ver.)>
  [0] sc:0  lt:179  rt:0  fl:0
  [1] sc:0  lt:177  rt:0  fl:0
  [2] sc:15  lt:3  rt:0  fl:0
  [3] sc:0  lt:16  rt:0  fl:0
  [4] sc:8  lt:9  rt:0  fl:0
<Constraint Check> (all must be [OK])
[transaction percentage]
​        Payment: 43.49% (>=43.0%) [OK]
   Order-Status: 4.42% (>= 4.0%) [OK]
​       Delivery: 3.93% (>= 4.0%) [NG] *
​    Stock-Level: 4.18% (>= 4.0%) [OK][response time (at least 90% passed)]
​      New-Order: 0.00%  [NG] *
​        Payment: 0.00%  [NG] *
   Order-Status: 83.33%  [NG] *
​       Delivery: 0.00%  [NG] *
​    Stock-Level: 47.06%  [NG] *
<TpmC>
​                 2148.000 TpmC
```
```
root@mysql 14:07:  [(none)]> select substring(md5(rand()) from 1 for 16);
+--------------------------------------+
| substring(md5(rand()) from 1 for 16) |
+--------------------------------------+
| 7bbd122c1797d1ef                     |
+--------------------------------------+
1 row in set (0.43 sec)
root@mysql 14:07:  [(none)]> select length(substring(md5(rand()) from 1 for 16));
+----------------------------------------------+
| length(substring(md5(rand()) from 1 for 16)) |
+----------------------------------------------+
|                                           16 |
+----------------------------------------------+
1 row in set (0.00 sec)
root@mysql 14:09:  [(none)]>  select substring(md5(rand()) from 1 for round(8+rand()*32));       
+------------------------------------------------------+
| substring(md5(rand()) from 1 for round(8+rand()*32)) |
+------------------------------------------------------+
| 97d24318bfc90a264fc5afb                              |
+------------------------------------------------------+
1 row in set (0.00 sec)
root@mysql 14:09:  [(none)]>  select substring(md5(rand()) from 1 for round(8+rand()*32));
+------------------------------------------------------+
| substring(md5(rand()) from 1 for round(8+rand()*32)) |
+------------------------------------------------------+
| 98607f7d3ef0e55b9df2e6957                            |
+------------------------------------------------------+
1 row in set (0.00 sec)
root@mysql 14:09:  [(none)]>  select substring(md5(rand()) from 1 for round(8+rand()*32));
+------------------------------------------------------+
| substring(md5(rand()) from 1 for round(8+rand()*32)) |
+------------------------------------------------------+
| 819d9b13a1d955                                       |
+------------------------------------------------------+
1 row in set (0.00 sec)
root@mysql 14:50:  [mysql]> set global log_output='table';       
Query OK, 0 rows affected (0.00 sec)
root@mysql 14:50:  [mysql]> show global variables like '%log_out%';
+---------------+-------+

| Variable_name | Value |
| ------------- | ----- |
|               |       |
+---------------+-------+
| log_output | TABLE |
| ---------- | ----- |
|            |       |
+---------------+-------+
1 row in set (0.00 sec)
root@mysql 14:50:  [mysql]> show global variables like '%general%';               
+------------------+-------+
| Variable_name | Value |
| ------------- | ----- |
|               |       |
+------------------+-------+
| general_log | OFF  |
| ----------- | ---- |
|             |      |
| general_log_file | table |
| ---------------- | ----- |
|                  |       |
+------------------+-------+
2 rows in set (0.00 sec)
root@mysql 14:51:  [mysql]> set global  general_log = on;
Query OK, 0 rows affected (0.00 sec)
root@mysql 14:51:  [mysql]> show global variables like '%general%';
+------------------+-------+
| Variable_name | Value |
| ------------- | ----- |
|               |       |
+------------------+-------+
| general_log | ON   |
| ----------- | ---- |
|             |      |
| general_log_file | table |
| ---------------- | ----- |
|                  |       |
+------------------+-------+
2 rows in set (0.00 sec)
root@mysql 14:51:  [mysql]> select event_time,thread_id,argument from general_log;
+----------------------------+-----------+-------------------------------------------------------+
| event_time | thread_id | argument |
| ---------- | --------- | -------- |
|            |           |          |
+----------------------------+-----------+-------------------------------------------------------+
| 2018-04-08 14:51:21.187833 | 28   | show global variables like '%general%' |
| -------------------------- | ---- | -------------------------------------- |
|                            |      |                                        |
| 2018-04-08 14:51:28.267054 | 28   | select event_time,thread_id,argument from general_log |
| -------------------------- | ---- | ----------------------------------------------------- |
|                            |      |                                                       |
+----------------------------+-----------+-------------------------------------------------------+
2 rows in set (0.00 sec)

```
```
mysqldump --single-transaction --databases sampdb > mysqltest.sql
```
```
root@mysql 14:54:  [mysql]> select event_time,thread_id,argument from general_log;
+----------------------------+-----------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| event_time | thread_id | argument |
| ---------- | --------- | -------- |
|            |           |          |
+----------------------------+-----------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 2018-04-08 14:54:41.253220 | 40   | root@localhost on  using Socket |
| -------------------------- | ---- | ------------------------------- |
|                            |      |                                 |
| 2018-04-08 14:54:41.255585 | 40   | /*!40100 SET @@SQL_MODE='' */ |
| -------------------------- | ---- | ----------------------------- |
|                            |      |                               |
| 2018-04-08 14:54:41.257029 | 40   | /*!40103 SET TIME_ZONE='+00:00' */ |
| -------------------------- | ---- | ---------------------------------- |
|                            |      |                                    |
| 2018-04-08 06:54:41.257163 | 40   | SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ |
| -------------------------- | ---- | ------------------------------------------------------- |
|                            |      |                                                         |
| 2018-04-08 06:54:41.257224 | 40   | START TRANSACTION /*!40100 WITH CONSISTENT SNAPSHOT */ |
| -------------------------- | ---- | ------------------------------------------------------ |
|                            |      |                                                        |
| 2018-04-08 06:54:41.257296 |        40 | SHOW VARIABLES LIKE 'gtid_mode'  
```
```
[root@centos ~]# mysqlpump  --single-transaction --parallel-schemas=4:tpcc1000 --parallel-schemas=2sampdb >sampdb.sql             
Dump progress: 1/6 tables, 0/3718559 rows
Dump progress: 2/25 tables, 376250/3721637 rows
Dump progress: 4/25 tables, 666877/3721637 rows
Dump progress: 4/25 tables, 1201877/3721637 rows
mysqlpump: [WARNING] (1429) Unable to connect to foreign data source: Can't connect to MySQL server on '192.168.45.84' (113)
Dump progress: 4/63 tables, 1564377/13259663 rows
Dump progress: 24/75 tables, 1985580/18220983 rows
Dump progress: 24/75 tables, 2579330/18220983 rows
Dump progress: 24/75 tables, 2964080/18220983 rows
Dump progress: 24/75 tables, 3373330/18220983 rows
Dump progress: 24/75 tables, 3705330/18220983 rows
xtrabackup --target-dir=/path/20110427/ --backup --throttle=100
root@mysql 15:44:  [(none)]> flush engine logs;
Query OK, 0 rows affected (0.29 sec)
root@mysql 17:24:  [(none)]> show global variables like 'binlog%image';
+------------------+-------+
| Variable_name | Value |
| ------------- | ----- |
|               |       |
+------------------+-------+
| binlog_row_image | FULL |
| ---------------- | ---- |
|                  |      |
+------------------+-------+
1 row in set (0.00 sec)
root@mysql 17:27:  [(none)]> set global binlog_row_image='minimal';
Query OK, 0 rows affected (0.00 sec)
root@mysql 17:27:  [(none)]> show global variables like 'binlog%image';
+------------------+---------+
| Variable_name | Value |
| ------------- | ----- |
|               |       |
+------------------+---------+
| binlog_row_image | MINIMAL |
| ---------------- | ------- |
|                  |         |
+------------------+---------+
1 row in set (0.00 sec)
root@mysql 17:38:  [(none)]> show binlog events in 'bin.000067' from 2 limit 5,5;  
+------------+------+------------+-----------+-------------+-----------------------------------+
| Log_name | Pos  | Event_type | Server_id | End_log_pos | Info |
| -------- | ---- | ---------- | --------- | ----------- | ---- |
|          |      |            |           |             |      |
+------------+------+------------+-----------+-------------+-----------------------------------+
| bin.000067 | 440  | Write_rows | 11   | 1101 | table_id: 368 flags: STMT_END_F |
| ---------- | ---- | ---------- | ---- | ---- | ------------------------------- |
|            |      |            |      |      |                                 |
| bin.000067 | 1101 | Table_map | 11   | 1167 | table_id: 369 (tpcc1000.history) |
| ---------- | ---- | --------- | ---- | ---- | -------------------------------- |
|            |      |           |      |      |                                  |
| bin.000067 | 1167 | Write_rows | 11   | 1240 | table_id: 369 flags: STMT_END_F |
| ---------- | ---- | ---------- | ---- | ---- | ------------------------------- |
|            |      |            |      |      |                                 |
| bin.000067 | 1240 | Table_map | 11   | 1345 | table_id: 368 (tpcc1000.customer) |
| ---------- | ---- | --------- | ---- | ---- | --------------------------------- |
|            |      |           |      |      |                                   |
| bin.000067 | 1345 | Write_rows | 11   | 1991 | table_id: 368 flags: STMT_END_F |
| ---------- | ---- | ---------- | ---- | ---- | ------------------------------- |
|            |      |            |      |      |                                 |
+------------+------+------------+-----------+-------------+-----------------------------------+
5 rows in set (0.13 sec)
mysqlbinlog --start-position=27284 binlog.001002 binlog.001003 binlog.001004 | mysql --host=host_name -u root -p
mysql> flush logs;
Query OK, 0 rows affected (0.01 sec)
mysql> show master status;
+------------------+----------+--------------+------------------+------------------------------------------+
| File | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
| ---- | -------- | ------------ | ---------------- | ----------------- |
|      |          |              |                  |                   |
+------------------+----------+--------------+------------------+------------------------------------------+
| mysql-bin.000018 | 194  |      |      | 7d0e42b6-0c89-11e8-90d8-000c292c7e58:1-6 |
| ---------------- | ---- | ---- | ---- | ---------------------------------------- |
|                  |      |      |      |                                          |
+------------------+----------+--------------+------------------+------------------------------------------+
1 row in set (0.00 sec)
mysql> show variables like '%skip%';
+------------------------+-------+
| Variable_name | Value |
| ------------- | ----- |
|               |       |
+------------------------+-------+
| skip_external_locking | ON   |
| --------------------- | ---- |
|                       |      |
| skip_name_resolve | OFF  |
| ----------------- | ---- |
|                   |      |
| skip_networking | OFF  |
| --------------- | ---- |
|                 |      |
| skip_show_database | OFF  |
| ------------------ | ---- |
|                    |      |
| slave_skip_errors | OFF  |
| ----------------- | ---- |
|                   |      |
| sql_slave_skip_counter | 0    |
| ---------------------- | ---- |
|                        |      |
+------------------------+-------+
6 rows in set (0.00 sec)
mysql> set global sql_slave_skip_counter=1;



mysql> show variables like '%skip%';
+------------------------+-------+

| Variable_name | Value |
| ------------- | ----- |
|               |       |
+------------------------+-------+
| skip_external_locking | ON   |
| --------------------- | ---- |
|                       |      |
| skip_name_resolve | OFF  |
| ----------------- | ---- |
|                   |      |
| skip_networking | OFF  |
| --------------- | ---- |
|                 |      |
| skip_show_database | OFF  |
| ------------------ | ---- |
|                    |      |
| slave_skip_errors | OFF  |
| ----------------- | ---- |
|                   |      |
| sql_slave_skip_counter | 0    |
| ---------------------- | ---- |
|                        |      |
+------------------------+-------+
6 rows in set (0.00 sec)
mysql> show variables like '%sync_relay%';
+---------------------+-------+
| Variable_name | Value |
| ------------- | ----- |
|               |       |
+---------------------+-------+
| sync_relay_log | 10000 |
| -------------- | ----- |
|                |       |
| sync_relay_log_info | 10000 |
| ------------------- | ----- |
|                     |       |
+---------------------+-------+
2 rows in set (0.00 sec)
mysql> show variables like '%relay%';     
+---------------------------+--------------------------------------+
| Variable_name | Value |
| ------------- | ----- |
|               |       |
+---------------------------+--------------------------------------+
| max_relay_log_size | 0    |
| ------------------ | ---- |
|                    |      |
| relay_log | /var/lib/mysql/mysql-relay-bin |
| --------- | ------------------------------ |
|           |                                |
| relay_log_basename | /var/lib/mysql/mysql-relay-bin |
| ------------------ | ------------------------------ |
|                    |                                |
| relay_log_index | /var/lib/mysql/mysql-relay-bin.index |
| --------------- | ------------------------------------ |
|                 |                                      |
| relay_log_info_file | relay-log.info |
| ------------------- | -------------- |
|                     |                |
| relay_log_info_repository | TABLE |
| ------------------------- | ----- |
|                           |       |
| relay_log_purge | ON   |
| --------------- | ---- |
|                 |      |
| relay_log_recovery | OFF  |
| ------------------ | ---- |
|                    |      |
| relay_log_space_limit | 0    |
| --------------------- | ---- |
|                       |      |
| sync_relay_log | 10000 |
| -------------- | ----- |
|                |       |
| sync_relay_log_info | 10000 |
| ------------------- | ----- |
|                     |       |
+---------------------------+--------------------------------------+
11 rows in set (0.00 sec)
mysql> show variables like '%master%';
+------------------------+-------+
| Variable_name | Value |
| ------------- | ----- |
|               |       |
+------------------------+-------+
| master_info_repository | TABLE |
| ---------------------- | ----- |
|                        |       |
| master_verify_checksum | OFF  |
| ---------------------- | ---- |
|                        |      |
| sync_master_info | 10000 |
| ---------------- | ----- |
|                  |       |
+------------------------+-------+
3 rows in set (0.00 sec)

root@mysql 10:24:  [(none)]> show variables like '%super%';
+-----------------+-------+
| Variable_name | Value |
| ------------- | ----- |
|               |       |
+-----------------+-------+
| super_read_only | OFF  |
| --------------- | ---- |
|                 |      |
+-----------------+-------+
1 row in set (0.00 sec)
root@mysql 10:26:  [(none)]> show variables like 'read_only';
+---------------+-------+
| Variable_name | Value |
| ------------- | ----- |
|               |       |
+---------------+-------+
| read_only | OFF  |
| --------- | ---- |
|           |      |
+---------------+-------+
1 row in set (0.00 sec)
mysql> show slave hosts;
+-----------+------+------+-----------+--------------------------------------+
| Server_id | Host | Port | Master_id | Slave_UUID |
| --------- | ---- | ---- | --------- | ---------- |
|           |      |      |           |            |
+-----------+------+------+-----------+--------------------------------------+
| 2    |      | 3306 | 1    | 7657c51c-0c89-11e8-8d27-000c29e60559 |
| ---- | ---- | ---- | ---- | ------------------------------------ |
|      |      |      |      |                                      |
+-----------+------+------+-----------+--------------------------------------+
1 row in set (0.00 sec)
```
## mysqldump:mysql备份
 mysqldump -uroot -poracle -B -A --events -x |gzip>/app/mysqlbak$(date +%F%T).sql.gz
 mysqldump -uroot -poracle -B -A --events -x |gzip>/app/mysqlbak`date +%F%T`.sql.gz
 mysqldump -uroot -poracle -B  --events -x  wordpress|gzip>/app/mysqlbak`date +%F%T`.sql.gz
## mysql刷新权限
flush privileges;  

```
mysql> show engine innodb status\G
********* 1. row *********
  Type: InnoDB
  Name:

# Status:

# 2018-04-13 08:32:48 0x7fdfde5fa700 INNODB MONITOR OUTPUT

## Per second averages calculated from the last 4 seconds

## BACKGROUND THREAD

srv_master_thread loops: 5 srv_active, 0 srv_shutdown, 486 srv_idle

## srv_master_thread log flush and writes: 491

## SEMAPHORES

OS WAIT ARRAY INFO: reservation count 135
OS WAIT ARRAY INFO: signal count 133
RW-shared spins 0, rounds 12, OS waits 6
RW-excl spins 0, rounds 60, OS waits 2
RW-sx spins 0, rounds 0, OS waits 0

## Spin rounds per wait: 12.00 RW-shared, 60.00 RW-excl, 0.00 RW-sx

## TRANSACTIONS

Trx id counter 15238
Purge done for trx's n:o < 15237 undo n:o < 0 state: running but idle
History list length 18
LIST OF TRANSACTIONS FOR EACH SESSION:
---TRANSACTION 422074637217392, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 422074637216480, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 422074637215568, not started

## 0 lock struct(s), heap size 1136, 0 row lock(s)

## FILE I/O

I/O thread 0 state: waiting for completed aio requests (insert buffer thread)
I/O thread 1 state: waiting for completed aio requests (log thread)
I/O thread 2 state: waiting for completed aio requests (read thread)
I/O thread 3 state: waiting for completed aio requests (read thread)
I/O thread 4 state: waiting for completed aio requests (read thread)
I/O thread 5 state: waiting for completed aio requests (read thread)
I/O thread 6 state: waiting for completed aio requests (write thread)
I/O thread 7 state: waiting for completed aio requests (write thread)
I/O thread 8 state: waiting for completed aio requests (write thread)
I/O thread 9 state: waiting for completed aio requests (write thread)
Pending normal aio reads: [0, 0, 0, 0] , aio writes: [0, 0, 0, 0] ,
ibuf aio reads:, log i/o's:, sync i/o's:
Pending flushes (fsync) log: 0; buffer pool: 0
459 OS file reads, 219 OS file writes, 86 OS fsyncs

## 0.00 reads/s, 0 avg bytes/read, 0.00 writes/s, 0.00 fsyncs/s

## INSERT BUFFER AND ADAPTIVE HASH INDEX

Ibuf: size 1, free list len 0, seg size 2, 0 merges
merged operations:
insert 0, delete mark 0, delete 0
discarded operations:
insert 0, delete mark 0, delete 0
Hash table size 34673, node heap has 0 buffer(s)
Hash table size 34673, node heap has 0 buffer(s)
Hash table size 34673, node heap has 0 buffer(s)
Hash table size 34673, node heap has 0 buffer(s)
Hash table size 34673, node heap has 0 buffer(s)
Hash table size 34673, node heap has 0 buffer(s)
Hash table size 34673, node heap has 0 buffer(s)
Hash table size 34673, node heap has 0 buffer(s)

## 0.00 hash searches/s, 0.00 non-hash searches/s

## LOG

Log sequence number 5543009
Log flushed up to   5543009
Pages flushed up to 5543009
Last checkpoint at  5543000
0 pending log flushes, 0 pending chkp writes

## 80 log i/o's done, 0.00 log i/o's/second

## BUFFER POOL AND MEMORY

Total large memory allocated 137428992
Dictionary memory allocated 145206
Buffer pool size   8191
Free buffers       7733
Database pages     458
Old database pages 0
Modified db pages  0
Pending reads      0
Pending writes: LRU 0, flush list 0, single page 0
Pages made young 0, not young 0
0.00 youngs/s, 0.00 non-youngs/s
Pages read 420, created 38, written 129
0.00 reads/s, 0.00 creates/s, 0.00 writes/s
No buffer pool page gets since the last printout
Pages read ahead 0.00/s, evicted without access 0.00/s, Random read ahead 0.00/s
LRU len: 458, unzip_LRU len: 0

## I/O sum[0]:cur[0], unzip sum[0]:cur[0]

## ROW OPERATIONS

0 queries inside InnoDB, 0 queries in queue
0 read views open inside InnoDB
Process ID=1591, Main thread ID=140599331071744, state: sleeping
Number of rows inserted 45, updated 112, deleted 0, read 186

## 0.00 inserts/s, 0.00 updates/s, 0.00 deletes/s, 0.00 reads/s

# END OF INNODB MONITOR OUTPUT

1 row in set (0.00 sec)
mysql> INSTALL PLUGIN rpl_semi_sync_slave SONAME 'semisync_slave.so';
Query OK, 0 rows affected (0.41 sec)
mysql> INSTALL PLUGIN rpl_semi_sync_master SONAME 'semisync_master.so';
mysql> show plugins;
+----------------------------+----------+--------------------+----------------------+---------+
| Name                       | Status   | Type               | Library              | License |
+----------------------------+----------+--------------------+----------------------+---------+
| binlog                     | ACTIVE   | STORAGE ENGINE     | NULL                 | GPL     |
| mysql_native_password      | ACTIVE   | AUTHENTICATION     | NULL                 | GPL     |
| sha256_password            | ACTIVE   | AUTHENTICATION     | NULL                 | GPL     |
| CSV                        | ACTIVE   | STORAGE ENGINE     | NULL                 | GPL     |
| MyISAM                     | ACTIVE   | STORAGE ENGINE     | NULL                 | GPL     |
| MRG_MYISAM                 | ACTIVE   | STORAGE ENGINE     | NULL                 | GPL     |
| PERFORMANCE_SCHEMA         | ACTIVE   | STORAGE ENGINE     | NULL                 | GPL     |
| MEMORY                     | ACTIVE   | STORAGE ENGINE     | NULL                 | GPL     |
| InnoDB                     | ACTIVE   | STORAGE ENGINE     | NULL                 | GPL     |
| INNODB_TRX                 | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_LOCKS               | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_LOCK_WAITS          | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_CMP                 | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_CMP_RESET           | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_CMPMEM              | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_CMPMEM_RESET        | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_CMP_PER_INDEX       | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_CMP_PER_INDEX_RESET | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_BUFFER_PAGE         | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_BUFFER_PAGE_LRU     | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_BUFFER_POOL_STATS   | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_TEMP_TABLE_INFO     | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_METRICS             | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_FT_DEFAULT_STOPWORD | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_FT_DELETED          | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_FT_BEING_DELETED    | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_FT_CONFIG           | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_FT_INDEX_CACHE      | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_FT_INDEX_TABLE      | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_SYS_TABLES          | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_SYS_TABLESTATS      | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_SYS_INDEXES         | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_SYS_COLUMNS         | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_SYS_FIELDS          | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_SYS_FOREIGN         | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_SYS_FOREIGN_COLS    | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_SYS_TABLESPACES     | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_SYS_DATAFILES       | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_SYS_VIRTUAL         | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| partition                  | ACTIVE   | STORAGE ENGINE     | NULL                 | GPL     |
| ARCHIVE                    | ACTIVE   | STORAGE ENGINE     | NULL                 | GPL     |
| FEDERATED                  | DISABLED | STORAGE ENGINE     | NULL                 | GPL     |
| BLACKHOLE                  | ACTIVE   | STORAGE ENGINE     | NULL                 | GPL     |
| ngram                      | ACTIVE   | FTPARSER           | NULL                 | GPL     |
| validate_password          | DISABLED | VALIDATE PASSWORD  | validate_password.so | GPL     |
| rpl_semi_sync_master       | ACTIVE   | REPLICATION        | semisync_master.so   | GPL     |
+----------------------------+----------+--------------------+----------------------+---------+
46 rows in set (0.00 sec)
root@mysql 13:46:  [(none)]> show variables like 'slave_rows_search_algorithms';
+------------------------------+-----------------------+
| Variable_name                | Value                 |
+------------------------------+-----------------------+
| slave_rows_search_algorithms | TABLE_SCAN,INDEX_SCAN |
+------------------------------+-----------------------+
1 row in set (0.00 sec)
root@mysql 13:50:  [(none)]> show global status like '%rpl%';
+--------------------------------------------+-------+
| Variable_name                              | Value |
+--------------------------------------------+-------+
| Rpl_semi_sync_master_clients               | 0     |
| Rpl_semi_sync_master_net_avg_wait_time     | 0     |
| Rpl_semi_sync_master_net_wait_time         | 0     |
| Rpl_semi_sync_master_net_waits             | 0     |
| Rpl_semi_sync_master_no_times              | 0     |
| Rpl_semi_sync_master_no_tx                 | 0     |
| Rpl_semi_sync_master_status                | ON    |
| Rpl_semi_sync_master_timefunc_failures     | 0     |
| Rpl_semi_sync_master_tx_avg_wait_time      | 0     |
| Rpl_semi_sync_master_tx_wait_time          | 0     |
| Rpl_semi_sync_master_tx_waits              | 0     |
| Rpl_semi_sync_master_wait_pos_backtraverse | 0     |
| Rpl_semi_sync_master_wait_sessions         | 0     |
| Rpl_semi_sync_master_yes_tx                | 0     |
| Rpl_semi_sync_slave_status                 | OFF   |
+--------------------------------------------+-------+
15 rows in set (0.00 sec)
mysql> stop slave io_thread;
Query OK, 0 rows affected, 1 warning (0.00 sec)
mysql> stop slave sql_thread;  
Query OK, 0 rows affected, 1 warning (0.00 sec)
```
## 针对某个DB复制
```
--replicate-do-db=db_name

[root@master ~]#  mysqlreplicate --master=root:oracle@192.168.45.32:3306 --slave=root:oracle@192.168.45.33:3306 --rpl-user=repl:oracle
WARNING: Using a password on the command line interface can be insecure.

# master on 192.168.45.32: ... connected.

# slave on 192.168.45.33: ... connected.

# Checking for binary logging on master...

# Setting up replication...

# ...done.

#mysqlreplicate --master=root:oracle@192.168.45.32:3306 --slave=root:oracle@192.168.45.33:3306 --rpl-user=repl:oracle for channel 'ch1'
mysql> reset slave all;
Query OK, 0 rows affected (0.02 sec)
[root@master ~]# mysqlrplcheck --master=root:oracle@localhost:3306 --slave=root:oracle@192.168.45.33:3306
WARNING: Using a password on the command line interface can be insecure.

# master on localhost: ... connected.

# slave on 192.168.45.33: ... connected.

## Test Description                                                     Status

Checking for binary logging on master                                [pass]
Are there binlog exceptions?                                         [pass]
Replication user exists?                                             [pass]
Checking server_id values                                            [pass]
Checking server_uuid values                                          [pass]
Is slave connected to master?                                        [pass]
Check master information file                                        [pass]
Checking InnoDB compatibility                                        [pass]
Checking storage engines compatibility                               [pass]
Checking lower_case_table_names settings                             [pass]
Checking slave delay (seconds behind master)                         [pass]

# ...done.
```

## 需备份二进制日志
```
mysql> show master status;
+------------------+----------+--------------+------------------+----------------------------------------------+

| File | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
| ---- | -------- | ------------ | ---------------- | ----------------- |
|      |          |              |                  |                   |
+------------------+----------+--------------+------------------+----------------------------------------------+
| mysql-bin.000020 | 8533959 |      |      | 7d0e42b6-0c89-11e8-90d8-000c292c7e58:1-23949 |
| ---------------- | ------- | ---- | ---- | -------------------------------------------- |
|                  |         |      |      |                                              |
+------------------+----------+--------------+------------------+----------------------------------------------+
1 row in set (0.00 sec)
mysql> reset master;
Query OK, 0 rows affected (0.03 sec)
mysql> show master status;
+------------------+----------+--------------+------------------+------------------------------------------+
| File | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
| ---- | -------- | ------------ | ---------------- | ----------------- |
|      |          |              |                  |                   |
+------------------+----------+--------------+------------------+------------------------------------------+
| mysql-bin.000001 | 1694 |      |      | 7d0e42b6-0c89-11e8-90d8-000c292c7e58:1-4 |
| ---------------- | ---- | ---- | ---- | ---------------------------------------- |
|                  |      |      |      |                                          |
+------------------+----------+--------------+------------------+------------------------------------------+
1 row in set (0.00 sec)
start slave for channel ch1
```
## 计算列
```
root@mysql 16:31:  [mytest]> create table t4 (id int auto_increment not null,c1 int,c2 int,c3 int,primary key (id));
Query OK, 0 rows affected (5.62 sec)
root@mysql 16:33:  [mytest]> create trigger inst_t4 before insert on t4 for each row set new.c3=new.c1+new.c2;
Query OK, 0 rows affected (0.38 sec)
root@mysql 16:35:  [mytest]> show triggers;
+---------+--------+-------+--------------------------+--------+------------------------+------------------------------------------------------------------------------------------------------------------------+----------------+----------------------+----------------------+--------------------+
| Trigger | Event | Table | Statement | Timing | Created | sql_mode | Definer | character_set_client | collation_connection | Database Collation |
| ------- | ----- | ----- | --------- | ------ | ------- | -------- | ------- | -------------------- | -------------------- | ------------------ |
|         |       |       |           |        |         |          |         |                      |                      |                    |
+---------+--------+-------+--------------------------+--------+------------------------+------------------------------------------------------------------------------------------------------------------------+----------------+----------------------+----------------------+--------------------+
| inst_t4 | INSERT | t4   | set new.c3=new.c1+new.c2 | BEFORE | 2018-04-16 16:35:51.20 | STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION | root@localhost | utf8 | utf8_general_ci | utf8mb4_general_ci |
| ------- | ------ | ---- | ------------------------ | ------ | ---------------------- | ------------------------------------------------------------ | -------------- | ---- | --------------- | ------------------ |
|         |        |      |                          |        |                        |                                                              |                |      |                 |                    |
+---------+--------+-------+--------------------------+--------+------------------------+------------------------------------------------------------------------------------------------------------------------+----------------+----------------------+----------------------+--------------------+
1 row in set (0.00 sec)
root@mysql 16:36:  [mytest]> insert into t(c1,c2) values (1,2);
ERROR 1146 (42S02): Table 'mytest.t' doesn't exist
root@mysql 16:37:  [mytest]> insert into t4(c1,c2) values (1,2);
Query OK, 1 row affected (0.01 sec)
root@mysql 16:37:  [mytest]> select * from t4;
+----+------+------+------+
| id   | c1   | c2   | c3   |
| ---- | ---- | ---- | ---- |
|      |      |      |      |
+----+------+------+------+
| 1    | 1    | 2    | 3    |
| ---- | ---- | ---- | ---- |
|      |      |      |      |
+----+------+------+------+
1 row in set (0.00 sec)
root@mysql 16:37:  [mytest]> insert into t4(c1,c2) values (2,3);
Query OK, 1 row affected (0.34 sec)
root@mysql 16:37:  [mytest]> select * from t4;
+----+------+------+------+
| id   | c1   | c2   | c3   |
| ---- | ---- | ---- | ---- |
|      |      |      |      |
+----+------+------+------+
| 1    | 1    | 2    | 3    |
| ---- | ---- | ---- | ---- |
|      |      |      |      |
| 2    | 2    | 3    | 5    |
| ---- | ---- | ---- | ---- |
|      |      |      |      |
+----+------+------+------+
2 rows in set (0.00 sec)
root@mysql 16:39:  [mytest]> create trigger upd_t4 before update on t4 for each row set new.c3=new.c1+new.c2;                
Query OK, 0 rows affected (0.00 sec)
root@mysql 16:41:  [mytest]> show triggers;
+---------+--------+-------+--------------------------+--------+------------------------+------------------------------------------------------------------------------------------------------------------------+----------------+----------------------+----------------------+--------------------+
| Trigger | Event | Table | Statement | Timing | Created | sql_mode | Definer | character_set_client | collation_connection | Database Collation |
| ------- | ----- | ----- | --------- | ------ | ------- | -------- | ------- | -------------------- | -------------------- | ------------------ |
|         |       |       |           |        |         |          |         |                      |                      |                    |
+---------+--------+-------+--------------------------+--------+------------------------+------------------------------------------------------------------------------------------------------------------------+----------------+----------------------+----------------------+--------------------+
| inst_t4 | INSERT | t4   | set new.c3=new.c1+new.c2 | BEFORE | 2018-04-16 16:35:51.20 | STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION | root@localhost | utf8 | utf8_general_ci | utf8mb4_general_ci |
| ------- | ------ | ---- | ------------------------ | ------ | ---------------------- | ------------------------------------------------------------ | -------------- | ---- | --------------- | ------------------ |
|         |        |      |                          |        |                        |                                                              |                |      |                 |                    |
| upd_t4 | UPDATE | t4   | set new.c3=new.c1+new.c2 | BEFORE | 2018-04-16 16:40:40.44 | STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION | root@localhost | utf8 | utf8_general_ci | utf8mb4_general_ci |
| ------ | ------ | ---- | ------------------------ | ------ | ---------------------- | ------------------------------------------------------------ | -------------- | ---- | --------------- | ------------------ |
|        |        |      |                          |        |                        |                                                              |                |      |                 |                    |
+---------+--------+-------+--------------------------+--------+------------------------+------------------------------------------------------------------------------------------------------------------------+----------------+----------------------+----------------------+--------------------+
2 rows in set (0.00 sec)
root@mysql 16:42:  [mytest]> update t4 set c1=5 where id=2;      
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0
root@mysql 16:43:  [mytest]> select * from t4;
+----+------+------+------+
| id   | c1   | c2   | c3   |
| ---- | ---- | ---- | ---- |
|      |      |      |      |
+----+------+------+------+
| 1    | 1    | 2    | 3    |
| ---- | ---- | ---- | ---- |
|      |      |      |      |
| 2    | 5    | 3    | 8    |
| ---- | ---- | ---- | ---- |
|      |      |      |      |
+----+------+------+------+
2 rows in set (0.00 sec)
root@mysql 16:45:  [mytest]> create view vw_t4 as select id,c1,c2,c1+c2 as c3 from t4;
Query OK, 0 rows affected (0.34 sec)
root@mysql 16:45:  [mytest]> select * from  vw_t4;
+----+------+------+------+
| id   | c1   | c2   | c3   |
| ---- | ---- | ---- | ---- |
|      |      |      |      |
+----+------+------+------+
| 1    | 1    | 2    | 3    |
| ---- | ---- | ---- | ---- |
|      |      |      |      |
| 2    | 5    | 3    | 8    |
| ---- | ---- | ---- | ---- |
|      |      |      |      |
+----+------+------+------+
2 rows in set (0.00 sec)
root@mysql 16:47:  [mytest]> create table t6 (id int auto_increment not null,c1 int,c2 int,c3 int as (c1+c2),primary key (id));  
Query OK, 0 rows affected (0.55 sec)
root@mysql 16:48:  [mytest]> show create table t6;
+-------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Table | Create Table |
| ----- | ------------ |
|       |              |
+-------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| t6    | CREATE TABLE t6 (
  id int(11) NOT NULL AUTO_INCREMENT,
  c1 int(11) DEFAULT NULL,
  c2 int(11) DEFAULT NULL,
  c3 int(11) GENERATED ALWAYS AS ((c1 + c2)) VIRTUAL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 |
+-------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)
root@mysql 16:49:  [mytest]> insert into t6(c1,c2) values(1,2);
Query OK, 1 row affected (0.34 sec)
root@mysql 16:49:  [mytest]> select * from t6;
+----+------+------+------+
| id   | c1   | c2   | c3   |
| ---- | ---- | ---- | ---- |
|      |      |      |      |
+----+------+------+------+
| 1    | 1    | 2    | 3    |
| ---- | ---- | ---- | ---- |
|      |      |      |      |
+----+------+------+------+
1 row in set (0.00 sec)
root@mysql 16:50:  [mytest]> select * from t6;
+----+------+------+------+
| id   | c1   | c2   | c3   |
| ---- | ---- | ---- | ---- |
|      |      |      |      |
+----+------+------+------+
| 1    | 5    | 2    | 7    |
| ---- | ---- | ---- | ---- |
|      |      |      |      |
+----+------+------+------+
1 row in set (0.00 sec)
root@mysql 16:50:  [mytest]> show triggers;
+---------+--------+-------+--------------------------+--------+------------------------+------------------------------------------------------------------------------------------------------------------------+----------------+----------------------+----------------------+--------------------+
| Trigger | Event | Table | Statement | Timing | Created | sql_mode | Definer | character_set_client | collation_connection | Database Collation |
| ------- | ----- | ----- | --------- | ------ | ------- | -------- | ------- | -------------------- | -------------------- | ------------------ |
|         |       |       |           |        |         |          |         |                      |                      |                    |
+---------+--------+-------+--------------------------+--------+------------------------+------------------------------------------------------------------------------------------------------------------------+----------------+----------------------+----------------------+--------------------+
| inst_t4 | INSERT | t4   | set new.c3=new.c1+new.c2 | BEFORE | 2018-04-16 16:35:51.20 | STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION | root@localhost | utf8 | utf8_general_ci | utf8mb4_general_ci |
| ------- | ------ | ---- | ------------------------ | ------ | ---------------------- | ------------------------------------------------------------ | -------------- | ---- | --------------- | ------------------ |
|         |        |      |                          |        |                        |                                                              |                |      |                 |                    |
| upd_t4 | UPDATE | t4   | set new.c3=new.c1+new.c2 | BEFORE | 2018-04-16 16:40:40.44 | STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION | root@localhost | utf8 | utf8_general_ci | utf8mb4_general_ci |
| ------ | ------ | ---- | ------------------------ | ------ | ---------------------- | ------------------------------------------------------------ | -------------- | ---- | --------------- | ------------------ |
|        |        |      |                          |        |                        |                                                              |                |      |                 |                    |
+---------+--------+-------+--------------------------+--------+------------------------+------------------------------------------------------------------------------------------------------------------------+----------------+----------------------+----------------------+--------------------+
2 rows in set (0.00 sec)
###json
root@mysql 16:54:  [mytest]> select json_array('a','b',now());
+------------------------------------------+
| json_array('a','b',now())                |
+------------------------------------------+
| ["a", "b", "2018-04-16 16:54:11.000000"] |
+------------------------------------------+
1 row in set (0.13 sec)
root@mysql 16:55:  [mytest]> select json_object('key1',1,'key2',2);
+--------------------------------+
| json_object('key1',1,'key2',2) |
+--------------------------------+
| {"key1": 1, "key2": 2}         |
+--------------------------------+
1 row in set (0.00 sec)
root@mysql 16:57:  [mytest]> create table t7(jdoc json);
Query OK, 0 rows affected (0.38 sec)
root@mysql 16:57:  [mytest]> show create table t7;
+-------+----------------------------------------------------------------------------------------+
| Table | Create Table |
| ----- | ------------ |
|       |              |
+-------+----------------------------------------------------------------------------------------+
| t7    | CREATE TABLE t7 (
  jdoc json DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 |
+-------+----------------------------------------------------------------------------------------+
1 row in set (0.00 sec)
root@mysql 16:57:  [mytest]> insert into t7(jdoc) values(json_array('a','b',now()));
Query OK, 1 row affected (0.34 sec)
root@mysql 16:59:  [mytest]> select * from t7;
+------------------------------------------+
| jdoc                                     |
+------------------------------------------+
| ["a", "b", "2018-04-16 16:59:04.000000"] |
+------------------------------------------+
1 row in set (0.00 sec)



root@mysql 17:07:  [mytest]> show variables like 'innodb_buffer_pool%';
+-------------------------------------+----------------+
| Variable_name                       | Value          |
+-------------------------------------+----------------+
| innodb_buffer_pool_chunk_size       | 134217728      |
| innodb_buffer_pool_dump_at_shutdown | ON             |
| innodb_buffer_pool_dump_now         | OFF            |
| innodb_buffer_pool_dump_pct         | 40             |
| innodb_buffer_pool_filename         | ib_buffer_pool |
| innodb_buffer_pool_instances        | 8              |
| innodb_buffer_pool_load_abort       | OFF            |
| innodb_buffer_pool_load_at_startup  | ON             |
| innodb_buffer_pool_load_now         | OFF            |
| innodb_buffer_pool_size             | 6442450944     |
+-------------------------------------+----------------+
10 rows in set (0.00 sec)
root@mysql 17:07:  [mytest]> select  134217728/1024/1024;

+---------------------+
| 134217728/1024/1024 |
+---------------------+
|        128.00000000 |
+---------------------+
1 row in set (0.00 sec)





root@mysql 17:07:  [mytest]> show variables like 'innodb_buffer_pool%';
+-------------------------------------+----------------+
| Variable_name                       | Value          |
+-------------------------------------+----------------+
| innodb_buffer_pool_chunk_size       | 134217728      |
| innodb_buffer_pool_dump_at_shutdown | ON             |
| innodb_buffer_pool_dump_now         | OFF            |
| innodb_buffer_pool_dump_pct         | 40             |
| innodb_buffer_pool_filename         | ib_buffer_pool |
| innodb_buffer_pool_instances        | 8              |
| innodb_buffer_pool_load_abort       | OFF            |
| innodb_buffer_pool_load_at_startup  | ON             |
| innodb_buffer_pool_load_now         | OFF            |
| innodb_buffer_pool_size             | 6442450944     |
+-------------------------------------+----------------+
10 rows in set (0.00 sec)
root@mysql 17:07:  [mytest]> select  134217728/1024/1024
    -> ;
+---------------------+
| 134217728/1024/1024 |
+---------------------+
|        128.00000000 |
+---------------------+
1 row in set (0.00 sec)
root@mysql 17:08:  [mytest]> set global innodb_buffer_pool_dump_now=on;
Query OK, 0 rows affected (0.00 sec)
#ll /data
-rw-r----- 1 mysql mysql       1869 Apr 16 17:12 ib_buffer_pool
root@mysql 17:14:  [mytest]> create tablespace ts1 add datafile 'ts1.ibd' engine=innodb;
Query OK, 0 rows affected (0.39 sec)
root@mysql 17:23:  [mytest]> create table t8 (c1 int,primary key(c1)) tablespace ts1 ;
Query OK, 0 rows affected (0.64 sec)
root@mysql 17:23:  [mytest]> show create table t8;
+-------+----------------------------------------------------------------------------------------------------------------------------------------+
| Table | Create Table                                                                                                                           |
+-------+----------------------------------------------------------------------------------------------------------------------------------------+
| t8    | CREATE TABLE t8 (
  c1 int(11) NOT NULL,
  PRIMARY KEY (c1)
) /*!50100 TABLESPACE ts1 */ ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 |
+-------+----------------------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)
```
## 密码有效期
```
root@mysql 15:17:  [mytest]>  show variables like 'default_password_lifetime';
+---------------------------+-------+
| Variable_name             | Value |
+---------------------------+-------+
| default_password_lifetime | 0     |
+---------------------------+-------+
1 row in set (0.00 sec)
```
## numa
```
[root@centos ~]# numactl --hardware
available: 1 nodes (0)
node 0 cpus: 0 1
node 0 size: 4095 MB
node 0 free: 2645 MB
node distances:
node   0
  0:  10
```
## innodb buffer pool hit rate
```
That's the Hit Rate since Uptime (Last MySQL Startup)
There are two things you can do to get the Last 10 Minutes

//METHOD #1
Flush all Status Values, Sleep 10 min, Run Query
FLUSH STATUS;SELECT SLEEP(600) INTO @x;SELECT round ((P2.variable_value / P1.variable_value),4),
P2.variable_value, P1.variable_value
FROM information_schema.GLOBAL_STATUS P1,
information_schema.GLOBAL_STATUS P2
WHERE P1. variable_name = 'innodb_buffer_pool_read_requests'AND P2. variable_name = 'innodb_buffer_pool_reads';

//METHOD #2
Capture innodb_buffer_pool_read_requests, innodb_buffer_pool_reads, Sleep 10 minutes, Run Query with Differences in innodb_buffer_pool_read_requests and innodb_buffer_pool_reads
SELECT
P1.variable_value,P2.variable_value
INTO
@rqs,@rds
FROM information_schema.GLOBAL_STATUS P1,
information_schema.GLOBAL_STATUS P2
WHERE P1.variable_name = 'innodb_buffer_pool_read_requests'AND P2.variable_name = 'innodb_buffer_pool_reads';
SELECT SLEEP(600) INTO @x;SELECT round (((P2.variable_value - @rds) / (P1.variable_value - @rqs)),4),
P2.variable_value, P1.variable_value
FROM information_schema.GLOBAL_STATUS P1,
information_schema.GLOBAL_STATUS P2
WHERE P1.variable_name = 'innodb_buffer_pool_read_requests'AND P2.variable_name = 'innodb_buffer_pool_reads';
```
## 验证唯一性
Oracle null可以多个
mysql  null只能一个
## mysql 5.7.22新特性
oracle mysql 5.7.22，去掉--flush-logs，只使用mysqldump -uroot -proot --default-character-set=utf8  --single-transaction --master-data=2 备份，也是会发出FLUSH TABLES WITH READ LOCK 
## 今日讨论，你都用了什么方法防止误删数据？
```
根据白天大家的讨论，总结共有以下几个措施，供参考：
1. 生产环境中，业务代码尽量不明文保存数据库连接账号密码信息；
2. 重要的DML、DDL通过平台型工具自动实施，减少人工操作；
3. 部署延迟复制从库，万一误删除时用于数据回档。且从库设置为read-only；
4. 确认备份制度及时有效；
5. 启用SQL审计功能，养成良好SQL习惯；
6. 启用 sql_safe_updates 选项，不允许没 WHERE 条件的更新/删除；
7. 将系统层的 rm 改为 mv；
8. 线上不进行物理删除，改为逻辑删除（将row data标记为不可用）；
9. 启用堡垒机，屏蔽高危SQL；
10. 降低数据库中普通账号的权限级别；
11. 务必开启binlog。
```
