# python while循环控制流语句结构与用法

**python while循环语句**和[for](http://www.iplaypy.com/jinjie/for.html)语句都是[python](http://www.iplaypy.com/)的主要循环结构。while语句是python中最通用的迭代结构，也是一个条件循环语句。while与[if](http://www.iplaypy.com/jinjie/if.html)语句有哪些不同，标准语法结构及循环使用方法是本文主要内容。

![python while循环控制流语句](http://www.iplaypy.com/uploads/allimg/160219/2-16021915532a27.jpg)

## python while循环语句和if语句有哪些不同之处

要想知道while与if两种语句有何不同，首先要知道while语句的工作原理。
if语句是条件为真True，就会执行一次相应的代码块；而while中的代码块会一直循环，直到循环条件不能满足、不再为真。

## python while语句一般标准语法

while循环语句的语法如下所示：
>python while 条件:
>​    执行代码块

while循环中的执行代码块会一直循环执行，直到当条件不能被满足为假False时才退出循环，并执行循环体后面的语句。python while循环语句最常被用在计数循环中。

## python while循环控制流语句基本操作方法

举一个最简单的，不加任何多重条件的例子，来看看while循环控制流语句基本用法是怎么样的
```
>>>x = 1
>>>while x<10:
>>>    x+=1
>>>    print x
2
3
4
5
6
7
8
9
10
```
变量x的初始值为1，条件是x小于10的情况时，执行代码块x+=1的操作，直到x的值不再小于10。

python while循环语句和for语句一样，也是常搭配break、continue、else一起使用，可以完成更多重条件的要求。