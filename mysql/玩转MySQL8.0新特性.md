# 玩转MySQL8.0新特性

## 1. 账户与安全

### 1.1 用户创建与授权

- MySQL8.0中

  MySQL8.0 创建用户和用户授权的命令要分开执行

```
create user 'sample'@'%' identified by 'sample';
grant all privileges on *.* to'sample'@'%';
```

- MySQL8.0之前

```
grant all privileges on *.* to'sample'@'%' identified by 'sample';
```

### 1.2 认证插件更新

- MySQL8.0中

  默认的身份认证插件是caching_sha2_password,替代了之前的mysql_native_password

```
> show variables like 'default_auth%';  
+-------------------------------+-----------------------+
| Variable_name                 | Value                 |
+-------------------------------+-----------------------+
| default_authentication_plugin | caching_sha2_password |
+-------------------------------+-----------------------+
1 row in set (0.39 sec)

> select user,host,plugin from mysql.user;
+------------------+-----------+-----------------------+
| user             | host      | plugin                |
+------------------+-----------+-----------------------+
| mysql.infoschema | localhost | mysql_native_password |
| mysql.session    | localhost | mysql_native_password |
| mysql.sys        | localhost | mysql_native_password |
| root             | localhost | caching_sha2_password |
+------------------+-----------+-----------------------+
4 rows in set (0.00 sec)
```

MySQL配置文件

```
# default-authentication-plugin=mysql_native_password
```

```
alter  user 'sample'@'%' identified with mysql_native_password by'sample';
```

### 1.3 密码管理增强

MySQL8.0 开始允许限制重复使用以前的密码

