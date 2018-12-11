# Oracle-安装手册-11gR2_Data Gaurd单机对单机.html

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

061746904

Oracle-安装手册-11gR2_Data Gaurd单机对单机

目录

环境

文档用途

详细信息

相关文档

内部备注

附件

环境

系统平台：Linux x86-64 Red Hat Enterprise Linux 5,Linux x86-64 Red Hat Enterprise
Linux 6,Linux x86-64 Red Hat Enterprise Linux 7

版本：11.2.0.4

文档用途

指导安装11gR2 Data Guard 单机对单机

详细信息

确认主备端OS及DB版本是否一致、是否通过认证

如若两端OS及DB版本存在差异，务必声明

  

 **1、主端设置force logging**

$ sqlplus / as sysdba

SQL> select name,log_mode,force_logging from gv$database;



NAME      LOG_MODE     FOR

\--------- ------------ ---

ORCL       ARCHIVELOG   NO



SQL> **alter database force logging;**

Database altered.



SQL> select name,log_mode,force_logging from gv$database;



NAME      LOG_MODE     FOR

\--------- ------------ ---

ORCL       ARCHIVELOG   YES

 **  
**

 **2** **、 主端设置归档模式**  

查看是否为归档模式：

SQL> archive log list;

Database log mode               Archive Mode

Automatic archival             Enabled

Archive destination            /fra

Oldest online log sequence     4

Next log sequence to archive   5

Current log sequence           5

若Database log mode 显示为Archive Mode即为归档模式，Archive
destination显示为归档路径，也可以查看归档路径的参数确定归档位置。

SQL> show parameter log_archive_dest_1



NAME                                 TYPE        VALUE

\------------------------------------ -----------
------------------------------

log_archive_dest_1                   string      LOCATION=/fra

若Database log mode 显示为No Archive Mode即为非归档模式，以下开启归档模式

先设置归档路径

SQL> alter system set log_archive_dest_1='location=/fra/arch/';

注：创建存放归档的目录 **并修改目录权限** ，如规划归档存放路径是/fra/arch则

mkdir /fra/arch

chown oracle:oinstall /fra/arch



重启实例到mount状态

SQL> shutdown immediate

SQL> startup mount;

开始归档模式

SQL> alter database archivelog;

SQL> alter database open;

##

 **3、主端配置参数**

查看主端的db_unique_name

sqlplus / as sysdba

sql>show parameter db_unique_name



SQL> ALTER SYSTEM SET LOG_ARCHIVE_CONFIG='DG_CONFIG=(ORCL,ORCLDG)' SID='*';

 **#** ** _注 红色取值为主库和备库的 DB_UNIQUE_NAME_**

 ** _备端db_unique_name 可以自定义，只要和备机启动时的参数一致就可以。_**



SQL> ALTER SYSTEM SET LOG_ARCHIVE_DEST_1='LOCATION=/fra
VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=ORCL' SID='*';



SQL> ALTER SYSTEM SET LOG_ARCHIVE_DEST_2='SERVICE=ORCLDG LGWR ASYNC REOPEN
NET_TIMEOUT=300 VALID_FOR=(ONLINE_LOGFILE,PRIMARY_ROLE) DB_UNIQUE_NAME=ORCLDG'
SID='*';

 **#** ** _注 红色取值为主库tnsnames.ora文件中备库的Net service name_**



SQL> alter system set LOG_ARCHIVE_DEST_STATE_1=ENABLE;



SQL> alter system set LOG_ARCHIVE_DEST_STATE_2=ENABLE;



SQL> ALTER SYSTEM SET STANDBY_FILE_MANAGEMENT =AUTO SID='*';



SQL> ALTER SYSTEM SET STANDBY_ARCHIVE_DEST='/fra';   **#** ** _注 11G此参数已废弃_**



SQL> ALTER SYSTEM SET FAL_CLIENT='ORCL' SID='*';         **#** ** _注
11G此参数已废弃_**

 **#** ** _注 红色取值为主库tnsnames.ora文件中主库的Net service name_**



SQL> ALTER SYSTEM SET FAL_SERVER='ORCLDG' SID='*';

 **#** ** _注 红色取值为主库tnsnames.ora文件中备库的Net service name_**

 **FAL_SERVER And FAL_CLIENT Settings For Cascaded Standby (** **文档 ID
358767.1)**

 ** **

以下参数修改需要重启数据库，但是当数据库作为Dataguard的主端时，是不起作用的。只有当当前数据库的角色为Data
guard的备机时，DB_FILE_NAME_CONVERT和LOG_FILE_NAME_CONVERT才会发挥作用。

SQL> alter system set DB_FILE_NAME_CONVERT =
'/data/orcldg/datafile/','/data/orcl/' scope=spfile;



SQL> alter system set LOG_FILE_NAME_CONVERT =
'/data/orcldg/onlinelog/','/data/orcl/'  scope=spfile;



DB_FILE_NAME_CONVERT参数的作用是转换主库和备库的数据文件路径。

LOG_FILE_NAME_CONVERT参数的作用是转换主库和备库的redo日志文件的路径。

以上两个参数的书写格式是，两两路径为一组，对方的路径在前，自己的路径在后。

 **  
**

 **4、主端创建standby redologs，仅限11G**

对于11G此步骤可以在主端备份数据库之前创建standby redolog，在备端执行alter database
mount;后会在备端自动创建standby redolog。

SQL> col status format a10;

select thread#, GROUP#,SEQUENCE#,BYTES/1024/1024,STATUS,FIRST_TIME from v$log;



   THREAD#     GROUP#  SEQUENCE# BYTES/1024/1024 STATUS     FIRST_TIM

\---------- ---------- ---------- --------------- ---------- ---------

         1          1         13              50 CURRENT    06-JUL-16

         1          2         11              50 INACTIVE   04-JUL-16

         1          3         12              50 ACTIVE     06-JUL-16



SQL> Set linesize 200

col member format a50

select * from v$logfile;



    GROUP# STATUS     TYPE    MEMBER                                 IS_

\---------- ---------- ------- -------------------------------------- ---

         3            ONLINE  /data/orcl/redo03.log                  NO

         2            ONLINE  /data/orcl/redo02.log                  NO

         1            ONLINE  /data/orcl/redo01.log                  NO



主端创建standby redologs：

standby redo日志的大小必须 **至少与redo日志一样大** ； **对于每个线程（** **THREAD#** **）的standby
redo的数量必须至少比当前线程的redo日志多一个日志组。**

当前环境中包含1个节点，有3个日志组（GROUP#），每个日志的大小为50MB，每个日志组有1个成员。根据这种情况，为每个线程创建4个大小为50MB的日志组，每个日志组包含1个成员，位于/data/orcl目录下。



SQL> ALTER DATABASE ADD STANDBY LOGFILE THREAD 1

GROUP 4 ('/data/orcl/stdbyredo01.log') SIZE 50M,

GROUP 5 ('/data/orcl/stdbyredo02.log') SIZE 50M,

GROUP 6 ('/data/orcl/stdbyredo03.log') SIZE 50M,

GROUP 7 ('/data/orcl/stdbyredo04.log') SIZE 50M;

 **  
**

 **5、监听配置**

 **5.1、备端配置静态监听服务名**

 **此步骤仅限11G使用RMAN DUPLICATE时配置静态监听服务名。**



在备端以oracle用户向$ORACLE_HOME/network/admin/listener.ora文件中添加以下条目，完成静态注册监听：

SID_LIST_LISTENER =

  (SID_LIST =

    (SID_DESC =

     (GLOBAL_DBNAME = orcldg)

     (ORACLE_HOME = /u01/app/oracle/product/11.2.0/db_1)

     (SID_NAME = orcldg)

    )

   )



LISTENER =

  (DESCRIPTION =

    (ADDRESS = (PROTOCOL = TCP)(HOST =备端的物理IP)(PORT = 1521))

  )

SID_NAME：数据库实例名，其值需和数据库参数INSTANCE_NAME保持一致，不可省略。

GLOBAL_DBNAME：数据库服务名，可以省略，默认和SID_NAME保持一致。

ORACLE_HOME：实例运行的ORACLE_HOME目录。在UNIX和Linux环境下，该参数可以省略，默认和环境变量$ORACLE_HOME保持一致。在WINDOWS环境中，该参数无效，ORACLE_HOME的值取自注册表HKEY_LOCAL_MACHINE\SOFTWARE\ORACLE\HOMEID

 ** **

 **配置完成后重启监听器。**

 **  
**

 **5.2、主备端tnsnames.ora文件配置**

配置$ORACLE_HOME/network/admin/tnsnames.ora文件

 **主端和备端** **tnsnames.ora** **文件都** **添加主备端** **IP** **配置** **条目** **。**



$ cat tnsnames.ora



ORCLDG =

  (DESCRIPTION =

    (ADDRESS_LIST =

      (ADDRESS = (PROTOCOL = TCP)(HOST = 备端的物理IP)(PORT = 1521))

    )

    (CONNECT_DATA =

      (SERVICE_NAME = orcl) (UR=A)

    )

  )

# (UR=A)作用当备端数据库nomount,mount或者restricted时，动态监听显示状态为BLOCKED时，主端可通过配置UR=A进行连接。



ORCL =

  (DESCRIPTION =

    (ADDRESS_LIST =

      (ADDRESS = (PROTOCOL = TCP)(HOST = 主端的物理IP)(PORT = 1521))

    )

    (CONNECT_DATA =

      (SERVICE_NAME = orcl)

    )

  )

备机启动监听

$ lsnrctl start

 ** **

主端和备端测试监听配置：

$ tnsping ORCL

$ tnsping ORCLDG

 **  
**

 **6、主端传输密码文件至备端**

$ scp $ORACLE_HOME/dbs/orapworcl  备端的物理IP:$ORACLE_HOME/dbs/orapworcldg

密码文件命名格式是orapw+SID

 **  
**

 **7、主端创建密码验证用户，仅限11G**

SQL> create user dgmima identified by 密码;

注意密码要提高复杂度。



SQL> GRANT SYSOPER to dgmima;



SQL>  select * from V$PWFILE_USERS;



USERNAME                       SYSDB SYSOP SYSAS

\------------------------------ ----- ----- -----

SYS                            TRUE  TRUE  FALSE

DGMIMA                         FALSE TRUE  FALSE



SQL> ALTER SYSTEM SET REDO_TRANSPORT_USER = DGMIMA SID='*';



 ** _\--_** **_How to make log shipping to continue work without copying
password file from primary to physical standby when changing sys password on
primary? (_** ** _文档_** **_ID 1416595.1)_**

 **  
**

 **8、备端修改主端生成的pfile参数文件**

主端备份传输pfile参数文件：

SQL> create pfile='/home/oracle/pfile.ora' from spfile;

$ scp /home/oracle/pfile.ora 备端的物理IP:/home/oracle/

在备端修改上以步传输的参数文件：

 **#** ** _注 本节标红的内容为需要修改的_**

10G：

*.audit_file_dest='/u01/app/oracle/admin/orcldg/adump'

*.background_dump_dest='/u01/app/oracle/admin/orcldg/bdump'

*.compatible='10.2.0.3.0'

*.control_files='/data/orcldg/controlfile/control01.ctl','/fra/orcldg/controlfile/control02.ctl'

*.core_dump_dest='/u01/app/oracle/admin/orcldg/cdump'

*.db_block_size=8192

*.db_domain=''

*.db_file_multiblock_read_count=16

*.db_files=2000

*.db_name='orcl'

*.dispatchers='(PROTOCOL=TCP) (SERVICE=orcldgXDB)'

*.fal_client='ORCLDG'

*.fal_server='ORCL'

*.job_queue_processes=10

*.log_archive_config='DG_CONFIG=(ORCL,ORCLDG)'

