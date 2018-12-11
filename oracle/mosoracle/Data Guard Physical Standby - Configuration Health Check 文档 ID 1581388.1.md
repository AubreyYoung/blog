# Data Guard Physical Standby - Configuration Health Check (文档 ID 1581388.1)

  

|

|

 **In this Document**  

| | [Main
Content](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=264814452230526&id=1581388.1&_afrWindowMode=0&_adf.ctrl-
state=ecpc8bcy2_112#MAINCONTENT)  
---|---  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=264814452230526&id=1581388.1&_afrWindowMode=0&_adf.ctrl-
state=ecpc8bcy2_112#REF)  
---|---  
  
* * *

## Applies to:

Oracle Database - Enterprise Edition - Version 11.2.0.1 to 12.1.0.1 [Release
11.2 to 12.1]  
Information in this document applies to any platform.  

## Main Content

The following scripts can be used to monitor the configuration and health of
Data Guard Physical Standby configuration. The purpose of these scripts is to
determine the current configuration and state of both the Primary and Standby
sites for the purpose of troubleshooting a potential problem.

The scripts have been tested and confirmed to be working in 11.2.0.x and
12.1.0.x databases.

_This sample code is provided for educational purposes only and not supported
by Oracle Support Services. It has been tested internally, however, and works
as documented. We do not guarantee that it will work for you, so be sure to
test it in your environment before relying on it._

_Proofread this sample code before using it! Due to the differences in the way
text editors, e-mail packages and operating systems handle text formatting
(spaces, tabs and carriage returns), this sample code may not be in an
executable state when you first receive it. Check over the sample code to
ensure that errors of this type are corrected._

**Primary Site Script**

===============================================================================

\-- This script is to be run on the Primary of a Data Guard Physical Standby
Site  
  
set echo off  
set feedback off  
column timecol new_value tstamp  
column spool_extension new_value suffix  
select to_char(sysdate,'Mondd_hhmi') timecol from sys.dual;  
column output new_value dbname  
select value || '_' output from v$parameter where name = 'db_name';  
  
\-- Output the results to this file  
  
spool dg_Primary_diag_&&dbname&&tstamp  
set lines 132  
set pagesize 500  
set numformat 999999999999999  
set trim on  
set trims on  
  
\-- Get the current Date  
  
alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';  
set feedback on  
select systimestamp from dual;  
  
\-- Primary Site Details  
set heading off  
set feedback off  
select 'Primary Site Details' from dual;  
select '********************' from dual;  
set heading on  
set feedback on  
  
col db_unique_name format a15  
col flashb_on format a10  
  
select DB_UNIQUE_NAME,DATABASE_ROLE DB_ROLE,FORCE_LOGGING F_LOG,FLASHBACK_ON
FLASHB_ON,LOG_MODE,OPEN_MODE,  
GUARD_STATUS GUARD,PROTECTION_MODE PROT_MODE  
from v$database;  
  
\-- Current SCN - this value on the primary and standby sites where real time
apply is in place should be nearly the same  
  
set heading off  
set feedback off  
select 'Primary Site last generated SCN' from dual;  
select '*******************************' from dual;  
set heading on  
set feedback on  
  
select DB_UNIQUE_NAME,SWITCHOVER_STATUS,CURRENT_SCN from v$database;  
  
set heading off  
set feedback off  
select 'Standby Site last applied SCN' from dual;  
select '*****************************' from dual;  
set heading on  
set feedback on  
  
select DEST_ID, APPLIED_SCN FROM v$archive_dest WHERE TARGET='STANDBY';  
  
  
\-- Incarnation Information  
\--  
  
set heading off  
set feedback off  
select 'Incarnation Destination Configuration' from dual;  
select '*************************************' from dual;  
set heading on  
set feedback on  
  
select INCARNATION# INC#, RESETLOGS_CHANGE# RS_CHANGE#, RESETLOGS_TIME,
PRIOR_RESETLOGS_CHANGE# PRIOR_RS_CHANGE#, STATUS,FLASHBACK_DATABASE_ALLOWED
FB_OK from v$database_incarnation;  
  
\-- Archivelog Destination Details  
\--  
  
set heading off  
set feedback off  
select 'Archive Destination Configuration' from dual;  
select '*********************************' from dual;  
set heading on  
set feedback on  
  
\-- Current Archive Locations  
\--  
  
column host_name format a30 tru  
column version format a10 tru  
select INSTANCE_NAME,HOST_NAME,VERSION,ARCHIVER from v$instance;  
  
column destination format a35 wrap  
column process format a7  
column archiver format a8  
column dest_id format 99999999  
  
select
DEST_ID,DESTINATION,STATUS,TARGET,ARCHIVER,PROCESS,REGISTER,TRANSMIT_MODE  
from v$archive_dest  
where DESTINATION IS NOT NULL;  
  
column name format a22  
column value format a100  
select NAME,VALUE from v$parameter where NAME like 'log_archive_dest%' and
upper(VALUE) like 'SERVICE%';  
  
set heading off  
set feedback off  
select 'Archive Destination Errors' from dual;  
select '**************************' from dual;  
set heading on  
set feedback on  
  
column error format a55 tru  
select DEST_ID,STATUS,ERROR from v$archive_dest  
where DESTINATION IS NOT NULL;  
  
column message format a80  
select MESSAGE, TIMESTAMP  
from v$dataguard_status  
where SEVERITY in ('Error','Fatal')  
order by TIMESTAMP;  
  
\-- Redo Log configuration  
\-- The size of the standby redo logs must match exactly the size on the
online redo logs  
  
set heading off  
set feedback off  
select 'Data Guard Redo Log Configuration' from dual;  
select '*********************************' from dual;  
set heading on  
set feedback on  
  
select GROUP# STANDBY_GROUP#,THREAD#,SEQUENCE#,BYTES,USED,ARCHIVED,STATUS from
v$standby_log order by GROUP#,THREAD#;  
  
select GROUP# ONLINE_GROUP#,THREAD#,SEQUENCE#,BYTES,ARCHIVED,STATUS from v$log
order by GROUP#,THREAD#;  
  
\-- Data Guard Parameters  
\--  
set heading off  
set feedback off  
select 'Data Guard Related Parameters' from dual;  
select '*****************************' from dual;  
set heading on  
set feedback on  
  
column name format a30  
column value format a100  
select NAME,VALUE from v$parameter where NAME IN
('db_unique_name','cluster_database','dg_broker_start','dg_broker_config_file1','dg_broker_config_file2','fal_client','fal_server','log_archive_config','log_archive_trace','log_archive_max_processes','archive_lag_target','remote_login_password_file','redo_transport_user')
order by name;  
  
  
\-- Redo Shipping Progress  
  
set heading off  
set feedback off  
select 'Data Guard Redo Shipping Progress' from dual;  
select '*********************************' from dual;  
set heading on  
set feedback on  
  
select systimestamp from dual;  
  
column client_pid format a10  
select
PROCESS,STATUS,CLIENT_PROCESS,CLIENT_PID,THREAD#,SEQUENCE#,BLOCK#,ACTIVE_AGENTS,KNOWN_AGENTS  
from v$managed_standby order by CLIENT_PROCESS,THREAD#,SEQUENCE#;  
  
host sleep 10  
  
select systimestamp from dual;  
  
select
PROCESS,STATUS,CLIENT_PROCESS,CLIENT_PID,THREAD#,SEQUENCE#,BLOCK#,ACTIVE_AGENTS,KNOWN_AGENTS  
from v$managed_standby order by CLIENT_PROCESS,THREAD#,SEQUENCE#;  
  
host sleep 10  
  
select systimestamp from dual;  
  
select
PROCESS,STATUS,CLIENT_PROCESS,CLIENT_PID,THREAD#,SEQUENCE#,BLOCK#,ACTIVE_AGENTS,KNOWN_AGENTS  
from v$managed_standby order by CLIENT_PROCESS,THREAD#,SEQUENCE#;  
  
  
set heading off  
set feedback off  
select 'Data Guard Errors in the Last Hour' from dual;  
select '**********************************' from dual;  
set heading on  
set feedback on  
  
select TIMESTAMP,SEVERITY,ERROR_CODE,MESSAGE from v$dataguard_status where
timestamp > systimestamp-1/24;  
spool off

================================================================================

**Standby Site Script**

================================================================================

\-- This script is to be run on the Standby of a Data Guard Physical Standby
Site  
  
set echo off  
set feedback off  
column timecol new_value tstamp  
column spool_extension new_value suffix  
select to_char(sysdate,'Mondd_hhmi') timecol from sys.dual;  
column output new_value dbname  
select value || '_' output from v$parameter where name = 'db_name';  
  
\-- Output the results to this file  
  
spool dg_Standby_diag_&&dbname&&tstamp  
set lines 132  
set pagesize 500  
set numformat 999999999999999  
set trim on  
set trims on  
  
\-- Get the current Date  
  
set feedback on  
select systimestamp from dual;  
  
\-- Standby Site Details  
set heading off  
set feedback off  
select 'Standby Site Details' from dual;  
select '********************' from dual;  
set heading on  
set feedback on  
  
col db_unique_name format a15  
col flashb_on format a10  
  
select DB_UNIQUE_NAME,DATABASE_ROLE DB_ROLE,FORCE_LOGGING F_LOG,FLASHBACK_ON
FLASHB_ON,LOG_MODE,OPEN_MODE,  
GUARD_STATUS GUARD,PROTECTION_MODE PROT_MODE  
from v$database;  
  
\-- Current SCN - this value on the primary and standby sites where real time
apply is in place should be nearly the same  
  
select DB_UNIQUE_NAME,SWITCHOVER_STATUS,CURRENT_SCN from v$database;  
  
\-- Incarnation Information  
\--  
  
set heading off  
set feedback off  
select 'Incarnation Destination Configuration' from dual;  
select '*************************************' from dual;  
set heading on  
set feedback on  
  
select INCARNATION# INC#, RESETLOGS_CHANGE# RS_CHANGE#, RESETLOGS_TIME,
PRIOR_RESETLOGS_CHANGE# PRIOR_RS_CHANGE#, STATUS,FLASHBACK_DATABASE_ALLOWED
FB_OK from v$database_incarnation;  
  
  
set heading off  
set feedback off  
select 'Archive Destination Configuration' from dual;  
select '*********************************' from dual;  
set heading on  
set feedback on  
\-- Current Archive Locations  
\--  
  
column host_name format a30 tru  
column version format a10 tru  
select INSTANCE_NAME,HOST_NAME,VERSION,ARCHIVER from v$instance;  
  
column destination format a35 wrap  
column process format a7  
column archiver format a8  
column dest_id format 99999999  
  
select
DEST_ID,DESTINATION,STATUS,TARGET,ARCHIVER,PROCESS,REGISTER,TRANSMIT_MODE  
from v$archive_dest  
where DESTINATION IS NOT NULL;  
  
column name format a22  
column value format a100  
select NAME,VALUE from v$parameter where NAME like 'log_archive_dest%' and
upper(VALUE) like 'SERVICE%';  
  
set heading off  
set feedback off  
select 'Archive Destination Errors' from dual;  
select '**************************' from dual;  
set heading on  
set feedback on  
  
column error format a55 tru  
select DEST_ID,STATUS,ERROR from v$archive_dest  
where DESTINATION IS NOT NULL;  
  
column message format a80  
select MESSAGE, TIMESTAMP  
from v$dataguard_status  
where SEVERITY in ('Error','Fatal')  
order by TIMESTAMP;  
  
\-- Redo Log configuration  
\-- The size of the standby redo logs must match exactly the size on the
online redo logs  
  
set heading off  
set feedback off  
select 'Data Guard Redo Log Configuration' from dual;  
select '*********************************' from dual;  
set heading on  
set feedback on  
  
select GROUP# STANDBY_GROUP#,THREAD#,SEQUENCE#,BYTES,USED,ARCHIVED,STATUS from
v$standby_log order by GROUP#,THREAD#;  
  
select GROUP# ONLINE_GROUP#,THREAD#,SEQUENCE#,BYTES,ARCHIVED,STATUS from v$log
order by GROUP#,THREAD#;  
  
\-- Data Guard Parameters  
\--  
set heading off  
set feedback off  
select 'Data Guard Related Parameters' from dual;  
select '*****************************' from dual;  
set heading on  
set feedback on  
  
column name format a30  
column value format a100  
select NAME,VALUE from v$parameter where NAME IN
('db_unique_name','cluster_database','dg_broker_start','dg_broker_config_file1','dg_broker_config_file2','fal_client','fal_server','log_archive_config','log_archive_trace','log_archive_max_processes','archive_lag_target','remote_login_password_file','redo_transport_user')
order by name;  
  
\-- Managed Recovery State  
  
set heading off  
set feedback off  
select 'Data Guard Apply Status' from dual;  
select '***********************' from dual;  
set heading on  
set feedback on  
  
select systimestamp from dual;  
  
column client_pid format a10  
select
PROCESS,STATUS,CLIENT_PROCESS,CLIENT_PID,THREAD#,SEQUENCE#,BLOCK#,ACTIVE_AGENTS,KNOWN_AGENTS  
from v$managed_standby order by CLIENT_PROCESS,THREAD#,SEQUENCE#;  
  
host sleep 10  
  
select systimestamp from dual;  
  
select
PROCESS,STATUS,CLIENT_PROCESS,CLIENT_PID,THREAD#,SEQUENCE#,BLOCK#,ACTIVE_AGENTS,KNOWN_AGENTS  
from v$managed_standby order by CLIENT_PROCESS,THREAD#,SEQUENCE#;  
  
host sleep 10  
  
select systimestamp from dual;  
  
select
PROCESS,STATUS,CLIENT_PROCESS,CLIENT_PID,THREAD#,SEQUENCE#,BLOCK#,ACTIVE_AGENTS,KNOWN_AGENTS  
from v$managed_standby order by CLIENT_PROCESS,THREAD#,SEQUENCE#;  
  
  
set heading off  
set feedback off  
select 'Data Guard Apply Lag' from dual;  
select '********************' from dual;  
set heading on  
set feedback on  
  
column name format a12  
column lag_time format a20  
column datum_time format a20  
column time_computed format a20  
SELECT NAME, VALUE LAG_TIME, DATUM_TIME, TIME_COMPUTED  
from V$DATAGUARD_STATS where name like 'apply lag';  
  
\-- If there is a lag remove the comment for the select below  
\--SELECT * FROM V$STANDBY_EVENT_HISTOGRAM WHERE NAME = 'apply lag' AND COUNT
> 0;  
  
set heading off  
set feedback off  
select 'Data Guard Gap Problems' from dual;  
select '***********************' from dual;  
set heading on  
set feedback on  
  
select * from v$archive_gap;  
  
set heading off  
set feedback off  
select 'Data Guard Errors in the Last Hour' from dual;  
select '**********************************' from dual;  
set heading on  
set feedback on  
  
select TIMESTAMP,SEVERITY,ERROR_CODE,MESSAGE from v$dataguard_status where
timestamp > systimestamp-1/24;  
spool off

============================================================================

  
**You can directly participate in the Discussion about this Note below. The
Frame is the interactive live Discussion - not a Screenshot ;-)**

