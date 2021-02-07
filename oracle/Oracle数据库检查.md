

[TOC]

# **Oracle数据库检查**

## 1.1 Oracle实例运行时间

```plsql
col running format a30
select to_char(startup_time, 'DD-MON-YYYY HH24:MI:SS') starttime,
TRUNC(sysdate - (startup_time)) || 'days' ||TRUNC(24 *((sysdate - startup_time) - TRUNC(sysdate - startup_time))) ||'hours' || MOD(TRUNC(1440 * ((SYSDATE - startup_time) -TRUNC(sysdate - startup_time))),
60) || 'min' ||MOD(TRUNC(86400 *((SYSDATE - STARTUP_TIME) - TRUNC(SYSDATE - startup_time))),60) || 's' running
from gv$instance;

-- RAC
alter session set NLS_DATE_FORMAT='YYYY-MM-DD HH24:MI:SS';
select INSTANCE_NUMBER,INSTANCE_NAME,HOST_NAME,STARTUP_TIME ,STATUS from sys.gv_$instance; 

```

**强制关库**

```plsql
手动强制清理oracle用户相关资源。以root用户结束Oracle所有进程。
# ps -fu oracle|grep -v grep| awk '{print $2}' |xargs kill -9
以root用户删除Oracle所有共享内存。生成删除共享内存和信号量的语句:
ipcs  -a 进程间通信的信息
共享内存：ipcs -m|grep oracle|grep -v grep| awk '{printf"ipcrm -m %s;\n", $2}'
信号量：ipcs -s|grep oracle|grep -v grep| awk '{printf"ipcrm -s %s;\n", $2}'
执行上面两个语句生成的命令，然后执行ipcs -a|grep oracle命令查看是否还有相关结果。以oracle用户删除“/dev/shm”下面的共性内存数据。
% ls -alt /dev/shm/ora_${ORACLE_SID}_*
上面查询如果有结果执行删除：
% rm /dev/shm/ora_${ORACLE_SID}_*
清理锁文件：“$ORACLE_HOME/dbs/”目录下的“lk<sid>”与“sgadef<sid>.dbf”文件。
ls -alt $ORACLE_HOME/dbs/lk*
ls -alt $ORACLE_HOME/dbs/sgadef*
例如：
oracle@linux220:/opt/oracle/product/11gR2/db/dbs> ls -alt $ORACLE_HOME/dbs/lk*
-rw-r----- 1 oracle oinstall 24 2014-05-19 14:42 /opt/oracle/product/11gR2/db/dbs/lkOR
```



## 1.2  查看cursors

**查询session_cached_cursors和 open_cursors 的使用率(每个实例)**

```plsql
col value for a15
col usage for a15
select 'session_cached_cursors' parameter,
lpad(value, 5) value,decode(value, 0, ' n/a', to_char(100 * used / value, '990') || '%') usage
from (select max(s.value) used from v$statname n, v$sesstat s
where n.name = 'session cursor cache count'
and s.statistic# = n.statistic#),(select value from v$parameter where name = 'session_cached_cursors')
union all
select 'open_cursors',lpad(value, 5),to_char(100 * used / value, '990') || '%'
from (select max(sum(s.value)) used from v$statname n, v$sesstat s where n.name in ('opened cursors current')
and s.statistic# = n.statistic# group by s.sid),
(select value from v$parameter where name = 'open_cursors');

-- 查看用户的cursor使用
SELECT A.USER_NAME, COUNT(*) FROM V$OPEN_CURSOR A GROUP BY A.USER_NAME; 

-- 查看终端的cursor使用
SELECT AA.USERNAME, AA.MACHINE, SUM(AA.VALUE) 
 FROM (SELECT A.VALUE, S.MACHINE, S.USERNAME 
 FROM V$SESSTAT A, V$STATNAME B, V$SESSION S 
 WHERE A.STATISTIC# = B.STATISTIC# 
 AND S.SID = A.SID 
 AND B.NAME = 'session cursor cache count') AA 
 GROUP BY AA.USERNAME, AA.MACHINE 
 ORDER BY AA.USERNAME, AA.MACHINE; 

-- 查看cursors的会话
SELECT a.inst_id,
     a.sid,
     a.USERNAME,
     a.SCHEMANAME,
     a.OSUSER,
     a.machine,
     a.TERMINAL,
     a.LOGON_TIME,
     a.PROGRAM,
     a.STATUS,
     b.name,
     b.used
FROM gv$session a,
     (SELECT n.inst_id,
             sid,
             n.name,
             s.VALUE used
        FROM gv$statname n, gv$sesstat s
       WHERE     n.name IN ('opened cursors current',
                            'session cursor cache count')
             AND s.statistic# = n.statistic#
             AND n.inst_id = s.inst_id) b
WHERE     a.sid = b.sid
     AND a.inst_id = b.inst_id
     AND b.name <> 'session cursor cache count'
ORDER BY b.used DESC;


--查看cursors的SQLID
SELECT distinct a.inst_id,
         a.sid,
         a.USERNAME,
         a.SCHEMANAME,
         a.OSUSER,
         a.machine,
         a.TERMINAL,
         a.LOGON_TIME,
         a.PROGRAM,
         a.STATUS,
         b.name,
         b.used,c.sql_id
  FROM   gv$session a,
         (SELECT   n.inst_id, sid, n.name, s.VALUE used
            FROM   gv$statname n, gv$sesstat s
           WHERE   n.name IN
                         ('opened cursors current',
                          'session cursor cache count')
                   AND s.statistic# = n.statistic# and n.inst_id=s.inst_id ) b,v$open_cursor c
 WHERE   a.sid = b.sid and a.inst_id = b.inst_id and a.sid=c.sid and c.CURSOR_TYPE in('OPEN','OPEN-PL/SQL','OPEN-RECURSIVE')
 and b.name <> 'session cursor cache count'
 order by b.used desc;
```

## 1.3 ASM rbal进程内存泄露检查

以下检查针对所有平台的11.2.0.4 RAC环境：

Oracle 11.2.0.4版本的RAC，ASM的rbal后台进程存在内存泄露的情况，将可能导致宕机，此问题影响了包括HPUX/AIX/LINUX等在内的操作系统。
建议按照下列方法全面梳理是否存在该情况，并增加进程一级内存使用情况的监控。

```
ps -elf |grep -i asm_rbal
ps -elf|grep osw
或
ps aux
```

正常而言在100M以上，通过比对ASM的其他后台进程即可知晓
select * from v$version

- 查看asm alert 日志中是否出现下列信息
  针对11.2.0.4 RAC ASM的rbal后台进程存在内存泄露的问题，说明如下：

1. 早在2016年初，ORACLE GCS和ACS部门就处理过几个客户的类似问题（包括文中的客户），所以这并不是一个近期突发的普遍问题，大家大可不必惊慌；
2. 故障根因是由于触发Bug 13904435导致了RBAL内存持续增长，workaround方法早就在文档1457886.1上提供，有条件的同学可以自己去检查实施，一劳永逸；
3. 如果还是担心，可以检查一下当前的RBAL进程内存消耗，没有发现异常增长就OK，因为问题触发只在MOUNT DG时，如果当时触发了就可能出现RBAL内存持续增长，如果当时没发生后面也不会再发生。

## 1.4 检查ASM磁盘组空间

```plsql
Set pagesize 100
Set linesize 180
Col name format a15
select GROUP_NUMBER,NAME,STATE,TYPE,TOTAL_MB/1024,FREE_MB/1024,USABLE_FILE_MB/1024 from v$asm_diskgroup;

set pagesize 200
set linesize 150
col path format a60;
col group_name format a10
col name format a20
select a.group_number,b.name as group_name,a.name,a.path,a.state,a.total_mb/1024 from v$asm_disk a,v$asm_diskgroup b where a.group_number=b.group_number;

-- 查看ASM磁盘组使用率
select name,round(total_mb/1024) "总容量",round(free_mb/1024) "空闲空间",round((free_mb/total_mb)*100) "可用空间比例" from gv$asm_diskgroup;

col name for a20
col STATE for a10      
col COMPATIBILITY for a20
col DATABASE_COMPATIBILITY for a30
select GROUP_NUMBER,name,STATE,TYPE,COMPATIBILITY,DATABASE_COMPATIBILITY from v$asm_diskgroup;

SELECT DG.NAME AS DISKGROUP, SUBSTR(C.INSTANCE_NAME,1,12) AS INSTANCE,
SUBSTR(C.DB_NAME,1,12) AS DBNAME, SUBSTR(C.SOFTWARE_VERSION,1,12) AS SOFTWARE,
SUBSTR(C.COMPATIBLE_VERSION,1,12) AS COMPATIBLE
FROM V$ASM_DISKGROUP DG, V$ASM_CLIENT C
WHERE DG.GROUP_NUMBER = C.GROUP_NUMBER;

SELECT CONCAT('+'||GNAME, SYS_CONNECT_BY_PATH(ANAME, '/'))
 FULL_PATH, SYSTEM_CREATED, ALIAS_DIRECTORY, FILE_TYPE
 FROM ( SELECT B.NAME GNAME, A.PARENT_INDEX PINDEX,
 A.NAME ANAME, A.REFERENCE_INDEX RINDEX,
 A.SYSTEM_CREATED, A.ALIAS_DIRECTORY,
 C.TYPE FILE_TYPE
 FROM V$ASM_ALIAS A, V$ASM_DISKGROUP B, V$ASM_FILE C
 WHERE A.GROUP_NUMBER = B.GROUP_NUMBER
 AND A.GROUP_NUMBER = C.GROUP_NUMBER(+)
 AND A.FILE_NUMBER = C.FILE_NUMBER(+)
 AND A.FILE_INCARNATION = C.INCARNATION(+)
 )
 START WITH (MOD(PINDEX, POWER(2, 24))) = 0
 CONNECT BY PRIOR RINDEX = PINDEX;

SELECT GROUP_NUMBER, DISK_NUMBER, MOUNT_STATUS, HEADER_STATUS, MODE_STATUS, STATE, OS_MB, TOTAL_MB, FREE_MB, NAME, FAILGROUP, PATH
FROM V$ASM_DISK ORDER BY GROUP_NUMBER, FAILGROUP, DISK_NUMBER;

SELECT * FROM V$ASM_DISK ORDER BY GROUP_NUMBER,DISK_NUMBER;

SELECT * FROM V$ASM_ATTRIBUTE;

SELECT * FROM V$ASM_OPERATION;
SELECT * FROM GV$ASM_OPERATION;

SELECT * FROM V$VERSION;

SELECT * FROM V$ASM_ACFSSNAPSHOTS;
SELECT * FROM V$ASM_ACFSVOLUMES;
SELECT * FROM V$ASM_FILESYSTEM;
SELECT * FROM V$ASM_VOLUME;
SELECT * FROM V$ASM_VOLUME_STAT;

SELECT * FROM V$ASM_USER;
SELECT * FROM V$ASM_USERGROUP;
SELECT * FROM V$ASM_USERGROUP_MEMBER;

SELECT * FROM V$ASM_DISK_IOSTAT;
SELECT * FROM V$ASM_DISK_STAT;
SELECT * FROM V$ASM_DISKGROUP_STAT;

SELECT * FROM V$ASM_TEMPLATE;

SELECT * FROM V$ASM_CLIENT;

--DISPLAYS INFORMATION ABOUT THE CONTENTS OF THE SPFILE.
SELECT * FROM V$SPPARAMETER ORDER BY 2;
SELECT * FROM GV$SPPARAMETER ORDER BY 3;

--DISPLAYS INFORMATION ABOUT THE INITIALIZATION PARAMETERS THAT ARE CURRENTLY IN EFFECT IN THE INSTANCE.
SELECT * FROM V$SYSTEM_PARAMETER ORDER BY 2;
SELECT * FROM GV$SYSTEM_PARAMETER ORDER BY 3;

-- ASM alias
select * from v$asm_file;
select * from v$asm_alias;


-- 12C ASM AUDIT VIEWS
SELECT * FROM V$ASM_AUDIT_CLEAN_EVENTS;
SELECT * FROM V$ASM_AUDIT_CLEANUP_JOBS;
SELECT * FROM V$ASM_AUDIT_CONFIG_PARAMS;
SELECT * FROM V$ASM_AUDIT_LAST_ARCH_TS;

-- 12C ASM ESTIMATE VIEW
SELECT * FROM V$ASM_ESTIMATE;
SELECT * FROM GV$ASM_ESTIMATE;
```

```plsql
alter diskgroup data add disk '/dev/raw/raw41' name DATA_0001,'/dev/raw/raw42' name DATA_0002,'/dev/raw/raw43' name DATA_0003 drop disk DATA_0000,DATA_0004,DATA_0005 rebalance power 11;

-- 挂在磁盘组
alter diskgroup data mount;

固态表X$KFGMG的REBALST_KFGMG字段会显示为2，代表正在compacting。
select NUMBER_KFGMG, OP_KFGMG, ACTUAL_KFGMG, REBALST_KFGMG from X$KFGMG;

select GROUP_NUMBER,OPERATION,POWER,EST_WORK,EST_RATE,EST_MINUTES from gv$asm_operation;

-- ASM OCR 添加,删除
Adding new storage disks and Dropping old storage disks from OCR ,Vote diskgroup (Doc ID 2073993.1) 
alter diskgroup ocr add disk '/dev/raw/raw33';
alter diskgroup ocr drop disk '/dev/raw/raw1';
```

**ASMCMD**

```plsql
-- Lists the contents of an Oracle ASM directory, the attributes of the specified file, or the names and attributes of all disk groups.
asmcmd -p ls
-- Lists the attributes of a disk group.
asmcmd -p lsattr
-- Lists information about current Oracle ASM clients.
asmcmd -p lsct
-- Lists disk groups and their information.
asmcmd -p lsdg
-- Lists disks Oracle ASM disks.
asmcmd -p lsdsk
-- Lists the open files.
asmcmd -p lsof
-- Lists open devices.
asmcmd -p lsod
-- Displays I/O statistics for disks.
asmcmd -p iostat
-- Retrieves the discovery diskstring value that is used by the Oracle ASM instance and its clients.
asmcmd -p dsget
-- Lists the current operations on a disk group or Oracle ASM instance.
asmcmd -p lsop
-- Retrieves the location of the Oracle ASM SPFILE.
asmcmd -p spget
-- Lists disk group templates.
asmcmd -p lstmpl
-- Lists users in a disk group.
asmcmd -p lsusr
-- Lists user groups.
asmcmd -p lsgrp
-- Lists the users from an Oracle ASM password file.
asmcmd -p lspwusr
-- Displays information about Oracle ADVM volumes.
asmcmd -p volinfo
```

## 1.5 日志大小

检查监听日志及alert日志文件大小,审计日志

**Windows**
进入监听文件及alert目录，检查listener.log大小
**Linux**,Solrias

```
find / -name "*listener*.log*" | xargs du -h
find / -name "alert*.log*" | xargs du -h
```

[^说明]: Windows下操作系统日接近或者大于4GB时，会造成数据库连接中断或者无法连接的现象；但在某些低版本的数据库中，listener.log大于2GB时会触发某些bug进而造成连接问题。为安全考虑，在所有操作系统平台下，建议尽量防止listener.log出现大于2GB的情况，及时备份清理。

**UNIX**

```
find / -name "*listener*.log*" | xargs du -m
find / -name "alert*.log*" | xargs du -m

HP-UX
find / -name "*listener*.log*" | xargs du -sk
find / -name "alert*.log*" | xargs du -sk
```

**清理审计日志**

```plsql
-- audit目录
cd $ORACLE_BASE/admin/{SID}/adump
-- 删除audit日志
find /opt/oracle/app/oracle/admin/oss/adump -name "*.aud" -print0 |xargs -0 rm -f

find /u01/app/oracle/admin/lydsj/cdump -name "*.trc" -ctime +30 -exec ls {} \;

-- 清空审计日志。
SQL> truncate table SYS.AUD$;
```

**ASM/RAC日志**

```sh
#ASM日志(grid用户)：
$ORACLE_BASE/diag/asm/+ASMX/trace/alert_+ASMX.log
#CRS日志(grid用户)：
$ORACLE_HOME/log/主机名/alert主机名.log
cd $ADR_BASE/diag/crs/主机名/crs/trace   				## Oracle 19C
```

## 1.6 查看集群运行状态

```plsql
crs_stat -t -v											-- 10g
crs_stat -t												-- 10g
crsctl status res -t									-- 11g
crsctl status res -t -init
crsctl check crs                                        -- 10g或11g
crsctl check cluster  -all                              -- 11g

-- 查看集群组件状态
crsctl check crs
crsctl check cssd
crsctl check crsd
crsctl check evmd
olsnodes -n
或
olsnodes -n -i -s -t 
srvctl status asm -a                                      -- 11g
srvctl status database -d sdbip
srvctl status diskgroup -g DGDATA1
gpnptool get
cemutlo -n
olsnodes -c
srvctl status listener -l LISTENER
srvctl status service -d spectra -v
lsnrctl status listener_scan1
lsnrctl services          OR         lsnrctl serice
srvctl status  scan_listener
srvctl config listener -l LISTENER
srvctl config listener -l LISTENER -a
srvctl config scan
crsctl stat res ora.LISTENER_SCAN1.lsnr -p

-- 查看集群私网信息
select NAME,IP_ADDRESS from gv$cluster_interconnects;

-- 查看集群active version
crsctl query crs activeversion

-- 查看集群是否为standard或者flex ASM
crsctl get cluster mode status

crsctl status res <ora.racdb.db> -p （-p可以查看每个资源详细的属性）

-- 关闭启动某个ora资源：（有的无法单独关闭，因为存在资源依赖关系）。
crsctl start res ora.oc4j

查询所有实例的状态
srvctl status database -d racdb
SQL> select * from v$active_instances;

查询单节点实例的状态
srvctl status instance -d racdb -i racdb1

关闭所有节点的实例
srvctl stop database -d racdb

关闭单节点的实例
srvctl stop instance -d racdb -i racdb2

查看RAC数据库配置
srvctl config database -d racdb

使用srvctl资源控制命令：
srvctl config network
srvctl config vip -n node1
srvctl status vip -n node1
srvctl config scan
srvctl status scan
srvctl config listener
srvctl status listener
srvctl start/stop listener -n node1 停止监听资源
srvctl config scan_listener
srvctl status scan_listener
srvctl config asm -a
srvctl config asm -n node1 查看指定节点的ASM配置。
srvctl status asm
srvctl status diskgroup -g data1
srvctl config database -d racdb 数据库配置
srvctl config nodeapps -n node1 节点应用配置
srvctl status nodeapps 节点应用状态
srvctl stop nodeapps 停止某节点上的所有应用
查看ASM实例状态:
srvctl status asm
srvctl status asm -a

 crsctl  stat res ora.acrosspm.db -t
 
srvctl disable diskgroup -g DATA1
srvctl remove diskgroup -g REDO5_SELF -f


-- 禁用ora.crf：禁用ora.crf，避免osysmond进程大量吃系统资源（如CPU）以root用户在每个RAC节点执行以下语句：
crsctl modify res ora.crf -attr "AUTO_START=never" -init
crsctl modify res ora.crf -attr "ENABLED=0" -init
crsctl stop res ora.crf -init
```

## 1.7 RAC自启

```
-- 11g
crsctl disable crs
crsctl enable crs
-- 11gRAC启动、关闭
crsctl start cluster -all
crsctl stop cluster -all
-- 10g
/etc/init.d/init.crs enable随操作系统的启动而启动
/etc/init.d/init.crs disable不随操作系统的启动而启动
-- 10g RAC启动、关闭
/etc/init.d/init.crs stop停止CRS主进程
/etc/init.d/init.crs start启动CRS主进程

-- 启停HAS
crsctl stop has
crsctl start has

-- 查看crs配置
crsctl config crs

-- 单节点集群has命令
crsctl check has
crsctl config has
crsctl disable has
crsctl enable has
crsctl query has releaseversion
crsctl query has softwareversion
crsctl start has
crsctl stop has
```

## 1.8 RAC网络配置

```
[oracle@rac1 init.d]$ oifcfg        Oracle网卡配置工具
Name:
oifcfg - Oracle Interface Configuration Tool.
Usage: oifcfg iflist [-p [-n]]
oifcfg setif {-node <nodename> | -global} {<if_name>/<subnet>:<if_type>}...
oifcfg getif [-node <nodename> | -global] [ -if <if_name>[/<subnet>] [-type <if_type>] ]
oifcfg delif [-node <nodename> | -global] [<if_name>[/<subnet>]]
oifcfg [-help]
<nodename> - name of the host, as known to a communications network
<if_name> - name by which the interface is configured in the system
<subnet> - subnet address of the interface
<if_type> - type of the interface { cluster_interconnect | public | storage }

oifcfg iflist -p -n

$ oifcfg iflist									  -- 查看网卡对应的网段，oracle网卡配置工具
eth0 192.168.1.0
eth1 192.168.2.0
eth2 192.168.61.0

$ oifcfg getif									  -- 没有配置之前是什么内容也没有

$ oifcfg setif -global eth0/192.168.1.0:public		 -- oracle网卡配置工具指定公有网卡

$ oifcfg setif -global eth1/192.168.2.0:cluster_interconnectoracle网卡配置工具指定私有网

[oracle@rac1 init.d]$ oifcfg getif					 -- 获取配置结果
eth0 192.168.1.0 global public						-- eth0是全局公共网卡
eth1 192.168.2.0 global cluster_interconnect		 -- eth1是全局私有网卡

-- 查看私网延迟(Misscount)
crsctl get css misscount
```

## 1.9 检查vote、ocr磁盘状态

```plsql
crsctl query css votedisk

-- 查看voting disk超时(disktimeout)
crsctl get css disktimeout

-- 移动voting disk到别的磁盘组
crsctl replace votedisk +OCRVD
-- 新增votedisk
crsctl add css votedisk 
-- 删除votedisk
crsctl delete css votedisk 
```

**OCR磁盘状态**

```
ocrcheck
```

**检查 ocr备份情况**

```
ocrconfig -showbackup
```

```
-- 使用ocrdump命令查看OCR内容，但这个命令不能用于OCR的备份恢复只可以用于阅读
RACDB1@rac1 /home/oracle$ ocrdump -stdout | more

-- 导出OCR磁盘内容，一旦有问题可以导入恢复
OCR手动导出:ocrconfig -export /tmp/ocr_bak
OCR手动导入:ocrconfig -import /tmp/ocr_bak
恢复OCR ocrconfig -restore /opt/product/10.2.0.1/crs/cdata/crs/backup01.ocr

-- 创建用于镜像OCR的RAW设备,比如为:/dev/raw/ocrcopied用ocrconfig –export 导出OCR的信息,编辑/etc/oracle/ocr.loc文件,添加ocrmirrorconfig_loc行
$ cat ocr.loc
ocrconfig_loc=/dev/raw/raw2
ocrmirrorconfig_loc=/dev/raw/ocrcopied
local_only=FALSE
用ocrconfig –import 导入OCR的信息

-- 我们的表决磁盘使用的是裸设备，因此使用裸设备的dd命令来备份表决磁盘，使用root用户
备份votedisk: dd if=/dev/raw/votediskcopied of=/dev/raw/raw1
恢复votedisk: dd if=/dev/raw/raw1 of=/dev/raw/votediskcopied

-- 通过strings命令查看votedisk内容
# strings voting_disk.bak |sort -u

-- 数据库自启
srvctl disable database -d doudou
```

## 1.10 检查节点vip资源

```plsql
srvctl config vip -n jaxnh1        #11g
srvctl config nodeapps -n jaxnh1 -a        #10g
```

## 1.11 验证oracle rac 负载均衡

```plsql
--连接数
select inst_id, count(*) from gv$session where status='ACTIVE' group by inst_id;
```

## 1.12 清空缓存

```plsql
----清空shared pool
alter system flush shared_pool;

----清空buffer cache
alter system flush buffer_cache;

----清空SGA连接池信息
alter system flush global context
```

## 2.1 数据库版本和补丁安装情况

### 2.1.1 版本情况

```
select * from v$version;
select dbid from v$database;
```

### 2.2.2 补丁安装情况1d

```
su - oracle/su - grid
$ORACLE_HOME/OPatch/opatch lsinventory -oh $ORACLE_HOME
$ORACLE_CRS_HOME/OPatch/opatch lsinventory  -oh $ORACLE_CRS_HOME
$ORA_CRS_HOME/OPatch/opatch lsinventory  -oh $ORA_CRS_HOME
./opatch lsinventory -oh $ORACLE_CRS_HOME                               -- 10g
./opatch lsinventory -oh $ORACLE_HOME                      -- 10g
```

### 2.2.3 补丁安装情况2​

```
set pages 100 lines 120
set echo on
col action format a6
col namespace format a10
col version format a10
col comments format a15
col action_time format a30
col bundle_series format a15
alter session set nls_timestamp_format = 'yyyy-mm-dd hh24:mi:ss.ff';
select * from dba_registry_history;
```

### 2.2.4 打PSU和Patch

