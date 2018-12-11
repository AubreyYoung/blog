# Oracle-安装手册-Oracle 12CR2 RAC 添加和删除节点

# 添加节点（rac3）

## 1、新节点系统配置

新添加节点的操作系统配置，网络配置，ASM磁盘配置等请参考指导书《Oracle-安装手册-
RAC-12cR2_for_Linux》的<验证系统要求>—<验证安装介质md5值>。

## 2、配置SSH

1\. 对 grid 和 oracle 用户配置 SSH，具体步骤参考下面的文章:

NOTE: 300548.1 - How To Configure SSH for a RAC Installation

或者 采用oracle自带ssh脚本：

# cd $ORACLE_HOME/oui/prov/resources/scripts

# ./sshUserSetup.sh -user grid -hosts "rac1 rac2 rac3" -advanced
-noPromptPassphrase

# ./sshUserSetup.sh -user oracle -hosts "rac1 rac2 rac3" -advanced
-noPromptPassphrase

2\. 测试验证 SSH configuration。

## 3、使用CVU验证添加的节点是否满足要求

在现有集群任一节点的grid用户下执行以下命令验证添加的节点是否满足GI软件的要求：

[grid]$ cluvfy stage -pre nodeadd -n rac3 -verbose -fixup 自动产生修复脚本

## 5、添加Clusterware

执行以下命令将添加新节点Clusterware软件 (在现有集群节点的grid用户执行)：

[grid]$ cd /u01/app/12.2.0/grid_1/addnode/

[grid]$ export IGNORE_PREADDNODE_CHECKS=Y

[grid]$ ./addnode.sh -silent -ignorePrereq "CLUSTER_NEW_NODES={rac3}"
"CLUSTER_NEW_VIRTUAL_HOSTNAMES={rac3-vip}" "CLUSTER_NEW_NODE_ROLES={hub}"

上一步执行成功之后，在新节点以root用户身份运行以下两个脚本：

[root@rac3 ~]# /u01/app/oraInventory/orainstRoot.sh

[root@rac3 ~]# /u01/app/12.2.0/grid_1/root.sh

验证

[grid@rac3 ~]$ crsctl status res –t

[grid@rac3 ~]$ crsctl status res –t -init

[grid@rac3 ~]$ crsctl check cluster –all

[grid@rac3 ~]$ olsnodes –n

[grid@rac3 ~]$ srvctl status asm

[grid@rac3 ~]$ srvctl status listener

## 6、添加Database软件

为新节点添加Database软件 (在现有集群节点以oracle用户执行)：

[oracle]$ cd /u02/app/oracle/product/12.2.0/db_1/addnode/

[oracle]$ ./addnode.sh -silent -ignorePrereq "CLUSTER_NEW_NODES={rac3}"

上一步完成之后，在新的节点以root用户身份运行以下脚本：

[root@rac3 ~]# /u02/app/oracle/product/12.2.0/db_1/root.sh

在现有集群节点或新节点，在grid和oracle用户下执行以下命令验证Clusterware和Database软件是否添加正确：

[grid]$ cluvfy stage -post nodeadd -n rac3 -verbose

## 7、添加DB instance

 **方案** **1** **：**

使用dbca工具执行以下命令，以静默模式添加新节点数据库实例（在现有集群节点以oracle用户执行）：

[oracle@rac1 ~]$ dbca -silent -addInstance -gdbName "orcl" -nodeName "rac3"
-instanceName "orcl3" -sysDBAUserName "sys" -sysDBAPassword "Oracle123"

 **方案** **2** **：**

在现有节点以 oracle 用户运行 dbca

1.检查集群和数据库是否正常。

SQL> select instance_number,instance_name,status from gv$instance;

SQL> select thread#,status,instance from gv$thread;

[grid@rac1 ~]$ crsctl status res -t

\--------------------------------------------------------------------------------

Name Target State Server State details

\--------------------------------------------------------------------------------

Local Resources

\--------------------------------------------------------------------------------

ora.ASMNET1LSNR_ASM.lsnr

ONLINE ONLINE rac1 STABLE

ONLINE ONLINE rac2 STABLE

ONLINE ONLINE rac3 STABLE

ora.CRS.dg

ONLINE ONLINE rac1 STABLE

ONLINE ONLINE rac2 STABLE

