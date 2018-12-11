# V$SYS_OPTIMIZER_ENV (文档 ID 305519.1)

  

|

|

 **In this Document**  

| |
[Goal](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360594730931645&id=305519.1&_adf.ctrl-
state=xdpz2dnb9_256#GOAL)  
---|---  
|
[Fix](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360594730931645&id=305519.1&_adf.ctrl-
state=xdpz2dnb9_256#FIX)  
---|---  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360594730931645&id=305519.1&_adf.ctrl-
state=xdpz2dnb9_256#REF)  
---|---  
  
* * *

## Applies to:

Oracle Database - Enterprise Edition - Version 10.1.0.2 to 11.2.0.3 [Release
10.1 to 11.2]  
Oracle Database - Personal Edition - Version 10.1.0.2 to 11.2.0.3 [Release
10.1 to 11.2]  
Oracle Database - Standard Edition - Version 10.1.0.2 to 11.2.0.3 [Release
10.1 to 11.2]  
Information in this document applies to any platform.  
Information in this document applies to any platform.  
  

## Goal

Information on V$SYS_OPTIMIZER_ENV

## Fix

Question :-  
============

What is V$SYS_OPTIMIZER_ENV ?

Answer :-  
=================

V$SYS_OPTIMIZER_ENV displays the contents of the optimizer environment for the
instance. The optimizer environment stores the value of the main parameters
used by the Oracle optimizer when building the execution plan of a SQL
statement. Hence, modifying the value of one or more of these parameters (for
example, by issuing an ALTER SYSTEM statement) could lead to plan changes.

This will only show parameters for optimizer on instance level. There is
another view V$SES_OPTIMIZER_ENV which displays  
displays the contents of the optimizer environment used by each session.There
is also view V$SQL_OPTIMIZER_ENV which displays the contents of the optimizer
environment used to build the execution plan of a SQL cursor.

  
Description of V$SYS_OPTIMIZER_ENV.  
=======================================

SQL*Plus: Release 10.1.0.3.0 - Production on Tue Apr 19 11:29:31 2005

Copyright (c) 1982, 2004, Oracle. All rights reserved.

  
Connected to:  
Oracle Database 10g Enterprise Edition Release 10.1.0.3.0 - 64bit Production  
With the Partitioning, OLAP and Data Mining options

SQL> desc v$sys_optimizer_env;  
Name Null? Type  
\----------------------------------------- --------
----------------------------  
ID NUMBER  
NAME VARCHAR2(40)  
ISDEFAULT VARCHAR2(3)  
VALUE VARCHAR2(25)  
DEFAULT_VALUE VARCHAR2(25)

Question:-  
==========

How is v$sys_optimizer_env useful?

Answer :-  
=======

1) v$sys_optimizer_env helps to quickly Verify Instance level optimizer
parameters.

SQL> select NAME,VALUE from v$sys_optimizer_env;

NAME VALUE  
\---------------------------------------- -------------------------  
parallel_execution_enabled true  
optimizer_features_enable 10.1.0.3  
cpu_count 4  
active_instance_count 1  
parallel_threads_per_cpu 2  
hash_area_size 131072  
bitmap_merge_area_size 1048576  
sort_area_size 65536  
sort_area_retained_size 0  
db_file_multiblock_read_count 16  
pga_aggregate_target 102400 KB

NAME VALUE  
\---------------------------------------- -------------------------  
parallel_query_mode enabled  
parallel_dml_mode disabled  
parallel_ddl_mode enabled  
optimizer_mode all_rows  
cursor_sharing exact  
star_transformation_enabled false  
optimizer_index_cost_adj 100  
optimizer_index_caching 0  
query_rewrite_enabled true  
query_rewrite_integrity enforced  
workarea_size_policy auto

NAME VALUE  
\---------------------------------------- -------------------------  
optimizer_dynamic_sampling 2  
statistics_level typical  
skip_unusable_indexes true

25 rows selected.

  
2) If we change any of the above parameter, it will be reflected immediately
in the v$sys_optimizer_env view.  
The following example of pga aggregate target change reflects the change in
v$sys_optimizer_env view.

SQL*Plus: Release 10.1.0.3.0 - Production on Tue Apr 19 11:44:43 2005

Copyright (c) 1982, 2004, Oracle. All rights reserved.

  
Connected to:  
Oracle Database 10g Enterprise Edition Release 10.1.0.3.0 - 64bit Production  
With the Partitioning, OLAP and Data Mining options

SQL> alter system set pga_aggregate_target=200M;

System altered

SQL> select name, value from v$sys_optimizer_env where
name='pga_aggregate_target';  
  
NAME VALUE  
\---------------------------------------- -------------------------  
pga_aggregate_target 204800 KB.

## References

[NOTE:215187.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=305519.1&id=215187.1)
\- SQLT (SQLTXPLAIN) - Tool that helps to diagnose a SQL statement performing
poorly or one that produces wrong results  
  
  
  



---
### TAGS
{V$SYS_OPTIMIZER_ENV}

---
### NOTE ATTRIBUTES
>Created Date: 2017-12-27 08:57:00  
>Last Evernote Update Date: 2018-10-01 15:59:04  
>author: YangKwong  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360594730931645  
>source-url: &  
>source-url: id=305519.1  
>source-url: &  
>source-url: _adf.ctrl-state=xdpz2dnb9_256  