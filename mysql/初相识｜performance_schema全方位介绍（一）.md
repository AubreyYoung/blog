## 初相识｜performance_schema全方位介绍（一）

## **目 录**

------

*1、什么是performance_schema* 

*2、performance_schema使用快速入门*

*2.1. 检查当前数据库版本是否支持*

*2.2. 启用performance_schema*

*2.3. performance_schema表的分类*

*2.4. performance_schema简单配置与使用*

## **导 语**

------

很久之前，当我还在尝试着系统地学习performance_schema的时候，通过在网上各种搜索资料进行学习，但很遗憾，学习的效果并不是很明显，很多标称类似 "深入浅出performance_schema" 的文章，基本上都是那种动不动就贴源码的风格，然后深入了之后却出不来了。对系统学习performance_schema的作用甚微。

现在，很高兴的告诉大家，我们基于 MySQL 官方文档加上我们的验证，整理了一份可以系统学习 performance_schema 的资料分享给大家，为了方便大家阅读，我们整理为了一个系列，一共7篇文章。下面，请跟随我们一起开始performance_schema系统的学习之旅吧。

本文首先，大致介绍了什么是performance_schema？它能做什么？

然后，简单介绍了如何快速上手使用performance_schema的方法；

最后，简单介绍了performance_schema中由哪些表组成，这些表大致的作用是什么。

PS：本系列文章所使用的数据库版本为 MySQL 官方 5.7.17版本



##  **1、****什么是performance_schema**

**MySQL的performance schema 用于监控MySQL server在一个较低级别的运行过程中的资源消耗、资源等待等情况，它具有以下特点：** 

1. 提供了一种在数据库运行时实时检查server的内部执行情况的方法。$\textcolor{Red}{performance\_schema 数据库中的表使用performance\_schema存储引擎。该数据库主要关注数据库运行过程中的性能相关的数据} $，与information_schema不同，$\textcolor{Red}{information\_schema主要关注server运行过程中的元数据信息} $ 

2. performance_schema通过监视server的事件来实现监视server内部运行情况， “事件”就是server内部活动中所做的任何事情以及对应的时间消耗，利用这些信息来判断server中的相关资源消耗在了哪里？一般来说，事件可以是函数调用、操作系统的等待、SQL语句执行的阶段（如sql语句执行过程中的parsing 或 sorting阶段）或者整个SQL语句与SQL语句集合。事件的采集可以方便的提供server中的相关存储引擎对磁盘文件、表I/O、表锁等资源的同步调用信息。  

3. performance_schema中的事件与写入二进制日志中的事件（描述数据修改的events）、事件计划调度程序（这是一种存储程序）的事件不同。performance_schema中的事件记录的是server执行某些活动对某些资源的消耗、耗时、这些活动执行的次数等情况。  

4. performance_schema中的事件只记录在本地server的performance_schema中，其下的这些表中数据发生变化时不会被写入binlog中，也不会通过复制机制被复制到其他server中。 

5. 当前活跃事件、历史事件和事件摘要相关的表中记录的信息。能提供某个事件的执行次数、使用时长。进而可用于分析某个特定线程、特定对象（如mutex或file）相关联的活动。 

6. PERFORMANCE_SCHEMA存储引擎使用server源代码中的“检测点”来实现事件数据的收集。对于performance_schema实现机制本身的代码没有相关的单独线程来检测，这与其他功能（如复制或事件计划程序）不同 

7. 收集的事件数据存储在performance_schema数据库的表中。这些表可以使用SELECT语句查询，也可以使用SQL语句更新performance_schema数据库中的表记录（如动态修改performance_schema的setup_*开头的几个配置表，但要注意：配置表的更改会立即生效，这会影响数据收集）  

8. performance_schema的表中的数据不会持久化存储在磁盘中，而是保存在内存中，一旦服务器重启，这些数据会丢失（包括配置表在内的整个performance_schema下的所有数据） 

9. MySQL支持的所有平台中事件监控功能都可用，但不同平台中用于统计事件时间开销的计时器类型可能会有所差异。 

**performance_schema实现机制遵循以下设计目标：** 

