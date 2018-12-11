# FAQ: What are Latches and What Causes Latch Contention (Pre-11g) (文档 ID
22908.1)

  

|

|

## Applies to:

Oracle Database - Personal Edition - Version 7.2.2.0 to 10.2.0.5 [Release
7.2.2 to 10.2]  
Oracle Database - Standard Edition - Version 7.2.2.0 to 10.2.0.5 [Release
7.2.2 to 10.2]  
Oracle Database - Enterprise Edition - Version 7.2.2.0 to 10.2.0.5 [Release
7.2.2 to 10.2]  
Information in this document applies to any platform.  

## Purpose

For advice on later versions, refer to:

[Document
1970450.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=1970450.1)
FAQ: What are Latches and What Causes Latch Contention (11g and Above)

The Oracle RDBMS makes use of different types of locking mechanisms. These are
mainly latches, enqueues, distributed locks and global locks (used in RAC).  
  
This bulletin focuses on latches. It attempts to give a clear understanding of
how latches are implemented in Oracle RDBMS and the causes behind latch
contention.  
The information provided can be used in tuning the various kinds of latches
discussed.

## Questions and Answers

### **FAQ: What are Latches and What Causes Latch Contention**

    * [What is a latch?](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153217895992671&id=22908.1&_adf.ctrl-state=11dph05qcs_186#LATCH)
    * [What is the difference between Latches and Enqueues?](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153217895992671&id=22908.1&_adf.ctrl-state=11dph05qcs_186#LATCH_DIFF)
    * [What is the difference between Latches and Mutexes?](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153217895992671&id=22908.1&_adf.ctrl-state=11dph05qcs_186#LATCH_MUTEX)
    * [When is a latch obtained?](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153217895992671&id=22908.1&_adf.ctrl-state=11dph05qcs_186#LATCH_WHEN)
    * [What are the possible latch request modes?](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153217895992671&id=22908.1&_adf.ctrl-state=11dph05qcs_186#LATCH_MODE)
    * [What causes latch contention?](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153217895992671&id=22908.1&_adf.ctrl-state=11dph05qcs_186#LATCH_CAUSE)
    * [How to identify contention for latches](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153217895992671&id=22908.1&_adf.ctrl-state=11dph05qcs_186#LATCH_IDENT)
    * [How to calculate latch hit ratio](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153217895992671&id=22908.1&_adf.ctrl-state=11dph05qcs_186#LATCH_HIT)
    * [Useful SQL scripts to get latch information](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153217895992671&id=22908.1&_adf.ctrl-state=11dph05qcs_186#LATCH_SCRIPTS)  

      * [Display System-wide latch statistics](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153217895992671&id=22908.1&_adf.ctrl-state=11dph05qcs_186#LATCH_STATS)
      * [Find out the latch name for a latch address](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153217895992671&id=22908.1&_adf.ctrl-state=11dph05qcs_186#LATCH_NAME)
      * [Display latch statistics by latch name](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153217895992671&id=22908.1&_adf.ctrl-state=11dph05qcs_186#LATCH_NAMESTATS)
    * [Latches that are of most concern to the DBA](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153217895992671&id=22908.1&_adf.ctrl-state=11dph05qcs_186#LATCH_WHICH)  

      * [BUFFER CACHE LATCHES](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153217895992671&id=22908.1&_adf.ctrl-state=11dph05qcs_186#LATCH_BC)  

        * [Cache buffers chains latch](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153217895992671&id=22908.1&_adf.ctrl-state=11dph05qcs_186#LATCH_CBC)
        * [Cache buffers LRU chain latch ](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153217895992671&id=22908.1&_adf.ctrl-state=11dph05qcs_186#LATCH_CBLRU)
      * [LIBRARY CACHE LATCHES](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153217895992671&id=22908.1&_adf.ctrl-state=11dph05qcs_186#LATCH_LC)  

        * [Library cache latch](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153217895992671&id=22908.1&_adf.ctrl-state=11dph05qcs_186#LATCH_LCL)
        * [Library cache pin latch](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153217895992671&id=22908.1&_adf.ctrl-state=11dph05qcs_186#LATCH_LCP)
      * [SHARED POOL LATCHES](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153217895992671&id=22908.1&_adf.ctrl-state=11dph05qcs_186#LATCH_SP)  

        * [Shared pool latch](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153217895992671&id=22908.1&_adf.ctrl-state=11dph05qcs_186#LATCH_SPL)
        * [Row cache objects latch](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153217895992671&id=22908.1&_adf.ctrl-state=11dph05qcs_186#LATCH_RC)
      * [REDOLOG BUFFER LATCHES](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153217895992671&id=22908.1&_adf.ctrl-state=11dph05qcs_186#LATCH_REDO)  

        * [Redo Copy latch](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153217895992671&id=22908.1&_adf.ctrl-state=11dph05qcs_186#LATCH_REDO_C)
        * [Redo allocation latch](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153217895992671&id=22908.1&_adf.ctrl-state=11dph05qcs_186#LATCH_REDO_A)
        * [Redo writing latch](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153217895992671&id=22908.1&_adf.ctrl-state=11dph05qcs_186#LATCH_REDO_W)
    * [Tuning SPIN_COUNT](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153217895992671&id=22908.1&_adf.ctrl-state=11dph05qcs_186#LATCH_SC)

**Note:** It is important to understand that it is neither practical nor
possible to provide specific values for the init.ora parameters discussed in
this bulletin. The values for these parameters vary from database to database
and from platform to platform. Moreover, for the same database and platforms,
they may vary from application to application.  
  
Before using any of the underscore (undocumented) parameters discussed in this
document, please open a Service Request.

    * ### **What is a latch?**

Latches are low level serialization mechanisms used to protect shared data
structures in the SGA. The implementation of latches is operating system
dependent, particularly in regard to whether a process will wait for a latch
and for how long.  

A latch is a type of a lock that can be very quickly acquired and freed.
Latches are typically used to prevent more than one process from executing the
same piece of code at a given time. Associated with each latch is a cleanup
procedure that will be called if a process dies while holding the latch.  
  
Latches have an associated level that is used to prevent deadlocks. Once a
process acquires a latch at a certain level it cannot subsequently acquire a
latch at a level that is equal to or less than that level (unless it acquires
it nowait).

    * ### **What is the difference between Latches and Enqueues?**

Enqueues are another type of locking mechanism used in Oracle.An enqueue is a
more sophisticated mechanism which permits several concurrent processes to
have varying degree of sharing of "known" resources. Any object which can be
concurrently used, can be protected with enqueues. A good example is of locks
on tables. We allow varying levels of sharing on tables e.g.  
Two processes can lock a table in share mode or in share update mode etc.  
  
One difference between a latch and an enqueue is that the enqueue is obtained
using an OS specific locking mechanism whereas a latch is obtained independent
of the OS An enqueue allows the user to store a value in the lock (i.e the
mode in which we are requesting it). The OS lock manager keeps track of the
resources locked. If a process cannot be granted the lock because it is
incompatible with the mode requested and the lock is requested with wait, the
OS puts the requesting process on a wait queue which is serviced in FIFO.  
  
Another difference between latches and enqueues is that in latches there is no
ordered queue of waiters like in enqueues. Latch waiters may either use timers
to wakeup and retry or they may spin (only in multiprocessors). Since all
waiters are concurrently retrying (depending on the scheduler), anyone might
get the latch and conceivably the first one attempting to obtain the latch
might be the last one to actually get it.  
 **  
**

    * ****

### ****What is the difference between Latches and Mutexes?****

In 10g, mutexes were introduced for certain operations in the library cache.  
Mutexes are a lighter-weight and more granular concurrency mechanism than
latches and take advantage of CPU architectures that offer the compare and
swap instructions (or similar). Mutexes like latches ensure that certain
operations are properly managed for concurrency. E.g., if one session is
changing a data structure in memory, then another session must wait to acquire
the mutex before it can make a similar change - this prevents unintended
changes that would lead to corruptions or crashes if not serialized.  
  

    * ### **When is a latch obtained?**

A process acquires a latch when working with a structure in the SGA.(System
Global Area). It continues to hold the latch for the period of time it works
with the structure. The latch is dropped when the process is finished with the
structure. Each latch protects a different set of data, identified by the name
of the latch.

Oracle uses atomic instructions like "test and set" for operating on
latches.Processes waiting to execute a part of code for which a latch has
already been obtained by some other process will wait until the latch is
released. Examples are redo allocation latches, copy latches, archive control
latch etc. The basic idea is to block concurrent access to shared data
structures. Since the instructions to  
set and free latches are atomic, the OS guarantees that only one process gets
it. Since it is only one instruction, it is quite fast.

Latches are held for short periods of time and provide a mechanism for cleanup
in case a holder dies abnormally while holding it. This cleaning is done using
the services of PMON. **  
**

  * **What are the possible latch request modes?**

Latch requests can be made in two modes:

      * willing-to-wait   
A "willing-to-wait" mode request will loop, wait, and request again until the
latch is obtained.  
Examples of "willing-to-wait" latches are: shared pool and library cache
latches

      * no wait  
In "no wait" mode the process will request the latch and if it is not
available, instead of waiting, another one is requested. Only when all fail
does the server process have to wait.  
An example of "no wait" latch is the redo copy latch

  * **What causes latch contention?**

If a required latch is busy, the process requesting it spins, tries again and
if still unavailable, spins again. The loop is repeated up to a maximum number
of times determined by the hidden initialization parameter _SPIN_COUNT. The
default value of the parameter is automatically adjusted when the machine's
CPU count changes provided that the default was used. If the parameter was
explicitly set then there is no change. It is not usually recommended to
change the default value for this parameter.

  
  

If after this entire loop, the latch is still not available, the process must
yield the CPU and go to sleep. Initially it sleeps for one centisecond. This
time is doubled in every subsequent sleep. This causes a slowdown to occur and
results in additional CPU usage,until a latch is available. The CPU usage is a
consequence of the "spinning" of the process. "Spinning" means that the
process continues to look for the availability of the latch after certain
intervals of time, during which it sleeps.

  * **How to identify contention for latches?**

Relevant data dictionary views to query are:

      * V$LATCH  
Shows aggregate latch statistics for both parent and child latches, grouped by
latch name. Individual parent and child latch statistics are broken down in
the views:  

        * V$LATCH_PARENT
        * V$LATCH_CHILDREN
  
Key information in these views is:  
  

        * GETS - Number of successful willing-to-wait requests for a latch.
        * MISSES - Number of times an initial willing-to-wait request was unsuccessful
        * SLEEPS - Number of times a process waited for requested a latch after an initial wiling-to-wait request.
        * IMMEDIATE_GETS - Number of successful immediate requests for each latch.
        * IMMEDIATE_MISSES Number of unsuccessful immediate requests for each latch.
      * V$LATCHNAME  
contains information about decoded latch names for the latches shown in
V$LATCH  
Oracle versions might differ in the latch# assigned to the existing latches.In
order to obtain information for the specific version query as follows:  
  

column name format a40 heading 'LATCH NAME'  
select latch#, name from v$latchname;

      * V$LATCHHOLDER  
contains information about the current latch holders.

  * **How to calculate latch hit ratio**

To get the hit ratio for latches apply the following formula:

"willing-to-wait" Hit Ratio = (GETS-MISSES)/GETS  
"no wait" Hit Ratio = (IMMEDIATE_GETS-IMMEDIATE_MISSES)/IMMEDIATE_GETS

This number should be close to 1. If not, tune according to the latch name

**  
**

  * **Useful SQL scripts to get latch information**

  * **Display System-wide latch statistics**

column name format A32 truncate heading "LATCH NAME"  
column pid heading "HOLDER PID"  
  
select c.name,a.addr,a.gets,a.misses,a.sleeps,a.immediate_gets,  
a.immediate_misses,b.pid  
from v$latch a, v$latchholder b, v$latchname c  
where a.addr = b.laddr(+) and a.latch# = c.latch#  
order by a.latch#;

  * **Find out the latch name for a latch address**

column name format a64 heading 'Name'  
  
select a.name from v$latchname a, v$latch b  
where b.addr = '&addr'  
and b.latch#=a.latch#;

  * **Display latch statistics by latch name**

column name format a32 heading 'LATCH NAME'  
column pid heading 'HOLDER PID'  
select c.name,a.addr,a.gets,a.misses,a.sleeps, a.immediate_gets,  
a.immediate_misses,b.pid  
from v$latch a, v$latchholder b, v$latchname c  
where a.addr = b.laddr(+) and a.latch# = c.latch#  
and c.name like '&latch_name%' order by a.latch#;

  
  

###

  * **Latches that are of most concern to the DBA**

  * BUFFER CACHE LATCHES

There are two main latches that protect data blocks in the buffer cache.
Contention for these two latches is usually seen when a database has high I/O
rates. We can reduce contention for these latches and tune them by adjusting
certain init.ora parameters.

  * Cache buffers chains latch

This latch is acquired whenever a block in the buffer cache is accessed
(pinned).Reducing contention for the cache buffer chains latch will usually
require reducing logical I/O rates by tuning and minimizing the I/O
requirements of the SQL involved. High I/O rates could be a sign of a hot
block (meaning a block highly accessed).

  
  

See [Note
163424.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=163424.1)
How To Identify a Hot Block Within The Database Buffer Cache to correctly
identify this issue.

  
  

You may be able to reduce the load on the cache buffer chain latches by
increasing the configuration parameter _DB_BLOCK_HASH_BUCKETS that represents
the number of 'hash buckets' or chains in the buffer cache.The buffers in the
SGA are located by hashing the required DBA by this number to get to a hash
chain. The chain is then scanned for buffers of the required DBA. It is not
recommended to change this parameter without careful benchmarking of the
effects

and it should not be necessary to make any changes in the latest versions of
Oracle.

  * Cache buffers LRU chain latch

The cache buffer lru chain latch is acquired in order to introduce a new block
into the buffer cache and when writing a buffer back to disk, specifically
when trying to scan the LRU (least recently used) chain containing all the
dirty blocks in the buffer cache.

  
  

Its possible to reduce contention for the cache buffer lru chain latch by
increasing the size of the buffer cache and thereby reducing the rate at which
new blocks are introduced into the buffer cache. The size of the buffer cache
is determined setting the parameter

[DB_CACHE_SIZE](http://download.oracle.com/docs/cd/B19306_01/server.102/b14237/initparams043.htm#sthref127)

.

  
  
_Note:_

when tuning the buffer pool, avoid increasing the size of the buffer cache for
the use of additional buffers that contribute little or nothing to the cache
hit ratio. A common mistake is to continue increase the buffer cache when
doing full table scans or operations that do not use the buffer cache.
Multiple buffer pools can help reduce contention on this latch.You can create
additional cache buffer lru chain latches by adjusting the configuration
parameter

[DB_BLOCK_LRU_LATCHES](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=39017.1)

.

  
  

  * LIBRARY CACHE LATCHES

  * Library cache latch

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

[SHARED_POOL_SIZE](http://download.oracle.com/docs/cd/B19306_01/server.102/b14237/initparams197.htm#sthref600)

can be increased. Be aware that if the application is not using the library
cache appropriately, the contention might be worse with a larger structure to
be handled.

The hidden parameter _KGL_LATCH_COUNT controls the number of library cache
latches. The default value should be adequate, but if contention for the
library cache latch cannot be resolved, it one may consider increasing this
value. The default value for _KGL_LATCH_COUNT is the next prime number after
CPU_COUNT. This value cannot exceed 67.

  
  

  * Library cache pin latch

The library cache pin latch must be acquired when a statement in the library
cache is re-executed. Misses on this latch occur when there is very high rate
of SQL execution. There is little that can be done to reduce the load on the
library cache pin latch, although using private rather than public synonyms or
direct object references such as OWNER.TABLE may help. For more information
see:  

[Document
34579.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=34579.1)
WAITEVENT: "library cache pin" Reference Note

  * SHARED POOL LATCHES

  * Shared pool latch

While the library cache latch protects operations withing the library cache,
the shared pool latch is used to protect critical operations when allocating
and freeing memory in the shared pool.

If an application makes use of literal (unshared) SQL then this can severely
limit scalability and throughput. The cost of parsing a new SQL statement is
expensive both in terms of CPU requirements and the number of times the
library cache and shared pool latches may need to be acquired and released.
Before Oracle9, there was just one such latch for the entire database to
protect the allocation of memory in the library cache. In Oracle9, multiple
children were introduced to relieve contention on this resource.

Ways to reduce the shared pool latch are:

      * Avoid hard parses when possible, parse once, execute many.
      * Eliminate literal SQL so that same sql is shared by many sessions.
      * Size the shared_pool adequately to avoid reloads
      * Use of MTS (shared server option) also greatly influences the shared pool latch.   
  

The following notes explain how to identify and correct problems with the
shared pool and shared pool latch contention:

[Document
1477107.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=1477107.1)
Resolving Issues Where 'Latch Shared Pool' Waits are Seen

  

[Document
62143.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=62143.1)
Troubleshooting: Tuning the Shared Pool and Tuning Library Cache Latch

  * Row cache objects latch

This latch comes into play when user processes are attempting to access the
cached data dictionary values.This latch protects the access of the data
dictionary cache in the SGA. When loading, referencing and freeing objects in
the data dictionary cache you need to get this latch.

It is not common to have contention in this latch and the only way to reduce
contention for this latch is by increasing the size of the shared pool
(SHARED_POOL_SIZE).

  
  

  * REDOLOG BUFFER LATCHES

When a change to a data block needs to be done, it requires to create a redo
record in the redolog buffer executing the following steps:

  
  

      * Ensure that no other processes has generated a higher SCN
      * Find for space available to write the redo record. If there are not space available a the LGWR must write to disk or issue a log switch
      * Allocate the space needed in the redo log buffer
      * Copy the redo record to the log buffer and link it to the appropriate structures for recovery purposes.
The database has three redo latches to handle this process:

  
  

  * Redo Copy latch

The redo copy latch is acquired for the whole duration of the process
described above. It is only released when a log switch is generated to release
free space and re-acquired once the log switch ends.

  
  

  * Redo allocation latch

The redo allocation latch is acquired to allocate memory space in the log
buffer. Before Oracle9.2, the redo allocation latch is unique and thus
serializes the writing of entries to the log buffer cache of the SGA. From
Oracle 9.2, multiple redo allocation latches become possible by setting the
init.ora parameter LOG_PARALLELISM. The log buffer is split into multiple
LOG_PARALLELISM areas that each have a size of LOG_BUFFER. The allocation job
of each area is protected by a specific redo allocation latch.

  
  

The redo allocation latch allocates space in the log buffer cache for each
transaction entry. If transactions are small, or if there is only one CPU on
the server, then the redo allocation latch also copies the transaction data
into the log buffer cache. If a logswitch is needed to get free space this
latch is released as well with the redo copy latch.

  
  

  * Redo writing latch

This unique latch prevent multiple processes posting the LGWR process
requesting log switch simultaneously. A process that needs free space must
acquire the latch before deciding whether to post the LGWR to perform a write,
execute a log switch or just wait.

  
  

For more information on redo latches and their tuning see:

[Note
147471.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=147471.1)
Redolog Buffer Cache and Resolving Redo Latch Contention

  
  

###

  * **Tuning SPIN_COUNT**

Tuning spin_count only applies to earlier versions. There should not normally
be a reason to alter this parameter in later versions.

  
  
[SPIN_COUNT](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=30832.1)

controls how many times the process will re-try to obtain the latch before
backing off and going to sleep. This basically means the process is in a tight
CPU loop continually trying to get the latch for SPIN_COUNT attempts. On a
single CPU system if an Oracle process tries to acquire a latch but it is held
by someone else the process will release the CPU and go to sleep for a short
period before trying again. However, on a multi processor system (SMP) it is
possible that the process holding the latch is running on one of the other
CPUs and so will potentially release the latch in the next few instructions
(latches are usually held for only very short periods of time).

  
  

Performance can be adjusted by changing the value of SPIN_COUNT. If a high
value is used, the latch will be attained sooner than if you use a low value.
However, you may use more CPU time spinning to get the latch if you use a high
value for SPIN_COUNT. You can decrease this probability of session sleeps by
increasing the value of the configuration parameters SPIN_COUNT (Oracle 8.0)
or _LATCH_SPIN_COUNT (Oracle 7). From 8i the parameter _SPIN_COUNT is a hidden
parameter.

  
  

This parameter controls the number of attempts the session will make to obtain
the latch before sleeping. Spinning on the latch consumes CPU, so if you
increase this parameter, you may see an increase in your systems overall CPU
utilization. If your computer is near 100% CPU and your application is
throughput rather than response time driven, you could consider decreasing
SPIN_COUNT in order to conserve CPU. Adjusting SPIN_COUNT is trial and error.
In general, only increase SPIN_COUNT if there are enough free CPU resources
available on the system, and decrease it only if there is no spare CPU
capacity.

  
  

To summarize latch sleeps and spin count, if you encounter latch contention
and have spare CPU capacity, consider increasing the value of SPIN_COUNT. If
CPU resources are at full capacity, consider decreasing the value of
SPIN_COUNT.

## References

[NOTE:163424.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=163424.1)
\- How to Identify Hot Blocks Within the Database Buffer Cache that may be
Associated with 'latch: cache buffers chains' Wait Contention  
[NOTE:30832.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=30832.1)
\- Init.ora Parameter "SPIN_COUNT" Reference Note  
[NOTE:34579.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=34579.1)
\- WAITEVENT: "library cache pin" Reference Note  
[NOTE:147471.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=147471.1)
\- Tuning the Redolog Buffer Cache and Resolving Redo Latch Contention  
  
[NOTE:39017.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=39017.1)
\- Init.ora Parameter "DB_BLOCK_LRU_LATCHES" Reference Note  
[NOTE:1342917.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=1342917.1)
\- Troubleshooting 'latch: cache buffers chains' Wait Contention  
[NOTE:62143.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=22908.1&id=62143.1)
\- Troubleshooting: Tuning the Shared Pool and Tuning Library Cache Latch
Contention  
  
  
---  
  
  


---
### NOTE ATTRIBUTES
>Created Date: 2018-01-22 02:53:38  
>Last Evernote Update Date: 2018-10-01 15:59:04  
>author: YangKwong  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153217895992671  
>source-url: &  
>source-url: id=22908.1  
>source-url: &  
>source-url: _adf.ctrl-state=11dph05qcs_186  