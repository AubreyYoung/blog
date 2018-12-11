# Oracle 12c数据库新特性总结.html

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

063433204

Oracle 12c数据库新特性总结

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

部分Oracle 12C新特性说明。

详细信息

## 1.    在线重命名和重新定位活跃数据文件

不同于以往的版本，在Oracle数据库12c
R1版本中对数据文件的迁移或重命名不再需要太多繁琐的步骤，即把表空间置为只读模式，接下来是对数据文件进行离线操作。在12c R1中，可以使用ALTER
DATABASE MOVE
DATAFILE这样的SQL语句对数据文件进行在线重命名和移动。而当此数据文件正在传输时，终端用户可以执行查询，DML以及DDL方面的任务。另外，数据文件可以在存储设备间迁移，如从非ASM迁移至ASM，反之亦然。

重命名数据文件：

SQL> ALTER DATABASE MOVE DATAFILE '/u00/data/users01.dbf' TO
'/u00/data/users_01.dbf';

从非ASM迁移数据文件至ASM：

SQL> ALTER DATABASE MOVE DATAFILE '/u00/data/users_01.dbf' TO '+DG_DATA';

将数据文件从一个ASM磁盘群组迁移至另一个ASM磁盘群组：

SQL> ALTER DATABASE MOVE DATAFILE '+DG_DATA/DBNAME/DATAFILE/users_01.dbf ' TO
'+DG_DATA_02';

在数据文件已存在于新路径的情况下，以相同的命名将其覆盖：

SQL> ALTER DATABASE MOVE DATAFILE '/u00/data/users_01.dbf' TO
'/u00/data_new/users_01.dbf' REUSE;

复制文件到一个新路径，同时在原路径下保留其拷贝：

SQL> ALTER DATABASE MOVE DATAFILE '/u00/data/users_01.dbf' TO
'/u00/data_new/users_01.dbf' KEEP;

当通过查询 **v$session_longops** 动态视图来移动文件时，你可以监控这一过程。另外，你也可以引用 **alert.log**
，Oracle会在其中记录具体的行为。



## 2.     表、表分区或子分区的在线迁移和转换

在Oracle 12c
R1中迁移表分区或子分区到不同的表空间不再需要复杂的过程。与之前版本中未分区表进行在线迁移类似，表分区或子分区可以在线或是离线迁移至一个不同的表空间。当指定了ONLINE语句，所有的DML操作可以在没有任何中断的情况下，在参与这一过程的分区或子分区上执行。与此相反，分区或子分区迁移如果是在离线情况下进行的，DML操作是不被允许的。

将非分区表在线转换为分区表。

在线SPLIT分区和子分区。

在线表移动。

示例：

SQL> ALTER TABLE table_name MOVE PARTITION|SUBPARTITION partition_name TO
tablespace tablespace_name;  
SQL> ALTER TABLE table_name MOVE PARTITION|SUBPARTITION partition_name TO
tablespace tablespace_name UPDATE INDEXES ONLINE;

第一个示例是用来在离线状况下将一个表分区或子分区迁移至一个新的表空间。第二个示例是在线迁移表分区或子分区并维护表上任何本地或全局的索引。此外，当使用ONLINE语句时，DML操作是不会中断的。

 **重要提示：**

·         UPDATE INDEXES语句可以避免出现表中任何本地或全局索引无法使用的情况。

·         表的在线迁移限制也适用于此。

·         引入加锁机制来完成这一过程，当然它也会导致性能下降并会产生大量的redo，这取决于分区和子分区的大小。



## 3.     不可见字段

在Oracle 11g R1中，Oracle以不可见索引和虚拟字段的形式引入了一些不错的增强特性。继承前者并发扬光大，Oracle 12c
R1中引入了不可见字段思想。在之前的版本中，为了隐藏重要的数据字段以避免在通用查询中显示，我们往往会创建一个视图来隐藏所需信息或应用某些安全条件。

在12c
R1中，你可以在表中创建不可见字段。当一个字段定义为不可见时，这一字段就不会出现在通用查询中，除非在SQL语句或条件中有显式的提及这一字段，或是在表定义中有DESCRIBED。要添加或是修改一个不可见字段是非常容易的，反之亦然。

SQL> CREATE TABLE emp (eno number(6), ename varchar2(40), sal number(9)
INVISIBLE);  
SQL> ALTER TABLE emp MODIFY (sal visible);

你必须在INSERT语句中显式提及不可见字段名以将不可见字段插入到数据库中。虚拟字段和分区字段同样也可以定义为不可见类型。但临时表，外部表和集群表并不支持不可见字段。



## 4.     相同字段上的多重索引

在Oracle 12c
R1之前，一个字段是无法以任何形式拥有多个索引的。或许有人会想知道为什么通常一个字段需要有多重索引，事实上需要多重索引的字段或字段集合是很多的。在12c
R1中，只要索引类型的形式不同，一个字段就可以包含在一个B-tree索引中，同样也可以包含在Bitmap索引中。注意，只有一种类型的索引是在给定时间可用的。

 SQL>  create table t1 as select object_id,object_name from dba_objects;

Table created.

create index i1 on t1(object_id);

Index created.

SQL>  SELECT index_name,visibility FROM dba_indexes WHERE index_name='I1';



INDEX_NAME                     VISIBILIT

\------------------------------ ---------

I1                             VISIBLE

SQL>  ALTER INDEX I1 INVISIBLE;

Index altered.

SQL> SELECT index_name,visibility FROM dba_indexes WHERE index_name='I1';

INDEX_NAME                     VISIBILIT

\------------------------------ ---------

I1                             INVISIBLE

SQL> create bitmap index i2 on t1(object_id);

Index created.

## 5.     DDL日志

在之前的版本中没有可选方法来对DDL操作进行日志记录。而在12c
R1中，你现在可以将DDL操作写入xml和日志文件中。这对于了解谁在什么时间执行了create或drop命令是十分有用的。要开启这一功能必须对ENABLE_DDL_LOGGING
初始参数加以配置。这一参数可以在数据库或会话级加以设置。当此参数为启用状态，所有的DDL命令会记录在$ORACLE_BASE/diag/rdbms/DBNAME/log|ddl
路径下的xml和日志文件中。一个xml中包含DDL命令，IP地址，时间戳等信息。这可以帮助确定在什么时候对用户或表进行了删除亦或是一条DDL语句在何时触发。

SQL> show parameter ENABLE_DDL_LOGGING



NAME                                 TYPE        VALUE

\------------------------------------ -----------
------------------------------

enable_ddl_logging                   boolean     FALSE

开启DDL日志功能

SQL> ALTER SYSTEM|SESSION SET ENABLE_DDL_LOGGING=TRUE;

以下的DDL语句可能会记录在xml或日志文件中：

·         CREATE|ALTER|DROP|TRUNCATE TABLE

·         DROP USER

·         CREATE|ALTER|DROP PACKAGE|FUNCTION|VIEW|SYNONYM|SEQUENCE



 SQL> create table a (id int);



Table created.

[oracle@ol122 ddl]$ pwd

/u01/app/oracle/diag/rdbms/orcl/orcl/log/ddl

 [oracle@ol122 ddl]$ ls

log.xml

[oracle@ol122 ddl]$ cat log.xml

<msg time='2017-06-05T16:02:38.778+08:00' org_id='oracle' comp_id='rdbms'

 msg_id='opiexe:4695:2946163730' type='UNKNOWN' group='diag_adl'

 level='16' host_id='ol122' host_addr='192.168.132.180'

 pid='4497' version='1'>

 <txt>create table a (id int)

 </txt>

</msg>

## 6.     临时undo

每个Oracle数据库包含一组与系统相关的表空间，例如 **SYSTEM** ， **SYSAUX** ， **UNDO &
TEMP**，并且它们在Oracle数据库中每个都用于不同的目的。在Oracle 12c
R1之前，临时表生成的undo记录是存储在undo表空间里的，通用表和持久表的undo记录也是类似的。而在12c
R12的临时undo功能中，临时undo记录可以存储在一个临时表中，而无需再存储在undo表空间内。这样做的主要好处在于：减少undo表空间，由于信息不会被记录在redo日志中，所以减少了redo数据的生成。你可以在会话级别或者数据库级别来启用临时undo选项。

启用临时undo功能

要使用这一新功能，需要做以下设置：

·         兼容性参数必须设置为12.0.0或更高

·         启用 TEMP_UNDO_ENABLED 初始化参数

·         由于临时undo记录现在是存储在一个临时表空间中的，你需要有足够的空间来创建这一临时表空间

  * 对于会话级，你可以使用：alter SESSION set temp_undo_enabled=true;

查询临时undo信息

以下所列的字典视图是用来查看或查询临时undo数据相关统计信息的：

·         V$TEMPUNDOSTAT

·         DBA_HIST_UNDOSTAT

·         V$UNDOSTAT

要禁用此功能，你只需做以下设置：

SQL> ALTER SYSTEM|SESSION SET TEMP_UNDO_ENABLED=FALSE;

## 7.     备份特定用户特权

在11g R2中，引入了SYSASM特权来执行ASM的特定操作。同样地，在12c中引入了SYSBACKUP特权用来在
RMAN中执行备份和恢复命令。因此，你可以在数据库中创建一个本地用户并在不授予其SYSDBA权限的情况下，通过授予SYSBACKUP权限让其能够在RMAN中执行备份和恢复相关的任务。

SQL> create user backupdb identified by oracle;



User created.



SQL> grant SYSBACKUP to backupdb;



Grant succeeded.

[oracle@ol122 ~]$ rman target backupdb/oracle



## 8.     如何在RMAN中执行SQL语句

在12c中，你可以在不需要SQL前缀的情况下在RMAN中执行任何SQL和PL/SQL命令，即你可以从RMAN直接执行任何SQL和PL/SQL命令。如下便是在RMAN中执行SQL语句的示例：

RMAN> SELECT username,machine FROM v$session;  
RMAN> ALTER TABLESPACE users ADD DATAFILE SIZE 121m;

## 9.     RMAN中的表恢复和分区恢复

Oracle数据库备份主要分为两类：逻辑和物理备份。每种备份类型都有其自身的优缺点。在之前的版本中，利用现有物理备份来恢复表或分区是不可行的。为了恢复特定对象，逻辑备份是必需的。对于12c
R1，你可以在发生drop或truncate的情况下从RMAN备份将一个特定的表或分区恢复到某个时间点或SCN。

此外在12.2，在RMAN执行表恢复之前，增强功能“Disk Space
Check”可以提供辅助实例的可用磁盘空间的前期检查。如果没有足够的空间来创建此实例，则会返回操作系统级错误。

当通过RMAN发起一个表或分区恢复时，大概流程是这样的：

·         确定要恢复表或分区所需的备份集

·         在恢复表或分区的过程中，一个辅助数据库会临时设置为某个时间点

·         利用数据泵将所需表或分区导出到一个dumpfile

·         你可以从源数据库导入表或分区(可选)

·         在恢复过程中进行重命名操作

以下是一个通过RMAN对表进行时间点恢复的示例(确保你已经对稍早的数据库进行了完整备份)：

RMAN> connect target "username/password as SYSBACKUP";  
RMAN> RECOVER TABLE username.tablename UNTIL TIME 'TIMESTAMP…'  
AUXILIARY DESTINATION '/u01/tablerecovery'  
DATAPUMP DESTINATION '/u01/dpump'  
DUMP FILE 'tablename.dmp'  
NOTABLEIMPORT \-- this option avoids importing the table
automatically.(此选项避免自动导入表)  
REMAP TABLE 'username.tablename': 'username.new_table_name'; \-- can rename
table with this option.(此选项可以对表重命名)

 **重要提示：**

·         确保对于辅助数据库在/u01文件系统下有足够的可用空间，同时对数据泵文件也有同样保证

·         必须要存在一份完整的数据库备份，或者至少是要有SYSTEM相关的表空间备份

以下是在RMAN中应用表或分区恢复的限制和约束：

·         SYS用户表或分区无法恢复

·         存储于SYSAUX和SYSTEM表空间下的表和分区无法恢复

·         当REMAP选项用来恢复的表包含NOT NULL约束时，恢复此表是不可行的

 RECOVER TABLE  xyh.test2 until scn 1429510

AUXILIARY DESTINATION '/u01/tablerecovery'

DATAPUMP DESTINATION '/u01/dpump'

DUMP FILE 'tablename.dmp'

NOTABLEIMPORT;

REMAP TABLE xyh.test1:xyh.test3;

## 10\.  限制PGA的大小

在Oracle 12c R1之前，没有选项可以用来限制和控制PGA的大小。虽然你设置某个大小为PGA_AGGREGATE_TARGET
的初始参数，Oracle会根据工作负载和需求来动态地增大或减小PGA的大小。而在12c中，你可以通过开启自动PGA管理来对PGA设定硬性限制，这需要对PGA_AGGREGATE_LIMIT
参数进行设置。因此，你现在可以通过设置新的参数来对PGA设定硬性限制以避免过度使用PGA。

SQL> ALTER SYSTEM SET PGA_AGGREGATE_LIMIT=2G;  
SQL> ALTER SYSTEM SET PGA_AGGREGATE_LIMIT=0; \--disables the hard limit

 **重要提示：**

当超过了当前PGA的限制，Oracle会自动终止/中止会话或进程以保持最合适的PGA内存。

## 11\. IN-Memory Option

alter table test inmemory;

## 12\. SQL*Plus Command History

此功能类似于UNIX平台命令行shell上的history命令。

## 13\.  对表分区维护的增强

 **添加多个新分区**

在Oracle 12c R1之前，一次只可能添加一个新分区到一个已存在的分区表。要添加一个以上的新分区，需要对每个新分区都单独执行一次 **ALTER
TABLE ADD PARTITION** 语句。而Oracle 12c只需要使用一条单独的 **ALTER TABLE ADD PARTITION**
命令就可以添加多个新分区，这增加了数据库灵活性。以下示例说明了如何添加多个新分区到已存在的分区表：

SQL> CREATE TABLE emp_part  
    (eno number(8), ename varchar2(40), sal number (6))   
  PARTITION BY RANGE (sal)  
  (PARTITION p1 VALUES LESS THAN (10000),  
   PARTITION p2 VALUES LESS THAN (20000),  
   PARTITION p3 VALUES LESS THAN (30000)  
  );

添加两个新分区：

SQL> ALTER TABLE emp_part ADD  PARTITION p4 VALUES LESS THAN (35000),  
  PARTITION p5 VALUES LESS THAN (40000);

同样，只要 **MAXVALUE** 分区不存在，你就可以添加多个新分区到一个列表和系统分区表。

 **如何删除和截断多个分区/子分区**

作为数据维护的一部分，DBA通常会在一个分区表上进行删除或截断分区的维护任务。在12c
R1之前，对于一个已存在的分区表一次只可能删除或截断一个分区。而对于Oracle 12c， 可以用单条 **ALTER TABLE table_name
{DROP|TRUNCATE} PARTITIONS**  命令来撤销或合并多个分区和子分区。

下例说明了如何在一个已存在分区表上删除或截断多个分区：

SQL> ALTER TABLE emp_part DROP PARTITIONS p4,p5;  
SQL> ALTER TABLE emp_part TRUNCATE PARTITIONS p4,p5;

要保持索引更新，使用 **UPDATE INDEXES** 或 **UPDATE GLOBAL INDEXES** 语句，如下所示：

SQL> ALTER TABLE emp_part DROP PARTITIONS p4,p5 UPDATE GLOBAL INDEXES;  
SQL> ALTER TABLE emp_part TRUNCATE PARTITIONS p4,p5 UPDATE GLOBAL INDEXES;

