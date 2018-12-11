# Oracle-安装手册-DataGaurd_RAC对单机-12CR2_for_Linux.html

You need to enable JavaScript to run this app.

![](https://47.100.29.40/highgo_admin/static/media/head.530901d0.png)

  杨光  |  退出

  * 知识库

    * ▢  新建文档
    * ▢  文档复查 (3)
    * ▢  文档查询
  * 待编区

文档详细

  知识库 文档详细

![noteattachment1][7f025a17697ee15eb3197c61326b203b]

066074104

Oracle-安装手册-DataGaurd_RAC对单机-12CR2_for_Linux

目录

环境

文档用途

详细信息

相关文档

内部备注

附件

环境

系统平台：Linux x86-64 Red Hat Enterprise Linux 6,Linux x86-64 Red Hat Enterprise
Linux 7

版本：12.2.0.1

文档用途

Oracle-安装手册-DataGaurd_RAC对单机-12CR2_for_Linux_v1.0

详细信息

确认主备端OS及DB版本是否一致、是否通过认证

如若两端OS及DB版本存在差异，务必声明

## 适用环境：

数据库版本

|

12CR2 64位   主端:RAC — 备端:单实例  
  
---|---  
  
操作系统版本

|

Red Hat Enterprise Linux Server   release 6.4(2.6.32-358.el6.x86_64)以上

Red Hat Enterprise Linux Server   release 7(3.10.0-123.el7.x86_64)以上  
  
## 本示例命名：

  
|

SID

|

db_name

|

db_unique_name

|

Net service name  
  
---|---|---|---|---  
  
主端node1

|

dgsrc1

|

dgsrc

|

dgsrc

|

dgsrc_tns  
  
主端node2

|

dgsrc2

|

dgsrc

|

dgsrc

|

dgsrc_tns  
  
备端

|

dgtar

|

dgsrc

|

dgtar

|

dgtar_tns  
  


## 1、主端设置force logging

[oracle]$ sqlplus / as sysdba

SQL> select name,log_mode,force_logging from gv$database;



NAME      LOG_MODE     FORCE_LOGGING

\--------- ------------ ---------------------------------------

DGSRC     ARCHIVELOG   NO

DGSRC     ARCHIVELOG   NO



SQL> **alter database force logging;**

Database altered.



SQL> select name,log_mode,force_logging from gv$database;



NAME      LOG_MODE     FORCE_LOGGING

\--------- ------------ ---------------------------------------

DGSRC     ARCHIVELOG   YES

DGSRC     ARCHIVELOG   YES

## 2、 主端设置归档模式

查看是否为归档模式：

SQL> archive log list;

Database log mode                 Archive Mode

Automatic archival               Enabled

Archive destination              +FRA

Oldest online log sequence       4

Next log sequence to archive     5

Current log sequence             5

若Database log mode 显示为Archive Mode即为归档模式，Archive
destination显示为归档路径，也可以查看归档路径的参数确定归档位置。

SQL> show parameter log_archive_dest_1



NAME                                 TYPE        VALUE

\------------------------------------ -----------
------------------------------

log_archive_dest_1                   string      LOCATION=+FRA

若Database log mode 显示为No Archive Mode即为非归档模式，以下开启归档模式

先设置归档路径

SQL> alter system set log_archive_dest_1='location=+FRA';

注：归档日志存放在共享存储上，在共享存储ASM上单独划分存放归档日志的磁盘组，比如FRA。如果共享存储没有空间，需要将归档放置本地磁盘时，必须在RAC所有节点上共享本地磁盘存放归档的路径，比如NFS。



关闭所有实例，启动1号实例到mount状态

SQL> shutdown immediate

SQL> startup mount;

开始归档模式

SQL> alter database archivelog;

SQL> alter database open;

SQL> alter pluggable database DGSRCPDB open;

启动其他实例

## 3、主端配置参数

查看主端的db_unique_name

[oracle]$ sqlplus / as sysdba

SQL> show parameter db_unique_name

NAME                                 TYPE        VALUE

\------------------------------------ -----------
------------------------------

db_unique_name                       string      dgsrc



SQL> ALTER SYSTEM SET LOG_ARCHIVE_CONFIG='DG_CONFIG=(DGSRC,DGTAR)' SID='*';

 **#** ** _注 红色取值为主库和备库的 DB_UNIQUE_NAME_**

 ** _备端db_unique_name 可以自定义，只要和备机启动时的参数一致就可以。_**



SQL> ALTER SYSTEM SET LOG_ARCHIVE_DEST_1='LOCATION=+FRA
VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=DGSRC' SID='*';



SQL> ALTER SYSTEM SET LOG_ARCHIVE_DEST_2='SERVICE=DGTAR_TNS LGWR ASYNC REOPEN
NET_TIMEOUT=300 VALID_FOR=(ONLINE_LOGFILE,PRIMARY_ROLE) DB_UNIQUE_NAME=DGTAR'
SID='*';

 **#** ** _注 红色取值为主库tnsnames.ora文件中备库的Net service name_**



SQL> alter system set LOG_ARCHIVE_DEST_STATE_1=ENABLE;



SQL> alter system set LOG_ARCHIVE_DEST_STATE_2=ENABLE;



SQL> ALTER SYSTEM SET STANDBY_FILE_MANAGEMENT =AUTO SID='*';



SQL> ALTER SYSTEM SET FAL_SERVER='DGTAR_TNS' SID='*';

 **#** ** _注 红色取值为主库tnsnames.ora文件中备库的Net service name_**

 **FAL_SERVER And FAL_CLIENT Settings For Cascaded Standby (** **文档 ID
358767.1)**

 ** **

以下参数修改需要重启数据库，注意：如果主端是RAC环境，且不能重启数据库，请不要修改以下参数。备端必须进行设置。

SQL> alter system set DB_FILE_NAME_CONVERT = '/data/dgtar/','+DATA/DGSRC/'
sid='*' scope=spfile;

SQL> alter system set LOG_FILE_NAME_CONVERT = '/data/dgtar/','+DATA/DGSRC/'
sid='*' scope=spfile;



DB_FILE_NAME_CONVERT参数的作用是转换主库和备库的数据文件路径。

LOG_FILE_NAME_CONVERT参数的作用是转换主库和备库的redo日志文件的路径。

以上两个参数的书写格式是，两两路径为一组，对方的路径在前，自己的路径在后。

## 4、主端创建standby redologs

在主端备份数据库之前创建standby redolog，在备端执行alter database mount;后会在备端自动创建standby
redolog。

SQL> col status format a10;

select thread#, GROUP#,SEQUENCE#,BYTES/1024/1024,STATUS,FIRST_TIME from v$log;



   THREAD#     GROUP#  SEQUENCE# BYTES/1024/1024 STATUS     FIRST_TIM

\---------- ---------- ---------- --------------- ---------- ---------

         1          1          5             200 CURRENT    21-MAR-18

         1          2          4             200 INACTIVE   21-MAR-18

         2          3          3             200 INACTIVE   21-MAR-18

         2          4          4             200 CURRENT    21-MAR-18



SQL> Set linesize 200

col member format a50

select * from v$logfile;



GROUP# STATUS TYPE    MEMBER                                      IS_ CON_ID

\------ ------ ------- ------------------------------------------- --- ------

     2        ONLINE  +DATA/DGSRC/ONLINELOG/group_2.263.971295345 NO       0

     1        ONLINE  +DATA/DGSRC/ONLINELOG/group_1.262.971295345 NO       0

     3        ONLINE  +DATA/DGSRC/ONLINELOG/group_3.270.971295993 NO       0

     4        ONLINE  +DATA/DGSRC/ONLINELOG/group_4.271.971296003 NO       0



主端创建standby redologs：

standby redo日志的大小 **必须至少与redo日志一样大；对于每个线程（** **THREAD#** **）的standby
redo的数量必须至少比当前线程的redo日志多一个日志组。**

当前的RAC环境中包含两个节点，每个节点有两个日志组（GROUP#），每个日志的大小为200MB，每个日志组有1个成员（+DATA）。根据这种情况，为每个线程创建3个大小为200MB的日志组，每个日志组包含1个成员，分别位于+DATA磁盘组。



alter database add standby logfile thread 1 group 5 ('+DATA') size 200M;

alter database add standby logfile thread 1 group 6 ('+DATA') size 200M;

alter database add standby logfile thread 1 group 7 ('+DATA') size 200M;

alter database add standby logfile thread 2 group 8 ('+DATA') size 200M;

alter database add standby logfile thread 2 group 9 ('+DATA') size 200M;

alter database add standby logfile thread 2 group 10 ('+DATA') size 200M;

## 5、监听配置

### 5.1、备端配置静态监听服务名

 **此步骤仅限使用RMAN DUPLICATE时配置静态监听服务名。**



在备端以oracle用户向$ORACLE_HOME/network/admin/listener.ora文件中添加以下条目：

SID_LIST_LISTENER =

  (SID_LIST =

    (SID_DESC =

     (GLOBAL_DBNAME = dgtar)

     (ORACLE_HOME = /u01/app/oracle/product/12.2.0/db_1)

     (SID_NAME = dgtar)

    )

   )



LISTENER =

  (DESCRIPTION =

    (ADDRESS = (PROTOCOL = TCP)(HOST = 备端的物理IP)(PORT = 1521))

  )

SID_NAME：数据库实例名，其值需和数据库参数INSTANCE_NAME保持一致，不可省略。

GLOBAL_DBNAME：数据库服务名，可以省略，默认和SID_NAME保持一致。

ORACLE_HOME：实例运行的ORACLE_HOME目录。在UNIX和Linux环境下，该参数可以省略，默认和环境变量$ORACLE_HOME保持一致。在WINDOWS环境中，该参数无效，ORACLE_HOME的值取自注册表HKEY_LOCAL_MACHINE\SOFTWARE\ORACLE\HOMEID



 **配置完成后重启监听器。**

###  5.2、主备端tnsnames.ora文件配置

以oracle用户配置$ORACLE_HOME/network/admin/tnsnames.ora文件

 **主端和备端** **tnsnames.ora** **文件都** **添加主备端** **IP** **配置** **条目** **。**

编辑文件tnsnames.ora 添加以下内容

[oracle]$ vi $ORACLE_HOME/network/admin/tnsnames.ora



DGTAR_TNS =

  (DESCRIPTION =

    (ADDRESS = (PROTOCOL = TCP)(HOST = 备端的物理IP)(PORT = 1521))

    (CONNECT_DATA =

      (SERVER = DEDICATED)

      (SERVICE_NAME = dgtar)(UR=A)

    )

  )

# (UR=A)作用当备端数据库nomount,mount或者restricted时，动态监听显示状态为BLOCKED时，主端可通过配置UR=A进行连接。



DGSRC_TNS =

  (DESCRIPTION =

    (ADDRESS = (PROTOCOL = TCP)(HOST = 主端scan ip)(PORT = 1521))

    (CONNECT_DATA =

      (SERVER = DEDICATED)

      (SERVICE_NAME = dgsrc)(UR=A)

    )

  )



DGSRC_TNS1 =

  (DESCRIPTION =

    (ADDRESS = (PROTOCOL = TCP)(HOST = 主端node1 vip)(PORT = 1521))

    (CONNECT_DATA =

      (SERVER = DEDICATED)

      (SERVICE_NAME = dgsrc)(UR=A)

    )

  )



DGSRC_TNS2 =

  (DESCRIPTION =

    (ADDRESS = (PROTOCOL = TCP)(HOST = 主端node2 vip)(PORT = 1521))

    (CONNECT_DATA =

      (SERVER = DEDICATED)

      (SERVICE_NAME = dgsrc)(UR=A)

    )

  )

注意：备端参数local_listener如果设置了LISTENER_DGTAR，那么备端tnsnames.ora文件需要添加以下内容：

DGTAR =

  (DESCRIPTION =

    (ADDRESS = (PROTOCOL = TCP)(HOST = dgtar)(PORT = 1521))

    (CONNECT_DATA =

      (SERVER = DEDICATED)

      (SERVICE_NAME = dgtar)

    )

  )



LISTENER_DGTAR =

  (ADDRESS = (PROTOCOL = TCP)(HOST = dgtar)(PORT = 1521))

备机启动监听

[oracle]$ lsnrctl start



主端和备端测试监听配置：

[oracle]$ tnsping DGSRC_TNS

[oracle]$ tnsping DGTAR_TNS

## 6、主端传输密码文件至备端

主端节点1传输密码文件至备端和主端集群的其他节点上

# su - grid

[grid@dgsrc1 ~]$ asmcmd -p

ASMCMD [+] > cd +data/dgsrc/PASSWORD

ASMCMD [+data/dgsrc/PASSWORD] > cp pwddgsrc.256.971295071 /home/grid

# scp pwddgsrc.256.971295071备端的物理IP:$ORACLE_HOME/dbs/orapwdgtar

密码文件命名格式是orapw+SID

备端修改密码文件的属组

# chown oracle:oinstall $ORACLE_HOME/dbs/orapwdgtar

## 7、主端创建密码验证用户

SQL> create user c##dgpasswd identified by 密码;

注意密码要提高复杂度。



SQL> GRANT SYSOPER to c##dgpasswd;



SQL> col USERNAME format a15

select USERNAME,SYSDBA,SYSOPER,SYSASM from V$PWFILE_USERS;



USERNAME        SYSDB SYSOP SYSAS

\--------------- ----- ----- -----

SYS             TRUE  TRUE  FALSE

SYSDG           FALSE FALSE FALSE

SYSBACKUP       FALSE FALSE FALSE

SYSKM           FALSE FALSE FALSE

C##DGPASSWD     FALSE TRUE  FALSE



SQL> ALTER SYSTEM SET REDO_TRANSPORT_USER = C##DGPASSWD SID='*';



 ** _\--_** **_How to make log shipping to continue work without copying
password file from primary to physical standby when changing sys password on
primary? (_** ** _文档_** **_ID 1416595.1)_**

##  8、备端修改主端生成的pfile参数文件

主端备份传输pfile参数文件：

SQL> create pfile='/home/oracle/pfile.ora' from spfile;

[oracle]$ scp /home/oracle/pfile.ora 备端的物理IP:/home/oracle/

在备端修改上一步传输的参数文件：

 **#** ** _注 本节标红的内容为需要修改的_**

*.audit_file_dest='/u01/app/oracle/admin/dgtar/adump'

*.audit_trail='NONE'

*.compatible='12.2.0'

*.control_files='/data/dgtar/controlfile/current01.ctl'

*.db_block_size=8192

*.db_create_file_dest=''                  **#** ** _注 关闭OMF功能_**

*.db_create_online_log_dest_1=''

*.db_create_online_log_dest_2=''

*.db_file_name_convert='+DATA/DGSRC/','/data/dgtar/'

*.db_name='dgsrc'

*.diagnostic_dest='/u01/app/oracle'

*.dispatchers='(PROTOCOL=TCP) (SERVICE=dgtarXDB)'

*.enable_pluggable_database=true

*.fal_server='DGSRC_TNS'

*.local_listener='LISTENER_DGTAR'

*.log_archive_config='DG_CONFIG=(DGSRC,DGTAR)'

*.log_archive_dest_1='LOCATION=/arch VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=DGTAR'

*.log_archive_dest_2='SERVICE=DGSRC_TNS LGWR ASYNC REOPEN NET_TIMEOUT=300 VALID_FOR=(ONLINE_LOGFILE,PRIMARY_ROLE) DB_UNIQUE_NAME=DGSRC'

*.log_archive_format='%t_%s_%r.dbf'

*.log_file_name_convert='+DATA/DGSRC/','/data/dgtar/'

*.nls_language='AMERICAN'

*.nls_territory='AMERICA'

*.open_cursors=300

*.pga_aggregate_target=787m

*.processes=300

*.redo_transport_user='C##DGPASSWD'

*.remote_login_passwordfile='exclusive'

*.sga_target=2360m

*.standby_file_management='AUTO'

*.undo_tablespace='UNDOTBS1'

*.service_names='dgsrc,dgtar'

*.db_unique_name='dgtar'

## 9、备端提前创建所需路径

[oracle]$ mkdir -p /u01/app/oracle/admin/dgtar/adump

[oracle]$ mkdir -p /data/dgtar/controlfile

[oracle]$ mkdir -p /arch

[oracle]$ mkdir -p /data/dgtar/onlinelog/

[oracle]$ mkdir -p /data/dgtar/datafile/

[oracle]$ mkdir -p /data/dgtar/tempfile/

## 10、备端复制主端数据库

有两种方式：

一种是使用RMAN在主端做备份，将备份文件传递至备端restore；

另一种是使用RMAN DUPLICATE...FROM ACTIVE DATABASE，这是oracle
11G新特性，最大的优势是可以不必耗费大量的磁盘空间中转落地的RMAN备份文件，而是直接通过主端数据文件生成备端数据文件。

Step by Step Guide on Creating Physical Standby Using RMAN DUPLICATE...FROM
ACTIVE DATABASE (文档 ID 1075908.1)

## 10.1、RMAN备份还原复制主端数据库

 **#** ** _注_** **_如果使用_** ** _RMAN DUPLICATE_** ** _方式，请跳过此章节。_**

###  10.1.1、备份primary

主端一个节点RMAN备份数据库，如果数据量很大，备份时间很长，建议后台执行备份脚本。

run {

allocate channel c1 type disk;

allocate channel c2 type disk;

allocate channel c3 type disk;

backup incremental level 0 format '/home/oracle/rmanbak/dgsrc_full_%U'
database;

backup format '/home/oracle/rmanbak/dgsrc_stanctf_%U' current controlfile for
standby;

release channel c1;

release channel c2;

release channel c3;

}

### 10.1.2、主端传输文件至备端

[oracle]$ scp /home/oracle/rmanbak/dgsrc_* 备端的物理IP:/home/oracle/backup/

如果是AIX或HP-UX没有scp工具的，参考使用FTP工具

在备端服务器上执行FTP命令get主端RMAN备份文件

# cd /home/oracle/backup/

# ftp 192.168.0.100

Name (192.168.0.100:root): root

331 Password required for root.

Password:

ftp>

ftp> cd /home/oracle/rmanbak

ftp> ls

ftp> bin                               **#** ** _注 使用二进制传输备份文件_**

ftp> prompt off                        **#** ** _注 不用输入确认_**

ftp> mget orcl_full_*

### 10.1.3、备端启动数据库到nomount

备端数据库先生成spfile后启动数据库到nomount状态

[oracle]$ export ORACLE_SID=dgtar

[oracle]$ sqlplus / as sysdba

SQL> create spfile from pfile='/home/oracle/pfile.ora';

SQL> startup nomount;

### 10.1.4、测试sqlplus连通性，确保能正常连通

主端和备端都要测试sqlplus连通性

[oracle]$ sqlplus /nolog

主端测试

SQL> connect sys/Oracle123@dgtar_tns AS SYSDBA

备端测试

SQL> connect sys/Oracle123@dgsrc_tns AS SYSDBA

### 10.1.5、备端restore database

restore控制文件

RMAN> restore standby controlfile from
'/home/oracle/backup/dgsrc_stanctf_0csuba8h_1_1';

备端将RMAN备份片加入到catalog中，rman备份的catalog使用控制文件。

RMAN> alter database mount;

RMAN> catalog start with '/home/oracle/backup';

或

RMAN> catalog backuppiece '/home/oracle/backup/dgsrc_full_03suba4t_1_1';

RMAN> catalog backuppiece '/home/oracle/backup/dgsrc_full_04suba4u_1_1';

备端数据库restore数据文件

RMAN> run {

allocate channel d1 type disk;

allocate channel d2 type disk;

allocate channel d3 type disk;

restore database;

release channel d1;

release channel d2;

release channel d3;

}

## 10.2、RMAN DUPLICATE复制主端数据库

 **#** ** _注_** **_如果使用_** ** _RMAN_** ** _备份还原方式，请跳过此章节。_**

###  10.2.1、备端启动数据库到nomount

备端数据库启动到nomount状态

[oracle]$ export ORACLE_SID=orcldg

[oracle]$ sqlplus / as sysdba

sql> create spfile from pfile='/home/oracle/pfile.ora';

sql> startup nomount;

### 10.2.2、测试sqlplus连通性，确保能正常连通

主端和备端都要测试sqlplus连通性

[oracle]$ sqlplus /nolog

主端测试

SQL> connect sys/Oracle123@dgtar_tns AS SYSDBA

备端测试

SQL> connect sys/Oracle123@dgsrc_tns AS SYSDBA

### 10.2.3、执行RMAN DUPLICATE

 ** _注意1：_**

如果主端是RAC，确保RMAN的SNAPSHOT CONTROLFILE在共享存储中，若不在共享存储中RMAN DUPLICATE复制控制文件会报以下错误：

ORA-00245: control file backup failed; target is likely on a local file system

RMAN> show snapshot controlfile name;



RMAN configuration parameters for database with db_unique_name ORCL are:

CONFIGURE SNAPSHOT CONTROLFILE NAME TO
'/u01/app/oracle/product/11.2.0/db_1/dbs/snapcf_orcl1.f'; # default



RMAN> CONFIGURE SNAPSHOT CONTROLFILE NAME TO '+FRA/snapcf_orcl.f';



new RMAN configuration parameters:

CONFIGURE SNAPSHOT CONTROLFILE NAME TO '+FRA/snapcf_orcl.f';

new RMAN configuration parameters are successfully stored

参考文档：

Bug 21503053 - ORA-245 from RMAN Controlfile Backup on Local Device (文档 ID
21503053.8)

ORA-245: In RAC environment from 11.2 onwards Backup Or Snapshot controlfile
needs to be in shared location (文档 ID 1472171.1)

 ** _ _**

 ** _注意2：_**

如果主端是RAC，使用RMAN连接主端数据库时不要使用SCAN的网络连接串，因为使用SCAN连接主数据会同时连接至RAC的两个节点上：

using target database control file instead of recovery catalog

allocated channel: prmy1

channel prmy1: SID=58 instance=orcl2 device type=DISK



allocated channel: prmy2

channel prmy2: SID=62 instance=orcl2 device type=DISK



allocated channel: prmy3

channel prmy3: SID=61 instance=orcl2 device type=DISK



allocated channel: prmy4

channel prmy4: SID=73 instance=orcl1 device type=DISK



allocated channel: stby

channel stby: SID=19 device type=DISK

…………

RMAN-00571: ========================================================

RMAN-00569: ============ ERROR MESSAGE STACK FOLLOWS ============

RMAN-00571: ==============================================

RMAN-03002: failure of Duplicate Db command at 06/25/2016 10:36:25

RMAN-05501: aborting duplication of target database

RMAN-03015: error occurred in stored script Memory Script



RMAN-03009: failure of backup command on prmy1 channel at 06/25/2016 10:36:25

ORA-19505: failed to identify file
"/u01/app/oracle/product/11.2.0/db_1/dbs/orapworcl1"

ORA-27037: unable to obtain file status

Linux-x86_64 Error: 2: No such file or directory

Additional information: 3

解决方法：可以在主端的一个节点上配置tnsnames.ora添加当前节点的VIP网络连接串，RMAN连接主端数据库时，使用VIP网络连接串。

参考文档：

RMAN Active Duplicate for Standby for RAC Database Unable to Find the Password
File Failing with: ORA-19505, and ORA-27037 (文档 ID 1551235.1)



 **RMAN** **连接主备数据库，开始RMAN** **DUPLICATE** **复制数据库：**

$ **rman target sys/Oracle123@dgsrc_tns1 auxiliary sys/Oracle123@dgtar_tns
nocatalog**



Recovery Manager: Release 12.2.0.1.0 - Production on Wed Mar 21 14:22:58 2018



Copyright (c) 1982, 2017, Oracle and/or its affiliates.  All rights reserved.



connected to target database: DGSRC (DBID=788332716)

using target database control file instead of recovery catalog

connected to auxiliary database: DGSRC (not mounted)



RMAN> run {

allocate channel prmy1 type disk;

allocate channel prmy2 type disk;

allocate channel prmy3 type disk;

allocate auxiliary channel stby1 type disk;

allocate auxiliary channel stby2 type disk;

allocate auxiliary channel stby3 type disk;

 **duplicate target database for standby from active database
nofilenamecheck;**

}

## 11、备端同步主端的归档日志

备端恢复数据文件完成后，重启数据库到mount状态，开启介质恢复进程。

 **备端** 重启数据库

SQL> startup mount force

 ** **

 **备端** 启动恢复进程mrp0

SQL> alter database recover managed standby database using current logfile
disconnect from session;

 ** **

 **备端** 查询是否有mrp0进程

SQL> set line 200

SELECT NAME,ROLE,INSTANCE,THREAD#,SEQUENCE#,BLOCK#,DELAY_MINS,ACTION FROM
GV$DATAGUARD_PROCESS;



切换 **主库** 归档，观察备库归档日志同步是否正常。

SQL> alter system archive log current;



关闭介质恢复的方法：

SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;

## 12、备端开启和关闭Active Data Guard

Active dataguard模式下，备机可提供只读的查询业务，不能写数据。

如果开启了介质恢复进程，需要先关闭介质恢复进程

SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;

启动

SQL> ALTER DATABASE OPEN READ ONLY;

SQL> RECOVER MANAGED STANDBY DATABASE DISCONNECT USING CURRENT LOGFILE;

PDB开启只读模式

SQL> show pdbs;



    CON_ID CON_NAME                       OPEN MODE  RESTRICTED

\---------- ------------------------------ ---------- ----------

         2 PDB$SEED                       READ ONLY  NO

         3 DGSRCPDB                       MOUNTED



SQL> **alter pluggable database DGSRCPDB open READ ONLY;**

Pluggable database altered.



SQL> show pdbs;



    CON_ID CON_NAME                       OPEN MODE  RESTRICTED

\---------- ------------------------------ ---------- ----------

         2 PDB$SEED                       READ ONLY  NO

         3 DGSRCPDB                       READ ONLY  NO

## 13、查询同步情况

主端查询

SQL> select max(sequence#),thread# from v$archived_log where RESETLOGS_CHANGE#
= (SELECT RESETLOGS_CHANGE# FROM V$DATABASE_INCARNATION WHERE STATUS =
'CURRENT') GROUP BY THREAD#;



MAX(SEQUENCE#)    THREAD#

\-------------- ----------

             7          1

             6          2

备端查询

SQL> select max(sequence#),thread# from v$archived_log where  applied='YES'
and RESETLOGS_CHANGE# = (SELECT RESETLOGS_CHANGE# FROM V$DATABASE_INCARNATION
WHERE STATUS = 'CURRENT') GROUP BY THREAD#;



MAX(SEQUENCE#)    THREAD#

\-------------- ----------

             7          1

             6          2



主备以上结果对比，如果max(sequence#)相差较大，表示目前不同步或同步延时较大，如果相差1到2个是可以接受的。



查看备机恢复进程状态的方法：

SQL> SELECT NAME,ROLE,INSTANCE,THREAD#,SEQUENCE#,BLOCK#,DELAY_MINS,ACTION FROM
GV$DATAGUARD_PROCESS;

以下查询仅限Active Data Guard

SQL> set line 200

select name,value  from v$dataguard_stats;



NAME                             VALUE

\-------------------------------- --------------------------------------------

transport lag                    +00 00:00:00

apply lag                        +00 00:00:00

apply finish time                +00 00:00:00.000

estimated startup time           23

## 14、Switchover

1. 检查主库和备库的参数设置

2. 确保主库设置了以下参数

SQL> alter system set DB_FILE_NAME_CONVERT = '/data/dgtar/','+DATA/DGSRC/'
sid='*' scope=spfile;

SQL> alter system set LOG_FILE_NAME_CONVERT = '/data/dgtar/','+DATA/DGSRC/'
sid='*' scope=spfile;

3. 确保主库创建了standby logfile联机redo日志文件

SQL> select * from v$standby_log;

4. 确保compatible主库和备库相同

5. 确保Managed Recovery运行在备库，且主备端同步正常

SQL> SELECT NAME FROM GV$DATAGUARD_PROCESS WHERE NAME LIKE 'MRP%';

NAME

\---------

MRP0



 **主端** 使用verify执行switchover前的验证

SQL> alter database switchover to <target standby db_unique_name> verify;



如果Standby 状态与primary 状态同步，我们会收到以下消息，

SQL> alter database switchover to dgtar verify;

Database altered.

12c Data guard Switchover Best Practices using SQLPLUS (文档 ID 1578787.1)

6. 验证主库和备库的tempfiles是否匹配

SQL> col name for a45

select ts#,name,ts#,status  from v$tempfile;

如果查询不匹配，可以在打开新的主库后再纠正。

7. 清除可能受阻的参数与jobs

主端查看当前DBMS_JOB 的状态

SQL> SELECT * FROM DBA_JOBS_RUNNING;

主端查看当前DBMS_SCHEDULER的状态

SQL> select owner,job_name,session_id,slave_process_id,running_instance from
dba_scheduler_running_jobs;

如果有正在运行的job则不建议切换，最好等job运行完，或者停掉job（详细参考oracle Job操作手册）。

SQL> SHOW PARAMETER job_queue_processes

禁止所有job再自动执行

SQL> ALTER SYSTEM SET job_queue_processes=0 SCOPE=BOTH SID='*';

8. 打开Data Guard 主库和备库的日志跟踪

主库和备库查询跟踪级别

SQL> SHOW PARAMETER log_archive_trace



NAME                                 TYPE        VALUE

\------------------------------------ -----------
------------------------------

log_archive_trace                    integer     0  



设置Data Guard的跟踪级别8191在主和目标物理备用数据库

SQL> ALTER SYSTEM SET log_archive_trace=8191;

打开后会在background_dump_dest参数指定的目录里生成类似ora11g_ **mrp0** _31640.trc的trc日志文件。

可以ls -lrt *mrp0* 来定位最后一个文件。



查看alter日志

SQL> SHOW PARAMETER background_dump_dest



# tail -f alert_orcl.log

9. 创建可靠还原点（可选）如果switch切换后有问题可以通过还原点回退数据库。

确认是否开启了闪回，如果没有则要先开启，主库和备库。



备库：

SQL> show parameter DB_RECOVERY

NAME                                 TYPE        VALUE

\------------------------------------ -----------
------------------------------

db_recovery_file_dest                string

db_recovery_file_dest_size           big integer 0



SQL> ALTER SYSTEM SET DB_RECOVERY_FILE_DEST_SIZE=10G;

SQL> ALTER SYSTEM SET DB_RECOVERY_FILE_DEST='/fra/flashback';



SQL> show parameter DB_RECOVERY

NAME                                 TYPE        VALUE

\------------------------------------ -----------
------------------------------

db_recovery_file_dest                string      /fra/flashback

db_recovery_file_dest_size           big integer 10G



停止恢复应用

SQL> RECOVER MANAGED STANDBY DATABASE CANCEL;

Media recovery complete.

创建还原点

SQL> CREATE RESTORE POINT SWITCHOVER_START_GRP GUARANTEE FLASHBACK DATABASE;



启动应用进程

SQL> RECOVER MANAGED STANDBY DATABASE DISCONNECT USING CURRENT LOGFILE;



查看还原点信息  

SQL> col NAME format a30

col time format a40

set line 300

select NAME,SCN,TIME from v$restore_point;



   NAME                                  SCN TIME

\------------------------------ ----------
-------------------------------------

SWITCHOVER_START_GRP               987029 04-JUL-16 02.11.05.000000000 PM



主库同样检查是否开启闪回，并创建还原点

SQL> CREATE RESTORE POINT SWITCHOVER_START_GRP GUARANTEE FLASHBACK DATABASE;

Restore point created.



 **注意如果创建还原点，在** **switch** **切换完毕后一定要删除主备节点上还原点，否则还原点的文件会不断增长直到磁盘爆满。**

 **删除方法：**

SQL> **drop restore point** SWITCHOVER_START_GRP;

10. 将备用数据库切换到主数据库

主端：

SQL> alter database switchover to <target standby db_unique_name>;

例如：

SQL> alter database switchover to dgtar;

11\. open新的主库

SQL> ALTER DATABASE OPEN;

SQL> alter pluggable database DGSRCPDB open;

12. 如果有不匹配的临时表空间，更正不匹配的临时表空间

13. 重新启动新的备库

SQL> SHUTDOWN ABORT;

SQL> startup

SQL> alter pluggable database DGSRCPDB open read only;

SQL> RECOVER MANAGED STANDBY DATABASE DISCONNECT USING CURRENT LOGFILE;

14. 切换还原参数

SQL> ALTER SYSTEM SET log_archive_trace=0;

SQL> ALTER SYSTEM SET job_queue_processes=<value saved> scope=both sid=’*’

SQL> EXECUTE DBMS_SCHEDULER.ENABLE(<for each job name captured>);

SQL> DROP RESTORE POINT SWITCHOVER_START_GRP;

 **另外要调整主备端自动删除归档的脚本和计划任务** **。**

15. 切换的检查

主端：

SQL> alter system switch logfile;



SQL> select max(sequence#),thread# from v$log_history group by thread#;



SQL> select dest_id,error,status from v$archive_dest where dest_id=<your
remote log_archive_dest_<n>>;



If remote log_Archive_destination is 2 i.e log_archive_dest_2.



SQL> select dest_id,error,status from v$archive_dest where dest_id=2;



SQL> select max(sequence#)  from v$archived_log where applied='YES' and
dest_id=2;



备端：



SQL> select max(sequence#),thread# from v$archived_log group by thread#;



SQL> select name,role,instance,thread#,sequence#,action from
gv$dataguard_process;



注意：对于Oracle版本12.2，请使用v $ dataguard_process而不是在Oracle 12.2中弃用的v $
managed_standby

12c Data guard Switchover Best Practices using SQLPLUS (文档 ID 1578787.1)

## 15、failover

1. 主端flush redo



如果主库可以mount，则在mount状态下执行以下步骤，如果不能mount则跳过这一步

SQL> alter system flush redo to '<target_db_name>';  

 ** _注：target_db_name=备端的DB_UNIQUE_NAME_**

示例:

SQL> alter system flush redo to dgtar;

flush redo是在11gR2被引入的. 对于Data guard, 在故障切换时flush
redo可能是非常有用的，如果这个命令能成功将最后的redo应用到备库上，那么data guard failover将不会丢失数据。

如果需要执行此语句，在备库上的 redo apply进程必须是启动的，执行此命令的主库必须是mouted 状态，不能open ,默认情况下这个语句
带有参数comfirm apply，语句执行将会一直等待所有redo applied。



2\. 确认备用数据库具有每个主数据库redo线程最近存档的redo日志文件。



查询备库上的 V$ARCHIVED_LOG 视图以获取每个重做线程的最高日志序列号。

For example:

SQL> SELECT UNIQUE THREAD# AS THREAD, MAX(SEQUENCE#)  OVER (PARTITION BY
thread#) AS LAST from V$ARCHIVED_LOG;

THREAD     LAST

\---------- ----------

1                  48



如果可能，将每个主数据库redo线程的最近归档的redo日志文件复制到备用数据库（如果它不存在）并注册它。这必须为每个redo线程完成。

SQL> ALTER DATABASE REGISTER PHYSICAL LOGFILE 'filespec1';

For example:

SQL> alter database register physical logfile '/fra/arch/1_42_916276568.dbf';

SQL> alter database register physical logfile '/fra/arch/1_43_916276568.dbf';

SQL> alter database register physical logfile '/fra/arch/1_44_916276568.dbf';



3\. 检查并处理任何归档的redo日志断档

查询备库上的 V$ARCHIVE_GAP 视图，以确定目标备用数据库是否存在任何redo断档。

For example:

SQL> SELECT THREAD#, LOW_SEQUENCE#, HIGH_SEQUENCE# FROM V$ARCHIVE_GAP;



THREAD# LOW_SEQUENCE# HIGH_SEQUENCE#

\---------- ------------- --------------

1            90                      92



在此示例中，redo断档包含线程1的序列号为90,91和92的归档重做日志文件。将缺少的归档重做日志文件从主数据库复制到目标备用数据库，并将它们注册到目标备用数据库。这必须为每个重做线程完成。

For example:

SQl> ALTER DATABASE REGISTER PHYSICAL LOGFILE 'filespec1';



4. 备端执行以下语句停止redo应用服务

SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;



5. 将物理备用数据库切换为主要角色。

在目标备用数据库上发出以下SQL语句：

SQL> ALTER DATABASE FAILOVER TO target_db_name;

例如，假设目标备用数据库名为DGTAR：

SQL> ALTER DATABASE FAILOVER TO DGTAR;



++如果此语句没有任何错误地完成，请继续执行下一步，否则执行步骤8



6. 备端执行以下语句打开转换后的主库：

SQL> alter database open;

SQL> alter pluggable database DGSRCPDB open;



7. 转换后的确认：

SQL> select database_role from v$database;



DATABASE_ROLE

\----------------

PRIMARY



Oracle建议您执行新的主数据库的完整备份。



8. 如果步骤5因错误而失败，请尝试解决错误原因，然后重新发出该语句。



■如果成功，请转至步骤6。

■如果错误仍然存在，并且涉及远程同步实例，请转至步骤9。

■如果错误仍然存在，并且没有涉及远端同步实例，请转至步骤10。



9. 仅对于远程同步实例错误情况，请使用FORCE选项。

如果错误涉及远程同步实例（例如，它不可用），并且您已尝试解决问题并重新发出该语句而未成功，则可以使用FORCE选项。例如：

SQL> ALTER DATABASE FAILVOVER TO DGTAR FORCE;

FORCE选项指示故障转移忽略与远程同步实例交互时遇到的任何故障，并尽可能继续进行故障转移。（FORCE选项仅在故障切换目标由远程同步实例服务时才有意义。）



如果FORCE选项成功，请转到步骤6。

如果FORCE选项不成功，请转至步骤10。



10. 执行数据丢失故障转移

如果无法解决错误情况，则可以通过在目标备用数据库上发出以下SQL语句来执行故障切换（但有些数据丢失）：

SQL> ALTER DATABASE ACTIVATE PHYSICAL STANDBY DATABASE;



Dataguard Failover 12c using SQL*Plus (文档 ID 2144024.1)

## 16、参数解释

alter system set LOG_ARCHIVE_CONFIG='DG_CONFIG=(WENDING,PHYSTDBY)' ;

启动db接受或发送redo data，包括所有库的db_unique_name



alter system set LOG_ARCHIVE_DEST_1='LOCATION=/orahome/arch1/WENDING
VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=WENDING' ;

主库归档目的地



alter system set LOG_ARCHIVE_DEST_2='SERVICE=db_phystdby LGWR ASYNC
VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=PHYSTDBY' ;

当该库充当主库角色时，设置物理备库redo data的传输目的地



alter system set LOG_ARCHIVE_MAX_PROCESSES=5;

最大ARCn进程数



alter system set LOG_ARCHIVE_DEST_STATE_1=ENABLE;

允许redo传输服务传输数据到目的地，默认是enable



alter system set LOG_ARCHIVE_DEST_STATE_2=ENABLE;

允许redo传输服务传输数据到目的地，默认是enable



alter system set REMOTE_LOGIN_PASSWORDFILE=EXCLUSIVE;

exclusive or shared，所有库sys密码要一致，默认是exclusive



以下是主库切换为备库，充当备库角色时的一些参数设置，如果不打算做数据库切换就不用设置了

alter system set FAL_SERVER=db_phystdby;

配置网络服务名，假如转换为备库角色时，从这里获取丢失的归档文件



alter system set FAL_CLIENT=db_wending;

配置网络服务名，fal_server拷贝丢失的归档文件到这里



alter system set DB_FILE_NAME_CONVERT='PHYSTDBY','WENDING' scope=spfile;

前为切换后的主库路径，后为切换后的备库路径，如果主备库目录结构完全一样，则无需设定



alter system set LOG_FILE_NAME_CONVERT='PHYSTDBY','WENDING' scope=spfile;

同上，这两个名字转换参数是主备库的路径映射关系，可能会是路径全名，看情况而定



alter system set STANDBY_FILE_MANAGEMENT=auto;

auto后当主库的datafiles增删时备库也同样自动操作，且会把日志传送到备库standby_archive_dest参数指定的目录下，确保该目录存在，如果你的存储采用文件系统没有问题，但是如果采用了裸设备，你就必须将该参数设置为manual



alter system set STANDBY_ARCHIVE_DEST='LOCATION=/orahome/arch1/WENDING';

一般和LOG_ARCHIVE_DEST_1的位置一样，如果备库采用ARCH传输方式，那么主库会把归档日志传到该目录下，这个参数在11g的时候已经废弃

  

相关文档

内部备注

附件

验证码：

  换一张

输入验证码：

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAYAAAA7MK6iAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEgAACxIB0t1+/AAAABZ0RVh0Q3JlYXRpb24gVGltZQAwOS8yNy8xN+stbYgAAAAcdEVYdFNvZnR3YXJlAEFkb2JlIEZpcmV3b3JrcyBDUzbovLKMAAABm0lEQVRIicXXwXGCQBTG8b+7uZsSTAXRCiQVhA6SXLgmJZgO5BguSQnYgR0EK0hKiAUs5rBvGVlBBEG/GWccxf0JC2/fjna7HU3JEz0BQnlNgbF3yBbIgBRIVWR+m8YcHYPzRE+BBfDY+O/KWQELFZmsNZwnegm8tgT9xCoybyfBeaJvgTVwfybqsgECFZm//Q/VwCgy1lrGroYHQEt4JSxzOgRa4GIAMsdy934PiO5npiKTuTNeXAgtrJH5UBPg54IwwJ3CVqO+swEegPea78MhYPfcroFlzTGhwtbevlFXLOrgqeKw4PeC5on+Ap5qjh37BcTPFjtXL/K+DxSAmwY4k7kiT3SGrT7+FWqNwmHJ9DPPE/0MIEtcQPnMO6EOPnYJAT5r8M4osFXYzqEpVXhXFCBT2HbllJTwM1CAtA1cws9AAVK3OqW066tibOGZd0BXKjLhdZdFuWHiC6Cx6zxLzZ4UiaG6kI2KTLEu+AUkwD6fvaMydpESLI9I33hle3u1hr62VssPZtjtSNussHdvJQoNeyeXITZt/1po2U5WDlb1AAAAAElFTkSuQmCC)![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAYAAAA7MK6iAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEgAACxIB0t1+/AAAABZ0RVh0Q3JlYXRpb24gVGltZQAwOS8yNy8xN+stbYgAAAAcdEVYdFNvZnR3YXJlAEFkb2JlIEZpcmV3b3JrcyBDUzbovLKMAAABu0lEQVRIicWX223CQBBFD26AlOAOMJoCQgl0AFQQSoEOoAN3EPLPKHYHKSFUQD686/jFPkysXMkSQsMc1jt7Z3Z2v9/xSVVTYG2eDJh3Qm5AAeRALiJfvpwzF1hVM2APbLz/rq0zcBCRIhqsqgfgLRLY1VFE9kFgVX0BLsDiSahVCaxE5Lv5ZTIxFJPrYnIPgyeAtuCDYLOnU0BruGEAZo9N9X5OCG1qKSKFXfFg5TVURiT2xe4BEmMOrnNaikgG7AKgOxPrgm9UNU2o3MilhapmInLywHcicjLblnpyrkPAUB0HF7wJvdC31EFwFgCeO+CxUIBsdr1e/V3iVzcqFypUdQswAgpALLgFh7qRREGh71yhSjufo6BjwHa1uapmZs9zwo5aD3yLhBaN1+ur9oe5EqrJYQx0jrvaXSoSqnHFJwtd0S+kMfA8BFw2js87w4XUhX/4wLY7nfD4NWEt0w59r46Ys4hsbVUfHIEEQqFauQtasxIAYwbHwOTP6GiNpzXsqWrBdFOIba9A30BWxDX9YKjJXasFNiPoX8MHx9t/G+gferX5wZLqOhKrM9VQ93CWc96drKa4tP0As8vvCUvsIrEAAAAASUVORK5CYII=)

sentinel

12CR2 64位 &nbsp;&nbsp;主端:RAC — 备端:单实例

操作系统版本

|

Red Hat Enterprise Linux Server &nbsp; release 6.4(2.6.32-358.el6.x86_64)以上

Red Hat Enterprise Linux Server &nbsp; release 7(3.10.0-123.el7.x86_64)以上  
  
---|---  
  
## 本示例命名：

  
|

SID

|

db_name

|

db_unique_name

|

Net service name  
  
---|---|---|---|---  
  
主端node1

|

dgsrc1

|

dgsrc

|

dgsrc

|

dgsrc_tns  
  
主端node2

|

dgsrc2

|

dgsrc

|

dgsrc

|

dgsrc_tns  
  
备端

|

dgtar

|

dgsrc

|

dgtar

|

dgtar_tns  
  
&nbsp;

## 1、主端设置force logging

[oracle]$ sqlplus / as sysdba

SQL&gt; select name,log_mode,force_logging from gv$database;

&nbsp;

NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; LOG_MODE&nbsp;&nbsp;&nbsp;&nbsp;
FORCE_LOGGING

\--------- ------------ ---------------------------------------

DGSRC&nbsp;&nbsp;&nbsp;&nbsp; ARCHIVELOG&nbsp;&nbsp; NO

DGSRC&nbsp;&nbsp;&nbsp;&nbsp; ARCHIVELOG&nbsp;&nbsp; NO

&nbsp;

SQL&gt; **alter database force logging;**

Database altered.

&nbsp;

SQL&gt; select name,log_mode,force_logging from gv$database;

&nbsp;

NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; LOG_MODE&nbsp;&nbsp;&nbsp;&nbsp;
FORCE_LOGGING

\--------- ------------ ---------------------------------------

DGSRC&nbsp;&nbsp;&nbsp;&nbsp; ARCHIVELOG&nbsp;&nbsp; YES

DGSRC&nbsp;&nbsp;&nbsp;&nbsp; ARCHIVELOG&nbsp;&nbsp; YES

## 2、 主端设置归档模式

查看是否为归档模式：

SQL&gt; archive log list;

Database log mode &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Archive Mode

Automatic archival&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Enabled

Archive destination&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; +FRA

Oldest online log sequence&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;4

Next log sequence to archive&nbsp;&nbsp; &nbsp;&nbsp;5

Current log sequence&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;5

若Database log mode 显示为Archive Mode即为归档模式，Archive
destination显示为归档路径，也可以查看归档路径的参数确定归档位置。

SQL&gt; show parameter log_archive_dest_1

&nbsp;

NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
TYPE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; VALUE

\------------------------------------ -----------
------------------------------

log_archive_dest_1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;string&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
LOCATION=+FRA

若Database log mode 显示为No Archive Mode即为非归档模式，以下开启归档模式

先设置归档路径

SQL&gt; alter system set log_archive_dest_1=&#39;location=+FRA&#39;;

注：归档日志存放在共享存储上，在共享存储ASM上单独划分存放归档日志的磁盘组，比如FRA。如果共享存储没有空间，需要将归档放置本地磁盘时，必须在RAC所有节点上共享本地磁盘存放归档的路径，比如NFS。

&nbsp;

关闭所有实例，启动1号实例到mount状态

SQL&gt; shutdown immediate

SQL&gt; startup mount;

开始归档模式

SQL&gt; alter database archivelog;

SQL&gt; alter database open;

SQL&gt; alter pluggable database DGSRCPDB open;

启动其他实例

## 3、主端配置参数

查看主端的db_unique_name

[oracle]$ sqlplus / as sysdba

SQL&gt; show parameter db_unique_name

NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
TYPE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; VALUE

\------------------------------------ -----------
------------------------------

db_unique_name&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
string&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; dgsrc

&nbsp;

SQL&gt; ALTER SYSTEM SET LOG_ARCHIVE_CONFIG=&#39;DG_CONFIG=(DGSRC,DGTAR)&#39;
SID=&#39;*&#39;;

 **#** ** _注 红色取值为主库和备库的 DB_UNIQUE_NAME_**

 ** _备端db_unique_name 可以自定义，只要和备机启动时的参数一致就可以。_**

&nbsp;

SQL&gt; ALTER SYSTEM SET LOG_ARCHIVE_DEST_1=&#39;LOCATION=+FRA
VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=DGSRC&#39; SID=&#39;*&#39;;

&nbsp;

SQL&gt; ALTER SYSTEM SET LOG_ARCHIVE_DEST_2=&#39;SERVICE=DGTAR_TNS LGWR ASYNC
REOPEN NET_TIMEOUT=300 VALID_FOR=(ONLINE_LOGFILE,PRIMARY_ROLE)
DB_UNIQUE_NAME=DGTAR&#39; SID=&#39;*&#39;;

 **#** ** _注 红色取值为主库tnsnames.ora文件中备库的Net service name_**

&nbsp;

SQL&gt; alter system set LOG_ARCHIVE_DEST_STATE_1=ENABLE;

&nbsp;

SQL&gt; alter system set LOG_ARCHIVE_DEST_STATE_2=ENABLE;

&nbsp;

SQL&gt; ALTER SYSTEM SET STANDBY_FILE_MANAGEMENT =AUTO SID=&#39;*&#39;;

&nbsp;

SQL&gt; ALTER SYSTEM SET FAL_SERVER=&#39;DGTAR_TNS&#39; SID=&#39;*&#39;;

 **#** ** _注 红色取值为主库tnsnames.ora文件中备库的Net service name_**

 **FAL_SERVER And FAL_CLIENT Settings For Cascaded Standby (** **文档 ID
358767.1)**

 **& nbsp;**

以下参数修改需要重启数据库，注意：如果主端是RAC环境，且不能重启数据库，请不要修改以下参数。备端必须进行设置。

SQL&gt; alter system set DB_FILE_NAME_CONVERT =
&#39;/data/dgtar/&#39;,&#39;+DATA/DGSRC/&#39; sid=&#39;*&#39; scope=spfile;

SQL&gt; alter system set LOG_FILE_NAME_CONVERT =
&#39;/data/dgtar/&#39;,&#39;+DATA/DGSRC/&#39; sid=&#39;*&#39; scope=spfile;

&nbsp;

DB_FILE_NAME_CONVERT参数的作用是转换主库和备库的数据文件路径。

LOG_FILE_NAME_CONVERT参数的作用是转换主库和备库的redo日志文件的路径。

以上两个参数的书写格式是，两两路径为一组，对方的路径在前，自己的路径在后。

## 4、主端创建standby redologs

在主端备份数据库之前创建standby redolog，在备端执行alter database mount;后会在备端自动创建standby
redolog。

SQL&gt; col status format a10;

select thread#, GROUP#,SEQUENCE#,BYTES/1024/1024,STATUS,FIRST_TIME from v$log;

&nbsp;

&nbsp;&nbsp; THREAD#&nbsp;&nbsp;&nbsp;&nbsp; GROUP#&nbsp; SEQUENCE#
BYTES/1024/1024 STATUS&nbsp;&nbsp;&nbsp;&nbsp; FIRST_TIM

\---------- ---------- ---------- --------------- ---------- ---------

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
5&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 200
CURRENT&nbsp;&nbsp;&nbsp; 21-MAR-18

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
4&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 200
INACTIVE&nbsp;&nbsp; 21-MAR-18

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
3&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
3&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 200
INACTIVE&nbsp;&nbsp; 21-MAR-18

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
4&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
4&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 200
CURRENT&nbsp;&nbsp;&nbsp; 21-MAR-18

&nbsp;

SQL&gt; Set linesize 200

col member format a50

select * from v$logfile;

&nbsp;

GROUP# STATUS TYPE&nbsp;&nbsp;&nbsp;
MEMBER&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
IS_ CON_ID

\------ ------ ------- ------------------------------------------- --- ------

&nbsp;&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; +DATA/DGSRC/ONLINELOG/group_2.263.971295345
NO&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0

&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; +DATA/DGSRC/ONLINELOG/group_1.262.971295345
NO&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0

&nbsp;&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; +DATA/DGSRC/ONLINELOG/group_3.270.971295993
NO&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0

&nbsp;&nbsp;&nbsp;&nbsp; 4&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; +DATA/DGSRC/ONLINELOG/group_4.271.971296003
NO&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0

&nbsp;

主端创建standby redologs：

standby redo日志的大小 **必须至少与redo日志一样大；对于每个线程（** **THREAD#** **）的standby
redo的数量必须至少比当前线程的redo日志多一个日志组。**

当前的RAC环境中包含两个节点，每个节点有两个日志组（GROUP#），每个日志的大小为200MB，每个日志组有1个成员（+DATA）。根据这种情况，为每个线程创建3个大小为200MB的日志组，每个日志组包含1个成员，分别位于+DATA磁盘组。

&nbsp;

alter database add standby logfile thread 1 group 5 (&#39;+DATA&#39;) size
200M;

alter database add standby logfile thread 1 group 6 (&#39;+DATA&#39;) size
200M;

alter database add standby logfile thread 1 group 7 (&#39;+DATA&#39;) size
200M;

alter database add standby logfile thread 2 group 8 (&#39;+DATA&#39;) size
200M;

alter database add standby logfile thread 2 group 9 (&#39;+DATA&#39;) size
200M;

alter database add standby logfile thread 2 group 10 (&#39;+DATA&#39;) size
200M;

## 5、监听配置

### 5.1、备端配置静态监听服务名

 **此步骤仅限使用RMAN DUPLICATE时配置静态监听服务名。**

&nbsp;

在备端以oracle用户向$ORACLE_HOME/network/admin/listener.ora文件中添加以下条目：

SID_LIST_LISTENER =

&nbsp; (SID_LIST =

&nbsp;&nbsp;&nbsp; (SID_DESC =

&nbsp;&nbsp;&nbsp;&nbsp; (GLOBAL_DBNAME = dgtar)

&nbsp;&nbsp;&nbsp;&nbsp; (ORACLE_HOME = /u01/app/oracle/product/12.2.0/db_1)

&nbsp;&nbsp;&nbsp;&nbsp; (SID_NAME = dgtar)

&nbsp;&nbsp;&nbsp; )

&nbsp;&nbsp; )

&nbsp;

LISTENER =

&nbsp; (DESCRIPTION =

&nbsp;&nbsp;&nbsp; (ADDRESS = (PROTOCOL = TCP)(HOST = 备端的物理IP)(PORT = 1521))

&nbsp; )

SID_NAME：数据库实例名，其值需和数据库参数INSTANCE_NAME保持一致，不可省略。

GLOBAL_DBNAME：数据库服务名，可以省略，默认和SID_NAME保持一致。

ORACLE_HOME：实例运行的ORACLE_HOME目录。在UNIX和Linux环境下，该参数可以省略，默认和环境变量$ORACLE_HOME保持一致。在WINDOWS环境中，该参数无效，ORACLE_HOME的值取自注册表HKEY_LOCAL_MACHINE\SOFTWARE\ORACLE\HOMEID

&nbsp;

 **配置完成后重启监听器。**

###  5.2、主备端tnsnames.ora文件配置

以oracle用户配置$ORACLE_HOME/network/admin/tnsnames.ora文件

 **主端和备端** **tnsnames.ora** **文件都** **添加主备端** **IP** **配置** **条目** **。**

编辑文件tnsnames.ora 添加以下内容

[oracle]$ vi $ORACLE_HOME/network/admin/tnsnames.ora

&nbsp;

DGTAR_TNS =

&nbsp; (DESCRIPTION =

&nbsp;&nbsp;&nbsp; (ADDRESS = (PROTOCOL = TCP)(HOST = 备端的物理IP)(PORT = 1521))

&nbsp;&nbsp;&nbsp; (CONNECT_DATA =

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (SERVER = DEDICATED)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (SERVICE_NAME = dgtar)(UR=A)

&nbsp;&nbsp;&nbsp; )

&nbsp; )

# (UR=A)作用当备端数据库nomount,mount或者restricted时，动态监听显示状态为BLOCKED时，主端可通过配置UR=A进行连接。

&nbsp;

DGSRC_TNS =

&nbsp; (DESCRIPTION =

&nbsp;&nbsp;&nbsp; (ADDRESS = (PROTOCOL = TCP)(HOST = 主端scan ip)(PORT = 1521))

&nbsp;&nbsp;&nbsp; (CONNECT_DATA =

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (SERVER = DEDICATED)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (SERVICE_NAME = dgsrc)(UR=A)

&nbsp;&nbsp;&nbsp; )

&nbsp; )

&nbsp;

DGSRC_TNS1 =

&nbsp; (DESCRIPTION =

&nbsp;&nbsp;&nbsp; (ADDRESS = (PROTOCOL = TCP)(HOST = 主端node1 vip)(PORT =
1521))

&nbsp;&nbsp;&nbsp; (CONNECT_DATA =

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (SERVER = DEDICATED)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (SERVICE_NAME = dgsrc)(UR=A)

&nbsp;&nbsp;&nbsp; )

&nbsp; )

&nbsp;

DGSRC_TNS2 =

&nbsp; (DESCRIPTION =

&nbsp;&nbsp;&nbsp; (ADDRESS = (PROTOCOL = TCP)(HOST = 主端node2 vip)(PORT =
1521))

&nbsp;&nbsp;&nbsp; (CONNECT_DATA =

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (SERVER = DEDICATED)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (SERVICE_NAME = dgsrc)(UR=A)

&nbsp;&nbsp;&nbsp; )

&nbsp; )

注意：备端参数local_listener如果设置了LISTENER_DGTAR，那么备端tnsnames.ora文件需要添加以下内容：

DGTAR =

&nbsp; (DESCRIPTION =

&nbsp;&nbsp;&nbsp; (ADDRESS = (PROTOCOL = TCP)(HOST = dgtar)(PORT = 1521))

&nbsp;&nbsp;&nbsp; (CONNECT_DATA =

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (SERVER = DEDICATED)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (SERVICE_NAME = dgtar)

&nbsp;&nbsp;&nbsp; )

&nbsp; )

&nbsp;

LISTENER_DGTAR =

&nbsp; (ADDRESS = (PROTOCOL = TCP)(HOST = dgtar)(PORT = 1521))

备机启动监听

[oracle]$ lsnrctl start

&nbsp;

主端和备端测试监听配置：

[oracle]$ tnsping DGSRC_TNS

[oracle]$ tnsping DGTAR_TNS

## 6、主端传输密码文件至备端

主端节点1传输密码文件至备端和主端集群的其他节点上

# su - grid

[grid@dgsrc1 ~]$ asmcmd -p

ASMCMD [+] &gt; cd +data/dgsrc/PASSWORD

ASMCMD [+data/dgsrc/PASSWORD] &gt; cp pwddgsrc.256.971295071 /home/grid

# scp pwddgsrc.256.971295071备端的物理IP:$ORACLE_HOME/dbs/orapwdgtar

密码文件命名格式是orapw+SID

备端修改密码文件的属组

# chown oracle:oinstall $ORACLE_HOME/dbs/orapwdgtar

## 7、主端创建密码验证用户

SQL&gt; create user c##dgpasswd identified by 密码;

注意密码要提高复杂度。

&nbsp;

SQL&gt; GRANT SYSOPER to c##dgpasswd;

&nbsp;

SQL&gt; col USERNAME format a15

select USERNAME,SYSDBA,SYSOPER,SYSASM from V$PWFILE_USERS;

&nbsp;

USERNAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; SYSDB SYSOP SYSAS

\--------------- ----- ----- -----

SYS&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
TRUE&nbsp; TRUE&nbsp; FALSE

SYSDG&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; FALSE FALSE
FALSE

SYSBACKUP&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; FALSE FALSE FALSE

SYSKM&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; FALSE FALSE
FALSE

C##DGPASSWD&nbsp;&nbsp;&nbsp;&nbsp; FALSE TRUE&nbsp; FALSE

&nbsp;

SQL&gt; ALTER SYSTEM SET REDO_TRANSPORT_USER = C##DGPASSWD SID=&#39;*&#39;;

&nbsp;

 ** _\--_** **_How to make log shipping to continue work without copying
password file from primary to physical standby when changing sys password on
primary? (_** ** _文档_** **_ID 1416595.1)_**

##  8、备端修改主端生成的pfile参数文件

主端备份传输pfile参数文件：

SQL&gt; create pfile=&#39;/home/oracle/pfile.ora&#39; from spfile;

[oracle]$ scp /home/oracle/pfile.ora 备端的物理IP:/home/oracle/

在备端修改上一步传输的参数文件：

 **#** ** _注 本节标红的内容为需要修改的_**

*.audit_file_dest=&#39;/u01/app/oracle/admin/dgtar/adump&#39;

*.audit_trail=&#39;NONE&#39;

*.compatible=&#39;12.2.0&#39;

*.control_files=&#39;/data/dgtar/controlfile/current01.ctl&#39;

*.db_block_size=8192

*.db_create_file_dest=&#39;&#39; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; **#** ** _注 关闭OMF功能_**

*.db_create_online_log_dest_1=&#39;&#39;

*.db_create_online_log_dest_2=&#39;&#39;

*.db_file_name_convert=&#39;+DATA/DGSRC/&#39;,&#39;/data/dgtar/&#39;

*.db_name=&#39;dgsrc&#39;

*.diagnostic_dest=&#39;/u01/app/oracle&#39;

*.dispatchers=&#39;(PROTOCOL=TCP) (SERVICE=dgtarXDB)&#39;

*.enable_pluggable_database=true

*.fal_server=&#39;DGSRC_TNS&#39;

*.local_listener=&#39;LISTENER_DGTAR&#39;

*.log_archive_config=&#39;DG_CONFIG=(DGSRC,DGTAR)&#39;

*.log_archive_dest_1=&#39;LOCATION=/arch VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=DGTAR&#39;

*.log_archive_dest_2=&#39;SERVICE=DGSRC_TNS LGWR ASYNC REOPEN NET_TIMEOUT=300 VALID_FOR=(ONLINE_LOGFILE,PRIMARY_ROLE) DB_UNIQUE_NAME=DGSRC&#39;

*.log_archive_format=&#39;%t_%s_%r.dbf&#39;

*.log_file_name_convert=&#39;+DATA/DGSRC/&#39;,&#39;/data/dgtar/&#39;

*.nls_language=&#39;AMERICAN&#39;

*.nls_territory=&#39;AMERICA&#39;

*.open_cursors=300

*.pga_aggregate_target=787m

*.processes=300

*.redo_transport_user=&#39;C##DGPASSWD&#39;

*.remote_login_passwordfile=&#39;exclusive&#39;

*.sga_target=2360m

*.standby_file_management=&#39;AUTO&#39;

*.undo_tablespace=&#39;UNDOTBS1&#39;

*.service_names=&#39;dgsrc,dgtar&#39;

*.db_unique_name=&#39;dgtar&#39;

## 9、备端提前创建所需路径

[oracle]$ mkdir -p /u01/app/oracle/admin/dgtar/adump

[oracle]$ mkdir -p /data/dgtar/controlfile

[oracle]$ mkdir -p /arch

[oracle]$ mkdir -p /data/dgtar/onlinelog/

[oracle]$ mkdir -p /data/dgtar/datafile/

[oracle]$ mkdir -p /data/dgtar/tempfile/

## 10、备端复制主端数据库

有两种方式：

一种是使用RMAN在主端做备份，将备份文件传递至备端restore；

另一种是使用RMAN DUPLICATE...FROM ACTIVE DATABASE，这是oracle
11G新特性，最大的优势是可以不必耗费大量的磁盘空间中转落地的RMAN备份文件，而是直接通过主端数据文件生成备端数据文件。

Step by Step Guide on Creating Physical Standby Using RMAN DUPLICATE...FROM
ACTIVE DATABASE (文档 ID 1075908.1)

## 10.1、RMAN备份还原复制主端数据库

 **#** ** _注_** **_如果使用_** ** _RMAN DUPLICATE_** ** _方式，请跳过此章节。_**

###  10.1.1、备份primary

主端一个节点RMAN备份数据库，如果数据量很大，备份时间很长，建议后台执行备份脚本。

run {

allocate channel c1 type disk;

allocate channel c2 type disk;

allocate channel c3 type disk;

backup incremental level 0 format &#39;/home/oracle/rmanbak/dgsrc_full_%U&#39;
database;

backup format &#39;/home/oracle/rmanbak/dgsrc_stanctf_%U&#39; current
controlfile for standby;

release channel c1;

release channel c2;

release channel c3;

}

### 10.1.2、主端传输文件至备端

[oracle]$ scp /home/oracle/rmanbak/dgsrc_* 备端的物理IP:/home/oracle/backup/

如果是AIX或HP-UX没有scp工具的，参考使用FTP工具

在备端服务器上执行FTP命令get主端RMAN备份文件

# cd /home/oracle/backup/

# ftp 192.168.0.100

Name (192.168.0.100:root): root

331 Password required for root.

Password:

ftp&gt;

ftp&gt; cd /home/oracle/rmanbak

ftp&gt; ls

ftp&gt;
bin&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp; **#** ** _注 使用二进制传输备份文件_**

ftp&gt; prompt
off&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp; **#** ** _注 不用输入确认_**

ftp&gt; mget orcl_full_*

### 10.1.3、备端启动数据库到nomount

备端数据库先生成spfile后启动数据库到nomount状态

[oracle]$ export ORACLE_SID=dgtar

[oracle]$ sqlplus / as sysdba

SQL&gt; create spfile from pfile=&#39;/home/oracle/pfile.ora&#39;;

SQL&gt; startup nomount;

### 10.1.4、测试sqlplus连通性，确保能正常连通

主端和备端都要测试sqlplus连通性

[oracle]$ sqlplus /nolog

主端测试

SQL&gt; connect sys/Oracle123@dgtar_tns AS SYSDBA

备端测试

SQL&gt; connect sys/Oracle123@dgsrc_tns AS SYSDBA

### 10.1.5、备端restore database

restore控制文件

RMAN&gt; restore standby controlfile from
&#39;/home/oracle/backup/dgsrc_stanctf_0csuba8h_1_1&#39;;

备端将RMAN备份片加入到catalog中，rman备份的catalog使用控制文件。

RMAN&gt; alter database mount;

RMAN&gt; catalog start with &#39;/home/oracle/backup&#39;;

或

RMAN&gt; catalog backuppiece
&#39;/home/oracle/backup/dgsrc_full_03suba4t_1_1&#39;;

RMAN&gt; catalog backuppiece
&#39;/home/oracle/backup/dgsrc_full_04suba4u_1_1&#39;;

备端数据库restore数据文件

RMAN&gt; run {

allocate channel d1 type disk;

allocate channel d2 type disk;

allocate channel d3 type disk;

restore database;

release channel d1;

release channel d2;

release channel d3;

}

## 10.2、RMAN DUPLICATE复制主端数据库

 **#** ** _注_** **_如果使用_** ** _RMAN_** ** _备份还原方式，请跳过此章节。_**

###  10.2.1、备端启动数据库到nomount

备端数据库启动到nomount状态

[oracle]$ export ORACLE_SID=orcldg

[oracle]$ sqlplus / as sysdba

sql&gt; create spfile from pfile=&#39;/home/oracle/pfile.ora&#39;;

sql&gt; startup nomount;

### 10.2.2、测试sqlplus连通性，确保能正常连通

主端和备端都要测试sqlplus连通性

[oracle]$ sqlplus /nolog

主端测试

SQL&gt; connect sys/Oracle123@dgtar_tns AS SYSDBA

备端测试

SQL&gt; connect sys/Oracle123@dgsrc_tns AS SYSDBA

### 10.2.3、执行RMAN DUPLICATE

 ** _注意1：_**

如果主端是RAC，确保RMAN的SNAPSHOT CONTROLFILE在共享存储中，若不在共享存储中RMAN DUPLICATE复制控制文件会报以下错误：

ORA-00245: control file backup failed; target is likely on a local file system

RMAN&gt; show snapshot controlfile name;

&nbsp;

RMAN configuration parameters for database with db_unique_name ORCL are:

CONFIGURE SNAPSHOT CONTROLFILE NAME TO
&#39;/u01/app/oracle/product/11.2.0/db_1/dbs/snapcf_orcl1.f&#39;; # default

&nbsp;

RMAN&gt; CONFIGURE SNAPSHOT CONTROLFILE NAME TO &#39;+FRA/snapcf_orcl.f&#39;;

&nbsp;

new RMAN configuration parameters:

CONFIGURE SNAPSHOT CONTROLFILE NAME TO &#39;+FRA/snapcf_orcl.f&#39;;

new RMAN configuration parameters are successfully stored

参考文档：

Bug 21503053 - ORA-245 from RMAN Controlfile Backup on Local Device (文档 ID
21503053.8)

ORA-245: In RAC environment from 11.2 onwards Backup Or Snapshot controlfile
needs to be in shared location (文档 ID 1472171.1)

 ** _& nbsp;_**

 ** _注意2：_**

如果主端是RAC，使用RMAN连接主端数据库时不要使用SCAN的网络连接串，因为使用SCAN连接主数据会同时连接至RAC的两个节点上：

using target database control file instead of recovery catalog

allocated channel: prmy1

channel prmy1: SID=58 instance=orcl2 device type=DISK

&nbsp;

allocated channel: prmy2

channel prmy2: SID=62 instance=orcl2 device type=DISK

&nbsp;

allocated channel: prmy3

channel prmy3: SID=61 instance=orcl2 device type=DISK

&nbsp;

allocated channel: prmy4

channel prmy4: SID=73 instance=orcl1 device type=DISK

&nbsp;

allocated channel: stby

channel stby: SID=19 device type=DISK

…………

RMAN-00571: ========================================================

RMAN-00569: ============ ERROR MESSAGE STACK FOLLOWS ============

RMAN-00571: ==============================================

RMAN-03002: failure of Duplicate Db command at 06/25/2016 10:36:25

RMAN-05501: aborting duplication of target database

RMAN-03015: error occurred in stored script Memory Script

&nbsp;

RMAN-03009: failure of backup command on prmy1 channel at 06/25/2016 10:36:25

ORA-19505: failed to identify file
&quot;/u01/app/oracle/product/11.2.0/db_1/dbs/orapworcl1&quot;

ORA-27037: unable to obtain file status

Linux-x86_64 Error: 2: No such file or directory

Additional information: 3

解决方法：可以在主端的一个节点上配置tnsnames.ora添加当前节点的VIP网络连接串，RMAN连接主端数据库时，使用VIP网络连接串。

参考文档：

RMAN Active Duplicate for Standby for RAC Database Unable to Find the Password
File Failing with: ORA-19505, and ORA-27037 (文档 ID 1551235.1)

&nbsp;

 **RMAN** **连接主备数据库，开始RMAN** **DUPLICATE** **复制数据库：**

$ **rman target sys/Oracle123@dgsrc_tns1 auxiliary sys/Oracle123@dgtar_tns
nocatalog**

&nbsp;

Recovery Manager: Release 12.2.0.1.0 - Production on Wed Mar 21 14:22:58 2018

&nbsp;

Copyright (c) 1982, 2017, Oracle and/or its affiliates.&nbsp; All rights
reserved.

&nbsp;

connected to target database: DGSRC (DBID=788332716)

using target database control file instead of recovery catalog

connected to auxiliary database: DGSRC (not mounted)

&nbsp;

RMAN&gt; run {

allocate channel prmy1 type disk;

allocate channel prmy2 type disk;

allocate channel prmy3 type disk;

allocate auxiliary channel stby1 type disk;

allocate auxiliary channel stby2 type disk;

allocate auxiliary channel stby3 type disk;

 **duplicate target database for standby from active database
nofilenamecheck;**

}

## 11、备端同步主端的归档日志

备端恢复数据文件完成后，重启数据库到mount状态，开启介质恢复进程。

 **备端** 重启数据库

SQL&gt; startup mount force

 **& nbsp;**

 **备端** 启动恢复进程mrp0

SQL&gt; alter database recover managed standby database using current logfile
disconnect from session;

 **& nbsp;**

 **备端** 查询是否有mrp0进程

SQL&gt; set line 200

SELECT NAME,ROLE,INSTANCE,THREAD#,SEQUENCE#,BLOCK#,DELAY_MINS,ACTION FROM
GV$DATAGUARD_PROCESS;

&nbsp;

切换 **主库** 归档，观察备库归档日志同步是否正常。

SQL&gt; alter system archive log current;

&nbsp;

关闭介质恢复的方法：

SQL&gt; ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;

## 12、备端开启和关闭Active Data Guard

Active dataguard模式下，备机可提供只读的查询业务，不能写数据。

如果开启了介质恢复进程，需要先关闭介质恢复进程

SQL&gt; ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;

启动

SQL&gt; ALTER DATABASE OPEN READ ONLY;

SQL&gt; RECOVER MANAGED STANDBY DATABASE DISCONNECT USING CURRENT LOGFILE;

PDB开启只读模式

SQL&gt; show pdbs;

&nbsp;

&nbsp;&nbsp;&nbsp; CON_ID
CON_NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
OPEN MODE&nbsp; RESTRICTED

\---------- ------------------------------ ---------- ----------

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2
PDB$SEED&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
READ ONLY&nbsp; NO

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 3
DGSRCPDB&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
MOUNTED

&nbsp;

SQL&gt; **alter pluggable database DGSRCPDB open READ ONLY;**

Pluggable database altered.

&nbsp;

SQL&gt; show pdbs;

&nbsp;

&nbsp;&nbsp;&nbsp; CON_ID
CON_NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
OPEN MODE&nbsp; RESTRICTED

\---------- ------------------------------ ---------- ----------

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2
PDB$SEED&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
READ ONLY&nbsp; NO

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 3
DGSRCPDB&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
READ ONLY&nbsp; NO

## 13、查询同步情况

主端查询

SQL&gt; select max(sequence#),thread# from v$archived_log where
RESETLOGS_CHANGE# = (SELECT RESETLOGS_CHANGE# FROM V$DATABASE_INCARNATION
WHERE STATUS = &#39;CURRENT&#39;) GROUP BY THREAD#;

&nbsp;

MAX(SEQUENCE#)&nbsp;&nbsp;&nbsp; THREAD#

\-------------- ----------

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
7&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
6&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2

备端查询

SQL&gt; select max(sequence#),thread# from v$archived_log where&nbsp;
applied=&#39;YES&#39; and RESETLOGS_CHANGE# = (SELECT RESETLOGS_CHANGE# FROM
V$DATABASE_INCARNATION WHERE STATUS = &#39;CURRENT&#39;) GROUP BY THREAD#;

&nbsp;

MAX(SEQUENCE#)&nbsp;&nbsp;&nbsp; THREAD#

\-------------- ----------

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;7&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
6&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2

&nbsp;

主备以上结果对比，如果max(sequence#)相差较大，表示目前不同步或同步延时较大，如果相差1到2个是可以接受的。

&nbsp;

查看备机恢复进程状态的方法：

SQL&gt; SELECT NAME,ROLE,INSTANCE,THREAD#,SEQUENCE#,BLOCK#,DELAY_MINS,ACTION
FROM GV$DATAGUARD_PROCESS;

以下查询仅限Active Data Guard

SQL&gt; set line 200

select name,value&nbsp; from v$dataguard_stats;

&nbsp;

NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
VALUE

\-------------------------------- --------------------------------------------

transport
lag&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
+00 00:00:00

apply
lag&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
+00 00:00:00

apply finish
time&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
+00 00:00:00.000

estimated startup
time&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 23

## 14、Switchover

1. 检查主库和备库的参数设置

2. 确保主库设置了以下参数

SQL&gt; alter system set DB_FILE_NAME_CONVERT =
&#39;/data/dgtar/&#39;,&#39;+DATA/DGSRC/&#39; sid=&#39;*&#39; scope=spfile;

SQL&gt; alter system set LOG_FILE_NAME_CONVERT =
&#39;/data/dgtar/&#39;,&#39;+DATA/DGSRC/&#39; sid=&#39;*&#39; scope=spfile;

3. 确保主库创建了standby logfile联机redo日志文件

SQL&gt; select * from v$standby_log;

4. 确保compatible主库和备库相同

5. 确保Managed Recovery运行在备库，且主备端同步正常

SQL&gt; SELECT NAME FROM GV$DATAGUARD_PROCESS WHERE NAME LIKE &#39;MRP%&#39;;

NAME

\---------

MRP0

&nbsp;

 **主端** 使用verify执行switchover前的验证

SQL&gt; alter database switchover to &lt;target standby db_unique_name&gt;
verify;

&nbsp;

如果Standby 状态与primary 状态同步，我们会收到以下消息，

SQL&gt; alter database switchover to dgtar verify;

Database altered.

12c Data guard Switchover Best Practices using SQLPLUS (文档 ID 1578787.1)

6. 验证主库和备库的tempfiles是否匹配

SQL&gt; col name for a45

select ts#,name,ts#,status&nbsp; from v$tempfile;

如果查询不匹配，可以在打开新的主库后再纠正。

7. 清除可能受阻的参数与jobs

主端查看当前DBMS_JOB 的状态

SQL&gt; SELECT * FROM DBA_JOBS_RUNNING;

主端查看当前DBMS_SCHEDULER的状态

SQL&gt; select owner,job_name,session_id,slave_process_id,running_instance
from dba_scheduler_running_jobs;

如果有正在运行的job则不建议切换，最好等job运行完，或者停掉job（详细参考oracle Job操作手册）。

SQL&gt; SHOW PARAMETER job_queue_processes

禁止所有job再自动执行

SQL&gt; ALTER SYSTEM SET job_queue_processes=0 SCOPE=BOTH SID=&#39;*&#39;;

8. 打开Data Guard 主库和备库的日志跟踪

主库和备库查询跟踪级别

SQL&gt; SHOW PARAMETER log_archive_trace

&nbsp;

NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
TYPE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; VALUE

\------------------------------------ -----------
------------------------------

log_archive_trace&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
integer&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;

&nbsp;

设置Data Guard的跟踪级别8191在主和目标物理备用数据库

SQL&gt; ALTER SYSTEM SET log_archive_trace=8191;

打开后会在background_dump_dest参数指定的目录里生成类似ora11g_ **mrp0** _31640.trc的trc日志文件。

可以ls -lrt *mrp0* 来定位最后一个文件。

&nbsp;

查看alter日志

SQL&gt; SHOW PARAMETER background_dump_dest

&nbsp;

# tail -f alert_orcl.log

9. 创建可靠还原点（可选）如果switch切换后有问题可以通过还原点回退数据库。

确认是否开启了闪回，如果没有则要先开启，主库和备库。

&nbsp;

备库：

SQL&gt; show parameter DB_RECOVERY

NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
TYPE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; VALUE

\------------------------------------ -----------
------------------------------

db_recovery_file_dest&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
string

db_recovery_file_dest_size&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
big integer 0

&nbsp;

SQL&gt; ALTER SYSTEM SET DB_RECOVERY_FILE_DEST_SIZE=10G;

SQL&gt; ALTER SYSTEM SET DB_RECOVERY_FILE_DEST=&#39;/fra/flashback&#39;;

&nbsp;

SQL&gt; show parameter DB_RECOVERY

NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
TYPE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; VALUE

\------------------------------------ -----------
------------------------------

db_recovery_file_dest&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
string&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /fra/flashback

db_recovery_file_dest_size&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
big integer 10G

&nbsp;

停止恢复应用

SQL&gt; RECOVER MANAGED STANDBY DATABASE CANCEL;

Media recovery complete.

创建还原点

SQL&gt; CREATE RESTORE POINT SWITCHOVER_START_GRP GUARANTEE FLASHBACK
DATABASE;

&nbsp;

启动应用进程

SQL&gt; RECOVER MANAGED STANDBY DATABASE DISCONNECT USING CURRENT LOGFILE;

&nbsp;

查看还原点信息&nbsp;&nbsp;

SQL&gt; col NAME format a30

col time format a40

set line 300

select NAME,SCN,TIME from v$restore_point;

&nbsp;

&nbsp;&nbsp;
NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
SCN TIME

\------------------------------ ----------
-------------------------------------

SWITCHOVER_START_GRP&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
987029 04-JUL-16 02.11.05.000000000 PM

&nbsp;

主库同样检查是否开启闪回，并创建还原点

SQL&gt; CREATE RESTORE POINT SWITCHOVER_START_GRP GUARANTEE FLASHBACK
DATABASE;

Restore point created.

&nbsp;

 **注意如果创建还原点，在** **switch** **切换完毕后一定要删除主备节点上还原点，否则还原点的文件会不断增长直到磁盘爆满。**

 **删除方法：**

SQL&gt; **drop restore point** SWITCHOVER_START_GRP;

10. 将备用数据库切换到主数据库

主端：

SQL&gt; alter database switchover to &lt;target standby db_unique_name&gt;;

例如：

SQL&gt; alter database switchover to dgtar;

11\. open新的主库

SQL&gt; ALTER DATABASE OPEN;

SQL&gt; alter pluggable database DGSRCPDB open;

12. 如果有不匹配的临时表空间，更正不匹配的临时表空间

13. 重新启动新的备库

SQL&gt; SHUTDOWN ABORT;

SQL&gt; startup

SQL&gt; alter pluggable database DGSRCPDB open read only;

SQL&gt; RECOVER MANAGED STANDBY DATABASE DISCONNECT USING CURRENT LOGFILE;

14. 切换还原参数

SQL&gt; ALTER SYSTEM SET log_archive_trace=0;

SQL&gt; ALTER SYSTEM SET job_queue_processes=&lt;value saved&gt; scope=both
sid=’*’

SQL&gt; EXECUTE DBMS_SCHEDULER.ENABLE(&lt;for each job name captured&gt;);

SQL&gt; DROP RESTORE POINT SWITCHOVER_START_GRP;

 **另外要调整主备端自动删除归档的脚本和计划任务** **。**

15. 切换的检查

主端：

SQL&gt; alter system switch logfile;

&nbsp;

SQL&gt; select max(sequence#),thread# from v$log_history group by thread#;

&nbsp;

SQL&gt; select dest_id,error,status from v$archive_dest where dest_id=&lt;your
remote log_archive_dest_&lt;n&gt;&gt;;

&nbsp;

If remote log_Archive_destination is 2 i.e log_archive_dest_2.

&nbsp;

SQL&gt; select dest_id,error,status from v$archive_dest where dest_id=2;

&nbsp;

SQL&gt; select max(sequence#)&nbsp; from v$archived_log where
applied=&#39;YES&#39; and dest_id=2;

&nbsp;

备端：

&nbsp;

SQL&gt; select max(sequence#),thread# from v$archived_log group by thread#;

&nbsp;

SQL&gt; select name,role,instance,thread#,sequence#,action from
gv$dataguard_process;

&nbsp;

注意：对于Oracle版本12.2，请使用v $ dataguard_process而不是在Oracle 12.2中弃用的v $
managed_standby

12c Data guard Switchover Best Practices using SQLPLUS (文档 ID 1578787.1)

## 15、failover

1. 主端flush redo

&nbsp;

如果主库可以mount，则在mount状态下执行以下步骤，如果不能mount则跳过这一步

SQL&gt; alter system flush redo to
&#39;&lt;target_db_name&gt;&#39;;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

 ** _注：target_db_name=备端的DB_UNIQUE_NAME_**

示例:

SQL&gt; alter system flush redo to dgtar;

flush redo是在11gR2被引入的. 对于Data guard, 在故障切换时flush
redo可能是非常有用的，如果这个命令能成功将最后的redo应用到备库上，那么data guard failover将不会丢失数据。

如果需要执行此语句，在备库上的 redo apply进程必须是启动的，执行此命令的主库必须是mouted 状态，不能open ,默认情况下这个语句
带有参数comfirm apply，语句执行将会一直等待所有redo applied。

&nbsp;

2\. 确认备用数据库具有每个主数据库redo线程最近存档的redo日志文件。

&nbsp;

查询备库上的 V$ARCHIVED_LOG 视图以获取每个重做线程的最高日志序列号。

For example:

SQL&gt; SELECT UNIQUE THREAD# AS THREAD, MAX(SEQUENCE#)&nbsp; OVER (PARTITION
BY thread#) AS LAST from V$ARCHIVED_LOG;

THREAD&nbsp;&nbsp;&nbsp;&nbsp; LAST

\---------- ----------

1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;48

&nbsp;

如果可能，将每个主数据库redo线程的最近归档的redo日志文件复制到备用数据库（如果它不存在）并注册它。这必须为每个redo线程完成。

SQL&gt; ALTER DATABASE REGISTER PHYSICAL LOGFILE &#39;filespec1&#39;;

For example:

SQL&gt; alter database register physical logfile
&#39;/fra/arch/1_42_916276568.dbf&#39;;

SQL&gt; alter database register physical logfile
&#39;/fra/arch/1_43_916276568.dbf&#39;;

SQL&gt; alter database register physical logfile
&#39;/fra/arch/1_44_916276568.dbf&#39;;

&nbsp;

3\. 检查并处理任何归档的redo日志断档

查询备库上的 V$ARCHIVE_GAP 视图，以确定目标备用数据库是否存在任何redo断档。

For example:

SQL&gt; SELECT THREAD#, LOW_SEQUENCE#, HIGH_SEQUENCE# FROM V$ARCHIVE_GAP;

&nbsp;

THREAD# LOW_SEQUENCE# HIGH_SEQUENCE#

\---------- ------------- --------------

1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
90&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
92

&nbsp;

在此示例中，redo断档包含线程1的序列号为90,91和92的归档重做日志文件。将缺少的归档重做日志文件从主数据库复制到目标备用数据库，并将它们注册到目标备用数据库。这必须为每个重做线程完成。

For example:

SQl&gt; ALTER DATABASE REGISTER PHYSICAL LOGFILE &#39;filespec1&#39;;

&nbsp;

4. 备端执行以下语句停止redo应用服务

SQL&gt; ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;

&nbsp;

5. 将物理备用数据库切换为主要角色。

在目标备用数据库上发出以下SQL语句：

SQL&gt; ALTER DATABASE FAILOVER TO target_db_name;

例如，假设目标备用数据库名为DGTAR：

SQL&gt; ALTER DATABASE FAILOVER TO DGTAR;

&nbsp;

++如果此语句没有任何错误地完成，请继续执行下一步，否则执行步骤8

&nbsp;

6. 备端执行以下语句打开转换后的主库：

SQL&gt; alter database open;

SQL&gt; alter pluggable database DGSRCPDB open;

&nbsp;

7. 转换后的确认：

SQL&gt; select database_role from v$database;

&nbsp;

DATABASE_ROLE

\----------------

PRIMARY

&nbsp;

Oracle建议您执行新的主数据库的完整备份。

&nbsp;

8. 如果步骤5因错误而失败，请尝试解决错误原因，然后重新发出该语句。

&nbsp;

■如果成功，请转至步骤6。

■如果错误仍然存在，并且涉及远程同步实例，请转至步骤9。

■如果错误仍然存在，并且没有涉及远端同步实例，请转至步骤10。

&nbsp;

9. 仅对于远程同步实例错误情况，请使用FORCE选项。

如果错误涉及远程同步实例（例如，它不可用），并且您已尝试解决问题并重新发出该语句而未成功，则可以使用FORCE选项。例如：

SQL&gt; ALTER DATABASE FAILVOVER TO DGTAR FORCE;

FORCE选项指示故障转移忽略与远程同步实例交互时遇到的任何故障，并尽可能继续进行故障转移。（FORCE选项仅在故障切换目标由远程同步实例服务时才有意义。）

&nbsp;

如果FORCE选项成功，请转到步骤6。

如果FORCE选项不成功，请转至步骤10。

&nbsp;

10. 执行数据丢失故障转移

如果无法解决错误情况，则可以通过在目标备用数据库上发出以下SQL语句来执行故障切换（但有些数据丢失）：

SQL&gt; ALTER DATABASE ACTIVATE PHYSICAL STANDBY DATABASE;

&nbsp;

Dataguard Failover 12c using SQL*Plus (文档 ID 2144024.1)

## 16、参数解释

alter system set LOG_ARCHIVE_CONFIG=&#39;DG_CONFIG=(WENDING,PHYSTDBY)&#39; ;

启动db接受或发送redo data，包括所有库的db_unique_name

&nbsp;

alter system set LOG_ARCHIVE_DEST_1=&#39;LOCATION=/orahome/arch1/WENDING
VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=WENDING&#39; ;

主库归档目的地

&nbsp;

alter system set LOG_ARCHIVE_DEST_2=&#39;SERVICE=db_phystdby LGWR ASYNC
VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=PHYSTDBY&#39; ;

当该库充当主库角色时，设置物理备库redo data的传输目的地

&nbsp;

alter system set LOG_ARCHIVE_MAX_PROCESSES=5;

最大ARCn进程数

&nbsp;

alter system set LOG_ARCHIVE_DEST_STATE_1=ENABLE;

允许redo传输服务传输数据到目的地，默认是enable

&nbsp;

alter system set LOG_ARCHIVE_DEST_STATE_2=ENABLE;

允许redo传输服务传输数据到目的地，默认是enable

&nbsp;

alter system set REMOTE_LOGIN_PASSWORDFILE=EXCLUSIVE;

exclusive or shared，所有库sys密码要一致，默认是exclusive

&nbsp;

以下是主库切换为备库，充当备库角色时的一些参数设置，如果不打算做数据库切换就不用设置了

alter system set FAL_SERVER=db_phystdby;

配置网络服务名，假如转换为备库角色时，从这里获取丢失的归档文件

&nbsp;

alter system set FAL_CLIENT=db_wending;

配置网络服务名，fal_server拷贝丢失的归档文件到这里

&nbsp;

alter system set DB_FILE_NAME_CONVERT=&#39;PHYSTDBY&#39;,&#39;WENDING&#39;
scope=spfile;

前为切换后的主库路径，后为切换后的备库路径，如果主备库目录结构完全一样，则无需设定

&nbsp;

alter system set LOG_FILE_NAME_CONVERT=&#39;PHYSTDBY&#39;,&#39;WENDING&#39;
scope=spfile;

同上，这两个名字转换参数是主备库的路径映射关系，可能会是路径全名，看情况而定

&nbsp;

alter system set STANDBY_FILE_MANAGEMENT=auto;

auto后当主库的datafiles增删时备库也同样自动操作，且会把日志传送到备库standby_archive_dest参数指定的目录下，确保该目录存在，如果你的存储采用文件系统没有问题，但是如果采用了裸设备，你就必须将该参数设置为manual

&nbsp;

alter system set
STANDBY_ARCHIVE_DEST=&#39;LOCATION=/orahome/arch1/WENDING&#39;;

一般和LOG_ARCHIVE_DEST_1的位置一样，如果备库采用ARCH传输方式，那么主库会把归档日志传到该目录下，这个参数在11g的时候已经废弃

  

" name="docDetail" type="hidden">


---
### ATTACHMENTS
[7f025a17697ee15eb3197c61326b203b]: media/Oracle-安装手册-DataGaurd_RAC对单机-12CR2_for_Linux.html
[Oracle-安装手册-DataGaurd_RAC对单机-12CR2_for_Linux.html](media/Oracle-安装手册-DataGaurd_RAC对单机-12CR2_for_Linux.html)
>hash: 7f025a17697ee15eb3197c61326b203b  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-DataGaurd_RAC对单机-12CR2_for_Linux_files\11947ec6e06f4dd6a765bcc48c4fc88d.png  

---
### NOTE ATTRIBUTES
>Created Date: 2018-09-25 03:29:14  
>Last Evernote Update Date: 2018-10-01 15:33:53  
>author: YangKwong  
>source: desktop.win  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-DataGaurd_RAC对单机-12CR2_for_Linux.html  
>source-application: evernote.win32  