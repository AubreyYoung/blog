# 1. 用户与表空间

## 1.1 用户

```plsql
show user
//解锁用户
alter  user usernmae account unlock;
//修改用户默认表空间
alter user username  default tablespace tablesapce_name;
alter user username  default temporary tablespace tablesapce_name;

//删除user
drop user ×× cascade

-- 创建用户
create user yqm identified by ora1234 default tablespace users temporary tablespace temp;

-- 修改密码
alter user yqm identified by yqm1234;
--授予用户 connect 的权限
grant connect to yqm;
-- 授予用户 DBA 的权限
grant dba to yqm;
-- 收回用户 DBA 的权限
revoke dba from yqm;
-- 授予用户 能查询 SCOTT 下的 EMP 表的权限
grant select on scott.emp to kxht;
-- 授予用户能查询所有表的权限
grant select any table to solo;
grant delete any table to solo;
grant create any table to solo;
```
## 1.2 表空间

```plsql
create tablespace tablesapce_name datafile '+DATA' size 30g autoextend on;
create temporary tablespace tablesapce_name datafile '+DATA' size 30g autoextend on;
create undo tablespace zzq_undo1 datafile '/oradata/zltest\zzq_undo2.dbf' size 20m autoextend on;
select * from dba_data_files;
select * from dba_temp_files;
select * from v$filestat;
select * from v$datafile;
-- 修改表空间
alter tablespace tablesapce_name off/online;
alter tablespace tablesapce_name read only/read write;
-- 修改数据文件
alter tablespace tablesapce_name add datafile '+DATA' size 30g autoextend on;
--删除数据文件
alter tablespace tablesapce_name drop datafile '(数据文件名,可以不添加路径*/)';
/*不能删除表空间第一个数据文件,若要删除必须删除表空间*/
drop tablespace tablespace_name including contents and datafiles;
drop tablesapce tablesapce_name including contents;
-- 如果其他表空间中的表有外键等约束关联到了本表空间中的表的字段，就要加上CASCADE CONSTRAINTS
drop tablespace tablespace_name including contents and datafiles CASCADE CONSTRAINTS;

-- 移动数据库文件
alter tablespace users rename datafile 'd:\oradata\ZLTEST\USERS01.DBF' to 'd:\oradata\aucdbf\USERS01.DBF';
```
# 2. 表与约束

## 2.1 表

```plsql
alter table tablename add column_nmae datatype;
-- 修改数据类型
alter table tablename modify column_nmae datatype not null/null;

alter table tablename drop column colume_name;
alter table tablename rename column colume_name to new_ colume_name;
rename   tablename to new_tablename;

truncate table  tablename;
drop table tablename;

-- 创建索引
CREATE INDEX idx_emp_ename ON emp(ename) tablespace users;
CREATE bitmap INDEX idx_emp_ename ON emp(ename) tablespace users;

-- 删除table
drop table  bh cascade constraints purge;
drop table emp2 purge;

insert into table_name (....) values();
update table table_name set XX=XX where  ...

-- 删除
DELETE EMP4;
DELETE * FROM EMP5;

-- 加载到KEEP
ALTER TABLE <tablename> STORAGE (BUFFER POOL KEEP);
ALTER INDEX <indexname> STORAGE (BUFFER_POOL KEEP);

-- 移动表到另一个表空间
alter table zhang.zzq_1 move tablespace zhang_zzq;
```
## 2.2 约束在表中的作用

```plsql
create table tablename constraint constraintname primary key();
alter table tablename  add constraint constraintname primary key();
alter table tablename  add constraint constraintname unique();
alter table tablename  add constraint constraintname check();
alter table tablename rename constraint constraintname to new_constraintname;
alter table tablename disable/enable constraint constraintname;
alter table tablename drop constraint constraintname;
select * from dba_constraints
alter table tbalename drop primary key cascade;

create table tablename(
id name(6,0) references emp(id) unique check(....)
);

--添加主键约束：

ALTER TABLE GA_AIRLINE ADD CONSTRAINT PK_AIRLINE_ID PRIMARY KEY(AIRLINE_ID);

有三种形式的外键约束：
1、普通外键约束（如果存在子表引用父表主键，则无法删除父表记录）
2、级联外键约束（可删除存在引用的父表记录，而且同时把所有有引用的子表记录也删除）
3、置空外键约束（可删除存在引用的父表记录，同时将子表中引用该父表主键的外键字段自动设为NULL，但该字段应允许空值）
这三种外键约束的建立语法如下：
例如有两张表 父表T_INVOICE主键ID。子表T_INVOICE_DETAIL外键字段INVOICE_ID
//1、普通外键约束：
ALTER TABLE T_INVOICE_DETAIL ADD CONSTRAINT FK_INVOICE_ID FOREIGN KEY(INVOICE_ID ) REFERENCES T_INVOICE(ID);
//2、级联外键约束：
ALTER TABLE T_INVOICE_DETAIL ADD CONSTRAINT FK_INVOICE_ID FOREIGN KEY(INVOICE_ID ) REFERENCES T_INVOICE(ID) ON DELETE CASCADE;
//3、置空外键约束：
ALTER TABLE T_INVOICE_DETAIL ADD CONSTRAINT FK_INVOICE_ID FOREIGN KEY(INVOICE_ID ) REFERENCES T_INVOICE(ID) ON DELETE SET NULL;

ALTER TABLE emp ADD CONSTRAINTS ch_sal CHECK(sal > 0);

//约束的替代写法
SQL> INSERT INTO
  2    (SELECT EMPNO, ENAME, HIREDATE
  3       FROM EMP
  4      WHERE HIREDATE <= SYSDATE WITH CHECK OPTION)
  5  VALUES
  6    (9999, 'test', SYSDATE + 1);
INSERT INTO
  (SELECT EMPNO, ENAME, HIREDATE
     FROM EMP
    WHERE HIREDATE <= SYSDATE WITH CHECK OPTION)
VALUES
  (9999, 'test', SYSDATE + 1)

ORA-01402: view WITH CHECK OPTION where-clause violation
```

# 3 单表查询

## 3.1 简单查询

```plsql
-- 查看表结构
describe scott.emp;
desc scott.emp;

user_tab_cols用来获取对应用户表的列信息；
user_col_comments用来获取对应用户表列的注释信息；
user_constraints用来获取用户表的约束条件；
user_cons_columns约束中用户可访问列。

select * from dba_tab_cols where owner='SCOTT' and table_name='EMP';
select * from dba_col_comments where owner='SCOTT' and table_name='EMP';
select * from dba_constraints where owner='SCOTT' and table_name='EMP';
select * from dba_cons_columns where owner='SCOTT' and table_name='EMP';

select  distinct .. from tablename where ...;
-- col username heading 用户名
-- col value for 9999.99 
-- col value for $9999.99 
-- col username clear
select .. from tablename where not(id = 1);

select sal,case sal  when 800 then '=800'  when 1250 then '=1250' else '不等800,1250' end from emp;

select sal,case when sal=800 then '=800'  when sal=1250 then '=1250'  else '不等800,1250' end from emp;

select sal,decode(sal,800,'工资低',5000,'工资高','工资一般') from emp;

-- 查询空值
SQL> select * from emp where comm is null;

     EMPNO ENAME      JOB              MGR HIREDATE         SAL       COMM     DEPTNO
---------- ---------- --------- ---------- --------- ---------- ---------- ----------
      7369 SMITH      CLERK           7902 17-DEC-80        800                    20
      7566 JONES      MANAGER         7839 02-APR-81       2975                    20
      7698 BLAKE      MANAGER         7839 01-MAY-81       2850                    30
      7782 CLARK      MANAGER         7839 09-JUN-81       2450                    10
      7788 SCOTT      ANALYST         7566 19-APR-87       3000                    20
      7839 KING       PRESIDENT            17-NOV-81       5000                    10
      7876 ADAMS      CLERK           7788 23-MAY-87       1100                    20
      7900 JAMES      CLERK           7698 03-DEC-81        950                    30
      7902 FORD       ANALYST         7566 03-DEC-81       3000                    20
      7934 MILLER     CLERK           7782 23-JAN-82       1300                    10

10 rows selected.

SQL> select * from emp where comm <> null;

no rows selected
```

