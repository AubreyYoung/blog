# Oracle 修改sys和system密码.html

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

069310704

Oracle 修改sys和system密码

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

用于修改rac的sys及system密码  

详细信息

 **RAC** **初始** **SYS** **密码为** **oracle** **，将其修改为** **zylong** **，需要注意的地方**

 ** **

 **节点** **1** **修改** **sys** **密码，** **sys** **密码存放在密码文件中**

SQL> ALTER USER SYS IDENTIFIED BY zylong;

 ** **

此时如果查看$ORACLE_HOME/dbs/orapw***1的修改时间会发现，节点1的文件修改时间最接近当前时间，而节点2的修改时间较早，说明节点1的密码文件修改过，节点2的密码文件未修改。

 **以下节点** **1** **验证登录：**

[oracle@racdg1 admin]$ sqlplus sys/zylong@orclddg1 as sysdba

登录正常

[oracle@racdg1 admin]$ sqlplus sys/zylong@orclddg2 as sysdba



SQL*Plus: Release 11.2.0.4.0 Production on Mon Jul 4 21:49:32 2016

Copyright (c) 1982, 2013, Oracle.  All rights reserved.

ERROR:

ORA-01017: invalid username/password; logon denied

登录异常

[oracle@racdg1 admin]$ sqlplus sys/oracle@orclddg2 as sysdba

登录正常

通过以上实验可以说明，使用ALTER USER SYS IDENTIFIED BY语句修改密码，只对当前节点生效。



 **节点** **1** **修改** **system** **密码，** **system** **密码存放在数据字典中**

SQL> ALTER USER SYSTEM IDENTIFIED BY zylong;

两个节点均生效



 **注意：**

1.       rac环境下修改sys密码时，在所有节点上都要修改；修改system密码时，只在一个节点上修改。

2.       修改SYS用户的密码后，如果当前数据库有其他软件通过SYS用户连接，比如备份软件commvault，注意修改软件上的SYS用户密码

3.       如果当前数据库有data guard，使用ALTER USER SYS IDENTIFIED BY语句修改SYS用户的密码，不会更新备库的密码文件，需要先关闭备库，将修改后的密码文件传输到备端的相应位置，再启动备库。

4.       如果dataguard如果主端清理归档的脚本中采用了sys用户，则要注意修改脚本中sys用户的密码。

  

相关文档

内部备注

附件


---
### ATTACHMENTS
[7f025a17697ee15eb3197c61326b203b]: media/Oracle_修改sys和system密码.html
[Oracle_修改sys和system密码.html](media/Oracle_修改sys和system密码.html)
>hash: 7f025a17697ee15eb3197c61326b203b  
>source-url: file://C:\Users\galaxy\Desktop\high  
>source-url: go\Oracle 修改sys和system密码_files\11947ec6e06f4dd6a765bcc48c4fc88d.png  

---
### NOTE ATTRIBUTES
>Created Date: 2018-09-25 03:29:10  
>Last Evernote Update Date: 2018-10-01 15:33:54  
>author: YangKwong  
>source: desktop.win  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle 修改sys和system密码.html  
>source-application: evernote.win32  