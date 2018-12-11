# mycat+percona+keepalived+haproxy-左越宗-51CTO博客

#  Mycat+percona+keepalived+haproxy

作者：[zuoyuezong@163.com](http://blog.51cto.com/zuoyuezong/1702507mailto:zuoyuezong@163.com)

为什么Mycat难相信很多哥们做mycat不是不全就是这出错那里出错最后崩溃的边缘晃荡几分钟后不了了之，要么公司的mycat是个这里提供一个例子

至于mycat的介绍就是：[www.baidu.com搜索框中输入mycat](http://blog.51cto.com/zuoyuezong/1702507)

## 1.下载安装mycat，java

[https://github.com/MyCATApache/Mycat-download/blob/master/1.4-RELEASE/Mycat-
server-1.4-RELEASE-20150901112004-linux.tar.gz](https://github.com/MyCATApache/Mycat-
download/blob/master/1.4-RELEASE/Mycat-
server-1.4-RELEASE-20150901112004-linux.tar.gz)

  

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

|

`[root``@node24` `src]#tar -xf Mycat-
server-``1.4``-RELEASE-``20150901112004``-linux.tar.gz`

` `

`[root``@node24` `src]#mv mycat/ /usr/local/`

` `

`[root``@node24` `src]#useradd mycat`

` `

`[root``@node24` `local]#chown mycat:root mycat/ -R`

` `

`[root``@node24` `src]#rpm -ivh jre-8u51-linux-x64.rpm `

`Preparing... ########################################### [``100``%]`

` ``1``:jre1.``8``.0_51 ###########################################
[``100``%]`

`Unpacking JAR files...`

` ``rt.jar...`

` ``jsse.jar...`

` ``charsets.jar...`

` ``localedata.jar...`

` ``jfxrt.jar...`

` ``plugin.jar...`

` ``javaws.jar...`

` ``Deploy.jar...`

` `

` `

` `

`[root``@node24` `src]#java -version`

`java version ``"1.8.0_51"`

`Java(TM) SE Runtime Environment (build ``1.8``.0_51-b16)`

`Java HotSpot(TM) ``64``-Bit Server VM (build ``25.51``-b03, mixed mode)`  
  
---|---  
  
  

此处注意java版本不得低于1.6

至此Mycat安装就算完成了

## 2.mysql环境以及Mycat配置

### 我的环境如下

10.1.166.22：mysql dn1

10.1.166.23 mysql dn2

10.1.166.24 mysql dn3

10.1.166.25 mysql dn4

10.1.166.26 mysql dn5

### 配置hosts文件

1

2

3

4

5

6

7

8

9

|

`[root``@node22` `src]#cat /etc/hosts`

`127.0``.``0.1` `localhost localhost.localdomain localhost4
localhost4.localdomain4`

`::``1` `localhost localhost.localdomain localhost6 localhost6.localdomain6`

`10.1``.``166.22` `node22`

`10.1``.``166.22` `dn1`

`10.1``.``166.23` `dn2`

`10.1``.``166.24` `dn3`

`10.1``.``166.25` `dn4`

`10.1``.``166.26` `dn5`  
  
---|---  
  
  

传到各个机器

1

|

`for` `i in ``10.1``.``166.22` `10.1``.``166.23` `10.1``.``166.24`
`10.1``.``166.25` `10.1``.``166.26``;``do` `scp /etc/hosts $i:/etc;done`  
  
---|---  
  
  

### 为你的mycat用户设置个密码

1

2

3

4

5

6

7

|

`[root``@node24` `src]#passwd mycat`

`Changing password ``for` `user mycat.`

`New password: `

`BAD PASSWORD: it is WAY too ``short`

`BAD PASSWORD: is too simple`

`Retype ``new` `password: `

`passwd: all authentication tokens updated successfully.`  
  
---|---  
  
  

### 原始mycat测试配置

1

2

3

4

5

6

|

`[root``@node24` `conf]#>../logs/wrapper.log `

`[root``@node24` `conf]#`

`[root``@node24` `conf]#pwd`

`/usr/local/mycat/conf`

`[root``@node24` `conf]#../bin/mycat start`

`Starting Mycat-server...`  
  
---|---  
  
  

### 报错处理方案

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

|

`[root@node24 conf]#cat ../logs/wrapper.``log`

`STATUS | wrapper | 2015/09/18 01:27:36 | --> Wrapper Started as Daemon`

`STATUS | wrapper | 2015/09/18 01:27:36 | Launching a JVM...`

`INFO | jvm 1 | 2015/09/18 01:27:36 | Java HotSpot(TM) 64-Bit Server VM
warning: ignoring option MaxPermSize=64M; support was removed in 8.0`

`ERROR | wrapper | 2015/09/18 01:27:36 | JVM exited ``while` `loading the
application.`

`INFO | jvm 1 | 2015/09/18 01:27:36 | Error: Exception thrown by the agent :
java.net.MalformedURLException: Local host name unknown:
java.net.UnknownHostException: node24: node24: unknown error`

`STATUS | wrapper | 2015/09/18 01:27:41 | Launching a JVM...`

`INFO | jvm 2 | 2015/09/18 01:27:41 | Java HotSpot(TM) 64-Bit Server VM
warning: ignoring option MaxPermSize=64M; support was removed in 8.0`

`INFO | jvm 2 | 2015/09/18 01:27:41 | Error: Exception thrown by the agent :
java.net.MalformedURLException: Local host name unknown:
java.net.UnknownHostException: node24: node24: unknown error`

`ERROR | wrapper | 2015/09/18 01:27:41 | JVM exited ``while` `loading the
application.`

`STATUS | wrapper | 2015/09/18 01:27:45 | Launching a JVM...`

`INFO | jvm 3 | 2015/09/18 01:27:45 | Java HotSpot(TM) 64-Bit Server VM
warning: ignoring option MaxPermSize=64M; support was removed in 8.0`

`ERROR | wrapper | 2015/09/18 01:27:45 | JVM exited ``while` `loading the
application.`

`INFO | jvm 3 | 2015/09/18 01:27:45 | Error: Exception thrown by the agent :
java.net.MalformedURLException: Local host name unknown:
java.net.UnknownHostException: node24: node24: unknown error`

`STATUS | wrapper | 2015/09/18 01:27:50 | Launching a JVM...`

`INFO | jvm 4 | 2015/09/18 01:27:50 | Java HotSpot(TM) 64-Bit Server VM
warning: ignoring option MaxPermSize=64M; support was removed in 8.0`

`INFO | jvm 4 | 2015/09/18 01:27:50 | Error: Exception thrown by the agent :
java.net.MalformedURLException: Local host name unknown:
java.net.UnknownHostException: node24: node24: unknown error`

`ERROR | wrapper | 2015/09/18 01:27:50 | JVM exited ``while` `loading the
application.`

`STATUS | wrapper | 2015/09/18 01:27:54 | Launching a JVM...`

`INFO | jvm 5 | 2015/09/18 01:27:54 | Java HotSpot(TM) 64-Bit Server VM
warning: ignoring option MaxPermSize=64M; support was removed in 8.0`

`ERROR | wrapper | 2015/09/18 01:27:54 | JVM exited ``while` `loading the
application.`

`INFO | jvm 5 | 2015/09/18 01:27:54 | Error: Exception thrown by the agent :
java.net.MalformedURLException: Local host name unknown:
java.net.UnknownHostException: node24: node24: unknown error`

`FATAL | wrapper | 2015/09/18 01:27:54 | There were 5 failed launches in a
row, each lasting less than 300 seconds. Giving up.`

`FATAL | wrapper | 2015/09/18 01:27:54 | There may be a configuration problem:
please check the logs.`

`STATUS | wrapper | 2015/09/18 01:27:55 | <-- Wrapper Stopped`  
  
---|---  
  
  

发现有报错 所以要先启动一下原始的连原始的都报错那还配置没有意义

ERROR | wrapper | 2015/09/18 01:27:36 | JVM exited while loading the
application.

INFO | jvm 1 | 2015/09/18 01:27:36 | Error: Exception thrown by the agent :
java.net.MalformedURLException: Local host name unknown:
java.net.UnknownHostException: node24: node24: unknown error

看到了是域名的报错可能是刚刚我修改hosts文件的时候没有写本机名

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

|

`[root``@node24` `conf]#cat /etc/hosts`

`127.0``.``0.1` `localhost localhost1 localhost.localdomain localhost4
localhost4.localdomain4`

`::``1` `localhost localhost.localdomain localhost6 localhost6.localdomain6`

`10.1``.``166.22` `node22`

`10.1``.``166.22` `dn1`

`10.1``.``166.23` `dn2`

`10.1``.``166.24` `dn3 `

`10.1``.``166.25` `dn4`

`10.1``.``166.26` `dn5`

` `

`[root``@node24` `conf]#hostname`

`node24`

`[root``@node24` `conf]#cat /etc/sysconfig/network`

`NETWORKING=yes`

`HOSTNAME=node24`  
  
---|---  
  
  

所以需要改变的是

Hosts文件中需要定义node24

改为

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

`[root``@node24` `conf]#cat /etc/hosts`

`127.0``.``0.1` `node24 localhost localhost1 localhost.localdomain localhost4
localhost4.localdomain4`

`::``1` `localhost localhost.localdomain localhost6 localhost6.localdomain6`

`10.1``.``166.22` `dn1`

`10.1``.``166.23` `dn2`

`10.1``.``166.24` `dn3 node24`

`10.1``.``166.25` `dn4`

`10.1``.``166.26` `dn5`

`[root``@node24` `conf]#../bin/mycat restart `

`Stopping Mycat-server...`

`Stopped Mycat-server.`

`Starting Mycat-server...`  
  
---|---  
  
  

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

|

`[root@node24 conf]#cat ../logs/wrapper.``log`

`STATUS | wrapper | 2015/09/18 02:17:28 | TERM trapped. Shutting down.`

`STATUS | wrapper | 2015/09/18 02:17:29 | <-- Wrapper Stopped`

`STATUS | wrapper | 2015/09/18 02:17:30 | --> Wrapper Started as Daemon`

`STATUS | wrapper | 2015/09/18 02:17:30 | Launching a JVM...`

`INFO | jvm 1 | 2015/09/18 02:17:30 | Java HotSpot(TM) 64-Bit Server VM
warning: ignoring option MaxPermSize=64M; support was removed in 8.0`

`INFO | jvm 1 | 2015/09/18 02:17:31 | Wrapper (Version 3.2.3)
http:``//wrapper.tanukisoftware.org`

`INFO | jvm 1 | 2015/09/18 02:17:31 | Copyright 1999-2006 Tanuki Software,
Inc. All Rights Reserved.`

`INFO | jvm 1 | 2015/09/18 02:17:31 | `

`INFO | jvm 1 | 2015/09/18 02:17:31 | log4j 2015-09-18 02:17:31
[./conf/log4j.xml] load completed.`

`INFO | jvm 1 | 2015/09/18 02:17:32 | MyCAT Server startup successfully. see
logs in logs/mycat.``log`  
  
---|---  
  
  

### 基于案例配置

我有一张线上日志表数据海量

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

|

` `

`CREATE TABLE `zuolog` (`

` ```id` bigint(``15``) NOT NULL AUTO_INCREMENT COMMENT ``'主键自增日志id'``,`

` ```code` varchar(``30``) NOT NULL ,`

` ```con` decimal(``2``,``0``) NOT NULL ,`

` ```cons` decimal(``11``,``1``) NOT NULL ,`

` ```mon` tinyint(``2``) NOT NULL ,`

` ```chargedtype` tinyint(``2``) NOT NULL ,`

` ```targetid` decimal(``11``,``0``) NOT NULL ,`

` ```consume` datetime NOT NULL DEFAULT ``'1753-01-01 12:00:00'` `COMMENT
``'yyyy-dd-MM hh:mm:ss(消费时间)'``,`

` ```userid` bigint(``20``) NOT NULL ,`

` ```content` varchar(``300``) DEFAULT NULL,`

` ```note1` varchar(``2``) DEFAULT NULL,`

` ```note2` varchar(``2``) DEFAULT NULL,`

` ```mon` tinyint(``1``) NOT NULL DEFAULT ``'1'` `,`

` ```stauts` tinyint(``1``) NOT NULL DEFAULT ``'0'` `,`

` ``PRIMARY KEY (`id`)`

`) ENGINE=InnoDB AUTO_INCREMENT=``1564262` `DEFAULT CHARSET=utf8
COMMENT=``'消费日志'``;`  
  
---|---  
  
  

现在数据以及好几千了 所以需要mycat 负载也高所以架构图这里划一下手绘本事不大还望见谅啊

[](http://s3.51cto.com/wyfs02/M01/74/67/wKioL1Ycnh7DO92eAAJRVDT_dhs405.jpg)

### 配置文件schema.xml配置

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

132

133

134

135

136

137

138

139

140

141

142

143

144

145

146

147

148

149

150

151

152

153

154

155

156

157

158

159

160

161

162

163

164

165

166

167

168

169

170

171

|

`[root``@node24` `conf]#cat schema.xml `

`<?xml version=``"1.0"``?>`

`<!DOCTYPE mycat:schema SYSTEM ``"schema.dtd"``>`

`<mycat:schema xmlns:mycat=``"http://org.opencloudb/"``>`

` `

` ``<schema name=``"yungui"` `checkSQLschema=``"false"`
`sqlMaxLimit=``"100"``>`

`<!-- <table name=``"travelrecord"` `dataNode=``"dn1,dn2,dn3"` `rule=``"auto-
sharding-long"` `/> -->`

`<!-- <table name=``"company"` `primaryKey=``"ID"` `type=``"global"`
`dataNode=``"dn1,dn2,dn3"` `/> -->`

`<!-- <table name=``"goods"` `primaryKey=``"ID"` `type=``"global"`
`dataNode=``"dn1,dn2"` `/> -->`

` ``<!-- random sharding using mod sharind rule -->`

`<!-- <table name=``"hotnews"` `primaryKey=``"ID"` `dataNode=``"dn1,dn2,dn3"`

` ``rule=``"mod-long"` `/> -->`

` ``<!-- <table name=``"dual"` `primaryKey=``"ID"`
`dataNode=``"dnx,dnoracle2"` `type=``"global"`

` ``needAddLimit=``"false"``/> <table name=``"worker"` `primaryKey=``"ID"`
`dataNode=``"jdbc_dn1,jdbc_dn2,jdbc_dn3"`

` ``rule=``"mod-long"` `/> -->`

` ``<table name=``"employee"` `primaryKey=``"ID"` `autoIncrement=``"true"`
`dataNode=``"dn1,dn2"`

` ``rule=``"sharding-by-intfile"` `/>`

` `

` ``<table name=``"elog"` `primaryKey=``"id"` `autoIncrement=``"true"`
`dataNode=``"dn1,dn2,dn3,dn4,dn5"`

` ``rule=``"mod-long"` `/> `

` ``<table name=``"tt2"` `primaryKey=``"id"` `autoIncrement=``"true"`
`dataNode=``"dn1,dn2,dn3,dn4,dn5"` `rule=``"mod-long"` `/>`

` ``<table name=``"MYCAT_SEQUENCE"` `primaryKey=``"name"` `dataNode=``"dn1"`
`/>`

` `

` `

`<!-- <table name=``"customer"` `primaryKey=``"ID"` `dataNode=``"dn1,dn2"`

` ``rule=``"sharding-by-intfile"``> -->`

`<!-- <childTable name=``"orders"` `primaryKey=``"ID"`
`joinKey=``"customer_id"`

` ``parentKey=``"id"``> -->`

`<!-- <childTable name=``"order_items"` `joinKey=``"order_id"`

` ``parentKey=``"id"` `/> `

` ``</childTable> -->`

`<!-- <childTable name=``"customer_addr"` `primaryKey=``"ID"`
`joinKey=``"customer_id"`

` ``parentKey=``"id"` `/>`

` ``</table> -->`

` ``<!-- <table name=``"oc_call"` `primaryKey=``"ID"` `dataNode=``"dn1$0-743"`
`rule=``"latest-month-calldate"`

` ``/> -->`

` ``</schema>`

` ``<!-- <dataNode name=``"dn1$0-743"` `dataHost=``"localhost1"`
`database=``"db$0-743"`

` ``/> -->`

` ``<dataNode name=``"dn1"` `dataHost=``"10.1.166.22"` `database=``"db1"` `/>`

` ``<dataNode name=``"dn2"` `dataHost=``"10.1.166.23"` `database=``"db2"` `/>`

` ``<dataNode name=``"dn3"` `dataHost=``"10.1.166.24"` `database=``"db3"` `/>`

` ``<dataNode name=``"dn4"` `dataHost=``"10.1.166.25"` `database=``"db4"` `/>`

` ``<dataNode name=``"dn5"` `dataHost=``"10.1.166.26"` `database=``"db5"` `/>`

` ``<!--<dataNode name=``"dn4"` `dataHost=``"sequoiadb1"`
`database=``"SAMPLE"` `/>`

` ``<dataNode name=``"jdbc_dn1"` `dataHost=``"jdbchost"` `database=``"db1"`
`/> `

` ``<dataNode name=``"jdbc_dn2"` `dataHost=``"jdbchost"` `database=``"db2"`
`/> `

` ``<dataNode name=``"jdbc_dn3"` `dataHost=``"jdbchost"` `database=``"db3"`
`/> -->`

` ``<dataHost name=``"10.1.166.22"` `maxCon=``"1000"` `minCon=``"10"`
`balance=``"0"`

` ``writeType=``"0"` `dbType=``"mysql"` `dbDriver=``"native"`
`switchType=``"1"` `slaveThreshold=``"100"``>`

` ``<heartbeat>select user()</heartbeat>`

` ``<!-- can have multi write hosts -->`

` ``<writeHost host=``"hostM1"` `url=``"10.1.166.22:3306"` `user=``"root"`

` ``password=``"123456"``>`

` ``<!-- can have multi read hosts -->`

` `

` ``</writeHost>`

` ``<writeHost host=``"hostS1"` `url=``"10.1.166.22:3306"` `user=``"root"`

` ``password=``"123456"` `/>`

` ``<!-- <writeHost host=``"hostM2"` `url=``"localhost:3306"` `user=``"root"`
`password=``"123456"``/> -->`

` ``</dataHost>`

` `

` `

` `

` `

` ``<dataHost name=``"10.1.166.23"` `maxCon=``"1000"` `minCon=``"10"`
`balance=``"0"`

` ``writeType=``"0"` `dbType=``"mysql"` `dbDriver=``"native"`
`switchType=``"1"` `slaveThreshold=``"100"``>`

` ``<heartbeat>select user()</heartbeat>`

` ``<!-- can have multi write hosts -->`

` ``<writeHost host=``"hostM1"` `url=``"10.1.166.23:3306"` `user=``"root"`

` ``password=``"123456"``>`

` ``<!-- can have multi read hosts -->`

` `

` ``</writeHost>`

` ``<writeHost host=``"hostS1"` `url=``"10.1.166.23:3306"` `user=``"root"`

` ``password=``"123456"` `/>`

` ``<!-- <writeHost host=``"hostM2"` `url=``"localhost:3306"` `user=``"root"`
`password=``"123456"``/> -->`

` ``</dataHost>`

` `

` ``<dataHost name=``"10.1.166.24"` `maxCon=``"1000"` `minCon=``"10"`
`balance=``"0"`

` ``writeType=``"0"` `dbType=``"mysql"` `dbDriver=``"native"`
`switchType=``"1"` `slaveThreshold=``"100"``>`

` ``<heartbeat>select user()</heartbeat>`

` ``<!-- can have multi write hosts -->`

` ``<writeHost host=``"hostM1"` `url=``"10.1.166.24:3306"` `user=``"root"`

` ``password=``"123456"``>`

` ``<!-- can have multi read hosts -->`

` `

` ``</writeHost>`

` ``<writeHost host=``"hostS1"` `url=``"10.1.166.24:3306"` `user=``"root"`

` ``password=``"123456"` `/>`

` ``<!-- <writeHost host=``"hostM2"` `url=``"localhost:3306"` `user=``"root"`
`password=``"123456"``/> -->`

` ``</dataHost>`

` `

` `

` ``<dataHost name=``"10.1.166.25"` `maxCon=``"1000"` `minCon=``"10"`
`balance=``"0"`

` ``writeType=``"0"` `dbType=``"mysql"` `dbDriver=``"native"`
`switchType=``"1"` `slaveThreshold=``"100"``>`

` ``<heartbeat>select user()</heartbeat>`

` ``<!-- can have multi write hosts -->`

` ``<writeHost host=``"hostM1"` `url=``"10.1.166.25:3306"` `user=``"root"`

` ``password=``"123456"``>`

` ``<!-- can have multi read hosts -->`

` `

` ``</writeHost>`

` ``<writeHost host=``"hostS1"` `url=``"10.1.166.25:3306"` `user=``"root"`

` ``password=``"123456"` `/>`

` ``<!-- <writeHost host=``"hostM2"` `url=``"localhost:3306"` `user=``"root"`
`password=``"123456"``/> -->`

` ``</dataHost>`

` `

` `

` ``<dataHost name=``"10.1.166.26"` `maxCon=``"1000"` `minCon=``"10"`
`balance=``"0"`

` ``writeType=``"0"` `dbType=``"mysql"` `dbDriver=``"native"`
`switchType=``"1"` `slaveThreshold=``"100"``>`

` ``<heartbeat>select user()</heartbeat>`

` ``<!-- can have multi write hosts -->`

` ``<writeHost host=``"hostM1"` `url=``"10.1.166.26:3306"` `user=``"root"`

` ``password=``"123456"``>`

` ``<!-- can have multi read hosts -->`

` `

` ``</writeHost>`

` ``<writeHost host=``"hostS1"` `url=``"10.1.166.26:3306"` `user=``"root"`

` ``password=``"123456"` `/>`

` ``<!-- <writeHost host=``"hostM2"` `url=``"localhost:3306"` `user=``"root"`
`password=``"123456"``/> -->`

` ``</dataHost>`

` `

` ``<!--`

` ``<dataHost name=``"sequoiadb1"` `maxCon=``"1000"` `minCon=``"1"`
`balance=``"0"` `dbType=``"sequoiadb"` `dbDriver=``"jdbc"``> `

` ``artbeat> </heartbeat>`

` ``<writeHost host=``"hostM1"`
`url=``"sequoiadb://1426587161.dbaas.sequoialab.net:11920/SAMPLE"`
`user=``"jifeng"` `password=``"jifeng"``></writeHost> `

` ``</dataHost> `

` `

` ``<dataHost name=``"oracle1"` `maxCon=``"1000"` `minCon=``"1"`
`balance=``"0"` `writeType=``"0"` `dbType=``"oracle"` `dbDriver=``"jdbc"``>
<heartbeat>select ``1` `from dual</heartbeat> `

` ``<connectionInitSql>alter session set nls_date_format=``'yyyy-mm-dd
hh24:mi:ss'``</connectionInitSql> `

` ``<writeHost host=``"hostM1"`
`url=``"jdbc:oracle:thin:@127.0.0.1:1521:nange"` `user=``"base"`
`password=``"123456"` `> </writeHost> </dataHost> `

` `

` ``<dataHost name=``"jdbchost"` `maxCon=``"1000"` `minCon=``"1"`
`balance=``"0"` `writeType=``"0"` `dbType=``"mongodb"` `dbDriver=``"jdbc"``> `

` ``<heartbeat>select user()</heartbeat> `

` ``<writeHost host=``"hostM"` `url=``"mongodb://192.168.0.99/test"`
`user=``"admin"` `password=``"123456"` `></writeHost> </dataHost> `

` `

` ``<dataHost name=``"sparksql"` `maxCon=``"1000"` `minCon=``"1"`
`balance=``"0"` `dbType=``"spark"` `dbDriver=``"jdbc"``> `

` ``<heartbeat> </heartbeat>`

` ``<writeHost host=``"hostM1"` `url=``"jdbc:hive2://feng01:10000"`
`user=``"jifeng"` `password=``"jifeng"``></writeHost> </dataHost> -->`

` `

` ``<!-- <dataHost name=``"jdbchost"` `maxCon=``"1000"` `minCon=``"10"`
`balance=``"0"` `dbType=``"mysql"`

` ``dbDriver=``"jdbc"``> <heartbeat>select user()</heartbeat> <writeHost
host=``"hostM1"`

` ``url=``"jdbc:mysql://localhost:3306"` `user=``"root"`
`password=``"123456"``> </writeHost> `

` ``</dataHost> -->`

`</mycat:schema>`

` `

`该配置文件是出错容易最多的地方需特别注意<!-- 之间的内容表示注释 -->`

` `

`<dataNode name=``"dn1"` `dataHost=``"10.1.166.22"` `database=``"db1"` `/>`

` ``<dataNode name=``"dn2"` `dataHost=``"10.1.166.23"` `database=``"db2"` `/>`

` ``<dataNode name=``"dn3"` `dataHost=``"10.1.166.24"` `database=``"db3"` `/>`

` ``<dataNode name=``"dn4"` `dataHost=``"10.1.166.25"` `database=``"db4"` `/>`

` ``<dataNode name=``"dn5"` `dataHost=``"10.1.166.26"` `database=``"db5"` `/>`

`dataNode name 表示节点名称 dataHost表示你数据库的名称 database表示你路由的数据库的名称`

`<schema name=``"yungui"` `checkSQLschema=``"false"` `sqlMaxLimit=``"100"``>`

`schema name 表示你mycat连接后端的db1 db2 db3 db4 db5在前端显示的库名字叫yungui
，sqlMaxLimit表示显示多少`

` `

` ``<dataHost name=``"10.1.166.23"` `maxCon=``"1000"` `minCon=``"10"`
`balance=``"0"`

` ``writeType=``"0"` `dbType=``"mysql"` `dbDriver=``"native"`
`switchType=``"1"` `slaveThreshold=``"100"``>`

` ``<heartbeat>select user()</heartbeat>`

` ``<!-- can have multi write hosts -->`

` ``<writeHost host=``"hostM1"` `url=``"10.1.166.23:3306"` `user=``"root"`

` ``password=``"123456"``>`

` ``<!-- can have multi read hosts -->`

` `

` ``</writeHost>`

` ``<writeHost host=``"hostS1"` `url=``"10.1.166.23:3306"` `user=``"root"`

` ``password=``"123456"` `/>`

` ``<!-- <writeHost host=``"hostM2"` `url=``"localhost:3306"` `user=``"root"`
`password=``"123456"``/> -->`

` ``</dataHost>`  
  
---|---  
  
  

为一个数据库实例的配置

balance="0"

参数balance决定了哪些MySQL服务器参与到读SQL的负

载均衡中，0为不开启读写分离，

1为全部的readHost与standby writeHost参与select语句的负载均衡，比如我们配置了1主3从的MySQL主从环境，并把第一个

从节点MySQL配置为dataHost中的第二个writeHost，以便主节点宕机后，Mycat自动切换到这个writeHost上来执行写操作，

此时balance=1就意味着第一个writeHost不参与读SQL的负载均衡，其他3个都参与；balance=2则表示所有的writeHost不参

与，此时，只有2个readHost参与负载均衡。这里有一个细节需要你知道，readHost是从属于writeHost的，即意味着它从那个

writeHost获取同步数据，因此，当它所属的writeHost宕机了，则它也不会再参与到读写分离中来，即“不工作了”，这是因为

此时，它的数据已经“不可靠”了。基于这个考虑，目前mycat 1.3和1.4版本中，若想支持MySQL一主一从的标准配置，并且在

主节点宕机的情况下，从节点还能读取数据，则需要在Mycat里配置为两个writeHost并设置banlance=1。

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

|

`<dataHost name=``"localhost1"` `maxCon=``"1000"` `minCon=``"10"`
`balance=``"1"`

`writeType=``"0"` `dbType=``"mysql"` `dbDriver=``"native"``>`

`<heartbeat>select user()</heartbeat>`

`<!-- can have multi write hosts -->`

`<writeHost host=``"hostM1"` `url=``"localhost:3306"` `user=``"root"`

`password=``"123456"``>`

`<!-- can have multi read hosts -->`

`<readHost host=``"hostS1"` `url=``"localhost2:3306"` `user=``"root"`
`password=``"123456"`

`/>`

`</writeHost>`

`</dataHost>`  
  
---|---  
  
  

writeType=1仅仅对于galera for mysql集群这种多主多节点都能写入的集群起效，此时Mycat会随机选择一个writeHost并写

入数据，对于非galera for mysql集群，请不要配置writeType=1，会导致数据库不一致的严重问题。

Mycat目前支持自动方式、编程指定的两种读写分离方式：

自动方式，即一个查询SQL是自动提交模式，对应于connection.setAutocommit(true) 或者 set autocommit=1

编程指定方式，即一个查询SQL语句以/*balance*/注解来确定其是走读节点还是写节点。在1.3版本里，若事务内的的查询语

句增加此注解，则强制其走读节点，而1.4版本里继续强化，可以在非事务内的查询语句前增加此注解，强制走写节点，这个

增强是为了避免主从不同步的情况下要求查询到刚写入的数据而做的增强。

另外 1.4开始支持MySQL主从复制状态绑定的读写分离机制，让读更加安全可靠，配置如下：

MyCAT心跳检查语句配置为 show slave status ，dataHost 上定义两个新属性： switchType="2" 与

slaveThreshold="100"，此时意味着开启MySQL主从复制状态绑定的读写分离与切换机制，Mycat心跳机制通过检测 show

slave status 中的 "Seconds_Behind_Master", "Slave_IO_Running",
"Slave_SQL_Running" 三个字段来确定当前主从同步

的状态以及Seconds_Behind_Master主从复制时延，

当Seconds_Behind_Master>slaveThreshold时，读写分离筛选器会过滤掉此Slave机器，防止读到很久之前的旧数据，而当主

节点宕机后，切换逻辑会检查Slave上的Seconds_Behind_Master是否为0，为0时则表示主从同步，可以安全切换，否则不会

切换。

switchType 目前有三种选择：

\- -1 表示不自动切换

\- 1 默认值，自动切换

\- 2 基于MySQL主从同步的状态决定是否切换

下面为参考配置：

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

|

`<dataHost name=``"localhost1"` `maxCon=``"1000"` `minCon=``"10"`
`balance=``"0"`

`writeType=``"0"` `dbType=``"mysql"` `dbDriver=``"native"` `switchType=``"2"`
`slaveThreshold=``"100"``>`

`<heartbeat>show slave status </heartbeat>`

`<!-- can have multi write hosts -->`

`<writeHost host=``"hostM1"` `url=``"localhost:3306"` `user=``"root"`

`password=``"123456"``>`

`<!-- can have multi read hosts -->`

`</writeHost>`

`<writeHost host=``"hostS1"` `url=``"localhost:3316"` `user=``"root"`

`password=``"123456"` `/>`

`《/ddataHost>`  
  
---|---  
  
  

conf/log4j.xml中配置日志输出级别为debug时，当选择节点的时候，会输出如下日志：

1

2

3

4

|

`16:37:21.660 DEBUG [Processor0-E3] (PhysicalDBPool.java:333) -select read
source hostM1 ``for`

`dataHost:localhost1`

`16:37:21.662 DEBUG [Processor0-E3] (PhysicalDBPool.java:333) -select read
source hostM1 ``for`

`dataHost:localhost1`  
  
---|---  
  
  

根据这个信息，可以确定某个SQL发往了哪个读（写）节点，据此可以分析判断是否发生了读写分离。

用MySQL客户端连接到Mycat的9066管理端口，执行show @@datanode ，也能看出负载均衡的情况，其中execute字段表明该分

片上执行过的SQL累计数：

![输入图片说明](http://static.oschina.net/uploads/img/201504/07212301_4ZPx.jpg
"在这里输入图片标题")

至于应用中的哪些数据查询比较适合开启读写分离，总结下来大概有以下几种：

\- 列表界面，通常是浏览查询功能，这类的数据访问频繁但实时性要求比较低，有几秒几十秒的延迟，通常感觉不出来，淘

宝界面里，已售出的商品个数往往比商家后台看到的数据要延迟很大，也说明了它是一个快照数据

\- 某个数据的详细信息页面，通常也访问较为频繁，但事实性要求不高

\- 历史时刻的数据，比如昨天的数据，上个月的，这种数据即使有修改，也概率很低

Mycat的读写分离，默认是按照该SQL是否有事务包裹，由于一些高层框架如Hibernate、Spring等往往会自动追加事务控制语

句，将查询语句变成事务内的语句，当你开启Mycat Debug日志级别后，就可能很清楚的看到这一点，日志中会出现如下的序

列，此时不会走读写分离，因此建议程序设计的时候，手工控制事务，让这些查询语句自动提交，这个做法也有利于加快

MySQL的执行过程

set autocomomit=0

…

select *

commit

```

因为我是percona集群无需配置读写分离什么的了

### Mysql授权以及配置文件

配置文件加入如下两句

1

2

|

`log_bin_trust_function_creators=``1`

`lower_case_table_names = ``1`  
  
---|---  
  
  

在每一台schema.xml配置文件定义过得mysql上授权如下

1

2

3

4

|

`GRANT ALL PRIVILEGES ON *.* TO ``'root'``@``'10.1.166.%'` `IDENTIFIED BY
``'123456'` `WITH GRANT OPTION ;`

`GRANT ALL PRIVILEGES ON *.* TO ``'root'``@``'127.0.0.1'` `IDENTIFIED BY
``'123456'` `WITH GRANT OPTION;`

` ``GRANT ALL PRIVILEGES ON *.* TO ``'root'``@``'localhost'` `IDENTIFIED BY
``'123456'` `WITH GRANT OPTION ;`

` ``flush privileges;`  
  
---|---  
  
  

这里的密码与上面配置文件的密码相对应

如果授权错误则会报错

### 配置数据名密码

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

|

`[root``@node24` `conf]#vi server.xml `

` `

`<?xml version=``"1.0"` `encoding=``"UTF-8"``?>`

`<!-- - - Licensed under the Apache License, Version ``2.0` `(the
``"License"``);`

` ``- you may not use ``this` `file except in compliance with the License. -
You`

` ``distributed under the License is distributed on an ``"AS IS"` `BASIS, -
WITHOUT`

` ``WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. - See
the`

` ``License ``for` `the specific language governing permissions and -
limitations`

` ``under the License. -->`

`<!DOCTYPE mycat:server SYSTEM ``"server.dtd"``>`

`<mycat:server xmlns:mycat=``"http://org.opencloudb/"``>`

` ``<system>`

` ``<property name=``"defaultSqlParser"``>druidparser</property>`

` ``<!-- <property name=``"useCompression"``>``1``</property>-->
<!--``1``为开启mysql压缩协议-->`

` ``<!-- <property name=``"processorBufferChunk"``>``40960``</property> -->`

` ``<!--`

` ``<property name=``"processors"``>``1``</property>`

` ``<property name=``"processorExecutor"``>``32``</property>`

` ``-->`

` ``<!--默认是``65535` `64K 用于sql解析时最大文本长度 -->`

` ``<!--<property name=``"maxStringLiteralLength"``>``65535``</property>-->`

` ``<!--<property name=``"sequnceHandlerType"``>``0``</property>-->`

` ``<!--<property name=``"backSocketNoDelay"``>``1``</property>-->`

` ``<!--<property name=``"frontSocketNoDelay"``>``1``</property>-->`

` ``<!--<property name=``"processorExecutor"``>``16``</property>-->`

` ``<!--`

` ``<property name=``"mutiNodeLimitType"``>``1``</property> ``0``：开启小数量级（默认）
；``1``：开启亿级数据排序`

` ``<property name=``"mutiNodePatchSize"``>``100``</property> 亿级数量排序批量`

` ``<property name=``"processors"``>``32``</property> <property
name=``"processorExecutor"``>``32``</property>`

` ``<property name=``"serverPort"``>``8066``</property> <property
name=``"managerPort"``>``9066``</property>`

` ``<property name=``"idleTimeout"``>``300000``</property> <property
name=``"bindIp"``>``0.0``.``0.0``</property>`

` ``<property name=``"frontWriteQueueSize"``>``4096``</property> <property
name=``"processors"``>``32``</property>`

` ``-->`

` ``</system>`

` ``<user name=``"adminz"``>`

` ``<property name=``"password"``>xinchengyungui</property>`

` ``<property name=``"schemas"``>yungui</property>`

` ``</user>`

` `

` ``<user name=``"adminz"``>`

` ``<property name=``"password"``>xinchengyungui</property>`

` ``<property name=``"schemas"``>yungui</property>`

` ``<property name=``"readOnly"``>``true``</property>`

` ``</user>`

` ``<!-- <cluster> <node name=``"cobar1"``> <property
name=``"host"``>``127.0``.``0.1``</property>`

` ``<property name=``"weight"``>``1``</property> </node> </cluster> -->`

` ``<!-- <quarantine> <host name=``"1.2.3.4"``> <property
name=``"user"``>test</property>`

` ``</host> </quarantine> -->`

` `

`</mycat:server>`  
  
---|---  
  
  

### 配置节点数

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

132

133

134

135

136

137

138

139

140

141

142

143

144

145

146

147

148

149

150

151

152

153

154

155

156

157

158

159

160

161

162

163

164

165

166

167

168

169

170

171

|

`[root@node22 conf]``#vi rule.xml `

` `

`<?xml version=``"1.0"` `encoding=``"UTF-8"``?>`

`<!-- - - Licensed under the Apache License, Version 2.0 (the ``"License"``);`

` ``- you may not use this ``file` `except ``in` `compliance with the License.
- You`

` ``may obtain a copy of the License at - -
http:``//www``.apache.org``/licenses/LICENSE-2``.0`

` ``- - Unless required by applicable law or agreed to ``in` `writing,
software -`

` ``distributed under the License is distributed on an ``"AS IS"` `BASIS, -
WITHOUT`

` ``WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. - See
the`

` ``License ``for` `the specific language governing permissions and -
limitations`

` ``under the License. -->`

`<!DOCTYPE mycat:rule SYSTEM ``"rule.dtd"``>`

`<mycat:rule xmlns:mycat=``"http://org.opencloudb/"``>`

` ``<tableRule name=``"rule1"``>`

` ``<rule>`

` ``<columns>``id``<``/columns``>`

` ``<algorithm>func1<``/algorithm``>`

` ``<``/rule``>`

` ``<``/tableRule``>`

` `

` ``<tableRule name=``"rule2"``>`

` ``<rule>`

` ``<columns>user_id<``/columns``>`

` ``<algorithm>func1<``/algorithm``>`

` ``<``/rule``>`

` ``<``/tableRule``>`

` `

` ``<tableRule name=``"sharding-by-intfile"``>`

` ``<rule>`

` ``<columns>sharding_id<``/columns``>`

`/5`

` ``<``/rule``>`

` ``<``/tableRule``>`

` `

` ``<tableRule name=``"jch"``>`

` ``<rule>`

` ``<columns>``id``<``/columns``>`

` ``<algorithm>jump-consistent-``hash``<``/algorithm``>`

` ``<``/rule``>`

` ``<``/tableRule``>`

` `

` ``<``function` `name=``"murmur"`

` ``class=``"org.opencloudb.route.function.PartitionByMurmurHash"``>`

` ``<property name=``"seed"``>0<``/property``><!-- 默认是0 -->`

` ``<property name=``"count"``>5<``/property``><!-- 要分片的数据库节点数量，必须指定，否则没法分片
-->`

` ``<property name=``"virtualBucketTimes"``>160<``/property``><!--
一个实际的数据库节点被映射为这么多虚拟节点，默>`

`认是160倍，也就是虚拟节点数是物理节点数的160倍 -->`

` ``<!-- <property name=``"weightMapFile"``>weightMapFile<``/property``>
节点的权重，没有指定权重的节点默认是1。以`

`properties文件的格式填写，以从0开始到count-1的整数值也就是节点索引为key，以节点权重值为值。所有权重值必须是正整数，否>`

`则以1代替 -->`

` ``<!-- <property
name=``"bucketMapPath"``>``/etc/mycat/bucketMapPath``<``/property``>`

` ``用于测试时观察各物理节点与虚拟节点的分布情况，如果指定了这个属性，会把虚拟节点的murmur ``hash``值>`

`与物理节点的映射按行输出到这个文件，没有默认值，如果不指定，就不会输出任何东西 -->`

` ``<``/function``>`

` ``<``function` `name=``"hash-int"`

` ``class=``"org.opencloudb.route.function.PartitionByFileMap"``>`

` ``<property name=``"mapFile"``>partition-``hash``-int.txt<``/property``>`

` ``<``/function``>`

` ``<``function` `name=``"rang-long"`

`[root@node22 conf]``#vi rule.xml `

` `

`<?xml version=``"1.0"` `encoding=``"UTF-8"``?>`

`<!-- - - Licensed under the Apache License, Version 2.0 (the ``"License"``);`

` ``- you may not use this ``file` `except ``in` `compliance with the License.
- You`

` ``may obtain a copy of the License at - -
http:``//www``.apache.org``/licenses/LICENSE-2``.0`

` ``- - Unless required by applicable law or agreed to ``in` `writing,
software -`

` ``distributed under the License is distributed on an ``"AS IS"` `BASIS, -
WITHOUT`

` ``WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. - See
the`

` ``License ``for` `the specific language governing permissions and -
limitations`

` ``under the License. -->`

`<!DOCTYPE mycat:rule SYSTEM ``"rule.dtd"``>`

`<mycat:rule xmlns:mycat=``"http://org.opencloudb/"``>`

` ``<tableRule name=``"rule1"``>`

` ``<rule>`

` ``<columns>``id``<``/columns``>`

` ``<algorithm>func1<``/algorithm``>`

` ``<``/rule``>`

` ``<``/tableRule``>`

` `

` ``<tableRule name=``"rule2"``>`

` ``<rule>`

` ``<columns>user_id<``/columns``>`

` ``<algorithm>func1<``/algorithm``>`

` ``<``/rule``>`

` ``<``/tableRule``>`

` `

` ``<tableRule name=``"sharding-by-intfile"``>`

` ``<rule>`

` ``<columns>sharding_id<``/columns``>`

` ``<algorithm>``hash``-int<``/algorithm``>`

` ``<``/rule``>`

` ``<``/tableRule``>`

` ``<tableRule name=``"auto-sharding-long"``>`

` ``<rule>`

` ``<columns>``id``<``/columns``>`

` ``<algorithm>rang-long<``/algorithm``>`

` ``<``/rule``>`

` ``<``/tableRule``>`

` ``<tableRule name=``"mod-long"``>`

` ``<rule>`

` ``<columns>``id``<``/columns``>`

` ``<algorithm>mod-long<``/algorithm``>`

` ``<``/rule``>`

` ``<``/tableRule``>`

` ``<tableRule name=``"sharding-by-murmur"``>`

` ``<rule>`

` ``<columns>``id``<``/columns``>`

` ``<algorithm>murmur<``/algorithm``>`

` ``<``/rule``>`

` ``<``/tableRule``>`

` ``<tableRule name=``"sharding-by-month"``>`

` ``<rule>`

` ``<columns>create_date<``/columns``>`

` ``<columns>calldate<``/columns``>`

` ``<``/tableRule``>`

` `

` ``<tableRule name=``"auto-sharding-rang-mod"``>`

` ``<rule>`

` ``<columns>``id``<``/columns``>`

` ``<algorithm>rang-mod<``/algorithm``>`

` ``<``/rule``>`

` ``<``/tableRule``>`

` `

` ``<tableRule name=``"jch"``>`

` ``<rule>`

` ``<columns>``id``<``/columns``>`

` ``<algorithm>jump-consistent-``hash``<``/algorithm``>`

` ``<``/rule``>`

` ``<``/tableRule``>`

` `

` ``<``function` `name=``"murmur"`

` ``class=``"org.opencloudb.route.function.PartitionByMurmurHash"``>`

` ``<property name=``"seed"``>0<``/property``><!-- 默认是0 -->`

` ``<property name=``"count"``>5<``/property``><!-- 这一行改成你实际分片的节点数
要分片的数据库节点数量，必须指定，否则没法分片 -->`

` ``<!-- <property
name=``"bucketMapPath"``>``/etc/mycat/bucketMapPath``<``/property``>`

` ``<``/function``>`

` ``<``function` `name=``"hash-int"`

` ``class=``"org.opencloudb.route.function.PartitionByFileMap"``>`

` ``<property name=``"mapFile"``>partition-``hash``-int.txt<``/property``>`

` ``<``/function``>`

` ``<``function` `name=``"rang-long"`

` ``class=``"org.opencloudb.route.function.AutoPartitionByLong"``>`

` ``<property name=``"mapFile"``>autopartition-long.txt<``/property``>`

` ``<``/function``>`

` ``<``function` `name=``"mod-long"`
`class=``"org.opencloudb.route.function.PartitionByMod"``>`

` ``<!-- how many data nodes -->`

` ``<property name=``"count"``>5<``/property``>`

` ``<``/function``>`

` `

` ``<``function` `name=``"func1"`
`class=``"org.opencloudb.route.function.PartitionByLong"``>`

` ``<property name=``"partitionCount"``>8<``/property``>`

` ``<property name=``"partitionLength"``>128<``/property``>`

` ``<``/function``>`

` ``<``function` `name=``"latestMonth"`

` ``class=``"org.opencloudb.route.function.LatestMonthPartion"``>`

` ``<property name=``"splitOneDay"``>24<``/property``>`

` ``<``/function``>`

` ``<``function` `name=``"partbymonth"`

` ``class=``"org.opencloudb.route.function.PartitionByMonth"``>`

` ``<property name=``"dateFormat"``>yyyy-MM-``dd``<``/property``>`

` ``<property name=``"sBeginDate"``>2015-01-01<``/property``>`

` ``<``/function``>`

` `

` ``<``function` `name=``"rang-mod"`
`class=``"org.opencloudb.route.function.PartitionByRangeMod"``>`

` ``<property name=``"mapFile"``>partition-range-mod.txt<``/property``>`

` ``<``/function``>`

` `

` ``<``function` `name=``"jump-consistent-hash"`
`class=``"org.opencloudb.route.function.PartitionByJumpConsistentHash"``>`

` ``<property name=``"totalBuckets"``>3<``/property``>`

` ``<``/function``>`

`<``/mycat``:rule>`  
  
---|---  
  
  

### 启动测试

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

|

`[root@node24 conf]#rm -rf dnindex.properties 删除掉之前原始测试启动后生成的文件里面记录了节点信息`

`[root@node24 conf]#cat ../logs/wrapper.``log`

`STATUS | wrapper | 2015/09/18 02:17:28 | TERM trapped. Shutting down.`

`STATUS | wrapper | 2015/09/18 02:17:29 | <-- Wrapper Stopped`

`STATUS | wrapper | 2015/09/18 02:17:30 | --> Wrapper Started as Daemon`

`STATUS | wrapper | 2015/09/18 02:17:30 | Launching a JVM...`

`INFO | jvm 1 | 2015/09/18 02:17:30 | Java HotSpot(TM) 64-Bit Server VM
warning: ignoring option MaxPermSize=64M; support was removed in 8.0`

`INFO | jvm 1 | 2015/09/18 02:17:31 | Wrapper (Version 3.2.3)
http:``//wrapper.tanukisoftware.org`

`INFO | jvm 1 | 2015/09/18 02:17:31 | Copyright 1999-2006 Tanuki Software,
Inc. All Rights Reserved.`

`INFO | jvm 1 | 2015/09/18 02:17:31 | `

`INFO | jvm 1 | 2015/09/18 02:17:31 | log4j 2015-09-18 02:17:31
[./conf/log4j.xml] load completed.`

`INFO | jvm 1 | 2015/09/18 02:17:32 | MyCAT Server startup successfully. see
logs in logs/mycat.``log`

`STATUS | wrapper | 2015/09/18 03:39:27 | TERM trapped. Shutting down.`

`STATUS | wrapper | 2015/09/18 03:39:28 | <-- Wrapper Stopped`

`STATUS | wrapper | 2015/09/18 03:39:29 | --> Wrapper Started as Daemon`

`STATUS | wrapper | 2015/09/18 03:39:29 | Launching a JVM...`

`INFO | jvm 1 | 2015/09/18 03:39:29 | Java HotSpot(TM) 64-Bit Server VM
warning: ignoring option MaxPermSize=64M; support was removed in 8.0`

`INFO | jvm 1 | 2015/09/18 03:39:30 | Wrapper (Version 3.2.3)
http:``//wrapper.tanukisoftware.org`

`INFO | jvm 1 | 2015/09/18 03:39:30 | Copyright 1999-2006 Tanuki Software,
Inc. All Rights Reserved.`

`INFO | jvm 1 | 2015/09/18 03:39:30 | `

`INFO | jvm 1 | 2015/09/18 03:39:30 | `

`INFO | jvm 1 | 2015/09/18 03:39:30 | WrapperSimpleApp: Encountered an error
running main: java.lang.ExceptionInInitializerError`

`INFO | jvm 1 | 2015/09/18 03:39:30 | java.lang.ExceptionInInitializerError`

`INFO | jvm 1 | 2015/09/18 03:39:30 | at
org.opencloudb.MycatStartup.main(MycatStartup.java:46)`

`INFO | jvm 1 | 2015/09/18 03:39:30 | at
sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)`

`INFO | jvm 1 | 2015/09/18 03:39:30 | at
sun.reflect.NativeMethodAccessorImpl.invoke(Unknown Source)`

`INFO | jvm 1 | 2015/09/18 03:39:30 | at
sun.reflect.DelegatingMethodAccessorImpl.invoke(Unknown Source)`

`INFO | jvm 1 | 2015/09/18 03:39:30 | at
java.lang.reflect.Method.invoke(Unknown Source)`

`INFO | jvm 1 | 2015/09/18 03:39:30 | at
org.tanukisoftware.wrapper.WrapperSimpleApp.run(WrapperSimpleApp.java:240)`

`INFO | jvm 1 | 2015/09/18 03:39:30 | at java.lang.Thread.run(Unknown Source)`

`INFO | jvm 1 | 2015/09/18 03:39:30 | Caused by:
org.opencloudb.config.util.ConfigException: user adminz duplicated!`

`INFO | jvm 1 | 2015/09/18 03:39:30 | at
org.opencloudb.config.loader.xml.XMLServerLoader.loadUsers(XMLServerLoader.java:168)`

`INFO | jvm 1 | 2015/09/18 03:39:30 | at
org.opencloudb.config.loader.xml.XMLServerLoader.load(XMLServerLoader.java:88)`

`INFO | jvm 1 | 2015/09/18 03:39:30 | at
org.opencloudb.config.loader.xml.XMLServerLoader.<init>(XMLServerLoader.java:61)`

`INFO | jvm 1 | 2015/09/18 03:39:30 | at
org.opencloudb.config.loader.xml.XMLConfigLoader.<init>(XMLConfigLoader.java:60)`

`INFO | jvm 1 | 2015/09/18 03:39:30 | at
org.opencloudb.ConfigInitializer.<init>(ConfigInitializer.java:64)`

`INFO | jvm 1 | 2015/09/18 03:39:30 | at
org.opencloudb.MycatConfig.<init>(MycatConfig.java:69)`

`INFO | jvm 1 | 2015/09/18 03:39:30 | at
org.opencloudb.MycatServer.<init>(MycatServer.java:103)`

`INFO | jvm 1 | 2015/09/18 03:39:30 | at
org.opencloudb.MycatServer.<clinit>(MycatServer.java:72)`

`INFO | jvm 1 | 2015/09/18 03:39:30 | ... 7 more`

`STATUS | wrapper | 2015/09/18 03:39:32 | <-- Wrapper Stopped`  
  
---|---  
  
  

[root@node24 conf]#cat ../logs/mycat.log

看到如上的报错

1

2

3

4

5

6

|

`at java.lang.Thread.run(Unknown Source)`

`是第二个这个不能改`

`<user name=``"user"``>`

` ``<property name=``"password"``>user</property>`

` ``<property name=``"schemas"``>yungui</property>`

` ``<property name=``"readOnly"``>``true``</property>`  
  
---|---  
  
  

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

|

`[root@node24 conf]``#cat server.xml `

`<?xml version=``"1.0"` `encoding=``"UTF-8"``?>`

`<!-- - - Licensed under the Apache License, Version 2.0 (the ``"License"``);
`

` ``- you may not use this ``file` `except ``in` `compliance with the License.
- You `

` ``may obtain a copy of the License at - -
http:``//www``.apache.org``/licenses/LICENSE-2``.0 `

` ``- - Unless required by applicable law or agreed to ``in` `writing,
software - `

` ``distributed under the License is distributed on an ``"AS IS"` `BASIS, -
WITHOUT `

` ``WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. - See the
`

` ``License ``for` `the specific language governing permissions and -
limitations `

` ``under the License. -->`

`<!DOCTYPE mycat:server SYSTEM ``"server.dtd"``>`

`<mycat:server xmlns:mycat=``"http://org.opencloudb/"``>`

` ``<system>`

` ``<property name=``"defaultSqlParser"``>druidparser<``/property``>`

` ``<!-- <property name=``"useCompression"``>1<``/property``>--> <!--
1为开启mysql压缩协议-->`

` ``<!-- <property name=``"processorBufferChunk"``>40960<``/property``> -->`

` ``<!-- `

` ``<property name=``"processors"``>1<``/property``> `

` ``<property name=``"processorExecutor"``>32<``/property``> `

` ``-->`

` ``<!--默认是65535 64K 用于sql解析时最大文本长度 -->`

` ``<!--<property name=``"maxStringLiteralLength"``>65535<``/property``>-->`

` ``<!--<property name=``"sequnceHandlerType"``>0<``/property``>-->`

` ``<!--<property name=``"backSocketNoDelay"``>1<``/property``>-->`

` ``<!--<property name=``"frontSocketNoDelay"``>1<``/property``>-->`

` ``<!--<property name=``"processorExecutor"``>16<``/property``>-->`

` ``<!-- `

` ``<property name=``"mutiNodeLimitType"``>1<``/property``> 0：开启小数量级（默认）
；1：开启亿级数据排序`

` ``<property name=``"mutiNodePatchSize"``>100<``/property``> 亿级数量排序批量`

` ``<property name=``"processors"``>32<``/property``> <property
name=``"processorExecutor"``>32<``/property``> `

` ``<property name=``"serverPort"``>8066<``/property``> <property
name=``"managerPort"``>9066<``/property``> `

` ``<property name=``"idleTimeout"``>300000<``/property``> <property
name=``"bindIp"``>0.0.0.0<``/property``> `

` ``<property name=``"frontWriteQueueSize"``>4096<``/property``> <property
name=``"processors"``>32<``/property``> -->`

` ``<``/system``>`

` ``<user name=``"adminz"``>`

` ``<property name=``"password"``>xinchengyungui<``/property``>`

` ``<property name=``"schemas"``>yungui<``/property``>`

` ``<``/user``>`  
  
---|---  
  
  

<user name="user">

<property name="password">user</property>

<property name="schemas">yungui</property>

<property name="readOnly">true</property>

</user>

1

2

3

4

5

6

|

` ``<!-- <cluster> <node name=``"cobar1"``> <property
name=``"host"``>127.0.0.1<``/property``> `

` ``<property name=``"weight"``>1<``/property``> <``/node``> <``/cluster``>
-->`

` ``<!-- <quarantine> <host name=``"1.2.3.4"``> <property
name=``"user"``>``test``<``/property``> `

` ``<``/host``> <``/quarantine``> -->`

` `

`<``/mycat``:server>`  
  
---|---  
  
  

再起启动成功。

1

2

3

4

5

6

7

8

|

`[root@node24 conf]``#cat dnindex.properties `

`#update`

`#Fri Sep 18 03:58:06 CST 2015`

`10.1.166.26=0`

`10.1.166.25=0`

`10.1.166.24=0`

`10.1.166.23=0`

`10.1.166.22=0`  
  
---|---  
  
  

生成新的这个文件

### 创建表

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

|

`mysql -uadminz -pzuo123 -h127.0.0.1 -P8066 -Dyungui`

`mysql> show databases;`

`+----------+`

`| DATABASE |`

`+----------+`

`| yungui |`

`+----------+`

`1 row ``in` `set` `(0.00 sec)`

`explain create table employee (``id` `int not null primary key,name
varchar(100),sharding_id int not null);`

`create table employee (``id` `int not null primary key,name
varchar(100),sharding_id int not null);`

`insert into employee(``id``,name,sharding_id) values(1,``'leader
us'``,10000);`

`insert into employee(``id``,name,sharding_id) values(2, ``'me'``,10010);`

`insert into employee(``id``,name,sharding_id) values(3, ``'mycat'``,10000);`

`insert into employee(``id``,name,sharding_id) values(4, ``'mydog'``,10010);`  
  
---|---  
  
  

发现在db1 db2中果然有数据了 说明没问题

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

|

`CREATE TABLE `zuolog` (`

` ```id` bigint(``15``) NOT NULL AUTO_INCREMENT COMMENT ``'主键自增日志id'``,`

` ```code` varchar(``30``) NOT NULL ,`

` ```con` decimal(``2``,``0``) NOT NULL ,`

` ```cons` decimal(``11``,``1``) NOT NULL ,`

` ```mon` tinyint(``2``) NOT NULL ,`

` ```chargedtype` tinyint(``2``) NOT NULL ,`

` ```targetid` decimal(``11``,``0``) NOT NULL ,`

` ```consume` datetime NOT NULL DEFAULT ``'1753-01-01 12:00:00'` `COMMENT
``'yyyy-dd-MM hh:mm:ss(消费时间)'``,`

` ```userid` bigint(``20``) NOT NULL ,`

` ```content` varchar(``300``) DEFAULT NULL,`

` ```note1` varchar(``2``) DEFAULT NULL,`

` ```note2` varchar(``2``) DEFAULT NULL,`

` ```mon` tinyint(``1``) NOT NULL DEFAULT ``'1'` `,`

` ```stauts` tinyint(``1``) NOT NULL DEFAULT ``'0'` `,`

` ``PRIMARY KEY (`id`)`

`) ENGINE=InnoDB AUTO_INCREMENT=``1564262` `DEFAULT CHARSET=utf8
COMMENT=``'消费日志'``;`  
  
---|---  
  
  

1

2

3

4

5

6

|

`mysql> INSERT INTO `elog` (```id```, `code`, `con`, `cons`, `mon`,
`chargedtype`, `targetid`, `consume`, `userid`, `content`, `note1`, `note2`,
`mon`, `stauts`) VALUES (``'1945'``, ``'118271404223146566920190'``, ``'0'``,
``'-0.5'``, ``'0'``, ``'0'``, ``'10214131'``, ``'2014-07-03 09:43:13'``,
``'347'``, NULL, NULL, NULL, ``'1'``, ``'0'``); `

`Query OK, 1 row affected (0.01 sec)`

` `

`mysql> INSERT INTO `elog` (```id```, `code`, `con`, `cons`, `mon`,
`chargedtype`, `targetid`, `consume`, `userid`, `content`, `note1`, `note2`,
`mon`, `stauts`) VALUES (``'1945'``, ``'118271404223146566920190'``, ``'0'``,
``'-0.5'``, ``'0'``, ``'0'``, ``'10214131'``, ``'2014-07-03 09:43:13'``,
``'347'``, NULL, NULL, NULL, ``'1'``, ``'0'``); `

`ERROR 1003 (HY000): mycat sequnce err.java.lang.NumberFormatException: null`

`mysql>`  
  
---|---  
  
  

上面是什么问题呢？去除id列插入就报错了 这说明了 自增主键不能自增

### 自增主键

1\. 配置server.xml  开启数据库层面设计的自增主键 还有基于本地的和catle的 但是我这里用基于数据库的也是mycat作者推荐的方式

<property name="sequnceHandlerType">1</property>

[](http://s3.51cto.com/wyfs02/M02/74/6B/wKiom1YcoLegk7D_AALg-TcK91I467.jpg)

2\. 配置sequence_db_conf.properties

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

` ``[root@node24 conf]``#vi sequence_db_conf.properties `

`#sequence stored in datanode`

`GLOBAL=dn1`

`COMPANY=dn1`

`CUSTOMER=dn1`

`ORDERS=dn1`

`tt2=dn1`

`TT2=dn1`

`elog=dn1`

`ELOG=dn1`  
  
---|---  
  
  

~

重启mycat

1

2

3

4

5

6

|

`tail -f /usr/local/mycat/logs/mycat.``log`

`09/18 06:38:49.139 INFO [Timer1] (PhysicalDatasource.java:373) -not ilde
connection in pool,create ``new` `connection ``for` `hostS1 of schema db5`

`09/18 06:38:49.140 INFO [Timer1] (PhysicalDatasource.java:373) -not ilde
connection in pool,create ``new` `connection ``for` `hostS1 of schema db4`

`09/18 06:38:49.149 INFO [Timer1] (PhysicalDatasource.java:373) -not ilde
connection in pool,create ``new` `connection ``for` `hostS1 of schema db3`

`09/18 06:38:49.150 INFO [Timer1] (PhysicalDatasource.java:373) -not ilde
connection in pool,create ``new` `connection ``for` `hostS1 of schema db2`

`09/18 06:38:49.152 INFO [Timer1] (PhysicalDatasource.java:373) -not ilde
connection in pool,create ``new` `connection ``for` `hostS1 of schema db1`  
  
---|---  
  
  

通过本地方式连接

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

|

`[root@node24 conf]``#mysql -p123456`

`Warning: Using a password on the ``command` `line interface can be insecure.`

`Welcome to the MySQL monitor. Commands end with ; or \g.`

`Your MySQL connection ``id` `is 135`

`Server version: 5.6.22-log MySQL Community Server (GPL)`

` `

`Copyright (c) 2000, 2014, Oracle and``/or` `its affiliates. All rights
reserved.`

` `

`Oracle is a registered trademark of Oracle Corporation and``/or` `its`

`affiliates. Other names may be trademarks of their respective`

`owners.`

` `

`Type ``'help;'` `or ``'\h'` `for` `help. Type ``'\c'` `to ``clear` `the
current input statement.`

` `

`下面的操作需在每一台数据库实例上做`

`mysql> `

` `

`DROP TABLE IF EXISTS MYCAT_SEQUENCE; `

`DROP FUNCTION IF EXISTS `mycat_seq_nextval`; `

`DROP FUNCTION IF EXISTS `mycat_seq_setval`;`

`DROP FUNCTION IF EXISTS `mycat_seq_setval`;`

`CREATE TABLE MYCAT_SEQUENCE ( name VARCHAR(50) NOT NULL, current_value INT
NOT NULL, increment INT NOT NULL DEFAULT 100, PRIMARY KEY (name) )
ENGINE=InnoDB;`

` `

`-- ----------------------------`

`-- Function structure ``for` ``mycat_seq_currval``

`-- ----------------------------`

`DROP FUNCTION IF EXISTS `mycat_seq_currval`;`

`DELIMITER ;;`

`CREATE FUNCTION `mycat_seq_currval`(seq_name VARCHAR(50)) RETURNS varchar(64)
CHARSET latin1`

` ``DETERMINISTIC`

`BEGIN `

` ``DECLARE retval VARCHAR(64);`

` ``SET retval=``"-999999999,null"``; `

` ``SELECT concat(CAST(current_value AS CHAR),``","``,CAST(increment AS CHAR)
) INTO retval FROM MYCAT_SEQUENCE WHERE name = seq_name; `

` ``RETURN retval ; `

`END`

`;;`

`DELIMITER ;`

` `

`-- ----------------------------`

`-- Function structure ``for` ``mycat_seq_nextval``

`-- ----------------------------`

`DROP FUNCTION IF EXISTS `mycat_seq_nextval`;`

`DELIMITER ;;`

`CREATE FUNCTION `mycat_seq_nextval`(seq_name VARCHAR(50)) RETURNS varchar(64)
CHARSET latin1`

` ``DETERMINISTIC`

`BEGIN `

` ``UPDATE MYCAT_SEQUENCE `

` ``SET current_value = current_value + increment WHERE name = seq_name; `

` ``RETURN mycat_seq_currval(seq_name); `

`END`

`;;`

`DELIMITER ;`

` `

`-- ----------------------------`

`-- Function structure ``for` ``mycat_seq_setval``

`-- ----------------------------`

`DROP FUNCTION IF EXISTS `mycat_seq_setval`;`

`DELIMITER ;;`

`CREATE FUNCTION `mycat_seq_setval`(seq_name VARCHAR(50), value INTEGER)
RETURNS varchar(64) CHARSET latin1`

` ``DETERMINISTIC`

`BEGIN `

` ``UPDATE MYCAT_SEQUENCE `

` ``SET current_value = value `

` ``WHERE name = seq_name; `

` ``RETURN mycat_seq_currval(seq_name); `

`END`

`;;`

`DELIMITER ;`  
  
---|---  
  
  

如果你登录Mycat查出来是这样的强调是登录mycat

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

`SELECT MYCAT_SEQ_SETVAL(``'GLOBAL'``, 1);`

`SELECT MYCAT_SEQ_CURRVAL(``'GLOBAL'``);`

`SELECT MYCAT_SEQ_NEXTVAL(``'GLOBAL'``);`

` `

`mysql> SELECT MYCAT_SEQ_NEXTVAL(``'GLOBAL'``);`

`+-----------------------------+`

`| MYCAT_SEQ_NEXTVAL(``'GLOBAL'``) |`

`+-----------------------------+`

`| -999999999,null |`

`+-----------------------------+`

`1 row ``in` `set` `(0.00 sec)`

` `

`mysql> SELECT MYCAT_SEQ_NEXTVAL(``'GLOBAL'``);`

`+-----------------------------+`

`| MYCAT_SEQ_NEXTVAL(``'GLOBAL'``) |`

`+-----------------------------+`

`| 100,100 |`

`+-----------------------------+`

`1 row ``in` `set` `(0.00 sec)`  
  
---|---  
  
  

有-99999999，null那么证明你是通过mycat登录上去做了以上操作的或者没有在每一台上做操作代表失败了

你最好通过本地登录在所有mycat配置文件配置的数据库实例也是就10.1.166.22 10.1.166.23 10.1.166.24
10.1.166.25上都做这样的操作

那么最后显示应该是这样的

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

|

`[root@node24 conf]``#mysql -uadminz -pxinchengyungui -h127.0.0.1 -P8066
-Dyungui`

`Warning: Using a password on the ``command` `line interface can be insecure.`

`Welcome to the MySQL monitor. Commands end with ; or \g.`

`Your MySQL connection ``id` `is 4`

`Server version: 5.5.8-mycat-1.4-RELEASE-20150901112004 MyCat Server
(OpenCloundDB)`

` `

`Copyright (c) 2000, 2014, Oracle and``/or` `its affiliates. All rights
reserved.`

` `

`Oracle is a registered trademark of Oracle Corporation and``/or` `its`

`affiliates. Other names may be trademarks of their respective`

`owners.`

` `

`Type ``'help;'` `or ``'\h'` `for` `help. Type ``'\c'` `to ``clear` `the
current input statement.`

` `

`mysql> SELECT MYCAT_SEQ_NEXTVAL(``'GLOBAL'``);`

`+-----------------------------+`

`| MYCAT_SEQ_NEXTVAL(``'GLOBAL'``) |`

`+-----------------------------+`

`| 201,100 |`

`+-----------------------------+`

`1 row ``in` `set` `(0.00 sec)`

` `

`mysql> SELECT MYCAT_SEQ_NEXTVAL(``'GLOBAL'``);`

`+-----------------------------+`

`| MYCAT_SEQ_NEXTVAL(``'GLOBAL'``) |`

`+-----------------------------+`

`| 201,100 |`

`+-----------------------------+`

`1 row ``in` `set` `(0.00 sec)`

` `

`mysql> SELECT MYCAT_SEQ_NEXTVAL(``'GLOBAL'``);`

`+-----------------------------+`

`| MYCAT_SEQ_NEXTVAL(``'GLOBAL'``) |`

`+-----------------------------+`

`| 301,100 |`

`+-----------------------------+`

`1 row ``in` `set` `(0.00 sec)`

` `

`mysql> SELECT MYCAT_SEQ_NEXTVAL(``'GLOBAL'``);`

`+-----------------------------+`

`| MYCAT_SEQ_NEXTVAL(``'GLOBAL'``) |`

`+-----------------------------+`

`| 201,100 |`

`+-----------------------------+`  
  
---|---  
  
  

这就正常了

我里面配置文件翻翻上面我设置了一个测试表tt2

这里我登上mycat

插入一条

1

|

`mysql> insert into mycat_sequence values(``'TT2'``,0,1);`  
  
---|---  
  
这一条是定义TT2为tt2表从0开始自增长每次增长数为1 如果没有这个就会报错如下：  

1

2

3

4

5

6

|

`mysql> delete from mycat_sequence; `

`mysql> insert into tt2(name) values(``'df'``) ;`

`ERROR 1003 (HY000): mycat sequnce err.java.lang.RuntimeException: sequnce not
found ``in` `db table`

`mysql> create table tt2(``id` `int auto_increment primary key,name
varchar(10));`

`Query OK, 0 rows affected (0.02 sec)`

`mysql> insert into mycat_sequence values(``'TT2'``,0,1);`  
  
---|---  
  
  

此处建议重启一下mycat 如果报错的话 不报错就不需要重启了

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

|

`mysql> insert into tt2(name) values(``'123'``);`

`Query OK, 1 row affected (0.11 sec)`

`mysql> insert into tt2(name) values(``'123'``);`

`Query OK, 1 row affected (0.11 sec)`

`mysql> insert into tt2(name) values(``'123'``);`

`Query OK, 1 row affected (0.11 sec)`

`mysql> insert into tt2(name) values(``'123'``);`

`Query OK, 1 row affected (0.11 sec)`

`mysql> insert into tt2(name) values(``'123'``);`

`Query OK, 1 row affected (0.11 sec)`

`mysql> insert into tt2(name) values(``'123'``);`

`Query OK, 1 row affected (0.11 sec)`

`mysql> insert into tt2(name) values(``'123'``);`

`Query OK, 1 row affected (0.11 sec)`

`mysql> insert into tt2(name) values(``'123'``);`

`Query OK, 1 row affected (0.11 sec)`

`mysql> insert into tt2(name) values(``'123'``);`

`Query OK, 1 row affected (0.11 sec)`

`mysql> insert into tt2(name) values(``'123'``);`

`Query OK, 1 row affected (0.11 sec)`

`mysql> insert into tt2(name) values(``'123'``);`

`Query OK, 1 row affected (0.11 sec)`

`mysql> ``select` `* from tt2 order by ``id` `asc;`

`+----+------+`

`| ``id` `| name |`

`+----+------+`

`| 1 | 123 |`

`| 2 | 123 |`

`| 3 | 123 |`

`| 4 | 123 |`

`| 5 | 123 |`

`| 6 | 123 |`

`| 7 | 123 |`

`| 8 | 123 |`

`| 9 | 123 |`

`| 10 | 123 |`

`| 11 | 123 |`

`| 12 | 123 |`

`| 13 | 123 |`

`+----+------+`

`13 rows ``in` `set` `(0.03 sec)`  
  
---|---  
  
  

看到了这就是自增长了

现在我们把这一切做到我的业务表elog里面

1

|

`mysql> insert into mycat_sequence values(``'ELOG'``,0,1);`  
  
---|---  
  
  

[](http://s3.51cto.com/wyfs02/M01/74/67/wKioL1YcoYrAIhoEAAHWke7JlTI074.jpg)

去掉id列证明下自增长是否成功

[root@node24 conf]#mysql -uadminz -pxinchengyungui -h127.0.0.1 -P8066 -Dyungui
< /usr/local/src/elog.sql

开启另一个窗口

[root@node24 ~]#mysql -uadminz -pxinchengyungui -h127.0.0.1 -P8066 -Dyungui

mysql> select * from elog order by id asc ;

| 110 | 274171404230318720996402 | 0 | -0.5 | 1 | 0 | 10212023 | 2014-07-02
10:52:22 | 412 | NULL | NULL | NULL | 1 | 0 |

| 111 | 954081404227374398993546 | 0 | -0.5 | 1 | 0 | 10212027 | 2014-07-02
10:52:37 | 64 | NULL | NULL | NULL | 1 | 0 |

+-----+--------------------------+-------------+--------------+-----------+-------------+----------+---------------------+----------+---------+-------+-------+-------------+---------------+

100 rows in set (0.01 sec)

发现不管你执行多少次都是100行

咋回事这是因为你之前配置文件配置显示100行

要想看的多

mysql> select * from elog order by id asc limit 1000000;

| 2724 | 176681404225891950114977 | 0 | -0.5 | 0 | 0 | 10219178 | 2014-07-04
14:48:41 | 1166 | NULL | NULL | NULL | 1 | 0 |

| 2725 | 519571404226693213346300 | 0 | -0.5 | 0 | 0 | 10219179 | 2014-07-04
14:48:46 | 948 | NULL | NULL | NULL | 1 | 0 |

| 2726 | 142391404222641663128165 | 0 | -0.5 | 0 | 0 | 10219180 | 2014-07-04
14:48:51 | 498 | NULL | NULL | NULL | 1 | 0 |

| 2727 | 519571404226693213346300 | 0 | -0.5 | 0 | 0 | 10219181 | 2014-07-04
14:49:13 | 948 | NULL | NULL | NULL | 1 | 0 |

+------+--------------------------+-------------+--------------+-----------+-------------+----------+---------------------+----------+---------+-------+-------+-------------+---------------+

2716 rows in set (0.03 sec)

这样就行烙

## 3.haproxy+mycat

再安装一个mycat配置的一样一样的

### 环境描述

1

2

3

4

5

|

`mysql5`

`OS: Oracle Linux Server release 6.3`

`Mycat server1:10.0.30.134:8806`

`Mycat server2:10.0.30.139:8806`

`Haproxy server:10.0.30.139: 8098`  
  
---|---  
  
  

前期未启用VIP，所以先用Mycat server2的8098端口作为haproxy的对外接口

### Mycat 安装

在Mycat server1及Mycat server2上进行安装Mycat

Linux(Unix)下，建议放在/usr/local/MyCAT目录下，如下面类似的：

[](http://s3.51cto.com/wyfs02/M02/74/6B/wKiom1YcoaDhzvftAABvms6D_vY484.jpg)

1

2

3

4

5

|

`useradd mycat`

`chown –R mycat.mycat /usr/local/mycat`

` `

`启动mycat`

`/usr/local/mycat/bin/mycat start`  
  
---|---  
  
  

### Haproxy 的安装

useradd haproxy

#wget
[http://haproxy.1wt.eu/download/1.4/src/haproxy-1.4.25.tar.gz](http://haproxy.1wt.eu/download/1.4/src/haproxy-1.4.25.tar.gz)  
# tar zcvf haproxy-1.3.20.tar.gz  
# cd haproxy-1.3.20  
# make TARGET=linux26 PREFIX=/usr/local/haprpxy ARCH=x86_64  
# make install

安装完毕后，进入安装目录创建配置文件  
# cd /usr/local/haproxy

#chown –R haproxy.haproxy *  
# vi haproxy.cfg

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

|

`global`

` ``log 127.0.0.1 local0 ``##记日志的功能`

` ``maxconn 4096`

` ``chroot ``/usr/local/haproxy`

` ``user haproxy`

` ``group haproxy`

` ``daemon`

`defaults`

`logglobal`

`optiondontlognull`

`retries3`

`option redispatch`

`maxconn2000`

`contimeout5000`

`clitimeout50000`

`srvtimeout50000`

`listen admin_stats 10.0.30.139:48800 ``##由于没有启用VIP，暂时用其中一台的IP和新端口`

` ``stats uri ``/admin-status` `##统计页面`

` ``stats auth admin:admin`

` ``mode http`

` ``option httplog`

`listenallmycat 10.0.30.139:8098`

` ``mode tcp`

` ``option tcplog`

` ``option httpchk OPTIONS * HTTP``/1``.1\r\nHost:\ www `

` ``balanceroundrobin`

` ``server mycat_134 10.0.30.134:8066 check port 48700 inter 5s rise 2 fall 3`

` ``server mycat_139 10.0.30.139:8066 check port 48700 inter 5s rise 2 fall 3`

` ``srvtimeout 20000`  
  
---|---  
  
  

默认haproxy是不记录日志的，为了记录日志还需要配置syslog模块，在oracle linux下是rsyslogd服务，yum –y install
rsyslog 先安装rsyslog，然后

1

2

|

`#`

`vi` `/etc/rsyslog``.d``/haproxy``.conf`  
  
---|---  
  
  

加入以下内容

1

2

3

|

`$ModLoad imudp`

`$UDPServerRun 514`

`local0.* ``/var/log/haproxy``.log ``##对应haproxy.cfg 的日志记录选项`  
  
---|---  
  
  

保存，重启

1

2

|

`service`

` ``rsyslog restart`  
  
---|---  
  
  

现在你就可以看到日志了

在Mycat server1 Mycat server2上都需要添加检测端口48700的脚本，为此需要用到xinetd

首先在xinetd目录下面增加脚本与端口的映射配置文件

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

`#vim /etc/xinetd.d/mycat_status`

`service mycat_status`

`{`

` ``flags = REUSE`

` ``socket_type = stream`

` ``port = 48700`

` ``wait = no`

` ``user = nobody`

` ``server = ``/usr/local/bin/mycat_status`

` ``log_on_failure += USERID`

` ``disable = no`

`}`  
  
---|---  
  
  

再增加/usr/local/bin/mycat_status用于检测mycat是否运行的脚本

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

`#vim /usr/local/bin/mycat_status`

`#!/bin/bash`

`#/usr/local/bin/mycat_status.sh`

`# This script checks if a mycat server is healthy running on localhost. It
will `

`# return: `

`# `

`# "HTTP/1.x 200 OK\r" (if mycat is running smoothly) `

`# `

`# "HTTP/1.x 503 Internal Server Error\r" (else) `

`mycat=```/usr/local/mycat/bin/mycat` `status | ``grep` `'not running'` `|
``wc` `-l``

`if` `[ ``"$mycat"` `= ``"0"` `];`

`then`

` ``/bin/echo` `-e ``"HTTP/1.1 200 OK\r\n"`

`else`

` ``/bin/echo` `-e ``"HTTP/1.1 503 Service Unavailable\r\n"`

`fi`  
  
---|---  
  
  

我是根据mycat status 返回的状态来判定mycat是否在运行的，也可以直接通过mysql –P8806 –e”select user()”
等直接执行sql的形式来检测

重启xinetd服务

1

|

`#service xinetd restart`  
  
---|---  
  
  

查看48700端口是否监听了

1

|

`#netstat -antup|grep 48700`  
  
---|---  
  
  

[](http://s3.51cto.com/wyfs02/M01/74/6B/wKiom1Ycoe6ip83oAACTBQSLnAU309.jpg)

如上图则端口的配置正确了

启动haproxy

1

|

`/usr/local/haproxy/sbin/haproxy` `-f ``/usr/local/haproxy/haproxy``.cfg`  
  
---|---  
  
  

为了使用方便可以增加一个启动，停止haproxy的脚本

启动脚本starthap内容如下

1

2

|

`#!/bin/sh`

`/usr/local/haproxy/sbin/haproxy` `-f ``/usr/local/haproxy/haproxy``.cfg &`  
  
---|---  
  
  

停止脚本stophap内容如下

1

2

|

`#!/bin/sh`

`ps` `-ef | ``grep` `sbin``/haproxy` `| ``grep` `-``v` `grep` `|``awk`
`'{print $2}'``|``xargs` `kill` `-s 9`  
  
---|---  
  
  

分别赋予启动权限

1

2

|

`chmod` `+x starthap`

`chmod` `+x stophap`  
  
---|---  
  
  

启动后可以通过[http://10.0.30.139:48800/admin-status](http://10.0.30.139:48800/admin-
status) (用户名密码都是admin haproxy.cnfg配置的)

[](http://s3.51cto.com/wyfs02/M01/74/67/wKioL1YcojfBMfKXAAbxip0CXyI880.jpg)

配置完成

## 4.percona集群+mycat+haproxy+keepalived

### 看我的集群比对然后加进来就行了

### 使用需谨慎 报错无人理只能靠自己

  


---
### ATTACHMENTS
[3186a9ef079c54025f9103d31f3c38bd]: media/wKiom1YcoLegk7D_AALg-TcK91I467.jpg
[wKiom1YcoLegk7D_AALg-TcK91I467.jpg](media/wKiom1YcoLegk7D_AALg-TcK91I467.jpg)
>hash: 3186a9ef079c54025f9103d31f3c38bd  
>source-url: http://s3.51cto.com/wyfs02/M02/74/6B/wKiom1YcoLegk7D_AALg-TcK91I467.jpg  
>file-name: wKiom1YcoLegk7D_AALg-TcK91I467.jpg  

[5d6bf4ed146ebc6b93feff21ec182a82]: media/wKiom1Ycoe6ip83oAACTBQSLnAU309.jpg
[wKiom1Ycoe6ip83oAACTBQSLnAU309.jpg](media/wKiom1Ycoe6ip83oAACTBQSLnAU309.jpg)
>hash: 5d6bf4ed146ebc6b93feff21ec182a82  
>source-url: http://s3.51cto.com/wyfs02/M01/74/6B/wKiom1Ycoe6ip83oAACTBQSLnAU309.jpg  
>file-name: wKiom1Ycoe6ip83oAACTBQSLnAU309.jpg  

[657f79fbfc3412c49c8702d92825a23c]: media/wKioL1YcojfBMfKXAAbxip0CXyI880.jpg
[wKioL1YcojfBMfKXAAbxip0CXyI880.jpg](media/wKioL1YcojfBMfKXAAbxip0CXyI880.jpg)
>hash: 657f79fbfc3412c49c8702d92825a23c  
>source-url: http://s3.51cto.com/wyfs02/M01/74/67/wKioL1YcojfBMfKXAAbxip0CXyI880.jpg  
>file-name: wKioL1YcojfBMfKXAAbxip0CXyI880.jpg  

[7e0d65a267e45e737c3eaf3295067644]: media/wKiom1YcoaDhzvftAABvms6D_vY484.jpg
[wKiom1YcoaDhzvftAABvms6D_vY484.jpg](media/wKiom1YcoaDhzvftAABvms6D_vY484.jpg)
>hash: 7e0d65a267e45e737c3eaf3295067644  
>source-url: http://s3.51cto.com/wyfs02/M02/74/6B/wKiom1YcoaDhzvftAABvms6D_vY484.jpg  
>file-name: wKiom1YcoaDhzvftAABvms6D_vY484.jpg  

[9a876903b031e96c00b45741a1c0a6ec]: media/wKioL1YcoYrAIhoEAAHWke7JlTI074.jpg
[wKioL1YcoYrAIhoEAAHWke7JlTI074.jpg](media/wKioL1YcoYrAIhoEAAHWke7JlTI074.jpg)
>hash: 9a876903b031e96c00b45741a1c0a6ec  
>source-url: http://s3.51cto.com/wyfs02/M01/74/67/wKioL1YcoYrAIhoEAAHWke7JlTI074.jpg  
>file-name: wKioL1YcoYrAIhoEAAHWke7JlTI074.jpg  

[ca696451264d9c6a3d1edd0b9dea3881]: media/wKioL1Ycnh7DO92eAAJRVDT_dhs405.jpg
[wKioL1Ycnh7DO92eAAJRVDT_dhs405.jpg](media/wKioL1Ycnh7DO92eAAJRVDT_dhs405.jpg)
>hash: ca696451264d9c6a3d1edd0b9dea3881  
>source-url: http://s3.51cto.com/wyfs02/M01/74/67/wKioL1Ycnh7DO92eAAJRVDT_dhs405.jpg  
>file-name: wKioL1Ycnh7DO92eAAJRVDT_dhs405.jpg  

---
### NOTE ATTRIBUTES
>Created Date: 2018-06-14 07:26:56  
>Last Evernote Update Date: 2018-10-01 15:35:36  
>source: web.clip7  
>source-url: http://blog.51cto.com/zuoyuezong/1702507  
>source-application: WebClipper 7  