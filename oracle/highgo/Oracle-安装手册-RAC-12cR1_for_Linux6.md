# Oracle-安装手册-RAC-12cR1_for_Linux6

# 瀚高技术支持管理平台

## 新特性

## 1、验证系统要求

要验证系统是否满足 Oracle 12 _c_ 数据库的最低要求，以 root 用户身份登录并运行以下命令。

要查看可用 RAM 和交换空间大小，运行以下命令：

grep MemTotal /proc/meminfo

grep SwapTotal /proc/meminfo

例如：

# grep MemTotal /proc/meminfo

MemTotal:512236 kB

# grep SwapTotal /proc/meminfo

SwapTotal:1574360 kB

At least 4 GB of RAM for Oracle Grid Infrastructure for cluster installations,
including  
installations where you plan to install Oracle RAC

For systems with 4 GB to 16 GB RAM, use swap space equal to RAM. For systems
with more than 16 GB RAM, use 16 GB of RAM for swap space.

## 2、初始化系统服务：

关闭防火墙

chkconfig iptables off

关闭selinux:

vi /etc/selinux/config

SELINUX=disabled

#avahi-daemon 1501093.1

chkconfig avahi-daemon off

#6.x版本上关闭 NetworkManager 服务

chkconfig NetworkManager off

## 3、网络配置

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

baseurl=file:///mnt/Server/

enabled=1

gpgcheck=0

执行如下名命令允许yum默认同时安装32和64位的rpm包

echo 'multilib_policy=all' >> /etc/yum.conf

可以执行如下命令安装所有需要的rpm

yum install compat-libcap1 tiger* binutils compat-libstdc* elfutils-libelf
elfutils-libelf-devel gcc gcc-c++ glibc glibc-common glibc-devel glibc-headers
ksh libaio libaio libaio-devel libaio-devel libgcc libstdc++ libstdc++-devel
make sysstat unixODBC unixODBC unixODBC-devel unixODBC-devel iscsi lsscsi* -y

## 5、内核参数

 **/etc/sysctl.conf** **这里面的修改可以通过安装过程中运行**`runfixup.sh` **脚本自动修改。**

 **在安装过程中，系统会提示。**

Oracle Database 12 _c_ 第 1
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
net.core.rmem_default = 262144  
net.core.rmem_max = 4194304  
net.core.wmem_default = 262144  
net.core.wmem_max = 1048576

fs.aio-max-nr = 1048576

kernel.panic_on_oops = 1

注意：在linux内核为2.6.31及以上版本中针对HAIP环境（多个内联心跳地址）添加以下参数

net.ipv4.conf.私有网卡1.rp_filter=2

net.ipv4.conf.私有网卡2.rp_filter=2

将'私有网卡n'替换成实际网卡名称。

参考mos文章

RAC and Oracle Clusterware Best Practices and Starter Kit (Linux) (Doc ID
811306.1)

运行如下命令是参数立即生效。

[root@racnode1 ~]# sysctl -p

## 6、设置oracle的shell限制：

在/etc/security/limits.conf文件中加入

grid soft nproc 2047

grid hard nproc 16384

grid soft nofile 1024

grid hard nofile 65536

grid hard stack 10240

oracle soft nproc 2047

oracle hard nproc 16384

oracle soft nofile 1024

oracle hard nofile 65536

oracle hard stack 10240

修改使以上参数生效：

vi /etc/pam.d/login

添加如下行

session required pam_limits.so

rhel6 或更高版本 则要注意

nproc参数的生效并不是在/etc/security/limits.conf里生效，是需要在

/etc/security/limits.d/90-nproc.conf 文件中设置

参考：

|

 **Setting nproc values on Oracle Linux 6 for RHCK kernel (** **文档**
**ID2108775.1)**  
  
---|---  
  
[root@localhost limits.d]# cat 90-nproc.conf

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

[root@rhel ~]#date -s "20100405 14:31:00"

关闭NTP服务

Network Time Protocol Setting

# /sbin/service ntpd stop

# chkconfig ntpd off

#mv /etc/ntp.conf /etc/ntp.conf.org

#service ntpd status

一定要保证时间同步，但是不能配置ntp，否则会导致12c的ctssd处于旁观模式。如果客户严格要求和北京时间一致，则考虑让客户提供时间服务器，然后再采用NTP和其时间服务器同步。如果配置NTP注意参数
-x 保证时间不能向回调，关于NTP配置此处不做详细解释。

## 8、修改主机名

每个主机均要修改：

vi /etc/sysconfig/network

将其中HOSTNAME改为主机名，如下：

HOSTNAME=rac1

注意主机名不能过长,不能超过8个字符，且不能有下划线等特殊符号，不要使用大写字母，建议使用小写字母即可。

修改完主机名务必重启生效

添加NOZEROCONF=yes 参考如下

 **CSSD Fails to Join the Cluster After Private Network Recovered if avahi
Daemon is up and Running (** **文档** **ID 1501093.1)**

## 9、添加用户和组、创建目录

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
  
 **数据库操作员**

|

 **oper**

|

 **oracle**

|

 **SYSOPER**

|

 **OSOPER**  
  
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
ASM 12c 第 1 版 (11.1) 中引入的，现在，在 Oracle ASM 12c 第 2 版 (11.2) 中，该权限已从 SYSDBA
权限中完全分离出来。SYSASM 权限不再提供对 RDBMS 实例的访问权限。用 SYSASM 权限代替 SYSDBA 权限来提供存储层的系统权限，这使得
ASM 管理和数据库管理之间有了清晰的责任划分，有助于防止使用相同存储的不同数据库无意间覆盖其他数据库的文件。SYSASM
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

/usr/sbin/groupadd -g 1300 asmdba

/usr/sbin/groupadd -g 1301 asmoper

useradd -u 1100 -g oinstall -G asmadmin,asmdba,asmoper grid

useradd -u 1200 -g oinstall -G dba,asmdba oracle

修改grid、oracle 用户密码

passwd grid

passwd oracle

创建grid目录

# mkdir -p /u01/app/12.1.0/grid

# chown grid:oinstall /u01/ -R

# chmod 775 /u01/ -R

    
    
    创建oracle目录

# mkdir -p /u02/app/oracle/product/12.1.0/db_home

# chown oracle:oinstall /u02/ -R

# chmod 775 /u02/ -R

修改grid用户环境变量

登录rac节点1

su - grid

vi .bash_profile

ORACLE_SID=+ASM1; export ORACLE_SID

ORACLE_BASE=/u01/app/grid; export ORACLE_BASE

ORACLE_HOME=/u01/app/12.1.0/grid; export ORACLE_HOME

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

export ORACLE_HOME=/u02/app/oracle/product/12.1.0/db_home

PATH=$ORACLE_HOME/bin:$PATH:$HOME/bin

umask 022

export PATH

登录RAC节点2

su - grid

vi .bash_profile

ORACLE_SID=+ASM2; export ORACLE_SID

ORACLE_BASE=/u01/app/grid; export ORACLE_BASE

ORACLE_HOME=/u01/app/12.1.0/grid; export ORACLE_HOME

umask 022

PATH=$ORACLE_HOME/bin:$PATH:$HOME/bin

export PATH

 **注意：** **grid** **用户环境变量** **ORACLE_HOME** **不在** **ORACLE_BASE** **目录下**

 **su - oracle**

修改oracle 用户环境变量

export ORACLE_SID=orcl2

export ORACLE_BASE=/u02/app/oracle

export ORACLE_HOME=/u02/app/oracle/product/12.1.0/db_home

PATH=$ORACLE_HOME/bin:$PATH:$HOME/bin

umask 022

export PATH

## 10、ASM配置共享磁盘

 ** _配置_** ** _iscsi_**

 ** _在_** ** _RHEL5_** ** _系统中_** ** _,_** ** _下载并安装_** ** _iSCSI_** **
_启动器软件包_** _  
**# rpm -ivh iscsi-initiator-utils-6.2.0.742-0.5.el5.i386.rpm**  
**2.**_ ** _在_** ** _RHEL5_** ** _系统中_** ** _,_** ** _生成并查看_** ** _iSCSI_** **
_启动器的名称_** _  
**# echo "InitiatorName=`iscsi-iname`" >/etc/iscsi/initiatorname.iscsi**  
**# cat /etc/iscsi/initiatorname.iscsi**  
InitiatorName=iqn.2005-03.com.redhat:01.b9d0dd11016  
**3.**_ ** _在_** ** _RHEL5_** ** _系统中_** ** _,_** ** _配置_** ** _iSCSI_** **
_启动器服务_** _  
**# vi /etc/iscsi/iscsid.conf** (iSCSI_ _启动器服务的配置文件_ _)_ _  
node.session.auth.authmethod = CHAP  
node.session.auth.username = iqn.2005-03.com.redhat:01.b9d0dd11016  
node.session.auth.password = 01.b9d0dd11016  
**# chkconfig iscsi --level 35 on**  
**4.**_ ** _在_** ** _SmartWin_** ** _存储设备中_** ** _,_** ** _创建并分配一个_** **
_iSCSI_** ** _共享_** ** _通过共享管理_** ** _-iSCSI_** ** _共享_** ** _,_** ** _使用_**
** _iSCSI_** ** _共享虚拟磁盘创建一个_** ** _iSCSI_** ** _共享_** ** _;_** ** _根据第_** **
_3_** ** _步得到的_** ** _iSCSI_** ** _启动器的名称_** ** _,_** ** _使用_** ** _CHAP_** **
_认证模式进行分配_** ** _;_** ** _启动器名称_** ** _:_**
_iqn.2005-03.com.redhat:01.b9d0dd11016  
_**_启动器口令_** ** _:_** _01.b9d0dd11016_ _  
**5.**_ ** _在_** ** _RHEL5_** ** _系统中_** ** _,_** ** _启动_** ** _iSCSI_** **
_启动器服务_** _  
**# service iscsi start**  
**# iscsiadm -m discovery -t st -p 192.168.1.2** (_ _发现_ _)_ _  
192.168.1.2:3260,1 iqn.2004-01.com.company:block-wb  
**# iscsiadm -m node -T iqn.2004-01.com.company:block-wb -p 192.168.1.2 -l**_

