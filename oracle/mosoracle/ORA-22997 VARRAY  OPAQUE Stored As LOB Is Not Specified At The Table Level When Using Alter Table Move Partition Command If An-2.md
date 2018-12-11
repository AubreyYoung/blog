# ORA-22997: VARRAY | OPAQUE Stored As LOB Is Not Specified At The Table Level
When Using Alter Table Move Partition Command If An XMLtype Column Stored as
CLOB Is Included (文档 ID 1466014.1)

  

|

|

 **In this Document**  

| |
[Symptoms](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=322895124066435&id=1466014.1&_adf.ctrl-
state=4n68ptb5n_53#SYMPTOM)  
---|---  
|
[Cause](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=322895124066435&id=1466014.1&_adf.ctrl-
state=4n68ptb5n_53#CAUSE)  
---|---  
|
[Solution](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=322895124066435&id=1466014.1&_adf.ctrl-
state=4n68ptb5n_53#FIX)  
---|---  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=322895124066435&id=1466014.1&_adf.ctrl-
state=4n68ptb5n_53#REF)  
---|---  
  
* * *

## Applies to:

Oracle Server - Enterprise Edition - Version 11.2.0.1 and later  
Information in this document applies to any platform.  

## Symptoms

When trying to move a table partition to another tablespace an error is
returned if the table includes an XMLtype column  
stored as CLOB  
  
ORA-22997: VARRAY | OPAQUE stored as LOB is not specified at the table level

## Cause

When moving a partition of a table that has a xmltype column stored as clob
the internal column name created by the system when STORE AS CLOB is  
used during the table creation phase.

The alter statement is executed invoking the column name instead of the real
internal lob column name  

## Solution

To show the solution consider the following testcase.

1.Create the partitioned table

CREATE TABLE part_xml` (ID NUMBER(15), XML_DOC SYS.XMLTYPE, PARTITION_DAY
VARCHAR2(2 BYTE))  
XMLTYPE XML_DOC STORE AS CLOB(  
TABLESPACE USERS)  
TABLESPACE USERS  
PARTITION BY LIST (PARTITION_DAY)  
(  
PARTITION PART_01 VALUES ('01') TABLESPACE USERS,  
PARTITION PART_02 VALUES ('02') TABLESPACE USERS);`

Then:

2\. check the LOB column internal name

`select table_name, column_name, segment_name from user_lobs;  
  
TABLE_NAME COLUMN_NAME SEGMENT_NAME  
---------------- ------------------ ------------------  
PART_XML SYS_NC00003$ SYS_LOB0000089011C00003$$`

  
  
The name that should be used in the ALTER TABLE ... MOVE PARTITION command is
not XML_LOB, but the real internal column lob name :

`alter table part_xml move partition TRAN_LOG_PART_01 tablespace TML_DATA lob
(SYS_NC00003$) store as clob (tablespace TML_LOB);`

To show the solution consider the following testcase.

1.Create the partitioned table

`

CREATE TABLE part_xml

(ID NUMBER(15), XML_DOC SYS.XMLTYPE, PARTITION_DAY VARCHAR2(2 BYTE))  
XMLTYPE XML_DOC STORE AS CLOB(  
TABLESPACE USERS)  
TABLESPACE USERS  
PARTITION BY LIST (PARTITION_DAY)  
(  
PARTITION PART_01 VALUES ('01') TABLESPACE USERS,  
PARTITION PART_02 VALUES ('02') TABLESPACE USERS);

`

  
Then:

2\. check the LOB column internal name

select table_name, column_name, segment_name from user_lobs;  
  
TABLE_NAME COLUMN_NAME SEGMENT_NAME  
\---------------- ------------------ ------------------  
PART_XML SYS_NC00003$ SYS_LOB0000089011C00003$$  
  
The name that should be used in the ALTER TABLE ... MOVE PARTITION is not
XML_LOB, but the real internal column lob name :  
  
alter table part_xml move partition TRAN_LOG_PART_01 tablespace TML_DATA  
lob (SYS_NC00003$) store as clob (tablespace TML_LOB);

## References

[NOTE:310002.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1466014.1&id=310002.1)
\- How to Move a Subpartition that contains a Type Object with LOBs  
  
  
  



---
### TAGS
{lob}

---
### NOTE ATTRIBUTES
>Created Date: 2017-07-05 01:19:33  
>Last Evernote Update Date: 2018-10-01 15:59:05  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=322895124066435  
>source-url: &  
>source-url: id=1466014.1  
>source-url: &  
>source-url: _adf.ctrl-state=4n68ptb5n_53  