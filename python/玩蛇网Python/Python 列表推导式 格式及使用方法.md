# Python 列表推导式 格式及使用方法

初学者可以把**python 列表推导式**理解为，利用其创建新[列表list](http://www.iplaypy.com/jichu/list.html)的一个简单方法。列表推导式比较像[for循环语句](http://www.iplaypy.com/jinjie/for.html)，必要时也可以加入[if条件语句](http://www.iplaypy.com/jinjie/if.html)完善推导式。

## 列表推导式标准格式

[Expression for Variable in  list]
也就是：[ 表达式  for  [变量](http://www.iplaypy.com/jichu/var.html) in 列表]
如果需要加入if条件语句则是：[表达式 for 变量 in 列表 if 条件]

## python推导式操作方法

### 列表推导式标准操作方法：
```
>>> a = [1,2,3,4,5,6,7,8,9,10]
>>> [3*x for x in a]
[3, 6, 9, 12, 15, 18, 21, 24, 27, 30]
```
如果没有给定列表，也可以用range()方法：
```
>>> [3*x for x in range(1,11)]
[3, 6, 9, 12, 15, 18, 21, 24, 27, 30]
```
### 加入if条件判断语句的列表推导式：

比如要取列表a中的偶数
```
>>> a = [1,2,3,4,5,6,7,8,9,10]
>>> [x for x in a if x % 2 == 0]
[2, 4, 6, 8, 10]
```
%号为取余算数操作符，可以查看[Python标准操作符与逻辑运算符](http://www.iplaypy.com/jichu/symbol.html)

### 多个for语句列表推导：

列表推导式中还可以加入多个for语句，看看能得到什么样的效果
```
>>> [[x,y] for x in range(2) for y in range(2)]
[[0, 0], [0, 1], [1, 0], [1, 1]]
```