1. 启用performance_schema不会导致server的行为发生变化。例如，它不会改变线程调度机制，不会导致查询执行计划（如EXPLAIN）发生变化 
2. 启用performance_schema之后，server会持续不间断地监测，开销很小。不会导致server不可用 
3. 在该实现机制中没有增加新的关键字或语句，解析器不会变化  
4. 即使performance_schema的监测机制在内部对某事件执行监测失败，也不会影响server正常运行 
5. 如果在开始收集事件数据时碰到有其他线程正在针对这些事件信息进行查询，那么查询会优先执行事件数据的收集，因为事件数据的收集是一个持续不断的过程，而检索(查询)这些事件数据仅仅只是在需要查看的时候才进行检索。也可能某些事件数据永远都不会去检索 
6. 需要很容易地添加新的instruments监测点 
7. instruments(事件采集项)代码版本化：如果instruments的代码发生了变更，旧的instruments代码还可以继续工作。 
8. 注意：MySQL sys schema是一组对象（包括相关的视图、存储过程和函数），可以方便地访问performance_schema收集的数据。同时检索的数据可读性也更高(例如：performance_schema中的时间单位是皮秒，经过sys schema查询时会转换为可读的us,ms,s,min,hour,day等单位)，sys schem在5.7.x版本默认安装 

##  **2、performance_schema使用快速入门**

现在，是否觉得上面的介绍内容太过枯燥呢？如果你这么想，那就对了，我当初学习的时候也是这么想的。但现在，对于什么是performance_schema这个问题上，比起更早之前更清晰了呢？如果你还没有打算要放弃阅读本文的话，那么，请跟随我们开始进入到"边走边唱"环节吧！ 

### **2.1检查当前数据库版本是否支持**

**performance_schema被视为存储引擎。**如果该引擎可用，则应该在INFORMATION_SCHEMA.ENGINES表或SHOW ENGINES语句的输出中都可以看到它的SUPPORT值为YES，如下： 

使用 INFORMATION_SCHEMA.ENGINES表来查询你的数据库实例是否支持INFORMATION_SCHEMA引擎

```
mysql> SELECT * FROM INFORMATION_SCHEMA.ENGINES WHERE ENGINE ='PERFORMANCE_SCHEMA';
+--------------------+---------+--------------------+--------------+------+------------+
| ENGINE             | SUPPORT | COMMENT            | TRANSACTIONS | XA   | SAVEPOINTS |
+--------------------+---------+--------------------+--------------+------+------------+
| PERFORMANCE_SCHEMA | YES     | Performance Schema | NO           | NO   | NO         |
+--------------------+---------+--------------------+--------------+------+------------+
1 row in set (0.00 sec)
```

使用show命令来查询你的数据库实例是否支持INFORMATION_SCHEMA引擎

```
mysql> show engines;
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
| Engine             | Support | Comment                                                        | Transactions | XA   | Savepoints |
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
| InnoDB             | DEFAULT | Supports transactions, row-level locking, and foreign keys     | YES          | YES  | YES        |
| MRG_MYISAM         | YES     | Collection of identical MyISAM tables                          | NO           | NO   | NO         |
| MEMORY             | YES     | Hash based, stored in memory, useful for temporary tables      | NO           | NO   | NO         |
| BLACKHOLE          | YES     | /dev/null storage engine (anything you write to it disappears) | NO           | NO   | NO         |
| MyISAM             | YES     | MyISAM storage engine                                          | NO           | NO   | NO         |
| CSV                | YES     | CSV storage engine                                             | NO           | NO   | NO         |
| ARCHIVE            | YES     | Archive storage engine                                         | NO           | NO   | NO         |
| PERFORMANCE_SCHEMA | YES     | Performance Schema                                             | NO           | NO   | NO         |
| FEDERATED          | NO      | Federated MySQL storage engine                                 | NULL         | NULL | NULL       |
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
9 rows in set (0.00 sec)
```

当我们看到PERFORMANCE_SCHEMA 对应的Support 字段输出为YES时就表示我们当前的数据库版本是支持performance_schema的。但知道我们的实例支持performance_schema引擎就可以使用了吗？NO，很遗憾，performance_schema在5.6及其之前的版本中，默认没有启用，从5.7及其之后的版本才修改为默认启用。现在，我们来看看如何设置performance_schema默认启用吧！ 

### **2.2. 启用performance_schema**

从上文中我们已经知道，performance_schema在5.7.x及其以上版本中默认启用（5.6.x及其以下版本默认关闭），如果要显式启用或关闭时，我们需要使用参数performance_schema=ON|OFF设置，并在my.cnf中进行配置：

```
[mysqld]
performance_schema = ON  # 注意：该参数为只读参数，需要在实例启动之前设置才生效
```
mysqld启动之后，通过如下语句查看performance_schema是否启用生效（值为ON表示performance_schema已初始化成功且可以使用了。如果值为OFF表示在启用performance_schema时发生某些错误。可以查看错误日志进行排查）：

