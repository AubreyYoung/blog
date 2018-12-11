# Oracle-指导手册-Oracle DataGaurd RAC对RAC安装.html

# Oracle-指导手册-Oracle DataGaurd RAC对RAC安装

# 瀚高技术支持管理平台

确认主备端OS及DB版本是否一致、是否通过认证；

如若两端OS及DB版本存在差异，务必声明

 **1、primary force logging**

$ sqlplus / as sysdba

SQL> select name,log_mode,force_logging from gv$database;

NAME      LOG_MODE     FOR

\--------- ------------ ---

ORCL       ARCHIVELOG   NO

ORCL       ARCHIVELOG   NO

SQL> alter database force logging;

Database altered.

SQL> select name,log_mode,force_logging from gv$database;

NAME      LOG_MODE     FOR

\--------- ------------ ---

ORCL       ARCHIVELOG   YES

ORCL       ARCHIVELOG   YES

## 2、 primary 设置归档模式

查看是否为归档模式：

SQL> archive log list;

Database log mode        Archive Mode

Automatic archival         Enabled

Archive destination        +FRA

Oldest online log sequence     4

Next log sequence to archive   5

Current log sequence               5

若Database log mode 显示为Archive Mode即为归档模式，Archive
destination显示为归档路径，也可以查看归档路径的参数确定归档位置。

SQL> show parameter log_archive_dest_1

NAME                                 TYPE        VALUE

\------------------------------------ -----------
------------------------------

log_archive_dest_1                   string      LOCATION=+FRA/

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

启动其他实例

## 3、配置primary参数

SQL> ALTER SYSTEM SET LOG_ARCHIVE_CONFIG='DG_CONFIG=(ORCL,ORCLDG)' SID='*';

 **#** ** _注_** ** _红色取值为主库和备库的_** **_DB_UNIQUE_NAME_**

SQL> ALTER SYSTEM SET LOG_ARCHIVE_DEST_1='LOCATION=+FRA
VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=ORCL' SID='*';

SQL> ALTER SYSTEM SET LOG_ARCHIVE_DEST_2='SERVICE=ORCLDG LGWR ASYNC REOPEN
NET_TIMEOUT=300 VALID_FOR=(ONLINE_LOGFILE,PRIMARY_ROLE) DB_UNIQUE_NAME=ORCLDG'
SID='*';

 **#** ** _注_** ** _红色取值为主库_** ** _tnsnames.ora_** ** _文件中备库的_** ** _Net
service name_**

SQL> alter system set LOG_ARCHIVE_DEST_STATE_1=ENABLE;

SQL> alter system set LOG_ARCHIVE_DEST_STATE_2=ENABLE;

SQL> ALTER SYSTEM SET STANDBY_FILE_MANAGEMENT =AUTO SID='*';

SQL> ALTER SYSTEM SET STANDBY_ARCHIVE_DEST='+FRA';   **#** ** _注_** **_11G_**
** _此参数已废弃_**

SQL> ALTER SYSTEM SET FAL_CLIENT='ORCL' SID='*';         **#** ** _注_**
**_11G_** ** _此参数已废弃_**

 **#** ** _注_** ** _红色取值为主库_** ** _tnsnames.ora_** ** _文件中主库的_** ** _Net
service name_**

SQL> ALTER SYSTEM SET FAL_SERVER='ORCLDG' SID='*';

 **#** ** _注_** ** _红色取值为主库_** ** _tnsnames.ora_** ** _文件中备库的_** ** _Net
service name_**

 **FAL_SERVER And FAL_CLIENT Settings For Cascaded Standby (** **文档** **ID
358767.1)**

以下参数修改需要重启数据库，注意：如果主端是RAC环境，且不能重启数据库，请不要修改以下参数。备端必须进行设置。

SQL> alter system set
DB_FILE_NAME_CONVERT='+DATADG/orcldg/datafile/','+DATA/orcl/datafile/' sid=’*’
scope=spfile;

SQL> alter system set
LOG_FILE_NAME_CONVERT='+DATADG/orcldg/onlinelog/','+DATA/orcl/onlinelog/'
sid=’*’ scope=spfile;

DB_FILE_NAME_CONVERT参数的作用是转换主库和备库的数据文件路径。

LOG_FILE_NAME_CONVERT参数的作用是转换主库和备库的redo日志文件的路径。

以上两个参数的书写格式是，两两路径为一组，对方的路径在前，自己的路径在后。

## 4、监听配置

### 4.1、备端配置静态监听服务名

 **此步骤仅限** **11G** **使用** **RMAN DUPLICATE** **时配置静态监听服务名。**

在备端第一个节点以grid用户向$ORACLE_HOME/network/admin/listener.ora文件中添加以下条目：

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

    (ADDRESS = (PROTOCOL = TCP)(HOST = 备端node1 vip)(PORT = 1521))

  )

SID_NAME：数据库实例名，其值需和数据库参数INSTANCE_NAME保持一致，不可省略。

GLOBAL_DBNAME：数据库服务名，可以省略，默认和SID_NAME保持一致。

