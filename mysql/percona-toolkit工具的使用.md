##  [percona-toolkit工具的使用](https://www.cnblogs.com/chenpingzhao/p/4850420.html)

percona-toolkit是一组高级命令行工具的集合，可以查看当前服务的摘要信息，磁盘检测，分析慢查询日志，查找重复索引，实现表同步等等

percona-toolkit 源自 Maatkit 和 Aspersa 工具，这两个工具是管理 mysql 的最有名的 工具，现在 Maatkit 工具已经不维护了，请大家还是使用 percona-toolkit 吧！这些 工具主要包括开发、性能、配置、监控、复制、系统、实用六大类，作为一个优秀 的 DBA，里面有的工具非常有用，如果能掌握并加以灵活应用，将能极大的提高工 作效率。

## 介绍

**1. pt-duplicate-key-checker**

功能为从 mysql 表中找出重复的索引和外键，这个工具会将重复的索引和外键都列出来，并生成了删除重复索引的语句，非常方便

```
pt-duplicate-key-checker --h localhost --u root --p 123456 -d test
```
2. pt-online-schema-change

功能为在 alter 操作更改表结构的时候不用锁定表，也就是说执行 alter 的时候不会阻塞写和读取操作，注意执行这个工具的时候必须 做好备份

官方文档 http://www.percona.com/doc/percona-toolkit/2.1/pt-online-schema-ch ange.html

工作原理是创建一个和你要执行 alter 操作的表一样的空表结构，执 行表结构修改，然后从原表中 copy 原始数据到表结构修改后的表， 当数据 copy 完成以后就会将原表移走，用新表代替原表，默认动作 是将原表 drop 掉。在 copy 数据的过程中，任何在原表的更新操作都 会更新到新表，因为这个工具在会在原表上创建触发器，触发器会将 在原表上更新的内容更新到新表。如果表中已经定义了触发器这个工 具就不能工作了。

```
pt-online-schema-change --lock-wait-time=120 --alter="ENGINE=InnoDB" D=database,t=table --execute
pt-online-schema-change --lock-wait-time=120 --alter="ADD COLUMN domain_id INT" D=database,t=table --execute
```

**3. pt-query-advisor**

根据一些规则分析查询语句，对可能的问题提出建议

```
pt-query-advisor /path/to/slow-query.log
pt-query-advisor --type genlog mysql.log
pt-query-digest --type tcpdump.txt --print --no-report | pt-query-advisor
pt-query-advisor --query "select * from test"
pt-query-advisor /path/to/general.log
pt-query-advisor /path/to/localhost-slow.log
```

4. pt-show-grants

规范化和打印 mysql 权限，让你在复制、比较 mysql 权限以及进行版 本控制的时候更有效率

```
`pt-show-grants --h localhost --u root --p 123456``pt-show-grants --h localhost --u root --p 123456 -d test``pt-show-grants --h localhost --u root --p 123456 -d test --revoke`
```

5. pt-upgrade

在多台服务器上执行查询，并比较有什么不同！这在升级服务器的时 候非常有用，可以先安装并导数据到新的服务器上，然后使用这个工 具跑一下 sql 看看有什么不同，可以找出不同版本之间的差异

**6. pt-index-usage**

从 log 文件中读取查询语句，并用 explain 分析他们是如何利用索引。 完成分析之后会生成一份关于索引没有被查询使用过的报告

```
pt-index-usage /path/to/slow.log --h localhost --u root --p 123456 -d test --no-report --create-save-results-database
```

7. pt-pmp

为查询程序执行聚合的 GDB 堆栈跟踪，先进性堆栈跟踪，然后将跟踪信息汇总

```
pt-pmp -p 21933
pt-pmp -b /usr/local/mysql/bin/mysqld_safe
```

8. pt-visual-explain

格式化 explain 出来的执行计划按照 tree 方式输出，方便阅读

```
pt-visual-explain --connect aaa --h localhost --u root --p 123456 -d test
pt-visual-explain `mysql --h localhost --u root --p 123456 -d test -e "explain select testx from test where id=1"` |
```

9. pt-config-diff

比较 mysql 配置文件和服务器参数

```
pt-config-diff /usr/local/mysql/share/mysql/my-large.cnf /usr/local/mysql/share/mysql/my-medium.cnf
```

**10. pt-mysql-summary**

