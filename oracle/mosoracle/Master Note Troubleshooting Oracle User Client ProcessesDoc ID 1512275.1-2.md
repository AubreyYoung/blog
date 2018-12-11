# Master Note: Troubleshooting Oracle User (Client) Processes(Doc ID
1512275.1)

Master Note: Troubleshooting Oracle User (Client) Processes(Doc ID 1512275.1)

主注解：Oracle 用户（客户端）进程排障（文档ID 1512275.1）

  

In this Document

本文档

  

Purpose

目的

  

Troubleshooting Steps

排障步骤

  

     Concepts

     概念

  

          Issues Involving Client (User) Processes

          客户端（用户）进程相关问题

  

     Client / Server / Interoperability

     客户端/服务端/交互

  

     Issues involving Client Connections

     客户端连接相关问题

  

     Issues Involving User Processes

     用户进程相关问题

  

     Helpful Articles on Client / User Processes

     关于客户端/用户进程的有用文章

  

     Helpful Articles on Connecting as SYSDBA

     关于以SYSDBA连接的有用文章

  

Further Diagnostics

进一步诊断

  

References

参考文档

  

|

|

  

Applies to:

适用于

Oracle Database - Enterprise Edition - Version 9.2.0.1 and later

oracle数据库-企业版-9.2.0.1及以后版本

Information in this document applies to any platform.

本文内容适用于任何平台

  

  

Purpose

目的

This document is intended to assist Database Administrators resolve issues
encountered involving User (Client) Processes.

  

Troubleshooting Steps

排障步骤

  

Concepts

概念

  

A client (user) process executes the application or Oracle tool code. When
users run client applications such as SQL*Plus, the operating system creates
client processes to run the applications.

客户端（用户）进程用来执行应用程序或Oracle工具代码。当用户运行如SQL*PLUS客户端应用程序，操作系统则创建客户端进程来运行应用程序。

  

  

For example, assume that a user on a client host starts SQL*Plus and connects
over the network to database **exdb  **on a different host (the database
instance is not started):

如：假设一个客户端主机开启SQL*PLUS并通过网络连接到不同主机的数据库exdb（数据库实例未开启）：

  

SQL> CONNECT SYS@exdb AS SYSDBA  
Enter password: *********

Connected to an idle instance. <<<< database instance is not started

连接到一个空闲实例. <<<< 数据库实例未开启

  

On the client host, a search of the processes for either `sqlplus` or **exdb
**shows only the `sqlplus` client process:

在客户端主机上，查找sqlplus或exdb的进程显示只有sqlplus客户端进程

  

    
    
    % ps -ef | grep -e exdb -e sqlplus | grep -v grep
    clientuser 29437 29436  0 15:40 pts/1    00:00:00 sqlplus           as sysdba
    

  

Client processes differ in important ways from the Oracle processes
interacting directly with the instance. The Oracle processes servicing the
client process can read from and write to the SGA, whereas the client process
cannot. A client process can run on a host other than the database host,
whereas Oracle processes cannot.

客户端进程不同于从Oracle进程直接与实例交互的方式。服务于客户端进程的Oracle进程能读写SGA，然而客户端进程不能。客户端进程能运行在与数据库主机不同的主机上，而Oracle进程不可以。

  

Oracle Database creates server processes to handle the requests of client
processes connected to the instance. A client process always communicates with
a database through a separate server process. Although the client application
and database can run on the same computer, greater efficiency is often
achieved when the client portions and server portion are run by different
computers connected through a network. More details in [Note
1504268.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=1504268.1
"Note 1504268.1 Master Note Oracle \(client\) Process")

Oralce
数据库创建服务端进程来处理客户端进程连接实例的请求。客户端进程总是通过独立的服务端进程与数据库交互的。尽管客户端应用程序和数据库能运行在相同的电脑上，当客户与服务运行在通过网络互联的不同计算机上时，这获得了更大的效率。更多详情在[Note
1504268.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=1504268.1
"Note 1504268.1 Master Note Oracle \(client\) Process")。

  

 _ **Issues Involving Client (User) Processes**_

客户端（用户）进程相关问题

  

Many of the issues involving client/user processes involve compatibility of
versions between client and server.

