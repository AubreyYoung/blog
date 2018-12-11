# Oracle-安装手册-RAC_11gR2_for_AIX.html

# Oracle-安装手册-RAC_11gR2_for_AIX

# 瀚高技术支持管理平台

 **新特性**

  * Oracle 11gR2将自动存储管理(ASM)和Oracle Clusterware集成在Oracle Grid Infrastructure中。Oracle ASM和Oracle Database 11gR2提供了较以前版本更为增强的存储解决方案，该解决方案能够在ASM上存储Oracle Clusterware文件，即Oracle集群注册表(OCR)和表决文件（VF，又称为表决磁盘）。这一特性使ASM能够提供一个统一的存储解决方案，无需使用第三方卷管理器或集群文件系统即可存储集群件和数据库的所有数据

  * SCAN（single client access name）即简单客户端连接名，一个方便客户端连接的接口；在Oracle 11gR2之前，client链接数据库的时候要用vip，假如cluster有4个节点，那么客户端的tnsnames.ora中就对应有四个主机vip的一个连接串，如果cluster增加了一个节点，那么对于每个连接数据库的客户端都需要修改这个tnsnames.ora。SCAN简化了客户端连接，客户端连接的时候只需要知道这个名称，并连接即可，每个SCAN VIP对应一个scan listener，cluster内部的service在每个scan listener上都有注册，scan listener接受客户端的请求，并转发到不同的Local listener中去，由local的listener提供服务给客户端

  * 此外，安装GRID的过程也简化了很多，内核参数的设置可保证安装的最低设置，验证安装后执行fixup.sh即可，此外ssh互信设置可以自动完成，尤其不再使用OCFS及其复杂设置，直接使用ASM存储

 **1、需要系统工程师完成的工作**

1、设置网卡IP地址，保证2个节点的公共网卡和私有网卡名称顺序完全一致。如果需要做网卡绑定，尽量在安装RAC之前完成。

2、操作系统安装图形界面

3、/tmp空间大于7G，/u01 100G的空间 /u02 100G的空间

4、swap空间要求如下

 **Available RAM**

|

 **Swap Space    Required**  
  
---|---  
  
Between 2 GB and 8 GB

|

2 times the size of RAM  
  
Between 8 GB and 32 GB

|

1.5 times the size of RAM  
  
More than 32 GB

|

32 GB  
  
5、rac的内联心跳网络使用独立的千M 网络交换机，若是没有独立的千M 网络交换机。 也可以使用公共的千M
网络交换机，此时，需要对交换机上连接rac节点的两个网口划出独立的vlan，使这rac节点间的内联心跳网络使用独立的vlan进行相互通信，并且需要设置qos以保证rac节点间的内联心跳网络所使用的带宽不被其他的网络流量挤占。如果用户有条件的情况最好建议使用光纤接口卡以满足cache
fusion的高传输速率、高带宽要求）

6、安装最新的操作系统补丁，打上相关的操作系统包

AIX 5.3 required packages:

bos.adt.base

bos.adt.lib

bos.adt.libm

bos.perf.libperfstat 5.3.9.0 or later

bos.perf.perfstat

bos.perf.proctools

rsct.basic.rte (For RAC configurations only)

rsct.compat.clients.rte (For RAC configurations only)

xlC.aix50.rte:10.1.0.0 or later

xlC.rte.10.1.0.0 or later

gpfs.base 3.2.1.8 or later (Only for RAC systems that will use GPFS cluster
filesystems)

AIX 6.1 required packages:

bos.adt.base

bos.adt.lib

bos.adt.libm

bos.perf.libperfstat 6.1.2.1 or later

bos.perf.perfstat

bos.perf.proctools

rsct.basic.rte (For RAC configurations only)

rsct.compat.clients.rte (For RAC configurations only)

xlC.aix61.rte:10.1.0.0 or later

xlC.rte.10.1.0.0 or later

gpfs.base 3.2.1.8 or later (Only for RAC systems that will use GPFS cluster
filesystems)

AIX 7.1 required packages:

bos.adt.base

bos.adt.lib

bos.adt.libm

bos.perf.libperfstat

bos.perf.perfstat

bos.perf.proctools

xlC.rte.11.1.0.2 or later

gpfs.base 3.3.0.11 or later (Only for RAC systems that will use GPFS cluster
filesystems)

Authorized Problem Analysis Reports (APARs) for AIX 5.3:

IZ42940

IZ49516

IZ52331

See Note:1379908.1 for other AIX 5.3 patches that may be required

APARs for AIX 7.1: （其他补充补丁参考下面的APARs for AIX 6.1部分）

IZ87216

IZ87564

IZ89165

IZ97035

See[Note:1264074.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=169706.1&id=1264074.1)and[Note:1379908.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=169706.1&id=1379908.1)for
other AIX 7.1 patches that may be required

APARs for AIX 6.1:

 **IZ41855**

 **IZ51456**

 **IZ52319**

#如果aix高于6100-06-04-1112 则以上三个包可以不必打。

参考：

 **   http://www-01.ibm.com/support/docview.wss?uid=tss1wp102042&aid=1**

 **IZ97457**

 **IZ89165**

#以上两个补丁根据如下文章根据OS 的TL安装对应的补丁包。

 **  11gR2 OUI On AIX Pre-Requisite Check Gives Error "Patch IZ97457, IZ89165
Are Missing" (** **文档 ID 1439940.1)**

 **  不同的内核有可能所需补丁的名称不一样，参考**



![noteattachment1][e3462a4c2a9a0a21b060552511ce7efb]

另外根据TL版本选择如下需要打的补丁（mos: 1264074.1）

IZ89304 for AIX 6.1 TL3  
IZ89302 for AIX 6.1 TL4  
IZ89300 for AIX 6.1 TL5  
IZ88711 or IZ89514 for AIX 6.1 TL6 - check with IBM  
IZ89165 for AIX 7.1 TL0 SP2

根据TL版本选择如下需要打的补丁（mos：1379908.1）

5.3 TL11 - iv10538  
5.3 TL12 - iv11158  
6.1 TL4 - iv11167  
6.1 TL5 - iv10576  
6.1 TL6 - iv10539  
6.1 TL7 - iv09580  
7.1 TL0 - unaffected  
7.1 TL1 - iv09541

See Note:1264074.1 andNote:1379908.1 for other AIX 6.1 patches that may be
required

 **AIX** **补丁下载地址** **：** **ftp://public.dhe.ibm.com/aix/efixes/**

 **参考文章** **Oracle Database (RDBMS) on Unix AIX,HP-UX,Linux,Mac OS
X,Solaris,Tru64 Unix Operating Systems Installation and Configuration
Requirements Quick Reference (8.0.5 to 11.2) (** **文档** **ID 169706.1)**

 **Linking Fails With "ld: 0706-010 The binder was killed by a signal:
Segmentation fault" On AIX 6.1 And AIX 7.1 (** **文档** **ID 1264074.1)**

 **" ld: 0711-780 SEVERE ERROR: Symbol .ksmpclrpga" and "ORA-7445
[KSMPCLRPGA()+23248]" (** **文档** **ID 1379908.1)**

 7、安装ssh，安装unzip（可选）

8、存储工程师从存储划出5块5G磁盘，其余用于存放数据库
数据的磁盘按每块1T的大小划分，如果存放数据库备份文件，也请规划好空间，各个磁盘是独立的lun，若是使用多路径的话，需要存储工程师把多路径软件在rac的所有节点上调试完毕。确保所有节点上看到的hdisk
number完全一致。

9、系统工程师设置主机名

   注意主机名不能过长,不能超过8个字符，且不能有下划线等特殊符号，不要使用大写字母，建议使用小写字母即可。

10、可以使用xmanager访问图形界面。

11、检查HACMP

  检查当前AIX系统上是否有HACMP组件，如果有和客户确认，如果可以则建议客户联系AIX小机工程师删除，避免HACMP对rac影响。

  lslpp -h "cluster*"

 **2、 验证系统要求**

要验证系统是否满足 Oracle 11 _g_ 数据库的最低要求，以 root 用户身份登录并运行以下命令。

要查看可用 RAM 和交换空间大小，运行以下命令：

# /usr/sbin/lsattr -E -l sys0 -a realmem

# /usr/sbin/lsps -a

例如：

 **# /usr/sbin/lsattr -E -l sys0 -a realmem**

realmem 130547712 Amount of usable physical memory in Kbytes False

 **# /usr/sbin/lsps -a**

Page Space     Physical Volume   Volume Group Size %Used Active  Auto  Type
Chksum

hd6             hdisk0            rootvg         512MB     2   yes   yes    lv
0

若不够，需要增加PPS数。本系统一个PPS为512M，所以增加63个，使swap达到32G。PPS大小可以通过lsvg rootvg查看。

# chps -s 63 hd6

确认系统结构

# /usr/bin/getconf HARDWARE_BITMODE

64

# bootinfo -K

64

# oslevel -r

6100-09

系统版本最低要求： _注（_ _mos ID 169706.1 AIX OS_ _）_

AIX 5L V5.3 TL 09 SP1 ("5300-09-01") or higher, 64 bit kernel (Part Number
E10854-01)

AIX 6.1 TL 02 SP1 ("6100-02-01") or higher, 64-bit kernel

AIX 7.1 TL 00 SP1 ("7100-00-01") or higher, 64-bit kernel

查看主机名

# uname –n

hisrac1

修改：

# smit hostname

查看本地磁盘空间

# df -g

Filesystem    GB blocks      Free %Used    Iused %Iused Mounted on

/dev/hd4           1.00      0.81   19%    10532     6% /

/dev/hd2           5.00      2.60   49%    52862     8% /usr

/dev/hd9var        1.00      0.69   32%     8769     6% /var

/dev/hd3           0.50      0.49    2%       51     1% /tmp

/dev/fwdump        1.50      1.50    1%        4     1% /var/adm/ras/platform

/dev/hd1           0.50      0.50    1%        5     1% /home

/dev/hd11admin      0.50      0.50    1%        5     1% /admin

/proc                 -         -    -         -     -  /proc

/dev/hd10opt       0.50      0.27   46%    10420    14% /opt

/dev/livedump      0.50      0.50    1%        4     1% /var/adm/ras/livedump

/aha                  -         -    -        16     1% /aha

如某个空间不足，添加方法：

先查看rootvg，确定可使用的空间大小

# lsvg rootvg

VOLUME GROUP:       rootvg      VG IDENTIFIER:
00f9ed6500004c0000000154c7f6ed9b

VG STATE:           active                PP SIZE:        512 megabyte(s)

VG PERMISSION:      read/write            TOTAL PPs:      558 (285696
megabytes)

MAX LVs:            256                   FREE PPs:       525 (268800
megabytes)

LVs:                13                    USED PPs:       33 (16896 megabytes)

OPEN LVs:           12                    QUORUM:         2 (Enabled)

TOTAL PVs:          1                     VG DESCRIPTORS: 2

STALE PVs:          0                     STALE PPs:      0

ACTIVE PVs:         1                     AUTO ON:        yes

MAX PPs per VG:     32512  

MAX PPs per PV:     1016                     MAX PVs:        32

LTG size (Dynamic): 1024 kilobyte(s)         AUTO SYNC:      no

HOT SPARE:          no                       BB POLICY:      relocatable

PV RESTRICTION:     none                     INFINITE RETRY: no

DISK BLOCK SIZE:    512  

添加命令：

# chfs -a size=+10G /home

Filesystem size changed to 22020096

# chfs -a size=+10G /tmp

Filesystem size changed to 22020096

创建/u01和/u02文件系统

# mkdir /u01

# mkdir /u02

# crfs -v jfs2 -g rootvg -a size=80G -m /u01

# crfs -v jfs2 -g rootvg -a size=80G -m /u02

# mount /u01

# mount /u02

# vi /etc/filesystems

/u01:

        dev             = /dev/fslv00

        vfs             = jfs2

        log             = /dev/hd8

        mount           = true

        account         = false

/u02:

        dev             = /dev/fslv01

        vfs             = jfs2

        log             = /dev/hd8

        mount           = true

        account         = false

查看时区和时间

# grep TZ /etc/environment

# date

修改时区为上海

smitty --> System Environments -->Change/Show Data and Time -->Change Time
Zone Using System Defined Value

 **参考文章How To Change Timezone for Grid Infrastructure (** **文档 ID 1209444.1)**

查看是否安装图形界面

# ps -ef | grep dtlogin

    root 3866778       1   0 00:17:35      -  0:00 /usr/dt/bin/dtlogin -daemon

查看操作系统日志

# /bin/errpt -a

 **3、网络配置**

Hosts文件配置

每个主机vi /etc/hosts

10.20.8.31 slyy01

10.20.8.33 slyy02