[跳过导航](https://community.oracle.com/message/12128823#j-main)

  * [](http://www.oracle.com/)
  * [Oracle Community Directory](https://www.oracle.com/communities/index.html)
  * [Oracle Community FAQ](https://community.oracle.com/community/faq)

  * [ 0](https://community.oracle.com/inbox)[user12030720](https://community.oracle.com/message/12128823#)

[500 积分](https://community.oracle.com/message/12128823# "500 积分")

  *     * [Actions](https://community.oracle.com/actions)
    * [News](https://community.oracle.com/news)
    * [Inbox](https://community.oracle.com/inbox)
    * 

[My Oracle Support Community
(MOSC)](https://community.oracle.com/community/support)

[](https://twitter.com/myoraclesupport)

  * 搜索[ __](https://community.oracle.com/message/12128823#)

  * [ 创建](https://community.oracle.com/message/12128823#)

[Go Directly To ](https://community.oracle.com/message/12128823#)

[High Availability Data Guard
(MOSC)](https://community.oracle.com/community/support/oracle_database/high_availability_data_guard)中的[更多讨论](https://community.oracle.com/community/support/oracle_database/high_availability_data_guard/content?filterID=contentstatus\[published\]~objecttype~objecttype\[thread\])
[](https://community.oracle.com/message/12128823# "此位置位于何处？")

**6 回复** [由 Paulb-Oracle 于 2014-4-26 上午8:10
最新回复](https://community.oracle.com/message/12399710?tstart=0#12399710) [ 
](https://community.oracle.com/community/feeds/messages?thread=3405477 "RSS")

#  [Discussion : Data Guard Physical Standby Health Check
Scripts](https://community.oracle.com/message/12128823#12128823)

此问题 **已回答** 。

[ ](https://community.oracle.com/people/Paulb-Oracle)

**[Paulb-Oracle](https://community.oracle.com/people/Paulb-Oracle)**
2013-10-13 下午11:19

Hi All  
A new note containing some downloadable scripts that will allow you to monitor
the health and progress of recovery in you physical standby databases.  
  
  
Data Guard Physical Standby - Configuration Health Check ([Doc ID
1581388.1](https://support.oracle.com/rs?type=doc&id=1581388.1))  
  
  
  
regards  
  
Paul  

[](https://community.oracle.com/people/Paulb-Oracle "Paulb-Oracle")

**正确答案** 作者： [Paulb-Oracle](https://community.oracle.com/people/Paulb-Oracle)
在 2014-4-26 上午8:10

'

HI

if the standby is open read only These errors will not occur. If it is mounted
only then these will appear. I think I may change the script to use an os
sleep instead to avoid any confusion that can result in mounted standbys.

Regards Paul.

**[查看上下文中的回答](https://community.oracle.com/message/12399710#12399710)**

  * 12024 查看 
  * 标签： 
  * ** 回复 **

平均用户评级: 无评分 (0 评级)

平均用户评级

无评分

(0 评级)

您的评级：

评级 差（1，最高值为 5）评级 中下（2，最高值为 5）评级 中等（3，最高值为 5）评级 中上（4，最高值为 5）评级 优（5，最高值为 5）

  * ######  **[1.](https://community.oracle.com/message/12280962#12280962 "回复链接 #1") [Re: Discussion : Data Guard Physical Standby Health Check Scripts](https://community.oracle.com/message/12280962#12280962) **

[ ](https://community.oracle.com/people/Thorstens-Oracle)

**[Thorstens-Oracle](https://community.oracle.com/people/Thorstens-Oracle) **
2014-2-25 上午9:44  （[回复 Paulb-
Oracle](https://community.oracle.com/message/12128823#12128823 "转至消息")）

Hi Paul !!

Thanks for raising this Discussion.

Thorsten

    * [喜爱](https://community.oracle.com/message/12128823# "喜爱") 显示 0 喜欢[(0)](https://community.oracle.com/message/12128823# "显示 0 喜欢")
    * ** 回复 **
    * [操作 ](https://community.oracle.com/message/12128823#)

  * ######  **[2.](https://community.oracle.com/message/12282390#12282390 "回复链接 #2") [Re: Discussion : Data Guard Physical Standby Health Check Scripts](https://community.oracle.com/message/12282390#12282390) **

[ ](https://community.oracle.com/people/Mikhail%20Velikikh)

**[Mikhail Velikikh](https://community.oracle.com/people/Mikhail%20Velikikh)
** 2014-2-26 上午3:03  （[回复 Paulb-
Oracle](https://community.oracle.com/message/12128823#12128823 "转至消息")）

Hi,

Primary/standby script contains mistake in parameters query:

select NAME,VALUE from v$parameter where NAME IN
('db_unique_name','cluster_database','dg_broker_start','dg_broker_config_file1','dg_broker_config_file2','fal_client','fal_server','log_archive_config','log_archive_trace','log_archive_max_processes','archive_lag_target','remote_log_password_file','redo_transport_user')
order by name;

  
remote_log_password_file should be remote_login_passwordfile.

Best regards,

Mikhail.

    * [喜爱](https://community.oracle.com/message/12128823# "喜爱") 显示 0 喜欢[(0)](https://community.oracle.com/message/12128823# "显示 0 喜欢")
    * ** 回复 **
    * [操作 ](https://community.oracle.com/message/12128823#)

  * ######  **[3.](https://community.oracle.com/message/12285049#12285049 "回复链接 #3") [Re: Discussion : Data Guard Physical Standby Health Check Scripts](https://community.oracle.com/message/12285049#12285049) **

[ ](https://community.oracle.com/people/Paulb-Oracle)

**[Paulb-Oracle](https://community.oracle.com/people/Paulb-Oracle) **
2014-2-26 下午8:54  （[回复 Mikhail
Velikikh](https://community.oracle.com/message/12282390#12282390 "转至消息")）

Thanks Mikhail

I will make the changes.

regards

Paul

    * [喜爱](https://community.oracle.com/message/12128823# "喜爱") 显示 0 喜欢[(0)](https://community.oracle.com/message/12128823# "显示 0 喜欢")
    * ** 回复 **
    * [操作 ](https://community.oracle.com/message/12128823#)

  * ######  **[4.](https://community.oracle.com/message/12399555#12399555 "回复链接 #4") [Re: Discussion : Data Guard Physical Standby Health Check Scripts](https://community.oracle.com/message/12399555#12399555) **

[ ](https://community.oracle.com/people/user7831087)

**[user7831087](https://community.oracle.com/people/user7831087) ** 2014-4-26
上午1:46  （[回复 Paulb-
Oracle](https://community.oracle.com/message/12128823#12128823 "转至消息")）

When I run the Standby Site Script I get the following error:

BEGIN DBMS_LOCK.SLEEP(10); END;

*

ERROR at line 1:

ORA-06550: line 1, column 7:

PLS-00201: identifier 'DBMS_LOCK.SLEEP' must be declared

ORA-06550: line 1, column 7:

PL/SQL: Statement ignored

Any clues? Primary script works fine.

    * [喜爱](https://community.oracle.com/message/12128823# "喜爱") 显示 0 喜欢[(0)](https://community.oracle.com/message/12128823# "显示 0 喜欢")
    * ** 回复 **
    * [操作 ](https://community.oracle.com/message/12128823#)

  * ######  **[5.](https://community.oracle.com/message/12399574#12399574 "回复链接 #5") [Re: Discussion : Data Guard Physical Standby Health Check Scripts](https://community.oracle.com/message/12399574#12399574) **

[ ](https://community.oracle.com/people/top.gun)

**[top.gun](https://community.oracle.com/people/top.gun) ** 2014-4-26 上午3:18
（[回复 user7831087](https://community.oracle.com/message/12399555#12399555
"转至消息")）

sql> grant execute on sys.dbms_lock to <user>;

    * [喜爱](https://community.oracle.com/message/12128823# "喜爱") 显示 0 喜欢[(0)](https://community.oracle.com/message/12128823# "显示 0 喜欢")
    * ** 回复 **
    * [操作 ](https://community.oracle.com/message/12128823#)

  * ###### 正确答案 **[6.](https://community.oracle.com/message/12399710#12399710 "回复链接 #6") [Re: Discussion : Data Guard Physical Standby Health Check Scripts](https://community.oracle.com/message/12399710#12399710) **

[ ](https://community.oracle.com/people/Paulb-Oracle)

**[Paulb-Oracle](https://community.oracle.com/people/Paulb-Oracle) **
2014-4-26 上午8:10  （[回复
user7831087](https://community.oracle.com/message/12399555#12399555 "转至消息")）

HI

if the standby is open read only These errors will not occur. If it is mounted
only then these will appear. I think I may change the script to use an os
sleep instead to avoid any confusion that can result in mounted standbys.

Regards Paul.

    * [喜爱](https://community.oracle.com/message/12128823# "喜爱") 显示 0 喜欢[(0)](https://community.oracle.com/message/12128823# "显示 0 喜欢")
    * ** 回复 **
    * [操作 ](https://community.oracle.com/message/12128823#)

[转至原始发贴](https://community.oracle.com/message/12128823#3405477) ** 回复原始发贴
**

  * [  关注 ](https://community.oracle.com/message/12128823#)
  * [书签](https://community.oracle.com/message/12128823#)显示 0 个书签[0](https://community.oracle.com/message/12128823# "显示 0 个书签")

  * [喜爱](https://community.oracle.com/message/12128823# "喜爱")显示 2 喜欢[2](https://community.oracle.com/message/12128823# "显示 2 喜欢")

#### 操作

  * [  举报滥用 ](https://community.oracle.com/message-abuse!input.jspa?objectID=3405477&objectType=1)
  * [  转换为文档 ](https://community.oracle.com/message/12128823#)
  * [  查看 PDF 版本 ](https://community.oracle.com/thread/3405477.pdf)

[My Oracle Support Community
(MOSC)](https://community.oracle.com/community/support)[MOS Support
Portal](https://support.oracle.com/)[About](http://www.oracle.com/us/support/mos-
community-ds-197359.pdf)

Powered by

## [Oracle Technology Network](https://community.oracle.com/docs/DOC-890454)

  * [Oracle Communities Directory](https://www.oracle.com/communities/index.html)
  * [FAQ](https://community.oracle.com/community/faq)

  * [About Oracle](http://www.oracle.com/us/corporate/index.html)
  * [Oracle and Sun](http://www.oracle.com/us/sun/index.html)
  * [RSS Feeds](http://www.oracle.com/us/syndication/feeds/index.html)
  * [Subscribe](http://www.oracle.com/us/syndication/subscribe/index.html)
  * [Careers](http://www.oracle.com/us/corporate/careers/index.html)
  * [Contact Us](http://www.oracle.com/us/corporate/contact/index.html)
  * [Site Maps](http://www.oracle.com/us/sitemaps/index.html)
  * [Legal Notices](http://www.oracle.com/us/legal/index.html)
  * [Terms of Use](http://www.oracle.com/us/legal/terms/index.html)
  * [Your Privacy Rights](http://www.oracle.com/us/legal/privacy/index.html)
  * Cookie Preferences

## References

  
  
  
  


---
### ATTACHMENTS
[0f0a83fb6ad8a6377550b09af55a5a5f]: media/level8.png-2.webp
[level8.png-2.webp](media/level8.png-2.webp)
>hash: 0f0a83fb6ad8a6377550b09af55a5a5f  
>source-url: http://www.oracle.com/webfolder/application/jive_engage/gamification/global/levels/level8.png  
>file-name: level8.png.webp  

[12b6ad2dde0d0acb04c64902bf60d372]: media/level2.png.webp
[level2.png.webp](media/level2.png.webp)
>hash: 12b6ad2dde0d0acb04c64902bf60d372  
>source-url: http://www.oracle.com/webfolder/application/jive_engage/gamification/global/levels/level2.png  
>file-name: level2.png.webp  

[33b30868ab1c085188053b3412cbf2a2]: media/Data_Guard_Physical_Standby_-_Configuration_Health_Check_文档_ID_1581388.1)
[Data_Guard_Physical_Standby_-_Configuration_Health_Check_文档_ID_1581388.1)](media/Data_Guard_Physical_Standby_-_Configuration_Health_Check_文档_ID_1581388.1))
[37fbf0ee81abc6239f319948c299d052]: media/Data_Guard_Physical_Standby_-_Configuration_Health_Check_文档_ID_1581388-2.1)
[Data_Guard_Physical_Standby_-_Configuration_Health_Check_文档_ID_1581388-2.1)](media/Data_Guard_Physical_Standby_-_Configuration_Health_Check_文档_ID_1581388-2.1))
[552645d727cf9cb1d13f32e0365bfb89]: media/Data_Guard_Physical_Standby_-_Configuration_Health_Check_文档_ID_1581388-3.1)
[Data_Guard_Physical_Standby_-_Configuration_Health_Check_文档_ID_1581388-3.1)](media/Data_Guard_Physical_Standby_-_Configuration_Health_Check_文档_ID_1581388-3.1))
[68e63bae19f4c02384a1cf73945320ed]: media/Data_Guard_Physical_Standby_-_Configuration_Health_Check_文档_ID_1581388-4.1)
[Data_Guard_Physical_Standby_-_Configuration_Health_Check_文档_ID_1581388-4.1)](media/Data_Guard_Physical_Standby_-_Configuration_Health_Check_文档_ID_1581388-4.1))
[7f8ec69e9260ecd88a0ba6cf55f55e68]: media/Data_Guard_Physical_Standby_-_Configuration_Health_Check_文档_ID_1581388-5.1)
[Data_Guard_Physical_Standby_-_Configuration_Health_Check_文档_ID_1581388-5.1)](media/Data_Guard_Physical_Standby_-_Configuration_Health_Check_文档_ID_1581388-5.1))
[b37c17a093427a0e71311e9ae368eaeb]: media/level7.png.webp
[level7.png.webp](media/level7.png.webp)
>hash: b37c17a093427a0e71311e9ae368eaeb  
>source-url: http://www.oracle.com/webfolder/application/jive_engage/gamification/global/levels/level7.png  
>file-name: level7.png.webp  

[cee0b54e37fa13e0f3f6cee8df602522]: media/level16.png.webp
[level16.png.webp](media/level16.png.webp)
>hash: cee0b54e37fa13e0f3f6cee8df602522  
>source-url: http://www.oracle.com/webfolder/application/jive_engage/gamification/global/levels/level16.png  
>file-name: level16.png.webp  

[e4a31404370f545de7ecef10d9aa59a3]: media/level1.png.webp
[level1.png.webp](media/level1.png.webp)
>hash: e4a31404370f545de7ecef10d9aa59a3  
>source-url: http://www.oracle.com/webfolder/application/jive_engage/gamification/global/levels/level1.png  
>file-name: level1.png.webp  

[fe5e340ecb4fdb955192a2c2d7245848]: media/Data_Guard_Physical_Standby_-_Configuration_Health_Check_文档_ID_1581388-6.1)
[Data_Guard_Physical_Standby_-_Configuration_Health_Check_文档_ID_1581388-6.1)](media/Data_Guard_Physical_Standby_-_Configuration_Health_Check_文档_ID_1581388-6.1))

---
### TAGS
{dataguard}

---
### NOTE ATTRIBUTES
>Created Date: 2017-06-20 06:05:17  
>Last Evernote Update Date: 2018-10-01 15:44:51  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=264814452230526  
>source-url: &  
>source-url: id=1581388.1  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=ecpc8bcy2_112  