如果你在不使用 **UPDATE GLOBAL INDEXES**  语句的情况下删除或截断一个分区，你可以在 **USER_INDEXES** 或
**USER_IND_PARTITIONS**  字典视图下查询 **ORPHANED_ENTRIES**  字段以找出是否有索引包含任何的过期条目。

 **将单个分区分割为多个新分区**

在12c中新增强的 **SPLIT PARTITION**
语句可以让你只使用一个单独命令将一个特定分区或子分区分割为多个新分区。下例说明了如何将一个分区分割为多个新分区：

SQL> CREATE TABLE emp_part

(eno number(8), ename varchar2(40), sal number (6))

PARTITION BY RANGE (sal)

(PARTITION p1 VALUES LESS THAN (10000),

PARTITION p2 VALUES LESS THAN (20000),

PARTITION p_max VALUES LESS THAN (MAXVALUE)

);  
SQL> ALTER TABLE emp_part SPLIT PARTITION p_max INTO

(PARTITION p3 VALUES LESS THAN (25000),

PARTITION p4 VALUES LESS THAN (30000), PARTITION p_max);

 **将多个分区合并为一个分区**

你可以使用单条 **ALTER TBALE MERGE PARTITIONS**  语句将多个分区合并为一个单独分区：

SQL> CREATE TABLE emp_part

(eno number(8), ename varchar2(40), sal number (6))

PARTITION BY RANGE (sal)

(PARTITION p1 VALUES LESS THAN (10000),

PARTITION p2 VALUES LESS THAN (20000),

PARTITION p3 VALUES LESS THAN (30000),

PARTITION p4 VALUES LESS THAN (40000),

PARTITION p5 VALUES LESS THAN (50000),

PARTITION p_max VALUES LESS THAN (MAXVALUE)

);  
SQL> ALTER TABLE emp_part MERGE PARTITIONS p3,p4,p5 INTO PARTITION p_merge;

如果分区范围形成序列，你可以使用如下示例：

SQL> ALTER TABLE emp_part MERGE PARTITIONS p3 TO p5 INTO PARTITION p_merge;

## 14\.  数据库升级改进

每当一个新的Oracle版本发布，DBA所要面临的挑战就是升级过程。该部分我将介绍12c中引入的针对升级的两个改进。

 **预升级脚本**

在12c R1中，原有的 **utlu[121]s.sql**  脚本由一个大为改善的预升级信息脚本 **preupgrd.sql**
所取代。除了预升级检查验证，此脚本还能以修复脚本的形式解决在升级过程前后出现的各种问题。

可以对产生的修复脚本加以执行来解决不同级别的问题，例如，预升级和升级后的问题。当手动升级数据库时，脚本必须在实际升级过程初始化之前加以手动执行。然而，当使用DBUA工具来进行数据库升级时，它会将预升级脚本作为升级过程的一部分加以自动执行，而且会提示你去执行修复脚本以防止报错。

如何执行脚本：

SQL> @$ORACLE_12GHOME/rdbms/admin/preupgrd.sql

以上脚本会产生一份日志文件以及一个 **[pre/post]upgrade_fixup.sql**  脚本。所有这些文件都位于
**$ORACLE_BASE/cfgtoollogs**  目录下。在你继续真正的升级过程之前，你应该浏览日志文件中所提到的建议并执行脚本以修复问题。

注意：你要确保将 **preupgrd.sql** 和 **utluppkg.sql**  脚本从12c Oracle的目录home/rdbms/admin
directory拷贝至当前的Oracle的database/rdbms/admin路径。

 **并行升级功能**

数据库升级时间的长短取决于数据库上所配置的组件数量，而不是数据库的大小。在之前的版本中，我们是无法并行运行升级程序，从而快速完成整个升级过程的。

在12c R1中，原有的 **catupgrd.sql**  脚本由 **catctl.pl**
脚本(并行升级功能)替代，现在我们可以采用并行模式运行升级程序了。

以下流程说明了如何初始化并行升级功能(3个过程);你需要在升级模式下在启动数据库后运行这一脚本：

cd $ORACLE_12_HOME/perl/bin  
$ ./perl catctl.pl –n 3 -catupgrd.sql

以上两个步骤需要在手动升级数据库时运行。而DBUA也继承了这两个新变化。

## 15\.  通过网络恢复数据文件

在12c
R1中另一个重要的增强是，你现在可以在主数据库和备用数据库之间用一个服务名重新获得或恢复数据文件、控制文件、参数文件、表空间或整个数据库。这对于同步主数据库和备用数据库极为有用。

当主数据库和备用数据库之间存在相当大的差异时，你不再需要复杂的前滚流程来填补它们之间的差异。RMAN能够通过网络执行备用恢复以进行增量备份，并且可以将它们应用到物理备用数据库。你可以用服务名直接将所需数据文件从备用点拷贝至主站，这是为了防止主数据库上数据文件、表空间的丢失，或是没有真正从备份集恢复数据文件。

以下流程演示了如何用此新功能执行一个前滚来对备用数据库和主数据库进行同步：

在物理备用数据库上：

./rman target "username/password@standby_db_tns as SYSBACKUP"  
RMAN> RECOVER DATABASE FROM SERVICE primary_db_tns USING COMPRESSED BACKUPSET;

以上示例使用备用数据库上定义的 **primary_db_tns**
连接字符串连接到主数据库，然后执行了一个增量备份，再将这些增量备份传输至备用目的地，接着将应用这些文件到备用数据库来进行同步。然而，需要确保已经对
**primary_db_tns**  进行了配置，即在备份数据库端将其指向主数据库。

在以下示例中，我将演示一个场景通过从备用数据库获取数据文件来恢复主数据库上丢失的数据文件：

在主数据库上：

./rman target "username/password@primary_db_tns as SYSBACKUP"  
RMAN> RESTORE DATAFILE ‘+DG_DISKGROUP/DBANME/DATAFILE/filename’ FROM SERVICE
standby_db_tns;

./rman target "username/password@primary_db_tns as SYSBACKUP"  
RMAN> RESTORE DATAFILE ‘+DG_DISKGROUP/DBANME/DATAFILE/filename’ FROM SERVICE
standby_db_tns;

## 16\.  对Data Pump的增强

Data Pump版本有了不少有用的改进，例如在导出时将视图转换为表，以及在导入时关闭日志记录等。

 **关闭redo日志的生成**

Data Pump中引入了新的 **TRANSFORM** 选项，这对于对象在导入期间提供了关闭重做生成的灵活性。当为 **TRANSFORM**
选项指定了 **DISABLE_ARCHIVE_LOGGING**
值，那么在整个导入期间，重做生成就会处于关闭状态。这一功能在导入大型表时缓解了压力，并且减少了过度的redo产生，从而加快了导入。这一属性还可应用到表以及索引。以下示例演示了这一功能：

$ ./impdp directory=dpump dumpfile=abcd.dmp logfile=abcd.log
TRANSFORM=DISABLE_ARCHIVE_LOGGING:Y

 **将视图转换为表**

这是Data Pump中另外一个改进。有了 **VIEWS_AS_TABLES**
选项，你就可以将视图数据载入表中。以下示例演示了如何在导出过程中将视图数据载入到表中：

$ ./expdp directory=dpump dumpfile=abcd.dmp logfile=abcd.log
views_as_tables=my_view:my_table

## 17\.  实时自动数据诊断监视器 (ADDM) 分析

通过使用诸如AWR、ASH以及ADDM之类的自动诊断工具来分析数据库的健康状况，是每个DBA日程工作的一部分。尽管每种工具都可以在多个层面衡量数据库的整体健康状况和性能，但没有哪个工具可以在数据库反应迟钝或是完全挂起的时候使用。

当数据库反应迟钝或是挂起状态时，而且你已经配置了Oracle 企业管理器
12c的云控制，你就可以对严重的性能问题进行诊断。这对于你了解当前数据库发生了什么状况有很大帮助，而且还能够对此问题给出解决方案。

以下步骤演示了如何在Oracle 企业管理器 12c上分析数据库状态：

·         在访问数据库访问主页面从 **Performance** 菜单选择 **Emergency Monitoring**
选项。这会显示挂起分析表中排名靠前的阻止会话。

·         在 **Performance** 菜单选择 **Real-Time ADDM**  选项来执行实时ADDM分析。

·         在收集了性能数据后，点击 **Findings** 标签以获得所有结果的交互总结。

## 18\.  同时在多个表上收集统计数据

在之前的Oracle数据库版本中，当你执行一个DBMS_STATS
程序来收集表、索引、模式或者数据库级别的统计数据时，Oracle习惯于一次一个表的收集统计数据。如果表很大，那么推荐你采用并行方式。在12c
R1中，你现在可以同时在多个表、分区以及子分区上收集统计数据。在你开始使用它之前，你必须对数据库进行以下设置以开启此功能：

SQL> ALTER SYSTEM SET RESOURCE_MANAGER_PLAN='DEFAULT_MAIN';  
SQL> ALTER SYSTEM SET JOB_QUEUE_PROCESSES=4;  
SQL> EXEC DBMS_STATS.SET_GLOBAL_PREFS('CONCURRENT', 'ALL');  
SQL> EXEC DBMS_STATS.GATHER_SCHEMA_STATS('SCOTT');



## 19\.  OPatch Automation Tool - opatchauto

从12c开始，在集群GRID/RAC环境下，通过root用户使用opatchauto命令安装patch

(注：11.2 GRID通过opatch auto)。

$ ./opatchauto apply -help

OPatch Automation Tool

Copyright (c) 2015, Oracle

Corporation. All rights reserved.



DESCRIPTION

Apply a System Patch to Oracle Home. User specified the patch

location or the current directory will be taken as the patch location.

opatchauto must run from the GI Home as root user.

SYNTAX

<GI_HOME>/OPatch/opatchauto apply

[-analyze]

[-database

<database names> ]

[-generateSteps]

[-invPtrLoc

<Path to oraInst.loc> ]

[-jre <LOC> ]

[-norestart ]

[-nonrolling ]

[-ocmrf <OCM

response file location> ]

[-oh

<OH_LIST> ]

[ <Patch

Location> ]

其中"-analyze"选项可以模拟OPatchauto apply，提前检查所有检查项目，但是运行"-analyze"选项不会真正改变系统。

opatchauto 安装GI PSU 具体命令：

1. 同时对GI home 和 all Oracle  RAC database homes 打psu：

# opatchauto apply  <UNZIPPED_PATCH_LOCATION>/20996835 -ocmrf <ocm response
file>



2. 只单独对GI home 打psu：

# opatchauto apply  <UNZIPPED_PATCH_LOCATION>/20996835 -oh <GI_HOME> -ocmrf
<ocm

response file>



3.只单独对RAC database  homes 打psu：

# opatchauto apply  <UNZIPPED_PATCH_LOCATION>/20996835 -oh
<oracle_home1_path>,<oracle_home2_path> -ocmrf <ocm response  file>

## 20\. 不同 Oracle 版本的客户端/服务器互操作性支持矩阵

        

![noteattachment2][e062a7f3848ef5f2ed9961afa1efbfe3]  

![noteattachment3][1ce22272c5d014cc80a5dfe719fbb2be]

## 21\.  wait event DISPLAY_NAME

DISPLAY_NAME列中出现的等待事件的更清晰和更具描述性的名称。出现在DISPLAY_NAME列中的名称可以在Oracle数据库版本中更改，因此客户脚本不应该依赖于每个版本的DISPLAY_NAME列中显示的名称。

可以通过如下sql了解：

select name,display_name,wait_class from v$event_name  where
name!=display_name order by name；

## 22\.  12C 中，发生脑裂时，节点保留策略

在 11.2 及早期版本，在脑裂发生时，节点号小的会保留下来。然而从 12.1.0.2 开始，引入节点权重的概念。从 12.1.0.2
开始，解决脑裂时，权重高的节点将会存活下来。

## 23\.  Long Identifiers

提供更长的标识符可为客户在定义其命名方案时提供更大的灵活性，例如更长和更具表现力的表名。

如果COMPATIBLE设置为12.2或更高的值，则名称必须为1到128个字节长，但有以下例外：

l  数据库名称限制在8个字节。

l  磁盘组，可插拔数据库（PDB），回滚段，表空间和表空间集的名称限制为30个字节。

如果标识符包含由句点分隔的多个部分，那么每个属性最多可以长达128个字节。每个周期分隔符以及任何周围的双引号都计数为一个字节。例如，假设您标识如下所示的列：

"schema"."table"."column"

schema名称可以是128字节，table可以是128字节，column可以是128字节。每个引号和周期都是单字节字符，因此本示例中标识符的总长度可以高达392字节。

## 24\.  CLOB，BLOB和XMLType上的分布式操作

在此版本中，支持对基于LOB的数据类型（如CLOB，BLOB和XMLType）的database link的操作。

## 25\. Oracle Data Guard数据库比较

此新工具可以比较存储在Oracle Data
Guard主数据库中的数据块及其物理备用数据库。使用此工具查找其他工具（如DBVERIFY应用程序）无法检测到的磁盘错误（例如丢失的写入）。

管理员可以验证备用数据库不包含由备用数据库上的I / O堆栈独立引入的静默损坏。 Oracle Data
Guard已经在主数据库或备用数据库上对热数据（数据进行读取或更改）进行了验证，但此新工具提供了全面的验证，包括尚未被Oracle Data
Guard读取或更改的冷数据。这种能力使管理员完全相信备用数据库没有物理损坏。

## 26\. Oracle Data Guard Broker支持多个自动故障转移目标

Oracle Data Guard现在支持快速启动故障转移配置中的多个故障转移目标。 以前的功能仅允许单个快速启动故障转移目标。
如果故障转移目标无法满足主故障时快速启动故障切换的要求，则不会发生自动故障。 指定多个故障转移目标显著提高在需要时总是有备用适于自动故障转移的可能性。

多个故障切换目标通过在主停电时更容易发生自动故障切换来提高高可用性。

## 27\. 在最大保护模式下快速启动故障切换

当Oracle Data Guard在最大保护模式下运行时，现在可以配置快速启动故障切换。

当有多个同步目的地时，用户现在可以在保证的零数据丢失模式下使用多个快速启动故障转移目标来使用自动故障切换。

## 28\. 自动同步Oracle Data Guard配置中的密码文件

此功能可自动在Oracle Data Guard配置中同步密码文件。
SYS，SYSDG等密码更改时，将更新主数据库中的密码文件，然后将更改传播到配置中的所有备用数据库。

## 29\.  RMAN：语法增强

RMAN: Syntax Enhancements

You can use the enhanced SET NEWNAME command for the entire tablespace or
database instead of on a per file basis. The new MOVE command enables easier
movement of files to other locations instead of using backup and delete. The
new RESTORE+RECOVER command for data file, tablespace and database performs
restore and recovery in one step versus having to issue offline, restore,
recover, and online operations.



These enhancements simplify and improve ease-of-use for the SET NEWNAME, MOVE
and RESTORE+RECOVER commands.您可以对整个表空间或数据库使用增强的SET NEWNAME命令，而不是以每个文件为基础。
新的MOVE命令可以轻松地将文件移动到其他位置，而不是使用backup和delete。
用于数据文件，表空间和数据库的新RESTORE+RECOVER命令在一个步骤中执行恢复和恢复，而不必执行offline, restore,
recover和在线操作。

这些增强功能简化了SET NEWNAME，MOVE和RESTORE + RECOVER命令的易用性。

## 30\. SCAN Listener支持HTTP协议

SCAN Listene现在可以使基于HTTP的recovery server的连接根据recovery server计算机上的负载重定向到不同的计算机。

