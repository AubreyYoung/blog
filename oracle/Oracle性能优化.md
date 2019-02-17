# Oracle性能优化

## AWR、ASH

**脚本目录  $ORACLE_HOME/rdbms/admin**

```
@?/rdbms/admin/addmrpt.sql
@?/rdbms/admin/awrrpt.sql
@?/rdbms/admin/ashrpt.sql
```

```
//修改快照时间间隔
EXEC DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS( interval => 30);
//手动生成快照
EXEC DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT('TYPICAL');
或
BEGIN 
  DBMS_WORKLOAD_REPOSITORY.create_snapshot(); 
END; 
/

//生成 AWR 基线：
BEGIN 
  DBMS_WORKLOAD_REPOSITORY.create_baseline ( 
    start_snap_id => 10,  
    end_snap_id   => 100, 
    baseline_name => 'AWR First baseline'); 
END; 
/

//生成 AWR 基线(11g)：
BEGIN
DBMS_WORKLOAD_REPOSITORY.CREATE_BASELINE_TEMPLATE (
start_time => to_date('&start_date_time','&start_date_time_format'),
end_time => to_date('&end_date_time','&end_date_time_format'),
baseline_name => 'MORNING',
template_name => 'MORNING',
expiration => NULL ) ;
END;
/

//基于重复时间周期来制定用于创建和删除 AWR 基线的模板：
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

//删除 AWR 基线：
BEGIN
    DBMS_WORKLOAD_REPOSITORY.DROP_BASELINE (baseline_name => 'AWR First baseline');
END;
/
```

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

**AWR 相关的视图**
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

## 查看会话ID、OSPID

```
//方法一：
column line format a79
set heading off
select 'ospid: ' || p.spid || ' # ''' ||s.sid||','||s.serial#||''' '||
  s.osuser || ' ' ||s.machine ||' '||s.username ||' '||s.program line
from v$session s , v$process p
where p.addr = s.paddr
and s.username <> ' ';

//方法二
select p.pid, p.spid, s.username  
        from v$process p, v$session s  
        where p.addr = s.paddr;
```
##  数据库当前的等待事件
```
select inst_id,event,count(1) from gv$session where wait_class#<> 6 group by inst_id,event order by 1,3;
```
## **查询每个客户端连接每个实例的连接数**

```
select inst_id,machine ,count(*) from gv$session group by machine,inst_id order by 3;

select INST_ID,status,count(status) from gv$session group by status,INST_ID order by status,INST_ID;
```

##  查询oracle正在执行的sql以及session

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
and s.sid=2065
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

## 查杀会话

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



## 根据sid查询已经执行过的sql 

```
select sql_text from v$sqlarea a,v$session b where a.SQL_ID=b.PREV_SQL_ID and b.SID=&sid; 
```

## 查看ASH信息

```
select SESSION_ID,NAME,P1,P2,P3,WAIT_TIME,CURRENT_OBJ#,CURRENT_FILE#,CURRENT_BLOCK#
       from v$active_session_history ash, v$event_name enm 
       where ash.event#=enm.event# 
       and SESSION_ID=&SID and SAMPLE_TIME>=(sysdate-&minute/(24*60));

//Input is:
//Enter value for sid: 15 
//Enter value for minute: 1  /* How many minutes activity you want to see */
```

## **查看内存占用大的会话**

```
SELECT server "连接类型",s.MACHINE,s.username,s.osuser,sn.NAME,VALUE/1024/1024 "占用内存MB",s.SID "会话ID",
      s.serial#,p.spid "操作系统进程ID",p.PGA_USED_MEM,p.PGA_ALLOC_MEM,p.PGA_FREEABLE_MEM, 
      p.PGA_MAX_MEM 
FROM v$session s, v$sesstat st, v$statname sn, v$process p 
WHERE st.SID = s.SID AND st.statistic# = sn.statistic# AND sn.NAME LIKE 'session pga memory' 
     AND p.addr = s.paddr and rownum<20
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

## oradebug

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

