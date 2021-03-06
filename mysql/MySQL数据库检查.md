

[TOC]



# 一、MySQL数据库管理

## 1.部署

### 1.1 升级

```mysql
-- 5.7版本升级
-- 软连接重建
mysql_upgrade -s     ## 只升级系统表
[root@centos ~]# mysql_config_editor remove -G mysql5.7
[root@centos ~]# mysql_config_editor print --all
[client]
host = elp
[root@centos ~]# mysql_config_editor set -G mysql5.7 -hlocalhost -uroot -p
Enter password:
[root@centos ~]# mysql_config_editor print --all
[client]
host = elp
[mysql5.7]
user = root
password = *
host = localhost
[root@centos ~]# mysql --help|grep login
-u, --user=name     User for login if not current user.
except for login file.
--login-path=#          Read this path from the login file.
[root@centos ~]# mysql --login-path=mysql5.7
```
### 1.2 降级

### 1.3 安装

### 1.4 myisam表修复

```mysql
# myisamchk 
```

## 2. 会话管理

### 2.1 查看进程

```mysql
mysql> show  processlist;

-- 查询会话
mysql> SELECT a.trx_state, 
          b.event_name, 
          a.trx_started, 
          b.timer_wait / 1000000000000 timer_wait, 
          a.trx_mysql_thread_id        blocking_trx_id, 
          b.sql_text 
   FROM   information_schema.innodb_trx a, 
          performance_schema.events_statements_current b, 
          performance_schema.threads c 
   WHERE  a.trx_mysql_thread_id = c.processlist_id 
          AND b.thread_id = c.thread_id; 

-- 获取当前会话进程ID
mysql>select CONNECTION_ID();
```
### 2.2 KILL会话

```mysql
mysql> kill XXXX;

-- shell脚本
#!/bin/bash
mysql -u root -e "show processlist" | grep -i "Locked" >> locked_log.txt

for line in `cat locked_log.txt | awk '{print $1}'`
do 
   echo "kill $line;" >> kill_thread_id.sql
done
现在kill_thread_id.sql的内容像这个样子

kill 66402982;
kill 66402983;
kill 66402986;
kill 66402991;

-- shell for循环命令脚本
for id in `mysqladmin processlist | grep -i locked | awk '{print $1}'`
do
   mysqladmin kill ${id}
done
;

方法二
-- 批量删除事务表中的事务脚本
mysql>  select concat('KILL ',id,';') from information_schema.processlist where user='cms_bokong';
```

## 3. 参数修改、优化

###  3.1 密码相关
```mysql
-- 密码有效期
mysql >  show variables like 'default_password_lifetime';
-- 修改MySQL密码检查策略，5.7 my.cnf文件中祛除validate-password = off
mysql> SET GLOBAL validate_password_policy = LOW;
mysql> alter user user() identified by '12345678';
```

### 3.2 autocommit配置

```dart
mysql> select @@autocommit;
mysql> set global autocommit=1;
mysql> set global autocommit=0;
```
### 3.3 事务隔离级别
```mysql
mysql > select @@transaction_isolation;
+-------------------------+
| @@transaction_isolation |
+-------------------------+
| REPEATABLE-READ         |
+-------------------------+

-- REPEATABLE READ   READ COMMITTED   READ UNCOMMITTED   SERIALIZABLE
mysql> set global transaction_isolation='READ COMMITTED';
```

### 3.4 查看参数

```sql
//1.查看系统所有变量
show [global | session] variables;
//查看全局变量
show global variables;
//查看会话变量
show session variables;
show variables;

//查看满足条件的系统变量(like模糊匹配)
show [global|session] like '%变量名%';
show global variables like '%tx%';

//查看指定的系统变量的值
select @@[global.|session.]系统变量名称;
select @@global.autocommit;
select @@tx_isolation;
select @@session.tx_isolation
```

> **注意:** 
>
> ​		select 和 @@ 关键字，global和session后面有个.符号

### 3.5参数赋值

```sql
/*为某个系统变量赋值*/
//方式1
set [global|session] 系统变量名=值;
set global autocommit=0;
//方式2
set @@[global.|session.]系统变量名=值;
set @@global.autocommit=1;

/*④为某个会话变量赋值*/
set @@session.tx_isolation='read-uncommitted';
set @@tx_isolation='read-committed';
```

> **注意:**
>
> ​		上面使用中介绍的，全局变量需要添加global关键字，会话变量需要添加session关键字，如果不 写，默认为session级别。 
>
> ​		全局变量的使用中用到了 @@ 关键字，后面会介绍自定义变量，**自定义变量中使用了一个 @ 符号**， 这点需要和全局变量区分一下。

## 4. percona toolkit

## 5. 用户权限管理

MySQL访问权限系统表

```sql
user
db
tables_priv
columns_priv
procs_priv
proxies_priv
```



### 5.1 创建/删除用户

```mysql
CREATE USER 'username'@'host' IDENTIFIED BY 'password';
CREATE USER 'username'@'192.168.5.9' IDENTIFIED BY 'password';
CREATE USER 'username'@'localhost' IDENTIFIED BY 'password';
CREATE USER 'username'@'%' IDENTIFIED BY '';
CREATE USER 'username'@'%';
create user 'root'@'%' identified by 'oracle';

drop user 'root'@'192.168.45.52';
```
### 5.2 授权、角色
![](MySQL%E6%95%B0%E6%8D%AE%E5%BA%93%E6%A3%80%E6%9F%A5.assets/Image.png)
```mysql
GRANT privileges ON databasename.tablename TO 'username'@'host';
GRANT SELECT,INSERT ON DBname.tablename TO 'username'@'%';
GRANT ALL ON DBname.tablename TO 'username'@'%';
GRANT ALL ON DBname.* TO 'username'@'%';
GRANT ALL ON *.* TO 'username'@'%';
GRANT ALL PRIVILEGES ON . TO 'root'@'%'  WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON . TO 'root'@'*.mysql.com'  WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON . TO 'root'@'192.168.45.0/255.255.255.0'  WITH GRANT OPTION;

show privileges
show grants for current_user;
show grants for current_user();
```
注意：使用以上命令授权的用户不能用来再给其他用户授权
如果想让该用户可以为其他用户授权，可以使用如下命令：

```mysql
GRANT privileges ON databasename.tablename TO 'username'@'host' WITH GRANT OPTION;
```
### 5.3 设置用户密码
```mysql
SET PASSWORD FOR 'username'@'host'=PASSWORD('newpassword');

-- 如果是修改当前登录的用户的密码，使用如下命令：
SET PASSWDORD=PASSWORD('newpassword')

rename user  'system'@'192.168.45.52' to 'test'@'192.168.45.52';
set password for 'sys'@'192.168.45.52' = password('oracle');
set password = "oracle";       ###mysql5.7写法

-- 设置root密码
mysql> mysql -u root
mysql> SET PASSWORD = PASSWORD('123456');

-- 重设其它用户的密码
-- 方法一
> mysql -u root -p
mysql> use mysql;
mysql> UPDATE user SET password=PASSWORD("new password") WHERE user='username';
mysql> FLUSH PRIVILEGES;
mysql> exit
-- 方法二
> mysql -u root -p
mysql> use mysql; 
mysql> SET PASSWORD FOR username=PASSWORD('new password');
mysql> exit
-- 方法三
mysqladmin -u root "old password" "new password"
mysqladmin  -uroot -p password "oracle"
```

## 6. mysqladmin

```mysql
mysqladmin create sampdb
mysqladmin drop database
mysqladmin extended-status
mysqladmin flush-hosts
mysqladmin flush-logs 
mysqladmin flush-logs binary,engine,error,general,relay,slow
mysqladmin flush-privileges
mysqladmin flush-status
mysqladmin flush-tables
mysqladmin flush-threads
mysqladmin kill id,id,.
mysqladmin password new_password
mysqladmin ping
mysqladmin processlist
mysqladmin reload 
mysqladmin refresh    
mysqladmin shutdown   
mysqladmin status     
mysqladmin start-slave
mysqladmin stop-slave 
mysqladmin variables  
mysqladmin version

-- 多个命令
mysqladmin processlist status

mysqladmin -uroot -pPassword@123 extended-status -r -i 1 -c 3|grep -iE 'connected|running|bytes_rece|bytes_sent'

mysqladmin -uroot -pPassword@123 variables |grep -iE 'connect|log'
-- 免密码登录，忘记密码
mysqldadmin  --skip-grant-tables --user=mysql &  
-- 查看mysqld进程号
pgrep   mysqld
```

## 7. innotop

```mysql
innotop 
  --askpass          Prompt for a password when connecting to MySQL
  --[no]color   -C   Use terminal coloring (default)
  --config      -c   Config file to read
  --count            Number of updates before exiting
  --delay       -d   Delay between updates in seconds
  --help             Show this help message
  --host        -h   Connect to host
  --[no]inc     -i   Measure incremental differences
  --mode        -m   Operating mode to start in
  --nonint      -n   Non-interactive, output tab-separated fields
  --password    -p   Password to use for connection
  --port        -P   Port number to use for connection
  --skipcentral -s   Skip reading the central configuration file
  --socket      -S   MySQL socket to use for connection
  --spark            Length of status sparkline (default 10)
  --timestamp   -t   Print timestamp in -n mode (1: per iter; 2: per line)
  --user        -u   User for login if not current user
  --version          Output version information and exit
  --write       -w   Write running configuration into home directory if no config files were loaded
  
[RO] Dashboard (? for help)                                                                                      localhost, 9d, 101.73 QPS, 30/2/434 con/run/cac thds, 8.0.20

Switch to a different mode:
   A  Dashboard         I  InnoDB I/O Info     Q  Query List
   B  InnoDB Buffers    K  InnoDB Lock Waits   R  InnoDB Row Ops
   C  Command Summary   L  Locks               S  Variables & Status
   D  InnoDB Deadlocks  M  Replication Status  T  InnoDB Txns
   F  InnoDB FK Err     O  Open Tables         U  User Statistics

Actions:
   d  Change refresh interval        q  Quit innotop
   k  Kill a query's connection      r  Reverse sort order
   n  Switch to the next connection  s  Choose sort column
   p  Pause innotop                  x  Kill a query

Other:
 TAB  Switch to the next server group   /  Quickly filter what you see
   !  Show license and warranty         =  Toggle aggregation
   #  Select/create server groups       @  Select/create server connections
   $  Edit configuration settings       \  Clear quick-filters
Press any key to continue
```

# 二、MySQL优化

## 1.  性能优化原理

