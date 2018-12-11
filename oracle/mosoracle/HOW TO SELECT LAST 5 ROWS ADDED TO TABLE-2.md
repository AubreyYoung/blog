# HOW TO SELECT LAST 5 ROWS ADDED TO TABLE

  

|

|

    
    
    
    PROBLEM DESCRIPTION: 
    =====================                                                          
                
    How to select the last 5 rows of table using SQL*PLUS with rownum.
    
    
    
    
    SOLUTION DESCRIPTION: 
    =====================     
                                
    Create a query using the following syntax: 
     
    select * from <table_name>                                                    
     	MINUS                                                                  
           
     	select * from <table_name> where rownum <=                             
           
     	(select count(*) - 5 from <table_name>);
      
  
---  
  
  


---
### NOTE ATTRIBUTES
>Created Date: 2017-09-06 06:34:28  
>Last Evernote Update Date: 2018-10-01 15:59:04  
>author: YangKwong  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=354602399357230  
>source-url: &  
>source-url: id=1032565.6  
>source-url: &  
>source-url: displayIndex=1  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=8rff7ntvd_141  