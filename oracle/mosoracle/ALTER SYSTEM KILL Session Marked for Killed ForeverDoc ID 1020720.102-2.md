# ALTER SYSTEM KILL Session Marked for Killed Forever(Doc ID 1020720.102)

ALTER SYSTEM KILL Session Marked for Killed Forever(Doc ID 1020720.102)

ALTER SYSTEM KILL Session 会话永久被标志为Killed（文档 ID 1020720.102）

  

|

|

***Checked for relevance on 04-Feb-2016***

***04-Feb-2016检查相关性***

  

PURPOSE

目的

  This document briefly describes how to suppress sessions marked killed in
v$session.

  本文简略描述在v$sessio中怎样禁止会话被标记为killed。

  

SCOPE & APPLICATION

范围&适用

  

  Useful for DBAs.

  DBA用户

  

  
  

ALTER SYSTEM KILL Session Marked for Killed Forever:

ALTER SYSTEM KILL Session 后会话永久被标志为Killed：

====================================================  


You have a session that you have killed, but it seems as though it will not go
away:

被你killed的会话，但是这个会话好像仍在运行：

  

  
SQL> alter system kill session 'sid, serial#';  
  
SQL> select status, username from v$session;  
  
            status    killed  
            username  username   
  

You have issued this several times and it seems it still is marked as killed.

你试了好几次，但它仍被标记为killed。

  
In order to determine which process to kill:  
为了查看那个进程被杀掉：

a) On a Unix platform:

a) 在Unix平台上

  
SQL> SELECT spid  
                 FROM v$process  
                 WHERE NOT EXISTS ( SELECT 1  
                                    FROM v$session  
                                    WHERE paddr = addr);

  

或

  
SQL> SELECT inst_id, status, event, state, blocking_session, sid, serial#,
program  
     FROM   gv$session   
     WHERE  status = 'KILLED';  
  
% kill <spid>  
  
  

b) On a Windows platform:

b) 在windows平台上

  
SQL> SELECT spid, osuser, s.program  
                FROM v$process p, v$session s   
                WHERE p.addr=s.paddr;  
  

Then use the orakill utility at the DOS prompt:

然后在dos中使用orakill工具：

  
c:\> orakill <SID> <spid>  
  

where <SID>  = the Oracle instance name (ORACLE_SID)

这儿  <SID>  = Oracle实例名（ORACLE_SID）

      <spid> = the thread id of the thread to kill

      <spid> = 想要杀掉的线程ID

  
  

Explanation:

解释：

============  
  

The simplest (and probably most common) reason the session stays around is
because the process is still around. The reason the process is still around is
because it is waiting on "SQLNet message from client".  If it does ever get a
message, it will then respond with an ORA-28 "Your session has been killed"
error number. At that point the session should go away. The dedicated server
process may remain alive until the client disconnects or exits.

会话驻留最简单（并且可能最常见）的原因是这个进程仍在运行。进程仍在运行的原因是他在等待“客户端发出的SQLNet信息”。若它得到一个信息，它将报ORA-28“你的会话被杀掉了”的错误数字。这是会话应当消失。专有服务进程可能让存活，直到客户端断开连接或退出。

  

PMON may take ownership of the session while it is cleaning up any resources
held by the session at the time it was killed. If it cannot clean everything
up immediately it will leave the session under the PSEUDO process while
performing other tasks.

会话被kill时，PMON会获取会话所有权，然后清理会话持有的任何资源。如果不能立即清理，当执行其他任务时，该进程将被置为伪进程。

  

By finding the spid you can then force the process to be killed.

通过找到spid你能强制杀掉该进程。



When issuing the 'kill' command be sure that you kill "DEDICATED SERVER
PROCESSES", those called:

当执行‘kill’命令时，应确保它是你将杀掉的专有服务进程，这些叫做；

    oracle<SID> (local=NO)

  

where <SID> is the ORACLE_SID.

这儿 <SID>是ORACLE_SID

  

Be sure you do not kill processes such as:

确保不要杀掉如下进程：

  
    ora_d000_<SID>  
    ora_s000_<SID>  
    ora_pmon_<SID>  
  
  

Related Documents:

相关文档

=================

[Note:100859.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1020720.102&id=100859.1)
ALTER SYSTEM KILL SESSION does not Release Locks Killing a Thread on Windows
NT

[Note:100859.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1020720.102&id=100859.1)
Windows NT中杀掉线程 ALTER SYSTEM KILL SESSION 不释放锁

  

[Note:1041427.6](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1020720.102&id=1041427.6)
KILLING INACTIVE SESSIONS DOES NOT REMOVE SESSION ROW FROM V$SESSION

[Note:1041427.6](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1020720.102&id=1041427.6)
杀掉不活动会话，不从v$session中移除会话行

  

[Note:1023442.6](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1020720.102&id=1023442.6)
HOW TO HAVE ORACLE CLEAN-UP OLD USER INFO AFTER KILLING SESSION UNDER MTS

[Note:1023442.6](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1020720.102&id=1023442.6)
怎样强制Oracle使用AFTER KILLING SESSION清除老的用户信息

  

[Note:387077.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1020720.102&id=387077.1)
How to find the process identifier (pid, spid) after the corresponding session
is killed?

[Note:387077.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1020720.102&id=387077.1)
杀掉相应的会话后怎样找到该会话的进程ID（pid，spid）？

  

  
  
  
---  
  
  
  
  
  
  
  
  



---
### TAGS
{翻译}  {已完}

---
### NOTE ATTRIBUTES
>Created Date: 2016-11-28 02:36:58  
>Last Evernote Update Date: 2016-11-30 05:07:33  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=163432747257742  
>source-url: &  
>source-url: id=1020720.102  
>source-url: &  
>source-url: _adf.ctrl-state=5kow4kf9s_224  
>source-application: evernote.win32  