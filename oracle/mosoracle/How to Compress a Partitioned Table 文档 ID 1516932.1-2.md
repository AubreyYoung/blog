# How to Compress a Partitioned Table (文档 ID 1516932.1)

  

|

|

 **In this Document**  

| |
[Goal](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=75887917231732&id=1516932.1&displayIndex=5&_afrWindowMode=0&_adf.ctrl-
state=jskza6s8s_182#GOAL)  
---|---  
|
[Solution](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=75887917231732&id=1516932.1&displayIndex=5&_afrWindowMode=0&_adf.ctrl-
state=jskza6s8s_182#FIX)  
---|---  
| [Insert with a subquery
method](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=75887917231732&id=1516932.1&displayIndex=5&_afrWindowMode=0&_adf.ctrl-
state=jskza6s8s_182#aref_section21)  
---|---  
| [Create compressed table as
Select](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=75887917231732&id=1516932.1&displayIndex=5&_afrWindowMode=0&_adf.ctrl-
state=jskza6s8s_182#aref_section22)  
---|---  
| [ALTER TABLE MOVE
command](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=75887917231732&id=1516932.1&displayIndex=5&_afrWindowMode=0&_adf.ctrl-
state=jskza6s8s_182#aref_section23)  
---|---  
|
[DBMS_REDEFINITION](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=75887917231732&id=1516932.1&displayIndex=5&_afrWindowMode=0&_adf.ctrl-
state=jskza6s8s_182#aref_section24)  
---|---  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=75887917231732&id=1516932.1&displayIndex=5&_afrWindowMode=0&_adf.ctrl-
state=jskza6s8s_182#REF)  
---|---  
  
* * *

  

## Applies to:

Oracle Database - Enterprise Edition - Version 9.2.0.1 and later  
Information in this document applies to any platform.  

## Goal

The purpose of this document is to provide step by step instructions on how to
compress a big partitioned table with example of various methods available.

## Solution

We can compress a partitioned table in one of the below four ways:  
  
These methods are applicable to a normal table (unpartitioned one) as well.  
  
When doing the reverse of Uncompressing a compressed table, you can use these
methods, the target table being specified 'Nocompress'.  
  
1) INSERT with a subquery method  
  
2) CREATE compressed TABLE AS SELECT  
  
3) ALTER TABLE MOVE command  
  
4) Online table reorganisation using DBMS_REDEFINITION  
  
Here is the table configuration we are going to use in the examples of this
article.

SQL> conn testuser/testuser  
  
SQL> CREATE TABLE big_table_part(  
OBJECT_ID NUMBER(10),  
OBJECT_NAME VARCHAR2(128),  
LAST_DDL_TIME DATE  
)  
PARTITION BY RANGE (OBJECT_ID)  
(  
PARTITION big_table_1 VALUES LESS THAN (25155),  
PARTITION big_table_2 VALUES LESS THAN (50310),  
PARTITION big_table_3 VALUES LESS THAN (MAXVALUE)  
);  
Table created.  
  
SQL> insert into big_table_part select OBJECT_ID,OBJECT_NAME,LAST_DDL_TIME
from dba_objects;  
SQL> insert into big_table_part select * from big_table_part;  
SQL> insert into big_table_part select * from big_table_part;  
SQL> insert into big_table_part select * from big_table_part;  
SQL> /  
SQL> commit;  
Commit complete.  
  
SQL> select SEGMENT_NAME,PARTITION_NAME,SEGMENT_TYPE,BYTES/1024/1024
size_MB,BYTES from dba_segments where OWNER='TESTUSER' order by 1,2;  
  
SEGMENT_NAME PARTITION_NAME SEGMENT_TYPE SIZE_MB BYTES  
\-------------------- -------------------- -------------------- ----------
----------  
BIG_TABLE_PART BIG_TABLE_1 TABLE PARTITION 9 9437184  
BIG_TABLE_PART BIG_TABLE_2 TABLE PARTITION 10 10485760  
BIG_TABLE_PART BIG_TABLE_3 TABLE PARTITION 24 25165824  
  
SQL> select TABLE_NAME,PARTITION_NAME,COMPRESSION,COMPRESS_FOR from
dba_tab_partitions where TABLE_OWNER='TESTUSER' order by 1,2;  
  
TABLE_NAME PARTITION_NAME COMPRESSION COMPRESS_FOR  
\-------------------- -------------------- ------------------------
--------------------  
BIG_TABLE_PART BIG_TABLE_1 DISABLED  
BIG_TABLE_PART BIG_TABLE_2 DISABLED  
BIG_TABLE_PART BIG_TABLE_3 DISABLED  
  
  

Prior to compressing a table, it is necessary to know how much of space saving
it is going to achieve for us.

For this, you need to calculate the compression ratio of the table.

Till release 11.1, The method is given in: Advanced Compression Advisor
(Versions Up To 11.1) ([Doc ID
950293.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1516932.1&id=950293.1))

And for 11.2 and later, you can use the code from How Does Compression Advisor
Work? ([Doc ID
1284972.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1516932.1&id=1284972.1)).  
Please note the code needs to be modified for including the Partition name for
compression.

### Insert with a subquery method

a) Create New table having partitions defined with compress clause

create table BIG_TABLE_PART_COMP(  
OBJECT_ID NUMBER(10),  
OBJECT_NAME VARCHAR2(128),  
LAST_DDL_TIME DATE  
)  
PARTITION BY RANGE (OBJECT_ID)  
(  
PARTITION big_table_1 VALUES LESS THAN (25155) compress,  
PARTITION big_table_2 VALUES LESS THAN (50310) compress,  
PARTITION big_table_3 VALUES LESS THAN (MAXVALUE) compress  
);

Insert into compressed table by selecting from original table. As we have
already specified compress, any new data inserted into the table will be
automatically compressed.

SQL> insert /*+APPEND*/ into BIG_TABLE_PART_COMP select * from BIG_TABLE_PART;  
  
936264 rows created.  
  
SQL> \-- insert into BIG_TABLE_PART_COMP select * from BIG_TABLE_PART;  
SQL> commit;  
  
Commit complete.  
  
SQL> select SEGMENT_NAME,PARTITION_NAME,SEGMENT_TYPE,BYTES/1024/1024
size_MB,BYTES from dba_segments where OWNER='TESTUSER' order by 1,2;  
  
SEGMENT_NAME PARTITION_NAME SEGMENT_TYPE SIZE_MB BYTES  
\-------------------- -------------------- -------------------- ----------
----------  
BIG_TABLE_PART BIG_TABLE_1 TABLE PARTITION 9 9437184  
BIG_TABLE_PART BIG_TABLE_2 TABLE PARTITION 10 10485760  
BIG_TABLE_PART BIG_TABLE_3 TABLE PARTITION 24 25165824  
BIG_TABLE_PART_COMP BIG_TABLE_1 TABLE PARTITION 6 6291456 <\-- compressed  
BIG_TABLE_PART_COMP BIG_TABLE_2 TABLE PARTITION 6 6291456 <\-- compressed  
BIG_TABLE_PART_COMP BIG_TABLE_3 TABLE PARTITION 14 14680064 <\-- compressed

Note we need to insert the data with direct load (insert /*+APPEND*/ or force
parallel DML) in order to get Basic compression to kick in.  
While COMPRESS FOR OLTP compression works on conventional insert as well.  
Direct load can be viewed as LOAD AS SELECT in the execution plan.
Conventional insert appears as LOAD TABLE CONVENTIONAL in the execution plan.

c) Now you can drop the old uncompressed table After keeping a backup of the
same in case needed.

