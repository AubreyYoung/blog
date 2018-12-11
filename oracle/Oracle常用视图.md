# Oracle常用视图

## 数据字典的分类

1. 静态数据字典表
2. 静态数据字典视图 
3. 动态数据字典表
4. 动态数据字典视图

## 数据字典的使用

1. 静态数据字典表的使用

静态数据字典表只能由 ORACLE 进行维护。

2. 静态数据字典视图的使用

通常用户通过对静态数据字典视图的查询可以获取所需要的所有数据库信息。

**Oracle 静态数据字典分类**

名称前缀              含义
user_ 	           包含了当前数据库用户所拥有的所有的模式对象的信息
all_ 		  包含了当前数据库用户可以访问的所有的模式对象的信息dba_             包含了所有数据库对象信息，只有具有 DBA 角色的用户才能而过访

**问的这些视图** 

例如：select * from dba_tablesselect  * from all_tablesselect   * from user_tables;

注： dba_ 开头的 必须是 sys 用户所有 ，非 sys 用户 需要在前面加 sys 前缀

下面都是一些常用的视图家族，都有一个 DBA_ ALL_ USER_ 的视图

## **常用的视图家族**

```
col_privs   包含了表的列权限信息，包含授予者，被授予者和权限名称等信息， 
extents     存储分配信息，包括数据段名 表空间名和分区编号，分区大小 
indexes    索引信息  包含索引类型， 唯一性， 索引作用等表的信息 
ind_columns   索引列信息  包括索引上的列的排序方式等信息 
object      对象信息， 包括对象名称 类型  创建时间 等信息 
segments  表和索引的数据段信息，包括表空间，存储设置等信息 
sequences   序列信息 包含序列名称 ，循环性，最大值等信息 
source    除触发器之外的所有存储过程，函数，包的源代码信息  
synonyms 同义词信息   包括引用的对象等信息 
sys_privs   系统权限信息 包括系统权限名称 授予者 
tab_columns   表和视图的列信息 ，包括列的数据类型等信息  
tab_privs  表权限信息  
tables  表信息 包括表所属的表空间 ，存储参数 ，数据行数量等信息。 
triggers   触发器信息 包括触发器的类型，事件。触发器体等信息 
users 用户信息 。包括用户临时和默认的表空间的类型 
views   视图 信息  
```

**权限视图** 

```
role_sys_privs  角色拥有的系统权限视图
role_tab_privs  角色拥有的对象权限
user_role _ privs  用户拥有的角色 
user_sys_privs   用户拥有的权限的角色
user_tab_privs_mads    用户分配的关于表对象权限
user_tab_privs_recd  用户拥有的关于表对象权限
user_col_privs_mads  用户分配的关于列的对象权限
user_col_privs_recd  用户拥有的关于列的对象权限 
```

3.  动态性能表是数据库实例启动后 创建的表

动态性能表都数据 SYS 用户； 用于存放数据库在运行的过程中的性能相关的信息。

通过以下的视图查看

select name from  v_$fixed_table;

4. 动态性能视图的使用

只有 sys 用户和拥有 DBA 角色的用户可以访问 。

在数据库启动到 NOMOUNT 的状态时 可以访问 v$ parameter v$sga  v$session v$process v$instance v$version v$option 

当数据库启动到 mount 的状态时 我们还可以访问 v$ log v$logfiel v$datafile v$controlfile  v$ database v$thread  v$datafile_header

当数据库完全启动后。可以访问 v_$fixed_table

**动态性能视图的使用**

