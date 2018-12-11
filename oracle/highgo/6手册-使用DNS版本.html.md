# 6手册-使用DNS版本.html

You need to enable JavaScript to run this app.

## 新特性

l        Oracle 11gR2将自动存储 **管理** (ASM)和Oracle Clusterware集成在Oracle Grid
Infrastructure中。Oracle ASM和Oracle Database
11gR2提供了较以前版本更为增强的存储解决方案，该解决方案能够在ASM上存储Oracle
Clusterware文件，即Oracle集群注册表(OCR)和表决文件（VF，又称为表决磁盘）。这一特性使ASM能够提供一个统一的存储解决方案，无需使用第三方卷管理器或集群文件系统即可存储集群件和数据库的所有数据

l        SCAN（single client access name）即简单客户端连接名，一个方便客户端连接的接口；在Oracle
11gR2之前，client链接数据库的时候要用vip，假如cluster有4个节点，那么客户端的tnsnames.ora中就对应有四个主机vip的一个连接串，如果cluster增加了一个节点，那么对于每个连接数据库的客户端都需要修改这个tnsnames.ora。SCAN简化了客户端连接，客户端连接的时候只需要知道这个名称，并连接即可，每个SCAN
VIP对应一个scan listener，cluster内部的service在每个scan listener上都有注册，scan
listener接受客户端的请求，并转发到不同的Local listener中去，由local的listener提供服务给客户端

l
此外，安装GRID的过程也简化了很多，内核参数的设置可保证安装的最低设置，验证安装后执行fixup.sh即可，此外ssh互信设置可以自动完成，尤其不再使用OCFS及其复杂设置，直接使用ASM存储

# DNS服务器配置

 **参考文档      Linux: How to Configure the DNS Server for 11gR2 SCAN (文档 ID
1107295.1)**

DNS服务器OS版本 RHEL6.7x64

## 1、安装相应的包

[root@dns ~]#  yum install bind bind-chroot



## 2、修改/etc/resolv.conf

domain highgo.com

nameserver 186.168.100.116

options rotate

options timeout:2

options attempts:5

## 3、修改/etc/named.conf



修改的内容如下



//

// named.conf

//

// Provided by Red Hat bind package to configure the ISC BIND named(8) DNS

// server as a caching only nameserver (as a localhost DNS resolver only).

//

// See /usr/share/doc/bind*/sample/ for example named configuration files.

//



options {

        listen-on port 53 { any; };

        listen-on-v6 port 53 { ::1; };

        directory       "/var/named";

        dump-file       "/var/named/data/cache_dump.db";

        statistics-file "/var/named/data/named_stats.txt";

        memstatistics-file "/var/named/data/named_mem_stats.txt";

        allow-query     { any; };

        recursion yes;



        dnssec-enable yes;

        dnssec-validation yes;

        dnssec-lookaside auto;



        /* Path to ISC DLV key */

        bindkeys-file "/etc/named.iscdlv.key";



        managed-keys-directory "/var/named/dynamic";

};



logging {

        channel default_debug {

                file "data/named.run";

                severity dynamic;

        };

};



zone "." IN {

        type hint;

        file "named.ca";

};



include "/etc/named.rfc1912.zones";

include "/etc/named.root.key";



## 4、修改/etc/named.rfc1912.zones



添加如下内容

zone "highgo.com" IN {

        type master;

        file "highgo.com.zone";

        allow-update { none; };

};



zone "100.168.186.in-addr.arpa" IN {

        type master;

        file "100.168.186.in-addr.arpa";

        allow-update { none; };

};





\---------------------------

说明：



zone "highgo.com" IN {
#正向。highgo.com为域名，此域名的声明要放到 resolv.conf 文件中

        type master;

        file "highgo.com.zone";                             #正向解析文件名称 此文件目录/var/named

        allow-update { none; };

};



zone "100.168.186.in-addr.arpa" IN {
#反向，100.168.186为所要解析的ip网段

        type master;

        file "100.168.186.in-addr.arpa";                             #反向解析文件名称此文件目录/var/named

        allow-update { none; };

};



这里需要注意的是，反向解析从左到右读取ip地址时是以相反的方向解释的，所以需要将ip地址反向排列。这里，192.168.8.*网段的反向解析域名为"8.168.192.in-
addr.arpa"。

\------------------------------------------------------------------------------



## 5、利用模板文件创建用于正向解析和反向解析文件





创建正向解析文件



 cp -p /var/named/named.localhost /var/named/highgo.com.zone



创建反向解析文件



cp -p /var/named/named.loopback /var/named/100.168.186.in-addr.arpa







## 6、修改正向解析文件

$TTL 1D

@       IN SOA  @ rname.invalid. (

                                        0       ; serial

                                        1D      ; refresh

                                        1H      ; retry

                                        1W      ; expire

                                        3H )    ; minimum

        NS      @

        A       186.168.100.116

        AAAA    ::1

scan-ip  in A 186.188.100.115

scan-ip  in A 186.188.100.117

scan-ip  in A 186.188.100.118





## 7、修改反向解析文件



$ORIGIN 100.168.186.in-addr.arpa.

$TTL 1H

@ IN SOA pera.com. root.pera.com. ( 2

3H

1H

1W

1H )

100.168.186.in-addr.arpa. IN NS pera.com.



115 IN PTR scan-ip.pera.com.

118 IN PTR scan-ip.pera.com.

117 IN PTR scan-ip.pera.com.







## 8、重启named

[root@dns named]# /etc/rc.d/init.d/named restart



如果卡在

Stopping named: [  OK  ]

Generating /etc/rndc.key:

执行

rndc-confgen -r /dev/urandom -a



## 9、修改named开机自启

chkconfig named on



## 10、修改所有rac节点的/etc/resolv.conf文件，添加以下内容

domain highgo.com

nameserver 186.168.100.116

options rotate

options timeout:2

options attempts:5

## 11、修改所有rac节点的/etc/nsswitch.conf

将第38行修改为以下内容

hosts:      dns files nis

## 12、在所有节点（包括dns节点和rac节点）执行如下命令检查

如果可以正常返回结果，说明配置正确

 **[root@dns named]# nslookup scan-ip.highgo.com**

Server:         186.168.100.116

Address:        186.168.100.116#53



Name:   scan-ip.highgo.com

Address: 186.188.100.115

Name:   scan-ip.highgo.com

Address: 186.188.100.117

Name:   scan-ip.highgo.com

Address: 186.188.100.118

 **[root@dns named]# nslookup 186.168.100.115**

Server:         186.168.100.116

Address:        186.168.100.116#53



115.100.168.186.in-addr.arpa    name = scan-ip.highgo.com.



 **[root@dns named]# nslookup 186.168.100.117**

Server:         186.168.100.116

Address:        186.168.100.116#53



117.100.168.186.in-addr.arpa    name = scan-ip.highgo.com.



 **[root@dns named]# nslookup 186.168.100.118**

Server:         186.168.100.116

Address:        186.168.100.116#53



118.100.168.186.in-addr.arpa    name = scan-ip.highgo.com







# RAC安装步骤

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

#rhel5需要关闭sendmail



chkconfig sendmail off

关闭防火墙

chkconfig iptables off

关闭selinux:

vi /etc/selinux/config

SELINUX=disabled

#avahi-daemon 1501093.1

chkconfig  avahi-daemon off

#6.x版本上关闭 NetworkManager 服务

chkconfig NetworkManager off

#6.x版本要执行创建如下软连接

ln -s /lib64/libcap.so.2.16 /lib64/libcap.so.1

## 3、网络配置

Hosts文件配置

每个主机vi /etc/hosts



186.168.100.25    rac1

186.168.100.26    rac2



192.0.10.125    rac1-priv

192.0.10.126    rac2-priv



186.168.100.125   rac1-vip

186.168.100.130   rac2-vip



rac1、rac2 对应的是网卡的物理ip ，即public ip

rac1-priv、rac2-priv 对应的是心跳网卡的物理ip  即private ip

rac1-vip、rac2-vip 对应的是虚拟VIP

 **因为通过DNS解析SCAN，所以不需要添加scanip的hosts解析**



建议客户客户端连接rac群集，访问数据库时使用  SCAN  ip地址。

 **注意** **：vip 、** **public ip 、** **scan ip 必须要在同一个子网网段中。**

 **另外** **对于心跳** **IP 地址的设置** **， 不要设置成和客户局域网中存在的** **ip 网段。**

 **如客户网络是192.x.x.x 则设置心跳为 10.x.x.x
,心跳地址工程师可以自定义，但也要和客户确认客户局域网络是否有相同ip地址的服务器，尽量避免干扰。**



配置完心跳地址后,一定要使用traceroute测试心跳网络之间通讯是否正常.心跳通讯是否正常不能简单地通过ping命令来检测.一定要使用traceroute默认是采用udp协议.每次执行traceroute会发起三次检测,*号表示通讯失败.

正常:

[root@rac1 ~]# traceroute rac2-priv

traceroute to rac2-priv (192.0.10.126), 30 hops max, 60 byte packets

1          lsrac2-priv (192.0.10.126)  **0.802 ms   0.655 ms  0.636 ms**

不正常:

[root@lsrac1 ~]# traceroute rac2-priv

traceroute to rac2-priv (192.0.10.126), 30 hops max, 60 byte packets

 1  lsrac2-priv (192.0.10.126)  1.187 ms *** ***

 如果经常出现* 则需要先检测心跳网络通讯是否正常.



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
ksh  libaio libaio  libaio-devel  libaio-devel libgcc  libstdc++
libstdc++-devel make sysstat unixODBC unixODBC unixODBC-devel unixODBC-devel
iscsi lsscsi*  -y

## 5、内核参数

 **/etc/sysctl.conf  ** **这里面的修改可以通过安装过程中运行**` **runfixup.sh**` **脚本自动修改。**

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

  

## 6、设置oracle的shell限制：

在/etc/security/limits.conf文件中加入

rhel 5>



grid                 soft    nproc   2047

grid                 hard    nproc   16384

grid                 soft    nofile   1024

grid                 hard    nofile   65536

grid                 hard    stack    10240

oracle               soft    nproc    2047

oracle               hard    nproc   16384

oracle               soft    nofile   1024

oracle               hard    nofile  65536

oracle               hard    stack   10240



修改使以上参数生效：

vi /etc/pam.d/login

添加如下行

session required pam_limits.so



rhel6 或更高版本 则要注意

nproc参数的生效并不是在/etc/security/limits.conf里生效，是需要在

/etc/security/limits.d/90-nproc.conf 文件中设置

参考：

![t](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.4665511072558828.png)

|

 **Setting nproc values on Oracle Linux 6 for   RHCK kernel (** **文档** **ID
2108775.1)**  
  
---|---  
  


[root@localhost limits.d]# cat 90-nproc.conf

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

检查多个服务器节点的操作系统时间是否一致。如果不一致要先手动修改。

如何同时修改两台或者多台主机的时间一模一样呢？

建议使用SecureCRT工具、

使用方法：先登录一台主机

![noteattachment1][b1dd40ca6756ab53dc5bffbf348baa6f]

然后登录第二台主机

![noteattachment2][9b24e34bab9b46d80af8bbad357738b2]

打开查看菜单，勾选交互窗口

![noteattachment3][e44a7029b80405829625776f3754974e]

窗口下方出现交互窗口

![noteattachment4][3c53d6a4a43d1de9eb5e25221a4e642f]

在交互窗口上右键菜单，勾选发送交互到所有会话。（此时要注意这个CRT窗口必须只能有RAC的两台服务器，不能有到其他主机的远程连接会话）

![noteattachment5][b391f63198892626fe407c03043fb5f5]

然后此时在交互窗口里输入的命令回车后都会自动发送到所有主机上执行。

linx修改时间的命令是  ：年月日 时分秒

[root@rhel ~]# date -s "20100405 14:31:00"



关闭NTP服务

Network Time Protocol Setting

# /sbin/service ntpd stop

# chkconfig ntpd off

#mv /etc/ntp.conf   /etc/ntp.conf.org.

#service ntpd status

一定要保证时间同步，但是不能配置ntp，否则会导致11g的ctssd处于旁观模式。如果客户严格要求和北京时间一致，则考虑让客户提供时间服务器，然后再采用NTP和其时间服务器同步。如果配置NTP注意参数
-x 保证时间不能向回调，关于NTP配置此处不做详细解释。







## 8、修改主机名

每个主机均要修改：

vi /etc/sysconfig/network

将其中HOSTNAME改为主机名，如下：

HOSTNAME=rac1

注意主机名不能过长,不能超过8个字符，且不能有下划线等特殊符号，不要使用大写字母，建议使用小写字母即可。

修改完主机名务必重启生效



## 9、添加用户和组、创建目录

 **描述**

|

 **OS** **组名**

|

 **分配给该组的** **OS** **用户**

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

# mkdir -p  /u01/app/11.2.0/grid

# chown grid:oinstall /u01/  -R

# chmod 775 /u01/ -R

    
    
    创建oracle目录

  

# mkdir -p  /u02/app/oracle/product/11.2.0/db_home

# chown oracle:oinstall /u02/ -R

# chmod  775 /u02/ -R



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



 **注意： grid 用户环境变量 ORACLE_HOME 不在ORACLE_BASE 目录下  **

 **su - oracle**

修改oracle 用户环境变量,其中ORACLE_SID ，让开发商定好数据库名称，SID后面分别添加1和2。

su - oracle

vi .bash_profile

export ORACLE_SID=orcl1

export ORACLE_BASE=/u02/app/oracle

export ORACLE_HOME=/u02/app/oracle/product/11.2.0/db_home

PATH=$ORACLE_HOME/bin:$PATH:$HOME/bin

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



 **注意： grid 用户环境变量 ORACLE_HOME 不在ORACLE_BASE 目录下  **

 **su - oracle**

修改oracle 用户环境变量

export ORACLE_SID=orcl2

export ORACLE_BASE=/u02/app/oracle

export ORACLE_HOME=/u02/app/oracle/product/11.2.0/db_home

PATH=$ORACLE_HOME/bin:$PATH:$HOME/bin

umask 022

export PATH



## 10、ASM配置共享磁盘

 ** _配置iscsi_**

 ** _在_** ** _RHEL5_** ** _系统中_** ** _,_** **_下载并安装_** ** _iSCSI_** **
_启动器软件包_** _  
 **# rpm -ivh iscsi-initiator-utils-6.2.0.742-0.5.el5.i386.rpm**  
 **2.**_ **_在_** ** _RHEL5_** ** _系统中_** ** _,_** **_生成并查看_** ** _iSCSI_** **
_启动器的名称_** _  
 **# echo "InitiatorName=`iscsi-iname`" >/etc/iscsi/initiatorname.iscsi**  
 **# cat /etc/iscsi/initiatorname.iscsi**  
InitiatorName=iqn.2005-03.com.redhat:01.b9d0dd11016  
 **3.**_ **_在_** ** _RHEL5_** ** _系统中_** ** _,_** **_配置_** ** _iSCSI_** **
_启动器服务_** _  
 **# vi /etc/iscsi/iscsid.conf** (iSCSI_ _启动器服务的配置文件_ _)_ _  
node.session.auth.authmethod = CHAP  
node.session.auth.username = iqn.2005-03.com.redhat:01.b9d0dd11016  
node.session.auth.password = 01.b9d0dd11016  
 **# chkconfig iscsi --level 35 on**  
 **4.**_ **_在_** ** _SmartWin_** ** _存储设备中_** ** _,_** **_创建并分配一个_** **
_iSCSI_** ** _共享_** _  
_**_通过共享管理_** ** _-iSCSI_** ** _共享_** ** _,_** **_使用_** ** _iSCSI_** **
_共享虚拟磁盘创建一个_** ** _iSCSI_** ** _共享_** ** _;_** _  
_**_根据第_** ** _3_** ** _步得到的_** ** _iSCSI_** ** _启动器的名称_** ** _,_** **_使用_**
** _CHAP_** ** _认证模式进行分配_** ** _;_** _  
_**_启动器名称_** ** _:_** _iqn.2005-03.com.redhat:01.b9d0dd11016  
_ **_启动器口令_** ** _:_** _01.b9d0dd11016_ _  
 **5.**_ **_在_** ** _RHEL5_** ** _系统中_** ** _,_** **_启动_** ** _iSCSI_** **
_启动器服务_** _  
 **# service iscsi start**  
 **# iscsiadm -m discovery -t st -p 192.168.1.2** (_ _发现_ _)_ _  
192.168.1.2:3260,1 iqn.2004-01.com.company:block-wb  
 **# iscsiadm -m node -T iqn.2004-01.com.company:block-wb -p 192.168.1.2 -l**_

 _ _

 _ _

###  _10.1_ _自动存储管理器_ _(ASM)_

 _从_
_http://www.oracle.com/technetwork/topics/linux/downloads/rhel5-084877.html_
_找到要下载的三个_ _RPM_ _软件包，注意，一定要与内核版本和系统平台相符。_

 _Uname  –a_ _查看系统版本_

 _ _

 ** _对_** ** _ASM_** ** _进行配置_** _：_

 _# /etc/init.d/oracleasm configure_

 _Configuring the Oracle ASM library driver._

 _这将配置_ _Oracle ASM_ _库驱动程序的启动时属性。以下问题将确定在启动时是否加载驱动程序以及它将拥有的权限。当前值将显示在方括号（_
_“[]”_ _）中。按_ _< ENTER>_ _而不键入回应将保留该当前值。按_ _Ctrl-C_ _将终止。_

 _Default user to own the driver interface []: **grid**_

 _Default group to own the driver interface []: **oinstall**_

 _Start Oracle ASM library driver on boot (y/n) [n]: **y**_

 _Fix permissions of Oracle ASM disks on boot (y/n) [y]: **y**_

 _Writing Oracle ASM library driver configuration
done_

 _Creating /dev/oracleasm mount point
done_

 _Loading module "oracleasm"
done_

 _Mounting ASMlib driver filesystem                            done_

 _Scanning system for ASM disks
done_

 _AMS_ _的命令如下所示：_

![文本框: oracle@DBRAC1:~> /etc/init.d/oracleasm Usage: /etc/init.d/oracleasm
{start|stop|restart|enable|disable|configure|createdisk|deletedisk|querydisk|listdisks|scandisks|status}](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.6914573146842611.png)

 _现在，如下所示启用_ _ASMLib_ _驱动程序。_

 ** _# /etc/init.d/oracleasm enable_**

 _Writing Oracle ASM library driver configuration
[  OK  ]_

 _Scanning system for ASM disks                                              [
OK  ]_

 _ASM_ _的安装和配置是要在集群中的每个节点上执行的_

 _ _

 _为_ _oracle_ _创建_ _ASM_ _磁盘：_

 _创建_ _ASM_ _磁盘只需在_ _RAC_ _集群中的一个节点上以_ _root_ _用户帐户执行。我将在_ _rac1_
_上运行这些命令。在另一个_ _Oracle RAC_ _节点上，您将需要执行_ _scandisk_ _以识别新卷。该操作完成后，应在两个_
_Oracle RAC_ _节点上运行_ _oracleasm listdisks_ _命令以验证是否创建了所有_ _ASM_ _磁盘以及它们是否可用。_

 _ _

 _#/etc/init.d/oracleasm createdisk   CRS  /dev/sdd1_

 _#/etc/init.d/oracleasm createdisk   DATA  /dev/sdd2_

 _#/etc/init.d/oracleasm createdisk   FRA  /dev/sdd3_

 _ _

 _/etc/init.d/oracleasm scandisks_

 _Scanning the system for Oracle ASMLib disks:                [  OK  ]_

 _ _

 _# /etc/init.d/oracleasm listdisks_

 _CRS_

 _DATA_

 _FRA_

 _ _





### 10.2原始设备

主要分如下三种情况：



情况1、使用存储专用多路径软件的情况：

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

start_udev

检查是否生成ls -l /dev/raw/raw*磁盘,以及磁盘权限是否是grid:asmadmin

情况2、使用linux操作系统自带multipath多路径软件的情况：

分rhel 5，和rhel 6两种情况。

 **rhel5:**

参考文章：

![t](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.5113417113793886.png)

|

 **Configuring raw   devices (multipath) for Oracle Clusterware 10g Release 2
(10.2.0) on   RHEL5/OL5 (** **文档** **ID 564580.1)**  
  
---|---  
  
 **Configuring non-raw multipath devices for Oracle Clusterware 11g (11.1.0,
11.2.0) on RHEL5/OL5 (** **文档** **ID 605828.1)**

 ** **

尽量让系统工程师或者存储工程师去配置multipath多路径。

对于multipath多路径我们只提一个要求，就是磁盘要必须使用别名 alias。

如果需要我们进行多路径配置，则配置方法如下：



查询磁盘设备的wwid

for i in `cat /proc/partitions | awk '{print $4}' |grep sd | grep [a-z]$`; do
echo "### $i: `scsi_id -g -u  -s  /block/$i`"; done



修改配置文件/etc/scsi_id.config内容如下：

vendor="ATA",options=-p 0x80  
options=-g

修改/etc/multipath.conf，wwid根据查询结果得出，注意修改磁盘别名  alias  

