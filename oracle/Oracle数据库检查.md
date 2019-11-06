[TOC]

# **Oracle数据库检查**

## 1.1 Oracle实例运行时间

```plsql
col running format a30
select to_char(startup_time, 'DD-MON-YYYY HH24:MI:SS') starttime,
TRUNC(sysdate - (startup_time)) || 'days' ||
TRUNC(24 *
((sysdate - startup_time) - TRUNC(sysdate - startup_time))) ||
'hours' || MOD(TRUNC(1440 * ((SYSDATE - startup_time) -
TRUNC(sysdate - startup_time))),
60) || 'min' ||
MOD(TRUNC(86400 *
((SYSDATE - STARTUP_TIME) - TRUNC(SYSDATE - startup_time))),
60) || 's' running
from v$instance;

-- RAC
alter session set NLS_DATE_FORMAT='YYYY-MM-DD HH24:MI:SS';
select INSTANCE_NUMBER,INSTANCE_NAME,HOST_NAME,STARTUP_TIME ,STATUS from sys.gv_$instance; 
```

## 1.2  查看cursors

**查询session_cached_cursors和 open_cursors 的使用率(每个实例)**

```plsql
col value for a15
col usage for a15
select 'session_cached_cursors' parameter,
lpad(value, 5) value,
decode(value, 0, ' n/a', to_char(100 * used / value, '990') || '%') usage
from (select max(s.value) used
from v$statname n, v$sesstat s
where n.name = 'session cursor cache count'
and s.statistic# = n.statistic#),
(select value from v$parameter where name = 'session_cached_cursors')
union all
select 'open_cursors',
lpad(value, 5),
to_char(100 * used / value, '990') || '%'
from (select max(sum(s.value)) used
from v$statname n, v$sesstat s
where n.name in ('opened cursors current')
and s.statistic# = n.statistic#
group by s.sid),
(select value from v$parameter where name = 'open_cursors');
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
select a.group_number,b.name as group_name,a.name,a.path,a.state,a.total_mb from v$asm_disk a,v$asm_diskgroup b where a.group_number=b.group_number;
```

```plsql
-- 挂在磁盘组
alter diskgroup data mount;
asmcmd> lsdg
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
find /u01/app/oracle/admin/orcl/adump -name "*.aud" -print0 |xargs -0 rm -f
```

## 1.6 查看集群运行状态

```
crs_stat -t -v											-- 10g
crs_stat -t												-- 10g
crsctl status res -t									 -- 11g
crsctl status res -t -init
crsctl check crs                                             -- 10g或11g
crsctl check cluster                                         -- 11g
olsnodes -n
或
olsnodes -n -i -s -t 
srvctl status asm -a                                         -- 11g
srvctl status database -d sdbip
srvctl status diskgroup -g DGDATA1
gpnptool get
cemutlo -n
srvctl status listener -l LISTENER
srvctl status service -d spectra -v
lsnrctl status listener_scan1
lsnrctl services          OR         lsnrctl serice
srvctl status  scan_listener
srvctl config listener -l LISTENER
srvctl config listener -l LISTENER -a
srvctl config scan
crsctl stat res ora.LISTENER_SCAN1.lsnr -p
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
```

## 1.9 检查vote、ocr磁盘状态

```
crsctl query css votedisk
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

### 2.2.2 补丁安装情况1

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
```

## 2.4 数据库时区

```plsql
-- 数据库时区
select dbtimezone from dual ;  
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
 NAME, ISDEFAULT, ISSES_MODIFIABLE SESMOD, ISSYS_MODIFIABLE SYSMOD, VALUE
  FROM V$PARAMETER
 WHERE NAME LIKE '%' || LOWER('process') || '%'
   AND NAME <> 'control_files'
   AND NAME <> 'rollback_segments';
```

### 2.5.1 非默认参数

```plsql
Col name for a20
Col value for a40
select num,name,value FROM V$PARAMETER where isdefault='FALSE';

select inst_id,NUM,name,value from GV$SYSTEM_PARAMETER2 where isdefault = 'FALSE' OR ismodified != 'FALSE' order by inst_id;
```

### 2.5.2 查看已废弃参数

