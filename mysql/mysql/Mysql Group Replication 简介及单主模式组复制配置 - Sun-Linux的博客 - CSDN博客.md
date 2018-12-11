# Mysql Group Replication 简介及单主模式组复制配置 - Sun-Linux的博客 - CSDN博客

  

#  [ Mysql Group Replication 简介及单主模式组复制配置
](http://blog.csdn.net/hzsunshine/article/details/69132225)

.

标签：
[mysql](http://www.csdn.net/tag/mysql)[高可用](http://www.csdn.net/tag/%e9%ab%98%e5%8f%af%e7%94%a8)

2017-04-04 18:53 1597人阅读
[评论](http://blog.csdn.net/hzsunshine/article/details/69132225#comments)(0) 收藏
[举报](http://blog.csdn.net/hzsunshine/article/details/69132225#report "举报")

.

分类：

数据库 _（4）_ 负载均衡与高可用 _（11）_

.

一 Mysql Group Replication简介  

Mysql Group Replication(MGR)是一个全新的高可用和高扩张的MySQL集群服务。  

高一致性，基于原生复制及paxos协议的组复制技术，以插件方式提供一致数据安全保证；  

高容错性，大多数服务正常就可继续工作，自动不同节点检测资源征用冲突，按顺序优先处理，内置自动防脑裂机制；  

高扩展性，自动添加移除节点，并更新组信息；  

高灵活性，单主模式和多主模式。单主模式自动选主，所有更新操作在主进行；多主模式，所有server同时更新。  

二 Mysql Group Replication与传统复制的区别和大幅改进

1.传统复制  

主-从复制：有一个主和不等数量的从。主节点执行的事务会异步发送给从节点，在从节点重新执行。（异步和半同步）

（半同步相对异步Master会确认Slave是否接到数据，更加安全）  

  

  

（原理见主从复制笔记）  

2.并行复制  

  

并行复制：复制->广播->正式复制

优势：  

弹性复制（高扩展性）：server动态添加移除  

高可用分片（高扩展性）：分片实现写扩展，每个分片是一个复制组。  

替代主从复制（高扩展性）：整组写入，避免单点争用。  

自动化系统：自动化部署Mysql复制到已有复制协议的自动化系统。  

故障检测与容错：自动检测，若服务faild,组内成员大多数达成认为该服务已不正常，则自动隔离。

组内成员会构成一个视图，组内成员主动加入或离开（主动或被动），都会更新组配置，更新视图。成员自愿离开，先更新组配置，然后采用大多数成员（不包含主动脱离的成员）意见是否确认该成员离开更新视图。如果是故障要排除，则需大多数服务确认（包括故障成员意见），然后才会更新组配置和视图。

最大允许即时故障数：f=(n-1)/2,多数正常则正常  

三 主从复制限制

1.存储引擎必须为innodb

2.每个表必须提供主键

> 3.只支持ipv4，网络需求较高

4.一个group最多只能有9台服务器

5.不支持Replication event checksums，

6.不支持Savepoints

7.multi-primary mode部署方式不支持SERIALIZABLE事务隔离级别

8.multi-primary mode部署方式不能完全支持级联外键约束

9.multi-primary mode部署方式不支持在不同节点上对同一个[数据库](http://lib.csdn.net/base/mysql
"MySQL知识库")对象并发执行DDL(在不同节点上对同一行并发进行RW事务，后发起的事务会失败)  
四 单主模式布置组复制

（组中server可在独立物理机运行，也可在同一台机器，同一机器采用多实例，也就是逻辑认为是独立机器）  

  

**1.安装mysql5.7包**

1.卸载系统已有数据库  

    
          1.  #检测系统是否已安装mariadb,如有则卸载
      2. rpm -qa | grep mariadb
      3. rpm -e mariadb-libs --nodeps
    
    

2.编译安装mysql5.7

    
          1. #添加mysql用户组并添加mysql用户(不允许登录)
    
      2. groupadd mysql
      3. useradd -r -g mysql -s /bin/false -M mysql
      4. #下载mysql源码包
      5. wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.17.tar.gz
      6. #安装编译工具和依赖包
      7. yum install -y cmake make gcc gcc-c++
      8. yum install -y ncurses-devel openssl-devel bison-devel libaio libaio-devel
      9. 
    
      10. # boost库安装
      11. # 该步骤可以省略，在cmake阶段添加参数-DDOWNLOAD_BOOST=1 -DWITH_BOOST=/usr/local/boost即可
      12. wget http://sourceforge.net/projects/boost/files/boost/1.59.0/boost_1_59_0.tar.gz
      13. tar -zxvf boost_1_59_0.tar.gz -C /usr/local
      14. mv /usr/local/boost_1_59_0 /usr/local/boost
      15. cd /usr/local/boost
      16. ./bootstrap.sh
      17. ./b2 stage threading=multi link=shared
      18. ./b2 install threading=multi link=shared
      19. 
    
      20. #安装编译mysql
      21. cd
      22. tar -zxvf mysql-5.7.17.tar.gz
      23. cd mysql-5.7.17
      24. #使用cmake工具设置参数，新版的php都从configure改用cmake
      25. 
    
      26. cmake \
      27. -DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
      28. -DMYSQL_DATADTR=/usr/local/mysql/data \
      29. -DSYSCONFDIR=/etc \
      30. -DMYSQL_USER=mysql \
      31. -DWITH_MYISAM_STORAGE_ENGINE=1 \
      32. -DWITH_INNOBASE_STORAGE_ENGINE=1 \
      33. -DWITH_ARCHIVE_STORAGE_ENGINE=1 \
      34. -DWITH_MEMORY_STORAGE_ENGINE=1 \
      35. -DWITH_READLINE=1 \
      36. -DMYSQL_UNIX_ADDR=/usr/local/mysql/mysql.sock \
      37. -DMYSQL_TCP_PORT=3306 \
      38. -DENABLED_LOCAL_INFILE=1 \
      39. -DENABLE_DOWNLOADS=1 \
      40. -DWITH_PARTRTION_STORAGE_ENGINE=1 \
      41. -DEXTRA_CHARSETS=all \
      42. -DDEFAULT_CHARSET=utf8 \
      43. -DDEFAULT_COLLATION=utf8_general_ci \
      44. -DWITH_DEBUG=0 \
      45. -DMYSQL_MAINTAINER_MODE=0 \
      46. -DMITH_SSL:STRING=bundled \
      47. -DWITH_ZLIB:STRING=bundled \
      48. -DDOWNLOAD_BOOST=1 \
      49. -DWITH_BOOST=/usr/local/boost
      50. 
    
      51. make && make install
      52. #默认1个线程编译，可使用指定线程数加快编译
      53. #make -j $(grep processor /proc/cpuinfo | wc -l) && make install
      54. 
    
      55. #将mysql目录权限给mysql用户
      56. chown -Rf mysql:mysql /usr/local/mysql
      57. 
    
      58. #设置mysql的默认配置文件
      59. cp /usr/local/mysql/support-files/my-default.cnf /etc/my.cnf
      60. #把mysql命令加入查找路径
      61. echo "export PATH=$PATH:/usr/local/mysql/bin" >>/etc/profile
      62. source /etc/profile
    
    

防火墙和selinux设置

    
          1. firewall-cmd --permanent --add-port=3307/tcp
      2. firewall-cmd --permanent --add-port=3308/tcp
    
      3. firewall-cmd --permanent --add-port=3309/tcp
    
      4. firewall-cmd --permanent --add-port=3407/tcp
    
      5. firewall-cmd --permanent --add-port=3408/tcp
    
      6. firewall-cmd --permanent --add-port=3409/tcp
    
      7. firewall-cmd --reload
    
      8. 
    
      9. setenforce 0
    
      10. sed -i 's#enforcing#permissive#g' /etc/selinux/config
    
    
    

3.部署组复制实例  

    
          1. mkdir /data
      2. #初始化数据库，创建数据库
      3. mysqld --initialize-insecure --user=mysql --basedir=/usr/local/mysql --datadir=/data/s1
      4. mysqld --initialize-insecure --user=mysql --basedir=/usr/local/mysql --datadir=/data/s2
      5. mysqld --initialize-insecure --user=mysql --basedir=/usr/local/mysql --datadir=/data/s3
    
    

4.配置组复制实例S1  

    
          1. cat > /data/s1/my.cnf <<EOF
      2. 
    
      3. [mysqld]
    
      4. # server configuration
      5. user=mysql
      6. datadir=/data/s1
      7. basedir=/usr/local/mysql/
      8. port=3307
      9. socket=/usr/local/mysql/s1.sock
      10. 
    
      11. #复制框架
      12. server_id=1
      13. gtid_mode=ON
      14. enforce_gtid_consistency=ON
      15. master_info_repository=TABLE
      16. relay_log_info_repository=TABLE
      17. binlog_checksum=NONE
      18. log_slave_updates=ON
      19. log_bin=binlog
      20. binlog_format=ROW
      21. 
    
      22. #组复制设置
      23. #server必须为每个事务收集写集合，并使用XXHASH64哈希算法将其编码为散列
      24. transaction_write_set_extraction=XXHASH64
      25. #告知插件加入或创建组命名，UUID 
      26. loose-group_replication_group_name="aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
      27. #server启动时不自启组复制
      28. loose-group_replication_start_on_boot=off
      29. #告诉插件使用IP地址，端口3407用于接收组中其他成员转入连接
      30. loose-group_replication_local_address="127.0.0.1:3407"
      31. #启动组server，种子server，加入组应该连接这些的ip和端口；其他server要加入组得由组成员同意
      32. loose-group_replication_group_seeds="127.0.0.1:3407,127.0.0.1:3408,127.0.0.1:3409"
      33. loose-group_replication_bootstrap_group=off
      34. loose-group_replication_single_primary_mode=FALSE
    
      35. loose-group_replication_enforce_update_everywhere_checks= TRUE
    
      36. 
    
      37. EOF
    
    

5.用户凭据  

    
          1. #启动mysql实例1服务
      2. nohup mysqld --defaults-file=/data/s1/my.cnf >/data/s1/nohup.out 2>/data/s1/nohup.out &
      3. #登录mysql s1
      4. mysql -uroot -h127.0.0.1 -P3307 --skip-password
    
      5. #修改root密码
      6. alter user 'root'@'localhost' identified by '123456';
      7. #下面操纵不写入二进制日志，避免修改传递给其他实例，先关闭
      8. set sql_log_bin=0;
    
      9. #创建拥有replication slave权限mysql用户
      10. create user rpl_user@'%';
    
      11. grant replication slave on *.* to rpl_user@'%'  identified by 'rpl_pass';
    
      12. flush privileges;
    
      13. #开启二进制写入
      14. set sql_log_bin=1;
      15. #分布式恢复加入组的server执行第一步
      16. #change master to语言将server配置为，在下次需要从其他成员恢复状态时，使用group_replication_recovery复制通道的给定凭证。
      17. change master to master_user='rpl_user',master_password='rpl_pass' for channel 'group_replication_recovery';
    
      18. #建议每个mysql通过配置唯一主机名，通过DNS或本地设置。（相同可能导致无法恢复）
    
    

6.启动组复制  

    
          1. #安装组复制插件
      2. install plugin group_replication soname 'group_replication.so';
    
      3. #检测插件是否安装成功
      4. show plugins;
    
      5. +----------------------------+----------+--------------------+----------------------+---------+
    | Name                       | Status   | Type               | Library              | License |
    +----------------------------+----------+--------------------+----------------------+---------+
    ......
    | group_replication          | ACTIVE   | GROUP REPLICATION  | group_replication.so | GPL     |
    +----------------------------+----------+--------------------+----------------------+---------+
      6. #server s1引导组，启动组复制程序（复制组只启动一次就行）
      7. set global group_replication_bootstrap_group=ON;
      8. start group_replication;
      9. set global group_replication_bootstrap_group=OFF;
      10. #检测组是否创建并已加入新成员
      11. select * from performance_schema.replication_group_members;
      12. +---------------------------+--------------------------------------+-------------+-------------+--------------+
    | CHANNEL_NAME              | MEMBER_ID                            | MEMBER_HOST | MEMBER_PORT | MEMBER_STATE |
    +---------------------------+--------------------------------------+-------------+-------------+--------------+
    | group_replication_applier | 70bf7af3-1657-11e7-82a8-000c29433013 | test1       |        3307 | ONLINE       |
    +---------------------------+--------------------------------------+-------------+-------------+--------------+
    
      13. 
    
    
    

7.测试

    
          1. mysql> create database test;
      2. 2017-03-31T23:23:45.535115Z 8 [Note] Plugin group_replication reported: 'Primary had applied all relay logs, disabled conflict detection'
      3. Query OK, 1 row affected (0.03 sec)
      4.   5. mysql> use test;
      6. Database changed
      7. 
    
      8. mysql> create table t1(c1 int primary key,c2 text not null);
      9. Query OK, 0 rows affected (0.03 sec)
      10.   11. mysql> insert into t1 values (1 , 'Luis');
      12. Query OK, 1 row affected (0.01 sec)
      13.   14. mysql> select * from t1;
      15. +----+------+
      16. | c1 | c2   |
      17. +----+------+
      18. |  1 | Luis |
      19. +----+------+
      20. 1 row in set (0.00 sec)
      21.   22. mysql> show binlog events;
      23. +---------------+------+----------------+-----------+-------------+----------------------------------------------------------------------------------------------------------------------+
      24. | Log_name      | Pos  | Event_type     | Server_id | End_log_pos | Info                                                                                                                 |
    +---------------+------+----------------+-----------+-------------+----------------------------------------------------------------------------------------------------------------------+
    | binlog.000001 |    4 | Format_desc    |         1 |         123 | Server ver: 5.7.17-log, Binlog ver: 4                                                                                |
    | binlog.000001 |  123 | Previous_gtids |         1 |         150 |                                                                                                                      |
    | binlog.000001 |  150 | Gtid           |         1 |         211 | SET @@SESSION.GTID_NEXT= '21355e09-16ea-11e7-bb6b-000c29433013:1'                                                    |
    | binlog.000001 |  211 | Query          |         1 |         386 | ALTER USER 'root'@'localhost' IDENTIFIED WITH 'mysql_native_password' AS '*6BB4837EB74329105EE4568DDA7DC67ED2CA2AD9' |
    | binlog.000001 |  386 | Gtid           |         1 |         447 | SET @@SESSION.GTID_NEXT= 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa:1'                                                    |
    | binlog.000001 |  447 | Query          |         1 |         506 | BEGIN                                                                                                                |
    | binlog.000001 |  506 | View_change    |         1 |         645 | view_id=14910585094598745:1                                                                                          |
    | binlog.000001 |  645 | Query          |         1 |         710 | COMMIT                                                                                                               |
    | binlog.000001 |  710 | Gtid           |         1 |         771 | SET @@SESSION.GTID_NEXT= 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa:2'                                                    |
    | binlog.000001 |  771 | Query          |         1 |         861 | create database test                                                                                                 |
    | binlog.000001 |  861 | Gtid           |         1 |         922 | SET @@SESSION.GTID_NEXT= 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa:3'                                                    |
    | binlog.000001 |  922 | Query          |         1 |        1044 | use `test`; create table t1(c1 int primary key,c2 text not null)                                                     |
    | binlog.000001 | 1044 | Gtid           |         1 |        1105 | SET @@SESSION.GTID_NEXT= 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa:4'                                                    |
    | binlog.000001 | 1105 | Query          |         1 |        1173 | BEGIN                                                                                                                |
    | binlog.000001 | 1173 | Table_map      |         1 |        1216 | table_id: 220 (test.t1)                                                                                              |
    | binlog.000001 | 1216 | Write_rows     |         1 |        1258 | table_id: 220 flags: STMT_END_F                                                                                      |
    | binlog.000001 | 1258 | Xid            |         1 |        1285 | COMMIT /* xid=40 */                                                                                                  |
    +---------------+------+----------------+-----------+-------------+----------------------------------------------------------------------------------------------------------------------+
    17 rows in set (0.00 sec)
    
    
    

8.第二个实例添加(S2)

    
          1. cat > /data/s2/my.cnf <<EOF
      2. 
    
      3. [mysqld]
      4. # server configuration
      5. user=mysql
      6. datadir=/data/s2
      7. basedir=/usr/local/mysql/
      8. port=3308
      9. socket=/usr/local/mysql/s2.sock
      10. 
    
      11. #复制框架
      12. server_id=2
      13. gtid_mode=ON
      14. enforce_gtid_consistency=ON
      15. master_info_repository=TABLE
      16. relay_log_info_repository=TABLE
      17. binlog_checksum=NONE
      18. log_slave_updates=ON
      19. log_bin=binlog
      20. binlog_format=ROW
      21. 
    
      22. #组复制设置
      23. #server必须为每个事务收集写集合，并使用XXHASH64哈希算法将其编码为散列
      24. transaction_write_set_extraction=XXHASH64
      25. #告知插件加入或创建组命名，UUID 
      26. loose-group_replication_group_name="aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
      27. #server启动时不自启组复制
      28. loose-group_replication_start_on_boot=off
      29. #告诉插件使用IP地址，端口3408用于接收组中其他成员转入连接
      30. loose-group_replication_local_address="127.0.0.1:3408"
      31. #启动组server，种子server，加入组应该连接这些的ip和端口；其他server要加入组得由组成员同意
      32. loose-group_replication_group_seeds="127.0.0.1:3407,127.0.0.1:3408,127.0.0.1:3409"
      33. loose-group_replication_bootstrap_group=off
      34. loose-group_replication_single_primary_mode=FALSE
    
      35. loose-group_replication_enforce_update_everywhere_checks= TRUE
      36. 
    
      37. EOF
    
    

9.用户凭证（S2）

    
          1. #启动mysql实例2服务
      2. nohup mysqld --defaults-file=/data/s2/my.cnf >/data/s2/nohup.out 2>/data/s2/nohup.out &
      3. #登录mysql s1
      4. mysql -uroot -h127.0.0.1 -P3308 --skip-password
      5. #修改root密码
      6. alter user 'root'@'localhost' identified by '123456';
      7. #下面操纵不写入二进制日志，避免修改传递给其他实例，先关闭
      8. set sql_log_bin=0;
    
      9. #创建拥有replication slave权限mysql用户
      10. create user rpl_user@'%';
    
      11. grant replication slave on *.* to rpl_user@'%' identified by 'rpl_pass';
    
      12. flush privileges;
    
      13. #开启二进制写入
      14. set sql_log_bin=1;
      15. #分布式恢复加入组的server执行第一步
      16. #change master to语言将server配置为，在下次需要从其他成员恢复状态时，使用group_replication_recovery复制通道的给定凭证。
      17. change master to master_user='rpl_user',master_password='rpl_pass' for channel 'group_replication_recovery';
    
      18. #建议每个mysql通过配置唯一主机名，通过DNS或本地设置。（相同可能导致无法恢复）
    
    

10.添加组

    
          1. #安装组复制插件
      2. install plugin group_replication soname 'group_replication.so';
    
      3. #检测插件是否安装成功
      4. show plugins;
    
      5. +----------------------------+----------+--------------------+----------------------+---------+
    | Name                       | Status   | Type               | Library              | License |
    +----------------------------+----------+--------------------+----------------------+---------+
    ......
    | group_replication          | ACTIVE   | GROUP REPLICATION  | group_replication.so | GPL     |
    +----------------------------+----------+--------------------+----------------------+---------+
      6. #添加到复制组（不用再设置启动，该组已在是s1时启动）
      7. set global group_replication_allow_local_disjoint_gtids_join=ON;
    
      8. start group_replication;
    
      9. #检测组是否创建并已加入新成员
      10. select * from performance_schema.replication_group_members;
      11. +---------------------------+--------------------------------------+-------------+-------------+--------------+
    | CHANNEL_NAME              | MEMBER_ID                            | MEMBER_HOST | MEMBER_PORT | MEMBER_STATE |
    +---------------------------+--------------------------------------+-------------+-------------+--------------+
    | group_replication_applier | 21355e09-16ea-11e7-bb6b-000c29433013 | test1       |        3307 | ONLINE       |
    | group_replication_applier | 25b39bc8-16ea-11e7-bc1e-000c29433013 | test1       |        3308 | ONLINE       |
    +---------------------------+--------------------------------------+-------------+-------------+--------------+
    
    
    

11.测试同步是否正常

    
          1. mysql> show databases like 'test';
      2. +-----------------+
      3. | Database (test) |
      4. +-----------------+
      5. | test            |
      6. +-----------------+
    
    

  

问题：

#在建立第二个mysql实例s2时，会有以下现象，s2一直处于RECOVERING状态。

    
          1. +---------------------------+--------------------------------------+-------------+-------------+--------------+
      2. | CHANNEL_NAME              | MEMBER_ID                            | MEMBER_HOST | MEMBER_PORT | MEMBER_STATE |
      3. +---------------------------+--------------------------------------+-------------+-------------+--------------+
      4. | group_replication_applier | 21355e09-16ea-11e7-bb6b-000c29433013 | test1       |        3307 | ONLINE       |
      5. | group_replication_applier | 25b39bc8-16ea-11e7-bc1e-000c29433013 | test1       |        3308 | RECOVERING   |
      6. +---------------------------+--------------------------------------+-------------+-------------+--------------+
    
    

错误日志如下：  

    
          1. [ERROR] Slave I/O for channel 'group_replication_recovery': error connecting to master 'rpl_user@test1:3307' - retry-time: 60  retries: 1, Error_code: 2003
      2. [ERROR] Plugin group_replication reported: 'There was an error when connecting to the donor server. Check group replication recovery's connection credentials.'
    
    

原因：mysql组复制用的是域名连接，我的主机设置名字为test1,但没有在hosts文件中声明其IP为127.0.0.1。（DNS就更没有了）导致s2无法正常访问s1。因而报错。

解决方法：修改/etc/hosts文件，追加127.0.0.1 对应主机名为test1。然后重新启动组复制就可以。

参考博客
[http://wangwei007.blog.51cto.com/680.19/1907145](http://wangwei007.blog.51cto.com/68019/1907145)

《Mysql Group Repaliation》京东翻译

参考博客 http://www.voidcn.com/blog/d6619309/article/p-6346153.html

[](http://blog.csdn.net/hzsunshine/article/details/69132225#)
[](http://blog.csdn.net/hzsunshine/article/details/69132225# "分享到QQ空间")
[](http://blog.csdn.net/hzsunshine/article/details/69132225# "分享到新浪微博")
[](http://blog.csdn.net/hzsunshine/article/details/69132225# "分享到腾讯微博")
[](http://blog.csdn.net/hzsunshine/article/details/69132225# "分享到人人网")
[](http://blog.csdn.net/hzsunshine/article/details/69132225# "分享到微信") .

顶

    0

踩

    0
.

  * 上一篇[MMM mysql高可用配置详细配置](http://blog.csdn.net/HzSunshine/article/details/67081917)
  * 下一篇[zabbix部署及监控](http://blog.csdn.net/HzSunshine/article/details/70056934)
.

####

相关文章推荐

  * _•_ [组复制官方文档翻译（组复制原理）](http://blog.csdn.net/cug_jiang126com/article/details/53818204 "组复制官方文档翻译（组复制原理）")
  * _•_ [SDCC 2017之大数据技术实战线上峰会](http://edu.csdn.net/huiyiCourse/series_detail/64?utm_source=blog7 "SDCC 2017之大数据技术实战线上峰会")
  * _•_ [mysql5.7新特性组复制官网简易翻译](http://blog.csdn.net/aoerqileng/article/details/71194631 "mysql5.7新特性组复制官网简易翻译")
  * _•_ [Hadoop大数据从入门到精通知识体系详解](http://edu.csdn.net/course/detail/3027?utm_source=blog7 "Hadoop大数据从入门到精通知识体系详解")
  * _•_ [MySQL Group Replication 搭建[Multi-Primary Mode]](http://blog.csdn.net/d6619309/article/details/53691790 "MySQL Group Replication 搭建\[Multi-Primary Mode\]")
  * _•_ [SDCC 2017之区块链技术实战线上峰会](http://edu.csdn.net/huiyiCourse/series_detail/66?utm_source=blog7 "SDCC 2017之区块链技术实战线上峰会")
  * _•_ [MySQL Replication(复制)基本原理](http://blog.csdn.net/chengzi28/article/details/50960549 "MySQL Replication\(复制\)基本原理")
  * _•_ [C++跨平台开发和ffmpeg，opencv音视频技术](http://edu.csdn.net/combo/detail/540?utm_source=blog7 "C++跨平台开发和ffmpeg，opencv音视频技术")

  * _•_ [mysql group replication集群搭建](http://blog.csdn.net/yuanlin65/article/details/53782020 "mysql group replication集群搭建")
  * _•_ [史上最全Android基础知识总结](http://edu.csdn.net/course/detail/2741?utm_source=blog7 "史上最全Android基础知识总结")
  * _•_ [zabbix部署及监控](http://blog.csdn.net/HzSunshine/article/details/70056934 "zabbix部署及监控")
  * _•_ [机器学习需要的数学知识](http://edu.csdn.net/combo/detail/532?utm_source=blog7 "机器学习需要的数学知识")
  * _•_ [MySQL Group Replication的RECOVERING状态深度理解](http://blog.csdn.net/mchdba/article/details/54671634 "MySQL Group Replication的RECOVERING状态深度理解")
  * _•_ [MYSQL双主同步复制配置](http://blog.csdn.net/oguro/article/details/52905169 "MYSQL双主同步复制配置")
  * _•_ [面试题：交换两个变量的值，不使用第三个变量](http://blog.csdn.net/oguro/article/details/52864251 "面试题：交换两个变量的值，不使用第三个变量")
  * _•_ [MySQL同步机制异常及恢复方法](http://blog.csdn.net/oguro/article/details/52905420 "MySQL同步机制异常及恢复方法")

  


---
### ATTACHMENTS
[0789a3e102324d702f07505bb3ce4be6]: media/Center.png
[Center.png](media/Center.png)
>hash: 0789a3e102324d702f07505bb3ce4be6  
>source-url: http://img.blog.csdn.net/20170404184446422?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvSHpTdW5zaGluZQ==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center  
>file-name: Center.png  

[2e2dc5fd2e47bcf47d95df7038ac1eb0]: media/Center-2.png
[Center-2.png](media/Center-2.png)
>hash: 2e2dc5fd2e47bcf47d95df7038ac1eb0  
>source-url: http://img.blog.csdn.net/20170404184430545?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvSHpTdW5zaGluZQ==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center  
>file-name: Center.png  

[570de32eb28731b489984a65fe175e6f]: media/Center-3.png
[Center-3.png](media/Center-3.png)
>hash: 570de32eb28731b489984a65fe175e6f  
>source-url: http://img.blog.csdn.net/20170404184349559?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvSHpTdW5zaGluZQ==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center  
>file-name: Center.png  

[760c5ec8c68b26ded5d32a15a75b0d4b]: media/category_icon-2.jpg
[category_icon-2.jpg](media/category_icon-2.jpg)
>hash: 760c5ec8c68b26ded5d32a15a75b0d4b  
>source-url: http://static.blog.csdn.net/images/category_icon.jpg  
>file-name: category_icon.jpg  

[76b818cb310cedf227ae109e056fc64d]: media/Center-4.png
[Center-4.png](media/Center-4.png)
>hash: 76b818cb310cedf227ae109e056fc64d  
>source-url: http://img.blog.csdn.net/20170404184758753?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvSHpTdW5zaGluZQ==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center  
>file-name: Center.png  

[f4957b54c1e7e28871f863560acc9791]: media/arrow_triangle__down-2.jpg
[arrow_triangle__down-2.jpg](media/arrow_triangle__down-2.jpg)
>hash: f4957b54c1e7e28871f863560acc9791  
>source-url: http://static.blog.csdn.net/images/arrow_triangle%20_down.jpg  
>file-name: arrow_triangle _down.jpg  


---
### TAGS
{group replication}

---
### NOTE ATTRIBUTES
>Created Date: 2017-09-13 07:01:51  
>Last Evernote Update Date: 2018-10-01 15:35:39  
>author: YangKwong  
>source: web.clip  
>source-url: http://blog.csdn.net/hzsunshine/article/details/69132225  