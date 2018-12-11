## mysqldump增量备份与恢复实例

小量的数据库可以每天进行完整备份，因为这也用不了多少时间，但当数据库很大时，就不太可能每天进行一次完整备份了，这时候就可以使用增量备份。增量备份的原理就是使用了mysql的binlog日志。

本次操作的MySQL版本为`5.7.21 for Linux (x86_64)`。
```
#mysql --version                                                              
mysql  Ver 14.14 Distrib 5.7.21, for linux-glibc2.12 (x86_64) using  EditLine wrapper 
```
增量备份要确保打开了二进制日志，参考[mysql的日志系统](http://seanlook.com/2014/12/04/mysql_log_binlog/)：

```
root@mysql 13:26:  [(none)]> show variables like '%log_bin%';
+---------------------------------+-----------------+
| Variable_name                   | Value           |
+---------------------------------+-----------------+
| log_bin                         | ON              |
| log_bin_basename                | /data/bin       |
| log_bin_index                   | /data/bin.index |
| log_bin_trust_function_creators | OFF             |
| log_bin_use_v1_row_events       | OFF             |
| sql_log_bin                     | ON              |
+---------------------------------+-----------------+
6 rows in set (0.00 sec)
root@mysql 13:26:  [(none)]> show variables like '%binlog%';
+-----------------------------------------+----------------------+
| Variable_name                           | Value                |
+-----------------------------------------+----------------------+
| binlog_cache_size                       | 32768                |
| binlog_checksum                         | CRC32                |
| binlog_direct_non_transactional_updates | OFF                  |
| binlog_error_action                     | ABORT_SERVER         |
| binlog_format                           | ROW                  |
| binlog_group_commit_sync_delay          | 0                    |
| binlog_group_commit_sync_no_delay_count | 0                    |
| binlog_gtid_simple_recovery             | ON                   |
| binlog_max_flush_queue_time             | 0                    |
| binlog_order_commits                    | ON                   |
| binlog_row_image                        | FULL                 |
| binlog_rows_query_log_events            | OFF                  |
| binlog_stmt_cache_size                  | 32768                |
| innodb_api_enable_binlog                | OFF                  |
| innodb_locks_unsafe_for_binlog          | OFF                  |
| log_statements_unsafe_for_binlog        | ON                   |
| max_binlog_cache_size                   | 18446744073709547520 |
| max_binlog_size                         | 1073741824           |
| max_binlog_stmt_cache_size              | 18446744073709547520 |
| sync_binlog                             | 1                    |
+-----------------------------------------+----------------------+
20 rows in set (0.01 sec)
root@mysql 13:26:  [(none)]> show binary logs;
+------------+-----------+
| Log_name   | File_size |
+------------+-----------+
| bin.000001 |       195 |
| bin.000002 |       154 |
+------------+-----------+
2 rows in set (0.00 sec)
root@mysql 13:26:  [(none)]> show master logs;
+------------+-----------+
| Log_name   | File_size |
+------------+-----------+
| bin.000001 |       195 |
| bin.000002 |       154 |
+------------+-----------+
2 rows in set (0.00 sec)
```
首先对smpdb数据库做一个完整备份：
```
mysqldump -h localhost -uroot -poracle --master-data=2 --single-transaction --add-drop-table --flush-logs --create-options --quick --extended-insert --default-character-set=utf8 --databases --set-gtid-purged=OFF sampdb > sampdb_full.sql                                                                        
mysqldump: [Warning] Using a password on the command line interface can be insecure.
```
这时候就会得到一个全备文件sampdb_full.sql l。mysqldump操作会导致滚动一次log，假设新的binlog文件是mysql-bin.000002。
### 1. 模拟插入数据和误操作
1. 在sampdb库的某个表插入一些数据，然后执行`flush logs`命令。这时将会产生一个新的二进制日志文件mysql-bin.000003，mysql-bin.000002则保存了全备过后的所有更改，既增加记录的操作也保存在了mysql-bin.00002中。
2. 再在sampdb库中的absencer表中增加两条记录，然后误删除absence表。absencer中增加记录的操作和删除表的操作都记录在mysql-bin.000003中。
### 2. 开始恢复
恢复过程不要记录日志：
```
mysql > set sql_log_bin=0;
或
mysql > set global sql_log_bin=0;
```
[^注]: MySQL5.7只支持session级别，MySQL5.5,5.6支持global

### 3. 首先导入全备数据
```
# mysql -uroot -p < sampdb_full_2.sql                                     
或
mysql> source /path/backup/pak_bak_full.sql
```
我们也可以看到全备时的binlog位置：
```
head -50 sampdb_full_2.sql |grep 'CHANGE MASTER'                        
-- CHANGE MASTER TO MASTER_LOG_FILE='bin.000005', MASTER_LOG_POS=194; 
```
查看当前所在二进制日志中的位置：
```
mysql> show master status;
```
根据上面两个position能大概确定需要完整恢复哪几个binlog文件。
### 4. 恢复mysql-bin.000002
在待恢复的position或时间点以前、全备以后的binlog需要全部恢复，多个文件以空格隔开
```
mysqlbinlog /var/lib/mysql/mysql-bin.000002 | mysql -uroot -p
或
root@mysql 10:29:  [(none)]>  show global variables like 'gtid_mode';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| gtid_mode     | ON    |
+---------------+-------+
1 row in set (0.00sec)
mysqlbinlog --skip-gtids /data/bin.000011 |mysql -uroot -p  
```
此时查询可以得到前两条数据。
### 5. 恢复部分mysql-bin.000003
这个日志中包括了新增记录和误删表两个部分，我们需要恢复到新增记录之后、误删操作以前的位置。
如果知道误操作的命令如`DROP TABLE`，则可以通过下面的方法在binlog文件中找到误操作之前的那个position：
（如下面的信息显示，误操作`DROP TABLE`之前的pos是775，在datetime 141204 15:08:04或pos 882时完成`DROP TABLE`操作）

```
$ mysqlbinlog /var/lib/mysql/mysql-bin.000003 |grep -C 5 'DROP TABLE'
#141204 15:07:05 server id 1  end_log_pos 775	Xid = 376
COMMIT/*!*/;
# at 775
#141204 15:08:04 server id 1  end_log_pos 882 	Query	thread_id=10	exec_time=0	error_code=0
SET TIMESTAMP=1417676884/*!*/;
DROP TABLE `t_user` /* generated by server */
/*!*/;
# at 882
```
恢复命令：
```
$ mysqlbinlog /var/lib/mysql/mysql-bin.000003 --stop-position=775 | mysql -h localhost -uroot -p
或
mysqlbinlog --skip-gtids --stop-position=714 /data/bin.000012 |mysql -uroot -p  
```
如果position难以确定，但知道需要恢复到的确切（服务器）时间，也可以使用datetime：
```
$ mysqlbinlog /var/lib/mysql/mysql-bin.000003 --stop-datetime="2014-12-04 15:08:00" | mysql -uroot -p
```
如果不是误操作导致的，而是迁移数据库，那么不需要position或datetime，使用所有binlog文件增量恢复即可。
确定恢复成功后记得打开日志记录：

```
mysql > set global sql_log_bin=1;
```
### 报错
1. unknown variable ‘default-character-set=utf8’
   在使用`mysqlbinlog`查看二进制日志的时候，提示下面的错误：
   /usr/local/mysql/bin/mysqlbinlog: unknown variable ‘default-character-set=utf8’
   原因是在我为了统一mysql客户端到服务端的的字符编码，在`/etc/my.cnf`文件的`[client]`、`[mysqld]`等节加入了`default-character-set = utf8`，`mysqlbinlog`会从`my.cnf`中的`[client]`读取配置，但奈何mysqlbinlog并不认识这个选项（据说是个bug）导致的。
   应对这个bug的方法有两个：
   第一，自然是注释到`[client]`中的这个字符集配置；
   第二，改用`loose-default-character-set = utf8`。在选项前加了`loose-`，表示当程序不认识此选项时会略过此选项，并给出一个警告。
2. 报错
mysqlbinlog --no-defaults mysql-bin.000018 --start-position="4" --stop-position="1102" |mysql test
ERROR 1781 (HY000) at line 17: @@SESSION.GTID_NEXT cannot be set to UUID:NUMBER when @@GLOBAL.GTID_MODE = OFF.
```
mysql> show global variables like 'gtid_mode'; 
+---------------+-------+ 
| Variable_name | Value | 
+---------------+-------+ 
| gtid_mode     | OFF   | 
+---------------+-------+ 
1 row in set (0.00 sec) 
```
最终，通过以下命令解决问题；
```
set @@GLOBAL.GTID_MODE = OFF_PERMISSIVE; 
```
导入日志记录
```
mysqlbinlog --no-defaults --start-position="441" mysql-bin.00000*| mysql
```
就不会再报那个错了；