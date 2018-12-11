## 使用mysqlbinlog提取二进制日志



[TOC]
## 提取mysqlbinlog的几种方式
a、使用show binlog events方式可以获取当前以及指定binlog的日志，不适宜提取大量日志。
b、使用mysqlbinlog命令行提取(适宜批量提取日志)。

## 演示show binlog events方式
```sql
mysql> show variables like 'version';
+---------------+------------+
| Variable_name | Value      |
+---------------+------------+
| version       | 5.6.12-log |
+---------------+------------+
mysql> show binary logs;
+-----------------+-----------+
| Log_name        | File_size |
+-----------------+-----------+
| APP01bin.000001 |       120 |
+-----------------+-----------+
```
1. 只查看第一个binlog文件的内容(show binlog events)

```
mysql> use replication;
Database changed
mysql> select * from tb;
+------+-------+
| id   | val   |
+------+-------+
|    1 | robin |
+------+-------+
mysql> insert into tb values(2,'jack');
Query OK, 1 row affected (0.02 sec)
mysql> flush logs;
Query OK, 0 rows affected (0.00 sec)
mysql> insert into tb values(3,'fred');
Query OK, 1 row affected (0.00 sec)
mysql> show binary logs;
+-----------------+-----------+
| Log_name        | File_size |
+-----------------+-----------+
| APP01bin.000001 |       409 |
| APP01bin.000002 |       363 |
+-----------------+-----------+
mysql> show binlog events;
+-----------------+-----+-------------+-----------+-------------+----------------------------------------------------+
| Log_name        | Pos | Event_type  | Server_id | End_log_pos | Info                                               |
+-----------------+-----+-------------+-----------+-------------+----------------------------------------------------+
| APP01bin.000001 |   4 | Format_desc |        11 |         120 | Server ver: 5.6.12-log, Binlog ver: 4              |
| APP01bin.000001 | 120 | Query       |        11 |         213 | BEGIN                                              |
| APP01bin.000001 | 213 | Query       |        11 |         332 | use `replication`; insert into tb values(2,'jack') |
| APP01bin.000001 | 332 | Xid         |        11 |         363 | COMMIT /* xid=382 */                               |
| APP01bin.000001 | 363 | Rotate      |        11 |         409 | APP01bin.000002;pos=4                              |
+-----------------+-----+-------------+-----------+-------------+----------------------------------------------------+
```
在上面的结果中第3行可以看到我们执行的SQL语句，第4行为自动提交

2. 查看指定binlog文件的内容(show binlog events in 'binname.xxxxx')

```
mysql> show binlog events in 'APP01bin.000002';
+-----------------+-----+-------------+-----------+-------------+----------------------------------------------------+
| Log_name        | Pos | Event_type  | Server_id | End_log_pos | Info                                               |
+-----------------+-----+-------------+-----------+-------------+----------------------------------------------------+
| APP01bin.000002 |   4 | Format_desc |        11 |         120 | Server ver: 5.6.12-log, Binlog ver: 4              |
| APP01bin.000002 | 120 | Query       |        11 |         213 | BEGIN                                              |
| APP01bin.000002 | 213 | Query       |        11 |         332 | use `replication`; insert into tb values(3,'fred') |
| APP01bin.000002 | 332 | Xid         |        11 |         363 | COMMIT /* xid=394 */                               |
+-----------------+-----+-------------+-----------+-------------+----------------------------------------------------+
```
3. 查看当前正在写入的binlog文件(show master status\G)

```
mysql> show master status\G
*************************** 1. row ***************************
File: APP01bin.000002
Position: 363
Binlog_Do_DB:
Binlog_Ignore_DB:
Executed_Gtid_Set:
1 row in set (0.00 sec)
```
4. 获取指定位置binlog的内容(show binlog events from)

```
mysql> show binlog events from 213;
+-----------------+-----+------------+-----------+-------------+----------------------------------------------------+
| Log_name        | Pos | Event_type | Server_id | End_log_pos | Info                                               |
+-----------------+-----+------------+-----------+-------------+----------------------------------------------------+
| APP01bin.000001 | 213 | Query      |        11 |         332 | use `replication`; insert into tb values(2,'jack') |
| APP01bin.000001 | 332 | Xid        |        11 |         363 | COMMIT /* xid=382 */                               |
| APP01bin.000001 | 363 | Rotate     |        11 |         409 | APP01bin.000002;pos=4                              |
+-----------------+-----+------------+-----------+-------------+----------------------------------------------------+
```
## 演示mysqlbinlog方式提取binlog
- 提取指定的binlog日志

