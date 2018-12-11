# Oracle-安装手册-rhel7 Oracle 11gR2 RAC安装

# 瀚高技术支持管理平台

## 新特性

lOracle 11gR2将自动存储 **管理** (ASM)和Oracle Clusterware集成在Oracle Grid
Infrastructure中。Oracle ASM和Oracle Database
11gR2提供了较以前版本更为增强的存储解决方案，该解决方案能够在ASM上存储Oracle
Clusterware文件，即Oracle集群注册表(OCR)和表决文件（VF，又称为表决磁盘）。这一特性使ASM能够提供一个统一的存储解决方案，无需使用第三方卷管理器或集群文件系统即可存储集群件和数据库的所有数据

lSCAN（single client access name）即简单客户端连接名，一个方便客户端连接的接口；在Oracle
11gR2之前，client链接数据库的时候要用vip，假如cluster有4个节点，那么客户端的tnsnames.ora中就对应有四个主机vip的一个连接串，如果cluster增加了一个节点，那么对于每个连接数据库的客户端都需要修改这个tnsnames.ora。SCAN简化了客户端连接，客户端连接的时候只需要知道这个名称，并连接即可，每个SCAN
VIP对应一个scan listener，cluster内部的service在每个scan listener上都有注册，scan
listener接受客户端的请求，并转发到不同的Local listener中去，由local的listener提供服务给客户端

l此外，安装GRID的过程也简化了很多，内核参数的设置可保证安装的最低设置，验证安装后执行fixup.sh即可，此外ssh互信设置可以自动完成，尤其不再使用OCFS及其复杂设置，直接使用ASM存储

## 1、验证系统要求

要验证系统是否满足 Oracle 11 _g_ 数据库的最低要求，以 root 用户身份登录并运行以下命令。

要查看可用 RAM 和交换空间大小，运行以下命令：

grep MemTotal /proc/meminfo

grep SwapTotal /proc/meminfo

例如：

# grep MemTotal /proc/meminfo

MemTotal:512236 kB

# grep SwapTotal /proc/meminfo

SwapTotal:1574360 kB

The minimum required RAM is 1.5 GB for grid infrastructure for a cluster, or
2.5 GB for grid infrastructure for a cluster and Oracle RAC. The minimum
required swap space is 1.5 GB. Oracle recommends that you set swap space to
1.5 times the amount of RAM for systems with 2 GB of RAM or less. For systems
with 2 GB to 16 GB RAM, use swap space equal to RAM. For systems with more
than 16 GB RAM, use 16 GB of RAM for swap space. If the swap space and the
grid home are on the same filesystem, then add together their respective disk
space requirements for the total minimum space required.

## 2、初始化系统服务：

关闭NUMA  
https://access.redhat.com/solutions/23216  
https://access.redhat.com/solutions/48756  
详细步骤参考附件：  
“How to determine if NUMA configuration is enabled or disabled_.pdf”  
“How to disable NUMA in Red Hat Enterprise Linux system.pdf”

关闭防火墙

systemctl stop firewalld.service

systemctl disable firewalld.service

关闭selinux:

vi /etc/selinux/config

SELINUX=disabled

#avahi-daemon 1501093.1

service avahi-daemon stop

chkconfig avahi-daemon off

关闭 NetworkManager 服务

systemctl stop NetworkManager.service

systemctl disable NetworkManager.service

启动network服务

service network start

chkconfig network on

## 3、网络配置

rhel7 安装完后网卡的命名规则是 eno16777736 如果要改成eth0 的形式：

vim /etc/sysconfig/grub

然后，往这个文件中添加“net.ifnames=0 biosdevname=0”内容，如下图所示：

上图中，红框部分是我所添加的内容（注意它的位置）。

紧接着，执行如下命令：

grub2-mkconfig -o /boot/grub2/grub.cfg

重启服务器，名字就发生了变化。

udev对网卡名称绑定：

vi /etc/udev/rules.d/70-persistent-net.rules

[root@rac1 ~]# vi /etc/udev/rules.d/70-persistent-net.rules

SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*",
ATTR{address}=="00:0c:29:28:15:78", ATTR{type}=="1", KERNEL=="eth*",
NAME="eth0"

SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*",
ATTR{address}=="00:0c:29:28:15:82", ATTR{type}=="1", KERNEL=="eth*",
NAME="eth1"

设置IP：

虽然ifconfig发现名字变回了eth0但是 配置文件仍让是en016777736.

复制eth0配置文件，

[root@localhost network-scripts]# cp ifcfg-eno16777736 ifcfg-eth0

网卡文件配置vi ifcfg-eth0

/etc/sysconfig/network-scripts/ifcfg-eth0文件为：

TYPE=Ethernet

BOOTPROTO=static

DEFROUTE=yes

PEERDNS=yes

PEERROUTES=yes

IPV4_FAILURE_FATAL=no

IPV6INIT=yes

IPV6_AUTOCONF=yes

IPV6_DEFROUTE=yes

IPV6_PEERDNS=yes

IPV6_PEERROUTES=yes

IPV6_FAILURE_FATAL=no

NAME=eth0

UUID=43344c1d-2103-4193-ad1a-2ae0cfda9b75

DEVICE=eth0

ONBOOT=yes

IPADDR=192.168.188.142

PREFIX=24

GATEWAY=192.168.188.2

同理配置心跳网络，但是心跳网络不要配置网关地址GATEWAY

 **参考文档：**

 **Oracle Linux 7: How to modify Network Interface names (** **文档** **ID
2080965.1)**

修改lo网络的mtu为1500，末尾追加MTU="1500"

[root@rac2 ~]# vi /etc/sysconfig/network-scripts/ifcfg-lo

DEVICE=lo

IPADDR=127.0.0.1

NETMASK=255.0.0.0

NETWORK=127.0.0.0

# If you're having problems with gated making 127.0.0.0/8 a martian,

# you can change this to something else (255.255.255.255, for example)

BROADCAST=127.255.255.255

ONBOOT=yes

NAME=loopback

MTU="1500"

 **参考文章：** **  
Skgxpvfynet: Mtype: 61 Process 23043 Failed Because Of A Resource Problem In
The OS (** **文档** **ID 2014681.1)**

Hosts文件配置

每个主机vi /etc/hosts

192.168.0.25 rac1

192.168.0.26 rac2

192.0.10.125 rac1-priv

192.0.10.126 rac2-priv

192.168.0.125 rac1-vip

192.168.0.130 rac2-vip

192.168.0.127 scan

rac1、rac2 对应的是网卡的物理ip ，即public ip

