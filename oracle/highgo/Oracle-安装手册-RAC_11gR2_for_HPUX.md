# Oracle-安装手册-RAC_11gR2_for_HPUX

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

 **Swap Space Required**  
  
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

For HP-UX 11i V3 (11.31):

PHCO_40381 11.31 Disk Owner Patch

PHCO_41479 11.31 (fixes an 11.2.0.2 ASM disk discovery issue)

PHKL_38038 VM patch - hot patching/Core file creation directory

PHKL_38938 11.31 SCSI cumulative I/O patch

PHKL_39351 Scheduler patch : post wait hang

PHSS_36354 11.31 assembler patch

PHSS_37042 11.31 hppac (packed decimal)

PHSS_37959 Libcl patch for alternate stack issue fix (QXCR1000818011)

PHSS_39094 11.31 linker + fdp cumulative patch

PHSS_39100 11.31 Math Library Cumulative Patch

PHSS_39102 11.31 Integrity Unwind Library

PHSS_38141 11.31 aC++ Runtime

Pro*C/C++, Oracle Call Interface, Oracle C++

Pro*C/C++, Oracle Call Interface, Oracle C++ Call Interface, Oracle XML
Developer's Kit (XDK):-

Patch for HP-UX 11i V3 (11.31) on HP-UX Itanium:-

PHSS_39824 - 11.31 HP C/aC++ Compiler (A.06.23) patch

PHKL_40941 - Scheduler patch : post wait hang

 **参考文章Oracle Database (RDBMS) on Unix AIX,HP-UX,Linux,Mac OS X,Solaris,Tru64
Unix Operating Systems Installation and Configuration Requirements Quick
Reference (8.0.5 to 11.2) (** **文档 ID 169706.1)**

7、安装ssh，安装unzip（可选）

8、存储工程师从存储划出5块5G磁盘，其余用于存放数据库
数据的磁盘按每块1T的大小划分，如果存放数据库备份文件，也请规划好空间，各个磁盘是独立的lun，若是使用多路径的话，需要存储工程师把多路径软件在rac的所有节点上调试完毕。确保所有节点上看到的hdisk
number完全一致。

9、系统工程师设置主机名

注意主机名不能过长,不能超过8个字符，且不能有下划线等特殊符号，不要使用大写字母，建议使用小写字母即可。

 **2、 验证系统要求**

要验证系统是否满足 Oracle 11 _g_ 数据库的最低要求，以 root 用户身份登录并运行以下命令。

要查看可用 RAM 和交换空间大小，运行以下命令：

Machinfo 或者 /usr/contrib/bin/machinfo | grep -i Memory

swapinfo -a

例如：

 **slyy01#[/]machinfo**

CPU info:

Intel(R) Itanium(R) Processor 9540 (2.13 GHz, 24 MB)

8 cores, 16 logical processors per socket

6.38 GT/s QPI, CPU version D0

Active processor count:

4 sockets

32 cores (8 per socket)

32 logical processors (8 per socket)

LCPU attribute is disabled

 **Memory: 130893 MB (127.83 GB)**

Firmware info:

Firmware revision: 02.63

FP SWA driver revision: 1.23

IPMI is supported on this system.

BMC firmware revision: 1.70

Platform info:

Model: "ia64 hp Integrity BL870c i4"

Machine ID number: 555212c8-dd98-11e5-aeb4-e78a7e362712

Machine serial number: SGH601W8CY

OS info:

Nodename: slyy01

Release: HP-UX B.11.31

Version: U (unlimited-user license)

Machine: ia64

ID Number: 1431442120

vmunix _release_version:

