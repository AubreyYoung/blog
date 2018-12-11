# Oracle-指导手册-DB_数据迁移.html

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

061241104

Oracle-指导手册-DB_数据迁移

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

此文档用于指导在Oracle DB数据迁移时的操作。

详细信息

  

  

 **1 数据迁移概述**

  

##  根据客户的不同硬件环境，数据迁移分为如下几个情况：  
  
第一：迁移前和迁移后是不同的物理主机，不同的存储  
  
第二：迁移前和迁移后是同一台物理主机（os可能不同），相同的存储  
  
另外，根据客户业务系统的数据量大小、停机时间要求， 结合客户不同的硬件环境，数据迁移需要用不同的工具：

 **1.exp** **和 expdp** **：适合跨 os** **，跨 db** **版本，对停机时间要求不严格的数据库迁移**

 ** ** exp user/password file=xxx.dmp log=xxxlog.log buffer=99999999
COMPRESS=N

 ** ** expdp user/password dumpfile=xxx_%U.dmp logfile= xxxlog.log
directory=yyyy parallel=4

 parallel的具体数值可以根据cpu_count的值设置。

 **2.Dataguard** **：必须是同种 os** **，必须是同一个 db** **版本之间的数据库迁移**

 **3.TTS** **：可以是不同种 os** **，可以是不同 db** **版本。**

 **4.GoldenGate** **：适合跨 os** **，跨 db** **版本，对停机时间有严格要求的数据库迁移。本文不论述
GoldenGate** **数据迁移的方法**



下面以这两种情况结合不同的迁移工具分别来介绍迁移步骤

  

  

 **2 数据迁移-情况一(exp,不同的主机)**

  

windows下的oracle （以下简称源系统） 到aix 下的oracle（以下简称目的系统） 的数据迁移

oracle  db的版本一样：

使用传统的exp和imp工具

1. 停止前台业务

2. 关闭源系统监听器:lsnrctl stop

3. 重启源系统上的oracle 数据库

4\. cmd下set nls_lang=AMERICAN_AMERICA.ZHS16GBK

 此处的ZHS16GBK为数据库字符集，请查询v$nls_parameters视图来确定db所用的字符集。

5. 执行exp或者expdp数据导出源系统中的业务数据:一般是分用户导出，或者是全库导出(在客户对业务系统不熟悉的情况下)。

执行exp命令时的必带参数：

exp user/password file=xxx log=xxxlog.log buffer=99999999 COMPRESS=N



对compress=n的解释如下：

如果一个表，有三个段[区]（产生的原因是因为数据量的增加，多次扩展数据段）每个3M大小。  
好，如果你用了COMPRESS=Y，表示导出来后再IMP进数据库时，你看到的只有一个段（9M），也就是把3个段合并成一个段了。  
如果是COMPRESS=N，就是还是3个段，每个段3M。

 建议在exp 命令中使用COMPRESS=N参数。

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

 that the goal of compress=y (compress many extents into one ) is virtually
accomplished.

以上来源于：

Import can result on more than a single extent even with COMPRESS=Y (文档 ID
135694.1)

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



使用md5sum命令校验dmp文件 的md5值。

不同os的md5命令是不同的，请参见：

 **How To Verify The Integrity Of A Patch/Software Download? [Video] [ID
549617.1]**

6. 使用 DBArtisan 8.6.2 将 源系统 数据库中的业务表所在的表空间 的   create tablespace的语句 生成出来，做符合目的系统的修改后，在目的系统中执行此语句

7. 使用 DBArtisan 8.6.2 将 源系统 数据库中业务用户（拥有表的用户）的  create user的 语句 生成出来，做符合目的系统的修改后，并在目的系统执行此语句\---此步骤仅仅针对export（非数据泵）

8. 将dmp文件上传到目的系统的os上，注意一定要使用ftp时的bin模式传输。 **使用** **md5sum** **命令校验** **dmp** **文件是完整的** **(** **与第** **5** **步中得到的** **md5** **值比较，必须一致才可以。** **)**