10.20.8.32 slyy01-vip

10.20.8.34 slyy02-vip

2.2.2.2    slyy01-priv

2.2.2.3    slyy02-priv

10.20.8.30 scan

rac1、rac2 对应的是网卡的物理ip ，即public ip

rac1-priv、rac2-priv 对应的是心跳网卡的物理ip  即private ip

rac1-vip、rac2-vip 对应的是虚拟VIP

scan对应的SCAN ip

建议客户客户端连接rac群集，访问数据库时使用  SCAN  ip地址。

 **注意** **：** **vip** **、** **public ip** **、** **scan ip** **必须要在同一个子网网段中。**

 **另外** **对于心跳** **IP** **地址的设置** **，** **不要设置成和客户局域网中存在的** **ip** **网段。**

 **如客户网络是** **192.x.x.x** **则设置心跳为** **10.x.x.x   ,**
**心跳地址工程师可以自定义，但也要和客户确认客户局域网络是否有相同** **ip** **地址的服务器，尽量避免干扰。**

 **配置完心跳地址后** **,** **一定要使用** **traceroute** **测试心跳网络之间通讯是否正常** **.**
**心跳通讯是否正常不能简单地通过** **ping** **命令来检测** **.** **一定要使用** **traceroute**
**默认是采用** **udp** **协议** **.** **每次执行** **traceroute** **会发起三次检测** **,***
**号表示通讯失败** **.**

 **正常** **:**

 **[root@rac1 ~]# traceroute rac2-priv**

 **traceroute to rac2-priv (192.168.122.132), 30 hops max, 60 byte packets**

 **lsrac2-priv (192.168.122.132)   0.802 ms  0.655 ms  0.636 ms**

 **不正常** **:**

 **[root@lsrac1 ~]# traceroute rac2-priv**

 **traceroute to rac2-priv (192.168.122.132), 30 hops max, 60 byte packets**

 **  1  lsrac2-priv (192.168.122.132)  1.187 ms * ***

 **如果经常出现** ***** **则需要先检测心跳网络通讯是否正常** **.**

 **4、安装软件包**

将需要安装的软件包和补丁包列表提供给AIX系统工程师，要求AIX工程师进行安装。

 **参考文档Oracle Database (RDBMS) on Unix AIX,HP-UX,Linux,Mac OS X,Solaris,Tru64
Unix Operating Systems Installation and Configuration Requirements Quick
Reference (8.0.5 to 11.2) (** **文档 ID 169706.1)**

查看软件包是否安装命令

# lslpp -l <软件名>

查看补丁包是否安装命令

# /usr/sbin/instfix -i –k “<补丁包>”

例：# lslpp -l bos.adt.base

       # /usr/sbin/instfix -i -k "IZ41855"

# lslpp -l bos.adt.base bos.adt.lib bos.adt.libm bos.perf.libperfstat
bos.perf.perfstat bos.perf.proctools rsct.basic.rte rsct.compat.clients.rte
xlC.aix61.rte xlC.rte gpfs.base

  Fileset                      Level  State      Description  

\----------------------------------------------------------------------------

Path: /usr/lib/objrepos

  bos.adt.base               6.1.9.0  COMMITTED  Base Application Development

                                                 Toolkit

  bos.adt.lib                6.1.8.0  COMMITTED  Base Application Development

                                                 Libraries

  bos.adt.libm               6.1.9.0  COMMITTED  Base Application Development

                                                 Math Library

  bos.perf.libperfstat       6.1.9.0  COMMITTED  Performance Statistics
Library

                                                 Interface

  bos.perf.perfstat          6.1.9.0  COMMITTED  Performance Statistics

                                                 Interface

  bos.perf.proctools         6.1.9.0  COMMITTED  Proc Filesystem Tools

  rsct.basic.rte             3.1.5.0  COMMITTED  RSCT Basic Function

  rsct.compat.clients.rte    3.1.5.0  COMMITTED  RSCT Event Management Client

                                                 Function

  xlC.aix61.rte             12.1.0.1  COMMITTED  IBM XL C++ Runtime for AIX
6.1

                                                 and 7.1

  xlC.rte                   12.1.0.1  COMMITTED  IBM XL C++ Runtime for AIX

Path: /etc/objrepos

  bos.adt.base               6.1.9.0  COMMITTED  Base Application Development

                                                 Toolkit

  bos.perf.libperfstat       6.1.9.0  COMMITTED  Performance Statistics
Library

                                                 Interface

  bos.perf.perfstat          6.1.9.0  COMMITTED  Performance Statistics

                                                 Interface

  rsct.basic.rte             3.1.5.0  COMMITTED  RSCT Basic Function

lslpp: 0504-132  Fileset gpfs.base not installed.

# /usr/sbin/instfix -i -k "IZ41855 IZ51456 IZ52319 IZ97457 IZ89165"

    There was no data for IZ41855 in the fix database.

    There was no data for IZ51456 in the fix database.

    There was no data for IZ52319 in the fix database.

    There was no data for IZ97457 in the fix database.

    There was no data for IZ89165 in the fix database.

 **如果** **AIX** **工程师可以提供更新的替代补丁，以** **AIX** **工程师提供为准。**

依据mos文章

AIX 6.1 TL8 or 7.1 TL2: 11gR2 GI Second Node Fails to Join the Cluster as CRSD
and EVMD are in INTERMEDIATE State (文档 ID 1528452.1)

11.2.0.1 and later版本实施AIX RAC时如果发现操作系统版本是  6.1 TL8 or 7.1 TL2,

则要IBM工程师升级TL版本或安装SP补丁

AIX 6.1 TL08 SP01

APAR IV35888: UDP MULTICAST: SHORT PACKET FOR SOME LISTENERS. 13/02/08 PTF
PECHANGE  
[http://www-01.ibm.com/support/docview.wss?uid=isg1IV35888&myns=apar&mynp=DOCTYPEcomponent&mync=E](http://www-01.ibm.com/support/docview.wss?uid=isg1IV35888&myns=apar&mynp=DOCTYPEcomponent&mync=E
"AIX 6.1 TL8")

AIX 7.1 TL02 SP01

APAR IV35893: UDP MULTICAST: SHORT PACKET FOR SOME LISTENERS. 13/02/08 PTF
PECHANGE  
[http://www-01.ibm.com/support/docview.wss?uid=isg1IV35893&myns=apar&mynp=DOCTYPEcomponent&mync=E](http://www-01.ibm.com/support/docview.wss?uid=isg1IV35893&myns=apar&mynp=DOCTYPEcomponent&mync=E
"AIX 7.1 TL2")

 **5、内核参数**

#vmo -L  \--可通过该命令查看参数设置

调整FileSystemCache大小 :

#vmo -p -o minperm%=5

#vmo -p -o maxclient%=20

#vmo -p -o maxperm%=20

#vmo -p -o maxpin%=80

#vmo -p -o strict_maxperm=0

#vmo -p -o lru_file_repage=0

#vmo -p -o strict_maxclient=1

#vmo -r -o page_steal_method=1; 需要重启生效

修改参数ncargs   _注（_ _mos ID 169706.1 AIX Kernel Settings_ _）_

# /usr/sbin/chdev -l sys0 -a ncargs='128'

修改参数 masuproc   _注（_ _mos ID 169706.1 AIX Kernel Settings_ _）_

# chdev -l sys0 -a maxuproc='16384'

# lsattr -E -l sys0 -a maxuproc

maxuproc 16384 Maximum number of PROCESSES allowed per user True

检查UDP和TCP内核参数：

# no -a|grep space

修改

查看是否运行在兼容模式下

# lsattr -E -l sys0 -a pre520tune

pre520tune disable Pre-520 tuning compatibility mode True

如果运行在兼容模式下：

修改/etc/rc.net，添加如下内容：

if [ -f /usr/sbin/no ]; then

/usr/sbin/no -o udp_sendspace=65536

/usr/sbin/no -o udp_recvspace=655360

/usr/sbin/no -o tcp_sendspace=65536

/usr/sbin/no -o tcp_recvspace=65536

/usr/sbin/no -o rfc1323=1

/usr/sbin/no -o sb_max=4194304

/usr/sbin/no -o ipqmaxlen=512

fi

如果不是运行在兼容模式下：

/usr/sbin/no -r -o ipqmaxlen=512

/usr/sbin/no -p -o rfc1323=1

/usr/sbin/no -p -o sb_max=4194304

/usr/sbin/no -p -o tcp_recvspace=65536

/usr/sbin/no -p -o tcp_sendspace=65536

/usr/sbin/no -p -o udp_recvspace=655360

/usr/sbin/no -p -o udp_sendspace=65536

检查当前的临时端口范围 _注（_ _mos ID 169706.1 AIX Kernel Settings_ _）_

# /usr/sbin/no -a | fgrep ephemeral

     tcp_ephemeral_low = 32768

     tcp_ephemeral_high = 65535

     udp_ephemeral_low = 32768

     udp_ephemeral_high = 65535

修改

# /usr/sbin/no -p -o tcp_ephemeral_low=9000 -o tcp_ephemeral_high=65500

# /usr/sbin/no -p -o udp_ephemeral_low=9000 -o udp_ephemeral_high=65500

AIX平台设置AIXTHREAD_SCOPE提高多任务应用程序（Oracle）的性能

在配置文件/etc/environment中添加以下的参数

AIXTHREAD_SCOPE=S

注意：AIX 6.x及以后版本不需要设置，其自动开启

Why "AIXTHREAD_SCOPE" Should Be Set To 'S' On AIX (Doc ID 458403.1)

 **6、配置异步IO**

查看异步IO：

On AIX 6.1 and AIX 7.1:

# ioo -o aio_maxreqs  或 # ioo -F -a | grep -i aio

aio_maxreqs = 65536

On AIX 5.3:

# lsattr -El aio0 -a maxreqs

maxreqs 65536 Maximum number of REQUESTS True

修改：

# chdev -P -l aio0 -a maxreqs=65536            AIX5.3

# ioo -p -o aio_maxreqs=65536                  AIX6.1

 **7、 修改操作系统时间**

检查多个服务器节点的操作系统时间是否一致。如果不一致要先手动修改。

如何同时修改两C台或者多台主机的时间一模一样呢？

建议使用SecureCRT工具、

使用方法：先登录一台主机

![noteattachment2][b1dd40ca6756ab53dc5bffbf348baa6f]

然后登录第二台主机

![noteattachment3][9b24e34bab9b46d80af8bbad357738b2]

打开查看菜单，勾选交互窗口

![noteattachment4][e44a7029b80405829625776f3754974e]

窗口下方出现交互窗口

![noteattachment5][3c53d6a4a43d1de9eb5e25221a4e642f]

在交互窗口上右键菜单，勾选发送交互到所有会话。（此时要注意这个CRT窗口必须只能有RAC的两台服务器，不能有到其他主机的远程连接会话）

![noteattachment6][b391f63198892626fe407c03043fb5f5]

然后此时在交互窗口里输入的命令回车后都会自动发送到所有主机上执行。

AIX修改时间的命令是  ：date -n mmddHHMMYY，mm表示月分，dd表示日期，HH表示小时，MM表示分钟，YY表示年份。

# date -n 0612103716

关闭NTP服务

Network Time Protocol Setting

# mv /etc/ntp.conf /etc/ntp.conf.bak

一定要保证时间同步，但是不能配置ntp，否则会导致11g的ctssd处于旁观模式。如果客户严格要求和北京时间一致，则考虑让客户提供时间服务器，然后再采用NTP和其时间服务器同步。如果配置NTP注意参数
-x 保证时间不能向回调，关于NTP配置此处不做详细解释。

 **8、添加用户和组、创建目录**

 **描述**

|

 **OS** **组名**

|

 **分配给该组的 OS 用户**

|

 **Oracle** **权限**

|

 **Oracle** **组名**  
  
---|---|---|---|---  
  
Oracle 清单和软件所有者

|

oinstall

|

grid、oracle

| |  
  
Oracle 自动存储管理组

|

asmadmin

|

grid

|

SYSASM

|

OSASM  
  
ASM 数据库管理员组

|

asmdba

|

grid、oracle

|

ASM 的 SYSDBA

|

OSDBA for ASM  
  
ASM 操作员组

|

asmoper

|

grid

|

ASM 的   SYSOPER

|

OSOPER for ASM  
  
数据库管理员

|

dba

|

oracle

|

SYSDBA

|

OSDBA  
  
数据库操作员

|

oper

|

oracle

|

SYSOPER

|

OSOPER  
  
  * Oracle 清单组（一般为 oinstall）

