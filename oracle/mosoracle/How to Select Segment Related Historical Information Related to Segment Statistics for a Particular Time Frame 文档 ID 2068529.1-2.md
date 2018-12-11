# How to Select Segment Related Historical Information Related to Segment
Statistics for a Particular Time Frame (文档 ID 2068529.1)

  

|

|

 **In this Document**  

| |
[Goal](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=350974981998059&id=2068529.1&_adf.ctrl-
state=gqyu8mh5h_282#GOAL)  
---|---  
|
[Solution](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=350974981998059&id=2068529.1&_adf.ctrl-
state=gqyu8mh5h_282#FIX)  
---|---  
| [Sample
Output](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=350974981998059&id=2068529.1&_adf.ctrl-
state=gqyu8mh5h_282#aref_section21)  
---|---  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=350974981998059&id=2068529.1&_adf.ctrl-
state=gqyu8mh5h_282#REF)  
---|---  
  
* * *

  

## Applies to:

Oracle Database - Enterprise Edition - Version 11.2.0.4 and later  
Information in this document applies to any platform.  

## Goal

Shows how to select historical segment related information related to segment
statistics for a particular time frame,  

## Solution

You can retrieve this information by selecting data from the following
objects:  

  * **V$SEGMENT_STATISTICS** : V$SEGMENT_STATISTICS displays information about segment-level statistics.   

  * **DBA_HIST_SEG_STAT** : displays historical information about segment-level statistics.
  * **DBA_HIST_SNAPSHOT** : displays information about the snapshots in the Workload Repository including timing information.

**NOTE:** Some of these views are part of the Automatic Workload Repository
(AWR). Information from the Automatic Workload Repository (AWR) cannot be used
without a Diagnostic Pack License.  
  
See: [Document
1490798.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=2068529.1&id=1490798.1)
AWR Reporting - Licensing Requirements Clarification

  

Use a select similar to the following:

SET linesize 290  
col begin_interval_time FOR a40  
col end_interval_time FOR a40  
  
SELECT HSS.obj#,  
HSS.dataobj#,  
ss.owner,  
ss.object_name,  
HSS.row_lock_waits_delta Delta,  
begin_interval_time,  
end_interval_time  
FROM dba_hist_seg_stat HSS,  
dba_hist_snapshot HS,  
v$segment_statistics ss  
WHERE HSS.snap_id = HS.snap_id  
AND ss.dataobj# = HSS.dataobj#  
AND ss.value > 1  
AND statistic_name = '%<Statistic Name>%';

**NOTE:**

  1. The delta value is the value of the statistics from the BEGIN_INTERVAL_TIME to the END_INTERVAL_TIME in the DBA_HIST_SNAPSHOT view. This allows you to focus in on the period when the statistic changed.
  2. Use the BEGIN_INTERVAL_TIME and END_INTERVAL_TIME to limit the report for a particular time frame.

### Sample Output

The following example retrieves information related to the 'row lock waits'
statistics:

SQL> SELECT HSS.obj#,  
HSS.dataobj#,  
ss.owner,  
ss.object_name,  
HSS.row_lock_waits_delta Delta,  
begin_interval_time,  
end_interval_time  
FROM dba_hist_seg_stat HSS,  
dba_hist_snapshot HS,  
v$segment_statistics ss  
WHERE HSS.snap_id = HS.snap_id  
AND ss.dataobj# = HSS.dataobj#  
AND ss.value > 1  
AND statistic_name = 'row lock waits';  
  
  

    
    
         OBJ#   DATAOBJ# OWNER  OBJECT_NAME   ROW_LOCK_WAITS_DELTA BEGIN_INTERVAL_TIME       END_INTERVAL_TIME
    ---------- ---------- ----- ------------- -------------------- ------------------------- ------------------------
         81568      81568 SYS   TEST_WAIT                        1 17-OCT-15 01.00.41.450 AM 17-OCT-15 02.00.43.610 AM
         81568      81568 SYS   TEST_WAIT                        2 17-OCT-15 04.00.47.674 AM 17-OCT-15 05.00.49.832 AM
    

## References

[NOTE:2068558.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=2068529.1&id=2068558.1)
\- How to Select Historical Information Related to "Wait Events" for a
Particular Time Frame  
[NOTE:243132.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=2068529.1&id=243132.1)
\- Analysis of Active Session History (Ash) Online and Offline  
  
  
  


---
### NOTE ATTRIBUTES
>Created Date: 2017-08-16 06:36:29  
>Last Evernote Update Date: 2018-10-01 15:59:04  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=350974981998059  
>source-url: &  
>source-url: id=2068529.1  
>source-url: &  
>source-url: _adf.ctrl-state=gqyu8mh5h_282  