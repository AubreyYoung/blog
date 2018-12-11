# Oracle-指导手册-Oracle 使用RMAN增量备份前滚恢复Dataguard断档操作.html

You need to enable JavaScript to run this app.

![](https://47.100.29.40/highgo_admin/static/media/head.530901d0.png)

  杨光  |  退出

  * 知识库

    * ▢  新建文档
    * ▢  文档复查 (3)
    * ▢  文档查询
  * 待编区

文档详细

  知识库 文档详细

![noteattachment1][7f025a17697ee15eb3197c61326b203b]

064558704

Oracle-指导手册-Oracle 使用RMAN增量备份前滚恢复Dataguard断档操作

目录

环境

文档用途

详细信息

相关文档

内部备注

附件

环境

系统平台：N/A

版本：N/A

文档用途

 **使用** **RMAN** **增量备份** **前滚恢复Dataguard断档**

  

详细信息

# 一、 目的

  

用于解决物理standby数据库丢失归档日志或不可解决的归档日志断档问题

用于解决物理standby断档后主库添加了数据文件情况

# 二、 解决方法

  

通过RMAN增量备份解决DATAGUARD断档，不需要重新初始化。

注意：如果使用了‘DataGuard Broker’，在开始前先关闭此功能，所有步骤完成后再重新启动



1 在standby数据库停止MRP恢复进程

SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;



2 在standby数据库确定SCN信息

此SCN为主库增量备份的起始点，使用以下查询最低的SCN值

SQL> select current_scn from v$database;



                                   CURRENT_SCN

\--------------------------------------------------

                                15025210932804



SQL> select min(checkpoint_change#) from v$datafile_header;



                        MIN(CHECKPOINT_CHANGE#)

\--------------------------------------------------

                                15025210932805



15025210932804<15025210932805 选择scn 15025210932804作为增量备份起始点





3 在primary数据库查询是否有断档以来添加的数据文件

如果有新添加的数据文件则需要额外备份恢复这部分数据文件，如没有则忽略

SQL> SELECT FILE#, NAME FROM V$DATAFILE WHERE CREATION_CHANGE# >
<SCN_NUMBER_FROM_STEP 2>



eg.

break on report

compute sum of bytes/1024/1024 on report

select bytes/1024/1024,file#,name from v$datafile where creation_change# >
15025210932804;



BYTES/1024/1024      FILE# NAME

\--------------- ----------
------------------------------------------------------------

         20480        188 +ZY_DATA/jnzyk/datafile/system.460.921764781

         20480        189 +ZY_DATA/jnzyk/datafile/tbs_pcsyyk_asjdata.461.921764861

         20480        190 +ZY_DATA/jnzyk/datafile/tbs_pcsyyk_asjdata.462.921764993

         20480        191 +ZY_DATA/jnzyk/datafile/tbs_pcsyyk_asjdata.463.921765089

         20480        192 +ZY_DATA/jnzyk/datafile/tbs_pcsyyk_asjdata.464.921765185

         20480        193 +ZY_DATA/jnzyk/datafile/tbs_yyk_czrkzpdata.465.926159703

         20480        194 +ZY_DATA/jnzyk/datafile/tbs_yyk_czrkzpdata.466.926159753

         20480        195 +ZY_DATA/jnzyk/datafile/tbs_yyk_czrkzpdata.467.926159811

         20480        196 +ZY_DATA/jnzyk/datafile/tbs_yyk_wbzydata.468.926161051

         20480        197 +ZY_DATA/jnzyk/datafile/tbs_yyk_wbzydata.469.926161157

         20480        198 +ZY_DATA/jnzyk/datafile/tbs_yyk_wbzydata.470.926161253

\---------------

        225280



11 rows selected.





4 基于之前步骤查询出的SCN信息，使用RMAN，备份丢失的数据文件及断档以来的增量数据

需要备份：增量备份，新的控制文件

RMAN> backup datafile #, #, #, # format '/tmp/ForStandby_%U' tag 'FORSTANDBY';
\--(可选)主库没有新添加的数据文件时忽略

RMAN> backup incremental from SCN 3162298 database format '/tmp/ForStandby_%U'
tag 'FORSTANDBY';

RMAN> backup current controlfile for standby format '/tmp/ForStandbyCTRL.bck';

eg.

#!/bin/bash

. ~/.bash_profile

export ORACLE_SID=jnzyk1

DATE=`date +%Y-%m-%d`

rman logfile=/opt/backup/bakdg/bak_dg$DATE.log <<EOF

connect target /

run

{

backup datafile 188,189,190,191,192,193,194,195,196,197,198  format
'/opt/backup/bakdg/dgdatafile%U';

backup incremental from scn 15025210932804 database format
'/opt/backup/bakdg/dgincre%U';

backup current controlfile for standby format '/opt/backup/bakdg/dgctl%U';

}

EOF



5 传输所有的备份从primary端到standby端

scp /tmp/ForStandby_* standby:/tmp



6 恢复新的控制文件并注册备份信息

RMAN> shutdown;

RMAN> startup nomount;

RMAN> restore standby controlfile from '/tmp/ForStandbyCTRL.bck';

RMAN> alter database mount;

RMAN> CATALOG START WITH '/tmp/ForStandby';  
  
using target database control file instead of recovery catalog  
searching for all files that match the pattern /tmp/ForStandby  
  
List of Files Unknown to the Database  
=====================================  
File Name: /tmp/ForStandby_2lkglss4_1_1  
File Name: /tmp/ForStandby_2mkglst8_1_1  
  
Do you really want to catalog the above files (enter YES or NO)? YES  
cataloging files...  
cataloging done  
  
List of Cataloged Files  
=======================  
File Name: /tmp/ForStandby_2lkglss4_1_1  
File Name: /tmp/ForStandby_2mkglst8_1_1





eg.

restore standby controlfile from
'/oradata/backup/zykdg/bakdg/dgctl1mrneud1_1_1';



alter database mount;

catalog start with '/oradata/backup/zykdg/bakdg/';



7 还原丢失的数据文件（可选）

如果没有则忽略

run

{

set newname for datafile X to '+DISKGROUP';

set newname for datafile Y to '+DISKGROUP';

set newname for datafile Z to '+DISKGROUP';

etc.

restore datafile x,y,z,....;

}



eg.

#!/bin/bash

. ~/.bash_profile

export ORACLE_SID=jnzyk

DATE=`date +%Y-%m-%d`

rman log=/oradata/backup/zykdg/bakdg/restore_datafile$DATE.log <<EOF

connect target /

run

{

set newname for datafile 188 to
'/oradata/zykdg/JNZYK/datafile/system.460.921764781';

set newname for datafile 189 to
'/oradata/zykdg/JNZYK/datafile/tbs_pcsyyk_asjdata.461.92176486';

set newname for datafile 190 to
'/oradata/zykdg/JNZYK/datafile/tbs_pcsyyk_asjdata.462.92176499';

set newname for datafile 191 to
'/oradata/zykdg/JNZYK/datafile/tbs_pcsyyk_asjdata.463.92176508';

set newname for datafile 192 to
'/oradata/zykdg/JNZYK/datafile/tbs_pcsyyk_asjdata.464.92176518';

set newname for datafile 193 to
'/oradata/zykdg/JNZYK/datafile/tbs_yyk_czrkzpdata.465.92615970';

set newname for datafile 194 to
'/oradata/zykdg/JNZYK/datafile/tbs_yyk_czrkzpdata.466.92615975';

set newname for datafile 195 to
'/oradata/zykdg/JNZYK/datafile/tbs_yyk_czrkzpdata.467.92615981';

set newname for datafile 196 to
'/oradata/zykdg/JNZYK/datafile/tbs_yyk_wbzydata.468.926161051';

set newname for datafile 197 to
'/oradata/zykdg/JNZYK/datafile/tbs_yyk_wbzydata.469.926161157';

set newname for datafile 198 to
'/oradata/zykdg/JNZYK/datafile/tbs_yyk_wbzydata.470.926161253';

restore datafile 188,189,190,191,192,193,194,195,196,197,198;

}

EOF



8 在新的standby控制文件中重命名数据文件

由于新的控制文件是从主端还原的，控制文件中的记录信息都是和主端相匹配，如果主端和备端目录结构不同，需要catalog
datafile以实现重命名操作，如果主端和备端目录结构相同则跳过

RMAN> CATALOG START WITH '+DATA/mystd/datafile/';  
  
List of Files Unknown to the Database  
=====================================  
File Name: +data/mystd/DATAFILE/SYSTEM.309.685535773  
File Name: +data/mystd/DATAFILE/SYSAUX.301.685535773  
File Name: +data/mystd/DATAFILE/UNDOTBS1.302.685535775  
File Name: +data/mystd/DATAFILE/SYSTEM.297.688213333  
File Name: +data/mystd/DATAFILE/SYSAUX.267.688213333  
File Name: +data/mystd/DATAFILE/UNDOTBS1.268.688213335  
  
Do you really want to catalog the above files (enter YES or NO)? YES  
cataloging files...  
cataloging done  
  
List of Cataloged Files  
=======================  
File Name: +data/mystd/DATAFILE/SYSTEM.297.688213333  
File Name: +data/mystd/DATAFILE/SYSAUX.267.688213333  
File Name: +data/mystd/DATAFILE/UNDOTBS1.268.688213335

 Once all files have been cataloged, switch the database to copy:

RMAN> SWITCH DATABASE TO COPY;  
  
datafile 1 switched to datafile copy
"+DATA/mystd/datafile/system.297.688213333"  
datafile 2 switched to datafile copy
"+DATA/mystd/datafile/undotbs1.268.688213335"  
datafile 3 switched to datafile copy
"+DATA/mystd/datafile/sysaux.267.688213333"



eg.

SQL> select name from v$dbfile;



NAME

\--------------------------------------------------------------------------------

+ZY_DATA/jnzyk/datafile/users.259.899045457

+ZY_DATA/jnzyk/datafile/undotbs1.258.899045457

+ZY_DATA/jnzyk/datafile/sysaux.257.899045457

+ZY_DATA/jnzyk/datafile/system.256.899045457

+ZY_DATA/jnzyk/datafile/undotbs2.266.899045659

+ZY_DATA/jnzyk/datafile/tbs_pcsyyk_gzdx.272.899048383

+ZY_DATA/jnzyk/datafile/tbs_pcsyyk_jgdata.273.899048387

+ZY_DATA/jnzyk/datafile/tbs_pcsyyk_mlp.274.899048389

+ZY_DATA/jnzyk/datafile/tbs_pcsyyk_zddxdata.275.899048391

+ZY_DATA/jnzyk/datafile/tbs_yyk_yskindex.276.899048395

+ZY_DATA/jnzyk/datafile/tbs_yyk_yskdata.277.899048397

......





198 rows selected.



SQL>





catalog start with '/oradata/zykdg/JNZYK/datafile/';

switch database to copy;



SQL> select name from v$dbfile;



NAME

\--------------------------------------------------------------------------------

/oradata/zykdg/JNZYK/datafile/o1_mf_users_cb4190s5_.dbf

/oradata/zykdg/JNZYK/datafile/o1_mf_undotbs1_cb6fns76_.dbf

/oradata/zykdg/JNZYK/datafile/o1_mf_sysaux_cb5894fk_.dbf

/oradata/zykdg/JNZYK/datafile/o1_mf_system_cb41614t_.dbf

/oradata/zykdg/JNZYK/datafile/o1_mf_undotbs2_cb7h1csk_.dbf

/oradata/zykdg/JNZYK/datafile/o1_mf_tbs_pcsy_cb58klj4_.dbf

/oradata/zykdg/JNZYK/datafile/o1_mf_tbs_pcsy_cb419ycz_.dbf

/oradata/zykdg/JNZYK/datafile/o1_mf_tbs_pcsy_cb58l0nj_.dbf

/oradata/zykdg/JNZYK/datafile/o1_mf_tbs_pcsy_cb41b76q_.dbf

/oradata/zykdg/JNZYK/datafile/o1_mf_tbs_yyk__cb58l9no_.dbf

/oradata/zykdg/JNZYK/datafile/o1_mf_tbs_yyk__cb41bo19_.dbf

……



9 使用增量备份前滚恢复standby数据库

RMAN> RECOVER DATABASE NOREDO;



eg.

#!/bin/bash

. ~/.bash_profile

export ORACLE_SID=jnzyk

DATE=`date +%Y-%m-%d`

rman log=/oradata/backup/zykdg/bakdg/recover$DATE.log <<EOF

connect target /

run

{

recover database noredo;

}

EOF





10 如果standby数据库需要配置闪回，使用以下的命令（可选）

SQL> ALTER DATABASE FLASHBACK OFF;  
SQL> ALTER DATABASE FLASHBACK ON;



11 standby数据库中所有的standby redo log日志组清空或重建

与步骤8同理，控制文件中记录的日志文件信息可能需要修改

SQL> ALTER DATABASE CLEAR LOGFILE GROUP 1;  
SQL> ALTER DATABASE CLEAR LOGFILE GROUP 2;  
SQL> ALTER DATABASE CLEAR LOGFILE GROUP 3;  
....

eg.

alter database add standby logfile thread 1 group 11
'/oradata/zykdg/JNZYK/onlinelog/standby11.log' reuse;

alter database add standby logfile thread 1 group 12
'/oradata/zykdg/JNZYK/onlinelog/standby12.log' reuse;

alter database drop standby logfile group 19;

alter database add standby logfile thread 2 group 19
'/oradata/zykdg/JNZYK/onlinelog/standby19.log' size 512m;

alter database add standby logfile thread 2 group 20
'/oradata/zykdg/JNZYK/onlinelog/standby20.log' size 512m;







12 在standby数据库启动MRP应用进程

SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT;



eg.

alter database recover managed standby database using current logfile
disconnect from session;





  

参考mos

Steps       to perform for Rolling forward a standby database using RMAN
incremental       backup when datafile is added to primary (Doc ID 1531031.1)

Steps to perform for Rolling Forward a Physical Standby Database using RMAN
Incremental Backup. (Doc ID 836986.1)

  
  
---  
  
  

  

相关文档

内部备注

附件

验证码：

  换一张

输入验证码：

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAYAAAA7MK6iAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEgAACxIB0t1+/AAAABZ0RVh0Q3JlYXRpb24gVGltZQAwOS8yNy8xN+stbYgAAAAcdEVYdFNvZnR3YXJlAEFkb2JlIEZpcmV3b3JrcyBDUzbovLKMAAABm0lEQVRIicXXwXGCQBTG8b+7uZsSTAXRCiQVhA6SXLgmJZgO5BguSQnYgR0EK0hKiAUs5rBvGVlBBEG/GWccxf0JC2/fjna7HU3JEz0BQnlNgbF3yBbIgBRIVWR+m8YcHYPzRE+BBfDY+O/KWQELFZmsNZwnegm8tgT9xCoybyfBeaJvgTVwfybqsgECFZm//Q/VwCgy1lrGroYHQEt4JSxzOgRa4GIAMsdy934PiO5npiKTuTNeXAgtrJH5UBPg54IwwJ3CVqO+swEegPea78MhYPfcroFlzTGhwtbevlFXLOrgqeKw4PeC5on+Ap5qjh37BcTPFjtXL/K+DxSAmwY4k7kiT3SGrT7+FWqNwmHJ9DPPE/0MIEtcQPnMO6EOPnYJAT5r8M4osFXYzqEpVXhXFCBT2HbllJTwM1CAtA1cws9AAVK3OqW066tibOGZd0BXKjLhdZdFuWHiC6Cx6zxLzZ4UiaG6kI2KTLEu+AUkwD6fvaMydpESLI9I33hle3u1hr62VssPZtjtSNussHdvJQoNeyeXITZt/1po2U5WDlb1AAAAAElFTkSuQmCC)![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAYAAAA7MK6iAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEgAACxIB0t1+/AAAABZ0RVh0Q3JlYXRpb24gVGltZQAwOS8yNy8xN+stbYgAAAAcdEVYdFNvZnR3YXJlAEFkb2JlIEZpcmV3b3JrcyBDUzbovLKMAAABu0lEQVRIicWX223CQBBFD26AlOAOMJoCQgl0AFQQSoEOoAN3EPLPKHYHKSFUQD686/jFPkysXMkSQsMc1jt7Z3Z2v9/xSVVTYG2eDJh3Qm5AAeRALiJfvpwzF1hVM2APbLz/rq0zcBCRIhqsqgfgLRLY1VFE9kFgVX0BLsDiSahVCaxE5Lv5ZTIxFJPrYnIPgyeAtuCDYLOnU0BruGEAZo9N9X5OCG1qKSKFXfFg5TVURiT2xe4BEmMOrnNaikgG7AKgOxPrgm9UNU2o3MilhapmInLywHcicjLblnpyrkPAUB0HF7wJvdC31EFwFgCeO+CxUIBsdr1e/V3iVzcqFypUdQswAgpALLgFh7qRREGh71yhSjufo6BjwHa1uapmZs9zwo5aD3yLhBaN1+ur9oe5EqrJYQx0jrvaXSoSqnHFJwtd0S+kMfA8BFw2js87w4XUhX/4wLY7nfD4NWEt0w59r46Ys4hsbVUfHIEEQqFauQtasxIAYwbHwOTP6GiNpzXsqWrBdFOIba9A30BWxDX9YKjJXasFNiPoX8MHx9t/G+gferX5wZLqOhKrM9VQ93CWc96drKa4tP0As8vvCUvsIrEAAAAASUVORK5CYII=)

sentinel

二、 解决方法

  

通过RMAN增量备份解决DATAGUARD断档，不需要重新初始化。

注意：如果使用了‘DataGuard Broker’，在开始前先关闭此功能，所有步骤完成后再重新启动

&nbsp;

1 在standby数据库停止MRP恢复进程

SQL&gt; ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;

&nbsp;

2 在standby数据库确定SCN信息

此SCN为主库增量备份的起始点，使用以下查询最低的SCN值

SQL&gt; select current_scn from v$database;

&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; CURRENT_SCN

\--------------------------------------------------

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp; 15025210932804

&nbsp;

SQL&gt; select min(checkpoint_change#) from v$datafile_header;

&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp; MIN(CHECKPOINT_CHANGE#)

\--------------------------------------------------

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp; 15025210932805

&nbsp;

15025210932804&lt;15025210932805 选择scn 15025210932804作为增量备份起始点

&nbsp;

&nbsp;

3 在primary数据库查询是否有断档以来添加的数据文件

如果有新添加的数据文件则需要额外备份恢复这部分数据文件，如没有则忽略

SQL&gt; SELECT FILE#, NAME FROM V$DATAFILE WHERE CREATION_CHANGE# &gt;
&lt;SCN_NUMBER_FROM_STEP 2&gt;

&nbsp;

eg.

break on report

compute sum of bytes/1024/1024 on report

select bytes/1024/1024,file#,name from v$datafile where creation_change# &gt;
15025210932804;

&nbsp;

BYTES/1024/1024&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; FILE# NAME

\--------------- ----------
------------------------------------------------------------

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;
20480&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 188
+ZY_DATA/jnzyk/datafile/system.460.921764781

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;
20480&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 189
+ZY_DATA/jnzyk/datafile/tbs_pcsyyk_asjdata.461.921764861

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;
20480&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 190
+ZY_DATA/jnzyk/datafile/tbs_pcsyyk_asjdata.462.921764993

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;
20480&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 191
+ZY_DATA/jnzyk/datafile/tbs_pcsyyk_asjdata.463.921765089

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;
20480&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 192
+ZY_DATA/jnzyk/datafile/tbs_pcsyyk_asjdata.464.921765185

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;
20480&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 193
+ZY_DATA/jnzyk/datafile/tbs_yyk_czrkzpdata.465.926159703

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;
20480&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 194
+ZY_DATA/jnzyk/datafile/tbs_yyk_czrkzpdata.466.926159753

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;
20480&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 195
+ZY_DATA/jnzyk/datafile/tbs_yyk_czrkzpdata.467.926159811

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;
20480&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 196
+ZY_DATA/jnzyk/datafile/tbs_yyk_wbzydata.468.926161051

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;
20480&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 197
+ZY_DATA/jnzyk/datafile/tbs_yyk_wbzydata.469.926161157

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;
20480&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 198
+ZY_DATA/jnzyk/datafile/tbs_yyk_wbzydata.470.926161253

\---------------

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;225280

&nbsp;

11 rows selected.

&nbsp;

&nbsp;

4 基于之前步骤查询出的SCN信息，使用RMAN，备份丢失的数据文件及断档以来的增量数据

需要备份：增量备份，新的控制文件

RMAN&gt; backup datafile #, #, #, # format &#39;/tmp/ForStandby_%U&#39; tag
&#39;FORSTANDBY&#39;;&nbsp;&nbsp;&nbsp;&nbsp; --(可选)主库没有新添加的数据文件时忽略

RMAN&gt; backup incremental from SCN 3162298 database format
&#39;/tmp/ForStandby_%U&#39; tag &#39;FORSTANDBY&#39;;

RMAN&gt; backup current controlfile for standby format
&#39;/tmp/ForStandbyCTRL.bck&#39;;

eg.

#!/bin/bash

. ~/.bash_profile

export ORACLE_SID=jnzyk1

DATE=`date +%Y-%m-%d`

rman logfile=/opt/backup/bakdg/bak_dg$DATE.log &lt;&lt;EOF

connect target /

run

{

backup datafile 188,189,190,191,192,193,194,195,196,197,198&nbsp; format
&#39;/opt/backup/bakdg/dgdatafile%U&#39;;

backup incremental from scn 15025210932804 database format
&#39;/opt/backup/bakdg/dgincre%U&#39;;

backup current controlfile for standby format
&#39;/opt/backup/bakdg/dgctl%U&#39;;

}

EOF

&nbsp;

5 传输所有的备份从primary端到standby端

scp /tmp/ForStandby_* standby:/tmp

&nbsp;

6 恢复新的控制文件并注册备份信息

RMAN&gt; shutdown;

RMAN&gt; startup nomount;

RMAN&gt; restore standby controlfile from &#39;/tmp/ForStandbyCTRL.bck&#39;;

RMAN&gt; alter database mount;

RMAN&gt; CATALOG START WITH &#39;/tmp/ForStandby&#39;;  
  
using target database control file instead of recovery catalog  
searching for all files that match the pattern /tmp/ForStandby  
  
List of Files Unknown to the Database  
=====================================  
File Name: /tmp/ForStandby_2lkglss4_1_1  
File Name: /tmp/ForStandby_2mkglst8_1_1  
  
Do you really want to catalog the above files (enter YES or NO)? YES  
cataloging files...  
cataloging done  
  
List of Cataloged Files  
=======================  
File Name: /tmp/ForStandby_2lkglss4_1_1  
File Name: /tmp/ForStandby_2mkglst8_1_1

&nbsp;

&nbsp;

eg.

restore standby controlfile from
&#39;/oradata/backup/zykdg/bakdg/dgctl1mrneud1_1_1&#39;;

&nbsp;

alter database mount;

catalog start with &#39;/oradata/backup/zykdg/bakdg/&#39;;

&nbsp;

7 还原丢失的数据文件（可选）

如果没有则忽略

run

{

set newname for datafile X to &#39;+DISKGROUP&#39;;

set newname for datafile Y to &#39;+DISKGROUP&#39;;

set newname for datafile Z to &#39;+DISKGROUP&#39;;

etc.

restore datafile x,y,z,....;

}

&nbsp;

eg.

#!/bin/bash

. ~/.bash_profile

export ORACLE_SID=jnzyk

DATE=`date +%Y-%m-%d`

rman log=/oradata/backup/zykdg/bakdg/restore_datafile$DATE.log &lt;&lt;EOF

connect target /

run

{

set newname for datafile 188 to
&#39;/oradata/zykdg/JNZYK/datafile/system.460.921764781&#39;;

set newname for datafile 189 to
&#39;/oradata/zykdg/JNZYK/datafile/tbs_pcsyyk_asjdata.461.92176486&#39;;

set newname for datafile 190 to
&#39;/oradata/zykdg/JNZYK/datafile/tbs_pcsyyk_asjdata.462.92176499&#39;;

set newname for datafile 191 to
&#39;/oradata/zykdg/JNZYK/datafile/tbs_pcsyyk_asjdata.463.92176508&#39;;

set newname for datafile 192 to
&#39;/oradata/zykdg/JNZYK/datafile/tbs_pcsyyk_asjdata.464.92176518&#39;;

set newname for datafile 193 to
&#39;/oradata/zykdg/JNZYK/datafile/tbs_yyk_czrkzpdata.465.92615970&#39;;

set newname for datafile 194 to
&#39;/oradata/zykdg/JNZYK/datafile/tbs_yyk_czrkzpdata.466.92615975&#39;;

set newname for datafile 195 to
&#39;/oradata/zykdg/JNZYK/datafile/tbs_yyk_czrkzpdata.467.92615981&#39;;

set newname for datafile 196 to
&#39;/oradata/zykdg/JNZYK/datafile/tbs_yyk_wbzydata.468.926161051&#39;;

set newname for datafile 197 to
&#39;/oradata/zykdg/JNZYK/datafile/tbs_yyk_wbzydata.469.926161157&#39;;

set newname for datafile 198 to
&#39;/oradata/zykdg/JNZYK/datafile/tbs_yyk_wbzydata.470.926161253&#39;;

restore datafile 188,189,190,191,192,193,194,195,196,197,198;

}

EOF

&nbsp;

8 在新的standby控制文件中重命名数据文件

由于新的控制文件是从主端还原的，控制文件中的记录信息都是和主端相匹配，如果主端和备端目录结构不同，需要catalog
datafile以实现重命名操作，如果主端和备端目录结构相同则跳过

RMAN&gt; CATALOG START WITH &#39;+DATA/mystd/datafile/&#39;;  
  
List of Files Unknown to the Database  
=====================================  
File Name: +data/mystd/DATAFILE/SYSTEM.309.685535773  
File Name: +data/mystd/DATAFILE/SYSAUX.301.685535773  
File Name: +data/mystd/DATAFILE/UNDOTBS1.302.685535775  
File Name: +data/mystd/DATAFILE/SYSTEM.297.688213333  
File Name: +data/mystd/DATAFILE/SYSAUX.267.688213333  
File Name: +data/mystd/DATAFILE/UNDOTBS1.268.688213335  
  
Do you really want to catalog the above files (enter YES or NO)? YES  
cataloging files...  
cataloging done  
  
List of Cataloged Files  
=======================  
File Name: +data/mystd/DATAFILE/SYSTEM.297.688213333  
File Name: +data/mystd/DATAFILE/SYSAUX.267.688213333  
File Name: +data/mystd/DATAFILE/UNDOTBS1.268.688213335

&nbsp;Once all files have been cataloged, switch the database to copy:

RMAN&gt; SWITCH DATABASE TO COPY;  
  
datafile 1 switched to datafile copy
&quot;+DATA/mystd/datafile/system.297.688213333&quot;  
datafile 2 switched to datafile copy
&quot;+DATA/mystd/datafile/undotbs1.268.688213335&quot;  
datafile 3 switched to datafile copy
&quot;+DATA/mystd/datafile/sysaux.267.688213333&quot;

&nbsp;

eg.

SQL&gt; select name from v$dbfile;

&nbsp;

NAME

\--------------------------------------------------------------------------------

+ZY_DATA/jnzyk/datafile/users.259.899045457

+ZY_DATA/jnzyk/datafile/undotbs1.258.899045457

+ZY_DATA/jnzyk/datafile/sysaux.257.899045457

+ZY_DATA/jnzyk/datafile/system.256.899045457

+ZY_DATA/jnzyk/datafile/undotbs2.266.899045659

+ZY_DATA/jnzyk/datafile/tbs_pcsyyk_gzdx.272.899048383

+ZY_DATA/jnzyk/datafile/tbs_pcsyyk_jgdata.273.899048387

+ZY_DATA/jnzyk/datafile/tbs_pcsyyk_mlp.274.899048389

+ZY_DATA/jnzyk/datafile/tbs_pcsyyk_zddxdata.275.899048391

+ZY_DATA/jnzyk/datafile/tbs_yyk_yskindex.276.899048395

+ZY_DATA/jnzyk/datafile/tbs_yyk_yskdata.277.899048397

......

&nbsp;

&nbsp;

198 rows selected.

&nbsp;

SQL&gt;

&nbsp;

&nbsp;

catalog start with &#39;/oradata/zykdg/JNZYK/datafile/&#39;;

switch database to copy;

&nbsp;

SQL&gt; select name from v$dbfile;

&nbsp;

NAME

\--------------------------------------------------------------------------------

/oradata/zykdg/JNZYK/datafile/o1_mf_users_cb4190s5_.dbf

/oradata/zykdg/JNZYK/datafile/o1_mf_undotbs1_cb6fns76_.dbf

/oradata/zykdg/JNZYK/datafile/o1_mf_sysaux_cb5894fk_.dbf

/oradata/zykdg/JNZYK/datafile/o1_mf_system_cb41614t_.dbf

/oradata/zykdg/JNZYK/datafile/o1_mf_undotbs2_cb7h1csk_.dbf

/oradata/zykdg/JNZYK/datafile/o1_mf_tbs_pcsy_cb58klj4_.dbf

/oradata/zykdg/JNZYK/datafile/o1_mf_tbs_pcsy_cb419ycz_.dbf

/oradata/zykdg/JNZYK/datafile/o1_mf_tbs_pcsy_cb58l0nj_.dbf

/oradata/zykdg/JNZYK/datafile/o1_mf_tbs_pcsy_cb41b76q_.dbf

/oradata/zykdg/JNZYK/datafile/o1_mf_tbs_yyk__cb58l9no_.dbf

/oradata/zykdg/JNZYK/datafile/o1_mf_tbs_yyk__cb41bo19_.dbf

……

&nbsp;

9 使用增量备份前滚恢复standby数据库

RMAN&gt; RECOVER DATABASE NOREDO;

&nbsp;

eg.

#!/bin/bash

. ~/.bash_profile

export ORACLE_SID=jnzyk

DATE=`date +%Y-%m-%d`

rman log=/oradata/backup/zykdg/bakdg/recover$DATE.log &lt;&lt;EOF

connect target /

run

{

recover database noredo;

}

EOF

&nbsp;

&nbsp;

10 如果standby数据库需要配置闪回，使用以下的命令（可选）

SQL&gt; ALTER DATABASE FLASHBACK OFF;&nbsp;  
SQL&gt; ALTER DATABASE FLASHBACK ON;

&nbsp;

11 standby数据库中所有的standby redo log日志组清空或重建

与步骤8同理，控制文件中记录的日志文件信息可能需要修改

SQL&gt; ALTER DATABASE CLEAR LOGFILE GROUP 1;  
SQL&gt; ALTER DATABASE CLEAR LOGFILE GROUP 2;  
SQL&gt; ALTER DATABASE CLEAR LOGFILE GROUP 3;  
....

eg.

alter database add standby logfile thread 1 group 11
&#39;/oradata/zykdg/JNZYK/onlinelog/standby11.log&#39; reuse;

alter database add standby logfile thread 1 group 12
&#39;/oradata/zykdg/JNZYK/onlinelog/standby12.log&#39; reuse;

alter database drop standby logfile group 19;

alter database add standby logfile thread 2 group 19
&#39;/oradata/zykdg/JNZYK/onlinelog/standby19.log&#39; size 512m;

alter database add standby logfile thread 2 group 20
&#39;/oradata/zykdg/JNZYK/onlinelog/standby20.log&#39; size 512m;

&nbsp;

&nbsp;

&nbsp;

12 在standby数据库启动MRP应用进程

SQL&gt; ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT;

&nbsp;

eg.

alter database recover managed standby database using current logfile
disconnect from session;

&nbsp;

&nbsp;

&nbsp;  

参考mos

Steps &nbsp; &nbsp; &nbsp; to perform for Rolling forward a standby database
using RMAN incremental &nbsp; &nbsp; &nbsp; backup when datafile is added to
primary (Doc ID 1531031.1)

Steps to perform for Rolling Forward a Physical Standby Database using RMAN
Incremental Backup. (Doc ID 836986.1)

  
  
---  
  
  

  

" name="docDetail" type="hidden">


---
### ATTACHMENTS
[7f025a17697ee15eb3197c61326b203b]: media/Oracle-指导手册-Oracle_使用RMAN增量备份前滚恢复Dataguard断档操作.html
[Oracle-指导手册-Oracle_使用RMAN增量备份前滚恢复Dataguard断档操作.html](media/Oracle-指导手册-Oracle_使用RMAN增量备份前滚恢复Dataguard断档操作.html)
>hash: 7f025a17697ee15eb3197c61326b203b  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-指导手册-Oracle 使用RMAN增量备份前滚恢复Dataguard断档操作_files\11947ec6e06f4dd6a765bcc48c4fc88d.png  

---
### NOTE ATTRIBUTES
>Created Date: 2018-09-25 03:29:42  
>Last Evernote Update Date: 2018-10-01 15:33:46  
>author: YangKwong  
>source: desktop.win  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-指导手册-Oracle 使用RMAN增量备份前滚恢复Dataguard断档操作.html  
>source-application: evernote.win32  