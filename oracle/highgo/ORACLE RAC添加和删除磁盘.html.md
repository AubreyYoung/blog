# ORACLE RAC添加和删除磁盘.html

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

067721104

ORACLE RAC添加和删除磁盘

目录

环境

文档用途

详细信息

相关文档

内部备注

附件

环境

系统平台：N/A

版本：11.2.0.1,11.2.0.2,11.2.0.3,11.2.0.4

文档用途

用于以下场景对ASM磁盘的操作：

1，ASM磁盘组空间不足，添加磁盘扩充磁盘组空间。

2，从ASM磁盘组中踢出磁盘，做其他用途，比如OGG、做RMAN备份空间等。

3，更换ASM磁盘组中的磁盘，比如当前磁盘为普通机械硬盘，使用SSD更换普通硬盘等。

  

详细信息

## 实验环境：

SQL> Set pagesize 100

SQL> Set linesize 100

SQL> Col name format a15

SQL> select GROUP_NUMBER,NAME,STATE,TYPE,TOTAL_MB,FREE_MB,USABLE_FILE_MB from
v$asm_diskgroup;



GROUP_NUMBER NAME            STATE       TYPE     TOTAL_MB    FREE_MB
USABLE_FILE_MB

\------------ --------------- ----------- ------ ---------- ----------
--------------

           1 ARCH            MOUNTED     EXTERN       2048       1660           1660

           2 CRS             MOUNTED     NORMAL       3072       2146            561

           3 DATA            MOUNTED     EXTERN       4096       2055           2055



SQL> set pagesize 200

SQL> set linesize 150

SQL> col path format a20;

SQL> col group_name format a10

SQL> col name format a20

SQL> col FAILGROUP_TYPE format a15

SQL> col FAILGROUP format a15

SQL> select a.group_number,b.name as
group_name,a.FAILGROUP,a.name,a.path,a.state,a.total_mb from v$asm_disk
a,v$asm_diskgroup b where a.group_number=b.group_number;



GROUP_NUMBER GROUP_NAME FAILGROUP NAME      PATH                 STATE
TOTAL_MB

\------------ ---------- --------- --------- -------------------- ------
--------

           1 ARCH       ARCH_0000 ARCH_0000 /u01/asm-disk/fra1   NORMAL     2048

           2 CRS        CRS_0000  CRS_0000  /u01/asm-disk/ocr1   NORMAL     1024

           3 DATA       DATA_0000 DATA_0000 /u01/asm-disk/data1  NORMAL     4096

           2 CRS        CRS_0001  CRS_0001  /u01/asm-disk/ocr2   NORMAL     1024

           2 CRS        CRS_0002  CRS_0002  /u01/asm-disk/ocr3   NORMAL     1024



SQL> show parameter disk



NAME                                 TYPE        VALUE

\------------------------------------ -----------
------------------------------

asm_diskgroups                       string      DATA, ARCH

