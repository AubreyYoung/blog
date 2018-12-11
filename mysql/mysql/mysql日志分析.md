# mysql日志分析

    日志文件(log)就是一个跟踪记录的列表，它可以协助我们时刻掌握系统及应用服务的动作状态，在故障排查的时候提供最详细准确地信息，帮助我们快速查找原因，减少我们凭主观的经验去猜测，这样的答案更具有说服力，机器通常是不会撒谎的。任何的系统，无论是操作系统、数据库、应用服务器他们都会有自己的log文件，而且根据功能性质的不同，又有分为不同种类的log。后面我们将要讨论的MySQL数据库同样也有自己的一套日志纪录文件，可分为种日志—— **二进制日志** **慢查询日志** 。它们都有哪些作用，我们在实际工作中又将如何有效的使用这些log文件呢？

    这4种日志文件默认情况下都存放在$MYSQL_HOME/data目录下面，我们也可以使用服务器启动选项来对日志存放的位置以及名称来进行自定义。下面图片中显示了各种log文件，错误日志node1.err、二进制日志以mysql-bin开头的16个文件、查询日志node1.log、以及慢查询日志node1-slow.log。

[](http://www.mysqlsystems.com/wp-content/uploads/2009/05/mysql_log1.jpg)

1\. 错误日志 –log-error[=/path_to/file_name]

它记录了MySQL数据库启动关闭信息，以及服务器运行过程中所发生的任何严重的错误信息。通常，当数据库出现问题不能正常启动，我们应当首先想到的就是查看错误日志。从下面可以看到此日志文件记录了MySQL数据库的启动和关闭信息。

[](http://www.mysqlsystems.com/wp-content/uploads/2009/05/mysql-log-
error1.jpg)

2\. 二进制日志 –log-bin=[/path_to/file_name]

binary
log文件是以二进制格式保存的，我们需要借助mysqlbinlog这个工具进行查看，该日志里面记录的所有的DDL和DML语句，其中select语句除外。

[](http://www.mysqlsystems.com/wp-content/uploads/2009/05/mysql-binlog1.jpg)

以上显示的是从位置232609开始到最后一次操作结束的binlog文件里记录的内容。

在data目录下会发现有16个binary
log文件，每次重启服务都会重新生成一个，或是文件达到最到限度也会安顺序自动生成下一个文件。在一个繁忙的OLTP系统中，每天会有大量的日志生成，自然我们会想到它将会占用可观的磁盘空间，所以我们有必要定期对其进行清理。下面介绍几种方法。

Option 1. mysql> reset master; (删除所有binlog文件，然后从新生成一个从000001开始的文件)

Option 2. mysql> purge master logs to ‘mysql-bin.000017′; (删除mysql-
bin.000017之前的所有日志)

Option 3. # mysqladmin flush-log
(根据配置文件my.cnf中的expire_logs_day参数，触发日志文件更新，将从当前日期开始前多少天的日志全部删除)

3\. 查询日志 –log[=/path_to/file_name]

查询日志记录客户端操作的所有sql语句，包括select查询语句在内。(note:
查询日志纪录的所有数据库的操作，对于访问频繁的应用，该日志对系统性能会一定影响，建议通常关闭此日志。)

[](http://www.mysqlsystems.com/wp-content/uploads/2009/05/mysql-querylog1.jpg)

4\. 慢查询日志 –log-slow-queries[=/path_to/file_name]

慢查询日志里记录了执行时间超过long_query_time参数值的sql语句。慢查询日志可以有效的帮助我们发现实际应用中sql的性能问题，找出执行效率低下的sql语句。

我们经常会看到上面，人家在回答你问题之前，有些时候会让你提供详细的日志信息，然后进一步分析帮你解决问题，这就是一个很好的解决问题的习惯和思路，做到有理有据，log就是我们查明真相的线索。了解了MySQL的日志之后，你也可以成为一个地道的troublshooting的专家。

  



---
### TAGS
{日志}

---
### NOTE ATTRIBUTES
>Created Date: 2016-05-19 00:46:25  
>Last Evernote Update Date: 2016-06-08 08:58:14  
>source: Clearly  
>source-url: http://www.blog.chinaunix.net/uid-10565106-id-223928.html  