ONLINE ONLINE rac3 STABLE

ora.LISTENER.lsnr

ONLINE ONLINE rac1 STABLE

ONLINE ONLINE rac2 STABLE

ONLINE ONLINE rac3 STABLE

ora.MGMT.dg

ONLINE ONLINE rac1 STABLE

ONLINE ONLINE rac2 STABLE

ONLINE ONLINE rac3 STABLE

ora.chad

ONLINE ONLINE rac1 STABLE

ONLINE ONLINE rac2 STABLE

ONLINE ONLINE rac3 STABLE

ora.net1.network

ONLINE ONLINE rac1 STABLE

ONLINE ONLINE rac2 STABLE

ONLINE ONLINE rac3 STABLE

ora.ons

ONLINE ONLINE rac1 STABLE

ONLINE ONLINE rac2 STABLE

ONLINE ONLINE rac3 STABLE

ora.proxy_advm

OFFLINE OFFLINE rac1 STABLE

OFFLINE OFFLINE rac2 STABLE

OFFLINE OFFLINE rac3 STABLE

\--------------------------------------------------------------------------------

Cluster Resources

\--------------------------------------------------------------------------------

ora.LISTENER_SCAN1.lsnr

1 ONLINE ONLINE rac2 STABLE

ora.MGMTLSNR

1 ONLINE ONLINE rac2 169.254.238.69 10.10

.10.41,STABLE

ora.asm

1 ONLINE ONLINE rac1 Started,STABLE

2 ONLINE ONLINE rac2 Started,STABLE

3 ONLINE ONLINE rac3 Started,STABLE

ora.cvu

1 ONLINE ONLINE rac2 STABLE

ora.mgmtdb

1 ONLINE ONLINE rac2 Open,STABLE

ora.orcl.db

1 ONLINE ONLINE rac2 Open,HOME=/u02/app/o

racle/product/12.2.0

/db_1,STABLE

2 ONLINE ONLINE rac1 Open,HOME=/u02/app/o

racle/product/12.2.0

/db_1,STABLE

3 ONLINE ONLINE rac3 Open,HOME=/u02/app/o

racle/product/12.2.0

/db_1,STABLE

ora.qosmserver

1 ONLINE ONLINE rac2 STABLE

ora.rac1.vip

1 ONLINE ONLINE rac1 STABLE

ora.rac2.vip

1 ONLINE ONLINE rac2 STABLE

ora.rac3.vip

1 ONLINE ONLINE rac3 STABLE

ora.scan1.vip

1 ONLINE ONLINE rac2 STABLE

\--------------------------------------------------------------------------------

# 删除节点（rac1）

## 1、 删除节点DB instance

如果要删除的节点有运行的service，那么需要修改service运行在保留的节点上。确保要删除的实例没有关联任何service。

以下命令强制迁移service到其他节点上

[oracle]$ srvctl modify service -db [db_unique_name] -service [service_name]
-oldinst [old_inst_name] -newinst [new_inst_name] [-force]

查看

[oracle]$ srvctl status service -db [db_unique_name] -service
[service_name_list]

删除实例：

 **方案** **1** **：**

oracle用户在保留节点使用dbca的静默模式进行删除实例：

$ dbca -silent -deleteInstance -nodeList "rac1" -gdbName "orcl" -instanceName
"orcl1" -sysDBAUserName "sys" -sysDBAPassword Oracle123

 **方案** **2** **：**

oracle用户在保留节点运行dbca：

检查

[oracle]$ srvctl config database -d orcl

Type: RAC

Database instances: orcl2,orcl3

Configured nodes: rac2,rac3

[grid]$ crsctl status res -t

## 1、 卸载节点Database软件

禁用和停止预删除节点的监听

[grid]$ srvctl disable listener -listener LISTENER -node rac1

[grid]$ srvctl stop listener -listener LISTENER -node rac1

在预删除的节点上执行以下命令更新Inventory

[oracle]$ cd $ORACLE_HOME/oui/bin

[oracle]$ ./runInstaller -updateNodeList
ORACLE_HOME=/u02/app/oracle/product/12.2.0/db_1 "CLUSTER_NODES={rac1}" -local

注：runInstaller -updateNodeList 更新的是/u01/app/oraInventory/ContentsXML/
inventory.xml。

