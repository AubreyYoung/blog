## MySQL5.7离线更改为事务复制


从MySQL5.6版本开始，支持以事务的方式来做主从同步，最大限度的保证MySQL的主从一致性。实现这一复制特性的关键是GTID(Global Transaction Identifiers)全局事务ID，通过GTID来强化数据库的主从一致性，故障恢复以及容错能力
>
> MySQL5.7支持在线修改复制类型，MySQL5.6只能离线修改，本篇文章主要介绍离线修改复制类型的方法，后续的文章中会介绍如何在线更换复制类型

## 什么是GTID

官方文档：

- 5.6: <http://dev.mysql.com/doc/refman/5.6/en/replication-gtids.html>
- 5.7: <http://dev.mysql.com/doc/refman/5.7/en/replication-gtids.html>

A GTID is represented as a pair of coordinates, separated by a colon character (:), as shown here:

```
GTID = source_id:transaction_id
```

每一个 GTID 代表一个数据库事务。在上面的定义中，`source_id` 表示执行事务的主库 uuid（server_uuid），`transaction_id` 是一个从 1 开始的自增计数，表示在这个主库上执行的第 n 个事务。MySQL 会保证事务与 GTID 之间的 1 : 1 映射


## master配置

```
> vim /etc/my.cnf
# client的配置会被MySQL客户端应用读取
# 只有MySQL附带的客户端应用程序保证可以读取到这段内容
[client]
port = 3306
socket = /tmp/mysql.sock
# 生产环境中所使用的字符集推荐设置为utf8mb4
# 这里默认使用utf8，字符集的问题将有独立的文章介绍
default-character-set = utf8

# 客户端读取的配置文件
[mysql]
no-auto-rehash
# 生产环境中所使用的字符集推荐设置为utf8mb4
# 这里默认使用utf8，字符集的问题将有独立的文章介绍
default-character-set = utf8

# MySQL服务端读取的配置文件
[mysqld]
server-id = 10153  # 保证server-id的唯一性，这里采用了IP的后两位来保证唯一性
port = 3306 # MySQL服务监听的端口号
user = mysql # 以mysql用户来运行MySQL服务进程
basedir = /usr/local/mysql # MySQL服务的根目录（编译安装指定路径，yum安装注释掉即可）
datadir = /data/mysqldata # 数据目录
socket = /tmp/mysql.sock # socket文件所在的位置
default-storage-engine = INNODB # 默认的存储引擎
# 生产环境中所使用的字符集推荐设置为utf8mb4
# 这里默认使用utf8，字符集的问题将有独立的文章介绍
character-set-server = utf8
connect_timeout = 60 # 连接超时时间
interactive_timeout = 28800 # MySQL在关闭一个交互的连接之前所要等待的秒数(交互连接如mysql gui tool中的连接)
wait_timeout = 28800 # MySQL在关闭一个非交互的连接之前所要等待的秒数
back_log = 500 # 操作系统在监听队列中所能保持的连接数
event_scheduler = ON # 开启定时任务机制
skip_name_resolve = ON # 忽略IP方向解析

###########binlog##########
log-bin = /data/mysqlLog/logs/mysql-bin # 打开二进制日志功能
# 当设置隔离级别为READ-COMMITED必须设置二进制日志格式为ROW
# 现在MySQL官方认为STATEMENT这个已经不再适合继续使用
# 但mixed类型在默认的事务隔离级别下，可能会导致主从数据不一致
binlog_format = row # 复制模式为行级模式（复制模式的介绍可以参考本站关于复制基础的文章）
max_binlog_size = 128M # 每个二进制日志最大的文件大小
binlog_cache_size = 2M # 二进制日志缓存大小
expire-logs-days = 5 # 二进制日志的保存时间（保存最近5天的二进制日志）
# 将slave在master收到的更新记入到slave自己的二进制日志文件中
# 在MySQL级联复制中，这个参数必须打开（A=>B=>C）
log-slave-updates=true 

# 以下三个参数启用复制有关的所有校验功能
binlog_checksum = CRC32 # checksum使用zlib中的CRC-32算法
# 不仅dump thread会对event进行校验，当master上执行show binlog events的时候
# 也会对event进行校验
# 设置为1，可以保证event被完整无缺地写入到主服务器的binlog中了
master_verify_checksum = 1 
slave_sql_verify_checksum = 1 # 设置为1，slave上的IO Thread写入到Relay Log时和SQL Thread读取Relay Log时会对checksum进行验证

binlog_rows_query_log_events = 1 # 可用于在二进制日志记录事件相关的信息，可降低故障排除的复杂度

###### GTID事务复制支持部分 ######
gtid-mode=on # 开启全局事务ID
enforce-gtid-consistency=true # 开启强制全局事务ID一致性（用于启动GTID及满足附属的其它需求）

# 启用此两项，可用于实现在崩溃时保证二进制及从服务器安全的功能
master-info-repository=TABLE 
relay-log-info-repository=TABLE


sync-master-info=1 # 确保无信息丢失
slave-parallel-workers=4 # 设定从服务器的SQL线程数；0表示关闭多线程复制功能
# rpl_semi_sync_master_enabled = 1 # 半同步复制

# 慢SQL的相关配置
slow_query_log = 1
slow_query_log_file = /data/mysqlLog/logs/mysql.slow
long_query_time = 1
 
log_error = /data/mysqlLog/logs/error.log # 错误信息的配置
max_connections = 3000 # MySQL的最大连接数
max_connect_errors = 32767 # 某一客户端尝试连接此MySQL服务器，但是失败（如密码错误等等）32767次，则MySQL会无条件强制阻止此客户端连接
log_bin_trust_function_creators = 1 # 允许使用MySQL自定义函数
transaction_isolation = READ-COMMITTED # 设置事务隔离级别
```