SQL> drop table big_table_part;

d) Rename the compressed table with the original name.

SQL> Alter table BIG_TABLE_PART_COMP rename to BIG_TABLE_PART;

e) Create all dependent objects (index etc ) on the new table. You can also do
this before step (c).

In the example above, we have created the index on the new table
BIG_TABLE_COMP_IND,so I only need to rename the index.

### Create compressed table as Select

a) Create new table with compressed data directly loaded.

SQL> create table BIG_TABLE_PART_COMP_2  
2 PARTITION BY RANGE (OBJECT_ID)  
3 (  
4 PARTITION big_table_1 VALUES LESS THAN (25155) compress,  
5 PARTITION big_table_2 VALUES LESS THAN (50310) compress,  
6 PARTITION big_table_3 VALUES LESS THAN (MAXVALUE) compress  
7 )  
8 as select OBJECT_ID,OBJECT_NAME,LAST_DDL_TIME from BIG_TABLE_PART;  
  
Table created.  
  
SQL> select SEGMENT_NAME,PARTITION_NAME,SEGMENT_TYPE,BYTES/1024/1024
size_MB,BYTES from dba_segments where OWNER='TESTUSER' order by 1,2;  
  
SEGMENT_NAME PARTITION_NAME SEGMENT_TYPE SIZE_MB BYTES  
\------------------------- -------------------- --------------------
---------- ----------  
BIG_TABLE_PART BIG_TABLE_1 TABLE PARTITION 9 9437184  
BIG_TABLE_PART BIG_TABLE_2 TABLE PARTITION 10 10485760  
BIG_TABLE_PART BIG_TABLE_3 TABLE PARTITION 24 25165824  
BIG_TABLE_PART_COMP_2 BIG_TABLE_1 TABLE PARTITION 6 6291456  
BIG_TABLE_PART_COMP_2 BIG_TABLE_2 TABLE PARTITION 6 6291456  
BIG_TABLE_PART_COMP_2 BIG_TABLE_3 TABLE PARTITION 14 14680064  
  
