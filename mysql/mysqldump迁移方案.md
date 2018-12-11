## mysqldump迁移方案

## mysqldump迁移方案

> 数据库D从A主机迁往B主机

## 前期准备

- 前端应用操作D库的用户名和密码

向研发人员收集用户名和密码，在B主机的数据库实例中，预先建立用户

```
B: mysql> create user 'username'@'%' identified by 'password';
```

- 在A主机中查询D库中该用户的权限

找到该用户对应的D库的权限SQL语句，保存一下，等到B主机建库后，给该用户赋予权限

```
A: mysql> show grants for username;
```

- 收集需要迁移的目标数据库的建库参数

**一般情况下午特殊建库参数，注意字符集**

*用户体系的my.cnf中指定字符集默认为character_set_server=utf8*

*ocrdb的my.cnf中指定字符集默认为character_set_server=utf8mb4*

```
A: mysql> show create database dbname;
```

- 为上面指定的用户赋予B主机上新库的权限

```
B: mysql> 在B主机上执行第二步保存的grant语句
```

## 迁移前的操作

- 将A主机上D库用户的`insert` `update` `delete`权限撤销

```
A: mysql> revoke INSERT, UPDATE, DELETE ON databasename.* FROM username;
```

- 停止连接数据库A的所有前端应用

尽可能停止连接`数据库A`的所有前端应用，不能停止的，将在数据库中`kill`掉`ESTABLISHED`的连接，让前端应用的连接池重新连接mysql数据库

检查该用户的连接情况

```
A: $> mysql -uroot -p -e 'show processlist;' | grep username
```

如果前端应用停止后，仍有其他服务器的连接，则kill掉这些连接，让其重连，重新获取该库权限，并记录这些服务器的IP地址，因为该库迁走并剥夺写入权限后，这些服务器可能会有问题

## 迁移

- mysqldump

```
A: $> mysqldump -uusername -p databasename | gzip > databasename.sql.gz
```

- scp

```
A: $> scp databasename.sql.gz ps@IP:/tmp/
```

- load

```
B: $> gunzip < databasename.sql.gz | mysql -uroot -p databasename
```

## 迁移后

- 在三区开启应用服务器，连接三区mysql

## 附

- 删除某一用户的所有权限

```
revoke all on *.* from sss@localhost ;
```