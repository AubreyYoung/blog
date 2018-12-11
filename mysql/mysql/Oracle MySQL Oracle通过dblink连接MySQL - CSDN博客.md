# [Oracle, MySQL] Oracle通过dblink连接MySQL - CSDN博客

原

# [Oracle, MySQL] Oracle通过dblink连接MySQL

2013年08月29日 12:04:52

阅读数：10737

业务上有这么一个需求，需要把Oracle的一些数据同步到MySQL，如果每次都是手动同步的话，实在太麻烦，因此花了点时间研究了下Oracle直连MySQL的方式。

参考文档： **[Detailed Overview of Connecting Oracle to MySQL Using DG4ODBC
Database Link (Doc ID
1320645.1)](https://support.oracle.com/epmos/faces/DocumentDisplay?_adf.ctrl-
state=zrc3m55j8_4&_afrLoop=126976935090956)**

版本信息：

Oracle: 11.2.0.1.0     OS: CentOS 5.9

MySQL: 5.5.27          OS: CentOS 5.8

原理：

Oracle使用DG4ODBC数据网关连接其它非Oracle数据库，其原理图如下：

![noteattachment1][1282220226b344b02f0739fdd906075a]

从上图可知，Oracle连接MySQL需要涉及到如下组件：DG4ODBC, ODBC Driver Manager, ODBC
Driver，本文将一一讲解它们的配置。

1）判断32位还是64位

因为32位和64位的配置不一样，64位更复杂一些，因此我们首先得确定Oracle和DG4ODBC是32位还是64位：

1

[oracle@lx16 ~]$ file $ORACLE_HOME/bin/dg4odbc

2

/home/oracle/app/oracle/product/11.2.0/dbhome_1/bin/dg4odbc: ELF 64-bit LSB
executable, AMD x86-64, version 1 (SYSV), for GNU/Linux 2.6.9, dynamically
linked (uses shared libs), not stripped

从上面的输出可知是64位。

2）下载并安装ODBC Driver Manager

到这个页面（http://www.unixodbc.org/download.html）根据你的OS下载unixodbc（注意：版本不能低于2.2.14）

$ wget
http://sourceforge.net/projects/unixodbc/files/unixODBC/2.2.14/unixODBC-2.2.14-linux-x86-64.tar.gz/download

解压缩：

$ tar -zxvf unixODBC-2.2.14-linux-x86-64.tar.gz

解压缩后会在当前目录下自动创建usr的目录，我们创建一个目录（~/app/unixodbc-2.2.14）用于放置unixodbc，然后把usr
迁移到该目录下：

1

$ mkdir ~/app/unixodbc-2.2.14

2

$ mv usr ~/app/unixodbc-2.2.14

3）下载并按照ODBC Driver for MySQL

到这个页面（<http://dev.mysql.com/downloads/connector/odbc/5.2.html#downloads>）根据你的OS下载ODBC-5.2.5，本例选择64位tar版本：

1

$ wget http://dev.mysql.com/get/Downloads/Connector-ODBC/5.2/mysql-connector-
odbc-5.2.5-linux-glibc2.5-x86-64bit.tar.gz/from/http://cdn.mysql.com/

2

$ tar -zxvf mysql-connector-odbc-5.2.5-linux-glibc2.5-x86-64bit.tar.gz

解压缩成功后是一个文件夹，把该文件夹迁移至~/app目录下，并给它创建一个软链接：

1

$ mv mysql-connector-odbc-5.2.5-linux-glibc2.5-x86-64bit ~/app

2

$ cd ~/app

3

$ ln -s mysql-connector-odbc-5.2.5-linux-glibc2.5-x86-64bit myodbc-5.2.5

4）配置ODBC Driver

在~/etc目录下创建odbc.ini如下：

1

[myodbc5]

2

Driver = /home/oracle/app/myodbc-5.2.5/lib/libmyodbc5w.so

3

Description = Connector/ODBC 5.2 Driver DSN

4

SERVER = 192.168.1.15

5

PORT = 3306

6

USER = mysql_user

7

PASSWORD = mysql_pwd

8

DATABASE = mysql_db

9

OPTION = 0

10

TRACE = OFF

其中，Driver指向第3步上按照的ODBC Driver，这里要特别注意：MySQL的Datbase是大小写敏感的。

5）验证ODBC连接

1

$ export ODBCINI=/home/oracle/etc/odbc.ini

2

$ export
LD_LIBRARY_PATH=/home/oracle/app/unixodbc-2.2.14/usr/local/lib:$LD_LIBRARY_PATH

3

$ cd ~/app/unixodbc-2.2.14/usr/local/bin

