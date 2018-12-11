# How Do I Determine If Supplemental Logging Is Turned ON At The Database Or
The Table Level(Oracle Specific)? (文档 ID 1059362.1)

  

|

|

 **In this Document**  

| |
[Goal](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=1676907511997&id=1059362.1&displayIndex=1&_afrWindowMode=0&_adf.ctrl-
state=cnnzq2ypz_141#GOAL)  
---|---  
|
[Solution](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=1676907511997&id=1059362.1&displayIndex=1&_afrWindowMode=0&_adf.ctrl-
state=cnnzq2ypz_141#FIX)  
---|---  
  
* * *

## Applies to:

Oracle GoldenGate - Version 9.0.0.0 and later  
Information in this document applies to any platform.  
***Checked for relevance on 29-Oct-2012***  
  

## Solution

The query below will tell you if Supplemental Logging is turned on at the
database level:  
  

select SUPPLEMENTAL_LOG_DATA_MIN, SUPPLEMENTAL_LOG_DATA_PK,  
SUPPLEMENTAL_LOG_DATA_UI, FORCE_LOGGING from v$database;

  
  
For a particular table, you can find if a Supplemental Log group has been
created for a particular table with the query below. If it returns a row,
Supplemental Logging is turned on. If it returns "no rows selected", then
Supplemental Logging is not turned on.

  
select * from dba_log_groups  
where OWNER='<schema_name_in_upper_case>' and  
TABLE_NAME='<table_name_in_upper_case>';

  
  
For a particular table, you can find which columns are part of the
Supplemental Log group with the query below:  
  

select LOG_GROUP_NAME, COLUMN_NAME, POSITION from  
dba_log_group_columns  
where OWNER='<schema_name_in_upper_case>' and  
TABLE_NAME='<table_name_in_upper_case>'  
order by position;

  
  
For a particular table, you can find out if Supplemental Logging is turned on
through GGSCI with the commands below:  
  

GGSCI> dblogin userid <user>, password <pw>  
GGSCI> info trandata <schema>.<table>  
  
  


---
### NOTE ATTRIBUTES
>Created Date: 2017-11-06 08:13:57  
>Last Evernote Update Date: 2018-10-01 15:59:04  
>author: YangKwong  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=1676907511997  
>source-url: &  
>source-url: id=1059362.1  
>source-url: &  
>source-url: displayIndex=1  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=cnnzq2ypz_141  