9. 在目的系统的 操作系统命令行下执行：

export  NLS_LANG=AMERICAN_AMERICA.ZHS16GBK

10. 在目的系统上 执行imp 或者impdp 数据导入：分用户导入

11. 在目的系统上 ，收集数据库的统计信息

12. 在目的系统上打开监听器lsnrctl start

13. 将前台业务的数据库连接串改写为指向目的系统，并开启前台业务，测试业务是否正常。



注意点:

对lob（blob,clob）类型的数据，请务必保证源系统上的所有业务表空间都在目的系统上都存在，否则，在imp导入时，会丢失lob类型的数据。

对于这种类型的数据来说，恢复时只认和原来表空间同名的表空间，若不存在同名的表空间，这部分数据将会因为“无处恢复”而丢失。

所以，想使用exp和imp 在数据迁移的同时完成表所在表空间的更换，不靠谱，要同时完成这2个需求（数据迁移和
表所在表空间的更换）请使用expdp和impdp工具

  

 **3 数据迁移-情况二(exp,同一个主机)**

  

其实此情况对应的迁移步骤与上一个迁移步骤很类似，此处简化为如下场景：

windows rac ，已经有业务数据，客户要求换成linux rac（物理主机还是那2个物理主机，存储还是那个存储），迁移方法是exp or expdp
，重装linux rac，然后导入数据。

此处的重点在于在windows
rac上导出数据(不建议使用windows的网络驱动器，建议使用windows的本地硬盘，即使在windows上接一个1T的移动硬盘，也比网络驱动器要靠谱)，对dmp文件要进行md5sum校验，得到md5值，然后，将这个dmp文件从windows上转移出来，比如转移到其他的主机上，再次进行md5sum校验，确认这2次的md5值相同。只有这2次的md5值相同，才说明dmp文件是完整的。
**只有** **dmp** **文件是完整的，才能将** **windows** **物理主机重装为** **linux** **操作系统**
，其余的步骤就和上一个迁移步骤一样了。

  

  

相关文档

内部备注

此文档用于指导在Oracle DB数据迁移时的操作。

附件

验证码：

  换一张

输入验证码：

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAYAAAA7MK6iAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEgAACxIB0t1+/AAAABZ0RVh0Q3JlYXRpb24gVGltZQAwOS8yNy8xN+stbYgAAAAcdEVYdFNvZnR3YXJlAEFkb2JlIEZpcmV3b3JrcyBDUzbovLKMAAABm0lEQVRIicXXwXGCQBTG8b+7uZsSTAXRCiQVhA6SXLgmJZgO5BguSQnYgR0EK0hKiAUs5rBvGVlBBEG/GWccxf0JC2/fjna7HU3JEz0BQnlNgbF3yBbIgBRIVWR+m8YcHYPzRE+BBfDY+O/KWQELFZmsNZwnegm8tgT9xCoybyfBeaJvgTVwfybqsgECFZm//Q/VwCgy1lrGroYHQEt4JSxzOgRa4GIAMsdy934PiO5npiKTuTNeXAgtrJH5UBPg54IwwJ3CVqO+swEegPea78MhYPfcroFlzTGhwtbevlFXLOrgqeKw4PeC5on+Ap5qjh37BcTPFjtXL/K+DxSAmwY4k7kiT3SGrT7+FWqNwmHJ9DPPE/0MIEtcQPnMO6EOPnYJAT5r8M4osFXYzqEpVXhXFCBT2HbllJTwM1CAtA1cws9AAVK3OqW066tibOGZd0BXKjLhdZdFuWHiC6Cx6zxLzZ4UiaG6kI2KTLEu+AUkwD6fvaMydpESLI9I33hle3u1hr62VssPZtjtSNussHdvJQoNeyeXITZt/1po2U5WDlb1AAAAAElFTkSuQmCC)![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAYAAAA7MK6iAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEgAACxIB0t1+/AAAABZ0RVh0Q3JlYXRpb24gVGltZQAwOS8yNy8xN+stbYgAAAAcdEVYdFNvZnR3YXJlAEFkb2JlIEZpcmV3b3JrcyBDUzbovLKMAAABu0lEQVRIicWX223CQBBFD26AlOAOMJoCQgl0AFQQSoEOoAN3EPLPKHYHKSFUQD686/jFPkysXMkSQsMc1jt7Z3Z2v9/xSVVTYG2eDJh3Qm5AAeRALiJfvpwzF1hVM2APbLz/rq0zcBCRIhqsqgfgLRLY1VFE9kFgVX0BLsDiSahVCaxE5Lv5ZTIxFJPrYnIPgyeAtuCDYLOnU0BruGEAZo9N9X5OCG1qKSKFXfFg5TVURiT2xe4BEmMOrnNaikgG7AKgOxPrgm9UNU2o3MilhapmInLywHcicjLblnpyrkPAUB0HF7wJvdC31EFwFgCeO+CxUIBsdr1e/V3iVzcqFypUdQswAgpALLgFh7qRREGh71yhSjufo6BjwHa1uapmZs9zwo5aD3yLhBaN1+ur9oe5EqrJYQx0jrvaXSoSqnHFJwtd0S+kMfA8BFw2js87w4XUhX/4wLY7nfD4NWEt0w59r46Ys4hsbVUfHIEEQqFauQtasxIAYwbHwOTP6GiNpzXsqWrBdFOIba9A30BWxDX9YKjJXasFNiPoX8MHx9t/G+gferX5wZLqOhKrM9VQ93CWc96drKa4tP0As8vvCUvsIrEAAAAASUVORK5CYII=)

