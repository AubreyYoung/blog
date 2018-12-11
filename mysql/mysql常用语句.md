### Mysql增加、删除和修改列属性和约束，和一些有用的查询语句

[TOC]

最近在整理关于MySql的东西，把一些需要记录的东西写下来，以便以后查询和浏览，以下是一些操作技巧。

## 如果【某数据库】存在就删除【某数据库】 
DROP DATABASE IF EXISTS db;
## 如果【某数据库】不存在就创建【某数据库】
CREATE DATABASE IF NOT EXISTS db;
## 使用【某数据库】
USE db;
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
#desc 表名;
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
## 修改主键的sql语句块如下:
```
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
## 如何取主键字段名称及字段类型--得到主键字段名
1:
```
SELECT TABLE_NAME,COLUMN_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME<>'dtproperties'
```
2:
EXEC sp_pkeys @table_name='表名'
3:
```
select o.name as 表名,c.name as 字段名,k.colid as 字段序号,k.keyno as 索引顺序,t.name as 类型
from sysindexes i
join sysindexkeys k on i.id = k.id and i.indid = k.indid
join sysobjects o on i.id = o.id
join syscolumns c on i.id=c.id and k.colid = c.colid
join systypes t on c.xusertype=t.xusertype
where o.xtype = 'U' and o.name='要查询的表名'
and exists(select 1 from sysobjects where xtype = 'PK' and parent_obj=i.id and name = i.name)
order by o.name,k.colid
```
以上就是关于如何修改MySql数据表的字段类型，默认值和增加新的字段。

## 创建用户：
```
CREATE USER 'username'@'host' IDENTIFIED BY 'password';
CREATE USER 'username'@'192.168.5.9' IDENTIFIED BY 'password';
CREATE USER 'username'@'localhost' IDENTIFIED BY 'password';
CREATE USER 'username'@'%' IDENTIFIED BY '';
CREATE USER 'username'@'%';
```
## 授权
```
GRANT privileges ON databasename.tablename TO 'username'@'host';
GRANT SELECT,INSERT ON DBname.tablename TO 'username'@'%';
GRANT ALL ON DBname.tablename TO 'username'@'%';
GRANT ALL ON DBname.* TO 'username'@'%';
GRANT ALL ON *.* TO 'username'@'%';
```
注意：使用以上命令授权的用户不能用来再给其他用户授权
如果想让该用户可以为其他用户授权，可以使用如下命令：
```
GRANT privileges ON databasename.tablename TO 'username'@'host' WITH GRANT OPTION;
```
## 设置/更改用户密码
```
SET PASSWORD FOR 'username'@'host'=PASSWORD('newpassword');
```
如果是修改当前登录的用户的密码，使用如下命令：
```
SET PASSWDORD=PASSWORD('newpassword')
```

## 管理给自己设置密码

```
> mysql -u root
mysql> SET PASSWORD = PASSWORD('123456');
```

## 管理员或者有全局权限的用户重设其它用户的密码

### 方法一

```
> mysql -u root -p
mysql> use mysql;
mysql> UPDATE user SET password=PASSWORD("new password") WHERE user='username';
mysql> FLUSH PRIVILEGES;
mysql> exit
```

### 方法二

```
> mysql -u root -p
mysql> use mysql; 
mysql> SET PASSWORD FOR username=PASSWORD('new password');
mysql> exit
```

### 方法三

```
mysqladmin -u root "old password" "new password"
```

## MySQL连接数

```
(root@localhost) [(none)]> show variables like '%max_connections%';
+-----------------+-------+
| Variable_name   | Value |
+-----------------+-------+
| max_connections | 800   |
+-----------------+-------+
1 row in set (0.00 sec)
```
## 看你的mysql现在已提供什么存储引擎:
```
mysql> show engines;
```
## MySQL数据库查看、创建、删除
```
show databases;
drop database name;
create database name;
use name;
root@mysql 14:01:  [(none)]> show create database mytest;
+----------+--------------------------------------------------------------------+
| Database | Create Database                                                    |
+----------+--------------------------------------------------------------------+
| mytest   | CREATE DATABASE `mytest` /*!40100 DEFAULT CHARACTER SET utf8mb4 */ |
+----------+--------------------------------------------------------------------+
1 row in set (0.37 sec)
```
## MySQL查看表结构
```
describe mysql.user;
desc mysql.user;
```

## mysql当前默认的存储引擎:
```
mysql> show variables like '%storage_engine%';
msyql>show engines
```
## 表用了什么引擎

在显示结果里参数engine后面的就表示该表当前用的存储引擎

```
mysql> show create table 表名;
```

## 基于时间查看 binlog 日志

```
mysqlbinlog  --no-defaults --start-datetime="2016-10-31 23:08:03" mysql-bin.000214 |more
```

## 基于位置查看 binlog 日志

```
mysqlbinlog --no-defaults --start-position=690271 mysql-bin.000214 |more
```