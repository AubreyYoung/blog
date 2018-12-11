# MySQL巡检怎么做-博客-云栖社区-阿里云

  

  1. 云栖社区>
  2. [老叶茶馆](https://yq.aliyun.com/teams/134)>
  3. [博客](https://yq.aliyun.com/teams/134/type_blog)>
  4. 正文

#  MySQL巡检怎么做

[技术小能手](https://yq.aliyun.com/users/30356932) 2017-09-29 16:44:25 浏览99 评论0
发表于： [老叶茶馆](https://yq.aliyun.com/teams/134)

[linux](https://yq.aliyun.com/tags/type_blog-tagid_10/)
[java](https://yq.aliyun.com/tags/type_blog-tagid_41/)
[监控](https://yq.aliyun.com/tags/type_blog-tagid_47/)
[服务器](https://yq.aliyun.com/tags/type_blog-tagid_372/)
[mysql](https://yq.aliyun.com/tags/type_blog-tagid_389/)
[innodb](https://yq.aliyun.com/tags/type_blog-tagid_390/)
[日志](https://yq.aliyun.com/tags/type_blog-tagid_467/)
[线程](https://yq.aliyun.com/tags/type_blog-tagid_473/)
[中间件](https://yq.aliyun.com/tags/type_blog-tagid_911/)
[排序](https://yq.aliyun.com/tags/type_blog-tagid_934/)
[索引](https://yq.aliyun.com/tags/type_blog-tagid_1364/)
[磁盘](https://yq.aliyun.com/tags/type_blog-tagid_2213/)

_摘要：_ 每家业务不一样，所以参考标准不一样。
如果没有zabbix，建议使用sar这个小工具，能够收集历史的信息，它的历史数据在/var/log/sa下面，通过 -f 来指定文件。

马上要迎来长假，想想是不是有点小激动，但激动的同时也要了解一下MySQL服务器的状态，以免在外旅游时，没准正和妹子...，突然来个报警，那内心的草泥马恐怕要无限奔腾......

**一、操作系统巡检**

如果有zabbix或者其他监控类型的工具，就方便很多。

首先看 CPU内存、硬盘io的消耗程度，其中重点是硬盘使用率，要为长假做好准备，避免厂家期间业务写入增长，磁盘占满。

每家业务不一样，所以参考标准不一样。 如果没有zabbix，建议使用sar这个小工具，能够收集历史的信息，它的历史数据在/var/log/sa下面，通过
-f 来指定文件。

**举例：**

**1.1 cpu监控**

    
    
     [root@zst data]# sar -u 10 3
    Linux 2.6.32-642.el6.x86_64 (zst) 09/22/2017 _x86_64_ (8 CPU)
    
    10:26:44 AM  CPU %user %nice %system %iowait %steal %idle
    10:26:54 AM  all 0.55  0.00  0.41    5.61    0.03   93.40
    

**1.2 内存监控**

    
    
     [root@zst data]# sar -r 10 3
    Linux 2.6.32-642.el6.x86_64 (zst) 09/22/2017 _x86_64_ (8 CPU)
    
    10:28:36 AM kbmemfree kbmemused %memused kbbuffers kbcached kbcommit %commit
    10:28:46 AM 223084    32658252  99.32    143468    16549080 18774068 37.81
    

**1.3 I/O监控**

    
    
     [root@zst data]# sar -b 10 3
    Linux 2.6.32-642.el6.x86_64 (zst) 09/22/2017 _x86_64_ (8 CPU)
    
    10:30:25 AM       tps      rtps      wtps   bread/s   bwrtn/s
    10:30:35 AM     67.17     61.63      5.54  16169.99     86.20
    

**1.4 系统SWAP监控**

    
    
     [root@zst data]# sar -w 10 3
    Linux 2.6.32-642.el6.x86_64 (zst)  09/22/2017   _x86_64_
    
    10:31:56 AM    proc/s   cswch/s
    10:32:06 AM      0.00   2234.44
    

当然，查看当前的磁盘和内存使用情况df -h，free
-m，是否使用numa和swap，或是否频繁交互信息等。当然，还有其他的监控项目，这里就不一一赘述了。

除此之外，还需要关注日志类信息，例如：

    
    
    /var/log/messages
    /var/log/dmesg
    

**二、MySQL本身巡检**

MySQL本身的监控应该包含重点参数的检查，MySQL状态的检查，除此以外还应该包含自增id的使用情况（小心因为自增id使用满了
不能insert写入从而引发报警哦），及主从健康状态的巡检。

**2.1 重点参数**

    
    
     "innodb_buffer_pool_size"
    "sync_binlog"
    'binlog_format'
    'innodb_flush_log_at_trx_commit'
    'read_only': 
    'log_slave_updates'
    'innodb_io_capacity'
    'query_cache_type'
    'query_cache_size'
    'max_connections'
    'max_connect_errors'
    'server_id'
    

**2.2 MySQL的状态**

例如：每秒的tps、qps，提交了多少事务、回滚了多少事务、打开文件数、打开表数、连接数、innodb buffer使用率，及锁等待等等。

首先，查看mysql状态

    
    
    mysql> show full processlis;
    mysql> show global status;
    mysql> show engine innodb status\G
    

show status中的一些状态信息

**1、wait事件**

    
    
     Innodb_buffer_pool_wait_free
    Innodb_log_waits
    

**2、MySQL锁监控**

    
    
    表锁
    Table_locks_waited
    Table_locks_immediate
    
    行锁
    Innodb_row_lock_current_waits，当前等待锁的行锁数量
    Innodb_row_lock_time，请求行锁总耗时
    Innodb_row_lock_time_avg，请求行锁平均耗时
    Innodb_row_lock_time_max，请求行锁最久耗时
    Innodb_row_lock_waits，行锁发生次数
    

还可以定时收集INFORMATION_SCHEMA里面的信息：

    
    
    INFORMATION_SCHEMA.INNODB_LOCKS; 
    INFORMATION_SCHEMA.INNODB_LOCK_WAITS;
    
    
    
    临时表/临时文件
    Created_tmp_disk_tables/Created_tmp_files
    
    打开表/文件数
    Open_files/Open_table_definitions/Open_tables
    
    并发连接数
    Threads_running /Threads_created/Threads_cached
    Aborted_clients 
    客户端没有正确关闭连接导致客户端终止而中断的连接数
    
    Aborted_connects
    试图连接到mysql服务器而失败的连接数
    

**Binlog**

    
    
     Binlog_cache_disk_use 
    使用临时二进制日志缓冲但超过 binlog_cache_size 值并使用临时文件
    
    Binlog_cache_use
    使用临时二进制日志缓冲的事务数量
    
    Binlog_stmt_cache_disk_use
    当非事务语句使用二进制日志缓存
    
    Binlog_stmt_cache_use
    使用二进制日志缓冲非事务语句数量
    

**链接数:**

    
    
     Connections 
    试图连接到（不管成不成功）mysql服务器的链接数
    

**临时表：**

    
    
    Created_tmp_disk_tables
    服务器执行语句时,在硬盘上自动创建的临时表的数量,是指在排序时,内存不够用 (tmp_table_size小于需要排序的结果集)，所以需要创建基于磁盘的临时表进行排序
    
    Created_tmp_files
    服务器执行语句时自动创建的内存中的临时表的数量
    

**索引:**

    
    
     Handler_commit 内部交语句
    
    Handler_rollback 内部 rollback语句数量
    
    Handler_read_first  索引第一条记录被读的次数,如果高,则它表明服务器正执行大量全索引扫描
    
    Handler_read_key  根据索引读一行的请求数，如果较高，说明查询和表的索引正确
    
    Handler_read_last 查询读索引最后一个索引键请求数
    
    Handler_read_next 按照索引顺序读下一行的请求数
    
    Handler_read_prev 按照索引顺序读前一行的请求数
    
    Handler_read_rnd 根据固定位置读一行的请求数，如果值较高，说明可能使用了大量需要mysql扫整个表的查询或没有正确使用索引
    
    Handler_read_rnd_next 在数据文件中读下一行的请求数，如果你正进行大量的表扫，该值会较高
    Open_table_definitions 
    被缓存的.frm文件数量
    
    Opened_tables
    已经打开的表的数量,如果较大,table_open_cache值可能太小
    
    Open_tables
    当前打开的表的数量
    Queries
    已经发送给服务器的查询个数
    Select_full_join 
    没有使用索引的联接的数量,如果该值不为0,你应该仔细检查表的所有
    
    Select_scan
    对第一个表进行完全扫的联接的数量
    
    Slow_queries 
    查询时间超过long_query_time秒的查询个数
    
    Sort_merge_passes
    排序算法已经执行的合并的数量,如果值较大,增加sort_buffer_size大小
    

**线程:**

    
    
     Threads_cached 线程缓存内的线程数量
    
    Threads_connected 当前打开的连接数量
    
    Threads_created 创建用来处理连接的线程数
    
    Threads_running 激活的（非睡眠状态）线程数
    

我写了一个不成熟的小巡检程序，仅巡检MySQL的状态和参数配置（因为客户的环境不能直连linux但可以直连MySQL），有兴趣的小伙伴可以看看。详见：

<https://github.com/enmotplinux/On-Site-Inspection>

**2.4 MySQL自增id的使用情况**

    
    
    mysql> SELECT table_schema,table_name,engine, Auto_increment
     FROM information_schema.tables where 
      INFORMATION_SCHEMA.TABLE_SCHEMA 
     not  in ("INFORMATION_SCHEMA" ,"PERFORMANCE_SCHEMA", "MYSQL", "SYS")
    

**2.5 存储引擎是否为innodb**

    
    
    mysql>  SELECT TABLE_SCHEMA,TABLE_NAME,ENGINE FROM 
     INFORMATION_SCHEMA.TABLES WHERE 
     ENGINE != 'innodb' AND 
     TABLE_SCHEMA NOT IN
      ("INFORMATION_SCHEMA" ,"PERFORMANCE_SCHEMA", "MYSQL", "SYS");
    

**2.6 MySQL主从检测**

    
    
    mysql>  show slave status\G
    

**2.6.1 主从状态**

主从状态是否双yes？

**2.6.2 主从是否延迟**

    
    
     Master_Log_File == Relay_Master_Log_File 
    && Read_Master_Log_Pos == Exec_Master_Log_Pos
    

最后，同样要检查MySQL的日志，提前发现潜在风险：

  * MySQL error log 
  * MySQL 慢查询日志

**三、高可用巡检**

**3.1 MHA && keepalived**

观察日志看是否有频繁主从切换，如果有的话就分析一下是什么原因导致频繁切换？

**3.2 中间件的巡检 mycat && pproxysql**

这些中间件的巡检，首先参考系统巡检，再看一下中间件本身的日志类和状态类信息，网络延迟或丢包的检查，也是必须要做工作。

**四、总结**

关于巡检来说，每个环境都是不一样的，所以巡检的侧重点也是不一样的，但基本的巡检步骤是避免不了的，如果有其他的巡检姿势也欢迎一起讨论。

原文发布时间为：2017-09-27  
本文作者：田帅萌  
本文来自云栖社区合作伙伴“老叶茶馆”，了解相关信息可以关注“老叶茶馆”微信公众号

如果您发现本社区中有涉嫌抄袭的内容，欢迎发送邮件至：yqgroup@service.aliyun.com
进行举报，并提供相关证据，一经查实，本社区将立刻删除涉嫌侵权内容。

用云栖社区APP，舒服~

【云栖快讯】红轴机械键盘、无线鼠标等753个大奖，先到先得，云栖社区首届博主招募大赛9月21日-11月20日限时开启，为你再添一个高端技术交流场所
[详情请点击](https://yq.aliyun.com/activity/363)

[评论文章 ( _0_ )](https://yq.aliyun.com/articles/220623#comment) (0) (0)

分享到:

     [](http://service.weibo.com/share/share.php?title=MySQL%E5%B7%A1%E6%A3%80%E6%80%8E%E4%B9%88%E5%81%9A+%E6%AF%8F%E5%AE%B6%E4%B8%9A%E5%8A%A1%E4%B8%8D%E4%B8%80%E6%A0%B7%EF%BC%8C%E6%89%80%E4%BB%A5%E5%8F%82%E8%80%83%E6%A0%87%E5%87%86%E4%B8%8D%E4%B8%80%E6%A0%B7%E3%80%82+%E5%A6%82%E6%9E%9C%E6%B2%A1%E6%9C%89zabbix%EF%BC%8C%E5%BB%BA%E8%AE%AE%E4%BD%BF%E7%94%A8sar%E8%BF%99%E4%B8%AA%E5%B0%8F%E5%B7%A5%E5%85%B7%EF%BC%8C%E8%83%BD%E5%A4%9F%E6%94%B6%E9%9B%86%E5%8E%86%E5%8F%B2%E7%9A%84%E4%BF%A1%E6%81%AF%EF%BC%8C%E5%AE%83%E7%9A%84%E5%8E%86%E5%8F%B2%E6%95%B0%E6%8D%AE%E5%9C%A8%2Fvar%2Flog%2Fsa%E4%B8%8B%E9%9D%A2%EF%BC%8C%E9%80%9A%E8%BF%87+-f+%E6%9D%A5%E6%8C%87%E5%AE%9A%E6%96%87%E4%BB%B6%E3%80%82&url=https%3A%2F%2Fyq.aliyun.com%2Farticles%2F220623)

__

  * [上一篇：让聊天机器人同你聊得更带劲 - 对话策略学习](https://yq.aliyun.com/articles/220595)
  * [下一篇：如何编写更好的SQL查询：终极指南（上）](https://yq.aliyun.com/articles/220656)

### 相关文章

  * [ 【巡检】MySQL巡检到底巡检什么 ](https://yq.aliyun.com/articles/214488)
  * [ 【巡检】MySQL巡检 ](https://yq.aliyun.com/articles/201165)
  * [ mysql数据库巡检脚本 ](https://yq.aliyun.com/articles/45717)
  * [ 历年双11实战经历者：数据库性能优化及运维 ](https://yq.aliyun.com/articles/198102)
  * [ 简单的mysql 性能和健康程度巡检 ](https://yq.aliyun.com/articles/45716)
  * [ 专访周金可：我们更倾向于Greenplum来解决数据倾斜… ](https://yq.aliyun.com/articles/60152)
  * [ 筑一座五军集结的长城：保障运维世界 ](https://yq.aliyun.com/articles/68405)
  * [ 阿里云资深DBA专家罗龙九：云数据库的安全和稳定是一个全… ](https://yq.aliyun.com/articles/57239)
  * [ 运维改革探索(二)：构建可视化分布式运维手段 ](https://yq.aliyun.com/articles/196512)
  * [ 运维改革探索(二)：构建可视化分布式运维手段 ](https://yq.aliyun.com/articles/79920)

### 网友评论

登录后可评论，请
[登录](https://account.aliyun.com/login/login.htm?from_type=yqclub&oauth_callback=https%3A%2F%2Fyq.aliyun.com%2Farticles%2F220623%3Fdo%3Dlogin)
或
[注册](https://account.aliyun.com/register/register.htm?from_type=yqclub&oauth_callback=https%3A%2F%2Fyq.aliyun.com%2Farticles%2F220623%3Fdo%3Dlogin)

[评论](https://yq.aliyun.com/articles/220623#modal-login)

  


---
### ATTACHMENTS
[e77cd6c7dd7335ca7d21a57bb14a19db]: media/e77cd6c7dd7335ca7d21a57bb14a19db-2.png
[e77cd6c7dd7335ca7d21a57bb14a19db-2.png](media/e77cd6c7dd7335ca7d21a57bb14a19db-2.png)
>hash: e77cd6c7dd7335ca7d21a57bb14a19db  
>source-url: https://yqfile.alicdn.com/e77cd6c7dd7335ca7d21a57bb14a19db.png  
>file-name: e77cd6c7dd7335ca7d21a57bb14a19db.png  

---
### NOTE ATTRIBUTES
>Created Date: 2017-10-02 00:21:58  
>Last Evernote Update Date: 2018-10-01 15:35:39  
>author: YangKwong  
>source: web.clip  
>source-url: https://yq.aliyun.com/articles/220623  