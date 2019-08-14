### MySQL常用语句

[TOC]
## 1. 数据库操作
```mysql
-- 如果【某数据库】存在就删除【某数据库】 
DROP DATABASE IF EXISTS db;
-- 如果【某数据库】不存在就创建【某数据库】
CREATE DATABASE IF NOT EXISTS db;
CREATE DATABASE IF NOT EXISTS yourdbname DEFAULT CHARSET utf8 COLLATE utf8_general_ci;
create database yourdb DEFAULT CHARACTER SET gbk COLLATE gbk_chinese_ci;
-- 使用【某数据库】
USE db;
-- 查看数据库
show databases;
-- 查看创建语句
show create database mytest;
-- 修改字符集
alter database sampdb character set utf8 collate utf8_general_ci;
-- 关闭mysql
mysqladmin -uroot -p shutdown
```
## 2. 表操作

### 2.1 常用操作

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
### 2.2 修改主键SQL

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
### 2.3 主键字段名称及字段类型
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
### 2.4 dual表
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

### 2.5 MySQL函数

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

## 3. 用户管理

### 3.1创建/删除用户：

```mysql
CREATE USER 'username'@'host' IDENTIFIED BY 'password';
CREATE USER 'username'@'192.168.5.9' IDENTIFIED BY 'password';
CREATE USER 'username'@'localhost' IDENTIFIED BY 'password';
CREATE USER 'username'@'%' IDENTIFIED BY '';
CREATE USER 'username'@'%';
create user 'root'@'%' identified by 'oracle';

drop user 'root'@'192.168.45.52';
```
### 3.2 授权
![](pictures\Image.png)
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
### 3.3 设置用户密码
```mysql
SET PASSWORD FOR 'username'@'host'=PASSWORD('newpassword');

-- 如果是修改当前登录的用户的密码，使用如下命令：
SET PASSWDORD=PASSWORD('newpassword')

rename user  'system'@'192.168.45.52' to 'test'@'192.168.45.52';
set password for 'sys'@'192.168.45.52' = password('oracle');
set password = "oracle";       ###mysql5.7写法
```

### 3.4设置root密码

```mysql
> mysql -u root
mysql> SET PASSWORD = PASSWORD('123456');
```

### 3.5重设其它用户的密码

```mysql
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
### 3.6 免密码登录

```mysql
mysqld_safe  --skip-grant-tables --user=mysql &  
```

### 3.7 mysql密码复杂设置
```mysql
5.7 my.cnf文件中祛除validate-password = off

-- 修改MySQL密码检查策略
mysql> SET GLOBAL validate_password_policy = LOW;
mysql> alter user user() identified by '12345678';
```

## 4. 查看数据库状态\配置

### 4.1 参数

```mysql
# mysqld --help --verbose|grep my.cnf
/etc/my.cnf /etc/mysql/my.cnf /usr/local/mysql/etc/my.cnf ~/.my.cnf
                      my.cnf, $MYSQL_TCP_PORT, /etc/services, built-in default
```

![](pictures/Image%20%5B2%5D.png)

```mysql
## MySQL最大可用连接数
show variables like '%max_connections%';
## 查看MySQL连接超时
mysql> SHOW GLOBAL VARIABLES LIKE '%TIMEOUT';
### 查看MySQL运行多长时间
mysql> show global status like 'UPTIME';
## 查看mysql请求链接进程被主动杀死
mysql> SHOW GLOBAL STATUS LIKE 'COM_KILL';
## 查看MySQL通信信息包最大值
mysql> SHOW GLOBAL VARIABLES LIKE 'MAX_ALLOWED_PACKET';
## 字符集
show variables like 'character_set%';
show variables like 'collation%';
## 告警
show warnings;

