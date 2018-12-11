# How to Identify Hard Parse Failures Such as Error=923 (文档 ID 1353015.1)

|

|

  

## Applies to:

Oracle Database - Enterprise Edition - Version 10.2.0.2 and later  
Information in this document applies to any platform.  

## Goal

Hard parse time may be impacted when there are a high number of parse errors.  
  
This may be noted in the ADDM report as follows:  
  

FINDING 2: 62% impact (2561 seconds)  
\------------------------------------  
Hard parsing SQL statements that encountered parse errors was consuming  
significant database time.  
  
RECOMMENDATION 1: Application Analysis, 62% benefit (2561 seconds)  
ACTION: Investigate application logic to eliminate parse errors.

In the AWR report Parse Failures are recorded in two places:

**1\. Time Model Statistics**

**2\. Instance Activity Stats**

......

  
  
  
  

## Solution

Failed parses are not stored in the data dictionary and therefore cannot be
identified through querying the data dictionary.  
  
As of Oracle10g, event 10035 can be set to report SQLs that fail during PARSE
operations.  
  
 **Syntax:**  
  

ALTER SYSTEM SET EVENTS '10035 trace name context forever, level 1';  
ALTER SESSION SET EVENTS '10035 trace name context forever, level 1';  
EVENT="10035 trace name context forever, level 1"  
  
Levels:  
level 1+ Print out failed parses of SQL statements to  
  
Note:  
The event can be turned off as follows:  
  
ALTER SYSTEM SET EVENTS '10035 trace name context off';  
ALTER SESSION SET EVENTS '10035 trace name context off';

When the event is set,any statement that fails to parse as a result of an
error, will be documented in the alert.log, together with the error number and
the process OSPID as displayed below

PARSE ERROR: ospid=11268, error=904 for statement:  
Mon Aug 29 09:48:24 2011  
select empid from emp  
  
PARSE ERROR: ospid=1776, error=936 for statement:  
Mon Aug 29 09:21:30 2011  
select * from emp where empno =  
  
PARSE ERROR: ospid=10220, error=942 for statement:  
Mon Aug 29 09:49:03 2011  
select * from emp_new

    
    
    Parse errors are syntax error and needs to be verified from application team.
    
    High CPU and Library Cache Contention

A high number of invalid (syntactically incorrect) SQL can result in high CPU
and library cache contention. Ideally, the solution is to fix the application
to issue valid SQL.  
However, as a temporary workaround, it is possible to set
_cursor_features_enabled in order to ease the effect of the incorrect parsing.  
When set the parse error is recorded in a table SQLERROR$ which is checked so
that repeated attempts to parse syntactically or semantically invalid
statements will not continually incur the full costs associated with hard
parsing.  
  
In order to enable this workaround,add 32 to the current value of
_cursor_features_enabled.  
  
For Example:  
  
The default value of _cursor_features_enabled = 2.  
In order to enable the fix set _cursor_features_enabled to 2 + 32.

_cursor_features_enabled is not dynamic and requires a restart:  
  
SQL> show parameter _cursor_features_enabled  
  
NAME TYPE VALUE  
\------------------------------------ -----------
------------------------------  
_cursor_features_enabled integer 32  
  
SQL> alter system set "_cursor_features_enabled" = 34 scope=spfile;  
  
System altered.

After restarting the database certain (not all) parse errors for non-SYS users
will be recorded in sqlerror$.  
  
The following notes include information on the necessary fixes to enable this
feature. These fixes are included in 112.0.4 and 12.1.0.1

[Document
8508078.8](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1353015.1&id=8508078.8)
Bug 8508078 - Contention from many concurrent bad SQLs - superseded  
[Document
14584323.8](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1353015.1&id=14584323.8)
Bug 14584323 - ORA-1775 may be reported masking some other error

### Failed Parse Time and ORA-4025

If a cursor reaches the max threshold for active locks, it can generate lots
of ORA-4025 errors and failed parse time will increment very quickly.

See:

[Document:17242746.8](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1353015.1&id=17242746.8)
ORA-4025 ON RECURSIVE SQL FROM PLSQL

**NOTE:** In 12.2 there is a Diagnostic enhancement that will give an early
warning in the alert.log without event 10035 being set. By default the
diagnostic will dump the parse error along with warning in the alert log every
100 parse errors for a given SQL within a 60 minutes period.

[Document
16945190.8](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1353015.1&id=16945190.8)
Bug 16945190 - Diagnostic enhancement to dump parse failure information
automatically

  
  
  
  
---


---
### ATTACHMENTS
[0938195be0c369ad99578e4e027b53ef]: media/How_to_Identify_Hard_Parse_Failures_Such_as_Error923_文档_ID_1353015-4.1)
[How_to_Identify_Hard_Parse_Failures_Such_as_Error923_文档_ID_1353015-4.1)](media/How_to_Identify_Hard_Parse_Failures_Such_as_Error923_文档_ID_1353015-4.1))
[d1f97ab54fde8381b7caacb2d68a66db]: media/How_to_Identify_Hard_Parse_Failures_Such_as_Error923_文档_ID_1353015-5.1)
[How_to_Identify_Hard_Parse_Failures_Such_as_Error923_文档_ID_1353015-5.1)](media/How_to_Identify_Hard_Parse_Failures_Such_as_Error923_文档_ID_1353015-5.1))
[d4c445972f5ab4e70731e9dae46137b9]: media/How_to_Identify_Hard_Parse_Failures_Such_as_Error923_文档_ID_1353015-6.1)
[How_to_Identify_Hard_Parse_Failures_Such_as_Error923_文档_ID_1353015-6.1)](media/How_to_Identify_Hard_Parse_Failures_Such_as_Error923_文档_ID_1353015-6.1))
---
### NOTE ATTRIBUTES
>Created Date: 2018-08-23 10:31:49  
>Last Evernote Update Date: 2018-10-01 15:55:03  
>source: web.clip7  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=454245837074682  
>source-url: &  
>source-url: parent=DOCUMENT  
>source-url: &  
>source-url: sourceId=1349387.1  
>source-url: &  
>source-url: id=1353015.1  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=qxbehgcvh_126  
>source-application: WebClipper 7  