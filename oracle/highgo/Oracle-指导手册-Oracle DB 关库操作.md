# Oracle-指导手册-Oracle DB 关库操作

# 瀚高技术支持管理平台

根据客户的不同db环境，关库操作分为如下四种情况：

第一：单机 （非asm方式）

第二：单机 （asm方式）和 Rac –asm方式

第三：rac环境

第四：Rac –hacmp并发卷组方式

下面分别来介绍停库步骤：

 **一、关库操作-** **情况一 单机（非asm方式）**

1\. 停应用程序服务器（weblogic 、websphere、Jboss、IIS等）

2\. 停oracle监听器lsnrctl stop

3\. 切换归档日志，alter system switch logfile;

4\. 执行多次 alter system checkpoint

5\. 考虑杀掉所有“LOCAL=NO”服务器进程以及其他“LOCAL=YES”前台进程。可以通过下命令杀掉“LOCAL=NO”服务器进程：

ps -ef | grep "LOCAL=NO"|grep -v grep | awk '{print "kill -9 " $2}'|sh

6\. 执行shutdown immediate

7\. 有这么一种可能，即使杀掉了所有的应用进程，数据库还是无法关闭，我们可能看到：

Shutting down instance (immediate)

License high water mark = 6

Tue Jan 29 08:30:44 2013

ALTER DATABASE CLOSE NORMAL

Tue Jan 29 08:30:45 2013

SMON: disabling tx recovery

SMON: disabling cache recovery

这些信息显示smon已经结束了事务层面的回退操作，关闭了cache层面的恢复，也就是说smon开始进行临时段回收工作，若是系统中有大量需要回收的临时段，那么这个操作可能会持续很长时间。此时，使用shutdown
abort关库是安全的。

 **二、关库操作-** ** **情况二 单机 （asm方式）和 Rac –asm方式****

先决条件检查(仅仅针对aix)：

select path from v$asm_disk;

查询出asm磁盘组所使用的pv，

使用lspv 命令查看相关pv的pvid是否有，若是存在pvid，禁止停止asm实例，否则asm实例将启动不了。

其余操作同关库操作-情况一

 **三、关库操作-** ** **情况三 单机 （asm方式）和 Rac –asm方式****

rac环境下存在多个实例，不要使用群集命令srvctl 关闭数据库实例或者数据库，虽然方便但是容易出现故障和手误。

确认目前服务器上运行的数据库实例名称：

ps -ef|grep ora_smon

最右侧表示实例名，如果有多个实例就有多个ora_smon_xx1进程。

查看目前环境变量中的ORACLE_SID变量值

echo $ORACLE_SID或者 env|grep ORACLE

如果不是想进入的SID则先设置正确的SID

export ORACLE_SID=xx1

应该sqlplus 登录到想要关闭的实例，然后执行

sqlplus / as sysdba

show parameter name 注：确认进入的实例是否正确。

alter system checkpoint; 注：手动创建检查点，避免执行shutdown 时后台在创建检查点的过程卡主，而导致数据库无法正常关闭。

alter system archive log current; 注：切换所有实例的redo 并生成归档日志。

shutdown immediate

如果存在多个数据库，则要注意ORACLE_SID

 **四、关库操作-** ** **情况四 Rac –hacmp并发卷组方式****

注意点： 需要停止cluster 后再去停止hacmp软件

Measure

Measure



---
### TAGS
{Support20180830}

---
### NOTE ATTRIBUTES
>Created Date: 2018-08-30 02:19:15  
>Last Evernote Update Date: 2018-10-01 15:33:55  
>source: web.clip7  
>source-url: https://47.100.29.40/highgo_admin/#/index/docSearchDetail/9348d700885026  
>source-application: WebClipper 7  