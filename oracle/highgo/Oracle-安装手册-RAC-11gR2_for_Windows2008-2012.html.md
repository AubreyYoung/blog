# Oracle-安装手册-RAC-11gR2_for_Windows2008-2012.html

You need to enable JavaScript to run this app.

![](https://47.100.29.40/highgo_admin/static/media/head.530901d0.png)

  杨光  |  退出

  * 知识库

    * ▢  新建文档
    * ▢  文档复查 (3)
    * ▢  文档查询
  * 待编区

文档详细

  知识库 文档详细

![noteattachment1][7f025a17697ee15eb3197c61326b203b]

068145004

Oracle-安装手册-RAC-11gR2_for_Windows2008-2012

目录

环境

文档用途

详细信息

相关文档

内部备注

附件

环境

系统平台：Microsoft Windows (64-bit) 2008 SP2,Microsoft Windows (64-bit) 2008
R2,Microsoft Windows (64-bit) 2008,Microsoft Windows (64-bit) 2012,Microsoft
Windows (64-bit) 2012 R2

版本：11.2.0.1,11.2.0.2,11.2.0.3,11.2.0.4

文档用途

指导手册

详细信息

注：以下若没有特殊说明，每个节点均执行

注：以下若没有特殊说明，Windows 2008 或 Windows 2012均执行

## 1、验证系统要求

要验证系统是否满足 Oracle 11g 数据库的最低要求，以 管理员（administrator） 用户身份登录并查看以下信息。



启动任务管理器，查看内存大小

   ![noteattachment2][4f01114d42e8b61b9a5c4ab5d221ecf1]

右击计算机—>属性—>高级系统设置—>高级—>性能 设置—>高级 查看虚拟内存。

![noteattachment3][83c5b40b52936a3eddd859e12d498fc9]

修改虚拟内存





  ![noteattachment4][51173cdd7075aeab7fa33188ff96fd91]

![noteattachment5][1b13a77bc75b225eaf27bce5a3b5a578]

![noteattachment6][6423a3f72ce09505b4db2cd606e125dc]



The minimum required RAM is 1.5 GB for grid infrastructure for a cluster, or
2.5 GB for grid infrastructure for a cluster and Oracle RAC. The minimum
required swap space is 1.5 GB. Oracle recommends that you set swap space to
1.5 times the amount of RAM for systems with 2 GB of RAM or less. For systems
with 2 GB to 16 GB RAM, use swap space equal to RAM. For systems with more
than 16 GB RAM, use 16 GB of RAM for swap space. If the swap space and the
grid home are on the same filesystem, then add together their respective disk
space requirements for the total minimum space required.

## 2、修改主机名

![noteattachment7][3fbe2486b53a534d2182405e5f5a8e9c]



注意主机名不能过长,不能超过8个字符，且不能有下划线等特殊符号，不要使用大写字母，建议使用小写字母即可。

修改完主机名务必重启生效

修改administrator登录密码（两台服务器都执行，密码一致）

服务器管理器—>配置—>本地用户和组—>用户—>administrator右键—>设置密码



## 3、关闭防火墙：

 **Windows 2008**

服务器管理器—>配置  —>高级安全Windows防火墙—>属性—>将域配置文件、专用配置文件、公用配置文件的防火墙全部关闭。

![noteattachment8][f560d2b103c7b12c671137572fd2e5fb]

 **Windows 2012**

服务器管理器—>工具  —>高级安全Windows防火墙—>属性—>将域配置文件、专用配置文件、公用配置文件的防火墙全部关闭。

  



![noteattachment9][2ac54d77c4b339e26fcbabb4d633242e]

![noteattachment10][c18e7dac8308a57f86a2f8f20aba75e1]

## 4、将管理员的提升提示行为修改为“不提示，直接提升”：

1. 打开命令提示符，键入“secpol.msc”，以启动“安全策略控制台”管理实用程序。

2. 从“本地安全设置”控制台树中，单击“本地策略”，然后单击“安全选项”

3. 向下滚动至“用户帐户控制: 管理员的提升提示行为”，并双击该项目。

4. 从下拉菜单中，选择：“不提示，直接提升（请求提升的任务将自动以提升的权限运行，而不提示管理员）”

5. 单击“确定”确认更改

  



![noteattachment11][d44a7f22864688dc584fd20d5515e72e]

![noteattachment12][cf93bf0a1d796357409c09aa76eaf98d]

## 5、确保管理员组可以管理审核和安全日志：

1. 打开命令提示符，键入“secpol.msc”，以启动“安全策略控制台”管理实用程序。

2. 单击“本地策略”

3. 单击“用户权限分配”

4. 在用户权限分配列表中找到“管理审核和安全日志”并双击该项目。

5. 如果“本地安全设置”选项卡中未列出管理员组，此时请添加该组。

6. 单击“确定”保存更改（如有更改）。

  

  ![noteattachment13][85fe2d48873730c2e70fd2bd8aa50f3a]

![noteattachment14][2d2e2da39b0f6c8a10c8128fc548b586]

  

## 6、修改默认的非交互式桌面堆栈：

将默认的非交互式桌面堆栈（Non-Interactive Desktop Heap）的大小增加至 1MB，以防止因桌面堆栈耗尽而出现不稳定的情况。

 **有关如何增加该值的信息，请参阅 Document 744125.1** **和 Microsoft** **知识库文章 KB947246**
**。**

如果需要进一步将非交互式桌面堆栈的大小调至 1MB 以上，建议您咨询 Microsoft。



需要在数据库服务器的注册表中增加桌面堆大小。 它可以在以下位置找到:

\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session
Manager\SubSystems\

编辑类型REG_EXPAND_SZ的Windows值。 它看起来类似于：

%SystemRoot%\system32\csrss.exe ObjectDirectory=\Windows
SharedSection=1024,3072,512 Windows=On SubSystemType=Windows
ServerDll=basesrv,1 ServerDll=winsrv:UserServerDllInitialization,3
ServerDll=winsrv:ConServerDllInitialization,2 ProfileControl=Off
MaxRequestThreads=16



At this location the following set of values can be seen for "SharedSection",
1024,3072,512. The third value (512) is the size of the desktop heap for each
desktop that is associated with a "noninteractive" window station.



Increase of the third value to 1024, so the values are now listed as 1024,
3072, 1024 resolved the problem.



If this value is not present, the size of the desktop heap for noninteractive
window stations will be same as the size specified for interactive window
stations (the second SharedSection value).

![noteattachment15][a4a01e84607bd64119ef1bc578c6849f]

## 7、修改网卡配置

### 7.1 重命名网卡：

对于公网和私网 (NIC)，请勿将“PUBLIC”和“PRIVATE”（全部大写）用于网络名称，请参考未发布的 Bug 6844099。您可以使用
public 和 private 这两个词的其他形式，例如：Public 和 Private 是可以接受的。

对于公网和私网 (NIC)的网络名称，请勿使用中文命名，否则会出现以下报错：

![noteattachment16][9c19c9f8019f35bb902b4fb080010121]

![noteattachment17][642af1292d9cb47db084e890218c9c39]



  

### 7.2 设置网卡优先级

1. 单击“开始”，单击“运行”，键入“ncpa.cpl”，然后单击“确定”。

2. 在窗口顶部的菜单栏中，单击“高级”，选择“高级设置”（对于 Windows 2008，如果“高级”未显示，单击“Alt”以启用该菜单项）。

3. 在“适配器和绑定”选项卡下，使用向上箭头将“公网”接口移至“连接”列表的顶部。

4. 在“绑定顺序”下，使 IPv4 的优先级高于 IPv6

5. 单击“确定”保存更改



  

![noteattachment18][354d2e2c88fd2f4e976856dca7434fd9]

![noteattachment19][83c82a3ab35c020e6198e5a71fb8880d]

  

### 7.3 设置网卡\--在 DNS 中注册此连接的地址

取消选中“在 DNS 中注册此连接的地址”。

 **参考： Grid Infrastructure / RAC on Windows: IP Addresses for HOST, VIP, AND
SCAN Get Scrambled Upon Reboot (Doc ID 1504625.1)**



1. 调用 Server Manager

2. 选择“查看网络连接”

3. 选择“公网”网络接口

4. 从右键菜单中选择“属性”

5. 从“网络”选项卡中选择“Internet 协议版本 4(TCP/IPv4)”

6. 单击“属性”

7. 从“常规”选项卡中单击“高级...”

8. 选择“DNS”选项卡

9. 取消选中“在 DNS 中注册此连接的地址”的单选按钮

  

![noteattachment20][8ca898eec8ecc131f6e26e8b88841108]

![noteattachment21][5c4b2130fdcc8c6638d26ba2ae7d06fe]

![noteattachment22][615afa660164756facf8443278cc18ea]

### 7.3 设置网卡—自动跃点（仅限Windows 2012）

公网网卡设置为100，私网网卡设置为300：

  

![noteattachment23][90cb56e5b6ef44553afaa835f5177fd0]

![noteattachment24][1728bd9a10f35872de97ab27200cdc1e]

 **RAC on Windows: Grid Infrastructure Installation Fails With OUI-35024 OR
Private Node Name is Pre-Populated into Node Selection Screen (** **文档** **ID
1907834.1)**

##  8、禁用 DHCP 媒体感知

必须禁用 DHCP 媒体感知。

要禁用DHCP 媒体感知，请以管理员用户身份在命令窗口中执行以下命令：

C:\Users\Administrator> netsh interface ipv4 set global
dhcpmediasense=disabled

C:\Users\Administrator> netsh interface ipv6 set global
dhcpmediasense=disabled



使用以下命令验证更改：

C:\Users\Administrator> netsh interface ipv4 show global

C:\Users\Administrator> netsh interface ipv6 show global



关闭默认的 SNP 功能

C:\Users\Administrator> netsh int tcp set global chimney=disabled

C:\Users\Administrator> netsh int tcp set global rss=disabled



使用以下命令验证更改：

C:\Users\Administrator> netsh interface tcp show global



## 9、网络配置

修改C:\WINDOWS\System32\drivers\etc\hosts文件

192.168.16.40        rac1

192.168.16.41        rac2

192.168.16.42        rac1-vip

192.168.16.43        rac2-vip

192.168.16.44        rac-cluster-scan

10.10.10.10            rac1-priv

10.10.10.11            rac2-priv



rac1、rac2 对应的是网卡的物理ip ，即public ip

rac1-priv、rac2-priv 对应的是心跳网卡的物理ip  即private ip

rac1-vip、rac2-vip 对应的是虚拟VIP

rac-cluster-scan对应的SCAN ip



建议客户客户端连接rac群集，访问数据库时使用  SCAN  ip地址。

 **注意** **：** **vip** **、** **public ip** **、** **scan ip** **必须要在同一个子网网段中。**

 **另外** **对于心跳** **IP** **地址的设置** **，** **不要设置成和客户局域网中存在的** **ip** **网段。**

 **如客户网络是** **192.x.x.x** **则设置心跳为** **10.x.x.x   ,**
**心跳地址工程师可以自定义，但也要和客户确认客户局域网络是否有相同** **ip** **地址的服务器，尽量避免干扰。**



配置完心跳地址后,一定要使用tracert测试心跳网络之间通讯是否正常.心跳通讯是否正常不能简单地通过ping命令来检测.一定要使用tr
tracert默认是采用udp协议.每次执行tracert会发起三次检测,*号表示通讯失败.

正常:

C:\Users\zylong> tracert rac2-priv

通过最多 30 个跃点跟踪

到 zylong-PC [192.168.16.1] 的路由:

  1    <1 毫秒   <1 毫秒   <1 毫秒 zylong-PC [192.168.16.1]

跟踪完成。

## 10、修改TEMP和TMP环境变量

![noteattachment25][06f8e14e9c5fca634a505eed473363aa]

## 11、修改操作系统时间

检查多个服务器节点的操作系统时间和时区一致。如果不一致要先手动修改。

## 12、ASM配置共享磁盘



服务器管理器—>存储—>磁盘管理—>每个磁盘联机并初始化—>新建简单卷—>分配大小—>不分配盘符—>不格式化磁盘—>确定 建立一个无盘符无格式化的磁盘

  

![noteattachment26][700e60b13acf65c5a3f1af12d419a72d]

![noteattachment27][92ecdf7323b08a3fc6d8ec640431f5e5]

![noteattachment28][8de75e9b7419766bd52ff2d386f46b30]

![noteattachment29][83ca0c47e60e33d0b86ed06c46b3ef62]

![noteattachment30][94a42934569e882bbb4905bd2fe5e3fe]

![noteattachment31][781bef3fad09cdd17e4cf176d5c04655]

![noteattachment32][c99276986925e6fcb0f97b64634cdbfe]

![noteattachment33][55a5b5d81f23bdf1ad2f18c7cc29f78b]

注：配置ASM磁盘，可以采用主分区也可以使用logical driver：

Microsoft Windows: Usage of Primary Partitions when installing Grid
Infrastructure with ASM (文档 ID 2223445.1)

  

![noteattachment34][d437877f92f5320a081b7be69c52d595]





解压群集安装程序

  

![noteattachment35][72847baafa0d08759e2e21a4f81f0706]

![noteattachment36][e3225b21a2ad21921803962813a344e4]



标记磁盘分区以供ASM使用

在Windows资源管理器中导航到Grid Infrastructure安装中的asmtool目录

媒体并双击“asmtoolg.exe”可执行文件。

  ![noteattachment37][72e2a2c9400471a79f4e905f5778807d]

![noteattachment38][186cf6f0e449dcf402e4f46568c9f841]

![noteattachment39][c28a769c4610a49831e241e8015bc3aa]

  

![noteattachment40][8c5f4fedf4b50e8602a3500dee5b312a]

![noteattachment41][72f45f902ccc8771f89c127be84f0c18]

![noteattachment42][4ff1571aa71152d3078e58baa999eb79]



## 13、验证安装介质md5值

安装介质如非官方途径下载，需要验证md5值，避免使用网络上被篡改过的恶意介质

 **windows** **：**

 **C:\Users\oracle >certutil  -hashfile p13390677_112040_Linux-x86-64_1of7.zip
md5**

 ** **

 **得出的值和如下官方提供的** **md5** **值进行对比，如果** **md5** **值不同，则表示文件有可能被篡改过** **，**
**不可以使用。**

 **文件的名字发生变化并不影响** **md5** **值的校验结果。**



详见《Oracle各版本安装包md5校验手册v2.docx》



## 14、安装 Oracle Grid Infrastructure

以下截图内值均未参考选项，以实际内容为准。

  

![noteattachment43][63e4457c4ee1cc231d8588badc15c442]

![noteattachment44][8098d56270f9c8d7c85f9235c366fca8]

![noteattachment45][2d12802f6680f6ff1f25cdf0cd8a0aed]

![noteattachment46][0277c480215a5a30bee8fb72233d4f9d]

![noteattachment47][7d512238fe527d2188d3d2f2fd3b876e]

  

  

注意： SCAN name 必须和hosts文件里的scan name 一致

![noteattachment48][06a6754511599c85d283d5542525d9b7]

![noteattachment49][0b705ae6da21b430bb99576409464368]

![noteattachment50][dd89fada0501717c7ada82ba145d45fc]

![noteattachment51][56e3bb95ea5d47106a4e8a55ae7bdbc7]

![noteattachment52][e34b15ff25e52f077f6fa45fee42f74e]



此处要求存储工程师划分5个5G的LUN 用来做CRS磁盘组

此处冗余模式 Redundancy要选择High

下方勾选5个5G的磁盘。

![noteattachment53][b88ced9a6c51a4f6cda412a8001ba6cb]

 **ASM** **必须达到一定的密码标准。密码中要包含字母大写、小写、数字，至少** **8** **个字符。**



![noteattachment54][6bc15bd3734915b80611e88660507f98]

![noteattachment55][37ff6da21f07e9f8c4544b5e0b9aad52]

![noteattachment56][d9207a924cfe467d28a7772491d910d5]

如果只有以上一个条件不满足，勾选右上角的全部忽略，如果存在其他条件不满足则要进行相应处理。



![noteattachment57][06388b956b9124427606c3370b04db42]

![noteattachment58][9258c844f1db4f15e2d3e0e508663807]

  



 **在** **Windows 2012** **上会出现以下错误：**

![noteattachment59][689468151bf16e6197a0e874cfc2dd9e]

查看grid安装日志：

C:\Temp\2\OraInstall2016-11-22_12-53-06PM\
installActions2016-11-22_12-53-06PM.log

查看grid安装后配置日志，相当于linux系统安装grid后执行root.sh脚本：

C:\app\11.2.0\grid\cfgtoollogs\crsconfig\ rootcrs_rac1.log

2016-11-27 16:35:46: The 'ROOTCRS_ACFSINST' is either in START/FAILED state

2016-11-27 16:35:46: Executing 'C:\app\11.2.0\grid\bin\acfsroot.bat install'

2016-11-27 16:35:46: Executing cmd: C:\app\11.2.0\grid\bin\acfsroot.bat
install

2016-11-27 16:35:47: Command output:

>  ACFS-9300: 已找到 ADVM/ACFS 分发文件。

>  ACFS-9307: 正在安装请求的 ADVM/ACFS 软件。

>  acfsinstall: ACFS-09420: 当前未在此节点上安装驱动程序。

>  acfsinstall: ACFS-09411: CreateService 成功。

>  acfsinstall: CLSU-00100: 操作系统功能: StartDriver 失败, 错误数据: 31

>  acfsinstall: CLSU-00101: 操作系统错误消息: 连到系统上的设备没有发挥作用。

>  acfsinstall: CLSU-00103: 错误位置: StartDriver_

>  acfsinstall: ACFS-09419: StartService 失败。

>  acfsinstall: ACFS-09401: 无法安装驱动程序。

>

>  ACFS-9340: 无法安装 OKS 驱动程序。

>  acfsinstall: ACFS-09420: 当前未在此节点上安装驱动程序。

>  acfsinstall: ACFS-09411: CreateService 成功。

>  acfsinstall: CLSU-00100: 操作系统功能: StartDriver 失败, 错误数据: 1068

>  acfsinstall: CLSU-00101: 操作系统错误消息: 依赖服务或组无法启动。

>  acfsinstall: CLSU-00103: 错误位置: StartDriver_

>  acfsinstall: ACFS-09419: StartService 失败。

>  acfsinstall: ACFS-09401: 无法安装驱动程序。

>

>  ACFS-9340: 无法安装 ADVM 驱动程序。

>  acfsinstall: ACFS-09420: 当前未在此节点上安装驱动程序。

>  acfsinstall: ACFS-09411: CreateService 成功。

>  acfsinstall: CLSU-00100: 操作系统功能: StartDriver 失败, 错误数据: 1068

>  acfsinstall: CLSU-00101: 操作系统错误消息: 依赖服务或组无法启动。

>  acfsinstall: CLSU-00103: 错误位置: StartDriver_

>  acfsinstall: ACFS-09419: StartService 失败。

>  acfsinstall: ACFS-09401: 无法安装驱动程序。

>

>  ACFS-9340: 无法安装 ACFS 驱动程序。

>  ACFS-9310: ADVM/ACFS 安装失败。

>End Command output

2016-11-27 16:35:47: C:\app\11.2.0\grid\bin\acfsroot.bat install ... failed

2016-11-27 16:35:47: USM driver install status is 0

2016-11-27 16:35:47: USM driver install actions failed

2016-11-27 16:35:47: Running as user Administrator:
C:\app\11.2.0\grid\bin\cluut

il -ckpt -oraclebase C:\app\grid -writeckpt -name ROOTCRS_ACFSINST -state FAIL

2016-11-27 16:35:47: s_run_as_user2: Running C:\app\11.2.0\grid\bin\cluutil
-ckp

t -oraclebase C:\app\grid -writeckpt -name ROOTCRS_ACFSINST -state FAIL

2016-11-27 16:35:47: C:\app\11.2.0\grid\bin\cluutil successfully executed



2016-11-27 16:35:47: Succeeded in writing the checkpoint:'ROOTCRS_ACFSINST'
with

 status:FAIL

2016-11-27 16:35:47: CkptFile: C:\app\grid\Clusterware\ckptGridHA_rac1.xml

2016-11-27 16:35:47: Sync the checkpoint file
'C:\app\grid\Clusterware\ckptGridH

A_rac1.xml'

参考文档：

 **[INS-20802] Grid Infrastructure failed During Grid Installation On Windows
OS (** **文档** **ID 1987371.1)**

解决方法：

For Existing Installations:

Bug:17927204 is first fixed in Windows DB Bundle Patch 11.2.0.4.11 or higher.
At the time of writting the solution, the latest version is 11.2.0.4.14, which
is available as Patch 20502905 WINDOWS DB BUNDLE PATCH 11.2.0.4.14.

Close the installation UI on the nodes.

Then on first node, perform de-configuration by running the following:
GI_HOME\crs\install\rootcrs.pl -deconfig -force

Apply Patch 20502905 WINDOWS DB BUNDLE PATCH 11.2.0.4.14 to the nodes.

Run config.bat from GI_HOME\crs\config to configure Grid Infrastructure in a
clustered environment (OR 'Grid_home\perl\bin\perl -IGrid_home\perl\lib
-IGrid_home\crs\install Grid_home\crs\install\roothas.pl' for a Grid
Infrastructure standalone / Oracle Restart environment)

The following error may be seen after running the config.bat : "ACFS drivers
installation failed" to resolve the error run ASMCA to configure ACFS.  To
resolve the error run ASMCA to configure ACFS on cluster env.  Run following
in on standalone (Restart) env.  
  
   1) cd Grid_home\oui\bin  
   2) setup.exe -updateNodeList ORACLE_HOME=Grid_home CLUSTER_NODES= CRS=TRUE  
   3) run ASMCA to configure ACFS