[^注]: NULL不支持加、减、乘、除、大小比较、相等比较，否则运算结果为NULL。而对于其他的函数,在使用时最好测试一下有NULL时的返回结果。

````plsql
SQL> select * from emp where comm <> null;

no rows selected

SQL> select * from dept where 1>= null;

no rows selected

SQL> select * from dept where 1<= null;

no rows selected

SQL> select * from dept where 1+null <= 0;

no rows selected

SQL> select * from dept where 1+null >= 0;

no rows selected

SQL> select * from dept where 1*null >= 0;

no rows selected

SQL> select replace('abcde','a',NULL) as str from dual;

STR
----
bcde

SQL> select greatest(1,null) from dual;

GREATEST(1,NULL)
----------------
NULL

SQL> select deptno,ename,comm,decode(comm,NULL,0) from scott.emp where deptno = 20;
    DEPTNO ENAME            COMM DECODE(COMM,NULL,0)
---------- ---------- ---------- -------------------
        20 Galaxy              0                    
        20 SMITH                                   0
        20 JONES                                   0
        20 SCOTT                                   0
        20 ADAMS                                   0
        20 FORD                                    0
        20 Aubrey              0                    
-- 不同的函数对NULL的支持不一样,使用NULL要先测试
````

## 3.2 NULL转换为0

```plsql
SQL> select coalesce(comm,0) from emp;

COALESCE(COMM,0)
----------------
               0
             300
             500
               0
            1400
               0
               0
               0
               0
               0
               0
               0
               0
               0

14 rows selected.

SQL> create or replace view v1 as 
  2  select null as c1,null as c2,1 as c3, null as c4,2 as c5, null as c6 from dual union all
  3  select null as c1,null as c2,null as c3, 3 as c4,null as c5, 2 as c6 from dual
  4  ;

View created.

SQL> select * from v1;

C C         C3         C4         C5         C6
- - ---------- ---------- ---------- ----------
             1                     2
                        3                     2

SQL> select coalesce(c1,c2,c3,c4,c5,c6) as c from v1;

         C
----------
         1
         3

-- 注: COALESCE(A,B,C,D)返回参数表中第一个不为空的值(从左开始) A B C D 可以是字段,也可以是其他函数的返回值或者表达式的结果值,如果所有的表达式都是空值,最终将返回一个空值.

SQL> select nvl(nvl(nvl(nvl(nvl(c1,c2),c3),c4),c5),c6)from v1;

NVL(NVL(NVL(NVL(NVL(C1,C2),C3),C4),C5),C
----------------------------------------
1
3
```

## 3.3 过滤条件加括号,便于查看

```plsql
select *
  from emp
 where ((DEPTNO = 10)
    or (comm is not null)
    or (DEPTNO = 20 and sal <= 2000));
```

## 3.4 别名作为where条件

```plsql
select  * from (select ename as 姓名,sal as 薪水,comm as 提成 from emp) x 
where 薪水 > 3000;
```

## 3.5 拼接字符

```plsql
select 'truncate table '||owner||'.'||table_name||';' as 清空表 from all_tables where owner ='SCOTT';
//单引号转义
select 'select table_name from all_tables where owner =''SCOTT'';' from dual;
select 'alter database datafile '''||file_name||''' offline drop;' from dba_data_files;
1.首尾单引号为字符串识别标识,不做转译用
2.首尾单引号里面如果出现的单引号，并且有多个,则相连两个单引号转译为一个字符串单引号
3.单引号一定成对出现,否者这个字符串出错,因为字符串不知道哪个单引号负责结束
```

## 3.6 select条件逻辑

```plsql
select ename as 姓名,sal as 薪资,
       case  when sal <= 2000 then '薪资低'
       when  sal >= 5000 then '薪资高'
       else '薪资中等'  end as 薪资水平
  from emp
 where deptno = 10;

姓名                 薪资 薪资水平
---------- ---------- ----
CLARK            2450 薪资中等
KING             5000 薪资高
MILLER           1300 薪资低

SQL> SELECT
    档次,
    COUNT(*) AS 人数
FROM
    (
        SELECT
            (
                CASE
                    WHEN sal <= 1000 THEN
                        '0000-1000'
                    WHEN sal <= 2000 THEN
                        '1000-2000'
                    WHEN sal <= 3000 THEN
                        '2000-3000'
                    WHEN sal <= 4000 THEN
                        '3000-4000'
                    WHEN sal >= 5000 THEN
                        '4000-5000'
                    ELSE
                        '好高'
                END
            ) AS 档次,
            ename,
            sal
        FROM
            scott.emp
    )
GROUP BY
    档次
ORDER BY
    1;
    
档次                人数
--------- ----------
0000-1000          2
1000-2000          6
2000-3000          7
4000-5000          1
```

## 3.7 取第二行数据

```plsql
SELECT * FROM (SELECT ROWNUM AS SN, EMP.* FROM EMP) WHERE SN = 2;
```

# 4 排序

## 4.1 基本排序

```plsql
SELECT empno,ename,hiredate FROM emp WHERE deptno=10 ORDER BY hiredate ASC;
SELECT empno,ename,hiredate FROM emp WHERE deptno=10 ORDER BY 3 ASC;
SELECT empno,deptno,sal,ename,job FROM emp ORDER BY 2 ASC,3 DESC;
```
## 4.2 多个字段排序

```plsql
select empno,deptno,sal,ename,job from scott.emp order by 2 asc,3 desc;
```
## 4.3 按子串排序

```plsql
SELECT LAST_NAME AS 名称,
       PHONE_NUMBER AS 号码,
       SALARY AS 工资,
       SUBSTR(PHONE_NUMBER, -4) AS 尾号
  FROM HR.EMPLOYEES
 WHERE ROWNUM <= 5
 ORDER BY 4;
 
 
 SELECT LAST_NAME AS 名称,
       PHONE_NUMBER AS 号码,
       SALARY AS 工资     
  FROM HR.EMPLOYEES t
 WHERE ROWNUM <= 5
 ORDER BY SUBSTR(t.PHONE_NUMBER, -4); 
```

## 4.4 随机读取数据

```plsql
-- 先随机排序,再取数据
SQL> SELECT empno,ename FROM (SELECT empno,ename FROM emp ORDER BY dbms_random.value()) WHERE ROWNUM <= 3;

EMPNO ENAME
----- ----------
 7844 TURNER
 7934 MILLER
 7654 MARTIN
```
## 4.5 TRANSLATE

TRANSLATE(expr,from_string,to_string)

```plsql
SQL> SELECT  TRANSLATE('ab 您好 bcadefg','abcdefg','1234567') AS NEW_STR  FROM dual;

NEW_STR
---------------
12 您好 2314567

-- to_string为空,则返回空值
SQL> SELECT  TRANSLATE('ab 您好 bcadefg','abcdefg','') AS NEW_STR  FROM dual;

NEW_STR
-------

-- to_string对应的位置没有字符,则from_string中列出的字符将会消掉
SQL> SELECT  TRANSLATE('ab 您好 bcadefg','1abcdefg','1') AS NEW_STR  FROM dual;

NEW_STR
-------
 您好
```