### 1.1 体系架构

#### 1.1.1 MySQL体系结构

![MySQL体系结构](MySQL%E6%95%B0%E6%8D%AE%E5%BA%93%E6%A3%80%E6%9F%A5.assets/mysql-architecture.png)

#### 1.1.2 InnoDB体系结构

![InnoDB存储引擎1](MySQL%E6%95%B0%E6%8D%AE%E5%BA%93%E6%A3%80%E6%9F%A5.assets/innodb-architecture1.png)
![InnoDB存储引擎2](MySQL%E6%95%B0%E6%8D%AE%E5%BA%93%E6%A3%80%E6%9F%A5.assets/innodb-architecture2.png)

- 后台线程

  ```mysql
  select * from performance_schema.threads where type='BACKGROUND';
  ```

- 前台线程

  ```mysql
  select * from performance_schema.threads where type='FOREGROUND';
  ```

### 1.2 什么影响了性能?

- 数据库设计对性能的影响

  - 过分的反范式化为表建立太多的列

  - 过分的范式化造成太多的表关联

  - 在OLTP环境中使用不切当的分区表

  - 使用外键保证数据的完整性

- 性能优化顺序
  - 数据库结构设计和SQL语句
  - 数据库存储引擎的选择和参数配置
  - 系统选择及优化
  - 硬件升级

### 1.3 OS NUMA

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
## 2. 数据字典

### 2.1 sys

**1. Server层统计信息字典表**
COLUMNS：

提供查询表中的列(字段)信息

该表为InnoDB 存储引擎的临时表

KEY_COLUMN_USAGE：

提供查询哪些索引列存在约束条件

该表中的信息包含主键、唯一索引、外键等约束的信息，例如：所在库表列名，引用的库表列名等。表中的信息与TABLE_CONSTRAINTS表中记录的信息有些类似，但TABLE_CONSTRAINTS表中没有记录约束引用的库表列信息。但是却记录了TABLE_CONSTRAINTS表中所没有的约束类型信息

该表为Memory引擎临时表

REFERENTIAL_CONSTRAINTS：

提供查询关于外键约束的一些信息

该表为Memory引擎临时表

STATISTICS：

提供查询关于索引的一些统计信息，一个索引对应一行记录

该表为Memory引擎临时表

TABLE_CONSTRAINTS：

提供查询表相关的约束信息

该表为Memory引擎临时表

FILES：

提供查询MySQL的数据表空间文件相关的信息，包含InnoDB存储引擎和NDB存储引擎相关的数据文件信息，由于NDB存储引擎在国内较少使用，我们大多数场景(95%以上场景InnoDB存储引擎都满可以使用)都是使用InnoDB存储引擎

该表为Memory存储引擎表

ENGINES：

提供查询MySQL Server支持的引擎相关的信息

该表为Memory引擎临时表

TABLESPACES：

提供查询关于活跃表空间的相关信息（主要记录的是NDB存储引擎表空间信息）

注意：该表不提供有关InnoDB存储引擎的表空间的信息。 对于InnoDB表空间元数据信息，请查询INNODB_SYS_TABLESPACES和INNODB_SYS_DATAFILES表。另外，从MySQL 5.7.8开始，INFORMATION_SCHEMA.FILES表也提供查询InnoDB表空间的元数据信息

该表为Memory引擎临时表。

SCHEMATA：

提供查询MySQL Server中的数据库列表信息，一个schema就代表一个database

该表为Memory引擎临时表

**2. Server层表级别对象字典表**
VIEWS：

提供查询数据库中的视图相关的信息，查询该表的帐号需要拥有show view权限

该表为InnoDB引擎临时表

TRIGGERS：

提供查询关于某个数据库下的触发器相关的信息，要查询某个表的触发器，查询的账户必须要有trigger权限

该表为InnoDB引擎临时表

TABLES：

提供查询数据库内的表相关的基本信息

该表为Memory引擎临时表

ROUTINES：

提供查询关于存储过程和存储函数的信息（不包括用户自定义函数UDF），该表中的信息与“mysql.proc”中记录的信息相对应（如果该表中有值的话）

该表为InnoDB引擎临时表

PARTITIONS：

提供查询关于分区表的信息

该表为InnoDB引擎临时表

EVENTS：

提供查询计划任务事件相关的信息

该表是InnoDB引擎临时表

PARAMETERS：

提供有关存储过程和函数的参数信息，以及有关存储函数的返回值的信息。 这些参数信息与mysql.proc表中的param_list列记录的内容类似

该表为InnoDB引擎临时表

**3. Server 层混杂信息字典表**
GLOBAL_STATUS、GLOBAL_VARIABLES、SESSION_STATUS、SESSION_VARIABLES：

提供查询全局、会话级别的的状态变量与系统变量信息，这些表为Memory引擎临时表

OPTIMIZER_TRACE：

提供优化程序跟踪功能产生的信息。

跟踪功能默认关闭，使用optimizer_trace系统变量启用跟踪功能。如果开启该功能，则每个会话只能跟踪他自己执行的语句，不能看到其他会话执行的语句，且每个会话只能记录最后一个跟踪的SQL语句

该表为InnoDB引擎临时表

PLUGINS：

提供查询关于MySQL Server中支持哪些插件的信息

该表为InnoDB引擎临时表

PROCESSLIST：

提供查询一些关于线程运行过程中的状态信息

该表为InnoDB引擎临时表

PROFILING：

提供查询关于语句性能分析的信息。其记录内容对应于SHOW PROFILES和SHOW PROFILE语句产生的信息。该表需要在会话变量 profiling=1时才会记录语句性能分析信息，否则该表不记录。

注意：从MySQL 5.7.2开始，此表不再推荐使用，在未来的MySQL版本中删除。改用Performance Schema;代替

该表为Memory引擎临时表

CHARACTER_SETS：

提供查询MySQL Server支持的可用字符集有哪些

该表为Memory引擎临时表

COLLATIONS：

提供查询MySQL Server支持的可用校对规则有哪些

该表为Memory引擎临时表

COLLATION_CHARACTER_SET_APPLICABILITY：

提供查询MySQL Server中哪种字符集适用于什么校对规则。查询结果集相当于从SHOW COLLATION获得的结果集中的前两个字段值。该表目前并没有发现有太大作用，为Memory引擎临时表

COLUMN_PRIVILEGES：

提供查询关于列(字段)的权限信息，表中的内容来自mysql.column_priv列权限表（需要针对一个表的列单独授权之后才会有内容）

该表为Memory引擎临时表

SCHEMA_PRIVILEGES：

提供查询关于库级别的权限信息，每种类型的库级别权限记录一行信息，该表中的信息来自mysql.db表

该表为Memory引擎临时表

TABLE_PRIVILEGES：

提供查询关于表级别权限信息，该表中的内容来自mysql.tables_priv

该表为Memory引擎临时表

USER_PRIVILEGES：

提供查询全局权限的信息，该表中的信息来自mysql.user表

该表为Memory引擎临时表

**4. InnoDB 层系统字典表**
INNODB_SYS_DATAFILES：

提供查询InnoDB file-per-table和常规表空间数据文件的路径信息，等同于InnoDB数据字典中SYS_DATAFILES表中的信息

该表中的信息包含InnoDB所有表空间类型的元数据，包括独立表空间、常规表空间、系统表空间、临时表空间和undo表空间（如果开启了独立表空间的话）

该表为memory引擎临时表，查询该表的用户需要有process权限。

INNODB_SYS_VIRTUAL：

提供查询有关InnoDB虚拟生成列和与之关联的列的元数据信息，等同于InnoDB数据字典内部SYS_VIRTUAL表中的信息。INNODB_SYS_VIRTUAL表中展示的行信息是虚拟生成列相关联列的每个列的信息。

该表为memory引擎临时表，查询该表的用户需要有process权限

INNODB_SYS_INDEXES：

提供查询有关InnoDB索引的元数据信息，等同于InnoDB数据字典内部SYS_INDEXES表中的信息

该表为memory引擎临时表，查询该表的用户需要具有process权限

INNODB_SYS_TABLES：

提供查询有关InnoDB表的元数据，等同于InnoDB数据字典内部SYS_TABLES表的信息。

该表为memory引擎临时表，查询该表的用户需要有process权限

INNODB_SYS_FIELDS：

提供查询有关InnoDB索引键列（字段）的元数据信息，等同于InnoDB数据字典内部SYS_FIELDS表的信息

该表为memory引擎临时表，查询该表的用户需要有process权限

INNODB_SYS_TABLESPACES：

提供查询有关InnoDB独立表空间和普通表空间的元数据信息（也包含了全文索引表空间），等同于InnoDB数据字典内部SYS_TABLESPACES表中的信息

该表为memory引擎临时表，查询该表的用户需要有process权限

INNODB_SYS_FOREIGN_COLS：

提供查询有关InnoDB外键列的状态信息，等同于InnoDB数据字典内部SYS_FOREIGN_COLS表的信息

该表为memory引擎临时表，查询该表的用户需要有process权限

INNODB_SYS_COLUMNS：

提供查询有关InnoDB表列的元数据信息，等同于InnoDB数据字典内部SYS_COLUMNS表的信息

该表为memory引擎临时表，查询该表的用户需要具有process权限

INNODB_SYS_FOREIGN：

提供查询有关InnoDB外键的元数据信息，等同于InnoDB数据字典内部SYS_FOREIGN表的信息

该表为memory引擎临时表，查询该表的用户需要有process权限

INNODB_SYS_TABLESTATS：

提供查询有关InnoDB表的较低级别的状态信息视图。 MySQL优化器会使用这些统计信息数据来计算并确定在查询InnoDB表时要使用哪个索引。这些信息保存在内存中的数据结构中，与存储在磁盘上的数据无对应关系。InnoDB内部也无对应的系统表。

该表为memory引擎临时表，查询该表的用户需要有process权限

**5. InnoDB 层锁、事务、统计信息字典表**
INNODB_LOCKS：

提供查询innodb引擎事务中正在请求的且并未获得的且同时阻塞了其他事务的锁信息(即没有发生不同事务之间的锁等待的锁信息，在这里是查看不到的，例如，只有一个事务时，该事务所加的锁信息无法查看到)。该表中的内容可以用于诊断高并发下的锁争用信息。

该表为memory引擎临时表，访问该表需要拥有具有process权限

INNODB_TRX：

提供查询当前在InnoDB引擎中执行的每个事务（不包括只读事务）的信息，包括事务是否正在等待锁、事务什么时间点开始、以及事务正在执行的SQL语句文本信息等（如果有SQL的话）。