```plsql
SELECT name from v$parameter WHERE isdeprecated = 'TRUE' ORDER BY name;
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
SELECT /* SHSNC */
 P.KSPPINM NAME, V.KSPPSTVL VALUE
  FROM SYS.X$KSPPI P, SYS.X$KSPPSV V
 WHERE P.INDX = V.INDX
   AND V.INST_ID = USERENV('Instance')
   AND SUBSTR(P.KSPPINM, 1, 1) = '_'
   AND ('PROCESS' IS NULL OR P.KSPPINM LIKE '%' || LOWER('process') || '%');
```

### 2.5.3 查看参数

```
show parameter audit_trail
show parameter max_dump_file_size
show parameter processes
show parameter sga_max_size
show parameter sga_target
show parameter spfile
show parameter memory_target
show parameter memory_max_target
show parameter db_block_size
show parameter db_files
show parameter recyclebin
show parameter O7_DICTIONARY_ACCESSIBILITY
show parameter pga_aggregate_target
show parameter listener
show parameter local_listener
show parameter remote_listener
show parameter db_create_file_dest
show parameter log_archive_dest_1
show parameter log_archive_dest_2
show parameter  control_file_record_keep_time
show parameter enable_ddl_logging
```
### 2.5.4 修改参数

```
alter system set deferred_segment_creation=FALSE;     
alter system set audit_trail             =none           scope=spfile;  
alter system set SGA_MAX_SIZE            =xxxxxM         scope=spfile; 
alter system set SGA_TARGET              =xxxxxM         scope=spfile;  
alter systemn set pga_aggregate_target   =XXXXXM         scope=spfile;
Alter PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;
alter database add SUPPLEMENTAL log data;
alter system set enable_ddl_logging=true;
#关闭11g密码延迟验证新特性
ALTER SYSTEM SET EVENT = '28401 TRACE NAME CONTEXT FOREVER, LEVEL 1' SCOPE = SPFILE;
#限制trace日志文件大最大25M
alter system set max_dump_file_size ='25m' ;
#关闭密码大小写限制
ALTER SYSTEM SET SEC_CASE_SENSITIVE_LOGON = FALSE;
alter system set db_files=2000 scope=spfile;
#RAC修改local_listener：（现象：使用PlSql Developer第一次连接超时，第二次之后连接正常）
alter system set local_listener = '(ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.0.125)(PORT = 1521))' sid='orcl1';
alter system set local_listener = '(ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.0.130)(PORT = 1521))' sid='orcl2';
HOST = 192.168.1.216 --此处使用数字形式的VIP，绝对禁止使用rac1-vip
HOST = 192.168.1.219 --此处使用数字形式的VIP，绝对禁止使用rac2-vip
#更改控制文件记录保留时间
alter system set control_file_record_keep_time =31;
```

### 2.5.5 Oracle 参数调优

