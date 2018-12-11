# How to Tell if the I/O of the Database is Slow (文档 ID 1275596.1)

  

|

|

 **In this Document**  

| |
[Goal](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323134869665184&id=1275596.1&_adf.ctrl-
state=4n68ptb5n_224#GOAL)  
---|---  
| [Ask Questions, Get Help, And Share Your Experiences With This
Article](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323134869665184&id=1275596.1&_adf.ctrl-
state=4n68ptb5n_224#aref_section11)  
---|---  
|
[Solution](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323134869665184&id=1275596.1&_adf.ctrl-
state=4n68ptb5n_224#FIX)  
---|---  
|
[Introduction](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323134869665184&id=1275596.1&_adf.ctrl-
state=4n68ptb5n_224#aref_section21)  
---|---  
| [What is
"Slow"?](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323134869665184&id=1275596.1&_adf.ctrl-
state=4n68ptb5n_224#aref_section22)  
---|---  
| [Response
time](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323134869665184&id=1275596.1&_adf.ctrl-
state=4n68ptb5n_224#aref_section23)  
---|---  
| [Types of
IO](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323134869665184&id=1275596.1&_adf.ctrl-
state=4n68ptb5n_224#aref_section24)  
---|---  
| [Read or
Write](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323134869665184&id=1275596.1&_adf.ctrl-
state=4n68ptb5n_224#aref_section25)  
---|---  
| [Single Block or
MultiBlock](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323134869665184&id=1275596.1&_adf.ctrl-
state=4n68ptb5n_224#aref_section26)  
---|---  
| [Synchronous or
Asynchronous.](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323134869665184&id=1275596.1&_adf.ctrl-
state=4n68ptb5n_224#aref_section27)  
---|---  
| [Expected thresholds for response
time](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323134869665184&id=1275596.1&_adf.ctrl-
state=4n68ptb5n_224#aref_section28)  
---|---  
| [IO Wait Outliers (Intermittent Short IO
Delays)](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323134869665184&id=1275596.1&_adf.ctrl-
state=4n68ptb5n_224#aref_section29)  
---|---  
| [Identifying IO Response
Time](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323134869665184&id=1275596.1&_adf.ctrl-
state=4n68ptb5n_224#aref_section210)  
---|---  
| [Sources in Oracle identifying Response Time
](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323134869665184&id=1275596.1&_adf.ctrl-
state=4n68ptb5n_224#aref_section211)  
---|---  
| [10046 Trace
File](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323134869665184&id=1275596.1&_adf.ctrl-
state=4n68ptb5n_224#aref_section212)  
---|---  
| [System State
Dump](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323134869665184&id=1275596.1&_adf.ctrl-
state=4n68ptb5n_224#aref_section213)  
---|---  
| [Statspack and AWR
reports](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323134869665184&id=1275596.1&_adf.ctrl-
state=4n68ptb5n_224#aref_section214)  
---|---  
| [Discuss Troubleshooting I/O
Contention](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323134869665184&id=1275596.1&_adf.ctrl-
state=4n68ptb5n_224#aref_section215)  
---|---  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323134869665184&id=1275596.1&_adf.ctrl-
state=4n68ptb5n_224#REF)  
---|---  
  
* * *

## Applies to:

Oracle Database - Enterprise Edition - Version 9.2.0.1 and later  
Oracle Database - Personal Edition - Version 9.2.0.1 and later  
Oracle Database - Standard Edition - Version 9.2.0.1 and later  
Information in this document applies to any platform.  

## Goal

This document outlines some of the thresholds whereby RDBMS Support may
consider IO to be slow and thus a potential reason for a performance problem.
It also looks into how to collect the supporting evidence from the RDBMS
perspective. It does not aim to provide diagnostics to understand why the IO
is slow nor does it provide any detailed explanation as to why slow IO may be
occurring.  
  
If the underlying cause for slow performance is found to be a result of slow
IO at the OS level, then the appropriate vendor responsible for the IO
subsystem (hardware and software) should be engaged to diagnose and correct
the situation.

### Ask Questions, Get Help, And Share Your Experiences With This Article

**Would you like to explore this topic further with other Oracle Customers,
Oracle Employees, and Industry Experts?**  
  
[Click here](https://community.oracle.com/message/12020515 "Discussion Thread:
Troubleshooting I/O Contention \[Document IDs 223117.1 & 1275596.1\]") to join
the discussion where you can ask questions, get help from others, and share
your experiences with this specific article.  
Discover discussions about other articles and helpful subjects by clicking
[here](https://community.oracle.com/community/support/oracle_database/database_tuning
"My Oracle Support Community - Database Tuning") to access the main _My Oracle
Support Community_ page for Database Tuning.

## Solution

### Introduction

The efficiency of IO may be measured in 2 ways :

  * **Response Time**   
Measured in milliseconds an operation takes to complete. This statistic is
gathered by Oracle.

  * **Throughput**  
Measured as the number of operations per unit of time. This is calculated
using OS tools for example iostat on Unix.

As this document concentrates on how to determine whether IO is slow from the
perspective of Oracle, we will not go into detail on throughput and how it is
measured. The following document describes how to install and use OS Watcher
in order to collect and archive iostat information as well as other OS
information:

[Document
301137.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1275596.1&id=301137.1)
OS Watcher User Guide

For help in troubleshooting see

[Document
223117.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1275596.1&id=223117.1)
Troubleshooting I/O-related waits

### What is "Slow"?

"Slow" is a very subjective term and depends largely upon the expectations of
the system and the hardware from the user. Users with Enterprise Storage
Systems may expect all IO requests to return in 10ms or less while individuals
with an old laptop computer using an external disk connected via an ancient
USB 1.0 interface may well have different expectations!

Additionally, end users will come to expect a certain level of response time
for their OLTP requests and reports. If the response time changes
dramatically, it could be due to a dramatic change in average IO response time
even though both old and new response times are less than what may be deemed
as the standard reasonable IO response time (e.g. degradation from 3ms to 9ms
may have a significant impact on application performance but IO may not be
considered 'slow' until time goes above 20ms). The reasons for the IO response
time change are varied, examples may include migrating from file system cache
to shared disk where there is no file system caching or changing of system
backup schedules such that its IO traffic overlaps with a batch job.

One of the ways that you can detect such changes is to record performance
statistics during periods of normal performance for comparison purposes when
performance issues are reported using a tool such as OS Watcher:

[Document
301137.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1275596.1&id=301137.1)
OS Watcher User Guide

### Response time

Hardware does not necessarily respond in a uniform fashion for each IO
request; there are always likely to be peaks and troughs. It is therefore
common to measure response time using an average.

Note: In order to mitigate the effects of high/low value anomalies, the size
of the sampled data set needs to be 'significant'. To this end, the number of
samples should be at least 1000 operations per hour in order to be considered
reliable and usable for decision making.

### Types of IO

The average response time is directly related to the type of IO:  

  * #### Read or Write

  * #### Single Block or MultiBlock

Single block IO, as suggested by its name, reads only one at a time.  
For example, when a session waits for a single-block IO it may typically wait
on the event "db file sequential read" to indicate that it is waiting for that
block to be delivered.  
  
Multi-Block operations read more than one block at a time ranging from 2 to
128 Oracle blocks depending on the size of the block and operating system
settings. Usually a multi-block request had a limit of 1Mb in size.  
For example when a session waits for a multi-block IO it may typically wait on
the event "db file scattered read" to indicate that it is waiting for those
blocks to be delivered.

  * #### Synchronous or Asynchronous.

Synchronous (Blocking) operations wait for the hardware to complete the
physical I/O, so that they can be informed of and manage appropriately the
success or failure of the operation (and to receive the results in the case of
a successful read). The execution of the process is blocked while it waits for
the results of the system call.  
  
With Asynchronous (Non-Blocking) operations the system call will return
immediately once the I/O request has been passed down to the hardware or
queued in the operating system (typically before the physical I/O operation
has even begun). The execution of the process is not blocked, because it does
not need to wait for the results of the system call. Instead, it can continue
executing and then receive the results of the I/O operation later, once they
are available.

### Expected thresholds for response time

A typical multi-block synchronous read of 64 x 8k blocks (512kB total) should
have an average of at most 20 milliseconds before worrying about 'slow IO'.
Smaller requests should be faster (10-20ms) whereas for larger requests, the
elapsed time should be no more than 25ms.

  * Asynchronous operations should be equally as fast as or faster than synchronous.
  * Single Block operations should be as fast as or faster than multi-block
  * 'log file parallel write', 'control file write' and 'direct path writes' waits should be no more than 15ms.

Data file writes are not as easy to measure as reads. DBWR writes blocks
asynchronously in batch ('db file parallel write' ) and there is currently no
criteria to sanction the response time. See:

[Document
34416.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1275596.1&id=34416.1)
WAITEVENT: "db file parallel write" Reference Note for more details.

Other wait events and statistics are used to reveal if DBWR (multiple or
single, with or without IO slaves) is fast enough to clean the dirty blocks.  
  
As a rule, times higher than those stated above should usually be investigated
as should any change for the worse noticed when comparing with previous
timings taken.  
  

**NOTE:** Just because a system is below these maximum thresholds does not
mean that there are no more available tuning opportunities.

  
Response Times will vary from system to system. As an example, the following
could be considered an acceptable average:  

> 10 ms for MultiBlock Synchronous Reads  
>  5 ms for SingleBlock Synchronous Reads  
>  3 ms for 'log file parallel write'

This is based on the premise that multiblock IO may require more IO subsystem
work than a single block IO and that, if recommendations are followed, redo
logs are likely to be on the fastest disks with no other concurrent activity.

### IO Wait Outliers (Intermittent Short IO Delays)

Even though the average IO wait time may be well in the accepted range, it is
possible that "hiccups" in performance may be due to a few IO wait outliers.  
In 12c the following views contain entries corresponding to I/Os that have
taken a long time (more than 500 ms)  
In 11g, the information in the Wait Event Histogram sections of the AWR report
may be useful in determining whether there are some IOs that are taking longer
than average  
Log write waits over 500ms are also written to the LGWR trace file  
  
For more information on outliers in 12C see:

Oracle Database Online Documentation 12c Release 1 (12.1)  
Database Administration  
Database Reference  
  
V$IO_OUTLIER  
<http://docs.oracle.com/database/121/REFRN/GUID-0DEB0604-8EFE-4829-8973-DCB3D94D25F3.htm#REFRN30673>  
  
V$LGWRIO_OUTLIER  
<http://docs.oracle.com/database/121/REFRN/GUID-6DB4FFC5-1587-4ADE-A79F-545BA90A07E5.htm#REFRN30674>  
  
V$KERNEL_IO_OUTLIER (only populated on
Solaris)[](https://docs.oracle.com/database/121/REFRN/refrn30673.htm#REFRN30673)  
<http://docs.oracle.com/database/121/REFRN/GUID-A4A1C17E-6D8A-4283-8054-8FB79D2F89D7.htm#REFRN30722>

### Identifying IO Response Time

Oracle records the response time of IO operations as the "Elapsed Time"
indicated in specific wait events and statistics."Response time" and "elapsed
time" are synonymous and interchangeable terms in this context.

Below is a list of some of the more popular wait events and their typical
acceptable wait times (not an exhaustive list)

Wait Event| R/W| Synchronous  
/Asynchronous| Singleblock/  
Multiblock| Elapsed Time  
(with 1000+ waits per hour)  
---|---|---|---|---  
control file parallel write |

Write

| Asynchronous | Multi | < 15ms  
control file sequential read |

Read

| Synchronous | Single | < 20 ms  
db file parallel read | Read | Asynchronous | Multi | < 20 ms  
db file scattered read | Read | Synchronous | Multi | < 20 ms  
db file sequential read | Read | Synchronous | Single | < 20 ms  
direct path read | Read | Asynchronous | Multi | < 20 ms  
direct path read temp | Read | Asynchronous | Multi | < 20 ms  
direct path write | Write | Asynchronous | Multi | < 15 ms  
direct path write temp | Write | Asynchronous | Multi | < 15 ms  
log file parallel write | Write | Asynchronous | Multi | < 15 ms  
|  |  |  |  
  
**Exadata Related**

|  |  |  |  
|  |  |  |  
cell smart table scan | Read | Asynchronous | Multi | < 1 ms  
cell single block physical read | Read | Synchronous | Single | < 1 ms  
cell multiblock physical read | Read | Synchronous | Multi | < 6 ms  
|  |  |  |  
|  |  |  |  
  
### Sources in Oracle identifying Response Time

#### 10046 Trace File

When level 8 or 12 is specified in the 10046 trace, wait events are included.
The response time is specified in the **ela** field. From 9i onwards the value
is specified in microseconds. In 8i and before the time is in is 1/100th
second (10ms).

WAIT #5: nam='cell single block physical read' **ela= 672**
cellhash#=2520626383 diskhash#=1377492511 bytes=16384 obj#=63
tim=1280416903276618  
  
672 microseconds = 0.672 ms

WAIT #5: nam='db file sequential read' **ela= 1018** file#=2 block#=558091
blocks=1 obj#=0 tim=10191852599110  
  
1018 microseconds = > 1.018 ms

  

#### System State Dump

For each process in a system state, the wait information is included among the
other process information. This will either show an active wait: "waiting for"
or a case where waiting is completed and the process is on CPU : "waited for"
/ "last wait for".

  * **"waiting for"**   
This means that the process is currently in a wait state.  
Prior to 11g the field to look at is "seconds since wait started" which shows
how long the process has been waiting on this wait event  
Starting 11gR1 the field to look at is "total" which is the total time elapsed
on this wait.  
  
If a process is indicated to be "waiting for" an IO related operation and
**"seconds since wait started" > **0 most likely this means that the IO got
"lost" and the session can be considered to be hanging. (since we have
mentioned previously that an average acceptable wait would be 20ms , any IO
wait of duration > 1 second is a cause for concern)

  * **"last wait for"** is relevant in versions prior to 11g and indicates a process that is no longer waiting (ie it is on CPU). The last wait is recorded and its wait time indicated in "wait_time" field. (In 11g, "last wait for" is replaced by "not in wait")  
  

last wait for 'db file sequential read' blocking sess=0x0 seq=100
wait_time=2264 seconds since wait started=0  
file#=45, block#=17a57, blocks=1  
  
2264 microseconds => 2.264 ms

  * **"waited for"** means the session is no longer waiting. This is used in systemstate trace starting from 11gR1.The field to look at is "total" indicating the total time waited.  
  

0: waited for 'db file sequential read' file#=9, block#=46526, blocks=1  
wait_id=179 seq_num=180 snap_id=1  
wait times: snap=0.007039 sec, exc=0.007039 sec, total=0.007039 sec  
wait times: max=infinite  
wait counts: calls=0 os=0  
  
0.007039 sec => 7.039 ms

#### Statspack and AWR reports

**Foreground and Background Wait Events**

These reports show sections detailing waits by both foreground and background
operations separately. The following is an example of such a section:  
  

    
    
                                                                 Avg
                                            %Time Total Wait    wait    Waits   % DB
    Event                             Waits -outs   Time (s)    (ms)     /txn   time
    -------------------------- ------------ ----- ---------- ------- -------- ------
    db file sequential read       2,354,428     0      8,256       4      2.6   21.2
    db file scattered read           23,614     0         48       2      0.0     .1
    
    

  
In this report, the average Response Time is shown by the Avg wait (ms) column
(Average Read in Milliseconds).  
  
**Tablespace IO Stats**  
  
The Tablespace section of these reports also gives useful information from the
tablespace perspective:  
  

    
    
    Tablespace                                                                      
    ------------------------------                                                  
                     Av       Av     Av                       Av     Buffer  Av Buf 
             Reads Reads/s  Rd(ms) Blks/Rd       Writes Writes/s      Waits  Wt(ms) 
    -------------- ------- ------- ------- ------------ -------- ---------- ------- 
    APPS_DATA                                                                       
         1,606,553     446     2.2     8.3       75,575       21     60,542     0.9 
                                                                                    
                           

  
Again the Read Response Time is indicated by the Av Rd (ms) column (Average
Read in Milliseconds).

**Wait Event Histogram**

The Wait event histogram section can provide useful information regarding the
spread of the write times that makes up the average. It can show if the
average is made up of many writes close to the average or if it is being
skewed by a few very large or small values:

    
    
                                                      % of Waits                  
                                     -----------------------------------------------
                               Total                                                
    Event                      Waits  <1ms  <2ms  <4ms  <8ms <16ms <32ms  <=1s   >1s
    -------------------------- ----- ----- ----- ----- ----- ----- ----- ----- -----
    db file parallel read       4139    .2    .5   2.5  26.4  23.5  15.0  31.9    .1
    db file parallel write      329K  88.5   4.0   2.1   1.9   2.3   1.1    .3    .0
    db file scattered read     14.4K  54.3   8.5   6.1  16.6  11.5   2.6    .4      

  
Each column indicates the percentage of wait events waited up to the time
specified between each bucket. For example the waits indicated under "<16ms"
are those that are greater than "8ms" but less than "16ms".

As long as the greatest percentage of waits are in the buckets from <1ms up to
16ms then the IO performance is generally acceptable.

**NOTE:** Remember to keep baseline STATSPACK or AWR when performance was
acceptable to compare the I/O statistics during the poor performance.

## Discuss Troubleshooting I/O Contention

**The window below is a live discussion of this article (not a screenshot). We
encourage you to join the discussion by clicking the "Reply" link below for
the entry you would like to provide feedback on. If you have questions or
implementation issues with the information in the article above, please share
that below.**

## References

[NOTE:223117.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1275596.1&id=223117.1)
\- Troubleshooting I/O Related Waits  
[NOTE:34558.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1275596.1&id=34558.1)
\- WAITEVENT: "db file scattered read" Reference Note  
[NOTE:34559.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1275596.1&id=34559.1)
\- WAITEVENT: "db file sequential read" Reference Note  
[NOTE:301137.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1275596.1&id=301137.1)
\- OSWatcher (Includes: [Video])  
[NOTE:34416.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1275596.1&id=34416.1)
\- WAITEVENT: "db file parallel write" Reference Note  
  
  
  


---
### NOTE ATTRIBUTES
>Created Date: 2017-07-05 01:22:59  
>Last Evernote Update Date: 2018-10-01 15:44:51  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323134869665184  
>source-url: &  
>source-url: id=1275596.1  
>source-url: &  
>source-url: _adf.ctrl-state=4n68ptb5n_224  