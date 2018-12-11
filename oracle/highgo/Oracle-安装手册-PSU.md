# Oracle-安装手册-PSU

# 一、PSU介绍

首先，维保客户的正式业务数据库实施时必须安装最新PSU补丁，减少后期因BUG等问题带来的维护成本。

关于psu：

 **Patch Set Update and Critical Patch Update October 2015 Availability
Document (** **文档** **ID 2037108.1)**

 **在** **2012** **年** **10** **月之前** **安全补丁叫做** **CPU** **，之后安全补丁较做** **SPU**
**每季度发行一次。**

 **如果在安装了** **psu** **的数据库上安装** **spu** **是不可以的。**

因此对于 客户使用漏洞扫描软件 扫描出来的安全漏洞，我们的建议是
客户直接安装对应数据库版本的PSU即可，而不必纠结于分析具体的漏洞问题，另外漏洞扫描软件扫描出来的漏洞往往提供的补丁是SPU补丁的下载地址，往往不符合实际生产环境。

  * Applying a SPU on an installation with an installed PSU/BP is not supported

我们目前客户均采用ＰＳＵ的补丁安装路线；另外windows的安全补丁不叫psu，应该叫做 **Bundle Patch** (Windows 32bit &
64bit)。

ｐｓｕ不定时更新，最新ｐｓｕ可以查找ｍｏｓ文章：

 **数据库** **PSU** **，** **SPU(CPU)** **，** **Bundle Patches** **和**
**Patchsets** **补丁号码快速参考** **(** **文档** **ID 1922396.1)**

PSU或者其他针对特定BUG的oracle补丁包中均含有README文档，安装的步骤一般都包含在其中，有些会指向到MOS文章中。

在进行实施时，如果没有特殊情况，一般对于维保客户都要安装最新版本的PSU。

RAC环境中的GI PSU（群集软件的PSU） 中往往包含对应的DB psu
，可以在安装的时候一起打上，当然如果有需要也可以只安装DB的psu，而不打grid 的psu。

新实施客户环境中，要求安装最新grid psu（其中包含DB PSU）。

如下表，目前11g最新PSU是 11.2.0.4.160419

#####  ** _11.2.0.4_**  
  
---  
  
**Description**

|

**PSU**

|

**SPU(CPU)**

|

**GI PSU**

|

**Bundle Patch** (Windows 32bit  & 64bit)  
  
APR2016

|

[22502456](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=22502456
"Click here to download")(11.2.0.4.160419)

|

[22502493](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=22502493
"Click here to download")(11.2.0.4.160419)

|

[22646198](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=22646198
"Click here to download")(11.2.0.4.160419)

|

[22839608](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=22839608
"Click here to download")(11.2.0.4.160419)  
  
JAN2016

|

[21948347](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=21948347
"Click here to download")(11.2.0.4.160119)

|

[21972320](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=21972320
"Click here to download")(11.2.0.4.160119)

|

[22191577](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=22191577
"Click here to download")(11.2.0.4.160119)

|

[22310544](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=22310544
"Click here to download")(11.2.0.4.160119)  
  
OCT2015

|

[21352635](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=21352635
"Click here to download")(11.2.0.4.8)

|

[21352646](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=21352646
"Click here to download")

|

[21523375](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=21523375
"Click here to download")(11.2.0.4.8)

|

[21821802](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=21821802
"Click here to download")(11.2.0.4.20)  
  
JUL2015

|

[20760982](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=20760982
"Click here to download")(11.2.0.4.7)

|

[20803583](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=20803583
"Click here to download")

|

[20996923](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=20996923
"Click here to download")(11.2.0.4.7)

|

[21469106](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=21469106
"Click here to download")(11.2.0.4.18)  
  
APR2015

|

[20299013](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=20299013
"Click here to download")(11.2.0.4.6)

|

[20299015](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=20299015
"Click here to download")

|

[20485808](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=20485808
"Click here to download")(11.2.0.4.6)

|

[20544696](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=20544696
"Click here to download")(11.2.0.4.15)  
  
JAN2015

|

[19769489](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=19769489
"Click here to download")(11.2.0.4.5)

|

[19854503](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=19854503
"Click here to download")

|

[19955028](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=19955028
"Click here to download")(11.2.0.4.5)

|

[20127071](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=20127071
"Click here to download")(11.2.0.4.12)  
  
OCT2014

|

[19121551](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=19121551
"Click here to download")(11.2.0.4.4)

|

[19271443](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=19271443
"Click here to download")

|

[19380115](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=19380115
"Click here to download")(11.2.0.4.4)

|

[19651773](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=19651773
"Click here to download")(11.2.0.4.10)  
  
JUL2014

|

[18522509](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=18522509
"Click here to download")(11.2.0.4.3)

|

[18681862](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=18681862
"Click here to download")

