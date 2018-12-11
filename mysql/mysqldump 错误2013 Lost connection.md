## mysqldump 错误2013 Lost connection

> 导出数据库的时候报如下错误 `mysqldump: Error 2013: Lost connection to MySQL server during query when dumping table`mail`at row: 2637433`

**查询资料**

大概说是因为mysqldump来不及接受mysql server端发送过来的数据，Server端的数据就会积压在内存中等待发送，这个等待不是无限期的，当Server的等待时间超过net_write_timeout（默认是60秒）时它就失去了耐心，mysqldump的连接会被断开，同时抛出错误Got error: 2013: Lost connection。

**解决方案一**

增加net_write_timeout可以解决上述的问题的。在实践中发现，在增大 net_write_timeout后，Server端会消耗更多的内存，有时甚至会导致swap的使用（并不确定是不是修改 net_write_timeout所至）。建议在mysqldump之前修改net_write_timeout为一个较大的值（如1800），在 mysqldump结束后，在将这个值修改到默认的60。

在sql命令行里面设置临时全局生效用类似如下命令：
SET GLOBAL net_write_timeout=1800;

修改了这个参数后再备份，不再报错
注意，这个参数不是mysqldump选项，而是mysql的一个配置参数

**解决方案二**

在执行 mysqldump 的时候可以通过添加 `--quick` 的参数来避免出现这样的问题

```
 --quick，-q

该选项用于转储大的表。它强制mysqldump从服务器一次一行地检索表中的行而不是检索所有行并在输出前将它缓存到内存中。
```

------

**参考文档**

<http://www.linuxyw.com/linux/yunweiguzhang/20130609/566.html>

<http://www.cnblogs.com/haven/archive/2012/10/27/2742141.html>