rac1-priv、rac2-priv 对应的是心跳网卡的物理ip 即private ip

rac1-vip、rac2-vip 对应的是虚拟VIP

scan对应的SCAN ip

建议客户客户端连接rac群集，访问数据库时使用 SCAN ip地址。

 **注意** **：** **vip** **、** **public ip** **、** **scan ip** **必须要在同一个子网网段中。**

 **另外** **对于心跳** **IP** **地址的设置** **，** **不要设置成和客户局域网中存在的** **ip** **网段。**

 **如客户网络是** **192.x.x.x** **则设置心跳为** **10.x.x.x ,**
**心跳地址工程师可以自定义，但也要和客户确认客户局域网络是否有相同** **ip** **地址的服务器，尽量避免干扰。**

配置完心跳地址后,一定要使用traceroute测试心跳网络之间通讯是否正常.心跳通讯是否正常不能简单地通过ping命令来检测.一定要使用traceroute默认是采用udp协议.每次执行traceroute会发起三次检测,*号表示通讯失败.

正常:

[root@rac1 ~]# traceroute rac2-priv

traceroute to rac2-priv (192.168.122.132), 30 hops max, 60 byte packets

1lsrac2-priv (192.168.122.132) **0.802 ms 0.655 ms 0.636 ms**

不正常:

[root@lsrac1 ~]# traceroute rac2-priv

traceroute to rac2-priv (192.168.122.132), 30 hops max, 60 byte packets

1 lsrac2-priv (192.168.122.132) 1.187 ms *** ***

如果经常出现* 则需要先检测心跳网络通讯是否正常.

## 3.2、网络配置检查

rac安装前检查，从11.2.0.2（含）开始，ORACLE私网通讯不再直接采用“我们在私网网卡上所配置的地址（例如192.168这样的地址）”，而是采用GRID启动后，ORACLE在私网网卡上绑定的169.254这个网段的地址，而部分x86服务器会带有IBM
IMM设备，这个设备主要用来进行硬件管理通过LANG或USB网络，默认IMM设备地址是169.254网段，这可能会造成IP冲突，169网段路由信息被清除，引起私网心跳不通问题

检查 是否存在169.xxx.xxx.xx的 网卡，如有，设置成静态并分配其他IP地址。

# ifconfig -a

..

usb0 Link encap:Ethernet HWaddr XX:XX:XX:XX:XX:XX

inet addr:169.254.xx.xx Bcast:169.254.95.255 Mask:255.255.255.0

修改这些网络设备如USB0口不采用DHCP，而是直接采用静态IP

修改dhcp为static，并分配其他IP

# vi /etc/sysconfig/network-scripts/ifcfg-usb0

# BOOTPROTO=dhcp

BOOTPROTO=static

IPADDR=xxx.xxx.xxx.xxx

重启网卡，使改变生效

/sbin/ifdown usb0

/sbin/ifup usb0

/sbin/ifconfig usb0

## 4、安装软件包

将操作系统盘放入光驱并挂载mount /dev/sr0 /mnt

或者可上传系统ISO，并挂载镜像mount -o loop xxx.iso /mnt

配置yum安装程序

vi /etc/yum.repos.d/rhel.repo

输入如下内容：

[rhel]

name=rhel

baseurl=file:///mnt

enabled=1

gpgcheck=0

执行如下名命令允许yum默认同时安装32和64位的rpm包

echo 'multilib_policy=all' >> /etc/yum.conf

可以执行如下命令安装所有需要的rpm

yum install elfutils-libelf-devel binutils compat-libcap* gcc gcc-c++ glibc
glibc-devel ksh libaio libaio-devel libgcc libstdc++ libstdc++-devel libXi
libXtst make sysstat tiger* iscsi* -y

其中compat-libstdc++-33-3.2.3 在rhel7的镜像中默认没有，需要单独安装。

见附件“”

 **参考文章：** **Requirements for Installing Oracle 11.2.0.4 RDBMS on OL7 or RHEL7
64-bit (x86-64) (** **文档** **ID 1962100.1)**

## 5、内核参数

 **/etc/sysctl.conf** **这里面的修改可以通过安装过程中运行**` **runfixup.sh**` **脚本自动修改。**

 **在安装过程中，系统会提示。**

Oracle Database 11 _g_ 第 2
版需要如下所示的内核参数设置。给出的值都是最小值，因此如果系统使用更大的值，则不要更改。其中shmmax和shmall要根据实际物理内存进行计算。

vi /etc/sysctl.conf

kernel.shmmax = 4294967295

#shmmax 1/2 of physical RAM( 单位B )See
[Note:567506.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1962100.1&id=567506.1)
for more information.

kernel.shmall = 2097152

#shmall等于物理内存（单位B）/page_size ,而page_size大小是运行getconf PAGE_SIZE 命令获得的，一般是4096B
See [Note
301830.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1962100.1&id=301830.1)
for more information.

kernel.shmmni = 4096

kernel.sem = 250 32000 100 128

fs.file-max = 6815744

net.ipv4.ip_local_port_range = 9000 65500

net.core.rmem_default=262144

net.core.rmem_max=4194304

net.core.wmem_default=262144

net.core.wmem_max=1048576

fs.aio-max-nr= 4194304

vm.min_free_kbytes=512MB

注意：在linux内核为2.6.31及以上版本中针对HAIP环境（多个内联心跳地址）添加以下参数

net.ipv4.conf.私有网卡1.rp_filter=2

net.ipv4.conf.私有网卡2.rp_filter=2

将'私有网卡n'替换成实际网卡名称。

参考mos文章

RAC and Oracle Clusterware Best Practices and Starter Kit (Linux) (Doc ID
811306.1)

运行如下命令是参数立即生效。

[root@racnode1 ~]# sysctl -p

 **参考文章：** **Requirements for Installing Oracle 11.2.0.4 RDBMS on OL7 or RHEL7
64-bit (x86-64) (** **文档** **ID 1962100.1)**

## 6、设置oracle的shell限制：

vi /etc/security/limits.conf

#for oracle

grid soft nofile 1024

grid hard nofile 65536

grid hard stack 10240

oracle soft nofile 1024

oracle hard nofile 65536

oracle hard stack 10240

修改使以上参数生效：

vi /etc/pam.d/login

添加如下行

session required pam_limits.so

 **注意》**

nproc参数的生效并不是在/etc/security/limits.conf里生效，是需要在

/etc/security/limits.d/20-nproc.conf 文件中设置

参考：

|

 **Setting nproc values on Oracle Linux 6 for RHCK kernel (** **文档** **ID
2108775.1)**  
  