移除预删除的节点上RAC database home

RAC database home可能存放在共享存储和非共享存储（常用）上。

(1) 共享RAC database home

在预删除的节点上执行

[oracle]$ cd $ORACLE_HOME/oui/bin

[oracle]$ ./runInstaller -detachHome ORACLE_HOME=<oracle_home_location>

(2) 非共享RAC database home

在预删除的节点上执行

[oracle]$ cd $ORACLE_HOME/deinstall

[oracle]$ ./deinstall -local

此时会保留$ORACLE_BASE/admin目录，可以手动删除。

在集群中所有保留的节点上执行以下命令更新Inventory

[oracle]$ cd $ORACLE_HOME/oui/bin

[oracle]$ ./runInstaller -updateNodeList
ORACLE_HOME=/u02/app/oracle/product/12.2.0/db_1 "CLUSTER_NODES={rac2,rac3}"

## 2、 卸载节点Clusterware软件

查看预删除的节点是否为pinned状态

[grid]$ olsnodes -s -t

如果返回的结果是pinned状态，执行以下命令；如果是unpinned状态，跳过此步骤

[root]# cd /u01/app/12.2.0/grid_1/bin

[root]# ./crsctl unpin css -n rac1

在预删除的节点上执行以下命令更新Inventory

[grid]$ cd $ORACLE_HOME/oui/bin

[grid]$ ./runInstaller -updateNodeList ORACLE_HOME=/u01/app/12.2.0/grid_1
"CLUSTER_NODES={rac1}" CRS=TRUE -silent -local

移除RAC grid home

RAC grid home可能存放在共享存储和非共享存储上。

(1) 共享RAC grid home

运行以下命令以解除配置Oracle集群件：

$ Grid_home/crs/install/rootcrs.sh -deconfig -force

从Grid_home/oui/bin目录运行以下命令以分离Grid home：

$ ./runInstaller -detachHome ORACLE_HOME = Grid_home -silent -local

根据安装实用程序的提示，手动删除任何配置文件。

(2) 非共享RAC database home

在删除的节点上执行

[grid]$ cd $ORACLE_HOME/deinstall

[grid]$ ./deinstall -local

会提示以root用户运行rootcrs.sh脚本

/u01/app/12.2.0/grid_1/crs/install/rootcrs.sh -force -deconfig -paramfile
"/tmp/deinstall2017-12-14_04-14-12PM/response/deinstall_OraGI12Home1.rsp"

警告：

如果不指定-local标志，则该命令将从群集中的每个节点中删除Oracle Grid Infrastructure主目录。

**在所有保留节点上以grid用户 更新保留节点的Inventory：

[grid]$ cd $ORACLE_HOME/oui/bin

[grid]$ ./runInstaller -updateNodeList ORACLE_HOME=/u01/app/12.2.0/grid_1
"CLUSTER_NODES={rac2,rac3}" CRS=TRUE -silent -local

此时会保留目录/u01/app/12.2.0和/u01/app/grid

在保留节点的其中一个节点上运行以下命令删除群集节点：

[root@rac2 ~]# cd /u01/app/12.2.0/grid_1/bin/

[root@rac2 bin]# ./crsctl delete node -n rac1

[root@rac2 bin]# ./olsnodes -s -t

运行以下CVU命令以验证指定节点是否已成功从群集中删除：

$ cluvfy stage -post nodedel -n node_list [-verbose]

停止并删除VIP

此步骤需要在 要删除的节点已损坏并重做系统 时完成，如果执行了上一步，此步骤可跳过

[root@rac2 ~]# cd /u01/app/12.2.0/grid_1/bin

[root@rac2 bin]# ./srvctl stop vip -i rac1

[root@rac2 bin]# ./srvctl remove vip -i rac1 -f

[root@rac2 bin]# ./crsctl stat res -t

SQL> select thread#,status,instance from gv$thread;

Measure

Measure


---
### ATTACHMENTS
[330e42fff4a8c2ba988496476ccf03d3]: media/20180122134512_165.png
[20180122134512_165.png](media/20180122134512_165.png)
>hash: 330e42fff4a8c2ba988496476ccf03d3  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122134512_165.png  
>file-name: 20180122134512_165.png  

