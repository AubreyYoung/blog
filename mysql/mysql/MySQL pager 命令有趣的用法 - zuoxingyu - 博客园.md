# MySQL pager 命令有趣的用法 - zuoxingyu - 博客园

  

原文链接：[http://www.mysqlperformanceblog.com/2013/01/21/fun-with-the-mysql-pager-
command/](http://www.mysqlperformanceblog.com/2013/01/21/fun-with-the-mysql-
pager-command/)

[Last time](http://www.mysqlperformanceblog.com/2012/12/21/be-productive-with-
the-mysql-command-line/) I wrote about a few tips that can make you more
efficient when using the command line on Unix. Today I want to focus more on
pager.

The most common usage of pager is to set it to a Unix pager such as less. It
can be very useful to view the result of a command spanning over many lines
(for instance `SHOW ENGINE INNODB STATUS`):

[上次](http://www.cnblogs.com/zuoxingyu/archive/2013/02/17/2914618.html)我写了篇短文讲述怎么样让unix命令更有效率，今天我着重说说pager.

pager最常见的用法是设置为Unix pager,比如less,它对于阅读多行文本非常有帮助（比如 SHOW ENGINE INNODB STATUS):

    
    
    mysql> pager less
    PAGER set to 'less'
    mysql> show engine innodb status\G
    [...]

Now you are inside `less` and you can easily navigate through the result set
(use q to quit, space to scroll down, etc).

Reminder: if you want to leave your custom pager, this is easy, just run
`pager`:

现在你已经进入到less程序里了，可以很方便的查看结果集（q 退出，空格翻页等）

提醒：如果你想恢复到默认pager,很简单，运行pager就行了：

    
    
    mysql> pager
    Default pager wasn't set, using stdout.

Or `\n`:

    
    
    mysql> \n
    PAGER set to stdout

But the pager command is not restricted to such basic usage! You can pass the
output of queries to most Unix programs that are able to work on text. We have
discussed the [topic](http://www.mysqlperformanceblog.com/2008/06/23/neat-
tricks-for-the-mysql-command-line-pager/), but here are a few more examples.

pager命令不局限于这样基础的用法，你可以把查询输出到很多unix程序里，我们在这篇文章里面讨论，但是在这里，也给出一些例子

## Discarding the result set 丢弃结果集

Sometimes you don’t care about the result set, you only want to see timing
information. This can be true if you are trying different execution plans for
a query by changing indexes. Discarding the result is possible with pager:

有时候我们并不关注结果集，仅仅只是看看执行SQL的时间信息。如果你用不同的索引改变执行计划，这时间就会是不一样的。用pager丢弃结果集是可行的

    
    
    mysql> pager cat > /dev/null
    PAGER set to 'cat > /dev/null'
    
    # Trying an execution plan
    mysql> SELECT ...
    1000 rows in set (0.91 sec)
    
    # Another execution plan
    mysql> SELECT ...
    1000 rows in set (1.63 sec)

Now it’s much easier to see all the timing information on one screen.

现在在一屏里可以很容易的看到SQL花费的时间信息了

## Comparing result sets 比较结果集

Let’s say you are rewriting a query and you want to check if the result set is
the same before and after rewrite. Unfortunately, it has a lot of rows:

现在我们看看，你重写了一个SQL，想去比较下结果集和改写前是不是一样的，不幸的是结果集有很多行

    
    
    mysql> SELECT ...
    [..]
    989 rows in set (0.42 sec)

Instead of manually comparing each row, you can calculate a checksum and only
compare the checksum:

用不着手工去比较每一行，你可以通过计算checksume值，然后只比较这个值

    
    
    mysql> pager md5sum
    PAGER set to 'md5sum'
    
    # Original query
    mysql> SELECT ...
    32a1894d773c9b85172969c659175d2d  -
    1 row in set (0.40 sec)
    
    # Rewritten query - wrong
    mysql> SELECT ...
    fdb94521558684afedc8148ca724f578  -
    1 row in set (0.16 sec)

Hmmm, checksums don’t match, something is wrong. Let’s retry:

