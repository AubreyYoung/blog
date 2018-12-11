# ORA-27054 ERRORS WHEN RUNNING RMAN WITH NFS (文档 ID 387700.1)

  

|

|

 **In this Document**  

| |
[Symptoms](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323466564845095&id=387700.1&_adf.ctrl-
state=4n68ptb5n_444#SYMPTOM)  
---|---  
|
[Cause](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323466564845095&id=387700.1&_adf.ctrl-
state=4n68ptb5n_444#CAUSE)  
---|---  
|
[Solution](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323466564845095&id=387700.1&_adf.ctrl-
state=4n68ptb5n_444#FIX)  
---|---  
| [Cause 1: - Mount Options are Correct but still getting the errors (Bug
5146667
)](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323466564845095&id=387700.1&_adf.ctrl-
state=4n68ptb5n_444#aref_section31)  
---|---  
| [Cause 2:- NFS server is on RH3 (kernel 3) which does support only 8K rsize
and wsize while the blocksize of the database is
16K.](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323466564845095&id=387700.1&_adf.ctrl-
state=4n68ptb5n_444#aref_section32)  
---|---  
| [ Cause 3 :-
](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323466564845095&id=387700.1&_adf.ctrl-
state=4n68ptb5n_444#aref_section33)[Bug
9244583](https://support.oracle.com/BugDisplay?parent=DOCUMENT&sourceId=1076405.1&id=9244583)  
  
  
---|---  
| [Cause 4 :- Incorrect setup for NFS mount in
AIX](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323466564845095&id=387700.1&_adf.ctrl-
state=4n68ptb5n_444#aref_section34)  
---|---  
| [Cause 5 :- Using NFS Mount point on a Netapp Filer on Solaris
10](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323466564845095&id=387700.1&_adf.ctrl-
state=4n68ptb5n_444#aref_section35)  
---|---  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323466564845095&id=387700.1&_adf.ctrl-
state=4n68ptb5n_444#REF)  
---|---  
  
* * *

_This document is being delivered to you via Oracle Support's Rapid Visibility
(RaV) process and therefore has not been subject to an independent technical
review. ___  
---  
  
## Applies to:

Oracle Database - Enterprise Edition - Version 10.2.0.1 and later  
Oracle Solaris on SPARC (64-bit)  
Sun Solaris SPARC (64-bit)  
***Checked for relevance on 04-Dec-2013***  
  
  
  

## Symptoms

Common error

\-----------------

ORA-27054 ERRORS WHEN RUNNING RMAN WITH NFS  
  
Starting Control File and SPFILE Autobackup at 01-AUG-06  
RMAN-00571: ===========================================================  
RMAN-00569: ERROR MESSAGE STACK FOLLOWS

===========================================================  
RMAN-03009: failure of Control File and SPFILE Autobackup command on
ORA_DISK_2  
channel at 08/01/2006 16:43:49  
ORA-19504: failed to create file
"/u60/rman/nitfq/cntrl/nitfq_c-4256538111-20060801-02"  
ORA-27054: NFS file system where the file is created or resides is not mounted
with correct options Additional information: 2

## Cause

Multiple Caused based on Symptom are given below

.

## Solution

### Cause 1: - Mount Options are Correct but still getting the errors (Bug
5146667 )

  
From Oracle 10G R2 , Oracle checks the options with which a NFS mount is
mounted on the filesystem. and this is done to ensure that no corruption of
the database can happen as incorrectly mounted NFS volumes can result in data
corruption.  
  
There are no single set of NFS mount options that work across all Oracle
platforms  
Please ensure that you have the proper mount options specified by the NAS
vendor /Vendor user guide  
  
  
The exact checks used for an NFS mounted disk vary between platforms but in
general the basic checks will include the following checks  
  
  
a) The mount table (eg; /etc/mnttab) can be read to check the mount options  
b) The NFS mount is mounted with the "hard" option  
c) The mount options include rsize>=32768 and wsize>=32768  
d) For RAC environments, where NFS disks are supported, the "noac" mount
option is used.  
  
Please refer the section -- NFS Mount Options in Oracle Database Installation
Guide10g Release 2 (10.2)  
If you have ensured that the mount options are appropriate and still getting
the errors then you are encountering symptoms as in Bug 5146667 Fixed In Ver:
11.0. 0.0  
  
  
And this issues is found to be port specific and reproducable on Solaris

**Solution 1 :-**

To implement the solution, please execute the following steps:

From the errors that we see from the RMAN stack this looks like Bug 5146667

This behaviour has been observed on Solaris and AIX Platform.

**A) WORKAROUND:**

As suggested in the bug the workaround recommended is to use the Event 10298.

sql> alter system set events '10298 trace name context forever, level 32';

or

sql> alter system set events '10298 trace name context forever, level 32'
scope=spfile;

  
or:  
Set the following event in the init.ora  
event="10298 trace name context forever, level 32"  
  

Then try the backups again

Note: If you set the event with scope=spfile, then same as with init.ora
change,  
you have to restart the instance for the event to be recognized.

**B) PATCH**  
Check if a one off patch for 10.2.0.1 for your platform is available  
Please follow next steps to download and test it :

Use the following link to download the Patch [Patch
5146667](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=387700.1&patchId=5146667)  
  
# Once the patch is shown as applied - you can disable/remove the event

( SQL> alter system set events '10298 trace name context off ' ; )

### Cause 2:- NFS server is on RH3 (kernel 3) which does support only 8K rsize
and wsize while the blocksize of the database is 16K.

The same error appears when one datafile is added to any tablespace and the
datafile is being created on NFS.

The database was upgraded from version 10.2.0.3 to version 10.2.0.4.0.

This is a Vendor specific issue.

  
NFS server is on RH3 (kernel 3) which does support only 8K rsize and wsize
while the blocksize of the database is 16K.

  

**Solution 2 :-**

Please check with the system admin, why /proc/mounts show only 8K for rsize
and wsize and upgrade the kernel to 2.6 for their 16K database block size.

  

Reference :-  
[BUG:7517843](https://support.oracle.com/BugDisplay?parent=DOCUMENT&sourceId=833094.1&id=7517843)
\- ORA-19504 ORA-27054 DURING THE BACKUP AFTER UPGRADE TO 10.2.0.4  
http://kbase.redhat.com/faq/FAQ_45_9192.shtm

  

  

### Cause 3 :- [Bug
9244583](https://support.oracle.com/BugDisplay?parent=DOCUMENT&sourceId=1076405.1&id=9244583)  
  

Running a backup to the same NFS filesystem, from 11.1 and 10.2 databases
works fine, but if we execute the backup from 11.2.0.1 database the above
errors are raised.

This problem has been reported in the following bug:  
  
[Bug
9244583](https://support.oracle.com/BugDisplay?parent=DOCUMENT&sourceId=1076405.1&id=9244583)
ORA-27054 ERRORS WHEN RUNNING RMAN WITH NFS IN 11.2  
  
There are multiple entries in /etc/mnttab for the mount point in question and
we use the auto-mount entry and since this entry fails the option checks we
raise the ORA-27054 error and never encounter the "real" entry for the file
system mount.

  

**Solution 3 :-**

  
  
1.- Apply the patch to fix bug 9244583, the patch can be downloaded from MOS.  
  
or  
  
2.- Use the workaround:  

  

Set the following event in the init.ora parameter file:  
  
event="10298 trace name context forever, level 32" in the init.ora/spfile and
restart the instance.  
  
If using spfile define the event from sqlplus  
  
SQL> alter system set event='10298 trace name context forever, level 32'
scope=spfile;

  

  

### Cause 4 :- Incorrect setup for NFS mount in AIX

  

**Solution 4 :-**

  

This seems to be a limitation on AIX platforms. All mount point information is
supposed to be present in the '/etc/filesystems' file located on the system.  
  
When mount information is not present in this file it can lead to errors.  
  
The behavior is described in base bug:  
  
Bug 6403001 - ORA-27054 ERROR WHEN BACKING UP DATABASE WITH RMAN TO AN NFS
MOUNT  
  
closed as 'OS-Vendor problem', specific for AIX platforms.  
  
So check and add the NFS mount point entry is in /etc/filesystems.

  

Reference :-

[BUG:6403001](https://support.oracle.com/BugDisplay?parent=DOCUMENT&sourceId=1337605.1&id=6403001)
\- ORA-27054 ERROR WHEN BACKING UP DATABASE WITH RMAN TO AN NFS MOUNT  
[NOTE:420582.1](https://support.oracle.com/DocumentDisplay?parent=DOCUMENT&sourceId=1337605.1&id=420582.1)
\- WRONG MOUNT OPTIONS AIX

  

### Cause 5 :- Using NFS Mount point on a Netapp Filer on Solaris 10

  

**Solution 5 :-**

  

Notes from the SA:  
  
By default, Solaris 10 uses NFS v4. This is specified (and configured) in
/etc/default/nfs.  
  
On the filer, nfs.v4 was not enabled by default:  

filer2> options nfs  
.  
.  
nfs.v3.enable on  
nfs.v4.acl.enable off  
nfs.v4.enable off  
nfs.v4.id.domain xxxxx masked  
nfs.v4.read_delegation off  
nfs.v4.write_delegation off  
.  
.  
filer2> options nfs.v4.enable on

  
  
On the Solaris 10 host  
  

-bash-3.00# nfsstat -m  
/backup from filer2:/vol/nfs_erp_backup  
Flags:  
vers=4,proto=tcp,sec=sys,hard,intr,link,symlink,acl,rsize=32768,wsize=32768,retrans=5,timeo=600  
Attr cache: acregmin=3,acregmax=60,acdirmin=30,acdirmax=60  
  
The default rsize/wsize settings for NFS v4 appears to be 64K, so we set to
32K in /etc/vfstab  
since that was what we could find reference to:  
  
-bash-3.00# grep backup /etc/vfstab  
filer2:/vol/nfs_erp_backup - /backup nfs - yes  
rw,bg,intr,hard,timeo=600,wsize=32768,rsize=32768,proto=tcp  
  
We also enabled nfs.v4.acl.enable to address a setfacl issue:  
  
filer2> options nfs.v4.acl.enable on  
  
Then we added /etc/passwd & /etc/group entries on the filer.

  
  
This appears to have resolved our RMAN to NFS issues on Solaris 10 to NetApp
and our setfacl issues.

  

  

## References

[BUG:5146667](https://support.oracle.com/epmos/faces/BugDisplay?parent=DOCUMENT&sourceId=387700.1&id=5146667)
\- ORA-27054 ERRORS WHEN RUNNING RMAN WITH NFS  
  
  
  



---
### TAGS
{nfs}  {rman}

---
### NOTE ATTRIBUTES
>Created Date: 2017-07-05 01:28:29  
>Last Evernote Update Date: 2018-10-01 15:44:50  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323466564845095  
>source-url: &  
>source-url: id=387700.1  
>source-url: &  
>source-url: _adf.ctrl-state=4n68ptb5n_444  