@(#) $Revision: vmunix: B.11.31_LR FLAVOR=perf

 **slyy01#[/]swapinfo -a**

Kb Kb Kb PCT START/ Kb

TYPE AVAIL USED FREE USED LIMIT RESERVE PRI NAME

dev 8388608 0 8388608 0% 0 - 1 /dev/vg00/lvol2

dev 125829120 0 125829120 0% 0 - 1 /dev/vg00/lvswap

reserve - 591988 -591988

memory 127487168 12267176 115219992 10%

SwapTotal:1574360 kB

 **3、网络配置**

Hosts文件配置

每个主机vi /etc/hosts

10.20.8.31 slyy01

10.20.8.33 slyy02

10.20.8.32 slyy01-vip

10.20.8.34 slyy02-vip

2.2.2.2 slyy01-priv

2.2.2.3 slyy02-priv

10.20.8.30 scan

rac1、rac2 对应的是网卡的物理ip ，即public ip

rac1-priv、rac2-priv 对应的是心跳网卡的物理ip 即private ip

rac1-vip、rac2-vip 对应的是虚拟VIP

scan对应的SCAN ip

建议客户客户端连接rac群集，访问数据库时使用 SCAN ip地址。

 **注意** **：** **vip** **、** **public ip** **、** **scan ip** **必须要在同一个子网网段中。**

 **另外** **对于心跳** **IP** **地址的设置** **，** **不要设置成和客户局域网中存在的** **ip** **网段。**

 **如客户网络是** **192.x.x.x** **则设置心跳为** **10.x.x.x ,**
**心跳地址工程师可以自定义，但也要和客户确认客户局域网络是否有相同** **ip** **地址的服务器，尽量避免干扰。**

 **配置完心跳地址后** **,** **一定要使用** **traceroute** **测试心跳网络之间通讯是否正常** **.**
**心跳通讯是否正常不能简单地通过** **ping** **命令来检测** **.** **一定要使用** **traceroute**
**默认是采用** **udp** **协议** **.** **每次执行** **traceroute** **会发起三次检测** **,***
**号表示通讯失败** **.**

 **正常** **:**

 **[root@rac1 ~]# traceroute rac2-priv**

 **traceroute to rac2-priv (192.168.122.132), 30 hops max, 60 byte packets**

 **lsrac2-priv (192.168.122.132) 0.802 ms 0.655 ms 0.636 ms**

 **不正常** **:**

 **[root@lsrac1 ~]# traceroute rac2-priv**

 **traceroute to rac2-priv (192.168.122.132), 30 hops max, 60 byte packets**

 **1 lsrac2-priv (192.168.122.132) 1.187 ms * ***

 **如果经常出现** ***** **则需要先检测心跳网络通讯是否正常** **.**

 **4、安装软件包**

将需要安装的软件包列表提供给HPUX系统工程师，要求HP工程师进行安装。

 **参考文档Oracle Database (RDBMS) on Unix AIX,HP-UX,Linux,Mac OS X,Solaris,Tru64
Unix Operating Systems Installation and Configuration Requirements Quick
Reference (8.0.5 to 11.2) (** **文档 ID 169706.1)**

查看补丁是否安装命令

swlist –l <补丁名>

例：swlist –l PHSS_39824

For HP-UX 11i V3 (11.31):

PHCO_40381 11.31 Disk Owner Patch

PHCO_41479 11.31 (fixes an 11.2.0.2 ASM disk discovery issue)

PHKL_38038 VM patch - hot patching/Core file creation directory

PHKL_38938 11.31 SCSI cumulative I/O patch

PHKL_39351 Scheduler patch : post wait hang

PHSS_36354 11.31 assembler patch

PHSS_37042 11.31 hppac (packed decimal)

PHSS_37959 Libcl patch for alternate stack issue fix (QXCR1000818011)

PHSS_39094 11.31 linker + fdp cumulative patch

PHSS_39100 11.31 Math Library Cumulative Patch

PHSS_39102 11.31 Integrity Unwind Library

PHSS_38141 11.31 aC++ Runtime

Pro*C/C++, Oracle Call Interface, Oracle C++

Pro*C/C++, Oracle Call Interface, Oracle C++ Call Interface, Oracle XML
Developer's Kit (XDK):-

Patch for HP-UX 11i V3 (11.31) on **HP-UX Itanium:-**

PHSS_39824 - 11.31 HP C/aC++ Compiler (A.06.23) patch

PHKL_40941 - Scheduler patch : post wait hang

 **如果** **HP** **工程师可以提供更新的替代补丁，以** **HP** **工程师提供为准。**

 **HP** **系统补丁更新通常是在** **HP** **官方网站上下载一个补丁集合的压缩文件。**

 **如果因补丁下载等问题无法解决可以使用如下链接提供的补丁包。**

 **https://yunpan.cn/cSiuVJ8ne9UV2** **访问密码** **1dc8**

 **5、内核参数**

/usr/sbin/kcweb -F --可通过该命令查看参数设置

Oracle Database 11 _g_ 第 2 版需要如下所示的内核参数设置。给出的值都是最小值，因此如果系统使用更大的值，则不要更改。

 **调整** **filecache** **大小** **:**

kctune –h filecache_min =5%

kctune –h filecache_max =5%

 ** _参考文章_** ** _High memory utilization on HP-UX 11.31 due to parameter
"filecache_max" [ID 1264915.1]_**

 ** _参考链接_** **
_http://docs.oracle.com/cd/E11882_01/install.112/e49316/pre_install.htm#HPDBI1150_**

检查UDP和TCP内核参数：  
# /usr/bin/ndd /dev/tcp tcp_smallest_anon_port tcp_largest_anon_port  
# /usr/bin/ndd /dev/udp udp_smallest_anon_port udp_largest_anon_port

# cp /etc/rc.config.d/nddconf /etc/rc.config.d/nddconf.bak  
# vi /etc/rc.config.d/nddconf  
添加如下内容（按照顺序排列）：

TRANSPORT_NAME[0]=tcp

NDD_NAME[0]=tcp_largest_anon_port

NDD_VALUE[0]=65500

TRANSPORT_NAME[1]=udp

NDD_NAME[1]=udp_largest_anon_port

NDD_VALUE[1]=65500

 **修改内核参数**

kctune -h nproc="4096"

kctune -h ninode="(8*nproc+2048)"

kctune -h ksi_alloc_max="(nproc*8)"

kctune -h executable_stack="C0"

kctune -h max_thread_proc="1024"

kctune -h maxdsiz="1073741824"

kctune -h maxdsiz_64bit="2147483648"

kctune -h maxfiles="65536"

kctune -h maxfiles_lim="65536"

kctune -h maxssiz="134217728"

kctune -h maxssiz_64bit="1073741824"

kctune -h maxuprc="((nproc*9)/10)+1"

kctune -h msgmni="(nproc)"

kctune -h msgtql="(nproc)"

kctune -h ncsize="(ninode+1024)"

kctune -h nflocks="(nproc)"

kctune -h nkthread="(((nproc*7)/4)+16)"

kctune -h nproc="4096"

kctune -h semmni="(nproc)"

kctune -h semmns="(semmni*2)"

kctune -h semmnu="(nproc-4)"

kctune -h semvmx="32767"

kctune -h shmmni="4096"

kctune -h shmseg="512"

 **kctune -h shmmax="81589934592"**

#shmmax 1/2 of physical RAM( 单位B )

kctune -h tcp_largest_anon_port="65500"

kctune -h udp_largest_anon_port="65500"

 **修改完成之后需要重启生效**

 **6、配置异步IO**

 **调整** **/dev/async minor number** **为** **0x4**

a. Log in as the root user.

b. Determine whether /dev/async exists. If the device does not exist, then use
the

following command to create it:

c. # /sbin/mknod /dev/async c 101 0x4

Alternatively, you can set the minor number value to 0x104 using the following
command:

# /sbin/mknod /dev/async c 101 0x104

d. If /dev/async exists, then determine the current value of the minor number,
as shown

in the following example:

e. # ls -l /dev/async

crw-r--r-- 1 root sys 101 0x000000 Sep 28 10:38 /dev/async

f. If the existing minor number of the file is not 0x4 or 0x104, then change
it to an

expected value using one of the following commands:

# /sbin/mknod /dev/async c 101 0x4

or

# /sbin/mknod /dev/async c 101 0x104

g. 如果/dev/async文件存在并且不能直接/sbin/mknod /dev/async c 101 0x4修改，则

可以先mv，然后/sbin/mknod /dev/async c 101 0x4

h. 修改/dev/async权限如下：

#chown oracle:dba /dev/async

#chmod 660 /dev/async

否则,trace等文件会会报错如下：

*** 2013-04-19 16:03:37.886

Async driver not configured : errno=13

 **7、 修改操作系统时间**

检查多个服务器节点的操作系统时间是否一致。如果不一致要先手动修改。

如何同时修改两C台或者多台主机的时间一模一样呢？

建议使用SecureCRT工具、

使用方法：先登录一台主机

然后登录第二台主机

打开查看菜单，勾选交互窗口

窗口下方出现交互窗口

在交互窗口上右键菜单，勾选发送交互到所有会话。（此时要注意这个CRT窗口必须只能有RAC的两台服务器，不能有到其他主机的远程连接会话）

然后此时在交互窗口里输入的命令回车后都会自动发送到所有主机上执行。

hpux修改时间的命令是 ：月日时分

[root@rhel ~]# date 06290808

关闭NTP服务

Network Time Protocol Setting

# /sbin/service ntpd stop

# chkconfig ntpd off

#mv /etc/ntp.conf /etc/ntp.conf.org.

#service ntpd status

一定要保证时间同步，但是不能配置ntp，否则会导致11g的ctssd处于旁观模式。如果客户严格要求和北京时间一致，则考虑让客户提供时间服务器，然后再采用NTP和其时间服务器同步。如果配置NTP注意参数
-x 保证时间不能向回调，关于NTP配置此处不做详细解释。

 **8、修改主机名**

如果主机名不符合要求，可以使用如下方法修改：

使用set_parms hostname命令或者修改/etc/rc.config.d/netconf文件中的hostname，

修改完主机名务必重启生效

使用set parms hostname命令修改完成以后会提示是否进行重启，如下

 ** _Your changes will not take effect until you reboot the system._**

 ** _Do you want to reboot now?_**

 _Press [y] for yes or [n] for no, then press [Enter]  
Broadcast Message from root () Sun Dec 13 09:42:35...  
PLEASE LOG OFF NOW ! ! !  
System maintenance about to begin.  
All processes will be terminated in 0 seconds._

 _  
Broadcast Message from root () Sun Dec 13 09:42:35...  
SYSTEM BEING BROUGHT DOWN NOW ! ! !_

 **9、添加用户和组、创建目录**

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

ASM 的 SYSOPER

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

  * ASM 操作员组（OSOPER for ASM，一般为 asmoper） 

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

/usr/sbin/groupadd -g 1000 oinstall

/usr/sbin/groupadd -g 1100 asmadmin

/usr/sbin/groupadd -g 1200 dba

/usr/sbin/groupadd -g 1201 oper

/usr/sbin/groupadd -g 1300 asmdba

/usr/sbin/groupadd -g 1301 asmoper

useradd -u 1100 -g oinstall -G asmadmin,asmdba,asmoper grid

useradd -u 1200 -g oinstall -G dba,oper,asmdba oracle

修改grid、oracle 用户密码

passwd grid

passwd oracle

创建grid目录

# mkdir -p /u01/app/11.2.0/grid

# chown grid:oinstall /u01/ -R

# chmod 775 /u01/ -R

    
    
    创建oracle目录

# mkdir -p /u02/app/oracle/product/11.2.0/db_home

# chown oracle:oinstall /u02/ -R

# chmod 775 /u02/ -R

设置oinstall组的权限

root# setprivgrp oinstall MLOCK RTSCHED RTPRIO

root# getprivgrp oinstall

编辑/etc/privgroup

增加一行：

oinstall RTPRIO MLOCK RTSCHED

检查：

root# getprivgrp

正确应该显示：

global privileges: CHOWN

oinstall: RTPRIO MLOCK RTSCHED

设置dba组的权限（否则会出现trace文件疯涨）

Grant dba group the MLOCK priv to avoid the Ioctl ASYNC_CONFIG trace file
errors:

(1) # /usr/sbin/setprivgrp dba MLOCK  
(2) # vi /etc/privgroup  
This should contain dba MLOCK RTSCHED RTPRIO  
(3) # cat /etc/privgroup  
dba MLOCK RTSCHED RTPRIO

修改grid用户环境变量

登录rac节点1

cd /home/grid/

vi .profile

export ORACLE_BASE=/u01/app/grid

export ORACLE_HOME=/u01/app/11.2.0/grid

export ORACLE_SID=+ASM1

export PATH=$ORACLE_HOME/bin:$PATH

export

 **export JAVA_HOME=/opt/java6**

export PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$ORACLE_HOME/bin:$PATH

 **export SHLIB_PATH=$ORACLE_HOME/lib:$ORACLE_HOME/rdbms/lib:/lib:/usr/lib**

 **export
CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib:$ORACLE_HOME/network/jlb**

注意要添加JAVA_HOME、 **CLASSPATH** **、** **SHLIB_PATH** 变量，否则后面安装PSU补丁时会报错。

 **注意：** **grid** **用户环境变量** **ORACLE_HOME** **不在** **ORACLE_BASE** **目录下**

 **su - oracle**

修改oracle 用户环境变量,其中ORACLE_SID ，让开发商定好数据库名称，SID后面分别添加1和2。

cd /home/oracle

vi .profile

export ORACLE_BASE=/u01/app/grid

export ORACLE_HOME=/u01/app/11.2.0/grid

export ORACLE_SID=

export PATH=$ORACLE_HOME/bin:$PATH

export

export JAVA_HOME=/opt/java6

export PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$ORACLE_HOME/bin:$PATH

export SHLIB_PATH=$ORACLE_HOME/lib:$ORACLE_HOME/rdbms/lib:/lib:/usr/lib

export
CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib:$ORACLE_HOME/network/jlb

登录RAC节点2

cd /home/grid/

vi .profile

export ORACLE_BASE=/u01/app/grid

export ORACLE_HOME=/u01/app/11.2.0/grid

export ORACLE_SID=+ASM1

export PATH=$ORACLE_HOME/bin:$PATH

export

export JAVA_HOME=/opt/java6

export PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$ORACLE_HOME/bin:$PATH

export SHLIB_PATH=$ORACLE_HOME/lib:$ORACLE_HOME/rdbms/lib:/lib:/usr/lib

export
CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib:$ORACLE_HOME/network/jlb

 **注意：** **grid** **用户环境变量** **ORACLE_HOME** **不在** **ORACLE_BASE** **目录下**

修改oracle 用户环境变量

cd /home/oracle

vi .profile

export ORACLE_BASE=/u01/app/grid

export ORACLE_HOME=/u01/app/11.2.0/grid

export ORACLE_SID=

export PATH=$ORACLE_HOME/bin:$PATH

export

export JAVA_HOME=/opt/java6

export PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$ORACLE_HOME/bin:$PATH

export SHLIB_PATH=$ORACLE_HOME/lib:$ORACLE_HOME/rdbms/lib:/lib:/usr/lib

export
CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib:$ORACLE_HOME/network/jlb

 **10、ASM配置共享磁盘**

11.3开始，hp-ux自带native_multi-path多路径软件，支持绝大多数存储设备，一般情况下不再需要安装存储厂商的多路径软件。执行ioscan
-m dsf可以查看多路径后的一个设备（diskxx）和多路径前的多个原始设备（cxtxdx）之间的对应关系。

这种情况下，如果存在多条路径，虽然每个lun在系统上看到有多个对应的设备文件，但是通过native multi path多路径软件，

同一个lun的多个设备文件会对应一个逻辑设备（diskxx），类似emc的powerdisk。

确保系统工程师已经将存储划分完成并将多路径软件部署完成

检查共享磁盘聚合前后对应关系

ioscan -m dsf

查看磁盘大小

diskinfo /dev/dsk/disk*

区别本地磁盘以及外挂磁盘

ioscan -fnkC disk

查看lun信息

ioscan -m lun

修改所有节点磁盘属性（两节点分别执行）

chown grid:asmadmin/dev/rdsk/disk41

chmod 660 /dev/rdsk/disk41

。。。

 **11、为用户等效性设置SSH**

在 两节点 上执行

mkdir ~/.ssh

chmod 700 ~/.ssh

ssh-keygen -t rsa

ssh-keygen -t dsa

在 rac1 上执行

cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys

ssh slyy02 cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

ssh slyy02 cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys

scp ~/.ssh/authorized_keys slyy02:~/.ssh/authorized_keys

在每个节点上测试连接。验证当您再次运行以下命令时，系统是否不提示您输入口令。

ssh slyy01 date

ssh slyy02 date

ssh slyy01-priv date

ssh slyy02-priv date

 **12、建立安装软件时需要的链接**

# cd /usr/lib

ln -s /usr/lib/libX11.3 libX11.sl

ln -s /usr/lib/libXIE.2 libXIE.sl

ln -s /usr/lib/libXext.3 libXext.sl

ln -s /usr/lib/libXhp11.3 libXhp11.sl

ln -s /usr/lib/libXi.3 libXi.sl

ln -s /usr/lib/libXm.4 libXm.sl

ln -s /usr/lib/libXp.2 libXp.sl

ln -s /usr/lib/libXt.3 libXt.sl

ln -s /usr/lib/libXtst.2 libXtst.sl

ll libX*.sl

 **13、验证安装介质md5值**

安装介质如非官方途径下载，需要验证md5值，避免使用网络上被篡改过的恶意介质

 **HPUX** **：**

 **MD5:**

 **$ openssl dgst -md5 oracle.aurora.javadoc.zip**

 **得出的值和如下官方提供的** **md5** **值进行对比，如果** **md5** **值不同，则表示文件有可能被篡改过** **，**
**不可以使用。**

 **文件的名字发生变化并不影响** **md5** **值的校验结果。**

详见《Oracle各版本安装包md5校验手册v2.docx》

 **14、安装 Oracle Grid Infrastructure**

Xmanager连接服务器

root登录

1、解压群集安装程序（可能会存在没有unzip命令的情况，此时应该从本地解压缩，然后 **以二进制的方式上传到服务器** ）

#xhost+

#echo $DISPLAY

192.168.211.26:0.0

#su - grid

$export DISPLAY=192.168.211.26:0.0

Xhost +

$./runInstaller

以下截图内值均未参考选项，以实际内容为准。

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

 **需要手工配置** **oracle** **用户和** **grid** **用户的** **ssh** **互信**

根据定义的网卡选择网络类型 public 还是 心跳private

 **ASM** **必须达到一定的密码标准。密码中要包含字母大写、小写、数字，至少** **8** **个字符。**

点击fix & check again，并运行提示脚本修正上述参数，但参数有可能需要重启生效，

因此运行修正脚本后如果依然提示anon_port参数不符合可以先勾选ignore all，后面再重启服务器即可。 **重启命令** **shutdown
–ry 0**

在两个节点分别以root用户执行提示的脚本。

若集群root.sh脚本运行不成功：

#删除crs配置信息

#/u01/app/11.2.0/grid/crs/install/rootcrs.pl -verbose -deconfig -force

 **15、集群安装后的任务**

(1)、验证oracle clusterware的安装

以grid身份运行以下命令：

检查crs状态：

[grid@rac1 ~]$ crsctl check crs

CRS-4638: Oracle High Availability Services is online

CRS-4537: Cluster Ready Services is online

CRS-4529: Cluster Synchronization Services is online

CRS-4533: Event Manager is online

检查 Clusterware 资源:

[grid@rac1 ~]$ crsctl stat res -t

\----------------------------------------------------------

NAME TARGET STATE SERVER STATE_DETAILS

\--------------------------------------------------------------

Local Resources

\--------------------------------------------------------------

ora.DATA.dg ONLINE ONLINE rac1

ONLINE ONLINE rac2

ora.FRA.dg ONLINE ONLINE rac1

ONLINE ONLINE rac2

ora.LISTENER.lsnr ONLINE ONLINE rac1

ONLINE ONLINE rac2

ora.OCR.dg ONLINE ONLINE rac1

ONLINE ONLINE rac2

ora.asm ONLINE ONLINE rac1 Started

ONLINE ONLINE rac2 Started

ora.gsd OFFLINE OFFLINE rac1

OFFLINE OFFLINE rac2

ora.net1.network ONLINE ONLINE rac1

ONLINE ONLINE rac2

ora.ons ONLINE ONLINE rac1

ONLINE ONLINE rac2

ora.registry.acfs ONLINE ONLINE rac1

ONLINE ONLINE rac2

\--------------------------------------------------------------

Cluster Resources

\--------------------------------------------------------------

ora.LISTENER_SCAN1.lsnr

1 ONLINE ONLINE rac1

ora.cvu

1 ONLINE ONLINE rac1

ora.oc4j

1 ONLINE ONLINE rac1

ora.rac1.vip

1 ONLINE ONLINE rac1

ora.rac2.vip

1 ONLINE ONLINE rac2

ora.scan1.vip

1 ONLINE ONLINE rac1

检查集群节点:

[grid@rac1 ~]$ olsnodes -n

rac1 1

rac2 2

检查两个节点上的 Oracle TNS 监听器进程:

[grid@rac1 ~]$ srvctl status listener

Listener LISTENER is enabled

Listener LISTENER is running on node(s): rac2,rac1

(2)创建 ASM 磁盘组

asmca

在 Disk Groups 选项卡中，单击 **Create** 按钮，在出现的画面中创建data卷：

除了CRS磁盘组以外其余存放数据和归档的磁盘组默认都是选择Extenal外部冗余模式，除非客户特殊要求。

对于磁盘组的规划，一般一套rac 含有一个CRS磁盘组，一个FRA磁盘组用于存放归档日志，一个或者多个DATA磁盘组用于存放数据。

单击Exit退出ASM配置向导。

 **至此重启下服务器确认** **crs** **各个资源状态均正常。**

 **16、安装oracle 11g r2 database**

Xmanager图形化登录服务器

root用户登录

依次解压个安装包

#xhost+

#echo $DISPLAY

192.168.211.26:0.0

#su - oracle

$export DISPLAY=192.168.211.26:0.0

Xhost +

$./runInstaller

需要手工配置oracle用户的ssh互信

待安装完成后在各个节点执行root.sh脚本，完成后退出向导。

 **17、创建、删除数据库**

建议

数据文件，归档日志分开存放在不同的，文件系统路径或ASM路径中

控制文件和在线日志多路复用时，放在不同的，磁盘驱动器或ASM磁盘组中

数据库位于文件系统时，将数据文件和在线日志放在不同的磁盘驱动器中

 **17.1 创建数据库**

使用dbca创建，创建之前确保已安装的所有服务（Oracle TNS 监听器、Oracle Clusterware 进程等）正在运行。

[grid@rac1 ~]$ crsctl stat res -t

\----------------------------------------------------------

NAME TARGET STATE SERVER STATE_DETAILS

\--------------------------------------------------------------

Local Resources

\--------------------------------------------------------------

ora.DATA.dg ONLINE ONLINE rac1

ONLINE ONLINE rac2

ora.FRA.dg ONLINE ONLINE rac1

ONLINE ONLINE rac2

ora.LISTENER.lsnr ONLINE ONLINE rac1

ONLINE ONLINE rac2

ora.OCR.dg ONLINE ONLINE rac1

ONLINE ONLINE rac2

ora.asm ONLINE ONLINE rac1 Started

ONLINE ONLINE rac2 Started

ora.gsd OFFLINE OFFLINE rac1

OFFLINE OFFLINE rac2

ora.net1.network ONLINE ONLINE rac1

ONLINE ONLINE rac2

ora.ons ONLINE ONLINE rac1

ONLINE ONLINE rac2

ora.registry.acfs ONLINE ONLINE rac1

ONLINE ONLINE rac2

\--------------------------------------------------------------

Cluster Resources

\--------------------------------------------------------------

ora.LISTENER_SCAN1.lsnr

1 ONLINE ONLINE rac1

ora.cvu

1 ONLINE ONLINE rac1

ora.oc4j

1 ONLINE ONLINE rac1

ora.rac1.vip

1 ONLINE ONLINE rac1

ora.rac2.vip

1 ONLINE ONLINE rac2

ora.scan1.vip

1 ONLINE ONLINE rac1

[grid@rac1 ~]$

点击"Multiplex Redo Logs and Control Files" 输入多个磁盘组来产生冗余控制文件和redo文件。如果存在+FRA则填写
+DATA和+FRA

如果不存在+FRA，只有+DATA ，则添加两个+DATA

原则就是要多个控制文件和redo文件，而且尽量要存放在不同的磁盘组中。

保守的设置原则是 ：

SGA_TARGET+pga_aggregate_target=物理内存*0.6

SGA_TARGET : pga_aggregate_target 比例是4:1

SGA_TARGET 等于 SGA_MAX_SIZE

根据实际物理内存进行调整。

此处关于内存设置，HPUX和AIX 可以选择使用Typical ,并勾选Use Automatic Memory
Management来启用AMM内存管理机制，建议比例为物理内存的60%。

 **字符集的必须和开发人员进行确认，不能猜测使用，数据库建立完成后字符集不能进行修改。**

 **分别为** **Thread1** **和** **Therad2** **添加一组** **REDO** **，并修改所有** **redo**
**大小为** **256M** **或者** **512M** **。**

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

 **18.安装PSU**

 **HPUX** **安装** **PSU** **需要使用** **java** **，所以需要在环境变量中做好配置**

 **HPUX** **安装** **PSU** **之前需要安装** **bash** ，否则会报出如下错误

OPATCHAUTO-72049: Script execution failed due to Cannot run program "bash":
bash: not found.

OPATCHAUTO-72049: Please correct the environment and re run the opatchauto.

HP-UX中使用的默认shell是POSIX
shell，也就是/usr/bin/sh，并且提供了ksh和csh，但就是不提供bash，要使用bash需要自己安装。根据软件依存关系，需要安装4个包，分别是：gettext、libiconv、termcap、bash
可以到官网下载：<http://hpux.connect.org.uk/hppd/hpux/>，

一、查询机器信息

先查看HP-UX机器的操作系统版本、机型、CPU架构等信息，我查得自己的服务器信息如下：

操作系统版本：B.11.23

位数：64

机型：ia64 hp server rx2600

CPU架构：Intel(R) Itanium 2

二、安装包下载

根据系统信息下载了以下几个安装包：

gettext-0.18.2.1-ia64-11.23.depot.gz

libiconv-1.14-ia64-11.23.depot.gz

termcap-1.3.1-ia64-11.23.depot.gz

bash-4.2.045-ia64-11.23.depot.gz

三、安装

把安装包放到服务器上，先解压成depot后缀的包再开始安装，注意，需要按照以下顺序安装：

# swinstall -s /lzx/gettext-0.18.2.1-ia64-11.23.depot gettext

# swinstall -s /lzx/libiconv-1.14-ia64-11.23.depot libiconv

# swinstall -s /lzx/termcap-1.3.1-ia64-11.23.depot termcap

# swinstall -s /lzx/bash-4.2.045-ia64-11.23.depot bash

用swinstall命令安装时一定要写绝对路径，相对路径是会报错的，后面要写软件包名。

四、使用bash

用命令：

# export PATH=$PATH:/usr/local/bin/bash

或者

# /usr/local/bin/bash

都可以启动到bash环境下。

或者将这个命令加入到$HOME/.profile文件里，这样下次登录时就自动启动到bash

**相关安装** **PSU** **的步骤参照《** **Oracle_PSU** **安装手册》**

 **建议先** **dbca** **建库，再打** **psu** **。**

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
  
# include disabled applications  
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

 _# Start database  
srvctl start database -d orcl -o nomount  
srvctl start database -d orcl -o mount  
srvctl start database -d orcl -o open_

 _# Grammar for start instance  
srvctl start instance -d [db_name] -i [instance_name]  
-o [start_option] -c [connect_str] __–_ _q_

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
  
# Grammar for stop instance  
srvctl stop instance -d [db_name] -i [instance_name]  
-o [start_option] -c [connect_str] -q  
  
# Stop all instances on the all nodes  
srvctl stop instance -d orcl -i orcl1,orcl2,...  
  
# Stop ASM instance  
srvctl stop ASM -n [node_name] -i asm1 -o [option]  
  
# Stop all apps in one node  
srvctl stop nodeapps -n [node_name]_

 **19.2、启动/停止集群命令**

 _以下停止/_ _启动操作需要以_` _root_` _身份来执行_

 ** _在本地服务器上停止 Oracle Clusterware 系统_**

 _在` rac1` 节点上使用 `crsctl stop cluster` 命令停止 Oracle Clusterware 系统：_

 ** _#/u01/app/11.2.0/grid/bin/crsctl stop cluster_**

 ** _注：_** _在运行“_` _crsctl stop cluster_` _”_ _命令之后，如果 Oracle Clusterware_
_管理的资源中有任何一个还在运行，则整个命令失败。使用_` _-f_` _选项无条件地停止所有资源并停止 Oracle Clusterware_ _系统。_

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

 ** _TNS_** ** _监听器 —（状态）_**

 _[oracle@rac1 ~]$ **srvctl status listener**_

 _Listener LISTENER is enabled_

 _Listener LISTENER is running on node(s): rac1,rac2_

 ** _TNS_** ** _监听器 —（配置）_**

 _[oracle@rac1 ~]$ **srvctl config listener -a**_

 _Name: LISTENER_

 _Network: 1, Owner: grid_

 _Home:_

 _/u01/app/11.2.0/grid on node(s) rac2,rac1_

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

 _/u01/app/11.2.0/grid on node(s) rac2,rac1_

 _End points: TCP:1521_

 **20、卸载软件**

 **20.1卸载Oracle Grid Infrastructure**

 _Deconfiguring Oracle Clusterware Without Removing Binaries_

 _cd /u01/app/11.2.0/grid/crs/install_

    
    
    1、Run rootcrs.pl with the -deconfig -force flags. For example
    
    
    # perl rootcrs.pl -deconfig –force
    
    
    Repeat on other nodes as required
    
    
    2、If you are deconfiguring Oracle Clusterware on all nodes in the cluster, then on the last node, enter the following command:

 _#_ _perl rootcrs.pl -deconfig -force –lastnode_

 _3_ _、_ _Removing Grid Infrastructure_

 _The default method for running the deinstall tool is from the deinstall
directory in the grid home. For example:_

    
    
    $ cd /u01/app/11.2.0/grid/deinstall
    
    
    $ ./deinstall

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

    
    
    $ cd $ORACLE_HOME/deinstall
    
    
    $ ./deinstall

 _Reserve.conf_

 _Crs-4402_

 **21、收尾工作**

修改数据库默认参数：

alter system set deferred_segment_creation=FALSE;

alter system set audit_trail =none scope=spfile;

alter system set SGA_MAX_SIZE =xxxxxM scope=spfile;

alter system set SGA_TARGET =xxxxxM scope=spfile;

alter systemn set pga_aggregate_target =XXXXXM scope=spfile;

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

部署OSW，HPUX环境下脚本有待验证，直接使用linux上部署OSW方法有可能会导致开机启动卡在启动脚本位置，而导致系统无法启动。

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

rm -rf /home/oracle/oracle/*

rm -rf /etc/rc.d/rc5.d/S96init.crs

rm -rf /etc/rc.d/init.d/init.crs

rm -rf /etc/rc.d/rc4.d/K96init.crs

rm -rf /etc/rc.d/rc6.d/K96init.crs

rm -rf /etc/rc.d/rc1.d/K96init.crs

rm -rf /etc/rc.d/rc0.d/K96init.crs

rm -rf /etc/rc.d/rc2.d/K96init.crs

rm -rf /etc/rc.d/rc3.d/S96init.crs

rm -rf /etc/oracle/*

rm -rf /etc/oraInst.loc

rm -rf /etc/oratab

rm -rf /usr/local/bin/coraenv

rm -rf /usr/local/bin/dbhome

rm -rf /usr/local/bin/oraenv

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

Measure

Measure


---
### ATTACHMENTS
[00b6ec0e1d32e5c3c41221056cd56821]: media/20180105153838_490.png
[20180105153838_490.png](media/20180105153838_490.png)
>hash: 00b6ec0e1d32e5c3c41221056cd56821  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153838_490.png  
>file-name: 20180105153838_490.png  

[08ed444ab642a1fdca0d29901f63d05d]: media/20180105154334_19.png
[20180105154334_19.png](media/20180105154334_19.png)
>hash: 08ed444ab642a1fdca0d29901f63d05d  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105154334_19.png  
>file-name: 20180105154334_19.png  

[1d8e8a223f7b367607f557c3be878cb7]: media/20180105153723_594.png
[20180105153723_594.png](media/20180105153723_594.png)
>hash: 1d8e8a223f7b367607f557c3be878cb7  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153723_594.png  
>file-name: 20180105153723_594.png  

[22a77819dc366d970bb9486945b7bf16]: media/20180105154054_266.png
[20180105154054_266.png](media/20180105154054_266.png)
>hash: 22a77819dc366d970bb9486945b7bf16  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105154054_266.png  
>file-name: 20180105154054_266.png  

[25457662ffb635d3d3d9e94f584a4c6f]: media/20180105154415_610.png
[20180105154415_610.png](media/20180105154415_610.png)
>hash: 25457662ffb635d3d3d9e94f584a4c6f  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105154415_610.png  
>file-name: 20180105154415_610.png  

[267a0f154a9c9f7d844a06acde55a2f1]: media/20180105153355_195.png
[20180105153355_195.png](media/20180105153355_195.png)
>hash: 267a0f154a9c9f7d844a06acde55a2f1  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153355_195.png  
>file-name: 20180105153355_195.png  

[2d2931fa478a5ec4ffb6996a3299029d]: media/20180105154025_418.png
[20180105154025_418.png](media/20180105154025_418.png)
>hash: 2d2931fa478a5ec4ffb6996a3299029d  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105154025_418.png  
>file-name: 20180105154025_418.png  

[30f81f689312dfc2d0298d7f7a206b61]: media/20180105153958_768.png
[20180105153958_768.png](media/20180105153958_768.png)
>hash: 30f81f689312dfc2d0298d7f7a206b61  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153958_768.png  
>file-name: 20180105153958_768.png  

[35423e16eef89b0a8f8478e9056aaafd]: media/20180105153456_182.png
[20180105153456_182.png](media/20180105153456_182.png)
>hash: 35423e16eef89b0a8f8478e9056aaafd  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153456_182.png  
>file-name: 20180105153456_182.png  

[3c39245533676cf6d694c5f820b2aed6]: media/20180105154037_928.png
[20180105154037_928.png](media/20180105154037_928.png)
>hash: 3c39245533676cf6d694c5f820b2aed6  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105154037_928.png  
>file-name: 20180105154037_928.png  

[3c53d6a4a43d1de9eb5e25221a4e642f]: media/20180105153038_45.png
[20180105153038_45.png](media/20180105153038_45.png)
>hash: 3c53d6a4a43d1de9eb5e25221a4e642f  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153038_45.png  
>file-name: 20180105153038_45.png  

[46a7f280300274d3afcd31ed21380c51]: media/20180105153201_923.png
[20180105153201_923.png](media/20180105153201_923.png)
>hash: 46a7f280300274d3afcd31ed21380c51  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153201_923.png  
>file-name: 20180105153201_923.png  

[49b811441ec26c5454e20e8b52b0ec2c]: media/20180105153210_523.png
[20180105153210_523.png](media/20180105153210_523.png)
>hash: 49b811441ec26c5454e20e8b52b0ec2c  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153210_523.png  
>file-name: 20180105153210_523.png  

[52af867d2e1fd0946cbe3e2035d25990]: media/20180105153507_873.png
[20180105153507_873.png](media/20180105153507_873.png)
>hash: 52af867d2e1fd0946cbe3e2035d25990  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153507_873.png  
>file-name: 20180105153507_873.png  

[530807808baa568befcfe0aece17de2d]: media/20180105154249_188.png
[20180105154249_188.png](media/20180105154249_188.png)
>hash: 530807808baa568befcfe0aece17de2d  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105154249_188.png  
>file-name: 20180105154249_188.png  

[577959095af1b6b24b303a9454b2fd0f]: media/20180105153258_937.png
[20180105153258_937.png](media/20180105153258_937.png)
>hash: 577959095af1b6b24b303a9454b2fd0f  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153258_937.png  
>file-name: 20180105153258_937.png  

[598b09d04401c2799e11d256f0d58b83]: media/20180105153411_569.png
[20180105153411_569.png](media/20180105153411_569.png)
>hash: 598b09d04401c2799e11d256f0d58b83  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153411_569.png  
>file-name: 20180105153411_569.png  

[6bdc707a23fdd5addcb65df0ee9903d9]: media/20180105154405_79.png
[20180105154405_79.png](media/20180105154405_79.png)
>hash: 6bdc707a23fdd5addcb65df0ee9903d9  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105154405_79.png  
>file-name: 20180105154405_79.png  

[6f5a7e811bc91485886fbb93d80e816c]: media/20180105153326_552.png
[20180105153326_552.png](media/20180105153326_552.png)
>hash: 6f5a7e811bc91485886fbb93d80e816c  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153326_552.png  
>file-name: 20180105153326_552.png  

[71594cbd3abea719b1ed1cc753f956b6]: media/20180105153312_318.png
[20180105153312_318.png](media/20180105153312_318.png)
>hash: 71594cbd3abea719b1ed1cc753f956b6  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153312_318.png  
>file-name: 20180105153312_318.png  

[73f2ee0840529d572a401b17965678de]: media/20180105153817_807.png
[20180105153817_807.png](media/20180105153817_807.png)
>hash: 73f2ee0840529d572a401b17965678de  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153817_807.png  
>file-name: 20180105153817_807.png  

[7449ea796dded8f834af0b98c4df020f]: media/20180105153531_559.png
[20180105153531_559.png](media/20180105153531_559.png)
>hash: 7449ea796dded8f834af0b98c4df020f  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153531_559.png  
>file-name: 20180105153531_559.png  

[748cab7ed247c8770d4bb8f569ad0e42]: media/20180105154144_456.png
[20180105154144_456.png](media/20180105154144_456.png)
>hash: 748cab7ed247c8770d4bb8f569ad0e42  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105154144_456.png  
>file-name: 20180105154144_456.png  

[7c643b4f82cf914e082183869430b833]: media/20180105153543_241.png
[20180105153543_241.png](media/20180105153543_241.png)
>hash: 7c643b4f82cf914e082183869430b833  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153543_241.png  
>file-name: 20180105153543_241.png  

[7dc2d69aab05cd230339febb1030e1de]: media/20180105154225_200.png
[20180105154225_200.png](media/20180105154225_200.png)
>hash: 7dc2d69aab05cd230339febb1030e1de  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105154225_200.png  
>file-name: 20180105154225_200.png  

[826e0ddae2f3f633066aed18e3206760]: media/20180105153137_401.png
[20180105153137_401.png](media/20180105153137_401.png)
>hash: 826e0ddae2f3f633066aed18e3206760  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153137_401.png  
>file-name: 20180105153137_401.png  

[82c1b655ac55eb57af1fa4fe0ba3af2f]: media/20180105153643_401.png
[20180105153643_401.png](media/20180105153643_401.png)
>hash: 82c1b655ac55eb57af1fa4fe0ba3af2f  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153643_401.png  
>file-name: 20180105153643_401.png  

[8feb69dc86a13f579947c1d02449f026]: media/20180105153517_298.png
[20180105153517_298.png](media/20180105153517_298.png)
>hash: 8feb69dc86a13f579947c1d02449f026  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153517_298.png  
>file-name: 20180105153517_298.png  

[93266e4b392df3e231c069b8014a4774]: media/20180105154321_887.png
[20180105154321_887.png](media/20180105154321_887.png)
>hash: 93266e4b392df3e231c069b8014a4774  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105154321_887.png  
>file-name: 20180105154321_887.png  

[953836a19f433c050e07d27933f548fd]: media/20180105153555_990.png
[20180105153555_990.png](media/20180105153555_990.png)
>hash: 953836a19f433c050e07d27933f548fd  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153555_990.png  
>file-name: 20180105153555_990.png  

[95fc93b88a1d13570432101574bf32ef]: media/20180105154153_105.png
[20180105154153_105.png](media/20180105154153_105.png)
>hash: 95fc93b88a1d13570432101574bf32ef  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105154153_105.png  
>file-name: 20180105154153_105.png  

[97ecf68a3afe9c08b3a7a7f42d2c3597]: media/20180105153755_627.png
[20180105153755_627.png](media/20180105153755_627.png)
>hash: 97ecf68a3afe9c08b3a7a7f42d2c3597  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153755_627.png  
>file-name: 20180105153755_627.png  

[995c6bc20a31a5888549a22a761a7407]: media/20180105153942_515.png
[20180105153942_515.png](media/20180105153942_515.png)
>hash: 995c6bc20a31a5888549a22a761a7407  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153942_515.png  
>file-name: 20180105153942_515.png  

[9b05655ab745146e0ec4c99a62c5728e]: media/20180105154011_39.png
[20180105154011_39.png](media/20180105154011_39.png)
>hash: 9b05655ab745146e0ec4c99a62c5728e  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105154011_39.png  
>file-name: 20180105154011_39.png  

[9b24e34bab9b46d80af8bbad357738b2]: media/20180105153008_549.png
[20180105153008_549.png](media/20180105153008_549.png)
>hash: 9b24e34bab9b46d80af8bbad357738b2  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153008_549.png  
>file-name: 20180105153008_549.png  

[9eb3862eee06ff0e68d84a2fe87a3afe]: media/20180105153424_335.png
[20180105153424_335.png](media/20180105153424_335.png)
>hash: 9eb3862eee06ff0e68d84a2fe87a3afe  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153424_335.png  
>file-name: 20180105153424_335.png  

[a123887d2116a87f71bd6ee5f393b0fe]: media/20180105153701_650.png
[20180105153701_650.png](media/20180105153701_650.png)
>hash: a123887d2116a87f71bd6ee5f393b0fe  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153701_650.png  
>file-name: 20180105153701_650.png  

[a50c48b9889cea0b2e41951e2cbac076]: media/20180105153932_525.png
[20180105153932_525.png](media/20180105153932_525.png)
>hash: a50c48b9889cea0b2e41951e2cbac076  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153932_525.png  
>file-name: 20180105153932_525.png  

[ac2af876bfe035d6bf243e5a09a120a3]: media/20180105154202_860.png
[20180105154202_860.png](media/20180105154202_860.png)
>hash: ac2af876bfe035d6bf243e5a09a120a3  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105154202_860.png  
>file-name: 20180105154202_860.png  

[b1dd40ca6756ab53dc5bffbf348baa6f]: media/20180105152954_549.png
[20180105152954_549.png](media/20180105152954_549.png)
>hash: b1dd40ca6756ab53dc5bffbf348baa6f  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105152954_549.png  
>file-name: 20180105152954_549.png  

[b391f63198892626fe407c03043fb5f5]: media/20180105153053_973.png
[20180105153053_973.png](media/20180105153053_973.png)
>hash: b391f63198892626fe407c03043fb5f5  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153053_973.png  
>file-name: 20180105153053_973.png  

[b47b9f651fa29a7feaa539512997ec42]: media/20180105153731_954.png
[20180105153731_954.png](media/20180105153731_954.png)
>hash: b47b9f651fa29a7feaa539512997ec42  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153731_954.png  
>file-name: 20180105153731_954.png  

[ba6b367892822a4f93391d8b221ed5af]: media/20180105154127_207.png
[20180105154127_207.png](media/20180105154127_207.png)
>hash: ba6b367892822a4f93391d8b221ed5af  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105154127_207.png  
>file-name: 20180105154127_207.png  

[bd93e91d8b6045616530297a2af65fd2]: media/20180105153149_510.png
[20180105153149_510.png](media/20180105153149_510.png)
>hash: bd93e91d8b6045616530297a2af65fd2  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153149_510.png  
>file-name: 20180105153149_510.png  

[bf4815da4a1d2b8d5781dfe6bda581ce]: media/20180105154258_576.png
[20180105154258_576.png](media/20180105154258_576.png)
>hash: bf4815da4a1d2b8d5781dfe6bda581ce  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105154258_576.png  
>file-name: 20180105154258_576.png  

[bfd16cb84c6cd2b6f0529153456b2407]: media/20180105154212_313.png
[20180105154212_313.png](media/20180105154212_313.png)
>hash: bfd16cb84c6cd2b6f0529153456b2407  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105154212_313.png  
>file-name: 20180105154212_313.png  

[c83cd7322b226c185450600b818c403b]: media/20180105154239_639.png
[20180105154239_639.png](media/20180105154239_639.png)
>hash: c83cd7322b226c185450600b818c403b  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105154239_639.png  
>file-name: 20180105154239_639.png  

[cdf24e3b491b22b52cfc615ee5601059]: media/20180105154119_374.png
[20180105154119_374.png](media/20180105154119_374.png)
>hash: cdf24e3b491b22b52cfc615ee5601059  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105154119_374.png  
>file-name: 20180105154119_374.png  

[cf2bd67e068a9c9d1625ed0d93beb6ce]: media/20180105153633_170.png
[20180105153633_170.png](media/20180105153633_170.png)
>hash: cf2bd67e068a9c9d1625ed0d93beb6ce  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153633_170.png  
>file-name: 20180105153633_170.png  

[cfe105f0548fc4141d2ff6a2d6ccb4f9]: media/20180105153859_501.png
[20180105153859_501.png](media/20180105153859_501.png)
>hash: cfe105f0548fc4141d2ff6a2d6ccb4f9  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153859_501.png  
>file-name: 20180105153859_501.png  

[d5a32357e03447e1c4da2c5e98cd312e]: media/20180105153221_30.png
[20180105153221_30.png](media/20180105153221_30.png)
>hash: d5a32357e03447e1c4da2c5e98cd312e  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153221_30.png  
>file-name: 20180105153221_30.png  

[d790ce669101d00c0de0d133bc9cf606]: media/20180105153747_684.png
[20180105153747_684.png](media/20180105153747_684.png)
>hash: d790ce669101d00c0de0d133bc9cf606  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153747_684.png  
>file-name: 20180105153747_684.png  

[d8710049a2ed8403357399403250e153]: media/20180105153433_178.png
[20180105153433_178.png](media/20180105153433_178.png)
>hash: d8710049a2ed8403357399403250e153  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153433_178.png  
>file-name: 20180105153433_178.png  

[dc3741c0fbc7dd7a20a44fb17ed7b4d8]: media/20180105154434_724.png
[20180105154434_724.png](media/20180105154434_724.png)
>hash: dc3741c0fbc7dd7a20a44fb17ed7b4d8  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105154434_724.png  
>file-name: 20180105154434_724.png  

[e44a7029b80405829625776f3754974e]: media/20180105153022_924.png
[20180105153022_924.png](media/20180105153022_924.png)
>hash: e44a7029b80405829625776f3754974e  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153022_924.png  
>file-name: 20180105153022_924.png  

[e640f071b79911f5e7234b55e28e87aa]: media/20180105153342_303.png
[20180105153342_303.png](media/20180105153342_303.png)
>hash: e640f071b79911f5e7234b55e28e87aa  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153342_303.png  
>file-name: 20180105153342_303.png  

[e9148591a8f969c40666d8ef0debd378]: media/20180105154344_829.png
[20180105154344_829.png](media/20180105154344_829.png)
>hash: e9148591a8f969c40666d8ef0debd378  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105154344_829.png  
>file-name: 20180105154344_829.png  

[eae1019396569841e04b93cf85d2c59e]: media/20180105153614_436.png
[20180105153614_436.png](media/20180105153614_436.png)
>hash: eae1019396569841e04b93cf85d2c59e  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153614_436.png  
>file-name: 20180105153614_436.png  

[f01a62578a939138c93ae14e70c22bbd]: media/20180105154355_547.png
[20180105154355_547.png](media/20180105154355_547.png)
>hash: f01a62578a939138c93ae14e70c22bbd  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105154355_547.png  
>file-name: 20180105154355_547.png  

[f3535121dcd1a9510afaa561b329d852]: media/20180105154311_607.png
[20180105154311_607.png](media/20180105154311_607.png)
>hash: f3535121dcd1a9510afaa561b329d852  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105154311_607.png  
>file-name: 20180105154311_607.png  

[ff050b814829a263fbda36bacf2f7faf]: media/20180105153850_723.png
[20180105153850_723.png](media/20180105153850_723.png)
>hash: ff050b814829a263fbda36bacf2f7faf  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153850_723.png  
>file-name: 20180105153850_723.png  

[ffce4a2dd9bc4f8881b6f5b9913bd84e]: media/20180105153918_190.png
[20180105153918_190.png](media/20180105153918_190.png)
>hash: ffce4a2dd9bc4f8881b6f5b9913bd84e  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180105153918_190.png  
>file-name: 20180105153918_190.png  


---
### TAGS
{Support20180830}

---
### NOTE ATTRIBUTES
>Created Date: 2018-08-30 02:12:45  
>Last Evernote Update Date: 2018-10-01 15:33:56  
>source: web.clip7  
>source-url: https://47.100.29.40/highgo_admin/#/index/docSearchDetail/b865d7058507a2  
>source-application: WebClipper 7  