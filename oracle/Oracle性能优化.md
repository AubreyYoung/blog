# Oracle性能优化

## 1. AWR、ASH

### 1.1 生成AWR、ASH、ADDM

**脚本目录  $ORACLE_HOME/rdbms/admin**

```
@?/rdbms/admin/addmrpt.sql
@?/rdbms/admin/awrrpt.sql
@?/rdbms/admin/ashrpt.sql
```
### 1.2 快照设置
```
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
### 1.3 其他AWR脚本
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

### 1.4 AWR 相关的视图

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
### 1.5 查看ASH信息

```
select SESSION_ID,NAME,P1,P2,P3,WAIT_TIME,CURRENT_OBJ#,CURRENT_FILE#,CURRENT_BLOCK#
       from v$active_session_history ash, v$event_name enm 
       where ash.event#=enm.event# 
       and SESSION_ID=&SID and SAMPLE_TIME>=(sysdate-&minute/(24*60));

-- Input is:
-- Enter value for sid: 15 
-- Enter value for minute: 1  /* How many minutes activity you want to see */
```

## 2. 会话相关

### 2.1 查看查询SID、SPID

```
-- 方法一：
column line format a79
set heading off
select 'ospid: ' || p.spid || ' # ''' ||s.sid||','||s.serial#||''' '||
  s.osuser || ' ' ||s.machine ||' '||s.username ||' '||s.program line
from v$session s , v$process p
where p.addr = s.paddr
and s.username <> ' ';

-- 方法二
select p.pid, p.spid, s.username  
        from v$process p, v$session s  
        where p.addr = s.paddr;
 -- 方法三       
 select 'ospid: ' || p.spid || ' # ''' ||s.sid||','||s.serial#||''' '||'inst_id: '||s.inst_id||' '||
  s.osuser || ' ' ||s.machine ||' '||s.username ||' '||s.program line
from gv$session s , v$process p
where p.addr = s.paddr
and s.username <> ' '
and s.sid=851;

LINE
--------------------------------------------------------------------------------
ospid: 15749 # '851,27493' inst_id: 1 acrosspm SPCIS-PRFHWI-SGR07 PM4H_HW alarmM

-- 方法四
set line 500
col sid format 9999
col s# format 99999
col username format a10
col event format a30
col machine format a20
col p123 format a18
col wt format 999
col SQL_ID for a18
alter session set cursor_sharing=force;
SELECT /* XJ LEADING(S) FIRST_ROWS */
 S.SID,
 S.SERIAL# S#,
 P.SPID,
 NVL(S.USERNAME, SUBSTR(P.PROGRAM, LENGTH(P.PROGRAM) - 6)) USERNAME,
 S.MACHINE,
 S.EVENT,
 S.P1 || '/' || S.P2 || '/' || S.P3 P123,
 S.WAIT_TIME WT,
 NVL(SQL_ID, S.PREV_SQL_ID) SQL_ID
  FROM V$PROCESS P, V$SESSION S
 WHERE P.ADDR = S.PADDR
   AND S.STATUS = 'ACTIVE'
   AND P.BACKGROUND IS NULL;
```
### 2.2 表相关SQL、SID、SPID

```plsql
--- 单实例
select
substr(s.username,1,18) username,
P.spid,
s.sid,s.serial#,s.machine,y.sql_text,
'ALTER SYSTEM KILL SESSION '''||s.sid||','||s.serial#||''';' "kill Session "
from gv$session s,
v$process p,v$transaction t,v$rollstat r,v$rollname n,gv$sql y
where 
s.paddr = p.addr
and s.taddr = t.addr (+)
and t.xidusn = r.usn (+)
and r.usn = n.usn (+)
and s.username is not null
and s.sql_address=y.address
and sql_text like '%IND_TOH_19666_4%'
```

###  2.3 查询SQL以及session

```
select
substr(s.username,1,18) username,
s.sid,s.serial#,s.machine,y.sql_text,
'ALTER SYSTEM KILL SESSION '''||s.sid||','||s.serial#||''';' "kill Session "
from v$session s,v$process p,v$transaction t,v$rollstat r,v$rollname n,v$sql y
where s.paddr = p.addr
and s.taddr = t.addr (+)
and t.xidusn = r.usn (+)
and r.usn = n.usn (+)
and s.username is not null
and s.sql_address=y.address
order by s.sid,s.serial#,s.username,s.status
```

```
select
substr(s.username,1,18) username,
s.sid,s.serial#,s.machine,y.sql_text,
'ALTER SYSTEM KILL SESSION '''||s.sid||','||s.serial#||''';' "kill Session "
from v$session s,v$process p,v$transaction t,v$rollstat r,v$rollname n,v$sql y
where s.paddr = p.addr
and s.taddr = t.addr (+)
and t.xidusn = r.usn (+)
and r.usn = n.usn (+)
and s.username is not null
and s.sql_address=y.address
order by s.sid,s.serial#,s.username,s.status
```

```plsql
--会话信息
select machine , event ,SERIAL#, TERMINAL, PROGRAM, ACTION,TYPE, SQL_ID, LOGON_TIME
from gv$session where sid=1568 and INST_ID=2;

--阻塞会话
select inst_id,sid,serial#,status,sql_id,sql_exec_start,module,blocking_session from gv$session where machine='spcis-prfhwi-sdb01' and module like 'sqlplus%'; 

select inst_id,sid,sql_id,event,module,machine,blocking_session  from gv$session where module ='PL/SQL Developer';
```

### 2.4 查杀会话

```
SELECT 'Lock' "Status",
a.username "用户名", a.sid "SID", a.serial# "SERIAL#",
b.type "锁类型",
DECODE(b.lmode, 1, 'No Lock', 2, 'Row Share', 3, 'Row Exclusive', 4, 'Share', 5, 'Share Row Exclusive', 6, 'Exclusive', 'NONE') "占用的模式",
DECODE(b.request, 1, 'No Lock', 2, 'Row Share', 3, 'Row Exclusive', 4, 'Share', 5, 'Share Row Exclusive', 6, 'Exclusive', 'NONE') "请求的模式",
c.object_name "对象名",
c.owner "对象所有者", c.object_type "对象类型",
b.id1 "资源ID1", b.id2 "资源ID2",b.ctime "ctime(秒) ",
'ALTER SYSTEM KILL SESSION '''||a.sid||','||a.serial#||''';' "kill Session ",
'kill -9 '||d.spid "Kill Process (Unix Linux)", 
'orakill '||f.instance_name||' '||d.spid "Kill Process (Windows)" 
FROM v$session a, v$lock b, v$locked_object b1, dba_objects c, v$process d, v$instance f
WHERE a.type <> 'BACKGROUND'
AND a.sid = b.sid
AND b.request = 0
AND d.addr = a.paddr
AND b1.session_id = a.sid
AND b1.object_id = c.object_id
AND f.status = 'OPEN'
AND f.database_status = 'ACTIVE'
order by b.ctime;
```

### 2.5 根据SID查询SQL

```plsql
select sql_text from v$sqlarea a,v$session b where a.SQL_ID=b.PREV_SQL_ID and b.SID=&sid;

