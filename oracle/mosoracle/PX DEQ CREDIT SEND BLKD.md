# PX DEQ CREDIT SEND BLKD

  

|

|

 **In this Document**  

| |
[Purpose](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=126268264621566&id=738464.1&displayIndex=1&_afrWindowMode=0&_adf.ctrl-
state=yh5mhgxd4_92#REF_PURPOSE)  
---|---  
|
[Scope](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=126268264621566&id=738464.1&displayIndex=1&_afrWindowMode=0&_adf.ctrl-
state=yh5mhgxd4_92#REF_SCOPE)  
---|---  
| [Ask Questions, Get Help, And Share Your Experiences With This
Article](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=126268264621566&id=738464.1&displayIndex=1&_afrWindowMode=0&_adf.ctrl-
state=yh5mhgxd4_92#aref_section21)  
---|---  
|
[Details](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=126268264621566&id=738464.1&displayIndex=1&_afrWindowMode=0&_adf.ctrl-
state=yh5mhgxd4_92#REF_TEXT)  
---|---  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=126268264621566&id=738464.1&displayIndex=1&_afrWindowMode=0&_adf.ctrl-
state=yh5mhgxd4_92#REF)  
---|---  
  
* * *

## Applies to:

Oracle Database - Enterprise Edition - Version 9.0.1.0 and later  
Information in this document applies to any platform.  

## Purpose

This article describes what the "PX DEQ CREDIT SEND BLKD" wait is, and gives
some idea's what can be checked to reduce the wait for "PX Deq Credit: need
buffer" and "PX Deq Credit: send blkd" wait event at database level.

## Scope

For dba's

### Ask Questions, Get Help, And Share Your Experiences With This Article

Would you like to explore this topic further with other Oracle Customers,
Oracle Employees, and Industry Experts?

[Click here to join the discussion where you can ask questions, get help from
others, and share your experiences with this specific
article](https://community.oracle.com/message/11872977).  
Discover discussions about other articles and helpful subjects by clicking
[here](https://community.oracle.com/community/support/oracle_database/database_datawarehousing)
to access the main My Oracle Support Community page for Database
Datawarehousing.

## Details

The wait events "PX Deq Credit: need buffer" and "PX Deq Credit: send blkd"
are occur when data or messages are exchanged between processes that are part
of a px query.

There are at least 3 different main areas that can cause these waits.

  1. We see high waits if a lot of data and message are exchanged between parallel processes. The cause can be that the execution plan is bad or there are problem with the parallel execution setup.
  2. There is a problem with the resource like the CPU or the interconnect. As example with a CPU utilization around 100% the process are limited by the CPU and can not send the data fast enough.
  3. If parallel queries are hung where one process waits for "PX Deq Credit: need buffer" as example.

This article focuses primarily on point 1. For points 2 and 3 you may consult
[Note
1324685.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=738464.1&id=1324685.1)
Best Practices for a Data Warehouse on Oracle Database 11g for further
information.

1.) Parallel Degree settings

At database level you should check your parallel execution setup. Are there
objects that should not have a degree setting. As example a "alter index
<indexname> rebuild parallel 4;" would cause a degree of 4 on that index,
although the intention was to rebuild the index with parallel 4 , but do not
change the degree.

The best is to run the SQL command from:  
[Note.270837.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=738464.1&id=270837.1)
Report for the Degree of Parallelism on Tables and Indexes

The fourth command from this script would show a mismatch between DOP of a
index and the table. Here an example output:

OWNER TABLE_NAME DEGREE INSTANCES INDEX_NAME DEGREE INSTANCES  
\------ ------------ ------- --------- ------------ ------- ---------  
SCOTT DEPT 1 1 PK_DEPT 4 1  
SCOTT EMP 1 1 PK_EMP DEFAULT DEFAULT

We see that the index PK_DEPT and PK_EMP have a parallel degree , but the base
tables not. Here you should consider to change the index setting to no
parallel

alter index SCOTT.PK_DEPT noparallel;

And the second script can be helpful , to get an overview over the DOP
distribution in your schema. Here is an example output

OWNER DEGREE INSTANCES Num Tables 'PARALLE  
\------ ---------- ---------- ---------- --------  
OSS 1 1 126 Serial  
OSS 8 1 1 Parallel

We see that there is only 1 table with a degree of 8 in the schema OSS. Maybe
it was not planned to have a table with a DOP 8.. You should consider to find
the table and set it no parallel. You can use as example for the OSS schema

select table_name from all_tables  
where ( trim(degree) != '1' and trim(degree) != '0' ) or  
( trim(instances) != '1' and trim(instances) != '0' )  
and owner = 'OSS';

and the result is here

TABLE_NAME  
\------------------------------  
OSS_EMP

To change the table to no parallel you can run

alter table OSS.OSS_EMP noparallel;

All this would reduce the number of parallel execution queries and so also the
data that needs to be transfered.

It can also helpful to check if the degree on the objects(tables/indexes) is
not to high. As example in most situation the performance is good when
tables/indexes with a size less than 200 MB, do not have a parallel degree.

Sometimes it helps to increase PARALLEL_EXECUTION_MESSAGE_SIZE = 8k or 16K,
but this cause a larger "PX msg pool". This pool can we monitored via

select * from v$sgastat where upper(name) like 'PX%';

  
  

* * *

**The window below is a live discussion of this article (not a screenshot). We
encourage you to join the discussion by clicking the "Reply" link below for
the entry you would like to provide feedback on. If you have questions or
implementation issues with the information in the article above, please share
that below.**

## References

[NOTE:271767.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=738464.1&id=271767.1)
\- WAITEVENT: "PX Deq Credit: send blkd"  
  
  
  



---
### TAGS
{PX DEQ CREDIT SEND BLKD}

---
### NOTE ATTRIBUTES
>Created Date: 2017-08-07 09:40:33  
>Last Evernote Update Date: 2018-10-01 15:44:50  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=126268264621566  
>source-url: &  
>source-url: id=738464.1  
>source-url: &  
>source-url: displayIndex=1  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=yh5mhgxd4_92  