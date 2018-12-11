# OCR / Vote disk Maintenance Operations: (ADD/REMOVE/REPLACE/MOVE) (文档 ID
428681.1)

  

|

|

 **In this Document**  

| |
[Goal](https://support.oracle.com/epmos/faces/DocumentDisplay?id=428681.1&_adf.ctrl-
state=4n68ptb5n_281&_afrLoop=323280678803592#GOAL)  
---|---  
|
[Solution](https://support.oracle.com/epmos/faces/DocumentDisplay?id=428681.1&_adf.ctrl-
state=4n68ptb5n_281&_afrLoop=323280678803592#FIX)  
---|---  
| [**Prepare the
disks**](https://support.oracle.com/epmos/faces/DocumentDisplay?id=428681.1&_adf.ctrl-
state=4n68ptb5n_281&_afrLoop=323280678803592#aref_section21)  
---|---  
| [1\.
Size](https://support.oracle.com/epmos/faces/DocumentDisplay?id=428681.1&_adf.ctrl-
state=4n68ptb5n_281&_afrLoop=323280678803592#aref_section22)  
---|---  
| [2\. For raw or block device (pre
11.2)](https://support.oracle.com/epmos/faces/DocumentDisplay?id=428681.1&_adf.ctrl-
state=4n68ptb5n_281&_afrLoop=323280678803592#aref_section23)  
---|---  
| [3\. For ASM disks
(11.2+)](https://support.oracle.com/epmos/faces/DocumentDisplay?id=428681.1&_adf.ctrl-
state=4n68ptb5n_281&_afrLoop=323280678803592#aref_section24)  
---|---  
| [4\. For cluster file
system](https://support.oracle.com/epmos/faces/DocumentDisplay?id=428681.1&_adf.ctrl-
state=4n68ptb5n_281&_afrLoop=323280678803592#aref_section25)  
---|---  
| [5\.
Permissions](https://support.oracle.com/epmos/faces/DocumentDisplay?id=428681.1&_adf.ctrl-
state=4n68ptb5n_281&_afrLoop=323280678803592#aref_section26)  
---|---  
| [6\.
Redundancy](https://support.oracle.com/epmos/faces/DocumentDisplay?id=428681.1&_adf.ctrl-
state=4n68ptb5n_281&_afrLoop=323280678803592#aref_section27)  
---|---  
| [**ADD/REMOVE/REPLACE/MOVE OCR
Device**](https://support.oracle.com/epmos/faces/DocumentDisplay?id=428681.1&_adf.ctrl-
state=4n68ptb5n_281&_afrLoop=323280678803592#aref_section28)  
---|---  
| [1\. To add an OCRMIRROR device when only OCR device is
defined:](https://support.oracle.com/epmos/faces/DocumentDisplay?id=428681.1&_adf.ctrl-
state=4n68ptb5n_281&_afrLoop=323280678803592#aref_section29)  
---|---  
| [2\. To remove an OCR
device](https://support.oracle.com/epmos/faces/DocumentDisplay?id=428681.1&_adf.ctrl-
state=4n68ptb5n_281&_afrLoop=323280678803592#aref_section210)  
---|---  
| [3\. To replace or move the location of an OCR
device](https://support.oracle.com/epmos/faces/DocumentDisplay?id=428681.1&_adf.ctrl-
state=4n68ptb5n_281&_afrLoop=323280678803592#aref_section211)  
---|---  
| [4\. To restore an OCR when clusterware is
down](https://support.oracle.com/epmos/faces/DocumentDisplay?id=428681.1&_adf.ctrl-
state=4n68ptb5n_281&_afrLoop=323280678803592#aref_section212)  
---|---  
| [**ADD/DELETE/MOVE Voting
Disk**](https://support.oracle.com/epmos/faces/DocumentDisplay?id=428681.1&_adf.ctrl-
state=4n68ptb5n_281&_afrLoop=323280678803592#aref_section213)  
---|---  
| [For 10gR2
release](https://support.oracle.com/epmos/faces/DocumentDisplay?id=428681.1&_adf.ctrl-
state=4n68ptb5n_281&_afrLoop=323280678803592#aref_section214)  
---|---  
| [For 11gR1
release](https://support.oracle.com/epmos/faces/DocumentDisplay?id=428681.1&_adf.ctrl-
state=4n68ptb5n_281&_afrLoop=323280678803592#aref_section215)  
---|---  
| [For 11gR2 release and
later](https://support.oracle.com/epmos/faces/DocumentDisplay?id=428681.1&_adf.ctrl-
state=4n68ptb5n_281&_afrLoop=323280678803592#aref_section216)  
---|---  
| [For online OCR/Voting diskgroup
change](https://support.oracle.com/epmos/faces/DocumentDisplay?id=428681.1&_adf.ctrl-
state=4n68ptb5n_281&_afrLoop=323280678803592#aref_section217)  
---|---  
| [ For Voting disk maintenance in Extended
Cluster](https://support.oracle.com/epmos/faces/DocumentDisplay?id=428681.1&_adf.ctrl-
state=4n68ptb5n_281&_afrLoop=323280678803592#aref_section218)  
---|---  
| [Community
Discussions](https://support.oracle.com/epmos/faces/DocumentDisplay?id=428681.1&_adf.ctrl-
state=4n68ptb5n_281&_afrLoop=323280678803592#aref_section219)  
---|---  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?id=428681.1&_adf.ctrl-
state=4n68ptb5n_281&_afrLoop=323280678803592#REF)  
---|---  
  
* * *

## Applies to:

Oracle Database - Enterprise Edition - Version 10.2.0.1 and later  
Information in this document applies to any platform.  

## Goal

[](https://support.oracle.com/epmos/faces/DocumentDisplay?&id=1268927.2&cid=ocdbgeneric-
ad-%E6%96%87%E6%A1%A3-428681.1&parent=KM-Advert&sourceId=ocdbgeneric-
ad-%E6%96%87%E6%A1%A3-428681.1)

The goal of this note is to provide steps to add, remove, replace or move an
Oracle Cluster Repository (OCR) and/or Voting Disk in Oracle Clusterware
10gR2, 11gR1 and 11gR2 environment. It will also provide steps to move OCR /
voting and ASM devices from raw device to block device. For Oracle Clusterware
12c, please refer to [Document
1558920.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=428681.1&id=1558920.1)
Software Patch Level and 12c Grid Infrastructure OCR Backup/Restore.

  
This article is intended for DBA and Support Engineers who need to modify, or
move OCR and voting disks files, customers who have an existing clustered
environment deployed on a storage array and might want to migrate to a new
storage array with minimal downtime.  
  
Typically, one would simply cp or dd the files once the new storage has been
presented to the hosts. In this case, it is a little more difficult because:  
  
1\. The Oracle Clusterware has the OCR and voting disks open and is actively
using them. (Both primary and mirrors)  
2\. There is an API provided for this function (ocrconfig and crsctl), which
is the appropriate interface than typical cp and/or dd commands.  
  
It is highly recommended to take a backup of the voting disk, and OCR device
before making any changes.

**Note:** while the OCR and Voting disk files may be stored together, such as
in OCFS (for example in pre-11.2 Clusterware environments) or in the same ASM
diskgroup (for example in 11.2 Oracle Clusterware environments), OCR and
Voting disk files are in fact two separate files or entities and so if the
intention is to modify or move both OCR and Voting disk files, then one must
follow steps provided for both of these types of files.

## Solution

### **Prepare the disks**

**  
**For OCR or voting disk addition or replacement, new disks need to be
prepared. Please refer to Clusteware/Gird Infrastructure installation guide
for different platform for the disk requirement and preparation.

#### 1\. Size

For 10.1:  
OCR device minimum size (each): 100M  
Voting disk minimum size (each): 20M

For 10.2:  
OCR device minimum size (each): 256M  
Voting disk minimum size (each): 256M

For 11.1:  
OCR device minimum size (each): 280M  
Voting disk minimum size (each): 280M

For 11.2:  
OCR device minimum size (each): 300M  
Voting disk minimum size (each): 300M

#### 2\. For raw or block device (pre 11.2)

Please refer to Clusterware installation guide on different platform for more
details.  
On windows platform the new raw device link is created via
$CRS_HOME\bin\GUIOracleOBJManager.exe, for example:  
\\\\.\VOTEDSK2  
\\\\.\OCR2

#### 3\. For ASM disks (11.2+)

On Windows platform, please refer to [Document
331796.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=428681.1&id=331796.1)
How to setup ASM on Windows  
On Linux platform, please refer to [Document
580153.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=428681.1&id=580153.1)
How To Setup ASM on Linux Using ASMLIB Disks, Raw Devices or Block Devices?  
For other platform, please refer to Clusterware/Gird Infrastructure
installation guide on
[OTN](http://www.oracle.com/pls/db112/portal.portal_db?selected=11&frame=
"11.2 Installation Guide") (Chapter: Oracle Automatic Storage Management
Storage Configuration).

#### 4\. For cluster file system

If OCR is on cluster file system, the new OCR or OCRMIRROR file must be
touched before add/replace command can be issued. Otherwise PROT-21: Invalid
parameter (10.2/11.) or PROT-30 The Oracle Cluster Registry location to be
added is not accessible (for 11.2) will occur.

As root user  
# touch /cluster_fs/ocrdisk.dat  
# touch /cluster_fs/ocrmirror.dat  
# chown root:oinstall /cluster_fs/ocrdisk.dat /cluster_fs/ocrmirror.dat  
# chmod 640 /cluster_fs/ocrdisk.dat /cluster_fs/ocrmirror.dat

It is not required to pre-touch voting disk file on cluster file system.

After delete command is issued, the ocr/voting files on the cluster file
system require to be removed manually.

#### 5\. Permissions

For OCR device:  
chown root:oinstall <OCR device>  
chmod 640 <OCR device>

For Voting device:  
chown <crs/grid>:oinstall <Voting device>  
chmod 644 <Voting device>

For ASM disks used for OCR/Voting disk:  
chown griduser:asmadmin <asm disks>  
chmod 660 <asm disks>

#### 6\. Redundancy

For Voting disks (never use even number of voting disks):  
 **External** redundancy requires minimum of **1** voting disk (or 1 failure
group)  
 **Normal** redundancy requires minimum of **3** voting disks (or 3 failure
group)  
 **High** redundancy requires minimum of **5** voting disks (or 5 failure
group)  
  
Insufficient failure group in respect of redundancy requirement could cause
voting disk creation failure. For example: ORA-15274: Not enough failgroups
(3) to create voting files  
  

For OCR:  
10.2 and 11.1, maximum 2 OCR devices: OCR and OCRMIRROR  
11.2+, upto 5 OCR devices can be added.

For more information, please refer to platform specific **Oracle® Grid
Infrastructure Installation Guide**.

### **ADD/REMOVE/REPLACE/MOVE OCR Device**

**Note:** You must be logged in as the root user, because root owns the OCR
files. "ocrconfig -replace" command can only be issued **when CRS is running**
, otherwise "PROT-1: Failed to initialize ocrconfig" will occur.  
  
 **Please ensure CRS is running on ALL cluster nodes during this operation** ,
otherwise the change will not reflect in the CRS down node, CRS will have
problem to startup from this down node. "ocrconfig -repair" option will be
required to fix the ocr.loc file on the CRS down node.  
  
For 11.2+ with OCR on ASM diskgroup, due to unpublished Bug 8604794 - FAIL TO
CHANGE OCR LOCATION TO DG WITH 'OCRCONFIG -REPAIR -REPLACE', "ocrconfig
-repair" to change OCR location to different ASM diskgroup does not work
currently. Workaround is to manually edit /etc/oracle/ocr.loc or
/var/opt/oracle/ocr.loc or Windows registry
HYKEY_LOCAL_MACHINE\SOFTWARE\Oracle\ocr, point to desired diskgroup.  
  
If there is any issue with OLR, please refer to How to restore OLR in 11.2
Grid Infrastructure [Note
1193643.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=428681.1&id=1193643.1).

Make sure there is a recent copy of the OCR file before making any changes:

> ocrconfig -showbackup

If there is not a recent backup copy of the OCR file, an export can be taken
for the current OCR file. Use the following command to generate an export of
the online OCR file:  
  
In 10.2

> # ocrconfig -export <OCR export_filename> -s online

In 11.1 and 11.2

> # ocrconfig -manualbackup  
> node1 2008/08/06 06:11:58 /crs/cdata/crs/backup_20080807_003158.ocr

To recover using this file, the following command can be used:

# ocrconfig -import <OCR export_filename>

  
From 11.2+, please also refer How to restore ASM based OCR after complete loss
of the CRS diskgroup on Linux/Unix systems [Document
1062983.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=428681.1&id=1062983.1)  
  
To see whether OCR is healthy, run an ocrcheck, which should return with like
below.

> # ocrcheck  
> Status of Oracle Cluster Registry is as follows :  
> Version : 2  
> Total space (kbytes) : 497928  
> Used space (kbytes) : 312  
> Available space (kbytes) : 497616  
> ID : 576761409  
> Device/File Name : /dev/raw/raw1  
> Device/File integrity check succeeded  
> Device/File Name : /dev/raw/raw2  
> Device/File integrity check succeeded  
>  
> Cluster registry integrity check succeeded  
>  
> For 11.1+, ocrcheck as root user should also show:  
> Logical corruption check succeeded

#### 1\. To add an OCRMIRROR device when only OCR device is defined:

To add an OCR mirror device, provide the full path including file name.  
**10.2 and 11.1:**

> # ocrconfig -replace ocrmirror <filename>  
> eg:  
> # ocrconfig -replace ocrmirror /dev/raw/raw2  
> # ocrconfig -replace ocrmirror /dev/sdc1  
> # ocrconfig -replace ocrmirror /cluster_fs/ocrdisk.dat  
> > ocrconfig -replace ocrmirror \\\\.\OCRMIRROR2 - for Windows

**11.2+:** From 11.2 onwards, upto 4 ocrmirrors can be added

> # ocrconfig -add <filename>  
> eg:  
> # ocrconfig -add +OCRVOTE2  
> # ocrconfig -add /cluster_fs/ocrdisk.dat

#### 2\. To remove an OCR device

To remove an OCR device:  
**10.2 and 11.1:**

> # ocrconfig -replace ocr

**11.2+:**

> # ocrconfig -delete <filename>  
> eg:  
> # ocrconfig -delete +OCRVOTE1

>

>  
>

>

> * Once an OCR device is removed, ocrmirror device automatically changes to
be OCR device.  
> * It is not allowed to remove OCR device if only 1 OCR device is defined,
the command will return PROT-16.

  
To remove an OCR mirror device:  
**10.2 and 11.1:**

> # ocrconfig -replace ocrmirror

**11.2+:**

> # ocrconfig -delete <ocrmirror filename>  
> eg:  
> # ocrconfig -delete +OCRVOTE2

After removal, the old OCR/OCRMIRROR can be deleted if they are on cluster
filesystem.

#### 3\. To replace or move the location of an OCR device

**Note.** 1\. An ocrmirror must be in place before trying to replace the OCR
device. The ocrconfig will fail with PROT-16, if there is no ocrmirror exists.  
2\. If an OCR device is replaced with a device of a different size, the size
of the new device will not be reflected until the clusterware is restarted.

  
**10.2 and 11.1:**  
To replace the OCR device with <filename>, provide the full path including
file name.

> # ocrconfig -replace ocr <filename>  
> eg:  
> # ocrconfig -replace ocr /dev/sdd1  
> $ ocrconfig -replace ocr \\\\.\OCR2 - for Windows

To replace the OCR mirror device with <filename>, provide the full path
including file name.

> # ocrconfig -replace ocrmirror <filename>  
> eg:  
> # ocrconfig -replace ocrmirror /dev/raw/raw4  
> # ocrconfig -replace ocrmirror \\\\.\OCRMIRROR2 - for Windows

**11.2+:**  
The command is same for replace either OCR or OCRMIRRORs (at least 2 OCR exist
for replace command to work):

# ocrconfig -replace <current filename> -replacement <new filename>  
eg:  
# ocrconfig -replace /cluster_file/ocr.dat -replacement +OCRVOTE  
# ocrconfig -replace +CRS -replacement +OCRVOTE

#### 4\. To restore an OCR when clusterware is down

When OCR is not accessible, CRSD process will not start, hence the clusterware
stack will not start completely. A restore of OCR device access and good OCR
content is required.  
To view the automatic OCR backup:

# ocrconfig -showbackup

To restore the OCR backup:

# ocrconfig -restore <path/filename of OCR backup>

**For 11.2+:** If OCR is located in ASM disk and ASM disk is also lost, please
check out:  
How to restore ASM based OCR after complete loss of the CRS diskgroup on
Linux/Unix systems [Document
1062983.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=428681.1&id=1062983.1)  
How to Restore OCR After the 1st ASM Diskgroup is Lost on Windows [Document
1294915.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=428681.1&id=1294915.1)  
  
If there is no valid backup of OCR presented, reinitialize OCR and Voting is
required.  
 **For 10.2 and 11.1:**  
Please refer to How to Recreate OCR/Voting Disk Accidentally Deleted [Document
399482.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=428681.1&id=399482.1)  
  
 **For 11.2+:**  
Deconfig the clusterware stack and rerun root.sh on all nodes is required.  
  
  

### **ADD/DELETE/MOVE Voting Disk**

**Note** : 1. crsctl votedisk commands must be run as root for 10.2 and 11.1,
but can be run as grid user for 11.2+  
2\. For 11.2+, when using ASM disks for OCR and voting, the command is same
for Windows and Unix platform.

For pre 11.2, to take a backup of voting disk:

> $ dd if=voting_disk_name of=backup_file_name

For Windows:

> ocopy \\\\.\votedsk1 o:\backup\votedsk1.bak

For 11.2+, it is no longer required to back up the voting disk. The voting
disk data is automatically backed up in OCR as part of any configuration
change. The voting disk files are backed up automatically by Oracle
Clusterware if the contents of the files have changed in the following ways:

  * Configuration parameters, for example `misscount`, have been added or modified

  * After performing voting disk `add` or `delete` operations

The voting disk contents are restored from a backup automatically when a new
voting disk is added or replaced.

#### For 10gR2 release

Shutdown the Oracle Clusterware (crsctl stop crs as root) on all nodes before
making any modification to the voting disk. Determine the current voting disk
location using:  
crsctl query css votedisk  
  
 **1\. To add a Voting Disk, provide the full path including file name:**

> # crsctl add css votedisk <VOTEDISK_LOCATION> -force  
> eg:  
> # crsctl add css votedisk /dev/raw/raw1 -force  
> # crsctl add css votedisk /cluster_fs/votedisk.dat -force  
> > crsctl add css votedisk \\\\.\VOTEDSK2 -force - for windows

**2\. To delete a Voting Disk, provide the full path including file name:**

> # crsctl delete css votedisk <VOTEDISK_LOCATION> -force  
> eg:  
> # crsctl delete css votedisk /dev/raw/raw1 -force  
> # crsctl delete css votedisk /cluster_fs/votedisk.dat -force  
> > crsctl delete css votedisk \\\\.\VOTEDSK1 -force - for windows

**3\. To move a Voting Disk, provide the full path including file name, add a
device first before deleting the old one:**

> # crsctl add css votedisk <NEW_LOCATION> -force  
> # crsctl delete css votedisk <OLD_LOCATION> -force  
> eg:  
> # crsctl add css votedisk /dev/raw/raw4 -force  
> # crsctl delete css votedisk /dev/raw/raw1 -force

After modifying the voting disk, start the Oracle Clusterware stack on all
nodes

> # crsctl start crs

Verify the voting disk location using

> # crsctl query css votedisk

#### For 11gR1 release

Starting with 11.1.0.6, the below commands can be performed online (CRS is up
and running).  
  
 **1\. To add a Voting Disk, provide the full path including file name:**

# crsctl add css votedisk <VOTEDISK_LOCATION>  
eg:  
# crsctl add css votedisk /dev/raw/raw1  
# crsctl add css votedisk /cluster_fs/votedisk.dat  
> crsctl add css votedisk \\\\.\VOTEDSK2 - for windows

**2\. To delete a Voting Disk, provide the full path including file name:**

# crsctl delete css votedisk <VOTEDISK_LOCATION>  
eg:  
# crsctl delete css votedisk /dev/raw/raw1 -force  
# crsctl delete css votedisk /cluster_fs/votedisk.dat  
> crsctl delete css votedisk \\\\.\VOTEDSK1 - for windows

**3\. To move a Voting Disk, provide the full path including file name:**

# crsctl add css votedisk <NEW_LOCATION>  
# crsctl delete css votedisk <OLD_LOCATION>  
eg:  
# crsctl add css votedisk /dev/raw/raw4  
# crsctl delete css votedisk /dev/raw/raw1

Verify the voting disk location:

# crsctl query css votedisk

#### For 11gR2 release and later

From 11.2, votedisk can be stored on either ASM diskgroup or cluster file
systems. The following commands can only be executed when **Grid
Infrastructure is running**. As grid user:  
  
 **1\. To add a Voting Disk**  
a. When votedisk is on cluster file system:

$ crsctl add css votedisk <cluster_fs/filename>

b. When votedisk is on ASM diskgroup, no add option available.  
The number of votedisk is determined by the diskgroup redundancy. If more
copies of votedisks are desired, one can move votedisk to a diskgroup with
higher redundancy. See step 4.  
If a votedisk is removed from a normal or high redundancy diskgroup for
abnormal reason, it can be added back using:

alter diskgroup <vote diskgroup name> add disk '</path/name>' force;

  
**2\. To delete a Voting Disk**  
a. When votedisk is on cluster file system:

$ crsctl delete css votedisk <cluster_fs/filename>  
or  
$ crsctl delete css votedisk <vdiskGUID> (vdiskGUID is the File Universal Id
from 'crsctl query css votedisk')

b. When votedisk is on ASM, no delete option available, one can only replace
the existing votedisk group with another ASM diskgroup  
  
 **3\. To move a Voting Disk on cluster file system**``

$ crsctl add css votedisk <new_cluster_fs/filename>  
$ crsctl delete css votedisk <old_cluster_fs/filename>  
or  
$ crsctl delete css votedisk <vdiskGUID>

**4\. To move voting disk on ASM from one diskgroup to another diskgroup due
to redundancy change or disk location change**

$ crsctl replace votedisk <+diskgroup>|<vdisk>

Example here is moving from external redundancy +OCRVOTE diskgroup to normal
redundancy +CRS diskgroup **  
**

1\. create new diskgroup +CRS as desired  
  
2\. $ crsctl query css votedisk  
## STATE File Universal Id File Name Disk group  
\-- ----- ----------------- --------- ---------  
1\. ONLINE 5e391d339a594fc7bf11f726f9375095 (ORCL:ASMDG02) [+OCRVOTE]  
Located 1 voting disk(s).  
  
3\. $ crsctl replace votedisk +CRS  
Successful addition of voting disk 941236c324454fc0bfe182bd6ebbcbff.  
Successful addition of voting disk 07d2464674ac4fabbf27f3132d8448b0.  
Successful addition of voting disk 9761ccf221524f66bff0766ad5721239.  
Successful deletion of voting disk 5e391d339a594fc7bf11f726f9375095.  
Successfully replaced voting disk group with +CRS.  
CRS-4266: Voting file(s) successfully replaced  
  
4\. $ crsctl query css votedisk  
## STATE File Universal Id File Name Disk group  
\-- ----- ----------------- --------- ---------  
1\. ONLINE 941236c324454fc0bfe182bd6ebbcbff (ORCL:CRSD1) [CRS]  
2\. ONLINE 07d2464674ac4fabbf27f3132d8448b0 (ORCL:CRSD2) [CRS]  
3\. ONLINE 9761ccf221524f66bff0766ad5721239 (ORCL:CRSD3) [CRS]  
Located 3 voting disk(s).

**5\. To move voting disk between ASM diskgroup and cluster file system**  
a. Move from ASM diskgroup to cluster file system:

$ crsctl query css votedisk  
## STATE File Universal Id File Name Disk group  
\-- ----- ----------------- --------- ---------  
1\. ONLINE 6e5850d12c7a4f62bf6e693084460fd9 (ORCL:CRSD1) [CRS]  
2\. ONLINE 56ab5c385ce34f37bf59580232ea815f (ORCL:CRSD2) [CRS]  
3\. ONLINE 4f4446a59eeb4f75bfdfc4be2e3d5f90 (ORCL:CRSD3) [CRS]  
Located 3 voting disk(s).  
  
$ crsctl replace votedisk /rac_shared/oradata/vote.test3  
Now formatting voting disk: /rac_shared/oradata/vote.test3.  
CRS-4256: Updating the profile  
Successful addition of voting disk 61c4347805b64fd5bf98bf32ca046d6c.  
Successful deletion of voting disk 6e5850d12c7a4f62bf6e693084460fd9.  
Successful deletion of voting disk 56ab5c385ce34f37bf59580232ea815f.  
Successful deletion of voting disk 4f4446a59eeb4f75bfdfc4be2e3d5f90.  
CRS-4256: Updating the profile  
CRS-4266: Voting file(s) successfully replaced  
  
$ crsctl query css votedisk  
## STATE File Universal Id File Name Disk group  
\-- ----- ----------------- --------- ---------  
1\. ONLINE 61c4347805b64fd5bf98bf32ca046d6c (/rac_shared/oradata/vote.disk) []  
Located 1 voting disk(s).

b. Move from cluster file system to ASM diskgroup

$ crsctl query css votedisk  
## STATE File Universal Id File Name Disk group  
\-- ----- ----------------- --------- ---------  
1\. ONLINE 61c4347805b64fd5bf98bf32ca046d6c (/rac_shared/oradata/vote.disk) []  
Located 1 voting disk(s).  
  
$ crsctl replace votedisk +CRS  
CRS-4256: Updating the profile  
Successful addition of voting disk 41806377ff804fc1bf1d3f0ec9751ceb.  
Successful addition of voting disk 94896394e50d4f8abf753752baaa5d27.  
Successful addition of voting disk 8e933621e2264f06bfbb2d23559ba635.  
Successful deletion of voting disk 61c4347805b64fd5bf98bf32ca046d6c.  
Successfully replaced voting disk group with +CRS.  
CRS-4256: Updating the profile  
CRS-4266: Voting file(s) successfully replaced  
  
[oragrid@auw2k4 crsconfig]$ crsctl query css votedisk  
## STATE File Universal Id File Name Disk group  
\-- ----- ----------------- --------- ---------  
1\. ONLINE 41806377ff804fc1bf1d3f0ec9751ceb (ORCL:CRSD1) [CRS]  
2\. ONLINE 94896394e50d4f8abf753752baaa5d27 (ORCL:CRSD2) [CRS]  
3\. ONLINE 8e933621e2264f06bfbb2d23559ba635 (ORCL:CRSD3) [CRS]  
Located 3 voting disk(s).

**6\. To verify:**

$ crsctl query css votedisk

****

#### For online OCR/Voting diskgroup change

For disk storage migration, if using ASM diskgroup and the size / diskgroup
redundancy remain the same, then one can use add failure group contain new
storage and drop failure group which contain old storage to achieve this
online change.

For more information, please refer to How to Swap Voting Disks Across Storage
in a Diskgroup (Doc ID 1558007.1) and Exact Steps To Migrate ASM Diskgroups To
Another SAN/Disk-Array/DAS/etc Without Downtime. (Doc ID 837308.1)

#### For Voting disk maintenance in Extended Cluster

Please refer to Oracle White paper: [Oracle Clusterware 11g Release 2 (11.2) –
Using standard NFS to support a third voting file for extended cluster
configurations](http://www.oracle.com/technetwork/database/clusterware/overview/grid-
infra-thirdvoteonnfs-131158.pdf "Using standard NFS to support a third voting
file for extended cluster configurations")

If there is any issue using asmca tool, please refer to How to Manually Add
NFS voting disk to an Extended Cluster using ASM in 11.2 [Note
1421588.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=428681.1&id=1421588.1)
for detailed commands.

### Community Discussions

Still have questions? Use the communities window below to search for similar
discussions or start a new discussion on this subject. (Window is the live
community not a screenshot)

Click
[here](https://community.oracle.com/community/support/oracle_database/database_-
_rac_scalability) to open in main browser window

## References

[NOTE:1558920.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=428681.1&id=1558920.1)
\- Software Patch Level and 12c Grid Infrastructure OCR Backup/Restore  
[NOTE:1062983.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=428681.1&id=1062983.1)
\- How to Restore ASM Based OCR After Complete Loss of the CRS Diskgroup on
Linux/Unix Systems  
[NOTE:866102.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=428681.1&id=866102.1)
\- Renaming OCR Using "ocrconfig -overwrite" Fails  
[NOTE:390880.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=428681.1&id=390880.1)
\- OCR Corruption after Adding/Removing voting disk to a cluster when CRS
stack is running  
[NOTE:1573574.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=428681.1&id=1573574.1)
\- OCR Placement and Size Specification  
  
  
  


---
### ATTACHMENTS
[3eef892b44f1ef05d46f23d87bb10759]: media/OCR__Vote_disk_Maintenance_Operations_ADDREMOVEREPLACEMOVE_文档_ID_42868.1)
[OCR__Vote_disk_Maintenance_Operations_ADDREMOVEREPLACEMOVE_文档_ID_42868.1)](media/OCR__Vote_disk_Maintenance_Operations_ADDREMOVEREPLACEMOVE_文档_ID_42868.1))

---
### TAGS
{RAC}

---
### NOTE ATTRIBUTES
>Created Date: 2017-07-05 01:25:12  
>Last Evernote Update Date: 2018-10-01 15:44:51  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?id=428681.1  
>source-url: &  
>source-url: _adf.ctrl-state=4n68ptb5n_281  
>source-url: &  
>source-url: _afrLoop=323280678803592  