## mysql修改sql_mode

## sql_mode

- 
- ANSI
- TRADITIONAL
- STRICT_TRANS_TABLES

## sql_mode为空

最宽松的模式, 即使有错误既不会报错也不会有警告⚠️

## ANSI

宽松模式，对插入数据进行校验，如果不符合定义类型或长度，对数据类型调整或截断保存，报warning警告

## TRADITIONAL

严格模式，当向mysql数据库插入数据时，进行数据的严格校验，保证错误数据不能插入，报error错误。用于事物时，会进行事物的回滚

## STRICT_TRANS_TABLES

严格模式，进行数据的严格校验，错误数据不能插入，报error错误

## NO_ENGINE_SUBSTITUTION

no_engine_subtitution的作用：mysql 在create table 时可以指定engine子句(指定存储引擎),如果把引擎指定成一个并不存在的引擎, 这个时候mysql可以有两种行为供选择

- 直接报错
- 把表的存储引擎替换成innodb

如果 sql_mode 存在 no_engine_subtitution 的时候 ===> 直接报错

如果 sql_mode 不存在 no_engine_subtitution 的时候 ===> 把表的存储引擎替换成innodb

## 查询 sql_mode

```
mysql>  select @@sql_mode;
+------------------------+
| @@sql_mode             |
+------------------------+
| NO_ENGINE_SUBSTITUTION |
+------------------------+
1 row in set (0.00 sec)

mysql> select @@global.sql_mode;
+------------------------+
| @@global.sql_mode      |
+------------------------+
| NO_ENGINE_SUBSTITUTION |
+------------------------+
1 row in set (0.00 sec)

mysql> select @@session.sql_mode;
+------------------------+
| @@session.sql_mode     |
+------------------------+
| NO_ENGINE_SUBSTITUTION |
+------------------------+
1 row in set (0.00 sec)
```

## 在线修改 sql_mode

```
SET [GLOBAL|SESSION] sql_mode='modes'
```

## 当前 session 生效

```
mysql> set sql_mode=`NO_FIELD_OPTIONS,HIGH_NOT_PRECEDENCE`;
```

## 全局生效

```
mysql> set global sql_mode=`NO_FIELD_OPTIONS,HIGH_NOT_PRECEDENCE`
```

## 离线修改 sql_mode

```
➜  ~ vim /etc/my.cnf

sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
```

------

参考文档:

- no_engine_subtitution: <http://www.cnblogs.com/JiangLe/p/5621856.html>