## slave配置

```
> vim /etc/my.cnf
[client]
port = 3306
socket = /tmp/mysql.sock
default-character-set = utf8

[mysql]
no-auto-rehash
default-character-set = utf8

[mysqld]
server-id = 10157
port = 3306
user = mysql
basedir = /usr/local/mysql
datadir = /data/mysqldata
socket = /tmp/mysql.sock
default-storage-engine = INNODB
character-set-server = utf8
connect_timeout = 60
wait_timeout = 18000
back_log = 500
event_scheduler = ON
 
###########binlog##########
log-bin = /data/mysqlLog/logs/mysql-bin
binlog_format = row
max_binlog_size = 128M
binlog_cache_size = 2M
expire-logs-days = 5
log-slave-updates=true
gtid-mode=on 
enforce-gtid-consistency=true
master-info-repository=TABLE
relay-log-info-repository=TABLE
sync-master-info=1
slave-parallel-workers=4
# rpl_semi_sync_slave_enabled = 1
# skip-slave-start # slave复制进程不随mysql启动而启动

slow_query_log = 1
slow_query_log_file = /data/mysqlLog/logs/mysql.slow
long_query_time = 2

log-error = /data/mysqlLog/logs/error.log
max_connections = 3000
max_connect_errors = 10000
log_bin_trust_function_creators = 1
transaction_isolation = READ-COMMITTED
```

## 分别启动主库和从库

```
> systemctl restart mysqld
```

## 在主库中创建复制用户

```
mysql> SET GLOBAL validate_password_policy = LOW;
Query OK, 0 rows affected (0.00 sec)

mysql> create user 'repl' identified by '12345678';
Query OK, 0 rows affected (0.05 sec)

mysql> grant replication slave on *.* to repl@'%';
Query OK, 0 rows affected (0.02 sec)
```

## 查看主库与从库GTID状态

```
mysql> show variables like 'gtid_mode';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| gtid_mode     | ON    |
+---------------+-------+
1 row in set (0.01 sec)
```

## 在从库启动复制线程

