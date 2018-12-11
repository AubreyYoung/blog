# 11g_linux5.8单机数据库安装步骤

Master Note of Linux OS Requirements for Database Server [ID 851598.1]

  

初始化系统服务：

  

chkconfig sendmail off

chkconfig iptables off

  

#6.x版本上关闭 NetworkManager 服务

  

chkconfig NetworkManager off

  

关闭selinux:

  

vi /etc/selinux/config

SELINUX=disabled

  

ln -s /lib64/libcap.so.2.16 /lib64/libcap.so.1

  

一、yum

 操作系统安装完毕后不要将系统光盘遗留在光驱中。

 可上传系统ISO，并挂载镜像。

  

 mount -o loop xxx.iso /mnt

  

vi /etc/yum.repos.d/rhel.repo

[rhel]

name=rhel

baseurl=file:///mnt/Server/

enabled=1

gpgcheck=0

  

echo 'multilib_policy=all' >> /etc/yum.conf

  

yum install tiger* binutils compat-libstdc++ elfutils-libelf elfutils-libelf-
devel gcc gcc-c++ glibc glibc-common glibc-devel glibc-headers ksh libaio
libaio libaio-devel libaio-devel libgcc libstdc++ libstdc++-devel make sysstat
unixODBC unixODBC unixODBC-devel unixODBC-devel iscsi systat* -y

  

二、修改主机名

  

vi /etc/sysconfig/network

#将其中HOSTNAME改为主机名，如下：

HOSTNAME=test

  

修改完主机名务必重启生效

  

三、修改/etc/hosts

  

# Do not remove the following line, or various programs

# that require network functionality will fail.

127.0.0.1 localhost.localdomain localhost

::1 localhost6.localdomain6 localhost6

  

#添加如下主机和ip的对应关系，切记127.0.0.1 这一行不要删除。

192.168.124.139 test

  

三、用户、安装目录、用户资源限制

  

 vi /etc/security/limits.conf

  

oracle soft nproc 2047

oracle hard nproc 16384

oracle soft nofile 1024

oracle hard nofile 65536

oracle soft stack 10240

  

  

  

vi /etc/pam.d/login

session required pam_limits.so

  

/usr/sbin/groupadd -g 500 oinstall

/usr/sbin/groupadd -g 501 dba

/usr/sbin/useradd -u 500 -g oinstall -G dba oracle

 passwd oracle

 密码设置为oracle@123

  

 mkdir -p /u01/app/oracle

 mkdir  /oradata  /fra

 chown oracle:oinstall /u01/ -R

 chmod 775 /u01/app/oracle/ -R

 chown oracle:oinstall /oradata

 chown oracle:oinstall /fra

 chown oracle:oinstall /rmanbackup

  

su - oracle

  

vi /home/oracle/.bash_profile

  

export ORACLE_BASE=/u01/app/oracle

export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/dbhome_1

export ORACLE_SID=orcl

export PATH=$ORACLE_HOME/bin:$PATH

  

四、系统内核参数

  

 vi /etc/sysctl.conf

  

#shmmax是物理内存的1/2 单位是b

kernel.shmmax = 68719476736

kernel.shmall = 4294967296

#getconf PAGE_SIZE 可以获取到当前系统的pgaesize。linux一般是4096 即 4Kb ，所以shamll的值设置为
物理内存G*1024*1024/4

  

#以下参数内容直接复制到sysctl.conf最后即可。

fs.aio-max-nr = 1048576

fs.file-max = 6815744

kernel.shmmni = 4096

kernel.sem = 250 32000 100 128

net.ipv4.ip_local_port_range = 9000 65500

net.core.rmem_default = 262144

net.core.rmem_max = 4194304

net.core.wmem_default = 262144

net.core.wmem_max = 1048576

  

运行sysctl -p 是以上参数生效

  

五、图形界面安装

  

配置远程图形化界面--vnc

vncserver

输入登陆密码oracle@123

  

注释掉 /root/.vnc/xstartup 中的最后一行

改为 session-gnome &

保存退出

  

相关步骤截图查看《11g_linux5.8单机数据库安装截图》

  

cd /../../database/

./runInstaller

  

#######################################################################

创建监听-----相关步骤查看word截图过程

netca

  

#######################################################################

创建数据库-----相关步骤查看word截图过程

dbca

  

#######################################################################

执行脚本

  

su - root

/u01/app/oraInventory/orainstRoot.sh

/u01/app/oracle/product/11.2.0/dbhome_1/root.sh

  

#######################################################################

  

六、安装完成后的参数检查与修改。

  

sqlplus / as sysdba

  

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

  