该表为memory引擎临时表，查询该表的用户需要有process权限

INNODB_BUFFER_PAGE_LRU：

提供查询缓冲池中的页面信息，与INNODB_BUFFER_PAGE表不同，INNODB_BUFFER_PAGE_LRU表保存有关innodb buffer pool中的页如何进入LRU链表以及在buffer pool不够用时确定需要从缓冲池中逐出哪些页

该表为Memory引擎临时表

INNODB_LOCK_WAITS：

提供查询关于每个被阻塞的InnoDB事务的锁等待记录，包括发生锁等带事务所请求的锁和阻止该锁请求被授予的锁

该表为memory引擎表，访问该表用户需要有process权限

INNODB_TEMP_TABLE_INFO：

提供查询有关在InnoDB实例中当前处于活动状态的用户(已建立连接的用户，断开的用户连接对应的临时表会被自动删除)创建的InnoDB临时表的信息。 它不提供查询优化器使用的内部InnoDB临时表的信息查询。INNODB_TEMP_TABLE_INFO表在首次查询时创建。

该表为memory引擎临时表，查询该表的用户需要有process权限

INNODB_BUFFER_PAGE：

提供查询关于buffer pool中的页相关的信息

查询该表需要用户具有PROCESS权限，该表为Memory引擎临时表

INNODB_METRICS：

提供查询InnoDB更为详细细致的性能信息，是对InnoDB的PERFORMANCE_SCHEMA的补充。通过对该表的查询，可用于检查innodb的整体健康状况。也可用于诊断性能瓶颈、资源短缺和应用程序的问题等。

该表为memory引擎临时表，查询该表的用户需要有process权限

INNODB_BUFFER_POOL_STATS：

提供查询一些Innodb buffer pool中的状态信息，该表中记录的信息与SHOW ENGINE INNODB STATUS输出的信息类似相同，另外，innodb buffer pool的一些状态变量也提供了部分相同的值

查看该表需要有process权限，该表为Memory引擎临时表

**6. InnoDB 层全文索引字典表**
INNODB_FT_CONFIG：

提供查询有关InnoDB表的FULLTEXT索引和关联的元数据信息。查询此表之前，需要先设置innodb_ft_aux_table="db_name/tb_name"，db_name/tb_name为包含全文索引的表名和库名。

查询该表的账户需要有PROCESS权限，该表为Memory引擎临时表

INNODB_FT_BEING_DELETED：

该表仅在OPTIMIZE TABLE语句执行维护操作期间作为INNODB_FT_DELETED表的快照数据存放使用。运行OPTIMIZE TABLE语句时，会先清空INNODB_FT_BEING_DELETED表中的数据，保存INNODB_FT_DELETED表中的快照数据到INNODB_FT_BEING_DELETED表，并从INNODB_FT_DELETED表中删除DOC_ID。由于INNODB_FT_BEING_DELETED表中的内容通常生命周期较短，因此该表中的数据对于监控或者调试来说用处并不大。

表中默认不记录数据，需要设置系统配置参数innodb_ft_aux_table=string（string表示db_name.tb_name字符串），并创建好全文索引，设置好停用词等。

查询该表的账户需要有PROCESS权限，该表为Memory引擎临时表

INNODB_FT_DELETED：

提供查询从InnoDB表的FULLTEXT索引中删除的行信息。它的存在是为了避免在InnoDB FULLTEXT索引的DML操作期间进行昂贵的索引重组操作，新删除的全文索引中单词的信息将单独存储在该表中，在执行文本搜索时从中过滤出搜索结果，该表中的信息仅在执行OPTIMIZE TABLE语句时清空。

该表中的信息默认不记录，需要使用innodb_ft_aux_table选项(该选项默认值为空串)指定需要记录哪个innodb引擎表的信息，例如：test/test。

查询该表的账户需要有PROCESS权限，该表为Memory引擎临时表

INNODB_FT_DEFAULT_STOPWORD：

该表为默认的全文索引停用词表，提供查询停用词列表值。启用停用词表需要开启参数innodb_ft_enable_stopword=ON，该参数默认为ON，启用停用词功能之后，如果innodb_ft_user_stopword_table选项（针对指定的innodb引擎表中的全文索引生效）自定义了停用词库表名称值，则停用词功能使用innodb_ft_user_stopword_table选项指定的停用词表，如果innodb_ft_user_stopword_table选项未指定，而innodb_ft_server_stopword_table选项（针对所有的innodb引擎表中的全文索引生效）自定义了停用词库表名称值，则同停用词功能使用innodb_ft_server_stopword_table选项指定的停用词表，如果innodb_ft_server_stopword_table选项也未指定，则使用默认的停用词表，即INNODB_FT_DEFAULT_STOPWORD表。

查询该表需要账户有PROCESS权限，该表为Memory引擎临时表

INNODB_FT_INDEX_TABLE：

提供查询关于innodb表全文索引中用于反向文本查找的倒排索引的分词信息。

查询该表的账户需要有PROCESS权限，该表为Memory引擎临时表

INNODB_FT_INDEX_CACHE：

提供查询包含FULLTEXT索引的innodb存储引擎表中新插入行的全文索引标记信息。它存在的目的是为了避免在DML操作期间进行昂贵的索引重组，新插入的全文索引的单词的信息被单独存储在该表中，直到对表执行OPTIMIZE TABLE语句时、或者关闭服务器时、或者当高速缓存中存放的信息大小超过了innodb_ft_cache_size或innodb_ft_total_cache_size系统配置参数指定的大小才会执行清理。默认不记录数据，需要使用innodb_ft_aux_table系统配置参数指定需要记录哪个表中的新插入行的全文索引数据。

查询该表的账户需要有PROCESS权限，该表为Memory引擎临时表

**7. InnoDB 层压缩相关字典表**
INNODB_CMP和INNODB_CMP_RESET：

这两个表中的数据包含了与压缩的InnoDB表页有关的操作的状态信息。表中记录的数据为测量数据库中的InnoDb表压缩的有效性提供参考。

### 2.2 mysql

- 访问权限系统表

  | 表名      | 含义 |
  | ------------ | ------------------------------------------------------------ |
  | db           | 数据库级别的权限表                                           |
  | tables_priv  | 表级别的权限表                                               |
  | columns_priv | 列级权限表                                                   |
  | procs_priv   | 存储过程和函数权限表                                         |
  | proxies_priv | 代理用户权限表                                               |
  | user | 包含用户帐户和全局权限和其他非权限列表(安全配置选项和资源控制选项列) |

- 数据库对象信息记录表

  | 表名   | 含义                                                         |
  | ------ | ------------------------------------------------------------ |
  | plugin | 该表提供查询自定义安装的插件信息（非系统默认启用的插件），该表的功能已经被information_schema.plugins表取代 |
  | proc   | 该表提供查询与information_schema.routines表类似的内容（早期版本主要用户记录存储过程），但information_schema.routines表记录的更加详细 |
  | event  | 该表提供查询计划任务相关的事件信息，该表中的信息与information_schema.events相同，且information_schema.events中记录的信息更加详细 |
  | func   | 该表提供查询与information_schema.routines表类似的内容（早期版本主要用于记录用户自定义函数），但information_schema.routines表记录的更加详细 |

- 统计信息记录表

  | 表名               | 含义                             |
  | ------------------ | -------------------------------- |
  | innodb_table_stats | 该表提供查询表数据相关的统计信息 |
  | innodb_index_stats | 该表提供查询索引相关的统计信息   |

- 优化器成本记录表

  | 表名        | 含义                                                         |
  | ----------- | ------------------------------------------------------------ |
  | engine_cost | 该表提供查询针对特定存储引擎的操作需要使用到的的优化器成本估算常量值 |
  | server_cost | 该表提供查询server常规操作需要使用到的优化器成本估算常量值   |

- 时区信息记录表

  | 表名                      | 含义                                                         |
  | ------------------------- | ------------------------------------------------------------ |
  | time_zone                 | 该表提供查询时区ID和跳秒之间的映射关系数据                   |
  | time_zone_leap_second     | 该表提供查询跳秒机器修正值信息，该表中的信息与time_zone_transition表中的类似，但time_zone_transition表中还记录了时区ID等信息 |
  | time_zone_name            | 该表提供查询时区的名称列表和时区ID的映射关系                 |
  | time_zone_transition      | 该表提供查询时区的跳秒数据                                   |
  | time_zone_transition_type | 该表提供查询具体的跳秒信息以及与时区的对应数据               |

- 复制信息记录表

  | 表名                 | 含义                                                         |
  | -------------------- | ------------------------------------------------------------ |
  | slave_master_info    | 该表提供查询IO线程读取主库的位置信息，以及从库连接主库的IP、账号、端口、密码等信息 |
  | slave_relay_log_info | 该表提供查询SQL线程重放的二进制文件对应的主库位置和relay log当前最新的位置 |
  | slave_worker_info    | 该表提供查询多线程复制时的worker线程状态信息，与performance_schema.replication_applier_status_by_worker表的区别是：slave_worker_info表记录worker线程重放的relay log和主库binlog位置信息，而performance_schema.replication_applier_status_by_worker表记录的是worker线程重放的GTID位置信息 |
  | ndb_binlog_index     | 该表提供查询ndb集群引擎相关的统计信息                        |

- 日志信息记录表

  | 表名        | 含义                                                         |
  | ----------- | ------------------------------------------------------------ |
  | general_log | 该表提供查询普通SQL语句的执行记录信息，用于查找客户端到底在服务端上执行了什么SQL（ |
  | slow_log    | 该表提供查询执行时间超过long_query_time设置值的SQL，或者未使用索引的（需要开启参数log_queries_not_using_indexes=ON）或者管理语句（需要开启参数log_slow_admin_statements=ON） |
  | servers     | 该表提供查询连接组合信息(远程实例的IP、端口、帐号、密码、数据库名称等信息，详见后续示例)，这些连接组合信息通常用于federated引擎（当然也可以作为在数据库中保存连接组合的一种方式，维护也较为方便），该表中的信息需要使用create server方式创建 |

### 2.3 information_schema