```
#mysqlbinlog /opt/data/APP01bin.000001
#mysqlbinlog /opt/data/APP01bin.000001|grep insert
/*!40019 SET @@session.max_insert_delayed_threads=0*/;
insert into tb values(2,'jack')
```
- 提取指定position位置的binlog日志

```
#mysqlbinlog --start-position="120" --stop-position="332" /opt/data/APP01bin.000001
```
- 提取指定position位置的binlog日志并输出到压缩文件

```
#mysqlbinlog --start-position="120" --stop-position="332" /opt/data/APP01bin.000001 |gzip >extra_01.sql.gz
```
- 提取指定position位置的binlog日志导入数据库

```
#mysqlbinlog --start-position="120" --stop-position="332" /opt/data/APP01bin.000001 | mysql -uroot -p
```
- 提取指定开始时间的binlog并输出到日志文件

```
#mysqlbinlog --start-datetime="2014-12-15 20:15:23" /opt/data/APP01bin.000002 --result-file=extra02.sql
```
- 提取指定位置的多个binlog日志文件

```
#mysqlbinlog --start-position="120" --stop-position="332" /opt/data/APP01bin.000001 /opt/data/APP01bin.000002|more
```
- 提取指定数据库binlog并转换字符集到UTF8

```
#mysqlbinlog --database=test --set-charset=utf8 /opt/data/APP01bin.000001 /opt/data/APP01bin.000002 >test.sql
```
- 远程提取日志，指定结束时间

```
#mysqlbinlog -urobin -p -h192.168.1.116 -P3306 --stop-datetime="2014-12-15 20:30:23" --read-from-remote-server mysql-bin.000033 |more
```
- 远程提取使用row格式的binlog日志并输出到本地文件