客户端/用户进程相关的许多问题涉及客户端与服务端版本兼容性。

  

 **Client / Server / Interoperability**

客户端/服务端/交互

  

Whether you are using Oracle tools like SQL*Plus or a Third Party
tool/application, the client and server version should be interoperable. The
following Note is a comprehensive document outlining the support for
interoperability between Oracle client and server versions and should be
checked first when looking at possible issues.

如果你使用SQL*Plus或第三方工具/应用程序类似Oracle工具，客户端和服务端版本应当是兼容的。下列注解是一个概括oracle客户端与服务端兼容性的综合文档

并且当遇到相关问题时应当首先查阅。

  

  

[Note
207303.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=207303.1
"Note 207303.1") \- Client / Server / Interoperability Support Matrix For
Different Oracle Versions

Note 207303.1 -  客户端/服务端/交互支持的不同Oracle版本矩阵图

  

 **Issues involving Client Connections**

 客户端连接相关问题

  

The following is a list of some of the known issues connecting from specific
client versions:

从特定客户端版本连接数据库已知问题列表如下：

  

[Note
785291.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=785291.1
"Note 785291.1") \- Unable To Connect To 11g Db From LINUX 11g Client via
SQLPUS as non-Oracle user Hang

[Note
785291.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=785291.1
"Note 785291.1") \- 由于非Oracle用户挂起导致linux 11g客户端SQLPLUS不能连接11g DB

  

[Note
3437884.8](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=3437884.8
"Note 3437884.8") \- Bug 3437884 - 10g client cannot connect to 8.1.7.0 -
8.1.7.3 server

[Note
3437884.8](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=3437884.8
"Note 3437884.8") \- Bug 3437884 - 1og客户端不能连接8.1.7.0 - 8.1.7.3服务端

  

[Note
3564573.8](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=3564573.8
"Note 3564573.8") \- Bug 3564573 - ORA-1017 when 10g client connects to 8i/9i
server with EBCDIC ASCII connection

[Note
3564573.8](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=3564573.8
"Note 3564573.8") \- Bug 3564573 - 10g客户端连接到带有EBCDIC ASCII的8i/9i服务端引起ORA-1017

  

[Note
4511371.8](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=4511371.8
"Note 4511371.8") \- Bug 4511371 ORA-6544 / ORA-4052 using PLSQL between 10g
and 11g

[Note 4511371.8 \- Bug
4511371](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=4511371.8
"Note 4511371.8") 10g~11G使用PLSQL报ORA-6544 / ORA-4052

  

[Note
389713.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=389713.1
"Note 389713.1") \- Understanding and Diagnosing ORA-00600 [12333] / ORA-3137
[12333] Errors

[Note
389713.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=389713.1
"Note 389713.1") \- 理解和诊断ORA-00600 [12333] / ORA-3137 [12333]错误

  

[Note
207319.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=207319.1
"Note 207319.1") \- ALERT: Connections from Oracle 9.2 to Oracle7 are Not
Supported

[Note
207319.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=207319.1
"Note 207319.1") \- 警告：Oracle 9.2连接到Oracle 7 不支持

  

 **Issues Involving User Processes**

 用户进程相关问题

[Note
3835429.8](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=3835429.8
"Note 3835429.8") \- Bug 3835429 - OERI[kqrfrpo] / DB hang after killing a
user process

[Note
10325142.8](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=10325142.8
"Note 10325142.8") \- Bug 10325142 - Client process stack size gets reset by
OCIEnvCreate() call

[Note
7348613.8](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=7348613.8
"Note 7348613.8") \- Bug 7348613 - ORA-600 [17281] during process cleanup for
failed client

[Note
1196373.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=1196373.1
"Note 1196373.1") \- ORA-600 [17280] When Client Side Process Dies Or Breaks
The Connection Due to Inbound Connection Timed Out

[Note
1448953.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=1448953.1
"Note 1448953.1") \- User Process Aborts Due To ORA-24761 Error

[Note
316916.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=316916.1
"Note 316916.1") \- Processes Remain In V$Process Without A Related Session
ORA-00020

  

 **Helpful Articles on Client / User Processes**

关于客户端/用户进程的有用文章

  