SQL> select TABLE_NAME,PARTITION_NAME,COMPRESSION,COMPRESS_FOR from
dba_tab_partitions where TABLE_OWNER='TESTUSER' order by 1,2;  
  
TABLE_NAME PARTITION_NAME COMPRESSION COMPRESS_FOR  
\------------------------- -------------------- ------------------------
--------------------  
BIG_TABLE_PART BIG_TABLE_1 DISABLED  
BIG_TABLE_PART BIG_TABLE_2 DISABLED  
BIG_TABLE_PART BIG_TABLE_3 DISABLED  
BIG_TABLE_PART_COMP_2 BIG_TABLE_1 ENABLED BASIC  
BIG_TABLE_PART_COMP_2 BIG_TABLE_2 ENABLED BASIC  
BIG_TABLE_PART_COMP_2 BIG_TABLE_3 ENABLED BASIC

b) You can now drop the old table ,rename BIG_TABLE_PART_COMP_2 to
BIG_TABLE_PART and create dependent objects as in the previous method.

### ALTER TABLE MOVE command

A point worth noting here is , in the 3rd method Alter table MOVE, we are NOT
discussing on Alter table table_name compress/nocompress here.

Which ( alter table <table_name> Compress ) will only change the compression
flag of the table and not actually compress/uncompress the data in it.

The change in flag will be applicable only for the new data to be inserted
into the table after the flag is set.  
The existing data size remains unchanged.

Let us walk through the example how ALTER TABLE MOVE works for compression
now.

a) You can not directly operate an Alter table Move at table level for any
partitioned table.

SQL> alter table BIG_TABLE_PART move compress;

alter table BIG_TABLE_PART move compress  
*  
ERROR at line 1:  
ORA-14511: cannot perform operation on a partitioned object

b) This needs to be executed for individual partitions of the table.

SQL> alter table BIG_TABLE_PART move partition BIG_TABLE_1 compress update
indexes;  
  
Table altered.  
  
SQL> alter table BIG_TABLE_PART move partition BIG_TABLE_2 compress  update
indexes;  
  
Table altered.  
  
SQL> alter table BIG_TABLE_PART move partition BIG_TABLE_3 compress  update
indexes;  
  
Table altered.

c) The data size in the partitions are now reduced due to compression. You see
compression is now enabled on the partitions.

SQL> select SEGMENT_NAME,PARTITION_NAME,SEGMENT_TYPE,BYTES/1024/1024
size_MB,BYTES from dba_segments where OWNER='TESTUSER' order by 1,2;  
  
SEGMENT_NAME PARTITION_NAME SEGMENT_TYPE SIZE_MB BYTES  
\------------------------- -------------------- --------------------
---------- ----------  
BIG_TABLE_PART BIG_TABLE_1 TABLE PARTITION 6 6291456  
BIG_TABLE_PART BIG_TABLE_2 TABLE PARTITION 6 6291456  
BIG_TABLE_PART BIG_TABLE_3 TABLE PARTITION 14 14680064  
  
SQL> select TABLE_NAME,PARTITION_NAME,COMPRESSION,COMPRESS_FOR from
dba_tab_partitions where TABLE_OWNER='TESTUSER' order by 1,2;  
  
TABLE_NAME PARTITION_NAME COMPRESSION COMPRESS_FOR  
\------------------------- -------------------- ------------------------
--------------------  
BIG_TABLE_PART BIG_TABLE_1 ENABLED BASIC  
BIG_TABLE_PART BIG_TABLE_2 ENABLED BASIC  
BIG_TABLE_PART BIG_TABLE_3 ENABLED BASIC

ALTER TABLE MOVE changes the rowids of the base tables rows, thus invalidating
any global indexes on the table and any local index partitions that correspond
to the moved table partition, unless the UPDATE INDEXES clause is used in the
ALTER TABLE MOVE statement.

Unusable index (partition) does not consume space in 11.2. Unusable index
(partition) needs to be rebuilt to get usable again.

### DBMS_REDEFINITION

All the above methods described will require your table to be offline for a
period of time.

Hence either of them can be implemeted if a downtime is affordable.