---|---  
  
[root@localhost limits.d]# cat 20-nproc.conf

# Default limit for number of user's processes to prevent

# accidental fork bombs.

# See rhbz #432903 for reasoning.

* soft nproc 1024

root soft nproc unlimited

不要修改默认的 * soft nproc 1024

要添加oracle和grid 项

grid soft nproc 2047

grid hard nproc 16384

oracle soft nproc 2047

oracle hard nproc 16384

nproc值表示该用户下的最大进程数max user processes如果业务进程较多，则可能因为进程达到上限而使得操作系统用户无法登陆。

查看当前用户的max user processes，可登录到指定的系统用户下

[root@localhost security]# ulimit -a

core file size (blocks, -c) 0

data seg size (kbytes, -d) unlimited

scheduling priority (-e) 0

file size (blocks, -f) unlimited

pending signals (-i) 23692

max locked memory (kbytes, -l) 32

max memory size (kbytes, -m) unlimited

open files (-n) 1024

pipe size (512 bytes, -p) 8

POSIX message queues (bytes, -q) 819200

real-time priority (-r) 0

stack size (kbytes, -s) 10240

cpu time (seconds, -t) unlimited

max user processes (-u) 23692

virtual memory (kbytes, -v) unlimited

file locks (-x) unlimited

## 7、修改操作系统时间

检查多个服务器节点的操作系统时间是否一致。如果不一致要先手动修改。

如何同时修改两台或者多台主机的时间一模一样呢？

建议使用SecureCRT工具、

使用方法：先登录一台主机

然后登录第二台主机

打开查看菜单，勾选交互窗口

窗口下方出现交互窗口

在交互窗口上右键菜单，勾选发送交互到所有会话。（此时要注意这个CRT窗口必须只能有RAC的两台服务器，不能有到其他主机的远程连接会话）

然后此时在交互窗口里输入的命令回车后都会自动发送到所有主机上执行。

linx修改时间的命令是 ：年月日 时分秒

[root@rhel ~]# date -s "20100405 14:31:00"

Oracle默认使用ctssd进行节点间时间同步，建议关闭操作系统的时间同步服务

 **Unable to Configure NTP after Oracle Linux 7 Installation (** **文档** **ID
1995703.1)**

 **CTSSD Runs in Observer Mode Even Though No Time Sync Software is Running
(** **文档** **ID 1054006.1)**

 **rhel7** **默认不安装** **ntp** **服务** **，而是被** **chronyd** **服务代替。**

禁用chronyd

# systemctl stop chronyd

# mv /etc/chrony.conf /etc/nouse_chrony.conf

# systemctl disable chronyd

如果安装有NTP服务，则禁用

/bin/systemctl stop ntpd.service

systemctl disable ntpd.service

mv /etc/ntp.conf /etc/ntp.conf.bak

一定要保证节点间时间同步，但是不能配置ntp，否则会导致11g的ctssd处于旁观模式。如果客户严格要求和北京时间一致，则考虑让客户提供时间服务器，然后再采用NTP或chronyd和其时间服务器同步。如果配置NTP注意参数
-x 保证时间不能向回调，关于NTP配置此处不做详细解释。

## 8、Redhat 7.2中安装oracle存在的bug修复方法

ALERT: Setting RemoveIPC=yes on Redhat 7.2 Crashes ASM and Database Instances
as Well as Any Application That Uses a Shared Memory Segment (SHM) or
Semaphores (SEM) (文档 ID 2081410.1)

设置了RemoveIPC=yes 的RHEL7.2 会crash掉Oracle asm 实例和Oracle
database实例，该问题也会在使用Shared Memory Segment (SHM) or Semaphores (SEM)的应用程序中发生。

在安装oracle的服务器中修改如下：

1) 在 /etc/systemd/logind.conf中设置RemoveIPC=no

2) Reboot the server or restart systemd-logind as follows:  
# systemctl daemon-reload  
# systemctl restart systemd-logind

## 9、修改主机名

查看主机名：

[root@localhost ~]# hostnamectl status

Static hostname: localhost.localdomain

Transient hostname: rac1

Icon name: computer

Chassis: n/a

Machine ID: 05683ff226ee4229b62037ea081b4697

Boot ID: a1052f601184411a86d78fee5f1bff7c

Virtualization: vmware

Operating System: Red Hat Enterprise Linux Server 7.1 (Maipo)

CPE OS Name: cpe:/o:redhat:enterprise_linux:7.1:GA:server

Kernel: Linux 3.10.0-229.el7.x86_64

Architecture: x86_64

修改主机名：

[root@localhost ~]#hostnamectl set-hostname **rac1**

注意主机名不能过长,不能超过8个字符，且不能有下划线等特殊符号，不要使用大写字母，建议使用小写字母即可。

## 10、添加用户和组、创建目录

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

 **rhel7** **安装操作系统时必须创建一个普通用户，建议删除，如果用户名是** **oracle** **同样建议删除，再重建即可。**

userdel -r oracle

创建用户和组：

/usr/sbin/groupadd -g 1001 oinstall

/usr/sbin/groupadd -g 1100 asmadmin

/usr/sbin/groupadd -g 1200 dba

/usr/sbin/groupadd -g 1201 oper

/usr/sbin/groupadd -g 1300 asmdba

/usr/sbin/groupadd -g 1301 asmoper

useradd -u 1100 -g oinstall -G asmadmin,asmdba,asmoper grid

useradd -u 1200 -g oinstall -G dba,oper,asmdba oracle

# passwd grid

# passwd oracle

创建grid目录

mkdir -p /u01/app/11.2.0/grid

chown grid:oinstall /u01/ -R

chmod 775 /u01/ -R

创建oracle目录

mkdir -p /u02/app/oracle/product/11.2.0/db_home

chown oracle:oinstall /u02/ -R

chmod 775 /u02/ -R

修改grid用户环境变量

登录rac节点1

su - grid

vi .bash_profile

ORACLE_SID=+ASM1; export ORACLE_SID

ORACLE_BASE=/u01/app/grid; export ORACLE_BASE

ORACLE_HOME=/u01/app/11.2.0/grid; export ORACLE_HOME

umask 022

PATH=$ORACLE_HOME/bin:$PATH:$HOME/bin

export PATH

 **注意：** **grid** **用户环境变量** **ORACLE_HOME** **不在** **ORACLE_BASE** **目录下**

 **su - oracle**

修改oracle 用户环境变量,其中ORACLE_SID ，让开发商定好数据库名称，SID后面分别添加1和2。

