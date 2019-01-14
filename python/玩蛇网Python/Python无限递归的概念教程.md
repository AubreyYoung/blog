# Python无限递归的概念教程

[Python](http://www.iplaypy.com/)程序调用自身的这种方法叫做递归，如果达不到我们需要的条件，而它会永远的继续递归调用下去，而程序也会永远不停止，这种现象叫做Python的**无限递归**。

下面[玩蛇网](http://www.iplaypy.com/)(www.iplaypy.com)给大家写一个会引起无限递归的简单函数：

```
`def` `test():``    ``test()`
```

很多程序语言中，无限递归的[函数](http://www.iplaypy.com/jichu/function.html)方法并不会真正的无休止的运行下去，它们都有一个深度限制，Python编程语言会在递归深度到达上限时，引发一个[异常](http://www.iplaypy.com/jichu/exception.html)的错误信息：

```
`>>> test()` `Traceback (most recent call last):``  ``File` `"pyshell#3"``, line ``1``, ``in` `module``    ``test()``  ``File` `"pyshell#2"``, line ``2``, ``in` `test``    ``test()``  ``File` `"pyshell#2"``, line ``2``, ``in` `test``    ``test()``  ``File` `"pyshell#2"``, line ``2``, ``in` `test``    ``test()``  ``File` `"pyshell#2"``, line ``2``, ``in` `test``    ``test()``RuntimeError: maximum recursion depth exceeded`
```

这个调用回溯信息显示了它的错误类型和详细信息，这个版本的Python无限递归最大值为 1000，各版本限制值不太相同。

```
>>>import sys
>>> sys.getrecursionlimit()
1000
```

