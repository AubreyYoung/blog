# LOB Segment Partition In Its Own Tablespace (文档 ID 2209442.1)

  

|

|

 **In this Document**  

| |
[Goal](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=78070371482389&id=2209442.1&displayIndex=26&_afrWindowMode=0&_adf.ctrl-
state=jskza6s8s_484#GOAL)  
---|---  
|
[Solution](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=78070371482389&id=2209442.1&displayIndex=26&_afrWindowMode=0&_adf.ctrl-
state=jskza6s8s_484#FIX)  
---|---  
  
* * *

  

## Applies to:

Oracle Database - Enterprise Edition - Version 11.2.0.4 and later  
Information in this document applies to any platform.  

## Goal

LOBs, or Large OBjects, are used to store non-character data, such as mp3s,
videos, pictures and long character data. This LOB segment can be created in a
separate tablespace.

This note will provide the command to create each LOB segment in its own
tablespace in case of partitioned table..  
  

## Solution

An example:

SQL> create table  
2 pos_data (  
3 start_date DATE,  
4 inventory_id NUMBER,  
5 inventory_info BLOB  
6 )  
7 PARTITION BY RANGE (start_date)  
8 INTERVAL(NUMTOYMINTERVAL(1, 'MONTH')) STORE IN (JAN_TS,FEB_TS,MAR_TS,APR_TS)  
9 (  
10 PARTITION pos_data_jan VALUES LESS THAN (TO_DATE('1-2-2007', 'DD-MM-YYYY'))
TABLESPACE JAN_TS  
11 LOB(inventory_info) STORE AS (TABLESPACE JAN_TS_LOB ),  
12 PARTITION pos_data_feb VALUES LESS THAN (TO_DATE('1-3-2007', 'DD-MM-YYYY'))
TABLESPACE FEB_TS  
13 LOB(inventory_info) STORE AS (TABLESPACE FEB_TS_LOB )  
14 );  
  
  



---
### TAGS
{partition table}

---
### NOTE ATTRIBUTES
>Created Date: 2017-06-27 06:26:31  
>Last Evernote Update Date: 2018-10-01 15:59:05  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=78070371482389  
>source-url: &  
>source-url: id=2209442.1  
>source-url: &  
>source-url: displayIndex=26  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=jskza6s8s_484#GOAL  