[3a3e3007985d85cb543c912dc8187007]: media/20180122134325_242.png
[20180122134325_242.png](media/20180122134325_242.png)
>hash: 3a3e3007985d85cb543c912dc8187007  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122134325_242.png  
>file-name: 20180122134325_242.png  

[3a4cdf2e82c843be29be36babb752753]: media/20180122134325_131.png
[20180122134325_131.png](media/20180122134325_131.png)
>hash: 3a4cdf2e82c843be29be36babb752753  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122134325_131.png  
>file-name: 20180122134325_131.png  

[56a661f79a27865954f0a5b84d334e40]: media/20180122134414_778.png
[20180122134414_778.png](media/20180122134414_778.png)
>hash: 56a661f79a27865954f0a5b84d334e40  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122134414_778.png  
>file-name: 20180122134414_778.png  

[7120fbd72df4fdc9a5b84dc8878a6ddd]: media/20180122134325_70.png
[20180122134325_70.png](media/20180122134325_70.png)
>hash: 7120fbd72df4fdc9a5b84dc8878a6ddd  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122134325_70.png  
>file-name: 20180122134325_70.png  

[7e2cd8416173396f35c5e720340a9825]: media/20180122134414_280.png
[20180122134414_280.png](media/20180122134414_280.png)
>hash: 7e2cd8416173396f35c5e720340a9825  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122134414_280.png  
>file-name: 20180122134414_280.png  

[86fbc2093d5b20d128c2db16d5809391]: media/20180122134414_111.png
[20180122134414_111.png](media/20180122134414_111.png)
>hash: 86fbc2093d5b20d128c2db16d5809391  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122134414_111.png  
>file-name: 20180122134414_111.png  

[89c4c92eccb1e2b905763c07feea3b98]: media/20180122134414_204.png
[20180122134414_204.png](media/20180122134414_204.png)
>hash: 89c4c92eccb1e2b905763c07feea3b98  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122134414_204.png  
>file-name: 20180122134414_204.png  

[8d3b6de8decb16ce9211c03a3cf4878a]: media/20180122134414_564.png
[20180122134414_564.png](media/20180122134414_564.png)
>hash: 8d3b6de8decb16ce9211c03a3cf4878a  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122134414_564.png  
>file-name: 20180122134414_564.png  

[900f52434ce9c6938fa237bc11d5c657]: media/20180122134325_890.png
[20180122134325_890.png](media/20180122134325_890.png)
>hash: 900f52434ce9c6938fa237bc11d5c657  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122134325_890.png  
>file-name: 20180122134325_890.png  

[c99d687975e7e9534d7429ef9c225a1e]: media/20180122134325_597.png
[20180122134325_597.png](media/20180122134325_597.png)
>hash: c99d687975e7e9534d7429ef9c225a1e  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122134325_597.png  
>file-name: 20180122134325_597.png  

[d31364d0261a2b996e226f379c5eec91]: media/20180122134325_563.png
[20180122134325_563.png](media/20180122134325_563.png)
>hash: d31364d0261a2b996e226f379c5eec91  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122134325_563.png  
>file-name: 20180122134325_563.png  

[ea9f2be1f390a2caa15a377791027548]: media/20180122134414_155.png
[20180122134414_155.png](media/20180122134414_155.png)
>hash: ea9f2be1f390a2caa15a377791027548  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122134414_155.png  
>file-name: 20180122134414_155.png  

[fe088142d5a4fe20caed0403b99c0dc8]: media/20180122134325_354.png
[20180122134325_354.png](media/20180122134325_354.png)
>hash: fe088142d5a4fe20caed0403b99c0dc8  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122134325_354.png  
>file-name: 20180122134325_354.png  

[ff13d387cec753ff28acc152a5429836]: media/20180122134414_615.png
[20180122134414_615.png](media/20180122134414_615.png)
>hash: ff13d387cec753ff28acc152a5429836  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180122134414_615.png  
>file-name: 20180122134414_615.png  


---
### TAGS
{Support20180830}

---
### NOTE ATTRIBUTES
>Created Date: 2018-08-30 01:33:35  
>Last Evernote Update Date: 2018-10-01 15:33:59  
>source: web.clip7  
>source-url: https://47.100.29.40/highgo_admin/#/index/docSearchDetail/319a30051c4100  
>source-application: WebClipper 7  