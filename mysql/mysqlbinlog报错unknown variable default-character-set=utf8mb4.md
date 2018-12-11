## mysqlbinlog报错:unknown variable default-character-set=utf8mb4



使用 mysqlbinlog 命令查看 binlog 日志时出现`mysqlbinlog: unknown variable 'default-character-set=utf8mb4'`的报错, 原因是在 mysql 的配置文件中, 我设置默认字符集为`utf8mb4`此字符集为 utf8 的扩展字符集,支持保存 emoji😈 表情, 解决方案如下

```
➜  ~ mysqlbinlog mysql-bin.000256
mysqlbinlog: unknown variable 'default-character-set=utf8mb4'
```

**原因是mysqlbinlog这个工具无法识别binlog中的配置中的default-character-set=utf8这个指令**

解决的办法有两个:

1. 将`/etc/my.cnf`中配置的`default-character-set = utf8mb4`修改为`character-set-server = utf8mb4`但是这种修改方法需要重启数据库, 在线上业务库中使用这种方法查看 binlog 日志并不划算~
2. `mysqlbinlog --no-defaults mysql-bin.000256` 完美解决~