su - oracle

vi .bash_profile

export ORACLE_SID=orcl1

export ORACLE_BASE=/u02/app/oracle

export ORACLE_HOME=/u02/app/oracle/product/11.2.0/db_home

PATH=$ORACLE_HOME/bin:$PATH:$HOME/bin

export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$ORACLE_HOME/rdbms/lib:/lib:/usr/lib

umask 022

export PATH

登录RAC节点2

su - grid

vi .bash_profile

ORACLE_SID=+ASM2; export ORACLE_SID

ORACLE_BASE=/u01/app/grid; export ORACLE_BASE

ORACLE_HOME=/u01/app/11.2.0/grid; export ORACLE_HOME

umask 022

PATH=$ORACLE_HOME/bin:$PATH:$HOME/bin

export PATH

 **注意：** **grid** **用户环境变量** **ORACLE_HOME** **不在** **ORACLE_BASE** **目录下**

 **su - oracle**

修改oracle 用户环境变量

su - oracle

vi .bash_profile

export ORACLE_SID=orcl2

export ORACLE_BASE=/u02/app/oracle

export ORACLE_HOME=/u02/app/oracle/product/11.2.0/db_home

PATH=$ORACLE_HOME/bin:$PATH:$HOME/bin

export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$ORACLE_HOME/rdbms/lib:/lib:/usr/lib

umask 022

export PATH

