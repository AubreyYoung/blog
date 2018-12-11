# Oracle-指导手册-Oracle 12C rman备份脚本部署手册

# 瀚高技术支持管理平台

# 概述

数据库处于归档模式下才能使用rman备份，rman备份可以通过shell或者DOS脚本来定时完成，也可以通过第三方的备份软件来完成，如康孚、Network、Tsm等，此类备份软件往往都是备份到带库上，并且由专业公司人员负责维护，一般不需要DBA进行运维。

此文档用于指导部署rman备份脚本。

适用Oracle 12C

# 部署脚本及注意事项

（1）部署RMAN备份前，需要开启数据库归档模式；12C
RAC开启归档模式时，无需设置cluster_database=false，直接将数据库启动到mount即可，如下：

$ srvctl start database –d orcl –o mount

SQL> alter database archivelog;

SQL> alter database open;

（2）使用backup database，命令会同时备份CDB和PDB。

##  **1、Linux 12C RMAN备份脚本**

全库备份文件内容rmanback0.sh：

#!/bin/bash

ORACLE_SID=ORCL1

ORACLE_HOME=/u01/app/oracle/product/12.2.0/dbhome_1

ORACLE_BASE=/u01/app/oracle

export ORACLE_SID=$ORACLE_SID

export ORACLE_HOME=$ORACLE_HOME

export ORACLE_BASE=$ORACLE_BASE

backtime=`date +%Y%m%d`

echo $backtime

$ORACLE_HOME/bin/rman log=/oracle/rmanbak/log/node1_backupall_$backtime.log
<<EOF

connect target /

run{

allocate channel c1 type disk ;

allocate channel c2 type disk ;

backup incremental level 0 FORMAT '/rmanbak/ORCL/full_db_%d_%T_%u_%p' database
include current controlfile ;

sql 'alter system archive log current';

backup FORMAT '/rmanbak/ORCL/arch_%d_%T_%u_%p' archivelog all not backed up
delete input;

report obsolete;

delete noprompt obsolete;

crosscheck backup;

crosscheck archivelog all;

delete noprompt expired backup;

release channel c1;

release channel c2;

}

EOF

echo "backup complete!"

exit

## **2** **、** **Windows 12C rman备份脚本**

@echo off

set oracle_sid=orcl

set da=%date:~0,4%%date:~5,2%%date:~8,2%1

set oraclepath="E:\app12c\Administrator\virtual\product\12.2.0\dbhome_1"

%oraclepath%\bin\rman target / msglog d:\DB_backup\Oracle_DB\rmanlog\%da%.log
cmdfile=d:\DB_backup\Oracle_DB\sql.rman

rman 配置文件sql.rman内容如下：

run{

allocate channel c1 type disk ;

allocate channel c2 type disk ;

backup incremental level 0 FORMAT 'E:\bak\orcl_full_%d_%T_%u_%p' database
include current controlfile ;

sql 'alter system archive log current';

backup FORMAT 'E:\bak\arch_full_%d_%T_%u_%p' archivelog all not backed up
delete input;

report obsolete;

delete noprompt obsolete;

crosscheck backup;

crosscheck archivelog all;

delete noprompt expired backup;

release channel c1;

release channel c2;

}

## **3** **、12C 常用备份与恢复命令**

###  **1** **）只备份CDB**

只备份CDB数据库需要具有SYSDBA或SYSBACKUP权限用户连接到CDB的root环境下，执行backupdatabase
root命令即可完成对CDB的备份，方法如下：

RMAN> backupdatabase root;

###  **2** **）备份整个CDB及其下面的所有PDB：**

备份整个CDB数据库及其下面的所有PDB类似于非CDB数据库方法相同，使用具有SYSDBA或SYSBACKUP权限用户连接到CDB的root环境下面，然后执行backupdatabase命令即可完成整个CDB的备份，方法如下：

RMAN> backup database;

###  **3** **）备份单个和多个PDB：**

（1）在CDB中允许备份一个或多少PDB数据库，备份一个PDB数据库可以通过以下两个方式备份：

在CDB根（root）使用BACKUP PLUGGABLE DATABASE命令备份一个或多个PDB数据库。

$ rman target /

RMAN> backup pluggable database pdb1;

（2）如果要备份多个pdb,只需在备份命令后面跟上多个你想备份的pdb实例的名称，如下：

RMAN> backup pluggable database pdb1,pdb2;

（3）在PDB中使用BACKUP DATABASE备份当前连接的PDB数据库，前提条件是需要配置好TNSNAMES.ORA文件。

$ rman target sys/oracle@pdb1

RMAN> backup database;

###  **4** **）整体数据库恢复（CDB和所有PDB）**

12C数据库加强了RMAN恢复的功能，恢复的方式基本同以前的模式一样，如果是在一个全新的异地进行恢复，同样的也是先手工创建与原库相同的CDB和PDB实例，然后关闭实例，删除所有数据文件，通过RMAN命令或者拷贝原始库的控制文件到新库上，启动CDB数据库到mount状态，如下

$rman target /

RMAN>startup mount;

RMAN>restore database;

RMAN>recover database;

###  **5** **）单个PDB数据库恢复**

恢复单个PDB的前提是CDB已经能够正常启动，在CDB启动的情况下在RMAN中采用restore pluggable database
pdb名称指定单个PDB数据库进行恢复，如下

