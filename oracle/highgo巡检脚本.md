#           HighGo巡检脚本
[TOC]
## 1.1 Oracle实例运行时间
```plsql
col running format a30
select to_char(startup_time, 'DD-MON-YYYY HH24:MI:SS') starttime,
TRUNC(sysdate - (startup_time)) || 'days' ||
TRUNC(24 *
((sysdate - startup_time) - TRUNC(sysdate - startup_time))) ||
'hours' || MOD(TRUNC(1440 * ((SYSDATE - startup_time) -
TRUNC(sysdate - startup_time))),
60) || 'min' ||
MOD(TRUNC(86400 *
((SYSDATE - STARTUP_TIME) - TRUNC(SYSDATE - startup_time))),
60) || 's' running
from v$instance;
```
## 1.2  查看cursors
**查询session_cached_cursors和 open_cursors 的使用率(每个实例)**

```plsql
select 'session_cached_cursors' parameter,
lpad(value, 5) value,
decode(value, 0, ' n/a', to_char(100 * used / value, '990') || '%') usage
from (select max(s.value) used
from v$statname n, v$sesstat s
where n.name = 'session cursor cache count'
and s.statistic# = n.statistic#),
(select value from v$parameter where name = 'session_cached_cursors')
union all
select 'open_cursors',
lpad(value, 5),
to_char(100 * used / value, '990') || '%'
from (select max(sum(s.value)) used
from v$statname n, v$sesstat s
where n.name in ('opened cursors current')
and s.statistic# = n.statistic#
group by s.sid),
(select value from v$parameter where name = 'open_cursors');
```
## 2.1 操作系统版本/架构
### 2.1.1 查看定时任务
**Linux**
crontab -l
crontab -u oracle  -l
crontab -u grid -l
**HP-UX、Solaris、AIX**
crontab -l
crontab -l grid
crontab -l oracle

### 2.1.2 查看系统负载
uptime
w
who
whoami

### 2.1.3 查看OS内核信息
**AIX**
oslevel -r
oslevel -s
bootinfo
**Linux/Solaries/HP-UX**
uname -a
uname -r
uname -m
uname -sr                          <!--HP-UX操作系统及版本-->
cat /etc/redhat-release
cat /etc/issue
lsb_release
lsb_release -a
**Windows**
winver>win.txt   或者 我的电脑—属性截图

### 2.1.4 查看IP地址信息
**Windows**
hostname>host.txt
ipconfig>ip.txt
netstat -in
**Linux/AIX**
cat /etc/hosts
ifconfig -a
ip addr    <!--linux-->
**HP-UX网卡配置**
ioscan -fnC lan
lanscan
vi /etc/rc.config.d/netconf
cat /etc/inetd.conf          <!--已经打开的网络协议-->
netstat -in
/opt/ignite/bin/print_manifest

## 2.2 系统内存检查
### 2.2.1 查看内存
**Windows**
systeminfo>info.txt   或者   “任务管理器—性能”截图 Windows检查虚拟内存设置
**Linux**
cat /proc/meminfo
grep MemTotal /proc/meminfo
grep SwapTotal /proc/meminfo
free
free -g
free -h                 <!--Redhat6.X以后支持-->
**AIX**
lsattr -El sys0 -a realmem
**查看交换分区使用**
lsps -a
svmon -G

prtconf
lscfg -v
nmon
topas

[^注]: 如果不带任何标志运行 prtconf 命令，会显示系统型号、机器序列号、处理器类型、处理器数目、处理器时钟速度、cpu 类型、总内存大小、网络信息、文件系统信息、调页空间信息和设备信息。nmon 然后敲m   巡检报告中务必体现该命令输出信息，可选择截图方式保存
**Solaris**
/usr/sbin/prtconf |grep "Memory size"
swap -s
**HP-UX**
/usr/contrib/bin/machinfo | grep -i memory
dmesg|grep Physical
swapinfo -atm

### 2.2.2 查看硬件信息
**Linux**
dmidecode
smartctl --all /dev/sda
**HP-UX 查看系统信息**
machinfo
**HP-UX 查看系统配置**
cstm
/opt/ignite/bin/print_manifest
glance
**HP-UX 查看主机型号**
model
**HP-UX硬件状态**
ioscan -fn
**HP-UX CELL状态**
parstatus
因该命令组件需要单独收费安装，部分客户系统下无此命令，可选择性搜集（该命令类似AIX下的nmon）

## 2.3 操作系统补丁检查
#### AIX
**11.2 AIX6.1 RAC**
lslpp -l bos.adt.base bos.adt.lib bos.adt.libm bos.perf.libperfstat bos.perf.perfstat bos.perf.proctools xlC.aix61.rte xlC.rte rsct.basic.rte rsct.compat.clients.rte gpfs.base
**AIX6.1 单机**
lslpp -l bos.adt.base bos.adt.lib bos.adt.libm bos.perf.libperfstat bos.perf.perfstat bos.perf.proctools xlC.aix61.rte xlC.rte

#### Linux
**11.2 OL7 or RHEL7 (x86-64)**
rpm -q compat-libstdc++-33 binutils compat-libcap1 gcc gcc-c++ glibc glibc-devel ksh libaio libaio-devel libgcc libstdc++ libstdc++-devel libXi libXtst make sysstat cpp glibc-headers mpfr

[^注 ]: i386和x86_64都要有的包：glibc glibc-devel libaio libaio-devel libgcc libstdc++ libstdc++-devel libXi libXtst
[^参考文章]: Requirements for Installing Oracle 11.2.0.4 RDBMS on OL7 or RHEL7 64-bit (x86-64) (文档 ID 1962100.1)
**11.2 OL6 or RHEL6 (x86-64)**
rpm -q binutils compat-libcap1 compat-libstdc++-33 gcc gcc-c++ glibc glibc glibc-devel glibc-devel ksh libgcc libstdc++ libstdc++-devel libaio libaio-devel make sysstat cpp glibc-headers mpfr

[^参考文章]: Requirements for Installing Oracle 11gR2 RDBMS on RHEL6 or OL6 64-bit (x86-64) (文档 ID 1441282.1)
**11.2 OL5 or RHEL5 (x86-64)**
rpm -q --queryformat "%{NAME}-%{VERSION}-%{RELEASE} (%{ARCH})\n" binutils compat-libstdc++-33 gcc gcc-c++ elfutils-libelf elfutils-libelf-devel elfutils-libelf-devel-static glibc glibc-common glibc-devel glibc-headers ksh libaio libaio-devel libgcc libstdc++ libstdc++-devel make sysstat unixODBC unixODBC-devel

[^注 ]: i386和x86_64都要有的包：compat-libstdc++-33 glibc libaio libgcc libstdc++ glibc-devel libaio-devel unixODBC unixODBC-devel
**11.1 OL5 or RHEL5 (x86-64)**
rpm -q --queryformat "%{NAME}-%{VERSION}-%{RELEASE} (%{ARCH})\n" binutils compat-libstdc++-33 elfutils-libelf elfutils-libelf-devel gcc gcc-c++ glibc glibc-common glibc-devel libaio libaio-devel libgcc libstdc++ libstdc++-devel make sysstat

[^注]: i386和x86_64都要有的包：compat-libstdc++-33 glibc glibc-devel libaio libgcc libstdc++
**10.2 RHEL5**
rpm -q --queryformat "%{NAME}-%{VERSION}-%{RELEASE} (%{ARCH})\n" compat-libstdc++-33 gcc-c++ libstdc++-devel glibc-headers glibc-devel glibc-devel libgomp gcc libXp sysstat util-linux

[^注]: i386和x86_64都要有的包：compat-libstdc++ glibc-devel   只有i386的包：libXp
#### HP-UX查看补丁是否安装命令
swlist –l <补丁名>
swlist –l PHSS_39824
**HP-UX查看系统中安装的所有补丁**
/usr/sbin/swlist -l patch | more
swlist –l fileset –a state
swlist -l bundle
swlist -l product
swlist -l product | grep PH
swlist -l fileset -a state -a patch_state

### 2.4 操作系统参数设置检查
#### AIX
**AIX检查用户shell资源限制**
cat /etc/security/limits
ulimit -a
**AIX Maxuproc参数设置**
lsattr -EH -l sys0 -a maxuproc
**AIX检查AIX系统aio设置**
ioo -F -a | grep -i aio
**AIX检查虚拟内存参数**
vmo -a -F