On the other hand, you can use dbms_redefinition method to do it online as
well.  
The table being redefined remains available for queries and DML during the
entire process.  
In order to synchronise the DMLs, SYNC_INTERIM_TABLE procedure can be used
intermittently.

However, there are multiple restrictions associated with online redefinition.

The complete list of restrictions along with redef process steps is available
at :How To Partition Existing Table Using DBMS_Redefinition ([Doc ID
472449.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1516932.1&id=472449.1))

NOTE: If you define the interim table as compressed, then you must use the by-
key method of redefinition, not the by-rowid method.

This method is NOT applicable if your table does Not have a primary key
constraint in it.

Here I am providing a minimum example of dbms_redefinition to achieve
compression for reference.  
Based on more complexity of the table involved, you will need to go through
different manageable scenarios at :

DBMS_REDEFINITION: Case Study for a Large Non-Partition Table to a Partition
Table with Online Transactions occuring ([Doc ID
1481558.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1516932.1&id=1481558.1))  
DBMS_REDEFINITION ONLINE REORGANIZATION OF TABLES ([Doc ID
149564.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1516932.1&id=149564.1))  
<http://docs.oracle.com/cd/E11882_01/server.112/e25494/tables007.htm#autoId8>
( for 11g)

1) Prepare the table with a primary key which needs to be compressed.

CREATE SEQUENCE entry  
START WITH 1  
INCREMENT BY 1  
NOCACHE  
NOCYCLE;  
\-- if you are doing this test on 11.2.0.2 and above on a small database, you
may want to set  
\-- _partition_large_extents" to false, so that the initial extent size for
partition does not outweigh the benefit of compression  
alter session set "_partition_large_extents"=false;  
CREATE TABLE big_table_part(  
OBJECT_ID NUMBER(10),  
OBJECT_NAME VARCHAR2(128),  
LAST_DDL_TIME DATE,  
pk number primary key  
)  
PARTITION BY RANGE (OBJECT_ID)  
(  
PARTITION big_table_1 VALUES LESS THAN (25155),  
PARTITION big_table_2 VALUES LESS THAN (50310),  
PARTITION big_table_3 VALUES LESS THAN (MAXVALUE)  
);  
  
create index BIG_TABLE_PART_IND on BIG_TABLE_PART(OBJECT_ID);  
  
insert into big_table_part select OBJECT_ID,OBJECT_NAME,sysdate, entry.nextval
from dba_objects;  
insert into big_table_part select
OBJECT_ID,OBJECT_NAME,LAST_DDL_TIME,entry.nextval from big_table_part;  
insert into big_table_part select
OBJECT_ID,OBJECT_NAME,LAST_DDL_TIME,entry.nextval from big_table_part;  
insert into big_table_part select
OBJECT_ID,OBJECT_NAME,LAST_DDL_TIME,entry.nextval from big_table_part;  
commit;  
select SEGMENT_NAME,PARTITION_NAME,SEGMENT_TYPE,BYTES/1024/1024 size_MB,BYTES
from dba_segments where OWNER='TESTUSER' order by 1,2;  
  
SQL> select SEGMENT_NAME,PARTITION_NAME,SEGMENT_TYPE,BYTES/1024/1024
size_MB,BYTES from dba_segments where OWNER='TESTUSER' order by 1,2;  
  
SEGMENT_NAME PARTITION_NAME SEGMENT_TYPE SIZE_MB BYTES  
\------------------------- -------------------- --------------------
---------- ----------  
BIG_TABLE_PART BIG_TABLE_1 TABLE PARTITION 10 10485760  
BIG_TABLE_PART BIG_TABLE_2 TABLE PARTITION 12 12582912  
BIG_TABLE_PART BIG_TABLE_3 TABLE PARTITION 27 28311552  
...

  
b) Create Interim table.

CREATE TABLE big_table_part_comp(  
OBJECT_ID NUMBER(10),  
OBJECT_NAME VARCHAR2(128),  
LAST_DDL_TIME DATE,  
PK number primary key  
)  
PARTITION BY RANGE (OBJECT_ID)  
(  
PARTITION big_table_1 VALUES LESS THAN (25155) compress,  
PARTITION big_table_2 VALUES LESS THAN (50310) compress,  
PARTITION big_table_3 VALUES LESS THAN (MAXVALUE) compress  
);  
  
create index BIG_TABLE_PART_IND_comp on BIG_TABLE_PART_comp(OBJECT_ID);  
  
SQL> select TABLE_NAME,PARTITION_NAME,COMPRESSION,COMPRESS_FOR from
dba_tab_partitions where TABLE_OWNER='TESTUSER' order by 1,2;  
  
