# MySQL5.7的新特性

## 1. MySQL服务功能增强

### 1.1 数据库初始化的方式变更

- 在MySQL5.7版本之前，使用编译安装或使用二进制包部署MySQL，初始化的时候是使用了如下脚本来实现的

```
mysql_install_db --datadir=/home/mysql/data --user=mysql --basedir=/home/mysql
```

- 到了MySQL5.7，不再提供脚本的方式初始化数据库，而是改用mysqld程序的命令来实现

```
mysqld --initialize --user=mysql --basedir=/home/mysql --datadir=/home/mysql/data
```

[^注]: 当然如果你使用了yum的方式安装了MySQL5.7，那么在第一次启动mysql的时候`systemctl start mysqld`默认会自动根据配置文件去初始化你的数据库

MySQL启动

```
mysql_safe --default-file = /etc/my.cnf $
```

### 1.2 支持为表增加计算列

什么是计算列？

当一张表上的某一列的数据是由其他列的值计算得到的列，就称之为计算列

例如：一张表t，有c1，c2和c3列，c3的值=c1+c2

在MySQL5.7之前，计算列只能通过触发器的方式来实现

```
mysql> create table t(id int auto_increment not null, c1 int,c2 int,c3 int,primary key (id));
Query OK, 0 rows affected (0.09 sec)
```

这张表建立之后，向t表中的c1和c2插入数据，c3是不可能自动计算出来的

- 方法一:只能通过插入触发器来实现

```
mysql> create trigger inst_t before insert on t for each row set new.c3=new.c1+new.c2; 
Query OK, 0 rows affected (0.07 sec)

mysql> show triggers;
+---------+--------+-------+--------------------------+--------+------------------------+-------------------------------------------------------------------------------------------------------------------------------------------+----------------+----------------------+----------------------+--------------------+
| Trigger | Event  | Table | Statement                | Timing | Created                | sql_mode                                                                                                                                  | Definer        | character_set_client | collation_connection | Database Collation |
+---------+--------+-------+--------------------------+--------+------------------------+-------------------------------------------------------------------------------------------------------------------------------------------+----------------+----------------------+----------------------+--------------------+
| inst_t  | INSERT | t     | set new.c3=new.c1+new.c2 | BEFORE | 2016-08-21 01:52:06.01 | ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION | root@localhost | utf8                 | utf8_general_ci      | utf8mb4_unicode_ci |
+---------+--------+-------+--------------------------+--------+------------------------+-------------------------------------------------------------------------------------------------------------------------------------------+----------------+----------------------+----------------------+--------------------+
1 row in set (0.00 sec)

mysql> insert into t(c1, c2) values(1, 2);
Query OK, 1 row affected (0.11 sec)

mysql> select * from t;
+----+------+------+------+
| id | c1   | c2   | c3   |
+----+------+------+------+
|  1 |    1 |    2 |    3 |
+----+------+------+------+
1 row in set (0.00 sec)

mysql>
```

上面实现了插入触发器，测试正常，但是一旦我去更改c1或c2的值，c3列是不会跟着变更的

因此还需要建立一个更新触发器

```
mysql> create trigger upd_t before update on t for each row set new.c3=new.c1+new.c2;
Query OK, 0 rows affected (0.08 sec)

mysql> show triggers;
+---------+--------+-------+--------------------------+--------+------------------------+-------------------------------------------------------------------------------------------------------------------------------------------+----------------+----------------------+----------------------+--------------------+
| Trigger | Event  | Table | Statement                | Timing | Created                | sql_mode                                                                                                                                  | Definer        | character_set_client | collation_connection | Database Collation |
+---------+--------+-------+--------------------------+--------+------------------------+-------------------------------------------------------------------------------------------------------------------------------------------+----------------+----------------------+----------------------+--------------------+
| inst_t  | INSERT | t     | set new.c3=new.c1+new.c2 | BEFORE | 2016-08-21 01:52:06.01 | ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION | root@localhost | utf8                 | utf8_general_ci      | utf8mb4_unicode_ci |
| upd_t   | UPDATE | t     | set new.c3=new.c1+new.c2 | BEFORE | 2016-08-21 02:01:50.46 | ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION | root@localhost | utf8                 | utf8_general_ci      | utf8mb4_unicode_ci |
+---------+--------+-------+--------------------------+--------+------------------------+-------------------------------------------------------------------------------------------------------------------------------------------+----------------+----------------------+----------------------+--------------------+
2 rows in set (0.00 sec)

mysql> update t set c1=5 where id=1;
Query OK, 1 row affected (0.04 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> select * from t;
+----+------+------+------+
| id | c1   | c2   | c3   |
+----+------+------+------+
|  1 |    5 |    2 |    7 |
+----+------+------+------+
1 row in set (0.00 sec)

mysql>
```

