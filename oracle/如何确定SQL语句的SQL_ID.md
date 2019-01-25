# 如何确定SQL语句的SQL_ID

## GOAL

本文档说明如何使用针对AWR，ASH数据或V$SQL视图执行的数据字典查询来确定SQL语句的关联文本的SQL_ID。

## SOLUTION

### 如何识别语句的SQL_ID

可以在AWR或ASH报告中找到语句的SQL_ID，也可以使用V $ SQL视图从数据库数据字典中选择它。

如果可以使用特定的可识别字符串或某种独特的注释来识别SQL，例如：/ * TARGET SQL * /那么这将使其更容易定位。

例如：

```
SQL> SELECT /* TARGET SQL */ * FROM dual;

SQL> SELECT sql_id, plan_hash_value, substr(sql_text,1,40) sql_text  FROM  v$sql 
WHERE sql_text like 'SELECT /* TARGET SQL */%'

SQL_ID        SQL_TEXT
------------- ----------------------------------------
0xzhrtn5gkpjs SELECT /* TARGET SQL */ * FROM dual
```

为方便起见，此处包含hash_value。 您还可以使用替换变量在V$SQL视图中找到SQL_ID：

```
SELECT sql_id, plan_hash_value, SUBSTR(sql_text,1,40) Text FROM v$sql WHERE sql_text LIKE '%&An_Identifiable_String%';
```

如果v$sql中没有SQL，则可以使用DBA_HIST_SQLTEXT和DBA_HIST_SQLSTAT：

```
select t.sql_id,
    t.sql_text,
    s.executions_total,
    s.elapsed_time_total
from DBA_HIST_SQLSTAT s, DBA_HIST_SQLTEXT t
where s.snap_id between 333 and 350;   # <====use snapid in which the query was run
```

### 要查找PL / SQL块中语句的SQL_ID

请参阅以下文档：

> [Document 741724.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1627387.1&id=741724.1) How to Determine the SQL_ID of a SQL Statement in a PL/SQL Block

如果您有PL / SQL块，例如：

```
declare v1 number; 
begin 
  select /* SimpleTest */ sum(sal) into v1 from emp; 
end; 
/
```

然后，如果您尝试从v$sql中找到SQL_ID，那么您将看到PL / SQL块的SQL_ID而不是SQL本身：

```
SQL> select sql_id, sql_text from v$sql where sql_text like '%SimpleTest%';

SQL_ID        SQL_TEXT
------------- ----------------------------------------------------------------------------------
77hjjr9qgwtzm declare v1 number; begin select /* SimpleTest */ sum(sal) into v1 from emp; end;
```

PL/SQL块中的SQL语句实际上是单独存储的，但您无法看到它，因为：

- PL / SQL块中的每个sql语句都存储为大写字母
- 每个注释和INTO语句都被删除

请注意，保留了优化器hints。

换一种说法，

```
select /* SimpleTest */ sum(sal) into v1 from emp
```

为了找到它的SQL_ID，你需要搜索类似于以下内容的东西：

```
SQL> select sql_id, sql_text from v$sql where sql_text like '%SUM(SAL)%EMP%';

SQL_ID        SQL_TEXT
------------- -------------------------------
5mqhh85sm278a SELECT SUM(SAL) FROM EMP
```

也可以使用SQL_TRACE中的hash_value来确定SQL_ID。 哈希值可以在由“hv =”字符串标识的原始跟踪文件中看到。

```
.................................................
PARSING IN CURSOR #1 len=24 dep=1 uid=54 oct=3 lid=54 tim=1194298465705687 hv=1899044106 ad='997aa660' 
SELECT SUM(SAL) FROM EMP
END OF STMT
..................
```

在这种情况下，哈希值为1899044106.要使用哈希值查找SQL_ID，请使用以下选择：

```
SQL> SELECT sql_id, hash_value, SUBSTR(sql_text,1,40) Text
FROM v$sql
WHERE  hash_value = &Hash_Value; 

SQL_ID        HASH_VALUE SQL_TEXT
------------- ---------- -------------------------------
5mqhh85sm278a 1899044106 SELECT SUM(SAL) FROM EMP
```

## 参考文档

[NOTE:1627387.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=741724.1&id=1627387.1) - How to Determine the SQL_ID for a SQL Statement

[NOTE:741724.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1627387.1&id=741724.1) - How to Determine the SQL_ID of a SQL Statement in a PL/SQL Block