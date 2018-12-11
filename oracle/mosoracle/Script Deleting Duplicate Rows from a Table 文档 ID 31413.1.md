# Script: Deleting Duplicate Rows from a Table (文档 ID 31413.1)

  

|

|

***Checked for relevance on 07-Dec-2016***  |  |  
---  
Abstract  
---  
Script to delete duplicate rows from a table  
  
Product Name, Product Version

| Oracle Server, 7.3.X to 11.2.0.X  
  
Platform  | Platform independent  
Date Created  | 12-Oct-1999  
Instructions  
      
    
    Execution Environment:
         SQL, SQL*Plus
    
    Access Privileges:
         Requires no special access privileges as script is to be run as the owner of
    
    
         the table.
    
    Usage:
         sqlplus username/<password> @duplicate.sql
    
    Instructions:
    
         Copy this script to a file named duplicate.sql. Connect to the database as the
    
    
         owner of the table with the duplicate rows. Execute the duplicate.sql script
    
    
         and provide the table name and column name(s) to filter the duplicates on. 
    
    
         Note that the script deletes the rows without confirming. You may wish to run
    
    
         the statement generated as a SELECT to verify the rows that will be deleted.
    
    
         However, you can issue a rollback before exiting the session if you wish to 
    
    
         rollback the delete that was performed.
    
    
     
    
    
    PROOFREAD THIS SCRIPT BEFORE USING IT! Due to differences in the way text 
    editors, e-mail packages, and operating systems handle text formatting (spaces, 
    tabs, and carriage returns), this script may not be in an executable state
    when you first receive it. Check over the script to ensure that errors of
    this type are corrected.
      
  
Description  
      
    
    This script takes as input a table name and list of columns which you desire to be
    
    
    unique and deletes all rows with the same value in these columns, leaving only the
    
    
    row with the minimum rowid. NOTE: The script does not deal with NULLS in the
    
    
    column(s).
    
    
     
    
    
    Restrictions: This script will not work if the column(s) to be filtered on are have
    
    
    a datatype of LONG,LONG RAW,RAW, CLOB, NCLOB, BLOB, BFILE or an object datatype.  
  

References  
  

Script  
`

REM This is an example SQL*Plus Script to delete duplicate rows from

REM a table.

REM

set echo off

set verify off heading off

undefine t

undefine c

prompt

prompt

prompt Enter name of table with duplicate rows

prompt

accept t prompt 'Table: '

prompt

select 'Table '||upper('&&t') from dual;

describe &&t

prompt

prompt Enter name(s) of column(s) which should be unique. If more than

prompt one column is specified , you MUST separate with commas.

prompt

accept c prompt 'Column(s): '

prompt

delete from &&t

where rowid not in (select min(rowid) from &&t group by &&c)

/

`  
Disclaimer  
      
    
    EXCEPT WHERE EXPRESSLY PROVIDED OTHERWISE, THE INFORMATION, SOFTWARE,
    PROVIDED ON AN "AS IS" AND "AS AVAILABLE" BASIS. ORACLE EXPRESSLY DISCLAIMS
    ALL WARRANTIES OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
    PURPOSE AND NON-INFRINGEMENT. ORACLE MAKES NO WARRANTY THAT: (A) THE RESULTS
    THAT MAY BE OBTAINED FROM THE USE OF THE SOFTWARE WILL BE ACCURATE OR
    RELIABLE; OR (B) THE INFORMATION, OR OTHER MATERIAL OBTAINED WILL MEET YOUR
    EXPECTATIONS. ANY CONTENT, MATERIALS, INFORMATION OR SOFTWARE DOWNLOADED OR
    OTHERWISE OBTAINED IS DONE AT YOUR OWN DISCRETION AND RISK. ORACLE SHALL HAVE
    NO RESPONSIBILITY FOR ANY DAMAGE TO YOUR COMPUTER SYSTEM OR LOSS OF DATA THAT
    RESULTS FROM THE DOWNLOAD OF ANY CONTENT, MATERIALS, INFORMATION OR SOFTWARE.
    
    ORACLE RESERVES THE RIGHT TO MAKE CHANGES OR UPDATES TO THE SOFTWARE AT ANY
    TIME WITHOUT NOTICE.
      
  
Limitation of Liability  
      
    
    IN NO EVENT SHALL ORACLE BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
    SPECIAL OR CONSEQUENTIAL DAMAGES, OR DAMAGES FOR LOSS OF PROFITS, REVENUE,
    DATA OR USE, INCURRED BY YOU OR ANY THIRD PARTY, WHETHER IN AN ACTION IN
    CONTRACT OR TORT, ARISING FROM YOUR ACCESS TO, OR USE OF, THE SOFTWARE.
    
    SOME JURISDICTIONS DO NOT ALLOW THE LIMITATION OR EXCLUSION OF LIABILITY.
    ACCORDINGLY, SOME OF THE ABOVE LIMITATIONS MAY NOT APPLY TO YOU.
      
  
---  
  
  



---
### TAGS
{duplicate rows}

---
### NOTE ATTRIBUTES
>Created Date: 2017-11-06 08:48:14  
>Last Evernote Update Date: 2018-10-01 15:44:50  
>author: YangKwong  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=2553010144947  
>source-url: &  
>source-url: id=31413.1  
>source-url: &  
>source-url: displayIndex=5  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=cnnzq2ypz_707  