OINSTALL 组的成员被视为 Oracle 软件的“所有者”，拥有对 Oracle 中央清单 (oraInventory) 的写入权限。在一个
Linux 系统上首次安装 Oracle 软件时，OUI 会创建 /etc/oraInst.loc 文件。该文件指定 Oracle 清单组的名称（默认为
oinstall）以及 Oracle 中央清单目录的路径。

如果不存在 oraInventory 组，默认情况下，安装程序会将集群的网格基础架构的安装所有者的主组列为 oraInventory 组。确保所有计划的
Oracle 软件安装所有者都使用此组作为主组。就本指南来说，必须将 grid 和 oracle 安装所有者配置为以 oinstall 作为其主组。

  * Oracle 自动存储管理组（一般为 asmadmin）

此组为必需组。如果想让 Oracle ASM 管理员和 Oracle Database 管理员分属不同的管理权限组，可单独创建此组。在 Oracle
文档中，OSASM 组是其成员被授予权限的操作系统组，在代码示例中，专门创建了一个组来授予此权限，此组名为 asmadmin。

OSASM 组的成员可通过操作系统身份验证使用 SQL 以 SYSASM 身份连接到一个 Oracle ASM 实例。SYSASM 权限是在 Oracle
ASM 11 _g_ 第 1 版 (11.1) 中引入的，现在，在 Oracle ASM 11 _g_ 第 2 版 (11.2) 中，该权限已从
SYSDBA 权限中完全分离出来。SYSASM 权限不再提供对 RDBMS 实例的访问权限。用 SYSASM 权限代替 SYSDBA
权限来提供存储层的系统权限，这使得 ASM
管理和数据库管理之间有了清晰的责任划分，有助于防止使用相同存储的不同数据库无意间覆盖其他数据库的文件。SYSASM
权限允许执行挂载和卸载磁盘组及其他存储管理任务。

  * ASM 数据库管理员组（OSDBA for ASM，一般为 asmdba）

ASM 数据库管理员组（OSDBA for ASM）的成员是 SYSASM 权限的一个子集，拥有对 Oracle ASM 管理的文件的读写权限。Grid
Infrastructure 安装所有者 (grid) 和所有 Oracle Database 软件所有者 (oracle)
必须是该组的成员，而所有有权访问 Oracle ASM 管理的文件并且具有数据库的 OSDBA 成员关系的用户必须是 ASM 的 OSDBA 组的成员。

  * ASM 操作员组（OSOPER      for ASM，一般为 asmoper）

该组为可选组。如果需要单独一组具有有限的 Oracle ASM 实例管理权限（ASM 的 SYSOPER 权限，包括启动和停止 Oracle ASM
实例的权限）的操作系统用户，则创建该组。默认情况下，OSASM 组的成员将拥有 ASM 的 SYSOPER 权限所授予的所有权限。

要使用 ASM 操作员组创建 ASM 管理员组（该组拥有的权限比默认的 asmadmin 组要少），安装 Grid Infrastructure
软件时必须选择 Advanced 安装类型。这种情况下，OUI 会提示您指定该组的名称。在本指南中，该组为 asmoper。

如果要拥有一个 OSOPER for ASM 组，则集群的 Grid Infrastructure 软件所有者 (grid) 必须为此组的一个成员。

  * 数据库管理员（OSDBA，一般为 dba）

OSDBA 组的成员可通过操作系统身份验证使用 SQL 以 SYSDBA 身份连接到一个 Oracle
实例。该组的成员可执行关键的数据库管理任务，如创建数据库、启动和关闭实例。该组的默认名称为 dba。SYSDBA
系统权限甚至在数据库未打开时也允许访问数据库实例。对此权限的控制完全超出了数据库本身的范围。

不要混淆 SYSDBA 系统权限与数据库角色 DBA。DBA 角色不包括 SYSDBA 或 SYSOPER 系统权限。

  * 数据库操作员组（OSOPER，一般为 oper）

OSOPER 组的成员可通过操作系统身份验证使用 SQL 以 SYSOPER 身份连接到一个 Oracle
实例。这个可选组的成员拥有一组有限的数据库管理权限，如管理和运行备份。该组的默认名称为 oper。SYSOPER
系统权限甚至在数据库未打开时也允许访问数据库实例。对此权限的控制完全超出了数据库本身的范围。要使用该组，选择 Advanced 安装类型来安装 Oracle
数据库软件。

mkgroup -'A' id='1000' adms='root' oinstall

mkgroup -'A' id='1100' adms='root' asmadmin

mkgroup -'A' id='1200' adms='root' dba

mkgroup -'A' id='1300' adms='root' asmdba

mkgroup -'A' id='1301' adms='root' asmoper

mkgroup -'A' id='1201' adms='root' oper

mkuser id='1100' pgrp='oinstall' groups='asmadmin,asmdba,asmoper'
home='/home/grid' grid

mkuser id='1101' pgrp='oinstall' groups='dba,oper,asmdba' home='/home/oracle'
oracle

修改grid、oracle 用户密码

passwd grid

passwd oracle

创建grid目录

# mkdir -p  /u01/app/11.2.0/grid

# chown –R grid:oinstall /u01/

# chmod –R 775 /u01/

    
    
    创建oracle目录

# mkdir -p  /u02/app/oracle/product/11.2.0/db_home

# chown –R oracle:oinstall /u02/

# chmod -R 775 /u02/

设置oracle用户和grid用户系统相关权限

# chuser capabilities=CAP_NUMA_ATTACH,CAP_BYPASS_RAC_VMM,CAP_PROPAGATE grid

# chuser capabilities=CAP_NUMA_ATTACH,CAP_BYPASS_RAC_VMM,CAP_PROPAGATE oracle

查看：

/usr/bin/lsuser -a capabilities grid

修改grid用户环境变量

登录rac节点1

cd /home/grid/

vi .profile

umask 022

if [ -t 0 ]; then

stty intr ^C

fi

export ORACLE_BASE=/u01/app/grid

export ORACLE_HOME=/u01/app/11.2.0/grid

export ORACLE_SID=+ASM1

export PATH=$ORACLE_HOME/bin:$PATH

export

 **注意：** **grid** **用户环境变量** **ORACLE_HOME** **不在** **ORACLE_BASE** **目录下**

 **su - oracle**

修改oracle 用户环境变量,其中ORACLE_SID ，让开发商定好数据库名称，SID后面分别添加1和2。

cd /home/oracle

vi .profile

umask 022

if [ -t 0 ]; then

stty intr ^C

fi

export ORACLE_SID=orcl1

export ORACLE_BASE=/u02/app/oracle

export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1

export PATH=$ORACLE_HOME/bin:$PATH

export LIBPATH=$ORACLE_HOME/lib:$ORACLE_HOME/rdbms/lib:/lib:/usr/lib

export
CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib:$ORACLE_HOME/network/jlb

export ORACLE_OWNER=oracle

登录RAC节点2

cd /home/grid/

vi .profile

umask 022

if [ -t 0 ]; then

stty intr ^C

fi

export ORACLE_BASE=/u01/app/grid

export ORACLE_HOME=/u01/app/11.2.0/grid

export ORACLE_SID=+ASM2

export PATH=$ORACLE_HOME/bin:$PATH

export

 **注意：** **grid** **用户环境变量** **ORACLE_HOME** **不在** **ORACLE_BASE** **目录下**

修改oracle 用户环境变量

cd /home/oracle

vi .profile

umask 022

if [ -t 0 ]; then

stty intr ^C

fi

export ORACLE_SID=orcl2

export ORACLE_BASE=/u02/app/oracle

export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1

export PATH=$ORACLE_HOME/bin:$PATH

export LIBPATH=$ORACLE_HOME/lib:$ORACLE_HOME/rdbms/lib:/lib:/usr/lib

export
CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib:$ORACLE_HOME/network/jlb

export ORACLE_OWNER=oracle

 **9、修改用户限制**

# vi /etc/security/limits

default:

               fsize = -1

               core = 2097151

               cpu = -1

               data = -1

               rss = -1

               stack = -1

               nofiles = -1

oracle:

               fsize = -1

               core = -1

               cpu = -1

               data = -1

               rss = -1

               stack = -1

               nofiles = -1

grid:

               fsize = -1

               core = -1

               cpu = -1

               data = -1

               rss = -1

               stack = -1

               nofiles = -1

查看

su - oracle

$ulimit -a

 **10、ASM配置共享磁盘**

确保系统工程师已经将存储划分完成并将多路径软件部署完成

检查pvid（两节点分别执行）

# lspv  \---检查pvid 部分，如果使用ASM模式一定要确保删除pvid

如果ASM对应的磁盘存在pvid，执行下面的命令将对应磁盘上的pvid清除掉：

如:清除hdiskpower8磁盘上的pvid。

chdev -l hdiskpower8 -a pv=clear

查看磁盘大小

#bootinfo -s hdiskpower8

检查reserve_policy（两节点分别执行）

# lsattr -El hdiskpower* | grep reserve

reserve_policy   no_reserve        Reserve Policy               True

针对不同的存储设备使用不同的命令

On IBM storage (ESS, FasTt, DSXXXX) : 更改reserve_policy的值为no_reserve

chdev -l hdiskpower8 -a reserve_policy=no_reserve

On EMC storage : 更改reserve_lock的值为no

chdev -l hdiskpower8 -a reserve_lock=no

On HDS storage with HDLM driver, and no disks in Volume Group
:更改dlmrsvlevel的值为no_reserve

chdev -l dlmfdrv -a dlmrsvlevel=no_reserve

清空磁盘内容

#dd if=/dev/zero of=/dev/rhdiskpower8 bs=1024 count=1024

检查磁盘内容：确保都是0

## lquerypv -h /dev/rhdiskpower8

修改所有节点磁盘属性（两节点分别执行）

chown grid:asmadmin /dev/rhdiskpower8

chmod 660 /dev/rhdiskpower8

 **11、为用户等效性设置SSH**

安装SSH软件，在网上下载的SSH软件在安装时有可能会报license错误。最好使用系统光盘中的SSH软件包。

到系统安装光盘中复制出来SSH的安装文件，软件包路径\installp\ppc

将\installp\ppc路径下所有以openssh开头的文件上传到/tmp/openssh/

将\installp\ppc路径下所有以openssl开头的文件上传到/tmp/openssl/

先安装openssl：

进入openssl目录

Shell# cd /tmp/openssl

Shell# smitty install_latest

顺序选择Install and Update Software、Install Software，

INPUT device / directory for software   [.] 输入当前目录.

SOFTWARE to install [_all_latest]   按F4、然后ESC+7选择列出行

 "ACCEPT new license agreements?"  [yes]

回车，执行安装

Command:OK  表示安装完成。

再安装openssh

openssh的安装与openssl的安装过程一样。

Shell# cd /tmp/openssh

Shell# smitty install_latest

安装过的文件集可以通过如下命令查看。

Shell# lslpp -l | grep ssh

三、运行ssh服务

默认安装好后系统自动启用ssh服务：

以下命令查看ssh服务

Shell# #lssrc -a | grep ssh

sshd ssh 979088 active

如果是inactive，可通过以下命令启动ssh服务：

Shell# startsrc -s sshd

停止ssh服务：

Shell# stopsrc -s sshd

自动启动ssh服务

1) 编辑一脚本

# vi /etc/rc.local

添加如下行:

#!/bin/sh

startsrc -g ssh

2) 编辑/etc/inittab

# vi /etc/inittab

添加如下行:

rc.local:2:wait:/etc/rc.local > /dev/console 2>&1即可

在 两节点 上执行

mkdir ~/.ssh

chmod 700 ~/.ssh

ssh-keygen -t rsa

ssh-keygen -t dsa

在 节点1 上执行

cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys

ssh hisrac2 cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

ssh hisrac2 cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys

scp ~/.ssh/authorized_keys hisrac2:~/.ssh/authorized_keys

在每个节点上测试连接。验证当您再次运行以下命令时，系统是否不提示您输入口令。

ssh hisrac1 date

ssh hisrac2 date

ssh hisrac1-priv date

ssh hisrac2-priv date

 **12、修改网卡参数**

![noteattachment7][df6a894c5485528f28e02a8db5af0fec]

# chdev -l en1 -a rfc1323=1

 **13、验证安装介质md5值**

安装介质如非官方途径下载，需要验证md5值，避免使用网络上被篡改过的恶意介质

 **AIX** **：**

 **$ csum p8202632_10205_AIX64-5L_1of2.zip**

 **得出的值和如下官方提供的** **md5** **值进行对比，如果** **md5** **值不同，则表示文件有可能被篡改过** **，**
**不可以使用。**

 **文件的名字发生变化并不影响** **md5** **值的校验结果。**

详见《Oracle各版本安装包md5校验手册》

 **14、安装 Oracle Grid Infrastructure**

Xmanager连接服务器

root登录