```mysql
-- information_schema.ENGINES 存储引擎信息
mysql>select * from information_schema.ENGINES;
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
| ENGINE             | SUPPORT | COMMENT                                                        | TRANSACTIONS | XA   | SAVEPOINTS |
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
| FEDERATED          | NO      | Federated MySQL storage engine                                 | NULL         | NULL | NULL       |
| MEMORY             | YES     | Hash based, stored in memory, useful for temporary tables      | NO           | NO   | NO         |
| InnoDB             | DEFAULT | Supports transactions, row-level locking, and foreign keys     | YES          | YES  | YES        |
| PERFORMANCE_SCHEMA | YES     | Performance Schema                                             | NO           | NO   | NO         |
| MyISAM             | YES     | MyISAM storage engine                                          | NO           | NO   | NO         |
| MRG_MYISAM         | YES     | Collection of identical MyISAM tables                          | NO           | NO   | NO         |
| BLACKHOLE          | YES     | /dev/null storage engine (anything you write to it disappears) | NO           | NO   | NO         |
| CSV                | YES     | CSV storage engine                                             | NO           | NO   | NO         |
| ARCHIVE            | YES     | Archive storage engine                                         | NO           | NO   | NO         |
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+

-- 查看会话
select  * from INFORMATION_SCHEMA.PROCESSLIST;
--查看进程
show processlist 
show full processlist     -- 显示全部进程
mysqladmin  processlist
```

### 2.4 performance_schema

- Setup Tables

  ```mysql
  mysql> show tables like '%setup_%';
  +-----------------------------------------+
  | Tables_in_performance_schema (%setup_%) |
  +-----------------------------------------+
  | setup_actors                            |
  | setup_consumers                         |
  | setup_instruments                       |
  | setup_objects                           |
  | setup_threads                           |
  +-----------------------------------------+
  5 rows in set (0.00 sec)
  ```

- Instance Tables

  ```mysql
  mysql> show tables like '%_instances%';
  +---------------------------------------------+
  | Tables_in_performance_schema (%_instances%) |
  +---------------------------------------------+
  | cond_instances                              |
  | file_instances                              |
  | mutex_instances                             |
  | prepared_statements_instances               |
  | rwlock_instances                            |
  | socket_instances                            |
  +---------------------------------------------+
  6 rows in set (0.01 sec)
  ```

- Wait Event Tables

  ```mysql
  mysql>  show tables LIKE 'events_waits%';
  +-----------------------------------------------+
  | Tables_in_performance_schema (events_waits%)  |
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
  9 rows in set (0.00 sec)
  ```

- Stage Event Tables

  ```mysql
  mysql> show tables LIKE 'events_stages%';
  +------------------------------------------------+
  | Tables_in_performance_schema (events_stages%)  |
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

- Statement Event Tables

  ```mysql
  mysql> show tables LIKE '%statements%';
  +----------------------------------------------------+
  | Tables_in_performance_schema (%statements%)        |
  +----------------------------------------------------+
  | events_statements_current                          |
  | events_statements_histogram_by_digest              |
  | events_statements_histogram_global                 |
  | events_statements_history                          |
  | events_statements_history_long                     |
  | events_statements_summary_by_account_by_event_name |
  | events_statements_summary_by_digest                |
  | events_statements_summary_by_host_by_event_name    |
  | events_statements_summary_by_program               |
  | events_statements_summary_by_thread_by_event_name  |
  | events_statements_summary_by_user_by_event_name    |
  | events_statements_summary_global_by_event_name     |
  | prepared_statements_instances                      |
  +----------------------------------------------------+
  13 rows in set (0.01 sec)
  ```

- Transaction Tables

  ```mysql
  mysql> show tables LIKE 'events_transactions%';
  +------------------------------------------------------+
  | Tables_in_performance_schema (events_transactions%)  |
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

- Connection Tables

  ```mysql
  mysql> SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
         WHERE TABLE_SCHEMA = 'performance_schema'
         AND TABLE_NAME REGEXP '_summary_by_(account|host|user)'
         ORDER BY TABLE_NAME;
  +------------------------------------------------------+
  | TABLE_NAME                                           |
  +------------------------------------------------------+
  | events_errors_summary_by_account_by_error            |
  | events_errors_summary_by_host_by_error               |
  | events_errors_summary_by_user_by_error               |
  | events_stages_summary_by_account_by_event_name       |
  | events_stages_summary_by_host_by_event_name          |
  | events_stages_summary_by_user_by_event_name          |
  | events_statements_summary_by_account_by_event_name   |
  | events_statements_summary_by_host_by_event_name      |
  | events_statements_summary_by_user_by_event_name      |
  | events_transactions_summary_by_account_by_event_name |
  | events_transactions_summary_by_host_by_event_name    |
  | events_transactions_summary_by_user_by_event_name    |
  | events_waits_summary_by_account_by_event_name        |
  | events_waits_summary_by_host_by_event_name           |
  | events_waits_summary_by_user_by_event_name           |
  | memory_summary_by_account_by_event_name              |
  | memory_summary_by_host_by_event_name                 |
  | memory_summary_by_user_by_event_name                 |
  +------------------------------------------------------+
  18 rows in set (0.12 sec)
  ```

- Connection Attribute Tables

  ```mysql
  mysql > show tables LIKE '%_connect_attrs%';
  +-------------------------------------------------+
  | Tables_in_performance_schema (%_connect_attrs%) |
  +-------------------------------------------------+
  | session_account_connect_attrs                   |
  | session_connect_attrs                           |
  +-------------------------------------------------+
  2 rows in set (0.00 sec)
  ```

- User-Defined Variable Tables

  ```mysql
  mysql > show tables LIKE 'user_variables_by_thread';
  +---------------------------------------------------------+
  | Tables_in_performance_schema (user_variables_by_thread) |
  +---------------------------------------------------------+
  | user_variables_by_thread                                |
  +---------------------------------------------------------+
  1 row in set (0.00 sec)
  ```

- Replication Tables

  ```mysql
  mysql > show tables LIKE 'replication_%';
  +----------------------------------------------+
  | Tables_in_performance_schema (replication_%) |
  +----------------------------------------------+
  | replication_applier_configuration            |
  | replication_applier_filters                  |
  | replication_applier_global_filters           |
  | replication_applier_status                   |
  | replication_applier_status_by_coordinator    |
  | replication_applier_status_by_worker         |
  | replication_connection_configuration         |
  | replication_connection_status                |
  | replication_group_member_stats               |
  | replication_group_members                    |
  +----------------------------------------------+
  10 rows in set (0.00 sec)
  ```

- NDB Cluster Tables

  ```mysql
  mysql > show tables LIKE 'ndb_%';
  ndb_sync_pending_objects
  ndb_sync_excluded_objects
  ```

- Lock Tables

  ```mysql
  mysql > show tables LIKE '%lock%';
  +---------------------------------------+
  | Tables_in_performance_schema (%lock%) |
  +---------------------------------------+
  | data_lock_waits                       |
  | data_locks                            |
  | metadata_locks                        |
  | rwlock_instances                      |
  | table_lock_waits_summary_by_table     |
  +---------------------------------------+
  5 rows in set (0.00 sec)
  ```

  **The table_handles Table**

- System Variable Tables、Status Variable Tables

  ```mysql
  mysql > show tables LIKE '%variables%';
  +--------------------------------------------+
  | Tables_in_performance_schema (%variables%) |
  +--------------------------------------------+
  | global_variables                           |
  | persisted_variables                        |
  | session_variables                          |
  | user_variables_by_thread                   |
  | variables_by_thread                        |
  | variables_info                             |
  +--------------------------------------------+
  6 rows in set (0.00 sec)
  ```

- Thread Pool Tables

  ```mysql
  tp_thread_group_state 
  tp_thread_group_stats 
  tp_thread_state 
  ```

- Clone Tables

  ```mysql
  clone_status 
  clone_progress 
  ```

- Summary Tables

- Miscellaneous Tables

  ```mysql
  host_cache 
  keyring_keys 
  log_status 
  performance_timers 
  processlist 
  threads 
  tls_channel_status 
  user_defined_functions 
  ```

**示例**

```mysql
-- 不影响性能查看线程
select * from performance_schema.threads;  

-- 哪类的SQL执行最多？
SELECT DIGEST_TEXT,COUNT_STAR,FIRST_SEEN,LAST_SEEN FROM events_statements_summary_by_digest ORDER BY COUNT_STAR DESC
-- 哪类SQL的平均响应时间最多？
SELECT DIGEST_TEXT,AVG_TIMER_WAIT FROM events_statements_summary_by_digest ORDER BY COUNT_STAR DESC
-- 哪类SQL排序记录数最多？
SELECT DIGEST_TEXT,SUM_SORT_ROWS FROM events_statements_summary_by_digest ORDER BY COUNT_STAR DESC
-- 哪类SQL扫描记录数最多？
SELECT DIGEST_TEXT,SUM_ROWS_EXAMINED FROM events_statements_summary_by_digest ORDER BY COUNT_STAR DESC
-- 哪类SQL使用临时表最多？
SELECT DIGEST_TEXT,SUM_CREATED_TMP_TABLES,SUM_CREATED_TMP_DISK_TABLES FROM events_statements_summary_by_digest ORDER BY COUNT_STAR DESC
-- 哪类SQL返回结果集最多？
SELECT DIGEST_TEXT,SUM_ROWS_SENT FROM events_statements_summary_by_digest ORDER BY COUNT_STAR DESC
-- 哪个表物理IO最多？
SELECT file_name,event_name,SUM_NUMBER_OF_BYTES_READ,SUM_NUMBER_OF_BYTES_WRITE FROM file_summary_by_instance ORDER BY SUM_NUMBER_OF_BYTES_READ + SUM_NUMBER_OF_BYTES_WRITE DESC
-- 哪个表逻辑IO最多？
SELECT object_name,COUNT_READ,COUNT_WRITE,COUNT_FETCH,SUM_TIMER_WAIT FROM table_io_waits_summary_by_table ORDER BY sum_timer_wait DESC
-- 哪个索引访问最多？
SELECT OBJECT_NAME,INDEX_NAME,COUNT_FETCH,COUNT_INSERT,COUNT_UPDATE,COUNT_DELETE FROM table_io_waits_summary_by_index_usage ORDER BY SUM_TIMER_WAIT DESC
-- 哪个索引从来没有用过？
SELECT OBJECT_SCHEMA,OBJECT_NAME,INDEX_NAME FROM table_io_waits_summary_by_index_usage WHERE INDEX_NAME IS NOT NULL AND COUNT_STAR = 0 AND OBJECT_SCHEMA <> 'mysql' ORDER BY OBJECT_SCHEMA,OBJECT_NAME;
-- 哪个等待事件消耗时间最多？
SELECT EVENT_NAME,COUNT_STAR,SUM_TIMER_WAIT,AVG_TIMER_WAIT FROM events_waits_summary_global_by_event_name WHERE event_name != 'idle' ORDER BY SUM_TIMER_WAIT DESC
-- 剖析某条SQL的执行情况，包括statement信息，stege信息，wait信息
SELECT EVENT_ID,sql_text FROM events_statements_history WHERE sql_text LIKE '%count(*)%';
-- 查看每个阶段的时间消耗
SELECT event_id,EVENT_NAME,SOURCE,TIMER_END - TIMER_START FROM events_stages_history_long WHERE NESTING_EVENT_ID = 1553;
-- 查看每个阶段的锁等待情况
SELECT event_id,event_name,source,timer_wait,object_name,index_name,operation,nesting_event_id FROM events_waits_history_longWHERE nesting_event_id = 1553;
```



