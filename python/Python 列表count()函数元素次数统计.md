# Python 列表count()函数元素次数统计

如何查看[Python list列表](http://www.iplaypy.com/jichu/list.html)中所包含相同元素的数量？使用python列表内置count()方法就可以统计某个元素在列表中出现了多少次。

## 列表count()函数调用方法

对象.count(参数)

## count()方法操作示例

有列表['a','iplaypython.com','c','b‘,'a']，想统计[字符串](http://www.iplaypy.com/jichu/str.html)'a'在列表中出现的次数，可以这样操作

```
`>>> [``'a'``,``'iplaypython.com'``,``'c'``,``'b'``,``'a'``].count(``'a'``)``2`
```

其返回值就是要统计参数出现的次数。在应用的时候最好是把列表赋给一个[变量](http://www.iplaypy.com/jichu/var.html)，之后再用count()方法来操作比较好。

当对象是一个嵌套的列表时，要查找嵌套列表中的列表参数count()方法同样可以完成

```
`>>> x ``=` `[``1``,``2``,``'a'``,[``1``,``2``],[``1``,``2``]]``>>> x.count([``1``,``2``])``2``>>> x.count(``1``)``1``>>> x.count(``'a'``)``1`
```

刚接触python语言的同学，很容易把len()和count()两种方法的作用混淆。列表是序列的一种，[序列的概念和通用操作方法](http://www.iplaypy.com/jinjie/jj106.html)可以关注一下。