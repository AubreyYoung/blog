# How to Compute the Size of a Table containing Outline CLOBs and BLOBs (文档 ID
118531.1)

  

|

|

## Applies to:

Oracle Database - Enterprise Edition - Version 8.0.3.0 and later  
Information in this document applies to any platform.  
***Checked for relevance on 11-Jan-2016***  
***Checked for relevance on 12-Jun-2017***  

## Goal

The purpose of this article is to provide more understanding on the space
usage of tables when using LOBS.

## Solution

A select from the BYTES column in DBA_SEGMENTS for the table shows the table
segment but does not include LOB (CLOB or BLOB) segments sizes.  
  
To caluclate the total size for the table and the associated LOBS segments a
sum of the following must occur:  
  
the bytes for the table => from dba_segments  
+  
the bytes for the LOB segments => from dba_lobs and dba_segments where
segment_type is LOBSEGMENT  
+  
the bytes for the LOB Index (Lob Locator) = from dba_indexes and dba_segments

  
  
The way to accomplish this is to create a SQL file with the following contents
(between the lines):  

==================================================

  
ACCEPT SCHEMA PROMPT 'Table Owner: '  
ACCEPT TABNAME PROMPT 'Table Name: '  
SELECT  
(SELECT SUM(S.BYTES) -- The Table Segment size  
FROM DBA_SEGMENTS S  
WHERE S.OWNER = UPPER('&SCHEMA') AND  
(S.SEGMENT_NAME = UPPER('&TABNAME'))) +  
(SELECT SUM(S.BYTES) -- The Lob Segment Size  
FROM DBA_SEGMENTS S, DBA_LOBS L  
WHERE S.OWNER = UPPER('&SCHEMA') AND  
(L.SEGMENT_NAME = S.SEGMENT_NAME AND L.TABLE_NAME = UPPER('&TABNAME') AND
L.OWNER = UPPER('&SCHEMA'))) +  
(SELECT SUM(S.BYTES) -- The Lob Index size  
FROM DBA_SEGMENTS S, DBA_INDEXES I  
WHERE S.OWNER = UPPER('&SCHEMA') AND  
(I.INDEX_NAME = S.SEGMENT_NAME AND I.TABLE_NAME = UPPER('&TABNAME') AND
INDEX_TYPE = 'LOB' AND I.OWNER = UPPER('&SCHEMA')))  
"TOTAL TABLE SIZE"  
FROM DUAL;  
  

==================================================  

  
**CASE STUDY** (on UNIX)  

$vi lob_table_size.sql  
  
ACCEPT SCHEMA PROMPT 'Table Owner: '  
ACCEPT TABNAME PROMPT 'Table Name: '  
SELECT  
(SELECT SUM(S.BYTES) -- The table segment size  
FROM DBA_SEGMENTS S  
WHERE S.OWNER = UPPER('&SCHEMA') AND  
(S.SEGMENT_NAME = UPPER('&TABNAME'))) +  
(SELECT SUM(S.BYTES) -- The Lob Segment Size  
FROM DBA_SEGMENTS S, DBA_LOBS L  
WHERE S.OWNER = UPPER('&SCHEMA') AND  
(L.SEGMENT_NAME = S.SEGMENT_NAME AND L.TABLE_NAME = UPPER('&TABNAME') AND
L.OWNER = UPPER('&SCHEMA'))) +  
(SELECT SUM(S.BYTES) -- The Lob Index size  
FROM DBA_SEGMENTS S, DBA_INDEXES I  
WHERE S.OWNER = UPPER('&SCHEMA') AND  
(I.INDEX_NAME = S.SEGMENT_NAME AND I.TABLE_NAME = UPPER('&TABNAME') AND
INDEX_TYPE = 'LOB' AND I.OWNER = UPPER('&SCHEMA')))  
"TOTAL TABLE SIZE"  
FROM DUAL;  
  
:wq  
  
$ sqlplus / as sysdba;  
  
create user test identified by test;  
grant DBA to test;  
alter user test default tablespace users;  
connect test/test;  
  
**\-- CREATE THE TABLE FOR THE TEST**  
  
CREATE TABLE TEST_TABLE (a number, b CLOB, c CLOB)  
LOB(b) STORE AS SECUREFILE (DEDUPLICATE retention none CACHE)  
LOB(c) STORE AS SECUREFILE (DEDUPLICATE retention none CACHE);  
  
**\-- INSERT ROWS INTO THE TABLE**  
  
