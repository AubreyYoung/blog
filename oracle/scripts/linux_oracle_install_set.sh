#!/usr/bin/env bash
#set -x

#define oracle install dir
oracle_dir="/u01"

if [ -z $oracle_dir ];then
    echo "your need define oracle install PATH,please open this setting oracle_dir variables"
    exit 0
fi

#Echo text color
function cecho ()
{
export red='\E[31m\c'
export green='\E[32m\c'
export white='\E[37m\c'


message=$1
color=${2:-$white}
echo -e "$color"
echo -e "$message"
tput sgr0
echo -e "$white"
return
}

#安装包检测，改用oracle-rdbms-server-11gR2-preinstall
#Check rpm package installed
#yum install -y  unixODBC unixODBC-devel
#rpm -q ksh compat-libstdc++-33 elfutils-libelf glibc glibc-common glibc-devel gcc gcc-c++ libaio-devel libaio libgcc libstdc++ libstdc++-devel make sysstat unixODBC unixODBC-devel | grep "not installed"
#if [ $? -eq 0 ];then
# exit 0
#fi


#addgroup
#groups oracle
#oracle : oinstall dba oper asmadmin asmdba
#Create user and group
function add_group(){
  grep "$1" /etc/group >/dev/null
  if [ $? -ne 0 ];then
    groupadd $1
    cecho "\c"
    cecho "addgroup -g $2 $1" $green
    cecho "\c"
  fi
}
add_group oinstall 5001
add_group dba 5002
add_group oper 5003
#add_group asmadmin 5004
#add_group asmoper 5005
#add_group asmdba 5006


#useradd oracle
id oracle >/dev/null
if [ $? -ne 0 ];then
  #useradd -u 5001 -g oinstall -G asmadmin,asmdba,dba,oper oracle
  useradd -u 5001 -g oinstall -G dba,oper oracle
  cecho "\c"
  cecho "adduser oracle" $green
  cecho "\c"
else
  #usermod -g oinstall -G asmadmin,asmdba,dba,oper oracle
  usermod -g oinstall -G dba,oper oracle
fi
passwd oracle


#创建目录
chown -R oracle:oinstall $oracle_dir
chmod -R 775 $oracle_dir

#error: "net.bridge.bridge-nf-call-ip6tables" is an unknown key
#error: "net.bridge.bridge-nf-call-iptables" is an unknown key
#error: "net.bridge.bridge-nf-call-arptables" is an unknown key
#解决方法
#modprobe bridge
modprobe bridge

#Add system variables in the /etc/sysctl.conf
#egrep "kernel.sem|net.ipv4.ip_local_port_range|fs.file-max|net.core.wmem_default|net.core.wmem_max|net.core.rmem_default|net.core.rmem_max|fs.aio-max-nr|kernel.shmmni|vm.min_free_kbytes|vm.vfs_cache_pressure|vm.swappiness" /etc/sysctl.conf 
function sed_sysctl(){
    VALUE=$(grep "^[ ]*$1" /etc/sysctl.conf | awk -F"[ ]*=[ ]*" '{print $2}')   
    if [ "-$VALUE" = "-" ]; then
      echo "$1 = $2">>/etc/sysctl.conf
      echo "$1 = $2:add"
    elif [ "-$VALUE" = "-$2" ]; then
      echo "$1 = $2:valid"
    else
      sed -i "s/^[ ]*$1.*$/$1=$2/g" /etc/sysctl.conf
      echo "$1 = $2:change"    
    fi
}
sed_sysctl "fs.file-max" "6815744"
sed_sysctl "kernel.sem" "250 32000 100 128"
sed_sysctl "kernel.shmmni" "4096"
sed_sysctl "net.core.rmem_default" "262144"
sed_sysctl "net.core.rmem_max" "4194304"
sed_sysctl "net.core.wmem_default" "262144"
sed_sysctl "net.core.wmem_max" "1048576"
sed_sysctl "fs.aio-max-nr" "1048576"
sed_sysctl "net.ipv4.ip_local_port_range" "9000 65500"

sed_sysctl "vm.min_free_kbytes" "51200"
sed_sysctl "vm.vfs_cache_pressure" "200"
sed_sysctl "vm.swappiness" "0"

/sbin/sysctl -p>/dev/null
if [ $? -ne 0 ];then
     cecho "\c"
     cecho "Edit sysctl.conf $1 failure" $red
     cecho "\c"
     exit 0
