# Python 列表sort()添加key和reverse参数操作方法

本文是关于**Python 列表sort()添加key和reverse参数操作方法**介绍，之前[python sorted 倒序](http://www.iplaypy.com/jinjie/jj114.html)法在前面文章有中简单介绍过，sort()是python列表排序方法，除了[列表cmp()比较函数](http://www.iplaypy.com/jinjie/list-cmp.html)可以做为参数放在sort()，key和reverse更是经常用到的sort方法另外两个可选参数。使用时要通过[关键字参数](http://www.iplaypy.com/jinjie/jj130.html)，也就是名字来指定。

先来讲下key在sort()函数中的作用，key和cmp参数一样，使用时都需要提供可以做为排序依据的函数。比如说我们有一个列表，要以列表内元素的长度来排序，那么就需要用到计算长度的len()函数：

```
`>>> x ``=` `[``'hello'``,``'abc'``,``'iplaypython.com'``]``>>> x.sort(key``=``len``)``>>> x``[``'abc'``, ``'hello'``, ``'iplaypython.com'``]`
```

当然做为key排序依据的函数，不仅仅是len，只要按照你的需求写入对应的函数就可以。假如需要以整型数字来排序，就需要用到int：

```
`>>> a ``=` `[``'3'``,``'188'``,``'50'``,``'1225'``]``>>> a.sort(key``=``int``)``>>> a``[``'3'``, ``'50'``, ``'188'``, ``'1225'``]`
```

sort()还有另外一个关键字参数，就是reverse，它是一个布尔值True/False，作用是用来决定是否要对列表进行反向排序。

```
`>>> a.sort(key``=``int``,reverse``=``True``)``>>> a``[``'1225'``, ``'188'``, ``'50'``, ``'3'``]`
```

列表sort()添加key和reverse参数操作方法很简单，也可以同样应用到[python sorted 倒序](http://www.iplaypy.com/jinjie/jj114.html)函数中。key()和reverse()也可以同时做为参数添加到sort方法中，能帮助实现更多效果。