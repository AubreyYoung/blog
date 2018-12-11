# RMAN recover database fails RMAN-6025 - v$archived_log.next_change# is
281474976710655 (文档 ID 238422.1)

  

|

|

|  _This document is being delivered to you via Oracle Support's Rapid
Visibility (RaV) process and therefore has not been subject to an independent
technical review. ___  
---  
  
## Applies to:

Oracle Database - Standard Edition - Version 9.0.1.0 to 11.2.0.2.0 [Release
9.0.1 to 11.2]  
Oracle Database - Enterprise Edition - Version 9.0.1.0 to 11.2.0.2.0 [Release
9.0.1 to 11.2]  
Information in this document applies to any platform.  
RMAN recovery fails:  
  
  

## Symptoms

RMAN database recover fails:

RMAN-00571: ===========================================================  
RMAN-00569: =============== ERROR MESSAGE STACK FOLLOWS ===============  
RMAN-00571: ===========================================================  
RMAN-03002: failure of recover command at 05/17/2010 10:22:51  
RMAN-06053: unable to perform media recovery because of missing log  
RMAN-06025: no backup of log thread 1 seq 2668 lowscn 1079975830 found to
restore

  
The archivelog being requested is very old compared to current log sequence.  
Inspection of V$ARCHIVED_LOG shows:

CREATOR REGISTR SEQ# FIRST_CHANGE# NEXT_CHANGE# NAME  
\------- ------- -------------------- --------------------
-------------------- --------------------  
RMAN RMAN 2668 1079861514 281474976710655
+RECO/irisdb/onlinelog/group_3.4508.718549667

To confirm if you have hit the same problem run this query against the
controlfile :

SQL> select thread#, sequence#, creator, registrar, archived,  
to_char(first_change#), to_char(next_change#), name  
from v$archived_log  
where archived='NO';

If you are using a catalog and the above query returns no rows then check the
catalog:

  
SQL>select * from rc_database;  
== note the dbinc_key of your target  
  
SQL> select thread#, sequence#, creator, archived,  
to_char(first_change#), to_char(next_change#), name  
from rc_archived_log  
where archived='NO' and dbinc_key=<your dbinc_key>;

## Cause

V$ARCHIVED_LOG or RC_ARCHIVED_LOG contains entries for online redo log files.  
Online redo logs are temporarily cataloged by RMAN as 'archived logs' during  
FULL media recovery; they are removed from the AL table when media  
recovery completes successfully. One of the online redo logs will be 'current'  
at the time so the SCN range for this log when cataloged will be low_SCN to
281474976710655 (FFFFFFFFFFFF(hex)). When media recovery completes, these
online entries in v$archived_log/rc_archived_log are deleted automatically by
RMAN. If media recovery fails and recovery is completed via SQLPlus, these
entries in AL table are not removed.  
  
During any subsequent recovery exercise, if the start SCN for recovery is  
greater than the low_SCN of any of the cataloged online redo logs, the one
with  
an infinite next_SCN value will always be chosen as it will always fall within  
the SCN range calculated for recovery - but this 'archived log' does not
really exist so RMAN fails.

## Solution

There is no easy solution if a catalog is not used - register the target in a
catalog first and then proceed as shown below.

Take a backup of the recovery catalog BEFORE deleting the following rows:

SQL>select * from rc_database;

== Note the dbinc_key for your target database

SQL> delete from al  
where dbinc_key = <dbinc_key>  
and archived = 'N';  
SQL> commit;

    
    
       
  
  



---
### TAGS
{rman}

---
### NOTE ATTRIBUTES
>Created Date: 2017-07-05 01:21:44  
>Last Evernote Update Date: 2018-10-01 15:59:05  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323079426736647  
>source-url: &  
>source-url: id=238422.1  
>source-url: &  
>source-url: _adf.ctrl-state=4n68ptb5n_167  