else
     cecho "\c"
     cecho "Edit sysctl.conf sucessfull" $green
     cecho "\c"
fi

#Add variables in the /etc/security/limits.conf
function modify_limits(){
    VALUE=$(grep "^[ ]*$1.*$2.*$3" /etc/security/limits.conf | awk -F" *" '{print $4}')
    if [ "-$VALUE" = "-" ];then
      echo "$1 $2 $3 $4" >>/etc/security/limits.conf
      echo "$1 $2 $3 $4 :add"
    elif [ "-$VALUE" = "-$4" ];then
      echo "$1 $2 $3 $4 :valid"
    elif [ "-$VALUE" != "-$4" ];then
      sed -i "s/^[ ]*$1.*$2.*$3.*$/$1 $2 $3 $4/g" /etc/security/limits.conf
      echo "$1 $2 $3 $4 :change"
    fi
}
modify_limits "oracle" "soft" "nofile" "1024"
modify_limits "oracle" "hard" "nofile" "65536"
modify_limits "oracle" "soft" "nproc" "16384"
modify_limits "oracle" "hard" "nproc" "16384"
modify_limits "oracle" "soft" "stack" "10240"
modify_limits "oracle" "hard" "stack" "32768"

grep "nofile" /etc/security/limits.conf >/dev/null
if [ $? -eq 0 ];then
    cecho "\c"
    cecho "Add variables in the /etc/security/limits.conf " $green
    cecho "\c"
fi

#用户界面安全设置
grep "pam_limits.so" /etc/pam.d/login >/dev/null
if [ $? -ne 0 ];then
    echo "session    required     pam_limits.so">>/etc/pam.d/login
fi

#Add variables in the /etc/profile
grep "oracle" /etc/profile >/dev/null
if [ $? -ne 0 ];then
    echo "if [ \$USER = \"oracle\" ]; then">>/etc/profile
    echo "    if [ \$SHELL = \"/bin/ksh\" ]; then">>/etc/profile
    echo "        ulimit -p 16384">>/etc/profile
    echo "        ulimit -n 65536">>/etc/profile
    echo "    else">>/etc/profile
    echo "        ulimit -u 16384 -n 65536">>/etc/profile
    echo "    fi">>/etc/profile
    echo "        umask 022">>/etc/profile
    echo "fi">>/etc/profile
    cecho "\c"
    cecho "Add variables in the /etc/profile " $green
    cecho "\c" 
fi

#Add env variables in the ~oracle/.bash_profile
grep "ORACLE_SID" ~oracle/.bash_profile >/dev/null
if [ $? -ne 0 ];then
    sed -i "s/^PATH=\$PATH:\$HOME\/bin$//g" ~oracle/.bash_profile
    sed -i "s/^export\ PATH$//g" ~oracle/.bash_profile
    echo "export ORACLE_BASE=$oracle_dir/app/oracle">>~oracle/.bash_profile
    echo "export ORACLE_HOME=\$ORACLE_BASE/product/11.2.0/dbhome_1">>~oracle/.bash_profile
    echo "export ORACLE_PATH=\$ORALCE_BASE/common/oracle/sql:.:\$ORACLE_HOME/rdbms/admin">>~oracle/.bash_profile
    echo "export ORACLE_SID=orcl">>~oracle/.bash_profile
    echo "export PATH=\$ORACLE_HOME/bin:\$ORA_CRS_HOME/bin:\${PATH}:\$HOME/bin">>~oracle/.bash_profile
    echo "export PATH=\${PATH}:/usr/bin:/bin:/usr/bin/X11:/usr/local/bin">>~oracle/.bash_profile
    echo "export PATH=\${PATH}:\$ORACLE_BASE/common/oracle/bin">>~oracle/.bash_profile
    echo "export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK">>~oracle/.bash_profile
    cecho "\c"
    cecho "Add env variables in the ~oracle/.bash_profile" $green
    cecho "\c" 
fi

#关掉本地时间服务器
/sbin/service nptd stop
chkconfig ntpd off
rm -rf /etc/ntp.conf


#关掉防火墙
chkconfig iptables off
service iptables stop

#禁止SELINUX
sed -i 's/^ *SELINUX *=.*$/SELINUX=disabled/g' /etc/selinux/config
setenforce 0
