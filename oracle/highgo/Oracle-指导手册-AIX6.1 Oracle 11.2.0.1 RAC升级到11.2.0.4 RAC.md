# Oracle-指导手册-AIX6.1+ Oracle 11.2.0.1 RAC升级到11.2.0.4 RAC

# 瀚高技术支持管理平台

# 时间参考：

项目

|

时间  
  
---|---  
  
打patch 9706490结束

|

1-2小时  
  
升级GI

|

2-5小时  
  
数据库软件安装完毕

|

2-4小时  
  
升级

|

DBUA时长

|

2小时20分钟以上  
  
手动跑脚本时长

|

1.5-2.5小时  
  
手动跑脚本后续

|

20分钟  
  
打最新GI&DB PSU（保证/tmp和ORACLE_HOME所在空间余量均大于11G）

|

1-2.5小时  
  
总时长

|

图形

|

6-13小时  
  
手动

|

5-12小时  
  
*以上时间仅供参考，因存储性能和服务器性能造成时间差异。

# 1 环境说明

两个节点的 11.2.0.1，节点名分别为 rac1 和 rac2， 数据库名为orcl。

GI HOME:

11.2.0.1: /u01/app/11.2.0/grid

11.2.0.4: /u01/app/11.2.0.4/grid

DB HOME:

11.2.0.1: /u02/app/oracle/product/11.2.0/db_home

11.2.0.4: /u02/app/oracle/product/11.2.0.4/db_home2

# 2 备份

对数据库做完整的备份，确保数据库存在有效的备份。

备份控制文件，参数文件。