*.log_archive_dest_1='LOCATION=/fra/arch VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=ORCLDG'

*.log_archive_dest_2='SERVICE=ORCL LGWR ASYNC REOPEN NET_TIMEOUT=300 VALID_FOR=(ONLINE_LOGFILE,PRIMARY_ROLE) DB_UNIQUE_NAME=ORCL'

*.log_archive_dest_state_1='ENABLE'

*.log_archive_dest_state_2='ENABLE'

*.log_archive_format='%t_%s_%r.dbf'

*.max_dump_file_size='25m'

*.open_cursors=300

*.pga_aggregate_target=94371840

*.processes=1500

*.remote_login_passwordfile='EXCLUSIVE'

*.sessions=1655

*.sga_target=283115520

*.standby_archive_dest='/fra/arch'    #和log_archive_dest_1一致就可。

*.standby_file_management='AUTO'

*.undo_management='AUTO'

*.undo_tablespace='UNDOTBS1'

*.user_dump_dest='/u01/app/oracle/admin/orcldg/udump'



*.service_names='orcl'

*.db_unique_name='orcldg'

*.LOG_FILE_NAME_CONVERT='/data/orcl/','/data/orcldg/onlinelog/'

*.DB_FILE_NAME_CONVERT='/data/orcl/','/data/orcldg/datafile/'

11G:

*.audit_file_dest='/u01/app/oracle/admin/orcldg/adump'

*.audit_trail='NONE'

*.compatible='11.2.0.4.0'

*.control_files='/data/orcldg/controlfile/control01.ctl','/fra/orcldg/controlfile/control02.ctl'

*.db_block_size=8192

*.db_domain=''

*.db_files=2000

*.db_name='orcl'

*.deferred_segment_creation=FALSE

*.diagnostic_dest='/u01/app/oracle'

*.dispatchers='(PROTOCOL=TCP) (SERVICE=orcldgXDB)'

*.enable_ddl_logging=TRUE

*.event='28401 TRACE NAME CONTEXT FOREVER, LEVEL 1'

*.fal_server='ORCL'

*.log_archive_config='DG_CONFIG=(ORCL,ORCLDG)'

*.log_archive_dest_1='LOCATION=/fra/arch VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=ORCLDG'

*.log_archive_dest_2='SERVICE=ORCL LGWR ASYNC REOPEN NET_TIMEOUT=300 VALID_FOR=(ONLINE_LOGFILE,PRIMARY_ROLE) DB_UNIQUE_NAME=ORCL'

*.log_archive_dest_state_1='ENABLE'

*.log_archive_dest_state_2='ENABLE'

*.log_archive_format='%t_%s_%r.dbf'

*.max_dump_file_size='25m'

*.open_cursors=300

*.pga_aggregate_target=209715200

*.processes=1500

*.remote_login_passwordfile='EXCLUSIVE'

*.sessions=1655

*.sga_target=996147200

*.standby_file_management='AUTO'

*.undo_tablespace='UNDOTBS1'

*.REDO_TRANSPORT_USER = DGMIMA



*.service_names='orcl'

*.db_unique_name='orcldg'

*.LOG_FILE_NAME_CONVERT='/data/orcl/','/data/orcldg/onlinelog/'

*.DB_FILE_NAME_CONVERT='/data/orcl/','/data/orcldg/datafile/'

 **  
**

 **9、备端提前创建所需路径**

包含所有参数文件中涉及的文件路径

10G :

$ mkdir -p /u01/app/oracle/admin/orcldg/adump

$ mkdir -p /u01/app/oracle/admin/orcldg/bdump

$ mkdir -p /u01/app/oracle/admin/orcldg/cdump

$ mkdir -p /u01/app/oracle/admin/orcldg/udump

$ mkdir -p /data/orcldg/controlfile

$ mkdir -p /fra/orcldg/controlfile

$ mkdir -p /fra/arch

$ mkdir -p /data/orcldg/onlinelog

$ mkdir -p /data/orcldg/datafile

11G :

mkdir -p /u01/app/oracle/admin/orcldg/adump

mkdir -p /data/orcldg/controlfile

mkdir -p /fra/orcldg/controlfile

mkdir -p /fra/arch

mkdir -p /data/orcldg/onlinelog/

mkdir -p /fra/orcldg/onlinelog/

mkdir -p /data/orcldg/datafile/

 **  
**

 **10、备端复制主端数据库**

有两种方式：

一种是使用RMAN在主端做备份，将备份文件传递至备端restore；

另一种是使用RMAN DUPLICATE...FROM ACTIVE DATABASE，这是oracle
11G新特性，最大的优势是可以不必耗费大量的磁盘空间中转落地的RMAN备份文件，而是直接通过主端数据文件生成备端数据文件。

Step by Step Guide on Creating Physical Standby Using RMAN DUPLICATE...FROM
ACTIVE DATABASE (文档 ID 1075908.1)

 **  
**

 **10.1、RMAN备份还原复制主端数据库**

 **#** ** _注_** **_如果使用_** ** _RMAN DUPLICATE_** ** _方式，请跳过此章节。_**

 **10.1.1、备份primary**

RMAN备份主端数据库，如果数据量很大，备份时间很长，建议后台执行备份脚本。

run {

allocate channel c1 type disk;

allocate channel c2 type disk;

allocate channel c3 type disk;

backup incremental level 0 format '/home/oracle/rmanbak/orcl_full_%U'
database;

backup format '/home/oracle/rmanbak/orcl_full_stanctf_%U' current controlfile
for standby;

release channel c1;

release channel c2;

release channel c3;

}

 **  
**

 **10.1.2、主端传输文件至备端**

$ scp /home/oracle/rmanbak/orcl_full_*  备端的物理IP:/home/oracle/backup/

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

ftp> prompt off                      **#** ** _注 不用输入确认_**

ftp> mget orcl_full_*

 **10.1.3、备端启动数据库到nomount**

备端数据库先生成spfile后启动数据库到nomount状态

设置ORACLE_SID

$ export ORACLE_SID=orcldg



$ sqlplus / as sysdba

sql> create spfile from pfile='/home/oracle/pfile.ora';

sql> startup nomount;

 **  
**

 **10.1.4、测试sqlplus连通性，确保能正常连通**

主端和备端都要测试sqlplus连通性

$ sqlplus /nolog

主端测试

SQL> connect sys/oracle@orcldg AS SYSDBA

备端测试

SQL> connect sys/oracle@orcl AS SYSDBA

 **  
**

 **10.1.5、备端restore database**

restore控制文件

RMAN> restore standby controlfile from
'/home/oracle/backup/orcl_full_stanctf_0mr95t13_1_1';

备端将RMAN备份片加入到catalog中，rman备份的catalog使用控制文件。

RMAN> alter database mount;

RMAN> catalog start with '/home/oracle/backup/orcl_full_';

备端数据库restore数据文件

RMAN>  run {

allocate channel d1 type disk;

allocate channel d2 type disk;

allocate channel d3 type disk;

restore database;

release channel d1;

release channel d2;

release channel d3;

}

 **  
**

 **10.2、RMAN DUPLICATE复制主端数据库**

 **#** ** _注_** **_如果使用_** ** _RMAN_** ** _备份还原方式，请跳过此章节。_**

 **10.2.1、备端启动数据库到nomount**

备端数据库启动到nomount状态

设置ORACLE_SID

$ export ORACLE_SID=orcldg



$ sqlplus / as sysdba

sql> create spfile from pfile='/home/oracle/pfile.ora';

sql> startup nomount;

 **  
**

 **10.2.2、测试sqlplus连通性，确保能正常连通**

主端和备端都要测试sqlplus连通性

$ sqlplus /nolog

主端测试

SQL> connect sys/oracle@orcldg AS SYSDBA

备端测试

SQL> connect sys/oracle@orcl AS SYSDBA

 **  
**

 **10.2.3、备端执行RMAN DUPLICATE**

RMAN连接主、备数据库，开始RMAN DUPLICATE复制数据库：

$ **rman target sys/oracle@orcl auxiliary sys/oracle@orcldg nocatalog**



Recovery Manager: Release 11.2.0.4.0 - Production on Mon Jun 27 03:19:00 2016

Copyright (c) 1982, 2011, Oracle and/or its affiliates.  All rights reserved.

connected to target database: ORCL (DBID=1486522286)

using target database control file instead of recovery catalog

connected to auxiliary database: ORCL (not mounted)



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

 **  
**

 **11、主备端创建standby redologs**

如果第四步没有创建standby redologs或当前环境是10G的数据库，需要创建standby redologs。 **如果** 第四步
**创建过standby redologs，请忽略此步。**

对于11G此步骤可以在主端备份数据库之前创建standby redolog，在备端执行alter database
mount;后会在备端自动创建standby redolog。

SQL> col status format a10;

select thread#, GROUP#,SEQUENCE#,BYTES/1024/1024,STATUS,FIRST_TIME from v$log;



   THREAD#     GROUP#  SEQUENCE# BYTES/1024/1024 STATUS     FIRST_TIM

\---------- ---------- ---------- --------------- ---------- ---------

         1          1         13              50 CURRENT    06-JUL-16

         1          2         11              50 INACTIVE   04-JUL-16

         1          3         12              50 ACTIVE     06-JUL-16



SQL> Set linesize 200

col member format a50

select * from v$logfile;



    GROUP# STATUS     TYPE    MEMBER                                 IS_

\---------- ---------- ------- -------------------------------------- ---

         3            ONLINE  /data/orcl/redo03.log                  NO

         2            ONLINE  /data/orcl/redo02.log                  NO

         1            ONLINE  /data/orcl/redo01.log                  NO



主端创建standby redologs：

standby redo日志的大小必须 **至少与redo日志一样大** ； **对于每个线程（** **THREAD#** **）的standby
redo的数量必须至少比当前线程的redo日志多一个日志组。**

当前环境中包含1个节点，有3个日志组（GROUP#），每个日志的大小为50MB，每个日志组有1个成员。根据这种情况，为每个线程创建4个大小为50MB的日志组，每个日志组包含1个成员，位于/data/orcl目录下。



SQL> ALTER DATABASE ADD STANDBY LOGFILE THREAD 1

GROUP 4 ('/data/orcl/stdbyredo01.log') SIZE 50M,

GROUP 5 ('/data/orcl/stdbyredo02.log') SIZE 50M,

GROUP 6 ('/data/orcl/stdbyredo03.log') SIZE 50M,

GROUP 7 ('/data/orcl/stdbyredo04.log') SIZE 50M;



备端创建standby redologs：



SQL> ALTER DATABASE ADD STANDBY LOGFILE THREAD 1

GROUP 4 ('/data/orcldg/onlinelog/stdbyredo01.log') SIZE 50M,

GROUP 5 ('/data/orcldg/onlinelog/stdbyredo02.log') SIZE 50M,

GROUP 6 ('/data/orcldg/onlinelog/stdbyredo03.log') SIZE 50M,

GROUP 7 ('/data/orcldg/onlinelog/stdbyredo04.log') SIZE 50M;

 **  
**

 **12、备端同步主端的归档日志**

备端恢复数据文件完成后，开启介质恢复进程，将主库的归档日志恢复到备库。

 **备端** 启动恢复进程mrp0

SQL> alter database recover managed standby database using current logfile
disconnect from session;

 ** **

 **备端** 查询是否有mrp0进程

SQL> SELECT PROCESS,STATUS,THREAD#,SEQUENCE#,BLOCK#,BLOCKS,DELAY_MINS FROM
V$MANAGED_STANDBY;



切换 **主库** 归档，观察备库归档日志同步是否正常。

SQL> alter system archive log current;



关闭介质恢复的方法：

SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;

 **  
**

 **13、备端开启和关闭Active Data Guard**

 **此步骤仅限11G** ，active dataguard模式下，备机可提供只读的查询业务，不能写数据。