##  4.6 转义字符

```plsql
CREATE OR REPLACE VIEW v2 AS
SELECT 'ABCDEF' AS vname FROM dual
UNION ALL
SELECT '_BCEFG' AS vname FROM dual
UNION ALL
SELECT '_BCDEF' AS vname FROM dual
UNION ALL
SELECT '_\BCDEF' AS vname FROM dual
UNION ALL
SELECT 'XYCEG' AS vname FROM dual;

SELECT * FROM v2 WHERE vname LIKE '%CDE%';
SELECT * FROM v2 WHERE vname LIKE '_BCD%';
SELECT * FROM v2 WHERE vname LIKE '\_BCD%' ESCAPE '\';
SELECT * FROM v2 WHERE vname LIKE '_\\BCD%' ESCAPE '\';
```

## 4.7 部分字段排序

```plsql
CREATE OR REPLACE VIEW V3 AS SELECT EMPNO || ' ' ||ename AS DATA FROM emp;
SELECT * FROM v3;

SQL> SELECT DATA, TRANSLATE(DATA, '- 0123456789', '-') AS ENAME
  2    FROM V3
  3   ORDER BY 2;

DATA                                                ENAME
------------- --------------------------------------------------------------
7876 ADAMS                                          ADAMS
7499 ALLEN                                          ALLEN
7698 BLAKE                                          BLAKE
7782 CLARK                                          CLARK
7902 FORD                                           FORD
7900 JAMES                                          JAMES
7566 JONES                                          JONES
7839 KING                                           KING
7654 MARTIN                                         MARTIN
7934 MILLER                                         MILLER
7788 SCOTT                                          SCOTT
7369 SMITH                                          SMITH
7844 TURNER                                         TURNER
7521 WARD                                           WARD

14 rows selected
```

## 4.8  处理排序空值

**Oracle默认升序空值在后,降序空值在前.**

```plsql
-- NULL排在最前
SELECT ENAME, SAL, COMM ORDER_COL FROM EMP ORDER BY 3 NULLS FIRST;
-- NULL排在最后
SELECT ENAME, SAL, COMM ORDER_COL FROM EMP ORDER BY 3 NULLS LAST;
```

## 4.9 根据条件取不同列中的值来排序

要求工资在这个范围的员工排在前面,以便优先查看.

```plsql
SELECT EMPNO AS 编码,
       ENAME AS 姓名,
       CASE
         WHEN SAL >= 1000 AND SAL <= 2000 THEN
          1
         ELSE
          2
       END AS 级别,
       SAL AS 工资
  FROM EMP
 WHERE DEPTNO = 30
 ORDER BY 3, 4;
 
 SELECT EMPNO AS 编码,
       ENAME AS 姓名,
       SAL AS 工资
  FROM EMP
 WHERE DEPTNO = 30
 ORDER BY CASE
         WHEN SAL >= 1000 AND SAL <= 2000 THEN
          1
         ELSE
          2
       END,3;
```

# 5 操作多个表

## 5.1 UNION ALL 和空值

```plsql
SQL> SELECT EMPNO AS 编码, ENAME AS 名称, NVL(MGR, DEPTNO) AS 上级编码
     FROM EMP
    WHERE EMPNO = 7788
   UNION ALL
   SELECT DEPTNO AS 编码, DNAME AS 名称, NULL AS 上级编码
     FROM DEPT
    WHERE DEPTNO = 10;

        编码 名称                 上级编码
---------- -------------- ----------
      7788 SCOTT                7566
        10 ACCOUNTING     

-- Oracle中常常把空字符串当作NULL处理
SQL> select sysdate from dual where '' is null;
SYSDATE   
----------
2019-11-25
-- 空字符串本身是varchar2类型,NULL可以是任何类型,它们不等价.
```

## 5.2 UNION 与 OR

```plsql
SQL> SELECT empno,ename FROM emp WHERE empno = 7788 OR ename = 'SCOTT';

EMPNO ENAME
----- ----------
 7788 SCOTT

SQL> SELECT EMPNO, ENAME
      FROM EMP
     WHERE EMPNO = 7788
    UNION ALL
    SELECT EMPNO, ENAME
      FROM EMP
     WHERE ENAME = 'SCOTT';

EMPNO ENAME
----- ----------
 7788 SCOTT
 7788 SCOTT
 
SQL> SELECT EMPNO, ENAME
      FROM EMP
     WHERE EMPNO = 7788
    UNION
    SELECT EMPNO, ENAME
      FROM EMP
     WHERE ENAME = 'SCOTT';

EMPNO ENAME
----- ----------
 7788 SCOTT
 
 SCOTT@ORCLPDB1@ORCLPDB1>  ALTER SESSION SET "_b_tree_bitmap_plans" = FALSE;

Session altered.

SCOTT@ORCLPDB1@ORCLPDB1>  EXPLAIN PLAN FOR SELECT empno,ename FROM emp WHERE empno = 7788 OR ename = 'SCOTT';

Explained.

SCOTT@ORCLPDB1@ORCLPDB1>  SELECT * FROM TABLE(dbms_xplan.display);

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Plan hash value: 1494988596

---------------------------------------------------------------------------------------------------------
| Id  | Operation                             | Name            | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                      |                 |     2 |    40 |     3   (0)| 00:00:01 |
|   1 |  VIEW                                 | VW_ORE_DD1C526D |     2 |    40 |     3   (0)| 00:00:01 |
|   2 |   UNION-ALL                           |                 |       |       |            |          |
|   3 |    TABLE ACCESS BY INDEX ROWID        | EMP             |     1 |    10 |     1   (0)| 00:00:01 |
|*  4 |     INDEX UNIQUE SCAN                 | PK_EMP          |     1 |       |     0   (0)| 00:00:01 |
|*  5 |    TABLE ACCESS BY INDEX ROWID BATCHED| EMP             |     1 |    10 |     2   (0)| 00:00:01 |
|*  6 |     INDEX RANGE SCAN                  | IDX_EMP_ENAME   |     1 |       |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   4 - access("EMPNO"=7788)
   5 - filter(LNNVL("EMPNO"=7788))
   6 - access("ENAME"='SCOTT')

20 rows selected.
```
## 5.3  INNER JOIN

```plsql
SELECT E.EMPNO, E.ENAME, D.DNAME, D.LOC
  FROM EMP E
 INNER JOIN DEPT D
    ON (E.DEPTNO = D.DEPTNO)
 WHERE E.DEPTNO = 10;
 
 SELECT E.EMPNO, E.ENAME, D.DNAME, D.LOC
   FROM EMP E, DEPT D
  WHERE E.DEPTNO = D.DEPTNO
    AND E.DEPTNO = 10;
    
EXPLAIN PLAN FOR
      SELECT a.EMPNO, a.ENAME, a.JOB, a.SAL, a.DEPTNO
       FROM EMP a
     inner join emp2 b on (b.ename=a.ename and b.job=a.job and b.sal=a.sal);
      
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);      

PLAN_TABLE_OUTPUT                                                                                                                                                                                                                                                                                           
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Plan hash value: 166525280
 
---------------------------------------------------------------------------
| Id  | Operation          | Name | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |      |     4 |   208 |     6   (0)| 00:00:01 |
|*  1 |  HASH JOIN         |      |     4 |   208 |     6   (0)| 00:00:01 |
|   2 |   TABLE ACCESS FULL| EMP2 |     4 |   104 |     3   (0)| 00:00:01 |
|   3 |   TABLE ACCESS FULL| EMP  |    16 |   416 |     3   (0)| 00:00:01 |
---------------------------------------------------------------------------
 

PLAN_TABLE_OUTPUT                                                                                                                                                                                                                                                                                           
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - access("B"."ENAME"="A"."ENAME" AND "B"."JOB"="A"."JOB" AND 
              "B"."SAL"="A"."SAL")
 
Note
-----
   - dynamic sampling used for this statement (level=2)

已选择 20 行。
```

