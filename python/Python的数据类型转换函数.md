# Python的数据类型转换函数

玩蛇网这篇文章给大家介绍关于，**Python数据类型的转换函数**。

Python提供了一些可以把某个值从一种[数据类型](http://www.iplaypy.com/jichu/data-type.html)，转换成为另一种数据类型的内置[函数](http://www.iplaypy.com/jichu/function.html)和方法。[int函数](http://www.iplaypy.com/jichu/int.html)可以将任何可以转换为整型的值转换为整型，如果转换过程中出现错误，就会抛出异常，[python 捕获异常](http://www.iplaypy.com/jichu/exception.html)也是学习要点之一。

## python数据类型转换函数，演示代码：

首先，进入Python解释器中，方便我们调试代码。
\>>> int(‘123’) #[python int](http://www.iplaypy.com/jichu/int.html)方法将字符串’123’转换为整型123
123

\>>> int("iplaypython") #我们在转换字母字符串的时候，发生错误，系统自动抛出了ValueError错误。

Traceback (most recent call last):
  File "<pyshell#0>", line 1, in <module>
​    int("iplaypython")
ValueError: invalid literal for int() with base 10: 'iplaypython'
\>>>

[python int()](http://www.iplaypy.com/jichu/int.html)函数可以将浮点数转换为整数，但不做四舍五入的操作，它是直接去掉小数部分：
\>>> int(99.9999999)
99
\>>> int(-9.8)
-9
\>>>

还有我们的float函数，可以把整数和[字符串类型](http://www.iplaypy.com/jichu/str.html)，转换为浮点数类型：
\>>> float(85)
85.0
\>>> float('888999')
888999.0
\>>>

最后，我们试一下str这个字符串函数，它会将传入的参数转换为字符串类型：
\>>> str(321)
'321'
\>>> str(5654849)
'5654849'
\>>>

怎么样才能知道转换是否成功呢，了解过一些基础知识的朋友从引号等这些特点，已经能区别数据的类型了，其实我们在type()函数那篇文章中有详细介绍，如果查看数据（[变量](http://www.iplaypy.com/jichu/var.html)）的类型和方法。