#### Linux
**Linux内核参数检查**
cat /etc/sysctl.conf
cat /etc/security/limits.conf
sysctl -a
ulimit -a

#### Solaris
cat /etc/system
#### HP-UX查看参数设置
cat /stand/system
sysdef
/usr/sbin/kcweb -F
ulimit -a
**HP-UX共享内存参数**
kctune| grep shm
**HP-UX显示每个module及描述**
kcmodule -d
**HP-UX显示每个内核参数及描述**
kctune -d
**HP-UX查看HP-UX的filecache使用率**
kcusage -ht filecache_max
**HP-UX修改filecache_max**
kctune filecache_min=5% filecache_max=10%
**HP-UX检查UDP和TCP内核参数**
/usr/bin/ndd /dev/tcp tcp_smallest_anon_port tcp_largest_anon_port
/usr/bin/ndd /dev/udp udp_smallest_anon_port udp_largest_anon_port
**HP-UX系统内核文件**
ls /stand

## 2.5 操作系统时区、时间检查
### AIX,HP-UX,Solaris
echo $TZ
date

### Linux

cat /etc/sysconfig/clock
date -R

## 2.6 操作系统日志信息
#### AIX
errpt -a
errpt
last

#### Linux：
cat /var/log/messages
dmesg
dmesg | grep -i SCSI
dmesg |grep fail
dmesg |grep error
last -n 100
lastlog
lastb
tail -1000  /var/log/secure
cat /var/log/boot.log

#### Solaris:
cat /var/adm/messages
####　HP-UX
/var/adm/syslog/syslog.log                   //系统常用信息，如配置、修改、启动、关闭等信息
/var/adm/syslog/mail.log                     //电子邮件信息
/var/adm/sulog                               //执行su的情况
/var/adm/btmp                                //所有注册失败信息
cmviewcl –v                                  //检查cluster状况
dmesg
dmesg | grep -i SCSI
dmesg |grep fail
dmesg |grep error
uptime
cat  /var/adm/syslog/syslog.log|grep panic
cat /var/adm/syslog/syslog.log |grep warning
cat /var/adm/syslog/syslog.log |grep err
lastb                                                                                   //查看失败登录
last
cat /var/adm/syslog/syslog.log|grep error
cat /var/adm/syslog/syslog.log|grep fail
cat /var/adm/syslog/OLDsyslog.log |grep error
cat /var/adm/syslog/OLDsyslog.log |grep fail
**系统日志**
/var/adm/syslog/syslog.log
**上一次系统日志**
/var/adm/syslog/OLDsyslog.log 
**系统启动日志目录**
/etc/rc.log
**系统关机日志目录**
/etc/shutdownlog
**系统CORE DUMP目录**
/var/adm/crash

#### Tru64
/var/adm/messages
#### Windows
save Application Log and System Log as .TXT files using Event Viewer
## 2.7 检查cpu信息
### Windows
wmic cpu list brief>cpu.txt
systeminfo

### AIX
**查看逻辑cpu个数**
pmcycles -m
bindprocessor -q

**查看物理cpu个数**
prtconf|grep Processors

### Linux
cat /proc/cpuinfo
lscpu

### HPUX 查看 CPU个数
machinfo
ioscan -fnC processor

### Solaris
mpstat  或者 psrinfo / prtdiag -v
## 3.1 检查文件系统空间
### Linux
df -h
df -hi
df -i
fdisk -l
mount |column -t

### AIX
df -g
mount
###AIX 如若文件系统空间使用率过高，可进一步检查vg信息，在有剩余空间的情况下可以在线扩充文件系统大小；在AIX下可以通过getconf命令去得到裸盘的容量大小
getconf DISK_SIZE /dev/rhdisk1

### HP-UX
bdf
df -P
**HP-UX检查共享磁盘聚合前后对应关系**
ioscan -m dsf
**HP-UX查看磁盘大小**
diskinfo /dev/disk/disk*
diskinfo -v
arraydsp -a
**HP-UX pv信息**
cat /etc/lvmtab
pvdisplay -v pv名称
vgdisplay -v
**HP-UX区别本地磁盘以及外挂磁盘**
ioscan -funC disk
**HP-UX查看lun信息**
ioscan -m lun
**查看HBA卡信息**
ioscan -fnC fc
**HP-UX 显示启动卷信息**
lvlnboot -v
**HP-UX 启动盘设备path 信息**
setboot
**HP-UX 内核加载的设备驱动**
lsdev

### Solaris
df -g 
df -h

### Windows
计算机管理-磁盘管理：
## 3.2 检查物理卷
### AIX
lspv                                //检查pvid 部分，如果使用ASM模式一定要确保删除pvid
**查看硬盘**
lspath
**列出所有磁盘设备**
lsdev -Cc disk

### HP-UX
strings /etc/lvmtab
### Linux
pvscan
vgscan
lvscan
pvdisplay
vgdisplay
lvdisplay

## 3.3 AIX检查reserve policy设置情况
```
lsattr -El hdisk1 | grep reserve
lsattr -El rhdiskpower1 | grep reserve
for i in `lspv |awk '{print $1}'`;do echo $i `lsattr -El $i |grep reserve` ;done;
```
## 3.4 多路径状态
### Linux 系统下几种多路径状态的查询方法：
**multipath方式多路径状态检查**
multipath -ll
**EMC存储powerpath**
powermt display dev=all
**日立多路径软件**
dlnkmgr view -path
**华为存储多路径查询**
upadmin
UltraPath CLI #1 >show vlun

## 3.5 aix检查共享vg下lv状态
lsvg -l datavg
lslv -l loglv00

## 3.6 以下检查针对所有平台的11.2.0.4 RAC环境：
Oracle 11.2.0.4版本的RAC，ASM的rbal后台进程存在内存泄露的情况，将可能导致宕机，此问题影响了包括HPUX/AIX/LINUX等在内的操作系统。
建议按照下列方法全面梳理是否存在该情况，并增加进程一级内存使用情况的监控。

* ps -elf |grep -i asm_rbal
ps -elf|grep osw
或
ps aux
正常而言在100M以上，通过比对ASM的其他后台进程即可知晓
*  select * from v$version
* 查看asm alert 日志中是否出现下列信息
针对11.2.0.4 RAC ASM的rbal后台进程存在内存泄露的问题，说明如下：
1. 早在2016年初，ORACLE GCS和ACS部门就处理过几个客户的类似问题（包括文中的客户），所以这并不是一个近期突发的普遍问题，大家大可不必惊慌；
2. 故障根因是由于触发Bug 13904435导致了RBAL内存持续增长，workaround方法早就在文档1457886.1上提供，有条件的同学可以自己去检查实施，一劳永逸；
3. 如果还是担心，可以检查一下当前的RBAL进程内存消耗，没有发现异常增长就OK，因为问题触发只在MOUNT DG时，如果当时触发了就可能出现RBAL内存持续增长，如果当时没发生后面也不会再发生。
## 3.7 检查共享vg模式
## 3.8 检查ASM磁盘组空间
```plsql
Set pagesize 100
Set linesize 180
Col name format a15
select GROUP_NUMBER,NAME,STATE,TYPE,TOTAL_MB,FREE_MB,USABLE_FILE_MB from v$asm_diskgroup;

set pagesize 200
set linesize 150
col path format a60;
col group_name format a10
col name format a20
select a.group_number,b.name as group_name,a.name,a.path,a.state,a.total_mb from v$asm_disk a,v$asm_diskgroup b where a.group_number=b.group_number;
```
lsdg
## 3.9 检查监听日志及alert日志文件大小
**Windows**
进入监听文件及alert目录，检查listener.log大小
**Linux**

```
find / -name "*listener*.log*" | xargs du -h
find / -name "alert*.log*" | xargs du -h
```
[^说明]: Windows下操作系统日接近或者大于4GB时，会造成数据库连接中断或者无法连接的现象；但在某些低版本的数据库中，listener.log大于2GB时会触发某些bug进而造成连接问题。为安全考虑，在所有操作系统平台下，建议尽量防止listener.log出现大于2GB的情况，及时备份清理。
**UNIX**
```
find / -name "*listener*.log*" | xargs du -m
find / -name "alert*.log*" | xargs du -m
HP-UX
find / -name "*listener*.log*" | xargs du -sk
find / -name "alert*.log*" | xargs du -sk
```
## 3.10 AIX信息查看
**查看网卡信息**
lsdev -Cc adapter|grep ent
**查看HBA卡信息**
lsdev -Cc adapter|grep fcs
**查看网络**
netstat -in
**查看路由表**
netstat -r


