define fileName=Inspur_Oracle_Check
COLUMN spool_time NEW_VALUE _spool_time NOPRINT
SELECT TO_CHAR(SYSDATE,'YYYY-MM-DD') spool_time FROM dual;
COLUMN hostname NEW_VALUE _host_name NOPRINT
select host_name hostname from v$instance;
COLUMN instance_name NEW_VALUE _SID NOPRINT
select instance_name from v$instance;
define pfileName=&_SID._&_spool_time.
prompt +----------------------------------------------------------------------------+
prompt |                       Oracle Database Check Result                         |
prompt |----------------------------------------------------------------------------+
prompt |             Copyright (c) 2018-2019 . Inspur All rights reserved.          |
prompt +----------------------------------------------------------------------------+
prompt
prompt Note: Oracle DB Health Check is starting...
prompt
prompt After this script has already executed successfully.
prompt
--&FileName._&_host_name._&_SID._&_spool_time..html的中文解释Inspur_Oracle_Check_主机名_实例名_巡检时间.html
prompt Please send &FileName._&_host_name._&_SID._&_spool_time..html to support@Inspur.com.
prompt
prompt More information about Inspur : http://www.Inspur.com.
prompt 

define reportHeader="<font size=+3 color=darkgreen><b>Inspur Oracle Database Check Result For &Application_Name</b></font><hr>Copyright (c) 2018-2019 <a target=""_blank"" href=""http://www.Inspur.com"">Inspur</a>. All rights reserved.<p>"


