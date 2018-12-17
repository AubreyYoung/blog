> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://www.kancloud.cn/digest/rman/148816

## <a id="_0"></a>一、运行要求

1、进程与内存要求

更多的进程的需要

大池的分配

2、基本环境变量需求

ORACLE_SID, ORACLE_HOME, PATH, NLS_LANG, 如果用到了基于时间的备份与恢复，需要另外设置 NLS_DATE_FORMAT

3、权限要求

需要 SYSDBA 系统权限

如果是本地，可以采用 OS 认证，远程需要采用密码文件认证

4、版本要求

RMAN 工具版本与目标数据库必须是同一个版本，如果使用了恢复目录，还需要注意

· 创建 RMAN 恢复目录的脚本版本必须等于或大于恢复目录所在数据库的版本

· 创建 RMAN 恢复目录的脚本版本必须等于或大于目标数据库的版本

## <a id="_25"></a>二、基本运行方法

9i 默认是 nocatalog，不使用恢复目录，使用命令 rman 即可进入 RMAN 的命令行界面，如

```
[oracle@db oracle]$ $ORACLE_HOME/bin/rman  
Recovery Manager: Release 9.2.0.4.0 - Production  
Copyright (c) 1995, 2002, Oracle Corporation. All rights reserved.  
RMAN>

```

连接目标数据库，可以用如下类似命令
RMAN>Connect target /

## <a id="RMAN__39"></a>三、如何运行 RMAN 命令

1、单个执行

```

RMAN>backup database;

```

2、运行一个命令块

```

RMAN> run {  
2> copy datafile 10 to  
3> '/oracle/prod/backup/prod_10.dbf';  
4> }

```

3、运行脚本

```
$ rman TARGET / @backup_db.rman  
RMAN> @backup_db.rman  
RMAN> RUN { @backup_db.rman }

```

运行存储在恢复目录中的脚本

```

RMAN> RUN { EXECUTE SCRIPT backup_whole_db };

```

4、SHELL 脚本，如果在 cron 中执行，注意设置正确的环境变量在脚本中

```
[oracle@db worksh]$ more rmanback.sh  
#!/bin/ksh  
#set env  
export ORACLE_HOME=/opt/oracle/product/9.2  
export ORACLE_SID=test  
export NLS_LANG="AMERICAN_AMERICA.zhs16gbk"  
export PATH=$PATH:$ORACLE_HOME/bin  
echo "-----------------------------start-----------------------------";date  
#backup start  
$ORACLE_HOME/bin/rman < connect target  
delete noprompt obsolete;  
backup database format '/netappdata1/rmanback/tbdb2/%U_%s.bak' filesperset = 2;  
exit;  
EOF  
echo "------------------------------end------------------------------";date

```

推荐 Oracle 社区：[http://www.pdmcn.com/bbs](http://www.pdmcn.com/bbs),  oracle QQ 群：60632593、60618621
推荐 Oracle 技术资料：《Oracle 9i RMAN 参考使用手册》、《ORACLE10G 备份与恢复》、《Oracle Database 10gRMAN 备份与恢复》