```
show variables like 'password_%';
+--------------------------+-------+
| Variable_name            | Value |
+--------------------------+-------+
| password_history         | 0     |
| password_require_current | OFF   |
| password_reuse_interval  | 0     |
+--------------------------+-------+
3 rows in set (0.01 sec)

password_reuse_interval				//按时间重用限制
password_require_current			//修改密码需要当前密码

//方法一:
> set persist password_require_current=on;
Query OK, 0 rows affected (0.00 sec)

more mysqld-auto.cnf
{ "Version" : 1 , "mysql_server" : { "password_require_current" : { "Value" : "ON" , "Metadata" : { "Timestamp" : 1552884290251613 , "User" : "root" , "Host" : "loca
lhost" } } } }

//方法二:
mysql> set  persist password_history = 3;
Query OK, 0 rows affected (0.00 sec)

mysql> show variables like 'password%';
+--------------------------+-------+
| Variable_name            | Value |
+--------------------------+-------+
| password_history         | 3     |
| password_require_current | ON    |
| password_reuse_interval  | 0     |
+--------------------------+-------+
3 rows in set (0.00 sec)

>alter  user 'sample'@'%' password history 5;

> alter user 'aubrey'@'192.168.45.%' identified by 'Password@123';
ERROR 3638 (HY000): Cannot use these credentials for 'aubrey@192.168.45.%' because they contradict the password history policy

>  desc mysql.password_history;
+--------------------+--------------+------+-----+----------------------+-------------------+
| Field              | Type         | Null | Key | Default              | Extra             |
+--------------------+--------------+------+-----+----------------------+-------------------+
| Host               | char(60)     | NO   | PRI |                      |                   |
| User               | char(32)     | NO   | PRI |                      |                   |
| Password_timestamp | timestamp(6) | NO   | PRI | CURRENT_TIMESTAMP(6) | DEFAULT_GENERATED |
| Password           | text         | YES  |     | NULL                 |                   |
+--------------------+--------------+------+-----+----------------------+-------------------+
4 rows in set (0.00 sec)

> select * from mysql.password_history;
+--------------+--------+----------------------------+------------------------------------------------------------------------+
| Host         | User   | Password_timestamp         | Password                                                               |
+--------------+--------+----------------------------+------------------------------------------------------------------------+
| 192.168.45.% | aubrey | 2019-03-22 09:45:07.323039 | $A$005$+`.i60[{VsG}_AeCQCayxfEEe0XOxRag8yWFfd0SuLjmv3K0P2C6zU6dX4 |
+--------------+--------+----------------------------+------------------------------------------------------------------------+
1 row in set (0.01 sec)

//修改当前用户密码
> alter user user() identified by 'oracle@345'; 
Query OK, 0 rows affected (0.00 sec)

//查看链接状态
> \s
--------------
mysql  Ver 8.0.15 for Linux on x86_64 (MySQL Community Server - GPL)

Connection id:          19
Current database:
Current user:           aubrey@localhost
SSL:                    Not in use
Current pager:          stdout
Using outfile:          ''
Using delimiter:        ;
Server version:         8.0.15 MySQL Community Server - GPL
Protocol version:       10
Connection:             Localhost via UNIX socket
Server characterset:    utf8mb4
Db     characterset:    utf8mb4
Client characterset:    utf8mb4
Conn.  characterset:    utf8mb4
UNIX socket:            /var/lib/mysql/mysql.sock
Uptime:                 31 min 12 sec

Threads: 2  Questions: 50  Slow queries: 0  Opens: 152  Flush tables: 2  Open tables: 128  Queries per second avg: 0.026
--------------

//password_require_current参数,dba用户不需要replace
> show variables like 'password%';
+--------------------------+-------+
| Variable_name            | Value |
+--------------------------+-------+
| password_history         | 3     |
| password_require_current | ON    |
| password_reuse_interval  | 0     |
+--------------------------+-------+
> alter user user() identified by 'Aubrey@123';
ERROR 13226 (HY000): Current password needs to be specified in the REPLACE clause in order to change it.
> alter user user() identified by 'Aubrey@123' replace 'Password@123';
Query OK, 0 rows affected (0.01 sec)
```

### 1.4 角色管理

一组权限的集合

```
> create role 'write_role';
Query OK, 0 rows affected (0.00 sec)

> select user,host,authentication_string from mysql.user;
+------------------+-----------+------------------------------------------------------------------------+
| user             | host      | authentication_string                                                  |
+------------------+-----------+------------------------------------------------------------------------+
| aubrey           | %         | $A$005$Q -QBhmA
CzVKsDpmkbE8TZtvg3A8GsVvSzLs1LNBtxaNNBC4pmlM1q/vA |
| write_role       | %         |                                                                        |
| mysql.infoschema | localhost | $A$005$THISISACOMBINATIONOFINVALIDSALTANDPASSWORDTHATMUSTNEVERBRBEUSED |
| mysql.session    | localhost | $A$005$THISISACOMBINATIONOFINVALIDSALTANDPASSWORDTHATMUSTNEVERBRBEUSED |
| mysql.sys        | localhost | $A$005$THISISACOMBINATIONOFINVALIDSALTANDPASSWORDTHATMUSTNEVERBRBEUSED |
| root             | localhost | $A$005$."
<&SYrhh1O8.7HTcpirAVG8/tCQKsOZAsRegZ2zClL1gl6 |
+------------------+-----------+------------------------------------------------------------------------+
6 rows in set (0.00 sec)

> grant insert,update,delete on aubrey.* to 'write_role';
Query OK, 0 rows affected (0.00 sec)

> grant select on aubrey.* to 'write_role';
Query OK, 0 rows affected (0.00 sec)

> create user 'test' identified by 'Password@123';
Query OK, 0 rows affected (0.01 sec)

> grant 'write_role' to test;
Query OK, 0 rows affected (0.00 sec)

> SHOW GRANTS FOR test;
+--------------------------------------+
| Grants for test@%                    |
+--------------------------------------+
| GRANT USAGE ON *.* TO `test`@`%`     |
| GRANT `write_role`@`%` TO `test`@`%` |
+--------------------------------------+
2 rows in set (0.00 sec)

mysql> SHOW GRANTS FOR test using 'write_role';
+------------------------------------------------------------------+
| Grants for test@%                                                |
+------------------------------------------------------------------+
| GRANT USAGE ON *.* TO `test`@`%`                                 |
| GRANT SELECT, INSERT, UPDATE, DELETE ON `aubrey`.* TO `test`@`%` |
| GRANT `write_role`@`%` TO `test`@`%`                             |
+------------------------------------------------------------------+
3 rows in set (0.00 sec)



mysql> select user();
+----------------+
| user()         |
+----------------+
| test@localhost |
+----------------+
1 row in set (0.00 sec)

mysql> select * from aubrey.t1;
ERROR 1142 (42000): SELECT command denied to user 'test'@'localhost' for table 't1'

mysql> select current_role();
+----------------+
| current_role() |
+----------------+
| NONE           |
+----------------+
1 row in set (0.01 sec)

mysql> set role 'write_role';
Query OK, 0 rows affected (0.00 sec)

mysql> select current_role();
+------------------+
| current_role()   |
+------------------+
| `write_role`@`%` |
+------------------+
1 row in set (0.00 sec)

mysql> select * from aubrey.t1;
Empty set (0.38 sec)
```

```
//设置用户默认角色
mysql> set default role 'write_role' to 'test';
Query OK, 0 rows affected (0.00 sec)

mysql> set default role all to 'test';            
Query OK, 0 rows affected (0.01 sec)

//查看角色
mysql> select * from mysql.default_roles;
+------+------+-------------------+-------------------+
| HOST | USER | DEFAULT_ROLE_HOST | DEFAULT_ROLE_USER |
+------+------+-------------------+-------------------+
| %    | test | %                 | write_role        |
+------+------+-------------------+-------------------+
1 row in set (0.00 sec)

mysql> select * from mysql.role_edges;
+-----------+------------+---------+---------+-------------------+
| FROM_HOST | FROM_USER  | TO_HOST | TO_USER | WITH_ADMIN_OPTION |
+-----------+------------+---------+---------+-------------------+
| %         | write_role | %       | test    | N                 |
+-----------+------------+---------+---------+-------------------+
1 row in set (0.00 sec)

//回收角色权限
mysql> revoke insert,update,delete on aubrey.* from 'write_role'; 
Query OK, 0 rows affected (0.00 sec)

mysql> show grants for 'write_role';
+------------------------------------------------+
| Grants for write_role@%                        |
+------------------------------------------------+
| GRANT USAGE ON *.* TO `write_role`@`%`         |
| GRANT SELECT ON `aubrey`.* TO `write_role`@`%` |
+------------------------------------------------+
2 rows in set (0.00 sec)

> show grants for 'test' using 'write_role';
+------------------------------------------+
| Grants for test@%                        |
+------------------------------------------+
| GRANT USAGE ON *.* TO `test`@`%`         |
| GRANT SELECT ON `aubrey`.* TO `test`@`%` |
| GRANT `write_role`@`%` TO `test`@`%`     |
+------------------------------------------+
3 rows in set (0.00 sec)
```