## 3. InnoDB

```bash
show ENGINES； #检查命令
#查看表使用的存储引擎
show table status from db_name where name='table_name';
#修改表的存储引擎
alter table table_name engine=innodb;
```

### 3.1 innodb buffer pool hit rate
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

### 3.2 事务

####  3.2.1 查看事务

```bash
#当前运行的所有事务
mysql> SELECT * FROM information_schema.INNODB_TRX;
#当前出现的锁
mysql> SELECT * FROM information_schema.INNODB_LOCKs;
#锁等待的对应关系
mysql> SELECT * FROM information_schema.INNODB_LOCK_waits;
```

#### 3.2.2 锁

```mysql
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
-- 一个事务所作的修改对其他事务是不可见的，好似是串行执行的
SQL> show variables like '%autoinc%';
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
```


(root@localhost) [information_schema]> show variables like 'max_heap%';
+---------------------+----------+
| Variable_name       | Value    |
+---------------------+----------+
| max_heap_table_size | 16777216 |
+---------------------+----------+
1 row in set (0.00 sec)
(root@localhost) [information_schema]> show table status like 'TABLES%';
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
SQL> show engines;
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
SQL> CREATE TABLE remote_fed (
    ->   `id` int(11) NOT NULL AUTO_INCREMENT,
    ->   `c1` varchar(10) NOT NULL DEFAULT '',
    ->   `c2` char(10) NOT NULL DEFAULT '',
    ->   PRIMARY KEY (`id`)
    -> ) ENGINE=^C
SQL> CREATE TABLE local_fed (
    ->   `id` int(11) NOT NULL AUTO_INCREMENT,
    ->   `c1` varchar(10) NOT NULL DEFAULT '',
    ->   `c2` char(10) NOT NULL DEFAULT '',
    ->   PRIMARY KEY (`id`)
    -> ) ENGINE=federated connection='<mysql://fed_link:oracle@192.168.45.84:3306/mytest/remote_fed>';
Query OK, 0 rows affected (5.37 sec)
SQL> show create table local_fed;
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
SQL> show variables like '%autocommit%';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| autocommit    | ON    |
+---------------+-------+
1 row in set (0.00 sec)
SQL> show variables like '%iso%';      
+-----------------------+----------------+
| Variable_name         | Value          |
+-----------------------+----------------+
| transaction_isolation | READ-COMMITTED |
| tx_isolation          | READ-COMMITTED |
+-----------------------+----------------+
2 rows in set (0.00 sec)
```

![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B14%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B15%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B16%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B17%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B18%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B19%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B20%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B21%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B22%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B23%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B24%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B25%5D.png)

​```mysql
(root@localhost) [(none)]> show variables like 'binlog_format';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| binlog_format | ROW   |
+---------------+-------+
1 row in set (0.00 sec)
(root@localhost) [(none)]> show binary logs;
+------------+------------+
| Log_name   | File_size  |
+------------+------------+
| bin.000001 |        177 |
| bin.000002 |        421 |
| bin.000003 |        217 |
| bin.000004 |        217 |
| bin.000005 |        217 |
| bin.000006 |        217 |
| bin.000007 |     120299 |
| bin.000008 |        217 |
| bin.000009 |        217 |
| bin.000010 |        217 |
| bin.000011 |        217 |
| bin.000012 |        217 |
| bin.000013 |        217 |
| bin.000014 |        217 |
| bin.000015 |        217 |
| bin.000016 |        217 |
| bin.000017 |        217 |
| bin.000018 |        217 |
| bin.000019 |        217 |
| bin.000020 |        217 |
| bin.000021 |       6678 |
| bin.000022 |        382 |
| bin.000023 |        217 |
| bin.000024 |        194 |
| bin.000025 |       4613 |
| bin.000026 |       9167 |
| bin.000027 |        217 |
| bin.000028 |       4453 |
| bin.000029 |   66376295 |
| bin.000030 |   10674999 |
| bin.000031 |        217 |
| bin.000032 |        217 |
| bin.000033 |       1960 |
| bin.000034 |        659 |
| bin.000035 |       3174 |
| bin.000036 |        416 |
| bin.000037 |        217 |
| bin.000038 |    2049281 |
| bin.000039 |        217 |
| bin.000040 |        217 |
| bin.000041 |        217 |
| bin.000042 |        217 |
| bin.000043 |        217 |
| bin.000044 |        235 |
| bin.000045 |        217 |
| bin.000046 |        217 |
| bin.000047 |        939 |
| bin.000048 |        217 |
| bin.000049 |        217 |
| bin.000050 | 1075207675 |
| bin.000051 |  848370257 |
| bin.000052 |        194 |
+------------+------------+
52 rows in set (0.00 sec)
(root@localhost) [(none)]> flush logs;
Query OK, 0 rows affected (0.35 sec)
(root@localhost) [(none)]> show variables like 'binlog_row_image';   ###FULL NOBOL  MIN
+------------------+-------+
| Variable_name    | Value |
+------------------+-------+
| binlog_row_image | FULL  |
+------------------+-------+
1 row in set (0.00 sec)
mysqlbinlog -vv 
mysql> show variables like 'log_bin';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| log_bin       | ON    |
+---------------+-------+
1 row in set (0.00 sec)
mysql> show variables like 'server_id';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| server_id     | 2     |
+---------------+-------+
1 row in set (0.00 sec)
log-bin=mysql-bin
server-id=2
relay_log=mysql-relay-bin
log_slave_updates = 1
read_only = 1
skip-slave-start
mysql> show processlist;
+----+------+-------------+------+-------------+------+---------------------------------------------------------------+------------------+
| Id | User | Host        | db   | Command     | Time | State                                                         | Info             |
+----+------+-------------+------+-------------+------+---------------------------------------------------------------+------------------+
| 14 | root | localhost   | NULL | Query       |    0 | starting                                                      | show processlist |
| 15 | repl | slave:50408 | NULL | Binlog Dump |   88 | Master has sent all binlog to slave; waiting for more updates | NULL             |
+----+------+-------------+------+-------------+------+---------------------------------------------------------------+------------------+
2 rows in set (0.00 sec)
mysql> show processlist;
+----+-------------+-----------+------+---------+------+--------------------------------------------------------+------------------+
| Id | User        | Host      | db   | Command | Time | State                                                  | Info             |
+----+-------------+-----------+------+---------+------+--------------------------------------------------------+------------------+
|  3 | root        | localhost | NULL | Sleep   |  157 |                                                        | NULL             |
|  4 | root        | localhost | NULL | Query   |    0 | starting                                               | show processlist |
|  5 | system user |           | NULL | Connect |   81 | Waiting for master to send event                       | NULL             |
|  6 | system user |           | NULL | Connect |   81 | Slave has read all relay log; waiting for more updates | NULL             |
+----+-------------+-----------+------+---------+------+--------------------------------------------------------+------------------+
4 rows in set (0.00 sec)
mysql>  system perror 1872
MySQL error code 1872 (ER_SLAVE_RLI_INIT_REPOSITORY): Slave failed to initialize relay log info structure from the repository
mysql> show variables like 'gtid_mode';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| gtid_mode     | OFF   |
+---------------+-------+
1 row in set (0.00 sec)

## gtid dump
mysqldump --single-transaction --master-data=2 --triggers --routines --events --all-databases -uroot -p> all_gtid.sql     

#多线程复制
mysql> stop slave;
Query OK, 0 rows affected (0.00 sec)
mysql> set global slave_parallel_type= 'logical_clock';
Query OK, 0 rows affected (0.00 sec)
mysql> set global slave_parallel_workers=2;
Query OK, 0 rows affected (0.00 sec)
mysql> start slave;
Query OK, 0 rows affected (0.01 sec)
mysql> show processlist;
+----+-------------+-----------+------+---------+------+--------------------------------------------------------+------------------+
| Id | User        | Host      | db   | Command | Time | State                                                  | Info             |
+----+-------------+-----------+------+---------+------+--------------------------------------------------------+------------------+
|  4 | root        | localhost | NULL | Query   |    0 | starting                                               | show processlist |
|  7 | system user |           | NULL | Connect |   54 | Waiting for master to send event                       | NULL             |
|  8 | system user |           | NULL | Connect |   54 | Slave has read all relay log; waiting for more updates | NULL             |
|  9 | system user |           | NULL | Connect |   54 | Waiting for an event from Coordinator                  | NULL             |
| 10 | system user |           | NULL | Connect |   54 | Waiting for an event from Coordinator                  | NULL             |
+----+-------------+-----------+------+---------+------+--------------------------------------------------------+------------------+
5 rows in set (0.00 sec)

mysql> show slave hosts;
+-----------+------+------+-----------+--------------------------------------+
| Server_id | Host | Port | Master_id | Slave_UUID                           |
+-----------+------+------+-----------+--------------------------------------+
|        13 |      | 3306 |        11 | 25b8bfec-35b3-11e8-9657-000c29653458 |
|        12 |      | 3306 |        11 | 23eeb92b-35b3-11e8-94db-000c29b85972 |
+-----------+------+------+-----------+--------------------------------------+
2 rows in set (0.00 sec)
create index index_name on table(col_name(n));
optimize table table_name;

(root@localhost) [sakila]> set profiling =1;
Query OK, 0 rows affected, 1 warning (0.00 sec)
(root@localhost) [sakila]> select count(*) from film;
+----------+
| count(*) |
+----------+
|     1000 |
+----------+
1 row in set (0.00 sec)
(root@localhost) [sakila]> show profiles;
+----------+------------+---------------------------+