解决过程：

  1. 回退grid安装后的配置操作

C:\Windows\system32> **set ORACLE_HOME=C:\app\11.2.0\grid**

C:\Windows\system32> **%ORACLE_HOME%\perl\bin\perl -I%ORACLE_HOME%\perl\lib
-I%ORACLE_HOME%\crs\install %ORACLE_HOME%\crs\install\rootcrs.pl -deconfig
-force**

2016-11-27 16:42:42: Checking for super user privileges

2016-11-27 16:42:42: superUser=Administrator groupName=Administrators

2016-11-27 16:42:42: domain=WORKGROUP user=ADMINISTRATOR

2016-11-27 16:42:42: C:\app\11.2.0\grid\bin\crssetup.exe getsystem

2016-11-27 16:42:42: Executing cmd: C:\app\11.2.0\grid\bin\crssetup.exe
getsyste

m

2016-11-27 16:42:42: Command output:

>  SYSTEM

>End Command output

2016-11-27 16:42:42: User has Administrator privileges

Using configuration parameter file:
C:\app\11.2.0\grid\crs\install\crsconfig_par

ams

PRCR-1119 : 无法查找 ora.cluster_vip_net1.type 类型的 CRS 资源

PRCR-1068 : 无法查询资源

Cannot communicate with crsd

PRCR-1070 : 无法检查 资源 ora.gsd 是否已注册

Cannot communicate with crsd

PRCR-1070 : 无法检查 资源 ora.ons 是否已注册

Cannot communicate with crsd



CRS-4535: 无法与集群就绪服务通信

CRS-4000: 命令 Stop 失败, 或已完成但出现错误。

CRS-4133: Oracle 高可用性服务已停止。

Remove Oracle Fence Service... C:\app\11.2.0\grid\bin\crssetup.exe
deinstallfenc

e

<16:43:11> Started

<16:43:11> arguements 2

<16:43:11>   C:\app\11.2.0\grid\bin\crssetup.exe

<16:43:11>   deinstallfence

<16:43:11> returning 0x0

Successfully deconfigured Oracle clusterware stack on this node

  1. 安装最新的Bundle Patch补丁，只安装到grid home下

上传opatch soft和最新的Bundle Patch补丁到所有RAC节点上

两个节点均替换OPatch，把 GRID_HOME上的OPatch进行备份，然后将下载的补丁6880880解压后复制到GRID_HOME下。



![noteattachment60][2e5dd7fcbc8be8128f45750d8d7ba868]

按照Bundle Patch补丁中README.html进行以下步骤

C:\Windows\system32>net stop msdtc

Distributed Transaction Coordinator 服务正在停止.

Distributed Transaction Coordinator 服务已成功停止。



C:\Windows\system32>set PATH=%ORACLE_HOME%\perl\bin;%PATH%



C:\Windows\system32>set ORACLE_HOME=C:\app\11.2.0\grid



C:\Windows\system32>net start | findstr /i ora

   OracleRemExecService



C:\Windows\system32> net stop OracleRemExecService

OracleRemExecService 服务已成功停止。



C:\Windows\system32>sc config Winmgmt start= disabled

[SC] ChangeServiceConfig 成功



C:\Windows\system32>net stop winmgmt

下面的服务依赖于 Windows Management Instrumentation 服务。

停止 Windows Management Instrumentation 服务也会停止这些服务。

   User Access Logging Service

   IP Helper

你想继续此操作吗? (Y/N) [N]: y

User Access Logging Service 服务正在停止.

User Access Logging Service 服务已成功停止。

IP Helper 服务正在停止.

IP Helper 服务已成功停止。

Windows Management Instrumentation 服务正在停止.

Windows Management Instrumentation 服务已成功停止。



C:\Windows\system32>cd C:\soft\psu\24591646



C:\soft\psu\24591646> **C:\app\11.2.0\grid\OPatch\opatch apply -local**

Oracle 中间补丁程序安装程序版本 11.2.0.3.15

版权所有 (c) 2016, Oracle Corporation。保留所有权利。

Oracle Home       : C:\app\11.2.0\grid

Central Inventory : C:\Program Files\Oracle\Inventory

   from           :

OPatch version    : 11.2.0.3.15

OUI version       : 11.2.0.4.0

Log file location :
C:\app\11.2.0\grid\cfgtoollogs\opatch\opatch2016-11-27_16-51

-17下午_1.log

Verifying environment and performing prerequisite checks...

OPatch continues with these patches:   24591646

是否继续? [y|n]

 **y**

User Responded with: Y

All checks passed.

提供电子邮件地址以用于接收有关安全问题的通知, 安装 Oracle Configuration Manager

并启动它。如果您使用 My Oracle

Support 电子邮件地址/用户名, 操作将更简单。

有关详细信息, 请访问 http://www.oracle.com/support/policies.html。

电子邮件地址/用户名:

尚未提供电子邮件地址以接收有关安全问题的通知。

是否不希望收到有关安全问题 (是 [Y], 否 [N]) [N] 的通知: **  y**

请关闭本地系统上在此 ORACLE_HOME 之外运行的 Oracle 实例。

(Oracle 主目录 = 'C:\app\11.2.0\grid')

本地系统是否已准备打补丁? [y|n]

 **y**

User Responded with: Y

Backing up files...

Applying interim patch '24591646' to OH 'C:\app\11.2.0\grid'

ApplySession: Oracle 主目录中不存在可选组件 [ oracle.ovm, 11.2.0.4.0 ] , [ oracl

e.rdbms.oci, 11.2.0.4.0 ] , [ oracle.owb.rsf, 11.2.0.4.0 ] , [ oracle.sdo,
11.2.

0.4.0 ] , [ oracle.sysman.agent, 10.2.0.4.5 ] , [ oracle.rdbms.hsodbc,
11.2.0.4.

0 ] , [ oracle.rdbms.tg4msql, 11.2.0.4.0 ] , [ oracle.rdbms.tg4sybs,
11.2.0.4.0

] , [ oracle.rdbms.tg4tera, 11.2.0.4.0 ] , [ oracle.rdbms.tg4ifmx, 11.2.0.4.0
]

, [ oracle.rdbms.tg4db2, 11.2.0.4.0 ] , [ oracle.xdk, 11.2.0.4.0 ] , [
oracle.ct

x, 11.2.0.4.0 ] , [ oracle.precomp.common, 11.2.0.4.0 ] , [ oracle.oraolap,
11.2

.0.4.0 ] , [ oracle.oraolap.api, 11.2.0.4.0 ] , [ oracle.odbc.ic, 11.2.0.4.0 ]
,

 [ oracle.rdbms.ic, 11.2.0.4.0 ] , [ oracle.rdbms.dv, 11.2.0.4.0 ] , [
oracle.nt

oledb, 11.2.0.4.0 ] , [ oracle.ntoledb.odp_net_2, 11.2.0.4.0 ] , [
oracle.sysman

.console.db, 11.2.0.4.0 ] , 或找到更高版本。

正在为组件 oracle.rdbms.deconfig, 11.2.0.4.0 打补丁...

正在为组件 oracle.rdbms.dbscripts, 11.2.0.4.0 打补丁...

正在为组件 oracle.sqlplus.ic, 11.2.0.4.0 打补丁...

正在为组件 oracle.sqlplus, 11.2.0.4.0 打补丁...

正在为组件 oracle.rdbms.rsf, 11.2.0.4.0 打补丁...

正在为组件 oracle.rdbms.rsf.ic, 11.2.0.4.0 打补丁...

正在为组件 oracle.ldap.owm, 11.2.0.4.0 打补丁...

正在为组件 oracle.rdbms.plsql, 11.2.0.4.0 打补丁...

正在为组件 oracle.xdk.parser.java, 11.2.0.4.0 打补丁...

正在为组件 oracle.xdk.rsf, 11.2.0.4.0 打补丁...

正在为组件 oracle.rdbms.rman, 11.2.0.4.0 打补丁...

正在为组件 oracle.sdo.locator, 11.2.0.4.0 打补丁...

正在为组件 oracle.rdbms, 11.2.0.4.0 打补丁...

正在为组件 oracle.nlsrtl.rsf, 11.2.0.4.0 打补丁...

正在为组件 oracle.oraolap.dbscripts, 11.2.0.4.0 打补丁...

正在为组件 oracle.ldap.rsf.ic, 11.2.0.4.0 打补丁...

正在为组件 oracle.rdbms.util, 11.2.0.4.0 打补丁...

正在为组件 oracle.network.rsf, 11.2.0.4.0 打补丁...

正在为组件 oracle.network.aso, 11.2.0.4.0 打补丁...

正在为组件 oracle.ordim.client, 11.2.0.4.0 打补丁...

正在为组件 oracle.ordim.jai, 11.2.0.4.0 打补丁...

正在为组件 oracle.has.cfs, 11.2.0.4.0 打补丁...

正在为组件 oracle.has.common.cvu, 11.2.0.4.0 打补丁...

正在为组件 oracle.has.common, 11.2.0.4.0 打补丁...

正在为组件 oracle.has.crs, 11.2.0.4.0 打补丁...

正在为组件 oracle.has.cvu, 11.2.0.4.0 打补丁...

正在为组件 oracle.has.db, 11.2.0.4.0 打补丁...

正在为组件 oracle.has.rsf, 11.2.0.4.0 打补丁...

正在为组件 oracle.usm, 11.2.0.4.0 打补丁...

Patch 24591646 successfully applied.

Log file location:
C:\app\11.2.0\grid\cfgtoollogs\opatch\opatch2016-11-27_16-51-

17下午_1.log

OPatch succeeded.



C:\soft\psu\24591646>sc config Winmgmt start= auto

[SC] ChangeServiceConfig 成功



C:\soft\psu\24591646>net start msdtc

Distributed Transaction Coordinator 服务正在启动 .

Distributed Transaction Coordinator 服务已经启动成功。



C:\soft\psu\24591646>net start winmgmt

Windows Management Instrumentation 服务正在启动 .

Windows Management Instrumentation 服务已经启动成功。



C:\soft\psu\24591646>sc query OraFenceService

SERVICE_NAME: OraFenceService

        TYPE               : 1  KERNEL_DRIVER

        STATE              : 4  RUNNING

                                (STOPPABLE, NOT_PAUSABLE, IGNORES_SHUTDOWN)

        WIN32_EXIT_CODE    : 0  (0x0)

        SERVICE_EXIT_CODE  : 0  (0x0)

        CHECKPOINT         : 0x0

        WAIT_HINT          : 0x0



C:\soft\psu\24591646>sc qc OraFenceService

[SC] QueryServiceConfig 成功

SERVICE_NAME: OraFenceService

        TYPE               : 1  KERNEL_DRIVER

        START_TYPE         : 4   DISABLED

        ERROR_CONTROL      : 1   NORMAL

        BINARY_PATH_NAME   :

        LOAD_ORDER_GROUP   :

        TAG                : 0

        DISPLAY_NAME       : OraFenceService

        DEPENDENCIES       :

        SERVICE_START_NAME :



C:\soft\psu\24591646>%ORACLE_HOME%\bin\crssetup deinstallfence

<16:59:24> Started

<16:59:24> arguements 2

<16:59:24>   C:\app\11.2.0\grid\bin\crssetup

<16:59:24>   deinstallfence

<16:59:24> failed to delete OraFenceService service. 指定的服务已标记为删除。



<16:59:24> returning 0x2000001

重新启动当前操作系统



C:\Windows\system32>set ORACLE_HOME=C:\app\11.2.0\grid

C:\Windows\system32>%ORACLE_HOME%\bin\crssetup installfence

<17:05:27> Started

<17:05:27> arguements 2

<17:05:27>   C:\app\11.2.0\grid\bin\crssetup

<17:05:27>   installfence

<17:05:27> Warning:  failed to remove imagePath, continuing. 操作成功完成。



<17:05:28> returning 0x0

重新启动当前操作系统



第二个节点打补丁，打完补丁最好重新启动一下操作系统

  1. 执行config.bat配置grid集群。

![noteattachment61][6092b9f1b12694b38269f7592d5545c8]

![noteattachment62][cf4159ca080bf216a2abf838ab839c6b]

![noteattachment63][bd0fbe487aeab304320725b26f2c7784]

![noteattachment64][21b3738348294538febe9b89c45ed8d0]

![noteattachment65][0a95c6c3bdb5c7b423003a69c3c2eb68]

![noteattachment66][e9e2516a7f1d9f452507d5cd66c8785d]

![noteattachment67][5e9a65070dff059ec66fb3574f2a8300]

![noteattachment68][61cfbff8a270b4794e9e551dbb92d431]

![noteattachment69][2ff2469eb9d0fbd3ee9b841b1219a7a9]

![noteattachment70][d1e43b2e42bc3fd5e51aba83b8a72371]

![noteattachment71][5b1078c405f03b05fa71b55d4b88499d]

![noteattachment72][1ea664ec9c825295ff2842b74626bd26]

![noteattachment73][1bca2566611a834042d5b6d8ce201cd3]

![noteattachment74][eb8bbb492d3d65425ac4e09d2868cfa0]

15、集群安装后的任务

 (1)、验证oracle clusterware的安装

以administrator身份运行以下命令：

检查crs状态：

C:\>crsctl check crs

CRS-4638: Oracle 高可用性服务联机

CRS-4537: 集群就绪服务联机

CRS-4529: 集群同步服务联机

CRS-4533: 事件管理器联机



检查 Clusterware 资源:

C:\>crsctl stat res -t

\--------------------------------------------------------------------------------

NAME         TARGET  STATE        SERVER                   STATE_DETAILS

\--------------------------------------------------------------------------------

Local Resources

\--------------------------------------------------------------------------------

ora.CRS.dg

               ONLINE  ONLINE       rac1

               ONLINE  ONLINE       rac2

ora.LISTENER.lsnr

               ONLINE  ONLINE       rac1

               ONLINE  ONLINE       rac2

ora.asm

               ONLINE  ONLINE       rac1                     Started

               ONLINE  ONLINE       rac2                     Started

ora.gsd

               OFFLINE OFFLINE      rac1

               OFFLINE OFFLINE      rac2

ora.net1.network

               ONLINE  ONLINE       rac1

               ONLINE  ONLINE       rac2

ora.ons

               ONLINE  ONLINE       rac1

               ONLINE  ONLINE       rac2

ora.registry.acfs

               ONLINE  ONLINE       rac1

               ONLINE  ONLINE       rac2

\--------------------------------------------------------------------------------

Cluster Resources

\--------------------------------------------------------------------------------

ora.LISTENER_SCAN1.lsnr

      1        ONLINE  ONLINE       rac1

