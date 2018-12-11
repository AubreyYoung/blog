# Oracle-安装手册-rhel6 Oracle 12.2.0.1 RAC安装指导手册

# 瀚高技术支持管理平台

## 12C R2认证

##

RAC 12.2.0.1在Linux x86-64 Red Hat Enterprise Linux 6认证的Minimum kernel version:
RHEL 6.4 (2.6.32-358.el6.x86_64)以上。

## 1、 验证系统要求

参考文档：

Oracle Database (RDBMS) on Unix AIX,HP-UX,Linux,Solaris and MS Windows
Operating Systems Installation and Configuration Requirements Quick Reference
(12.1/12.2) ( **文档** **ID 1587357.1** )

Requirements for Installing Oracle Database 12.2 on OL6 or RHEL6 64-bit
(x86-64) ( **文档** **ID 2196074.1** )

https://docs.oracle.com/en/database/oracle/oracle-database/12.2/cwlin/oracle-
grid-infrastructure-installation-
checklist.html#GUID-71A93E07-7E50-449C-B425-02F04A2EA8E6

验证系统是否满足 Oracle 12c 数据库的最低要求。

RAM 最小8GB 以上，SWAP的要求如下：

 **RAM**

|

 **Swap Space**  
  
---|---  
  
Between 4 GB and 16 GB

|

Equal to the size of RAM  
  
More than 16 GB

|

16 GB  
  
本地磁盘空间

目录

|

最小

|

Oracle建议  
  
---|---|---  
  
Grid home

|

12GB

|

100GB  
  
Oracle home

|

9GB

|

100GB  
  
/tmp

|

1GB

|

2GB  
  
检查内存和磁盘，运行以下命令：

# grep MemTotal /proc/meminfo

# grep SwapTotal /proc/meminfo

# free -m

# df -h /tmp

# df -h /dev/shm

# uname –a

# fdisk –l

# cat /etc/fstab

 **扩展** **SWAP** **空间的方法：**

 **方法** **1** **：没有多余磁盘时，使用系统文件扩展** **SWAP**

以root创建swap文件

# dd if=/dev/zero of=/swap/swapfile1 bs=4M count=1024

执行mkswap格式化分区

# mkswap /swap/swapfile1

Setting up swapspace version 1, size = 4194300 KiB

no label, UUID=eac92db9-3913-4383-8428-7fedc7914bf4

编辑/etc/fstab文件加入swap

# vi /etc/fstab

/swap/swapfile1 swap swap defaults 0 0

挂载swap

[root@rac1 ~]# swapon -va

swapon /swap/swapfile1

swapon: /swap/swapfile1: insecure permissions 0644, 0600 suggested.

swapon: /swap/swapfile1: found swap signature: version 1, page-size 4, same
byte order

swapon: /swap/swapfile1: pagesize=4096, swapsize=4294967296,
devsize=4294967296

使用free -m查看swap大小。

 **方法** **2** **：找一个未使用的磁盘扩展** **SWAP** ，例如例子中的/dev/sdg，执行fdisk分区：

[root@rac1 ~]# fdisk /dev/sdg

Command (m for help): **n**

Command action

e extended

p primary partition (1-4)

 **p**

Partition number (1-4): **1**

First cylinder (1-1044, default 1):

Using default value 1

Last cylinder, +cylinders or +size{K,M,G} (1-1044, default 1044):

Using default value 1044

Command (m for help): **w**

The partition table has been altered!

Calling ioctl() to re-read partition table.

Syncing disks.

执行mkswap格式化分区

[root@rac1 ~]# mkswap /dev/sdg1

Setting up swapspace version 1, size = 8385892 KiB

no label, UUID=55584ef9-f0fd-494e-80ea-2129a585abda

编辑/etc/fstab文件加入swap

[root@rac1 ~]# vi /etc/fstab

UUID=55584ef9-f0fd-494e-80ea-2129a585abda swap swap defaults 0 0

挂载swap

[root@rac1 ~]# swapon -va

swapon on /dev/sdg1

swapon: /dev/sdg1: found swap signature: version 1, page-size 4, same byte
order

swapon: /dev/sdg1: pagesize=4096, swapsize=8587157504, devsize=8587160064

使用free -m查看swap大小。

## 2、 初始化系统服务

关闭防火墙

# service iptables stop

# chkconfig iptables off

关闭selinux:

# sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

# setenforce 0

关闭avahi-daemon，系统默不安装

# /etc/init.d/avahi-daemon stop

# /sbin/chkconfig avahi-daemon off

关闭 NetworkManager 服务

# service NetworkManager stop

# chkconfig NetworkManager off

关闭cpuspeed服务

# service cpuspeed stop

# chkconfig cpuspeed off

Linux OS Service 'cpuspeed' (文档 **ID 551694.1** )

启用名称服务高速缓存守护程序（nscd）。

https://docs.oracle.com/en/database/oracle/oracle-
database/12.2/cwlin/enabling-the-name-service-cache-
daemon.html#GUID-2578FE34-E846-4D0D-85AC-E2A191915578

# yum install nscd –y ##yum的配置请参考下文<安装软件包>

# chkconfig --level 35 nscd on

# service nscd start

## 3、 网络Hosts文件配置

每个主机修改/etc/hosts文件

# vi /etc/hosts

192.168.0.25 rac1

192.168.0.26 rac2

192.0.10.125 rac1-priv

192.0.10.126 rac2-priv

192.168.0.125 rac1-vip

192.168.0.130 rac2-vip

192.168.0.127 rac-cluster-scan

rac1、rac2 对应的是网卡的物理ip ，即public ip

rac1-priv、rac2-priv 对应的是心跳网卡的物理ip ，即private ip

rac1-vip、rac2-vip 对应的是虚拟IP，即vip

rac-cluster-scan 对应的SCAN ip

建议客户客户端连接rac群集，访问数据库时使用SCAN ip地址。

注意：vip、public ip、scan ip 必须要在同一个子网网段中。

另外，对于心跳IP地址的设置，不要设置成和客户局域网中存在的ip网段。

如客户网络是192.x.x.x 则设置心跳为 10.x.x.x
,心跳地址工程师可以自定义，但也要和客户确认客户局域网络是否有相同ip地址的服务器，尽量避免干扰。

配置完心跳地址后,一定要使用traceroute测试心跳网络之间通讯是否正常。不能简单地通过ping命令来检测.一定要使用traceroute，traceroute默认是采用udp协议.每次执行traceroute会发起三次检测,*号表示通讯失败.

正常:

# traceroute rac2-priv

traceroute to rac2-priv (192.168.122.132), 30 hops max, 60 byte packets

lsrac2-priv (192.168.122.132) 0.802 ms 0.655 ms 0.636 ms

不正常:

# traceroute rac2-priv

traceroute to rac2-priv (192.168.122.132), 30 hops max, 60 byte packets

1 lsrac2-priv (192.168.122.132) 1.187 ms * *

如果经常出现* 则需要先检测心跳网络通讯是否正常.

## 4、 心跳网络检查

1.从11.2.0.2（含）开始，ORACLE私网通讯不再直接采用“我们在私网网卡上所配置的地址（例如192.168这样的地址）”，而是采用GRID启动后，ORACLE在私网网卡上绑定的169.254这个网段的地址，而部分x86服务器会带有IBM
IMM设备，这个设备主要用来进行硬件管理，通过LANG或USB网络，默认IMM设备地址是169.254网段，这可能会造成IP冲突，169网段路由信息被清除，引起私网心跳不通问题。

检查 是否存在169.xxx.xxx.xx的网卡，如有，设置成静态并分配其他IP地址。

# ifconfig -a

usb0 Link encap:Ethernet HWaddr XX:XX:XX:XX:XX:XX

inet addr:169.254.xx.xx Bcast:169.254.95.255 Mask:255.255.255.0

修改这些网络设备如USB0口不采用DHCP，而是直接采用静态IP

修改dhcp为static，并分配其他IP

# vi /etc/sysconfig/network-scripts/ifcfg-usb0

# BOOTPROTO=dhcp

BOOTPROTO=static

IPADDR=xxx.xxx.xxx.xxx

重启网卡，使改变生效

# /sbin/ifdown usb0

# /sbin/ifup usb0

# /sbin/ifconfig usb0

Oracle RAC H/A Failure Causes Oracle Linux Node Eviction On Server With IBM
Integrated Management Module (IMM) (文档 **ID 1629814.1** )

2.集群心跳网络建议冗余交换机，如果服务器使用多个网卡网卡，集群会使用HAIP，每个专用接口应该位于不同的子网上，最多可以为心跳网络定义四个接口。Oracle建议使用专用交换机。最小的交换机速度是千兆以太网。Oracle不建议在心跳网络上使用防火墙，因为这可能会阻止互连流量。

## 5、 安装软件包

将操作系统光盘放入光驱并挂载

# mkdir /media/cdrom

# mount /dev/cdrom /media/cdrom

或者可上传系统ISO，并挂载镜像

# mkdir /media/cdrom

# mount -o loop xxx.iso /media/cdrom

配置yum安装程序

# vi /etc/yum.repos.d/highgo.repo

输入如下内容：

[Server]

name=Red Hat Enterprise Linux $releasever Beta - $basearch - Source

baseurl=file:///media/cdrom

enabled=1

gpgcheck=1

gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release

安装64位系统软件包

yum install binutils compat-libcap1 compat-libstdc++-33 e2fsprogs e2fsprogs-
libs gcc gcc-c++ glibc glibc-devel libaio libaio-devel libX11 libXau libXi
libXtst libgcc libstdc++ libstdc++-devel libxcb make smartmontools sysstat
nfs-utils net-tools ksh unixODBC unixODBC-devel lsscsi* openssh -y

安装32位系统软件包

echo 'multilib_policy=all' >> /etc/yum.conf

可以执行如下命令安装所有需要的rpm