呵呵呵，checksum不同，SQL有问题

    
    
    # Rewritten query - correct
    mysql> SELECT ...
    32a1894d773c9b85172969c659175d2d  -
    1 row in set (0.17 sec)

Checksums are identical, the rewritten query is much likely to produce the
same result as the original one.

checksum值相同，重写后的SQL结果集和重写前的完全一样

## Cleaning up `SHOW PROCESSLIST 清理SHOW PROCESSLIST信息`

If you have lots of connections on your MySQL, it’s very difficult to read the
output of `SHOW PROCESSLIST`. For instance, if you have several hundreds of
connections and you want to know how many connections are sleeping, manually
counting the rows from the output of `SHOW PROCESSLIST` is probably not the
best solution. With pager, it is straightforward:

如果你的MYSQL有很多连接在跑，读show
processlist就变得很困难了。比方说，如果你有几百个连接，然后想去看看有多少连接处于sleeping状态，人工去数show
processlist可能不是最好的办法，使用pager,就非常简单了

    
    
    mysql> pager grep Sleep | wc -l
    PAGER set to 'grep Sleep | wc -l'
    mysql> show processlist;
    337
    346 rows in set (0.00 sec)

This should be read as ’337 out 346 connections are sleeping’.

这应该是：346个连接里，有337个是sleeping的

Slightly more complicated now: you want to know the number of connections for
each status:

再稍微复杂点，你想统计下各种状态的连接数有多少

    
    
    mysql> pager awk -F '|' '{print $6}' | sort | uniq -c | sort -r
    PAGER set to 'awk -F '|' '{print $6}' | sort | uniq -c | sort -r'
    mysql> show processlist;
        309  Sleep       
          3 
          2  Query       
          2  Binlog Dump 
          1  Command

Astute readers will have noticed that these questions could have been solved
by querying INFORMATION_SCHEMA. For instance, counting the number of sleeping
connections can be done with:

聪明的读者应该已经发现了，这个语句可以通过查询INFORMATION_SCHEMA库得到。比方说，计算sleeping状态的连接数，可以通过下面的查询

    
    
    mysql> SELECT COUNT(*) FROM INFORMATION_SCHEMA.PROCESSLIST WHERE COMMAND='Sleep';
    +----------+
    | COUNT(*) |
    +----------+
    |      320 |
    +----------+

and counting the number of connection for each status can be done with:

统计每个状态的连接数

    
    
    mysql> SELECT COMMAND,COUNT(*) TOTAL FROM INFORMATION_SCHEMA.PROCESSLIST GROUP BY COMMAND ORDER BY TOTAL DESC;
    +-------------+-------+
    | COMMAND     | TOTAL |
    +-------------+-------+
    | Sleep       |   344 |
    | Query       |     5 |
    | Binlog Dump |     2 |
    +-------------+-------+

True, but:

  * It’s nice to know several ways to get the same result
  * Some of you may feel more comfortable with writing SQL queries, while others will prefer command line tools

完全正确，但是：

  * 懂得很多的办法达到同样的目的是很酷的
  * 有些人觉得写SQL语句比较舒服，但是有些更喜欢命令行工具

## Conclusion 结论

As you can see, pager is your friend! It’s very easy to use and it can solve
problems in an elegant and very efficient way. You can even write your custom
script (if it is too complicated to fit in a single line) and pass it to the
pager.

如你所见，pager非常有用。它非常简单，可以通过不同的思路解决问题。你甚至可以用pager来写你的脚本。

  


---
### ATTACHMENTS
[51e409b11aa51c150090697429a953ed]: media/copycode-2.gif
[copycode-2.gif](media/copycode-2.gif)
>hash: 51e409b11aa51c150090697429a953ed  
>source-url: http://common.cnblogs.com/images/copycode.gif  
>file-name: copycode.gif  


---
### TAGS
{pager}

---
### NOTE ATTRIBUTES
>Created Date: 2018-03-19 08:29:22  
>Last Evernote Update Date: 2018-10-01 15:35:37  
>author: YangKwong  
>source: web.clip  
>source-url: http://www.cnblogs.com/zuoxingyu/archive/2013/02/17/2914549.html  