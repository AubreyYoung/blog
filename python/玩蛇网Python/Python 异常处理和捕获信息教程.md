# Python 异常处理和捕获信息教程

在学习了Python的[基础数据类型](http://www.iplaypy.com/jichu/data-type.html)和它们的相关操作方法之后，要学习的另外一个重点知识是 **Python异常**。

我们经常在编写程序和调试代码的过程中，有发生一些错误，为了处理和提醒用户这些错误，Python会抛出一个异常。

![python 异常处理](http://www.iplaypy.com/uploads/allimg/160219/2-160219153P4202.jpg)

Python使用它的异常对象(Exception object)来表示这种错误出现的情况，只要代码中出现错误，无论是语法错误还是缩进错误，都会引发异常情况。如果这种异常没有被处理或者捕捉，程序就会 回溯(Tracebace)，抛出异常信息，终止程序运行。

下面玩蛇网给大家举一个异常的简单案例：

![Python异常错误](http://www.iplaypy.com/uploads/allimg/131223/1-13122313011GV.jpg)

## 一、raise语句

我们可以主动的引发Python程序的异常，可以使用raise语句来触发异常。

\>>> raise Exception # 触发python异常类
\>>>

## 二、捕捉异常

如果在程序出错的时候捕捉到这个错误，被用自己的方式来处理它，或者不想让使用程序的用户了解程序出错的详细信息，这个时候我们就需要捕捉异常，可以使用 try和except 语言。

\>>>  a = 10
\>>>  b = 0
\>>>  [print](http://www.iplaypy.com/jichu/print.html) a / b
\>>>
这样，程序运行之后会产生异常错误，信息如下：
Traceback (most recent call last):
  File "<pyshell#2>", line 1, in <module>
​    print a /b
ZeroDivisionError: integer division or modulo by zero

如何处理上面的除零错误，并且返回自己想要的内容，请看下面的代码：

try:
​    a = 10
​    b = 0
​    print a / b
except ZeroDivisionError:
   print ("除零错误，已经捕获!")

如果需要同时捕捉多个可能的异常错误，可以把异常的类型，放入一个[元组](http://www.iplaypy.com/jichu/tuple.html)中，举例说明：
except (ZeroDivisionError, TypeError, NameError)