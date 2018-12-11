# How To Move Or Rebuild A Lob Partition (文档 ID 761388.1)

  

|

|

 **In this Document**  

| |
[Goal](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=78046905180401&id=761388.1&displayIndex=13&_afrWindowMode=0&_adf.ctrl-
state=jskza6s8s_435#GOAL)  
---|---  
|
[Solution](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=78046905180401&id=761388.1&displayIndex=13&_afrWindowMode=0&_adf.ctrl-
state=jskza6s8s_435#FIX)  
---|---  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=78046905180401&id=761388.1&displayIndex=13&_afrWindowMode=0&_adf.ctrl-
state=jskza6s8s_435#REF)  
---|---  
  
* * *

## Applies to:

Oracle Database - Enterprise Edition - Version 9.2.0.8 to 11.2.0.3 [Release
9.2 to 11.2]  
Information in this document applies to any platform.  
  
  

## Goal

This note will provide the correct syntax to Move or Rebuild a LOB partition.
You will get below error if you use the incorrect syntax :

    
    
    SQL> alter table SHOW_LOB_STORAGE move lob(DDD) 
      2  store as (tablespace PARTFORLOB03); 
    alter table SHOW_LOB_STORAGE move lob(DDD) 
                * 
    ERROR at line 1: 
    ORA-14511: cannot perform operation on a partitioned object

## Solution

The syntax to move a LOB partition is the following.

alter table <table name> move partition <table partition name>  
lob (<lob column name>) store as <optional lob partition name> (tablespace
<lob tablespace name>);

-or-

alter table <table name> move partition <table partition name>  
lob (<lob column name>) store as (tablespace <lob tablespace name>);

A working example.

    
    
    SQL> connect testlob/testlob 
    Connected. 
    
    
    1. Create a partitioned table that contains a LOB.
    
    
    SQL> create table show_lob_storage 
      2  (aaa number(5), 
      3   bbb varchar2(10), 
      4   ccc number(5), 
      5   ddd CLOB ) 
      6  PARTITION BY RANGE(aaa) 
      7  (PARTITION p1 VALUES LESS THAN (50) tablespace part01 
      8     LOB (ddd) STORE AS (tablespace partforlob01), 
      9   PARTITION p2 VALUES LESS THAN (100) tablespace part02 
     10     LOB (ddd) STORE AS (tablespace partforlob02), 
     11   PARTITION p3 VALUES LESS THAN (MAXVALUE) tablespace part03 
     12     LOB (ddd) STORE AS (tablespace partforlob03));
    
    
    Table created.
    
    
    2. Show objects created on DB from above SQL.
    
    
    SQL> set pagesize 10000 
    SQL> col segment_name format a25 
    SQL> col segment_type format a16 
    SQL> col tablespace_name format a13 
    SQL> col partition_name format a15 
    SQL> select segment_name, segment_type, tablespace_name, 
      2  partition_name from user_segments 
      3  order by segment_name, partition_name; 
    
    
    SEGMENT_NAME              SEGMENT_TYPE     TABLESPACE_NA PARTITION_NAME 
    ------------------------- ---------------- ------------- --------------- 
    SHOW_LOB_STORAGE          TABLE PARTITION  PART01        P1 
    SHOW_LOB_STORAGE          TABLE PARTITION  PART02        P2 
    SHOW_LOB_STORAGE          TABLE PARTITION  PART03        P3 
    SYS_IL0000054529C00004$$  INDEX PARTITION  PARTFORLOB01  SYS_IL_P150 
    SYS_IL0000054529C00004$$  INDEX PARTITION  PARTFORLOB02  SYS_IL_P151 
    SYS_IL0000054529C00004$$  INDEX PARTITION  PARTFORLOB03  SYS_IL_P152 
    SYS_LOB0000054529C00004$$ LOB PARTITION    PARTFORLOB01  SYS_LOB_P147 
    SYS_LOB0000054529C00004$$ LOB PARTITION    PARTFORLOB02  SYS_LOB_P148 
    SYS_LOB0000054529C00004$$ LOB PARTITION    PARTFORLOB03  SYS_LOB_P149
    
    
    9 rows selected. 
    
    
    3. Show the partition name corresponding to each LOB partition.
    
    
    SQL> select partition_name, lob_partition_name, tablespace_name 
      2  from user_lob_partitions where table_name = 'SHOW_LOB_STORAGE';  
    
    
    PARTITION_NAME  LOB_PARTITION_NAME             TABLESPACE_NA 
    --------------- ------------------------------ ------------- 
    P1              SYS_LOB_P147                   PARTFORLOB01 
    P2              SYS_LOB_P148                   PARTFORLOB02 
    P3              SYS_LOB_P149                   PARTFORLOB03 
    
    
    4. Move LOB partition SYS_LOB_P147 to tablespace PARTFORLOB3.
    
    
    SQL> alter table SHOW_LOB_STORAGE move partition P1 tablespace PART01 
      2  lob(DDD) store as SYS_LOB_P147 (tablespace PARTFORLOB03);   
    
    
    Table altered. 
    
    
    5. Show location of LOB partition after the move.
    
    
    SQL> select partition_name, lob_partition_name, tablespace_name 
      2  from user_lob_partitions where table_name = 'SHOW_LOB_STORAGE'; 
    
    
    PARTITION_NAME  LOB_PARTITION_NAME             TABLESPACE_NA 
    --------------- ------------------------------ ------------- 
    P1              SYS_LOB_P147                   PARTFORLOB03 
    P2              SYS_LOB_P148                   PARTFORLOB02 
    P3              SYS_LOB_P149                   PARTFORLOB03 
    
    
    6. Show the LOB index partition followed the LOB partition to new tablespace.
    
    
    SQL> select partition_name, tablespace_name, status from user_ind_partitions;  
    
    
    PARTITION_NAME  TABLESPACE_NA STATUS 
    --------------- ------------- -------- 
    SYS_IL_P151     PARTFORLOB02  USABLE 
    SYS_IL_P152     PARTFORLOB03  USABLE 
    SYS_IL_P154     PARTFORLOB03  USABLE
    
    
    7. Syntax if just want to rebuild a LOB partition on the existing tablespace.
    
    
    SQL> alter table SHOW_LOB_STORAGE move partition P2 
      2  lob(DDD) store as (tablespace PARTFORLOB02); 
    
    
    Table altered.
    
    
    Note: The ALTER TABLE...MOVE statement does not permit DML against the table
    while the statement is executing. To leave the table available for DML while
    moving it, use DBMS_REDEFINITION.
    

## References

[NOTE:130814.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=761388.1&id=130814.1)
\- How To Move LOB Data To Another Tablespace  
[NOTE:177407.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=761388.1&id=177407.1)
\- How to Re-Organize a Table Online  
[NOTE:310002.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=761388.1&id=310002.1)
\- How to Move a Subpartition that contains a Type Object with LOBs  
[NOTE:386341.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=761388.1&id=386341.1)
\- How to determine the actual size of the LOB segments and how to free the
deleted/unused space above/below the HWM  
  
  
  



---
### TAGS
{move table}

---
### NOTE ATTRIBUTES
>Created Date: 2017-06-27 06:25:29  
>Last Evernote Update Date: 2018-10-01 15:59:05  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=78046905180401  
>source-url: &  
>source-url: id=761388.1  
>source-url: &  
>source-url: displayIndex=13  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=jskza6s8s_435#FIX  