```
mysql> change master to
    ->   master_host='192.168.10.153',
    ->   master_port=3306,
    ->   master_user='repl',
    ->   master_password='12345678',
    ->   master_auto_position=1 for channel "db153";
Query OK, 0 rows affected, 2 warnings (0.27 sec)

mysql> start slave for channel "db153";
Query OK, 0 rows affected (0.09 sec)

mysql> show slave status for channel "db153" \G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.10.153
                  Master_User: repl
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000001
          Read_Master_Log_Pos: 595
               Relay_Log_File: localhost-relay-bin-db153.000002
                Relay_Log_Pos: 808
        Relay_Master_Log_File: mysql-bin.000001
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB: 
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 595
              Relay_Log_Space: 1025
              Until_Condition: None
               Until_Log_File: 
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File: 
           Master_SSL_CA_Path: 
              Master_SSL_Cert: 
            Master_SSL_Cipher: 
               Master_SSL_Key: 
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error: 
               Last_SQL_Errno: 0
               Last_SQL_Error: 
  Replicate_Ignore_Server_Ids: 
             Master_Server_Id: 10153
                  Master_UUID: 1349d343-6611-11e6-b341-005056ad5f2f
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind: 
      Last_IO_Error_Timestamp: 
     Last_SQL_Error_Timestamp: 
               Master_SSL_Crl: 
           Master_SSL_Crlpath: 
           Retrieved_Gtid_Set: 1349d343-6611-11e6-b341-005056ad5f2f:1-2
            Executed_Gtid_Set: 1349d343-6611-11e6-b341-005056ad5f2f:1-2
                Auto_Position: 1
         Replicate_Rewrite_DB: 
                 Channel_Name: db153
           Master_TLS_Version: 
1 row in set (0.00 sec)

mysql>
```

## 验证主从同步

## master

```
mysql> show master status;
+------------------+----------+--------------+------------------+------------------------------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set                        |
+------------------+----------+--------------+------------------+------------------------------------------+
| mysql-bin.000001 |      595 |              |                  | 1349d343-6611-11e6-b341-005056ad5f2f:1-2 |
+------------------+----------+--------------+------------------+------------------------------------------+
1 row in set (0.00 sec)

mysql> create database polarsnow;
Query OK, 1 row affected (0.03 sec)

mysql> show master status;
+------------------+----------+--------------+------------------+------------------------------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set                        |
+------------------+----------+--------------+------------------+------------------------------------------+
| mysql-bin.000001 |      769 |              |                  | 1349d343-6611-11e6-b341-005056ad5f2f:1-3 |
+------------------+----------+--------------+------------------+------------------------------------------+
1 row in set (0.00 sec)

mysql>
```

## slave

```
mysql> show slave status for channel "db153"\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.10.153
                  Master_User: repl
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000001
          Read_Master_Log_Pos: 769
               Relay_Log_File: localhost-relay-bin-db153.000002
                Relay_Log_Pos: 982
        Relay_Master_Log_File: mysql-bin.000001
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB: 
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 769
              Relay_Log_Space: 1199
              Until_Condition: None
               Until_Log_File: 
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File: 
           Master_SSL_CA_Path: 
              Master_SSL_Cert: 
            Master_SSL_Cipher: 
               Master_SSL_Key: 
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error: 
               Last_SQL_Errno: 0
               Last_SQL_Error: 
  Replicate_Ignore_Server_Ids: 
             Master_Server_Id: 10153
                  Master_UUID: 1349d343-6611-11e6-b341-005056ad5f2f
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind: 
      Last_IO_Error_Timestamp: 
     Last_SQL_Error_Timestamp: 
               Master_SSL_Crl: 
           Master_SSL_Crlpath: 
           Retrieved_Gtid_Set: 1349d343-6611-11e6-b341-005056ad5f2f:1-3
            Executed_Gtid_Set: 1349d343-6611-11e6-b341-005056ad5f2f:1-3
                Auto_Position: 1
         Replicate_Rewrite_DB: 
                 Channel_Name: db153
           Master_TLS_Version: 
1 row in set (0.00 sec)

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| polarsnow          |
| sys                |
+--------------------+
5 rows in set (0.00 sec)

mysql>
```

至此，事务同步配置成功！

在之前使用二进制复制的主从模式时，经历了各种主从数据不一致的情况，而从MySQL5.6开始新引入的事务复制能否解决二进制bin-log复制的数据一致性的痛点还有待观察和检验……

## 附录

- MySQL5.7官方文档：<http://dev.mysql.com/doc/refman/5.7/en/>
- 参考文档：<http://www.cnblogs.com/darren-lee/p/5160802.html>