TABLE_NAME PARTITION_NAME COMPRESSION COMPRESS_FOR  
\------------------------- -------------------- ------------------------
--------------------  
BIG_TABLE_PART BIG_TABLE_1 DISABLED  
BIG_TABLE_PART BIG_TABLE_2 DISABLED  
BIG_TABLE_PART BIG_TABLE_3 DISABLED  
BIG_TABLE_PART_COMP BIG_TABLE_1 ENABLED BASIC  
BIG_TABLE_PART_COMP BIG_TABLE_2 ENABLED BASIC  
BIG_TABLE_PART_COMP BIG_TABLE_3 ENABLED BASIC  
  
6 rows selected.

  
c) Verify if the table can be redefined.

EXEC Dbms_Redefinition.can_redef_table('TESTUSER','BIG_TABLE_PART');

d) Start the redefinition process.

exec
DBMS_REDEFINITION.start_redef_table('TESTUSER','BIG_TABLE_PART','BIG_TABLE_PART_COMP');

e) Copy dependent objects .  
  
Instead of copying dependent objects, you can also create them manually (as
explained in 11g documentation link above).

DECLARE  
num_errors PLS_INTEGER;  
BEGIN  
DBMS_REDEFINITION.COPY_TABLE_DEPENDENTS('TESTUSER','BIG_TABLE_PART','BIG_TABLE_PART_COMP',  
DBMS_REDEFINITION.CONS_ORIG_PARAMS, TRUE, TRUE, TRUE, TRUE, num_errors);  
END;  
/

f) Finish the redefinition.

exec
DBMS_REDEFINITION.FINISH_REDEF_TABLE('TESTUSER','BIG_TABLE_PART','BIG_TABLE_PART_COMP');  
  
SQL> select SEGMENT_NAME,PARTITION_NAME,SEGMENT_TYPE,BYTES/1024/1024
size_MB,BYTES from dba_segments where OWNER='TESTUSER' order by 1,2;  
  
SEGMENT_NAME PARTITION_NAME SEGMENT_TYPE SIZE_MB BYTES  
\------------------------- -------------------- --------------------
---------- ----------  
BIG_TABLE_PART BIG_TABLE_1 TABLE PARTITION 7 7340032 < \---- compressed data
in table BIG_TABLE_PART  
BIG_TABLE_PART BIG_TABLE_2 TABLE PARTITION 7 7340032 < \---- compressed data
in table BIG_TABLE_PART  
BIG_TABLE_PART BIG_TABLE_3 TABLE PARTITION 17 17825792 < \---- compressed data
in table BIG_TABLE_PART  
BIG_TABLE_PART_COMP BIG_TABLE_1 TABLE PARTITION 10 10485760  
BIG_TABLE_PART_COMP BIG_TABLE_2 TABLE PARTITION 12 12582912  
BIG_TABLE_PART_COMP BIG_TABLE_3 TABLE PARTITION 27 28311552

g) Drop the Interim table.

drop table BIG_TABLE_PART_COMP;

h) Rename all the constraints and indexes to match the original names.

alter index BIG_TABLE_PART_IND_COMP rename to BIG_TABLE_PART_IND;

## References

[NOTE:882712.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1516932.1&id=882712.1)
\- All About Advanced Table Compression (Overview, Use, Examples,
Restrictions)  
[NOTE:472449.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1516932.1&id=472449.1)
\- How To Partition Existing Table Using DBMS_REDEFINITION  
[NOTE:1284972.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1516932.1&id=1284972.1)
\- How Does Compression Advisor Work?  
[NOTE:1481558.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1516932.1&id=1481558.1)
\- DBMS_REDEFINITION: Case Study for a Large Non-Partition Table to a
Partition Table with Online Transactions occuring  
[NOTE:149564.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1516932.1&id=149564.1)
\- DBMS_REDEFINITION ONLINE REORGANIZATION OF TABLES  
[NOTE:1461738.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1516932.1&id=1461738.1)
\- How to View Whether Compression Is Set For a Table/Partition and What Type
of Compression  
[NOTE:950293.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1516932.1&id=950293.1)
\- Advanced Compression Advisor (Versions Up To 11.1)  
  
  
  



---
### TAGS
{partition table}

---
### NOTE ATTRIBUTES
>Created Date: 2017-06-27 06:21:28  
>Last Evernote Update Date: 2018-10-01 15:59:05  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=75887917231732  
>source-url: &  
>source-url: id=1516932.1  
>source-url: &  
>source-url: displayIndex=5  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=jskza6s8s_182  