```
#mysqlbinlog -urobin -p -P3606 -h192.168.1.177 --read-from-remote-server -vv inst3606bin.000005 >row.sql
```
## 获取mysqlbinlog的帮助信息(仅列出常用选项)
```
-?, --help
显示帮助消息并退出。
-d, --database=name
只列出该数据库的条目(只适用本地日志)。
-f, --force-read
使用该选项，如果mysqlbinlog读它不能识别的二进制日志事件，它会打印警告，忽略该事件并继续。没有该选项，如果mysqlbinlog读到此类事件则停止。
-h, --host=name
获取给定主机上的MySQL服务器的二进制日志。
-l, --local-load=name
为指定目录中的LOAD DATA INFILE预处理本地临时文件。
-o, --offset=#
跳过前N个条目。
-p, --password[=name]
当连接服务器时使用的密码。如果使用短选项形式(-p)，选项和密码之间不能有空格。
如果在命令行中–password或-p选项后面没有密码值，则提示输入一个密码。
-P, --port=#
用于连接远程服务器的TCP/IP端口号。
--protocol=name
使用的连接协议。
-R, --read-from-remote-server|--read-from-remote-master=name
从MySQL服务器读二进制日志。如果未给出该选项，任何连接参数选项将被忽略，即连接到本地。
这些选项是–host、–password、–port、–protocol、–socket和–user。
-r, --result-file=name
将输出指向给定的文件。
-s, --short-form
只显示日志中包含的语句，不显示其它信息，该方式可以缩小生成sql文件的尺寸。
-S, --socket=name
用于连接的套接字文件。
--start-datetime=name
从二进制日志中读取等于或晚于datetime参量的事件，datetime值相对于运行mysqlbinlog的机器上的本地时区。
该值格式应符合DATETIME或TIMESTAMP数据类型。例如：2004-12-25 11:25:56 ，建议使用引号标识。
--stop-datetime=name
从二进制日志中读取小于或等于datetime的所有日志事件。关于datetime值的描述参见--start-datetime选项。
-j, --start-position=#
从二进制日志中第1个位置等于N参量时的事件开始读。
--stop-position=#
从二进制日志中第1个位置等于和大于N参量时的事件起停止读。
--server-id=#
仅仅提取指定server_id的binlog日志
--set-charset=name
添加SET NAMES character_set到输出
-t, --to-last-log
在MySQL服务器中请求的二进制日志的结尾处不停止，而是继续打印直到最后一个二进制日志的结尾。
如果将输出发送给同一台MySQL服务器，会导致无限循环。该选项要求–read-from-remote-server。
-D, --disable-log-bin
禁用二进制日志。如果使用–to-last-logs选项将输出发送给同一台MySQL服务器，可以避免无限循环。
该选项在崩溃恢复时也很有用，可以避免复制已经记录的语句。注释：该选项要求有SUPER权限。
-u, --user=name
连接远程服务器时使用的MySQL用户名。
-v, --verbose
用于输出基于row模式的binlog日志，-vv为列数据类型添加注释
-V, --version
显示版本信息并退出。
```
## binlog格式
Mysql binlog日志有ROW,Statement,MiXED三种格式；
可通过my.cnf配置文件或set global binlog_format='ROW/STATEMENT/MIXED'进行修；
命令行show variables like 'binlog_format'命令查看binglog格式。
- Row level: 仅保存记录被修改细节，不记录sql语句上下文相关信息
- 优点：能非常清晰的记录下每行数据的修改细节，不需要记录上下文相关信息，因此不会发生某些特定情况下的procedure、function、及trigger的调用触发无法被正确复制的问题，任何情况都可以被复制，且能加快从库重放日志的效率，保证从库数据的一致性
- 缺点:由于所有的执行的语句在日志中都将以每行记录的修改细节来记录，因此，可能会产生大量的日志内容，干扰内容也较多；比如一条update语句，如修改多条记录，则binlog中每一条修改都会有记录，这样造成binlog日志量会很大，特别是当执行alter table之类的语句的时候，由于表结构修改，每条记录都发生改变，那么该表每一条记录都会记录到日志中，实际等于重建了表。
- tip:   - row模式生成的sql编码需要解码，不能用常规的办法去生成，需要加上相应的参数(--base64-output=decode-rows -v)才能显示出sql语句;
- 新版本binlog默认为ROW level，且5.6新增了一个参数：binlog_row_image；把binlog_row_image设置为minimal以后，binlog记录的就只是影响的列，大大减少了日志内容
- Statement level: 每一条会修改数据的sql都会记录在binlog中
- 优点：只需要记录执行语句的细节和上下文环境，避免了记录每一行的变化，在一些修改记录较多的情况下相比ROW level能大大减少binlog日志量，节约IO，提高性能；还可以用于实时的还原；同时主从版本可以不一样，从服务器版本可以比主服务器版本高
- 缺点：为了保证sql语句能在slave上正确执行，必须记录上下文信息，以保证所有语句能在slave得到和在master端执行时候相同的结果；另外，主从复制时，存在部分函数（如sleep）及存储过程在slave上会出现与master结果不一致的情况，而相比Row level记录每一行的变化细节，绝不会发生这种不一致的情况
- Mixedlevel level: 以上两种level的混合
- 使用经过前面的对比，可以发现ROW level和statement level各有优势，如能根据sql语句取舍可能会有更好地性能和效果；Mixed level便是以上两种leve的结合。不过，新版本的MySQL对row level模式也被做了优化，并不是所有的修改都会以row level来记录，像遇到表结构变更的时候就会以statement模式来记录，如果sql语句确实就是update或者delete等修改数据的语句，那么还是会记录所有行的变更；因此，现在一般使用row level即可。
- 选取规则如果是采用 INSERT，UPDATE，DELETE 直接操作表的情况，则日志格式根据 binlog_format 的设定而记录
- 如果是采用 GRANT，REVOKE，SET PASSWORD 等管理语句来做的话，那么无论如何都采用statement模式记录
## 复制
复制是mysql最重要的功能之一，mysql集群的高可用、负载均衡和读写分离都是基于复制来实现的；从5.6开始复制有两种实现方式，基于binlog和基于GTID（全局事务标示符）；本文接下来将介绍基于binlog的一主一从复制；其复制的基本过程如下：
```
1. Master将数据改变记录到二进制日志(binary log)中
2. Slave上面的IO进程连接上Master，并请求从指定日志文件的指定位置（或者从最开始的日志）之后的日志内容
3. Master接收到来自Slave的IO进程的请求后，负责复制的IO进程会根据请求信息读取日志指定位置之后的日志信息，返回给Slave的IO进程。返回信息中除了日志所包含的信息之外，还包括本次返回的信息已经到Master端的bin-log文件的名称以及bin-log的位置
4. Slave的IO进程接收到信息后，将接收到的日志内容依次添加到Slave端的relay-log文件的最末端，并将读取到的Master端的 bin-log的文件名和位置记录到master-info文件中，以便在下一次读取的时候能够清楚的告诉Master从某个bin-log的哪个位置开始往后的日志内容
5. Slave的Sql进程检测到relay-log中新增加了内容后，会马上解析relay-log的内容成为在Master端真实执行时候的那些可执行的内容，并在自身执行
```
接下来使用实例演示基于binlog的主从复制：
1. 配置master
主要包括设置复制账号，并授予REPLICATION SLAVE权限，具体信息会存储在于master.info文件中，及开启binlog；
```
mysql> CREATE USER 'test'@'%' IDENTIFIED BY '123456';
mysql> GRANT REPLICATION SLAVE ON *.* TO 'test'@'%';
mysql> show variables like "log_bin";
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| log_bin       | ON    |
+---------------+-------+
```
查看master当前binlogmysql状态：
```
mysql> show master status;
+------------------+----------+--------------+------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+------------------+----------+--------------+------------------+-------------------+
| mysql-bin.000003 |      120 |              |                  |                   |
+------------------+----------+--------------+------------------+-------------------+
```
建表插入数据：
```
SQL> CREATE TABLE `tb_person` (
`id` int(11) NOT NULL AUTO_INCREMENT,
`name` varchar(36) NOT NULL,
`address` varchar(36) NOT NULL DEFAULT '',
`sex` varchar(12) NOT NULL DEFAULT 'Man' ,
`other` varchar(256) NOT NULL ,
PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;
SQL> insert into tb_person  set name="name1", address="beijing", sex="man", other="nothing";
SQL> insert into tb_person  set name="name2", address="beijing", sex="man", other="nothing";
SQL> insert into tb_person  set name="name3", address="beijing", sex="man", other="nothing";
SQL>insert into tb_person  set name="name4", address="beijing", sex="man", other="nothing";
```
2. 配置slave
Slave的配置类似master，需额外设置relay_log参数，slave没有必要开启二进制日志，如果slave为其它slave的master，须设置bin_log
3. 连接master
```
mysql> CHANGE MASTER TO
MASTER_HOST='10.108.111.14',
MASTER_USER='test',
MASTER_PASSWORD='123456',
MASTER_LOG_FILE='mysql-bin.000003',
MASTER_LOG_POS=120;
```
4. show slave status;
```
mysql> show slave status\G
*************************** 1. row ***************************
Slave_IO_State:   ---------------------------- slave io状态，表示还未启动
Master_Host: 10.108.111.14
Master_User: test
Master_Port: 20126
Connect_Retry: 60   ----- master宕机或连接丢失从服务器线程重新尝试连接主服务器之前睡眠时间
Master_Log_File: mysql-bin.000003  ------------ 当前读取master binlog文件
Read_Master_Log_Pos: 120  ------------------------- slave读取master binlog文件位置
Relay_Log_File: relay-bin.000001  ------------ 回放binlog
Relay_Log_Pos: 4   -------------------------- 回放relay log位置
Relay_Master_Log_File: mysql-bin.000003  ------------ 回放log对应maser binlog文件
Slave_IO_Running: No
Slave_SQL_Running: No
Exec_Master_Log_Pos: 0  -------------------------- 相对于master从库的sql线程执行到的位置
Seconds_Behind_Master: NULL
```
Slave_IO_State, Slave_IO_Running, 和Slave_SQL_Running为NO说明slave还没有开始复制过程。
5. 启动复制
```
start slave
```
6. 再次观察slave状态
```
mysql> show slave status\G
*************************** 1. row ***************************
Slave_IO_State: Waiting for master to send event -- 等待master新的event
Master_Host: 10.108.111.14
Master_User: test
Master_Port: 20126
Connect_Retry: 60
Master_Log_File: mysql-bin.000003
Read_Master_Log_Pos: 3469  ---------------------------- 3469  等于Exec_Master_Log_Pos，已完成回放
Relay_Log_File: relay-bin.000002                    ||
Relay_Log_Pos: 1423                                ||
Relay_Master_Log_File: mysql-bin.000003                    ||
Slave_IO_Running: Yes                                 ||
Slave_SQL_Running: Yes                                 ||
Exec_Master_Log_Pos: 3469  -----------------------------3469  等于slave读取master binlog位置，已完成回放
Seconds_Behind_Master: 0
```
可看到slave的I/O和SQL线程都已经开始运行，而且Seconds_Behind_Master=0。Relay_Log_Pos增加，意味着一些事件被获取并执行了。
最后看下如何正确判断SLAVE的延迟情况，判定slave是否追上master的binlog：