打最新PSU和Oracle推荐的Patch

• Quick Reference to Patch Numbers for Database PSU, SPU(CPU), Bundle Patches and Patchsets(Doc ID 1454618.1)
• Oracle Recommended Patches -- Oracle Database(Doc ID 756671.1)

## 2.2 数据库基本配置信息

### 2.2.1 数据库基本信息

```plsql
alter session set NLS_DATE_FORMAT='YYYY-MM-DD HH24:MI:SS';
col PLATFORM_NAME format a30
select dbid,name,platform_name,created, log_mode  from v$database;
```

### **2.2.2 **功能开启情况

查看数据库强制日志、最小补充日志、闪回功能开启情况

```plsql
col FLASHBACK_ON format a2
col platform_name format a10
col name format a9
alter session set NLS_DATE_FORMAT='YYYY-MM-DD HH24:MI:SS';
select dbid,name,platform_name,created,log_mode,force_logging,supplemental_log_data_fk,supplemental_log_data_all,supplemental_log_data_min,flashback_on  from v$database;
select supplemental_log_data_min from gv$database;
```

### 2.2.3开启补充日志

```plsql
alter database add supplemental log data;
```

## 2.3 数据库连接数

```plsql
col name format a10
col value format a10
select inst_id, sessions_current,sessions_highwater,SESSIONS_MAX,SESSIONS_WARNING ,USERS_MAX from  gv$license;

select name,value from v$parameter where name='processes';

--杀会话
ps -ef | grep "LOCAL=NO"|grep -v grep | awk '{print "kill -9 " $2}'|sh
```

## 2.4 数据库时区

```plsql
-- 数据库时区
select dbtimezone from dual;  
-- 看会话时区
select sessiontimezone from dual; 
-- 查看当前时间和时区 
select systimestamp from dual; 
-- 修改数据时区 
alter database set time_zone='+8:00'; 

select u.name || '.' || o.name || '.' || c.name TSLTZcolumn
  from sys.obj$ o, sys.col$ c, sys.user$ u
where c.type# = 231
   and o.obj# = c.obj#
   and u.user# = o.owner#;
```

## 2.5 数据库参数

```plsql
-- V$PARAMETER 显示执行查询的 session的参数值。 V$SYSTEM_PARAMETER 视图则列出实例的参数值。
Set pagesize 1000
set linesize 100
column name format a30
column value format a40
select inst_id,name,value from gv$parameter where value is not null;

-- 某个参数
set linesize 120
col NAME format a40
COL VALUE FORMAT A40
SELECT /* SHSNC */
 INST_ID,NAME, ISDEFAULT, ISSES_MODIFIABLE SESMOD, ISSYS_MODIFIABLE SYSMOD, VALUE
  FROM GV$PARAMETER
 WHERE NAME LIKE '%' || LOWER('process') || '%'
   AND NAME <> 'control_files'
   AND NAME <> 'rollback_segments';
```

### 2.5.1 非默认参数

```plsql
Col name for a20
Col value for a40
select inst_id,num,name,value FROM GV$PARAMETER where isdefault='FALSE' order by inst_id,num;

select inst_id,NUM,name,value from GV$SYSTEM_PARAMETER2 where isdefault = 'FALSE' OR ismodified != 'FALSE' order by inst_id;
```

### 2.5.2 查看已废弃参数

```plsql
SELECT inst_id,name from gv$parameter WHERE isdeprecated = 'TRUE' ORDER BY name;
```

### 2.5.3 隐藏参数

```plsql
set linesize 200
column name format a50
column value format a25
col description format a40
select x.ksppinm name,y.ksppstvl value,y.ksppstdf isdefault,x.ksppdesc description,
decode(bitand(y.ksppstvf,7),1,'MODIFIED',4,'SYSTEM_MOD','FALSE') ismod,
decode(bitand(y.ksppstvf,2),2,'TRUE','FALSE') isadj
from
sys.x$ksppi x,
sys.x$ksppcv y
where
x.inst_id = userenv('Instance') and
y.inst_id = userenv('Instance') and
x.indx = y.indx and
x.ksppinm LIKE '/_%' escape '/'
order by
translate(x.ksppinm, ' _', ' ');

-- 关键字隐藏参数
SELECT  P.KSPPINM NAME, V.KSPPSTVL VALUE
  FROM SYS.X$KSPPI P, SYS.X$KSPPSV V
 WHERE P.INDX = V.INDX
   AND V.INST_ID = USERENV('Instance')
   AND SUBSTR(P.KSPPINM, 1, 1) = '_'
   AND ('PROCESS' IS NULL OR P.KSPPINM LIKE '%' || LOWER('process') || '%');
```

### 2.5.3 查看参数

```
select inst_id,name,value from gv$parameter where name in('audit_trail',
'max_dump_file_size',
'processes',
'sga_max_size',
'sga_target',
'spfile',
'memory_target',
'memory_max_target',
'db_block_size',
'db_files',
'recyclebin',
'O7_DICTIONARY_ACCESSIBILITY',
'pga_aggregate_target',
'listener',
'local_listener',
'remote_listener',
'db_create_file_dest',
'log_archive_dest_1',
'log_archive_dest_2',
'control_file_record_keep_time',
'enable_ddl_logging','cursor_sharing','open_cursors','session_cached_cursors','sec_case_sensitive_logon','log_buffer','recyclebin') order by inst_id;
```
### 2.5.4 修改参数

```plsql
alter system set audit_sys_operations=false scope=spfile;
alter system set deferred_segment_creation=FALSE;     
alter system set audit_trail             =none           scope=spfile;  
alter system set SGA_MAX_SIZE            =xxxxxM         scope=spfile; 
alter system set SGA_TARGET              =xxxxxM         scope=spfile;  
alter systemn set pga_aggregate_target   =XXXXXM         scope=spfile;
Alter PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;
alter database add SUPPLEMENTAL log data;
alter system set enable_ddl_logging=true;
-- 设置28401和10949事件
alter system set event='28401 trace name context forever,level 1','10949 trace name context forever,level 1' sid='*' scope=spfile;
#限制trace日志文件大最大25M
alter system set max_dump_file_size ='25M' ;
alter system set db_files=2000 scope=spfile;
#RAC修改local_listener：（现象：使用PlSql Developer第一次连接超时，第二次之后连接正常）
alter system set local_listener = '(ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.0.125)(PORT = 1521))' sid='orcl1';
alter system set local_listener = '(ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.0.130)(PORT = 1521))' sid='orcl2';
HOST = 192.168.1.216 --此处使用数字形式的VIP，绝对禁止使用rac1-vip
HOST = 192.168.1.219 --此处使用数字形式的VIP，绝对禁止使用rac2-vip
#更改控制文件记录保留时间
alter system set control_file_record_keep_time =31;
alter system set resource_limit=true sid='*' scope=spfile;
alter system set resource_manager_plan='force:' sid='*' scope=spfile;
alter system set parallel_force_local=true  sid='*' scope=spfile;
alter system set fast_start_parallel_rollback='LOW' scope=spfile;
ALTER SYSTEM SET open_cursors=1000 SCOPE=SPFILE;             
ALTER SYSTEM SET session_cached_cursors=1000 SCOPE=SPFILE;
alter system set cursor_sharing=force scope=spfile;
ALTER SYSTEM SET log_buffer=536870912 SCOPE=SPFILE;
ALTER SYSTEM SET parallel_max_servers=80;    默认480
ALTER SYSTEM SET processes=5000 SCOPE=SPFILE;
alter system set db_file_multiblock_read_count = 128 ;
alter system set disk_asynch_io=true sid ='*' scope=spfile;
alter system set recyclebin='OFF' scope=spfile;
alter system set "_undo_autotune"=false scope=spfile sid='*';
alter system set undo_retention=10800 scope=spfile sid='*';


alter profile "DEFAULT" limit PASSWORD_GRACE_TIME UNLIMITED;
alter profile "DEFAULT" limit PASSWORD_LIFE_TIME UNLIMITED;
alter profile "DEFAULT" limit PASSWORD_LOCK_TIME UNLIMITED;
alter profile "DEFAULT" limit FAILED_LOGIN_ATTEMPTS UNLIMITED;

exec dbms_scheduler.disable( 'ORACLE_OCM.MGMT_CONFIG_JOB' );
exec dbms_scheduler.disable( 'ORACLE_OCM.MGMT_STATS_CONFIG_JOB' );

BEGIN
DBMS_AUTO_TASK_ADMIN.DISABLE(
client_name => 'auto space advisor',
operation => NULL,
window_name => NULL);
END;
/

BEGIN
DBMS_AUTO_TASK_ADMIN.DISABLE(
client_name => 'sql tuning advisor',
operation => NULL,
window_name => NULL);
END;
/

-- asm parameter
alter system set memory_max_target=4096m scope=spfile;
alter system set memory_target=1536m scope=spfile;


ALTER SYSTEM SET shared_pool_size=10g SCOPE=SPFILE;
ALTER SYSTEM SET db_cache_size=56g SCOPE=SPFILE;
ALTER SYSTEM SET pga_aggregate_target=10g SCOPE=SPFILE;   

-- 如果要禁掉ASM实例的AMM，就一定不要同时reset memory_target和memory_max_target，而是应该将memory_target设为0并只reset memory_max_target。
-- 在任意一个RAC节点执行如下操作:
alter system set sga_target=2048M scope=spfile sid='*';
alter system set pga_aggregate_target=1024M scope=spfile sid='*';
alter system set memory_target=0 scope=spfile sid='*';
alter system set memory_max_target=0 scope=spfile sid='*';
alter system reset memory_max_target scope=spfile sid='*';

-- 关闭DRM（因DRM导致的问题非常多）：
alter system set "_gc_policy_time"=0 scope=spfile sid='*';
alter system set "_gc_undo_affinity"=false sid='*';
-- 增加实例延迟降级锁的时长为3毫秒,避免遇到一些导致实例crash的bug：
alter system set "_gc_defer_time"=3 scope=spfile sid='*';

-- 关闭自适应游标共享
alter system set "_optimizer_adaptive_cursor_sharing"=false sid='*' scope=spfile;
alter system set "_optimizer_extended_cursor_sharing"=none sid='*' scope=spfile;
alter system set "_optimizer_extended_cursor_sharing_rel"=none sid='*'scope=spfile;

-- 关闭Cardinality feedback：11g的Cardinality feedback可能会导致执行计划的不稳定：
alter system set "_optimizer_use_feedback"=false sid ='*' scope=spfile;

-- 使并行会话改为使用large pool
alter system set "_px_use_large_pool"=true sid ='*' scope=spfile;

-- 恢复LGWR的post/wait通知方式
alter system set "_use_adaptive_log_file_sync"=false sid='*' scope=spfile;

-- 修改参数样例
alter system set session_cached_cursors=300  sid='*' scope=spfile;
alter system set parallel_execution_message_size=32768  sid='*' scope=spfile;
alter system set "_optim_peek_user_binds"=false sid='*' scope=spfile;
alter system set "_b_tree_bitmap_plans"=false sid='*' scope=spfile;
alter system set filesystemio_options=asynch sid='*' scope=spfile;
alter system set "_cursor_obsolete_threshold"=100 sid='*' scope=spfile;
alter system set "_undo_autotune"=false sid='*' scope=spfile;
alter system set "_use_adaptive_log_file_sync"=false sid='*' scope=spfile;
alter system set "_gc_policy_time"=0  sid='*' scope=spfile;
alter system set db_file_multiblock_read_count=16  sid='*' scope=spfile;
alter system set undo_retention=10800   sid='*' scope=spfile;
alter system set "_memory_broker_stat_interval"=900  sid='*' scope=spfile;
alter system set job_queue_processes=80 sid='*' scope=spfile;
alter system set "_lm_tickets"=5000 sid='*' scope=spfile; 
alter system set "_gc_undo_affinity"=false sid='*';
alter system set large_pool_size=128M scope=spfile sid='*';

-- 云和恩墨参数
alter system set "_optimizer_adaptive_cursor_sharing"=false sid='*' scope=spfile;
alter system set "_optimizer_extended_cursor_sharing"=none sid='*' scope=spfile;
alter system set "_optimizer_extended_cursor_sharing_rel"=none sid='*' scope=spfile;
alter system set "_optimizer_use_feedback"=false sid ='*' scope=spfile;
alter system set deferred_segment_creation=false sid='*' scope=spfile;
alter system set event='28401 trace name context forever,level 1' sid='*' scope=spfile;
alter system set resource_limit=true sid='*' scope=spfile;
alter system set resource_manager_plan='force:' sid='*' scope=spfile;
alter system set "_undo_autotune"=false sid='*' scope=spfile;
alter system set "_optimizer_null_aware_antijoin"=false sid ='*' scope=spfile;
alter system set "_px_use_large_pool"=true sid ='*' scope=spfile;
alter system set audit_trail=none sid ='*' scope=spfile;
alter system set "_partition_large_extents"=false sid='*' scope=spfile;
alter system set "_index_partition_large_extents"= false sid='*' scope=spfile;
alter system set "_use_adaptive_log_file_sync"=false sid ='*' scope=spfile;
alter system set disk_asynch_io=true sid ='*' scope=spfile;
alter system set db_files=2000 scope=spfile;
alter profile "DEFAULT" limit PASSWORD_GRACE_TIME UNLIMITED;
alter profile "DEFAULT" limit PASSWORD_LIFE_TIME UNLIMITED;
exec dbms_scheduler.disable( 'ORACLE_OCM.MGMT_CONFIG_JOB' );
exec dbms_scheduler.disable( 'ORACLE_OCM.MGMT_STATS_CONFIG_JOB' );
BEGIN
DBMS_AUTO_TASK_ADMIN.DISABLE(
client_name => 'auto space advisor',
operation => NULL,
window_name => NULL);
END;
/
BEGIN
DBMS_AUTO_TASK_ADMIN.DISABLE(
client_name => 'sql tuning advisor',
operation => NULL,
window_name => NULL);
END;
/
```

| 参数                                   | 解释                                                         | 级别 |
| -------------------------------------- | :----------------------------------------------------------- | ---- |
| dit_trail: DB,  EXTENDED               | 审计（Audit）用于监视用户所执行的数据库操作，审计记录可存在数据字典表，当数据库的审计是开启时，在语句执行阶段产生审计记录。<br />\|由于审计表（AUD\$）存放在SYSTEM表空间，因此为了不影响系统的性能，保护SYSTEM表空间，建议把AUD$移动到其他的表空间上，或者关闭审计。<br />参考命令：alter  system set audit_trail='NONE' #INSTANCE# scope=spfile | 警告 |
| parallel_force_local                   | 为了降低集群间的数据交互，建议并行进程强制在本地实例分配，以便降低集群间的数据交互。<br />参考命令：alter  system set parallel_force_local=TRUE #INSTANCE# | 警告 |
| _gc_policy_time                        | DRM（Dynamic Resource  Mastering）负责将 Cache 资源 Remaster 到频繁访问这部分数据的节点上，从而提高 RAC 的性能。<br />但是 DRM 在实际使用中存在诸多  Bug，频繁的 DRM 会引发实例长时间 Hang 住甚至是宕机，建议关闭 DRM。<br />参考命令：alter  system set "_gc_policy_time"=0 #INSTANCE# scope=spfile; | 严重 |
| _gc_undo_affinity                      | 建议关闭集群 Undo  Affinity，降低集群交互，避免触发相关 BUG。<br />参考命令：alter  system set "_gc_undo_affinity"=FALSE #INSTANCE# scope=spfile; | 严重 |
| _optimizer_use_feedback                | 基数反馈（Cardinality  Feedback）是 Oracle 11.2 中引入的关于 SQL  性能优化的新特性，该特性主要针对统计信息陈旧、无直方图或虽然有直方图但仍基数计算不准确的情况，<br />Cardinality 基数的计算直接影响到后续的 JOIN  COST 等重要的成本计算评估，造成 CBO 选择不当的执行计划。但是该参数存在不稳定因素，可能会带来执行效率的问题，建议关闭优化器反馈。<br />参考命令：alter  system set "_optimizer_use_feedback"=FALSE #INSTANCE#; | 警告 |
| deferred_segment_creation              | 延迟段创建会导致使用 Direct 方式的  Export 出来的 DMP 文件无法正常导入（文档 ID 1604983.1），建议关闭延迟段创建的特性。<br />参考命令：alter  system set deferred_segment_creation=FALSE #INSTANCE#; | 提示 |
| _undo_autotune                         | 隐含参数 _undo_autotune 负责  undo retention（即 undo 段的保持时间）的自动调整，若由 Oracle 自动负责 undo retention，<br />则 Oracle  会根据事务量来占用 undo 表空间，可能会形成 undo 表空间的争用，建议将其关闭。<br />参考命令：alter  system set "_undo_autotune"=FALSE #INSTANCE#; | 严重 |
| _memory_imm_mode_without_autosga       | alter system set  "_memory_imm_mode_without_autosga"=false sid='*' scope=spfile;<br />说明：11.2.0.3开始，即使是手工管理内存方式下，如果某个POOL内存吃紧，Oracle仍然可能会自动调整内存，用这个参数来关闭这种行为 | 警告 |
| event                                  | alter system set  event='28401 trace name context forever,level 1','10949 trace name context  forever,level 1' sid='*' scope=spfile;<br />说明：这个参数主要设置2个事件：<br />1）  10949事件用于关闭11g的自动serial direct path read特性，避免出现过多的直接路径读，消耗过多的IO资源。<br />2）  28401事件用于关闭11g数据库中用户持续输入错误密码时的延迟用户验证特性，避免用户持续输入错误密码时产生大量的row cache  lock或library cache lock等待，严重时使数据库完全不能登录。 | 严重 |
| enable_ddl_logging                     | alter system set  enable_ddl_logging=true sid='*' scope=spfile;<br />说明：在11g里面，打开这个参数可以将ddl语句记录在alert日志中。以便于某些故障的排查。建议在OLTP类系统中使用。 | 提示 |
| parallel_max_servers                   | alter system set  parallel_max_servers=cpu_count逻辑CPU数 sid='*' scope=spfile;<br />说明：这个参数默认值与CPU相关，OLTP系统中将这个参数设置小一些，可以避免过多的并行对系统造成冲击。 | 提示 |
| result_cache_max_size                  | alter system set  result_cache_max_size=0 scope=spfile sid='*';<br />说明：12c中关闭result_cache，容易触发latch  free等bug。 | 严重 |
| _optimizer_ads_use_result_cache        | alter system set  "_optimizer_ads_use_result_cache" = FALSE scope=spfile sid='*';<br />说明：12c中关闭result_cache，容易触发latch  free等bu | 警告 |
| _datafile_write_errors_crash_instance  | alter system set  "_datafile_write_errors_crash_instance"=FALSE scope=spfile sid='*';<br />说明：在 PDB  由于某些原因丢失数据文件后，允许 CDB 继续运行。注意: 只对 PDB 的非系统数据文件有效。 | 警告 |
| _optimizer_adaptive_plans              | alter system set  "_optimizer_adaptive_plans"=FALSE scope=spfile sid='*';<br />说明：关闭自适应执行 | 警告 |
| _optimizer_aggr_groupby_elim           | alter system set  "_optimizer_aggr_groupby_elim"=FALSE scope=spfile sid='*';<br />19567916.8，Wrong  results when GROUP BY uses nested queries in 12.1.0.2 | 警告 |
| _optimizer_reduce_groupby_key          | alter system set  "_optimizer_reduce_groupby_key"=FALSE scope=spfile sid='*';<br />说明：Wrong  results from OUTER JOIN with a bind variable and a GROUP BY claus | 警告 |
| _optimizer_cost_based_transformation   | alter system set  "_optimizer_reduce_groupby_key"=off scope=spfile sid='*';<br />说明：关闭COST查询转换。 | 警告 |
| _optimizer_adaptive_cursor_sharing     | 隐含参数  _optimizer_adaptive_cursor_sharing 能控制自适应式游标共享的部分行为，由 Oracle  自适应的处理绑定变量的窥探，但这可能会触发性能问题。 Oracle 建议在非技术指导下，将其关闭掉。<br />参考命令：alter  system set "_optimizer_adaptive_cursor_sharing"=FALSE #INSTANCE#; | 警告 |
| _optimizer_extended_cursor_sharing     | 建议禁用自适应游标共享，将隐含参数_optimizer_extended_cursor_sharing设置为  NONE。<br />参考命令：alter  system set "_optimizer_extended_cursor_sharing"='NONE' #INSTANCE#; | 警告 |
| _optimizer_extended_cursor_sharing_rel | 建议禁用自适应游标共享，将隐含参数_optimizer_extended_cursor_sharing_rel设置为  NONE。<br />参考命令：alter  system set "_optimizer_extended_cursor_sharing_rel"='NONE'  #INSTANCE#; | 警告 |
| _optimizer_null_aware_antijoin         | 参数  _optimizer_null_aware_antijoin 是在 Oracle 11g  引入的新参数，它用于解决在反连接（Anti-Join）时，关联列上存在空值（NULL）或关联列无非空约束的问题。但是该参数不稳定，存在较多的  Bug，为避免触发相关 Bug，建议关闭。<br />参考命令：alter  system set "_optimizer_null_aware_antijoin"=FALSE #INSTANCE#; | 警告 |
| _PX_use_large_pool                     | 并行执行的从属进程在工作时需要交换数据和信息，默认从  Shared Pool 中分配内存空间。当 _PX_use_large_pool=TRUE 时并行进程将从 Large Pool  中分配内存，减少对共享池（Shared Pool）的争用。<br />参考命令：alter  system set "_PX_use_large_pool"=TRUE scope=spfile #INSTANCE#; | 警告 |
| _partition_large_extents               | 建议关闭分区使用大的初始化区（Extent）。<br />参考命令：alter  system set "_partition_large_extents"=FALSE #INSTANCE#; | 警告 |
| _use_adaptive_log_file_sync            | Oracle 默认启用  _use_adaptive_log_file_sync 参数，使得 LGWR 进程写日志的方式能自动在 post/wait 和 polling  两种方式之间进行取舍，可能会导致比较严重的写日志等待（log file sync的平均单次等待时间较高）,建议关闭此功能。<br />参考命令：alter  system set "_use_adaptive_log_file_sync"=FALSE #INSTANCE#; | 严重 |
| job_queue_processes                    | alter system set  job_queue_processes=cpu_core（CPU核数） scope=spfile sid='*';<br />说明：默认1000，建议调整为CPU核数。 | 提示 |

### 2.5.5 Oracle 参数调优

```plsql
ALTER SYSTEM SET "_buffer_busy_wait_timeout"=2     SCOPE=SPFILE;
ALTER SYSTEM SET "_kill_diagnostics_timeout"=140   SCOPE=SPFILE;
ALTER SYSTEM SET "_lm_rcvr_hang_allow_time"=140    SCOPE=SPFILE;
ALTER SYSTEM SET "_optim_peek_user_binds"=FALSE    SCOPE=SPFILE;
alter system set "_optimizer_adaptive_cursor_sharing"=false sid='*' scope=spfile;
alter system set "_optimizer_extended_cursor_sharing"=none sid='*' scope=spfile;
alter system set "_optimizer_extended_cursor_sharing_rel"=none sid='*' scope=spfile;
alter system set "_optimizer_use_feedback"=false sid ='*' scope=spfile;
alter system set "_undo_autotune"=false sid='*' scope=spfile;
alter system set "_optimizer_null_aware_antijoin"=false sid ='*' scope=spfile;
alter system set "_px_use_large_pool"=true sid ='*' scope=spfile;
alter system set "_partition_large_extents"=false sid='*' scope=spfile;
alter system set "_index_partition_large_extents"= false sid='*' scope=spfile;
alter system set "_use_adaptive_log_file_sync"=false sid ='*' scope=spfile;

ALTER SYSTEM SET "_kgl_hot_object_copies"=2 SCOPE=SPFILE;
ALTER SYSTEM SET "_enable_NUMA_support"=false;
ALTER SYSTEM SET PLSQL_CODE_TYPE=NATIVE SCOPE=SPFILE;    ---把plsql存储过程编译成本地代码的过程，不会导致任何解释器开销
ALTER SYSTEM SET PLSQL_OPTIMIZE_LEVEL=2 SCOPE=SPFILE;
alter system set use_large_pages='ONLY' SCOPE=SPFILE;
-- 调整ASM实例的LARGE_POOL_SIZE
alter system set large_pool_size=128M scope=spfile sid='*';
//10g
alter system set commit_write='immediate,nowait';    异步提交
//11g
alter system set commit_logging ='immediate';
alter system set commit_wait ='nowait' ;
alter system set java_jit_enabled=false scope=spfile;


待定参数
alter system set "_disk_sector_size_override" = true scope=spfile;
alter system set "_ash_size" = 100M scope=spfile;
alter system set "_gc_read_mostly_locking"=FALSE scope=spfile;
alter system set "_gc_policy_time"=0 scope=spfile;
```

[^注]: 将可选的 vm.hugetlb_shm_group 参数设置为有权使用 HugePages 的操作系统组。默认情况下，此参数设置为 0，从而允许所有组使用 HugePages。可以将此参数设置为 Oracle