备份两节点以下目录中文件：

 **[oracle@rac1 ~]$ cp /u02/app/oracle/product/11.2.0/db_home/dbs/*
/home/oracle/upgradebak/dbs/**

**[oracle@db01 admin]$ cp -R
/u02/app/oracle/product/11.2.0/db_home/network/admin/*
/home/oracle/upgradebak/admin/**

# 2 升级 GI

## 2.1 下载并解压 11.2.0.4 GI 介质

 **[grid@rac1 tmp]$ ls -l**

total 1178160

-rw-r--r-- 1 grid oinstall 1205251894 Sep 2 18:49 p13390677_112040_AIX64-5L_3of7.zip

用 grid 用户进行解压：

**[grid@rac1 tmp]$ unzip p13390677_112040_AIX64-5L_3of7.zip**

在两个节点都创建 11.2.0.4 的 GI 的 ORACLE_HOME：

 **注意： grid 用户环境变量 ORACLE_HOME 不在ORACLE_BASE 目录下**

 **# mkdir -p /u01/app/11.2.0.4/grid**

 **# chown grid:oinstall /u01/app/11.2.0.4/grid**

## 2.2 利用 CUV 进行升级前的检查

用 grid 用户在节点 1 执行：

 **[grid@rac1 grid]$./runcluvfy.sh stage -pre crsinst -upgrade -n rac1,rac2
-rolling -src_crshome /u01/app/11.2.0/grid -dest_crshome
/u01/app/11.2.0.4/grid -dest_version 11.2.0.4.0**

Performing pre-checks for cluster services setup

Checking node reachability...

Node reachability check passed from node "rac1"

Checking user equivalence...

User equivalence check passed for user "grid"

Checking CRS user consistency

CRS user consistency check successful

Checking node connectivity...

Checking hosts config file...

Verification of the hosts config file successful

Check: Node connectivity for interface "en8"

Node connectivity passed for interface "en8"

TCP connectivity check passed for subnet "192.168.254.0"

Check: Node connectivity for interface "en9"

Node connectivity passed for interface "en9"

TCP connectivity check passed for subnet "10.0.0.0"

Checking subnet mask consistency...

Subnet mask consistency check passed for subnet "192.168.254.0".

Subnet mask consistency check passed for subnet "10.0.0.0".

Subnet mask consistency check passed.

Node connectivity check passed

Checking multicast communication...

Checking subnet "192.168.254.0" for multicast communication with multicast
group "230.0.1.0"...

Check of subnet "192.168.254.0" for multicast communication with multicast
group "230.0.1.0" passed.

Checking subnet "10.0.0.0" for multicast communication with multicast group
"230.0.1.0"...

Check of subnet "10.0.0.0" for multicast communication with multicast group
"230.0.1.0" passed.

Check of multicast communication passed.

Checking OCR integrity...

OCR integrity check passed

Total memory check passed

Available memory check passed

Swap space check passed

Free disk space check passed for "rac2:/u01/app/11.2.0.4/grid"

Free disk space check passed for "rac1:/u01/app/11.2.0.4/grid"

Free disk space check passed for "rac2:/tmp/"

Free disk space check passed for "rac1:/tmp/"

Check for multiple users with UID value 503 passed

User existence check passed for "grid"

Group existence check passed for "oinstall"

Membership check for user "grid" in group "oinstall" [as Primary] passed

Run level check passed

Hard limits check passed for "maximum open file descriptors"

Soft limits check passed for "maximum open file descriptors"

Hard limits check passed for "maximum user processes"

Soft limits check passed for "maximum user processes"

 **Check for Oracle patch "9706490 or 9413827" in home "/u01/app/11.2.0/grid"
failed**

 **Check failed on nodes:**

 **rac2,rac1**

There are no oracle patches required for home "/u01/app/11.2.0.4/grid".

System architecture check passed

Kernel version check passed

Kernel parameter check passed for "ncargs"

Kernel parameter check passed for "maxuproc"

 **Kernel parameter check failed for "tcp_ephemeral_low"**

 **Check failed on nodes:**

 **rac2,rac1**

 **Kernel parameter check failed for "tcp_ephemeral_high"**

 **Check failed on nodes:**

 **rac2,rac1**

 **Kernel parameter check failed for "udp_ephemeral_low"**

 **Check failed on nodes:**

 **rac2,rac1**

 **Kernel parameter check failed for "udp_ephemeral_high"**

 **Check failed on nodes:**

 **rac2,rac1**

Package existence check passed for "bos.adt.base"

Package existence check passed for "bos.adt.lib"

Package existence check passed for "bos.adt.libm"

Package existence check passed for "bos.perf.libperfstat"

Package existence check passed for "bos.perf.perfstat"

Package existence check passed for "bos.perf.proctools"

Package existence check passed for "xlC.aix61.rte"

Package existence check passed for "xlC.rte"

 **Operating system patch check failed for "Patch IZ97457"**

 **Check failed on nodes:**

 **rac2,rac1**

Check for multiple users with UID value 0 passed

Current group ID check passed

Starting check for consistency of primary group of root user

Check for consistency of root user's primary group passed

Starting Clock synchronization checks using Network Time Protocol(NTP)...

NTP Configuration file check started...

No NTP Daemons or Services were found to be running

Clock synchronization check using Network Time Protocol(NTP) passed

Core file name pattern consistency check passed.

User "grid" is not part of "system" group. Check passed

Default user file creation mask check passed

Checking consistency of file "/etc/resolv.conf" across nodes

File "/etc/resolv.conf" does not exist on any node of the cluster. Skipping
further checks

File "/etc/resolv.conf" is consistent across nodes

Time zone consistency check passed

Checking VIP configuration.

Checking VIP Subnet configuration.

Check for VIP Subnet configuration passed.

Checking VIP reachability

Check for VIP reachability passed.

Checking Oracle Cluster Voting Disk configuration...

ASM Running check passed. ASM is running on all specified nodes

Oracle Cluster Voting Disk configuration check passed

Clusterware version consistency passed

User ID < 65535 check passed

Kernel 64-bit mode check passed

Starting check for Network parameter - ipqmaxlen ...

ERROR:

PRVE-0273 : The value of network parameter "ipqmaxlen" for interface "en9" is
not configured to the expected value on node "rac2".[Expected="512";
Found="en9=100"]

PRVE-0273 : The value of network parameter "ipqmaxlen" for interface "en9" is
not configured to the expected value on node "rac1".[Expected="512";
Found="en9=100"]

Check for Network parameter - ipqmaxlen failed

Starting check for Network parameter - rfc1323 ...

ERROR:

PRVE-0273 : The value of network parameter "rfc1323" for interface "en9" is
not configured to the expected value on node "rac2".[Expected="1";
Found="en9=0"]

PRVE-0273 : The value of network parameter "rfc1323" for interface "en9" is
not configured to the expected value on node "rac1".[Expected="1";
Found="en9=0"]

Check for Network parameter - rfc1323 failed

Starting check for Network parameter - sb_max ...

ERROR:

PRVE-0273 : The value of network parameter "sb_max" for interface "en9" is not
configured to the expected value on node "rac2".[Expected="4194304";
Found="en9=1500000"]

PRVE-0273 : The value of network parameter "sb_max" for interface "en9" is not
configured to the expected value on node "rac1".[Expected="4194304";
Found="en9=1500000"]

Check for Network parameter - sb_max failed

Starting check for Network parameter - tcp_sendspace ...

Check for Network parameter - tcp_sendspace passed

Starting check for Network parameter - tcp_recvspace ...

Check for Network parameter - tcp_recvspace passed

Starting check for Network parameter - udp_sendspace ...

ERROR:

PRVE-0273 : The value of network parameter "udp_sendspace" for interface "en9"
is not configured to the expected value on node "rac2".[Expected="65536";
Found="en9=13516"]

PRVE-0273 : The value of network parameter "udp_sendspace" for interface "en9"
is not configured to the expected value on node "rac1".[Expected="65536";
Found="en9=13516"]

Check for Network parameter - udp_sendspace failed

Starting check for Network parameter - udp_recvspace ...

ERROR:

PRVE-0273 : The value of network parameter "udp_recvspace" for interface "en9"
is not configured to the expected value on node "rac2".[Expected="655360";
Found="en9=42080"]

PRVE-0273 : The value of network parameter "udp_recvspace" for interface "en9"
is not configured to the expected value on node "rac1".[Expected="655360";
Found="en9=42080"]

Check for Network parameter - udp_recvspace failed

Pre-check for cluster services setup was unsuccessful on all the nodes.

有报错信息。

不同的环境，报错很可能不一致，此为参考。

1.Check for Oracle patch "9706490 or 9413827" in home "/u01/app/11.2.0/grid"
failed

该报错信息提示需要为GI打patch：9706490 或 9413827。步骤见[2.3 打Patch
9706490](https://47.100.29.40/highgo_admin/file:///C:/Users/Administrator/Desktop/1/AIX11.2.0.1%E5%88%B011.2.0.4rac%E5%8D%87%E7%BA%A7%E6%93%8D%E4%BD%9C%E6%89%8B%E5%86%8Cv1.1.docx#_2.3__%E6%89%93Patch)。

2\. Kernel parameter check failed for "tcp_ephemeral_low"

Kernel parameter check failed for "tcp_ephemeral_high"

Kernel parameter check failed for "udp_ephemeral_low"

Kernel parameter check failed for "udp_ephemeral_high"

该参数为当前的临时端口范围，通过如下命令设置：（mos ID 169706.1 AIX Kernel Settings）

# /usr/sbin/no -p -o tcp_ephemeral_low=9000 -o tcp_ephemeral_high=65500

# /usr/sbin/no -p -o udp_ephemeral_low=9000 -o udp_ephemeral_high=65500

3\. Operating system patch check failed for "Patch IZ97457"

该系统补丁不修复虽仍可进行后续操作，但可能存在一定隐患，此处强烈建议修复该补丁，如果系统工程师有针对该补丁更新的修复方案，以系统工程师提供为准。不同版本的操作系统需要打的补丁不同，详见下表。

参考MOS:11gR2 OUI On AIX Pre-Requisite Check Gives Error "Patch IZ97457, IZ89165
Are Missing" (文档 ID 1439940.1)

系统工程师修复后可按如下方法查看是否已安装操作系统补丁包：

-bash-3.2# oslevel -r

6100-04

-bash-3.2# instfix -i |grep IZ89302

All filesets for IZ89302 were found.

-bash-3.2# instfix -i |grep IZ97605

All filesets for IZ97605 were found.

4\. Starting check for Network parameter - ipqmaxlen ...

ERROR:

PRVE-0273 : The value of network parameter "ipqmaxlen" for interface "en9" is
not configured to the expected value on node "rac2".[Expected="512";
Found="en9=100"]

PRVE-0273 : The value of network parameter "ipqmaxlen" for interface "en9" is
not configured to the expected value on node "rac1".[Expected="512";
Found="en9=100"]

Check for Network parameter - ipqmaxlen failed

Starting check for Network parameter - rfc1323 ...

ERROR:

PRVE-0273 : The value of network parameter "rfc1323" for interface "en9" is
not configured to the expected value on node "rac2".[Expected="1";
Found="en9=0"]

PRVE-0273 : The value of network parameter "rfc1323" for interface "en9" is
not configured to the expected value on node "rac1".[Expected="1";
Found="en9=0"]

Check for Network parameter - rfc1323 failed

Starting check for Network parameter - sb_max ...

ERROR:

PRVE-0273 : The value of network parameter "sb_max" for interface "en9" is not
configured to the expected value on node "rac2".[Expected="4194304";
Found="en9=1500000"]

参考MOS: PRVE-0273 : The value of network parameter "udp_sendspace" for
interface "en0" is not configured to the expected value on node "racnode1" (文档
ID 1373242.1)

该报错为BUG。忽略即可。

在此强调。不同的环境，报错很可能不一致，此为参考。

## 2.3HACMP检查

检查当前AIX系统上是否有HACMP组件，如果有则客户确认，建议客户联系AIX小机工程师删除，避免HACMP导致升级失败。

lslpp -h "cluster*"

如下表示存在HACMP程序

如果带有HACMP升级运行rootupgrate.sh可能出现如下报错

原因是

$ ls -l /oracle/app/11.2.0.3/grid/lib/libskgxn*  
lrwxrwxrwx 1 grid oinstall 33 Nov 23 03:08
/oracle/app/11.2.0.3/grid/lib/libskgxn2.so ->
/opt/ORCLcluster/lib/libskgxn2.so  
-rwxr-xr-x 1 grid oinstall 159806 Oct 20 23:55 /oracle/app/11.2.0.3/grid/lib/libskgxnr.a  
lrwxrwxrwx 1 grid oinstall 33 Nov 23 09:38
/oracle/app/11.2.0.3/grid/lib/libskgxnr.so ->
/opt/ORCLcluster/lib/libskgxnr.so

grid的.so文件链接指向到了HACMP的文件上。

 **参考文档：**

 **AIX 11gR212c Grid Infrastructure Installation, root.sh Error Failed to
write the checkpoint'' with statusFAIL.Error code is 256 (** **文档 ID
1382505.1)**

 **AIX How to Upgrade to 11gR2 Grid Infrastructure When PowerHAHACMP Exists
(** **文档 ID 1443814.1)**

 **How to Deinstall Oracle Clusterware Home Manually (** **文档 ID 1364419.1)**

 **How to Proceed from Failed Upgrade to 11gR2 Grid Infrastructure on
LinuxUnix (** **文档 ID 969254.1)**

## 2.4 打Patch 9706490

添加opatch到 path，方便操作：

 **[grid@racX ~]$ vi .profile**

PATH=$ORACLE_HOME/bin:$PATH:$HOME/bin:/u02/app/oracle/product/11.2.0/db_home/OPatch

 **[oracle@racX ~]$ vi .profile**

PATH=$ORACLE_HOME/bin:$PATH:$HOME/bin:$ORACLE_PATH:/u01/app/11.2.0/grid/Opatch

 **[root@rac1 grid]# su - grid**

 **[grid@rac1 ~]$ opatch lsinventory -detail -oh $ORACLE_HOME**

Oracle Interim Patch Installer version 11.2.0.3.6

Copyright (c) 2013, Oracle Corporation. All rights reserved.

Oracle Home : /u01/app/11.2.0/grid

Central Inventory : /u01/app/oraInventory

from : /u01/app/11.2.0/grid/oraInst.loc

OPatch version : 11.2.0.3.6

OUI version : 11.2.0.1.0

Log file location :
/u01/app/11.2.0/grid/cfgtoollogs/opatch/opatch2016-08-11_01-48-03AM_1.log

Lsinventory Output file location :
/u01/app/11.2.0/grid/cfgtoollogs/opatch/lsinv/lsinventory2016-08-11_01-48-03AM.txt

\-----------------------------------------------------------------------------

Installed Top-level Products (1):

Oracle Grid Infrastructure 11.2.0.1.0

There are 1 product(s) installed in this Oracle Home.

Installed Components (87):

Agent Required Support Files 10.2.0.4.2

Assistant Common Files 11.2.0.1.0

Automatic Storage Management Assistant 11.2.0.1.0

Bali Share 1.1.18.0.0

Buildtools Common Files 11.2.0.1.0

Character Set Migration Utility 11.2.0.1.0

Cluster Ready Services Files 11.2.0.1.0

Cluster Verification Utility Common Files 11.2.0.1.0

Cluster Verification Utility Files 11.2.0.1.0

Database SQL Scripts 11.2.0.1.0

Deinstallation Tool 11.2.0.1.0

Enterprise Manager Common Core Files 10.2.0.4.2

Enterprise Manager Common Files 10.2.0.4.2

Enterprise Manager Minimal Integration 11.2.0.1.0

Enterprise Manager plugin Common Files 11.2.0.1.0

Expat libraries 2.0.1.0.1

HAS Common Files 11.2.0.1.0

HAS Files for DB 11.2.0.1.0

Installation Common Files 11.2.0.1.0

Installation Plugin Files 11.2.0.1.0

Installer SDK Component 11.2.0.1.0

LDAP Required Support Files 11.2.0.1.0

OLAP SQL Scripts 11.2.0.1.0

Oracle Clusterware RDBMS Files 11.2.0.1.0

Oracle Configuration Manager Deconfiguration 10.3.1.0.0

Oracle Containers for Java 11.2.0.1.0

Oracle Core Required Support Files 11.2.0.1.0

Oracle Database 11g 11.2.0.1.0

Oracle Database 11g Multimedia Files 11.2.0.1.0

Oracle Database Deconfiguration 11.2.0.1.0

Oracle Database User Interface 2.2.13.0.0

Oracle Database Utilities 11.2.0.1.0

Oracle DBCA Deconfiguration 11.2.0.1.0

Oracle Extended Windowing Toolkit 3.4.47.0.0

Oracle Globalization Support 11.2.0.1.0

Oracle Globalization Support 11.2.0.1.0

Oracle Grid Infrastructure 11.2.0.1.0

Oracle Help For Java 4.2.9.0.0

Oracle Ice Browser 5.2.3.6.0

Oracle Internet Directory Client 11.2.0.1.0

Oracle Java Client 11.2.0.1.0

Oracle JDBC/OCI Instant Client 11.2.0.1.0

Oracle JDBC/THIN Interfaces 11.2.0.1.0

Oracle JFC Extended Windowing Toolkit 4.2.36.0.0

Oracle JVM 11.2.0.1.0

Oracle LDAP administration 11.2.0.1.0

Oracle Locale Builder 11.2.0.1.0

Oracle Multimedia 11.2.0.1.0

Oracle Multimedia Client Option 11.2.0.1.0

Oracle Multimedia Java Advanced Imaging 11.2.0.1.0

Oracle Multimedia Locator 11.2.0.1.0

Oracle Multimedia Locator RDBMS Files 11.2.0.1.0

Oracle Net 11.2.0.1.0

Oracle Net Listener 11.2.0.1.0

Oracle Net Required Support Files 11.2.0.1.0

Oracle Netca Client 11.2.0.1.0

Oracle Notification Service 11.2.0.0.0

Oracle Notification Service (eONS) 11.2.0.1.0

Oracle One-Off Patch Installer 11.2.0.0.2

Oracle Quality of Service Management (Client) 11.2.0.1.0

Oracle Quality of Service Management (Server) 11.2.0.1.0

Oracle RAC Deconfiguration 11.2.0.1.0

Oracle RAC Required Support Files-HAS 11.2.0.1.0

Oracle Recovery Manager 11.2.0.1.0

Oracle Security Developer Tools 11.2.0.1.0

Oracle Text Required Support Files 11.2.0.1.0

Oracle Universal Installer 11.2.0.1.0

Oracle Wallet Manager 11.2.0.1.0

Parser Generator Required Support Files 11.2.0.1.0

Perl Interpreter 5.10.0.0.1

Perl Modules 5.10.0.0.1

PL/SQL 11.2.0.1.0

PL/SQL Embedded Gateway 11.2.0.1.0

Platform Required Support Files 11.2.0.1.0

Precompiler Required Support Files 11.2.0.1.0

RDBMS Required Support Files 11.2.0.1.0

RDBMS Required Support Files for Instant Client 11.2.0.1.0

Required Support Files 11.2.0.1.0

Secure Socket Layer 11.2.0.1.0

SQL*Plus 11.2.0.1.0

SQL*Plus Files for Instant Client 11.2.0.1.0

SQL*Plus Required Support Files 11.2.0.1.0

SSL Required Support Files for InstantClient 11.2.0.1.0

Sun JDK 1.5.0.17.0

Universal Storage Manager Files 11.2.0.1.0

XDK Required Support Files 11.2.0.1.0

XML Parser for Java 11.2.0.1.0

There are 87 component(s) installed in this Oracle Home.

There are no Interim patches installed in this Oracle Home.

Rac system comprising of multiple nodes

Local node = rac1

Remote node = rac2

\----------------------------------------------------------------------------

OPatch succeeded.

 **[root@rac1 grid]# su - oracle**

 **[oracle@rac1 ~]$ opatch lsinventory -detail -oh $ORACLE_HOME**

Oracle Interim Patch Installer version 11.2.0.3.6

Copyright (c) 2013, Oracle Corporation. All rights reserved.

Oracle Home : /u02/app/oracle/product/11.2.0/db_home

Central Inventory : /u01/app/oraInventory

from : /u02/app/oracle/product/11.2.0/db_home/oraInst.loc

OPatch version : 11.2.0.3.6

OUI version : 11.2.0.1.0

Log file location :
/u02/app/oracle/product/11.2.0/db_home/cfgtoollogs/opatch/opatch2016-08-11_01-48-35AM_1.log

Lsinventory Output file location :
/u02/app/oracle/product/11.2.0/db_home/cfgtoollogs/opatch/lsinv/lsinventory2016-08-11_01-48-35AM.txt

\-------------------------------------------------------------------------

Installed Top-level Products (1):

Oracle Database 11g 11.2.0.1.0

There are 1 product(s) installed in this Oracle Home.

Installed Components (134):

Agent Required Support Files 10.2.0.4.2

Assistant Common Files 11.2.0.1.0

Bali Share 1.1.18.0.0

Buildtools Common Files 11.2.0.1.0

Character Set Migration Utility 11.2.0.1.0

Cluster Verification Utility Common Files 11.2.0.1.0

Database Configuration and Upgrade Assistants 11.2.0.1.0

Database SQL Scripts 11.2.0.1.0

Database Workspace Manager 11.2.0.1.0

Deinstallation Tool 11.2.0.1.0

Enterprise Edition Options 11.2.0.1.0

Enterprise Manager Agent 10.2.0.4.2

Enterprise Manager Agent Core Files 10.2.0.4.2

Enterprise Manager Common Core Files 10.2.0.4.2

Enterprise Manager Common Files 10.2.0.4.2

Enterprise Manager Database Plugin -- Agent Support 11.2.0.1.0

Enterprise Manager Database Plugin -- Repository Support 11.2.0.1.0

Enterprise Manager Grid Control Core Files 10.2.0.4.2

Enterprise Manager Minimal Integration 11.2.0.1.0

Enterprise Manager plugin Common Files 11.2.0.1.0

Enterprise Manager Repository Core Files 10.2.0.4.2

Exadata Storage Server 11.2.0.1.0

Expat libraries 2.0.1.0.1

Generic Connectivity Common Files 11.2.0.1.0

HAS Common Files 11.2.0.1.0

HAS Files for DB 11.2.0.1.0

Installation Common Files 11.2.0.1.0

Installation Plugin Files 11.2.0.1.0

Installer SDK Component 11.2.0.1.0

JAccelerator (COMPANION) 11.2.0.1.0

LDAP Required Support Files 11.2.0.1.0

OLAP SQL Scripts 11.2.0.1.0

Oracle 11g Warehouse Builder Required Files 11.2.0.1.0

Oracle Advanced Security 11.2.0.1.0

Oracle Application Express 11.2.0.1.0

Oracle Call Interface (OCI) 11.2.0.1.0

Oracle Clusterware RDBMS Files 11.2.0.1.0

Oracle Code Editor 1.2.1.0.0I

Oracle Configuration Manager 10.3.1.1.0

Oracle Configuration Manager Deconfiguration 10.3.1.0.0

Oracle Containers for Java 11.2.0.1.0

Oracle Core Required Support Files 11.2.0.1.0

Oracle Data Mining RDBMS Files 11.2.0.1.0

Oracle Database 11g 11.2.0.1.0

Oracle Database 11g 11.2.0.1.0

Oracle Database 11g Multimedia Files 11.2.0.1.0

Oracle Database Deconfiguration 11.2.0.1.0

Oracle Database Gateway for ODBC 11.2.0.1.0

Oracle Database User Interface 2.2.13.0.0

Oracle Database Utilities 11.2.0.1.0

Oracle Database Vault J2EE Application 11.2.0.1.0

Oracle Database Vault option 11.2.0.1.0

Oracle DBCA Deconfiguration 11.2.0.1.0

Oracle Display Fonts 9.0.2.0.0

Oracle Enterprise Manager Console DB 11.2.0.1.0

Oracle Extended Windowing Toolkit 3.4.47.0.0

Oracle Globalization Support 11.2.0.1.0

Oracle Globalization Support 11.2.0.1.0

Oracle Help For Java 4.2.9.0.0

Oracle Help for the Web 2.0.14.0.0

Oracle Ice Browser 5.2.3.6.0

Oracle Internet Directory Client 11.2.0.1.0

Oracle Java Client 11.2.0.1.0

Oracle JDBC Server Support Package 11.2.0.1.0

Oracle JDBC/OCI Instant Client 11.2.0.1.0

Oracle JDBC/THIN Interfaces 11.2.0.1.0

Oracle JFC Extended Windowing Toolkit 4.2.36.0.0

Oracle JVM 11.2.0.1.0

Oracle Label Security 11.2.0.1.0

Oracle LDAP administration 11.2.0.1.0

Oracle Locale Builder 11.2.0.1.0

Oracle Message Gateway Common Files 11.2.0.1.0

Oracle Multimedia 11.2.0.1.0

Oracle Multimedia Annotator 11.2.0.1.0

Oracle Multimedia Client Option 11.2.0.1.0

Oracle Multimedia Java Advanced Imaging 11.2.0.1.0

Oracle Multimedia Locator 11.2.0.1.0

Oracle Multimedia Locator RDBMS Files 11.2.0.1.0

Oracle Net 11.2.0.1.0

Oracle Net Listener 11.2.0.1.0

Oracle Net Required Support Files 11.2.0.1.0

Oracle Net Services 11.2.0.1.0

Oracle Netca Client 11.2.0.1.0

Oracle Notification Service 11.2.0.0.0

Oracle Notification Service (eONS) 11.2.0.1.0

Oracle ODBC Driver 11.2.0.1.0

Oracle ODBC Driverfor Instant Client 11.2.0.1.0

Oracle OLAP 11.2.0.1.0

Oracle OLAP API 11.2.0.1.0

Oracle OLAP RDBMS Files 11.2.0.1.0

Oracle One-Off Patch Installer 11.2.0.0.2

Oracle Partitioning 11.2.0.1.0

Oracle Programmer 11.2.0.1.0

Oracle Quality of Service Management (Client) 11.2.0.1.0

Oracle RAC Deconfiguration 11.2.0.1.0

Oracle RAC Required Support Files-HAS 11.2.0.1.0

Oracle Real Application Testing 11.2.0.1.0

Oracle Recovery Manager 11.2.0.1.0

Oracle Security Developer Tools 11.2.0.1.0

Oracle Spatial 11.2.0.1.0

Oracle SQL Developer 11.2.0.1.0

Oracle Starter Database 11.2.0.1.0

Oracle Text 11.2.0.1.0

Oracle Text Required Support Files 11.2.0.1.0

Oracle UIX 2.2.24.5.0

Oracle Universal Connection Pool 11.2.0.1.0

Oracle Universal Installer 11.2.0.1.0

Oracle Wallet Manager 11.2.0.1.0

Oracle XML Development Kit 11.2.0.1.0

Oracle XML Query 11.2.0.1.0

Parser Generator Required Support Files 11.2.0.1.0

Perl Interpreter 5.10.0.0.1

Perl Modules 5.10.0.0.1

PL/SQL 11.2.0.1.0

PL/SQL Embedded Gateway 11.2.0.1.0

Platform Required Support Files 11.2.0.1.0

Precompiler Common Files 11.2.0.1.0

Precompiler Required Support Files 11.2.0.1.0

Provisioning Advisor Framework 10.2.0.4.2

RDBMS Required Support Files 11.2.0.1.0

RDBMS Required Support Files for Instant Client 11.2.0.1.0

regexp 2.1.9.0.0

Required Support Files 11.2.0.1.0

Sample Schema Data 11.2.0.1.0

Secure Socket Layer 11.2.0.1.0

SQL*Plus 11.2.0.1.0

SQL*Plus Files for Instant Client 11.2.0.1.0

SQL*Plus Required Support Files 11.2.0.1.0

SQLJ Runtime 11.2.0.1.0

SSL Required Support Files for InstantClient 11.2.0.1.0

Sun JDK 1.5.0.17.0

XDK Required Support Files 11.2.0.1.0

XML Parser for Java 11.2.0.1.0

XML Parser for Oracle JVM 11.2.0.1.0

There are 134 component(s) installed in this Oracle Home.

There are no Interim patches installed in this Oracle Home.

Rac system comprising of multiple nodes

Local node = rac1

Remote node = rac2

\----------------------------------------------------------------------------

OPatch succeeded.

解压缩补丁包：

 **[root@rac1 tmp]# unzip p9706490_112010_AIX64-5L.zip**

 **[root@rac1 tmp]# su - oracle**

 **[oracle@rac1 ~]$ srvctl stop home -o /u02/app/oracle/product/11.2.0/db_home
-s /home/oracle/stop.log -n rac1**

 **[oracle@rac1 ~]$ cat /home/oracle/stop.log**

db-orcl

 **[root@rac1 tmp]# /u01/app/11.2.0/grid/crs/install/rootcrs.pl -unlock**

2016-08-11 01:57:38: Parsing the host name

2016-08-11 01:57:38: Checking for super user privileges

2016-08-11 01:57:38: User has super user privileges

Using configuration parameter file:
/u01/app/11.2.0/grid/crs/install/crsconfig_params

CRS-2791: Starting shutdown of Oracle High Availability Services-managed
resources on 'rac1'

CRS-2673: Attempting to stop 'ora.crsd' on 'rac1'

CRS-2790: Starting shutdown of Cluster Ready Services-managed resources on
'rac1'

CRS-2673: Attempting to stop 'ora.CRS.dg' on 'rac1'

CRS-2673: Attempting to stop 'ora.registry.acfs' on 'rac1'

CRS-2673: Attempting to stop 'ora.DATA.dg' on 'rac1'

CRS-2673: Attempting to stop 'ora.FRA.dg' on 'rac1'

CRS-2673: Attempting to stop 'ora.LISTENER.lsnr' on 'rac1'

CRS-2673: Attempting to stop 'ora.LISTENER_SCAN1.lsnr' on 'rac1'

CRS-2677: Stop of 'ora.LISTENER.lsnr' on 'rac1' succeeded

CRS-2673: Attempting to stop 'ora.rac1.vip' on 'rac1'

CRS-2677: Stop of 'ora.rac1.vip' on 'rac1' succeeded

CRS-2672: Attempting to start 'ora.rac1.vip' on 'rac2'

CRS-2677: Stop of 'ora.LISTENER_SCAN1.lsnr' on 'rac1' succeeded

CRS-2673: Attempting to stop 'ora.scan1.vip' on 'rac1'

CRS-2677: Stop of 'ora.scan1.vip' on 'rac1' succeeded

CRS-2672: Attempting to start 'ora.scan1.vip' on 'rac2'

CRS-2677: Stop of 'ora.registry.acfs' on 'rac1' succeeded

CRS-2676: Start of 'ora.rac1.vip' on 'rac2' succeeded

CRS-2676: Start of 'ora.scan1.vip' on 'rac2' succeeded

CRS-2672: Attempting to start 'ora.LISTENER_SCAN1.lsnr' on 'rac2'

CRS-2676: Start of 'ora.LISTENER_SCAN1.lsnr' on 'rac2' succeeded

CRS-2677: Stop of 'ora.CRS.dg' on 'rac1' succeeded

CRS-2677: Stop of 'ora.DATA.dg' on 'rac1' succeeded

CRS-2677: Stop of 'ora.FRA.dg' on 'rac1' succeeded

CRS-2673: Attempting to stop 'ora.asm' on 'rac1'

CRS-2677: Stop of 'ora.asm' on 'rac1' succeeded

CRS-2673: Attempting to stop 'ora.ons' on 'rac1'

CRS-2673: Attempting to stop 'ora.eons' on 'rac1'

CRS-2677: Stop of 'ora.ons' on 'rac1' succeeded

CRS-2673: Attempting to stop 'ora.net1.network' on 'rac1'

CRS-2677: Stop of 'ora.net1.network' on 'rac1' succeeded

CRS-2677: Stop of 'ora.eons' on 'rac1' succeeded

CRS-2792: Shutdown of Cluster Ready Services-managed resources on 'rac1' has
completed

CRS-2677: Stop of 'ora.crsd' on 'rac1' succeeded

CRS-2673: Attempting to stop 'ora.cssdmonitor' on 'rac1'

CRS-2673: Attempting to stop 'ora.ctssd' on 'rac1'

CRS-2673: Attempting to stop 'ora.evmd' on 'rac1'

CRS-2673: Attempting to stop 'ora.asm' on 'rac1'

CRS-2673: Attempting to stop 'ora.drivers.acfs' on 'rac1'

CRS-2673: Attempting to stop 'ora.mdnsd' on 'rac1'

CRS-2677: Stop of 'ora.cssdmonitor' on 'rac1' succeeded

CRS-2677: Stop of 'ora.mdnsd' on 'rac1' succeeded

CRS-2677: Stop of 'ora.evmd' on 'rac1' succeeded

CRS-2677: Stop of 'ora.ctssd' on 'rac1' succeeded

CRS-2677: Stop of 'ora.drivers.acfs' on 'rac1' succeeded

CRS-2677: Stop of 'ora.asm' on 'rac1' succeeded

CRS-2673: Attempting to stop 'ora.cssd' on 'rac1'

CRS-2677: Stop of 'ora.cssd' on 'rac1' succeeded

CRS-2673: Attempting to stop 'ora.gpnpd' on 'rac1'

CRS-2673: Attempting to stop 'ora.diskmon' on 'rac1'

CRS-2677: Stop of 'ora.gpnpd' on 'rac1' succeeded

CRS-2673: Attempting to stop 'ora.gipcd' on 'rac1'

CRS-2677: Stop of 'ora.gipcd' on 'rac1' succeeded

CRS-2677: Stop of 'ora.diskmon' on 'rac1' succeeded

CRS-2793: Shutdown of Oracle High Availability Services-managed resources on
'rac1' has completed

CRS-4133: Oracle High Availability Services has been stopped.

Successfully unlock /u01/app/11.2.0/grid

 **[root@rac1 tmp]# chmod -R 777 9706490/**

 **[root@rac1 tmp]# su - oracle**

**[oracle@rac1 ~]$ cd /tmp/9706490/custom/server/9706490/custom/scripts/**

 **[oracle@rac1 scripts]$ ./prepatch.sh -dbhome $ORACLE_HOME**

./prepatch.sh completed successfully.

 **[root@rac1 tmp]# su - grid**

 **[grid@rac1 ~]$ cd /tmp/9706490/**

 **[grid@rac1 9706490]$ opatch napply -local -oh $ORACLE_HOME -id 9706490**

Oracle Interim Patch Installer version 11.2.0.3.6

Copyright (c) 2013, Oracle Corporation. All rights reserved.

Oracle Home : /u01/app/11.2.0/grid

Central Inventory : /u01/app/oraInventory

from : /u01/app/11.2.0/grid/oraInst.loc

OPatch version : 11.2.0.3.6

OUI version : 11.2.0.1.0

Log file location :
/u01/app/11.2.0/grid/cfgtoollogs/opatch/opatch2016-08-11_02-03-08AM_1.log

Verifying environment and performing prerequisite checks...

OPatch continues with these patches: 9706490

Do you want to proceed? [y|n]

y

User Responded with: Y

All checks passed.

Provide your email address to be informed of security issues, install and

initiate Oracle Configuration Manager. Easier for you if you use your My

Oracle Support Email address/User Name.

Visit http://www.oracle.com/support/policies.html for details.

Email address/User Name:

You have not provided an email address for notification of security issues.

Do you wish to remain uninformed of security issues ([Y]es, [N]o) [N]: **Y**

Please shutdown Oracle instances running out of this ORACLE_HOME on the local
system.

(Oracle Home = '/u01/app/11.2.0/grid')

Is the local system ready for patching? [y|n]

 **y**

User Responded with: Y

Backing up files...

Applying interim patch '9706490' to OH '/u01/app/11.2.0/grid'

Patching component oracle.crs, 11.2.0.1.0...

Patching component oracle.usm, 11.2.0.1.0...

Verifying the update...

Patch 9706490 successfully applied.

Log file location:
/u01/app/11.2.0/grid/cfgtoollogs/opatch/opatch2016-08-11_02-03-08AM_1.log

OPatch succeeded.

数据库也可以打上该patch

 **[root@rac1 tmp]# su - oracle**

 **[oracle@rac1 ~]$ cd /tmp/9706490/**

 **[oracle@rac1 9706490]$ opatch napply custom/server/ -local -oh $ORACLE_HOME
-id 9706490**

Oracle Interim Patch Installer version 11.2.0.3.6

Copyright (c) 2013, Oracle Corporation. All rights reserved.

Oracle Home : /u02/app/oracle/product/11.2.0/db_home

Central Inventory : /u01/app/oraInventory

from : /u02/app/oracle/product/11.2.0/db_home/oraInst.loc

OPatch version : 11.2.0.3.6

OUI version : 11.2.0.1.0

Log file location :
/u02/app/oracle/product/11.2.0/db_home/cfgtoollogs/opatch/opatch2016-08-11_02-07-20AM_1.log

Verifying environment and performing prerequisite checks...

OPatch continues with these patches: 9706490

Do you want to proceed? [y|n]

y

User Responded with: Y

All checks passed.

Provide your email address to be informed of security issues, install and

initiate Oracle Configuration Manager. Easier for you if you use your My

Oracle Support Email address/User Name.

Visit http://www.oracle.com/support/policies.html for details.

Email address/User Name:

You have not provided an email address for notification of security issues.

Do you wish to remain uninformed of security issues ([Y]es, [N]o) [N]: Y

Please shutdown Oracle instances running out of this ORACLE_HOME on the local
system.

(Oracle Home = '/u02/app/oracle/product/11.2.0/db_home')

Is the local system ready for patching? [y|n]

y

User Responded with: Y

Backing up files...

Applying interim patch '9706490' to OH
'/u02/app/oracle/product/11.2.0/db_home'

Patching component oracle.rdbms, 11.2.0.1.0...

Verifying the update...

Patch 9706490 successfully applied.

Log file location:
/u02/app/oracle/product/11.2.0/db_home/cfgtoollogs/opatch/opatch2016-08-11_02-07-20AM_1.log

OPatch succeeded.

第二节点执行以上操作，注意修改命令中主机名。

禁止两节点同时运行以下脚本，要依次运行！

 **[root@rac1 tmp]# /u01/app/11.2.0/grid/crs/install/rootcrs.pl -patch**

2016-08-11 02:18:26: Parsing the host name

2016-08-11 02:18:26: Checking for super user privileges

2016-08-11 02:18:26: User has super user privileges

Using configuration parameter file:
/u01/app/11.2.0/grid/crs/install/crsconfig_params

CRS-4123: Oracle High Availability Services has been started.

 **[root@rac1 tmp]# su - oracle**

 **[oracle@rac1 ~]$ srvctl start home -o
/u02/app/oracle/product/11.2.0/db_home -s /home/oracle/stop.log -n rac1**

第二节点执行以上操作，注意修改命令中主机名。

至此补丁修补完毕。

## 2.5 利用 CUV 重新检查

用 grid 用户在节点 1 执行：

 **[grid@rac1 ~]$ /tmp/grid/runcluvfy.sh stage -pre crsinst -upgrade -n
rac1,rac2 -rolling -src_crshome /u01/app/11.2.0/grid -dest_crshome
/u01/app/11.2.0.4/grid -dest_version 11.2.0.4.0**

Performing pre-checks for cluster services setup

Checking node reachability...

Node reachability check passed from node "rac1"

Checking user equivalence...

User equivalence check passed for user "grid"

Checking CRS user consistency

CRS user consistency check successful

Checking node connectivity...

Checking hosts config file...

Verification of the hosts config file successful

Check: Node connectivity for interface "en8"

Node connectivity passed for interface "en8"

TCP connectivity check passed for subnet "192.168.254.0"

Check: Node connectivity for interface "en9"

Node connectivity passed for interface "en9"

TCP connectivity check passed for subnet "10.0.0.0"

Checking subnet mask consistency...

Subnet mask consistency check passed for subnet "192.168.254.0".

Subnet mask consistency check passed for subnet "10.0.0.0".

Subnet mask consistency check passed.

Node connectivity check passed

Checking multicast communication...

Checking subnet "192.168.254.0" for multicast communication with multicast
group "230.0.1.0"...

Check of subnet "192.168.254.0" for multicast communication with multicast
group "230.0.1.0" passed.

Checking subnet "10.0.0.0" for multicast communication with multicast group
"230.0.1.0"...

Check of subnet "10.0.0.0" for multicast communication with multicast group
"230.0.1.0" passed.

Check of multicast communication passed.

Checking OCR integrity...

OCR integrity check passed

Total memory check passed

Available memory check passed

Swap space check passed

Free disk space check passed for "rac2:/u01/app/11.2.0.4/grid"

Free disk space check passed for "rac1:/u01/app/11.2.0.4/grid"

Free disk space check passed for "rac2:/tmp/"

Free disk space check passed for "rac1:/tmp/"

Check for multiple users with UID value 503 passed

User existence check passed for "grid"

Group existence check passed for "oinstall"

Membership check for user "grid" in group "oinstall" [as Primary] passed

Run level check passed

Hard limits check passed for "maximum open file descriptors"

Soft limits check passed for "maximum open file descriptors"

Hard limits check passed for "maximum user processes"

Soft limits check passed for "maximum user processes"

Check for Oracle patch "9706490 or 9413827" in home "/u01/app/11.2.0/grid"
passed

There are no oracle patches required for home "/u01/app/11.2.0.4/grid".

System architecture check passed

Kernel version check passed

Kernel parameter check passed for "ncargs"

Kernel parameter check passed for "maxuproc"

Kernel parameter check passed for "tcp_ephemeral_low"

Kernel parameter check passed for "tcp_ephemeral_high"

Kernel parameter check passed for "udp_ephemeral_low"

Kernel parameter check passed for "udp_ephemeral_high"

Package existence check passed for "bos.adt.base"

Package existence check passed for "bos.adt.lib"

Package existence check passed for "bos.adt.libm"

Package existence check passed for "bos.perf.libperfstat"

Package existence check passed for "bos.perf.perfstat"

Package existence check passed for "bos.perf.proctools"

Package existence check passed for "xlC.aix61.rte"

Package existence check passed for "xlC.rte"

Operating system patch check passed for "Patch IZ97457"

Check for multiple users with UID value 0 passed

Current group ID check passed

Starting check for consistency of primary group of root user

Check for consistency of root user's primary group passed

Starting Clock synchronization checks using Network Time Protocol(NTP)...

NTP Configuration file check started...

No NTP Daemons or Services were found to be running

Clock synchronization check using Network Time Protocol(NTP) passed

Core file name pattern consistency check passed.

User "grid" is not part of "system" group. Check passed

Default user file creation mask check passed

Checking consistency of file "/etc/resolv.conf" across nodes

File "/etc/resolv.conf" does not exist on any node of the cluster. Skipping
further checks

File "/etc/resolv.conf" is consistent across nodes

Time zone consistency check passed

Checking VIP configuration.

Checking VIP Subnet configuration.

Check for VIP Subnet configuration passed.

Checking VIP reachability

Check for VIP reachability passed.

Checking Oracle Cluster Voting Disk configuration...

ASM Running check passed. ASM is running on all specified nodes

Oracle Cluster Voting Disk configuration check passed

Clusterware version consistency passed

User ID < 65535 check passed

Kernel 64-bit mode check passed

Starting check for Network parameter - ipqmaxlen ...

ERROR:

PRVE-0273 : The value of network parameter "ipqmaxlen" for interface "en9" is
not configured to the expected value on node "rac2".[Expected="512";
Found="en9=100"]

PRVE-0273 : The value of network parameter "ipqmaxlen" for interface "en9" is
not configured to the expected value on node "rac1".[Expected="512";
Found="en9=100"]

Check for Network parameter - ipqmaxlen failed

Starting check for Network parameter - rfc1323 ...

ERROR:

PRVE-0273 : The value of network parameter "rfc1323" for interface "en9" is
not configured to the expected value on node "rac2".[Expected="1";
Found="en9=0"]

PRVE-0273 : The value of network parameter "rfc1323" for interface "en9" is
not configured to the expected value on node "rac1".[Expected="1";
Found="en9=0"]

Check for Network parameter - rfc1323 failed

Starting check for Network parameter - sb_max ...

ERROR:

PRVE-0273 : The value of network parameter "sb_max" for interface "en9" is not
configured to the expected value on node "rac2".[Expected="4194304";
Found="en9=1500000"]

PRVE-0273 : The value of network parameter "sb_max" for interface "en9" is not
configured to the expected value on node "rac1".[Expected="4194304";
Found="en9=1500000"]

Check for Network parameter - sb_max failed

Starting check for Network parameter - tcp_sendspace ...

Check for Network parameter - tcp_sendspace passed

Starting check for Network parameter - tcp_recvspace ...

Check for Network parameter - tcp_recvspace passed

Starting check for Network parameter - udp_sendspace ...

ERROR:

PRVE-0273 : The value of network parameter "udp_sendspace" for interface "en9"
is not configured to the expected value on node "rac2".[Expected="65536";
Found="en9=13516"]

PRVE-0273 : The value of network parameter "udp_sendspace" for interface "en9"
is not configured to the expected value on node "rac1".[Expected="65536";
Found="en9=13516"]

Check for Network parameter - udp_sendspace failed

Starting check for Network parameter - udp_recvspace ...

ERROR:

PRVE-0273 : The value of network parameter "udp_recvspace" for interface "en9"
is not configured to the expected value on node "rac2".[Expected="655360";
Found="en9=42080"]

PRVE-0273 : The value of network parameter "udp_recvspace" for interface "en9"
is not configured to the expected value on node "rac1".[Expected="655360";
Found="en9=42080"]

Check for Network parameter - udp_recvspace failed

Pre-check for cluster services setup was unsuccessful on all the nodes.

成功。

## 2.6检查集群状态：

 **[grid@rac1 ~]$ crsctl stat res -t**

\--------------------------------------------------------------------------------

NAME TARGET STATE SERVER STATE_DETAILS

\--------------------------------------------------------------------------------

Local Resources

\--------------------------------------------------------------------------------

ora.CRS.dg

ONLINE ONLINE rac1

ONLINE ONLINE rac2

ora.DATA.dg

ONLINE ONLINE rac1

ONLINE ONLINE rac2

ora.FRA.dg

ONLINE ONLINE rac1

ONLINE ONLINE rac2

ora.LISTENER.lsnr

ONLINE ONLINE rac1

ONLINE ONLINE rac2

ora.asm

ONLINE ONLINE rac1 Started

ONLINE ONLINE rac2 Started

ora.eons

ONLINE ONLINE rac1

ONLINE ONLINE rac2

ora.gsd

OFFLINE OFFLINE rac1

OFFLINE OFFLINE rac2

ora.net1.network

ONLINE ONLINE rac1

ONLINE ONLINE rac2

ora.ons

ONLINE ONLINE rac1

ONLINE ONLINE rac2

ora.registry.acfs

ONLINE ONLINE rac1

ONLINE ONLINE rac2

ora.LISTENER_SCAN1.lsnr

1 ONLINE ONLINE rac1

ora.oc4j

1 OFFLINE OFFLINE

ora.orcl.db

1 ONLINE ONLINE rac1 Open

2 ONLINE ONLINE rac2 Open

ora.rac1.vip

1 ONLINE ONLINE rac1

ora.rac2.vip

1 ONLINE ONLINE rac2

ora.scan1.vip

1 ONLINE ONLINE rac1

## 2.7安装11.2.0.4集群软件

以下截图供参考。

直接test通过的话就不用点setup。

新gi home已在上述步骤提前创建，修改正确后下一步。

 **注意： grid 用户环境变量 ORACLE_HOME 不在ORACLE_BASE 目录下**

 ****

 ****

 ****

 ****

安装。

根据提示在节点 1 用 root 用户运行 rootupgrade.sh：

 **[root@rac1 tmp]# /u01/app/11.2.0.4/grid/rootupgrade.sh**

Performing root user operation for Oracle 11g

The following environment variables are set as:

ORACLE_OWNER= grid

ORACLE_HOME= /u01/app/11.2.0.4/grid

Enter the full pathname of the local bin directory: [/usr/local/bin]:

The contents of "dbhome" have not changed. No need to overwrite.

The file "oraenv" already exists in /usr/local/bin. Overwrite it? (y/n)

[n]: **y**

Copying oraenv to /usr/local/bin ...

The file "coraenv" already exists in /usr/local/bin. Overwrite it? (y/n)

[n]: **y**

Copying coraenv to /usr/local/bin ...

Entries will be added to the /etc/oratab file as needed by

Database Configuration Assistant when a database is created

Finished running generic part of root script.

Now product-specific root actions will be performed.

Using configuration parameter file:
/u01/app/11.2.0.4/grid/crs/install/crsconfig_params

Creating trace directory

Installing Trace File Analyzer

ASM upgrade has started on first node.

CRS-2791: Starting shutdown of Oracle High Availability Services-managed
resources on 'rac1'

CRS-2673: Attempting to stop 'ora.crsd' on 'rac1'

CRS-2790: Starting shutdown of Cluster Ready Services-managed resources on
'rac1'

CRS-2673: Attempting to stop 'ora.CRS.dg' on 'rac1'

CRS-2673: Attempting to stop 'ora.orcl.db' on 'rac1'

CRS-2673: Attempting to stop 'ora.registry.acfs' on 'rac1'

CRS-2673: Attempting to stop 'ora.LISTENER.lsnr' on 'rac1'

CRS-2673: Attempting to stop 'ora.LISTENER_SCAN1.lsnr' on 'rac1'

CRS-2677: Stop of 'ora.registry.acfs' on 'rac1' succeeded

CRS-2677: Stop of 'ora.LISTENER.lsnr' on 'rac1' succeeded

CRS-2673: Attempting to stop 'ora.rac1.vip' on 'rac1'

CRS-2677: Stop of 'ora.LISTENER_SCAN1.lsnr' on 'rac1' succeeded

CRS-2673: Attempting to stop 'ora.scan1.vip' on 'rac1'

CRS-2677: Stop of 'ora.rac1.vip' on 'rac1' succeeded

CRS-2672: Attempting to start 'ora.rac1.vip' on 'rac2'

CRS-2677: Stop of 'ora.scan1.vip' on 'rac1' succeeded

CRS-2672: Attempting to start 'ora.scan1.vip' on 'rac2'

CRS-2676: Start of 'ora.rac1.vip' on 'rac2' succeeded

CRS-2676: Start of 'ora.scan1.vip' on 'rac2' succeeded

CRS-2672: Attempting to start 'ora.LISTENER_SCAN1.lsnr' on 'rac2'

CRS-2676: Start of 'ora.LISTENER_SCAN1.lsnr' on 'rac2' succeeded

CRS-2677: Stop of 'ora.CRS.dg' on 'rac1' succeeded

CRS-2677: Stop of 'ora.orcl.db' on 'rac1' succeeded

CRS-2673: Attempting to stop 'ora.DATA.dg' on 'rac1'

CRS-2673: Attempting to stop 'ora.FRA.dg' on 'rac1'

CRS-2677: Stop of 'ora.DATA.dg' on 'rac1' succeeded

CRS-2677: Stop of 'ora.FRA.dg' on 'rac1' succeeded

CRS-2673: Attempting to stop 'ora.asm' on 'rac1'

CRS-2677: Stop of 'ora.asm' on 'rac1' succeeded

CRS-2673: Attempting to stop 'ora.eons' on 'rac1'

CRS-2673: Attempting to stop 'ora.ons' on 'rac1'

CRS-2677: Stop of 'ora.ons' on 'rac1' succeeded

CRS-2673: Attempting to stop 'ora.net1.network' on 'rac1'

CRS-2677: Stop of 'ora.net1.network' on 'rac1' succeeded

CRS-2677: Stop of 'ora.eons' on 'rac1' succeeded

CRS-2792: Shutdown of Cluster Ready Services-managed resources on 'rac1' has
completed

CRS-2677: Stop of 'ora.crsd' on 'rac1' succeeded

CRS-2673: Attempting to stop 'ora.drivers.acfs' on 'rac1'

CRS-2673: Attempting to stop 'ora.mdnsd' on 'rac1'

CRS-2673: Attempting to stop 'ora.cssdmonitor' on 'rac1'

CRS-2673: Attempting to stop 'ora.ctssd' on 'rac1'

CRS-2673: Attempting to stop 'ora.evmd' on 'rac1'

CRS-2673: Attempting to stop 'ora.asm' on 'rac1'

CRS-2677: Stop of 'ora.cssdmonitor' on 'rac1' succeeded

CRS-2677: Stop of 'ora.mdnsd' on 'rac1' succeeded

CRS-2677: Stop of 'ora.evmd' on 'rac1' succeeded

CRS-2677: Stop of 'ora.ctssd' on 'rac1' succeeded

CRS-2677: Stop of 'ora.drivers.acfs' on 'rac1' succeeded

CRS-2677: Stop of 'ora.asm' on 'rac1' succeeded

CRS-2673: Attempting to stop 'ora.cssd' on 'rac1'

CRS-2677: Stop of 'ora.cssd' on 'rac1' succeeded

CRS-2673: Attempting to stop 'ora.gpnpd' on 'rac1'

CRS-2673: Attempting to stop 'ora.diskmon' on 'rac1'

CRS-2677: Stop of 'ora.gpnpd' on 'rac1' succeeded

CRS-2673: Attempting to stop 'ora.gipcd' on 'rac1'

CRS-2677: Stop of 'ora.gipcd' on 'rac1' succeeded

CRS-2677: Stop of 'ora.diskmon' on 'rac1' succeeded

CRS-2793: Shutdown of Oracle High Availability Services-managed resources on
'rac1' has completed

CRS-4133: Oracle High Availability Services has been stopped.

OLR initialization - successful

Replacing Clusterware entries in inittab

clscfg: EXISTING configuration version 5 detected.

clscfg: version 5 is 11g Release 2.

Successfully accumulated necessary OCR keys.

Creating OCR keys for user 'root', privgrp 'root'..

Operation successful.

Preparing packages for installation...

cvuqdisk-1.0.9-1

Configure Oracle Grid Infrastructure for a Cluster ... succeeded

根据提示在节点 2 用 root 用户运行 rootupgrade.sh（输出略）：

 **[root@rac2 tmp]# /u01/app/11.2.0.4/grid/rootupgrade.sh**

回到OUI点确定。

点ok，点下一步。

点yes。

点close。

检查GI 版本：

 **[root@rac1 tmp]# su - grid**

 **[grid@rac1 ~]$ crsctl query crs activeversion**

Oracle Clusterware active version on the cluster is [11.2.0.4.0]

 **[grid@rac2 ~]$ crsctl query crs activeversion**

Oracle Clusterware active version on the cluster is [11.2.0.4.0]

2.7 修改grid环境变量

修改所有节点：

 **[grid@rac1 ~]$ vi .profile**

umask 022

if [ -t 0 ]; then

stty intr ^C

fi

export AIXTHREAD_SCOPE=S **#** ** _注（_** ** _mos ID 169706.1 AIX Kernel
Settings_** ** _）_**

PATH=$PATH:$HOME/bin

export PATH

ORACLE_SID=+ASM1; export ORACLE_SID

ORACLE_BASE=/u01/app/grid; export ORACLE_BASE

ORACLE_HOME=/u01/app/11.2.0.4/grid; export ORACLE_HOME

ORACLE_PATH=/u01/app/oracle/common/oracle/sql; export ORACLE_PATH

umask 022

PATH=$ORACLE_HOME/bin:$PATH:$HOME/bin:$ORACLE_PATH:/u01/app/11.2.0/grid/OPatch

export PATH

 **[grid@rac2 ~]$ vi .profile**

umask 022

if [ -t 0 ]; then

stty intr ^C

fi

export AIXTHREAD_SCOPE=S **#** ** _注（_** ** _mos ID 169706.1 AIX Kernel
Settings_** ** _）_**

PATH=$PATH:$HOME/bin

export PATH

ORACLE_SID=+ASM2; export ORACLE_SID

ORACLE_BASE=/u01/app/grid; export ORACLE_BASE

ORACLE_HOME=/u01/app/11.2.0.4/grid; export ORACLE_HOME

ORACLE_PATH=/u01/app/oracle/common/oracle/sql; export ORACLE_PATH

umask 022

PATH=$ORACLE_HOME/bin:$PATH:$HOME/bin:$ORACLE_PATH:/u01/app/11.2.0/grid/OPatch

export PATH

至此GI升级完毕。

# 3 升级数据库

## 3.1下载介质，解压缩。

 **unzip p13390677_112040_AIX64-5L_1of7.zip -d /tmp/**

 **unzip p13390677_112040_AIX64-5L_2of7.zip -d /tmp/**

## 3.2 创建新oracle home。

 **[root@rac1 tmp]# mkdir -p /u02/app/oracle/product/11.2.0.4/db_home2**

 **[root@rac1 tmp]# chown oracle:oinstall
/u02/app/oracle/product/11.2.0.4/db_home2**

 **[root@rac2 tmp]# mkdir -p /u02/app/oracle/product/11.2.0.4/db_home2**

 **[root@rac2 tmp]# chown oracle:oinstall
/u02/app/oracle/product/11.2.0.4/db_home2**

在安装前一定要取消 oracle 用户的 ORACLE_BASE, ORACLE_HOME, ORACLE_SID 等的设置。

 **[oracle@racX ~]$ vi .profile**

umask 022

if [ -t 0 ]; then

stty intr ^C

fi

export AIXTHREAD_SCOPE=S

#export ORACLE_SID=orclX

#export ORACLE_BASE=/u02/app/oracle

#export ORACLE_HOME=/u02/app/oracle/product/11.2.0/db_home

#PATH=$ORACLE_HOME/bin:$PATH:$HOME/bin:/u02/app/oracle/product/11.2.0/db_home/OPatch

#export LIBPATH=$ORACLE_HOME/lib:$ORACLE_HOME/rdbms/lib:/lib:/usr/lib

#export
CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib:$ORACLE_HOME/network/jlb

export ORACLE_OWNER=oracle

PATH=$PATH:$HOME/bin

export PATH

这个时候只是安装软件，对运行的数据库没有影响，数据库是启动和停止的都可以。

## 3.3图形安装

以下截图供参考。

忽略单scan警告。勾选即可下一步。

点yes。

开始安装。

两节点运行root脚本。

 **[root@rac1 ~]# /u02/app/oracle/product/11.2.0.4/db_home2/root.sh**

Performing root user operation for Oracle 11g

The following environment variables are set as:

ORACLE_OWNER= oracle

ORACLE_HOME= /u02/app/oracle/product/11.2.0.4/db_home2

Enter the full pathname of the local bin directory: [/usr/local/bin]:

The contents of "dbhome" have not changed. No need to overwrite.

The contents of "oraenv" have not changed. No need to overwrite.

The contents of "coraenv" have not changed. No need to overwrite.

Entries will be added to the /etc/oratab file as needed by

Database Configuration Assistant when a database is created

Finished running generic part of root script.

Now product-specific root actions will be performed.

Finished product-specific root actions.

 **[root@rac2 ~]# /u02/app/oracle/product/11.2.0.4/db_home2/root.sh**

Performing root user operation for Oracle 11g

The following environment variables are set as:

ORACLE_OWNER= oracle

ORACLE_HOME= /u02/app/oracle/product/11.2.0.4/db_home2

Enter the full pathname of the local bin directory: [/usr/local/bin]:

The contents of "dbhome" have not changed. No need to overwrite.

The contents of "oraenv" have not changed. No need to overwrite.

The contents of "coraenv" have not changed. No need to overwrite.

Entries will be added to the /etc/oratab file as needed by

Database Configuration Assistant when a database is created

Finished running generic part of root script.

Now product-specific root actions will be performed.

Finished product-specific root actions.

## 3.4数据库升级

### 3.4.1 升级前检查

 **[root@rac1 ~]# su - oracle**

 **[oracle@rac1 ~]$ export
ORACLE_HOME=/u02/app/oracle/product/11.2.0/db_home**

注意是旧目录

 **[oracle@rac1 ~]$ export ORACLE_SID=orcl1**

启动数据库（如果之前已经关闭了的话）：

 **[oracle@rac1 ~]$ $ORACLE_HOME/bin/srvctl start database -d orcl**

 **[oracle@rac1 ~]$ $ORACLE_HOME/bin/srvctl status database -d orcl**

Instance orcl1 is running on node rac1

Instance orcl2 is running on node rac2

执行新目录下的 utlu112i.sql 来进行升级前的检查：

 **[oracle@rac1 ~]$ $ORACLE_HOME/bin/sqlplus / as sysdba**

SQL*Plus: Release 11.2.0.1.0 Production on Thu Aug 11 04:09:18 2016

Copyright (c) 1982, 2009, Oracle. All rights reserved.

Connected to:

Oracle Database 11g Enterprise Edition Release 11.2.0.1.0 - 64bit Production

With the Partitioning, Real Application Clusters, Automatic Storage
Management, OLAP,

Data Mining and Real Application Testing options

 **SQL > @/u02/app/oracle/product/11.2.0.4/db_home2/rdbms/admin/utlu112i.sql**

这是新的 ORACLE_HOME 下面的脚本

Oracle Database 11.2 Pre-Upgrade Information Tool 08-11-2016 04:11:33

Script Version: 11.2.0.4.0 Build: 001

.

**********************************************************************

Database:

**********************************************************************

\--> name: ORCL

\--> version: 11.2.0.1.0

\--> compatible: 11.2.0.0.0

\--> blocksize: 8192

\--> platform: Linux x86 64-bit

\--> timezone file: V11

.

**********************************************************************

Tablespaces: [make adjustments in the current environment]

**********************************************************************

\--> SYSTEM tablespace is adequate for the upgrade.

.... minimum required size: 895 MB

\--> SYSAUX tablespace is adequate for the upgrade.

.... minimum required size: 650 MB

\--> UNDOTBS1 tablespace is adequate for the upgrade.

.... minimum required size: 400 MB

\--> TEMP tablespace is adequate for the upgrade.

.... minimum required size: 60 MB

\--> EXAMPLE tablespace is adequate for the upgrade.

.... minimum required size: 78 MB

.

**********************************************************************

Flashback: OFF

**********************************************************************

**********************************************************************

Update Parameters: [Update Oracle Database 11.2 init.ora or spfile]

Note: Pre-upgrade tool was run on a lower version 64-bit database.

**********************************************************************

\--> If Target Oracle is 32-Bit, refer here for Update Parameters:

\-- No update parameter changes are required.

.

\--> If Target Oracle is 64-Bit, refer here for Update Parameters:

\-- No update parameter changes are required.

.

**********************************************************************

Renamed Parameters: [Update Oracle Database 11.2 init.ora or spfile]

**********************************************************************

\-- No renamed parameters found. No changes are required.

.

**********************************************************************

Obsolete/Deprecated Parameters: [Update Oracle Database 11.2 init.ora or
spfile]

**********************************************************************

\-- No obsolete parameters found. No changes are required

.

**********************************************************************

Components: [The following database components will be upgraded or installed]

**********************************************************************

\--> Oracle Catalog Views [upgrade] VALID

\--> Oracle Packages and Types [upgrade] VALID

\--> JServer JAVA Virtual Machine [upgrade] VALID

\--> Oracle XDK for Java [upgrade] VALID

\--> Real Application Clusters [upgrade] VALID

\--> Oracle Workspace Manager [upgrade] VALID

\--> OLAP Analytic Workspace [upgrade] VALID

\--> OLAP Catalog [upgrade] VALID

\--> EM Repository [upgrade] VALID

\--> Oracle Text [upgrade] VALID

\--> Oracle XML Database [upgrade] VALID

\--> Oracle Java Packages [upgrade] VALID

\--> Oracle interMedia [upgrade] VALID

\--> Spatial [upgrade] VALID

\--> Expression Filter [upgrade] VALID

\--> Rule Manager [upgrade] VALID

\--> Oracle Application Express [upgrade] VALID

... APEX will only be upgraded if the version of APEX in

... the target Oracle home is higher than the current one.

\--> Oracle OLAP API [upgrade] VALID

.

**********************************************************************

Miscellaneous Warnings

**********************************************************************

WARNING: --> The "cluster_database" parameter is currently "TRUE"

.... and must be set to "FALSE" prior to running a manual upgrade.

WARNING: --> Database is using a timezone file older than version 14.

.... After the release migration, it is recommended that DBMS_DST package

.... be used to upgrade the 11.2.0.1.0 database timezone version

.... to the latest version which comes with the new release.

WARNING: --> Your recycle bin is turned on and currently contains no objects.

.... Because it is REQUIRED that the recycle bin be empty prior to upgrading

.... and your recycle bin is turned on, you may need to execute the command:

PURGE DBA_RECYCLEBIN

.... prior to executing your upgrade to confirm the recycle bin is empty.

WARNING: --> Database contains schemas with objects dependent on DBMS_LDAP
package.

.... Refer to the 11g Upgrade Guide for instructions to configure Network
ACLs.

.... USER APEX_030200 has dependent objects.

.

**********************************************************************

Recommendations

**********************************************************************

Oracle recommends gathering dictionary statistics prior to

upgrading the database.

To gather dictionary statistics execute the following command

while connected as SYSDBA:

EXECUTE dbms_stats.gather_dictionary_stats;

**********************************************************************

Oracle recommends reviewing any defined events prior to upgrading.

To view existing non-default events execute the following commands

while connected AS SYSDBA:

Events:

SELECT (translate(value,chr(13)||chr(10),' ')) FROM sys.v$parameter2

WHERE UPPER(name) ='EVENT' AND isdefault='FALSE'

Trace Events:

SELECT (translate(value,chr(13)||chr(10),' ')) from sys.v$parameter2

WHERE UPPER(name) = '_TRACE_EVENTS' AND isdefault='FALSE'

Changes will need to be made in the init.ora or spfile.

**********************************************************************

SQL>

参考Applying the DSTv14 update for the Oracle Database (文档 ID
1109924.1)。无需升级时区文件。

参考utlu112i.sql Warning Database contains schemas with objects dependent on
DBMS_LDAP package USER APPS has dependent objects (文档 ID 1536345.1)可忽略该问题。

清空回收站：

 **SQL > PURGE DBA_RECYCLEBIN ;**

收集统计信息，一般可以提高升级速度：

 **SQL > EXECUTE dbms_stats.gather_dictionary_stats;**

### 3.4.2 创建担保还原点：

 **SQL > ALTER SYSTEM SET DB_RECOVERY_FILE_DEST_SIZE='6000m';**

System altered.

 **SQL > alter system set db_recovery_file_dest='+DATA';**

System altered.

 **SQL > CREATE RESTORE POINT dbua001 GUARANTEE FLASHBACK DATABASE;**

Restore point created.

### 3.4.3 DBUA 升级（二选一）

root执行：

xhost +

用 oracle 用户执行：

/u02/app/oracle/product/11.2.0.4/db_home2/bin/dbua

以上问题均已处理。点yes。

升级后编译无效对象，建议业务开并行，加速编译无效对象。

可勾选升级时区版本。

无需EM的去掉勾选。

点击完成开始升级。

升级过程要密切关注alert log、系统空间使用率和ASM diskgroup使用率！

修改 oracle 用户的 ORACLE_HOME 和 PATH 到新的路径

所有节点都修改：

 **[oracle@racX ~]$ vi .profile**

export ORACLE_BASE=/u02/app/oracle

export ORACLE_HOME=$ORACLE_BASE/product/11.2.0.4/db_home2

ORACLE_SID=orcl1; export ORACLE_SID

### 3.4.4 手动升级（二选一）

 **[root@rac1 ~]# su - oracle**

 **[oracle@rac1 ~]$ export
ORACLE_HOME=/u02/app/oracle/product/11.2.0/db_home**

注意是旧目录

 **[oracle@rac1 ~]$ export ORACLE_SID=orcl1**

 **[oracle@rac1 ~]$ $ORACLE_HOME/bin/sqlplus / as sysdba**

修改参数 CLUSTER_DATABASE为 false.

 **SQL > show parameter CLUSTER_DATABASE **

NAME TYPE VALUE

\------------------------------------ -----------
------------------------------

cluster_database boolean TRUE

 **SQL > alter system set cluster_database=FALSE SCOPE=SPFILE;**

System altered.

关闭数据库

 **[oracle@rac1 ~]$ $ORACLE_HOME/bin/srvctl stop database -d orcl**

修改环境变量等

 **[oracle@ rac1 ~]$ vi .profile ---** **修改如下行路径**

# .profile

# Get the aliases and functions

if [ -f ~/.bashrc ]; then

. ~/.bashrc

fi

# User specific environment and startup programs

PATH=$PATH:$HOME/bin

export PATH

export ORACLE_SID=orcl1

export ORACLE_BASE=/u02/app/oracle

export ORACLE_HOME=/u02/app/oracle/product/11.2.0.4/db_home

PATH=$ORACLE_HOME/bin:$PATH:$HOME/bin:/u02/app/oracle/product/11.2.0.4/db_home/OPatch

umask 022

export PATH

**[oracle@rac1 ~]$ vi /etc/oratab ------** **修改如下行路径**

orcl:/u02/app/oracle/product/11.2.0.4/db_home2:N

**[oracle@rac1 admin]$ cp /u02/app/oracle/product/11.2.0/db_home/dbs/*
/u02/app/oracle/product/11.2.0.4/db_home2/dbs/**

复制监听文件：

 **[oracle@db01 admin]$ cp -R
/u02/app/oracle/product/11.2.0/db_home/network/admin/*
/u02/app/oracle/product/11.2.0.4/db_home2/network/admin/**

 **检查** **oracle** **可执行文件权限**

 **$ORACLE_HOME/bin/oracle** **可执行文件正确属主应该是** **oracle:asmadmin** **，并且权限必须有**
**s** **共享才可以，如下：**

 **oracle@host:[/oracle/database/product/11.2.0/dbhome_1/bin] ll oracle**

 **-rwsr-s--x 1 oracle asmadmin 232399473 Dec 19 14:51 oracle**

 **如果** **oracle** **可执行文件权限不对，可以执行下面命令：**

 **${GI_HOME}/bin/setasmgidwrap -o ${ORACLE_HOME}/bin/oracle**

 **执行完毕以后检查** **oracle** **可执行文件的权限：**

 **ls -l ${ORACLE_HOME}/bin/oracle**

准备工作完成。

 **[root@rac1 ~]# su - oracle**

 **[oracle@rac1 ~]$ sqlplus / as sysdba**

SQL*Plus: Release 11.2.0.4.0 Production on Fri Aug 12 02:54:18 2016

Copyright (c) 1982, 2013, Oracle. All rights reserved.

Connected to an idle instance.

 **SQL > startup upgrade;**

ORACLE instance started.

Total System Global Area 1603411968 bytes

Fixed Size 2253664 bytes

Variable Size 520096928 bytes

Database Buffers 1073741824 bytes

Redo Buffers 7319552 bytes

Database mounted.

Database opened.

 **SQL > set echo on**

 **SQL > spool /home/oracle/upgrade08.log**

 **SQL > set time on;**

 **SQL >@?/rdbms/admin/catupgrd.sql**

脚本输出见附录。

 **升级过程要密切关注alert log、系统空间使用率和ASM diskgroup使用率！**

启动数据库。

 **SQL > startup**

ORACLE instance started.

Total System Global Area 1603411968 bytes

Fixed Size 2253664 bytes

Variable Size 603983008 bytes

Database Buffers 989855744 bytes

Redo Buffers 7319552 bytes

Database mounted.

Database opened.

 **SQL > @?/rdbms/admin/** **catuppst.sql**

清理无效对象：

 **SQL > @?/rdbms/admin/utlrp.sql**

将参数cluster_database改回true

 **SQL > alter system set cluster_database=TRUE SCOPE=SPFILE;**

System altered.

 **SQL > SHUTDOWN IMMEDIATE;**

Database closed.

Database dismounted.

ORACLE instance shut down.

使用下面的命令升级 Oracle Clusterware中的数据库配置

 **[oracle@rac1 ~]$ srvctl upgrade database -d orcl -o
/u02/app/oracle/product/11.2.0.4/db_home2**

启动数据库：

 **[oracle@rac1 ~]$ srvctl start database -d orcl**

## 3.5 后续工作

检查数据库版本：

 **SQL > column comp_name format a30**

 **SQL > column version format a15**

 **SQL > column status format a10**

 **SQL > column schema format a10**

 **SQL > set line 200**

 **SQL > select comp_name,version,status,schema from dba_registry;**

COMP_NAME VERSION STATUS SCHEMA

\------------------------------ --------------- ---------- ----------

OWB 11.2.0.1.0 VALID OWBSYS

Oracle Application Express 3.2.1.00.10 VALID APEX_030200

Oracle Enterprise Manager 11.2.0.4.0 VALID SYSMAN

OLAP Catalog 11.2.0.4.0 VALID OLAPSYS

Spatial 11.2.0.4.0 VALID MDSYS

Oracle Multimedia 11.2.0.4.0 VALID ORDSYS

Oracle XML Database 11.2.0.4.0 VALID XDB

Oracle Text 11.2.0.4.0 VALID CTXSYS

Oracle Expression Filter 11.2.0.4.0 VALID EXFSYS

Oracle Rules Manager 11.2.0.4.0 VALID EXFSYS

Oracle Workspace Manager 11.2.0.4.0 VALID WMSYS

Oracle Database Catalog Views 11.2.0.4.0 VALID SYS

Oracle Database Packages and T ypes 11.2.0.4.0 VALID SYS

JServer JAVA Virtual Machine 11.2.0.4.0 VALID SYS

Oracle XDK 11.2.0.4.0 VALID SYS

Oracle Database Java Packages 11.2.0.4.0 VALID SYS

OLAP Analytic Workspace 11.2.0.4.0 VALID SYS

Oracle OLAP API 11.2.0.4.0 VALID SYS

Oracle Real Application Clusters 11.2.0.4.0 VALID SYS

19 rows selected.

 **SQL > select * from v$version;**

BANNER

\----------------------------------------------------------------------

Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production

PL/SQL Release 11.2.0.4.0 - Production

CORE 11.2.0.4.0 Production

TNS for Linux: Version 11.2.0.4.0 - Production

NLSRTL Version 11.2.0.4.0 - Production

检查无效对象：

 **SQL > column object_name format a30**

 **SQL > column object_type format a20**

 **SQL > column status format a10**

 **SQL > select owner,object_name,object_type,status from dba_objects where
status<>'VALID';**

no rows selected

DBUA勾选升级时区文件时检查时区文件版本。手动升级可无需升级时区文件。参考Applying the DSTv14 update for the
Oracle Database (文档 ID 1109924.1)。

如果需要升级的话可以到MOS: Scripts to automatically update the RDBMS DST (timezone)
version in an 11gR2 or 12cR1 database . (文档 ID 1585343.1)

下载时区文件升级脚本进行升级。

 **SQL > SELECT version FROM v$timezone_file;**

VERSION

\----------

14

检查集群状态：

 **[grid@rac2 ~]$ crsctl stat res -t**

\------------------------------------------------------------------------

NAME TARGET STATE SERVER STATE_DETAILS

\------------------------------------------------------------------------

Local Resources

\------------------------------------------------------------------------

ora.CRS.dg

ONLINE ONLINE rac1

ONLINE ONLINE rac2

ora.DATA.dg

ONLINE ONLINE rac1

ONLINE ONLINE rac2

ora.FRA.dg

ONLINE ONLINE rac1

ONLINE ONLINE rac2

ora.LISTENER.lsnr

ONLINE ONLINE rac1

ONLINE ONLINE rac2

ora.asm

ONLINE ONLINE rac1 Started

ONLINE ONLINE rac2 Started

ora.gsd

OFFLINE OFFLINE rac1

OFFLINE OFFLINE rac2

ora.net1.network

ONLINE ONLINE rac1

ONLINE ONLINE rac2

ora.ons

ONLINE ONLINE rac1

ONLINE ONLINE rac2

ora.registry.acfs

ONLINE ONLINE rac1

ONLINE ONLINE rac2

ora.LISTENER_SCAN1.lsnr

1 ONLINE ONLINE rac2

ora.cvu

1 ONLINE ONLINE rac2

ora.oc4j

1 ONLINE ONLINE rac2

ora.orcl.db

1 ONLINE ONLINE rac1 Open

2 ONLINE ONLINE rac2 Open

ora.rac1.vip

1 ONLINE ONLINE rac1

ora.rac2.vip

1 ONLINE ONLINE rac2

ora.scan1.vip

1 ONLINE ONLINE rac2

删除还原点。

 **SQL > drop RESTORE POINT dbua001;**

至此。升级工作完成。

运行稳定后较长的一段时间后，删除11.2.0.1的软件。

# 4 恢复升级前

所有节点停止数据库

 **SQL > shutdown immediate**

Database closed.

Database dismounted.

ORACLE instance shut down.

 **[root@rac2 ~]# su - oracle**

 **[oracle@rac2 ~]$ export
ORACLE_HOME=/u02/app/oracle/product/11.2.0.4/db_home2**

 **[oracle@rac2 ~]$ export ORACLE_SID=orcl2**

 **[oracle@rac2 ~]$ /u02/app/oracle/product/11.2.0.4/db_home2/bin/sqlplus / as
sysdba**

SQL*Plus: Release 11.2.0.4.0 Production on Fri Aug 12 01:17:35 2016

Copyright (c) 1982, 2013, Oracle. All rights reserved.

Connected to an idle instance.

 **SQL > startup mount**

ORACLE instance started.

Total System Global Area 1603411968 bytes

Fixed Size 2253664 bytes

Variable Size 570428576 bytes

Database Buffers 1023410176 bytes

Redo Buffers 7319552 bytes

Database mounted.

 **SQL > FLASHBACK database TO RESTORE POINT dbua001;**

Flashback complete.

 **[oracle@rac2 ~]$ export
ORACLE_HOME=/u02/app/oracle/product/11.2.0/db_home**

**[oracle@rac2 ~]$ /u02/app/oracle/product/11.2.0/db_home/bin/sqlplus / as
sysdba**

SQL*Plus: Release 11.2.0.1.0 Production on Fri Aug 12 01:20:35 2016

Copyright (c) 1982, 2013, Oracle. All rights reserved.

 **SQL > alter database open RESETLOGS;**

启动另一节点数据库实例。

改回oracle用户所有环境变量。

附录1 手动升级脚本输出信息

详见附件“upgrade08.7z”

Measure

Measure


---
### ATTACHMENTS
[0e419cec10abe7e8931a6d8ee898fa80]: media/20180103154245_678.png
[20180103154245_678.png](media/20180103154245_678.png)
>hash: 0e419cec10abe7e8931a6d8ee898fa80  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103154245_678.png  
>file-name: 20180103154245_678.png  

[12d3c7e1092237c7d553d3f65423b479]: media/20180103154130_216.png
[20180103154130_216.png](media/20180103154130_216.png)
>hash: 12d3c7e1092237c7d553d3f65423b479  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103154130_216.png  
>file-name: 20180103154130_216.png  

[1d8a4ab28bbb0c63645370b972305ec3]: media/20180103153840_675.png
[20180103153840_675.png](media/20180103153840_675.png)
>hash: 1d8a4ab28bbb0c63645370b972305ec3  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103153840_675.png  
>file-name: 20180103153840_675.png  

[23392fa3bb56301d7c96e58fd7011e67]: media/20180103154233_884.png
[20180103154233_884.png](media/20180103154233_884.png)
>hash: 23392fa3bb56301d7c96e58fd7011e67  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103154233_884.png  
>file-name: 20180103154233_884.png  

[2e54e1ff5fe1694701cba265cff91c82]: media/20180103154517_179.png
[20180103154517_179.png](media/20180103154517_179.png)
>hash: 2e54e1ff5fe1694701cba265cff91c82  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103154517_179.png  
>file-name: 20180103154517_179.png  

[2ffa6c081a5609f36a04b6fecde6825c]: media/20180103154021_947.png
[20180103154021_947.png](media/20180103154021_947.png)
>hash: 2ffa6c081a5609f36a04b6fecde6825c  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103154021_947.png  
>file-name: 20180103154021_947.png  

[335a592eca603daa547db76182147fc6]: media/20180103154447_473.png
[20180103154447_473.png](media/20180103154447_473.png)
>hash: 335a592eca603daa547db76182147fc6  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103154447_473.png  
>file-name: 20180103154447_473.png  

[3be1cc0bbb96fb4ed347979265e57c75]: media/20180103153939_821.png
[20180103153939_821.png](media/20180103153939_821.png)
>hash: 3be1cc0bbb96fb4ed347979265e57c75  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103153939_821.png  
>file-name: 20180103153939_821.png  

[3edf19daa2570437c0a652b4c725c530]: media/20180103154151_81.png
[20180103154151_81.png](media/20180103154151_81.png)
>hash: 3edf19daa2570437c0a652b4c725c530  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103154151_81.png  
>file-name: 20180103154151_81.png  

[4188ac99bcf28d38f77290ed939b5494]: media/20180103154052_368.png
[20180103154052_368.png](media/20180103154052_368.png)
>hash: 4188ac99bcf28d38f77290ed939b5494  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103154052_368.png  
>file-name: 20180103154052_368.png  

[41c124a197b3909fb02bbdb6eeb80bac]: media/20180103153907_903.png
[20180103153907_903.png](media/20180103153907_903.png)
>hash: 41c124a197b3909fb02bbdb6eeb80bac  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103153907_903.png  
>file-name: 20180103153907_903.png  

[4667d89415bcb55496603c6b3ee462f4]: media/20180103154204_518.png
[20180103154204_518.png](media/20180103154204_518.png)
>hash: 4667d89415bcb55496603c6b3ee462f4  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103154204_518.png  
>file-name: 20180103154204_518.png  

[469015aea7a8e97a0caf3b8b8c027a3c]: media/20180103154436_826.png
[20180103154436_826.png](media/20180103154436_826.png)
>hash: 469015aea7a8e97a0caf3b8b8c027a3c  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103154436_826.png  
>file-name: 20180103154436_826.png  

[50be669ff27275cfb4e0402a27fe1be4]: media/20180103154429_749.png
[20180103154429_749.png](media/20180103154429_749.png)
>hash: 50be669ff27275cfb4e0402a27fe1be4  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103154429_749.png  
>file-name: 20180103154429_749.png  

[519da09c1363c6f242818f39e607f62c]: media/20180103153852_453.png
[20180103153852_453.png](media/20180103153852_453.png)
>hash: 519da09c1363c6f242818f39e607f62c  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103153852_453.png  
>file-name: 20180103153852_453.png  

[523ff1f3ca15ff6b670fb42a7b2fcbb0]: media/20180103154527_592.png
[20180103154527_592.png](media/20180103154527_592.png)
>hash: 523ff1f3ca15ff6b670fb42a7b2fcbb0  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103154527_592.png  
>file-name: 20180103154527_592.png  

[59a233a82fe7b6cfa660aab8b0109757]: media/20180103154414_58.png
[20180103154414_58.png](media/20180103154414_58.png)
>hash: 59a233a82fe7b6cfa660aab8b0109757  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103154414_58.png  
>file-name: 20180103154414_58.png  

[5d570c5c2d24a1a98051514c042ac99b]: media/20180103154252_752.png
[20180103154252_752.png](media/20180103154252_752.png)
>hash: 5d570c5c2d24a1a98051514c042ac99b  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103154252_752.png  
>file-name: 20180103154252_752.png  

[646e1cd06c340ab4f7d24d6d1066f3fe]: media/20180103154117_133.png
[20180103154117_133.png](media/20180103154117_133.png)
>hash: 646e1cd06c340ab4f7d24d6d1066f3fe  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103154117_133.png  
>file-name: 20180103154117_133.png  

[659961be5eb091784b8505448106bdcd]: media/20180103153913_107.png
[20180103153913_107.png](media/20180103153913_107.png)
>hash: 659961be5eb091784b8505448106bdcd  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103153913_107.png  
>file-name: 20180103153913_107.png  

[6d3291b2268108a0b3638de245686df9]: media/20180103153807_352.jpg
[20180103153807_352.jpg](media/20180103153807_352.jpg)
>hash: 6d3291b2268108a0b3638de245686df9  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103153807_352.jpg  
>file-name: 20180103153807_352.jpg  

[790f47d4a488f5d1c2767242fefee5f7]: media/20180103154543_101.png
[20180103154543_101.png](media/20180103154543_101.png)
>hash: 790f47d4a488f5d1c2767242fefee5f7  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103154543_101.png  
>file-name: 20180103154543_101.png  

[804de3b6b43fa1e3ebfc0cb443d76111]: media/20180103153833_822.png
[20180103153833_822.png](media/20180103153833_822.png)
>hash: 804de3b6b43fa1e3ebfc0cb443d76111  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103153833_822.png  
>file-name: 20180103153833_822.png  

[84f3766b671c1102e4d5fcad07964e9b]: media/20180103154537_316.png
[20180103154537_316.png](media/20180103154537_316.png)
>hash: 84f3766b671c1102e4d5fcad07964e9b  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103154537_316.png  
>file-name: 20180103154537_316.png  

[8597ed8fc33e87a3a692ad5a2417746e]: media/20180103154222_505.png
[20180103154222_505.png](media/20180103154222_505.png)
>hash: 8597ed8fc33e87a3a692ad5a2417746e  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103154222_505.png  
>file-name: 20180103154222_505.png  

[8fefb13e67435ea762e259a8d2ba3084]: media/20180103154108_749.png
[20180103154108_749.png](media/20180103154108_749.png)
>hash: 8fefb13e67435ea762e259a8d2ba3084  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103154108_749.png  
>file-name: 20180103154108_749.png  

[9d5fddd93e8f1f69e814160b461f6f3d]: media/20180103154144_926.png
[20180103154144_926.png](media/20180103154144_926.png)
>hash: 9d5fddd93e8f1f69e814160b461f6f3d  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103154144_926.png  
>file-name: 20180103154144_926.png  

[a548f1a91ba68d0bf377ada3632db243]: media/20180103153759_545.jpg
[20180103153759_545.jpg](media/20180103153759_545.jpg)
>hash: a548f1a91ba68d0bf377ada3632db243  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103153759_545.jpg  
>file-name: 20180103153759_545.jpg  

[a63b09d6c7aab1079fc4b850a9174063]: media/20180103154507_126.png
[20180103154507_126.png](media/20180103154507_126.png)
>hash: a63b09d6c7aab1079fc4b850a9174063  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103154507_126.png  
>file-name: 20180103154507_126.png  

[a70bc125875010c9f26d50efb3732bd2]: media/20180103153922_560.png
[20180103153922_560.png](media/20180103153922_560.png)
>hash: a70bc125875010c9f26d50efb3732bd2  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103153922_560.png  
>file-name: 20180103153922_560.png  

[a85ac990fa318f393eb914cd923067f7]: media/20180103154458_609.png
[20180103154458_609.png](media/20180103154458_609.png)
>hash: a85ac990fa318f393eb914cd923067f7  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103154458_609.png  
>file-name: 20180103154458_609.png  

[a96b780f49f64512c26d5254b23a7d62]: media/20180103154347_176.png
[20180103154347_176.png](media/20180103154347_176.png)
>hash: a96b780f49f64512c26d5254b23a7d62  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103154347_176.png  
>file-name: 20180103154347_176.png  

[adc937b5c474b2202d548258ea226f25]: media/20180103154421_62.png
[20180103154421_62.png](media/20180103154421_62.png)
>hash: adc937b5c474b2202d548258ea226f25  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103154421_62.png  
>file-name: 20180103154421_62.png  

[aecc7186b5ab25606f5a88e3d170ab48]: media/20180103154000_873.png
[20180103154000_873.png](media/20180103154000_873.png)
>hash: aecc7186b5ab25606f5a88e3d170ab48  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103154000_873.png  
>file-name: 20180103154000_873.png  

[b73f64eb4be98d214e00b9d2e639a698]: media/20180103153946_662.png
[20180103153946_662.png](media/20180103153946_662.png)
>hash: b73f64eb4be98d214e00b9d2e639a698  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103153946_662.png  
>file-name: 20180103153946_662.png  

[c76459d0888386dc34e9d635f2d3bf78]: media/20180103154100_244.png
[20180103154100_244.png](media/20180103154100_244.png)
>hash: c76459d0888386dc34e9d635f2d3bf78  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103154100_244.png  
>file-name: 20180103154100_244.png  

[c91da3b543cc02bb775ece97e98a408c]: media/20180103154137_494.png
[20180103154137_494.png](media/20180103154137_494.png)
>hash: c91da3b543cc02bb775ece97e98a408c  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103154137_494.png  
>file-name: 20180103154137_494.png  

[d04f3af6853d08db8d7298105ee7aaa4]: media/20180103153928_357.png
[20180103153928_357.png](media/20180103153928_357.png)
>hash: d04f3af6853d08db8d7298105ee7aaa4  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103153928_357.png  
>file-name: 20180103153928_357.png  

[d46bf855fc47e6ce133bb5fd76dae072]: media/20180103153629_421.png
[20180103153629_421.png](media/20180103153629_421.png)
>hash: d46bf855fc47e6ce133bb5fd76dae072  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103153629_421.png  
>file-name: 20180103153629_421.png  

[d4f495515c8039e5204287c73214595d]: media/20180103154406_647.png
[20180103154406_647.png](media/20180103154406_647.png)
>hash: d4f495515c8039e5204287c73214595d  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103154406_647.png  
>file-name: 20180103154406_647.png  

[d98fa07eb31278ee76044984041a6b28]: media/20180103154009_992.png
[20180103154009_992.png](media/20180103154009_992.png)
>hash: d98fa07eb31278ee76044984041a6b28  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103154009_992.png  
>file-name: 20180103154009_992.png  

[dcd41f020f721241838fa8b4690dd105]: media/20180103154123_203.png
[20180103154123_203.png](media/20180103154123_203.png)
>hash: dcd41f020f721241838fa8b4690dd105  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103154123_203.png  
>file-name: 20180103154123_203.png  

[ea43e5d427228ba78af67765353c8fd0]: media/20180103153857_824.png
[20180103153857_824.png](media/20180103153857_824.png)
>hash: ea43e5d427228ba78af67765353c8fd0  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103153857_824.png  
>file-name: 20180103153857_824.png  

[eefbd9bbe4d5857d275cbf62f84550a4]: media/20180103153846_976.png
[20180103153846_976.png](media/20180103153846_976.png)
>hash: eefbd9bbe4d5857d275cbf62f84550a4  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103153846_976.png  
>file-name: 20180103153846_976.png  

[f51c3edf84998efc716b09ffe050439f]: media/20180103154158_813.png
[20180103154158_813.png](media/20180103154158_813.png)
>hash: f51c3edf84998efc716b09ffe050439f  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180103154158_813.png  
>file-name: 20180103154158_813.png  


---
### TAGS
{Support20180830}

---
### NOTE ATTRIBUTES
>Created Date: 2018-08-30 01:33:04  
>Last Evernote Update Date: 2018-10-01 15:33:59  
>source: web.clip7  
>source-url: https://47.100.29.40/highgo_admin/#/index/docSearchDetail/9b0d1c05e3af43  
>source-application: WebClipper 7  