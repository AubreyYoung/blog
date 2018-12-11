# MySQL中的ROWNUM的实现

  

[MySQL](http://lib.csdn.net/base/14 "MySQL知识库") 几乎模拟了 Oracle,SQL
Server等商业[数据库](http://lib.csdn.net/base/14
"MySQL知识库")的大部分功能，函数。但很可惜，到目前的版本(5.1.33)为止,仍没有实现ROWNUM这个功能。

下面介绍几种具体的实现方法.

建立实验环境如下

mysql> create table tbl (

    ->  id      int primary key,

    ->  col     int

    -> );

Query OK, 0 rows affected (0.08 sec)

mysql> insert into tbl values

    -> (1,26),

    -> (2,46),

    -> (3,35),

    -> (4,68),

    -> (5,93),

    -> (6,92);

Query OK, 6 rows affected (0.05 sec)

Records: 6  Duplicates: 0  Warnings:

mysql> select * from tbl order by col;

+----+------+

| id | col  |

+----+------+

|  1 |   26 |

|  3 |   35 |

|  2 |   46 |

|  4 |   68 |

|  6 |   92 |

|  5 |   93 |

+----+------+

6 rows in set (0.00 sec)

 **1\. 直接在程序中实现**

这应该算是效率最高的一种，也极为方便。直接在你的开发程序中（PHP/ASP/C/...）等中，直接初始化一个变量nRowNum=0，然后在while
记录集时，nRowNum++; 然后输出即可。

 **2\. 使用MySQL变量；在某些情况下，无法通过修改程序来实现时，可以考虑这种方法。**

缺点，@x 变量是 connection
级的，再次查询的时候需要初始化。一般来说PHP等B/S应用没有这个问题。但C/S如果connection一只保持则要考虑 set @x=0

mysql> select @x:=ifnull(@x,0)+1 as rownum,id,col

    -> from tbl

    -> order by col;

+--------+----+------+

| rownum | id | col  |

+--------+----+------+

|      1 |  1 |   26 |

|      1 |  3 |   35 |

|      1 |  2 |   46 |

|      1 |  4 |   68 |

|      1 |  6 |   92 |

|      1 |  5 |   93 |

+--------+----+------+

6 rows in set (0.00 sec)

 **3\. 使用联接查询（笛卡尔积）**

缺点，显然效率会差一些。利用表的自联接，代码如下，你可以直接试一下 select a.*,b.* from tbl a,tbl b where
a.col>=b.col 以理解这个方法原理

mysql> select a.id,a.col,count(*) as rownum

    -> from tbl a,tbl b

    -> where a.col>=b.col

    -> group by a.id,a.col;

+----+------+--------+

| id | col  | rownum |

+----+------+--------+

|  1 |   26 |      1 |

|  2 |   46 |      3 |

|  3 |   35 |      2 |

|  4 |   68 |      4 |

|  5 |   93 |      6 |

|  6 |   92 |      5 |

+----+------+--------+

6 rows in set (0.00 sec)

 **4\. 子查询**

缺点，和联接查询一样，具体的效率要看索引的配置和MySQL的优化结果。

mysql> select a.*,

    ->  (select count(*) from tbl where col<=a.col) as rownum

    -> from tbl a;

+----+------+--------+

| id | col  | rownum |

+----+------+--------+

|  1 |   26 |      1 |

|  2 |   46 |      3 |

|  3 |   35 |      2 |

|  4 |   68 |      4 |

|  5 |   93 |      6 |

|  6 |   92 |      5 |

+----+------+--------+

6 rows in set (0.06 sec)

做为一款开源的数据库系统，MySQL无疑是一个不做的产品。它的更新速度，文档维护都不逊于几大商业数据库产品。估计在下一个版本中，我们可以看到由MySQL自身实现的ROWNUM。

  



---
### TAGS
{GET_DDL}  {DDL}  {ROWNUM}

---
### NOTE ATTRIBUTES
>Created Date: 2016-05-30 02:20:22  
>Last Evernote Update Date: 2016-06-20 21:49:19  
>source: Clearly  
>source-url: http://blog.csdn.net/acmain_chm/article/details/4095531  