```
PARALLEL_MAX_SEVERS参数设置并行执行可用的最大进程数量，该参数的缺省值如下得出：
1.当PGA_AGGREGATE_TARGET >0时
	PARALLEL_MAX_SERVERS= (CPU_COUNT x PARALLEL_THREADS_PER_CPU x 10)
2.当PARALLEL_MAX_SERVERS未设置
	PARALLEL_MAX_SERVERS=(CPU_COUNT x PARALLEL_THREADS_PER_CPU x 5）
3.缺省设置可能并不足够，通常我们根据最高的并行度（DOP）来设置PARALLEL_MAX_SERVERS参数
```

隐藏参数含义

| NAME                      | VALUE | ISDEFAULT | DESCRIPTION                                             | ISMOD | ISADJ |
| ------------------------- | ----- | --------- | ------------------------------------------------------- | ----- | ----- |
| _buffer_busy_wait_timeout | 2     | FALSE     | buffer busy wait time in centiseconds                   | FALSE | FALSE |
| _enable_NUMA_support      | FALSE | TRUE      | Enable NUMA support and optimizations                   | FALSE | FALSE |
| _kgl_hot_object_copies    | 2     | FALSE     | Number of copies for the hot object                     | FALSE | FALSE |
| _kill_diagnostics_timeout | 140   | FALSE     | timeout delay in seconds before killing enqueue blocker | FALSE | FALSE |
| _lm_rcvr_hang_allow_time  | 140   | FALSE     | receiver hang allow time in seconds                     | FALSE | FALSE |
| _optim_peek_user_binds    | FALSE | FALSE     | enable peeking of user binds                            | FALSE | FALSE |

### 2.5.6 ASM隐藏参数

```plsql
select ksppinm,ksppstvl,ksppdesc from x$ksppi x,x$ksppcv y where x.indx = y.indx and ksppinm='_asm_hbeatiowait';
```

### 2.5.7 Memory建议

```plsql
-- sga
select sga_size,sga_size_factor,estd_db_time from v$sga_target_advice;
-- pga
select pga_target_for_estimate,pga_target_factor,estd_extra_bytes_rw from v$pga_target_advice;
--memory 
select memory_size,memory_size_factor,estd_db_time from v$memory_target_advice;
```

## 2.6 数据库profile

```
set pagesize 200
col PROFILE format a20
col RESOURCE_NAME format a25
col LIMIT format a15
select * from dba_profiles where profile='PM4H';
select * from dba_profiles;
```

## 2.7 数据库字符集

```plsql
select userenv('language') from dual;

select * from NLS_DATABASE_PARAMETERS;
```

## 2.8 数据库实例状态

```plsql
col host_name  format a20
select inst_id,instance_number,instance_name,host_name,status from gv$instance;
```

## 2.9 数据库产品选项

```plsql
Set pagesize 100
Set linesize 100
set linesize 150
column parameter format a50
column value format a20
select *  from v$option where value='TRUE';

col COMP_NAME format a35;
select comp_id,comp_name, status, substr(version,1,10) as version  from dba_registry;

select comp_name, version, status from dba_server_registry where comp_name like '%OLAP%';

select name, detected_usages, currently_used from dba_feature_usage_statistics where name like 'OLAP%' order by name;

set pagesize500
set linesize 100
select substr(comp_name,1,40) comp_name, status, substr(version,1,10) version from dba_registry order by comp_name;
```

## 2.10 数据量大小

### 2.10.1 查看数据库段空间统计

```plsql
select sum(bytes)/1024/1024/1024 as gb from  Dba_Segments;


select sum(bytes)/1024/1024 as Mb from  Dba_Segments where owner='ENRIQ';

-- dba_segments slow优化
select /*+ optimizer_features_enable('11.2.0.2')*/  sum(bytes)/1024/1024/1024 as gb from  Dba_Segments;

-- Total Size of the database
Also accounting for controlfiles and mirrored redolog files.

select (a.data_size+b.temp_size+c.redo_size+d.cont_size)/1024/1024/1024 "total_size GB"
from ( select sum(bytes) data_size
       from dba_data_files ) a,
     ( select nvl(sum(bytes),0) temp_size
       from dba_temp_files ) b,
     ( select sum(bytes) redo_size
       from sys.v_$logfile lf, sys.v_$log l
       where lf.group# = l.group#) c,
     ( select sum(block_size*file_size_blks) cont_size
       from v$controlfile ) d;
```

### 2.10.2 查看表大小

```plsql
Select Segment_Name,Sum(bytes)/1024/1024 From dba_Extents Group By Segment_Name;
```
### 2.10.3 查看表的大小(分配)

```PLSQL
set linesize 120
col owner format a10
col segment_name for a30
SELECT /*+ SHSNC */
 OWNER,
 SEGMENT_NAME,
 SEGMENT_TYPE,
 SUM(BYTES) / 1048576 SIZE_MB,
 MAX(INITIAL_EXTENT) INIEXT,
 MAX(NEXT_EXTENT) MAXEXT
  FROM DBA_SEGMENTS
 WHERE SEGMENT_NAME = UPPER('TESTTABLE')
   AND ('SCOTT' IS NULL OR UPPER(OWNER) = UPPER('SCOTT'))
   AND SEGMENT_TYPE LIKE 'TABLE%'
 GROUP BY OWNER, SEGMENT_NAME, SEGMENT_TYPE
UNION ALL
SELECT OWNER,
       SEGMENT_NAME,
       SEGMENT_TYPE,
       SUM(BYTES) / 1048576 SIZE_MB,
       MAX(INITIAL_EXTENT) INIEXT,
       MAX(NEXT_EXTENT) MAXEXT
  FROM DBA_SEGMENTS
 WHERE (OWNER, SEGMENT_NAME) IN
       (SELECT OWNER, INDEX_NAME
          FROM DBA_INDEXES
         WHERE TABLE_NAME = UPPER('TESTTABLE')
           AND ('SCOTT' IS NULL OR UPPER(OWNER) = UPPER('SCOTT'))
        UNION
        SELECT OWNER, SEGMENT_NAME
          FROM DBA_LOBS
         WHERE TABLE_NAME = UPPER('TESTTABLE')
           AND ('SCOTT' IS NULL OR UPPER(OWNER) = UPPER('SCOTT')))
 GROUP BY OWNER, SEGMENT_NAME, SEGMENT_TYPE;
 
-- How to Compute the Size of a Table containing Outline CLOBs and BLOBs (文档 ID 118531.1)
ACCEPT SCHEMA PROMPT 'Table Owner: '
ACCEPT TABNAME PROMPT 'Table Name:  '
SELECT
 (SELECT SUM(S.BYTES)                                                                                                 -- The Table Segment size
  FROM DBA_SEGMENTS S
  WHERE S.OWNER = UPPER('&SCHEMA') AND
       (S.SEGMENT_NAME = UPPER('&TABNAME'))) +
 (SELECT SUM(S.BYTES)                                                                                                 -- The Lob Segment Size
  FROM DBA_SEGMENTS S, DBA_LOBS L
  WHERE S.OWNER = UPPER('&SCHEMA') AND
       (L.SEGMENT_NAME = S.SEGMENT_NAME AND L.TABLE_NAME = UPPER('&TABNAME') AND L.OWNER = UPPER('&SCHEMA'))) +
 (SELECT SUM(S.BYTES)                                                                                                 -- The Lob Index size
  FROM DBA_SEGMENTS S, DBA_INDEXES I
  WHERE S.OWNER = UPPER('&SCHEMA') AND
       (I.INDEX_NAME = S.SEGMENT_NAME AND I.TABLE_NAME = UPPER('&TABNAME') AND INDEX_TYPE = 'LOB' AND I.OWNER = UPPER('&SCHEMA')))
  "TOTAL TABLE SIZE"
FROM DUAL;
```

### 2.10.4估算表大小(实际)

```plsql
select num_rows*avg_row_len/1024/1024 from sys.dba_tables where table_name=upper(:table_name) and owner=upper(:owner);
```

### 2.10.5 审计日志大小

```plsql
col segment_name FOR a10
SELECT owner,segment_name,tablespace_name,bytes/1024/1024/1024 GB FROM dba_segments WHERE segment_name ='AUD$' AND owner='SYS';

-- 关闭登录、登出的审计日志：记录的每一次登录、登出操作
noaudit create session;
```

## 2.11 控制文件

### 2.11.1 查看控制文件

```plsql
Set linesize 200
Col name format a55
Select * from v$controlfile;
```

### 2.11.2 生成控制文件

```
alter session set tracefile_identifier='bak_control';
alter database backup controlfile to trace;
或
alter database backup controlfile to '/home/oracle/controlfile20171229.bak';
```

[^注]： RAC报错

```
SQL> alter database backup controlfile to '/home/oracle/controlfile20180926.bak';
alter database backup controlfile to '/home/oracle/controlfile20180926.bak'
*
ERROR at line 1:
ORA-00244: concurrent control file backup operation in progress
```

## 2.12 redo log文件

### 2.12.1 查看redo

```plsql
col status format a10;
select thread#, GROUP#,SEQUENCE#,BYTES/1024/1024,STATUS,FIRST_TIME from v$log;

set line 200
col member format a60;
select group#,sequence#,bytes/1024/1024 M ,members,status from v$log;

select * from v$logfile;

select group#,status,type,IS_RECOVERY_DEST_FILE,member from v$logfile;

col status format a10;
select inst_id,thread#, GROUP#,SEQUENCE#,BYTES/1024/1024,STATUS,FIRST_TIME from gv$log;
```
### 2.12.2 清空redo

```plsql
--清空redo
ALTER DATABASE CLEAR LOGFILE GROUP 1;
--非归档清空redo
ALTER DATABASE CLEAR UNARCHIVED LOGFILE GROUP 3;
```

### 2.12.3 查看REDO切换频率

```plsql
Select round(FIRST_TIME, 'DD'), THREAD#, Count(SEQUENCE#)
From v$log_history
Group By round(FIRST_TIME, 'DD'), THREAD#
Order By 1, 2;
```

### 2.12.4 检查15天内归档的生成情况

```plsql
set numw 4
set pagesize 500
set line 500
col Date for a20
col Day for a20
SELECT  trunc(first_time) "Date",
to_char(first_time, 'Dy') "Day",
count(1) "Total",
SUM(decode(to_char(first_time, 'hh24'),'00',1,0)) "h0",
SUM(decode(to_char(first_time, 'hh24'),'01',1,0)) "h1",
SUM(decode(to_char(first_time, 'hh24'),'02',1,0)) "h2",
SUM(decode(to_char(first_time, 'hh24'),'03',1,0)) "h3",
SUM(decode(to_char(first_time, 'hh24'),'04',1,0)) "h4",
SUM(decode(to_char(first_time, 'hh24'),'05',1,0)) "h5",
SUM(decode(to_char(first_time, 'hh24'),'06',1,0)) "h6",
SUM(decode(to_char(first_time, 'hh24'),'07',1,0)) "h7",
SUM(decode(to_char(first_time, 'hh24'),'08',1,0)) "h8",
SUM(decode(to_char(first_time, 'hh24'),'09',1,0)) "h9",
SUM(decode(to_char(first_time, 'hh24'),'10',1,0)) "h10",
SUM(decode(to_char(first_time, 'hh24'),'11',1,0)) "h11",
SUM(decode(to_char(first_time, 'hh24'),'12',1,0)) "h12",
SUM(decode(to_char(first_time, 'hh24'),'13',1,0)) "h13",
SUM(decode(to_char(first_time, 'hh24'),'14',1,0)) "h14",
SUM(decode(to_char(first_time, 'hh24'),'15',1,0)) "h15",
SUM(decode(to_char(first_time, 'hh24'),'16',1,0)) "h16",
SUM(decode(to_char(first_time, 'hh24'),'17',1,0)) "h17",
SUM(decode(to_char(first_time, 'hh24'),'18',1,0)) "h18",
SUM(decode(to_char(first_time, 'hh24'),'19',1,0)) "h19",
SUM(decode(to_char(first_time, 'hh24'),'20',1,0)) "h20",
SUM(decode(to_char(first_time, 'hh24'),'21',1,0)) "h21",
SUM(decode(to_char(first_time, 'hh24'),'22',1,0)) "h22",
SUM(decode(to_char(first_time, 'hh24'),'23',1,0)) "h23"
FROM    V$log_history where to_date(first_time)>to_date(sysdate-15)
group by trunc(first_time), to_char(first_time, 'Dy')
Order by 1;
set numw 10
```

2.12.5 REDO管理

```plsql
-- add
alter database add logfile group 4 '/usr/oracle/dbs/log4PROD.dbf' size 300M;
alter database add logfile thread 1 group 5
('/u04/oradata/redologs/redo05a.log','/u04/oradata/redologs/redo05b.log') size 300M;
-- Add a redo log file group and specifying the group number
ALTER DATABASE ADD LOGFILE GROUP 5 ('c:\temp\newlog1.log') SIZE 500M;
-- switch
alter system switch logfile;
ALTER SYSTEM ARCHIVE LOG CURRENT;
-- drop
alter database drop logfile group 1;
-- clear
 ALTER DATABASE CLEAR LOGFILE GROUP 1;
 ALTER DATABASE CLEAR UNARCHIVED LOGFILE GROUP 2;
```

## 2.13 归档情况 

```plsql
archive log list;
select log_mode from v$database;

col name format a20
col value  format a40
select inst_id,name,value from gv$parameter where name ='log_archive_dest_1';
```

## 2.14 表空间使用情况

### 2.14.1 查看SYSAUX使用信息

```plsql
col Schema for a25;
col Item for a25;
SELECT occupant_name "Item",space_usage_kbytes / 1048576 "Space Used (GB)",schema_name "Schema",move_procedure "Move Procedure" FROM v$sysaux_occupants ORDER BY 1 ;

--awrinfo
@?/rdbms/admin/awrinfo.sql
```

### 2.14.2 查看表空间使用信息1

```plsql
set linesize 150
set pagesize 400
column file_name format a65
column tablespace_name format a25
select f.tablespace_name tablespace_name,round((d.sumbytes/1024/1024/1024),2) total_g,
round(f.sumbytes/1024/1024/1024,2) free_g,
round((d.sumbytes-f.sumbytes)/1024/1024/1024,2) used_g,
round((d.sumbytes-f.sumbytes)*100/d.sumbytes,2) used_percent
from (select tablespace_name,sum(bytes) sumbytes from dba_free_space group by tablespace_name) f,
(select tablespace_name,sum(bytes) sumbytes from dba_data_files group by tablespace_name) d
where f.tablespace_name= d.tablespace_name
order by used_percent desc;

-- 大于80%
select *
  from (
  select tablespace_name,
               count(file_id),
               sum(round(bytes / (1024 * 1024 * 1024), 2)) total_space_GB,
               sum(round(MAXBYTES / (1024 * 1024 * 1024), 2)) max_space_GB,
               round(sum(bytes) / sum(MAXBYTES) * 100) space_usage_percent
          from dba_data_files
                    group by tablespace_name
         order by space_usage_percent desc) t
where space_usage_percent > 80
and (instr(t.TABLESPACE_NAME,'_DAT_')>0 or instr(t.TABLESPACE_NAME,'_IDX_')>0)
and regexp_substr(t.TABLESPACE_NAME,'\d{6}')>to_char(trunc(sysdate-30),'yymmdd')
union all
select *
  from (
  select tablespace_name,
               count(file_id),
               sum(round(bytes / (1024 * 1024 * 1024), 2)) total_space_GB,
               sum(round(MAXBYTES / (1024 * 1024 * 1024), 2)) max_space_GB,
               round(sum(bytes) / sum(MAXBYTES) * 100) space_usage_percent
          from dba_data_files
                    group by tablespace_name
         order by space_usage_percent desc) t
where space_usage_percent > 80
and (instr(t.TABLESPACE_NAME,'_DAT_')<= 0 and  instr(t.TABLESPACE_NAME,'_IDX_')<=0);

select tablespace_name,logging,status,SEGMENT_SPACE_MANAGEMENT from dba_tablespaces;
```

### 2.14.3 查看表空间使用信息2

 **查看表空间自动扩展情况下的使用信息**

```plsql
set linesize 150 pagesize 500
select f.tablespace_name tablespace_name,
round((d.sumbytes/1024/1024/1024),2) total_without_extend_GB,
round(((d.sumbytes+d.extend_bytes)/1024/1024/1024),2) total_with_extend_GB,
round((f.sumbytes+d.Extend_bytes)/1024/1024/1024,2) free_with_extend_GB,
round((d.sumbytes-f.sumbytes)/1024/1024/1024,2) used_GB,
round((d.sumbytes-f.sumbytes)*100/(d.sumbytes+d.extend_bytes),2) used_percent_with_extend
from (select tablespace_name,sum(bytes) sumbytes from dba_free_space group by tablespace_name) f,
(select tablespace_name,sum(aa.bytes) sumbytes,sum(aa.extend_bytes) extend_bytes from
(select  nvl(case  when autoextensible ='YES' then (case when (maxbytes-bytes)>=0 then (maxbytes-bytes) end) end,0) Extend_bytes,tablespace_name,bytes  from dba_data_files) aa group by tablespace_name) d
where f.tablespace_name= d.tablespace_name
order by  used_percent_with_extend desc;

--某个表空间
set linesize 120
SELECT /* SHSNC */
 TABLESPACE_NAME   TS_NAME,
 INITIAL_EXTENT    INI_EXT,
 NEXT_EXTENT       NXT_EXT,
 STATUS,
 CONTENTS,
 EXTENT_MANAGEMENT EXT_MGR,
 ALLOCATION_TYPE   ALLOC_TYPE
  FROM DBA_TABLESPACES
 ORDER BY TABLESPACE_NAME
 
 -- 查看表空间可用百分比
select b.tablespace_name,a.total,b.free,round((b.free/a.total)*100) "% Free" from
(select tablespace_name, sum(bytes/(1024*1024)) total from dba_data_files group by tablespace_name) a,
(select tablespace_name, round(sum(bytes/(1024*1024))) free from dba_free_space group by tablespace_name) b
WHERE a.tablespace_name = b.tablespace_name
order by "% Free";

 -- 大于90
 set linesize 150 pagesize 500
SELECT tablespace_name,total_space_GB,max_space_GB,space_usage_percent FROM (
select f.tablespace_name tablespace_name,
round((d.sumbytes/1024/1024/1024),2) total_without_extend_GB,
round(((d.sumbytes+d.extend_bytes)/1024/1024/1024),2) max_space_GB,
round((f.sumbytes+d.Extend_bytes)/1024/1024/1024,2) free_with_extend_GB,
round((d.sumbytes-f.sumbytes)/1024/1024/1024,2) total_space_GB,
round((d.sumbytes-f.sumbytes)*100/(d.sumbytes+d.extend_bytes),2) space_usage_percent
from (select tablespace_name,sum(bytes) sumbytes from dba_free_space group by tablespace_name) f,
(select tablespace_name,sum(aa.bytes) sumbytes,sum(aa.extend_bytes) extend_bytes from
(select  nvl(case  when autoextensible ='YES' then (case when (maxbytes-bytes)>=0 then (maxbytes-bytes) end) end,0) Extend_bytes
,tablespace_name,bytes  from dba_data_files) aa group by tablespace_name) d
where f.tablespace_name= d.tablespace_name
and ( instr(f.tablespace_name, '_DAT_') <= 0
                  AND instr(f.tablespace_name, '_IDX_') <= 0 ))
where space_usage_percent > 90
order by  space_usage_percent desc;


-- 统计每个用户使用表空间率
SELECT c.owner                                  "用户",
       a.tablespace_name                        "表空间名",
       total/1024/1024                          "表空间大小M",
       free/1024/1024                           "表空间剩余大小M",
       ( total - free )/1024/1024               "表空间使用大小M",
       Round(( total - free ) / total, 4) * 100 "表空间总计使用率%",
       c.schemas_use/1024/1024                  "用户使用表空间大小M",
       round((schemas_use)/total,4)*100         "用户使用表空间率%"
FROM   (SELECT tablespace_name,
               Sum(bytes) free
        FROM   DBA_FREE_SPACE
        GROUP  BY tablespace_name) a,
       (SELECT tablespace_name,
               Sum(bytes) total
        FROM   DBA_DATA_FILES
        GROUP  BY tablespace_name) b,
       (Select owner ,Tablespace_Name,
                Sum(bytes) schemas_use
        From Dba_Segments
        Group By owner,Tablespace_Name) c
WHERE  a.tablespace_name = b.tablespace_name
and a.tablespace_name =c.Tablespace_Name
order by c.owner,a.tablespace_name;

SELECT c.owner,
       a.tablespace_name,
       total/1024/1024,
       free/1024/102,
       ( total - free )/1024/1024,
       Round(( total - free )/total, 4)*100,
       c.schemas_use/1024/1024,
       round((schemas_use)/total,4)*100
FROM   (SELECT tablespace_name,
               Sum(bytes) free
        FROM   DBA_FREE_SPACE
        GROUP  BY tablespace_name) a,
       (SELECT tablespace_name,
               Sum(bytes) total
        FROM   DBA_DATA_FILES
        GROUP  BY tablespace_name) b,
       (Select owner ,Tablespace_Name,
                Sum(bytes) schemas_use
        From Dba_Segments
        Group By owner,Tablespace_Name) c
WHERE  a.tablespace_name = b.tablespace_name
and a.tablespace_name =c.Tablespace_Name
order by c.owner,a.tablespace_name;
```

### 2.14.4 查看表空间使用信息3

查看表空间自动扩展情况下的使用信息

```
set lines 112
set pages 10000

clear break

col TSname heading 'TSpace|Name|||'
col TSname format a25
col TSstatus heading 'TSpace|Status|||'
col TSstatus format a9
col TSSizeMb heading 'TSpace|Size|||'
col TSSizeMb format 99999
col TSUsedMb heading 'TSpace|Used|Space|Mb|'
col TSUsedMb format 99999
col TSFreeMb heading 'TSpace|Free|Space|Mb|'
col TSFreeMb format 99999
col TSUsedPrct heading 'TSpace|Used|Space|%|'
col TSUsedPrct format 99999
col TSFreePrct heading 'TSpace|Free|Space|%|'
col TSFreePrct format 99999
col TSSegUsedMb heading 'TSpace|Segmt|Space|Mb|'
col TSSegUsedMb format 99999
col TSExtUsedMb heading 'TSpace|Extent|Space|Mb|'
col TSExtUsedMb format 99999
col AutoExtFile heading 'Auto|Extend|File|?|'
col AutoExtFile format a6
col TSMaxSizeMb heading 'TSpace|MaxSize|Mb||'
col TSMaxSizeMb format a6
col TSMaxUsedPrct heading 'TSpace|Maxed|Used|Space|%'
col TSMaxUsedPrct format a6
col TSMaxFreePrct heading 'TSpace|Maxed|Free|Space|%'
col TSMaxFreePrct format a6

WITH
  ts_total_space AS (SELECT
                       tablespace_name,
                       SUM(bytes) as bytes,
                       SUM(blocks) as blocks,
                       SUM(maxbytes) as maxbytes
                     FROM 
                       dba_data_files
                     GROUP BY 
                       tablespace_name),
ts_free_space AS (SELECT
                    ddf.tablespace_name,
                    NVL(SUM(dfs.bytes),0) as bytes,
                    NVL(SUM(dfs.blocks),0) as blocks
                  FROM
                    dba_data_files ddf,
                    dba_free_space dfs
                  WHERE 
                    ddf.file_id = dfs.file_id(+)
                  GROUP BY 
                    ddf.tablespace_name),
ts_total_segments AS (SELECT
                        tablespace_name,
                        SUM(bytes) as bytes,
                        SUM(blocks) as blocks
                      FROM 
                        dba_segments
                      GROUP BY 
                        tablespace_name),
ts_total_extents AS (SELECT
                       tablespace_name,
                       SUM(bytes) as bytes,
                       SUM(blocks) as blocks
                     FROM 
                       dba_extents
                     GROUP BY 
                       tablespace_name)
SELECT
  dt.tablespace_name as "TSname",
  dt.status as "TSstatus",
  ROUND(ttsp.bytes/1024/1024,0) as "TSSizeMb",
  ROUND((ttsp.bytes-tfs.bytes)/1024/1024,0) as "TSUsedMb",
  ROUND(tfs.bytes/1024/1024,0) as "TSFreeMb",
  ROUND((ttsp.bytes-tfs.bytes)/ttsp.bytes*100,0) as "TSUsedPrct",
  ROUND(tfs.bytes/ttsp.bytes*100,0) as "TSFreePrct",
  ROUND(ttse.bytes/1024/1024,0) as "TSSegUsedMb",
  ROUND(tte.bytes/1024/1024,0) as "TSExtUsedMb",
  CASE 
    WHEN ttsp.maxbytes = 0 THEN 'No' ELSE 'Yes' 
  END as "AutoExtFile",
  CASE 
    WHEN ttsp.maxbytes = 0 THEN '-' ELSE TO_CHAR(ROUND(ttsp.maxbytes/1024/1024,0))
  END as "TSMaxSizeMb",
  CASE 
    WHEN ttsp.maxbytes = 0 THEN '-' ELSE TO_CHAR(ROUND((ttsp.bytes-tfs.bytes)/ttsp.maxbytes*100,0))
  END as "TSMaxUsedPrct",
  CASE 
    WHEN ttsp.maxbytes = 0 THEN '-' ELSE TO_CHAR(ROUND((ttsp.maxbytes-(ttsp.bytes-tfs.bytes))/ttsp.maxbytes*100,0))
  END as "TSMaxFreePrct"
FROM
  dba_tablespaces dt,
  ts_total_space ttsp,
  ts_free_space tfs,
  ts_total_segments ttse,
  ts_total_extents tte
WHERE dt.tablespace_name = ttsp.tablespace_name(+)
AND dt.tablespace_name = tfs.tablespace_name(+)
AND dt.tablespace_name = ttse.tablespace_name(+)
AND dt.tablespace_name = tte.tablespace_name(+)
ORDER BY ttsp.tablespace_name;
```