```plsql
ALTER SYSTEM SET "_buffer_busy_wait_timeout"=2     SCOPE=SPFILE;
ALTER SYSTEM SET "_kill_diagnostics_timeout"=140   SCOPE=SPFILE;
ALTER SYSTEM SET "_lm_rcvr_hang_allow_time"=140    SCOPE=SPFILE;
ALTER SYSTEM SET "_optim_peek_user_binds"=FALSE    SCOPE=SPFILE;
ALTER SYSTEM SET "_use_adaptive_log_file_sync"=FALSE SCOPE=SPFILE;
ALTER SYSTEM SET "_PX_use_large_pool"=TRUE SCOPE=SPFILE;
ALTER SYSTEM SET "deferred_segment_creation"=FALSE SCOPE=SPFILE;
ALTER SYSTEM SET log_buffer=512000000 SCOPE=SPFILE;
ALTER SYSTEM SET parallel_force_local=false;
ALTER SYSTEM SET parallel_max_servers=20;    默认480
ALTER SYSTEM SET open_cursors=3000 SCOPE=SPFILE;             
open_cursors设定每个session（会话）最多能同时打开多少个cursor（游标）。session_cached_cursor设定每个session（会话）最多可以缓存多少个关闭掉的cursor
ALTER SYSTEM SET session_cached_cursors=3000 SCOPE=SPFILE;
ALTER SYSTEM SET "_kgl_hot_object_copies"=2 SCOPE=SPFILE;
ALTER SYSTEM SET audit_trail='none' SCOPE=SPFILE;
ALTER SYSTEM SET shared_pool_size=10g SCOPE=SPFILE;
ALTER SYSTEM SET db_cache_size=56g SCOPE=SPFILE;
ALTER SYSTEM SET pga_aggregate_target=10g SCOPE=SPFILE;   
ALTER SYSTEM SET processes=5000 SCOPE=SPFILE;
ALTER SYSTEM SET "_enable_NUMA_support"=false;
ALTER SYSTEM SET PLSQL_CODE_TYPE=NATIVE SCOPE=SPFILE;    ---把plsql存储过程编译成本地代码的过程，不会导致任何解释器开销
ALTER SYSTEM SET PLSQL_OPTIMIZE_LEVEL=2 SCOPE=SPFILE;
alter system set use_large_pages='ONLY' SCOPE=SPFILE;
alter system set recyclebin='OFF' scope=spfile;
//10g
alter system set commit_write='immediate,nowait';    异步提交
//11g
alter system set commit_logging ='immediate';
alter system set commit_wait ='nowait' ;
alter system set db_file_multiblock_read_count = 128 ;
alter system set java_jit_enabled=false scope=spfile;
alter system set cursor_sharing=force scope=spfile;

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

| NAME                        | VALUE | ISDEFAULT | DESCRIPTION                                             | ISMOD | ISADJ |
| --------------------------- | ----- | --------- | ------------------------------------------------------- | ----- | ----- |
| _PX_use_large_pool          | TRUE  | FALSE     | Use Large Pool as source of PX buffers                  | FALSE | FALSE |
| _buffer_busy_wait_timeout   | 2     | FALSE     | buffer busy wait time in centiseconds                   | FALSE | FALSE |
| _enable_NUMA_support        | FALSE | TRUE      | Enable NUMA support and optimizations                   | FALSE | FALSE |
| _kgl_hot_object_copies      | 2     | FALSE     | Number of copies for the hot object                     | FALSE | FALSE |
| _kill_diagnostics_timeout   | 140   | FALSE     | timeout delay in seconds before killing enqueue blocker | FALSE | FALSE |
| _lm_rcvr_hang_allow_time    | 140   | FALSE     | receiver hang allow time in seconds                     | FALSE | FALSE |
| _optim_peek_user_binds      | FALSE | FALSE     | enable peeking of user binds                            | FALSE | FALSE |
| _use_adaptive_log_file_sync | FALSE | FALSE     | Adaptively switch between post/wait and polling         | FALSE | FALSE |

### 2.5.6 ASM隐藏参数

```plsql
select ksppinm,ksppstvl,ksppdesc from x$ksppi x,x$ksppcv y where x.indx = y.indx and ksppinm='_asm_hbeatiowait';
```

## 2.6 数据库profile

```
set pagesize 200
col PROFILE format a20
col RESOURCE_NAME format a25
col LIMIT format a15
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
Select num_rows*avg_row_len/1024/1024 from dba_tables where table_name='<table_name>' ;
```

### 2.10.5 审计日志大小

```plsql
col segment_name FOR a10
SELECT owner,segment_name,tablespace_name,bytes/1024/1024/1024 GB FROM dba_segments WHERE segment_name ='AUD$' AND owner='SYS';
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

select tablespace_name,logging,status from dba_tablespaces;
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
(select  nvl(case  when autoextensible ='YES' then (case when (maxbytes-bytes)>=0 then (maxbytes-bytes) end) end,0) Extend_bytes
,tablespace_name,bytes  from dba_data_files) aa group by tablespace_name) d
where f.tablespace_name= d.tablespace_name
order by  used_percent_with_extend desc;


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
select session_key,AUTOBACKUP_DONE,OUTPUT_DEVICE_TYPE, INPUT_TYPE,status,ELAPSED_SECONDS/3600     hours,   TO_CHAR(START_TIME,'yyyy-mm-dd hh24:mi') start_time, OUTPUT_BYTES_DISPLAY out_size,OUTPUT_BYTES_PER_SEC_DISPLAY,INPUT_BYTES_PER_SEC_DISPLAY  from v$RMAN_BACKUP_JOB_DETAILS order by start_time ;
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
set pagesize500
set linesize 100
select substr(comp_name,1,40) comp_name, status, substr(version,1,10) version from dba_registry order by comp_name;

select substr(object_name,1,40) object_name,substr(owner,1,15) owner,object_type from dba_objects where status='INVALID' order by owner,object_type;

select owner,object_type,count(*) from dba_objects where status='INVALID' group by owner,object_type order by owner,object_type ;
```

### 2.18.2 SYS用户无效对象

```plsql
set linesize 200
col owner format a15
col object_name format a30
col object_id format 99999999
col object_type format a10
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