## 4.1 查看集群运行状态
```
crs_stat -t -v											//10g
crs_stat -t												//10g
crsctl status res -t									 //11g
crsctl check crs                                             //10g或11g
crsctl check cluster                                         //11g
olsnodes -n
或
olsnodes -n -p -i
srvctl status asm -a                                         //11g
srvctl status database -d sdbip
srvctl status diskgroup -g DGDATA1
gpnptool get
cemutlo -n
srvctl status listener -l LISTENER
srvctl status service -d spectra -v
lsnrctl status listener_scan1
lsnrctl services          OR         lsnrctl serice
srvctl status  scan_listener
srvctl config listener -l LISTENER
srvctl config listener -l LISTENER -a
srvctl config scan
crsctl stat res ora.LISTENER_SCAN1.lsnr -p
```
**RAC自启**

```
//11g
crsctl disable crs
crsctl enable crs
//11gRAC启动、关闭
crsctl start cluster -all
crsctl stop cluster -all
//10g
/etc/init.d/init.crs enable随操作系统的启动而启动
/etc/init.d/init.crs disable不随操作系统的启动而启动
//10g RAC启动、关闭
/etc/init.d/init.crs stop停止CRS主进程
/etc/init.d/init.crs start启动CRS主进程
```
**RAC网络配置**

```
[oracle@rac1 init.d]$ oifcfg        Oracle网卡配置工具
Name:
oifcfg - Oracle Interface Configuration Tool.
Usage: oifcfg iflist [-p [-n]]
oifcfg setif {-node <nodename> | -global} {<if_name>/<subnet>:<if_type>}...
oifcfg getif [-node <nodename> | -global] [ -if <if_name>[/<subnet>] [-type <if_type>] ]
oifcfg delif [-node <nodename> | -global] [<if_name>[/<subnet>]]
oifcfg [-help]
<nodename> - name of the host, as known to a communications network
<if_name> - name by which the interface is configured in the system
<subnet> - subnet address of the interface
<if_type> - type of the interface { cluster_interconnect | public | storage }

$ oifcfg iflist									  //查看网卡对应的网段，oracle网卡配置工具
eth0 192.168.1.0
eth1 192.168.2.0
eth2 192.168.61.0

$ oifcfg getif									  //没有配置之前是什么内容也没有

$ oifcfg setif -global eth0/192.168.1.0:public		 //oracle网卡配置工具指定公有网卡

$ oifcfg setif -global eth1/192.168.2.0:cluster_interconnectoracle网卡配置工具指定私有网

[oracle@rac1 init.d]$ oifcfg getif					 //获取配置结果
eth0 192.168.1.0 global public						//eth0是全局公共网卡
eth1 192.168.2.0 global cluster_interconnect		 //eth1是全局私有网卡
```

## 4.2 检查vote、ocr磁盘状态

crsctl query css votedisk
**OCR磁盘状态**
ocrcheck
**检查 ocr备份情况**
ocrconfig -showbackup

```
//使用ocrdump命令查看OCR内容，但这个命令不能用于OCR的备份恢复只可以用于阅读
RACDB1@rac1 /home/oracle$ ocrdump -stdout | more

//导出OCR磁盘内容，一旦有问题可以导入恢复
OCR手动导出:ocrconfig -export /tmp/ocr_bak
OCR手动导入:ocrconfig -import /tmp/ocr_bak
恢复OCR ocrconfig -restore /opt/product/10.2.0.1/crs/cdata/crs/backup01.ocr

//创建用于镜像OCR的RAW设备,比如为:/dev/raw/ocrcopied用ocrconfig –export 导出OCR的信息,编辑/etc/oracle/ocr.loc文件,添加ocrmirrorconfig_loc行
$ cat ocr.loc
ocrconfig_loc=/dev/raw/raw2
ocrmirrorconfig_loc=/dev/raw/ocrcopied
local_only=FALSE
用ocrconfig –import 导入OCR的信息

//我们的表决磁盘使用的是裸设备，因此使用裸设备的dd命令来备份表决磁盘，使用root用户
备份votedisk: dd if=/dev/raw/votediskcopied of=/dev/raw/raw1
恢复votedisk: dd if=/dev/raw/raw1 of=/dev/raw/votediskcopied

//通过strings命令查看votedisk内容
# strings voting_disk.bak |sort -u
```



## 4.3 检查节点vip资源
srvctl config vip -n jaxnh1        #11g
srvctl config nodeapps -n jaxnh1 -a        #10g

## 4.4 验证oracle rac 负载均衡
select inst_id, count(*) from gv$session where status='ACTIVE' group by inst_id;
## 5.1 数据库版本和补丁安装情况
**版本情况**

```
select * from v$version;
select dbid from v$database;
```
#### **补丁安装情况1**

```
su - oracle/su - grid
$ORACLE_HOME/OPatch/opatch lsinventory -oh $ORACLE_HOME
$ORACLE_CRS_HOME/OPatch/opatch lsinventory  -oh $ORACLE_CRS_HOME
$ORA_CRS_HOME/OPatch/opatch lsinventory  -oh $ORA_CRS_HOME
./opatch lsinventory -oh $ORACLE_CRS_HOME                               //10g
./opatch lsinventory -oh $ORACLE_HOME                      //10g
```
#### **补丁安装情况2**

```plsql
set pages 100 lines 120
set echo on
col action format a6
col namespace format a10
col version format a10
col comments format a15
col action_time format a30
col bundle_series format a15
alter session set nls_timestamp_format = 'yyyy-mm-dd hh24:mi:ss.ff';
select * from dba_registry_history;
```
## 5.2 数据库基本配置信息
**数据库基本信息**

```plsql
alter session set NLS_DATE_FORMAT='YYYY-MM-DD HH24:MI:SS';
col PLATFORM_NAME format a30
select dbid,name,platform_name,created, log_mode  from v$database;
```
#### **查看数据库强制日志、最小补充日志、闪回功能开启情况**

```plsql
col FLASHBACK_ON format a2
col platform_name format a10
col name format a9
alter session set NLS_DATE_FORMAT='YYYY-MM-DD HH24:MI:SS';
select dbid,name,platform_name,created,log_mode,force_logging,supplemental_log_data_fk,supplemental_log_data_all,supplemental_log_data_min,flashback_on  from v$database;
select supplemental_log_data_min from gv$database;
```
---alter database add supplemental log data;

#### **查看数据库当前session连接数，以及曾经达到最高的连接个数**

```plsql
select inst_id, sessions_current,sessions_highwater from  gv$license;

Set pagesize 1000
set linesize 100
column name format a30
column value format a40
select inst_id,name,value from gv$parameter where value is not null;
```
#### **非默认参数**

```plsql
Col name for a20
Col value for a40
select num,name,value FROM V$PARAMETER where isdefault='FALSE';
```
#### **隐藏参数**

```plsql
set linesize 200
column name format a50
column value format a25
col description format a40
select x.ksppinm name,y.ksppstvl value,y.ksppstdf isdefault,x.ksppdesc description,
decode(bitand(y.ksppstvf,7),1,'MODIFIED',4,'SYSTEM_MOD','FALSE') ismod,
decode(bitand(y.ksppstvf,2),2,'TRUE','FALSE') isadj
from
sys.x$ksppi x,
sys.x$ksppcv y
where
x.inst_id = userenv('Instance') and
y.inst_id = userenv('Instance') and
x.indx = y.indx and
x.ksppinm LIKE '/_%' escape '/'
order by
translate(x.ksppinm, ' _', ' ');
```
#### **查看参数**

```
show parameter audit_trail
show parameter max_dump_file_size
show parameter processes
show parameter sga_max_size
show parameter sga_target
show parameter spfile
show parameter memory_target
show parameter memory_max_target
show parameter db_block_size
show parameter db_files
show parameter recyclebin
show parameter O7_DICTIONARY_ACCESSIBILITY
show parameter pga_aggregate_target
show parameter listener
show parameter local_listener
show parameter remote_listener
show parameter db_create_file_dest
show parameter log_archive_dest_1
show parameter log_archive_dest_2
```
alter system set max_dump_file_size ='25m' ;
```
set pagesize 200
col PROFILE format a20
col RESOURCE_NAME format a25
col LIMIT format a15
select * from dba_profiles;
```
#### **数据库字符集**