sentinel

 **& nbsp;**exp user/password file=xxx.dmp log=xxxlog.log buffer=99999999
COMPRESS=N

 **& nbsp;**expdp user/password dumpfile=xxx_%U.dmp logfile= xxxlog.log
directory=yyyy parallel=4

&nbsp;parallel的具体数值可以根据cpu_count的值设置。

 **2.Dataguard** **：必须是同种 os** **，必须是同一个 db** **版本之间的数据库迁移**

 **3.TTS** **：可以是不同种 os** **，可以是不同 db** **版本。**

 **4.GoldenGate** **：适合跨 os** **，跨 db** **版本，对停机时间有严格要求的数据库迁移。本文不论述
GoldenGate** **数据迁移的方法**

&nbsp;

下面以这两种情况结合不同的迁移工具分别来介绍迁移步骤

  

  

 **2 数据迁移-情况一(exp,不同的主机)**

  

windows下的oracle （以下简称源系统） 到aix 下的oracle（以下简称目的系统） 的数据迁移

oracle&nbsp; db的版本一样：

使用传统的exp和imp工具

1. 停止前台业务

2. 关闭源系统监听器:lsnrctl stop

3. 重启源系统上的oracle 数据库

4\. cmd下set nls_lang=AMERICAN_AMERICA.ZHS16GBK

&nbsp;此处的ZHS16GBK为数据库字符集，请查询v$nls_parameters视图来确定db所用的字符集。

5. 执行exp或者expdp数据导出源系统中的业务数据:一般是分用户导出，或者是全库导出(在客户对业务系统不熟悉的情况下)。

执行exp命令时的必带参数：

exp user/password file=xxx log=xxxlog.log buffer=99999999 COMPRESS=N

&nbsp;

对compress=n的解释如下：

如果一个表，有三个段[区]（产生的原因是因为数据量的增加，多次扩展数据段）每个3M大小。  
好，如果你用了COMPRESS=Y，表示导出来后再IMP进数据库时，你看到的只有一个段（9M），也就是把3个段合并成一个段了。  
如果是COMPRESS=N，就是还是3个段，每个段3M。

&nbsp;建议在exp 命令中使用COMPRESS=N参数。

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