ORACLE_HOME：实例运行的ORACLE_HOME目录。在UNIX和Linux环境下，该参数可以省略，默认和环境变量$ORACLE_HOME保持一致。在WINDOWS环境中，该参数无效，ORACLE_HOME的值取自注册表HKEY_LOCAL_MACHINE\SOFTWARE\ORACLE\HOMEID

配置完成后重启监听器

### 4.2、主备端tnsnames.ora文件配置

以oracle用户配置$ORACLE_HOME /network/admin/tnsnames.ora文件

 **1** **、主端** **tnsnames.ora** **文件添加备端** **IP** **配置条目。**

主端tnsnames.ora配置示例：

10G：主端添加备端的所有VIP地址

[oracle@rac1 admin]$ cat tnsnames.ora

ORCLDG =

  (DESCRIPTION =

    (ADDRESS_LIST =

      (ADDRESS = (PROTOCOL = TCP)(HOST = 备端node1 vip)(PORT = 1521))

      (ADDRESS = (PROTOCOL = TCP)(HOST = 备端node2 vip)(PORT = 1521))

    )

    (CONNECT_DATA =

      (SERVICE_NAME = orcldg)

    )

  )

11G：主端添加备端的scan ip地址

$ cat tnsnames.ora

ORCLDG =

  (DESCRIPTION =

    (ADDRESS = (PROTOCOL = TCP)(HOST = 备端scan ip)(PORT = 1521))

    (CONNECT_DATA =

      (SERVER = DEDICATED)

      (SERVICE_NAME = orcldg)

    )

  )

 **2** **、备端** **tnsnames.ora** **文件添加主端** **IP** **配置条目。**

备端tnsnames.ora配置示例：

10G：备端添加主端的所有VIP地址

[oracle@orcldg1 admin]$ cat tnsnames.ora

ORCL =

  (DESCRIPTION =

    (ADDRESS = (PROTOCOL = TCP)(HOST = 主端node1 vip)(PORT = 1521))

    (ADDRESS = (PROTOCOL = TCP)(HOST = 主端node2 vip)(PORT = 1521))

    (LOAD_BALANCE = yes)

    (CONNECT_DATA =

      (SERVER = DEDICATED)

      (SERVICE_NAME = orcl)

    )

  )

 **注意：备端是** **RAC** **，需要注意备端的两个节点上** **tnsnames.ora** **文件存在以** **下内容：**

LISTENERS_ORCLDG =

  (ADDRESS_LIST =

    (ADDRESS = (PROTOCOL = TCP)(HOST = 备端node1 vip)(PORT = 1521))

    (ADDRESS = (PROTOCOL = TCP)(HOST = 备端node2 vip)(PORT = 1521))

  )

如果不存在，启动实例会报以下错误：

SQL> startup nomount;

ORA-01078: failure in processing system parameters

ORA-00119: invalid specification for system parameter REMOTE_LISTENER

ORA-00132: syntax error or unresolved network name 'LISTENERS_ORCLDG'

11G：备端添加主端的scan ip地址

$ cat tnsnames.ora

ORCL =

  (DESCRIPTION =

    (ADDRESS = (PROTOCOL = TCP)(HOST = 主端scan ip)(PORT = 1521))

    (CONNECT_DATA =

      (SERVER = DEDICATED)

      (SERVICE_NAME = orcl)

    )

  )

备机启动监听

$ lsnrctl start

主端和备端测试监听配置：

$ tnsping ORCL

Used TNSNAMES adapter to resolve the alias

Attempting to contact (DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST =
10.10.10.10)(PORT = 1521)) (CONNECT_DATA = (SERVER = DEDICATED) (SERVICE_NAME
= orcl)))

OK (10 msec)

## 5、主端node1传输密码文件至备端

$ scp orapworcl1 备端node1 vip:$ORACLE_HOME/dbs/orapworcldg1

$ scp orapworcl1 备端node2 vip:$ORACLE_HOME/dbs/orapworcldg2

## 6、主端创建密码验证用户，仅限11G

SQL> create user dgmima identified by 密码;

密码要提高复杂度，至少８个字母包含大小写英文和数字，并要记录到交付文档中，可以在线百度随机密码生成器。

SQL> GRANT SYSOPER to dgmima;

SQL>  select * from V$PWFILE_USERS;

USERNAME                       SYSDB SYSOP SYSAS

\------------------------------ ----- ----- -----

SYS                            TRUE  TRUE  FALSE

DGMIMA                         FALSE TRUE  FALSE

SQL> ALTER SYSTEM SET REDO_TRANSPORT_USER = DGMIMA SID='*';

 ** _\--_** ** _How to make log shipping to continue work without copying
password file from primary to physical standby when changing sys password on
primary? (_** ** _文档_** **_ID 1416595.1)_**

## 7、备端修改主端生成的pfile参数文件

主端备份传输pfile参数文件：

SQL>create pfile='/home/oracle/pfile.ora' from spfile;

将备份文件传输到备端RAC的节点1上

$ scp /home/oracle/pfile.ora 备端node1 vip:/home/oracle/