```
v$access   包含当前被锁定的数据库对象及正在访问他们的会话
v$archive  包含归档所需的重做日志文件中的信息
v$ archived_log   包含从控制文件中获取的归档日志信息。
v$archive_processes  包含于一个实例相关的 arch 进程的状态信息 
v$ backup   包含联机数据文件的备份状态信息 
v$backup_async_io   包括从控制文件中获取的备份集的信息 
v$ backup_corruption   包含从控制文件中获取的有关数据文件备份中损坏的信息。
v$ backup_datafile   包含从控制文件中获取的备份的数据文件和备份控制文件的信息
v$ backup_device   包含支持备份设备的信息
v$backup_piece     包含从控制文件中获取的备份块的信息
v$backup_redolog    包含从控制文件中获取的关于备份集的归档日志的信息
v$backup_set    包含从控制文件中获取的备份集的信息
v$bgprocess 包含数据库后台进程信息
v$ buffer_pool   包含当前实例中所有可用缓冲池的信息
v$ buffer_pool_statistics  包含当前实例所有可用缓冲池的统计信息
v$ cache   包含当前实例的 SGA 中的每一块的头部信息
v$context   包含当前对话的属性信息。
v$controlfile   包含控制文件信息
v$ controlfile_record_section   包含控制文件记录部分的信息
v$ copy_curruption 包含从控制问价中获取的数据文件副本损坏的信息 
v$database  包含从控制文件中获取的数据库信息 
v$datafile   包含从控制文件中获取的数据文件信息
v$datafile_copy  包括从控制文件中获取的数据文件副本的信息
v$datafile_header  包含数据文件头部信息
v$ db_object_cache  包含缓存在库高速缓冲中的数据库对象信息
v$db_pipes   包含当前数据库中的管道信息
v$deleted_object   包含从控制文件中获取的被删除的归档日志，数据文件副本和备份块的信息
v$ dispatcher_rate   包含调度进程速率统计量的信息
v$ dispatche   包含调度进程的信息
v$ DLM_ALL_LOCKS  包含当前所有锁
v$ DLM_CONVERT_LOCAL   包含本地锁转换操作所消耗的时间的信息 
v$ EVENT_NAME   包含等待时间的信息
v$ fixed_table   包含所有可用的动态性能视图和动态性能表的信息 
v$ sysstat   包含当前实例的性能统计信息
v$ instance  包含当前实例的详细信息 
v$sga  包含 SGA 区的主要组成部分的信息 
v$ sgainfo   包含 SGA 区的详细消息 
v$ parameter 包含初始化参数信息 
v$ sversion   包含 Oracle 版本信息 
v$ option  包含已安装的 Oraclette 组件的选项信息 
v$session   包含当前所有会话信息 
v$process   包含当前系统所有进程信息 
v$ bgprocess  包含数据库所有后台进程信息 
v$ database  包含当前数据库信息
v$ controlfile  包含当前数据库所有控制文件信息
v$ datafile   包含当前数据库所有的数据文件的信息
v$ dbfile   包含所有数据文件的编号信息 
v$ logfile   包含当前数据库所有的重做日志文件信息
v$ log  包含当前数据库重做日志文件信息 
v$ log_history  包含重做日志文件切换情况的历史信息
v$ thread  包含当前数据库线程的信息
v$ lock 包含锁的信息 
v$ locked_object   包含被加锁的数据库对象信息 
v$ rollname 包含当前处于联机状态的回退信息 
v$ rollstat    包含当前所有的回退段的统计信息 
v$ tablespace  包含当前数据库所有表空间信息
v$ tempfile   包含当前数据库多有的临时数据文件的信息 ； 

常用的数据字典

    dba_data_files:通常用来查询关于数据库文件的信息
    dba_db_links:包括数据库中的所有数据库链路，也就是databaselinks。
    dba_extents:数据库中所有分区的信息
    dba_free_space:所有表空间中的剩余空间
    dba_indexs:关于数据库中所有索引的描述
    dba_ind_columns:在所有表及聚集上索引的列
    dba_objects:数据库中所有的对象
    dba_rollback_segs:回滚段的描述
    dba_segments:所有数据库段信息
    dba_synonyms:关于同义词的信息
    dba_tables:数据库中所有数据表的描述
    dba_tabespaces:关于表空间的信息
    dba_tab_columns:所有表描述、视图以及聚集的列
    dba_tab_grants/privs:对象所授予的权限
    dba_ts_quotas:所有用户表空间限额
    dba_users:关于数据的所有用户的信息
    dba_views:数据库中所有视图的文本
    10 常用的动态性能视图：
    v$datafile：数据库使用的数据文件信息
    v$librarycache：共享池中SQL语句的管理信息
    v$lock：通过访问数据库会话，设置对象锁的所有信息
    v$log：从控制文件中提取有关重做日志组的信息
    v$logfile有关实例重置日志组文件名及其位置的信息
    v$parameter：初始化参数文件中所有项的值
    v$process：当前进程的信息
    v$rollname：回滚段信息
    v$rollstat：联机回滚段统计信息
    v$rowcache：内存中数据字典活动/性能信息
    v$session:有关会话的信息
    v$sesstat：在v$session中报告当前会话的统计信息
    v$sqlarea：共享池中使用当前光标的统计信息，光标是一块内存区域，有Oracle处理SQL语句时打开。
    v$statname：在v$sesstat中报告各个统计的含义
    v$sysstat：基于当前操作会话进行的系统统计
    v$waitstat：出现一个以上会话访问数据库的数据时的详细情况。当有一个以上的会话访问同一信息时，可出现等待情况。



```