ora.cvu

      1        ONLINE  ONLINE       rac1

ora.oc4j

      1        ONLINE  ONLINE       rac1

ora.rac1.vip

      1        ONLINE  ONLINE       rac1

ora.rac2.vip

      1        ONLINE  ONLINE       rac2

ora.scan1.vip

      1        ONLINE  ONLINE       rac1



检查集群节点:

C:\>olsnodes -n

rac1    1

rac2    2

检查两个节点上的 Oracle TNS 监听器进程:

C:\>srvctl status listener

监听程序 LISTENER 已启用

监听程序 LISTENER 正在节点上运行: rac2,rac1



(2)为数据和快速恢复区创建 ASM 磁盘组

asmca

![noteattachment75][be14fbd1ac63f2944927c9ccb65f6637]



在 Disk Groups 选项卡中，单击 **创建** 按钮，在出现的画面中创建data卷：

除了CRS磁盘组以外其余存放数据和归档的磁盘组默认都是选择Extenal外部冗余模式，除非客户特殊要求。

![noteattachment76][6fde6c87dcda5c2eb35b5e0792652cf9]

![noteattachment77][a6b5ecde87885297808844e8bd54f5ed]

![noteattachment78][32f04490e107267ac32bb868fac59d36]

对于磁盘组的规划，一般一套rac 含有一个CRS磁盘组，一个FRA磁盘组用于存放归档日志，一个或者多个DATA磁盘组用于存放数据。

单击 **退出** 退出ASM配置向导。

 **至此重启下服务器确认** **crs** **各个资源状态均正常。**

##  16、安装oracle 11g r2 database

![noteattachment79][27c643a9d36c2f1317cada9cc2c68db4]

选择 **Real Application Clusters database installation** 单选按钮（此为默认选择），确保选中 Node
Name 窗口中的两个 Oracle RAC 节点。

![noteattachment80][5f93524edb406f70955b455ab9e35e35]

 **在** **Windows 2012** **上会出现以下错误：**

![noteattachment81][d4b1ceb1c22632fcb172ead47684d433]

C:\>crsctl status res -t

\--------------------------------------------------------------------------------

NAME           TARGET  STATE        SERVER                   STATE_DETAILS

\--------------------------------------------------------------------------------

Local Resources

\--------------------------------------------------------------------------------

ora.CRS.dg

               ONLINE  ONLINE       rac1

               ONLINE  ONLINE       rac2

ora.DATA.dg

               ONLINE  ONLINE       rac1

               ONLINE  ONLINE       rac2

ora.FRA.dg

               ONLINE  ONLINE       rac1

               ONLINE  ONLINE       rac2

ora.LISTENER.lsnr

               ONLINE  ONLINE       rac1

               ONLINE  ONLINE       rac2

ora.asm

               ONLINE  ONLINE       rac1                     Started

               ONLINE  ONLINE       rac2                     Started

ora.gsd

               OFFLINE OFFLINE      rac1

               OFFLINE OFFLINE      rac2

ora.net1.network

               ONLINE  ONLINE       rac1

               ONLINE  ONLINE       rac2

ora.ons

               ONLINE  ONLINE       rac1

               ONLINE  ONLINE       rac2

ora.registry.acfs

               ONLINE  ONLINE       rac1

               ONLINE  ONLINE       rac2

\--------------------------------------------------------------------------------

Cluster Resources

\--------------------------------------------------------------------------------

ora.LISTENER_SCAN1.lsnr

      1        ONLINE  ONLINE       rac1

ora.cvu

      1        ONLINE  ONLINE       rac1

ora.oc4j

      1        ONLINE  ONLINE       rac1

ora.rac1.vip

      1        ONLINE  ONLINE       rac1

ora.rac2.vip

      1        ONLINE  ONLINE       rac2

ora.scan1.vip

      1        ONLINE  ONLINE       rac1

 **参考文档：**

 **Windows: Prerequisite Error INS-35423 And Warnings When Installing RAC
Database Software (** **文档** **ID 2164220.1)**

解决方法：

Known issue in bug 19065263, will be fixed in release 12.2.

The workaround is to run setup.exe and pass the hostname.  
e.g.

C:\>setup.exe ORACLE_HOSTNAME=RACNODE1



解决过程：

![noteattachment82][d9dc57e413156639d7399a066e484267]



C:\>cd C:\soft\database

C:\soft\database>setup.exe ORACLE_HOSTNAME=rac1

![noteattachment83][9277b28e54c4d9820a4cce1b4644962b]

![noteattachment84][070bac00acae7f20aa0d8216a75be257]

![noteattachment85][3581cb50fb0ca84dd617d63ac6beeb14]

  

 **在** **Windows 2008** **上会出现以下错误，全部忽略即可：**

![noteattachment86][0c753771d3ca357a1a21fdc25ef06d6d]

2012

![noteattachment87][c2a57410cb4295cd08ea0f45fe7b6fcb]

待安装完成后退出向导。

## 17、创建、删除数据库

建议

数据文件，归档日志分开存放在不同的，文件系统路径或ASM路径中

控制文件和在线日志多路复用时，放在不同的，磁盘驱动器或ASM磁盘组中

数据库位于文件系统时，将数据文件和在线日志放在不同的磁盘驱动器中

### 17.1 创建数据库

 使用dbca创建，创建之前确保已安装的所有服务（Oracle TNS 监听器、Oracle Clusterware 进程等）正在运行。

C:\>crsctl status res -t

\--------------------------------------------------------------------------------

NAME           TARGET  STATE        SERVER                   STATE_DETAILS

\--------------------------------------------------------------------------------

Local Resources

\--------------------------------------------------------------------------------

ora.CRS.dg

               ONLINE  ONLINE       rac1

               ONLINE  ONLINE       rac2

ora.DATA.dg

               ONLINE  ONLINE       rac1

               ONLINE  ONLINE       rac2

ora.FRA.dg

               ONLINE  ONLINE       rac1

               ONLINE  ONLINE       rac2

ora.LISTENER.lsnr

               ONLINE  ONLINE       rac1

               ONLINE  ONLINE       rac2

ora.asm

               ONLINE  ONLINE       rac1                     Started

               ONLINE  ONLINE       rac2                     Started

ora.gsd

               OFFLINE OFFLINE      rac1

               OFFLINE OFFLINE      rac2

ora.net1.network

               ONLINE  ONLINE       rac1

               ONLINE  ONLINE       rac2

ora.ons

               ONLINE  ONLINE       rac1

               ONLINE  ONLINE       rac2

ora.registry.acfs

               ONLINE  ONLINE       rac1

               ONLINE  ONLINE       rac2

\--------------------------------------------------------------------------------

Cluster Resources

\--------------------------------------------------------------------------------

ora.LISTENER_SCAN1.lsnr

      1        ONLINE  ONLINE       rac1

ora.cvu

      1        ONLINE  ONLINE       rac1

ora.oc4j

      1        ONLINE  ONLINE       rac1

ora.rac1.vip

      1        ONLINE  ONLINE       rac1

ora.rac2.vip

      1        ONLINE  ONLINE       rac2

ora.scan1.vip

      1        ONLINE  ONLINE       rac1



![noteattachment88][73cac470092bf9a3c8cfb35f6e6a887d]

![noteattachment89][d8a7a4ecdf46fff6a8e1d64052030fc4]

![noteattachment90][1b3cd90263f6aeb17e9d51142020c31c]

![noteattachment91][682b84f7107c62a4828ac0f2617c97fc]

![noteattachment92][35a236c47bf3203b29622784bd39b620]

![noteattachment93][e213066d615c2367977c3a308102c5c4]

  

  

点击"Multiplex Redo Logs and Control Files" 输入多个磁盘组来产生冗余控制文件和redo文件。

如果存在+FRA则填写 +DATA和+FRA

如果不存在+FRA，只有+DATA ，则添加两个+DATA

原则就是要多个控制文件和redo文件，而且尽量要存放在不同的磁盘组中。

![noteattachment94][3edeb2a3cc1062dd3887f95b465e10bf]

注意将“归档日志文件格式”中的“S”修改为“s”，否则alert日志中可能会出现如下警告：

Tue Aug 29 09:18:52 中国标准时间 2017

ARC0: Warning.  Log sequence in archive filename wrapped

to fix length as indicated by %S in LOG_ARCHIVE_FORMAT.

Old log archive with same name might be overwritten.

Tue Aug 29 09:19:17 中国标准时间 2017

Thread 1 advanced to log sequence 118540 (LGWR switch)

LOG_ARCHIVE_FORMAT默认情况下使用%S，而%S是固定字符长度为5，也就是说，当归档日志的sequence超过了99999以后，就会提示类似警告，只截取其中的5个数字，因此有可能归档日志名字完全相同被覆盖，因此alert日志出现如上警告。

LOG_ARCHIVE_FORMAT is applicable only if you are using the redo log in
ARCHIVELOG mode. Use a text string and variables to specify the default
filename format when archiving redo log files. The string generated from this
format is appended to the string specified in the LOG_ARCHIVE_DEST parameter.

The following variables can be used in the format:

%s log sequence number

%S log sequence number, zero filled

%t thread number

%T thread number, zero filled

Using uppercase letters for the variables (for example, %S) causes the value
to be fixed length and padded to the left with zeros.



![noteattachment95][283cf929505395f953583dec8d9e1c61]



保守的设置原则是 ：

SGA_TARGET+pga_aggregate_target=物理内存*0.6

SGA_TARGET : pga_aggregate_target  比例是4:1

SGA_TARGET 等于 SGA_MAX_SIZE



根据实际物理内存进行调整。

![noteattachment95][283cf929505395f953583dec8d9e1c61]

![noteattachment97][980de9ca44c431dd94fa8b3115fdf54a]

  

字符集的必须和开发人员进行确认，不能猜测使用，数据库建立完成后字符集不能进行修改。

![noteattachment98][9537a74f327467bb37eaa1a480f3244b]

这里得注意新加的两组日志一个是线程Thread# 1，一个是线程Thread# 2

![noteattachment99][48dc25c40e4f64456e4d41da2f8aec38]

![noteattachment100][20e35c1163a1d79e02c9b2ccca901b5b]

![noteattachment101][f0ea5e59782c275a27f309b25dcb47b4]

### 17.2 删除数据库

删除数据库最好也用dbca，虽然srvctl也可以。

  1. 运行dbca，选择”delete a database”。然后就next..，直到finish。

  2. 数据的删除并不影响asm实例，如果想删除与asm有关的内容，可以按如下做法：

# export ORACLE_SID= _ASM_instance_name_

# sqlplus / as sysdba

SQL> drop diskgroup _diskgroup_name_ including contents;

SQL> quit

然后在各个节点上执行

# srvctl stop asm –n hostname

# srvctl remove asm –n hostname

这样，应该就可以删除的比较干净了。

## 18、安装Bundle Patch补丁

对于Windows
2008R2，在打补丁之前先安装操作系统补丁KB3033929（Windows6.1-KB3033929-x64.msu），否则ACFS资源无法启动，集群alert日志出现以下报错：

[ctssd(2224)]CRS-2408:集群时间同步服务已将主机 rac1 上的时钟更新为与集群标准时间同步。

[client(1316)]CRS-10001:23-Nov-16 17:24 ACFS-9391: 正在检查现有 ADVM/ACFS 安装。

[client(1648)]CRS-10001:23-Nov-16 17:24 ACFS-9392: 正在验证操作系统的 ADVM/ACFS安装文件。

[client(2312)]CRS-10001:23-Nov-16 17:24 ACFS-9393: 正在验证 ASM 管理员设置。

[client(1708)]CRS-10001:23-Nov-16 17:24 ACFS-9308: 正在加载已安装的 ADVM/ACFS 驱动程序。

[client(2292)]CRS-10001:23-Nov-16 17:24 ACFS-9154: 正在加载 'oracle oks' 驱动程序。

[client(2312)]CRS-10001:23-Nov-16 17:24 ACFS-9109: oracle oks 驱动程序无法加载。

[client(1796)]CRS-10001:23-Nov-16 17:24 ACFS-9127: 并非所有 ADVM/ACFS 驱动程序均

已加载。

2016-11-23 17:24:20.063:

[C:\app\11.2.0\grid/bin/orarootagent.exe(1324)]CRS-5016:进程 "C:\app\11.2.0\grid
\bin\acfsload.bat" (由代理 "C:\app\11.2.0\grid/bin/orarootagent.exe" 衍生,
用于操作"start") 失败: 详细信息见 "(:CLSN00010:)" (位于
"C:\app\11.2.0\grid\log\rac1\agent\ohasd\orarootagent\orarootagent.log")

2016-11-23 17:24:20.397:

