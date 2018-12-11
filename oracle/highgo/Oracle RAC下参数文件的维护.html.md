# Oracle RAC下参数文件的维护.html

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

061531604

Oracle RAC下参数文件的维护

目录

环境

文档用途

详细信息

相关文档

内部备注

附件

环境

系统平台：N/A

版本：N/A

文档用途

在RAC环境下，由于多节点不同实例在启动时都需要依赖参数文件，所以其管理更加复杂。本节就RAC下参数文件管理进行阐述。

详细信息

RAC下共享spfile

RAC环境下数据库在启动时，首先尝试寻找Cluster里面Database资源的Spfile配置选项。如果找不到对应的文件，那么继续按照单实例的寻找顺序在默认位置查找。

建议在RAC环境下使用共享的SPFILE，并在默认位置保留一个PFILE，里面通过SPFILE参数指向共享的SPFILE。默认在RAC安装配置完成，就自动生成了一个PFILE文件。

下面是RAC环境中一个参数文件的设置范例。

[oracle@raclinux1 ~]$ cd $ORACLE_HOME/dbs

[oracle@raclinux1 dbs]$ more initRACDB1.ora

SPFILE='+MY_DG2/RACDB/spfileRACDB.ora'  
  
---  
  
在此环境中，需要谨慎使用createspfile from
pfile的命令，很多朋友因为草率地执行这样的操作而导致数据库故障。在ASM或RAC环境中，通常的init<sid>.ora文件中只有如上示例的一行，如果此时执行createspfile
from pfile命令，则新创建的SPFILE文件将也只有这样一行信息，数据库将无法启动。

使用ASM存储参数文件

在ASM环境中，参数文件可以存储在ASM磁盘组上，而在Oracle RAC环境中，默认使用存储在ASM上的参数文件，在维护RAC环境的参数文件时要格外谨慎。

以下是一个测试过程，用于指导大家如何将参数文件转移到ASM存储并使之生效。

首先检查参数文件的位置，并通过SPFILE创建一个PFILE文件，进而在ASM磁盘上创建SPFILE文件。

SQL> connect / as sysdba

SQL> show parameter spfile

NAME    TYPE      VALUE

\------ ------- ------------------------------

spfile string   /oracle/product/11.2.0/db_1/dbs/spfileracdb11.ora

SQL> create pfile from spfile

File created.

SQL> create spfile='+RACDB_DATA' from
pfile='/oracle/product/11.2.0/db_1/dbs/initracdb11.ora';

File created.  
  
---  
  
  

检查ASM上的参数文件。

[grid@rac1 ~]$ asmcmd

ASMCMD> ls RACDB_DATA/racdb1/spfile*

spfileracdb1.ora  
  
---  
  
同步RAC两个节点上的参数文件，更改其内容，设置SPFILE参数指向ASM中的参数文件。

[oracle@rac1 dbs]$ echo "SPFILE='+RACDB_DATA/racdb1/spfileracdb1.ora'" >
/oracle/product/11.2.0/db_1/dbs/initracdb11.ora

[oracle@rac1 dbs]$ ssh rac2 "echo
\"SPFILE='+RACDB_DATA/racdb1/spfileracdb1.ora'\" >
/oracle/product/11.2.0/db_1/dbs/initracdb12.ora"  
  
---  
  
通过srvctl修改OCR中关于参数文件的配置。

[oracle@rac1 dbs]$ srvctl modify database -d racdb1
-p+RACDB_DATA/racdb1/spfileracdb1.ora  
---  
  
现在通过CRS启动数据库，将不再需要dbs目录下的参数文件，可以将其移除。

[oracle@rac1 dbs]$ mv /oracle/product/11.2.0/db_1/dbs/spfileracdb11.ora
/oracle/product/ 11.2.0/db_1/dbs/spfileracdb11.ora_bak

[oracle@rac1 dbs]$ ssh rac2 "mv
/oracle/product/11.2.0/db_1/dbs/spfileracdb12.ora
/oracle/product/11.2.0/db_1/dbs/spfileracdb12.ora_bak"  
  
---  
  
在下次重新启动数据库时，新的配置将会生效。

[oracle@rac1 dbs]$ srvctl stop database -d racdb1

[oracle@rac1 dbs]$ srvctl start database -d racdb1

[oracle@rac1 dbs]$ srvctl status database -d racdb1

Instance racdb11 is running on node rac1

Instance racdb12 is running on node rac2  
  
---  
  
检查数据库，新的参数文件已经被使用和生效。