### 2.14.5 查看表空间使用信息4

```PLSQL
SET LINESIZE 500
SET PAGESIZE 1000
col FREE_SPACE(M) for 999999999
col USED_SPACE(M) for 999999999
col TABLESPACE_NAME for a15
SELECT D.TABLESPACE_NAME,
       SPACE "SUM_SPACE(M)",
       SPACE - NVL(FREE_SPACE, 0) "USED_SPACE(M)",
       ROUND((1 - NVL(FREE_SPACE, 0) / SPACE) * 100, 2) "USED_RATE(%)",
       FREE_SPACE "FREE_SPACE(M)",
       CASE
         WHEN FREE_SPACE = REA_FREE_SPACE THEN
          NULL
         ELSE
          ROUND((1 - NVL(REA_FREE_SPACE, 0) / SPACE) * 100, 2)
       END "REA_USED_RATE(%)",
       CASE
         WHEN FREE_SPACE = REA_FREE_SPACE THEN
          NULL
         ELSE
          REA_FREE_SPACE
       END "REA_FREE_SPACE(M)"
  FROM (SELECT TABLESPACE_NAME, ROUND(SUM(BYTES) / (1024 * 1024), 2) SPACE
          FROM DBA_DATA_FILES
         GROUP BY TABLESPACE_NAME) D,
       (SELECT F1.TABLESPACE_NAME,
               F1.FREE_SPACE - NVL(F2.FREE_SPACE, 0) REA_FREE_SPACE,
               F1.FREE_SPACE
          FROM (SELECT TABLESPACE_NAME,
                       ROUND(SUM(BYTES) / (1024 * 1024), 2) FREE_SPACE
                  FROM DBA_FREE_SPACE
                 GROUP BY TABLESPACE_NAME) F1,
               (SELECT TS_NAME TABLESPACE_NAME,
                       ROUND(SUM(SPACE) * 8 / 1024, 2) FREE_SPACE
                  FROM DBA_RECYCLEBIN
                 GROUP BY TS_NAME) F2
         WHERE F1.TABLESPACE_NAME = F2.TABLESPACE_NAME(+)) F
 WHERE D.TABLESPACE_NAME = F.TABLESPACE_NAME(+)
   AND ('USERS' IS NULL OR D.TABLESPACE_NAME = UPPER('USERS'))
 ORDER BY 1 - NVL(REA_FREE_SPACE, 0) / SPACE DESC;
```

## 2.15 临时表空间及账户状态

### 2.15.1 用户使用临时表空间情况

```plsql
column username format a25
column account_status format a20
col default_tablespace format a20
col temporary_tablespace format a20
select username,account_status,default_tablespace,temporary_tablespace from dba_users;

col username format a25;
col account_status format a20;
col default_tablespace format a19;
col temporary_tablespace format a10;
select username,account_status,default_tablespace,temporary_tablespace,CREATED from dba_users order by account_status,created;
```

### 2.15.2 临时表空间使用

```plsql
col Name for a10
col "Size (M)" for  a20
col "HWM (M)" for a20
col "HWM %" for a20
col "Using (M)" for a20
col "Using %" for a20
SELECT d.tablespace_name "Name",
TO_CHAR(NVL(a.bytes / 1024 / 1024, 0),'99,999,990.900') "Size (M)",
TO_CHAR(NVL(t.hwm, 0)/1024/1024,'99999999.999')  "HWM (M)",
TO_CHAR(NVL(t.hwm / a.bytes * 100, 0), '990.00') "HWM %" ,
TO_CHAR(NVL(t.bytes/1024/1024, 0),'99999999.999') "Using (M)",
TO_CHAR(NVL(t.bytes / a.bytes * 100, 0), '990.00') "Using %"
FROM sys.dba_tablespaces d,
(select tablespace_name, sum(bytes) bytes from dba_temp_files group by tablespace_name) a,
(select tablespace_name, sum(bytes_cached) hwm, sum(bytes_used) bytes from v$temp_extent_pool group by tablespace_name) t
WHERE d.tablespace_name = a.tablespace_name(+)
AND d.tablespace_name = t.tablespace_name(+)
AND d.extent_management like 'LOCAL'
AND d.contents like 'TEMPORARY';

-- 查看临时表空间使用率
SELECT temp_used.tablespace_name,total,used,
           total - used as "Free",
           round(nvl(total-used, 0) * 100/total,3) "Free percent"
      FROM (SELECT tablespace_name, SUM(bytes_used)/1024/1024 used
              FROM GV_$TEMP_SPACE_HEADER
             GROUP BY tablespace_name) temp_used,
           (SELECT tablespace_name, SUM(bytes)/1024/1024 total
              FROM dba_temp_files
             GROUP BY tablespace_name) temp_total
     WHERE temp_used.tablespace_name = temp_total.tablespace_name;
```

### 2.15.3 临时数据文件大小

```plsql
Set pagesize 100
Set linesize 200
col file_name format a55
select tablespace_name,file_name,bytes/1024/1024,autoextensible,maxbytes/1024/1024 from dba_temp_files;
```

### 2.15.4 临时表空间文件

查看临时表空间对应的临时文件的使用情况

```plsql
SELECT TABLESPACE_NAME         AS TABLESPACE_NAME,
    BYTES_USED/1024/1024/1024    AS TABLESAPCE_USED,
    BYTES_FREE/1024/1024/1024  AS TABLESAPCE_FREE
FROM V$TEMP_SPACE_HEADER
ORDER BY 1 DESC;
```

### 2.15.5 消耗临时表空间SQL语句

查找消耗临时表空间资源比较多的SQL语句

```plsql
SELECT   se.username,
         se.sid,
         su.extents,
         su.blocks * to_number(rtrim(p.value)) as Space,
         tablespace,
         segtype,
         sql_text
FROM gv$sort_usage su, gv$parameter p, gv$session se, gv$sql s
   WHERE p.name = 'db_block_size'
     AND su.session_addr = se.saddr
     AND s.hash_value = su.sqlhash
     AND s.address = su.sqladdr
ORDER BY se.username, se.sid;

 SELECT su.username,se.sid,se.serial#,se.sql_address,se.machine,se.program,su.tablespace,su.segtype,su.contents FROM v$session se,v$sort_usage su WHERE se.saddr=su.session_addr;
```

### 2.15.6 收缩临时表空间

排序等操作使用的临时段，使用完成后会被标记为空闲，表示可以重用，占用的空间不会立即释放，有时候临时表空间会变得非常大，此时可以通过收缩临时表空间来释放没有使用的空间。收缩临时表空间是ORACLE 11g新增的功能。

```plsql
ALTER TABLESPACE TEMP SHRINK SPACE KEEP 8G;
 
ALTER TABLESPACE TEMP SHRINK TEMPFILE '/u01/app/oracle/oradata/GSP/temp02.dbf'
```

## 2.16 SCHEMA使用情况

Schema大小

```plsql
select owner, count(*),sum(bytes)/1024/1024/1024 as GB from dba_segments group by owner order by GB desc;
```

## 2.17  RMAN 备份情况

**查看数据库是否存在备份实效情况**

```plsql
col INPUT_BYTES_PER_SEC_DISPLAY format a15;
col OUTPUT_BYTES_PER_SEC_DISPLAY format a15;
col TIME_TAKEN_DISPLAY format a17;
col status format a10;
COL hours    FORMAT 999.999
COL out_size FORMAT a10
select session_key,AUTOBACKUP_DONE,OUTPUT_DEVICE_TYPE, INPUT_TYPE,status,ELAPSED_SECONDS/3600     hours,   TO_CHAR(START_TIME,'yyyy-mm-dd hh24:mi') start_time, OUTPUT_BYTES_DISPLAY out_size,OUTPUT_BYTES_PER_SEC_DISPLAY,INPUT_BYTES_PER_SEC_DISPLAY  
from v$RMAN_BACKUP_JOB_DETAILS order by start_time ;
```
```plsql
col INPUT_BYTES_PER_SEC_DISPLAY format a15;
col OUTPUT_BYTES_PER_SEC_DISPLAY format a15;
col TIME_TAKEN_DISPLAY format a17;
col status format a10;
COL hours    FORMAT 999.999
COL out_size FORMAT a10
col handle format a80
select session_key,AUTOBACKUP_DONE,OUTPUT_DEVICE_TYPE, INPUT_TYPE,status,ELAPSED_SECONDS/3600     hours,
TO_CHAR(START_TIME,'yyyy-mm-dd hh24:mi') start_time, OUTPUT_BYTES_DISPLAY out_size,OUTPUT_BYTES_PER_SEC_DISPLAY,
INPUT_BYTES_PER_SEC_DISPLAY
from v$RMAN_BACKUP_JOB_DETAILS  where start_time >sysdate-30 order by start_time;
```


```plsql
select * from (select RECID,start_time,HANDLE from v$backup_piece  order by start_time desc ) where rownum<30;
```
```plsql
rman target /
list backup of database ;
list backup of archivelog all;
show all;
```

[^注]: 若是备份信息存储在control file中,并且rman的保留策略是天数；需要根据control_file_record_keep_time的参数值,进一步评估control_file_record_keep_time参数值的合理性。

[查看RMAN备份还原进度](\Git\blog\oracle\RMAN监控脚本.md)

```plsql
SELECT  SID,  decode(totalwork, 0, 0, round(100 * sofar/totalwork, 2)) "Percent", message "Message", start_time, elapsed_seconds, time_remaining , inst_id  from GV$Session_longops where TIME_REMAINING>0;
```



## 2.18  数据库中无效对象情况

### 2.18.1 ALL

```plsql
set linesize 500
col owner format a15
col object_name format a30
col object_id format 99999999
col object_type format a10
SELECT OWNER,OBJECT_NAME, OBJECT_ID, OBJECT_TYPE,to_char(CREATED,'yyyy-mm-dd,hh24:mi:ss') CREATED,
to_char(LAST_DDL_TIME,'yyyy-mm-dd,hh24:mi:ss') LAST_DDL_TIME,STATUS
FROM  dba_objects where status<>'VALID' order by owner,object_name,OBJECT_TYPE;
```
其他查询
```plsql
select substr(object_name,1,40) object_name,substr(owner,1,15) owner,object_type from dba_objects where status='INVALID' order by owner,object_type;

select owner,object_type,count(*) from dba_objects where status='INVALID' group by owner,object_type order by owner,object_type ;

-- 1. Query returning the number of invalid objects remaining. This number should decrease with time.
SELECT COUNT(*) FROM obj$ WHERE status IN (4, 5, 6);

-- 2. Query returning the number of objects compiled so far. This number should increase with time.
SELECT COUNT(*) FROM UTL_RECOMP_COMPILED;

-- 3. Query showing jobs created by UTL_RECOMP
SELECT job_name FROM dba_scheduler_jobs WHERE job_name like 'UTL_RECOMP_SLAVE_%';

-- 4. Query showing UTL_RECOMP jobs that are running
SELECT job_name FROM dba_scheduler_running_jobs WHERE job_name like 'UTL_RECOMP_SLAVE_%';
```

### 2.18.2 SYS用户无效对象

```plsql
set linesize 400
col owner format a15
col object_name format a30
col object_id format 99999999
col object_type format a10
col CREATED for a20
col LAST_DDL_TIME for
SELECT OWNER,OBJECT_NAME, OBJECT_ID, OBJECT_TYPE,to_char(CREATED,'yyyy-mm-dd,hh24:mi:ss') CREATED,
to_char(LAST_DDL_TIME,'yyyy-mm-dd,hh24:mi:ss') LAST_DDL_TIME,STATUS
FROM  dba_objects where status<>'VALID' and owner='SYS' order by last_ddl_time;
```

### 2.18.3 编译无效对象

```
alter package <schema name>.<package_name> compile;
alter package <schema name>.<package_name> compile body;
alter view <schema name>.<view_name> compile;
alter trigger <schema).<trigger_name> compile;
alter procedure sys.LOGMNR_KRVRDLUID3 compile;
```

[^参考文章]: How to Diagnose Invalid or Missing Data Dictionary (SYS) Objects (文档 ID 554520.1)
[^参考文章]: Debug and Validate Invalid Objects (文档 ID 300056.1)

## 2.19  SCN headroom问题检查

```plsql
Rem
Rem $Header: rdbms/admin/scnhealthcheck.sql st_server_tbhukya_bug-13498243/8 2012/01/17 03:37:18 tbhukya Exp $
Rem
Rem scnhealthcheck.sql
Rem
Rem Copyright (c) 2012, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      scnhealthcheck.sql - Scn Health check
Rem
Rem    DESCRIPTION
Rem      Checks scn health of a DB
Rem
Rem    NOTES
Rem      .
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    tbhukya     01/11/12 - Created
Rem
Rem
define LOWTHRESHOLD=10
define MIDTHRESHOLD=62
define VERBOSE=TRUE
set veri off;
set feedback off;
set serverout on
DECLARE
verbose boolean:=&&VERBOSE;
BEGIN
For C in (
select
version,
date_time,
dbms_flashback.get_system_change_number current_scn,
indicator
from
(
select
version,
to_char(SYSDATE,'YYYY/MM/DD HH24:MI:SS') DATE_TIME,
((((
((to_number(to_char(sysdate,'YYYY'))-1988)*12*31*24*60*60) +
((to_number(to_char(sysdate,'MM'))-1)*31*24*60*60) +
(((to_number(to_char(sysdate,'DD'))-1))*24*60*60) +
(to_number(to_char(sysdate,'HH24'))*60*60) +
(to_number(to_char(sysdate,'MI'))*60) +
(to_number(to_char(sysdate,'SS')))
) * (16*1024)) - dbms_flashback.get_system_change_number)
/ (16*1024*60*60*24)
) indicator
from v$instance
)
) LOOP
dbms_output.put_line( '-----------------------------------------------------'
|| '---------' );
dbms_output.put_line( 'ScnHealthCheck' );
dbms_output.put_line( '-----------------------------------------------------'
|| '---------' );
dbms_output.put_line( 'Current Date: '||C.date_time );
dbms_output.put_line( 'Current SCN:  '||C.current_scn );
if (verbose) then
dbms_output.put_line( 'SCN Headroom: '||round(C.indicator,2) );
end if;
dbms_output.put_line( 'Version:      '||C.version );
dbms_output.put_line( '-----------------------------------------------------'
|| '---------' );
IF C.version > '10.2.0.5.0' and
C.version NOT LIKE '9.2%' THEN
IF C.indicator>&MIDTHRESHOLD THEN
dbms_output.put_line('Result: A - SCN Headroom is good');
dbms_output.put_line('Apply the latest recommended patches');
dbms_output.put_line('based on your maintenance schedule');
IF (C.version < '11.2.0.2') THEN
dbms_output.put_line('AND set _external_scn_rejection_threshold_hours='
|| '24 after apply.');
END IF;
ELSIF C.indicator<=&LOWTHRESHOLD THEN
dbms_output.put_line('Result: C - SCN Headroom is low');
dbms_output.put_line('If you have not already done so apply' );
dbms_output.put_line('the latest recommended patches right now' );
IF (C.version < '11.2.0.2') THEN
dbms_output.put_line('set _external_scn_rejection_threshold_hours=24 '
|| 'after apply');
END IF;
dbms_output.put_line('AND contact Oracle support immediately.' );
ELSE
dbms_output.put_line('Result: B - SCN Headroom is low');
dbms_output.put_line('If you have not already done so apply' );
dbms_output.put_line('the latest recommended patches right now');
IF (C.version < '11.2.0.2') THEN
dbms_output.put_line('AND set _external_scn_rejection_threshold_hours='
||'24 after apply.');
END IF;
END IF;
ELSE
IF C.indicator<=&MIDTHRESHOLD THEN
dbms_output.put_line('Result: C - SCN Headroom is low');
dbms_output.put_line('If you have not already done so apply' );
dbms_output.put_line('the latest recommended patches right now' );
IF (C.version >= '10.1.0.5.0' and
C.version <= '10.2.0.5.0' and
C.version NOT LIKE '9.2%') THEN
dbms_output.put_line(', set _external_scn_rejection_threshold_hours=24'
|| ' after apply');
END IF;
dbms_output.put_line('AND contact Oracle support immediately.' );
ELSE
dbms_output.put_line('Result: A - SCN Headroom is good');
dbms_output.put_line('Apply the latest recommended patches');
dbms_output.put_line('based on your maintenance schedule ');
IF (C.version >= '10.1.0.5.0' and
C.version <= '10.2.0.5.0' and
C.version NOT LIKE '9.2%') THEN
dbms_output.put_line('AND set _external_scn_rejection_threshold_hours=24'
|| ' after apply.');
END IF;
END IF;
END IF;
dbms_output.put_line(
'For further information review MOS document id 1393363.1');
dbms_output.put_line( '-----------------------------------------------------'
|| '---------' );
END LOOP;
end;
/
```

## 2.20 等待事件

### 2.20.1 数据库等待事件

```plsql
set line 500
select inst_id,event,count(1) from gv$session where wait_class#<> 6 group by inst_id,event order by 1,3;

-- "查询结果中，15分钟内“EVENT”列中不包含以下等待事件：
 read by other session、buffer busy waits
 control file parallel write
 enqueue
 latch free
 log file sync
 log file switch（checkpoint incomplete）
 log file switch（archiving needed）
 global cache busy、gc current block busy、gc cr block busy
 log buffer space
 log file parallel write
 cursor: mutex S
 cursor: mutex X
 cursor: pin S
 cursor: pin S wait on X
 cursor: pin X
 DFS lock handle
 library cache lock
 library cache pin
 row cache lock
如果15分钟内“EVENT”列包括以上等待事件，但等待次数小于或等于30次，则检查通过。例如，15分钟内“log file sync”总共等待16次。

select * from (select a.event, count(*) from v$active_session_history a  where a.sample_time > sysdate - 15 / (24 * 60) 
               and a.sample_time < sysdate and a.session_state = 'WAITING' and a.wait_class not in ('Idle') group by a.event order by 2 desc, 1) where rownum <= 5;
               
-- 检查数据库的等待事件
set pages 80
set lines 120
col event for a40
select sid, event, p1, p2, p3, WAIT_TIME, SECONDS_IN_WAIT  from v$session_wait where event not like 'SQL%'   and event not like 'rdbms%';               
如果数据库长时间持续出现大量像latch free，enqueue，buffer busy waits，db file sequentialread，db file scattered read等等待事件时，需要对其进行分析，可能存在问题的语句。               
```

### 2.20.2 检查锁与library闩锁等待

```plsql
1. 查询锁等待。
select 'session ' || c.locker || ' lock ' || c.locked ||
    ', alter system kill session ' || '''' || c.locker || ',' ||
    d.serial# || '''' || ', OS:kill -9 ' || e.spid as "result"
    from (select a.sid locked, b.sid locker
    from v$lock a, v$lock b
    where a.request > 0
    and a.id1 = b.id1
    and a.id2 = b.ID2
    and a.type = b.type
    and a.addr <> b.addr) c,
    v$session d,
    v$process e
   where c.locker = d.sid
    and d.paddr = e.addr;
   如果返回结果为空，则表示系统无锁等待事件。
2. 查询library闩锁等待。
   select 'session ' || d.locker || ' lock ' || d.locked ||
    ', alter system kill session ' || '''' || d.locker || ',' ||
    d.serial# || '''' || ', OS:kill -9 ' || d.os as "result"
    from (select distinct s.sid locker, s.serial#, p.spid os, w.sid locked
    from dba_kgllock k, v$session s, v$session_wait w, v$process p
    where w.event like 'library cache%'
    and k.kgllkhdl = w.p1raw
    and k.kgllkuse = s.saddr
    and s.sid <> w.sid
    and s.paddr = p.addr) d
   order by d.locker;
   如果返回结果为空，则表示系统无library闩锁等待事件
```

### 2.20.3 等待事件信息

```plsql
select * from v$event_name B where b.name ='latch: cache buffers chains';

--引起等待事件的会话
select user_id,sql_id,count(*) from  sys.wrh$_active_session_history a
where sample_time > to_date('2019-10-29 08:00:00','yyyy-mm-dd hh24:mi:ss')
and sample_time < to_date('2019-10-29 09:00:00','yyyy-mm-dd hh24:mi:ss')
and a.instance_number =1 and a.event_id=2779959231
group by user_id,sql_id
order by 3;

select sql_id,p1,count(*) from  sys.wrh$_active_session_history 
where sample_time > to_date('2019-10-29 08:00:00','yyyy-mm-dd hh24:mi:ss')
and sample_time < to_date('2019-10-29 09:00:00','yyyy-mm-dd hh24:mi:ss')
and instance_number =1 and event_id=2779959231
group by sql_id,p1
order by 3 desc;
```

## 2.21 客户端连接分布

查询每个客户端连接每个实例的连接数

```plsql
col MACHINE format a20
select inst_id,machine ,count(*) from gv$session group by machine,inst_id order by 3;

select INST_ID,status,count(status) from gv$session group by status,INST_ID order by status,INST_ID;
```

连接数满排查

```plsql
 select inst_id,status,count(1) from gv$session where type <> 'BACKGROUNND' group by inst_id,status order by 3;
```

## 2.22 未删除归档

### 2.22.1 未删除的归档总大小

```
select  ((sum(blocks * block_size)) /1024 /1024) as "MB" from v$archived_log where  STANDBY_DEST  ='NO'  and deleted='NO';
```
### 2.22.2 删除归档

```
-- 删除3天前的归档日志，注意不要敲错日期，此删除操作是不可逆的。
RMAN> delete force archivelog until time "sysdate-1";
-- 删除3天前的归档日志
delete  archivelog until time "sysdate -3";
```

## 2.21 数据库所有实例每天生成的归档大小

```plsql
select
trunc(completion_time) as "Date"
,count(*) as "Count"
,((sum(blocks * block_size)) /1024/1024/1024) as "GB"
from v$archived_log where  STANDBY_DEST  ='NO'
group by trunc(completion_time) order by trunc(completion_time) ;
```

## 2.22  检查数据库中DBA权限的用户

```plsql
set pagesize 400
select * from dba_role_privs where granted_role='DBA';
```

## 2.23   数据库中DBLINK的创建信息

```plsql
SELECT 'CREATE '||DECODE(U.NAME,'PUBLIC','public ')||'DATABASE LINK '||CHR(10)
||DECODE(U.NAME,'PUBLIC',Null, 'SYS','',U.NAME||'.')|| L.NAME||chr(10)
||'CONNECT TO ' || L.USERID || ' IDENTIFIED BY "'||L.PASSWORD||'" USING
'''||L.HOST||''''
||chr(10)||';' TEXT
FROM SYS.LINK$ L, SYS.USER$ U
WHERE L.OWNER# = U.USER#;
```

## 2.24   检查object_id的最大值

```
select max(object_id) from dba_objects;
```

## 2.25   入侵检查

如果查询出信息输出则表示已经被恶意程序植入了比特币勒索触发器，需要尽快处理。该问题主要是通过使用互联网上非正规渠道获得的plsqldevloper工具连接数据库时传播感染。

数据库中存在被加密的存储过程，名字如下：
"DBMS_SUPPORT_INTERNAL "
"DBMS_ SYSTEM_INTERNAL "
"DBMS_ CORE_INTERNAL "
“DBMS_STANDARD_FUN9”
三个触发器名字如下：
"DBMS_SUPPORT_INTERNAL "
"DBMS_ SYSTEM_INTERNAL "
"DBMS_ CORE_INTERNAL "

一旦重启数据库，代码会判断数据库创建时间大于1200天，然后开始truncate某些表以及tab$被删除，恢复起来比较复杂。

检查是否使用盗版工具，Login.sql、AfterConnect.sql、toad.ini是否被注入。检查数据库中是否存在以上对象：

```plsql
select 'DROP TRIGGER '||owner||'."'||TRIGGER_NAME||'";' from dba_triggers where
TRIGGER_NAME like 'DBMS_%_INTERNAL% '
union all
select 'DROP PROCEDURE '||owner||'."'||a.object_name||'";' from dba_procedures a
where a.object_name like 'DBMS_%_INTERNAL% ';
```

