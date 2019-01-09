# Python sqlite3模块 安装查询命令等使用讲解

**Sqlite3**是一个Python的嵌入式关系型[数据库](http://www.iplaypy.com/data/)，属于轻量级，并提供SQL支持。

## 一、sqlite3模块安装简介

从Python2.5以后的版本开始SQLite，sqlite3模块为SQLite提供了一个DB-API2.0的兼容接口，默认已经在[python 模块](http://www.iplaypy.com/module/)中，大家向下面这样，导入模块：

```
import sqlite3
```


没有报[异常](http://www.iplaypy.com/jichu/exception.html)，就说明模块已经导入成功了。

## 二、sqlite3模块创建打开数据库

SQLite数据库是使用文件来做为它的存储系统，可以自由选择它的存储位置。
```
>>> import sqlite3 #导入模块
>>> db = sqlite3.connect("d:\\test\\a.db") #Linux平台的话，同样使用绝对路径比较好
```
*connect()*方法，可以判断一个数据库文件是否存在，如果不存在就自动创建一个，如果存在的话，就打开那个数据库。

## 三 、sqlite3模块数据库对象操作

数据库的连接对象，有以下几种操作行为：
1. *commit()* ，事务提交
2. *rollback()* ，事务回滚
3. *cursor()* ，创建游标
4. *close()* ， 关闭一个连接

在创建了游标之后，它有以下可以操作的方法

- execute()，执行sql语句
- scroll()，游标滚动
- close()，关闭游标
- executemany，执行多条sql语句 
- fetchone()，从结果中取一条记录
- fetchmany()，从结果中取多条记录
- fetchall()，从结果中取出所有记录

用sqlite3模块，刚才我们已经新建了一个数据库，下面我们来新建一个表：

```
>>> cur = db.cursor()
>>> cur.execute("""create table catalog ( id integer primary key, pid integer, name varchar(10) UNIQUE )""")
```
刚才我们创建了一个名为 “iplaypython”的表，并设置了主键id，一个[整型](http://www.iplaypy.com/jichu/int.html)pid，和一个name。
insert(插入)数据：
```
>>> cur.execute("insert into catalog values(0, 0, 'i love python')")
>>> cur.execute("insert into catalog values(1, 0, 'hello world')")
>>> db.commit()
```
[^提示]: 对数据的修改，必须要用commit()方法提交一下事务。
select(选择):
```
>>> cur.execute("select * from catalog")
>>> print(cur.fetchall())
```
update(修改):
```
>>> cur.execute("update catalog set name='happy' where id = 0")
>>> db.commit()
>>> cur.execute("select * from catalog")
>>> print(cur.fetchone())
```
delete(删除)：
```
>>> cur.execute("delete from catalog where id = 1")
>>> db.commit()
>>> cur.execute("select * from catalog")
>>> print(cur.fetchall())
>>> cur.close()
>>> db.close()
```
## 四 、模块注意事项
Sqlite数据库虽然属于轻量级别的，但是它虽然小，但是功能齐全，是做测试练习和小型应用的首选数据库。