[C:\app\11.2.0\grid/bin/orarootagent.exe(1840)]CRS-5016:进程
"C:\app\11.2.0\grid\bin\acfsload.bat" (由代理
"C:\app\11.2.0\grid/bin/orarootagent.exe" 衍生, 用于操作 "check") 失败: 详细信息见
"(:CLSN00010:)" (位于"C:\app\11.2.0\grid\log\rac

1\agent\ohasd\orarootagent\orarootagent.log")

 **参考** **MOS** **文章：**

 **RAC on Windows: CLSRSC-196: ACFS driver install actions failed: When
Running 'rootcrs.pl -postpatch' (** **文档** **ID 2095606.1)**

 **补丁下载地址：**

 **https://technet.microsoft.com/en-us/library/security/3033929.aspx**



 **注意：** **Windows 2012** **因为在安装** **grid** **时已经安装了** **grid home**
**下的补丁，所有此时只需安装** **oracle home** **下的补丁即可。** **Windows 2008** **的** **grid
home** **和** **oracle home** **均打补丁。**

 ** **

1.   上传opatch soft和最新的Bundle Patch补丁到所有RAC节点上

2.   两个节点均替换OPatch，把 GRID_HOME和DB_HOME上的OPatch进行备份，然后将下载的补丁6880880解压后复制到GRID_HOME和DB_HOME下。

![noteattachment102][0e25883ef5e6caacc3fd4423d09dc492]



按照Bundle Patch补丁中README.html进行以下步骤

> net stop msdtc

> set PATH=%ORACLE_HOME%\perl\bin;%PATH%

在集群中的每个节点上执行以下步骤，一次一个节点。



RAC环境中的修补顺序是Grid Home，后跟Database Home

在修补Grid Home之前，停止OCR相关资源，“unlock”Grid
Home以准备修补并停止Oracle高可用性服务（OHASD）和所有Oracle服务：

> set ORACLE_HOME=<path to Grid Infrastructure home>

例如：

> set ORACLE_HOME=C:\app\11.2.0\grid

> srvctl stop service -d <database name> -s <configured workload management
service> -i <instance name>

> srvctl stop instance -d <database name> -i <instance name>

例如

> srvctl stop instance -d orcl -i orcl1

> %ORACLE_HOME%\perl\bin\perl -I%ORACLE_HOME%\perl\lib
-I%ORACLE_HOME%\crs\install %ORACLE_HOME%\crs\install\rootcrs.pl -unlock

注意：'rootcrs.pl -unlock'包括在本地节点上停止Oracle Clusterware。

验证在要修补的节点上不再有任何资源运行，从运行Grid的另一个节点运行以下命令：

> crsctl status resource -t

该节点上停止所有“Oracle”服务

net start | findstr /i ora



net stop "Oracle Object Service"

net stop OracleMTSRecoveryService

net stop OracleServiceORCL2

禁用和停止（非Oracle）Windows Management Instrumentation服务。

> sc config Winmgmt start= disabled

> net stop winmgmt

使用以下步骤将补丁应用到Grid Home：（确保ORACLE_HOME指向Grid Infrastructure主目录。）

 ** _注意：此步骤在_** ** _Windows 2012_** ** _安装_** ** _oracle home_** **
_补丁时无需操作_**

解压补丁安装包

> cd 24591646

> set ORACLE_HOME=C:\app\11.2.0\grid

> <path to latest version of opatch>\opatch apply -local

例如

> C:\app\11.2.0\grid\OPatch\opatch apply -local

使用以下步骤将补丁应用到Database Home：（确保ORACLE_HOME指向数据库主目录。）

> cd 24591646

> set ORACLE_HOME=C:\app\oracle\product\11.2.0\dbhome_1

> <path to latest version of opatch>\opatch apply -local

例如

> C:\app\oracle\product\11.2.0\dbhome_1\OPatch\opatch apply -local

重新启用（非Oracle）Windows Management Instrumentation服务。

> sc config Winmgmt start= auto

通过运行'rootcrs.pl -patch'来完成修补。

注意：此命令包括Oracle高可用性服务的启动

> set ORACLE_HOME=C:\app\11.2.0\grid

> %ORACLE_HOME%\perl\bin\perl -I%ORACLE_HOME%\perl\lib
-I%ORACLE_HOME%\crs\install %ORACLE_HOME%\crs\install\rootcrs.pl -patch



> srvctl start instance -d <dbname> -i <instance name>

例如

> srvctl start instance -d orcl -i orcl1

启动msdtc和winmgmt

> net start msdtc

> net start winmgmt

Installing OraFence:（注意，此处需要重启两个操作系统）

 ** _注意：此步骤在_** ** _Windows 2012_** ** _安装_** ** _oracle home_** **
_补丁时无需操作_**

> set ORACLE_HOME=C:\app\11.2.0\grid

> %ORACLE_HOME%\bin\crssetup deinstallfence

重新启动节点以使更改生效。

> set ORACLE_HOME=C:\app\11.2.0\grid

> %ORACLE_HOME%\bin\crssetup installfence

重新启动节点以使更改生效。

 **Updating OCFS** : Take a backup of file ocfs.sys located under
%SystemRoot%\System32\drivers.

 Ensure all services and resources listed in step 1 have been stopped before
copying the ocfs.sys

 replace ocfs.sys with ocfs.sys.w2k364 supplied in the patch 24591646. Note
that the filename in %SystemRoot%\System32\drivers is required to be ocfs.sys
and reboot the node.

 When copying OCFS drivers you may need to reboot the node.



 **其他节点重复以上步骤**



在其中一个节点上执行catbundle.sql脚本

cd %ORACLE_HOME%\rdbms\admin

sqlplus /nolog

SQL> CONNECT / AS SYSDBA

SQL> @catbundle.sql PSU apply

SQL> QUIT

在其中一个节点上执行utlrp.sql脚本

cd %ORACLE_HOME%\rdbms\admin

sqlplus /nolog

SQL> CONNECT / AS SYSDBA

SQL> @utlrp.sql

对于在安装BP 11.2.0.4.161018之后已升级或创建的数据库，不需要执行任何操作





## 19、回退Bundle Patch补丁

按照Bundle Patch补丁中README.html进行以下步骤



在集群中的每个节点上执行以下步骤，一次一个节点。

在RAC环境中卸载的顺序是Database Home，然后是Grid Home

> srvctl stop service -d <database name> -s <configured workload management
service> -i <instancename>

> srvctl stop instance -d <dbname> -i <instance name>

例如

> srvctl stop instance -d orcl -i orcl1



> net stop OracleServiceorcl1

> net stop "Oracle orcl1 VSS Writer Service"

> net stop OracleDBConsoleorcl1

> net stop msdtc

> net stop ocfs (required only for OCFS installation)

> net stop orafenceservice

> net stop OracleMTSRecoveryService

> net stop OracleRemExecService

设置指向您的Database Home的ORACLE_HOME环境变量，然后通过输入以下命令运行OPatch实用程序

> set ORACLE_HOME=C:\app\oracle\product\11.2.0\dbhome_1

> C:\app\oracle\product\11.2.0\dbhome_1\OPatch\opatch rollback -id 24591646
-local

从Grid Home卸载修补程序：从Grid Home卸载修补程序之前，“unlock”Grid
Home以准备修补，并停止Oracle高可用性服务（OHASD）和所有Oracle服务：

> set ORACLE_HOME=C:\app\11.2.0\grid

> %ORACLE_HOME%\perl\bin\perl -I%ORACLE_HOME%\perl\lib
-I%ORACLE_HOME%\crs\install %ORACLE_HOME%\crs\install\rootcrs.pl -unlock



> net stop "Oracle Object Service"

> net stop ocfs (required only for OCFS installation)

> net stop orafenceservice

设置指向Grid Home的ORACLE_HOME环境变量，然后通过输入以下命令运行OPatch实用程序

> set ORACLE_HOME=C:\app\11.2.0\grid

> C:\app\11.2.0\grid\OPatch\opatch rollback -id 24591646 -local

通过运行以下命令，在节点上启动Oracle HASD服务（OHASD）和oracle实例

> %ORACLE_HOME%\perl\bin\perl -I%ORACLE_HOME%\perl\lib
-I%ORACLE_HOME%\crs\install %ORACLE_HOME%\crs\install\rootcrs.pl -patch

> srvctl start instance -d <dbname> -i <instance name>

例如

> srvctl start instance -d orcl -i orcl1

在之前安装当前卸载的Bundle Patch补丁时执行catbundle.sql脚本的节点上执行catbundle_PSU_<database
SID>_ROLLBACK.sql脚本

cd %ORACLE_HOME%\rdbms\admin

sqlplus /nolog

SQL> CONNECT / AS SYSDBA

SQL> @catbundle_PSU_<database SID>_ROLLBACK.sql

例如

SQL> @catbundle_PSU_ORCL_ROLLBACK

SQL> QUIT

在其中一个节点上执行utlrp.sql脚本

cd %ORACLE_HOME%\rdbms\admin

sqlplus /nolog

SQL> CONNECT / AS SYSDBA

SQL> @utlrp.sql



 _ _

##  20、卸载软件

### 20.1卸载Oracle Grid Infrastructure

管理员用户登录

Stop the databases and cluster resources:



Run on any node: "srvctl stop database -d <dbname>"

Run on any node: "crsctl stop cluster -all"

Run on all nodes: "crsctl stop crs"



停止与ORACLE_HOME相关的所有正在运行的Oracle服务：

如果要删除Grid Infrastructure Home，请使用命令行命令停止OraFence服务：

'net stop OraFenceService'



在一个节点上使用DBCA删除数据库，使用NETCA删除监听



通过在命令提示符窗口中运行以下步骤删除GRID配置：

所有节点运行：

set path=%path%;C:\app\11.2.0\grid\perl\bin

除最后一个节点的所有节点运行

perl C:\app\11.2.0\grid\crs\install\rootcrs.pl -verbose -deconfig -force

在最后一个节点上运行 此命令将清零OCR和Voting磁盘

perl C:\app\11.2.0\grid\crs\install\rootcrs.pl -verbose -deconfig -force
-lastnode



从OUI清单中删除ORACLE_HOME：

C:\app\11.2.0\grid\OUI\BIN\setup -detachHome ORACLE_HOME=C:\app\11.2.0\grid



删除注册表中的条目

启动注册表编辑器：选择开始>运行> regedit。

转到HKEY_LOCAL_MACHINE\SOFTWARE\ORACLE，删除该条目。

转到HKEY_LOCAL_MACHINE\SOFTWARE\ODBC。 展开所有子项并删除键：“Oracle in <ORACLE_HOME>”。

转到HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services。
删除名称以Oracle或Ora开头的所有键，或具有要删除的ORACLE_HOME或其下的位置的ImagePath字符串条目。

转到HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\OraFenceService并删除该条目。

转到HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\ocfs并删除该条目。

关闭regedit。



删除环境变量

CLASSPATH，ORACLE_HOME，PATH和PERL5LIB。关于oracle的设置



清理开始菜单图标：



右键单击开始按钮，然后选择浏览所有用户。

展开程序文件夹。

删除文件夹Oracle - <ORACLE_HOME>和任何子文件夹。



如果这是服务器上唯一的ORACLE_HOME，请删除C：\ Program Files下的Oracle文件夹。
如果此服务器上有任何其他Oracle产品，请不要删除此项。



重启节点



转到TEMP / TMP目录并删除所有文件和目录。



转到ORACLE_HOME位置并验证所有文件夹/文件已删除。



删除Windows驱动程序文件夹中的群集驱动程序，通常C:\WINDOWS\System32\Drivers：

ocfs.sys

oracleacfs.sys

oracleadvm.sys

oracleoks.sys

orafencedrv.sys

orafenceservice.sys



清空所有节点上的回收站。



您必须重新初始化所有共享磁盘，以允许从集群中的一个节点重新安装一个干净的环境。

参考文档

 **How To Clean up After a Failed (or successful) Oracle Clusterware
Installation on Windows (** **文档** **ID 341214.1)**



重新启动所有节点以确保清除已禁用的Oracle服务和仍驻留在内存中已删除的项目



清空磁盘步骤：

C:\Users\Administrator>diskpart



Microsoft DiskPart 版本 6.1.7601

Copyright (C) 1999-2008 Microsoft Corporation.

在计算机上: RAC1



DISKPART> list disk



  磁盘 ###  状态           大小     可用     Dyn  Gpt

  \--------  \-------------  \-------  \-------  \---  \---

  磁盘 0    联机               50 GB      0 B

  磁盘 1    联机             1024 MB  1984 KB

  磁盘 2    联机             1024 MB  1984 KB

  磁盘 3    联机             1024 MB  1984 KB

  磁盘 4    联机             2048 MB  1984 KB

  磁盘 5    联机             4096 MB  1024 KB



DISKPART> select disk 1



磁盘 1 现在是所选磁盘。



DISKPART> clean all



DiskPart 成功地清除了磁盘。

## 21、收尾工作

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





ASM内存参数设置

Unable To Start ASM (ORA-00838 ORA-04031) On 11.2.0.3/11.2.0.4 If OS CPUs # >
64\. (文档 ID 1416083.1)

SQL> show parameter memory_target

查看ASM实例内存大小，如果值小于1536m，则做如下配置

SQL> alter system set memory_max_target=4096m scope=spfile;

SQL> alter system set memory_target=1536m scope=spfile;

如果当前memory_target值大于1536M，则不作任何变更



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

## 22、部署rman备份脚本

参考rman 备份相关文档



 **至此结束 RAC部署，重启RAC所有服务器，启动后检查相关服务及内容是否正常，方可结束安装。**



相关文档

内部备注

附件

验证码：

  换一张

输入验证码：

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAYAAAA7MK6iAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEgAACxIB0t1+/AAAABZ0RVh0Q3JlYXRpb24gVGltZQAwOS8yNy8xN+stbYgAAAAcdEVYdFNvZnR3YXJlAEFkb2JlIEZpcmV3b3JrcyBDUzbovLKMAAABm0lEQVRIicXXwXGCQBTG8b+7uZsSTAXRCiQVhA6SXLgmJZgO5BguSQnYgR0EK0hKiAUs5rBvGVlBBEG/GWccxf0JC2/fjna7HU3JEz0BQnlNgbF3yBbIgBRIVWR+m8YcHYPzRE+BBfDY+O/KWQELFZmsNZwnegm8tgT9xCoybyfBeaJvgTVwfybqsgECFZm//Q/VwCgy1lrGroYHQEt4JSxzOgRa4GIAMsdy934PiO5npiKTuTNeXAgtrJH5UBPg54IwwJ3CVqO+swEegPea78MhYPfcroFlzTGhwtbevlFXLOrgqeKw4PeC5on+Ap5qjh37BcTPFjtXL/K+DxSAmwY4k7kiT3SGrT7+FWqNwmHJ9DPPE/0MIEtcQPnMO6EOPnYJAT5r8M4osFXYzqEpVXhXFCBT2HbllJTwM1CAtA1cws9AAVK3OqW066tibOGZd0BXKjLhdZdFuWHiC6Cx6zxLzZ4UiaG6kI2KTLEu+AUkwD6fvaMydpESLI9I33hle3u1hr62VssPZtjtSNussHdvJQoNeyeXITZt/1po2U5WDlb1AAAAAElFTkSuQmCC)![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAYAAAA7MK6iAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEgAACxIB0t1+/AAAABZ0RVh0Q3JlYXRpb24gVGltZQAwOS8yNy8xN+stbYgAAAAcdEVYdFNvZnR3YXJlAEFkb2JlIEZpcmV3b3JrcyBDUzbovLKMAAABu0lEQVRIicWX223CQBBFD26AlOAOMJoCQgl0AFQQSoEOoAN3EPLPKHYHKSFUQD686/jFPkysXMkSQsMc1jt7Z3Z2v9/xSVVTYG2eDJh3Qm5AAeRALiJfvpwzF1hVM2APbLz/rq0zcBCRIhqsqgfgLRLY1VFE9kFgVX0BLsDiSahVCaxE5Lv5ZTIxFJPrYnIPgyeAtuCDYLOnU0BruGEAZo9N9X5OCG1qKSKFXfFg5TVURiT2xe4BEmMOrnNaikgG7AKgOxPrgm9UNU2o3MilhapmInLywHcicjLblnpyrkPAUB0HF7wJvdC31EFwFgCeO+CxUIBsdr1e/V3iVzcqFypUdQswAgpALLgFh7qRREGh71yhSjufo6BjwHa1uapmZs9zwo5aD3yLhBaN1+ur9oe5EqrJYQx0jrvaXSoSqnHFJwtd0S+kMfA8BFw2js87w4XUhX/4wLY7nfD4NWEt0w59r46Ys4hsbVUfHIEEQqFauQtasxIAYwbHwOTP6GiNpzXsqWrBdFOIba9A30BWxDX9YKjJXasFNiPoX8MHx9t/G+gferX5wZLqOhKrM9VQ93CWc96drKa4tP0As8vvCUvsIrEAAAAASUVORK5CYII=)

sentinel

管理员（administrator） 用户身份登录并查看以下信息。

&nbsp;

启动任务管理器，查看内存大小

&nbsp;&nbsp;!["1.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124134109_9.png%22/)

右击计算机—&gt;属性—&gt;高级系统设置—&gt;高级—&gt;性能 设置—&gt;高级 查看虚拟内存。

!["2.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124134122_42.png%22/)

修改虚拟内存

&nbsp;

&nbsp;

&nbsp;!["3.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124140104_427.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124140043_937.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124140043_275.png%22/)

&nbsp;

The minimum required RAM is 1.5 GB for grid infrastructure for a cluster, or
2.5 GB for grid infrastructure for a cluster and Oracle RAC. The minimum
required swap space is 1.5 GB. Oracle recommends that you set swap space to
1.5 times the amount of RAM for systems with 2 GB of RAM or less. For systems
with 2 GB to 16 GB RAM, use swap space equal to RAM. For systems with more
than 16 GB RAM, use 16 GB of RAM for swap space. If the swap space and the
grid home are on the same filesystem, then add together their respective disk
space requirements for the total minimum space required.

## 2、修改主机名

!["6.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124140119_750.png%22/)

&nbsp;

注意主机名不能过长,不能超过8个字符，且不能有下划线等特殊符号，不要使用大写字母，建议使用小写字母即可。

修改完主机名务必重启生效

修改administrator登录密码（两台服务器都执行，密码一致）

服务器管理器—&gt;配置—&gt;本地用户和组—&gt;用户—&gt;administrator右键—&gt;设置密码

&nbsp;

## 3、关闭防火墙：

 **Windows 2008**

服务器管理器—&gt;配置&nbsp;
—&gt;高级安全Windows防火墙—&gt;属性—&gt;将域配置文件、专用配置文件、公用配置文件的防火墙全部关闭。

!["7.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124140202_621.png%22/)

 **Windows 2012**

服务器管理器—&gt;工具&nbsp;
—&gt;高级安全Windows防火墙—&gt;属性—&gt;将域配置文件、专用配置文件、公用配置文件的防火墙全部关闭。

  

&nbsp;

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124140219_623.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124140219_304.png%22/)

## 4、将管理员的提升提示行为修改为“不提示，直接提升”：

1. 打开命令提示符，键入“secpol.msc”，以启动“安全策略控制台”管理实用程序。

2. 从“本地安全设置”控制台树中，单击“本地策略”，然后单击“安全选项”

3. 向下滚动至“用户帐户控制: 管理员的提升提示行为”，并双击该项目。

4. 从下拉菜单中，选择：“不提示，直接提升（请求提升的任务将自动以提升的权限运行，而不提示管理员）”

5. 单击“确定”确认更改

  

&nbsp;

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124140237_415.png%22/)

!["11.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124140255_537.png%22/)

## 5、确保管理员组可以管理审核和安全日志：

1. 打开命令提示符，键入“secpol.msc”，以启动“安全策略控制台”管理实用程序。

2. 单击“本地策略”

3. 单击“用户权限分配”

4. 在用户权限分配列表中找到“管理审核和安全日志”并双击该项目。

5. 如果“本地安全设置”选项卡中未列出管理员组，此时请添加该组。

6. 单击“确定”保存更改（如有更改）。

  

&nbsp;!["12.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124140315_715.png%22/)

!["13.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124140328_702.png%22/)

  

## 6、修改默认的非交互式桌面堆栈：

将默认的非交互式桌面堆栈（Non-Interactive Desktop Heap）的大小增加至 1MB，以防止因桌面堆栈耗尽而出现不稳定的情况。

 **有关如何增加该值的信息，请参阅 Document 744125.1** **和 Microsoft** **知识库文章 KB947246**
**。**

如果需要进一步将非交互式桌面堆栈的大小调至 1MB 以上，建议您咨询 Microsoft。

&nbsp;

需要在数据库服务器的注册表中增加桌面堆大小。 它可以在以下位置找到:

\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session
Manager\SubSystems\

编辑类型REG_EXPAND_SZ的Windows值。 它看起来类似于：

%SystemRoot%\system32\csrss.exe ObjectDirectory=\Windows
SharedSection=1024,3072,512 Windows=On SubSystemType=Windows
ServerDll=basesrv,1 ServerDll=winsrv:UserServerDllInitialization,3
ServerDll=winsrv:ConServerDllInitialization,2 ProfileControl=Off
MaxRequestThreads=16

&nbsp;

At this location the following set of values can be seen for
&quot;SharedSection&quot;, 1024,3072,512. The third value (512) is the size of
the desktop heap for each desktop that is associated with a
&quot;noninteractive&quot; window station.

&nbsp;

Increase of the third value to 1024, so the values are now listed as 1024,
3072, 1024 resolved the problem.

&nbsp;

If this value is not present, the size of the desktop heap for noninteractive
window stations will be same as the size specified for interactive window
stations (the second SharedSection value).

!["14.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124140409_742.png%22/)

## 7、修改网卡配置

### 7.1 重命名网卡：

对于公网和私网 (NIC)，请勿将“PUBLIC”和“PRIVATE”（全部大写）用于网络名称，请参考未发布的 Bug 6844099。您可以使用
public 和 private 这两个词的其他形式，例如：Public 和 Private 是可以接受的。

对于公网和私网 (NIC)的网络名称，请勿使用中文命名，否则会出现以下报错：

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124140430_418.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124140430_945.png%22/)

&nbsp;

  

### 7.2 设置网卡优先级

1. 单击“开始”，单击“运行”，键入“ncpa.cpl”，然后单击“确定”。

2. 在窗口顶部的菜单栏中，单击“高级”，选择“高级设置”（对于 Windows 2008，如果“高级”未显示，单击“Alt”以启用该菜单项）。

3. 在“适配器和绑定”选项卡下，使用向上箭头将“公网”接口移至“连接”列表的顶部。

4. 在“绑定顺序”下，使 IPv4 的优先级高于 IPv6

5. 单击“确定”保存更改

&nbsp;

  

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124140502_639.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124140502_659.png%22/)

  

### 7.3 设置网卡\--在 DNS 中注册此连接的地址

取消选中“在 DNS 中注册此连接的地址”。

 **参考： Grid Infrastructure / RAC on Windows: IP Addresses for HOST, VIP, AND
SCAN Get Scrambled Upon Reboot (Doc ID 1504625.1)**

&nbsp;

1. 调用 Server Manager

2. 选择“查看网络连接”

3. 选择“公网”网络接口

4. 从右键菜单中选择“属性”

5. 从“网络”选项卡中选择“Internet 协议版本 4(TCP/IPv4)”

6. 单击“属性”

7. 从“常规”选项卡中单击“高级...”

8. 选择“DNS”选项卡

9. 取消选中“在 DNS 中注册此连接的地址”的单选按钮

  

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124140646_359.png%22/)

!["20.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124140714_336.png%22/)

!["21.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124140726_729.png%22/)

### 7.3 设置网卡—自动跃点（仅限Windows 2012）

公网网卡设置为100，私网网卡设置为300：

  

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124140755_460.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124140755_511.png%22/)

 **RAC on Windows: Grid Infrastructure Installation Fails With OUI-35024 OR
Private Node Name is Pre-Populated into Node Selection Screen (** **文档** **ID
1907834.1)**

##  8、禁用 DHCP 媒体感知

必须禁用 DHCP 媒体感知。

要禁用DHCP 媒体感知，请以管理员用户身份在命令窗口中执行以下命令：

C:\Users\Administrator&gt; netsh interface ipv4 set global
dhcpmediasense=disabled

C:\Users\Administrator&gt; netsh interface ipv6 set global
dhcpmediasense=disabled

&nbsp;

使用以下命令验证更改：

C:\Users\Administrator&gt; netsh interface ipv4 show global

C:\Users\Administrator&gt; netsh interface ipv6 show global

&nbsp;

关闭默认的 SNP 功能

C:\Users\Administrator&gt; netsh int tcp set global chimney=disabled

C:\Users\Administrator&gt; netsh int tcp set global rss=disabled

&nbsp;

使用以下命令验证更改：

C:\Users\Administrator&gt; netsh interface tcp show global

&nbsp;

## 9、网络配置

修改C:\WINDOWS\System32\drivers\etc\hosts文件

192.168.16.40&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

192.168.16.41&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac2

192.168.16.42&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1-vip

192.168.16.43&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac2-vip

192.168.16.44&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac-cluster-scan

10.10.10.10&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac1-priv

10.10.10.11&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac2-priv

&nbsp;

rac1、rac2 对应的是网卡的物理ip ，即public ip

rac1-priv、rac2-priv 对应的是心跳网卡的物理ip&nbsp; 即private ip

rac1-vip、rac2-vip 对应的是虚拟VIP

rac-cluster-scan对应的SCAN ip

&nbsp;

建议客户客户端连接rac群集，访问数据库时使用&nbsp; SCAN&nbsp; ip地址。

 **注意** **：** **vip** **、** **public ip** **、** **scan ip** **必须要在同一个子网网段中。**

 **另外** **对于心跳** **IP** **地址的设置** **，** **不要设置成和客户局域网中存在的** **ip** **网段。**

 **如客户网络是** **192.x.x.x** **则设置心跳为** **10.x.x.x &nbsp; ,**
**心跳地址工程师可以自定义，但也要和客户确认客户局域网络是否有相同** **ip** **地址的服务器，尽量避免干扰。**

&nbsp;

配置完心跳地址后,一定要使用tracert测试心跳网络之间通讯是否正常.心跳通讯是否正常不能简单地通过ping命令来检测.一定要使用tr
tracert默认是采用udp协议.每次执行tracert会发起三次检测,*号表示通讯失败.

正常:

C:\Users\zylong&gt; tracert rac2-priv

通过最多 30 个跃点跟踪

到 zylong-PC [192.168.16.1] 的路由:

&nbsp; 1&nbsp;&nbsp;&nbsp; &lt;1 毫秒&nbsp;&nbsp; &lt;1 毫秒&nbsp;&nbsp; &lt;1 毫秒
zylong-PC [192.168.16.1]

跟踪完成。

## 10、修改TEMP和TMP环境变量

!["24.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124140833_622.png%22/)

## 11、修改操作系统时间

检查多个服务器节点的操作系统时间和时区一致。如果不一致要先手动修改。

## 12、ASM配置共享磁盘

&nbsp;

服务器管理器—&gt;存储—&gt;磁盘管理—&gt;每个磁盘联机并初始化—&gt;新建简单卷—&gt;分配大小—&gt;不分配盘符—&gt;不格式化磁盘—&gt;确定
建立一个无盘符无格式化的磁盘

  

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124140958_618.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124140958_20.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124140958_231.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124140958_204.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124140958_91.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124140958_967.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124140958_546.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124140958_325.png%22/)

注：配置ASM磁盘，可以采用主分区也可以使用logical driver：

Microsoft Windows: Usage of Primary Partitions when installing Grid
Infrastructure with ASM (文档 ID 2223445.1)

  

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124140958_169.png%22/)

&nbsp;

&nbsp;

解压群集安装程序

  

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124141038_632.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124141038_42.png%22/)

&nbsp;

标记磁盘分区以供ASM使用

在Windows资源管理器中导航到Grid Infrastructure安装中的asmtool目录

媒体并双击“asmtoolg.exe”可执行文件。

&nbsp;!["36.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124141221_98.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124141138_976.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124141138_460.png%22/)

  

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124141138_702.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124141138_545.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124141138_676.png%22/)

&nbsp;

## 13、验证安装介质md5值

安装介质如非官方途径下载，需要验证md5值，避免使用网络上被篡改过的恶意介质

 **windows** **：**

 **C:\Users\oracle &gt;certutil&nbsp; -hashfile
p13390677_112040_Linux-x86-64_1of7.zip md5**

 **& nbsp;**

 **得出的值和如下官方提供的** **md5** **值进行对比，如果** **md5** **值不同，则表示文件有可能被篡改过** **，**
**不可以使用。**

 **文件的名字发生变化并不影响** **md5** **值的校验结果。**

&nbsp;

详见《Oracle各版本安装包md5校验手册v2.docx》

&nbsp;

## 14、安装 Oracle Grid Infrastructure

以下截图内值均未参考选项，以实际内容为准。

  

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124141444_298.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124141444_928.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124141444_284.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124141445_200.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124141445_21.png%22/)

  

  

注意： SCAN name 必须和hosts文件里的scan name 一致

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124141532_949.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124141532_38.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124141532_354.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124141532_760.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124141532_758.png%22/)

&nbsp;

此处要求存储工程师划分5个5G的LUN 用来做CRS磁盘组

此处冗余模式 Redundancy要选择High

下方勾选5个5G的磁盘。

!["52.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124141603_929.png%22/)

 **ASM** **必须达到一定的密码标准。密码中要包含字母大写、小写、数字，至少** **8** **个字符。**

&nbsp;

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124141705_514.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124141705_651.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124141705_987.png%22/)

如果只有以上一个条件不满足，勾选右上角的全部忽略，如果存在其他条件不满足则要进行相应处理。

&nbsp;

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124141743_372.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124141743_84.png%22/)

  

&nbsp;

 **在** **Windows 2012** **上会出现以下错误：**

!["58.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124141808_465.png%22/)

查看grid安装日志：

C:\Temp\2\OraInstall2016-11-22_12-53-06PM\
installActions2016-11-22_12-53-06PM.log

查看grid安装后配置日志，相当于linux系统安装grid后执行root.sh脚本：

C:\app\11.2.0\grid\cfgtoollogs\crsconfig\ rootcrs_rac1.log

2016-11-27 16:35:46: The &#39;ROOTCRS_ACFSINST&#39; is either in START/FAILED
state

2016-11-27 16:35:46: Executing &#39;C:\app\11.2.0\grid\bin\acfsroot.bat
install&#39;

2016-11-27 16:35:46: Executing cmd: C:\app\11.2.0\grid\bin\acfsroot.bat
install

2016-11-27 16:35:47: Command output:

&gt;&nbsp; ACFS-9300: 已找到 ADVM/ACFS 分发文件。

&gt;&nbsp; ACFS-9307: 正在安装请求的 ADVM/ACFS 软件。

&gt;&nbsp; acfsinstall: ACFS-09420: 当前未在此节点上安装驱动程序。

&gt;&nbsp; acfsinstall: ACFS-09411: CreateService 成功。

&gt;&nbsp; acfsinstall: CLSU-00100: 操作系统功能: StartDriver 失败, 错误数据: 31

&gt;&nbsp; acfsinstall: CLSU-00101: 操作系统错误消息: 连到系统上的设备没有发挥作用。

&gt;&nbsp; acfsinstall: CLSU-00103: 错误位置: StartDriver_

&gt;&nbsp; acfsinstall: ACFS-09419: StartService 失败。

&gt;&nbsp; acfsinstall: ACFS-09401: 无法安装驱动程序。

&gt;&nbsp;

&gt;&nbsp; ACFS-9340: 无法安装 OKS 驱动程序。

&gt;&nbsp; acfsinstall: ACFS-09420: 当前未在此节点上安装驱动程序。

&gt;&nbsp; acfsinstall: ACFS-09411: CreateService 成功。

&gt;&nbsp; acfsinstall: CLSU-00100: 操作系统功能: StartDriver 失败, 错误数据: 1068

&gt;&nbsp; acfsinstall: CLSU-00101: 操作系统错误消息: 依赖服务或组无法启动。

&gt;&nbsp; acfsinstall: CLSU-00103: 错误位置: StartDriver_

&gt;&nbsp; acfsinstall: ACFS-09419: StartService 失败。

&gt;&nbsp; acfsinstall: ACFS-09401: 无法安装驱动程序。

&gt;&nbsp;

&gt;&nbsp; ACFS-9340: 无法安装 ADVM 驱动程序。

&gt;&nbsp; acfsinstall: ACFS-09420: 当前未在此节点上安装驱动程序。

&gt;&nbsp; acfsinstall: ACFS-09411: CreateService 成功。

&gt;&nbsp; acfsinstall: CLSU-00100: 操作系统功能: StartDriver 失败, 错误数据: 1068

&gt;&nbsp; acfsinstall: CLSU-00101: 操作系统错误消息: 依赖服务或组无法启动。

&gt;&nbsp; acfsinstall: CLSU-00103: 错误位置: StartDriver_

&gt;&nbsp; acfsinstall: ACFS-09419: StartService 失败。

&gt;&nbsp; acfsinstall: ACFS-09401: 无法安装驱动程序。

&gt;&nbsp;

&gt;&nbsp; ACFS-9340: 无法安装 ACFS 驱动程序。

&gt;&nbsp; ACFS-9310: ADVM/ACFS 安装失败。

&gt;End Command output

2016-11-27 16:35:47: C:\app\11.2.0\grid\bin\acfsroot.bat install ... failed

2016-11-27 16:35:47: USM driver install status is 0

2016-11-27 16:35:47: USM driver install actions failed

2016-11-27 16:35:47: Running as user Administrator:
C:\app\11.2.0\grid\bin\cluut

il -ckpt -oraclebase C:\app\grid -writeckpt -name ROOTCRS_ACFSINST -state FAIL

2016-11-27 16:35:47: s_run_as_user2: Running C:\app\11.2.0\grid\bin\cluutil
-ckp

t -oraclebase C:\app\grid -writeckpt -name ROOTCRS_ACFSINST -state FAIL

2016-11-27 16:35:47: C:\app\11.2.0\grid\bin\cluutil successfully executed

&nbsp;

2016-11-27 16:35:47: Succeeded in writing the
checkpoint:&#39;ROOTCRS_ACFSINST&#39; with

&nbsp;status:FAIL

2016-11-27 16:35:47: CkptFile: C:\app\grid\Clusterware\ckptGridHA_rac1.xml

2016-11-27 16:35:47: Sync the checkpoint file
&#39;C:\app\grid\Clusterware\ckptGridH

A_rac1.xml&#39;

参考文档：

 **[INS-20802] Grid Infrastructure failed During Grid Installation On Windows
OS (** **文档** **ID 1987371.1)**

解决方法：

For Existing Installations:

Bug:17927204 is first fixed in Windows DB Bundle Patch 11.2.0.4.11 or higher.
At the time of writting the solution, the latest version is 11.2.0.4.14, which
is available as Patch 20502905 WINDOWS DB BUNDLE PATCH 11.2.0.4.14.

Close the installation UI on the nodes.

Then on first node, perform de-configuration by running the following:
GI_HOME\crs\install\rootcrs.pl -deconfig -force

Apply Patch 20502905 WINDOWS DB BUNDLE PATCH 11.2.0.4.14 to the nodes.

Run config.bat from GI_HOME\crs\config to configure Grid Infrastructure in a
clustered environment (OR &#39;Grid_home\perl\bin\perl -IGrid_home\perl\lib
-IGrid_home\crs\install Grid_home\crs\install\roothas.pl&#39; for a Grid
Infrastructure standalone / Oracle Restart environment)

The following error may be seen after running the config.bat : &quot;ACFS
drivers installation failed&quot; to resolve the error run ASMCA to configure
ACFS. &nbsp;To resolve the error run ASMCA to configure ACFS on cluster
env.&nbsp; Run following in on standalone (Restart) env.  
  
&nbsp;&nbsp; 1) cd Grid_home\oui\bin  
&nbsp;&nbsp; 2) setup.exe -updateNodeList ORACLE_HOME=Grid_home CLUSTER_NODES=
CRS=TRUE  
&nbsp;&nbsp; 3) run ASMCA to configure ACFS

