# Exact Steps To Migrate ASM Diskgroups To Another SAN/Disk-Array/DAS/etc
Without Downtime. (文档 ID 837308.1)

  

|

|

 **In this Document**  

| |  Goal  
---|---  
| Ask Questions, Get Help, And Share Your Experiences With This Article  
---|---  
| Solution  
---|---  
| References  
---|---  
  
* * *

## Applies to:

Oracle Database - Enterprise Edition - Version 10.2.0.1 to 12.1.0.2 [Release
10.2 to 12.1]  
Information in this document applies to any platform.  

## Goal

The present document explains in detail the exact steps to migrate ASM
diskgroups from one **SAN/Disk-Array/DAS/** etc to another **SAN/Disk-
Array/DAS** /etc without a downtime. This procedure will also work for
diskgroups hosting OCR and Votefiles and ASM spfile.

Note: **These steps are applicable to External, Normal & High redundancy
diskgroups.**

### Ask Questions, Get Help, And Share Your Experiences With This Article

**Would you like to explore this topic further with other Oracle Customers,
Oracle Employees, and Industry Experts?**  
  
[Click here to join the discussion where you can ask questions, get help from
others, and share your experiences with this specific
article](https://community.oracle.com/thread/3113035 "Discussion of Doc ID
946213.1").  
Discover discussions about other articles and helpful subjects by clicking
[here](https://community.oracle.com/community/support/oracle_database/storage_management_\(asm_acfs_dnfs_odm\)
"My Oracle Support Community - Storage") to access the main _My Oracle Support
Community_ page for Database Install/Upgrade.

## Solution

If your plans are replacing the current disks associated to your diskgroups
with a new storage, this operation can be accomplished without any downtime,
so you can follow the next steps  
  
1) Backup all your databases and valid the backup (always required to protect
your data).  
  
2) Add the new path (new disks from the new storage) to your asm_disktring to
be recognized by ASM:  
  
Example:

SQL> alter system set asm_diskstring = '/dev/emcpowerc*' , '/dev/emcpowerh*';  
  
Where: **'/dev/emcpowerc*'** are the current disks.  
Where: **'/dev/emcpowerh*'** are the new disks.

  
3) Confirm that the new disks are being detected by ASM:

SQL> select path from v$asm_disk;

4) Validate all the new disks as described in the following document:  

_**How To Add a New Disk(s) to An Existing Diskgroup on RAC Cluster or
Standalone ASM Configuration (Best Practices). (Doc
ID[557348.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=837308.1&id=557348.1
"557348.1"))**_

  
5) Add the new disks to your desired diskgroup:

SQL> alter diskgroup <diskgroup name> add disk  
‘<new disk 1>’,  
‘<new disk 2>’,  
‘<new disk 3>’,  
‘<new disk 4>’,  
.  
.  
.  
‘<new disk N>’ rebalance power <#>;

  
  
6) Then wait until the rebalance operation completes:

SQL> select * from v$asm_operation;  
SQL> select * from gv$asm_operation;

  
7) Finally, remove the old disks:

SQL> alter diskgroup <diskgroup name> drop disk  
<disk name A>,  
<disk name B>,  
<disk name D>,  
<disk name E>,  
.  
.  
.  
<disk name X> rebalance power <#>;

  
8) Then wait until the rebalance operation completes:

SQL> select * from v$asm_operation;  
SQL> select * from gv$asm_operation;

  
  
9) Done, your ASM diskgroups and database have been migrated to the new
storage.  
  
Note: Alternatively, we can execute add disk & drop disk statements in one
operation, in that way only one rebalance operation will be started as follow:

SQL> alter diskgroup <diskgroup name>  
add disk '<new device physical name 1>', .., '<new device physical name N>'  
drop disk <old disk logical name 1>, <old disk logical name 2>, ..,<old disk
logical name N>  
rebalance power <#>;

  
This is more efficient than separated commands (add disk & drop disk
statements).

Note 1: On 10g, a manual rebalance operation is required to restart the
diskgroup rebalance and expel the disk(s) because on 10g (if something wrong
happens on disk expelling, e.g. hanging) ASM will not restart the ASM
rebalance automatically (this was already enhanced on 11g and 12c), therefore
you will need to restart a manual rebalance operation as follows:  

SQL> alter diskgroup <diskgroup name> rebalance power 11;

  

Note 2: Disk from the old **SAN/Disk-Array/DAS/** etc are finally expelled
from the diskgroup(s) once the rebalance operation (from the drop operation)
completes and when HEADER_STATUS = **FORMER** is reported thru the v$asm_disk
view.

  

* * *

**The window below is a live discussion of this article (not a screenshot). We
encourage you to join the discussion by clicking the "Reply" link below for
the entry you would like to provide feedback on. If you have questions or
implementation issues with the information in the article above, please share
that below.**

* * *

## References

[NOTE:557348.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=837308.1&id=557348.1)
\- How To Add a New Disk(s) to An Existing Diskgroup on RAC Cluster or
Standalone ASM Configuration (Best Practices).  
[NOTE:1918350.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=837308.1&id=1918350.1)
\- Exact Steps to Migrate ASM Diskgroups to Another SAN/Disk-Array/DAS/Etc
without Downtime (When ASMLIB Devices Are Involved)  
[NOTE:1638177.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=837308.1&id=1638177.1)
\- Move OCR , Vote File , ASM SPILE to new Diskgroup  
  
  
  



---
### TAGS
{RAC}

---
### NOTE ATTRIBUTES
>Created Date: 2017-05-05 08:04:44  
>Last Evernote Update Date: 2017-05-05 08:11:13  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=512284754552726  
>source-url: &  
>source-url: id=837308.1  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=136fbpr51o_45  