##  5.4 IN

```plsql
SQL> EXPLAIN PLAN FOR
      SELECT EMPNO, ENAME, JOB, SAL, DEPTNO
       FROM EMP
      WHERE (ENAME, JOB, SAL) IN (SELECT ENAME, JOB, SAL FROM EMP3);

Explained


SQL> SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

PLAN_TABLE_OUTPUT                                                                                                                                                                                                                                                                                           
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Plan hash value: 4039873364
 
---------------------------------------------------------------------------
| Id  | Operation          | Name | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |      |     4 |   208 |     6   (0)| 00:00:01 |
|*  1 |  HASH JOIN SEMI    |      |     4 |   208 |     6   (0)| 00:00:01 |
|   2 |   TABLE ACCESS FULL| EMP  |    16 |   416 |     3   (0)| 00:00:01 |
|   3 |   TABLE ACCESS FULL| EMP2 |     4 |   104 |     3   (0)| 00:00:01 |
---------------------------------------------------------------------------
 

PLAN_TABLE_OUTPUT                                                                                                                                                                                                                                                                                           
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - access("ENAME"="ENAME" AND "JOB"="JOB" AND "SAL"="SAL")
 
Note
-----
   - dynamic sampling used for this statement (level=2)

已选择 19 行。


```

## 5.5 EXISTS

```plsql
EXPLAIN PLAN FOR
      SELECT EMPNO, ENAME, JOB, SAL, DEPTNO
       FROM EMP a
      exists (select null from emp2 b where b.ename=a.ename and b.job=a.job and b.sal=a.sal);
      
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);     

PLAN_TABLE_OUTPUT                                                                                                                                                                                                                                                                                           
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Plan hash value: 4039873364
 
---------------------------------------------------------------------------
| Id  | Operation          | Name | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |      |     4 |   208 |     6   (0)| 00:00:01 |
|*  1 |  HASH JOIN SEMI    |      |     4 |   208 |     6   (0)| 00:00:01 |
|   2 |   TABLE ACCESS FULL| EMP  |    16 |   416 |     3   (0)| 00:00:01 |
|   3 |   TABLE ACCESS FULL| EMP2 |     4 |   104 |     3   (0)| 00:00:01 |
---------------------------------------------------------------------------
 

PLAN_TABLE_OUTPUT                                                                                                                                                                                                                                                                                           
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - access("ENAME"="ENAME" AND "JOB"="JOB" AND "SAL"="SAL")
 
Note
-----
   - dynamic sampling used for this statement (level=2)

已选择 19 行。
```

## 5.6 表连接

```plsql
DROP TABLE L PURGE;
DROP TABLE R PURGE;
/*左表*/
create table l as 
select 'left_1' as str,'1' as val from dual union ALL
select 'left_2','2' as val from dual union all
select 'left_3','3' as val from dual union all
select 'left_4','4' as val from dual;
select * from l;
/*右表*/
create table r as 
select  'right_3' as str,'3' as val,1 as status from dual union all
select  'right_4' as str,'4' as val,0 as status from dual union all
select  'right_5' as str,'5' as val,0 as status from dual union all
select  'right_6' as str,'6' as val,0 as status from dual;
select * from r;

/*INNER JOIN*/
select l.str as left_str,r.str as right_str from l inner join r on l.val=r.val order by 1,2;

/*INNER JOIN WHERE*/
select l.str as left_str,r.str as right_str from l,r where  l.val=r.val order by 1,2;

/*LEFT JOIN*/
select l.str as left_str,r.str as right_str from l left join r on l.val=r.val order by 1,2;
select l.str as left_str,r.str as right_str,r.status  from l left join r on l.val=r.val where r.status=1 order by 1,2;
select l.str as left_str,r.str as right_str,r.status  from l left join r on (l.val=r.val and r.status=1) order by 1,2;

/*LEFT JOIN + */
select l.str as left_str,r.str as right_str from l,r where  l.val=r.val(+) order by 1,2;
select l.str as left_str,r.str as right_str,r.status from l,r where  l.val=r.val(+) and r.status=1 order by 1,2;
select l.str as left_str,r.str as right_str,r.status from l,r where  l.val=r.val(+) and r.status(+)=1 order by 1,2;
select l.str as left_str,r.str as right_str,r.status from l,(select * from r where r.status=1) r where l.val=r.val(+)  order by 1,2;

/*RIGHT JOIN*/
select l.str as left_str,r.str as right_str from l right join r on l.val=r.val order by 1,2;
 
/*RIGHT JOIN + */
select l.str as left_str,r.str as right_str from l,r where  l.val(+)=r.val order by 1,2;

/*FULL JOIN*/
select l.str as left_str,r.str as right_str from l full join r on l.val=r.val order by 1,2;
 
 -- natural join
 -- 自然连接（NATURAL JOIN）是一种特殊的等值连接，将表中具有相同名称的列自动进行匹配。
 -- 1.自然连接不必指定任何连接条件;
 -- 2.如果两张表中有相同名字的列，但是数据类型不一致，如果能隐式转换，则能正常连接，但如果隐式转换不成功，则报错;
 -- 3.使用自然连接时，不能使用表名或表的别名修饰列;
 -- 4.自然连接会两张表中相同名称的所有列;
 -- 5.自然连接也可以指定显示列。
 -- 自然连接，自动匹配同名的列，虽然很方便，不用指定匹配的列。但也有缺点，虽然可以指定查询结果包括哪些列，但不能人为地指定哪些列被匹配,而内连接就可以自由指定。

SELECT
    index_name,
    column_name,
    index_type,
    uniqueness
FROM
    dba_indexes
    NATURAL JOIN dba_ind_columns
WHERE
    table_name = 'CUSTOMERS';
```

## 5.7 自关联

```plsql
/*自关联*/
SELECT 员工.EMPNO AS 职工编码,
       员工.ENAME AS 职工姓名,
       员工.JOB   AS 工作,
       员工.MGR   AS 员工表_主管编码,
       主管.EMPNO AS 主管表_主管编码,
       主管.ENAME AS 主管姓名
  FROM EMP 员工
  LEFT JOIN EMP 主管
    ON (员工.MGR = 主管.EMPNO)
 ORDER BY 1;
/*视图*/
CREATE OR REPLACE VIEW 员工 AS SELECT * FROM emp;
CREATE OR REPLACE VIEW 主管 AS SELECT * FROM emp;
SELECT 员工.EMPNO AS 职工编码,
       员工.ENAME AS 职工姓名,
       员工.JOB   AS 工作,
       员工.MGR   AS 员工表_主管编码,
       主管.EMPNO AS 主管表_主管编码,
       主管.ENAME AS 主管姓名
  FROM 员工
  LEFT JOIN 主管
    ON (员工.MGR = 主管.EMPNO)
 ORDER BY 1;
 
 /*自关联*/
 select a.*,b.ename from  emp a left join  emp b  on a.MGR=b.empno order by 1;
```

## 5.8 NOT IN,NOT EXISTS ,LEFT JOIN