解决过程：

  1. 回退grid安装后的配置操作

C:\Windows\system32&gt; **set ORACLE_HOME=C:\app\11.2.0\grid**

C:\Windows\system32&gt; **%ORACLE_HOME%\perl\bin\perl -I%ORACLE_HOME%\perl\lib
-I%ORACLE_HOME%\crs\install %ORACLE_HOME%\crs\install\rootcrs.pl -deconfig
-force**

2016-11-27 16:42:42: Checking for super user privileges

2016-11-27 16:42:42: superUser=Administrator groupName=Administrators

2016-11-27 16:42:42: domain=WORKGROUP user=ADMINISTRATOR

2016-11-27 16:42:42: C:\app\11.2.0\grid\bin\crssetup.exe getsystem

2016-11-27 16:42:42: Executing cmd: C:\app\11.2.0\grid\bin\crssetup.exe
getsyste

m

2016-11-27 16:42:42: Command output:

&gt;&nbsp; SYSTEM

&gt;End Command output

2016-11-27 16:42:42: User has Administrator privileges

Using configuration parameter file:
C:\app\11.2.0\grid\crs\install\crsconfig_par

ams

PRCR-1119 : 无法查找 ora.cluster_vip_net1.type 类型的 CRS 资源

PRCR-1068 : 无法查询资源

Cannot communicate with crsd

PRCR-1070 : 无法检查 资源 ora.gsd 是否已注册

Cannot communicate with crsd

PRCR-1070 : 无法检查 资源 ora.ons 是否已注册

Cannot communicate with crsd

&nbsp;

CRS-4535: 无法与集群就绪服务通信

CRS-4000: 命令 Stop 失败, 或已完成但出现错误。

CRS-4133: Oracle 高可用性服务已停止。

Remove Oracle Fence Service... C:\app\11.2.0\grid\bin\crssetup.exe
deinstallfenc

e

&lt;16:43:11&gt; Started

&lt;16:43:11&gt; arguements 2

&lt;16:43:11&gt;&nbsp;&nbsp; C:\app\11.2.0\grid\bin\crssetup.exe

&lt;16:43:11&gt;&nbsp;&nbsp; deinstallfence

&lt;16:43:11&gt; returning 0x0

Successfully deconfigured Oracle clusterware stack on this node

  1. 安装最新的Bundle Patch补丁，只安装到grid home下

上传opatch soft和最新的Bundle Patch补丁到所有RAC节点上

两个节点均替换OPatch，把 GRID_HOME上的OPatch进行备份，然后将下载的补丁6880880解压后复制到GRID_HOME下。

&nbsp;