//自动提交
mysql> select @@session.autocommit;
+----------------------+
| @@session.autocommit |
+----------------------+
|                    0 |
+----------------------+
1 row in set (0.00 sec)
mysql> select @@global.autocommit;
+---------------------+
| @@global.autocommit |
+---------------------+
|                   0 |
+---------------------+
1 row in set (0.00 sec)
mysql> set global autocommit = 1;
Query OK, 0 rows affected (0.00 sec)
mysql> select @@global.autocommit;
+---------------------+
| @@global.autocommit |
+---------------------+
|                   1 |
+---------------------+
1 row in set (0.00 sec)
mysql> select @@session.autocommit;
+----------------------+
| @@session.autocommit |
+----------------------+
|                    0 |
+----------------------+
1 row in set (0.00 sec)
mysq>set session autocommit = 1;
```
![](MySQL常用语句.assets/Image [4].png)

```mysql
SQL> show variables where variable_name='wait_timeout' or variable_name='interactive_timeout';
+---------------------+-------+
| Variable_name       | Value |
+---------------------+-------+
| interactive_timeout | 1800  |
| wait_timeout        | 1800  |
+---------------------+-------+
2 rows in set (0.00 sec)

SQL> set global wait_timeout=3600;set global interactive_timeout=3600;
Query OK, 0 rows affected (0.00 sec)
Query OK, 0 rows affected (0.00 sec)


SQL> show variables where variable_name='wait_timeout' or variable_name='interactive_timeout';  ###这两个参数需同时修改，否则mysql选择其中大的参数，这两个参数只对新建链接有效
+---------------------+-------+
| Variable_name       | Value |
+---------------------+-------+
| interactive_timeout | 1800  |
| wait_timeout        | 1800  |
+---------------------+-------+
2 rows in set (0.00 sec)

(root@localhost) [(none)]> show variables where variable_name='wait_timeout' or variable_name='interactive_timeout';
+---------------------+-------+
| Variable_name       | Value |
+---------------------+-------+
| interactive_timeout | 3600  |
| wait_timeout        | 3600  |
+---------------------+-------+
2 rows in set (0.00 sec)

SQL> show variables like 'sort_buffer_size';
ERROR 2006 (HY000): MySQL server has gone away
No connection. Trying to reconnect...
Connection id:    4
Current database: mytest
+------------------+----------+
| Variable_name    | Value    |
+------------------+----------+
| sort_buffer_size | 33554432 |
+------------------+----------+
1 row in set (0.01 sec)

SQL> show variables like 'join_buffer_size';    
+------------------+-----------+
| Variable_name    | Value     |
+------------------+-----------+
| join_buffer_size | 134217728 |
+------------------+-----------+
1 row in set (0.00 sec)

SQL> show variables like 'read_buffer_size';    
+------------------+----------+
| Variable_name    | Value    |
+------------------+----------+
| read_buffer_size | 16777216 |
+------------------+----------+
1 row in set (0.00 sec)