defaults {  
        user_friendly_names yes  
}  
defaults {  
        udev_dir /dev  
        polling_interval  10  
        selector "round-robin 0"  
        path_grouping_policy failover  
        getuid_callout "/sbin/scsi_id -g -u -s /block/%n"  
        prio_callout /bin/true  
        path_checker readsector0  
        rr_min_io 100  
        rr_weight priorities  
        failback immediate  
        #no_path_retry fail  
        user_friendly_name yes  
}  
blacklist {  
        devnode "^(ram|raw|loop|fd|md|dm-|sr|scd|st)[0-9]*"  
        devnode "^hd[a-z]"  
        devnode "^cciss!c[0-9]d[0-9]*"  
}  
multipaths {  
        multipath {  
                wwid    149455400000000000000000001000000de0200000d000000  
                alias   fra  
                path_grouping_policy failover  
        }  
        multipath {  
                wwid    149455400000000000000000001000000e30200000d000000  
                alias   data  
                path_grouping_policy failover  
        }  
        multipath {  
                wwid    149455400000000000000000001000000e80200000d000000  
                alias   ocr1  
                path_grouping_policy failover  
        }  
        multipath {  
                wwid    149455400000000000000000001000000ed0200000d000000  
                alias   ocr2  
                path_grouping_policy failover  
        }  
        multipath {  
                wwid    149455400000000000000000001000000ca0200000d000000  
                alias   ocr3  
                path_grouping_policy failover  
        }

        multipath {  
                wwid    149455400000000000000000001000000ca0200000d000000  
                alias   ocr4  
                path_grouping_policy failover  
        }

        multipath {  
                wwid    149455400000000000000000001000000ca0200000d000000  
                alias   ocr5  
                path_grouping_policy failover  
        }  
}

编写/etc/rc.local 文件，使得开机修改磁盘权限

添加如下内容：

chown grid:asmadmin /dev/mapper/ocr1

chown grid:asmadmin /dev/mapper/ocr1

chown grid:asmadmin /dev/mapper/ocr2

chown grid:asmadmin /dev/mapper/ocr3

chown grid:asmadmin /dev/mapper/ocr4

chown grid:asmadmin /dev/mapper/ocr5

chown grid:asmadmin /dev/mapper/data

chown grid:asmadmin /dev/mapper/fra



chmod 660 /dev/mapper/ocr1

chmod 660 /dev/mapper/ocr1

chmod 660 /dev/mapper/ocr2

chmod 660 /dev/mapper/ocr3

chmod 660 /dev/mapper/ocr4

chmod 660 /dev/mapper/ocr5

chmod 660 /dev/mapper/data

chmod 660 /dev/mapper/fra

 **rhel6:**

 **参考文章：**

 **Configuring Multipath Devices on RHEL6/OL6 (** **文档** **ID 1538626.1)**

查询磁盘设备的wwid

 for i in `cat /proc/partitions | awk '{print $4}' |grep sd | grep [a-z]$`; do
echo "### $i: `scsi_id -g -u  -d  /dev/$i`"; done

 ** **

多路径配置文件内容/etc/multipath.conf，修改wwid和别名alias  

# grep -v ^# /etc/multipath.conf  
defaults {  
       udev_dir                /dev  
       polling_interval        5  
       path_grouping_policy    failover  
       getuid_callout          "/lib/udev/scsi_id --whitelisted --device=/dev/%n"  
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
                wwid    149455400000000000000000001000000de0200000d000000  
                alias   fra  
                path_grouping_policy failover  
        }  
        multipath {  
                wwid    149455400000000000000000001000000e30200000d000000  
                alias   data  
                path_grouping_policy failover  
        }  
        multipath {  
                wwid    149455400000000000000000001000000e80200000d000000  
                alias   ocr1  
                path_grouping_policy failover  
        }  
        multipath {  
                wwid    149455400000000000000000001000000ed0200000d000000  
                alias   ocr2  
                path_grouping_policy failover  
        }  
        multipath {  
                wwid    149455400000000000000000001000000ca0200000d000000  
                alias   ocr3  
                path_grouping_policy failover  
        }

        multipath {  
                wwid    149455400000000000000000001000000ca0200000d000000  
                alias   ocr4  
                path_grouping_policy failover  
        }

        multipath {  
                wwid    149455400000000000000000001000000ca0200000d000000  
                alias   ocr5  
                path_grouping_policy failover  
        }

}



查看多路径磁盘对应的dm-X 名称

ls -l /dev/mapper/|grep dm*

将共享存储磁盘列表抓取出来，通过notepad++工具进行列编辑

注意不要修改RAC非存储磁盘的权限。

 _因为rhel 6 多路径和5不一样，/dev/mapper下不再是块设备磁盘，而是软连接。_

 _dm-X 多路径绑定出来后，不同节点生成的dm-X对应的存储磁盘有可能不一致。_

 _因此参考mos文章：_

 **How to set udev rule for setting the disk permission on ASM disks when
using multipath on OL 6.x (** **文档 ID 1521757.1)**

 **使用udev修改磁盘权限和属主**

vi  /etc/udev/rules.d/12-dm-permissions-highgo.rules

添加如下内容，根据实际情况进行调整：

 _ _

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

 _ _

root用户执行

start_udev

重新加载udev设备

ls –l /dev/dm-*  检查磁盘属主和权限是否正确。

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
echo "### $i: `scsi_id -g -u  -d  /dev/$i`"; done

例如：

  ###sdb:   149455400000000000000000001000000de0200000d000000

  ###sdc:   149455400000000000000000001000000e30200000d000000

  ###sdd:   149455400000000000000000001000000e80200000d000000

  ###sde:   149455400000000000000000001000000ed0200000d000000

  ###sdf:   149455400000000000000000001000000ca0200000d000000

  ###sdg:   149455400000000000000000001000000ca0200000d000000

  ###sdh:   149455400000000000000000001000000ca0200000d000000



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



 ** _小技巧：如果需要手动解除绑定：raw /dev/raw/raw13 0 0 ＃解除raw13绑定_**



 **rhel 5:**

 **Linux: How To Setup UDEV Rules For RAC OCR And Voting Devices On SLES10,
RHEL5, OEL5, OL5 (** **文档** **ID 414897.1)**

 ** **

查询设备wwid，注意和rhel6的区别是 scsi_id的 参数6是-d ，5是-s

另外磁盘是/block/sdx 而不是/dev/sdx

for i in `cat /proc/partitions | awk '{print $4}' |grep sd | grep [a-z]$`; do
echo "### $i: `scsi_id -g -u  -s  /block/$i`"; done

同rhel6设置类似，同样修改RESULT和RUN的标记参数。

vi /etc/udev/rules.d/99-asm-highgo.rules



ACTION=="add",BUS=="scsi", KERNEL=="sd*", PROGRAM=="/sbin/scsi_id -g -u -s
%p", RESULT=="14f504e46494c45525743714d4f6a2d6437466f2d30435362",
RUN+="/bin/raw /dev/raw/raw1 %N"

ACTION=="add",BUS=="scsi", KERNEL=="sd*", PROGRAM=="/sbin/scsi_id -g -u -s
%p", RESULT=="149455400000000000000000001000000e30200000d000000",
RUN+="/bin/raw /dev/raw/raw2 %N"

ACTION=="add",BUS=="scsi", KERNEL=="sd*", PROGRAM=="/sbin/scsi_id -g -u -s
%p", RESULT=="149455400000000000000000001000000e80200000d000000",
RUN+="/bin/raw /dev/raw/raw3 %N"

ACTION=="add",BUS=="scsi", KERNEL=="sd*", PROGRAM=="/sbin/scsi_id -g -u -s
%p", RESULT=="149455400000000000000000001000000ed0200000d000000",
RUN+="/bin/raw /dev/raw/raw4 %N"

ACTION=="add",BUS=="scsi", KERNEL=="sd*", PROGRAM=="/sbin/scsi_id -g -u -s
%p", RESULT=="149455400000000000000000001000000ca0200000d000000",
RUN+="/bin/raw /dev/raw/raw5 %N"

ACTION=="add",BUS=="scsi", KERNEL=="sd*", PROGRAM=="/sbin/scsi_id -g -u -s
%p", RESULT=="149455400000000000000000001000000ca0200000d000000",
RUN+="/bin/raw /dev/raw/raw6 %N"

ACTION=="add",BUS=="scsi", KERNEL=="sd*", PROGRAM=="/sbin/scsi_id -g -u -s
%p", RESULT=="149455400000000000000000001000000ca0200000d000000",
RUN+="/bin/raw /dev/raw/raw7 %N"



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



**注意：要根据你的实际情况来配置，不建议使用自动shell脚本生成以上内容，建议notepad++等工具进行列模式编辑。特别是添加磁盘到现有生产环境的情况，脚本不可控，存在安全隐患。**



### 针对如上三种情况都需要创建用于ASM访问的磁盘软链接

mkdir /u01/asm-disk/

举例如：

ln -s /dev/mapper/ocr1 /u01/asm-disk/ocr1

ln -s /dev/mapper/ocr2 /u01/asm-disk/ocr2

ln -s /dev/mapper/ocr3 /u01/asm-disk/ocr3

ln -s /dev/mapper/ocr4 /u01/asm-disk/ocr4

ln -s /dev/mapper/ocr5 /u01/asm-disk/ocr5

ln -s /dev/mapper/data /u01/asm-disk/data

ln -s /dev/mapper/fra  /u01/asm-disk/fra



ln -s /dev/raw/raw1  /u01/asm-disk/ocr1

ln -s /dev/raw/raw2  /u01/asm-disk/ocr2

ln -s /dev/raw/raw3  /u01/asm-disk/ocr3





无论哪种形式的裸设备最后都要建立软连接，到/u01/asm-disk目录

根据实际情况进行修改。

 **配置到此后需要重启下服务器，确保所有的存储磁盘均可自动挂在、主机名等信息都是正确的。**

##  11、安装 Oracle Grid Infrastructure

vnc连接服务器

root登录

解压群集安装程序

#gunzip p13390677_112040_Linux-x86-64_3of7.zip -d /tmp/

#cd /tmp/grid/

#xhost+

#su - grid

$cd /tmp/grid

$./runInstaller

以下截图内值均未参考选项，以实际内容为准。

![noteattachment6][5c8574a6ceb99de546f4370e27b15ed2]

![noteattachment7][d67440b5918f8568c4729092945ac019]
![noteattachment8][048d9dbc21b5ea16361597fbce1614c8]

注意： SCAN name 必须和DNS解析的域名一致，如果DNS不能成功解析，那么这一步会报错

 **网格命名服务 (GNS)**