!["59.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124141840_70.png%22/)

按照Bundle Patch补丁中README.html进行以下步骤

C:\Windows\system32&gt;net stop msdtc

Distributed Transaction Coordinator 服务正在停止.

Distributed Transaction Coordinator 服务已成功停止。

&nbsp;

C:\Windows\system32&gt;set PATH=%ORACLE_HOME%\perl\bin;%PATH%

&nbsp;

C:\Windows\system32&gt;set ORACLE_HOME=C:\app\11.2.0\grid

&nbsp;

C:\Windows\system32&gt;net start | findstr /i ora

&nbsp;&nbsp; OracleRemExecService

&nbsp;

C:\Windows\system32&gt; net stop OracleRemExecService

OracleRemExecService 服务已成功停止。

&nbsp;

C:\Windows\system32&gt;sc config Winmgmt start= disabled

[SC] ChangeServiceConfig 成功

&nbsp;

C:\Windows\system32&gt;net stop winmgmt

下面的服务依赖于 Windows Management Instrumentation 服务。

停止 Windows Management Instrumentation 服务也会停止这些服务。

&nbsp;&nbsp; User Access Logging Service

&nbsp;&nbsp; IP Helper

你想继续此操作吗? (Y/N) [N]: y

User Access Logging Service 服务正在停止.

User Access Logging Service 服务已成功停止。

IP Helper 服务正在停止.

IP Helper 服务已成功停止。

Windows Management Instrumentation 服务正在停止.

Windows Management Instrumentation 服务已成功停止。

&nbsp;

C:\Windows\system32&gt;cd C:\soft\psu\24591646

&nbsp;

C:\soft\psu\24591646&gt; **C:\app\11.2.0\grid\OPatch\opatch apply -local**

Oracle 中间补丁程序安装程序版本 11.2.0.3.15

版权所有 (c) 2016, Oracle Corporation。保留所有权利。

Oracle Home&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : C:\app\11.2.0\grid

Central Inventory : C:\Program Files\Oracle\Inventory

&nbsp;&nbsp; from&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
:

OPatch version&nbsp;&nbsp;&nbsp; : 11.2.0.3.15

OUI version&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : 11.2.0.4.0

Log file location :
C:\app\11.2.0\grid\cfgtoollogs\opatch\opatch2016-11-27_16-51

-17下午_1.log

Verifying environment and performing prerequisite checks...

OPatch continues with these patches:&nbsp;&nbsp; 24591646

是否继续? [y|n]

 **y**

User Responded with: Y

All checks passed.

提供电子邮件地址以用于接收有关安全问题的通知, 安装 Oracle Configuration Manager

并启动它。如果您使用 My Oracle

Support 电子邮件地址/用户名, 操作将更简单。

有关详细信息, 请访问 http://www.oracle.com/support/policies.html。

电子邮件地址/用户名:

尚未提供电子邮件地址以接收有关安全问题的通知。

是否不希望收到有关安全问题 (是 [Y], 否 [N]) [N] 的通知: **& nbsp;y**

请关闭本地系统上在此 ORACLE_HOME 之外运行的 Oracle 实例。

(Oracle 主目录 = &#39;C:\app\11.2.0\grid&#39;)

本地系统是否已准备打补丁? [y|n]

 **y**

User Responded with: Y

Backing up files...

Applying interim patch &#39;24591646&#39; to OH &#39;C:\app\11.2.0\grid&#39;

ApplySession: Oracle 主目录中不存在可选组件 [ oracle.ovm, 11.2.0.4.0 ] , [ oracl

e.rdbms.oci, 11.2.0.4.0 ] , [ oracle.owb.rsf, 11.2.0.4.0 ] , [ oracle.sdo,
11.2.

0.4.0 ] , [ oracle.sysman.agent, 10.2.0.4.5 ] , [ oracle.rdbms.hsodbc,
11.2.0.4.

0 ] , [ oracle.rdbms.tg4msql, 11.2.0.4.0 ] , [ oracle.rdbms.tg4sybs,
11.2.0.4.0

] , [ oracle.rdbms.tg4tera, 11.2.0.4.0 ] , [ oracle.rdbms.tg4ifmx, 11.2.0.4.0
]

, [ oracle.rdbms.tg4db2, 11.2.0.4.0 ] , [ oracle.xdk, 11.2.0.4.0 ] , [
oracle.ct

x, 11.2.0.4.0 ] , [ oracle.precomp.common, 11.2.0.4.0 ] , [ oracle.oraolap,
11.2

.0.4.0 ] , [ oracle.oraolap.api, 11.2.0.4.0 ] , [ oracle.odbc.ic, 11.2.0.4.0 ]
,

&nbsp;[ oracle.rdbms.ic, 11.2.0.4.0 ] , [ oracle.rdbms.dv, 11.2.0.4.0 ] , [
oracle.nt

oledb, 11.2.0.4.0 ] , [ oracle.ntoledb.odp_net_2, 11.2.0.4.0 ] , [
oracle.sysman

.console.db, 11.2.0.4.0 ] , 或找到更高版本。

正在为组件 oracle.rdbms.deconfig, 11.2.0.4.0 打补丁...

正在为组件 oracle.rdbms.dbscripts, 11.2.0.4.0 打补丁...

正在为组件 oracle.sqlplus.ic, 11.2.0.4.0 打补丁...

正在为组件 oracle.sqlplus, 11.2.0.4.0 打补丁...

正在为组件 oracle.rdbms.rsf, 11.2.0.4.0 打补丁...

正在为组件 oracle.rdbms.rsf.ic, 11.2.0.4.0 打补丁...

正在为组件 oracle.ldap.owm, 11.2.0.4.0 打补丁...

正在为组件 oracle.rdbms.plsql, 11.2.0.4.0 打补丁...

正在为组件 oracle.xdk.parser.java, 11.2.0.4.0 打补丁...

正在为组件 oracle.xdk.rsf, 11.2.0.4.0 打补丁...

正在为组件 oracle.rdbms.rman, 11.2.0.4.0 打补丁...

正在为组件 oracle.sdo.locator, 11.2.0.4.0 打补丁...

正在为组件 oracle.rdbms, 11.2.0.4.0 打补丁...

正在为组件 oracle.nlsrtl.rsf, 11.2.0.4.0 打补丁...

正在为组件 oracle.oraolap.dbscripts, 11.2.0.4.0 打补丁...

正在为组件 oracle.ldap.rsf.ic, 11.2.0.4.0 打补丁...

正在为组件 oracle.rdbms.util, 11.2.0.4.0 打补丁...

正在为组件 oracle.network.rsf, 11.2.0.4.0 打补丁...

正在为组件 oracle.network.aso, 11.2.0.4.0 打补丁...

正在为组件 oracle.ordim.client, 11.2.0.4.0 打补丁...

正在为组件 oracle.ordim.jai, 11.2.0.4.0 打补丁...

正在为组件 oracle.has.cfs, 11.2.0.4.0 打补丁...

正在为组件 oracle.has.common.cvu, 11.2.0.4.0 打补丁...

正在为组件 oracle.has.common, 11.2.0.4.0 打补丁...

正在为组件 oracle.has.crs, 11.2.0.4.0 打补丁...

正在为组件 oracle.has.cvu, 11.2.0.4.0 打补丁...

正在为组件 oracle.has.db, 11.2.0.4.0 打补丁...

正在为组件 oracle.has.rsf, 11.2.0.4.0 打补丁...

正在为组件 oracle.usm, 11.2.0.4.0 打补丁...

Patch 24591646 successfully applied.

Log file location:
C:\app\11.2.0\grid\cfgtoollogs\opatch\opatch2016-11-27_16-51-

17下午_1.log

OPatch succeeded.

&nbsp;

C:\soft\psu\24591646&gt;sc config Winmgmt start= auto

[SC] ChangeServiceConfig 成功

&nbsp;

C:\soft\psu\24591646&gt;net start msdtc

Distributed Transaction Coordinator 服务正在启动 .

Distributed Transaction Coordinator 服务已经启动成功。

&nbsp;

C:\soft\psu\24591646&gt;net start winmgmt

Windows Management Instrumentation 服务正在启动 .

Windows Management Instrumentation 服务已经启动成功。

&nbsp;

C:\soft\psu\24591646&gt;sc query OraFenceService

SERVICE_NAME: OraFenceService

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
TYPE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
: 1&nbsp; KERNEL_DRIVER

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
STATE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
: 4&nbsp; RUNNING

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
(STOPPABLE, NOT_PAUSABLE, IGNORES_SHUTDOWN)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; WIN32_EXIT_CODE&nbsp;&nbsp;&nbsp; :
0&nbsp; (0x0)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; SERVICE_EXIT_CODE&nbsp; : 0&nbsp;
(0x0)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
CHECKPOINT&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : 0x0

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
WAIT_HINT&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : 0x0

&nbsp;

C:\soft\psu\24591646&gt;sc qc OraFenceService

[SC] QueryServiceConfig 成功

SERVICE_NAME: OraFenceService

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
TYPE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
: 1&nbsp; KERNEL_DRIVER

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
START_TYPE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : 4&nbsp;&nbsp;
DISABLED

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ERROR_CONTROL&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : 1&nbsp;&nbsp; NORMAL

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; BINARY_PATH_NAME&nbsp;&nbsp; :

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; LOAD_ORDER_GROUP&nbsp;&nbsp; :

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
TAG&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
: 0

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
DISPLAY_NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : OraFenceService

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
DEPENDENCIES&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; :

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; SERVICE_START_NAME :

&nbsp;

C:\soft\psu\24591646&gt;%ORACLE_HOME%\bin\crssetup deinstallfence

&lt;16:59:24&gt; Started

&lt;16:59:24&gt; arguements 2

&lt;16:59:24&gt;&nbsp;&nbsp; C:\app\11.2.0\grid\bin\crssetup

&lt;16:59:24&gt;&nbsp;&nbsp; deinstallfence

&lt;16:59:24&gt; failed to delete OraFenceService service. 指定的服务已标记为删除。

&nbsp;

&lt;16:59:24&gt; returning 0x2000001

重新启动当前操作系统

&nbsp;

C:\Windows\system32&gt;set ORACLE_HOME=C:\app\11.2.0\grid

C:\Windows\system32&gt;%ORACLE_HOME%\bin\crssetup installfence

&lt;17:05:27&gt; Started

&lt;17:05:27&gt; arguements 2

&lt;17:05:27&gt;&nbsp;&nbsp; C:\app\11.2.0\grid\bin\crssetup

&lt;17:05:27&gt;&nbsp;&nbsp; installfence

&lt;17:05:27&gt; Warning:&nbsp; failed to remove imagePath, continuing.
操作成功完成。

&nbsp;

&lt;17:05:28&gt; returning 0x0

重新启动当前操作系统

&nbsp;

第二个节点打补丁，打完补丁最好重新启动一下操作系统

  1. 执行config.bat配置grid集群。

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142031_402.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142031_693.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142031_425.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142031_489.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142031_194.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142031_743.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142031_302.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142031_583.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142032_434.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142032_257.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142032_930.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142032_599.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142032_414.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142032_476.png%22/)

15、集群安装后的任务

&nbsp;(1)、验证oracle clusterware的安装

以administrator身份运行以下命令：

检查crs状态：

C:\&gt;crsctl check crs

CRS-4638: Oracle 高可用性服务联机

CRS-4537: 集群就绪服务联机

CRS-4529: 集群同步服务联机

CRS-4533: 事件管理器联机

&nbsp;

检查 Clusterware 资源:

C:\&gt;crsctl stat res -t

\--------------------------------------------------------------------------------

NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; TARGET&nbsp;
STATE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
SERVER&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
STATE_DETAILS

\--------------------------------------------------------------------------------

Local Resources

\--------------------------------------------------------------------------------

ora.CRS.dg

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac2

ora.LISTENER.lsnr

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac2

ora.asm

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Started

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Started

ora.gsd

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
OFFLINE OFFLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
OFFLINE OFFLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac2

ora.net1.network

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac2

ora.ons

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac2

ora.registry.acfs

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac2

\--------------------------------------------------------------------------------

Cluster Resources

\--------------------------------------------------------------------------------

ora.LISTENER_SCAN1.lsnr

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

ora.cvu

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

ora.oc4j

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

ora.rac1.vip

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

ora.rac2.vip

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac2

ora.scan1.vip

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

&nbsp;

检查集群节点:

C:\&gt;olsnodes -n

rac1&nbsp;&nbsp;&nbsp; 1

rac2&nbsp;&nbsp;&nbsp; 2

检查两个节点上的 Oracle TNS 监听器进程:

C:\&gt;srvctl status listener

监听程序 LISTENER 已启用

监听程序 LISTENER 正在节点上运行: rac2,rac1

&nbsp;

(2)为数据和快速恢复区创建 ASM 磁盘组

asmca

!["74.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142112_978.png%22/)

&nbsp;

在 Disk Groups 选项卡中，单击 **创建** 按钮，在出现的画面中创建data卷：

除了CRS磁盘组以外其余存放数据和归档的磁盘组默认都是选择Extenal外部冗余模式，除非客户特殊要求。

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142145_395.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142145_705.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142145_456.png%22/)

对于磁盘组的规划，一般一套rac 含有一个CRS磁盘组，一个FRA磁盘组用于存放归档日志，一个或者多个DATA磁盘组用于存放数据。

单击 **退出** 退出ASM配置向导。

 **至此重启下服务器确认** **crs** **各个资源状态均正常。**

##  16、安装oracle 11g r2 database

!["78.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142402_938.png%22)

选择 **Real Application Clusters database installation** 单选按钮（此为默认选择），确保选中 Node
Name 窗口中的两个 Oracle RAC 节点。

!["79.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142429_801.png%22)

 **在** **Windows 2012** **上会出现以下错误：**

!["80.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142444_164.png%22)

C:\&gt;crsctl status res -t

\--------------------------------------------------------------------------------

NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; TARGET&nbsp;
STATE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
SERVER&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
STATE_DETAILS

\--------------------------------------------------------------------------------

Local Resources

\--------------------------------------------------------------------------------

ora.CRS.dg

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac2

ora.DATA.dg

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac2

ora.FRA.dg

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac2

ora.LISTENER.lsnr

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac2

ora.asm

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;rac1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Started

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Started

ora.gsd

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
OFFLINE OFFLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
OFFLINE OFFLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac2

ora.net1.network

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac2

ora.ons

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac2

ora.registry.acfs

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac2

\--------------------------------------------------------------------------------

Cluster Resources

\--------------------------------------------------------------------------------

ora.LISTENER_SCAN1.lsnr

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

ora.cvu

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

ora.oc4j

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

ora.rac1.vip

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

ora.rac2.vip

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac2

ora.scan1.vip

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

 **参考文档：**

 **Windows: Prerequisite Error INS-35423 And Warnings When Installing RAC
Database Software (** **文档** **ID 2164220.1)**

解决方法：

Known issue in bug 19065263, will be fixed in release 12.2.

The workaround is to run setup.exe and pass the hostname.  
e.g.

C:\&gt;setup.exe ORACLE_HOSTNAME=RACNODE1

&nbsp;

解决过程：

!["81.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142516_49.png%22)

&nbsp;

C:\&gt;cd C:\soft\database

C:\soft\database&gt;setup.exe ORACLE_HOSTNAME=rac1

!["82.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142637_254.png%22)

!["83.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142655_97.png%22)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142603_99.png%22/)

&nbsp;  

 **在** **Windows 2008** **上会出现以下错误，全部忽略即可：**

!["85.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142728_653.png%22)

2012

!["86.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142751_133.png%22)

待安装完成后退出向导。

## 17、创建、删除数据库

建议

数据文件，归档日志分开存放在不同的，文件系统路径或ASM路径中

控制文件和在线日志多路复用时，放在不同的，磁盘驱动器或ASM磁盘组中

数据库位于文件系统时，将数据文件和在线日志放在不同的磁盘驱动器中

### 17.1 创建数据库

&nbsp;使用dbca创建，创建之前确保已安装的所有服务（Oracle TNS 监听器、Oracle Clusterware 进程等）正在运行。

C:\&gt;crsctl status res -t

\--------------------------------------------------------------------------------

NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; TARGET&nbsp;
STATE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
SERVER&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
STATE_DETAILS

\--------------------------------------------------------------------------------

Local Resources

\--------------------------------------------------------------------------------

ora.CRS.dg

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE &nbsp;ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac2

ora.DATA.dg

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac2

ora.FRA.dg

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac2

ora.LISTENER.lsnr

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac2

ora.asm

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Started

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
rac2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Started

ora.gsd

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
OFFLINE OFFLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
OFFLINE OFFLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac2

ora.net1.network

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac2

ora.ons

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac2

ora.registry.acfs

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac2

\--------------------------------------------------------------------------------

Cluster Resources

\--------------------------------------------------------------------------------

ora.LISTENER_SCAN1.lsnr

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

ora.cvu

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

ora.oc4j

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

ora.rac1.vip

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

ora.rac2.vip

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac2

ora.scan1.vip

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rac1

&nbsp;

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142901_975.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142901_259.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142901_43.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142901_70.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142901_946.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142901_666.png%22/)

&nbsp;  

  

点击&quot;Multiplex Redo Logs and Control Files&quot; 输入多个磁盘组来产生冗余控制文件和redo文件。

如果存在+FRA则填写 +DATA和+FRA

如果不存在+FRA，只有+DATA ，则添加两个+DATA

原则就是要多个控制文件和redo文件，而且尽量要存放在不同的磁盘组中。

!["94.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142914_714.png%22)

注意将“归档日志文件格式”中的“S”修改为“s”，否则alert日志中可能会出现如下警告：

Tue Aug 29 09:18:52 中国标准时间 2017

ARC0: Warning.&nbsp; Log sequence in archive filename wrapped

to fix length as indicated by %S in LOG_ARCHIVE_FORMAT.

Old log archive with same name might be overwritten.

Tue Aug 29 09:19:17 中国标准时间 2017

Thread 1 advanced to log sequence 118540 (LGWR switch)

LOG_ARCHIVE_FORMAT默认情况下使用%S，而%S是固定字符长度为5，也就是说，当归档日志的sequence超过了99999以后，就会提示类似警告，只截取其中的5个数字，因此有可能归档日志名字完全相同被覆盖，因此alert日志出现如上警告。

LOG_ARCHIVE_FORMAT is applicable only if you are using the redo log in
ARCHIVELOG mode. Use a text string and variables to specify the default
filename format when archiving redo log files. The string generated from this
format is appended to the string specified in the LOG_ARCHIVE_DEST parameter.

The following variables can be used in the format:

%s log sequence number

%S log sequence number, zero filled

%t thread number

%T thread number, zero filled

Using uppercase letters for the variables (for example, %S) causes the value
to be fixed length and padded to the left with zeros.&nbsp;

&nbsp;

!["95.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124142930_42.png%22)

&nbsp;

保守的设置原则是 ：

SGA_TARGET+pga_aggregate_target=物理内存*0.6

SGA_TARGET : pga_aggregate_target &nbsp;比例是4:1

SGA_TARGET 等于 SGA_MAX_SIZE

&nbsp;

根据实际物理内存进行调整。

!["95.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124143027_701.png%22)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124143010_767.png%22/)

  

字符集的必须和开发人员进行确认，不能猜测使用，数据库建立完成后字符集不能进行修改。

!["98.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124143041_147.png%22)

这里得注意新加的两组日志一个是线程Thread# 1，一个是线程Thread# 2

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124143111_280.png%22/)

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124143111_652.png%22/)

![""](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124143111_663.png%22)

### 17.2 删除数据库

删除数据库最好也用dbca，虽然srvctl也可以。

  1. 运行dbca，选择”delete a database”。然后就next..，直到finish。

  2. 数据的删除并不影响asm实例，如果想删除与asm有关的内容，可以按如下做法：

# export ORACLE_SID= _ASM_instance_name_

# sqlplus / as sysdba

SQL&gt; drop diskgroup _diskgroup_name_ including contents;

SQL&gt; quit

然后在各个节点上执行

# srvctl stop asm –n hostname

# srvctl remove asm –n hostname

这样，应该就可以删除的比较干净了。

## 18、安装Bundle Patch补丁

对于Windows
2008R2，在打补丁之前先安装操作系统补丁KB3033929（Windows6.1-KB3033929-x64.msu），否则ACFS资源无法启动，集群alert日志出现以下报错：

[ctssd(2224)]CRS-2408:集群时间同步服务已将主机 rac1 上的时钟更新为与集群标准时间同步。

[client(1316)]CRS-10001:23-Nov-16 17:24 ACFS-9391: 正在检查现有 ADVM/ACFS 安装。

[client(1648)]CRS-10001:23-Nov-16 17:24 ACFS-9392: 正在验证操作系统的 ADVM/ACFS安装文件。

[client(2312)]CRS-10001:23-Nov-16 17:24 ACFS-9393: 正在验证 ASM 管理员设置。

[client(1708)]CRS-10001:23-Nov-16 17:24 ACFS-9308: 正在加载已安装的 ADVM/ACFS 驱动程序。

[client(2292)]CRS-10001:23-Nov-16 17:24 ACFS-9154: 正在加载 &#39;oracle oks&#39;
驱动程序。

[client(2312)]CRS-10001:23-Nov-16 17:24 ACFS-9109: oracle oks 驱动程序无法加载。

[client(1796)]CRS-10001:23-Nov-16 17:24 ACFS-9127: 并非所有 ADVM/ACFS 驱动程序均

已加载。

2016-11-23 17:24:20.063:

[C:\app\11.2.0\grid/bin/orarootagent.exe(1324)]CRS-5016:进程
&quot;C:\app\11.2.0\grid \bin\acfsload.bat&quot; (由代理
&quot;C:\app\11.2.0\grid/bin/orarootagent.exe&quot; 衍生, 用于操作&quot;start&quot;)
失败: 详细信息见 &quot;(:CLSN00010:)&quot; (位于
&quot;C:\app\11.2.0\grid\log\rac1\agent\ohasd\orarootagent\orarootagent.log&quot;)

2016-11-23 17:24:20.397:

[C:\app\11.2.0\grid/bin/orarootagent.exe(1840)]CRS-5016:进程
&quot;C:\app\11.2.0\grid\bin\acfsload.bat&quot; (由代理
&quot;C:\app\11.2.0\grid/bin/orarootagent.exe&quot; 衍生, 用于操作
&quot;check&quot;) 失败: 详细信息见 &quot;(:CLSN00010:)&quot;
(位于&quot;C:\app\11.2.0\grid\log\rac

1\agent\ohasd\orarootagent\orarootagent.log&quot;)

 **参考** **MOS** **文章：**

 **RAC on Windows: CLSRSC-196: ACFS driver install actions failed: When
Running &#39;rootcrs.pl -postpatch&#39; (** **文档** **ID 2095606.1)**

 **补丁下载地址：**

 **https://technet.microsoft.com/en-us/library/security/3033929.aspx**

&nbsp;

 **注意：** **Windows 2012** **因为在安装** **grid** **时已经安装了** **grid home**
**下的补丁，所有此时只需安装** **oracle home** **下的补丁即可。** **Windows 2008** **的** **grid
home** **和** **oracle home** **均打补丁。**

 **& nbsp;**

1.&nbsp;&nbsp; 上传opatch soft和最新的Bundle Patch补丁到所有RAC节点上

2.&nbsp;&nbsp; 两个节点均替换OPatch，把
GRID_HOME和DB_HOME上的OPatch进行备份，然后将下载的补丁6880880解压后复制到GRID_HOME和DB_HOME下。

!["102.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124143148_190.png%22)

&nbsp;

按照Bundle Patch补丁中README.html进行以下步骤

&gt; net stop msdtc

&gt; set PATH=%ORACLE_HOME%\perl\bin;%PATH%

在集群中的每个节点上执行以下步骤，一次一个节点。

&nbsp;

RAC环境中的修补顺序是Grid Home，后跟Database Home

在修补Grid Home之前，停止OCR相关资源，“unlock”Grid
Home以准备修补并停止Oracle高可用性服务（OHASD）和所有Oracle服务：

&gt; set ORACLE_HOME=&lt;path to Grid Infrastructure home&gt;

例如：

&gt; set ORACLE_HOME=C:\app\11.2.0\grid

&gt; srvctl stop service -d &lt;database name&gt; -s &lt;configured workload
management service&gt; -i &lt;instance name&gt;

&gt; srvctl stop instance -d &lt;database name&gt; -i &lt;instance name&gt;

例如

&gt; srvctl stop instance -d orcl -i orcl1

&gt; %ORACLE_HOME%\perl\bin\perl -I%ORACLE_HOME%\perl\lib
-I%ORACLE_HOME%\crs\install %ORACLE_HOME%\crs\install\rootcrs.pl -unlock

注意：&#39;rootcrs.pl -unlock&#39;包括在本地节点上停止Oracle Clusterware。

验证在要修补的节点上不再有任何资源运行，从运行Grid的另一个节点运行以下命令：

&gt; crsctl status resource -t

该节点上停止所有“Oracle”服务

net start | findstr /i ora

&nbsp;

net stop &quot;Oracle Object Service&quot;

net stop OracleMTSRecoveryService

net stop OracleServiceORCL2

禁用和停止（非Oracle）Windows Management Instrumentation服务。

&gt; sc config Winmgmt start= disabled

&gt; net stop winmgmt

使用以下步骤将补丁应用到Grid Home：（确保ORACLE_HOME指向Grid Infrastructure主目录。）

 ** _注意：此步骤在_** ** _Windows 2012_** ** _安装_** ** _oracle home_** **
_补丁时无需操作_**

解压补丁安装包

&gt; cd 24591646

&gt; set ORACLE_HOME=C:\app\11.2.0\grid

&gt; &lt;path to latest version of opatch&gt;\opatch apply -local

例如

&gt; C:\app\11.2.0\grid\OPatch\opatch apply -local

使用以下步骤将补丁应用到Database Home：（确保ORACLE_HOME指向数据库主目录。）

&gt; cd 24591646

&gt; set ORACLE_HOME=C:\app\oracle\product\11.2.0\dbhome_1

&gt; &lt;path to latest version of opatch&gt;\opatch apply -local

例如

&gt; C:\app\oracle\product\11.2.0\dbhome_1\OPatch\opatch apply -local

重新启用（非Oracle）Windows Management Instrumentation服务。

&gt; sc config Winmgmt start= auto

通过运行&#39;rootcrs.pl -patch&#39;来完成修补。

注意：此命令包括Oracle高可用性服务的启动

&gt; set ORACLE_HOME=C:\app\11.2.0\grid

&gt; %ORACLE_HOME%\perl\bin\perl -I%ORACLE_HOME%\perl\lib
-I%ORACLE_HOME%\crs\install %ORACLE_HOME%\crs\install\rootcrs.pl -patch

&nbsp;

&gt; srvctl start instance -d &lt;dbname&gt; -i &lt;instance name&gt;

例如

&gt; srvctl start instance -d orcl -i orcl1

启动msdtc和winmgmt

&gt; net start msdtc

&gt; net start winmgmt&nbsp;

Installing OraFence:（注意，此处需要重启两个操作系统）

 ** _注意：此步骤在_** ** _Windows 2012_** ** _安装_** ** _oracle home_** **
_补丁时无需操作_**

&gt; set ORACLE_HOME=C:\app\11.2.0\grid

&gt; %ORACLE_HOME%\bin\crssetup deinstallfence

重新启动节点以使更改生效。

&gt; set ORACLE_HOME=C:\app\11.2.0\grid

&gt; %ORACLE_HOME%\bin\crssetup installfence

重新启动节点以使更改生效。

 **Updating OCFS** : Take a backup of file ocfs.sys located under
%SystemRoot%\System32\drivers.

&nbsp;Ensure all services and resources listed in step 1 have been stopped
before copying the ocfs.sys

&nbsp;replace ocfs.sys with ocfs.sys.w2k364 supplied in the patch 24591646.
Note that the filename in %SystemRoot%\System32\drivers is required to be
ocfs.sys and reboot the node.

&nbsp;When copying OCFS drivers you may need to reboot the node.

&nbsp;

 **其他节点重复以上步骤**

&nbsp;

在其中一个节点上执行catbundle.sql脚本

cd %ORACLE_HOME%\rdbms\admin

sqlplus /nolog

SQL&gt; CONNECT / AS SYSDBA

SQL&gt; @catbundle.sql PSU apply

SQL&gt; QUIT

在其中一个节点上执行utlrp.sql脚本

cd %ORACLE_HOME%\rdbms\admin

sqlplus /nolog

SQL&gt; CONNECT / AS SYSDBA

SQL&gt; @utlrp.sql

对于在安装BP 11.2.0.4.161018之后已升级或创建的数据库，不需要执行任何操作

&nbsp;

&nbsp;

## 19、回退Bundle Patch补丁

按照Bundle Patch补丁中README.html进行以下步骤

&nbsp;

在集群中的每个节点上执行以下步骤，一次一个节点。

在RAC环境中卸载的顺序是Database Home，然后是Grid Home

&gt; srvctl stop service -d &lt;database name&gt; -s &lt;configured workload
management service&gt; -i &lt;instancename&gt;

&gt; srvctl stop instance -d &lt;dbname&gt; -i &lt;instance name&gt;

例如

&gt; srvctl stop instance -d orcl -i orcl1

&nbsp;

&gt; net stop OracleServiceorcl1

&gt; net stop &quot;Oracle orcl1 VSS Writer Service&quot;

&gt; net stop OracleDBConsoleorcl1

&gt; net stop msdtc

&gt; net stop ocfs (required only for OCFS installation)

&gt; net stop orafenceservice

&gt; net stop OracleMTSRecoveryService

&gt; net stop OracleRemExecService

设置指向您的Database Home的ORACLE_HOME环境变量，然后通过输入以下命令运行OPatch实用程序

&gt; set ORACLE_HOME=C:\app\oracle\product\11.2.0\dbhome_1

&gt; C:\app\oracle\product\11.2.0\dbhome_1\OPatch\opatch rollback -id 24591646
-local

从Grid Home卸载修补程序：从Grid Home卸载修补程序之前，“unlock”Grid
Home以准备修补，并停止Oracle高可用性服务（OHASD）和所有Oracle服务：

&gt; set ORACLE_HOME=C:\app\11.2.0\grid

&gt; %ORACLE_HOME%\perl\bin\perl -I%ORACLE_HOME%\perl\lib
-I%ORACLE_HOME%\crs\install %ORACLE_HOME%\crs\install\rootcrs.pl -unlock

&nbsp;

&gt; net stop &quot;Oracle Object Service&quot;

&gt; net stop ocfs (required only for OCFS installation)

&gt; net stop orafenceservice

设置指向Grid Home的ORACLE_HOME环境变量，然后通过输入以下命令运行OPatch实用程序

&gt; set ORACLE_HOME=C:\app\11.2.0\grid

&gt; C:\app\11.2.0\grid\OPatch\opatch rollback -id 24591646 -local

通过运行以下命令，在节点上启动Oracle HASD服务（OHASD）和oracle实例

&gt; %ORACLE_HOME%\perl\bin\perl -I%ORACLE_HOME%\perl\lib
-I%ORACLE_HOME%\crs\install %ORACLE_HOME%\crs\install\rootcrs.pl -patch

&gt; srvctl start instance -d &lt;dbname&gt; -i &lt;instance name&gt;

例如

&gt; srvctl start instance -d orcl -i orcl1

在之前安装当前卸载的Bundle Patch补丁时执行catbundle.sql脚本的节点上执行catbundle_PSU_&lt;database
SID&gt;_ROLLBACK.sql脚本

cd %ORACLE_HOME%\rdbms\admin

sqlplus /nolog

SQL&gt; CONNECT / AS SYSDBA

SQL&gt; @catbundle_PSU_&lt;database SID&gt;_ROLLBACK.sql

例如

SQL&gt; @catbundle_PSU_ORCL_ROLLBACK

SQL&gt; QUIT

在其中一个节点上执行utlrp.sql脚本

cd %ORACLE_HOME%\rdbms\admin

sqlplus /nolog

SQL&gt; CONNECT / AS SYSDBA

SQL&gt; @utlrp.sql

&nbsp;

 _& nbsp;_

## 20、卸载软件

### 20.1卸载Oracle Grid Infrastructure

管理员用户登录

Stop the databases and cluster resources:

&nbsp;

Run on any node: &quot;srvctl stop database -d &lt;dbname&gt;&quot;

Run on any node: &quot;crsctl stop cluster -all&quot;

Run on all nodes: &quot;crsctl stop crs&quot;

&nbsp;

停止与ORACLE_HOME相关的所有正在运行的Oracle服务：

如果要删除Grid Infrastructure Home，请使用命令行命令停止OraFence服务：

&#39;net stop OraFenceService&#39;

&nbsp;

在一个节点上使用DBCA删除数据库，使用NETCA删除监听

&nbsp;

通过在命令提示符窗口中运行以下步骤删除GRID配置：

所有节点运行：

set path=%path%;C:\app\11.2.0\grid\perl\bin

除最后一个节点的所有节点运行

perl C:\app\11.2.0\grid\crs\install\rootcrs.pl -verbose -deconfig -force

在最后一个节点上运行 此命令将清零OCR和Voting磁盘

perl C:\app\11.2.0\grid\crs\install\rootcrs.pl -verbose -deconfig -force
-lastnode

&nbsp;

从OUI清单中删除ORACLE_HOME：

C:\app\11.2.0\grid\OUI\BIN\setup -detachHome ORACLE_HOME=C:\app\11.2.0\grid

&nbsp;

删除注册表中的条目

启动注册表编辑器：选择开始&gt;运行&gt; regedit。

转到HKEY_LOCAL_MACHINE\SOFTWARE\ORACLE，删除该条目。

转到HKEY_LOCAL_MACHINE\SOFTWARE\ODBC。 展开所有子项并删除键：“Oracle in
&lt;ORACLE_HOME&gt;”。

转到HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services。
删除名称以Oracle或Ora开头的所有键，或具有要删除的ORACLE_HOME或其下的位置的ImagePath字符串条目。

转到HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\OraFenceService并删除该条目。

转到HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\ocfs并删除该条目。

关闭regedit。

&nbsp;

删除环境变量

CLASSPATH，ORACLE_HOME，PATH和PERL5LIB。关于oracle的设置

&nbsp;

清理开始菜单图标：

&nbsp;

右键单击开始按钮，然后选择浏览所有用户。

展开程序文件夹。

删除文件夹Oracle - &lt;ORACLE_HOME&gt;和任何子文件夹。

&nbsp;

如果这是服务器上唯一的ORACLE_HOME，请删除C：\ Program Files下的Oracle文件夹。
如果此服务器上有任何其他Oracle产品，请不要删除此项。

&nbsp;

重启节点

&nbsp;

转到TEMP / TMP目录并删除所有文件和目录。

&nbsp;

转到ORACLE_HOME位置并验证所有文件夹/文件已删除。

&nbsp;

删除Windows驱动程序文件夹中的群集驱动程序，通常C:\WINDOWS\System32\Drivers：

ocfs.sys

oracleacfs.sys

oracleadvm.sys

oracleoks.sys

orafencedrv.sys

orafenceservice.sys

&nbsp;

清空所有节点上的回收站。

&nbsp;

您必须重新初始化所有共享磁盘，以允许从集群中的一个节点重新安装一个干净的环境。

参考文档

 **How To Clean up After a Failed (or successful) Oracle Clusterware
Installation on Windows (** **文档** **ID 341214.1)**

&nbsp;

重新启动所有节点以确保清除已禁用的Oracle服务和仍驻留在内存中已删除的项目

&nbsp;

清空磁盘步骤：

C:\Users\Administrator&gt;diskpart

&nbsp;

Microsoft DiskPart 版本 6.1.7601

Copyright (C) 1999-2008 Microsoft Corporation.

在计算机上: RAC1

&nbsp;

DISKPART&gt; list disk

&nbsp;

&nbsp; 磁盘 ###&nbsp;
状态&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
大小&nbsp;&nbsp;&nbsp;&nbsp; 可用&nbsp;&nbsp;&nbsp;&nbsp; Dyn&nbsp; Gpt

&nbsp; --------&nbsp; -------------&nbsp; -------&nbsp; -------&nbsp;
---&nbsp; ---

&nbsp; 磁盘 0&nbsp;&nbsp;&nbsp;
联机&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
50 GB&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0 B

&nbsp; 磁盘 1&nbsp;&nbsp;&nbsp;
联机&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1024 MB&nbsp; 1984 KB

&nbsp; 磁盘 2&nbsp;&nbsp;&nbsp;
联机&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1024 MB&nbsp; 1984 KB

&nbsp; 磁盘 3&nbsp;&nbsp;&nbsp;
联机&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1024 MB&nbsp; 1984 KB

&nbsp; 磁盘 4&nbsp;&nbsp;&nbsp;
联机&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
2048 MB&nbsp; 1984 KB

&nbsp; 磁盘 5&nbsp;&nbsp;&nbsp;
联机&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
4096 MB&nbsp; 1024 KB

&nbsp;

DISKPART&gt; select disk 1

&nbsp;

磁盘 1 现在是所选磁盘。

&nbsp;

DISKPART&gt; clean all

&nbsp;

DiskPart 成功地清除了磁盘。

## 21、收尾工作

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

&nbsp;

&nbsp;

ASM内存参数设置

Unable To Start ASM (ORA-00838 ORA-04031) On 11.2.0.3/11.2.0.4 If OS CPUs #
&gt; 64. (文档 ID 1416083.1)

SQL&gt; show parameter memory_target

查看ASM实例内存大小，如果值小于1536m，则做如下配置

SQL&gt; alter system set memory_max_target=4096m scope=spfile;

SQL&gt; alter system set memory_target=1536m scope=spfile;

如果当前memory_target值大于1536M，则不作任何变更

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

## 22、部署rman备份脚本

参考rman 备份相关文档

&nbsp;

 **至此结束 RAC部署，重启RAC所有服务器，启动后检查相关服务及内容是否正常，方可结束安装。**

&nbsp;

" name="docDetail" type="hidden">


---
### ATTACHMENTS
[0277c480215a5a30bee8fb72233d4f9d]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012.html)
>hash: 0277c480215a5a30bee8fb72233d4f9d  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124141445_200.png  

[06388b956b9124427606c3370b04db42]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-2.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-2.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-2.html)
>hash: 06388b956b9124427606c3370b04db42  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124141743_372.png  

[06a6754511599c85d283d5542525d9b7]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-3.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-3.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-3.html)
>hash: 06a6754511599c85d283d5542525d9b7  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124141532_949.png  

[06f8e14e9c5fca634a505eed473363aa]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-4.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-4.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-4.html)
>hash: 06f8e14e9c5fca634a505eed473363aa  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124140833_622.png  

[070bac00acae7f20aa0d8216a75be257]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-5.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-5.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-5.html)
>hash: 070bac00acae7f20aa0d8216a75be257  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142655_97.png  

[0a95c6c3bdb5c7b423003a69c3c2eb68]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-6.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-6.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-6.html)
>hash: 0a95c6c3bdb5c7b423003a69c3c2eb68  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142031_194.png  

[0b705ae6da21b430bb99576409464368]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-7.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-7.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-7.html)
>hash: 0b705ae6da21b430bb99576409464368  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124141532_38.png  

[0c753771d3ca357a1a21fdc25ef06d6d]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-8.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-8.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-8.html)
>hash: 0c753771d3ca357a1a21fdc25ef06d6d  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142728_653.png  

[0e25883ef5e6caacc3fd4423d09dc492]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-9.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-9.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-9.html)
>hash: 0e25883ef5e6caacc3fd4423d09dc492  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124143148_190.png  

[1728bd9a10f35872de97ab27200cdc1e]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-10.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-10.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-10.html)
>hash: 1728bd9a10f35872de97ab27200cdc1e  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124140755_511.png  

[186cf6f0e449dcf402e4f46568c9f841]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-11.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-11.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-11.html)
>hash: 186cf6f0e449dcf402e4f46568c9f841  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124141138_976.png  

