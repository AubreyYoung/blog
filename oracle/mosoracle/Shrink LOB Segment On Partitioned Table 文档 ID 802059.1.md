# Shrink LOB Segment On Partitioned Table (文档 ID 802059.1)

  

|

|

 **In this Document**  

| |
[Goal](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=78039046741348&id=802059.1&displayIndex=20&_afrWindowMode=0&_adf.ctrl-
state=jskza6s8s_386#GOAL)  
---|---  
|
[Solution](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=78039046741348&id=802059.1&displayIndex=20&_afrWindowMode=0&_adf.ctrl-
state=jskza6s8s_386#FIX)  
---|---  
|
[Restriction](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=78039046741348&id=802059.1&displayIndex=20&_afrWindowMode=0&_adf.ctrl-
state=jskza6s8s_386#aref_section21)  
---|---  
| [Known
Issues](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=78039046741348&id=802059.1&displayIndex=20&_afrWindowMode=0&_adf.ctrl-
state=jskza6s8s_386#aref_section22)  
---|---  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=78039046741348&id=802059.1&displayIndex=20&_afrWindowMode=0&_adf.ctrl-
state=jskza6s8s_386#REF)  
---|---  
  
* * *

## Applies to:

Oracle Database - Enterprise Edition - Version 10.2.0.1 and later  
Information in this document applies to any platform.  

## Goal

This document gives instructions for how to shrink LOB segments in a
partitioned table.

Note: Before shrinking a LOB segment, please review the known issues at the
bottom of the note and make sure your RDBMS version is not affected.

## Solution

Create a partitioned table that contains a LOB segment:

> create table part ( id number,address clob)  
>  partition by range (id)  
>  (  
>  partition p1 values less than (10),  
>  partition p2 values less than (20),  
>  partition p_max values less than (maxvalue)  
>  );

  
Shrink all LOB segments in a partitioned table:

> alter table part modify lob (address) (shrink space cascade);

  
Shrink LOB segments for a single partition:

> alter table part modify partition p1 lob (address) (shrink space cascade);

### Restriction

In 11g and above only BasicFiles LOBs can be shrunk the SHRINK option is not
supported for SecureFiles LOBs as documentation (Oracle Database SecureFiles
and Large Objects Developer's Guide) states.

An alternative is to use DBMS_REDEFINITION, see [Document
1394613.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=802059.1&id=1394613.1)
HOW TO SHRINK A SECUREFILE LOB USING ONLINE REDEFIITION (DBMS_REDEFINITION)?
for more details.

### Known Issues

These were the known issues with shrinking LOBS at the time this note was
written (May 2009). If you have an RDBMS version that is affected by one of
these bugs, before shrinking LOBs, you should either (1) apply the patchset in
which the issue is fixed, when available for your OS platform, (2) apply a
one-off patch, if available, or (3) use the workaround, if available.

  * [Bug 5768710](https://support.oracle.com/epmos/faces/BugDisplay?parent=DOCUMENT&sourceId=802059.1&id=5768710)  
Abstract: ALTER TABLE SHRINK slow with LOB  
Fixed-Releases: 10.2.0.5 11.1.0.6 WIN:10.2.0.3 P13  
Details:  
ALTER TABLE ... SHRINK SPACE CASCADE can take a very long time on a table with
LOB columns.

  * [Bug 5636728](https://support.oracle.com/epmos/faces/BugDisplay?parent=DOCUMENT&sourceId=802059.1&id=5636728)  
Abstract: LOB corruption / ORA-1555 when reading LOBs after a SHRINK operation  
Fixed-Releases: 10.2.0.4 11.1.0.6 WIN:10.2.0.2 P14 WIN:10.2.0.2 P15
WIN:10.2.0.3 P09  
Details:  
After shrinking an ENABLE STORAGE IN ROW LOB column selecting the LOB may fail
with ORA-1555 / ORA-22924 errors .  
Workaround:  
Avoid using SHRINK on tables with LOB columns

## References

[BUG:5636728](https://support.oracle.com/epmos/faces/BugDisplay?parent=DOCUMENT&sourceId=802059.1&id=5636728)
\- FALSE ORA-1555 WHEN READING LOBS AFTER SHRINK  
[BUG:5768710](https://support.oracle.com/epmos/faces/BugDisplay?parent=DOCUMENT&sourceId=802059.1&id=5768710)
\- 'ALTER TABLE SHRINK' ON A TABLE W/ A LOB SLOW DOWN AFTER THE FIRST DAY.  
[NOTE:1029252.6](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=802059.1&id=1029252.6)
\- How to Resize a Datafile  
  
  
  



---
### TAGS
{partition table}

---
### NOTE ATTRIBUTES
>Created Date: 2017-06-27 06:25:05  
>Last Evernote Update Date: 2018-10-01 15:44:51  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=78039046741348  
>source-url: &  
>source-url: id=802059.1  
>source-url: &  
>source-url: displayIndex=20  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=jskza6s8s_386  