SQL> show variables like 'read_rnd_buffer_size';
+----------------------+----------+
| Variable_name        | Value    |
+----------------------+----------+
| read_rnd_buffer_size | 33554432 |
+----------------------+----------+
1 row in set (0.00 sec)
```



![](MySQL常用语句.assets/Image [5].png)

```mysql
SQL> show variables like 'innodb_buffer_pool_size';          
+-------------------------+------------+
| Variable_name           | Value      |
+-------------------------+------------+
| innodb_buffer_pool_size | 6442450944 |
+-------------------------+------------+
1 row in set (0.00 sec)
SQL> select sum(index_length) from information_schema.tables where engine='myisam';
+-------------------+
| sum(index_length) |
+-------------------+
|             44032 |
+-------------------+
1 row in set (0.73 sec)
SQL> show variables like 'key_buffer_size';
+-----------------+---------+
| Variable_name   | Value   |
+-----------------+---------+
| key_buffer_size | 8388608 |
+-----------------+---------+
1 row in set (0.00 sec)
SQL> show variables like 'innodb_log_file_size';
+----------------------+------------+
| Variable_name        | Value      |
+----------------------+------------+
| innodb_log_file_size | 8589934592 |
+----------------------+------------+
1 row in set (0.00 sec)
SQL> show variables like 'innodb_log_files_in_group';
+---------------------------+-------+
| Variable_name             | Value |
+---------------------------+-------+
| innodb_log_files_in_group | 2     |
+---------------------------+-------+
1 row in set (0.00 sec)
SQL> show variables like 'innodb_log_buffer_size';
+------------------------+----------+
| Variable_name          | Value    |
+------------------------+----------+
| innodb_log_buffer_size | 33554432 |
+------------------------+----------+
1 row in set (0.00 sec)
SQL> show variables like 'innodb_flush_log_at_trx_commit';
+--------------------------------+-------+
| Variable_name                  | Value |
+--------------------------------+-------+
| innodb_flush_log_at_trx_commit | 1     |
+--------------------------------+-------+
1 row in set (0.00 sec)
SQL> show variables like 'innodb_flush_method';
+---------------------+----------+
| Variable_name       | Value    |
+---------------------+----------+
| innodb_flush_method | O_DIRECT |
+---------------------+----------+
1 row in set (0.00 sec)
SQL> show variables like 'innodb_file_per_table';
+-----------------------+-------+
| Variable_name         | Value |
+-----------------------+-------+
| innodb_file_per_table | ON    |
+-----------------------+-------+
1 row in set (0.00 sec)
SQL> show variables like 'innodb_doublewrite';
+--------------------+-------+
| Variable_name      | Value |
+--------------------+-------+
| innodb_doublewrite | ON    |
+--------------------+-------+
1 row in set (0.00 sec)
\###myisam
SQL> show variables like 'delay_key_write';   ###OFF ON ALL
+-----------------+-------+
| Variable_name   | Value |
+-----------------+-------+
| delay_key_write | ON    |
+-----------------+-------+
1 row in set (0.00 sec)
SQL> show variables like 'expire_logs_days';
+------------------+-------+
| Variable_name    | Value |
+------------------+-------+
| expire_logs_days | 90    |
+------------------+-------+
1 row in set (0.00 sec)
SQL> show variables like 'max_allowed_packet';    ###需主从一致
+--------------------+----------+
| Variable_name      | Value    |
+--------------------+----------+
| max_allowed_packet | 16777216 |
+--------------------+----------+
1 row in set (0.00 sec)
SQL> show variables like 'skip_name_resolve';
+-------------------+-------+
| Variable_name     | Value |
+-------------------+-------+
| skip_name_resolve | ON    |
+-------------------+-------+
1 row in set (0.00 sec)

SQL> show global variables like 'read_only';   ###从库启用
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| read_only     | OFF   |
+---------------+-------+
1 row in set (0.00 sec)

SQL> show global variables like 'sync_binlog';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| sync_binlog   | 1     |
+---------------+-------+
1 row in set (0.00 sec)

SQL> show global variables like '%_table_size';
+---------------------+----------+
| Variable_name       | Value    |
+---------------------+----------+
| max_heap_table_size | 16777216 |
| tmp_table_size      | 67108864 |
+---------------------+----------+
2 rows in set (0.00 sec)

SQL> show global variables like 'max_connections';
+-----------------+-------+
| Variable_name   | Value |
+-----------------+-------+
| max_connections | 800   |
+-----------------+-------+
1 row in set (0.00 sec)
```

![](MySQL常用语句.assets/Image [6].png)



![](MySQL常用语句.assets/Image [7].png)

![](MySQL常用语句.assets/Image [8].png)

### 4.2 存储引擎:

```mysql
mysql> show engines;
-- mysql当前默认的存储引擎:
mysql>show variables like '%storage_engine%';
msyql>show engines
-- 表用了什么引擎,在显示结果里参数engine后面的就表示该表当前用的存储引擎
mysql> show create table 表名;
```
## 5.MySQL日志

###  binlog 日志

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



### 慢SQL日志

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

## 6. MySQL版本升级

```mysql
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

## 7. 常用系统表

