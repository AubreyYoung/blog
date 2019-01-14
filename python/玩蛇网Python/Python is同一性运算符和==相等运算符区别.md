# Python is同一性运算符和==相等运算符区别

[Python](http://www.iplaypy.com/)中有很多运算符，今天我们就来讲讲is和==两种运算符在应用上的本质区别是什么。

在讲is和==这两种运算符区别之前，首先要知道Python中对象包含的三个基本要素，分别是：id(身份标识)、[python type()](http://www.iplaypy.com/jichu/type.html)(数据类型)和value(值)。is和\==都是对对象进行比较判断作用的，但对对象比较判断的内容并不相同。下面来看看具体区别在哪。

## ==比较操作符和is同一性运算符区别

==是[python标准操作符](http://www.iplaypy.com/jichu/symbol.html)中的比较操作符，用来比较判断两个对象的value(值)是否相等，例如下面两个[字符串](http://www.iplaypy.com/jichu/str.html)间的比较：
```
>>> a = 'iplaypython.com'
>>> b = 'iplaypython.com'
>>> a == b
True
```
is也被叫做同一性运算符，这个运算符比较判断的是对象间的唯一身份标识，也就是id是否相同。通过对下面几个列表间的比较，你就会明白is同一性运算符的工作原理：
```
>>> x = y = [4,5,6]
>>> z = [4,5,6]
>>> x == y
True
>>> x == z
True
>>> x is y
True
>>> x is z
False
>>>
>>> print(id(x))
3075326572
>>> print(id(y))
3075326572
>>> print(id(z))
3075328140
```
前三个例子都是True，这什么最后一个是False呢？x、y和z的值是相同的，所以前两个是True没有问题。至于最后一个为什么是False，看看三个对象的id分别是什么就会明白了。

## 总结

==比较操作符：用来比较两个对象是否相等，value做为判断因素；
is同一性运算符：比较判断两个对象是否相同，id做为判断因素。