###  _10.1_ _自动存储管理器_ _(ASM)_

 _从_
_http://www.oracle.com/technetwork/topics/linux/downloads/rhel5-084877.html_
_找到要下载的三个_ _RPM_ _软件包，注意，一定要与内核版本和系统平台相符。_

 _Uname –a_ _查看系统版本_

 ** _对_** ** _ASM_** ** _进行配置_** _：_

 _# /etc/init.d/oracleasm configure_

 _Configuring the Oracle ASM library driver._

 _这将配置_ _Oracle ASM_ _库驱动程序的启动时属性。以下问题将确定在启动时是否加载驱动程序以及它将拥有的权限。当前值将显示在方括号（_
_“[]”_ _）中。按_ _ <ENTER> __而不键入回应将保留该当前值。按_ _Ctrl-C_ _将终止。_

 _Default user to own the driver interface []:_ ** _grid_**

 _Default group to own the driver interface []:_ ** _oinstall_**

 _Start Oracle ASM library driver on boot (y/n) [n]: **y**_

 _Fix permissions of Oracle ASM disks on boot (y/n) [y]: **y**_

 _Writing Oracle ASM library driver configuration done_

 _Creating /dev/oracleasm mount point done_

 _Loading module "oracleasm" done_

 _Mounting ASMlib driver filesystem done_

 _Scanning system for ASM disks done_

 _AMS_ _的命令如下所示：_

oracle@DBRAC1:~> /etc/init.d/oracleasm

Usage: /etc/init.d/oracleasm

{start|stop|restart|enable|disable|configure|createdisk|deletedisk|querydisk|listdisks|scandisks|status}  
  
---  
  
 _现在，如下所示启用_ _ASMLib_ _驱动程序。_

 ** _# /etc/init.d/oracleasm enable_**

 _Writing Oracle ASM library driver configuration [ OK ]_

 _Scanning system for ASM disks [ OK ]_

 _ASM_ _的安装和配置是要在集群中的每个节点上执行的_

 _为_ _oracle_ _创建_ _ASM_ _磁盘：_

 _创建_ _ASM_ _磁盘只需在_ _RAC_ _集群中的一个节点上以_ _root_ _用户帐户执行。我将在_ _rac1_
_上运行这些命令。在另一个_ _Oracle RAC_ _节点上，您将需要执行_ _scandisk_ _以识别新卷。该操作完成后，应在两个_
_Oracle RAC_ _节点上运行_ _oracleasm listdisks_ _命令以验证是否创建了所有_ _ASM_ _磁盘以及它们是否可用。_

 _#/etc/init.d/oracleasm createdisk CRS /dev/sdd1_

 _#/etc/init.d/oracleasm createdisk DATA /dev/sdd2_

 _#/etc/init.d/oracleasm createdisk FRA /dev/sdd3_

 _/etc/init.d/oracleasm scandisks_

 _Scanning the system for Oracle ASMLib disks: [ OK ]_

 _# /etc/init.d/oracleasm listdisks_

 _CRS_

 _DATA_

 _FRA_

### 10.2原始设备

主要分如下三种情况：

情况1、使用存储专用多路径软件的情况：

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

start_udev

检查是否生成ls -l /dev/raw/raw*磁盘,以及磁盘权限是否是grid:asmadmin

注意：正在运行生产业务的os,禁止使用start_udev命令，start_udev会重新读取udev规则，暂时性删除网卡，造成节点hang或驱逐。动态添加存储的变通方法是将规则写入udev配置文件，手动执行绑定授权命令，待下次重启，自动读取udev文件配置。

/bin/raw /dev/raw/raw1 /dev/mapper/mpath1

chown oracle:oinstall/dev/raw/raw1

chmod 660 /dev/raw/raw1

Network interface going down when dynamically adding disks to storage using
udev in RHEL 6 (文档 ID 1569028.1)

情况2、使用linux操作系统自带multipath多路径软件的情况：

 **rhel6:**

 **参考文章：**

 **Configuring Multipath Devices on RHEL6/OL6 (** **文档** **ID 1538626.1)**

查询磁盘设备的wwid

for i in `cat /proc/partitions | awk '{print $4}' |grep sd | grep [a-z]$`; do
echo "### $i: `scsi_id -g -u -d /dev/$i`"; done

多路径配置文件内容/etc/multipath.conf，修改wwid和别名alias

# grep -v ^# /etc/multipath.conf

defaults {

udev_dir /dev

polling_interval 5

path_grouping_policy multibus

getuid_callout "/lib/udev/scsi_id --whitelisted --device=/dev/%n"

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

wwid 149455400000000000000000001000000de0200000d000000

alias fra

path_grouping_policy multibus

}

multipath {

wwid 149455400000000000000000001000000e30200000d000000

alias data

path_grouping_policy multibus

}

multipath {

wwid 149455400000000000000000001000000e80200000d000000

alias ocr1

path_grouping_policy multibus

}

multipath {

wwid 149455400000000000000000001000000ed0200000d000000

alias ocr2

path_grouping_policy multibus

}

multipath {

wwid 149455400000000000000000001000000ca0200000d000000

alias ocr3

path_grouping_policy multibus }

multipath {  
wwid 149455400000000000000000001000000ca0200000d000000  
alias ocr4  
path_grouping_policy multibus  
}

multipath {  
wwid 149455400000000000000000001000000ca0200000d000000  
alias ocr5  
path_grouping_policy multibus  
}

}

查看多路径磁盘对应的dm-X 名称

ls -l /dev/mapper/|grep dm*

将共享存储磁盘列表抓取出来，通过notepad++工具进行列编辑

注意不要修改RAC非存储磁盘的权限。

 _因为_ _rhel 6_ _多路径和_ _5_ _不一样，_ _/dev/mapper_ _下不再是块设备磁盘，而是软连接。_

 _dm-X_ _多路径绑定出来后，不同节点生成的_ _dm-X_ _对应的存储磁盘有可能不一致。_

 _因此参考_ _mos_ _文章：_

 **How to set udev rule for setting the disk permission on ASM disks when
using multipath on OL 6.x (** **文档 ID 1521757.1)**

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

root用户执行

start_udev

重新加载udev设备

ls –l /dev/dm-* 检查磁盘属主和权限是否正确。

注意：正在运行生产业务的os,禁止使用start_udev命令，start_udev会重新读取udev规则，暂时性删除网卡，造成节点hang或驱逐。动态添加存储的变通方法是将规则写入udev配置文件，手动执行绑定授权命令，待下次重启，自动读取udev文件配置。

/bin/raw /dev/raw/raw1 /dev/mapper/mpath1

chown oracle:oinstall/dev/raw/raw1

chmod 660 /dev/raw/raw1

Network interface going down when dynamically adding disks to storage using
udev in RHEL 6 (文档 ID 1569028.1)

 **情况** **3** **、如果未使用** **multipath** **或其他多路径软件：**

为避免后期添加删除磁盘等导致盘序变乱，要求使用udev绑定wwid的形式。

禁止使用raw
绑定sdb、sdc等磁盘名的形式。（华为存储多路径ultrapath聚合后的名字依然是/dev/sdb,这种情况直接使用磁盘名，不需要绑定wwid）

以下步骤中，之所以没有按照mos文章中提到的直接对磁盘进行重命名，而是针对wwid调用raw 命令来绑定成raw设备，原因是直接重命名磁盘的话，fdisk
-l就不会显示被重命名的磁盘（可以通过cat /proc/partitions看到被重命名的磁盘，如果磁盘被重命名成/dev/vote，可以通过fdisk
-l /dev/vote来查看磁盘大小等信息。），对于不熟悉环境的人来说fdisk -l 会因为看不到所有存储磁盘而影响判断。

 **rhel 6:**

如果不使用多路径软件，则需要使用udev绑定裸设备的形式

https://www.kernel.org/pub/linux/utils/kernel/hotplug/udev/udev.html

 **How To Replace ASMLib With UDEV (** **文档** **ID 1461321.1)**

 **像文章中指出将磁盘进行重命名，但是会出现** **fdisk -l**
**无法看到被重命名磁盘的情况，这样不便于后期对磁盘的管理。因此采用将磁盘绑定为** **raw** **设备的做法。**

查询磁盘设备的wwid

for i in `cat /proc/partitions | awk '{print $4}' |grep sd | grep [a-z]$`; do
echo "### $i: `scsi_id -g -u -d /dev/$i`"; done