## Oracle常用数据字典表

```
//查看当前用户的缺省表空间
select username,default_tablespace from user_users; 
//查看当前用户的角色
select * from user_role_privs;
//查看当前用户的系统权限和表级权限
select * from user_sys_privs;
select * from user_tab_privs;
//查看用户下所有的表
select * from user_tables;
select * from tab;
//查看用户下所有的表的列属性
select * from USER_TAB_COLUMNS where table_name='table_name';
desc table_name
//显示用户信息(所属表空间)
select default_tablespace, temporary_tablespace from dba_users where username= 'GAME';
//显示当前会话所具有的权限
select * from session_privs;
//显示指定用户所具有的系统权限
select * from dba_sys_privs where grantee='GAME';
//显示特权用户
select * from v$pwfile_users;
//显示用户的PROFILE
select profile from dba_users where username='GAME';
```
## 表
```
//查看名称包含log字符的表
select object_name,object_id from user_objects where instr(object_name,'LOG')>0;
select object_name,object_id from user_objects where object_name like '%LOG%';
//查看某表的创建时间
select object_name,created from user_objects where object_name=upper('&table_name');
//查看某表的大小
select sum(bytes)/(1024*1024) as "size(M)" from user_segments where segment_name=upper('&table_name');
//查看放在Oracle的内存区里的表
select table_name,cache from user_tables where instr(cache,'Y')>0;
```
## 索引
```
//查看索引个数和类别
select index_name,index_type,table_name from user_indexes order by table_name;
//查看索引被索引的字段
select * from user_ind_columns where index_name=upper('&index_name');
//查看索引的大小
select sum(bytes)/(1024*1024) as "size(M)" from user_segments where segment_name=upper('&index_name');
```
## 序列
```
//查看序列号，last_number是当前值
select * from user_sequences;
```
## 视图
```
//查看视图的名称
select view_name from user_views;
//查看创建视图的select语句
set view_name,text_length from user_views;
说明：可以根据视图的text_length值设定set long 的大小
set long 2000; 
select text from user_views where view_name=upper('&view_name');
```
## 同义词
```
//查看同义词的名称
select * from user_synonyms;
```
##  约束条件
```
//查看某表的约束条件
select constraint_name, constraint_type,search_condition, r_constraint_name from user_constraints where table_name = upper('&table_name');

select c.constraint_name,c.constraint_type,cc.column_name from user_constraints c,user_cons_columns cc where c.owner = upper('&table_owner') and c.table_name = upper('&table_name')  and c.owner = cc.owner and c.constraint_name = cc.constraint_name order by cc.position;
```
## 存储函数和过程
```
//查看函数和过程的状态
select object_name,status from user_objects where object_type='FUNCTION';
select object_name,status from user_objects where object_type='PROCEDURE';
//查看函数和过程的源代码
select text from all_source where owner=user and name=upper('&plsql_name');
```


## 常用查询

