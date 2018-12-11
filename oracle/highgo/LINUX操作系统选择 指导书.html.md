# LINUX操作系统选择 指导书.html

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

064974604

LINUX操作系统选择 指导书

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

用于Liunx操作系统的选择

详细信息

## 无论是数据库还是其他产品，在服务器上安装操作系统，系统类型和版本的选择要遵循如下原则:

### 1选择的安装的操作系统版本必须通过了硬件服务器厂家的认证。 如目前较新的服务器并不再支持安装rhel 5 操作系统，因此如果客户提出要安装rhel5
，则请 **客户和服务器工程师** 确认是否可行。

### 2需要考虑备份软件(如CommVault,HPDP等等)能在哪些操作系统版本上运行(认证通过),本项需要咨询备份软件工程师

### 3若是使用RHEL,请访问https://access.redhat.com/ecosystem网址

### 4 若是使用Oracle Linux,请访问http://linux.oracle.com/pls/apex/f?p=117:1网址

### 5操作系统和oracle数据库版本要通过oracle官方认证。

Metalink.oracle.com 认证部分

  

如果未通过则不建议客户安装，否则出现故障oracle官方将以此为由不提供技术支持。

  ![noteattachment2][6c610fc72666be03726991afb923ab41]

### 6   10G oracle数据库不支持安装在rhel6以及以上版本的操作系统中。

### 7   11.2.0.4和11.2.0.3  oracle 可以安装在 rhel 5 ，rhel6 ，rhel7
但就工程经验，强烈不建议安装在rhel 7的操作系统中。(11.2.0.2和11.2.0.1只能安装在rhel5.x中。)

8   12.2.0.1不支持安装在rhel 5中，我们建议客户最低操作系统版本要求为rhel6.9或rhel 7.3及以上。

### 9对于rhel 6 ，目前最新小版本是rhel 6.9；对于rhel 7 ，目前最新小版本是rhel 7.5（截止2018年4月12日）；



### 10为避免客户后期出于对操作系统安全考虑或应对检查等原因要求系统升级，建议安装rhel5是选择 rhel 5最后一个版本rhel 5.11

### 11要求安装操作系统是 rhel 5 **选择rhel 5.11** ；rhel 6 选择 **rhel6.9** ；rhel建议使用
**rhel7.3 及以上版本**（7.2会出现安装图形无法正常显示的情况，还存在RemoveIPC的bug）。.

使用6.7原因是硬件方面的相关认证：

https://access.redhat.com/ecosystem

