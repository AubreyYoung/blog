# Overview Steps of Upgrading Oracle Database with a Logical Standby Database
In Place (文档 ID 437276.1)

|

|

**In this Document**  

| |
[Goal](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=267941332913471&id=437276.1&_afrWindowMode=0&_adf.ctrl-
state=152hqe0oee_192#GOAL)  
---|---  
|
[Solution](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=267941332913471&id=437276.1&_afrWindowMode=0&_adf.ctrl-
state=152hqe0oee_192#FIX)  
---|---  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=267941332913471&id=437276.1&_afrWindowMode=0&_adf.ctrl-
state=152hqe0oee_192#REF)  
---|---  
  
* * *

## Applies to:

Oracle Database - Enterprise Edition - Version 10.1.0.3 to 11.2.0.3 [Release
10.1 to 11.2]  
Information in this document applies to any platform.  
***Checked for relevance on 18-Sep-2013***  
*** Reviewed for Relevance 16-Jul-2015 ***  
The instructions within this document are supported for the following upgrade
scenarios:  
  
10.1.0.3 => 10.x.x.x  
10.x.x.x => 11.x.x.x  
11.x.x.x => 11.x.x.x  

## Goal

*** Reviewed for Relevance 16-Jul-2015 ***

This document describes the traditional method for upgrading your Oracle
Database software with a logical standby database in place. A second method in
Chapter 12, "Using SQL Apply to Upgrade the Oracle Database" of the Data Guard
Concepts and Administration guide describes how to upgrade with a logical
standby database in place in a rolling fashion to minimize downtime. Use the
steps from only one method to perform the complete upgrade. Do not attempt to
use both methods or to combine the steps from the two methods as you perform
the upgrade process.

## Solution

Perform the following steps to upgrade to the newest release of the Oracle
Database when a logical standby database is present in the configuration:

  1. Review and perform the steps listed in the "Preparing to Upgrade" chapter of the Oracle Database Upgrade Guide or in the appropriate patchset README.
  2. Set the data protection mode to MAXIMUM PERFORMANCE at the primary database, if needed:   

SQL> ALTER DATABASE SET STANDBY DATABASE TO MAXIMIZE PERFORMANCE;

  3. On the primary database, stop all user activity and defer the remote archival destination associated with the logical standby database. (For this procedure, it is assumed that LOG_ARCHIVE_DEST_2 is associated with the logical standby database):   

SQL> ALTER SYSTEM SET LOG_ARCHIVE_DEST_STATE_2=DEFER SCOPE=BOTH;

  4. Stop SQL Apply on the standby database:   

SQL> ALTER DATABASE STOP LOGICAL STANDBY APPLY;

  5. On the primary database install the newer release of the Oracle software as described in the Oracle Database Upgrade Guide or appropriate patchset README.
  6. On the logical standby database, install the newer release of the Oracle software as described in Oracle Database Upgrade Guide or appropriate patchset README (perform the same Steps like for a Primary Database for example catupgrd).  

Steps 5 and 6 can be performed concurrently (in other words, performed at the
same time) to reduce downtime during the upgrade procedure.

  7. On the upgraded logical standby database, restart the database and restart SQL Apply. If you are using Oracle RAC, start up the other standby database instances:   

If the upgrade was done to any release of 10.2.0.x, the following will need to
be set on the logical standby to avoid ORA-1403 on startup of SQL Apply:  
  
SQL> ALTER SYSTEM SET EVENTS '1348 trace name context forever, level
1073741824';  
  
Once SQL apply has successfully started, this event will be unset on the next
instance bounce or by stopping SQL apply again and running (but you should
wait until the Logical Apply has caught up with the Primary before unsetting
this Event):  
  
SQL> ALTER SYSTEM SET EVENTS '1348 trace name context off';

  

SQL> STARTUP  
SQL> ALTER DATABASE START LOGICAL STANDBY APPLY IMMEDIATE;  
  
If standby redo logs were not configured on the logical standby, the IMMEDIATE
clause should be dropped.

  8. Startup the upgraded primary database and allow users to connect. If you are using Oracle RAC, start up the other primary database instances.   
  
Also, enable archiving to the upgraded logical standby database, as follows:  

SQL> STARTUP  
SQL> ALTER SYSTEM SET LOG_ARCHIVE_DEST_STATE_2=ENABLE;

  9. Optionally, reset to the original data protection mode if you changed it in Step 2.

## References

[BUG:5715079](https://support.oracle.com/epmos/faces/BugDisplay?parent=DOCUMENT&sourceId=437276.1&id=5715079)
\- UPGRADED LOGICAL STANDBY FAILS WITH ORA-1281.  


---
### NOTE ATTRIBUTES
>Created Date: 2018-06-26 07:14:54  
>Last Evernote Update Date: 2018-10-01 15:40:46  
>source: web.clip7  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=267941332913471  
>source-url: &  
>source-url: id=437276.1  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=152hqe0oee_192  
>source-application: WebClipper 7  