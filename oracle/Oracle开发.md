# Oracle开发

## 一、SQL基础
### 1.1 用户与表空间

- 用户

```
show user
//解锁用户
alter  user usernmae account unlock;
//修改用户默认表空间
alter user username  default tablespace tablesapce_name;
alter user username  default temporary tablespace tablesapce_name;

//删除user
drop user ×× cascade
```
- 表空间

```
create tablespace tablesapce_name datafile '+DATA' size 30g autoextend on;
create temporary tablespace tablesapce_name datafile '+DATA' size 30g autoextend on;
select * from dba_data_files;
select * from dba_temp_files;
select * from v$filestat;
select * from v$datafile;
--修改表空间
alter tablespace tablesapce_name off/online;
alter tablespace tablesapce_name read only/read write;
--修改数据文件
alter tablespace tablesapce_name add datafile '+DATA' size 30g autoextend on;
alter tablespace tablesapce_name drop datafile '(数据文件名,可以不添加路径*/)';
/*不能删除表空间第一个数据文件,若要删除必须删除表空间*/
drop tablesapce tablesapce_name including contents;
//如果其他表空间中的表有外键等约束关联到了本表空间中的表的字段，就要加上CASCADE CONSTRAINTS
drop tablespace tablespace_name including contents and datafiles CASCADE CONSTRAINTS;
```
### 1.2 表与约束

- 表

```
alter table tablename add column_nmae datatype;
--修改数据类型
alter table tablename modify column_nmae datatype not null/null;

alter table tablename drop column colume_name;
alter table tablename rename column colume_name to new_ colume_name;
rename   tablename to new_tablename;

truncate table  tablename;
drop table tablename;

#删除table
drop table  bh cascade constraints purge;

insert into table_name (....) values();
update table table_name set XX=XX where  ...
```
- 约束在表中的作用
```
create table tablename(
)
constraint constraintname primary key();

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
```

### 1.3 查询语句

查询的作用,强大的select

```
select  distinct .. from tablename where ...;
-- col username heading 用户名
-- col value for 9999.99 
-- col value for $9999.99 
-- col username clear
select .. from tablename where not(id = 1);

select sal,case sal  when 800 then '=800'  when 1250 then '=1250' else '不等800,1250' end from emp;

select sal,case when sal=800 then '=800'  when sal=1250 then '=1250'  else '不等800,1250' end from emp;

select sal,decode(sal,800,'工资低',5000,'工资高','工资一般') from emp;
```

## 二、SQL函数

### 2.1 函数的作用

- 方便数据的统计
- 处理查询结果

### 2.2 函数的分类

- 数值函数

  **四舍五入round(n[,m])**

  省略m:0;m>0:小数点后m位;m>0:小数点前m位

```
SQL> select round(23.4),round(23.4,1),round(23.4,-1) from dual;

ROUND(23.4) ROUND(23.4,1) ROUND(23.4,-1)
----------- ------------- --------------
         23          23.4             20
```

​	**取整函数**

ceil(n),floor(n)

```
SQL> select ceil(23.45),floor(23.45) from dual;

CEIL(23.45) FLOOR(23.45)
----------- ------------
         24           23
```

- 常用计算

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

- 三角函数

  sin(n)、asin(n)、cos(n)、acos(n)、tan(n)、atan(n)

- 字符函数

  upper(char),lower(char), initcap(char)  ----首字母大写

  substr(char,n[m])

  length(char)

  concat(char1,char2):与||操作符作用一样,字符串拼接

  trim(c2 from c1)  去除字符两边的一个字符,trim(char) 去除字符两边的所有空格

  ltrim(c2 from c1)

  rtrim(c2 from c1)

  replace(char,s_string[,r_string])

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

- 日期函数

  系统时间sysdate

```
alter session set nls_timestamp_format = 'yyyy-mm-dd hh24:mi:ss.ff';
select sysdate from dual
```

​	日期操作

​	add_months(date,i)

​	next_day(date,char)

​	last_day(date) 返回该月的最后一天

​	month_between(date1,date2)

​	extract(date from datetime)

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



- 转换函数

  日期转字符to_char(date[,fmt[,params])

```
SQL> select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') from dual;

TO_CHAR(SYSDATE,'YYYY-MM-DDHH24:MI:SS')
---------------------------------------
2019-03-18 15:38:49
```

​	字符转日期to_date(char[,fmt[,params])

```
SQL> select to_date('2019-09-10','yyyy-mm-dd hh24:mi:ss') from dual;

TO_DATE('2019-09-10','YYYY-MM-DDHH24:MI:SS')
--------------------------------------------
2019/9/10
```

​	数字转字符to_char(number,fmt[,params])

​		9:显示数字并忽略前面的0

​		0:显示数字,位数不足,用0补齐

​		.或D:显示小数点

​		,或G:显示千位符

​		$:美元符号

​		S:加正负号(前后都可以)

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

​	字符转数字to_number(char[,fmt])

```
SQL> select to_number('$122,322.233','$999,999.999') from dual;

TO_NUMBER('$122,322.233','$999,999.999')
----------------------------------------
                              122322.233
```

## 三、Oracle触发器

### 3.1 什么是触发器

每当一个特定的数据操作语句(insert,update,delete)在指定的表上发出时,Oracle自动地执行触发器中定义的语句序列.

```plsql
create trigger update_emp after insert on emp
declare
begin
  dbms_output.put_line('成功插入新员工');
end;
/

```

### 3.2  触发器的应用场景

- 复杂的安全性检查
- 数据的确认
- 实现审计功能
- 数据的备份与同步

### 3.3 触发器的语法

```plsql
create [or replace] trigger 触发器名
{befor|after}
{delete|insert|update [of 列名]}
on 表名
[for each row [when(条件)]]
PLSQL块
```

### 3.4 触发器的类型

- 语句级触发器

  指定的操作语句操作之前或之后执行一次,不管这条语句影响了多少行

- 行级触发器

  触发语句作用的每一条记录都被出发.在行级触发器中使用:old和:new伪记录变量识别值的状态

### 3.5 案例

- 案例一: 复杂的安全性检查      禁止在非工作时间插入新员工

```

```