```
mysql> SHOW VARIABLES LIKE 'performance_schema';
+--------------------+-------+
| Variable_name      | Value |
+--------------------+-------+
| performance_schema | ON    |
+--------------------+-------+
1 row in set (0.00 sec)
```

现在，你可以在performance_schema下使用show tables语句或者通过查询 INFORMATION_SCHEMA.TABLES表中performance_schema引擎相关的元数据来了解在performance_schema下存在着哪些表： 

通过从INFORMATION_SCHEMA.tables表查询有哪些performance_schema引擎的表：

```
mysql> SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES \
WHERE TABLE_SCHEMA ='performance_schema' and engine='performance_schema';
+------------------------------------------------------+
| TABLE_NAME                                           |
+------------------------------------------------------+
| accounts                                             |
| cond_instances                                       |
......
| users                                                |
| variables_by_thread                                  |
+------------------------------------------------------+
87 rows in set (0.00 sec)
```

直接在performance_schema库下使用show tables语句来查看有哪些performance_schema引擎表：

```
mysql> use performance_schema
Database changed
mysql> show tables from performance_schema;
+------------------------------------------------------+
| Tables_in_performance_schema                         |
+------------------------------------------------------+
| accounts                                             |
| cond_instances                                       |
......
| users                                                |
| variables_by_thread                                  |
+------------------------------------------------------+
87 rows in set (0.00 sec)
```

现在，我们知道了在 MySQL 5.7.17 版本中，performance_schema 下一共有87张表，那么，这87帐表都是存放什么数据的呢？我们如何使用他们来查询我们想要查看的数据呢？先别着急，我们先来看看这些表是如何分类的。 

###  **2.3. performance_schema表的分类**

performance_schema库下的表可以按照监视不同的纬度进行了分组，例如：或按照不同数据库对象进行分组，或按照不同的事件类型进行分组，或在按照事件类型分组之后，再进一步按照帐号、主机、程序、线程、用户等，如下：

**按照事件类型分组记录性能事件数据的表** 

语句事件记录表，这些表记录了语句事件信息，当前语句事件表events_statements_current、历史语句事件表events_statements_history和长语句历史事件表events_statements_history_long、以及聚合后的摘要表summary，其中，summary表还可以根据帐号(account)，主机(host)，程序(program)，线程(thread)，用户(user),摘要(digest)和全局(global)再进行细分)

```
mysql> show tables like 'events_statement%';
+----------------------------------------------------+
| Tables_in_performance_schema (%statement%)         |
+----------------------------------------------------+
| events_statements_current                          |
| events_statements_history                          |
| events_statements_history_long                     |
| events_statements_summary_by_account_by_event_name |
| events_statements_summary_by_digest                |
| events_statements_summary_by_host_by_event_name    |
| events_statements_summary_by_program               |
| events_statements_summary_by_thread_by_event_name  |
| events_statements_summary_by_user_by_event_name    |
| events_statements_summary_global_by_event_name     |
+----------------------------------------------------+
11 rows in set (0.00 sec)
```

等待事件记录表，与语句事件类型的相关记录表类似：

```
mysql> show tables like 'events_wait%';
+-----------------------------------------------+
| Tables_in_performance_schema (%wait%)         |
+-----------------------------------------------+
| events_waits_current                          |
| events_waits_history                          |
| events_waits_history_long                     |
| events_waits_summary_by_account_by_event_name |
| events_waits_summary_by_host_by_event_name    |
| events_waits_summary_by_instance              |
| events_waits_summary_by_thread_by_event_name  |
| events_waits_summary_by_user_by_event_name    |
| events_waits_summary_global_by_event_name     |
+-----------------------------------------------+
12 rows in set (0.01 sec)
```

阶段事件记录表，记录语句执行的阶段事件的表，与语句事件类型的相关记录表类似：

```
mysql> show tables like 'events_stage%';
+------------------------------------------------+
| Tables_in_performance_schema (%stage%)         |
+------------------------------------------------+
| events_stages_current                          |
| events_stages_history                          |
| events_stages_history_long                     |
| events_stages_summary_by_account_by_event_name |
| events_stages_summary_by_host_by_event_name    |
| events_stages_summary_by_thread_by_event_name  |
| events_stages_summary_by_user_by_event_name    |
| events_stages_summary_global_by_event_name     |
+------------------------------------------------+
8 rows in set (0.00 sec)
```