| Query_ID | Duration | Query |
| -------- | -------- | ----- |
|          |          |       |
+----------+------------+---------------------------+
| 1    | 0.00037100 | select count(*) from film |
| ---- | ---------- | ------------------------- |
|      |            |                           |
+----------+------------+---------------------------+
1 row in set, 1 warning (0.00 sec)
(root@localhost) [sakila]> show profile for query 1;
+----------------------+----------+
| Status | Duration |
| ------ | -------- |
|        |          |
+----------------------+----------+
| starting             | 0.000051 |
| -------------------- | -------- |
|                      |          |
| checking permissions | 0.000005 |
| -------------------- | -------- |
|                      |          |
| Opening tables       | 0.000015 |
| --------------       | -------- |
|                      |          |
| init                 | 0.000012 |
| ----                 | -------- |
|                      |          |
| System lock          | 0.000007 |
| -----------          | -------- |
|                      |          |
| optimizing           | 0.000003 |
| ----------           | -------- |
|                      |          |
| statistics           | 0.000011 |
| ----------           | -------- |
|                      |          |
| preparing            | 0.000009 |
| ---------            | -------- |
|                      |          |
| executing            | 0.000002 |
| ---------            | -------- |
|                      |          |
| Sending data         | 0.000224 |
| ------------         | -------- |
|                      |          |
| end                  | 0.000004 |
| ----                 | -------- |
|                      |          |
| query end            | 0.000007 |
| ---------            | -------- |
|                      |          |
| closing tables       | 0.000006 |
| --------------       | -------- |
|                      |          |
| freeing items        | 0.000009 |
| -------------        | -------- |
|                      |          |
| cleaning up          | 0.000008 |
| -----------          | -------- |
|                      |          |
+----------------------+----------+
15 rows in set, 1 warning (0.00 sec)
(root@localhost) [sakila]> show profile cpu for query 1;
+----------------------+----------+----------+------------+
| Status | Duration | CPU_user | CPU_system |
| ------ | -------- | -------- | ---------- |
|        |          |          |            |
+----------------------+----------+----------+------------+
| starting             | 0.000051 | 0.000000 | 0.000000 |
| -------------------- | -------- | -------- | -------- |
|                      |          |          |          |
| checking permissions | 0.000005 | 0.000000 | 0.000000 |
| -------------------- | -------- | -------- | -------- |
|                      |          |          |          |
| Opening tables       | 0.000015 | 0.000000 | 0.000000 |
| --------------       | -------- | -------- | -------- |
|                      |          |          |          |
| init                 | 0.000012 | 0.000000 | 0.000000 |
| ----                 | -------- | -------- | -------- |
|                      |          |          |          |
| System lock          | 0.000007 | 0.000000 | 0.000000 |
| -----------          | -------- | -------- | -------- |
|                      |          |          |          |
| optimizing           | 0.000003 | 0.000000 | 0.000000 |
| ----------           | -------- | -------- | -------- |
|                      |          |          |          |
| statistics           | 0.000011 | 0.000000 | 0.000000 |
| ----------           | -------- | -------- | -------- |
|                      |          |          |          |
| preparing            | 0.000009 | 0.000000 | 0.000000 |
| ---------            | -------- | -------- | -------- |
|                      |          |          |          |
| executing            | 0.000002 | 0.000000 | 0.000000 |
| ---------            | -------- | -------- | -------- |
|                      |          |          |          |
| Sending data         | 0.000224 | 0.000000 | 0.000000 |
| ------------         | -------- | -------- | -------- |
|                      |          |          |          |
| end                  | 0.000004 | 0.000000 | 0.000000 |
| ----                 | -------- | -------- | -------- |
|                      |          |          |          |
| query end            | 0.000007 | 0.000000 | 0.000000 |
| ---------            | -------- | -------- | -------- |
|                      |          |          |          |
| closing tables       | 0.000006 | 0.000000 | 0.000000 |
| --------------       | -------- | -------- | -------- |
|                      |          |          |          |
| freeing items        | 0.000009 | 0.000000 | 0.000000 |
| -------------        | -------- | -------- | -------- |
|                      |          |          |          |
| cleaning up          | 0.000008 | 0.000000 | 0.000000 |
| -----------          | -------- | -------- | -------- |
|                      |          |          |          |
+----------------------+----------+----------+------------+
15 rows in set, 1 warning (0.00 sec)
(root@localhost) [sakila]> SELECT @@profiling;
+-------------+
| @@profiling |
+-------------+
|           1 |
+-------------+
1 row in set, 1 warning (0.00 sec)
(root@localhost) [sakila]> SHOW PROFILE;
+----------------------+----------+
| Status | Duration |
| ------ | -------- |
|        |          |
+----------------------+----------+
| starting             | 0.000056 |
| -------------------- | -------- |
|                      |          |
| checking permissions | 0.000003 |
| -------------------- | -------- |
|                      |          |
| Opening tables       | 0.000004 |
| --------------       | -------- |
|                      |          |
| init                 | 0.000010 |
| ----                 | -------- |
|                      |          |
| optimizing           | 0.000004 |
| ----------           | -------- |
|                      |          |
| executing            | 0.000007 |
| ---------            | -------- |
|                      |          |
| end                  | 0.000003 |
| ----                 | -------- |
|                      |          |
| query end            | 0.000004 |
| ---------            | -------- |
|                      |          |
| closing tables       | 0.000003 |
| --------------       | -------- |
|                      |          |
| freeing items        | 0.000008 |
| -------------        | -------- |
|                      |          |
| cleaning up          | 0.000010 |
| -----------          | -------- |
|                      |          |
+----------------------+----------+
11 rows in set, 1 warning (0.00 sec)
(root@localhost) [sakila]> set profiling = 0;
Query OK, 0 rows affected, 1 warning (0.00 sec)
(root@localhost) [sakila]> SHOW VARIABLES LIKE 'performance_schema';
+--------------------+-------+
| Variable_name | Value |
| ------------- | ----- |
|               |       |
+--------------------+-------+
| performance_schema | ON   |
| ------------------ | ---- |
|                    |      |
+--------------------+-------+
1 row in set (0.00 sec)

(root@localhost) [(none)]> select connection_id();
ERROR 2006 (HY000): MySQL server has gone away
No connection. Trying to reconnect...
Connection id:    14
Current database: * NONE *
+-----------------+
| connection_id() |
+-----------------+
|              14 |
+-----------------+
1 row in set (0.00 sec)

(root@localhost) [mytest]> begin;
Query OK, 0 rows affected (0.00 sec)
(root@localhost) [mytest]> insert into t5 (i) values (2),(3);
Query OK, 2 rows affected (0.39 sec)
Records: 2  Duplicates: 0  Warnings: 0
(root@localhost) [mytest]> savepoint s1;
Query OK, 0 rows affected (0.00 sec)
(root@localhost) [mytest]> insert into t5 (i) values (4),(5);
Query OK, 2 rows affected (0.00 sec)
Records: 2  Duplicates: 0  Warnings: 0
(root@localhost) [mytest]> savepoint s2;
Query OK, 0 rows affected (0.00 sec)
(root@localhost) [mytest]> insert into t5 (i) values (6),(7);
Query OK, 2 rows affected (0.00 sec)
Records: 2  Duplicates: 0  Warnings: 0
(root@localhost) [mytest]> select * from t5;
+---+
| i |
+---+
| 2 |
| 3 |
| 4 |
| 5 |
| 6 |
| 7 |
+---+
6 rows in set (0.00 sec)
(root@localhost) [mytest]> rollback to savepoint s2;
Query OK, 0 rows affected (0.00 sec)
(root@localhost) [mytest]> select * from t5;
+---+
| i |
+---+
| 2 |
| 3 |
| 4 |
| 5 |
+---+
4 rows in set (0.00 sec)
(root@localhost) [mytest]> rollback;
Query OK, 0 rows affected (0.00 sec)
(root@localhost) [mytest]> select * from t5;
Empty set (0.00 sec)
SHOW GLOBAL STATUS like '%binlog%';
###/etc/sysctl.cnf
vm.swappiness ≤ 10
vm.dirty_ratio ≤ 5
vm.dirty_background_ratio ≤ 10
or
echo 5 >/proc/sys/vm/swappiness
```

![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B26%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B27%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B28%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B29%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B30%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B31%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B32%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B33%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B34%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B35%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B36%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B37%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B38%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B39%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B40%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B41%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B42%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B43%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B44%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B45%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B46%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B47%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B48%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B49%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B50%5D.png)
![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B51%5D.png)

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
        Payment: 43.49% (>=43.0%) [OK]
   Order-Status: 4.42% (>= 4.0%) [OK]
       Delivery: 3.93% (>= 4.0%) [NG] *
    Stock-Level: 4.18% (>= 4.0%) [OK][response time (at least 90% passed)]
      New-Order: 0.00%  [NG] *
        Payment: 0.00%  [NG] *
   Order-Status: 83.33%  [NG] *
       Delivery: 0.00%  [NG] *
    Stock-Level: 47.06%  [NG] *
<TpmC>
                 2148.000 TpmC
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

## 4. 优化器

### 4.1 索引

### 4.2 解释计划

```mysql
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
explain select emp_no,first_name,last_name from employees where emp_no in (select emp_no from dept_manager);;
explain extended select emp_no,first_name,last_name from employees where emp_no in (select emp_no from dept_manager);

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
mysql> desc FORMAT = JSON select * from employees where emp_no = 23344;
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
```

![](MySQL%E5%B8%B8%E7%94%A8%E8%AF%AD%E5%8F%A5.assets/Image%20%5B3%5D.png)

###  4.3 统计信息

```
use sys

select * from  x$schema_index_statistics limit 1 ;

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
SQL> show variables like '%join%buffer%';
+------------------+-----------+
| Variable_name    | Value     |
+------------------+-----------+
| join_buffer_size | 134217728 |
+------------------+-----------+
1 row in set (0.00 sec)
SQL> select 134217728/1024/1024;
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
(root@localhost) [employees]> explain select /*+ MRR(salaries) */ * from salaries where salary>1000 and salary <40000;
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
(root@localhost) [employees]> explain select /*+ MRR(salaries) */ * from salaries where salary>1000 and salary <40000;
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

```

### 4.4 hint

### 4.5 并行

## 5.  慢SQL日志

```mysql
# mysqldumpslow /data/slow.log

Reading mysql slow query log from /data/slow.log
Count: 1  Time=0.00s (0s)  Lock=0.00s (0s)  Rows=17.0 (17), root[root]@[192.168.45.1]
  SELECT STATE AS Status, ROUND(SUM(DURATION),N) AS Duration, CONCAT(ROUND(SUM(DURATION)/N.N*N,N), 'S') AS Percentage FROM INFORMATION_SCHEMA.PROFILING WHERE QUERY_ID=N GROUP BY SEQ, STATE ORDER BY SEQ