yum install compat-libstdc++-33 glibc glibc-devel libaio libaio-devel libX11
libXau libXi libXtst libgcc libstdc++ libstdc++-devel libxcb -y

# sed -i "s/multilib_policy=all//g" /etc/yum.conf

# umount /media/cdrom/

<https://docs.oracle.com/database/122/CWLIN/supported-red-hat-enterprise-
linux-6-distributions-for-x86-64.htm#CWLIN-
GUID-3B53A308-3EC2-4173-98A0-0FFD68994E90>

 **如果没有安装图形化界面，可以使用以下方式安装：**

安装Xwindow软件组

# yum groupinstall "X Window System" -y

开始安装桌面

# yum groupinstall "Desktop" -y

rhel 6.1新增了一个redhat订阅，可以删除

# yum remove subscription-manager-firstboot subscription-manager subscription-
manager-gui

安装桌面右键终端

# yum install nautilus-open-terminal

设置默认图形化运行级别

[root@hgdb01 ~]# vi /etc/inittab

id:3:initdefault:

将id:3:initdefault:中的3改成5

## 6、 内核参数

/etc/sysctl.conf 这里面的修改可以通过安装过程中运行runfixup.sh脚本自动修改。

在安装过程中，系统会提示。

Oracle Database
12c第2版需要如下所示的内核参数设置。给出的值都是最小值，因此如果系统使用更大的值，则不要更改。其中shmmax和shmall要根据实际物理内存进行计算。

# vi /etc/sysctl.d/97-oracle-highgo-sysctl.conf

kernel.shmmax = 4294967295

#shmmax 1/2 of physical RAM(单位bytes)See
[Note:567506.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1962100.1&id=567506.1)
for more information.

kernel.shmall = 2097152

# physical memory的40%。

Note: If the server supports multiple databases, or uses a large SGA, then set
this parameter to a value that is equal to the total amount of shared memory,
in 4K pages, that the system can use at one time.

kernel.shmmni = 4096  
kernel.sem = 250 32000 100 128  
net.ipv4.ip_local_port_range = 9000 65500  
net.core.rmem_default = 262144  
net.core.rmem_max = 4194304  
net.core.wmem_default = 262144  
net.core.wmem_max = 1048576

fs.aio-max-nr = 4194304

fs.file-max = 6815744

vm.min_free_kbytes=524288

kernel.panic_on_oops = 1

kernel.randomize_va_space=0

kernel.exec-shield=0

RAC and Oracle Clusterware Best Practices and Starter Kit (Linux) (文档 **ID
811306.1** )

Requirements for Installing Oracle Database 12.2 on OL6 or RHEL6 64-bit
(x86-64) (文档 **ID 2196074.1** )

注意：在linux内核为2.6.31及以上版本中针对HAIP环境（多个内联心跳地址）添加以下参数，其中0表示不过滤，1表示严格过滤，2表示一般过滤，专用互连的rp_filter值设置为0或2。

net.ipv4.conf.私有网卡1.rp_filter=2

net.ipv4.conf.私有网卡2.rp_filter=2

将'私有网卡n'替换成实际网卡名称。

参考mos文章

rp_filter for multiple private interconnects and Linux Kernel 2.6.32+ (文档 **ID
1286796.1** )

运行如下命令是参数立即生效。

# /sbin/sysctl --system

运行如下命令查看参数值是否生效。

# /sbin/sysctl -a

## 7、 设置oracle的shell限制

在/etc/security/limits.conf文件中加入

# vi /etc/security/limits.conf

grid soft nofile 1024

grid hard nofile 65536

grid hard stack 32768

grid soft stack 10240

oracle soft nofile 1024

oracle hard nofile 65536

oracle hard stack 32768

oracle soft stack 10240

oracle hard memlock 3145728

oracle soft memlock 3145728

https://docs.oracle.com/en/database/oracle/oracle-
database/12.2/cwlin/checking-resource-limits-for-oracle-software-installation-
users.html#GUID-293874BD-8069-470F-BEBF-A77C06618D5A

修改使以上参数生效：

# vi /etc/pam.d/login

session required pam_limits.so

rhel6 或更高版本 则要注意

nproc参数在/etc/security/limits.d/90-nproc.conf中设置生效的优先级大于设置在文件/etc/security/limits.conf，所以建议在/etc/security/limits.d/90-nproc.conf中设置nproc参数。

参考mos文章

Setting nproc values on Oracle Linux 6 for RHCK kernel (文档 **ID 2108775.1** )

[root@rac1 ~]# cat /etc/security/limits.d/90-nproc.conf

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

nproc值表示该用户下的最大进程数max user processes，如果业务进程较多，则可能因为进程达到上限而使得操作系统用户无法登陆。

查看当前用户的max user processes，可登录到指定的系统用户下

[oracle]$ ulimit -a

max user processes (-u) 2047

[oracle]$ ulimit -Ha

max user processes (-u) 16384

在/etc/profile文件中加入

# vi /etc/profile

if [ $USER = "oracle" ] || [ $USER = "grid" ]; then

if [ $SHELL = "/bin/ksh" ]; then

ulimit -p 16384

ulimit -n 65536

else

ulimit -u 16384 -n 65536

fi

umask 022

fi

## 8、 操作系统时间和时区

检查多个服务器节点的操作系统时间是否一致。如果不一致要先手动修改。

建议使用SecureCRT工具对所有节点同时修改。

linux修改时间的命令是 ：年月日 时分秒

#date -s "20100405 14:31:00"

检查操作系统时区

# cat /etc/sysconfig/clock

ZONE="Asia/Shanghai"

修改时区，具体请参考指导书《操作系统时区设置手册》

# vi /etc/sysconfig/clock

ZONE="Asia/Shanghai"

# cd /etc/

# mv localtime localtime.bak

# ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

关闭NTP服务

Network Time Protocol Setting

service ntpd stop

chkconfig ntpd off

mv /etc/ntp.conf /etc/ntp.conf.bak

mv /etc/resolv.conf /etc/resolv.conf.bak

一定要保证时间同步，但是不能配置ntp，否则会导致12c的ctssd处于旁观模式。如果客户严格要求和北京时间一致，则考虑让客户提供时间服务器，然后再采用NTP和其时间服务器同步。如果配置NTP注意参数-
x保证时间不能向回调，关于NTP配置此处不做详细解释。

## 9、 修改主机名

每个主机均要修改：

vi /etc/sysconfig/network

将其中HOSTNAME改为主机名，如下：

HOSTNAME=rac1

注意主机名不能过长,不能超过8个字符，且不能有下划线等特殊符号，不要使用大写字母，建议使用小写字母即可。

添加NOZEROCONF=yes

参考MOS文章：

CSSD Fails to Join the Cluster After Private Network Recovered if avahi Daemon
is up and Running (文档 **ID 1501093.1** )

修改完主机名务必重启生效

## 10、添加用户和组、创建目录

/usr/sbin/groupadd -g 54321 oinstall

/usr/sbin/groupadd -g 54322 dba

/usr/sbin/groupadd -g 54323 oper

/usr/sbin/groupadd -g 54324 backupdba

/usr/sbin/groupadd -g 54325 dgdba

/usr/sbin/groupadd -g 54326 kmdba

/usr/sbin/groupadd -g 54327 asmdba

/usr/sbin/groupadd -g 54328 asmoper

/usr/sbin/groupadd -g 54329 asmadmin

/usr/sbin/groupadd -g 54330 racdba

/usr/sbin/useradd -u 54331 -g oinstall -G dba,asmdba,asmoper,asmadmin,racdba
grid

/usr/sbin/useradd -u 54321 -g oinstall -G
dba,oper,backupdba,dgdba,kmdba,asmdba,racdba oracle

如果系统存在Oracle和grid用户，可以使用以下方式修改属组或者删除重建：

# /usr/sbin/usermod -g oinstall -G dba,asmdba,dgdba,kmdba,racdba[,oper] oracle

# /usr/sbin/userdel -r oracle

修改grid、oracle 用户密码

passwd grid

passwd oracle

创建目录

mkdir -p /u01/app/12.2.0/grid

mkdir -p /u01/app/grid

mkdir -p /u02/app/oracle/product/12.2.0/db_1

chown -R grid:oinstall /u01/

chown -R oracle:oinstall /u02/

chmod -R 775 /u01/ /u02/

rac节点修改grid用户环境变量

# vi /home/grid/.bash_profile

umask 022

if [ -t 0 ]; then

stty intr ^C

fi

export ORACLE_SID=+ASM1 **_#_** ** _其他节点修改为_** ** _+ASM2/3.._**

export ORACLE_BASE=/u01/app/grid

export ORACLE_HOME=/u01/app/12.2.0/grid

export PATH=$ORACLE_HOME/bin:$PATH:$HOME/bin:$ORACLE_PATH

export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib

export CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib

export

注意： grid 用户环境变量 ORACLE_HOME 不在ORACLE_BASE 目录下，$ORA_CRS_HOME不要用作用户环境变量。

rac节点修改oracle用户环境变量,其中ORACLE_SID让开发商定好数据库名称，SID后面分别添加1和2。

# vi /home/oracle/.bash_profile

umask 022

if [ -t 0 ]; then

stty intr ^C

fi

export ORACLE_SID=orcl1 **_#_** ** _其他节点修改为_** ** _orcl2/3.._**

export ORACLE_BASE=/u02/app/oracle

export ORACLE_HOME=/u02/app/oracle/product/12.2.0/db_1

export ORACLE_HOSTNAME=rac1

export PATH=$ORACLE_HOME/bin:$PATH:$HOME/bin

export
LD_LIBRARY_PATH=$ORACLE_HOME/lib:$ORACLE_HOME/lib32:$ORACLE_HOME/rdbms/lib:/lib:/usr/lib

export CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib

export

## 11、ASM配置共享磁盘

