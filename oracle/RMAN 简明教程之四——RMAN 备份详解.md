> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://www.kancloud.cn/digest/rman/148818

RMAN 可以用来备份主备用数据库，如表空间、数据文件、归档日志、控制文件、服务器文件与备份集，下面我们分情况进行试验。

## <a id="_2"></a>一、文件拷贝

原始文件的拷贝，有点类似于 OS 热备份，可以拷贝整个数据文件到另外一个地点，但是结果仅仅只能写入到硬盘，而且单独的文件是分开的。
数据文件拷贝实例：

```
run {   
allocate channel d1 type disk;   
allocate channel d2 type disk;   
allocate channel d3 type disk;   
copy # first   
datafile 1 to '$HOME/prd1.dbf',   
datafile 2 to '$HOME/prd2.dbf';   
copy # second   
datafile 3 to '$HOME/prd3.dbf';   
sql 'alter system archive log current';   
}   

```

## <a id="_18"></a>二、备份与备份集

RMAN 的常规备份是产生只有 RMAN 才能识别的备份集，所以，除了 copy 命令之外的其他备份，都是 RMAN 产生的备份集以及对应的备份片。
如下是备份数据库的实例，它开启两个通道，将数据库备份到磁带：

```
run {   
allocate channel t1 type 'SBT_TAPE';   
allocate channel t2 type 'SBT_TAPE';   
backup   
filesperset 2   
format 'df_%t_%s_%p'   
database;   
}   

```

RMAN 也可以实现多个镜相的备份：

```
Run{   
allocate channel d1 type disk;   
allocate channel d2 type disk;   
allocate channel d3 type disk;   
SET BACKUP COPIES 3;   
BACKUP DATAFILE 7 FORMAT '/tmp/%U','?/oradata/%U','?/%U';   
};   

```

以下是常见的备份归档的例子：

```

RMAN>sql ‘alter system archive log current’;   
RMAN>backup archivelog all delete input;   
RMAN> backup archivelog from time '01-jan-00' until time '30-jun-00';   
RMAN> backup archivelog like 'oracle/arc/dest/log%';   10  
RMAN> backup archivelog all;   
RMAN> backup archivelog from logseq 20 until logseq 50 thread 1;   
RMAN> backup archivelog from scn 1 until scn 9999;   

```

在 RAC 环境中，因为数据库是共享的，所以可以连接到一个实例就可以备份整个数据库，但是，因为归档日志可以备份在本地，所以 RAC 归档日志的备份就变的复杂一些，我们可以通过连接到两个实例的通道来备份两个实例的归档日志。

```
run{   
ALLOCATE CHANNEL node_c1 DEVICE TYPE DISK CONNECT ['sys/pass@dbin1'](#);  
ALLOCATE CHANNEL node_c2 DEVICE TYPE DISK CONNECT ['sys/pass@dbin2'](#);  
sql 'ALTER SYSTEM ARCHIVE LOG CURRENT';   
backup archivelog all delete input format '/u01/dbbak/%U_%s.bak' filesperset = 5;  
}   

```

## <a id="_61"></a>三、常见备份参数

1、Keep 参数可以长期的保持特殊的备份或者拷贝，让它们不受默认备份保持策略的影响，如

```
RMAN> BACKUP DATABASE KEEP UNTIL TIME   
2> "to_date('31-MAR-2002','DD_MM_YYYY)" nologs;   
RMAN> BACKUP TABLESPACE SAMPLE KEEP FOREVER NOLOGS;   

```

其中 NOLOGS 表示可以不保留该备份以来的归档日志，默认是 LOGS，表示保留该备份以来的参数，如果想让该备份永久有效，可以使用 FOREVER 参数。
2、Tag 参数指明了备份集的标志，可以达到 30 个字符长度，如

```
RMAN> BACKUP DEVICE TYPE DISK DATAFILE 1 TAG   
2> "wkly_bkup";   

```

在 Oracle  92 版本以后，RMAN 自动提供一个 TAG，格式为 TAGYYYYMMDDTHHMMSS 如 TAG20020208T133437，通过备份标志 TAG，也可以很方便的从备份集进行恢复，如 Restore database from tag=’tag name’

## <a id="_75"></a>四、增量备份

