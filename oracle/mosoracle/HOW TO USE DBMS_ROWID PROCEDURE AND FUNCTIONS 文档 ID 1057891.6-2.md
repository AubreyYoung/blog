# HOW TO USE DBMS_ROWID PROCEDURE AND FUNCTIONS (文档 ID 1057891.6)

  

|

|

## Applies to:

PL/SQL - Version 10.1.0.2 and later  
Oracle Database - Enterprise Edition - Version 10.1.0.2 and later  
Information in this document applies to any platform.  
***Checked for relevance on 8th Apr 2016***

## Purpose

 Demonstrate the use of PLSQL supplied package DBMS_ROWID

## Details

The DBMS_ROWID package allows rowid manipulation from SQL statements. The
source for this package is in "dbmsutil.sql", which is called by
"catproc.sql". The script creates a public synonym matching the package name
and grants execute privilege to public.  
      
The following examples will use the following rowid:  
  
  

SQL> select substr(rowid,1,6) "object", substr(rowid,7,3) "file",
substr(rowid,10,6) "block", substr(rowid,16,3) "row" from test;

  
  
        object fil block  row  
        \------ --- ------ ---  
        AAABPW AAF AAAAv1 AAA  
  
  
 **DBMS_ROWID.ROWID_BLOCK_NUMBER:** returns the block number of a rowid.  
  
   Header:  
 ** **  
 **    function dbms_rowid.rowid_block_number  (row_id in rowid)  return
number**  
  
  

SQL> select dbms_rowid.rowid_block_number(rowid) "block" from test;

  
  
        block  
        \-----  
        3061  
  
  
 **DBMS_ROWID.ROWID_CREATE:** Creates and returns a rowid based on the
individual row components.   The type of rowid to be created is either
ROWID_TYPE_RESTRICTED (0) or ROWID_TYPE_EXTENDED (1).  This function should
be used for test purposes ONLY.  Only Oracle Server can create a valid rowid
that points to data in a database.  
  
  ** ** Header:  
 ** **  
 **    function dbms_rowid.rowid_create  (rowid_type in number , object_number
in number , relative_fno in number , block_number in number, row_number in
number)  return rowid**  
  
  

SQL> /* Create a restricted rowid */  
  
SQL> select dbms_rowid.rowid_create(0,5078,5,3061,0) from dual;  


  
        DBMS_ROWID.ROWID_C  
        \------------------  
        00000BF5.0000.0005  
  
  


SQL> /* Create an extended rowid */  
  
SQL> select dbms_rowid.rowid_create(1,5078,5,3061,0) from dual;  


  
        DBMS_ROWID.ROWID_C  
        \------------------  
        AAABPWAAFAAAAv1AAA  
  
  
 **DBMS_ROWID.ROWID_INFO:** returns individual components of a specified
rowid.   This procedure can NOT be used in a SQL statement (must use PL/SQL).  
  
   Header:  
  
    procedure dbms_rowid.rowid_info  (rowid_in in rowid, rowid_type out number, object_number out number, relative_fno out number, block_number out number, row_number out number)   
  
  

SQL> set serverout on  
SQL> set echo on  
  
SQL> declare  
my_rowid rowid;  
rowid_type number;  
object_number number;  
relative_fno number;  
block_number number;  
row_number number;  
begin  
  my_rowid :=dbms_rowid.rowid_create(1,5078,5,3061,0);  
  dbms_rowid.rowid_info(my_rowid, rowid_type, object_number,  
  relative_fno, block_number, row_number);  
  dbms_output.put_line('ROWID:   ' || my_rowid);  
  dbms_output.put_line('Object#:      ' || object_number);  
  dbms_output.put_line('RelFile#:     ' || relative_fno);  
  dbms_output.put_line('Block#:       ' || block_number);  
  dbms_output.put_line('Row#:         ' || row_number);  
end;  
/  


  
   ROWID: AAABPWAAFAAAAv1AAA  
   Object#:  5078  
   RelFile#: 5  
   Block#:   3061  
   Row#:     0  
  
  
 **DBMS_ROWID.ROWID_OBJECT:** returns the object number of a rowid.
ROWID_OBJECT_UNDEFINED (0) is returned for restricted rowids.  
  
  ** ** Header:  
 ** **  
 **    function dbms_rowid.rowid_object (row_id in rowid)  return number**  


/* If extended format, dbms_rowid.rowid_object returns the object#. */  
  
SQL> select dbms_rowid.rowid_object(rowid) "object" from test;

  
         object  
         \------  
         5078  
  