```plsql
select userenv('language') from dual;
select * from NLS_DATABASE_PARAMETERS;
```
#### **数据库实例状态**

```plsql
col host_name  format a20
select inst_id,instance_number,instance_name,host_name,status from gv$instance;
```
## 5.3 数据库产品选项
```plsql
Set pagesize 100
Set linesize 100
set linesize 150
column parameter format a50
column value format a20
select *  from v$option where value='TRUE';
col COMP_NAME format a35;
select comp_id,comp_name, status, substr(version,1,10) as version  from dba_registry;
```
## 5.4 数据量大小
### **查看数据库段空间统计**

select sum(bytes)/1024/1024/1024 as gb from  Dba_Segments;

## 5.5 控制文件
**控制文件**

```plsql
Set linesize 200
Col name format a55
Select * from v$controlfile;
```
#### **生成控制文件**

alter session set tracefile_identifier='bak_control';
alter database backup controlfile to trace;
或
alter database backup controlfile to '/home/oracle/controlfile20171229.bak';

[^注]： RAC报错

```
SQL> alter database backup controlfile to '/home/oracle/controlfile20180926.bak';
alter database backup controlfile to '/home/oracle/controlfile20180926.bak'
*
ERROR at line 1:
ORA-00244: concurrent control file backup operation in progress
```
## 5.6 redo log文件
```plsql
col status format a10;
select thread#, GROUP#,SEQUENCE#,BYTES/1024/1024,STATUS,FIRST_TIME from v$log;

set line 200
col member format a60;
select group#,sequence#,bytes/1024/1024 M ,members,status from v$log;

select * from v$logfile;

select group#,status,type,IS_RECOVERY_DEST_FILE,member from v$logfile;

col status format a10;
select inst_id,thread#, GROUP#,SEQUENCE#,BYTES/1024/1024,STATUS,FIRST_TIME from gv$log;
```
## 5.7 归档情况
```plsql
archive log list;
select log_mode from v$database;

col name format a20
col value  format a40
select inst_id,name,value from gv$parameter where name ='log_archive_dest_1';
```
## 5.8 表空间使用情况
**查看表空间使用信息**

```plsql
set linesize 150
set pagesize 400
column file_name format a65
column tablespace_name format a25
select f.tablespace_name tablespace_name,round((d.sumbytes/1024/1024/1024),2) total_g,
round(f.sumbytes/1024/1024/1024,2) free_g,
round((d.sumbytes-f.sumbytes)/1024/1024/1024,2) used_g,
round((d.sumbytes-f.sumbytes)*100/d.sumbytes,2) used_percent
from (select tablespace_name,sum(bytes) sumbytes from dba_free_space group by tablespace_name) f,
(select tablespace_name,sum(bytes) sumbytes from dba_data_files group by tablespace_name) d
where f.tablespace_name= d.tablespace_name
order by used_percent desc;
```
#### **查看表空间自动扩展情况下的使用信息**

```plsql
set linesize 150 pagesize 500
select f.tablespace_name tablespace_name,
round((d.sumbytes/1024/1024/1024),2) total_without_extend_GB,
round(((d.sumbytes+d.extend_bytes)/1024/1024/1024),2) total_with_extend_GB,
round((f.sumbytes+d.Extend_bytes)/1024/1024/1024,2) free_with_extend_GB,
round((d.sumbytes-f.sumbytes)/1024/1024/1024,2) used_GB,
round((d.sumbytes-f.sumbytes)*100/(d.sumbytes+d.extend_bytes),2) used_percent_with_extend
from (select tablespace_name,sum(bytes) sumbytes from dba_free_space group by tablespace_name) f,
(select tablespace_name,sum(aa.bytes) sumbytes,sum(aa.extend_bytes) extend_bytes from
(select  nvl(case  when autoextensible ='YES' then (case when (maxbytes-bytes)>=0 then (maxbytes-bytes) end) end,0) Extend_bytes
,tablespace_name,bytes  from dba_data_files) aa group by tablespace_name) d
where f.tablespace_name= d.tablespace_name
order by  used_percent_with_extend desc;

select tablespace_name,logging,status from dba_tablespaces;
```
#### **相关数据文件（可扩展性）**

```plsql
Set pagesize 300
Set linesize 300
col file_name format a60
select file_id,tablespace_name,file_name,bytes/1024/1024,status,autoextensible,maxbytes/1024/1024 from dba_data_files;

col file_name format a60
select file_id, file_name,tablespace_name,bytes/1024/1024 as MB ,autoextensible,maxbytes,user_bytes,online_status from dba_data_files;
```
#### **Displays Space Usage for Each Datafile**

```
--
-- Displays Space Usage for Each Datafile.
--
 
SET PAUSE ON
SET PAUSE 'Press Return to Continue'
SET PAGESIZE 60
SET LINESIZE 300
COLUMN "Tablespace Name" FORMAT A20
COLUMN "File Name" FORMAT A80
 
SELECT  Substr(df.tablespace_name,1,20) "Tablespace Name",
        Substr(df.file_name,1,80) "File Name",
        Round(df.bytes/1024/1024,0) "Size (M)",
        decode(e.used_bytes,NULL,0,Round(e.used_bytes/1024/1024,0)) "Used (M)",
        decode(f.free_bytes,NULL,0,Round(f.free_bytes/1024/1024,0)) "Free (M)",
        decode(e.used_bytes,NULL,0,Round((e.used_bytes/df.bytes)*100,0)) "% Used"
FROM    DBA_DATA_FILES DF,
       (SELECT file_id,
               sum(bytes) used_bytes
        FROM dba_extents
        GROUP by file_id) E,
       (SELECT sum(bytes) free_bytes,
               file_id
        FROM dba_free_space
        GROUP BY file_id) f
WHERE    e.file_id (+) = df.file_id
AND      df.file_id  = f.file_id (+)
ORDER BY df.tablespace_name,
         df.file_name
/
```
**查看数据库是否存在数据库文件处于需要还原状态**
select * from v$recover_file;

#### 占用空间最多的10个object