Count: 1  Time=0.00s (0s)  Lock=0.00s (0s)  Rows=0.0 (0), 0users@0hosts
  bin/mysqld, Version: N.N.N-log (MySQL Community Server (GPL)). started with:
  
-- 修改slow_log表存储引擎 
set global slow_query_log=0;
alter table mysql.slow_log engine = myisam;
set global slow_query_log=1;
```

## 6. 基准测试

### 6.1 sysbench

[sysbench]: https://Git.com/akopytov/sysbench#linux	"sysbench github"

```shell
# sysbench --test=cpu --cpu-max-prime=10000 run

WARNING: the --test option is deprecated. You can pass a script name or path on the command line without any options.
sysbench 1.0.13 (using bundled LuaJIT 2.1.0-beta2)
Running the test with following options:
Number of threads: 1

Initializing random number generator from current time
Prime numbers limit: 10000
Initializing worker threads...
Threads started!

CPU speed:
events per second:   914.21

General statistics:
total time:                          10.0004s
total number of events:              9144

Latency (ms):
     min:                                    1.04
     avg:                                    1.09
     max:                                    2.30
     95th percentile:                        1.16
     sum:                                 9993.36

Threads fairness:
events (avg/stddev):           9144.0000/0.00
execution time (avg/stddev):   9.9934/0.00



# sysbench /usr/share/sysbench/oltp_read_only.lua --mysql-host=127.0.0.1 --mysql-port=3306 --mysql-user=root --mysql-password='oracle' --mysql-db=mytest --db-driver=mysql --tables=10 --table-size=1000000 --report-interval=10 --threads=128 --time=120 prepare

# sysbench /usr/share/sysbench/oltp_read_only.lua --mysql-host=127.0.0.1 --mysql-port=3306 --mysql-user=root --mysql-password='oracle' --mysql-db=mytest --db-driver=mysql --tables=10 --table-size=1000000 --report-interval=10 --threads=128 --time=120 run
```

### 6.2 mysqlslap

![](MySQL%E6%95%B0%E6%8D%AE%E5%BA%93%E6%A3%80%E6%9F%A5.assets/Image%20%5B11%5D.png)

![](MySQL%E6%95%B0%E6%8D%AE%E5%BA%93%E6%A3%80%E6%9F%A5.assets/Image%20%5B12%5D.png)

![](MySQL%E6%95%B0%E6%8D%AE%E5%BA%93%E6%A3%80%E6%9F%A5.assets/Image%20%5B13%5D.png)

```mysql
# mysqlslap --concurrency=1,50,100,200 --iterations=3 --number-int-cols=5 --number-char-cols=5 --auto-generate-sql --auto-generate-sql-add-autoincrement --engine=myisam,innodb --number-of-queries=10 --create-schema=sbtest;



# mysqlslap --concurrency=1,50,100,200 --iterations=3 --number-int-cols=5 --number-char-cols=5 --auto-generate-sql --auto-generate-sql-add-autoincrement --engine=myisam,innodb --number-of-queries=10 --create-schema=sbtest --only-print|more

DROP SCHEMA IF EXISTS `sbtest`;

CREATE SCHEMA `sbtest`;

use sbtest;

set default_storage_engine=`myisam`;

CREATE TABLE `t1` (id serial,intcol1 INT(32) ,intcol2 INT(32) ,intcol3 INT(32) ,intcol4 INT(32) ,intcol5 INT(32) ,charcol1 VARCHAR(128),charcol2 VARCHAR(128

),charcol3 VARCHAR(128),charcol4 VARCHAR(128),charcol5 VARCHAR(128));