1、解压群集安装程序（可能会存在没有unzip命令的情况，使用jar xvf）

![noteattachment8][fdab52848445d062db21c7dd3bc36646]

以下截图内值均为参考选项，以实际内容为准。

![noteattachment9][fd37cf3d7bae4fa54cd81587bb870921]

![noteattachment10][afae82162b585d75a21c1dcfde5ea3fc]

![noteattachment11][d5b7e489712728ba1dd7688592b7a6a5]

![noteattachment12][580e4cab55e032002a585e3ea7b5c3db]

![noteattachment13][d6e3a01235626062797c7ed7619b9175]

注意： SCAN name 必须和hosts文件里的scan name 一致

 **网格命名服务 (GNS)**

从 Oracle Clusterware 11 _g_ 第 2 版开始，引入了另一种分配 IP 地址的方法，即 _网格命名服务_ (GNS)。该方法允许使用
DHCP 分配所有专用互连地址以及大多数 VIP 地址。GNS 和 DHCP 是 Oracle 的新的网格即插即用 (GPnP) 特性的关键要素，如
Oracle 所述，该特性使我们无需配置每个节点的数据，也不必具体地添加和删除节点。通过实现对集群网络需求的自我管理，GNS 实现了 _动态_
网格基础架构。与手动定义静态 IP 地址相比，使用 GNS 配置 IP
地址确实有其优势并且更为灵活，但代价是增加了复杂性，该方法所需的一些组件未在这个构建经济型 Oracle RAC 的指南中定义。例如，为了在集群中启用
GNS，需要在公共网络上有一个 DHCP 服务器. 要了解 GNS 的更多优势及其配置方法，请参见 [适用于 Linux 的 Oracle Grid
Infrastructure 11 _g_ 第 2 版 (11.2)
安装指南](http://download.oracle.com/docs/cd/E11882_01/install.112/e10812/toc.htm)。

![noteattachment14][27544b394654f98a8176bd073eb22de8]

![noteattachment15][5ec69b8c6677475e53830a7ee54ac646]

![noteattachment16][f824cf5bc9a4efa20ffa622d5e58230f]

根据定义的网卡选择网络类型  public 还是 心跳private

![noteattachment17][c5ef269c7bc7b6bec3885ec7ddc82cfe]

![noteattachment18][a5587d1e5aafd30b4b513e0d329832d1]

![noteattachment19][8eb6de1e4c6399eecee4ca455a5623ac]

 **ASM必须达到一定的密码标准。密码中要包含字母大写、小写、数字，至少8个字符。**

 **![noteattachment20][ce56f50e991d03c9885ae8bd58c4b2b0]**

 **![noteattachment21][eada663c6addc467e04bc75589f00287]**

 **![noteattachment22][9c71adb229af872d43a8865aeb64fff6]**

 **![noteattachment23][933ef216dd6627a9d80e6fb2db4db1df]**

 **![noteattachment24][55aa6e41ca9eff083f41e80947fa1c2f]**

 **![noteattachment25][75f6fb86dc9116b424ac61663fd22044]**

关于上图的补丁部分，请认真参阅 第1 部分的系统补丁的要求，如果补丁不可以忽略则要求小机工程师安装或者自行下载安装。

![noteattachment26][d0bca7d731be219a2e720276bfe3ee23]

![noteattachment27][8d8522bdb3d8a53975a6f4eba16b8dc7]

在两个节点分别以root用户执行提示的脚本，执行结果如下：

1号节点执行orainstRoot.sh:

# /u01/app/oraInventory/orainstRoot.sh

Changing permissions of /u01/app/oraInventory.

Adding read,write permissions for group.

Removing read,write,execute permissions for world.

Changing groupname of /u01/app/oraInventory to oinstall.

The execution of the script is complete.

2号节点执行orainstRoot.sh:

# /u01/app/oraInventory/orainstRoot.sh

Changing permissions of /u01/app/oraInventory.

Adding read,write permissions for group.

Removing read,write,execute permissions for world.

Changing groupname of /u01/app/oraInventory to oinstall.

The execution of the script is complete.

1号节点执行root.sh：

# /u01/app/11.2.0/grid_1/root.sh

Performing root user operation for Oracle 11g

The following environment variables are set as:

    ORACLE_OWNER= grid

    ORACLE_HOME=  /u01/app/11.2.0/grid_1

Enter the full pathname of the local bin directory: [/usr/local/bin]:

   Copying dbhome to /usr/local/bin ...

   Copying oraenv to /usr/local/bin ...

   Copying coraenv to /usr/local/bin ...

Creating /etc/oratab file...

Entries will be added to the /etc/oratab file as needed by

Database Configuration Assistant when a database is created

Finished running generic part of root script.

Now product-specific root actions will be performed.

Using configuration parameter file:
/u01/app/11.2.0/grid_1/crs/install/crsconfig_params

Creating trace directory

User ignored Prerequisites during installation

Installing Trace File Analyzer

User grid has the required capabilities to run CSSD in realtime mode

OLR initialization - successful

  root wallet

  root wallet cert

  root cert export

  peer wallet

  profile reader wallet

  pa wallet

  peer wallet keys

  pa wallet keys

  peer cert request

  pa cert request

  peer cert

  pa cert

  peer root cert TP

  profile reader root cert TP

  pa root cert TP

  peer pa cert TP

  pa peer cert TP

  profile reader pa cert TP

  profile reader peer cert TP

  peer user cert

  pa user cert

Adding Clusterware entries to inittab

CRS-2672: Attempting to start 'ora.mdnsd' on 'hisrac1'

CRS-2676: Start of 'ora.mdnsd' on 'hisrac1' succeeded

CRS-2672: Attempting to start 'ora.gpnpd' on 'hisrac1'

CRS-2676: Start of 'ora.gpnpd' on 'hisrac1' succeeded

CRS-2672: Attempting to start 'ora.cssdmonitor' on 'hisrac1'

CRS-2672: Attempting to start 'ora.gipcd' on 'hisrac1'

CRS-2676: Start of 'ora.cssdmonitor' on 'hisrac1' succeeded

CRS-2676: Start of 'ora.gipcd' on 'hisrac1' succeeded

CRS-2672: Attempting to start 'ora.cssd' on 'hisrac1'

CRS-2672: Attempting to start 'ora.diskmon' on 'hisrac1'

CRS-2676: Start of 'ora.diskmon' on 'hisrac1' succeeded

CRS-2676: Start of 'ora.cssd' on 'hisrac1' succeeded

ASM created and started successfully.

Disk Group CRS created successfully.

clscfg: -install mode specified

Successfully accumulated necessary OCR keys.

Creating OCR keys for user 'root', privgrp 'system'..

Operation successful.

CRS-4256: Updating the profile

Successful addition of voting disk 42b42afadc594f82bfa7588f393d615e.

Successful addition of voting disk a10117506b864f9fbf90ea34476ae8b4.

Successful addition of voting disk 6b43a9ad769c4ff4bf7addbd6bba5b9b.

Successful addition of voting disk 0f455a2c1b5e4f1abf9922b3e1d9e440.

Successful addition of voting disk 331480b6ffb24fe8bfc22c421a75d8ec.

Successfully replaced voting disk group with +CRS.

CRS-4256: Updating the profile

CRS-4266: Voting file(s) successfully replaced

##  STATE    File Universal Id                File Name Disk group

\--  \-----    \-----------------                \--------- ---------

 1\. ONLINE   42b42afadc594f82bfa7588f393d615e (/dev/rhdiskpower4) [CRS]

 2\. ONLINE   a10117506b864f9fbf90ea34476ae8b4 (/dev/rhdiskpower5) [CRS]

 3\. ONLINE   6b43a9ad769c4ff4bf7addbd6bba5b9b (/dev/rhdiskpower6) [CRS]

 4\. ONLINE   0f455a2c1b5e4f1abf9922b3e1d9e440 (/dev/rhdiskpower7) [CRS]

 5\. ONLINE   331480b6ffb24fe8bfc22c421a75d8ec (/dev/rhdiskpower8) [CRS]

Located 5 voting disk(s).

CRS-2672: Attempting to start 'ora.asm' on 'hisrac1'

CRS-2676: Start of 'ora.asm' on 'hisrac1' succeeded

CRS-2672: Attempting to start 'ora.CRS.dg' on 'hisrac1'

CRS-2676: Start of 'ora.CRS.dg' on 'hisrac1' succeeded

Configure Oracle Grid Infrastructure for a Cluster ... succeeded

2号节点执行root.sh：

[root@zjdb2 ~]# /u01/app/11.2.0/grid/root.sh

Performing root user operation for Oracle 11g

The following environment variables are set as:

    ORACLE_OWNER= grid

    ORACLE_HOME=  /u01/app/11.2.0/grid_1

Enter the full pathname of the local bin directory: [/usr/local/bin]:

Creating /usr/local/bin directory...

   Copying dbhome to /usr/local/bin ...

   Copying oraenv to /usr/local/bin ...

   Copying coraenv to /usr/local/bin ...

Creating /etc/oratab file...

Entries will be added to the /etc/oratab file as needed by

Database Configuration Assistant when a database is created

Finished running generic part of root script.

Now product-specific root actions will be performed.

Using configuration parameter file:
/u01/app/11.2.0/grid_1/crs/install/crsconfig_params

Creating trace directory

User ignored Prerequisites during installation

Installing Trace File Analyzer

User grid has the required capabilities to run CSSD in realtime mode

OLR initialization - successful

Adding Clusterware entries to inittab

CRS-4402: The CSS daemon was started in exclusive mode but found an active CSS
daemon on node hisrac1, number 1, and is terminating

An active cluster was found during exclusive startup, restarting to join the
cluster

Configure Oracle Grid Infrastructure for a Cluster ... succeeded

脚本执行执行完毕后点OK 继续：

![noteattachment28][69748ccbeddb747e4f931e36bd11024b]

![noteattachment29][4bdfc5f483fdeb18e4a06e10ac2ba7ef]

![noteattachment30][14addf1abbed6662024fd0612df12628]

如果出现如上错误，需要安装系统补丁IV09580

在6.1.04版本不打IV09580有可能会报如上错误。

https://yunpan.cn/cRHBDuEBrx7Fa  访问密码 4b93

安装命令：

root@sdgsdb1:/u01/app>emgr -e IV09580.epkg.Z

![noteattachment31][e99c2f4dda2a6e683c6073c7df128d37]

若集群root.sh脚本运行不成功：

删除crs配置信息

#/u01/app/11.2.0/grid/crs/install/rootcrs.pl -verbose -deconfig -force

然后可以重新运行root.sh

 **15、集群安装后的任务**

 (1)、验证oracle clusterware的安装

以grid身份运行以下命令：

检查crs状态：

$ crsctl check crs

CRS-4638: Oracle High Availability Services is online

CRS-4537: Cluster Ready Services is online

CRS-4529: Cluster Synchronization Services is online

CRS-4533: Event Manager is online

检查 Clusterware 资源:

$ crsctl stat res -t

\----------------------------------------------------------

NAME               TARGET  STATE        SERVER      STATE_DETAILS

\--------------------------------------------------------------

Local Resources  

\--------------------------------------------------------------

ora.DATA.dg        ONLINE  ONLINE       rac1  

                   ONLINE  ONLINE       rac2                     

ora.FRA.dg         ONLINE  ONLINE       rac1  

                   ONLINE  ONLINE       rac2                     

ora.LISTENER.lsnr  ONLINE  ONLINE       rac1  

                   ONLINE  ONLINE       rac2                     

ora.OCR.dg         ONLINE  ONLINE       rac1  

                   ONLINE  ONLINE       rac2                     

ora.asm            ONLINE  ONLINE       rac1        Started  

                   ONLINE  ONLINE       rac2        Started      

ora.gsd            OFFLINE OFFLINE      rac1  

                   OFFLINE OFFLINE      rac2                     

ora.net1.network   ONLINE  ONLINE       rac1  

                   ONLINE  ONLINE       rac2                     

ora.ons            ONLINE  ONLINE       rac1  

                   ONLINE  ONLINE       rac2                     

ora.registry.acfs  ONLINE  ONLINE       rac1  

                   ONLINE  ONLINE       rac2                     

\--------------------------------------------------------------

Cluster Resources

\--------------------------------------------------------------

ora.LISTENER_SCAN1.lsnr

      1            ONLINE  ONLINE       rac1                     

ora.cvu  

      1            ONLINE  ONLINE       rac1                      

ora.oc4j  

      1            ONLINE  ONLINE       rac1                     

ora.rac1.vip  

      1            ONLINE  ONLINE       rac1                     

ora.rac2.vip  

      1            ONLINE  ONLINE       rac2                      

ora.scan1.vip  

      1            ONLINE  ONLINE       rac1                     

检查集群节点:

[grid@rac1 ~]$ olsnodes -n

rac1    1

rac2    2

检查两个节点上的 Oracle TNS 监听器进程:

[grid@rac1 ~]$ srvctl status listener

Listener LISTENER is enabled

Listener LISTENER is running on node(s): rac2,rac1

(2)创建 ASM 磁盘组

asmca

![noteattachment32][69c3fbfb54f81423c9fa8641e9b1c18f]

![noteattachment33][85d9102290bf4ad176569df799b290d5]

在 Disk Groups 选项卡中，单击 **Create** 按钮，在出现的画面中创建data卷：

除了CRS磁盘组以外其余存放数据和归档的磁盘组默认都是选择Extenal外部冗余模式，除非客户特殊要求。

![noteattachment34][8623e38cda028fe656e307bd3085f51c]

![noteattachment35][82105731a5af5d3bdb741d158eb58ef6]

对于磁盘组的规划，一般一套rac 含有一个CRS磁盘组，一个FRA磁盘组用于存放归档日志，一个或者多个DATA磁盘组用于存放数据。

单击Exit退出ASM配置向导。

 **至此重启下服务器确认** **crs** **各个资源状态均正常。**

 **16、安装oracle 11g r2 database**

Xmanager图形化登录服务器

root用户登录

![noteattachment36][53f16ee5abe433f881c9cc80324a05fa]

![noteattachment37][83bc9f79ada633eb659b74fca75ffedf]

![noteattachment38][c43210215eb13f4b29472f5e2679c15f]

![noteattachment39][6fa432cf8555d1be67f220813f644fe8]

![noteattachment40][fd5f1a0b5a7ec2a1da073c88d8dc271b]

![noteattachment41][1a99f8b6c78ea03a7dcecb43af06b442]

需要手工配置oracle用户的ssh互信

![noteattachment42][ae9d51069260c18a36edf9173d00d753]

![noteattachment43][2768eafde01bfd43d827fec8366a5365]

![noteattachment44][757dee528e39d2b3cfafc0491d71500a]

![noteattachment45][b5ce4fb4d134b127d0cce390f8ff550b]

![noteattachment46][e068d237133178d16e7c562ce63e3886]

![noteattachment47][5b3993b953e43ce05a1799bb13bd4ae4]

![noteattachment48][f40f329ec74bce4f1b665902327ea73e]

![noteattachment49][e0f4227f2e73f685fe4c25cbe1578d12]

![noteattachment50][22a77819dc366d970bb9486945b7bf16]

以root用户分别在两个节点执行以上脚本。

1号节点：

# /u02/app/oracle/product/11.2.0/db_1/root.sh

Performing root user operation for Oracle 11g

The following environment variables are set as:

    ORACLE_OWNER= oracle

    ORACLE_HOME=  /u02/app/oracle/product/11.2.0/db_1

Enter the full pathname of the local bin directory: [/usr/local/bin]:

The contents of "dbhome" have not changed. No need to overwrite.

The contents of "oraenv" have not changed. No need to overwrite.

The contents of "coraenv" have not changed. No need to overwrite.

Entries will be added to the /etc/oratab file as needed by

Database Configuration Assistant when a database is created

Finished running generic part of root script.

Now product-specific root actions will be performed.

Finished product-specific root actions.

2号节点：

# /u02/app/oracle/product/11.2.0/db_1/root.sh

Performing root user operation for Oracle 11g

The following environment variables are set as:

    ORACLE_OWNER= oracle

    ORACLE_HOME=  /u02/app/oracle/product/11.2.0/db_1

Enter the full pathname of the local bin directory: [/usr/local/bin]:

The contents of "dbhome" have not changed. No need to overwrite.

The contents of "oraenv" have not changed. No need to overwrite.

The contents of "coraenv" have not changed. No need to overwrite.

Entries will be added to the /etc/oratab file as needed by

Database Configuration Assistant when a database is created

Finished running generic part of root script.

Now product-specific root actions will be performed.

Finished product-specific root actions.

执行完毕点击close完成database软件的安装。

 **17、创建、删除数据库**

建议

数据文件，归档日志分开存放在不同的，文件系统路径或ASM路径中

控制文件和在线日志多路复用时，放在不同的，磁盘驱动器或ASM磁盘组中

数据库位于文件系统时，将数据文件和在线日志放在不同的磁盘驱动器中

 **17.1 创建数据库**

使用dbca创建，创建之前确保已安装的所有服务（Oracle TNS 监听器、Oracle Clusterware 进程等）正在运行。

[grid@rac1 ~]$ crsctl stat res -t

\----------------------------------------------------------

NAME               TARGET  STATE        SERVER      STATE_DETAILS

\--------------------------------------------------------------

Local Resources  

\--------------------------------------------------------------

ora.DATA.dg        ONLINE  ONLINE       rac1  

                   ONLINE  ONLINE       rac2                     

ora.FRA.dg         ONLINE  ONLINE       rac1  

                   ONLINE  ONLINE       rac2                     

ora.LISTENER.lsnr  ONLINE  ONLINE       rac1  

                   ONLINE  ONLINE       rac2                     

ora.OCR.dg         ONLINE  ONLINE       rac1  

                   ONLINE  ONLINE       rac2                     

ora.asm            ONLINE  ONLINE       rac1        Started  

                   ONLINE  ONLINE       rac2        Started      

ora.gsd            OFFLINE OFFLINE      rac1  

                   OFFLINE OFFLINE      rac2                     

ora.net1.network   ONLINE  ONLINE       rac1  

                   ONLINE  ONLINE       rac2                     

ora.ons            ONLINE  ONLINE       rac1  

                   ONLINE  ONLINE       rac2                      

ora.registry.acfs  ONLINE  ONLINE       rac1  

                   ONLINE  ONLINE       rac2                     

\--------------------------------------------------------------

Cluster Resources

\--------------------------------------------------------------

ora.LISTENER_SCAN1.lsnr

      1            ONLINE  ONLINE       rac1                     

ora.cvu  

      1            ONLINE  ONLINE       rac1                     

ora.oc4j  

      1            ONLINE  ONLINE       rac1                     

ora.rac1.vip  

      1            ONLINE  ONLINE       rac1                     

ora.rac2.vip  

      1            ONLINE  ONLINE       rac2                     

ora.scan1.vip  

      1            ONLINE  ONLINE       rac1                      

![noteattachment51][516bbbb8f36911eafc295395716bfafa]

![noteattachment52][8fc7322dc0658e5c7a67a91bf0f2b2d3]

![noteattachment53][a5496347273be89df8e189793f9af8de]

![noteattachment54][dd2726b3253c7044b9365ab0ca8160bd]

![noteattachment55][57b249f3199e2f1632901d1d91caba73]

![noteattachment56][187c3ae31da35c04ad15345a057fb481]

![noteattachment57][842840d75d46797b8cac2d233af2a7b2]

点击"Multiplex Redo Logs and Control Files" 输入多个磁盘组来产生冗余控制文件和redo文件。如果存在+FRA则填写
+DATA和+FRA

如果不存在+FRA，只有+DATA ，则添加两个+DATA

原则就是要多个控制文件和redo文件，而且尽量要存放在不同的磁盘组中。

![noteattachment58][7991fbf813507c02d1bd3846c9312660]

![noteattachment59][1fd99e28fa02d3ad1f72bc2f68a95d1b]

![noteattachment60][bf4815da4a1d2b8d5781dfe6bda581ce]

保守的设置原则是 ：

SGA_TARGET+pga_aggregate_target=物理内存*0.6

SGA_TARGET : pga_aggregate_target  比例是4:1

SGA_TARGET 等于 SGA_MAX_SIZE

根据实际物理内存进行调整。

此处关于内存设置，HPUX和AIX 可以选择使用Typical ,并勾选Use Automatic Memory
Management来启用AMM内存管理机制，建议比例为物理内存的60%。

![noteattachment61][f3535121dcd1a9510afaa561b329d852]

![noteattachment62][dc84080221cfa66c97b44236852c6f1a]

 **字符集的必须和开发人员进行确认，不能猜测使用，数据库建立完成后字符集不能进行修改。**

![noteattachment63][2ae104163a97acb3d244db209dd18181]

![noteattachment64][faab476f88a7a007d22cd085a4933cab]

 **分别为** **Thread1** **和** **Therad2** **添加一组** **REDO** **，并修改所有** **redo**
**大小为** **256M** **或者** **512M** **。**

![noteattachment65][293d73bed932c0589f2a570cc210fbc9]

![noteattachment66][652ed40196c5b3f26ca407d257ace30d]

![noteattachment67][c39f745ff8bc2b93a19173fd630a1b16]

![noteattachment68][25457662ffb635d3d3d9e94f584a4c6f]

 **17.2 删除数据库**

删除数据库最好也用dbca，虽然srvctl也可以。

1.运行dbca，选择”delete a database”。然后就next..，直到finish。

2.数据的删除并不影响asm实例，如果想删除与asm有关的内容，可以按如下做法：

# export ORACLE_SID= _ASM_instance_name_

# sqlplus / as sysdba

SQL> drop diskgroup _diskgroup_name_ including contents;

SQL> quit

然后在各个节点上执行

# srvctl stop asm –n hostname

# srvctl remove asm –n hostname

这样，应该就可以删除的比较干净了。

 **18\. 安装PSU**

 **相关安装** **PSU** **的步骤参照《** **Oracle_PSU** **安装手册》**

 **建议先** **dbca** **建库，再打** **psu** **。**

AIX平台，oracle创建了一个关键修复补丁N-Apply bundle
patch（CPUS）针对11.2.0.4，这个补丁和PSU不会冲突，安装完PSU后需要安装此CPUS

11.2.0.4. AIX bundle 2 can be downloaded here: [Patch
20877677](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=2022567.1&patchId=20877677)

注意，在安装此cpus补丁前，需要先安装psu 11.2.0.4.170418

[Patch
24732075](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=2022567.1&patchId=24732075)
Database Patch Set Update 11.2.0.4.170418

Recommended Bundle for AIX 11.2.0.4. with Critical Fixes (Doc ID 2022567.1)

 **19、常用命令**

 **19.1、oracle 用户管理数据库命令**

 ** _srvctl status_** _  
        Available options: database|instance|service|nodeapps|asm  
  
# Display help for database level  
        srvctl status database -h  
  
# Display instance's running status on each node  
        srvctl status database -d orcl  
        example output:  
          Instance orcl1 is(not) running on node rac1  
          Instance orcl2 is(not) running on node rac2  
  
# include  disabled applications  
        srvctl status database -d orcl -f  
  
# verbos output  
        srvctl status database -d orcl -v  
  
# Additional information for EM Console  
        srvctl status database -d orcl -S EM_AGENT_DEBUG  
  
# Additional information for EM Console  
        srvctl status database -d orcl -i orcl1 -S EM_AGENT_DEBUG  
  
# Display help for instance level  
        srvctl status instance -h  
  
# display appointed instance's running status  
        srvctl status instance -d orcl -i orcl1  
  
# Display help for node level  
        srvctl status nodeapps -h  
  
# Display all app's status on the node xxx  
        srvctl status nodeapps -n <node_name>_

 ** _srvctl start_**

 _   # Start database  
        srvctl start database -d orcl -o nomount  
        srvctl start database -d orcl -o mount  
        srvctl start database -d orcl -o open_

 _# Grammar for start instance  
        srvctl start instance -d [db_name] -i [instance_name]  
               -o [start_option] -c [connect_str]_ _–_ _q_

 _# Start all instances on the all nodes  
        srvctl start instance -d orcl -i orcl1,orcl2,_

 _# Start ASM instance  
        srvctl start ASM -n [node_name] -i asm1 -o open  
  
# Start all apps in one node  
     srvctl start nodeapps -n [node_name]_

 ** _srvctl stop_**

 _# Stop database  
        srvctl stop database -d orcl -o normal  
        srvctl stop database -d orcl -o immediate  
        srvctl stop database -d orcl -o abort  
  
# Grammar for stop  instance  
        srvctl stop instance -d [db_name] -i [instance_name]  
               -o [start_option] -c [connect_str] -q  
  
# Stop all instances on the all nodes  
        srvctl stop instance -d orcl -i orcl1,orcl2,...  
  
# Stop ASM instance  
        srvctl stop ASM -n [node_name] -i asm1 -o [option]  
  
# Stop all apps in one node  
        srvctl stop nodeapps -n [node_name]_

 **19.2、启动/停止集群命令**

 _以下停止/_ _启动操作需要以_ `_root_` _身份来执行_

 ** _在本地服务器上停止 Oracle Clusterware 系统_**

 _在` rac1` 节点上使用 `crsctl stop cluster` 命令停止 Oracle Clusterware 系统：_

 ** _#/u01/app/11.2.0/grid/bin/crsctl stop cluster_**

 ** _注：_** _在运行“_` _crsctl stop cluster_` _”_ _命令之后，如果 Oracle Clusterware_
_管理的资源中有任何一个还在运行，则整个命令失败。使用_ `_-f_` _选项无条件地停止所有资源并停止 Oracle Clusterware_ _系统。_

 ** _在本地服务器上启动 Oracle Clusterware 系统_**

 _在 rac1 节点上使用 crsctl start cluster 命令启动 Oracle Clusterware 系统：_

 _[root@rac1 ~]# **/u01/app/11.2.0/grid/bin/crsctl start cluster**_

 ** _注：_** _可通过指定 -all 选项在集群中所有服务器上启动 Oracle Clusterware 系统。_

 _[root@rac1 ~]# **/u01/app/11.2.0/grid/bin/crsctl start cluster -all**_

 _还可以通过列出服务器（各服务器之间以空格分隔）在集群中一个或多个指定的服务器上启动 Oracle Clusterware 系统：_

 _[root@rac1 ~]# **/u01/app/11.2.0/grid/bin/crsctl start cluster -n rac1
rac2**_

 **19.3 检查集群的运行状况（集群化命令）**

 _以 grid 用户身份运行以下命令。_

 _[grid@rac1 ~]$ **crsctl check cluster**_

 _CRS-4537: Cluster Ready Services is online_

 _CRS-4529: Cluster Synchronization Services is online_

 _CRS-4533: Event Manager is online_

 ** _所有 Oracle 实例 —（数据库状态）_**

 _[oracle@rac1 ~]$ **srvctl status database -d orcl**_

 _Instance orcl1 is running on node rac1_

 _Instance orcl2 is running on node rac2_

 ** _单个 Oracle 实例 —（特定实例的状态）_**

 _[oracle@rac1 ~]$ **srvctl status instance -d orcl -i orcl1**_

 _Instance orcl1 is running on node rac1_

 ** _节点应用程序 —（状态）_**

 _[oracle@rac1 ~]$ **srvctl status nodeapps**_

 _VIP rac1-vip is enabled_

 _VIP rac1-vip is running on node: rac1_

 _VIP rac2-vip is enabled_

 _VIP rac2-vip is running on node: rac2_

 _Network is enabled_

 _Network is running on node: rac1_

 _Network is running on node: rac2_

 _GSD is disabled_

 _GSD is not running on node: rac1_

 _GSD is not running on node: rac2_

 _ONS is enabled_

 _ONS daemon is running on node: rac1_

 _ONS daemon is running on node: rac2_

 _eONS is enabled_

 _eONS daemon is running on node: rac1_

 _eONS daemon is running on node: rac2_

 ** _节点应用程序 —（配置）_**

 _[oracle@rac1 ~]$ **srvctl config nodeapps**_

 _VIP exists.:rac1_

 _VIP exists.: /rac1-vip/192.168.1.251/255.255.255.0/eth0_

 _VIP exists.:rac2_

 _VIP exists.: /rac2-vip/192.168.1.252/255.255.255.0/eth0_

 _GSD exists._

 _ONS daemon exists. Local port 6100, remote port 6200_

 _eONS daemon exists. Multicast port 24057, multicast IP address
234.194.43.168, listening port 2016_

 ** _列出配置的所有数据库_**

 _[oracle@rac1 ~]$ **srvctl config database**_

 _orcl_

 ** _数据库 —（配置）_**

 _[oracle@rac1 ~]$ **srvctl config database -d orcl -a**_

 _Database unique name: orcl_

 _Database name: orcl_

 _Oracle home: /u01/app/oracle/product/11.2.0/dbhome_1_

 _Oracle user: oracle_

 _Spfile: +ORCL_DATA/orcl/spfileorcl.ora_

 _Domain: idevelopment.info_

 _Start options: open_

 _Stop options: immediate_

 _Database role: PRIMARY_

 _Management policy: AUTOMATIC_

 _Server pools: orcl_

 _Database instances: orcl1,orcl2_

 _Disk Groups: ORCL_DATA,FRA_

 _Services:_

 _Database is enabled_

 _Database is administrator managed_

 ** _ASM —_** ** _（状态）_**

 _[oracle@rac1 ~]$ **srvctl status asm**_

 _ASM is running on rac1,rac2_

 ** _ASM —_** ** _（配置）_**

 _$ **srvctl config asm -a**_

 _ASM home: /u01/app/11.2.0/grid_

 _ASM listener: LISTENER_

 _ASM is enabled._

 ** _TNS_** **_监听器 —（状态）_**

 _[oracle@rac1 ~]$ **srvctl status listener**_

 _Listener LISTENER is enabled_

 _Listener LISTENER is running on node(s): rac1,rac2_

 ** _TNS_** **_监听器 —（配置）_**

 _[oracle@rac1 ~]$ **srvctl config listener -a**_

 _Name: LISTENER_

 _Network: 1, Owner: grid_

 _Home:_

 _  /u01/app/11.2.0/grid on node(s) rac2,rac1_

 _End points: TCP:1521_

 ** _SCAN —_** ** _（状态）_**

 _[oracle@rac1 ~]$ **srvctl status scan**_

 _SCAN VIP scan1 is enabled_

 _SCAN VIP scan1 is running on node rac1_

 ** _SCAN —_** ** _（配置）_**

 _[oracle@rac1 ~]$ **srvctl config scan**_

 _SCAN name: racnode-cluster-scan, Network: 1/192.168.1.0/255.255.255.0/eth0_

 _SCAN VIP name: scan1, IP: /racnode-cluster-scan/192.168.1.187_

 ** _VIP —_** ** _（特定节点的状态）_**

 _[oracle@rac1 ~]$ **srvctl status vip -n rac1**_

 _VIP rac1-vip is enabled_

 _VIP rac1-vip is running on node: rac1_

 _[oracle@rac1 ~]$ **srvctl status vip -n rac2**_

 _VIP rac2-vip is enabled_

 _VIP rac2-vip is running on node: rac2_

 ** _VIP —_** ** _（特定节点的配置）_**

 _[oracle@rac1 ~]$ **srvctl config vip -n rac1**_

 _VIP exists.:rac1_

 _VIP exists.: /rac1-vip/192.168.1.251/255.255.255.0/eth0_

 _[oracle@rac1 ~]$ **srvctl config vip -n rac2**_

 _VIP exists.:rac2_

 _VIP exists.: /rac2-vip/192.168.1.252/255.255.255.0/eth0_

 ** _节点应用程序配置 —（VIP、GSD、ONS、监听器）_**

 _[oracle@rac1 ~]$ **srvctl config nodeapps -a -g -s -l**_

 _-l option has been deprecated and will be ignored._

 _VIP exists.:rac1_

 _VIP exists.: /rac1-vip/192.168.1.251/255.255.255.0/eth0_

 _VIP exists.:rac2_

 _VIP exists.: /rac2-vip/192.168.1.252/255.255.255.0/eth0_

 _GSD exists._

 _ONS daemon exists. Local port 6100, remote port 6200_

 _Name: LISTENER_

 _Network: 1, Owner: grid_

 _Home:_

 _  /u01/app/11.2.0/grid on node(s) rac2,rac1_

 _End points: TCP:1521_

 **20、卸载软件**

 **20.1卸载Oracle Grid Infrastructure**

 _Deconfiguring Oracle Clusterware Without Removing Binaries_

 _cd /u01/app/11.2.0/grid/crs/install_

    
    
    1、Run rootcrs.pl with the -deconfig -force flags. For example
    
    
    # perl rootcrs.pl -deconfig –force
    
    
    Repeat on other nodes as required
    
    
    2、If you are deconfiguring Oracle Clusterware on all nodes in the cluster, then on the last node, enter the following command:

 _#_ _perl rootcrs.pl -deconfig -force –lastnode_

 _3_ _、_ _Removing Grid Infrastructure_

 _The default method for running the deinstall tool is from the deinstall
directory in the grid home. For example:_

    
    
    $ cd /u01/app/11.2.0/grid/deinstall
    
    
    $ ./deinstall

 **20.2卸载 Oracle Real Application Clusters Software**

 _Overview of Deinstallation Procedures_

 _To completely remove all Oracle databases, instances, and software from an
Oracle home directory:_

· _Identify all instances associated with the Oracle home_

· _Shut down processes_

· _Remove listeners installed in the Oracle Database home_

· _Remove database instances_

· _Remove Automatic Storage Management (11.1 or earlier)_

· _Remove Oracle Clusterware and Oracle Automatic Storage Management (Oracle
grid infrastructure)_

 _Deinstalling Oracle RAC Software_

    
    
    $ cd $ORACLE_HOME/deinstall
    
    
    $ ./deinstall

 _Reserve.conf_

 _Crs-4402_

 **21、收尾工作**

修改数据库默认参数：

alter system set deferred_segment_creation=FALSE;  

alter system set audit_trail             =none           scope=spfile;

alter system set SGA_MAX_SIZE            =xxxxxM         scope=spfile;

alter system set SGA_TARGET              =xxxxxM         scope=spfile;

alter systemn set pga_aggregate_target   =XXXXXM         scope=spfile;

Alter PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;

alter database add SUPPLEMENTAL log data;

alter system set enable_ddl_logging=true;

#关闭11g密码延迟验证新特性

ALTER SYSTEM SET EVENT = '28401 TRACE NAME CONTEXT FOREVER, LEVEL 1' SCOPE =
SPFILE;

#限制trace日志文件大最大25M

alter system set max_dump_file_size ='25m' ;

#关闭密码大小写限制

ALTER SYSTEM SET SEC_CASE_SENSITIVE_LOGON = FALSE;  
alter system set db_files=2000 scope=spfile;

#RAC修改local_listener：（现象：使用PlSql Developer第一次连接超时，第二次之后连接正常）

alter system set local_listener = '(ADDRESS = (PROTOCOL = TCP)(HOST =
192.168.0.125)(PORT = 1521))' sid='orcl1';

