# Oracle RAC 添加删除节点更换设备指导书.html

You need to enable JavaScript to run this app.

![](https://47.100.29.40/highgo_admin/static/media/head.530901d0.png)

  杨光  |  退出

  * 知识库

    * ▢  新建文档
    * ▢  文档复查 (3)
    * ▢  文档查询
  * 待编区

文档详细

  知识库 文档详细

![noteattachment1][7f025a17697ee15eb3197c61326b203b]

064082604

Oracle RAC 添加删除节点更换设备指导书

目录

环境

文档用途

详细信息

相关文档

内部备注

附件

环境

系统平台：Linux x86 Red Hat Enterprise Linux 4,Linux x86 Red Hat Enterprise Linux
5,Linux x86 Red Hat Enterprise Linux 6,Linux x86-64 Red Hat Enterprise Linux
4,Linux x86-64 Red Hat Enterprise Linux 5,Linux x86-64 Red Hat Enterprise
Linux 6,Linux x86-64 Red Hat Enterprise Linux 7

版本：11.2.0.1,11.2.0.2,11.2.0.3,11.2.0.4

文档用途

指导添加删除RAC节点以更换节点服务器，增加服务器分担压力等。

  

详细信息

# 添加节点

## 1、验证系统要求

要验证系统是否满足 Oracle 11g 数据库的最低要求，以 root 用户身份登录并运行以下命令。

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

  ![noteattachment2][7c146d143810c9267dedb0f876c3ba85]  

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

[root@localhost network-scripts]# cp ifcfg-eno16777736  ifcfg-eth0

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



Hosts文件配置，将新节点的相关ip加入其中

每个主机vi /etc/hosts

192.168.0.25    rac1

192.168.0.26    rac2



192.0.10.125    rac1-priv

192.0.10.126    rac2-priv



192.168.0.125   rac1-vip

192.168.0.130   rac2-vip

192.168.0.127   scan



rac1、rac2 对应的是网卡的物理ip ，即public ip

rac1-priv、rac2-priv 对应的是心跳网卡的物理ip  即private ip

rac1-vip、rac2-vip 对应的是虚拟VIP

scan对应的SCAN ip



建议客户客户端连接rac群集，访问数据库时使用  SCAN  ip地址。

 **注意** **：** **vip** **、** **public ip** **、** **scan ip** **必须要在同一个子网网段中。**

 **另外** **对于心跳** **IP** **地址的设置** **，** **不要设置成和客户局域网中存在的** **ip** **网段。**

 **如客户网络是** **192.x.x.x** **则设置心跳为** **10.x.x.x   ,**
**心跳地址工程师可以自定义，但也要和客户确认客户局域网络是否有相同** **ip** **地址的服务器，尽量避免干扰。**



配置完心跳地址后,一定要使用traceroute测试心跳网络之间通讯是否正常.心跳通讯是否正常不能简单地通过ping命令来检测.一定要使用traceroute默认是采用udp协议.每次执行traceroute会发起三次检测,*号表示通讯失败.

正常:

[root@rac1 ~]# traceroute rac2-priv

traceroute to rac2-priv (192.168.122.132), 30 hops max, 60 byte packets

1          lsrac2-priv (192.168.122.132)  **0.802 ms   0.655 ms  0.636 ms**

不正常:

[root@lsrac1 ~]# traceroute rac2-priv

traceroute to rac2-priv (192.168.122.132), 30 hops max, 60 byte packets

 1  lsrac2-priv (192.168.122.132)  1.187 ms *** ***

 如果经常出现* 则需要先检测心跳网络通讯是否正常.



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

![noteattachment3][313e6669fa5cfb6c9a7b190b636fe162]

yum install elfutils-libelf-devel binutils compat-libcap* gcc gcc-c++ glibc
glibc-devel ksh  libaio libaio-devel libgcc  libstdc++  libstdc++-devel libXi
libXtst make sysstat tiger* iscsi*  -y

其中compat-libstdc++-33-3.2.3 在rhel7的镜像中默认没有，需要单独安装。

文件见附件



 **参考文章：** **Requirements for Installing Oracle 11.2.0.4 RDBMS on OL7 or RHEL7
64-bit (x86-64) (** **文档** **ID 1962100.1)**

##  5、内核参数

 **/etc/sysctl.conf** ** ** **这里面的修改可以通过安装过程中运行**` **runfixup.sh**`
**脚本自动修改。**

 **在安装过程中，系统会提示。**



Oracle Database 11 _g_ 第 2
版需要如下所示的内核参数设置。给出的值都是最小值，因此如果系统使用更大的值，则不要更改。其中shmmax和shmall要根据实际物理内存进行计算。



vi /etc/sysctl.conf



kernel.shmmax = 4294967295  

#shmmax  1/2 of physical RAM( 单位B  )See
[Note:567506.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1962100.1&id=567506.1)
for more information.

kernel.shmall = 2097152  

#shmall等于物理内存（单位B）/page_size ,而page_size大小是运行getconf PAGE_SIZE  命令获得的，一般是4096B
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

fs.aio-max-nr=1048576



运行如下命令是参数立即生效。

[root@racnode1 ~]# sysctl -p

   ![noteattachment4][a86cfbc88db6ff546adcdd1b93d8d8dd]

 **参考文章：** **    Requirements for Installing Oracle 11.2.0.4 RDBMS on OL7 or
RHEL7 64-bit (x86-64) (** **文档** **ID 1962100.1)**

## 6 、设置oracle的shell限制：

vi /etc/security/limits.conf

#for oracle

grid                 soft    nofile  1024

grid                 hard    nofile  65536

grid                 hard    stack   10240

oracle               soft    nofile  1024

oracle               hard    nofile  65536

oracle               hard    stack   10240

修改使以上参数生效：

vi /etc/pam.d/login

添加如下行

session required pam_limits.so

 **注意》**

nproc参数的生效并不是在/etc/security/limits.conf里生效，是需要在

/etc/security/limits.d/20-nproc.conf  文件中设置

参考：

 **Setting nproc values on Oracle Linux 6 for RHCK kernel (** **文档** **ID
2108775.1)**  
  
---  
  
  

[root@localhost limits.d]# cat 20-nproc.conf

# Default limit for number of user's processes to prevent

# accidental fork bombs.

# See rhbz #432903 for reasoning.



*          soft    nproc     1024

root       soft    nproc     unlimited



不要修改默认的 *          soft    nproc     1024



要添加oracle和grid 项

grid      soft     nproc   2047

grid      hard    nproc   16384

oracle    soft     nproc   2047

oracle    hard    nproc   16384

nproc值表示该用户下的最大进程数max user processes如果业务进程较多，则可能因为进程达到上限而使得操作系统用户无法登陆。

查看当前用户的max user processes，可登录到指定的系统用户下

[root@localhost security]# ulimit -a

core file size          (blocks, -c) 0

data seg size           (kbytes, -d) unlimited

scheduling priority             (-e) 0

file size               (blocks, -f) unlimited

pending signals                 (-i) 23692

max locked memory       (kbytes, -l) 32

max memory size         (kbytes, -m) unlimited

open files                      (-n) 1024

pipe size            (512 bytes, -p) 8

POSIX message queues     (bytes, -q) 819200

real-time priority              (-r) 0

stack size              (kbytes, -s) 10240

cpu time               (seconds, -t) unlimited

max user processes              (-u) 23692

virtual memory          (kbytes, -v) unlimited

file locks                      (-x) unlimited

## 7、修改操作系统时间

不要在生产时段修改生产环境的时间！

检查多个服务器节点的操作系统时间是否一致。如果不一致要先手动修改。

如何同时修改两台或者多台主机的时间一模一样呢？

建议使用SecureCRT工具、

使用方法：先登录一台主机

![noteattachment5][e013c7cd12ab5658dacffd84a3df5da5]

  

然后登录第二台主机

![noteattachment6][db453cd32e7a906fdc2c1db6d456a877]

  

打开查看菜单，勾选交互窗口

![noteattachment7][61794ba1a4a77d7548a086e80485828e]

  

窗口下方出现交互窗口

![noteattachment8][c24cb351952cb4edf5f29b17fbc41a11]

在交互窗口上右键菜单，勾选发送交互到所有会话。（此时要注意这个CRT窗口必须只能有RAC的两台服务器，不能有到其他主机的远程连接会话）

![noteattachment9][e9e7b4cd6aa65e854324815a35147a40]



然后此时在交互窗口里输入的命令回车后都会自动发送到所有主机上执行。

linx修改时间的命令是  ：年月日 时分秒

[root@rhel ~]# date -s "20100405 14:31:00"



关闭时间同步服务，默认使用ctssd进行节点间时间同步。

 **Unable to Configure NTP after Oracle Linux 7 Installation (** **文档** **ID
1995703.1)**

 **rhel7** **默认不安装** **ntp** **服务** **，而是被** **chronyd** **服务代替。**

禁用chronyd

systemctl stop chronyd

systemctl disable chronyd

如果安装有NTP服务，则禁用

/bin/systemctl stop  ntpd.service

systemctl disable ntpd.service

mv /etc/ntp.conf /etc/ntp.conf.bak

一定要保证节点间时间同步，但是不能配置ntp，否则会导致11g的ctssd处于旁观模式。如果客户严格要求和北京时间一致，则考虑让客户提供时间服务器，然后再采用NTP或chronyd和其时间服务器同步。如果配置NTP注意参数
-x 保证时间不能向回调，关于NTP配置此处不做详细解释。







## 8、修改主机名



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

[root@localhost ~]#hostnamectl set-hostname  **rac1**



注意主机名不能过长,不能超过8个字符，且不能有下划线等特殊符号，不要使用大写字母，建议使用小写字母即可。



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

|  
|  
  
  
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

mkdir -p  /u01/app/11.2.0/grid

chown grid:oinstall /u01/  -R

chmod 775 /u01/ -R

创建oracle目录

mkdir -p  /u02/app/oracle/product/11.2.0/db_home

chown oracle:oinstall /u02/ -R

chmod  775 /u02/ -R

修改grid用户环境变量

登录rac节点1

su - grid

vi .bash_profile

ORACLE_SID=+ASM1; export ORACLE_SID

ORACLE_BASE=/u01/app/grid; export ORACLE_BASE

ORACLE_HOME=/u01/app/11.2.0/grid; export ORACLE_HOME

ORACLE_PATH=/u01/app/oracle/common/oracle/sql; export ORACLE_PATH

umask 022

PATH=$ORACLE_HOME/bin:$PATH:$HOME/bin:$ORACLE_PATH

export PATH

 **注意：** **grid** **用户环境变量** **ORACLE_HOME** **不在** **ORACLE_BASE** **目录下** **
**

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

ORACLE_PATH=/u01/app/oracle/common/oracle/sql; export ORACLE_PATH

umask 022

PATH=$ORACLE_HOME/bin:$PATH:$HOME/bin:$ORACLE_PATH

export PATH

 **注意：** **grid** **用户环境变量** **ORACLE_HOME** **不在** **ORACLE_BASE** **目录下** **
**

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

## 10、ASM配置共享磁盘

参考其他节点的共享磁盘配置，确保与其他节点一致。

### 10.1使用linux操作系统自带multipath多路径软件的情况：

 **参考文章：**

 **Deploying Oracle Database 12c on** **Red Enterprise Linux 7**

[ https://www.redhat.com/en/files/resources/en-rhel-deploying-
Oracle-12c-rhel-7.pdf](https://www.redhat.com/en/files/resources/en-rhel-
deploying-Oracle-12c-rhel-7.pdf)

 **参考文章：** **How to set udev rules in OL7 related to ASM on multipath disks
(** **文档** **ID 2101679.1)**

生成multipath.conf文件

/sbin/mpathconf --enable

查询磁盘设备的wwid

for i in `cat /proc/partitions | awk '{print $4}' |grep sd | grep [a-z]$`; do
echo "### $i: ` /usr/lib/udev/scsi_id -g -u  -d  /dev/$i`"; done



多路径配置文件内容/etc/multipath.conf，修改wwid和别名alias  

# cat   /etc/multipath.conf  
 defaults {

       polling_interval        5

       path_grouping_policy    failover

       prio                    const

       path_checker            directio

       rr_min_io               1000

       rr_weight               uniform

       failback                manual

       no_path_retry           fail

       user_friendly_names     yes

}



blacklist {

        devnode "^(ram|raw|loop|fd|md|dm-|sr|scd|st)[0-9]*"

        devnode "^hd[a-z]"

        devnode "^cciss!c[0-9]d[0-9]*"

}



multipaths {

multipath {

                wwid    14f504e46494c45525743714d4f6a2d6437466f2d30435362

                alias   fra

                path_grouping_policy failover

        }

        multipath {

                wwid    14f504e46494c4552664857314b622d576f63582d6f324743

                alias   data

                path_grouping_policy failover

        }

        multipath {

                wwid    14f504e46494c45524f616d324a4f2d463255562d42764747

                alias   ocr1

                path_grouping_policy failover

        }

        multipath {

                wwid    14f504e46494c455230336f4738382d684268682d66306a32

                alias   ocr2

                path_grouping_policy failover

        }

        multipath {

                wwid    14f504e46494c455241653457776c2d527a4c712d6c625178

                alias   ocr3

                path_grouping_policy failover

        }

        multipath {

                wwid    14f504e46494c45524146554f7a732d6b6443752d6e4f7956

                alias   ocr4

                path_grouping_policy failover

        }

        multipath {

                wwid    14f504e46494c4552416a4e6938672d363876662d6d636735

                alias   ocr5

                path_grouping_policy failover

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

 **参考文章： How to set udev rule for setting the disk permission on ASM disks
when using multipath on OL 6.x (文档 ID 1521757.1)**

 **使用 udev修改磁盘权限和属主**

vi  /etc/udev/rules.d/12-dm-permissions-highgo.rules

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

  
**参考文章： How to set udev rules in OL7 related to ASM on multipath disks (文档 ID
2101679.1)**

但经过试验，该重新加载的命令并不一定能够保证重新加载udev策略。

可以使用systemctl restart systemd-udev-trigger.service重启service可以重新加载策略。

 **如果是现有生产环境添加磁盘等操作，不建议使用 start_udev或者systemctl restart systemd-udev-
trigger.service来在线添加新磁盘，建议手动在线修改，并安排停机时间重启确认。**

ls –l /dev/dm-*  检查磁盘属主和权限是否正确。



修改 /etc/systemd/system/sysinit.target.wants/multipathd.service

将PIDFile=/var/run/multipathd/multipathd.pid

改为

PIDFile=/run/multipathd.pid

 **参考文章：**

 **Oracle Linux 7: Multipathd Does Not Start Automatically on System Boot (**
**文档 ID 2093615.1)**

### 10.2使用存储专用多路径软件的情况：

此种情况下磁盘的名称，以及磁盘唯一性的确认都是存储工程来保障的。

如emc的存储多路径聚合软件聚合后的盘一般是/dev/emcpowera 、/dev/emcpowerb等

只需要 存储工程师提供给我们盘名，我们进行ASM层面的操作即可。

华为多路径聚合磁盘后磁盘名称依然是/dev/sdb 、/dev/sdc  等， kernel == "sdb"即可。

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

  
**参考文章： How to set udev rules in OL7 related to ASM on multipath disks (文档 ID
2101679.1)**

但经过试验，该重新加载的命令并不一定能够保证重新加载udev策略。

可以使用systemctl restart systemd-udev-trigger.service重启service可以重新加载策略。



检查是否生成ls -l /dev/raw/raw*磁盘,以及磁盘权限是否是grid:asmadmin

### 10.3创建用于ASM访问的磁盘软链接

无论磁盘如何采用何种形式管理，一定要创建软连接，放到/u10/asm-disk中

mkdir /u01/asm-disk/

举例如：

ln -s /dev/mapper/ocr1 /u01/asm-disk/ocr1

ln -s /dev/mapper/ocr2 /u01/asm-disk/ocr2

ln -s /dev/mapper/ocr3 /u01/asm-disk/ocr3

ln -s /dev/mapper/ocr4 /u01/asm-disk/ocr4

ln -s /dev/mapper/ocr5 /u01/asm-disk/ocr5

ln -s /dev/mapper/data /u01/asm-disk/data

ln -s /dev/mapper/fra  /u01/asm-disk/fra

## 11、配置SSH

1. 对 grid 和 oracle 用户配置 SSH，具体步骤参考下面的文章:

NOTE: 300548.1 - How To Configure SSH for a RAC Installation

或者

Oracle Grid Infrastructure Installation Guide 11g Release 2 (11.2) for Linux

[http://docs.oracle.com/cd/E11882_01/install.112/e22489/manpreins.htm#CWLIN407](http://docs.oracle.com/cd/E11882_01/install.112/e22489/manpreins.htm#CWLIN407)

或者

采用oracle自带ssh脚本：

见附件

./sshUserSetup.sh -user 用户名 -hosts "主机名1 主机名2 主机名3 。。。" -advanced
-noPromptPassphrase

2. 测试验证 SSH configuration。

## 12、使用 CVU 检查新加节点的硬件和 OS 环境

在现有节点上运行如下的命令,rac3是待添加主机名：

$ cluvfy stage -post hwos -n rac3 -verbose

$ cluvfy comp peer -refnode rac1 -n rac3 -orainv oinstall -osdba oinstall-
verbose

$ cluvfy stage -pre nodeadd -n rac3 -verbose

注意：如果出现警告/错误信息，请在添加节点前修复。

## 13、备份 OCR

在添加节点前，建议手动备份 OCR （GRID 每 4 个小时也会自动备份 OCR），目的是如果出现某些问题，我们可以恢复到添加节点前的状态：

$su - root

$GRID_HOME/bin/ocrdump /tmp/ocrdump_1nodes.bak

## 14、添加cluster RAC

不使用GNS的情况

(GNS--Grid Naming Service,与SCAN搭配使用，可以不配置RAC的IP地址，使用DHCP服务来分配IP)

$ GI_HOME/oui/bin/addNode.sh -silent "CLUSTER_NEW_NODES={rac3}"
"CLUSTER_NEW_VIRTUAL_HOSTNAMES={rac3-vip}"

如果在之前检查的时候有错误需要忽略，需要先添加如下环境变量：

$ export IGNORE_PREADDNODE_CHECKS=Y

使用GNS的情况是:

$ GI_HOME/oui/bin/addNode.sh -silent “CLUSTER_NEW_NODES={<new node>}”



在执行完之后会提醒在新节点上运行root脚本,按照提示执行就行

检查确认cluster已经安装完成

$GI_HOME/bin/cluvfy stage -post nodeadd -n <new node> -verbose

修改一个权限:

使用root用户

cd $ORACLE_HOME/bin

chgrp asmadmin oracle

chmod 6751 oracle

ls -l oracle

## 15、添加database software

从已经存在的节点上使用oracle用户执行:

$> $ORACLE_HOME/oui/bin/addNode.sh -silent "CLUSTER_NEW_NODES={<new node>}"

执行完成之后,根据提示在新节点上执行root脚本。

## 16、添加DB instance

方案1：

$ORACLE_HOME/bin/dbca -silent -addInstance -nodeList <new node> -gdbName <db
name> -instanceName <new instance> -sysDBAUserName sys -sysDBAPassword <sys
password>

方案2：

1.         在节点 1 以 oracle 用户运行 dbca

![noteattachment10][ba058fddf1f46af542c661b58202bc14]

2.         选择 RAC database

![noteattachment11][62cf83adfb748fbddf702a4317b312a4]

3.          

![noteattachment12][fcc92f99bf269bb8204ea65ac59a1bc2]

4.         选择 add an instance

![noteattachment13][6e7d851d9722bc706dea6a180de4c98d]

5.         当前的 RAC database

![noteattachment14][d89763cb69065159651cf3573141c87a]

6.         当前已有的数据库实例

![noteattachment15][f7d1e26d74ceaab0050444f795e31650]

7.         新数据库实例

![noteattachment16][420c1379d4b05ed9d40818a6a55bbeba]

8.         实例 3 的 undo tablespace 和 redo log 信息：

![noteattachment17][a988d87fcffffb19a75f5dd64add930f]

9.         总结

![noteattachment18][0edf1f3cbc8ac4e6212f16427cb8d575]

10.      

![noteattachment19][aa94ddc7f2e4804403cb295d6f024129]

11.     完成

12.     检查集群和数据库是否正常。

# 删除节点

## 1、备份 OCR

在添加节点前，建议手动备份 OCR （GRID 每 4 个小时也会自动备份 OCR），目的是如果出现某些问题，我们可以恢复到添加节点前的状态：

$su - root

$GRID_HOME/bin/ocrdump /tmp/ocrdump_1nodes.bak

## 2、删除DB instance

方案1：

oracle用户在保留节点使用dbca的静默模式进行删除实例：

$ dbca -silent -deleteInstance [-nodeList node_name] -gdbName gdb_name
-instanceName instance_name -sysDBAUserName sys -sysDBAPassword password

方案2：

1.       oracle用户在保留节点运行dbca：

![noteattachment20][55e51b1d4e4bece036a5cfe3b295c938]

2.        

![noteattachment21][16f2c50c5ad4818b016010ce74a0448a]

3.        

![noteattachment22][9f3898b8748c90ceb50a82c1457b9998]

4.        

![noteattachment23][a732475156f5cdca71585b89bf940a8b]

5.        

![noteattachment24][b7b4b191d31ae315689cf37134c4ad1d]

6.       选择准备删除的数据库实例

![noteattachment25][52d44f0c410ae5c12e26eee0906ea090]

7.        

![noteattachment26][be973cef48245887ae80ec9cb981f734]

8.        

![noteattachment27][007dcaced306b778f9b56384c09ef09b]

9.        

![noteattachment28][f690a156c7a0e7bf51180864e0d1de04]

10.   完成

11.   禁用被删除实例的线程

SQL> ALTER DATABASE DISABLE THREAD 3;

12.   检查

[grid@rac001 ~]$ srvctl config database -d orcl

## 3、移除RAC

1 禁用将被删除节点上的监听：

$ srvctl disable listener -l listener_name -n name_of_node_to_delete

$ srvctl stop listener -l listener_name -n name_of_node_to_delete

2更新被删节点清单

在要删除的节点上的$ORACLE_HOME/oui/bin中运行以下命令以更新该节点上的清单：

$ ./runInstaller -updateNodeList ORACLE_HOME=Oracle_home_location
"CLUSTER_NODES={name_of_node_to_delete}" -local

3对于共享主节点的情况（一般的都不是这种）

对于共享主节点，通过在要删除的每个节点上的$ORACLE_HOME/oui/bin目录中运行以下命令来分离节点，而不是卸载节点：

$ ./runInstaller -detachHome ORACLE_HOME = Oracle_home_location

4.用oracle用户在要删除的节点运行脚本

$ORACLE_HOME/deinstall/deinstall -local

5. 用oracle用户从群集中任何一个剩余节点上的$ORACLE_HOME/oui/bin目录运行以下命令，以更新这些节点的清单，并指定以逗号分隔的剩余节点名称列表：

$ ./runInstaller -updateNodeList ORACLE_HOME=Oracle_home_location
"CLUSTER_NODES={remaining_node_list}"

6.在GRID层面删除节点

在要删除的节点用root执行：

# $GRID_HOME/crs/install/rootcrs.pl -deconfig -deinstall -force

在要保留节点用root执行：

# $GRID_HOME/bin/crsctl delete node -n rac3

至此rac3从集群中移除完毕。

检查集群状态。

# 添加/删除节点总结

1. 添加节点分为 3 个阶段，第一阶段是复制 GIRD HOME 到新节点，第二阶段是复制 RDBMS HOME 到新节点，第三阶段是 DBCA 添加数据库实例。

2. 第一阶段主要工作是复制 GIRD HOME 到新节点，配置 GRID， 并且启动 GRID， 同时更新OCR 信息， 更新 inventory 信息。

3. 第二阶段主要工作是复制 RDBMS HOME 到新节点，更新 inventory 信息。

4. 第三阶段主要工作是 DBCA 创建新的数据库实例（包括创建 undo 表空间， redo log，初始化参数等），更新 OCR 信息（包括注册新的数据库实例等）。

5. 在添加/删除节点的过程中，原有的节点一直是 online 状态，不需要停机，对客户端业

务没有影响。

6. 添加/删除节点前，备份 OCR （默认每 4 小时自动备份 ocr），在某些情况下添加/删除节点失败，可以通过恢复原来的 OCR 来解决问题。

7. 新节点的 ORACLE_BASE 和 ORACLE_HOME 路径在添加过程中会自动创建，无需手动创建。

8. 正常安装 11.2 GRID 时， OUI 界面提供 SSH 配置功能，但是添加节点脚本 addNode.sh 没有这个功能，因此需要手动配置 oracle 用户和 grid 用户的 SSH 用户等效性。此外，在配置完等效性后，务必手动对每个节点的公有IP和私有IP进行ssh测试，确保不需要输入yes或者密码。检查等效性如果不通过，务必解决此问题。

# 常见问题

1 CVU 报错 PRVF-4007

运行 CVU 时报 PRVF-4007 : User equivalence check failed，

原因是没有为新添加节点的 grid 用户和 oracle 用户配置用户等效性。

2 复制/etc/oratab 失败

有些情况下从节点 1 复制/etc/oratab 到节点 3 时，可能会失败，原因是权限问题，可以手动修改/etc/oratab 文件或者修改权限

3 RDBMS_oracle_home/oui/bin/addNode.sh 报没有权限创建文件

如果是先运行了 grid_home/root.sh 脚本，那么会将 ORACLE BASE 权限改为 root 用户，

因此后执行 rdbms 下面的 addNode.sh 时就会由于权限不足而失败。

解决方法有 2 个：

方法 1：后运行 grid_home/root.sh 脚本，先运行 rdbms 下面的 addNode.sh。

方法 2：手动修改 oracle base 权限，安装结束后再修改回来。

# 参考文档

Oracle Clusterware Administration and Deployment Guide 11g Release 2 (11.2)

>>>> 4 Adding and Deleting Cluster Nodes

http://docs.oracle.com/cd/E11882_01/rac.112/e16794/adddelclusterware.htm#CHDFIAIE

Oracle Real Application Clusters Administration and Deployment Guide 11g
Release 2 (11.2)

>>>> 10 Adding and Deleting Oracle RAC from Nodes on Linux and UNIX Systems

http://docs.oracle.com/cd/E11882_01/rac.112/e16795/adddelunix.htm#BEICADHD

  

相关文档

内部备注

附件

compat-libstdc++-33-3.2.3-72.el7.x86_64.rpm  
---  
sshUserSetup.sh  
  
验证码：

  换一张

输入验证码：

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAYAAAA7MK6iAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEgAACxIB0t1+/AAAABZ0RVh0Q3JlYXRpb24gVGltZQAwOS8yNy8xN+stbYgAAAAcdEVYdFNvZnR3YXJlAEFkb2JlIEZpcmV3b3JrcyBDUzbovLKMAAABm0lEQVRIicXXwXGCQBTG8b+7uZsSTAXRCiQVhA6SXLgmJZgO5BguSQnYgR0EK0hKiAUs5rBvGVlBBEG/GWccxf0JC2/fjna7HU3JEz0BQnlNgbF3yBbIgBRIVWR+m8YcHYPzRE+BBfDY+O/KWQELFZmsNZwnegm8tgT9xCoybyfBeaJvgTVwfybqsgECFZm//Q/VwCgy1lrGroYHQEt4JSxzOgRa4GIAMsdy934PiO5npiKTuTNeXAgtrJH5UBPg54IwwJ3CVqO+swEegPea78MhYPfcroFlzTGhwtbevlFXLOrgqeKw4PeC5on+Ap5qjh37BcTPFjtXL/K+DxSAmwY4k7kiT3SGrT7+FWqNwmHJ9DPPE/0MIEtcQPnMO6EOPnYJAT5r8M4osFXYzqEpVXhXFCBT2HbllJTwM1CAtA1cws9AAVK3OqW066tibOGZd0BXKjLhdZdFuWHiC6Cx6zxLzZ4UiaG6kI2KTLEu+AUkwD6fvaMydpESLI9I33hle3u1hr62VssPZtjtSNussHdvJQoNeyeXITZt/1po2U5WDlb1AAAAAElFTkSuQmCC)![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAYAAAA7MK6iAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEgAACxIB0t1+/AAAABZ0RVh0Q3JlYXRpb24gVGltZQAwOS8yNy8xN+stbYgAAAAcdEVYdFNvZnR3YXJlAEFkb2JlIEZpcmV3b3JrcyBDUzbovLKMAAABu0lEQVRIicWX223CQBBFD26AlOAOMJoCQgl0AFQQSoEOoAN3EPLPKHYHKSFUQD686/jFPkysXMkSQsMc1jt7Z3Z2v9/xSVVTYG2eDJh3Qm5AAeRALiJfvpwzF1hVM2APbLz/rq0zcBCRIhqsqgfgLRLY1VFE9kFgVX0BLsDiSahVCaxE5Lv5ZTIxFJPrYnIPgyeAtuCDYLOnU0BruGEAZo9N9X5OCG1qKSKFXfFg5TVURiT2xe4BEmMOrnNaikgG7AKgOxPrgm9UNU2o3MilhapmInLywHcicjLblnpyrkPAUB0HF7wJvdC31EFwFgCeO+CxUIBsdr1e/V3iVzcqFypUdQswAgpALLgFh7qRREGh71yhSjufo6BjwHa1uapmZs9zwo5aD3yLhBaN1+ur9oe5EqrJYQx0jrvaXSoSqnHFJwtd0S+kMfA8BFw2js87w4XUhX/4wLY7nfD4NWEt0w59r46Ys4hsbVUfHIEEQqFauQtasxIAYwbHwOTP6GiNpzXsqWrBdFOIba9A30BWxDX9YKjJXasFNiPoX8MHx9t/G+gferX5wZLqOhKrM9VQ93CWc96drKa4tP0As8vvCUvsIrEAAAAASUVORK5CYII=)

sentinel

grep SwapTotal /proc/meminfo

&nbsp;

例如：

# grep MemTotal /proc/meminfo

MemTotal:512236 kB

# grep SwapTotal /proc/meminfo

SwapTotal:1574360 kB

&nbsp;

The minimum required RAM is 1.5 GB for grid infrastructure for a cluster, or
2.5 GB for grid infrastructure for a cluster and Oracle RAC. The minimum
required swap space is 1.5 GB. Oracle recommends that you set swap space to
1.5 times the amount of RAM for systems with 2 GB of RAM or less. For systems
with 2 GB to 16 GB RAM, use swap space equal to RAM. For systems with more
than 16 GB RAM, use 16 GB of RAM for swap space. If the swap space and the
grid home are on the same filesystem, then add together their respective disk
space requirements for the total minimum space required.

## 2、初始化系统服务：

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

&nbsp;

## 3、网络配置

rhel7 安装完后网卡的命名规则是 eno16777736 如果要改成eth0 的形式：

vim /etc/sysconfig/grub

然后，往这个文件中添加“net.ifnames=0
biosdevname=0”内容，如下图所示：&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

&nbsp;!["1.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180116131338_436.png%22/)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

上图中，红框部分是我所添加的内容（注意它的位置）。

紧接着，执行如下命令：

grub2-mkconfig -o /boot/grub2/grub.cfg

重启服务器，名字就发生了变化。

udev对网卡名称绑定：

vi /etc/udev/rules.d/70-persistent-net.rules&nbsp;

[root@rac1 ~]# vi /etc/udev/rules.d/70-persistent-net.rules

SUBSYSTEM==&quot;net&quot;, ACTION==&quot;add&quot;, DRIVERS==&quot;?*&quot;,
ATTR{address}==&quot;00:0c:29:28:15:78&quot;, ATTR{type}==&quot;1&quot;,
KERNEL==&quot;eth*&quot;, NAME=&quot;eth0&quot;

SUBSYSTEM==&quot;net&quot;, ACTION==&quot;add&quot;, DRIVERS==&quot;?*&quot;,
ATTR{address}==&quot;00:0c:29:28:15:82&quot;, ATTR{type}==&quot;1&quot;,
KERNEL==&quot;eth*&quot;, NAME=&quot;eth1&quot;

设置IP：

虽然ifconfig发现名字变回了eth0但是 配置文件仍让是en016777736.

复制eth0配置文件，

[root@localhost network-scripts]# cp ifcfg-eno16777736&nbsp; ifcfg-eth0

网卡文件配置vi ifcfg-eth0

&nbsp;

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

&nbsp;

修改lo网络的mtu为1500，末尾追加MTU=&quot;1500&quot;

[root@rac2 ~]# vi /etc/sysconfig/network-scripts/ifcfg-lo

DEVICE=lo

IPADDR=127.0.0.1

NETMASK=255.0.0.0

NETWORK=127.0.0.0

# If you&#39;re having problems with gated making 127.0.0.0/8 a martian,

# you can change this to something else (255.255.255.255, for example)

BROADCAST=127.255.255.255

ONBOOT=yes

NAME=loopback

MTU=&quot;1500&quot;

 **参考文章：** **  
Skgxpvfynet: Mtype: 61 Process 23043 Failed Because Of A Resource Problem In
The OS (** **文档** **ID 2014681.1)**

&nbsp;

Hosts文件配置，将新节点的相关ip加入其中

每个主机vi /etc/hosts

192.168.0.25&nbsp;&nbsp;&nbsp; rac1

192.168.0.26&nbsp;&nbsp;&nbsp; rac2

&nbsp;

192.0.10.125&nbsp;&nbsp;&nbsp; rac1-priv

192.0.10.126&nbsp;&nbsp;&nbsp; rac2-priv

&nbsp;

192.168.0.125&nbsp;&nbsp; rac1-vip

192.168.0.130&nbsp;&nbsp; rac2-vip

192.168.0.127&nbsp;&nbsp; scan

&nbsp;

rac1、rac2 对应的是网卡的物理ip ，即public ip

rac1-priv、rac2-priv 对应的是心跳网卡的物理ip&nbsp; 即private ip

rac1-vip、rac2-vip 对应的是虚拟VIP

scan对应的SCAN ip

&nbsp;

建议客户客户端连接rac群集，访问数据库时使用&nbsp; SCAN&nbsp; ip地址。

 **注意** **：** **vip** **、** **public ip** **、** **scan ip** **必须要在同一个子网网段中。**

 **另外** **对于心跳** **IP** **地址的设置** **，** **不要设置成和客户局域网中存在的** **ip** **网段。**

 **如客户网络是** **192.x.x.x** **则设置心跳为** **10.x.x.x &nbsp; ,**
**心跳地址工程师可以自定义，但也要和客户确认客户局域网络是否有相同** **ip** **地址的服务器，尽量避免干扰。**

&nbsp;

配置完心跳地址后,一定要使用traceroute测试心跳网络之间通讯是否正常.心跳通讯是否正常不能简单地通过ping命令来检测.一定要使用traceroute默认是采用udp协议.每次执行traceroute会发起三次检测,*号表示通讯失败.

正常:

[root@rac1 ~]# traceroute rac2-priv

traceroute to rac2-priv (192.168.122.132), 30 hops max, 60 byte packets

1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; lsrac2-priv
(192.168.122.132)&nbsp; **0.802 ms &nbsp; 0.655 ms&nbsp; 0.636 ms**

不正常:

[root@lsrac1 ~]# traceroute rac2-priv

traceroute to rac2-priv (192.168.122.132), 30 hops max, 60 byte packets

&nbsp;1&nbsp; lsrac2-priv (192.168.122.132)&nbsp; 1.187 ms *** ***

&nbsp;如果经常出现* 则需要先检测心跳网络通讯是否正常.

&nbsp;

## 4、安装软件包

将操作系统盘放入光驱并挂载mount /dev/sr0 /mnt

或者可上传系统ISO，并挂载镜像mount -o loop xxx.iso /mnt

&nbsp;

配置yum安装程序&nbsp;

vi /etc/yum.repos.d/rhel.repo

输入如下内容：

[rhel]

name=rhel

baseurl=file:///mnt

enabled=1

gpgcheck=0

执行如下名命令允许yum默认同时安装32和64位的rpm包

echo&nbsp;&#39;multilib_policy=all&#39;&nbsp;&gt;&gt;&nbsp;/etc/yum.conf

可以执行如下命令安装所有需要的rpm

!["2.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180116131429_181.png%22/)

yum install elfutils-libelf-devel binutils compat-libcap* gcc gcc-c++ glibc
glibc-devel ksh&nbsp; libaio libaio-devel libgcc&nbsp; libstdc++&nbsp;
libstdc++-devel libXi libXtst make sysstat tiger* iscsi* &nbsp;-y

其中compat-libstdc++-33-3.2.3 在rhel7的镜像中默认没有，需要单独安装。

文件见附件

&nbsp;

 **参考文章：** **Requirements for Installing Oracle 11.2.0.4 RDBMS on OL7 or RHEL7
64-bit (x86-64) (** **文档** **ID 1962100.1)**

##  5、内核参数

 **/etc/sysctl.conf** **& nbsp;** **这里面的修改可以通过安装过程中运行**` **runfixup.sh**`
**脚本自动修改。**

 **在安装过程中，系统会提示。**

&nbsp;

Oracle Database 11 _g_ 第 2
版需要如下所示的内核参数设置。给出的值都是最小值，因此如果系统使用更大的值，则不要更改。其中shmmax和shmall要根据实际物理内存进行计算。

&nbsp;

vi /etc/sysctl.conf

&nbsp;

kernel.shmmax = 4294967295&nbsp;&nbsp;&nbsp;

#shmmax&nbsp; 1/2 of physical RAM( 单位B&nbsp;
)See&nbsp;[Note:567506.1](https://47.100.29.40/highgo_admin/%22https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1962100.1&id=567506.1")&nbsp;for
more information.

kernel.shmall = 2097152&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;

#shmall等于物理内存（单位B）/page_size ,而page_size大小是运行getconf PAGE_SIZE&nbsp;
命令获得的，一般是4096B&nbsp; &nbsp;See&nbsp;[Note
301830.1](https://47.100.29.40/highgo_admin/%22https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1962100.1&id=301830.1")&nbsp;for
more information.

kernel.shmmni = 4096

kernel.sem = 250 32000 100 128

fs.file-max = 6815744

net.ipv4.ip_local_port_range = 9000 65500

net.core.rmem_default=262144

net.core.rmem_max=4194304

net.core.wmem_default=262144

net.core.wmem_max=1048576

fs.aio-max-nr=1048576

&nbsp;

运行如下命令是参数立即生效。

[root@racnode1 ~]# sysctl -p

&nbsp;&nbsp;!["3.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180116131546_399.png%22/)

 **参考文章：** **& nbsp;&nbsp; Requirements for Installing Oracle 11.2.0.4 RDBMS
on OL7 or RHEL7 64-bit (x86-64) (** **文档** **ID 1962100.1)**

## 6 、设置oracle的shell限制：

vi /etc/security/limits.conf

#for oracle

grid&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
soft&nbsp;&nbsp;&nbsp; nofile&nbsp; 1024

grid&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
hard&nbsp;&nbsp;&nbsp; nofile&nbsp; 65536

grid&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;hard&nbsp;&nbsp;&nbsp;
stack&nbsp;&nbsp; 10240

oracle&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
soft&nbsp;&nbsp;&nbsp; nofile&nbsp; 1024

oracle&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
hard&nbsp;&nbsp;&nbsp; nofile&nbsp; 65536

oracle&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
hard&nbsp;&nbsp;&nbsp; stack&nbsp;&nbsp; 10240

修改使以上参数生效：

vi /etc/pam.d/login&nbsp;

添加如下行

session required pam_limits.so

 **注意》**

nproc参数的生效并不是在/etc/security/limits.conf里生效，是需要在

/etc/security/limits.d/20-nproc.conf &nbsp;文件中设置

参考：

 **Setting nproc values on Oracle Linux 6 for RHCK kernel (** **文档** **ID
2108775.1)**  
  
---  
  
&nbsp;  

[root@localhost limits.d]# cat 20-nproc.conf

# Default limit for number of user&#39;s processes to prevent

# accidental fork bombs.

# See rhbz #432903 for reasoning.

&nbsp;

*&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; soft&nbsp;&nbsp;&nbsp; nproc&nbsp;&nbsp;&nbsp;&nbsp; 1024

root&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; soft&nbsp;&nbsp;&nbsp;
nproc&nbsp;&nbsp;&nbsp;&nbsp; unlimited

&nbsp;

不要修改默认的 *&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
soft&nbsp;&nbsp;&nbsp; nproc&nbsp;&nbsp;&nbsp;&nbsp; 1024

&nbsp;

要添加oracle和grid 项

grid&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; soft&nbsp;&nbsp;&nbsp;&nbsp;
nproc&nbsp;&nbsp; 2047

grid&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; hard&nbsp;&nbsp;&nbsp; nproc&nbsp;&nbsp;
16384

oracle&nbsp;&nbsp;&nbsp; soft&nbsp;&nbsp;&nbsp;&nbsp; nproc&nbsp;&nbsp; 2047

oracle&nbsp;&nbsp;&nbsp; hard&nbsp;&nbsp;&nbsp; nproc&nbsp;&nbsp; 16384

nproc值表示该用户下的最大进程数max user processes如果业务进程较多，则可能因为进程达到上限而使得操作系统用户无法登陆。

查看当前用户的max user processes，可登录到指定的系统用户下

[root@localhost security]# ulimit -a

core file size&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (blocks,
-c) 0

data seg size&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
(kbytes, -d) unlimited

scheduling
priority&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
(-e) 0

file
size&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
(blocks, -f) unlimited

pending
signals&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
(-i) 23692

max locked memory&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (kbytes, -l) 32

max memory size&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (kbytes, -m)
unlimited

open
files&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
(-n) 1024

pipe size&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
(512 bytes, -p) 8

POSIX message queues&nbsp;&nbsp;&nbsp;&nbsp; (bytes, -q) 819200

real-time
priority&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
(-r) 0

stack
size&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
(kbytes, -s) 10240

cpu
time&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
(seconds, -t) unlimited

max user
processes&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
(-u) 23692

virtual memory&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (kbytes,
-v) unlimited

file
locks&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
(-x) unlimited

## 7、修改操作系统时间

不要在生产时段修改生产环境的时间！

检查多个服务器节点的操作系统时间是否一致。如果不一致要先手动修改。

如何同时修改两台或者多台主机的时间一模一样呢？

建议使用SecureCRT工具、

使用方法：先登录一台主机

!["4.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180116131906_736.png%22/)

  

然后登录第二台主机

!["5.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180116131919_291.png%22/)

  

打开查看菜单，勾选交互窗口

!["6.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180116131936_937.png%22/)

  

窗口下方出现交互窗口

!["7.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180116131956_129.png%22/)

在交互窗口上右键菜单，勾选发送交互到所有会话。（此时要注意这个CRT窗口必须只能有RAC的两台服务器，不能有到其他主机的远程连接会话）

!["8.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180116132021_492.png%22/)

&nbsp;

然后此时在交互窗口里输入的命令回车后都会自动发送到所有主机上执行。

linx修改时间的命令是&nbsp; ：年月日 时分秒

[root@rhel ~]# date -s &quot;20100405 14:31:00&quot;

&nbsp;

关闭时间同步服务，默认使用ctssd进行节点间时间同步。

 **Unable to Configure NTP after Oracle Linux 7 Installation (** **文档** **ID
1995703.1)**

 **rhel7** **默认不安装** **ntp** **服务** **，而是被** **chronyd** **服务代替。**

禁用chronyd

systemctl stop chronyd

systemctl disable chronyd

如果安装有NTP服务，则禁用

/bin/systemctl stop&nbsp; ntpd.service

systemctl disable ntpd.service

mv /etc/ntp.conf /etc/ntp.conf.bak

一定要保证节点间时间同步，但是不能配置ntp，否则会导致11g的ctssd处于旁观模式。如果客户严格要求和北京时间一致，则考虑让客户提供时间服务器，然后再采用NTP或chronyd和其时间服务器同步。如果配置NTP注意参数
-x 保证时间不能向回调，关于NTP配置此处不做详细解释。

&nbsp;

&nbsp;

&nbsp;

## 8、修改主机名

&nbsp;

查看主机名：

[root@localhost ~]# hostnamectl status

&nbsp;&nbsp; Static hostname: localhost.localdomain

Transient hostname: rac1

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Icon name: computer

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Chassis: n/a

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Machine ID:
05683ff226ee4229b62037ea081b4697

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Boot ID:
a1052f601184411a86d78fee5f1bff7c

&nbsp;&nbsp;&nbsp; Virtualization: vmware

&nbsp; Operating System: Red Hat Enterprise Linux Server 7.1 (Maipo)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; CPE OS Name:
cpe:/o:redhat:enterprise_linux:7.1:GA:server

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Kernel:
Linux 3.10.0-229.el7.x86_64

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Architecture: x86_64

修改主机名：

[root@localhost ~]#hostnamectl&nbsp;set-hostname&nbsp; **rac1**

&nbsp;

注意主机名不能过长,不能超过8个字符，且不能有下划线等特殊符号，不要使用大写字母，建议使用小写字母即可。

&nbsp;

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

|  
|  
  
  
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

ASM 的 &nbsp; SYSOPER

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
  
&nbsp;

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

  * ASM 操作员组（OSOPER &nbsp; &nbsp; &nbsp;for ASM，一般为 asmoper）

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

&nbsp;

# passwd grid

# passwd oracle

创建grid目录

mkdir -p&nbsp; /u01/app/11.2.0/grid

chown grid:oinstall /u01/&nbsp; -R

chmod 775 /u01/ -R

创建oracle目录

mkdir -p&nbsp; /u02/app/oracle/product/11.2.0/db_home&nbsp;

chown oracle:oinstall /u02/ -R

chmod&nbsp; 775 /u02/ -R

修改grid用户环境变量

登录rac节点1

su - grid

vi .bash_profile

ORACLE_SID=+ASM1; export ORACLE_SID

ORACLE_BASE=/u01/app/grid; export ORACLE_BASE

ORACLE_HOME=/u01/app/11.2.0/grid; export ORACLE_HOME

ORACLE_PATH=/u01/app/oracle/common/oracle/sql; export ORACLE_PATH

umask 022

PATH=$ORACLE_HOME/bin:$PATH:$HOME/bin:$ORACLE_PATH

export PATH

 **注意：** **grid** **用户环境变量** **ORACLE_HOME** **不在** **ORACLE_BASE** **目录下**
**& nbsp;**

 **su - oracle**

修改oracle 用户环境变量,其中ORACLE_SID ，让开发商定好数据库名称，SID后面分别添加1和2。

su - oracle

vi .bash_profile

export ORACLE_SID=orcl1

export ORACLE_BASE=/u02/app/oracle

export ORACLE_HOME=/u02/app/oracle/product/11.2.0/db_home&nbsp;

PATH=$ORACLE_HOME/bin:$PATH:$HOME/bin

export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$ORACLE_HOME/rdbms/lib:/lib:/usr/lib

umask 022

export PATH

&nbsp;

登录RAC节点2

su - grid

vi .bash_profile

ORACLE_SID=+ASM2; export ORACLE_SID

ORACLE_BASE=/u01/app/grid; export ORACLE_BASE

ORACLE_HOME=/u01/app/11.2.0/grid; export ORACLE_HOME

ORACLE_PATH=/u01/app/oracle/common/oracle/sql; export ORACLE_PATH

umask 022

PATH=$ORACLE_HOME/bin:$PATH:$HOME/bin:$ORACLE_PATH

export PATH

 **注意：** **grid** **用户环境变量** **ORACLE_HOME** **不在** **ORACLE_BASE** **目录下**
**& nbsp;**

 **su - oracle**

修改oracle 用户环境变量

su - oracle

vi .bash_profile

export ORACLE_SID=orcl2

export ORACLE_BASE=/u02/app/oracle

export ORACLE_HOME=/u02/app/oracle/product/11.2.0/db_home&nbsp;

PATH=$ORACLE_HOME/bin:$PATH:$HOME/bin

export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$ORACLE_HOME/rdbms/lib:/lib:/usr/lib

umask 022

export PATH

## 10、ASM配置共享磁盘

参考其他节点的共享磁盘配置，确保与其他节点一致。

### 10.1使用linux操作系统自带multipath多路径软件的情况：

 **参考文章：**

 **Deploying Oracle Database 12c on** **Red Enterprise Linux 7**

[ https://www.redhat.com/en/files/resources/en-rhel-deploying-
Oracle-12c-rhel-7.pdf](https://47.100.29.40/highgo_admin/%22https://www.redhat.com/en/files/resources/en-
rhel-deploying-Oracle-12c-rhel-7.pdf%22)

 **参考文章：** **How to set udev rules in OL7 related to ASM on multipath disks
(** **文档** **ID 2101679.1)**

生成multipath.conf文件

/sbin/mpathconf --enable

查询磁盘设备的wwid

for i in `cat /proc/partitions | awk &#39;{print $4}&#39; |grep sd | grep
[a-z]$`; do echo &quot;### $i: ` /usr/lib/udev/scsi_id -g -u&nbsp; -d&nbsp;
/dev/$i`&quot;; done

&nbsp;

多路径配置文件内容/etc/multipath.conf，修改wwid和别名alias&nbsp;&nbsp;&nbsp;

# cat &nbsp;&nbsp;/etc/multipath.conf  
&nbsp;defaults {

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
polling_interval&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 5

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; path_grouping_policy&nbsp;&nbsp;&nbsp;
failover

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
prio&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
const

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
path_checker&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
directio

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rr_min_io&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1000

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rr_weight&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
uniform

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
failback&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
manual

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
no_path_retry&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; fail

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
user_friendly_names&nbsp;&nbsp;&nbsp;&nbsp; yes

}

&nbsp;

blacklist {

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; devnode
&quot;^(ram|raw|loop|fd|md|dm-|sr|scd|st)[0-9]*&quot;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; devnode &quot;^hd[a-z]&quot;

&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;devnode
&quot;^cciss!c[0-9]d[0-9]*&quot;

}

&nbsp;

multipaths {

multipath {

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
wwid&nbsp;&nbsp;&nbsp; 14f504e46494c45525743714d4f6a2d6437466f2d30435362

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
alias&nbsp;&nbsp; fra

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
path_grouping_policy failover

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; multipath {

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
wwid&nbsp;&nbsp;&nbsp; 14f504e46494c4552664857314b622d576f63582d6f324743

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
alias&nbsp;&nbsp; data

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
path_grouping_policy failover

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; multipath {

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
wwid&nbsp;&nbsp;&nbsp; 14f504e46494c45524f616d324a4f2d463255562d42764747

&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;alias&nbsp;&nbsp;
ocr1

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
path_grouping_policy failover

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; multipath {

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
wwid&nbsp;&nbsp;&nbsp; 14f504e46494c455230336f4738382d684268682d66306a32

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
alias&nbsp;&nbsp; ocr2

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
path_grouping_policy failover

&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;}

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; multipath {

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
wwid&nbsp;&nbsp;&nbsp; 14f504e46494c455241653457776c2d527a4c712d6c625178

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
alias&nbsp;&nbsp; ocr3

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
path_grouping_policy failover

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; multipath {

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
wwid&nbsp;&nbsp;&nbsp; 14f504e46494c45524146554f7a732d6b6443752d6e4f7956

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
alias&nbsp;&nbsp; ocr4

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
path_grouping_policy failover

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; multipath {

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
wwid&nbsp;&nbsp;&nbsp; 14f504e46494c4552416a4e6938672d363876662d6d636735

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
alias&nbsp;&nbsp; ocr5

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
path_grouping_policy failover

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }

&nbsp;

}

启动、查看multipathd.service状态

systemctl start multipathd.service

systemctl status multipathd.service

将multipathd.service设置为开机自启

systemctl enable multipathd.service

查看多路径状态

multipath –ll

&nbsp;

查看多路径磁盘对应的dm-X 名称

ls -l /dev/mapper/|grep dm*

将共享存储磁盘列表抓取出来，通过notepad++工具进行列编辑

注意不要修改RAC非存储磁盘的权限。

 _因为_ _rhel 6_ _、_ _rhel7_ _多路径和_ _5_ _不一样，_ _/dev/mapper_ _下不再是块设备磁盘，而是软连接。_

 _dm-X_ _多路径绑定出来后，不同节点生成的_ _dm-X_ _对应的存储磁盘有可能不一致。_

 _因此参考_ _mos_ _文章：_

 **参考文章： How to set udev rule for setting the disk permission on ASM disks
when using multipath on OL 6.x (文档 ID 1521757.1)**

 **使用 udev修改磁盘权限和属主**

vi&nbsp; /etc/udev/rules.d/12-dm-permissions-highgo.rules

添加如下内容，根据实际情况进行调整：

ENV{DM_NAME}==&quot;ocr1&quot;, OWNER:=&quot;grid&quot;,
GROUP:=&quot;asmadmin&quot;, MODE:=&quot;660&quot;,
SYMLINK+=&quot;mapper/$env{DM_NAME}&quot;

ENV{DM_NAME}==&quot;ocr2&quot;, OWNER:=&quot;grid&quot;,
GROUP:=&quot;asmadmin&quot;, MODE:=&quot;660&quot;,
SYMLINK+=&quot;mapper/$env{DM_NAME}&quot;

ENV{DM_NAME}==&quot;ocr3&quot;, OWNER:=&quot;grid&quot;,
GROUP:=&quot;asmadmin&quot;, MODE:=&quot;660&quot;,
SYMLINK+=&quot;mapper/$env{DM_NAME}&quot;

ENV{DM_NAME}==&quot;ocr4&quot;, OWNER:=&quot;grid&quot;,
GROUP:=&quot;asmadmin&quot;, MODE:=&quot;660&quot;,
SYMLINK+=&quot;mapper/$env{DM_NAME}&quot;

ENV{DM_NAME}==&quot;ocr5&quot;, OWNER:=&quot;grid&quot;,
GROUP:=&quot;asmadmin&quot;, MODE:=&quot;660&quot;,
SYMLINK+=&quot;mapper/$env{DM_NAME}&quot;

ENV{DM_NAME}==&quot;data&quot;, OWNER:=&quot;grid&quot;,
GROUP:=&quot;asmadmin&quot;, MODE:=&quot;660&quot;,
SYMLINK+=&quot;mapper/$env{DM_NAME}&quot;

ENV{DM_NAME}==&quot;fra&quot;, OWNER:=&quot;grid&quot;,
GROUP:=&quot;asmadmin&quot;, MODE:=&quot;660&quot;,
SYMLINK+=&quot;mapper/$env{DM_NAME}&quot;

&nbsp;

执行以下命令是配置生效 ，rhel7 没有star_udev命令

# /sbin/udevadm control --reload-rules

# /sbin/udevadm trigger --type=devices --action=change

  
**参考文章： How to set udev rules in OL7 related to ASM on multipath disks (文档 ID
2101679.1)**

但经过试验，该重新加载的命令并不一定能够保证重新加载udev策略。

可以使用systemctl restart systemd-udev-trigger.service重启service可以重新加载策略。

 **如果是现有生产环境添加磁盘等操作，不建议使用 start_udev或者systemctl restart systemd-udev-
trigger.service来在线添加新磁盘，建议手动在线修改，并安排停机时间重启确认。**

ls –l /dev/dm-*&nbsp; 检查磁盘属主和权限是否正确。

&nbsp;

修改&nbsp;/etc/systemd/system/sysinit.target.wants/multipathd.service

将PIDFile=/var/run/multipathd/multipathd.pid

改为

PIDFile=/run/multipathd.pid

 **参考文章：**

 **Oracle Linux 7: Multipathd Does Not Start Automatically on System Boot (**
**文档 ID 2093615.1)**

### 10.2使用存储专用多路径软件的情况：

此种情况下磁盘的名称，以及磁盘唯一性的确认都是存储工程来保障的。

如emc的存储多路径聚合软件聚合后的盘一般是/dev/emcpowera 、/dev/emcpowerb等

只需要 存储工程师提供给我们盘名，我们进行ASM层面的操作即可。

华为多路径聚合磁盘后磁盘名称依然是/dev/sdb 、/dev/sdc&nbsp; 等， kernel == &quot;sdb&quot;即可。

vi /etc/udev/rules.d/99-asm-highgo.rules

ACTION==&quot;add&quot;, KERNEL==&quot;emcpowera&quot;, RUN+=&quot;/bin/raw
/dev/raw/raw1 %N&quot;

ACTION==&quot;add&quot;, KERNEL==&quot;emcpowerb&quot;, RUN+=&quot;/bin/raw
/dev/raw/raw2 %N&quot;

ACTION==&quot;add&quot;, KERNEL==&quot;emcpowerc&quot;, RUN+=&quot;/bin/raw
/dev/raw/raw3 %N&quot;

ACTION==&quot;add&quot;, KERNEL==&quot;emcpowerd&quot;, RUN+=&quot;/bin/raw
/dev/raw/raw4 %N&quot;

ACTION==&quot;add&quot;, KERNEL==&quot;emcpowere&quot;, RUN+=&quot;/bin/raw
/dev/raw/raw5 %N&quot;

ACTION==&quot;add&quot;, KERNEL==&quot;emcpowerf&quot;, RUN+=&quot;/bin/raw
/dev/raw/raw6 %N&quot;

&nbsp;

KERNEL==&quot;raw1&quot;,OWNER=&quot;grid&quot;,GROUP=&quot;asmadmin&quot;,
MODE=&quot;660&quot;

KERNEL==&quot;raw2&quot;,OWNER=&quot;grid&quot;,GROUP=&quot;asmadmin&quot;,
MODE=&quot;660&quot;

KERNEL==&quot;raw3&quot;,OWNER=&quot;grid&quot;,GROUP=&quot;asmadmin&quot;,
MODE=&quot;660&quot;

KERNEL==&quot;raw4&quot;,OWNER=&quot;grid&quot;,GROUP=&quot;asmadmin&quot;,
MODE=&quot;660&quot;

KERNEL==&quot;raw5&quot;,OWNER=&quot;grid&quot;,GROUP=&quot;asmadmin&quot;,
MODE=&quot;660&quot;

KERNEL==&quot;raw6&quot;,OWNER=&quot;grid&quot;,GROUP=&quot;asmadmin&quot;,
MODE=&quot;660&quot;

重启udev守护进程

执行以下命令是配置生效 ，rhel7 没有star_udev命令

# /sbin/udevadm control --reload-rules

# /sbin/udevadm trigger --type=devices --action=change

  
**参考文章： How to set udev rules in OL7 related to ASM on multipath disks (文档 ID
2101679.1)**

但经过试验，该重新加载的命令并不一定能够保证重新加载udev策略。

可以使用systemctl restart systemd-udev-trigger.service重启service可以重新加载策略。

&nbsp;

检查是否生成ls -l /dev/raw/raw*磁盘,以及磁盘权限是否是grid:asmadmin

### 10.3创建用于ASM访问的磁盘软链接

无论磁盘如何采用何种形式管理，一定要创建软连接，放到/u10/asm-disk中

mkdir /u01/asm-disk/

举例如：

ln -s /dev/mapper/ocr1 /u01/asm-disk/ocr1

ln -s /dev/mapper/ocr2 /u01/asm-disk/ocr2

ln -s /dev/mapper/ocr3 /u01/asm-disk/ocr3

ln -s /dev/mapper/ocr4 /u01/asm-disk/ocr4

ln -s /dev/mapper/ocr5 /u01/asm-disk/ocr5

ln -s /dev/mapper/data /u01/asm-disk/data

ln -s /dev/mapper/fra&nbsp; /u01/asm-disk/fra

## 11、配置SSH

1. 对 grid 和 oracle 用户配置 SSH，具体步骤参考下面的文章:

NOTE: 300548.1 - How To Configure SSH for a RAC Installation

或者

Oracle Grid Infrastructure Installation Guide 11g Release 2 (11.2) for Linux

[http://docs.oracle.com/cd/E11882_01/install.112/e22489/manpreins.htm#CWLIN407](https://47.100.29.40/highgo_admin/%22http://docs.oracle.com/cd/E11882_01/install.112/e22489/manpreins.htm#CWLIN407")

或者

采用oracle自带ssh脚本：

见附件

./sshUserSetup.sh -user 用户名 -hosts &quot;主机名1 主机名2 主机名3 。。。&quot; -advanced
-noPromptPassphrase

2. 测试验证 SSH configuration。

## 12、使用 CVU 检查新加节点的硬件和 OS 环境

在现有节点上运行如下的命令,rac3是待添加主机名：

$ cluvfy stage -post hwos -n rac3 -verbose

$ cluvfy comp peer -refnode rac1 -n rac3 -orainv oinstall -osdba oinstall-
verbose

$ cluvfy stage -pre nodeadd -n rac3 -verbose

注意：如果出现警告/错误信息，请在添加节点前修复。

## 13、备份 OCR

在添加节点前，建议手动备份 OCR （GRID 每 4 个小时也会自动备份 OCR），目的是如果出现某些问题，我们可以恢复到添加节点前的状态：

$su - root

$GRID_HOME/bin/ocrdump /tmp/ocrdump_1nodes.bak

## 14、添加cluster RAC

不使用GNS的情况

(GNS--Grid Naming Service,与SCAN搭配使用，可以不配置RAC的IP地址，使用DHCP服务来分配IP)

$ GI_HOME/oui/bin/addNode.sh -silent &quot;CLUSTER_NEW_NODES={rac3}&quot;
&quot;CLUSTER_NEW_VIRTUAL_HOSTNAMES={rac3-vip}&quot;

如果在之前检查的时候有错误需要忽略，需要先添加如下环境变量：

$ export IGNORE_PREADDNODE_CHECKS=Y

使用GNS的情况是:

$ GI_HOME/oui/bin/addNode.sh -silent “CLUSTER_NEW_NODES={&lt;new node&gt;}”

&nbsp;

在执行完之后会提醒在新节点上运行root脚本,按照提示执行就行

检查确认cluster已经安装完成

$GI_HOME/bin/cluvfy stage -post nodeadd -n &lt;new node&gt; -verbose

修改一个权限:

使用root用户

cd $ORACLE_HOME/bin

chgrp asmadmin oracle

chmod 6751 oracle

ls -l oracle

## 15、添加database software

从已经存在的节点上使用oracle用户执行:

$&gt; $ORACLE_HOME/oui/bin/addNode.sh -silent &quot;CLUSTER_NEW_NODES={&lt;new
node&gt;}&quot;

执行完成之后,根据提示在新节点上执行root脚本。

## 16、添加DB instance

方案1：

$ORACLE_HOME/bin/dbca -silent -addInstance -nodeList &lt;new node&gt; -gdbName
&lt;db name&gt; -instanceName &lt;new instance&gt; -sysDBAUserName sys
-sysDBAPassword &lt;sys password&gt;

方案2：

1.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 在节点 1 以 oracle 用户运行 dbca

!["9.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180116132315_557.png%22/)

2.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 选择 RAC database

!["10.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180116132327_515.png%22/)

3.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;

!["11.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180116132339_981.png%22/)

4.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 选择 add an instance

!["12.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180116132352_239.png%22/)

5.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 当前的 RAC database

!["13.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180116132407_33.png%22/)

6.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 当前已有的数据库实例

!["14.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180116132421_430.png%22/)

7.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 新数据库实例

!["15.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180116132441_625.png%22/)

8.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 实例 3 的 undo tablespace 和
redo log 信息：

!["16.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180116132500_789.png%22/)

9.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 总结

!["17.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180116132522_34.png%22/)

10.&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;

!["18.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180116132537_487.png%22/)

11.&nbsp;&nbsp;&nbsp;&nbsp; 完成

12.&nbsp;&nbsp;&nbsp;&nbsp; 检查集群和数据库是否正常。

# 删除节点

## 1、备份 OCR

在添加节点前，建议手动备份 OCR （GRID 每 4 个小时也会自动备份 OCR），目的是如果出现某些问题，我们可以恢复到添加节点前的状态：

$su - root

$GRID_HOME/bin/ocrdump /tmp/ocrdump_1nodes.bak

## 2、删除DB instance

方案1：

oracle用户在保留节点使用dbca的静默模式进行删除实例：

$ dbca -silent -deleteInstance [-nodeList node_name] -gdbName gdb_name
-instanceName instance_name -sysDBAUserName sys -sysDBAPassword password

方案2：

1.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; oracle用户在保留节点运行dbca：

!["19.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180116132609_759.png%22/)

2.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;

!["20.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180116132625_9.png%22/)

3.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;

!["21.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180116132653_132.png%22/)

4.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;

!["22.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180116132708_693.png%22/)

5.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;

!["23.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180116132727_398.png%22/)

6.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 选择准备删除的数据库实例

!["24.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180116132739_47.png%22/)

7.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;

!["25.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180116132752_986.png%22/)

8.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;

!["26.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180116132837_168.png%22/)

9.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;

!["27.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180116132850_555.png%22/)

10.&nbsp;&nbsp; 完成

11.&nbsp;&nbsp; 禁用被删除实例的线程

SQL&gt; ALTER DATABASE DISABLE THREAD 3;

12.&nbsp;&nbsp; 检查

[grid@rac001 ~]$ srvctl config database -d orcl

## 3、移除RAC

1 禁用将被删除节点上的监听：

$ srvctl disable listener -l listener_name -n name_of_node_to_delete

$ srvctl stop listener -l listener_name -n name_of_node_to_delete

2更新被删节点清单

在要删除的节点上的$ORACLE_HOME/oui/bin中运行以下命令以更新该节点上的清单：

$ ./runInstaller -updateNodeList ORACLE_HOME=Oracle_home_location
&quot;CLUSTER_NODES={name_of_node_to_delete}&quot; -local

3对于共享主节点的情况（一般的都不是这种）

对于共享主节点，通过在要删除的每个节点上的$ORACLE_HOME/oui/bin目录中运行以下命令来分离节点，而不是卸载节点：

$ ./runInstaller -detachHome ORACLE_HOME = Oracle_home_location

4.用oracle用户在要删除的节点运行脚本

$ORACLE_HOME/deinstall/deinstall -local

5. 用oracle用户从群集中任何一个剩余节点上的$ORACLE_HOME/oui/bin目录运行以下命令，以更新这些节点的清单，并指定以逗号分隔的剩余节点名称列表：

$ ./runInstaller -updateNodeList ORACLE_HOME=Oracle_home_location
&quot;CLUSTER_NODES={remaining_node_list}&quot;

6.在GRID层面删除节点

在要删除的节点用root执行：

# $GRID_HOME/crs/install/rootcrs.pl -deconfig -deinstall -force

在要保留节点用root执行：

# $GRID_HOME/bin/crsctl delete node -n rac3

至此rac3从集群中移除完毕。

检查集群状态。

# 添加/删除节点总结

1. 添加节点分为 3 个阶段，第一阶段是复制 GIRD HOME 到新节点，第二阶段是复制 RDBMS HOME 到新节点，第三阶段是 DBCA 添加数据库实例。

2. 第一阶段主要工作是复制 GIRD HOME 到新节点，配置 GRID， 并且启动 GRID， 同时更新OCR 信息， 更新 inventory 信息。

3. 第二阶段主要工作是复制 RDBMS HOME 到新节点，更新 inventory 信息。

4. 第三阶段主要工作是 DBCA 创建新的数据库实例（包括创建 undo 表空间， redo log，初始化参数等），更新 OCR 信息（包括注册新的数据库实例等）。

5. 在添加/删除节点的过程中，原有的节点一直是 online 状态，不需要停机，对客户端业

务没有影响。

6. 添加/删除节点前，备份 OCR （默认每 4 小时自动备份 ocr），在某些情况下添加/删除节点失败，可以通过恢复原来的 OCR 来解决问题。

7. 新节点的 ORACLE_BASE 和 ORACLE_HOME 路径在添加过程中会自动创建，无需手动创建。

8. 正常安装 11.2 GRID 时， OUI 界面提供 SSH 配置功能，但是添加节点脚本 addNode.sh 没有这个功能，因此需要手动配置 oracle 用户和 grid 用户的 SSH 用户等效性。此外，在配置完等效性后，务必手动对每个节点的公有IP和私有IP进行ssh测试，确保不需要输入yes或者密码。检查等效性如果不通过，务必解决此问题。

# 常见问题

1 CVU 报错 PRVF-4007

运行 CVU 时报 PRVF-4007 : User equivalence check failed，

原因是没有为新添加节点的 grid 用户和 oracle 用户配置用户等效性。

2 复制/etc/oratab 失败

有些情况下从节点 1 复制/etc/oratab 到节点 3 时，可能会失败，原因是权限问题，可以手动修改/etc/oratab 文件或者修改权限

3 RDBMS_oracle_home/oui/bin/addNode.sh 报没有权限创建文件

如果是先运行了 grid_home/root.sh 脚本，那么会将 ORACLE BASE 权限改为 root 用户，

因此后执行 rdbms 下面的 addNode.sh 时就会由于权限不足而失败。

解决方法有 2 个：

方法 1：后运行 grid_home/root.sh 脚本，先运行 rdbms 下面的 addNode.sh。

方法 2：手动修改 oracle base 权限，安装结束后再修改回来。

# 参考文档

Oracle Clusterware Administration and Deployment Guide 11g Release 2 (11.2)

&gt;&gt;&gt;&gt; 4 Adding and Deleting Cluster Nodes

http://docs.oracle.com/cd/E11882_01/rac.112/e16794/adddelclusterware.htm#CHDFIAIE

Oracle Real Application Clusters Administration and Deployment Guide 11g
Release 2 (11.2)

&gt;&gt;&gt;&gt; 10 Adding and Deleting Oracle RAC from Nodes on Linux and
UNIX Systems

http://docs.oracle.com/cd/E11882_01/rac.112/e16795/adddelunix.htm#BEICADHD

  

" name="docDetail" type="hidden">


---
### ATTACHMENTS
[007dcaced306b778f9b56384c09ef09b]: media/Oracle_RAC_添加删除节点更换设备指导书.html
[Oracle_RAC_添加删除节点更换设备指导书.html](media/Oracle_RAC_添加删除节点更换设备指导书.html)
>hash: 007dcaced306b778f9b56384c09ef09b  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle RAC 添加删除节点更换设备指导书_files\20180116132837_168.png  

[0edf1f3cbc8ac4e6212f16427cb8d575]: media/Oracle_RAC_添加删除节点更换设备指导书-2.html
[Oracle_RAC_添加删除节点更换设备指导书-2.html](media/Oracle_RAC_添加删除节点更换设备指导书-2.html)
>hash: 0edf1f3cbc8ac4e6212f16427cb8d575  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle RAC 添加删除节点更换设备指导书_files\20180116132522_34.png  

[16f2c50c5ad4818b016010ce74a0448a]: media/Oracle_RAC_添加删除节点更换设备指导书-3.html
[Oracle_RAC_添加删除节点更换设备指导书-3.html](media/Oracle_RAC_添加删除节点更换设备指导书-3.html)
>hash: 16f2c50c5ad4818b016010ce74a0448a  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle RAC 添加删除节点更换设备指导书_files\20180116132625_9.png  

[313e6669fa5cfb6c9a7b190b636fe162]: media/Oracle_RAC_添加删除节点更换设备指导书-4.html
[Oracle_RAC_添加删除节点更换设备指导书-4.html](media/Oracle_RAC_添加删除节点更换设备指导书-4.html)
>hash: 313e6669fa5cfb6c9a7b190b636fe162  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle RAC 添加删除节点更换设备指导书_files\20180116131429_181.png  

[420c1379d4b05ed9d40818a6a55bbeba]: media/Oracle_RAC_添加删除节点更换设备指导书-5.html
[Oracle_RAC_添加删除节点更换设备指导书-5.html](media/Oracle_RAC_添加删除节点更换设备指导书-5.html)
>hash: 420c1379d4b05ed9d40818a6a55bbeba  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle RAC 添加删除节点更换设备指导书_files\20180116132441_625.png  

[52d44f0c410ae5c12e26eee0906ea090]: media/Oracle_RAC_添加删除节点更换设备指导书-6.html
[Oracle_RAC_添加删除节点更换设备指导书-6.html](media/Oracle_RAC_添加删除节点更换设备指导书-6.html)
>hash: 52d44f0c410ae5c12e26eee0906ea090  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle RAC 添加删除节点更换设备指导书_files\20180116132739_47.png  

[55e51b1d4e4bece036a5cfe3b295c938]: media/Oracle_RAC_添加删除节点更换设备指导书-7.html
[Oracle_RAC_添加删除节点更换设备指导书-7.html](media/Oracle_RAC_添加删除节点更换设备指导书-7.html)
>hash: 55e51b1d4e4bece036a5cfe3b295c938  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle RAC 添加删除节点更换设备指导书_files\20180116132609_759.png  

[61794ba1a4a77d7548a086e80485828e]: media/Oracle_RAC_添加删除节点更换设备指导书-8.html
[Oracle_RAC_添加删除节点更换设备指导书-8.html](media/Oracle_RAC_添加删除节点更换设备指导书-8.html)
>hash: 61794ba1a4a77d7548a086e80485828e  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle RAC 添加删除节点更换设备指导书_files\20180116131936_937.png  

[62cf83adfb748fbddf702a4317b312a4]: media/Oracle_RAC_添加删除节点更换设备指导书-9.html
[Oracle_RAC_添加删除节点更换设备指导书-9.html](media/Oracle_RAC_添加删除节点更换设备指导书-9.html)
>hash: 62cf83adfb748fbddf702a4317b312a4  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle RAC 添加删除节点更换设备指导书_files\20180116132327_515.png  

[6e7d851d9722bc706dea6a180de4c98d]: media/Oracle_RAC_添加删除节点更换设备指导书-10.html
[Oracle_RAC_添加删除节点更换设备指导书-10.html](media/Oracle_RAC_添加删除节点更换设备指导书-10.html)
>hash: 6e7d851d9722bc706dea6a180de4c98d  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle RAC 添加删除节点更换设备指导书_files\20180116132352_239.png  

[7c146d143810c9267dedb0f876c3ba85]: media/Oracle_RAC_添加删除节点更换设备指导书-11.html
[Oracle_RAC_添加删除节点更换设备指导书-11.html](media/Oracle_RAC_添加删除节点更换设备指导书-11.html)
>hash: 7c146d143810c9267dedb0f876c3ba85  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle RAC 添加删除节点更换设备指导书_files\20180116131338_436.png  

[7f025a17697ee15eb3197c61326b203b]: media/Oracle_RAC_添加删除节点更换设备指导书-12.html
[Oracle_RAC_添加删除节点更换设备指导书-12.html](media/Oracle_RAC_添加删除节点更换设备指导书-12.html)
>hash: 7f025a17697ee15eb3197c61326b203b  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle RAC 添加删除节点更换设备指导书_files\11947ec6e06f4dd6a765bcc48c4fc88d.png  

[9f3898b8748c90ceb50a82c1457b9998]: media/Oracle_RAC_添加删除节点更换设备指导书-13.html
[Oracle_RAC_添加删除节点更换设备指导书-13.html](media/Oracle_RAC_添加删除节点更换设备指导书-13.html)
>hash: 9f3898b8748c90ceb50a82c1457b9998  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle RAC 添加删除节点更换设备指导书_files\20180116132653_132.png  

[a732475156f5cdca71585b89bf940a8b]: media/Oracle_RAC_添加删除节点更换设备指导书-14.html
[Oracle_RAC_添加删除节点更换设备指导书-14.html](media/Oracle_RAC_添加删除节点更换设备指导书-14.html)
>hash: a732475156f5cdca71585b89bf940a8b  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle RAC 添加删除节点更换设备指导书_files\20180116132708_693.png  

[a86cfbc88db6ff546adcdd1b93d8d8dd]: media/Oracle_RAC_添加删除节点更换设备指导书-15.html
[Oracle_RAC_添加删除节点更换设备指导书-15.html](media/Oracle_RAC_添加删除节点更换设备指导书-15.html)
>hash: a86cfbc88db6ff546adcdd1b93d8d8dd  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle RAC 添加删除节点更换设备指导书_files\20180116131546_399.png  

[a988d87fcffffb19a75f5dd64add930f]: media/Oracle_RAC_添加删除节点更换设备指导书-16.html
[Oracle_RAC_添加删除节点更换设备指导书-16.html](media/Oracle_RAC_添加删除节点更换设备指导书-16.html)
>hash: a988d87fcffffb19a75f5dd64add930f  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle RAC 添加删除节点更换设备指导书_files\20180116132500_789.png  

[aa94ddc7f2e4804403cb295d6f024129]: media/Oracle_RAC_添加删除节点更换设备指导书-17.html
[Oracle_RAC_添加删除节点更换设备指导书-17.html](media/Oracle_RAC_添加删除节点更换设备指导书-17.html)
>hash: aa94ddc7f2e4804403cb295d6f024129  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle RAC 添加删除节点更换设备指导书_files\20180116132537_487.png  

[b7b4b191d31ae315689cf37134c4ad1d]: media/Oracle_RAC_添加删除节点更换设备指导书-18.html
[Oracle_RAC_添加删除节点更换设备指导书-18.html](media/Oracle_RAC_添加删除节点更换设备指导书-18.html)
>hash: b7b4b191d31ae315689cf37134c4ad1d  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle RAC 添加删除节点更换设备指导书_files\20180116132727_398.png  

[ba058fddf1f46af542c661b58202bc14]: media/Oracle_RAC_添加删除节点更换设备指导书-19.html
[Oracle_RAC_添加删除节点更换设备指导书-19.html](media/Oracle_RAC_添加删除节点更换设备指导书-19.html)
>hash: ba058fddf1f46af542c661b58202bc14  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle RAC 添加删除节点更换设备指导书_files\20180116132315_557.png  

[be973cef48245887ae80ec9cb981f734]: media/Oracle_RAC_添加删除节点更换设备指导书-20.html
[Oracle_RAC_添加删除节点更换设备指导书-20.html](media/Oracle_RAC_添加删除节点更换设备指导书-20.html)
>hash: be973cef48245887ae80ec9cb981f734  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle RAC 添加删除节点更换设备指导书_files\20180116132752_986.png  

[c24cb351952cb4edf5f29b17fbc41a11]: media/Oracle_RAC_添加删除节点更换设备指导书-21.html
[Oracle_RAC_添加删除节点更换设备指导书-21.html](media/Oracle_RAC_添加删除节点更换设备指导书-21.html)
>hash: c24cb351952cb4edf5f29b17fbc41a11  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle RAC 添加删除节点更换设备指导书_files\20180116131956_129.png  

[d89763cb69065159651cf3573141c87a]: media/Oracle_RAC_添加删除节点更换设备指导书-22.html
[Oracle_RAC_添加删除节点更换设备指导书-22.html](media/Oracle_RAC_添加删除节点更换设备指导书-22.html)
>hash: d89763cb69065159651cf3573141c87a  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle RAC 添加删除节点更换设备指导书_files\20180116132407_33.png  

[db453cd32e7a906fdc2c1db6d456a877]: media/Oracle_RAC_添加删除节点更换设备指导书-23.html
[Oracle_RAC_添加删除节点更换设备指导书-23.html](media/Oracle_RAC_添加删除节点更换设备指导书-23.html)
>hash: db453cd32e7a906fdc2c1db6d456a877  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle RAC 添加删除节点更换设备指导书_files\20180116131919_291.png  

[e013c7cd12ab5658dacffd84a3df5da5]: media/Oracle_RAC_添加删除节点更换设备指导书-24.html
[Oracle_RAC_添加删除节点更换设备指导书-24.html](media/Oracle_RAC_添加删除节点更换设备指导书-24.html)
>hash: e013c7cd12ab5658dacffd84a3df5da5  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle RAC 添加删除节点更换设备指导书_files\20180116131906_736.png  

[e9e7b4cd6aa65e854324815a35147a40]: media/Oracle_RAC_添加删除节点更换设备指导书-25.html
[Oracle_RAC_添加删除节点更换设备指导书-25.html](media/Oracle_RAC_添加删除节点更换设备指导书-25.html)
>hash: e9e7b4cd6aa65e854324815a35147a40  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle RAC 添加删除节点更换设备指导书_files\20180116132021_492.png  

[f690a156c7a0e7bf51180864e0d1de04]: media/Oracle_RAC_添加删除节点更换设备指导书-26.html
[Oracle_RAC_添加删除节点更换设备指导书-26.html](media/Oracle_RAC_添加删除节点更换设备指导书-26.html)
>hash: f690a156c7a0e7bf51180864e0d1de04  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle RAC 添加删除节点更换设备指导书_files\20180116132850_555.png  

[f7d1e26d74ceaab0050444f795e31650]: media/Oracle_RAC_添加删除节点更换设备指导书-27.html
[Oracle_RAC_添加删除节点更换设备指导书-27.html](media/Oracle_RAC_添加删除节点更换设备指导书-27.html)
>hash: f7d1e26d74ceaab0050444f795e31650  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle RAC 添加删除节点更换设备指导书_files\20180116132421_430.png  

[fcc92f99bf269bb8204ea65ac59a1bc2]: media/Oracle_RAC_添加删除节点更换设备指导书-28.html
[Oracle_RAC_添加删除节点更换设备指导书-28.html](media/Oracle_RAC_添加删除节点更换设备指导书-28.html)
>hash: fcc92f99bf269bb8204ea65ac59a1bc2  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle RAC 添加删除节点更换设备指导书_files\20180116132339_981.png  

---
### NOTE ATTRIBUTES
>Created Date: 2018-09-25 03:29:06  
>Last Evernote Update Date: 2018-10-01 15:33:54  
>author: YangKwong  
>source: desktop.win  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle RAC 添加删除节点更换设备指导书.html  
>source-application: evernote.win32  