## 2.20 数据库当前的等待事件

### 2.20.1 数据库等待事件

```plsql
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
"

select * from (select a.event, count(*) from v$active_session_history a  where a.sample_time > sysdate - 15 / (24 * 60) and a.sample_time < sysdate and a.session_state = 'WAITING' and a.wait_class not in ('Idle') group by a.event order by 2 desc, 1) where rownum <= 5;
```

### 5.20.2 检查锁与library闩锁等待

```plsql
1. 查询锁等待。
   SQL> select 'session ' || c.locker || ' lock ' || c.locked ||
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
   SQL> select 'session ' || d.locker || ' lock ' || d.locked ||
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

### 5.20.3 等待事件信息

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

## 5.21 客户端连接分布

查询每个客户端连接每个实例的连接数

```plsql
col MACHINE format a20
select inst_id,machine ,count(*) from gv$session group by machine,inst_id order by 3;

select INST_ID,status,count(status) from gv$session group by status,INST_ID order by status,INST_ID;
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
,((sum(blocks * block_size)) /1024 /1024) as "MB"
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

```plsql
select 'DROP TRIGGER '||owner||'."'||TRIGGER_NAME||'";' from dba_triggers where
TRIGGER_NAME like 'DBMS_%_INTERNAL% '
union all
select 'DROP PROCEDURE '||owner||'."'||a.object_name||'";' from dba_procedures a
where a.object_name like 'DBMS_%_INTERNAL% ';
```

```plsql
select owner,object_name,created from dba_objects where object_name like 'DBMS_SUPPORT_DBMONITOR%';
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

-- Rebuild Partition index
Select 'alter index '||index_owner||'.'||index_name||' rebuild partition '||partition_name||' ONLINE;' from dba_ind_partitions where  status = 'UNUSABLE';

-- Rebuild Sub Partition index
Select 'alter index '||index_owner||'.'||index_name||' rebuild subpartition '||subpartition_name||' ONLINE;' from dba_ind_subpartitions where  status = 'UNUSABLE';

-- online重建索引
alter index PM4H_DB.IDX_IND_H_3723 rebuild online;
alter index PM4H_DB.IDX_IND_H_3723 rebuild partition PD_IND_H_3723_190501 online;

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
SELECT owner,index_name,blevel FROM dba_indexes WHERE blevel >= 3 ORDER BY blevel DESC;
```

## 2.28 Other Index Type

```plsql
select t.owner,t.table_name,t.index_name,t.index_type,t.status,t.blevel,t.leaf_blocks from dba_indexes t
where index_type in ('BITMAP', 'FUNCTION-BASED NORMAL', 'NORMAL/REV')
and owner not in ('ORDDATA','ORDSYS','DMSYS','APEX_030200','OUTLN','DBSNMP','SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','ORDSYS','DBSNMP','OUTLN','TSMSYS') and owner in (select username from dba_users where account_status='OPEN');
```

## 2.29 SYSTEM表空间业务数据

```plsql
select * from (select owner, segment_name, segment_type,tablespace_name
  from dba_segments where tablespace_name in('SYSTEM','SYSAUX'))
where  owner not in ('MTSSYS','ORDDATA','ORDSYS','DMSYS','APEX_030200','OUTLN','DBSNMP','SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','ORDSYS','DBSNMP','OUTLN','TSMSYS') and owner in (select username from dba_users where account_status='OPEN');
```

## 2.30 表的并行度

```plsql
select owner,table_name name,status,degree from dba_tables where degree>1;
```

## 2.31 索引并行度

```plsql
select owner,index_name name,status,degree from dba_indexes where degree>'1';
```

## 2.32 Disabled Trigger(es)

```plsql
SELECT owner, trigger_name, table_name, status FROM dba_triggers WHERE  owner in (select username from dba_users where account_status='OPEN');
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

```
@?/rdbms/admin/addmrpt.sql
@?/rdbms/admin/awrrpt.sql
@?/rdbms/admin/ashrpt.sql
@?/rdbms/admin/awrsqrpt.sql
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
create pfile='/home/oracle/pfile20190822.ora' from spfile;
create pfile='/export/home/oracle/pfile20170626.ora' from spfile;     <!--Solaris-->
```

## 3.3 JOB状态查询

```
-- 主端查看当前DBMS_JOB 的状态
SELECT * FROM DBA_JOBS_RUNNING;

