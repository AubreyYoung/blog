# Oracle开发

## 基本开发SQL语句

```
--用户与表空间
--用户
show user
--解锁用户
alter  user usernmae account unlock;
alter user username  default tablespace tablesapce_name;
alter user username  default temporary tablespace tablesapce_name;
--表空间
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
/*不能删除表空间一个数据文件,若要删除必须删除表空间*/

drop tablesapce tablesapce_name including contents;
--表与约束
--表
alter table tablename add column_nmae datatype;
--修改数据类型
alter table tablename modify column_nmae datatype not null/null;

alter table tablename drop column colume_name;
alter table tablename rename column colume_name to new_ colume_name;
rename   tablename to new_tablename;

truncate table  tablename;
drop table tablename;

insert into table_name (....) values();
update table table_name set XX=XX where  ...

--约束在表中的作用
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

-- 有三种形式的外键约束：
-- 1、普通外键约束（如果存在子表引用父表主键，则无法删除父表记录）
-- 2、级联外键约束（可删除存在引用的父表记录，而且同时把所有有引用的子表记录也删除）
-- 3、置空外键约束（可删除存在引用的父表记录，同时将子表中引用该父表主键的外键字段自动设为NULL，但该字段应允许空值）
-- 这三种外键约束的建立语法如下：
-- 例如有两张表 父表T_INVOICE主键ID。子表T_INVOICE_DETAIL外键字段INVOICE_ID

--1、普通外键约束：

ALTER TABLE T_INVOICE_DETAIL ADD CONSTRAINT FK_INVOICE_ID FOREIGN KEY(INVOICE_ID ) REFERENCES T_INVOICE(ID);
--2、级联外键约束：
ALTER TABLE T_INVOICE_DETAIL ADD CONSTRAINT FK_INVOICE_ID FOREIGN KEY(INVOICE_ID ) REFERENCES T_INVOICE(ID) ON DELETE CASCADE;
--3、置空外键约束：
ALTER TABLE T_INVOICE_DETAIL ADD CONSTRAINT FK_INVOICE_ID FOREIGN KEY(INVOICE_ID ) REFERENCES T_INVOICE(ID) ON DELETE SET NULL;


--查询语句
--查询的作用
--强大的select

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

