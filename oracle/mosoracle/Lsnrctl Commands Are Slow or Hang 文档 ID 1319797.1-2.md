#  Lsnrctl Commands Are Slow or Hang (文档 ID 1319797.1)

  

|

|

 **In this Document**  

| |
[Symptoms](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=328245316238260&id=1319797.1&_adf.ctrl-
state=bm60milh_927#SYMPTOM)  
---|---  
|
[Changes](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=328245316238260&id=1319797.1&_adf.ctrl-
state=bm60milh_927#CHANGE)  
---|---  
|
[Cause](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=328245316238260&id=1319797.1&_adf.ctrl-
state=bm60milh_927#CAUSE)  
---|---  
|
[Solution](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=328245316238260&id=1319797.1&_adf.ctrl-
state=bm60milh_927#FIX)  
---|---  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=328245316238260&id=1319797.1&_adf.ctrl-
state=bm60milh_927#REF)  
---|---  
  
* * *

## Applies to:

Oracle Net Services - Version 11.1.0.7 to 12.1.0.2 [Release 11.1 to 12.1]  
Microsoft Windows x64 (64-bit)  
Microsoft Windows (32-bit)  
This issue is limited to the Windows OS.  
***Checked for relevance on 17-JAN-2017***  
  

## Symptoms

  * The listener is hung or is extremely slow to respond. 
  * Tnspings to the listener take a very long time (seconds) to respond or the ping hangs completely. 
  * Lsnrctl utility commands are either hanging or slow to respond. 
  * ADR Diagnostics are enabled in this environment and the flat file TNSListener log file is at or approaching the size of 4 gigabytes. 

  
Check this location: **$ORACLE_BASE\diag\tnslsnr\ <hostname>\listener\trace\  
**  
The listener.log might contain messages similar to the following DBGRL error
being repeated throughout:  
  

DBGRL Error: SLERC_OERC, 48180

  
  
Also, on Windows 32-bit, you may find the following errors reported when
attempting to check services or connect through the listener:  
  

TNS-12571: TNS:packet writer failure  
TNS-12560: TNS:protocol adapter error  
TNS-00530: Protocol adapter error  
32-bit Windows Error: 54: Unknown error

  
The lsnrctl utility might return the following error stack when checking the
status of the listener:  
  
  

LSNRCTL> status listener  
Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=oracle)(PORT=1521)))  
TNS-12547: TNS:lost contact  
TNS-12560: TNS:protocol adapter error  
TNS-00517: Lost contact  
64-bit Windows Error: 54: Unknown error

  
Or the lsnrctl status command might hang altogether. i.e. Returns no response.  
  

## Changes

No recent changes have taken place on this server. It is likely that this
installation has been in place for some time as the listener.log has grown to
at or near 4G in size. It is also likely that ADR diagnostic for the listener
is enabled on this server. i.e. No DIAG_ADR_<listener_name>=OFF in
listener.ora.

## Cause

The listener.log has reached the file size limit (on Windows) of 4G. This
issue is described in published bug:  
  

[Bug:9879101](https://support.oracle.com/epmos/faces/BugDisplay?parent=DOCUMENT&sourceId=1319797.1&id=9879101)
THE CONNECT THROUGH LISTENER WAS SLOW WHEN LISTENER LOG GREW to 4GB

See also: [Note:
9497965.8](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1319797.1&id=9497965.8)
\- Win: Listener Startup Fails Due to listener.log Size is Greater Than 4GB  
  

## Solution

You can solve this problem by deleting the large listener in
$ORACLE_BASE\diag\tnslsnr\<hostname>\listener\trace\<listener_name>.log

**1)** Stop the listener process using the command line or Control Panel
Service.  
  
 **2)** Delete the log file(s) that are at or approaching the 4G size limit at
this location:

$ORACLE_BASE\diag\tnslsnr\<hostname>\listener\trace\<listener_name>.log

**3)** Issue any lsnrctl command and you will see a new listener.log in its
place under:

$ORACLE_BASE\diag\tnslsnr\<hostname>\listener\trace\  
  

Since ADR Diagnostics are enabled for this listener these steps cannot be done
dynamically using the lsnrctl utility.  
e.g.

LSNRCTL>set log_file mylog

Will yield: TNS-01251: Cannot set trace/log directory under ADR.  
  
However, it is possible to disable the flat file listener logging using the
following commands:  
  
LSNRCTL>set current_listener <listener_name>  
LSNRCTL>set log_status OFF  
LSNRCTL>save_config  
  
This will prevent this issue from arising in the future. This also stop the
ADR logging.

## References

[BUG:9879101](https://support.oracle.com/epmos/faces/BugDisplay?parent=DOCUMENT&sourceId=1319797.1&id=9879101)
\- THE CONNECT THROUGH LISTENER WAS SLOW WHEN LISTNER LOG GROWED 4GB  
[BUG:9497965](https://support.oracle.com/epmos/faces/BugDisplay?parent=DOCUMENT&sourceId=1319797.1&id=9497965)
\- STARTUP LISTENER WITH SERVICE FAILED WITH LISTENER.LOG GROWED MORE THAN 4GB  
  
  
  



---
### TAGS
{listener_log}

---
### NOTE ATTRIBUTES
>Created Date: 2017-07-21 03:07:43  
>Last Evernote Update Date: 2017-07-21 03:08:15  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=328245316238260  
>source-url: &  
>source-url: id=1319797.1  
>source-url: &  
>source-url: _adf.ctrl-state=bm60milh_927  