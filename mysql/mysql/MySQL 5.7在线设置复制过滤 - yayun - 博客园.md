# MySQL 5.7在线设置复制过滤 - yayun - 博客园

#  [MySQL 5.7在线设置复制过滤](http://www.cnblogs.com/gomysql/p/4991197.html)

很久没有更新博客了，主要是公司事情比较多，最近终于闲下来了。然而5.7也GA了，有许多新的特性，其中现在可以进行在线设置复制过滤了。但是还是得停复制，不过不用重启实例了。方便了DBA们进行临时性的调整。下面就简单的测试一下。MySQL
5.7的安装有了很大的变化，我主要是安装的二进制版本。关于如何安装以及如何搭建好复制这种小事，相信聪明的你可以很快搞定。安装请参考<http://dev.mysql.com/doc/refman/5.7/en/binary-
installation.html>

下面进行复制过滤设置测试。

    
    
    mysql> show slave status\G
    *************************** 1. row ***************************
                   Slave_IO_State: Waiting for master to send event
                      Master_Host: 10.69.25.173
                      Master_User: repl
                      Master_Port: 3306
                    Connect_Retry: 60
                  Master_Log_File: mysql-bin.000001
              Read_Master_Log_Pos: 1902
                   Relay_Log_File: relaylog.000002
                    Relay_Log_Pos: 2068
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
              Exec_Master_Log_Pos: 1902

可以看见现在并没有复制过滤的设置，现在进行调整。设置只同步db1，db2这2个库。  
使用命令很简单：CHANGE REPLICATION FILTER REPLICATE_DO_DB = (db1, db2);

    
    
    mysql> CHANGE REPLICATION FILTER REPLICATE_DO_DB = (db1, db2);
    ERROR 3017 (HY000): This operation cannot be performed with a running slave sql thread; run STOP SLAVE SQL_THREAD first
    mysql> 

可以看见提示要先停止SQL线程。那就先停止SQL线程。

    
    
    mysql> STOP SLAVE SQL_THREAD;
    Query OK, 0 rows affected (0.01 sec)
    
    mysql> CHANGE REPLICATION FILTER REPLICATE_DO_DB = (db1, db2);
    Query OK, 0 rows affected (0.00 sec)

成功执行，我们再看看复制状态：

    
    
    mysql> show slave status\G
    *************************** 1. row ***************************
                   Slave_IO_State: Waiting for master to send event
                      Master_Host: 10.69.25.173
                      Master_User: repl
                      Master_Port: 3306
                    Connect_Retry: 60
                  Master_Log_File: mysql-bin.000001
              Read_Master_Log_Pos: 1902
                   Relay_Log_File: relaylog.000002
                    Relay_Log_Pos: 2068
            Relay_Master_Log_File: mysql-bin.000001
                 Slave_IO_Running: Yes
                Slave_SQL_Running: No
                  **Replicate_Do_DB: db1,db2**          Replicate_Ignore_DB: 
               Replicate_Do_Table: 
           Replicate_Ignore_Table: 
          Replicate_Wild_Do_Table: 
      Replicate_Wild_Ignore_Table: 
                       Last_Errno:  0

可以看见已经成功设置只同步db1，db2库，设置完成开启SQL线程就完事。

那么我们要是又要全部的库都要同步该如何操作呢，也很简单。

    
    
    mysql> STOP SLAVE SQL_THREAD;
    Query OK, 0 rows affected (0.00 sec)
    
    mysql> CHANGE REPLICATION FILTER REPLICATE_DO_DB = ();
    Query OK, 0 rows affected (0.00 sec)
    
    mysql> start SLAVE SQL_THREAD;
    Query OK, 0 rows affected (0.00 sec)
    
    mysql> show slave status\G
    *************************** 1. row ***************************
                   Slave_IO_State: Waiting for master to send event
                      Master_Host: 10.69.25.173
                      Master_User: repl
                      Master_Port: 3306
                    Connect_Retry: 60
                  Master_Log_File: mysql-bin.000001
              Read_Master_Log_Pos: 1902
                   Relay_Log_File: relaylog.000002
                    Relay_Log_Pos: 2068
            Relay_Master_Log_File: mysql-bin.000001
                 Slave_IO_Running: Yes
                Slave_SQL_Running: Yes
                  Replicate_Do_DB: 
              Replicate_Ignore_DB: 
               Replicate_Do_Table: 
           Replicate_Ignore_Table: 
          Replicate_Wild_Do_Table: 
      Replicate_Wild_Ignore_Table: 