```plsql
select owner,object_name,created from dba_objects where object_name like 'DBMS_SUPPORT_DBMONITOR%';


SELECT OWNER
     , '"'||OBJECT_NAME||'"' OBJECT_NAME
     ,OBJECT_TYPE
     ,TO_CHAR(CREATED, 'YYYY-MM-DD HH24:MI:SS') CREATED
  FROM DBA_OBJECTS
 WHERE OBJECT_NAME LIKE 'DBMS_CORE_INTERNA%'
    OR OBJECT_NAME LIKE 'DBMS_SYSTEM_INTERNA%'
    OR OBJECT_NAME LIKE 'DBMS_SUPPORT%';

SELECT '    DROP '||OBJECT_TYPE||' "'||OWNER||'"."'||OBJECT_NAME||'";' OBJECT_NAME
  FROM DBA_OBJECTS
 WHERE OBJECT_NAME LIKE 'DBMS_CORE_INTERNA%'
    OR OBJECT_NAME LIKE 'DBMS_SYSTEM_INTERNA%'
    OR OBJECT_NAME LIKE 'DBMS_SUPPORT%';

SELECT JOB, LOG_USER, WHAT
  FROM DBA_JOBS
 WHERE WHAT LIKE 'DBMS_STANDARD_FUN9%' ;

SELECT '    -- Logon with '||LOG_USER||CHR(10)||'    EXEC DBMS_JOB.BROKEN ('||JOB||', ''TRUE'')'||CHR(10)||'    EXEC DBMS_JOB.REMOVE('||JOB||')' STMT
  FROM DBA_JOBS
 WHERE WHAT LIKE 'DBMS_STANDARD_FUN9%' ;

SELECT OWNER,'"'||OBJECT_NAME||'"' OBJECT_NAME,OBJECT_TYPE,CREATED
  FROM DBA_OBJECTS
 WHERE OBJECT_NAME LIKE 'ORACHK%';
```

## 2.26 Unusable Index(es) 
### 2.26.1 普通索引

```plsql
select t.owner,t.index_name,t.table_name,blevel,t.num_rows,t.leaf_blocks,t.distinct_keys  from dba_indexes t
where status = 'UNUSABLE'
and  table_owner not in ('ORDDATA','ORDSYS','DMSYS','APEX_030200','OUTLN','DBSNMP','SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','SQLTXPLAIN','OWBSYS','FLOWS_FILES')
and owner in (select username from dba_users where account_status='OPEN');
```
### 2.26.2分区索引

```plsql
SELECT T.INDEX_OWNER ,T.INDEX_NAME,T.PARTITION_NAME,BLEVEL,T.NUM_ROWS,T.LEAF_BLOCKS,T.DISTINCT_KEYS
  FROM DBA_IND_PARTITIONS T
 WHERE STATUS = 'UNUSABLE'
   AND INDEX_OWNER NOT IN ('ORDDATA','ORDSYS','DMSYS','APEX_030200','OUTLN','DBSNMP','SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','SQLTXPLAIN','OWBSYS','FLOWS_FILES')
   and INDEX_OWNER  IN (select username from dba_users where account_status='OPEN');
```
### 2.26.3 子分区索引

```plsql
SELECT T.INDEX_OWNER ,T.INDEX_NAME,T.PARTITION_NAME,BLEVEL,T.NUM_ROWS,T.LEAF_BLOCKS,T.DISTINCT_KEYS
  FROM DBA_IND_SUBPARTITIONS T
 WHERE STATUS = 'UNUSABLE'
   AND INDEX_OWNER NOT IN ('ORDDATA','ORDSYS','DMSYS','APEX_030200','OUTLN','DBSNMP','SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','SQLTXPLAIN','OWBSYS','FLOWS_FILES')
   and INDEX_OWNER  IN (select username from dba_users where account_status='OPEN');
```
### 2.26.4 重建索引

```plsql
-- Rebuild index
Select 'alter index '||owner||'.'||index_name||' rebuild ONLINE;' from dba_indexes d where  status = 'UNUSABLE';
 select 'alter index '||owner||'.'||index_name||' rebuild online nologging parallel 4;' from dba_indexes where table_name=upper('TASK_INSTANCE_LOG');

-- Rebuild Partition index
Select 'alter index '||index_owner||'.'||index_name||' rebuild partition '||partition_name||' ONLINE;' from dba_ind_partitions where  status = 'UNUSABLE';

-- Rebuild Sub Partition index
Select 'alter index '||index_owner||'.'||index_name||' rebuild subpartition '||subpartition_name||' ONLINE;' from dba_ind_subpartitions where  status = 'UNUSABLE';

-- online重建索引
alter index ADMIN01.PK_TASK_INSTANCE_LOG rebuild online nologging parallel 4;
alter index PM4H_DB.IDX_IND_H_3723 rebuild partition PD_IND_H_3723_190501 online nologging parallel 4;

-- 重建索引
set linesize 120
col GRANTEE format a12
col owner   format a12
col GRANTOR format a12
col PRIVILEGE format a20
COL VALUE FORMAT A40
alter session set cursor_sharing=force;
SELECT /* SHSNC */
 'ALTER INDEX ' || OWNER || '.' || INDEX_NAME || ' REBUILD ONLINE;' UNUSABLE_INDEXES
  FROM ALL_INDEXES
 WHERE (TABLE_OWNER = UPPER('SCOTT') OR 'SCOTT' IS NULL)
   AND STATUS = 'UNUSABLE'
UNION ALL
SELECT 'ALTER INDEX ' || IP.INDEX_OWNER || '.' || IP.INDEX_NAME ||
       ' REBUILD PARTITION ' || IP.PARTITION_NAME || ' ONLINE;'
  FROM ALL_IND_PARTITIONS IP, ALL_INDEXES I
 WHERE IP.INDEX_OWNER = I.OWNER
   AND IP.INDEX_NAME = I.INDEX_NAME
   AND (I.TABLE_OWNER = UPPER('SCOTT') OR 'SCOTT' IS NULL)
   AND IP.STATUS = 'UNUSABLE'
UNION ALL
SELECT 'ALTER INDEX ' || IP.INDEX_OWNER || '.' || IP.INDEX_NAME ||
       ' REBUILD SUBPARTITION ' || IP.PARTITION_NAME || ' ONLINE;'
  FROM ALL_IND_SUBPARTITIONS IP, ALL_INDEXES I
 WHERE IP.INDEX_OWNER = I.OWNER
   AND IP.INDEX_NAME = I.INDEX_NAME
   AND (I.TABLE_OWNER = UPPER('SCOTT') OR 'SCOTT' IS NULL)
   AND IP.STATUS = 'UNUSABLE';
```

## 2.27 Index(es) of blevel>=3

```plsql
col INDEX_NAME for a30
SELECT owner,index_name,INDEX_TYPE,TABLE_OWNER,TABLE_NAME,TABLE_TYPE,blevel,PARTITIONED FROM dba_indexes WHERE blevel >= 3 ORDER BY blevel DESC;
```

## 2.28 Other Index Type

```plsql
select t.owner,t.table_name,t.index_name,t.index_type,t.status,t.blevel,t.leaf_blocks from dba_indexes t
where index_type in ('BITMAP', 'FUNCTION-BASED NORMAL', 'NORMAL/REV')
and owner not in ('ORDDATA','ORDSYS','DMSYS','APEX_030200','OUTLN','DBSNMP','SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','ORDSYS','DBSNMP','OUTLN','TSMSYS') 
and owner in (select username from dba_users where account_status='OPEN');
```

## 2.29 SYSTEM表空间业务数据

```plsql
select * from (select owner, segment_name, segment_type,tablespace_name
  from dba_segments where tablespace_name in('SYSTEM','SYSAUX'))
where  owner not in ('MTSSYS','ORDDATA','ORDSYS','DMSYS','APEX_030200','OUTLN','DBSNMP','SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','ORDSYS','DBSNMP','OUTLN','TSMSYS')
and owner in (select username from dba_users where account_status='OPEN');
```

## 2.30 并行度

```plsql
--表的并行度
select owner,table_name name,status,degree from dba_tables where degree>1;
--索引并行度
select owner,index_name name,status,degree from dba_indexes where degree>'1';
```

## 2.31 全表扫描

```plsql
SELECT
    t.inst_id,
    t.sid,
    t.serial#,
    target,
    t.sql_exec_start,
    t.username,
    t.sql_id
FROM
    gv$session_longops t
WHERE
    t.sql_plan_operation = 'TABLE ACCESS'
    AND sql_plan_options = 'FULL';
    
SELECT
    target,
    count(1)
FROM
    gv$session_longops t
WHERE
    t.sql_plan_operation = 'TABLE ACCESS'
    AND sql_plan_options = 'FULL'
    group by target;
    
col name for a30
select name,value from v$sysstat    where name in ('table scans (short tables)','table scans (long tables)');
```

## 2.32 Trigger(es)

```plsql
col OWNER for a15
col TRIGGER_NAME for a30
col TABLE_NAME for a40
SELECT owner, trigger_name, table_name, status FROM dba_triggers WHERE  owner in (select username from dba_users where account_status='OPEN');

select owner,trigger_name,table_name,status from dba_triggers where status= 'DISABLED';
```

## 2.33 Disabled Constraint(s) 

```plsql
SELECT owner, constraint_name, table_name, constraint_type, status 
FROM dba_constraints WHERE status ='DISABLE' and constraint_type='P' and owner in (select username from dba_users where account_status='OPEN');
```

## 2.34  外键无索引

```plsql
select c.owner,d.table_name,d.CONSTRAINT_NAME,d.columns from DBA_CONS_COLUMNS c,
(SELECT TABLE_NAME,
       CONSTRAINT_NAME,
       CNAME1 || NVL2(CNAME2, ',' || CNAME2, NULL) ||
       NVL2(CNAME3, ',' || CNAME3, NULL) ||
       NVL2(CNAME4, ',' || CNAME4, NULL) ||
       NVL2(CNAME5, ',' || CNAME5, NULL) ||
       NVL2(CNAME6, ',' || CNAME6, NULL) ||
       NVL2(CNAME7, ',' || CNAME7, NULL) ||
       NVL2(CNAME8, ',' || CNAME8, NULL) COLUMNS
  FROM (SELECT B.TABLE_NAME,
               B.CONSTRAINT_NAME,               
               MAX(DECODE(POSITION, 1, COLUMN_NAME, NULL)) CNAME1,
               MAX(DECODE(POSITION, 2, COLUMN_NAME, NULL)) CNAME2,
               MAX(DECODE(POSITION, 3, COLUMN_NAME, NULL)) CNAME3,
               MAX(DECODE(POSITION, 4, COLUMN_NAME, NULL)) CNAME4,
               MAX(DECODE(POSITION, 5, COLUMN_NAME, NULL)) CNAME5,
               MAX(DECODE(POSITION, 6, COLUMN_NAME, NULL)) CNAME6,
               MAX(DECODE(POSITION, 7, COLUMN_NAME, NULL)) CNAME7,
               MAX(DECODE(POSITION, 8, COLUMN_NAME, NULL)) CNAME8,
               COUNT(*) COL_CNT
          FROM (SELECT SUBSTR(TABLE_NAME, 1, 30) TABLE_NAME,
                       SUBSTR(CONSTRAINT_NAME, 1, 30) CONSTRAINT_NAME,
                       SUBSTR(COLUMN_NAME, 1, 30) COLUMN_NAME,
                       POSITION
                  FROM DBA_CONS_COLUMNS) A,
               DBA_CONSTRAINTS B
         WHERE A.CONSTRAINT_NAME = B.CONSTRAINT_NAME
           AND B.CONSTRAINT_TYPE = 'R'
         GROUP BY B.TABLE_NAME, B.CONSTRAINT_NAME) CONS
 WHERE COL_CNT > ALL (SELECT COUNT(*)
          FROM DBA_IND_COLUMNS I WHERE I.TABLE_NAME = CONS.TABLE_NAME
           AND I.COLUMN_NAME IN (CNAME1,CNAME2,CNAME3,CNAME4,CNAME5,CNAME6,CNAME7,CNAME8)
           AND I.COLUMN_POSITION <= CONS.COL_CNT
GROUP BY I.INDEX_NAME)) d where c.constraint_name=d.CONSTRAINT_NAME and c.table_name=d.TABLE_NAME
and c.owner in(select username from dba_users where account_status='OPEN' and username not in ('SYS','SYSTEM','SYSMAN','DBSNMP')) order by c.owner;
```

## 2.35 数据库保护模式

```plsql
select DB_UNIQUE_NAME,DATABASE_ROLE DB_ROLE,FORCE_LOGGING F_LOG,FLASHBACK_ON FLASHB_ON,LOG_MODE,OPEN_MODE,
GUARD_STATUS GUARD,PROTECTION_MODE PROT_MODE
from v$database;

select DEST_ID, APPLIED_SCN FROM v$archive_dest WHERE TARGET='STANDBY';
```

### 2.35.1 查看备库状态

```plsql
select DB_UNIQUE_NAME,DATABASE_ROLE DB_ROLE,FORCE_LOGGING F_LOG,FLASHBACK_ON FLASHB_ON,LOG_MODE,OPEN_MODE,
GUARD_STATUS GUARD,PROTECTION_MODE PROT_MODE
from v$database;
```

## 2.36 备库同步状态

**主端查询**

```plsql
select max(sequence#),thread# from v$archived_log where RESETLOGS_CHANGE# = (SELECT RESETLOGS_CHANGE# FROM V$DATABASE_INCARNATION WHERE STATUS = 'CURRENT') GROUP BY THREAD#;
```

**备端查询**

```plsql
select max(sequence#),thread# from gv$archived_log where  applied='YES' and RESETLOGS_CHANGE# = (SELECT RESETLOGS_CHANGE# FROM V$DATABASE_INCARNATION WHERE STATUS = 'CURRENT') GROUP BY THREAD#; 

SELECT PROCESS,STATUS,THREAD#,SEQUENCE#,BLOCK#,BLOCKS,DELAY_MINS FROM V$MANAGED_STANDBY;
```

[^注]: 如果主备相差3个以内可以接受，如果相差较多则表示同步异常。

### 2.36.1 切换归档日志

```plsql
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;
ALTER DATABASE OPEN READ ONLY;

RECOVER MANAGED STANDBY DATABASE DISCONNECT USING CURRENT LOGFILE;
ALTER SYSTEM SWITCH LOGFILE;
ALTER SYSTEM ARCHIVE LOG CURRENT;

archive log all；

---Flush any unsent redo from the primary database to the target standby database.
SQL> ALTER SYSTEM FLUSH REDO TO target_db_name;
```
### 2.36.2 应用归档

```plsql
-- 单个或少量
SQL> alter database register logfile '/u01/archlog/1_132735_893238304.arc';
-- 大量
rman> catalog start with '/u01/archlog/';

-- rman 
CONFIGURE ARCHIVELOG DELETION POLICY TO APPLIED ON ALL STANDBY;
```

### 2.36.3 同步状态

```plsql
col name for a30
set linesize 500
col  value for a50
select name,value  from v$dataguard_stats;
```

### 2.36.4 检查是否存在断档

```
select * from v$archive_gap;
```

## 3.1 AWR、ASH

### 3.1.1 脚本

脚本目录 $ORACLE_HOME/rdbms/admin

```plsql
@?/rdbms/admin/addmrpt.sql
@?/rdbms/admin/awrrpt.sql
@?/rdbms/admin/ashrpt.sql
@?/rdbms/admin/awrsqrpt.sql
@?/rdbms/admin/awrrpti   -- RAC中选择实例号
@?/rdbms/admin/awrgrpt   -- RAC全局AWR
@?/rdbms/admin/awrddrpt  -- AWR比对报告
```
### 3.1.2 快照、基线

```
-- 查看快照保留期限，11g默认为8天
SELECT retention FROM dba_hist_wr_control;

-- 修改快照时间间隔
EXEC DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS( interval => 30);
-- 手动生成快照
EXEC DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT('TYPICAL');
或
BEGIN 
  DBMS_WORKLOAD_REPOSITORY.create_snapshot(); 
END; 
/

-- 生成 AWR 基线：
BEGIN 
  DBMS_WORKLOAD_REPOSITORY.create_baseline ( 
    start_snap_id => 10,  
    end_snap_id   => 100, 
    baseline_name => 'AWR First baseline'); 
END; 
/

-- 生成 AWR 基线(11g)：
BEGIN
DBMS_WORKLOAD_REPOSITORY.CREATE_BASELINE_TEMPLATE (
start_time => to_date('&start_date_time','&start_date_time_format'),
end_time => to_date('&end_date_time','&end_date_time_format'),
baseline_name => 'MORNING',
template_name => 'MORNING',
expiration => NULL ) ;
END;
/

-- 基于重复时间周期来制定用于创建和删除 AWR 基线的模板：
BEGIN
DBMS_WORKLOAD_REPOSITORY.CREATE_BASELINE_TEMPLATE (
day_of_week => 'MONDAY',
hour_in_day => 9,
duration => 3,
start_time => to_date('&start_date_time','&start_date_time_format'),
end_time => to_date('&end_date_time','&end_date_time_format'),
baseline_name_prefix => 'MONDAY_MORNING'
template_name => 'MONDAY_MORNING',
expiration => 30 );
END;
/

-- 删除 AWR 基线：
BEGIN
    DBMS_WORKLOAD_REPOSITORY.DROP_BASELINE (baseline_name => 'AWR First baseline');
END;
/
```
### 3.1.3 其他脚本

```
awrrpt.sql 
展示一段时间范围两个快照之间的数据库性能指标。
awrrpti.sql 
展示一段时间范围两个快照之间的特定数据库和特定实例的性能指标。
awrsqrpt.sql
展示特定 SQL 在一段时间范围两个快照之间的性能指标，运行这个脚本来检查和诊断一个特定 SQL 的性能问题。
awrsqrpi.sql 
展示特定 SQL 在特定数据库和特定实例的一段时间范围内两个快照之间的性能指标。
awrddrpt.sql
用于比较两个指定的时间段之间数据库详细性能指标和配置情况。
awrddrpi.sql 
用于在特定的数据库和特定实例上，比较两个指定的时间段之间的数据库详细性能指标和配置情况。
```

### 3.1.4 AWR 相关的视图

如下系统视图与 AWR 相关：

```
V$ACTIVE_SESSION_HISTORY - 展示每秒采样的 active session history (ASH)。
V$METRIC - 展示度量信息。
V$METRICNAME - 展示每个度量组的度量信息。
V$METRIC_HISTORY - 展示历史度量信息。
V$METRICGROUP - 展示所有的度量组。
DBA_HIST_ACTIVE_SESS_HISTORY - 展示 active session history 的历史信息。
DBA_HIST_BASELINE - 展示 AWR 基线信息。
DBA_HIST_DATABASE_INSTANCE - 展示数据库环境信息。
DBA_HIST_SNAPSHOT - 展示 AWR 快照信息。
DBA_HIST_SQL_PLAN - 展示 SQL 执行计划信息。
DBA_HIST_WR_CONTROL - 展示 AWR 设置信息。
```

## 3.2 参数文件备份

```
create pfile='C:\Users\Administrator\Desktop\pfile20170109.ora' from spfile;
create pfile='/opt/oracle/pfile20190805.ora' from spfile;
create pfile='/home/oracle/pfile20200821.ora' from spfile;
create pfile='/export/home/oracle/pfile20170626.ora' from spfile;     <!--Solaris-->
```

## 3.3 JOB状态查询

```plsql
-- 查看当前DBMS_JOB 的状态
SELECT * FROM DBA_JOBS_RUNNING;

-- 查看当前DBMS_SCHEDULER的状态
select owner,job_name,session_id,slave_process_id,running_instance from dba_scheduler_running_jobs;

-- 查看数据泵Job
 select job_name,state from dba_datapump_jobs;
 
 select vs.sid, vp.program PROCESSNAME, vp.spid THREADID from   v$session vs,v$process p,dba_datapump_sessions dp where vp.addr = vs.paddr(+) and vs.saddr = dp.saddr; 
 
 
-- 查询正在执行的SCHEDULER_JOB
select owner,job_name,sid,b.SERIAL#,b.username,spid from ALL_SCHEDULER_RUNNING_JOBS,v$session b,v$process  where session_id=sid and paddr=addr

-- 查询正在执行的dbms_job
select job,b.sid,b.SERIAL#,b.username,spid from DBA_JOBS_RUNNING a ,v$session b,v$process  where a.sid=b.sid and paddr=addr

```

## 3.4 还原点设置

创建可靠还原点（可选）如果switch切换后有问题可以通过还原点回退数据库。 

确认是否开启了闪回，如果没有则要先开启，主库和备库。

```plsql
SQL> show parameter DB_RECOVERY
NAME TYPE VALUE
------------------------------------ ----------- ------------------------------
db_recovery_file_dest string
db_recovery_file_dest_size big integer 0

SQL> ALTER SYSTEM SET DB_RECOVERY_FILE_DEST_SIZE=10G;

SQL> ALTER SYSTEM SET DB_RECOVERY_FILE_DEST='/fra/flashback';

SQL> show parameter DB_RECOVERY
NAME TYPE VALUE
------------------------------------ ----------- ------------------------------
db_recovery_file_dest string /fra/flashback
db_recovery_file_dest_size big integer 10G

--停止恢复应用
RECOVER MANAGED STANDBY DATABASE CANCEL;
--创建还原点
CREATE RESTORE POINT SWITCHOVER_START_GRP GUARANTEE FLASHBACK DATABASE;
--启动应用进程
SQL> RECOVER MANAGED STANDBY DATABASE DISCONNECT USING CURRENT LOGFILE;
--查看还原点信息
SQL> col NAME format a30
col time format a40
set line 300
select NAME,SCN,TIME from v$restore_point;
```

### 3.4.1 创建还原点

主库同样检查是否开启闪回，并创建还原点

```
SQL> CREATE RESTORE POINT SWITCHOVER_START_GRP GUARANTEE FLASHBACK DATABASE;
Restore point created.
```

[^注意]: 如果创建还原点，在switch 切换完毕后一定要删除主备节点上还原点，否则还原点的文件会不断增长直到磁盘爆满。

### 3.4.2 删除还原点

```
drop restore point SWITCHOVER_START_GRP;
```

## 3.5  Windows Oracle服务配置

```
oradim.exe -delete -SID HISSERVER
oradim.exe -new -sid HISSERVER -startmode auto -srvcstart system -spfile
```

## 3.6  密码文件创建

```
-- UNIX
orapwd file=$ORACLE_HOME/dbs/orapw<local ORACLE_SID> password=<sys password> entries=5

-- Windows
orapwd file=$ORACLE_HOME/database/PWD<local ORACLE_SID>.ora password=<sys password> entries=5
```

## 3.7 闪回

### 3.7.1 闪回信息查询

```plsql
-- 查看数据库状态
select NAME,OPEN_MODE ,DATABASE_ROLE,CURRENT_SCN,FLASHBACK_ON from v$database;

-- 获取当前数据库的系统时间和SCN
select to_char(systimestamp,'yyyy-mm-dd HH24:MI:SS') as sysdt , dbms_flashback.get_system_change_number scn from dual;

-- 查看数据库可恢复的时间点
select * from V$FLASHBACK_DATABASE_LOG;

-- 查看闪回日志空间情况
select * from V$flashback_database_stat;

-- SCN和timestamp转换关系查询
select scn,to_char(time_dp,'yyyy-mm-dd hh24:mi:ss')from sys.smon_scn_time;

-- 查看闪回restore_point
select scn, STORAGE_SIZE ,to_char(time,'yyyy-mm-dd hh24:mi:ss') time,NAME from v$restore_point;

-- 查看闪回空间使用情况
select * from V$RECOVERY_AREA_USAGE;
```

### 3.7.2 开启/关闭闪回

```plsql
-- 确保数据库处于归档模式，如果为非归档模式，将数据库转换成归档模式
archive log list;

-- 设置闪回区大小：
alter system set db_recovery_file_dest_size=80g scope=spfile;
设置闪回区位置：
alter system set db_recovery_file_dest='/workdb/account_flashback_area' scope=spfile;
设置闪回目标为5天，以分钟为单位，每天为1440分钟：
alter system set db_flashback_retention_target=7200 scope=spfile;
-- RAC 
alter system set cluster_database=false scope=spfile sid='am2';
-- 打开闪回功能
shutdown immediate;
startup mount;
alter database flashback on;
alter database open;
alter system set cluster_database=true scope=spfile sid='am2';
-- 关闭闪回功能
shutdown immediate;
startup mount;
alter database flashback off;
alter database open;
```

### 3.7.3 闪回操作

