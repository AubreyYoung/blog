#  dbms_metadata.get_ddl 的使用总结 
获取对象定义的包为：dbms_metadata，其中的 get_ddl 函数是获取对象的函数GET_DDL函数返回创建对象的原数据的 DDL 语句，参数说明
- object_type --- 需要返回原数据的 DDL 语句的对象类型

- name --- 对象名称

- schema --- 对象所在的 Schema，默认为当前用户所在所 Schema

- version --- 对象原数据的版本

- model --- 原数据的类型默认为 ORACLE

- transform. - XSL-T transform. to be applied.

- RETURNS: 对象的原数据默认以 CLOB 类型返回

其中，我们经常用到的是前三项。
dbms_metadata 包中的 get_ddl 函数定义：

```
FUNCTION get_ddl ( object_type IN VARCHAR2,
name IN VARCHAR2,
schema IN VARCHAR2 DEFAULT NULL,
version IN VARCHAR2 DEFAULT 'COMPATIBLE',
model IN VARCHAR2 DEFAULT 'ORACLE',
transform. IN VARCHAR2 DEFAULT 'DDL') RETURN CLOB;
```
  **注意：**
- 如果使用 sqlplus 需要进行下列格式化，特别需要对 long 进行设置，否则无法显示完整的 SQL
- 参数要使用大写，否则会查不到
  set linesize 180
  set pages 999
  set long 90000

## 查看数据库表的定义写法：

select dbms_metadata.get_ddl('TABLE','TABLENAME','USERNAME') from dual;

## 查看索引的 SQL

select dbms_metadata.get_ddl('INDEX','INDEXNAME','USERNAME') from dual;

## 查看创建主键的 SQL

SELECT DBMS_METADATA.GET_DDL('CONSTRAINT','CONSTRAINTNAME','USERNAME') FROM DUAL;

## 查看创建外键的 SQL

SELECT DBMS_METADATA.GET_DDL('REF_CONSTRAINT','REF_CONSTRAINTNAME','USERNAME') FROM DUAL;

## 查看创建视图的 SQL

SELECT DBMS_METADATA.GET_DDL('VIEW','VIEWNAME','USERNAME') FROM DUAL;

## 查看用户的 SQL

SELECT DBMS_METADATA.GET_DDL('USER','USERNAME') FROM DUAL;

## 查看角色的 SQL

SELECT DBMS_METADATA.GET_DDL('ROLE','ROLENAME') FROM DUAL;

## 查看表空间的 SQL

SELECT DBMS_METADATA.GET_DDL('TABLESPACE','TABLESPACENAME') FROM DUAL;

## 获取物化视图 SQL

select dbms_metadata.get_ddl('MATERIALIZED VIEW','MVNAME') FROM DUAL;

## 获取远程连接定义 SQL

SELECT dbms_metadata.get_ddl('DB_LINK','DBLINKNAME','USERNAME') stmt FROM dual

## 获取用户下的触发器 SQL

select DBMS_METADATA.GET_DDL('TRIGGER','TRIGGERNAME','USERNAME) FROM DUAL;

## 获取用户下的序列

select DBMS_METADATA.GET_DDL('SEQUENCE','SEQUENCENAME') from DUAL;

## 获取用户下的函数

select DBMS_METADATA.GET_DDL('FUNCTION','FUNCTIONNAME','USERNAME') from DUAL

## 获取包的定义

select DBMS_METADATA.GET_DDL('PACKAGE','PACKAGENAME','USERNAME') from dual

## 获取存储过程

select DBMS_METADATA.GET_DDL('PROCEDURE','PROCEDURENAME','USERNAME') from dual

## 获取包体定义

select DBMS_METADATA.GET_DDL('PACKAGE BODY','PACKAGEBODYNAME','USERNAME') from dual

## 获取远程数据库对象的定义

SELECT DBMS_LOB.SUBSTR@dblinkname(DBMS_METADATA.GET_DDL@dblinkname('TABLE', 'TABLENAME', 'USERNAME')) FROM DUAL@dblinkname

## 获取多个对象的定义

SELECT DBMS_METADATA.GET_DDL(O.OBJECT_TYPE, O.object_name,O.OWNER)
FROM DBA_OBJECTS O where O.OBJECT_TYPE IN ('TABLE','INDEX','PROCEDURE','FUNCTION') and ONWER = 'ONWERNAME';
这个语句可以更改一下，就可以得到很多语句出来

## 错误处理

```
SQL> select dbms_metadata.get_ddl('TABLE','TABLENAME','USERNAME') from dual;
ERROR:
ORA-19206: Invalid value for query or REF CURSOR parameter
ORA-06512: at "SYS.DBMS_XMLGEN", line 83
ORA-06512: at "SYS.DBMS_METADATA", line 345
ORA-06512: at "SYS.DBMS_METADATA", line 410
ORA-06512: at "SYS.DBMS_METADATA", line 449
ORA-06512: at "SYS.DBMS_METADATA", line 615
ORA-06512: at "SYS.DBMS_METADATA", line 1221
ORA-06512: at line 1
no rows selected
//解决办法
运行 $ORACLE_HOME/rdbms/admin/catmeta.sql
```
