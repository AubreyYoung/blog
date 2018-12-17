> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://www.kancloud.cn/digest/rman/148821

Oracle 版本 9 因为控制文件的自动备份，可以很大程度成不需要使用恢复目录，但是使用恢复目录的也有如下好处
· 有些命令只被恢复目录支持（对于 9i 来说，也就是专门操作恢复目录的语句而已）
· 能保留更多的历史备份信息
· 一个恢复目录能管理与备份多个目标数据库
· 如果在 9i 以前，丢失控制文件而没有恢复目录将是难以恢复的
· 如果没有恢复目录，而且发生了结构上的改变，时间点的恢复需要小心操作
· 能存储备份与恢复的脚本
可以看到，主要是可以保留更多的备份信息与方便的管理多个目标数据库，这个在众多目标数据库的情况下，是可以考虑的。

## <a id="_9"></a>一、创建恢复目录

注意，恢复目录不要与目标数据库在同一台机器上，而且大小要求比较小。

```
SQL> create user RMAN identified by RMAN   
2 temporary tablespace TEMP   
3 default tablespace RCVCAT   
4 quota unlimited on RCVCAT;   
SQL> grant recovery_catalog_owner to RMAN;   
RMAN> create catalog   
RMAN> register database;   

```

恢复目录可以采用如下命令升级与删除

```
RMAN> UPGRADE CATALOG;   
RMAN> DROP CATALOG;   

```

## <a id="_25"></a>二、恢复目录管理

恢复目录支持如下的命令

```
{CREATE|UPGRADE|DROP} CATALOG   
{CREATE|DELETE|REPLACE|PRINT} SCRIPT   
LIST INCARNATION   
REGISTER DATABASE   
REPORT SCHEMA AT TIME   
RESET DATABASE   
RESYNC CATALOG   

```

1、Resync 命令
Resync 可以同步数据库与恢复目录之间的信息，在实际情况下，rman 一般可以自动同步。
在如下情况下需要同步
· 数据库物理结构的改变
· 数据文件增加或者是改变大小
· 表空间删除
· 回滚段的创建与删除
· 每产生 10 个归档日志
2、Reset  命令
目标数据库 resetlogs 之后，需要重新设置恢复目录。Reset 命令就用来重新设置恢复目录。

## <a id="_46"></a>三、恢复目录视图

恢复目录本身有一组视图，用于存放目标数据库与备份信息，如恢复目录的相关视图

```
RC_DATABASE   
RC_DATAFILE   
RC_STORED_SCRIPT   20  
RC_STORED_SCRIPT_LINE   
RC_TABLESPACE   

```

可以通过如下命令来查看相关信息
`select * from rc_database;`

## <a id="_57"></a>四、存储脚本

存储脚本

```
RMAN> creata script level0backp{   
       backup   
       incremental level 0   
       format '/u01/db01/backup/%U'   
       filesperset 5   
       database plus archivelog delete input;   
       sql 'alter database archive log current';   
       }   
**执行脚本   
**RMAN> run {execute script Level0backup;}   
**更新脚本   
**RMAN> replace script level0backup{   
      ……   
       }   
**删除脚本**  
RMAN> delete script Level0backup;   
**查看脚本**  
RMAN> print script level0backup;   

```

一个实用脚本，包括备份 RAC 数据库与归档日志的 shell 脚本

```
[oracle@db worksh]$ more rmanback.sh    
#!/bin/sh   
#set env   
export ORACLE_HOME=/opt/oracle/product/9.2   
export ORACLE_SID=db2in1   
export NLS_LANG="AMERICAN_AMERICA.zhs16gbk"   
export PATH=$PATH:$ORACLE_HOME/bin:/sbin:/usr/sbin   

echo "-----------------------------start-----------------------------";date   
#backup start   
$ORACLE_HOME/bin/rman <<EOF   
connect target   
delete noprompt obsolete;   
backup database include current controlfile format '/rmanback/db2/%U_%s.bak' filesperset = 2;  

run{   
ALLOCATE CHANNEL node_c1 DEVICE TYPE DISK CONNECT ['sys/pass@db1in1'](#);  
ALLOCATE CHANNEL node_c2 DEVICE TYPE DISK CONNECT ['sys/pass@db2in2'](#);  
sql 'ALTER SYSTEM ARCHIVE LOG CURRENT';   
backup archivelog all delete input format '/ rmanback/db2/%U_%s.bak' filesperset = 5;  
}   

list backup;   
exit;   
EOF   
echo "------------------------------end------------------------------";date

```

[Oracle 社区 PDM 中文网](http://www.pdmcn.com/bbs)：[http://www.pdmcn.com/bbs](http://www.pdmcn.com/bbs),

Oracle 专家 QQ 群：60632593、60618621

Oracle 技术资料：《Oracle 9i RMAN 参考使用手册》、《ORACLE10G 备份与恢复》、《**Oracle Database 10gRMAN 备份与恢复**》