```
col owner format a15
col Segment_Name format a36
col segment_type format a15
col tablespace_name format a15
select owner, Segment_Name,segment_type,tablespace_name,MB from
 (Select owner, Segment_Name,segment_type,tablespace_name,Sum(bytes)/1024/1024 as MB From dba_Extents  group by owner,Segment_Name,segment_type,tablespace_name order by MB desc);
where rownum < 11;
```
**This query lists all tablespaces, the datafiles they use and some usage measurements:**
```
set linesize 133
set pagesize 500

clear break

col TSname format a25 
col TSname heading 'TSpace|Name|'
col FName format a55 
col FName heading 'File|Name|'
col FStatus format a9 
col FStatus heading 'File|Status|'
col FSizeMb format 99999 
col FSizeMb heading 'File|Size|Mb'
col FileFreeMb format 99999
col FileFreeMb heading 'File|Free|Mb'
col FileFreePrct format 999
col FileFreePrct heading 'File|Free|%'
col AutoExt format a6 
col AutoExt heading 'Auto|Extend|?'
col ExtbyMb format a6
col ExtbyMb heading 'Ext by|?|Mb'
col FMaxSizeMb format a8
col FMaxSizeMb heading 'File|Max Size|Mb'
break on TSname skip 1

SELECT
  ddf.tablespace_name as "TSname",
  ddf.file_name as "FName",
  ddf.status as "FStatus",
  ROUND(ddf.bytes/1024/1024,2) as "FSizeMb",
  ROUND(SUM(dfs.bytes)/1024/1024,2) as "FileFreeMb",
  ROUND(SUM(dfs.bytes)/SUM(ddf.bytes)*100,0) as "FileFreePrct",
  ddf.autoextensible as "AutoExt",
  CASE 
    WHEN ddf.increment_by = 0 THEN '-' ELSE TO_CHAR(ROUND((ddf.increment_by * dt.block_size)/1024/1024,2))
  END as "ExtbyMb",
  CASE 
    WHEN ddf.maxbytes = 0 THEN '-' ELSE TO_CHAR(ROUND(ddf.maxbytes/1024/1024,2))
  END as "FMaxSizeMb"
FROM 
  sys.dba_data_files ddf,
  sys.dba_tablespaces dt,
  sys.dba_free_space dfs
WHERE ddf.tablespace_name = dt.tablespace_name
AND ddf.file_id = dfs.file_id(+)
GROUP BY
  ddf.tablespace_name,
  ddf.file_name,
  ddf.status,
  ddf.bytes,
  ddf.autoextensible,
  ddf.increment_by,
  dt.block_size,
  ddf.maxbytes
ORDER BY
  ddf.tablespace_name
;
```
**This query lists all Tablespaces, their status an some usage measurements:**
```
set lines 112
set pages 10000

clear break

col TSname heading 'TSpace|Name|||'
col TSname format a25
col TSstatus heading 'TSpace|Status|||'
col TSstatus format a9
col TSSizeMb heading 'TSpace|Size|||'
col TSSizeMb format 99999
col TSUsedMb heading 'TSpace|Used|Space|Mb|'
col TSUsedMb format 99999
col TSFreeMb heading 'TSpace|Free|Space|Mb|'
col TSFreeMb format 99999
col TSUsedPrct heading 'TSpace|Used|Space|%|'
col TSUsedPrct format 99999
col TSFreePrct heading 'TSpace|Free|Space|%|'
col TSFreePrct format 99999
col TSSegUsedMb heading 'TSpace|Segmt|Space|Mb|'
col TSSegUsedMb format 99999
col TSExtUsedMb heading 'TSpace|Extent|Space|Mb|'
col TSExtUsedMb format 99999
col AutoExtFile heading 'Auto|Extend|File|?|'
col AutoExtFile format a6
col TSMaxSizeMb heading 'TSpace|MaxSize|Mb||'
col TSMaxSizeMb format a6
col TSMaxUsedPrct heading 'TSpace|Maxed|Used|Space|%'
col TSMaxUsedPrct format a6
col TSMaxFreePrct heading 'TSpace|Maxed|Free|Space|%'
col TSMaxFreePrct format a6

WITH
  ts_total_space AS (SELECT
                       tablespace_name,
                       SUM(bytes) as bytes,
                       SUM(blocks) as blocks,
                       SUM(maxbytes) as maxbytes
                     FROM 
                       dba_data_files
                     GROUP BY 
                       tablespace_name),
ts_free_space AS (SELECT
                    ddf.tablespace_name,
                    NVL(SUM(dfs.bytes),0) as bytes,
                    NVL(SUM(dfs.blocks),0) as blocks
                  FROM
                    dba_data_files ddf,
                    dba_free_space dfs
                  WHERE 
                    ddf.file_id = dfs.file_id(+)
                  GROUP BY 
                    ddf.tablespace_name),
ts_total_segments AS (SELECT
                        tablespace_name,
                        SUM(bytes) as bytes,
                        SUM(blocks) as blocks
                      FROM 
                        dba_segments
                      GROUP BY 
                        tablespace_name),
ts_total_extents AS (SELECT
                       tablespace_name,
                       SUM(bytes) as bytes,
                       SUM(blocks) as blocks
                     FROM 
                       dba_extents
                     GROUP BY 
                       tablespace_name)
SELECT
  dt.tablespace_name as "TSname",
  dt.status as "TSstatus",
  ROUND(ttsp.bytes/1024/1024,0) as "TSSizeMb",
  ROUND((ttsp.bytes-tfs.bytes)/1024/1024,0) as "TSUsedMb",
  ROUND(tfs.bytes/1024/1024,0) as "TSFreeMb",
  ROUND((ttsp.bytes-tfs.bytes)/ttsp.bytes*100,0) as "TSUsedPrct",
  ROUND(tfs.bytes/ttsp.bytes*100,0) as "TSFreePrct",
  ROUND(ttse.bytes/1024/1024,0) as "TSSegUsedMb",
  ROUND(tte.bytes/1024/1024,0) as "TSExtUsedMb",
  CASE 
    WHEN ttsp.maxbytes = 0 THEN 'No' ELSE 'Yes' 
  END as "AutoExtFile",
  CASE 
    WHEN ttsp.maxbytes = 0 THEN '-' ELSE TO_CHAR(ROUND(ttsp.maxbytes/1024/1024,0))
  END as "TSMaxSizeMb",
  CASE 
    WHEN ttsp.maxbytes = 0 THEN '-' ELSE TO_CHAR(ROUND((ttsp.bytes-tfs.bytes)/ttsp.maxbytes*100,0))
  END as "TSMaxUsedPrct",
  CASE 
    WHEN ttsp.maxbytes = 0 THEN '-' ELSE TO_CHAR(ROUND((ttsp.maxbytes-(ttsp.bytes-tfs.bytes))/ttsp.maxbytes*100,0))
  END as "TSMaxFreePrct"
FROM
  dba_tablespaces dt,
  ts_total_space ttsp,
  ts_free_space tfs,
  ts_total_segments ttse,
  ts_total_extents tte
WHERE dt.tablespace_name = ttsp.tablespace_name(+)
AND dt.tablespace_name = tfs.tablespace_name(+)
AND dt.tablespace_name = ttse.tablespace_name(+)
AND dt.tablespace_name = tte.tablespace_name(+)
ORDER BY ttsp.tablespace_name
;
```
**This query lists all segments of a tablespace, their status an some usage measurements:**
```
set lines 137
set pages 10000

clear break

col TSname heading 'TSpace|Name|'
col TSname format a25
col SgmntOwner heading 'Sgmnt|Owner|'
col SgmntOwner format a15
col SgmntType heading 'Sgmnt|Type|'
col SgmntType format a15
col SgmntName heading 'Sgmnt|Name|'
col SgmntName format a35
col MinExt heading 'Min|No of|Ext'
col MinExt format 99999999999
col MaxExt heading 'Max|No of|Ext'
col MaxExt format 99999999999
col SgmntSize heading 'Sgmnt|Size|Mb'
col SgmntSize format 9999
col SgmntExentNo heading 'No of|Extent|'
col SgmntExentNo format 9999999999

SELECT
  ds.tablespace_name as "TSname",
  ds.owner as "SgmntOwner",
  ds.segment_type as "SgmntType",
  ds.segment_name as "SgmntName",
  ds.min_extents as "MinExt",
  ds.max_extents as "MaxExt",
  ROUND(ds.bytes/1024/1024,0) as "SgmntSize",
  SUM(ds.extents) as "SgmntExentNo"
FROM
  dba_segments ds
WHERE tablespace_name = 'SYSAUX'
GROUP BY
  ds.tablespace_name,
  ds.owner,
  ds.segment_type,
  ds.segment_name,
  ds.min_extents,
  ds.max_extents,
  ds.bytes
ORDER BY
  ds.tablespace_name,
  ds.owner,
  ds.segment_type,
  ds.segment_name
;
```

## 5.9 临时表空间及账户状态
**用户使用临时表空间情况**
```plsql
column username format a25
column account_status format a20
col default_tablespace format a20
col temporary_tablespace format a20
select username,account_status,default_tablespace,temporary_tablespace from dba_users;

col username format a25;
col account_status format a20;
col default_tablespace format a19;
col temporary_tablespace format a10;
select username,account_status,default_tablespace,temporary_tablespace,CREATED from dba_users order by account_status,created;
```
### 临时表空间使用
```plsql
SELECT d.tablespace_name "Name",
TO_CHAR(NVL(a.bytes / 1024 / 1024, 0),'99,999,990.900') "Size (M)",
TO_CHAR(NVL(t.hwm, 0)/1024/1024,'99999999.999')  "HWM (M)",
TO_CHAR(NVL(t.hwm / a.bytes * 100, 0), '990.00') "HWM % " ,
TO_CHAR(NVL(t.bytes/1024/1024, 0),'99999999.999') "Using (M)",
TO_CHAR(NVL(t.bytes / a.bytes * 100, 0), '990.00') "Using %"
FROM sys.dba_tablespaces d,
(select tablespace_name, sum(bytes) bytes from dba_temp_files group by tablespace_name) a,
(select tablespace_name, sum(bytes_cached) hwm, sum(bytes_used) bytes from v$temp_extent_pool group by tablespace_name) t
WHERE d.tablespace_name = a.tablespace_name(+)
AND d.tablespace_name = t.tablespace_name(+)
AND d.extent_management like 'LOCAL'
AND d.contents like 'TEMPORARY';
```
### 临时数据文件大小
```plsql
Set pagesize 100
Set linesize 200
col file_name format a55
select tablespace_name,file_name,bytes/1024/1024,autoextensible,maxbytes/1024/1024 from dba_temp_files;
```
## 5.10 SCHEMA使用情况
**每个schema使用情况**

