# MySQL5.7.19 - 在线变更复制方式 - 从日志 - 到事务 - 李鑫磊的专栏 - SegmentFault 思否

# 【第一部分】 Master - Lebron - 192.168.1.122

### 检查Master版本是否大于5.7.6

    
    
    mysql> show variables like 'version';
    +---------------+------------+
    | Variable_name | Value      |
    +---------------+------------+
    | version       | 5.7.19-log |
    +---------------+------------+
    1 row in set (0.00 sec)

### 检查Master的gtid_mode是否为off

    
    
    mysql> show variables like 'gtid_mode';
    +---------------+-------+
    | Variable_name | Value |
    +---------------+-------+
    | gtid_mode     | OFF   |
    +---------------+-------+
    1 row in set (0.00 sec)

### 第一步

    
    
    mysql> set @@global.enforce_gtid_consistency=warn;
    Query OK, 0 rows affected (0.00 sec)

  * 退出mysql，查看错误日志，确保没有错误

    
    
    mysql> quit
    Bye
    [root@lebron sysconfig]# tail -f /var/log/mysqld.log
    Version: '5.7.19-log'  socket: '/var/lib/mysql/mysql.sock'  port: 3306  MySQL Community Server (GPL)
    2017-12-10T15:29:40.557075Z 0 [Note] Executing 'SELECT * FROM INFORMATION_SCHEMA.TABLES;' to get a list of tables using the deprecated partition engine. You may use the startup option '--disable-partition-engine-check' to skip this check. 
    2017-12-10T15:29:40.557077Z 0 [Note] Beginning of list of non-natively partitioned tables
    2017-12-10T15:29:40.564129Z 0 [Note] End of list of non-natively partitioned tables
    2017-12-10T15:29:41.171276Z 3 [Note] Access denied for user 'UNKNOWN_MYSQL_USER'@'localhost' (using password: NO)
    2017-12-10T17:20:10.601941Z 6 [Warning] IP address '192.168.1.123' could not be resolved: Name or service not known
    2017-12-10T17:34:27.796701Z 10 [Note] Start binlog_dump to master_thread_id(10) slave_server(100), pos(mysql-bin.000001, 154)
    2017-12-10T17:39:27.813157Z 11 [Note] While initializing dump thread for slave with UUID <a41e6957-dc02-11e7-a9aa-0800271c6805>, found a zombie dump thread with the same UUID. Master is killing the zombie dump thread(10).
    2017-12-10T17:39:27.813305Z 11 [Note] Start binlog_dump to master_thread_id(11) slave_server(100), pos(mysql-bin.000001, 154)
    2017-12-10T19:01:14.798790Z 12 [Note] Changed ENFORCE_GTID_CONSISTENCY from OFF to WARN.

### 第二步

    
    
    mysql> set @@global.enforce_gtid_consistency=on;
    Query OK, 0 rows affected (0.00 sec)

### 第三步

    
    
    mysql> set @@global.gtid_mode=off_permissive;
    Query OK, 0 rows affected (0.02 sec)

  * 退出mysql，查看错误日志，确保没有错误

    
    
    mysql> quit
    Bye
    [root@lebron sysconfig]# tail -f /var/log/mysqld.log
    2017-12-10T15:29:40.557077Z 0 [Note] Beginning of list of non-natively partitioned tables
    2017-12-10T15:29:40.564129Z 0 [Note] End of list of non-natively partitioned tables
    2017-12-10T15:29:41.171276Z 3 [Note] Access denied for user 'UNKNOWN_MYSQL_USER'@'localhost' (using password: NO)
    2017-12-10T17:20:10.601941Z 6 [Warning] IP address '192.168.1.123' could not be resolved: Name or service not known
    2017-12-10T17:34:27.796701Z 10 [Note] Start binlog_dump to master_thread_id(10) slave_server(100), pos(mysql-bin.000001, 154)
    2017-12-10T17:39:27.813157Z 11 [Note] While initializing dump thread for slave with UUID <a41e6957-dc02-11e7-a9aa-0800271c6805>, found a zombie dump thread with the same UUID. Master is killing the zombie dump thread(10).
    2017-12-10T17:39:27.813305Z 11 [Note] Start binlog_dump to master_thread_id(11) slave_server(100), pos(mysql-bin.000001, 154)
    2017-12-10T19:01:14.798790Z 12 [Note] Changed ENFORCE_GTID_CONSISTENCY from OFF to WARN.
    2017-12-10T19:05:50.369256Z 13 [Note] Changed ENFORCE_GTID_CONSISTENCY from WARN to ON.
    2017-12-10T19:09:01.626528Z 13 [Note] Changed GTID_MODE from OFF to OFF_PERMISSIVE.

### 第四步

    
    
    mysql> set @@global.gtid_mode=on_permissive;
    Query OK, 0 rows affected (0.02 sec)

  * 查看设置结果

    
    
    mysql> show variables like 'gtid_mode';
    +---------------+---------------+
    | Variable_name | Value         |
    +---------------+---------------+
    | gtid_mode     | ON_PERMISSIVE |
    +---------------+---------------+
    1 row in set (0.00 sec)

### 第五步 - Master无操作，Slave上确认基于日志的复制是否都已完成

### 第六步

    
    
    mysql> set @@global.gtid_mode=on;
    Query OK, 0 rows affected (0.02 sec)

### 第七 ~ 十步 - Master上无操作

# 【第二部分】 Slave - Kyrie - 192.168.1.123

### 检查Slave版本是否大于5.7.6

    
    
    mysql> show variables like 'version';
    +---------------+------------+
    | Variable_name | Value      |
    +---------------+------------+
    | version       | 5.7.19-log |
    +---------------+------------+
    1 row in set (0.00 sec)

