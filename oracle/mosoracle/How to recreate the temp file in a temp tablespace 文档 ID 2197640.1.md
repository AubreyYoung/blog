# How to recreate the temp file in a temp tablespace (文档 ID 2197640.1)

  

|

|

 **In this Document**  

| |
[Goal](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=189236626129322&id=2197640.1&_adf.ctrl-
state=p069li6tb_156#GOAL)  
---|---  
|
[Solution](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=189236626129322&id=2197640.1&_adf.ctrl-
state=p069li6tb_156#FIX)  
---|---  
  
* * *

  

## Applies to:

Oracle Database - Enterprise Edition - Version 10.2.0.1 to 11.2.0.4 [Release
10.2 to 11.2]  
Information in this document applies to any platform.  

## Goal

This document intends to show the step by step instruction for temp files
recreation.

## Solution

1\. Query the information of current tempfiles.

SQL> select * from dba_temp_files;

FILE_NAME  
\--------------------------------------------------------------------------------  
FILE_ID TABLESPACE_NAME BYTES BLOCKS STATUS RELATIVE_FNO AUT MAXBYTES
MAXBLOCKS INCREMENT_BY USER_BYTES USER_BLOCKS  
\---------- ------------------------------ ---------- ---------- ---------
------------ --- ---------- ---------- ------------ ---------- -----------  
/export/oracle/app/oracle/oradata/R112/R112_PF_TMP_002.dbf  
4 TEMPORAL 2147483648 524288 AVAILABLE 1 NO 0 0 0 2146435072 524032

/export/oracle/app/oracle/oradata/R112/R112_PF_TMP_001.dbf  
5 TEMPORAL 1,0737E+10 2621440 AVAILABLE 2 NO 0 0 0 1,0736E+10 2621184

SQL> select * from V$TEMPFILE ;

FILE# CREATION_CHANGE# CREATION TS# RFILE# STATUS ENABLED BYTES BLOCKS
CREATE_BYTES BLOCK_SIZE  
\---------- ---------------- -------- ---------- ---------- ------- ----------
---------- ---------- ------------ ----------  
NAME  
\--------------------------------------------------------------------------------  
4 7,5605E+12 27/11/15 21 1 ONLINE READ WRITE 2147483648 524288 2147483648 4096

/export/oracle/app/oracle/oradata/R112/R112_PF_TMP_002.dbf

5 7,5605E+12 27/11/15 21 2 ONLINE READ WRITE 1,0737E+10 2621440 1,0737E+10
4096

/export/oracle/app/oracle/oradata/R112/R112_PF_TMP_001.dbf

2\. Checkif there is enough space in file system where temp files will be
created. In this case: /sdp_bd/R112/systmp

Filesystem Size Used Avail Use% Mounted on  
/dev/cciss/c0d0p3 7.8G 4.6G 2.9G 62% /  
/dev/cciss/c0d0p7 105G 19G 81G 20% /arch_local  
/dev/cciss/c0d0p1 101M 14M 83M 14% /boot  
none 7.9G 0 7.9G 0% /dev/shm  
/dev/cciss/c0d0p5 66G 56G 7.4G 89% /export  
/dev/cciss/c0d0p6 7.8G 5.4G 2.1G 73% /var  
/dev/sda1 512M 347M 166M 68% /ocr_shared/ocr_1  
/dev/sda2 512M 343M 170M 67% /ocr_shared/ocr_2  
/dev/sda3 512M 100M 412M 20% /ocr_shared/vote_1  
/dev/sda5 512M 100M 412M 20% /ocr_shared/vote_2  
/dev/sda6 512M 100M 412M 20% /ocr_shared/vote_3  
/dev/sda7 512M 107M 406M 21% /ocr_shared/spfiles  
/dev/sdak1 1.2T 477G 724G 40% /recovery_area  
/dev/sdal1 10G 327M 9.7G 4% /log  
/dev/sds1 48G 13G 36G 26% /sdp_bd/R112/data1  
/dev/sds2 48G 1.3G 47G 3% /sdp_bd/R112/index1  
/dev/sde1 30G 25G 5.3G 83% /sdp_bd/R112/systmp

3\. Check the tablespace where temp files will be created.

SQL> SELECT tablespace_name, SUM(bytes_used), SUM(bytes_free)  
FROM V$temp_space_header  
GROUP BY tablespace_name;

TABLESPACE_NAME SUM(BYTES_USED) SUM(BYTES_FREE)  
\------------------------------ --------------- ---------------  
TEMPORAL 4677697536 8207204352

4\. Create the new temp files.

ALTER TABLESPACE TEMPORAL ADD TEMPFILE '/sdp_bd/R112/systmp/R112_PF_TMP_1.dbf'
SIZE 2560M REUSE AUTOEXTEND OFF;

ALTER TABLESPACE TEMPORAL ADD TEMPFILE '/sdp_bd/R112/systmp/R112_PF_TMP_2.dbf'
SIZE 2560M REUSE AUTOEXTEND OFF;

5\. If you want to use symbolic links you can create them in each server of
the RAC

ln -s /sdp_bd/R112/systmp/R112_PF_TMP_1.dbf
/export/oracle/app/oracle/oradata/R112/R112_PF_TMP_1.dbf

ln -s /sdp_bd/R112/systmp/R112_PF_TMP_2.dbf
/export/oracle/app/oracle/oradata/R112/R112_PF_TMP_2.dbf

Verify the symbolic links has been created.

ls -l

6\. Make sure there is no session is using the temp tablespace

SQL> SELECT USERNAME, SESSION_NUM, SESSION_ADDR FROM V$SORT_USAGE;

If any session is using the TEM tablespace it can be identified with:

SELECT SID, SERIAL#, STATUS FROM V$SESSION WHERE SERIAL#=SESSION_NUM;  
Or  
SELECT SID, SERIAL#, STATUS FROM V$SESSION WHERE SADDR=SESSION_ADDR;

7\. Change the status of the temp files to Offline.

alter database tempfile
'/export/oracle/app/oracle/oradata/R112/R112_PF_TMP_001.dbf' OFFLINE;  
alter database tempfile
'/export/oracle/app/oracle/oradata/R112/R112_PF_TMP_002.dbf' OFFLINE;

8\. Drop the old temp files.

ALTER DATABASE TEMPFILE
'/export/oracle/app/oracle/oradata/R112/R112_PF_TMP_001.dbf' DROP;

ALTER DATABASE TEMPFILE
'/export/oracle/app/oracle/oradata/R112/R112_PF_TMP_002.dbf' DROP;

9\. Verify the info of the new temp files.

SQL> select * from dba_temp_files;  
Or  
SQL> select * from V$TEMPFILE;  
  
  



---
### TAGS
{temp tablespace}

---
### NOTE ATTRIBUTES
>Created Date: 2017-06-19 09:01:47  
>Last Evernote Update Date: 2017-06-19 09:02:09  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=189236626129322  
>source-url: &  
>source-url: id=2197640.1  
>source-url: &  
>source-url: _adf.ctrl-state=p069li6tb_156  