# 使用 from import方法导入Python模块

玩蛇网[python教程](http://www.iplaypy.com/)在前面的文章中给大家讲解过一种导入模块的方法 [import](http://www.iplaypy.com/jinjie/import.html) ，今天介绍一种经常会使用到的方法 **from import**。

比如我们导入一个数学计算的模块 math：
```
>>> import math
>>> print math
<module 'math' (built-in)>
>>>
>>> print(math.pi) #导出圆周率的值
3.14159265359
>>>
```
我们导入math模块，在[python模块学习](http://www.iplaypy.com/module/)中我们会知道，这样做会得到名math的对象，这个模块对象包含了pi这样的常量，以及一些其它的方法。

我们如果直接访问 pi，不加math这个前缀会发生什么情况呢？
```
>>> print(pi)

Traceback (most recent call last):
  File "<pyshell#6>", line 1, in <module>
    print pi
NameError: name 'pi' is not defined
>>>
```
程序抛出了一个名为“NameError”的错误，这样的[python 错误处理](http://www.iplaypy.com/jichu/exception.html)要怎么解决？这个时候我们可以用from这个方法来实现可以直接用pi这个方法：
```
>>> from math import pi
>>> print(pi)
3.141592653589793
>>>
```
这样我们就可以直接输出 pi的值了，而不会报错，不需要加那个模块名加句号。

有的朋友可能感觉还是比较麻烦，有会有更快速、更省事的Python模块导入方法呢？
答案是：还真有。

```
>>> from math import *
>>>
>>> pi
3.141592653589793
>>> cos(pi)
-1.0
>>>
```
这样就不需要一个一样导入模块内部的方法了，一次性的将所有[python 调用函数](http://www.iplaypy.com/jichu/function.html)方法导入，好处是代码看起来非常简洁，但是如果同时导入多个模块，要考虑模块方法名冲突等这些问题，至于怎么样使用，要看你的使用[环境](http://www.iplaypy.com/jichu/interpreter.html)。

总之，from方法导入模块，是你以后编程过程中经常会用到的。