set termout       off
set echo          off
set feedback      off
set verify        off
set wrap          on
set trimspool     on
set serveroutput  on
set escape        on
set pagesize 50000
set long     2000000000
set numw 16
col error format a30
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
set markup html on spool on preformat off entmap on -
head ' -
  <title>Oracle Database Check result</title> -
  <style type="text/css"> -
    body              {font:10pt Arial,Helvetica,sans-serif; color:black; background:White;} -
    p                 {font:10pt Arial,Helvetica,sans-serif; color:black; background:White;} -
    table,tr,td       {font:10pt Arial,Helvetica,sans-serif; color:Black; background:#FFFFCC; padding:0px 0px 0px 0px; margin:0px 0px 0px 0px;} -
    th                {font:bold 10pt Arial,Helvetica,sans-serif; color:White; background:#0066cc; padding:0px 0px 0px 0px;} -
    h1                {font:bold 12pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:#0066cc; border-bottom:1px solid #cccc99; margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;} -
    h2                {font:bold 10pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; margin-top:4pt; margin-bottom:0pt;} -
	a                 {font:10pt Arial,Helvetica,sans-serif; color:#663300; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
  </style>' -
body   'BGCOLOR="#C0C0C0"' -
table  'WIDTH="90%" BORDER="1"' 

spool &FileName._&_host_name._&_SID._&_spool_time..html
set markup html on entmap off
prompt &reportHeader

SET MARKUP HTML ON

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>1.Check Time</b></font>
select sysdate as current_date from dual;
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>2.DB Version</b></font>
select * from v$version;
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>3.RDBMS Patch Info</b></font>
select * from dba_registry_history;
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>4.DBID and Created Time</b></font>
select dbid,name,created from v$database;
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>5.Instance Start Time</b></font>
alter session set NLS_DATE_FORMAT='YYYY-MM-DD HH24:MI:SS';
select INSTANCE_NUMBER,INSTANCE_NAME,HOST_NAME,STARTUP_TIME ,STATUS from sys.v_$instance;
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>6.ASM Disk (Group) Usage</b></font>
select GROUP_NUMBER,NAME,STATE,TYPE,TOTAL_MB,FREE_MB,USABLE_FILE_MB from v$asm_diskgroup;
select a.group_number,b.name as group_name,a.name,a.path,a.state,a.total_mb from v$asm_disk a,v$asm_diskgroup b where a.group_number=b.group_number;
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>7.LOG and Flashback Info</b></font>
select force_logging,supplemental_log_data_min,supplemental_log_data_all,flashback_on from v$database;
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>8.Session Info</b></font>
select inst_id, sessions_current,sessions_highwater from  gv$license;
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>9.DB Parameter</b></font>
select inst_id,name,value from gv$parameter where value is not null;
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>10.Profiles Info</b></font>
select * from dba_profiles;
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>11.Character Set</b></font>
select userenv('language') from dual;
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>12.Instance status</b></font>
select inst_id,instance_number,instance_name,host_name,status from gv$instance;
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>13.DB v$option</b></font>
select *  from v$option where value='TRUE';
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>15.Controlfile Info</b></font>
Select * from v$controlfile;
alter session set tracefile_identifier='bak_control';
alter database backup controlfile to trace;
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>16.Redo log Info</b></font>
select thread#, GROUP#,SEQUENCE#,BYTES/1024/1024,STATUS,FIRST_TIME from v$log;
select * from v$logfile;
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>17.Archivelog Information</b></font>
archive log list;
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>18.v$recover_log and v$recover_file</b></font>
select THREAD#,SEQUENCE# SEQUENCE#,
TIME "TIME"
from v$recovery_log;

select file#,online_status "STATUS",
change# "SCN",
time"TIME" 
from v$recover_file;

SELECT a.recid,
a.thread#,
a.sequence#, 
a.name, 
a.first_change#,
a.NEXT_CHANGE#,
a.archived, 
a.deleted,
a.completion_time
FROM v$archived_log a, v$recovery_log l
WHERE a.thread# = l.thread#
AND a.sequence# = l.sequence#;
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>19.Tablespace Usage</b></font>
prompt <font><B>Number of tablespaces:</B></font>
select count(name) as Number_of_tablesapces from v$tablespace;
prompt <font><B>Note:</B></font>
prompt <br>
prompt <font><B>Follow result no include autoextend space :</B></font>
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
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font><B>20.Follow result include autoextend space for SYSTEM and SYSAUX:</B></font>
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
and f.tablespace_name in ('SYSTEM','SYSAUX')
order by  used_percent_with_extend desc;
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>21.Temp Tablespace Info</b></font>
select username,account_status,default_tablespace,temporary_tablespace from dba_users;
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>22.Temp Tablespace Size</b></font>
select tablespace_name,file_name,bytes/1024/1024,autoextensible,maxbytes/1024/1024 from dba_temp_files;
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>23.Temp Tablespace Usage</b></font>
SELECT d.tablespace_name "Name",
            TO_CHAR(NVL(a.bytes / 1024 / 1024, 0),'99,999,990.900') "Size (M)",
            TO_CHAR(NVL(t.hwm, 0)/1024/1024,'99999999.999')  "HWM (M)",
            TO_CHAR(NVL(t.hwm / a.bytes * 100, 0), '990.00') "HWM % " ,
            TO_CHAR(NVL(t.bytes/1024/1024, 0),'99999999.999') "Using (M)",
            TO_CHAR(NVL(t.bytes / a.bytes * 100, 0), '990.00') "Using %"
       FROM sys.dba_tablespaces d,
            (select tablespace_name, sum(bytes) bytes from dba_temp_files group by tablespace_name) a,
            (select tablespace_name, sum(bytes_cached) hwm, sum(bytes_used) bytes from v$temp_extent_pool group by tablespace_name) t
      WHERE d.tablespace_name = a.tablespace_name(+)
        AND d.tablespace_name = t.tablespace_name(+)
        AND d.extent_management like 'LOCAL'
        AND d.contents like 'TEMPORARY';
prompt <font><B>Note:</B></font>
prompt <br>


prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>25.RMAN Backup Info in recent 15 days</b></font>
select session_key,autobackup_done,output_device_type,input_type,status,elapsed_seconds/3600 hours,to_char(start_time,'yyyy-mm-dd hh24:mi') start_time,
output_bytes_display out_size,output_bytes_per_sec_display,input_bytes_per_sec_display from v$rman_backup_job_details order by start_time;
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>26.STATISTICS</b></font>
select * from DBA_TAB_STATISTICS where OWNER in ('PM4H_DB', 'PM4H_MO', 'PM4H_HW') where  last_analyzed is not null and last_analyzed <= (sysdate-2);
select * from DBA_TAB_COL_STATISTICS where OWNER in ('PM4H_DB', 'PM4H_MO', 'PM4H_HW') where last_analyzed is not null and last_analyzed <= (sysdate-2);
select * from DBA_IND_STATISTICS where OWNER in ('PM4H_DB', 'PM4H_MO', 'PM4H_HW') where last_analyzed is not null and last_analyzed <= (sysdate-2);
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>27.Waiting Events</b></font>
select inst_id,event,count(1) from gv$session where wait_class#<> 6 group by inst_id,event order by 1,3;
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>28.Client connection distribution</b></font>
select inst_id,machine ,count(*) from gv$session group by machine,inst_id order by 3;
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>29.Redo log switch times per hour in recent 15 days</b></font>
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
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>30.Total undeleted archivelog size</b></font>
select  ((sum(blocks * block_size)) /1024 /1024) as "MB" from v$archived_log where  STANDBY_DEST  ='NO'  and deleted='NO';
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>31.Daily generated archive size for all instances</b></font>
select 
trunc(completion_time) as "Date"
,count(*) as "Count"
,((sum(blocks * block_size)) /1024 /1024) as "MB"
from v$archived_log where  STANDBY_DEST  ='NO' 
group by trunc(completion_time) order by trunc(completion_time) ;
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>32.Daily Transactions</b></font>
select instance_number,
metric_unit,
trunc(begin_time) time,
avg(average)*60*60*24 "Transactions Per Day"
from DBA_HIST_SYSMETRIC_SUMMARY
where metric_unit = 'Transactions Per Second'
and begin_time >=
to_date(sysdate-7, 'yyyy-mm-dd hh24:mi:ss')
and begin_time < to_date(sysdate, 'yyyy-mm-dd hh24:mi:ss')
group by instance_number, metric_unit, trunc(begin_time)
order by instance_number;
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>33.Users with DBA authority</b></font>
select * from dba_role_privs where granted_role='DBA';
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>34.Dblink info</b></font>
SELECT 'CREATE '||DECODE(U.NAME,'PUBLIC','public ')||'DATABASE LINK '||CHR(10)
||DECODE(U.NAME,'PUBLIC',Null, 'SYS','',U.NAME||'.')|| L.NAME||chr(10)
||'CONNECT TO ' || L.USERID || ' IDENTIFIED BY "'||L.PASSWORD||'" USING 
'''||L.HOST||''''
||chr(10)||';' TEXT
FROM SYS.LINK$ L, SYS.USER$ U
WHERE L.OWNER# = U.USER#;
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>35.max(object_id)</b></font>
select max(object_id) from dba_objects;
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>36.Security Check</b></font>
select 'DROP TRIGGER '||owner||'."'||TRIGGER_NAME||'";' from dba_triggers where
TRIGGER_NAME like 'DBMS_%_INTERNAL% '
union all
select 'DROP PROCEDURE '||owner||'."'||a.object_name||'";' from dba_procedures a 
where a.object_name like 'DBMS_%_INTERNAL% ';
select owner,object_name,created from dba_objects where object_name like 'DBMS_SUPPORT_DBMONITOR%';
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>37.Dataguard Info</b></font>
select protection_mode, protection_level, database_role from v$database;
select log_mode,open_mode from v$database;
select max(sequence#),applied,thread# from v$archived_log group by applied,thread# order by thread#;
SELECT  PROCESS, STATUS,THREAD#,SEQUENCE#,BLOCK#,BLOCKS, DELAY_MINS FROM V$MANAGED_STANDBY;
select * from v$archive_gap;
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>38.Create pfile</b></font>
create pfile='/home/oracle/pfile_&pfileName..ora' from spfile;
prompt <br>
prompt <font><B>Note:Pfile was created successfully as <font color="blue">"pfile_&pfileName..ora"</font>.Please download it!</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>39.SCN Headroom Info</b></font>
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
prompt <br>
prompt <font><B>Note:</B></font>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>40.Unusable Index(es)</b></font>
select t.owner,t.index_name,t.table_name,blevel,t.num_rows,t.leaf_blocks,t.distinct_keys  from dba_indexes t
where status = 'UNUSABLE'
and  table_owner not in ('ORDDATA','ORDSYS','DMSYS','APEX_030200','OUTLN','DBSNMP','SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','SQLTXPLAIN','OWBSYS','FLOWS_FILES')
and owner in (select username from dba_users where account_status='OPEN');
prompt <font><B>Note:</B></font>
prompt <br>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Unusable partitioned Index(es)</b></font>
SELECT T.INDEX_OWNER ,T.INDEX_NAME,T.PARTITION_NAME,BLEVEL,T.NUM_ROWS,T.LEAF_BLOCKS,T.DISTINCT_KEYS
  FROM DBA_IND_PARTITIONS T
 WHERE STATUS = 'UNUSABLE'
   AND INDEX_OWNER NOT IN ('ORDDATA','ORDSYS','DMSYS','APEX_030200','OUTLN','DBSNMP','SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','SQLTXPLAIN','OWBSYS','FLOWS_FILES')
   and INDEX_OWNER  IN (select username from dba_users where account_status='OPEN');
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>41.Index(es) of blevel>=3</b></font>
col INDEX_NAME for a30
SELECT owner,index_name,blevel FROM dba_indexes WHERE blevel >= 3 ORDER BY blevel DESC;
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>42.Other Index Type</b></font>
select t.owner,t.table_name,t.index_name,t.index_type,t.status,t.blevel,t.leaf_blocks from dba_indexes t
where index_type in ('BITMAP', 'FUNCTION-BASED NORMAL', 'NORMAL/REV')
and owner not in ('ORDDATA','ORDSYS','DMSYS','APEX_030200','OUTLN','DBSNMP','SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','ORDSYS','DBSNMP','OUTLN','TSMSYS') and owner in (select username from dba_users where account_status='OPEN');
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>43.Any Business data in system tablespace</b></font>
select * from (select owner, segment_name, segment_type,tablespace_name
  from dba_segments where tablespace_name in('SYSTEM','SYSAUX'))
where  owner not in ('MTSSYS','ORDDATA','ORDSYS','DMSYS','APEX_030200','OUTLN','DBSNMP','SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','ORDSYS','DBSNMP','OUTLN','TSMSYS') and owner in (select username from dba_users where account_status='OPEN');
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>44.Table(s) of degree > 1</b></font>
select owner,table_name name,status,degree from dba_tables where degree>1;
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>45.Index(es) of degree > 1</b></font>
select owner,index_name name,status,degree from dba_indexes where degree>'1';
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>46.Disabled Trigger(es)</b></font>
SELECT owner, trigger_name, table_name, status FROM dba_triggers WHERE status = 'DISABLED' and owner in (select username from dba_users where account_status='OPEN');
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>47.Disabled Constraint(s)</b></font>
SELECT owner, constraint_name, table_name, constraint_type, status 
FROM dba_constraints WHERE status ='DISABLE' and constraint_type='P' and owner in (select username from dba_users where account_status='OPEN');
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>48.Foreign Key no index</b></font>
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
and c.owner in(select username from dba_users where account_status='OPEN' and username not in ('MTSSYS','ORDDATA','ORDSYS','DMSYS','APEX_030200','OUTLN','DBSNMP','SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','ORDSYS','DBSNMP','OUTLN','TSMSYS')) order by c.owner;
prompt <font><B>Note:</B></font>
prompt <br>


prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>49.Datafile of Numbers</b></font>
select count(*) from dba_data_files; 
prompt <font><B>Note:</B></font>
prompt <br>

prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Datafile Info</b></font>
select file_id,tablespace_name,file_name,bytes/1024/1024,status,autoextensible,maxbytes/1024/1024 from dba_data_files; 
prompt <font><B>Note:</B></font>
prompt <br>
spool off
prompt 
quit