```PLSQL
/*NOT IN*/
SQL> EXPLAIN PLAN FOR
      SELECT *
       FROM DEPT
       WHERE DEPTNO NOT IN
             (SELECT EMP.DEPTNO FROM EMP WHERE EMP.DEPTNO IS NOT NULL);

Explained

SQL> SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------
Plan hash value: 1353548327
--------------------------------------------------------------------------------
| Id  | Operation                    | Name    | Rows  | Bytes | Cost (%CPU)| Ti
--------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |         |     1 |    23 |     6  (17)| 00
|   1 |  MERGE JOIN ANTI             |         |     1 |    23 |     6  (17)| 00
|   2 |   TABLE ACCESS BY INDEX ROWID| DEPT    |     4 |    80 |     2   (0)| 00
|   3 |    INDEX FULL SCAN           | PK_DEPT |     4 |       |     1   (0)| 00
|*  4 |   SORT UNIQUE                |         |    14 |    42 |     4  (25)| 00
|*  5 |    TABLE ACCESS FULL         | EMP     |    14 |    42 |     3   (0)| 00
--------------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   4 - access("DEPTNO"="EMP"."DEPTNO")
       filter("DEPTNO"="EMP"."DEPTNO")
   5 - filter("EMP"."DEPTNO" IS NOT NULL)

19 rows selected

/*NOT EXISTS*/
SQL> EXPLAIN PLAN FOR
  2    SELECT *
  3      FROM DEPT
  4     WHERE NOT EXISTS (SELECT NULL FROM EMP WHERE EMP.DEPTNO = DEPT.DEPTNO);

Explained

SQL> SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------
Plan hash value: 1353548327
--------------------------------------------------------------------------------
| Id  | Operation                    | Name    | Rows  | Bytes | Cost (%CPU)| Ti
--------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |         |     1 |    23 |     6  (17)| 00
|   1 |  MERGE JOIN ANTI             |         |     1 |    23 |     6  (17)| 00
|   2 |   TABLE ACCESS BY INDEX ROWID| DEPT    |     4 |    80 |     2   (0)| 00
|   3 |    INDEX FULL SCAN           | PK_DEPT |     4 |       |     1   (0)| 00
|*  4 |   SORT UNIQUE                |         |    14 |    42 |     4  (25)| 00
|   5 |    TABLE ACCESS FULL         | EMP     |    14 |    42 |     3   (0)| 00
--------------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   4 - access("EMP"."DEPTNO"="DEPT"."DEPTNO")
       filter("EMP"."DEPTNO"="DEPT"."DEPTNO")

18 rows selected

/*LEFT JOIN*/
SQL> EXPLAIN PLAN FOR
  2    SELECT DEPT.*
  3      FROM DEPT
  4      LEFT JOIN EMP
  5        ON EMP.DEPTNO = DEPT.DEPTNO
  6     WHERE EMP.EMPNO IS NULL;

Explained

SQL> SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------
Plan hash value: 457395871
--------------------------------------------------------------------------------
| Id  | Operation                     | Name    | Rows  | Bytes | Cost (%CPU)| T
--------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |         |     1 |    27 |     6  (17)| 0
|*  1 |  FILTER                       |         |       |       |            |
|   2 |   MERGE JOIN OUTER            |         |     1 |    27 |     6  (17)| 0
|   3 |    TABLE ACCESS BY INDEX ROWID| DEPT    |     4 |    80 |     2   (0)| 0
|   4 |     INDEX FULL SCAN           | PK_DEPT |     4 |       |     1   (0)| 0
|*  5 |    SORT JOIN                  |         |    14 |    98 |     4  (25)| 0
|   6 |     TABLE ACCESS FULL         | EMP     |    14 |    98 |     3   (0)| 0
--------------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   1 - filter("EMP"."EMPNO" IS NULL)
   5 - access("EMP"."DEPTNO"(+)="DEPT"."DEPTNO")
       filter("EMP"."DEPTNO"(+)="DEPT"."DEPTNO")

20 rows selected
```

## 5.9 GROUP BY不显示0行

```plsql
SQL> SELECT COUNT(*) FROM EMP GROUP BY DEPTNO;

  COUNT(*)
----------
         6
         5
         3

SQL> SELECT COUNT(*) FROM EMP WHERE DEPTNO = 40;

  COUNT(*)
----------
         0
```

## 5.10  LEFT JOIN的条件

```plsql
SQL> SELECT L.STR AS LEFT_STR, R.STR AS RIGHT_STR, R.STATUS
  2    FROM L
  3    LEFT JOIN R
  4      ON L.V = R.V
  5   WHERE R.STATUS = 1
  6   ORDER BY 1, 2;

LEFT_STR RIGHT_STR     STATUS
-------- --------- ----------
left_3   right_3            1

SQL> SELECT L.STR AS LEFT_STR, R.STR AS RIGHT_STR, R.STATUS
  2    FROM L,R
  3   WHERE L.V = R.V(+)
  4     AND R.STATUS = 1
  5   ORDER BY 1, 2;

LEFT_STR RIGHT_STR     STATUS
-------- --------- ----------
left_3   right_3            1

SQL> EXPLAIN PLAN FOR
  2    SELECT L.STR AS LEFT_STR, R.STR AS RIGHT_STR, R.STATUS
  3      FROM L
  4      LEFT JOIN R
  5        ON L.V = R.V
  6     WHERE R.STATUS = 1
  7     ORDER BY 1, 2;

Explained


SQL> SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------
Plan hash value: 688663707
----------------------------------------------------------------------------
| Id  | Operation           | Name | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |      |     2 |    42 |     7  (15)| 00:00:01 |
|   1 |  SORT ORDER BY      |      |     2 |    42 |     7  (15)| 00:00:01 |
|*  2 |   HASH JOIN         |      |     2 |    42 |     6   (0)| 00:00:01 |
|*  3 |    TABLE ACCESS FULL| R    |     2 |    24 |     3   (0)| 00:00:01 |
|   4 |    TABLE ACCESS FULL| L    |     4 |    36 |     3   (0)| 00:00:01 |
----------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   2 - access("L"."V"="R"."V")
   3 - filter("R"."STATUS"=1)

17 rows selected

SQL> EXPLAIN PLAN FOR
  2    SELECT L.STR AS LEFT_STR, R.STR AS RIGHT_STR, R.STATUS
  3      FROM L,R
  4     WHERE L.V = R.V(+)
  5       AND R.STATUS = 1
  6     ORDER BY 1, 2;

Explained


SQL> SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------
Plan hash value: 688663707
----------------------------------------------------------------------------
| Id  | Operation           | Name | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |      |     2 |    42 |     7  (15)| 00:00:01 |
|   1 |  SORT ORDER BY      |      |     2 |    42 |     7  (15)| 00:00:01 |
|*  2 |   HASH JOIN         |      |     2 |    42 |     6   (0)| 00:00:01 |
|*  3 |    TABLE ACCESS FULL| R    |     2 |    24 |     3   (0)| 00:00:01 |
|   4 |    TABLE ACCESS FULL| L    |     4 |    36 |     3   (0)| 00:00:01 |
----------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   2 - access("L"."V"="R"."V")
   3 - filter("R"."STATUS"=1)

17 rows selected


SQL> SELECT L.STR AS LEFT_STR, R.STR AS RIGHT_STR, R.STATUS
  2    FROM L
  3    LEFT JOIN R
  4      ON (L.V = R.V AND R.STATUS = 1)
  5   ORDER BY 1, 2;

LEFT_STR RIGHT_STR     STATUS
-------- --------- ----------
left_1             
left_2             
left_3   right_3            1
left_4             

SQL> 
SQL> SELECT L.STR AS LEFT_STR, R.STR AS RIGHT_STR, R.STATUS
  2    FROM L,R
  3   WHERE L.V = R.V(+)
  4     AND R.STATUS(+) = 1
  5   ORDER BY 1, 2;

LEFT_STR RIGHT_STR     STATUS
-------- --------- ----------
left_1             
left_2             
left_3   right_3            1
left_4             

//改写的SQL
SELECT L.STR AS LEFT_STR, R.STR AS RIGHT_STR, R.STATUS
  FROM L
  LEFT JOIN (SELECT * FROM R WHERE STATUS = 1) R
    ON (L.V = R.V AND R.STATUS = 1)
 ORDER BY 1, 2;
 
 //改写的SQL执行计划
  Plan Hash Value  : 2310059642 

-----------------------------------------------------------------------
| Id  | Operation             | Name | Rows | Bytes | Cost | Time     |
-----------------------------------------------------------------------
|   0 | SELECT STATEMENT      |      |    4 |    84 |    7 | 00:00:01 |
|   1 |   SORT ORDER BY       |      |    4 |    84 |    7 | 00:00:01 |
| * 2 |    HASH JOIN OUTER    |      |    4 |    84 |    6 | 00:00:01 |
|   3 |     TABLE ACCESS FULL | L    |    4 |    36 |    3 | 00:00:01 |
| * 4 |     TABLE ACCESS FULL | R    |    2 |    24 |    3 | 00:00:01 |
-----------------------------------------------------------------------

Predicate Information (identified by operation id):
------------------------------------------
* 2 - access("L"."V"="R"."V"(+))
* 4 - filter("R"."STATUS"(+)=1 AND "STATUS"(+)=1)
```

