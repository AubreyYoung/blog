# Python 运行报错NameError出现原因，怎么解决

刚刚学习[python](http://www.iplaypy.com/)语言时常会遇到一些问题，能看懂常见的[python 捕获异常](http://www.iplaypy.com/jichu/exception.html)错误类型很重要。[python ioerror](http://www.iplaypy.com/jinjie/ioerror.html)很常见，**NameError**是最普通也是最常会遇到的内建报错类名，其代表问题出现在[python 变量命名](http://www.iplaypy.com/jichu/var.html)上，找不到变量名会引发NameError。

举一个最简单的可以引发NameError错误示例，[print](http://www.iplaypy.com/jichu/print.html)一个不存在的变量名：

```
`>>> ``print` `x``Traceback (most recent call last):``  ``File` `"<stdin>"``, line ``1``, ``in` `<module>``NameError: name ``'x'` `is` `not` `defined`
```

错误提示告诉我们NameError: name 'x' is not defined，名称'x'没有定义，也就是说没有找到该对象。还有[python permission denied](http://www.iplaypy.com/jinjie/ioerror.html)，是没有权限的意思。

玩蛇网python学习分享平台告诉你**解决NameError方法**：把未定义的变量名定义一下。比如只是想输出[字符串‘](http://www.iplaypy.com/jichu/str.html)x’，或是想把x定义为某种[数据类型](http://www.iplaypy.com/jichu/data-type.html)，都要先告诉程序这个对象是什么。

```
`>>> ``print` `'x'``x``>>>``>>> x ``=` `( )``>>> ``print` `x``()``>>>``>>> x ``=` `[ ]``>>> ``print` `x``[]``>>>``>>> x ``=` `{ }``>>> ``print` `x``{}`
```

​	要避免python的NameError错误还需要注意：在编写[函数](http://www.iplaypy.com/jichu/function.html)，调用变量时要注意变量的[作用域](http://www.iplaypy.com/jinjie/jj146.html)，变量工作范围不清晰，调用时也会出现NameError错误；

​	再有比如要使用[time模块](http://www.iplaypy.com/module/time.html)内某个方法时，记得要先导入该模块（一般要指明在哪个模块中）不然运行时会引发NameError错误。