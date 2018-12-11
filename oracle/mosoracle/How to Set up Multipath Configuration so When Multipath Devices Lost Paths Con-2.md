# How to Set up Multipath Configuration so When Multipath Devices Lost Path(s)
Con

How to Set up Multipath Configuration so When Multipath Devices Lost Path(s)
Connectivity, I/O Queued Instead of Failing Path(s) (文档 ID 1629825.1)

  

如何配置多路径，以致当多路径设备丢失链路时，I/O排队等待而不报告链路丢失

| [
![noteattachment1][d74f4ac5869665cf665a5feb44d0f627]转到底部](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=420266174303938&id=1629825.1&_adf.ctrl-
state=2ozdbqi40_72# "转到底部")|
![noteattachment2][5a563b0be47c59aae95d23dce91a7309]  
---|---|---  
  
* * *

![noteattachment3][5a563b0be47c59aae95d23dce91a7309]

 **In this Document**  

|  
|
[Goal](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=420266174303938&id=1629825.1&_adf.ctrl-
state=2ozdbqi40_72#GOAL)  
---|---  
  
|
[Solution](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=420266174303938&id=1629825.1&_adf.ctrl-
state=2ozdbqi40_72#FIX)  
---|---  
  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=420266174303938&id=1629825.1&_adf.ctrl-
state=2ozdbqi40_72#REF)  
---|---  
  
* * *

##  APPLIES TO:

Linux OS - Version Oracle Linux 5.0 to Oracle Linux 5.10 [Release OL5 to
OL5U10]  
Linux OS - Version Oracle Linux 6.0 to Oracle Linux 6.4 [Release OL6 to OL6U4]  
Linux x86  
Linux x86-64  

## GOAL

  

 Sometimes multipath devices path(s) connectivity could lost (which might
caused by, e.g. FC switch port corruption, LUNs in storage system went
offline, server HBA hardware failure, etc.). Set up multipath configuration to
queue I/O than failing path(s) of multipath devices.

有时多路径设备链路可能会丢失（这可能由于
FC（光纤）交换机端口损坏，存储系统LUN掉线，服务器HBA损坏等引起）。配置多路径为I/O排队等待而不是报告多路径设备丢失链路。

## SOLUTION

  

 1\. Install below device-mapper-multipath RPM pakcage:

安装下面的device-mapper-multipath RPM包

Oracle Linux 5.x: device-mapper-multipath-0.4.9-64.0.3.el5 or later.  
Oracle Linux 6.x: device-mapper-multipath-0.4.9-62.0.1.el6 or later.

 **Note:**  If use previous device-mapper-multipath RPM pakcage rather than
specified ones above, I/O will fail even with below configuration due to known
issue: Bug 16389355/Bug 15837419.

注：若使用以前的device-mapper-multipath RPM包，而不是上边指定的；由于Bug 16389355/Bug 15837419
即使使用了下列配置，I/O将报告链路丢失/失败

  

  

2\. Set "flush_on_last_del no" and "no_path_retry queue" in
/etc/multipath.conf.

/etc/multipath.conf中设置flush_on_last_del  no和 no_path_retry  queue

  

  

flush_on_last_del

  

If set to yes, then multipath will disable queuing when the last path to a
device has been deleted.

multipath

若设置为yes，当最后一条链路被删除后，multipath将不在使用I/O排队等待

  

  

no_path_retry

  

A numeric value for this attribute specifies the number of times the system
should attempt to use a failed path before disabling queuing.

  

  

A value of _  fail_ indicates immediate failure, without queuing.

fail表示：不I/O排队等待，立即报告链路失败

  

A value of  _queue_  indicates that queuing should not stop until the path is
fixed.

queue表示：I/O一直排队等待，直到链路恢复  

  

Restart multipathd service to apply changes in configuration file:

重启multipathd服务使配置文件的改变失效

# service multipathd restart



  

Sample multipath device "blue":

样本多路径设备“blue”

[root@oraclelinux ~]# multipathd show topology  
blue (3600144f0adf5cc4c0000512c77ae0001) dm-8 SUN,ZFS Storage 7120  
size=100G features='1 queue_if_no_path' hwhandler='0' wp=rw  
`-+- policy='round-robin 0' prio=130 status=enabled  
  |- 8:0:0:16 sde 8:64  active ready running  
  |- 8:0:1:16 sdj 8:144 active ready running  
  |- 9:0:0:16 sdo 8:224 active ready running  
  `- 9:0:1:16 sdt 65:48 active ready running



  

3\. When path /dev/sdj in "blue" lost connectivity, I/O will be queued,
instead of failing path after I/O error with error message(s) in dmesg/system
logs such as "device-mapper: multipath: Failing path 8:144":

当/dev/sdj链路丢失，I/O将排队等待，而不是在dmesg/系统日志中 I/O error后产生类似 "device-mapper:
multipath: Failing path 8:144"的错误信息

blue (3600144f0adf5cc4c0000512c77ae0001) dm-8 SUN,ZFS Storage 7120  
size=100G features='1 queue_if_no_path' hwhandler='0' wp=rw  
`-+- policy='round-robin 0' prio=130 status=active  
  |- 8:0:0:16 sde 8:64  active ready running  
  |- 9:0:0:16 sdo 8:224 active ready running  
  `- 9:0:1:16 sdt 65:48 active ready running

  
System logs:

Mar  2 03:27:51 oraclelinux kernel: sd 8:0:1:16: [sdj] Unhandled error code  
Mar  2 03:27:51 oraclelinux kernel: sd 8:0:1:16: [sdj] Result:
hostbyte=DID_NO_CONNECT driverbyte=DRIVER_OK  
Mar  2 03:27:51 oraclelinux kernel: sd 8:0:1:16: [sdj] CDB: Read(10): 28 00 01
16 b6 e0 00 01 00 00  
Mar  2 03:27:51 oraclelinux kernel: end_request: I/O error, dev sdj, sector
18265824  
Mar  2 03:27:51 oraclelinux multipathd: blue: remaining active paths: 3  
Mar  2 03:27:52 oraclelinux kernel: sd 8:0:1:16: [sdj] Unhandled error code  
Mar  2 03:27:52 oraclelinux kernel: sd 8:0:1:16: [sdj] Result:
hostbyte=DID_NO_CONNECT driverbyte=DRIVER_OK  
Mar  2 03:27:52 oraclelinux kernel: sd 8:0:1:16: [sdj] CDB: Read(10): 28 00 00
00 00 00 00 00 08 00  
Mar  2 03:27:52 oraclelinux multipathd: sdj: remove path (uevent)  
Mar  2 03:27:52 oraclelinux kernel: end_request: I/O error, dev sdj, sector 0  
Mar  2 03:27:52 oraclelinux multipathd: blue: load table [0 209715200
multipath 1 queue_if_no_path 0 1 1 round-robin 0 3 1 8:64 1 8:224 1 65:48 1]  
Mar  2 03:27:52 oraclelinux multipathd: sdj: path removed from map blue  
Mar  2 03:28:37 oraclelinux kernel: sd 8:0:1:16: [sdj] 209715200 512-byte
logical blocks: (107 GB/100 GiB)  
Mar  2 03:28:37 oraclelinux kernel: sd 8:0:1:16: [sdj] Write Protect is off  
Mar  2 03:28:37 oraclelinux kernel: sd 8:0:1:16: [sdj] Write cache: disabled,
read cache: enabled, doesn't support DPO or FUA  
Mar  2 03:28:37 oraclelinux kernel:  sdj:  
Mar  2 03:28:38 oraclelinux kernel: sd 8:0:1:16: [sdj] Attached SCSI disk  
Mar  2 03:28:38 oraclelinux multipathd: sdj: add path (uevent)  
Mar  2 03:28:38 oraclelinux multipathd: blue: load table [0 209715200
multipath 1 queue_if_no_path 0 1 1 round-robin 0 4 1 8:64 1 8:224 1 65:48 1
8:144 1]  
Mar  2 03:28:38 oraclelinux multipathd: sdj path added to devmap blue  
Mar  2 03:28:50 oraclelinux multipathd: blue: sdo - directio checker reports
path is up  
Mar  2 03:28:50 oraclelinux multipathd: blue: remaining active paths: 4



## REFERENCES  
  
  

  

  

总结：

multipath配置"flush_on_last_del no" and "no_path_retry
queue"，dmesg/系统日志不再报告链路丢失，而是进行I/O排队，等待链路恢复。


---
### ATTACHMENTS
[5a563b0be47c59aae95d23dce91a7309]: media/How_to_Set_up_Multipath_Configuration_so_When_Multipath_Devices_Lost_Paths_Con-3.gif
[How_to_Set_up_Multipath_Configuration_so_When_Multipath_Devices_Lost_Paths_Con-3.gif](media/How_to_Set_up_Multipath_Configuration_so_When_Multipath_Devices_Lost_Paths_Con-3.gif)
[d74f4ac5869665cf665a5feb44d0f627]: media/How_to_Set_up_Multipath_Configuration_so_When_Multipath_Devices_Lost_Paths_Con-4.gif
[How_to_Set_up_Multipath_Configuration_so_When_Multipath_Devices_Lost_Paths_Con-4.gif](media/How_to_Set_up_Multipath_Configuration_so_When_Multipath_Devices_Lost_Paths_Con-4.gif)
---
### NOTE ATTRIBUTES
>Created Date: 2017-05-11 02:54:35  
>Last Evernote Update Date: 2017-05-11 04:35:09  
>author: YangKwong  
>source: desktop.win  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=420266174303938  
>source-url: &  
>source-url: id=1629825.1  
>source-url: &  
>source-url: _adf.ctrl-state=2ozdbqi40_72  
>source-application: evernote.win32  