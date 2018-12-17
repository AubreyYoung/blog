> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://blog.csdn.net/newhappy2008/article/details/2316056 <link rel="stylesheet" href="https://csdnimg.cn/release/phoenix/template/css/ck_htmledit_views-d7e2a68c7c.css">

索引的选择性是指索引列中不同值的数目与表中记录数的比。如果一个表中有 2000 条记
录，表索引列有 1980 个不同的值，那么这个索引的选择性就是 1980/2000=0.99。

　　一个索引的选择性越接近于 1，这个索引的效率就越高。

　　如果是使用基于 cost 的最优化，优化器不应该使用选择性不好的索引。如果是使用基于
rule 的最优化，优化器在确定执行路径时不会考虑索引的选择性（除非是唯一性索引），并
且不得不手工优化查询以避免使用非选择性的索引。

　　确定索引的选择性，可以有两种方法：手工测量和自动测量。

　　（1）手工测量索引的选择性
　　如果要根据一个表的两列创建两列并置索引，可以用以下方法测量索引的选择性：

　　列的选择性 = 不同值的数目 / 行的总数 /* 越接近 1 越好 */

select count(distinct 第一列 ||'%'|| 第二列)/count(*)
from 表名
/

select count(distinct status||'%'||owner)/count(*)
from test;
/

　　如果我们知道其中一列索引的选择性（例如其中一列是主键），那么我们就可以知道另一列索引的选择性。

　　手工方法的优点是在创建索引前就能评估索引的选择性。

　　（2）自动测量索引的选择性

　　如果分析一个表，也会自动分析所有表的索引。

　　第一，为了确定一个表的确定性，就要分析表。

analyze table 表名 compute statistics
/

　　第二，确定索引里不同关键字的数目：

select distinct_keys
from user_indexes
where table_name='表名'
and index_name='索引名'
/

　　第三，确定表中行的总数：

select num_rows
from user_tables
where table_name='表名'
/

　　第四，索引的选择性 = 索引里不同关键字的数目 / 表中行的总数：

select i.distinct_keys/t.num_rows
from
user_indexes i,
user_tables t
where i.table_name='表名'
and i.index_name='索引名'
and i.table_name=t.table_name
/

　　第五，可以查询 USER_TAB_COLUMNS 以了解每个列的选择性。

　　表中所有行在该列的不同值的数目：

select
column_name,
num_distinct
from user_tab_columns
where table_name='表名'
/

　　列的选择性 = NUM_DISTINCT / 表中所有行的总数，查询 USER_TAB_COLUMNS 有助测量每个列
的选择性，但它并不能精确地测量列的并置组合的选择性。要想测量一组列的选择性，需要
采用手工方法或者根据这组列创建一个索引并重新分析表。