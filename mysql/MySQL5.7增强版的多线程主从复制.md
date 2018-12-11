## MySQL5.7增强版的多线程主从复制

MySQL多线程主从复制不是5.7版本中的新鲜产物，这个特性在5.6版本中就已经提供。但是在5.7版本中给多线程主从复制的特性做了增强

- 在MySQL5.6版本中的多线程复制，前提是一个线程只针对一个库
- 在MySQL5.7版本中，一个库可以使用多个线程同步，可以认为MySQL5.7的多线程复制是基于表的

## 多线程复制的配置

根据MySQL复制原理，可以知道，多线程复制只需要修改slave端即可

## 检查系统当前多线程复制的参数

```
mysql> show variables like 'slave_parallel%';
+------------------------+----------+
| Variable_name          | Value    |
+------------------------+----------+
| slave_parallel_type    | DATABASE |
| slave_parallel_workers | 0        |
+------------------------+----------+
2 rows in set (0.01 sec)

mysql>
```

从上面的查询结果上来看，slave默认的多线程复制类型是基于数据库的，也就是一个数据库对应一个线程；而多线程复制的线程数量为0，意为单进程复制

## 设置多线程复制

```
mysql> stop slave;
Query OK, 0 rows affected (0.05 sec)

mysql> set global slave_parallel_type='logical_clock';
Query OK, 0 rows affected (0.00 sec)

mysql> set global slave_parallel_workers=8;
Query OK, 0 rows affected (0.00 sec)

mysql> start slave;
Query OK, 0 rows affected (0.18 sec)

mysql>
```

## 查看复制线程

```
mysql> show processlist;
+----+-----------------+-----------+------+---------+--------+--------------------------------------------------------+------------------+
| Id | User            | Host      | db   | Command | Time   | State                                                  | Info             |
+----+-----------------+-----------+------+---------+--------+--------------------------------------------------------+------------------+
|  1 | event_scheduler | localhost | NULL | Daemon  | 141366 | Waiting on empty queue                                 | NULL             |
| 13 | root            | localhost | NULL | Query   |      0 | starting                                               | show processlist |
| 14 | system user     |           | NULL | Connect |     49 | Waiting for master to send event                       | NULL             |
| 15 | system user     |           | NULL | Connect |     48 | Slave has read all relay log; waiting for more updates | NULL             |
| 16 | system user     |           | NULL | Connect |     49 | Waiting for an event from Coordinator                  | NULL             |
| 17 | system user     |           | NULL | Connect |     49 | Waiting for an event from Coordinator                  | NULL             |
| 18 | system user     |           | NULL | Connect |     49 | Waiting for an event from Coordinator                  | NULL             |
| 19 | system user     |           | NULL | Connect |     49 | Waiting for an event from Coordinator                  | NULL             |
| 20 | system user     |           | NULL | Connect |     49 | Waiting for an event from Coordinator                  | NULL             |
| 21 | system user     |           | NULL | Connect |     49 | Waiting for an event from Coordinator                  | NULL             |
| 22 | system user     |           | NULL | Connect |     49 | Waiting for an event from Coordinator                  | NULL             |
| 23 | system user     |           | NULL | Connect |     49 | Waiting for an event from Coordinator                  | NULL             |
+----+-----------------+-----------+------+---------+--------+--------------------------------------------------------+------------------+
12 rows in set (0.00 sec)

mysql> show variables like 'slave_parallel%';
+------------------------+---------------+
| Variable_name          | Value         |
+------------------------+---------------+
| slave_parallel_type    | LOGICAL_CLOCK |
| slave_parallel_workers | 8             |
+------------------------+---------------+
2 rows in set (0.00 sec)

mysql>
```

*注：MySQL5.7支持多源复制，这里的多线程复制的意思是为每一个源分配的多线程。例如上面我设置了线程数量为8，那意为着每个channel复制源都会提供8个线程去复制，如果有两个channel，那么在processlist中将看到16个线程*

## 查看多线程复制相关的视图

```
mysql> show tables like 'replication%';
+---------------------------------------------+
| Tables_in_performance_schema (replication%) |
+---------------------------------------------+
| replication_applier_configuration           |
| replication_applier_status                  |
| replication_applier_status_by_coordinator   |
| replication_applier_status_by_worker        |
| replication_connection_configuration        |
| replication_connection_status               |
| replication_group_member_stats              |
| replication_group_members                   |
+---------------------------------------------+
8 rows in set (0.00 sec)
mysql> select * from replication_applier_status_by_coordinator;
+--------------+-----------+---------------+-------------------+--------------------+----------------------+
| CHANNEL_NAME | THREAD_ID | SERVICE_STATE | LAST_ERROR_NUMBER | LAST_ERROR_MESSAGE | LAST_ERROR_TIMESTAMP |
+--------------+-----------+---------------+-------------------+--------------------+----------------------+
| db153        |        40 | ON            |                 0 |                    | 0000-00-00 00:00:00  |
+--------------+-----------+---------------+-------------------+--------------------+----------------------+
1 row in set (0.00 sec)

mysql>
```

*注：由于MySQL5.7支持多源复制，那么这个复制的协调者replication_applier_status_by_coordinator会去协调每一个channel的复制线程*

```
mysql> select * from replication_applier_status_by_worker;
+--------------+-----------+-----------+---------------+-----------------------+-------------------+--------------------+----------------------+
| CHANNEL_NAME | WORKER_ID | THREAD_ID | SERVICE_STATE | LAST_SEEN_TRANSACTION | LAST_ERROR_NUMBER | LAST_ERROR_MESSAGE | LAST_ERROR_TIMESTAMP |
+--------------+-----------+-----------+---------------+-----------------------+-------------------+--------------------+----------------------+
| db153        |         1 |        41 | ON            |                       |                 0 |                    | 0000-00-00 00:00:00  |
| db153        |         2 |        42 | ON            |                       |                 0 |                    | 0000-00-00 00:00:00  |
| db153        |         3 |        43 | ON            |                       |                 0 |                    | 0000-00-00 00:00:00  |
| db153        |         4 |        44 | ON            |                       |                 0 |                    | 0000-00-00 00:00:00  |
| db153        |         5 |        45 | ON            |                       |                 0 |                    | 0000-00-00 00:00:00  |
| db153        |         6 |        46 | ON            |                       |                 0 |                    | 0000-00-00 00:00:00  |
| db153        |         7 |        47 | ON            |                       |                 0 |                    | 0000-00-00 00:00:00  |
| db153        |         8 |        48 | ON            |                       |                 0 |                    | 0000-00-00 00:00:00  |
+--------------+-----------+-----------+---------------+-----------------------+-------------------+--------------------+----------------------+
8 rows in set (0.00 sec)

mysql>
```

在这里可以清楚的看到，为`db153`这一个channel提供了8个复制线程，如果有两个channel的，这里将显示16行