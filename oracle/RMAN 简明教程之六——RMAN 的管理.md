> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://www.kancloud.cn/digest/rman/148820

## <a id="Report_0"></a>一、Report 命令

Report 命令可以检测那些文件需要备份，那些备份能被删除以及那些文件能不能获得的信息，如
报告数据库的所有能备份数据文件对象
Report schema
或者

```
RMAN> REPORT SCHEMA AT TIME 'SYSDATE-14';   
RMAN> REPORT SCHEMA AT SCN 1000;   
RMAN> REPORT SCHEMA AT SEQUENCE 100 THREAD 1;   

```

报告需要备份的数据文件
`Report need backup [ redundancy | days | incremental n];`
报告过期了的数据文件或者不可用的备份与拷贝
`Report obsolete [orphan]`
报告不能获得或者不能到达的数据文件信息
`Report unrecoverable [database]`

## <a id="List_16"></a>二、List 命令

List 命令一般用来查看备份与拷贝信息，如
查看备份信息
List backup
查看备份汇总信息
List backup summary
查看文件拷贝的信息
List copy
查看具体的备份信息
List backup of datafile ‘file name’
list incarnation of database;   18

## <a id="Crosscheck_27"></a>三、Crosscheck 命令

检查磁盘或磁带上的备份或拷贝是否正确，并更新备份或者拷贝的状态。如果不正确，将标记为 expired（过期）
Crosscheck backup;
Crosscheck archivelog all;
Delete [noprompt] expired backup 命令删除过期备份
也可以用 List 来查看相应的报告
LIST EXPIRED BACKUP;
LIST EXPIRED BACKUP SUMMARY;

## <a id="_Delete__35"></a>四、 Delete 命令

Delete 命令可以用来删除指定的备份或者用来删除废弃或者是过期的备份集如删除指定的备份集与备份片

```
RMAN> DELETE BACKUPPIECE 101;   
RMAN> DELETE CONTROLFILECOPY '/tmp/control01.ctl';   
RMAN> DELETE BACKUP OF TABLESPACE users DEVICE TYPE sbt;   

```

删除过期或者废弃了的备份

```
RMAN> DELETE EXPIRED BACKUP;   
RMAN> DELETE NOPROMPT OBSOLETE;   
RMAN> DELETE OBSOLETE REDUNDANCY = 3;   
RMAN> DELETE OBSOLETE RECOVERY WINDOW OF 7 DAYS;   

```

删除指定的备份归档

```
RMAN> DELETE NOPROMPT ARCHIVELOG UNTIL SEQUENCE = 300; 

```

[PDM 中文网 Oracle 社区](http://www.pdmcn.com/bbs)：[http://www.pdmcn.com/bbs](http://www.pdmcn.com/bbs),

Oracle 专家 QQ 群：60632593、60618621

Oracle 技术资料：《Oracle 9i RMAN 参考使用手册》、《ORACLE10G 备份与恢复》、《**Oracle Database 10gRMAN 备份与恢复**》