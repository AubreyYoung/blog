# How To Move Partitioned Tables to Another Tablespace When They Contain LOBs
(文档 ID 1388957.1)

  

|

|

 **In this Document**  

| |
[Goal](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=78013241432402&id=1388957.1&displayIndex=5&_afrWindowMode=0&_adf.ctrl-
state=jskza6s8s_337#GOAL)  
---|---  
|
[Solution](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=78013241432402&id=1388957.1&displayIndex=5&_afrWindowMode=0&_adf.ctrl-
state=jskza6s8s_337#FIX)  
---|---  
| [Storage
summary](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=78013241432402&id=1388957.1&displayIndex=5&_afrWindowMode=0&_adf.ctrl-
state=jskza6s8s_337#aref_section21)  
---|---  
| [Find out which segments to move from a
tablespace](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=78013241432402&id=1388957.1&displayIndex=5&_afrWindowMode=0&_adf.ctrl-
state=jskza6s8s_337#aref_section22)  
---|---  
| [TABLE
PARTITION](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=78013241432402&id=1388957.1&displayIndex=5&_afrWindowMode=0&_adf.ctrl-
state=jskza6s8s_337#aref_section23)  
---|---  
|
[Example](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=78013241432402&id=1388957.1&displayIndex=5&_afrWindowMode=0&_adf.ctrl-
state=jskza6s8s_337#aref_section24)  
---|---  
| [TABLE / LOB
SUBPARTITION](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=78013241432402&id=1388957.1&displayIndex=5&_afrWindowMode=0&_adf.ctrl-
state=jskza6s8s_337#aref_section25)  
---|---  
| [DEFAULT
TABLESPACES](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=78013241432402&id=1388957.1&displayIndex=5&_afrWindowMode=0&_adf.ctrl-
state=jskza6s8s_337#aref_section26)  
---|---  
| [INDEX PARTITION and INDEX
SUBPARTITION](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=78013241432402&id=1388957.1&displayIndex=5&_afrWindowMode=0&_adf.ctrl-
state=jskza6s8s_337#aref_section27)  
---|---  
| [Restrictions on INDEX REBUILD
](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=78013241432402&id=1388957.1&displayIndex=5&_afrWindowMode=0&_adf.ctrl-
state=jskza6s8s_337#aref_section28)  
---|---  
| [Notes on nested
tables](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=78013241432402&id=1388957.1&displayIndex=5&_afrWindowMode=0&_adf.ctrl-
state=jskza6s8s_337#aref_section29)  
---|---  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=78013241432402&id=1388957.1&displayIndex=5&_afrWindowMode=0&_adf.ctrl-
state=jskza6s8s_337#REF)  
---|---  
  
* * *

  

## Applies to:

Oracle Database - Enterprise Edition - Version 11.2.0.1 and later  
Information in this document applies to any platform.  

## Goal

Sometimes it may become necessary to move objects (or part of an object, for
example: partitions) to another tablespace. One such reason is to be able to
drop a tablespace (which needs to be empty to do so).

This article explains how to move segments to another tablespace, including:

  * a table _partition_ or _sub-partition_
  * a table's LOB column storage
  * a _partitioned_ or _sub-partitioned_ table LOB column storage for any given partition or sub-partition
  * an index
  * an index _partition_ or _sub-partition_

## Solution

First, review the following articles:

  * How To Move All Tables From One User To Another Tablespace (Doc ID 158162.1)
  * How to move LOB Data to Another Tablespace when the Table also contains a LONG column (Doc ID 453186.1)

### Storage summary

Oracle stores data for tables and indexes in so called _segments._ For each
segment, it is possible to specify a _tablespace_ into which the segment
should be stored. In other words, the storage required for that segment will
be allocated in datafiles belonging to that tablespace.

A tablespace can hold more than one segment.

The type of segments this article deals with are:

  * an unpartitioned table (or index) holds all its data in a single segment, _including_ in-row LOBs, but not other LOBs.
  * each LOB column of an unpartitioned table that is _not stored in-row_ occupies its own segment. The tablespace used for the segment can be specified using the **STORE AS** clause.
  * for a _partitioned_ (but not _sub-_ partitioned table, each partition requires the same number of segments as an unpartitioned table would. That is to say, for each partition, you require a segment for regular column data (and in-row LOBs) _plus_ a segment for each LOB that is not stored in-row. Note that there is **no segment** allocated for the table itself, as all data must belong to exactly one table partition. However, you can declare a **default tablespace** at the **table level**. This tablespace is used if you do not speciy a tablespace explicitly for any segment on the partition level.
  * for a _sub-partitioned_ table, each sub-partition requires the same number of segments as an unpartitioned table would. For each sub-partition, you require a segment for regular column data (including in-row LOBs) _plus_ a segment for each LOB that is not stored in-row. Note that the total number of sub-partitions is equal to the number of partitions in the table _times_ the number of sub-partitions in each partition. No segment is allocated at the partition or table level. However, you can declare a **default tablespace** at the **partition and/or table level**. It will be used if the sub-partition does not explicitly state a tablespace. If a partition does not declare a default, then the default tablespace declared at the table level will be used. If none is declared there either, the _user's_ default tablespace will be used instead.

Example:

A table with two (not in-row) LOB columns uses three segments (one for each
LOB column, the third for the rest of the columns).

If such a table were partitioned by LIST partitioning into 5 partitions, then
the entire table would result in 15 segments, (3 segments for each of the 5
partitions) each potentially on a different tablespace (however, segments can
reside in the same tablespace if desired). The table itself would not occupy a
segment / tablespace.

If we further sub-partition the table using a 8 subpartitions (using HASH),
then we would have 120 segments (8 subpartitions for 5 partitions at 3
segments). Now data is only stored on the sub-partition level, no segments are
used on the partition or table level.

### Find out which segments to move from a tablespace

Query to locate all objects that have a segment in a given tablespace  
  

SELECT UNIQUE segment_name, partition_name, segment_type,  
from dba_segments  
where tablespace_name = 'name-of-tablespace';

  
For LOB PARTITION segments, find the exact name of the LOB column, and its
partitioned object that it belongs to:

  

SELECT OWNER, TABLE_NAME, COLUMN_NAME, SEGMENT_NAME, TABLESPACE_NAME,
INDEX_NAME, PARTITIONED  
FROM DBA_LOBS  
WHERE TABLESPACE_NAME = 'name-of-tablespace ';

For an index partition, check:  
  

SELECT p.INDEX_OWNER, p.INDEX_NAME, p.PARTITION_NAME, p.TABLESPACE_NAME,
i.TABLE_NAME, i.COLUMN_NAME  
FROM DBA_IND_PARTITIONS p, ALL_IND_COLUMNS i  
WHERE p.TABLESPACE_NAME = 'AUDIT_DATOS_2012';  
AND p.INDEX_NAME = i.INDEX_NAME  
AND p.INDEX_OWNER = i.INDEX_OWNER;

  
How to move segments to a different tablespace

The syntax for moving segments of partitioned tables can be summarized as
this:

  

  * Use the ALTER TABLE MOVE command to indicate you want to move existing data.
  * Use the PARTITION or SUBPARTITION clause to identify WHAT to move.
  * If you want to move just LOB columns, use the "LOB" clause to identify the LOB column to move and the "STORE AS" to indicate WHERE to move it.
  * If you want to move non-LOB data, use the TABLESPACE clause to identify WHERE to move the segment
  * You can combine moving LOB and non-LOB segment moves, even if they are going to different tablespaces.
  * Index partitions cannot simply be moved, but have to be rebuilt in the new tablespace

  
Some more details:  
  

#### TABLE PARTITION

  
A single partition can be moved to a different tablespace unless it contains
subparttitiuons (see below)  
  
If you would like to move more than one partition, need to repeat the command
for each partition.  
  

SQL> alter table "table-name" move partition "partition-name" tablespace "new-
tablespace" [UPDATE GLOBAL INDEXES];  
or  
SQL> alter table "table-name" move partition for "value" tablespace "new-
tablespace" [UPDATE GLOBAL INDEXES];

  
If the table contains LOB columns, then you can use the "LOB" clause to move
the LOB data and index segments associated with this partition:  
  

SQL> alter table "table-name" move partition "partition-name" LOB ("column-
name",...) store as ( tablespace "new-tablespace" );

  
Here as well, you can use the "FOR" keyword to identify the partition by value
rather than name.  
  
Only the LOBs named are affected. If you do not specify the LOB_storage_clause
for a particular LOB column, then its LOB data and LOB index segments are not
moved.

Note that this does **not apply** to LOBs that are stored in-line, ie. with
the row data itself. This can be seen in the DDL for the object: If it uses
the clause **STORE AS (ENABLE STORAGE IN ROW ....)** , then the LOB is stored
in-line and cannot be moved to a different tablespace independently.

  
Once you have completed moving partitions to a different tablespace, you may
want to consider changing the **default tablespace** for that table as well.
If you plan on creating new partitions without providing an explicit
tablespace each time, the default tablespace for that table is picked (or, if
none is declared, the _user's_ default tablespace is being used).

To change the table default tablespace, use a command like this:

SQL> ALTER TABLE "table-name" MODIFY DEFAULT ATTRIBUTES TABLESPACE "new
tablespace";

##### Example

SQL> alter table "bigtable" move partition for "JAN2012" store as ( tablespace
"BIGGER_TBS" )  
(if all rows for "JAN2012" of the key column should be moved)

  
Note that you can _combine_ the change of tablespace for LOB columns with the
change of tablespace for the regular columns of the partition:  
  

alter table "table-name" move partition for "value" tablespace "new-tbs" lob
("column-name",...) store as ( tablespace "new-tablespace" )  
The non-lob data and the a lob column for that partition are moved to
tablespace new-tbs and new-tablespace, respectively.

  

#### TABLE / LOB SUBPARTITION

To move individual subpartitions, a _sub-partition within a specific
partition_ needs to be identified (by subpartition name).  
  

SQL> ALTER TABLE "table-name" MOVE SUBPARTITION "subpartition " TABLESPACE
"new-tablespace";

  
Again, for LOB SUB-PARTITIONS, you can use the same syntax as for PARTITION
move above, just replace the word "PARTITION" with "SUBPARTITION". Keepin mind
that this does **not apply** to LOBs that are stored _in-line_ , as explained
above.

#### DEFAULT TABLESPACES

Once you have completed moving sub-partition segments to another tablespace,
also review the **default tablespace** of the affected sub-partitions. When a
new sub-partition is created _without specifying a tablespace_ , the segment
is placed in one of the following (sorted by precedence, highest first):

  * the tablespace declared for the corresponding _parent partition_ , if one is declared.
  * the tablespace declared for the table, if one is declared
  * the default tablespace declared for the _user_ executing the command.

For example, let's assume you would like to move all sub-partitions to a new
tablespace in order to drop the old tablespace. Once all sub-partitions have
been moved to the new tablespace, confirm (and adjust) the default tablespace
for all partitions, the default tablespace for the table itself, as well as
any default tablespace for users. Only after this has been done, drop the old
tablespace.

Although no segments may be stored in such a tablespace once all sub-
partitions have been moved, referencing a non-existant tablespace in an object
DDL can cause problems when creating new segments (ie. sub-partitions)

To change the default tablespace for a single partition, use the following
command:

SQL> ALTER TABLE "table-name" MODIFY DEFAULT ATTRIBUTES FOR PARTITION
"partition-name" TABLESPACE "new tablespace";

This command changes the default tablespace for a single partition and has to
be repeated for all partitions that require adjustment.

If you do not know the name of the partition (for example, because you are
using _interval partitioning_ ), you may use the _extended partition syntax_
and identify the partition by _partition key value(s)_ , like this:

SQL> ALTER TABLE "table-name" MODIFY DEFAULT ATTRIBUTES FOR PARTITION FOR
(value, ...) TABLESPACE "new tablespace";

where "value" is _any_ value (combination) of the partition column((s) that
uniquely identifies a partition. You may need to provide a list of partition
key values if you use multi-column partition keys. Of course, such syntax is
not available for HASH partitions, as the partition cannot be identified by a
partition key value in such a s case.

Once you have changed the default tablespace for partitions, you should also
evaluate if you need to change the default tablespace for the entire table,
which can be accomplished using:

SQL> ALTER TABLE "table-name" MODIFY DEFAULT ATTRIBUTES TABLESPACE "new
tablespace";

#### INDEX PARTITION and INDEX SUBPARTITION

  
You cannot directly "move" an index / index partition / index sub-partition to
another tablespace. Instead, it has to be rebuilt:  
  
To rebuild an index on a different tablespace, proceed with one of the
following:  
  
If the Index uses sub-partitions, execute:  
  

SQL> alter index <owner>.<index-name> rebuild subpartition <sub-partition-
name> tablespace <new-tablespace>;

  
If the index uses partitions (but no sub-partitions), execute:  
  

SQL> alter index <owner>.<index-name> rebuild partition <partition-name>
tablespace <new-tablespace>;

  
These commands have to executed on each partition / sub-partition.

#### Restrictions on INDEX REBUILD

(for more details see the Oracle 11.2 reference on "ALTER INDEX"):  
  
\- You cannot rebuild an index on a temporary table.  
\- You cannot rebuild a bitmap index that is marked INVALID. Instead, you must
drop and then re-create it.  
\- You cannot rebuild an entire partitioned index. You must rebuild each
partition or subpartition, as described for the PARTITION clause.  
\- You cannot specify the deallocate_unused_clause in the same statement as
the rebuild_clause.  
\- You cannot change the value of the PCTFREE parameter for the index as a
whole (ALTER INDEX) or for a partition (ALTER INDEX ... MODIFY PARTITION). You
can specify PCTFREE in all other forms of the ALTER INDEX statement.  
\- You cannot rebuild a local index, but you can rebuild a partition of a
local index (ALTER INDEX ... REBUILD PARTITION).  
\- You cannot rebuild an online index that is used to enforce a deferrable
unique constraint.  
  
Notes Regarding LOBs:

  

For any LOB columns you specify in a move_table_clause:  
Oracle Database drops the old LOB data segment and corresponding index segment
and creates new segments, even if you do not specify a new tablespace.

  

If the LOB index in table resided in a different tablespace from the LOB data,
then Oracle Database collocates the LOB index in the same tablespace with the
LOB data after the move

  

#### Notes on nested tables

For nested tables (starting in 10g), you can use similar syntax as you would
for LOB columns:  
  

ALTER TABLE ,,, MOVE PARTITION "partition" NESTED TABLE name|COLUMN_VALUE
STORE AS ( TABLESPACE "new-tablespace") .;

  
Only the nested table items named are affected. If you do not specify the
nested_table_col_properties clause of the table_partition_description for a
particular nested table column, then its segments are not moved.

## References

[NOTE:761388.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1388957.1&id=761388.1)
\- How To Move Or Rebuild A Lob Partition  
[NOTE:177407.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1388957.1&id=177407.1)
\- How to Re-Organize a Table Online  
  
  
  



---
### TAGS
{move table}

---
### NOTE ATTRIBUTES
>Created Date: 2017-06-27 06:27:08  
>Last Evernote Update Date: 2018-10-01 15:44:51  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=78013241432402  
>source-url: &  
>source-url: id=1388957.1  
>source-url: &  
>source-url: displayIndex=5  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=jskza6s8s_337  