```plsql
select owner, count(*),sum(bytes)/1024/1024/1024 as GB from dba_segments group by owner order by GB desc;
```
### 数据库连接数
```
col name format a10
col value format a10
select sessions_current,sessions_highwater from  gv$license;

select name,value from v$parameter where name='processes';
```
## 5.11  RMAN 备份情况
**查看数据库是否存在备份实效情况**
```plsql
col INPUT_BYTES_PER_SEC_DISPLAY format a15;
col OUTPUT_BYTES_PER_SEC_DISPLAY format a15;
col TIME_TAKEN_DISPLAY format a17;
col status format a10;
COL hours    FORMAT 999.999
COL out_size FORMAT a10
select session_key,AUTOBACKUP_DONE,OUTPUT_DEVICE_TYPE, INPUT_TYPE,status,ELAPSED_SECONDS/3600     hours,   TO_CHAR(START_TIME,'yyyy-mm-dd hh24:mi') start_time, OUTPUT_BYTES_DISPLAY out_size,OUTPUT_BYTES_PER_SEC_DISPLAY,INPUT_BYTES_PER_SEC_DISPLAY  from v$RMAN_BACKUP_JOB_DETAILS order by start_time ;

col INPUT_BYTES_PER_SEC_DISPLAY format a15;
col OUTPUT_BYTES_PER_SEC_DISPLAY format a15;
col TIME_TAKEN_DISPLAY format a17;
col status format a10;
COL hours    FORMAT 999.999
COL out_size FORMAT a10
col handle format a80
select session_key,AUTOBACKUP_DONE,OUTPUT_DEVICE_TYPE, INPUT_TYPE,status,ELAPSED_SECONDS/3600     hours,
TO_CHAR(START_TIME,'yyyy-mm-dd hh24:mi') start_time, OUTPUT_BYTES_DISPLAY out_size,OUTPUT_BYTES_PER_SEC_DISPLAY,
INPUT_BYTES_PER_SEC_DISPLAY
from v$RMAN_BACKUP_JOB_DETAILS  where start_time >sysdate-30 order by start_time;

select * from (select RECID,start_time,HANDLE from v$backup_piece  order by start_time desc ) where rownum<30;

rman target /
list backup of database ;
list backup of archivelog all;
show all;
```
[^注]: 若是备份信息存储在control file中,并且rman的保留策略是天数；需要根据control_file_record_keep_time的参数值,进一步评估control_file_record_keep_time参数值的合理性。
## 5.12  CRS 日志报错情况
## 5.13  RDBMS 日志报错情况
### 参看数据库，RAC日志、ASM日志
tail -1000
## 5.14  数据库中无效对象情况
### ALL
```plsql
set linesize 500
col owner format a15
col object_name format a30
col object_id format 99999999
col object_type format a10
SELECT OWNER,OBJECT_NAME, OBJECT_ID, OBJECT_TYPE,to_char(CREATED,'yyyy-mm-dd,hh24:mi:ss') CREATED,
to_char(LAST_DDL_TIME,'yyyy-mm-dd,hh24:mi:ss') LAST_DDL_TIME,STATUS
FROM  dba_objects where status<>'VALID' order by owner,object_name,OBJECT_TYPE;
```
### 非SYS
```plsql
set linesize 200
col owner format a15
col object_name format a30
col object_id format 99999999
col object_type format a10
SELECT OWNER,OBJECT_NAME, OBJECT_ID, OBJECT_TYPE,to_char(CREATED,'yyyy-mm-dd,hh24:mi:ss') CREATED,
to_char(LAST_DDL_TIME,'yyyy-mm-dd,hh24:mi:ss') LAST_DDL_TIME,STATUS
FROM  dba_objects where status<>'VALID' and owner='SYS' order by last_ddl_time;
```
[^参考文章]: How to Diagnose Invalid or Missing Data Dictionary (SYS) Objects (文档 ID 554520.1)
[^参考文章]: Debug and Validate Invalid Objects (文档 ID 300056.1)
### 占用空间最多的10个object
```plsql
col owner format a15
col Segment_Name format a36
col segment_type format a15
col tablespace_name format a15
select owner, Segment_Name,segment_type,tablespace_name,MB from
(Select owner, Segment_Name,segment_type,tablespace_name,Sum(bytes)/1024/1024 as MB From dba_Extents  group by owner,Segment_Name,segment_type,tablespace_name order by MB desc)
where rownum < 11;
```
## 5.15  数据库scn headroom问题检查
```plsql
Rem
Rem $Header: rdbms/admin/scnhealthcheck.sql st_server_tbhukya_bug-13498243/8 2012/01/17 03:37:18 tbhukya Exp $
Rem
Rem scnhealthcheck.sql
Rem
Rem Copyright (c) 2012, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      scnhealthcheck.sql - Scn Health check
Rem
Rem    DESCRIPTION
Rem      Checks scn health of a DB
Rem
Rem    NOTES
Rem      .
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    tbhukya     01/11/12 - Created
Rem
Rem
define LOWTHRESHOLD=10
define MIDTHRESHOLD=62
define VERBOSE=TRUE
set veri off;
set feedback off;
set serverout on
DECLARE
verbose boolean:=&&VERBOSE;
BEGIN
For C in (
select
version,
date_time,
dbms_flashback.get_system_change_number current_scn,
indicator
from
(
select
version,
to_char(SYSDATE,'YYYY/MM/DD HH24:MI:SS') DATE_TIME,
((((
((to_number(to_char(sysdate,'YYYY'))-1988)*12*31*24*60*60) +
((to_number(to_char(sysdate,'MM'))-1)*31*24*60*60) +
(((to_number(to_char(sysdate,'DD'))-1))*24*60*60) +
(to_number(to_char(sysdate,'HH24'))*60*60) +
(to_number(to_char(sysdate,'MI'))*60) +
(to_number(to_char(sysdate,'SS')))
) * (16*1024)) - dbms_flashback.get_system_change_number)
/ (16*1024*60*60*24)
) indicator
from v$instance
)
) LOOP
dbms_output.put_line( '-----------------------------------------------------'
|| '---------' );
dbms_output.put_line( 'ScnHealthCheck' );
dbms_output.put_line( '-----------------------------------------------------'
|| '---------' );
dbms_output.put_line( 'Current Date: '||C.date_time );
dbms_output.put_line( 'Current SCN:  '||C.current_scn );
if (verbose) then
dbms_output.put_line( 'SCN Headroom: '||round(C.indicator,2) );
end if;
dbms_output.put_line( 'Version:      '||C.version );
dbms_output.put_line( '-----------------------------------------------------'
|| '---------' );
IF C.version > '10.2.0.5.0' and
C.version NOT LIKE '9.2%' THEN
IF C.indicator>&MIDTHRESHOLD THEN
dbms_output.put_line('Result: A - SCN Headroom is good');
dbms_output.put_line('Apply the latest recommended patches');
dbms_output.put_line('based on your maintenance schedule');
IF (C.version < '11.2.0.2') THEN
dbms_output.put_line('AND set _external_scn_rejection_threshold_hours='
|| '24 after apply.');
END IF;
ELSIF C.indicator<=&LOWTHRESHOLD THEN
dbms_output.put_line('Result: C - SCN Headroom is low');
dbms_output.put_line('If you have not already done so apply' );
dbms_output.put_line('the latest recommended patches right now' );
IF (C.version < '11.2.0.2') THEN
dbms_output.put_line('set _external_scn_rejection_threshold_hours=24 '
|| 'after apply');
END IF;
dbms_output.put_line('AND contact Oracle support immediately.' );
ELSE
dbms_output.put_line('Result: B - SCN Headroom is low');
dbms_output.put_line('If you have not already done so apply' );
dbms_output.put_line('the latest recommended patches right now');
IF (C.version < '11.2.0.2') THEN
dbms_output.put_line('AND set _external_scn_rejection_threshold_hours='
||'24 after apply.');
END IF;
END IF;
ELSE
IF C.indicator<=&MIDTHRESHOLD THEN
dbms_output.put_line('Result: C - SCN Headroom is low');
dbms_output.put_line('If you have not already done so apply' );
dbms_output.put_line('the latest recommended patches right now' );
IF (C.version >= '10.1.0.5.0' and
C.version <= '10.2.0.5.0' and
C.version NOT LIKE '9.2%') THEN
dbms_output.put_line(', set _external_scn_rejection_threshold_hours=24'
|| ' after apply');
END IF;
dbms_output.put_line('AND contact Oracle support immediately.' );
ELSE
dbms_output.put_line('Result: A - SCN Headroom is good');
dbms_output.put_line('Apply the latest recommended patches');
dbms_output.put_line('based on your maintenance schedule ');
IF (C.version >= '10.1.0.5.0' and
C.version <= '10.2.0.5.0' and
C.version NOT LIKE '9.2%') THEN
dbms_output.put_line('AND set _external_scn_rejection_threshold_hours=24'
|| ' after apply.');
END IF;
END IF;
END IF;
dbms_output.put_line(
'For further information review MOS document id 1393363.1');
dbms_output.put_line( '-----------------------------------------------------'
|| '---------' );
END LOOP;
end;
/
```
## 5.16 数据库当前的等待事件
```
select inst_id,event,count(1) from gv$session where wait_class#<> 6 group by inst_id,event order by 1,3;

//查询每个客户端连接每个实例的连接数
select inst_id,machine ,count(*) from gv$session group by machine,inst_id order by 3;

select INST_ID,status,count(status) from gv$session group by status,INST_ID order by status,INST_ID;

//查看内存占用大的
SELECT server "连接类型",s.MACHINE,s.username,s.osuser,sn.NAME,VALUE/1024/1024 "占用内存MB",s.SID "会话ID",
      s.serial#,p.spid "操作系统进程ID",p.PGA_USED_MEM,p.PGA_ALLOC_MEM,p.PGA_FREEABLE_MEM, 
      p.PGA_MAX_MEM 
FROM v$session s, v$sesstat st, v$statname sn, v$process p 
WHERE st.SID = s.SID AND st.statistic# = sn.statistic# AND sn.NAME LIKE 'session pga memory' 
     AND p.addr = s.paddr and rownum<20
ORDER BY VALUE DESC ;

SELECT s.inst_id,s.username,s.MACHINE,s.osuser,VALUE/1024/1024 "占用内存MB",s.SID "会话ID",
      s.serial#,p.spid "操作系统进程ID",p.PGA_USED_MEM,p.PGA_FREEABLE_MEM, 
      p.PGA_MAX_MEM 
FROM gv$session s, v$sesstat st, v$statname sn, v$process p 
WHERE st.SID = s.SID AND st.statistic# = sn.statistic# AND sn.NAME LIKE 'session pga memory' 
     AND p.addr = s.paddr and rownum<20 and s.username is not null
ORDER BY VALUE DESC ;

SELECT sum(VALUE/1024/1024) "占用内存MB" 
FROM v$session s, v$sesstat st, v$statname sn, v$process p 
WHERE st.SID = s.SID AND st.statistic# = sn.statistic# AND sn.NAME LIKE 'session pga memory' 
     AND p.addr = s.paddr and s.username is not null;

alter system kill session '1568,27761,@2' immediate; 

//查锁
 with lk as (select blocking_instance||'.'||blocking_session blocker, inst_id||'.'||sid waiter 
                  from gv$session 
                  where blocking_instance is not null 
                    and blocking_session is not null)
      select lpad('  ',2*(level-1))||waiter lock_tree from
       (select * from lk
        union all
        select distinct 'root', blocker from lk
        where blocker not in (select waiter from lk))
      connect by prior waiter=blocker start with blocker='root';
```