此功能可使连接在不同的恢复服务器机器之间进行负载平衡。

## 31\. 自动部署Oracle Data Guard

Oracle Data Guard快速启动故障转移（自动数据库故障转移）之间的Oracle Data Guard物理复制之间的部署是自动的。

支持使用DBCA命令行界面从现有主数据库创建Oracle Data Guard备用数据库。此功能减少了在Oracle Enterprise
Manager之外创建备用数据库所必须执行的手动步骤。 此外，DBCA允许在备用数据库创建结束时运行自定义脚本。

此功能使用户能够以非常简单的方式从命令行界面脚本创建备用数据库。

## 32\. 本地TEMP表空间

为了改进I / O操作，Oracle在Oracle Database 12c第2版（12.2）中引入了本地临时表空间，以便将溢出写入读取器节点上的本地磁盘。

对于SQL操作，例如散列聚合，排序，散列连接，为WITH子句创建游标持续时间临时表，还有星型转换可以溢出到磁盘（特别是共享磁盘上的全局临时表空间）。本地临时表空间的管理与现有临时表空间的管理类似。

本地临时表空间通过以下方式改进了只读实例中的临时表空间管理：

将临时文件存储在读取器节点私有存储中以充分利用本地存储的I / O优势。

避免昂贵的跨实例临时表空间管理。

增加临时表空间的可寻址性。

通过消除磁盘空间元数据管理来提高实例预热性能。

 **注意：** 您不能使用本地临时表空间来存储数据库对象，例如表或索引。 Oracle global临时表的空间也是同样的限制。

## 33\. Oracle数据库可以包含读/写和只读实例

Oracle Database 12c Release
2（12.2）提供了同一数据库中的两种类型的实例：读/写和只读。读/写实例是常规的Oracle数据库实例，可以处理对数据的更新（例如，DML语句UPDATE，DELETE，INSERT和MERGE），分区维护操作等。您可以直接连接到读/写实例。



只读实例只能处理查询，无法直接更新数据。您不能直接连接到只读实例。请注意，并行SQL语句包含数据的更新和查询（例如，INSERT INTO <select
query>）。在这种情况下，只有在读/写实例上处理INSERT部分时，才会在读/写和只读实例上处理语句的<select query>部分。

要将实例指定为只读，请将INSTANCE_MODE参数设置为READ_ONLY。 （参数的默认值为READ_WRITE。）

只读实例的引入显着提高了数据仓库工作负载的并行查询的可扩展性，并允许Oracle数据库在数百个物理节点上运行。

## 34\.  Oracle Grid Infrastructure Installation Using Zip Images

在Oracle Grid Infrastructure 12c Release 2（12.2）中，安装介质将替换为Oracle Grid
Infrastructure安装程序的zip文件。 将zip文件解压缩到目标Grid home路径后，用户可以启动安装程序向导。

此功能通过以zip格式直接将Oracle家庭软件映像提供给用户，从而简化了用户的安装体验。
到目前为止，用户必须从自动发布更新（ARU）或Oracle技术网络（OTN）下载安装介质，解压缩文件，然后以setup.exe或runInstaller运行安装程序，将软件复制到他们的系统。

## 35\. I/O Rate Limits for PDBs

此功能限制了可插拔数据库（PDB）发出的物理I / O速率。 您可以将限制指定为每秒的I / O请求或Mbps（每秒兆字节的I / O）。
此限制只能应用于PDB，而不能应用于CDB或非CDB。

后台I / O，如重写日志写入或脏缓冲区高速缓存写入不受限制。

限制值由新的PDB参数MAX_IOPS和MAX_MBPS指定。

## 36\. PDB Character Set

可以在同一多租户容器数据库（CDB）中为每个可插入数据库（PDB）设置一个不同的字符集。

## 37\. PDB Refresh

客户希望定期将更改从源可插拔数据库（PDB）传播到其克隆副本。 在这种情况下，我们说克隆的PDB是源PDB的可刷新副本。
可刷新的克隆PDB只能以只读模式打开，并且可以手动（按需）或自动执行来自源PDB的传播更改。

## 38\. Near Zero Downtime PDB Relocation

这种新功能通过利用克隆功能将可插拔数据库（PDB）从一个CDB重新定位到另一个CDB来显着减少停机时间。
源PDB在实际的克隆操作正在进行的同时仍然是开放的和功能完整的。 当应用增量redo时，源PDB被停止并且目的地PDB被联机，将应用中断减少到非常小的窗口。
源PDB随后废弃。

## 39\. Logical Standby Database AND  LogMiner to Support CDBs with PDBs with
Different Character Sets

在Oracle Database 12c Release
2（12.2）中，CDB允许PDB具有不同的字符集，只要根容器具有作为所有PDB字符集的超集的字符集即可。
逻辑备用数据库支持这样的主数据库。LogMiner也支持这样的主数据库。

## 40\.  支持CDB中具有不同字符集，时区文件版本和数据库时区的PDB



## 41\. 支持一个CDB具有Thousands PDB

Oracle Database 12c Release 2（12.2）现在支持在单个多租户容器数据库（CDB）中拥有数千个可插拔数据库（PDB）。

Oracle Database 12c Release 1（12.1.0.1）为每个CDB最多支持252个PDB。
通过为每个CDB支持更多的PDB，您将有更少的CDB来管理，从而进一步降低运营费用。

## 42\. PDB操作系统凭证

Oracle数据库操作系统用户通常是一个高度特权的用户。 在操作系统交互期间使用该用户可能会暴露安全漏洞的漏洞。
此外，使用相同的操作系统用户操作来自不同可插拔数据库（PDB）的系统交互可能会损害属于给定PDB的数据。这提供了保护属于一个PDB的数据不被连接到另一个PDB的用户访问的能力。

（有关如何创建操作系统用户凭据，请参阅DBMS_CREDENTIAL）

## 43\.  在升级期间将用户表空间自动设置为只读

并行升级脚本（catctl.pl）的新选项-T可用于在升级期间自动将用户表空间设置为只读，然后在升级后改回读/写。

为了避免在升级期间遇到问题，可以使用此新功能实现更快的回退策略。

请执行以下步骤。



如果需要，将system表空间复制到本地磁盘。

在升级中使用-T选项可以在升级期间将用户表空间设置为只读。

如果在升级过程中出现问题，则可以通过还原系统表空间的副本并在原始（旧）的Oracle主目录中打开数据库来快速重新启动数据库。

数据库升级助手（DBUA）也支持此功能。

## 44\. Oracle Data Pump Parallel expdp/Import of Metadata

以前仅适用于数据的并行。现在通过启用并行工作的多个进程来导入元数据，Oracle Data Pump导入/导出作业的性能得到了改善。

Oracle Data Pump现在花费更少的时间，因为元数据的并行导入被添加到此版本。

OracleData Pump现在在迁移期间只需要更短的停机时间和更短的导出运行时间。

## 45\.  Adding Oracle Data Pump and SQL*Loader Utilities to Instant Client

This feature adds SQL*Loader, expdp, impdp, exp, and imp to the tools for
instant client.

## 46\. 数据库迁移：支持由DB2 Export Utility生成的LLS文件

此功能有助于将数据从DB2迁移到Oracle数据库。

## 47\. ADG支持ODP和STA

Active Data Guard支持捕获性能数据的自动负载信息库（AWR）并在其上运行AWR数据自动数据库诊断监控（ADDM）分析以及SQL Tuning
Advisor。

## 48\. Grid: I/O Server

此功能可以使Oracle数据库对Oracle ASM磁盘组中的数据进行访问，而不需要根据当前的要求与底层磁盘进行物理“存储连接”。
通过类似于网络文件系统（NFS）服务器向NFS客户端提供数据的方式，通过网络提供对数据的访问。

此功能使客户端群集可以访问磁盘组，而不需要共享存储。

## 49\. 支持Oracle Cluster Interconnect的基于IPv6的IP地址

您可以将集群节点配置为在专用网络上使用基于IPv4或IPv6的IP地址，多个专用网络可用于集群。