在备端修改上一步传输的参数文件：

 **#** ** _注_** ** _本节标红的内容为需要修改的_**

10G

*.audit_file_dest='/u01/app/oracle/admin/orcldg/adump'

*.background_dump_dest='/u01/app/oracle/admin/orcldg/bdump'

*.cluster_database_instances=2

*.cluster_database=TRUE

*.compatible='10.2.0.3.0'

*.control_files='+DATADG/orcldg/controlfile/current01.ctl', '+FRADG/orcldg/controlfile/current02.ctl'

*.core_dump_dest='/u01/app/oracle/admin/orcldg/cdump'

*.db_block_size=8192

*.db_create_file_dest=''          **#** ** _注_** ** _关闭_** ** _OMF_** ** _功能_**

*.db_domain=''

*.db_file_multiblock_read_count=16

*.db_files=2000

*.db_name='orcl'

*.dispatchers='(PROTOCOL=TCP) (SERVICE=orcldgXDB)'

*.fal_client='ORCLDG'

*.fal_server='ORCL'

orcldg1.instance_number=1

orcldg2.instance_number=2

*.job_queue_processes=10

orcldg1.local_listener='(ADDRESS = (PROTOCOL = TCP)(HOST = 备端node1 vip)(PORT =
1521))'

orcldg2.local_listener='(ADDRESS = (PROTOCOL = TCP)(HOST = 备端node2 vip)(PORT =
1521))'

*.log_archive_config='DG_CONFIG=(ORCL,ORCLDG)'

*.log_archive_dest_1='LOCATION=+FRADG VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=ORCLDG'

*.log_archive_dest_2='SERVICE=ORCL LGWR ASYNC REOPEN NET_TIMEOUT=300 VALID_FOR=(ONLINE_LOGFILE,PRIMARY_ROLE) DB_UNIQUE_NAME=ORCL'

*.log_archive_dest_state_1='ENABLE'

*.log_archive_dest_state_2='ENABLE'

*.log_archive_format='%t_%s_%r.dbf'

*.max_dump_file_size='25m'

*.open_cursors=300

*.pga_aggregate_target=199229440

*.processes=1500

*.remote_listener='LISTENERS_ORCLDG'

*.remote_login_passwordfile='EXCLUSIVE'

*.sessions=1655

*.sga_target=599785472

*.standby_archive_dest='+FRADG'

*.standby_file_management='AUTO'

orcldg2.thread=2

orcldg1.thread=1

*.undo_management='AUTO'

orcldg1.undo_tablespace='UNDOTBS1'

orcldg2.undo_tablespace='UNDOTBS2'

*.user_dump_dest='/u01/app/oracle/admin/orcldg/udump'

*.service_names='orcldg'

*.db_unique_name='orcldg'

*.LOG_FILE_NAME_CONVERT='+DATA/orcl/onlinelog','+DATADG/orcldg/onlinelog/'

*.DB_FILE_NAME_CONVERT='+DATA/orcl/datafile/','+DATADG/orcldg/datafile/'

11G:

*.audit_file_dest='/u01/app/oracle/admin/orcldg/adump'

*.audit_trail='NONE'

*.cluster_database=true

*.compatible='11.2.0.4.0'

*.control_files='+DATADG/orcldg/controlfile/current01.ctl','+FRADG/orcldg/controlfile/current02.ctl'

*.db_block_size=8192

*.db_create_file_dest=''                    **#** ** _注_** ** _关闭_** ** _OMF_** ** _功能_**

*.db_create_online_log_dest_1=''

*.db_create_online_log_dest_2=''

*.db_domain=''

*.db_files=2000

*.db_name='orcl'

*.deferred_segment_creation=FALSE

*.diagnostic_dest='/u01/app/oracle'

*.dispatchers='(PROTOCOL=TCP) (SERVICE=orcldgXDB)'

*.enable_ddl_logging=TRUE

*.event='28401 TRACE NAME CONTEXT FOREVER, LEVEL 1'

*.fal_server='ORCL'

orcldg2.instance_number=2

orcldg1.instance_number=1

*.log_archive_config='DG_CONFIG=(ORCL,ORCLDG)'

*.log_archive_dest_1='LOCATION=+FRADG VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=ORCLDG'

*.log_archive_dest_2='SERVICE=ORCL LGWR ASYNC REOPEN NET_TIMEOUT=300 VALID_FOR=(ONLINE_LOGFILE,PRIMARY_ROLE) DB_UNIQUE_NAME=ORCL'

*.log_archive_dest_state_1='ENABLE'

*.log_archive_dest_state_2='ENABLE'

*.log_archive_format='%t_%s_%r.dbf'

*.max_dump_file_size='25m'

*.open_cursors=300

*.pga_aggregate_target=209715200

*.processes=1500

*.remote_listener='racdg-scan:1521'

*.remote_login_passwordfile='EXCLUSIVE'

*.sessions=1655

*.sga_target=1258291200

*.standby_file_management='AUTO'

orcldg2.thread=2

orcldg1.thread=1

orcldg2.undo_tablespace='UNDOTBS2'

orcldg1.undo_tablespace='UNDOTBS1'

