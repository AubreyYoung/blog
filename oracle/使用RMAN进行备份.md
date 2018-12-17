 #  使用RMAN进行备份

## 备份整个数据库

```
RMAN> backup database format '/u01/app/oracle/rmanbak/whole_%d_%U';
//备份整个数据库并压缩备份集
RMAN> backup as compressed backupset database format '/u01/app/oracle/rmanbak/whole_%d_%U';

RMAN> run{
allocate channel ch1 type disk  							//手动分配一个通道
maxpiecesize=2g;										   //指定备份片的大小为 g
backup as compressed backupset								//压缩备份集
format '/rmanbak/whole_%d_%U' filesperset=3 database;	   	  //指定备份集中允许容纳的文件数为个
release channel ch1;}									   //释放通道

RMAN> configure device type disk parallelism 3; 			 //将并行度改为3

RMAN> run{
2> allocate channel ch1 type disk
3> maxpiecesize=100m;  //备份片大小设置为m, 则一个备份集包含多个备份片, 且每个备份片大小为m
4> backup
5> format '/u01/app/oracle/rmanbak/whole_%d_%U'
6> database;
7> release channel ch1;}
```

## 备份数据文件

**备份类型为镜像备份**
RMAN> backup as copy datafile 4  format '/u01/app/oracle/rmanbak/df_%d_%U';

## 备份表空间

RMAN> backup tablespace users,example format '/u01/app/oracle/rmanbak/tb_%d_%U';
RMAN> backup tablespace temp; //临时表空间不需要备份

## 备份控制文件

RMAN> configure controlfile autobackup on;-- 自动备份控制文件置为 on 状态, 将自动备份控制文件和参数文件
注：在备份 system01.dbf 或 system 表空间时将会自动备份控制文件和参数文件，即使自动备份控制文件参数为 off

**单独备份控制文件及参数文件**
RMAN> backup current controlfile;

**备份数据文件时包含控制文件**
RMAN> backup datafile 4 include current controlfile;
或
RMAN> sql "alter database backup controlfile to''/tmp/orclcontrol.bak''";
sql statement: alter database backup controlfile to ''/tmp/orclcontrol.bak''
或
RMAN>  sql "alter database backup controlfile to trace as''/tmp/orclcontrol.sql''";
sql statement: alter database backup controlfile to trace as ''/tmp/orclcontrol.sql''

## 单独备份 spfile

RMAN> backup spfile format '/u01/app/oracle/rmanbak/sp_%d_%U';
RMAN> backup copies 2 device type disk spfile;

## 备份归档日志文件

​	备份归档日志时仅仅备份归档过的数据文件 (不备份联机重做日志文件)
​	备份归档日志时总是对归档日志做完整备份
​	RMAN 对归档日志备份前会自动做一次日志切换
​	且从一组归档日志中备份未损坏的归档日志
​	RMAN 会自动判断哪些归档日志需要进行备份
​	归档日志的备份集不能包含其它类型的文件
```
RMAN> backup
2> format '/u01/app/oracle/rmanbak/lf_%d_%U'
3> archivelog all delete input;   --delete input 删除所有已经备份过的归档日志

RMAN> backup   //此种写法实现了上述相同的功能
2> archivelog all delete input
3> format '/u01/app/oracle/rmanbak/lf_%d_%U';

RMAN>  backup archivelog sequence between 50 and 120 thread 1 delete input;

RMAN> backup archivelog from time "sysdate-15" until time "sysdate-7";

RMAN> backup
2> format '/u01/app/oracle/rmanbak/lf_%d_%U'
3> archivelog from sequence=80
4> delete input;
```
使用 plus archivelog 时备份数据库完成的动作 (backup database plus archivelog):
​	首先执行 alter system archive log current 命令 (对当前日志归档)
​	执行 backup archivelog all 命令 (对所有归档日志进行备份)
​	执行 backup database 命令中指定的数据文件、表空间等
​	再次执行 alter system archive log current
​	备份在备份操作期间产生的新的归档日志

执行下面的命令, 并观察备份列出的信息, 可以看到使用 plus archivelog 时使用了上面描述的步骤来进行备份
RMAN> backup database plus archivelog format  '/u01/app/oracle/rmanbak/lg_%d_%U' delete input;

## 备份闪回区

RMAN> backup recovery area;
使用 backup recovery area 时，将备份位于闪回区且未进行过备份的所有文件，这些文件包括完整、增量备份集、自动备份的控制文件 (假定使用闪回区作为备份路径时)、归档日志、数据文件的镜像副本等。闪回日志，当前的控制文件。
联机重做日志不会被备份

RMAN> backup recovery files;
使用 backup recovery files 时，将备份磁盘上未进行过备份的所有恢复文件，而不论是否位于闪回区
注：使用上述两条命令时，备份目的地必须是磁带

## 总结

数据文件的备份集对于未使用的块可以执行增量备份，可以跳过未使用过的数据块来进行压缩备份对于控制文件、归档日志文件、spfile 文件则是简单的拷贝，并对其进行打包压缩而已。