SQL> SHOW parameter spfile

NAME TYPE VALUE

\------ ----------- ------------------------------

spfile string +RACDB_DATA/racdb1/spfileracdb1.ora  
  
---  
  
谨慎修改RAC参数

在RAC环境中，即使按照正常的方式修改参数，也有可能因为遭遇Bug而导致事故，所以在进行重要的环境变更前，一定要进行测试，并详细检查与变更有关的文件，确保变更不会引起错误。

在Oracle 10.1的版本中，会遇到这样的问题，在RAC环境下修改UNDO_RETENTION参数，使用如下命令：

alter system set undo_retention=18000 sid='*';  
---  
  
这条命令直接导致了RAC的其他节点挂起，Oracle记录了一个相关Bug，Bug号为：4220405（这个Bug在Oracle
10gR2中修正），其Workaround就是分别修改不同实例。

alter system set undo_retention=18000 sid='RAC1';

alter system set undo_retention=18000 sid='RAC2';

alter system set undo_retention=18000 sid='RAC3';  
  
---  
  
这个案例告诉我们，Bug无处不在，数据库调整应当极其谨慎，最好在测试环境中测试过再应用到生产环境。

再次重申，在RAC环境中，每一个维护操作都要相当谨慎！

RAC环境下初始化参数的查询方法

下面介绍RAC环境下初始化参数的查询方法。

一个简单的例子：

![noteattachment2][f27eeeda4a5a8a94edaa9b714a74e6f6]

不同的查询方法得到的结果。

![noteattachment3][d9b920f62c236d562c4a67c55215ce93]

似乎除了看不到全局设置外，GV$PARAMETER参数和V$SPPARAMETER没有什么不同，其实不然，如果alter system
set的时候只修改了spfile或者memory参数，结果就会不同。

从上面的对比可以看出，通过GV$视图访问的结果和SPFILE中包含的信息完全不同。除了上面介绍的几种视图之外，CREATE
PFILE也是一个不错的选择。Oracle把SPFILE也纳入到RMAN的备份恢复策略当中，如果你配置了控制文件自动备份（AUTOBACKUP），那么Oracle会在数据库发生重大变化（如增减表空间）时自动进行控制文件及SPFILE文件的备份。

  

相关文档

内部备注

原文链接：https://mp.weixin.qq.com/s/4YWwOdVFfjvmvgWYROsLEQ

附件

验证码：

  换一张

输入验证码：

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAYAAAA7MK6iAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEgAACxIB0t1+/AAAABZ0RVh0Q3JlYXRpb24gVGltZQAwOS8yNy8xN+stbYgAAAAcdEVYdFNvZnR3YXJlAEFkb2JlIEZpcmV3b3JrcyBDUzbovLKMAAABm0lEQVRIicXXwXGCQBTG8b+7uZsSTAXRCiQVhA6SXLgmJZgO5BguSQnYgR0EK0hKiAUs5rBvGVlBBEG/GWccxf0JC2/fjna7HU3JEz0BQnlNgbF3yBbIgBRIVWR+m8YcHYPzRE+BBfDY+O/KWQELFZmsNZwnegm8tgT9xCoybyfBeaJvgTVwfybqsgECFZm//Q/VwCgy1lrGroYHQEt4JSxzOgRa4GIAMsdy934PiO5npiKTuTNeXAgtrJH5UBPg54IwwJ3CVqO+swEegPea78MhYPfcroFlzTGhwtbevlFXLOrgqeKw4PeC5on+Ap5qjh37BcTPFjtXL/K+DxSAmwY4k7kiT3SGrT7+FWqNwmHJ9DPPE/0MIEtcQPnMO6EOPnYJAT5r8M4osFXYzqEpVXhXFCBT2HbllJTwM1CAtA1cws9AAVK3OqW066tibOGZd0BXKjLhdZdFuWHiC6Cx6zxLzZ4UiaG6kI2KTLEu+AUkwD6fvaMydpESLI9I33hle3u1hr62VssPZtjtSNussHdvJQoNeyeXITZt/1po2U5WDlb1AAAAAElFTkSuQmCC)![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAYAAAA7MK6iAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEgAACxIB0t1+/AAAABZ0RVh0Q3JlYXRpb24gVGltZQAwOS8yNy8xN+stbYgAAAAcdEVYdFNvZnR3YXJlAEFkb2JlIEZpcmV3b3JrcyBDUzbovLKMAAABu0lEQVRIicWX223CQBBFD26AlOAOMJoCQgl0AFQQSoEOoAN3EPLPKHYHKSFUQD686/jFPkysXMkSQsMc1jt7Z3Z2v9/xSVVTYG2eDJh3Qm5AAeRALiJfvpwzF1hVM2APbLz/rq0zcBCRIhqsqgfgLRLY1VFE9kFgVX0BLsDiSahVCaxE5Lv5ZTIxFJPrYnIPgyeAtuCDYLOnU0BruGEAZo9N9X5OCG1qKSKFXfFg5TVURiT2xe4BEmMOrnNaikgG7AKgOxPrgm9UNU2o3MilhapmInLywHcicjLblnpyrkPAUB0HF7wJvdC31EFwFgCeO+CxUIBsdr1e/V3iVzcqFypUdQswAgpALLgFh7qRREGh71yhSjufo6BjwHa1uapmZs9zwo5aD3yLhBaN1+ur9oe5EqrJYQx0jrvaXSoSqnHFJwtd0S+kMfA8BFw2js87w4XUhX/4wLY7nfD4NWEt0w59r46Ys4hsbVUfHIEEQqFauQtasxIAYwbHwOTP6GiNpzXsqWrBdFOIba9A30BWxDX9YKjJXasFNiPoX8MHx9t/G+gferX5wZLqOhKrM9VQ93CWc96drKa4tP0As8vvCUvsIrEAAAAASUVORK5CYII=)

