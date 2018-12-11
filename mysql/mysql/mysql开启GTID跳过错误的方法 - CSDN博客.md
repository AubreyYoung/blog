# mysql开启GTID跳过错误的方法 - CSDN博客

# mysql开启GTID跳过错误的方法

原创  2017年04月21日 17:58:55

  * 
.

1、数据库版本

mysql> select version()  
-> ;  
+-------------------------------------------+  
| version() |  
+-------------------------------------------+  
| 5.7.17 |  
+-------------------------------------------+  
1 row in set (0.00 sec)  

  

\--主从同步

10.10.6.87 主

10.10.90 从

  

**2、产生问题过程**

（1）主从库开启了GTID模式

（2）在从库某表添加了唯一索引，然后去主库给某表添加索引，导致问题 （此处为了测试，故意为之，制造问题）

'Duplicate key name 'i_index'' on query. Default database: 'test'. Query:
'create unique index i_index on t(id)'  
（3） 查看从库状态，发现Slave_SQL_Running: No  
mysql> show slave status \G;  
*************************** 1. row ***************************  
Slave_IO_State: Waiting for master to send event  
Master_Host: 10.10.6.87  
Master_User: rep  
Master_Port: 3306  
Connect_Retry: 60  
Master_Log_File: mysql-bin.000028  
Read_Master_Log_Pos: 1113  
Relay_Log_File: mysql-bin.000007  
Relay_Log_Pos: 1151  
Relay_Master_Log_File: mysql-bin.000028  
Slave_IO_Running: Yes  
Slave_SQL_Running: No  
Replicate_Do_DB:  
Replicate_Ignore_DB: mysql,information_schema  
Replicate_Do_Table:  
Replicate_Ignore_Table:  
Replicate_Wild_Do_Table:  
Replicate_Wild_Ignore_Table:  
Last_Errno: 1061  
Last_Error: Error 'Duplicate key name 'i_index'' on query. Default database:
'test'. Query: 'create unique index i_index on t(id)'  
Skip_Counter: 0  
Exec_Master_Log_Pos: 938  
Relay_Log_Space: 2301  
Until_Condition: None  
Until_Log_File:  
Until_Log_Pos: 0  
Master_SSL_Allowed: No  
Master_SSL_CA_File:  
Master_SSL_CA_Path:  
Master_SSL_Cert:  
Master_SSL_Cipher:  
Master_SSL_Key:  
Seconds_Behind_Master: NULL  
Master_SSL_Verify_Server_Cert: No  
Last_IO_Errno: 0  
Last_IO_Error:  
Last_SQL_Errno: 1061  
Last_SQL_Error: Error 'Duplicate key name 'i_index'' on query. Default
database: 'test'. Query: 'create unique index i_index on t(id)'  
Replicate_Ignore_Server_Ids:  
Master_Server_Id: 2  
Master_UUID: 8f9e146f-0a18-11e7-810a-0050568833c8  
Master_Info_File: /var/lib/mysql/master.info  
SQL_Delay: 0 #SQL延迟同步  
SQL_Remaining_Delay: NULL  
Slave_SQL_Running_State:  
Master_Retry_Count: 86400  
Master_Bind:  
Last_IO_Error_Timestamp:  
Last_SQL_Error_Timestamp: 170421 15:44:05  
Master_SSL_Crl:  
Master_SSL_Crlpath:  
Retrieved_Gtid_Set: 8f9e146f-0a18-11e7-810a-0050568833c8:1-4  
Executed_Gtid_Set: 8f9e146f-0a18-11e7-810a-0050568833c8:1-3,
#多出了一个GTID(本身实例执行的事务)  
f7c86e19-24fe-11e7-a66c-005056884f03:1-9  
Auto_Position: 0  
Replicate_Rewrite_DB:  
Channel_Name:  
Master_TLS_Version:  
1 row in set (0.00 sec)  
  
  
ERROR:  
No query specified  
  
  
 **3、解决问题过程：**  
  
mysql > stop slave sql_thread;  
Query OK, 0 rows affected, 1 warning (0.00 sec)  
  
  
mysql> set global sql_slave_skip_counter=1;  
ERROR 1858 (HY000): sql_slave_skip_counter can not be set when the server is
running with @@GLOBAL.GTID_MODE = ON. Instead, for each transaction that you
want to skip, generate an empty transaction with the same GTID as the
transaction  
mysql> stop slave;  
Query OK, 0 rows affected (0.01 sec)  
  
  
mysql> set global sql_slave_skip_counter=1;  
ERROR 1858 (HY000): sql_slave_skip_counter can not be set when the server is
running with @@GLOBAL.GTID_MODE = ON. Instead, for each transaction that you
want to skip, generate an empty transaction with the same GTID as the
transaction  
  
  
从上面可以发现按照往常解决办法，是行不通的，因为开启了GTID原因  
  
  
  
  
3.1 分析出现问题时候GTID值  

通过分析法获取gtid值

通过查看mysql> show slave status \G;  

查看一下信息并记录下来:  
Retrieved_Gtid_Set: 8f9e146f-0a18-11e7-810a-0050568833c8:1-4 --跳过此事务  
Executed_Gtid_Set:
8f9e146f-0a18-11e7-810a-0050568833c8:1-3,f7c86e19-24fe-11e7-a66c-005056884f03:1-9  

  