set line 120;
SELECT 'ps -ef|grep ' || TO_CHAR(SPID) ||
       '|grep LOCAL=NO|awk ''{print " -9 "\$2}''|xargs kill' KILL_SH
  FROM GV$PROCESS P, GV$SESSION S
 WHERE S.PADDR = P.ADDR
   AND S.SQL_ID = '$2';
```

### 2.6 内存占用大的会话

```
SELECT server "连接类型",s.MACHINE,s.username,s.osuser,sn.NAME,VALUE/1024/1024 "占用内存MB",s.SID "会话ID",
      s.serial#,p.spid "操作系统进程ID",p.PGA_USED_MEM,p.PGA_ALLOC_MEM,p.PGA_FREEABLE_MEM, 
      p.PGA_MAX_MEM 
FROM v$session s, v$sesstat st, v$statname sn, v$process p 
WHERE st.SID = s.SID AND st.statistic# = sn.statistic#  
     AND p.addr = s.paddr
ORDER BY VALUE DESC ;

SELECT s.inst_id,s.username,s.MACHINE,s.osuser,VALUE/1024/1024 "占用内存MB",s.SID "会话ID",
      s.serial#,p.spid "操作系统进程ID",p.PGA_USED_MEM,p.PGA_FREEABLE_MEM, 
      p.PGA_MAX_MEM 
FROM gv$session s, v$sesstat st, v$statname sn, v$process p 
WHERE st.SID = s.SID AND st.statistic# = sn.statistic# AND sn.NAME LIKE 'session pga memory' 
     AND p.addr = s.paddr and rownum<20 and s.username is not null
ORDER BY VALUE DESC ;

SELECT sum(VALUE/1024/1024) "占用内存MB" 
FROM v$session s, v$sesstat st, v$statname sn, v$process p 
WHERE st.SID = s.SID AND st.statistic# = sn.statistic# AND sn.NAME LIKE 'session pga memory' 
     AND p.addr = s.paddr and s.username is not null;

alter system kill session '1568,27761,@2' immediate; 
```

### 2.7 查询SQL语句的SQL_ID

```
SELECT sql_id, plan_hash_value, substr(sql_text,1,40) sql_text FROM v$sql WHERE sql_text like 'SELECT /* TARGET SQL */%'

-- 根据SQL 查询到操作用户
select s.username from v$active_session_history t,dba_users s  where t.USER_ID=s.user_id and t.SQL_ID='0nx7fbv1w5xg2';
 
-- 查询并获取当前sql的杀会话语句
select 'alter system kill session '''|| t.SID||','||t.SERIAL#||',@'||t.inst_id||''' immediate;' from gv$session t where t.SQL_ID='c6yz84stnau9b';

-- 查询并获取当前会话的执行计划清空过程语句
select SQL_TEXT,sql_id, address, hash_value, executions, loads, parse_calls, invalidations from v$sqlarea  where sql_id='0nx7fbv1w5xg2';

call sys.dbms_shared_pool.purge('0000000816530A98,3284334050','c');
```

##  3.等待事件

###  3.1  数据库当前的等待事件

```
select inst_id,event,count(1) from gv$session where wait_class#<> 6 group by inst_id,event order by 1,3;
```
### 3.2 等待事件

```plsql
-- 查询数据库等待时间和实际执行时间的相对百分比
select *
from v$sysmetric a
where a.METRIC_NAME in
      ('Database CPU Time Ratio', 'Database Wait Time Ratio')
  and a.INTSIZE_CSEC = (select max(intsize_csec) from v$sysmetric);
  
-- 查询数据库中过去30分钟引起最多等待的sql语句
select ash.USER_ID,
      u.username,
      sum(ash.WAIT_TIME) ttl_wait_time,
      s.SQL_TEXT
from v$active_session_history ash, v$sqlarea s, dba_users u
where ash.SAMPLE_TIME between sysdate - 60 / 2880 and sysdate
  and ash.SQL_ID = s.SQL_ID
  and ash.USER_ID = u.user_id
group by ash.USER_ID, s.SQL_TEXT, u.username
order by ttl_wait_time desc


-- 查询数据库过去15分钟最重要的等待事件
select ash.EVENT, sum(ash.WAIT_TIME + ash.TIME_WAITED) total_wait_time
from v$active_session_history ash
where ash.SAMPLE_TIME between sysdate - 30 / 2880 and sysdate
group by event
order by total_wait_time desc

-- 在过去15分钟哪些用户经历了等待
select s.SID,
      s.USERNAME,
      sum(ash.WAIT_TIME + ash.TIME_WAITED) total_wait_time
from v$active_session_history ash, v$session s
where ash.SAMPLE_TIME between sysdate - 30 / 2880 and sysdate
  and ash.SESSION_ID = s.SID
group by s.SID, s.USERNAME
order by total_wait_time desc;

-- 查询等待时间最长的对象
select a.CURRENT_OBJ#,
      d.object_name,
      d.object_type,
      a.EVENT,
      sum(a.WAIT_TIME + a.TIME_WAITED) total_wait_time
from v$active_session_history a, dba_objects d
where a.SAMPLE_TIME between sysdate - 30 / 2880 and sysdate
  and a.CURRENT_OBJ# = d.object_id
group by a.CURRENT_OBJ#, d.object_name, d.object_type, a.EVENT
order by total_wait_time desc;

-- 查询过去15分钟等待时间最长的sql语句
select a.USER_ID,
      u.username,
      s.SQL_TEXT,
      sum(a.WAIT_TIME + a.TIME_WAITED) total_wait_time
from v$active_session_history a, v$sqlarea s, dba_users u
where a.SAMPLE_TIME between sysdate - 30 / 2880 and sysdate
  and a.SQL_ID = s.SQL_ID
  and a.USER_ID = u.user_id
group by a.USER_ID, s.SQL_TEXT, u.username
order by total_wait_time desc;

-- 那些SQL消耗更多的IO
select *
from (select s.PARSING_SCHEMA_NAME,
              s.DIRECT_WRITES,
              substr(s.SQL_TEXT, 1, 500),
              s.DISK_READS
        from v$sql s
        order by s.DISK_READS desc)
where rownum < 20
-- 查看哪些会话正在等待IO资源
SELECT username, program, machine, sql_id
FROM V$SESSION
WHERE EVENT LIKE 'db file%read';

-- 查看正在等待IO资源的对象
SELECT d.object_name, d.object_type, d.owner
FROM V$SESSION s, dba_objects d
WHERE EVENT LIKE 'db file%read'
　　and s.ROW_WAIT_OBJ# = d.object_id
```



## 4. **查询每个客户端连接每个实例的连接数**

```
select inst_id,machine ,count(*) from gv$session group by machine,inst_id order by 3;