alter system set local_listener = '(ADDRESS = (PROTOCOL = TCP)(HOST =
192.168.0.130)(PORT = 1521))' sid='orcl2';

HOST = 192.168.1.216 --此处使用数字形式的VIP，绝对禁止使用rac1-vip

HOST = 192.168.1.219 --此处使用数字形式的VIP，绝对禁止使用rac2-vip

#更改控制文件记录保留时间

alter system set control_file_record_keep_time =31;

ASM内存参数设置

Unable To Start ASM (ORA-00838 ORA-04031) On 11.2.0.3/11.2.0.4 If OS CPUs # >
64\. (文档 ID 1416083.1)

SQL> show parameter memory_target

查看ASM实例内存大小，如果值小于1536m，则做如下配置

SQL> alter system set memory_max_target=4096m scope=spfile;

SQL> alter system set memory_target=1536m scope=spfile;

如果当前memory_target值大于1536M，则不作任何变更

修改rman 控制文件快照路径###

ORA-245: In RAC environment from 11.2 onwards Backup Or Snapshot controlfile
needs to be in shared location (文档 ID 1472171.1)

一个节点上执行即可

rman target /

show all;

CONFIGURE SNAPSHOT CONTROLFILE NAME TO '+DATA/snapcf_ls.f';

show all;