&nbsp;that the goal of compress=y (compress many extents into one ) is
virtually accomplished.

以上来源于：&nbsp;

Import can result on more than a single extent even with COMPRESS=Y (文档 ID
135694.1)

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

&nbsp;

使用md5sum命令校验dmp文件 的md5值。

不同os的md5命令是不同的，请参见：

 **How To Verify The Integrity Of A Patch/Software Download? [Video] [ID
549617.1]**

6. 使用 DBArtisan 8.6.2 将 源系统 数据库中的业务表所在的表空间 的&nbsp;&nbsp; create tablespace的语句 生成出来，做符合目的系统的修改后，在目的系统中执行此语句

7. 使用 DBArtisan 8.6.2 将 源系统 数据库中业务用户（拥有表的用户）的&nbsp; create user的 语句 生成出来，做符合目的系统的修改后，并在目的系统执行此语句\---此步骤仅仅针对export（非数据泵）

8. 将dmp文件上传到目的系统的os上，注意一定要使用ftp时的bin模式传输。 **使用** **md5sum** **命令校验** **dmp** **文件是完整的** **(** **与第** **5** **步中得到的** **md5** **值比较，必须一致才可以。** **)**

9. 在目的系统的 操作系统命令行下执行：

export&nbsp; NLS_LANG=AMERICAN_AMERICA.ZHS16GBK

10. 在目的系统上 执行imp 或者impdp 数据导入：分用户导入

11. 在目的系统上 ，收集数据库的统计信息

12. 在目的系统上打开监听器lsnrctl start

13. 将前台业务的数据库连接串改写为指向目的系统，并开启前台业务，测试业务是否正常。

&nbsp;

注意点:

对lob（blob,clob）类型的数据，请务必保证源系统上的所有业务表空间都在目的系统上都存在，否则，在imp导入时，会丢失lob类型的数据。

对于这种类型的数据来说，恢复时只认和原来表空间同名的表空间，若不存在同名的表空间，这部分数据将会因为“无处恢复”而丢失。

所以，想使用exp和imp 在数据迁移的同时完成表所在表空间的更换，不靠谱，要同时完成这2个需求（数据迁移和
表所在表空间的更换）请使用expdp和impdp工具

  

 **3 数据迁移-情况二(exp,同一个主机)**

  

其实此情况对应的迁移步骤与上一个迁移步骤很类似，此处简化为如下场景：

windows rac ，已经有业务数据，客户要求换成linux rac（物理主机还是那2个物理主机，存储还是那个存储），迁移方法是exp or expdp
，重装linux rac，然后导入数据。

此处的重点在于在windows
rac上导出数据(不建议使用windows的网络驱动器，建议使用windows的本地硬盘，即使在windows上接一个1T的移动硬盘，也比网络驱动器要靠谱)，对dmp文件要进行md5sum校验，得到md5值，然后，将这个dmp文件从windows上转移出来，比如转移到其他的主机上，再次进行md5sum校验，确认这2次的md5值相同。只有这2次的md5值相同，才说明dmp文件是完整的。
**只有** **dmp** **文件是完整的，才能将** **windows** **物理主机重装为** **linux** **操作系统**
，其余的步骤就和上一个迁移步骤一样了。

  

  

" name="docDetail" type="hidden">


---
### ATTACHMENTS
[7f025a17697ee15eb3197c61326b203b]: media/Oracle-指导手册-DB_数据迁移.html
[Oracle-指导手册-DB_数据迁移.html](media/Oracle-指导手册-DB_数据迁移.html)
>hash: 7f025a17697ee15eb3197c61326b203b  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-指导手册-DB_数据迁移_files\11947ec6e06f4dd6a765bcc48c4fc88d.png  

---
### NOTE ATTRIBUTES
>Created Date: 2018-09-25 03:29:32  
>Last Evernote Update Date: 2018-10-01 15:33:47  
>author: YangKwong  
>source: desktop.win  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-指导手册-DB_数据迁移.html  
>source-application: evernote.win32  