/* If restricted format rowid, dbms_rowid.rowid_object returns 0. */  
  
SQL> select dbms_rowid.rowid_object(dbms_rowid.rowid_to_restricted(rowid,0))
"object" from test;

    
        object  
        \------  
          0  
  
  
 **DBMS_ROWID.ROWID_RELATIVE_FNO:** returns the relative file number of a
rowid.   The file number is relative to the tablespace.  
  
 **   ** Header:  
  
   **function dbms_rowid.rowid_relative_fno (row_id in rowid)   return
number**  
  
  

SQL> select dbms_rowid.rowid_relative_fno(rowid) "relative fno" from test;  


  
        relative fno  
        \------------  
           5  
  
  
 **DBMS_ROWID.ROWID_ROW_NUMBER:** returns the row number of a rowid.  
  
   Header:  
 ** **  
 **    function dbms_rowid.rowid_row_number  (row_id in rowid)  return
number**  
  
/* Row numbers start counting at zero. */  
  
  

SQL> select dbms_rowid.rowid_row_number(rowid) "row"  from test;

  
        row  
        \---  
         0  
  
  
 **DBMS_ROWID.ROWID_TO_ABSOLUTE_FNO:** returns the absolute file number of a
rowid.  Although DBMS_ROWID.ROWID_VERIFY provides default values for schema
and object, this function will result in ORA-942 and ORA-6512 if NULL is  used
for either argument.  
  
   Header:  
 ** **  
 **    function dbms_rowid.rowid_to_absolute_fno (rowid in rowid, schema_name
in varchar2, object_name in varchar2)  return number**  
  
  

SQL> select dbms_rowid.rowid_to_absolute_fno  (rowid, 'SCHEMA_A', 'TEST')
"absolute fno"  from test;

  
  
        absolute fno  
        \------------  
           5  
  
  
  
 **DBMS_ROWID.ROWID_TO_EXTENDED:** converts a restricted rowid to an extended
rowid.   The conversion type is ROWID_CONVERT_INTERNAL (0) if the original
rowid was stored in a column of type ROWID or ROWID_CONVERT_EXTERNAL (1) if
the original rowid was stored as a character string.  Both the schema and
object name will default to the current object and schema if NULL.  
  
   Header:  
 ** **  
 **    function dbms_rowid.rowid_to_extended (old_rowid in rowid, schema_name
in varchar2, object_name in varchar2, conversion_type in integer)  return
rowid**  
 ** **

/* Convert a restricted internal rowid to extended format. */  
  
   SQL> select dbms_rowid.rowid_to_extended
(dbms_rowid.rowid_to_restricted(rowid,0),'SCHEMA_A','TEST',0) "extended rowid"
from test;

  
        extended rowid  
        \--------------  
        AAABPWAAFAAAAv1AAA  


/* Demonstrate success if schema and object NULL. */  
  
   SQL> select dbms_rowid.rowid_to_extended
(dbms_rowid.rowid_to_restricted(rowid,0),null,null,0) "extended rowid" from
test;

  
  
        extended rowid  
        \--------------  
        AAABPWAAFAAAAv1AAA  


/* Convert a restricted external rowid to extended format. */  
  
   SQL> select dbms_rowid.rowid_to_extended
('00000BF5.0000.0005','SCHEMA_A','TEST',1) from dual;  


  
        DBMS_ROWID.ROWID_T  
        \------------------  
        AAABPWAAFAAAAv1AAA  
  
  
 **DBMS_ROWID.ROWID_TO_RESTRICTED:** converts an extended rowid (Oracle8) to a
restricted rowid (Oracle7 format).   The restricted row format is
BBBBBBB.RRRR.FFFFF, where BBBBBBB is the block and RRRR is the row in the
block (first row is zero) and FFFFF is the file number.  The package accepts
as input the rowid and the rowid conversion type.  ROWID_CONVERT_INTERNAL (0)
and ROWID_CONVERT_EXTERNAL (1) are constants defined by the DBMS_ROWID
package.  
  
  Header:  
  
   function dbms_rowid.rowid_to_restricted (old_rowid in rowid,
conversion_type in integer) return rowid  
  
  

SQL> select dbms_rowid.rowid_to_restricted(rowid, 1) "restricted rowid" from
test;

  
        restricted rowid  
        \----------------  
        00000BF5.0000.0005  
  
  
     

NOTE: In base 16: B*16^2 + F*16^1 + 5*16^0 = 11*256 + 15*16 +5 = 3061

  
  
 **DBMS_ROWID.ROWID_TYPE:** returns the type of a rowid, either