4

$ ./isql myodbc5 -v

5

+---------------------------------------+

6

| Connected! |

7

| |

8

| sql-statement |

9

| help [tablename] |

10

| quit |

11

| |

12

+---------------------------------------+

上面显示连接成功。

6）配置tnsnames.ora

myodbc5 =

(DESCRIPTION=

(ADDRESS=

(PROTOCOL=TCP) (HOST=localhost) (PORT=1521)

)

(CONNECT_DATA=

(SID=myodbc5)

)

(HS=OK)

)

7）配置listener.ora

1

SID_LIST_LISTENER=

2

(SID_LIST=

3

(SID_DESC=

4

(SID_NAME=myodbc5)

5

(ORACLE_HOME=/home/oracle/app/oracle/product/11.2.0/dbhome_1)

6

(PROGRAM=dg4odbc)

7

(ENVS=LD_LIBRARY_PATH=/home/oracle/app/unixodbc-2.2.14/usr/local/lib:/home/oracle/app/oracle/product/11.2.0/dbhome_1/lib)

8

)

9

)

如上所示，为了避免和其它已存在的ODBC Driver Manager冲突，强烈设置LD_LIBRARY_PATH在listener.ora

8）创建init<sid>.ora文件

创建文件$ORACLE_HOME/hs/admin/initmyodbc5.ora，内容如下：

1

HS_FDS_CONNECT_INFO=myodbc5 # Data source name in odbc.ini

2

HS_FDS_SHAREABLE_NAME=/home/oracle/app/unixodbc-2.2.14/usr/local/lib/libodbc.so

3

HS_FDS_SUPPORT_STATISTICS=FALSE

4

HS_LANGUAGE=AMERICAN_AMERICA.WE8ISO8859P15

5

6

# ODBC env variables

7

set ODBCINI=/home/oracle/etc/odbc.ini

9）使上述配置文件生效

1

$ lsnrctl reload

2

$ lsnrctl status

3

Service "myodbc5" has 1 instance(s).

4

Instance "myodbc5", status UNKNOWN, has 1 handler(s) for this service...

10）验证配置是否正确

1

$ tnsping myodbc5

2

3

TNS Ping Utility for Linux: Version 11.2.0.1.0 - Production on 29-AUG-2013
10:54:46

4

5

Copyright (c) 1997, 2009, Oracle. All rights reserved.

6

7

Used parameter files:

8

/home/oracle/app/oracle/product/11.2.0/dbhome_1/network/admin/sqlnet.ora

9

10

11

Used TNSNAMES adapter to resolve the alias

12

Attempting to contact (DESCRIPTION= (ADDRESS= (PROTOCOL=TCP) (HOST=localhost)
(PORT=1521)) (CONNECT_DATA= (SID=myodbc5)) (HS=OK))

13

OK (0 msec)

复制

11）创建dblink

1

SQL> create public database link mysqltest connect to "mysql_user" identified
by "mysql_pwd" using 'myodbc5';

2

SQL> select count(*) from trans_expert_map@mysqltest;

3

4

COUNT(*)

5

\----------

6

371

  

  

所属专栏： [深入Oracle](https://blog.csdn.net/column/details/oraclenote.html)

相关热词： [oracle的](https://blog.csdn.net/qq_16605855/article/details/77646293)
[oracle'](https://blog.csdn.net/aspnet2002web/article/details/51211581)
[oracle小猪](https://blog.csdn.net/zj52hm/article/details/51943783)
[oracle消耗](https://blog.csdn.net/dtjiawenwang88/article/details/74906954)
[oracle重构](https://blog.csdn.net/lovergo/article/details/53219913)

[上一篇](https://blog.csdn.net/dbanote/article/details/10331133)[Oracle] Data
Guard 系列（5） - 创建逻辑备库

[下一篇](https://blog.csdn.net/dbanote/article/details/11271115)[Django实战] 第1篇 -
概述

  


---
### ATTACHMENTS
[1282220226b344b02f0739fdd906075a]: media/20130829091838640.jpg
[20130829091838640.jpg](media/20130829091838640.jpg)
>hash: 1282220226b344b02f0739fdd906075a  
>source-url: https://img-blog.csdn.net/20130829091838640  
>timestamp: 20130829T091814Z  
>file-name: 20130829091838640  

---
### NOTE ATTRIBUTES
>Created Date: 2018-07-23 07:15:59  
>Last Evernote Update Date: 2018-07-27 07:02:40  
>source: web.clip7  
>source-url: https://blog.csdn.net/dbanote/article/details/10488581  
>source-application: WebClipper 7  