|

[18706472](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=18706472
"Click here to download")(11.2.0.4.3)

|

[18842982](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=18842982
"Click here to download")(11.2.0.4.7)  
  
APR2014

|

[18031668](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=18031668
"Click here to download")(11.2.0.4.2)

|

[18139690](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=18139690
"Click here to download")

|

[18139609](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=18139609
"Click here to download")(11.2.0.4.2)

|

[18296644](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=18296644
"Click here to download")(11.2.0.4.4)  
  
JAN2014

|

[17478514](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=17478514
"Click here to download")(11.2.0.4.1)

|

[17551709](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=17551709
"Click here to download")

|

N/A

|

[17987366](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1922396.1&patchId=17987366
"Click here to download")(11.2.0.4.1)  
  
可以参考readme进行手动安装psu，也可以按照readme中2.3 OPatch auto for GI

参考mos文章 **FAQ: OPatch/Patch Questions/Issues for Oracle Clusterware (Grid
Infrastructure or CRS) and RAC Environments (** **文档** **ID 1339140.1**

 **采用** **opatch auto** **的方式安装** **psu** **。**

 **opatch** auto安装方式比手动安装要更为省时省力。

以下演示如何在11.2.0.4.0 RAC上安装最新 GI PSU（包含db psu）。

单独打db psu相对简单，查看readme即可。

AUTO打psu的方式需要逐个节点安装，安装过程中会自动重启实例和本节点群集服务，另外一个节点访问不受影响。

# 二、PSU MD5验证

非官方下载的PSU需要经过md5验证，防止软件被恶意篡改，造成数据库破坏

安装介质校验方法参考《Oracle-指导手册-安装介质md5校验v2.1》

通过mos下载页面上的“view digest detail”查看官方md5值

如果md5值不同，则表示文件有可能被篡改过，不可以使用。

# 二、节点1上安装步骤：

  1.  **上传** **opatch soft** **和** **最新的** **GI psu** **到所有** **RAC** **节点的** **/tmp/** **中**

  2.  **更新** **opatch** **，** **两个节点均替换** **OPATCH** **，** **PSU** **安装都有最低的** **Opatch** **版本要求。**

Opatch工具下载MOS： **How To Download And Install The Latest OPatch(6880880)
Version (** **文档** **ID 274526.1)**

<https://updates.oracle.com/download/6880880.html>

su - oracle

unzip /tmp/OPatch\ 11.2.0.3.6_p6880880_112000_Linux-x86-64.zip -d $ORACLE_HOME

su - grid

unzip /tmp/OPatch\ 11.2.0.3.6_p6880880_112000_Linux-x86-64.zip -d $ORACLE_HOME

3.生成ocm response file

su - grid

$ORACLE_HOME/OPatch/ocm/bin/emocmrsp -no_banner -output /u02/config.rsp

_Provide your email address to be informed of security issues, install and_

 _initiate Oracle Configuration Manager. Easier for you if you use your My_

 _Oracle Support Email address/User Name._

 _Visit http://www.oracle.com/support/policies.html for details._

 _Email address/User Name:_

 _You have not provided an email address for notification of security issues._

 _Do you wish to remain uninformed of security issues ([Y]es, [N]o) [N]:
**y**_

 _The OCM configuration response file (/u02/config.rsp) was successfully
created._

 _[grid@rac2 ~]$_

 **4.解压** **gi psu patch**

su - root

#unzip 11.2.0.4.0419_GI_p22191577_112040_Linux-x86-64.zip -d /tmp/gi

 **5.修改补丁访问权限**

chmod 777 /tmp/gi/ -Rf

 **权限设置很重要** ，否则会出现 **Error:Patch Applicable check failed for
/u01/app/11.2.0/grid**

 **GI Home and the Database Homes that are not shared and ACFS file system is
not configured.**

 **6.关闭** **EM**

As the Oracle RAC database home owner execute:

$ <ORACLE_HOME>/bin/emctl stop dbconsole

如果没开em可以忽略本步骤。

 **7.开始打补丁**

打补丁的过程会自动重启 **本节点** 的所有数据库实例和crs 服务，因此打补丁前不必手动关闭数据库实例和群集。

若已经DBCA建库，使用以下命令

su - root

/u01/app/11.2.0/grid/OPatch/opatch auto /tmp/gi/22191577 -ocmrf
/u02/config.rsp

 **若是** **AIX** **或者** **HPUX** **环境新建** **RAC** **，建议先** **DBCA** **建库，再打**
**PSU** **。（** **原因见附** **2** **）。**

如果还没有DBCA建库，opatch auto只能打gi psu，而不会打db psu， **经过验证在** **AIX** **和**
**HPUX,linux** **环境下会出现只打** **GI psu** **，而不打** **DB psu** **的情况（** **原因详见**
**附** **1** **）**

。

 **auto** **打补丁是每个节点独立打，所以一号节点完成以上步骤后，需要再其他节点上同样执行一遍以上操作。**

 **8.如果打** **PSU** **前** **RAC** **已经存在数据库，则** **RAC** **上所有数据库运行脚本更新数据字典**

补丁安装完毕后需要更新数据字典，关闭其中一个数据库实例，然后在另外一个实例上执行：

cd $ORACLE_HOME/rdbms/admin

sqlplus /nolog

SQL> CONNECT / AS SYSDBA

SQL> STARTUP

SQL> @catbundle.sql psu apply

SQL> QUIT

9\. **编译无效对象**

cd $ORACLE_HOME/rdbms/admin

sqlplus /nolog

SQL> CONNECT / AS SYSDBA

SQL> @utlrp.sql

 **10.查看补丁**

su - grid

$ORACLE_HOME/OPatch/opatch lsinventory -oh $ORACLE_HOME

su - oracle

$ORACLE_HOME/OPatch/opatch lsinventory -oh $ORACLE_HOME

 **11.附** **1** **：**

参考mos：

 **Why "opatch auto" not patching RAC database ORACLE_HOME? (** **文档** **ID
1479651.1)  
****其中不能通过** **auto** **自动打** **db psu** **的原因是** **OCR** **中不存在** **DB home**
**的信息** **，**

The RAC database home has no database registered in the OCR

To find out whether there's any databases registered in the OCR running from
the RAC database ORACLE_HOME:

$GRID_HOME/bin/crsctl stat res -p -w "TYPE = ora.database.type" | egrep
'^NAME|^ORACLE_HOME'

以上查询如果没有结果那在打gi psu的时候，就不会自动打db psu。

DBCA建库后，再进行查询，就会出现db home的信息，再auto 打gi psu就会把db psu 一起打上。

 **如果是在** **AIX** **和** **HPUX** **上新建** **RAC** **，** **建议** **先** **DBCA**
**建库** **，** **再直接打** **GI PSU** **，并跑脚本更新数据字典。**

 **12.附** **2** **：**

如果一定要先打psu再建库，可以打完GI PSU后再加 –oh 参数来指定ORACLE_HOME来打db psu，

# /u01/app/11.2.0/grid_1/OPatch/opatch auto /tmp/gi/22646198 -oh
/u02/app/oracle/product/11.2.0/db_1 -ocmrf /u02/config.rsp

但是-oh参数打完psu后要检查 oracle用户的

$ORACLE_HOME/bin/oracle文件属主权限是否正确。如下是不正确的

权限应该是

[grid@lsrac1 bin]$ ls -l/u02/app/oracle/product/11.2.0/db_home/bin/oracle

-rwxr-s--x 1 oracle **asmadmin** 239626641 Jan 24 10:29 /u02/app/oracle/product/11.2.0/db_home/bin/oracle

如果权限不对，启动数据库实例时会提示无法访问asm磁盘组：

此时需要使用grid用户执行如下命令来修正权限：

参考mos：

 **Instance Startup Fails With ORA-00205 After Applying Patch/Relinking (**
**文档** **ID 1166697.1)**

su - grid  
[grid@lsrac1 ~]$ cd $ORACLE_HOME/bin/

[grid@lsrac1 bin]$ ./setasmgidwrap
o=/u02/app/oracle/product/11.2.0/db_home/bin/oracle

Measure

Measure


---
### ATTACHMENTS
[a78868f50e274d6c3416ec17fa50403e]: media/20180123211819_663.png
[20180123211819_663.png](media/20180123211819_663.png)
>hash: a78868f50e274d6c3416ec17fa50403e  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180123211819_663.png  
>file-name: 20180123211819_663.png  

[c4d2a02a92c82162c3e71fd16b4a7718]: media/20180123211852_313.png
[20180123211852_313.png](media/20180123211852_313.png)
>hash: c4d2a02a92c82162c3e71fd16b4a7718  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180123211852_313.png  
>file-name: 20180123211852_313.png  

[df20491cf285f8d61e3eaa39159a1349]: media/20180123211528_155.png
[20180123211528_155.png](media/20180123211528_155.png)
>hash: df20491cf285f8d61e3eaa39159a1349  
>source-url: https://support.highgo.com/highgo_api/images/uedit/20180123211528_155.png  
>file-name: 20180123211528_155.png  


---
### TAGS
{Support20180830}

---
### NOTE ATTRIBUTES
>Created Date: 2018-08-30 02:15:56  
>Last Evernote Update Date: 2018-10-01 15:33:56  
>source: web.clip7  
>source-url: https://47.100.29.40/highgo_admin/#/index/docSearchDetail/4c39d405aeeba1  
>source-application: WebClipper 7  