从上面的Demo可以看出，在MySQL5.7之前，如果想实现计算列，至少要创建插入和更新两个触发器.

- 方法二: 使用视图也是可以实现计算列的目的

```
mysql> create view vw_t as select id,c1,c2,c1+c2 as c3 from t;
Query OK, 0 rows affected (0.11 sec)

mysql> select * from vw_t;
+----+------+------+------+
| id | c1   | c2   | c3   |
+----+------+------+------+
|  1 |    5 |    2 |    7 |
+----+------+------+------+
1 row in set (0.00 sec)

mysql>
```

而无论是使用触发器还是视图，对mysql的性能都会产生或多或少的影响，所以一般情况下，在生产环境中，建议是尽可能少的使用触发器和视图

- 在MySQL5.7原生支持计算列语法

在`create table`以及`alter table`语句中支持增加计算列

```
col_name data_type [GENERATED ALWAYS] AS (expression) [VIRTUAL|STORED] [UNIQUE [KEY]] [COMMENT comment] [[NOT] NULL] [[PRIMARY] KEY]
```

```
mysql> drop table t;
Query OK, 0 rows affected (0.25 sec)

mysql> create table t (id int auto_increment not null, c1 int, c2 int, c3 int as (c1+c2), primary key(id));
Query OK, 0 rows affected (0.22 sec)

mysql> show create table t;
+-------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Table | Create Table                                                                                                                                                                                                                                                             |
+-------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| t     | CREATE TABLE `t` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `c1` int(11) DEFAULT NULL,
  `c2` int(11) DEFAULT NULL,
  `c3` int(11) GENERATED ALWAYS AS ((`c1` + `c2`)) VIRTUAL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci |
+-------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.01 sec)

mysql> insert into t(c1, c2) values(1, 2);
Query OK, 1 row affected (0.05 sec)

mysql> select * from t;
+----+------+------+------+
| id | c1   | c2   | c3   |
+----+------+------+------+
|  1 |    1 |    2 |    3 |
+----+------+------+------+
1 row in set (0.00 sec)

mysql> update t set c1=9 where id=1;
Query OK, 1 row affected (0.05 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> select * from t;
+----+------+------+------+
| id | c1   | c2   | c3   |
+----+------+------+------+
|  1 |    9 |    2 |   11 |
+----+------+------+------+
1 row in set (0.00 sec)

mysql>
```

MySQL5.7原生支持的计算列有两种模式，一种是虚拟列，一种是存在磁盘中的列。虚拟列不占用磁盘空间

### 1.3 引入了JSON列类型及相关的函数

- MySQL5.7之前，只能在varchar或是text等字符类型的列中存储json类型的字符串，并通过程序解析来使用json字符串
- MySQL5.7之后，增加了json列类型以及`json_`开头的相关处理函数，如`json_type()``json_object()``json_merge()` 等

```
# 生成一个json的数组
mysql> select json_array('a','b',now());
+------------------------------------------+
| json_array('a','b',now())                |
+------------------------------------------+
| ["a", "b", "2016-08-21 02:41:45.000000"] |
+------------------------------------------+
1 row in set (0.00 sec)

# 生成一个json KV对象
mysql> select json_object('k1',1,'k2',2);
+----------------------------+
| json_object('k1',1,'k2',2) |
+----------------------------+
| {"k1": 1, "k2": 2}         |
+----------------------------+
1 row in set (0.00 sec)
```

创建一个含有json类型字段的表

```
mysql> create table t1(jdoc json);
Query OK, 0 rows affected (0.32 sec)

mysql> show create table t1;
+-------+-------------------------------------------------------------------------------------------------------------------+
| Table | Create Table                                                                                                      |
+-------+-------------------------------------------------------------------------------------------------------------------+
| t1    | CREATE TABLE `t1` (
  `jdoc` json DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci |
+-------+-------------------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)

mysql> insert into t1(jdoc) values(json_array('a','b',now()));
Query OK, 1 row affected (0.05 sec)

mysql> insert into t1(jdoc) values(json_object('k1',1,'k2',2));
Query OK, 1 row affected (0.06 sec)

mysql> select * from t1;
+------------------------------------------+
| jdoc                                     |
+------------------------------------------+
| ["a", "b", "2016-08-21 02:47:50.000000"] |
| {"k1": 1, "k2": 2}                       |
+------------------------------------------+
2 rows in set (0.00 sec)
```

