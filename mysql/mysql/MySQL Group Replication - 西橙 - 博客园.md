# MySQL Group Replication - 西橙 - 博客园

  

|

# [MySQL Group Replication](http://www.cnblogs.com/Bccd/p/6808391.html)

在>=mysql5.7.17的版本中开始支持组复制插件。组复制中的成员至少需要三个才会起到容错作用，各成员在通信层通过原子广播及总订单消息的

传递一起应用或回滚事务组从而达到数据的强一致性。组复制的成员是独立处理事务的，rw事务需要通过组的冲突检查才可以进行，ro事务则不需要

组之间的通信而直接提交。当一个成员要提交rw事务时，会原子广播写入的行数据和相关的写入集（变更行的唯一身份认证标志），所有的成员会接

收到一组顺序相同的事务集并顺序应用。如果不同的两组事务同时并发在两个成员上修改相同的行记录，那么这就是冲突（通过事务集的唯一标识值来

检测冲突），这种情况下，遵循第一提交完胜的准则。

## 组复制协议

## 组复制实践

单主机部署三个实例，端口分别为

s1：6666

s2：6667

s3：6668

与组复制相关的参数配置

|

1

2

3

4

5

6

7

8

9

10

11

12

13

14

15

16

|

`server_id=1`

`gtid_mode=ON`

`enforce_gtid_consistency=ON`

`master_info_repository=TABLE`

`relay_log_info_repository=TABLE`

`binlog_checksum=NONE`

`log_slave_updates=ON`

`log_bin=binlog`

`binlog_format=ROW`

`transaction_write_set_extraction=XXHASH64`

`loose-group_replication_group_name=``"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"`

`loose-group_replication_start_on_boot=off`

`loose-group_replication_local_address= ``"127.0.0.1:10001"`

`loose-group_replication_group_seeds=
``"127.0.0.1:10001,127.0.0.1:10002,127.0.0.1:10003"`

`loose-group_replication_bootstrap_group= off`  
  
---|---  
  
10001、10002、10003是每个实例的recovery process分别侦听的端口

如果开启并行复制 还需 slave_preserve_commit_order 设置为1

## 先部署s1

1、创建用于复制事务日志的用户

组复制基于binlog采用异步复制的协议，recovery process通过group_replication_recovery
通道在成员间传输事务日志，

复制用户要有` REPLICATION SLAVE 权限`

注意创建用户的日志不可以到达其他的成员实例上

    
    
    set sql_log_bin=0;GRANT REPLICATION SLAVE ON *.* TO grepl@'%' IDENTIFIED BY 'grepl';       flush privileges;set sql_log_bin=1;
    

配置恢复通道用于从其他成员复制恢复

    
    
    mysql>  CHANGE MASTER TO MASTER_USER='grepl', MASTER_PASSWORD='grepl' FOR CHANNEL 'group_replication_recovery';                
    Query OK, 0 rows affected, 2 warnings (0.02 sec)

安装组复制插件

    
    
    mysql> INSTALL PLUGIN group_replication SONAME 'group_replication.so';
    Query OK, 0 rows affected (0.10 sec)  
    # check  
    mysql> show plugins;

开启组复制

通过s1引导组（bootstrap group）并开启组复制，bootstrap group只可以进行一次并由一个成员进行，不把
group_replication_bootstrap_group=ON

放到配置文件中的原因是避免实例重启重新进行bootstrap group，若果重复执行，则会产生两个拥有相同成员的组。

    
    
    SET GLOBAL group_replication_bootstrap_group=ON;
    START GROUP_REPLICATION;
    SET GLOBAL group_replication_bootstrap_group=OFF;  
    mysql>  SELECT * FROM performance_schema.replication_group_members;  
    +---------------------------+--------------------------------------+----------------+-------------+--------------+  
    | CHANNEL_NAME              | MEMBER_ID                            | MEMBER_HOST    | MEMBER_PORT | MEMBER_STATE |  
    +---------------------------+--------------------------------------+----------------+-------------+--------------+  
    | group_replication_applier | b110f16d-3163-11e7-b64a-fa163eef641d | 10.211.253.192 |        6666 | ONLINE       |  
    +---------------------------+--------------------------------------+----------------+-------------+--------------+  
    1 row in set (0.00 sec)