shutdown immediate;

startup

  

SGA_MAX_SIZE\SGA_TARGET \pga_aggregate_target

保守的设置原则是 ：

SGA_TARGET+pga_aggregate_target=物理内存*0.6

SGA_TARGET : pga_aggregate_target 比例是4:1

SGA_TARGET 等于 SGA_MAX_SIZE

  

根据实际物理内存进行调整。

  

七、大页内存

  

如果内存大于等于64G 考虑开启大页内存

  

大页内存计算方法是 ：

SGA_MAX_SIZE 单位是G

(SGA_MAX_SIZE*1024/2)+2= 大页内存值

uname -r 查看内核版本

 2.4对应的参数是：vm.hugetlb_pool =大页内存值

 2.6对应的参数是：vm.nr_hugepages =大页内存值

  

 将以上参数值 如vm.hugetlb_pool =9218 追加到/etc/sysctl.conf最后一行。

  

 在/etc/security/limits.conf文件中增加如下行

 oracle soft memlock 18878464

 oracle hard memlock 18878464

  

 以上18878464的值替换成 大页内存值*2*1024

  

八、配置开机自启动

  

如果客户要求开机自启动数据库

su - oracle

mkdir /home/oracle/scripts/ -p

  

vi /home/oracle/scripts/startupdb.sh

startupdb.sh脚本内容如下：

  

#scripts startupdb.sh #####################################

  

#!/bin/bash

source ~/.bash_profile

lsnrctl start

echo "startup" |tee /home/oracle/scripts/startupdb.sql

echo "quit" |tee -a /home/oracle/scripts/startupdb.sql

sqlplus / as sysdba @/home/oracle/scripts/startupdb.sql

  

#scripts startupdb.sh #####################################

  

编辑开机启动任务：

su - root

vi /etc/rc.local

尾行加入：

su - oracle -c '/bin/bash /home/oracle/scripts/startupdb.sh'

  

九、配置rman自动备份

  

关于crontab命令请自行百度。

  

 记得修改ORACE_SID 和备份文件名称

[oracle@his01 ~]$crontab –l ----计划任务

0 23 * * 6 /home/oracle/scripts/rmanbackup0.sh ----每周六做0级全备

0 23 * * 0,1,2,3,4,5 /home/oracle/scripts/rmanbackup1.sh ----其他时间做1级备份

  

[oracle@his01 ~]$cat /home/oracle/scripts/rmanbackup0.sh

#!/bin/sh

DATE=`date +%Y-%m-%d`

export ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1

export ORACLE_BASE=/u01/app/oracle

export ORACLE_SID=orcl

/u01/app/oracle/product/11.2.0/dbhome_1/bin/rman cmdfile
/home/oracle/scripts/backup0.sh log=/home/oracle/scripts/log_rman_$DATE

  

[oracle@his01 ~]$cat /home/oracle/scripts/rmanbackup1.sh

#!/bin/sh

DATE=`date +%Y-%m-%d`

export ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1

export ORACLE_BASE=/u01/app/oracle

export ORACLE_SID=dzyyhis1

/u01/app/oracle/product/11.2.0/dbhome_1/bin/rman cmdfile
/home/oracle/scripts/backup1.sh log=/home/oracle/scripts/log_rman_$DATE

  

[oracle@his01 ~]$cat /home/oracle/scripts/backup1.sh

connect target

run

{

allocate channel d1 type disk;

backup incremental level 1 format '/rmanbackup/orcl_inc_%U' database;

sql 'alter system archive log current';

backup format '/rmanbackup/orcl_arch_inc_%U' archivelog all delete input;

crosscheck backup;

delete noprompt expired backup;

delete noprompt obsolete;

release channel d1;

}

  

[oracle@his01 ~]$cat /home/oracle/scripts/backup0.sh

connect target

run

{

allocate channel d1 type disk;

backup incremental level 0 format '/rmanbackup/orcl_full_%U' database include
current controlfile;

sql 'alter system archive log current';

backup format '/rmanbackup/orcl_arch_full_%U' archivelog all delete input;

crosscheck backup;

delete noprompt expired backup;

delete noprompt obsolete;

release channel d1;

}

  

注意脚本权限的修改

  

chmod +x /home/oracle/scripts/rmanbackup1.sh

chmod +x /home/oracle/scripts/rmanbackup0.sh


---
### NOTE ATTRIBUTES
>Created Date: 2016-11-23 01:59:06  
>Last Evernote Update Date: 2017-05-05 05:39:32  
>author: YangKwong  
>source: desktop.win  
>source-url: https://www.zhihu.com/question/20065273  
>source-application: evernote.win32  