精细地对 mysql 的配置和 sataus 信息进行汇总，汇总后你直接看一眼 就能看明白

```
pt-mysql-summary  --user=root --password=sEtNcu3O9R7Dl29c --all-databases
```

**11. pt-variable-advisor**

分析 mysql 的参数变量，并对可能存在的问题提出建议

```
pt-variable-advisor --h localhost --u root --p 123456
```

结果

```
# WARN delay_key_write: MyISAM index blocks are never flushed until necessary.
# WARN innodb_lock_wait_timeout: This option has an unusually long value, which can cause system overload if locks are not being released.
# NOTE innodb_max_dirty_pages_pct: The innodb_max_dirty_pages_pct is lower than the default.
# NOTE low_priority_updates: The server is running with non-default lock priority for updates.
# NOTE max_binlog_size: The max_binlog_size is smaller than the default of 1GB.
# NOTE port: The server is listening on a non-default port.
# NOTE read_buffer_size-1: The read_buffer_size variable should generally be left at its default unless an expert determines it is necessary to change it.
# NOTE read_rnd_buffer_size-1: The read_rnd_buffer_size variable should generally be left at its default unless an expert determines it is necessary to change it.
# CRIT slave_skip_errors: You should not set this option.
# NOTE sort_buffer_size-1: The sort_buffer_size variable should generally be left at its default unless an expert determines it is necessary to change it.
# NOTE tx_isolation-1: This server's transaction isolation level is non-default.
# NOTE innodb_data_file_path: Auto-extending InnoDB files can consume a lot of disk space that is very difficult to reclaim later.
# WARN log_output: Directing log output to tables has a high performance impact.
```

12. pt-deadlock-logger

提取和记录 mysql 死锁的相关信息,收集和保存 mysql 上最近的死锁信息，可以直接打印死锁信息和存储 死锁信息到数据库中，死锁信息包括发生死锁的服务器、最近发生死 锁的时间、死锁线程 id、死锁的事务 id、发生死锁时事务执行了多长 时间等等非常多的信息

13. pt-fk-error-logger

提取和记录 mysql 外键错误信息，通过SHOW INNODB STATUS提取和保存mysql数据库最近发生的外键 错误信息。可以通过参数控制直接打印错误信息或者将错误信息存储 到数据库的表中

14. pt-mext

并行查看 SHOW GLOBAL STATUS 的多个样本的信息，原理：pt-mext 执行你指定的 COMMAND，并每次读取一行结果，把 空行分割的内容保存到一个一个的临时文件中，最后结合这些临时文 件并行查看结果

**15. pt-query-digest**

分析查询执行日志，并产生一个查询报告，为 MySQL、PostgreSQL、 memcached 过滤、重放或者转换语句

16. pt-trend

居于一组时间序列的数据点做统计，读取一个慢查询日志，并输出统计信息。也可以指定多个文件。如果 不指定文件的话直接从标准输入中读取信息

17. pt-heartbeat

监控 mysql 复制延迟，测量复制落后主 mysql 或者主 PostgreSQL 多少时间，你可以使用这个 脚本去更新主或者监控复制

原理：pt-heartbeat 通过真实的复制数据来确认 mysql 和 postgresql 复制延迟，这个避免了对复制机制的依赖，从而能得出准确的落后复 制时间，包含两部分：第一部分在主上 pt-heartbeat 的--update 线程 会在指定的时间间隔更新一个时间戳，第二部分是 pt-heartbeat 的 --monitor 线程或者--check 线程连接到从上检查复制的心跳记录（前 面更新的时间戳），并和当前系统时间进行比较，得出时间的差异。 你可以手工创建 heartbeat 表或者添加--create-table 参数，推荐使用 MEMORY 引擎

18. pt-slave-delay

设置从服务器落后于主服务器指定时间

原理：通过启动和停止复制 sql 线程来设置从落后于主指定时间。默 认是基于从上 relay 日志的二进制日志的位置来判断，因此不需要连 接到主服务器，如果 IO 进程不落后主服务器太多的话，这个检查方 式工作很好，如果网络通畅的话，一般 IO 线程落后主通常都是毫秒 级别。一般是通过--delay and --delay"+"--interval 来控制。--interval 是 指定检查是否启动或者停止从上 sql 线程的频繁度，默认的是 1 分钟 检查一次

19. pt-slave-find