MEMBER_HOST字段显示的是report_host 的值

创建测试数据

    
    
    use test
    CREATE TABLE t1 (c1 INT PRIMARY KEY, c2 TEXT NOT NULL);
    INSERT INTO t1 VALUES (1, 'Luis');  
    SELECT * FROM t1;  
    mysql> SHOW BINLOG EVENTS in 'mysql-bin.000002';  
    +------------------+-----+----------------+------------+-------------+--------------------------------------------------------------------+  
    | Log_name         | Pos | Event_type     | Server_id  | End_log_pos | Info                                                               |  
    +------------------+-----+----------------+------------+-------------+--------------------------------------------------------------------+  
    | mysql-bin.000002 |   4 | Format_desc    | 4294967295 |         123 | Server ver: 5.7.18-log, Binlog ver: 4                              |  
    | mysql-bin.000002 | 123 | Previous_gtids | 4294967295 |         150 |                                                                    |  
    | mysql-bin.000002 | 150 | Gtid           | 4294967295 |         211 | SET @@SESSION.GTID_NEXT= 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa:1'  |  
    | mysql-bin.000002 | 211 | Query          | 4294967295 |         270 | BEGIN                                                              |  
    | mysql-bin.000002 | 270 | View_change    | 4294967295 |         369 | view_id=14939720086383376:1                                        |  
    | mysql-bin.000002 | 369 | Query          | 4294967295 |         434 | COMMIT                                                             |  
    | mysql-bin.000002 | 434 | Gtid           | 4294967295 |         495 | SET @@SESSION.GTID_NEXT= 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa:2'  |  
    | mysql-bin.000002 | 495 | Query          | 4294967295 |         585 | CREATE DATABASE test                                               |  
    | mysql-bin.000002 | 585 | Gtid           | 4294967295 |         646 | SET @@SESSION.GTID_NEXT= 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa:3'  |  
    | mysql-bin.000002 | 646 | Query          | 4294967295 |         770 | use `test`; CREATE TABLE t1 (c1 INT PRIMARY KEY, c2 TEXT NOT NULL) |  
    | mysql-bin.000002 | 770 | Gtid           | 4294967295 |         831 | SET @@SESSION.GTID_NEXT= 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa:4'  |  
    | mysql-bin.000002 | 831 | Query          | 4294967295 |         899 | BEGIN                                                              |  
    | mysql-bin.000002 | 899 | Table_map      | 4294967295 |         942 | table_id: 219 (test.t1)                                            |  
    | mysql-bin.000002 | 942 | Write_rows     | 4294967295 |         984 | table_id: 219 flags: STMT_END_F                                    |  
    | mysql-bin.000002 | 984 | Xid            | 4294967295 |        1011 | COMMIT /* xid=73 */                                                |  
    +------------------+-----+----------------+------------+-------------+--------------------------------------------------------------------+  
    15 rows in set (0.01 sec)

添加组成员

重复上上面的操作，除了设置group_replication_bootstrap_group，注意个别配置项的更改

    
    
    mysql> select * FROM performance_schema.replication_group_members;
    +---------------------------+--------------------------------------+----------------+-------------+--------------+
    | CHANNEL_NAME              | MEMBER_ID                            | MEMBER_HOST    | MEMBER_PORT | MEMBER_STATE |
    +---------------------------+--------------------------------------+----------------+-------------+--------------+
    | group_replication_applier | b110f16d-3163-11e7-b64a-fa163eef641d | 10.211.253.192 |        6666 | ONLINE       |
    | group_replication_applier | b9e9924f-3163-11e7-b226-fa163eef641d | 10.211.253.192 |        6667 | ONLINE       |
    | group_replication_applier | c1ae8a71-3163-11e7-ad97-fa163eef641d | 10.211.253.192 |        6668 | ONLINE       |
    +---------------------------+--------------------------------------+----------------+-------------+--------------+
    3 rows in set (0.00 sec)

