# Automatic Workload Repository (AWR) Reports - Main Information Sources (Doc
ID 1363422.1)

|

|

**In this Document**  

| |
[Purpose](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=537464980763804&id=1363422.1&displayIndex=2&_afrWindowMode=0&_adf.ctrl-
state=skppdrfco_4#PURPOSE)  
---|---  
|
[Scope](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=537464980763804&id=1363422.1&displayIndex=2&_afrWindowMode=0&_adf.ctrl-
state=skppdrfco_4#SCOPE)  
---|---  
| [Automatic Workload Repository (AWR)
Overview](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=537464980763804&id=1363422.1&displayIndex=2&_afrWindowMode=0&_adf.ctrl-
state=skppdrfco_4#aref_section21)  
---|---  
|
[Details](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=537464980763804&id=1363422.1&displayIndex=2&_afrWindowMode=0&_adf.ctrl-
state=skppdrfco_4#BODYTEXT)  
---|---  
| [Frequently Asked
Questions](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=537464980763804&id=1363422.1&displayIndex=2&_afrWindowMode=0&_adf.ctrl-
state=skppdrfco_4#aref_section31)  
---|---  
| [Collecting AWR
reports](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=537464980763804&id=1363422.1&displayIndex=2&_afrWindowMode=0&_adf.ctrl-
state=skppdrfco_4#aref_section32)  
---|---  
| [AWR
Interpretation](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=537464980763804&id=1363422.1&displayIndex=2&_afrWindowMode=0&_adf.ctrl-
state=skppdrfco_4#aref_section33)  
---|---  
| [AWR setup and Troubleshooting setup
Issues](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=537464980763804&id=1363422.1&displayIndex=2&_afrWindowMode=0&_adf.ctrl-
state=skppdrfco_4#aref_section34)  
---|---  
| [AWR
Setup](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=537464980763804&id=1363422.1&displayIndex=2&_afrWindowMode=0&_adf.ctrl-
state=skppdrfco_4#aref_section35)  
---|---  
| [AWR
Troubleshooting](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=537464980763804&id=1363422.1&displayIndex=2&_afrWindowMode=0&_adf.ctrl-
state=skppdrfco_4#aref_section36)  
---|---  
| [AWR Storage
Management](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=537464980763804&id=1363422.1&displayIndex=2&_afrWindowMode=0&_adf.ctrl-
state=skppdrfco_4#aref_section37)  
---|---  
| [Common
Issues](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=537464980763804&id=1363422.1&displayIndex=2&_afrWindowMode=0&_adf.ctrl-
state=skppdrfco_4#aref_section38)  
---|---  
| [If awrinfo.sql hangs, use following
script:](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=537464980763804&id=1363422.1&displayIndex=2&_afrWindowMode=0&_adf.ctrl-
state=skppdrfco_4#aref_section39)  
---|---  
| [Community
Discussions](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=537464980763804&id=1363422.1&displayIndex=2&_afrWindowMode=0&_adf.ctrl-
state=skppdrfco_4#aref_section310)  
---|---  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=537464980763804&id=1363422.1&displayIndex=2&_afrWindowMode=0&_adf.ctrl-
state=skppdrfco_4#REF)  
---|---  
  
* * *

## Applies to:

Oracle Database - Enterprise Edition - Version 10.1.0.2 and later  
Information in this document applies to any platform.  

## Purpose

**This document outlines the primary information sources regarding all aspects
of AWR reports.**

## Scope

### Automatic Workload Repository (AWR) Overview

**Automatic Workload Repository (AWR) is a licensed feature that allows
information to be recorded on a database for multiple purposes including
detection and elimination of performance issues.**

For a general overview of Performance Advisors and Manageability Features,
see:

[Document
276103.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=276103.1)
PERFORMANCE TUNING USING 10g ADVISORS AND MANAGEABILITY FEATURES

Assuming you have the appropriate licenses for AWR, you may gather and examine
Automatic Workload Repository (AWR) reports for the system.

[Document
1490798.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=1490798.1)
AWR Reporting - Licensing Requirements Clarification

Without the appropriate licenses, Statspack provides a legacy solution:

[Document
94224.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=94224.1)
FAQ- Statspack Complete Reference

## Details

### Frequently Asked Questions

[Document
1599440.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=1599440.1)
FAQ: Automatic Workload Repository (AWR) Reports  
  
[Document
1628089.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=1628089.1)
AWR Report Interpretation Checklist for Diagnosing Database Performance Issues  
[Document
1359094.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=1359094.1)
How to Use AWR reports to Diagnose Database Performance Issues

### Collecting AWR reports

[Document
748642.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=748642.1)
How to Generate an AWR Report and Create Baselines

### AWR Interpretation

A video entitled: "[Introduction to Performance Analysis Using AWR and
ASH](http://education.oracle.com/pls/web_prod-plq-
dad/db_pages.getpage?page_id=721&get_params=streamId:21 "Introduction to
Performance Analysis Using AWR and ASH")" is available
[here](http://education.oracle.com/pls/web_prod-plq-
dad/db_pages.getpage?page_id=721&get_params=streamId:21 "Introduction to
Performance Analysis Using AWR and ASH") providing a comprehensive guided tour
using an actual problem.

[Document
1628089.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=1628089.1)
AWR Report Interpretation Checklist for Diagnosing Database Performance Issues  
[Document
1359094.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=1359094.1)
How to Use AWR reports to Diagnose Database Performance Issues  
  
[Document
786554.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=786554.1)
How to Read PGA Memory Advisory Section in AWR and Statspack Reports  
[Document
754639.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=754639.1)
How to Read Buffer Cache Advisory Section in AWR and Statspack Reports.  
  
[Document
762526.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=762526.1)
How to Interpret the OS stats section of an AWR report  
[Document
1466035.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=1466035.1)
How to Interpret the "SQL ordered by Physical Reads (UnOptimized)" Section in
AWR Reports (11.2 onwards)

### AWR setup and Troubleshooting setup Issues

This section covers the setup of AWR and troubleshooting of problems related
to that:

#### AWR Setup

[Document
782974.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=782974.1)
How to Recreate The AWR ( AUTOMATIC WORKLOAD ) Repository ?

#### AWR Troubleshooting

[Document
1301503.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=1301503.1)
Troubleshooting: AWR Snapshot Collection issues  
  
[Document
296765.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=296765.1)
Solutions for possible AWR Library Cache Latch Contention Issues in Oracle 10g  
[Document
560204.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=560204.1)
MMON TRACE SHOWS KEWRAFC: FLUSH SLAVE FAILED, AWR ENQUEUE TIMEOUT

#### AWR Storage Management

[Document
1399365.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=1399365.1)
Troubleshooting Issues with SYSAUX  
  
[Document
287679.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=287679.1)
Space Management In Sysaux Tablespace with AWR in Use  
[Document
329984.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=329984.1)
Usage and Storage Management of SYSAUX tablespace occupants SM/AWR,
SM/ADVISOR, SM/OPTSTAT and SM/OTHER

#### Common Issues

[Document
459887.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=459887.1)
ORA-13516 AWR Operation failed: SWRF Schema not initialized ORA-06512
SYS.DBMS_WORKLOAD_REPOSITORY

#### If awrinfo.sql hangs, use following script:

[Document
733655.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=733655.1)
AWR diagnostic collection script

### Community Discussions

Still have questions? Use the communities window below to search for similar
discussions or start a new discussion on this subject. (Window is the live
community not a screenshot)

Click [here](https://community.oracle.com/message/12020464#12020464) to open
in main browser window

## References

[NOTE:560204.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=560204.1)
\- MMON Trace Shows: "*** KEWRAFC: Flush slave failed, AWR Enqueue Timeout"  
[NOTE:1359094.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=1359094.1)
\- How to Use AWR Reports to Diagnose Database Performance Issues  
[NOTE:733655.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=733655.1)
\- AWR Diagnostic Collection Script  
[NOTE:748642.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=748642.1)
\- How to Generate an AWR Report and Create Baselines  
[NOTE:276103.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=276103.1)
\- Performance Tuning Using Advisors and Manageability Features: AWR, ASH,
ADDM and SQL Tuning Advisor  
[NOTE:287679.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=287679.1)
\- How to Address Issues Where AWR Data Uses Significant Space in the SYSAUX
Tablespace  
[NOTE:296765.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=296765.1)
\- Solutions for possible AWR Library Cache Latch Contention Issues in Oracle
10g  
[NOTE:786554.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=786554.1)
\- How to Read PGA Memory Advisory Section in AWR and Statspack Reports to
Tune PGA_AGGREGATE_TARGET  
[NOTE:94224.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=94224.1)
\- FAQ- Statspack Complete Reference  
[NOTE:1490798.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=1490798.1)
\- AWR Reporting - Licensing Requirements Clarification  
[NOTE:1301503.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=1301503.1)
\- Troubleshooting: Missing Automatic Workload Repository (AWR) Snapshots and
Other Collection Issues  
[NOTE:754639.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=754639.1)
\- How to Read Buffer Cache Advisory Section in AWR and Statspack Reports.  
[NOTE:782974.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=782974.1)
\- How to Recreate the Automatic Workload Repository (AWR)?  
[NOTE:1399365.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=1399365.1)
\- Troubleshooting Issues with SYSAUX Usage by the Automatic Workload
Repository (AWR)  
[NOTE:329984.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=329984.1)
\- Usage and Storage Management of SYSAUX tablespace occupants SM/AWR,
SM/ADVISOR, SM/OPTSTAT and SM/OTHER  
[NOTE:459887.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1363422.1&id=459887.1)
\- ORA-13516 AWR Operation failed: SWRF Schema not initialized ORA-06512
SYS.DBMS_WORKLOAD_REPOSITORY  


---
### NOTE ATTRIBUTES
>Created Date: 2018-09-14 10:10:19  
>Last Evernote Update Date: 2018-10-01 15:40:46  
>source: web.clip7  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=537464980763804  
>source-url: &  
>source-url: id=1363422.1  
>source-url: &  
>source-url: displayIndex=2  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=skppdrfco_4  
>source-application: WebClipper 7  