从 Oracle Clusterware 11 _g_ 第 2 版开始，引入了另一种分配 IP 地址的方法，即 _网格命名服务_ (GNS)。该方法允许使用
DHCP 分配所有专用互连地址以及大多数 VIP 地址。GNS 和 DHCP 是 Oracle 的新的网格即插即用 (GPnP) 特性的关键要素，如
Oracle 所述，该特性使我们无需配置每个节点的数据，也不必具体地添加和删除节点。通过实现对集群网络需求的自我管理，GNS 实现了 _动态_
网格基础架构。与手动定义静态 IP 地址相比，使用 GNS 配置 IP
地址确实有其优势并且更为灵活，但代价是增加了复杂性，该方法所需的一些组件未在这个构建经济型 Oracle RAC 的指南中定义。例如，为了在集群中启用
GNS，需要在公共网络上有一个 DHCP 服务器. 要了解 GNS 的更多优势及其配置方法，请参见 [适用于 Linux 的 Oracle Grid
Infrastructure 11 _g_ 第 2 版 (11.2)
安装指南](http://download.oracle.com/docs/cd/E11882_01/install.112/e10812/toc.htm)。

  ![noteattachment9][fef23ec78a708f1281748f4807c911e1]

先点击setup按钮来建立主机之间的ssh互信，左右就是服务器之间ssh登录时可以不需要输入对方操作系统账户的密码。

![noteattachment10][c26dd33029c3ad9b8b9e82d95bc029f2]根据定义的网卡选择网络类型  public 还是
心跳private

  ![noteattachment11][b4cf665f75d07ba54ea5cce6fda4aafd]
![noteattachment12][dc194f9efc553fc8a4bd6ce986940142]此处要求存储工程师划分5个3G的LUN
用来做CRS磁盘组

此处冗余模式 Redundancy要选择High

下方勾选5个3G的磁盘。

 **注意此处添加的磁盘是存储磁盘软链接存放的目录/dev/asm-disk/**

  ![noteattachment13][ea149d44ca13a07b25ba80c4be91862c] **ASM
必须达到一定的密码标准。密码中要包含字母大写、小写、数字，至少8个字符。**

  ![noteattachment14][de86f21c27fc86d5f2a31bd467a3255d]
![noteattachment15][7a831c2f7640cf44168362a762af5cf3]
![noteattachment16][580e2bcd3b4f0e45b659a140f382b93a]
![noteattachment17][28891a335465eec5d8f39090dc14e36e]
![noteattachment18][925a0b8294e36568785aff1171044ffe]

如果只有以上三个条件不满足，勾选右上角的ignore all，如果存在其他条件不满足则要进行相应处理。

![noteattachment19][965d87c7f41f57cdcf1bf7de19021ad6]
![noteattachment20][0941d40e1bcec58610401ea33eb28caf]  

若集群root.sh脚本运行不成功：

#删除crs配置信息

#/u01/app/11.2.0/grid/crs/install/rootcrs.pl -verbose -deconfig -force

  ![noteattachment21][c668c401a76be67566406e37ce515d6c]

 **出现这两个错误可以忽略不计，直接下一步退出。也可以用下面的方法避免错误出现。**

 _如果您只在_ _hosts_ _文件中定义_ _SCAN_ _但却想让_ _CVU_ _成功完成，只需在两个_ _Oracle RAC_ _节点上以_
_root_ _身份对_ _nslookup_ _实用程序进行如下修改。_

 _首先，在两个_ _Oracle RAC_ _节点上将原先的_ _nslookup_ _二进制文件重命名为_ _nslookup.original_
_：_

 _[root@racnode1 ~]# **mv /usr/bin/nslookup /usr/bin/nslookup.original**_

 _然后，新建一个名为_ _/usr/bin/nslookup_ _的_ _shell_ _脚本，在该脚本中用_ _202.102.128.68_
_替换主_ _DNS_ _，用_ _rac-scan_ _替换_ _SCAN_ _主机名，用_ _192.168.0.127_ _替换_ _SCAN IP_
_地址，如下所示：_

 _#!/bin/bash_

 _ _

 _HOSTNAME=${1}_

 _ _

 _if [[ $HOSTNAME = "rac-scan" ]]; then_

 _     echo   "Server:         202.102.128.68"_

 _     echo   "Address:        202.102.128.68#53"_

 _     echo   "Non-authoritative answer:"_

 _     echo   "Name:   rac-scan"_

 _     echo   "Address: 192.168.0.127"_

 _else_

 _       /usr/bin/nslookup.original $HOSTNAME_

 _fi_  
  
---  
  
 _最后，将新建的_ _nslookup shell_ _脚本更改为可执行脚本：_

 _[root@racnode1 ~]# **chmod 755 /usr/bin/nslookup**_

 _记住要在两个_ _Oracle RAC_ _节点上执行这些操作。_

 _每当_ _CVU_ _使用您的_ _SCAN_ _主机名调用_ _nslookup_ _脚本时，这个新的_ _nslookup shell_
_脚本只是回显您的_ _SCAN IP_ _地址，其他情况下则会调用原先的_ _nslookup_ _二进制文件。_

 _在_ _Oracle Grid Infrastructure_ _的安装过程中，当_ _CVU_ _尝试验证您的_ _SCAN_
_时，它就会成功通过：_

 _[grid@racnode1 ~]$ **cluvfy comp scan -verbose**_

 _ _

 _Verifying scan_

 _ _

 _Checking Single Client Access Name (SCAN)..._

 _  SCAN VIP    name     Node          Running?      ListenerName  Port
Running?   _

 _    \----------------    \------------  \------------  \------------
\------------  \------------_

 _    racnode-cluster-scan    racnode1      true          LISTENER      1521
true       _

 _ _

 _Checking name resolution setup for   "racnode-cluster-scan"..._

 _  SCAN Name      IP Address                Status                    Comment
_

 _    \------------    \------------------------    \------------------------
\----------_

 _    racnode-cluster-scan    192.168.1.187             **passed**_

 _ _

 _Verification of SCAN VIP and Listener setup passed_

 _ _

 _Verification of scan was successful._

 _ _

_===============================================================================_

 _ _

 _[grid@racnode2 ~]$ **cluvfy comp scan -verbose**_

 _ _

 _Verifying scan_

 _ _

 _Checking Single Client Access Name (SCAN)..._

 _  SCAN VIP    name     Node          Running?      ListenerName  Port
Running?   _

 _    \----------------    \------------  \------------  \------------
\------------  \------------_

 _    racnode-cluster-scan    racnode1      true          LISTENER      1521
true       _

 _ _

 _Checking name resolution setup for   "racnode-cluster-scan"..._

 _  SCAN Name      IP Address                Status                    Comment
_

 _    \------------    \------------------------    \------------------------
\----------_

 _    racnode-cluster-scan    192.168.1.187             **passed**_

 _ _

 _Verification of SCAN VIP and Listener setup passed_

 _ _

 _Verification of scan was successful._  
  
---  
  


## 12、集群安装后的任务

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

ora.gsd              OFFLINE OFFLINE      rac1  

                   OFFLINE OFFLINE      rac2                     

ora.net1.network   ONLINE  ONLINE       rac1  

                   ONLINE  ONLINE       rac2                     

ora.ons              ONLINE  ONLINE       rac1  

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



(2)为数据和快速恢复区创建 ASM 磁盘组

![noteattachment22][6d1afda2741d4ccce7741ce9449fdd71]

asmca

![noteattachment23][1951f92f3cf962c48b1b4337b0996c94]在 Disk Groups 选项卡中，单击
**Create** 按钮，在出现的画面中创建data卷：

除了CRS磁盘组以外其余存放数据和归档的磁盘组默认都是选择Extenal外部冗余模式，除非客户特殊要求。

![noteattachment24][7268853afb0c73f72114aa88731e106d]
![noteattachment25][b1134d4505b6385afdc96d9aca37168c]
![noteattachment26][c8d01a72bb80c5639e10bf2e764cbd07]
![noteattachment27][fb1995c9b1acc8bf6db642b2d44fcc43]  

对于磁盘组的规划，一般一套rac 含有一个CRS磁盘组，一个FRA磁盘组用于存放归档日志，一个或者多个DATA磁盘组用于存放数据。

单击Exit退出ASM配置向导。







 **至此重启下服务器确认crs各个资源状态均正常。**

##  13、安装oracle 11g r2 database

vnc图形化登录服务器

root用户登录

依次解压如下两个安装包

unzip p13390677_112040_Linux-x86-64_1of7.zip -d /tmp/

unzip p13390677_112040_Linux-x86-64_2of7.zip -d /tmp/

xhost+

su - oracle

$cd /tmp/database

$./runInstaller

  ![noteattachment28][e46116e346645d68fecbb56ee3f3f43f]

选择 **Real Application Clusters database installation** 单选按钮（此为默认选择），确保选中 Node
Name 窗口中的两个 Oracle RAC 节点。

接下来，单击 [SSH Connectivity] 按钮。输入 oracle 用户的 OS Password，然后单击 [Setup] 按钮。这会启动
SSH Connectivity 配置过程：

  ![noteattachment29][9c75745de4fd666923b35c11c695ab7c]
![noteattachment30][4b0a796c8ee3f6b555f7fce108a66c81]
![noteattachment31][aad9d51242f28fb6bf0267232d196fe9]
![noteattachment32][25693b53c6dd7efc9f90104956dcd3df]
![noteattachment33][8a28f177d99012d42926ac3028606ab8]
![noteattachment34][854ad22a5c75c534586de4e3317f1dab]
![noteattachment35][22356291fef9fe9e3cba16c97b1b042c]
![noteattachment36][9b241ce9fb6482ee04d4a0fd6b44f000]
![noteattachment37][1d27f57a0472aea5c20e4e428dd9ea21]
![noteattachment38][f4224fdf2a9c0a72c374a026e71229a3]

待安装完成后在各个节点执行root.sh脚本，完成后退出向导。

## 14、创建、删除数据库



### 14.1 创建数据库

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

ora.gsd              OFFLINE OFFLINE      rac1  

                   OFFLINE OFFLINE      rac2                     

ora.net1.network   ONLINE  ONLINE       rac1  

                   ONLINE  ONLINE       rac2                     

ora.ons              ONLINE  ONLINE       rac1  

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

[grid@rac1 ~]$  

  ![noteattachment39][37062aea6fd1501e4ec2725ef261a3c1]
![noteattachment40][3a36ae985feac43a5183250777c2c3a3]
![noteattachment41][ac6da0d42ff479de2a4e15a15dd7dd67]
![noteattachment42][215feafd65536365048b3ab7ae68171e]
![noteattachment43][aed8dd48d4b395897109d6f62500e664]
![noteattachment44][9f699984331d9f7de2666880bfb33eb6]
![noteattachment45][594ed5d7f971589f47e174fc0d967f8e]

点击"Multiplex Redo Logs and Control Files" 输入多个磁盘组来产生冗余控制文件和redo文件。

如果存在+FRA则填写 +DATA和+FRA

如果不存在+FRA，只有+DATA ，则添加两个+DATA

原则就是要多个控制文件和redo文件，而且尽量要存放在不同的磁盘组中。

![noteattachment46][ac39e7ad518d9a7af238e90d06bcb00e]
![noteattachment47][799fd84c0223ad24ad1928200aedb9d9]
![noteattachment48][1d1cd7d6db547e6b5b119f3ce1f51677]

数据库安装成功并正常启动需要将sga设置大于1072m

保守的设置原则是 ：

SGA_TARGET+pga_aggregate_target=物理内存*0.6

SGA_TARGET : pga_aggregate_target  比例是4:1

SGA_TARGET 等于 SGA_MAX_SIZE



根据实际物理内存进行调整。

![noteattachment49][59749488ecc428002ac10ab1d4072f76]
![noteattachment50][11d84121014589c53d12d4cceea529f5]字符集的必须和开发人员进行确认，不能猜测使用，数据库建立完成后字符集不能进行修改。

![noteattachment51][ea8489ec9a5ba6ffba12db3ebb00c6db]
![noteattachment52][a5d870f331bafe278ff68a90f8770085]这里得注意新加的两组日志一个是线程Thread#
1，一个是线程Thread# 2

![noteattachment53][63040b79080ecf91fed0db50959eb5d2]
![noteattachment54][5d4cd36e3c765e9168dbc2967d3b29a5]
![noteattachment55][57a518321f1aa3d33083555ca2e2097d]
![noteattachment56][5b40c4a76a04f2c8ff8e0fde7b17613a]

### 14.2 删除数据库

删除数据库最好也用dbca，虽然srvctl也可以。

1.    运行dbca，选择”delete a database”。然后就next..，直到finish。

2.    数据的删除并不影响asm实例，如果想删除与asm有关的内容，可以按如下做法：

# export ORACLE_SID= _ASM_instance_name_

# sqlplus / as sysdba

SQL> drop diskgroup _diskgroup_name_ including contents;

SQL> quit

然后在各个节点上执行

# srvctl stop asm –n hostname

# srvctl remove asm –n hostname

这样，应该就可以删除的比较干净了。





## 15、常用命令

###  _15.1_ _、_ _oracle_ _用户管理数据库命令_

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

 _ _

 _ _

 ** _ _**

 ** _ _**

 ** _ _**

 ** _srvctl start_**

 _ _

 _   # Start database  
        srvctl start database -d orcl -o nomount  
        srvctl start database -d orcl -o mount  
        srvctl start database -d orcl -o open_

 _ _

 _# Grammar for start instance  
        srvctl start instance -d [db_name] -i [instance_name]  
               -o [start_option] -c [connect_str]_ _–_ _q_

 _ _

 _# Start all instances on the all nodes  
        srvctl start instance -d orcl -i orcl1,orcl2,_

 _ _

 _# Start ASM instance  
        srvctl start ASM -n [node_name] -i asm1 -o open  
  
# Start all apps in one node  
     srvctl start nodeapps -n [node_name]_

 _ _

 _ _

 ** _srvctl stop_**

 _ _

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



 _ _

###  _15.2_ _、启动_ _/_ _停止集群命令_

 _以下停止/启动操作需要以_ ` root` _身份来执行_

 ** _在本地服务器上停止 Oracle Clusterware 系统_**

 _在_ ` rac1` _节点上使用_ ` crsctl stop cluster` _命令停止 Oracle Clusterware 系统：_

 ** _#/u01/app/11.2.0/grid/bin/crsctl stop cluster_**

 ** _注：_** _在运行“_` crsctl stop cluster` _” 命令之后，如果 Oracle Clusterware
管理的资源中有任何一个还在运行，则整个命令失败。使用_ `-f` _选项无条件地停止所有资源并停止 Oracle Clusterware 系统。_

 _ _

 ** _在本地服务器上启动_** **_Oracle Clusterware_** **_系统_**

 _在_ _rac1_ _节点上使用_ _crsctl start cluster_ _命令启动_ _Oracle Clusterware_ _系统：_

 _[root@rac1 ~]# **/u01/app/11.2.0/grid/bin/crsctl start cluster**_

 ** _注：_** _可通过指定_ _-all_ _选项在集群中所有服务器上启动_ _Oracle Clusterware_ _系统。_

 _[root@rac1 ~]# **/u01/app/11.2.0/grid/bin/crsctl start cluster -all**_

 _还可以通过列出服务器（各服务器之间以空格分隔）在集群中一个或多个指定的服务器上启动_ _Oracle Clusterware_ _系统：_

 _[root@rac1 ~]# **/u01/app/11.2.0/grid/bin/crsctl start cluster -n rac1
rac2**_

 _ _

 _ _

###  _15.3_ _检查集群的运行状况（集群化命令）_

 _以_ _grid_ _用户身份运行以下命令。_

 _[grid@rac1 ~]$ **crsctl check cluster**_

 _CRS-4537: Cluster Ready Services is online_

 _CRS-4529: Cluster Synchronization Services is online_

 _CRS-4533: Event Manager is online_

 ** _所有_** **_Oracle_** **_实例_** **_—_** ** _（数据库状态）_**

 _[oracle@rac1 ~]$ **srvctl status database -d orcl**_

 _Instance orcl1 is running on node rac1_

 _Instance orcl2 is running on node rac2_

 ** _单个_** **_Oracle_** **_实例_** **_—_** ** _（特定实例的状态）_**

 _[oracle@rac1 ~]$ **srvctl status instance -d orcl -i orcl1**_

 _Instance orcl1 is running on node rac1_

 ** _节点应用程序_** **_—_** ** _（状态）_**

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

 ** _节点应用程序_** **_—_** ** _（配置）_**

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

 ** _数据库_** **_—_** ** _（配置）_**

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

 ** _TNS_** **_监听器_** **_—_** ** _（状态）_**

 _[oracle@rac1 ~]$ **srvctl status listener**_

 _Listener LISTENER is enabled_

 _Listener LISTENER is running on node(s): rac1,rac2_

 ** _TNS_** **_监听器_** **_—_** ** _（配置）_**

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

 _ _

 _[oracle@rac1 ~]$ **srvctl status vip -n rac2**_

 _VIP rac2-vip is enabled_

 _VIP rac2-vip is running on node: rac2_

 ** _VIP —_** ** _（特定节点的配置）_**

 _[oracle@rac1 ~]$ **srvctl config vip -n rac1**_

 _VIP exists.:rac1_

 _VIP exists.: /rac1-vip/192.168.1.251/255.255.255.0/eth0_

 _ _

 _[oracle@rac1 ~]$ **srvctl config vip -n rac2**_

 _VIP exists.:rac2_

 _VIP exists.: /rac2-vip/192.168.1.252/255.255.255.0/eth0_

 ** _节点应用程序配置_** **_—_** ** _（_** ** _VIP_** ** _、_** ** _GSD_** ** _、_** **
_ONS_** ** _、监听器）_**

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

 _ _

 _ _

##  _16_ _、卸载软件_

###  _16.1_ _卸载_ _Oracle Grid Infrastructure_

 _Deconfiguring Oracle Clusterware Without Removing Binaries_

 _cd /u01/app/11.2.0/grid/crs/install_

    
    
    1、Run rootcrs.pl with the -deconfig -force flags. For example
    
    
    # perl rootcrs.pl -deconfig –force
    
    
    Repeat on other nodes as required
    
    
    2、If you are deconfiguring Oracle Clusterware on all nodes in the cluster, then on the last node, enter the following command:

  

 _# perl rootcrs.pl -deconfig -force –lastnode_

 _3_ _、_ _Removing Grid Infrastructure_

 _The default method for running the deinstall tool is from the deinstall
directory in the grid home. For example:_

    
    
    $ cd /u01/app/11.2.0/grid/deinstall
    
    
    $ ./deinstall

  

 _ _

 _ _

###  _16.2_ _卸载_ _Oracle Real Application Clusters Software_

 _Overview of Deinstallation Procedures_

 _To completely remove all Oracle databases, instances, and software from an
Oracle home directory:_

·         _Identify all instances associated with the Oracle home_

·         _Shut down processes_

·         _Remove listeners installed in the Oracle Database home_

·         _Remove database instances_

·         _Remove Automatic Storage Management (11.1 or earlier)_

·         _Remove Oracle Clusterware and Oracle Automatic Storage Management
(Oracle grid infrastructure)_

 _Deinstalling Oracle RAC Software_

    
    
    $ cd $ORACLE_HOME/deinstall
    
    
    $ ./deinstall

  

 _ _

 _ _

 _Reserve.conf_

 _Crs-4402_

 _ _

 _ _

 _ _

##  17、收尾工作

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

 **Redhat** **内核的系统** 中关闭透明大页内存 ：

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

# NOTICE:  You have a /boot partition.  This means that

#          all kernel and initrd paths are relative to /boot/, eg.

#          root (hd0,0)

#          kernel /vmlinuz-version ro root=/dev/sda3

#          initrd /initrd-[generic-]version.img

#boot=/dev/sda

default=0

timeout=5

splashimage=(hd0,0)/grub/splash.xpm.gz

hiddenmenu

title Red Hat Enterprise Linux 6 (2.6.32-642.el6.x86_64)

        root (hd0,0)

        kernel /vmlinuz-2.6.32-642.el6.x86_64 ro root=UUID=36e1c41b-9a78-4d3d-888e-6558ee9266a4 rd_NO_LUKS rd_NO_LVM.UTF-8 rd_NO_MD SYSFONT=latarcyrheb-sun16 crashkernel=128M  KEYBOARDTYPE=pc KEYTABLE=us rd_NO_DM rhgb quiet transparent_hugepage=never

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

Server
| 4.1 kB     00:00 ...

Resolving Dependencies

\--> Running transaction check

\---> Package tuned.noarch 0:0.2.19-16.el6 will be installed

\--> Finished Dependency Resolution



Dependencies Resolved



========================================================================================================================================================================

 Package                              Arch
Version                                         Repository
Size

========================================================================================================================================================================

Installing:

 tuned                                noarch
0.2.19-16.el6                                   Server
95 k



Transaction Summary

========================================================================================================================================================================

Install       1 Package(s)



Total download size: 95 k

Installed size: 219 k

Is this ok [y/N]: y

Downloading Packages:

Running rpm_check_debug

Running Transaction Test

Transaction Test Succeeded

Running Transaction

Warning: RPMDB altered outside of yum.

  Installing : tuned-0.2.19-16.el6.noarch
1/1

  Verifying  : tuned-0.2.19-16.el6.noarch
1/1



Installed:

  tuned.noarch 0:0.2.19-16.el6  



Complete!

[root@rac1 Packages]# tuned-adm  active

Current active profile: default

Service tuned: disabled, stopped

Service ktune: disabled, stopped



[root@rac1 Packages]# cd /etc/tune-profiles/

[root@rac1 tune-profiles]# cp -r throughput-performance throughput-
performance-no-thp

[root@rac1 tune-profiles]# sed -ie 's,set_transparent_hugepages
always,set_transparent_hugepages never,' \

>       /etc/tune-profiles/throughput-performance-no-thp/ktune.sh

[root@rac1 tune-profiles]# grep set_transparent_hugepages /etc/tune-
profiles/throughput-performance-no-thp/ktune.sh

        set_transparent_hugepages never



[root@rac1 tune-profiles]# tuned-adm profile throughput-performance-no-thp

Switching to profile 'throughput-performance-no-thp'

Applying deadline elevator: dm-0 dm-1 dm-2 dm-3 dm-4 dm-5 dm-6 sda sdb sdc sdd
sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo [  OK  ]

Applying ktune sysctl settings:

/etc/ktune.d/tunedadm.conf: [  OK  ]

Calling '/etc/ktune.d/tunedadm.sh start': [  OK  ]

Applying sysctl settings from /etc/sysctl.conf

Starting tuned: [  OK  ]



[root@rac1 tune-profiles]# cat
/sys/kernel/mm/redhat_transparent_hugepage/enabled

always madvise [never]



如上修改后，仍然需要在/etc/grub.conf的kernel行中添加transparent_hugepage=never，如下

[root@rac1 tune-profiles]# cat /etc/grub.conf

# grub.conf generated by anaconda

#

# Note that you do not have to rerun grub after making changes to this file

# NOTICE:  You have a /boot partition.  This means that

#          all kernel and initrd paths are relative to /boot/, eg.

#          root (hd0,0)

#          kernel /vmlinuz-version ro root=/dev/sda3

#          initrd /initrd-[generic-]version.img

#boot=/dev/sda

default=0

timeout=5

splashimage=(hd0,0)/grub/splash.xpm.gz

hiddenmenu

title Red Hat Enterprise Linux 6 (2.6.32-642.el6.x86_64)

        root (hd0,0)

        kernel /vmlinuz-2.6.32-642.el6.x86_64 ro root=UUID=36e1c41b-9a78-4d3d-888e-6558ee9266a4 rd_NO_LUKS rd_NO_LVM.UTF-8 rd_NO_MD SYSFONT=latarcyrheb-sun16 crashkernel=128M  KEYBOARDTYPE=pc KEYTABLE=us rd_NO_DM rhgb quiet transparent_hugepage=never

        initrd /initramfs-2.6.32-642.el6.x86_64.img

  

  

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



安装PSU，根据PSU相关介绍进行安装。

参考相关PSU文档



部署OSW

默认30秒收集1次，总共保留2天的记录

设置开机自动启动osw监控

linux:

vi  /etc/rc.local

cd /tmp/oswbb&&/tmp/oswbb/startOSWbb.sh

通过测试osw的日志默认策略 30秒*2天
大约需500M的磁盘空间，合理安排存放目录。如果需要自定义天数和扫描间隔,例如想每隔15秒收集一次,共保留7天168小时,添加参数即可.

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

其中<node1-priv>  和<node2-priv> 修改成  rac心跳ip的名称 如 rac1-priv 和rac2-priv

另外最后一行 rm locks/lock.file 必须保留

# DO NOT DELETE THE FOLLOWING LINE!!!!!!!!!!!!!!!!!!!!!

########################################################

rm locks/lock.file

osw生成的日志会保留在 oswbb下的 archive 目录中。



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



## 18、部署rman备份脚本

参考rman 备份相关文档



 **至此结束RAC部署，重启RAC所有服务器，启动后检查相关服务及内容是否正常，方可结束安装。**

##  19、安装群集和数据库失败如何快速重来，需要清理重来？

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



# 如何将已经实施完成的RAC的scan-ip由hosts文件解析修改为DNS解析

## 1、修改所有rac节点的/etc/resolv.conf文件，添加以下内容

domain highgo.com

nameserver 186.168.100.116

options rotate

options timeout:2

options attempts:5

## 2、修改所有rac节点的/etc/nsswitch.conf

将第38行修改为以下内容

hosts:      dns files nis

## 3、删除/etc/hosts文件里scan-ip的解析

## 4、在所有节点（包括dns节点和rac节点）执行如下命令检查

如果可以正常返回结果，说明配置正确

 **[root@dns named]# nslookup scan-ip.highgo.com**

Server:         186.168.100.116

Address:        186.168.100.116#53



Name:   scan-ip.highgo.com

Address: 186.188.100.115

Name:   scan-ip.highgo.com

Address: 186.188.100.117

Name:   scan-ip.highgo.com

Address: 186.188.100.118

 **[root@dns named]# nslookup 186.168.100.115**

Server:         186.168.100.116

Address:        186.168.100.116#53



115.100.168.186.in-addr.arpa    name = scan-ip.highgo.com.



 **[root@dns named]# nslookup 186.168.100.117**

Server:         186.168.100.116

Address:        186.168.100.116#53



117.100.168.186.in-addr.arpa    name = scan-ip.highgo.com.



 **[root@dns named]# nslookup 186.168.100.118**

Server:         186.168.100.116

Address:        186.168.100.116#53



118.100.168.186.in-addr.arpa    name = scan-ip.highgo.com

## 5、查看当前scanip名称



[grid@rac1 ~]$ srvctl config scan

SCAN name: scan-ip, Network: 1/186.168.100.0/255.255.255.0/eth0

SCAN VIP name: scan1, IP: /scan-ip/186.168.100.115

## 6、关闭scan、关闭scan_listener

[root@rac1 grid]# srvctl stop scan_listener

[root@rac1 grid]#  srvctl stop scan

## 7、将scanip名称修改为DNS解析的域名

[root@rac1 grid]# srvctl modify scan -n scan-ip.highgo.com.



## 8、打开scan，打开scan_listener 并查看当前scan-ip配置

[root@rac1 grid]# srvctl start scan

[root@rac1 grid]#  srvctl start scan_listener

[root@rac1 grid]# srvctl config scan

SCAN name: scan-ip.highgo.com., Network: 1/186.168.100.0/255.255.255.0/eth0

SCAN VIP name: scan1, IP: /scan-ip.highgo.com./186.168.100.117

SCAN VIP name: scan2, IP: /scan-ip.highgo.com./186.168.100.118

SCAN VIP name: scan3, IP: /scan-ip.highgo.com./186.168.100.115



# 客户端如何通过dns域名连接到数据库

1、在网卡配置中添加DNS，地址为DNS服务器的IP地址

![noteattachment57][f03d0600c2cc0f9b2d0621b76436a513]

2、Oracle 客户端 tnsnames配置相关的连接串，host后面写上DNS域名

TEST =

  (DESCRIPTION =

    (ADDRESS_LIST =

      (ADDRESS = (PROTOCOL = TCP)(HOST = **scan-ip.highgo.com** )(PORT = 1521))

    )

    (CONNECT_DATA =

      (SERVICE_NAME = orcl)

    )

  )

3、客户端使用tnsping进行测试

![noteattachment58][62be29adb90e5038343037397e991e13]

  

相关文档

内部备注

附件

验证码：

  换一张

输入验证码：

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAYAAAA7MK6iAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEgAACxIB0t1+/AAAABZ0RVh0Q3JlYXRpb24gVGltZQAwOS8yNy8xN+stbYgAAAAcdEVYdFNvZnR3YXJlAEFkb2JlIEZpcmV3b3JrcyBDUzbovLKMAAABm0lEQVRIicXXwXGCQBTG8b+7uZsSTAXRCiQVhA6SXLgmJZgO5BguSQnYgR0EK0hKiAUs5rBvGVlBBEG/GWccxf0JC2/fjna7HU3JEz0BQnlNgbF3yBbIgBRIVWR+m8YcHYPzRE+BBfDY+O/KWQELFZmsNZwnegm8tgT9xCoybyfBeaJvgTVwfybqsgECFZm//Q/VwCgy1lrGroYHQEt4JSxzOgRa4GIAMsdy934PiO5npiKTuTNeXAgtrJH5UBPg54IwwJ3CVqO+swEegPea78MhYPfcroFlzTGhwtbevlFXLOrgqeKw4PeC5on+Ap5qjh37BcTPFjtXL/K+DxSAmwY4k7kiT3SGrT7+FWqNwmHJ9DPPE/0MIEtcQPnMO6EOPnYJAT5r8M4osFXYzqEpVXhXFCBT2HbllJTwM1CAtA1cws9AAVK3OqW066tibOGZd0BXKjLhdZdFuWHiC6Cx6zxLzZ4UiaG6kI2KTLEu+AUkwD6fvaMydpESLI9I33hle3u1hr62VssPZtjtSNussHdvJQoNeyeXITZt/1po2U5WDlb1AAAAAElFTkSuQmCC)![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAYAAAA7MK6iAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEgAACxIB0t1+/AAAABZ0RVh0Q3JlYXRpb24gVGltZQAwOS8yNy8xN+stbYgAAAAcdEVYdFNvZnR3YXJlAEFkb2JlIEZpcmV3b3JrcyBDUzbovLKMAAABu0lEQVRIicWX223CQBBFD26AlOAOMJoCQgl0AFQQSoEOoAN3EPLPKHYHKSFUQD686/jFPkysXMkSQsMc1jt7Z3Z2v9/xSVVTYG2eDJh3Qm5AAeRALiJfvpwzF1hVM2APbLz/rq0zcBCRIhqsqgfgLRLY1VFE9kFgVX0BLsDiSahVCaxE5Lv5ZTIxFJPrYnIPgyeAtuCDYLOnU0BruGEAZo9N9X5OCG1qKSKFXfFg5TVURiT2xe4BEmMOrnNaikgG7AKgOxPrgm9UNU2o3MilhapmInLywHcicjLblnpyrkPAUB0HF7wJvdC31EFwFgCeO+CxUIBsdr1e/V3iVzcqFypUdQswAgpALLgFh7qRREGh71yhSjufo6BjwHa1uapmZs9zwo5aD3yLhBaN1+ur9oe5EqrJYQx0jrvaXSoSqnHFJwtd0S+kMfA8BFw2js87w4XUhX/4wLY7nfD4NWEt0w59r46Ys4hsbVUfHIEEQqFauQtasxIAYwbHwOTP6GiNpzXsqWrBdFOIba9A30BWxDX9YKjJXasFNiPoX8MHx9t/G+gferX5wZLqOhKrM9VQ93CWc96drKa4tP0As8vvCUvsIrEAAAAASUVORK5CYII=)

sentinel

中。Oracle ASM和Oracle Database 11gR2提供了较以前版本更为增强的存储解决方案，该解决方案能够在ASM上存储Oracle
Clusterware文件，即Oracle集群注册表(OCR)和表决文件（VF，又称为表决磁盘）。这一特性使ASM能够提供一个统一的存储解决方案，无需使用第三方卷管理器或集群文件系统即可存储集群件和数据库的所有数据

l&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SCAN（single client access
name）即简单客户端连接名，一个方便客户端连接的接口；在Oracle
11gR2之前，client链接数据库的时候要用vip，假如cluster有4个节点，那么客户端的tnsnames.ora中就对应有四个主机vip的一个连接串，如果cluster增加了一个节点，那么对于每个连接数据库的客户端都需要修改这个tnsnames.ora。SCAN简化了客户端连接，客户端连接的时候只需要知道这个名称，并连接即可，每个SCAN
VIP对应一个scan listener，cluster内部的service在每个scan listener上都有注册，scan
listener接受客户端的请求，并转发到不同的Local listener中去，由local的listener提供服务给客户端

l&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;此外，安装GRID的过程也简化了很多，内核参数的设置可保证安装的最低设置，验证安装后执行fixup.sh即可，此外ssh互信设置可以自动完成，尤其不再使用OCFS及其复杂设置，直接使用ASM存储

# DNS服务器配置

 **参考文档 &nbsp;&nbsp;&nbsp;&nbsp; Linux: How to Configure the DNS Server for
11gR2 SCAN (文档 ID 1107295.1)**

DNS服务器OS版本 RHEL6.7x64

## 1、安装相应的包

[root@dns ~]#&nbsp; yum install bind bind-chroot

&nbsp;

## 2、修改/etc/resolv.conf

domain highgo.com

nameserver 186.168.100.116

options rotate

options timeout:2

options attempts:5

## 3、修改/etc/named.conf

&nbsp;

修改的内容如下

&nbsp;

//

// named.conf

//

// Provided by Red Hat bind package to configure the ISC BIND named(8) DNS

// server as a caching only nameserver (as a localhost DNS resolver only).

//

// See /usr/share/doc/bind*/sample/ for example named configuration files.

//

&nbsp;

options {

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; listen-on port 53 { any; };

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; listen-on-v6 port 53 { ::1; };

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
directory&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &quot;/var/named&quot;;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; dump-
file&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&quot;/var/named/data/cache_dump.db&quot;;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; statistics-file
&quot;/var/named/data/named_stats.txt&quot;;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; memstatistics-file
&quot;/var/named/data/named_mem_stats.txt&quot;;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; allow-query&nbsp;&nbsp;&nbsp;&nbsp;
{ any; };

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; recursion yes;

&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; dnssec-enable yes;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; dnssec-validation yes;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; dnssec-lookaside auto;

&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /* Path to ISC DLV key */

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; bindkeys-file
&quot;/etc/named.iscdlv.key&quot;;

&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; managed-keys-directory
&quot;/var/named/dynamic&quot;;

};

&nbsp;

logging {

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; channel default_debug {

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
file &quot;data/named.run&quot;;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
severity dynamic;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; };

};

&nbsp;

zone &quot;.&quot; IN {

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; type hint;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; file &quot;named.ca&quot;;

};

&nbsp;

include &quot;/etc/named.rfc1912.zones&quot;;

include &quot;/etc/named.root.key&quot;;

&nbsp;

## 4、修改/etc/named.rfc1912.zones

&nbsp;

添加如下内容

zone &quot;highgo.com&quot; IN {

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; type master;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; file &quot;highgo.com.zone&quot;;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; allow-update { none; };

};

&nbsp;

zone &quot;100.168.186.in-addr.arpa&quot; IN {

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; type master;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; file &quot;100.168.186.in-
addr.arpa&quot;;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; allow-update { none; };

};

&nbsp;

&nbsp;

\---------------------------

说明：

&nbsp;

zone &quot;highgo.com&quot; IN
{&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
#正向。highgo.com为域名，此域名的声明要放到 resolv.conf 文件中

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; type master;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; file
&quot;highgo.com.zone&quot;;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
#正向解析文件名称 此文件目录/var/named

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; allow-update { none; };

};

&nbsp;

zone &quot;100.168.186.in-addr.arpa&quot; IN
{&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
#反向，100.168.186为所要解析的ip网段

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; type master;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; file &quot;100.168.186.in-
addr.arpa&quot;;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
#反向解析文件名称此文件目录/var/named

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; allow-update { none; };

};

&nbsp;

这里需要注意的是，反向解析从左到右读取ip地址时是以相反的方向解释的，所以需要将ip地址反向排列。这里，192.168.8.*网段的反向解析域名为&quot;8.168.192.in-
addr.arpa&quot;。

\------------------------------------------------------------------------------

&nbsp;

## 5、利用模板文件创建用于正向解析和反向解析文件

&nbsp;

&nbsp;

创建正向解析文件

&nbsp;

&nbsp;cp -p /var/named/named.localhost /var/named/highgo.com.zone

&nbsp;

创建反向解析文件

&nbsp;

cp -p /var/named/named.loopback /var/named/100.168.186.in-addr.arpa

&nbsp;

&nbsp;

&nbsp;

## 6、修改正向解析文件

$TTL 1D

@&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; IN SOA&nbsp; @ rname.invalid. (

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ; serial

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1D&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ; refresh

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1H&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ; retry

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1W&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ; expire

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
3H )&nbsp;&nbsp;&nbsp; ; minimum

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; NS&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; @

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
A&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 186.168.100.116

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; AAAA&nbsp;&nbsp;&nbsp; ::1

scan-ip&nbsp; in A 186.188.100.115

scan-ip&nbsp; in A 186.188.100.117

scan-ip&nbsp; in A 186.188.100.118

&nbsp;

&nbsp;

## 7、修改反向解析文件

&nbsp;

$ORIGIN 100.168.186.in-addr.arpa.

$TTL 1H

@ IN SOA pera.com. root.pera.com. ( 2

3H

1H

1W

1H )

100.168.186.in-addr.arpa. IN NS pera.com.

&nbsp;

115 IN PTR scan-ip.pera.com.

118 IN PTR scan-ip.pera.com.

117 IN PTR scan-ip.pera.com.

&nbsp;

&nbsp;

&nbsp;

## 8、重启named

[root@dns named]# /etc/rc.d/init.d/named restart

&nbsp;

如果卡在

Stopping named: [&nbsp; OK&nbsp; ]

Generating /etc/rndc.key:

执行

rndc-confgen -r /dev/urandom -a

&nbsp;

## 9、修改named开机自启

chkconfig named on

&nbsp;

## 10、修改所有rac节点的/etc/resolv.conf文件，添加以下内容

domain highgo.com

nameserver 186.168.100.116

options rotate

options timeout:2

options attempts:5

## 11、修改所有rac节点的/etc/nsswitch.conf

将第38行修改为以下内容

hosts: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;dns files nis

## 12、在所有节点（包括dns节点和rac节点）执行如下命令检查

如果可以正常返回结果，说明配置正确

 **[root@dns named]# nslookup scan-ip.highgo.com**

Server:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 186.168.100.116

Address:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 186.168.100.116#53

&nbsp;

Name:&nbsp;&nbsp; scan-ip.highgo.com

Address: 186.188.100.115

Name:&nbsp;&nbsp; scan-ip.highgo.com

Address: 186.188.100.117

Name:&nbsp;&nbsp; scan-ip.highgo.com

Address: 186.188.100.118

 **[root@dns named]# nslookup 186.168.100.115**

Server:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 186.168.100.116

Address:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 186.168.100.116#53

&nbsp;

115.100.168.186.in-addr.arpa&nbsp;&nbsp;&nbsp; name = scan-ip.highgo.com.

&nbsp;

 **[root@dns named]# nslookup 186.168.100.117**

Server:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 186.168.100.116

Address:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 186.168.100.116#53

&nbsp;

117.100.168.186.in-addr.arpa&nbsp;&nbsp;&nbsp; name = scan-ip.highgo.com.

&nbsp;

 **[root@dns named]# nslookup 186.168.100.118**

Server:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 186.168.100.116

Address:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 186.168.100.116#53

&nbsp;

118.100.168.186.in-addr.arpa&nbsp;&nbsp;&nbsp; name = scan-ip.highgo.com

&nbsp;

&nbsp;

&nbsp;

# RAC安装步骤

## 1、验证系统要求

要验证系统是否满足 Oracle 11 _g_ 数据库的最低要求，以 root 用户身份登录并运行以下命令。

要查看可用 RAM 和交换空间大小，运行以下命令：

grep MemTotal /proc/meminfo

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

#rhel5需要关闭sendmail

&nbsp;

chkconfig sendmail off&nbsp;

关闭防火墙

chkconfig iptables off

关闭selinux:

vi /etc/selinux/config

SELINUX=disabled

#avahi-daemon 1501093.1

chkconfig&nbsp; avahi-daemon off

#6.x版本上关闭 NetworkManager 服务

chkconfig NetworkManager off

#6.x版本要执行创建如下软连接

ln -s /lib64/libcap.so.2.16 /lib64/libcap.so.1

## 3、网络配置

Hosts文件配置

每个主机vi /etc/hosts

&nbsp;

186.168.100.25&nbsp;&nbsp;&nbsp; rac1

186.168.100.26&nbsp;&nbsp;&nbsp; rac2

&nbsp;

192.0.10.125&nbsp;&nbsp;&nbsp; rac1-priv

192.0.10.126&nbsp;&nbsp;&nbsp; rac2-priv

&nbsp;

186.168.100.125&nbsp;&nbsp; rac1-vip

186.168.100.130&nbsp;&nbsp; rac2-vip

&nbsp;

rac1、rac2 对应的是网卡的物理ip ，即public ip

rac1-priv、rac2-priv 对应的是心跳网卡的物理ip&nbsp; 即private ip

rac1-vip、rac2-vip 对应的是虚拟VIP

 **因为通过DNS解析SCAN，所以不需要添加scanip的hosts解析**

&nbsp;

建议客户客户端连接rac群集，访问数据库时使用&nbsp; SCAN&nbsp; ip地址。

 **注意** **：vip 、** **public ip 、** **scan ip 必须要在同一个子网网段中。**

 **另外** **对于心跳** **IP 地址的设置** **， 不要设置成和客户局域网中存在的** **ip 网段。**

 **如客户网络是192.x.x.x 则设置心跳为 10.x.x.x &nbsp;
,心跳地址工程师可以自定义，但也要和客户确认客户局域网络是否有相同ip地址的服务器，尽量避免干扰。**

&nbsp;

配置完心跳地址后,一定要使用traceroute测试心跳网络之间通讯是否正常.心跳通讯是否正常不能简单地通过ping命令来检测.一定要使用traceroute默认是采用udp协议.每次执行traceroute会发起三次检测,*号表示通讯失败.

正常:

[root@rac1 ~]# traceroute rac2-priv

traceroute to rac2-priv (192.0.10.126), 30 hops max, 60 byte packets

1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; lsrac2-priv
(192.0.10.126)&nbsp; **0.802 ms &nbsp; 0.655 ms&nbsp; 0.636 ms**

不正常:

[root@lsrac1 ~]# traceroute rac2-priv

traceroute to rac2-priv (192.0.10.126), 30 hops max, 60 byte packets

&nbsp;1&nbsp; lsrac2-priv (192.0.10.126)&nbsp; 1.187 ms *** ***

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

baseurl=file:///mnt/Server/

enabled=1

gpgcheck=0

执行如下名命令允许yum默认同时安装32和64位的rpm包

echo&nbsp;&#39;multilib_policy=all&#39;&nbsp;&gt;&gt;&nbsp;/etc/yum.conf

可以执行如下命令安装所有需要的rpm

yum install compat-libcap1 tiger* binutils compat-libstdc* elfutils-libelf
elfutils-libelf-devel gcc gcc-c++ glibc glibc-common glibc-devel glibc-headers
ksh&nbsp; libaio libaio&nbsp; libaio-devel&nbsp; libaio-devel libgcc&nbsp;
libstdc++&nbsp; libstdc++-devel make sysstat unixODBC unixODBC unixODBC-devel
unixODBC-devel iscsi lsscsi*&nbsp; -y

## 5、内核参数

 **/etc/sysctl.conf &nbsp;** **这里面的修改可以通过安装过程中运行**` **runfixup.sh**`
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

&nbsp;&nbsp;

## 6、设置oracle的shell限制：

在/etc/security/limits.conf文件中加入

rhel 5&gt;

&nbsp;

grid&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
soft&nbsp;&nbsp;&nbsp; nproc&nbsp;&nbsp; 2047

grid&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
hard&nbsp;&nbsp;&nbsp; nproc&nbsp;&nbsp; 16384

grid&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
soft&nbsp;&nbsp;&nbsp; nofile&nbsp;&nbsp; 1024

grid&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
hard&nbsp;&nbsp;&nbsp; nofile&nbsp;&nbsp; 65536

grid&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
hard&nbsp; &nbsp;&nbsp;stack&nbsp;&nbsp;&nbsp; 10240

oracle&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
soft&nbsp;&nbsp;&nbsp; nproc&nbsp;&nbsp;&nbsp; 2047

oracle&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
hard&nbsp;&nbsp;&nbsp; nproc&nbsp;&nbsp; 16384

oracle&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
soft&nbsp;&nbsp;&nbsp; nofile&nbsp;&nbsp; 1024

oracle&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
hard&nbsp;&nbsp;&nbsp; nofile&nbsp; 65536

oracle&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
hard&nbsp;&nbsp;&nbsp; stack&nbsp;&nbsp; 10240

&nbsp;

修改使以上参数生效：

vi /etc/pam.d/login&nbsp;

添加如下行

session required pam_limits.so

&nbsp;

rhel6 或更高版本 则要注意

nproc参数的生效并不是在/etc/security/limits.conf里生效，是需要在

/etc/security/limits.d/90-nproc.conf 文件中设置

参考：

!["t"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.43470452547391747.png)

|

 **Setting nproc values on Oracle Linux 6 for &nbsp; RHCK kernel (** **文档**
**ID 2108775.1)**  
  
---|---  
  
&nbsp;

[root@localhost limits.d]# cat 90-nproc.conf

# Default limit for number of user&#39;s processes to prevent

# accidental fork bombs.

# See rhbz #432903 for reasoning.

&nbsp;

*&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; soft&nbsp;&nbsp;&nbsp; nproc&nbsp;&nbsp;&nbsp;&nbsp; 1024

root&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; soft&nbsp;&nbsp;&nbsp;
nproc&nbsp;&nbsp;&nbsp;&nbsp; unlimited

&nbsp;

不要修改默认的 *&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;soft&nbsp;&nbsp;&nbsp; nproc&nbsp;&nbsp;&nbsp;&nbsp; 1024

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

pending signals&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(-i) 23692

max locked memory&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (kbytes, -l) 32

max memory size&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (kbytes, -m)
unlimited

open
files&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
(-n) 1024

pipe size&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
(512 bytes, -p) 8

POSIX message queues&nbsp;&nbsp;&nbsp;&nbsp; (bytes, -q) 819200

real-time priority&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(-r) 0

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

检查多个服务器节点的操作系统时间是否一致。如果不一致要先手动修改。

如何同时修改两台或者多台主机的时间一模一样呢？

建议使用SecureCRT工具、

使用方法：先登录一台主机

!["1.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.11358525174339618.png)

然后登录第二台主机

!["2.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.052171377050363565.png)

打开查看菜单，勾选交互窗口

!["3.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.14559717840209307.png)

窗口下方出现交互窗口

!["4.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.8117407949791782.png)

在交互窗口上右键菜单，勾选发送交互到所有会话。（此时要注意这个CRT窗口必须只能有RAC的两台服务器，不能有到其他主机的远程连接会话）

!["5.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.3774773829734348.png)&nbsp;

然后此时在交互窗口里输入的命令回车后都会自动发送到所有主机上执行。

linx修改时间的命令是&nbsp; ：年月日 时分秒

[root@rhel ~]# date -s &quot;20100405 14:31:00&quot;

&nbsp;

关闭NTP服务

Network Time Protocol Setting

# /sbin/service ntpd stop

# chkconfig ntpd off

#mv /etc/ntp.conf &nbsp;&nbsp;/etc/ntp.conf.org.

#service ntpd status

一定要保证时间同步，但是不能配置ntp，否则会导致11g的ctssd处于旁观模式。如果客户严格要求和北京时间一致，则考虑让客户提供时间服务器，然后再采用NTP和其时间服务器同步。如果配置NTP注意参数
-x 保证时间不能向回调，关于NTP配置此处不做详细解释。

&nbsp;

&nbsp;

&nbsp;

## 8、修改主机名

每个主机均要修改：

vi /etc/sysconfig/network

将其中HOSTNAME改为主机名，如下：

HOSTNAME=rac1

注意主机名不能过长,不能超过8个字符，且不能有下划线等特殊符号，不要使用大写字母，建议使用小写字母即可。

修改完主机名务必重启生效

&nbsp;

## 9、添加用户和组、创建目录

 **描述**

|

 **OS** **组名**

|

 **分配给该组的** **OS** **用户**

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

&nbsp;

/usr/sbin/groupadd -g 1000 oinstall

/usr/sbin/groupadd -g 1100 asmadmin

/usr/sbin/groupadd -g 1200 dba

/usr/sbin/groupadd -g 1201 oper

/usr/sbin/groupadd -g 1300 asmdba

/usr/sbin/groupadd -g 1301 asmoper

useradd -u 1100 -g oinstall -G asmadmin,asmdba,asmoper grid

useradd -u 1200 -g oinstall -G dba,oper,asmdba oracle

&nbsp;

修改grid、oracle 用户密码

passwd grid

passwd oracle

创建grid目录

# mkdir -p&nbsp; /u01/app/11.2.0/grid

# chown grid:oinstall /u01/&nbsp; -R

# chmod 775 /u01/ -R

    
    
    创建oracle目录

  

# mkdir -p&nbsp; /u02/app/oracle/product/11.2.0/db_home&nbsp;

# chown oracle:oinstall /u02/ -R

# chmod&nbsp; 775 /u02/ -R

&nbsp;

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

&nbsp;

 **注意： grid 用户环境变量 ORACLE_HOME 不在ORACLE_BASE 目录下 &nbsp;**

 **su - oracle**

修改oracle 用户环境变量,其中ORACLE_SID ，让开发商定好数据库名称，SID后面分别添加1和2。

su - oracle

vi .bash_profile

export ORACLE_SID=orcl1

export ORACLE_BASE=/u02/app/oracle

export ORACLE_HOME=/u02/app/oracle/product/11.2.0/db_home&nbsp;

PATH=$ORACLE_HOME/bin:$PATH:$HOME/bin

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

&nbsp;

 **注意： grid 用户环境变量 ORACLE_HOME 不在ORACLE_BASE 目录下 &nbsp;**

 **su - oracle**

修改oracle 用户环境变量

export ORACLE_SID=orcl2

export ORACLE_BASE=/u02/app/oracle

export ORACLE_HOME=/u02/app/oracle/product/11.2.0/db_home&nbsp;

PATH=$ORACLE_HOME/bin:$PATH:$HOME/bin

umask 022

export PATH

&nbsp;

## 10、ASM配置共享磁盘

 ** _配置iscsi_**

 ** _在_** ** _RHEL5_** ** _系统中_** ** _,_** **_下载并安装_** ** _iSCSI_** **
_启动器软件包_** _  
 **# rpm -ivh iscsi-initiator-utils-6.2.0.742-0.5.el5.i386.rpm**  
 **2.**_ **_在_** ** _RHEL5_** ** _系统中_** ** _,_** **_生成并查看_** ** _iSCSI_** **
_启动器的名称_** _  
 **# echo &quot;InitiatorName=`iscsi-iname`&quot;
&gt;/etc/iscsi/initiatorname.iscsi**  
 **# cat /etc/iscsi/initiatorname.iscsi**  
InitiatorName=iqn.2005-03.com.redhat:01.b9d0dd11016  
 **3.**_ **_在_** ** _RHEL5_** ** _系统中_** ** _,_** **_配置_** ** _iSCSI_** **
_启动器服务_** _  
 **# vi /etc/iscsi/iscsid.conf** (iSCSI_ _启动器服务的配置文件_ _)_ _  
node.session.auth.authmethod = CHAP  
node.session.auth.username = iqn.2005-03.com.redhat:01.b9d0dd11016  
node.session.auth.password = 01.b9d0dd11016  
 **# chkconfig iscsi --level 35 on**  
 **4.**_ **_在_** ** _SmartWin_** ** _存储设备中_** ** _,_** **_创建并分配一个_** **
_iSCSI_** ** _共享_** _  
_**_通过共享管理_** ** _-iSCSI_** ** _共享_** ** _,_** **_使用_** ** _iSCSI_** **
_共享虚拟磁盘创建一个_** ** _iSCSI_** ** _共享_** ** _;_** _  
_**_根据第_** ** _3_** ** _步得到的_** ** _iSCSI_** ** _启动器的名称_** ** _,_** **_使用_**
** _CHAP_** ** _认证模式进行分配_** ** _;_** _  
_**_启动器名称_** ** _:_** _iqn.2005-03.com.redhat:01.b9d0dd11016  
_ **_启动器口令_** ** _:_** _01.b9d0dd11016_ _  
 **5.**_ **_在_** ** _RHEL5_** ** _系统中_** ** _,_** **_启动_** ** _iSCSI_** **
_启动器服务_** _  
 **# service iscsi start**  
 **# iscsiadm -m discovery -t st -p 192.168.1.2** (_ _发现_ _)_ _  
192.168.1.2:3260,1 iqn.2004-01.com.company:block-wb  
 **# iscsiadm -m node -T iqn.2004-01.com.company:block-wb -p 192.168.1.2 -l**_

 _& nbsp;_

 _& nbsp;_

###  _10.1_ _自动存储管理器_ _(ASM)_

 _从_
_http://www.oracle.com/technetwork/topics/linux/downloads/rhel5-084877.html_
_找到要下载的三个_ _RPM_ _软件包，注意，一定要与内核版本和系统平台相符。_

 _Uname &nbsp;–a_ _查看系统版本_

 _& nbsp;_

 ** _对_** ** _ASM_** ** _进行配置_** _：_

 _# /etc/init.d/oracleasm configure_

 _Configuring the Oracle ASM library driver._

 _这将配置_ _Oracle ASM_ _库驱动程序的启动时属性。以下问题将确定在启动时是否加载驱动程序以及它将拥有的权限。当前值将显示在方括号（_
_“[]”_ _）中。按_ _& lt;ENTER&gt;_ _而不键入回应将保留该当前值。按_ _Ctrl-C_ _将终止。_

 _Default user to own the driver interface []: **grid**_

 _Default group to own the driver interface []: **oinstall**_

 _Start Oracle ASM library driver on boot (y/n) [n]: **y**_

 _Fix permissions of Oracle ASM disks on boot (y/n) [y]: **y**_

 _Writing Oracle ASM library driver configuration
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
done_

 _Creating /dev/oracleasm mount point
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
done_

 _Loading module
&quot;oracleasm&quot;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
done_

 _Mounting ASMlib driver filesystem
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;done_

 _Scanning system for ASM disks
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
done_

 _AMS_ _的命令如下所示：_

!["文本框:](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.45922659513632125.png)

 _现在，如下所示启用_ _ASMLib_ _驱动程序。_

 ** _# /etc/init.d/oracleasm enable_**

 _Writing Oracle ASM library driver configuration
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
[&nbsp; OK&nbsp; ]_

 _Scanning system for ASM disks
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
[&nbsp; OK&nbsp; ]_

 _ASM_ _的安装和配置是要在集群中的每个节点上执行的_

 _& nbsp;_

 _为_ _oracle_ _创建_ _ASM_ _磁盘：_

 _创建_ _ASM_ _磁盘只需在_ _RAC_ _集群中的一个节点上以_ _root_ _用户帐户执行。我将在_ _rac1_
_上运行这些命令。在另一个_ _Oracle RAC_ _节点上，您将需要执行_ _scandisk_ _以识别新卷。该操作完成后，应在两个_
_Oracle RAC_ _节点上运行_ _oracleasm listdisks_ _命令以验证是否创建了所有_ _ASM_ _磁盘以及它们是否可用。_

 _& nbsp;_

 _#/etc/init.d/oracleasm createdisk &nbsp; CRS&nbsp; /dev/sdd1_

 _#/etc/init.d/oracleasm createdisk &nbsp; DATA&nbsp; /dev/sdd2_

 _#/etc/init.d/oracleasm createdisk &nbsp; FRA &nbsp;/dev/sdd3_

 _& nbsp;_

 _/etc/init.d/oracleasm scandisks_

 _Scanning the system for Oracle ASMLib disks:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
[&nbsp; OK&nbsp; ]_

 _& nbsp;_

 _# /etc/init.d/oracleasm listdisks_

 _CRS_

 _DATA_

 _FRA_

 _& nbsp;_

&nbsp;

&nbsp;

### 10.2原始设备

主要分如下三种情况：

&nbsp;

情况1、使用存储专用多路径软件的情况：

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

start_udev

检查是否生成ls -l /dev/raw/raw*磁盘,以及磁盘权限是否是grid:asmadmin

情况2、使用linux操作系统自带multipath多路径软件的情况：

分rhel 5，和rhel 6两种情况。

 **rhel5:**

参考文章：

!["t"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.4079489034112391.png)

|

 **Configuring raw &nbsp; devices (multipath) for Oracle Clusterware 10g
Release 2 (10.2.0) on &nbsp; RHEL5/OL5 (** **文档** **ID 564580.1)**  
  
---|---  
  
 **Configuring non-raw multipath devices for Oracle Clusterware 11g (11.1.0,
11.2.0) on RHEL5/OL5 (** **文档** **ID 605828.1)**

 **& nbsp;**

尽量让系统工程师或者存储工程师去配置multipath多路径。

对于multipath多路径我们只提一个要求，就是磁盘要必须使用别名 alias。

如果需要我们进行多路径配置，则配置方法如下：

&nbsp;

查询磁盘设备的wwid

for i in `cat /proc/partitions | awk &#39;{print $4}&#39; |grep sd | grep
[a-z]$`; do echo &quot;### $i: `scsi_id -g -u&nbsp; -s&nbsp; /block/$i`&quot;;
done

&nbsp;

修改配置文件/etc/scsi_id.config内容如下：

vendor=&quot;ATA&quot;,options=-p 0x80  
options=-g

修改/etc/multipath.conf，wwid根据查询结果得出，注意修改磁盘别名&nbsp; alias&nbsp;&nbsp;&nbsp;

defaults&nbsp;{  
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; user_friendly_names&nbsp;yes  
}  
defaults&nbsp;{  
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; udev_dir /dev  
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; polling_interval&nbsp; 10  
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; selector &quot;round-robin&nbsp;0&quot;  
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; path_grouping_policy failover  
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; getuid_callout
&quot;/sbin/scsi_id&nbsp;-g&nbsp;-u&nbsp;-s&nbsp;/block/%n&quot;  
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; prio_callout /bin/true  
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; path_checker readsector0  
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; rr_min_io 100  
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; rr_weight priorities  
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; failback immediate  
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; #no_path_retry fail  
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; user_friendly_name yes  
}  
blacklist&nbsp;{  
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;
devnode&nbsp;&quot;^(ram|raw|loop|fd|md|dm-|sr|scd|st)[0-9]*&quot;  
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; devnode&nbsp;&quot;^hd[a-z]&quot;  
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;
devnode&nbsp;&quot;^cciss!c[0-9]d[0-9]*&quot;  
}  
multipaths&nbsp;{  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; multipath&nbsp;{  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
wwid&nbsp;&nbsp;&nbsp;&nbsp;149455400000000000000000001000000de0200000d000000  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
alias&nbsp;&nbsp;&nbsp;fra  
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;
path_grouping_policy failover  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; multipath&nbsp;{  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
wwid&nbsp;&nbsp;&nbsp;&nbsp;149455400000000000000000001000000e30200000d000000  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
alias&nbsp;&nbsp;&nbsp;data  
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp;
path_grouping_policy failover  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; multipath&nbsp;{  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
wwid&nbsp;&nbsp;&nbsp;&nbsp;149455400000000000000000001000000e80200000d000000  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
alias&nbsp;&nbsp;&nbsp;ocr1  
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;
path_grouping_policy failover  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; multipath&nbsp;{  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
wwid&nbsp;&nbsp;&nbsp;&nbsp;149455400000000000000000001000000ed0200000d000000  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
alias&nbsp;&nbsp;&nbsp;ocr2  
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;
path_grouping_policy failover  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; multipath&nbsp;{  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
wwid&nbsp;&nbsp;&nbsp;&nbsp;149455400000000000000000001000000ca0200000d000000  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
alias&nbsp;&nbsp;&nbsp;ocr3  
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;
path_grouping_policy failover  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; multipath&nbsp;{  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
wwid&nbsp;&nbsp;&nbsp;&nbsp;149455400000000000000000001000000ca0200000d000000  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
alias&nbsp;&nbsp;&nbsp;ocr4  
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;
path_grouping_policy failover  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; multipath&nbsp;{  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
wwid&nbsp;&nbsp;&nbsp;&nbsp;149455400000000000000000001000000ca0200000d000000  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
alias&nbsp;&nbsp;&nbsp;ocr5  
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;
path_grouping_policy failover  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }  
}

编写/etc/rc.local 文件，使得开机修改磁盘权限

添加如下内容：

chown grid:asmadmin /dev/mapper/ocr1

chown grid:asmadmin /dev/mapper/ocr1

chown grid:asmadmin /dev/mapper/ocr2

chown grid:asmadmin /dev/mapper/ocr3

chown grid:asmadmin /dev/mapper/ocr4

chown grid:asmadmin /dev/mapper/ocr5

chown grid:asmadmin /dev/mapper/data

chown grid:asmadmin /dev/mapper/fra

&nbsp;

chmod 660 /dev/mapper/ocr1

chmod 660 /dev/mapper/ocr1

chmod 660 /dev/mapper/ocr2

chmod 660 /dev/mapper/ocr3

chmod 660 /dev/mapper/ocr4

chmod 660 /dev/mapper/ocr5

chmod 660 /dev/mapper/data

chmod 660 /dev/mapper/fra&nbsp;

 **rhel6:**

 **参考文章：**

 **Configuring Multipath Devices on RHEL6/OL6 (** **文档** **ID 1538626.1)**

查询磁盘设备的wwid

&nbsp;for i in `cat /proc/partitions | awk &#39;{print $4}&#39; |grep sd |
grep [a-z]$`; do echo &quot;### $i: `scsi_id -g -u&nbsp; -d&nbsp;
/dev/$i`&quot;; done

 **& nbsp;**

多路径配置文件内容/etc/multipath.conf，修改wwid和别名alias&nbsp;&nbsp;&nbsp;

# grep -v ^# /etc/multipath.conf  
defaults {  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
udev_dir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
/dev  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
polling_interval&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 5  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; path_grouping_policy&nbsp;&nbsp;&nbsp;
failover  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
getuid_callout&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&quot;/lib/udev/scsi_id --whitelisted --device=/dev/%n&quot;  
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
blacklist&nbsp;{  
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;
devnode&nbsp;&quot;^(ram|raw|loop|fd|md|dm-|sr|scd|st)[0-9]*&quot;  
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; devnode&nbsp;&quot;^hd[a-z]&quot;  
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;
devnode&nbsp;&quot;^cciss!c[0-9]d[0-9]*&quot;  
}  
multipaths {  
&nbsp;&nbsp; &nbsp;multipath&nbsp;{  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
wwid&nbsp;&nbsp;&nbsp;&nbsp;149455400000000000000000001000000de0200000d000000  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
alias&nbsp;&nbsp;&nbsp;fra  
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;
path_grouping_policy failover  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; multipath&nbsp;{  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
wwid&nbsp;&nbsp;&nbsp;&nbsp;149455400000000000000000001000000e30200000d000000  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
alias&nbsp;&nbsp;&nbsp;data  
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp;
path_grouping_policy failover  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; multipath&nbsp;{  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
wwid&nbsp;&nbsp;&nbsp;&nbsp;149455400000000000000000001000000e80200000d000000  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
alias&nbsp;&nbsp;&nbsp;ocr1  
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;
path_grouping_policy failover  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; multipath&nbsp;{  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
wwid&nbsp;&nbsp;&nbsp;&nbsp;149455400000000000000000001000000ed0200000d000000  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
alias&nbsp;&nbsp;&nbsp;ocr2  
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;
path_grouping_policy failover  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; multipath&nbsp;{  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
wwid&nbsp;&nbsp;&nbsp;&nbsp;149455400000000000000000001000000ca0200000d000000  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
alias&nbsp;&nbsp;&nbsp;ocr3  
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;
path_grouping_policy failover  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; multipath&nbsp;{  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
wwid&nbsp;&nbsp;&nbsp;&nbsp;149455400000000000000000001000000ca0200000d000000  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
alias&nbsp;&nbsp;&nbsp;ocr4  
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;
path_grouping_policy failover  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; multipath&nbsp;{  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
wwid&nbsp;&nbsp;&nbsp;&nbsp;149455400000000000000000001000000ca0200000d000000  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
alias&nbsp;&nbsp;&nbsp;ocr5  
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;
path_grouping_policy failover  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }

}

&nbsp;

查看多路径磁盘对应的dm-X 名称

ls -l /dev/mapper/|grep dm*

将共享存储磁盘列表抓取出来，通过notepad++工具进行列编辑

注意不要修改RAC非存储磁盘的权限。

 _因为rhel 6 多路径和5不一样，/dev/mapper下不再是块设备磁盘，而是软连接。_

 _dm-X 多路径绑定出来后，不同节点生成的dm-X对应的存储磁盘有可能不一致。_

 _因此参考mos文章：_

 **How to set udev rule for setting the disk permission on ASM disks when
using multipath on OL 6.x (** **文档 ID 1521757.1)**

 **使用udev修改磁盘权限和属主**

vi&nbsp; /etc/udev/rules.d/12-dm-permissions-highgo.rules

添加如下内容，根据实际情况进行调整：

 _& nbsp;_

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

 _& nbsp;_

root用户执行

start_udev

重新加载udev设备

ls –l /dev/dm-*&nbsp; 检查磁盘属主和权限是否正确。

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

&nbsp;for i in `cat /proc/partitions | awk &#39;{print $4}&#39; |grep sd |
grep [a-z]$`; do echo &quot;### $i: `scsi_id -g -u&nbsp; -d&nbsp;
/dev/$i`&quot;; done

例如：

&nbsp; ###sdb:&nbsp;&nbsp; 149455400000000000000000001000000de0200000d000000

&nbsp; ###sdc:&nbsp;&nbsp; 149455400000000000000000001000000e30200000d000000

&nbsp; ###sdd:&nbsp;&nbsp; 149455400000000000000000001000000e80200000d000000

&nbsp; ###sde:&nbsp;&nbsp; 149455400000000000000000001000000ed0200000d000000

&nbsp; ###sdf:&nbsp;&nbsp; 149455400000000000000000001000000ca0200000d000000

&nbsp; ###sdg:&nbsp;&nbsp; 149455400000000000000000001000000ca0200000d000000

&nbsp; ###sdh:&nbsp;&nbsp; 149455400000000000000000001000000ca0200000d000000

&nbsp;

举例其中b\c\d\e\f\g\h盘是存储磁盘，要用来创建ASM磁盘组。

vi /etc/udev/rules.d/99-asm-highgo.rules

添加如下内容 拿sdb磁盘举例，

1修改其中的RESULT为上面查出来对对应WWID值：

2修改RUN+=&quot;/bin/raw /dev/raw/raw1 %N&quot;中raw磁盘名称raw1

&nbsp;

ACTION==&quot;add&quot;,BUS==&quot;scsi&quot;, KERNEL==&quot;sd*&quot;,
PROGRAM==&quot;/sbin/scsi_id --whitelisted --replace-whitespace
--device=/dev/$name&quot;,
RESULT==&quot;149455400000000000000000001000000de0200000d000000&quot;,
RUN+=&quot;/bin/raw /dev/raw/raw1 %N&quot;

ACTION==&quot;add&quot;,BUS==&quot;scsi&quot;, KERNEL==&quot;sd*&quot;,
PROGRAM==&quot;/sbin/scsi_id --whitelisted --replace-whitespace
--device=/dev/$name&quot;,
RESULT==&quot;149455400000000000000000001000000e30200000d000000&quot;,
RUN+=&quot;/bin/raw /dev/raw/raw2 %N&quot;

ACTION==&quot;add&quot;,BUS==&quot;scsi&quot;, KERNEL==&quot;sd*&quot;,
PROGRAM==&quot;/sbin/scsi_id --whitelisted --replace-whitespace
--device=/dev/$name&quot;,
RESULT==&quot;149455400000000000000000001000000e80200000d000000&quot;,
RUN+=&quot;/bin/raw /dev/raw/raw3 %N&quot;

ACTION==&quot;add&quot;,BUS==&quot;scsi&quot;, KERNEL==&quot;sd*&quot;,
PROGRAM==&quot;/sbin/scsi_id --whitelisted --replace-whitespace
--device=/dev/$name&quot;,
RESULT==&quot;149455400000000000000000001000000ed0200000d000000&quot;,
RUN+=&quot;/bin/raw /dev/raw/raw4 %N&quot;

ACTION==&quot;add&quot;,BUS==&quot;scsi&quot;, KERNEL==&quot;sd*&quot;,
PROGRAM==&quot;/sbin/scsi_id --whitelisted --replace-whitespace
--device=/dev/$name&quot;,
RESULT==&quot;149455400000000000000000001000000ca0200000d000000&quot;,
RUN+=&quot;/bin/raw /dev/raw/raw5 %N&quot;

ACTION==&quot;add&quot;,BUS==&quot;scsi&quot;, KERNEL==&quot;sd*&quot;,
PROGRAM==&quot;/sbin/scsi_id --whitelisted --replace-whitespace
--device=/dev/$name&quot;,
RESULT==&quot;149455400000000000000000001000000ca0200000d000000&quot;,
RUN+=&quot;/bin/raw /dev/raw/raw6 %N&quot;

ACTION==&quot;add&quot;,BUS==&quot;scsi&quot;, KERNEL==&quot;sd*&quot;,
PROGRAM==&quot;/sbin/scsi_id --whitelisted --replace-whitespace
--device=/dev/$name&quot;,
RESULT==&quot;149455400000000000000000001000000ca0200000d000000&quot;,
RUN+=&quot;/bin/raw /dev/raw/raw7 %N&quot;

使用哪个共享磁盘，则相应添加以上内容。

修改磁盘权限和属主：

KERNEL==&quot;raw1&quot;, OWNER=&quot;grid&quot;, GROUP=&quot;asmadmin&quot;,
MODE=&quot;660&quot;

KERNEL==&quot;raw2&quot;, OWNER=&quot;grid&quot;, GROUP=&quot;asmadmin&quot;,
MODE=&quot;660&quot;

KERNEL==&quot;raw3&quot;, OWNER=&quot;grid&quot;, GROUP=&quot;asmadmin&quot;,
MODE=&quot;660&quot;

KERNEL==&quot;raw4&quot;, OWNER=&quot;grid&quot;, GROUP=&quot;asmadmin&quot;,
MODE=&quot;660&quot;

KERNEL==&quot;raw5&quot;, OWNER=&quot;grid&quot;, GROUP=&quot;asmadmin&quot;,
MODE=&quot;660&quot;

KERNEL==&quot;raw6&quot;, OWNER=&quot;grid&quot;, GROUP=&quot;asmadmin&quot;,
MODE=&quot;660&quot;

KERNEL==&quot;raw7&quot;, OWNER=&quot;grid&quot;, GROUP=&quot;asmadmin&quot;,
MODE=&quot;660&quot;

&nbsp;

root用户执行

start_udev

重新加载udev设备

ls –l /dev/raw/raw* 查询raw是否成功挂在磁盘，并确认磁盘属主和权限是否正确

&nbsp;

 ** _小技巧：如果需要手动解除绑定：raw /dev/raw/raw13 0 0 ＃解除raw13绑定_**

&nbsp;

 **rhel 5:**

 **Linux: How To Setup UDEV Rules For RAC OCR And Voting Devices On SLES10,
RHEL5, OEL5, OL5 (** **文档** **ID 414897.1)**

 **& nbsp;**

查询设备wwid，注意和rhel6的区别是 scsi_id的 参数6是-d ，5是-s

另外磁盘是/block/sdx 而不是/dev/sdx

for i in `cat /proc/partitions | awk &#39;{print $4}&#39; |grep sd | grep
[a-z]$`; do echo &quot;### $i: `scsi_id -g -u&nbsp; -s&nbsp; /block/$i`&quot;;
done

同rhel6设置类似，同样修改RESULT和RUN的标记参数。

vi /etc/udev/rules.d/99-asm-highgo.rules

&nbsp;

ACTION==&quot;add&quot;,BUS==&quot;scsi&quot;, KERNEL==&quot;sd*&quot;,
PROGRAM==&quot;/sbin/scsi_id -g -u -s %p&quot;,
RESULT==&quot;14f504e46494c45525743714d4f6a2d6437466f2d30435362&quot;,
RUN+=&quot;/bin/raw /dev/raw/raw1 %N&quot;

ACTION==&quot;add&quot;,BUS==&quot;scsi&quot;, KERNEL==&quot;sd*&quot;,
PROGRAM==&quot;/sbin/scsi_id -g -u -s %p&quot;,
RESULT==&quot;149455400000000000000000001000000e30200000d000000&quot;,
RUN+=&quot;/bin/raw /dev/raw/raw2 %N&quot;

ACTION==&quot;add&quot;,BUS==&quot;scsi&quot;, KERNEL==&quot;sd*&quot;,
PROGRAM==&quot;/sbin/scsi_id -g -u -s %p&quot;,
RESULT==&quot;149455400000000000000000001000000e80200000d000000&quot;,
RUN+=&quot;/bin/raw /dev/raw/raw3 %N&quot;

ACTION==&quot;add&quot;,BUS==&quot;scsi&quot;, KERNEL==&quot;sd*&quot;,
PROGRAM==&quot;/sbin/scsi_id -g -u -s %p&quot;,
RESULT==&quot;149455400000000000000000001000000ed0200000d000000&quot;,
RUN+=&quot;/bin/raw /dev/raw/raw4 %N&quot;

ACTION==&quot;add&quot;,BUS==&quot;scsi&quot;, KERNEL==&quot;sd*&quot;,
PROGRAM==&quot;/sbin/scsi_id -g -u -s %p&quot;,
RESULT==&quot;149455400000000000000000001000000ca0200000d000000&quot;,
RUN+=&quot;/bin/raw /dev/raw/raw5 %N&quot;

ACTION==&quot;add&quot;,BUS==&quot;scsi&quot;, KERNEL==&quot;sd*&quot;,
PROGRAM==&quot;/sbin/scsi_id -g -u -s %p&quot;,
RESULT==&quot;149455400000000000000000001000000ca0200000d000000&quot;,
RUN+=&quot;/bin/raw /dev/raw/raw6 %N&quot;

ACTION==&quot;add&quot;,BUS==&quot;scsi&quot;, KERNEL==&quot;sd*&quot;,
PROGRAM==&quot;/sbin/scsi_id -g -u -s %p&quot;,
RESULT==&quot;149455400000000000000000001000000ca0200000d000000&quot;,
RUN+=&quot;/bin/raw /dev/raw/raw7 %N&quot;

&nbsp;

使用哪个共享磁盘，则相应添加以上内容。

修改磁盘权限和属主：

KERNEL==&quot;raw1&quot;, OWNER=&quot;grid&quot;, GROUP=&quot;asmadmin&quot;,
MODE=&quot;660&quot;

KERNEL==&quot;raw2&quot;, OWNER=&quot;grid&quot;, GROUP=&quot;asmadmin&quot;,
MODE=&quot;660&quot;

KERNEL==&quot;raw3&quot;, OWNER=&quot;grid&quot;, GROUP=&quot;asmadmin&quot;,
MODE=&quot;660&quot;

KERNEL==&quot;raw4&quot;, OWNER=&quot;grid&quot;, GROUP=&quot;asmadmin&quot;,
MODE=&quot;660&quot;

KERNEL==&quot;raw5&quot;, OWNER=&quot;grid&quot;, GROUP=&quot;asmadmin&quot;,
MODE=&quot;660&quot;

KERNEL==&quot;raw6&quot;, OWNER=&quot;grid&quot;, GROUP=&quot;asmadmin&quot;,
MODE=&quot;660&quot;

KERNEL==&quot;raw7&quot;, OWNER=&quot;grid&quot;, GROUP=&quot;asmadmin&quot;,
MODE=&quot;660&quot;

&nbsp;

root用户执行

start_udev

重新加载udev设备

ls –l /dev/raw/raw* 查询raw是否成功挂在磁盘，并确认磁盘属主和权限是否正确

&nbsp;

**注意：要根据你的实际情况来配置，不建议使用自动shell脚本生成以上内容，建议notepad++等工具进行列模式编辑。特别是添加磁盘到现有生产环境的情况，脚本不可控，存在安全隐患。**

&nbsp;

### 针对如上三种情况都需要创建用于ASM访问的磁盘软链接

mkdir /u01/asm-disk/

举例如：

ln -s /dev/mapper/ocr1 /u01/asm-disk/ocr1

ln -s /dev/mapper/ocr2 /u01/asm-disk/ocr2

ln -s /dev/mapper/ocr3 /u01/asm-disk/ocr3

ln -s /dev/mapper/ocr4 /u01/asm-disk/ocr4

ln -s /dev/mapper/ocr5 /u01/asm-disk/ocr5

ln -s /dev/mapper/data /u01/asm-disk/data

ln -s /dev/mapper/fra&nbsp; /u01/asm-disk/fra

&nbsp;

ln -s /dev/raw/raw1&nbsp; /u01/asm-disk/ocr1

ln -s /dev/raw/raw2&nbsp; /u01/asm-disk/ocr2

ln -s /dev/raw/raw3&nbsp; /u01/asm-disk/ocr3

&nbsp;

&nbsp;

无论哪种形式的裸设备最后都要建立软连接，到/u01/asm-disk目录

根据实际情况进行修改。

 **配置到此后需要重启下服务器，确保所有的存储磁盘均可自动挂在、主机名等信息都是正确的。**

##  11、安装 Oracle Grid Infrastructure

vnc连接服务器

root登录

解压群集安装程序

#gunzip p13390677_112040_Linux-x86-64_3of7.zip -d /tmp/

#cd /tmp/grid/

#xhost+

#su - grid

$cd /tmp/grid

$./runInstaller

以下截图内值均未参考选项，以实际内容为准。

!["6.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.8605306726560313.png)

!["7.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.8711037065183045.png)!["8.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.5586013438783353.png)

注意： SCAN name 必须和DNS解析的域名一致，如果DNS不能成功解析，那么这一步会报错

 **网格命名服务 (GNS)**

从 Oracle Clusterware 11 _g_ 第 2 版开始，引入了另一种分配 IP 地址的方法，即 _网格命名服务_ (GNS)。该方法允许使用
DHCP 分配所有专用互连地址以及大多数 VIP 地址。GNS 和 DHCP 是 Oracle 的新的网格即插即用 (GPnP) 特性的关键要素，如
Oracle 所述，该特性使我们无需配置每个节点的数据，也不必具体地添加和删除节点。通过实现对集群网络需求的自我管理，GNS 实现了 _动态_
网格基础架构。与手动定义静态 IP 地址相比，使用 GNS 配置 IP
地址确实有其优势并且更为灵活，但代价是增加了复杂性，该方法所需的一些组件未在这个构建经济型 Oracle RAC 的指南中定义。例如，为了在集群中启用
GNS，需要在公共网络上有一个 DHCP 服务器. 要了解 GNS 的更多优势及其配置方法，请参见 [适用于 Linux 的 Oracle Grid
Infrastructure 11 _g_ 第 2 版 (11.2)
安装指南](https://47.100.29.40/highgo_admin/%22http://download.oracle.com/docs/cd/E11882_01/install.112/e10812/toc.htm%22)。

&nbsp;!["9.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.19846480448132398.png)

先点击setup按钮来建立主机之间的ssh互信，左右就是服务器之间ssh登录时可以不需要输入对方操作系统账户的密码。

!["10.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.31142605654802225.png)根据定义的网卡选择网络类型&nbsp;
public 还是 心跳private

&nbsp;!["11.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.559082206147633.png)!["12.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.29471787809812944.png)此处要求存储工程师划分5个3G的LUN
用来做CRS磁盘组

此处冗余模式 Redundancy要选择High

下方勾选5个3G的磁盘。

 **注意此处添加的磁盘是存储磁盘软链接存放的目录/dev/asm-disk/**

&nbsp;!["13.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.19441230175774482.png)
**ASM 必须达到一定的密码标准。密码中要包含字母大写、小写、数字，至少8个字符。**

&nbsp;!["14.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.665214678361044.png)!["15.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.06561406733046393.png)!["16.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.0945493167849476.png)!["17.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.3449447431118451.png)!["18.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.533950503622669.png)

如果只有以上三个条件不满足，勾选右上角的ignore all，如果存在其他条件不满足则要进行相应处理。

!["19.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.9595728528988854.png)!["20.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.33387970059815797.png)&nbsp;  

若集群root.sh脚本运行不成功：

#删除crs配置信息

#/u01/app/11.2.0/grid/crs/install/rootcrs.pl -verbose -deconfig -force

&nbsp;!["21.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.8765606026304236.png)

 **出现这两个错误可以忽略不计，直接下一步退出。也可以用下面的方法避免错误出现。**

 _如果您只在_ _hosts_ _文件中定义_ _SCAN_ _但却想让_ _CVU_ _成功完成，只需在两个_ _Oracle RAC_ _节点上以_
_root_ _身份对_ _nslookup_ _实用程序进行如下修改。_

 _首先，在两个_ _Oracle RAC_ _节点上将原先的_ _nslookup_ _二进制文件重命名为_ _nslookup.original_
_：_

 _[root@racnode1 ~]# **mv /usr/bin/nslookup /usr/bin/nslookup.original**_

 _然后，新建一个名为_ _/usr/bin/nslookup_ _的_ _shell_ _脚本，在该脚本中用_ _202.102.128.68_
_替换主_ _DNS_ _，用_ _rac-scan_ _替换_ _SCAN_ _主机名，用_ _192.168.0.127_ _替换_ _SCAN IP_
_地址，如下所示：_

 _#!/bin/bash_

 _& nbsp;_

 _HOSTNAME=${1}_

 _& nbsp;_

 _if [[ $HOSTNAME = &quot;rac-scan&quot; ]]; then_

 _& nbsp;&nbsp;&nbsp; echo &nbsp;
&quot;Server:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
202.102.128.68&quot;_

 _& nbsp;&nbsp;&nbsp; echo &nbsp;
&quot;Address:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
202.102.128.68#53&quot;_

 _& nbsp;&nbsp;&nbsp; echo &nbsp; &quot;Non-authoritative answer:&quot;_

 _& nbsp;&nbsp;&nbsp; echo &nbsp; &quot;Name:&nbsp;&nbsp; rac-scan&quot;_

 _& nbsp;&nbsp;&nbsp; echo &nbsp; &quot;Address: 192.168.0.127&quot;_

 _else_

 _& nbsp;&nbsp;&nbsp; &nbsp; /usr/bin/nslookup.original $HOSTNAME_

 _fi_  
  
---  
  
 _最后，将新建的_ _nslookup shell_ _脚本更改为可执行脚本：_

 _[root@racnode1 ~]# **chmod 755 /usr/bin/nslookup**_

 _记住要在两个_ _Oracle RAC_ _节点上执行这些操作。_

 _每当_ _CVU_ _使用您的_ _SCAN_ _主机名调用_ _nslookup_ _脚本时，这个新的_ _nslookup shell_
_脚本只是回显您的_ _SCAN IP_ _地址，其他情况下则会调用原先的_ _nslookup_ _二进制文件。_

 _在_ _Oracle Grid Infrastructure_ _的安装过程中，当_ _CVU_ _尝试验证您的_ _SCAN_
_时，它就会成功通过：_

 _[grid@racnode1 ~]$ **cluvfy comp scan -verbose**_

 _& nbsp;_

 _Verifying scan_

 _& nbsp;_

 _Checking Single Client Access Name (SCAN)..._

 _& nbsp; SCAN VIP &nbsp; name&nbsp;&nbsp;&nbsp;&nbsp;
Node&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Running?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ListenerName&nbsp;
Port&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Running?&nbsp;&nbsp;&nbsp;_

 _& nbsp; &nbsp; ----------------&nbsp; &nbsp; ------------&nbsp;
------------&nbsp; ------------&nbsp; ------------&nbsp; ------------_

 _& nbsp; &nbsp; racnode-cluster-scan&nbsp; &nbsp;
racnode1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
true&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
LISTENER&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1521&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;true&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_

 _& nbsp;_

 _Checking name resolution setup for &nbsp; &quot;racnode-cluster-
scan&quot;..._

 _& nbsp; SCAN Name&nbsp;&nbsp;&nbsp;&nbsp; IP
Address&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Status&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Comment&nbsp;&nbsp;_

 _& nbsp; &nbsp; ------------&nbsp; &nbsp; ------------------------&nbsp;
&nbsp; ------------------------&nbsp; &nbsp; ----------_

 _& nbsp; &nbsp; racnode-cluster-scan&nbsp; &nbsp;
192.168.1.187&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
**passed**_

 _& nbsp;_

 _Verification of SCAN VIP and Listener setup passed_

 _& nbsp;_

 _Verification of scan was successful._

 _& nbsp;_

_===============================================================================_

 _& nbsp;_

 _[grid@racnode2 ~]$ **cluvfy comp scan -verbose**_

 _& nbsp;_

 _Verifying scan_

 _& nbsp;_

 _Checking Single Client Access Name (SCAN)..._

 _& nbsp; SCAN VIP &nbsp; name&nbsp;&nbsp;&nbsp;&nbsp;
Node&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Running?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ListenerName&nbsp;
Port&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Running?&nbsp;&nbsp;&nbsp;_

 _& nbsp; &nbsp; ----------------&nbsp; &nbsp; ------------&nbsp;
------------&nbsp; ------------&nbsp; ------------&nbsp; ------------_

 _& nbsp; &nbsp; racnode-cluster-scan&nbsp; &nbsp;
racnode1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
true&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
LISTENER&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1521&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
true&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_

 _& nbsp;_

 _Checking name resolution setup for &nbsp; &quot;racnode-cluster-
scan&quot;..._

 _& nbsp; SCAN Name&nbsp;&nbsp;&nbsp;&nbsp; IP
Address&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Status&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Comment&nbsp;&nbsp;_

 _& nbsp; &nbsp; ------------&nbsp; &nbsp; ------------------------&nbsp;
&nbsp; ------------------------&nbsp; &nbsp; ----------_

 _& nbsp; &nbsp; racnode-cluster-scan&nbsp; &nbsp;
192.168.1.187&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
**passed**_

 _& nbsp;_

 _Verification of SCAN VIP and Listener setup passed_

 _& nbsp;_

 _Verification of scan was successful._  
  
---  
  
&nbsp;

## 12、集群安装后的任务

&nbsp;(1)、验证oracle clusterware的安装

以grid身份运行以下命令：

检查crs状态：

[grid@rac1 ~]$ crsctl check crs

CRS-4638: Oracle High Availability Services is online

CRS-4537: Cluster Ready Services is online

CRS-4529: Cluster Synchronization Services is online

CRS-4533: Event Manager is online

&nbsp;

检查 Clusterware 资源:

[grid@rac1 ~]$ crsctl stat res -t

\----------------------------------------------------------

NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
TARGET&nbsp; STATE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
SERVER&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; STATE_DETAILS

\--------------------------------------------------------------

Local Resources&nbsp;&nbsp;&nbsp;

\--------------------------------------------------------------

ora.DATA.dg&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ONLINE&nbsp;
ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

ora.FRA.dg&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ONLINE&nbsp;
ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

ora.LISTENER.lsnr&nbsp; ONLINE&nbsp;
ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

ora.OCR.dg&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ONLINE&nbsp;
ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

ora.asm&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Started&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Started&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

ora.gsd&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;OFFLINE OFFLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
OFFLINE OFFLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

ora.net1.network&nbsp;&nbsp; ONLINE&nbsp;
ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

ora.ons&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

ora.registry.acfs&nbsp; ONLINE&nbsp;
ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

\--------------------------------------------------------------

Cluster Resources

\--------------------------------------------------------------

ora.LISTENER_SCAN1.lsnr

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

ora.cvu&nbsp;&nbsp;&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

ora.oc4j&nbsp;&nbsp;&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

ora.rac1.vip&nbsp;&nbsp;&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

ora.rac2.vip&nbsp;&nbsp;&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ONLINE&nbsp;
ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

ora.scan1.vip&nbsp;&nbsp;&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

&nbsp;

检查集群节点:

[grid@rac1 ~]$ olsnodes -n

rac1&nbsp;&nbsp;&nbsp; 1

rac2&nbsp;&nbsp;&nbsp; 2

检查两个节点上的 Oracle TNS 监听器进程:

[grid@rac1 ~]$ srvctl status listener

Listener LISTENER is enabled

Listener LISTENER is running on node(s): rac2,rac1

&nbsp;

(2)为数据和快速恢复区创建 ASM 磁盘组

!["22.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.611520614285576.png)

asmca

!["23.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.46784502129446826.png)在
Disk Groups 选项卡中，单击 **Create** 按钮，在出现的画面中创建data卷：

除了CRS磁盘组以外其余存放数据和归档的磁盘组默认都是选择Extenal外部冗余模式，除非客户特殊要求。

!["24.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.19941606993944805.png)!["25.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.21502181325500747.png)!["26.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.2572574320022112.png)!["27.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.8919987389204169.png)&nbsp;  

对于磁盘组的规划，一般一套rac 含有一个CRS磁盘组，一个FRA磁盘组用于存放归档日志，一个或者多个DATA磁盘组用于存放数据。

单击Exit退出ASM配置向导。

&nbsp;

&nbsp;

&nbsp;

 **至此重启下服务器确认crs各个资源状态均正常。**

##  13、安装oracle 11g r2 database

vnc图形化登录服务器

root用户登录

依次解压如下两个安装包

unzip p13390677_112040_Linux-x86-64_1of7.zip -d /tmp/

unzip p13390677_112040_Linux-x86-64_2of7.zip -d /tmp/

xhost+

su - oracle

$cd /tmp/database

$./runInstaller

&nbsp;!["28.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.37536572664421186.png)&nbsp;

选择 **Real Application Clusters database installation** 单选按钮（此为默认选择），确保选中 Node
Name 窗口中的两个 Oracle RAC 节点。

接下来，单击 [SSH Connectivity] 按钮。输入 oracle 用户的 OS Password，然后单击 [Setup] 按钮。这会启动
SSH Connectivity 配置过程：

&nbsp;!["29.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.22722088971121512.png)!["30.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.9068722569127068.png)!["31.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.657531101785439.png)!["32.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.36273781138757366.png)!["33.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.30995731843075136.png)!["34.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.17420255955138697.png)!["35.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.2757406907747719.png)!["36.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.10634160346501087.png)!["37.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.5185861079171048.png)!["38.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.4024912356983439.png)

待安装完成后在各个节点执行root.sh脚本，完成后退出向导。

## 14、创建、删除数据库

&nbsp;

### 14.1 创建数据库

&nbsp;使用dbca创建，创建之前确保已安装的所有服务（Oracle TNS 监听器、Oracle Clusterware 进程等）正在运行。

[grid@rac1 ~]$ crsctl stat res -t

\----------------------------------------------------------

NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
TARGET&nbsp; STATE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
SERVER&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; STATE_DETAILS

\--------------------------------------------------------------

Local Resources&nbsp;&nbsp;&nbsp;

\--------------------------------------------------------------

ora.DATA.dg&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ONLINE&nbsp;
ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

ora.FRA.dg&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ONLINE&nbsp;
ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;rac2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

ora.LISTENER.lsnr&nbsp; ONLINE&nbsp;
ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

ora.OCR.dg&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ONLINE&nbsp;
ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

ora.asm&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Started&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Started&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

ora.gsd&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;OFFLINE OFFLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
OFFLINE OFFLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

ora.net1.network&nbsp;&nbsp; ONLINE&nbsp;
ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

ora.ons&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

ora.registry.acfs&nbsp; ONLINE&nbsp;
ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

\--------------------------------------------------------------

Cluster Resources

\--------------------------------------------------------------

ora.LISTENER_SCAN1.lsnr

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

ora.cvu&nbsp;&nbsp;&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

ora.oc4j&nbsp;&nbsp;&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

ora.rac1.vip&nbsp;&nbsp;&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

ora.rac2.vip&nbsp;&nbsp;&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;

ora.scan1.vip&nbsp;&nbsp;&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

[grid@rac1 ~]$&nbsp;&nbsp;&nbsp;&nbsp;

&nbsp;!["39.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.32211838039875773.png)!["40.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.18259448097207165.png)!["41.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.006069727418273496.png)!["42.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.23239562946966563.png)!["43.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.6398880024860276.png)!["44.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.2393387457948426.png)!["45.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.9613096078625729.png)

点击&quot;Multiplex Redo Logs and Control Files&quot; 输入多个磁盘组来产生冗余控制文件和redo文件。

如果存在+FRA则填写 +DATA和+FRA

如果不存在+FRA，只有+DATA ，则添加两个+DATA

原则就是要多个控制文件和redo文件，而且尽量要存放在不同的磁盘组中。

!["46.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.6133154314171965.png)!["47.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.18907206930127862.png)!["48.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.31410448504725674.png)

数据库安装成功并正常启动需要将sga设置大于1072m

保守的设置原则是 ：

SGA_TARGET+pga_aggregate_target=物理内存*0.6

SGA_TARGET : pga_aggregate_target &nbsp;比例是4:1

SGA_TARGET 等于 SGA_MAX_SIZE

&nbsp;

根据实际物理内存进行调整。

!["49.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.5419044108827562.png)!["50.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.11989850547083791.png)字符集的必须和开发人员进行确认，不能猜测使用，数据库建立完成后字符集不能进行修改。

!["51.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.11965896566337975.png)!["52.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.46630721529149377.png)这里得注意新加的两组日志一个是线程Thread#
1，一个是线程Thread# 2

!["53.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.2115103522880457.png)!["54.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.19386815981461258.png)!["55.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.42836872000768955.png)!["56.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.23519107693546126.png)

### 14.2 删除数据库

删除数据库最好也用dbca，虽然srvctl也可以。

1.&nbsp;&nbsp;&nbsp; 运行dbca，选择”delete a database”。然后就next..，直到finish。

2.&nbsp;&nbsp;&nbsp; 数据的删除并不影响asm实例，如果想删除与asm有关的内容，可以按如下做法：

# export ORACLE_SID= _ASM_instance_name_

# sqlplus / as sysdba

SQL&gt; drop diskgroup _diskgroup_name_ including contents;

SQL&gt; quit

然后在各个节点上执行

# srvctl stop asm –n hostname

# srvctl remove asm –n hostname

这样，应该就可以删除的比较干净了。

&nbsp;

&nbsp;

## 15、常用命令

###  _15.1_ _、_ _oracle_ _用户管理数据库命令_

 ** _srvctl status_** _  
&nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;Available options:
database|instance|service|nodeapps|asm  
  
&nbsp; # Display help for database level  
&nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;srvctl status database -h  
  
&nbsp;# Display instance&#39;s running status on each node  
&nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;srvctl status database -d orcl  
&nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;example output:  
&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; Instance orcl1 is(not) running on node
rac1  
&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; Instance orcl2 is(not) running on node
rac2  
  
# include&nbsp;&nbsp;disabled applications  
&nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;srvctl status database -d orcl -f  
  
&nbsp;# verbos output  
&nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;srvctl status database -d orcl -v  
  
&nbsp;# Additional information for EM Console  
&nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;srvctl status database -d orcl -S
EM_AGENT_DEBUG  
  
&nbsp; # Additional information for EM Console  
&nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;srvctl status database -d orcl -i orcl1
-S EM_AGENT_DEBUG  
  
&nbsp;&nbsp;&nbsp;# Display help for instance level  
&nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;srvctl status instance -h  
  
&nbsp; &nbsp;# display appointed instance&#39;s running status  
&nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;srvctl status instance -d orcl -i orcl1  
  
&nbsp; &nbsp;# Display help for node level  
&nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;srvctl status nodeapps -h  
  
&nbsp; &nbsp;&nbsp;# Display all app&#39;s status on the node xxx  
&nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;srvctl status nodeapps -n
&lt;node_name&gt;_

 _& nbsp;_

 _& nbsp;_

 ** _& nbsp;_**

 ** _& nbsp;_**

 ** _& nbsp;_**

 ** _srvctl start_**

 _& nbsp;_

 _& nbsp;&nbsp;# Start database  
&nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;srvctl start database -d orcl -o nomount  
&nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;srvctl start database -d orcl -o mount  
&nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;srvctl start database -d orcl -o open_

 _& nbsp;_

 _# Grammar for start instance  
&nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;srvctl start instance -d [db_name] -i
[instance_name]  
&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;-o
[start_option] -c [connect_str]_ _–_ _q_

 _& nbsp;_

 _# Start all instances on the all nodes  
&nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;srvctl start instance -d orcl -i
orcl1,orcl2,_

 _& nbsp;_

 _# Start ASM instance  
&nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;srvctl start ASM -n [node_name] -i asm1
-o open  
  
# Start all apps in one node  
&nbsp; &nbsp;&nbsp;&nbsp;srvctl start nodeapps -n [node_name]_

 _& nbsp;_

 _& nbsp;_

 ** _srvctl stop_**

 _& nbsp;_

 _# Stop database  
&nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;srvctl stop database -d orcl -o normal  
&nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;srvctl stop database -d orcl -o
immediate  
&nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;srvctl stop database -d orcl -o abort  
  
&nbsp;# Grammar for stop&nbsp;&nbsp;instance  
&nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;srvctl stop instance -d [db_name] -i
[instance_name]  
&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;-o
[start_option] -c [connect_str] -q  
  
&nbsp;# Stop all instances on the all nodes  
&nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;srvctl stop instance -d orcl -i
orcl1,orcl2,...  
  
# Stop ASM instance  
&nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;srvctl stop ASM -n [node_name] -i asm1
-o [option]  
  
&nbsp;# Stop all apps in one node  
&nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;srvctl stop nodeapps -n [node_name]_

&nbsp;

 _& nbsp;_

###  _15.2_ _、启动_ _/_ _停止集群命令_

 _以下停止/启动操作需要以_ ` root` _身份来执行_

 ** _在本地服务器上停止 Oracle Clusterware 系统_**

 _在_ ` rac1` _节点上使用_ ` crsctl stop cluster` _命令停止 Oracle Clusterware 系统：_

 ** _#/u01/app/11.2.0/grid/bin/crsctl stop cluster_**

 ** _注：_** _在运行“_` crsctl stop cluster` _” 命令之后，如果 Oracle Clusterware
管理的资源中有任何一个还在运行，则整个命令失败。使用_ `-f` _选项无条件地停止所有资源并停止 Oracle Clusterware 系统。_

 _& nbsp;_

 ** _在本地服务器上启动_** **_Oracle Clusterware_** **_系统_**

 _在_ _rac1_ _节点上使用_ _crsctl start cluster_ _命令启动_ _Oracle Clusterware_ _系统：_

 _[root@rac1 ~]# **/u01/app/11.2.0/grid/bin/crsctl start cluster**_

 ** _注：_** _可通过指定_ _-all_ _选项在集群中所有服务器上启动_ _Oracle Clusterware_ _系统。_

 _[root@rac1 ~]# **/u01/app/11.2.0/grid/bin/crsctl start cluster -all**_

 _还可以通过列出服务器（各服务器之间以空格分隔）在集群中一个或多个指定的服务器上启动_ _Oracle Clusterware_ _系统：_

 _[root@rac1 ~]# **/u01/app/11.2.0/grid/bin/crsctl start cluster -n rac1
rac2**_

 _& nbsp;_

 _& nbsp;_

###  _15.3_ _检查集群的运行状况（集群化命令）_

 _以_ _grid_ _用户身份运行以下命令。_

 _[grid@rac1 ~]$ **crsctl check cluster**_

 _CRS-4537: Cluster Ready Services is online_

 _CRS-4529: Cluster Synchronization Services is online_

 _CRS-4533: Event Manager is online_

 ** _所有_** **_Oracle_** **_实例_** **_—_** ** _（数据库状态）_**

 _[oracle@rac1 ~]$ **srvctl status database -d orcl**_

 _Instance orcl1 is running on node rac1_

 _Instance orcl2 is running on node rac2_

 ** _单个_** **_Oracle_** **_实例_** **_—_** ** _（特定实例的状态）_**

 _[oracle@rac1 ~]$ **srvctl status instance -d orcl -i orcl1**_

 _Instance orcl1 is running on node rac1_

 ** _节点应用程序_** **_—_** ** _（状态）_**

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

 ** _节点应用程序_** **_—_** ** _（配置）_**

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

 ** _数据库_** **_—_** ** _（配置）_**

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

 ** _TNS_** **_监听器_** **_—_** ** _（状态）_**

 _[oracle@rac1 ~]$ **srvctl status listener**_

 _Listener LISTENER is enabled_

 _Listener LISTENER is running on node(s): rac1,rac2_

 ** _TNS_** **_监听器_** **_—_** ** _（配置）_**

 _[oracle@rac1 ~]$ **srvctl config listener -a**_

 _Name: LISTENER_

 _Network: 1, Owner: grid_

 _Home:_

 _& nbsp; /u01/app/11.2.0/grid on node(s) rac2,rac1_

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

 _& nbsp;_

 _[oracle@rac1 ~]$ **srvctl status vip -n rac2**_

 _VIP rac2-vip is enabled_

 _VIP rac2-vip is running on node: rac2_

 ** _VIP —_** ** _（特定节点的配置）_**

 _[oracle@rac1 ~]$ **srvctl config vip -n rac1**_

 _VIP exists.:rac1_

 _VIP exists.: /rac1-vip/192.168.1.251/255.255.255.0/eth0_

 _& nbsp;_

 _[oracle@rac1 ~]$ **srvctl config vip -n rac2**_

 _VIP exists.:rac2_

 _VIP exists.: /rac2-vip/192.168.1.252/255.255.255.0/eth0_

 ** _节点应用程序配置_** **_—_** ** _（_** ** _VIP_** ** _、_** ** _GSD_** ** _、_** **
_ONS_** ** _、监听器）_**

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

 _& nbsp; /u01/app/11.2.0/grid on node(s) rac2,rac1_

 _End points: TCP:1521_

 _& nbsp;_

 _& nbsp;_

##  _16_ _、卸载软件_

###  _16.1_ _卸载_ _Oracle Grid Infrastructure_

 _Deconfiguring Oracle Clusterware Without Removing Binaries_

 _cd /u01/app/11.2.0/grid/crs/install_

    
    
    1、Run&nbsp;rootcrs.pl&nbsp;with&nbsp;the&nbsp;-deconfig&nbsp;-force&nbsp;flags.&nbsp;For&nbsp;example
    
    
    #&nbsp;perl&nbsp;rootcrs.pl&nbsp;-deconfig&nbsp;–force
    
    
    Repeat&nbsp;on&nbsp;other&nbsp;nodes&nbsp;as&nbsp;required
    
    
    2、If&nbsp;you&nbsp;are&nbsp;deconfiguring&nbsp;Oracle&nbsp;Clusterware&nbsp;on&nbsp;all&nbsp;nodes&nbsp;in&nbsp;the&nbsp;cluster,&nbsp;then&nbsp;on&nbsp;the&nbsp;last&nbsp;node,&nbsp;enter&nbsp;the&nbsp;following&nbsp;command:

  

 _# perl rootcrs.pl -deconfig -force –lastnode_

 _3_ _、_ _Removing Grid Infrastructure_

 _The default method for running the deinstall tool is from the deinstall
directory in the grid home. For example:_

    
    
    $&nbsp;cd&nbsp;/u01/app/11.2.0/grid/deinstall
    
    
    $&nbsp;./deinstall

  

 _& nbsp;_

 _& nbsp;_

###  _16.2_ _卸载_ _Oracle Real Application Clusters Software_

 _Overview of Deinstallation Procedures_

 _To completely remove all Oracle databases, instances, and software from an
Oracle home directory:_

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; _Identify all instances
associated with the Oracle home_

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; _Shut down processes_

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; _Remove listeners installed
in the Oracle Database home_

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; _Remove database instances_

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; _Remove Automatic Storage
Management (11.1 or earlier)_

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; _Remove Oracle Clusterware
and Oracle Automatic Storage Management (Oracle grid infrastructure)_

 _Deinstalling Oracle RAC Software_

    
    
    $&nbsp;cd&nbsp;$ORACLE_HOME/deinstall
    
    
    $&nbsp;./deinstall

  

 _& nbsp;_

 _& nbsp;_

 _Reserve.conf_

 _Crs-4402_

 _& nbsp;_

 _& nbsp;_

 _& nbsp;_

## 17、收尾工作

修改数据库默认参数：

alter system set deferred_segment_creation=FALSE;&nbsp;&nbsp;&nbsp;&nbsp;

alter system set
audit_trail&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
=none&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
scope=spfile;&nbsp;

alter system set
SGA_MAX_SIZE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
=xxxxxM&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; scope=spfile;

alter system set
SGA_TARGET&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
=xxxxxM&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; scope=spfile;&nbsp;

alter systemn set pga_aggregate_target&nbsp;&nbsp;
=XXXXXM&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; scope=spfile;

Alter PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;

alter database add SUPPLEMENTAL log data;

alter system set enable_ddl_logging=true;

#关闭11g密码延迟验证新特性

ALTER SYSTEM SET EVENT = &#39;28401 TRACE NAME CONTEXT FOREVER, LEVEL 1&#39;
SCOPE = SPFILE;

#限制trace日志文件大最大25M

alter system set max_dump_file_size&nbsp;=&#39;25m&#39; ;

#关闭密码大小写限制

ALTER&nbsp;SYSTEM&nbsp;SET&nbsp;SEC_CASE_SENSITIVE_LOGON&nbsp;=&nbsp;FALSE;  
alter&nbsp;system&nbsp;set&nbsp;db_files=2000&nbsp;scope=spfile;

#RAC修改local_listener：（现象：使用PlSql Developer第一次连接超时，第二次之后连接正常）

alter system set local_listener = &#39;(ADDRESS = (PROTOCOL = TCP)(HOST =
192.168.0.125)(PORT = 1521))&#39; sid=&#39;orcl1&#39;;

alter system set local_listener = &#39;(ADDRESS = (PROTOCOL = TCP)(HOST =
192.168.0.130)(PORT = 1521))&#39; sid=&#39;orcl2&#39;;

HOST = 192.168.1.216 --此处使用数字形式的VIP，绝对禁止使用rac1-vip

HOST = 192.168.1.219 --此处使用数字形式的VIP，绝对禁止使用rac2-vip

#更改控制文件记录保留时间

alter system set control_file_record_keep_time =31;

 **Redhat** **内核的系统** 中关闭透明大页内存 ：

vi /etc/rc.local 添加如下内容

if test -f /sys/kernel/mm/redhat_transparent_hugepage/enabled; then

echo never &gt; /sys/kernel/mm/redhat_transparent_hugepage/enabled

fi

if test -f /sys/kernel/mm/redhat_transparent_hugepage/defrag; then

echo never &gt; /sys/kernel/mm/redhat_transparent_hugepage/defrag

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

# NOTICE:&nbsp; You have a /boot partition.&nbsp; This means that

#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; all kernel and initrd
paths are relative to /boot/, eg.

#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; root (hd0,0)

#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; kernel /vmlinuz-
version ro root=/dev/sda3

#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; initrd
/initrd-[generic-]version.img

#boot=/dev/sda

default=0

timeout=5

splashimage=(hd0,0)/grub/splash.xpm.gz

hiddenmenu

title Red Hat Enterprise Linux 6 (2.6.32-642.el6.x86_64)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; root (hd0,0)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; kernel
/vmlinuz-2.6.32-642.el6.x86_64 ro
root=UUID=36e1c41b-9a78-4d3d-888e-6558ee9266a4 rd_NO_LUKS rd_NO_LVM.UTF-8
rd_NO_MD SYSFONT=latarcyrheb-sun16 crashkernel=128M&nbsp; KEYBOARDTYPE=pc
KEYTABLE=us rd_NO_DM rhgb quiet transparent_hugepage=never

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; initrd
/initramfs-2.6.32-642.el6.x86_64.img

&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

方法3：参考redhat文档https://access.redhat.com/solutions/422283

如若以上两种方法均无效，则使用如下方法：

首先检查tuned包是否安装：

[root@rac1 ~]# rpm -qa |grep tuned

如若未安装，使用如下方法安装：

&nbsp;

[root@rac1 Packages]# yum install tuned

Loaded plugins: product-id, refresh-packagekit, search-disabled-repos,
security, subscription-manager

This system is not registered to Red Hat Subscription Management. You can use
subscription-manager to register.

Setting up Install Process

Server&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
| 4.1 kB&nbsp;&nbsp;&nbsp;&nbsp; 00:00 ...

Resolving Dependencies

\--&gt; Running transaction check

\---&gt; Package tuned.noarch 0:0.2.19-16.el6 will be installed

\--&gt; Finished Dependency Resolution

&nbsp;

Dependencies Resolved

&nbsp;

========================================================================================================================================================================

&nbsp;Package&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Arch&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Version&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Repository&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Size

========================================================================================================================================================================

Installing:

&nbsp;tuned&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
noarch&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
0.2.19-16.el6&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Server&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
95 k

&nbsp;

Transaction Summary

========================================================================================================================================================================

Install&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1 Package(s)

&nbsp;

Total download size: 95 k

Installed size: 219 k

Is this ok [y/N]: y

Downloading Packages:

Running rpm_check_debug

Running Transaction Test

Transaction Test Succeeded

Running Transaction

Warning: RPMDB altered outside of yum.

&nbsp; Installing :
tuned-0.2.19-16.el6.noarch&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1/1

&nbsp; Verifying&nbsp; :
tuned-0.2.19-16.el6.noarch&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1/1

&nbsp;

Installed:

&nbsp; tuned.noarch
0:0.2.19-16.el6&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

&nbsp;

Complete!

[root@rac1 Packages]# tuned-adm&nbsp; active

Current active profile: default

Service tuned: disabled, stopped

Service ktune: disabled, stopped

&nbsp;

[root@rac1 Packages]# cd /etc/tune-profiles/

[root@rac1 tune-profiles]# cp -r throughput-performance throughput-
performance-no-thp

[root@rac1 tune-profiles]# sed -ie &#39;s,set_transparent_hugepages
always,set_transparent_hugepages never,&#39; \

&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /etc/tune-profiles/throughput-
performance-no-thp/ktune.sh

[root@rac1 tune-profiles]# grep set_transparent_hugepages /etc/tune-
profiles/throughput-performance-no-thp/ktune.sh

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; set_transparent_hugepages never

&nbsp;

[root@rac1 tune-profiles]# tuned-adm profile throughput-performance-no-thp

Switching to profile &#39;throughput-performance-no-thp&#39;

Applying deadline elevator: dm-0 dm-1 dm-2 dm-3 dm-4 dm-5 dm-6 sda sdb sdc sdd
sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo [&nbsp; OK&nbsp; ]

Applying ktune sysctl settings:

/etc/ktune.d/tunedadm.conf: [&nbsp; OK&nbsp; ]

Calling &#39;/etc/ktune.d/tunedadm.sh start&#39;: [&nbsp; OK&nbsp; ]

Applying sysctl settings from /etc/sysctl.conf

Starting tuned: [&nbsp; OK&nbsp; ]

&nbsp;

[root@rac1 tune-profiles]# cat
/sys/kernel/mm/redhat_transparent_hugepage/enabled

always madvise [never]

&nbsp;

如上修改后，仍然需要在/etc/grub.conf的kernel行中添加transparent_hugepage=never，如下

[root@rac1 tune-profiles]# cat /etc/grub.conf

# grub.conf generated by anaconda

#

# Note that you do not have to rerun grub after making changes to this file

# NOTICE:&nbsp; You have a /boot partition.&nbsp; This means that

#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; all kernel and initrd
paths are relative to /boot/, eg.

#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; root (hd0,0)

#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; kernel /vmlinuz-
version ro root=/dev/sda3

#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; initrd
/initrd-[generic-]version.img

#boot=/dev/sda

default=0

timeout=5

splashimage=(hd0,0)/grub/splash.xpm.gz

hiddenmenu

title Red Hat Enterprise Linux 6 (2.6.32-642.el6.x86_64)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; root (hd0,0)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; kernel
/vmlinuz-2.6.32-642.el6.x86_64 ro
root=UUID=36e1c41b-9a78-4d3d-888e-6558ee9266a4 rd_NO_LUKS rd_NO_LVM.UTF-8
rd_NO_MD SYSFONT=latarcyrheb-sun16 crashkernel=128M&nbsp; KEYBOARDTYPE=pc
KEYTABLE=us rd_NO_DM rhgb quiet transparent_hugepage=never

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; initrd
/initramfs-2.6.32-642.el6.x86_64.img

&nbsp;  

  

修改rman 控制文件快照路径###

ORA-245: In RAC environment from 11.2 onwards Backup Or Snapshot controlfile
needs to be in shared location (文档 ID 1472171.1)

一个节点上执行即可

rman target /

show all;

CONFIGURE SNAPSHOT CONTROLFILE NAME TO &#39;+DATA/snapcf_ls.f&#39;;

show all;

修改ASM的链路中断等待时间，避免多路径切换时间超过15s而导致磁盘组被强制umount：

su - grid

sqlplus / as sysdba

alter&nbsp;system&nbsp;set&nbsp;&quot;_asm_hbeatiowait&quot;=120&nbsp;scope=spfile&nbsp;sid=&#39;*&#39;;

另外参考文章修改asm的内存参数：

 **ASM Instances Are Reporting ORA-04031 Errors. (** **文档** **ID 1370925.1)**

 **RAC** **和** **Oracle Clusterware** **最佳实践和初学者指南（平台无关部分）** **(** **文档** **ID
1526083.1)**

su - grid

sqlplus / as sysdba

SQL&gt; alter system set memory_max_target=4096m scope=spfile;  
alter system set memory_target=1536m scope=spfile;

&nbsp;

如果内存大约等于64G开启大页内存，参考 大页内存指导书

&nbsp;

安装PSU，根据PSU相关介绍进行安装。

参考相关PSU文档

&nbsp;

部署OSW

默认30秒收集1次，总共保留2天的记录

设置开机自动启动osw监控

linux:

vi&nbsp; /etc/rc.local

cd /tmp/oswbb&amp;&amp;/tmp/oswbb/startOSWbb.sh

通过测试osw的日志默认策略 30秒*2天&nbsp;
大约需500M的磁盘空间，合理安排存放目录。如果需要自定义天数和扫描间隔,例如想每隔15秒收集一次,共保留7天168小时,添加参数即可.

cd /tmp/oswbb&amp;&amp;/tmp/oswbb/startOSWbb.sh 15 168

&nbsp;

注意：osw默认不监控rac的心跳网络

rac环境 部署osw 需要将其中的Exampleprivate.net文件改名private.net并修改其中内容

&nbsp;

删除非当前操作系统的 部分，只保留当前系统的，如操作系统是linux ，只需要保存

#Linux Example

########################################################

echo &quot;zzz ***&quot;`date`

traceroute -r -F &lt;node1-priv&gt;

traceroute -r -F &lt;node2-priv&gt;

########################################################

其中&lt;node1-priv&gt;&nbsp; 和&lt;node2-priv&gt; 修改成&nbsp; rac心跳ip的名称 如
rac1-priv 和rac2-priv

另外最后一行 rm locks/lock.file 必须保留

# DO NOT DELETE THE FOLLOWING LINE!!!!!!!!!!!!!!!!!!!!!

########################################################

rm locks/lock.file

osw生成的日志会保留在 oswbb下的 archive 目录中。

&nbsp;

部署ASM aud审计登录文件定时清理任务：

每台服务器都要部署。

su - grid

$ sqlplus &#39;/ as sysasm&#39;

SQL&gt; select value from v$parameter where name = &#39;audit_file_dest&#39;;

VALUE

\--------------------------------------------------------------------------------

/u01/app/11.2.0/grid/rdbms/audit

&nbsp;

grid用户执行：

crontab -e

添加内容

0 2 * * sun /usr/bin/find /u01/app/11.2.0/grid/rdbms/audit -maxdepth 1 -name
&#39;*.aud&#39; -mtime +30 -delete

参考文档：

 **  
Manage Audit File Directory Growth with cron (** **文档** **ID 1298957.1)  
A Lot of Audit Files in ASM Home (** **文档** **ID 813416.1)**

&nbsp;

## 18、部署rman备份脚本

参考rman 备份相关文档

&nbsp;

 **至此结束RAC部署，重启RAC所有服务器，启动后检查相关服务及内容是否正常，方可结束安装。**

##  19、安装群集和数据库失败如何快速重来，需要清理重来？

RAC 安装失败后的删除

如果已经运行了root.sh脚本则要清理掉crs磁盘组的相关共享磁盘，命令格式如下：

dd if=/dev/zero of=/dev/raw/raw1 bs=1k count=3000

&nbsp;删除grid和oracle的软件安装目录：

rm -rf /u02/*

rm -rf /u01/*

删除其他生成的配置文件：

rm &nbsp;-rf /home/oracle/oracle/*

rm &nbsp;-rf /etc/rc.d/rc5.d/S96init.crs

rm &nbsp;-rf /etc/rc.d/init.d/init.crs

rm &nbsp;-rf /etc/rc.d/rc4.d/K96init.crs

rm &nbsp;-rf /etc/rc.d/rc6.d/K96init.crs&nbsp;

rm &nbsp;-rf /etc/rc.d/rc1.d/K96init.crs

rm &nbsp;-rf /etc/rc.d/rc0.d/K96init.crs

rm &nbsp;-rf /etc/rc.d/rc2.d/K96init.crs

rm &nbsp;-rf /etc/rc.d/rc3.d/S96init.crs

rm &nbsp;-rf /etc/oracle/*

rm &nbsp;-rf /etc/oraInst.loc

rm &nbsp;-rf /etc/oratab

rm &nbsp;-rf /usr/local/bin/coraenv

rm &nbsp;-rf /usr/local/bin/dbhome

rm &nbsp;-rf /usr/local/bin/oraenv

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

&nbsp;

# 如何将已经实施完成的RAC的scan-ip由hosts文件解析修改为DNS解析

## 1、修改所有rac节点的/etc/resolv.conf文件，添加以下内容

domain highgo.com

nameserver 186.168.100.116

options rotate

options timeout:2

options attempts:5

## 2、修改所有rac节点的/etc/nsswitch.conf

将第38行修改为以下内容

hosts:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; dns files nis

## 3、删除/etc/hosts文件里scan-ip的解析

## 4、在所有节点（包括dns节点和rac节点）执行如下命令检查

如果可以正常返回结果，说明配置正确

 **[root@dns named]# nslookup scan-ip.highgo.com**

Server:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 186.168.100.116

Address:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 186.168.100.116#53

&nbsp;

Name:&nbsp;&nbsp; scan-ip.highgo.com

Address: 186.188.100.115

Name:&nbsp;&nbsp; scan-ip.highgo.com

Address: 186.188.100.117

Name:&nbsp;&nbsp; scan-ip.highgo.com

Address: 186.188.100.118

 **[root@dns named]# nslookup 186.168.100.115**

Server:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 186.168.100.116

Address:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 186.168.100.116#53

&nbsp;

115.100.168.186.in-addr.arpa&nbsp;&nbsp;&nbsp; name = scan-ip.highgo.com.

&nbsp;

 **[root@dns named]# nslookup 186.168.100.117**

Server:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 186.168.100.116

Address:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 186.168.100.116#53

&nbsp;

117.100.168.186.in-addr.arpa&nbsp;&nbsp;&nbsp; name = scan-ip.highgo.com.

&nbsp;

 **[root@dns named]# nslookup 186.168.100.118**

Server:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 186.168.100.116

Address:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 186.168.100.116#53

&nbsp;

118.100.168.186.in-addr.arpa&nbsp;&nbsp;&nbsp; name = scan-ip.highgo.com

## 5、查看当前scanip名称

&nbsp;

[grid@rac1 ~]$ srvctl config scan

SCAN name: scan-ip, Network: 1/186.168.100.0/255.255.255.0/eth0

SCAN VIP name: scan1, IP: /scan-ip/186.168.100.115

## 6、关闭scan、关闭scan_listener

[root@rac1 grid]# srvctl stop scan_listener

[root@rac1 grid]#&nbsp; srvctl stop scan

## 7、将scanip名称修改为DNS解析的域名

[root@rac1 grid]# srvctl modify scan -n scan-ip.highgo.com.

&nbsp;

## 8、打开scan，打开scan_listener 并查看当前scan-ip配置

[root@rac1 grid]# srvctl start scan

[root@rac1 grid]#&nbsp; srvctl start scan_listener

[root@rac1 grid]# srvctl config scan

SCAN name: scan-ip.highgo.com., Network: 1/186.168.100.0/255.255.255.0/eth0

SCAN VIP name: scan1, IP: /scan-ip.highgo.com./186.168.100.117

SCAN VIP name: scan2, IP: /scan-ip.highgo.com./186.168.100.118

SCAN VIP name: scan3, IP: /scan-ip.highgo.com./186.168.100.115

&nbsp;

# 客户端如何通过dns域名连接到数据库

1、在网卡配置中添加DNS，地址为DNS服务器的IP地址

!["57.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.010622345520361343.png)

2、Oracle 客户端 tnsnames配置相关的连接串，host后面写上DNS域名

TEST =

&nbsp; (DESCRIPTION =

&nbsp;&nbsp;&nbsp; (ADDRESS_LIST =

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (ADDRESS = (PROTOCOL = TCP)(HOST = **scan-
ip.highgo.com** )(PORT = 1521))

&nbsp;&nbsp;&nbsp; )

&nbsp;&nbsp;&nbsp; (CONNECT_DATA =

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (SERVICE_NAME = orcl)

&nbsp;&nbsp;&nbsp; )

&nbsp; )

3、客户端使用tnsping进行测试

!["58.png"](file:///C:/Users/galaxy/Documents/My%20Knowledge/temp/597e3e20-a7fd-4549-a534-63ec5c172eb6/128/index_files/0.026158811588165465.png)

  

" name="docDetail" type="hidden">


---
### ATTACHMENTS
[048d9dbc21b5ea16361597fbce1614c8]: media/6手册-使用DNS版本.html
[6手册-使用DNS版本.html](media/6手册-使用DNS版本.html)
>hash: 048d9dbc21b5ea16361597fbce1614c8  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124143958_83.png  

[0941d40e1bcec58610401ea33eb28caf]: media/6手册-使用DNS版本-2.html
[6手册-使用DNS版本-2.html](media/6手册-使用DNS版本-2.html)
>hash: 0941d40e1bcec58610401ea33eb28caf  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144248_940.png  

[11d84121014589c53d12d4cceea529f5]: media/6手册-使用DNS版本-3.html
[6手册-使用DNS版本-3.html](media/6手册-使用DNS版本-3.html)
>hash: 11d84121014589c53d12d4cceea529f5  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144839_590.png  

[1951f92f3cf962c48b1b4337b0996c94]: media/6手册-使用DNS版本-4.html
[6手册-使用DNS版本-4.html](media/6手册-使用DNS版本-4.html)
>hash: 1951f92f3cf962c48b1b4337b0996c94  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144340_460.png  

[1d1cd7d6db547e6b5b119f3ce1f51677]: media/6手册-使用DNS版本-5.html
[6手册-使用DNS版本-5.html](media/6手册-使用DNS版本-5.html)
>hash: 1d1cd7d6db547e6b5b119f3ce1f51677  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144815_76.png  

[1d27f57a0472aea5c20e4e428dd9ea21]: media/6手册-使用DNS版本-6.html
[6手册-使用DNS版本-6.html](media/6手册-使用DNS版本-6.html)
>hash: 1d27f57a0472aea5c20e4e428dd9ea21  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144629_730.png  

[215feafd65536365048b3ab7ae68171e]: media/6手册-使用DNS版本-7.html
[6手册-使用DNS版本-7.html](media/6手册-使用DNS版本-7.html)
>hash: 215feafd65536365048b3ab7ae68171e  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144728_295.png  

[22356291fef9fe9e3cba16c97b1b042c]: media/6手册-使用DNS版本-8.html
[6手册-使用DNS版本-8.html](media/6手册-使用DNS版本-8.html)
>hash: 22356291fef9fe9e3cba16c97b1b042c  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144616_998.png  

[25693b53c6dd7efc9f90104956dcd3df]: media/6手册-使用DNS版本-9.html
[6手册-使用DNS版本-9.html](media/6手册-使用DNS版本-9.html)
>hash: 25693b53c6dd7efc9f90104956dcd3df  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144554_311.png  

[28891a335465eec5d8f39090dc14e36e]: media/6手册-使用DNS版本-10.html
[6手册-使用DNS版本-10.html](media/6手册-使用DNS版本-10.html)
>hash: 28891a335465eec5d8f39090dc14e36e  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144213_568.png  

[37062aea6fd1501e4ec2725ef261a3c1]: media/6手册-使用DNS版本-11.html
[6手册-使用DNS版本-11.html](media/6手册-使用DNS版本-11.html)
>hash: 37062aea6fd1501e4ec2725ef261a3c1  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144711_375.png  

[3a36ae985feac43a5183250777c2c3a3]: media/6手册-使用DNS版本-12.html
[6手册-使用DNS版本-12.html](media/6手册-使用DNS版本-12.html)
>hash: 3a36ae985feac43a5183250777c2c3a3  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144716_778.png  

[3c53d6a4a43d1de9eb5e25221a4e642f]: media/6手册-使用DNS版本-13.html
[6手册-使用DNS版本-13.html](media/6手册-使用DNS版本-13.html)
>hash: 3c53d6a4a43d1de9eb5e25221a4e642f  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124143806_720.png  

[4b0a796c8ee3f6b555f7fce108a66c81]: media/6手册-使用DNS版本-14.html
[6手册-使用DNS版本-14.html](media/6手册-使用DNS版本-14.html)
>hash: 4b0a796c8ee3f6b555f7fce108a66c81  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144541_331.png  

[57a518321f1aa3d33083555ca2e2097d]: media/6手册-使用DNS版本-15.html
[6手册-使用DNS版本-15.html](media/6手册-使用DNS版本-15.html)
>hash: 57a518321f1aa3d33083555ca2e2097d  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124145003_230.png  

[580e2bcd3b4f0e45b659a140f382b93a]: media/6手册-使用DNS版本-16.html
[6手册-使用DNS版本-16.html](media/6手册-使用DNS版本-16.html)
>hash: 580e2bcd3b4f0e45b659a140f382b93a  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144207_750.png  

[594ed5d7f971589f47e174fc0d967f8e]: media/6手册-使用DNS版本-17.html
[6手册-使用DNS版本-17.html](media/6手册-使用DNS版本-17.html)
>hash: 594ed5d7f971589f47e174fc0d967f8e  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144745_140.png  

[59749488ecc428002ac10ab1d4072f76]: media/6手册-使用DNS版本-18.html
[6手册-使用DNS版本-18.html](media/6手册-使用DNS版本-18.html)
>hash: 59749488ecc428002ac10ab1d4072f76  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144832_511.png  

[5b40c4a76a04f2c8ff8e0fde7b17613a]: media/6手册-使用DNS版本-19.html
[6手册-使用DNS版本-19.html](media/6手册-使用DNS版本-19.html)
>hash: 5b40c4a76a04f2c8ff8e0fde7b17613a  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124145009_525.png  

[5c8574a6ceb99de546f4370e27b15ed2]: media/6手册-使用DNS版本-20.html
[6手册-使用DNS版本-20.html](media/6手册-使用DNS版本-20.html)
>hash: 5c8574a6ceb99de546f4370e27b15ed2  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124143928_771.png  

[5d4cd36e3c765e9168dbc2967d3b29a5]: media/6手册-使用DNS版本-21.html
[6手册-使用DNS版本-21.html](media/6手册-使用DNS版本-21.html)
>hash: 5d4cd36e3c765e9168dbc2967d3b29a5  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144957_600.png  

[62be29adb90e5038343037397e991e13]: media/6手册-使用DNS版本-22.html
[6手册-使用DNS版本-22.html](media/6手册-使用DNS版本-22.html)
>hash: 62be29adb90e5038343037397e991e13  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124145039_724.png  

[63040b79080ecf91fed0db50959eb5d2]: media/6手册-使用DNS版本-23.html
[6手册-使用DNS版本-23.html](media/6手册-使用DNS版本-23.html)
>hash: 63040b79080ecf91fed0db50959eb5d2  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144952_668.png  

[6d1afda2741d4ccce7741ce9449fdd71]: media/6手册-使用DNS版本-24.html
[6手册-使用DNS版本-24.html](media/6手册-使用DNS版本-24.html)
>hash: 6d1afda2741d4ccce7741ce9449fdd71  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144327_938.png  

[7268853afb0c73f72114aa88731e106d]: media/6手册-使用DNS版本-25.html
[6手册-使用DNS版本-25.html](media/6手册-使用DNS版本-25.html)
>hash: 7268853afb0c73f72114aa88731e106d  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144402_814.png  

[799fd84c0223ad24ad1928200aedb9d9]: media/6手册-使用DNS版本-26.html
[6手册-使用DNS版本-26.html](media/6手册-使用DNS版本-26.html)
>hash: 799fd84c0223ad24ad1928200aedb9d9  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144810_966.png  

[7a831c2f7640cf44168362a762af5cf3]: media/6手册-使用DNS版本-27.html
[6手册-使用DNS版本-27.html](media/6手册-使用DNS版本-27.html)
>hash: 7a831c2f7640cf44168362a762af5cf3  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144159_120.png  

[854ad22a5c75c534586de4e3317f1dab]: media/6手册-使用DNS版本-28.html
[6手册-使用DNS版本-28.html](media/6手册-使用DNS版本-28.html)
>hash: 854ad22a5c75c534586de4e3317f1dab  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144608_279.png  

[8a28f177d99012d42926ac3028606ab8]: media/6手册-使用DNS版本-29.html
[6手册-使用DNS版本-29.html](media/6手册-使用DNS版本-29.html)
>hash: 8a28f177d99012d42926ac3028606ab8  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144601_619.png  

[925a0b8294e36568785aff1171044ffe]: media/6手册-使用DNS版本-30.html
[6手册-使用DNS版本-30.html](media/6手册-使用DNS版本-30.html)
>hash: 925a0b8294e36568785aff1171044ffe  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144220_972.png  

[965d87c7f41f57cdcf1bf7de19021ad6]: media/6手册-使用DNS版本-31.html
[6手册-使用DNS版本-31.html](media/6手册-使用DNS版本-31.html)
>hash: 965d87c7f41f57cdcf1bf7de19021ad6  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144243_108.png  

[9b241ce9fb6482ee04d4a0fd6b44f000]: media/6手册-使用DNS版本-32.html
[6手册-使用DNS版本-32.html](media/6手册-使用DNS版本-32.html)
>hash: 9b241ce9fb6482ee04d4a0fd6b44f000  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144622_874.png  

[9b24e34bab9b46d80af8bbad357738b2]: media/6手册-使用DNS版本-33.html
[6手册-使用DNS版本-33.html](media/6手册-使用DNS版本-33.html)
>hash: 9b24e34bab9b46d80af8bbad357738b2  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124143751_599.png  

[9c75745de4fd666923b35c11c695ab7c]: media/6手册-使用DNS版本-34.html
[6手册-使用DNS版本-34.html](media/6手册-使用DNS版本-34.html)
>hash: 9c75745de4fd666923b35c11c695ab7c  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144534_530.png  

[9f699984331d9f7de2666880bfb33eb6]: media/6手册-使用DNS版本-35.html
[6手册-使用DNS版本-35.html](media/6手册-使用DNS版本-35.html)
>hash: 9f699984331d9f7de2666880bfb33eb6  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144738_186.png  

[a5d870f331bafe278ff68a90f8770085]: media/6手册-使用DNS版本-36.html
[6手册-使用DNS版本-36.html](media/6手册-使用DNS版本-36.html)
>hash: a5d870f331bafe278ff68a90f8770085  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144919_706.png  

[aad9d51242f28fb6bf0267232d196fe9]: media/6手册-使用DNS版本-37.html
[6手册-使用DNS版本-37.html](media/6手册-使用DNS版本-37.html)
>hash: aad9d51242f28fb6bf0267232d196fe9  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144548_619.png  

[ac39e7ad518d9a7af238e90d06bcb00e]: media/6手册-使用DNS版本-38.html
[6手册-使用DNS版本-38.html](media/6手册-使用DNS版本-38.html)
>hash: ac39e7ad518d9a7af238e90d06bcb00e  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144803_403.png  

[ac6da0d42ff479de2a4e15a15dd7dd67]: media/6手册-使用DNS版本-39.html
[6手册-使用DNS版本-39.html](media/6手册-使用DNS版本-39.html)
>hash: ac6da0d42ff479de2a4e15a15dd7dd67  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144722_253.png  

[aed8dd48d4b395897109d6f62500e664]: media/6手册-使用DNS版本-40.html
[6手册-使用DNS版本-40.html](media/6手册-使用DNS版本-40.html)
>hash: aed8dd48d4b395897109d6f62500e664  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144733_37.png  

[b1134d4505b6385afdc96d9aca37168c]: media/6手册-使用DNS版本-41.html
[6手册-使用DNS版本-41.html](media/6手册-使用DNS版本-41.html)
>hash: b1134d4505b6385afdc96d9aca37168c  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144410_226.png  

[b1dd40ca6756ab53dc5bffbf348baa6f]: media/6手册-使用DNS版本-42.html
[6手册-使用DNS版本-42.html](media/6手册-使用DNS版本-42.html)
>hash: b1dd40ca6756ab53dc5bffbf348baa6f  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124143744_261.png  

[b391f63198892626fe407c03043fb5f5]: media/6手册-使用DNS版本-43.html
[6手册-使用DNS版本-43.html](media/6手册-使用DNS版本-43.html)
>hash: b391f63198892626fe407c03043fb5f5  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124143821_75.png  

[b4cf665f75d07ba54ea5cce6fda4aafd]: media/6手册-使用DNS版本-44.html
[6手册-使用DNS版本-44.html](media/6手册-使用DNS版本-44.html)
>hash: b4cf665f75d07ba54ea5cce6fda4aafd  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144046_918.png  

[c26dd33029c3ad9b8b9e82d95bc029f2]: media/6手册-使用DNS版本-45.html
[6手册-使用DNS版本-45.html](media/6手册-使用DNS版本-45.html)
>hash: c26dd33029c3ad9b8b9e82d95bc029f2  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144030_775.png  

[c668c401a76be67566406e37ce515d6c]: media/6手册-使用DNS版本-46.html
[6手册-使用DNS版本-46.html](media/6手册-使用DNS版本-46.html)
>hash: c668c401a76be67566406e37ce515d6c  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144303_919.png  

[c8d01a72bb80c5639e10bf2e764cbd07]: media/6手册-使用DNS版本-47.html
[6手册-使用DNS版本-47.html](media/6手册-使用DNS版本-47.html)
>hash: c8d01a72bb80c5639e10bf2e764cbd07  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144418_582.png  

[d67440b5918f8568c4729092945ac019]: media/6手册-使用DNS版本-48.html
[6手册-使用DNS版本-48.html](media/6手册-使用DNS版本-48.html)
>hash: d67440b5918f8568c4729092945ac019  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124143934_47.png  

[dc194f9efc553fc8a4bd6ce986940142]: media/6手册-使用DNS版本-49.html
[6手册-使用DNS版本-49.html](media/6手册-使用DNS版本-49.html)
>hash: dc194f9efc553fc8a4bd6ce986940142  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144052_401.png  

[de86f21c27fc86d5f2a31bd467a3255d]: media/6手册-使用DNS版本-50.html
[6手册-使用DNS版本-50.html](media/6手册-使用DNS版本-50.html)
>hash: de86f21c27fc86d5f2a31bd467a3255d  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144150_839.png  

[e44a7029b80405829625776f3754974e]: media/6手册-使用DNS版本-51.html
[6手册-使用DNS版本-51.html](media/6手册-使用DNS版本-51.html)
>hash: e44a7029b80405829625776f3754974e  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124143758_496.png  

[e46116e346645d68fecbb56ee3f3f43f]: media/6手册-使用DNS版本-52.html
[6手册-使用DNS版本-52.html](media/6手册-使用DNS版本-52.html)
>hash: e46116e346645d68fecbb56ee3f3f43f  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144443_297.png  

[ea149d44ca13a07b25ba80c4be91862c]: media/6手册-使用DNS版本-53.html
[6手册-使用DNS版本-53.html](media/6手册-使用DNS版本-53.html)
>hash: ea149d44ca13a07b25ba80c4be91862c  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144116_397.png  

[ea8489ec9a5ba6ffba12db3ebb00c6db]: media/6手册-使用DNS版本-54.html
[6手册-使用DNS版本-54.html](media/6手册-使用DNS版本-54.html)
>hash: ea8489ec9a5ba6ffba12db3ebb00c6db  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144910_178.png  

[f03d0600c2cc0f9b2d0621b76436a513]: media/6手册-使用DNS版本-55.html
[6手册-使用DNS版本-55.html](media/6手册-使用DNS版本-55.html)
>hash: f03d0600c2cc0f9b2d0621b76436a513  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124145029_496.png  

[f4224fdf2a9c0a72c374a026e71229a3]: media/6手册-使用DNS版本-56.html
[6手册-使用DNS版本-56.html](media/6手册-使用DNS版本-56.html)
>hash: f4224fdf2a9c0a72c374a026e71229a3  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144638_89.png  

[fb1995c9b1acc8bf6db642b2d44fcc43]: media/6手册-使用DNS版本-57.html
[6手册-使用DNS版本-57.html](media/6手册-使用DNS版本-57.html)
>hash: fb1995c9b1acc8bf6db642b2d44fcc43  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144424_622.png  

[fef23ec78a708f1281748f4807c911e1]: media/6手册-使用DNS版本-58.html
[6手册-使用DNS版本-58.html](media/6手册-使用DNS版本-58.html)
>hash: fef23ec78a708f1281748f4807c911e1  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本_files\20180124144017_377.png  

---
### NOTE ATTRIBUTES
>Created Date: 2018-09-25 03:29:19  
>Last Evernote Update Date: 2018-10-01 15:33:51  
>author: YangKwong  
>source: desktop.win  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-oracle11gR2-RACforLinux5  
>source-url: &  
>source-url: 6手册-使用DNS版本.html  
>source-application: evernote.win32  