通过上面的信息可以知道已经执行的gtid是8f9e146f-0a18-11e7-810a-0050568833c8:1-3,准备要执行8f9e146f-0a18-11e7-810a-0050568833c8:4的时候出问题了，所以条跳过此步骤

  
  
  
或者 通过日志查看 （推荐）  
  
  
#170421 15:36:28 server id 2 end_log_pos 938 CRC32 0x9f9f38d8  Xid = 140  
COMMIT/*!*/;  
# at 938  
#170421 15:39:10 server id 2 end_log_pos 1003 CRC32 0x20f00692  GTID
last_committed=3sequence_number=4  
SET @@SESSION.GTID_NEXT= '8f9e146f-0a18-11e7-810a-0050568833c8:4'/*!*/;  
# at 1003  
#170421 15:39:10 server id 2 end_log_pos 1113 CRC32 0x4b10f015  Query
thread_id=25420exec_time=0error_code=0  
use `test`/*!*/;  
SET TIMESTAMP=1492760350/*!*/;  
create unique index i_index on t(id)  
/*!*/;  
SET @@SESSION.GTID_NEXT= 'AUTOMATIC' /* added by mysqlbinlog */ /*!*/;  
DELIMITER ;  
# End of log file  
/*!50003 SET COMPLETION_TYPE=@OLD_COMPLETION_TYPE*/;  
/*!50530 SET @@SESSION.PSEUDO_SLAVE_MODE=0*/;  

  

**解决办法一：跳过错误**

(1)停止slave进程  

mysql> STOP SLAVE;

(2)设置事务号，事务号从Retrieved_Gtid_Set获取  

在session里设置gtid_next，即跳过这个GTID  

mysql> SET @@SESSION.GTID_NEXT= '8f9e146f-0a18-11e7-810a-0050568833c8:4'

（3）设置空事物  

mysql> BEGIN; COMMIT;

（4）恢复事物号

mysql> SET SESSION GTID_NEXT = AUTOMATIC;

(5)启动slave进程  

mysql> START SLAVE;

**解决办法二：重置master方法跳过错误**  
  
  
mysql > STOP SLAVE;  
mysql> RESET MASTER;  
mysql> SET @@GLOBAL.GTID_PURGED ='8f9e146f-0a18-11e7-810a-0050568833c8:1-4'  
mysql> START SLAVE;  
  
  
上面这些命令的用意是，忽略8f9e146f-0a18-11e7-810a-0050568833c8:1-4 这个GTID事务，下一次事务接着从 5
这个GTID开始，即可跳过上述错误。  
  

****解决办法三：** 使用pt-slave-restart工具  
**  
  
pt-slave-restart工具的作用是监视某些特定的复制错误，然后忽略，并且再次启动SLAVE进程（Watch and restart MySQL
replication after errors）。  
忽略所有1062错误，并再次启动SLAVE进程  
[root@dgt mysql]# pt-slave-resetart -S /var/lib/mysql/mysql.sock —error-
numbers=1062  
  
  
检查到错误信息只要包含 test.t1，就一概忽略，并再次启动 SLAVE 进程  
[root@dgt mysql]# pt-slave-resetart -S /var/lib/mysql/mysql.sock —error-
text=”test.t1”  
  
  
下面举例解决错误问题号  
Last_SQL_Error: Could not execute Delete_rows event on table test.t; Can't
find record in 't', Error_code: 1032; handler error HA_ERR_KEY_NOT_FOUND; the
event's master log mysql-bin.000028, end_log_pos 1862  
Replicate_Ignore_Server_Ids:  
Master_Server_Id: 2  
Master_UUID: 8f9e146f-0a18-11e7-810a-0050568833c8  
Master_Info_File: /var/lib/mysql/master.info  
SQL_Delay: 0  
SQL_Remaining_Delay: NULL  
Slave_SQL_Running_State:  
Master_Retry_Count: 86400  
Master_Bind:  
Last_IO_Error_Timestamp:  
Last_SQL_Error_Timestamp: 170421 17:45:11  
Master_SSL_Crl:  
Master_SSL_Crlpath:  
Retrieved_Gtid_Set: 8f9e146f-0a18-11e7-810a-0050568833c8:1-7  
Executed_Gtid_Set: 8f9e146f-0a18-11e7-810a-0050568833c8:1-6,  
f7c86e19-24fe-11e7-a66c-005056884f03:1  
Auto_Position: 0  
Replicate_Rewrite_DB:  
Channel_Name:  
Master_TLS_Version:  
1 row in set (0.00 sec)  
  
  
[root@dgt mysql]# pt-slave-restart -S /var/lib/mysql/mysql.sock --error-
numbers=1032 --user=root --password='bc.123456'  
2017-04-21T17:53:27 S=/var/lib/mysql/mysql.sock,p=...,u=root mysql-bin.000015
620 1032  
2017-04-21T17:54:31 S=/var/lib/mysql/mysql.sock,p=...,u=root mysql-bin.000015
1140 1032  
  
  
  
  
**参数解释：**  
\--slave-password=s Sets the password to be used to connect to the slaves  
\--slave-user=s Sets the user to be used to connect to the slaves  
\--sleep=i Initial sleep seconds between checking the slave ( default 1)  
\--socket=s -S Socket file to use for connection=  
\--password=s -p Password to use when connecting  
pt-slave-resetart -S./mysql.sock —error-numbers=1032  
\--error-numbers=h Only restart this comma-separated list of errors  
\--host=s -h Connect to host  
\--user=s -u User for login if not current user  

  
  


---
### NOTE ATTRIBUTES
>Created Date: 2018-04-13 08:03:50  
>Last Evernote Update Date: 2018-10-01 15:35:37  
>source: web.clip7  
>source-url: https://blog.csdn.net/wll_1017/article/details/70332107  
>source-application: WebClipper 7  