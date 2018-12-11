## 怎么查看grid control oms的登录端口
若 Grid Control在启动状态，用以下命令查看：
```
emctl status oms -details
Oracle Enterprise Manager 11g Release 1 Grid Control
Copyright (c) 1996, 2010 Oracle Corporation. All rights reserved.
Enter Enterprise Manager Root (SYSMAN) Password :
Console Server Host :<OMS-hostname>
HTTP Console Port : 7800
HTTPS Console Port : 7801
HTTP Upload Port : 4890
HTTPS Upload Port : 1159
OMS is not configured with SLB or virtual hostname
Agent Upload is locked.
OMS Console is locked.
Active CA ID: 1
```
若Grid Control 在停止状态， 查找以下文件：**\$GC_HOME/em/\$INSTANCE_NAME/emgc.properties**
```
# cat  /w01/wls/gc_inst/em/EMGC_OMS1/emgc.properties
#Tue Nov 15 16:12:25 EST 2011
oracle.sysman.emSDK.svlt.ConsoleServerName=nas\:4889_Management_Service
EM_INSTANCE_HOME=/w01/wls/gc_inst/em/EMGC_OMS1
EM_REPOS_CONNECTDESCRIPTOR=(DESCRIPTION\=(ADDRESS_LIST\=(ADDRESS\=(PROTOCOL\=TCP)(HOST\=nas)(PORT\=1521)))(CONNECT_DATA\=(SID\=EMREP)))
EM_NODEMGR_HOME=/w01/wls/gc_inst/NodeManager/emnodemanager
NM_USER=nodemanager
OPMN_LOCAL_PORT=0
WEBTIER_ORACLE_HOME=/w01/wls/oms/../Oracle_WT
MSPORT=7202
OHS_PROXY_PORT=0
AS_HTTPS_PORT=7101
MW_HOME=/w01/wls
EM_CONSOLE_HTTPS_PORT=7799
OHS_COMP_NAME=ohs1
EM_DOMAIN_HOME=/w01/wls/gc_inst/user_projects/domains/GCDomain
COMMON_ORACLE_HOME=/w01/wls/oracle_common
oracle.sysman.emRep.repositoryMode=repository
EM_UPLOAD_HTTP_PORT=4889
EM_WEBTIER_INSTHOME=/w01/wls/gc_inst/WebTierIH1
EM_DOMAIN_NAME=GCDomain
EM_REPOS_USER=SYSMAN
IS_ADMIN_HOST=true
EM_NODEMGR_PORT=7403
AS_PORT=0
WEBTIER_INSTANCE_NAME=instance1
OMSNAME=EMGC_OMS1
EM_INSTANCE_HOST=nas
AS_USERNAME=weblogic
AS_HOST=nas
ADMIN_SERVER_NAME=EMGC_ADMINSERVER
EM_UPLOAD_HTTPS_PORT=4900
ORACLE_HOME=/w01/wls/oms
WLS_HOME=/w01/wls/wlserver_10.3
MS_HTTPS_PORT=7301
OPMN_REMOTE_PORT=0
EM_CONSOLE_HTTP_PORT=7788
```
EM_CONSOLE_HTTPS_PORT=7799
EM_CONSOLE_HTTP_PORT=7788
这2个就是 OMS的登录 端口 上面的是HTTPS 下面是HTTP