## 11、ASM配置共享磁盘

 _配置_ _iscsi_

 _在_ _RHEL5_ _系统中_ _,_ _下载并安装_ _iSCSI_ _启动器软件包_

 _# rpm -ivh iscsi-initiator-utils-6.2.0.742-0.5.el5.i386.rpm_

 _2._ _在_ _RHEL5_ _系统中_ _,_ _生成并查看_ _iSCSI_ _启动器的名称_

 _# echo "InitiatorName=`iscsi-iname`" >/etc/iscsi/initiatorname.iscsi_

 _# cat /etc/iscsi/initiatorname.iscsi_

 _InitiatorName=iqn.2005-03.com.redhat:01.b9d0dd11016_

 _3._ _在_ _RHEL5_ _系统中_ _,_ _配置_ _iSCSI_ _启动器服务_

 _# vi /etc/iscsi/iscsid.conf(iSCSI_ _启动器服务的配置文件_ _)_

 _node.session.auth.authmethod = CHAP_

 _node.session.auth.username = iqn.2005-03.com.redhat:01.b9d0dd11016_

 _node.session.auth.password = 01.b9d0dd11016_

 _# systemctl enable iscsi.service_

 _systemctl start iscsi.service_

 _rm -rf /var/lib/iscsi/nodes/*_

 _rm -rf /var/lib/iscsi/send_targets/*_

 _iscsiadm -m discovery -t st -p_ _192.168.100.91 (_ _发现_ _)_

 _[root@localhost ~]# iscsiadm -m discovery -t st -p 192.168.100.91_

 _iscsiadm: No portals found_

 _[root@open1 ~]# vi /etc/initiators.deny_

 _#_ _注释掉当前的_ _iqn_ _号_

 _# iqn.2006-01.com.openfiler:tsn.a7fdfa71c47e ALL_

 _iscsiadm -m node -T iqn.2006-01.com.openfiler:tsn.a7fdfa71c47e -p
192.168.100.91 -l (_ _登录_ _)_

### 11.1使用linux操作系统自带multipath多路径软件的情况：

 **参考文章：**

 **Deploying Oracle Database 12c on** **Red Enterprise Linux 7**

<https://www.redhat.com/en/files/resources/en-rhel-deploying-
Oracle-12c-rhel-7.pdf>

 **参考文章：** **How to set udev rules in OL7 related to ASM on multipath disks
(** **文档** **ID 2101679.1)**

生成multipath.conf文件

/sbin/mpathconf --enable

查询磁盘设备的wwid

for i in `cat /proc/partitions | awk '{print $4}' |grep sd | grep [a-z]$`; do
echo "### $i: ` /usr/lib/udev/scsi_id -g -u -d /dev/$i`"; done

多路径配置文件内容/etc/multipath.conf，修改wwid和别名alias

# cat /etc/multipath.conf  
defaults {

polling_interval 5

path_grouping_policy multibus

prio const

path_checker directio

rr_min_io 1000

rr_weight uniform

failback manual

no_path_retry fail

user_friendly_names yes

}

blacklist {

devnode "^(ram|raw|loop|fd|md|dm-|sr|scd|st)[0-9]*"

devnode "^hd[a-z]"

devnode "^cciss!c[0-9]d[0-9]*"

}

multipaths {

multipath {

wwid 14f504e46494c45525743714d4f6a2d6437466f2d30435362

alias fra

path_grouping_policy multibus

}

multipath {

wwid 14f504e46494c4552664857314b622d576f63582d6f324743

alias data

path_grouping_policy multibus

}

multipath {

wwid 14f504e46494c45524f616d324a4f2d463255562d42764747

alias ocr1

path_grouping_policy multibus

}

multipath {

wwid 14f504e46494c455230336f4738382d684268682d66306a32

alias ocr2

path_grouping_policy multibus

}

multipath {

wwid 14f504e46494c455241653457776c2d527a4c712d6c625178

alias ocr3

path_grouping_policy multibus

}

multipath {

wwid 14f504e46494c45524146554f7a732d6b6443752d6e4f7956

alias ocr4

path_grouping_policy multibus

}

multipath {

wwid 14f504e46494c4552416a4e6938672d363876662d6d636735

alias ocr5

path_grouping_policy multibus

}

}

启动、查看multipathd.service状态

systemctl start multipathd.service

systemctl status multipathd.service

将multipathd.service设置为开机自启

systemctl enable multipathd.service

查看多路径状态

multipath –ll

查看多路径磁盘对应的dm-X 名称

ls -l /dev/mapper/|grep dm*

将共享存储磁盘列表抓取出来，通过notepad++工具进行列编辑

注意不要修改RAC非存储磁盘的权限。

 _因为_ _rhel 6_ _、_ _rhel7_ _多路径和_ _5_ _不一样，_ _/dev/mapper_ _下不再是块设备磁盘，而是软连接。_

 _dm-X_ _多路径绑定出来后，不同节点生成的_ _dm-X_ _对应的存储磁盘有可能不一致。_

 _因此参考_ _mos_ _文章：_

 **参考文章：How to set udev rule for setting the disk permission on ASM disks when
using multipath on OL 6.x (文档 ID1521757.1)**

 **使用udev修改磁盘权限和属主**

vi /etc/udev/rules.d/12-dm-permissions-highgo.rules

添加如下内容，根据实际情况进行调整：

ENV{DM_NAME}=="ocr1", OWNER:="grid", GROUP:="asmadmin", MODE:="660",
SYMLINK+="mapper/$env{DM_NAME}"

ENV{DM_NAME}=="ocr2", OWNER:="grid", GROUP:="asmadmin", MODE:="660",
SYMLINK+="mapper/$env{DM_NAME}"

ENV{DM_NAME}=="ocr3", OWNER:="grid", GROUP:="asmadmin", MODE:="660",
SYMLINK+="mapper/$env{DM_NAME}"

ENV{DM_NAME}=="ocr4", OWNER:="grid", GROUP:="asmadmin", MODE:="660",
SYMLINK+="mapper/$env{DM_NAME}"

ENV{DM_NAME}=="ocr5", OWNER:="grid", GROUP:="asmadmin", MODE:="660",
SYMLINK+="mapper/$env{DM_NAME}"

ENV{DM_NAME}=="data", OWNER:="grid", GROUP:="asmadmin", MODE:="660",
SYMLINK+="mapper/$env{DM_NAME}"

ENV{DM_NAME}=="fra", OWNER:="grid", GROUP:="asmadmin", MODE:="660",
SYMLINK+="mapper/$env{DM_NAME}"

执行以下命令是配置生效 ，rhel7 没有star_udev命令

# /sbin/udevadm control --reload-rules

# /sbin/udevadm trigger --type=devices --action=change

 **参考文章：How to set udev rules in OL7 related to ASM on multipath disks (文档 ID
2101679.1)**

但经过试验，该重新加载的命令并不一定能够保证重新加载udev策略。

可以使用systemctl restart systemd-udev-trigger.service重启service可以重新加载策略。

 **如果是现有生产环境添加磁盘等操作，不建议使用start_udev或者systemctl restartsystemd-udev-
trigger.service来在线添加新磁盘，建议手动在线修改，并安排停机时间重启确认。**

ls –l /dev/dm-* 检查磁盘属主和权限是否正确。

### 11.2使用存储专用多路径软件的情况：

此种情况下磁盘的名称，以及磁盘唯一性的确认都是存储工程来保障的。

如emc的存储多路径聚合软件聚合后的盘一般是/dev/emcpowera 、/dev/emcpowerb等

只需要 存储工程师提供给我们盘名，我们进行ASM层面的操作即可。

华为多路径聚合磁盘后磁盘名称依然是/dev/sdb 、/dev/sdc 等， kernel == "sdb"即可。

vi /etc/udev/rules.d/99-asm-highgo.rules

ACTION=="add", KERNEL=="emcpowera", RUN+="/bin/raw /dev/raw/raw1 %N"

ACTION=="add", KERNEL=="emcpowerb", RUN+="/bin/raw /dev/raw/raw2 %N"

ACTION=="add", KERNEL=="emcpowerc", RUN+="/bin/raw /dev/raw/raw3 %N"

ACTION=="add", KERNEL=="emcpowerd", RUN+="/bin/raw /dev/raw/raw4 %N"

ACTION=="add", KERNEL=="emcpowere", RUN+="/bin/raw /dev/raw/raw5 %N"

ACTION=="add", KERNEL=="emcpowerf", RUN+="/bin/raw /dev/raw/raw6 %N"

KERNEL=="raw1",OWNER="grid",GROUP="asmadmin", MODE="660"

KERNEL=="raw2",OWNER="grid",GROUP="asmadmin", MODE="660"

KERNEL=="raw3",OWNER="grid",GROUP="asmadmin", MODE="660"

KERNEL=="raw4",OWNER="grid",GROUP="asmadmin", MODE="660"

KERNEL=="raw5",OWNER="grid",GROUP="asmadmin", MODE="660"

KERNEL=="raw6",OWNER="grid",GROUP="asmadmin", MODE="660"

重启udev守护进程

执行以下命令是配置生效 ，rhel7 没有star_udev命令

# /sbin/udevadm control --reload-rules

# /sbin/udevadm trigger --type=devices --action=change

 **参考文章：How to set udev rules in OL7 related to ASM on multipath disks (文档 ID
2101679.1)**

但经过试验，该重新加载的命令并不一定能够保证重新加载udev策略。

可以使用systemctl restart systemd-udev-trigger.service重启service可以重新加载策略。

检查是否生成ls -l /dev/raw/raw*磁盘,以及磁盘权限是否是grid:asmadmin

### 11.3、 创建用于ASM访问的磁盘软链接

无论磁盘如何采用何种形式管理，一定要创建软连接，放到/u10/asm-disk中

mkdir /u01/asm-disk/

举例如：

ln -s /dev/mapper/ocr1 /u01/asm-disk/ocr1

ln -s /dev/mapper/ocr2 /u01/asm-disk/ocr2

ln -s /dev/mapper/ocr3 /u01/asm-disk/ocr3

ln -s /dev/mapper/ocr4 /u01/asm-disk/ocr4

ln -s /dev/mapper/ocr5 /u01/asm-disk/ocr5

ln -s /dev/mapper/data /u01/asm-disk/data

ln -s /dev/mapper/fra /u01/asm-disk/fra

## 12 验证安装介质md5值

安装介质如非官方途径下载，需要验证md5值，避免使用网络上被篡改过的恶意介质

 **linux** **：**

 **md5sum p13390677_112040_Linux-x86-64_1of7.zip**

 **得出的值和如下官方提供的** **md5** **值进行对比，如果** **md5** **值不同，则表示文件有可能被篡改过** **，**
**不可以使用。**

 **文件的名字发生变化并不影响** **md5** **值的校验结果。**

详见《Oracle各版本安装包md5校验手册v2.docx》

## 13、安装 Oracle Grid Infrastructure

vnc连接服务器

root登录

查询vnc占用的端口号

在vnc端执行：netstat -lp |grep -i vnc

解压群集安装程序

#gunzip p13390677_112040_Linux-x86-64_3of7.zip -d /tmp/

#cd /tmp/grid/

#xhost+

#export DISPLAY=:x.0---x是执行netstat -lp |grep -i vnc查出来的结果

#su – grid

$export DISPLAY=:x.0---x是执行netstat -lp |grep -i vnc查出来的结果

$cd /tmp/grid

 **对于** **vnc** **如果以上连接方式较麻烦，可以直接使用** **grid** **或者** **oracle**
**用户登录图形界面，图形界面里打开命令窗口开始安装之前一定要先检查环境变量是否加载成功：** **env|grep ORA**

 **如果没有** **ORACLE_SID** **、** **ORACLE_HOME** **、** **ORACLE_BASE**
**等环境变量，可以在当前命令窗口加载环境变量配置文件** **source ~/.bash_profile**
**，然后再检查变量是否存在，存在变量方可执行** **runInstaller** **进行安装。**

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

os
password是grid用户的密码，先点击setup按钮来建立主机之间的ssh互信，作用就是服务器之间ssh登录时可以不需要输入对方操作系统账户的密码。

根据定义的网卡选择网络类型 public 还是 心跳private

![]()

此处要求存储工程师划分5个3G的LUN 用来做CRS磁盘组

此处冗余模式 Redundancy要选择High

下方勾选5个3G的磁盘。

 **注意此处添加的磁盘是存储磁盘软链接存放的目录** **/dev/asm-disk/**

**ASM** **必须达到一定的密码标准。密码中要包含字母大写、小写、数字，至少** **8** **个字符。**

如果只有以上两个条件不满足，勾选右上角的ignore all，如果存在其他条件不满足则要进行相应处理。

![]()

![]()

**运行** **root.sh** **脚本之前，** **rhel7** **上没有** **ohas.** **service**
**文件，需要手动创建。**

 **参考文章：** **Install of Clusterware fails while running root.sh on OL7 - ohasd
fails to start (** **文档** **ID1959008.1)**

vi /usr/lib/systemd/system/ohas.service ，各个RAC节点均要创建ohas.service文件。

输入如下内容：

[Unit]

Description=Oracle High Availability Services

After=syslog.target

[Service]

ExecStart=/etc/init.d/init.ohasd run >/dev/null 2>&1 Type=simple

Restart=always

[Install]

WantedBy=multi-user.target

开机启动ohas服务

systemctl daemon-reload

systemctl enable ohas.service

运行root.sh,启动ohas faild。

如果出现上述ohasd failed to start的错误时，手动执行

/bin/systemctl start ohas.service

然后稍等片刻脚本会继续执行。

若集群root.sh脚本运行不成功,需要回退到root.sh脚本：

#删除crs配置信息

#/u01/app/11.2.0/grid/crs/install/rootcrs.pl -verbose -deconfig -force

 **运行** **deconfig** **时如果提示：**

 **调用** **GI HOME** **下的** **perl** **命令就可以了，参考** **MOS** **：**

 **rootcrs.pl/roothas.pl Fails With Can't locate Env.pm (** **文档** **ID
2019784.1)**

![]()

**出现这两个错误可以忽略不计，直接下一步退出。** **也可以用下面的方法避免错误出现。**

 _如果您只在 hosts 文件中定义 SCAN 但却想让 CVU 成功完成，只需在两个 Oracle RAC 节点上以 root 身份对 nslookup
实用程序进行如下修改。_

 _首先，在两个 Oracle RAC 节点上将原先的 nslookup 二进制文件重命名为 nslookup.original：_

 _[root@racnode1 ~]# **mv /usr/bin/nslookup /usr/bin/nslookup.original**_

 _然后，新建一个名为 /usr/bin/nslookup 的 shell 脚本，在该脚本中用 202.102.128.68 替换主 DNS，用 rac-
scan 替换 SCAN 主机名，用 192.168.0.127 替换 SCAN IP 地址，如下所示：_

 _#!/bin/bash_

 _HOSTNAME=${1}_

 _if [[ $HOSTNAME = "rac-scan" ]]; then_

 _echo "Server: 202.102.128.68"_

 _echo "Address: 202.102.128.68#53"_

 _echo "Non-authoritative answer:"_

 _echo "Name: rac-scan"_

 _echo "Address: 192.168.0.127"_

 _else_

 _/usr/bin/nslookup.original $HOSTNAME_

 _fi_  
  
---  
  
 _最后，将新建的 nslookup shell 脚本更改为可执行脚本：_

 _[root@racnode1 ~]# **chmod 755 /usr/bin/nslookup**_

 _记住要在两个 Oracle RAC 节点上执行这些操作。_

 _每当 CVU 使用您的 SCAN 主机名调用 nslookup 脚本时，这个新的 nslookup shell 脚本只是回显您的 SCAN IP
地址，其他情况下则会调用原先的 nslookup 二进制文件。_

 _在 Oracle Grid Infrastructure 的安装过程中，当 CVU 尝试验证您的 SCAN 时，它就会成功通过：_

 _[grid@racnode1 ~]$ **cluvfy comp scan -verbose**_

 _Verifying scan_

 _Checking Single Client Access Name (SCAN)..._

 _SCAN VIP name Node Running? ListenerName Port Running?_

 _\---------------- ------------ ------------ ------------ ------------
------------_

 _racnode-cluster-scan racnode1 true LISTENER 1521 true_

 _Checking name resolution setup for "racnode-cluster-scan"..._

 _SCAN Name IP Address Status Comment_

 _\------------ ------------------------ ------------------------ ----------_

 _racnode-cluster-scan 192.168.1.187 **passed**_

 _Verification of SCAN VIP and Listener setup passed_

 _Verification of scan was successful._

_===============================================================================_

 _[grid@racnode2 ~]$ **cluvfy comp scan -verbose**_

 _Verifying scan_

 _Checking Single Client Access Name (SCAN)..._

 _SCAN VIP name Node Running? ListenerName Port Running?_

 _\---------------- ------------ ------------ ------------ ------------
------------_

 _racnode-cluster-scan racnode1 true LISTENER 1521 true_

 _Checking name resolution setup for "racnode-cluster-scan"..._

 _SCAN Name IP Address Status Comment_

 _\------------ ------------------------ ------------------------ ----------_

 _racnode-cluster-scan 192.168.1.187 **passed**_

 _Verification of SCAN VIP and Listener setup passed_

 _Verification of scan was successful._  
  
---  
  
## 14、集群安装后的任务

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

(2)为数据和快速恢复区创建 ASM 磁盘组

asmca

![]()

在 Disk Groups 选项卡中，单击 **Create** 按钮，在出现的画面中创建data卷：

除了CRS磁盘组以外其余存放数据和归档的磁盘组默认都是选择Extenal外部冗余模式，除非客户特殊要求。

![]()

![]()

![]()

![]()

对于磁盘组的规划，一般一套rac 含有一个CRS磁盘组，一个FRA磁盘组用于存放归档日志，一个或者多个DATA磁盘组用于存放数据。

单击Exit退出ASM配置向导。

 **至此重启下服务器确认** **crs** **各个资源状态均正常。**

## 15、安装oracle 11g r2 database

vnc图形化登录服务器

root用户登录

查询vnc占用的端口号

在vnc端执行：netstat -lp |grep -i vnc

依次解压如下两个安装包

unzip p13390677_112040_Linux-x86-64_1of7.zip -d /tmp/

unzip p13390677_112040_Linux-x86-64_2of7.zip -d /tmp/

#xhost+

#export DISPLAY=:x.0---x是执行netstat -lp |grep -i vnc查出来的结果

#su – oracle

$export DISPLAY=:x.0---x是执行netstat -lp |grep -i vnc查出来的结果

$cd /tmp/database

$./runInstaller

![]()

选择 **Real Application Clusters database installation** 单选按钮（此为默认选择），确保选中 Node
Name 窗口中的两个 Oracle RAC 节点。

接下来，单击 [SSH Connectivity] 按钮。输入 oracle 用户的 OS Password，然后单击 [Setup] 按钮。这会启动
SSH Connectivity 配置过程：

![]()

![]()

![]()

![]()

![]()

![]()

![]()

![]()

**若出现此报错则点继续，安装完成后打补丁** **19692824**

.

因为该补丁的readme中提到

 **1\. For non-recommended patches, you must have the exact symptoms**

 **described in the service request (SR).**

如果不使用EM管理，建议不打该补丁。

 **参考文章：** **Installation walk-through - Oracle Grid/RAC 11.2.0.4 on Oracle
Linux 7 (** **文档** **ID 1951613.1)**

![]()

待安装完成后在各个节点执行root.sh脚本，完成后退出向导。

## 16、创建数据库

创建数据库建议

数据文件，归档日志分开存放在不同的，文件系统路径或ASM路径中

控制文件和在线日志多路复用时，放在不同的，磁盘驱动器或ASM磁盘组中

数据库位于文件系统时，将数据文件和在线日志放在不同的磁盘驱动器中

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

![]()

![]()

![]()

![]()

![]()

![]()

点击"Multiplex Redo Logs and Control Files" 输入多个磁盘组来产生冗余控制文件和redo文件。

如果存在+FRA则填写 +DATA和+FRA

如果不存在+FRA，只有+DATA ，则添加两个+DATA

原则就是要多个控制文件和redo文件，而且尽量要存放在不同的磁盘组中。

![]()

![]()

![]()

数据库安装成功并正常启动需要将sga设置大于1072m

保守的设置原则是 ：

SGA_TARGET+pga_aggregate_target=物理内存*0.6

SGA_TARGET : pga_aggregate_target 比例是4:1

SGA_TARGET 等于 SGA_MAX_SIZE

根据实际物理内存进行调整。

![]()

![]()

字符集的必须和开发人员进行确认，不能猜测使用，数据库建立完成后字符集不能进行修改。

![]()

![]()

这里得注意新加的两组日志一个是线程Thread# 1，一个是线程Thread# 2

![]()

![]()

![]()

![]()

## 17、收尾工作

修改数据库默认参数：

alter system set deferred_segment_creation=FALSE;

alter system set audit_trail =none scope=spfile;

alter system set SGA_MAX_SIZE =xxxxxM scope=spfile;

alter system set SGA_TARGET =xxxxxM scope=spfile;

alter system set pga_aggregate_target =XXXXXM scope=spfile;

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

 **Redhat7** **内核系统中** 关闭透明大页内存：

参考《RHEL7 禁用透明大页内存.docx》

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

在 11g 环境中，如果多个数据库共享同一个 ASM 实例，可能需要修改 ASM processes 参数。根据经验法则，ASM 的最佳进程数为 150
个，可用于确定合适值的公式为：

ASM processes = 50 x (<max # instances on db node> \+ <1 for first 10>) + 10 x
(<subsequent instances after 10>)

设置成150即可。

su - grid

sqlplus / as sysdba

SQL> alter system set processes=150 scope=spfile;

参考：

RAC 和 Oracle Clusterware 最佳实践和初学者指南（平台无关部分） (Doc ID 1526083.1)

RAC 和 Oracle Clusterware 最佳实践和初学者指南 (Linux) (Doc ID 1525820.1)

安装PSU，根据PSU相关介绍进行安装。

参考相关PSU文档

部署OSW

默认30秒收集1次，总共保留2天的记录

设置开机自动启动osw监控

linux:

vi /etc/rc.local

cd /tmp/oswbb&&/tmp/oswbb/startOSWbb.sh

通过测试osw的日志默认策略 30秒*2天大约需500M的磁盘空间，合理安排存放目录。

注意：osw默认不监控rac的心跳网络

rac环境 部署osw 需要将其中的Exampleprivate.net文件改名private.net并修改其中内容

删除非当前操作系统的 部分，只保留当前系统的，如操作系统是linux ，只需要保存

#Linux Example

########################################################

echo "zzz ***"`date`

traceroute -r -F <node1-priv>

traceroute -r -F <node2-priv>

########################################################

其中<node1-priv> 和<node2-priv> 修改成 rac心跳ip的名称 如 rac1-priv 和rac2-priv

另外最后一行 rm locks/lock.file 必须保留

# DO NOT DELETE THE FOLLOWING LINE!!!!!!!!!!!!!!!!!!!!!

########################################################

rm locks/lock.file

osw生成的日志会保留在 oswbb下的 archive 目录中。

如果内存大约等于64G开启大页内存，参考 大页内存指导书

## 18、部署rman备份脚本

参考rman 备份相关文档

 **至此结束** **RAC** **部署，重启** **RAC** **所有服务器，启动后检查相关服务及内容是否正常，方可结束安装。**

## 19、安装群集和数据库失败如何快速重来，需要清理重来？

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
[06bf72aee6695891a4b33264a6428fdb]: media/20180123151039_863.png
[20180123151039_863.png](media/20180123151039_863.png)
>hash: 06bf72aee6695891a4b33264a6428fdb  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180123151039_863.png  
>file-name: 20180123151039_863.png  

[28891a335465eec5d8f39090dc14e36e]: media/20180123151823_927.png
[20180123151823_927.png](media/20180123151823_927.png)
>hash: 28891a335465eec5d8f39090dc14e36e  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180123151823_927.png  
>file-name: 20180123151823_927.png  

[3c53d6a4a43d1de9eb5e25221a4e642f]: media/20180123151408_367.png
[20180123151408_367.png](media/20180123151408_367.png)
>hash: 3c53d6a4a43d1de9eb5e25221a4e642f  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180123151408_367.png  
>file-name: 20180123151408_367.png  

[3c55b4b6438d0f039e7801a917aa5dc9]: media/20180123151310_30.png
[20180123151310_30.png](media/20180123151310_30.png)
>hash: 3c55b4b6438d0f039e7801a917aa5dc9  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180123151310_30.png  
>file-name: 20180123151310_30.png  

[580e2bcd3b4f0e45b659a140f382b93a]: media/20180123151813_74.png
[20180123151813_74.png](media/20180123151813_74.png)
>hash: 580e2bcd3b4f0e45b659a140f382b93a  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180123151813_74.png  
>file-name: 20180123151813_74.png  

[5c8574a6ceb99de546f4370e27b15ed2]: media/20180123151524_811.png
[20180123151524_811.png](media/20180123151524_811.png)
>hash: 5c8574a6ceb99de546f4370e27b15ed2  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180123151524_811.png  
>file-name: 20180123151524_811.png  

[7a831c2f7640cf44168362a762af5cf3]: media/20180123151805_694.png
[20180123151805_694.png](media/20180123151805_694.png)
>hash: 7a831c2f7640cf44168362a762af5cf3  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180123151805_694.png  
>file-name: 20180123151805_694.png  

[95c3522fbd618a818c467e9cd10de56e]: media/20180123151921_118.png
[20180123151921_118.png](media/20180123151921_118.png)
>hash: 95c3522fbd618a818c467e9cd10de56e  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180123151921_118.png  
>file-name: 20180123151921_118.png  

[9b24e34bab9b46d80af8bbad357738b2]: media/20180123151345_326.png
[20180123151345_326.png](media/20180123151345_326.png)
>hash: 9b24e34bab9b46d80af8bbad357738b2  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180123151345_326.png  
>file-name: 20180123151345_326.png  

[b1dd40ca6756ab53dc5bffbf348baa6f]: media/20180123151334_303.png
[20180123151334_303.png](media/20180123151334_303.png)
>hash: b1dd40ca6756ab53dc5bffbf348baa6f  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180123151334_303.png  
>file-name: 20180123151334_303.png  

[b2cc7d73d983213a4864b317ee10ee85]: media/20180123151128_358.png
[20180123151128_358.png](media/20180123151128_358.png)
>hash: b2cc7d73d983213a4864b317ee10ee85  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180123151128_358.png  
>file-name: 20180123151128_358.png  

[b391f63198892626fe407c03043fb5f5]: media/20180123151420_913.png
[20180123151420_913.png](media/20180123151420_913.png)
>hash: b391f63198892626fe407c03043fb5f5  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180123151420_913.png  
>file-name: 20180123151420_913.png  

[b4cf665f75d07ba54ea5cce6fda4aafd]: media/20180123151702_804.png
[20180123151702_804.png](media/20180123151702_804.png)
>hash: b4cf665f75d07ba54ea5cce6fda4aafd  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180123151702_804.png  
>file-name: 20180123151702_804.png  

[b92d0e0eeb3a6ddd6f49267dc01ba881]: media/20180123151254_463.png
[20180123151254_463.png](media/20180123151254_463.png)
>hash: b92d0e0eeb3a6ddd6f49267dc01ba881  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180123151254_463.png  
>file-name: 20180123151254_463.png  

[c26dd33029c3ad9b8b9e82d95bc029f2]: media/20180123151639_499.png
[20180123151639_499.png](media/20180123151639_499.png)
>hash: c26dd33029c3ad9b8b9e82d95bc029f2  
>source-url: https://support.highgo.com/highgo_api/  
>source-url: images/uedit/20180123151639_499.png  
>file-name: 20180123151639_499.png  

[c32b634a1f2ccefa37ab80ca2f7afd61]: media/20180123151544_722.png
[20180123151544_722.png](media/20180123151544_722.png)
>hash: c32b634a1f2ccefa37ab80ca2f7afd61  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180123151544_722.png  
>file-name: 20180123151544_722.png  

[d67440b5918f8568c4729092945ac019]: media/20180123151531_948.png
[20180123151531_948.png](media/20180123151531_948.png)
>hash: d67440b5918f8568c4729092945ac019  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180123151531_948.png  
>file-name: 20180123151531_948.png  

[de86f21c27fc86d5f2a31bd467a3255d]: media/20180123151758_746.png
[20180123151758_746.png](media/20180123151758_746.png)
>hash: de86f21c27fc86d5f2a31bd467a3255d  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180123151758_746.png  
>file-name: 20180123151758_746.png  

[df3e567d6f16d040326c7a0ea29a4f41]: media/spacer-3.gif
[spacer-3.gif](media/spacer-3.gif)
>hash: df3e567d6f16d040326c7a0ea29a4f41  
>source-url: http://47.100.29.40/highgo_admin/ueditor/themes/default/images/spacer.gif  
>file-name: spacer.gif  

[e44a7029b80405829625776f3754974e]: media/20180123151354_498.png
[20180123151354_498.png](media/20180123151354_498.png)
>hash: e44a7029b80405829625776f3754974e  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180123151354_498.png  
>file-name: 20180123151354_498.png  

[ea149d44ca13a07b25ba80c4be91862c]: media/20180123151725_325.png
[20180123151725_325.png](media/20180123151725_325.png)
>hash: ea149d44ca13a07b25ba80c4be91862c  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180123151725_325.png  
>file-name: 20180123151725_325.png  

[f37eb077461cd9442d458a0af18a941e]: media/20180123151227_857.jpg
[20180123151227_857.jpg](media/20180123151227_857.jpg)
>hash: f37eb077461cd9442d458a0af18a941e  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180123151227_857.jpg  
>file-name: 20180123151227_857.jpg  

[fa7a0eb4737c821e8483932c71672635]: media/20180123151830_84.png
[20180123151830_84.png](media/20180123151830_84.png)
>hash: fa7a0eb4737c821e8483932c71672635  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180123151830_84.png  
>file-name: 20180123151830_84.png  

[fef23ec78a708f1281748f4807c911e1]: media/20180123151627_934.png
[20180123151627_934.png](media/20180123151627_934.png)
>hash: fef23ec78a708f1281748f4807c911e1  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180123151627_934.png  
>file-name: 20180123151627_934.png  


---
### TAGS
{Support20180830}

---
### NOTE ATTRIBUTES
>Created Date: 2018-08-30 02:00:57  
>Last Evernote Update Date: 2018-10-01 15:33:57  
>source: web.clip7  
>source-url: https://47.100.29.40/highgo_admin/#/index/docSearchDetail/0e80f50367eff1  
>source-application: WebClipper 7  