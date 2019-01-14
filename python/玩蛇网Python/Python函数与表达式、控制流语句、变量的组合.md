# Python函数与表达式、控制流语句、变量的组合

玩蛇网：看到这篇文章的朋友，大概已经看了前面我们介绍的[Python变量定义](http://www.iplaypy.com/jichu/var.html)、表达式、控制流语句([if](http://www.iplaypy.com/jinjie/if.html)语句、[else](http://www.iplaypy.com/jinjie/else-elif.html)语句等)以及[函数](http://www.iplaypy.com/jichu/function.html)的知识了，但是如果将这几类代码组合起来使用呢？

Python编程语言的最有用的特点之一就是可以将各种小的代码块，组合起来使用，提高开发效率和缩短代码行数。

例如：函数的参数可以是任何类型的表达式，而且可以有数学的算术符号。
```
>>> import math #首先导入math模块
>>>
>>> iplaypython = 10086 #创建一个整型变量
>>>
>>> p = math.sin(iplaypython / 2046.0 * 12 * math.pi) #组合各类代码元素
>>> print(p)
-0.469109990476
```
甚至，还可以包括函数的调用 ：
```
>>> math.exp(math.log(p+1))
0.5308900095241484
>>>
```
大致上，在任何地方可以使用值的地方，都可以使用任意的Python表达式，但是有一个例外情况：
赋值表达式的左边必须是变量名字，在左边放置任何其他的表达式都会产生[语法错误的异常](http://www.iplaypy.com/jichu/exception.html)。
举例说明：
```
>>> hours = 60
>>> minutes = hours * 60
>>>
>>> hours * 60 = minutes
SyntaxError: can't assign to operator #提供语法错误
```