```plsql
-- 闪回数据库
FLASHBACK DATABASE TO TIMESTAMP to_timestamp('2017-12-14 14:28:33','yyyy-mm-dd HH24:MI:SS');;
flashback database to scn 16813234;
　　
-- 闪回DROP	其中table_name可以是删除表名称，也可以是别名
flashback table table_name to before drop;
flashback table table_name to before drop rename to table_name_new;

-- 闪回表
flashback table table_name to scn scn_number;
flashback table table_name to timestamp to_timestamp('2017-12-14 14:28:33','yyyy-mm-dd hh24:mi:ss');

-- 查询误删除操作时间点的SQL。
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
select start_timestamp,operation,undo_sql from flashback_transaction_query where table_name=upper('TABLE_NAME') and table_owner=upper('USER_NAME') and start_timestamp>to_date('2012-07-02 20:30:00','yyyy-mm-dd hh24:mi:ss') order  by start_timestamp desc;
--以误删除了admin数据库中的W_UVS_SERVICE表为例，误删除时间为2013年4月2日晚上20点30分以后，执行以下SQL：
 select start_timestamp,operation,undo_sql from flashback_transaction_query where table_name=upper('W_UVS_SERVICE') and table_owner=upper('admin') and start_timestamp>to_date('2013-04-20 20:30:00','yyyy-mm-dd hh24:mi:ss') order  by start_timestamp desc;
显示以下信息：
START_TIMESTAMP     OPERATION
------------------- --------------------------------
UNDO_SQL
--------------------------------------------------------------------------------
04/20/2013 20:40:15 DELETE
insert into "ADMIN"."W_UVS_SERVICE"("DURATION_UNIT_LENGTH","START_TIME_RULE_CODE") val
ues ('2','2');
-- 设置待恢复表为行迁移模式。
alter table TABLE_NAME enable row movement;
-- 恢复到删除前指定时间点前的一段时间。时间从2查询结果的start_timestamp获取，填写到下面的SQL语句中。
flashback table TABLE_NAME to timestamp to_date('2013/04/20 20:40:00','yyyy-mm-dd hh24:mi:ss');
-- 删除操作的时间戳是2013/04/20 20:40:15，因此可以恢复到2013/04/20 20:40:00，早于删除操作15秒。这个提前值一般经验值，取10到20秒较为合适。检查数据恢复后数据。
select count(*) from TABLE_NAME;

-- 闪回查询
select * from table_name as of timestamp to_timestamp('2017-12-14 14:28:33','yyyy-mm-dd hh24:mi:ss');
select * from scott.dept as of scn 16801523;

-- 闪回快照
create restore point before_201712151111 guarantee flashback database;
flashback database to restore point before_201712151111;
```

## 3.8 开启关闭归档

```plsql
-- 设置归档路径
alter system set log_archive_dest_1='location=+DATA/FRA/' scope=spfile;
alter system set log_archive_dest_2='location=/oracle/ora9/oradata/arch2' scope=spfile;
#如果归档到两个位置，则可以通过上边方法实现

-- 设置归档日记文件名格式
alter system set log_archive_format='arch_%d_%t_%r_%s.log';

-- 开启归档
shutdown immediate;
startup mount;    
alter database archivelog;
alter database open; 

-- 关闭归档
shutdown immediate; 
startup mount; 
alter database noarchivelog; 
alter database open; 

```

## 3.9 12c数据库管理

```
-- 查看当前属于哪个容器
show con_name;
select sys_context('USERENV','CON_NAME') from dual;
alter session set container=cdb$root;

-- 如果在PDB中可以使用如下语法：
ALTER PLUGGABLE DATABASE OPEN READ WRITE [RESTRICTED] [FORCE];
ALTER PLUGGABLE DATABASE OPEN READ ONLY [RESTRICTED] [FORCE];
ALTER PLUGGABLE DATABASE OPEN UPGRADE [RESTRICTED];
ALTER PLUGGABLE DATABASE CLOSE [IMMEDIATE];

-- 如果是在CDB中，可以使用如下语法：
ALTER PLUGGABLE DATABASE <pdd-name-clause> OPEN READ WRITE [RESTRICTED][FORCE];
ALTER PLUGGABLE DATABASE <pdd-name-clause> OPEN READ ONLY [RESTRICTED] [FORCE];
ALTER PLUGGABLE DATABASE <pdd-name-clause> OPEN UPGRADE [RESTRICTED];
ALTER PLUGGABLE DATABASE <pdd-name-clause> CLOSE [IMMEDIATE];
<pdd-name-clause>表示的是多个PDB，如果有多个，用逗号分开。 也可以使用ALL或者ALL EXCEPT关键字来替代。其中：ALL：表示所有的PDBS;ALLEXCEPT 表示需要排除的PDBS。

-- 查看是否为cdb
select name,log_mode,open_mode,cdb from v$database;
 
-- 查看容器数据库中的pdb
col pdb_name for a30
select pdb_id,pdb_name,dbid,status from dba_pdbs;
select con_id,dbid,name,open_mode from v$pdbs;

-- inmemory检查确认未开启
col value for a20
col name for a40
select name,value from v$parameter where name like '%inm%';
-- 设置in内存大小
alter system set inmemory_size=600m scope=spfile;
-- 设置加载到内存的进程数量
alter system set inmemory_max_populate_servers=2 scope=both;

-- 查看PDB信息（在CDB模式下）
show pdbs   --查看所有pdb
select name,open_mode from v$pdbs;  --v$pdbs为PDB信息视图
select con_id, dbid, guid, name , open_mode from v$pdbs;

-- 切换容器
alter session set container=orcl1   --切换到PDBorcl1容器
alter session set container=CDB$ROOT    --切换到CDB容器

-- 查看当前属于哪个容器
select sys_context('USERENV','CON_NAME') from dual; --使用sys_context查看属于哪个容器
show con_name   --用show查看当前属于哪个容器

-- 创建或克隆前要指定文件映射的位置（需要CBD下sysdba权限
alter system set db_create_file_dest='/u01/app/oracle/oradata/orcl/orcl2';

-- 创建一个新的PDB：（需要CBD下sysdba权限）
create pluggable database test admin user admin identified by admin;    
alter pluggable database test_pdb open;    --将test_pdb 打开

-- 克隆PDB（需要CBD下sysdba权限）
create pluggable database orcl2 from orcl1;   --test_pdb必须是打开的，才可以被打开
alter pluggable database orcl2 open;   --然后打开这个pdb

-- 删除PDB（需要CBD下sysdba权限）
alter pluggable database  orcl2 close;  --关闭之后才能删除
drop pluggable database orcl2 including datafiles;  --删除PDB orcl2
--设置CDB启动PDB自动启动（在这里使用的是触发器）

-- 容器自启
CREATE OR REPLACE TRIGGER open_pdbs
AFTER STARTUP ON DATABASE
BEGIN
EXECUTE IMMEDIATE 'ALTER PLUGGABLE DATABASE ALL OPEN';
END open_pdbs;
/

-- 连接pdb
 sqlplus system/oracle@localhost:1521/orclpdb1
 -- 连接cdb
 sqlplus system/oracle@localhost:1521/orcl
```

## 3.10 11g AUTOTASK

```plsql
-- 执行历史
select client_name,job_name,job_start_time from dba_autotask_job_history;
-- AUTOTASK
SELECT client_name,status FROM dba_autotask_client;
-- 维护窗口
select * from dba_autotask_window_clients;
select * from dba_scheduler_windows;
-- 任务执行情况
col job_name for a30
col ACTUAL_START_DATE for a40
col RUN_DURATION for a30
set lines 180 pages 100
select owner, job_name, status, ACTUAL_START_DATE, RUN_DURATION from dba_scheduler_job_run_details where job_name like 'ORA$AT_OS_OPT_S%' order by 4;

-- 启动自动维护任务
--启动sql tuning advisor
BEGIN
  DBMS_AUTO_TASK_ADMIN.enable(
    client_name => 'sql tuning advisor',
    operation   => NULL,
    window_name => NULL);
END;
/

--启动auto space advisor
BEGIN
  DBMS_AUTO_TASK_ADMIN.enable(
    client_name => 'auto space advisor',
    operation   => NULL,
    window_name => NULL);
END;
/
--启动自动统计信息收集
BEGIN
  DBMS_AUTO_TASK_ADMIN.enable(
    client_name => 'auto optimizer stats collection',
    operation => NULL,
    window_name => NULL);
END;
/

-- 关闭自动维护任务
--关闭sql tuning advisor,避免消耗过多的资源
BEGIN
  DBMS_AUTO_TASK_ADMIN.disable(
    client_name => 'sql tuning advisor',
    operation   => NULL,
    window_name => NULL);
END;
/

--关闭auto space advisor,避免消耗过多的IO，还有避免出现这个任务引起的library cache lock
BEGIN
  DBMS_AUTO_TASK_ADMIN.disable(
    client_name => 'auto space advisor',
    operation   => NULL,
    window_name => NULL);
END;
/

--光闭自动统计信息收集，（慎用，除非有其他手工收集统计信息的完整方案，否则不建议关闭）
BEGIN
  DBMS_AUTO_TASK_ADMIN.disable(
    client_name => 'auto optimizer stats collection',
    operation => NULL,
    window_name => NULL);
END;
/

```

## 3.11 锁表

```plsql
select object_name,s.sid,s.serial#,p.spid from v$locked_object l,dba_objects o,v$session s,v$process p where l.object_id=o.object_id and l.session_id=s.sid and s.paddr=p.addr;
SELECT OBJECT_ID, SESSION_ID, inst_id FROM GV$LOCKED_OBJECT WHERE OBJECT_ID in (select object_id FROM dba_objects where object_name='OBJ_4525' AND OWNER='PM4H_MO');

select 'alter system kill session '||chr(39)||s.sid||','||s.serial#||chr(39)||'，@'||s.inst_id||chr(39)||' immediate;'  from gv$locked_object l,dba_objects o,gv$session s,gv$process p where l.object_id=o.object_id and l.session_id=s.sid and s.paddr=p.addr and S.USERNAME='db_username';

alter system kill session '4276,6045,@1' immediate;


-- 查询DML死锁会话sid，及引起死锁的堵塞者会话blocking_session
select sid, blocking_session, LOGON_TIME,sql_id,status,event,seconds_in_wait,state, BLOCKING_SESSION_STATUS from v$session where event like 'enq%' and state='WAITING' and BLOCKING_SESSION_STATUS='VALID';

BLOCKING_SESSION:Session identifier of the blocking session. This column is valid only if BLOCKING_SESSION_STATUS has the value VALID.

-- 可以在v$session.LOGON_TIME上看到引起死锁的堵塞者会话比等待者要早如果遇到RAC环境，一定要用gv$来查，并且执行alter system kill session 'sid,serial#'要到RAC对应的实例上去执行 或如下也可以
select
           (select username from v$session where sid=a.sid) blocker,
         a.sid,
         a.id1,
         a.id2,
       ' is blocking ' "IS BLOCKING",
         (select username from v$session where sid=b.sid) blockee,
             b.sid
    from v$lock a, v$lock b
   where a.block = 1
     and b.request > 0
     and a.id1 = b.id1
     and a.id2 = b.id2;
     
     
-- 查询DDL锁的sql
SELECT sid, event, p1raw, seconds_in_wait, wait_time FROM sys.v_$session_wait WHERE event like 'library cache %';
p1raw结果为'0000000453992440'
SELECT s.sid, kglpnmod "Mode", kglpnreq "Req", s.LOGON_TIME FROM x$kglpn p, v$session s WHERE p.kglpnuse=s.saddr AND kglpnhdl='0000000453992440';

-- 查询锁住的DDL对象
select d.session_id,s.SERIAL#,d.name from dba_ddl_locks d,v$session s where d.owner='MKLMIGEM' and d.SESSION_ID=s.sid

```

## 3.12 数据文件

### 3.12.1 数据文件

```plsql
Set pagesize 300
Set linesize 300
col file_name format a60
col tablespace_name for a20
select file_id,tablespace_name,file_name,bytes/1024/1024,status,autoextensible,maxbytes/1024/1024 from dba_data_files;

col file_name format a60
select file_id, file_name,tablespace_name,bytes/1024/1024 as MB ,autoextensible,maxbytes,user_bytes,online_status from dba_data_files;

-- 某个表空间数据文件
set linesize 120
col name format a60
col file# format 9999
col size_mb format 99999
alter session set cursor_sharing=force;
SELECT /* SHSNC */ /*+ RULE */
 F.FILE#,
 F.NAME,
 TRUNC(F.BYTES / 1048576, 2) SIZE_MB,
 F.CREATION_TIME,
 STATUS
  FROM V$DATAFILE F, V$TABLESPACE T
 WHERE F.TS# = T.TS#
   AND T.NAME in ('PM4H_SELF','PM4H_HW')
 ORDER BY F.CREATION_TIME;
 
 
-- 查看数据文件可用百分比
select b.file_id,b.tablespace_name,b.file_name,b.AUTOEXTENSIBLE,
ROUND(b.bytes/1024/1024/1024,2) ||'G'  "文件总容量",
ROUND((b.bytes-sum(nvl(a.bytes,0)))/1024/1024/1024,2)||'G' "文件已用容量",
ROUND(sum(nvl(a.bytes,0))/1024/1024/1024,2)||'G' "文件可用容量",
ROUND(sum(nvl(a.bytes,0))/(b.bytes),2)*100||'%' "文件可用百分比"
from dba_free_space a,dba_data_files b
where a.file_id=b.file_id
group by b.tablespace_name,b.file_name,b.file_id,b.bytes,b.AUTOEXTENSIBLE
order by b.tablespace_name;

-- 查看数据文件可用百分比
select b.file_id,b.tablespace_name,b.file_name,b.AUTOEXTENSIBLE,
ROUND(b.MAXBYTES/1024/1024/1024,2) ||'G'  "文件最大可用总容量",
ROUND((b.bytes-sum(nvl(a.bytes,0)))/1024/1024/1024,2)||'G' "文件已用容量",
ROUND(((b.MAXBYTES/1024/1024/1024)-((b.bytes-sum(nvl(a.bytes,0)))/1024/1024/1024))/(b.MAXBYTES/1024/1024/1024),2)*100||'%' "文件可用百分比"
from dba_free_space a,dba_data_files b
where a.file_id=b.file_id and b.file_id>4
group by b.tablespace_name,b.file_name,b.file_id,b.bytes,b.AUTOEXTENSIBLE,b.MAXBYTES
order by b.tablespace_name;
```

### 3.12.2 数据文件需要还原

```plsql
select THREAD#,SEQUENCE# SEQUENCE#,TIME "TIME"from v$recovery_log;

select file#,online_status "STATUS",change# "SCN",time"TIME" from v$recover_file;

SELECT a.recid,a.thread#,a.sequence#, a.name, a.first_change#,a.NEXT_CHANGE#,a.archived,a.deleted,a.completion_time FROM v$archived_log a,v$recovery_log l WHERE a.thread# = l.thread# AND a.sequence# = l.sequence#;
```

### 3.12.3 数据文件使用率方法一

**Displays Space Usage for Each Datafile**

```
--
-- Displays Space Usage for Each Datafile.
--
 
SET PAUSE ON
SET PAUSE 'Press Return to Continue'
SET PAGESIZE 60
SET LINESIZE 300
COLUMN "Tablespace Name" FORMAT A20
COLUMN "File Name" FORMAT A80
 
SELECT  Substr(df.tablespace_name,1,20) "Tablespace Name",
        Substr(df.file_name,1,80) "File Name",
        Round(df.bytes/1024/1024,0) "Size (M)",
        decode(e.used_bytes,NULL,0,Round(e.used_bytes/1024/1024,0)) "Used (M)",
        decode(f.free_bytes,NULL,0,Round(f.free_bytes/1024/1024,0)) "Free (M)",
        decode(e.used_bytes,NULL,0,Round((e.used_bytes/df.bytes)*100,0)) "% Used"
FROM    DBA_DATA_FILES DF,
       (SELECT file_id,
               sum(bytes) used_bytes
        FROM dba_extents
        GROUP by file_id) E,
       (SELECT sum(bytes) free_bytes,
               file_id
        FROM dba_free_space
        GROUP BY file_id) f
WHERE    e.file_id (+) = df.file_id
AND      df.file_id  = f.file_id (+)
ORDER BY df.tablespace_name,
         df.file_name
/

```

### 3.12.4 数据文件使用率方法二

**This query lists all tablespaces, the datafiles they use and some usage measurements:**

```
set linesize 133
set pagesize 500

clear break

col TSname format a25 
col TSname heading 'TSpace|Name|'
col FName format a55 
col FName heading 'File|Name|'
col FStatus format a9 
col FStatus heading 'File|Status|'
col FSizeMb format 99999 
col FSizeMb heading 'File|Size|Mb'
col FileFreeMb format 99999
col FileFreeMb heading 'File|Free|Mb'
col FileFreePrct format 999
col FileFreePrct heading 'File|Free|%'
col AutoExt format a6 
col AutoExt heading 'Auto|Extend|?'
col ExtbyMb format a6
col ExtbyMb heading 'Ext by|?|Mb'
col FMaxSizeMb format a8
col FMaxSizeMb heading 'File|Max Size|Mb'
break on TSname skip 1

SELECT
  ddf.tablespace_name as "TSname",
  ddf.file_name as "FName",
  ddf.status as "FStatus",
  ROUND(ddf.bytes/1024/1024,2) as "FSizeMb",
  ROUND(SUM(dfs.bytes)/1024/1024,2) as "FileFreeMb",
  ROUND(SUM(dfs.bytes)/SUM(ddf.bytes)*100,0) as "FileFreePrct",
  ddf.autoextensible as "AutoExt",
  CASE 
    WHEN ddf.increment_by = 0 THEN '-' ELSE TO_CHAR(ROUND((ddf.increment_by * dt.block_size)/1024/1024,2))
  END as "ExtbyMb",
  CASE 
    WHEN ddf.maxbytes = 0 THEN '-' ELSE TO_CHAR(ROUND(ddf.maxbytes/1024/1024,2))
  END as "FMaxSizeMb"
FROM 
  sys.dba_data_files ddf,
  sys.dba_tablespaces dt,
  sys.dba_free_space dfs
WHERE ddf.tablespace_name = dt.tablespace_name
AND ddf.file_id = dfs.file_id(+)
GROUP BY
  ddf.tablespace_name,
  ddf.file_name,
  ddf.status,
  ddf.bytes,
  ddf.autoextensible,
  ddf.increment_by,
  dt.block_size,
  ddf.maxbytes
ORDER BY
  ddf.tablespace_name;
```

## 3.13 占用空间最多的10个object

```plsql
col owner format a15
col Segment_Name format a36
col segment_type format a15
col tablespace_name format a15
select owner, Segment_Name,segment_type,tablespace_name,MB from
(Select owner, Segment_Name,segment_type,tablespace_name,Sum(bytes)/1024/1024 as MB From dba_Extents  group by owner,Segment_Name,segment_type,tablespace_name order by MB desc)
where rownum < 11;
```

## 3.14 统计信息

### 3.14.1 查看统计信息

```plsql
-- 查看表统计信息
select * from DBA_TAB_STATISTICS where OWNER  NOT IN ('ORDDATA','ORDSYS','DMSYS','APEX_030200','OUTLN','DBSNMP','SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','SQLTXPLAIN','OWBSYS','FLOWS_FILES') AND  
last_analyzed is not null and last_analyzed >= (sysdate-2);

select table_name,partition_name,subpartition_name,object_type, num_rows, global_stats,last_analyzed from user_tab_statistics;
-- 查看列统计信息
select * from DBA_TAB_COL_STATISTICS where OWNER  NOT IN ('ORDDATA','ORDSYS','DMSYS','APEX_030200','OUTLN','DBSNMP','SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','SQLTXPLAIN','OWBSYS','FLOWS_FILES') 
AND last_analyzed is not null and last_analyzed >= (sysdate-1);

-- 查看索引统计信息
select * from DBA_IND_STATISTICS where OWNER  NOT IN ('ORDDATA','ORDSYS','DMSYS','APEX_030200','OUTLN','DBSNMP','SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','SQLTXPLAIN','OWBSYS','FLOWS_FILES') 
AND last_analyzed is not null and last_analyzed >= (sysdate-2);

-- 分区表和分区索引统计信息
select index_owner,tablespace_name,index_name,partition_name,logging,num_rows,last_analyzed,status from dba_ind_partitions where index_name in (select index_name from dba_part_indexes where table_name=upper('tablename')) and TABLE_OWNER=upper('username');
select table_owner,table_name,partition_name,logging,num_rows,last_analyzed, global_stats from dba_tab_partitions t where t.table_name=upper('tablename') and TABLE_OWNER=upper('username');

-- 查看统计信息过期的表
SELECT OWNER, TABLE_NAME, PARTITION_NAME, 
       OBJECT_TYPE, STALE_STATS, LAST_ANALYZED 
  FROM DBA_TAB_STATISTICS
 WHERE (STALE_STATS = 'YES' OR LAST_ANALYZED IS NULL)
   -- STALE_STATS = 'YES' 表示统计信息过期：当对象有超过10%的rows被修改时
   -- LAST_ANALYZED IS NULL 表示该对象从未进行过收集统计信息
   AND OWNER NOT IN ('MDDATA', 'MDSYS', 'ORDSYS', 'CTXSYS', 
                     'ANONYMOUS', 'EXFSYS', 'OUTLN', 'DIP', 
                     'DMSYS', 'WMSYS', 'XDB', 'ORACLE_OCM', 
                     'TSMSYS', 'ORDPLUGINS', 'SI_INFORMTN_SCHEMA',
                     'OLAPSYS', 'SYSTEM', 'SYS', 'SYSMAN',
                     'DBSNMP', 'SCOTT', 'PERFSTAT', 'PUBLIC',
                     'MGMT_VIEW', 'WK_TEST', 'WKPROXY', 'WKSYS')
   -- 系统用户表的统计信息状态不做统计，根据需求打开或关闭
   AND TABLE_NAME NOT LIKE 'BIN%'
   -- 回收站中的表不做统计
  order by 1,2;
  
-- 统计信息脚本
select 'exec dbms_stats' || '.' || 'gather_table_stats' || '(ownname=>''' ||owner||'''' || ', tabname=> ''' || table_name || ''''||',estimate_percent =>10' || ',method_opt=> ' ||'''FOR ALL COLUMNS SIZE AUTO'''||', degree => 2'|| ', cascade => TRUE ); '
  from DBA_TAB_STATISTICS
 where owner  NOT IN ('MDDATA', 'MDSYS', 'ORDSYS', 'CTXSYS', 
                     'ANONYMOUS', 'EXFSYS', 'OUTLN', 'DIP', 
                     'DMSYS', 'WMSYS', 'XDB', 'ORACLE_OCM', 
                     'TSMSYS', 'ORDPLUGINS', 'SI_INFORMTN_SCHEMA',
                     'OLAPSYS', 'SYSTEM', 'SYS', 'SYSMAN',
                     'DBSNMP', 'SCOTT', 'PERFSTAT', 'PUBLIC',
                     'MGMT_VIEW', 'WK_TEST', 'WKPROXY', 'WKSYS')
and  (STALE_STATS = 'YES' OR LAST_ANALYZED IS NULL) AND TABLE_NAME NOT LIKE 'BIN%';
```

### 3.14.2 收集统计信息

```plsql
select distinct 'exec dbms_stats' || '.' || 'gather_table_stats' || '(ownname=>''' ||owner||'''' || ', tabname=> ''' || table_name || ''''||',estimate_percent =>0.01' || ',method_opt=> ' ||'''FOR ALL COLUMNS SIZE AUTO'''||', degree => 2'|| ', cascade => TRUE ); '
  from DBA_TAB_STATISTICS
 where owner  NOT IN ('MDDATA', 'MDSYS', 'ORDSYS', 'CTXSYS', 
                     'ANONYMOUS', 'EXFSYS', 'OUTLN', 'DIP', 
                     'DMSYS', 'WMSYS', 'XDB', 'ORACLE_OCM', 
                     'TSMSYS', 'ORDPLUGINS', 'SI_INFORMTN_SCHEMA',
                     'OLAPSYS', 'SYSTEM', 'SYS', 'SYSMAN',
                     'DBSNMP', 'SCOTT', 'PERFSTAT', 'PUBLIC',
                     'MGMT_VIEW', 'WK_TEST', 'WKPROXY', 'WKSYS')
and  ( LAST_ANALYZED IS NULL) AND TABLE_NAME NOT LIKE 'BIN%'
and rownum <= 100;

select DISTINCT 'exec dbms_stats' || '.' || 'gather_table_stats' || '(ownname=>''' ||owner||'''' || ', tabname=> ''' || table_name ||''''||',estimate_percent =>DBMS_STATS.AUTO_SAMPLE_SIZE' || ',method_opt=> ' ||'''FOR ALL COLUMNS SIZE AUTO'''||', degree => 10'|| ', cascade => TRUE ); '
  from DBA_TAB_STATISTICS
 where owner ='PM4H_DB'
and  ( STALE_STATS = 'YES' OR LAST_ANALYZED IS NULL ) AND TABLE_NAME NOT LIKE 'BIN%'
and last_analyzed <=  TO_DATE('2019-09-26 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
and  last_analyzed >= TO_DATE('2019-09-21 00:00:00', 'YYYY-MM-DD HH24:MI:SS')

-- 收集表统计信息
exec dbms_stats.gather_table_stats(ownname=>'PM4H_DB', tabname=> 'IND_TOH_21989_2',estimate_percent =>DBMS_STATS.AUTO_SAMPLE_SIZE,method_opt=> 'FOR ALL COLUMNS SIZE AUTO', degree => 4, cascade => TRUE ); 

-- 收集表分区统计信息
exec dbms_stats.gather_table_stats(ownname=>'PM4H_DB', tabname=> 'IND_TOH_21989_2',partname => 'P21989_2_20190926',estimate_percent =>DBMS_STATS.AUTO_SAMPLE_SIZE,method_opt=> 'FOR ALL COLUMNS SIZE AUTO', degree => 10, cascade => TRUE ); 

exec dbms_stats.gather_table_stats(ownname=>'PM4H_MO', tabname=> 'OBJ_VER_4525',partname => 'PW_OBJ_VER_4525_171120',granularity => 'PARTITION',estimate_percent =>0.01,method_opt=> 'for all indexed columns size 254', degree => 10, cascade => TRUE );

-- 只收集表的统计信息
exec dbms_stats.gather_table_stats(ownname => 'PM4H_DB', tabname =>'IND_TOH_20688', estimate_percent =>DBMS_STATS.AUTO_SAMPLE_SIZE, method_opt => 'FOR TABLE',degree => 4);
```