事务事件记录表，记录事务相关的事件的表，与语句事件类型的相关记录表类似：

```
mysql> show tables like 'events_transaction%';
+------------------------------------------------------+
| Tables_in_performance_schema (%transaction%)         |
+------------------------------------------------------+
| events_transactions_current                          |
| events_transactions_history                          |
| events_transactions_history_long                     |
| events_transactions_summary_by_account_by_event_name |
| events_transactions_summary_by_host_by_event_name    |
| events_transactions_summary_by_thread_by_event_name  |
| events_transactions_summary_by_user_by_event_name    |
| events_transactions_summary_global_by_event_name     |
+------------------------------------------------------+
8 rows in set (0.00 sec)
```

监视文件系统层调用的表：

```
mysql> show tables like '%file%';
+---------------------------------------+
| Tables_in_performance_schema (%file%) |
+---------------------------------------+
| file_instances                        |
| file_summary_by_event_name            |
| file_summary_by_instance              |
+---------------------------------------+
3 rows in set (0.01 sec)
```

监视内存使用的表：

```
mysql> show tables like '%memory%';
+-----------------------------------------+
| Tables_in_performance_schema (%memory%) |
+-----------------------------------------+
| memory_summary_by_account_by_event_name |
| memory_summary_by_host_by_event_name    |
| memory_summary_by_thread_by_event_name  |
| memory_summary_by_user_by_event_name    |
| memory_summary_global_by_event_name     |
+-----------------------------------------+
5 rows in set (0.01 sec)
```

动态对performance_schema进行配置的配置表：

```
mysql> show tables like '%setup%';
+----------------------------------------+
| Tables_in_performance_schema (%setup%) |
+----------------------------------------+
| setup_actors                           |
| setup_consumers                        |
| setup_instruments                      |
| setup_objects                          |
| setup_timers                           |
+----------------------------------------+
5 rows in set (0.00 sec)
```
现在，我们已经大概知道了performance_schema中的主要表的分类，但，如何使用他们来为我们提供需要的性能事件数据呢？下面，我们介绍如何通过performance_schema下的配置表来配置与使用performance_schema。 

### **2.4. performance_schema简单配置与使用**

数据库刚刚初始化并启动时，并非所有instruments(事件采集项，在采集项的配置表中每一项都有一个开关字段，或为YES，或为NO)和consumers(与采集项类似，也有一个对应的事件类型保存表配置项，为YES就表示对应的表保存性能数据，为NO就表示对应的表不保存性能数据)都启用了，所以默认不会收集所有的事件，可能你需要检测的事件并没有打开，需要进行设置，可以使用如下两个语句打开对应的instruments和consumers（行计数可能会因MySQL版本而异），例如，我们以配置监测等待事件数据为例进行说明： 
打开等待事件的采集器配置项开关，需要修改setup_instruments 配置表中对应的采集器配置项

```
mysql> UPDATE setup_instruments SET ENABLED = 'YES', TIMED = 'YES' where name like 'wait%';
Query OK, 0 rows affected (0.00 sec)
Rows matched: 323  Changed: 0  Warnings: 0
```
打开等待事件的保存表配置开关，修改修改setup_consumers 配置表中对应的配置i向
```
mysql> UPDATE setup_consumers SET ENABLED = 'YES' where name like '%wait%';
Query OK, 3 rows affected (0.04 sec)
Rows matched: 3  Changed: 3  Warnings: 0
```
配置好之后，我们就可以查看server当前正在做什么，可以通过查询events_waits_current表来得知，该表中每个线程只包含一行数据，用于显示每个线程的最新监视事件（正在做的事情）：
```
qogir_env@localhost : performance_schema 04:23:52> SELECT * FROM events_waits_current limit 1\G
*************************** 1. row ***************************
        THREAD_ID: 4
         EVENT_ID: 60
     END_EVENT_ID: 60
       EVENT_NAME: wait/synch/mutex/innodb/log_sys_mutex
           SOURCE: log0log.cc:1572
      TIMER_START: 1582395491787124480
        TIMER_END: 1582395491787190144
       TIMER_WAIT: 65664
            SPINS: NULL
    OBJECT_SCHEMA: NULL
      OBJECT_NAME: NULL
       INDEX_NAME: NULL
      OBJECT_TYPE: NULL
OBJECT_INSTANCE_BEGIN: 955681576
 NESTING_EVENT_ID: NULL
NESTING_EVENT_TYPE: NULL
        OPERATION: lock
  NUMBER_OF_BYTES: NULL
            FLAGS: NULL
1 row in set (0.02 sec)
# 该事件信息表示线程ID为4的线程正在等待innodb存储引擎的log_sys_mutex锁，这是innodb存储引擎的一个互斥锁，等待时间为65664皮秒（*_ID列表示事件来自哪个线程、事件编号是多少；EVENT_NAME表示检测到的具体的内容；SOURCE表示这个检测代码在哪个源文件中以及行号；计时器字段TIMER_START、TIMER_END、TIMER_WAIT分别表示该事件的开始时间、结束时间、以及总的花费时间，如果该事件正在运行而没有结束，那么TIMER_END和TIMER_WAIT的值显示为NULL。注：计时器统计的值是近似值，并不是完全精确）
```