例如：

###sdb: 149455400000000000000000001000000de0200000d000000

###sdc: 149455400000000000000000001000000e30200000d000000

###sdd: 149455400000000000000000001000000e80200000d000000

###sde: 149455400000000000000000001000000ed0200000d000000

###sdf: 149455400000000000000000001000000ca0200000d000000

###sdg: 149455400000000000000000001000000ca0200000d000000

###sdh: 149455400000000000000000001000000ca0200000d000000

举例其中b\c\d\e\f\g\h盘是存储磁盘，要用来创建ASM磁盘组。

vi /etc/udev/rules.d/99-asm-highgo.rules

添加如下内容 拿sdb磁盘举例，

1修改其中的RESULT为上面查出来对对应WWID值：

2修改RUN+="/bin/raw /dev/raw/raw1 %N"中raw磁盘名称raw1

ACTION=="add",BUS=="scsi", KERNEL=="sd*", PROGRAM=="/sbin/scsi_id
--whitelisted --replace-whitespace --device=/dev/$name",
RESULT=="149455400000000000000000001000000de0200000d000000", RUN+="/bin/raw
/dev/raw/raw1 %N"

ACTION=="add",BUS=="scsi", KERNEL=="sd*", PROGRAM=="/sbin/scsi_id
--whitelisted --replace-whitespace --device=/dev/$name",
RESULT=="149455400000000000000000001000000e30200000d000000", RUN+="/bin/raw
/dev/raw/raw2 %N"

ACTION=="add",BUS=="scsi", KERNEL=="sd*", PROGRAM=="/sbin/scsi_id
--whitelisted --replace-whitespace --device=/dev/$name",
RESULT=="149455400000000000000000001000000e80200000d000000", RUN+="/bin/raw
/dev/raw/raw3 %N"

ACTION=="add",BUS=="scsi", KERNEL=="sd*", PROGRAM=="/sbin/scsi_id
--whitelisted --replace-whitespace --device=/dev/$name",
RESULT=="149455400000000000000000001000000ed0200000d000000", RUN+="/bin/raw
/dev/raw/raw4 %N"

ACTION=="add",BUS=="scsi", KERNEL=="sd*", PROGRAM=="/sbin/scsi_id
--whitelisted --replace-whitespace --device=/dev/$name",
RESULT=="149455400000000000000000001000000ca0200000d000000", RUN+="/bin/raw
/dev/raw/raw5 %N"

ACTION=="add",BUS=="scsi", KERNEL=="sd*", PROGRAM=="/sbin/scsi_id
--whitelisted --replace-whitespace --device=/dev/$name",
RESULT=="149455400000000000000000001000000ca0200000d000000", RUN+="/bin/raw
/dev/raw/raw6 %N"

ACTION=="add",BUS=="scsi", KERNEL=="sd*", PROGRAM=="/sbin/scsi_id
--whitelisted --replace-whitespace --device=/dev/$name",
RESULT=="149455400000000000000000001000000ca0200000d000000", RUN+="/bin/raw
/dev/raw/raw7 %N"

使用哪个共享磁盘，则相应添加以上内容。

修改磁盘权限和属主：

KERNEL=="raw1", OWNER="grid", GROUP="asmadmin", MODE="660"

KERNEL=="raw2", OWNER="grid", GROUP="asmadmin", MODE="660"

KERNEL=="raw3", OWNER="grid", GROUP="asmadmin", MODE="660"

KERNEL=="raw4", OWNER="grid", GROUP="asmadmin", MODE="660"

KERNEL=="raw5", OWNER="grid", GROUP="asmadmin", MODE="660"

KERNEL=="raw6", OWNER="grid", GROUP="asmadmin", MODE="660"

KERNEL=="raw7", OWNER="grid", GROUP="asmadmin", MODE="660"

root用户执行

start_udev

重新加载udev设备

ls –l /dev/raw/raw* 查询raw是否成功挂在磁盘，并确认磁盘属主和权限是否正确

注意：正在运行生产业务的os,禁止使用start_udev命令，start_udev会重新读取udev规则，暂时性删除网卡，造成节点hang或驱逐。动态添加存储的变通方法是将规则写入udev配置文件，手动执行绑定授权命令，待下次重启，自动读取udev文件配置。

/bin/raw /dev/raw/raw1 /dev/mapper/mpath1

chown oracle:oinstall/dev/raw/raw1

chmod 660 /dev/raw/raw1

Network interface going down when dynamically adding disks to storage using
udev in RHEL 6 (文档 ID 1569028.1)

 ** _小技巧：如果需要手动解除绑定：raw /dev/raw/raw13 0 0_** ** _＃解除raw13_** ** _绑定_**

 **注意** **：要根据你的实际情况来配置，不建议使用自动shell** **脚本生成以上内容，建议notepad** **++**
**等工具进行列模式编辑。特别是添加磁盘到现有生产环境的情况，脚本不可控，存在安全隐患。**

### 针对如上三种情况都需要创建用于ASM访问的磁盘软链接

mkdir /u01/asm-disk/

举例如：

ln -s /dev/mapper/ocr1 /u01/asm-disk/ocr1

ln -s /dev/mapper/ocr2 /u01/asm-disk/ocr2

ln -s /dev/mapper/ocr3 /u01/asm-disk/ocr3

ln -s /dev/mapper/ocr4 /u01/asm-disk/ocr4

ln -s /dev/mapper/ocr5 /u01/asm-disk/ocr5

ln -s /dev/mapper/data /u01/asm-disk/data

ln -s /dev/mapper/fra /u01/asm-disk/fra

ln -s /dev/raw/raw1 /u01/asm-disk/ocr1

ln -s /dev/raw/raw2 /u01/asm-disk/ocr2

ln -s /dev/raw/raw3 /u01/asm-disk/ocr3

无论哪种形式的裸设备最后都要建立软连接，到/u01/asm-disk目录

根据实际情况进行修改。

 **配置到此后需要重启下服务器，确保所有的存储磁盘均可自动挂在、主机名等信息都是正确的。**

## 11 磁盘io调度程序建议

Linux中磁盘io调度程序有两种算法，CFQ（完全公平队列）和deadline（期限）

CFQ调度程序适用于各种各样的应用程序，在延迟和吞吐量之间又一个很好的平衡

Deadline调度程序针对每个请求都能实现最大延迟并能保持一个很好的吞吐量

如果应用为io密集型，如数据库系统，建议使用deadline调度程序

Red Hat Enterprise Linux 4, 5, 6中默认的算法为CFQ，Red Hat Enterprise Linux
7则使用deadline作为默认算法。

1 查看

$ cat /sys/block/sda/queue/scheduler

noop anticipatory [deadline] cfq

2 修改

在线修改临时生效

Enabling the deadline io scheduler at runtime via the /sys filesystem (RHEL 5,
6, 7)

$ echo 'deadline' > /sys/block/sda/queue/scheduler

写入启动脚本永久生效

Enabling the deadline io scheduler at boot time. Add elevator=deadline to the
end of the kernel line in /etc/grub.conf file (RHEL 4, 5, and 6):

title Red Hat Enterprise Linux Server (2.6.9-67.EL)

root (hd0,0)

kernel /vmlinuz-2.6.9-67.EL ro root=/dev/vg0/lv0 elevator=deadline

initrd /initrd-2.6.9-67.EL.img

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

解压群集安装程序

#gunzip p17694377_121020_Linux-x86-64_3of8.zip -d /tmp/

#gunzip p17694377_121020_Linux-x86-64_4of8.zip -d /tmp/

#cd /tmp/grid/

#xhost+

#su - grid

$cd /tmp/grid

 **说明：** 为了避免ALERT: On Linux, When Installing or Upgrading GI to 12.1.0.2, the
Root Script on Remote Nodes May Fail with "error while loading shared
libraries" Messages (文档 ID 2032832.1)中执行root脚本报错的问题，在执行runInstaller前需执行如下操作：

Before starting runInstaller when installing of or upgrading to 12.1.0.2 Grid
Infrastructure (GI), set SRVM_USE_RACTRANS to true.

 **On ksh or bsh, issue "export SRVM_USE_RACTRANS=true"**

 **On csh, issue "setenv SRVM_USE_RACTRANS true"**

After SRVM_USE_RACTRANS is set to true, execute runInstaller to start the
installation or upgrade.

$./runInstaller

以下截图内值均未参考选项，以实际内容为准。

相比之前的版本， Oracle 12c推出了flex cluster、flex ASM的概念，但是Flex cluster需要配置GNS

参考

http://docs.oracle.com/database/121/CWADD/bigcluster.htm#CWADD92560

http://www.oracle.com/technetwork/cn/articles/database/flexasm-flexcluster-
benefits-odb12c-2177371-zhs.html

注意： SCAN name 必须和hosts文件里的scan name 一致

 **网格命名服务 (GNS)**