```mysql
select * from mysql.user limit 1\G
select * from mysql.db limit 1\G
select * from mysql.tables_priv limit 1\G
select * from mysql.columns_priv limit 1\G
```

## 8.表修复

```mysql
[root@centos sampdb]# mysqlfrm  --diagnostic   absence.frm
# WARNING: Cannot generate character set or collation names without the --server option.
# CAUTION: The diagnostic mode is a best-effort parse of the .frm file. As such, it may not identify all of the components of the table correctly. This is especially true for damaged files. It will also not read the default values for the columns and the resulting statement may not be syntactically correct.
# Reading .frm file for absence.frm:
# The .frm file is a TABLE.
```

## 9. MySQL解释计划

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
explain select emp_no,first_name,last_name from employees where emp_no in (select emp_no from dept_manager);\G
explain extended select emp_no,first_name,last_name from employees where emp_no in (select emp_no from dept_manager)\G

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
mysql> desc FORMAT = JSON select * from employees where emp_no = 23344\G
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

![](D:\Git\blog\mysql\pictures\Image [3].png)

## 10. 统计信息

```
use sys

select * from  x$schema_index_statistics limit 1 \G

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
(root@localhost) [employees]> explain select /*+ MRR(salaries) */ * from salaries where salary>1000 and salary <40000\G
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
(root@localhost) [employees]> explain select /*+ MRR(salaries) */ * from salaries where salary>1000 and salary <40000\G
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

## 11. sysbench

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
## 12. mysqlslap

![](MySQL常用语句.assets/Image [11].png)

![](MySQL常用语句.assets/Image [12].png)

![](MySQL常用语句.assets/Image [13].png)

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

## 13. 性能优化

**什么影响了性能?**

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

## 14. 事务

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
一个事务所作的修改对其他事务是不可见的，好似是串行执行的
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


(root@localhost) [information_schema]> show variables like 'max_heap%';
+---------------------+----------+
| Variable_name       | Value    |
+---------------------+----------+
| max_heap_table_size | 16777216 |
+---------------------+----------+
1 row in set (0.00 sec)
(root@localhost) [information_schema]> show table status like 'TABLES%'\G
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

![](pictures/Image [14].png)
![](pictures/Image [15].png)
![](pictures/Image [16].png)
![](pictures/Image [17].png)
![](pictures/Image [18].png)
![](pictures/Image [19].png)
![](pictures/Image [20].png)
![](pictures/Image [21].png)
![](pictures/Image [22].png)
![](pictures/Image [23].png)
![](pictures/Image [24].png)
![](pictures/Image [25].png)

```mysql
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

![](pictures/Image [26].png)
![](pictures/Image [27].png)
![](pictures/Image [28].png)
![](pictures/Image [29].png)
![](pictures/Image [30].png)
![](pictures/Image [31].png)
![](pictures/Image [32].png)
![](pictures/Image [33].png)
![](pictures/Image [34].png)
![](pictures/Image [35].png)
![](pictures/Image [36].png)
![](pictures/Image [37].png)
![](pictures/Image [38].png)
![](pictures/Image [39].png)
![](pictures/Image [40].png)
![](pictures/Image [41].png)
![](pictures/Image [42].png)
![](pictures/Image [43].png)
![](pictures/Image [44].png)
![](pictures/Image [45].png)
![](pictures/Image [46].png)
![](pictures/Image [47].png)
![](pictures/Image [48].png)
![](pictures/Image [49].png)
![](pictures/Image [50].png)
![](pictures/Image [51].png)

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
## mysqldump:mysql备份
```mysql
 mysqldump -uroot -poracle -B -A --events -x |gzip>/app/mysqlbak$(date +%F%T).sql.gz
 mysqldump -uroot -poracle -B -A --events -x |gzip>/app/mysqlbak`date +%F%T`.sql.gz
 mysqldump -uroot -poracle -B  --events -x  wordpress|gzip>/app/mysqlbak`date +%F%T`.sql.gz
```