## 5.17 客户端连接分布
```plsql
col MACHINE format a20
select inst_id,machine ,count(*) from gv$session group by machine,inst_id order by 3;
```
## 5.18  检查15天内归档的生成情况
```plsql
set numw 4
SELECT  trunc(first_time) "Date",
to_char(first_time, 'Dy') "Day",
count(1) "Total",
SUM(decode(to_char(first_time, 'hh24'),'00',1,0)) "h0",
SUM(decode(to_char(first_time, 'hh24'),'01',1,0)) "h1",
SUM(decode(to_char(first_time, 'hh24'),'02',1,0)) "h2",
SUM(decode(to_char(first_time, 'hh24'),'03',1,0)) "h3",
SUM(decode(to_char(first_time, 'hh24'),'04',1,0)) "h4",
SUM(decode(to_char(first_time, 'hh24'),'05',1,0)) "h5",
SUM(decode(to_char(first_time, 'hh24'),'06',1,0)) "h6",
SUM(decode(to_char(first_time, 'hh24'),'07',1,0)) "h7",
SUM(decode(to_char(first_time, 'hh24'),'08',1,0)) "h8",
SUM(decode(to_char(first_time, 'hh24'),'09',1,0)) "h9",
SUM(decode(to_char(first_time, 'hh24'),'10',1,0)) "h10",
SUM(decode(to_char(first_time, 'hh24'),'11',1,0)) "h11",
SUM(decode(to_char(first_time, 'hh24'),'12',1,0)) "h12",
SUM(decode(to_char(first_time, 'hh24'),'13',1,0)) "h13",
SUM(decode(to_char(first_time, 'hh24'),'14',1,0)) "h14",
SUM(decode(to_char(first_time, 'hh24'),'15',1,0)) "h15",
SUM(decode(to_char(first_time, 'hh24'),'16',1,0)) "h16",
SUM(decode(to_char(first_time, 'hh24'),'17',1,0)) "h17",
SUM(decode(to_char(first_time, 'hh24'),'18',1,0)) "h18",
SUM(decode(to_char(first_time, 'hh24'),'19',1,0)) "h19",
SUM(decode(to_char(first_time, 'hh24'),'20',1,0)) "h20",
SUM(decode(to_char(first_time, 'hh24'),'21',1,0)) "h21",
SUM(decode(to_char(first_time, 'hh24'),'22',1,0)) "h22",
SUM(decode(to_char(first_time, 'hh24'),'23',1,0)) "h23"
FROM    V$log_history where to_date(first_time)>to_date(sysdate-15)
group by trunc(first_time), to_char(first_time, 'Dy')
Order by 1;
set numw 10
```
## 5.19 目前数据库中未删除的归档总大小
```
select  ((sum(blocks * block_size)) /1024 /1024) as "MB" from v$archived_log where  STANDBY_DEST  ='NO'  and deleted='NO';
```
```
//删除3天前的归档日志，注意不要敲错日期，此删除操作是不可逆的。
RMAN> delete force archivelog until time "sysdate";
//删除3天前的归档日志
delete  archivelog until time "sysdate-3";
```
## 5.20 数据库所有实例每天生成的归档大小
```plsql
select
trunc(completion_time) as "Date"
,count(*) as "Count"
,((sum(blocks * block_size)) /1024 /1024) as "MB"
from gv$archived_log where  STANDBY_DEST  ='NO'
group by trunc(completion_time) order by trunc(completion_time) ;
```
## 5.21  检查数据库中DBA权限的用户
```plsql
set pagesize 400
select * from dba_role_privs where granted_role='DBA';
```
## 5.22   数据库中DBLINK的创建信息
```plsql
SELECT 'CREATE '||DECODE(U.NAME,'PUBLIC','public ')||'DATABASE LINK '||CHR(10)
||DECODE(U.NAME,'PUBLIC',Null, 'SYS','',U.NAME||'.')|| L.NAME||chr(10)
||'CONNECT TO ' || L.USERID || ' IDENTIFIED BY "'||L.PASSWORD||'" USING
'''||L.HOST||''''
||chr(10)||';' TEXT
FROM SYS.LINK$ L, SYS.USER$ U
WHERE L.OWNER# = U.USER#;
```
## 5.23   检查object_id的最大值
select max(object_id) from dba_objects;
## 5.24   入侵检查
如果查询出信息输出则表示已经被恶意程序植入了比特币勒索触发器，需要尽快处理。该问题主要是通过使用互联网上非正规渠道获得的plsqldevloper工具连接数据库时传播感染。
```plsql
select 'DROP TRIGGER '||owner||'."'||TRIGGER_NAME||'";' from dba_triggers where
TRIGGER_NAME like 'DBMS_%_INTERNAL% '
union all
select 'DROP PROCEDURE '||owner||'."'||a.object_name||'";' from dba_procedures a
where a.object_name like 'DBMS_%_INTERNAL% ';

select owner,object_name,created from dba_objects where object_name like 'DBMS_SUPPORT_DBMONITOR%';
```
## 5.25 Unusable Index(es) 
```plsql
select t.owner,t.index_name,t.table_name,blevel,t.num_rows,t.leaf_blocks,t.distinct_keys  from dba_indexes t
where status = 'UNUSABLE'
and  table_owner not in ('ORDDATA','ORDSYS','DMSYS','APEX_030200','OUTLN','DBSNMP','SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB')
and owner in (select username from dba_users where account_status='OPEN');
```
## 5.26 Index(es) of blevel>=3
```plsql
col INDEX_NAME for a30
SELECT owner,index_name,blevel FROM dba_indexes WHERE blevel >= 3 ORDER BY blevel DESC;
```
## 5.27 Other Index Type
```plsql
select t.owner,t.table_name,t.index_name,t.index_type,t.status,t.blevel,t.leaf_blocks from dba_indexes t
where index_type in ('BITMAP', 'FUNCTION-BASED NORMAL', 'NORMAL/REV')
and owner not in ('ORDDATA','ORDSYS','DMSYS','APEX_030200','OUTLN','DBSNMP','SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','ORDSYS','DBSNMP','OUTLN','TSMSYS') and owner in (select username from dba_users where account_status='OPEN');
```
## 5.28 Any Business data in system tablespace 
```plsql
select * from (select owner, segment_name, segment_type,tablespace_name
  from dba_segments where tablespace_name in('SYSTEM','SYSAUX'))
where  owner not in ('MTSSYS','ORDDATA','ORDSYS','DMSYS','APEX_030200','OUTLN','DBSNMP','SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','ORDSYS','DBSNMP','OUTLN','TSMSYS') and owner in (select username from dba_users where account_status='OPEN');
```
## 5.29 Table(s) of degree
select owner,table_name name,status,degree from dba_tables where degree>1;
## 5.30 Index(es) of degree 
select owner,index_name name,status,degree from dba_indexes where degree>'1';
## 5.31 Disabled Trigger(es)
```plsql
SELECT owner, trigger_name, table_name, status FROM dba_triggers WHERE status = 'DISABLED' and owner in (select username from dba_users where account_status='OPEN');
```
## 5.32 Disabled Constraint(s) 
```plsql
SELECT owner, constraint_name, table_name, constraint_type, status 
FROM dba_constraints WHERE status ='DISABLE' and constraint_type='P' and owner in (select username from dba_users where account_status='OPEN');
```
## 5.33  Foreign Key no index
```plsql
select c.owner,d.table_name,d.CONSTRAINT_NAME,d.columns from DBA_CONS_COLUMNS c,
(SELECT TABLE_NAME,
       CONSTRAINT_NAME,
       CNAME1 || NVL2(CNAME2, ',' || CNAME2, NULL) ||
       NVL2(CNAME3, ',' || CNAME3, NULL) ||
       NVL2(CNAME4, ',' || CNAME4, NULL) ||
       NVL2(CNAME5, ',' || CNAME5, NULL) ||
       NVL2(CNAME6, ',' || CNAME6, NULL) ||
       NVL2(CNAME7, ',' || CNAME7, NULL) ||
       NVL2(CNAME8, ',' || CNAME8, NULL) COLUMNS
  FROM (SELECT B.TABLE_NAME,
               B.CONSTRAINT_NAME,               
               MAX(DECODE(POSITION, 1, COLUMN_NAME, NULL)) CNAME1,
               MAX(DECODE(POSITION, 2, COLUMN_NAME, NULL)) CNAME2,
               MAX(DECODE(POSITION, 3, COLUMN_NAME, NULL)) CNAME3,
               MAX(DECODE(POSITION, 4, COLUMN_NAME, NULL)) CNAME4,
               MAX(DECODE(POSITION, 5, COLUMN_NAME, NULL)) CNAME5,
               MAX(DECODE(POSITION, 6, COLUMN_NAME, NULL)) CNAME6,
               MAX(DECODE(POSITION, 7, COLUMN_NAME, NULL)) CNAME7,
               MAX(DECODE(POSITION, 8, COLUMN_NAME, NULL)) CNAME8,
               COUNT(*) COL_CNT
          FROM (SELECT SUBSTR(TABLE_NAME, 1, 30) TABLE_NAME,
                       SUBSTR(CONSTRAINT_NAME, 1, 30) CONSTRAINT_NAME,
                       SUBSTR(COLUMN_NAME, 1, 30) COLUMN_NAME,
                       POSITION
                  FROM DBA_CONS_COLUMNS) A,
               DBA_CONSTRAINTS B
         WHERE A.CONSTRAINT_NAME = B.CONSTRAINT_NAME
           AND B.CONSTRAINT_TYPE = 'R'
         GROUP BY B.TABLE_NAME, B.CONSTRAINT_NAME) CONS
 WHERE COL_CNT > ALL (SELECT COUNT(*)
          FROM DBA_IND_COLUMNS I WHERE I.TABLE_NAME = CONS.TABLE_NAME
           AND I.COLUMN_NAME IN (CNAME1,CNAME2,CNAME3,CNAME4,CNAME5,CNAME6,CNAME7,CNAME8)
           AND I.COLUMN_POSITION <= CONS.COL_CNT
GROUP BY I.INDEX_NAME)) d where c.constraint_name=d.CONSTRAINT_NAME and c.table_name=d.TABLE_NAME
and c.owner in(select username from dba_users where account_status='OPEN' and username not in ('SYS','SYSTEM','SYSMAN','DBSNMP')) order by c.owner;
```
## 6.1 数据库保护模式
```plsql
select DB_UNIQUE_NAME,DATABASE_ROLE DB_ROLE,FORCE_LOGGING F_LOG,FLASHBACK_ON FLASHB_ON,LOG_MODE,OPEN_MODE,
GUARD_STATUS GUARD,PROTECTION_MODE PROT_MODE
from v$database;

select DEST_ID, APPLIED_SCN FROM v$archive_dest WHERE TARGET='STANDBY';
```
**查看备库状态**