[Note
1506805.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=1506805.1
"Note 1506805.1") \- Master Note: Troubleshooting ORA-03113

[Note
1506805.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=1506805.1
"Note 1506805.1") -主注解：ora-03113排障

  

[Note
119706.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=119706.1
"Note 119706.1") \- Troubleshooting Guide TNS-12535 or ORA-12535 or ORA-12170
Errors

[Note
119706.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=119706.1
"Note 119706.1") -TNS-12535 或 ORA-12535 或 ORA-12170 错误排障指导

  

[Note
951892.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=951892.1
"Note 951892.1") \- Why does a server process continue to run after its client
process has been terminated?

[Note
951892.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=951892.1
"Note 951892.1") -为什么客户端进程终止后它的服务进程继续运行？

  

[Note
387077.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=387077.1
"Note 387077.1") \- How To Find The Process Identifier (pid, spid) After The
Corresponding Session Is Killed?

[Note
387077.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=387077.1
"Note 387077.1") \- 杀掉相应的会话后怎样查找这个进程的ID信息（pid，spid）？

  

[Note
601605.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=601605.1
"Note 601605.1") \- A discussion of Dead Connection Detection, Resource
Limits, V$SESSION, V$PROCESS and OS processes

[Note
601605.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=601605.1
"Note 601605.1") \- 关于死亡连接发现，资源限制，v$session，v$process，和OS进程的讨论

  

[Note
206007.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=206007.1
"Note 206007.1") \- How To Automate Cleanup Of Dead Connections And INACTIVE
Sessions

[Note
206007.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=206007.1
"Note 206007.1") \- 怎样自动清理死亡连接和不活动会话？

  

[Note
219968.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=219968.1
"Note 219968.1") \- Client side tracing? SQL*Net & Oracle Net Services -
Tracing and Logging at a Glance

[Note
219968.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=219968.1
"Note 219968.1") \- 客户端追踪？SQL*Net& Oracle Net Services -瞬时的追踪和日志记录

  

[Note
164768.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=164768.1
"Note 164768.1") \- Troubleshooting: High CPU Utilization

[Note
164768.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=164768.1
"Note 164768.1") \- 排障：高CPU利用率

  

[Note
1019526.6](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=1019526.6
"Note 1019526.6") \- Script: To Obtain Session Information

[Note
1019526.6](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=1019526.6
"Note 1019526.6") \- 脚本：获取会话信息

  

[Note
1501987.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=1501987.1
"Note 1501987.1") \- Master Note: Overview of Database Resident Connection
Pooling (DRCP)

[Note
1501987.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=1501987.1
"Note 1501987.1") \- 主注解：数据库驻留连接池（DRCP）概况

  

 **Helpful Articles on Connecting as SYSDBA**

关于以SYSDBA连接的有用文章

  

  

[Note
233223.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=233223.1
"Note 233223.1") \- Checklist for Resolving CONNECT AS SYSDBA (INTERNAL)
Issues

注：233223.1- 解决connect as sysdba(内部)问题的清单

  

 **Further Diagnostics**

进一步诊断

  

If you were not able to resolve the issue with the details provided in this
document, please raise a Service Request for further assistance from Oracle
Support.

如果不能按照本文提供的资料解决问题，请从Oracle support发布一个服务请求（SR）来寻求进一步的帮助。

  

  

References

参考文档

[NOTE:207303.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=207303.1)
\- Client / Server Interoperability Support Matrix for Different Oracle
Versions

注：207303.1-客户端/服务端/交互支持的不同Oracle版本矩阵图

[NOTE:1504268.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1512275.1&id=1504268.1)
\- Master Note: Overview of User (Client) Processes

注：1504268.1-主注解：用户（客户端）进程概况  
  
---  
  
  



---
### TAGS
{翻译}  {已完}

---
### NOTE ATTRIBUTES
>Created Date: 2016-11-28 02:35:44  
>Last Evernote Update Date: 2016-11-30 02:39:23  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=163347977107398  
>source-url: &  
>source-url: id=1512275.1  
>source-url: &  
>source-url: _adf.ctrl-state=5kow4kf9s_53  
>source-application: evernote.win32  