*.service_names='orcldg'

*.db_unique_name='orcldg'

*.LOG_FILE_NAME_CONVERT='+DATA/orcl/onlinelog','+DATADG/orcldg/onlinelog/'

*.DB_FILE_NAME_CONVERT='+DATA/orcl/datafile/','+DATADG/orcldg/datafile/'

## 8、备端提前创建所需路径

10G 备端两个节点创建以下目录:

$ mkdir -p /u01/app/oracle/admin/orcldg/adump

$ mkdir -p /u01/app/oracle/admin/orcldg/bdump

$ mkdir -p /u01/app/oracle/admin/orcldg/cdump

$ mkdir -p /u01/app/oracle/admin/orcldg/udump

$ asmcmd –p

ASMCMD [+] > cd +DATADG

ASMCMD [+DATADG] > mkdir orcldg

ASMCMD [+DATADG] > cd orcldg

ASMCMD [+DATADG/orcldg] > mkdir DATAFILE CONTROLFILE ONLINELOG

ASMCMD [+DATADG/orcldg] > cd +FRADG

ASMCMD [+FRADG] > mkdir orcldg

ASMCMD [+FRADG] > cd orcldg

ASMCMD [+FRADG/orcldg] > mkdir ARCHIVELOG CONTROLFILE ONLINELOG

11G备端两个节点创建以下目录:

mkdir -p /u01/app/oracle/admin/orcldg/adump

ASMCMD [+] > cd +DATADG

ASMCMD [+DATADG] > mkdir orcldg

ASMCMD [+DATADG] > cd orcldg

ASMCMD [+DATADG/orcldg] > mkdir PARAMETERFILE DATAFILE CONTROLFILE TEMPFILE
ONLINELOG

ASMCMD [+DATADG/orcldg] > cd + FRADG

ASMCMD [+FRADG] > mkdir orcldg

ASMCMD [+FRADG] > cd orcldg

ASMCMD [+FRADG/orcldg] > mkdir ARCHIVELOG CONTROLFILE ONLINELOG

## 9、备端复制主端数据库

有两种方式，一种是使用RMAN在主端做备份，将备份文件传递至备端restore；另一种是使用RMAN DUPLICATE...FROM ACTIVE
DATABASE，这是oracle 11G新特性。

Step by Step Guide on Creating Physical Standby Using RMAN DUPLICATE...FROM
ACTIVE DATABASE (文档 ID 1075908.1)

## 9.1、RMAN备份还原复制主端数据库

 **#** ** _注_** ** _如果使用_** ** _RMAN DUPLICATE_** ** _方式，请跳过此章节。_**

### 9.1.1、备份primary

在主端node1上RMAN备份主端数据库，如果数据量很大，备份时间很长，建议后台执行备份脚本。

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

### 9.1.2、主端传输文件至备端

传输备份文件，将备份文件传输到备端RAC的节点1上

$ scp /home/oracle/rmanbak/orcl_full_* 备端node1 vip:/home/oracle/backup/

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

ftp> bin                               **#** ** _注_** ** _使用二进制传输备份文件_**

ftp> prompt off                      **#** ** _注_** ** _不用输入确认_**

ftp> mget orcl_full_*

### 9.1.3、备端启动数据库到nomount

备端node1数据库先生成spfile后启动数据库到nomount状态

设置ORACLE_SID

$ export ORACLE_SID=orcldg1

$ sqlplus / as sysdba

SQL> create spfile='+DATADG/orcldg/parameterfile/spfileorcldg.ora' from
pfile='/home/oracle/pfile.ora';

两个节点修改$ORACLE_HOME/dbs目录下initorcl1.ora参数文件

$ cat initorcl1.ora

spfile='+DATADG/orcldg/parameterfile/spfileorcldg.ora'

$ cat initorcl2.ora

spfile='+DATADG/orcldg/parameterfile/spfileorcldg.ora'

重启节点1的实例

sql> startup nomount;

注：如果备端是RAC并且未建过数据库，有可能$ORACLE_HOME/bin/oracle文件权限不正确

[oracle@racbak1 bin]$ ls -l oracle

-rwsr-s--x 1 oracle oinstall 239626641 Jun 27 05:33 oracle

解决方法

以grid用户执行以下命令

$ cd /u01/app/11.2.0/grid/bin/

$ ./setasmgidwrap o=/u02/app/oracle/product/11.2.0/db_home/bin/oracle

[oracle@racbak1 bin]$ ls -l oracle

-rwsr-s--x 1 oracle asmadmin 239626641 Jun 27 05:33 oracle

### 9.1.4、测试sqlplus连通性，确保能正常连通

主端和备端都要测试sqlplus连通性

$ sqlplus /nolog

主端测试

SQL> connect sys/oracle@orcldg AS SYSDBA

备端测试

SQL> connect sys/oracle@orcl AS SYSDBA

### 9.1.5、备端node1 restore database

restore控制文件

RMAN> restore standby controlfile from
'/home/oracle/backup/orcl_full_stanctf_0mr95t13_1_1';

