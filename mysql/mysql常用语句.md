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
### 4.2 存储引擎:
```mysql
mysql> show engines;
-- mysql当前默认的存储引擎:
mysql>show variables like '%storage_engine%';
msyql>show engines
-- 表用了什么引擎,在显示结果里参数engine后面的就表示该表当前用的存储引擎
mysql> show create table 表名;
```
## 5. binlog 日志

```mysql
-- 基于时间查看 binlog 日志
mysqlbinlog  --no-defaults --start-datetime="2016-10-31 23:08:03" mysql-bin.000214 |more
-- 基于位置查看 binlog 日志
mysqlbinlog --no-defaults --start-position=690271 mysql-bin.000214 |more
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