## 5.11 比对两张表的数据

```plsql
CREATE OR REPLACE VIEW V4 AS
  SELECT *
    FROM EMP
   WHERE DEPTNO != 10
  UNION ALL
  SELECT *
    FROM EMP
   WHERE ENAME = 'SCOTT';

SELECT * FROM V4 WHERE ENAME = 'SCOTT';

SELECT ROWNUM, EMPNO, ENAME FROM EMP WHERE ENAME = 'SCOTT';

SQL> SELECT V4.EMPNO, V4.ENAME, B.EMPNO, B.ENAME
      FROM V4
      FULL JOIN EMP B
        ON (B.EMPNO = V4.EMPNO)
     WHERE (V4.EMPNO IS NULL OR B.EMPNO IS NULL);

EMPNO ENAME      EMPNO ENAME
----- ---------- ----- ----------
                  7782 CLARK
                  7839 KING
                  7934 MILLER
                
//改写SQL
SQL> SELECT V.EMPNO, V.ENAME, V.CNT, EMP.EMPNO, EMP.ENAME, EMP.CNT
  2    FROM (SELECT EMPNO, ENAME, COUNT(*) AS CNT FROM V4 GROUP BY EMPNO, ENAME) V
  3    FULL JOIN (SELECT EMPNO, ENAME, COUNT(*) AS CNT
  4                 FROM EMP
  5                GROUP BY EMPNO, ENAME) EMP
  6      ON (EMP.EMPNO = V.EMPNO AND V.CNT = EMP.CNT)
  7   WHERE (V.EMPNO IS NULL OR EMP.EMPNO IS NULL);

EMPNO ENAME             CNT EMPNO ENAME             CNT
----- ---------- ---------- ----- ---------- ----------
                             7782 CLARK               1
                             7788 SCOTT               1
                             7839 KING                1
                             7934 MILLER              1
 7788 SCOTT               2                  
```

## 5.12 聚集与内连接

```plsql
SQL> SELECT E.DEPTNO,
          SUM(E.SAL) AS TOTAL_SAL,
           SUM(E.SAL * EB2.RATE) AS TOLTAL_BONUS
      FROM EMP E
     INNER JOIN (SELECT EB.EMPNO,
                        SUM(CASE
                              WHEN EB.TYPE = 1 THEN
                               0.1
                              WHEN EB.TYPE = 2 THEN
                              0.2
                             WHEN EB.TYPE = 3 THEN
                             0.3
                           END) AS RATE
                  FROM EMP_BONUS EB
                 GROUP BY EB.EMPNO) EB2
       ON E.EMPNO = EB2.EMPNO
    WHERE E.DEPTNO = 10
    GROUP BY DEPTNO;

DEPTNO  TOTAL_SAL TOLTAL_BONUS
------ ---------- ------------
    10       6300         1890
```

## 5.13 聚集与外连接

```plsql
SQL> SELECT E.DEPTNO,
           SUM(E.SAL) AS TOTAL_SAL,
           SUM(E.SAL * EB2.RATE) AS TOLTAL_BONUS
      FROM EMP E
      LEFT JOIN (SELECT EB.EMPNO,
                        SUM(CASE
                              WHEN EB.TYPE = 1 THEN
                              0.1
                              WHEN EB.TYPE = 2 THEN
                              0.2
                             WHEN EB.TYPE = 3 THEN
                              0.3
                           END) AS RATE
                  FROM EMP_BONUS EB
                GROUP BY EB.EMPNO) EB2
       ON E.EMPNO = EB2.EMPNO
    GROUP BY DEPTNO;

DEPTNO  TOTAL_SAL TOLTAL_BONUS
------ ---------- ------------
    30       9400 
    20      10875 
    10       8750         1890
```

## 5.14 空值连接

```plsql
SQL> SELECT EMP.EMPNO, EMP.ENAME, DEPT.DEPTNO, DEPT.DNAME
  2    FROM EMP
  3    FULL JOIN DEPT
  4      ON DEPT.DEPTNO = EMP.DEPTNO;

EMPNO ENAME      DEPTNO DNAME
----- ---------- ------ --------------
 7369 SMITH          20 RESEARCH
 7499 ALLEN          30 SALES
 7521 WARD           30 SALES
 7566 JONES          20 RESEARCH
 7654 MARTIN         30 SALES
 7698 BLAKE          30 SALES
 7782 CLARK          10 ACCOUNTING
 7788 SCOTT          20 RESEARCH
 7839 KING           10 ACCOUNTING
 7844 TURNER         30 SALES
 7876 ADAMS          20 RESEARCH
 7900 JAMES          30 SALES
 7902 FORD           20 RESEARCH
 7934 MILLER         10 ACCOUNTING
                     40 OPERATIONS

15 rows selected


SELECT EMP.EMPNO, EMP.ENAME, DEPT.DEPTNO, DEPT.DNAME
  FROM EMP
  LEFT JOIN DEPT
    ON DEPT.DEPTNO = EMP.DEPTNO
UNION ALL
SELECT EMP.EMPNO, EMP.ENAME, DEPT.DEPTNO, DEPT.DNAME
  FROM EMP
 RIGHT JOIN DEPT
    ON DEPT.DEPTNO = EMP.DEPTNO;
```

## 5.15  空值转换

```plsql
SQL> SELECT A.ENAME, A.COMM
  2    FROM EMP A
  3   WHERE COALESCE(A.COMM, 0) <
  4         (SELECT B.COMM FROM EMP B WHERE B.ENAME = 'ALLEN');

ENAME           COMM
---------- ---------
SMITH      
JONES      
BLAKE      
CLARK      
SCOTT      
KING       
TURNER          0.00
ADAMS      
JAMES      
FORD       
MILLER     

11 rows selected


UPDATE emp SET deptno=NULL WHERE empno=7788;
SQL> SELECT COUNT(*)
  2    FROM DEPT
  3   WHERE DEPTNO NOT IN (SELECT EMP.DEPTNO FROM EMP WHERE EMP.DEPTNO IS NOT NULL);

  COUNT(*)
----------
         1
```

# 6 插入、更新与删除

### 4.1 插入

