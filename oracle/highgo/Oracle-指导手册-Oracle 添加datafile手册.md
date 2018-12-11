# Oracle-指导手册-Oracle 添加datafile手册

# 瀚高技术支持管理平台

## 一、前期准备

添加数据文件，需要了解要添加的数据文件初始大小及自动扩展的最大值是否超出存储空间剩余量。

## 二、本地存储，ASM存储方式：

### 1、添加数据文件前检查当前数据文件情况，单机RAC相同

SQL> select
file_id,tablespace_name,file_name,bytes/1024/1024,status,autoextensible,maxbytes/1024/1024
from dba_data_files;

FILE_ID TABLESPACE_NAME FILE_NAME MB STATUS AUT MAXBYTES/1024/1024

\---------- --------------- ------- -------- ---------- --- ------------------

4 USERS /oradata/SGBDC/datafile/o1_mf_users_cdr4k6xw_.dbf 45 AVAILABLE YES
32767.9844

3 UNDOTBS1 /oradata/SGBDC/datafile/o1_mf_undotbs1_cdr4k6wr_.dbf 1905 AVAILABLE
YES 32767.9844

2 SYSAUX /oradata/SGBDC/datafile/o1_mf_sysaux_cdr4k6w4_.dbf 1050 AVAILABLE YES
32767.9844

1 SYSTEM /oradata/SGBDC/datafile/o1_mf_system_cdr4k6tj_.dbf 850 AVAILABLE YES
32767.9844

5 BDC /oradata/SGBDC/datafile/bdc_01.dbf 10093.25 AVAILABLE YES 32767.9844

6 TXBDC /oradata/SGBDC/datafile/TXBDC.dbf 8505 AVAILABLE YES 32767.9844

7 MPDBMASTER /oradata/SGBDC/datafile/MPDBMASTER.dbf 15 AVAILABLE YES
32767.9844

8 MPDBMASTER_INDX /oradata/SGBDC/datafile/MPDBMASTERidx01.dbf 20 AVAILABLE YES
32767.9844

9 TXBDC_INDX /oradata/SGBDC/datafile/TXBDCidx01.dbf 200 AVAILABLE YES
32767.9844

### 2、检查剩余空间：

存放在本地存储查询：

[root@rhel711g home]# df -h

Filesystem Size Used Avail Use% Mounted on

/dev/mapper/rhel-root 47G 3.0G 42G 7% /

devtmpfs 985M 0 985M 0% /dev

tmpfs 994M 136K 994M 1% /dev/shm

/dev/sda1 477M 83M 365M 19% /boot

/dev/mapper/oradata 500G 3.0G 497G 1% /oradata

存放在ASM存储查询:

sqlplus登录asm实例。

SQL> select GROUP_NUMBER,NAME,STATE,TYPE,TOTAL_MB,FREE_MB,USABLE_FILE_MB from
v$asm_diskgroup;

GROUP_NUMBER NAME STATE TYPE TOTAL_MB FREE_MB SABLE_FILE_MB

\------------ ------ --- -- ------ ---------- ---------- --------------

1 DATA MOUNTED EXTERN 512000 217802 217802

2 FLA MOUNTED EXTERN 512000 507006 507006

3 OCRVOT MOUNTED EXTERN 5120 4724 4724

空间足够，扩展TXBDC表空间。

### 4、添加数据文件

查询是否开启OMF:

SQL> show parameter db_create_file_dest

NAME TYPE VALUE

\------------------------------------ -----------

db_create_file_dest string +DATA

参数值非空即代表启用OMF，在确保该存储位置空间足够的情况下使用如下语句添加数据文件。

打开自动扩展的情况

alter tablespace TXBDC add datafile size 200M autoextend **on** ;

不开启自动扩展的情况

alter tablespace TXBDC add datafile size 200M autoextend **off** ;

如果db_create_file_dest值为空，则需要指定添加数据文件的具体位置和名称：

alter tablespace BDC add datafile '/oradata/SGBDC/datafile/bdc_02.dbf' size
200M autoextend on ;

原则上添加的数据文件与之前存在的数据文件大小一致，数据文件是否自动扩展也与之前存在的数据文件一致。

 **注意添加数据文件语句一定要明确指定** **autoextend [on/off]**
**，除非现有的数据文件都是采用非扩展的方式，否则打开文件自动扩展即可。**

## 三、裸设备存储方式