INSERT INTO t1 VALUES (NULL,1804289383,846930886,1681692777,1714636915,1957747793,'vmC9127qJNm06sGB8R92q2j7vTiiITRDGXM9ZLzkdekbWtmXKwZ2qG1llkRw5m9DHOFilEREk3q7oce8O3BEJC0woJsm6uzFAEynLH2xCsw1KQ1lT4zg9rdxBLb97R','GHZ65mNzkSrYT3zWoSbg9cNePQr1bzSk81qDgE4Oanw3rnPfGsBHSbnu1evTdFDe83ro9w4jjteQg4yoo9xHck3WNqzs54W5zEm92ikdRF48B2oz3m8gMBAl11Wy50','w46i58Giekxik0cYzfA8BZBLADEg3JhzGfZDoqvQQk0Akcic7lcJInYSsf
```



# 三、MySQL备份容灾

##  1. binlog 日志

```mysql
-- 基于时间查看 binlog 日志
mysqlbinlog  --no-defaults --start-datetime="2016-10-31 23:08:03" mysql-bin.000214 |more
-- 基于位置查看 binlog 日志
mysqlbinlog --no-defaults --start-position=690271 mysql-bin.000214 |more
```

**mysqlbinlog命令查看binglog_format=row的日志**

在配置文件中配置有`binglog_format=row`的数据库产生的 binglog 日志是不能以正常的`mysqlbinlog logfile`的方式打开的, 默认情况下只能看到一些经过base-64编码的信息

- 从MySQL 5.1.28开始，mysqlbinlog多了个参数–verbose(或-v)，将改动生成带注释的语句，如果使用两次这个参数(如-v -v)，会生成字段的类型、长度、是否为null等属性信息
- 加–base64-output=DECODE-ROWS参数还可以去掉BINLOG开头的信息

```
mysqlbinlog -v -v --base64-output=DECODE-ROWS mysql-bin.000003
```

## 2. 复制
###  2.1 复制需备份二进制日志

```
mysql> reset master;
mysql> show master status;
mysql> start slave for channel ch1
```
### 2.2 针对某个DB复制

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

## 3. mysqldump

```mysql
 mysqldump -uroot -poracle -B -A --events -x |gzip>/app/mysqlbak$(date +%F%T).sql.gz
 mysqldump -uroot -poracle -B -A --events -x |gzip>/app/mysqlbak`date +%F%T`.sql.gz
 mysqldump -uroot -poracle -B  --events -x  wordpress|gzip>/app/mysqlbak`date +%F%T`.sql.gz
 
-- 5.7.22新特性
mysql 5.7.22，去掉--flush-logs，只使用mysqldump -uroot -proot --default-character-set=utf8  --single-transaction --master-data=2 备份，也是会发出FLUSH TABLES WITH READ LOCK 
```
## 4. XtraBackup

## 5. 防止误删数据？
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

# 四、MySQL数据库开发

## 1. 数据库操作

### 1.1 基本操作

```mysql
-- 登录 mysql -h ip -P 端⼜ -u ⽤户名 -p
mysql -h localhost -P 3306 -u root -p
-- 查看数据库版本
mysql -V
mysql --version
select version();    -- 登录情况下，查看链接的库版本
-- 如果【某数据库】存在就删除【某数据库】 
DROP DATABASE IF EXISTS db;
-- 如果【某数据库】不存在就创建【某数据库】
CREATE DATABASE IF NOT EXISTS db;
CREATE DATABASE IF NOT EXISTS yourdbname DEFAULT CHARSET utf8 COLLATE utf8_general_ci;
create database yourdb DEFAULT CHARACTER SET gbk COLLATE gbk_chinese_ci;
-- 显示所有数据库
show databases;
-- 进⼊指定的库：use 库名;
USE db;
-- 显示当前库中所有的表
show tables;
-- 查看其他库中所有的表：show tables from 库名;
show tables from seata;
-- 查看表的创建语句：show create table 表名;
show create database mytest;
-- 查看表结构：desc 表名;
desc biz_tags;
-- 查看当前所在库：
select database();
-- 查看当前mysql⽀持的存储引擎
SHOW ENGINES;
-- 查看系统变量及其值
SHOW VARIABLES;
-- 查看某个系统变量：SHOW VARIABLES like '变量名';
SHOW VARIABLES like 'wait_timeout';
SHOW VARIABLES like '%timeout%';
-- 修改数据库字符集
alter database sampdb character set utf8 collate utf8_general_ci;
```
### 1.2 MySQL语法规范

1. 不区分⼤⼩写，但建议关键字⼤写，表名、列名⼩写

2. 每条命令最好⽤英⽂分号结尾

3. 每条命令根据需要，可以进⾏缩进或换⾏

4. 注释
    – 单⾏注释：#注释⽂字
    – 单⾏注释：-- 注释⽂字 ，注意， 这⾥需要加空格
    – 多⾏注释：/* 注释⽂字 */

### 1.3 SQL的语⾔分类
-  DQL（Data Query Language）：数据查询语⾔ select 相关语句
-  DML（Data Manipulate Language）：数据操作语⾔ insert 、update、delete 语句
- DDL（Data De>ine Languge）：数据定义语⾔ create、drop、alter 语句
-  TCL（Transaction Control Language）：事务控制语⾔ set autocommit=0、start transaction、savepoint、commit、rollback

### 1.4 MySQL的数据类型

主要包括以下五⼤类

- 整数类型：bit、bool、tinyint、smallint、mediumint、int、bigint
- 浮点数类型：float、double、decimal
- 字符串类型：char、varchar、tinyblob、blob、mediumblob、longblob、tinytext、text、mediumtext、longtext
- ⽇期类型：Date、DateTime、TimeStamp、Time、Year
- 其他数据类型：暂不介绍，⽤的⽐较少。

**整数类型**

| 类型                      | 字节数 | 有符号值范围       | 无符号值范围 |
| ------------------------- | ------ | ------------------ | ------------ |
| tinyint[(n)] [unsigned]   | 1      | [- 2^7^, 2^7^-1]   | [0, 2^8^-1]  |
| smallint[(n)] [unsigned]  | 2      | [- 2^15^, 2^15^-1] | [0, 2^16^-1] |
| mediumint[(n)] [unsigned] | 3      | [- 2^23^, 2^23^-1] | [0, 2^24^-1] |
| int[(n)] [unsigned]       | 4      | [- 2^31^, 2^31^-1] | [0, 2^32^-1] |
| bigint[(n)] [unsigned]    | 8      | [- 2^63^, 2^63^-1] | [0, 2^64^-1] |

上面[]包含的内容是可选的，默认是有符号类型的，无符号的需要在类型后面跟上unsigned

```sql
-- 有符号类型
mysql> create table demo1(
c1 tinyint
);
Query OK, 0 rows affected (0.01 sec)
mysql> insert into demo1 values(-pow(2,7)),(pow(2,7)-1);
Query OK, 2 rows affected (0.00 sec)
Records: 2 Duplicates: 0 Warnings: 0
mysql> select * from demo1;
+------+
| c1 |
+------+
| -128 |
| 127 |
+------+
2 rows in set (0.00 sec)
mysql> insert into demo1 values(pow(2,7));
ERROR 1264 (22003): Out of range value for column 'c1' at row 1
-- demo1表中c1 字段为tinyint有符号类型的，可以看一下上面的演示，有超出范围报错的。关于数值对应的范围计算方式属于计算机基础的一些知识，可以去看一下计算机的二进制表示相关的文
章。

--无符号类型
mysql> create table demo2(
c1 tinyint unsigned
);
Query OK, 0 rows affected (0.01 sec)
mysql> insert into demo2 values (-1);
ERROR 1264 (22003): Out of range value for column 'c1' at row 1
mysql> insert into demo2 values (pow(2,8)+1);
ERROR 1264 (22003): Out of range value for column 'c1' at row 1
mysql> insert into demo2 values (0),(pow(2,8));
mysql> insert into demo2 values (0),(pow(2,8)-1);
Query OK, 2 rows affected (0.00 sec)
Records: 2 Duplicates: 0 Warnings: 0
mysql> select * from demo2;
+------+
| c1 |
+------+
| 0 |
| 255 |
+------+
2 rows in set (0.00 sec)
-- c1是⽆符号的tinyint类型的，插⼊了负数会报错。
```



## 2. 分区表

### 2.1 分区类型

### 2.2 分区管理

### 2.3 分区查询

## 3. 表

### 3.1 常用操作

```mysql
## 如果【某表】存在就删除【某表】
DROP TABLE IF EXISTS tb;
## 如果【某表】不存在就创建【某表】
CREATE TABLE IF NOT EXISTS tb
## 添加表字段
alter table` 表名称` add transactor varchar(10) not Null;
alter table  `表名称` add id int unsigned not Null auto_increment primary key
## 修改某个表的字段类型及指定为空或非空
alter table `表名称` change 字段名称 字段名称 字段类型 [是否允许非空];
alter table `表名称` modify 字段名称 字段类型 [是否允许非空];
## 修改某个表的字段名称及指定为空或非空 
alter table `表名称` change 字段原名称 字段新名称 字段类型 [是否允许非空
## 删除某一字段
ALTER TABLE `表名称` DROP 字段名;
## 添加唯一键
ALTER TABLE `表名称` ADD UNIQUE ( `userid`)
## 修改主键
ALTER TABLE `表名称` DROP PRIMARY KEY ,ADD PRIMARY KEY ( `id` )
## 增加索引
ALTER TABLE `表名称` ADD INDEX ( `id` )
ALTER TABLE `表名称` MODIFY COLUMN `id`  int(11) NOT NULL AUTO_INCREMENT FIRST ,ADD PRIMARY KEY (`id`);
## 查看表的字段信息
desc 表名
describe mysql.user;
desc mysql.user;
show columns from `表名`；

## 查看表的所有信息
show create table `表名`;
## 添加主键约束
alter table `表名` add constraint 主键名称（形如：PK_表名） primary key 表名(主键字段);
alter table  `表名` add 列名 列类型 unsigned 是否为空 auto_increment primary key；
## 添加外键约束
alter table `从表` add constraint 外键（形如：FK_从表_主表） foreign key 从表(外键字段) references 主表(主键字段);
(alter table `主表名` add foreign key (字段 ) references 从表名(字段) on delete cascade)
## 添加唯一约束 
ALTER table `表名` add unique key 约束名 (字段);
## 删除主键约束
alter table `表名` drop primary key;
## 删除外键约束
alter table `表名` drop foreign key 外键（区分大小写）;
## 修改表名
alter table `表名称` rename to bbb;
## 修改表的注释 
ALTER TABLE `表名称` COMMENT '学生表2.0';
## 查看数据库表
show tables from sampdb;
show tables in employees;

## 查看表的详细信息
SHOW CREATE TABLE `表名称`
## 修改字段的注释信息 
ALTER TABLE `表名` MODIFY COLUMN `列名` `数据类型` COMMENT '备注信息';
## 查看字段的详细信息 
SHOW FULL COLUMNS  FROM `表名称`;
## 查看字段的简要信息
SHOW COLUMNS FROM `表名称`;
## 查询当前数据库中所有表
select table_name from information_schema.tables where table_schema='当前数据库';
## 查询当前数据库中所有表的约束（详情）
select * from INFORMATION_SCHEMA.KEY_COLUMN_USAGE where Constraint_Schema='test_StringEntityTest';
## 查询当前数据库中所有表的约束（简单）
select * from information_schema.Table_Constraints where Constraint_Schema='test_StringEntityTest';
```
### 3.2 修改主键SQL

```mysql
declare @defname varchar(100)
declare @cmd varchar(500)
declare @tablename varchar(100)
declare @keyname varchar(100)
Set @tablename='Temp1'
Set @keyname='id' --需要設置的key,分隔
select @defname= name
   FROM sysobjects so 
   JOIN sysconstraints sc
   ON so.id = sc.constid
   WHERE object_name(so.parent_obj) = @tablename
   and xtype='PK'
if @defname is not null
begin
select @cmd='alter table '+ @tablename+ ' drop constraint '+ @defname
--print @cmd
   exec (@cmd)
 end
else
 set @defname='PK_'+@keyname
select @cmd='alter table '+ @tablename+ ' ADD constraint '+ @defname +' PRIMARY KEY CLUSTERED('+@keyname+')'
   exec (@cmd)
```
### 3.3 字段
```mysql
SELECT TABLE_NAME,COLUMN_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME<>'dtproperties'

EXEC sp_pkeys @table_name='表名'

select o.name as 表名,c.name as 字段名,k.colid as 字段序号,k.keyno as 索引顺序,t.name as 类型
from sysindexes i
join sysindexkeys k on i.id = k.id and i.indid = k.indid
join sysobjects o on i.id = o.id
join syscolumns c on i.id=c.id and k.colid = c.colid
join systypes t on c.xusertype=t.xusertype
where o.xtype = 'U' and o.name='要查询的表名'
and exists(select 1 from sysobjects where xtype = 'PK' and parent_obj=i.id and name = i.name)
order by o.name,k.colid

-- 以上就是关于如何修改MySql数据表的字段类型，默认值和增加新的字段。
```
### 3.4 dual表
```mysql
mysql> select 4*4 from dual;
+-----+
| 4*4 |
+-----+
|  16 |
+-----+
1 row in set (0.07 sec)
mysql> select 4*4;
+-----+
| 4*4 |
+-----+
|  16 |
+-----+
1 row in set (0.00 sec)
mysql> select * from dual;
ERROR 1096 (HY000): No tables used
-- Oracle用法
sys@ORCL> select * from dual;
D
-
X
sys@ORCL> select 4*4;
select 4*4
*
ERROR at line 1:
ORA-00923: FROM keyword not found where expected
sys@ORCL> select 4*4 from dual;

4*4
--
16
```

### 3.5 NULL唯一性

Oracle NULL可以多个	MySQL NULL只能一个

## 4. 函数

```mysql
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
```

## 5.  其他特性

### 5.1 计算列

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

## 6. 自定义变量

### 6.1 用户变量  

#### 6.1.1 声明并初始化(要求声明时必须初始化)  

```sql
/*方式1*/
set @变量名=值;
/*方式2*/
set @变量名:=值;
/*方式3*/
select @变量名:=值;
```

> **注意：**
>
> ​		上面使用了 @ 符合，而上面介绍全局变量使用了2个 @ 符号，这点注意区分一下。
>
> ​		set中=号前面冒号是可选的，select方式=前面必须有冒号  

#### 6.1.2 赋值(更新变量的值)

```sql
/*方式1：这块和变量的声明一样*/
set @变量名=值;
set @变量名:=值;
select @变量名:=值;
/*方式2*/
select 字段 into @变量名 from 表;
```

#### 6.1.3 使用  

```sql
select @变量名;
```

#### 6.1.4 综合示例 

```sql
/*set方式创建变量并初始化*/
set @username='路人甲java';
/*select into方式创建变量*/
select 'javacode2018' into @gzh;
select count(*) into @empcount from employees;
/*select :=方式创建变量*/
select @first_name:='路人甲Java',@email:='javacode2018@163.com';
/*使用变量*/
insert into employees (first_name,email) values (@first_name,@email);
```

### 6.2 局部变量  

#### 6.2.1 声明

```sql
declare 变量名 变量类型;
declare 变量名 变量类型 [default 默认值];
```

#### 6.2.2 赋值  

```sql
/*方式1*/
set 局部变量名=值;
set 局部变量名:=值;
select 局部变量名:=值;
/*方式2*/
select 字段 into 局部变量名 from 表;
```

> **注意**：局部变量前面没有 @ 符号  

#### 6.2.3 使用(查看变量的值) 

```sql
select 局部变量名;
```

#### 6.2.4 示例

```sql
/*创建表test1*/
drop table IF EXISTS test1;
create table test1(a int PRIMARY KEY,b int);
/*声明脚本的结束符为$$*/
DELIMITER $$
DROP PROCEDURE IF EXISTS proc1;
CREATE PROCEDURE proc1()
BEGIN
/*声明了一个局部变量*/
DECLARE v_a int;
select ifnull(max(a),0)+1 into v_a from test1;
select @v_b:=v_a*2;
insert into test1(a,b) select v_a,@v_b;
end $$
/*声明脚本的结束符为;*/
DELIMITER ;
/*调用存储过程*/
call proc1();
/*查看结果*/
select * from test1;
```

### 6.3 用户变量和局部变量对比  

|          | 作用域                | 定义位置              | 语法                    |
| -------- | --------------------- | --------------------- | ----------------------- |
| 用户变量 | 当前会话              | 会话的任何地方        | 加 @ 符号，不用指定类型 |
| 局部变量 | 定义他的begin end之间 | begin end中的第一句话 | 不加 @ 符号，要指定类型 |

> **总结**
>
> ​		系统变量可以设置系统的一些配置信息，数据库重启之后会被还原
>
> ​		会话变量可以设置当前会话的一些配置信息，对当前会话起效
>
> ​		declare创建的局部变量常用于存储过程和函数的创建中
>
> ​		作用域：全局变量对整个系统有效、会话变量作用于当前会话、用户变量作用于当前会话、局部变量作用于begin end之间
>
> ​		注意全局变量中用到了 @@ ，用户变量变量用到了 @ ，而局部变量没有这个符号
>
> ​		delimiter 关键字用来声明脚本的结束符  