[1b13a77bc75b225eaf27bce5a3b5a578]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-12.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-12.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-12.html)
>hash: 1b13a77bc75b225eaf27bce5a3b5a578  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124140043_937.png  

[1b3cd90263f6aeb17e9d51142020c31c]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-13.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-13.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-13.html)
>hash: 1b3cd90263f6aeb17e9d51142020c31c  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142901_43.png  

[1bca2566611a834042d5b6d8ce201cd3]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-14.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-14.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-14.html)
>hash: 1bca2566611a834042d5b6d8ce201cd3  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142032_414.png  

[1ea664ec9c825295ff2842b74626bd26]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-15.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-15.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-15.html)
>hash: 1ea664ec9c825295ff2842b74626bd26  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142032_599.png  

[20e35c1163a1d79e02c9b2ccca901b5b]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-16.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-16.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-16.html)
>hash: 20e35c1163a1d79e02c9b2ccca901b5b  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124143111_652.png  

[21b3738348294538febe9b89c45ed8d0]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-17.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-17.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-17.html)
>hash: 21b3738348294538febe9b89c45ed8d0  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142031_489.png  

[27c643a9d36c2f1317cada9cc2c68db4]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-18.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-18.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-18.html)
>hash: 27c643a9d36c2f1317cada9cc2c68db4  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142402_938.png  

