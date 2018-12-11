# MySQL 5.7 在线开启和关闭GTID | | For DBA

  

# MySQL 5.7 在线开启和关闭GTID

Posted on [2017-04-17](http://www.fordba.com/mysql57replication-mode-change-
online-enable-and-disable-gtids-html.html) by
[Harvey](http://www.fordba.com/author/admin) __[Leave a
comment](http://www.fordba.com/mysql57replication-mode-change-online-enable-
and-disable-gtids-html.html#respond) __
[MySQL](http://www.fordba.com/category/mysql)

## 一、前言

最近在测试MySQL5.7的新特性，升级到5.7后xtraback需要升级到2.4，测试发现了如下报错：

    
    
    The --slave-info option requires GTID enabled for a multi-threaded slave.
    
    

`--slave-info` 选项表示如果在从库上备份，他能够获取主库的binlog位点，记录到xtrabackup_slave_info文件中  
该报错意思是如果开启了多线程复制，那么`--slave-
info`选项需要打开GTID,刚好我没开启，而5.7又支持在线开启和关闭GTID,于是做了如下实验。

* * *

## 二、在线开启GTID

在MySQL 5.7.6之后，可以在线开启GTID，需要满足两个条件  
1、复制拓扑结构中，所有的数据库版本必须大于等于5.7.6  
2、 `gtid_mode`必须设置为`OFF`

1、在拓扑结构中所有服务器运行以下命令：（非常重要）

    
    
    SET @@GLOBAL.ENFORCE_GTID_CONSISTENCY = WARN;
     [Note] Changed ENFORCE_GTID_CONSISTENCY from OFF to WARN.
    

开启这个选项时候，让服务器在正常负载下运行一段时间，观察`err log`，如果有发现任何warning，需要通知应用进行调整，直到不出现warning。

2、在拓扑结构中所有服务器运行以下命令：

    
    
    SET @@GLOBAL.ENFORCE_GTID_CONSISTENCY = ON;
    
    [Note] Changed ENFORCE_GTID_CONSISTENCY from WARN to ON.
    

3、在拓扑结构中所有服务器运行以下命令，所有服务器必须执行完这一步之后才能执行下一步：

    
    
    SET @@GLOBAL.GTID_MODE = OFF_PERMISSIVE;
    
    [Note] Changed GTID_MODE from OFF to OFF_PERMISSIVE.
    

该命令的效果:服务器不产生GTID，但是能够接受不带GTID的事务，也能够接受带GTID的事务

4、在拓扑结构中所有服务器运行以下命令

    
    
    SET @@GLOBAL.GTID_MODE = ON_PERMISSIVE;
    

该命令的效果:服务器产生GTID，但是能够接受不带GTID的事务，也能够接受带GTID的事务

5、第四步之后，服务器将不产生匿名的GTID,通过以下命令查看是否还存在匿名的GTID，一定要确保该操作的结果为0（多次验证），才可以进行下一步。

    
    
    SHOW STATUS LIKE 'ONGOING_ANONYMOUS_TRANSACTION_COUNT';
    
    

[](http://fordba.com/wp-content/uploads/2017/04/gtid2.png)

6、确保第五步操作之前的所有binlog都已经被其他服务器应用了，因为匿名的GTID必须确保已经复制应用成功，才可以进行下一步操作。

7、如果你需要用binlog来实现一个闪回操作，需要确保你已经不需要那些不包含GTID的binlog了，否则需要等那些binlog过期，才可以进行下一步操作

8、在所有的服务器上执行：

    
    
    SET @@GLOBAL.GTID_MODE = ON;
    

该命令的效果:服务器产生GTID，且只能接受带GTID的事务。

> **_这里有个很关键的地方：如果master的gtid_mode 为on，那么他的所有slave都只能接受带GTID的事务，所以必须等待所有的slave
都已经接受且应用了不带gtid的事务，才可以将master的gtid_mode 设置为on_**

[](http://fordba.com/wp-content/uploads/2017/04/gtid3.png)

我们看到GTID 已经正常打开了  
[](http://fordba.com/wp-content/uploads/2017/04/gtid_var.png)

9、添加以下内容到my.cnf 中

    
    
    #GTID#
    enforce_gtid_consistency       = on
    gtid_mode                      = on
    

10、开启slave的`auto position`，如果你使用的是多源复制，需要针对每个`channel`启用`auto position`

    
    
    STOP SLAVE [FOR CHANNEL 'channel'];
    CHANGE MASTER TO MASTER_AUTO_POSITION = 1 [FOR CHANNEL 'channel'];
    START SLAVE [FOR CHANNEL 'channel'];
    

* * *

## 三、在线关闭GTID

在线关闭和在线开启是类似的，只是步奏相反  
1、关闭slave的`auto position`，如果你使用的是多源复制，需要针对每个`channel`关闭`auto position`

    
    
    STOP SLAVE [FOR CHANNEL 'channel'];
    CHANGE MASTER TO MASTER_AUTO_POSITION = 0, MASTER_LOG_FILE = file, \
    MASTER_LOG_POS = position [FOR CHANNEL 'channel'];
    START SLAVE [FOR CHANNEL 'channel'];
    

2、在所有的服务器上执行：

    
    
    SET @@GLOBAL.GTID_MODE = ON_PERMISSIVE;
    
    

3、在所有的服务器上执行：

    
    
    SET @@GLOBAL.GTID_MODE = OFF_PERMISSIVE;
    
    

4、在所有的服务器上等待 @@GLOBAL.GTID_OWNED 的值是一个空字符串为止。

    
    
    SELECT @@GLOBAL.GTID_OWNED;
    
    

5、等待第三步操作时候，master上的binlog中的日志都已经被slave应用完毕。

6、如果你需要用binlog来实现一个闪回操作，需要确保你已经不需要那些包含GTID的binlog了，否则需要等那些binlog过期，才可以进行下一步操作

7、在所有的服务器上执行：

    
    
    SET @@GLOBAL.GTID_MODE = OFF;
    
    

8、在所有的服务器上执行：

    
    
    SET @@GLOBAL.GTID_MODE = OFF;
    SET @@GLOBAL.ENFORCE_GTID_CONSISTENCY = OFF;
    

9、删除以下配置

    
    
    #GTID#
    enforce_gtid_consistency       = on
    gtid_mode                      = on
    
    

## 四、参考文章

[【MySQL】5.7新特性之七 ](http://blog.itpub.net/22664653/viewspace-2133818/)  
<https://dev.mysql.com/doc/refman/5.7/en/replication-mode-change-online-
enable-gtids.html>  
<https://dev.mysql.com/doc/refman/5.7/en/replication-mode-change-online-
disable-gtids.html>

## 文章导航

[MySQL中隐式转换导致的查询结果错误案例分析](http://www.fordba.com/mysql-type-convert-
analysis.html)

[MySQL中一个双引号的错位引发的血案](http://www.fordba.com/mysql-double-quotation-marks-
accident.html)

### Write a Reply or Comment

电子邮件地址不会被公开。 必填项已用*标注

评论

姓名 *

电子邮件 *

站点

* * *

  


---
### ATTACHMENTS
[cb703949b3cc0b20cbceb6b96d090baf]: media/gtid3.png
[gtid3.png](media/gtid3.png)
>hash: cb703949b3cc0b20cbceb6b96d090baf  
>source-url: http://fordba.com/wp-content/uploads/2017/04/gtid3.png  
>file-name: gtid3.png  

[d61605cb0f49fe24a99698c1aa85eddf]: media/gtid2.png
[gtid2.png](media/gtid2.png)
>hash: d61605cb0f49fe24a99698c1aa85eddf  
>source-url: http://fordba.com/wp-content/uploads/2017/04/gtid2.png  
>file-name: gtid2.png  

[f91a001a38f8922cb702ef87d145afcf]: media/gtid_var.png
[gtid_var.png](media/gtid_var.png)
>hash: f91a001a38f8922cb702ef87d145afcf  
>source-url: http://fordba.com/wp-content/uploads/2017/04/gtid_var.png  
>file-name: gtid_var.png  


---
### TAGS
{gtid}

---
### NOTE ATTRIBUTES
>Created Date: 2018-03-12 01:51:02  
>Last Evernote Update Date: 2018-10-01 15:35:37  
>author: YangKwong  
>source: web.clip  
>source-url: http://www.fordba.com/mysql57replication-mode-change-online-enable-and-disable-gtids-html.html  