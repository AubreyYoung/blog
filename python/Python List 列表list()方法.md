# Python List 列表list()方法

Python基础数据类型之一**列表list**，在python中作用很强大，列表List可以包含不同类型的数据对像，同时它是一个有序的[集合](http://www.iplaypy.com/jichu/set.html)。所有序列能用到的标准操作方法，列表也都可以使用，比如切片、索引等，python的list是可变数据类型，它支持添加 append、插入 insert、修改、删除del等操作。

*下图使用了两个链接*

[![python列表list](http://www.iplaypy.com/uploads/allimg/160127/2-16012H1451MZ.jpg)](http://www.iplaypy.com/jichu/list.html)

## Python列表list的创建

可以把python中的**list列表**理解为任意对像的序列，只要把需要的参数值放入到中括号[  ]里面就可以了，就像下面这样操作：

 names = ['ada','amy','ella','sandy']

列表可以包含不同类型对像，也支持嵌套：

例如a = ['a',567,['adc',4,],(1,2)]

这个列表中就包含了字符串、整型、元组这些元素，同时还嵌套了一个列表。

## 修改列表list中的值

列表是有序的，可以通过python list下标来修改特定位置的值。下面用举例说明的方法来介绍下如何修改列表参数：
\>>>a = [1,9,9]
\>>>a [0] = 9
\>>>a
[9,9,9]
列表的修改操作，也可以把它看成是特定位置重新赋值的操作。

```
>>> a=[1,9,223,2324234,3432]
>>> a[0]=55
>>> a
[55, 9, 223, 2324234, 3432]
>>> del a[-1]
>>> a
```



## Python list 列表删除操作

**python 列表**删除最常用到的方法有三种：del、remove、pop，使用方法和用途也并不相同，这里先了解下del这种最方便的入门级列表删除操作方法。

现有列表 names = ['ada','amy','ella','sandy']，要求是把上面列表中的'amy'删除，思路是：先知道'amy'在列表names中的索引位置，之后配合del这个方法来删除。列表del方法具体使用方法如下：

\>>>names = ['ada','amy','ella','sandy']
\>>>del names[1]
\>>>names
['ada','ella','sandy']

玩蛇网Python列表的操作方法还有很多，像是python append、count、extend、index、python list insert、python reverse和sort排序等方法，这些会再更之后的文章中做详细讲解。