备端将RMAN备份片加入到catalog中，rman备份的catalog使用控制文件。

RMAN> alter database mount;

RMAN> catalog backuppiece '/home/oracle/backup/orcl_full_g4qpg0ut_1_1';

RMAN> catalog backuppiece '/home/oracle/backup/orcl_full_g5qpg0ut_1_1';

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

## 9.2、RMAN DUPLICATE复制主端数据库

 **#** ** _注_** ** _如果使用_** ** _RMAN_** ** _备份还原方式，请跳过此章节。_**

### 9.2.1、备端创建初始化文件

在备端两个节点的$ORACLE_HOME/dbs目录下创建以下文件：

[oracle@racdg1 dbs]$ cat initorcl1.ora

spfile='+DATADG/orcldg/parameterfile/spfileorcldg.ora'

[oracle@racdg2 dbs]$ cat initorcl2.ora

spfile='+DATADG/orcldg/parameterfile/spfileorcldg.ora'

### 9.2.2、备端node1启动数据库到nomount

备端是节点1的数据库启动到nomount状态

设置ORACLE_SID

$ export ORACLE_SID=orcldg1

$ sqlplus / as sysdba

SQL> startup nomount pfile=/home/oracle/pfile.ora

 **#** ** _注_** ** _请不要使用_** ** _spfile_** ** _启动数据库_**

 ** _RMAN-05537: DUPLICATE without TARGET connection when auxiliary instance
is started with spfile cannot use SPFILE clause_**

### 9.2.3、测试sqlplus连通性，确保能正常连通

主端和备端都要测试sqlplus连通性

$ sqlplus /nolog

主端测试

SQL> connect sys/oracle@orcldg AS SYSDBA

备端测试

SQL> connect sys/oracle@orcl AS SYSDBA

### 9.2.4、主端node1执行RMAN DUPLICATE

 ** _注意_** ** _1_** ** _：_**

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

 ** _注意_** ** _2_** ** _：_**

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

RMAN连接主备数据库，开始RMAN DUPLICATE复制数据库：

$ rman target sys/oracle@orcl1 auxiliary sys/oracle@orcldg

Recovery Manager: Release 11.2.0.4.0 - Production on Sat Jun 25 12:17:04 2016

Copyright (c) 1982, 2011, Oracle and/or its affiliates.  All rights reserved.

connected to target database: ORCL (DBID=1443054597)

connected to auxiliary database: ORCL (not mounted)

RMAN> run {

allocate channel prmy1 type disk;

allocate channel prmy2 type disk;

allocate channel prmy3 type disk;

allocate channel prmy4 type disk;

allocate auxiliary channel stby type disk;

duplicate target database for standby from active database

spfile

   parameter_value_convert 'orcl','orcldg'

   SET DB_CREATE_FILE_DEST=''

   SET DB_CREATE_ONLINE_LOG_DEST_1=''

   SET DB_CREATE_ONLINE_LOG_DEST_2=''

   set db_unique_name='orcldg'

   set db_file_name_convert='+DATA/orcl/datafile/','+DATADG/orcldg/datafile/'

   set
log_file_name_convert='+DATA/orcl/onlinelog','+DATADG/orcldg/onlinelog/','+FRA/orcl/onlinelog/','+FRADG/orcldg/onlinelog/'

   set
control_files='+DATADG/orcldg/controlfile/current01.ctl','+FRADG/orcldg/controlfile/current02.ctl'

   set log_archive_max_processes='5'

   set fal_server='ORCL'

   set standby_file_management='AUTO'

   SET parallel_execution_message_size="65536"

   set log_archive_config='DG_CONFIG=(ORCL,ORCLDG)'

   set log_archive_dest_1='LOCATION=+FRADG VALID_FOR=(ALL_LOGFILES,ALL_ROLES)
DB_UNIQUE_NAME=ORCLDG'

   set log_archive_dest_2='SERVICE=ORCL LGWR ASYNC REOPEN NET_TIMEOUT=300
VALID_FOR=(ONLINE_LOGFILE,PRIMARY_ROLE) DB_UNIQUE_NAME=ORCL'

   NOFILENAMECHECK;

 }

参考文档：

11g RMAN Duplicate Database For Standby Fails With ORA-439 (文档 ID 1313736.1)

## 10、主备端创建standby redologs

对于11G此步骤可以在主端备份数据库之前创建standby redolog，在备端执行alter database
mount;后会在备端自动创建standby redolog。

SQL> col status format a10;

select thread#, GROUP#,SEQUENCE#,BYTES/1024/1024,STATUS,FIRST_TIME from v$log;

   THREAD#     GROUP#  SEQUENCE# BYTES/1024/1024 STATUS     FIRST_TIM

\---------- ---------- ---------- --------------- ---------- ---------

         1          1         27              50 CURRENT    25-JUN-16

         1          2         26              50 INACTIVE   25-JUN-16

         2          3          7              50 INACTIVE   25-JUN-16

         2          4          8              50 CURRENT    25-JUN-16

SQL> Set linesize 200

col member format a50

select * from v$logfile;

    GROUP# STATUS     TYPE    MEMBER                                             IS_

