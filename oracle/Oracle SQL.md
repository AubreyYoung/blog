# Oracle SQL
```
select to_char(standby_became_primary_scn) from v$database;
archive log list；
archive log all；
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;
RECOVER MANAGED STANDBY DATABASE DISCONNECT USING CURRENT LOGFILE;
select max(sequence#),thread# from v$archived_log where RESETLOGS_CHANGE# = (SELECT RESETLOGS_CHANGE# FROM V$DATABASE_INCARNATION WHERE STATUS = 'CURRENT') GROUP BY THREAD#;
select max(sequence#),thread# from v$archived_log where  applied='YES' and RESETLOGS_CHANGE# = (SELECT RESETLOGS_CHANGE# FROM V$DATABASE_INCARNATION WHERE STATUS = 'CURRENT') GROUP BY THREAD#;
select max(sequence#),applied,thread# from v$archived_log group by applied,thread# order by thread#;
alter system switch logfile;
alter database set standby to maximize performance;
alter database set standby to maximize availability;
alter database set standby  to maximize protection;
recover database using bakup controlfile until cancel;
```

```
**删除table**
drop table  bh cascade constraints purge;
**修改归档**
alter system set log_archive_dest_1='location=/arch mandatory'
alter system set log_archive_dest_1='location=/arch optional'
**修改FRA**
alter system set db_recovery_file_dest='' scope=both;
alter system set db_recovery_file_dest='/fra' scope=both;
alter system set db_recovery_file_dest_size=20G scope=both;
alter system set log_archive_dest_10='location=USE_DB_RECOVERY_FILE_DEST'
**FRA查看**
select * from dba_outstanding_alerts;
select * from v$recovery_file_dest;
select * from v$flash_recovery_area_usage;
**RDBMS日志位置**
select  * from v$diag_info;
**密码文件参数**
alter system set remote_login_passwordfile=exclusive scope=spfile;
**RMAN非默认值**
select  * from v$rman_configuration;
**RMAN信道配置**
configure channel divice type;
configure channel n divice type;               ###配置默认设备
configure channel divice type clear;
configure channel n divice type clear;
configure default device type to sbt;
configure default device type to disk;
configure device type disk backup type to backupset;
configure device type disk backup type to compressed backupset;
configure device type disk backup type to copy;
configure device type disk backup type to parallelism 2;
configure channel 2 device type disk format '/rmanbackup/backup_%U';
configure channel 2 device type disk maxpiecessize 100m maxopenfiles 8 rate 100MB;
configure channel device type disk maxpiecessize 100m maxopenfiles 8 rate 100MB;
configure channel  device  type sbt maxpiecesize 100m parms 'ENV=(NB_ORA-CLASS=RMAN_rs100_tape)';
configure datafile backup copies for  device  type disk to 2;
configure exclude for tablespace old_data;
configure backup optimization on;
configure  snapshot  controlfile name to '/home/oracle/scontrolf_orcl';
configure controlfile  autobackup on;
configure controlfile  autobackup off;
configure controlfile autobackup format for device type disk to '/rman/orcl_%F';
configure retention policy to recovery windows of 3 days;
configure retention policy to redundancy 3;
configure retention policy to none;
configure retention policy clear;
report obsolete;
delete obsolete;
set  encryption on identified by password only;
set  encryption on identified by password;
configure encryption for database on;
set encryption on identified by password only;
select algorithm_name from v$rman_encryption_algorithms;
configure encryption algorithm 'AES128';
configure archivelog deletion policy to backup up 3 times to device type disk;
configure archivelog deletion policy applied on standby;
alter system set deferred_segment_creation=FALSE;
alter system set audit_trail             =none           scope=spfile;
alter system set SGA_MAX_SIZE            =xxxxxM         scope=spfile;
alter system set SGA_TARGET              =xxxxxM         scope=spfile;
alter systemn set pga_aggregate_target   =XXXXXM         scope=spfile;
Alter PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;
SELECT resource_name,limit FROM dba_profiles WHERE profile='DEFAULT' AND resource_name='PASSWORD_LIFE_TIME';
alter database add SUPPLEMENTAL log data;
alter system set enable_ddl_logging=true;
**关闭11g密码延迟验证新特性**
ALTER SYSTEM SET EVENT = '28401 TRACE NAME CONTEXT FOREVER, LEVEL 1' SCOPE = SPFILE;
**限制trace日志文件大最大25M**
alter system set max_dump_file_size ='25m' ;
**关闭密码大小写限制**
ALTER SYSTEM SET SEC_CASE_SENSITIVE_LOGON = FALSE;
alter system set db_files=2000 scope=spfile;
**RAC修改local_listener：（现象：使用PlSql Developer第一次连接超时，第二次之后连接正常）**
alter system set local_listener = '(ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.0.125)(PORT = 1521))' sid='orcl1';
alter system set local_listener = '(ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.0.130)(PORT = 1521))' sid='orcl2';
HOST = 192.168.1.216 --此处使用数字形式的VIP，绝对禁止使用rac1-vip
HOST = 192.168.1.219 --此处使用数字形式的VIP，绝对禁止使用rac2-vip
**更改控制文件记录保留时间**
alter system set control_file_record_keep_time =31;
SELECT VALUE FROM V$DIAG_INFO WHERE NAME = 'Diag Trace';
SELECT VALUE FROM V$DIAG_INFO WHERE NAME = 'Default Trace File';
SELECT PID, PROGRAM, TRACEFILE FROM V$PROCESS;
alter system register;
create tablespace catalog datafile size 15M autoextend on;
create tablespace catalog_tbs datafile size 50M autoextend on;
create user rcat_user identified by oracle default tablespace catalog;
grant connect,resource,recovery_catalog_owner to tcat_user;

grant sysdba to backup_admin;
rman target=backup_admin/oracle@central catalog=rcat_user/oracle@orcl
register database;
report schema;
catalog datafilecopy '/orabak/***.dbf';
catalog archivelog '/orabak/***.arc';
catalog backuppiece '/orabak/\***.bkp';
catalog start with '/orabak/';
unregister database;
unregister database central;
RUN{SET DBID 2385199057; UNREGISTER DATABASE central NOPROMPT; }
create user farouka identified by oracle default tablespace catalog_tbs quota unlimited on catalog_tbs;
grant recovery_catalog_owner to farouka;
rman catalog=rcat_user/oracle@orcl
grant catalog for database orcl to farouka;
grant register database to farouka;
rman catalog=farouka/oracle@orcl

> create virtual catalog;
> execute rcat_user.DBMS_RCVCAT.create_virtual_catalog;
> import catalog rcvcat_user@RCAT1 DB_NAME=TEST,DEV,PROD;
> list backup of database;
> connect target backup_admin/oracle@central
> select * from rcver;
> upgrade catalog;
> reset database to incarnation 5;
> resync catalog;
> **清除恢复目录记录**
> $ORACLE_HOME/rdbms/admin/prgrmanc.sql
> select * from rc_database_incarnation;
> delete from dbinc where DBINC_KEY=317;
> select * from dbinc;
> select * from rc_backup_set;
> select * from rc_backup_set;
> **rc_archived_log(v$archived_log)**
> col name for a50
> col COMPLETION_TIME for a25
> alter session set nls_date_format='DD-MON-YYYY:HH24:MI:SS';
> select name,sequence#,status,COMPLETION_TIME from rc_archived_log;
> select * from v$archived_log;
> **rc_backup_controlfile(v$backup_datafile)**
> select file#,creation_time,resetlogs_time,blocks,block_size,controlfile_type from v$backup_datafile where file#=0;
> col completion_time for a25
> col autobackup_date for a25
> alter session set nls_date_format='DD-MON-YYYY:HH24:MI:SS';
> select db_name,status,completion_time,controlfile_type,autobackup_date from rc_backup_controlfile;
> **rc_backup_corruption(v$backup_corruption)备份集备份时产生的损坏块**
> select db_name,piece#,file#,block#,blocks,corruption_type from rc_backup_corruption where db_name='CENTRAL';
> **rc_backup_datafile(v$backup_datafile)**
> **rc_backup_files(v$backup_files)**
> CALL DBMS_RCVMAN.SETDATABASE(null,null,null,2283997583,null);
> select backup_type,file_type,status,bytes from rc_backup_files;
> ###rc_database_corruption(v$backup_corruption):数据库中的损坏块
> ###rc_backup_piece(v$backup_piece)
> ###rc_backup_redolog(v$backup_redolog):归档日志
> alter session set nls_date_format='DD-MON-YYYY:HH24:MI:SS';
> select db_name,bs_key,sequence#,thread#,first_change#,status from rc_backup_redolog;
> ###rc_backup_set(v$backup_set)
> ###rc_backup_spfile(v$backup_spfile)
> ###rc_controlfile_copy(v$datafile_copy)
> ###rc_copy_corruption(v$copy_corruption)
> selec db_name,file#,block#,blocks,corruption_type from rc_copy_corruption where db_name='CENTRAL';
> ###rc_database(v$database)
> ###rc_database_block_corruption(v$database_block_corruption)
> blockrecover corruption list;
> select file#,block#,orruption_type from v$database_block_corruption;
> ###rc_database_incarnation(v$database_incarnation)
> select dbid,name,dbinc_key,resetlog_time,current_incarnation from rc_database_incarnation where db_key=<database key> and dbinc_key=<current incarnation key number>;
> ###rc_datafile(v$datafile)
> select db_name,ts#,tablespace_name,file#,name,bytes,included_in_database_backup,aux_name from rc_datafile where db_name='CENTEAL';
> ###rc_datafile_copy(v$datafile_copy)
> ###rc_log_history(v$log_history)
> ###rc_offline_range(v$offline_range)
> ###rc_redo_log(v$log,v$logfile)
> ###rc_redo_thread(v$thread)
> select db_name,thread#,status,sequence# from rc_redo_thread where db_name='CENTRAL';
> ###rc_resync
> select db_name,controlfile_name,controlfile_sequence#,resync_type,resync_time from re_sync where db_name='CENTRAL';
> ###rc_rman_configuration(v$rman_configuration)
> select name,value from rc_rman_configuration where db_key=1;
> ###rc_tablespace(v$tablespace)
> ###rc_tempfile(v$tempfile)
> select * from v$database_block_corruption;
> alter tablespace TBS_APTSTA_BSVC add datafile '+DATA' size 31G autoextend on；
> select ksppinm, ksppstvl from x$ksppi pi, x$ksppcv cv where cv.indx=pi.indx and pi.ksppinm ='_external_scn_rejection_threshold_hours';
> #删除表空间
> drop tablespace test including contents and datafiles cascade constraints;
> oracle查看RMAN备份完成需要时间
> select inst_id,sid,serial#,opname,COMPLETE,
> trunc(((to_char(last_update_time,'dd')-to_char(start_time,'dd'))*60*24+(to_char(last_update_time,'hh24')-to_char(start_time,'hh24'))*60 +(to_char(last_update_time,'mi')-to_char(start_time,'mi')))*(100-complete)/complete) min from
> (
> SELECT inst_id,
> sid,
> serial#,
> opname,
> ROUND(SOFAR / TOTALWORK * 100, 2) COMPLETE,
> LAST_UPDATE_TIME,
> START_TIME
> FROM gV$SESSION_LONGOPS
> WHERE OPNAME LIKE 'RMAN%'
> AND OPNAME NOT LIKE '%aggregate%'
> AND TOTALWORK != 0
> AND SOFAR <> TOTALWORK
> ) t
> ;
> ##AQ drop
> alter session set events'10851 trace name context forever,level 2';
> drop user ×× cascade
> alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
> select rownum,
> empno,
> ename,
> mgr,
> sal + 300 newsal,
> decode(mgr, null, '大老板', '下级员工') jd
> from scott.emp
> where ename in ('KING', 'SCOTT', 'JONES');
> select * from scott.emp where empno > 7700;
> select count(*) from scott.emp where deptno=30;
> select count(*),sum(sal),avg(sal) from scott.emp where ename like '%NE%';
> select ename,dname from scott.emp,scott.dept where empno>7750 and emp.deptno=dept.deptno;
> select ename,dname from scott.emp join scott.dept on emp.deptno=dept.deptno where empno>7750;
> select ename,dname from  scott.emp join scott.dept using(deptno) where empno>7750;
> insert into  emp (EMPNO,ENAME,JOB,HIREDATE) values (8001,'MAPY','DBA','20161101');
> select job,count(distinct deptno) from emp where mgr is not null group by job order by count(distinct deptno),job;
> select job,count(distinct deptno) from emp where mgr is not null group by job order by 2,job;
> select job,count(distinct deptno) uniq_deptno from emp where mgr is not null group by job order by uniq_deptno desc,job;
> select sysdate from dual;
> select user from dual;
> select 889+323 from dual;
> select power(2,8) from dual;
> select to_char(sysdate,'YYYY-MM-DD') from dual;
> create sequence test2017;
> select test2017.nextval from dual;
> select test2017.currval from dual;
> drop sequence test2017;
> insert into test select * from emp;
> select ename || '''s sal is ' || sal from emp;   ###两个单引号代表一个'
> select distinct deptno from emp;
> select * from emp where deptno != 10;
> select * from emp where deptno <> 10;(标准写法)
> select * from emp where sal >= 800 and sal <= 1500;
> select * from emp where sal between 800 and 1500;
> select * from emp where sal=800 or sal=1500 or sal=2000;
> select * from emp where sal in (800,1500,2000);
> select * from emp where ename like '_A%';  ### _单个字符，%任意字符
> select * from emp where ename like '%\%%' escape '\'; ###定义转义字符，长度为1
> select * from emp where comm is null ;
> select * from emp where comm  is not  null ;
> select * from emp order by deptno,ename desc;### desc 只作用于ename
> select distinct deptno,job from emp;### distinct 作用于deptno和job
> select lower(ename) from emp;
> select upper(ename) from emp;
> select ename from emp where lower(ename) like '%a%';
> select substr('hello',1,2) from dual; ###字符从1开始
> SQL> select substr('hello',1,2) from dual;
> SU
> --
> he
> SQL> select substr('hello',0,2) from dual;
> SU
> --
> he
> SQL> select ascii('a') from dual;
> ASCII('A')
> ----------
> 97
> SQL> select ascii('A') from dual;
> ASCII('A')
> ----------
> 65
> SQL> select chr(65) from dual;
> C
> -
> A
> SQL> select round(12434.893,0) from dual;
> ROUND(12434.893,0)
> ------------------
> 12435
> SQL> select round(12434.893) from dual;
> ROUND(12434.893)
> ----------------
> 12435
> SQL> select round(12434.993,1) from dual;
> ROUND(12434.993,1)
> ------------------
> 12435
> SQL> select round(12434.993,2) from dual;
> ROUND(12434.993,2)
> ------------------
> 12434.99
> SQL> select round(12434.993,-1) from dual;
> ROUND(12434.993,-1)
> -------------------
> 12430
> SQL> select round(12434.993,-2) from dual;
> ROUND(12434.993,-2)
> -------------------
> 12400
> select sal*12+nvl(comm,0) from scott.emp;
> SQL> select count(7) from emp;
> COUNT(7)
> ----------
> 14
> SQL> select count(comm) from emp;
> COUNT(COMM)
> -----------
> 4
> select * from (select emp.*,rownum r  from emp where numrow<=10) where r>5;
> ###RMAN备份时间
> select inst_id,sid,serial#,opname,COMPLETE,
> trunc(((to_char(last_update_time,'dd')-to_char(start_time,'dd'))*60*24+(to_char(last_update_time,'hh24')-to_char(start_time,'hh24'))*60 +(to_char(last_update_time,'mi')-to_char(start_time,'mi')))*(100-complete)/complete) min from
> (
> SELECT inst_id,
> sid,
> serial#,
> opname,
> ROUND(SOFAR / TOTALWORK * 100, 2) COMPLETE,
> LAST_UPDATE_TIME,
> START_TIME
> FROM gV$SESSION_LONGOPS
> WHERE OPNAME LIKE 'RMAN%'
> AND OPNAME NOT LIKE '%aggregate%'
> AND TOTALWORK != 0
> AND SOFAR <> TOTALWORK
> ) t
> ;
> ###RMAN压缩备份
> connect target  /
> run
> {
> allocate channel d1 type disk;
> allocate channel d2 type disk;
> allocate channel d3 type disk;
> backup as compressed backupset incremental level 0 format '/rmanback/orcl_full_%U' database include current controlfile;
> delete noprompt obsolete device type disk;
> sql 'alter system archive log current';
> backup  format '/rmanback/orcl_arch_full_%U' archivelog all not backed up delete input;
> crosscheck backup;
> delete noprompt expired backup;
> release channel d1;
> release channel d2;
> release channel d3;
> }
> SQL> select supplemental_log_data_min from gv$database;

SUPPLEME
--------
NO
SQL> alter database add supplemental log data;
Database altered.
alter system set service_names='orcl' scope=both;
orapwd file=orapwmapy password=galaxy entries=2
select DB_UNIQUE_NAME,SWITCHOVER_STATUS,CURRENT_SCN from v$database;
sqlplus / as sysdba @dg_Primary_diag.sql
alter system archive log current;
-日志管理
1.forcing log switches
alter system switch logfile;
2.forcing checkpoints
alter system checkpoint;
3.adding online redo log groups
alter database add logfile group 4 ('/disk3/log4a.rdo','/disk4/log4b.rdo') size 1m;
4.adding online redo log members
alter database add logfile member
'/disk3/log1b.rdo' to group 1,
'/disk4/log2b.rdo' to group 2;
5.changes the name of the online redo logfile
alter database rename file 'c:/oracle/oradata/oradb/redo01.log' to 'c:/oracle/oradata/redo01.log';
6.drop online redo log groups
alter database drop logfile group 3;
7.drop online redo log members
alter database drop logfile member 'c:/oracle/oradata/redo01.log';
8.clearing online redo log files
alter database clear [unarchived] logfile 'c:/oracle/log2a.rdo';
9.using logminer analyzing redo logfiles
a. in the init.ora specify utl_file_dir = ' '
b. sql> execute dbms_logmnr_d.build('oradb.ora','c:\oracle\oradb\log');
c. sql> execute dbms_logmnr_add_logfile('c:\oracle\oradata\oradb\redo01.log',dbms_logmnr.new);
d. sql> execute dbms_logmnr.add_logfile('c:\oracle\oradata\oradb\redo02.log', dbms_logmnr.addfile);
e. sql> execute dbms_logmnr.start_logmnr(dictfilename=>'c:\oracle\oradb\log\oradb.ora');
f. sql> select * from v$logmnr_contents(v$logmnr_dictionary,v$logmnr_parameters v$logmnr_logs);
g. sql> execute dbms_logmnr.end_logmnr;
-表空间管理
1.create tablespaces
create tablespace ts_name datafile 'c:\oracle\oradata\file1.dbf' size 100m ,
'c:\oracle\oradata\file2.dbf' size 100m minimum extent 550k [logging/nologging]sql> default storage (initial 500k next 500k maxextents 500 pctinccease 0)
[online/offline] [permanent/temporary] [extent_management_clause]
2.locally managed tablespace
create tablespace user_data datafile 'c:\oracle\oradata\user_data01.dbf' size 500m extent management local uniform size 10m;
3.temporary tablespace
create temporary tablespace temp tempfile 'c:\oracle\oradata\temp01.dbf' size 500m extent management local uniform size 10m;
4.change the storage setting
alter tablespace app_data minimum extent 2m;
alter tablespace app_data default storage(initial 2m next 2m maxextents 999);
5.taking tablespace offline or online
alter tablespace app_data offline;
alter tablespace app_data online;
6.read_only tablespace
alter tablespace app_data read only|write;
7.droping tablespace
drop tablespace app_data including contents;
8.enableing automatic extension of data files
alter tablespace app_data add datafile 'c:\oracle\oradata\app_data01.dbf' size 200m autoextend on next 10m maxsize 500m;
9.change the size fo data files manually
alter database datafile 'c:\oracle\oradata\app_data.dbf' resize 200m;
10.Moving data files: alter tablespace
alter tablespace app_data rename datafile 'c:\oracle\oradata\app_data.dbf to 'c:\oracle\app_data.dbf';
11.moving data files:alter database
alter database rename file 'c:\oracle\oradata\app_data.dbf' to 'c:\oracle\app_data.dbf';
-表
1.create a table
create table table_name (column datatype,column datatype]....)
tablespace tablespace_name [pctfree integer] [pctused integer]
[initrans integer] [maxtrans integer]sql> storage(initial 200k next 200k pctincrease 0 maxextents 50)
[logging|nologging] [cache|nocache]
2.copy an existing table
create table table_name [logging|nologging] as subquery
3.create temporary table
create global temporary table xay_temp as select * from xay；
on commit preserve rows/on commit delete rows
4.pctfree = (average row size - initial row size) *100 /average row size
pctused = 100-pctfree- (average row size*100/available data space)
5.change storage and block utilization parameter
alter table table_name pctfree=30 pctused=50 storage(next 500k minextents 2 maxextents 100);
6.manually allocating extents
alter table table_name allocate extent(size 500k datafile 'c:/oracle/data.dbf');
7.move tablespace
alter table employee move tablespace users;
8.deallocate of unused space
alter table table_name deallocate unused [keep integer]
9.truncate a table
truncate table table_name;
10.drop a table
drop table table_name [cascade constraints];
11.drop a column
alter table table_name drop column comments cascade constraints checkpoint 1000;
alter table table_name drop columns continue;
12.mark a column as unused
alter table table_name set unused column comments cascade constraints;
alter table table_name drop unused columns checkpoint 1000;
alter table orders drop columns continue checkpoint 1000；
data_dictionary : dba_unused_col_tabs
-索引
1.creating function-based indexes
create index summit.item_quantity on summit.item(quantity-quantity_shipped);
2.create a B-tree index
create [unique] index index_name on table_name(column,.. asc/desc) tablespace
tablespace_name [pctfree integer] [initrans integer] [maxtrans integer]
[logging | nologging] [nosort] storage(initial 200k next 200k pctincrease 0 maxextents 50);
3.pctfree(index)=(maximum number of rows-initial number of rows)*100/maximum number of rows
4.creating reverse key indexes
create unique index xay_id on xay(a) reverse pctfree 30 storage(initial 200k next 200k pctincrease 0 maxextents 50) tablespace indx;
5.create bitmap index
create bitmap index xay_id on xay(a) pctfree 30 storage( initial 200k next 200k pctincrease 0 maxextents 50) tablespace indx;
6.change storage parameter of index
alter index xay_id storage (next 400k maxextents 100);
7.allocating index space
alter index xay_id allocate extent(size 200k datafile 'c:/oracle/index.dbf');
alter index xay_id deallocate unused;
第五章：约束
1.define constraints as immediate or deferred
alter session set constraint[s] = immediate/deferred/default;
set constraint[s] constraint_name/all immediate/deferred;
2.drop constraints

drop table table_name cascade constraints
drop tablespace tablespace_name including contents cascade constraints
3. define constraints while create a table
    create table xay(id number(7) constraint xay_id primary key deferrable using index storage(initial 100k next 100k) tablespace indx)；
    primary key/unique/references table(column)/check；
    4.enable constraints
    alter table xay enable novalidate constraint xay_id;
    5.enable constraints
    alter table xay enable validate constraint xay_id;
    -LOAD数据
    1.loading data using direct_load insert
    insert /*+append */ into emp nologging select * from emp_old;
    2.parallel direct-load insert
    alter session enable parallel dml;
    insert /*+parallel(emp,2) */ into emp nologging select * from emp_old;
    3.using sql*loader
    sqlldr scott/tiger \
    control = ulcase6.ctl \
    log = ulcase6.log direct=true
    -reorganizing data
    1.using export
    exp scott/tiger tables(dept,emp) file=c:\emp.dmp log=exp.log compress=n direct=y
    2.using import
    imp scott/tiger tables(dept,emp) file=emp.dmp log=imp.log ignore=y
    3.transporting a tablespace
    salter tablespace sales_ts read only;
    exp sys/.. file=xay.dmp transport_tablespace=y tablespace=sales_ts triggers=n constraints=n
    copy datafile
    imp sys/.. file=xay.dmp transport_tablespace=y datafiles=(/disk1/sles01.dbf,/disk2/sles02.dbf)
    alter tablespace sales_ts read write;
    4.checking transport set
    DBMS_tts.transport_set_check(ts_list =>'sales_ts' ..,incl_constraints=>true);
    在表transport_set_violations 中查看dbms_tts.isselfcontained 为true 是，表示自包含
    -managing password security and resources
    1.controlling account lock and password
    alter user juncky identified by oracle account unlock;
    2.user_provided password function
    function_name(userid in varchar2(30),password in varchar2(30),old_password in varchar2(30)) return boolean
    3.create a profile : password setting
    create profile grace_5 limit failed_login_attempts 3
    password_lock_time unlimited password_life_time 30
    password_reuse_time 30 password_verify_function verify_function
    password_grace_time 5;
    4.altering a profile
    alter profile default limit failed_login_attempts 3 password_life_time 60;
    5.drop a profile
    drop profile grace_5 [cascade];
    6.create a profile : resource limit
    create profile developer_prof limit sessions_per_user 2 cpu_per_session 10000 idle_time 60 connect_time 480;
4. view => resource_cost : alter resource cost dba_Users,dba_profiles；
5. enable resource limits
    alter system set resource_limit=true;
    -Managing users
    1.create a user: database authentication
    create user juncky identified by oracle default tablespace users temporary tablespace temp quota 10m/unlimited on data password expire [account lock|unlock] [profile profilename|default];
    2.change user quota on tablespace
    alter user juncky quota 0 on users;
    3.drop a user
    drop user juncky [cascade];
6. monitor user
    view: dba_users , dba_ts_quotas
    -managing privileges
    1.system privileges: view => system_privilege_map ,dba_sys_privs,session_privs
    2.grant system privilege
    grant create session,create table to managers;
    grant create session to scott with admin option;
    with admin option can grant or revoke privilege from any user or role;
    3.sysdba and sysoper privileges:
    sysoper: startup,shutdown,alter database open|mount,alter database backup controlfile,alter tablespace begin/end backup,recover database,alter database archivelog,restricted session
    sysdba:sysoper privileges with admin option,create database,recover database until4.password file members: view:=> v$pwfile_users
    5.O7_dictionary_accessibility =true
    restriction access to view or tables in other schema
    6.revoke system privilege
    revoke create table from karen;
    revoke create session from scott;
    7.grant object privilege
    grant execute on dbms_pipe to public;
    grant update(first_name,salary) on employee to karen with grant option;
    8.display object privilege : view => dba_tab_privs, dba_col_privs
    9.revoke object privilege
    revoke execute on dbms_pipe from scott [cascade constraints];
    10.audit record view :=> sys.aud$
7. protecting the audit trail
   audit delete on sys.aud$ by access;
   12.statement auditing
   audit user;
   13.privilege auditing
   audit select any table by summit by access;
   14.schema object auditing
   audit lock on summit.employee by access whenever successful;
   15.view audit option : view=> all_def_audit_opts,dba_stmt_audit_opts,dba_priv_audit_opts,dba_obj_audit_opts
   16.view audit result: view=> dba_audit_trail,dba_audit_exists,dba_audit_object,dba_audit_session,dba_audit_statement
   -manager role
   1.create roles
   create role sales_clerk;
   create role hr_clerk identified by bonus;
   2.modify role
   alter role sales_clerk identified by commission;
   alter role hr_clerk identified externally;
   alter role hr_manager not identified;
   3.assigning roles
   grant sales_clerk to scott;
   grant hr_clerk to hr_manager;
   grant hr_manager to scott with admin option;
   4.establish default role
   alter user scott default role hr_clerk,sales_clerk;
   alter user scott default role all;
   alter user scott default role all except hr_clerk;
   alter user scott default role none;
   5.enable and disable roles
   set role hr_clerk;
   set role sales_clerk identified by commission;
   set role all except sales_clerk;
   set role none;
   6.remove role from user
   revoke sales_clerk from scott;
   revoke hr_manager from public;
   7.remove role
   drop role hr_manager;
   8.display role information
   view: =>dba_roles,dba_role_privs,role_role_privs,dba_sys_privs,role_sys_privs,role_tab_privs,session_roles
   -BACKUP and RECOVERY
8. v$sga,v$instance,v$process,v$bgprocess,v$database,v$datafile,v$sgastat
9. Rman need set dbwr_IO_slaves or backup_tape_IO_slaves and large_pool_size
10. Monitoring Parallel Rollback> v$fast_start_servers , v$fast_start_transactions
    4.perform a closed database backup (noarchivelog)
    shutdown immediate
    cp files /backup/
    startup
    5.restore to a different location
    connect system/manager as sysdba
    startup mount
    alter database rename file '/disk1/../user.dbf' to '/disk2/../user.dbf';
    alter database open;
    6.recover syntax
    --recover a mounted database
    recover database;
    recover datafile '/disk1/data/df2.dbf';
    alter database recover database;
    --recover an opened database
>recover tablespace user_data;
>recover datafile 2;
>alter database recover datafile 2;
>7.how to apply redo log files automatically
>set autorecovery on
>recover automatic datafile 4;
>8.complete recovery:
>--method 1(mounted databae)
>copy c:\backup\user.dbf c:\oradata\user.dbf
>startup mount
>recover datafile 'c:\oradata\user.dbf;
>alter database open;
>--method 2(opened database,initially opened,not system or rollback datafile)
>copy c:\backup\user.dbf c:\oradata\user.dbf (alter tablespace offline)
>recover datafile 'c:\oradata\user.dbf' or
>recover tablespace user_data;
>alter database datafile 'c:\oradata\user.dbf' online or
>alter tablespace user_data online;
>--method 3(opened database,initially closed not system or rollback datafile)
>startup mount
>alter database datafile 'c:\oradata\user.dbf' offline;
>alter database open
>copy c:\backup\user.dbf d:\oradata\user.dbf
>alter database rename file 'c:\oradata\user.dbf' to 'd:\oradata\user.dbf'
>recover datafile 'e:\oradata\user.dbf' or recover tablespace user_data;
>alter tablespace user_data online;
>--method 4(loss of data file with no backup and have all archive log)
>alter tablespace user_data offline immediate;
>alter database create datafile 'd:\oradata\user.dbf' as 'c:\oradata\user.dbf''
>recover tablespace user_data;
>alter tablespace user_data online；
>5.perform an open database backup
>alter tablespace user_data begin backup;
>copy files /backup/
>alter database datafile '/c:/../data.dbf' end backup;
>alter system switch logfile;
>6.backup a control file
>alter database backup controlfile to 'control1.bkp';
>alter database backup controlfile to trace;
>7.recovery (noarchivelog mode)
>shutdown abort
>cp files
>startup
>8.recovery of file in backup mode
>alter database datafile 2 end backup;
>9.clearing redo log file
>alter database clear unarchived logfile group 1;
>alter database clear unarchived logfile group 1 unrecoverable datafile;
>10.redo log recovery
>alter database add logfile group 3 'c:\oradata\redo03.log' size 1000k;
>alter database drop logfile group 1;
>alter database open;
>or
>cp c:\oradata\redo02.log' c:\oradata\redo01.log
>alter database clear logfile 'c:\oradata\log01.log';
>-dblink的建立
>1.在tnsnames.ora增加对备份数据库的指向，取名***（增加完毕后，用sqlplus进行验证）tnsping ***
>2.登录本地数据库
>3.CREATE DATABASE LINK *** CONNECT TO “目标用户名” IDENTIFIED BY “目标用户密码” USING '标识串';
>Create database link chsflora113 connect to flora indentified by kibflora2006 using ‘chsflora’；
>连接数据库chsflora，并创建连接名为chsflora113的dblink。
>1、查看各组内存大小
>select component,granule_size/1024/1024 from v$sga_dynamic_components;
>2、查看SGA
>select name,value/1024/1024 from v$sga;
>3、修改SGA
>alter system set sga_target=2g scope=spfile;
>数据库坏块
>select * from v$database_block_corruption;
>l         设置隔离级别
>l          设置一个事务的隔离级别
>l         SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
>l         SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
>l         SET TRANSACTION READ ONLY;
>l         设置增个会话的隔离级别
>l         ALTER SESSION SET ISOLATION_LEVEL SERIALIZABLE;
>l         ALTER SESSION SET ISOLATION_LEVEL READ COMMITTED;
>V$SYS_OPTIMIZER_ENV displays the contents of the optimizer environment for the instance
>V$SES_OPTIMIZER_ENV displays the contents of the optimizer environment for a particular session
>delete noprompt obsolete recovery window of 36 days
>delete  obsolete recovery window of 36 days
>find . -type f -ctime +36|xargs rm -f
>DELETE NOPROMPT ARCHIVELOG ALL BACKED UP 1 TIMES TO DISK COMPLETED BEFORE 'SYSDATE-5';
>delete noprompt backup of archivelog all completed before 'SYSDATE-36';
>#SQL语句的执行顺序
>1.常见的select、from、where的顺序
>1.from        2.where        3.select
>2.完整的select,from,where,group by,having,order by的顺序
>1.from        2.where        3.group by        4.having         5.select        6.order by
>sqlplus /nolog
>connect  conn
>show user
>clear screen
>spool
>edit
>set time on
>set timing on
>show error
>create user test identified by oracle default tablespace users temporary tablespace temp;
>select * from dba_sys_privs d where d.grantee='TEST';
>grant update(sal) on emp to test;
>-- 确定角色的权限
>select * from role_tab_privs ;  包含了授予角色的对象权限
>select * from role_role_privs ; 包含了授予另一角色的角色
>select * from role_sys_privs ;  包含了授予角色的系统权限
>-- 确定用户帐户所授予的权限
>select * from DBA_tab_privs ;   直接授予用户帐户的对象权限
>select * from DBA_role_privs ;  授予用户帐户的角色
>select * from DBA_sys_privs ;   授予用户帐户的系统权限
>-- 系统存在的角色
>select * from DBA_roles
>DBA_SYS_PRIVS:     查询某个用户所拥有的系统权限
>USER_SYS_PRIVS:    当前用户所拥有的系统权限
>SESSION_PRIVS:     当前用户所拥有的全部权限
>ROLE_SYS_PRIVS:    某个角色所拥有的系统权限
>ROLE_ROLE_PRIVS:   当前角色被赋予的角色
>SESSION_ROLES:     当前用户被激活的角色
>USER_ROLE_PRIVS:   当前用户被授予的角色
>另外还有针对表的访问权限的视图:
>TABLE_PRIVILEGES
>ALL_TAB_PRIVS
>ROLE_TAB_PRIVS:     某个角色被赋予的相关表的权限
>1、查看所有用户
>select * from dba_user;
>select * from all_users;
>select * from user_users;
>2、查看用户系统权限
>select * from dba_sys_privs;
>select * from all_sys_privs;
>select * from user_sys_privs;
>3、查看用户对象权限
>select * from dba_tab_privs;
>select * from all_tab_privs;
>select * from user_tab_privs;
>4、查看所有角色
>select * from dba_roles;
>5、查看用户所拥有的角色
>select * from dba_role_privs;
>select * from user_role_privs;
>6、查看当前用户的缺省表空间
>select username,default_tablespace from user_users;
>7、查看某个角色的具体权限
>SELECT * FROM DBA_SYS_PRIVS WHERE GRANTEE='RESOURCE';
>###过期的/不在支持的初始化参数
>select name from v$parameter where isdeprecated = 'TRUE' order by name;
>select name,ISSPECIFIED  from v$obsolete_parameter order by name;
>###初始化参数列表
>col name for a33
>col value for a60
>col ismodified for a5
>col description for a80 word_wrapped
>select name,value,ismodified,description from v$parameter order by name;
>###未公开的初始化参数列表
>set linesize 200
>column name format a50
>column value format a25
>col description format a40
>select x.ksppinm name,y.ksppstvl value,y.ksppstdf isdefault,x.ksppdesc description,
>decode(bitand(y.ksppstvf,7),1,'MODIFIED',4,'SYSTEM_MOD','FALSE') ismod,
>decode(bitand(y.ksppstvf,2),2,'TRUE','FALSE') isadj
>from
>sys.x$ksppi x,
>sys.x$ksppcv y
>where
>x.inst_id = userenv('Instance') and
>y.inst_id = userenv('Instance') and
>x.indx = y.indx and
>x.ksppinm LIKE '/_%' escape '/'
>order by
>translate(x.ksppinm, ' _', ' ');
>或
>col name for a15
>col value for a15
>col default for a15
>col default1 for a15
>col desc1 for a30
>select a.ksppinm name,b.ksppstvl value,b.ksppstdf default1,a.ksppdesc desc1 from x$ksppi a,x$ksppcv b where a.indx = b.indx
>and substr(ksppinm,1,1) = '_'
>order by ksppinm;
>设置一个列的回绕方式
>WRA[PPED]|WOR[D_WRAPPED]|TRU[NCATED]
>COL1
--------------------
HOW ARE YOU?

SQL>COL COL1 FORMAT A5
SQL>COL COL1 WRAPPED
COL1
-----
HOW A
RE YO
U?

SQL> COL COL1 WORD_WRAPPED
COL1
-----
HOW
ARE
YOU?
###GV$视图列表
select name from v$fixed_table where name like 'GV%' order by name;
###V$视图列表
select name from v$fixed_table where name like 'V%' order by name;
###创建v$视图的x$表的脚本
select 'View name: '||view_name,
substr(substr(view_definition,1,3900),1,(instr(view_definition,'from')-1)) def1,
substr(substr(view_definition,1,3900),(instr(view_definition,'from')))||';' def2
from v$fixed_view_definition
order by view_name;
###X$表列表
select name from v$fixed_table where name like 'X%' order by name;
###oracle进程内存占用
SELECT * FROM V$PROCESS_MEMORY;
###rman fulldb
run {
allocate channel c1 type disk;
allocate channel c2 type disk;
allocate channel c3 type disk;
backup incremental level 0 format '/home/oracle/rmanbak/orcl_full_%U' database;
backup format '/home/oracle/rmanbak/orcl_full_stanctf_%U' current controlfile for standby;
release channel c1;
release channel c2;
release channel c3;
}
###expdp fulldb

expdp sys/****** dumpfile=sdwsdj%U.dmp directory=DATA_PUMP_DIR schemas=sdwsdj parallel=2 logfile=expdp20171201.log
###procedure
scott@ORCL> create table test_table(col1 integer,col2 integer);
Table created.
scott@ORCL> create or replace procedure test_proc
2  as
3  begin
4  for x in (select col1,col2 from test_table)
5  loop
6  --process data
7  NULL;
8  END LOOP;
9  END;
10  /
Procedure created.
scott@ORCL> select object_name,status from user_objects where object_name = 'TEST_PROC';
OBJECT_NAME                                                                                                                      STATUS
-------------------------------------------------------------------------------------------------------------------------------- -------
TEST_PROC                                                                                                                        VALID
scott@ORCL> alter table test_table add col3 number;
Table altered.
scott@ORCL> select object_name,status from user_objects where object_name = 'TEST_PROC';
OBJECT_NAME                                                                                                                      STATUS
-------------------------------------------------------------------------------------------------------------------------------- -------
TEST_PROC                                                                                                                        VALID
scott@ORCL> alter table test_table modify col1 varchar2(20);
Table altered.
scott@ORCL> select object_name,status from user_objects where object_name = 'TEST_PROC';
OBJECT_NAME                                                                                                                      STATUS
-------------------------------------------------------------------------------------------------------------------------------- -------
TEST_PROC                                                                                                                        INVALID
scott@ORCL> execute test_proc
PL/SQL procedure successfully completed.
scott@ORCL> select object_name,status from user_objects where object_name = 'TEST_PROC';
OBJECT_NAME                                                                                                                      STATUS
-------------------------------------------------------------------------------------------------------------------------------- -------
TEST_PROC                                                                                                                        VALID
###dbms_metadata.get_ddl的用法:dbms_metadata包中的get_ddl函数
--GET_DDL: Return the metadata for a single object as DDL.
-- This interface is meant for casual browsing (e.g., from SQLPlus)
-- vs. the programmatic OPEN / FETCH / CLOSE interfaces above.
-- PARAMETERS:
-- object_type - The type of object to be retrieved.
-- name - Name of the object.
-- schema - Schema containing the object. Defaults to
-- the caller's schema.
-- version - The version of the objects' metadata.
-- model - The object model for the metadata.
-- transform. - XSL-T transform. to be applied.
-- RETURNS: Metadata for the object transformed to DDL as a CLOB.
FUNCTION get_ddl ( object_type IN VARCHAR2,
name IN VARCHAR2,
schema IN VARCHAR2 DEFAULT NULL,
version IN VARCHAR2 DEFAULT 'COMPATIBLE',
model IN VARCHAR2 DEFAULT 'ORACLE',
transform. IN VARCHAR2 DEFAULT 'DDL') RETURN CLOB;
####1.得到一个表或索引的ddl语句
SELECT DBMS_METADATA.GET_DDL('TABLE','DEPT','SCOTT') FROM DUAL;
select dbms_metadata.get_ddl('INDEX','PK_DEPT','SCOTT') from dual;
SELECT DBMS_METADATA.GET_DDL('TABLE',u.table_name) FROM USER_TABLES u;
####2.得到一个用户下的所有表，索引，存储过程的ddl
SELECT DBMS_METADATA.GET_DDL(U.OBJECT_TYPE, u.object_name) FROM USER_OBJECTS u where U.OBJECT_TYPE IN ('TABLE','INDEX','PROCEDURE');
select dbms_metadata.get_ddl('TRIGGER','DRLP_AIR_TRG','MICS_GZL6') from dual;
####3.得到所有表空间的ddl语句
EXECUTE DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'STORAGE',false);
SELECT DBMS_METADATA.GET_DDL('TABLESPACE', TS.tablespace_name) FROM DBA_TABLESPACES TS;
####4.得到所有创建用户的ddl
EXECUTE DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'STORAGE',false);
SELECT DBMS_METADATA.GET_DDL('USER',U.username) FROM DBA_USERS U;
9i 中可以利用DBMS_METADATA.GET_DDL包得到数据库的对象的ddl脚本。如下（SQLPLUS中执行）：
####a. 获取单个的建表、视图和建索引的语法
set pagesize 0
set long 90000
set feedback off
set echo off
spool DEPT.sql
select dbms_metadata.get_ddl('TABLE','TAB_NAME','SCOTT') from dual;
select dbms_metadata.get_ddl('VIEW','VIEW_NAME','SCOTT') from dual;
select dbms_metadata.get_ddl('INDEX','IDX_NAME','SCOTT') from dual;
spool off;
b.获取一个SCHEMA下的所有建表、视图和建索引的语法，以scott为例：
set pagesize 0
set long 90000
set feedback off
set echo off
spool schema.sql
connect scott/tiger;
SELECT DBMS_METADATA.GET_DDL('TABLE',u.table_name) FROM USER_TABLES u;
SELECT DBMS_METADATA.GET_DDL('VIEW',u.VIEW_name) FROM USER_VIEWS u;
SELECT DBMS_METADATA.GET_DDL('INDEX',u.index_name) FROM USER_INDEXES u;
spool off;
####c. 获取某个SCHEMA的建全部存储过程的语法
set pagesize 0
set long 90000
set feedback off
set echo off
spool procedures.sql
select DBMS_METADATA.GET_DDL('PROCEDURE',u.object_name) from user_objects u where object_type = 'PROCEDURE';
spool off;
####d. 获取某个SCHEMA的全部函数的DDL
set pagesize 0
set long 90000
set feedback off
set echo off
spool function.sql
select DBMS_METADATA.GET_DDL('FUNCTION',u.object_name) from user_objects u where object_type = 'FUNCTION';
spool off;
####e.获取某个SCHEMA的object DDL的语法
set pagesize 0
set long 90000
set feedback off
set echo off
set heading 999
set lines 100
select
dbms_metadata.GET_DDL(u.object_type,u.object_name,'PUBS')
from
dba_objects u
where
owner = 'PUBS';
###add constraint
alter table t6
add (constraint emp_emp_id_pk
primary key (employee_id)
,constraint emp_dept_fk
foreign key (department_id) references t7
,constraint emp_job_fk
foreign key (job_id) references t8
,constraint emp_manager_fk
foreign key (manager_id) references t6
);
###format time
alter session set nls_date_format='DD-MON-YYYY:HH24:MI:SS';
###rowid
scott@ORCL> select rowid,t.* from t3 t;
ROWID                     SNO
------------------ ----------
AAAWTdAAEAAAAGnAAA       1.23
AAAWTdAAEAAAAGnAAB       1.23
AAAWTdAAEAAAAGnAAC       1.24
###format model
hr@ORCL> select last_name employee,to_char(salary,'$99,990.99') from employees;
EMPLOYEE                  TO_CHAR(SAL
------------------------- -----------
OConnell                    $2,600.00
scott@ORCL> update t6 set hire_date = to_date('1998 05 20','YYYY MM DD') where last_name ='Hunold';
1 row updated.
###object table
CREATE TYPE HUMAN AS OBJECT(
NAME VARCHAR2(20),
SEX VARCHAR2(1),-- F : FEMALE M:MALE
BIRTHDAY DATE,
NOTE VARCHAR2(300)
)
SQL>SELECT * FROM USER_OBJECTS WHERE OBJECT_TYPE = 'TYPE';
OBJECT_NAM SUBOBJECT_  OBJECT_ID DATA_OBJECT_ID OBJECT_TYPE         CREATED   LAST_DDL_ TIMESTAMP           STATUS  T G S  NAMESPACE EDITION_NA
---------- ---------- ---------- -------------- ------------------- --------- --------- ------------------- ------- - - - ---------- ----------
HUMAN                      91568                TYPE                24-MAY-18 24-MAY-18 2018-05-24:14:45:01 VALID   N N N          1
SQL> CREATE TABLE STUDENTS(GUID NUMBER NOT NULL,STUDENTS HUMAN);
Table created.
###table compress
scott@ORCL> alter table scott.t6 compress for oltp;
Table altered.
create table sales (
prod_id number not null,
cust number not null,
time_id date not null)
pctfree 5 nologging nocompress
partition by range (time_id)
(partition sales_2008 values less than(to_date('2009-01-01','YYYY-MM-DD')) compress basic,
partition sales_2009 values less than(to_date('2010-01-01','YYYY-MM-DD')) compress for oltp);
###cluster table
CREATE CLUSTER personnel
(department NUMBER(4))
SIZE 512
STORAGE (initial 100K next 50K);
Cluster Keys: Example
The following statement creates the cluster index on the cluster key of personnel:
CREATE INDEX idx_personnel ON CLUSTER personnel;
After creating the cluster index, you can add tables to the index and perform DML operations on those tables.
Adding Tables to a Cluster: Example
The following statements create some departmental tables from the sample hr.employees table and add them to the personnel cluster created in the earlier example:
CREATE TABLE dept_10
CLUSTER personnel (department_id)
AS SELECT * FROM employees WHERE department_id = 10;
CREATE TABLE dept_20
CLUSTER personnel (department_id)
AS SELECT * FROM employees WHERE department_id = 20;
###rename table
scott@ORCL> alter table sales rename to sales_test;
Table altered.
###flush cache
ALTER SYSTEM FLUSH SHARED_POOL
ALTER SYSTEM FLUSH BUFFER_CACHE
ALTER SYSTEM FLUSH GLOBAL CONTEXT
###
galaxy@ORCL> select userenv('SESSIONID') from dual;
USERENV('SESSIONID')
--------------------
1634760
galaxy@ORCL> select userenv('TERMINAL') from dual;
USERENV('TERMINAL')
------------------------------
pts/1
galaxy@ORCL> select userenv('LANGUAGE') from dual;
USERENV('LANGUAGE')
----------------------------------------------------
AMERICAN_AMERICA.ZHS16GBK
galaxy@ORCL> select userenv('LANG') from dual;
USERENV('LANG')
----------------------------------------------------
US
galaxy@ORCL> select userenv('ISDBA') from dual;
USEREN
------
FALSE
galaxy@ORCL> select userenv('ENTRYID') from dual;
USERENV('ENTRYID')
------------------
1
galaxy@ORCL> select userenv('CLIENT_INFO') from dual;
USERENV('CLIENT_INFO')
----------------------------------------------------------------
###切换日志组
alter system switch logfile;
###删除中间过渡用的日志组4
alter database drop logfile group 4;
###备份当前的最新的控制文件
alter database backupcontrolfile to trace resetlogs;
###dklink测试
select 1 from dual@dblink；
###impdp
impdp sys/****** dumpfile=0620.DMP directory=DATA_PUMP_DIR schemas=sst parallel=2 logfile=impdp20180622.log
###GET_DDL
SELECT DBMS_METADATA.GET_DDL('SST','GAS_STATION_UNLOAD_DENSITY') FROM DUAL;
###编译无效对象
@?/rdbms/admin/utlrp.sql
###升级数据字典
@?/rdbms/admin/catbundle.sql psu apply
###jvm psu升级
@/tmp/highgo20180626/27475598/postinstall.sql
###windows oracle创建、删除服务
用oradim命令创建oracle服务，关于oradim命令的部分参数解释如下：
1-NEW表明我们要创建一个新的实例
2-SID指定要创建的实例名
3-SRVCservice_name指定创建的oracle服务名
4-STARTMODEauto|manual表明启动oracle服务时是否自动启动实例，默认为manual即手动
5-SRVCSTARTsystem|demand默认是demand，system指当系统重启时服务自动启动，demand表示需要用户手动启动服务，不明确指定该参数时，默认为-SRVCSTARTdemand
6-SPFILE表示当startup数据库时使用spfile参数
oradim.exe -delete -SID HISSERVER
oradim.exe -new -sid HISSERVER -startmode manual -srvcstart system -spfile
###查看字段,数据类型长度
galaxy@ORCL> create table a(a date,b timestamp);
Table created.
galaxy@ORCL> insert into a values(sysdate,systimestamp);
1 row created.
galaxy@ORCL> select * from a;
A         B
--------- ----------------------------
13-JUL-18 13-JUL-18 08.39.26.281075 AM
galaxy@ORCL> insert into a values(to_date('2017-01-01','yyyy-mm-dd'), to_date('2017-01-01','yyyy-mm-dd'));
1 row created.
galaxy@ORCL> select * from a;
A         B
--------- -----------------------------
13-JUL-18 13-JUL-18 08.39.26.281075 AM
01-JAN-17 01-JAN-17 12.00.00.000000 AM
galaxy@ORCL> commit;
Commit complete.
galaxy@ORCL> col TABLE_NAME for a10
galaxy@ORCL> col DATA_TYPE for a15
galaxy@ORCL> select table_name,column_name,data_type,data_length from user_tab_cols where table_name='A';
TABLE_NAME COLUMN_NAME  DATA_TYPE       DATA_LENGTH
---------- ------------ --------------- -----------
A          A            DATE                             7
A          B            TIMESTAMP(6)             11
galaxy@ORCL> select a,dump(a) from a;
A                 DUMP(A)
---------      -----------
13-JUL-18   Typ=12 Len=7: 120,118,7,13,9,40,27
01-JAN-17  Typ=12 Len=7: 120,117,1,1,1,1,1
galaxy@ORCL> select b,dump(b) from a;
B                                                     DUMP(B)
-------------------------------          -----------
13-JUL-18 08.39.26.281075 AM    Typ=180 Len=11: 120,118,7,13,9,40,27,16,192,221,56
01-JAN-17 12.00.00.000000 AM    Typ=180 Len=7: 120,117,1,1,1,1,1
galaxy@ORCL> select a,vsize(a) from a;
A                      VSIZE(A)
---------          ----------
13-JUL-18           7
01-JAN-17          7
galaxy@ORCL> select b,vsize(b) from a;
B                                                      VSIZE(B)
--------------------------------        ----------
13-JUL-18 08.39.26.281075 AM             11
01-JAN-17 12.00.00.000000 AM              7
galaxy@ORCL> select dump(sysdate) from dual;
DUMP(SYSDATE)
---------------
Typ=13 Len=8: 226,7,7,13,8,44,25,0

galaxy@ORCL> select vsize(sysdate) from dual;
VSIZE(SYSDATE)
--------------
7
```

##### RMAN后台还原

```
$ nohup rman cmdfile=restore.txt log=restore20181213_1.log &

$ cat restore.txt
connect target /
run {
allocate channel d1 type disk;
allocate channel d2 type disk;
allocate channel d3 type disk;
restore database;
release channel d1;
release channel d2;
release channel d3;
}
```