### 1、添加数据文件前检查当前数据文件情况：

SQL> select
file_id,tablespace_name,file_name,bytes/1024/1024,status,autoextensible,maxbytes/1024/1024
from dba_data_files;

FILE_ID TABLESPACE_NAME FILE_NAME BYTES/1024/1024 STATUS AUT
MAXBYTES/1024/1024

\---------------------------- --------------- ---------- ---

1 SYSTEM /dev/vgdata/rsystem_10g 10200 AVAILABLE NO 0

2 UNDOTBS1 /dev/vgdata/rundotbs1_20g 20400 AVAILABLE NO 0

3 SYSAUX /dev/vgdata/rsysaux_10g 10200 AVAILABLE NO 0

5 USERS /dev/vgdata/ruser01_10g 10200 AVAILABLE NO 0

32 HISRUN_HIS /dev/vgdata/rdata5g_038 5000 AVAILABLE NO 0

33 HISRUN_HIS /dev/vgdata/rdata5g_039 5000 AVAILABLE NO 0

34 HISRUN_HIS /dev/vgdata/rdata5g_040 5000 AVAILABLE NO 0

为表空间HISRUN_HIS添加数据文件。

检查物理卷组：

举例HPUX系统如下：

hostname#[~]vgdisplay -v /dev/vgdata

…………………………

LV Name /dev/vgdata/data5g_040

LV Status available/syncd

**LV Size (Mbytes) 5120**

Current LE 160

Allocated PE 160

Used PV 1

LV Name /dev/vgdata/data5g_041

LV Status available/syncd

**LV Size (Mbytes) 5120**

Current LE 160

Allocated PE 160

Used PV 1

……………………

hostname#[~]ls -al /dev/vgdata/r*

crw-rw---- 1 oracle oinstall 64 0x030015 May 23 2015
/dev/vgdata/rcontrol1_512m

crw-rw---- 1 oracle oinstall 64 0x030016 May 23 2015
/dev/vgdata/rcontrol2_512m

crw-rw---- 1 oracle oinstall 64 0x030017 May 23 2015
/dev/vgdata/rcontrol3_512m

crw-rw---- 1 oracle oinstall 64 0x03001a May 23 2015 /dev/vgdata/rdata5g_001

crw-rw---- 1 oracle oinstall 64 0x03001b May 23 2015 /dev/vgdata/rdata5g_002

crw-rw---- 1 oracle oinstall 64 0x03001c May 23 2015 /dev/vgdata/rdata5g_003

crw-rw---- 1 oracle oinstall 64 0x03001d May 23 2015 /dev/vgdata/rdata5g_004

crw-rw---- 1 oracle oinstall 64 0x03003f May 23 2015 /dev/vgdata/rdata5g_038

crw-rw---- 1 oracle oinstall 64 0x030040 May 23 2015 /dev/vgdata/rdata5g_039

 **crw-rw---- 1 oracle oinstall 64 0x030041 May 23 2015
/dev/vgdata/rdata5g_040**

 **crw-rw---- 1 oracle oinstall 64 0x030042 May 23 2015
/dev/vgdata/rdata5g_041**

crw-rw---- 1 oracle oinstall 64 0x030043 May 23 2015 /dev/vgdata/rdata5g_042

 **需要客户提供给我们可以用来存放新数据文件的LV** **。**

如果客户提供的lv是/dev/vgdata/rdata5g_041。

我们要自己确认检查确认/dev/vgdata/rdata5g_041未被控制文件，日志文件，数据文件占用。RAC还要确保未被OCR/Voting
Disk使用，因为在技术上，客户并不一定是对的：

SQL> select * from v$controlfile;

SQL> select * from v$logfile;

SQL> select * from dba_data_files where file_name='/dev/vgdata/rdata5g_041';

SQL> select * from dba_temp_files;

### 2、添加数据文件

确保数据文件大小比lv至少小10M， **禁用自动扩展：**

SQL> alter tablespace HISRUN_HIS add datafile '/dev/vgdata/rdata5g_070' **size
5000M autoextend off** ;

Tablespace altered.

### 3、检查当前数据文件情况：

SQL> select
file_id,tablespace_name,file_name,bytes/1024/1024,status,autoextensible,maxbytes/1024/1024
from dba_data_files;

FILE_ID TABLESPACE_NAME FILE_NAME BYTES/1024/1024 STATUS AUT
MAXBYTES/1024/1024