```
//查看回滚段名称及大小
//查看回滚段名称及大小
select segment_name, tablespace_name, r.status, 
(initial_extent/1024) InitialExtent,(next_extent/1024) NextExtent, 
max_extents, v.curext CurExtent
From dba_rollback_segs r, v$rollstat v
Where r.segment_id = v.usn(+)
order by segment_name;
//查看数据库库对象
select owner, object_type, status, count(*) count# from all_objects group by owner, object_type, status;

//查看数据表的参数信息
SELECT partition_name,
       high_value,
       high_value_length,
       tablespace_name,
       pct_free,
       pct_used,
       ini_trans,
       max_trans,
       initial_extent,
       next_extent,
       min_extent,
       max_extent,
       pct_increase,
       FREELISTS,
       freelist_groups,
       LOGGING,
       BUFFER_POOL,
       num_rows,
       blocks,
       empty_blocks,
       avg_space,
       chain_cnt,
       avg_row_len,
       sample_size,
       last_analyzed
  FROM dba_tab_partitions
 WHERE table_name = 'upper(&tname)'
   AND table_owner = 'upper(&towner)'
 ORDER BY partition_position
//查看还没提交的事务
select * from v$locked_object;
select * from v$transaction;

//回滚段查看
select rownum,
       sys.dba_rollback_segs.segment_name Name,
       v$rollstat.extents                 Extents,
       v$rollstat.rssize                  Size_in_Bytes,
       v$rollstat.xacts                   XActs,
       v$rollstat.gets                    Gets,
       v$rollstat.waits                   Waits,
       v$rollstat.writes                  Writes,
       sys.dba_rollback_segs.status       status
  from v$rollstat, sys.dba_rollback_segs, v$rollname
 where v$rollname.name(+) = sys.dba_rollback_segs.segment_name
   and v$rollstat.usn(+) = v$rollname.usn
 order by rownum

//查看sga情况
SELECT NAME, BYTES/1024/1024 MB FROM SYS.V_$SGASTAT ORDER BY NAME ASC

//查看catched object
SELECT owner,
       name,
       db_link,
       namespace,
       type,
       sharable_mem,
       loads,
       executions,
       locks,
       pins,
       kept
  FROM v$db_object_cache

//查看V$SQLAREA
SELECT SQL_TEXT,
       SHARABLE_MEM,
       PERSISTENT_MEM,
       RUNTIME_MEM,
       SORTS,
       VERSION_COUNT,
       LOADED_VERSIONS,
       OPEN_VERSIONS,
       USERS_OPENING,
       EXECUTIONS,
       USERS_EXECUTING,
       LOADS,
       FIRST_LOAD_TIME,
       INVALIDATIONS,
       PARSE_CALLS,
       DISK_READS,
       BUFFER_GETS,
       ROWS_PROCESSED
  FROM V$SQLAREA

//查看object分类数量
select decode(o.type#,
              1,
              'INDEX',
              2,
              'TABLE',
              3,
              'CLUSTER',
              4,
              'VIEW',
              5,
              'SYNONYM',
              6,
              'SEQUENCE',
              'OTHER') object_type,
       count(*) quantity
  from sys.obj$ o
 where o.type# > 1
 group by decode(o.type#,
                 1,
                 'INDEX',
                 2,
                 'TABLE',
                 3,
                 'CLUSTER',
                 4,
                 'VIEW',
                 5,
                 'SYNONYM',
                 6,
                 'SEQUENCE',
                 'OTHER')
union
select 'COLUMN', count(*)
  from sys.col$
union
select 'DB LINK', count(*)
  from dba_objects;

//按用户查看object种类  ----运行报错
select u.name schema,
       sum(decode(o.type#, 1, 1, NULL)) indexes,
       sum(decode(o.type#, 2, 1, NULL)) tables,
       sum(decode(o.type#, 3, 1, NULL)) clusters,
       sum(decode(o.type#, 4, 1, NULL)) views,
       sum(decode(o.type#, 5, 1, NULL)) synonyms,
       sum(decode(o.type#, 6, 1, NULL)) sequences,
       sum(decode(o.type#,
                  1,
                  NULL,
                  2,
                  NULL,
                  3,
                  NULL,
                  4,
                  NULL,
                  5,
                  NULL,
                  6,
                  NULL,
                  1)) others
  from sys.obj$ o, sys.user$ u
 where o.type# >= 1
   and u.user# = o.owner#
   and u.name <> 'PUBLIC'
 group by u.name
 order by sys.link$
union 
select 'CONSTRAINT', count(*)
  from sys.con$
 
//查询有哪些数据库实例在运行
select inst_name from v$active_instances;
```

## 查看连接用户操作

```
1）查看有哪些用户连接
select s.osuser os_user_name,
       decode(sign(48 - command),
              1,
              to_char(command),
              'Action Code #' || to_char(command)) action,
       p.program oracle_process,
       status session_status,
       s.terminal terminal,
       s.program program,
       s.username user_name,
       s.fixed_table_sequence activity_meter,
       '' query,
       0 memory,
       0 max_memory,
       0 cpu_usage,
       s.sid,
       s.serial# serial_num
  from v$session s, v$process p
 where s.paddr = p.addr
   and s.type = 'USER'
 order by s.username, s.osuser

2）根据v.sid查看对应连接的资源占用等情况
select n.name, v.value, n.class, n.statistic#
  from v$statname n, v$sesstat v
 where v.sid = 176
   and v.statistic# = n.statistic#
 order by n.class, n.statistic#

3）根据sid查看对应连接正在运行的sql
select /*+ PUSH_SUBQ */
 command_type,
 sql_text,
 sharable_mem,
 persistent_mem,
 runtime_mem,
 sorts,
 version_count,
 loaded_versions,
 open_versions,
 users_opening,
 executions,
 users_executing,
 loads,
 first_load_time,
 invalidations,
 parse_calls,
 disk_reads,
 buffer_gets,
 rows_processed,
 sysdate start_time,
 sysdate finish_time,
 '>' || address sql_address,
 'N' status
  from v$sqlarea
 where address = (select sql_address from v$session where sid = 176)
```

