# maxscale实现读写分离 - CSDN博客

原

# maxscale实现读写分离

2016年05月03日 18:17:04 阅读数：11517 标签： [mysql
](http://so.csdn.net/so/search/s.do?q=mysql&t=blog)[maria db
](http://so.csdn.net/so/search/s.do?q=maria%20db&t=blog)[负载均衡
](http://so.csdn.net/so/search/s.do?q=%E8%B4%9F%E8%BD%BD%E5%9D%87%E8%A1%A1&t=blog)
更多

个人分类： [MariaDB
](https://blog.csdn.net/wjf870128/article/category/5839285)[Mysql
](https://blog.csdn.net/wjf870128/article/category/3159497)

# 1.前言

maxscale是mariadb公司开发的一套数据库中间件，可以很方便的实现读写分离方案；并且提供了读写分离的负载均衡和高可用性保障。另外maxscale对于前端应用而言是透明的，我们可以很方便的将应用迁移到maxscale中实现读写分离方案，来分担主库的压力。maxscale也提供了sql语句的解析过滤功能。这里我们主要讲解maxscale的安装、配置以及注意事项。

  

# 2.安装环境

使用我之前的MHA环境

1）server1（node节点）  
OS：CentOS 6.4 X64  
IPADDR：172.16.21.12（eth0）；192.168.8.6（eth1）  
HOSTNAME：mysql-mha01  
DB：Mariadb10.0.21  
防火墙关闭；selinux关闭；  
2）server2（node节点）  
OS：CentOS 6.4 X64  
IPADDR：172.16.21.13（eth2）；192.168.8.7（eth3）  
HOSTNAME：mysql-mha02  
DB：DB：Mariadb10.0.21  
防火墙关闭；selinux关闭；  
3）server3（node节点，manager节点）  
OS：CentOS 6.4 X64  
IPADDR：172.16.21.15（eth2）；192.168.8.8（eth3）  
HOSTNAME：mysql-mha01  
DB：DB：Mariadb10.0.21  
防火墙关闭；selinux关闭；

  

使用软件：maxscale-1.4.1-1.rhel_6.x86_64.rpm

  

# 3.安装软件

在主节点192.168.8.7上安装maxscale

    
    
    yum install maxscale-1.4.1-1.rhel_6.x86_64.rpm
    
          1. 1
    
    mkdir -p /maxscale/cache  
    
      2. 2
    
    mkdir -p /maxscale/data  
    
      3. 3
    
    mkdir -p /maxscale/log  
    
      4. 4
    
    mkdir -p /maxscale/pid  
    
      5. 5
    
    mkdir -p /maxscale/tmp
    
    
    

# 4.maxscale配置

## 4.1配置文件

    
          1. 1
    
    [root@mysql-mha02 etc]# cat /etc/maxscale.cnf
    
      2. 2
    
    # MaxScale documentation on GitHub:
    
      3. 3
    
    # https://github.com/mariadb-corporation/MaxScale/blob/master/Documentation/Documentation-Contents.md
    
      4. 4
    
     
    
      5. 5
    
    # Global parameters
    
      6. 6
    
    #
    
      7. 7
    
    # Complete list of configuration options:
    
      8. 8
    
    # https://github.com/mariadb-corporation/MaxScale/blob/master/Documentation/Getting-Started/Configuration-Guide.md
    
      9. 9
    
     
    
      10. 10
    
    [maxscale]
    
      11. 11
    
    threads=auto               #开启线程个数，默认为1.设置为auto会同cpu核数相同
    
      12. 12
    
    ms_timestamp=1             #timestamp精度
    
      13. 13
    
    syslog=1                   #将日志写入到syslog中  
    
      14. 14
    
    maxlog=1                   #将日志写入到maxscale的日志文件中
    
      15. 15
    
    log_to_shm=0               #不将日志写入到共享缓存中，开启debug模式时可打开加快速度
    
      16. 16
    
    log_warning=1              #记录告警信息
    
      17. 17
    
    log_notice=1               #记录notice
    
      18. 18
    
    log_info=1                 #记录info
    
      19. 19
    
    log_debug=0                #不打开debug模式
    
      20. 20
    
    log_augmentation=1         #日志递增
    
      21. 21
    
    #相关目录设置
    
      22. 22
    
    logdir=/maxscale/log/
    
      23. 23
    
    datadir=/maxscale/data/
    
      24. 24
    
    libdir=/usr/lib64/maxscale/
    
      25. 25
    
    cachedir=/maxscale/cache/
    
      26. 26
    
    piddir=/maxscale/pid/
    
      27. 27
    
    execdir=/usr/bin/
    
      28. 28
    
     
    
      29. 29
    
    # Server definitions
    
      30. 30
    
    #
    
      31. 31
    
    # Set the address of the server to the network
    
      32. 32
    
    # address of a MySQL server.
    
      33. 33
    
    #
    
      34. 34
    
    [server1]
    
      35. 35
    
    type=server
    
      36. 36
    
    address=192.168.8.6
    
      37. 37
    
    port=3306
    
      38. 38
    
    protocol=MySQLBackend
    
      39. 39
    
     
    
      40. 40
    
    [server2]
    
      41. 41
    
    type=server
    
      42. 42
    
    address=192.168.8.7
    
      43. 43
    
    port=3306
    
      44. 44
    
    protocol=MySQLBackend
    
      45. 45
    
     
    
      46. 46
    
    [server3]
    
      47. 47
    
    type=server
    
      48. 48
    
    address=192.168.8.8
    
      49. 49
    
    port=3306
    
      50. 50
    
    protocol=MySQLBackend
    
      51. 51
    
     
    
      52. 52
    
    # Monitor for the servers
    
      53. 53
    
    #
    
      54. 54
    
    # This will keep MaxScale aware of the state of the servers.
    
      55. 55
    
    # MySQL Monitor documentation:
    
      56. 56
    
    # https://github.com/mariadb-corporation/MaxScale/blob/master/Documentation/Monitors/MySQL-Monitor.md
    
      57. 57
    
     
    
      58. 58
    
    #相关的监控信息，监控的用户需要对后端数据库有访问replication client的权限：grant replication client
    
      59. 59
    
    [MySQL Monitor]
    
      60. 60
    
    type=monitor
    
      61. 61
    
    module=mysqlmon
    
      62. 62
    
    servers=server1,server2,server3
    
      63. 63
    
    user=root
    
      64. 64
    
    passwd=7AE087FBF864EBB87D108C3AB1603D0D
    
      65. 65
    
    monitor_interval=1000              #监控心跳为1秒 
    
      66. 66
    
    detect_replication_lag=true        #监控主从复制延迟，可用后续指定router service的max_slave_replication_lag单位是秒，来控制maxscale运行的最大延迟
    
      67. 67
    
    detect_stale_master=true           #当复制slave全部断掉时，maxscale仍然可用，将所有的访问指向master节点
    
      68. 68
    
     
    
      69. 69
    
    # Service definitions
    
      70. 70
    
    #
    
      71. 71
    
    # Service Definition for a read-only service and
    
      72. 72
    
    # a read/write splitting service.
    
      73. 73
    
    #
    
      74. 74
    
     
    
      75. 75
    
    # ReadConnRoute documentation:
    
      76. 76
    
    # https://github.com/mariadb-corporation/MaxScale/blob/master/Documentation/Routers/ReadConnRoute.md
    
      77. 77
    
     
    
      78. 78
    
    #read-only的只读节点slave分离
    
      79. 79
    
    [Read-Only Service]
    
      80. 80
    
    type=service
    
      81. 81
    
    router=readconnroute
    
      82. 82
    
    servers=server1,server2,server3
    
      83. 83
    
    user=root
    
      84. 84
    
    passwd=7AE087FBF864EBB87D108C3AB1603D0D
    
      85. 85
    
    router_options=slave
    
      86. 86
    
    enable_root_user=1
    
      87. 87
    
     
    
      88. 88
    
    # ReadWriteSplit documentation:
    
      89. 89
    
    # https://github.com/mariadb-corporation/MaxScale/blob/master/Documentation/Routers/ReadWriteSplit.md
    
      90. 90
    
     
    
      91. 91
    
    #读写分离，用户需要有SELECT ON mysql.db；SELECT ON mysql.tables_priv；SHOW DATABASES ON *.*的权限
    
      92. 92
    
    [Read-Write Service]
    
      93. 93
    
    type=service
    
      94. 94
    
    router=readwritesplit
    
      95. 95
    
    servers=server1,server2,server3
    
      96. 96
    
    user=root
    
      97. 97
    
    passwd=7AE087FBF864EBB87D108C3AB1603D0D
    
      98. 98
    
    use_sql_variables_in=master                  #sql语句中的存在变量只指向master中执行
    
      99. 99
    
    enable_root_user=1                           #允许root用户登录执行
    
      100. 100
    
    master_accept_reads=true                     #master节点也可以转发读请求
    
      101. 101
    
    max_slave_replication_lag=5                  #复制延迟最大为5秒(必须比monitor的interval大)
    
    
    
    
          1. 1
    
    #maxscale管理节点信息
    
      2. 2
    
    [MaxAdmin Service]
    
      3. 3
    
    type=service
    
      4. 4
    
    router=cli
    
      5. 5
    
     
    
      6. 6
    
    # Listener definitions for the services
    
      7. 7
    
    #
    
      8. 8
    
    # These listeners represent the ports the
    
      9. 9
    
    # services will listen on.
    
      10. 10
    
    #
    
      11. 11
    
     
    
      12. 12
    
    #各个请求的端口信息
    
      13. 13
    
    [Read-Only Listener]
    
      14. 14
    
    type=listener
    
      15. 15
    
    service=Read-Only Service
    
      16. 16
    
    protocol=MySQLClient
    
      17. 17
    
    port=4008
    
      18. 18
    
     
    
      19. 19
    
    [Read-Write Listener]
    
      20. 20
    
    type=listener
    
      21. 21
    
    service=Read-Write Service
    
      22. 22
    
    protocol=MySQLClient
    
      23. 23
    
    port=4006
    
      24. 24
    
     
    
      25. 25
    
    [MaxAdmin Listener]
    
      26. 26
    
    type=listener
    
      27. 27
    
    service=MaxAdmin Service
    
      28. 28
    
    protocol=maxscaled
    
      29. 29
    
    port=6603
    
    
    

  
  

## 4.2加密密码

配置文件中的密码都是经过maxscale进行加密后的，可以防止密码泄露，具体的操作步骤为

在刚才配置文件中的datadir目录下创建加密文件

    
    
    maxkeys /maxscale/data

  
生成加密后的密码

    
          1. 1
    
    [root@mysql-mha02 data]# maxpasswd /maxscale/data/.secrets 123456
    
      2. 2
    
    7AE087FBF864EBB87D108C3AB1603D0D
    
    
    

7AE087FBF864EBB87D108C3AB1603D0D就是123456加密后的密码啦。我们可以添加到配置文件中。

## 4.3启动maxscale

    
    
    maxscale -f /etc/maxscale.cnf

# 5.验证读写分离

## 5.1创建测试表

在主节点server2 192.168.8.7上建立测试表

    
          1. 1
    
    MariaDB [test]> create table test_maxscale(id int);
    
      2. 2
    
    Query OK, 0 rows affected (0.02 sec)
    
      3. 3
    
     
    
      4. 4
    
    MariaDB [test]> insert into test_maxscale values(87);
    
      5. 5
    
    Query OK, 1 row affected (0.02 sec)
    
      6. 6
    
     
    
      7. 7
    
    MariaDB [test]> select * from test_maxscale;
    
      8. 8
    
    +------+
    
      9. 9
    
    | id   |
    
      10. 10
    
    +------+
    
      11. 11
    
    |   87 |
    
      12. 12
    
    +------+
    
      13. 13
    
    1 row in set (0.00 sec)
    
    
    

在节点server1 192.168.8.6上额外加入测试信息  

    
          1. 1
    
    MariaDB [test]> insert into test_maxscale values(86);
    
      2. 2
    
    MariaDB [test]> select * from test_maxscale;
    
      3. 3
    
    +------+
    
      4. 4
    
    | id   |
    
      5. 5
    
    +------+
    
      6. 6
    
    |   87 |
    
      7. 7
    
    |   86 |
    
      8. 8
    
    +------+
    
      9. 9
    
    2 rows in set (0.00 sec)
    
    
    

在节点server3 192.168.8.8上额外加入测试信息  

    
          1. 1
    
    MariaDB [test]> insert into test_maxscale values(88);
    
      2. 2
    
    Query OK, 1 row affected (0.00 sec)
    
      3. 3
    
     
    
      4. 4
    
    MariaDB [test]> select * from test_maxscale;
    
      5. 5
    
    +------+
    
      6. 6
    
    | id   |
    
      7. 7
    
    +------+
    
      8. 8
    
    |   87 |
    
      9. 9
    
    |   88 |
    
      10. 10
    
    +------+
    
      11. 11
    
    2 rows in set (0.00 sec)
    
    
    

  

## 5.2只读访问maxscale

通过mysql命令行访问maxscale所在节点192.168.8.7的读写分离listener 4006端口

    
          1. 1
    
    [root@mysql-mha01 ~]# mysql -P4006 -uroot -p123456 -h192.168.8.7 -e "select * from test.test_maxscale;"
    
      2. 2
    
    +------+
    
      3. 3
    
    | id   |
    
      4. 4
    
    +------+
    
      5. 5
    
    |   87 |
    
      6. 6
    
    |   86 |
    
      7. 7
    
    +------+
    
    
    

发现分到了server1上面

## 5.3读写分离

加入包含insert的sql语句

    
          1. 1
    
    [root@mysql-mha02 log]# mysql -P4006 -uroot -p123456 -h192.168.8.7 -e "insert into test.test_maxscale values(90);select * from test.test_maxscale;"
    
      2. 2
    
    +------+
    
      3. 3
    
    | id   |
    
      4. 4
    
    +------+
    
      5. 5
    
    |   87 |
    
      6. 6
    
    |   88 |
    
      7. 7
    
    |   90 |
    
      8. 8
    
    +------+
    
    
    

发现转发到server3中，但是也包含90的值，我们需要到主节点server2和另外一个slave进行验证

在server2主节点中

    
          1. 1
    
    MariaDB [(none)]> select * from test.test_maxscale;
    
      2. 2
    
    +------+
    
      3. 3
    
    | id   |
    
      4. 4
    
    +------+
    
      5. 5
    
    |   87 |
    
      6. 6
    
    |   90 |
    
      7. 7
    
    +------+
    
      8. 8
    
    2 rows in set (0.00 sec)
    
    
    

在server1另一个slave节点中

    
          1. 1
    
    MariaDB [test]> select * from test_maxscale;
    
      2. 2
    
    +------+
    
      3. 3
    
    | id   |
    
      4. 4
    
    +------+
    
      5. 5
    
    |   87 |
    
      6. 6
    
    |   86 |
    
      7. 7
    
    |   90 |
    
      8. 8
    
    +------+
    
      9. 9
    
    3 rows in set (0.00 sec)
    
    
    

maxscale实现了读写分离。  
  

# 6.注意事项

详细的注意事项链接 <https://mariadb.com/kb/en/mariadb-enterprise/mariadb-
maxscale/limitations-and-known-issues-within-maxscale/>

这里我主要讲些重点需要注意的：

1）创建链接的时候，不支持压缩协议

2）转发路由不能动态的识别master节点的迁移

3）LONGLOB字段不支持

4）在一下情况会将语句转到master节点中(保证事务一致)：

明确指定事务；

prepared的语句；

语句中包含存储过程，自定义函数

包含多条语句信息：INSERT INTO ... ; SELECT LAST_INSERT_ID();

5）一些语句默认会发送到后端的所有server中，但是可以指定

    
    
    use_sql_variables_in=[master|all] (default: all)
    

为master的时候可以将语句都转移到master 上执行。但是自动提交值和prepared的语句仍然发送到所有后端server。

这些语句为

    
          1. 1
    
    COM_INIT_DB (USE <db name> creates this)
    
      2. 2
    
    COM_CHANGE_USER
    
      3. 3
    
    COM_STMT_CLOSE
    
      4. 4
    
    COM_STMT_SEND_LONG_DATA
    
      5. 5
    
    COM_STMT_RESET
    
      6. 6
    
    COM_STMT_PREPARE
    
      7. 7
    
    COM_QUIT (no response, session is closed)
    
      8. 8
    
    COM_REFRESH
    
      9. 9
    
    COM_DEBUG
    
      10. 10
    
    COM_PING
    
      11. 11
    
    SQLCOM_CHANGE_DB (USE ... statements)
    
      12. 12
    
    SQLCOM_DEALLOCATE_PREPARE
    
      13. 13
    
    SQLCOM_PREPARE
    
      14. 14
    
    SQLCOM_SET_OPTION
    
      15. 15
    
    SELECT ..INTO variable|OUTFILE|DUMPFILE
    
      16. 16
    
    SET autocommit=1|0
    
    
    

  

6）maxscale不支持主机名匹配的认证模式，只支持IP地址方式的host解析。所以在添加user的时候记得使用合适的范式。

7）跨库查询不支持，会显示的指定到第一个数据库中

8）通过select方式改变会话变量的行为不支持  
  

  

  

  

  

  


---
### NOTE ATTRIBUTES
>Created Date: 2018-09-04 02:36:39  
>Last Evernote Update Date: 2018-10-01 15:35:36  
>source: web.clip7  
>source-url: https://blog.csdn.net/wjf870128/article/details/51218697  
>source-application: WebClipper 7  