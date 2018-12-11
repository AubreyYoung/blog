# How to Identify ORA-00060 Deadlock Types Using Deadlock Graphs in Trace (文档
ID 1507093.1)

  

 How to Identify ORA-00060 Deadlock Types Using Deadlock Graphs in Trace (文档
ID 1507093.1)

怎样使用trace中死锁图识别ora-00060死锁类型？

|

|

  

 **In this Document**

 **在文档中**

|

  
  
  
---  
  
  
  
  
---  
  
[
Goal](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=156108188417175&id=1507093.1&_adf.ctrl-
state=1adjq74nvy_72#GOAL)

目标

  [Deadlock Graph
Interpretation](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=156108188417175&id=1507093.1&_adf.ctrl-
state=1adjq74nvy_72#aref_section11)

  死锁图详解

  [Ask Questions, Get Help, And Share Your Experiences With This
Article](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=156108188417175&id=1507093.1&_adf.ctrl-
state=1adjq74nvy_72#aref_section12)

  提问题，获取帮助，和分享你与这篇文章有关的经验

[Solution](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=156108188417175&id=1507093.1&_adf.ctrl-
state=1adjq74nvy_72#FIX)

解决方案

  [iscuss ORA-00060
Deadlocks](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=156108188417175&id=1507093.1&_adf.ctrl-
state=1adjq74nvy_72#aref_section21)

  讨论ora-00060死锁

  

[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=156108188417175&id=1507093.1&_adf.ctrl-
state=1adjq74nvy_72#REF)

参考文档

  
  
  
---  
  
* * *

## Applies to:

适用于

Oracle Database - Enterprise Edition - Version 9.0.1.0 and later

Oracle数据库-企业版-V9.0.1.0及以后版本

Information in this document applies to any platform.

本文档的信息适用于任何平台

## Goal

目标

  

When Oracle detects a deadlock, the current SQL in the session detecting the
deadlock is cancelled and 'statement-level rollback' is performed so as to
free up resources and not block all activity. The session that detected the
deadlock is still 'alive' and the rest of the transaction is still active. If
you repeat the last (cancelled) operation in the session, then you will get
the deadlock again.

当Oracle发现一个死锁时，正检测到死锁会话的当前的SQL将被取消，并且‘语句-级别
回滚’将被执行以便释放资源和不阻止所有活动。检测到死锁的会话仍是‘活的’并且事务其余的工作仍是活动的。如果你重复会话中最后的（取消的）操作，那么你将再一次得到死锁。

  

When such a deadlock is detected a trace file is produced containing a
"Deadlock Graph" (along with other useful information). By examination of
numerous Service Requests, we have seen that the most common types of deadlock
can be identified by a "signature" deadlock graph that can be used to identify
the "type" of deadlock being encountered. This article presents examples of
each type so that investigation and resolution can continue along the right
track.

当检测到死锁，一个包含一个‘死锁图’（以及其他有用的信息）的trace文件将会产生。经过检查大量的服务请求，我们看到大部分最常见类型的死锁能够通过一个用来识别死锁类型的死锁图‘信号’识别。本文提供了每种类型的例子以便诊断和解决方案继续沿着正确的轨道。

  

The aim of this document is to show how to use a "Deadlock Graph" produced by
and ORA-00060 error to identify the base problem.

本文的目的是为了展示怎样使用产生的“死锁图”和ora-00060确定基本的问题。

  

 **NOTE:** Some deadlock traces **DO NOT** contain a  "Deadlock Graph"
section because the deadlock is such that it would be inappropriate or
irrelevant. In these cases then the recommended action is to collect some
extra diagnostic information and then create a Service Request with Support as
outlined in the following document:

注：一些死锁的trace的确不包含‘死锁图’内容因为这种死锁可能是不合适的或者无关紧要的。在这些情况下建议的措施是收集一些额外的诊断信息，然后使用在线支持在下列文档中创建一个服务请求。

[Document
1552194.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1507093.1&id=1552194.1)
ORA-00060 Deadlock Graph Not Matching any Examples: Suggested Next Steps 文档
1552194.1 ora-00060 死锁图不匹配任何例子：建议下一步。

  

If you are not already using it, you can use the Troubleshooting Assistant to
help you diagnose common ORA-00060 Deadlock issues:

如果你已经不适用在线支持了，你能使用故障排查助手帮助你诊断普通的ora-00060死锁问题。

[Document
60.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1507093.1&id=60.1)
Troubleshooting Assistant: Oracle Database ORA-00060 Errors on Single Instance
(Non-RAC) Diagnosing Using Deadlock Graphs in ORA-00060 Trace Files

文档 60.1 故障排查助手：oracle 数据库 单实例使用ora-00060 trace文件中死锁图诊断ora-00060 错误

  

Deadlock Graph Interpretation

死锁图详解

  

A typical deadlock graph might look like this:

典型的死锁图可能像这样：

  

  ![noteattachment1][385ad20f8f064c5cbb4b986e5378f42f]

  

检测到死锁（ora-00060）

[事务死锁]

下列死锁不是oracle错误。它是由于应用程序设计中用户错误或发出错误的特别sql引起的死锁。下列信息可以帮助

判定死锁：

死锁图：

                                 阻碍者                                 等待者

资源明                      进程  会话  控制/占有  等待        进程   会话   控制/占有   等待

TX-00000000-0000000        555  1234        X              222   9876
X

TX-00000000-0000000        222  9876        X              555   1234
X

  

  

  

In order to differentiate different types, we have taken the Lock Type and the
mode held/waited for by the holder and waiter and used this to create a
signature for each type. For example, the previous graph shows the following
characteristics:

为了对比不同的类型的死锁，我们

  * >1 row in the Deadlock Graph

      死锁图中>1行

  * All Lock Types are TX

      所有死锁类型是TX

  * The lock modes for the Holders and the Waiters are all X (eXclusive, mode 6)

      占有者和等待者的锁模式都是X（排它，模式6）

  

By focusing on these particular characteristics in the graph:

通过关注图中这些特别的特征：

  ![noteattachment2][e7debf8dd8fcb62be6fc58227bc2d112]

  

will give us the following type (which is typically an application deadlock):

给出我们如下类型（通常是应用程序死锁）

TX X X  
TX X X  
  

Note that the most relevant parts of the "Key Signature" for deadlock type
recognition are the **lock Type** and the **Mode** it is requesting. The main
types are highlighted in the table below

死锁类型的“关键信号”是注解最重要的部分，这个标识死锁类型和死锁的寻求模式。死锁的主要类型已在下表中突出显示。

  

The most common types are:

最常见类型是：

  

 **" Key Signature"**

 **“关键信号”**

|

 **Lock Type**

 **锁类型**

|  **Requested**

 **Lock Mode**

 **需要的锁模式**

|

 **Deadlock Graph**

 **死锁图**

|  **Likely**

 **Deadlock Type**

 **可能的死锁类型**

|

 **Comments**

 **备注**  
  
---|---|---|---|---|---  
  
Type TX Lock Requesting Mode X (6)

TX类型锁需要X（6）模式

| TX| X(6)|  **TX** X **X**  
 **TX** X **X**|

[Application](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1507093.1&id=1552120.1
"ORA-00060 Deadlock Graph with >1 Row of "TX X X": Application Deadlock")

应用程序

|

TX Lock Held in Mode X (6) Requesting Mode X (6)

TX锁占有X(6)，需要X（6）  
  
Type TM Lock Requesting Mode SSX (5)

TM类型锁需要SSX(5)模式

| TM| SSX (5)|  **TM** SX **SSX** SX **SSX**  
 **TM** SX **SSX** SX **SSX**|

[Missing Index on Foreign Key (FK)
Constraint](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1507093.1&id=1552169.1
"ORA-00060 Deadlock Graph with >1 Row, at Least 1 Row is Type "TM" with Waiter
Waiting for Mode "SSX" Typical Graph Row: "TM SX SSX SX SSX"")

外检约束丢失索引

|

TM  Lock Held in Mode SX (3) Held SSX (5) Requested

TM锁持有SX（3）模式，持有并需要SSX（5）  
  
Type TX Lock Requesting Mode S(4)

  

| TX| S(4)|  **TX** X **S**  
 **TX** X **S**| [Insufficient Interested Transaction List (ITL)
Provision](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1507093.1&id=1552191.1#ITL
"ORA-00060 Deadlock Graph with >1 Row, at Least 1 Row is "TX X S" and None of
the Involved Objects are Bitmap Indexes")  
 **OR**  
[Bitmap
Index](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1507093.1&id=1552175.1
"ORA-00060 Deadlock Graph with >1 Row, at Least 1 Row is "TX X S" and at Least
1 Involved Object is a Bitmap Index") **  
OR**  
[PK/UK
Index](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1507093.1&id=1552191.1#PKUKINDEX
"ORA-00060 Deadlock Graph with >1 Row, at Least 1 Row is "TX X S" and None of
the Involved Objects are Bitmap Indexes")|

TX Lock Held in Mode X (6) Requesting Mode S (4)

ITL, Bitmap Index and PK/UK Index Signatures are the Same. Further
Investigation will be required to identify absolute cause  
  
Type TX Lock Requesting Mode X (6)  
Single Row in Deadlock Graph| TX| X(6)|  **TX** X **X**  
 **Single Row in Deadlock Graph**| [Self
Deadlock](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1507093.1&id=1552123.1
"ORA-00060 Deadlock Graph with ONLY 1 Row of "TX X X", No Autonomous
Transactions: Single-Resource "SELF Deadlock"")  
OR  
[Autonomous Transaction Self
Deadlock](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1507093.1&id=1552173.1
"ORA-00060 Deadlock Graph with ONLY 1 Row of")|  This looks the same as a
standard application deadlock except that there is only a single row in the
deadlock graph.  
Type UL Lock in Deadlock Graph| UL| ANY|  **UL ? ?  
?**| [Application Deadlock Featuring User Defined
Locks](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1507093.1&id=2063394.1
"ORA-00060 Deadlock Graph with at least 1 Row of Featuring a "UL .. .." Lock:
Application Deadlock Involving a User Defined Lock")|  This is very similar to
the standard application deadlock except that it features User Defined Locks  
  


 **Note:** this table is not exhaustive and outlines the most common issues.
There are some rare conditions where deadlocks can be achieved that are not
mentioned. For cases that do not match those above, the recommended action is
to collect some extra diagnostic information and then create a Service Request
with Support as outlined in the following document:

[Document
1552194.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1507093.1&id=1552194.1)
ORA-00060 Deadlock Graph Not Matching any Examples: Suggested Next Steps

文档 1552194.1 ora-00060 死锁图不匹配任何例子：建议下一步。

For information on how to identify and diagnose the various different types of
ORA-00060 Deadlock Types that you may encounter, please refer to the following
document:

[Document
1559695.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1507093.1&id=1559695.1)
How to Diagnose Different ORA-00060 Deadlock Types Using Deadlock Graphs in
Trace

文档1559695.1 怎样使用trace中死锁图诊断不同的ora-00060 死锁类型

Note: these are the most common types and causes. There are rare cases where
similar symptoms can be found with different causes. If there is any doubt
about the identification of a particular non-application deadlock type or if
different graphs are seen, then file a Service Request with Oracle Support  
  
For Reference, the Oracle lock modes are :  
  
0 - none  
1 - null (NULL)  
2 - Row Share, also called a subshare table lock  (SS)  
3 - Row eXclusive Table Lock, also called a subexclusive table lock (SX)  
4 - Share Table Lock (S)  
5 - Share Row-eXclusive, also called a share-subexclusive table lock (SSX)  
6 - EXclusive (X)

Note: Often you will see a combination of an application deadlock "Signature"
plus one of the others as opposed to a "classic" repeating signature. For
example you may see something like:  
  

    
    
    Deadlock graph:
                         ---------Blocker(s)--------  ---------Waiter(s)---------
    Resource Name          process session holds waits  process session holds waits
    TM-XXXXXXXX-00000000　      11     333    SX             22      44    SX   SSX
    TX-XXXXXXXX-XXXXXXXX　      22      44     X             11     333           X
    

  
Which is a combination of the "Application deadlock" and "Missing Index on
Foreign Key (FK) Constraint" deadlock. In these cases, it is advisable to
resolve the non-"TX X X" symptoms first since it is more likely that the less
common FK/ITL/Bitmap signature is the base cause as opposed to an application
deadlock.



Please Note that the trace contains various associated pieces of information
that may or may not have any relevance to the issue dependent on the type of
deadlock. For example, in the "Rows Waited on:" Section, the "dictionary objn"
value can be used to identify related objects in certain cases, but in other
cases may point at totally unrelated information. If the information is
useable, it is noted in the relevant section, otherwise, do not rely upon it.

There is more about lock modes and locking in the following:

  

 **Oracle® Database Concepts**

 **oracle  数据库   概念**

 **12 _c_ Release 1 (12.1)**

 **12c 发行版1（12.1）**

E17633-20

Chapter 9 Data Concurrency and Consistency

第9章 数据并发性和一致性

Section: Lock Modes

小节：锁模式

[http://docs.oracle.com/cd/E16655_01/server.121/e17633/consist.htm#CNCPT020](http://docs.oracle.com/cd/E16655_01/server.121/e17633/consist.htm#CNCPT020
"Lock Modes")

  

 **Ask Questions, Get Help, And Share Your Experiences With This Article**

提问题，获取帮助，和分享你与这篇文章有关的经验

 **Would you like to explore this topic further with other Oracle Customers,
Oracle Employees, and Industry Experts?**  
  
[ Click here](https://community.oracle.com/thread/3297263 "Discussion Thread:
Troubleshooting ORA-00060 Deadlock Detected \[Document IDs 62365.1, 1507093.1
& 1559695.1\]") to join the discussion where you can ask questions, get help
from others, and share your experiences with this specific article.  
Discover discussions about other articles and helpful subjects by clicking
[here](https://community.oracle.com/community/support/oracle_database/database_tuning
"My Oracle Support Community - Database Tuning") to access the main _My Oracle
Support Community_ page for Database Tuning.

  

Solution

解决方案

For information on how to identify and diagnose the various different types of
ORA-00060 Deadlock Types that you may encounter, please refer to the following
document:

[Document
1559695.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1507093.1&id=1559695.1)
How to Diagnose Different ORA-00060 Deadlock Types Using Deadlock Graphs in
Trace

文档1559695.1 怎样使用trace中死锁图诊断不同的ora-00060 死锁类型







  

Discuss ORA-00060 Deadlocks

讨论 ora-00060 死锁

 **The window below is a live discussion of this article (not a screenshot).
We encourage you to join the discussion by clicking the "Reply" link below for
the entry you would like to provide feedback on. If you have questions or
implementation issues with the information in the article above, please share
that below.**

then the recommended action is to collect some extra diagnostic information
and then create a Service Request with Support as outlined in the following
document:

  

References

参考文档

[NOTE:1559695.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1507093.1&id=1559695.1)
\- How to Diagnose Different ORA-00060 Deadlock Types Using Deadlock Graphs in
Trace  
[NOTE:1019527.6](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1507093.1&id=1019527.6)
\- Script to Check for Foreign Key Locking Issues for a Specific User  
[NOTE:1039297.6](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1507093.1&id=1039297.6)
\- Script: To list Foreign Key Constraints  
[NOTE:15476.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1507093.1&id=15476.1)
\- FAQ: Detecting and Resolving Locking Conflicts and Ora-00060 errors  
[NOTE:33453.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1507093.1&id=33453.1)
\- Locking and Referential Integrity  
[NOTE:62354.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1507093.1&id=62354.1)
\- Waits for 'Enq: TX - ...' Type Events - Transaction (TX) Lock Example
Scenarios  
[NOTE:18251.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1507093.1&id=18251.1)
\- OERR: ORA-60 "deadlock detected while waiting for resource"  
[NOTE:60.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1507093.1&id=60.1)
\- Troubleshooting ORA-00060 Deadlock Detected Errors  
  
  
  
  


---
### ATTACHMENTS
[385ad20f8f064c5cbb4b986e5378f42f]: media/How_to_Identify_ORA-00060_Deadlock_Types_Using_Deadlock_Graphs_in_Trace_文档_ID_1507093-3.1)
[How_to_Identify_ORA-00060_Deadlock_Types_Using_Deadlock_Graphs_in_Trace_文档_ID_1507093-3.1)](media/How_to_Identify_ORA-00060_Deadlock_Types_Using_Deadlock_Graphs_in_Trace_文档_ID_1507093-3.1))
[e7debf8dd8fcb62be6fc58227bc2d112]: media/How_to_Identify_ORA-00060_Deadlock_Types_Using_Deadlock_Graphs_in_Trace_文档_ID_1507093-4.1)
[How_to_Identify_ORA-00060_Deadlock_Types_Using_Deadlock_Graphs_in_Trace_文档_ID_1507093-4.1)](media/How_to_Identify_ORA-00060_Deadlock_Types_Using_Deadlock_Graphs_in_Trace_文档_ID_1507093-4.1))

---
### TAGS
{翻译}

---
### NOTE ATTRIBUTES
>Created Date: 2016-11-28 00:41:13  
>Last Evernote Update Date: 2016-11-30 01:03:19  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=156108188417175  
>source-url: &  
>source-url: id=1507093.1  
>source-url: &  
>source-url: _adf.ctrl-state=1adjq74nvy_72  
>source-application: evernote.win32  