\---------- ---------- -------
-------------------------------------------------- ---

         2            ONLINE  +DATA/orcl/onlinelog/group_2.262.915273875         NO

         2            ONLINE  +FRA/orcl/onlinelog/group_2.258.915273877          NO

         1            ONLINE  +DATA/orcl/onlinelog/group_1.261.915273867         NO

         1            ONLINE  +FRA/orcl/onlinelog/group_1.257.915273871          NO

         3            ONLINE  +DATA/orcl/onlinelog/group_3.265.915274265         NO

         3            ONLINE  +FRA/orcl/onlinelog/group_3.259.915274271          NO

         4            ONLINE  +DATA/orcl/onlinelog/group_4.266.915274277         NO

         4            ONLINE  +FRA/orcl/onlinelog/group_4.260.915274281          NO

主端创建standby redologs：

standby redo日志的大小必须至少与redo日志一样大；对于每个线程（THREAD#）的standby
redo的数量必须至少比当前线程的redo日志多一个日志组。

当前的RAC环境中包含两个节点，每个节点有两个日志组（GROUP#），每个日志的大小为50MB，每个日志组有两个成员（+DATA，+FRA）。根据这种情况，为每个线程创建3个大小为50MB的日志组，每个日志组包含两个成员，分别位于DATA和FRA磁盘组。

alter database add standby logfile thread 1 group 5 ('+DATA','+FRA') size 50M;

alter database add standby logfile thread 1 group 6 ('+DATA','+FRA') size 50M;

alter database add standby logfile thread 1 group 7 ('+DATA','+FRA') size 50M;

alter database add standby logfile thread 2 group 8 ('+DATA','+FRA') size 50M;

alter database add standby logfile thread 2 group 9 ('+DATA','+FRA') size 50M;

alter database add standby logfile thread 2 group 10 ('+DATA','+FRA') size
50M;

备端创建standby redologs：

SQL> ALTER DATABASE ADD STANDBY LOGFILE THREAD 1

GROUP 5 ('+DATADG') SIZE 50M,

GROUP 6 ('+DATADG') SIZE 50M,

GROUP 7 ('+DATADG') SIZE 50M;

SQL> ALTER DATABASE ADD STANDBY LOGFILE THREAD 2

GROUP 8 ('+DATADG') SIZE 50M,

GROUP 9 ('+DATADG') SIZE 50M,

GROUP 10 ('+DATADG') SIZE 50M;

## 11、备端同步主端的归档日志

备端恢复数据文件完成后，开启介质恢复进程，将主库的归档日志恢复到备库。11G使用后不能开启Active Data Guard，两个选其一

启动

SQL> alter database recover managed standby database disconnect from session;

切换主库归档，观察备库归档日志同步是否正常。

SQL> alter system archive log current;

关闭

SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;

## 12、备端开启和关闭Active Data Guard

此步骤仅限11G

如果开启了第7步的介质恢复进程，需要先关闭介质恢复进程

SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;

启动

SQL> ALTER DATABASE OPEN READ ONLY;

SQL> RECOVER MANAGED STANDBY DATABASE DISCONNECT USING CURRENT LOGFILE;

关闭

SQL> RECOVER MANAGED STANDBY DATABASE CANCEL;

## 13、备端向CRS注册数据库服务

 **声明：** 备端仅一个实例运行，备端RAC中的其他实例处于shutdown状态

10G，以oracle用户执行以下命令

添加数据库服务

$ srvctl add database -d orcldg -n orcl -o /u01/app/oracle/product/10.2.0/db_1
-p +DATADG/orcldg/spfileorcldg.ora -r PHYSICAL_STANDBY

$ srvctl add instance -d orcldg -i orcldg1 -n racdg1

$ srvctl add instance -d orcldg -i orcldg2 -n racdg2

启动数据库

$ srvctl start database -d orcldg -o mount

在RAC其中一个节点上开启介质恢复进程，此进程只能在一个节点上存在，所以另外一个节点可以关闭。

SQL> alter database recover managed standby database disconnect from session;

11G，以oracle用户执行以下命令

添加数据库服务

$ srvctl add database -d orcldg -n orcl -o /u01/app/oracle/product/11.2.0/db_1
-p +DATADG/orcldg/parameterfile/spfileorcldg.ora -r physical_standby -a
DATADG,FRADG

$ srvctl add instance -d orcldg -i orcl1 -n racdg1

$ srvctl add instance -d orcldg -i orcl1 -n racdg2

启动数据库

$ srvctl start database -d orcldg

开启Active Data Guard

SQL> RECOVER MANAGED STANDBY DATABASE DISCONNECT USING CURRENT LOGFILE;

## 14、查询同步情况

此查询10G和11G都可以使用。

主端查询

SQL> select thread#, max(sequence#) from v$archived_log  group by thread#;

   THREAD# MAX(SEQUENCE#)

\---------- --------------

         1             10

         2              9

备端查询

SQL> select thread#,max(sequence#) from v$archived_log where applied='YES'
group by thread#;

   THREAD# MAX(SEQUENCE#)

