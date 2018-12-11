# How To Add A 10g RAC Database to 12c Grid Infrastructure (文档 ID 2272954.1)

  

|

|

 **In this Document**  

| |
[Goal](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323014991777562&id=2272954.1&_adf.ctrl-
state=4n68ptb5n_110#GOAL)  
---|---  
|
[Solution](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323014991777562&id=2272954.1&_adf.ctrl-
state=4n68ptb5n_110#FIX)  
---|---  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323014991777562&id=2272954.1&_adf.ctrl-
state=4n68ptb5n_110#REF)  
---|---  
  
* * *

  

## Applies to:

Oracle Database - Enterprise Edition - Version 10.2.0.4 to 11.1.0.7 [Release
10.2 to 11.1]  
Oracle Database - Enterprise Edition - Version 12.1.0.2 and later  
Information in this document applies to any platform.  

## Goal

What is the process to add a 10gR2 RAC database to 12c Grid Infrastructure?  

## Solution

***IMPORTANT***

Ensure all nodes are pinned prior to completing any task as outlined in
Document:[1568834.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=2272954.1&id=1568834.1)
\- Pre 12.1 Database Issues in 12c Grid Infrastructure Environment

$GRID_HOME/bin/olsnodes -t -n

First, add the database resource from resource home (10g) to the OCR.

as RDBMS software owner:

<10.2 RDBMS Home>/bin/srvctl add database -d <db_unique_name> -o
<10.2_oracle_home> -p spfile -s start_options -y [automatic | manual]

Example:

$ cd /u01/app/oracle/product/10.2.0/dbhome_1/bin

$ srvctl add database -d ORCL -o /u01/app/oracle/product/10.2.0/dbhome_1 -p
+DATA/orcl/spfileorcl.ora -s OPEN -y automatic

Secondly, add the instances on each node and start each instance.

as RDBMS software owner:

<10.2 RDBMS Home>/bin/srvctl add instance -d <db_unique_name> -i <inst_name>
-n node_name

<10.2 RDBMS Home>/bin/srvctl start instance -d <db_unique_name> -i <inst_name>

<10.2 RDBMS Home>/bin/srvctl status database -d <db_unique_name>

Example:

$ cd /u01/app/oracle/product/10.2.0/dbhome_1/bin

$ srvctl add instance -d ORCL -i ORCL1 -n racnode1

$ srvctl start instance -d ORCL -i ORCL1

$ srvctl status database -d ORCL

Instance ORCL1 is running on node racnode1

<Continue to add instances to remaining nodes in cluster>

For additional parameters please reference the "Server Control Utility
Reference" on documentation

<http://docs.oracle.com/cd/B19306_01/rac.102/b14197/srvctladmin.htm#CHDEBCFF>

Command syntax and references for other releases:

10gR2, 11gR1, 11gR2 and 12cR1 Oracle Clusterware (CRS / Grid Infrastructure) &
RAC Command (crsctl, srvctl, cluvfy etc) Syntax and Reference (Doc ID
[1332452.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=2272954.1&id=1332452.1))

## References

[NOTE:1568834.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=2272954.1&id=1568834.1)
\- Pre 12.1 Database Issues in 12c Grid Infrastructure Environment  
[NOTE:954552.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=2272954.1&id=954552.1)
\- 11.2 Oracle Restart cannot manage 10.x or 11.1 single instances  
  
  
  



---
### TAGS
{RAC}

---
### NOTE ATTRIBUTES
>Created Date: 2017-07-05 01:21:01  
>Last Evernote Update Date: 2018-10-01 15:59:05  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323014991777562  
>source-url: &  
>source-url: id=2272954.1  
>source-url: &  
>source-url: _adf.ctrl-state=4n68ptb5n_110  