\---------- ------------------- ---------------------------- ---------------
---------- --- ------------------

1 SYSTEM /dev/vgdata/rsystem_10g 10200 AVAILABLE NO 0

2 UNDOTBS1 /dev/vgdata/rundotbs1_20g 20400 AVAILABLE NO 0

3 SYSAUX /dev/vgdata/rsysaux_10g 10200 AVAILABLE NO 0

5 USERS /dev/vgdata/ruser01_10g 10200 AVAILABLE NO 0

32 HISRUN_HIS /dev/vgdata/rdata5g_038 5000 AVAILABLE NO 0

33 HISRUN_HIS /dev/vgdata/rdata5g_039 5000 AVAILABLE NO 0

34 HISRUN_HIS /dev/vgdata/rdata5g_040 5000 AVAILABLE NO 0

35 HISRUN_HIS /dev/vgdata/rdata5g_041 5000 AVAILABLE NO 0

## 四、存在DATAGUARD

在备端查询以下参数：

SQL> show parameter standby_file_management

NAME TYPE VALUE

\-------------------------- -------- -----------

standby_file_management string AUTO

如果参数值是MANUAL，则要修改参数值为AUTO，否则主端同步过来的数据文件默认放到$ORACLE_HOME/dbs目录中，如：
**/u01/app/oracle/product/10.2.0/db_1/dbs/UNNAMED00009**

。

修改命令: alter system set standby_file_management=auto;

 **检查备机参数 db_create_file_dest** **，如果参数有值则备机会优先在db_create_file_dest**
**中创建文件。**

 **如db_create_file_dest** **没值，则检查db_file_name_convert**
**，备机会优先在db_file_name_convert** **中创建文件，如果以上两个参数都没有设置，或者db_file_name_convert**
**的值中不包含主端新建数据文件的路径，则会尝试创建和主端路径和文件名字一样的数据文件，如果路径中子目录不存在，则会主动尝试创建，如果因文件夹权限等原因无法创建成功，那文件会默认放到$ORACLE_HOME/dbs**
**目录下，并以UNNAMED0000X** **格式命名，此时备机的mrp0** **进程会终止，同步会中断。**

 **所以主端创建数据文件前需要检查备端以上三个参数的值是否妥当，避免数据文件同步失败而导致dg** **同步中断。**

 **如果已经出现了UNNAMED0000X** **在dbs** **下，并同步失败的情况，应该如何处理？**

SQL> select name from v$datafile;

NAME

\------------------------------------------------------

/oradata/orac/system01.dbf

/oradata/orac/undotbs01.dbf

/oradata/orac/sysaux01.dbf

/oradata/orac/users01.dbf

/oradata/orac/system02.dbf

/oradata/orac/undotbs02.dbf

/oradata/orac/sysaux02.dbf

/oradata/orac/users02.dbf

 **/u01/app/oracle/product/10.2.0/db_1/dbs/UNNAMED00009**

9 rows selected.

在出现如上情况是，备端mrp0进程会无法启动，dg将不能同步。

 **解决方法：**

备端修改standby_file_management为手动

alter system set standby_file_management=manual;

转换数据文件

alter database create datafile
'/u01/app/oracle/product/10.2.0/db_1/dbs/UNNAMED00009' as
'/oradata/orac/users03.dbf';

备端修改standby_file_management为自动

alter system set standby_file_management=auto;

启动恢复进程MRP0

alter database recover managed standby database using current logfile
disconnect from session;

备端再次查询当前数据文件正常：

SQL> select name from v$datafile;

NAME

\---------------------------------------------------------/oradata/orac/system01.dbf

/oradata/orac/undotbs01.dbf

/oradata/orac/sysaux01.dbf

/oradata/orac/users01.dbf

/oradata/orac/system02.dbf

/oradata/orac/undotbs02.dbf

/oradata/orac/sysaux02.dbf

/oradata/orac/users02.dbf

/oradata/orac/users03.dbf

9 rows selected.

Measure

Measure



---
### TAGS
{Support20180830}

---
### NOTE ATTRIBUTES
>Created Date: 2018-08-30 02:09:51  
>Last Evernote Update Date: 2018-10-01 15:33:57  
>source: web.clip7  
>source-url: https://47.100.29.40/highgo_admin/#/index/docSearchDetail/17d83b0402032d  
>source-application: WebClipper 7  