asm_diskstring                       string      /u01/asm-disk/*

## 1、添加磁盘前的准备

添加磁盘前，请存储工程师划分磁盘，划分的磁盘大小与要添加的磁盘组（本实验为DATA磁盘组）中的磁盘（本实验DATA_0000）大小相同。

磁盘划分完成后，请存储工程师配置多路径，告知聚合后的磁盘路径和名称。



 **Linux** **操作系统磁盘准备：**

参考指导书：《oracle11gR2-RACforLinux5&6手册》 10、ASM配置共享磁盘

配置UDEV绑定磁盘，修改磁盘权限，创建用于ASM访问的磁盘软链接。

 **AIX** **操作系统磁盘准备：**

参考指导书：《Oracle 11gR2 AIX RAC安装手册》 10、ASM配置共享磁盘

 **WINDOWS** **操作系统磁盘准备：**

参考指导书：《oracle11gR2-RAC for Windows 2008&2012手册》 10、ASM配置共享磁盘

 **HP-UX** **操作系统磁盘准备：**

参考指导书：《Oracle 11gR2 HPUX RAC安装手册》 10、ASM配置共享磁盘



 **需要注意的事项：**

### 1）新添加的磁盘大小与原磁盘组中磁盘相同

### 2）新添加的磁盘路径与原磁盘组中磁盘相同

新添加的磁盘路径与原磁盘组中磁盘相同，如果出现多个扫描路径下的对应相同的物理磁盘，会出现类似以下报错：

SQL> alter diskgroup data add disk '/dev/raw/raw6','/dev/raw/raw7';

alter diskgroup data add disk '/dev/raw/raw6','/dev/raw/raw7'

*

ERROR at line 1:

ORA-15032: not all alterations performed

ORA-15031: disk specification '/dev/raw/raw7' matches no disks

ORA-15014: path '/dev/raw/raw7' is not in the discovery set

ORA-15031: disk specification '/dev/raw/raw6' matches no disks

ORA-15014: path '/dev/raw/raw6' is not in the discovery set

本实验将RAW绑定的裸设备(/dev/raw/raw*)建立软连接，到/u01/asm-disk目录下。

建立软连接的原因是：当操作系统层面上的磁盘设备编号发生改变后，无需更改集群ASM配置，重建软连接即可。

### 3）不要执行start_udev，手动RAW绑定设备

在Linux环境中配置好udev配置文件后，不要执行start_udev,不然集群会出问题，本实验中VIP漂移至其他节点上：

[grid@0906rac1 ~]$ crsctl status res -t

ora.LISTENER.lsnr

               ONLINE  OFFLINE      0906rac1                                    

               ONLINE  ONLINE       0906rac2

ora.0906rac1.vip

      1        ONLINE  INTERMEDIATE 0906rac2          FAILED OVER        

ora.0906rac2.vip

      1        ONLINE  ONLINE       0906rac2                              

如果出现这种现象，使用以下命令将VIP手动漂移回原节点：

[grid@0906rac1 ~]$ srvctl relocate vip -i 0906rac1  -n 0906rac1

执行start_udev出现VIP漂移的原因：

在执行start_udev期间，udev会删除公共网络接口，这将导致监听崩溃，并且clusterware将所有服务，SCAN
监听和节点1上的VIP移动到节点2。

 **Network interface going down when dynamically adding disks to storage using
udev in RHEL 6 (** **文档** **ID 1569028.1)**



此时需要在集群的所有节点上执行RAW手动绑定设备并更改属性和权限，与客户协商计划内停机，验证服务器重启后磁盘是否可以正常加载：

raw /dev/raw/raw6 /dev/sdg

raw /dev/raw/raw7 /dev/sdh



chown grid:asmadmin /dev/raw/raw6

chown grid:asmadmin /dev/raw/raw7



chmod 660 /dev/raw/raw6

chmod 660 /dev/raw/raw7

## 2、添加磁盘前的测试

1 判断磁盘中是否存在数据，使用如下命令

# for DISK in $(awk '!/name/ {print $NF}' /proc/partitions); do echo -n "$DISK
"; if [ $(hexdump -n10485760 /dev/$DISK | head | wc -l) -gt "3" ]; then echo
"has data"; else echo "is empty"; fi; done;

vda has data

vdb is empty



注：以上脚本是依据hexdump命令的输出，aix是lquerypv 、linux是hexdump

如果有数据要和客户进行确认才能进行格式化操作，对于单次服务工作，还必须要客户签订免责协议，才能进行格式化等操作。



2 在配置好磁盘后，需要先使用添加的磁盘创建一个测试的磁盘组，验证当前磁盘可用，例如：

SQL> CREATE DISKGROUP TEST EXTERNAL REDUNDANCY DISK '/u01/asm-
disk/data2','/u01/asm-disk/data3' attribute 'compatible.asm'
='11.2.0.4.0','compatible.rdbms'='11.2.0.4.0';

Diskgroup created.



在其他节点mount新创建的磁盘组

[grid@0906rac2 ~]$ sqlplus / as sysasm

SQL> alter diskgroup test mount;

其中compatible.asm和compatible.rdbms是Oracle 11g
ASM中引入的磁盘组兼容性属性，此属性确定可连接到ASM磁盘组的ASM实例和数据库实例的最低版本，推进磁盘组Oracle数据库和ASM兼容性设置使您能够使用最新版本中提供的新的ASM功能，比如本文档后面提到的数据平衡进程数Power的取值范围是0-11之间，如果COMPATIBLE.ASM磁盘组属性设置为11.2.0.2或更高版本，则值的范围为0到1024。

所以为了使用最新版本中的ASM功能，新创建的磁盘组compatible.asm/compatible.rdbms的取值需要参考现有磁盘组的取值，当前现有磁盘组的compatible.asm/compatible.rdbms属性值为11.2.0.4.0，所以上面创建的TEST磁盘组的compatible.asm/compatible.rdbms设置为11.2.0.4.0。

 **compatible.asm/compatible.rdbms**
**的设置只有在新创建磁盘组时指定，在现有磁盘组中添加或删除磁盘时不用指定此参数。**

以下查看现有磁盘组的compatible.asm/compatible.rdbms属性值：

SQL> SELECT dg.name AS diskgroup, SUBSTR(c.instance_name,1,12) AS instance,

  2  SUBSTR(c.db_name,1,12) AS dbname, SUBSTR(c.SOFTWARE_VERSION,1,12) AS
software,

  3  SUBSTR(c.COMPATIBLE_VERSION,1,12) AS compatible

  4  FROM V$ASM_DISKGROUP dg, V$ASM_CLIENT c

  5  WHERE dg.group_number = c.group_number;



DISKGROUP   INSTANCE     DBNAME   SOFTWARE     COMPATIBLE

\----------- ------------ -------- ------------ ------------

CRS         +ASM1        +ASM     11.2.0.4.0   11.2.0.4.0

DATA        qldb1        qldb     11.2.0.4.0   11.2.0.4.0



以下查询新创建的磁盘组指定了compatible.asm/compatible.rdbms

SQL> set line 200

SQL> select inst_id,name,state,type,free_mb,substr(compatibility,1,10)
compatibility from gv$asm_diskgroup where name='TEST';



   INST_ID NAME    STATE       TYPE      FREE_MB COMPATIBIL

\---------- ------- ----------- ------ ---------- ----------

         1 TEST    MOUNTED     EXTERN       8095 11.2.0.4.0

         2 TEST    MOUNTED     EXTERN       8095 11.2.0.4.0



如果创建磁盘组时不指定compatible.asm/compatible.rdbms，默认是10.1.0.0.0。

SQL>  select inst_id,name,state,type,free_mb,substr(compatibility,1,10)
compatibility from gv$asm_diskgroup where name='TEST';



   INST_ID NAME   STATE       TYPE      FREE_MB COMPATIBIL

\---------- ------ ----------- ------ ---------- ----------

         1 TEST   MOUNTED     EXTERN       8097 10.1.0.0.0

         2 TEST   MOUNTED     EXTERN       8097 10.1.0.0.0



测试成功后，删除磁盘组，准备添加磁盘

SQL> alter diskgroup TEST dismount;

SQL> drop diskgroup TEST force including contents;

## 3、在现有的磁盘组中添加磁盘

当出现本文档“使用场景”的第一个场景时，需要添加磁盘到现有磁盘组：

[grid@0906rac1 ~]$ sqlplus / as sysasm

SQL> alter diskgroup data add disk '/u01/asm-disk/data2','/u01/asm-
disk/data3';

其中data为磁盘组名，/u01/asm-disk/data*为磁盘的全路径和磁盘名称。



查看添加情况

SQL> col path format a20;

SQL> col group_name format a10

SQL> col name format a20

SQL> col FAILGROUP_TYPE format a15

SQL> col FAILGROUP format a15

SQL> select a.group_number,b.name as
group_name,a.FAILGROUP,a.name,a.path,a.state,a.total_mb from v$asm_disk
a,v$asm_diskgroup b where a.group_number=b.group_number;



GROUP_NUMBER GROUP_NAME FAILGROUP NAME      PATH                STATE
TOTAL_MB

\------------ ---------- --------- --------- ------------------- ------
--------

           1 ARCH       ARCH_0000 ARCH_0000 /u01/asm-disk/fra1  NORMAL     2048

           2 CRS        CRS_0000  CRS_0000  /u01/asm-disk/ocr1  NORMAL     1024

           3 DATA       DATA_0000 DATA_0000 /u01/asm-disk/data1 NORMAL     4096

           2 CRS        CRS_0001  CRS_0001  /u01/asm-disk/ocr2  NORMAL     1024

           2 CRS        CRS_0002  CRS_0002  /u01/asm-disk/ocr3  NORMAL     1024

           3 DATA       DATA_0001 DATA_0001 /u01/asm-disk/data2 NORMAL     4096

           3 DATA       DATA_0002 DATA_0002 /u01/asm-disk/data3 NORMAL     4096

7 rows selected.

## 4、在现有的磁盘组中删除磁盘

当出现本文档“使用场景”的第二个场景时，需要在现有磁盘组中删除磁盘，

 **注意，删除磁盘前需要确认磁盘组中剩余的磁盘是否可以存放磁盘组中的所有数据** 。

[grid@0906rac1 ~]$ sqlplus / as sysasm

SQL> alter diskgroup data drop disk 'DATA_0000';



此时虽然命令已经结束，但是磁盘还未完全删除，ASM在平衡磁盘中的数据。

 **切记，不要立即格式化删除的磁盘，等ASM平衡完成后在对磁盘做操作。**

查看数据平衡速度：

SQL> select GROUP_NUMBER,OPERATION,POWER,EST_WORK,EST_RATE,EST_MINUTES from
v$asm_operation;

GROUP_NUMBER OPERA      POWER   EST_WORK   EST_RATE EST_MINUTES

\------------ ----- ---------- ---------- ---------- -----------

           3 REBAL          1       1013        471           2



GROUP_NUMBER: ASM正在平衡数据的磁盘组编号

OPERA       : ASM的操作类型，REBAL表示正在平衡数据

EST_WORK    : 预计需要平衡的单元数

EST_RATE    : 预计每分钟平衡的单元数

EST_MINUTES : 预计剩余时间，分钟为单位

POWER       :
数据平衡时使用的进程数量，进程数量越多，重新平衡操作就越快，但会消耗更多的CPU和I/O资源，在业务繁忙时段，不要将此数值设置的过高，以免影响应用程序因系统资源消耗过高而变慢。

POWER取值在0到11之间，其中0表示停止重新平衡，11是平衡的速度最快。

从Oracle Database
11g第2版（11.2.0.2）开始，如果COMPATIBLE.ASM磁盘组属性设置为11.2.0.2或更高版本，则值的范围为0到1024。

可以动态调整此参数，但是调整ASM_POWER_LIMIT只会影响未来的重新平衡。它不影响正在进行的重新平衡。

SQL> show parameter limit

NAME                                 TYPE        VALUE

\------------------------------------ ----------- ------

asm_power_limit                      integer     1

为了改变进行中的重新平衡的进程数，需要使用以下命令发出一个新的重新平衡指令。

ALTER DISKGROUP <磁盘组名> REBALANCE [POWER n];

POWER参考文档：

 **How To Change The Asm Rebalancing Power After Starting The Rebalancing
Process (** **文档** **ID 563362.1)**

当平衡完成后，以上查询无返回结果，然后通过以下查询确定磁盘状态

SQL> select path,header_status from v$asm_disk where path = '/u01/asm-
disk/data1';



PATH                 HEADER_STATU

\-------------------- ------------

/u01/asm-disk/data1  FORMER



当HEADER_STATU的值为FORMER时，表示磁盘已经完全从磁盘组中踢出。

当HEADER_STATU的值为MEMBER时，表示磁盘还是当前磁盘组的成员。



V$ASM_DISK字段含义参考：

[https://docs.oracle.com/cd/E11882_01/server.112/e40402/dynviews_1024.htm#REFRN30170](https://docs.oracle.com/cd/E11882_01/server.112/e40402/dynviews_1024.htm#REFRN30170)



V$ASM_OPERATION字段含义参考：

[http://docs.oracle.com/cd/E11882_01/server.112/e40402/dynviews_1031.htm#REFRN30173](http://docs.oracle.com/cd/E11882_01/server.112/e40402/dynviews_1031.htm#REFRN30173)

## 5、在现有的磁盘组中替换磁盘

当出现本文档“使用场景”的第三个场景时，需要在现有磁盘组中替换磁盘：

在替换磁盘之前，先执行本文档第2步，验证添加的磁盘可用性。

[grid@0906rac1 ~]$ sqlplus / as sysasm

SQL> alter diskgroup data add disk '/u01/asm-disk/data1' name DATA_0000 drop
disk DATA_0001,DATA_0002 rebalance power 2;

如果添加多个磁盘，以逗号隔开，例如：

SQL> alter diskgroup data add disk '/u01/asm-disk/data1' name
DATA_0000[,'/u01/asm-disk/data*' name DATA_000*]

drop disk DATA_0001,DATA_0002

rebalance power 2;

此时虽然命令已经结束，但是磁盘还未完全删除，ASM在平衡磁盘中的数据。

 **切记，不要立即格式化删除的磁盘，等ASM平衡完成后在对磁盘做操作。**

查看平衡信息，请参考本文档第四步。



如果添加失败,被替换的磁盘会显示DROPPING状态，表示等待重平衡数据，磁盘可以正常访问。

例如，ASM中现有磁盘的路径是/dev/asm-disk*，先添加的磁盘路径是/u01/asm-
disk/ssd_data*，执行以上替换命令后会出现以下报错信息：



ORA-15032: not all alterations performed

ORA-15031: disk specification '/u01/asm-disk/ssd_data2' matches no disks

ORA-15014: path '/dev/mapper/ssd_data2' is not in the discovery set

ORA-15031: disk specification '/u01/asm-disk/ssd_data1' matches no disks

ORA-15014: path '/dev/mapper/ssd_data1' is not in the discovery set

此时，ASM的扫描磁盘路径是：

SQL> show parameter disk



NAME                                 TYPE        VALUE

\------------------------------------ ----------- --------------------

asm_diskgroups                       string      DATA, FRA

asm_diskstring                       string      /dev/



GROUP_NUMBER GROUP_NAME NAME       PATH             STATE      TOTAL_MB

\------------ ---------- ---------- ---------------- -------- ----------

           3 FRA        FRA_0007   /dev/asm-disk18  NORMAL       204797

           2 DATA       DATA_0004  /dev/asm-disk7   DROPPING     204797

           2 DATA       DATA_0001  /dev/asm-disk4   DROPPING     204797

           2 DATA       DATA_0002  /dev/asm-disk5   DROPPING     204797

 **ORA-15071: ASM disk "<disk_name>" is already being dropped (** **文档** **ID
1684159.1)**



解决方法是将原有的磁盘使用软连接，链接到需要添加磁盘的路径下面:

ln -s /dev/asm-disk7 /u01/asm-disk/asm-disk7

ln -s /dev/asm-disk4 /u01/asm-disk/asm-disk4

ln -s /dev/asm-disk5 /u01/asm-disk/asm-disk5

修改ASM扫描路径为新磁盘的路径：

SQL> alter system set asm_diskstring ='/u01/asm-disk/';

alter system set asm_diskstring ='/u01/asm-disk/'

*

ERROR at line 1:

ORA-02097: parameter cannot be modified because specified value is invalid

ORA-15014: path '/dev/asm-disk8' is not in the discovery set



 **SQL > alter system set asm_diskstring ='/u01/asm-disk/' scope=spfile;**

注意，此时需要重启ASM实例

SQL> shutdown immediate

ASM instance shutdown

SQL> startup

ASM instance started



Total System Global Area 1135747072 bytes

Fixed Size                  2260728 bytes

Variable Size            1108320520 bytes

ASM Cache                  25165824 bytes

ASM diskgroups mounted

ASM diskgroups volume enabled

SQL> show parameter disk



NAME                                 TYPE        VALUE

\------------------------------------ ----------- ------------------

asm_diskgroups                       string      DATA, FRA

asm_diskstring                       string      /u01/asm-disk/



然后执行磁盘添加命令，但此时需要使用FORCE参数。

SQL> ALTER DISKGROUP DATA ADD DISK '/u01/asm-disk/ssd_data1','/u01/asm-
disk/ssd_data2','/u01/asm-disk/ssd_data3','/u01/asm-disk/ssd_data4','/u01/asm-
disk/ssd_data5','/u01/asm-disk/ssd_data6','/u01/asm-disk/ssd_data7';

ALTER DISKGROUP DATA ADD DISK '/u01/asm-disk/ssd_data1','/u01/asm-
disk/ssd_data2','/u01/asm-disk/ssd_data3','/u01/asm-disk/ssd_data4','/u01/asm-
disk/ssd_data5','/u01/asm-disk/ssd_data6','/u01/asm-disk/ssd_data7'

*

ERROR at line 1:

ORA-15032: not all alterations performed

ORA-15033: disk '/u01/asm-disk/ssd_data5' belongs to diskgroup "DATA"

ORA-15033: disk '/u01/asm-disk/ssd_data4' belongs to diskgroup "DATA"



SQL> ALTER DISKGROUP DATA ADD DISK '/u01/asm-disk/ssd_data1' FORCE,'/u01/asm-
disk/ssd_data2' FORCE,'/u01/asm-disk/ssd_data3' FORCE,'/u01/asm-
disk/ssd_data4' FORCE,'/u01/asm-disk/ssd_data5' FORCE,'/u01/asm-
disk/ssd_data6' FORCE,'/u01/asm-disk/ssd_data7' FORCE;



Diskgroup altered.

  

相关文档

内部备注

附件

验证码：

  换一张

输入验证码：

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAYAAAA7MK6iAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEgAACxIB0t1+/AAAABZ0RVh0Q3JlYXRpb24gVGltZQAwOS8yNy8xN+stbYgAAAAcdEVYdFNvZnR3YXJlAEFkb2JlIEZpcmV3b3JrcyBDUzbovLKMAAABm0lEQVRIicXXwXGCQBTG8b+7uZsSTAXRCiQVhA6SXLgmJZgO5BguSQnYgR0EK0hKiAUs5rBvGVlBBEG/GWccxf0JC2/fjna7HU3JEz0BQnlNgbF3yBbIgBRIVWR+m8YcHYPzRE+BBfDY+O/KWQELFZmsNZwnegm8tgT9xCoybyfBeaJvgTVwfybqsgECFZm//Q/VwCgy1lrGroYHQEt4JSxzOgRa4GIAMsdy934PiO5npiKTuTNeXAgtrJH5UBPg54IwwJ3CVqO+swEegPea78MhYPfcroFlzTGhwtbevlFXLOrgqeKw4PeC5on+Ap5qjh37BcTPFjtXL/K+DxSAmwY4k7kiT3SGrT7+FWqNwmHJ9DPPE/0MIEtcQPnMO6EOPnYJAT5r8M4osFXYzqEpVXhXFCBT2HbllJTwM1CAtA1cws9AAVK3OqW066tibOGZd0BXKjLhdZdFuWHiC6Cx6zxLzZ4UiaG6kI2KTLEu+AUkwD6fvaMydpESLI9I33hle3u1hr62VssPZtjtSNussHdvJQoNeyeXITZt/1po2U5WDlb1AAAAAElFTkSuQmCC)![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAYAAAA7MK6iAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEgAACxIB0t1+/AAAABZ0RVh0Q3JlYXRpb24gVGltZQAwOS8yNy8xN+stbYgAAAAcdEVYdFNvZnR3YXJlAEFkb2JlIEZpcmV3b3JrcyBDUzbovLKMAAABu0lEQVRIicWX223CQBBFD26AlOAOMJoCQgl0AFQQSoEOoAN3EPLPKHYHKSFUQD686/jFPkysXMkSQsMc1jt7Z3Z2v9/xSVVTYG2eDJh3Qm5AAeRALiJfvpwzF1hVM2APbLz/rq0zcBCRIhqsqgfgLRLY1VFE9kFgVX0BLsDiSahVCaxE5Lv5ZTIxFJPrYnIPgyeAtuCDYLOnU0BruGEAZo9N9X5OCG1qKSKFXfFg5TVURiT2xe4BEmMOrnNaikgG7AKgOxPrgm9UNU2o3MilhapmInLywHcicjLblnpyrkPAUB0HF7wJvdC31EFwFgCeO+CxUIBsdr1e/V3iVzcqFypUdQswAgpALLgFh7qRREGh71yhSjufo6BjwHa1uapmZs9zwo5aD3yLhBaN1+ur9oe5EqrJYQx0jrvaXSoSqnHFJwtd0S+kMfA8BFw2js87w4XUhX/4wLY7nfD4NWEt0w59r46Ys4hsbVUfHIEEQqFauQtasxIAYwbHwOTP6GiNpzXsqWrBdFOIba9A30BWxDX9YKjJXasFNiPoX8MHx9t/G+gferX5wZLqOhKrM9VQ93CWc96drKa4tP0As8vvCUvsIrEAAAAASUVORK5CYII=)

sentinel

&nbsp;

GROUP_NUMBER
NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
STATE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; TYPE&nbsp;&nbsp;&nbsp;&nbsp;
TOTAL_MB&nbsp;&nbsp;&nbsp; FREE_MB USABLE_FILE_MB

\------------ --------------- ----------- ------ ---------- ----------
--------------

&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1
ARCH&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
MOUNTED&nbsp;&nbsp;&nbsp;&nbsp; EXTERN&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
2048&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1660&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1660

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2
CRS&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
MOUNTED&nbsp;&nbsp;&nbsp;&nbsp; NORMAL&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
3072&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
2146&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 561

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 3
DATA&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
MOUNTED&nbsp;&nbsp;&nbsp;&nbsp; EXTERN&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
4096&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
2055&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2055

&nbsp;

SQL&gt; set pagesize 200

SQL&gt; set linesize 150

SQL&gt; col path format a20;

SQL&gt; col group_name format a10

SQL&gt; col name format a20

SQL&gt; col FAILGROUP_TYPE format a15

SQL&gt; col FAILGROUP format a15

SQL&gt; select a.group_number,b.name as
group_name,a.FAILGROUP,a.name,a.path,a.state,a.total_mb from v$asm_disk
a,v$asm_diskgroup b where a.group_number=b.group_number;

&nbsp;

GROUP_NUMBER GROUP_NAME FAILGROUP NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
PATH&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
STATE&nbsp; TOTAL_MB

\------------ ---------- --------- --------- -------------------- ------
--------

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1
ARCH&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ARCH_0000 ARCH_0000 /u01/asm-
disk/fra1&nbsp;&nbsp; NORMAL&nbsp;&nbsp;&nbsp;&nbsp; 2048

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2
CRS&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; CRS_0000&nbsp; CRS_0000&nbsp;
/u01/asm-disk/ocr1&nbsp;&nbsp; NORMAL&nbsp;&nbsp;&nbsp;&nbsp; 1024

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 3
DATA&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; DATA_0000 DATA_0000 /u01/asm-
disk/data1&nbsp; NORMAL&nbsp;&nbsp;&nbsp;&nbsp; 4096

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2
CRS&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; CRS_0001&nbsp; CRS_0001&nbsp;
/u01/asm-disk/ocr2&nbsp;&nbsp; NORMAL&nbsp;&nbsp;&nbsp;&nbsp; 1024

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2
CRS&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; CRS_0002&nbsp; CRS_0002&nbsp;
/u01/asm-disk/ocr3&nbsp;&nbsp; NORMAL&nbsp;&nbsp;&nbsp;&nbsp; 1024

&nbsp;

SQL&gt; show parameter disk

&nbsp;

NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
TYPE&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;VALUE

\------------------------------------ -----------
------------------------------

asm_diskgroups&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
string&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; DATA, ARCH

asm_diskstring&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
string&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /u01/asm-disk/*

## 1、添加磁盘前的准备

添加磁盘前，请存储工程师划分磁盘，划分的磁盘大小与要添加的磁盘组（本实验为DATA磁盘组）中的磁盘（本实验DATA_0000）大小相同。

磁盘划分完成后，请存储工程师配置多路径，告知聚合后的磁盘路径和名称。

&nbsp;

 **Linux** **操作系统磁盘准备：**

参考指导书：《oracle11gR2-RACforLinux5&amp;6手册》 10、ASM配置共享磁盘

配置UDEV绑定磁盘，修改磁盘权限，创建用于ASM访问的磁盘软链接。

 **AIX** **操作系统磁盘准备：**

参考指导书：《Oracle 11gR2 AIX RAC安装手册》 10、ASM配置共享磁盘

 **WINDOWS** **操作系统磁盘准备：**

参考指导书：《oracle11gR2-RAC for Windows 2008&amp;2012手册》 10、ASM配置共享磁盘

 **HP-UX** **操作系统磁盘准备：**

参考指导书：《Oracle 11gR2 HPUX RAC安装手册》 10、ASM配置共享磁盘

&nbsp;

 **需要注意的事项：**

### 1）新添加的磁盘大小与原磁盘组中磁盘相同

### 2）新添加的磁盘路径与原磁盘组中磁盘相同

新添加的磁盘路径与原磁盘组中磁盘相同，如果出现多个扫描路径下的对应相同的物理磁盘，会出现类似以下报错：

SQL&gt; alter diskgroup data add disk
&#39;/dev/raw/raw6&#39;,&#39;/dev/raw/raw7&#39;;

alter diskgroup data add disk &#39;/dev/raw/raw6&#39;,&#39;/dev/raw/raw7&#39;

*

ERROR at line 1:

ORA-15032: not all alterations performed

ORA-15031: disk specification &#39;/dev/raw/raw7&#39; matches no disks

ORA-15014: path &#39;/dev/raw/raw7&#39; is not in the discovery set

ORA-15031: disk specification &#39;/dev/raw/raw6&#39; matches no disks

ORA-15014: path &#39;/dev/raw/raw6&#39; is not in the discovery set

本实验将RAW绑定的裸设备(/dev/raw/raw*)建立软连接，到/u01/asm-disk目录下。

建立软连接的原因是：当操作系统层面上的磁盘设备编号发生改变后，无需更改集群ASM配置，重建软连接即可。

### 3）不要执行start_udev，手动RAW绑定设备

在Linux环境中配置好udev配置文件后，不要执行start_udev,不然集群会出问题，本实验中VIP漂移至其他节点上：

[grid@0906rac1 ~]$ crsctl status res -t

ora.LISTENER.lsnr

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; OFFLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
0906rac1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0906rac2

ora.0906rac1.vip

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; INTERMEDIATE
0906rac2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; FAILED
OVER&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

ora.0906rac2.vip

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ONLINE&nbsp; ONLINE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
0906rac2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

如果出现这种现象，使用以下命令将VIP手动漂移回原节点：

[grid@0906rac1 ~]$ srvctl relocate vip -i 0906rac1&nbsp; -n 0906rac1

执行start_udev出现VIP漂移的原因：

在执行start_udev期间，udev会删除公共网络接口，这将导致监听崩溃，并且clusterware将所有服务，SCAN
监听和节点1上的VIP移动到节点2。

 **Network interface going down when dynamically adding disks to storage using
udev in RHEL 6 (** **文档** **ID 1569028.1)**

&nbsp;

此时需要在集群的所有节点上执行RAW手动绑定设备并更改属性和权限，与客户协商计划内停机，验证服务器重启后磁盘是否可以正常加载：

raw /dev/raw/raw6 /dev/sdg

raw /dev/raw/raw7 /dev/sdh

&nbsp;

chown grid:asmadmin /dev/raw/raw6

chown grid:asmadmin /dev/raw/raw7

&nbsp;

chmod 660 /dev/raw/raw6

chmod 660 /dev/raw/raw7

## 2、添加磁盘前的测试

1 判断磁盘中是否存在数据，使用如下命令

# for DISK in $(awk &#39;!/name/ {print $NF}&#39; /proc/partitions); do echo
-n &quot;$DISK &quot;; if [ $(hexdump -n10485760 /dev/$DISK | head | wc -l)
-gt &quot;3&quot; ]; then echo &quot;has data&quot;; else echo &quot;is
empty&quot;; fi; done;

vda has data

vdb is empty

&nbsp;

注：以上脚本是依据hexdump命令的输出，aix是lquerypv&nbsp;、linux是hexdump

如果有数据要和客户进行确认才能进行格式化操作，对于单次服务工作，还必须要客户签订免责协议，才能进行格式化等操作。

&nbsp;

2 在配置好磁盘后，需要先使用添加的磁盘创建一个测试的磁盘组，验证当前磁盘可用，例如：

SQL&gt; CREATE DISKGROUP TEST EXTERNAL REDUNDANCY DISK &#39;/u01/asm-
disk/data2&#39;,&#39;/u01/asm-disk/data3&#39; attribute
&#39;compatible.asm&#39;
=&#39;11.2.0.4.0&#39;,&#39;compatible.rdbms&#39;=&#39;11.2.0.4.0&#39;;

Diskgroup created.

&nbsp;

在其他节点mount新创建的磁盘组

[grid@0906rac2 ~]$ sqlplus / as sysasm

SQL&gt; alter diskgroup test mount;

其中compatible.asm和compatible.rdbms是Oracle 11g
ASM中引入的磁盘组兼容性属性，此属性确定可连接到ASM磁盘组的ASM实例和数据库实例的最低版本，推进磁盘组Oracle数据库和ASM兼容性设置使您能够使用最新版本中提供的新的ASM功能，比如本文档后面提到的数据平衡进程数Power的取值范围是0-11之间，如果COMPATIBLE.ASM磁盘组属性设置为11.2.0.2或更高版本，则值的范围为0到1024。

所以为了使用最新版本中的ASM功能，新创建的磁盘组compatible.asm/compatible.rdbms的取值需要参考现有磁盘组的取值，当前现有磁盘组的compatible.asm/compatible.rdbms属性值为11.2.0.4.0，所以上面创建的TEST磁盘组的compatible.asm/compatible.rdbms设置为11.2.0.4.0。

 **compatible.asm/compatible.rdbms**
**的设置只有在新创建磁盘组时指定，在现有磁盘组中添加或删除磁盘时不用指定此参数。**

以下查看现有磁盘组的compatible.asm/compatible.rdbms属性值：

SQL&gt; SELECT dg.name AS diskgroup, SUBSTR(c.instance_name,1,12) AS instance,

&nbsp; 2&nbsp; SUBSTR(c.db_name,1,12) AS dbname,
SUBSTR(c.SOFTWARE_VERSION,1,12) AS software,

&nbsp; 3&nbsp; SUBSTR(c.COMPATIBLE_VERSION,1,12) AS compatible

&nbsp; 4&nbsp; FROM V$ASM_DISKGROUP dg, V$ASM_CLIENT c

&nbsp; 5&nbsp; WHERE dg.group_number = c.group_number;

&nbsp;

DISKGROUP&nbsp;&nbsp; INSTANCE&nbsp;&nbsp;&nbsp;&nbsp; DBNAME&nbsp;&nbsp;
SOFTWARE&nbsp;&nbsp;&nbsp;&nbsp; COMPATIBLE

\----------- ------------ -------- ------------ ------------

CRS&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
+ASM1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; +ASM&nbsp;&nbsp;&nbsp;&nbsp;
11.2.0.4.0&nbsp;&nbsp; 11.2.0.4.0

DATA&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
qldb1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; qldb&nbsp;&nbsp;&nbsp;&nbsp;
11.2.0.4.0&nbsp;&nbsp; 11.2.0.4.0

&nbsp;

以下查询新创建的磁盘组指定了compatible.asm/compatible.rdbms

SQL&gt; set line 200

SQL&gt; select inst_id,name,state,type,free_mb,substr(compatibility,1,10)
compatibility from gv$asm_diskgroup where name=&#39;TEST&#39;;

&nbsp;

&nbsp;&nbsp; INST_ID NAME&nbsp;&nbsp;&nbsp;
STATE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; TYPE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
FREE_MB COMPATIBIL

\---------- ------- ----------- ------ ---------- ----------

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1 TEST&nbsp;&nbsp;&nbsp;
MOUNTED&nbsp;&nbsp;&nbsp;&nbsp; EXTERN&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
8095 11.2.0.4.0

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2 TEST&nbsp;&nbsp;&nbsp;
MOUNTED&nbsp;&nbsp;&nbsp;&nbsp; EXTERN&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
8095 11.2.0.4.0

&nbsp;

如果创建磁盘组时不指定compatible.asm/compatible.rdbms，默认是10.1.0.0.0。

SQL&gt;&nbsp; select
inst_id,name,state,type,free_mb,substr(compatibility,1,10) compatibility from
gv$asm_diskgroup where name=&#39;TEST&#39;;

&nbsp;

&nbsp;&nbsp; INST_ID NAME&nbsp;&nbsp;
STATE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; TYPE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
FREE_MB COMPATIBIL

\---------- ------ ----------- ------ ---------- ----------

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1 TEST&nbsp;&nbsp;
MOUNTED&nbsp;&nbsp;&nbsp;&nbsp; EXTERN&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
8097 10.1.0.0.0

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2 TEST&nbsp;&nbsp;
MOUNTED&nbsp;&nbsp;&nbsp;&nbsp; EXTERN&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
8097 10.1.0.0.0

&nbsp;

测试成功后，删除磁盘组，准备添加磁盘

SQL&gt; alter diskgroup TEST dismount;

SQL&gt; drop diskgroup TEST force including contents;

## 3、在现有的磁盘组中添加磁盘

当出现本文档“使用场景”的第一个场景时，需要添加磁盘到现有磁盘组：

[grid@0906rac1 ~]$ sqlplus / as sysasm

SQL&gt; alter diskgroup data add disk &#39;/u01/asm-
disk/data2&#39;,&#39;/u01/asm-disk/data3&#39;;

其中data为磁盘组名，/u01/asm-disk/data*为磁盘的全路径和磁盘名称。

&nbsp;

查看添加情况

SQL&gt; col path format a20;

SQL&gt; col group_name format a10

SQL&gt; col name format a20

SQL&gt; col FAILGROUP_TYPE format a15

SQL&gt; col FAILGROUP format a15

SQL&gt; select a.group_number,b.name as
group_name,a.FAILGROUP,a.name,a.path,a.state,a.total_mb from v$asm_disk
a,v$asm_diskgroup b where a.group_number=b.group_number;

&nbsp;

GROUP_NUMBER GROUP_NAME FAILGROUP NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
PATH&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
STATE&nbsp; TOTAL_MB

\------------ ---------- --------- --------- ------------------- ------
--------

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1
ARCH&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ARCH_0000 ARCH_0000 /u01/asm-
disk/fra1&nbsp; NORMAL&nbsp;&nbsp;&nbsp;&nbsp; 2048

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2
CRS&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; CRS_0000&nbsp; CRS_0000&nbsp;
/u01/asm-disk/ocr1&nbsp; NORMAL&nbsp;&nbsp;&nbsp;&nbsp; 1024

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 3
DATA&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; DATA_0000 DATA_0000 /u01/asm-
disk/data1 NORMAL&nbsp;&nbsp;&nbsp;&nbsp; 4096

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2
CRS&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; CRS_0001&nbsp; CRS_0001&nbsp;
/u01/asm-disk/ocr2&nbsp; NORMAL&nbsp;&nbsp;&nbsp;&nbsp; 1024

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2
CRS&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; CRS_0002&nbsp; CRS_0002&nbsp;
/u01/asm-disk/ocr3&nbsp; NORMAL&nbsp;&nbsp;&nbsp;&nbsp; 1024

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 3
DATA&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; DATA_0001 DATA_0001 /u01/asm-
disk/data2 NORMAL&nbsp;&nbsp;&nbsp;&nbsp; 4096

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 3
DATA&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; DATA_0002 DATA_0002 /u01/asm-
disk/data3 NORMAL&nbsp;&nbsp;&nbsp;&nbsp; 4096

7 rows selected.

## 4、在现有的磁盘组中删除磁盘

当出现本文档“使用场景”的第二个场景时，需要在现有磁盘组中删除磁盘，

 **注意，删除磁盘前需要确认磁盘组中剩余的磁盘是否可以存放磁盘组中的所有数据** 。

[grid@0906rac1 ~]$ sqlplus / as sysasm

SQL&gt; alter diskgroup data drop disk &#39;DATA_0000&#39;;

&nbsp;

此时虽然命令已经结束，但是磁盘还未完全删除，ASM在平衡磁盘中的数据。

 **切记，不要立即格式化删除的磁盘，等ASM平衡完成后在对磁盘做操作。**

查看数据平衡速度：

SQL&gt; select GROUP_NUMBER,OPERATION,POWER,EST_WORK,EST_RATE,EST_MINUTES from
v$asm_operation;

GROUP_NUMBER OPERA&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; POWER&nbsp;&nbsp;
EST_WORK&nbsp;&nbsp; EST_RATE EST_MINUTES

\------------ ----- ---------- ---------- ---------- -----------

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 3
REBAL&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1013&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
471&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2

&nbsp;

GROUP_NUMBER: ASM正在平衡数据的磁盘组编号

OPERA&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : ASM的操作类型，REBAL表示正在平衡数据

EST_WORK&nbsp;&nbsp;&nbsp; : 预计需要平衡的单元数

EST_RATE&nbsp;&nbsp;&nbsp; : 预计每分钟平衡的单元数

EST_MINUTES : 预计剩余时间，分钟为单位

POWER&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; :
数据平衡时使用的进程数量，进程数量越多，重新平衡操作就越快，但会消耗更多的CPU和I/O资源，在业务繁忙时段，不要将此数值设置的过高，以免影响应用程序因系统资源消耗过高而变慢。

POWER取值在0到11之间，其中0表示停止重新平衡，11是平衡的速度最快。

从Oracle Database
11g第2版（11.2.0.2）开始，如果COMPATIBLE.ASM磁盘组属性设置为11.2.0.2或更高版本，则值的范围为0到1024。

可以动态调整此参数，但是调整ASM_POWER_LIMIT只会影响未来的重新平衡。它不影响正在进行的重新平衡。

SQL&gt; show parameter limit

NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
TYPE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; VALUE

\------------------------------------ ----------- ------

asm_power_limit&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
integer&nbsp;&nbsp;&nbsp;&nbsp; 1

为了改变进行中的重新平衡的进程数，需要使用以下命令发出一个新的重新平衡指令。

ALTER DISKGROUP &lt;磁盘组名&gt; REBALANCE [POWER n];

POWER参考文档：

 **How To Change The Asm Rebalancing Power After Starting The Rebalancing
Process (** **文档** **ID 563362.1)**

当平衡完成后，以上查询无返回结果，然后通过以下查询确定磁盘状态

SQL&gt; select path,header_status from v$asm_disk where path = &#39;/u01/asm-
disk/data1&#39;;

&nbsp;

PATH&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
HEADER_STATU

\-------------------- ------------

/u01/asm-disk/data1&nbsp; FORMER

&nbsp;

当HEADER_STATU的值为FORMER时，表示磁盘已经完全从磁盘组中踢出。

当HEADER_STATU的值为MEMBER时，表示磁盘还是当前磁盘组的成员。

&nbsp;

V$ASM_DISK字段含义参考：

[https://docs.oracle.com/cd/E11882_01/server.112/e40402/dynviews_1024.htm#REFRN30170](https://47.100.29.40/highgo_admin/%22https://docs.oracle.com/cd/E11882_01/server.112/e40402/dynviews_1024.htm#REFRN30170")

&nbsp;

V$ASM_OPERATION字段含义参考：

[http://docs.oracle.com/cd/E11882_01/server.112/e40402/dynviews_1031.htm#REFRN30173](https://47.100.29.40/highgo_admin/%22http://docs.oracle.com/cd/E11882_01/server.112/e40402/dynviews_1031.htm#REFRN30173")

## 5、在现有的磁盘组中替换磁盘

当出现本文档“使用场景”的第三个场景时，需要在现有磁盘组中替换磁盘：

在替换磁盘之前，先执行本文档第2步，验证添加的磁盘可用性。

[grid@0906rac1 ~]$ sqlplus / as sysasm

SQL&gt; alter diskgroup data add disk &#39;/u01/asm-disk/data1&#39; name
DATA_0000 drop disk DATA_0001,DATA_0002 rebalance power 2;

如果添加多个磁盘，以逗号隔开，例如：

SQL&gt; alter diskgroup data add disk &#39;/u01/asm-disk/data1&#39; name
DATA_0000[,&#39;/u01/asm-disk/data*&#39; name DATA_000*]

drop disk DATA_0001,DATA_0002

rebalance power 2;

此时虽然命令已经结束，但是磁盘还未完全删除，ASM在平衡磁盘中的数据。

 **切记，不要立即格式化删除的磁盘，等ASM平衡完成后在对磁盘做操作。**

查看平衡信息，请参考本文档第四步。

&nbsp;

如果添加失败,被替换的磁盘会显示DROPPING状态，表示等待重平衡数据，磁盘可以正常访问。

例如，ASM中现有磁盘的路径是/dev/asm-disk*，先添加的磁盘路径是/u01/asm-
disk/ssd_data*，执行以上替换命令后会出现以下报错信息：

&nbsp;

ORA-15032: not all alterations performed

ORA-15031: disk specification &#39;/u01/asm-disk/ssd_data2&#39; matches no
disks

ORA-15014: path &#39;/dev/mapper/ssd_data2&#39; is not in the discovery set

ORA-15031: disk specification &#39;/u01/asm-disk/ssd_data1&#39; matches no
disks

ORA-15014: path &#39;/dev/mapper/ssd_data1&#39; is not in the discovery set

此时，ASM的扫描磁盘路径是：

SQL&gt; show parameter disk

&nbsp;

NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
TYPE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; VALUE

\------------------------------------ ----------- --------------------

asm_diskgroups&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
string&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; DATA, FRA

asm_diskstring&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
string&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /dev/

&nbsp;

GROUP_NUMBER GROUP_NAME NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
PATH&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
STATE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; TOTAL_MB

\------------ ---------- ---------- ---------------- -------- ----------

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 3
FRA&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; FRA_0007&nbsp;&nbsp; /dev/asm-
disk18&nbsp; NORMAL&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 204797

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2
DATA&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; DATA_0004&nbsp; /dev/asm-
disk7&nbsp;&nbsp; DROPPING&nbsp;&nbsp;&nbsp;&nbsp; 204797

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2
DATA&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; DATA_0001&nbsp; /dev/asm-
disk4&nbsp;&nbsp; DROPPING&nbsp;&nbsp;&nbsp;&nbsp; 204797

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2
DATA&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; DATA_0002&nbsp; /dev/asm-
disk5&nbsp;&nbsp; DROPPING&nbsp;&nbsp;&nbsp;&nbsp; 204797

 **ORA-15071: ASM disk &quot;&lt;disk_name&gt;&quot; is already being dropped
(** **文档** **ID 1684159.1)**

&nbsp;

解决方法是将原有的磁盘使用软连接，链接到需要添加磁盘的路径下面:

ln -s /dev/asm-disk7 /u01/asm-disk/asm-disk7

ln -s /dev/asm-disk4 /u01/asm-disk/asm-disk4

ln -s /dev/asm-disk5 /u01/asm-disk/asm-disk5

修改ASM扫描路径为新磁盘的路径：

SQL&gt; alter system set asm_diskstring =&#39;/u01/asm-disk/&#39;;

alter system set asm_diskstring =&#39;/u01/asm-disk/&#39;

*

ERROR at line 1:

ORA-02097: parameter cannot be modified because specified value is invalid

ORA-15014: path &#39;/dev/asm-disk8&#39; is not in the discovery set

&nbsp;

 **SQL &gt; alter system set asm_diskstring =&#39;/u01/asm-disk/&#39;
scope=spfile;**

注意，此时需要重启ASM实例

SQL&gt; shutdown immediate

ASM instance shutdown

SQL&gt; startup

ASM instance started

&nbsp;

Total System Global Area 1135747072 bytes

Fixed
Size&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
2260728 bytes

Variable
Size&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1108320520 bytes

ASM
Cache&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
25165824 bytes

ASM diskgroups mounted

ASM diskgroups volume enabled

SQL&gt; show parameter disk

&nbsp;

NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
TYPE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; VALUE

\------------------------------------ ----------- ------------------

asm_diskgroups&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
string&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; DATA, FRA

asm_diskstring&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
string&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /u01/asm-disk/

&nbsp;

然后执行磁盘添加命令，但此时需要使用FORCE参数。

SQL&gt; ALTER DISKGROUP DATA ADD DISK &#39;/u01/asm-
disk/ssd_data1&#39;,&#39;/u01/asm-disk/ssd_data2&#39;,&#39;/u01/asm-
disk/ssd_data3&#39;,&#39;/u01/asm-disk/ssd_data4&#39;,&#39;/u01/asm-
disk/ssd_data5&#39;,&#39;/u01/asm-disk/ssd_data6&#39;,&#39;/u01/asm-
disk/ssd_data7&#39;;

ALTER DISKGROUP DATA ADD DISK &#39;/u01/asm-disk/ssd_data1&#39;,&#39;/u01/asm-
disk/ssd_data2&#39;,&#39;/u01/asm-disk/ssd_data3&#39;,&#39;/u01/asm-
disk/ssd_data4&#39;,&#39;/u01/asm-disk/ssd_data5&#39;,&#39;/u01/asm-
disk/ssd_data6&#39;,&#39;/u01/asm-disk/ssd_data7&#39;

*

ERROR at line 1:

ORA-15032: not all alterations performed

ORA-15033: disk &#39;/u01/asm-disk/ssd_data5&#39; belongs to diskgroup
&quot;DATA&quot;

ORA-15033: disk &#39;/u01/asm-disk/ssd_data4&#39; belongs to diskgroup
&quot;DATA&quot;

&nbsp;

SQL&gt; ALTER DISKGROUP DATA ADD DISK &#39;/u01/asm-disk/ssd_data1&#39;
FORCE,&#39;/u01/asm-disk/ssd_data2&#39; FORCE,&#39;/u01/asm-
disk/ssd_data3&#39; FORCE,&#39;/u01/asm-disk/ssd_data4&#39;
FORCE,&#39;/u01/asm-disk/ssd_data5&#39; FORCE,&#39;/u01/asm-
disk/ssd_data6&#39; FORCE,&#39;/u01/asm-disk/ssd_data7&#39; FORCE;

&nbsp;

Diskgroup altered.

  

" name="docDetail" type="hidden">


---
### ATTACHMENTS
[7f025a17697ee15eb3197c61326b203b]: media/ORACLE_RAC添加和删除磁盘.html
[ORACLE_RAC添加和删除磁盘.html](media/ORACLE_RAC添加和删除磁盘.html)
>hash: 7f025a17697ee15eb3197c61326b203b  
>source-url: file://C:\Users\galaxy\Desktop\highgo\ORACLE RAC添加和删除磁盘_files\11947ec6e06f4dd6a765bcc48c4fc88d.png  

---
### NOTE ATTRIBUTES
>Created Date: 2018-09-25 03:29:08  
>Last Evernote Update Date: 2018-10-01 15:33:54  
>author: YangKwong  
>source: desktop.win  
>source-url: file://C:\Users\galaxy\Desktop\highgo\ORACLE RAC添加和删除磁盘.html  
>source-application: evernote.win32  