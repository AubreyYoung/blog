# python if控制流语句 语法笔记

Python程序是由很多语句组成，**python if**执行条件语句也是其中的一种，也是本文要讲的重点。python **if语句**用于控制条件代码的执行，else和elif也是同样的功能，通常和[for循环语句](http://www.iplaypy.com/jinjie/for.html)搭配使用。else和elif和使用方法会单独写一篇文章来介绍，我们先来讲讲if语句的操作方法吧。

![python if语句用法](http://www.iplaypy.com/uploads/allimg/160127/2-16012H04Z91b.jpg)

## if控制流语句执行条件原理

if语句也叫做控制流语句，给出条件来决定下一步怎么操作。原理就是如果条件为真，则执行语句块内容被执行；如果条件为假，则语句块不会被执行。

## 标准python if条件语句格式

python if语句的一般格式如下：

> python if决策条件:
>
> ​	执行语句块	

举例说明下，大家可能就更容易理解些，像下面这样：
```
x = 5
if x>0:
   print 'x>0'
```
if x>0就是决策条件部分，意思是如果x的值比0大，那么执行语句块被执行。这里的执行语句块部分就是print 'x>0'，因为设定了x的值是[整型数字](http://www.iplaypy.com/jichu/int.html)5，x比0大为真True！所以执行语句块的内容会被输出（执行）；
相反，如果把条件改成if x<0结果会怎么样呢？真相是x=5，比0大，所以x<0是不对的，为假False！执行语句块的内容不会被输出（执行）。

## python if条件语句的执行规则

看下面这个例题，你会更清楚if条件语句的执行规则是怎么样的。
```
a = 2 ，b = 8
if a<b:                      python if语句条件为真True
    print 'a<b'            会被执行
if a>b:                      条件为假False
    print 'a>b'            不会被执行
```
执行代码块print[字符串](http://www.iplaypy.com/jichu/str.html)内容是不固定的，你可以写入你想要输出的内容，如果不存在要执行的语句，可以使用pass语句。