专用互连的IPv6支持完成了Oracle Real Application Clusters (Oracle RAC）的IPv6增强工作。 自Oracle
Database 12c Release 1（12.1）以来，Oracle RAC已经为公共网络支持IPv6。

## 50.    自动存储管理(ASM)中的增强

 **Flex ASM**

在一个典型的网格基础架构安装环境中，每个节点都运行自身的ASM实例，并将其作为运行于此节点上数据库的存储容器。但这种设置会存在相应的单点故障危险。例如，如果此节点上的ASM实例发生故障，则运行于此节点上的所有数据库和实例都会受到影响。为了避免ASM实例的单点故障，Oracle
12c提供了一个名为Flex ASM的功能。Flex
ASM是一个不同的概念和架构，只有很少数量的ASM实例需要运行在集群中的一些服务器上。当某节点上的一个ASM实例发生故障，Oracle集群就会在另一个不同的节点上自动启动替代ASM实例以加强可用性。另外，这一设置还为运行在此节点上的实例提供了ASM实例负载均衡能力。Flex
ASM的另一个优势就是可以在单独节点上加以配置。

当选择Flex Cluster选项作为集群安装环境的第一部分时，鉴于Flex Cluster的要求，Flex
ASM配置就会被自动选择。传统集群同样也适用于Flex ASM。当你决定使用Flex ASM时，你必须保证所需的网络是可用的。你可以选择Flex
ASM存储选项作为集群安装环境的一部分，或是使用ASMCA在一个标准集群环境下启用Flex ASM。

以下命令显示了当前的ASM模式：

$ ./asmcmd showclustermode  
$ ./srvctl config asm

或是连接到ASM实例并查询 **INSTANCE_TYPE** 参数。如果输出值为 **ASMPROX** ，那么，就说明Flex ASM已经配置好了。

 **ASM** **存储限制放宽**

ASM存储硬性限额在最大ASM 磁盘群组和磁盘大小上已经大幅提升。在 12c R1中，ASM支持511个ASM磁盘群组，而在11g
R2中只支持63个。同样，相比起在11g R2中20 PB的磁盘大小，现在已经将这一数字提高到32 PB。

 **对ASM均衡操作的优化**

12c 中新的 **EXPLAIN WORK FOR**  语句用于衡量一个给定ASM均衡操作所需的工作量，并在 **V$ASM_ESTIMATE**
动态视图中输入结果。使用此动态视图，你可以调整 **POWER LIMIT**
语句对重新平衡操作工作进行改善。例如，如果你想衡量添加一个新ASM磁盘所需的工作量，在实际执行手动均衡操作之前，你可以使用以下命令：

SQL> EXPLAIN WORK FOR ALTER DISKGROUP DG_DATA ADD DISK data_005;  
SQL> SELECT est_work FROM V$ASM_ESTIMATE;  
SQL> EXPLAIN WORK SET STATEMENT_ID='ADD_DISK' FOR ALTER DISKGROUP DG_DATA AD
DISK data_005;  
SQL> SELECT est_work FROM V$ASM_ESTIMATE WHERE STATEMENT_ID = 'ADD_DISK’;

你可以根据从动态视图中获取的输出来调整POWER的限制以改善均衡操作。

 **ASM** **磁盘清理**

在一个ASM磁盘群组中，新的ASM磁盘清理操作分为正常或高冗余两个级别，它可以检验ASM磁盘群组中所有磁盘的逻辑数据破坏，并且可以自动对逻辑破坏进行修复，如果检测到有逻辑数据破坏，就会使用ASM镜像磁盘。磁盘清理可以在磁盘群组，特定磁盘或是某个文件上执行，这样其影响可降到最小程度。以下演示了磁盘清理场景：

SQL> ALTER DISKGROUP dg_data SCRUB POWER LOW:HIGH:AUTO:MAX;  
SQL> ALTER DISKGROUP dg_data SCRUB FILE
'+DG_DATA/MYDB/DATAFILE/filename.xxxx.xxxx'  
REPAIR POWER AUTO;

 **ASM** **的活动会话历史(ASH)**

 **V$ACTIVE_SESSION_HISOTRY**  动态视图现在还可以提供ASM实例的活动会话抽样。然而，诊断包的使用是受到许可限制的。

## 51.    网格(Grid)基础架构的增强

 **Flex** **集群**

Oracle 12c
在集群安装时支持两类配置：传统标准集群和Flex集群。在一个传统标准集群中，所有集群中的节点都彼此紧密地整合在一起，并通过私有网络进行互动，而且可以直接访问存储。另一方面，Flex集群在Hub和Leaf节点结构间引入了两类节点。分配在Hub中的节点类似于传统标准集群，它们通过私有网络彼此互连在一起并对存储可以进行直接读写访问。而Leaf节点不同于Hub节点，它们不需要直接访问底层存储;相反的是，它们通过Hub节点对存储和数据进行访问。

你可以配置多达64个Hub节点，而Leaf节点则可以更多。在Oracle
Flex集群中，无需配置Leaf节点就可以拥有Hub节点，而如果没有Hub节点的话，Leaf节点是不会存在的。对于一个单独Hub节点，你可以配置多个Leaf节点。在Oracle
Flex集群中，只有Hub节点会直接访问OCR和Voting磁盘。当你规划大规模的集群环境时，这将是一个非常不错的功能。这一系列设置会大大降低互连拥堵，并为传统标准集群提供空间以扩大集群。

部署Flex 集群的两种途径：

1. 在配置一个全新集群的时候部署

2. 升级一个标准集群模式到Flex集群

如果你正在配置一个全新的集群，你需要在步骤3中选择集群配置的类型，选择配置一个Flex集群选项，然后你需要在步骤6中对Hub和Leaf节点进行分类。对于每个节点，选择相应角色是Hub或是Leaf，而虚拟主机名也是可选的。

将一个标准集群模式转换为Flex 集群模式需要以下步骤：

1. 用以下命令获取集群的当前状态：

$ ./crsctl get cluster mode status

2. 以root用户执行以下命令：

$ ./crsctl set cluster mode flex  
$ ./crsctl stop crs  
$ ./crsctl start crs –wait

3. 根据设计改变节点角色：

$ ./crsctl get node role config  
$ ./crsctl set node role hub|leaf  
$ ./crsctl stop crs  
$ ./crsctl start crs -wait

 **注意：**

·         你无法从Flex恢复回标准集群模式

·         改变集群节点模式需要集群栈停止

·         确保以一个固定的VIP配置GNS

 **ASM** **磁盘群组中的OCR备份**

对于12c，OCR现在可以在ASM磁盘群组中得以备份。这简化了通过所有节点对OCR备份文件的访问。为了防止OCR的恢复，你不必担心OCR最新的备份是在哪个节点上。可以从任何节点轻易识别存储在ASM中的最新备份并能很容易地执行恢复。

以下演示了如何将ASM磁盘群组设置为OCR备份位置：

$ ./ocrconfig -backuploc +DG_OCR

 **支持IPv6协议**

对于12c，Oracle是支持IPv6网络协议配置的。你现在可以在IPv4或IPv6上配置共有或私有网络接口，尽管如此，你需要确保在所有集群中的节点上使用相同的IP协议。

## 52.    RAC数据库的增强*

 **What-if** **命令评估**

通过 **srvctl** 使用新的 **What-if** 命令评估选项，现在可以确定运行此命令所造成的影响。这一新添加到 **srvctl**
的命令，可以在没有实际执行或是不对当前系统做任何改变的情况下模拟此命令。这在想要对一个已存在的系统进行更改却对结果不确定的时候特别有用。这样，此命令就会提供进行变更的效果。而
**–eval**  选项也可以通过 **crsctl**  命令来使用。

例如，如果你想要知道停止一个特定数据库会发生什么，那么你就可以使用以下示例：

$ ./srvctl stop database –d MYDB –eval  
$ ./crsctl eval modify resource -attr “value”

 **srvctl** **的改进**

对于 **srvctl** 命令还有一些新增功能。以下演示了如何用这些新增功能停止或启动集群上的数据库或实例资源。

## 53.   截断表CASCADE

在之前的版本中，在子表引用一个主表以及子表存在记录的情况下，是不提供截断此主表操作的。而在12c中的带有 **CASCADE** 操作的
**TRUNCATE TABLE** 可以截断主表中的记录，并自动对子表进行递归截断，并作为 **DELETE ON CASCADE**
服从外键引用。由于这是应用到所有子表的，所以对递归层级的数量是没有CAP的，可以是孙子表或是重孙子表等等。

这一增强摈弃了要在截断一个主表之前先截断所有子表记录的前提。新的 **CASCADE** 语句同样也可以应用到表分区和子表分区等。

SQL> TRUNCATE TABLE CASCADE;  
SQL> TRUNCATE TABLE PARTITION CASCADE;

如果对于子表的外键没有定义 **ON DELETE CASCADE**  选项，便会抛出一个ORA-14705错误。

## 54.   对Top-N查询结果限制记录

在之前的版本中有多种间接手段来对顶部或底部记录获取Top-N查询结果。而在12c中，通过新的 **FETCH FIRST|NEXT|PERCENT**
语句简化了这一过程并使其变得更为直接。为了从EMP表检索排名前10的工资记录，可以用以下新的SQL语句：

SQL> SELECT eno,ename,sal FROM emp ORDER BY SAL DESC  
FETCH FIRST 10 ROWS ONLY;

以下示例获取排名前N的所有相似的记录。例如，如果第十行的工资值是5000，并且还有其他员工的工资符合排名前N的标准，那么它们也同样会由WITH
TIES语句获取。

SQL> SELECT eno,ename,sal FROM emp ORDER BY SAL DESC  
FETCH FIRST 10 ROWS ONLY WITH TIES;

以下示例限制从EMP表中获取排名前10%的记录：

SQL> SELECT eno,ename,sal FROM emp ORDER BY SAL DESC  
FETCH FIRST 10 PERCENT ROWS ONLY;

以下示例忽略前5条记录并会显示表的下5条记录：

SQL> SELECT eno,ename,sal FROM emp ORDER BY SAL DESC  
OFFSET 5 ROWS FETCH NEXT 5 ROWS ONLY;

所有这些限制同样可以很好的应用于PL/SQL块。

BEGIN  
SELECT sal BULK COLLECT INTO sal_v FROM EMP  
FETCH FIRST 100 ROWS ONLY;  
END;

## 55.   对SQL*Plus的各种增强

SQL*Plus的隐式结果：12c中，在没有实际绑定某个RefCursor的情况下，SQL*Plus从一个PL/SQL块的一个隐式游标返回结果。这一新的
**dbms_sql.return_result** 过程将会对PL/SQL 块中由SELECT
语句查询所指定的结果加以返回并进行格式化。以下代码对此用法进行了描述：

SQL> CREATE PROCEDURE mp1  
res1 sys_refcursor;  
BEGIN  
open res1 for SELECT eno,ename,sal FROM emp;  
dbms_sql.return_result(res1);  
END;  
SQL> execute mp1;

当此过程得以执行，会在SQL*Plus上返回格式化的记录。

显示不可见字段：在本系列文章的[第一部分](http://www.searchdatabase.com.cn/showcontent_74721.htm)，我已经对不可见字段的新特性做了相关阐述。当字段定义为不可见时，在描述表结构时它们将不会显示。然而，你可以通过在SQL*Plus提示符下进行以下设置来显示不可见字段的相关信息：

SQL> SET COLINVISIBLE ON|OFF

以上设置仅对 **DESCRIBE**  命令有效。目前它还无法对不可见字段上的 **SELECT  **语句结果产生效果。

## 56.   会话级序列

在12c中现在可以创建新的会话级数据库序列来支持会话级序列值。这些序列的类型在有会话级的全局临时表上最为适用。

会话级序列会产生一个独特范围的值，这些值是限制在此会话内的，而非超越此会话。一旦会话终止，会话序列的状态也会消失。以下示例解释了创建一个会话级序列：

SQL> CREATE SEQUENCE my_seq START WITH 1 INCREMENT BY 1 SESSION;  
SQL> ALTER SEQUENCE my_seq GLOBAL|SESSION;

对于会话级序列， **CACHE, NOCACHE, ORDER**  或  **NOORDER**  语句会予以忽略。

## 57.   WITH语句的改善

在12c中，你可以用SQL更快的运行PL/SQL函数或过程，这些是由SQL语句的WITH语句加以定义和声明的。以下示例演示了如何在WITH语句中定义和声明一个过程或函数：

WITH  
PROCEDURE|FUNCTION test1 (…)  
BEGIN  
END;  
SELECT FROM table_name;  
/

尽管你不能在PL/SQL单元直接使用 **WITH** 语句，但其可以在PL/SQL单元中通过一个动态SQL加以引用。

## 58.   扩展数据类型

在12c中，与早期版本相比，诸如 **VARCHAR2, NAVARCHAR2** 以及  **RAW**
这些数据类型的大小会从4K以及2K字节扩展至32K字节。只要可能，扩展字符的大小会降低对LOB数据类型的使用。为了启用扩展字符大小，你必须将
**MAX_STRING_SIZE** 的初始数据库参数设置为 **EXTENDED** 。

要使用扩展字符类型需要执行以下过程：

1. 关闭数据库

2. 以升级模式重启数据库

3. 更改参数:  **ALTER SYSTEM SET MAX_STRING_SIZE=EXTENDED** ;

4. 执行 utl32k.sql as sysdba : SQL> @?/rdbms/admin/utl32k.sql

5. 关闭数据库

6. 以读写模式重启数据库

对比LOB数据类型，在ASSM表空间管理中，扩展数据类型的字段以SecureFiles
LOB加以存储，而在非ASSM表空间管理中，它们则是以BasciFiles LOB进行存储的。

 **注意：** 一旦更改，你就不能再将设置改回STANDARD。

## 59\.  Case-Insensitive Database

Oracle数据库支持不区分大小写的排序规则，例如BINARY_CI或GENERIC_M_CI。
通过将这些归类应用于SQL操作，应用程序可以以不区分大小写的方式执行字符串比较和匹配，而与数据的语言无关。

## 60\.  Real-Time Materialized Views

物化视图可用于查询重写，即使它们与基表未完全同步并被认为是过时的。 使用物化视图日志进行增量计算以及陈旧的物化视图，数据库可以计算查询并实时返回正确的结果。



对于可以用于所有时间的查询重写的物化视图，准确计算结果是实时计算的，结果被优化和快速查询处理以获得最佳性能。
这减轻了严格的要求，即始终必须拥有新鲜的物化视图以获得最佳性能。

## 61\.  Scheduler: Job Incompatibilities

现在，您可以指定一个或多个作业不能在同一时间执行。

有些时候，当其他job已在运行，该job不应该执行的情况。如果两个job都使用相同的资源，您可以指定这两个作业不能在同一时间执行。

## 62\. Scheduler: In-Memory Jobs

从此版本开始，您可以创建In-Memory Jobs。 对于In-Memory Jobs，与正常job相比，写入磁盘的数据更少。 有两种类型的In-
Memory Jobs，重复的In-Memory Jobs和一次性In-Memory Jobs。 对于一次性In-Memory
Jobs，没有任何内容写入磁盘。 对于重复In-Memory Jobs，作业元数据写入磁盘，但没有运行信息。

In-Memory Jobs具有更好的性能和可扩展性。

  

相关文档

内部备注

附件

验证码：

  换一张

输入验证码：

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAYAAAA7MK6iAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEgAACxIB0t1+/AAAABZ0RVh0Q3JlYXRpb24gVGltZQAwOS8yNy8xN+stbYgAAAAcdEVYdFNvZnR3YXJlAEFkb2JlIEZpcmV3b3JrcyBDUzbovLKMAAABm0lEQVRIicXXwXGCQBTG8b+7uZsSTAXRCiQVhA6SXLgmJZgO5BguSQnYgR0EK0hKiAUs5rBvGVlBBEG/GWccxf0JC2/fjna7HU3JEz0BQnlNgbF3yBbIgBRIVWR+m8YcHYPzRE+BBfDY+O/KWQELFZmsNZwnegm8tgT9xCoybyfBeaJvgTVwfybqsgECFZm//Q/VwCgy1lrGroYHQEt4JSxzOgRa4GIAMsdy934PiO5npiKTuTNeXAgtrJH5UBPg54IwwJ3CVqO+swEegPea78MhYPfcroFlzTGhwtbevlFXLOrgqeKw4PeC5on+Ap5qjh37BcTPFjtXL/K+DxSAmwY4k7kiT3SGrT7+FWqNwmHJ9DPPE/0MIEtcQPnMO6EOPnYJAT5r8M4osFXYzqEpVXhXFCBT2HbllJTwM1CAtA1cws9AAVK3OqW066tibOGZd0BXKjLhdZdFuWHiC6Cx6zxLzZ4UiaG6kI2KTLEu+AUkwD6fvaMydpESLI9I33hle3u1hr62VssPZtjtSNussHdvJQoNeyeXITZt/1po2U5WDlb1AAAAAElFTkSuQmCC)![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAYAAAA7MK6iAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEgAACxIB0t1+/AAAABZ0RVh0Q3JlYXRpb24gVGltZQAwOS8yNy8xN+stbYgAAAAcdEVYdFNvZnR3YXJlAEFkb2JlIEZpcmV3b3JrcyBDUzbovLKMAAABu0lEQVRIicWX223CQBBFD26AlOAOMJoCQgl0AFQQSoEOoAN3EPLPKHYHKSFUQD686/jFPkysXMkSQsMc1jt7Z3Z2v9/xSVVTYG2eDJh3Qm5AAeRALiJfvpwzF1hVM2APbLz/rq0zcBCRIhqsqgfgLRLY1VFE9kFgVX0BLsDiSahVCaxE5Lv5ZTIxFJPrYnIPgyeAtuCDYLOnU0BruGEAZo9N9X5OCG1qKSKFXfFg5TVURiT2xe4BEmMOrnNaikgG7AKgOxPrgm9UNU2o3MilhapmInLywHcicjLblnpyrkPAUB0HF7wJvdC31EFwFgCeO+CxUIBsdr1e/V3iVzcqFypUdQswAgpALLgFh7qRREGh71yhSjufo6BjwHa1uapmZs9zwo5aD3yLhBaN1+ur9oe5EqrJYQx0jrvaXSoSqnHFJwtd0S+kMfA8BFw2js87w4XUhX/4wLY7nfD4NWEt0w59r46Ys4hsbVUfHIEEQqFauQtasxIAYwbHwOTP6GiNpzXsqWrBdFOIba9A30BWxDX9YKjJXasFNiPoX8MHx9t/G+gferX5wZLqOhKrM9VQ93CWc96drKa4tP0As8vvCUvsIrEAAAAASUVORK5CYII=)

sentinel

从非ASM迁移数据文件至ASM：

SQL&gt;&nbsp;ALTER&nbsp;DATABASE&nbsp;MOVE&nbsp;DATAFILE&nbsp;&#39;/u00/data/users_01.dbf&#39;&nbsp;TO&nbsp;&#39;+DG_DATA&#39;;

将数据文件从一个ASM磁盘群组迁移至另一个ASM磁盘群组：

SQL&gt;&nbsp;ALTER&nbsp;DATABASE&nbsp;MOVE&nbsp;DATAFILE&nbsp;&#39;+DG_DATA/DBNAME/DATAFILE/users_01.dbf&nbsp;&#39;&nbsp;TO&nbsp;&#39;+DG_DATA_02&#39;;

在数据文件已存在于新路径的情况下，以相同的命名将其覆盖：

SQL&gt;&nbsp;ALTER&nbsp;DATABASE&nbsp;MOVE&nbsp;DATAFILE&nbsp;&#39;/u00/data/users_01.dbf&#39;&nbsp;TO&nbsp;&#39;/u00/data_new/users_01.dbf&#39;&nbsp;REUSE;

复制文件到一个新路径，同时在原路径下保留其拷贝：

SQL&gt;&nbsp;ALTER&nbsp;DATABASE&nbsp;MOVE&nbsp;DATAFILE&nbsp;&#39;/u00/data/users_01.dbf&#39;&nbsp;TO&nbsp;&#39;/u00/data_new/users_01.dbf&#39;&nbsp;KEEP;

当通过查询 **v$session_longops** 动态视图来移动文件时，你可以监控这一过程。另外，你也可以引用 **alert.log**
，Oracle会在其中记录具体的行为。

&nbsp;

## 2.&nbsp;&nbsp;&nbsp; &nbsp;表、表分区或子分区的在线迁移和转换

在Oracle 12c
R1中迁移表分区或子分区到不同的表空间不再需要复杂的过程。与之前版本中未分区表进行在线迁移类似，表分区或子分区可以在线或是离线迁移至一个不同的表空间。当指定了ONLINE语句，所有的DML操作可以在没有任何中断的情况下，在参与这一过程的分区或子分区上执行。与此相反，分区或子分区迁移如果是在离线情况下进行的，DML操作是不被允许的。

将非分区表在线转换为分区表。

在线SPLIT分区和子分区。

在线表移动。

示例：

SQL&gt;&nbsp;ALTER&nbsp;TABLE&nbsp;table_name&nbsp;MOVE&nbsp;PARTITION|SUBPARTITION&nbsp;partition_name&nbsp;TO&nbsp;tablespace&nbsp;tablespace_name;&nbsp;  
SQL&gt;&nbsp;ALTER&nbsp;TABLE&nbsp;table_name&nbsp;MOVE&nbsp;PARTITION|SUBPARTITION&nbsp;partition_name&nbsp;TO&nbsp;tablespace&nbsp;tablespace_name&nbsp;UPDATE&nbsp;INDEXES&nbsp;ONLINE;

第一个示例是用来在离线状况下将一个表分区或子分区迁移至一个新的表空间。第二个示例是在线迁移表分区或子分区并维护表上任何本地或全局的索引。此外，当使用ONLINE语句时，DML操作是不会中断的。

 **重要提示：**

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; UPDATE
INDEXES语句可以避免出现表中任何本地或全局索引无法使用的情况。

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 表的在线迁移限制也适用于此。

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
引入加锁机制来完成这一过程，当然它也会导致性能下降并会产生大量的redo，这取决于分区和子分区的大小。

&nbsp;

## 3.&nbsp;&nbsp;&nbsp; &nbsp;不可见字段

在Oracle 11g R1中，Oracle以不可见索引和虚拟字段的形式引入了一些不错的增强特性。继承前者并发扬光大，Oracle 12c
R1中引入了不可见字段思想。在之前的版本中，为了隐藏重要的数据字段以避免在通用查询中显示，我们往往会创建一个视图来隐藏所需信息或应用某些安全条件。

在12c
R1中，你可以在表中创建不可见字段。当一个字段定义为不可见时，这一字段就不会出现在通用查询中，除非在SQL语句或条件中有显式的提及这一字段，或是在表定义中有DESCRIBED。要添加或是修改一个不可见字段是非常容易的，反之亦然。

SQL&gt;&nbsp;CREATE&nbsp;TABLE&nbsp;emp&nbsp;(eno&nbsp;number(6),&nbsp;ename&nbsp;varchar2(40),&nbsp;sal&nbsp;number(9)&nbsp;INVISIBLE);  
SQL&gt;&nbsp;ALTER&nbsp;TABLE&nbsp;emp&nbsp;MODIFY&nbsp;(sal&nbsp;visible);

你必须在INSERT语句中显式提及不可见字段名以将不可见字段插入到数据库中。虚拟字段和分区字段同样也可以定义为不可见类型。但临时表，外部表和集群表并不支持不可见字段。

&nbsp;

## 4.&nbsp;&nbsp;&nbsp; &nbsp;相同字段上的多重索引

在Oracle 12c
R1之前，一个字段是无法以任何形式拥有多个索引的。或许有人会想知道为什么通常一个字段需要有多重索引，事实上需要多重索引的字段或字段集合是很多的。在12c
R1中，只要索引类型的形式不同，一个字段就可以包含在一个B-tree索引中，同样也可以包含在Bitmap索引中。注意，只有一种类型的索引是在给定时间可用的。

&nbsp;SQL&gt;&nbsp; create table t1 as select object_id,object_name from
dba_objects;

Table created.

create index i1 on t1(object_id);

Index created.

SQL&gt;&nbsp; SELECT index_name,visibility FROM dba_indexes WHERE
index_name=&#39;I1&#39;;

&nbsp;

INDEX_NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
VISIBILIT

\------------------------------ ---------

I1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
VISIBLE

SQL&gt;&nbsp; ALTER INDEX I1 INVISIBLE;

Index altered.

SQL&gt; SELECT index_name,visibility FROM dba_indexes WHERE
index_name=&#39;I1&#39;;

INDEX_NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
VISIBILIT

\------------------------------ ---------

I1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
INVISIBLE

SQL&gt; create bitmap index i2 on t1(object_id);

Index created.

## 5.&nbsp;&nbsp;&nbsp; &nbsp;DDL日志

在之前的版本中没有可选方法来对DDL操作进行日志记录。而在12c
R1中，你现在可以将DDL操作写入xml和日志文件中。这对于了解谁在什么时间执行了create或drop命令是十分有用的。要开启这一功能必须对ENABLE_DDL_LOGGING
初始参数加以配置。这一参数可以在数据库或会话级加以设置。当此参数为启用状态，所有的DDL命令会记录在$ORACLE_BASE/diag/rdbms/DBNAME/log|ddl
路径下的xml和日志文件中。一个xml中包含DDL命令，IP地址，时间戳等信息。这可以帮助确定在什么时候对用户或表进行了删除亦或是一条DDL语句在何时触发。

SQL&gt; show parameter ENABLE_DDL_LOGGING

&nbsp;

NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;TYPE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; VALUE

\------------------------------------ -----------
------------------------------

enable_ddl_logging&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
boolean&nbsp;&nbsp;&nbsp;&nbsp; FALSE

开启DDL日志功能

SQL&gt;&nbsp;ALTER&nbsp;SYSTEM|SESSION&nbsp;SET&nbsp;ENABLE_DDL_LOGGING=TRUE;

以下的DDL语句可能会记录在xml或日志文件中：

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; CREATE|ALTER|DROP|TRUNCATE
TABLE

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; DROP USER

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; CREATE|ALTER|DROP
PACKAGE|FUNCTION|VIEW|SYNONYM|SEQUENCE

&nbsp;

&nbsp;SQL&gt; create table a (id int);

&nbsp;

Table created.

[oracle@ol122 ddl]$ pwd

/u01/app/oracle/diag/rdbms/orcl/orcl/log/ddl

&nbsp;[oracle@ol122 ddl]$ ls

log.xml

[oracle@ol122 ddl]$ cat log.xml

&lt;msg time=&#39;2017-06-05T16:02:38.778+08:00&#39; org_id=&#39;oracle&#39;
comp_id=&#39;rdbms&#39;

&nbsp;msg_id=&#39;opiexe:4695:2946163730&#39; type=&#39;UNKNOWN&#39;
group=&#39;diag_adl&#39;

&nbsp;level=&#39;16&#39; host_id=&#39;ol122&#39;
host_addr=&#39;192.168.132.180&#39;

&nbsp;pid=&#39;4497&#39; version=&#39;1&#39;&gt;

&nbsp;&lt;txt&gt;create table a (id int)

&nbsp;&lt;/txt&gt;

&lt;/msg&gt;

## 6.&nbsp;&nbsp;&nbsp; &nbsp;临时undo

每个Oracle数据库包含一组与系统相关的表空间，例如 **SYSTEM** ， **SYSAUX** ， **UNDO &amp;
TEMP**，并且它们在Oracle数据库中每个都用于不同的目的。在Oracle 12c
R1之前，临时表生成的undo记录是存储在undo表空间里的，通用表和持久表的undo记录也是类似的。而在12c
R12的临时undo功能中，临时undo记录可以存储在一个临时表中，而无需再存储在undo表空间内。这样做的主要好处在于：减少undo表空间，由于信息不会被记录在redo日志中，所以减少了redo数据的生成。你可以在会话级别或者数据库级别来启用临时undo选项。

启用临时undo功能

要使用这一新功能，需要做以下设置：

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 兼容性参数必须设置为12.0.0或更高

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 启用 TEMP_UNDO_ENABLED 初始化参数

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
由于临时undo记录现在是存储在一个临时表空间中的，你需要有足够的空间来创建这一临时表空间

  * 对于会话级，你可以使用：alter SESSION set temp_undo_enabled=true;

查询临时undo信息

以下所列的字典视图是用来查看或查询临时undo数据相关统计信息的：

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; V$TEMPUNDOSTAT

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; DBA_HIST_UNDOSTAT

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; V$UNDOSTAT

要禁用此功能，你只需做以下设置：

SQL&gt;&nbsp;ALTER&nbsp;SYSTEM|SESSION&nbsp;SET&nbsp;TEMP_UNDO_ENABLED=FALSE;

## 7.&nbsp;&nbsp;&nbsp; &nbsp;备份特定用户特权

在11g R2中，引入了SYSASM特权来执行ASM的特定操作。同样地，在12c中引入了SYSBACKUP特权用来在
RMAN中执行备份和恢复命令。因此，你可以在数据库中创建一个本地用户并在不授予其SYSDBA权限的情况下，通过授予SYSBACKUP权限让其能够在RMAN中执行备份和恢复相关的任务。

SQL&gt; create user backupdb identified by oracle;

&nbsp;

User created.

&nbsp;

SQL&gt; grant SYSBACKUP to backupdb;

&nbsp;

Grant succeeded.

[oracle@ol122 ~]$ rman target backupdb/oracle

&nbsp;

## 8.&nbsp;&nbsp;&nbsp; &nbsp;如何在RMAN中执行SQL语句

在12c中，你可以在不需要SQL前缀的情况下在RMAN中执行任何SQL和PL/SQL命令，即你可以从RMAN直接执行任何SQL和PL/SQL命令。如下便是在RMAN中执行SQL语句的示例：

RMAN&gt;&nbsp;SELECT&nbsp;username,machine&nbsp;FROM&nbsp;v$session;&nbsp;  
RMAN&gt;&nbsp;ALTER&nbsp;TABLESPACE&nbsp;users&nbsp;ADD&nbsp;DATAFILE&nbsp;SIZE&nbsp;121m;&nbsp;

## 9.&nbsp;&nbsp;&nbsp; &nbsp;RMAN中的表恢复和分区恢复

Oracle数据库备份主要分为两类：逻辑和物理备份。每种备份类型都有其自身的优缺点。在之前的版本中，利用现有物理备份来恢复表或分区是不可行的。为了恢复特定对象，逻辑备份是必需的。对于12c
R1，你可以在发生drop或truncate的情况下从RMAN备份将一个特定的表或分区恢复到某个时间点或SCN。

此外在12.2，在RMAN执行表恢复之前，增强功能“Disk Space
Check”可以提供辅助实例的可用磁盘空间的前期检查。如果没有足够的空间来创建此实例，则会返回操作系统级错误。

当通过RMAN发起一个表或分区恢复时，大概流程是这样的：

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 确定要恢复表或分区所需的备份集

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
在恢复表或分区的过程中，一个辅助数据库会临时设置为某个时间点

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 利用数据泵将所需表或分区导出到一个dumpfile

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 你可以从源数据库导入表或分区(可选)

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 在恢复过程中进行重命名操作

以下是一个通过RMAN对表进行时间点恢复的示例(确保你已经对稍早的数据库进行了完整备份)：

RMAN&gt;&nbsp;connect&nbsp;target&nbsp;&quot;username/password&nbsp;as&nbsp;SYSBACKUP&quot;;&nbsp;  
RMAN&gt;&nbsp;RECOVER&nbsp;TABLE&nbsp;username.tablename&nbsp;UNTIL&nbsp;TIME&nbsp;&#39;TIMESTAMP…&#39;&nbsp;  
AUXILIARY&nbsp;DESTINATION&nbsp;&#39;/u01/tablerecovery&#39;&nbsp;  
DATAPUMP&nbsp;DESTINATION&nbsp;&#39;/u01/dpump&#39;&nbsp;  
DUMP&nbsp;FILE&nbsp;&#39;tablename.dmp&#39;&nbsp;  
NOTABLEIMPORT&nbsp;--&nbsp;this&nbsp;option&nbsp;avoids&nbsp;importing&nbsp;the&nbsp;table&nbsp;automatically.(此选项避免自动导入表)&nbsp;  
REMAP&nbsp;TABLE&nbsp;&#39;username.tablename&#39;:&nbsp;&#39;username.new_table_name&#39;;&nbsp;--&nbsp;can&nbsp;rename&nbsp;table&nbsp;with&nbsp;this&nbsp;option.(此选项可以对表重命名)

 **重要提示：**

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
确保对于辅助数据库在/u01文件系统下有足够的可用空间，同时对数据泵文件也有同样保证

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
必须要存在一份完整的数据库备份，或者至少是要有SYSTEM相关的表空间备份

以下是在RMAN中应用表或分区恢复的限制和约束：

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; SYS用户表或分区无法恢复

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
存储于SYSAUX和SYSTEM表空间下的表和分区无法恢复

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 当REMAP选项用来恢复的表包含NOT
NULL约束时，恢复此表是不可行的

&nbsp;RECOVER TABLE&nbsp; xyh.test2 until scn 1429510

AUXILIARY DESTINATION &#39;/u01/tablerecovery&#39;

DATAPUMP DESTINATION &#39;/u01/dpump&#39;

DUMP FILE &#39;tablename.dmp&#39;

NOTABLEIMPORT;

REMAP TABLE xyh.test1:xyh.test3;

## 10\. &nbsp;限制PGA的大小

在Oracle 12c R1之前，没有选项可以用来限制和控制PGA的大小。虽然你设置某个大小为PGA_AGGREGATE_TARGET
的初始参数，Oracle会根据工作负载和需求来动态地增大或减小PGA的大小。而在12c中，你可以通过开启自动PGA管理来对PGA设定硬性限制，这需要对PGA_AGGREGATE_LIMIT
参数进行设置。因此，你现在可以通过设置新的参数来对PGA设定硬性限制以避免过度使用PGA。

SQL&gt;&nbsp;ALTER&nbsp;SYSTEM&nbsp;SET&nbsp;PGA_AGGREGATE_LIMIT=2G;&nbsp;  
SQL&gt;&nbsp;ALTER&nbsp;SYSTEM&nbsp;SET&nbsp;PGA_AGGREGATE_LIMIT=0;&nbsp;--disables&nbsp;the&nbsp;hard&nbsp;limit

 **重要提示：**

当超过了当前PGA的限制，Oracle会自动终止/中止会话或进程以保持最合适的PGA内存。

## 11\. IN-Memory Option

alter table test inmemory;

## 12\. SQL*Plus Command History

此功能类似于UNIX平台命令行shell上的history命令。

## 13\. &nbsp;对表分区维护的增强

 **添加多个新分区**

在Oracle 12c R1之前，一次只可能添加一个新分区到一个已存在的分区表。要添加一个以上的新分区，需要对每个新分区都单独执行一次 **ALTER
TABLE ADD PARTITION** 语句。而Oracle 12c只需要使用一条单独的 **ALTER TABLE ADD PARTITION**
&nbsp;命令就可以添加多个新分区，这增加了数据库灵活性。以下示例说明了如何添加多个新分区到已存在的分区表：

SQL&gt;&nbsp;CREATE&nbsp;TABLE&nbsp;emp_part&nbsp;  
&nbsp;&nbsp;&nbsp;&nbsp;(eno&nbsp;number(8),&nbsp;ename&nbsp;varchar2(40),&nbsp;sal&nbsp;number&nbsp;(6))&nbsp;  
&nbsp;&nbsp;PARTITION&nbsp;BY&nbsp;RANGE&nbsp;(sal)&nbsp;  
&nbsp;&nbsp;(PARTITION&nbsp;p1&nbsp;VALUES&nbsp;LESS&nbsp;THAN&nbsp;(10000),&nbsp;  
&nbsp;&nbsp;&nbsp;PARTITION&nbsp;p2&nbsp;VALUES&nbsp;LESS&nbsp;THAN&nbsp;(20000),&nbsp;  
&nbsp;&nbsp;&nbsp;PARTITION&nbsp;p3&nbsp;VALUES&nbsp;LESS&nbsp;THAN&nbsp;(30000)&nbsp;  
&nbsp;&nbsp;);

添加两个新分区：

SQL&gt;&nbsp;ALTER&nbsp;TABLE&nbsp;emp_part&nbsp;ADD&nbsp;&nbsp;PARTITION&nbsp;p4&nbsp;VALUES&nbsp;LESS&nbsp;THAN&nbsp;(35000),&nbsp;  
&nbsp;&nbsp;PARTITION&nbsp;p5&nbsp;VALUES&nbsp;LESS&nbsp;THAN&nbsp;(40000);

同样，只要 **MAXVALUE** 分区不存在，你就可以添加多个新分区到一个列表和系统分区表。

 **如何删除和截断多个分区/子分区**

作为数据维护的一部分，DBA通常会在一个分区表上进行删除或截断分区的维护任务。在12c
R1之前，对于一个已存在的分区表一次只可能删除或截断一个分区。而对于Oracle 12c， 可以用单条 **ALTER TABLE table_name
{DROP|TRUNCATE} PARTITIONS** &nbsp;命令来撤销或合并多个分区和子分区。

下例说明了如何在一个已存在分区表上删除或截断多个分区：

SQL&gt;&nbsp;ALTER&nbsp;TABLE&nbsp;emp_part&nbsp;DROP&nbsp;PARTITIONS&nbsp;p4,p5;&nbsp;  
SQL&gt;&nbsp;ALTER&nbsp;TABLE&nbsp;emp_part&nbsp;TRUNCATE&nbsp;PARTITIONS&nbsp;p4,p5;

要保持索引更新，使用 **UPDATE INDEXES** 或 **UPDATE GLOBAL INDEXES** 语句，如下所示：

SQL&gt;&nbsp;ALTER&nbsp;TABLE&nbsp;emp_part&nbsp;DROP&nbsp;PARTITIONS&nbsp;p4,p5&nbsp;UPDATE&nbsp;GLOBAL&nbsp;INDEXES;&nbsp;  
SQL&gt;&nbsp;ALTER&nbsp;TABLE&nbsp;emp_part&nbsp;TRUNCATE&nbsp;PARTITIONS&nbsp;p4,p5&nbsp;UPDATE&nbsp;GLOBAL&nbsp;INDEXES;

如果你在不使用 **UPDATE GLOBAL INDEXES** &nbsp;语句的情况下删除或截断一个分区，你可以在 **USER_INDEXES**
或 **USER_IND_PARTITIONS** &nbsp;字典视图下查询 **ORPHANED_ENTRIES**
&nbsp;字段以找出是否有索引包含任何的过期条目。

 **将单个分区分割为多个新分区**

在12c中新增强的 **SPLIT PARTITION**
&nbsp;语句可以让你只使用一个单独命令将一个特定分区或子分区分割为多个新分区。下例说明了如何将一个分区分割为多个新分区：

SQL&gt; CREATE TABLE emp_part

(eno number(8), ename varchar2(40), sal number (6))

PARTITION BY RANGE (sal)

(PARTITION p1 VALUES LESS THAN (10000),

PARTITION p2 VALUES LESS THAN (20000),

PARTITION p_max VALUES LESS THAN (MAXVALUE)

);  
SQL&gt;&nbsp;ALTER TABLE emp_part SPLIT PARTITION p_max INTO

(PARTITION p3 VALUES LESS THAN (25000),

PARTITION p4 VALUES LESS THAN (30000), PARTITION p_max);

 **将多个分区合并为一个分区**

你可以使用单条 **ALTER TBALE MERGE PARTITIONS** &nbsp;语句将多个分区合并为一个单独分区：

SQL&gt; CREATE TABLE emp_part

(eno number(8), ename varchar2(40), sal number (6))

PARTITION BY RANGE (sal)

(PARTITION p1 VALUES LESS THAN (10000),

PARTITION p2 VALUES LESS THAN (20000),

PARTITION p3 VALUES LESS THAN (30000),

PARTITION p4 VALUES LESS THAN (40000),

PARTITION p5 VALUES LESS THAN (50000),

PARTITION p_max VALUES LESS THAN (MAXVALUE)

);  
SQL&gt;&nbsp;ALTER&nbsp;TABLE&nbsp;emp_part&nbsp;MERGE&nbsp;PARTITIONS&nbsp;p3,p4,p5&nbsp;INTO&nbsp;PARTITION&nbsp;p_merge;

如果分区范围形成序列，你可以使用如下示例：

SQL&gt;&nbsp;ALTER&nbsp;TABLE&nbsp;emp_part&nbsp;MERGE&nbsp;PARTITIONS&nbsp;p3&nbsp;TO&nbsp;p5&nbsp;INTO&nbsp;PARTITION&nbsp;p_merge;

## 14\. &nbsp;数据库升级改进

每当一个新的Oracle版本发布，DBA所要面临的挑战就是升级过程。该部分我将介绍12c中引入的针对升级的两个改进。

 **预升级脚本**

在12c R1中，原有的 **utlu[121]s.sql** &nbsp;脚本由一个大为改善的预升级信息脚本 **preupgrd.sql**
所取代。除了预升级检查验证，此脚本还能以修复脚本的形式解决在升级过程前后出现的各种问题。

可以对产生的修复脚本加以执行来解决不同级别的问题，例如，预升级和升级后的问题。当手动升级数据库时，脚本必须在实际升级过程初始化之前加以手动执行。然而，当使用DBUA工具来进行数据库升级时，它会将预升级脚本作为升级过程的一部分加以自动执行，而且会提示你去执行修复脚本以防止报错。

如何执行脚本：

SQL&gt;&nbsp;@$ORACLE_12GHOME/rdbms/admin/preupgrd.sql

以上脚本会产生一份日志文件以及一个 **[pre/post]upgrade_fixup.sql** &nbsp;脚本。所有这些文件都位于
**$ORACLE_BASE/cfgtoollogs**
&nbsp;目录下。在你继续真正的升级过程之前，你应该浏览日志文件中所提到的建议并执行脚本以修复问题。

注意：你要确保将 **preupgrd.sql** 和 **utluppkg.sql** &nbsp;脚本从12c
Oracle的目录home/rdbms/admin directory拷贝至当前的Oracle的database/rdbms/admin路径。

 **并行升级功能**

数据库升级时间的长短取决于数据库上所配置的组件数量，而不是数据库的大小。在之前的版本中，我们是无法并行运行升级程序，从而快速完成整个升级过程的。

在12c R1中，原有的 **catupgrd.sql** &nbsp;脚本由 **catctl.pl**
&nbsp;脚本(并行升级功能)替代，现在我们可以采用并行模式运行升级程序了。

以下流程说明了如何初始化并行升级功能(3个过程);你需要在升级模式下在启动数据库后运行这一脚本：

cd&nbsp;$ORACLE_12_HOME/perl/bin&nbsp;  
$&nbsp;./perl&nbsp;catctl.pl&nbsp;–n&nbsp;3&nbsp;-catupgrd.sql

以上两个步骤需要在手动升级数据库时运行。而DBUA也继承了这两个新变化。

## 15\. &nbsp;通过网络恢复数据文件

在12c
R1中另一个重要的增强是，你现在可以在主数据库和备用数据库之间用一个服务名重新获得或恢复数据文件、控制文件、参数文件、表空间或整个数据库。这对于同步主数据库和备用数据库极为有用。

当主数据库和备用数据库之间存在相当大的差异时，你不再需要复杂的前滚流程来填补它们之间的差异。RMAN能够通过网络执行备用恢复以进行增量备份，并且可以将它们应用到物理备用数据库。你可以用服务名直接将所需数据文件从备用点拷贝至主站，这是为了防止主数据库上数据文件、表空间的丢失，或是没有真正从备份集恢复数据文件。

以下流程演示了如何用此新功能执行一个前滚来对备用数据库和主数据库进行同步：

在物理备用数据库上：

./rman&nbsp;target&nbsp;&quot;username/password@standby_db_tns&nbsp;as&nbsp;SYSBACKUP&quot;&nbsp;  
RMAN&gt;&nbsp;RECOVER&nbsp;DATABASE&nbsp;FROM&nbsp;SERVICE&nbsp;primary_db_tns&nbsp;USING&nbsp;COMPRESSED&nbsp;BACKUPSET;

以上示例使用备用数据库上定义的 **primary_db_tns**
&nbsp;连接字符串连接到主数据库，然后执行了一个增量备份，再将这些增量备份传输至备用目的地，接着将应用这些文件到备用数据库来进行同步。然而，需要确保已经对
**primary_db_tns** &nbsp;进行了配置，即在备份数据库端将其指向主数据库。

在以下示例中，我将演示一个场景通过从备用数据库获取数据文件来恢复主数据库上丢失的数据文件：

在主数据库上：

./rman&nbsp;target&nbsp;&quot;username/password@primary_db_tns&nbsp;as&nbsp;SYSBACKUP&quot;&nbsp;  
RMAN&gt;&nbsp;RESTORE&nbsp;DATAFILE&nbsp;‘+DG_DISKGROUP/DBANME/DATAFILE/filename’&nbsp;FROM&nbsp;SERVICE&nbsp;standby_db_tns;

./rman&nbsp;target&nbsp;&quot;username/password@primary_db_tns&nbsp;as&nbsp;SYSBACKUP&quot;&nbsp;  
RMAN&gt;&nbsp;RESTORE&nbsp;DATAFILE&nbsp;‘+DG_DISKGROUP/DBANME/DATAFILE/filename’&nbsp;FROM&nbsp;SERVICE&nbsp;standby_db_tns;

## 16\. &nbsp;对Data Pump的增强

Data Pump版本有了不少有用的改进，例如在导出时将视图转换为表，以及在导入时关闭日志记录等。

 **关闭redo日志的生成**

Data Pump中引入了新的 **TRANSFORM** 选项，这对于对象在导入期间提供了关闭重做生成的灵活性。当为 **TRANSFORM**
选项指定了 **DISABLE_ARCHIVE_LOGGING**
&nbsp;值，那么在整个导入期间，重做生成就会处于关闭状态。这一功能在导入大型表时缓解了压力，并且减少了过度的redo产生，从而加快了导入。这一属性还可应用到表以及索引。以下示例演示了这一功能：

$&nbsp;./impdp&nbsp;directory=dpump&nbsp;dumpfile=abcd.dmp&nbsp;logfile=abcd.log&nbsp;TRANSFORM=DISABLE_ARCHIVE_LOGGING:Y

 **将视图转换为表**

这是Data Pump中另外一个改进。有了 **VIEWS_AS_TABLES**
&nbsp;选项，你就可以将视图数据载入表中。以下示例演示了如何在导出过程中将视图数据载入到表中：

$&nbsp;./expdp&nbsp;directory=dpump&nbsp;dumpfile=abcd.dmp&nbsp;logfile=abcd.log&nbsp;views_as_tables=my_view:my_table

## 17\. &nbsp;实时自动数据诊断监视器 (ADDM) 分析

通过使用诸如AWR、ASH以及ADDM之类的自动诊断工具来分析数据库的健康状况，是每个DBA日程工作的一部分。尽管每种工具都可以在多个层面衡量数据库的整体健康状况和性能，但没有哪个工具可以在数据库反应迟钝或是完全挂起的时候使用。

当数据库反应迟钝或是挂起状态时，而且你已经配置了Oracle 企业管理器
12c的云控制，你就可以对严重的性能问题进行诊断。这对于你了解当前数据库发生了什么状况有很大帮助，而且还能够对此问题给出解决方案。

以下步骤演示了如何在Oracle 企业管理器 12c上分析数据库状态：

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 在访问数据库访问主页面从 **Performance**
菜单选择 **Emergency Monitoring** &nbsp;选项。这会显示挂起分析表中排名靠前的阻止会话。

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 在 **Performance** 菜单选择
**Real-Time ADDM** &nbsp;选项来执行实时ADDM分析。

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 在收集了性能数据后，点击 **Findings**
标签以获得所有结果的交互总结。

## 18\. &nbsp;同时在多个表上收集统计数据

在之前的Oracle数据库版本中，当你执行一个DBMS_STATS
程序来收集表、索引、模式或者数据库级别的统计数据时，Oracle习惯于一次一个表的收集统计数据。如果表很大，那么推荐你采用并行方式。在12c
R1中，你现在可以同时在多个表、分区以及子分区上收集统计数据。在你开始使用它之前，你必须对数据库进行以下设置以开启此功能：

SQL&gt;&nbsp;ALTER&nbsp;SYSTEM&nbsp;SET&nbsp;RESOURCE_MANAGER_PLAN=&#39;DEFAULT_MAIN&#39;;&nbsp;  
SQL&gt;&nbsp;ALTER&nbsp;SYSTEM&nbsp;SET&nbsp;JOB_QUEUE_PROCESSES=4;&nbsp;  
SQL&gt;&nbsp;EXEC&nbsp;DBMS_STATS.SET_GLOBAL_PREFS(&#39;CONCURRENT&#39;,&nbsp;&#39;ALL&#39;);&nbsp;  
SQL&gt;&nbsp;EXEC&nbsp;DBMS_STATS.GATHER_SCHEMA_STATS(&#39;SCOTT&#39;);

&nbsp;

## 19\. &nbsp;OPatch Automation Tool - opatchauto

从12c开始，在集群GRID/RAC环境下，通过root用户使用opatchauto命令安装patch

(注：11.2 GRID通过opatch auto)。

$ ./opatchauto apply -help

OPatch Automation Tool

Copyright (c) 2015, Oracle

Corporation. All rights reserved.

&nbsp;

DESCRIPTION

Apply a System Patch to Oracle Home. User specified the patch

location or the current directory will be taken as the patch location.

opatchauto must run from the GI Home as root user.

SYNTAX

&lt;GI_HOME&gt;/OPatch/opatchauto apply

[-analyze]

[-database

&lt;database names&gt; ]

[-generateSteps]

[-invPtrLoc

&lt;Path to oraInst.loc&gt; ]

[-jre &lt;LOC&gt; ]

[-norestart ]

[-nonrolling ]

[-ocmrf &lt;OCM

response file location&gt; ]

[-oh

&lt;OH_LIST&gt; ]

[ &lt;Patch

Location&gt; ]

其中&quot;-analyze&quot;选项可以模拟OPatchauto
apply，提前检查所有检查项目，但是运行&quot;-analyze&quot;选项不会真正改变系统。

opatchauto 安装GI PSU 具体命令：

1. 同时对GI home 和 all Oracle &nbsp;RAC database homes 打psu：

# opatchauto apply&nbsp; &lt;UNZIPPED_PATCH_LOCATION&gt;/20996835 -ocmrf
&lt;ocm response file&gt;

&nbsp;

2. 只单独对GI home 打psu：

# opatchauto apply&nbsp; &lt;UNZIPPED_PATCH_LOCATION&gt;/20996835 -oh
&lt;GI_HOME&gt; -ocmrf &lt;ocm

response file&gt;

&nbsp;

3.只单独对RAC database&nbsp; homes 打psu：

# opatchauto apply&nbsp; &lt;UNZIPPED_PATCH_LOCATION&gt;/20996835 -oh&nbsp;
&lt;oracle_home1_path&gt;,&lt;oracle_home2_path&gt; -ocmrf &lt;ocm
response&nbsp; file&gt;

## 20\. 不同 Oracle 版本的客户端/服务器互操作性支持矩阵

&nbsp; &nbsp; &nbsp; &nbsp;&nbsp;

![](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124131605_248.png%22/)  

!["2.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180124131618_924.png%22)

## 21\. &nbsp;wait event DISPLAY_NAME

DISPLAY_NAME列中出现的等待事件的更清晰和更具描述性的名称。出现在DISPLAY_NAME列中的名称可以在Oracle数据库版本中更改，因此客户脚本不应该依赖于每个版本的DISPLAY_NAME列中显示的名称。

可以通过如下sql了解：

select name,display_name,wait_class from v$event_name&nbsp; where
name!=display_name order by name；

## 22\. &nbsp;12C 中，发生脑裂时，节点保留策略

在 11.2 及早期版本，在脑裂发生时，节点号小的会保留下来。然而从 12.1.0.2 开始，引入节点权重的概念。从 12.1.0.2
开始，解决脑裂时，权重高的节点将会存活下来。

## 23\. &nbsp;Long Identifiers

提供更长的标识符可为客户在定义其命名方案时提供更大的灵活性，例如更长和更具表现力的表名。

如果COMPATIBLE设置为12.2或更高的值，则名称必须为1到128个字节长，但有以下例外：

l&nbsp; 数据库名称限制在8个字节。

l&nbsp; 磁盘组，可插拔数据库（PDB），回滚段，表空间和表空间集的名称限制为30个字节。

如果标识符包含由句点分隔的多个部分，那么每个属性最多可以长达128个字节。每个周期分隔符以及任何周围的双引号都计数为一个字节。例如，假设您标识如下所示的列：

&quot;schema&quot;.&quot;table&quot;.&quot;column&quot;

schema名称可以是128字节，table可以是128字节，column可以是128字节。每个引号和周期都是单字节字符，因此本示例中标识符的总长度可以高达392字节。

## 24\. &nbsp;CLOB，BLOB和XMLType上的分布式操作

在此版本中，支持对基于LOB的数据类型（如CLOB，BLOB和XMLType）的database link的操作。

## 25\. Oracle Data Guard数据库比较

此新工具可以比较存储在Oracle Data
Guard主数据库中的数据块及其物理备用数据库。使用此工具查找其他工具（如DBVERIFY应用程序）无法检测到的磁盘错误（例如丢失的写入）。

管理员可以验证备用数据库不包含由备用数据库上的I / O堆栈独立引入的静默损坏。 Oracle Data
Guard已经在主数据库或备用数据库上对热数据（数据进行读取或更改）进行了验证，但此新工具提供了全面的验证，包括尚未被Oracle Data
Guard读取或更改的冷数据。这种能力使管理员完全相信备用数据库没有物理损坏。

## 26\. Oracle Data Guard Broker支持多个自动故障转移目标

Oracle Data Guard现在支持快速启动故障转移配置中的多个故障转移目标。 以前的功能仅允许单个快速启动故障转移目标。
如果故障转移目标无法满足主故障时快速启动故障切换的要求，则不会发生自动故障。 指定多个故障转移目标显著提高在需要时总是有备用适于自动故障转移的可能性。

多个故障切换目标通过在主停电时更容易发生自动故障切换来提高高可用性。

## 27\. 在最大保护模式下快速启动故障切换

当Oracle Data Guard在最大保护模式下运行时，现在可以配置快速启动故障切换。

当有多个同步目的地时，用户现在可以在保证的零数据丢失模式下使用多个快速启动故障转移目标来使用自动故障切换。

## 28\. 自动同步Oracle Data Guard配置中的密码文件

此功能可自动在Oracle Data Guard配置中同步密码文件。
SYS，SYSDG等密码更改时，将更新主数据库中的密码文件，然后将更改传播到配置中的所有备用数据库。

## 29\. &nbsp;RMAN：语法增强

RMAN: Syntax Enhancements

You can use the enhanced SET NEWNAME command for the entire tablespace or
database instead of on a per file basis. The new MOVE command enables easier
movement of files to other locations instead of using backup and delete. The
new RESTORE+RECOVER command for data file, tablespace and database performs
restore and recovery in one step versus having to issue offline, restore,
recover, and online operations.

&nbsp;

These enhancements simplify and improve ease-of-use for the SET NEWNAME, MOVE
and RESTORE+RECOVER commands.您可以对整个表空间或数据库使用增强的SET NEWNAME命令，而不是以每个文件为基础。
新的MOVE命令可以轻松地将文件移动到其他位置，而不是使用backup和delete。
用于数据文件，表空间和数据库的新RESTORE+RECOVER命令在一个步骤中执行恢复和恢复，而不必执行offline, restore,
recover和在线操作。

这些增强功能简化了SET NEWNAME，MOVE和RESTORE + RECOVER命令的易用性。

## 30\. SCAN Listener支持HTTP协议

SCAN Listene现在可以使基于HTTP的recovery server的连接根据recovery server计算机上的负载重定向到不同的计算机。

此功能可使连接在不同的恢复服务器机器之间进行负载平衡。

## 31\. 自动部署Oracle Data Guard

Oracle Data Guard快速启动故障转移（自动数据库故障转移）之间的Oracle Data Guard物理复制之间的部署是自动的。

支持使用DBCA命令行界面从现有主数据库创建Oracle Data Guard备用数据库。此功能减少了在Oracle Enterprise
Manager之外创建备用数据库所必须执行的手动步骤。 此外，DBCA允许在备用数据库创建结束时运行自定义脚本。

此功能使用户能够以非常简单的方式从命令行界面脚本创建备用数据库。

## 32\. 本地TEMP表空间

为了改进I / O操作，Oracle在Oracle Database 12c第2版（12.2）中引入了本地临时表空间，以便将溢出写入读取器节点上的本地磁盘。

对于SQL操作，例如散列聚合，排序，散列连接，为WITH子句创建游标持续时间临时表，还有星型转换可以溢出到磁盘（特别是共享磁盘上的全局临时表空间）。本地临时表空间的管理与现有临时表空间的管理类似。

本地临时表空间通过以下方式改进了只读实例中的临时表空间管理：

将临时文件存储在读取器节点私有存储中以充分利用本地存储的I / O优势。

避免昂贵的跨实例临时表空间管理。

增加临时表空间的可寻址性。

通过消除磁盘空间元数据管理来提高实例预热性能。

 **注意：** 您不能使用本地临时表空间来存储数据库对象，例如表或索引。 Oracle global临时表的空间也是同样的限制。

## 33\. Oracle数据库可以包含读/写和只读实例

Oracle Database 12c Release
2（12.2）提供了同一数据库中的两种类型的实例：读/写和只读。读/写实例是常规的Oracle数据库实例，可以处理对数据的更新（例如，DML语句UPDATE，DELETE，INSERT和MERGE），分区维护操作等。您可以直接连接到读/写实例。

&nbsp;

只读实例只能处理查询，无法直接更新数据。您不能直接连接到只读实例。请注意，并行SQL语句包含数据的更新和查询（例如，INSERT INTO
&lt;select query&gt;）。在这种情况下，只有在读/写实例上处理INSERT部分时，才会在读/写和只读实例上处理语句的&lt;select
query&gt;部分。

要将实例指定为只读，请将INSTANCE_MODE参数设置为READ_ONLY。 （参数的默认值为READ_WRITE。）

只读实例的引入显着提高了数据仓库工作负载的并行查询的可扩展性，并允许Oracle数据库在数百个物理节点上运行。

## 34\. &nbsp;Oracle Grid Infrastructure Installation Using Zip Images

在Oracle Grid Infrastructure 12c Release 2（12.2）中，安装介质将替换为Oracle Grid
Infrastructure安装程序的zip文件。 将zip文件解压缩到目标Grid home路径后，用户可以启动安装程序向导。

此功能通过以zip格式直接将Oracle家庭软件映像提供给用户，从而简化了用户的安装体验。
到目前为止，用户必须从自动发布更新（ARU）或Oracle技术网络（OTN）下载安装介质，解压缩文件，然后以setup.exe或runInstaller运行安装程序，将软件复制到他们的系统。

## 35\. I/O Rate Limits for PDBs

此功能限制了可插拔数据库（PDB）发出的物理I / O速率。 您可以将限制指定为每秒的I / O请求或Mbps（每秒兆字节的I / O）。
此限制只能应用于PDB，而不能应用于CDB或非CDB。

后台I / O，如重写日志写入或脏缓冲区高速缓存写入不受限制。

限制值由新的PDB参数MAX_IOPS和MAX_MBPS指定。

## 36\. PDB Character Set

可以在同一多租户容器数据库（CDB）中为每个可插入数据库（PDB）设置一个不同的字符集。

## 37\. PDB Refresh

客户希望定期将更改从源可插拔数据库（PDB）传播到其克隆副本。 在这种情况下，我们说克隆的PDB是源PDB的可刷新副本。
可刷新的克隆PDB只能以只读模式打开，并且可以手动（按需）或自动执行来自源PDB的传播更改。

## 38\. Near Zero Downtime PDB Relocation

这种新功能通过利用克隆功能将可插拔数据库（PDB）从一个CDB重新定位到另一个CDB来显着减少停机时间。
源PDB在实际的克隆操作正在进行的同时仍然是开放的和功能完整的。 当应用增量redo时，源PDB被停止并且目的地PDB被联机，将应用中断减少到非常小的窗口。
源PDB随后废弃。

## 39\. Logical Standby Database AND&nbsp; LogMiner to Support CDBs with PDBs
with Different Character Sets

在Oracle Database 12c Release
2（12.2）中，CDB允许PDB具有不同的字符集，只要根容器具有作为所有PDB字符集的超集的字符集即可。
逻辑备用数据库支持这样的主数据库。LogMiner也支持这样的主数据库。

## 40\. &nbsp;支持CDB中具有不同字符集，时区文件版本和数据库时区的PDB

&nbsp;

## 41\. 支持一个CDB具有Thousands PDB

Oracle Database 12c Release 2（12.2）现在支持在单个多租户容器数据库（CDB）中拥有数千个可插拔数据库（PDB）。

Oracle Database 12c Release 1（12.1.0.1）为每个CDB最多支持252个PDB。
通过为每个CDB支持更多的PDB，您将有更少的CDB来管理，从而进一步降低运营费用。

## 42\. PDB操作系统凭证

Oracle数据库操作系统用户通常是一个高度特权的用户。 在操作系统交互期间使用该用户可能会暴露安全漏洞的漏洞。
此外，使用相同的操作系统用户操作来自不同可插拔数据库（PDB）的系统交互可能会损害属于给定PDB的数据。这提供了保护属于一个PDB的数据不被连接到另一个PDB的用户访问的能力。

（有关如何创建操作系统用户凭据，请参阅DBMS_CREDENTIAL）

## 43\. &nbsp;在升级期间将用户表空间自动设置为只读

并行升级脚本（catctl.pl）的新选项-T可用于在升级期间自动将用户表空间设置为只读，然后在升级后改回读/写。

为了避免在升级期间遇到问题，可以使用此新功能实现更快的回退策略。

请执行以下步骤。

&nbsp;

如果需要，将system表空间复制到本地磁盘。

在升级中使用-T选项可以在升级期间将用户表空间设置为只读。

如果在升级过程中出现问题，则可以通过还原系统表空间的副本并在原始（旧）的Oracle主目录中打开数据库来快速重新启动数据库。

数据库升级助手（DBUA）也支持此功能。

## 44\. Oracle Data Pump Parallel expdp/Import of Metadata

以前仅适用于数据的并行。现在通过启用并行工作的多个进程来导入元数据，Oracle Data Pump导入/导出作业的性能得到了改善。

Oracle Data Pump现在花费更少的时间，因为元数据的并行导入被添加到此版本。

OracleData Pump现在在迁移期间只需要更短的停机时间和更短的导出运行时间。

## 45\. &nbsp;Adding Oracle Data Pump and SQL*Loader Utilities to Instant
Client

This feature adds SQL*Loader, expdp, impdp, exp, and imp to the tools for
instant client.

## 46\. 数据库迁移：支持由DB2 Export Utility生成的LLS文件

此功能有助于将数据从DB2迁移到Oracle数据库。

## 47\. ADG支持ODP和STA

Active Data Guard支持捕获性能数据的自动负载信息库（AWR）并在其上运行AWR数据自动数据库诊断监控（ADDM）分析以及SQL Tuning
Advisor。

## 48\. Grid: I/O Server

此功能可以使Oracle数据库对Oracle ASM磁盘组中的数据进行访问，而不需要根据当前的要求与底层磁盘进行物理“存储连接”。
通过类似于网络文件系统（NFS）服务器向NFS客户端提供数据的方式，通过网络提供对数据的访问。

此功能使客户端群集可以访问磁盘组，而不需要共享存储。

## 49\. 支持Oracle Cluster Interconnect的基于IPv6的IP地址

您可以将集群节点配置为在专用网络上使用基于IPv4或IPv6的IP地址，多个专用网络可用于集群。

专用互连的IPv6支持完成了Oracle Real Application Clusters (Oracle RAC）的IPv6增强工作。 自Oracle
Database 12c Release 1（12.1）以来，Oracle RAC已经为公共网络支持IPv6。

## 50.&nbsp;&nbsp; &nbsp;自动存储管理(ASM)中的增强

 **Flex ASM**

在一个典型的网格基础架构安装环境中，每个节点都运行自身的ASM实例，并将其作为运行于此节点上数据库的存储容器。但这种设置会存在相应的单点故障危险。例如，如果此节点上的ASM实例发生故障，则运行于此节点上的所有数据库和实例都会受到影响。为了避免ASM实例的单点故障，Oracle
12c提供了一个名为Flex ASM的功能。Flex
ASM是一个不同的概念和架构，只有很少数量的ASM实例需要运行在集群中的一些服务器上。当某节点上的一个ASM实例发生故障，Oracle集群就会在另一个不同的节点上自动启动替代ASM实例以加强可用性。另外，这一设置还为运行在此节点上的实例提供了ASM实例负载均衡能力。Flex
ASM的另一个优势就是可以在单独节点上加以配置。

当选择Flex Cluster选项作为集群安装环境的第一部分时，鉴于Flex Cluster的要求，Flex
ASM配置就会被自动选择。传统集群同样也适用于Flex ASM。当你决定使用Flex ASM时，你必须保证所需的网络是可用的。你可以选择Flex
ASM存储选项作为集群安装环境的一部分，或是使用ASMCA在一个标准集群环境下启用Flex ASM。

以下命令显示了当前的ASM模式：

$&nbsp;./asmcmd&nbsp;showclustermode&nbsp;  
$&nbsp;./srvctl&nbsp;config&nbsp;asm

或是连接到ASM实例并查询 **INSTANCE_TYPE** 参数。如果输出值为 **ASMPROX** ，那么，就说明Flex ASM已经配置好了。

 **ASM** **存储限制放宽**

ASM存储硬性限额在最大ASM 磁盘群组和磁盘大小上已经大幅提升。在 12c R1中，ASM支持511个ASM磁盘群组，而在11g
R2中只支持63个。同样，相比起在11g R2中20 PB的磁盘大小，现在已经将这一数字提高到32 PB。

 **对ASM均衡操作的优化**

12c 中新的 **EXPLAIN WORK FOR** &nbsp;语句用于衡量一个给定ASM均衡操作所需的工作量，并在
**V$ASM_ESTIMATE** 动态视图中输入结果。使用此动态视图，你可以调整 **POWER LIMIT**
&nbsp;语句对重新平衡操作工作进行改善。例如，如果你想衡量添加一个新ASM磁盘所需的工作量，在实际执行手动均衡操作之前，你可以使用以下命令：

SQL&gt;&nbsp;EXPLAIN&nbsp;WORK&nbsp;FOR&nbsp;ALTER&nbsp;DISKGROUP&nbsp;DG_DATA&nbsp;ADD&nbsp;DISK&nbsp;data_005;&nbsp;  
SQL&gt;&nbsp;SELECT&nbsp;est_work&nbsp;FROM&nbsp;V$ASM_ESTIMATE;&nbsp;  
SQL&gt;&nbsp;EXPLAIN&nbsp;WORK&nbsp;SET&nbsp;STATEMENT_ID=&#39;ADD_DISK&#39;&nbsp;FOR&nbsp;ALTER&nbsp;DISKGROUP&nbsp;DG_DATA&nbsp;AD&nbsp;DISK&nbsp;data_005;&nbsp;  
SQL&gt;&nbsp;SELECT&nbsp;est_work&nbsp;FROM&nbsp;V$ASM_ESTIMATE&nbsp;WHERE&nbsp;STATEMENT_ID&nbsp;=&nbsp;&#39;ADD_DISK’;

你可以根据从动态视图中获取的输出来调整POWER的限制以改善均衡操作。

 **ASM** **磁盘清理**

在一个ASM磁盘群组中，新的ASM磁盘清理操作分为正常或高冗余两个级别，它可以检验ASM磁盘群组中所有磁盘的逻辑数据破坏，并且可以自动对逻辑破坏进行修复，如果检测到有逻辑数据破坏，就会使用ASM镜像磁盘。磁盘清理可以在磁盘群组，特定磁盘或是某个文件上执行，这样其影响可降到最小程度。以下演示了磁盘清理场景：

SQL&gt;&nbsp;ALTER&nbsp;DISKGROUP&nbsp;dg_data&nbsp;SCRUB&nbsp;POWER&nbsp;LOW:HIGH:AUTO:MAX;&nbsp;  
SQL&gt;&nbsp;ALTER&nbsp;DISKGROUP&nbsp;dg_data&nbsp;SCRUB&nbsp;FILE&nbsp;&#39;+DG_DATA/MYDB/DATAFILE/filename.xxxx.xxxx&#39;&nbsp;  
REPAIR&nbsp;POWER&nbsp;AUTO;

 **ASM** **的活动会话历史(ASH)**

 **V$ACTIVE_SESSION_HISOTRY** &nbsp;动态视图现在还可以提供ASM实例的活动会话抽样。然而，诊断包的使用是受到许可限制的。

## 51.&nbsp;&nbsp; &nbsp;网格(Grid)基础架构的增强

 **Flex** **集群**

Oracle 12c
在集群安装时支持两类配置：传统标准集群和Flex集群。在一个传统标准集群中，所有集群中的节点都彼此紧密地整合在一起，并通过私有网络进行互动，而且可以直接访问存储。另一方面，Flex集群在Hub和Leaf节点结构间引入了两类节点。分配在Hub中的节点类似于传统标准集群，它们通过私有网络彼此互连在一起并对存储可以进行直接读写访问。而Leaf节点不同于Hub节点，它们不需要直接访问底层存储;相反的是，它们通过Hub节点对存储和数据进行访问。

你可以配置多达64个Hub节点，而Leaf节点则可以更多。在Oracle
Flex集群中，无需配置Leaf节点就可以拥有Hub节点，而如果没有Hub节点的话，Leaf节点是不会存在的。对于一个单独Hub节点，你可以配置多个Leaf节点。在Oracle
Flex集群中，只有Hub节点会直接访问OCR和Voting磁盘。当你规划大规模的集群环境时，这将是一个非常不错的功能。这一系列设置会大大降低互连拥堵，并为传统标准集群提供空间以扩大集群。

部署Flex 集群的两种途径：

1. 在配置一个全新集群的时候部署

2. 升级一个标准集群模式到Flex集群

如果你正在配置一个全新的集群，你需要在步骤3中选择集群配置的类型，选择配置一个Flex集群选项，然后你需要在步骤6中对Hub和Leaf节点进行分类。对于每个节点，选择相应角色是Hub或是Leaf，而虚拟主机名也是可选的。

将一个标准集群模式转换为Flex 集群模式需要以下步骤：

1. 用以下命令获取集群的当前状态：

$&nbsp;./crsctl&nbsp;get&nbsp;cluster&nbsp;mode&nbsp;status

2. 以root用户执行以下命令：

$&nbsp;./crsctl&nbsp;set&nbsp;cluster&nbsp;mode&nbsp;flex&nbsp;  
$&nbsp;./crsctl&nbsp;stop&nbsp;crs&nbsp;  
$&nbsp;./crsctl&nbsp;start&nbsp;crs&nbsp;–wait

3. 根据设计改变节点角色：

$&nbsp;./crsctl&nbsp;get&nbsp;node&nbsp;role&nbsp;config&nbsp;  
$&nbsp;./crsctl&nbsp;set&nbsp;node&nbsp;role&nbsp;hub|leaf&nbsp;  
$&nbsp;./crsctl&nbsp;stop&nbsp;crs&nbsp;  
$&nbsp;./crsctl&nbsp;start&nbsp;crs&nbsp;-wait

 **注意：**

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 你无法从Flex恢复回标准集群模式

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 改变集群节点模式需要集群栈停止

·&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 确保以一个固定的VIP配置GNS

 **ASM** **磁盘群组中的OCR备份**

对于12c，OCR现在可以在ASM磁盘群组中得以备份。这简化了通过所有节点对OCR备份文件的访问。为了防止OCR的恢复，你不必担心OCR最新的备份是在哪个节点上。可以从任何节点轻易识别存储在ASM中的最新备份并能很容易地执行恢复。

以下演示了如何将ASM磁盘群组设置为OCR备份位置：

$&nbsp;./ocrconfig&nbsp;-backuploc&nbsp;+DG_OCR

 **支持IPv6协议**

对于12c，Oracle是支持IPv6网络协议配置的。你现在可以在IPv4或IPv6上配置共有或私有网络接口，尽管如此，你需要确保在所有集群中的节点上使用相同的IP协议。

## 52.&nbsp;&nbsp; &nbsp;RAC数据库的增强*

 **What-if** **命令评估**

通过 **srvctl** 使用新的 **What-if** 命令评估选项，现在可以确定运行此命令所造成的影响。这一新添加到 **srvctl**
的命令，可以在没有实际执行或是不对当前系统做任何改变的情况下模拟此命令。这在想要对一个已存在的系统进行更改却对结果不确定的时候特别有用。这样，此命令就会提供进行变更的效果。而
**–eval** &nbsp;选项也可以通过 **crsctl** &nbsp;命令来使用。

例如，如果你想要知道停止一个特定数据库会发生什么，那么你就可以使用以下示例：

$&nbsp;./srvctl&nbsp;stop&nbsp;database&nbsp;–d&nbsp;MYDB&nbsp;–eval&nbsp;  
$&nbsp;./crsctl&nbsp;eval&nbsp;modify&nbsp;resource&nbsp;-attr&nbsp;“value”

 **srvctl** **的改进**

对于 **srvctl** 命令还有一些新增功能。以下演示了如何用这些新增功能停止或启动集群上的数据库或实例资源。

## 53.&nbsp;&nbsp; 截断表CASCADE

在之前的版本中，在子表引用一个主表以及子表存在记录的情况下，是不提供截断此主表操作的。而在12c中的带有 **CASCADE** 操作的
**TRUNCATE TABLE** 可以截断主表中的记录，并自动对子表进行递归截断，并作为 **DELETE ON CASCADE**
服从外键引用。由于这是应用到所有子表的，所以对递归层级的数量是没有CAP的，可以是孙子表或是重孙子表等等。

这一增强摈弃了要在截断一个主表之前先截断所有子表记录的前提。新的 **CASCADE** 语句同样也可以应用到表分区和子表分区等。

SQL&gt;&nbsp;TRUNCATE&nbsp;TABLE&nbsp;CASCADE;&nbsp;  
SQL&gt;&nbsp;TRUNCATE&nbsp;TABLE&nbsp;PARTITION&nbsp;CASCADE;

如果对于子表的外键没有定义 **ON DELETE CASCADE** &nbsp;选项，便会抛出一个ORA-14705错误。

## 54.&nbsp;&nbsp; 对Top-N查询结果限制记录

在之前的版本中有多种间接手段来对顶部或底部记录获取Top-N查询结果。而在12c中，通过新的 **FETCH FIRST|NEXT|PERCENT**
语句简化了这一过程并使其变得更为直接。为了从EMP表检索排名前10的工资记录，可以用以下新的SQL语句：

SQL&gt;&nbsp;SELECT&nbsp;eno,ename,sal&nbsp;FROM&nbsp;emp&nbsp;ORDER&nbsp;BY&nbsp;SAL&nbsp;DESC&nbsp;  
FETCH&nbsp;FIRST&nbsp;10&nbsp;ROWS&nbsp;ONLY;

以下示例获取排名前N的所有相似的记录。例如，如果第十行的工资值是5000，并且还有其他员工的工资符合排名前N的标准，那么它们也同样会由WITH
TIES语句获取。

SQL&gt;&nbsp;SELECT&nbsp;eno,ename,sal&nbsp;FROM&nbsp;emp&nbsp;ORDER&nbsp;BY&nbsp;SAL&nbsp;DESC&nbsp;  
FETCH&nbsp;FIRST&nbsp;10&nbsp;ROWS&nbsp;ONLY&nbsp;WITH&nbsp;TIES;

以下示例限制从EMP表中获取排名前10%的记录：

SQL&gt;&nbsp;SELECT&nbsp;eno,ename,sal&nbsp;FROM&nbsp;emp&nbsp;ORDER&nbsp;BY&nbsp;SAL&nbsp;DESC&nbsp;  
FETCH&nbsp;FIRST&nbsp;10&nbsp;PERCENT&nbsp;ROWS&nbsp;ONLY;

以下示例忽略前5条记录并会显示表的下5条记录：

SQL&gt;&nbsp;SELECT&nbsp;eno,ename,sal&nbsp;FROM&nbsp;emp&nbsp;ORDER&nbsp;BY&nbsp;SAL&nbsp;DESC&nbsp;  
OFFSET&nbsp;5&nbsp;ROWS&nbsp;FETCH&nbsp;NEXT&nbsp;5&nbsp;ROWS&nbsp;ONLY;

所有这些限制同样可以很好的应用于PL/SQL块。

BEGIN&nbsp;  
SELECT&nbsp;sal&nbsp;BULK&nbsp;COLLECT&nbsp;INTO&nbsp;sal_v&nbsp;FROM&nbsp;EMP&nbsp;  
FETCH&nbsp;FIRST&nbsp;100&nbsp;ROWS&nbsp;ONLY;&nbsp;  
END;

## 55.&nbsp;&nbsp; 对SQL*Plus的各种增强

SQL*Plus的隐式结果：12c中，在没有实际绑定某个RefCursor的情况下，SQL*Plus从一个PL/SQL块的一个隐式游标返回结果。这一新的
**dbms_sql.return_result** 过程将会对PL/SQL 块中由SELECT
语句查询所指定的结果加以返回并进行格式化。以下代码对此用法进行了描述：

SQL&gt;&nbsp;CREATE&nbsp;PROCEDURE&nbsp;mp1&nbsp;  
res1&nbsp;sys_refcursor;&nbsp;  
BEGIN&nbsp;  
open&nbsp;res1&nbsp;for&nbsp;SELECT&nbsp;eno,ename,sal&nbsp;FROM&nbsp;emp;&nbsp;  
dbms_sql.return_result(res1);&nbsp;  
END;&nbsp;  
SQL&gt;&nbsp;execute&nbsp;mp1;

当此过程得以执行，会在SQL*Plus上返回格式化的记录。

显示不可见字段：在本系列文章的[第一部分](https://47.100.29.40/highgo_admin/%22http://www.searchdatabase.com.cn/showcontent_74721.htm%22)，我已经对不可见字段的新特性做了相关阐述。当字段定义为不可见时，在描述表结构时它们将不会显示。然而，你可以通过在SQL*Plus提示符下进行以下设置来显示不可见字段的相关信息：

SQL&gt;&nbsp;SET&nbsp;COLINVISIBLE&nbsp;ON|OFF

以上设置仅对 **DESCRIBE** &nbsp;命令有效。目前它还无法对不可见字段上的 **SELECT &nbsp;**语句结果产生效果。

## 56.&nbsp;&nbsp; 会话级序列

在12c中现在可以创建新的会话级数据库序列来支持会话级序列值。这些序列的类型在有会话级的全局临时表上最为适用。

会话级序列会产生一个独特范围的值，这些值是限制在此会话内的，而非超越此会话。一旦会话终止，会话序列的状态也会消失。以下示例解释了创建一个会话级序列：

SQL&gt;&nbsp;CREATE&nbsp;SEQUENCE&nbsp;my_seq&nbsp;START&nbsp;WITH&nbsp;1&nbsp;INCREMENT&nbsp;BY&nbsp;1&nbsp;SESSION;&nbsp;  
SQL&gt;&nbsp;ALTER&nbsp;SEQUENCE&nbsp;my_seq&nbsp;GLOBAL|SESSION;

对于会话级序列， **CACHE, NOCACHE, ORDER** &nbsp;或&nbsp; **NOORDER** &nbsp;语句会予以忽略。

## 57.&nbsp;&nbsp; WITH语句的改善

在12c中，你可以用SQL更快的运行PL/SQL函数或过程，这些是由SQL语句的WITH语句加以定义和声明的。以下示例演示了如何在WITH语句中定义和声明一个过程或函数：

WITH&nbsp;  
PROCEDURE|FUNCTION&nbsp;test1&nbsp;(…)&nbsp;  
BEGIN&nbsp;  
END;&nbsp;  
SELECT&nbsp;FROM&nbsp;table_name;&nbsp;  
/

尽管你不能在PL/SQL单元直接使用 **WITH** 语句，但其可以在PL/SQL单元中通过一个动态SQL加以引用。

## 58.&nbsp;&nbsp; 扩展数据类型

在12c中，与早期版本相比，诸如 **VARCHAR2, NAVARCHAR2** 以及&nbsp; **RAW**
这些数据类型的大小会从4K以及2K字节扩展至32K字节。只要可能，扩展字符的大小会降低对LOB数据类型的使用。为了启用扩展字符大小，你必须将
**MAX_STRING_SIZE** 的初始数据库参数设置为 **EXTENDED** 。

要使用扩展字符类型需要执行以下过程：

1. 关闭数据库

2. 以升级模式重启数据库

3. 更改参数:&nbsp; **ALTER SYSTEM SET MAX_STRING_SIZE=EXTENDED** ;

4. 执行 utl32k.sql as sysdba : SQL&gt; @?/rdbms/admin/utl32k.sql

5. 关闭数据库

6. 以读写模式重启数据库

对比LOB数据类型，在ASSM表空间管理中，扩展数据类型的字段以SecureFiles
LOB加以存储，而在非ASSM表空间管理中，它们则是以BasciFiles LOB进行存储的。

 **注意：** 一旦更改，你就不能再将设置改回STANDARD。

## 59\. &nbsp;Case-Insensitive Database

Oracle数据库支持不区分大小写的排序规则，例如BINARY_CI或GENERIC_M_CI。
通过将这些归类应用于SQL操作，应用程序可以以不区分大小写的方式执行字符串比较和匹配，而与数据的语言无关。

## 60\. &nbsp;Real-Time Materialized Views

物化视图可用于查询重写，即使它们与基表未完全同步并被认为是过时的。 使用物化视图日志进行增量计算以及陈旧的物化视图，数据库可以计算查询并实时返回正确的结果。

&nbsp;

对于可以用于所有时间的查询重写的物化视图，准确计算结果是实时计算的，结果被优化和快速查询处理以获得最佳性能。
这减轻了严格的要求，即始终必须拥有新鲜的物化视图以获得最佳性能。

## 61\. &nbsp;Scheduler: Job Incompatibilities

现在，您可以指定一个或多个作业不能在同一时间执行。

有些时候，当其他job已在运行，该job不应该执行的情况。如果两个job都使用相同的资源，您可以指定这两个作业不能在同一时间执行。

## 62\. Scheduler: In-Memory Jobs

从此版本开始，您可以创建In-Memory Jobs。 对于In-Memory Jobs，与正常job相比，写入磁盘的数据更少。 有两种类型的In-
Memory Jobs，重复的In-Memory Jobs和一次性In-Memory Jobs。 对于一次性In-Memory
Jobs，没有任何内容写入磁盘。 对于重复In-Memory Jobs，作业元数据写入磁盘，但没有运行信息。

In-Memory Jobs具有更好的性能和可扩展性。

  

" name="docDetail" type="hidden">


---
### ATTACHMENTS
[1ce22272c5d014cc80a5dfe719fbb2be]: media/Oracle_12c数据库新特性总结.html
[Oracle_12c数据库新特性总结.html](media/Oracle_12c数据库新特性总结.html)
>hash: 1ce22272c5d014cc80a5dfe719fbb2be  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle 12c数据库新特性总结_files\20180124131618_924.png  

[7f025a17697ee15eb3197c61326b203b]: media/Oracle_12c数据库新特性总结-2.html
[Oracle_12c数据库新特性总结-2.html](media/Oracle_12c数据库新特性总结-2.html)
>hash: 7f025a17697ee15eb3197c61326b203b  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle 12c数据库新特性总结_files\11947ec6e06f4dd6a765bcc48c4fc88d.png  

[e062a7f3848ef5f2ed9961afa1efbfe3]: media/Oracle_12c数据库新特性总结-3.html
[Oracle_12c数据库新特性总结-3.html](media/Oracle_12c数据库新特性总结-3.html)
>hash: e062a7f3848ef5f2ed9961afa1efbfe3  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle 12c数据库新特性总结_files\20180124131605_248.png  

---
### NOTE ATTRIBUTES
>Created Date: 2018-09-25 03:29:05  
>Last Evernote Update Date: 2018-10-01 15:33:54  
>author: YangKwong  
>source: desktop.win  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle 12c数据库新特性总结.html  
>source-application: evernote.win32  