使用新磁盘创建ASM磁盘组前，务必检查新磁盘是否存在数据：

# for DISK in $(awk '!/name/ {print $NF}' /proc/partitions); do echo -n "$DISK
"; if [ $(hexdump -n10485760 /dev/$DISK | head | wc -l) -gt "3" ]; then echo
"has data"; else echo "is empty"; fi; done;

在确认新磁盘无数据后，需确认是否使用asmlib包方式创建的ASM磁盘。

### 11.1 ASMLib

### 11.2 原始设备

主要分如下三种情况：

### 情况1、使用存储专用多路径软件的情况

此种情况下磁盘的名称，以及磁盘唯一性的确认都是存储工程来保障的。

如emc的存储多路径聚合软件聚合后的盘一般是/dev/emcpowera 、/dev/emcpowerb等。

这种情况只需要存储工程师提供给我们盘名，我们进行ASM层面的操作即可。

# vi /etc/udev/rules.d/99-asm-highgo.rules

ACTION=="add", KERNEL=="emcpowera", RUN+="/bin/raw /dev/raw/raw1 %N"

ACTION=="add", KERNEL=="emcpowerb", RUN+="/bin/raw /dev/raw/raw2 %N"

ACTION=="add", KERNEL=="emcpowerc", RUN+="/bin/raw /dev/raw/raw3 %N"

ACTION=="add", KERNEL=="emcpowerd", RUN+="/bin/raw /dev/raw/raw4 %N"

ACTION=="add", KERNEL=="emcpowere", RUN+="/bin/raw /dev/raw/raw5 %N"

KERNEL=="raw[1-5]",OWNER="grid",GROUP="asmadmin",MODE="0660"

重启udev守护进程

# start_udev

检查是否生成ls -l /dev/raw/raw*磁盘,以及磁盘权限是否是grid:asmadmin

注意：正在运行生产业务的os,禁止使用start_udev命令，start_udev会重新读取udev规则，暂时性删除网卡，造成节点hang或驱逐。动态添加存储的变通方法是将规则写入udev配置文件，手动执行绑定授权命令，待下次重启，自动读取udev文件配置。

/bin/raw /dev/raw/raw1 /dev/mapper/mpath1

chown oracle:oinstall/dev/raw/raw1

chmod 660 /dev/raw/raw1

Network interface going down when dynamically adding disks to storage using
udev in RHEL 6 (文档 **ID 1569028.1** )

### 情况2、使用linux系统自带multipath多路径软件的情况

参考文章：

Configuring Multipath Devices on RHEL6/OL6 (文档 **ID 1538626.1** )

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

因为rhel 6 多路径和5不一样，/dev/mapper下不再是块设备磁盘，而是软连接。

dm-X 多路径绑定出来后，不同节点生成的dm-X对应的存储磁盘有可能不一致。

配置asm磁盘时不允许使用/dev/dm-*格式

How to Configure LUNs for ASM Disks using WWID, DM-Multipathing, and ASMLIB on
RHEL 5/OL 5 and RHEL 6/OL 6 (文档 **ID 1365511.1** )

因此参考mos文章：

How to set udev rule for setting the disk permission on ASM disks when using
multipath on OL 6.x (文档 **ID 1521757.1** )

 **使用** **udev** **修改磁盘权限和属主**

添加如下内容，根据实际情况进行调整：

# vi /etc/udev/rules.d/12-dm-permissions-highgo.rules

ENV{DM_NAME}=="ocr1", OWNER:="grid", GROUP:="asmadmin", MODE:="660",
SYMLINK+="mapper/$env{DM_NAME}"

ENV{DM_NAME}=="ocr2", OWNER:="grid", GROUP:="asmadmin", MODE:="660",
SYMLINK+="mapper/$env{DM_NAME}"

ENV{DM_NAME}=="ocr3", OWNER:="grid", GROUP:="asmadmin", MODE:="660",
SYMLINK+="mapper/$env{DM_NAME}"

ENV{DM_NAME}=="data", OWNER:="grid", GROUP:="asmadmin", MODE:="660",
SYMLINK+="mapper/$env{DM_NAME}"

ENV{DM_NAME}=="fra", OWNER:="grid", GROUP:="asmadmin", MODE:="660",
SYMLINK+="mapper/$env{DM_NAME}"

root用户执行

# start_udev

重新加载udev设备

# ls –l /dev/dm-* 检查磁盘属主和权限是否正确。

注意：正在运行生产业务的os,禁止使用start_udev命令，start_udev会重新读取udev规则，暂时性删除网卡，造成节点hang或驱逐。动态添加存储的变通方法是将规则写入udev配置文件，手动执行绑定授权命令，待下次重启，自动读取udev文件配置。

/bin/raw /dev/raw/raw1 /dev/mapper/mpath1

chown oracle:oinstall /dev/raw/raw1

chmod 660 /dev/raw/raw1

Network interface going down when dynamically adding disks to storage using
udev in RHEL 6 (文档 **ID 1569028.1** )

### 情况3、未使用multipath或其他多路径软件的情况

为避免后期添加删除磁盘等导致盘序变乱，要求使用udev绑定wwid的形式。

禁止使用raw绑定sdb、sdc等磁盘名的形式。（华为存储多路径ultrapath聚合后的名字依然是/dev/sdb,这种情况直接使用磁盘名，不需要绑定wwid）

以下步骤中，之所以没有按照mos文章中提到的直接对磁盘进行重命名，而是针对wwid调用raw 命令来绑定成raw设备，原因是直接重命名磁盘的话，fdisk
-l就不会显示被重命名的磁盘（可以通过cat /proc/partitions看到被重命名的磁盘，如果磁盘被重命名成/dev/vote，可以通过fdisk
-l /dev/vote来查看磁盘大小等信息。），对于不熟悉环境的人来说fdisk -l 会因为看不到所有存储磁盘而影响判断。

如果不使用多路径软件，则需要使用udev绑定裸设备的形式

https://www.kernel.org/pub/linux/utils/kernel/hotplug/udev/udev.html

How To Replace ASMLib With UDEV (文档 **ID 1461321.1** )

像文章中指出将磁盘进行重命名，但是会出现fdisk -l无法看到被重命名磁盘的情况，这样不便于后期对磁盘的管理。因此采用将磁盘绑定为raw设备的做法。

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

KERNEL=="raw[1-5]",OWNER="grid",GROUP="asmadmin",MODE="0660"

root用户执行

# start_udev

重新加载udev设备

ls –l /dev/raw/raw*

查询raw是否成功挂在磁盘，并确认磁盘属主和权限是否正确

注意：正在运行生产业务的os,禁止使用start_udev命令，start_udev会重新读取udev规则，暂时性删除网卡，造成节点hang或驱逐。动态添加存储的变通方法是将规则写入udev配置文件，手动执行绑定授权命令，待下次重启，自动读取udev文件配置。

/bin/raw /dev/raw/raw1 /dev/mapper/mpath1

chown grid:asmadmin /dev/raw/raw1

chmod 660 /dev/raw/raw1

Network interface going down when dynamically adding disks to storage using
udev in RHEL 6 (文档 **ID 1569028.1** )

 _小技巧：如果需要手动解除绑定：_ _raw /dev/raw/raw13 0 0_ _＃解除_ _raw13_ _绑定_

注意：要根据你的实际情况来配置，不建议使用自动shell脚本生成以上内容，建议notepad++等工具进行列模式编辑。特别是添加磁盘到现有生产环境的情况，脚本不可控，存在安全隐患。

### 创建用于ASM访问的磁盘软链接

# su - grid

$ mkdir /u01/asm-disk/

举例如：

ln -s /dev/mapper/ocr1 /u01/asm-disk/ocr1

ln -s /dev/mapper/ocr2 /u01/asm-disk/ocr2

ln -s /dev/mapper/ocr3 /u01/asm-disk/ocr3

ln -s /dev/mapper/data /u01/asm-disk/data

ln -s /dev/mapper/fra /u01/asm-disk/fra

ln -s /dev/raw/raw1 /u01/asm-disk/ocr1

ln -s /dev/raw/raw2 /u01/asm-disk/ocr2

ln -s /dev/raw/raw3 /u01/asm-disk/ocr3

无论哪种形式的裸设备最后都要建立软连接，到/u01/asm-disk目录

根据实际情况进行修改。

配置到此后需要重启下服务器，确保所有的存储磁盘均可自动挂载。

## 12、磁盘io调度程序建议

Linux中磁盘io调度程序有两种算法，CFQ（完全公平队列）和deadline（期限）

CFQ调度程序适用于各种各样的应用程序，在延迟和吞吐量之间又一个很好的平衡

Deadline调度程序针对每个请求都能实现最大延迟并能保持一个很好的吞吐量

如果应用为io密集型，如数据库系统，建议使用deadline调度程序

Red Hat Enterprise Linux 4, 5, 6中默认的算法为CFQ，

Red Hat Enterprise Linux 7则使用deadline作为默认算法。

1 查看

$ cat /sys/block/sdb/queue/scheduler

noop anticipatory [deadline] cfq

2 修改

在线修改临时生效

Enabling the deadline io scheduler at runtime via the /sys filesystem (RHEL 5,
6, 7)

$ echo 'deadline' > /sys/block/sda/queue/scheduler

写入启动脚本永久生效

Enabling the deadline io scheduler at boot time. Add elevator=deadline to the
end of the kernel line in /etc/grub.conf file (RHEL 4, 5, and 6):

vi /etc/grub.conf

title Red Hat Enterprise Linux Server (2.6.9-67.EL)

root (hd0,0)

kernel /vmlinuz-2.6.9-67.EL ro root=/dev/vg0/lv0 elevator=deadline

initrd /initrd-2.6.9-67.EL.img

例如

[root@rac2 ~]# cat /sys/block/sdb/queue/scheduler

