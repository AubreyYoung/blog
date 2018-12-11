# Troubleshooting Database Contention With V$Wait_Chains (文档 ID 1428210.1)

  

|

|

 **In this Document**  

| |
[Purpose](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=259568625095759&id=1428210.1&_afrWindowMode=0&_adf.ctrl-
state=e3039yktr_4#PURPOSE)  
---|---  
| [Troubleshooting
Steps](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=259568625095759&id=1428210.1&_afrWindowMode=0&_adf.ctrl-
state=e3039yktr_4#TRBLSHOOT)  
---|---  
|
[Introduction](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=259568625095759&id=1428210.1&_afrWindowMode=0&_adf.ctrl-
state=e3039yktr_4#aref_section21)  
---|---  
| [Basic
Information](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=259568625095759&id=1428210.1&_afrWindowMode=0&_adf.ctrl-
state=e3039yktr_4#aref_section22)  
---|---  
| [Additional Information (formatted) - Top 100 wait chain
processes](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=259568625095759&id=1428210.1&_afrWindowMode=0&_adf.ctrl-
state=e3039yktr_4#aref_section23)  
---|---  
| [Final Blocking Session in
11.2](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=259568625095759&id=1428210.1&_afrWindowMode=0&_adf.ctrl-
state=e3039yktr_4#aref_section24)  
---|---  
| [Example of Output of Query 1 using Oracle Enterprise
Manager](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=259568625095759&id=1428210.1&_afrWindowMode=0&_adf.ctrl-
state=e3039yktr_4#aref_section25)  
---|---  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=259568625095759&id=1428210.1&_afrWindowMode=0&_adf.ctrl-
state=e3039yktr_4#REF)  
---|---  
  
* * *

## Applies to:

Oracle Database - Enterprise Edition - Version 11.1.0.6 to 12.1.0.2 [Release
11.1 to 12.1]  
Information in this document applies to any platform.  

## Purpose

The purpose of this document is to provide a fast and easy way to troubleshoot
database contention and hangs via SQL in version 11g with v$wait_chains.

## Troubleshooting Steps

### Introduction

Starting in 11g release 1, the dia0 background processes starts collecting
hanganalyze information and stores this in memory in the "hang analysis
cache". It does this every 3 seconds for local hanganalyze information and
every 10 seconds for global (RAC) hanganalyze information.  
  
The data stored in the "hang analysis cache" can be extremely valuable for
troubleshooting live database contention and hangs.  
  
There are many database features that utilize the hang analysis cache for
example: Hang Management, Resource Manager Idle Blocker Kill, SQL Tune Hang
Avoidance and PMON cleanup as well as external tools that use the hang
analysis cache like Procwatcher.  
  
The following is a describe of v$wait_chains in 11g R2:

SQL> desc v$wait_chains  
Name Null? Type  
\----------------------------------------- -------- ----------------------  
CHAIN_ID NUMBER  
CHAIN_IS_CYCLE VARCHAR2(5)  
CHAIN_SIGNATURE VARCHAR2(801)  
CHAIN_SIGNATURE_HASH NUMBER  
INSTANCE NUMBER  
OSID VARCHAR2(25)  
PID NUMBER  
SID NUMBER  
SESS_SERIAL# NUMBER  
BLOCKER_IS_VALID VARCHAR2(5)  
BLOCKER_INSTANCE NUMBER  
BLOCKER_OSID VARCHAR2(25)  
BLOCKER_PID NUMBER  
BLOCKER_SID NUMBER  
BLOCKER_SESS_SERIAL# NUMBER  
BLOCKER_CHAIN_ID NUMBER  
IN_WAIT VARCHAR2(5)  
TIME_SINCE_LAST_WAIT_SECS NUMBER  
WAIT_ID NUMBER  
WAIT_EVENT NUMBER  
WAIT_EVENT_TEXT VARCHAR2(64)  
P1 NUMBER  
P1_TEXT VARCHAR2(64)  
P2 NUMBER  
P2_TEXT VARCHAR2(64)  
P3 NUMBER  
P3_TEXT VARCHAR2(64)  
IN_WAIT_SECS NUMBER  
TIME_REMAINING_SECS NUMBER  
NUM_WAITERS NUMBER  
ROW_WAIT_OBJ# NUMBER  
ROW_WAIT_FILE# NUMBER  
ROW_WAIT_BLOCK# NUMBER  
ROW_WAIT_ROW# NUMBER

Note: There is no gv$ equivalent as v$wait_chains would report on multiple
instances in a multi-instance (RAC) environment.

  
Useful SQLs for querying v$wait_chains:

#### Basic Information

SQL> SELECT chain_id, num_waiters, in_wait_secs, osid, blocker_osid,
substr(wait_event_text,1,30)  
FROM v$wait_chains; 2  
  
CHAIN_ID NUM_WAITERS IN_WAIT_SECS OSID BLOCKER_OSID
SUBSTR(WAIT_EVENT_TEXT,1,30)  
\---------- ----------- ------------ -------------------------
------------------------- ------------------------------  
1 0 10198 21045 21044 enq: TX - row lock contention  
1 1 10214 21044 SQL*Net message from client

#### Additional Information (formatted) - Top 100 wait chain processes

set pages 1000  
set lines 120  
set heading off  
column w_proc format a50 tru  
column instance format a20 tru  
column inst format a28 tru  
column wait_event format a50 tru  
column p1 format a16 tru  
column p2 format a16 tru  
column p3 format a15 tru  
column Seconds format a50 tru  
column sincelw format a50 tru  
column blocker_proc format a50 tru  
column waiters format a50 tru  
column chain_signature format a100 wra  
column blocker_chain format a100 wra  
  
SELECT *  
FROM (SELECT 'Current Process: '||osid W_PROC, 'SID '||i.instance_name
INSTANCE,  
'INST #: '||instance INST,'Blocking Process:
'||decode(blocker_osid,null,'<none>',blocker_osid)||  
' from Instance '||blocker_instance BLOCKER_PROC,'Number of waiters:
'||num_waiters waiters,  
'Wait Event: ' ||wait_event_text wait_event, 'P1: '||p1 p1, 'P2: '||p2 p2,
'P3: '||p3 p3,  
'Seconds in Wait: '||in_wait_secs Seconds, 'Seconds Since Last Wait:
'||time_since_last_wait_secs sincelw,  
'Wait Chain: '||chain_id ||': '||chain_signature chain_signature,'Blocking
Wait Chain: '||decode(blocker_chain_id,null,  
'<none>',blocker_chain_id) blocker_chain  
FROM v$wait_chains wc,  
v$instance i  
WHERE wc.instance = i.instance_number (+)  
AND ( num_waiters > 0  
OR ( blocker_osid IS NOT NULL  
AND in_wait_secs > 10 ) )  
ORDER BY chain_id,  
num_waiters DESC)  
WHERE ROWNUM < 101;  
  

  
  
ospid 25627 is waiting for a TX lock and is blocked by ospid 21549  
ospid 21549 is idle waiting for "SQL*Net message from client"

Note: You can use Procwatcher proactively to monitor v$wait_chains and dumps
diagnostic information if database contention is detected.  
  
For information on Procwatcher see:  
[Document
459694.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1428210.1&id=459694.1)
Procwatcher: Script to Monitor and Examine Oracle DB and Clusterware Processes  
  
For an example of how to use Procwatcher to trap database contention problems
see:  
[Document
1352623.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1428210.1&id=1352623.1)
How To Troubleshoot Database Contention With Procwatcher

#### Final Blocking Session in 11.2

In 11.2 you can also add v$session.final_blocking_session to see the final
blocker. The final blocker is the session/process at the top of the wait
chain. This is the session/process that maybe causing the problem. Example of
query with final_blocking_session info:

`set pages 1000  
set lines 120  
set heading off  
column w_proc format a50 tru  
column instance format a20 tru  
column inst format a28 tru  
column wait_event format a50 tru  
column p1 format a16 tru  
column p2 format a16 tru  
column p3 format a15 tru  
column Seconds format a50 tru  
column sincelw format a50 tru  
column blocker_proc format a50 tru  
column fblocker_proc format a50 tru  
column waiters format a50 tru  
column chain_signature format a100 wra  
column blocker_chain format a100 wra  
  
SELECT *  
FROM (SELECT 'Current Process: '||osid W_PROC, 'SID '||i.instance_name
INSTANCE,  
'INST #: '||instance INST,'Blocking Process:
'||decode(blocker_osid,null,'<none>',blocker_osid)||  
' from Instance '||blocker_instance BLOCKER_PROC,  
'Number of waiters: '||num_waiters waiters,  
'Final Blocking Process: '||decode(p.spid,null,'<none>',  
p.spid)||' from Instance '||s.final_blocking_instance FBLOCKER_PROC,  
'Program: '||p.program image,  
'Wait Event: ' ||wait_event_text wait_event, 'P1: '||wc.p1 p1, 'P2: '||wc.p2
p2, 'P3: '||wc.p3 p3,  
'Seconds in Wait: '||in_wait_secs Seconds, 'Seconds Since Last Wait:
'||time_since_last_wait_secs sincelw,  
'Wait Chain: '||chain_id ||': '||chain_signature chain_signature,'Blocking
Wait Chain: '||decode(blocker_chain_id,null,  
'<none>',blocker_chain_id) blocker_chain  
FROM v$wait_chains wc,  
gv$session s,  
gv$session bs,  
gv$instance i,  
gv$process p  
WHERE wc.instance = i.instance_number (+)  
AND (wc.instance = s.inst_id (+) and wc.sid = s.sid (+)  
and wc.sess_serial# = s.serial# (+))  
AND (s.final_blocking_instance = bs.inst_id (+) and s.final_blocking_session =
bs.sid (+))  
AND (bs.inst_id = p.inst_id (+) and bs.paddr = p.addr (+))  
AND ( num_waiters > 0  
OR ( blocker_osid IS NOT NULL  
AND in_wait_secs > 10 ) )  
ORDER BY chain_id,  
num_waiters DESC)  
WHERE ROWNUM < 101;  
  
`

Here we can see that ospid 2309 is the final blocker. **  
**

### Example of Output of Query 1 using Oracle Enterprise Manager

  
  
In the above example we see that:

  * ospid: 1135 is waiting for a TM enqueue and is waiting for ospid: 454.
  * ospid: 454 is waiting for a TM enqueue and is waiting for ospid: 507.
  * ospid: 507 is idle waiting for "SQL*Net message from client".

Also note that ospid's 615 and 1111 are also waiting for the first wait chain
meaning that ospid: 507 is ultimately blocking these 2 processes as well.  
  
Solutions to this contention would include trying to get ospid: 507 release
the lock or even killing the session or process if there is no other
alternative.  
  
  


---
### ATTACHMENTS
[4610325791b3adf732a8b974778702dc]: media/Troubleshooting_Database_Contention_With_V$Wait_Chains_文档_ID_1428210.1)
[Troubleshooting_Database_Contention_With_V$Wait_Chains_文档_ID_1428210.1)](media/Troubleshooting_Database_Contention_With_V$Wait_Chains_文档_ID_1428210.1))
[8abb162e62df928ad18380741f367a0e]: media/Troubleshooting_Database_Contention_With_V$Wait_Chains_文档_ID_1428210-2.1)
[Troubleshooting_Database_Contention_With_V$Wait_Chains_文档_ID_1428210-2.1)](media/Troubleshooting_Database_Contention_With_V$Wait_Chains_文档_ID_1428210-2.1))
[c9ef6fa906d4ced037c64c0bda658533]: media/Troubleshooting_Database_Contention_With_V$Wait_Chains_文档_ID_1428210-3.1)
[Troubleshooting_Database_Contention_With_V$Wait_Chains_文档_ID_1428210-3.1)](media/Troubleshooting_Database_Contention_With_V$Wait_Chains_文档_ID_1428210-3.1))
---
### NOTE ATTRIBUTES
>Created Date: 2018-01-23 08:30:03  
>Last Evernote Update Date: 2018-10-01 15:40:46  
>author: YangKwong  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=259568625095759  
>source-url: &  
>source-url: id=1428210.1  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=e3039yktr_4  