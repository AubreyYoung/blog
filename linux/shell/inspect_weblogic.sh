#!/bin/sh
# Auth: liuyong@hthorizon.com
# Desc: Inspect weblogic server
# Create: 2016/07/07
# Version: v1.0

#set -x

getResource() {
arr=(
'date',
'lsb_release -a',
'cat /proc/cpuinfo | grep processor | wc -l',
'free -m',
'vmstat 2 5',
'df -h',
'java -version',
'fdisk -l',
'ifconfig -a',
'ps -ef | grep java | grep -v grep',
'id',
'uname -a',
'cat /proc/cpuinfo',
'cat /proc/meminfo',
'ulimit -a',
'top -n 1',
'top -n 1'
)

IFS_BAK=$IFS
IFS=,

for cmd in ${arr[*]}
do
	[ -z "$cmd" ] && continue
	echo -e "\n"
	echo "# $cmd"
	eval "$cmd 2>&1"
done

IFS=$IFS_BAK

}


getDomains() {
if [ -n "$1" ] ; then
	FIND_PATH="$1"
else
	WLS_HOME=`ps -ef | grep weblogic.home | grep -v grep | tr ' ' '\n' | grep weblogic.home | head -n 1 | cut -d "=" -f 2`
	if [ -n "$WLS_HOME" ] ; then
		FIND_PATH="$WLS_HOME/../.."
		if [ -f $FIND_PATH/domain-registry.xml ] ; then
			for i in `cat $FIND_PATH/domain-registry.xml | grep "domain location" | cut -d '"' -f 2`
			do
				echo -e "[Info] FIND DOMAIN FROM XML:$i" >&2
				echo $i
			done
			return;
		else
			FIND_PATH="/"
		fi
	else
		FIND_PATH="/"
	fi
fi

echo -e "[Info] FIND_PATH:$FIND_PATH" >&2

for i in `find $FIND_PATH -maxdepth 10 -type d -name "servers" 2>/dev/null`
do
	if [[ -f "$i/../config/config.xml" ]] ; then
		echo ${i:0:${#i}-8}
	fi
done
}


upload() {
NETSECTION=`echo $1 | cut -d . -f 3`
if [ "$NETSECTION" -eq 110 ] ; then
	FTP_SERV="192.168.110.239"
elif [ "$NETSECTION" -eq 101 ] ; then
	FTP_SERV="192.168.1.167"
elif [ "$NETSECTION" -eq 1 ] ; then
	FTP_SERV="192.168.1.167"
elif [ "$NETSECTION" -eq 8 ] ; then
	FTP_SERV="192.168.1.167"
fi

RPWD="/inspect"
LPWD="/tmp/HT"

ftp -n<<!
open $FTP_SERV
user test test
bin
prompt
cd $RPWD
lcd $LPWD
mput $1
ls
close
bye
!
}


# -------------------- Here we go --------------------


# 磁盘空间检查
SPACE_FREE=`df -m | grep -w "/tmp" | awk '{print $(NF-2)}'`
[ -z $SPACE_FREE ] && SPACE_FREE=`df -m | grep -w "/" | awk '{print $(NF-2)}'`
[ "$SPACE_FREE" -le 500 ] && echo "[Error] There is no enough space on /tmp or / [${SPACE_FREE}M]." && exit 1


# 获取IP信息
ADDR=`ifconfig | grep "192.168" | awk '{print $2}' | awk -F: '{print $2}'`
[ -z "$ADDR" ] && ADDR=`grep "IPADDR" /etc/sysconfig/network-scripts/ifcfg-eth0 | cut -d '=' -f 2`
[ -z "$ADDR" ] && echo "[Error] ifconfig error!" && exit 1


# 目标路径
HT_HOME="/tmp/HT"
mkdir -p $HT_HOME


# 收集资源信息
getResource | tee $HT_HOME/$ADDR.txt
[ $? -ne 0 ] && echo "[Error] getResouce() throws exception." && exit 1


# 收集日志、配置
echo -e "\n[Info] Now finding weblogic domain, this will take few seconds..." | tee -a $HT_HOME/$ADDR.txt
for DOMAIN_PATH in `getDomains $1`
do
	DOMAIN_NAME=`basename $DOMAIN_PATH` && mkdir -p $HT_HOME/$DOMAIN_NAME
	echo -e "\n[Info] DOMAIN_PATH:$DOMAIN_PATH" | tee -a $HT_HOME/$ADDR.txt
	echo -e "[Info] Gathering logs and configs..." | tee -a $HT_HOME/$ADDR.txt
	for i in `find $DOMAIN_PATH/servers/*/logs/ -maxdepth 1 -mtime -7 -name '*.log*' 2>/dev/null`
	do
		if [[ ! "$i" =~ "ldap" ]] && [[ ! "$i" =~ "access" ]] && [[ ! "$i" =~ "AuditRecorder" ]] ; then
			if [ `du $i | awk '{print $1}'` -ge 20000 ] ; then
				echo -e "[Info] Larger than 20000K: $i" | tee -a $HT_HOME/$ADDR.txt
				tail -20000 $i > $HT_HOME/$DOMAIN_NAME/`basename $i`
			else
				cp $i $HT_HOME/$DOMAIN_NAME/
			fi
		fi
	done

	if [ `ls $HT_HOME/$DOMAIN_NAME/ | wc -l` -eq 0 ] ; then
		for SERVER_NAME in `ls $DOMAIN_PATH/servers/ | grep -v domain_bak`
		do
			echo -e "$DOMAIN_NAME $SERVER_NAME logs:" | tee -a $HT_HOME/$ADDR.txt
			ls -ltr $DOMAIN_PATH/servers/$SERVER_NAME/logs/ | tee -a $HT_HOME/$ADDR.txt
		done
	fi
        
	cp -r $DOMAIN_PATH/config/ $HT_HOME/$DOMAIN_NAME/
done

if [ -z "$DOMAIN_PATH" ] ; then
	echo -e "\n[Warning] Weblogic not found." | tee -a $HT_HOME/$ADDR.txt && exit 1
fi


# 打包
echo -e "\n[Info] Tar the files."
mv $0 $HT_HOME
cd $HT_HOME
tar -cvzf $ADDR.tar.gz `ls | grep -v -E "*.sh"`


# 上传
if [ $? -ne 0 ] ; then
	echo -e "\n[Error] TAR ERROR" && exit 1
else
	echo -e "\n[Info] Upload the tar-file."
	upload $ADDR.tar.gz
fi


echo -e "\n[Info] $ADDR done."

