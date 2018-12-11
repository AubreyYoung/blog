# 10g_linux5.8单机数据库安装、升级步骤

  

配置静态IP地址

#setup    设置IP

#service network restart  重启network服务

修改/etc/hosts

  

添加ip地址解析：

192.168.222.222      gjywdb1  

检查selinux：

因为SELINUX对oracle有影响，所以把secure linux设成无效，编辑文件 /etc/selinux/config :

SELINUX=disabled

当然你也可以用图形界面下的工具 (系统 > 管理 > 安全级别和防火墙)。选择SELinux页面并且设为无效。

本地YUM

mount /dev/sr0 /mnt

vi  /etc/yum.repos.d

[root@csdb yum.repos.d]# cat rhel.repo

[rhel]

name=rhel

baseurl=file:///mnt/Server

enabled=1

gpgcheck=0

删除/etc/yum.repos.d/下的其他配置文件

yum install  setarch-2*   make-3*  glibc-2*  libaio-0* compat-libstdc++-33-3*
compat-gcc-34-3*  compat-gcc-34-c++-3*  gcc-4*  libXp-1* openmotif-2*  compat-
db-4*  glibc-devel-*   glibc-devel-*  -y



修改内核参数

  

#vi /etc/sysctl.conf

增加下面的内容到文件中：

kernel.shmmni = 4096

kernel.sem = 250 32000 100 128

fs.file-max = 101365

net.ipv4.ip_local_port_range =1024 65000

net.core.rmem_default=1048576

net.core.rmem_max=1048576

net.core.wmem_default=262144

net.core.wmem_max=262144

运行下面的命令使得内核参数生效：

  

/sbin/sysctl –p

建立安装Oracle需要的用户，组，及目录

  

a)新增组和用户：

groupadd oinstall

groupadd dba

useradd -g oinstall -G dba oracle

passwd oracle

  

密码：oracle@123

  

b) 创建Oracle的安装目录，并把权限付给oracle用户：

mkdir -p /u01/app/oracle/product/10.2.0/db_1

chown -R oracle.oinstall /u01

设置oracle用户的shell limit

  

#vi /etc/security/limits.conf

增加下面的内容到文件 /etc/security/limits.conf 文件中：

oracle  soft    nproc   2047

oracle  hard    nproc   16384

oracle  soft    nofile  1024

oracle  hard    nofile  65536

  

增加下面的内容到文件 /etc/pam.d/login 中，使shell limit生效：

session required /lib/security/pam_limits.so

配置oracle用户的环境变量

  

登录到oracle 用户并且配置环境变量，编辑/home/oracle目录下的.bash_profile文件

vi .bash_profile

增加下面的内容到文件 .bash_profile

# Oracle Settings

 export ORACLE_SID=cedb

 export ORACLE_BASE=/u01/app/oracle

 export ORACLE_HOME=$ORACLE_BASE/product/10.2.0/db_1

 export PATH=$ORACLE_HOME/bin:$PATH:$HOME/BIN

修改完用：source .bash_profile生效。

添加你的机器oracle用户可以使用图形化界面开始安装：

  

  

cpio -idmv < 10201_database_linux_x86_64.cpio

# xhost +           #转到图形化界面

# su - oracle                         #切换到oracle用户

$ export LANG=C                        #设置运行语言

$ cd /home/database     #进入解压路径

$ ./runInstaller  -ignoreSysPreReqs         #进入安装界面

Netca

Dbca

# 升级过程:

查询timezone问题

SELECT version FROM v$timezone_file;

2

  select c.owner || '.' || c.table_name || '(' || c.column_name || ') -' ||

 c.data_type || ' ' col

     from dba_tab_cols c, dba_objects o

    where c.data_type like '%TIME ZONE'

       and c.owner=o.owner

      and c.table_name = o.object_name

      and o.object_type = 'TABLE'

   order by col

   /

无业务用户对象。



关闭数据库

shutdown immediate

关闭监听

lsnrctl stop

备份数据库的软件目录

cp -a /u01/app/oracle/product/10.2.0/db_1
/u01/app/oracle/product/10.2.0/db_1.bak

解压10.2.0.5补丁程序

安装补丁程序./runInstaller

升级检查

Start the database in the UPGRADE mode:

  1. SQL> STARTUP UPGRADE
  2. Set the system to spool results to a log file for later analysis:
  3. SQL> SPOOL upgrade_info.log
  4. Run the Pre-Upgrade Information Tool:
  5. SQL> @?/rdbms/admin/utlu102i.sql
  6. Turn off the spooling of script results to the log file:
  7. SQL> SPOOL OFF

shutdown immediate

更新数据字典

  1. SQL> STARTUP UPGRADE
  2. SQL> SPOOL patch.log
  3. SQL> @?/rdbms/admin/catupgrd.sql

SQL> SPOOL OFF

编译无效对象

  1. SQL> SHUTDOWN IMMEDIATE
  2. SQL> STARTUP
  3. SQL> @?/rdbms/admin/utlrp.sql

业务程序进行测试。

回退机制：

如果软件升级和数据库升级失败，可以通过升级前的异地冷备份文件进行恢复。

部署RMAN备份脚本

Rman

2、 /u01目录扩展后对系统做了一次全备，并检查相应脚本

 [oracle@his01 ~]$crontab –l         \---计划任务

0 23 * * 6 /home/oracle/scripts/rmanbackup0.sh    \----每周六做0级全备

0 23 * * 0,1,2,3,4,5 /home/oracle/scripts/rmanbackup1.sh   \----其他时间做1级备份

注意脚本权限的修改

[oracle@his01 ~]$cat /home/oracle/scripts/rmanbackup0.sh  

#!/bin/sh

DATE=`date +%Y-%m-%d`

export ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1

