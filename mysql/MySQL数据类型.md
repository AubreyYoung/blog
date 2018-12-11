## MySQL数据类型

## 整形

| 存储类型  | 存储空间（字节） | 最小值               | 最大值               |
| --------- | ---------------- | -------------------- | -------------------- |
| TINYINT   | 1                | -128                 | 127                  |
|           |                  | 0                    | 255                  |
| SMALLINT  | 2                | -32768               | 32767                |
|           |                  | 0                    | 65535                |
| MEDIUMINT | 3                | -8388608             | 8388607              |
|           |                  | 0                    | 16777215             |
| INT       | 4                | -2147483648          | 4147483647           |
|           |                  | 0                    | 4294967295           |
| BIGINT    | 8                | -9223372036854775808 | 9223372036854775807  |
|           |                  | 0                    | 18446744073709551615 |

## 老生常谈的问题

- int(11) VS int(21) 有什么区别

是存储空间有区别？还是存储范围有区别？

**答案是：都没有区别,只在特性情况下显示上有些区别**

```
## 设置空位补零
mysql> create table testint (a int(11) zerofill, b int(21) zerofill);
Query OK, 0 rows affected (0.03 sec)

mysql> insert into testint values(1,1);
Query OK, 1 row affected (0.01 sec)

mysql> select * from testint;
+-------------+-----------------------+
| a           | b                     |
+-------------+-----------------------+
| 00000000001 | 000000000000000000001 |
+-------------+-----------------------+
1 row in set (0.00 sec)
## 默认情况下数字前面不会补零
mysql> create table testint (a int(11), b int(21));
Query OK, 0 rows affected (0.03 sec)

mysql> insert into testint values(1,1);
Query OK, 1 row affected (0.01 sec)

mysql> select * from testint;
+------+------+
| a    | b    |
+------+------+
|    1 |    1 |
+------+------+
1 row in set (0.00 sec)
```

## 浮点型

| 类型   | 存储空间（字节） | 精度   | 精确性        |
| ------ | ---------------- | ------ | ------------- |
| FLOAT  | 4                | 单精度 | 非精确        |
| DOUBLE | 8                | 双精度 | 比FLOAT精度高 |

- FLOAT(9,5)
- DOUBLE(9,5)

指定数字的总位数最大为9，小数点后最多显示5位数

FLOAT和DOUBLE都是非精确型的数据类型，非精确型的数据类型的问题是精度的丢失

```
mysql> create table `t` (                                                                           ->   `a` int(11) default null,
    ->   `b` float(7,4) default null
    -> ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
Query OK, 0 rows affected (0.02 sec)

mysql> insert into t values (1, 123.12345);
Query OK, 1 row affected (0.00 sec)

mysql> select * from t;
+------+----------+
| a    | b        |
+------+----------+
|    1 | 123.1235 |
+------+----------+
1 row in set (0.00 sec)
```

## 精确的数字类型

**DECIMAL(9,5) 定点数-更精确的数字类型**

- 高精度的数据类型，常用来存储交易相关的数据
- DECIMAL(M,N)，M代表总精度，N代表小数点右侧的位数（1 < M < 254; 0 < N < 60）
- 和FLOAT和DOUBLE不同的是，DECIMAL的存储空间是变长的

## 经验之谈

- 存储性别、省份、类型等分类信息时选择TINYINT或者enmu
- BIGINT存储空间更大，INT和BIGINT之间通常选择GIBINT
- 交易等高精度数据时选择使用DECIMAL数据类型