```plsql
select DB_UNIQUE_NAME,DATABASE_ROLE DB_ROLE,FORCE_LOGGING F_LOG,FLASHBACK_ON FLASHB_ON,LOG_MODE,OPEN_MODE,
GUARD_STATUS GUARD,PROTECTION_MODE PROT_MODE
from v$database;
```
## 6.2 备库同步状态
**主端查询**

```plsql
select max(sequence#),thread# from v$archived_log where RESETLOGS_CHANGE# = (SELECT RESETLOGS_CHANGE# FROM V$DATABASE_INCARNATION WHERE STATUS = 'CURRENT') GROUP BY THREAD#;

archive log list;
```
**备端查询**

```plsql
select max(sequence#),thread# from gv$archived_log where  applied='YES' and RESETLOGS_CHANGE# = (SELECT RESETLOGS_CHANGE# FROM V$DATABASE_INCARNATION WHERE STATUS = 'CURRENT') GROUP BY THREAD#; 

SELECT PROCESS,STATUS,THREAD#,SEQUENCE#,BLOCK#,BLOCKS,DELAY_MINS FROM V$MANAGED_STANDBY;

select DB_UNIQUE_NAME,SWITCHOVER_STATUS,CURRENT_SCN from v$database;
select sequence#,applied from v$archived_log;
select max(sequence#),applied,thread# from v$archived_log group by applied,thread# order by thread#;

select * from V$DATAGUARD_STATUS order by TIMESTAMP desc,error_code;

archive log list;
```
[^注]: 如果主备相差3个以内可以接受，如果相差较多则表示同步异常。
**切换归档日志**

```
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;
ALTER DATABASE OPEN READ ONLY;
RECOVER MANAGED STANDBY DATABASE DISCONNECT USING CURRENT LOGFILE;
ALTER SYSTEM SWITCH LOGFILE;
ALTER SYSTEM ARCHIVE LOG CURRENT;
```

**同步状态**

```plsql
col name for a30
set linesize 500
col  value for a50
select name,value  from v$dataguard_stats;
```
**检查是否存在断档**
select * from v$archive_gap;

## 7.1 AWR、ASH
**脚本目录  $ORACLE_HOME/rdbms/admin**

```
@?/rdbms/admin/addmrpt.sql
@?/rdbms/admin/awrrpt.sql
@?/rdbms/admin/ashrpt.sql
```
## 7.2 参数文件备份
```
create pfile='C:\Users\Administrator\Desktop\pfile20170109.ora' from spfile;
create pfile='/home/oracle/pfile20181127_his.ora' from spfile;
create pfile='/export/home/oracle/pfile20170626.ora' from spfile;     <!--Solaris-->
```