_current表中每个线程只保留一条记录，且一旦线程完成工作，该表中不会再记录该线程的事件信息，_history表中记录每个线程已经执行完成的事件信息，但每个线程的只事件信息只记录10条，再多就会被覆盖掉，*_history_long表中记录所有线程的事件信息，但总记录数量是10000行，超过会被覆盖掉，现在咱们查看一下历史表events_waits_history 中记录了什么：

```
mysql> SELECT THREAD_ID,EVENT_ID,EVENT_NAME,TIMER_WAIT FROM events_waits_history ORDER BY THREAD_ID limit 21;
+-----------+----------+------------------------------------------+------------+
| THREAD_ID | EVENT_ID | EVENT_NAME                               | TIMER_WAIT |
+-----------+----------+------------------------------------------+------------+
|         4 |      341 | wait/synch/mutex/innodb/fil_system_mutex |      84816 |
|         4 |      342 | wait/synch/mutex/innodb/fil_system_mutex |      32832 |
|         4 |      343 | wait/io/file/innodb/innodb_log_file      |  544126864 |
......
|         4 |      348 | wait/io/file/innodb/innodb_log_file      |  693076224 |
|         4 |      349 | wait/synch/mutex/innodb/fil_system_mutex |      65664 |
|         4 |      350 | wait/synch/mutex/innodb/log_sys_mutex    |      25536 |
|        13 |     2260 | wait/synch/mutex/innodb/buf_pool_mutex   |     111264 |
|        13 |     2259 | wait/synch/mutex/innodb/fil_system_mutex |    8708688 |
......
|        13 |     2261 | wait/synch/mutex/innodb/flush_list_mutex |     122208 |
|        15 |      291 | wait/synch/mutex/innodb/buf_dblwr_mutex  |      37392 |
+-----------+----------+------------------------------------------+------------+
21 rows in set (0.00 sec)
```

summary表提供所有事件的汇总信息。该组中的表以不同的方式汇总事件数据（如：按用户，按主机，按线程等等）。例如：要查看哪些instruments占用最多的时间，可以通过对events_waits_summary_global_by_event_name表的COUNT_STAR或SUM_TIMER_WAIT列进行查询（这两列是对事件的记录数执行COUNT（*）、事件记录的TIMER_WAIT列执行SUM（TIMER_WAIT）统计而来），如下：

```
mysql> SELECT EVENT_NAME,COUNT_STAR FROM events_waits_summary_global_by_event_name \
ORDER BY COUNT_STAR DESC LIMIT 10;
| EVENT_NAME                                        | COUNT_STAR |
+---------------------------------------------------+------------+
| wait/synch/mutex/mysys/THR_LOCK_malloc            |       6419 |
| wait/io/file/sql/FRM                              |        452 |
| wait/synch/mutex/sql/LOCK_plugin                  |        337 |
| wait/synch/mutex/mysys/THR_LOCK_open              |        187 |
| wait/synch/mutex/mysys/LOCK_alarm                 |        147 |
| wait/synch/mutex/sql/THD::LOCK_thd_data           |        115 |
| wait/io/file/myisam/kfile                         |        102 |
| wait/synch/mutex/sql/LOCK_global_system_variables |         89 |
| wait/synch/mutex/mysys/THR_LOCK::mutex            |         89 |
| wait/synch/mutex/sql/LOCK_open                    |         88 |
+---------------------------------------------------+------------+
mysql> SELECT EVENT_NAME,SUM_TIMER_WAIT FROM events_waits_summary_global_by_event_name\
ORDER BY SUM_TIMER_WAIT DESC LIMIT 10;
+----------------------------------------+----------------+
| EVENT_NAME                             | SUM_TIMER_WAIT |
+----------------------------------------+----------------+
| wait/io/file/sql/MYSQL_LOG             |     1599816582 |
| wait/synch/mutex/mysys/THR_LOCK_malloc |     1530083250 |
| wait/io/file/sql/binlog_index          |     1385291934 |
| wait/io/file/sql/FRM                   |     1292823243 |
| wait/io/file/myisam/kfile              |      411193611 |
| wait/io/file/myisam/dfile              |      322401645 |
| wait/synch/mutex/mysys/LOCK_alarm      |      145126935 |
| wait/io/file/sql/casetest              |      104324715 |
| wait/synch/mutex/sql/LOCK_plugin       |       86027823 |
| wait/io/file/sql/pid                   |       72591750 |
+----------------------------------------+----------------+
# 这些结果表明，THR_LOCK_malloc互斥事件是最热的。
注：THR_LOCK_malloc互斥事件仅在DEBUG版本中存在,GA版本不存在 
```

