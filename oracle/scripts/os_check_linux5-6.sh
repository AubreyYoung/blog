#!/bin/bash
echo "+----------------------------------------------------------------------------+"
echo "|                      You are logged in as `whoami`                             |"
echo "+----------------------------------------------------------------------------+"
echo "|          Copyright (c) 2018-2019 . Inspur All rights reserved.             |"
echo "+----------------------------------------------------------------------------+"
if [ `whoami` != root ]; then
echo "Must be logged on as root user to run this script."
exit
fi
CHECK_DATE=`date +%F`
echo "+----------------------------------------------------------------------------+"
echo "|        Running OS Check Script at `date`             | "        
echo "+----------------------------------------------------------------------------+"             
echo ""
sleep 2
echo "+----------------------------------------------------------------------------+"
echo "|                 Important!!! Something you need to know!                   |"        
echo "+----------------------------------------------------------------------------+"  
echo "|When this script is executing,if the result shows something like following: |"
echo -e "|    \033[01m \033[05m 'xxx: unrecognized service' \033[0m                                          |"
echo "|    or                                                                      |"
echo -e "|    \033[01m \033[05m 'xxx: No such file or directory'  \033[0m                                    |"
echo "|    or                                                                      |"
echo -e "|    \033[01m \033[05m 'xxx: command not found' \033[0m                                             |"
echo "|    This is not an error,it's normal.                                       |"
echo "|    It may be due to some check commands not suitable for                   |"
echo "|                     the current operating system version.                  |"
echo -e "|    \033[01m \033[05m So you can ignore it!  \033[0m                                               |"
echo -e "|    \033[01m \033[05m    you can ignore it!!  \033[0m                                              |"
echo -e "|    \033[01m \033[05m    you can ignore it!!! \033[0m                                              |"
echo "|    Or you can update this script's commands to suite for the current OS.   |"
echo "|    We will gradually improve such issues in later version.                 |"
echo "+----------------------------------------------------------------------------+" 
sleep 30
echo ""
echo "+----------------------------------------------------------------------------+"
echo "|                      OS Health Check is running...                         |"        
echo "+----------------------------------------------------------------------------+" 
sleep 5
echo ""
echo "+----------------------------------------------------------------------------+" 
echo "|                                                                            |"
echo "|           The following results may can be ignored, please confirm!        |"
echo "|                                                                            |"
echo ""
CURRENT_DIR=`pwd`
HOST=`hostname`
CHECK_LOG=$CURRENT_DIR/Inspur_OS_Check_$HOST\_$CHECK_DATE.txt
###################
echo 1. $HOST-Hostname >$CHECK_LOG  
echo "# hostname" >>$CHECK_LOG  
echo $HOST >>$CHECK_LOG  
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                                \n">>$CHECK_LOG  
###################
echo 2. $HOST-OS Time >>$CHECK_LOG  
echo "# date -R" >>$CHECK_LOG  
date -R >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "# more /etc/sysconfig/clock" >>$CHECK_LOG  
more /etc/sysconfig/clock >>$CHECK_LOG  
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                                \n">>$CHECK_LOG  
###################
echo 3. $HOST-OS Start Time and Last reboot >>$CHECK_LOG  
echo "# uptime" >>$CHECK_LOG  
uptime >>$CHECK_LOG  
echo "# last reboot" >>$CHECK_LOG  
last reboot >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                                \n">>$CHECK_LOG  
###################
echo 3. $HOST-Hardware Vendor and Model >>$CHECK_LOG  
echo "# dmidecode | grep 'Product Name'" >>$CHECK_LOG  
dmidecode | grep 'Product Name' >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "# dmidecode |grep 'Serial Number'" >>$CHECK_LOG  
dmidecode |grep 'Serial Number' >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "# dmidecode -s system-serial-number" >>$CHECK_LOG  
dmidecode -s system-serial-number >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "# dmidecode -t 11" >>$CHECK_LOG  
dmidecode -t 11 >>$CHECK_LOG  
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                                \n">>$CHECK_LOG  
###################
echo 4. $HOST-OS Service Status >>$CHECK_LOG  
echo "# service NetworkManager status" >>$CHECK_LOG  
service NetworkManager status >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "# service avahi-daemon status" >>$CHECK_LOG  
service avahi-daemon status >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "# service iptables status" >>$CHECK_LOG  
service iptables status >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "# service sendmail status" >>$CHECK_LOG  
service sendmail status >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "# service cpuspeed status" >>$CHECK_LOG  
service cpuspeed status >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "# service ntpd status" >>$CHECK_LOG  
service ntpd status >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "# cat /etc/sysconfig/ntpd" >>$CHECK_LOG  
cat /etc/sysconfig/ntpd >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "# ps -ef |grep osw" >>$CHECK_LOG  
ps -elf |grep osw >>$CHECK_LOG 
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                             \n">>$CHECK_LOG  
###################
echo 5. $HOST-NUMA Check >>$CHECK_LOG  
echo "# numactl --hardware" >>$CHECK_LOG  
numactl --hardware >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "# numactl --show" >>$CHECK_LOG  
numactl --show >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "# grep -i numa /var/log/dmesg returns" >>$CHECK_LOG  
grep -i numa /var/log/dmesg returns >>$CHECK_LOG  
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                                \n">>$CHECK_LOG  
###################
echo 6. $HOST-OS HugePage Check >>$CHECK_LOG  
echo "# grep Huge /proc/meminfo" >>$CHECK_LOG  
grep Huge /proc/meminfo >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "# cat /sys/kernel/mm/redhat_transparent_hugepage/enabled" >>$CHECK_LOG  
cat /sys/kernel/mm/redhat_transparent_hugepage/enabled >>$CHECK_LOG  
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                                \n">>$CHECK_LOG  
###################
echo 7. $HOST-OS Version >>$CHECK_LOG  
echo "# uname -a" >>$CHECK_LOG  
uname -a >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "# cat /etc/redhat-release" >>$CHECK_LOG  
cat /etc/redhat-release >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "# cat /etc/issue" >>$CHECK_LOG  
cat /etc/issue >>$CHECK_LOG  
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                                \n">>$CHECK_LOG  
###################
echo 8. $HOST-Network Info >>$CHECK_LOG  
echo "# netstat -rn" >>$CHECK_LOG  
netstat -rn >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "# netstat -su" >>$CHECK_LOG  
netstat -su >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "# ifconfig -a" >>$CHECK_LOG  
ifconfig -a >>$CHECK_LOG  
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                                \n">>$CHECK_LOG  
###################
echo 9. $HOST-Network IP Set >>$CHECK_LOG  
echo "# cat /etc/hosts" >>$CHECK_LOG  
cat /etc/hosts >>$CHECK_LOG  
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                                \n">>$CHECK_LOG  
###################
echo 10. $HOST-File System Usage \(df -h\) >>$CHECK_LOG  
echo "# df -h" >>$CHECK_LOG  
df -h >>$CHECK_LOG  
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                                \n">>$CHECK_LOG  
###################
echo 11. $HOST-File System Inode Usage \(df -i\) >>$CHECK_LOG  
echo "# df -i" >>$CHECK_LOG  
df -i >>$CHECK_LOG  
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                                \n">>$CHECK_LOG  
###################
echo 12. $HOST-Log Size >>$CHECK_LOG  
echo "(1) listener log size" >>$CHECK_LOG  
echo "# find / -iname "*listener*.log*" | xargs du -h" >>$CHECK_LOG  
find / -iname "*listener*.log*" | xargs du -h >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "(2) alert log size" >>$CHECK_LOG  
echo "# find / -iname "alert*.log*" | xargs du -h" >>$CHECK_LOG  
find / -iname "alert*.log*" | xargs du -h >>$CHECK_LOG  
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                                \n">>$CHECK_LOG  
###################
echo 13. $HOST-Memory Usage >>$CHECK_LOG  
echo "# vmstat" >>$CHECK_LOG  
vmstat 2 5 >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "# free -m" >>$CHECK_LOG  
free -m >>$CHECK_LOG  
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                                \n">>$CHECK_LOG  
###################
echo 14. $HOST-CPU Info >>$CHECK_LOG  
echo "(1) how many physical cpus?" >>$CHECK_LOG  
echo "# cat /proc/cpuinfo |grep "physical id"|sort |uniq|wc -l" >>$CHECK_LOG  
cat /proc/cpuinfo |grep "physical id"|sort |uniq|wc -l >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "(2) how many logical cpus?" >>$CHECK_LOG  
echo "# cat /proc/cpuinfo |grep "processor"|wc -l" >>$CHECK_LOG  
cat /proc/cpuinfo |grep "processor"|wc -l >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "(3) cpu cores" >>$CHECK_LOG  
echo "# cat /proc/cpuinfo |grep "cores"|uniq" >>$CHECK_LOG  
cat /proc/cpuinfo |grep "cores"|uniq >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "(4) cpu MHz" >>$CHECK_LOG  
echo "# cat /proc/cpuinfo |grep MHz|uniq" >>$CHECK_LOG  
cat /proc/cpuinfo |grep MHz|uniq  >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "(5) cpu type" >>$CHECK_LOG  
echo "# cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c" >>$CHECK_LOG  
cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c >>$CHECK_LOG  
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                                \n">>$CHECK_LOG  
###################
echo 15. $HOST-User Environment Set >>$CHECK_LOG  
echo "root env" >>$CHECK_LOG  
echo ---------------------------------------------------- >>$CHECK_LOG  
env >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
id oracle >& /dev/null
if [ $? == 0 ]; then
echo "oracle env" >>$CHECK_LOG  
echo ---------------------------------------------------- >>$CHECK_LOG  
su - oracle -c "env" >>$CHECK_LOG  
fi
echo "" >>$CHECK_LOG  
id grid >& /dev/null
if [ $? == 0 ]; then
echo "grid env" >>$CHECK_LOG  
echo ---------------------------------------------------- >>$CHECK_LOG  
su - grid -c "env" >>$CHECK_LOG  
fi
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                                \n">>$CHECK_LOG  
id oracle >& /dev/null
if [ $? == 0 ]; then
echo "# cat /home/oracle/.bash_profile" >>$CHECK_LOG  
cat /home/oracle/.bash_profile >>$CHECK_LOG  
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                                \n">>$CHECK_LOG  
fi
id grid >& /dev/null
if [ $? == 0 ]; then
echo "# cat /home/grid/.bash_profile" >>$CHECK_LOG  
cat /home/grid/.bash_profile >>$CHECK_LOG  
fi
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                                \n">>$CHECK_LOG  
###################
echo 16. $HOST-OS User crontab >>$CHECK_LOG  
echo "(1)root crontab" >>$CHECK_LOG  
echo "# crontab -l" >>$CHECK_LOG  
crontab -l >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
id oracle >& /dev/null
if [ $? == 0 ]; then
echo "(2)oracle crontab" >>$CHECK_LOG  
echo "# su - oracle -c 'crontab -l'" >>$CHECK_LOG  
su - oracle -c "crontab -l" >>$CHECK_LOG  
fi
echo "" >>$CHECK_LOG  
id grid >& /dev/null
if [ $? == 0 ]; then
echo "(3)grid crontab" >>$CHECK_LOG  
echo "# su - grid -c 'crontab -l'" >>$CHECK_LOG  
su - grid -c "crontab -l" >>$CHECK_LOG  
fi
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                                \n">>$CHECK_LOG  
###################
echo 17. $HOST-\1\0gR2 rpms >>$CHECK_LOG  
echo "# rpm -q binutils compat-db compat-libstdc++-296 compat-libstdc++-33 control-center gcc glibc glibc-common  glibc-devel glibc-headers ksh libgcc libstdc++ libstdc++-devel libgnome libgnomeui libaio libgomp libXp libXext libXtst make sysstat" >>$CHECK_LOG  
rpm -q binutils compat-db compat-libstdc++-296 compat-libstdc++-33 control-center gcc glibc glibc-common  glibc-devel glibc-headers ksh libgcc libstdc++ libstdc++-devel libgnome libgnomeui libaio libgomp libXp libXext libXtst  make sysstat >>$CHECK_LOG  
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                                \n">>$CHECK_LOG  
###################
echo 18. $HOST-11gR2 rpms >>$CHECK_LOG  
echo "# rpm -q binutils compat-libstdc++-33 elfutils-libelf  gcc gcc-c++ glibc  glibc-devel glibc-headers glibc-common ksh kernel-headers libaio libaio-devel libgcc libstdc++  libstdc++-devel libgomp make sysstat unixODBC unixODBC-devel" >>$CHECK_LOG  
rpm -q binutils compat-libstdc++-33 elfutils-libelf  gcc gcc-c++ glibc  glibc-devel glibc-headers glibc-common ksh kernel-headers libaio libaio-devel libgcc libstdc++  libstdc++-devel libgomp make sysstat unixODBC unixODBC-devel >>$CHECK_LOG  
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                                \n">>$CHECK_LOG  
###################
cat /etc/redhat-release |grep 6 >& /dev/null
if [ $? -ne 0 ]; then
echo 19. $HOST-Linux Kernel Parameter and limits.conf >>$CHECK_LOG  
echo "# cat /etc/sysctl.conf" >>$CHECK_LOG  
cat /etc/sysctl.conf >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "# sysctl -a" >>$CHECK_LOG  
sysctl -a >>$CHECK_LOG  
echo "" >>$CHECK_LOG 
echo "# cat /etc/security/limits.conf" >>$CHECK_LOG 
cat /etc/security/limits.conf >>$CHECK_LOG
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                                \n">>$CHECK_LOG  
else
###################
echo 19. $HOST-Linux Kernel Parameter and limits.conf >>$CHECK_LOG 
echo "# cat /etc/sysctl.conf" >>$CHECK_LOG  
cat /etc/sysctl.conf >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "# sysctl -a" >>$CHECK_LOG  
sysctl -a >>$CHECK_LOG   
echo "" >>$CHECK_LOG  
echo "# cat /etc/security/limits.conf" >>$CHECK_LOG 
cat /etc/security/limits.conf >>$CHECK_LOG
echo "" >>$CHECK_LOG  
echo "# /etc/security/limits.d/90-nproc.conf" >>$CHECK_LOG 
cat /etc/security/limits.d/90-nproc.conf >>$CHECK_LOG
echo "" >>$CHECK_LOG  
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                       \n">>$CHECK_LOG
fi
###################
id grid >& /dev/null
if [ $? -ne 0 ]; then
echo 20. $HOST-10g RAC Status >>$CHECK_LOG  
echo "# id oracle" >>$CHECK_LOG  
id oracle >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "# su - oracle -c 'crs_stat -t'" >>$CHECK_LOG  
su - oracle -c "crs_stat -t" >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "# su - oracle -c 'crsctl query css votedisk'" >>$CHECK_LOG  
su - oracle -c "crsctl query css votedisk" >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "# su - oracle -c 'ocrcheck'" >>$CHECK_LOG  
su - oracle -c "ocrcheck" >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "# su - oracle -c 'ocrconfig -showbackup'" >>$CHECK_LOG  
su - oracle -c "ocrconfig -showbackup" >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "# su - oracle -c \'srvctl config nodeapps -n $HOST -a\'" >>$CHECK_LOG  
su - oracle -c "srvctl config nodeapps -n $HOST -a" >>$CHECK_LOG  
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                                \n">>$CHECK_LOG  
else
###################
echo  20. $HOST-11g RAC Status >>$CHECK_LOG  
echo "# id oracle" >>$CHECK_LOG  
id oracle >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "# id grid" >>$CHECK_LOG  
id grid >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "# su - grid -c 'crsctl stat res -t'" >>$CHECK_LOG  
su - grid -c "crsctl stat res -t" >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "# su - grid -c 'crsctl query css votedisk'" >>$CHECK_LOG  
su - grid -c "crsctl query css votedisk" >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "# su - grid -c 'ocrcheck'" >>$CHECK_LOG  
su - grid -c "ocrcheck" >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "# su - grid -c 'ocrconfig -showbackup'" >>$CHECK_LOG  
su - grid -c "ocrconfig -showbackup" >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "# su - grid -c 'srvctl config vip -n $HOST'" >>$CHECK_LOG  
su - grid -c "srvctl config vip -n $HOST" >>$CHECK_LOG  
echo "" >>$CHECK_LOG  
echo "# su - grid -c 'oifcfg getif'" >>$CHECK_LOG  
su - grid -c "oifcfg getif" >>$CHECK_LOG  
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                             \n">>$CHECK_LOG  
fi
###################
echo 21. $HOST-Raw Info >>$CHECK_LOG  
echo "# ls -l /dev/raw/*" >>$CHECK_LOG  
ls -l /dev/raw/* >>$CHECK_LOG  
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                                \n">>$CHECK_LOG  
###################
echo 22. $HOST-Udev Bond Set >>$CHECK_LOG  
echo "# cat /etc/udev/rules.d/60-raw.rules" >>$CHECK_LOG  
cat /etc/udev/rules.d/60-raw.rules >>$CHECK_LOG  
echo "# **********99-asm-Inspur.rules/12-dm-permissions-Inspur.rules is only for specific racs;*********#" >>$CHECK_LOG  
echo "# ***************If your db is not use it,please ignore it.**************#" >>$CHECK_LOG  
echo ""
echo "# cat  /etc/udev/rules.d/99-asm-Inspur.rules" >>$CHECK_LOG  
cat  /etc/udev/rules.d/99-asm-Inspur.rules >>$CHECK_LOG  
echo ""
echo "# cat  /etc/udev/rules.d/12-dm-permissions-Inspur.rules" >>$CHECK_LOG  
cat /etc/udev/rules.d/12-dm-permissions-Inspur.rules >>$CHECK_LOG  
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                                \n">>$CHECK_LOG  
###################
echo 23. $HOST-/etc/rc.local >>$CHECK_LOG  
echo "# cat /etc/rc.local" >>$CHECK_LOG  
cat /etc/rc.local >>$CHECK_LOG  
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                                \n">>$CHECK_LOG  
###################
echo 24. $HOST-Multipath Set >>$CHECK_LOG  
echo "# multipath -ll" >>$CHECK_LOG  
multipath -ll >>$CHECK_LOG   
echo "" >>$CHECK_LOG  
echo "# cat /etc/multipath.conf" >>$CHECK_LOG  
cat /etc/multipath.conf >>$CHECK_LOG   
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                                \n">>$CHECK_LOG  
################### 
echo 25. $HOST-Disk I/O info >>$CHECK_LOG  
echo "# iostat -x 2 5" >>$CHECK_LOG  
iostat -x 2 5 >>$CHECK_LOG  
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                                \n">>$CHECK_LOG  
###################
echo 26. $HOST-Disk Info\ >>$CHECK_LOG  
echo "# fdisk -l" >>$CHECK_LOG  
fdisk -l >>$CHECK_LOG  
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                                \n">>$CHECK_LOG  
###################
echo 27. $HOST-User/Group Info\ >>$CHECK_LOG  
echo "# cat /etc/group" >>$CHECK_LOG  
cat /etc/group >>$CHECK_LOG  
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                                \n">>$CHECK_LOG  
###################
echo 28. $HOST-User Password Info\ >>$CHECK_LOG  
echo "# cat /etc/passwd" >>$CHECK_LOG  
cat /etc/passwd >>$CHECK_LOG  
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                                \n">>$CHECK_LOG  
###################
echo 29. $HOST-OS Messages\ >>$CHECK_LOG  
echo "# cat /etc/logrotate.conf" >>$CHECK_LOG  
echo ""  >>$CHECK_LOG  
cat /etc/logrotate.conf >>$CHECK_LOG  
echo "# tail -500 /var/log/messages" >>$CHECK_LOG 
echo ""  >>$CHECK_LOG  
tail -500 /var/log/messages >>$CHECK_LOG  
echo ""  >>$CHECK_LOG 
echo ""  >>$CHECK_LOG 
echo "# dmesg" >>$CHECK_LOG  
dmesg >>$CHECK_LOG  
echo ---------------------------------------------------- >>$CHECK_LOG  
echo -e "NOTE:                                                \n">>$CHECK_LOG 
echo "|                                                                            |"
echo "|                                                                            |" 
echo "+----------------------------------------------------------------------------+" 
echo ""
echo "+----------------------------------------------------------------------------+"
echo "|                               ***Ending!***                                | "  
echo "|                                                                            |" 
echo "|  Please download $CHECK_LOG.  |"        
echo "+----------------------------------------------------------------------------+"  