sentinel

[oracle@raclinux1 dbs]$ more initRACDB1.ora

SPFILE=&#39;+MY_DG2/RACDB/spfileRACDB.ora&#39;  
  
---  
  
在此环境中，需要谨慎使用createspfile from
pfile的命令，很多朋友因为草率地执行这样的操作而导致数据库故障。在ASM或RAC环境中，通常的init&lt;sid&gt;.ora文件中只有如上示例的一行，如果此时执行createspfile
from pfile命令，则新创建的SPFILE文件将也只有这样一行信息，数据库将无法启动。

使用ASM存储参数文件

在ASM环境中，参数文件可以存储在ASM磁盘组上，而在Oracle RAC环境中，默认使用存储在ASM上的参数文件，在维护RAC环境的参数文件时要格外谨慎。

以下是一个测试过程，用于指导大家如何将参数文件转移到ASM存储并使之生效。

首先检查参数文件的位置，并通过SPFILE创建一个PFILE文件，进而在ASM磁盘上创建SPFILE文件。

SQL&gt; connect / as sysdba

SQL&gt; show parameter spfile

NAME &nbsp; &nbsp;TYPE &nbsp; &nbsp; &nbsp;VALUE

\------ ------- ------------------------------

spfile string &nbsp; /oracle/product/11.2.0/db_1/dbs/spfileracdb11.ora

SQL&gt; create pfile from spfile

File created.&nbsp;

SQL&gt; create spfile=&#39;+RACDB_DATA&#39; from
pfile=&#39;/oracle/product/11.2.0/db_1/dbs/initracdb11.ora&#39;;

File created.  
  
---  
  
  

检查ASM上的参数文件。

[grid@rac1 ~]$ asmcmd

ASMCMD&gt; ls RACDB_DATA/racdb1/spfile*&nbsp;

spfileracdb1.ora  
  
---  
  
同步RAC两个节点上的参数文件，更改其内容，设置SPFILE参数指向ASM中的参数文件。

[oracle@rac1 dbs]$ echo
&quot;SPFILE=&#39;+RACDB_DATA/racdb1/spfileracdb1.ora&#39;&quot; &gt;
&nbsp;/oracle/product/11.2.0/db_1/dbs/initracdb11.ora

[oracle@rac1 dbs]$ ssh rac2 &quot;echo
\&quot;SPFILE=&#39;+RACDB_DATA/racdb1/spfileracdb1.ora&#39;\&quot; &gt;
&nbsp;/oracle/product/11.2.0/db_1/dbs/initracdb12.ora&quot;  
  
---  
  
通过srvctl修改OCR中关于参数文件的配置。

[oracle@rac1 dbs]$ srvctl modify database -d racdb1
-p+RACDB_DATA/racdb1/spfileracdb1.ora  
---  
  
现在通过CRS启动数据库，将不再需要dbs目录下的参数文件，可以将其移除。

[oracle@rac1 dbs]$ mv /oracle/product/11.2.0/db_1/dbs/spfileracdb11.ora
/oracle/product/ 11.2.0/db_1/dbs/spfileracdb11.ora_bak

