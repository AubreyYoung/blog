# Oracle-指导手册-Oracle DB 归档日志挖掘.html

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

066584604

Oracle-指导手册-Oracle DB 归档日志挖掘

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

此文档用于指导在Oracle DB日志挖掘时的操作步骤。

详细信息

# 1 概述

此文档用于指导在Oracle DB日志挖掘时的操作步骤。

  

# 2 日志挖掘操作步骤

以下建议在plsql-dev的sql windows 进行操作(注意：只能在同一个sql windows里边进行操作，因为v$logmnr_contents
是基于session的)，当然也可以在sqlplus里边进行如下操作，只不过sqlplus的格式化输出不是很整齐，所以推荐在plsql-dev的sql
windows 进行操作。

以下操作请尽量用sys用户来执行，sys密码忘记的话，也可以用具有dba角色的用户来执行：



### 2.1.1 1、手动切换当前redo日志

alter system archive log current;

### 2.1.2 和客户确定需要进行日志挖掘的大体时间点，并查询在那时间段内产生的归档日志有哪些

alter session set NLS_DATE_FORMAT='YYYY-MM-DD HH24:MI:SS';

select thread#,name,completion_time  from v$archived_log where completion_time
>TO_DATE('2016-06-15 10:00:00','YYYY-MM-DD HH24:MI:SS') order by
completion_time;

### 2.1.3 添加archive redo log：

将下面logfilename后面的文件替换为具体的归档日志文件，挖多少加多少。

begin

sys.dbms_logmnr.add_logfile(logfilename=>'+DG_FRA/aaa/archivelog/2012_05_30/thread_1_seq_2856',
options=>sys.dbms_logmnr.addfile);

sys.dbms_logmnr.add_logfile(logfilename=>'+DG_FRA/aaa/archivelog/2012_05_30/thread_1_seq_2857',
options=>sys.dbms_logmnr.addfile);

sys.dbms_logmnr.add_logfile(logfilename=>'+DG_FRA/aaa/archivelog/2012_05_30/thread_1_seq_2858',
options=>sys.dbms_logmnr.addfile);

end;



说明：

+DG_FRA/aaa/archivelog/2012_05_30/thread_1_seq_2856
这个来源于v$archived_log视图，该视图还有一列是completion_time，该列的意思是该sequence号对应的redolog
归档完成的时间。



二、开始分析：

begin

sys.dbms_logmnr.start_logmnr(options=>sys.dbms_logmnr.dict_from_online_catalog);

end;



三、检查分析结果：

select * from  v$logmnr_contents  where sql_redo like '%table_name%'

\---这个where条件，就是你自己要填写查找的内容。

也可以写当时的sql语句如delte from xxx 等关键字，注意日志挖掘挖出来的并不是和执行的sql语句一模一样。举例

前台执行delete from scott.nn ;

语句挖出来后会将是很多sql，如：

![noteattachment2][cb0c4b31e596665d6f02c1a94810af1f]

另外，v$logmnr_contents有一列scn是表示发起命令时的scn号，可方便用于误删除数据的恢复操作，详见《oracle_误删除数据恢复操作手册》

四、结束分析

begin

sys.dbms_logmnr.end_logmnr;

end;

或者直接退出会话。

### 2.1.4 关于补充日志

另外，只有在已经打开supplemental log
的情况下，会记录执行sql的OS_USERNAME,USERNAME,MACHINE_NAME，数据库默认不打开，所以这三列信息不进行记录。

 _知识点：打开补充日志命令_

alter database add SUPPLEMENTAL log data;

  

相关文档

内部备注

附件


---
### ATTACHMENTS
[7f025a17697ee15eb3197c61326b203b]: media/Oracle-指导手册-Oracle_DB_归档日志挖掘.html
[Oracle-指导手册-Oracle_DB_归档日志挖掘.html](media/Oracle-指导手册-Oracle_DB_归档日志挖掘.html)
>hash: 7f025a17697ee15eb3197c61326b203b  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-指导手册-Oracle DB 归档日志挖掘_files\11947ec6e06f4dd6a765bcc48c4fc88d.png  

[cb0c4b31e596665d6f02c1a94810af1f]: media/Oracle-指导手册-Oracle_DB_归档日志挖掘-2.html
[Oracle-指导手册-Oracle_DB_归档日志挖掘-2.html](media/Oracle-指导手册-Oracle_DB_归档日志挖掘-2.html)
>hash: cb0c4b31e596665d6f02c1a94810af1f  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-指导手册-Oracle DB 归档日志挖掘_files\20180103111619_139.png  

---
### NOTE ATTRIBUTES
>Created Date: 2018-09-25 03:29:40  
>Last Evernote Update Date: 2018-10-01 15:33:46  
>author: YangKwong  
>source: desktop.win  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-指导手册-Oracle DB 归档日志挖掘.html  
>source-application: evernote.win32  