其他的成员加入组aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa后在被宣布online前自动复制s1的差异日志并应用

### 组复制模式

https://dev.mysql.com/doc/refman/5.7/en/group-replication-deploying-in-multi-
primary-or-single-primary-mode.html

分类: [MySQL 高可用](http://www.cnblogs.com/Bccd/category/996010.html)

好文要顶 关注我 收藏该文

[](http://home.cnblogs.com/u/Bccd/)

[西橙](http://home.cnblogs.com/u/Bccd/)  
[关注 - 0](http://home.cnblogs.com/u/Bccd/followees)  
[粉丝 - 0](http://home.cnblogs.com/u/Bccd/followers)

+加关注

0

0

[« ](http://www.cnblogs.com/Bccd/p/6740149.html)
上一篇：[MySQL容量规划之tcpcopy应用之道](http://www.cnblogs.com/Bccd/p/6740149.html
"发布于2017-04-20 18:14")  
[» ](http://www.cnblogs.com/Bccd/p/6868904.html) 下一篇：[MySQL5.7 服务 crash
后无法启动](http://www.cnblogs.com/Bccd/p/6868904.html "发布于2017-05-17 18:26")  

发表于 2017-05-05 17:16 [西橙](http://www.cnblogs.com/Bccd/) 阅读(79) 评论(0)
[编辑](https://i.cnblogs.com/EditPosts.aspx?postid=6808391)
[收藏](http://www.cnblogs.com/Bccd/p/6808391.html#)  
  
  


---
### ATTACHMENTS
[24de3321437f4bfd69e684e353f2b765]: media/wechat-4.png
[wechat-4.png](media/wechat-4.png)
>hash: 24de3321437f4bfd69e684e353f2b765  
>source-url: http://common.cnblogs.com/images/wechat.png  
>file-name: wechat.png  

[373280fde0d7ed152a0f7f06df3f3ad4]: media/sample_face-2.gif
[sample_face-2.gif](media/sample_face-2.gif)
>hash: 373280fde0d7ed152a0f7f06df3f3ad4  
>source-url: http://pic.cnblogs.com/face/sample_face.gif  
>file-name: sample_face.gif  

[51e409b11aa51c150090697429a953ed]: media/copycode-6.gif
[copycode-6.gif](media/copycode-6.gif)
>hash: 51e409b11aa51c150090697429a953ed  
>source-url: http://common.cnblogs.com/images/copycode.gif  
>file-name: copycode.gif  

[7c38b9617fdc6238650dc4e42b6418ca]: media/1012095-20170505134335132-2093990795.png
[1012095-20170505134335132-2093990795.png](media/1012095-20170505134335132-2093990795.png)
>hash: 7c38b9617fdc6238650dc4e42b6418ca  
>source-url: http://images2015.cnblogs.com/blog/1012095/201705/1012095-20170505134335132-2093990795.png  
>file-name: 1012095-20170505134335132-2093990795.png  

[c5fd93bfefed3def29aa5f58f5173174]: media/icon_weibo_24-4.png
[icon_weibo_24-4.png](media/icon_weibo_24-4.png)
>hash: c5fd93bfefed3def29aa5f58f5173174  
>source-url: http://common.cnblogs.com/images/icon_weibo_24.png  
>file-name: icon_weibo_24.png  


---
### TAGS
{group replication}

---
### NOTE ATTRIBUTES
>Created Date: 2017-09-13 07:48:01  
>Last Evernote Update Date: 2018-10-01 15:35:39  
>author: YangKwong  
>source: web.clip  
>source-url: http://www.cnblogs.com/Bccd/p/6808391.html  