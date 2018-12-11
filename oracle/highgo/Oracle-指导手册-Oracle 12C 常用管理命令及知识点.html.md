# Oracle-指导手册-Oracle 12C 常用管理命令及知识点.html

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

068596504

Oracle-指导手册-Oracle 12C 常用管理命令及知识点

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

用于指导初步学习Oracle 12C。

详细信息

##  **一、实验版本说明**

SQL> select banner from v$version;

BANNER

\------------------------------------------------------------------------------

Oracle Database 12c Enterprise Edition Release 12.2.0.1.0 - 64bit Production

PL/SQL Release 12.2.0.1.0 - Production

CORE    12.2.0.1.0      Production

TNS for 64-bit Windows: Version 12.2.0.1.0 - Production

NLSRTL Version 12.2.0.1.0 - Production

##  **二、12C结构简介**

1、CDB组件（Components of a CDB）

一个CDB数据库容器包含了下面一些组件：

2、ROOT组件

ROOT又叫CDB$ROOT, 存储着ORACLE提供的元数据和Common
User,元数据的一个例子是ORACLE提供的PL/SQL包的源代码，Common User 是指在每个容器中都存在的用户。

3、SEED组件

Seed又叫PDB$SEED,这个是你创建PDBS数据库的模板，你不能在Seed中添加或修改一个对象。一个CDB中有且只能有一个Seed.

4、PDBS

CDB中可以有一个或多个PDBS，PDBS向后兼容，可以像以前在数据库中那样操作PDBS，这里指大多数常规操作。

这些组件中的每一个都可以被称为一个容器。因此，ROOT(根)是一个容器，Seed(种子)是一个容器，每个PDB是一个容器。每个容器在CDB中都有一个独一无二的的ID和名称。

##  **三、12C数据库文件分布**

 **数据文件分布:**

 **CDB** **和PDB：system/sysaux/undo表空间均是独立的，而参数文件、redolog和controlfile是共享的。**

###  **1** **、登录CDB，执行如下查询**

SQL> show pdbs

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED

\---------- ------------------------------ ---------- ----------

         2 PDB$SEED                       READ ONLY  NO

         3 ORCLPDB1                       READ WRITE NO

         4 ORCLPDB2                       MOUNTED

SQL> select con_id, dbid, guid, name , open_mode from v$pdbs;

    CON_ID       DBID GUID                             NAME     OPEN_MODE

\---------- ---------- -------------------------------- ----------------------

         2 3785701224 3C0B56822B2448D1A2A330E6C4141AA9 PDB$SEED  READ ONLY

         3   94456717 7339EF72AE85434EAE621C24DD4ED014 ORCLPDB1  READ WRITE

         4 1392788411 EC320B8DBEF146ABA0C3D907046F027E ORCLPDB2  MOUNTED

SQL> show parameter spfile

NAME    TYPE   VALUE

\------- ----------------------

spfile  string
E:\APP12C\ADMINISTRATOR\VIRTUAL\PRODUCT\12.2.0\DBHOME_1\DATABASE\SPFILEORCL.ORA

 **查看的datafile信息中包含所有的CDB和PDB的数据文件信息：**

SQL> select name from v$datafile;

NAME

\----------------------------------------------------------------------------

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\SYSTEM01.DBF

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\PDBSEED\SYSTEM01.DBF

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\SYSAUX01.DBF

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\PDBSEED\SYSAUX01.DBF

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\UNDOTBS01.DBF

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\PDBSEED\UNDOTBS01.DBF

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\USERS01.DBF

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\ORCLPDB1\SYSTEM01.DBF

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\ORCLPDB1\SYSAUX01.DBF

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\ORCLPDB1\UNDOTBS01.DBF

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\ORCLPDB1\USERS01.DBF

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\ORCLPDB2\SYSTEM01.DBF

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\ORCLPDB2\SYSAUX01.DBF

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\ORCLPDB2\UNDOTBS01.DBF

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\ORCLPDB2\USERS01.DBF

已选择 15 行。



SQL> select name from v$controlfile;

NAME

\------------------------------------------------------------------------

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\CONTROL01.CTL

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\CONTROL02.CTL



SQL> select member from v$logfile;

MEMBER

\------------------------------------------------------------------------

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\REDO03.LOG

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\REDO02.LOG

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\REDO01.LOG

###  **2** **、登录PDB**

SQL> show pdbs

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED

\---------- ------------------------------ ---------- ----------

         3 ORCLPDB1                       READ WRITE NO

 **查看PDB中使用的redolog和controlfile和CDB中的一致。**

SQL> select name from v$controlfile;

NAME

\-------------------------------------------------------------------

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\CONTROL01.CTL

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\CONTROL02.CTL



SQL> select member from v$logfile;

MEMBER

\--------------------------------------------------------------------

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\REDO03.LOG

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\REDO02.LOG

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\REDO01.LOG

###  **3** **、检查所有的表空间信息**

SQL> select con_id,name from v$tablespace order by con_id;

    CON_ID NAME

\---------- ----------------------------------------------------------

         1 SYSAUX

         1 SYSTEM

         1 UNDOTBS1

         1 USERS

         1 TEMP

         2 SYSTEM

         2 SYSAUX

         2 UNDOTBS1

         2 TEMP

         3 SYSTEM

         3 USERS



    CON_ID NAME

\---------- ----------------------------------------------------------

         3 TEMP

         3 UNDOTBS1

         3 SYSAUX

         4 TEMP

         4 UNDOTBS1

         4 SYSAUX

         4 SYSTEM

         4 USERS



已选择 19 行。

##  **四、PDB数据库的启动和停止**

1、因为默认连接的是CDB,所以必须先指定PDB才可以通过sqlplus来启动和关闭PDB，

具体语法和普通实例一样：

alter session set container=orclpdb1;

STARTUP FORCE;

STARTUP OPEN READ WRITE [RESTRICT];

STARTUP OPEN READ ONLY [RESTRICT];

STARTUP UPGRADE;

SHUTDOWN [IMMEDIATE];



2、如果在PDB中可以使用如下语法：

ALTER PLUGGABLE DATABASE OPEN READ WRITE [RESTRICTED] [FORCE];

ALTER PLUGGABLE DATABASE OPEN READ ONLY [RESTRICTED] [FORCE];

ALTER PLUGGABLE DATABASE OPEN UPGRADE [RESTRICTED];

ALTER PLUGGABLE DATABASE CLOSE [IMMEDIATE];



3、如果是在CDB中，可以使用如下语法：

ALTER PLUGGABLE DATABASE <pdd-name-clause> OPEN READ WRITE
[RESTRICTED][FORCE];

ALTER PLUGGABLE DATABASE <pdd-name-clause> OPEN READ ONLY [RESTRICTED]
[FORCE];

ALTER PLUGGABLE DATABASE <pdd-name-clause> OPEN UPGRADE [RESTRICTED];

ALTER PLUGGABLE DATABASE <pdd-name-clause> CLOSE [IMMEDIATE];

<pdd-name-clause>表示的是多个PDB，如果有多个，用逗号分开。 也可以使用ALL或者ALL EXCEPT关键字来替代。

 其中：

ALL：表示所有的PDBS。

ALLEXCEPT 表示需要排除的PDBS。



如：

ALTER PLUGGABLE DATABASE pdb1, pdb2 OPEN READ ONLY FORCE;

