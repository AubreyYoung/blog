# Python 布尔表达式讲解

**布尔表达式**是值为**True**或者为**False**的一种Python的表达式。

下面的例子中[玩蛇网](http://www.iplaypy.com/)会使用”==”双等操作符，来比较两个操作对象是否相等，
如果相等，返回结果：True，否则返回：False。
```
>>> 5 == 5
True
>>> 5 == 6
False
```
真值(True)和假值(False)是[Python基础数据类型](http://www.iplaypy.com/jichu/data-type.html)之**bool**的两个特殊值，它们不是[字符串](http://www.iplaypy.com/jichu/str.html)：
可以用[type python](http://www.iplaypy.com/jichu/type.html)方法查看。
```
>>> type(True)
<type 'bool'>
>>> type(False)
<type 'bool'>
```
==操作符是一个关系操作符，其他的关系操作符还有：
```
x != y # x不等于y
x > y  # x大于y
x < y  # x小于y 
x >= y # x大于或等于y
x <= y # x小于或等于y
```
虽然这些操作符，你已经知道了好多，Python的符号和[python int](http://www.iplaypy.com/jichu/int.html)符号还是有些区别的，最常见的错误是使用了一个等号”=”，玩蛇网提示：比较2个值一定要用”==”。

大家要记住， = 是赋值操作符，而双等号 == 是一个关系型操作符。另外，==Python中不存在 =< 或者 =>这样的操作符==。