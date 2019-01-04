# RMAN监控脚本

## Script-1
<!--本脚本由Oracle官方提供，并前者基础上修改时间格式-->

```
REM -------------------------------
REM Script to monitor rman backup/restore operations
REM To run from sqlplus:   @monitor '<YYYY-MM-DD HH24:MI:SS>' 
REM Example:  
--SQL>spool monitor.out
--SQL>@monitor '06-aug-12 16:38:03'
REM where <date> is the start time of your rman backup or restore job
REM Run monitor script periodically to confirm rman is progessing
REM -------------------------------

alter session set NLS_DATE_FORMAT='YYYY-MM-DD HH24:MI:SS';
set lines 1500
set pages 100
col CLI_INFO format a10
col spid format a5
col ch format a20
col seconds format 999999.99
col filename format a65
col bfc  format 9
col "% Complete" format 999.99
col event format a40
set numwidth 10

select sysdate from dual;

REM gv$session_longops (channel level)

prompt
prompt Channel progress - gv$session_longops:
prompt
select s.inst_id, o.sid, CLIENT_INFO ch, context, sofar, totalwork,
                    round(sofar/totalwork*100,2) "% Complete"
     FROM gv$session_longops o, gv$session s
     WHERE opname LIKE 'RMAN%'
     AND opname NOT LIKE '%aggregate%'
     AND o.sid=s.sid
     AND totalwork != 0
     AND sofar <> totalwork;

REM Check wait events (RMAN sessions) - this is for CURRENT waits only
REM use the following for 11G+
prompt
prompt Session progess - CURRENT wait events and time in wait so far:
prompt
select inst_id, sid, CLIENT_INFO ch, seq#, event, state, wait_time_micro/1000000 seconds
from gv$session where program like '%rman%' and
wait_time = 0 and
not action is null;

REM use the following for 10G
--select  inst_id, sid, CLIENT_INFO ch, seq#, event, state, seconds_in_wait secs
--from gv$session where program like '%rman%' and
--wait_time = 0 and
--not action is null;

REM gv$backup_async_io
prompt
prompt Disk (file and backuppiece) progress - includes tape backuppiece 
prompt if backup_tape_io_slaves=TRUE:
prompt
select s.inst_id, a.sid, CLIENT_INFO Ch, a.STATUS,
open_time, round(BYTES/1024/1024,2) "SOFAR Mb" , round(total_bytes/1024/1024,2)
TotMb, io_count,
round(BYTES/TOTAL_BYTES*100,2) "% Complete" , a.type, filename
from gv$backup_async_io a,  gv$session s
where not a.STATUS in ('UNKNOWN')
and a.sid=s.sid and open_time > to_date('&1', 'YYYY-MM-DD HH24:MI:SS') order by 2,7;

REM gv$backup_sync_io
prompt
prompt Tape backuppiece progress (only if backup_tape_io_slaves=FALSE):
prompt
select s.inst_id, a.sid, CLIENT_INFO Ch, filename, a.type, a.status, buffer_size bsz, buffer_count bfc,
open_time open, io_count
from gv$backup_sync_io a, gv$session s
where
a.sid=s.sid and
open_time > to_date('&1', 'YYYY-MM-DD HH24:MI:SS') ;
REM -------------------------------
```
## Script-1运行结果样例
```
SQL> @monitor '2019-01-03 15:00:00'

Session altered.


SYSDATE
-------------------
2019-01-04 10:12:56


Channel progress - gv$session_longops:


   INST_ID        SID CH                      CONTEXT      SOFAR  TOTALWORK % Complete
---------- ---------- -------------------- ---------- ---------- ---------- ----------
         2       3217                               1  296588138  560921582      52.88
         1       3217 rman channel=d1               1  296588138  560921582      52.88


Session progess - CURRENT wait events and time in wait so far:


   INST_ID        SID CH                         SEQ# EVENT                                    STATE                  SECONDS
---------- ---------- -------------------- ---------- ---------------------------------------- ------------------- ----------
         1       2833                            1693 SQL*Net message from client              WAITING               53192.16


Disk (file and backuppiece) progress - includes tape backuppiece
if backup_tape_io_slaves=TRUE:

old   7: and a.sid=s.sid and open_time > to_date('&1', 'YYYY-MM-DD HH24:MI:SS') order by 2,7
new   7: and a.sid=s.sid and open_time > to_date('2019-01-03 15:00:00', 'YYYY-MM-DD HH24:MI:SS') order by 2,7

   INST_ID        SID CH                   STATUS      OPEN_TIME             SOFAR Mb      TOTMB   IO_COUNT % Complete TYPE      FILENAME
---------- ---------- -------------------- ----------- ------------------- ---------- ---------- ---------- ---------- --------- -----------------------------------------------------------------
         2       3217                      FINISHED    2019-01-03 21:23:41          1        100          3       1.00 INPUT     +DATA/sdbip/datafile/sdbipidx.290.870278463
         1       3217 rman channel=d1      FINISHED    2019-01-03 21:23:42          1        100          3       1.00 INPUT     +DATA/sdbip/datafile/sdbiprange1.291.870278501
         1       3217 rman channel=d1      FINISHED    2019-01-03 21:23:41          1        100          3       1.00 INPUT     +DATA/sdbip/datafile/sdbipidx.290.870278463
         2       3217                      FINISHED    2019-01-03 21:23:42          1        100          3       1.00 INPUT     +DATA/sdbip/datafile/sdbiprange1.291.870278501
         1       3217 rman channel=d1      FINISHED    2019-01-03 21:23:11        139       2048        141       6.79 INPUT     +DATA/sdbip/datafile/users.265.976804941
         1       3217 rman channel=d1      FINISHED    2019-01-03 21:22:06        256       2048        258      12.50 INPUT     +DATA/sdbip/datafile/epsa.282.870259203
         2       3217                      FINISHED    2019-01-03 21:22:06        256       2048        258      12.50 INPUT     +DATA/sdbip/datafile/epsa.282.870259203
         2       3217                      FINISHED    2019-01-03 21:23:00         10       2048         12        .49 INPUT     +DATA/sdbip/datafile/reportdat1.284.870259389
         1       3217 rman channel=d1      FINISHED    2019-01-03 21:23:03         35       2048         37       1.71 INPUT     +DATA/sdbip/datafile/sdbip_va1.288.870259823
         1       3217 rman channel=d1      FINISHED    2019-01-03 21:23:03        2.5       2048          5        .12 INPUT     +DATA/sdbip/datafile/flow.286.870259539
         2       3217                      FINISHED    2019-01-03 21:23:03         35       2048         37       1.71 INPUT     +DATA/sdbip/datafile/sdbip_va1.288.870259823
         2       3217                      FINISHED    2019-01-03 21:23:03        2.5       2048          5        .12 INPUT     +DATA/sdbip/datafile/flow.286.870259539
         1       3217 rman channel=d1      FINISHED    2019-01-03 21:23:00         10       2048         12        .49 INPUT     +DATA/sdbip/datafile/reportdat1.284.870259389
         2       3217                      FINISHED    2019-01-03 21:23:11        139       2048        141       6.79 INPUT     +DATA/sdbip/datafile/users.265.976804941
         2       3217                      FINISHED    2019-01-03 21:21:04      290.5       4548        293       6.39 INPUT     +DATA/sdbip/datafile/sysaux.272.976804811
         1       3217 rman channel=d1      FINISHED    2019-01-03 21:21:04      290.5       4548        293       6.39 INPUT     +DATA/sdbip/datafile/sysaux.272.976804811
         1       3217 rman channel=d1      FINISHED    2019-01-03 21:07:26      17946      18432      17948      97.36 INPUT     +DATA/sdbip/datafile/system.273.976804561
         2       3217                      FINISHED    2019-01-03 21:07:26      17946      18432      17948      97.36 INPUT     +DATA/sdbip/datafile/system.273.976804561
         1       3217 rman channel=d1      FINISHED    2019-01-03 20:57:07       2922      31744       2926       9.20 INPUT     +DATA/sdbip/datafile/undotsb1.1.dbf
         2       3217                      FINISHED    2019-01-03 20:57:07       2922      31744       2926       9.20 INPUT     +DATA/sdbip/datafile/undotsb1.1.dbf
         1       3217 rman channel=d1      FINISHED    2019-01-03 20:30:50    29554.5      32724      29557      90.31 INPUT     +DATA/sdbip/datafile/users.259.869568449
         2       3217                      FINISHED    2019-01-03 20:30:50    29554.5      32724      29557      90.31 INPUT     +DATA/sdbip/datafile/users.259.869568449
         1       3217 rman channel=d1      FINISHED    2019-01-03 19:26:27   32745.05   32767.98      32747      99.93 INPUT     +DATA/sdbip/datafile/system.256.869568449
         2       3217                      FINISHED    2019-01-03 19:26:27   32745.05   32767.98      32747      99.93 INPUT     +DATA/sdbip/datafile/system.256.869568449
         2       3217                      FINISHED    2019-01-03 19:26:27    2073.48   32767.98       2075       6.33 INPUT     +DATA/sdbip/datafile/sysaux.257.869568449
         2       3217                      FINISHED    2019-01-03 19:26:27    4522.55   32767.98       4525      13.80 INPUT     +DATA/sdbip/datafile/undotbs1.258.869568449
         2       3217                      FINISHED    2019-01-03 19:26:27   15240.05   32767.98      15243      46.51 INPUT     +DATA/sdbip/datafile/undotbs2.271.869568607
         2       3217                      FINISHED    2019-01-03 19:33:53   16000.05   32767.98      16004      48.83 INPUT     +DATA/sdbip/datafile/undotsb2.dbf
         2       3217                      FINISHED    2019-01-03 19:42:09    4858.55   32767.98       4861      14.83 INPUT     +DATA/sdbip/datafile/undotsb1.dbf
         2       3217                      FINISHED    2019-01-03 19:58:52   16491.05   32767.98      16503      50.33 INPUT     +DATA/sdbip/datafile/undotsb2.1.dbf
         2       3217                      FINISHED    2019-01-03 20:19:59   32746.05   32767.98      32748      99.93 INPUT     +DATA/sdbip/datafile/system.298.902162119
         2       3217                      FINISHED    2019-01-03 20:29:37     365.98   32767.98        367       1.12 INPUT     +DATA/sdbip/datafile/sysaux.299.920734519
         1       3217 rman channel=d1      FINISHED    2019-01-03 19:26:27    2073.48   32767.98       2075       6.33 INPUT     +DATA/sdbip/datafile/sysaux.257.869568449
         1       3217 rman channel=d1      FINISHED    2019-01-03 19:26:27   15240.05   32767.98      15243      46.51 INPUT     +DATA/sdbip/datafile/undotbs2.271.869568607
         1       3217 rman channel=d1      FINISHED    2019-01-03 19:26:27    4522.55   32767.98       4525      13.80 INPUT     +DATA/sdbip/datafile/undotbs1.258.869568449
         1       3217 rman channel=d1      FINISHED    2019-01-03 19:33:53   16000.05   32767.98      16004      48.83 INPUT     +DATA/sdbip/datafile/undotsb2.dbf
         1       3217 rman channel=d1      FINISHED    2019-01-03 19:42:09    4858.55   32767.98       4861      14.83 INPUT     +DATA/sdbip/datafile/undotsb1.dbf
         1       3217 rman channel=d1      FINISHED    2019-01-03 20:29:37     365.98   32767.98        367       1.12 INPUT     +DATA/sdbip/datafile/sysaux.299.920734519
         1       3217 rman channel=d1      FINISHED    2019-01-03 20:19:59   32746.05   32767.98      32748      99.93 INPUT     +DATA/sdbip/datafile/system.298.902162119
         1       3217 rman channel=d1      FINISHED    2019-01-03 19:58:52   16491.05   32767.98      16503      50.33 INPUT     +DATA/sdbip/datafile/undotsb2.1.dbf
         2       3217                      FINISHED    2019-01-03 19:26:27     299530     322536     299532      92.87 INPUT     +DATA/sdbip/datafile/dwsdbip1.283.870259343
         1       3217 rman channel=d1      FINISHED    2019-01-03 19:26:27     299530     322536     299532      92.87 INPUT     +DATA/sdbip/datafile/dwsdbip1.283.870259343
         2       3217                      FINISHED    2019-01-03 19:26:27     476631     482160     476633      98.85 INPUT     +DATA/sdbip/datafile/kettle1.287.870259623
         1       3217 rman channel=d1      FINISHED    2019-01-03 19:26:27     476631     482160     476633      98.85 INPUT     +DATA/sdbip/datafile/kettle1.287.870259623
         2       3217                      IN PROGRESS 2019-01-03 19:26:26  559801.99     760096     559802      73.65 INPUT     +DATA/sdbip/datafile/sdbipdat1.281.870258811
         1       3217 rman channel=d1      IN PROGRESS 2019-01-03 19:26:26  559801.99     760096     559802      73.65 INPUT     +DATA/sdbip/datafile/sdbipdat1.281.870258811
         2       3217                      IN PROGRESS 2019-01-03 19:26:26  559801.99    2424608     559802      23.09 INPUT     +DATA/sdbip/datafile/odssdbip1.285.870259461
         1       3217 rman channel=d1      IN PROGRESS 2019-01-03 19:26:26  559801.99    2424608     559802      23.09 INPUT     +DATA/sdbip/datafile/odssdbip1.285.870259461
         2       3217                      IN PROGRESS 2019-01-03 19:26:25     386535                386536            OUTPUT    /rmanbak/orcl_full_55tme1iv_1_1
         1       3217 rman channel=d1      IN PROGRESS 2019-01-03 19:26:25     386535                386536            OUTPUT    /rmanbak/orcl_full_55tme1iv_1_1

50 rows selected.


Tape backuppiece progress (only if backup_tape_io_slaves=FALSE):

old   6: open_time > to_date('&1', 'YYYY-MM-DD HH24:MI:SS')
new   6: open_time > to_date('2019-01-03 15:00:00', 'YYYY-MM-DD HH24:MI:SS')

no rows selected
```

## Script-2
<!--oracle查看RMAN备份完成需要时间-->

```
select inst_id,sid,serial#,opname,COMPLETE,
trunc(((to_char(last_update_time,'dd')-to_char(start_time,'dd'))*60*24+(to_char(last_update_time,'hh24')-to_char(start_time,'hh24'))*60 +(to_char(last_update_time,'mi')-to_char(start_time,'mi')))*(100-complete)/complete) min from
(
SELECT inst_id,
sid,
serial#,
opname,
ROUND(SOFAR / TOTALWORK * 100, 2) COMPLETE,
LAST_UPDATE_TIME,
START_TIME
FROM gV$SESSION_LONGOPS
WHERE OPNAME LIKE 'RMAN%'
AND OPNAME NOT LIKE '%aggregate%'
AND TOTALWORK != 0
AND SOFAR <> TOTALWORK
) t
;
```

## Script-2运行结果样例

```
   INST_ID        SID CH                                                                  CONTEXT      SOFAR  TOTALWORK % Complete
---------- ---------- ---------------------------------------------------------------- ---------- ---------- ---------- ----------
         1       3217 rman channel=d1                                                           1  294292458  560921582      52.47
         2       3217                                                                           1  294292458  560921582      52.47
```

