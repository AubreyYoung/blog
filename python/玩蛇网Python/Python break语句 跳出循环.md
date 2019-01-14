# Python break语句 跳出循环

本文主要讲下**python**中的**break语句用法**，常用在满足某个条件，需要立刻退出当前循环时(跳出循环)，break语句可以用在[for循环](http://www.iplaypy.com/jinjie/for.html)和[while循环语句](http://www.iplaypy.com/jinjie/while.html)中。简单的说，break语句是会立即退出循环，在其后边的循环代码不会被执行。

![Python break语句使用方法](http://www.iplaypy.com/uploads/allimg/160127/2-16012G54344326.jpg)

## break语句的用法
```
>>>x = 1
>>>while True:
>>>    x+=1
>>>    print x
```
假设while条件为真，则执行代码块会被执行。因为条件永远是真，程序就会一直被执行下行，进入死循环，直到你的电脑崩溃。那么怎么解决这个问题呢？python 跳出循环！这个时候就要用到break语句来结束或是continue跳出。
```
>>>x = 1
>>>while True:
>>>    x+=1
>>>    print x
>>>    break
2
```
在代码最后加上break语句后，程序只运行了一次就被结束，这正说明了break语句是会立即退出循环的特性。你也可以给它设定另一个条件，当另一个条件被满足为真是，再执行退出操作。这就是下面要讲的while循环中的break和if语句，同样也可以在python中跳出for循环。

## break和if语句如果在while循环中使用方法

braak语句可以出现在while或for循环主体内，大多时候是和if语句一同出现。还用上面的例题来说明：
```
>>>x = 1
>>>while True:
>>>    x+=1
>>>    print x
>>>    if x >= 5:
 >>>       break
2
3
4
5
```
这里在结束之前，又多加了一个条件，当x大于等于5时再执行break语句。break语句是嵌套在if中的，要注意缩进问题，避免程序运行出错。