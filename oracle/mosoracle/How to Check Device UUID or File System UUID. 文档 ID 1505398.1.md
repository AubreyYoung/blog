# How to Check Device UUID or File System UUID. (文档 ID 1505398.1)

  

|

|

 **In this Document**  

| |
[Goal](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=40548267301445&id=1505398.1&_adf.ctrl-
state=6mllyy5k2_45#GOAL)  
---|---  
|
[Solution](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=40548267301445&id=1505398.1&_adf.ctrl-
state=6mllyy5k2_45#FIX)  
---|---  
  
* * *

  

## Applies to:

Linux OS - Version Oracle Linux 5.0 and later  
Linux x86-64  
Linux x86  

## Goal

In Linux, sometimes the name of devices or file systems are not persistent
which will bring system in trouble, in such situation specify UUID
(universally unique identifier) is the solution to identify the only unique
component in the system.

## Solution

**1\. Device uuid**

In OL5.x:

# scsi_id -u -g -s /block/sda  
35000c50032387713

In OL6.x:

# scsi_id --whitelisted /dev/sdd  
3600144f0da627ad70000503ad6ce0006

Or:

# udevadm info --query=all --path=/sys/block/sda  
P:
/devices/pci0000:00/0000:00:01.0/0000:01:00.0/host0/target0:2:0/0:2:0:0/block/sda  
N: sda  
W: 99  
S: block/8:0  
S: disk/by-id/scsi-364403a78570b200018ac2cd20575ec04  
S: disk/by-path/pci-0000:01:00.0-scsi-0:2:0:0  
S: disk/by-id/wwn-0x64403a78570b200018ac2cd20575ec04  
E: UDEV_LOG=3  
E:
DEVPATH=/devices/pci0000:00/0000:00:01.0/0000:01:00.0/host0/target0:2:0/0:2:0:0/block/sda  
E: MAJOR=8  
E: MINOR=0  
E: DEVNAME=/dev/sda  
E: DEVTYPE=disk  
E: SUBSYSTEM=block  
E: MPATH_SBIN_PATH=/sbin  
E: ID_SCSI=1  
E: ID_VENDOR=LSI  
E: ID_VENDOR_ENC=LSI  
E: ID_MODEL=MRSASRoMB-4i  
E: ID_MODEL_ENC=MRSASRoMB-4i  
E: ID_REVISION=2.12  
E: ID_TYPE=disk  
E: ID_SERIAL_RAW=364403a78570b200018ac2cd20575ec04  
E: ID_SERIAL=364403a78570b200018ac2cd20575ec04  
E: ID_SERIAL_SHORT=64403a78570b200018ac2cd20575ec04  
E: ID_WWN=0x64403a78570b2000  
E: ID_WWN_VENDOR_EXTENSION=0x18ac2cd20575ec04  
E: ID_WWN_WITH_EXTENSION=0x64403a78570b200018ac2cd20575ec04  
E: ID_SCSI_SERIAL=0004ec7505d22cac1800200b57783a40  
E: ID_BUS=scsi  
E: ID_PATH=pci-0000:01:00.0-scsi-0:2:0:0  
E: ID_PART_TABLE_TYPE=dos  
E: LVM_SBIN_PATH=/sbin  
E: DEVLINKS=/dev/block/8:0 /dev/disk/by-
id/scsi-364403a78570b200018ac2cd20575ec04 /dev/disk/by-
path/pci-0000:01:00.0-scsi-0:2:0:0 /dev/disk/by-
id/wwn-0x64403a78570b200018ac2cd20575ec04  

For multipath devices:

# multipath -ll -v

360080e500024a048000004044f3c64ee dm-0 SUN,LCSM100_F  
size=95G features='1 queue_if_no_path' hwhandler='1 rdac' wp=rw  
|-+- policy='round-robin 0' prio=6 status=active  
| `- 7:0:0:0 sdb 8:16 active ready running  
`-+- policy='round-robin 0' prio=1 status=enabled  
`- 8:0:0:0 sdk 8:160 active ghost running

**Note:** the device uuid is fixed value, the uuid of dm-mp device should be
identical with the uuid of its paths. In most of situation could not be
modified unless the device supports dynamic uuid feature.

**Usage:**

The device uuid often being used to persistent the device name or dm-mpath
name, following example bind the wwid with name oraasm1 persistently.

multipath {  
wwid 36006048caf0b141598afa8e2875797a1  
alias oraasm1  
}

**Note:** the partition (such as sda1 sdb1) does not have uuid.

**2\. File system uuid**

In OL5.x:

# blkid /dev/sda1

/dev/sda1: LABEL="/boot1" UUID="ae298adb-1b94-42a0-9dc9-a121c7561a5b"
TYPE="ext3" SEC_TYPE="ext2"  
  
# /lib/udev/vol_id /dev/sda1  
ID_FS_USAGE=filesystem  
ID_FS_TYPE=ext3  
ID_FS_VERSION=1.0  
ID_FS_UUID=ae298adb-1b94-42a0-9dc9-a121c7561a5b  
ID_FS_LABEL=/boot1  
ID_FS_LABEL_SAFE=boot1

**Note:** the /dev/sdxx must be formated as file system.

**Usage:**

Could specify uuid in /etc/fstab to bind the device with mount directory
persistently.

UUID=xxx-xxx-xxx-xxx /mount_dir ext3 defaults 1 2

**Note:** file system uuid will be changed after re-create file system.

**3\. LVM2 uuid**

# pvs -v  
PV VG Fmt Attr PSize PFree DevSize PV UUID  
/dev/sda2 vg0 lvm2 a-- 48.81G 0 48.83G xCJzmN-oJmL-kMFl-JCrb-lfoH-movY-6x6K6O  
/dev/sda3 vg0 lvm2 a-- 48.81G 0 48.83G 9iXmmM-kKqV-OYDb-eSVN-ymCw-wwVk-uY6fXo  
  
# lvs  
LV VG #Seg Attr LSize Maj Min KMaj KMin Origin Snap% Move Copy% Log Convert LV
UUID  
lvroot vg0 3 -wi-ao 146.44G -1 -1 253 0 C0l0R2-KhH8-N7Nk-BhXn-MJhS-35dn-XXdL1B  
lvasmlib vg1 1 -wi-a- 4.88G -1 -1 253 6 5nlcKy-1kvs-l7qb-eIts-tEs6-E2JG-RisWDx  
  
# vgs -v  
VG Attr Ext #PV #LV #SN VSize VFree VG UUID  
vg0 wz--n- 32.00M 3 1 0 146.44G 0 ereADB-2w9v-O2P9-58OS-RN9Q-t2pV-8wXpSc  
vg1 wz--n- 4.00M 3 3 0 139.71G 9.95G LczKdV-Nq82-lNrr-EmI1-cerd-numb-1qV6m4

**Usage:**

In some case need recover some pv device, use the --uuid and --restorefile
arguments of the pvcreate command to restore the physical volume. The
following command restores the physical volume label with the backuped
metadata. **  
**

# pvcreate --uuid "0YnHNn-1COx-dohx-bwPf-aLyl-pO8F-f5PI5R" --restorefile
/etc/lvm/archive/vg0_00000-1324010847.vg /dev/sda2  
Physical volume "/dev/sda2" successfully created

**Note:** lvm2 uuid will be changed after re-create.  
  
  



---
### TAGS
{UUID}

---
### NOTE ATTRIBUTES
>Created Date: 2017-07-11 02:28:51  
>Last Evernote Update Date: 2018-10-01 15:44:50  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=40548267301445  
>source-url: &  
>source-url: id=1505398.1  
>source-url: &  
>source-url: _adf.ctrl-state=6mllyy5k2_45  