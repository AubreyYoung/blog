# How To Find The Process Identifier (pid, spid) After The Corresponding
Session Is Killed?(Doc ID 387077.1)

How To Find The Process Identifier (pid, spid) After The Corresponding Session
Is Killed?(Doc ID 387077.1)

杀掉相应的会话后怎样找到该会话的进程ID（pid，spid）？

  

|

|

  

 **In this Document**

 **本文中**

|

[
Symptoms](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=163396965574942&id=387077.1&_adf.ctrl-
state=5kow4kf9s_167#SYMPTOM)

症状

|

  
  
  
---|---  
  
[Cause](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=163396965574942&id=387077.1&_adf.ctrl-
state=5kow4kf9s_167#CAUSE)

起因

|

  
  
  
---|---  
  
[Solution](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=163396965574942&id=387077.1&_adf.ctrl-
state=5kow4kf9s_167#FIX)

结论

|

  
  
  
---|---  
  
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=163396965574942&id=387077.1&_adf.ctrl-
state=5kow4kf9s_167#REF)

参考文档

|

  
  
  
---|---  
  
* * *

 _This document is being delivered to you via Oracle Support 's Rapid
Visibility (RaV) process and therefore has not been subject to an independent
technical review._  
---  
  
  

Applies to:

适用于：

Oracle Database - Enterprise Edition - Version 9.2.0.1 to 11.1.0.7 [Release
9.2 to 11.1]

oracle数据库-企业版-9.2.0.1及以后版本

Information in this document applies to any platform.

本文内容适用于任何平台

***Checked for relevance on 04-Feb-2016***

***04-Feb-2016 检查相关性***

  
  

  

Symptoms

症状

When killing a session with 'alter system kill session' the value paddr in
v$session changes while the addr corresponding value in v$process does not.  
As a result, it is no longer possible to identify the process that has been
killed and terminate it at OS level  
  
It is very easy to check (on a solaris 64 bit machine):  
1\. Create a new session  
2\. get the sid:

SQL> select distinct sid from v$mystat;  
SID  
\---  
140

  
3\. check paddr in v$session and addr in v$process (and the spid of the
process)

SQL> select spid,addr from v$process where addr in (select paddr from  
v$session where sid=140);  
  
SPID ADDR  
\------------ ----------------  
1011 0000000398E5CAA0

  
4\. kill the session

SQL> alter system kill session '140,9752';

  
  
5\. check paddr in the v$session and addr in v$process:

SQL> select paddr from v$session where sid=140;  
  
PADDR  
\---------------------  
0000000398E9E3E8  
  
SQL> select addr from v$process where spid=1011;  
  
ADDR  
\---------------------  
0000000398E5CAA0

  
As it can be seen, after killing the session, the paddr changes only in
v$session. It is no longer possible to join the 2 views.  
  

  

Cause

起因

[Bug
5453737](https://support.oracle.com/epmos/faces/BugDisplay?parent=DOCUMENT&sourceId=387077.1&id=5453737)
WHEN A SESSION IS KILLED, PADDR CHANGES IN V$SESSION BUT ADDR NOT IN V$PROCESS  
closed as not a bug with the following explanation:  
When a session is killed, the session state object(and all the child state
objects under the session state object) move out from under the original
parent process state object, and are placed under the pseudo process state
object (which is expected, given the parent/child process mechanism on Unix).
PMON will clean up all the state objects found under the pseudo process state
object. That explains why PADDR changes in V$SESSION when a session is killed.
New PADDR you are seeing in v$SESSION is the address of the pseudo process
state object. This shows up in system state under PSEUDO PROCESS for group
DEFAULT: V$PROCESS still maintains the record of the original parent process.
This is expected.  
  

  

Solution

结论

It is not possible to identify the killed session process from a direct join
between v$process and v$session in releases inferior to 11g. This problem is
addressed in internal  
[BUG:5379252](https://support.oracle.com/epmos/faces/BugDisplay?parent=DOCUMENT&sourceId=387077.1&id=5379252)
\- Hard To Determine Server Processes Which Owned Killed Session  
  
The following workaround has been recommended:  
  

select spid, program from v$process  
    where program!= 'PSEUDO'  
    and addr not in (select paddr from v$session)  
    and addr not in (select paddr from v$bgprocess)  
    and addr not in (select paddr from v$shared_server);

  
As a result of the bug, 2 additional columns have been added to V$SESSION from
11g on:  
V$SESSION  
CREATOR_ADDR - state object address of creating process  
CREATOR_SERIAL# - serial number of creating process  
CREATOR_ADDR is the column that can be joined with the ADDR column in
V$PROCESS to uniquely identify the killed process corresponding to the former
session.  
Following the previous example, this would identify the killed session:

select * from v$process where addr=(select creator_addr from v$session where
sid=140);

  
Two more views that can be helpful for the subject have been introduced in 11g  
V$PROCESS_GROUP  
INDX - Index  
NAME - The name of the process group. The default group is called DEFAULT.  
PID - Oracle process id  
  
V$DETACHED_SESSION  
INDX - Index  
PG_NAME - The process group name that owns this session. The default group is
DEFAULT.  
SID - Oracle session id.  
SERIAL# - Session serial number.  
PID - Oracle process id.  
  
Unfortunately, these changes are only available in the Oracle releases at
least equal to 11.1.0.6 and cannot be backported to previous releases.  
  

  

References

参考文档

  

[BUG:5453737](https://support.oracle.com/epmos/faces/BugDisplay?parent=DOCUMENT&sourceId=387077.1&id=5453737)
\- WHEN A SESSION IS KILLED, PADDR CHANGES IN V$SESSION BUT ADDR NOT IN
V$PROCESS

[BUG:5453737](https://support.oracle.com/epmos/faces/BugDisplay?parent=DOCUMENT&sourceId=387077.1&id=5453737)
\- 当一个会话被杀掉，v$session中paddr改变，但是addr不在v$process  
  
  



---
### TAGS
{翻译}

---
### NOTE ATTRIBUTES
>Created Date: 2016-11-28 02:36:30  
>Last Evernote Update Date: 2016-11-30 05:14:54  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=163396965574942  
>source-url: &  
>source-url: id=387077.1  
>source-url: &  
>source-url: _adf.ctrl-state=5kow4kf9s_167  
>source-application: evernote.win32  