### 检查Slave的gtid_mode是否为off

    
    
    mysql> show variables like 'gtid_mode';
    +---------------+-------+
    | Variable_name | Value |
    +---------------+-------+
    | gtid_mode     | OFF   |
    +---------------+-------+
    1 row in set (0.00 sec)

### 第一步

    
    
    mysql> set @@global.enforce_gtid_consistency=warn;
    Query OK, 0 rows affected (0.00 sec)

### 第二步

    
    
    mysql> set @@global.enforce_gtid_consistency=on;
    Query OK, 0 rows affected (0.00 sec)

### 第三步

    
    
    mysql> set @@global.gtid_mode=off_permissive;
    Query OK, 0 rows affected (0.02 sec)

  * 退出mysql，查看错误日志，确保没有错误

    
    
    mysql> quit
    Bye
    [root@lebron sysconfig]# tail -f /var/log/mysqld.log
    2017-12-10T15:29:40.557077Z 0 [Note] Beginning of list of non-natively partitioned tables
    2017-12-10T15:29:40.564129Z 0 [Note] End of list of non-natively partitioned tables
    2017-12-10T15:29:41.171276Z 3 [Note] Access denied for user 'UNKNOWN_MYSQL_USER'@'localhost' (using password: NO)
    2017-12-10T17:20:10.601941Z 6 [Warning] IP address '192.168.1.123' could not be resolved: Name or service not known
    2017-12-10T17:34:27.796701Z 10 [Note] Start binlog_dump to master_thread_id(10) slave_server(100), pos(mysql-bin.000001, 154)
    2017-12-10T17:39:27.813157Z 11 [Note] While initializing dump thread for slave with UUID <a41e6957-dc02-11e7-a9aa-0800271c6805>, found a zombie dump thread with the same UUID. Master is killing the zombie dump thread(10).
    2017-12-10T17:39:27.813305Z 11 [Note] Start binlog_dump to master_thread_id(11) slave_server(100), pos(mysql-bin.000001, 154)
    2017-12-10T19:01:14.798790Z 12 [Note] Changed ENFORCE_GTID_CONSISTENCY from OFF to WARN.
    2017-12-10T19:05:50.369256Z 13 [Note] Changed ENFORCE_GTID_CONSISTENCY from WARN to ON.
    2017-12-10T19:09:01.626528Z 13 [Note] Changed GTID_MODE from OFF to OFF_PERMISSIVE.

### 第四步

    
    
    mysql> set @@global.gtid_mode=on_permissive;
    Query OK, 0 rows affected (0.02 sec)

  * 查看设置结果

    
    
    mysql> show variables like 'gtid_mode';
    +---------------+---------------+
    | Variable_name | Value         |
    +---------------+---------------+
    | gtid_mode     | ON_PERMISSIVE |
    +---------------+---------------+
    1 row in set (0.00 sec)

### 第五步 - 检查Master的数据是否都同步到Slave上了，Empty表示都同步了

  * 匿名复制，即所有非gtid的复制，即基于日志的复制;
  * 如果结果非空，要等到结果为空才能继续操作;

    
    
    mysql> show status like 'ongoing_anonymouse_transaction_count';
    Empty set (0.00 sec)

### 第六步

    
    
    mysql> set @@global.gtid_mode=on;
    Query OK, 0 rows affected (0.02 sec)

### 第七步

    
    
    mysql> stop slave;
    Query OK, 0 rows affected (0.01 sec)

### 第八步

    
    
    mysql> change master to master_auto_position=1;
    Query OK, 0 rows affected (0.01 sec)

### 第九步

    
    
    mysql> start slave;
    Query OK, 0 rows affected (0.01 sec)

### 第十步

  * 当主从间发生同步后，Retrieved_Gtid_Set & Executed_Gtid_Set才有值；

    
    
    mysql> show slave status\G;
    *************************** 1. row ***************************
                   Slave_IO_State: Waiting for master to send event
                      Master_Host: 192.168.1.122
                      Master_User: lxl
                      Master_Port: 3306
                    Connect_Retry: 60
                  Master_Log_File: mysql-bin.000004
              Read_Master_Log_Pos: 420
                   Relay_Log_File: lebron-relay-bin.000002
                    Relay_Log_Pos: 633
            Relay_Master_Log_File: mysql-bin.000004
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
              Exec_Master_Log_Pos: 420
                  Relay_Log_Space: 841
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
                 Master_Server_Id: 1
                      Master_UUID: a41e6957-dc02-11e7-a9aa-0800271c6804
                 Master_Info_File: /var/lib/mysql/master.info
                        SQL_Delay: 0
              SQL_Remaining_Delay: NULL
          Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
               Master_Retry_Count: 86400
                      Master_Bind: 
          Last_IO_Error_Timestamp: 
         Last_SQL_Error_Timestamp: 
                   Master_SSL_Crl: 
               Master_SSL_Crlpath: 
               Retrieved_Gtid_Set: a41e6957-dc02-11e7-a9aa-0800271c6804:1
                Executed_Gtid_Set: a41e6957-dc02-11e7-a9aa-0800271c6804:1
                    Auto_Position: 1
             Replicate_Rewrite_DB: 
                     Channel_Name: 
               Master_TLS_Version: 
    1 row in set (0.00 sec)
    
    ERROR: 
    No query specified

### 注意

global.enforce_gtid_consistency=on &
global.gtid_mode=on设置到my.cnf中，下次启动服务的时候就是gtid的方式完成复制。


---
### NOTE ATTRIBUTES
>Created Date: 2018-04-17 07:07:11  
>Last Evernote Update Date: 2018-10-01 15:35:37  
>source: web.clip7  
>source-url: https://segmentfault.com/a/1190000012367138  
>source-application: WebClipper 7  