### 3.14.3 统计信息管理

```plsql
-- 确认执行计划是否在统计更新前后不一致。可以根据sql_id去查执行计划是否有变化，比如在统计更新之前是用到索引的，统计之后反而是全表扫描。
-- 确认sql_id信息：
select * from v$sql where sql_text like '%tablename%';
-- 根据sql_id查询所有执行计划，确认是否有变化：
 select * from DBA_HIST_SQL_PLAN where sql_id= 'sql_id' order by TIMESTAMP;
-- 查询结果中的“LAST_ANALYZED”列所示时间即为统计更新时间。查看统计更新可以保留的时间。
select DBMS_STATS.GET_STATS_HISTORY_RETENTION from dual;
-- 系统默认统计信息保留31天。查看最早可以恢复的时间点。
 select DBMS_STATS.GET_STATS_HISTORY_AVAILABILITY from dual;
-- 检查数据表所有的统计情况，选择时间点来恢复。
select * from dba_tab_stats_history where table_name ='tablename';
-- 还原统计信息
select TABLE_NAME, STATS_UPDATE_TIME from dba_tab_stats_history where table_name=upper('IND_ORG_20686');
select TABLE_NAME, PARTITION_NAME,STATS_UPDATE_TIME from dba_tab_stats_history where table_name=upper('MO_MOENTITY');
execute dbms_stats.restore_table_stats ('PM4H_AD','MO_MOENTITY','25-SEP-19 02.26.47.499595 PM +07:00');
-- 确认还原情况。
SQL> select TABLE_NAME ,LAST_ANALYZED  from user_tables where TABLE_NAME='AR_LOG_TRX_DETAIL';

-- 删除列统计信息
exec dbms_stats.gather_table_stats('PM4H_DB','IND_TOH_20688',method_opt=>'for columns owner size 1');

exec dbms_stats.delete_column_stats(ownname=>'PM4H_DB',tabname=>'QTM_MODATA',colname=> NULL)

-- 删除表的统计信息
analyze table  table_name delete statistics;

DBMS_STATS.DELETE_TABLE_STATS (
   ownname          VARCHAR2, 
   tabname          VARCHAR2, 
   partname         VARCHAR2 DEFAULT NULL,
   stattab          VARCHAR2 DEFAULT NULL, 
   statid           VARCHAR2 DEFAULT NULL,
   cascade_parts    BOOLEAN  DEFAULT TRUE, 
   cascade_columns  BOOLEAN  DEFAULT TRUE,
   cascade_indexes  BOOLEAN  DEFAULT TRUE,
   statown          VARCHAR2 DEFAULT NULL,
   no_invalidate    BOOLEAN  DEFAULT to_no_invalidate_type (
                                     get_param('NO_INVALIDATE')),
   force            BOOLEAN DEFAULT FALSE);
   
exec dbms_stats.delete_table_stats(ownname=>'PM4H_DB',tabname=>'IND_TOH_20688') 

-- 删除索引统计信息
DBMS_STATS.DELETE_INDEX_STATS (
   ownname          VARCHAR2, 
   indname          VARCHAR2,
   partname         VARCHAR2 DEFAULT NULL,
   stattab          VARCHAR2 DEFAULT NULL, 
   statid           VARCHAR2 DEFAULT NULL,
   cascade_parts    BOOLEAN  DEFAULT TRUE,
   statown          VARCHAR2 DEFAULT NULL,
   no_invalidate    BOOLEAN  DEFAULT to_no_invalidate_type (get_param('NO_INVALIDATE')),
   force            BOOLEAN DEFAULT FALSE);
   
exec DBMS_STATS.DELETE_INDEX_STATS(ownname=>'PM4H_AD', indname=>'MO_MOENTITY_IDX11')

--11g统计信息收集新特性：扩展统计信息收集

exec DBMS_STATS.GATHER_TABLE_STATS(ownname=>‘xxx',tabname=>‘DEALREC_ERR_201608',method_opt=>'for columns (substr(other_class, 1, 3)) size skewonly',estimate_percent=>10,no_invalidate=>false,cascade=>true,degree => 10);
```



## 3.15 分区表信息

### 3.15.1 是否分区表

该表是否是分区表，分区表的分区类型是什么，是否有子分区，分区总数有多少

```plsql
select OWNER,table_name,partitioning_type,subpartitioning_type,partition_count from dba_part_tables where  owner  NOT IN ('MDDATA', 'MDSYS', 'ORDSYS', 'CTXSYS', 
                     'ANONYMOUS', 'EXFSYS', 'OUTLN', 'DIP', 
                     'DMSYS', 'WMSYS', 'XDB', 'ORACLE_OCM', 
                     'TSMSYS', 'ORDPLUGINS', 'SI_INFORMTN_SCHEMA',
                     'OLAPSYS', 'SYSTEM', 'SYS', 'SYSMAN',
                     'DBSNMP', 'SCOTT', 'PERFSTAT', 'PUBLIC',
                     'MGMT_VIEW', 'WK_TEST', 'WKPROXY', 'WKSYS');

-- 方法二
set linesize 120
col USERNAME format a12
col MACHINE format a16
col TABLESPACE format a10
SELECT /* SHSNC */
 PARTITION_POSITION NO#,
 PARTITION_NAME,
 TABLESPACE_NAME TS_NAME,
 INITIAL_EXTENT / 1024 INI_K,
 NEXT_EXTENT / 1024 NEXT_K,
 PCT_INCREASE PCT,
 FREELISTS FLS,
 FREELIST_GROUPS FLGS
  FROM ALL_TAB_PARTITIONS
 WHERE TABLE_OWNER = 'SCOTT'
   AND TABLE_NAME LIKE '%GPS%'
 ORDER BY 1;
```
### 3.15.2 分区键

该分区表在哪一列上建分区,有无多列联合建分区

```PLSQL
col owner for a20
col name for a30
col column_name for a30
col object_type for a30
select owner,name,column_name,object_type,column_position from dba_part_key_columns where name ='RANGE_PART_TAB';
```
### 3.15.3 分区表大小

```PLSQL
select sum(bytes)/1024/1024 from dba_segments where segment_name ='RANGE_PART_TAB';
```
### 3.15.4 各分区大小

 该分区表各分区分别有多大，各个分区名是什么。

```PLSQL
select partition_name, segment_type, bytes from dba_segments where segment_name ='RANGE_PART_TAB';
```
### 3.15.5 分区表统计信息收集情况

```PLSQL
select table_name,partition_name,last_analyzed,partition_position,num_rows from dba_tab_statistics where table_name ='RANGE_PART_TAB';
```
### 3.15.6分区表索引

查该分区表有无索引，分别什么类型,全局索引是否失效，此外还可看统计信息收集情况。

其中status值为N/A 表示分区索引，分区索引是否失效是在dba_ind_partitions中查看

```PLSQL
select table_name,index_name,last_analyzed,blevel,num_rows,leaf_blocks,distinct_keys,status
from dba_indexes where table_name ='RANGE_PART_TAB';
```
### 3.15.7 分区表索引键

```PLSQL
select index_name,column_name,column_position from dba_ind_columns where table_name='RANGE_PART_TAB';
```
### 3.15.8 分区表上的各索引大小

```PLSQL
select segment_name,segment_type,sum(bytes)/1024/1024 from dba_segments
where segment_name in(select index_name from dba_indexes where table_name='RANGE_PART_TAB')
group by segment_name,segment_type;
```
### 3.15.9 分区表索引段的分配情况

```PLSQL
select segment_name,partition_name,segment_type,bytes from dba_segments where segment_name in (select index_name from dba_indexes where table_name='RANGE_PART_TAB');
```
### 3.15.10 分区索引统计信息

```PLSQL
select t2.table_name,t1.index_name,t1.partition_name,t1.last_analyzed,t1.blevel,t1.num_rows,t1.leaf_blocks,t1.status from dba_ind_partitions t1, dba_indexes t2 where t1.index_name = t2.index_name and t2.table_name='RANGE_PART_TAB'; 
```
## 3.16 索引状态

```plsql
SET linesize 500
col INDEX_COL  FOR a30
col INDEX_TYPE FOR a22
col INDEX_NAME FOR a32
col table_name FOR a32
SELECT B.OWNER || '.' || B.INDEX_NAME INDEX_NAME,
       A.INDEX_COL,
       B.INDEX_TYPE || '-' || B.UNIQUENESS INDEX_TYPE,
       B.PARTITIONED
  FROM (SELECT TABLE_OWNER,
               TABLE_NAME,
               INDEX_NAME,
               SUBSTR(MAX(SYS_CONNECT_BY_PATH(COLUMN_NAME, ',')), 2) INDEX_COL
          FROM (SELECT TABLE_OWNER,
                       TABLE_NAME,
                       INDEX_NAME,
                       COLUMN_NAME,
                       ROW_NUMBER() OVER(PARTITION BY TABLE_OWNER, TABLE_NAME, INDEX_NAME ORDER BY TABLE_OWNER, INDEX_NAME, COLUMN_POSITION, COLUMN_NAME) RN
                  FROM DBA_IND_COLUMNS
                 WHERE TABLE_NAME = UPPER('TEST')
                   AND TABLE_OWNER = UPPER('SCOTT'))
         START WITH RN = 1
        CONNECT BY PRIOR RN = RN - 1
               AND PRIOR TABLE_NAME = TABLE_NAME
               AND PRIOR INDEX_NAME = INDEX_NAME
               AND PRIOR TABLE_OWNER = TABLE_OWNER
         GROUP BY TABLE_NAME, INDEX_NAME, TABLE_OWNER
         ORDER BY TABLE_OWNER, TABLE_NAME, INDEX_NAME) A,
       (SELECT *
          FROM DBA_INDEXES
         WHERE TABLE_NAME = UPPER('TEST')
           AND TABLE_OWNER = UPPER('SCOTT')) B
 WHERE A.TABLE_OWNER = B.TABLE_OWNER
   AND A.TABLE_NAME = B.TABLE_NAME
   AND A.INDEX_NAME = B.INDEX_NAME;  
```

**查看无索引的表**

```plsql
select * from dba_tables where table_name not in (select DISTINCT table_name from dba_indexes  where owner  NOT IN ('MDDATA', 'MDSYS', 'ORDSYS', 'CTXSYS', 
                     'ANONYMOUS', 'EXFSYS', 'OUTLN', 'DIP', 
                     'DMSYS', 'WMSYS', 'XDB', 'ORACLE_OCM', 
                     'TSMSYS', 'ORDPLUGINS', 'SI_INFORMTN_SCHEMA',
                     'OLAPSYS', 'SYSTEM', 'SYS', 'SYSMAN',
                     'DBSNMP', 'SCOTT', 'PERFSTAT', 'PUBLIC',
                     'MGMT_VIEW', 'WK_TEST', 'WKPROXY', 'WKSYS'))
                     and owner  NOT IN ('MDDATA', 'MDSYS', 'ORDSYS', 'CTXSYS', 
                     'ANONYMOUS', 'EXFSYS', 'OUTLN', 'DIP', 
                     'DMSYS', 'WMSYS', 'XDB', 'ORACLE_OCM', 
                     'TSMSYS', 'ORDPLUGINS', 'SI_INFORMTN_SCHEMA',
                     'OLAPSYS', 'SYSTEM', 'SYS', 'SYSMAN',
                     'DBSNMP', 'SCOTT', 'PERFSTAT', 'PUBLIC',
                     'MGMT_VIEW', 'WK_TEST', 'WKPROXY', 'WKSYS');  
```

  **查询索引碎片的比例**

```plsql
select name,del_lf_rows,lf_rows, round(del_lf_rows/decode(lf_rows,0,1,lf_rows)*100,0)||'%' frag_pct from index_stats where round(del_lf_rows/decode(lf_rows,0,1,lf_rows)*100,0)>30;
```

## 3.17 Segment查看

### 3.17.1 segment大小

```plsql
set linesize 120
col USERNAME format a12
col MACHINE format a16
col TABLESPACE format a10
SELECT /* SHSNC */ /*+ RULE */
 SEGMENT_TYPE,
 OWNER SEGMENT_OWNER,
 SEGMENT_NAME,
 TRUNC(SUM(BYTES) / 1024 / 1024, 1) SIZE_MB
  FROM DBA_SEGMENTS
 WHERE OWNER NOT IN ('SYS', 'SYSTEM')
 GROUP BY SEGMENT_TYPE, OWNER, SEGMENT_NAME
HAVING SUM(BYTES) > 100 * 1048576
 ORDER BY 1, 2, 3, 4 DESC;
```

### 3.17.2 某个表空间 segment

This query lists all segments of a tablespace, their status an some usage measurements

```
set lines 137
set pages 10000

clear break

col TSname heading 'TSpace|Name|'
col TSname format a25
col SgmntOwner heading 'Sgmnt|Owner|'
col SgmntOwner format a15
col SgmntType heading 'Sgmnt|Type|'
col SgmntType format a15
col SgmntName heading 'Sgmnt|Name|'
col SgmntName format a35
col MinExt heading 'Min|No of|Ext'
col MinExt format 99999999999
col MaxExt heading 'Max|No of|Ext'
col MaxExt format 99999999999
col SgmntSize heading 'Sgmnt|Size|Mb'
col SgmntSize format 9999
col SgmntExentNo heading 'No of|Extent|'
col SgmntExentNo format 9999999999

SELECT
  ds.tablespace_name as "TSname",
  ds.owner as "SgmntOwner",
  ds.segment_type as "SgmntType",
  ds.segment_name as "SgmntName",
  ds.min_extents as "MinExt",
  ds.max_extents as "MaxExt",
  ROUND(ds.bytes/1024/1024,0) as "SgmntSize",
  SUM(ds.extents) as "SgmntExentNo"
FROM
  dba_segments ds
WHERE tablespace_name = 'SYSAUX'
GROUP BY
  ds.tablespace_name,
  ds.owner,
  ds.segment_type,
  ds.segment_name,
  ds.min_extents,
  ds.max_extents,
  ds.bytes
ORDER BY
  ds.tablespace_name,
  ds.owner,
  ds.segment_type,
  ds.segment_name
;
```


## 3.18 查看UNDO表空间

### 3.18.1 查看UNDO表空间

查看UNDO表空间的大小、可用空间

```plsql
select * from (select
     a.tablespace_name,
     sum(a.bytes)/(1024*1024*1024) total_space_GB,
     round(b.free,2) Free_space_GB,
     round(b.free/(sum(a.bytes)/(1024*1024*1024))* 100,2) percent_free
    from dba_data_files a,
     (select tablespace_name,sum(bytes)/(1024*1024*1024) free  from dba_free_space
     group by tablespace_name) b
   where a.tablespace_name = b.tablespace_name(+)
     group by a.tablespace_name,b.free)
 where tablespace_name like 'UNDO%';
```
### 2.18.2 查看详细的UNDO信息

```plsql
-- 通过v$UNDOSTAT来查看详细的UNDO信息
SELECT TO_CHAR(BEGIN_TIME, 'MM/DD/YYYY HH24:MI:SS') BEGIN_TIME,TO_CHAR(END_TIME, 'MM/DD/YYYY HH24:MI:SS') END_TIME,UNDOTSN, UNDOBLKS, TXNCOUNT, MAXCONCURRENCY AS "MAXCON" FROM v$UNDOSTAT WHERE rownum <= 100;

BEGIN_TIME表示每条记录UNDO事务开始的时间
END_TIMEE表示每条记录UNDO事务结束的时间
上面每条记录的间隔是10分钟
UNDOTSN 在这段时间undo事务的数量
UNDOBLKS在这段时间占用的undo块的数量
TXNCOUNT事务的总数量
MAXCON这些UNDO事务过程中的最大数据库连接数

-- 查看各个undo段的使用信息
select a.name,b.extents,b.rssize,b.writes,b.xacts,b.wraps from v$rollname a,v$rollstat b where a.usn=b.usn;

-- 确定哪些用户正在使用undo段
select a.username,b.name,c.used_ublk from v$session a,v$rollname b,v$transaction c where a.saddr=c.ses_addr and b.usn=c.xidusn;

-- 每秒生成的UNDO量
SELECT (SUM(undoblks))/ SUM((end_time - begin_time) * 86400) FROM v$undostat;

-- 当前undo表空间使用状态
SELECT DISTINCT STATUS,SUM(BYTES),COUNT(*) FROM DBA_UNDO_EXTENTS GROUP BY STATUS;

-- 查看活动事务v$transaction
SELECT A.SID, A.USERNAME, B.XIDUSN, B.USED_UREC, B.USED_UBLK FROM V$SESSION A, V$TRANSACTION B WHERE A.SADDR=B.SES_ADDR;

SELECT XID AS "txn_id", XIDUSN AS "undo_seg", USED_UBLK "used_undo_blocks",XIDSLOT AS "slot", XIDSQN AS "seq", STATUS AS "txn_status" FROM V$TRANSACTION;

-- 查询事务使用的UNDO段及大小
select s.sid,s.serial#,s.sql_id,v.usn,segment_name,r.status, v.rssize/1024/1024 mb
From dba_rollback_segs r, v$rollstat v,v$transaction t,v$session s
Where r.segment_id = v.usn and v.usn=t.xidusn and t.addr=s.taddr
order by segment_name ;

select usn,xacts,rssize/1024/1024/1024,hwmsize/1024/1024/1024,shrinks
from v$rollstat order by rssize;
```
### 3.18.3 UNDO表空间管理

```plsql
-- 创建UNDO表空间：
create undo tablespace undotbs3 datafile '/data1/oradata/undotbs03_1.dbf' size 100M autoextend on next 20M maxsize 500M;

上面命令中，指定UNDO表空间名称、对应数据文件、初始大小、自动扩展、每次扩展大小、最大扩展到多大

-- 给UNDO表空间增加数据文件：
ALTER TABLESPACE UNDOTBS3 ADD DATAFILE '/data1/oradata/undotbs03_2.dbf' SIZE 1024M AUTOEXTEND ON NEXT 100M MAXSIZE 2048M;

-- 切换默认UNDO表空间：
alter system set undo_tablespace = UNDOTBS3;
```

### 3.18.4 UNDO参数

```plsql
show parameter undo

-- 更改UNDO RETENTION
alter system set UNDO_RETENTION = 1800;

SELECT TO_CHAR(BEGIN_TIME, 'YYYY-MM-DD HH24:MI:SS') BEGIN_TIME,TUNED_UNDORETENTION FROM V$UNDOSTAT;
```

### 3.18.5 UNDO参数建议

```plsql
set serveroutput on;
DECLARE
tablespacename        varchar2(30);
tablespacesize        number;
autoextend            boolean;
autoextendtf          char(5);
undoretention         number;
retentionguarantee    boolean;
retentionguaranteetf  char(5);
autotuneenabled       boolean;
autotuneenabledtf     char(5);
longestquery          number;
requiredretention     number;
bestpossibleretention number;
requireundosize       number;


problem               varchar2(100);
recommendation        varchar2(100);
rationale             varchar2(100);
retention             number;
utbsize               number;
nbr                   number;
undoadvisor           varchar2(100);
instancenumber        number;
ret                   boolean;
rettf                 char(5);
BEGIN
   dbms_output.put_line('--x--x--x--x--x--x--x');
   dbms_output.put_line('--undo_info');
   dbms_output.put_line('--x--x--x--x--x--x--x');
   ret := dbms_undo_adv.undo_info(tablespacename,
tablespacesize,
          autoextend, undoretention,
retentionguarantee);
   if ret then rettf := 'TRUE'; else rettf :=
'FALSE'; end if;
   if autoextend then autoextendtf := 'TRUE';
      else autoextendtf := 'FALSE'; end if;
   if retentionguarantee then retentionguaranteetf
:= 'TRUE';
      else retentionguaranteetf := 'FALSE'; end if;
   dbms_output.put_line ('Information Valid    :
'||rettf);
   dbms_output.put_line ('Tablespace Name      :
'||tablespacename);
   dbms_output.put_line ('Tablespace Size      :
'||tablespacesize);
   dbms_output.put_line ('Extensiable          :
'||autoextendtf);
   dbms_output.put_line ('undo_retention       :
'||undoretention);
   dbms_output.put_line ('Guaranteed Retention :
'||retentionguaranteetf);


   dbms_output.put_line('--x--x--x--x--x--x--x');
   dbms_output.put_line('--undo_health');
   dbms_output.put_line('--x--x--x--x--x--x--x');
   nbr := dbms_undo_adv.undo_health(problem,
recommendation, rationale, retention, utbsize);
   dbms_output.put_line ('Information Valid    :
'||nbr);
   dbms_output.put_line ('Problem              :
'||problem);
   dbms_output.put_line ('Recommendation       :
'||recommendation);
   dbms_output.put_line ('Rationale            :
'||rationale);
   dbms_output.put_line ('Retention            :
'||retention);
   dbms_output.put_line ('UTBSize              :
'||utbsize);


   dbms_output.put_line('--x--x--x--x--x--x--x');
   dbms_output.put_line('--undo_advisor');
   dbms_output.put_line('--x--x--x--x--x--x--x');
   select instance_number into instancenumber from
v$instance;
   undoadvisor :=
dbms_undo_adv.undo_advisor(instancenumber);
   dbms_output.put_line ('Undo Advisor         :
'||undoadvisor);


   dbms_output.put_line('--x--x--x--x--x--x--x');
   dbms_output.put_line('--undo_autotune');
   dbms_output.put_line('--x--x--x--x--x--x--x');
   ret :=
dbms_undo_adv.undo_autotune(autotuneenabled);
   if autotuneenabled then autotuneenabledtf :=
'TRUE';
       else autotuneenabledtf := 'FALSE'; end if;
   dbms_output.put_line ('Auto Tuning Enabled  :
'||autotuneenabledtf);


   dbms_output.put_line('--x--x--x--x--x--x--x');
   dbms_output.put_line('--longest_query');
   dbms_output.put_line('--x--x--x--x--x--x--x');
   longestquery :=
dbms_undo_adv.longest_query(sysdate-1,sysdate);
   dbms_output.put_line ('Longest Run Query    :
'||longestquery);


   dbms_output.put_line('--x--x--x--x--x--x--x');
   dbms_output.put_line('--required_retention');
   dbms_output.put_line('--x--x--x--x--x--x--x');
   requiredretention :=
dbms_undo_adv.required_retention;
   dbms_output.put_line ('Required Retention   :
'||requiredretention);


   dbms_output.put_line('--x--x--x--x--x--x--x');
  
dbms_output.put_line('--best_possible_retention');
   dbms_output.put_line('--x--x--x--x--x--x--x');
   bestpossibleretention :=
dbms_undo_adv.best_possible_retention;
   dbms_output.put_line ('Best Retention       :
'||bestpossibleretention);


   dbms_output.put_line('--x--x--x--x--x--x--x');
   dbms_output.put_line('--required_undo_size');
   dbms_output.put_line('--x--x--x--x--x--x--x');
   requireundosize := dbms_undo_adv.required_undo_size(444);
   dbms_output.put_line ('Required Undo Size   :
'||requireundosize);

END;
/
```

## 3.19 查看表修改记录

```plsql
select * from dba_tab_modifications;
```

## 4.20 Oracle 12c/19c 参数优化

