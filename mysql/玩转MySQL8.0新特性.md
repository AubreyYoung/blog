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
>alter  user 'sample'@'%' password history 5;

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

//修改当前用户密码
> alter user user() identified by 'oracle@345'; 
Query OK, 0 rows affected (0.00 sec)
```

### 1.4 角色管理