RMAN>restore pluggable database orcl;

RMAN>recover pluggable database orcl;

最后，在以restlogs方式，打开pdb实例，如下

SQL>conn / as sysdba

已连接。

SQL>show pdbs

CON_ID CON_NAME OPEN MODE RESTRICTED

\---------------------------------------- ---------- ----------

2 PDB$SEED READ ONLY NO

3 ORCL MOUNTED

4 ZLEMR MOUNTED

SQL>alter pluggable database pdb1 orcl resetlogs;

插接式数据库已变更。

SQL>show pdbs

CON_ID CON_NAME OPEN MODE RESTRICTED

\---------------------------------------- ---------- ----------

2 PDB$SEED READ ONLY NO

3 ORCL READ WRITE NO

4 ZLEMR MOUNTED

###  **6** **）恢复PDB数据文件**

 **数据库在open的时候，会对当前的数据的所有数据文件进行检查。**

**对于system,sysaux和undo表空间的数据文件，如果有问题，数据库无法open。如果是PDB中某个普通的数据文件出现丢失，我们可以先用offline方式跳过，然后再打数据库,稍后再对数据文件做恢复:**

 **例:**

SQL> startup;

ORACLE instance started.

Total System Global Area 835104768 bytes

Fixed Size 2293880 bytes

Variable Size 322965384 bytes

Database Buffers 503316480 bytes

Redo Buffers 6529024 bytes

Database mounted.

ORA-01157: cannot identify/lock data file 6- see DBWR trace file

ORA-01110: data file 6:'/u01/app/oracle/oradata/c12/users01.dbf'

SQL> alter database datafile 6 offline;

Database altered.

SQL> alter database open;

Database altered.

使用rman

RMAN> restore datafile 6;

RMAN> recover datafile 6;

然后对数据文件进行online处理

SQL> alter database datafile 6 online;

再看看pdb的数据文件.摸拟pdb数据文件删除

[oracle@o12c pdb2]$ mv pdb2_users01.dbfpdb2_users01.dbfold

启动数据库实例

SQL> startup;

ORACLE instance started.

Total System Global Area 835104768 bytes

Fixed Size 2293880 bytes

Variable Size 322965384 bytes

Database Buffers 503316480 bytes

Redo Buffers 6529024 bytes

Database mounted.

Database opened.

 **由此我们可以得出一个结论，当cdb在打开的时候，数据库不会检查pdb中的数据文件。**

SQL> alter pluggable database pdb2 open;

alter pluggable database pdb2 open

ERROR at line 1:

ORA-01157: cannot identify/lock data file 13- see DBWR trace file

ORA-01110: data file 13:'/u01/app/oracle/oradata/c12/pdb2/pdb2_users01.dbf'

 **只有在打开pluggabledatabase时，会效验PDB数据库的数据文件，。**

SQL> alter session set container=pdb2;

Session altered.

SQL> alter pluggable database datafile 13 offline;

Pluggable database altered.

**数据文件file#(文件号)是唯一的，但我们在CDB中操作时找不到该文件，必须要进入PDB模式，如果在CDB试图去offline一个数据文件时会报错：**

SQL> show con_name

CON_NAME

\------------------------------

CDB$ROOT

SQL> alter database datafile 10 offline;

alter database datafile 10 offline

第 1 行出现错误:

ORA-01516: 不存在的日志文件, 数据文件或临时文件 "10"*

但是在rman中可以直接使用datafile号进行恢复

[oracle@localhost admin]$ rman target /

恢复管理器: Release 12.1.0.2.0 - Production on 星期三 3月 23 11:04:15 2016

Copyright (c) 1982, 2014, Oracle and/or itsaffiliates. All rights reserved.

已连接到目标数据库: CDB (DBID=2023252752)

RMAN> restore datafile 10;

启动 restore 于 23-3月 -16

使用通道 ORA_DISK_1

通道 ORA_DISK_1: 正在开始还原数据文件备份集

通道 ORA_DISK_1: 正在指定从备份集还原的数据文件

通道 ORA_DISK_1: 将数据文件 00010 还原到
/u01……/backupset/2016_03_23/o1_mf_nnndf_TAG20160323T100113_ch3y7byj_.bkp

通道 ORA_DISK_1: 段句柄 =
/u01…….backupset/2016_03_23/o1_mf_nnndf_TAG20160323T100113_ch3y7byj_.bkp标记 =
TAG20160323T100113

通道 ORA_DISK_1: 已还原备份片段 1

通道 ORA_DISK_1: 还原完成, 用时: 00:00:01

完成 restore 于 23-3月 -16

RMAN> recover datafile 10;

启动 recover 于 23-3月 -16

使用通道 ORA_DISK_1

正在开始介质的恢复

介质恢复完成, 用时: 00:00:00

完成 recover 于 23-3月 -16;

Measure

Measure



---
### TAGS
{Support20180830}

---
### NOTE ATTRIBUTES
>Created Date: 2018-08-30 01:37:57  
>Last Evernote Update Date: 2018-10-01 15:33:59  
>source: web.clip7  
>source-url: https://47.100.29.40/highgo_admin/#/index/docSearchDetail/3bc92f0196e225  
>source-application: WebClipper 7  