[283cf929505395f953583dec8d9e1c61]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-19.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-19.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-19.html)
>hash: 283cf929505395f953583dec8d9e1c61  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124143027_701.png  

[2ac54d77c4b339e26fcbabb4d633242e]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-20.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-20.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-20.html)
>hash: 2ac54d77c4b339e26fcbabb4d633242e  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124140219_623.png  

[2d12802f6680f6ff1f25cdf0cd8a0aed]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-21.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-21.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-21.html)
>hash: 2d12802f6680f6ff1f25cdf0cd8a0aed  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124141444_284.png  

[2d2e2da39b0f6c8a10c8128fc548b586]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-22.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-22.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-22.html)
>hash: 2d2e2da39b0f6c8a10c8128fc548b586  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124140328_702.png  

[2e5dd7fcbc8be8128f45750d8d7ba868]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-23.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-23.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-23.html)
>hash: 2e5dd7fcbc8be8128f45750d8d7ba868  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124141840_70.png  

[2ff2469eb9d0fbd3ee9b841b1219a7a9]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-24.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-24.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-24.html)
>hash: 2ff2469eb9d0fbd3ee9b841b1219a7a9  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142032_434.png  

[32f04490e107267ac32bb868fac59d36]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-25.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-25.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-25.html)
>hash: 32f04490e107267ac32bb868fac59d36  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142145_456.png  

[354d2e2c88fd2f4e976856dca7434fd9]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-26.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-26.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-26.html)
>hash: 354d2e2c88fd2f4e976856dca7434fd9  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124140502_639.png  

[3581cb50fb0ca84dd617d63ac6beeb14]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-27.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-27.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-27.html)
>hash: 3581cb50fb0ca84dd617d63ac6beeb14  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142603_99.png  

[35a236c47bf3203b29622784bd39b620]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-28.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-28.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-28.html)
>hash: 35a236c47bf3203b29622784bd39b620  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142901_946.png  

[37ff6da21f07e9f8c4544b5e0b9aad52]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-29.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-29.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-29.html)
>hash: 37ff6da21f07e9f8c4544b5e0b9aad52  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124141705_651.png  

[3edeb2a3cc1062dd3887f95b465e10bf]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-30.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-30.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-30.html)
>hash: 3edeb2a3cc1062dd3887f95b465e10bf  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142914_714.png  

[3fbe2486b53a534d2182405e5f5a8e9c]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-31.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-31.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-31.html)
>hash: 3fbe2486b53a534d2182405e5f5a8e9c  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124140119_750.png  

[48dc25c40e4f64456e4d41da2f8aec38]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-32.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-32.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-32.html)
>hash: 48dc25c40e4f64456e4d41da2f8aec38  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124143111_280.png  

[4f01114d42e8b61b9a5c4ab5d221ecf1]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-33.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-33.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-33.html)
>hash: 4f01114d42e8b61b9a5c4ab5d221ecf1  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124134109_9.png  

[4ff1571aa71152d3078e58baa999eb79]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-34.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-34.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-34.html)
>hash: 4ff1571aa71152d3078e58baa999eb79  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124141138_676.png  

[51173cdd7075aeab7fa33188ff96fd91]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-35.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-35.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-35.html)
>hash: 51173cdd7075aeab7fa33188ff96fd91  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124140104_427.png  

[55a5b5d81f23bdf1ad2f18c7cc29f78b]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-36.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-36.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-36.html)
>hash: 55a5b5d81f23bdf1ad2f18c7cc29f78b  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124140958_325.png  

[56e3bb95ea5d47106a4e8a55ae7bdbc7]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-37.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-37.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-37.html)
>hash: 56e3bb95ea5d47106a4e8a55ae7bdbc7  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124141532_760.png  

[5b1078c405f03b05fa71b55d4b88499d]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-38.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-38.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-38.html)
>hash: 5b1078c405f03b05fa71b55d4b88499d  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142032_930.png  

[5c4b2130fdcc8c6638d26ba2ae7d06fe]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-39.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-39.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-39.html)
>hash: 5c4b2130fdcc8c6638d26ba2ae7d06fe  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124140714_336.png  

[5e9a65070dff059ec66fb3574f2a8300]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-40.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-40.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-40.html)
>hash: 5e9a65070dff059ec66fb3574f2a8300  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142031_302.png  

[5f93524edb406f70955b455ab9e35e35]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-41.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-41.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-41.html)
>hash: 5f93524edb406f70955b455ab9e35e35  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142429_801.png  

[6092b9f1b12694b38269f7592d5545c8]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-42.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-42.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-42.html)
>hash: 6092b9f1b12694b38269f7592d5545c8  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142031_402.png  

[615afa660164756facf8443278cc18ea]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-43.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-43.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-43.html)
>hash: 615afa660164756facf8443278cc18ea  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124140726_729.png  

[61cfbff8a270b4794e9e551dbb92d431]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-44.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-44.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-44.html)
>hash: 61cfbff8a270b4794e9e551dbb92d431  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142031_583.png  

[63e4457c4ee1cc231d8588badc15c442]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-45.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-45.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-45.html)
>hash: 63e4457c4ee1cc231d8588badc15c442  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124141444_298.png  

[6423a3f72ce09505b4db2cd606e125dc]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-46.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-46.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-46.html)
>hash: 6423a3f72ce09505b4db2cd606e125dc  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124140043_275.png  

[642af1292d9cb47db084e890218c9c39]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-47.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-47.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-47.html)
>hash: 642af1292d9cb47db084e890218c9c39  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124140430_945.png  

[682b84f7107c62a4828ac0f2617c97fc]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-48.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-48.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-48.html)
>hash: 682b84f7107c62a4828ac0f2617c97fc  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142901_70.png  

[689468151bf16e6197a0e874cfc2dd9e]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-49.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-49.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-49.html)
>hash: 689468151bf16e6197a0e874cfc2dd9e  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124141808_465.png  

[6bc15bd3734915b80611e88660507f98]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-50.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-50.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-50.html)
>hash: 6bc15bd3734915b80611e88660507f98  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124141705_514.png  

[6fde6c87dcda5c2eb35b5e0792652cf9]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-51.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-51.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-51.html)
>hash: 6fde6c87dcda5c2eb35b5e0792652cf9  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142145_395.png  

[700e60b13acf65c5a3f1af12d419a72d]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-52.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-52.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-52.html)
>hash: 700e60b13acf65c5a3f1af12d419a72d  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124140958_618.png  

[72847baafa0d08759e2e21a4f81f0706]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-53.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-53.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-53.html)
>hash: 72847baafa0d08759e2e21a4f81f0706  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124141038_632.png  

[72e2a2c9400471a79f4e905f5778807d]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-54.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-54.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-54.html)
>hash: 72e2a2c9400471a79f4e905f5778807d  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124141221_98.png  

[72f45f902ccc8771f89c127be84f0c18]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-55.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-55.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-55.html)
>hash: 72f45f902ccc8771f89c127be84f0c18  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124141138_545.png  

[73cac470092bf9a3c8cfb35f6e6a887d]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-56.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-56.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-56.html)
>hash: 73cac470092bf9a3c8cfb35f6e6a887d  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142901_975.png  

[781bef3fad09cdd17e4cf176d5c04655]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-57.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-57.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-57.html)
>hash: 781bef3fad09cdd17e4cf176d5c04655  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124140958_967.png  

[7d512238fe527d2188d3d2f2fd3b876e]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-58.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-58.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-58.html)
>hash: 7d512238fe527d2188d3d2f2fd3b876e  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124141445_21.png  

[7f025a17697ee15eb3197c61326b203b]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-59.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-59.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-59.html)
>hash: 7f025a17697ee15eb3197c61326b203b  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\11947ec6e06f4dd6a765bcc48c4fc88d.png  

[8098d56270f9c8d7c85f9235c366fca8]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-60.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-60.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-60.html)
>hash: 8098d56270f9c8d7c85f9235c366fca8  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124141444_928.png  

[83c5b40b52936a3eddd859e12d498fc9]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-61.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-61.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-61.html)
>hash: 83c5b40b52936a3eddd859e12d498fc9  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124134122_42.png  

[83c82a3ab35c020e6198e5a71fb8880d]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-62.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-62.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-62.html)
>hash: 83c82a3ab35c020e6198e5a71fb8880d  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124140502_659.png  

[83ca0c47e60e33d0b86ed06c46b3ef62]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-63.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-63.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-63.html)
>hash: 83ca0c47e60e33d0b86ed06c46b3ef62  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124140958_204.png  

[85fe2d48873730c2e70fd2bd8aa50f3a]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-64.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-64.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-64.html)
>hash: 85fe2d48873730c2e70fd2bd8aa50f3a  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124140315_715.png  

[8c5f4fedf4b50e8602a3500dee5b312a]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-65.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-65.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-65.html)
>hash: 8c5f4fedf4b50e8602a3500dee5b312a  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124141138_702.png  

[8ca898eec8ecc131f6e26e8b88841108]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-66.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-66.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-66.html)
>hash: 8ca898eec8ecc131f6e26e8b88841108  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124140646_359.png  

[8de75e9b7419766bd52ff2d386f46b30]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-67.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-67.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-67.html)
>hash: 8de75e9b7419766bd52ff2d386f46b30  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124140958_231.png  

[90cb56e5b6ef44553afaa835f5177fd0]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-68.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-68.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-68.html)
>hash: 90cb56e5b6ef44553afaa835f5177fd0  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124140755_460.png  

[9258c844f1db4f15e2d3e0e508663807]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-69.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-69.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-69.html)
>hash: 9258c844f1db4f15e2d3e0e508663807  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124141743_84.png  

[9277b28e54c4d9820a4cce1b4644962b]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-70.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-70.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-70.html)
>hash: 9277b28e54c4d9820a4cce1b4644962b  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142637_254.png  

[92ecdf7323b08a3fc6d8ec640431f5e5]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-71.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-71.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-71.html)
>hash: 92ecdf7323b08a3fc6d8ec640431f5e5  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124140958_20.png  

[94a42934569e882bbb4905bd2fe5e3fe]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-72.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-72.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-72.html)
>hash: 94a42934569e882bbb4905bd2fe5e3fe  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124140958_91.png  

[9537a74f327467bb37eaa1a480f3244b]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-73.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-73.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-73.html)
>hash: 9537a74f327467bb37eaa1a480f3244b  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124143041_147.png  

[980de9ca44c431dd94fa8b3115fdf54a]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-74.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-74.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-74.html)
>hash: 980de9ca44c431dd94fa8b3115fdf54a  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124143010_767.png  

[9c19c9f8019f35bb902b4fb080010121]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-75.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-75.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-75.html)
>hash: 9c19c9f8019f35bb902b4fb080010121  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124140430_418.png  

[a4a01e84607bd64119ef1bc578c6849f]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-76.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-76.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-76.html)
>hash: a4a01e84607bd64119ef1bc578c6849f  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124140409_742.png  

[a6b5ecde87885297808844e8bd54f5ed]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-77.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-77.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-77.html)
>hash: a6b5ecde87885297808844e8bd54f5ed  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142145_705.png  

[b88ced9a6c51a4f6cda412a8001ba6cb]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-78.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-78.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-78.html)
>hash: b88ced9a6c51a4f6cda412a8001ba6cb  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124141603_929.png  

[bd0fbe487aeab304320725b26f2c7784]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-79.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-79.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-79.html)
>hash: bd0fbe487aeab304320725b26f2c7784  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142031_425.png  

[be14fbd1ac63f2944927c9ccb65f6637]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-80.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-80.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-80.html)
>hash: be14fbd1ac63f2944927c9ccb65f6637  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142112_978.png  

[c18e7dac8308a57f86a2f8f20aba75e1]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-81.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-81.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-81.html)
>hash: c18e7dac8308a57f86a2f8f20aba75e1  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124140219_304.png  

[c28a769c4610a49831e241e8015bc3aa]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-82.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-82.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-82.html)
>hash: c28a769c4610a49831e241e8015bc3aa  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124141138_460.png  

[c2a57410cb4295cd08ea0f45fe7b6fcb]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-83.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-83.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-83.html)
>hash: c2a57410cb4295cd08ea0f45fe7b6fcb  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142751_133.png  

[c99276986925e6fcb0f97b64634cdbfe]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-84.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-84.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-84.html)
>hash: c99276986925e6fcb0f97b64634cdbfe  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124140958_546.png  

[cf4159ca080bf216a2abf838ab839c6b]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-85.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-85.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-85.html)
>hash: cf4159ca080bf216a2abf838ab839c6b  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142031_693.png  

[cf93bf0a1d796357409c09aa76eaf98d]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-86.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-86.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-86.html)
>hash: cf93bf0a1d796357409c09aa76eaf98d  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124140255_537.png  

[d1e43b2e42bc3fd5e51aba83b8a72371]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-87.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-87.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-87.html)
>hash: d1e43b2e42bc3fd5e51aba83b8a72371  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142032_257.png  

[d437877f92f5320a081b7be69c52d595]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-88.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-88.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-88.html)
>hash: d437877f92f5320a081b7be69c52d595  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124140958_169.png  

[d44a7f22864688dc584fd20d5515e72e]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-89.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-89.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-89.html)
>hash: d44a7f22864688dc584fd20d5515e72e  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124140237_415.png  

[d4b1ceb1c22632fcb172ead47684d433]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-90.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-90.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-90.html)
>hash: d4b1ceb1c22632fcb172ead47684d433  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142444_164.png  

[d8a7a4ecdf46fff6a8e1d64052030fc4]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-91.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-91.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-91.html)
>hash: d8a7a4ecdf46fff6a8e1d64052030fc4  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142901_259.png  

[d9207a924cfe467d28a7772491d910d5]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-92.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-92.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-92.html)
>hash: d9207a924cfe467d28a7772491d910d5  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124141705_987.png  

[d9dc57e413156639d7399a066e484267]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-93.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-93.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-93.html)
>hash: d9dc57e413156639d7399a066e484267  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142516_49.png  

[dd89fada0501717c7ada82ba145d45fc]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-94.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-94.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-94.html)
>hash: dd89fada0501717c7ada82ba145d45fc  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124141532_354.png  

[e213066d615c2367977c3a308102c5c4]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-95.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-95.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-95.html)
>hash: e213066d615c2367977c3a308102c5c4  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142901_666.png  

[e3225b21a2ad21921803962813a344e4]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-96.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-96.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-96.html)
>hash: e3225b21a2ad21921803962813a344e4  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124141038_42.png  

[e34b15ff25e52f077f6fa45fee42f74e]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-97.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-97.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-97.html)
>hash: e34b15ff25e52f077f6fa45fee42f74e  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124141532_758.png  

[e9e2516a7f1d9f452507d5cd66c8785d]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-98.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-98.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-98.html)
>hash: e9e2516a7f1d9f452507d5cd66c8785d  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142031_743.png  

[eb8bbb492d3d65425ac4e09d2868cfa0]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-99.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-99.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-99.html)
>hash: eb8bbb492d3d65425ac4e09d2868cfa0  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124142032_476.png  

[f0ea5e59782c275a27f309b25dcb47b4]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-100.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-100.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-100.html)
>hash: f0ea5e59782c275a27f309b25dcb47b4  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124143111_663.png  

[f560d2b103c7b12c671137572fd2e5fb]: media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-101.html
[Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-101.html](media/Oracle-安装手册-RAC-11gR2_for_Windows2008-2012-101.html)
>hash: f560d2b103c7b12c671137572fd2e5fb  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012_files\20180124140202_621.png  

---
### NOTE ATTRIBUTES
>Created Date: 2018-09-25 03:29:25  
>Last Evernote Update Date: 2018-10-01 15:33:49  
>author: YangKwong  
>source: desktop.win  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-安装手册-RAC-11gR2_for_Windows2008-2012.html  
>source-application: evernote.win32  