如果开启了第10步的介质恢复进程，需要先关闭介质恢复进程

SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;

启动

SQL> ALTER DATABASE OPEN READ ONLY;

SQL> RECOVER MANAGED STANDBY DATABASE DISCONNECT USING CURRENT LOGFILE;

 **  
**

 **14、查询同步情况**

此查询10G和11G都可以使用。

主端查询

SQL>   select max(sequence#),thread# from v$archived_log where
RESETLOGS_CHANGE# = (SELECT RESETLOGS_CHANGE# FROM V$DATABASE_INCARNATION
WHERE STATUS = 'CURRENT') GROUP BY THREAD#;



   THREAD# MAX(SEQUENCE#)

\---------- --------------

         1             10

         2              9



备端查询

SQL> select max(sequence#),thread# from v$archived_log where  applied='YES'
and RESETLOGS_CHANGE# = (SELECT RESETLOGS_CHANGE# FROM V$DATABASE_INCARNATION
WHERE STATUS = 'CURRENT') GROUP BY THREAD#;

        



   THREAD# MAX(SEQUENCE#)

\---------- --------------

         1              9

         2              9



主备以上结果对比，如果max(sequence#)相差较大，表示目前不同步或同步延时较大，如果相差1到2个是可以接受的。



查看备机恢复进程状态的方法：

SQL> SELECT PROCESS,STATUS,THREAD#,SEQUENCE#,BLOCK#,BLOCKS,DELAY_MINS FROM
V$MANAGED_STANDBY;

以下查询仅限11G Active Data Guard

SQL> set line 300

SQL> select name,value  from v$dataguard_stats;



NAME                             VALUE

\-------------------------------- --------------------------------------------

transport lag                    +00 00:00:00

apply lag                        +00 00:00:00

apply finish time                +00 00:00:00.000

estimated startup time           21

## 15、备库开启闪回功能

根据实际环境设置以下参数

设置闪回区大小，这是闪回区存放闪回日志时占用磁盘空间的最大限制，设置前确保磁盘空间充足( **请结合实际磁盘空间设置** )

SQL> alter system set db_recovery_file_dest_size=100g scope=spfile;

设置闪回区位置，用于存放闪回日志文件

SQL> alter system set db_recovery_file_dest='/flashback_area' scope=spfile;

设置闪回日志保留天数为5天，此参数以分钟为单位，每天为1440分钟 **(** **请结合实际情况设置保留天数** **)**

SQL> alter system set db_flashback_retention_target=7200 scope=spfile;

打开闪回功能

SQL> select flashback_on from V$database;



FLASHBACK_ON

\------------------

NO



SQL> RECOVER MANAGED STANDBY DATABASE CANCEL;

SQL> shutdown immediate;

SQL> startup mount;

SQL> alter database flashback on;

SQL> alter database open;

SQL> select flashback_on from v$database;



FLASHBACK_ON

\------------------

YES

开启同步

SQL> RECOVER MANAGED STANDBY DATABASE DISCONNECT USING CURRENT LOGFILE;



当使用闪回数据库闪回到过去的时间点时，请参考《oracle_误删除数据恢复操作手册》

 **  
**  

 **16、Switchover**

1. 检查主库和备库的参数设置

2. 确保主库设置了以下参数



SQL> alter system set DB_FILE_NAME_CONVERT =
'/data/orcldg/datafile/','/data/orcl/' sid=’*’ scope=spfile;



SQL> alter system set LOG_FILE_NAME_CONVERT =
'/data/orcldg/onlinelog/','/data/orcl/' sid=’*’ scope=spfile;

3. 确保主库创建了standby logfile联机redo日志文件

SQL> select * from v$standby_log;

4. 确保compatible主库和备库相同

5. 确保Managed Recovery运行在备库，且主备端同步正常

SQL> SELECT PROCESS FROM V$MANAGED_STANDBY WHERE PROCESS LIKE 'MRP%';



PROCESS

\---------

MRP0



主端；

SQL> select thread#,max(sequence#) from v$archived_log where RESETLOGS_CHANGE#
= (SELECT RESETLOGS_CHANGE# FROM V$DATABASE_INCARNATION WHERE STATUS =
'CURRENT') GROUP BY THREAD#;



备端；

SQL> select thread#,max(sequence#) from v$archived_log where  applied='YES'
and RESETLOGS_CHANGE# = (SELECT RESETLOGS_CHANGE# FROM V$DATABASE_INCARNATION
WHERE STATUS = 'CURRENT') GROUP BY THREAD#;



SQL> set line 200

SQL> select name,value  from v$dataguard_stats;



 ** _\--10G_** ** _需要检查_**

 **SELECT DELAY_MINS FROM V$MANAGED_STANDBY WHERE PROCESS = 'MRP0';**

 ** **

 **On the target physical standby database turn off delay if > 0**

 ** **

 **SQL > RECOVER MANAGED STANDBY DATABASE CANCEL**

 **SQL > ALTER DATABASE RECOVER MANAGED STANDBY DATABASE NODELAY USING CURRENT
