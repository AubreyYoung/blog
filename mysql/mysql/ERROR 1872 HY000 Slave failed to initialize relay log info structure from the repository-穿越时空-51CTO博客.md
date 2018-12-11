# ERROR 1872 (HY000): Slave failed to initialize relay log info structure from
the repository-穿越时空-51CTO博客

  

[穿越时空](http://blog.51cto.com/gfsunny) _>_ 正文

# ERROR 1872 (HY000): Slave failed to initialize relay log info structure from
the repository

原创 [gfsunny](http://blog.51cto.com/gfsunny) 2015-06-26 10:02:04
[评论(0)](http://blog.51cto.com/gfsunny/1665813#comment) 765人阅读

该问题的一般是由relay log没有在配置文件定义所致。  

1、问题描述：

mysql> start slave;

ERROR 1872 (HY000): Slave failed to initialize relay log info structure from
the repository

mysql> system perror 1872

MySQL error code 1872 (ER_SLAVE_RLI_INIT_REPOSITORY): Slave failed to
initialize relay log info structure from the repository

2、处理办法  
2.1、修改配置文件

诸如在my.cnf配置文件中添加如下项：  

relay_log = /opt/mysql/logs/mysql-relay-bin

重启mysql实例使其生效。  

2.2、重新连接master

mysql> stop slave;

Query OK, 0 rows affected, 1 warning (0.00 sec)

  

mysql> change master to
master_host='192.168.2.10',master_user='repl_user',master_password='123456',master_log_file='mysql-
bin.000002',master_log_pos=821301;

Query OK, 0 rows affected, 2 warnings (0.00 sec)

  

mysql> start slave;

ERROR 1872 (HY000): Slave failed to initialize relay log info structure from
the repository

重新连接后问题依旧。  

2.3、重新设置slave

mysql> reset slave;

Query OK, 0 rows affected (0.00 sec)

  

mysql> change master to
master_host='192.168.2.10',master_user='repl_user',master_password='123456',master_log_file='mysql-
bin.000002',master_log_pos=821301;

Query OK, 0 rows affected, 2 warnings (0.02 sec)

  

mysql> start slave;

Query OK, 0 rows affected (0.12 sec)

再次查看slave状态：  

mysql> show slave status\G;

*************************** 1. row ***************************

Slave_IO_State: Waiting for master to send event

Master_Host: 192.168.2.10

Master_User: repl_user

Master_Port: 3306

Connect_Retry: 60

Master_Log_File: mysql-bin.000002

Read_Master_Log_Pos: 824989

Relay_Log_File: mysql-relay-bin.000002

Relay_Log_Pos: 3971

Relay_Master_Log_File: mysql-bin.000002

Slave_IO_Running: Yes

Slave_SQL_Running: Yes

.......

问题解决。  

版权声明：原创作品，如需转载，请注明出处。否则将追究法律责任

[MySQL error code
187](http://blog.51cto.com/search/result?q=MySQL+error+code+187)

0

分享

收藏

[上一篇：MySQL 获得当前日期时间 函数](http://blog.51cto.com/gfsunny/1665616 "MySQL 获得当前日期时间
函数") [下一篇：我的友情链接](http://blog.51cto.com/gfsunny/2002784 "我的友情链接")

  



---
### TAGS
{reset slave}

---
### NOTE ATTRIBUTES
>Created Date: 2018-03-30 01:35:32  
>Last Evernote Update Date: 2018-10-01 15:35:37  
>author: YangKwong  
>source: web.clip  
>source-url: http://blog.51cto.com/gfsunny/1665813  