\---------- --------------

         1              9

         2              9

此查询仅限11G Active Data Guard

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

## 16、Switchover

1\. 检查主库和备库的参数设置

2\. 确保主库设置了以下参数

SQL> alter system set
DB_FILE_NAME_CONVERT='+DATADG/orcldg/datafile/','+DATA/orcl/datafile/' sid=’*’
scope=spfile;

SQL> alter system set
LOG_FILE_NAME_CONVERT='+DATADG/orcldg/onlinelog/','+DATA/orcl/onlinelog/'
sid=’*’ scope=spfile;

3\. 确保主库创建了standby logfile联机redo日志文件

SQL> select * from v$standby_log;

4\. 确保compatible主库和备库相同

5\. 确保Managed Recovery运行在备库，且主备端同步正常

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

6\. 确保主库 LOG_ARCHIVE_DEST_2 日志recover状态是“REAL TIME APPLY”

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

SQL> SELECT RECOVERY_MODE FROM V$ARCHIVE_DEST_STATUS WHERE DEST_ID=2;

RECOVERY_MODE

\-----------------------

MANAGED

11G 开启只读模式：

SQL> SELECT RECOVERY_MODE FROM V$ARCHIVE_DEST_STATUS WHERE DEST_ID=2;

RECOVERY_MODE

\-----------------------

MANAGED REAL TIME APPLY

7\. 检查LOG_ARCHIVE_MAX_PROCESSES，仅限11G

LOG_ARCHIVE_MAX_PROCESSES 参数设置为4或更高，注意不要设置过高，此参数可以通过 ALTER SYSTEM 动态修改。

SQL> show parameter LOG_ARCHIVE_MAX_PROCESSES

NAME                                 TYPE        VALUE

\------------------------------------ -----------
------------------------------

log_archive_max_processes            integer     4

8\. 检查主库和备库的临时表空间和所有的数据文件是否为ONLINE状态

关于备库上的每个临时表空间，验证与主库上的表空间相关联的临时表空间也存在于备库上。

SQL> SELECT TMP.NAME FILENAME, BYTES, TS.NAME TABLESPACE

FROM V$TEMPFILE TMP, V$TABLESPACE TS WHERE TMP.TS#=TS.TS#;  

主端

FILENAME                            BYTES TABLESPACE

\------------------------------ ---------- ------------------------------

+DATA/orcl/datafile/temp01.dbf            30408704 TEMP

备端

FILENAME                           BYTES TABLESPACE

\-------------------------------- ---------- ------------------------------

+DATADG/orcldg/datafile/temp01.dbf   20971520 TEMP

如果查询不匹配，可以在打开新的主库后再纠正。

在备端查询数据文件状态

SQL> SELECT NAME FROM V$DATAFILE WHERE STATUS=’OFFLINE’;

如果有任何OFFLINE 数据文件，切换后将其ONLINE：

SQL> ALTER DATABASE DATAFILE 'datafile-name' ONLINE;

9\. 清除可能受阻的参数与jobs

主端查看当前job的状态

SQL> SELECT * FROM DBA_JOBS_RUNNING;

SQL> SELECT OWNER, JOB_NAME, START_DATE, END_DATE, ENABLED FROM

DBA_SCHEDULER_JOBS WHERE ENABLED='TRUE' AND OWNER <> 'SYS';

SQL> SHOW PARAMETER job_queue_processes

锁定jobs

SQL> ALTER SYSTEM SET job_queue_processes=0 SCOPE=BOTH SID='*';

禁止可能干扰切换的job

SQL> EXECUTE DBMS_SCHEDULER.DISABLE( <job_name> );

10\. 打开Data Guard 主库和备库的日志跟踪

主库和备库查询跟踪级别

SQL> SHOW PARAMETER log_archive_trace

NAME                                 TYPE        VALUE

\------------------------------------ -----------
------------------------------

log_archive_trace                    integer     0  

设置Data Guard的跟踪级别8191在主和目标物理备用数据库

SQL> ALTER SYSTEM SET log_archive_trace=8191;

查看alter日志

10G：

SQL> SHOW PARAMETER background_dump_dest

NAME                                 TYPE        VALUE

\------------------------------------ -----------
------------------------------

background_dump_dest                 string
/u01/app/oracle/admin/orcl/bdump

11G

SQL> SHOW PARAMETER background_dump_dest

NAME                                 TYPE        VALUE

\------------------------------------ -----------
------------------------------

background_dump_dest            string
/u01/app/oracle/diag/rdbms/orcl/orcl/trace

[root@dgzhu trace]# tail -f alert_orcl.log

11\. 创建可靠还原点（可选）

SQL> show parameter DB_RECOVERY

NAME                                 TYPE        VALUE

\------------------------------------ -----------
------------------------------

db_recovery_file_dest                string

db_recovery_file_dest_size           big integer 0

SQL> ALTER SYSTEM SET DB_RECOVERY_FILE_DEST_SIZE=1G;

System altered.

SQL> ALTER SYSTEM SET DB_RECOVERY_FILE_DEST='+FRADG/flashback';

System altered.