查找和打印 mysql 所有从服务器复制层级关系

原理:连接 mysql 主服务器并查找其所有的从，然后打印出所有从服 务器的层级关系

20. pt-slave-restart

监视 mysql 复制错误，并尝试重启 mysql 复制当复制停止的时候，监视一个或者多个 mysql 复制错误，当从停止的时候尝试重新启动复 制。你可以指定跳过的错误并运行从到指定的日志位置

21. pt-table-checksum

检查 mysql 复制一致性

工作原理：pt-table-checksum 在主上执行检查语句在线检查 mysql 复 制的一致性，生成 replace 语句，然后通过复制传递到从，再通过 update 更新 master_src 的值。通过检测从上 this_src 和 master_src 的 值从而判断复制是否一致。 注意：使用的时候选择业务地峰的时候运行，因为运行的时候会造成 表的部分记录锁定。使用--max-load 来指定最大的负载情况，如果达 到那个负载这个暂停运行。如果发现有不一致的数据，可以使用 pt-table-sync 工具来修复。 注意：和 1.0 版本不同，新版本的 pt-table-checksum 只需要在 master 上执行即可。 通过 –explain 参数再结合二进制日志就可以看出脚本的工作原理， 如我的 test 库有一个名字为 zhang 的表，我们通过抓取二进制日志来 查看

22. pt-table-sync

高效同步 mysql 表的数据

原理：总是在主上执行数据的更改，再同步到从上，不会直接更改成 从的数据，在主上执行更改是基于主上现在的数据，不会更改主上的 数据。注意使用之前先备份你的数据，避免造成数据的丢失.执行 execute 之前最好先换成--print 或--dry-run 查看一下会变更哪些数据

23. pt-diskstats

是一个对 GUN/LINUX 的交互式监控工具，为 GUN/LINUX 打印磁盘 io 统计信息，和 iostat 有点像，但是这个工 具是交互式并且比 iostat 更详细。可以分析从远程机器收集的数据

24. pt-fifo-split

模拟切割文件并通过管道传递给先入先出队列而不用真正的切割文 件，pt-fifo-split 读取大文件中的数据并打印到 fifo 文件，每次达到指定行 数就往 fifo 文件中打印一个 EOF 字符，读取完成以后，关闭掉 fifo 文 件并移走，然后重建 fifo 文件，打印更多的行。这样可以保证你每次 读取的时候都能读取到制定的行数直到读取完成。注意此工具只能工 作在类 unix 操作系统。这个程序对大文件的数据导入数据库非常有 用，具体的可以查看 http://www.mysqlperformanceblog.com/2008/07 /03/how-to-load-large-files-safely-into-innodb-with-load-data-infile/。

**25. pt-summary**

友好地收集和显示系统信息概况，此工具并不是一个调优或者诊断工 具，这个工具会产生一个很容易进行比较和发送邮件的报告

原理：此工具会运行和多命令去收集系统状态和配置信息，先保存到 临时目录的文件中去，然后运行一些unix命令对这些结果做格式化， 最好是用 root 用户或者有权限的用户运行此命令

26. pt-stalk

出现问题的时候收集 mysql 的用于诊断的数据，pt-stalk 等待触发条件触发，然后收集数据帮助错误诊断，它被设计 成使用 root 权限运行的守护进程，因此你可以诊断那些你不能直接 观察的间歇性问题。默认的诊断触发条件为 SHOW GLOBAL STATUS。 也可以指定 processlist 为诊断触发条件 ，使用--function 参数指定

27. pt-archiver

将 mysql 数据库中表的记录归档到另外一个表或者文件，也可以直接 进行记录的删除操作

这个工具只是归档旧的数据，不会对线上数据的 OLTP 查询造成太大 影响，你可以将数据插入另外一台服务器的其他表中，也可以写入到 一个文件中，方便使用 load data infile 命令导入数据。另外你还可以 用它来执行 delete 操作。这个工具默认的会删除源中的数据。使用 的时候请注意

28. pt-find

查找 mysql 表并执行指定的命令，和 gnu 的 find 命令类似

29. pt-kill

Kill 掉符合指定条件 mysql 语句，假如没有指定文件的话pt-kill连接到mysql并通过SHOW PROCESSLIST 找到指定的语句，反之 pt-kill 从包含 SHOW PROCESSLIST 结果的文件 中读取 mysql 语句