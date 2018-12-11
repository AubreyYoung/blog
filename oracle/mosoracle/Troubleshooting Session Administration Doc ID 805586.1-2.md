# Troubleshooting Session Administration (Doc ID 805586.1)

Troubleshooting Session Administration (Doc ID 805586.1)

会话管理排障（文档 ID805586.1 ）

  

|

|

  

 **In this Document**

 **本文中**

|

[
Purpose](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=163461189781861&id=805586.1&_adf.ctrl-
state=5kow4kf9s_281#PURPOSE)

|

  
  
  
---|---  
  
 目的

[Troubleshooting
Steps](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=163461189781861&id=805586.1&_adf.ctrl-
state=5kow4kf9s_281#TRBLSHOOT)

|

  
  
  
---|---  
  
 排障步骤

[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=163461189781861&id=805586.1&_adf.ctrl-
state=5kow4kf9s_281#REF)

|

  
  
  
---|---  
  
 参考文档

  

Applies to:

适用于：

Oracle Database - Enterprise Edition - Version 9.2.0.1 and later

oracle数据库-企业版-9.2.0.1及以后版本

Information in this document applies to any platform.

本文内容适用于任何平台

***Checked for relevance on 09-JUl-2015***

***04-Feb-2016 检查相关性***

  

Purpose

目的

  

 **Applies to** :  
适用于：

Information in this document applies to any platform.

本文内容适用于任何平台

  

 **Purpose**

 **目的**

  

The aim of this document is to provide a Troubleshooting Guide for Session
Administration, including :

本文目的是为会话管理提供排障指导，包括：

  

Troubleshooting Details

详细排障过程

General Problem Analysis

一般问题分析

Session Tracing

会话追踪

References

参考文档

  

Troubleshooting Steps

排障步骤

  

 **  Oracle Session Administration Troubleshooting**

 **Oracle会话管理排障**

  

Instructions for the Reader

读者书名

The Oracle Session Administration Troubleshooting Guide is provided to assist
you in solving Sesssion administration issues in a structured manner. The
method is based on Oracle Diagnostic Methodology and the Enhanced Problem
Analysis principles and it helps you to avoid trial and error approach. It
guides you through a step-by-step method. Diagnostic tools are included in the
document to assist in the different troubleshooting steps.

Oracle会话管理排障指导帮助你解决结构化方式中会话管理问题。该方法基于Oracle诊断方法论和强大的问题分析原则并帮助你避免试凑方式。通过一步步方式知道你。本文中包含在不同排障步骤中帮助你的诊断工具。

  

Step by step approach

一步一步的方法

  

 **ISSUE CLARIFICATION**

 **问题解答**

  
In the issue clarification section it is important to describe the problem as
best as possible. What is the problem you need to solve? At the end of the
process you should be able to come back to this section to verify if the root
cause was found and the solution was provided.  
  
WHAT IS the problem we are looking at?  
  
Examples of problem descriptions:  
  
1\. The session hang while trying to connect to the database.  
2\. Orphan sessions/processes (mismatch between v$session and v$process).  
3\. Ora-00018 Maximum Number Of Sessions Exceeded  
  
  
 **ISSUE VERIFICATION**

问题确认

  

When you have a starting problem description it is time to collect facts in a
structured way. First step would be to get an overview of all the facts we
have. What information do we have readily available?  
The answers to the following Oracle Session administration specific questions
can potentially help you to solve the problem:  
  
Please note that for Session Administration, questions can be more relevant to
certain areas, than others. For these reasons the following Key / guidelines
can be followed:

 **What is the problem / what is not a problem?**  
What are the symptoms?  
What are the different errors generated?  
What Client and Server platforms reproduce the problem?  
What Client and Server platforms work?  
What 5-digit version of Oracle software reproduces the problem?  
What 5-digit version of Oracle software works?  
(For Windows platform confirm patch number bundle used)  
What products reproduce the issue?  
What products do not reproduce the issue?  
Is this standalone database?  
Is this RAC?  
  
 **When is the problem seen / when is the problem not seen?**  
  
Is the problem constant?  
Is the problem reported intermittently?  
Is there any pattern to the failure?  
What resolves the problem?  
How long does the problem last?  
Has this ever worked or is this a fresh installation / setup?  
When did the problem start to fail?  
  
 **Where is the problem / Where is the problem not?**  
  
Is the problem seen when run directly on the server where RDBMS installed?
Check bequeath and local connections on the server :  
  
Bequeath example is  "sqlplus username/password"  
Local example is "sqlplus username/password@net-service-name"

Does it happen for bequeath and/or local connections?  
Does it happen for dedicate and/or shared connections?  
Does it happen for all users or only for some users?  
Does it happen from sqlplus sessions or from any client?  
Are there any logon triggers?  
If the problem is intermittent, Is there any pattern to the failure ?  
Date, time ?  
During peak load ?  
When a batch job is run ?  
When certain SQL statement used ?

  

  

 **CAUSE DETERMINATION**

起因认定

  

The facts listed in the **ISSUE VERIFICATION** are the starting point for the
**CAUSE DETERMINATION** :  
There are 3 main approaches to take here:  
  
Use your experience to list possible causes. List the assumptions which needs
to be checked in this case  
Start searching for possible causes in My Oracle Support or other Oracle
knowledge bases. Use the facts collected above to refine your search criteria.  
Analyze the facts on differences between the working situation and non working
situation: Depending on the answers from the questioning above and further
investigation from the troubleshooting guides you should be able to list what
is different, special, unique between the IS and the IS NOT and also see what
is changed and when.  
  
Examples  
What changes happened around time the first failure / problem was reported?  
  
New software installed?  
Upgrade done?  
New hardware?  
Network configuration changes?  
What is different between the clients who can connect and those that cannot?  
What changed and could have an impact between the working situation and the
current situation?  
What is different to the working Alias and the non-working Alias?  
  
The output will be a list of potential reasons causing the symptoms: can be a
bug, a configuration setting, a conflict with other software, …  
  

 **CAUSE JUSTIFICATION**

起因理由

  

Evaluate the causes: check the causes against the facts (the IS and the IS NOT
observations). This also includes checking the symptoms of the problem against
any bug rediscoveries identifying a problem. List potential assumptions you
have made. Determine the most probable cause (often the one with the least
assumptions or with the most reasonable assumptions).  
  
For the most probable cause, verify the assumptions and turn them into facts
(document them in the Issue Verification part). Some examples:  
  
If bug XXX then we expect an upgrade from version x to y happened before the
symptoms started  
If the configuration file is wrong on client x, and right on client y, we
expect it to work if we copy the file  
This looks like same issue as described in note XXX but then we expect also a
virus checker installed on the Windows server  
If this cause would be true then another sequence of actions would result in a
different outcome: let’s test this via an internal test case  
  
If the verification fails, go to the next probable cause and repeat the
verification.  
  
If no potential cause stands the justification process, go back to the issue
verification and collect more detailed facts. Further diagnostics can be
verified. See below in the section Diagnostic Tools)  
  

 **POTENTIAL SOLUTIONS**

 **可能的解决方案**

  
A brief description of the corrective actions that will remove the cause of
the problem: in some cases there is only 1 solution linked to the cause. But
in many cases, there are more. Example: install a patch to remove the bug from
the system, avoid the problem by working differently, or avoid the problem by
setting some parameters.  
  

 **POTENTIAL SOLUTION JUSTIFICATION**

 **可能的解决方案理由  
**  

Explain why the proposed solution solves the problem.  
  



  

 **Diagnostic Tools -** **  Session Tracing**

 **诊断工具--会话追踪**

 1\. The session hang while trying to connect to the database.

  
Check the alert log file, the OS messages log and get the following traces:  
  
a. 10046 at level 12 by attaching to the hanging session ([NOTE
1058210.6](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=805586.1&id=1058210.6)
"How to Enable SQL_TRACE for Another Session or in MTS Using Oradebug")  
  
b. an OS debugger while trying to connect to the database ([NOTE
110888.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=805586.1&id=110888.1)
"How to Trace Unix System Calls")  
  
E.g.:  
  
$ strace -fo <output file> sqlplus user/password  
  
c. get 3 errorstacks fro the hanging session ([NOTE
61552.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=805586.1&id=61552.1)
"Diagnosing Database Hanging Issues"). The time interval between two
errorstack should be around 90 seconds.  
  
d. get systemstate dump at level 12 while the new session hangs (NOTE 61552.1
"Diagnosing Database Hanging Issues")  
  
e. for local connections only get  
  
\- the sqlnet traces for client/server ([NOTE
219968.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=805586.1&id=219968.1)
"SQL*Net, Net8, Oracle Net Services - Tracing and Logging at a Glance")  
\- os debugger as described in step (b)  
\- the sqlnet log file: $ORACLE_HOME/network/log/sqlnet.log  
\- the listener log file: $ORACLE_HOME/network/log/listener.log  
  

  
2\. Orphan sessions/processes (mismatch between v$session and v$process).

Normally, Oracle on its own will not create orphan processes. Orphan processes
are created when clients either get disconnected by network problems,
firewalls closing ports on active connections or by end users exiting
applications incorrectly.  
  
a. check the values for PROGRAM/BACKGROUND for the orphan processes:  
  
select addr, spid, username, program, background  
from v$process  
where addr not in (select paddr from v$session)  
/  
  
b. get 2-3 errorstacks and/or the process state for the orphan processes in
order to determine the call stack of the process and the source (e.g. jdbc,
odbc, toad, etc.); see [NOTE
61552.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=805586.1&id=61552.1)
"Diagnosing Database Hanging Issues".  
  
c.  get the output for  
  
$ ps -ef | grep SID  
  
in order to determine if there is a mismatch between v$process and the OS
processes list and to get the parent PID for the orphan process. If the parent
process for the orphan process is still active repeat step (b) for the parent
in order to determine its source.  
  
d. repeat steps (b) and (c) thrice at an interval of 30 min (To check whether
the sessions are disappearing after some time or just staying back)  
  
e. implement Dead Connection Detection DCD  
  
Please note that while Dead Connection Detection is set at the SQL*Net level,
it relies heavily on the underlying protocol stack for it's successful
execution. For example, you might set SQLNET.EXPIRE_TIME=1 in the sqlnet.ora
file, but it is unlikely that an orphaned server process will be cleaned up
immediately upon expiration of that interval.  
  
References:  
  
[NOTE
151972.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=805586.1&id=151972.1)
"Dead Connection Detection (DCD) Explained"  
[NOTE
601605.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=805586.1&id=601605.1)
"A discussion of Dead Connection Detection, Resource Limits, V$SESSION,
V$PROCESS and OS processes"  
  
Note: On Windows, the DCD implementation could cause additional orphan
processes; see [NOTE
462252.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=805586.1&id=462252.1)
"Orphaned Processes when DCD is enabled on Windows"  
  
f. if the issue still reproduces, turn on Event 10246 at level 1.  
  
This turns on PMON tracing and we should be able to check to see if PMON  
cleaned up a dead process. The event needs to be set in the init ora file, and
the database must be restarted then. Restarting the database will clear the  
problem so we would need to wait for the issue to happen again.  
      
    event = "10246 trace name context forever, level 1"  
  
References:  
  
[NOTE
1020720.102](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=805586.1&id=1020720.102)
ALTER SYSTEM KILL Session Marked for Killed Forever"  
[NOTE
107686.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=805586.1&id=107686.1)
"Why several Process remain KILLED in V$SESSION"  
[NOTE
100859.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=805586.1&id=100859.1)
"ALTER SYSTEM KILL SESSION does not Release Locks Killing a Thread on Windows
NT"  
[NOTE
387077.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=805586.1&id=387077.1)
"How to find the process identifier (pid, spid) after the corresponding
session is killed?"  
[NOTE
1041427.6](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=805586.1&id=1041427.6)
"KILLING INACTIVE SESSIONS DOES NOT REMOVE SESSION ROW FROM V$SESSION"  
  
Known issues:  
  
[NOTE
5362226.8](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=805586.1&id=5362226.8)
"Bug 5362226 - PMON may not clean up dead processes"  


  
3\. Ora-00018 Maximum Number Of Sessions Exceeded

Error:  ORA 18  
Text:   maximum number of sessions exceeded  
\-------------------------------------------------------------------------------  
Cause:  An operation requested a resource that was unavailable.  
        The maximum number of sessions is specified by the initialization   
        parameter SESSIONS.  
        When this maximum is reached, no more requests are processed.  
Action: Try the operation again in a few minutes.  
        If this message occurs often, shut down Oracle, increase the SESSIONS   
        parameter in the initialization parameter file, and restart Oracle.  
  
a. Usually this is the expected behavior as described in [NOTE
419130.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=805586.1&id=419130.1)
"Ora-00018 Maximum Number Of Sessions Exceeded". For example the number of
sessions when error reported from ‘select count(*) from v$session’ is much
lesser that the session’s parameter that is set in the database (either set
directly by SESSIONS parameter or derived from PROCESSES parameter). The
similar issue was raised long back in the bug below but was closed as not a
bug. The explanation provided by the development was that this is due to
internal recursive calls which are not displayed in the normal v$session view.
This v$session view gives only the user session.  
  
Reference  
  
[BUG
1528019](https://support.oracle.com/epmos/faces/BugDisplay?parent=DOCUMENT&sourceId=805586.1&id=1528019)
"ORA-18 AT 50% OF SESSIONS"  
  
Eg:  
  
SQL> select count(*) from x$ksuse where bitand(ksspaflg,1) !=0 ;  
  
COUNT(*)  
\----------  
10  
  
SQL> select count(*) from v$session' ;  
  
COUNT(*)  
\----------  
9  
  
  
The solution in most of the case is to increase the init.ora
SESSIONS/PROCESSES parameter value.  
  
The other options is to limit the number of sessions per USER using resource
limit profiles (SESSIONS_PER_USER)  
  
References:  
  
Oracle® Database SQL Reference  
10g Release 2 (10.2) - CREATE PROFILE  
http://download.oracle.com/docs/cd/B19306_01/server.102/b14200/statements_6010.htm#i2065930  
  
[NOTE
1016552.102](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=805586.1&id=1016552.102)
"How to use PROFILES to limit user resources"  
[NOTE
206007.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=805586.1&id=206007.1)
"How To Automate Cleanup Of Dead Connections And INACTIVE Sessions"  
  
b. Check if there is any user, application creating excessive sessions. In
order to determine the source of a session get the process state as described
in [NOTE
61552.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=805586.1&id=61552.1)
"Diagnosing Database Hanging Issues".  
Contact the application vendor in order to check why there are so many opened
sessions (possibly sessions leak at the application level).

  

References

参考文档

[NOTE:1023442.6](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=805586.1&id=1023442.6)
\- HOW TO HAVE ORACLE CLEAN-UP OLD USER INFO AFTER KILLING SESSION  
[NOTE:1041427.6](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=805586.1&id=1041427.6)
\- KILLING INACTIVE SESSIONS DOES NOT REMOVE SESSION ROW FROM V$SESSION  
[NOTE:165659.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=805586.1&id=165659.1)
\- Difference Between Processes, Sessions and Connections  
[NOTE:206007.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=805586.1&id=206007.1)
\- How To Automate Cleanup Of Dead Connections And INACTIVE Sessions  
[NOTE:387077.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=805586.1&id=387077.1)
\- How To Find The Process Identifier (pid, spid) After The Corresponding
Session Is Killed?  
[NOTE:462252.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=805586.1&id=462252.1)
\- Orphaned Processes when DCD is enabled on Windows  
[NOTE:61552.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=805586.1&id=61552.1)
\- Oracle 9i and Below: Exhaustive Troubleshooting Steps for Oracle Database
Hanging Issues  
[NOTE:1287854.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=805586.1&id=1287854.1)
\- Troubleshooting Guide - ORA-20: Maximum Number Of Processes (%S) Exceeded  
[NOTE:100859.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=805586.1&id=100859.1)
\- ALTER SYSTEM KILL SESSION does not Release Locks Killing a Thread on
Windows NT  
[NOTE:1016552.102](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=805586.1&id=1016552.102)
\- How To Use PROFILES To Limit User Resources  
[NOTE:161794.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=805586.1&id=161794.1)
\- Should Sessions be Killed in OS or Using Alter System Kill Session?  
[NOTE:1020720.102](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=805586.1&id=1020720.102)
\- ALTER SYSTEM KILL Session Marked for Killed Forever  
  
  
  



---
### TAGS
{翻译}

---
### NOTE ATTRIBUTES
>Created Date: 2016-11-28 02:37:43  
>Last Evernote Update Date: 2016-11-30 05:42:37  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=163461189781861  
>source-url: &  
>source-url: id=805586.1  
>source-url: &  
>source-url: _adf.ctrl-state=5kow4kf9s_281  
>source-application: evernote.win32  