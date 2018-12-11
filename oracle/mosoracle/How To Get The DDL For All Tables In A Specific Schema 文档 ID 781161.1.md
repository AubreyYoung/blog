# How To Get The DDL For All Tables In A Specific Schema (文档 ID 781161.1)

  

|

|

 **In this Document**  

| |
[Goal](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=88992127495250&id=781161.1&displayIndex=2&_afrWindowMode=0&_adf.ctrl-
state=1aujci0hbj_368#GOAL)  
---|---  
|
[Solution](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=88992127495250&id=781161.1&displayIndex=2&_afrWindowMode=0&_adf.ctrl-
state=1aujci0hbj_368#FIX)  
---|---  
  
* * *

## Applies to:

Oracle Database - Enterprise Edition - Version 10.1.0.2 to 11.2.0.1.0 [Release
10.1 to 11.2]  
Information in this document applies to any platform.  

## Goal

This document explains how to get the DDL for all the tables in a specific
schema using DBMS_METADATA.GET_DDL package / procedure.

## Solution

Connect as the user for which the table DDLs are to be fetched and execute the
following statement.

SET LONG 2000000  
SET PAGESIZE 0  
EXECUTE
DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'STORAGE',false);  
SELECT DBMS_METADATA.GET_DDL('TABLE',u.table_name)  
FROM USER_TABLES u  
WHERE u.nested='NO'  
AND (u.iot_type is null or u.iot_type='IOT');  
EXECUTE
DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'DEFAULT');

* * *  
  
  



---
### TAGS
{DBMS_METADATA}

---
### NOTE ATTRIBUTES
>Created Date: 2017-06-27 09:21:45  
>Last Evernote Update Date: 2018-10-01 15:44:51  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=88992127495250  
>source-url: &  
>source-url: id=781161.1  
>source-url: &  
>source-url: displayIndex=2  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=1aujci0hbj_368#FIX  