select INST_ID,status,count(status) from gv$session group by status,INST_ID order by status,INST_ID;
```



## 5. oradebug

```
11:33:20 sys@ORCL> oradebug help
HELP           [command]                 Describe one or all commands
SETMYPID                                 Debug current process
SETOSPID       <ospid>                   Set OS pid of process to debug
SETORAPID      <orapid> ['force']        Set Oracle pid of process to debug
SETORAPNAME    <orapname>                Set Oracle process name to debug
SHORT_STACK                              Get abridged OS stack
CURRENT_SQL                              Get current SQL
DUMP           <dump_name> <lvl> [addr]  Invoke named dump
PDUMP          [interval=<interval>]     Invoke named dump periodically
               [ndumps=<count>]  <dump_name> <lvl> [addr]
DUMPSGA        [bytes]                   Dump fixed SGA
DUMPLIST                                 Print a list of available dumps
EVENT          <text>                    Set trace event in process
SESSION_EVENT  <text>                    Set trace event in session
DUMPVAR        <p|s|uga> <name> [level]  Print/dump a fixed PGA/SGA/UGA variable
DUMPTYPE       <address> <type> <count>  Print/dump an address with type info
SETVAR         <p|s|uga> <name> <value>  Modify a fixed PGA/SGA/UGA variable
PEEK           <addr> <len> [level]      Print/Dump memory
POKE           <addr> <len> <value>      Modify memory
WAKEUP         <orapid>                  Wake up Oracle process
SUSPEND                                  Suspend execution
RESUME                                   Resume execution
FLUSH                                    Flush pending writes to trace file
CLOSE_TRACE                              Close trace file
TRACEFILE_NAME                           Get name of trace file
SETTRACEFILEID <identifier name>         Set tracefile identifier
LKDEBUG                                  Invoke global enqueue service debugger
NSDBX                                    Invoke CGS name-service debugger
-G             <Inst-List | def | all>   Parallel oradebug command prefix
-R             <Inst-List | def | all>   Parallel oradebug prefix (return output
SETINST        <instance# .. | all>      Set instance list in double quotes
SGATOFILE      <SGA dump dir>         Dump SGA to file; dirname in double quotes
DMPCOWSGA      <SGA dump dir> Dump & map SGA as COW; dirname in double quotes
MAPCOWSGA      <SGA dump dir>         Map SGA as COW; dirname in double quotes
HANGANALYZE    [level] [syslevel]        Analyze system hang
FFBEGIN                                  Flash Freeze the Instance
FFDEREGISTER                             FF deregister instance from cluster
FFTERMINST                               Call exit and terminate instance
FFRESUMEINST                             Resume the flash frozen instance
FFSTATUS                                 Flash freeze status of instance
SKDSTTPCS      <ifname>  <ofname>        Helps translate PCs to names
WATCH          <address> <len> <self|exist|all|target>  Watch a region of memory
DELETE         <local|global|target> watchpoint <id>    Delete a watchpoint
SHOW           <local|global|target> watchpoints        Show  watchpoints
DIRECT_ACCESS  <set/enable/disable command | select query> Fixed table access
IPC                                      Dump ipc information
UNLIMIT                                  Unlimit the size of the trace file
CALL           [-t count] <func> [arg1]...[argn]  Invoke function with arguments
CORE                                     Dump core without crashing process
PROCSTAT                                 Dump process statistics
```

## 6. 查看长事务

```
set linesize 200
set pagesize 5000
col transaction_duration format a45
 
with transaction_details as
( select inst_id
  , ses_addr
  , sysdate - start_date as diff
  from gv$transaction
)
select s.username
, to_char(trunc(t.diff))
             || ' days, '
             || to_char(trunc(mod(t.diff * 24,24)))
             || ' hours, '
             || to_char(trunc(mod(t.diff * 24 * 60,24)))
             || ' minutes, '
             || to_char(trunc(mod(t.diff * 24 * 60 * 60,60)))
             || ' seconds' as transaction_duration
, s.program
, s.terminal
, s.status
, s.sid
, s.serial#
from gv$session s
, transaction_details t
where s.inst_id = t.inst_id
and s.saddr = t.ses_addr
order by t.diff desc
/

-- Get long run query 方法2
set linesize 120
col MESSAGE format a30
col opname for a20
col username for a20
set pagesize 1000
SELECT OPNAME,
       TIME_REMAINING  REMAIN,
       ELAPSED_SECONDS ELAPSE,
       MESSAGE,
       SQL_ID,
       SID,
       USERNAME
  FROM V$SESSION_LONGOPS
 WHERE TIME_REMAINING > 0;
```

[^注]: set transaction 只命名、配置事务，并不开启事务，随后的SQL才开启事务

## 7. 10046Trace

```
-- 在Session级打开trace
适用于SQL语句可以在新的session创建后再运行。
在session级收集10046 trace：
alter session set tracefile_identifier='10046'; 
alter session set timed_statistics = true;
alter session set statistics_level=all;
alter session set max_dump_file_size = unlimited;
alter session set events '10046 trace name context forever,level 12';

-- 执行需要被trace的SQL --

select * from dual;
exit;
如果不退出当前session, 可以用以下命令关闭trace:
alter session set events '10046 trace name context off';
注意，如果session没有被彻底地关闭并且跟踪被停止了，某些重要的trace信息的可能会丢失。
注意：这里我们将"statistics_level"设置为all，这是因为有可能这个参数在系统级不是默认值"TYPICAL"（比如 BASIC）。为了收集性能相关问题的信息我们需要打开某个级别的statistics。我们推荐在 session 级将这个参数设置成 ALL 以便于收集更多的信息，尽管这不是必须的。
 
-- 跟踪一个已经开始的进程
如果需要跟踪一个已经存在session，可以用 oradebug连接到session上，并发起10046 trace。
首先，用某种方法找到需要被跟踪的session.
例如，在SQL*Plus里，找出目标session的OS的进程ID(spid):
select p.PID,p.SPID,s.SID from v$process p,v$session s where s.paddr = p.addr and s.sid = &SESSION_ID;
SPID 是操作系统的进程标识符（os pid）
PID 是Oracle的进程标识符(ora pid)
如果你不知道session的ID, 那么可以使用类似下面的SQL语句来帮助你找到它
column line format a79
set heading off
select 'ospid: ' || p.spid || ' # ''' ||s.sid||','||s.serial#||''' '||
  s.osuser || ' ' ||s.machine ||' '||s.username ||' '||s.program line
from v$session s , v$process p
where p.addr = s.paddr
and s.username <> ' ';

如果是使用了12c的multi thread下，那么需要使用v$process中新的列stid来找到对应的thread, 因为Oracle把多个processes放进了一个单独的 ospid 中。如果想找到特定的thread, 使用下面的语法:
oradebug setospid <spid> <stid>
一旦找到OS PID，就可以用以下命令初始化跟踪：
假设需要被跟踪的OSPID是9834。
以sysdba的身份登录到SQL*Plus并执行下面的命令：
connect / as sysdba
oradebug setospid 9834
oradebug unlimit
oradebug event 10046 trace name context forever,level 12
记得把例子中的'9834' 替换成真实的os pid。
注:也可以通过oradebug使用 'setorapid'命令连接到一个session。
 
下面的例中， 使用PID（Oracle进程标识符）(而不是SPID), oradebug命令将被改为：
connect / as sysdba
oradebug setorapid 9834
oradebug unlimit
oradebug event 10046 trace name context forever,level 12
记得把例子中的9834替换成真实的ora pid。
跟踪过程完成以后，关闭oradebug跟踪：
oradebug event 10046 trace name context off
如果是使用了12c的multi thread下，那么需要使用v$process中新的列stid来找到对应的thread, 因为Oracle把多个processes放进了一个单独的 ospid 中。如果想找到特定的thread, 使用下面的语法:
oradebug setospid <spid> <stid>oradebug unlimit
tracefile名字会是 <instance><spid>_<stid>.trc 的格式.
```

## 8. 10053Trace



## 9. 表nologging

```plsql
alter session enable parallel dml;
ALTER TABLE PPCMGR.PFP_ACCT_SNP_FCT NOLOGGING;  
DELETE /*+parallel(a,4)*/ FROM PPCMGR.PFP_ACCT_SNP_FCT a where time_key >=20151223;
ALTER TABLE PPCMGR.PFP_ACCT_SNP_FCT LOGGING; 
```

## 10. SQL执行进度

```plsql
select a.username,
       a.target,
       a.sid,
       a.SERIAL#,
       a.opname,
       round(a.sofar * 100 / a.totalwork, 0) || '%' as progress, --进度条
       time_remaining second, --剩余时间：秒
       trunc(a.time_remaining / 60, 2) minute,--剩余时间：分钟
       b.sql_text,
       b.LAST_ACTIVE_TIME
  from v$session_longops a, v$sqlarea b
 where a.time_remaining <> 0
   and a.sql_address = b.address
   and a.sql_hash_value = b.hash_value
   and a.username = 'GGS';

select  target,SOFAR  /  TOTALWORK *100 from V$session_longops order by SOFAR desc;


SELECT SE.SID,  
OPNAME,  
TRUNC(SOFAR / TOTALWORK * 100, 2) || '%' AS PCT_WORK,  
ELAPSED_SECONDS ELAPSED,  
ROUND(ELAPSED_SECONDS * (TOTALWORK - SOFAR) / SOFAR) REMAIN_TIME,  
SQL_TEXT  
FROM V$SESSION_LONGOPS SL, V$SQLAREA SA, V$SESSION SE  
WHERE SL.SQL_HASH_VALUE = SA.HASH_VALUE  
AND SL.SID = SE.SID  
AND SOFAR != TOTALWORK  
ORDER BY START_TIME;  
```

## 11.行锁等待时间

```plsql
select t.SEQ#,
(max(t.SAMPLE_TIME) - min(t.SAMPLE_TIME)) "持续时间",
t.SESSION_ID "当前会话id",
t.SESSION_SERIAL# "当前会话SERIAL#",
t.event "等待事件",
t.BLOCKING_SESSION "阻塞会话id",
t.BLOCKING_SESSION_SERIAL# "阻塞会话SERIAL#"
from dba_hist_active_sess_history t
where sample_time between
to_date('2019-06-21 9:30:00', 'yyyy-mm-dd hh24:mi:ss') and
to_date('2019-06-21 10:45:00', 'yyyy-mm-dd hh24:mi:ss')
group by t.SESSION_ID,
t.SESSION_SERIAL#,
t.BLOCKING_SESSION,
t.BLOCKING_SESSION_SERIAL#,
t.EVENT,
t.SEQ#;
```

## 12.高水位、空间碎片

```plsql
--查看块总数
SELECT SEGMENT_NAME, EXTENTS, BLOCKS
  FROM USER_SEGMENTS
 WHERE SEGMENT_NAME = 'GJDS_BUS_OIL_LOG';
--查看高水位
SELECT BLOCKS, EMPTY_BLOCKS
  FROM DBA_TABLES
 WHERE TABLE_NAME = 'GJDS_BUS_OIL_LOG'
   AND OWNER = 'BUS';
--查看实际用了多少块
SELECT COUNT(DISTINCT DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) USED_BLOCK
  FROM GJDS_BUS_OIL_LOG S;
```

## 13. 查看执行较高的SQL模块

```plsql
set linesize 150
col sql_t format a50;
SELECT SUBSTR(SQL_TEXT, 1, 50) AS SQL_T,
       TRIM(PROGRAM),
       MIN(SQL_ID),
       COUNT(*)
  FROM (SELECT SQL_TEXT, A.SQL_ID, PROGRAM
          FROM V$SESSION A, V$SQLAREA B
         WHERE A.SQL_ID = B.SQL_ID
           AND A.STATUS = 'ACTIVE'
           AND A.SQL_ID IS NOT NULL
        UNION ALL
        SELECT SQL_TEXT, A.PREV_SQL_ID AS SQL_ID, PROGRAM
          FROM V$SESSION A, V$SQLAREA B
         WHERE A.SQL_ID IS NULL
           AND A.PREV_SQL_ID = B.SQL_ID
           AND A.STATUS = 'ACTIVE')
 GROUP BY SUBSTR(SQL_TEXT, 1, 50), TRIM(PROGRAM)
 ORDER BY 1;
 
 SQL_T                                              TRIM(PROGRAM)                    MIN(SQL_ID)     COUNT(*)
-------------------------------------------------- ------------------------------------------------ ------------- ----------
select 1 from sys.aq$_subscriber_table where rownu oracle@mapy (Q001)                               cv959u044n88s          1
select 1 from sys.aq$_subscriber_table where rownu oracle@mapy (Q004)                               cv959u044n88s          1
select f.file#, f.block#, f.ts#, f.length from fet oracle@mapy (SMON)                               chsyr0gssbuqf          1
select file# from file$ where ts#=:1          oracle@mapy (MMNL)                               bsa0wjtftg3uw          1
select grantee#, privilege#, max(nvl(option$,0)) f oracle@mapy (DBRM)                               8wxxddd1nswfw          1
```

## 14. 调优工具包DBMS_SQLTUNE

```plsql
SELECT * FROM TESTTABLE WHERE ID BETWEEN 200 AND 400;

SELECT * FROM V$SQLTEXT T WHERE T.SQL_TEXT LIKE '%TESTTABLE%';

DECLARE
  MY_TASK_NAME VARCHAR2(50);
BEGIN
  MY_TASK_NAME := DBMS_SQLTUNE.CREATE_TUNING_TASK(SQL_ID     => '0j3ypx51zud1r',
                                  SCOPE      => 'COMPREHENSIVE',
                                  TIME_LIMIT   => 60,
                                  TASK_NAME   => 'Lunar_tunning_0j3ypx51zud1r',
                                  DESCRIPTION  => 'Task to tune a query on bjgduva68mbqm by Lunar');
  DBMS_SQLTUNE.EXECUTE_TUNING_TASK(MY_TASK_NAME);
  DBMS_OUTPUT.PUT_LINE(MY_TASK_NAME);
END;
/

SELECT DBMS_SQLTUNE.REPORT_TUNING_TASK('&task_name') FROM DUAL;

EXEC DBMS_SQLTUNE.DROP_TUNING_TASK('Lunar_tunning_0j3ypx51zud1r');
```
## 15.Get the max contiguous free space of tablespace

```plsql
set line 200;
SELECT T.TABLESPACE_NAME,
       SUM(D.BYTES) / 1024 / 1024 / 1024 "表空间大小(G)",
       T.FREE "最大连续段大小(G)"
  FROM (SELECT TABLESPACE_NAME, MAX(FREE_SPACE) FREE
          FROM (SELECT F.TABLESPACE_NAME,
                       F.FILE_ID,
                       BLOCK_ID,
                       SUM(F.BYTES) / 1024 / 1024 / 1024 FREE_SPACE
                  FROM DBA_FREE_SPACE F, DBA_TABLESPACES T
                 WHERE T.TABLESPACE_NAME = F.TABLESPACE_NAME
                   AND T.ALLOCATION_TYPE = 'SYSTEM'
                   AND T.CONTENTS <> 'UNDO'
                   AND T.TABLESPACE_NAME NOT IN
                       ('SYSAUX', 'SYSTEM', 'USERS', 'TIVOLIORTS')
                 GROUP BY F.TABLESPACE_NAME, F.FILE_ID, BLOCK_ID) T
         GROUP BY T.TABLESPACE_NAME) T,
       DBA_DATA_FILES D
 WHERE T.TABLESPACE_NAME = D.TABLESPACE_NAME
 GROUP BY T.TABLESPACE_NAME, T.FREE
HAVING T.FREE < 2;
```

## 16. Get top5 sql for the last n hours

```plsql
set line 300;
set pagesize 300;
col module for a30;
col PARSING_SCHEMA_NAME for a10;
SELECT TO_CHAR(A.BEGIN_TIME, 'yyyymmdd hh24:mi'),
       TO_CHAR(A.END_TIME, 'yyyymmdd hh24:mi'),
       A.INSTANCE_NUMBER,
       A.PARSING_SCHEMA_NAME,
       A.MODULE,
       A.SQL_ID,
       A.BUFFER_GETS_DELTA,
       A.CPU_TIME_DELTA / B.VALUE * 100 CPU_PCT
  FROM (SELECT *
          FROM (SELECT SS.SNAP_ID,
                       SN.BEGIN_INTERVAL_TIME BEGIN_TIME,
                       SN.END_INTERVAL_TIME END_TIME,
                       SN.INSTANCE_NUMBER,
                       PARSING_SCHEMA_NAME,
                       MODULE,
                       SQL_ID,
                       BUFFER_GETS_DELTA,
                       CPU_TIME_DELTA,
                       RANK() OVER(PARTITION BY SS.SNAP_ID, SN.INSTANCE_NUMBER ORDER BY CPU_TIME_DELTA DESC) RANK
                  FROM DBA_HIST_SQLSTAT SS, DBA_HIST_SNAPSHOT SN
                 WHERE SN.SNAP_ID = SS.SNAP_ID
                   AND SN.BEGIN_INTERVAL_TIME BETWEEN SYSDATE - N / 24 AND
                       SYSDATE
                   AND SS.INSTANCE_NUMBER = SN.INSTANCE_NUMBER)
         WHERE RANK < 6) A,
       DBA_HIST_SYSSTAT B
 WHERE A.SNAP_ID = B.SNAP_ID
   AND A.INSTANCE_NUMBER = B.INSTANCE_NUMBER
   AND B.STAT_ID = 3649082374
 ORDER BY 1, 3 ASC, 8 DESC;
```

## 17. Get fragment table

```plsql
set line 300
set pagesize 300
col table_name for a35
col owner for a6
col tab_size for 999999.999999
col safe_space for 999999.999999
SELECT OWNER,
       TABLE_NAME,
       BLOCKS * 8 / 1024 TAB_SIZE,
       (AVG_ROW_LEN * NUM_ROWS + INI_TRANS * 24) / (BLOCKS * 8 * 1024) * 100 USED_PCT,
       ((BLOCKS * 8 * 1024) - (AVG_ROW_LEN * NUM_ROWS + INI_TRANS * 24)) / 1024 / 1024 * 0.9 SAFE_SPACE
  FROM DBA_TABLES
 WHERE (OWNER LIKE '__YY' OR OWNER LIKE '__ZW' OR OWNER = 'COMMON')
   AND BLOCKS > 1024 * 10
   AND (AVG_ROW_LEN * NUM_ROWS + INI_TRANS * 24) / (BLOCKS * 8 * 1024) * 100 < 50
 ORDER BY 4;
```

## 18.get top top_value process of consume by cpu

```plsql
col username for a10
col program for a50
col event for a30
set line 300
SELECT S.INST_ID,
       S.USERNAME,
       S.PROGRAM,
       S.SQL_ID,
       S.EVENT,
       P.SPID,
       SQL.CPU_TIME / 1000000 / DECODE(EXECUTIONS, 0, 1, EXECUTIONS) CPU,
       SQL.BUFFER_GETS / DECODE(EXECUTIONS, 0, 1, EXECUTIONS) BUFF
  FROM GV$SQL SQL, GV$SESSION S, GV$PROCESS P
 WHERE S.SQL_ID = SQL.SQL_ID
   AND S.STATUS = 'ACTIVE'
   AND WAIT_CLASS# <> 6
   AND S.PADDR = P.ADDR
 ORDER BY 6 DESC;
```

## 26.Get session info of cost more than cost_value

```plsql
SELECT DISTINCT SESS.USERNAME,
                NVL(DECODE(NVL(SESS.MODULE, SESS.PROGRAM),
                                 'SQL*Plus',
                                 SESS.PROGRAM,
                                 SESS.MODULE),
                    SESS.MACHINE || ':' || SESS.PROCESS) PROGRAM,
                SESS.SQL_ID,
                P.SPID,
                SESS.EVENT,
                PLAN.COST
  FROM V$SESSION SESS, V$SQL_PLAN PLAN, V$PROCESS P
 WHERE SESS.SQL_ID = PLAN.SQL_ID
   AND PLAN.ID = 0
   AND COST > 3
   AND SESS.STATUS = 'ACTIVE'
   AND P.ADDR = SESS.PADDR
 ORDER BY COST DESC;
```

## 27.Get Active Session

```plsql
set linesize 140
col sid format 9999
col s# format 99999
col username format a10
col event format a30
col machine format a20
col p123 format a18
col wt format 999
col SQL_ID for a18
alter session set cursor_sharing=force;
SELECT /* XJ LEADING(S) FIRST_ROWS */
 S.SID,
 S.SERIAL# S#,
 P.SPID,
 NVL(S.USERNAME, SUBSTR(P.PROGRAM, LENGTH(P.PROGRAM) - 6)) USERNAME,
 S.MACHINE,
 S.EVENT,
 S.P1 || '/' || S.P2 || '/' || S.P3 P123,
 S.WAIT_TIME WT,
 NVL(SQL_ID, S.PREV_SQL_ID) SQL_ID
  FROM V$PROCESS P, V$SESSION S
 WHERE P.ADDR = S.PADDR
   AND S.STATUS = 'ACTIVE'
   AND P.BACKGROUND IS NULL;
```

## 28.get hight pararllel module

```plsql
set linesize 150
col sql_t format a50;
SELECT SUBSTR(SQL_TEXT, 1, 50) AS SQL_T,
       TRIM(PROGRAM),
       MIN(SQL_ID),
       COUNT(*)
  FROM (SELECT SQL_TEXT, A.SQL_ID, PROGRAM
          FROM V$SESSION A, V$SQLAREA B
         WHERE A.SQL_ID = B.SQL_ID
           AND A.STATUS = 'ACTIVE'
           AND A.SQL_ID IS NOT NULL
        UNION ALL
        SELECT SQL_TEXT, A.PREV_SQL_ID AS SQL_ID, PROGRAM
          FROM V$SESSION A, V$SQLAREA B
         WHERE A.SQL_ID IS NULL
           AND A.PREV_SQL_ID = B.SQL_ID
           AND A.STATUS = 'ACTIVE')
 GROUP BY SUBSTR(SQL_TEXT, 1, 50), TRIM(PROGRAM)
 ORDER BY 1;
```

## 29.Get lock information by sid

```plsql
set linesize 120
col type format a12
col hold format a12
col request format a12
col BLOCK_OTHERS format a16
alter session set cursor_sharing=force;
SELECT /* SHSNC */ /*+ RULE */
 SID,
 DECODE(TYPE,
        'MR',
        'Media Recovery',
        'RT',
        'Redo Thread',
        'UN',
        'User Name',
        'TX',
        'Transaction',
        'TM',
        'DML',
        'UL',
        'PL/SQL User Lock',
        'DX',
        'Distributed Xaction',
        'CF',
        'Control File',
        'IS',
        'Instance State',
        'FS',
        'File Set',
        'IR',
        'Instance Recovery',
        'ST',
        'Disk Space Transaction',
        'TS',
        'Temp Segment',
        'IV',
        'Library Cache Invalidation',
        'LS',
        'Log Start or Switch',
        'RW',
        'Row Wait',
        'SQ',
        'Sequence Number',
        'TE',
        'Extend Table',
        'TT',
        'Temp Table',
        'TC',
        'Thread Checkpoint',
        'SS',
        'Sort Segment',
        'JQ',
        'Job Queue',
        'PI',
        'Parallel operation',
        'PS',
        'Parallel operation',
        'DL',
        'Direct Index Creation',
        TYPE) TYPE,
 DECODE(LMODE,
        0,
        'None',
        1,
        'Null',
        2,
        'Row-S (SS)',
        3,
        'Row-X (SX)',
        4,
        'Share',
        5,
        'S/Row-X (SSX)',
        6,
        'Exclusive',
        TO_CHAR(LMODE)) HOLD,
 DECODE(REQUEST,
        0,
        'None',
        1,
        'Null',
        2,
        'Row-S (SS)',
        3,
        'Row-X (SX)',
        4,
        'Share',
        5,
        'S/Row-X (SSX)',
        6,
        'Exclusive',
        TO_CHAR(REQUEST)) REQUEST,
 ID1,
 ID2,
 CTIME,
 DECODE(BLOCK,
        0,
        'Not Blocking',
        1,
        'Blocking',
        2,
        'Global',
        TO_CHAR(BLOCK)) BLOCK_OTHERS
  FROM V$LOCK
 WHERE TYPE <> 'MR'
   AND TO_CHAR(SID) = NVL('$2', TO_CHAR(SID));
--$2为SID
```

## 30.查看表结构

```plsql
set linesize 120
col name format a30
col nullable format a8
col type format a30
alter session set cursor_sharing=force;
SELECT /* SHSNC D5 */
 COLUMN_ID NO#,
 COLUMN_NAME NAME,
 DECODE(NULLABLE, 'N', 'NOT NULL', '') NULLABLE,
 (CASE
   WHEN DATA_TYPE = 'CHAR' THEN
    DATA_TYPE || '(' || DATA_LENGTH || ')'
   WHEN DATA_TYPE = 'VARCHAR' THEN
    DATA_TYPE || '(' || DATA_LENGTH || ')'
   WHEN DATA_TYPE = 'VARCHAR2' THEN
    DATA_TYPE || '(' || DATA_LENGTH || ')'
   WHEN DATA_TYPE = 'NCHAR' THEN
    DATA_TYPE || '(' || DATA_LENGTH || ')'
   WHEN DATA_TYPE = 'NVARCHAR' THEN
    DATA_TYPE || '(' || DATA_LENGTH || ')'
   WHEN DATA_TYPE = 'NVARCHAR2' THEN
    DATA_TYPE || '(' || DATA_LENGTH || ')'
   WHEN DATA_TYPE = 'RAW' THEN
    DATA_TYPE || '(' || DATA_LENGTH || ')'
   WHEN DATA_TYPE = 'NUMBER' THEN
    (CASE
      WHEN DATA_SCALE IS NULL AND DATA_PRECISION IS NULL THEN
       'NUMBER'
      WHEN DATA_SCALE <> 0 THEN
       'NUMBER(' || NVL(DATA_PRECISION, 38) || ',' || DATA_SCALE || ')'
      ELSE
       'NUMBER(' || NVL(DATA_PRECISION, 38) || ')'
    END)
   ELSE
    (CASE
      WHEN DATA_TYPE_OWNER IS NOT NULL THEN
       DATA_TYPE_OWNER || '.' || DATA_TYPE
      ELSE
       DATA_TYPE
    END)
 END) TYPE
  FROM ALL_TAB_COLUMNS
 WHERE UPPER(OWNER) = UPPER(NVL('SCOTT', OWNER))
   AND TABLE_NAME = UPPER('TESTTABLE')
 ORDER BY 1;
```

## 34.List view by name pattern

```plsql
set linesize 120
col TYPE_NAME format a30
SELECT /* SHSNC */
 OWNER,
 VIEW_NAME,
 DECODE(VIEW_TYPE_OWNER, NULL, NULL, VIEW_TYPE_OWNER || '.' || VIEW_TYPE) TYPE_NAME
  FROM ALL_VIEWS
 WHERE OWNER = '$3'
   AND VIEW_NAME LIKE '%A%'
   AND OWNER NOT IN ('SYS', 'SYSTEM', 'CTXSYS', 'WMSYS');
```

## 35.查看Sequence

```plsql
set linesize 120
col owner format a12
col MAX_VALUE format 999999999999
SELECT /* SHSNC */
 SEQUENCE_OWNER OWNER,
 SEQUENCE_NAME,
 MIN_VALUE      LOW,
 MAX_VALUE      HIGH,
 INCREMENT_BY   STEP,
 CYCLE_FLAG     CYC,
 ORDER_FLAG     ORD,
 CACHE_SIZE     CACHE,
 LAST_NUMBER    CURVAL
  FROM ALL_SEQUENCES
 WHERE SEQUENCE_OWNER = 'SCOTT'
   AND SEQUENCE_NAME LIKE '$2';
```

## 37.排序操作

```plsql
set linesize 120
col USERNAME format a12
col MACHINE format a16
col TABLESPACE format a10
SELECT /* SHSNC */ /*+ ordered */
 B.SID,
 B.SERIAL#,
 B.USERNAME,
 B.MACHINE,
 A.BLOCKS,
 A.TABLESPACE,
 A.SEGTYPE,
 A.SEGFILE#   FILE#,
 A.SEGBLK#    BLOCK#
  FROM V$SORT_USAGE A, V$SESSION B
 WHERE A.SESSION_ADDR = B.SADDR;
```

## 38.Who have lock on given object?

```plsql
set linesize 120
col USERNAME format a16
col MACHINE format a20
SELECT /* SHSNC */ /*+ RULE */
 S.SID, S.SERIAL#, P.SPID, S.USERNAME, S.MACHINE, S.STATUS
  FROM V$PROCESS P, V$SESSION S, V$LOCKED_OBJECT O
 WHERE P.ADDR = S.PADDR
   AND O.SESSION_ID = S.SID
   AND S.USERNAME IS NOT NULL
   AND O.OBJECT_ID = TO_NUMBER('$2');
```

## 39.Get latch name by latch id

```plsql
set linesize 120
SELECT /* SHSNC */ NAME FROM V$LATCHNAME WHERE LATCH#=TO_NUMBER('$2');
```

## 40.Get dependency information

```plsql
set linesize 120
SELECT /* SHSNC */
 TYPE,
 REFERENCED_OWNER     D_OWNER,
 REFERENCED_NAME      D_NAME,
 REFERENCED_TYPE      D_TYPE,
 REFERENCED_LINK_NAME DBLINK,
 DEPENDENCY_TYPE      DEPEND
  FROM ALL_DEPENDENCIES
 WHERE OWNER = '$3'
   AND NAME = '$2';
	 
SELECT /* SHSNC */
 REFERENCED_TYPE TYPE,
 OWNER           R_OWNER,
 NAME            R_NAME,
 TYPE            R_TYPE,
 DEPENDENCY_TYPE DEPEND
  FROM ALL_DEPENDENCIES
 WHERE REFERENCED_OWNER = '$3'
   AND REFERENCED_NAME = '$2'
   AND REFERENCED_LINK_NAME IS NULL;
```

## 41.Get all the transactions

```plsql
set linesize 120
col USERNAME format a12
col rbs format a12
col BLKS_RECS format a16
col START_TIME format a17
col LOGIO format 99999
col PHY_IO FORMAT 99999
COL CRGET FORMAT 99999
COL CRMOD FORMAT 99999
SELECT /* SHSNC */ /* RULE */
 S.SID,
 S.SERIAL#,
 S.USERNAME,
 R.NAME RBS,
 T.START_TIME,
 TO_CHAR(T.USED_UBLK) || ',' || TO_CHAR(T.USED_UREC) BLKS_RECS,
 T.LOG_IO LOGIO,
 T.PHY_IO PHYIO,
 T.CR_GET CRGET,
 T.CR_CHANGE CRMOD
  FROM V$TRANSACTION T, V$SESSION S, V$ROLLNAME R, V$ROLLSTAT RS
 WHERE T.SES_ADDR(+) = S.SADDR
   AND T.XIDUSN = R.USN
   AND S.USERNAME IS NOT NULL
   AND R.USN = RS.USN;
```

## 42.Get SQLs by object name

```plsql
set linesize 120
col vers format 999
SELECT /* SHSNC */
 HASH_VALUE,
 OPEN_VERSIONS  VERS,
 SORTS,
 EXECUTIONS     EXECS,
 DISK_READS     READS,
 BUFFER_GETS    GETS,
 ROWS_PROCESSED ROWCNT
  FROM V$SQL
 WHERE EXECUTIONS > 10
   AND HASH_VALUE IN
       (SELECT /*+ NL_SJ */
        DISTINCT HASH_VALUE
          FROM V$SQL_PLAN
         WHERE OBJECT_NAME = UPPER('$2')
           AND NVL(OBJECT_OWNER, 'A') = UPPER(NVL('$3', 'A')));
```

## 43.Get lock requestor/blocker

```plsql
set linesize 180
col HOLD_SID format 99999
col WAIT_SID format 99999
col type format a20
col hold format a12
col request format a12
SELECT /* SHSNC */ /*+ ORDERED USE_HASH(H,R) */
 H.SID HOLD_SID,
 R.SID WAIT_SID,
 DECODE(H.TYPE,
        'MR',
        'Media Recovery',
        'RT',
        'Redo Thread',
        'UN',
        'User Name',
        'TX',
        'Transaction',
        'TM',
        'DML',
        'UL',
        'PL/SQL User Lock',
        'DX',
        'Distributed Xaction',
        'CF',
        'Control File',
        'IS',
        'Instance State',
        'FS',
        'File Set',
        'IR',
        'Instance Recovery',
        'ST',
        'Disk Space Transaction',
        'TS',
        'Temp Segment',
        'IV',
        'Library Cache Invalidation',
        'LS',
        'Log Start or Switch',
        'RW',
        'Row Wait',
        'SQ',
        'Sequence Number',
        'TE',
        'Extend Table',
        'TT',
        'Temp Table',
        'TC',
        'Thread Checkpoint',
        'SS',
        'Sort Segment',
        'JQ',
        'Job Queue',
        'PI',
        'Parallel operation',
        'PS',
        'Parallel operation',
        'DL',
        'Direct Index Creation',
        H.TYPE) TYPE,
 DECODE(H.LMODE,
        0,
        'None',
        1,
        'Null',
        2,
        'Row-S (SS)',
        3,
        'Row-X (SX)',
        4,
        'Share',
        5,
        'S/Row-X (SSX)',
        6,
        'Exclusive',
        TO_CHAR(H.LMODE)) HOLD,
 DECODE(R.REQUEST,
        0,
        'None',
        1,
        'Null',
        2,
        'Row-S (SS)',
        3,
        'Row-X (SX)',
        4,
        'Share',
        5,
        'S/Row-X (SSX)',
        6,
        'Exclusive',
        TO_CHAR(R.REQUEST)) REQUEST,
 R.ID1,
 R.ID2,
 R.CTIME
  FROM V $LOCK H, V $LOCK R
 WHERE H.BLOCK = 1
   AND R.REQUEST > 0
   AND H.SID <> R.SID
   AND H.TYPE <> 'MR'
   AND R.TYPE <> 'MR'
   AND H.ID1 = R.ID1
   AND H.ID2 = R.ID2
   AND H.TYPE = R.TYPE
   AND H.LMODE > 0
   AND R.REQUEST > 0
 ORDER BY 1, 2;
```

## 44.Get top5 sql for the last n hours

```plsql
set line 300;
set pagesize 300;
col module for a30;
col PARSING_SCHEMA_NAME for a10;
SELECT TO_CHAR(A.BEGIN_TIME, 'yyyymmdd hh24:mi'),
       TO_CHAR(A.END_TIME, 'yyyymmdd hh24:mi'),
       A.INSTANCE_NUMBER,
       A.PARSING_SCHEMA_NAME,
       A.MODULE,
       A.SQL_ID,
       A.BUFFER_GETS_DELTA,
       A.CPU_TIME_DELTA / B.VALUE * 100 CPU_PCT
  FROM (SELECT *
          FROM (SELECT SS.SNAP_ID,
                       SN.BEGIN_INTERVAL_TIME BEGIN_TIME,
                       SN.END_INTERVAL_TIME END_TIME,
                       SN.INSTANCE_NUMBER,
                       PARSING_SCHEMA_NAME,
                       MODULE,
                       SQL_ID,
                       BUFFER_GETS_DELTA,
                       CPU_TIME_DELTA,
                       RANK() OVER(PARTITION BY SS.SNAP_ID, SN.INSTANCE_NUMBER ORDER BY CPU_TIME_DELTA DESC) RANK
                  FROM DBA_HIST_SQLSTAT SS, DBA_HIST_SNAPSHOT SN
                 WHERE SN.SNAP_ID = SS.SNAP_ID
                   AND SN.BEGIN_INTERVAL_TIME BETWEEN SYSDATE - $2 / 24 AND
                       SYSDATE
                   AND SS.INSTANCE_NUMBER = SN.INSTANCE_NUMBER)
         WHERE RANK < 6) A,
       DBA_HIST_SYSSTAT B
 WHERE A.SNAP_ID = B.SNAP_ID
   AND A.INSTANCE_NUMBER = B.INSTANCE_NUMBER
   AND B.STAT_ID = 3649082374
 ORDER BY 1, 3 ASC, 8 DESC;
```

## 45.DB 资源使用

```plsql
SELECT INSTANCE_NUMBER,
       SNAP_ID,
       MIN(BEGIN_TIME) AS 快照开始时间,
       MAX(END_TIME) AS 快照停止时间,
       ROUND(SUM(CASE METRIC_NAME
                   WHEN 'Host CPU Utilization (%)' THEN
                    AVERAGE
                 END)) AS CPU使用率,
       SUM(CASE METRIC_NAME
             WHEN 'Current OS Load' THEN
              MAXVAL
           END) AS 最大OS负载,
       SUM(CASE METRIC_NAME
             WHEN 'Current OS Load' THEN
              AVERAGE
           END) AS 平均OS负载,
       ROUND(SUM(CASE METRIC_NAME
                   WHEN 'User Transaction Per Sec' THEN
                    AVERAGE
                 END)) AS 每秒事务数,
       ROUND(SUM(CASE METRIC_NAME
                   WHEN 'Executions Per Sec' THEN
                    AVERAGE
                 END)) AS 每秒SQL执行次数,
       ROUND(SUM(CASE METRIC_NAME
                   WHEN 'Logical Reads Per Sec' THEN
                    AVERAGE
                 END)) AS 每秒逻辑读总量,
       ROUND(SUM(CASE METRIC_NAME
                   WHEN 'Physical Read Total IO Requests Per Sec' THEN
                    AVERAGE
                 END)) AS 物理读IOPS,
       ROUND(SUM(CASE METRIC_NAME
                   WHEN 'Physical Write Total IO Requests Per Sec' THEN
                    AVERAGE
                 END)) AS 物理写IOPS,
       ROUND(SUM(CASE METRIC_NAME
                   WHEN 'Redo Writes Per Sec' THEN
                    AVERAGE
                 END)) AS REDO_IOPS,
       ROUND(SUM(CASE METRIC_NAME
                   WHEN 'Physical Read Total Bytes Per Sec' THEN
                    AVERAGE / 1024 / 1024
                 END)) AS 物理读MBPS,
       ROUND(SUM(CASE METRIC_NAME
                   WHEN 'Physical Write Total Bytes Per Sec' THEN
                    AVERAGE / 1024 / 1024
                 END)) AS 物理写MBPS,
       ROUND(SUM(CASE METRIC_NAME
                   WHEN 'Redo Generated Per Sec' THEN
                    AVERAGE / 1024 / 1024
                 END)) AS REDO_MBPS,
       ROUND(SUM(CASE METRIC_NAME
                   WHEN 'Network Traffic Volume Per Sec' THEN
                    AVERAGE / 1024 / 1024
                 END)) AS 每秒网络流量_MB
  FROM DBA_HIST_SYSMETRIC_SUMMARY T
 WHERE T.INSTANCE_NUMBER IN (1 /*, 2*/)
   AND BEGIN_TIME >= TRUNC(SYSDATE)
 GROUP BY INSTANCE_NUMBER, SNAP_ID
 ORDER BY SNAP_ID DESC, INSTANCE_NUMBER;
```

## 47.内存参数优化

```plsql
-- Memory Target
select * from v$memory_target_advice order by memory_size;

-- SGA Target
select * from v$sga_target_advice order by sga_size;

-- PGA Target
select * from V$PGA_TARGET_ADVICE order by pga_target_for_estimate;
```

- 工具专题

  ![1565082784251](Oracle性能优化.assets/1565082784251.png)

-  索引专题

- 执行计划专题

-  统计信息专题

-  Hint专题

- 并行专题

- 开发与设计

- OLAP/数仓技术