-- 主端查看当前DBMS_SCHEDULER的状态
select owner,job_name,session_id,slave_process_id,running_instance from dba_scheduler_running_jobs;
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

-- 打开闪回功能
shutdown immediate;
startup mount;
alter database flashback on;
alter database open;

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

## 3.11 锁定对象处理(ORA-04021)

```plsql
SELECT OBJECT_ID, SESSION_ID, inst_id FROM GV$LOCKED_OBJECT WHERE OBJECT_ID in (select object_id FROM dba_objects where object_name='IND_M5_42' AND OWNER='PM4H_DB');

select SERIAL# from gv$session where sid=4276 and INST_ID=1;

alter system kill session '4276,6045,@1' immediate;
```

## 3.12 数据库文件

### 3.12.1 数据文件

```plsql
Set pagesize 300
Set linesize 300
col file_name format a60
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
   AND T.NAME = NVL(UPPER('USERS'), 'SYSTEM')
 ORDER BY F.CREATION_TIME;
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
select * from DBA_TAB_STATISTICS where OWNER in ('PM4H_DB', 'PM4H_MO', 'PM4H_HW') AND  last_analyzed is not null and last_analyzed >= (sysdate-2);
-- 查看列统计信息
select * from DBA_TAB_COL_STATISTICS where OWNER in ('PM4H_DB', 'PM4H_MO', 'PM4H_HW') AND last_analyzed is not null and last_analyzed >= (sysdate-2);
;
-- 查看索引统计信息
select * from DBA_IND_STATISTICS where OWNER in ('PM4H_DB', 'PM4H_MO', 'PM4H_HW') AND last_analyzed is not null and last_analyzed >= (sysdate-2);

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
exec dbms_stats.gather_table_stats(ownname=>'PM4H_DB', tabname=> 'IND_TOH_21989_2',estimate_percent =>DBMS_STATS.AUTO_SAMPLE_SIZ,method_opt=> 'FOR ALL COLUMNS SIZE AUTO', degree => 4, cascade => TRUE ); 

-- 收集表分区统计信息
exec dbms_stats.gather_table_stats(ownname=>'PM4H_DB', tabname=> 'IND_TOH_21989_2',partname => 'P21989_2_20190926',estimate_percent =>DBMS_STATS.AUTO_SAMPLE_SIZE,method_opt=> 'FOR ALL COLUMNS SIZE AUTO', degree => 10, cascade => TRUE ); 

-- 只收集表的统计信息
exec dbms_stats.gather_table_stats(ownname => 'PM4H_DB', tabname =>'IND_TOH_20688', estimate_percent =>DBMS_STATS.AUTO_SAMPLE_SIZE, method_opt => 'FOR TABLE',degree => 4);

```

### 3.14.3 统计信息管理

```plsql
--- 还原统计信息
select TABLE_NAME, STATS_UPDATE_TIME from dba_tab_stats_history where table_name=upper('IND_ORG_20686');

select TABLE_NAME, PARTITION_NAME,STATS_UPDATE_TIME from dba_tab_stats_history where table_name=upper('MO_MOENTITY');

execute dbms_stats.restore_table_stats ('PM4H_AD','MO_MOENTITY','25-SEP-19 02.26.47.499595 PM +07:00');

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
   no_invalidate    BOOLEAN  DEFAULT to_no_invalidate_type (
                                     get_param('NO_INVALIDATE')),
   force            BOOLEAN DEFAULT FALSE);
   
exec DBMS_STATS.DELETE_INDEX_STATS(ownname=>'PM4H_AD', indname=>'MO_MOENTITY_IDX11')

--11g统计信息收集新特性：扩展统计信息收集

exec DBMS_STATS.GATHER_TABLE_STATS(ownname=>‘xxx',tabname=>‘DEALREC_ERR_201608',method_opt=>'for columns (substr(other_class, 1, 3)) size skewonly',estimate_percent=>10,no_invalidate=>false,cascade=>true,degree => 10);
```



## 3.15 分区表信息

### 3.15.1 是否分区表

该表是否是分区表，分区表的分区类型是什么，是否有子分区，分区总数有多少

```plsql
select OWNER,table_name,partitioning_type,subpartitioning_type,partition_count from dba_part_tables where table_name ='RANGE_PART_TAB';

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

### 3.17.3 查看表的并行度

```
select owner,table_name,degree from dba_tables where table_name='EMP';
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

-- 查询事务使用的UNDO段及大小。
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



