# Python time模块 函数格式 时间操作源码演示

[Python](http://www.iplaypy.com/)标准库中有一个操作时间的模块，叫做 **python time模块**。

![python time模块](http://www.iplaypy.com/uploads/allimg/160323/2-160323152531330.jpg)

[TOC]

## 一、python time模块的简介

在Python编程语言中，只要涉及到时间日期的操作，就会用到这个time模块。

应用的时候，有3种方式用来表示时间：

1. 时间戳
2. 格式化的时间[str（字符串）](http://www.iplaypy.com/jichu/str.html)
3. [元组](http://www.iplaypy.com/jichu/tuple.html) (struct_time)以及calendar

## 二、python time模块函数讲解

要注意的是元组struct_time有9个元素，它们的索引的内容如下：

[索引][属性]               [值]

0             *tm_year*(年)    比如：2013
1             *tm_mon*(月)        1~12
2             *tm_mday*(日)       1~31
3             *tm_hour*(小时)     0~23
4             *tm_min*(分钟)       0~59
5             *tm_sec*(秒)           0~59
6             *tm_wday*(周)        0~6 (0是周日，依此类推)
7             *tm_yday*              (一年中第几天，1~366)
8             *tm_isdst*(夏令制) (默认为-1)

[^提示]: 提示 这些属性中的年月日和时间是最长用的，一定要记牢！

**下面讲time模块的常用函数：

1. **time.localtime([secs])** ：

   这个函数的作用是将时间戳，转换成当前时区的时间结构，返回的是一个元组。secs参数如果没有提供的话，系统默认会以当前时间做为参数。

2. **time.time()** 

   这个模块的核心之一就是time()，它会把从纪元开始以来的秒数作为一个float值返回。

3. **time.ctime()** 

   将一个时间戳，转换为一个时间的字符串。

4. **time.sleep()** 

   经常在写程序的想让程序暂停一下再运行，这个时间sleep()方法就派上用场了，它可以让程序休眠，参数是以秒计算。

5. **time.clock()** 

   返回[浮点数](http://www.iplaypy.com/jichu/int.html)，可以计算程序运行的总时间，也可以用来计算两次clock()之间的间隔。

6. **time.strftime()**

   将strume_time这个元组，根据你规定的格式，输出字符串。

## 三、python time源代码演示

![Python time模块代码演示](http://www.iplaypy.com/uploads/allimg/131214/1-131214112119C4.jpg)
**Python time模块代码演示**

注意：上面黑色背景是代码部分，下面灰色部分是运行的结果。

```
#coding UTF-8
import time

print(time.time())
print(time.ctime())
print(time.localtime())
print(time.asctime())
print(time.strftime('%Y-%m-%d',time.localtime()))
time.sleep(2)
print(time.process_time())
```

[^注]: time.clock过时

## 四、python time模块注意事项

在类[Linux系统](http://www.iplaypy.com/linux/)上我们使用time模块的time()方法，会比用clock()方法，精度更高一些，在Windows系统中用time.clock()能获得更准确的时间。这是因为每个系统平台，它们彼此的系统时钟实现方式不同。