可以看见又没有过滤了。又全部同步所有的库了。重点命令就是

    
    
    CHANGE REPLICATION FILTER REPLICATE_DO_DB = ();

我们同样可以可以设置只同步某个库下面的某张表，或者不同步某个库下面的某张表。看命令。

    
    
    mysql> STOP SLAVE SQL_THREAD; 
    Query OK, 0 rows affected (0.00 sec)
    
    mysql> CHANGE REPLICATION FILTER
        -> REPLICATE_WILD_DO_TABLE = ('db1.t1%'),
        -> REPLICATE_WILD_IGNORE_TABLE =  ('db1.t2%');
    Query OK, 0 rows affected (0.00 sec)
    
    mysql> show slave status\G
    *************************** 1. row ***************************
                   Slave_IO_State: Waiting for master to send event
                      Master_Host: 10.69.25.173
                      Master_User: repl
                      Master_Port: 3306
                    Connect_Retry: 60
                  Master_Log_File: mysql-bin.000001
              Read_Master_Log_Pos: 1902
                   Relay_Log_File: relaylog.000002
                    Relay_Log_Pos: 2068
            Relay_Master_Log_File: mysql-bin.000001
                 Slave_IO_Running: Yes
                Slave_SQL_Running: No
                  Replicate_Do_DB: 
              Replicate_Ignore_DB: 
               Replicate_Do_Table: 
           Replicate_Ignore_Table: 
          Replicate_Wild_Do_Table: db1.t1%
      Replicate_Wild_Ignore_Table: db1.t2%

可以看见我已经设置同步db1下面以t1开头的表。忽略了db1下面t2开头的表。  
重点的命令就是：

    
    
    CHANGE REPLICATION FILTER
    REPLICATE_WILD_DO_TABLE = ('db1.t1%'),
    REPLICATE_WILD_IGNORE_TABLE =  ('db1.t2%');

如果我们要设置同时同步1个库下面的某些表可以这样写：

    
    
    mysql> STOP SLAVE SQL_THREAD;
    Query OK, 0 rows affected (0.00 sec)
    
    mysql> CHANGE REPLICATION FILTER
        -> REPLICATE_WILD_DO_TABLE = ('db2.t1%','db2.t2%');
    Query OK, 0 rows affected (0.00 sec)
    
    mysql> show slave status\G
    *************************** 1. row ***************************
                   Slave_IO_State: Waiting for master to send event
                      Master_Host: 10.69.25.173
                      Master_User: repl
                      Master_Port: 3306
                    Connect_Retry: 60
                  Master_Log_File: mysql-bin.000001
              Read_Master_Log_Pos: 1902
                   Relay_Log_File: relaylog.000002
                    Relay_Log_Pos: 2068
            Relay_Master_Log_File: mysql-bin.000001
                 Slave_IO_Running: Yes
                Slave_SQL_Running: No
                  Replicate_Do_DB: 
              Replicate_Ignore_DB: 
               Replicate_Do_Table: 
           Replicate_Ignore_Table: 
          Replicate_Wild_Do_Table: db2.t1%,db2.t2%

可以看到已经成功设置。

如果我们这样写是不生效的。会以最后一个表为准：

    
    
    mysql> STOP SLAVE SQL_THREAD;
    Query OK, 0 rows affected (0.00 sec)
    
    mysql> CHANGE REPLICATION FILTER
        -> REPLICATE_WILD_DO_TABLE = ('db2.t1%'),
        -> REPLICATE_WILD_DO_TABLE =  ('db2.t2%');
    Query OK, 0 rows affected (0.00 sec)
    
    mysql> show slave status\G
    *************************** 1. row ***************************
                   Slave_IO_State: Waiting for master to send event
                      Master_Host: 10.69.25.173
                      Master_User: repl
                      Master_Port: 3306
                    Connect_Retry: 60
                  Master_Log_File: mysql-bin.000001
              Read_Master_Log_Pos: 1902
                   Relay_Log_File: relaylog.000002
                    Relay_Log_Pos: 2068
            Relay_Master_Log_File: mysql-bin.000001
                 Slave_IO_Running: Yes
                Slave_SQL_Running: No
                  Replicate_Do_DB: 
              Replicate_Ignore_DB: 
               Replicate_Do_Table: 
           Replicate_Ignore_Table: 
          Replicate_Wild_Do_Table: db2.t2%