declare  
i number;  
my_insert_b clob;  
my_insert_c clob;  
begin  
for i in 1..5000 loop  
my_insert_b := my_insert_b||'b';  
my_insert_c := my_insert_c||'c';  
end loop;  
for i in 1..1000 loop  
insert into TEST_TABLE values (i,to_char(i)||my_insert_b, my_insert_c);  
end loop;  
commit;  
end;  
/  
  
**\-- EXAMINE THE SEGMENTS CREATED BY THE TABLE AND ITS DEPENDENT SEGMENTS**  
  
COLUMN SEGMENT_NAME FORMAT A32  
COLUMN COLUMN_NAME FORMAT A12  
  
SELECT SEGMENT_NAME, SEGMENT_TYPE, BYTES FROM USER_SEGMENTS;  
  
\-- SEGMENT_NAME SEGMENT_TYPE BYTES  
\-- -------------------------------- ------------------ ----------  
\-- TEST_TABLE TABLE 262144  
\-- SYS_IL0000069158C00002$$ LOBINDEX 589824  
\-- SYS_IL0000069158C00003$$ LOBINDEX 65536  
\-- SYS_LOB0000069158C00002$$ LOBSEGMENT 19070976  
\-- SYS_LOB0000069158C00003$$ LOBSEGMENT 1245184  
  
SELECT SUM(BYTES) FROM USER_SEGMENTS;  
  
\-- SUM(BYTES)  
\-- ----------  
\-- 21233664

**\-- EXAMINE WHICH LOB SEGMENT BELONGS TO WHICH COLUMN IN TEST_TABLE**

SELECT COLUMN_NAME, SEGMENT_NAME  
FROM DBA_LOBS  
WHERE OWNER = 'TEST' AND TABLE_NAME = 'TEST_TABLE'

\-- COLUMN_NAME SEGMENT_NAME  
\-- ------------ --------------------------------  
\-- B SYS_LOB0000069158C00002$$  
\-- C SYS_LOB0000069158C00003$$  
  
\-- THE LOB INDEXES CAN BE ASSOCIATED WITH A COLUMN BY THE NAME OF THE INDEX
WITH REGARD TO THE NAME OF THE LOB SEGMENT  
  
  
  
**\-- EXECUTE THE SCRIPT TO SUM THE LOB STORAGE FOR THE TABLE**  
  
run lob_table_size.sql

\-- Table Owner: test  
\-- Table Name: test_table  
\-- old 4: WHERE S.OWNER = UPPER('&SCHEMA') AND  
\-- new 4: WHERE S.OWNER = UPPER('test') AND  
\-- old 5: (S.SEGMENT_NAME = UPPER('&TABNAME'))) +  
\-- new 5: (S.SEGMENT_NAME = UPPER('test_table'))) +  
\-- old 8: WHERE S.OWNER = UPPER('&SCHEMA') AND  
\-- new 8: WHERE S.OWNER = UPPER('test') AND  
\-- old 9: (L.SEGMENT_NAME = S.SEGMENT_NAME AND L.TABLE_NAME =
UPPER('&TABNAME') AND L.OWNER = UPPER('&SCHEMA'))) +  
\-- new 9: (L.SEGMENT_NAME = S.SEGMENT_NAME AND L.TABLE_NAME =
UPPER('test_table') AND L.OWNER = UPPER('test'))) +  
\-- old 12: WHERE S.OWNER = UPPER('&SCHEMA') AND  
\-- new 12: WHERE S.OWNER = UPPER('test') AND  
\-- old 13: (I.INDEX_NAME = S.SEGMENT_NAME AND I.TABLE_NAME =
UPPER('&TABNAME') AND INDEX_TYPE = 'LOB' AND I.OWNER = UPPER('&SCHEMA')))  
\-- new 13: (I.INDEX_NAME = S.SEGMENT_NAME AND I.TABLE_NAME =
UPPER('test_table') AND INDEX_TYPE = 'LOB' AND I.OWNER = UPPER('test')))  
  
\-- TOTAL TABLE SIZE  
\-- ----------------  
\-- 21233664

  
Explanation  
\-----------  
  
LOBs over approximately 4000 bytes in length are stored "out of line" These
LOBs are assigned to a special LOB segment that is separate from the table
segment.  
  
  
  
---  
  
  



---
### TAGS
{lob}

---
### NOTE ATTRIBUTES
>Created Date: 2017-07-04 09:33:02  
>Last Evernote Update Date: 2018-10-01 15:59:05  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=265905828240244  
>source-url: &  
>source-url: id=118531.1  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=16yaj3xs0g_4  