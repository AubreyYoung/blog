## 开启GTID的情况下导出导入库的注意事项
在开启了 GTID 功能的 MySQL 数据库中, 不论是否使用了 GTID 的方式做了主从同步, 导出导入时都需要特别注意数据库中的 GTID 信息.
## 导出
```
mysqldump -uroot -p userdb > userdb.sql
Warning: A partial dump from a server that has GTIDs will by default include the GTIDs of all transactions, even those that changed suppressed parts of the database. If you don't want to restore GTIDs, pass --set-gtid-purged=OFF. To make a complete dump, pass --all-databases --triggers --routines --events
```
mysql提示: 当前数据库实例中开启了 GTID 功能, 在开启有 GTID 功能的数据库实例中, 导出其中任何一个库, 如果没有显示地指定`--set-gtid-purged`参数, 都会提示这一行信息. 意思是默认情况下, 导出的库中含有 GTID 信息, 如果不想导出包含有 GTID 信息的数据库, 需要显示地添加`--set-gtid-purged=OFF`参数. 于是乎, dump 变成了如下样子
```
mysqldump -uroot -p --set-gtid-purged=OFF userdb > userdb.sql
```
使用以上这条命令 dump 出来的库是不包含 GTID 信息的
## 导入
导入的时候也分两种, 一种是导入带有 GTID 的信息的库, 一种是导入不带有 GTID 信息的库
## 不带有 GTID 信息
不带有 GTID 信息的 dump 文件, 不管目标数据库实例是否开启了 GTID 功能, 且不管数据库实例是否已有其他 GTID 信息, 都可以顺利导入
## 带有 GTID 信息
带有 GTID 信息的 dump 文件, 要求目标数据库实例必须开启 GTID 功能, 且当前数据库中无其他 GTID 信息. 如果目标数据库中已经记录了一条或一条以上的 GTID 信息, 那么在导入数据库时会报出类似如下的错误❌
```
mysql -uroot -p userdb < userdb.sql
Password:xxxxxxxx
ERROR 1840 (HY000) at line 24: @@GLOBAL.GTID_PURGED can only be set when @@GLOBAL.GTID_EXECUTED is empty.
```
在 mysql5.7版本中加入了多 channel 的特性, 一台数据库实例可以同时与多个主库同步, 实现多主一从架构, 但是假如现在数据库实例中开启了 GTID, 并以 GTID 的方式与 A 主库和 B 主库同步,那么现在的 slave 中就记录有两条 GTID 信息. 在导入带有新 GTID 信息的库时, 会报错, 要求你清除掉目标数据库实例中所有的 GTID 信息. 在这种情况下, 问题就比较严重了, 因为我的这台数据库已经和两台主库建立主从关系, 现在为了导入一个新库, 需要 reset 掉所有同步信息(GTID 信息)
这个时候你有两个选择:
1. 重新 dump 数据库, 使用`--set-gtid-purged=OFF`的参数禁止🚫导出 GTID 信息,再 load 进目标数据库
2. 在目标数据库中执行`mysql> reset slave all;` `mysql> reset master;` 清空所有 GTID 信息之后就可以导入了