SQL> show parameter DB_RECOVERY

NAME                                 TYPE        VALUE

\------------------------------------ -----------
------------------------------

db_recovery_file_dest                string      +FRADG/flashback

db_recovery_file_dest_size           big integer 1G

SQL> RECOVER MANAGED STANDBY DATABASE CANCEL;

Media recovery complete.

SQL> CREATE RESTORE POINT SWITCHOVER_START_GRP GUARANTEE FLASHBACK DATABASE;

Restore point created.

SQL> RECOVER MANAGED STANDBY DATABASE DISCONNECT USING CURRENT LOGFILE;

Media recovery complete.

SQL> col NAME format a30

col time format a40

set line 300

select NAME,SCN,TIME from v$restore_point;

   NAME                                  SCN TIME

\------------------------------ ----------
----------------------------------------

SWITCHOVER_START_GRP               987029 04-JUL-16 02.11.05.000000000 PM

主库创建还原点

SQL> CREATE RESTORE POINT SWITCHOVER_START_GRP GUARANTEE FLASHBACK DATABASE;

Restore point created.

12\. 确保主库可以切换为备库

SQL> SELECT SWITCHOVER_STATUS FROM V$DATABASE;

SWITCHOVER_STATUS

\--------------------

TO STANDBY

13.关闭主端和备端所有次要的实例，只留一个主实例

14\. 切换主库为 standby database

第一种情况

如果查询结果是SESSIONS ACTIVE：

SQL> ALTER DATABASE COMMIT TO SWITCHOVER TO PHYSICAL STANDBY WITH SESSION
SHUTDOWN;

如果查询结果是TO STANDBY

SQL> ALTER DATABASE COMMIT TO SWITCHOVER TO PHYSICAL STANDBY;

15\. 确保备库可以切换为主库

SQL> SELECT SWITCHOVER_STATUS FROM V$DATABASE;

SWITCHOVER_STATUS

\-----------------

TO PRIMARY

16\. 切换 standby database 为主库

第一种情况

如果查询结果是SESSIONS ACTIVE： 执行下面的：

SQL> ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY WITH SESSION SHUTDOWN;

如果查询结果是TO STANDBY

SQL> ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY;

17\. open新的主库

SQL> ALTER DATABASE OPEN;

启动其他节点实例

18\. 更正不匹配的临时表空间

19\. 重新启动新的备库

SQL> SHUTDOWN ABORT;

SQL> STARTUP MOUNT;

SQL> ALTER DATABASE OPEN READ ONLY;

SQL> RECOVER MANAGED STANDBY DATABASE DISCONNECT USING CURRENT LOGFILE;

如果是RAC，仅启动一个实例即可

20\. 收尾

SQL> ALTER SYSTEM SET log_archive_trace=0;

SQL> ALTER SYSTEM SET job_queue_processes=<value saved> scope=both sid=’*’

SQL> EXECUTE DBMS_SCHEDULER.ENABLE(<for each job name captured>);

SQL> DROP RESTORE POINT SWITCHOVER_START_GRP;

## 17、failover

检查主备端同步正常

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

 **1.** **传输归档日志**

如果主库可以mount，则在mount状态下执行以下步骤，如果不能mount则跳过这一步

SQL> alter system flush redo to '<target_db_name>';  

 ** _注：_** ** _target_db_name=_** ** _备端的_** ** _DB_UNIQUE_NAME_**

flush redo是在11gR2被引入的. 对于Data guard, 在故障切换时flush
redo可能是非常有用的，如果这个命令能成功将最后的redo应用到standby上，那么DG上将没有数据丢失。

如果需要执行此语句，在standby上的 redo apply必须是启动的，执行此命令的primary database必须是mouted
状态，不能open ,默认情况下 comfirm apply是这个语句的一部分，语句执行将会一直等待直到所有redo applied。

10G

主端和备端找出相差的归档日志，将主端两个节点未传输的归档日志传递至备端。

在备端手动注册缺失的归档日志：

alter database register physical logfile '/fra/arch/1_42_916276568.dbf';

alter database register physical logfile '/fra/arch/1_43_916276568.dbf';

alter database register physical logfile '/fra/arch/2_44_916276568.dbf';

2\. 备端关闭所有次要的实例，只留一个主实例

3\. 备端执行以下语句停止redo应用服务

SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;

4\. 备端执行以下语句发起故障转移操作：

SQL> alter database recover managed standby database finish force;

5\. 备端执行以下语句将备库转换为主库

SQL> ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY;

6\. 备端执行以下语句打开转换后的主库：

SQL> alter database open;

确认：

SQL> select database_role from v$database;

DATABASE_ROLE

\----------------

PRIMARY

7\. 转换后启动其他辅助实例

## 18、参数解释

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

Measure

Measure


---
### NOTE ATTRIBUTES
>Created Date: 2018-09-25 03:29:38  
>Last Evernote Update Date: 2018-10-01 15:33:46  
>author: YangKwong  
>source: desktop.win  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-指导手册-Oracle DataGaurd RAC对RAC安装.html  
>source-application: evernote.win32  