在说明增量备份之前， 首先要理解差异增量与累计增量备份，以及增量备份的备份与恢复原理。差异增量，是默认的增量备份方式。 差异增量是备份上级或同级备份以来变化的块，累计增量是备份上级备份以来变化的块。累计增量增加了备份的时间，但是因为恢复的时候，需要从更少的备份集中恢复数据，所以，为了减少恢复的时候，累计增量备份将比差异增量备份更有效。 
不管怎么样增量备份，在 Oracle 版本 9 中，还是需要比较数据库中全部的数据块，这个过程其实也是一个漫长的过程，而且由于增量备份形成多个不同的备份集，使得恢复变的更加不可靠而且速度慢，所以增量备份在版本 9 中仍然是鸡肋，除非是很大型的数据仓库系统，没有必要选择增量备份。
Oracle 版本 10 在增量备份上做了很大的改进，可以使增量备份变成真正意义的增量，因为通过特有的增量日志，使得 RMAN 没有必要去比较数据库的每一个数据块，当然，代价就是日志的 IO 与磁盘空间付出，完全还是不适合 OLTP 系统。另外，版本 10 通过备份的合并，使增量备份的结果可以合并在一起，而完全的减少了恢复时间。
增量备份都需要一个基础，比如 0 级备份就是所有增量的基础备份，0 级备份与全备份的不同就是 0 级备份可以作为其它增量备份的基础备份而全备份是不可以的， 是否选择增量备份作为你的备份策略，最终，需要你自己有一个清醒的认识。
以下是零级备份的例子
backup incremental level 0 database;
一级差异增量例子
backup incremental level 1 database;
一级累计增量例子
backup incremental level 1 cumulative database;   12

## <a id="_86"></a>五、备份检查

我们可以通过 Validate 命令来检查是否能备份，如数据文件是否存在，是否存在坏块不能被备份，如：
BACKUP VALIDATE DATABASE;
BACKUP VALIDATE DATABASE ARCHIVELOG ALL;

## <a id="_90"></a>六、重新启动备份

对于异常结束了的备份，很多人可能不想再重新开始备份了吧，特别是备份到 90% 以上，因为异常原因终止了该备份，那怎么办呢？RMAN 提供一个重新开始备份的方法，通过简单的命令，你就可以只备份那不到 10% 的数据了。

```
RMAN> BACKUP NOT BACKED UP SINCE TIME 'SYSDATE-14'   
2> DATABASE PLUS ARCHIVELOG;   

```

## <a id="RMAN__96"></a>七、RMAN 动态性能视图

以下是与 RMAN 备份有关系的一些动态性能视图，信息是从控制文件中获取的。

```
V$ARCHIVED_LOG   
V$BACKUP_CORRUPTION   
V$COPY_CORRUPTION   
V$BACKUP_DATAFILE   
V$BACKUP_REDOLOG   
V$BACKUP_SET   
V$BACKUP_PIECE   
V$BACKUP_DEVICE   
V$CONTROLFILE_RECORD_SECTION   

```

这里还有一个视图，可以大致的监控到 RMAN 备份进行的程度。如通过如下的 SQL 脚本，
将获得备份的进度。

```
SQL> SELECT SID, SERIAL#, CONTEXT, SOFAR, TOTALWORK,   
2 ROUND(SOFAR/TOTALWORK*100,2) "%_COMPLETE"   
3 FROM V$SESSION_LONGOPS   
4 WHERE OPNAME LIKE 'RMAN%'   
5 AND OPNAME NOT LIKE '%aggregate%'   
6 AND TOTALWORK != 0   
7 AND SOFAR <> TOTALWORK;   
SID SERIAL# CONTEXT SOFAR    TOTAL   WORK %_COMPLETE   
---    -------      -------        -------     ---------    ----------   
13   75          1           9470      15360    61.65   
12   81          1           15871    28160    56.36   

```

Oracle 社区 PDM 中文网：[http://www.pdmcn.com/bbs](http://www.pdmcn.com/bbs),

Oracle 专家 QQ 群：60632593、60618621

Oracle 技术资料：《Oracle 9i RMAN 参考使用手册》、《ORACLE10G 备份与恢复》、《**Oracle Database 10gRMAN 备份与恢复**》