可以看到只有db2下面的t2开头的表生效了。

参考资料：

<https://www.percona.com/blog/2015/11/04/mysql-5-7-change-replication-filter-
online/>

作者：Atlas

出处：Atlas的博客 <http://www.cnblogs.com/gomysql>

您的支持是对博主最大的鼓励，感谢您的认真阅读。本文版权归作者所有，欢迎转载，但请保留该声明。如果您需要技术支持，本人亦提供有偿服务。

分类: [MySQL
Replication](http://www.cnblogs.com/gomysql/category/565921.html),[MySQL5.7](http://www.cnblogs.com/gomysql/category/700077.html)

标签: [Replication](http://www.cnblogs.com/gomysql/tag/Replication/),
[FILTER](http://www.cnblogs.com/gomysql/tag/FILTER/), [MySQL
5.7](http://www.cnblogs.com/gomysql/tag/MySQL%205.7/)

好文要顶 关注我 收藏该文

[](http://home.cnblogs.com/u/gomysql/)

[yayun](http://home.cnblogs.com/u/gomysql/)  
[关注 - 3](http://home.cnblogs.com/u/gomysql/followees)  
[粉丝 - 127](http://home.cnblogs.com/u/gomysql/followers)

+加关注

0

0

[« ](http://www.cnblogs.com/gomysql/p/4688920.html)
上一篇：[MHA监控进程异常退出](http://www.cnblogs.com/gomysql/p/4688920.html "发布于2015-07-30
12:16")  
[» ](http://www.cnblogs.com/gomysql/p/4994755.html)
下一篇：[诡异的复制错误](http://www.cnblogs.com/gomysql/p/4994755.html "发布于2015-11-25
15:48")  

posted @ 2015-11-24 12:51 [yayun](http://www.cnblogs.com/gomysql/) 阅读(1622)
评论(0) [编辑](https://i.cnblogs.com/EditPosts.aspx?postid=4991197)
[收藏](https://www.cnblogs.com/gomysql/p/4991197.html#)


---
### ATTACHMENTS
[24de3321437f4bfd69e684e353f2b765]: media/wechat.png
[wechat.png](media/wechat.png)
>hash: 24de3321437f4bfd69e684e353f2b765  
>source-url: https://common.cnblogs.com/images/wechat.png  
>file-name: wechat.png  

[51e409b11aa51c150090697429a953ed]: media/copycode.gif
[copycode.gif](media/copycode.gif)
>hash: 51e409b11aa51c150090697429a953ed  
>source-url: https://common.cnblogs.com/images/copycode.gif  
>file-name: copycode.gif  

[c3cd75b37dcaa50aae8d98e60a0c8e87]: media/20180111152354.png
[20180111152354.png](media/20180111152354.png)
>hash: c3cd75b37dcaa50aae8d98e60a0c8e87  
>source-url: https://pic.cnblogs.com/face/609710/20180111152354.png  
>file-name: 20180111152354.png  

[c5fd93bfefed3def29aa5f58f5173174]: media/icon_weibo_24.png
[icon_weibo_24.png](media/icon_weibo_24.png)
>hash: c5fd93bfefed3def29aa5f58f5173174  
>source-url: https://common.cnblogs.com/images/icon_weibo_24.png  
>file-name: icon_weibo_24.png  

---
### NOTE ATTRIBUTES
>Created Date: 2018-04-17 07:06:33  
>Last Evernote Update Date: 2018-10-01 15:35:37  
>source: web.clip7  
>source-url: https://www.cnblogs.com/gomysql/p/4991197.html  
>source-application: WebClipper 7  