```
mysql> show engine innodb status\G
********* 1. row *********
  Type: InnoDB
  Name:

# Status:

# 2018-04-13 08:32:48 0x7fdfde5fa700 INNODB MONITOR OUTPUT

## Per second averages calculated from the last 4 seconds

## BACKGROUND THREAD

srv_master_thread loops: 5 srv_active, 0 srv_shutdown, 486 srv_idle

## srv_master_thread log flush and writes: 491

## SEMAPHORES

OS WAIT ARRAY INFO: reservation count 135
OS WAIT ARRAY INFO: signal count 133
RW-shared spins 0, rounds 12, OS waits 6
RW-excl spins 0, rounds 60, OS waits 2
RW-sx spins 0, rounds 0, OS waits 0

## Spin rounds per wait: 12.00 RW-shared, 60.00 RW-excl, 0.00 RW-sx

## TRANSACTIONS

Trx id counter 15238
Purge done for trx's n:o < 15237 undo n:o < 0 state: running but idle
History list length 18
LIST OF TRANSACTIONS FOR EACH SESSION:
---TRANSACTION 422074637217392, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 422074637216480, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 422074637215568, not started

## 0 lock struct(s), heap size 1136, 0 row lock(s)

## FILE I/O

I/O thread 0 state: waiting for completed aio requests (insert buffer thread)
I/O thread 1 state: waiting for completed aio requests (log thread)
I/O thread 2 state: waiting for completed aio requests (read thread)
I/O thread 3 state: waiting for completed aio requests (read thread)
I/O thread 4 state: waiting for completed aio requests (read thread)
I/O thread 5 state: waiting for completed aio requests (read thread)
I/O thread 6 state: waiting for completed aio requests (write thread)
I/O thread 7 state: waiting for completed aio requests (write thread)
I/O thread 8 state: waiting for completed aio requests (write thread)
I/O thread 9 state: waiting for completed aio requests (write thread)
Pending normal aio reads: [0, 0, 0, 0] , aio writes: [0, 0, 0, 0] ,
ibuf aio reads:, log i/o's:, sync i/o's:
Pending flushes (fsync) log: 0; buffer pool: 0
459 OS file reads, 219 OS file writes, 86 OS fsyncs

## 0.00 reads/s, 0 avg bytes/read, 0.00 writes/s, 0.00 fsyncs/s

## INSERT BUFFER AND ADAPTIVE HASH INDEX

Ibuf: size 1, free list len 0, seg size 2, 0 merges
merged operations:
insert 0, delete mark 0, delete 0
discarded operations:
insert 0, delete mark 0, delete 0
Hash table size 34673, node heap has 0 buffer(s)
Hash table size 34673, node heap has 0 buffer(s)
Hash table size 34673, node heap has 0 buffer(s)
Hash table size 34673, node heap has 0 buffer(s)
Hash table size 34673, node heap has 0 buffer(s)
Hash table size 34673, node heap has 0 buffer(s)
Hash table size 34673, node heap has 0 buffer(s)
Hash table size 34673, node heap has 0 buffer(s)

## 0.00 hash searches/s, 0.00 non-hash searches/s

## LOG

Log sequence number 5543009
Log flushed up to   5543009
Pages flushed up to 5543009
Last checkpoint at  5543000
0 pending log flushes, 0 pending chkp writes

## 80 log i/o's done, 0.00 log i/o's/second

## BUFFER POOL AND MEMORY

Total large memory allocated 137428992
Dictionary memory allocated 145206
Buffer pool size   8191
Free buffers       7733
Database pages     458
Old database pages 0
Modified db pages  0
Pending reads      0
Pending writes: LRU 0, flush list 0, single page 0
Pages made young 0, not young 0
0.00 youngs/s, 0.00 non-youngs/s
Pages read 420, created 38, written 129
0.00 reads/s, 0.00 creates/s, 0.00 writes/s
No buffer pool page gets since the last printout
Pages read ahead 0.00/s, evicted without access 0.00/s, Random read ahead 0.00/s
LRU len: 458, unzip_LRU len: 0

## I/O sum[0]:cur[0], unzip sum[0]:cur[0]

## ROW OPERATIONS

0 queries inside InnoDB, 0 queries in queue
0 read views open inside InnoDB
Process ID=1591, Main thread ID=140599331071744, state: sleeping
Number of rows inserted 45, updated 112, deleted 0, read 186

## 0.00 inserts/s, 0.00 updates/s, 0.00 deletes/s, 0.00 reads/s

# END OF INNODB MONITOR OUTPUT

1 row in set (0.00 sec)
mysql> INSTALL PLUGIN rpl_semi_sync_slave SONAME 'semisync_slave.so';
Query OK, 0 rows affected (0.41 sec)
mysql> INSTALL PLUGIN rpl_semi_sync_master SONAME 'semisync_master.so';
mysql> show plugins;
+----------------------------+----------+--------------------+----------------------+---------+
| Name                       | Status   | Type               | Library              | License |
+----------------------------+----------+--------------------+----------------------+---------+
| binlog                     | ACTIVE   | STORAGE ENGINE     | NULL                 | GPL     |
| mysql_native_password      | ACTIVE   | AUTHENTICATION     | NULL                 | GPL     |
| sha256_password            | ACTIVE   | AUTHENTICATION     | NULL                 | GPL     |
| CSV                        | ACTIVE   | STORAGE ENGINE     | NULL                 | GPL     |
| MyISAM                     | ACTIVE   | STORAGE ENGINE     | NULL                 | GPL     |
| MRG_MYISAM                 | ACTIVE   | STORAGE ENGINE     | NULL                 | GPL     |
| PERFORMANCE_SCHEMA         | ACTIVE   | STORAGE ENGINE     | NULL                 | GPL     |
| MEMORY                     | ACTIVE   | STORAGE ENGINE     | NULL                 | GPL     |
| InnoDB                     | ACTIVE   | STORAGE ENGINE     | NULL                 | GPL     |
| INNODB_TRX                 | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_LOCKS               | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_LOCK_WAITS          | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_CMP                 | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_CMP_RESET           | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_CMPMEM              | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_CMPMEM_RESET        | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_CMP_PER_INDEX       | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_CMP_PER_INDEX_RESET | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_BUFFER_PAGE         | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_BUFFER_PAGE_LRU     | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_BUFFER_POOL_STATS   | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_TEMP_TABLE_INFO     | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_METRICS             | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_FT_DEFAULT_STOPWORD | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_FT_DELETED          | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_FT_BEING_DELETED    | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_FT_CONFIG           | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_FT_INDEX_CACHE      | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_FT_INDEX_TABLE      | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_SYS_TABLES          | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_SYS_TABLESTATS      | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_SYS_INDEXES         | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_SYS_COLUMNS         | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_SYS_FIELDS          | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_SYS_FOREIGN         | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_SYS_FOREIGN_COLS    | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_SYS_TABLESPACES     | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_SYS_DATAFILES       | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| INNODB_SYS_VIRTUAL         | ACTIVE   | INFORMATION SCHEMA | NULL                 | GPL     |
| partition                  | ACTIVE   | STORAGE ENGINE     | NULL                 | GPL     |
| ARCHIVE                    | ACTIVE   | STORAGE ENGINE     | NULL                 | GPL     |
| FEDERATED                  | DISABLED | STORAGE ENGINE     | NULL                 | GPL     |
| BLACKHOLE                  | ACTIVE   | STORAGE ENGINE     | NULL                 | GPL     |
| ngram                      | ACTIVE   | FTPARSER           | NULL                 | GPL     |
| validate_password          | DISABLED | VALIDATE PASSWORD  | validate_password.so | GPL     |
| rpl_semi_sync_master       | ACTIVE   | REPLICATION        | semisync_master.so   | GPL     |
+----------------------------+----------+--------------------+----------------------+---------+
46 rows in set (0.00 sec)
root@mysql 13:46:  [(none)]> show variables like 'slave_rows_search_algorithms';
+------------------------------+-----------------------+
| Variable_name                | Value                 |
+------------------------------+-----------------------+
| slave_rows_search_algorithms | TABLE_SCAN,INDEX_SCAN |
+------------------------------+-----------------------+
1 row in set (0.00 sec)
root@mysql 13:50:  [(none)]> show global status like '%rpl%';
+--------------------------------------------+-------+
| Variable_name                              | Value |
+--------------------------------------------+-------+
| Rpl_semi_sync_master_clients               | 0     |
| Rpl_semi_sync_master_net_avg_wait_time     | 0     |
| Rpl_semi_sync_master_net_wait_time         | 0     |
| Rpl_semi_sync_master_net_waits             | 0     |
| Rpl_semi_sync_master_no_times              | 0     |
| Rpl_semi_sync_master_no_tx                 | 0     |
| Rpl_semi_sync_master_status                | ON    |
| Rpl_semi_sync_master_timefunc_failures     | 0     |
| Rpl_semi_sync_master_tx_avg_wait_time      | 0     |
| Rpl_semi_sync_master_tx_wait_time          | 0     |
| Rpl_semi_sync_master_tx_waits              | 0     |
| Rpl_semi_sync_master_wait_pos_backtraverse | 0     |
| Rpl_semi_sync_master_wait_sessions         | 0     |
| Rpl_semi_sync_master_yes_tx                | 0     |
| Rpl_semi_sync_slave_status                 | OFF   |
+--------------------------------------------+-------+
15 rows in set (0.00 sec)
mysql> stop slave io_thread;
Query OK, 0 rows affected, 1 warning (0.00 sec)
mysql> stop slave sql_thread;  
Query OK, 0 rows affected, 1 warning (0.00 sec)
```
## 针对某个DB复制
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