修改ASM的链路中断等待时间，避免多路径切换时间超过15s而导致磁盘组被强制umount：

su - grid

sqlplus / as sysdba

alter system set "_asm_hbeatiowait"=120 scope=spfile sid='*';

另外参考文章修改asm的内存参数：

 **ASM Instances Are Reporting ORA-04031 Errors. (** **文档** **ID 1370925.1)**

 **RAC** **和** **Oracle Clusterware** **最佳实践和初学者指南（平台无关部分）** **(** **文档** **ID
1526083.1)**

su - grid

sqlplus / as sysdba

SQL> alter system set memory_max_target=4096m scope=spfile;  
alter system set memory_target=1536m scope=spfile;

部署OSW，参考《OSW部署手册》

部署ASM aud审计登录文件定时清理任务：

每台服务器都要部署。

su - grid

$ sqlplus '/ as sysasm'

SQL> select value from v$parameter where name = 'audit_file_dest';

VALUE

\--------------------------------------------------------------------------------

/u01/app/11.2.0/grid/rdbms/audit

grid用户执行：

crontab -e

添加内容

0 2 * * sun /usr/bin/find /u01/app/11.2.0/grid/rdbms/audit -maxdepth 1 -name
'*.aud' -mtime +30 -delete

参考文档：

 **  
Manage Audit File Directory Growth with cron (** **文档** **ID 1298957.1)  
A Lot of Audit Files in ASM Home (** **文档** **ID 813416.1)**

 **22、部署rman备份脚本**

