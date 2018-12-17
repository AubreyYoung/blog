> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://blog.csdn.net/newhappy2008/article/details/6587126 版权声明：本文为博主原创文章，未经博主允许不得转载。 https://blog.csdn.net/newhappy2008/article/details/6587126 <link rel="stylesheet" href="https://csdnimg.cn/release/phoenix/template/css/ck_htmledit_views-d7e2a68c7c.css">

 1\. 相关视图

        v$backup_files

        v$backup_set

        v$backup_piece

        v$backup_redolog

        v$backup_spfile

        v$backup_device

        v$rman_configuration

        v$archived_log

        v$backup_corruption

        v$copy_corruption

        v$database_block_corruption

        v$backup_datafile

    2\. 查看 channel 对应的 server sessions

            使用 set command id 命令

        查询 v$process 和 v$session 判断哪一个会话与之对应的 RMAN 通道

        SQL> select sid,username,client_info from v$session

          2  where client_info is not null;

               SID USERNAME                       CLIENT_INFO

        ---------- ------------------------------ ------------------------------

               146 SYS                            rman channel=ORA_DISK_1

               148 SYS                            rman channel=ORA_DISK_2

               150 SYS                            rman channel=ORA_DISK_3

        -- 下面使用了 set command id 命令

        RMAN> run{

        2> allocate channel ch1 type disk;

        3> set command id to 'rman';

        4> backup as copy datafile 4

        5> format '/u01/app/oracle/rmanbak/dd_%U';

        6> }

        SQL> select sid,username,client_info from v$session

          2   where client_info is not null;

               SID USERNAME                       CLIENT_INFO

        ---------- ------------------------------ ------------------------------

               140 SYS                            id=rman

        SQL> select sid,spid,client_info

          2  from v$process p ,v$session s

          3  where p.addr = s.paddr

          4  and client_info like '%id=%';

               SID SPID         CLIENT_INFO

        ---------- ------------ ------------------------------

               140 5002         id=rman 

        -- 查看 rman 完整的进度      

        SQL> select sid,serial#,context,sofar,totalwork,

          2  round(sofar/totalwork*100,2) "% Complete"

          3  from v$session_longops

          4   where opname like 'RMAN:%'

          5  and opname not like 'RMAN:aggregate%'

          6  and totalwork!=0;    

        -- 通过如下 SQL 获得 rman 用来完成备份操作的服务进程的 SID 与 SPID 信息：

        select sid, spid, client_info

          from v$process p, v$session s

         where p.addr = s.paddr

           and client_info like '%id=rman%'

    3.Linux 下的 rman 自动备份

        备份脚本 + crontab

        bak_inc0 ：级增量备份，每周日使用级增量进行备份

        bak_inc1 ：级增量备份，每周三使用级增量备份，备份从周日以来到周三所发生的数据变化

        bak_inc2 ：级增量备份，备份每天发生的差异增量。如从周日到周一的差异，从周一到周二的差异

        -- 下面是级增量的脚本，其余级与级依法炮制，所不同的是备份级别以及 tag 标记

        [oracle@oradb scripts]$ cat bak_inc0

        run {

        allocate channel ch1 type disk;

        backup as compressed backupset  incremental level 0

        format '/u01/oracle/bk/rmbk/incr0_%d_%U'

        tag 'day_incr0'

        database plus archivelog delete input;

        release channel ch1;

        }

        逐个测试脚本

        [oracle@oradb bk]$ rman target / log=/u01/oracle/bk/log/bak_inc0.log /

        > cmdfile=/u01/oracle/bk/scripts/bak_inc0.rcv

        RMAN> 2> 3> 4> 5> 6> 7> 8> 9>

        [oracle@oradb bk]$

        编辑 crontab

        [root@oradb ~]# whoami

        root

        [root@oradb ~]# crontab -e -u oracle

        45 23 * * 0 rman target / log=/u01/oracle/bk/log/bak_inc0.log append cmdfile =/u01/oracle/bk/scripts/bak_inc0.rcv

        45 23 * * 1 rman target / log=/u01/oracle/bk/log/bak_inc2.log append cmdfile =/u01/oracle/bk/scripts/bak_inc2.rcv

        45 23 * * 2 rman target / log=/u01/oracle/bk/log/bak_inc2.log append cmdfile =/u01/oracle/bk/scripts/bak_inc2.rcv

        45 23 * * 3 rman target / log=/u01/oracle/bk/log/bak_inc1.log append cmdfile =/u01/oracle/bk/scripts/bak_inc1.rcv

        45 23 * * 4 rman target / log=/u01/oracle/bk/log/bak_inc2.log append cmdfile =/u01/oracle/bk/scripts/bak_inc2.rcv

        45 23 * * 5 rman target / log=/u01/oracle/bk/log/bak_inc2.log append cmdfile =/u01/oracle/bk/scripts/bak_inc2.rcv

        45 23 * * 6 rman target / log=/u01/oracle/bk/log/bak_inc2.log append cmdfile =/u01/oracle/bk/scripts/bak_inc2.rcv

        "/tmp/crontab.XXXXInBzgR" 7L, 791C written

        crontab: installing new crontab

        保存之后重启 crontab

        [root@oradb ~]# service crond restart

        Stopping crond: [OK]

        Starting crond: [OK]

        检查自动备份是否成功执行