ALTER PLUGGABLE DATABASE pdb1, pdb2 CLOSE IMMEDIATE;

ALTER PLUGGABLE DATABASE ALL OPEN;

ALTER PLUGGABLE DATABASE ALL CLOSE IMMEDIATE;

ALTER PLUGGABLE DATABASE ALL EXCEPT pdb1 OPEN;

ALTER PLUGGABLE DATABASE ALL EXCEPT pdb1 CLOSE IMMEDIATE;

##  **五、部分常用命令**

###  **1** **、查看是否为cdb**

SQL> select name,log_mode,open_mode,cdb from v$database;

NAME      LOG_MODE     OPEN_MODE            CDB

\--------- ------------ -------------------- ---

ORCL   NOARCHIVELOG READ WRITE           YES

###  ** ** **2** **、查看容器数据库中的pdb**

SQL> col pdb_name for a30

SQL> select pdb_id,pdb_name,dbid,status from dba_pdbs;

    PDB_ID PDB_NAME                             DBID STATUS

\---------- ------------------------------ ---------- -----------

         3 ORCLPDB1                         94456717 NORMAL

         2 PDB$SEED                       3785701224 NORMAL

         4 ORCLPDB2                       1392788411 NORMAL

SQL> select con_id,dbid,name,open_mode from v$pdbs;

    CON_ID       DBID  NAME     OPEN_MODE

\----------------------------------------

        2 3785701224   PDB$SEED  READ ONLY

        3   94456717   ORCLPDB1  MOUNTED

        4 1392788411   ORCLPDB2  MOUNTED

###  **3** **、启动pdb**

SQL> alter pluggable database ORCLPDB1 open;

插接式数据库已变更。

 SQL> select con_id,dbid,name,open_mode from v$pdbs;

    CON_ID       DBID  NAME     OPEN_MODE

\----------------------------------------

        2 3785701224   PDB$SEED  READ ONLY

        3   94456717   ORCLPDB1  READ WRITE

        4 1392788411   ORCLPDB2  MOUNTED

###  **4** **、查看监听配置详情**

[oracle@oel6 admin]$ cat listener.ora

# listener.ora Network Configuration File:
/u01/app/product/12.1.0/dbname_1/network/admin/listener.ora

# Generated by Oracle configuration tools.

 SID_LIST_LISTENER =

  (SID_LIST =

    (SID_DESC =

      (GLOBAL_DBNAME = orcl)

      (ORACLE_HOME = /u01/app/product/12.1.0/dbname_1)

      (SID_NAME = orcl)

    )

    (SID_DESC =

      (GLOBAL_DBNAME = orclpdb1)

      (ORACLE_HOME = /u01/app/product/12.1.0/dbname_1)

      (SID_NAME = orcl)

    )

  )



LISTENER =

  (DESCRIPTION =

    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.18.145)(PORT = 1521))

  )



ADR_BASE_LISTENER = /u01/app



[oracle@oel6 admin]$ cat tnsnames.ora

# tnsnames.ora Network Configuration File:
/u01/app/product/12.1.0/dbname_1/network/admin/tnsnames.ora

# Generated by Oracle configuration tools.



ORCL =

  (DESCRIPTION =

    (ADDRESS_LIST =

      (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.18.145)(PORT = 1521))

    )

    (CONNECT_DATA =

      (SERVICE_NAME = orcl)

    )

  )





orclpdb1 =

  (DESCRIPTION =

    (ADDRESS_LIST =

      (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.18.145)(PORT = 1521))

    )

    (CONNECT_DATA =

    (SID=guard6)

      (SERVICE_NAME = orclpdb1)

    )

  )

###  **5** **、连接到pdb数据库**

