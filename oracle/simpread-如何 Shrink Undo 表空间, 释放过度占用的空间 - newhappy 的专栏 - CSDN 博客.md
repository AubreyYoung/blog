> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://blog.csdn.net/newhappy2008/article/details/12511823 版权声明：本文为博主原创文章，未经博主允许不得转载。 https://blog.csdn.net/newhappy2008/article/details/12511823 <link rel="stylesheet" href="https://csdnimg.cn/release/phoenix/template/css/ck_htmledit_views-d7e2a68c7c.css"> 采用如下步骤回收 UNDO 空间:
1\. 确认文件

<pre>SQL> select file_name,bytes/1024/1024 from dba_data_files
  2  where tablespace_name like 'UNDOTBS1';

FILE_NAME
--------------------------------------------------------------------------------
BYTES/1024/1024
---------------
+ORADG/danaly/datafile/undotbs1.265.600173875
          27810
</pre>

2\. 检查 UNDO Segment 状态

<pre>SQL> select usn,xacts,rssize/1024/1024/1024,hwmsize/1024/1024/1024,shrinks
  2  from v$rollstat order by rssize;

       USN      XACTS RSSIZE/1024/1024/1024 HWMSIZE/1024/1024/1024    SHRINKS
---------- ---------- --------------------- ---------------------- ----------
         0          0            .000358582             .000358582          0
         2          0            .071517944             .071517944          0
         3          0             .13722229              .13722229          0
         9          0            .236984253             .236984253          0
        10          0            .625144958             .625144958          0
         5          1            1.22946167             1.22946167          0
         8          0            1.27175903             1.27175903          0
         4          1            1.27895355             1.27895355          0
         7          0            1.56770325             1.56770325          0
         1          0            2.02474976             2.02474976          0
         6          0             2.9671936              2.9671936          0

11 rows selected.
</pre>

3\. 创建新的 UNDO 表空间

<pre>SQL> create undo tablespace undotbs2;

Tablespace created.
</pre>

4\. 切换 UNDO 表空间为新的 UNDO 表空间

<pre>SQL> alter system set undo_tablespace=undotbs2 scope=both;

System altered.
</pre>

5\. 等待原 UNDO 表空间所有 UNDO SEGMENT OFFLINE

<pre>SQL> select usn,xacts,status,rssize/1024/1024/1024,hwmsize/1024/1024/1024,shrinks
  2 from v$rollstat order by rssize;

       USN      XACTS STATUS          RSSIZE/1024/1024/1024 HWMSIZE/1024/1024/1024    SHRINKS
---------- ---------- --------------- --------------------- ---------------------- ----------
        14          0 ONLINE                     .000114441             .000114441          0
        19          0 ONLINE                     .000114441             .000114441          0
        11          0 ONLINE                     .000114441             .000114441          0
        12          0 ONLINE                     .000114441             .000114441          0
        13          0 ONLINE                     .000114441             .000114441          0
        20          0 ONLINE                     .000114441             .000114441          0
        15          1 ONLINE                     .000114441             .000114441          0
        16          0 ONLINE                     .000114441             .000114441          0
        17          0 ONLINE                     .000114441             .000114441          0
        18          0 ONLINE                     .000114441             .000114441          0
         0          0 ONLINE                     .000358582             .000358582          0

       USN      XACTS STATUS          RSSIZE/1024/1024/1024 HWMSIZE/1024/1024/1024    SHRINKS
---------- ---------- --------------- --------------------- ---------------------- ----------
         6          0 PENDING OFFLINE             2.9671936              2.9671936          0

12 rows selected.
</pre>

再看:

<pre>11:32:11 SQL> /

       USN      XACTS STATUS          RSSIZE/1024/1024/1024 HWMSIZE/1024/1024/1024    SHRINKS
---------- ---------- --------------- --------------------- ---------------------- ----------
        15          1 ONLINE                     .000114441             .000114441          0
        11          0 ONLINE                     .000114441             .000114441          0
        12          0 ONLINE                     .000114441             .000114441          0
        13          0 ONLINE                     .000114441             .000114441          0
        14          0 ONLINE                     .000114441             .000114441          0
        20          0 ONLINE                     .000114441             .000114441          0
        16          0 ONLINE                     .000114441             .000114441          0
        17          0 ONLINE                     .000114441             .000114441          0
        18          0 ONLINE                     .000114441             .000114441          0
        19          0 ONLINE                     .000114441             .000114441          0
         0          0 ONLINE                     .000358582             .000358582          0

11 rows selected.

Elapsed: 00:00:00.00
</pre>

6\. 删除原 UNDO 表空间

<pre>11:34:00 SQL> drop tablespace undotbs1 including contents;

Tablespace dropped.

Elapsed: 00:00:03.13
</pre>

7\. 检查空间情况
由于我使用的 ASM 管理, 可以使用 10gR2 提供的信工具 asmcmd 来察看空间占用情况.

<pre>[oracle@danaly ~]$ export ORACLE_SID=+ASM
[oracle@danaly ~]$ asmcmd
ASMCMD> du 
Used_MB      Mirror_used_MB
  21625               21625
ASMCMD> exit
</pre>

空间已经释放。