instance表记录了哪些类型的对象会被检测。这些对象在被server使用时，在该表中将会产生一条事件记录，例如，file_instances表列出了文件I/O操作及其关联文件名：

```
mysql> SELECT * FROM file_instances limit 20;
+------------------------------------------------------+--------------------------------------+------------+
| FILE_NAME                                            | EVENT_NAME                           | OPEN_COUNT |
+------------------------------------------------------+--------------------------------------+------------+
| /home/mysql/program/share/english/errmsg.sys         | wait/io/file/sql/ERRMSG              
|          0 |
| /home/mysql/program/share/charsets/Index.xml         | wait/io/file/mysys/charset           
|          0 |
| /data/mysqldata1/innodb_ts/ibdata1                   | wait/io/file/innodb/innodb_data_file |          3 |
| /data/mysqldata1/innodb_log/ib_logfile0              | wait/io/file/innodb/innodb_log_file  |          2 |
| /data/mysqldata1/innodb_log/ib_logfile1              | wait/io/file/innodb/innodb_log_file  |          2 |
| /data/mysqldata1/undo/undo001                        | wait/io/file/innodb/innodb_data_file |          3 |
| /data/mysqldata1/undo/undo002                        | wait/io/file/innodb/innodb_data_file |          3 |
| /data/mysqldata1/undo/undo003                        | wait/io/file/innodb/innodb_data_file |          3 |
| /data/mysqldata1/undo/undo004                        | wait/io/file/innodb/innodb_data_file |          3 |
| /data/mysqldata1/mydata/multi_master/test.ibd        | wait/io/file/innodb/innodb_data_file |          1 |
| /data/mysqldata1/mydata/mysql/engine_cost.ibd        | wait/io/file/innodb/innodb_data_file |          3 |
| /data/mysqldata1/mydata/mysql/gtid_executed.ibd      | wait/io/file/innodb/innodb_data_file |          3 |
| /data/mysqldata1/mydata/mysql/help_category.ibd      | wait/io/file/innodb/innodb_data_file |          3 |
| /data/mysqldata1/mydata/mysql/help_keyword.ibd       | wait/io/file/innodb/innodb_data_file |          3 |
| /data/mysqldata1/mydata/mysql/help_relation.ibd      | wait/io/file/innodb/innodb_data_file |          3 |
| /data/mysqldata1/mydata/mysql/help_topic.ibd         | wait/io/file/innodb/innodb_data_file |          3 |
| /data/mysqldata1/mydata/mysql/innodb_index_stats.ibd | wait/io/file/innodb/innodb_data_file |          3 |
| /data/mysqldata1/mydata/mysql/innodb_table_stats.ibd | wait/io/file/innodb/innodb_data_file |          3 |
| /data/mysqldata1/mydata/mysql/plugin.ibd             | wait/io/file/innodb/innodb_data_file |          3 |
| /data/mysqldata1/mydata/mysql/server_cost.ibd        | wait/io/file/innodb/innodb_data_file |          3 |
+------------------------------------------------------+--------------------------------------+------------+
20 rows in set (0.00 sec)
```
------

## **本文小结**

本篇内容到这里就接近尾声了，相信很多人都认为，我们大多数时候并不会直接使用performance_schema来查询性能数据，而是使用sys schema下的视图代替，为什么不直接学习sys schema呢？那你知道sys schema中的数据是从哪里吐出来的吗？performance_schema 中的数据实际上主要是从performance_schema、information_schema中获取，所以要想玩转sys schema，全面了解performance_schema必不可少。另外，对于sys schema、informatiion_schema甚至是mysql schema，我们后续也会推出不同的系列文章分享给大家。

