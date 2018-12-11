# Maxscale安装-读写分离(1) – 运维生存时间

# Maxscale安装-读写分离(1)

  * __
  * [ __ 1 ](http://www.ttlsa.com/mysql/maxscale-install-read-write-split/#comments)
  * __ __

  * A+

所属分类：[MySQL](http://www.ttlsa.com/mysql/)

### ****前言****

关于MySQL中间件的产品也很多,之前用过了360的Atlas、玩过MyCat。这边我选择 Maxscale的原因就是功能能满足需求,也看好他的未来发展。

其实有关于如何安装 Maxscale的文章百度一下一大把，写这篇文章主要为了说明配置的某些现象，同时也为之后使用Maxscale的其他配置做下基础。

### ****我的环境****

这边我的'一主二从'已经是搭建好的了，如何搭建就不再描述了。

****注意：**** 这边我的三个节点都没有开启 GTID，具体是为什么在之后会讲到，这边大家留意一下就行。

1

2

3

4

|

192.168.137.11 (Maxscale)

192.168.137.21:3306 (Master)

192.168.137.22:3306 (Slave)

192.168.137.23:3306 (Slave)  
  
---|---  
  
这边我使用的用于复制的用户是maxscale,具体权限如下:

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

17

18

19

20

21

22

|

CREATE USER maxscale@'%' IDENTIFIED BY "123456";

GRANT replication slave, replication client ON *.* TO maxscale@'%';

GRANT SELECT ON mysql.* TO maxscale@'%';

GRANT ALL ON maxscale_schema.* TO maxscale@'%';

GRANT SHOW DATABASES ON *.* TO maxscale@'%';

root@(none) 22:34:15>SELECT VERSION();

+\--\--\--\--\--\--\--\--\--\--+

| VERSION() |

+\--\--\--\--\--\--\--\--\--\--+

| 10.1.8-MariaDB-log |

+\--\--\--\--\--\--\--\--\--\--+

1 row in set (0.00 sec)

root@(none) 22:34:25>SHOW SLAVE HOSTS;

+\--\--\--\--\--\--+\--\--\--\--\--\--\--\--+\--\--\--+\--\--\--\--\--\--+

| Server_id | Host | Port | Master_id |

+\--\--\--\--\--\--+\--\--\--\--\--\--\--\--+\--\--\--+\--\--\--\--\--\--+

| 3306137022 | 192.168.137.21 | 3306 | 3306137021 |

| 3306137023 | 192.168.137.21 | 3306 | 3306137021 |

+\--\--\--\--\--\--+\--\--\--\--\--\--\--\--+\--\--\--+\--\--\--\--\--\--+

2 rows in set (0.00 sec)  
  
---|---  
  
下载Maxscale

在 192.168.137.11 机器上

这边提供下载地址: [_https://downloads.mariadb.com_](https://downloads.mariadb.com/)

****我的版本****

1

2

3

4

5

6

|

[root@normal_11 opt]# pwd

/opt

[root@normal_11 opt]# ll

total 149624

-rw-r\--r\-- 1 root root 3587510 Nov 2 21:07 maxscale-2.0.1.centos.7.tar.gz  
  
---|---  
  
### ****开始安装****

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

|

[root@normal_11 opt]# groupadd maxscale

[root@normal_11 opt]# useradd -g maxscale maxscale

[root@normal_11 opt]# cd /opt

[root@normal_11 opt]# tar -zxf maxscale-2.0.1.centos.7.tar.gz

[root@normal_11 opt]# ln -s maxscale-2.0.1.centos.7 /usr/local/maxscale

[root@normal_11 opt]# chown -R maxscale:maxscale /usr/local/maxscale

[root@normal_11 opt]# mkdir -p /u01/maxscale/{data,cache,logs,tmp}

[root@normal_11 opt]# mkdir -p /u01/maxscale/logs/{binlog,trace}

[root@normal_11 opt]# chown -R maxscale:maxscale /u01/maxscale

[root@normal_11 opt]# /usr/local/maxscale/bin/maxkeys /u01/maxscale/data/

[root@normal_11 opt]# /usr/local/maxscale/bin/maxpasswd
/u01/maxscale/data/.secrets 123456

1D30C1E689410756D7B82C233FCBF8D9  
  
---|---  
  
****Maxscale 配置文件****

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

17

18

19

20

21

22

23

24

25

26

27

28

29

30

31

32

33

34

35

36

37

38

39

40

41

42

43

44

45

46

47

48

49

50

51

52

53

54

55

56

57

58

59

60

61

62

63

64

65

66

67

68

69

70

71

72

73

74

75

76

77

78

79

80

81

82

83

84

85

86

87

88

89

90

91

92

93

94

95

96

97

98

99

100

101

102

103

104

105

106

107

108

109

110

111

112

113

114

115

116

117

118

119

120

121

122

123

124

125

126

127

128

129

130

131

|

[root@normal_11 opt]# cat /etc/maxscale.cnf

###################################################

# CREATE USER maxscale@'%' IDENTIFIED BY "123456";

# GRANT replication slave, replication client ON *.* TO maxscale@'%';

# GRANT SELECT ON mysql.* TO maxscale@'%';

# GRANT ALL ON maxscale_schema.* TO maxscale@'%';

# GRANT SHOW DATABASES ON *.* TO maxscale@'%';

# groupadd maxscale

# useradd -g maxscale maxscale

# cd /opt

# tar -zxf maxscale-2.0.1.rhel.7.tar.gz

# ln -s /opt/maxscale-2.0.1.rhel.7 /usr/local/maxscale

# chown -R maxscale:maxscale /usr/local/maxscale

# mkdir -p /u01/maxscale/{data,cache,logs,tmp}

# mkdir -p /u01/maxscale/logs/{binlog,trace}

# chown -R maxscale:maxscale /u01/maxscale

# /usr/local/maxscale/bin/maxkeys /u01/maxscale/data/

# /usr/local/maxscale/bin/maxpasswd /u01/maxscale/data/.secrets 123456

###################################################

[maxscale]

# 开启线程个数，默认为1.设置为auto会同cpu核数相同

threads=auto

# timestamp精度

ms_timestamp=1

# 将日志写入到syslog中

syslog=1

# 将日志写入到maxscale的日志文件中

maxlog=1

# 不将日志写入到共享缓存中，开启debug模式时可打开加快速度

log_to_shm=0

# 记录告警信息

log_warning=1

# 记录notice

log_notice=1

# 记录info

log_info=1

# 不打开debug模式

log_debug=0

# 日志递增

log_augmentation=1

# 相关目录设置

basedir=/usr/local/maxscale/

logdir=/u01/maxscale/logs/trace/

datadir=/u01/maxscale/data/

cachedir=/u01/maxscale/cache/

piddir=/u01/maxscale/tmp/

[server1]

type=server

address=192.168.137.21

port=3306

protocol=MySQLBackend

serv_weight=1

[server2]

type=server

address=192.168.137.22

port=3306

protocol=MySQLBackend

serv_weight=3

[server3]

type=server

address=192.168.137.23

port=3306

protocol=MySQLBackend

serv_weight=3

[MySQL Monitor]

type=monitor

module=mysqlmon

servers=server1,server2,server3

user=maxscale

passwd=1D30C1E689410756D7B82C233FCBF8D9

# 监控心态为 10s

monitor_interval=10000

# 当复制slave全部断掉时，maxscale仍然可用，将所有的访问指向master节点

detect_stale_master=true

# 监控主从复制延迟，可用后续指定router service的(配置此参数请求会永远落在 master)

# detect_replication_lag=true

[Read-Only Service]

type=service

router=readconnroute

servers=server1,server2,server3

user=maxscale

passwd=1D30C1E689410756D7B82C233FCBF8D9

router_options=slave

# 允许root用户登录执行

enable_root_user=1

# 查询权重

weightby=serv_weight

[Read-Write Service]

type=service

router=readwritesplit

servers=server1,server2,server3

user=maxscale

passwd=1D30C1E689410756D7B82C233FCBF8D9

max_slave_connections=100%

# sql语句中的存在变量只指向master中执行

use_sql_variables_in=master

# 允许root用户登录执行

enable_root_user=1

# 允许主从最大间隔(s)

max_slave_replication_lag=3600

[MaxAdmin Service]

type=service

router=cli

[Read-Only Listener]

type=listener

service=Read-Only Service

protocol=MySQLClient

port=4008

[Read-Write Listener]

type=listener

service=Read-Write Service

protocol=MySQLClient

port=4006

[MaxAdmin Listener]

type=listener

service=MaxAdmin Service

protocol=maxscaled

socket=/u01/maxscale/tmp/maxadmin.sock

port=6603  
  
---|---  
  
细心的朋友会注意到, 的我配置文件最上面就是安装 Maxscale 的基本步骤，这是本人的一个习惯.

这边我稍微说明一下配置文件的意思:

  1. [server1], [server2], [server3] 我配置了三个Maxscale需要连接的MySQL服务
  2. [MySQL Monitor] 配置一个监听服务, 同时监听着 [server1], [server2], [server3] 的状态
  3. [Read-Only Service] 配置了只读服务, 只在[server2], [server3]中执行

注意: 虽然是只读服务但是同样可以执行 DML DDL, 说以要限制好用户的权限.

  4. [Read-Write Listener] 配置了读写分离的服务
  5. [MaxAdmin Listener] 配置了用户管理Maxscale的服务

### ****演示****

这边我们以 [Read-Write Listener] 配置的服务来演示读写分离情况

  1. ****启动 Maxscale****

如果启动有报错那就查看一下日志 /var/log/message 或 /u01/maxscale/logs/trace/maxscale1.log(自定义)

1

2

3

4

5

6

7

8

|

[root@normal_11 opt]# /usr/local/maxscale/bin/maxscale -f /etc/maxscale.cnf

[root@normal_11 opt]# netstat -natpl | grep max

tcp 0 0 0.0.0.0:4008 0.0.0.0:* LISTEN 5507/maxscale

tcp 0 0 0.0.0.0:6603 0.0.0.0:* LISTEN 5507/maxscale

tcp 0 0 0.0.0.0:4006 0.0.0.0:* LISTEN 5507/maxscale

tcp 0 0 192.168.137.11:43102 192.168.137.22:3306 ESTABLISHED 5507/maxscale

tcp 0 0 192.168.137.11:54624 192.168.137.21:3306 ESTABLISHED 5507/maxscale

tcp 0 0 192.168.137.11:52989 192.168.137.23:3306 ESTABLISHED 5507/maxscale  
  
---|---  
  
  2. ****使用 maxadmin 查看服务****

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

17

18

19

|

[root@normal_11 opt]# /usr/local/maxscale/bin/maxadmin -S
/u01/maxscale/tmp/maxadmin.sock

MaxScale> list servers

Servers.

\--\--\--\--\--\--\--\--\---+\--\--\--\--\--\--\--\---+\--\--\---+\--\--\--\--\--\---+\--\--\--\--\--\--\--\--\--\--

Server | Address | Port | Connections | Status

\--\--\--\--\--\--\--\--\---+\--\--\--\--\--\--\--\---+\--\--\---+\--\--\--\--\--\---+\--\--\--\--\--\--\--\--\--\--

server1 | 192.168.137.21 | 3306 | 0 | Master, Running

server2 | 192.168.137.22 | 3306 | 0 | Slave, Running

server3 | 192.168.137.23 | 3306 | 0 | Slave, Running

\--\--\--\--\--\--\--\--\---+\--\--\--\--\--\--\--\---+\--\--\---+\--\--\--\--\--\---+\--\--\--\--\--\--\--\--\--\--

MaxScale> list services

Services.

\--\--\--\--\--\--\--\--\--\--\--\--\--+\--\--\--\--\--\--\--\--\--\--\--+\--\--\--\--+\--\--\--\--\--\--\---

Service Name | Router Module | #Users | Total Sessions

\--\--\--\--\--\--\--\--\--\--\--\--\--+\--\--\--\--\--\--\--\--\--\--\--+\--\--\--\--+\--\--\--\--\--\--\---

Read-Only Service | readconnroute | 1 | 1

Read-Write Service | readwritesplit | 1 | 1

MaxAdmin Service | cli | 3 | 3

\--\--\--\--\--\--\--\--\--\--\--\--\--+\--\--\--\--\--\--\--\--\--\--\--+\--\--\--\--+\--\--\--\--\--\--\---  
  
---|---  
  
通过登录Maxscale的读写分离服务, 来执行sql并且查看日志，查看日志路由情况。

****注意:**** 这边登录的用户就是普通的MySQL用户, 不是maxscale用户

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

17

18

19

20

21

22

23

24

25

26

27

28

29

30

31

32

33

34

35

36

37

38

39

40

41

42

43

44

45

46

47

48

49

50

51

|

[root@normal_11 opt]# mysql -uHH -p -h192.168.137.11 -P4006

Logging to file '/u01/mysql_history/query.log'

Enter password:

Welcome to the MySQL monitor. Commands end with ; or \g.

Your MySQL connection id is 5524

Server version: 5.5.5-10.0.0 2.0.1-maxscale MariaDB Server

Copyright (c) 2009-2015 Percona LLC and/or its affiliates

Copyright (c) 2000, 2015, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its

affiliates. Other names may be trademarks of their respective

owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

HH@192.168.137.11 11:13:46 [(none)]>SELECT * FROM test.t1;

+\--\--+\--\--\--+\--\---+

| id | name | age |

+\--\--+\--\--\--+\--\---+

| 1 | HH1 | 1 |

| 2 | HH2 | 2 |

| 3 | HH3 | 3 |

+\--\--+\--\--\--+\--\---+

3 rows in set (0.01 sec)

HH@192.168.137.11 11:15:03 [(none)]>INSERT INTO test.t1 VALUES(NULL, 'HH4',
4);

Query OK, 1 row affected (0.01 sec)

# 使用 HH 登录成的日志

2016-11-03 23:13:46.907 info : (log_server_connections): Servers and router
connection counts:

2016-11-03 23:13:46.907 info : (log_server_connections): current operations :
0 in 192.168.137.21:3306 RUNNING MASTER

2016-11-03 23:13:46.907 info : (log_server_connections): current operations :
0 in 192.168.137.22:3306 RUNNING SLAVE

2016-11-03 23:13:46.907 info : (log_server_connections): current operations :
0 in 192.168.137.23:3306 RUNNING SLAVE

2016-11-03 23:13:46.908 info : (select_connect_backend_servers): Selected
RUNNING MASTER in 192.168.137.21:3306

2016-11-03 23:13:46.908 info : (select_connect_backend_servers): Selected
RUNNING SLAVE in 192.168.137.22:3306

2016-11-03 23:13:46.908 info : (select_connect_backend_servers): Selected
RUNNING SLAVE in 192.168.137.23:3306

2016-11-03 23:13:46.908 info : (session_alloc): Started Read-Write Service
client session [0] for 'HH' from 192.168.137.11

2016-11-03 23:13:46.909 [9] info : (route_single_stmt): > Autocommit:
[enabled], trx is [not open], cmd: COM_QUERY, type:
QUERY_TYPE_READ|QUERY_TYPE_SYSVAR_READ, stmt: select @@version_comment limit 1

2016-11-03 23:13:46.909 [9] info : (route_single_stmt): Route query to master
192.168.137.21:3306 <

2016-11-03 23:13:46.922 [9] info : (route_single_stmt): > Autocommit:
[enabled], trx is [not open], cmd: COM_QUERY, type: QUERY_TYPE_READ, stmt:
select USER()

2016-11-03 23:13:46.922 [9] info : (route_single_stmt): Route query to slave
192.168.137.22:3306 <

# 执行 SELECT * FROM test.t1 语句被路由到 192.168.137.22:3306[server2]中的日志

2016-11-03 23:15:02.618 [9] info : (route_single_stmt): > Autocommit:
[enabled], trx is [not open], cmd: COM_QUERY, type: QUERY_TYPE_READ, stmt:
SELECT * FROM test.t1

2016-11-03 23:15:02.618 [9] info : (route_single_stmt): Route query to slave
192.168.137.22:3306 <

# 执行 INSERT INTO test.t1 VALUES(NULL, 'HH4', 4) 语句被路由到
192.168.137.21:3306[server1]中的日志

2016-11-03 23:17:02.716 [9] info : (route_single_stmt): > Autocommit:
[enabled], trx is [not open], cmd: COM_QUERY, type: QUERY_TYPE_WRITE, stmt:
INSERT INTO test.t1 VALUES(NULL, 'HH4', 4)

2016-11-03 23:17:02.716 [9] info : (route_single_stmt): Route query to master
192.168.137.21:3306 <  
  
---|---  
  
上面是最基本的读写分离操作

### ****重点参数说明与演示****

有许多刚刚搭建Maxscale的朋友会问到为什么我的select总是落在Master上,影响比较大的参数有两个,如下:

1

2

3

4

5

|

# 监控主从复制延迟，可用后续指定router service的(配置此参数请求会永远落在 master)

detect_replication_lag=true

# 允许主从最大间隔(s).有些朋友在做压力测试的是会说SELECT 会打在Master,多半是这个参数

max_slave_replication_lag=3600  
  
---|---  
  
  1. ****detect_replication_lag=true 时的现象****

执行 SELECT 语句

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

|

HH@192.168.137.11 11:24:59 [(none)]>SELECT * FROM test.t1;

+\--\--+\--\--\--+\--\---+

| id | name | age |

+\--\--+\--\--\--+\--\---+

| 1 | HH1 | 1 |

| 2 | HH2 | 2 |

| 3 | HH3 | 3 |

| 4 | HH4 | 4 |

+\--\--+\--\--\--+\--\---+

4 rows in set (0.00 sec)  
  
---|---  
  
****查看路由的日志****

1

2

3

|

# 该查询落在了Master(192.168.137.21:3306)[server1]上了

2016-11-03 23:25:04.364 [7] info : (route_single_stmt): > Autocommit:
[enabled], trx is [not open], cmd: COM_QUERY, type: QUERY_TYPE_READ, stmt:
SELECT * FROM test.t1

2016-11-03 23:25:04.364 [7] info : (route_single_stmt): Route query to master
192.168.137.21:3306 <  
  
---|---  
  
所以我的配置是将 detect_replication_lag=true 给注释了也就是用默认值false.

关于 max_slave_replication_lag 这个参数我就不演示了, 因为涉及到了使用 sysbench 等压力工具不在本文范畴,
有兴趣的自己玩玩, 这边就说说该参数的意义。

如果主从延时大于该参数那么 QDL DML DDL 三种语句都落在 Master(192.168.137.21:3306)[server1]上。

昵称: HH

QQ: 275258836

ttlsa群交流沟通(QQ群②: 6690706 QQ群③: 168085569 QQ群④: 415230207（新） 微信公众号: ttlsacom)

[_感觉本文内容不错，读后有收获？_](https://shop127352015.taobao.com/?spm=a230r.7195193.1997079397.2.B0seHv)

_逛逛衣服店，鼓励作者写出更好文章。_

[ 收 __ 藏](http://www.ttlsa.com/mysql/maxscale-install-read-write-
split/?wpzmaction=add&postid=12517)

**微信公众号**

扫一扫关注运维生存时间公众号，获取最新技术文章~

__ 赞 _5_

赏

__ 分享


---
### ATTACHMENTS
[a2e9e9d54f7672170215dd73d82e627e]: media/Maxscale安装-读写分离1_–_运维生存时间.jpg
[Maxscale安装-读写分离1_–_运维生存时间.jpg](media/Maxscale安装-读写分离1_–_运维生存时间.jpg)
---
### NOTE ATTRIBUTES
>Created Date: 2018-09-04 02:44:05  
>Last Evernote Update Date: 2018-10-01 15:35:35  
>source: web.clip7  
>source-url: http://www.ttlsa.com/mysql/maxscale-install-read-write-split/  
>source-application: WebClipper 7  