LOGFILE DISCONNECT FROM SESSION;**



 ** _\--10G_** ** _需要检查_**

 **primary  ** **检查以前禁用重做线程**

 **SQL > SELECT THREAD# FROM V$THREAD WHERE SEQUENCE# > 0;**

 ** **

 **    THREAD#**

 **\----------**

 **          1**

 **          2**

 ** **

 **SQL > SELECT TO_CHAR(RESETLOGS_CHANGE#) FROM V$DATABASE_INCARNATION WHERE
STATUS = 'CURRENT';**

 ** **

 **TO_CHAR(RESETLOGS_CHANGE#)**

 **\----------------------------------------**

 **602821**

 ** **

 **SQL > SELECT 'CONDITION MET'**

 **  2   FROM SYS.DUAL**

 **  3   WHERE NOT EXISTS (SELECT 1**

 **  4   FROM V$ARCHIVED_LOG**

 **  5   WHERE THREAD# = 1**

 **  6   AND RESETLOGS_CHANGE# = 602821)**

 **  7   AND NOT EXISTS (SELECT 1**

 **  8   FROM V$LOG_HISTORY**

 **  9   WHERE THREAD# = 1**

 **  10  AND RESETLOGS_CHANGE# = 602821);**

 ** **

 **no rows selected**

 ** **

 **SQL > SELECT 'CONDITION MET'**

 **  2   FROM SYS.DUAL**

 **  3   WHERE NOT EXISTS (SELECT 1**

 **  4   FROM V$ARCHIVED_LOG**

 **  5   WHERE THREAD# = 2**

 **  6   AND RESETLOGS_CHANGE# = 602821)**

 **  7   AND NOT EXISTS (SELECT 1**

 **  8   FROM V$LOG_HISTORY**

 **  9   WHERE THREAD# = 2**

 **  10  AND RESETLOGS_CHANGE# = 602821);**

 ** **

 **no rows selected**



 ** _\--10G_** ** _需要检查_**

 **SQL > SELECT VALUE FROM V$DATAGUARD_STATS WHERE NAME='standby has been
open';**

 ** **

 **VALUE**

 **\----------------------------------------------------------------**

 **N**

 ** **

 **If the target physical standby was open read-only then restart the
standby**

 ** **

 **SQL > SHUTDOWN IMMEDIATE**

 ** **

 **SQL > STARTUP MOUNT**



6. 确保主库 LOG_ARCHIVE_DEST_2 的 recover状态是“REAL TIME APPLY” ，如果到传输到备库的日志目录是其他目录如 LOG_ARCHIVE_DEST_3，则检查LOG_ARCHIVE_DEST_3。

SQL> show parameter LOG_ARCHIVE_DEST_2



NAME                                 TYPE        VALUE

\------------------------------------ -----------
------------------------------

log_archive_dest_2                   string      SERVICE=ORCLDG LGWR ASYNC
REOP

                                                 EN NET_TIMEOUT=300 VALID_FOR=(

                                                 ONLINE_LOGFILE,PRIMARY_ROLE) D

                                                 B_UNIQUE_NAME=ORCLDG

10G：

 **主端查询：**

SQL> SELECT RECOVERY_MODE FROM V$ARCHIVE_DEST_STATUS WHERE DEST_ID=2;



RECOVERY_MODE

\-----------------------

MANAGED



11G 开启只读模式：

 **主端查询：**

SQL> SELECT RECOVERY_MODE FROM V$ARCHIVE_DEST_STATUS WHERE DEST_ID=2;



RECOVERY_MODE

\-----------------------

MANAGED REAL TIME APPLY

7. 检查LOG_ARCHIVE_MAX_PROCESSES，仅限11G

检查 **主端和备端** LOG_ARCHIVE_MAX_PROCESSES 参数设置为4或更高，注意不要设置过高，此参数可以通过 ALTER SYSTEM
动态修改。

SQL> show parameter LOG_ARCHIVE_MAX_PROCESSES



NAME                                 TYPE        VALUE

\------------------------------------ -----------
------------------------------

log_archive_max_processes            integer     4

8. 检查主库和备库的临时表空间和所有的数据文件是否为ONLINE状态

关于备库上的每个临时表空间，验证与主库上的表空间相关联的临时表空间也存在于备库上。

SQL> SELECT TMP.NAME FILENAME, BYTES, TS.NAME TABLESPACE

FROM V$TEMPFILE TMP, V$TABLESPACE TS WHERE TMP.TS#=TS.TS#;  



主端  

FILENAME                            BYTES TABLESPACE

\------------------------------ ---------- ------------------------------

/data/orcl/temp01.dbf            30408704 TEMP



备端

FILENAME                           BYTES TABLESPACE

\-------------------------------- ---------- ------------------------------

/data/orcldg/datafile/temp01.dbf   20971520 TEMP

如果查询不匹配，可以在打开新的主库后再纠正。



在备端查询数据文件状态

SQL> SELECT NAME FROM V$DATAFILE WHERE STATUS='OFFLINE';

如果有任何OFFLINE 数据文件，切换后将其ONLINE：

SQL> ALTER DATABASE DATAFILE 'datafile-name' ONLINE;

9. 清除可能受阻的参数与jobs

主端查看当前DBMS_JOB 的状态

SQL> SELECT * FROM DBA_JOBS_RUNNING;

主端查看当前DBMS_SCHEDULER的状态

SQL> select owner,job_name,session_id,slave_process_id,running_instance from
dba_scheduler_running_jobs;

如果有正在运行的job则不建议切换，最好等job运行完，或者停掉job（详细参考oracle Job操作手册）。

SQL> SHOW PARAMETER job_queue_processes

禁止所有job再自动执行

SQL> ALTER SYSTEM SET job_queue_processes=0 SCOPE=BOTH SID='*';

10. 打开Data Guard 主库和备库的日志跟踪

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

10G：

SQL> SHOW PARAMETER background_dump_dest



NAME                             TYPE        VALUE

\-------------------------------- ----------- ------------------------------

background_dump_dest             string      /u01/app/oracle/admin/orcl/bdump



11G

SQL> SHOW PARAMETER background_dump_dest



NAME                     TYPE        VALUE

\------------------------ -----------
-----------------------------------------

background_dump_dest     string
/u01/app/oracle/diag/rdbms/orcl/orcl/trace



[root@dgzhu trace]# tail -f alert_orcl.log

11. 创建可靠还原点（可选）如果switch切换后有问题可以通过还原点回退数据库。

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

12. 确保主库可以切换为备库

主端：

SQL> SELECT SWITCHOVER_STATUS FROM V$DATABASE;

SWITCHOVER_STATUS

\--------------------

TO STANDBY

如果主端有回话连接，则查询结果是

SESSIONS ACTIVE

13. 切换主库为 standby database

 **如果主端是RAC，则先shutdown immediate的形式关闭其他所有的实例，只保留一个。**

如果查询结果是SESSIONS ACTIVE：

SQL> ALTER DATABASE COMMIT TO SWITCHOVER TO PHYSICAL STANDBY WITH SESSION
SHUTDOWN;



如果查询结果是TO STANDBY

SQL> ALTER DATABASE COMMIT TO SWITCHOVER TO PHYSICAL STANDBY;



如果切换失败可参阅

http://docs.oracle.com/cd/E11882_01/server.112/e41134/troubleshooting.htm#SBYDB01410

如果切换过程遇到ora-16139 ，且主端的v$database  database_role是 physical standby
，则可以先忽略，当切换玩启动恢复进程后，会自动recover。



14. 验证备库可否切换为主库

SQL> SELECT SWITCHOVER_STATUS FROM V$DATABASE;

SWITCHOVER_STATUS

\-----------------

TO PRIMARY

15. 切换 standby database 为主库

第一种情况

如果查询结果是SESSIONS ACTIVE： 执行下面的：

SQL> ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY WITH SESSION SHUTDOWN;



如果查询结果是TO PRIMARY

SQL> ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY;

16\. open新的主库

SQL> ALTER DATABASE OPEN;

17. 如果有不匹配的临时表空间，更正不匹配的临时表空间

18. 重新启动新的备库

SQL> SHUTDOWN ABORT;

SQL> STARTUP MOUNT;

SQL> ALTER DATABASE OPEN READ ONLY;

SQL> RECOVER MANAGED STANDBY DATABASE DISCONNECT USING CURRENT LOGFILE;

19. 收尾

SQL> ALTER SYSTEM SET log_archive_trace=0;

SQL> ALTER SYSTEM SET job_queue_processes=<value saved> scope=both sid=’*’

SQL> EXECUTE DBMS_SCHEDULER.ENABLE(<for each job name captured>);

SQL> DROP RESTORE POINT SWITCHOVER_START_GRP;

 **另外要调整主备端自动删除归档的脚本和计划任务** **。**

参考文档：

 **11.2 Data Guard Physical Standby Switchover Best Practices using SQL*Plus
(** **文档 ID 1304939.1)**

 **10.2 Data Guard Physical Standby Switchover (** **文档** **ID751600.1)**

 **  
**

 **17、failover**

如果主库可以mount，则在mount状态下执行以下步骤，如果不能mount则跳过这一步

SQL> alter system flush redo to '<target_db_name>';  

 ** _注：target_db_name=备端的DB_UNIQUE_NAME_**

flush redo是在11gR2被引入的. 对于Data guard, 在故障切换时flush
redo可能是非常有用的，如果这个命令能成功将最后的redo应用到standby上，那么DG上将没有数据丢失。

如果需要执行此语句，在standby上的 redo apply必须是启动的，执行此命令的primary database必须是mouted
状态，不能open ,默认情况下 comfirm apply是这个语句的一部分，语句执行将会一直等待直到所有redo applied。



10G

主端和备端找出相差的归档日志，将主端未传输的归档日志传递至备端。

在备端手动注册缺失的归档日志：

alter database register physical logfile '/fra/arch/1_42_916276568.dbf';

alter database register physical logfile '/fra/arch/1_43_916276568.dbf';

alter database register physical logfile '/fra/arch/1_44_916276568.dbf';



备端执行以下语句停止redo应用服务

SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;



备端执行以下语句发起故障转移操作：

SQL> alter database recover managed standby database finish force;



备端执行以下语句将备库转换为主库

SQL> ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY;



备端执行以下语句打开转换后的主库：

SQL> alter database open;



确认：

SQL> select database_role from v$database;



DATABASE_ROLE

\----------------

PRIMARY

 **  
**

 **18、参数解释**

alter system set LOG_ARCHIVE_CONFIG='DG_CONFIG=(WENDING,PHYSTDBY)' ;

启动db接受或发送redo data，包括所有库的db_unique_name



alter system set LOG_ARCHIVE_DEST_1='LOCATION=/orahome/arch1/WENDING
VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=WENDING' ;

主库归档目的地



alter system set LOG_ARCHIVE_DEST_2='SERVICE=db_phystdby LGWR ASYNC
VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=PHYSTDBY' ;

当该库充当主库角色时，设置物理备库redo data的传输目的地



alter system set LOG_ARCHIVE_MAX_PROCESSES=5 scope=spfile;

最大ARCn进程数



alter system set LOG_ARCHIVE_DEST_STATE_1=ENABLE scope=spfile;

允许redo传输服务传输数据到目的地，默认是enable



alter system set LOG_ARCHIVE_DEST_STATE_2=ENABLE scope=spfile;

允许redo传输服务传输数据到目的地，默认是enable



alter system set REMOTE_LOGIN_PASSWORDFILE=EXCLUSIVE scope=spfile;

exclusive or shared，所有库sys密码要一致，默认是exclusive



以下是主库切换为备库，充当备库角色时的一些参数设置，如果不打算做数据库切换就不用设置了

alter system set FAL_SERVER=db_phystdby scope=spfile;

配置网络服务名，假如转换为备库角色时，从这里获取丢失的归档文件



alter system set FAL_CLIENT=db_wending scope=spfile;

配置网络服务名，fal_server拷贝丢失的归档文件到这里



alter system set DB_FILE_NAME_CONVERT='PHYSTDBY','WENDING' scope=spfile;

前为切换后的主库路径，后为切换后的备库路径，如果主备库目录结构完全一样，则无需设定



alter system set LOG_FILE_NAME_CONVERT='PHYSTDBY','WENDING' scope=spfile;

同上，这两个名字转换参数是主备库的路径映射关系，可能会是路径全名，看情况而定



alter system set STANDBY_FILE_MANAGEMENT=auto scope=spfile;

auto后当主库的datafiles增删时备库也同样自动操作，且会把日志传送到备库standby_archive_dest参数指定的目录下，确保该目录存在，如果你的存储采用文件系统没有问题，但是如果采用了裸设备，你就必须将该参数设置为manual



alter system set STANDBY_ARCHIVE_DEST='LOCATION=/orahome/arch1/WENDING'
scope=spfile;

一般和LOG_ARCHIVE_DEST_1的位置一样，如果备库采用ARCH传输方式，那么主库会把归档日志传到该目录下，这个参数在11g的时候已经废弃

  

相关文档

内部备注

指导安装11gR2 Data Guard 单机对单机

附件

验证码：

  换一张

输入验证码：

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAYAAAA7MK6iAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEgAACxIB0t1+/AAAABZ0RVh0Q3JlYXRpb24gVGltZQAwOS8yNy8xN+stbYgAAAAcdEVYdFNvZnR3YXJlAEFkb2JlIEZpcmV3b3JrcyBDUzbovLKMAAABm0lEQVRIicXXwXGCQBTG8b+7uZsSTAXRCiQVhA6SXLgmJZgO5BguSQnYgR0EK0hKiAUs5rBvGVlBBEG/GWccxf0JC2/fjna7HU3JEz0BQnlNgbF3yBbIgBRIVWR+m8YcHYPzRE+BBfDY+O/KWQELFZmsNZwnegm8tgT9xCoybyfBeaJvgTVwfybqsgECFZm//Q/VwCgy1lrGroYHQEt4JSxzOgRa4GIAMsdy934PiO5npiKTuTNeXAgtrJH5UBPg54IwwJ3CVqO+swEegPea78MhYPfcroFlzTGhwtbevlFXLOrgqeKw4PeC5on+Ap5qjh37BcTPFjtXL/K+DxSAmwY4k7kiT3SGrT7+FWqNwmHJ9DPPE/0MIEtcQPnMO6EOPnYJAT5r8M4osFXYzqEpVXhXFCBT2HbllJTwM1CAtA1cws9AAVK3OqW066tibOGZd0BXKjLhdZdFuWHiC6Cx6zxLzZ4UiaG6kI2KTLEu+AUkwD6fvaMydpESLI9I33hle3u1hr62VssPZtjtSNussHdvJQoNeyeXITZt/1po2U5WDlb1AAAAAElFTkSuQmCC)![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAYAAAA7MK6iAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEgAACxIB0t1+/AAAABZ0RVh0Q3JlYXRpb24gVGltZQAwOS8yNy8xN+stbYgAAAAcdEVYdFNvZnR3YXJlAEFkb2JlIEZpcmV3b3JrcyBDUzbovLKMAAABu0lEQVRIicWX223CQBBFD26AlOAOMJoCQgl0AFQQSoEOoAN3EPLPKHYHKSFUQD686/jFPkysXMkSQsMc1jt7Z3Z2v9/xSVVTYG2eDJh3Qm5AAeRALiJfvpwzF1hVM2APbLz/rq0zcBCRIhqsqgfgLRLY1VFE9kFgVX0BLsDiSahVCaxE5Lv5ZTIxFJPrYnIPgyeAtuCDYLOnU0BruGEAZo9N9X5OCG1qKSKFXfFg5TVURiT2xe4BEmMOrnNaikgG7AKgOxPrgm9UNU2o3MilhapmInLywHcicjLblnpyrkPAUB0HF7wJvdC31EFwFgCeO+CxUIBsdr1e/V3iVzcqFypUdQswAgpALLgFh7qRREGh71yhSjufo6BjwHa1uapmZs9zwo5aD3yLhBaN1+ur9oe5EqrJYQx0jrvaXSoSqnHFJwtd0S+kMfA8BFw2js87w4XUhX/4wLY7nfD4NWEt0w59r46Ys4hsbVUfHIEEQqFauQtasxIAYwbHwOTP6GiNpzXsqWrBdFOIba9A30BWxDX9YKjJXasFNiPoX8MHx9t/G+gferX5wZLqOhKrM9VQ93CWc96drKa4tP0As8vvCUvsIrEAAAAASUVORK5CYII=)

sentinel

SQL&gt; select name,log_mode,force_logging from gv$database;

&nbsp;

NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; LOG_MODE&nbsp;&nbsp;&nbsp;&nbsp; FOR

\--------- ------------ ---

ORCL&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ARCHIVELOG&nbsp;&nbsp; NO

&nbsp;

SQL&gt; **alter database force logging;**

Database altered.

&nbsp;

SQL&gt; select name,log_mode,force_logging from gv$database;

&nbsp;

NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; LOG_MODE&nbsp;&nbsp;&nbsp;&nbsp; FOR

\--------- ------------ ---

ORCL&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ARCHIVELOG&nbsp;&nbsp; YES

 **  
**

 **2** **、 主端设置归档模式**  

查看是否为归档模式：

SQL&gt; archive log list;

Database log mode &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Archive Mode

Automatic archival&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp; Enabled

Archive destination&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp; /fra

Oldest online log sequence&nbsp;&nbsp;&nbsp;&nbsp; 4

Next log sequence to archive&nbsp;&nbsp; 5

Current log sequence&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp; &nbsp;&nbsp;&nbsp;5

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
LOCATION=/fra

若Database log mode 显示为No Archive Mode即为非归档模式，以下开启归档模式

先设置归档路径

SQL&gt; alter system set log_archive_dest_1=&#39;location=/fra/arch/&#39;;

注：创建存放归档的目录 **并修改目录权限** ，如规划归档存放路径是/fra/arch则

mkdir /fra/arch

chown oracle:oinstall /fra/arch

&nbsp;

重启实例到mount状态

SQL&gt; shutdown immediate

SQL&gt; startup mount;

开始归档模式

SQL&gt; alter database archivelog;

SQL&gt; alter database open;

##

 **3、主端配置参数**

查看主端的db_unique_name

sqlplus / as sysdba

sql&gt;show parameter db_unique_name

&nbsp;

SQL&gt; ALTER SYSTEM SET LOG_ARCHIVE_CONFIG=&#39;DG_CONFIG=(ORCL,ORCLDG)&#39;
SID=&#39;*&#39;;

 **#** ** _注 红色取值为主库和备库的 DB_UNIQUE_NAME_**

 ** _备端db_unique_name 可以自定义，只要和备机启动时的参数一致就可以。_**

&nbsp;

SQL&gt; ALTER SYSTEM SET LOG_ARCHIVE_DEST_1=&#39;LOCATION=/fra
VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=ORCL&#39; SID=&#39;*&#39;;

&nbsp;

SQL&gt; ALTER SYSTEM SET LOG_ARCHIVE_DEST_2=&#39;SERVICE=ORCLDG LGWR ASYNC
REOPEN NET_TIMEOUT=300 VALID_FOR=(ONLINE_LOGFILE,PRIMARY_ROLE)
DB_UNIQUE_NAME=ORCLDG&#39; SID=&#39;*&#39;;

 **#** ** _注 红色取值为主库tnsnames.ora文件中备库的Net service name_**

&nbsp;

SQL&gt; alter system set LOG_ARCHIVE_DEST_STATE_1=ENABLE;

&nbsp;

SQL&gt; alter system set LOG_ARCHIVE_DEST_STATE_2=ENABLE;

&nbsp;

SQL&gt; ALTER SYSTEM SET STANDBY_FILE_MANAGEMENT =AUTO SID=&#39;*&#39;;

&nbsp;

SQL&gt; ALTER SYSTEM SET STANDBY_ARCHIVE_DEST=&#39;/fra&#39;;&nbsp;&nbsp;
**#** ** _注 11G此参数已废弃_**

&nbsp;

SQL&gt; ALTER SYSTEM SET FAL_CLIENT=&#39;ORCL&#39;
SID=&#39;*&#39;;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; **#** ** _注
11G此参数已废弃_**

 **#** ** _注 红色取值为主库tnsnames.ora文件中主库的Net service name_**

&nbsp;

SQL&gt; ALTER SYSTEM SET FAL_SERVER=&#39;ORCLDG&#39; SID=&#39;*&#39;;

 **#** ** _注 红色取值为主库tnsnames.ora文件中备库的Net service name_**

 **FAL_SERVER And FAL_CLIENT Settings For Cascaded Standby (** **文档 ID
358767.1)**

 **& nbsp;**

以下参数修改需要重启数据库，但是当数据库作为Dataguard的主端时，是不起作用的。只有当当前数据库的角色为Data
guard的备机时，DB_FILE_NAME_CONVERT和LOG_FILE_NAME_CONVERT才会发挥作用。

SQL&gt; alter system set DB_FILE_NAME_CONVERT =
&#39;/data/orcldg/datafile/&#39;,&#39;/data/orcl/&#39; scope=spfile;

&nbsp;

SQL&gt; alter system set LOG_FILE_NAME_CONVERT =
&#39;/data/orcldg/onlinelog/&#39;,&#39;/data/orcl/&#39;&nbsp; scope=spfile;

&nbsp;

DB_FILE_NAME_CONVERT参数的作用是转换主库和备库的数据文件路径。

LOG_FILE_NAME_CONVERT参数的作用是转换主库和备库的redo日志文件的路径。

以上两个参数的书写格式是，两两路径为一组，对方的路径在前，自己的路径在后。

 **  
**

 **4、主端创建standby redologs，仅限11G**

对于11G此步骤可以在主端备份数据库之前创建standby redolog，在备端执行alter database
mount;后会在备端自动创建standby redolog。

SQL&gt; col status format a10;

select thread#, GROUP#,SEQUENCE#,BYTES/1024/1024,STATUS,FIRST_TIME from v$log;

&nbsp;

&nbsp;&nbsp; THREAD#&nbsp;&nbsp;&nbsp;&nbsp; GROUP#&nbsp; SEQUENCE#
BYTES/1024/1024 STATUS&nbsp;&nbsp;&nbsp;&nbsp; FIRST_TIM

\---------- ---------- ---------- --------------- ---------- ---------

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
13&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
50 CURRENT&nbsp;&nbsp;&nbsp; 06-JUL-16

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
11&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
50 INACTIVE&nbsp;&nbsp; 04-JUL-16

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
3&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
12&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
50 ACTIVE&nbsp;&nbsp;&nbsp;&nbsp; 06-JUL-16

&nbsp;

SQL&gt; Set linesize 200

col member format a50

select * from v$logfile;

&nbsp;

&nbsp;&nbsp;&nbsp; GROUP# STATUS&nbsp;&nbsp;&nbsp;&nbsp;
TYPE&nbsp;&nbsp;&nbsp;
MEMBER&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
IS_

\---------- ---------- ------- -------------------------------------- ---

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
3&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp;
/data/orcl/redo03.log&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
NO

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp;
/data/orcl/redo02.log&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
NO

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; /data/orcl/redo01.log&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;NO

&nbsp;

主端创建standby redologs：

standby redo日志的大小必须 **至少与redo日志一样大** ； **对于每个线程（** **THREAD#** **）的standby
redo的数量必须至少比当前线程的redo日志多一个日志组。**

当前环境中包含1个节点，有3个日志组（GROUP#），每个日志的大小为50MB，每个日志组有1个成员。根据这种情况，为每个线程创建4个大小为50MB的日志组，每个日志组包含1个成员，位于/data/orcl目录下。

&nbsp;

SQL&gt; ALTER DATABASE ADD STANDBY LOGFILE THREAD 1

GROUP 4 (&#39;/data/orcl/stdbyredo01.log&#39;) SIZE 50M,

GROUP 5 (&#39;/data/orcl/stdbyredo02.log&#39;) SIZE 50M,

GROUP 6 (&#39;/data/orcl/stdbyredo03.log&#39;) SIZE 50M,

GROUP 7 (&#39;/data/orcl/stdbyredo04.log&#39;) SIZE 50M;

 **  
**

 **5、监听配置**

 **5.1、备端配置静态监听服务名**

 **此步骤仅限11G使用RMAN DUPLICATE时配置静态监听服务名。**

&nbsp;

在备端以oracle用户向$ORACLE_HOME/network/admin/listener.ora文件中添加以下条目，完成静态注册监听：

SID_LIST_LISTENER =

&nbsp; (SID_LIST =

&nbsp;&nbsp;&nbsp; (SID_DESC =

&nbsp;&nbsp;&nbsp;&nbsp; (GLOBAL_DBNAME = orcldg)

&nbsp;&nbsp;&nbsp;&nbsp; (ORACLE_HOME = /u01/app/oracle/product/11.2.0/db_1)

&nbsp;&nbsp;&nbsp;&nbsp; (SID_NAME = orcldg)

&nbsp;&nbsp;&nbsp; )

&nbsp;&nbsp; )

&nbsp;

LISTENER =

&nbsp; (DESCRIPTION =

&nbsp;&nbsp;&nbsp; (ADDRESS = (PROTOCOL = TCP)(HOST =备端的物理IP)(PORT = 1521))

&nbsp; )

SID_NAME：数据库实例名，其值需和数据库参数INSTANCE_NAME保持一致，不可省略。

GLOBAL_DBNAME：数据库服务名，可以省略，默认和SID_NAME保持一致。

ORACLE_HOME：实例运行的ORACLE_HOME目录。在UNIX和Linux环境下，该参数可以省略，默认和环境变量$ORACLE_HOME保持一致。在WINDOWS环境中，该参数无效，ORACLE_HOME的值取自注册表HKEY_LOCAL_MACHINE\SOFTWARE\ORACLE\HOMEID

 **& nbsp;**

 **配置完成后重启监听器。**

 **  
**

 **5.2、主备端tnsnames.ora文件配置**

配置$ORACLE_HOME/network/admin/tnsnames.ora文件

 **主端和备端** **tnsnames.ora** **文件都** **添加主备端** **IP** **配置** **条目** **。**

&nbsp;

$ cat tnsnames.ora

&nbsp;

ORCLDG =

&nbsp; (DESCRIPTION =

&nbsp;&nbsp;&nbsp; (ADDRESS_LIST =

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (ADDRESS = (PROTOCOL = TCP)(HOST =
备端的物理IP)(PORT = 1521))

&nbsp;&nbsp;&nbsp; )

&nbsp;&nbsp;&nbsp; (CONNECT_DATA =

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (SERVICE_NAME = orcl) (UR=A)

&nbsp;&nbsp;&nbsp; )

&nbsp; )

# (UR=A)作用当备端数据库nomount,mount或者restricted时，动态监听显示状态为BLOCKED时，主端可通过配置UR=A进行连接。

&nbsp;

ORCL =

&nbsp; (DESCRIPTION =

&nbsp;&nbsp;&nbsp; (ADDRESS_LIST =

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (ADDRESS = (PROTOCOL = TCP)(HOST =
主端的物理IP)(PORT = 1521))

&nbsp;&nbsp;&nbsp; )

&nbsp;&nbsp;&nbsp; (CONNECT_DATA =

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (SERVICE_NAME = orcl)

&nbsp;&nbsp;&nbsp; )

&nbsp; )

备机启动监听

$ lsnrctl start

 **& nbsp;**

主端和备端测试监听配置：

$ tnsping ORCL

$ tnsping ORCLDG

 **  
**

 **6、主端传输密码文件至备端**

$ scp $ORACLE_HOME/dbs/orapworcl&nbsp; 备端的物理IP:$ORACLE_HOME/dbs/orapworcldg

密码文件命名格式是orapw+SID

 **  
**

 **7、主端创建密码验证用户，仅限11G**

SQL&gt; create user dgmima identified by 密码;

注意密码要提高复杂度。

&nbsp;

SQL&gt; GRANT SYSOPER to dgmima;

&nbsp;

SQL&gt;&nbsp; select * from V$PWFILE_USERS;

&nbsp;

USERNAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
SYSDB SYSOP SYSAS

\------------------------------ ----- ----- -----

SYS&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
TRUE&nbsp; TRUE&nbsp; FALSE

DGMIMA&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
FALSE TRUE&nbsp; FALSE

&nbsp;

SQL&gt; ALTER SYSTEM SET REDO_TRANSPORT_USER = DGMIMA SID=&#39;*&#39;;

&nbsp;

 ** _\--_** **_How to make log shipping to continue work without copying
password file from primary to physical standby when changing sys password on
primary? (_** ** _文档_** **_ID 1416595.1)_**

 **  
**

 **8、备端修改主端生成的pfile参数文件**

主端备份传输pfile参数文件：

SQL&gt; create pfile=&#39;/home/oracle/pfile.ora&#39; from spfile;

$ scp /home/oracle/pfile.ora 备端的物理IP:/home/oracle/

在备端修改上以步传输的参数文件：

 **#** ** _注 本节标红的内容为需要修改的_**

10G：

*.audit_file_dest=&#39;/u01/app/oracle/admin/orcldg/adump&#39;

*.background_dump_dest=&#39;/u01/app/oracle/admin/orcldg/bdump&#39;

*.compatible=&#39;10.2.0.3.0&#39;

*.control_files=&#39;/data/orcldg/controlfile/control01.ctl&#39;,&#39;/fra/orcldg/controlfile/control02.ctl&#39;

*.core_dump_dest=&#39;/u01/app/oracle/admin/orcldg/cdump&#39;

*.db_block_size=8192

*.db_domain=&#39;&#39;

*.db_file_multiblock_read_count=16

*.db_files=2000

*.db_name=&#39;orcl&#39;

*.dispatchers=&#39;(PROTOCOL=TCP) (SERVICE=orcldgXDB)&#39;

*.fal_client=&#39;ORCLDG&#39;

*.fal_server=&#39;ORCL&#39;

*.job_queue_processes=10

*.log_archive_config=&#39;DG_CONFIG=(ORCL,ORCLDG)&#39;

*.log_archive_dest_1=&#39;LOCATION=/fra/arch VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=ORCLDG&#39;

*.log_archive_dest_2=&#39;SERVICE=ORCL LGWR ASYNC REOPEN NET_TIMEOUT=300 VALID_FOR=(ONLINE_LOGFILE,PRIMARY_ROLE) DB_UNIQUE_NAME=ORCL&#39;

*.log_archive_dest_state_1=&#39;ENABLE&#39;

*.log_archive_dest_state_2=&#39;ENABLE&#39;

*.log_archive_format=&#39;%t_%s_%r.dbf&#39;

*.max_dump_file_size=&#39;25m&#39;

*.open_cursors=300

*.pga_aggregate_target=94371840

*.processes=1500

*.remote_login_passwordfile=&#39;EXCLUSIVE&#39;

*.sessions=1655

*.sga_target=283115520

*.standby_archive_dest=&#39;/fra/arch&#39;&nbsp;&nbsp;&nbsp; #和log_archive_dest_1一致就可。

*.standby_file_management=&#39;AUTO&#39;

*.undo_management=&#39;AUTO&#39;

*.undo_tablespace=&#39;UNDOTBS1&#39;

*.user_dump_dest=&#39;/u01/app/oracle/admin/orcldg/udump&#39;

&nbsp;

*.service_names=&#39;orcl&#39;

*.db_unique_name=&#39;orcldg&#39;

*.LOG_FILE_NAME_CONVERT=&#39;/data/orcl/&#39;,&#39;/data/orcldg/onlinelog/&#39;

*.DB_FILE_NAME_CONVERT=&#39;/data/orcl/&#39;,&#39;/data/orcldg/datafile/&#39;

11G:

*.audit_file_dest=&#39;/u01/app/oracle/admin/orcldg/adump&#39;

*.audit_trail=&#39;NONE&#39;

*.compatible=&#39;11.2.0.4.0&#39;

*.control_files=&#39;/data/orcldg/controlfile/control01.ctl&#39;,&#39;/fra/orcldg/controlfile/control02.ctl&#39;

*.db_block_size=8192

*.db_domain=&#39;&#39;

*.db_files=2000

*.db_name=&#39;orcl&#39;

*.deferred_segment_creation=FALSE

*.diagnostic_dest=&#39;/u01/app/oracle&#39;

*.dispatchers=&#39;(PROTOCOL=TCP) (SERVICE=orcldgXDB)&#39;

*.enable_ddl_logging=TRUE

*.event=&#39;28401 TRACE NAME CONTEXT FOREVER, LEVEL 1&#39;

*.fal_server=&#39;ORCL&#39;

*.log_archive_config=&#39;DG_CONFIG=(ORCL,ORCLDG)&#39;

*.log_archive_dest_1=&#39;LOCATION=/fra/arch VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=ORCLDG&#39;

*.log_archive_dest_2=&#39;SERVICE=ORCL LGWR ASYNC REOPEN NET_TIMEOUT=300 VALID_FOR=(ONLINE_LOGFILE,PRIMARY_ROLE) DB_UNIQUE_NAME=ORCL&#39;

*.log_archive_dest_state_1=&#39;ENABLE&#39;

*.log_archive_dest_state_2=&#39;ENABLE&#39;

*.log_archive_format=&#39;%t_%s_%r.dbf&#39;

*.max_dump_file_size=&#39;25m&#39;

*.open_cursors=300

*.pga_aggregate_target=209715200

*.processes=1500

*.remote_login_passwordfile=&#39;EXCLUSIVE&#39;

*.sessions=1655

*.sga_target=996147200

*.standby_file_management=&#39;AUTO&#39;

*.undo_tablespace=&#39;UNDOTBS1&#39;

*.REDO_TRANSPORT_USER = DGMIMA

&nbsp;

*.service_names=&#39;orcl&#39;

*.db_unique_name=&#39;orcldg&#39;

*.LOG_FILE_NAME_CONVERT=&#39;/data/orcl/&#39;,&#39;/data/orcldg/onlinelog/&#39;

*.DB_FILE_NAME_CONVERT=&#39;/data/orcl/&#39;,&#39;/data/orcldg/datafile/&#39;

 **  
**

 **9、备端提前创建所需路径**

包含所有参数文件中涉及的文件路径

10G :

$ mkdir -p /u01/app/oracle/admin/orcldg/adump

$ mkdir -p /u01/app/oracle/admin/orcldg/bdump

$ mkdir -p /u01/app/oracle/admin/orcldg/cdump

$ mkdir -p /u01/app/oracle/admin/orcldg/udump

$ mkdir -p /data/orcldg/controlfile

$ mkdir -p /fra/orcldg/controlfile

$ mkdir -p /fra/arch

$ mkdir -p /data/orcldg/onlinelog

$ mkdir -p /data/orcldg/datafile

11G :

mkdir -p /u01/app/oracle/admin/orcldg/adump

mkdir -p /data/orcldg/controlfile

mkdir -p /fra/orcldg/controlfile

mkdir -p /fra/arch

mkdir -p /data/orcldg/onlinelog/

mkdir -p /fra/orcldg/onlinelog/

mkdir -p /data/orcldg/datafile/

 **  
**

 **10、备端复制主端数据库**

有两种方式：

一种是使用RMAN在主端做备份，将备份文件传递至备端restore；

另一种是使用RMAN DUPLICATE...FROM ACTIVE DATABASE，这是oracle
11G新特性，最大的优势是可以不必耗费大量的磁盘空间中转落地的RMAN备份文件，而是直接通过主端数据文件生成备端数据文件。

Step by Step Guide on Creating Physical Standby Using RMAN DUPLICATE...FROM
ACTIVE DATABASE (文档 ID 1075908.1)

 **  
**

 **10.1、RMAN备份还原复制主端数据库**

 **#** ** _注_** **_如果使用_** ** _RMAN DUPLICATE_** ** _方式，请跳过此章节。_**

 **10.1.1、备份primary**

RMAN备份主端数据库，如果数据量很大，备份时间很长，建议后台执行备份脚本。

run {

allocate channel c1 type disk;

allocate channel c2 type disk;

allocate channel c3 type disk;

backup incremental level 0 format &#39;/home/oracle/rmanbak/orcl_full_%U&#39;
database;

backup format &#39;/home/oracle/rmanbak/orcl_full_stanctf_%U&#39; current
controlfile for standby;

release channel c1;

release channel c2;

release channel c3;

}

 **  
**

 **10.1.2、主端传输文件至备端**

$ scp /home/oracle/rmanbak/orcl_full_*&nbsp; 备端的物理IP:/home/oracle/backup/

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
**#** ** _注 不用输入确认_**

ftp&gt; mget orcl_full_*

 **10.1.3、备端启动数据库到nomount**

备端数据库先生成spfile后启动数据库到nomount状态

设置ORACLE_SID

$ export ORACLE_SID=orcldg

&nbsp;

$ sqlplus / as sysdba

sql&gt; create spfile from pfile=&#39;/home/oracle/pfile.ora&#39;;

sql&gt; startup nomount;

 **  
**

 **10.1.4、测试sqlplus连通性，确保能正常连通**

主端和备端都要测试sqlplus连通性

$ sqlplus /nolog

主端测试

SQL&gt; connect sys/oracle@orcldg AS SYSDBA

备端测试

SQL&gt; connect sys/oracle@orcl AS SYSDBA

 **  
**

 **10.1.5、备端restore database**

restore控制文件

RMAN&gt; restore standby controlfile from
&#39;/home/oracle/backup/orcl_full_stanctf_0mr95t13_1_1&#39;;

备端将RMAN备份片加入到catalog中，rman备份的catalog使用控制文件。

RMAN&gt; alter database mount;

RMAN&gt; catalog start with &#39;/home/oracle/backup/orcl_full_&#39;;

备端数据库restore数据文件

RMAN&gt;&nbsp; run {

allocate channel d1 type disk;

allocate channel d2 type disk;

allocate channel d3 type disk;

restore database;

release channel d1;

release channel d2;

release channel d3;

}

 **  
**

 **10.2、RMAN DUPLICATE复制主端数据库**

 **#** ** _注_** **_如果使用_** ** _RMAN_** ** _备份还原方式，请跳过此章节。_**

 **10.2.1、备端启动数据库到nomount**

备端数据库启动到nomount状态

设置ORACLE_SID

$ export ORACLE_SID=orcldg

&nbsp;

$ sqlplus / as sysdba

sql&gt; create spfile from pfile=&#39;/home/oracle/pfile.ora&#39;;

sql&gt; startup nomount;

 **  
**

 **10.2.2、测试sqlplus连通性，确保能正常连通**

主端和备端都要测试sqlplus连通性

$ sqlplus /nolog

主端测试

SQL&gt; connect sys/oracle@orcldg AS SYSDBA

备端测试

SQL&gt; connect sys/oracle@orcl AS SYSDBA

 **  
**

 **10.2.3、备端执行RMAN DUPLICATE**

RMAN连接主、备数据库，开始RMAN DUPLICATE复制数据库：

$ **rman target sys/oracle@orcl auxiliary sys/oracle@orcldg nocatalog**

&nbsp;

Recovery Manager: Release 11.2.0.4.0 - Production on Mon Jun 27 03:19:00 2016

Copyright (c) 1982, 2011, Oracle and/or its affiliates.&nbsp; All rights
reserved.

connected to target database: ORCL (DBID=1486522286)

using target database control file instead of recovery catalog

connected to auxiliary database: ORCL (not mounted)

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

 **  
**

 **11、主备端创建standby redologs**

如果[第四步](https://47.100.29.40/highgo_admin/%22file:///C:/Users/zylong/Desktop/1/Oracle-
安装手册-
Data%20Gaurd单机对单机v1.0.docx#_4�����˴���standby_redologs������11G")没有创建standby
redologs或当前环境是10G的数据库，需要创建standby redologs。 **如果**[
第四步](https://47.100.29.40/highgo_admin/%22file:///C:/Users/zylong/Desktop/1/Oracle-
安装手册-Data%20Gaurd单机对单机v1.0.docx#_4�����˴���standby_redologs������11G")
**创建过standby redologs，请忽略此步。**

对于11G此步骤可以在主端备份数据库之前创建standby redolog，在备端执行alter database
mount;后会在备端自动创建standby redolog。

SQL&gt; col status format a10;

select thread#, GROUP#,SEQUENCE#,BYTES/1024/1024,STATUS,FIRST_TIME from v$log;

&nbsp;

&nbsp;&nbsp; THREAD#&nbsp;&nbsp;&nbsp;&nbsp; GROUP#&nbsp; SEQUENCE#
BYTES/1024/1024 STATUS&nbsp;&nbsp;&nbsp;&nbsp; FIRST_TIM

\---------- ---------- ---------- --------------- ---------- ---------

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
13&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
50 CURRENT&nbsp;&nbsp;&nbsp; 06-JUL-16

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
11&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
50 INACTIVE&nbsp;&nbsp; 04-JUL-16

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
3&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
12&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
50 ACTIVE&nbsp;&nbsp;&nbsp;&nbsp; 06-JUL-16

&nbsp;

SQL&gt; Set linesize 200

col member format a50

select * from v$logfile;

&nbsp;

&nbsp;&nbsp;&nbsp; GROUP# STATUS&nbsp;&nbsp;&nbsp;&nbsp;
TYPE&nbsp;&nbsp;&nbsp;
MEMBER&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
IS_

\---------- ---------- ------- -------------------------------------- ---

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
3&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp;
/data/orcl/redo03.log&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
NO

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ONLINE&nbsp;
/data/orcl/redo02.log&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
NO

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp;
/data/orcl/redo01.log&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
NO

&nbsp;

主端创建standby redologs：

standby redo日志的大小必须 **至少与redo日志一样大** ； **对于每个线程（** **THREAD#** **）的standby
redo的数量必须至少比当前线程的redo日志多一个日志组。**

当前环境中包含1个节点，有3个日志组（GROUP#），每个日志的大小为50MB，每个日志组有1个成员。根据这种情况，为每个线程创建4个大小为50MB的日志组，每个日志组包含1个成员，位于/data/orcl目录下。

&nbsp;

SQL&gt; ALTER DATABASE ADD STANDBY LOGFILE THREAD 1

GROUP 4 (&#39;/data/orcl/stdbyredo01.log&#39;) SIZE 50M,

GROUP 5 (&#39;/data/orcl/stdbyredo02.log&#39;) SIZE 50M,

GROUP 6 (&#39;/data/orcl/stdbyredo03.log&#39;) SIZE 50M,

GROUP 7 (&#39;/data/orcl/stdbyredo04.log&#39;) SIZE 50M;

&nbsp;

备端创建standby redologs：

&nbsp;

SQL&gt; ALTER DATABASE ADD STANDBY LOGFILE THREAD 1

GROUP 4 (&#39;/data/orcldg/onlinelog/stdbyredo01.log&#39;) SIZE 50M,

GROUP 5 (&#39;/data/orcldg/onlinelog/stdbyredo02.log&#39;) SIZE 50M,

GROUP 6 (&#39;/data/orcldg/onlinelog/stdbyredo03.log&#39;) SIZE 50M,

GROUP 7 (&#39;/data/orcldg/onlinelog/stdbyredo04.log&#39;) SIZE 50M;

 **  
**

 **12、备端同步主端的归档日志**

备端恢复数据文件完成后，开启介质恢复进程，将主库的归档日志恢复到备库。

 **备端** 启动恢复进程mrp0

SQL&gt; alter database recover managed standby database using current logfile
disconnect from session;

 **& nbsp;**

 **备端** 查询是否有mrp0进程

SQL&gt; SELECT PROCESS,STATUS,THREAD#,SEQUENCE#,BLOCK#,BLOCKS,DELAY_MINS FROM
V$MANAGED_STANDBY;

&nbsp;

切换 **主库** 归档，观察备库归档日志同步是否正常。

SQL&gt; alter system archive log current;

&nbsp;

关闭介质恢复的方法：

SQL&gt; ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;

 **  
**

 **13、备端开启和关闭Active Data Guard**

 **此步骤仅限11G** ，active dataguard模式下，备机可提供只读的查询业务，不能写数据。

如果开启了第10步的介质恢复进程，需要先关闭介质恢复进程

SQL&gt; ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;

启动

SQL&gt; ALTER DATABASE OPEN READ ONLY;

SQL&gt; RECOVER MANAGED STANDBY DATABASE DISCONNECT USING CURRENT LOGFILE;

 **  
**

 **14、查询同步情况**

此查询10G和11G都可以使用。

主端查询

SQL&gt; &nbsp;&nbsp;select max(sequence#),thread# from v$archived_log where
RESETLOGS_CHANGE# = (SELECT RESETLOGS_CHANGE# FROM V$DATABASE_INCARNATION
WHERE STATUS = &#39;CURRENT&#39;) GROUP BY THREAD#;

&nbsp;

&nbsp;&nbsp; THREAD# MAX(SEQUENCE#)

\---------- --------------

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 10

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
9

&nbsp;

备端查询

SQL&gt; select max(sequence#),thread# from v$archived_log where&nbsp;
applied=&#39;YES&#39; and RESETLOGS_CHANGE# = (SELECT RESETLOGS_CHANGE# FROM
V$DATABASE_INCARNATION WHERE STATUS = &#39;CURRENT&#39;) GROUP BY THREAD#;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

&nbsp;

&nbsp;&nbsp; THREAD# MAX(SEQUENCE#)

\---------- --------------

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
9

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
9

&nbsp;

主备以上结果对比，如果max(sequence#)相差较大，表示目前不同步或同步延时较大，如果相差1到2个是可以接受的。

&nbsp;

查看备机恢复进程状态的方法：

SQL&gt; SELECT PROCESS,STATUS,THREAD#,SEQUENCE#,BLOCK#,BLOCKS,DELAY_MINS FROM
V$MANAGED_STANDBY;

以下查询仅限11G Active Data Guard

SQL&gt; set line 300

SQL&gt; select name,value&nbsp; from v$dataguard_stats;

&nbsp;

NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
VALUE

\-------------------------------- --------------------------------------------

transport lag&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;+00 00:00:00

apply
lag&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
+00 00:00:00

apply finish
time&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
+00 00:00:00.000

estimated startup
time&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 21

## 15、备库开启闪回功能

根据实际环境设置以下参数

设置闪回区大小，这是闪回区存放闪回日志时占用磁盘空间的最大限制，设置前确保磁盘空间充足( **请结合实际磁盘空间设置** )

SQL&gt; alter system set db_recovery_file_dest_size=100g scope=spfile;

设置闪回区位置，用于存放闪回日志文件

SQL&gt; alter system set db_recovery_file_dest=&#39;/flashback_area&#39;
scope=spfile;

设置闪回日志保留天数为5天，此参数以分钟为单位，每天为1440分钟 **(** **请结合实际情况设置保留天数** **)**

SQL&gt; alter system set db_flashback_retention_target=7200 scope=spfile;

打开闪回功能

SQL&gt; select flashback_on from V$database;

&nbsp;

FLASHBACK_ON

\------------------

NO

&nbsp;

SQL&gt; RECOVER MANAGED STANDBY DATABASE CANCEL;

SQL&gt; shutdown immediate;

SQL&gt; startup mount;

SQL&gt; alter database flashback on;

SQL&gt; alter database open;

SQL&gt; select flashback_on from v$database;

&nbsp;

FLASHBACK_ON

\------------------

YES

开启同步

SQL&gt; RECOVER MANAGED STANDBY DATABASE DISCONNECT USING CURRENT LOGFILE;

&nbsp;

当使用闪回数据库闪回到过去的时间点时，请参考《oracle_误删除数据恢复操作手册》

 **  
**  

 **16、Switchover**

1. 检查主库和备库的参数设置

2. 确保主库设置了以下参数

&nbsp;

SQL&gt; alter system set DB_FILE_NAME_CONVERT =
&#39;/data/orcldg/datafile/&#39;,&#39;/data/orcl/&#39; sid=’*’ scope=spfile;

&nbsp;

SQL&gt; alter system set LOG_FILE_NAME_CONVERT =
&#39;/data/orcldg/onlinelog/&#39;,&#39;/data/orcl/&#39; sid=’*’ scope=spfile;

3. 确保主库创建了standby logfile联机redo日志文件

SQL&gt; select * from v$standby_log;

4. 确保compatible主库和备库相同

5. 确保Managed Recovery运行在备库，且主备端同步正常

SQL&gt; SELECT PROCESS FROM V$MANAGED_STANDBY WHERE PROCESS LIKE
&#39;MRP%&#39;;

&nbsp;

PROCESS

\---------

MRP0

&nbsp;

主端；

SQL&gt; select thread#,max(sequence#) from v$archived_log where
RESETLOGS_CHANGE# = (SELECT RESETLOGS_CHANGE# FROM V$DATABASE_INCARNATION
WHERE STATUS = &#39;CURRENT&#39;) GROUP BY THREAD#;

&nbsp;

备端；

SQL&gt; select thread#,max(sequence#) from v$archived_log where&nbsp;
applied=&#39;YES&#39; and RESETLOGS_CHANGE# = (SELECT RESETLOGS_CHANGE# FROM
V$DATABASE_INCARNATION WHERE STATUS = &#39;CURRENT&#39;) GROUP BY THREAD#;

&nbsp;

SQL&gt; set line 200

SQL&gt; select name,value&nbsp; from v$dataguard_stats;

&nbsp;

 ** _\--10G_** ** _需要检查_**

 **SELECT DELAY_MINS FROM V$MANAGED_STANDBY WHERE PROCESS = &#39;MRP0&#39;;**

 **& nbsp;**

 **On the target physical standby database turn off delay if &gt; 0**

 **& nbsp;**

 **SQL &gt; RECOVER MANAGED STANDBY DATABASE CANCEL**

 **SQL &gt; ALTER DATABASE RECOVER MANAGED STANDBY DATABASE NODELAY USING
CURRENT LOGFILE DISCONNECT FROM SESSION;**

&nbsp;

 ** _\--10G_** ** _需要检查_**

 **primary &nbsp;** **检查以前禁用重做线程**

 **SQL &gt; SELECT THREAD# FROM V$THREAD WHERE SEQUENCE# &gt; 0;**

 **& nbsp;**

 **& nbsp;&nbsp; THREAD#**

 **\----------**

 **& nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1**

 **& nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2**

 **& nbsp;**

 **SQL &gt; SELECT TO_CHAR(RESETLOGS_CHANGE#) FROM V$DATABASE_INCARNATION
WHERE STATUS = &#39;CURRENT&#39;;**

 **& nbsp;**

 **TO_CHAR(RESETLOGS_CHANGE#)**

 **\----------------------------------------**

 **602821**

 **& nbsp;**

 **SQL &gt; SELECT &#39;CONDITION MET&#39;**

 **& nbsp; 2&nbsp; FROM SYS.DUAL**

 **& nbsp; 3&nbsp; WHERE NOT EXISTS (SELECT 1**

 **& nbsp; 4&nbsp; FROM V$ARCHIVED_LOG**

 **& nbsp; 5&nbsp; WHERE THREAD# = 1**

 **& nbsp; 6&nbsp; AND RESETLOGS_CHANGE# = 602821)**

 **& nbsp; 7&nbsp; AND NOT EXISTS (SELECT 1**

 **& nbsp; 8&nbsp; FROM V$LOG_HISTORY**

 **& nbsp; 9&nbsp; WHERE THREAD# = 1**

 **& nbsp;10&nbsp; AND RESETLOGS_CHANGE# = 602821);**

 **& nbsp;**

 **no rows selected**

 **& nbsp;**

 **SQL &gt; SELECT &#39;CONDITION MET&#39;**

 **& nbsp; 2&nbsp; FROM SYS.DUAL**

 **& nbsp; 3&nbsp; WHERE NOT EXISTS (SELECT 1**

 **& nbsp; 4&nbsp; FROM V$ARCHIVED_LOG**

 **& nbsp; 5&nbsp; WHERE THREAD# = 2**

 **& nbsp; 6&nbsp; AND RESETLOGS_CHANGE# = 602821)**

 **& nbsp; 7&nbsp; AND NOT EXISTS (SELECT 1**

 **& nbsp; 8&nbsp; FROM V$LOG_HISTORY**

 **& nbsp; 9&nbsp; WHERE THREAD# = 2**

 **& nbsp;10&nbsp; AND RESETLOGS_CHANGE# = 602821);**

 **& nbsp;**

 **no rows selected**

&nbsp;

 ** _\--10G_** ** _需要检查_**

 **SQL &gt; SELECT VALUE FROM V$DATAGUARD_STATS WHERE NAME=&#39;standby has
been open&#39;;**

 **& nbsp;**

 **VALUE**

 **\----------------------------------------------------------------**

 **N**

 **& nbsp;**

 **If the target physical standby was open read-only then restart the
standby**

 **& nbsp;**

 **SQL &gt; SHUTDOWN IMMEDIATE**

 **& nbsp;**

 **SQL &gt; STARTUP MOUNT**

&nbsp;

6. 确保主库 LOG_ARCHIVE_DEST_2 的 recover状态是“REAL TIME APPLY” ，如果到传输到备库的日志目录是其他目录如 LOG_ARCHIVE_DEST_3，则检查LOG_ARCHIVE_DEST_3。

SQL&gt; show parameter LOG_ARCHIVE_DEST_2

&nbsp;

NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;TYPE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
VALUE

\------------------------------------ -----------
------------------------------

log_archive_dest_2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
string&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; SERVICE=ORCLDG LGWR ASYNC REOP

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;EN
NET_TIMEOUT=300 VALID_FOR=(

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE_LOGFILE,PRIMARY_ROLE) D

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
B_UNIQUE_NAME=ORCLDG

10G：

 **主端查询：**

SQL&gt; SELECT RECOVERY_MODE FROM V$ARCHIVE_DEST_STATUS WHERE DEST_ID=2;

&nbsp;

RECOVERY_MODE

\-----------------------

MANAGED

&nbsp;

11G 开启只读模式：

 **主端查询：**

SQL&gt; SELECT RECOVERY_MODE FROM V$ARCHIVE_DEST_STATUS WHERE DEST_ID=2;

&nbsp;

RECOVERY_MODE

\-----------------------

MANAGED REAL TIME APPLY

7. 检查LOG_ARCHIVE_MAX_PROCESSES，仅限11G

检查 **主端和备端** LOG_ARCHIVE_MAX_PROCESSES 参数设置为4或更高，注意不要设置过高，此参数可以通过 ALTER SYSTEM
动态修改。

SQL&gt; show parameter LOG_ARCHIVE_MAX_PROCESSES

&nbsp;

NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
TYPE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; VALUE

\------------------------------------ -----------
------------------------------

log_archive_max_processes&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;integer&nbsp;&nbsp;&nbsp;&nbsp;
4

8. 检查主库和备库的临时表空间和所有的数据文件是否为ONLINE状态

关于备库上的每个临时表空间，验证与主库上的表空间相关联的临时表空间也存在于备库上。

SQL&gt; SELECT TMP.NAME FILENAME, BYTES, TS.NAME TABLESPACE

FROM V$TEMPFILE TMP, V$TABLESPACE TS WHERE TMP.TS#=TS.TS#;&nbsp;&nbsp;

&nbsp;

主端&nbsp;&nbsp;

FILENAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;BYTES TABLESPACE

\------------------------------ ---------- ------------------------------

/data/orcl/temp01.dbf&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
30408704 TEMP

&nbsp;

备端

FILENAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
BYTES TABLESPACE

\-------------------------------- ---------- ------------------------------

/data/orcldg/datafile/temp01.dbf&nbsp;&nbsp; 20971520 TEMP

如果查询不匹配，可以在打开新的主库后再纠正。

&nbsp;

在备端查询数据文件状态

SQL&gt; SELECT NAME FROM V$DATAFILE WHERE STATUS=&#39;OFFLINE&#39;;

如果有任何OFFLINE 数据文件，切换后将其ONLINE：

SQL&gt; ALTER DATABASE DATAFILE &#39;datafile-name&#39; ONLINE;

9. 清除可能受阻的参数与jobs

主端查看当前DBMS_JOB 的状态

SQL&gt; SELECT * FROM DBA_JOBS_RUNNING;

主端查看当前DBMS_SCHEDULER的状态

SQL&gt; select owner,job_name,session_id,slave_process_id,running_instance
from dba_scheduler_running_jobs;

如果有正在运行的job则不建议切换，最好等job运行完，或者停掉job（详细参考oracle Job操作手册）。

SQL&gt; SHOW PARAMETER job_queue_processes

禁止所有job再自动执行

SQL&gt; ALTER SYSTEM SET job_queue_processes=0 SCOPE=BOTH SID=&#39;*&#39;;

10. 打开Data Guard 主库和备库的日志跟踪

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

SQL&gt; ALTER SYSTEM SET log_archive_trace=8191;&nbsp;&nbsp; &nbsp;

打开后会在background_dump_dest参数指定的目录里生成类似ora11g_ **mrp0** _31640.trc的trc日志文件。

可以ls -lrt *mrp0* 来定位最后一个文件。

&nbsp;

查看alter日志

10G：

SQL&gt; SHOW PARAMETER background_dump_dest

&nbsp;

NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
TYPE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; VALUE

\-------------------------------- ----------- ------------------------------

background_dump_dest&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
string&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /u01/app/oracle/admin/orcl/bdump

&nbsp;

11G

SQL&gt; SHOW PARAMETER background_dump_dest

&nbsp;

NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
TYPE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; VALUE

\------------------------ -----------
-----------------------------------------

background_dump_dest&nbsp;&nbsp;
&nbsp;&nbsp;string&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
/u01/app/oracle/diag/rdbms/orcl/orcl/trace

&nbsp;

[root@dgzhu trace]# tail -f alert_orcl.log

11. 创建可靠还原点（可选）如果switch切换后有问题可以通过还原点回退数据库。

确认是否开启了闪回，如果没有则要先开启，主库和备库。

&nbsp;

备库：

SQL&gt; show parameter DB_RECOVERY

NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;TYPE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
VALUE

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

12. 确保主库可以切换为备库

主端：

SQL&gt; SELECT SWITCHOVER_STATUS FROM V$DATABASE;

SWITCHOVER_STATUS

\--------------------

TO STANDBY

如果主端有回话连接，则查询结果是

SESSIONS ACTIVE

13. 切换主库为 standby database

 **如果主端是RAC，则先shutdown immediate的形式关闭其他所有的实例，只保留一个。**

如果查询结果是SESSIONS ACTIVE：

SQL&gt; ALTER DATABASE COMMIT TO SWITCHOVER TO PHYSICAL STANDBY WITH SESSION
SHUTDOWN;

&nbsp;

如果查询结果是TO STANDBY

SQL&gt; ALTER DATABASE COMMIT TO SWITCHOVER TO PHYSICAL STANDBY;

&nbsp;

如果切换失败可参阅

http://docs.oracle.com/cd/E11882_01/server.112/e41134/troubleshooting.htm#SBYDB01410

如果切换过程遇到ora-16139 ，且主端的v$database&nbsp; database_role是 physical standby
，则可以先忽略，当切换玩启动恢复进程后，会自动recover。

&nbsp;

14. 验证备库可否切换为主库

SQL&gt; SELECT SWITCHOVER_STATUS FROM V$DATABASE;

SWITCHOVER_STATUS

\-----------------

TO PRIMARY

15. 切换 standby database 为主库

第一种情况

如果查询结果是SESSIONS ACTIVE： 执行下面的：

SQL&gt; ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY WITH SESSION SHUTDOWN;

&nbsp;

如果查询结果是TO PRIMARY

SQL&gt; ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY;

16\. open新的主库

SQL&gt; ALTER DATABASE OPEN;

17. 如果有不匹配的临时表空间，更正不匹配的临时表空间

18. 重新启动新的备库

SQL&gt; SHUTDOWN ABORT;

SQL&gt; STARTUP MOUNT;

SQL&gt; ALTER DATABASE OPEN READ ONLY;

SQL&gt; RECOVER MANAGED STANDBY DATABASE DISCONNECT USING CURRENT LOGFILE;

19. 收尾

SQL&gt; ALTER SYSTEM SET log_archive_trace=0;

SQL&gt; ALTER SYSTEM SET job_queue_processes=&lt;value saved&gt; scope=both
sid=’*’

SQL&gt; EXECUTE DBMS_SCHEDULER.ENABLE(&lt;for each job name captured&gt;);

SQL&gt; DROP RESTORE POINT SWITCHOVER_START_GRP;

 **另外要调整主备端自动删除归档的脚本和计划任务** **。**

参考文档：

 **11.2 Data Guard Physical Standby Switchover Best Practices using SQL*Plus
(** **文档 ID 1304939.1)**

 **10.2 Data Guard Physical Standby Switchover (** **文档** **ID751600.1)**

 **  
**

 **17、failover**

如果主库可以mount，则在mount状态下执行以下步骤，如果不能mount则跳过这一步

SQL&gt; alter system flush redo to
&#39;&lt;target_db_name&gt;&#39;;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

 ** _注：target_db_name=备端的DB_UNIQUE_NAME_**

flush redo是在11gR2被引入的. 对于Data guard, 在故障切换时flush
redo可能是非常有用的，如果这个命令能成功将最后的redo应用到standby上，那么DG上将没有数据丢失。

如果需要执行此语句，在standby上的 redo apply必须是启动的，执行此命令的primary database必须是mouted
状态，不能open ,默认情况下 comfirm apply是这个语句的一部分，语句执行将会一直等待直到所有redo applied。

&nbsp;

10G

主端和备端找出相差的归档日志，将主端未传输的归档日志传递至备端。

在备端手动注册缺失的归档日志：

alter database register physical logfile
&#39;/fra/arch/1_42_916276568.dbf&#39;;

alter database register physical logfile
&#39;/fra/arch/1_43_916276568.dbf&#39;;

alter database register physical logfile
&#39;/fra/arch/1_44_916276568.dbf&#39;;

&nbsp;

备端执行以下语句停止redo应用服务

SQL&gt; ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;

&nbsp;

备端执行以下语句发起故障转移操作：

SQL&gt; alter database recover managed standby database finish force;

&nbsp;

备端执行以下语句将备库转换为主库

SQL&gt; ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY;

&nbsp;

备端执行以下语句打开转换后的主库：

SQL&gt; alter database open;

&nbsp;

确认：

SQL&gt; select database_role from v$database;

&nbsp;

DATABASE_ROLE

\----------------

PRIMARY

 **  
**

 **18、参数解释**

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

alter system set LOG_ARCHIVE_MAX_PROCESSES=5 scope=spfile;

最大ARCn进程数

&nbsp;

alter system set LOG_ARCHIVE_DEST_STATE_1=ENABLE scope=spfile;

允许redo传输服务传输数据到目的地，默认是enable

&nbsp;

alter system set LOG_ARCHIVE_DEST_STATE_2=ENABLE scope=spfile;

允许redo传输服务传输数据到目的地，默认是enable

&nbsp;

alter system set REMOTE_LOGIN_PASSWORDFILE=EXCLUSIVE scope=spfile;

exclusive or shared，所有库sys密码要一致，默认是exclusive

&nbsp;

以下是主库切换为备库，充当备库角色时的一些参数设置，如果不打算做数据库切换就不用设置了

alter system set FAL_SERVER=db_phystdby scope=spfile;

配置网络服务名，假如转换为备库角色时，从这里获取丢失的归档文件

&nbsp;

alter system set FAL_CLIENT=db_wending scope=spfile;

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

alter system set STANDBY_FILE_MANAGEMENT=auto scope=spfile;

auto后当主库的datafiles增删时备库也同样自动操作，且会把日志传送到备库standby_archive_dest参数指定的目录下，确保该目录存在，如果你的存储采用文件系统没有问题，但是如果采用了裸设备，你就必须将该参数设置为manual

&nbsp;

alter system set
STANDBY_ARCHIVE_DEST=&#39;LOCATION=/orahome/arch1/WENDING&#39; scope=spfile;

一般和LOG_ARCHIVE_DEST_1的位置一样，如果备库采用ARCH传输方式，那么主库会把归档日志传到该目录下，这个参数在11g的时候已经废弃

  

" name="docDetail" type="hidden">


---
### ATTACHMENTS
[7f025a17697ee15eb3197c61326b203b]: media/Oracle-安装手册-11gR2_Data_Gaurd单机对单机.html
[Oracle-安装手册-11gR2_Data_Gaurd单机对单机.html](media/Oracle-安装手册-11gR2_Data_Gaurd单机对单机.html)
>hash: 7f025a17697ee15eb3197c61326b203b  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-11gR2_Data Gaurd单机对单机_files\11947ec6e06f4dd6a765bcc48c4fc88d.png  

---
### NOTE ATTRIBUTES
>Created Date: 2018-09-25 03:29:12  
>Last Evernote Update Date: 2018-10-01 15:33:53  
>author: YangKwong  
>source: desktop.win  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-11gR2_Data Gaurd单机对单机.html  
>source-application: evernote.win32  