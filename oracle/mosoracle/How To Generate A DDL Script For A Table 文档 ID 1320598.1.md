# How To Generate A DDL Script For A Table (文档 ID 1320598.1)

  

|

|

**In this Document**

| |
[Purpose](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=89007722900293&id=1320598.1&displayIndex=5&_afrWindowMode=0&_adf.ctrl-
state=1aujci0hbj_474#PURPOSE)  
---|---  
|
[Requirements](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=89007722900293&id=1320598.1&displayIndex=5&_afrWindowMode=0&_adf.ctrl-
state=1aujci0hbj_474#SWREQS)  
---|---  
|
[Configuring](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=89007722900293&id=1320598.1&displayIndex=5&_afrWindowMode=0&_adf.ctrl-
state=1aujci0hbj_474#CONFIG)  
---|---  
|
[Instructions](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=89007722900293&id=1320598.1&displayIndex=5&_afrWindowMode=0&_adf.ctrl-
state=1aujci0hbj_474#RUNSTEPS)  
---|---  
|
[Script](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=89007722900293&id=1320598.1&displayIndex=5&_afrWindowMode=0&_adf.ctrl-
state=1aujci0hbj_474#CODE)  
---|---  
| [Sample
Output](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=89007722900293&id=1320598.1&displayIndex=5&_afrWindowMode=0&_adf.ctrl-
state=1aujci0hbj_474#OUTPUT)  
---|---  
  
* * *

## Applies to:

Oracle Applications Technology Stack - Version 11.5.10.2 to 12.2 [Release
11.5.10 to 12.2]  
Information in this document applies to any platform.

## Purpose

\-- File Name : ddl.sql  
\-- Purpose : To generate a ddl script of a table and its index/trigger from
the database.

The sample program in this article is provided for educational purposes only
and is NOT supported by Oracle Support Services. It has been tested
internally, however, and works as documented. We do not guarantee that it will
work for you, so be sure to test it in your environment before relying on it.

##  _Caution_

 _This sample code is provided for educational purposes only, and is not
supported by Oracle Support. It has been tested internally, however, we do not
guarantee that it will work for you. Ensure that you run it in your test
environment before using._

## Script

  

EXECUTE
DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'STORAGE',false);

  

\--  
\-- File Name : ddl.sql  
\-- Purpose : it generates ddl script of table and its index/trigger from the
database.  
\-- Date : 2011/05/09  
\-- Author : Jinsoo Eo (Apps Performance Group, Oracle HQ)  
\--  
\-- How to use ddl.sql  
\-- Run ddl.sql on the sql*plus.  
\-- Login the sql*plus with apps user or dba user  
\-- Start ddl.sql, which will ask you table_name and table_owner that you're
looking for.  
\-- It will generate tablename_ddl.txt  
  
set long 1000000

SET PAGESIZE 3000

set lines 300

SET HEADING OFF  
SET VERIFY OFF  
SET FEEDBACK OFF  
set echo on

set timing off

set wrap on

  
ACCEPT TABLE_NAME CHAR PROMPT 'Enter Table Name : '  
ACCEPT TABLE_OWNER CHAR PROMPT 'Enter Table Owner : '  
  
select DBMS_METADATA.GET_DDL('TABLE',OBJECT_NAME,OWNER)  
FROM Dba_objects  
where owner = UPPER('&TABLE_OWNER') and object_name = UPPER('&TABLE_NAME')  
and object_type = 'TABLE'  
union all  
select dbms_metadata.GET_DEPENDENT_DDL ('COMMENT', TABLE_NAME, OWNER )  
FROM (select table_name,owner  
from Dba_col_comments  
where owner = UPPER('&TABLE_OWNER')  
and table_name = UPPER('&TABLE_NAME')  
and comments is not null  
union  
select table_name,owner  
from sys.Dba_TAB_comments  
where owner = UPPER('&TABLE_OWNER')  
and table_name = UPPER('&TABLE_NAME')  
and comments is not null)  
union all  
select DBMS_METADATA.GET_DEPENDENT_DDL('INDEX',TABLE_NAME, TABLE_OWNER)  
FROM (select table_name,table_owner  
FROM Dba_indexes  
where table_owner = UPPER('&TABLE_OWNER')  
and table_name = UPPER('&TABLE_NAME')  
and index_name not in (select constraint_name  
from sys.Dba_constraints  
where table_name = table_name  
and constraint_type = 'P' )  
and rownum = 1)  
union all  
select dbms_metadata.GET_DDL ('TRIGGER', trigger_name ,owner )  
from Dba_triggers  
where table_owner = UPPER('&TABLE_OWNER')  
and table_name = UPPER('&TABLE_NAME')  
.  
SET CONCAT +  
spool &TABLE_NAME+_ddl.txt  
/  
spool off

## Sample Output

$sqlplus apps/<apps password>

SQL>@ddl

SQL> ACCEPT TABLE_NAME CHAR PROMPT 'Enter Table Name : '  
Enter Table Name : WF_ITEMS  
SQL> ACCEPT TABLE_OWNER CHAR PROMPT 'Enter Table Owner : '  
Enter Table Owner : APPLSYS

SQL> exit

$ cat WF_ITEMS_ddl.sql

CREATE TABLE "APPLSYS"."WF_ITEMS"  
( "ITEM_TYPE" VARCHAR2(8) NOT NULL ENABLE,  
"ITEM_KEY" VARCHAR2(240) NOT NULL ENABLE,  
"ROOT_ACTIVITY" VARCHAR2(30) NOT NULL ENABLE,  
"ROOT_ACTIVITY_VERSION" NUMBER NOT NULL ENABLE,  
"OWNER_ROLE" VARCHAR2(320),  
"PARENT_ITEM_TYPE" VARCHAR2(8),  
"PARENT_ITEM_KEY" VARCHAR2(240),  
"PARENT_CONTEXT" VARCHAR2(2000),  
"BEGIN_DATE" DATE NOT NULL ENABLE,  
"END_DATE" DATE,  
"USER_KEY" VARCHAR2(240),  
"HA_MIGRATION_FLAG" VARCHAR2(1),  
"SECURITY_GROUP_ID" VARCHAR2(32)  
) PCTFREE 10 PCTUSED 40 INITRANS 10 MAXTRANS 255 NOCOMPRESS NOLOGGING  
STORAGE(INITIAL 131072 NEXT 131072 MINEXTENTS 1 MAXEXTENTS 2147483645  
PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)  
TABLESPACE "APPS_TS_TX_DATA"  
  
CREATE INDEX "APPLSYS"."WF_ITEMS_N1" ON "APPLSYS"."WF_ITEMS"
("PARENT_ITEM_TYPE", "PARENT_ITEM_KEY")  
PCTFREE 10 INITRANS 11 MAXTRANS 255 COMPUTE STATISTICS  
STORAGE(INITIAL 131072 NEXT 131072 MINEXTENTS 1 MAXEXTENTS 2147483645  
PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)  
TABLESPACE "APPS_TS_TX_IDX"  
  
CREATE INDEX "APPLSYS"."WF_ITEMS_N3" ON "APPLSYS"."WF_ITEMS" ("END_DATE")  
PCTFREE 10 INITRANS 11 MAXTRANS 255 COMPUTE STATISTICS  
STORAGE(INITIAL 131072 NEXT 131072 MINEXTENTS 1 MAXEXTENTS 2147483645  
PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)  
TABLESPACE "APPS_TS_TX_IDX"

...  
  
  
  
  
  



---
### TAGS
{DBMS_METADATA}

---
### NOTE ATTRIBUTES
>Created Date: 2017-06-27 09:40:27  
>Last Evernote Update Date: 2017-07-04 02:54:57  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=89007722900293  
>source-url: &  
>source-url: id=1320598.1  
>source-url: &  
>source-url: displayIndex=5  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=1aujci0hbj_474#CODE  