noop anticipatory deadline [cfq]

[root@rac2 ~]# echo 'deadline' > /sys/block/sdb/queue/scheduler

[root@rac2 ~]# echo 'deadline' > /sys/block/sdc/queue/scheduler

[root@rac2 ~]# echo 'deadline' > /sys/block/sdd/queue/scheduler

[root@rac2 ~]# echo 'deadline' > /sys/block/sde/queue/scheduler

[root@rac2 ~]# echo 'deadline' > /sys/block/sdf/queue/scheduler

[root@rac2 ~]# cat /sys/block/sdb/queue/scheduler

noop anticipatory [deadline] cfq

## 13、系统日志保留时间

修改操作系统日志保留策略配置文件

# vi /etc/logrotate.conf

修改rotate 4为 rotate 50

使得操作系统日志保留50周，每周1个日志文件。

# logrotate -f /etc/logrotate.conf ##设置立即生效

## 14、验证安装介质md5值

安装介质如非官方途径下载，需要验证md5值，避免使用网络上被篡改过的恶意介质

# md5sum linuxx64_12201_database.zip

得出的值和如下官方提供的md5值进行对比，如果md5值不同，则表示文件有可能被篡改过，不可以使用。文件的名字发生变化并不影响md5值的校验结果。

详见《Oracle各版本安装包md5校验手册v2.docx》

linuxx64_12201_database.zip (3,453,696,911 bytes) (cksum - 4170261901)

MD5 1841F2CE7709CF909DB4C064D80AAE79

SHA-1 12598250BE536C9D074AE0EB2F7DF4A9B463D0EB

linuxx64_12201_grid_home.zip (2,994,687,209 bytes) (cksum - 1523222538)

MD5 AC1B156334CC5E8F8E5BD7FCDBEBFF82

SHA-1 F4611B73B502A2BD560E5788BE168E306D7A4BDA

## 15、安装 Oracle Grid Infrastructure

解压群集安装程序

# su - grid

$ unzip /opt/linuxx64_12201_grid_home.zip -d $ORACLE_HOME

安装cvuqdisk软件包

找到位于Oracle GI安装介质cvuqdisk目录中的RPM软件包。如果安装了Oracle GI，则位于grid_home/cv/rpm目录中。

# export CVUQDISK_GRP=oinstall

# rpm -ivh cvuqdisk-1.0.10-1.rpm

VNC连接服务器执行安装程序

# xhost+

# su - grid

$ cd $ORACLE_HOME

$ ./gridSetup.sh

以下截图内值均未参考选项，以实际内容为准。

Cluster
Name不区分大小写，长度不超过15个字符，必须是字母或数字，不能以数字开头，并且可能包含连字符(-)，不能包含下划线字符(_)。安装之后，只能通过重新安装Oracle
GI来更改Cluster Name。

SCAN Name必须和hosts文件里的scan name 保持一致。

Oracle Flex
Clusters有两种类型的节点：Hub节点和Leaf节点。Hub节点数可以多达64个。Hub节点可直接访问共享存储。Hub节点还可以为一个或多个Leaf节点提供存储服务。Oracle
Flex集群中的Leaf节点不需要直接访问共享存储，而是通过Hub节点请求数据。

先点击setup按钮来建立主机之间的ssh互信，互信就是服务器之间ssh登录时可以不需要输入对方操作系统账户的密码。

相比于之前的版本，Oracle12c网卡的类型增加了ASM以及ASM & Private两个类型，这两种类型在使用Flex ASM的方式时选择。Oracle
Flex ASM使Oracle
ASM实例能够在独立于数据库服务器的物理服务器上运行。以将所有存储要求合并到一组磁盘组中。所有这些磁盘组都由运行在单个Oracle
Flex集群中的一小组Oracle ASM实例进行管理。每个Oracle Flex ASM集群都有一个或多个在其上运行Oracle
ASM实例的Hub节点。Oracle Flex ASM可以使用与Oracle Clusterware相同的专用网络，也可以使用自己的专用专用网络。