[http://linux.oracle.com/pls/apex/f?p=117:1](http://linux.oracle.com/pls/apex/f?p=117:1)

https://access.redhat.com/support/policy/intel

之所以不再采用6.6操作系统是因为如下BUG

RHEL 6.6: IPC Send timeout/node eviction etc with high packet reassembles
failure (文档 ID 2008933.1)

RAC Cluster is Experiencing Node Evictions after Kernel Upgrade to OL6.6 (文档
ID 2011957.1)

6.5之前存在bug

[https://access.redhat.com/solutions/433883](https://access.redhat.com/solutions/433883)

### 12 CPU型号与操作系统的选型关系

参考redhat文章

<https://access.redhat.com/articles/3135591>



数据库服务器若是老款的intel xeon cpu,建议使用如下的操作系统版本:

Red Hat Enterprise Linux 7 Update 4

Red Hat Enterprise Linux 6 Update 9



若是 数据库服务器是最新的intel skylake scalable processor,若是2路服务器或者4路服务器,建议使用如下的操作系统版本:

Red Hat Enterprise Linux 7 Update 4

Red Hat Enterprise Linux 6 Update 9



若是 数据库服务器是最新的intel skylake scalable processor,若是8路服务器,建议使用如下的操作系统版本:

Red Hat Enterprise Linux 7 Update 4

### 13使用浪潮天梭K1主机操作系统的注意事项

浪潮天梭k1主机，其实分好几个类别：

K1-950 intel 安腾cpu

K1-930 intel 安腾cpu

K1-910 intel 安腾cpu

K1-800 intel 志强cpu



第一：前三种机型，由于使用的是安腾cpu，因此，若想运行oracle database，请务必同时满足如下的两个条件：

     A. 只能安装Oracle Database 小于等于10.2.0.5的版本。

B. 只能安装Linux Itanium版本的操作系统（非K-UX），原因，如下所示，认证列表中没有K-UX。

  

![noteattachment3][3c7bbef1f5ce73968c0db04a43322572]

第二：第四种机型，由于使用的是志强cpu，其实就是一般意义上的pcserver，在该种机型之上，可以安装RHEL
x86-64bit，也可以安装Oracle Database 10G , 11G, 12c



### 14维保客户新装操作系统要求进行如下修改：

 **1** **修改操作系统日志保留策略配置文件**

vi /etc/logrotate.conf

将其中# keep 4 weeks worth of backlogs

rotate 4

改为 rotate 50 ,使得操作系统日志保留50周，每周1个日志文件。

 _logrotate_ _ _ _-f_ _ _ _/etc/logrotate.conf_ _ _ _设置立即生效_

 **2** **记录历史命令执行时间和发起命令的远程主机IP地址**

 **LINUX** **系统**

1、编辑/etc/profile文件，尾部加入如下行：

 _#history_

 _HISTFILESIZE=2000_

 _LOGIP=`who -u am i 2 >/dev/null| awk '{print $NF}'|sed -e 's/[()]//g'`_

 _export HISTTIMEFORMAT= "[%F %T][`whoami`][${LOGIP}] "_

 _LOG_DIR=/var/log/history_

 _if [ -z $LOGIP ]_

 _then_

 _LOGIP=`hostname`_

 _fi_

 _if [ ! -d $LOG_DIR ]_

 _then_

 _mkdir -p $LOG_DIR_

 _chmod 777 $LOG_DIR_

 _fi_

 _if [ ! -d $LOG_DIR/${LOGNAME} ]_

 _then_

 _mkdir -p $LOG_DIR/${LOGNAME}_

 _chmod 777 $LOG_DIR/${LOGNAME}_

 _fi_

 _export HISTSIZE=40960_

 _LOGTM=`date + "%Y%m%d_%H:%M:%S"`_

 _export HISTFILE= "$LOG_DIR/${LOGNAME}/${LOGIP}-$LOGTM"_

 _#End for history_

如果要查看历史命令，可以查看/var/log/history
目录中相应系统用户下，每次ssh或者本地shell会话退出时都会将会话进行的操作保留并生成一个日志文件。其中数据是unix时间戳可以通过linux
的date命令转换成可阅读时间格式 ，如date -d "@1279592730" 或者在线转换

http://tool.chinaz.com/Tools/unixtime.aspx?qq-pf-to=pcqq.c2c



另外，linux服务器上建议关闭的服务有

 _service cpuspeed stop_

 _chkconfig cpuspeed off_

 _service_ _   _ _NetworkManager_ _ _ _stop_

 _chkconfig_ _ _ _NetworkManager_ _ _ _off_

 _service sendmail stop_

 _chkconfig sendmail off_



 **AIX** **系统**

除了同样需要将以上内容放到/etc/profile中外，还需要用ROOT用户VI，添加EXTENDED_HISTORY=ON至/etc/environment
。



注：按照上述要求修改/etc/profile后linux的history和aix的 fc -t只能显示当前会话的历史命令。

  

相关文档

内部备注

附件

验证码：

  换一张

输入验证码：

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAYAAAA7MK6iAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEgAACxIB0t1+/AAAABZ0RVh0Q3JlYXRpb24gVGltZQAwOS8yNy8xN+stbYgAAAAcdEVYdFNvZnR3YXJlAEFkb2JlIEZpcmV3b3JrcyBDUzbovLKMAAABm0lEQVRIicXXwXGCQBTG8b+7uZsSTAXRCiQVhA6SXLgmJZgO5BguSQnYgR0EK0hKiAUs5rBvGVlBBEG/GWccxf0JC2/fjna7HU3JEz0BQnlNgbF3yBbIgBRIVWR+m8YcHYPzRE+BBfDY+O/KWQELFZmsNZwnegm8tgT9xCoybyfBeaJvgTVwfybqsgECFZm//Q/VwCgy1lrGroYHQEt4JSxzOgRa4GIAMsdy934PiO5npiKTuTNeXAgtrJH5UBPg54IwwJ3CVqO+swEegPea78MhYPfcroFlzTGhwtbevlFXLOrgqeKw4PeC5on+Ap5qjh37BcTPFjtXL/K+DxSAmwY4k7kiT3SGrT7+FWqNwmHJ9DPPE/0MIEtcQPnMO6EOPnYJAT5r8M4osFXYzqEpVXhXFCBT2HbllJTwM1CAtA1cws9AAVK3OqW066tibOGZd0BXKjLhdZdFuWHiC6Cx6zxLzZ4UiaG6kI2KTLEu+AUkwD6fvaMydpESLI9I33hle3u1hr62VssPZtjtSNussHdvJQoNeyeXITZt/1po2U5WDlb1AAAAAElFTkSuQmCC)![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAYAAAA7MK6iAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEgAACxIB0t1+/AAAABZ0RVh0Q3JlYXRpb24gVGltZQAwOS8yNy8xN+stbYgAAAAcdEVYdFNvZnR3YXJlAEFkb2JlIEZpcmV3b3JrcyBDUzbovLKMAAABu0lEQVRIicWX223CQBBFD26AlOAOMJoCQgl0AFQQSoEOoAN3EPLPKHYHKSFUQD686/jFPkysXMkSQsMc1jt7Z3Z2v9/xSVVTYG2eDJh3Qm5AAeRALiJfvpwzF1hVM2APbLz/rq0zcBCRIhqsqgfgLRLY1VFE9kFgVX0BLsDiSahVCaxE5Lv5ZTIxFJPrYnIPgyeAtuCDYLOnU0BruGEAZo9N9X5OCG1qKSKFXfFg5TVURiT2xe4BEmMOrnNaikgG7AKgOxPrgm9UNU2o3MilhapmInLywHcicjLblnpyrkPAUB0HF7wJvdC31EFwFgCeO+CxUIBsdr1e/V3iVzcqFypUdQswAgpALLgFh7qRREGh71yhSjufo6BjwHa1uapmZs9zwo5aD3yLhBaN1+ur9oe5EqrJYQx0jrvaXSoSqnHFJwtd0S+kMfA8BFw2js87w4XUhX/4wLY7nfD4NWEt0w59r46Ys4hsbVUfHIEEQqFauQtasxIAYwbHwOTP6GiNpzXsqWrBdFOIba9A30BWxDX9YKjJXasFNiPoX8MHx9t/G+gferX5wZLqOhKrM9VQ93CWc96drKa4tP0As8vvCUvsIrEAAAAASUVORK5CYII=)

sentinel

请访问http://linux.oracle.com/pls/apex/f?p=117:1网址

### 5操作系统和oracle数据库版本要通过oracle官方认证。

Metalink.oracle.com 认证部分

  

如果未通过则不建议客户安装，否则出现故障oracle官方将以此为由不提供技术支持。

&nbsp;!["1.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180413100251_436.png%22)

### 6&nbsp;&nbsp; 10G oracle数据库不支持安装在rhel6以及以上版本的操作系统中。

### 7&nbsp;&nbsp; 11.2.0.4和11.2.0.3&nbsp; oracle 可以安装在 rhel 5 ，rhel6
，rhel7&nbsp; 但就工程经验，强烈不建议安装在rhel 7的操作系统中。(11.2.0.2和11.2.0.1只能安装在rhel5.x中。)

8&nbsp;&nbsp; 12.2.0.1不支持安装在rhel 5中，我们建议客户最低操作系统版本要求为rhel6.9或rhel 7.3及以上。

### 9对于rhel 6 ，目前最新小版本是rhel 6.9；对于rhel 7 ，目前最新小版本是rhel 7.5（截止2018年4月12日）；

&nbsp;

### 10为避免客户后期出于对操作系统安全考虑或应对检查等原因要求系统升级，建议安装rhel5是选择 rhel 5最后一个版本rhel 5.11

### 11要求安装操作系统是 rhel 5 **选择rhel 5.11** ；rhel 6 选择 **rhel6.9** ；rhel建议使用
**rhel7.3 及以上版本**（7.2会出现安装图形无法正常显示的情况，还存在RemoveIPC的bug）。.

使用6.7原因是硬件方面的相关认证：

https://access.redhat.com/ecosystem

[http://linux.oracle.com/pls/apex/f?p=117:1](https://47.100.29.40/highgo_admin/%22http://linux.oracle.com/pls/apex/f?p=117:1")

https://access.redhat.com/support/policy/intel

之所以不再采用6.6操作系统是因为如下BUG

RHEL 6.6: IPC Send timeout/node eviction etc with high packet reassembles
failure (文档 ID 2008933.1)

RAC Cluster is Experiencing Node Evictions after Kernel Upgrade to OL6.6 (文档
ID 2011957.1)

6.5之前存在bug

[https://access.redhat.com/solutions/433883](https://47.100.29.40/highgo_admin/%22https://access.redhat.com/solutions/433883%22)

### 12 CPU型号与操作系统的选型关系

参考redhat文章

[https://access.redhat.com/articles/3135591](https://47.100.29.40/highgo_admin/%22https://access.redhat.com/articles/3135591%22)

&nbsp;

数据库服务器若是老款的intel xeon cpu,建议使用如下的操作系统版本:

Red Hat Enterprise Linux 7 Update 4

Red Hat Enterprise Linux 6 Update 9

&nbsp;

若是 数据库服务器是最新的intel skylake scalable processor,若是2路服务器或者4路服务器,建议使用如下的操作系统版本:

Red Hat Enterprise Linux 7 Update 4

Red Hat Enterprise Linux 6 Update 9

&nbsp;

若是 数据库服务器是最新的intel skylake scalable processor,若是8路服务器,建议使用如下的操作系统版本:

Red Hat Enterprise Linux 7 Update 4

### 13使用浪潮天梭K1主机操作系统的注意事项

浪潮天梭k1主机，其实分好几个类别：

K1-950 intel 安腾cpu

K1-930 intel 安腾cpu

K1-910 intel 安腾cpu

K1-800 intel 志强cpu

&nbsp;

第一：前三种机型，由于使用的是安腾cpu，因此，若想运行oracle database，请务必同时满足如下的两个条件：

&nbsp;&nbsp;&nbsp;&nbsp; A. 只能安装Oracle Database 小于等于10.2.0.5的版本。

B. 只能安装Linux Itanium版本的操作系统（非K-UX），原因，如下所示，认证列表中没有K-UX。

  

!["2.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180413100317_385.png%22)

第二：第四种机型，由于使用的是志强cpu，其实就是一般意义上的pcserver，在该种机型之上，可以安装RHEL&nbsp;
x86-64bit，也可以安装Oracle Database 10G , 11G, 12c

&nbsp;

### 14维保客户新装操作系统要求进行如下修改：

 **1** **修改操作系统日志保留策略配置文件**

vi /etc/logrotate.conf

将其中# keep 4 weeks worth of backlogs

rotate 4

改为 rotate 50 ,使得操作系统日志保留50周，每周1个日志文件。

 _logrotate_ _& nbsp;_ _-f_ _& nbsp;_ _/etc/logrotate.conf_ _& nbsp;_ _设置立即生效_

 **2** **记录历史命令执行时间和发起命令的远程主机IP地址**

 **LINUX** **系统**

1、编辑/etc/profile文件，尾部加入如下行：

 _#history_

 _HISTFILESIZE=2000_

 _LOGIP=`who -u am i 2 &gt;/dev/null| awk &#39;{print $NF}&#39;|sed -e
&#39;s/[()]//g&#39;`_

 _export HISTTIMEFORMAT= &quot;[%F %T][`whoami`][${LOGIP}] &quot;_

 _LOG_DIR=/var/log/history_

 _if [ -z $LOGIP ]_

 _then_

 _LOGIP=`hostname`_

 _fi_

 _if [ ! -d $LOG_DIR ]_

 _then_

 _mkdir -p $LOG_DIR_

 _chmod 777 $LOG_DIR_

 _fi_

 _if [ ! -d $LOG_DIR/${LOGNAME} ]_

 _then_

 _mkdir -p $LOG_DIR/${LOGNAME}_

 _chmod 777 $LOG_DIR/${LOGNAME}_

 _fi_

 _export HISTSIZE=40960_

 _LOGTM=`date + &quot;%Y%m%d_%H:%M:%S&quot;`_

 _export HISTFILE= &quot;$LOG_DIR/${LOGNAME}/${LOGIP}-$LOGTM&quot;_

 _#End for history_

如果要查看历史命令，可以查看/var/log/history
目录中相应系统用户下，每次ssh或者本地shell会话退出时都会将会话进行的操作保留并生成一个日志文件。其中数据是unix时间戳可以通过linux
的date命令转换成可阅读时间格式 ，如date -d &quot;@1279592730&quot; 或者在线转换

http://tool.chinaz.com/Tools/unixtime.aspx?qq-pf-to=pcqq.c2c

&nbsp;

另外，linux服务器上建议关闭的服务有

 _service cpuspeed stop_

 _chkconfig cpuspeed off_

 _service_ _& nbsp;&nbsp;_ _NetworkManager_ _& nbsp;_ _stop_

 _chkconfig_ _& nbsp;_ _NetworkManager_ _& nbsp;_ _off_

 _service sendmail stop_

 _chkconfig sendmail off_

&nbsp;

 **AIX** **系统**

除了同样需要将以上内容放到/etc/profile中外，还需要用ROOT用户VI，添加EXTENDED_HISTORY=ON至/etc/environment
。

&nbsp;

注：按照上述要求修改/etc/profile后linux的history和aix的 fc -t只能显示当前会话的历史命令。

  

" name="docDetail" type="hidden">


---
### ATTACHMENTS
[3c7bbef1f5ce73968c0db04a43322572]: media/LINUX操作系统选择_指导书.html
[LINUX操作系统选择_指导书.html](media/LINUX操作系统选择_指导书.html)
>hash: 3c7bbef1f5ce73968c0db04a43322572  
>source-url: file://C:\Users\galaxy\Desktop\highgo\LINUX操作系统选择 指导书_files\20180413100317_385.png  

[6c610fc72666be03726991afb923ab41]: media/LINUX操作系统选择_指导书-2.html
[LINUX操作系统选择_指导书-2.html](media/LINUX操作系统选择_指导书-2.html)
>hash: 6c610fc72666be03726991afb923ab41  
>source-url: file://C:\Users\galaxy\Desktop\highgo\LINUX操作系统选择 指导书_files\20180413100251_436.png  

[7f025a17697ee15eb3197c61326b203b]: media/LINUX操作系统选择_指导书-3.html
[LINUX操作系统选择_指导书-3.html](media/LINUX操作系统选择_指导书-3.html)
>hash: 7f025a17697ee15eb3197c61326b203b  
>source-url: file://C:\Users\galaxy\Desktop\highgo\LINUX操作系统选择 指导书_files\11947ec6e06f4dd6a765bcc48c4fc88d.png  

---
### NOTE ATTRIBUTES
>Created Date: 2018-09-25 03:29:03  
>Last Evernote Update Date: 2018-10-01 15:33:55  
>author: YangKwong  
>source: desktop.win  
>source-url: file://C:\Users\galaxy\Desktop\highgo\LINUX操作系统选择 指导书.html  
>source-application: evernote.win32  