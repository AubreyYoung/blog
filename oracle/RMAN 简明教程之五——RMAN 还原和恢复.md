> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://www.kancloud.cn/digest/rman/148819

## <a id="_0"></a>一、常规还原与恢复

RMAN 的整个恢复过程可以分为还原（restore）与恢复（recover） ，他们在含义上是有很大差别的，一个是指物理意义的文件的还原与拷贝，一个是指数据库一致性的恢复，所以，正确的理解这两个概念，有助于正确的恢复数据库。
对于 RMAN 的备份，还原操作只能是在用 RMAN 或 RMAN 包来做了，对于恢复操作则是很灵活的了，除了 RMAN，也可以在 SQLPLUS 中完成。还原与恢复一个数据库，可以用如下两个简单的命令完成

```
RMAN>restore database;   
RMAN>recover database;   

```

恢复一个表空间，或者恢复一个数据文件，相对比较恢复数据库可能花费更少的时间。

```
RMAN> SQL "ALTER TABLESPACE tools OFFLINE IMMEDIATE";   
RMAN> RESTORE TABLESPACE tools;   
RMAN> RECOVER TABLESPACE tools;   
RMAN> SQL "ALTER TABLESPACE tools ONLINE";   

```

对于数据库与数据文件，可以从指定的 tag 恢复
`RMAN>RESTORE DATAFILE 1 FROM TAG=’tag name’`
对于时间点恢复等不完全恢复，可能只有完全的还原数据库了。

```
RMAN> RUN {   
2> ALLOCATE CHANNEL c1 TYPE DISK;   
3> ALLOCATE CHANNEL c2 TYPE DISK;   
4> SET UNTIL TIME = '2002-12-09:11:44:00';   
5> RESTORE DATABASE;   
6> RECOVER DATABASE;   
7> ALTER DATABASE OPEN RESETLOGS; }   

```

不完全恢复在 RMAN 中还可以用基于日志的恢复

```
RMAN> RUN {   
2> SET UNTIL SEQUENCE 120 THREAD 1;   
3> ALTER DATABASE MOUNT;   
4> RESTORE DATABASE;   
5> RECOVER DATABASE; # recovers through log 119   
6> ALTER DATABASE OPEN RESESTLOGS;   
7> }   

```

如果有可能，也可以恢复数据文件到一个新的位置

```
SET NEWNAME FOR datafile   
'/u01/oradata/tools01.dbf' TO '/tmp/tools01.dbf';   
RESTORE datafile '/u01/oradata/tools01.dbf';   
SWITCH DATAFILE ALL;   

```

除了恢复数据库与数据文件，我们也可以恢复控制文件，需要启动到 nomount 下，用如下
的命令即可   14

```
Restore controlfile from ‘file name’   
Restore controlfile from autobackup   
Restore controlfile from tag=‘……’   

```

在正常情况下，不用恢复归档日志，恢复进程会自动寻找所需要的归档日志，当然我们也可以指定恢复到哪里。

```
SET ARCHIVELOG DESTINATION TO '/u02/tmp_restore';   
RESTORE ARCHIVELOG ALL;   

```

如果使用的服务器参数文件（spfile） ，RMAN 可以备份该参数文件，如果发生文件损坏，可以用 RMAN 恢复 spfile 参数文件，在没有参数文件的情况下，用 Rman 的临时参数文件启动数据库到 Nomount 下，执行如下命令即可

```
Restore controlfile from autobackup    
Restore controlfile from ‘file name’   

```

## <a id="_60"></a>二、特殊情况下的恢复

在假定丢失了恢复目录与控制文件，只剩下备份集与备份片，这个时候，可能只能从文件中恢复了。以下是调用 dbms_backup_restore 包，从文件中恢复的例子。

```
declare   
devtype varchar2(100);   
done boolean;   
recid number;   
stamp number;   
fullname varchar2(80);   
begin   
devtype :=   
dbms_backup_restore.deviceallocate('sbt_tape',params=>'ENV=   
(NSR_SERVER=backup_server)');   
dbms_backup_restore.restoresetdata file;   
dbms_backup_restore.restorecontrolfileto(   
'first_control_file');   
dbms_backup_restore.restorebackuppiece('backup_piece', done);   
dbms_backup_restore.copycontrolfile ('first_control_file',   
'second_control_file', recid, stamp,fullname);   
-- repeat the above copycontrolfile for each control file   
end; /   

```

## <a id="_82"></a>三、还原检查与恢复测试

与备份检查一样，还原操作也可以检查是否能正常 restore 或者是否该备份集是否有效。如：

```
RMAN> RESTORE DATABASE VALIDATE;   
RMAN> VALIDATE BACKUPSET 218;   

```

Recover 还可以进行测试，检测恢复的错误，错误信息记载在 alert 文件中，通过测试，我们可以知道该恢复操作是否能正常完成。   15

```
SQL>RECOVER TABLESPACE sales TEST;   
SQL>RECOVER DATABASE UNTIL CANCEL TEST   

```

## <a id="_93"></a>四、块级别的恢复

块恢复 Block Media Recovery (BMR)， 块是恢复的最小单元， 通过块可以减少恢复时间，而且数据文件可以在线。恢复块的时候，必须指定具体的块号，如：
`BLOCKRECOVER datafile 6 BLOCK 3;`
要恢复的坏块信息可以从报警与跟踪文件，表与索引的分析，DBV 工具或第三方媒体管理工具以及具体的查询语句中获得。产生块损坏的原因一般是间断或随机的 IO 错误或者是内存的块错误。
块的错误信息保存在 V$DATABASE_BLOCK_CORRUPTION，用如下命令恢复该视图中列出的坏块