**注意此处添加的磁盘是存储磁盘软链接存放的目录** **/u01/asm-disk/**

添加CRS磁盘组，用于存储Oracle集群注册表（OCR），投票文件和Oracle ASM密码文件。

从Oracle Grid Infrastructure 12 c Release 2（12.2）开始，您必须使用Oracle自动存储管理（Oracle
ASM）来存储投票文件和OCR文件。

ASM Filter Driver （ASMFD）

Oracle ASMFD有助于防止Oracle ASM磁盘和磁盘组中的文件出现损坏。

如果Linux系统上存在Oracle ASMLIB，请在安装Oracle GI之前卸载Oracle ASMLIB，以便在Oracle
GI安装期间选择安装和配置Oracle ASMFD。

创建MGMT磁盘组，存储Grid Infrastructure Management Repository（GIMR）数据文件和Oracle Cluster
Registry（OCR）备份文件。Oracle强烈建议您将OCR备份文件存储在与存储OCR文件的磁盘组不同的磁盘组中。

注意安装完成以后不能将GIMR从一个磁盘组迁移到另一个磁盘组。

GIMR是一个多租户数据库，存储关于集群的信息。此信息包括Cluster Health Monitor收集的实时性能数据。

注意MGMT磁盘组需要的磁盘大小最小是37712MB，否则安装会报以下错误：

SEVERE: [Nov 27, 2017 1:41:04 PM] [FATAL] [INS-30515] Insufficient space
available in the selected disks.

CAUSE: Insufficient space available in the selected Disks. At least, 37,712 MB
of free space is required.

ACTION: Choose additional disks such that the total size should be at least
37,712 MB.

ASM必须达到一定的密码标准。密码中要包含字母大写、小写、数字，至少8个字符。

Oracle 12.2在RHEL 7中安装时可以使用自动执行root脚本的功能。

# /tmp/GridSetupActions2017-11-27_01-55-03PM/CVU_12.2.0.1.0_grid/runfixup.sh

All Fix-up operations were completed successfully.

只有以上几个条件不满足，勾选右上角的ignore all，如果存在其他条件不满足则要进行相应处理。

运行root.sh脚本需要注意：

1.root.sh脚本必须先在第一个节点上运行并等待它完成之后再在其他节点运行此脚本。

2.可以在除运行root.sh脚本的最后一个节点以外的所有其他节点上同时运行脚本。

3.像第一个节点一样，root.sh最后一个节点上的脚本必须单独运行。

[root@rac1 ~]# /u01/app/oraInventory/orainstRoot.sh

[root@rac2 ~]# /u01/app/oraInventory/orainstRoot.sh

[root@rac1 ~]# /u01/app/12.2.0/grid/root.sh

[root@rac2 ~]# /u01/app/12.2.0/grid/root.sh

若集群root.sh脚本运行不成功：

删除crs配置信息

#/u01/app/12.1.0/grid/crs/install/rootcrs.pl -verbose -deconfig -force

出现这两个错误可以忽略不计。

注意：

集群安装完成后，请不要删除或运行cron作业删除/tmp/.oracle或/var/tmp/.oracle目录或文件。如果删除这些文件，则Oracle软件可能会遇到间歇性挂起。Oracle软件安装可能会失败并显示以下错误：

CRS-0184: Cannot communicate with the CRS daemon。

## 16、集群安装后的任务

验证oracle clusterware的安装

以grid身份运行以下命令：

检查crs状态：

[grid@rac2 ~]$ crsctl check cluster -all

**************************************************************

rac1:

CRS-4537: Cluster Ready Services is online

CRS-4529: Cluster Synchronization Services is online

CRS-4533: Event Manager is online

**************************************************************

rac2:

CRS-4537: Cluster Ready Services is online

CRS-4529: Cluster Synchronization Services is online

CRS-4533: Event Manager is online

**************************************************************

检查 Clusterware 资源:

[grid@rac1 ~]$ crsctl status res -t

\--------------------------------------------------------------------------------

Name Target State Server State details

\--------------------------------------------------------------------------------

Local Resources

\--------------------------------------------------------------------------------

ora.ASMNET1LSNR_ASM.lsnr

ONLINE ONLINE rac1 STABLE

ONLINE ONLINE rac2 STABLE

ora.CRS.dg

ONLINE ONLINE rac1 STABLE

ONLINE ONLINE rac2 STABLE

ora.LISTENER.lsnr

ONLINE ONLINE rac1 STABLE

ONLINE ONLINE rac2 STABLE

ora.MGMT.dg

ONLINE ONLINE rac1 STABLE

ONLINE ONLINE rac2 STABLE

ora.chad

ONLINE ONLINE rac1 STABLE

ONLINE ONLINE rac2 STABLE

ora.net1.network

ONLINE ONLINE rac1 STABLE

ONLINE ONLINE rac2 STABLE

ora.ons

ONLINE ONLINE rac1 STABLE

ONLINE ONLINE rac2 STABLE

ora.proxy_advm

OFFLINE OFFLINE rac1 STABLE

OFFLINE OFFLINE rac2 STABLE

\--------------------------------------------------------------------------------

Cluster Resources

\--------------------------------------------------------------------------------

ora.LISTENER_SCAN1.lsnr

1 ONLINE ONLINE rac1 STABLE

ora.MGMTLSNR

1 ONLINE ONLINE rac1 169.254.190.14 10.10

.10.10,STABLE

ora.asm

1 ONLINE ONLINE rac1 Started,STABLE

2 ONLINE ONLINE rac2 Started,STABLE

3 OFFLINE OFFLINE STABLE

ora.cvu

1 ONLINE ONLINE rac1 STABLE

ora.mgmtdb

1 ONLINE ONLINE rac1 Open,STABLE

ora.qosmserver

1 ONLINE ONLINE rac1 STABLE

ora.rac1.vip

1 ONLINE ONLINE rac1 STABLE

ora.rac2.vip

1 ONLINE ONLINE rac2 STABLE

ora.scan1.vip

1 ONLINE ONLINE rac1 STABLE

\--------------------------------------------------------------------------------

[grid@rac1 ~]$ crsctl status res -t -init

检查集群节点:

[grid@rac1 ~]$ olsnodes -n

rac1 1

rac2 2

检查ASM：

[grid@rac2 ~]$ srvctl status asm

ASM is running on rac1,rac2

检查两个节点上的 Oracle TNS 监听器进程:

[grid@rac1 ~]$ srvctl status listener

Listener LISTENER is enabled

Listener LISTENER is running on node(s): rac1,rac2

## 17、创建 ASM 磁盘组

在 Disk Groups 选项卡中，单击 Create 按钮，在出现的画面中创建data卷：

除了CRS磁盘组以外其余存放数据和归档的磁盘组默认都是选择Extenal外部冗余模式，除非客户特殊要求。

选择External。

ASM Flex冗余磁盘组至少需要三个磁盘设备（或三个故障组）。

对于磁盘组的规划，一般一套rac 含有一个CRS磁盘组，一个FRA磁盘组用于存放归档日志，一个或者多个DATA磁盘组用于存放数据。

单击Exit退出ASM配置向导。

至此重启下服务器确认crs各个资源状态均正常。

## 18、安装DATABASE软件

解压database安装包

[root@rac1 opt]# unzip linuxx64_12201_database.zip

vnc图形化登录服务器

单击 [SSH Connectivity] 按钮。输入 oracle 用户的 OS Password，然后单击 [Setup] 按钮。这会启动 SSH
Connectivity 配置过程：

待安装完成后在各个节点执行root.sh脚本，完成后退出向导。

## 19、创建数据库

使用dbca创建，创建之前确保已安装的所有服务（Oracle TNS 监听器、Oracle Clusterware 进程等）正在运行。

点击 **Multiplex Redo Logs and Control Files** 输入多个磁盘组来产生冗余控制文件和redo文件。

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

##

## 20、优化数据库参数

 **1\. DBCA** **创建的数据库实例参数修改**

alter system set deferred_segment_creation=false;

alter system set audit_trail =none scope=spfile;

alter system set sga_max_size =xxxxxm scope=spfile;

alter system set sga_target =xxxxxm scope=spfile;

alter systemn set pga_aggregate_target =xxxxxm scope=spfile;

alter profile default limit password_life_time unlimited;

alter database add supplemental log data;

alter system set enable_ddl_logging=true;

#关闭12c密码延迟验证新特性

alter system set event='28401 trace name context forever, level 1'
scope=spfile;

#限制trace日志文件大最大25M

alter system set max_dump_file_size ='25m';

alter system set db_files=2000 scope=spfile;

#RAC修改local_listener：（现象：使用PlSql Developer第一次连接超时，第二次之后连接正常）

alter system set local_listener = '(address = (protocol = tcp)(host =
192.168.0.125)(port = 1521))' sid='orcl1';

alter system set local_listener = '(address = (protocol = tcp)(host =
192.168.0.130)(port = 1521))' sid='orcl2';

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

 **2.** **修改rman 控制文件快照路径**

ORA-245: In RAC environment from 11.2 onwards Backup Or Snapshot controlfile
needs to be in shared location (文档 **ID 1472171.1** )

一个节点上执行即可

$ rman target /

show all;

CONFIGURE SNAPSHOT CONTROLFILE NAME TO '+DATA/snapcf_ls.f';

show all;

 **3\. ASM** **实例内存参数修改**

ASM Instances Are Reporting ORA-04031 Errors. (文档 ID 1370925.1)

RAC 和 Oracle Clusterware 最佳实践和初学者指南（平台无关部分） (文档 ID 1526083.1)

Unable To Start ASM (ORA-00838 ORA-04031) On 11.2.0.3/11.2.0.4 If OS CPUs # >
64\. (文档 ID 1416083.1)

# su - grid

$ sqlplus / as sysdba

SQL> alter system set memory_max_target=4096m scope=spfile;  
SQL> alter system set memory_target=1536m scope=spfile;

修改ASM的链路中断等待时间，避免多路径切换时间超过15s而导致磁盘组被强制umount：

SQL> alter system set "_asm_hbeatiowait"=120 scope=spfile sid='*';

## 4、禁用 diagsnap 收集。  
# <GRID_HOME>/bin/oclumon manage -disable diagsnap  
参考：安装或升级到 12.2 Grid Infrastructure 后，集群意外的崩溃 (文档 ID 2404319.1)

## 21、配置大页内存

Oracle建议禁用Transparent HugePages，因为它们可能会导致访问内存时出现延迟，从而导致Oracle
RAC环境中的节点重新启动，对于Oracle Database单实例会产生性能问题或延迟。Oracle推荐使用标准的HugePages for Linux。

 **1.** **关闭透明大页内存**

# cat /sys/kernel/mm/transparent_hugepage/enabled

[always] never

vi /etc/rc.local 添加如下内容

if test -f /sys/kernel/mm/redhat_transparent_hugepage/enabled; then

echo never > /sys/kernel/mm/redhat_transparent_hugepage/enabled

fi

if test -f /sys/kernel/mm/redhat_transparent_hugepage/defrag; then

echo never > /sys/kernel/mm/redhat_transparent_hugepage/defrag

fi

修改后重启操作系统验证：

# cat /sys/kernel/mm/transparent_hugepage/enabled

always [never]

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

 **2.** **如果内存大约等于64G开启大页内存，参考 <大页内存指导书>**

## 22、安装PSU

12cPSU和11gPSU安装有所不同

1.上传opatch soft和最新的GI psu到所有RAC节点的/psu中

2.更新opatch，两个节点均替换OPatch，PSU安装都有最低的Opatch版本要求。  
**PSU 12.2.0.1.171017** **要求OPatch version 12.2.0.1.6以上。**

 **Opatch** **工具下载：**

How To Download And Install The Latest OPatch(6880880) Version (文档 ID
274526.1)

<https://updates.oracle.com/ARULink/PatchDetails/process_form?patch_num=6880880>

p6880880_122010_Linux-x86-64.zip (95262208 bytes)

MD5 475C53D82F7474B11512598967B3E5F0

SHA-1 A8923D83815D4B43BF955BB8CDE31B471B11F737

 **PSU** **下载：**

Master Note for Database Proactive Patch Program (文档 ID 756671.1)

p26737266_122010_Linux-x86-64.zip (1059015858 bytes)

MD5 472813254C93B8823D25CB1768B509C5

SHA-1 360B8A3AF1C5766C78A0274CFB788C0D02F26C00

# su - oracle

$ unzip /psu/p6880880_122010_Linux-x86-64.zip -d $ORACLE_HOME

# su - grid

$ unzip /tmp/p6880880_122010_Linux-x86-64.zip -d $ORACLE_HOME

$ $ORACLE_HOME/OPatch/opatch version

OPatch Version: 12.2.0.1.11

OPatch succeeded.

检查GI home和每个database home的inventory信息的一致性,
如果下面命令成功，则列出安装在home目录中的Oracle组件，注意保存输出。

[root@rac1 ~]# su - grid

[grid@rac1 ~]$ $ORACLE_HOME/OPatch/opatch lsinventory -detail -oh $ORACLE_HOME

[root@rac1 ~]# su - oracle

[oracle@rac1 ~]$ $ORACLE_HOME/OPatch/opatch lsinventory -detail -oh
$ORACLE_HOME

[root@rac1 ~]# chown -R grid:oinstall /psu

[root@rac1 ~]# su - grid

[grid@rac1 ~]$ cd /psu

[grid@rac1 psu]$ unzip p26737266_122010_Linux-x86-64.zip

使用OPatch对PSU进行检查

# su - grid

$ORACLE_HOME/OPatch/opatch prereq CheckConflictAgainstOHWithDetail -phBaseDir
/psu/26737266/26710464

$ORACLE_HOME/OPatch/opatch prereq CheckConflictAgainstOHWithDetail -phBaseDir
/psu/26737266/26925644

$ORACLE_HOME/OPatch/opatch prereq CheckConflictAgainstOHWithDetail -phBaseDir
/psu/26737266/26737232

$ORACLE_HOME/OPatch/opatch prereq CheckConflictAgainstOHWithDetail -phBaseDir
/psu/26737266/26839277

$ORACLE_HOME/OPatch/opatch prereq CheckConflictAgainstOHWithDetail -phBaseDir
/psu/26737266/26928563

# su - oracle

$ORACLE_HOME/OPatch/opatch prereq CheckConflictAgainstOHWithDetail -phBaseDir
/psu/26737266/26710464

$ORACLE_HOME/OPatch/opatch prereq CheckConflictAgainstOHWithDetail -phBaseDir
/psu/26737266/26925644

输出结果：

Invoking prereq "checkconflictagainstohwithdetail"

Prereq "checkConflictAgainstOHWithDetail" passed.

OPatch succeeded.

运行OPatch SystemSpace检查

检查ORACLE_HOME文件系统上是否有足够的可用空间可用于要应用的修补程序，如下所示：

# su - grid

$ vi /tmp/patch_list_gihome.txt

/psu/26737266/26928563

/psu/26737266/26839277

/psu/26737266/26737232

/psu/26737266/26925644

/psu/26737266/26710464

$ $ORACLE_HOME/OPatch/opatch prereq CheckSystemSpace -phBaseFile
/tmp/patch_list_gihome.txt

Invoking prereq "checksystemspace"

Prereq "checkSystemSpace" passed.

OPatch succeeded.

# su - oracle

$ vi /tmp/patch_list_dbhome.txt

/psu/26737266/26925644

/psu/26737266/26710464

$ $ORACLE_HOME/OPatch/opatch prereq CheckSystemSpace -phBaseFile
/tmp/patch_list_dbhome.txt

Invoking prereq "checksystemspace"

Prereq "checkSystemSpace" passed.

OPatch succeeded.

# /u01/app/12.2.0/grid/OPatch/opatchauto apply /psu/26737266 -analyze

Opatch实用程序为Oracle Grid Infrastructure（GI）主页和Oracle RAC数据库主目录自动执行了修补程序应用程序。

该实用程序必须由具有root权限的操作系统（OS）用户执行，并且如果GI主目录或Oracle
RAC数据库主目录位于非共享存储中，则必须在集群中的每个节点上执行该实用程序。 该实用程序不应该在群集节点上并行运行。

OPatchauto的介绍

https://docs.oracle.com/cd/E24628_01/doc.121/e39376/opatch_overview.htm#OPTCH106

备份Oracle主目录

可以使用任何方法，例如zip，cp -r，tar，和cpio压缩Oracle主。

export ORACLE_HOME=/u01/app/12.2.0/grid

export PATH=$PATH:$ORACLE_HOME/OPatch

opatchauto apply /psu/26737266

opatchauto会自动调用Datapatch在数据库中执行需要的SQL。

Datapatch: Database 12c Post Patch SQL Automation (文档 **ID 1585822.1** )

SQL> select STATUS,DESCRIPTION from dba_registry_sqlpatch;

STATUS DESCRIPTION

\---------------
-------------------------------------------------------------------------------------

SUCCESS DATABASE RELEASE UPDATE 12.2.0.1.171017

具体内容详见readme。

## 23、部署OSW

默认30秒收集1次，总共保留2天的记录

设置开机自动启动osw监控

linux:

vi /etc/rc.local

cd /tmp/oswbb&&/tmp/oswbb/startOSWbb.sh

通过测试osw的日志默认策略
30秒*2天，大约需500M的磁盘空间，合理安排存放目录。如果需要自定义天数和扫描间隔,例如想每隔5秒收集一次,共保留7天168小时,添加参数即可.

cd /tmp/oswbb&&/tmp/oswbb/startOSWbb.sh 5 168

注意：osw默认不监控rac的心跳网络

rac环境部署osw需要将其中的Exampleprivate.net文件改名private.net并修改内容

删除非当前操作系统的部分，只保留当前系统的，如操作系统是linux ，只需要保存

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

## 24、部署rman备份脚本

创建脚本目录和备份文件目录

[root@rac1 ~]# mkdir /rmanbak

[root@rac1 ~]# chown oracle:oinstall /rmanbak

[oracle@rac1 ~]$ mkdir -p /home/oracle/scripts/rman_logs

创建备份脚本

[oracle@rac1 ~]$ vi /home/oracle/scripts/rmanbackup0.sh

#!/bin/sh

DATE=`date +%Y-%m-%d`

export ORACLE_SID=orcl1

export ORACLE_BASE=/u02/app/oracle

export ORACLE_HOME=/u02/app/oracle/product/12.2.0/db_1

$ORACLE_HOME/bin/rman cmdfile /home/oracle/scripts/backup0.sh
log=/home/oracle/scripts/rman_logs/log_rman_$DATE

[oracle@rac1 ~]$ vi /home/oracle/scripts/rmanbackup1.sh

#!/bin/sh

DATE=`date +%Y-%m-%d`

export ORACLE_SID=orcl1

export ORACLE_BASE=/u02/app/oracle

export ORACLE_HOME=/u02/app/oracle/product/12.2.0/db_1

$ORACLE_HOME/bin/rman cmdfile /home/oracle/scripts/backup1.sh
log=/home/oracle/scripts/rman_logs/log_rman_$DATE

[oracle@rac1 ~]$ vi /home/oracle/scripts/backup0.sh

connect target /

run

{

allocate channel d1 type disk;

allocate channel d2 type disk;

allocate channel d3 type disk;

backup incremental level 0 format '/rmanbak/orcl_full_%U' database;

delete noprompt obsolete device type disk;

sql 'alter system archive log current';

backup format '/rmanbak/orcl_arch_full_%U' archivelog all not backed up delete
input;

crosscheck backup;

delete noprompt expired backup;

release channel d1;

release channel d2;

release channel d3;

}

[oracle@rac1 ~]$ vi /home/oracle/scripts/backup1.sh

connect target /

run

{

allocate channel d1 type disk;

allocate channel d2 type disk;

allocate channel d3 type disk;

backup incremental level 1 format '/rmanbak/orcl_inc_%U' database;

delete noprompt obsolete device type disk;

sql 'alter system archive log current';

backup format '/rmanbak/orcl_arch_inc_%U' archivelog all not backed up delete
input;

crosscheck backup;

delete noprompt expired backup;

release channel d1;

release channel d2;

release channel d3;

}

修改脚本权限

[oracle@rac1 ~]$ chmod u+x /home/oracle/scripts/rmanbackup1.sh

[oracle@rac1 ~]$ chmod u+x /home/oracle/scripts/rmanbackup0.sh

[oracle@rac1 ~]$ chmod u+x /home/oracle/scripts/backup0.sh

[oracle@rac1 ~]$ chmod u+x /home/oracle/scripts/backup1.sh

设置rman

[oracle@rac1 ~]$ rman target /

CONFIGURE RETENTION POLICY TO REDUNDANCY 1; ---设置保留周期

CONFIGURE CONTROLFILE AUTOBACKUP ON; ---控制文件和参数文件自动备份

CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '/rmanbak/%F';
---控制文件和参数文件自动备份路径

设置计划任务

[oracle@rac1 ~]$ crontab -e

0 23 * * 6 /home/oracle/scripts/rmanbackup0.sh ----每周六做0级全备

0 23 * * 0,1,2,3,4,5 /home/oracle/scripts/rmanbackup1.sh ----其他时间做1级备份

至此结束RAC部署，重启RAC所有服务器，启动后检查相关服务及内容是否正常，方可结束安装。

## 25、安装群集和数据库失败如何快速重来，需要清理重来？

RAC 安装失败后的删除

如果已经运行了root.sh脚本则要清理掉crs磁盘组的相关共享磁盘，命令格式如下：

首先定位需要dd的磁盘，通过blkid查看可以查看UUID，fdisk查看磁盘大小，确定磁盘后使用以下命令进行dd操作：

dd if=/dev/zero of=/dev/sdb bs=1k count=3000

删除grid和oracle的软件安装目录：

[oracle]$ cd $ORACLE_HOME/deinstall

[oracle]$ ./deinstall -local

[grid]$ cd $ORACLE_HOME/deinstall

[grid]$ ./deinstall -local

 _清理完成后需要重启下所有服务器，使得相应进程关闭。_

##  _26、_ _卸载软件_

### 26.1 删除数据库

删除数据库最好也用dbca，虽然srvctl也可以。

1.运行dbca，选择”Delete database”。然后就next..，直到finish。

2.数据的删除并不影响asm实例，如果想删除与asm有关的内容，可以按如下做法：

# export ORACLE_SID=ASM_instance_name

# sqlplus / as sysdba

SQL> drop diskgroup diskgroup_name including contents;

SQL> quit

然后在各个节点上执行

# srvctl stop asm –n hostname

# srvctl remove asm –n hostname

###  _25.2_ _卸载_ _Oracle Real Application Clusters Software_

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

###  _25.3_ _卸载_ _Oracle Grid Infrastructure_

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

 _$ ./deinstall_

Measure

Measure


---
### ATTACHMENTS
[05d5fa002ea041a805d16d8af8cec6a0]: media/20180122143921_108.png
[20180122143921_108.png](media/20180122143921_108.png)
>hash: 05d5fa002ea041a805d16d8af8cec6a0  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143921_108.png  
>file-name: 20180122143921_108.png  

[08a4ea1144f1b8e2b9c758f8890281f3]: media/20180122142318_827.png
[20180122142318_827.png](media/20180122142318_827.png)
>hash: 08a4ea1144f1b8e2b9c758f8890281f3  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122142318_827.png  
>file-name: 20180122142318_827.png  

[0e4486e1b459283e55d9f957706e0196]: media/20180122143117_469.png
[20180122143117_469.png](media/20180122143117_469.png)
>hash: 0e4486e1b459283e55d9f957706e0196  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143117_469.png  
>file-name: 20180122143117_469.png  

[1156449a52fcbe3c2cba4a9db520086d]: media/20180122143407_990.png
[20180122143407_990.png](media/20180122143407_990.png)
>hash: 1156449a52fcbe3c2cba4a9db520086d  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143407_990.png  
>file-name: 20180122143407_990.png  

[1987df3b5d604f50286a5ce37a26b495]: media/20180122142353_250.png
[20180122142353_250.png](media/20180122142353_250.png)
>hash: 1987df3b5d604f50286a5ce37a26b495  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122142353_250.png  
>file-name: 20180122142353_250.png  

[1b138df9f1397ea6c6d7e74527a737de]: media/20180122143016_914.png
[20180122143016_914.png](media/20180122143016_914.png)
>hash: 1b138df9f1397ea6c6d7e74527a737de  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143016_914.png  
>file-name: 20180122143016_914.png  

[1bacdc964d18f43b983fb452e7cf7ede]: media/20180122143514_678.png
[20180122143514_678.png](media/20180122143514_678.png)
>hash: 1bacdc964d18f43b983fb452e7cf7ede  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143514_678.png  
>file-name: 20180122143514_678.png  

[2141590db298d8d8daaa38720214213d]: media/20180122143701_167.png
[20180122143701_167.png](media/20180122143701_167.png)
>hash: 2141590db298d8d8daaa38720214213d  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143701_167.png  
>file-name: 20180122143701_167.png  

[23170e6fb5615e97dad5f614d3121a5d]: media/20180122144153_739.png
[20180122144153_739.png](media/20180122144153_739.png)
>hash: 23170e6fb5615e97dad5f614d3121a5d  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122144153_739.png  
>file-name: 20180122144153_739.png  

[236fbfa7e0918796df05113f6927231c]: media/20180122143617_747.png
[20180122143617_747.png](media/20180122143617_747.png)
>hash: 236fbfa7e0918796df05113f6927231c  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143617_747.png  
>file-name: 20180122143617_747.png  

[2420caeef97407e33e9d914dabd677e1]: media/20180122143731_373.png
[20180122143731_373.png](media/20180122143731_373.png)
>hash: 2420caeef97407e33e9d914dabd677e1  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143731_373.png  
>file-name: 20180122143731_373.png  

[2963c77accd382eff59ae81dc00c767e]: media/20180122143237_304.png
[20180122143237_304.png](media/20180122143237_304.png)
>hash: 2963c77accd382eff59ae81dc00c767e  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143237_304.png  
>file-name: 20180122143237_304.png  

[2cb5934ed445dc0021dc1e939645cc85]: media/20180122143416_293.png
[20180122143416_293.png](media/20180122143416_293.png)
>hash: 2cb5934ed445dc0021dc1e939645cc85  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143416_293.png  
>file-name: 20180122143416_293.png  

[31dc747209c56dcadd079e900a834617]: media/20180122142414_137.png
[20180122142414_137.png](media/20180122142414_137.png)
>hash: 31dc747209c56dcadd079e900a834617  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122142414_137.png  
>file-name: 20180122142414_137.png  

[3b5557539fc51e056651fa243a03179b]: media/20180122142258_803.png
[20180122142258_803.png](media/20180122142258_803.png)
>hash: 3b5557539fc51e056651fa243a03179b  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122142258_803.png  
>file-name: 20180122142258_803.png  

[3b58167c0e60fd9d020104b8311c5d66]: media/20180122142658_698.png
[20180122142658_698.png](media/20180122142658_698.png)
>hash: 3b58167c0e60fd9d020104b8311c5d66  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122142658_698.png  
>file-name: 20180122142658_698.png  

[3dc10f555ac4dc012a3c48e5e1994859]: media/20180122144038_259.png
[20180122144038_259.png](media/20180122144038_259.png)
>hash: 3dc10f555ac4dc012a3c48e5e1994859  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122144038_259.png  
>file-name: 20180122144038_259.png  

[4035799a5fa6621b617ac10dc0b1b3f4]: media/20180122142934_580.png
[20180122142934_580.png](media/20180122142934_580.png)
>hash: 4035799a5fa6621b617ac10dc0b1b3f4  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122142934_580.png  
>file-name: 20180122142934_580.png  

[42fc71673c06760895cff1a785d9b479]: media/20180122143653_307.png
[20180122143653_307.png](media/20180122143653_307.png)
>hash: 42fc71673c06760895cff1a785d9b479  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143653_307.png  
>file-name: 20180122143653_307.png  

[44d4f7a5c31827c8e342e11e8735fc4e]: media/20180122143352_703.png
[20180122143352_703.png](media/20180122143352_703.png)
>hash: 44d4f7a5c31827c8e342e11e8735fc4e  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143352_703.png  
>file-name: 20180122143352_703.png  

[4e8c5f615754c9539a75e20320038d1b]: media/20180122142339_355.png
[20180122142339_355.png](media/20180122142339_355.png)
>hash: 4e8c5f615754c9539a75e20320038d1b  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122142339_355.png  
>file-name: 20180122142339_355.png  

[4ebf48bc9b5df327ca8097f752e2112e]: media/20180122143401_550.png
[20180122143401_550.png](media/20180122143401_550.png)
>hash: 4ebf48bc9b5df327ca8097f752e2112e  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143401_550.png  
>file-name: 20180122143401_550.png  

[5008513ad91dc1af409b7e6366505364]: media/20180122143819_788.png
[20180122143819_788.png](media/20180122143819_788.png)
>hash: 5008513ad91dc1af409b7e6366505364  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143819_788.png  
>file-name: 20180122143819_788.png  

[53712b23c39e10b4fd6f800e83212d8c]: media/20180122142102_205.png
[20180122142102_205.png](media/20180122142102_205.png)
>hash: 53712b23c39e10b4fd6f800e83212d8c  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122142102_205.png  
>file-name: 20180122142102_205.png  

[54a9408c20c1c8daf54a525ff6af629e]: media/20180122142911_63.png
[20180122142911_63.png](media/20180122142911_63.png)
>hash: 54a9408c20c1c8daf54a525ff6af629e  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122142911_63.png  
>file-name: 20180122142911_63.png  

[54e719e26126beb43ecf1e26fa6894a5]: media/20180122143608_806.png
[20180122143608_806.png](media/20180122143608_806.png)
>hash: 54e719e26126beb43ecf1e26fa6894a5  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143608_806.png  
>file-name: 20180122143608_806.png  

[57d9141a995bf3ad99ec2ec7f5ec16c5]: media/20180122142903_471.png
[20180122142903_471.png](media/20180122142903_471.png)
>hash: 57d9141a995bf3ad99ec2ec7f5ec16c5  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122142903_471.png  
>file-name: 20180122142903_471.png  

[593a0bc3faceabb676f8df6d00aa0df2]: media/20180122143522_921.png
[20180122143522_921.png](media/20180122143522_921.png)
>hash: 593a0bc3faceabb676f8df6d00aa0df2  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143522_921.png  
>file-name: 20180122143522_921.png  

[5ce374a8a3bf74015a820770fb01944f]: media/20180122143812_752.png
[20180122143812_752.png](media/20180122143812_752.png)
>hash: 5ce374a8a3bf74015a820770fb01944f  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143812_752.png  
>file-name: 20180122143812_752.png  

[60bb1a53feb7d645f2c4e35bf83d901e]: media/20180122143255_532.png
[20180122143255_532.png](media/20180122143255_532.png)
>hash: 60bb1a53feb7d645f2c4e35bf83d901e  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143255_532.png  
>file-name: 20180122143255_532.png  

[61ad6f279826ed136edf672e6036c75d]: media/20180122143709_940.png
[20180122143709_940.png](media/20180122143709_940.png)
>hash: 61ad6f279826ed136edf672e6036c75d  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143709_940.png  
>file-name: 20180122143709_940.png  

[63915ebd491cbbb7846ba53c6ee32aa1]: media/20180122144021_973.png
[20180122144021_973.png](media/20180122144021_973.png)
>hash: 63915ebd491cbbb7846ba53c6ee32aa1  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122144021_973.png  
>file-name: 20180122144021_973.png  

[641f6239e291ea585dad5da285ebd9f7]: media/20180122143037_490.png
[20180122143037_490.png](media/20180122143037_490.png)
>hash: 641f6239e291ea585dad5da285ebd9f7  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143037_490.png  
>file-name: 20180122143037_490.png  

[6749909412404fd091bffa0c50d14a7a]: media/20180122143101_554.png
[20180122143101_554.png](media/20180122143101_554.png)
>hash: 6749909412404fd091bffa0c50d14a7a  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143101_554.png  
>file-name: 20180122143101_554.png  

[7057c5c317a3bb074819737403ab8137]: media/20180122143929_430.png
[20180122143929_430.png](media/20180122143929_430.png)
>hash: 7057c5c317a3bb074819737403ab8137  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143929_430.png  
>file-name: 20180122143929_430.png  

[706c81a99df80d70fdd5db6d01061741]: media/20180122143540_14.png
[20180122143540_14.png](media/20180122143540_14.png)
>hash: 706c81a99df80d70fdd5db6d01061741  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143540_14.png  
>file-name: 20180122143540_14.png  

[7363c02adb709ae5e1be5a9346124789]: media/20180122144012_422.png
[20180122144012_422.png](media/20180122144012_422.png)
>hash: 7363c02adb709ae5e1be5a9346124789  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122144012_422.png  
>file-name: 20180122144012_422.png  

[758520e9291d70fa540a5ca53035f4f0]: media/20180122143201_207.png
[20180122143201_207.png](media/20180122143201_207.png)
>hash: 758520e9291d70fa540a5ca53035f4f0  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143201_207.png  
>file-name: 20180122143201_207.png  

[77483b213fd28c256f8e2b3cec2ddf19]: media/20180122143805_373.png
[20180122143805_373.png](media/20180122143805_373.png)
>hash: 77483b213fd28c256f8e2b3cec2ddf19  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143805_373.png  
>file-name: 20180122143805_373.png  

[848b304da9f6e188d23f8fea7c364dcd]: media/20180122142803_657.png
[20180122142803_657.png](media/20180122142803_657.png)
>hash: 848b304da9f6e188d23f8fea7c364dcd  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122142803_657.png  
>file-name: 20180122142803_657.png  

[851db08e1fac961ccbeba9fdea58f197]: media/20180122142839_245.png
[20180122142839_245.png](media/20180122142839_245.png)
>hash: 851db08e1fac961ccbeba9fdea58f197  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122142839_245.png  
>file-name: 20180122142839_245.png  

[884342cf5d2743875494257fb06dab51]: media/20180122144004_205.png
[20180122144004_205.png](media/20180122144004_205.png)
>hash: 884342cf5d2743875494257fb06dab51  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122144004_205.png  
>file-name: 20180122144004_205.png  

[8a271356e8b7600e0c3808235fccde9d]: media/20180122144140_672.png
[20180122144140_672.png](media/20180122144140_672.png)
>hash: 8a271356e8b7600e0c3808235fccde9d  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122144140_672.png  
>file-name: 20180122144140_672.png  

[8ed74da991432e7652c685eb0151b0fc]: media/20180122143000_899.png
[20180122143000_899.png](media/20180122143000_899.png)
>hash: 8ed74da991432e7652c685eb0151b0fc  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143000_899.png  
>file-name: 20180122143000_899.png  

[90298a03fab91cf3e7bf6f0a23723415]: media/20180122142721_978.png
[20180122142721_978.png](media/20180122142721_978.png)
>hash: 90298a03fab91cf3e7bf6f0a23723415  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122142721_978.png  
>file-name: 20180122142721_978.png  

[989cecb1b246c85ae21b724a5c9ef219]: media/20180122143109_825.png
[20180122143109_825.png](media/20180122143109_825.png)
>hash: 989cecb1b246c85ae21b724a5c9ef219  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143109_825.png  
>file-name: 20180122143109_825.png  

[99b11fccf4d19044c9d6c1ab3956ec71]: media/20180122143717_135.png
[20180122143717_135.png](media/20180122143717_135.png)
>hash: 99b11fccf4d19044c9d6c1ab3956ec71  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143717_135.png  
>file-name: 20180122143717_135.png  

[9b2d1eb2bb34a7f55197c2a91fdc3dbf]: media/20180122142919_996.png
[20180122142919_996.png](media/20180122142919_996.png)
>hash: 9b2d1eb2bb34a7f55197c2a91fdc3dbf  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122142919_996.png  
>file-name: 20180122142919_996.png  

[a36bce0d9e22d1a92c7639d62ef75ae4]: media/20180122144205_657.png
[20180122144205_657.png](media/20180122144205_657.png)
>hash: a36bce0d9e22d1a92c7639d62ef75ae4  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122144205_657.png  
>file-name: 20180122144205_657.png  

[a612157a35b292177416d9638b10b970]: media/20180122143008_677.png
[20180122143008_677.png](media/20180122143008_677.png)
>hash: a612157a35b292177416d9638b10b970  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143008_677.png  
>file-name: 20180122143008_677.png  

[a68c7a3db97bedc1cff0f1b0125374bd]: media/20180122143145_913.png
[20180122143145_913.png](media/20180122143145_913.png)
>hash: a68c7a3db97bedc1cff0f1b0125374bd  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143145_913.png  
>file-name: 20180122143145_913.png  

[a7c87e8515918ea499fefd4ccd5c7bf2]: media/20180122143740_759.png
[20180122143740_759.png](media/20180122143740_759.png)
>hash: a7c87e8515918ea499fefd4ccd5c7bf2  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143740_759.png  
>file-name: 20180122143740_759.png  

[b17285b33f29e26ce925a5c6b0fb948a]: media/20180122144045_219.png
[20180122144045_219.png](media/20180122144045_219.png)
>hash: b17285b33f29e26ce925a5c6b0fb948a  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122144045_219.png  
>file-name: 20180122144045_219.png  

[b2a19d02dd9073e5b2e7cc820213ab13]: media/20180122143136_565.png
[20180122143136_565.png](media/20180122143136_565.png)
>hash: b2a19d02dd9073e5b2e7cc820213ab13  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143136_565.png  
>file-name: 20180122143136_565.png  

[b2e4ae78718f6d011b7a6b429c02bc5a]: media/20180122143559_493.png
[20180122143559_493.png](media/20180122143559_493.png)
>hash: b2e4ae78718f6d011b7a6b429c02bc5a  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143559_493.png  
>file-name: 20180122143559_493.png  

[b668bd69e1186aae86f6fe9d60b6b6b1]: media/20180122143506_101.png
[20180122143506_101.png](media/20180122143506_101.png)
>hash: b668bd69e1186aae86f6fe9d60b6b6b1  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143506_101.png  
>file-name: 20180122143506_101.png  

[b689c48688bd4a0ebbb72983a4c0995f]: media/20180122142739_226.png
[20180122142739_226.png](media/20180122142739_226.png)
>hash: b689c48688bd4a0ebbb72983a4c0995f  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122142739_226.png  
>file-name: 20180122142739_226.png  

[c190edbf30ab7d5b9b8f50ce8203a853]: media/20180122143844_884.png
[20180122143844_884.png](media/20180122143844_884.png)
>hash: c190edbf30ab7d5b9b8f50ce8203a853  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143844_884.png  
>file-name: 20180122143844_884.png  

[c1c109f7463615befd15258c5f38c512]: media/20180122142305_726.png
[20180122142305_726.png](media/20180122142305_726.png)
>hash: c1c109f7463615befd15258c5f38c512  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122142305_726.png  
>file-name: 20180122142305_726.png  

[c4dcfd30b2e651297dcd8c8a476fa2fc]: media/20180122143724_345.png
[20180122143724_345.png](media/20180122143724_345.png)
>hash: c4dcfd30b2e651297dcd8c8a476fa2fc  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143724_345.png  
>file-name: 20180122143724_345.png  

[c5dad94f066550f67acea722f63bba08]: media/20180122143532_597.png
[20180122143532_597.png](media/20180122143532_597.png)
>hash: c5dad94f066550f67acea722f63bba08  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143532_597.png  
>file-name: 20180122143532_597.png  

[c8ea587c47d301a962d768a4c923583c]: media/20180122144146_111.png
[20180122144146_111.png](media/20180122144146_111.png)
>hash: c8ea587c47d301a962d768a4c923583c  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122144146_111.png  
>file-name: 20180122144146_111.png  

[cda772788e176e1b82d1021e89a19e38]: media/20180122144159_886.png
[20180122144159_886.png](media/20180122144159_886.png)
>hash: cda772788e176e1b82d1021e89a19e38  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122144159_886.png  
>file-name: 20180122144159_886.png  

[d344b9d620f431c8c8afeccb14731b62]: media/20180122143549_380.png
[20180122143549_380.png](media/20180122143549_380.png)
>hash: d344b9d620f431c8c8afeccb14731b62  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143549_380.png  
>file-name: 20180122143549_380.png  

[e0616bb3786284d9abd5c15627316dc8]: media/20180122143458_745.png
[20180122143458_745.png](media/20180122143458_745.png)
>hash: e0616bb3786284d9abd5c15627316dc8  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143458_745.png  
>file-name: 20180122143458_745.png  

[e0f9ca6bd4fa32d94b91d45aa80fee51]: media/20180122143228_208.png
[20180122143228_208.png](media/20180122143228_208.png)
>hash: e0f9ca6bd4fa32d94b91d45aa80fee51  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143228_208.png  
>file-name: 20180122143228_208.png  

[e286d990949360b9076023d521fd72c2]: media/20180122142651_932.png
[20180122142651_932.png](media/20180122142651_932.png)
>hash: e286d990949360b9076023d521fd72c2  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122142651_932.png  
>file-name: 20180122142651_932.png  

[e3c3675cc221e03a3457901e23477b0b]: media/20180122143314_213.png
[20180122143314_213.png](media/20180122143314_213.png)
>hash: e3c3675cc221e03a3457901e23477b0b  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143314_213.png  
>file-name: 20180122143314_213.png  

[e50e31a2d098cd1dc957697d117964bc]: media/20180122143837_764.png
[20180122143837_764.png](media/20180122143837_764.png)
>hash: e50e31a2d098cd1dc957697d117964bc  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143837_764.png  
>file-name: 20180122143837_764.png  

[e5d7283deda794199c2515d7f503a379]: media/20180122142311_806.png
[20180122142311_806.png](media/20180122142311_806.png)
>hash: e5d7283deda794199c2515d7f503a379  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122142311_806.png  
>file-name: 20180122142311_806.png  

[e667becc8816e7deaa7000a7af185411]: media/20180122143344_12.png
[20180122143344_12.png](media/20180122143344_12.png)
>hash: e667becc8816e7deaa7000a7af185411  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143344_12.png  
>file-name: 20180122143344_12.png  

[e77c0c9a13f3c35df63cc2a96dfb85ed]: media/20180122142704_65.png
[20180122142704_65.png](media/20180122142704_65.png)
>hash: e77c0c9a13f3c35df63cc2a96dfb85ed  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122142704_65.png  
>file-name: 20180122142704_65.png  

[ebf0983a5b93b453032c5a4ea8c22cef]: media/20180122144133_77.png
[20180122144133_77.png](media/20180122144133_77.png)
>hash: ebf0983a5b93b453032c5a4ea8c22cef  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122144133_77.png  
>file-name: 20180122144133_77.png  

[ed7741695e63de8dece854324dbd16a0]: media/20180122142927_527.png
[20180122142927_527.png](media/20180122142927_527.png)
>hash: ed7741695e63de8dece854324dbd16a0  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122142927_527.png  
>file-name: 20180122142927_527.png  

[f76ea10864b281c25d8ca9155cbc0b76]: media/20180122143913_400.png
[20180122143913_400.png](media/20180122143913_400.png)
>hash: f76ea10864b281c25d8ca9155cbc0b76  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143913_400.png  
>file-name: 20180122143913_400.png  

[f877960ca4ee772375e2f89e3ef1fe1d]: media/20180122142422_339.png
[20180122142422_339.png](media/20180122142422_339.png)
>hash: f877960ca4ee772375e2f89e3ef1fe1d  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122142422_339.png  
>file-name: 20180122142422_339.png  

[f9a70275d0a2a393affc1ffa80a80149]: media/20180122143905_262.png
[20180122143905_262.png](media/20180122143905_262.png)
>hash: f9a70275d0a2a393affc1ffa80a80149  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122143905_262.png  
>file-name: 20180122143905_262.png  

[fb0a0e9cd2b3f4c682747621e4d053f7]: media/20180122144030_65.png
[20180122144030_65.png](media/20180122144030_65.png)
>hash: fb0a0e9cd2b3f4c682747621e4d053f7  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122144030_65.png  
>file-name: 20180122144030_65.png  


---
### TAGS
{Support20180830}

---
### NOTE ATTRIBUTES
>Created Date: 2018-08-30 01:58:19  
>Last Evernote Update Date: 2018-10-01 15:33:57  
>source: web.clip7  
>source-url: https://47.100.29.40/highgo_admin/#/index/docSearchDetail/20c446046286ef  
>source-application: WebClipper 7  