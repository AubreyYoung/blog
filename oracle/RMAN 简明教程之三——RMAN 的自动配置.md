> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://www.kancloud.cn/digest/rman/148817

Oracle 9i 可以配置一些参数如通道，备份保持策略等信息，通过一次设定可以多次使用，而且，设置中的信息不影响脚本中的重新设置。RMAN 默认的配置参数，通过 show all 就可以看出来。

```
RMAN> show all;  
RMAN configuration parameters are:  
CONFIGURE RETENTION POLICY TO REDUNDANCY 1;  
CONFIGURE BACKUP OPTIMIZATION OFF;  
CONFIGURE DEFAULT DEVICE TYPE TO DISK;  
CONFIGURE CONTROLFILE AUTOBACKUP OFF;  
CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR TYPE DISK TO '%F';  
CONFIGURE DEVICE TYPE DISK PARALLELISM 1;  
CONFIGURE DATAFILE BACKUP COPIES FOR DEVICE TYPE DISK TO 1;  
CONFIGURE ARCHIVELOG BACKUP COPIES FOR DEVICE TYPE DISK TO 1;  
CONFIGURE MAXSETSIZE TO UNLIMITED;  
CONFIGURE SNAPSHOT CONTROLFILE NAME TO  
'/u01/app/oracle/product/9.0.2/dbs/snapcf_U02.f';  

```

## <a id="&nbsp;_16"></a>一、 备份策略保持

分为两个保持策略，一个是时间策略，决定至少有一个备份能恢复到指定的日期，一个冗余策略，规定至少有几个冗余的备份。

```
CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 5 DAYS;  
CONFIGURE RETENTION POLICY TO REDUNDANCY 5;  
CONFIGURE RETENTION POLICY TO NONE;  

```

在第一个策略中，是保证至少有一个备份能恢复到 Sysdate-5 的时间点上，之前的备份将标记为 Obsolete。第二个策略中说明至少需要有三个冗余的备份存在，如果多余三个备份以上的备份将标记为冗余。NONE 可以把使备份保持策略失效，Clear 将恢复默认的保持策略。

## <a id="_24"></a>二、通道配置与自动通道分配

通过 CONFIGURE 配置自动分配的通道，而且可以通过数字来指定不同的通道分配情况。

```
CONFIGURE CHANNEL DEVICE TYPE DISK FORMAT '/U01/ORACLE/BACKUP/%U‘  
CONFIGURE CHANNEL n DEVICE TYPE DISK FORMAT '/U01/ORACLE/BACKUP/%U‘  

```

当然，也可以在运行块中，手工指定通道分配，这样的话，将取代默认的通道分配。

```
Run{  
allocate channel cq type disk format='/u01/backup/%u.bak'  
……  
}  

```

以下是通道的一些特性
读的速率限制
Allocate channel …… rate = integer
最大备份片大小限制
Allocate channel …… maxpiecesize = integer
最大并发打开文件数（默认 16）
Allocate channel …… maxopenfile = integer

## <a id="_45"></a>三、控制文件自动备份

从 9i 开始，可以配置控制文件的自动备份，但是这个设置在备用数据库上是失效的。通过如下的命令，可以设置控制文件的自动备份
CONFIGURE CONTROLFILE AUTOBACKUP ON;
对于没有恢复目录的备份策略来说，这个特性是特别有效的，控制文件的自动备份发生在任何 backup 或者 copy 命令之后，或者任何数据库的结构改变之后。
可以用如下的配置指定控制文件的备份路径与格式
CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR TYPE DISK TO '%F';
在备份期间，将产生一个控制文件的快照，用于控制文件的读一致性，这个快照可以通过如下配置
CONFIGURE SNAPSHOT CONTROLFILE NAME TO
'/u01/app/oracle/product/9.0.2/dbs/snapcf_U02.f';

## <a id="_54"></a>四、设置并行备份

RMAN 支持并行备份与恢复，也可以在配置中指定默认的并行程度。如
CONFIGURE DEVICE TYPE DISK PARALLELISM 4;
指定在以后的备份与恢复中，将采用并行度为 4，同时开启 4 个通道进行备份与恢复，当然也可以在 run 的运行块中指定通道来决定备份与恢复的并行程度。

并行的数目决定了开启通道的个数。如果指定了通道配置，将采用指定的通道，如果没有指定通道，将采用默认通道配置。
## 五、配置默认 IO 设备类型
IO 设备类型可以是磁盘或者磁带，在默认的情况下是磁盘，可以通过如下的命令进行重新配置。

```
CONFIGURE DEFAULT DEVICE TYPE TO DISK;  
CONFIGURE DEFAULT DEVICE TYPE TO SBT;  

```

注意，如果换了一种 IO 设备，相应的配置也需要做修改，如
RMAN> CONFIGURE DEVICE TYPE SBT PARALLELISM 2;

## <a id="_69"></a>六、配置多个备份的拷贝数目

如果觉得单个备份集不放心，可以设置多个备份集的拷贝，如

```
CONFIGURE DATAFILE BACKUP COPIES FOR DEVICE TYPE DISK TO 2;  
CONFIGURE ARCHIVELOG BACKUP COPIES FOR DEVICE TYPE DISK TO 2;  

```

如果指定了多个拷贝，可以在通道配置或者备份配置中指定多个拷贝地点

```
CONFIGURE CHANNEL DEVICE TYPE DISK FORMAT '/u01/backup/%U', '/u02/backup/%U';  
RMAN>backup datafile n format '/u01/backup/%U', '/u02/backup/%U';  

```

## <a id="_80"></a>七、备份优化

可以在配置中设置备份的优化，如
CONFIGURE BACKUP OPTIMIZATION ON;
如果优化设置打开，将对备份的数据文件、归档日志或备份集运行一个优化算法。同样的 DBID, 检查点 SCN,ResetlogSCN 与时间正常离线，只读或正常关闭的文件归档日志，同样的线程，序列号 RESETLOG SCN 与时间

## <a id="_84"></a>八、备份文件的格式

备份文件可以自定义各种各样的格式，如下
%c 备份片的拷贝数
%d 数据库名称
%D 位于该月中的第几天 (DD)
%M 位于该年中的第几月 (MM)
%F 一个基于 DBID 唯一的名称, 这个格式的形式为 c-IIIIIIIIII-YYYYMMDD-QQ,
其中 IIIIIIIIII 为该数据库的 DBID，YYYYMMDD 为日期，QQ 是一个 1-256 的序
列
%n 数据库名称，向右填补到最大八个字符
%u 一个八个字符的名称代表备份集与创建时间
%p 该备份集中的备份片号，从 1 开始到创建的文件数
%U 一个唯一的文件名，代表 %u_%p_%c
%s 备份集的号
%t 备份集时间戳
%T 年月日格式 (YYYYMMDD)

推荐 Oracle 社区：[http://www.pdmcn.com/bbs](http://www.pdmcn.com/bbs),  oracle QQ 群：60632593、60618621

推荐 Oracle 技术资料：《Oracle 9i RMAN 参考使用手册》、《ORACLE10G 备份与恢复》、《**Oracle Database 10gRMAN 备份与恢复**》