C:\Users\user>sqlplus sys/********@orclpdb1 as sysdba

 SQL*Plus: Release 11.2.0.1.0 Production on Wed Dec 10 16:38:35 2014

 Copyright (c) 1982, 2010, Oracle.  All rights reserved.

 Connected to:

Oracle Database 12c Enterprise Edition Release 12.2.0.1.0 - 64bit Production

With the Partitioning, Oracle Label Security, OLAP, Advanced Analytics

and Real Application Testing options

 SQL> select name from v$pdbs;

 NAME

\------------------------------

ORCLPDB1

###  **6** **、连接到cdb**

 C:\Users\user>sqlplus sys/********@orcl as sysdba

 SQL*Plus: Release 11.2.0.1.0 Production on Wed Dec 10 16:40:37 2014

 Copyright (c) 1982, 2010, Oracle.  All rights reserved.

 Connected to:

Oracle Database 12c Enterprise Edition Release 12.2.0.1.0 - 64bit Production

With the Partitioning, Oracle Label Security, OLAP, Advanced Analytics

and Real Application Testing options

 SQL> select name from v$pdbs;

NAME

\----------------------------------

PDB$SEED

ORCLPDB1

ORCLPDB2

###  **7** **、从cdb切换到pdb**

SQL> alter session set container=orclpdb1;

 Session altered.

 SQL> select name from v$pdbs;

 NAME

\------------------------------

ORCLPDB1

##  **六、开启inmemory**

###  **1** **、检查确认未开启**

SQL> col value for a20

SQL> col name for a40

SQL> select name,value from v$parameter where name like '%inm%';

NAME                                     VALUE

\---------------------------------------- --------------------

 **inmemory_size                             0**

inmemory_clause_default

inmemory_force                           DEFAULT

inmemory_query                           ENABLE

inmemory_max_populate_servers            0

inmemory_trickle_repopulate_servers_perc 1

ent

optimizer_inmemory_aware                 TRUE

 7 rows selected.



SQL> show sga

Total System Global Area 1694498816 bytes

Fixed Size                  2925168 bytes

Variable Size             452988304 bytes

Database Buffers         1224736768 bytes

Redo Buffers               13848576 bytes

###  **2** **、设置in内存大小**

SQL> alter system set inmemory_size=600m scope=spfile;

System altered.

###  **3** **、设置加载到内存的进程数量**

SQL> alter system set inmemory_max_populate_servers=2 scope=both;

System altered.

###  ** ** **4** **、启动数据库验证已开启**

SQL> startup

ORACLE instance started.

 Total System Global Area 1694498816 bytes

Fixed Size                  2925168 bytes

Variable Size             503319952 bytes

Database Buffers          536870912 bytes

Redo Buffers               13848576 bytes

In-Memory Area            637534208 bytes

Database mounted.

Database opened.

##  **七、用户和角色**

在Oracle12C中，用户权限的管理相对传统的 Oracle 单数据库环境稍有不同。在多租户环境中有两种类型的用户。

①：共同用户（Common User）： 该用户存在所有容器 （根和所有的 Pdb） 中。

②：本地用户（Local User）： 用户只有在特定的 PDB 中存在。同样的用户名中可以存在多个Pdb中创建，但它们之间没有关系。

同样，有两种类型的角色：如

①：共同角色（Common Role）： 该角色在所有容器 （根和所有的 Pdb） 中。

②：本地角色（Local Role）： 该角色只存在于特定的 PDB。可以在多个 Pdb中创建相同的角色名称，但它们之间没有关系。

一些 DDL 语句有扩充，以使他们能够定向到当前容器还是所有容器的CONTAINER子句。它的使用将在以下各节中进行演示。

注意：

   在 cdb 中创建公共用户的时候， pdbs 中也会创建相同用户。若CDB 下 GRANT
命令赋权，如果赋权时未指定container=all，则赋权只在CDB中生效，并不会在PDB中生效,这个用户要能够访问PDB，需要切换到 pdb
再赋权。。若赋权时指定 container=all，则赋权在CDB中生效，也在PDB中生效。

###  **1** **、在CDB中，给用户赋权时未指定container=all**

SQL> show con_name;

CON_NAME

\------------------------------

CDB$ROOT



SQL> create user c##zhang identified by zhang;

SQL> grant create session to c##zhang;
\--赋权给用户，这个时候开启另一个窗口使用该用户登录pdb的时候是没有权限的，如下：



[oracle@localhost ~]$ sqlplus c##zhang/zhang@192.168.2.100/testpdb

SQL*Plus: Release 12.2.0.1.0 Production on Tue Jul 18 15:15:51 2017

Copyright (c) 1982, 2016, Oracle.  All rights reserved.

ERROR:

ORA-01045: user C##ZHANG lacks CREATE SESSION privilege; logon denied



\----切换到pdb中，给用户赋权就可以登录了：

SQL> alter session set container=testpdb;

SQL> grant create session to c##zhang;



###  **2** **、在CDB中，给用户赋权时指定container=all**

SQL> create user c##zhang1 identified by zhang;

SQL> grant create session to c##zhang1 container=all;



###  **3** **、创建公共角色**

SQL> show con_name

CON_NAME

\------------------------------

CDB$ROOT  



SQL> create role c##role;   \---创建角色

SQL> grant select on dba_objects to c##role container=all;  \--给这个角色加权限

SQL> grant c##role to c##zhang1 container=all;  \--将角色赋给公共用户

SQL> alter session set container=testpdb;  \---切换到pdb

SQL> grant c##role to admin;   \---也可以把这个角色赋予pdb中的本地用户



###  **4** **、本地角色**

  本地角色是以类似的方式到 pre-12 c 数据库创建的。每个 PDB 可以具有与匹配的名称，因为当地的作用范围仅限于当前 PDB 的角色。

必须满足以下条件。

①：必须连接到具有CREATE ROLE权限的用户。

②：如果您连接到公共用户，容器必须设置为本地 PDB。

③：角色名称为本地角色不必须与"C##"或"c##"作为前缀。

④：角色名称必须是唯一在 PDB 内。

⑤：本地角色可以赋权给公共用户（作用范围局限于pdb内操作，不影响CDB权限）或者本地用户。如：



SQL> show con_name;

CON_NAME

\------------------------------

TESTPDB



SQL> create role pdb_role;    \---创建角色

SQL> grant select on dba_tables to pdb_role;  \--给角色加权限

SQL> grant pdb_role to c##zhang;  \--将角色赋予公共用户

SQL> grant pdb_role to admin;   \---将角色赋予本地用户



##  **八、创建和删除PDB**



使用CREATE PLUGGABLE DATABASE可以从SEED来创建一个PDB。当前的容器必须是CDB root。

SYS@testdb> show con_name

CON_NAME

\------------------------------

CDB$ROOT



SYS@testdb> CREATE PLUGGABLE DATABASE test_pdb ADMIN USER testadm IDENTIFIED
BY "rF" ROLES=(CONNECT)
file_name_convert=(‘/data/oradata/testdb/pdbseed‘,‘/data/oradata/testdb/test_pdb‘)
path_prefix=‘/data/oradata/testdb/test_pdb‘;

Pluggable database created.



SYS@testdb> show pdbs

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED

\---------- ------------------------------ ---------- ----------

         2 PDB$SEED                       READ ONLY  NO

         3 TEST_PDB                       MOUNTED

        

使用DROP PLUGGABLE DATABASE来删除PDB

drop pluggable database test_pdb including datafiles;

##  **九、数据文件重命名与迁移**

###  **1** **、重命名数据文件**

SQL> ALTER DATABASE MOVE DATAFILE '/u01/data/users01.dbf' TO
'/u01/data/users_02.dbf';

###  **2** **、从非ASM存储迁移数据文件到ASM**

SQL> ALTER DATABASE MOVE DATAFILE '/u01/data/users_01.dbf' TO '+DG_DATA';

数据文件从一个ASM磁盘组迁移到另一个：

SQL> ALTER DATABASE MOVE DATAFILE '+DG_DATA/users_01.dbf' TO '+DG_DATA_02';

###  **3** **、如果数据文件在新位置也存在，则覆盖同名的数据文件**

SQL> ALTER DATABASE MOVE DATAFILE '/u01/data/users_01.dbf' TO
'/u02/data_new/users_01.dbf' REUSE;

###  **4** **、数据文件拷贝到新位置，旧位置保留旧的拷贝**

SQL> ALTER DATABASE MOVE DATAFILE '/u00/data/users_01.dbf' TO
'/u01/data_new/users_01.dbf' KEEP;

通过查询动态视图v$session_longops，你可以监控数据文件移动的进程。另外，也可以参考数据库的alert.log，因为，Oracle会把正在进行的操作的详细信息写入该日志中。



###  **其他注意事项**

当执行如下命令后，会生成SYSTEM02.DBF文件，且SYSTEM01.DBF文件不会被删除：

SQL> alter database move datafile
'E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\SYSTEM01.DBF' to
'E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\SYSTEM02.DBF';

数据库已更改。



当执行如下命令后，SYSTEM02.DBF文件会被删除：

SQL> alter database move datafile
'E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\SYSTEM02.DBF' to
'E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\SYSTEM01.DBF' reu

se;

数据库已更改。

##  **十、CDB/PDB用户的创建与对象管理**

在Oracle
12C中，账号分为两种，一种是公用账号，一种是本地账号（亦可理解为私有账号）。共有账号是指在CDB下创建，并在全部PDB中生效的账号，另一种是在PDB中创建的账号。

针对这两种账号的测试如下：

###  **1** **、在PDB中创建测试账号**

 SQL> alter session set container=pdb01;

Session altered.

 SQL> select username from dba_users where username like 'GUI%';

no rows selected

 SQL> CREATE USER TEST IDENTIFIED BY test;

User created.



SQL> grant dba to test;

Grant succeeded.



SQL> show con_name

CON_NAME

\------------------------------

PDB01



SQL> conn /as sysdba

Connected.

SQL> create user test identified by test;

create user test identified by test

            *

ERROR at line 1:

ORA-65096: invalid common user or role name

SQL> show con_name

 CON_NAME

\------------------------------

CDB$ROOT

 **结论：**

如果在PDB中已经存在一个用户或者角色，则在CDB中不能创建相同的账号或者角色名。

###  **2** **、在CDB中创建测试账号**

SQL> show con_name

 CON_NAME

\------------------------------

CDB$ROOT

SQL> create user C##GUIJIAN IDENTIFIED BY guijian;   \------注意CDB中创建用户一定要带上c##

User created.

SQL> create user c#gui identified by gui;

create user c#gui identified by gui

            *

ERROR at line 1:

ORA-65096: invalid common user or role name



SQL> select username from dba_users where username like '%GUI%';

 USERNAME

\------------------------------------------------------------------------------

C##GUIJIAN



SQL> ALTER SESSION SET CONTAINER=PDB01;



Session altered.



SQL> select username from dba_users where username like '%GUI%';

 USERNAME

\------------------------------------------------------------------------------

C##GUIJIAN



SQL> create user guijian identified by guijian;

 User created.

同样在CDB中创建账号后不能在PDB中出现同名的账号，因CDB中的账号对所有的PDB都是有效的。

SQL> create user c##guijian identified by guijian;

create user c##guijian identified by guijian

            *

ERROR at line 1:

ORA-65094: invalid local user or role name

SQL> alter session set container=pdba;

 Session altered.



SQL> show user

USER is "SYS"

SQL> alter user sys identified by sys;

alter user sys identified by sys

*

ERROR at line 1:

ORA-65066: The specified changes must apply to all containers



SQL> show con_name

 CON_NAME

\------------------------------

PDBA



SQL> conn /as sysdba

Connected.

SQL> show con_name



CON_NAME

\------------------------------

CDB$ROOT

SQL> alter user sys identified by sys;

 User altered.



SQL>

  **3** **、CDB下创建账号的权限问题**

SQL> conn / as sysdba

Connected.

SQL> grant connect,create session to c##cdb;

 Grant succeeded.



SQL> conn c##cdb/cdb@pdba

ERROR:

ORA-01045: user C##CDB lacks CREATE SESSION privilege; logon denied

 Warning: You are no longer connected to ORACLE.



SQL> conn / as sysdba

Connected.

SQL> alter session set container=pdba;

 Session altered.



SQL> grant resource,connect to c##cdb;

 Grant succeeded.



SQL> conn  /as sysdba

Connected.

SQL> conn c##cdb/cdb@pdba

Connected.

SQL> conn / as sysdba

Connected.

SQL> create user guijian identified by guijian container=current;

create user guijian identified by guijian container=current

                                  *

ERROR at line 1:

ORA-65049: creation of local user or role is not allowed in CDB$ROOT



SQL> create user c##guijian identified by guijian container=current;

create user c##guijian identified by guijian container=current

            *

ERROR at line 1:

ORA-65094: invalid local user or role name



SQL> show con_name

CON_NAME

\------------------------------

CDB$ROOT

SQL> create user c##guijian identified by guijian container=all;

User created.



SQL> create user c##guijian01 identified by guijian;

User created.



SQL> create user test identified by test;

create user test identified by test

            *

第 1 行出现错误:

ORA-65096: 公用用户名或角色名无效



SQL> create user c##test identified by test;

用户已创建。

##  **十一、12C参数修改效果说明**

在cdb中修改参数,会默认所有pdb均自动继承;如果在pdb中修改值会覆盖cdb参数,而且只对当前pdb生效,并记录在PDB_SPFILE$。

pdb中不同于root的参数是记录在root的PDB_SPFILE$基表中.

整个CDB的工作原理是如果在PDB_SPFILE$中无相关参数记录,则继承cdb的参数文件中值,如果PDB_SPFILE$中有记录则使用该值覆盖cdb参数文件值.

  

相关文档

内部备注

附件

验证码：

  换一张

输入验证码：

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAYAAAA7MK6iAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEgAACxIB0t1+/AAAABZ0RVh0Q3JlYXRpb24gVGltZQAwOS8yNy8xN+stbYgAAAAcdEVYdFNvZnR3YXJlAEFkb2JlIEZpcmV3b3JrcyBDUzbovLKMAAABm0lEQVRIicXXwXGCQBTG8b+7uZsSTAXRCiQVhA6SXLgmJZgO5BguSQnYgR0EK0hKiAUs5rBvGVlBBEG/GWccxf0JC2/fjna7HU3JEz0BQnlNgbF3yBbIgBRIVWR+m8YcHYPzRE+BBfDY+O/KWQELFZmsNZwnegm8tgT9xCoybyfBeaJvgTVwfybqsgECFZm//Q/VwCgy1lrGroYHQEt4JSxzOgRa4GIAMsdy934PiO5npiKTuTNeXAgtrJH5UBPg54IwwJ3CVqO+swEegPea78MhYPfcroFlzTGhwtbevlFXLOrgqeKw4PeC5on+Ap5qjh37BcTPFjtXL/K+DxSAmwY4k7kiT3SGrT7+FWqNwmHJ9DPPE/0MIEtcQPnMO6EOPnYJAT5r8M4osFXYzqEpVXhXFCBT2HbllJTwM1CAtA1cws9AAVK3OqW066tibOGZd0BXKjLhdZdFuWHiC6Cx6zxLzZ4UiaG6kI2KTLEu+AUkwD6fvaMydpESLI9I33hle3u1hr62VssPZtjtSNussHdvJQoNeyeXITZt/1po2U5WDlb1AAAAAElFTkSuQmCC)![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAYAAAA7MK6iAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEgAACxIB0t1+/AAAABZ0RVh0Q3JlYXRpb24gVGltZQAwOS8yNy8xN+stbYgAAAAcdEVYdFNvZnR3YXJlAEFkb2JlIEZpcmV3b3JrcyBDUzbovLKMAAABu0lEQVRIicWX223CQBBFD26AlOAOMJoCQgl0AFQQSoEOoAN3EPLPKHYHKSFUQD686/jFPkysXMkSQsMc1jt7Z3Z2v9/xSVVTYG2eDJh3Qm5AAeRALiJfvpwzF1hVM2APbLz/rq0zcBCRIhqsqgfgLRLY1VFE9kFgVX0BLsDiSahVCaxE5Lv5ZTIxFJPrYnIPgyeAtuCDYLOnU0BruGEAZo9N9X5OCG1qKSKFXfFg5TVURiT2xe4BEmMOrnNaikgG7AKgOxPrgm9UNU2o3MilhapmInLywHcicjLblnpyrkPAUB0HF7wJvdC31EFwFgCeO+CxUIBsdr1e/V3iVzcqFypUdQswAgpALLgFh7qRREGh71yhSjufo6BjwHa1uapmZs9zwo5aD3yLhBaN1+ur9oe5EqrJYQx0jrvaXSoSqnHFJwtd0S+kMfA8BFw2js87w4XUhX/4wLY7nfD4NWEt0w59r46Ys4hsbVUfHIEEQqFauQtasxIAYwbHwOTP6GiNpzXsqWrBdFOIba9A30BWxDX9YKjJXasFNiPoX8MHx9t/G+gferX5wZLqOhKrM9VQ93CWc96drKa4tP0As8vvCUvsIrEAAAAASUVORK5CYII=)

sentinel

PL/SQL Release 12.2.0.1.0 - Production

CORE&nbsp;&nbsp;&nbsp; 12.2.0.1.0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Production

TNS for 64-bit Windows: Version 12.2.0.1.0 - Production

NLSRTL Version 12.2.0.1.0 - Production

##  **二、12C结构简介**

1、CDB组件（Components of a CDB）

一个CDB数据库容器包含了下面一些组件：

2、ROOT组件

ROOT又叫CDB$ROOT, 存储着ORACLE提供的元数据和Common
User,元数据的一个例子是ORACLE提供的PL/SQL包的源代码，Common User 是指在每个容器中都存在的用户。

3、SEED组件

Seed又叫PDB$SEED,这个是你创建PDBS数据库的模板，你不能在Seed中添加或修改一个对象。一个CDB中有且只能有一个Seed.

4、PDBS

CDB中可以有一个或多个PDBS，PDBS向后兼容，可以像以前在数据库中那样操作PDBS，这里指大多数常规操作。

这些组件中的每一个都可以被称为一个容器。因此，ROOT(根)是一个容器，Seed(种子)是一个容器，每个PDB是一个容器。每个容器在CDB中都有一个独一无二的的ID和名称。

##  **三、12C数据库文件分布**

 **数据文件分布:**

 **CDB** **和PDB：system/sysaux/undo表空间均是独立的，而参数文件、redolog和controlfile是共享的。**

###  **1** **、登录CDB，执行如下查询**

SQL&gt; show pdbs

&nbsp;&nbsp;&nbsp; CON_ID
CON_NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
OPEN MODE&nbsp; RESTRICTED

\---------- ------------------------------ ---------- ----------

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2
PDB$SEED&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
READ ONLY&nbsp; NO

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 3
ORCLPDB1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
READ WRITE NO

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 4
ORCLPDB2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
MOUNTED

SQL&gt; select con_id, dbid, guid, name , open_mode from v$pdbs;

&nbsp;&nbsp;&nbsp; CON_ID&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; DBID
GUID&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
NAME&nbsp;&nbsp;&nbsp;&nbsp; OPEN_MODE

\---------- ---------- -------------------------------- ----------------------

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2 3785701224
3C0B56822B2448D1A2A330E6C4141AA9 PDB$SEED&nbsp; READ ONLY

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; 94456717
7339EF72AE85434EAE621C24DD4ED014 ORCLPDB1&nbsp; READ WRITE

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 4 1392788411
EC320B8DBEF146ABA0C3D907046F027E ORCLPDB2&nbsp; MOUNTED

SQL&gt; show parameter spfile

NAME &nbsp;&nbsp;&nbsp;TYPE&nbsp;&nbsp; VALUE

\------- ----------------------

spfile&nbsp; string
E:\APP12C\ADMINISTRATOR\VIRTUAL\PRODUCT\12.2.0\DBHOME_1\DATABASE\SPFILEORCL.ORA

 **查看的datafile信息中包含所有的CDB和PDB的数据文件信息：**

SQL&gt; select name from v$datafile;

NAME

\----------------------------------------------------------------------------

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\SYSTEM01.DBF

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\PDBSEED\SYSTEM01.DBF

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\SYSAUX01.DBF

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\PDBSEED\SYSAUX01.DBF

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\UNDOTBS01.DBF

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\PDBSEED\UNDOTBS01.DBF

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\USERS01.DBF

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\ORCLPDB1\SYSTEM01.DBF

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\ORCLPDB1\SYSAUX01.DBF

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\ORCLPDB1\UNDOTBS01.DBF

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\ORCLPDB1\USERS01.DBF

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\ORCLPDB2\SYSTEM01.DBF

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\ORCLPDB2\SYSAUX01.DBF

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\ORCLPDB2\UNDOTBS01.DBF

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\ORCLPDB2\USERS01.DBF

已选择 15 行。

&nbsp;

SQL&gt; select name from v$controlfile;

NAME

\------------------------------------------------------------------------

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\CONTROL01.CTL

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\CONTROL02.CTL

&nbsp;

SQL&gt; select member from v$logfile;

MEMBER

\------------------------------------------------------------------------

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\REDO03.LOG

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\REDO02.LOG

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\REDO01.LOG

###  **2** **、登录PDB**

SQL&gt; show pdbs

&nbsp;&nbsp;&nbsp; CON_ID
CON_NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
OPEN MODE&nbsp; RESTRICTED

\---------- ------------------------------ ---------- ----------

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 3
ORCLPDB1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
READ WRITE NO

 **查看PDB中使用的redolog和controlfile和CDB中的一致。**

SQL&gt; select name from v$controlfile;

NAME

\-------------------------------------------------------------------

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\CONTROL01.CTL

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\CONTROL02.CTL

&nbsp;

SQL&gt; select member from v$logfile;

MEMBER

\--------------------------------------------------------------------

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\REDO03.LOG

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\REDO02.LOG

E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\REDO01.LOG

###  **3** **、检查所有的表空间信息**

SQL&gt; select con_id,name from v$tablespace order by con_id;

&nbsp;&nbsp;&nbsp; CON_ID NAME

\---------- ----------------------------------------------------------

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1 SYSAUX

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1 SYSTEM

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1 UNDOTBS1

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1 USERS

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1 TEMP

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2 SYSTEM

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2 SYSAUX

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2 UNDOTBS1

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2 TEMP

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 3 SYSTEM

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 3 USERS

&nbsp;

&nbsp;&nbsp;&nbsp; CON_ID NAME

\---------- ----------------------------------------------------------

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 3 TEMP

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 3 UNDOTBS1

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 3 SYSAUX

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 4 TEMP

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 4 UNDOTBS1

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 4 SYSAUX

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 4 SYSTEM

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 4 USERS

&nbsp;

已选择 19 行。

##  **四、PDB数据库的启动和停止**

1、因为默认连接的是CDB,所以必须先指定PDB才可以通过sqlplus来启动和关闭PDB，

具体语法和普通实例一样：

alter session set container=orclpdb1;

STARTUP FORCE;

STARTUP OPEN READ WRITE [RESTRICT];

STARTUP OPEN READ ONLY [RESTRICT];

STARTUP UPGRADE;

SHUTDOWN [IMMEDIATE];

&nbsp;

2、如果在PDB中可以使用如下语法：

ALTER PLUGGABLE DATABASE OPEN READ WRITE [RESTRICTED] [FORCE];

ALTER PLUGGABLE DATABASE OPEN READ ONLY [RESTRICTED] [FORCE];

ALTER PLUGGABLE DATABASE OPEN UPGRADE [RESTRICTED];

ALTER PLUGGABLE DATABASE CLOSE [IMMEDIATE];

&nbsp;

3、如果是在CDB中，可以使用如下语法：

ALTER PLUGGABLE DATABASE &lt;pdd-name-clause&gt; OPEN READ WRITE
[RESTRICTED][FORCE];

ALTER PLUGGABLE DATABASE &lt;pdd-name-clause&gt; OPEN READ ONLY [RESTRICTED]
[FORCE];

ALTER PLUGGABLE DATABASE &lt;pdd-name-clause&gt; OPEN UPGRADE [RESTRICTED];

ALTER PLUGGABLE DATABASE &lt;pdd-name-clause&gt; CLOSE [IMMEDIATE];

&lt;pdd-name-clause&gt;表示的是多个PDB，如果有多个，用逗号分开。 也可以使用ALL或者ALL EXCEPT关键字来替代。

&nbsp;其中：

ALL：表示所有的PDBS。

ALLEXCEPT 表示需要排除的PDBS。

&nbsp;

如：

ALTER PLUGGABLE DATABASE pdb1, pdb2 OPEN READ ONLY FORCE;

ALTER PLUGGABLE DATABASE pdb1, pdb2 CLOSE IMMEDIATE;

ALTER PLUGGABLE DATABASE ALL OPEN;

ALTER PLUGGABLE DATABASE ALL CLOSE IMMEDIATE;

ALTER PLUGGABLE DATABASE ALL EXCEPT pdb1 OPEN;

ALTER PLUGGABLE DATABASE ALL EXCEPT pdb1 CLOSE IMMEDIATE;

##  **五、部分常用命令**

###  **1** **、查看是否为cdb**

SQL&gt; select name,log_mode,open_mode,cdb from v$database;

NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; LOG_MODE&nbsp;&nbsp;&nbsp;
&nbsp;OPEN_MODE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
CDB

\--------- ------------ -------------------- ---

ORCL&nbsp;&nbsp; NOARCHIVELOG READ
WRITE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; YES

###  **& nbsp;** **2** **、查看容器数据库中的pdb**

SQL&gt; col pdb_name for a30

SQL&gt; select pdb_id,pdb_name,dbid,status from dba_pdbs;

&nbsp;&nbsp;&nbsp; PDB_ID
PDB_NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;DBID STATUS

\---------- ------------------------------ ---------- -----------

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 3
ORCLPDB1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
94456717 NORMAL

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2
PDB$SEED&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
3785701224 NORMAL

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 4
ORCLPDB2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1392788411 NORMAL

SQL&gt; select con_id,dbid,name,open_mode from v$pdbs;

&nbsp;&nbsp;&nbsp; CON_ID&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; DBID&nbsp;
NAME&nbsp;&nbsp;&nbsp;&nbsp; OPEN_MODE

\----------------------------------------

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2 3785701224&nbsp;&nbsp;
PDB$SEED&nbsp; READ ONLY

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; 94456717&nbsp;&nbsp;
ORCLPDB1&nbsp; MOUNTED

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 4 1392788411&nbsp;&nbsp;
ORCLPDB2&nbsp; MOUNTED

###  **3** **、启动pdb**

SQL&gt; alter pluggable database ORCLPDB1 open;

插接式数据库已变更。

&nbsp;SQL&gt; select con_id,dbid,name,open_mode from v$pdbs;

&nbsp;&nbsp;&nbsp; CON_ID&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; DBID&nbsp;
NAME&nbsp;&nbsp;&nbsp;&nbsp; OPEN_MODE

\----------------------------------------

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2 3785701224&nbsp;&nbsp;
PDB$SEED&nbsp; READ ONLY

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; 94456717&nbsp;&nbsp;
ORCLPDB1&nbsp; READ WRITE

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 4 1392788411&nbsp;&nbsp;
ORCLPDB2&nbsp; MOUNTED

###  **4** **、查看监听配置详情**

[oracle@oel6 admin]$ cat listener.ora

# listener.ora Network Configuration File:
/u01/app/product/12.1.0/dbname_1/network/admin/listener.ora

# Generated by Oracle configuration tools.

&nbsp;SID_LIST_LISTENER =

&nbsp; (SID_LIST =

&nbsp;&nbsp;&nbsp; (SID_DESC =

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (GLOBAL_DBNAME = orcl)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (ORACLE_HOME =
/u01/app/product/12.1.0/dbname_1)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (SID_NAME = orcl)

&nbsp;&nbsp;&nbsp; )

&nbsp;&nbsp;&nbsp; (SID_DESC =

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (GLOBAL_DBNAME = orclpdb1)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (ORACLE_HOME =
/u01/app/product/12.1.0/dbname_1)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (SID_NAME = orcl)

&nbsp;&nbsp;&nbsp; )

&nbsp; )

&nbsp;

LISTENER =

&nbsp; (DESCRIPTION =

&nbsp;&nbsp;&nbsp; (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.18.145)(PORT =
1521))

&nbsp; )

&nbsp;

ADR_BASE_LISTENER = /u01/app

&nbsp;

[oracle@oel6 admin]$ cat tnsnames.ora

# tnsnames.ora Network Configuration File:
/u01/app/product/12.1.0/dbname_1/network/admin/tnsnames.ora

# Generated by Oracle configuration tools.

&nbsp;

ORCL =

&nbsp; (DESCRIPTION =

&nbsp;&nbsp;&nbsp; (ADDRESS_LIST =

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (ADDRESS = (PROTOCOL = TCP)(HOST =
192.168.18.145)(PORT = 1521))

&nbsp;&nbsp;&nbsp; )

&nbsp;&nbsp;&nbsp; (CONNECT_DATA =

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (SERVICE_NAME = orcl)

&nbsp;&nbsp;&nbsp; )

&nbsp; )

&nbsp;

&nbsp;

orclpdb1 =

&nbsp; (DESCRIPTION =

&nbsp;&nbsp;&nbsp; (ADDRESS_LIST =

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (ADDRESS = (PROTOCOL = TCP)(HOST =
192.168.18.145)(PORT = 1521))

&nbsp;&nbsp;&nbsp; )

&nbsp;&nbsp;&nbsp; (CONNECT_DATA =

&nbsp;&nbsp;&nbsp; (SID=guard6)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (SERVICE_NAME = orclpdb1)

&nbsp;&nbsp;&nbsp; )

&nbsp; )

###  **5** **、连接到pdb数据库**

C:\Users\user&gt;sqlplus sys/********@orclpdb1 as sysdba

&nbsp;SQL*Plus: Release 11.2.0.1.0 Production on Wed Dec 10 16:38:35 2014

&nbsp;Copyright (c) 1982, 2010, Oracle.&nbsp; All rights reserved.

&nbsp;Connected to:

Oracle Database 12c Enterprise Edition Release 12.2.0.1.0 - 64bit Production

With the Partitioning, Oracle Label Security, OLAP, Advanced Analytics

and Real Application Testing options

&nbsp;SQL&gt; select name from v$pdbs;

&nbsp;NAME

\------------------------------

ORCLPDB1

###  **6** **、连接到cdb**

&nbsp;C:\Users\user&gt;sqlplus sys/********@orcl as sysdba

&nbsp;SQL*Plus: Release 11.2.0.1.0 Production on Wed Dec 10 16:40:37 2014

&nbsp;Copyright (c) 1982, 2010, Oracle.&nbsp; All rights reserved.

&nbsp;Connected to:

Oracle Database 12c Enterprise Edition Release 12.2.0.1.0 - 64bit Production

With the Partitioning, Oracle Label Security, OLAP, Advanced Analytics

and Real Application Testing options

&nbsp;SQL&gt; select name from v$pdbs;

NAME

\----------------------------------

PDB$SEED

ORCLPDB1

ORCLPDB2

###  **7** **、从cdb切换到pdb**

SQL&gt; alter session set container=orclpdb1;

&nbsp;Session altered.

&nbsp;SQL&gt; select name from v$pdbs;

&nbsp;NAME

\------------------------------

ORCLPDB1

##  **六、开启inmemory**

###  **1** **、检查确认未开启**

SQL&gt; col value for a20

SQL&gt; col name for a40

SQL&gt; select name,value from v$parameter where name like &#39;%inm%&#39;;

NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
VALUE

\---------------------------------------- --------------------

 **inmemory_size
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
0**

inmemory_clause_default

inmemory_force&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
DEFAULT

inmemory_query&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ENABLE

inmemory_max_populate_servers&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
0

inmemory_trickle_repopulate_servers_perc 1

ent

optimizer_inmemory_aware&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
TRUE

&nbsp;7 rows selected.

&nbsp;

SQL&gt; show sga

Total System Global Area 1694498816 bytes

Fixed
Size&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
2925168 bytes

Variable
Size&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
452988304 bytes

Database Buffers&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1224736768
bytes

Redo
Buffers&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
13848576 bytes

###  **2** **、设置in内存大小**

SQL&gt; alter system set inmemory_size=600m scope=spfile;

System altered.

###  **3** **、设置加载到内存的进程数量**

SQL&gt; alter system set inmemory_max_populate_servers=2 scope=both;

System altered.

###  **& nbsp;** **4** **、启动数据库验证已开启**

SQL&gt; startup

ORACLE instance started.

&nbsp;Total System Global Area 1694498816 bytes

Fixed
Size&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;2925168 bytes

Variable
Size&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
503319952 bytes

Database Buffers&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
536870912 bytes

Redo
Buffers&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
13848576 bytes

In-Memory
Area&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
637534208 bytes

Database mounted.

Database opened.

##  **七、用户和角色**

在Oracle12C中，用户权限的管理相对传统的 Oracle 单数据库环境稍有不同。在多租户环境中有两种类型的用户。

①：共同用户（Common User）： 该用户存在所有容器 （根和所有的 Pdb） 中。

②：本地用户（Local User）： 用户只有在特定的 PDB 中存在。同样的用户名中可以存在多个Pdb中创建，但它们之间没有关系。

同样，有两种类型的角色：如

①：共同角色（Common Role）： 该角色在所有容器 （根和所有的 Pdb） 中。

②：本地角色（Local Role）： 该角色只存在于特定的 PDB。可以在多个 Pdb中创建相同的角色名称，但它们之间没有关系。

一些 DDL 语句有扩充，以使他们能够定向到当前容器还是所有容器的CONTAINER子句。它的使用将在以下各节中进行演示。

注意：

&nbsp;&nbsp; 在 cdb 中创建公共用户的时候， pdbs 中也会创建相同用户。若CDB 下 GRANT
命令赋权，如果赋权时未指定container=all，则赋权只在CDB中生效，并不会在PDB中生效,这个用户要能够访问PDB，需要切换到 pdb
再赋权。。若赋权时指定 container=all，则赋权在CDB中生效，也在PDB中生效。

###  **1** **、在CDB中，给用户赋权时未指定container=all**

SQL&gt; show con_name;

CON_NAME

\------------------------------

CDB$ROOT

&nbsp;

SQL&gt; create user c##zhang identified by zhang;

SQL&gt; grant create session to c##zhang;&nbsp;
--赋权给用户，这个时候开启另一个窗口使用该用户登录pdb的时候是没有权限的，如下：

&nbsp;

[oracle@localhost ~]$ sqlplus c##zhang/zhang@192.168.2.100/testpdb

SQL*Plus: Release 12.2.0.1.0 Production on Tue Jul 18 15:15:51 2017

Copyright (c) 1982, 2016, Oracle.&nbsp; All rights reserved.

ERROR:

ORA-01045: user C##ZHANG lacks CREATE SESSION privilege; logon denied

&nbsp;

\----切换到pdb中，给用户赋权就可以登录了：

SQL&gt; alter session set container=testpdb;

SQL&gt; grant create session to c##zhang;

&nbsp;

###  **2** **、在CDB中，给用户赋权时指定container=all**

SQL&gt; create user c##zhang1 identified by zhang;

SQL&gt; grant create session to c##zhang1 container=all;

&nbsp;

###  **3** **、创建公共角色**

SQL&gt; show con_name

CON_NAME

\------------------------------

CDB$ROOT&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

&nbsp;

SQL&gt; create role c##role;&nbsp;&nbsp; ---创建角色

SQL&gt; grant select on dba_objects to c##role container=all;&nbsp; --给这个角色加权限

SQL&gt; grant c##role to c##zhang1 container=all;&nbsp; --将角色赋给公共用户

SQL&gt; alter session set container=testpdb;&nbsp; ---切换到pdb

SQL&gt; grant c##role to admin;&nbsp;&nbsp; ---也可以把这个角色赋予pdb中的本地用户

&nbsp;

###  **4** **、本地角色**

&nbsp; 本地角色是以类似的方式到 pre-12 c 数据库创建的。每个 PDB 可以具有与匹配的名称，因为当地的作用范围仅限于当前 PDB 的角色。

必须满足以下条件。

①：必须连接到具有CREATE ROLE权限的用户。

②：如果您连接到公共用户，容器必须设置为本地 PDB。

③：角色名称为本地角色不必须与&quot;C##&quot;或&quot;c##&quot;作为前缀。

④：角色名称必须是唯一在 PDB 内。

⑤：本地角色可以赋权给公共用户（作用范围局限于pdb内操作，不影响CDB权限）或者本地用户。如：

&nbsp;

SQL&gt; show con_name;

CON_NAME

\------------------------------

TESTPDB

&nbsp;

SQL&gt; create role pdb_role;&nbsp;&nbsp;&nbsp; ---创建角色

SQL&gt; grant select on dba_tables to pdb_role;&nbsp; --给角色加权限

SQL&gt; grant pdb_role to c##zhang;&nbsp; --将角色赋予公共用户

SQL&gt; grant pdb_role to admin;&nbsp;&nbsp; ---将角色赋予本地用户

&nbsp;

##  **八、创建和删除PDB**

&nbsp;

使用CREATE PLUGGABLE DATABASE可以从SEED来创建一个PDB。当前的容器必须是CDB root。

SYS@testdb&gt; show con_name

CON_NAME

\------------------------------

CDB$ROOT

&nbsp;

SYS@testdb&gt; CREATE PLUGGABLE DATABASE test_pdb ADMIN USER testadm
IDENTIFIED BY &quot;rF&quot; ROLES=(CONNECT)
file_name_convert=(‘/data/oradata/testdb/pdbseed‘,‘/data/oradata/testdb/test_pdb‘)
path_prefix=‘/data/oradata/testdb/test_pdb‘;

Pluggable database created.

&nbsp;

SYS@testdb&gt; show pdbs

&nbsp;&nbsp;&nbsp; CON_ID CON_NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;OPEN
MODE&nbsp; RESTRICTED

\---------- ------------------------------ ---------- ----------

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2
PDB$SEED&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
READ ONLY&nbsp; NO

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 3
TEST_PDB&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
MOUNTED

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;

使用DROP PLUGGABLE DATABASE来删除PDB

drop pluggable database test_pdb including datafiles;

##  **九、数据文件重命名与迁移**

###  **1** **、重命名数据文件**

SQL&gt; ALTER DATABASE MOVE DATAFILE &#39;/u01/data/users01.dbf&#39; TO
&#39;/u01/data/users_02.dbf&#39;;

###  **2** **、从非ASM存储迁移数据文件到ASM**

SQL&gt; ALTER DATABASE MOVE DATAFILE &#39;/u01/data/users_01.dbf&#39; TO
&#39;+DG_DATA&#39;;

数据文件从一个ASM磁盘组迁移到另一个：

SQL&gt; ALTER DATABASE MOVE DATAFILE &#39;+DG_DATA/users_01.dbf&#39; TO
&#39;+DG_DATA_02&#39;;

###  **3** **、如果数据文件在新位置也存在，则覆盖同名的数据文件**

SQL&gt; ALTER DATABASE MOVE DATAFILE &#39;/u01/data/users_01.dbf&#39; TO
&#39;/u02/data_new/users_01.dbf&#39; REUSE;

###  **4** **、数据文件拷贝到新位置，旧位置保留旧的拷贝**

SQL&gt; ALTER DATABASE MOVE DATAFILE &#39;/u00/data/users_01.dbf&#39; TO
&#39;/u01/data_new/users_01.dbf&#39; KEEP;

通过查询动态视图v$session_longops，你可以监控数据文件移动的进程。另外，也可以参考数据库的alert.log，因为，Oracle会把正在进行的操作的详细信息写入该日志中。

&nbsp;

###  **其他注意事项**

当执行如下命令后，会生成SYSTEM02.DBF文件，且SYSTEM01.DBF文件不会被删除：

SQL&gt; alter database move datafile
&#39;E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\SYSTEM01.DBF&#39; to
&#39;E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\SYSTEM02.DBF&#39;;

数据库已更改。

&nbsp;

当执行如下命令后，SYSTEM02.DBF文件会被删除：

SQL&gt; alter database move datafile
&#39;E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\SYSTEM02.DBF&#39; to
&#39;E:\APP12C\ADMINISTRATOR\VIRTUAL\ORADATA\ORCL\SYSTEM01.DBF&#39; reu

se;

数据库已更改。

##  **十、CDB/PDB用户的创建与对象管理**

在Oracle
12C中，账号分为两种，一种是公用账号，一种是本地账号（亦可理解为私有账号）。共有账号是指在CDB下创建，并在全部PDB中生效的账号，另一种是在PDB中创建的账号。

针对这两种账号的测试如下：

###  **1** **、在PDB中创建测试账号**

&nbsp;SQL&gt; alter session set container=pdb01;

Session altered.

&nbsp;SQL&gt; select username from dba_users where username like
&#39;GUI%&#39;;

no rows selected

&nbsp;SQL&gt; CREATE USER TEST IDENTIFIED BY test;

User created.

&nbsp;

SQL&gt; grant dba to test;

Grant succeeded.

&nbsp;

SQL&gt; show con_name

CON_NAME

\------------------------------

PDB01

&nbsp;

SQL&gt; conn /as sysdba

Connected.

SQL&gt; create user test identified by test;

create user test identified by test

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; *

ERROR at line 1:

ORA-65096: invalid common user or role name

SQL&gt; show con_name

&nbsp;CON_NAME

\------------------------------

CDB$ROOT

 **结论：**

如果在PDB中已经存在一个用户或者角色，则在CDB中不能创建相同的账号或者角色名。

###  **2** **、在CDB中创建测试账号**

SQL&gt; show con_name

&nbsp;CON_NAME

\------------------------------

CDB$ROOT

SQL&gt; create user C##GUIJIAN IDENTIFIED BY guijian;&nbsp;&nbsp;
------注意CDB中创建用户一定要带上c##

User created.

SQL&gt; create user c#gui identified by gui;

create user c#gui identified by gui

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; *

ERROR at line 1:

ORA-65096: invalid common user or role name

&nbsp;

SQL&gt; select username from dba_users where username like &#39;%GUI%&#39;;

&nbsp;USERNAME

\------------------------------------------------------------------------------

C##GUIJIAN

&nbsp;

SQL&gt; ALTER SESSION SET CONTAINER=PDB01;

&nbsp;

Session altered.

&nbsp;

SQL&gt; select username from dba_users where username like &#39;%GUI%&#39;;

&nbsp;USERNAME

\------------------------------------------------------------------------------

C##GUIJIAN

&nbsp;

SQL&gt; create user guijian identified by guijian;

&nbsp;User created.

同样在CDB中创建账号后不能在PDB中出现同名的账号，因CDB中的账号对所有的PDB都是有效的。

SQL&gt; create user c##guijian identified by guijian;

create user c##guijian identified by guijian

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; *

ERROR at line 1:

ORA-65094: invalid local user or role name

SQL&gt; alter session set container=pdba;

&nbsp;Session altered.

&nbsp;

SQL&gt; show user

USER is &quot;SYS&quot;

SQL&gt; alter user sys identified by sys;

alter user sys identified by sys

*

ERROR at line 1:

ORA-65066: The specified changes must apply to all containers

&nbsp;

SQL&gt; show con_name

&nbsp;CON_NAME

\------------------------------

PDBA

&nbsp;

SQL&gt; conn /as sysdba

Connected.

SQL&gt; show con_name

&nbsp;

CON_NAME

\------------------------------

CDB$ROOT

SQL&gt; alter user sys identified by sys;

&nbsp;User altered.

&nbsp;

SQL&gt;

&nbsp; **3** **、CDB下创建账号的权限问题**

SQL&gt; conn / as sysdba

Connected.

SQL&gt; grant connect,create session to c##cdb;

&nbsp;Grant succeeded.

&nbsp;

SQL&gt; conn c##cdb/cdb@pdba

ERROR:

ORA-01045: user C##CDB lacks CREATE SESSION privilege; logon denied

&nbsp;Warning: You are no longer connected to ORACLE.

&nbsp;

SQL&gt; conn / as sysdba

Connected.

SQL&gt; alter session set container=pdba;

&nbsp;Session altered.

&nbsp;

SQL&gt; grant resource,connect to c##cdb;

&nbsp;Grant succeeded.

&nbsp;

SQL&gt; conn&nbsp; /as sysdba

Connected.

SQL&gt; conn c##cdb/cdb@pdba

Connected.

SQL&gt; conn / as sysdba

Connected.

SQL&gt; create user guijian identified by guijian container=current;

create user guijian identified by guijian container=current

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
*

ERROR at line 1:

ORA-65049: creation of local user or role is not allowed in CDB$ROOT

&nbsp;

SQL&gt; create user c##guijian identified by guijian container=current;

create user c##guijian identified by guijian container=current

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; *

ERROR at line 1:

ORA-65094: invalid local user or role name

&nbsp;

SQL&gt; show con_name

CON_NAME

\------------------------------

CDB$ROOT

SQL&gt; create user c##guijian identified by guijian container=all;

User created.

&nbsp;

SQL&gt; create user c##guijian01 identified by guijian;

User created.

&nbsp;

SQL&gt; create user test identified by test;

create user test identified by test

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; *

第 1 行出现错误:

ORA-65096: 公用用户名或角色名无效

&nbsp;

SQL&gt; create user c##test identified by test;

用户已创建。

##  **十一、12C参数修改效果说明**

在cdb中修改参数,会默认所有pdb均自动继承;如果在pdb中修改值会覆盖cdb参数,而且只对当前pdb生效,并记录在PDB_SPFILE$。

pdb中不同于root的参数是记录在root的PDB_SPFILE$基表中.

整个CDB的工作原理是如果在PDB_SPFILE$中无相关参数记录,则继承cdb的参数文件中值,如果PDB_SPFILE$中有记录则使用该值覆盖cdb参数文件值.

  

" name="docDetail" type="hidden">


---
### ATTACHMENTS
[7f025a17697ee15eb3197c61326b203b]: media/Oracle-指导手册-Oracle_12C_常用管理命令及知识点.html
[Oracle-指导手册-Oracle_12C_常用管理命令及知识点.html](media/Oracle-指导手册-Oracle_12C_常用管理命令及知识点.html)
>hash: 7f025a17697ee15eb3197c61326b203b  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-指导手册-Oracle 12C 常用管理命令及知识点_files\11947ec6e06f4dd6a765bcc48c4fc88d.png  

---
### NOTE ATTRIBUTES
>Created Date: 2018-09-25 03:29:36  
>Last Evernote Update Date: 2018-10-01 15:33:47  
>author: YangKwong  
>source: desktop.win  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-指导手册-Oracle 12C 常用管理命令及知识点.html  
>source-application: evernote.win32  