export ORACLE_BASE=/u01/app/oracle

export ORACLE_SID=orcl

/u01/app/oracle/product/11.2.0/db_1/bin/rman cmdfile
/home/oracle/scripts/backup0.sh log=/home/oracle/scripts/log_rman_$DATE

[oracle@his01 ~]$cat /home/oracle/scripts/rmanbackup1.sh

#!/bin/sh

DATE=`date +%Y-%m-%d`

export ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1

export ORACLE_BASE=/u01/app/oracle

export ORACLE_SID=dzyyhis1

/u01/app/oracle/product/11.2.0/db_1/bin/rman cmdfile
/home/oracle/scripts/backup1.sh log=/home/oracle/scripts/log_rman_$DATE

[oracle@his01 ~]$cat /home/oracle/scripts/backup1.sh

connect target

run

{

allocate channel d1 type disk;

backup incremental level 1 format '/rmanbak/orcl_inc_%U' database;

backup format '/rmanbak/orcl_arch_inc_%U' archivelog all delete input;

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

backup incremental level 0 format '/rmanbak/orcl_full_%U' database include
current controlfile;

backup format '/rmanbak/orcl_arch_full_%U' archivelog all delete input;

crosscheck backup;

delete noprompt expired backup;

delete noprompt obsolete;

release channel d1;

}

大页内存

##

##  

SCRIPT

\------------------------------------------------------------------------------------------------------------------------

  

#!/bin/bash

#

# hugepages_settings.sh

#

# Linux bash script to compute values for the

# recommended HugePages/HugeTLB configuration

#

# Note: This script does calculation for all shared memory

# segments available when the script is run, no matter it

# is an Oracle RDBMS shared memory segment or not.

#

# This script is provided by Doc ID 401749.1 from My Oracle Support

# http://support.oracle.com

  

# Welcome text

echo "

This script is provided by Doc ID 401749.1 from My Oracle Support

(http://support.oracle.com) where it is intended to compute values for

the recommended HugePages/HugeTLB configuration for the current shared

memory segments. Before proceeding with the execution please note following:

 * For ASM instance, it needs to configure ASMM instead of AMM.

 * The 'pga_aggregate_target' is outside the SGA and 

   you should accommodate this while calculating SGA size.

 * In case you changes the DB SGA size, 

   as the new SGA will not fit in the previous HugePages configuration,

   it had better disable the whole HugePages,

   start the DB with new SGA size and run the script again.

And make sure that:

 * Oracle Database instance(s) are up and running

 * Oracle Database 11g Automatic Memory Management (AMM) is not setup 

   (See Doc ID 749851.1)

 * The shared memory segments can be listed by command:

     # ipcs -m

  

  

Press Enter to proceed..."

  

read

  

# Check for the kernel version

KERN=`uname -r | awk -F. '{ printf("%d.%d\n",$1,$2); }'`

  

# Find out the HugePage size

HPG_SZ=`grep Hugepagesize /proc/meminfo | awk '{print $2}'`

if [ -z "$HPG_SZ" ];then

    echo "The hugepages may not be supported in the system where the script is being executed."

    exit 1

fi

  

# Initialize the counter

NUM_PG=0

  

# Cumulative number of pages required to handle the running shared memory
segments

for SEG_BYTES in `ipcs -m | cut -c44-300 | awk '{print $1}' | grep
"[0-9][0-9]*"`

do

    MIN_PG=`echo "$SEG_BYTES/($HPG_SZ*1024)" | bc -q`

    if [ $MIN_PG -gt 0 ]; then

        NUM_PG=`echo "$NUM_PG+$MIN_PG+1" | bc -q`

    fi

done

  

RES_BYTES=`echo "$NUM_PG * $HPG_SZ * 1024" | bc -q`

  

# An SGA less than 100MB does not make sense

# Bail out if that is the case

if [ $RES_BYTES -lt 100000000 ]; then

    echo "***********"

    echo "** ERROR **"

    echo "***********"

    echo "Sorry! There are not enough total of shared memory segments allocated for 

HugePages configuration. HugePages can only be used for shared memory segments

that you can list by command:

  

    # ipcs -m

  

of a size that can match an Oracle Database SGA. Please make sure that:

 * Oracle Database instance is up and running 

 * Oracle Database 11g Automatic Memory Management (AMM) is not configured"

    exit 1

fi

  

# Finish with results

case $KERN in

    '2.2') echo "Kernel version $KERN is not supported. Exiting." ;;

    '2.4') HUGETLB_POOL=`echo "$NUM_PG*$HPG_SZ/1024" | bc -q`;

           echo "Recommended setting: vm.hugetlb_pool = $HUGETLB_POOL" ;;

    '2.6') echo "Recommended setting: vm.nr_hugepages = $NUM_PG" ;;

    '3.8') echo "Recommended setting: vm.nr_hugepages = $NUM_PG" ;;

esac

  

# End

开机自启动数据库

    [oracle@hvrhub hub]$ cat /etc/oratab 

  

    hub:/u01/app/oracle/product/11.2.0/dbhome_1:Y 



    [oracle@hvrhub hub]$ cat /etc/rc.local  

    #!/bin/sh 

    # 

    # This script will be executed *after* all the other init scripts. 

    # You can put your own initialization stuff in here if you don't 

    # want to do the full Sys V style init stuff. 

     

    touch /var/lock/subsys/local 

     

    su - oracle -c 'dbstart' 

    su - oracle -c 'lsnrctl start' 

    [oracle@hvrhub hub]$  


---
### NOTE ATTRIBUTES
>Created Date: 2016-11-23 02:13:19  
>Last Evernote Update Date: 2017-12-18 13:07:46  
>author: YangKwong  
>source: desktop.win  
>source-application: evernote.win32  