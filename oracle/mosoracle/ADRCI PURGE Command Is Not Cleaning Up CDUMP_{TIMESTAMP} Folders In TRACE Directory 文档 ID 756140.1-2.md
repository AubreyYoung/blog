# ADRCI PURGE Command Is Not Cleaning Up CDUMP_{TIMESTAMP} Folders In TRACE
Directory (文档 ID 756140.1)

  

 **In this Document**  

| |
[Symptoms](https://support.oracle.com/epmos/faces/SearchDocDisplay?_adf.ctrl-
state=11jlj9x84n_9&_afrLoop=274600870306934#SYMPTOM)  
---|---  
| [Cause](https://support.oracle.com/epmos/faces/SearchDocDisplay?_adf.ctrl-
state=11jlj9x84n_9&_afrLoop=274600870306934#CAUSE)  
---|---  
|
[Solution](https://support.oracle.com/epmos/faces/SearchDocDisplay?_adf.ctrl-
state=11jlj9x84n_9&_afrLoop=274600870306934#FIX)  
---|---  
|
[References](https://support.oracle.com/epmos/faces/SearchDocDisplay?_adf.ctrl-
state=11jlj9x84n_9&_afrLoop=274600870306934#REF)  
---|---  
  
* * *

## Applies to:

Oracle Database - Enterprise Edition - Version 11.1.0.6 to 11.1.0.6 [Release
11.1]  
Information in this document applies to any platform.  
Oracle Server Enterprise Edition - Version: 11.1.0.6  
  
  

## Symptoms

For this article there are no symptoms in terms of errors seen in alert or
within the session.  
  
Instead for this article to be applicable the user will be trying to delete
folders using the ADRCI tool under Oracle11g 11.1.0.6, the problem is only
seen on this particular release and is resolved in the 11.1.0.7 patchset.  
  
There is no clear documentation to show how such directories can be removed
using ADRCI so to demonstrate the problem and solution an example is now
provided. The example is specific to a particular machine/instance so cannot
be simulated by a testcase. The purpose of the example is simply to highlight
syntax and usage of ADRCI:  
  
a) navigate to the directory containing the instance trace information:

cd /app/oracle/diag/rdbms/v1116u/V1116U/trace

  
The path will depend on the installation. If unsure of on the location, issue
the following query against the database instance:

SELECT VALUE FROM V$DIAG_INFO WHERE NAME LIKE 'Diag Trace%';

  
b) At the OS command prompt issue the directory listing command, like in:

$ ls -ltr | grep cdmp  
  
drwxr-xr-x 2 oracle dba 4096 Nov 11 11:54 cdmp_20081111115441/  
drwxr-xr-x 2 oracle dba 4096 Nov 13 09:10 cdmp_20081113091031/  
drwxr-xr-x 2 oracle dba 4096 Nov 20 11:23 cdmp_20081120112348/  
drwxr-xr-x 2 oracle dba 4096 Nov 27 06:52 cdmp_20081127065231/  
drwxr-xr-x 2 oracle dba 4096 Nov 27 06:52 cdmp_20081127065232/  
drwxr-xr-x 2 oracle dba 4096 Nov 27 06:52 cdmp_20081127065235/

  
c) initiate the ADRCI utility:

$ adrci

  
d) at the ADRCI command prompt display all Oracle Homes maintained by this
ADR:

adrci> show homes

  
e) If (d) shows more than 1 home, select the proper home for use with ADRCI:

adrci> set homepath diag/rdbms/v1116u/V1116U  
adrci> set home diag/rdbms/v1116u/V1116U

  
The SET command here depends on (a). If (c) already shows
diag/rdbms/v1116u/V1116U then no action needed.  
  
f) find out what incidents are reported for this instance:

adrci> show incident  
  
INCIDENT_ID PROBLEM_KEY CREATE_TIME  
\----------- ----------------------------- ------------------------------  
39828 ORA-4031 2008-11-27 06:52:26.580144 +00:00  
39820 ORA-4031 2008-11-27 06:52:28.845338 +00:00  
39796 ORA-4031 2008-11-27 06:52:27.562537 +00:00  
39780 ORA-4031 2008-11-27 06:52:32.817075 +00:00  
39748 ORA-4031 2008-11-27 06:52:29.250429 +00:00  
31411 ORA-7445 [mdagun_term()+1031] 2008-11-20 11:23:43.585772 +00:00  
  
6 rows fetched

  
g) try to purge the evidence of the incident 31411:

adrci> purge -i 31411

  
'show incident' will then show the 5 remaining rows but still 'ls -ltr' shows
six CDMP_<timestamp> directories.

## Cause

The cause of this problem has been identified in
[Bug:7601698](https://support.oracle.com/epmos/faces/BugDisplay?parent=DOCUMENT&sourceId=756140.1&id=7601698)
which is confirmed to be a duplicate of unpublished bug 6343743. It is caused
by the ADR of 11.1.0.6 not taking into account the purging if CDMP
directories.

## Solution

In Oracle 11g 11.1.0.7 and higher releases a new option 'UTSCDMP' has been
added to ADRCI's PURGE command:

adrci> help purge  
  
Usage: PURGE [[-i <id1> | <id1> <id2>] |  
[-age <mins> [-type ALERT|INCIDENT|TRACE|CDUMP|HM|UTSCDMP]]]:  
...

  
The UTSCDMP type has been added by the bug fix to allow purge of the CDMP
related information; e.g.:

adrci> purge -age 1440 -type UTSCDMP

  
This will delete the CDMP_<timestamp> directories from the TRACE directory
which are more than 1 day old (1440 minutes = 1 day).  
  
When available, download Patch 6343743 to resolve this issue.  
  
If this Note does not resolve the issue it is not sure if the issue described
is applicable to the issue encountered a new SR should be raised with Oracle
Global Software Support through the My Oracle Support website.

## References

  
  
  
  
  



---
### TAGS
{adrci}

---
### NOTE ATTRIBUTES
>Created Date: 2017-06-29 13:01:43  
>Last Evernote Update Date: 2018-10-01 15:59:05  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/SearchDocDisplay?_adf.ctrl-state=11jlj9x84n_9  
>source-url: &  
>source-url: _afrLoop=274600870306934#SYMPTOM  