ROWID_TYPE_RESTRICTED (0) or ROWID_TYPE_EXTENDED (1).  
  
   Header:  
 ** **  
 **    function dbms_rowid.rowid_type (row_id in rowid) return number;**  
 ** **

/* Oracle8 rowids are extended format*/  
  
SQL> select dbms_rowid.rowid_type(rowid) "type" from test;

  
  
       type  
       \----  
         1  


/* Oracle7-style rowids are restricted format. */  
  
SQL> select dbms_rowid.rowid_type( chartorowid('00000BF5.0000.0005')) "type"
from dual;

  
  
        type  
        \----  
         0  
  
  
 **DBMS_ROWID.ROWID_VERIFY:** verifies that a restricted rowid can be
converted to extended format.   The function returns either ROWID_VALID (0) or
ROWID_INVALID (1).  The conversion type is either ROWID_CONVERT_INTERNAL (0)
if original rowid is stored in a column of type ROWID or
ROWID_CONVERT_EXTERNAL if original rowid is stored as a character string.  Per
reference in Oracle8 Server Application Developer's Guide - this function can
be used to find bad rowids before conversion using
DBMS_ROWID.ROWID_TO_EXTENDED (the example in the text is not correct -
corrected version provided).  Both the schema and object will default to the
current schema and object if NULL.  
  
  Header:  
 ** **  
 **    function dbms_rowid.rowid_verify (rowid_in in rowid, schema_name in
varchar2, object_name in varchar2, conversion_type in integer) return number**  


/* Insert a valid restricted rowid. */  
  
   SQL> update test set rowid_col = dbms_rowid.rowid_create(0,55706,4,444,0);  
  
/* Select where conversion from restricted to extended will fail. */  
  
   SQL> select rowid, rowid_col from test where
dbms_rowid.rowid_verify(rowid_col,null,null,0) = 1;

  

  


        no rows selected

  

  

  

  

  

SQL> set serverout on

SQL> set echo on

  

SQL> declare

my_rowid rowid;

rowid_type number;

object_number number;

relative_fno number;

block_number number;

row_number number;

begin

  my_rowid :=dbms_rowid.rowid_create(1,5078,5,3061,0);

  dbms_rowid.rowid_info(my_rowid, rowid_type, object_number,

  relative_fno, block_number, row_number);

  dbms_output.put_line('ROWID:   ' || my_rowid);

  dbms_output.put_line('Object#:      ' || object_number);

  dbms_output.put_line('RelFile#:     ' || relative_fno);

  dbms_output.put_line('Block#:       ' || block_number);

  dbms_output.put_line('Row#:         ' || row_number);

end;

/'

  

  

select

 rowid,

 dbms_rowid.rowid_relative_fno(rowid)rel_fno,

 dbms_rowid.rowid_block_number(rowid)blockno,

 dbms_rowid.rowid_row_number(rowid) rowno

 from emp_temp;

  

  

select a.rowid,a.* from scott.bh a where rowid like '%fAAAEAAAA%';

  

select substr(rowid,1,6) "object", substr(rowid,7,3) "file",
substr(rowid,10,6) "block", substr(rowid,16,3) "row",a.* from scott.bh a where
rowid like '';

  

select rowid from scott.bh a where rowid like '';

  

create table rowid_temp as select rowid  row_id from scott.bh a where rowid
like '';

  

 begin

  for cursor_lob in (select rowid r, SYS_NC00024$ from OUTP.OUTPATIENT where
rowid in(select * from rowid_temp )) loop

  begin

    n:=dbms_lob.instr(cursor_lob.SYS_NC00024$,hextoraw('889911'));

  exception

    when error_1578 then

      insert into corrupt_lobs_outpatient values (cursor_lob.r, 1578);

      commit;

    when error_1555 then

      insert into corrupt_lobs_outpatient values (cursor_lob.r, 1555);

      commit;

    when error_22922 then

      insert into corrupt_lobs_outpatient values (cursor_lob.r, 22922);

      commit;

    end;

  end loop;

end;

/

  

  

  

  

  
  
  
---  
  
  



---
### TAGS
{rowid}

---
### NOTE ATTRIBUTES
>Created Date: 2017-05-28 06:42:07  
>Last Evernote Update Date: 2017-05-31 09:51:07  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=93369469492627  
>source-url: &  
>source-url: id=1057891.6  
>source-url: &  
>source-url: displayIndex=3  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=63ohn7hnr_29#BODYTEXT  