## 耗资源的进程（top session）
```
select s.schemaname schema_name,
       decode(sign(48 - command),
              1,
              to_char(command),
              'Action Code #' || to_char(command)) action,
       status session_status,
       s.osuser os_user_name,
       s.sid,
       p.spid,
       s.serial# serial_num,
       nvl(s.username, '[Oracle process]') user_name,
       s.terminal terminal,
       s.program program,
       st.value criteria_value
  from v$sesstat st, v$session s, v$process p
 where st.sid = s.sid
   and st.statistic# = to_number('38')
   and ('ALL' = 'ALL' or s.status = 'ALL')
   and p.addr = s.paddr
 order by st.value desc, p.spid asc, s.username asc, s.osuser asc
```

//捕捉运行很久的SQL
column username format a12 
column opname format a16 
column progress format a8 
select username,
​       sid,
​       opname,
​       round(sofar * 100 / totalwork, 0) || '%' as progress,
​       time_remaining,
​       sql_text
  from v$session_longops, v$sql
 where time_remaining <> 0
   and sql_address = address
   and sql_hash_value = hash_value;

## 查询表空间的碎片程度 
select tablespace_name,count(tablespace_name) from dba_free_space group by tablespace_name having count(tablespace_name)>10; 

alter tablespace name coalesce; 
alter table name deallocate unused; 
create or replace view ts_blocks_v as 
select tablespace_name,block_id,bytes,blocks,'free space' segment_name from dba_free_space 
union all 
select tablespace_name,block_id,bytes,blocks,segment_name from dba_extents; 
select * from ts_blocks_v; 
select tablespace_name,sum(bytes),max(bytes),count(block_id) from dba_free_space 
group by tablespace_name;

## 查找object为哪些进程所用
select p.spid,
​       s.sid,
​       s.serial# serial_num,
​       s.username user_name,
​       a.type object_type,
​       s.osuser os_user_name,
​       a.owner,
​       a.object object_name,
​       decode(sign(48 - command),
​              1,
​              to_char(command),
​              'Action Code #' || to_char(command)) action,
​       p.program oracle_process,
​       s.terminal terminal,
​       s.program program,
​       s.status session_status
  from v$session s, v$access a, v$process p
 where s.paddr = p.addr
   and s.type = 'USER'
   and a.sid = s.sid
   and a.object = 'SUBSCRIBER_ATTR'
 order by s.username, s.osuser;

## 查看锁（lock）情况
```
select /*+ RULE */
 ls.osuser os_user_name,
 ls.username user_name,
 decode(ls.type,
        'RW',
        'Row wait enqueue lock',
        'TM',
        'DML enqueue lock',
        'TX',
        'Transaction enqueue lock',
        'UL',
        'User supplied lock') lock_type,
 o.object_name object,
 decode(ls.lmode,
        1,
        null,
        2,
        'Row Share',
        3,
        'Row Exclusive',
        4,
        'Share',
        5,
        'Share Row Exclusive',
        6,
        'Exclusive',
        null) lock_mode,
 o.owner,
 ls.sid,
 ls.serial# serial_num,
 ls.id1,
 ls.id2
  from sys.dba_objects o,
       (select s.osuser,
               s.username,
               l.type,
               l.lmode,
               s.sid,
               s.serial#,
               l.id1,
               l.id2
          from v$session s, v$lock l
         where s.sid = l.sid) ls
 where o.object_id = ls.id1
   and o.owner <> 'SYS'
 order by o.owner, o.object_name
```
## 查看等待（wait）情况
```
SELECT v$waitstat.class,
      v$waitstat.count count,
       SUM(v$sysstat.value) sum_value
  FROM v$waitstat, v$sysstat
 WHERE v$sysstat.name IN ('db block gets', 'consistent gets')
 group by v$waitstat.class, v$waitstat.count
```

## 取得服务器的IP 地址
```
select utl_inaddr.get_host_address from dual;
```
## 获取客户端的IP地址
```
select sys_context('userenv','host'),sys_context('userenv','ip_address') from dual;
```