参考rman 备份相关文档

 **至此结束** **RAC** **部署，重启** **RAC** **所有服务器，启动后检查相关服务及内容是否正常，方可结束安装。**

 **23、安装群集和数据库失败如何快速重来，需要清理重来？**

RAC 安装失败后的删除

如果已经运行了root.sh脚本则要清理掉crs磁盘组的相关共享磁盘，命令格式如下：

dd if=/dev/zero of=/dev/raw/raw1 bs=1k count=3000

删除grid和oracle的软件安装目录：

rm -rf /u02/*

rm -rf /u01/*

删除其他生成的配置文件：

rm  -rf /home/oracle/oracle/*

rm  -rf /etc/rc.d/rc5.d/S96init.crs

rm  -rf /etc/rc.d/init.d/init.crs

rm  -rf /etc/rc.d/rc4.d/K96init.crs

rm  -rf /etc/rc.d/rc6.d/K96init.crs

rm  -rf /etc/rc.d/rc1.d/K96init.crs

rm  -rf /etc/rc.d/rc0.d/K96init.crs

rm  -rf /etc/rc.d/rc2.d/K96init.crs

rm  -rf /etc/rc.d/rc3.d/S96init.crs

rm  -rf /etc/oracle/*

rm  -rf /etc/oraInst.loc

rm  -rf /etc/oratab

rm  -rf /usr/local/bin/coraenv

rm  -rf /usr/local/bin/dbhome

rm  -rf /usr/local/bin/oraenv

rm -f /etc/init.d/init.cssd

rm -f /etc/init.d/init.crs

rm -f /etc/init.d/init.crsd

rm -f /etc/init.d/init.evmd

rm -f /etc/rc2.d/K96init.crs

rm -f /etc/rc2.d/S96init.crs

rm -f /etc/rc3.d/K96init.crs

rm -f /etc/rc3.d/S96init.crs

rm -f /etc/rc5.d/K96init.crs

rm -f /etc/rc5.d/S96init.crs

rm -f /etc/inittab.crs

rm -rf /tmp/.oracle/

rm -rf /etc/init.d/init.ohasd

rm -rf /etc/init.d/init.*

rm -rf /etc/oracle/

rm -rf /etc/oraInst.loc

rm -rf /var/tmp/.oracle/

rm -rf /tmp/.oracle/

rm -rf /var/tmp/.oracle/

rm -rf /usr/tmp/.oracle/

rm -f /etc/rc.d/init.d/ohasd

以上rm操作同样适用于10Grac的清理。

 _清理完成后需要重启下所有服务器，使得相应进程关闭。_

 _参考文档：_ **  
RAC** **和** **Oracle Clusterware** **最佳实践和初学者指南** **(AIX) (** **文档** **ID
1526555.1)**

 **AIX: Top Things to DO NOW to Stabilize 11gR2 GI/RAC Cluster (** **文档** **ID
1427855.1)**

 **PRVE-0273 : The value of network parameter "udp_sendspace" for interface
"en0" is not configured to the expected value on node "racnode1" (** **文档**
**ID 1373242.1)**

 **11gR2  OUI On AIX Pre-Requisite Check Gives Error ** **“** **Patch
IZ97457, IZ89165 Are Missing** **”** **  (** **文档** **  ID 1439940.1)**

 **OUI  reports OS PATCH:IZ52319 is not installed running AIX ** **
![noteattachment69][df3e567d6f16d040326c7a0ea29a4f41]** **6.1.0.3  and later
[ID 989678.1] **

Measure

Measure


---
### ATTACHMENTS
[14addf1abbed6662024fd0612df12628]: media/Oracle-安装手册-RAC_11gR2_for_AIX.html
[Oracle-安装手册-RAC_11gR2_for_AIX.html](media/Oracle-安装手册-RAC_11gR2_for_AIX.html)
>hash: 14addf1abbed6662024fd0612df12628  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105112717_185.jpg  

[187c3ae31da35c04ad15345a057fb481]: media/Oracle-安装手册-RAC_11gR2_for_AIX-2.html
[Oracle-安装手册-RAC_11gR2_for_AIX-2.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-2.html)
>hash: 187c3ae31da35c04ad15345a057fb481  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105113649_596.png  

[1a99f8b6c78ea03a7dcecb43af06b442]: media/Oracle-安装手册-RAC_11gR2_for_AIX-3.html
[Oracle-安装手册-RAC_11gR2_for_AIX-3.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-3.html)
>hash: 1a99f8b6c78ea03a7dcecb43af06b442  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105113107_728.png  

[1fd99e28fa02d3ad1f72bc2f68a95d1b]: media/Oracle-安装手册-RAC_11gR2_for_AIX-4.html
[Oracle-安装手册-RAC_11gR2_for_AIX-4.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-4.html)
>hash: 1fd99e28fa02d3ad1f72bc2f68a95d1b  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105113757_950.png  

[22a77819dc366d970bb9486945b7bf16]: media/Oracle-安装手册-RAC_11gR2_for_AIX-5.html
[Oracle-安装手册-RAC_11gR2_for_AIX-5.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-5.html)
>hash: 22a77819dc366d970bb9486945b7bf16  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105113508_672.png  

[25457662ffb635d3d3d9e94f584a4c6f]: media/Oracle-安装手册-RAC_11gR2_for_AIX-6.html
[Oracle-安装手册-RAC_11gR2_for_AIX-6.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-6.html)
>hash: 25457662ffb635d3d3d9e94f584a4c6f  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105114008_799.png  

[27544b394654f98a8176bd073eb22de8]: media/Oracle-安装手册-RAC_11gR2_for_AIX-7.html
[Oracle-安装手册-RAC_11gR2_for_AIX-7.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-7.html)
>hash: 27544b394654f98a8176bd073eb22de8  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105112212_725.png  

[2768eafde01bfd43d827fec8366a5365]: media/Oracle-安装手册-RAC_11gR2_for_AIX-8.html
[Oracle-安装手册-RAC_11gR2_for_AIX-8.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-8.html)
>hash: 2768eafde01bfd43d827fec8366a5365  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105113202_677.png  

[293d73bed932c0589f2a570cc210fbc9]: media/Oracle-安装手册-RAC_11gR2_for_AIX-9.html
[Oracle-安装手册-RAC_11gR2_for_AIX-9.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-9.html)
>hash: 293d73bed932c0589f2a570cc210fbc9  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105113926_135.png  

[2ae104163a97acb3d244db209dd18181]: media/Oracle-安装手册-RAC_11gR2_for_AIX-10.html
[Oracle-安装手册-RAC_11gR2_for_AIX-10.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-10.html)
>hash: 2ae104163a97acb3d244db209dd18181  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105113900_423.png  

[3c53d6a4a43d1de9eb5e25221a4e642f]: media/Oracle-安装手册-RAC_11gR2_for_AIX-11.html
[Oracle-安装手册-RAC_11gR2_for_AIX-11.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-11.html)
>hash: 3c53d6a4a43d1de9eb5e25221a4e642f  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105111740_20.png  

[4bdfc5f483fdeb18e4a06e10ac2ba7ef]: media/Oracle-安装手册-RAC_11gR2_for_AIX-12.html
[Oracle-安装手册-RAC_11gR2_for_AIX-12.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-12.html)
>hash: 4bdfc5f483fdeb18e4a06e10ac2ba7ef  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105112649_669.png  

[516bbbb8f36911eafc295395716bfafa]: media/Oracle-安装手册-RAC_11gR2_for_AIX-13.html
[Oracle-安装手册-RAC_11gR2_for_AIX-13.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-13.html)
>hash: 516bbbb8f36911eafc295395716bfafa  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105113547_511.png  

[53f16ee5abe433f881c9cc80324a05fa]: media/Oracle-安装手册-RAC_11gR2_for_AIX-14.html
[Oracle-安装手册-RAC_11gR2_for_AIX-14.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-14.html)
>hash: 53f16ee5abe433f881c9cc80324a05fa  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105112930_623.png  

[55aa6e41ca9eff083f41e80947fa1c2f]: media/Oracle-安装手册-RAC_11gR2_for_AIX-15.html
[Oracle-安装手册-RAC_11gR2_for_AIX-15.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-15.html)
>hash: 55aa6e41ca9eff083f41e80947fa1c2f  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105112504_314.png  

[57b249f3199e2f1632901d1d91caba73]: media/Oracle-安装手册-RAC_11gR2_for_AIX-16.html
[Oracle-安装手册-RAC_11gR2_for_AIX-16.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-16.html)
>hash: 57b249f3199e2f1632901d1d91caba73  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105113639_88.png  

[580e4cab55e032002a585e3ea7b5c3db]: media/Oracle-安装手册-RAC_11gR2_for_AIX-17.html
[Oracle-安装手册-RAC_11gR2_for_AIX-17.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-17.html)
>hash: 580e4cab55e032002a585e3ea7b5c3db  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105112139_912.png  

[5b3993b953e43ce05a1799bb13bd4ae4]: media/Oracle-安装手册-RAC_11gR2_for_AIX-18.html
[Oracle-安装手册-RAC_11gR2_for_AIX-18.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-18.html)
>hash: 5b3993b953e43ce05a1799bb13bd4ae4  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105113437_623.png  

[5ec69b8c6677475e53830a7ee54ac646]: media/Oracle-安装手册-RAC_11gR2_for_AIX-19.html
[Oracle-安装手册-RAC_11gR2_for_AIX-19.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-19.html)
>hash: 5ec69b8c6677475e53830a7ee54ac646  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105112232_74.png  

[652ed40196c5b3f26ca407d257ace30d]: media/Oracle-安装手册-RAC_11gR2_for_AIX-20.html
[Oracle-安装手册-RAC_11gR2_for_AIX-20.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-20.html)
>hash: 652ed40196c5b3f26ca407d257ace30d  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105113939_871.png  

[69748ccbeddb747e4f931e36bd11024b]: media/Oracle-安装手册-RAC_11gR2_for_AIX-21.html
[Oracle-安装手册-RAC_11gR2_for_AIX-21.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-21.html)
>hash: 69748ccbeddb747e4f931e36bd11024b  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105112634_717.png  

[69c3fbfb54f81423c9fa8641e9b1c18f]: media/Oracle-安装手册-RAC_11gR2_for_AIX-22.html
[Oracle-安装手册-RAC_11gR2_for_AIX-22.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-22.html)
>hash: 69c3fbfb54f81423c9fa8641e9b1c18f  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105112814_494.png  

[6fa432cf8555d1be67f220813f644fe8]: media/Oracle-安装手册-RAC_11gR2_for_AIX-23.html
[Oracle-安装手册-RAC_11gR2_for_AIX-23.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-23.html)
>hash: 6fa432cf8555d1be67f220813f644fe8  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105113033_191.png  

[757dee528e39d2b3cfafc0491d71500a]: media/Oracle-安装手册-RAC_11gR2_for_AIX-24.html
[Oracle-安装手册-RAC_11gR2_for_AIX-24.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-24.html)
>hash: 757dee528e39d2b3cfafc0491d71500a  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105113355_916.png  

[75f6fb86dc9116b424ac61663fd22044]: media/Oracle-安装手册-RAC_11gR2_for_AIX-25.html
[Oracle-安装手册-RAC_11gR2_for_AIX-25.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-25.html)
>hash: 75f6fb86dc9116b424ac61663fd22044  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105112519_823.png  

[7991fbf813507c02d1bd3846c9312660]: media/Oracle-安装手册-RAC_11gR2_for_AIX-26.html
[Oracle-安装手册-RAC_11gR2_for_AIX-26.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-26.html)
>hash: 7991fbf813507c02d1bd3846c9312660  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105113742_611.png  

[82105731a5af5d3bdb741d158eb58ef6]: media/Oracle-安装手册-RAC_11gR2_for_AIX-27.html
[Oracle-安装手册-RAC_11gR2_for_AIX-27.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-27.html)
>hash: 82105731a5af5d3bdb741d158eb58ef6  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105112910_780.png  

[83bc9f79ada633eb659b74fca75ffedf]: media/Oracle-安装手册-RAC_11gR2_for_AIX-28.html
[Oracle-安装手册-RAC_11gR2_for_AIX-28.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-28.html)
>hash: 83bc9f79ada633eb659b74fca75ffedf  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105112944_336.png  

[842840d75d46797b8cac2d233af2a7b2]: media/Oracle-安装手册-RAC_11gR2_for_AIX-29.html
[Oracle-安装手册-RAC_11gR2_for_AIX-29.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-29.html)
>hash: 842840d75d46797b8cac2d233af2a7b2  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105113702_817.png  

[85d9102290bf4ad176569df799b290d5]: media/Oracle-安装手册-RAC_11gR2_for_AIX-30.html
[Oracle-安装手册-RAC_11gR2_for_AIX-30.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-30.html)
>hash: 85d9102290bf4ad176569df799b290d5  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105112828_528.png  

[8623e38cda028fe656e307bd3085f51c]: media/Oracle-安装手册-RAC_11gR2_for_AIX-31.html
[Oracle-安装手册-RAC_11gR2_for_AIX-31.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-31.html)
>hash: 8623e38cda028fe656e307bd3085f51c  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105112853_540.png  

[8d8522bdb3d8a53975a6f4eba16b8dc7]: media/Oracle-安装手册-RAC_11gR2_for_AIX-32.html
[Oracle-安装手册-RAC_11gR2_for_AIX-32.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-32.html)
>hash: 8d8522bdb3d8a53975a6f4eba16b8dc7  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105112559_6.png  

[8eb6de1e4c6399eecee4ca455a5623ac]: media/Oracle-安装手册-RAC_11gR2_for_AIX-33.html
[Oracle-安装手册-RAC_11gR2_for_AIX-33.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-33.html)
>hash: 8eb6de1e4c6399eecee4ca455a5623ac  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105112341_673.png  

[8fc7322dc0658e5c7a67a91bf0f2b2d3]: media/Oracle-安装手册-RAC_11gR2_for_AIX-34.html
[Oracle-安装手册-RAC_11gR2_for_AIX-34.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-34.html)
>hash: 8fc7322dc0658e5c7a67a91bf0f2b2d3  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105113610_384.png  

[933ef216dd6627a9d80e6fb2db4db1df]: media/Oracle-安装手册-RAC_11gR2_for_AIX-35.html
[Oracle-安装手册-RAC_11gR2_for_AIX-35.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-35.html)
>hash: 933ef216dd6627a9d80e6fb2db4db1df  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105112447_886.png  

[9b24e34bab9b46d80af8bbad357738b2]: media/Oracle-安装手册-RAC_11gR2_for_AIX-36.html
[Oracle-安装手册-RAC_11gR2_for_AIX-36.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-36.html)
>hash: 9b24e34bab9b46d80af8bbad357738b2  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105111706_889.png  

[9c71adb229af872d43a8865aeb64fff6]: media/Oracle-安装手册-RAC_11gR2_for_AIX-37.html
[Oracle-安装手册-RAC_11gR2_for_AIX-37.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-37.html)
>hash: 9c71adb229af872d43a8865aeb64fff6  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105112431_486.png  

[a5496347273be89df8e189793f9af8de]: media/Oracle-安装手册-RAC_11gR2_for_AIX-38.html
[Oracle-安装手册-RAC_11gR2_for_AIX-38.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-38.html)
>hash: a5496347273be89df8e189793f9af8de  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105113620_842.png  

[a5587d1e5aafd30b4b513e0d329832d1]: media/Oracle-安装手册-RAC_11gR2_for_AIX-39.html
[Oracle-安装手册-RAC_11gR2_for_AIX-39.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-39.html)
>hash: a5587d1e5aafd30b4b513e0d329832d1  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105112325_647.png  

[ae9d51069260c18a36edf9173d00d753]: media/Oracle-安装手册-RAC_11gR2_for_AIX-40.html
[Oracle-安装手册-RAC_11gR2_for_AIX-40.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-40.html)
>hash: ae9d51069260c18a36edf9173d00d753  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105113129_906.png  

[afae82162b585d75a21c1dcfde5ea3fc]: media/Oracle-安装手册-RAC_11gR2_for_AIX-41.html
[Oracle-安装手册-RAC_11gR2_for_AIX-41.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-41.html)
>hash: afae82162b585d75a21c1dcfde5ea3fc  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105112035_338.png  

[b1dd40ca6756ab53dc5bffbf348baa6f]: media/Oracle-安装手册-RAC_11gR2_for_AIX-42.html
[Oracle-安装手册-RAC_11gR2_for_AIX-42.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-42.html)
>hash: b1dd40ca6756ab53dc5bffbf348baa6f  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105111648_243.png  

[b391f63198892626fe407c03043fb5f5]: media/Oracle-安装手册-RAC_11gR2_for_AIX-43.html
[Oracle-安装手册-RAC_11gR2_for_AIX-43.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-43.html)
>hash: b391f63198892626fe407c03043fb5f5  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105111813_271.png  

[b5ce4fb4d134b127d0cce390f8ff550b]: media/Oracle-安装手册-RAC_11gR2_for_AIX-44.html
[Oracle-安装手册-RAC_11gR2_for_AIX-44.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-44.html)
>hash: b5ce4fb4d134b127d0cce390f8ff550b  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105113416_768.png  

[bf4815da4a1d2b8d5781dfe6bda581ce]: media/Oracle-安装手册-RAC_11gR2_for_AIX-45.html
[Oracle-安装手册-RAC_11gR2_for_AIX-45.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-45.html)
>hash: bf4815da4a1d2b8d5781dfe6bda581ce  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105113807_676.png  

[c39f745ff8bc2b93a19173fd630a1b16]: media/Oracle-安装手册-RAC_11gR2_for_AIX-46.html
[Oracle-安装手册-RAC_11gR2_for_AIX-46.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-46.html)
>hash: c39f745ff8bc2b93a19173fd630a1b16  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105113956_846.png  

[c43210215eb13f4b29472f5e2679c15f]: media/Oracle-安装手册-RAC_11gR2_for_AIX-47.html
[Oracle-安装手册-RAC_11gR2_for_AIX-47.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-47.html)
>hash: c43210215eb13f4b29472f5e2679c15f  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105113011_508.png  

[c5ef269c7bc7b6bec3885ec7ddc82cfe]: media/Oracle-安装手册-RAC_11gR2_for_AIX-48.html
[Oracle-安装手册-RAC_11gR2_for_AIX-48.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-48.html)
>hash: c5ef269c7bc7b6bec3885ec7ddc82cfe  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105112306_64.png  

[ce56f50e991d03c9885ae8bd58c4b2b0]: media/Oracle-安装手册-RAC_11gR2_for_AIX-49.html
[Oracle-安装手册-RAC_11gR2_for_AIX-49.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-49.html)
>hash: ce56f50e991d03c9885ae8bd58c4b2b0  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105112355_91.png  

[d0bca7d731be219a2e720276bfe3ee23]: media/Oracle-安装手册-RAC_11gR2_for_AIX-50.html
[Oracle-安装手册-RAC_11gR2_for_AIX-50.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-50.html)
>hash: d0bca7d731be219a2e720276bfe3ee23  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105112537_114.png  

[d5b7e489712728ba1dd7688592b7a6a5]: media/Oracle-安装手册-RAC_11gR2_for_AIX-51.html
[Oracle-安装手册-RAC_11gR2_for_AIX-51.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-51.html)
>hash: d5b7e489712728ba1dd7688592b7a6a5  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105112101_415.png  

[d6e3a01235626062797c7ed7619b9175]: media/Oracle-安装手册-RAC_11gR2_for_AIX-52.html
[Oracle-安装手册-RAC_11gR2_for_AIX-52.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-52.html)
>hash: d6e3a01235626062797c7ed7619b9175  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105112152_447.png  

[dc84080221cfa66c97b44236852c6f1a]: media/Oracle-安装手册-RAC_11gR2_for_AIX-53.html
[Oracle-安装手册-RAC_11gR2_for_AIX-53.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-53.html)
>hash: dc84080221cfa66c97b44236852c6f1a  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105113847_259.png  

[dd2726b3253c7044b9365ab0ca8160bd]: media/Oracle-安装手册-RAC_11gR2_for_AIX-54.html
[Oracle-安装手册-RAC_11gR2_for_AIX-54.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-54.html)
>hash: dd2726b3253c7044b9365ab0ca8160bd  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105113630_693.png  

[df3e567d6f16d040326c7a0ea29a4f41]: media/Oracle-安装手册-RAC_11gR2_for_AIX-55.html
[Oracle-安装手册-RAC_11gR2_for_AIX-55.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-55.html)
>hash: df3e567d6f16d040326c7a0ea29a4f41  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\spacer.gif  

[df6a894c5485528f28e02a8db5af0fec]: media/Oracle-安装手册-RAC_11gR2_for_AIX-56.html
[Oracle-安装手册-RAC_11gR2_for_AIX-56.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-56.html)
>hash: df6a894c5485528f28e02a8db5af0fec  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105111928_452.png  

[e068d237133178d16e7c562ce63e3886]: media/Oracle-安装手册-RAC_11gR2_for_AIX-57.html
[Oracle-安装手册-RAC_11gR2_for_AIX-57.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-57.html)
>hash: e068d237133178d16e7c562ce63e3886  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105113426_812.png  

[e0f4227f2e73f685fe4c25cbe1578d12]: media/Oracle-安装手册-RAC_11gR2_for_AIX-58.html
[Oracle-安装手册-RAC_11gR2_for_AIX-58.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-58.html)
>hash: e0f4227f2e73f685fe4c25cbe1578d12  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105113459_800.png  

[e3462a4c2a9a0a21b060552511ce7efb]: media/Oracle-安装手册-RAC_11gR2_for_AIX-59.html
[Oracle-安装手册-RAC_11gR2_for_AIX-59.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-59.html)
>hash: e3462a4c2a9a0a21b060552511ce7efb  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105111521_953.png  

[e44a7029b80405829625776f3754974e]: media/Oracle-安装手册-RAC_11gR2_for_AIX-60.html
[Oracle-安装手册-RAC_11gR2_for_AIX-60.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-60.html)
>hash: e44a7029b80405829625776f3754974e  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105111723_843.png  

[e99c2f4dda2a6e683c6073c7df128d37]: media/Oracle-安装手册-RAC_11gR2_for_AIX-61.html
[Oracle-安装手册-RAC_11gR2_for_AIX-61.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-61.html)
>hash: e99c2f4dda2a6e683c6073c7df128d37  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105112744_734.png  

[eada663c6addc467e04bc75589f00287]: media/Oracle-安装手册-RAC_11gR2_for_AIX-62.html
[Oracle-安装手册-RAC_11gR2_for_AIX-62.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-62.html)
>hash: eada663c6addc467e04bc75589f00287  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105112413_757.png  

[f3535121dcd1a9510afaa561b329d852]: media/Oracle-安装手册-RAC_11gR2_for_AIX-63.html
[Oracle-安装手册-RAC_11gR2_for_AIX-63.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-63.html)
>hash: f3535121dcd1a9510afaa561b329d852  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105113832_391.png  

[f40f329ec74bce4f1b665902327ea73e]: media/Oracle-安装手册-RAC_11gR2_for_AIX-64.html
[Oracle-安装手册-RAC_11gR2_for_AIX-64.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-64.html)
>hash: f40f329ec74bce4f1b665902327ea73e  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105113450_307.png  

[f824cf5bc9a4efa20ffa622d5e58230f]: media/Oracle-安装手册-RAC_11gR2_for_AIX-65.html
[Oracle-安装手册-RAC_11gR2_for_AIX-65.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-65.html)
>hash: f824cf5bc9a4efa20ffa622d5e58230f  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105112249_291.png  

[faab476f88a7a007d22cd085a4933cab]: media/Oracle-安装手册-RAC_11gR2_for_AIX-66.html
[Oracle-安装手册-RAC_11gR2_for_AIX-66.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-66.html)
>hash: faab476f88a7a007d22cd085a4933cab  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105113913_708.png  

[fd37cf3d7bae4fa54cd81587bb870921]: media/Oracle-安装手册-RAC_11gR2_for_AIX-67.html
[Oracle-安装手册-RAC_11gR2_for_AIX-67.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-67.html)
>hash: fd37cf3d7bae4fa54cd81587bb870921  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105112018_924.png  

[fd5f1a0b5a7ec2a1da073c88d8dc271b]: media/Oracle-安装手册-RAC_11gR2_for_AIX-68.html
[Oracle-安装手册-RAC_11gR2_for_AIX-68.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-68.html)
>hash: fd5f1a0b5a7ec2a1da073c88d8dc271b  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105113044_574.png  

[fdab52848445d062db21c7dd3bc36646]: media/Oracle-安装手册-RAC_11gR2_for_AIX-69.html
[Oracle-安装手册-RAC_11gR2_for_AIX-69.html](media/Oracle-安装手册-RAC_11gR2_for_AIX-69.html)
>hash: fdab52848445d062db21c7dd3bc36646  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX_files\20180105111959_717.png  

---
### NOTE ATTRIBUTES
>Created Date: 2018-09-25 03:29:27  
>Last Evernote Update Date: 2018-10-01 15:33:48  
>author: YangKwong  
>source: desktop.win  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC_11gR2_for_AIX.html  
>source-application: evernote.win32  