> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://blog.csdn.net/newhappy2008/article/details/4173600 <link rel="stylesheet" href="https://csdnimg.cn/release/phoenix/template/css/ck_htmledit_views-d7e2a68c7c.css">

转之 Eygle 的文章：[http://www.eygle.com/archives/2009/03/db_file_multiblock_read_count_auto.html](http://www.eygle.com/archives/2009/03/db_file_multiblock_read_count_auto.html)

关于这个参数，经过几多变化，在 Oracle10gR2 中终于修成了正果，实现了自动调整。

很久以前演过过这个参数，有过这样的[记叙](http://www.eygle.com/archives/2005/12/db_file_multiblock_read_count.html)：

> 初始化参数 db_file_multiblock_read_count 影响 Oracle 在执行全表扫描时一次读取的 block 的数量.
> 
> db_file_multiblock_read_count 的设置要受 OS 最大 IO 能力影响，也就是说，如果你系统的硬件 IO 能力有限，即使设置再大的 db_file_multiblock_read_count 也是没有用的。
> 
> 理论上，最大 db_file_multiblock_read_count 和系统 IO 能力应该有如下关系:
> 
> Max(db_file_multiblock_read_count) = MaxOsIOsize/db_block_size
> 
> 当然这个 Max(db_file_multiblock_read_count) 还要受 Oracle 的限制，
> 目前 Oracle 所支持的最大 db_file_multiblock_read_count 值为 128.
> 
> 我们可以通过 db_file_multiblock_read_count 来测试 Oracle 在不同系统下，单次 IO 最大所能读取得数据量

**这个参数的设置可能影响到 CBO 优化器的执行计划选择，所以 Oracle 通常缺省设置为 16，不推荐设置高于 32 的值。**

引用一段 [Kamus](http://www.dbform.com/html/2009/568.html) 同学的描述：

> db_file_multiblock_read_count 曾经是一个经过热烈讨论的初始化参数。该参数只有在对表或者索引进行 Full Scan 的时候才起作用。
> 
> 在 Oracle10gR2 以前的版本中，DBA 必须根据 db_block_size 参数，以及应用系统的特性，来调整 db_file_multiblock_read_count 参数。该参数值将影响 CBO 在该产生何种 SQL 执行计划上的判断。
> 
> 我们知道如下的公式，其中 max I/O chunk size 跟操作系统有关，但是 Oracle 文档中也指出大多数操作系统上该值为 1M。
> 
> db_file_multiblock_read_count = max I/O chunk size / db_block_size
> 
> 在 Oracle10gR2 之后的版本（10gR2 和 11g）中，Oracle 数据库已经可以根据系统的 IO 能力以及 Buffer Cache 的大小来动态调整该参数值，Oracle 建议不要显式设置该参数值。

在我的一个 11.1.0.7 的环境中，这个值被自动调整为 73：

> SQL> select * from v$version;
> 
> BANNER
> --------------------------------------------------------------------------------
> Oracle Database 11g Enterprise Edition Release 11.1.0.7.0 - Production
> PL/SQL Release 11.1.0.7.0 - Production
> CORE    11.1.0.7.0      Production
> TNS for Linux: Version 11.1.0.7.0 - Production
> NLSRTL Version 11.1.0.7.0 - Production
> 
> SQL> show parameter multi
> 
> NAME                                TYPE        VALUE
> ------------------------------------ ----------- ------------------------------
> db_file_multiblock_read_count        integer    73
> parallel_adaptive_multi_user        boolean    TRUE