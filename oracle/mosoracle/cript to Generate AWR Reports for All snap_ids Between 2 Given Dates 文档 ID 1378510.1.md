# cript to Generate AWR Reports for All snap_ids Between 2 Given Dates (文档 ID
1378510.1)



  

  

|

  

|

Oracle Database - Enterprise Edition - Version 10.1.0.2 to 11.2.0.3 [Release
10.1 to 11.2]

Information in this document applies to any platform.

  

In this Document

|

  

|
[Purpose](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=186993706266867&id=1378510.1&displayIndex=1&_afrWindowMode=0&_adf.ctrl-
state=ao3ra3izz_570#PURPOSE)  
---|---  
  
  

|
[Requirements](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=186993706266867&id=1378510.1&displayIndex=1&_afrWindowMode=0&_adf.ctrl-
state=ao3ra3izz_570#SWREQS)  
---|---  
  
  

|
[Configuring](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=186993706266867&id=1378510.1&displayIndex=1&_afrWindowMode=0&_adf.ctrl-
state=ao3ra3izz_570#CONFIG)  
---|---  
  
  

|
[Instructions](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=186993706266867&id=1378510.1&displayIndex=1&_afrWindowMode=0&_adf.ctrl-
state=ao3ra3izz_570#RUNSTEPS)  
---|---  
  
  

|
[Script](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=186993706266867&id=1378510.1&displayIndex=1&_afrWindowMode=0&_adf.ctrl-
state=ao3ra3izz_570#CODE)  
---|---  
  
  

| [Sample
Output](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=186993706266867&id=1378510.1&displayIndex=1&_afrWindowMode=0&_adf.ctrl-
state=ao3ra3izz_570#OUTPUT)  
---|---  
  
  

|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=186993706266867&id=1378510.1&displayIndex=1&_afrWindowMode=0&_adf.ctrl-
state=ao3ra3izz_570#REF)  
---|---  
  
  

* * *

  

This document is being delivered to you via Oracle Support's Rapid Visibility
(RaV) process and therefore has not been subject to an independent technical
review.  
---  
  
## Applies to:

## Purpose

This document outlines scipts that can be used to automatically generate all
AWR reports for snap_ids between 2 given dates.

## Requirements

RDBMS : 10g and above

Oracle Tuning Pack license.

## Configuring

PRIVILEGES

1\. Connect into SQL*Plus as SYSDBA or user with DBA privilege

## Instructions

EXECUTION

  1. Save the 2 scripts as "gen_batch.sql" and "pcreport.sql"
  2. Execute the script "gen_batch.sql" passing BEGIN_DATE and END_DATE.  
The date format is "DD-MON-YYYY HH24" so 9th May 2012 would need to be entered
as'09-MAY-2012 00'.  
This produces a new script called "batch.sql" which calls "pcreport.sql" once
for each snapshot id range within the specified date range.  
  

Make sure to use the right dates before an instance shutdown, as the following
error may surface:

'ORA-20200: Begin Snapshot Id 469 does not exist for this database/instance'

        3\. 'Execute "batch.sql"  to generate the AWR reports.

## Caution

This sample code is provided for educational purposes only, and is not
supported by Oracle Support. It has been tested internally, however, we do not
guarantee that it will work for you. Ensure that you run it in your test
environment before using.

## Script

gen_batch.sql

set echo off heading off feedback off verify off

select 'Please enter dates in DD-MON-YYYY HH24 format:' from dual;

select 'You have entered:', '&&BEGIN_DATE', '&&END_DATE' from dual;

set pages 0 termout off

spool batch.sql

SELECT DISTINCT '@pcreport '

                                ||b.snap_id

                                ||' '

                                ||e.snap_id

                                ||' '

                                || TO_CHAR(b.end_interval_time,'YYMMDD_HH24MI_')

                                ||TO_CHAR(e.end_interval_time,'HH24MI')

                                ||'.txt' Commands,

                '\-- '||TO_CHAR(b.end_interval_time,'YYMMDD_HH24MI') lineorder

FROM            dba_hist_snapshot b,

                dba_hist_snapshot e

WHERE           b.end_interval_time>=to_date('&BEGIN_DATE','DD-MON-YYYY HH24')

AND             b.end_interval_time<=to_date('&END_DATE','DD-MON-YYYY HH24')

AND             e.snap_id           =b.snap_id+1

ORDER BY        lineorder

/

spool off

set termout on

select 'Generating Report Script batch.sql.....' from dual;

select 'Report file created for snap_ids between:', '&&BEGIN_DATE',
'&&END_DATE', 'Check file batch.sql' from dual;

set echo on termout on verify on heading on feedback on



pcreport.sql

define num_days = 0;

define report_type = 'text'

column inst_num new_value inst_num

column dbname new_value dbname

column dbid new_value dbid

SELECT d.dbid            dbid     ,

       d.name            db_name  ,

       i.instance_number inst_num ,

       i.instance_name   inst_name

FROM   v$database d,

       v$instance i;

column begin_snap new_value begin_snap

column end_snap new_value end_snap

column report_name new_value report_name

SELECT &1 begin_snap

FROM   dual;

SELECT &2 end_snap

FROM   dual;

SELECT name

              ||'_'

              ||'&3' report_name

FROM   v$database;

@@?/rdbms/admin/awrrpti

## Sample Output



SQL> @gen_batch

SQL> set echo off heading off feedback off verify off

Please enter dates in DD-MON-YYYY HH24 format:

You have entered: 08-MAY-201200 09-MAY-201200

Generating Report Script batch.sql.....

Report file created for snap_ids between: 08-MAY-201200 09-MAY-201200 Check
file batch.sql

SQL>

SQL> set echo off heading off feedback off verify off pages 0 termout off

SQL> @batch

Instances in this Workload Repository schema

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

....

## References  
  
  
  
  
  
  
  
  

  



---
### TAGS
{AWR}

---
### NOTE ATTRIBUTES
>Created Date: 2017-12-25 08:44:45  
>Last Evernote Update Date: 2017-12-25 08:45:19  
>author: YangKwong  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=186993706266867  
>source-url: &  
>source-url: id=1378510.1  
>source-url: &  
>source-url: displayIndex=1  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=ao3ra3izz_570#CODE  