从 Oracle Clusterware 11g 第 2 版开始，引入了另一种分配 IP 地址的方法，即 _网格命名服务_ (GNS)。该方法允许使用
DHCP 分配所有专用互连地址以及大多数 VIP 地址。GNS 和 DHCP 是 Oracle 的新的网格即插即用 (GPnP) 特性的关键要素，如
Oracle 所述，该特性使我们无需配置每个节点的数据，也不必具体地添加和删除节点。通过实现对集群网络需求的自我管理，GNS 实现了 _动态_
网格基础架构。与手动定义静态 IP 地址相比，使用 GNS 配置 IP
地址确实有其优势并且更为灵活，但代价是增加了复杂性，该方法所需的一些组件未在这个构建经济型 Oracle RAC 的指南中定义。例如，为了在集群中启用
GNS，需要在公共网络上有一个 DHCP 服务器. 要了解 GNS 的更多优势及其配置方法，请参见 [适用于 Linux 的 Oracle Grid
Infrastructure 11g 第 2 版 (11.2)
安装指南](http://download.oracle.com/docs/cd/E11882_01/install.112/e10812/toc.htm)。

先点击setup按钮来建立主机之间的ssh互信，左右就是服务器之间ssh登录时可以不需要输入对方操作系统账户的密码。

相比于之前的版本，Oracle12c网卡的类型增加了 ASM以及ASM&Private两个类型，这两种类型在使用Flex ASM的方式时选择，关于Flex
ASM 请参考

<http://www.oracle.com/technetwork/cn/articles/database/flexasm-flexcluster-
benefits-odb12c-2177371-zhs.html>

选择 Flex_ASM

注意：如果选择HIGH模式
磁盘的大小必须大于16557MB，如果选择NORMAL模式，那么必须大于11029MB，EXTERNAL模式磁盘大小必须大于5501MB

此处要求存储工程师划分5个20G的LUN 用来做CRS磁盘组

此处冗余模式 Redundancy要选择High

下方勾选5个20G的磁盘。

如果磁盘容量有限，可以要求存储工程师划分3个15G的LUN用作CRS磁盘组。

那此处冗余模式Redundancy要选择Normal

 **注意此处添加的磁盘是存储磁盘软链接存放的目录** **/dev/asm-disk/**

**ASM** **必须达到一定的密码标准。密码中要包含字母大写、小写、数字，至少** **8** **个字符。**

Oracle12c中可以自动执行root脚本。

只有以上三个条件不满足，勾选右上角的ignore all，如果存在其他条件不满足则要进行相应处理。

之前配置了Oracle12c的自动运行root脚本。

如果未做配置，则进行如下手动运行脚本。

若集群root.sh脚本运行不成功：

#删除crs配置信息

#/u01/app/12.1.0/grid/crs/install/rootcrs.pl -verbose -deconfig -force

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

[grid@12crac1 ~]$ crsctl status res -t

\--------------------------------------------------------------------------------

Name Target State Server State details

\--------------------------------------------------------------------------------

Local Resources

\--------------------------------------------------------------------------------

ora.ASMNET1LSNR_ASM.lsnr

ONLINE ONLINE 12crac1 STABLE

ONLINE ONLINE 12crac2 STABLE

ora.LISTENER.lsnr

ONLINE ONLINE 12crac1 STABLE

ONLINE ONLINE 12crac2 STABLE

ora.OCR.dg

ONLINE ONLINE 12crac1 STABLE

ONLINE ONLINE 12crac2 STABLE

ora.net1.network

ONLINE ONLINE 12crac1 STABLE

ONLINE ONLINE 12crac2 STABLE

ora.ons

ONLINE ONLINE 12crac1 STABLE

ONLINE ONLINE 12crac2 STABLE

\--------------------------------------------------------------------------------

Cluster Resources

\--------------------------------------------------------------------------------

ora.12crac1.vip

1 ONLINE ONLINE 12crac1 STABLE

ora.12crac2.vip

1 ONLINE ONLINE 12crac2 STABLE

ora.LISTENER_SCAN1.lsnr

1 ONLINE ONLINE 12crac1 STABLE

ora.MGMTLSNR

1 ONLINE ONLINE 12crac1 169.254.32.5 192.168

.122.172,STABLE

ora.asm

1 ONLINE ONLINE 12crac1 Started,STABLE

2 ONLINE ONLINE 12crac2 Started,STABLE

3 OFFLINE OFFLINE STABLE

ora.cvu

1 ONLINE ONLINE 12crac1 STABLE

ora.mgmtdb

1 ONLINE ONLINE 12crac1 Open,STABLE

ora.oc4j

1 ONLINE ONLINE 12crac1 STABLE

ora.scan1.vip

1 ONLINE ONLINE 12crac1 STABLE

\--------------------------------------------------------------------------------

检查集群节点:

[grid@rac1 ~]$ olsnodes -n

12crac1 1

12crac2 2

检查两个节点上的 Oracle TNS 监听器进程:

[grid@rac1 ~]$ srvctl status listener

Listener LISTENER is enabled

Listener LISTENER is running on node(s): 12crac2,12crac1

(2)为数据和快速恢复区创建 ASM 磁盘组

xhost +

asmca

在 Disk Groups 选项卡中，单击 **Create** 按钮，在出现的画面中创建data卷：

除了CRS磁盘组以外其余存放数据和归档的磁盘组默认都是选择Extenal外部冗余模式，除非客户特殊要求。

对于磁盘组的规划，一般一套rac 含有一个CRS磁盘组，一个FRA磁盘组用于存放归档日志，一个或者多个DATA磁盘组用于存放数据。

单击Exit退出ASM配置向导。

 **至此重启下服务器确认** **crs** **各个资源状态均正常。**

## 15、安装oracle 12c r1 database

vnc图形化登录服务器

root用户登录

依次解压如下两个安装包

unzip p17694377_121020_Linux-x86-64_1of8.zip -d /tmp/

unzip p17694377_121020_Linux-x86-64_2of8.zip -d /tmp/

xhost+

su - oracle

$cd /tmp/database

$./runInstaller

选择 **Real Application Clusters database installation** 单选按钮（此为默认选择），确保选中 Node
Name 窗口中的两个 Oracle RAC 节点。

接下来，单击 [SSH Connectivity] 按钮。输入 oracle 用户的 OS Password，然后单击 [Setup] 按钮。这会启动
SSH Connectivity 配置过程：

待安装完成后在各个节点执行root.sh脚本，完成后退出向导。

## 16、创建、删除数据库

创建数据库建议

数据文件，归档日志分开存放在不同的，文件系统路径或ASM路径中

控制文件和在线日志多路复用时，放在不同的，磁盘驱动器或ASM磁盘组中

数据库位于文件系统时，将数据文件和在线日志放在不同的磁盘驱动器中

### 16.1 创建数据库

使用dbca创建，创建之前确保已安装的所有服务（Oracle TNS 监听器、Oracle Clusterware 进程等）正在运行。

点击"Multiplex Redo Logs and Control Files" 输入多个磁盘组来产生冗余控制文件和redo文件。

如果存在+FRA则填写 +DATA和+FRA

如果不存在+FRA，只有+DATA ，则添加两个+DATA

原则就是要多个控制文件和redo文件，而且尽量要存放在不同的磁盘组中。

数据库安装成功并正常启动需要将sga设置大于1072m

保守的设置原则是 ：

SGA_TARGET+pga_aggregate_target=物理内存*0.6

SGA_TARGET : pga_aggregate_target 比例是4:1

SGA_TARGET 等于 SGA_MAX_SIZE

根据实际物理内存进行调整。

字符集的必须和开发人员进行确认，不能猜测使用，数据库建立完成后字符集不能进行修改。

这里得注意新加的两组日志一个是线程Thread# 1，一个是线程Thread# 2

 **16.2** **删除数据库**

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

## 17、常用命令

###  _17.1_ _、_ _oracle_ _用户管理数据库命令_

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

###  _17.2_ _、启动_ _/_ _停止集群命令_

 _以下停止/_ _启动操作需要以_` _root_` _身份来执行_

 ** _在本地服务器上停止 Oracle Clusterware 系统_**

 _在` rac1` 节点上使用 `crsctl stop cluster` 命令停止 Oracle Clusterware 系统：_

 ** _#/u01/app/12.1.0/grid/bin/crsctl stop cluster_**

 ** _注：_** _在运行“_` _crsctl stop cluster_` _”_ _命令之后，如果 Oracle Clusterware_
_管理的资源中有任何一个还在运行，则整个命令失败。使用_` _-f_` _选项无条件地停止所有资源并停止 Oracle Clusterware_ _系统。_

 ** _在本地服务器上启动 Oracle Clusterware 系统_**

 _在 rac1 节点上使用 crsctl start cluster 命令启动 Oracle Clusterware 系统：_

 _[root@rac1 ~]# **/u01/app/12.1.0/grid/bin/crsctl start cluster**_

 ** _注：_** _可通过指定 -all 选项在集群中所有服务器上启动 Oracle Clusterware 系统。_

 _[root@rac1 ~]# **/u01/app/12.1.0/grid/bin/crsctl start cluster -all**_

 _还可以通过列出服务器（各服务器之间以空格分隔）在集群中一个或多个指定的服务器上启动 Oracle Clusterware 系统：_

 _[root@rac1 ~]# **/u01/app/12.1.0/grid/bin/crsctl start cluster -n rac1
rac2**_

###  _17.3_ _检查集群的运行状况（集群化命令）_

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

 _Oracle home: /u01/app/oracle/product/12.1.0/dbhome_1_

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

 _ASM home: /u01/app/12.1.0/grid_

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

 _/u01/app/12.1.0/grid on node(s) rac2,rac1_

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

 _/u01/app/12.1.0/grid on node(s) rac2,rac1_

 _End points: TCP:1521_

##  _18_ _、卸载软件_

###  _18.1_ _卸载_ _Oracle Grid Infrastructure_

 _Deconfiguring Oracle Clusterware Without Removing Binaries_

 _cd /u01/app/12.1.0/grid/crs/install_

    
    
    1、Run rootcrs.pl with the -deconfig -force flags. For example
    
    
    # perl rootcrs.pl -deconfig –force
    
    
    Repeat on other nodes as required
    
    
    2、If you are deconfiguring Oracle Clusterware on all nodes in the cluster, then on the last node, enter the following command:

 _#_ _perl rootcrs.pl -deconfig -force –lastnode_

 _3_ _、_ _Removing Grid Infrastructure_

 _The default method for running the deinstall tool is from the deinstall
directory in the grid home. For example:_

    
    
    $ cd /u01/app/12.1.0/grid/deinstall
    
    
    $ ./deinstall

###  _18.2_ _卸载_ _Oracle Real Application Clusters Software_

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

## 19、收尾工作

修改数据库默认参数：

alter system set deferred_segment_creation=FALSE;

alter system set audit_trail =none scope=spfile;

alter system set SGA_MAX_SIZE =xxxxxM scope=spfile;

alter system set SGA_TARGET =xxxxxM scope=spfile;

alter systemn set pga_aggregate_target =XXXXXM scope=spfile;

Alter PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;

alter database add SUPPLEMENTAL log data;

alter system set enable_ddl_logging=true;

#关闭12c密码延迟验证新特性

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

alter system set "_report_capture_cycle_time"=0;  
alter system set "_optimizer_ads_use_result_cache" = FALSE;  
alter system SET "_use_single_log_writer"=TRUE SID='*' SCOPE=SPFILE;  
alter system set "_optimizer_aggr_groupby_elim"=false scope=both;  
alter system set "_optimizer_reduce_groupby_key"=false scope=both;  
alter system SET parallel_force_local=false;  
alter system set "_enable_pdb_close_abort"=true;  
alter system set "_enable_pdb_close_noarchivelog"=true;  
alter system set "_drop_stat_segment"=1;  
alter system set "_common_data_view_enabled"=false;  
alter system set "_optimizer_dsdir_usage_control"=0;

alter system set optimizer_adaptive_features=false; -- 12.2.0.1has been made
obsolete

alter system set "_optimizer_adaptive_plans"=false; --- 12.2.0.1has been made
obsolete

alter system set "_optimizer_gather_feedback"=false;  
alter system set "_optimizer_enable_extended_stats"=false;  
alter system set "_datafile_write_errors_crash_instance"=FALSE;

ALTER SYSTEM SET awr_pdb_autoflush_enabled= TRUE SID='*' SCOPE=BOTH;

ALTER SYSTEM SET awr_snapshot_time_offset=1000000 SID='*' SCOPE=BOTH;

 **redhat** **内核系统中** 关闭透明大页内存 ：

vi /etc/rc.local 添加如下内容

if test -f /sys/kernel/mm/redhat_transparent_hugepage/enabled; then

echo never > /sys/kernel/mm/redhat_transparent_hugepage/enabled

fi

if test -f /sys/kernel/mm/redhat_transparent_hugepage/defrag; then

echo never > /sys/kernel/mm/redhat_transparent_hugepage/defrag

fi

修改后重启操作系统验证：

# grep AnonHugePages /proc/meminfo

输出结果为0K，则表是关闭的透明的大页内存。

如若以上方法无法关闭透明的大页内存，则使用方法2或者方法3关闭透明的大页内存：

方法2：

在/etc/grub.conf文件中kernel行末添加transparent_hugepage=never，并重启操作系统

[root@rac1 tune-profiles]# cat /etc/grub.conf

# grub.conf generated by anaconda

#

# Note that you do not have to rerun grub after making changes to this file

# NOTICE: You have a /boot partition. This means that

# all kernel and initrd paths are relative to /boot/, eg.

# root (hd0,0)

# kernel /vmlinuz-version ro root=/dev/sda3

# initrd /initrd-[generic-]version.img

#boot=/dev/sda

default=0

timeout=5

splashimage=(hd0,0)/grub/splash.xpm.gz

hiddenmenu

title Red Hat Enterprise Linux 6 (2.6.32-642.el6.x86_64)

root (hd0,0)

kernel /vmlinuz-2.6.32-642.el6.x86_64 ro
root=UUID=36e1c41b-9a78-4d3d-888e-6558ee9266a4 rd_NO_LUKS rd_NO_LVM.UTF-8
rd_NO_MD SYSFONT=latarcyrheb-sun16 crashkernel=128M KEYBOARDTYPE=pc
KEYTABLE=us rd_NO_DM rhgb quiet transparent_hugepage=never

initrd /initramfs-2.6.32-642.el6.x86_64.img

方法3：参考redhat文档https://access.redhat.com/solutions/422283

如若以上两种方法均无效，则使用如下方法：

首先检查tuned包是否安装：

[root@rac1 ~]# rpm -qa |grep tuned

如若未安装，使用如下方法安装：

[root@rac1 Packages]# yum install tuned

Loaded plugins: product-id, refresh-packagekit, search-disabled-repos,
security, subscription-manager

This system is not registered to Red Hat Subscription Management. You can use
subscription-manager to register.

Setting up Install Process

Server | 4.1 kB 00:00 ...

Resolving Dependencies

\--> Running transaction check

\---> Package tuned.noarch 0:0.2.19-16.el6 will be installed

\--> Finished Dependency Resolution

Dependencies Resolved

========================================================================================================================================================================

Package Arch Version Repository Size

========================================================================================================================================================================

Installing:

tuned noarch 0.2.19-16.el6 Server 95 k

Transaction Summary

========================================================================================================================================================================

Install 1 Package(s)

Total download size: 95 k

Installed size: 219 k

Is this ok [y/N]: y

Downloading Packages:

Running rpm_check_debug

Running Transaction Test

Transaction Test Succeeded

Running Transaction

Warning: RPMDB altered outside of yum.

Installing : tuned-0.2.19-16.el6.noarch 1/1

Verifying : tuned-0.2.19-16.el6.noarch 1/1

Installed:

tuned.noarch 0:0.2.19-16.el6

Complete!

[root@rac1 Packages]# tuned-adm active

Current active profile: default

Service tuned: disabled, stopped

Service ktune: disabled, stopped

[root@rac1 Packages]# cd /etc/tune-profiles/

[root@rac1 tune-profiles]# cp -r throughput-performance throughput-
performance-no-thp

[root@rac1 tune-profiles]# sed -ie 's,set_transparent_hugepages
always,set_transparent_hugepages never,' \

> /etc/tune-profiles/throughput-performance-no-thp/ktune.sh

[root@rac1 tune-profiles]# grep set_transparent_hugepages /etc/tune-
profiles/throughput-performance-no-thp/ktune.sh

set_transparent_hugepages never

[root@rac1 tune-profiles]# tuned-adm profile throughput-performance-no-thp

Switching to profile 'throughput-performance-no-thp'

Applying deadline elevator: dm-0 dm-1 dm-2 dm-3 dm-4 dm-5 dm-6 sda sdb sdc sdd
sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo [ OK ]

Applying ktune sysctl settings:

/etc/ktune.d/tunedadm.conf: [ OK ]

Calling '/etc/ktune.d/tunedadm.sh start': [ OK ]

Applying sysctl settings from /etc/sysctl.conf

Starting tuned: [ OK ]

[root@rac1 tune-profiles]# cat
/sys/kernel/mm/redhat_transparent_hugepage/enabled

always madvise [never]

如上修改后，仍然需要在/etc/grub.conf的kernel行中添加transparent_hugepage=never，如下

[root@rac1 tune-profiles]# cat /etc/grub.conf

# grub.conf generated by anaconda

#

# Note that you do not have to rerun grub after making changes to this file

# NOTICE: You have a /boot partition. This means that

# all kernel and initrd paths are relative to /boot/, eg.

# root (hd0,0)

# kernel /vmlinuz-version ro root=/dev/sda3

# initrd /initrd-[generic-]version.img

#boot=/dev/sda

default=0

timeout=5

splashimage=(hd0,0)/grub/splash.xpm.gz

hiddenmenu

title Red Hat Enterprise Linux 6 (2.6.32-642.el6.x86_64)

root (hd0,0)

kernel /vmlinuz-2.6.32-642.el6.x86_64 ro
root=UUID=36e1c41b-9a78-4d3d-888e-6558ee9266a4 rd_NO_LUKS rd_NO_LVM.UTF-8
rd_NO_MD SYSFONT=latarcyrheb-sun16 crashkernel=128M KEYBOARDTYPE=pc
KEYTABLE=us rd_NO_DM rhgb quiet transparent_hugepage=never

initrd /initramfs-2.6.32-642.el6.x86_64.img

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

如果内存大约等于64G开启大页内存，参考 大页内存指导书

安装PSU，12cPSU和11gPSU安装有所不同

 **1.** **上传** **opatch soft** **和** **最新的** **GI psu** **到所有** **RAC**
**节点的** **/tmp/** **中**

 **2.** **更新** **opatch** **，** **两个节点均替换** **OPATCH** **，** **PSU**
**安装都有最低的** **Opatch** **版本要求。**

Opatch工具下载MOS： **How To Download And Install The Latest OPatch(6880880)
Version (** **文档** **ID 274526.1)**

<https://updates.oracle.com/download/6880880.html>

su - oracle

unzip /tmp/ unzip p6880880_121010_Linux-x86-64.zip -d $ORACLE_HOME

su - grid

unzip /tmp/O unzip p6880880_121010_Linux-x86-64.zip -d $ORACLE_HOME

3.生成ocm response file

su - grid

$ORACLE_HOME/OPatch/ocm/bin/emocmrsp -no_banner -output /u02/config.rsp

**4.** **解压** **gi psu patch**

su - root

#unzip 12.1.0.4.0419_GI_p22191577_112040_Linux-x86-64.zip -d /tmp/gi

5、 **开始打补丁**

打补丁的过程会自动重启 **本节点** 的所有数据库实例和crs 服务，因此打补丁前不必手动关闭数据库实例和群集。

若已经DBCA建库，使用以下命令

/u01/app/12.1.0/grid/OPatch/opatchauto apply /tmp/gi/22646084/ -ocmrf
/u02/config.rsp

执行完如上命令之后不用执行相关sql脚本，具体内容详见readme。

部署OSW

默认30秒收集1次，总共保留2天的记录

设置开机自动启动osw监控

linux:

vi /etc/rc.local

cd /tmp/oswbb&&/tmp/oswbb/startOSWbb.sh 3 168

通过测试osw的日志默认策略
30秒*2天大约需500M的磁盘空间，合理安排存放目录。如果需要自定义天数和扫描间隔,例如想每隔15秒收集一次,共保留7天168小时,添加参数即可.

cd /tmp/oswbb&&/tmp/oswbb/startOSWbb.sh 15 168

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

## 20、部署rman备份脚本

参考rman 备份相关文档

## 21、移走MGMTDB（非必须）

MGMTDB 的数据文件是存放在OCR voting disk的磁盘组里的，为了节省OCR 磁盘组空间，我们也可以把MGMTDB
转移走。而有时候如果不了解12c的这一特性，可能会遇到OCR空间紧张的情况。当然，这里的移动位置，也是从一个共享位置移动到另一个共享位置。

在Oracle 12c 中Management Database 用来存储Cluster HealthMonitor (CHM/OS,ora.crf)
，Oracle Database QoS Management，Rapid Home Provisioning和其他的数据。

Management Repository 是受12c Clusterware 管理的一个单实例，在Cluster
启动的时会启动MGMTDG并在其中一个节点上运行，并受GI 管理，如果运行MGMTDG的节点宕机了，GI 会自动把MGMTDB 转移到其他的节点上。

默认情况，MGMTDB 数据库的数据文件存放在共享的设备，如OCR/Voting 的磁盘组中，但后期可以移动位置。

  * 在12.1.0.1 中，GIMR 是可选的，如果在安装GI的时候，没有选择Management Database 数据库，那么所有依赖的特性，如ClusterHealth Monitor (CHM/OS) 就会被禁用。

  * 在12.1.0.2 中，可以忽略这个问题，因为是强制安装GIMR了。

  * 另外，对于MGMT 数据库，在目前的版本中，也不需要手工对其进行备份。

### 停止并禁用ora.crf 资源

在所有节点使用root用户执行如下命令：

crsctl stop res ora.crf –init

crsctl modify res ora.crf -attr ENABLED=0 -init

### 查看MGMTDB运行的节点

[root@rac1 ~]# srvctl status mgmtdb

Database is enabled

Instance -MGMTDB is running on node rac2

这里显示在节点1上运行，那么在节点1上，用grid用户，执行dbca 命令，删除MGMTDB。

dbca -silent- deleteDatabase -sourceDB -MGMTDB

Connecting to database

4% complete

9% complete

14% complete

19% complete

23% complete

28% complete

47% complete

Updating network configuration files

48% complete

52% complete

Deleting instance and datafiles

76% complete

100% complete

Look at the log file "/u01/app/grid/cfgtoollogs/dbca/_mgmtdb.log" for further
details.

注意：如果是使用DBCA 手工创建的MGMTDB，则可能出现不能删除的情况，具体处理过程可以参考MOS：
1631336.1。（该文档只适用于12.1.0.1不适用于12.1.0.2）

### 重建MGMTDB的CDB

su – grid

$ORACLE_HOME/bin/dbca -silent -createDatabase -sid -MGMTDB
-createAsContainerDatabase true -templateName MGMTSeed_Database.dbc -gdbName
_mgmtdb -storageType ASM -diskGroupName +DATA -datafileJarLocation
$ORACLE_HOME/assistants/dbca/templates -characterset AL32UTF8
-autoGeneratePasswords –skipUserTemplateCheck

Registering database with Oracle Grid Infrastructure

5% complete

Copying database files

7% complete

9% complete

16% complete

23% complete

30% complete

37% complete

41% complete

Creating and starting Oracle instance

43% complete

48% complete

49% complete

50% complete

55% complete

60% complete

61% complete

64% complete

Completing Database Creation

68% complete

79% complete

89% complete

100% complete

Look at the log file "/u01/app/grid/cfgtoollogs/dbca/_mgmtdb/_mgmtdb0.log" for
further details.

###  **使用** **DBCA** **创建** **PDB**

su – grid

$ORACLE_HOME/bin/ dbca -silent -createPluggableDatabase -sourceDB -MGMTDB
-pdbName **raccluster** -createPDBFrom RMANBACKUP -PDBBackUpfile
$ORACLE_HOME/assistants/dbca/templates/mgmtseed_pdb.dfb -PDBMetadataFile
$ORACLE_HOME/assistants/dbca/templates/mgmtseed_pdb.xml -createAsClone true
-internalSkipGIHomeCheck

(需要确认集群的名称)

4% complete

12% complete

21% complete

38% complete

55% complete

85% complete

Completing Pluggable Database Creation

100% complete

Look at the log file
"/u01/app/grid/cfgtoollogs/dbca/_mgmtdb/raccluster/_mgmtdb0.log" for further
details.

###  **验证** **MGMTDB**

[grid@12crac1 bin]$ srvctl status MGMTDB

Database is enabled

Instance -MGMTDB is running on node 12crac1

[grid@12crac1 bin]$ **srvctl config mgmtdb**

Database unique name: _mgmtdb

Database name:

Oracle home: <CRS home>

Oracle user: grid

 **Spfile: +DATA/_MGMTDB/PARAMETERFILE/spfile.292.916913883**

Password file:

Domain:

Start options: open

Stop options: immediate

Database role: PRIMARY

Management policy: AUTOMATIC

Type: Management

PDB name: raccluster

PDB service: raccluster

Cluster name: raccluster

Database instance: -MGMTDB

[grid@12crac1 bin]$ exportORACLE_SID=-MGMTDB

[grid@12crac1 bin]$ export ORACLE_SID=-MGMTDB

[grid@12crac1 bin]$ sqlplus / as sysdba

SQL*Plus: Release 12.1.0.2.0 Production on Mon Jul 11 10:53:17 2016

Copyright (c) 1982, 2014, Oracle. All rights reserved.

Connected to:

Oracle Database 12c Enterprise Edition Release 12.1.0.2.0 - 64bit Production

With the Partitioning, Automatic Storage Management and Advanced Analytics
options

SQL> show parameter name

NAME TYPE VALUE

\------------------------------------ -----------
------------------------------

cell_offloadgroup_name string

db_file_name_convert string

db_name string _mgmtdb

db_unique_name string _mgmtdb

global_names boolean FALSE

instance_name string -MGMTDB

lock_name_space string

log_file_name_convert string

pdb_file_name_convert string

processor_group_name string

service_names string _mgmtdb

SQL> select file_name from dba_data_files union select member file_name from
V$logfile;

FILE_NAME

\--------------------------------------------------------------------------------

+DATA/_MGMTDB/DATAFILE/sysaux.281.916912953

+DATA/_MGMTDB/DATAFILE/system.282.916913003

+DATA/_MGMTDB/DATAFILE/undotbs1.283.916913069

+DATA/_MGMTDB/ONLINELOG/group_1.285.916913339

+DATA/_MGMTDB/ONLINELOG/group_2.286.916913343

+DATA/_MGMTDB/ONLINELOG/group_3.287.916913347

6 rows selected.

 **至此结束** **RAC** **部署，重启** **RAC** **所有服务器，启动后检查相关服务及内容是否正常，方可结束安装。**

## 22、安装群集和数据库失败如何快速重来，需要清理重来？

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
[048f71442aabec7b59bfea291df3d522]: media/20180124145410_824.png
[20180124145410_824.png](media/20180124145410_824.png)
>hash: 048f71442aabec7b59bfea291df3d522  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124145410_824.png  
>file-name: 20180124145410_824.png  

[06ae74bd23c99f4c9682aa6d6626b20c]: media/20180124145622_267.png
[20180124145622_267.png](media/20180124145622_267.png)
>hash: 06ae74bd23c99f4c9682aa6d6626b20c  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124145622_267.png  
>file-name: 20180124145622_267.png  

[0aade6f3cfe79370aae62750313f8650]: media/20180124144410_396.png
[20180124144410_396.png](media/20180124144410_396.png)
>hash: 0aade6f3cfe79370aae62750313f8650  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124144410_396.png  
>file-name: 20180124144410_396.png  

[0b55e24e761662a9b655b04b11e81309]: media/20180124144844_929.png
[20180124144844_929.png](media/20180124144844_929.png)
>hash: 0b55e24e761662a9b655b04b11e81309  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124144844_929.png  
>file-name: 20180124144844_929.png  

[1293bbd833da2dd6387151a41bf04632]: media/20180124145846_656.png
[20180124145846_656.png](media/20180124145846_656.png)
>hash: 1293bbd833da2dd6387151a41bf04632  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124145846_656.png  
>file-name: 20180124145846_656.png  

[191ac495c4df7560081cb023da2fa144]: media/20180124145846_769.png
[20180124145846_769.png](media/20180124145846_769.png)
>hash: 191ac495c4df7560081cb023da2fa144  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124145846_769.png  
>file-name: 20180124145846_769.png  

[2311dbb1ac38900a309834b0d04a358b]: media/20180124150238_715.png
[20180124150238_715.png](media/20180124150238_715.png)
>hash: 2311dbb1ac38900a309834b0d04a358b  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124150238_715.png  
>file-name: 20180124150238_715.png  

[2e50cf87f4b81a65b6c5e6aa878554e6]: media/20180124145410_310.png
[20180124145410_310.png](media/20180124145410_310.png)
>hash: 2e50cf87f4b81a65b6c5e6aa878554e6  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124145410_310.png  
>file-name: 20180124145410_310.png  

[2fc62cad90bb12fc7fca3a851feca1d3]: media/20180124145249_942.png
[20180124145249_942.png](media/20180124145249_942.png)
>hash: 2fc62cad90bb12fc7fca3a851feca1d3  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124145249_942.png  
>file-name: 20180124145249_942.png  

[33a176df9ccead13b44b4278b9265378]: media/20180124144916_197.png
[20180124144916_197.png](media/20180124144916_197.png)
>hash: 33a176df9ccead13b44b4278b9265378  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124144916_197.png  
>file-name: 20180124144916_197.png  

[363ef6c07152b4085a87576e05bf3594]: media/20180124145846_333.png
[20180124145846_333.png](media/20180124145846_333.png)
>hash: 363ef6c07152b4085a87576e05bf3594  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124145846_333.png  
>file-name: 20180124145846_333.png  

[3a62dfe3f9a218e84a1f9366fec418b0]: media/20180124144220_806.png
[20180124144220_806.png](media/20180124144220_806.png)
>hash: 3a62dfe3f9a218e84a1f9366fec418b0  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124144220_806.png  
>file-name: 20180124144220_806.png  

[3be49ae52a8f7d6926212271cc947404]: media/20180124145846_587.png
[20180124145846_587.png](media/20180124145846_587.png)
>hash: 3be49ae52a8f7d6926212271cc947404  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124145846_587.png  
>file-name: 20180124145846_587.png  

[42b43a15bac0e4bc8ed2b142e6237bd5]: media/20180124144537_888.png
[20180124144537_888.png](media/20180124144537_888.png)
>hash: 42b43a15bac0e4bc8ed2b142e6237bd5  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124144537_888.png  
>file-name: 20180124144537_888.png  

[44336c77dfdd100a6b976712b8aa4d4d]: media/20180124145622_588.png
[20180124145622_588.png](media/20180124145622_588.png)
>hash: 44336c77dfdd100a6b976712b8aa4d4d  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124145622_588.png  
>file-name: 20180124145622_588.png  

[451d8c9cd5bd782696df4e0475b5c57a]: media/20180124144353_11.png
[20180124144353_11.png](media/20180124144353_11.png)
>hash: 451d8c9cd5bd782696df4e0475b5c57a  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124144353_11.png  
>file-name: 20180124144353_11.png  

[483b5b0fc10cbd0462e1d52cf98078b1]: media/20180124145102_330.png
[20180124145102_330.png](media/20180124145102_330.png)
>hash: 483b5b0fc10cbd0462e1d52cf98078b1  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124145102_330.png  
>file-name: 20180124145102_330.png  

[49216821ae9a6f7fece7b9d2ad09e710]: media/20180124144624_703.png
[20180124144624_703.png](media/20180124144624_703.png)
>hash: 49216821ae9a6f7fece7b9d2ad09e710  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124144624_703.png  
>file-name: 20180124144624_703.png  

[61794ba1a4a77d7548a086e80485828e]: media/20180124143949_177.png
[20180124143949_177.png](media/20180124143949_177.png)
>hash: 61794ba1a4a77d7548a086e80485828e  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124143949_177.png  
>file-name: 20180124143949_177.png  

[67c774d0294e3cc3812c59bc278310ae]: media/20180124145249_110.png
[20180124145249_110.png](media/20180124145249_110.png)
>hash: 67c774d0294e3cc3812c59bc278310ae  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124145249_110.png  
>file-name: 20180124145249_110.png  

[69a3baa4f8ddec67506b0b82cdf257ff]: media/20180124145034_898.png
[20180124145034_898.png](media/20180124145034_898.png)
>hash: 69a3baa4f8ddec67506b0b82cdf257ff  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124145034_898.png  
>file-name: 20180124145034_898.png  

[6a4daa37e4ee2ee3fcb4cbdd7ec7d18b]: media/20180124145846_56.png
[20180124145846_56.png](media/20180124145846_56.png)
>hash: 6a4daa37e4ee2ee3fcb4cbdd7ec7d18b  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124145846_56.png  
>file-name: 20180124145846_56.png  

[6c45136590a0abc8cd086509eb709570]: media/20180124144947_226.png
[20180124144947_226.png](media/20180124144947_226.png)
>hash: 6c45136590a0abc8cd086509eb709570  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124144947_226.png  
>file-name: 20180124144947_226.png  

[710bfbe3e96e439ed116a1d37799acad]: media/20180124144916_977.png
[20180124144916_977.png](media/20180124144916_977.png)
>hash: 710bfbe3e96e439ed116a1d37799acad  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124144916_977.png  
>file-name: 20180124144916_977.png  

[78852da8db1de1643b44c06ce591fe70]: media/20180124145622_270.png
[20180124145622_270.png](media/20180124145622_270.png)
>hash: 78852da8db1de1643b44c06ce591fe70  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124145622_270.png  
>file-name: 20180124145622_270.png  

[7f8572d11eaeaf0fe96a94a70c8fd8f2]: media/20180124150238_646.png
[20180124150238_646.png](media/20180124150238_646.png)
>hash: 7f8572d11eaeaf0fe96a94a70c8fd8f2  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124150238_646.png  
>file-name: 20180124150238_646.png  

[803588fa82e8257f3107fa0befd12f67]: media/20180124145410_68.png
[20180124145410_68.png](media/20180124145410_68.png)
>hash: 803588fa82e8257f3107fa0befd12f67  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124145410_68.png  
>file-name: 20180124145410_68.png  

[823ed304b6e151ec6c6fa42767a9d18a]: media/20180124145622_215.png
[20180124145622_215.png](media/20180124145622_215.png)
>hash: 823ed304b6e151ec6c6fa42767a9d18a  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124145622_215.png  
>file-name: 20180124145622_215.png  

[832b70084c6bda7966b1cb819b2375e1]: media/20180124145622_69.png
[20180124145622_69.png](media/20180124145622_69.png)
>hash: 832b70084c6bda7966b1cb819b2375e1  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124145622_69.png  
>file-name: 20180124145622_69.png  

[83cc2302cd7b2b9fdfcaed50a09909c6]: media/20180124144916_531.png
[20180124144916_531.png](media/20180124144916_531.png)
>hash: 83cc2302cd7b2b9fdfcaed50a09909c6  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124144916_531.png  
>file-name: 20180124144916_531.png  

[8aa273e881d443317aa34b521cdda098]: media/20180124145846_313.png
[20180124145846_313.png](media/20180124145846_313.png)
>hash: 8aa273e881d443317aa34b521cdda098  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124145846_313.png  
>file-name: 20180124145846_313.png  

[8dce5a5760e14c6f6cebb394a60f4148]: media/20180124145952_497.png
[20180124145952_497.png](media/20180124145952_497.png)
>hash: 8dce5a5760e14c6f6cebb394a60f4148  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124145952_497.png  
>file-name: 20180124145952_497.png  

[971e1a418ba8fc5ae02780883cec01ea]: media/20180124145622_877.png
[20180124145622_877.png](media/20180124145622_877.png)
>hash: 971e1a418ba8fc5ae02780883cec01ea  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124145622_877.png  
>file-name: 20180124145622_877.png  

[9906e230bfb0253e5c1184b31b8eb074]: media/20180124145952_31.png
[20180124145952_31.png](media/20180124145952_31.png)
>hash: 9906e230bfb0253e5c1184b31b8eb074  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124145952_31.png  
>file-name: 20180124145952_31.png  

[9a6b60ddfc88b2567f2060c90eecb7bd]: media/20180124145846_265.png
[20180124145846_265.png](media/20180124145846_265.png)
>hash: 9a6b60ddfc88b2567f2060c90eecb7bd  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124145846_265.png  
>file-name: 20180124145846_265.png  

[9ab632725a103dc47f766dea08a7b2a4]: media/20180124150031_526.png
[20180124150031_526.png](media/20180124150031_526.png)
>hash: 9ab632725a103dc47f766dea08a7b2a4  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124150031_526.png  
>file-name: 20180124150031_526.png  

[a03dc589da5810cf2657be6ebc507974]: media/20180124145952_356.png
[20180124145952_356.png](media/20180124145952_356.png)
>hash: a03dc589da5810cf2657be6ebc507974  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124145952_356.png  
>file-name: 20180124145952_356.png  

[af13157f5c1740f0be79340fa998d229]: media/20180124145846_237.png
[20180124145846_237.png](media/20180124145846_237.png)
>hash: af13157f5c1740f0be79340fa998d229  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124145846_237.png  
>file-name: 20180124145846_237.png  

[b542088663bfff13c0752a1b3caa40a7]: media/20180124145249_567.png
[20180124145249_567.png](media/20180124145249_567.png)
>hash: b542088663bfff13c0752a1b3caa40a7  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124145249_567.png  
>file-name: 20180124145249_567.png  

[b78ad0bdf35ab95c936c7681596383b3]: media/20180124150050_345.png
[20180124150050_345.png](media/20180124150050_345.png)
>hash: b78ad0bdf35ab95c936c7681596383b3  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124150050_345.png  
>file-name: 20180124150050_345.png  

[b9c4cadcd0b1a65d57568396cf53cc84]: media/20180124150238_273.png
[20180124150238_273.png](media/20180124150238_273.png)
>hash: b9c4cadcd0b1a65d57568396cf53cc84  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124150238_273.png  
>file-name: 20180124150238_273.png  

[bf28b361568acb0c92e8dc04fd9d3612]: media/20180124144916_718.png
[20180124144916_718.png](media/20180124144916_718.png)
>hash: bf28b361568acb0c92e8dc04fd9d3612  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124144916_718.png  
>file-name: 20180124144916_718.png  

[c24cb351952cb4edf5f29b17fbc41a11]: media/20180124144008_777.png
[20180124144008_777.png](media/20180124144008_777.png)
>hash: c24cb351952cb4edf5f29b17fbc41a11  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124144008_777.png  
>file-name: 20180124144008_777.png  

[c8d47af34fceb8152f41cea21537c9d6]: media/20180124145846_276.png
[20180124145846_276.png](media/20180124145846_276.png)
>hash: c8d47af34fceb8152f41cea21537c9d6  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124145846_276.png  
>file-name: 20180124145846_276.png  

[c9f9902af277efa0ae78d75c5d620f3e]: media/20180124150031_104.png
[20180124150031_104.png](media/20180124150031_104.png)
>hash: c9f9902af277efa0ae78d75c5d620f3e  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124150031_104.png  
>file-name: 20180124150031_104.png  

[cad295f7695e13224ffff98e46257b55]: media/20180124145622_880.png
[20180124145622_880.png](media/20180124145622_880.png)
>hash: cad295f7695e13224ffff98e46257b55  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124145622_880.png  
>file-name: 20180124145622_880.png  

[cf0557fba8dd216eb4ff971a2612ef9c]: media/20180124145622_300.png
[20180124145622_300.png](media/20180124145622_300.png)
>hash: cf0557fba8dd216eb4ff971a2612ef9c  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124145622_300.png  
>file-name: 20180124145622_300.png  

[d50bc5a9c8b081f44946d371436118bd]: media/20180124145622_764.png
[20180124145622_764.png](media/20180124145622_764.png)
>hash: d50bc5a9c8b081f44946d371436118bd  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124145622_764.png  
>file-name: 20180124145622_764.png  

[d535e66a1f1ab58dfa2e6182357ed58f]: media/20180124144916_641.png
[20180124144916_641.png](media/20180124144916_641.png)
>hash: d535e66a1f1ab58dfa2e6182357ed58f  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124144916_641.png  
>file-name: 20180124144916_641.png  

[d900912abb9fe64c763e13d9b37466a6]: media/20180124150238_763.png
[20180124150238_763.png](media/20180124150238_763.png)
>hash: d900912abb9fe64c763e13d9b37466a6  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124150238_763.png  
>file-name: 20180124150238_763.png  

[db453cd32e7a906fdc2c1db6d456a877]: media/20180124143929_80.png
[20180124143929_80.png](media/20180124143929_80.png)
>hash: db453cd32e7a906fdc2c1db6d456a877  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124143929_80.png  
>file-name: 20180124143929_80.png  

[ddedc94380a5f89e05fe295934a663ad]: media/20180124145622_451.png
[20180124145622_451.png](media/20180124145622_451.png)
>hash: ddedc94380a5f89e05fe295934a663ad  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124145622_451.png  
>file-name: 20180124145622_451.png  

[de4c3d9876ac4a36ef530947545156d0]: media/20180124144511_762.png
[20180124144511_762.png](media/20180124144511_762.png)
>hash: de4c3d9876ac4a36ef530947545156d0  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124144511_762.png  
>file-name: 20180124144511_762.png  

[df3e567d6f16d040326c7a0ea29a4f41]: media/spacer-2.gif
[spacer-2.gif](media/spacer-2.gif)
>hash: df3e567d6f16d040326c7a0ea29a4f41  
>source-url: http://47.100.29.40/highgo_admin/ueditor/themes/default/images/spacer.gif  
>file-name: spacer.gif  

[e013c7cd12ab5658dacffd84a3df5da5]: media/20180124143903_716.png
[20180124143903_716.png](media/20180124143903_716.png)
>hash: e013c7cd12ab5658dacffd84a3df5da5  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124143903_716.png  
>file-name: 20180124143903_716.png  

[e3d7fa809cbb75c34603b64208ad9e1b]: media/20180124144615_817.png
[20180124144615_817.png](media/20180124144615_817.png)
>hash: e3d7fa809cbb75c34603b64208ad9e1b  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124144615_817.png  
>file-name: 20180124144615_817.png  

[e7874289cf2d135461651491685c8844]: media/20180124144947_152.png
[20180124144947_152.png](media/20180124144947_152.png)
>hash: e7874289cf2d135461651491685c8844  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124144947_152.png  
>file-name: 20180124144947_152.png  

[e8a6e54e6d60e5740f63e72b6d757b6e]: media/20180124144916_946.png
[20180124144916_946.png](media/20180124144916_946.png)
>hash: e8a6e54e6d60e5740f63e72b6d757b6e  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124144916_946.png  
>file-name: 20180124144916_946.png  

[e908ff3eb1eb09e5f3162270533cf291]: media/20180124144437_478.png
[20180124144437_478.png](media/20180124144437_478.png)
>hash: e908ff3eb1eb09e5f3162270533cf291  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124144437_478.png  
>file-name: 20180124144437_478.png  

[e9e7b4cd6aa65e854324815a35147a40]: media/20180124144027_285.png
[20180124144027_285.png](media/20180124144027_285.png)
>hash: e9e7b4cd6aa65e854324815a35147a40  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124144027_285.png  
>file-name: 20180124144027_285.png  

[ee3da5c2e7941785aad9588c1377ffd3]: media/20180124145410_353.png
[20180124145410_353.png](media/20180124145410_353.png)
>hash: ee3da5c2e7941785aad9588c1377ffd3  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124145410_353.png  
>file-name: 20180124145410_353.png  

[f489a9f991fa55d5fdbf83744ffa566c]: media/20180124145202_482.png
[20180124145202_482.png](media/20180124145202_482.png)
>hash: f489a9f991fa55d5fdbf83744ffa566c  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124145202_482.png  
>file-name: 20180124145202_482.png  

[f573ef2e805ddbd144df3203c9adb6f9]: media/20180124145846_726.png
[20180124145846_726.png](media/20180124145846_726.png)
>hash: f573ef2e805ddbd144df3203c9adb6f9  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124145846_726.png  
>file-name: 20180124145846_726.png  

[f62e1aba7aff90d8d70d2dcaa886c845]: media/20180124150238_314.png
[20180124150238_314.png](media/20180124150238_314.png)
>hash: f62e1aba7aff90d8d70d2dcaa886c845  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124150238_314.png  
>file-name: 20180124150238_314.png  

[f9cdbc4d466303f6de63325cd7418bc3]: media/20180124144254_313.png
[20180124144254_313.png](media/20180124144254_313.png)
>hash: f9cdbc4d466303f6de63325cd7418bc3  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124144254_313.png  
>file-name: 20180124144254_313.png  

[fc943637a1d3cf58fbb15556b15681d6]: media/20180124144353_191.png
[20180124144353_191.png](media/20180124144353_191.png)
>hash: fc943637a1d3cf58fbb15556b15681d6  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180124144353_191.png  
>file-name: 20180124144353_191.png  


---
### TAGS
{Support20180830}

---
### NOTE ATTRIBUTES
>Created Date: 2018-08-30 02:17:26  
>Last Evernote Update Date: 2018-10-01 15:33:55  
>source: web.clip7  
>source-url: https://47.100.29.40/highgo_admin/#/index/docSearchDetail/9ea11401074b57  
>source-application: WebClipper 7  