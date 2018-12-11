# FAQ: What are Latches and What Causes Latch Contention (11g and Above) (文档
ID 1970450.1)

  

|

|

 **In this Document**  

| |
[Purpose](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=1970450.1&_adf.ctrl-
state=11dph05qcs_243&_afrLoop=153315641007401#PURPOSE)  
---|---  
| [Questions and
Answers](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=1970450.1&_adf.ctrl-
state=11dph05qcs_243&_afrLoop=153315641007401#FAQ)  
---|---  
| [What is a
latch?](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=1970450.1&_adf.ctrl-
state=11dph05qcs_243&_afrLoop=153315641007401#aref_section21)  
---|---  
| [What is the difference between latches and
enqueues?](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=1970450.1&_adf.ctrl-
state=11dph05qcs_243&_afrLoop=153315641007401#aref_section22)  
---|---  
| [What is differences between latches and
mutexes?](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=1970450.1&_adf.ctrl-
state=11dph05qcs_243&_afrLoop=153315641007401#aref_section23)  
---|---  
| [When is a latch
obtained?](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=1970450.1&_adf.ctrl-
state=11dph05qcs_243&_afrLoop=153315641007401#aref_section24)  
---|---  
| [What are the possible latch request
mode?](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=1970450.1&_adf.ctrl-
state=11dph05qcs_243&_afrLoop=153315641007401#aref_section25)  
---|---  
| [Spin
Count](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=1970450.1&_adf.ctrl-
state=11dph05qcs_243&_afrLoop=153315641007401#aref_section26)  
---|---  
| [What causes latch
contention?](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=1970450.1&_adf.ctrl-
state=11dph05qcs_243&_afrLoop=153315641007401#aref_section27)  
---|---  
| [How to identify contention for
latches?](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=1970450.1&_adf.ctrl-
state=11dph05qcs_243&_afrLoop=153315641007401#aref_section28)  
---|---  
| [How get the hit ratio for
latches](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=1970450.1&_adf.ctrl-
state=11dph05qcs_243&_afrLoop=153315641007401#aref_section29)  
---|---  
| [Useful SQL scripts to get latch information using the
views:](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=1970450.1&_adf.ctrl-
state=11dph05qcs_243&_afrLoop=153315641007401#aref_section210)  
---|---  
| [Find the latch name and
'sleeps'](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=1970450.1&_adf.ctrl-
state=11dph05qcs_243&_afrLoop=153315641007401#aref_section211)  
---|---  
| [Find latch name, address, gets, misses, sleeps,
etc:](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=1970450.1&_adf.ctrl-
state=11dph05qcs_243&_afrLoop=153315641007401#aref_section212)  
---|---  
| [Display latch statistics by latch
name](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=1970450.1&_adf.ctrl-
state=11dph05qcs_243&_afrLoop=153315641007401#aref_section213)  
---|---  
| [Contention on Latches and Mutexes that are of most concern to the
DBA:](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=1970450.1&_adf.ctrl-
state=11dph05qcs_243&_afrLoop=153315641007401#aref_section214)  
---|---  
| [BUFFER CACHE
LATCH](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=1970450.1&_adf.ctrl-
state=11dph05qcs_243&_afrLoop=153315641007401#aref_section215)  
---|---  
| [ LIBRARY CACHE
LATCHES](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=1970450.1&_adf.ctrl-
state=11dph05qcs_243&_afrLoop=153315641007401#aref_section216)  
---|---  
| [LIBRARY CACHE PIN
LATCH](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=1970450.1&_adf.ctrl-
state=11dph05qcs_243&_afrLoop=153315641007401#aref_section217)  
---|---  
| [SHARED POOL
LATCHES](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=1970450.1&_adf.ctrl-
state=11dph05qcs_243&_afrLoop=153315641007401#aref_section218)  
---|---  
| [ROW CACHE OBJECTS LATCH
](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=1970450.1&_adf.ctrl-
state=11dph05qcs_243&_afrLoop=153315641007401#aref_section219)  
---|---  
| [REDOLOG BUFFER
LATCHES](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=1970450.1&_adf.ctrl-
state=11dph05qcs_243&_afrLoop=153315641007401#aref_section220)  
---|---  
| [MUTEXES
](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=1970450.1&_adf.ctrl-
state=11dph05qcs_243&_afrLoop=153315641007401#aref_section221)  
---|---  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=1970450.1&_adf.ctrl-
state=11dph05qcs_243&_afrLoop=153315641007401#REF)  
---|---  
  
* * *

## Applies to:

Oracle Database - Personal Edition - Version 11.1.0.6 and later  
Oracle Database - Enterprise Edition - Version 11.1.0.6 and later  
Oracle Database - Standard Edition - Version 11.1.0.6 and later  
Information in this document applies to any platform.  

## Purpose

A number of different locking mechanisms are used to protect data from
concurrent access including latches, enqueues, distributed locks and global
locks (used in RAC).

This bulletin focuses on latches and aims to provide a clear understanding of
how latches are implemented and the causes of latch contention. The
information provided can be used in tuning the various kinds of latches
discussed.

**Note** : It is important to understand that it is neither practical nor
possible to provide specific values for the init.ora parameters discussed in
this bulletin. The values for these parameters vary from database to database
and from platform to platform. Moreover, for the same database and platforms,
they may vary from application to application.

For advice on earlier versions, refer to:

[Document
22908.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1970450.1&id=22908.1)
FAQ: What are Latches and What Causes Latch Contention (Pre-11g)

## Questions and Answers

### What is a latch?

Latches provide a low level serialization mechanism protecting shared data
structures in the SGA. A latch is a type of a lock that can be very quickly
acquired and freed. Latches are typically used to prevent more than one
process from executing the same piece of code at a given time. When a latch is
acquired, it is acquired at a particular level in order to prevent deadlocks.
Once a process acquires a latch at a certain level, it cannot subsequently
acquire a latch at a level that is equal to or less than that level (unless it
acquires it nowait). Associated with each latch is a cleanup procedure that
will be called if a process dies while holding the latch. This cleaning is
done using the services of PMON. The underlying implementation of latches is
operating system dependent, particularly in regard to whether a process will
wait for a latch and for how long.  
  
Some example of latches are following: buffer latch catches, library cache
latches, shared pool latches, redo allocation latches, copy latches, archive
control latch and redolog buffer latches.

### What is the difference between latches and enqueues?

Enqueues are another type of locking mechanism used in Oracle. An enqueue is a
more sophisticated mechanism which permits several concurrent processes to
have varying degree of sharing of "known" resources. Any object which can be
used concurrently can be protected with enqueues. A good example is taking and
holding locks on tables. Varying levels of sharing is permittent on tables,
for example: multiple processes can lock a table in share mode or in share
update mode etc.

One difference between a latch and an enqueue is that the enqueue is obtained
using an OS specific locking mechanism whereas a latch is obtained independent
of the OS. An enqueue allows the user to store a value in the lock (i.e the
mode in which we are requesting it). The OS lock manager keeps track of the
resources locked. If a process cannot be granted to the lock because it is
incompatible with the mode requested and the lock is requested with wait, the
OS puts the requesting process on a wait queue which is serviced in FIFO.

Another difference between latches and enqueues is that enqueues maintain and
ordered queue of waiters while latches do not. All processes waiting for a
latch concurrently retry (depending on the scheduler). This means that any of
the waiters might get the latch and conceivably the first one attempting to
obtain the latch might be the last one to actually get it. Latch waiters may
either use timers to wakeup and retry or they may spin (only in
multiprocessors) spinning on a latch means holding the CPU and waiting in
anticipation of that latch being freed in a short time).

### What is differences between latches and mutexes?

Mutexes are a lighter-weight and more granular concurrency mechanism than
latches that control access to the library cache. They take advantage of CPU
architectures that offer the compare and swap instructions (or similar).
Mutexes, like latches, ensure that certain operations are properly managed for
concurrency, for example, if one session is changing a data structure in
memory, then another session must wait to acquire the mutex before it can make
a similar change. This prevents unintended changes that would lead to
corruptions or crashes if not serialized.

### When is a latch obtained?

A process acquires a latch when working with a structure in the SGA (System
Global Area). It continues to hold the latch for the period of time it works
with the structure. The latch is dropped when the process is finished with the
structure. Each latch protects a different set of data, identified by the name
of the latch.

The goal of latches is to manage concurrent access to shared data structures
such that only one process can access the structure at a time. Blocked
processes (processes waiting to execute a part of the code for which a latch
has already been obtained by some other process) will wait until the latch is
released. Oracle uses atomic instructions like "test and set" for operating on
latches. Since the instructions to set and free latches are atomic, the OS
guarantees that only one process gets it and because it is only a single
instruction, it is quite fast.

### What are the possible latch request mode?

Latch requests can be made in two modes:

  * **willing-to-wait :** A "willing-to-wait" mode request will loop, wait, and request again until the latch is obtained. Examples of "willing-to-wait" latches are shared pool and library cache latches. **  
  
**

  * **no wait** : In "no wait" mode, the process will request the latch and if it is not available, instead of waiting, another one is requested. Only when all fail does the server process have to wait. An example of "no wait" latch is the redo copy latch.

### Spin Count

Spin counts controls how many times the process will re-try to obtain the
latch before backing off and going to sleep. This basically means the process
is in a tight CPU loop continually trying to get the latch for SPIN_COUNT
attempts. On a single CPU system if an Oracle process tries to acquire a latch
but it is held by someone else the process will release the CPU and go to
sleep for a short period before trying again. However, on a multi processor
system (SMP) it is possible that the process holding the latch is running on
one of the other CPUs and so will potentially release the latch in the next
few instructions (latches are usually held for only very short periods of
time).

### What causes latch contention?

If a required latch is busy, the process requesting it spins, tries again and
if still unavailable, spins again. The loop is repeated up to a maximum number
of times determined by the hidden initialization parameter _SPIN_COUNT. The
default value of the parameter is automatically adjusted when the machine's
CPU count changes provided that the default was used. If the parameter was
explicitly set, then there is no change. It is not usually recommended to
change the default value for this parameter.

If after this entire loop, the latch is still not available, the process must
yield the CPU and go to sleep. Initially, it sleeps for one centisecond. This
time is doubled in every subsequent sleep. This causes a slowdown to occur and
results in additional CPU usage until a latch is available. The CPU usage is a
consequence of the "spinning" of the process. "Spinning" means that the
process continues to look for the availability of the latch after certain
intervals of time, during which it sleeps.

#### How to identify contention for latches?

Use AWR or statspack to identify the contention of latches (remember a license
is required to use AWR). Here is an example AWR report showing latch free
waits as top wait.

One of the top waits is 'latch free' wait:

To find where the contention is, click on 'latch statistics':

Then, click on 'latch sleep breakdown':

Notice the top latches...once identified and depending on the latch, start the
investigation and resolution process:

The following data dictionary views can be accessed identify latch contention:  
  

  * V$LATCH shows aggregate latch statistics for both parent and child latches, grouped by latch name:  
  

**Oracle® Database Reference  
11 _g_ Release 2 (11.2)**  
Part Number E17110-04[  
https://docs.oracle.com/cd/E18283_01/server.112/e17110/dynviews_2015.htm
](https://docs.oracle.com/cd/E18283_01/server.112/e17110/dynviews_2015.htm)

  
  

  * V$LATCH_PARENT displays statistics about parent latches. The columns for `V$LATCH_PARENT` are the same as those for `V$LATCH`.  
  

  * V$LATCH_CHILDREN displays statistics about child latches. This view includes all columns of `V$LATCH` plus the `CHILD#`column:  
  

**Oracle® Database Reference  
11 _g_ Release 2 (11.2)**  
Part Number E17110-04[  
https://docs.oracle.com/cd/E18283_01/server.112/e17110/dynviews_2016.htm#i1407087
](https://docs.oracle.com/cd/E18283_01/server.112/e17110/dynviews_2016.htm#i1407087)

  
  

  * V$LATCHNAME contains information about decoded latch names for the latches shown in V$LATCH:  
  

**Oracle® Database Reference** **  
**11** _g_ **Release 2 (11.2)****  
Part Number E17110-04  
<http://docs.oracle.com/cd/E18283_01/server.112/e17110/dynviews_2020.htm>

  
Oracle versions might differ in the latch# assigned to the existing latches.
In order to obtain information for the specific version query as follows:

column name format a40 heading 'LATCH NAME'  
select latch#, name from v$latchname;

  
  

  * V$LATCHHOLDER contains information about the current latch holders:  
  

**Oracle® Database Reference  
11 _g_ Release 2 (11.2)**  
Part Number E17110-04  
<http://docs.oracle.com/cd/E18283_01/server.112/e17110/dynviews_2019.htm>

  
  

#### How get the hit ratio for latches

To get the hit ratio for latches, review the 'Instance Efficiency Percentages
(Target 100%)' of AWR:

Or download this script:

[http://oracle-base.com/dba/script.php?category=monitoring&file=tuning.sql
](http://oracle-base.com/dba/script.php?category=monitoring&file=tuning.sql)

Or apply the following formula:

"willing-to-wait" Hit Ratio = (GETS - MISSES) / GETS  
"no wait" Hit Ratio = (IMMEDIATE_GETS - IMMEDIATE_MISSES) / IMMEDIATE_GETS

The ratio should be close to 1. If not, tune dependent on the latch.

#### Useful SQL scripts to get latch information using the views:

##### Find the latch name and 'sleeps'

To find latch name and the sleeps, run following sql:

SELECT n.name, l.sleeps  
FROM v$latch l, v$latchname n  
WHERE n.latch#=l.latch# and l.sleeps > 0 order by l.sleeps

Example ouput:

LATCH NAME SLEEPS  
\-------------------------------- ----------  
call allocation 76  
JS Sh mem access 109  
redo allocation 112  
row cache objects 129  
shared pool 4652

The example shows shared pool latch with the highest sleep so concentrate on
optimizing that area first.

##### Find latch name, address, gets, misses, sleeps, etc:

Display System-wide latch statistics by running following sql to obtain latch
name, address, gets, misses, sleeps, etc:

column name format A32 truncate heading "LATCH NAME"  
column pid heading "HOLDER PID"

select c.name,a.addr,a.gets,a.misses,a.sleeps,a.immediate_gets,  
a.immediate_misses,b.pid  
from v$latch a, v$latchholder b, v$latchname c  
where a.addr = b.laddr(+) and a.latch# = c.latch#  
order by a.latch#;

Example output:

LATCH NAME ADDR GETS MISSES  
\-------------------------------- ---------------- ---------- ----------  
SLEEPS IMMEDIATE_GETS IMMEDIATE_MISSES HOLDER PID  
\---------- -------------- ---------------- ----------  
cache buffers chain 00000000600188A8 1009130 43  
2 5595705 233

buffer pool 0000000060018950 2177 0  
0 0 0

multiple dbwriter suspend 0000000060018BF8 0 0  
0 0 0

Assuming there is latch contention, in this case, the 'cache buffer chains'
latch is showing the most gets, misses and sleeps so start investigating
there.

##### Display latch statistics by latch name

To display latch statistics by latch name, run following sql:

column name format a32 heading 'LATCH NAME'  
column pid heading 'HOLDER PID'  
  
select c.name,a.addr,a.gets,a.misses,a.sleeps, a.immediate_gets,  
a.immediate_misses,b.pid  
from v$latch a, v$latchholder b, v$latchname c  
where a.addr = b.laddr(+) and a.latch# = c.latch#  
and c.name like '&latch_name%' order by a.latch#;

Example output:

LATCH NAME ADDR GETS MISSES  
\-------------------------------- ---------------- ---------- ----------  
SLEEPS IMMEDIATE_GETS IMMEDIATE_MISSES HOLDER PID  
\---------- -------------- ---------------- ----------  
cache buffers chain 00000000600188A8 1009288 43  
2 5595884 233

### Contention on Latches and Mutexes that are of most concern to the DBA:

#### BUFFER CACHE LATCH

This latch is acquired whenever a block in the buffer cache is accessed
(pinned). Reducing contention for the cache buffer chains latch will usually
require reducing logical I/O rates by tuning and minimizing the I/O
requirements of the SQL involved. Review following note to start
troubleshooting this latch:

[Document
1342917.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1970450.1&id=1342917.1)
Troubleshooting 'latch: cache buffers chains' Wait Contention

High I/O rates could be a sign of a hot block (meaning a block highly
accessed):

[Document
163424.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1970450.1&id=163424.1)
How To Identify a Hot Block Within The Database Buffer Cache to correctly
identify this issue.

For assistance in tuning the sql, review following note:

[Document
1476044.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1970450.1&id=1476044.1)
Resolving Issues Where 'latch: cache buffer chain' Waits Seen Due to Poorly
Tuned SQL

In some cases, the buffer cache may be sized too small. So make sure the
buffer cache is large enough or if using automatic memory management or
automatic shared memory management, make sure the SGA is sized correctly. For
further reading for automatic memory management or automatic shared memory
management, review following notes:

[Document
270065.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1970450.1&id=270065.1)
Use Automatic Shared Memory Management  
[Document
443746.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1970450.1&id=443746.1)
Automatic Memory Management (AMM) on 11g

To make sure the buffer cache is sized correctly, please review following
note:

[Document
754639.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1970450.1&id=754639.1)
How to Read Buffer Cache Advisory Section in AWR and Statspack Reports

**Note:** When tuning the buffer pool, avoid increasing the size of the buffer
cache for the use of additional buffers that contribute little or nothing to
the cache hit ratio. A common mistake is to continue increase the buffer cache
when doing full table scans or operations that do not use the buffer cache.

#### LIBRARY CACHE LATCHES

The library cache latches protect the cached SQL statements and objects'
definitions held in the library cache within the shared pool. The library
cache latch must be acquired in order to add a new statement to the library
cache. During a parse, Oracle searches the library cache for a matching
statement. If one is not found, then Oracle will parse the SQL statement,
obtain the library cache latch and insert the new SQL.

The first resource to reduce contention on this latch is to ensure that the
application is reusing as much SQL statements as possible. Use bind variables
whenever possible in the application. Misses on this latch may also be a sign
that the application is parsing SQL at a high rate and may be suffering from
too much parse CPU overhead.If the application is already tuned the  
SHARED_POOL_SIZE can be increased. Be aware that if the application is not
using the library cache appropriately, the contention might be worse with a
larger structure to be handled.

For further reading on tuning sqls, shared pool, and parameters related to the
library cache latches, review the following note:

[Document
62143.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1970450.1&id=62143.1)
Troubleshooting: Tuning the Shared Pool and Tuning Library Cache Latch
Contention

Known Issue:

[Document
9795214.8](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1970450.1&id=9795214.8)
Library Cache Memory Corruption / ORA-600 [17074] may result in Instance crash

#### LIBRARY CACHE PIN LATCH

The library cache pin latch must be acquired when a statement in the library
cache is re-executed. Misses on this latch occur when there is very high rate
of SQL execution. There is little that can be done to reduce the load on the
library cache pin latch, although using private rather than public synonyms or
direct object references such as OWNER.TABLE may help.If there is a blocking
scenario where one or two processes are being blocked by one process, the
reason for the process not releasing the pin needs to be determined if there
is general widespread waiting then the shared pool may need tuning. See:  
[](https://support.oracle.com/DocumentDisplay?parent=DOCUMENT&sourceId=444560.1&id=62143.1)

[Document
62143.1](https://support.oracle.com/DocumentDisplay?parent=DOCUMENT&sourceId=444560.1&id=62143.1)
Troubleshooting: Tuning the Shared Pool and Tuning Library Cache Latch
Contention

For more information see:

[Document
34579.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1970450.1&id=34579.1)
WAITEVENT: "library cache pin" Reference Note

#### SHARED POOL LATCHES

While the library cache latch protects operations within the library cache,
the shared pool latch is used to protect critical operations when allocating
and freeing memory in the shared pool. If an application makes use of literal
(unshared) SQL, then this can severely limit scalability and throughput. The
cost of parsing a new SQL statement is expensive both in terms of CPU
requirements and the number of times the library cache and shared pool latches
may need to be acquired and released.

Ways to reduce the shared pool latch are:

  * Avoid hard parses when possible, parse once, execute many.
  * Eliminate literal SQL so that same sql is shared by many sessions.
  * Size the shared_pool adequately to avoid reloads
  * Use of MTS (shared server option) also greatly influences the shared pool latch.

The following notes also explain how to identify and correct problems with the
shared pool and shared pool latch contention:

[Document
1477107.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1970450.1&id=1477107.1)
Resolving Issues Where 'Latch Shared Pool' Waits are Seen  
[Document
62143.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1970450.1&id=62143.1)
Troubleshooting: Tuning the Shared Pool and Tuning Library Cache Latch

Known Issue:

[Document
8363210.8](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1970450.1&id=8363210.8)
OERI [526] on logical standby for "shared pool" child latch

#### ROW CACHE OBJECTS LATCH

This latch comes into play when user processes are attempting to access the
cached data dictionary values.This latch protects the access of the data
dictionary cache in the SGA. When loading, referencing and freeing objects in
the data dictionary cache you need to get this latch.

Sometimes increasing the size of the shared pool (SHARED_POOL_SIZE) reduces
this wait.

For further reading, review following note:

[Document
1550722.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1970450.1&id=1550722.1)
WAITEVENT: "latch: row cache objects" Reference Note

#### REDOLOG BUFFER LATCHES

When a change to a data block needs to be done, it requires to create a redo
record in the redolog buffer executing the following steps:

  * Ensure that no other processes has generated a higher SCN
  * Find for space available to write the redo record. If there are not space available a the LGWR must write to disk or issue a log switch
  * Allocate the space needed in the redo log buffer
  * Copy the redo record to the log buffer and link it to the appropriate structures for recovery purposes.

**Note** : In general redo log buffer contention is not frequent problem
unless the latches already mentioned are consistently in the top wait events.
Experience usually shows redo IO throughput is the main culprit of redo
contention.

For more information on redo latches and their tuning see:

[Document
147471.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1970450.1&id=147471.1)
Redolog Buffer Cache and Resolving Redo Latch Contention

#### MUTEXES

Mutexes have replaced library cache latches for are a mechanism to control
access to memory structures. Mutexes were introduced in 10g as faster and
lightweight forms of latches and waits. If there is contention on mutexes you
may see waits for the following:

  * cursor: mutex X
  * cursor: mutex S
  * cursor: pin X
  * cursor: pin S
  * cursor: pin S wait on X
  * library cache: mutex X
  * library cache: mutex S

To read about the latches and how to resolve it, review following note:

[Document
1356828.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1970450.1&id=1356828.1)
FAQ: 'cursor: mutex ..' / 'cursor: pin ..' / 'library cache: mutex ..' Type
Wait Events  
[Document
1377998.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1970450.1&id=1377998.1)
Troubleshooting: Waits for Mutex Type Events  
  
  


---
### ATTACHMENTS
[278d42fd6821be402005247a226dd2f6]: media/FAQ_What_are_Latches_and_What_Causes_Latch_Contention_11g_and_Above_文档_ID_1970450.1)
[FAQ_What_are_Latches_and_What_Causes_Latch_Contention_11g_and_Above_文档_ID_1970450.1)](media/FAQ_What_are_Latches_and_What_Causes_Latch_Contention_11g_and_Above_文档_ID_1970450.1))
[ac61f294e518715dea9f20233b4fe340]: media/FAQ_What_are_Latches_and_What_Causes_Latch_Contention_11g_and_Above_文档_ID_1970450-2.1)
[FAQ_What_are_Latches_and_What_Causes_Latch_Contention_11g_and_Above_文档_ID_1970450-2.1)](media/FAQ_What_are_Latches_and_What_Causes_Latch_Contention_11g_and_Above_文档_ID_1970450-2.1))
[bd9e95b63d8f46971582cc466a9e317f]: media/FAQ_What_are_Latches_and_What_Causes_Latch_Contention_11g_and_Above_文档_ID_1970450-3.1)
[FAQ_What_are_Latches_and_What_Causes_Latch_Contention_11g_and_Above_文档_ID_1970450-3.1)](media/FAQ_What_are_Latches_and_What_Causes_Latch_Contention_11g_and_Above_文档_ID_1970450-3.1))
[d5d35f77d8ea056d93b7e5e81bc06876]: media/FAQ_What_are_Latches_and_What_Causes_Latch_Contention_11g_and_Above_文档_ID_1970450-4.1)
[FAQ_What_are_Latches_and_What_Causes_Latch_Contention_11g_and_Above_文档_ID_1970450-4.1)](media/FAQ_What_are_Latches_and_What_Causes_Latch_Contention_11g_and_Above_文档_ID_1970450-4.1))
[daa5f196d06f4043e1fd3fa65182754a]: media/FAQ_What_are_Latches_and_What_Causes_Latch_Contention_11g_and_Above_文档_ID_1970450-5.1)
[FAQ_What_are_Latches_and_What_Causes_Latch_Contention_11g_and_Above_文档_ID_1970450-5.1)](media/FAQ_What_are_Latches_and_What_Causes_Latch_Contention_11g_and_Above_文档_ID_1970450-5.1))
---
### NOTE ATTRIBUTES
>Created Date: 2018-01-22 02:53:12  
>Last Evernote Update Date: 2018-10-01 15:44:49  
>author: YangKwong  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT  
>source-url: &  
>source-url: sourceId=22908.1  
>source-url: &  
>source-url: id=1970450.1  
>source-url: &  
>source-url: _adf.ctrl-state=11dph05qcs_243  
>source-url: &  
>source-url: _afrLoop=153315641007401  