```plsql
 CREATE TABLE test1 (
 c1 VARCHAR2(10) DEFAULT '默认1',
 c2 VARCHAR2(10) DEFAULT '默认2',
 c3 VARCHAR2(10) DEFAULT '默认3',
 c4 DATE DEFAULT SYSDATE
 );
 
 INSERT INTO test1(c1,c2,c3) VALUES(DEFAULT,NULL,'手输值');
 
SQL>  SELECT * FROM test1;

C1         C2         C3         C4
---------- ---------- ---------- -----------
默认1                 手输值     2019/5/5 11

//视图的作用

CREATE OR REPLACE VIEW V_TEST1 AS
  SELECT C1, C2, C3 FROM TEST1;
  
INSERT INTO v_test1(c1,c2,c3) VALUES('手输c1',NULL,'不能改c4');

SQL> INSERT INTO v_test1(c1,c2,c3) VALUES(DEFAULT,NULL,'不能改c4');
INSERT INTO v_test1(c1,c2,c3) VALUES(DEFAULT,NULL,'不能改c4')

ORA-32575: Explicit column default is not supported for modifying views
```

### 4.2 复制数据

```plsql
CREATE TABLE test2 AS SELECT * FROM test1;

CREATE TABLE test2 AS SELECT * FROM test1 WHERE 1=2;

SQL> desc test2
Name Type         Nullable Default Comments 
---- ------------ -------- ------- -------- 
C1   VARCHAR2(10) Y                         
C2   VARCHAR2(10) Y                         
C3   VARCHAR2(10) Y                         
C4   DATE         Y         

INSERT INTO test2 SELECT * FROM test1;
```

[^注]:复制的表不包含默认值等约束信息,使用这种方式复制表后,需重建默认值及索引和约束.

### 4.3 无条件INSTER INTO

```plsql
CREATE TABLE EMP4 AS
  SELECT EMPNO, ENAME, JOB FROM EMP WHERE 1 = 2;

CREATE TABLE EMP5 AS
  SELECT EMPNO, ENAME, DEPTNO FROM EMP WHERE 1 = 2;

INSERT ALL INTO EMP4
  (EMPNO, ENAME, JOB)
VALUES
  (EMPNO, ENAME, JOB) INTO EMP5
  (EMPNO, ENAME, DEPTNO)
VALUES
  (EMPNO, ENAME, DEPTNO)
  SELECT EMPNO, ENAME, JOB, DEPTNO FROM EMP WHERE DEPTNO IN (10, 20);
```

### 4.4 有条件INSTER INTO

```plsql
INSERT ALL WHEN JOB IN
  ('SALESMAN', 'MANAGER') THEN INTO EMP4
  (EMPNO, ENAME, JOB)
VALUES
  (EMPNO, ENAME, JOB) WHEN DEPTNO IN
  ('20', '30') THEN INTO EMP5
  (EMPNO, ENAME, DEPTNO)
VALUES
  (EMPNO, ENAME, DEPTNO)
  SELECT EMPNO, ENAME, JOB, DEPTNO FROM EMP;
```

### 4.5 INSTER FIRST

```PLSQL
/*INSERT FIRST*/
DELETE EMP4;
DELETE EMP5;
INSERT FIRST WHEN JOB IN
  ('SALESMAN', 'MANAGER') THEN INTO EMP4
  (EMPNO, ENAME, JOB)
VALUES
  (EMPNO, ENAME, JOB) WHEN DEPTNO IN
  ('20', '30') THEN INTO EMP5
  (EMPNO, ENAME, DEPTNO)
VALUES
  (EMPNO, ENAME, DEPTNO)
  SELECT EMPNO, ENAME, JOB, DEPTNO FROM EMP;
```

### 4.6 转置INSTER

```plsql
/*转置 INSERT*/
DROP TABLE test3;
DROP TABLE test4;
CREATE TABLE TEST4(D VARCHAR2(10), DES VARCHAR2(50));
CREATE TABLE TEST3 AS
  SELECT '熊样,精神不佳' AS D1,
         '猫样,温驯听话' AS D2,
         '狗样,神气活现' AS D3,
         '鸟样,向往明天' AS D4,
         '花样,愿你快乐像花儿一样' AS D5
    FROM DUAL;
 
 SQL> INSERT ALL INTO TEST4
  2    (D, DES)
  3  VALUES
  4    ('周一', D1) INTO TEST4
  5    (D, DES)
  6  VALUES
  7    ('周二', D2) INTO TEST4
  8    (D, DES)
  9  VALUES
 10    ('周三', D3) INTO TEST4
 11    (D, DES)
 12  VALUES
 13    ('周四', D4) INTO TEST4
 14    (D, DES)
 15  VALUES
 16    ('周五', D5)
 17    SELECT D1, D2, D3, D4,D5 FROM TEST3;

5 rows inserted

SQL> SELECT * FROM test4;

D          DES
---------- --------------------------------------------------
周一       熊样,精神不佳
周二       猫样,温驯听话
周三       狗样,神气活现
周四       鸟样,向往明天
周五       花样,愿你快乐像花儿一样

//转置INSERT
INSERT INTO test4(d,des)
SELECT '周一',d1 FROM test3 UNION ALL
SELECT '周二',d2 FROM test3 UNION ALL
SELECT '周三',d3 FROM test3 UNION ALL
SELECT '周四',d4 FROM test3 UNION ALL
SELECT '周五',d5 FROM test3;
```

### 4.7 批量更新

```plsql
ALTER TABLE EMP ADD DNAME VARCHAR2(50) DEFAULT 'noname';

SELECT * FROM EMP;

SELECT DEPTNO,
       DNAME AS OLD_NAME,
       (SELECT DEPT.DNAME
          FROM DEPT
         WHERE DEPT.DEPTNO = EMP.DEPTNO
           AND DEPT.DNAME IN ('ACCOUNTING', 'RESEARCH')) AS NEW_DNAME,
       CASE
         WHEN EMP.DEPTNO NOT IN (10, 20) THEN
          '不被更新的行'
       END AS DES
  FROM EMP;

/*添加限定条件*/
SELECT DEPTNO,
       DNAME AS OLD_NAME,
       (SELECT DEPT.DNAME
          FROM DEPT
         WHERE DEPT.DEPTNO = EMP.DEPTNO
           AND DEPT.DNAME IN ('ACCOUNTING', 'RESEARCH')) AS NEW_DNAME,
       CASE
         WHEN EMP.DEPTNO NOT IN (10, 20) THEN
          '不被更新的行'
       END AS DES
  FROM EMP
 WHERE EXISTS (SELECT DEPT.DNAME
          FROM DEPT
         WHERE DEPT.DEPTNO = EMP.DEPTNO
           AND DEPT.DNAME IN ('ACCOUNTING', 'RESEARCH'));

UPDATE EMP
   SET EMP.DNAME =
       (SELECT DEPT.DNAME
          FROM DEPT
         WHERE DEPT.DEPTNO = EMP.DEPTNO
           AND DEPT.DNAME IN ('ACCOUNTING', 'RESEARCH'))
 WHERE EXISTS (SELECT DEPT.DNAME
          FROM DEPT
         WHERE DEPT.DEPTNO = EMP.DEPTNO
           AND DEPT.DNAME IN ('ACCOUNTING', 'RESEARCH'));

SELECT EMPNO, ENAME, DEPTNO, DNAME FROM EMP;
```







# 二、函数

## 1. 函数的作用

- 方便数据的统计 
- 处理查询结果

## 2. 函数的分类

### 2.1 数值函数

**四舍五入round(n[,m])**

省略m:0;m>0:小数点后m位;m>0:小数点前m位