[oracle@rac1 dbs]$ ssh rac2 &quot;mv
/oracle/product/11.2.0/db_1/dbs/spfileracdb12.ora
/oracle/product/11.2.0/db_1/dbs/spfileracdb12.ora_bak&quot;  
  
---  
  
在下次重新启动数据库时，新的配置将会生效。

[oracle@rac1 dbs]$ srvctl stop database -d racdb1

[oracle@rac1 dbs]$ srvctl start database -d racdb1

[oracle@rac1 dbs]$ srvctl status database -d racdb1

Instance racdb11 is running on node rac1

Instance racdb12 is running on node rac2  
  
---  
  
检查数据库，新的参数文件已经被使用和生效。

SQL&gt; SHOW parameter spfile

NAME TYPE VALUE

\------ ----------- ------------------------------

spfile string +RACDB_DATA/racdb1/spfileracdb1.ora  
  
---  
  
谨慎修改RAC参数

在RAC环境中，即使按照正常的方式修改参数，也有可能因为遭遇Bug而导致事故，所以在进行重要的环境变更前，一定要进行测试，并详细检查与变更有关的文件，确保变更不会引起错误。

在Oracle 10.1的版本中，会遇到这样的问题，在RAC环境下修改UNDO_RETENTION参数，使用如下命令：

alter system set undo_retention=18000 sid=&#39;*&#39;;  
---  
  
这条命令直接导致了RAC的其他节点挂起，Oracle记录了一个相关Bug，Bug号为：4220405（这个Bug在Oracle
10gR2中修正），其Workaround就是分别修改不同实例。

alter system set undo_retention=18000 sid=&#39;RAC1&#39;;

alter system set undo_retention=18000 sid=&#39;RAC2&#39;;

alter system set undo_retention=18000 sid=&#39;RAC3&#39;;  
  
---  
  
这个案例告诉我们，Bug无处不在，数据库调整应当极其谨慎，最好在测试环境中测试过再应用到生产环境。

再次重申，在RAC环境中，每一个维护操作都要相当谨慎！

RAC环境下初始化参数的查询方法

下面介绍RAC环境下初始化参数的查询方法。

一个简单的例子：

!["微信图片_20180713103453.bmp"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180713123039_944.bmp%22)

不同的查询方法得到的结果。

!["2.bmp"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180713123048_345.bmp%22)

似乎除了看不到全局设置外，GV$PARAMETER参数和V$SPPARAMETER没有什么不同，其实不然，如果alter system
set的时候只修改了spfile或者memory参数，结果就会不同。

从上面的对比可以看出，通过GV$视图访问的结果和SPFILE中包含的信息完全不同。除了上面介绍的几种视图之外，CREATE
PFILE也是一个不错的选择。Oracle把SPFILE也纳入到RMAN的备份恢复策略当中，如果你配置了控制文件自动备份（AUTOBACKUP），那么Oracle会在数据库发生重大变化（如增减表空间）时自动进行控制文件及SPFILE文件的备份。

  

" name="docDetail" type="hidden">


---
### ATTACHMENTS
[7f025a17697ee15eb3197c61326b203b]: media/Oracle_RAC下参数文件的维护.html
[Oracle_RAC下参数文件的维护.html](media/Oracle_RAC下参数文件的维护.html)
>hash: 7f025a17697ee15eb3197c61326b203b  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle RAC下参数文件的维护_files\11947ec6e06f4dd6a765bcc48c4fc88d.png  

[d9b920f62c236d562c4a67c55215ce93]: media/Oracle_RAC下参数文件的维护-2.html
[Oracle_RAC下参数文件的维护-2.html](media/Oracle_RAC下参数文件的维护-2.html)
>hash: d9b920f62c236d562c4a67c55215ce93  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle RAC下参数文件的维护_files\20180713123048_345.bmp  

[f27eeeda4a5a8a94edaa9b714a74e6f6]: media/Oracle_RAC下参数文件的维护-3.html
[Oracle_RAC下参数文件的维护-3.html](media/Oracle_RAC下参数文件的维护-3.html)
>hash: f27eeeda4a5a8a94edaa9b714a74e6f6  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle RAC下参数文件的维护_files\20180713123039_944.bmp  

---
### NOTE ATTRIBUTES
>Created Date: 2018-09-25 03:29:08  
>Last Evernote Update Date: 2018-10-01 15:33:54  
>author: YangKwong  
>source: desktop.win  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle RAC下参数文件的维护.html  
>source-application: evernote.win32  