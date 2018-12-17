> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://blog.csdn.net/newhappy2008/article/details/6199376 版权声明：本文为博主原创文章，未经博主允许不得转载。 https://blog.csdn.net/newhappy2008/article/details/6199376 <link rel="stylesheet" href="https://csdnimg.cn/release/phoenix/template/css/ck_htmledit_views-d7e2a68c7c.css">

使用 Insert Select 实现同时向多个表插入记录

一、无条件 INSERT ALL
---------------------------------------------------------------------------------------------
INSERT ALL
insert_into_clause values_clause_1
[insert_into_clause values_clause_2] 
……
Subquery；
----------------------------------------------------------------------------------------------
1、指定所有跟随着的多表 insert_into_clauses 执行无条件的多表插入；
2、对于每个由子查询返回的行， Oracle 服务器执行每一个 insert_into_clause 一次。
二、条件 INSERT ALL
---------------------------------------------------------------------------------------------
INSERT ALL
WHEN condition THEN insert_into_clause values_clause
[WHEN condition THEN] [insert_into_clause values_clause]
……
[ELSE] [insert_into_clause values_clause] 
Subquery；
--------------------------------------------------------------------------------------------
1、指定 conditional_insert_clause 来执行一个条件多表插入；
2、Oracle 服务器通过相应的 WHEN 条件过滤每一个 insert_into_clause，确定是否执行这个 insert_into_clause；
3、一个单个的多表插入语句可以包含最多 127 个 WHEN 子句。
三、条件 INSERT FIRST
--------------------------------------------------------------------------------------------
INSERT FIRST
WHEN condition THEN insert_into_clause values_clause
[WHEN condition THEN] [insert_into_clause values_clause]
……
[ELSE] [insert_into_clause values_clause] 
Subquery；
--------------------------------------------------------------------------------------------
1、Oracle 服务器对每一个出现在语句顺序中的 WHEN 子句求值；
2、如果第一个 WHEN 子句的值为 true，Oracle 服务器对于给定的行执行相应的 INTO 子句，并且跳过后面的 WHEN 子句 (后面的 when 语句都不再考虑满足第一个 When 子句的记录，即使该记录满足 when 语句中的条件)。
注：多表 INSERT 语句上的约束
a、你只能在表而不能在视图上执行多表插入；
b、你不能执行一个多表插入到一个远程表；
c、在执行一个多表插入时，你不能指定一个表集合表达式；
d、在一个多表插入中，所有的 insert_into_clauses 不能组合指定多于 999 个目列；
e、只有当所有 insert_into_clauses 中的表数据都没有发生更新时，Rollback 才会起作用。
EG: 
   Tables: z_test(id int,name varchar2(10));
          z_test1(id int ,name varchar2(10));
          z_test2(id int);
          z_test3(name varchar2(10);
初始数据：z_test
Id    Name
10    133
5    184
1    18423
1    18445
1    18467
6    129
2    12923
2    12945
z_test1, z_test2,z_test3 均为空。
测试一：无条件 INSERT ALL
    SQL 语句：
----------------------------------------------------------------------------
SQL> Insert All 
  2  Into z_test1(id,name) values (id,name)
  3  Into z_test2(id) values(id)
  4  Select id,name from z_test;
16 rows created.
----------------------------------------------------------------------------
测试结果：
----------------------------------------------------------------------------
SQL> select * from z_test1;
        ID NAME
---------- --------------------
        10 133
         5 184
         1 18423
         1 18445
         1 18467
         6 129
         2 12923
         2 12945
8 rows selected.
SQL> select * from z_test2;
        ID
----------
        10
         5
         1
         1
         1
         6
         2
         2
8 rows selected.
----------------------------------------------------------------------------
测试二：条件 INSERT ALL
    SQL 语句：
----------------------------------------------------------------------------
SQL> Insert All
  2  when id>5 then into z_test1(id, name) values(id,name)
  3  when id<>2 then into z_test2(id) values(id)
  4  else into z_test3 values(name)
  5  select id,name from z_test;
10 rows created.
----------------------------------------------------------------------------
测试结果：
----------------------------------------------------------------------------
SQL> select * from z_test1;
        ID NAME
---------- --------------------
        10 133
         6 129
SQL> select * from z_test2;
        ID
----------
        10
         5
         1
         1
         1
         6
6 rows selected.
SQL> select * from z_test3;
NAME
--------------------
12923
12945
2 rows selected.
----------------------------------------------------------------------------
测试三：条件 INSERT FIRST
    SQL 语句：
----------------------------------------------------------------------------
SQL> Insert First 
  2  when id=1 then into z_test1 values(id,name)
  3  when id>5 then into z_test2 values(id)
  4  else into z_test3 values(name)
  5  select * from z_test;
8 rows created.
----------------------------------------------------------------------------
测试结果：
----------------------------------------------------------------------------
SQL> select * from z_test1;
        ID NAME
---------- --------------------
         1 18423
         1 18445
         1 18467
3 rows created.
SQL> select * from z_test2;
        ID
----------
        10
         6
2 rows created.
SQL> select * from z_test3;
NAME
--------------------
184
12923
12945
3 rows created.