```
RMAN> BLOCKRECOVER CORRUPTION LIST   
2> RESTORE UNTIL TIME 'sysdate – 10';   

```

备份的坏块信息保存在

```
V$BACKUP_CORRUPTION   
V$COPY_CORRUPTION   

```

可以用如下的命令来恢复坏块。

```
BLOCKRECOVER datafile 2 BLOCK 12, 13 datafile 7 BLOCK 5, 98, 99 datafile 9 BLOCK 19;  
BLOCKRECOVER  TABLESPACE  SYSTEM  DBA  4194404,  4194405  FROM  TAG   
"weekly_backup";   
BLOCKRECOVER TABLESPACE SYSTEM DBA 4194404, 4194405 RESTORE UNTIL TIME   
'SYSDATE-2';   

```

## <a id="_115"></a>五、数据库复制

可以用 RMAN 来进行数据库的复制与克隆，RMAN 提供一个专门的命令来完成这个操作。如

```
CONNECT TARGET   
CONNECT AUXILIARY [SYS/aux_pwd@newdb](#)  
DUPLICATE TARGET DATABASE TO ndbnewh    
   LOGFILE    
     '?/dbs/log_1.f' SIZE 100M,   
     '?/dbs/log_2.f' SIZE 100M    
   SKIP READONLY    
   NOFILENAMECHECK;   

```

在以上的命令执行之前，注意如下几点
1、备份主库上的所有数据文件，控制文件以及备份时与备份后产生的归档日志，并把该备份拷贝到需要复制的机器同样的目录下（如果不是同样的目录，在 linux/unix 环境下可以考虑建立一个链接来完成） 。
2、拷贝主数据库的初始化参数文件到复制的机器上，并做相应的修改，如修改数据库名称与实例名称

3、在要复制的机器上创建新的密码文件，并启动复制的数据库到 nomount 下。
4、配置主数据库到复制数据库的网络连接或者复制数据库到主数据库的连接。
5、在主数据库或者复制的数据库上运行 RMAN，分别连接主数据库与复制数据库实例。
6、运行复制命令，命令将还原所有数据文件，重新创建控制文件，并利用新的参数文件启动恢复数据库到一致状态，最后用 resetlog 方式打开数据库，创建指定的 redolog。
复制命令也可以从磁带上的备份进行复制，并改变数据库名称，也可以改变数据库文件的新的路径以及恢复到以前的时间点， 跳过不需要复制的表空间等， 如一个比较复杂的复制命令：

```
RUN   
{     
   ALLOCATE AUXILIARY CHANNEL newdb1 DEVICE TYPE sbt;    
   DUPLICATE TARGET DATABASE TO newdb   
   DB_FILE_NAME_CONVERT=('/h1/oracle/dbs/trgt/','/h2/oracle/oradata/newdb/')   
   UNTIL TIME 'SYSDATE-1'   # specifies incomplete recovery   
   SKIP TABLESPACE cmwlite, drsys, example    # skip desired tablespaces   
   PFILE = ?/dbs/initNEWDB.ora   
   lOGFILE   
       GROUP 1 ('?/oradata/newdb/redo01_1.f',    
                  '?/oradata/newdb/redo01_2.f') SIZE 200K,    
       GROUP 2 ('?/oradata/newdb/redo02_1.f',    
                  '?/oradata/newdb/redo02_2.f') SIZE 200K    
       GROUP 3 ('?/oradata/newdb/redo03_1.f',   
                  '?/oradata/newdb/redo03_2.f') SIZE 200K REUSE;   
}   

```

## <a id="_RMAN_154"></a>六、利用 RMAN 创建备用数据库

利用 RMAN 创建备用数据库可以用两种办法，一种是常规的 Restore 命令，利用从主数据库拷贝过去的备用控制文件，把备用数据库启动到备用 mount 下，这个时候的备用数据库是没有数据文件的。 然后在备用端， 启动 RMAN 命令， 连接该数据库 （与主数据库 DBID 一样） ，把从主数据库拷贝过来的 RMAN 备份还原出来。最后就与其它方法一样了，进入备用的管理恢复模式。
另外一个办法就是复制命令了，如
DUPLICATE TARGET DATABASE FOR STANDBY NOFILENAMECHECK;
以下详细的介绍了这一个过程。
1、创建备用参数文件与密码文件，启动备用数据库到 nomount 下
2、备份主数据库与备用控制文件以及所有归档

```
RMAN> Backup Database;   
RMAN> Backup current controlfile for standby;   
RMAN> sql "Alter System Archive Log Current";    
RMAN> Backup filesperset 10 ArchiveLog all delete input;   

```

3、拷贝所有的备份到备用数据库相同路径下
4、配置主数据库到备用数据库的连接
5、启动 RMAN
`rman target / auxiliary [sys/change_on_install@STANDBY](#)    17`
6，开始创建备用数据库
`RMAN> duplicate target database for standby dorecover nofilenamecheck;`
整个过程包括了备用控制文件的创建，启动到 Mount 下，参数文件中指定的路径转换与数据文件的还原，归档日志的还原等。
7、最后恢复日志并启动到管理恢复模式下。

```
SQL> recover standby database;    
SQL> alter database recover managed standby database disconnect;

```

Oracle 社区 PDM 中文网：[http://www.pdmcn.com/bbs](http://www.pdmcn.com/bbs),

Oracle 专家 QQ 群：60632593、60618621

Oracle 技术资料：《Oracle 9i RMAN 参考使用手册》、《ORACLE10G 备份与恢复》、《**Oracle Database 10gRMAN 备份与恢复**》