```plsql
-- 12c
alter system set deferred_segment_creation=false;
alter system set audit_trail =none scope=spfile;
alter system set sga_max_size =xxxxxm scope=spfile;
alter system set sga_target =xxxxxm scope=spfile;
alter system set pga_aggregate_target =xxxxxm scope=spfile;
alter profile default limit password_life_time unlimited;
alter database add supplemental log data;
alter system set enable_ddl_logging=true;
-- 关闭密码延迟验证新特性
alter system set event = '28401 trace name context forever, level 1' scope = spfile;
-- 限制trace日志文件大最大25m
alter system set max_dump_file_size ='25m';
alter system set db_files=2000 scope=spfile;
-- 如果修改了监听端口（默认1521）修改local_listener
alter system set local_listener = '(address = (protocol = tcp)(host = 192.168.0.125)
(port = 2016))' ;
-- 更改控制文件记录保留时间
alter system set control_file_record_keep_time =31;
alter system set "_report_capture_cycle_time"=0;
alter system set "_optimizer_ads_use_result_cache" = false;
alter system set "_use_single_log_writer"=true sid='*' scope=spfile;
alter system set "_optimizer_aggr_groupby_elim"=false scope=both;
alter system set "_optimizer_reduce_groupby_key"=false scope=both;
alter system set "_enable_pdb_close_abort"=true;
alter system set "_enable_pdb_close_noarchivelog"=true;
alter system set "_drop_stat_segment"=1;
alter system set "_common_data_view_enabled"=false;
alter system set "_optimizer_dsdir_usage_control"=0;
alter system set "_optimizer_gather_feedback"=false;
alter system set "_optimizer_enable_extended_stats"=false;
alter system set "_datafile_write_errors_crash_instance"=false;
alter system set awr_pdb_autoflush_enabled= true sid='*' scope=both;
alter system set awr_snapshot_time_offset=1000000 sid='*' scope=both;

--19c
alter system set db_file_multiblock_read_count=32 scope=spfile sid='*';
alter system set max_dump_file_size = '500M' scope=spfile sid='*';
alter system set "_memory_imm_mode_without_autosga"=FALSE scope=spfile sid='*';
alter system set job_queue_processes=100 scope=spfile sid='*';
alter system set DB_FILES=4096 scope=spfile sid='*';
alter system set nls_date_format='YYYY-MM-DD HH24:MI:SS' scope=spfile sid='*';
alter system set open_cursors=3000 scope=spfile sid='*';
alter system set open_links_per_instance=48 scope=spfile sid='*';
alter system set open_links=100 scope=spfile sid='*';
alter system set parallel_max_servers=20 scope=spfile sid='*';
alter system set session_cached_cursors=200 scope=spfile sid='*';
alter system set undo_retention=10800 scope=spfile sid='*';
alter system set "_undo_autotune"=false scope=spfile sid='*';
alter system set "_partition_large_extents"=false scope=spfile sid='*';
alter system set "_use_adaptive_log_file_sync"=false scope=spfile sid='*';
alter system set "_optimizer_use_feedback"=false scope=spfile sid='*';
alter system set deferred_segment_creation=false scope=spfile sid='*';
alter system set "_external_scn_logging_threshold_seconds"=600 scope=spfile sid='*';
alter system set "_external_scn_rejection_threshold_hours"=24 scope=spfile sid='*';
alter system set result_cache_max_size=0 scope=spfile sid='*';
alter system set "_cleanup_rollback_entries"=2000 scope=spfile sid='*';
alter system set parallel_force_local=true scope=spfile sid='*';   --rac
alter system set "_gc_policy_time"=0 scope=spfile sid='*';
alter system set "_clusterwide_global_transactions"=false scope=spfile sid='*'; 
alter system set "_library_cache_advice"=false scope=both sid='*';
alter system set db_cache_advice=off scope=both sid='*';
alter system set filesystemio_options=setall scope=spfile sid='*';
alter system set fast_start_mttr_target=300 scope=spfile sid='*';
alter profile default limit PASSWORD_LIFE_TIME   UNLIMITED;
alter profile  ORA_STIG_PROFILE limit  PASSWORD_LIFE_TIME   UNLIMITED;

begin
 DBMS_AUTO_TASK_ADMIN.DISABLE(
 client_name => 'sql tuning advisor',
 operation => NULL,
 window_name => NULL);
end;
/

begin
 DBMS_AUTO_TASK_ADMIN.DISABLE(
 client_name => 'auto space advisor',
 operation => NULL,
 window_name => NULL);
end;
/
```

## 4.21 19c In-Memory

```plsql
-- 查看In-Memeory
select * from  v$im_column_level;
SELECT * FROM V$IM_SEGMENTS;

-- 查看In-Memeory大小
select pool,ALLOC_BYTES/1024/1024,USED_BYTES/1024/1024,POPULATE_STATUS,con_id 
from V$INMEMORY_AREA;

--查看In-Memeory级别
select * from dba_tables；
-- PRIORITY NONE	缺省级别；执行 SQL 引起对象扫描后，触发进入 IN-MEMORY
-- PRIORITY CRITICAL	最高优先级；数据库启动后立即进入 IN-MEMORY
-- PRIORITY HIGH	在具有 CRITICAL 优先级的对象之后进入 IN-MEMORY
-- PRIORITY MEDIUM	在具有 CRITICAL、HIGH 优先级的对象之后进入 IN-MEMORY
-- PRIORITY LOW	在具有 CRITICAL、HIGH、MEDIUM 优先级的对象之后进入 IN-MEMORY
alter table test inmemory priority high;

-- 开启In-Memeory
create table test (id number) inmemory;
alter table test inmemory;
alter table imo_t1 inmemory (id) no inmemory (name,type); 

-- 可以通过如下初始创建表空间或后续修改表空间 inmemory 属性的方式进行启用，在属性为 inmemory 的表空间中创建的对象自动加载 inmemory 属性，除非显示设置对象为 no inmemory：
create tablespace imotest datafile '/oradata/orcl/imotest01.dbf' size 100M default inmemory;
alter tablespace imotest default inmemory;

--关闭inmemory
alter table test no inmemory;

--手工执行DBMS_INMEMORY.POPULATE procedure来加载TEST表到IM中
EXEC DBMS_INMEMORY.POPULATE('CS','TEST');
EXEC DBMS_INMEMORY.REPOPULATE('CS','TEST', FORCE=>TRUE);

-- 通过全表扫描objects加载数据到IM
SELECT /*+ FULL (s) */ COUNT(*) FROM test s;
```

## 4.22 查看EXPDP/IMPDP JOB

```plsql
set lines 150 pages 100 numwidth 7
col program for a38
col username for a10
col spid for a7
select s.program, s.sid,
s.status, s.username, d.job_name, p.spid, s.serial#, p.pid
from v$session s, v$process p, dba_datapump_sessions d
where p.addr=s.paddr and s.saddr=d.saddr;

select * from GV$DATAPUMP_SESSION;
```

## 5.1 静默安装

```sh
# RAC
su oracle -c "$ORACLE_HOME/bin/dbca -silent -createDatabase -templateName
General_Purpose.dbc -gdbName $DBNAME -sid $ORACLE_SID -sysPassword password
-systemPassword password -sysmanPassword password -dbsnmpPassword password
-emConfiguration LOCAL -storageType ASM -diskGroupName ASMgrp1
-datafileJarLocation $ORACLE_HOME/assistants/dbca/templates -nodeinfo
node1,node2 -characterset WE8ISO8859P1 -obfuscatedPasswords false -sampleSchema
false -asmSysPassword password"

# SingleInstance
dbca -silent -createDatabase -templateName General_Purpose.dbc
  -gdbname ora11g -sid ora11g -responseFile NO_VALUE -characterSet AL32UTF8
  -memoryPercentage 30 -emConfiguration LOCAL
```

## 5.2 SYS_CONTEXT函数

```plsql
select
SYS_CONTEXT('USERENV','TERMINAL') terminal,
SYS_CONTEXT('USERENV','LANGUAGE') language,
SYS_CONTEXT('USERENV','SESSIONID') sessionid,
SYS_CONTEXT('USERENV','INSTANCE') instance,
SYS_CONTEXT('USERENV','ENTRYID') entryid,
SYS_CONTEXT('USERENV','ISDBA') isdba,
SYS_CONTEXT('USERENV','NLS_TERRITORY') nls_territory,
SYS_CONTEXT('USERENV','NLS_CURRENCY') nls_currency,
SYS_CONTEXT('USERENV','NLS_CALENDAR') nls_calendar,
SYS_CONTEXT('USERENV','NLS_DATE_formAT') nls_date_format,
SYS_CONTEXT('USERENV','NLS_DATE_LANGUAGE') nls_date_language,
SYS_CONTEXT('USERENV','NLS_SORT') nls_sort,
SYS_CONTEXT('USERENV','CURRENT_USER') current_user,
SYS_CONTEXT('USERENV','CURRENT_USERID') current_userid,
SYS_CONTEXT('USERENV','SESSION_USER') session_user,
SYS_CONTEXT('USERENV','SESSION_USERID') session_userid,
SYS_CONTEXT('USERENV','PROXY_USER') proxy_user,
SYS_CONTEXT('USERENV','PROXY_USERID') proxy_userid,
SYS_CONTEXT('USERENV','DB_DOMAIN') db_domain,
SYS_CONTEXT('USERENV','DB_NAME') db_name,
SYS_CONTEXT('USERENV','HOST') host,
SYS_CONTEXT('USERENV','OS_USER') os_user,
SYS_CONTEXT('USERENV','EXTERNAL_NAME') external_name,
SYS_CONTEXT('USERENV','IP_ADDRESS') ip_address,
SYS_CONTEXT('USERENV','NETWORK_PROTOCOL') network_protocol,
SYS_CONTEXT('USERENV','BG_JOB_ID') bg_job_id,
SYS_CONTEXT('USERENV','FG_JOB_ID') fg_job_id,
SYS_CONTEXT('USERENV','AUTHENTICATION_DATA') authentication_data
FROM dual;
```

## 5.3 查看业务用户

```plsql
select USERNAME,CREATED from dba_users where DEFAULT_TABLESPACE not in('SYSTEM','SYSAUX') AND username not in('ANONYMOUS','APEX_030200', 'APEX_PUBLIC_USER', 'APPQOSSYS', 'CTXSYS', 'DIP', 'EXFSYS', 'FLOWS_FILES', 'MDDATA', 'OLAPSYS', 'ORACLE_OCM','ORDDATA', 
 'ORDPLUGINS', 'ORDSYS', 'OUTLN','OWBSYS', 'OWBSYS_AUDIT', 'SI_INFORMTN_SCHEMA', 'SPATIAL_CSW_ADMIN_USR', 'SPATIAL_WFS_ADMIN_USR', 'SYS', 'SYSTEM', 'WMSYS','XDB','XS$NULL','SCOTT','DBSNMP','SYSMAN','MGMT_VIEW','MDSYS');
```

## 5.4 资源管理计划

```plsql
select resource_name,max_utilization,initial_allocation,limit_value from v$resource_limit;

-- 方法一：禁用资源调整：
1.在线修改；
如果resource_manager_plan null可以无需重复设置
ALTER system SET resource_manager_plan=’’;
EXECUTE dbms_scheduler.set_attribute(‘WEEKNIGHT_WINDOW’,‘RESOURCE_PLAN’,’’);
EXECUTE dbms_scheduler.set_attribute(‘WEEKEND_WINDOW’,‘RESOURCE_PLAN’,’’);
EXECUTE dbms_scheduler.set_attribute(‘MONDAY_WINDOW’,‘RESOURCE_PLAN’,’’);
EXECUTE dbms_scheduler.set_attribute(‘TUESDAY_WINDOW’,‘RESOURCE_PLAN’,’’);
EXECUTE dbms_scheduler.set_attribute(‘WEDNESDAY_WINDOW’,‘RESOURCE_PLAN’,’’);
EXECUTE dbms_scheduler.set_attribute(‘THURSDAY_WINDOW’,‘RESOURCE_PLAN’,’’);
EXECUTE dbms_scheduler.set_attribute(‘FRIDAY_WINDOW’,‘RESOURCE_PLAN’,’’);
EXECUTE dbms_scheduler.set_attribute(‘SATURDAY_WINDOW’,‘RESOURCE_PLAN’,’’);
EXECUTE dbms_scheduler.set_attribute(‘SUNDAY_WINDOW’,‘RESOURCE_PLAN’,’’);
2.如果上述操作没有生效，或者能够重启的情况下执行
alter system set “_resource_manager_always_on” = false scope=spfile;

-- 方法二：
alter system set resource_limit=true sid='*' scope=spfile;
alter system set resource_manager_plan='force:' sid='*' scope=spfile;
说明：这两个参数用于将资源管理计划强制设置为“空”，避免Oracle 自动打开维护窗口（每晚22:00 到早上6:00，周末全天）的资源计划（resource manager plan），使系统在维护窗口期间资源不足或触发相应的BUG。
```

## 5.5 动态性能视图

```plsql
-- 基表
select * from v$fixed_table;
-- 动态性能视图定义
select * from v$fixed_view_definition;
-- 数据字典
select * from dba_views;
select * from dict where table_name like 'DBA_HIST_%';
```

## 5.6 DataGuard管理

**Start Standby Database**

> startup nomount
>
> alter database mount standby database;
>
> alter database recover managed standby database disconnect;


**Disable/Enable archive log destinations**

> alter system set log_archive_dest_state_2 = 'defer';
>
> alter system set log_archive_dest_state_2 = 'enable';


**To remove a delay from a standby**

> alter database recover managed standby database cancel;
>
> alter database recover managed standby database nodelay disconnect;

**Stop and Start of Logical standby apply**

> alter database stop logical standby apply;
> alter database start logical standby apply;


**Physical Standby switchover:**
In Primary Database：

> ALTER DATABASE COMMIT TO SWITCHOVER TO PHYSICAL STANDBY;
>
> SHUTDOWN IMMEDIATE;
>
> STARTUP NOMOUNT;
>
> ALTER DATABASE MOUNT STANDBY DATABASE;


In standby Database:

> ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY;
>
> SHUTDOWN IMMEDIATE;
>
> STARTUP;


In Primary Database:

> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;


If the primary Database is down,we can use fllowing step to active standby database:

> Alter DATABASE RECOVER MANAGED STANDBY DATABASE FINISH;
> Alter DATABASE COMMIT TO SWITCHOVER TO PRIMARY;
> SHUTDOWN IMMEDIATE;
> STARTUP;


**Register missing archive log file**
Find archive log gap by query:

> SELECT THREAD#, LOW_SEQUENCE#, HIGH_SEQUENCE# FROM V$ARCHIVE_GAP;


register using:

> ALTER DATABASE REGISTER PHYSICAL LOGFILE 'filespec1';

**切换保护**

> alter database set standby database to maximize availability;
>
> alter database set standby database to maximize protection;
>
> alter database set standby database to maximize performa

## 5.7 回滚段使用

查询回滚段的信息。所用数据字典： DBA_ROLLBACK_SEGS，可以查询的信息：回滚段的标识(SEGMENT_ID)、名称(SEGMENT_NAME)、所在表空间(TABLESPACE_NAME)、类型(OWNER)、状态(STATUS)。
>select * from DBA_ROLLBACK_SEGS;

查看回滚段的统计信息
```plsql
SELECT n.name, s.extents, s.rssize, s.optsize, s.hwmsize, s.xacts,
s.status
FROM v$rollname n, v$rollstat s
WHERE n.usn = s.usn;
```
查看回滚段的使用情况，哪个用户正在使用回滚段的资源:
```plsql
select s.username, u.name
from v$transaction t, v$rollstat r, v$rollname u, v$session s
where s.taddr = t.addr
and t.xidusn = r.usn
and r.usn = u.usn
order by s.username; 
```

## 5.8 查看表的DDL

```plsql
-- 查看表的索引
SELECT
    col.table_owner    "table_owner",
    idx.table_name     "table_name",
    col.index_owner    "index_owner",
    idx.index_name     "index_name",
    uniqueness         "uniqueness",
    status,
    column_name        "column_name",
    column_position
FROM
    dba_ind_columns  col,
    dba_indexes      idx
WHERE
        col.index_name = idx.index_name
    AND col.table_name = idx.table_name
    AND col.table_owner = idx.table_owner
    AND col.table_owner = '&owner'
    AND col.table_name = '&table_name'
ORDER BY
    idx.table_type,
    idx.table_name,
    idx.index_name,
    col.table_owner,
    column_position;
    
-- 后台执行操作，导出建表语句：使用表归属用户登录（不推荐，适用场景在PL/SQL无法登录场景）
EXECUTE DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'STORAGE',false);
-- 生成建表语句：
SELECT DBMS_METADATA.GET_DDL('TABLE',u.table_name) FROM USER_TABLES u where table_name=upper('tablename');
-- 生成建索引语句：
SELECT DBMS_METADATA.GET_DDL('INDEX',u.index_name) FROM USER_INDEXES u where table_name=upper('tablename');
-- 生成建限制语句：
SELECT DBMS_METADATA.GET_DDL('CONSTRAINT',u.CONSTRAINT_NAME) FROM user_constraints u where table_name=upper('tablename');
```

## 5.9 CPU占用率高的进程

```plsql
 -- 根据CPU占用率高的进程号查询对应的SQL操作
 alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss'; 
 select a.osuser,a.machine,a.sid,a.serial#,a.program,a.status,a.client_info,b.SQL_ID,b.sql_text from v$session a,v$sqlarea b where a.sql_hash_value=b.hash_value and a.sid in (select s.sid from v$session s,v$process p where p.spid=27697 and s.paddr=p.addr); 
 select sid,event,sql_id,program,machine,blocking_session,blocking_instance,p1,p2 from v$session where event not like 'S%';
```

## 5.10 阻塞会话

```plsql
-- 查询被阻塞Session信息和blocking_session信息。
select BLOCKING_SESSION,count(*) from v$session where BLOCKING_SESSION!=0 group by BLOCKING_SESSION;

-- 如果有记录，则说明存在blocking_session，执行以下SQL进一步分析。
select a.osuser,a.machine,a.sid,a.serial#,a.program,a.status,b.SQL_ID, b.sql_text, a.blocking_session,a.p1,a.p2 from v$session a,v$sqlarea b where a.sql_hash_value=b.hash_value and a.BLOCKING_SESSION!=0;

--如果有记录，则说明记录中的sid被blocking_session对应的操作阻塞。根据查询出来的“blocking_session”查询对应的操作信息。查询正在运行的SQL信息。
select a.osuser,a.machine,a.sid,a.serial#,a.program,a.status,b.SQL_ID, b.sql_text from v$session a,v$sqlarea b where a.sql_hash_value=b.hash_value and a.sid in (select distinct BLOCKING_SESSION from v$session where BLOCKING_SESSION!=0);

-- 如果能查询到记录，则说明可能是因为这个SQL执行慢，导致其它session被阻塞，此时需要等待SQL执行完毕以解锁；如果查询不到记录，则说明可能是因为某次执行了更新，未commit提交导致锁表，需要通过后续步骤判断是否有锁存在。

-- 查询锁信息。
select o.object_name, s.osuser,s.machine, s.program, s.status,s.sid,s.serial#,p.spid from v$locked_object l,dba_objects o,v$session s,v$process p where l.object_id=o.object_id and l.session_id=s.sid and s.paddr=p.addr
and s.sid in (select distinct BLOCKING_SESSION from v$session where BLOCKING_SESSION!=0);

--查询目前锁对象信息
select sid,serial#,username,SCHEMANAME,osuser,MACHINE,terminal,PROGRAM,owner,object_name,object_type,o.object_id  from dba_objects o,v$locked_object l,v$session s where o.object_id = l.object_id and s.sid = l.session_id; 

-- 杀会话
alter system kill session '1568,27761,@2' immediate; 
```

## 5.11  keep_buffer_pool

```plsql
 alter system set db_keep_cache_size=100m scope=both;
 
 -- 查看keep pool剩余大小
 select p.name,a.cnum_repl "total buffers",a.anum_repl "free buffers" from x$kcbwds a, v$buffer_pool p where a.set_id=p.LO_SETID and p.name='KEEP';  
 
 -- 查看当前keep pool的大小：
 select component,current_size from v$sga_dynamic_components where component='KEEP buffer cache';
 
  -- 查看keep pool的建议大小
 SELECT size_for_estimate,buffers_for_estimate,estd_physical_read_factor,estd_physical_reads FROM v$db_cache_advice WHERE name = 'KEEP' AND block_size = (SELECT value FROM v$parameter  WHERE name = 'db_block_size') AND advice_status = 'ON'；

-- 查看哪些表使用keep buffer
SELECT * FROM dba_segments WHERE segment_type = 'KEEP'；
SELECT * FROM dba_tables WHERE buffer_pool = 'KEEP'；

-- 修改表或索引的结构
alter table xxx storage(buffer_pool keep);
CREATE INDEX cust_idx ... STORAGE (BUFFER_POOL KEEP);
ALTER TABLE customer STORAGE (BUFFER_POOL KEEP);
ALTER INDEX cust_name_idx STORAGE (BUFFER_POOL KEEP);  

-- 同时要修改表的cache属性：
Alter table xxx cache;
-- 也可以在表创建时直接指定相应的属性：
create table aaa(i int) storage (buffer_pool keep);
create table bbb(i int) storage (buffer_pool keep) cache;
    
--观察表的cache情况及大小：
select table_name,cache,blocks from user_tables where buffer_pool='KEEP';

--查看哪些表被放在缓存区 但并不意味着该表已经被缓存 
select table_name from dba_tables where buffer_pool='KEEP';

--查询到该表是否已经被缓存 
select table_name,cache,buffer_pool from user_TABLES where cache like '%Y';

--已经加入到KEEP区的表想要移出缓存，使用 
alter table table_name nocache;  

--对于普通LOB类型的segment的cache方法 
alter table t2 modify lob(c2) (storage (buffer_pool keep) cache);  

--取消缓存 
alter table test modify lob(address) (storage (buffer_pool keep) nocache);  

--对基于CLOB类型的对象的cache方法   
alter table lob1 modify lob(c1.xmldata) (storage (buffer_pool keep) cache);   

--查询该用户下所有表内的大字段情况 
select column_name,segment_name from user_lobs;   
```

## 5.12 表CACHE

```plsql
-- 创建表对象时使用cache，如下面的例子
  create table tb_test
        (id number,name varchar2(20),
         sex  char(1),
         age  number,
         score number)
         tablespace users
         storage(initial 50k next 50k pctincrease 0)
         cache;    --指定cache子句
 
-- 使用alter table 修改已经存在的表
alter table scott.emp cache;

-- 可以使用nocache来修改对象，使其不具备cache属性
alter table soctt.emp nocache
       
-- 使用hint提示符来实现cache
select /*+ cache*/ empno,ename from scott.emp; 
```

**注意** cache table*与*keep buffer pool*的异同

  两者的目的都是尽可能将最热的对象置于到buffer pool，尽可能的避免aged out。cache table是将对象置于到default buffer cache。  而使用buffer_pool keep子句是将对象置于到keep buffer pool.buffer_pool和cache同时指定时，keep比cache有优先权。*buffer_pool*用来指定存贮使用缓冲池，而cache/nocache指定存储的方式(LRU或MRU端)。建表时候不注明的话,nocache是默认值。

## 5.13 族表

```plsql
-- 集群因子clustering_factor高的表,集群因子越接近块数越好，接近行数则说明索引列的列值相等的行分布极度散列，可能不走索引扫描而走全表扫描
select tab.table_name,tab.blocks,tab.num_rows,ind.index_name,ind.clustering_factor,
round(nvl(ind.clustering_factor,1)/decode(tab.num_rows,0,1,tab.num_rows),3)*100||'%' "集群因子接近行数"
from user_tables tab, user_indexes ind where tab.table_name=ind.table_name
and tab.blocks>100
and nvl(ind.clustering_factor,1)/decode(tab.num_rows,0,1,tab.num_rows) between 0.35 and 3
```

## 5.14 停掉NTP，配置CTSSD

- 在RAC各个节点先停掉NTPD
- cluvfy comp clocksync
- 将RAC各个节点的NTP配置文件/etc/ntp.conf改名
- 重启GI

## 5.15 查看服务器资源

```plsqlSELECT * FROM v$osstat;
SELECT * FROM v$osstat;

select * from V$SYSSTAT;
```

## 5.17 序列

```plsql
select * from DBA_SEQUENCES  where  sequence_owner  NOT IN ('MDDATA', 'MDSYS', 'ORDSYS', 'CTXSYS', 
                     'ANONYMOUS', 'EXFSYS', 'OUTLN', 'DIP', 
                     'DMSYS', 'WMSYS', 'XDB', 'ORACLE_OCM', 
                     'TSMSYS', 'ORDPLUGINS', 'SI_INFORMTN_SCHEMA',
                     'OLAPSYS', 'SYSTEM', 'SYS', 'SYSMAN',
                     'DBSNMP', 'SCOTT', 'PERFSTAT', 'PUBLIC',
                     'MGMT_VIEW', 'WK_TEST', 'WKPROXY', 'WKSYS');
                     
                     
  select * from gv$enqueue_stat;
  
  ALTER SEQUENCE schema_name.sequence_name
    [INCREMENT BY interval]
    [MAXVALUE max_value | NOMAXVALUE]
    [MINVALUE min_value | NOMINVALUE]
    [CYCLE | NOCYCLE]
    [CACHE cache_size | NOCACHE]
    [ORDER | NOORDER];
```

