# How to Find or Delete Duplicate Rows in a Table (文档 ID 1004425.6)

  

|

|

    
    
    
    PROBLEM DESCRIPTION:
    ====================
    
    How do you find or delete duplicate rows in a table?
    
    
    SOLUTION DESCRIPTION:
    =====================
    
    The following SELECT statement will find and display all duplicate rows  
    in a table, except the row with the maximum ROWID.  The example uses the  
    dept table:  
     
    SELECT * FROM dept a  
    WHERE ROWID <> (SELECT MAX(ROWID)  
                    FROM dept b  
                    WHERE a.deptno = b.deptno 
                    AND a.dname = b.dname -- Make sure all columns are compared 
                    AND a.loc = b.loc);                        
     
    The following statement will delete all duplicate rows in a table, except the 
    row with the maximum ROWID:  
     
    DELETE FROM dept a  
    WHERE ROWID <> (SELECT MAX(ROWID)  
                    FROM dept b 
                    WHERE a.deptno = b.deptno  
                    AND a.dname = b.dname -- Make sure all columns are compared 
                    AND a.loc = b.loc); 
     
    Alternatively: 
     
    DELETE FROM dept a 
    WHERE 1 < (SELECT COUNT(deptno)  
               FROM dept b 
               WHERE a.deptno = b.deptno 
               AND a.dname = b.dname      -- Make sure all columns are compared 
               AND a.loc = b.loc); 
     
    EXPLANATION
    ===========
     
    Using the pseudocolumn ROWID is the fastest way to access a row. ROWID 
    represents a unique storage identification number for a single row in a table 
    (Note: Two rows on different tables but stored in the same cluster may have 
    the same rowid value).   
     
    Duplicate rows which contain only null columns, however, will not be 
    identified by either of the two methods above.  
    
    In such a case, simply:   
    DELETE FROM dept WHERE deptno IS NULL AND 
                           dname  IS NULL AND 
                           loc    IS NULL;                   
     
    
    REFERENCES:
    ===========
    Oracle SQL Language Reference Manual
      
  
---  
  
  



---
### TAGS
{duplicate rows}

---
### NOTE ATTRIBUTES
>Created Date: 2017-11-06 08:49:26  
>Last Evernote Update Date: 2018-10-01 15:59:04  
>author: YangKwong  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?id=1004425.6  
>source-url: &  
>source-url: displayIndex=2  
>source-url: &  
>source-url: _adf.ctrl-state=cnnzq2ypz_658  
>source-url: &  
>source-url: _afrLoop=4129795644647  