## 需备份二进制日志
```
mysql> show master status;
+------------------+----------+--------------+------------------+----------------------------------------------+

| File | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
| ---- | -------- | ------------ | ---------------- | ----------------- |
|      |          |              |                  |                   |
+------------------+----------+--------------+------------------+----------------------------------------------+
| mysql-bin.000020 | 8533959 |      |      | 7d0e42b6-0c89-11e8-90d8-000c292c7e58:1-23949 |
| ---------------- | ------- | ---- | ---- | -------------------------------------------- |
|                  |         |      |      |                                              |
+------------------+----------+--------------+------------------+----------------------------------------------+
1 row in set (0.00 sec)
mysql> reset master;
Query OK, 0 rows affected (0.03 sec)
mysql> show master status;
+------------------+----------+--------------+------------------+------------------------------------------+
| File | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
| ---- | -------- | ------------ | ---------------- | ----------------- |
|      |          |              |                  |                   |
+------------------+----------+--------------+------------------+------------------------------------------+
| mysql-bin.000001 | 1694 |      |      | 7d0e42b6-0c89-11e8-90d8-000c292c7e58:1-4 |
| ---------------- | ---- | ---- | ---- | ---------------------------------------- |
|                  |      |      |      |                                          |
+------------------+----------+--------------+------------------+------------------------------------------+
1 row in set (0.00 sec)
start slave for channel ch1
```
## 计算列
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
## 密码有效期
```
root@mysql 15:17:  [mytest]>  show variables like 'default_password_lifetime';
+---------------------------+-------+
| Variable_name             | Value |
+---------------------------+-------+
| default_password_lifetime | 0     |
+---------------------------+-------+
1 row in set (0.00 sec)
```
## numa
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
## innodb buffer pool hit rate
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
## 验证唯一性
Oracle null可以多个
mysql  null只能一个
## mysql 5.7.22新特性
oracle mysql 5.7.22，去掉--flush-logs，只使用mysqldump -uroot -proot --default-character-set=utf8  --single-transaction --master-data=2 备份，也是会发出FLUSH TABLES WITH READ LOCK 
## 今日讨论，你都用了什么方法防止误删数据？
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