## 2. Replication方面的增强

### 2.1 支持多源复制

![复制增强](.\pictures\MySQL5.7新特性_复制增强01.png)
![复制增强](.\pictures\MySQL5.7新特性_多源复制.png)

### 2.2 基于库或是逻辑锁的多线程复制

- MySQL5.7之前

  从MySQL5.6开始支持多线程复制,只不过是一个库一个复制线程

- MySQL5.7之后

  MySQL5.7后对多线程复制功能进行了增强,增加了slave_parallel_type参数可以控制并发同步是基于database还是logical_lock

### 2.3 在线变更复制方式

- MySQL5.7之前

  要把基于日志点的复制方式变为基于GTID的复制方式或基于GTID的复制方式变为基于日志点的复制方式必须要重启master服务器

- MySQL5.7之后

  允许在线变更日志复制的方式,而不需要重启master服务器

  ![在线变更复制方式](D:\Git\blog\mysql\pictures\MySQL5.7新特性_在线变更日志复制方式.png)

## 3. InnoDB存储引擎的增强

### 3.1 支持缓冲池大小在线变更

- MySQL5.7之前

  要变更innodb_buffer_pool的大小必须更改my.cnf文件后重启数据库服务器.

- MySQL5.7之后

  innodb_buffer_pool_size参数变为动态参数,可以在线调整innodb缓冲池的大小.

### 3.2 增加innodb_buffer_pool导入导出功能

```
root@mysql 10:40:  [Aubrey]> show variables like 'innodb_buffer_pool_dump%';
+-------------------------------------+-------+
| Variable_name                       | Value |
+-------------------------------------+-------+
| innodb_buffer_pool_dump_at_shutdown | ON    |
| innodb_buffer_pool_dump_now         | OFF   |
| innodb_buffer_pool_dump_pct         | 40    |
+-------------------------------------+-------+
3 rows in set (0.00 sec)

root@mysql 10:41:  [Aubrey]> show variables like 'innodb_buffer_pool_load%';
+------------------------------------+-------+
| Variable_name                      | Value |
+------------------------------------+-------+
| innodb_buffer_pool_load_abort      | OFF   |
| innodb_buffer_pool_load_at_startup | ON    |
| innodb_buffer_pool_load_now        | OFF   |
+------------------------------------+-------+

//手动dump
> set global innodb_buffer_pool_dump_now = on; 
Query OK, 0 rows affected (0.00 sec)
# ll 
-rw-r----- 1 mysql mysql      653 Mar 18 10:45 ib_buffer_pool
```



### 3.3 支持为innodb表建立表空间

## MySQL安全方面的增强

## 初始化数据库后的默认密码

- 在MySQL5.7之前的版本，初始化数据库后，默认的root密码为空，在localhost直接使用mysql客户端，可以以无密码的方式进入到数据库中
- 在MySQL5.7中，在初始化数据库之后，会为root生成一个强度为`大写字母+小写字母+数字+特殊符号`的密码，并且首次进入到mysql时，强制要你更改密码，且强度默认依然为`大写字母+小写字母+数字+特殊符号`

关于MySQL5.7的初始化密码的查找，可以参考本站的文章

- [https://docs.20150509.cn/2016/07/28/MySQL5-7初始密码/](https://docs.20150509.cn/2016/07/28/MySQL5-7%E5%88%9D%E5%A7%8B%E5%AF%86%E7%A0%81/)

## 默认的密码强度

mysql对于密码有3种检验策略，默认validate_password_policy为MEDIUM

- LOW policy tests password length only. Passwords must be at least 8 characters long.
- MEDIUM policy adds the conditions that passwords must contain at least 1 numeric character, 1 lowercase and uppercase character, and 1 special (nonalphanumeric) character.
- STRONG policy adds the condition that password substrings of length 4 or longer must not match words

关于MySQL5.7密码强度的更改，可以参考本站的文章

- [https://docs.20150509.cn/2016/08/19/CentOS7安装MySQL5-7/](https://docs.20150509.cn/2016/08/19/CentOS7%E5%AE%89%E8%A3%85MySQL5-7/)

## 不在支持old_password认证

## 增加账号默认过期时间

## 加强了对账号的管理功能

## 增加了sys管理数据库