```
SQL> select round(23.4),round(23.4,1),round(23.4,-1) from dual;

ROUND(23.4) ROUND(23.4,1) ROUND(23.4,-1)
----------- ------------- --------------
         23          23.4             20
```

**取整函数**

ceil(n),floor(n)

```
SQL> select ceil(23.45),floor(23.45) from dual;

CEIL(23.45) FLOOR(23.45)
----------- ------------
         24           23
```

**常用计算**

abs(n),mod(n,m),power(n,m),sqrt(16)

```
SQL> select abs(-23),abs(23),abs(0) from dual;

  ABS(-23)    ABS(23)     ABS(0)
---------- ---------- ----------
        23         23          0
        
SQL> select mod(8,3),mod(null,2),mod(8,null) from dual;

  MOD(8,3) MOD(NULL,2) MOD(8,NULL)
---------- ----------- -----------
         2             
 
SQL> select power(5,3),power(null,3) from dual;

POWER(5,3) POWER(NULL,3)
---------- -------------
       125 
SQL> select sqrt(16) from dual;

  SQRT(16)
----------
         4
```

**三角函数**

sin(n)、asin(n)、cos(n)、acos(n)、tan(n)、atan(n)

### 2.2 字符函数

**upper(char),lower(char), initcap(char)  ----首字母大写**

**substr(char,n[m])**

**length(char)**

**concat(char1,char2):与||操作符作用一样,字符串拼接**

**trim(c2 from c1)  去除字符两边的一个字符,trim(char) 去除字符两边的所有空格**

**ltrim(c2 from c1)**

**rtrim(c2 from c1)**

**replace(char,s_string[,r_string])**

```
SQL> select substr('oracle',4),substr('oracle',0,4),substr('oracle',-5,4) from dual;

SUBSTR('ORACLE',4) SUBSTR('ORACLE',0,4) SUBSTR('ORACLE',-5,4)
------------------ -------------------- ---------------------
cle                orac                 racl

SQL> select concat('Oracle','MySQL'),'Oracle'||'MySQL' from dual;

CONCAT('ORACLE','MYSQL') 'ORACLE'||'MYSQL'
------------------------ -----------------
OracleMySQL              OracleMySQL

SQL> select trim('a' from 'aoraclea') from dual;

TRIM('A'FROM'AORACLEA')
-----------------------
oracle

SQL> select replace('oracle','a') from dual;

REPLACE('ORACLE','A')
---------------------
orcle

SQL> select replace('oracle','a',' ') from dual;

REPLACE('ORACLE','A','')
------------------------
or cle

SQL> select replace('oracle','ac','R') from dual;

REPLACE('ORACLE','AC','R')
--------------------------
orRle
```

### 2.3 日期函数

**系统时间sysdate**

```
alter session set nls_timestamp_format = 'yyyy-mm-dd hh24:mi:ss.ff';
select sysdate from dual
```

​	**日期操作**

​	**add_months(date,i)**

​	**next_day(date,char)**

​	**last_day(date) 返回该月的最后一天**

​	**month_between(date1,date2)**

​	**extract(date from datetime)**

```
SQL> select add_months(sysdate,1),add_months(sysdate,-1) from dual;

ADD_MONTHS(SYSDATE,1) ADD_MONTHS(SYSDATE,-1)
--------------------- ----------------------
2019/4/18 15:19:29    2019/2/18 15:19:29

SQL> select next_day(sysdate,'星期一') from dual;

NEXT_DAY(SYSDATE,'星期一')
-----------------------
2019/3/25 15:22:12

SQL> select extract(year from sysdate) from dual;

EXTRACT(YEARFROMSYSDATE)
------------------------
                    2019
```

### 2.4 转换函数

**日期转字符to_char(date[,fmt[,params])**

```
SQL> select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') from dual;

TO_CHAR(SYSDATE,'YYYY-MM-DDHH24:MI:SS')
---------------------------------------
2019-03-18 15:38:49
```

字符转日期to_date(char[,fmt[,params])

```
SQL> select to_date('2019-09-10','yyyy-mm-dd hh24:mi:ss') from dual;

TO_DATE('2019-09-10','YYYY-MM-DDHH24:MI:SS')
--------------------------------------------
2019/9/10
```

**数字转字符to_char(number,fmt[,params])**

​		**9:显示数字并忽略前面的0**

​		**0:显示数字,位数不足,用0补齐**

​		**.或D:显示小数点**

​		**,或G:显示千位符**

​		**$:美元符号**

​		**S:加正负号(前后都可以)**

```
SQL> select to_char(122232.324,'$99,999,999.99') from dual;

TO_CHAR(122232.324,'$99,999,999.99')
------------------------------------
    $122,232.32

SQL> select to_char(122232.324,'S99,999,999.99') from dual;

TO_CHAR(122232.324,'S99,999,999.99')
------------------------------------
   +122,232.32

```

**字符转数字to_number(char[,fmt])**

```
SQL> select to_number('$122,322.233','$999,999.999') from dual;

TO_NUMBER('$122,322.233','$999,999.999')
----------------------------------------
                              122322.233
```

# 三、PL/SQL

## 1 . 定时JOB 

```plsql
1．创建一张表，用户存放定时信息
create table test_time (test date)
2. 制定定时执行的存储过程
create or replace procedure inserttest as begin insert into test_time values (sysdate);
end;
/
3. 创建 JOB，即创建待执行的定时任务过程
variable job1 number;
begin
dbms_job.submit(:job1,'inserttest;',sysdate,'sysdate+1/1440');
end;
4.启动 JOB 启动并运行定时任务的过程
begin
dbms_job.run(:job1);
end;
/
5.查看 结果
select to_char(test,'yyyy/mm/dd hh24:mi:ss') from test_time
```

定时JOB的参数说明  

```plsql
DBMS_JOB.SUBMIT(:jobno,//job 号
'your_procedure;',//要执行的过程
trunc(sysdate)+1/24,//下次执行时间
'trunc(sysdate)+1/24+1'//每次间隔时间
);
删除 job:dbms_job.remove(jobno);
修改要执行的操作:job:dbms_job.what(jobno,what);
修改下次执行时间： dbms_job.next_date(job,next_date);
修改间隔时间： dbms_job.interval(job,interval);
停止 job:dbms.broken(job,broken,nextdate);
启动 job:dbms_job.run(jobno);
修改 job_queue_processes 的值：（保证其不为 0 否则 JOB 不自动运行)可通过 select * from v$parameter;查看其值；
或者直接用 show parameter job_queue_processes;查看如下：
NAME TYPE VALUE
--------------- ----------- ------------
job_queue_processes integer 10
```



###  



# 四、Oracle触发器

## 4.1 什么是触发器

每当一个特定的数据操作语句(insert,update,delete)在指定的表上发出时,Oracle自动地执行触发器中定义的语句序列.

```plsql
create trigger update_emp after insert on emp
declare
begin
  dbms_output.put_line('成功插入新员工');
end;
/

```

## 4.2  触发器的应用场景

- 复杂的安全性检查
- 数据的确认
- 实现审计功能
- 数据的备份与同步

## 4.3 触发器的语法

```plsql
create [or replace] trigger 触发器名
{befor|after}
{delete|insert|update [of 列名]}
on 表名
[for each row [when(条件)]]
PLSQL块
```

## 4.4 触发器的类型

- 语句级触发器

  指定的操作语句操作之前或之后执行一次,不管这条语句影响了多少行

- 行级触发器

  触发语句作用的每一条记录都被出发.在行级触发器中使用:old和:new伪记录变量识别值的状态

## 4.5 案例

- 案例一: 复杂的安全性检查      禁止在非工作时间插入新员工

```

```

# 