- 首先看 Relay_Master_Log_File 和 Maser_Log_File 是否有差异；
- 如果Relay_Master_Log_File 和 Master_Log_File 是一样的话，再来看Exec_Master_Log_Pos 和 Read_Master_Log_Pos 的差异，对比SQL线程比IO线程慢了多少个binlog事件；
- 如果Relay_Master_Log_File 和 Master_Log_File 不一样，那说明延迟可能较大，需要从MASTER上取得binlog status，判断当前的binlog和MASTER上的差距；
7. 查询slave数据，主从一致

```
mysql> select * from tb_person;
+----+-------+---------+-----+---------+
| id | name  | address | sex | other   |
+----+-------+---------+-----+---------+
|  5 | name4 | beijing | man | nothing |
|  6 | name2 | beijing | man | nothing |
|  7 | name1 | beijing | man | nothing |
|  8 | name3 | beijing | man | nothing |
+----+-------+---------+-----+---------+
```
关于mysql复制的内容还有很多，比如不同的同步方式、复制格式情况下有什么区别，有什么特点，应该在什么情况下使用....这里不再一一介绍。
## 恢复
恢复是binlog的两大主要作用之一，接下来通过实例演示如何利用binlog恢复数据：
a.首先，看下当前binlog位置

```
mysql> show master status;
+------------------+----------+--------------+------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+------------------+----------+--------------+------------------+-------------------+
| mysql-bin.000008 |     1847 |              |                  |                   |
+------------------+----------+--------------+------------------+-------------------+
```
b.向表tb_person中插入两条记录：
```
insert into tb_person  set name="person_1", address="beijing", sex="man", other="test-1";
insert into tb_person  set name="person_2", address="beijing", sex="man", other="test-2";
```
c.记录当前binlog位置：
```
mysql> show master status;
+------------------+----------+--------------+------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+------------------+----------+--------------+------------------+-------------------+
| mysql-bin.000008 |     2585 |              |                  |                   |
+------------------+----------+--------------+------------------+-------------------+
```
d.查询数据
```
mysql> select *  from tb_person where name ="person_2" or name="person_1";
+----+----------+---------+-----+--------+
| id | name     | address | sex | other  |
+----+----------+---------+-----+--------+
|  6 | person_1 | beijing | man | test-1 |
|  7 | person_2 | beijing | man | test-2 |
+----+----------+---------+-----+--------+
```
e.删除一条: 
```
delete from tb_person where name ="person_2";
mysql> select *  from tb_person where name ="person_2" or name="person_1";
+----+----------+---------+-----+--------+
| id | name     | address | sex | other  |
+----+----------+---------+-----+--------+
|  6 | person_1 | beijing | man | test-1 |
+----+----------+---------+-----+--------+
```
f. binlog恢复（指定pos点恢复/部分恢复）
```
mysqlbinlog   --start-position=1847  --stop-position=2585  mysql-bin.000008  > test.sql
mysql> source /var/lib/mysql/3306/test.sql
```
d.数据恢复完成
```
mysql> select *  from tb_person where name ="person_2" or name="person_1";
+----+----------+---------+-----+--------+
| id | name     | address | sex | other  |
+----+----------+---------+-----+--------+
|  6 | person_1 | beijing | man | test-1 |
|  7 | person_2 | beijing | man | test-2 |
+----+----------+---------+-----+--------+
```
e.总结
恢复，就是让mysql将保存在binlog日志中指定段落区间的sql语句逐个重新执行一次而已

## 小结
a、可以通过show binlog events以及mysqlbinlog方式来提取binlog日志。
b、show binlog events 参数有限不适宜批量提取，mysqlbinlog可用于批量提取来建立恢复数据库的SQL。
c、mysqlbinlog可以基于时间点，position等方式实现不完全恢复或时点恢复。
d、mysqlbinlog可以从支持本地或远程方式提取binlog日志。
e、mysqlbinlog可以基于server_id，以及基于数据库级别提取日志，不支持表级别。