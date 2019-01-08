# Python math模块 数学函数教程

在[Python基础教程](http://www.iplaypy.com/jichu/)中，大家都已经了解了[Python](http://www.iplaypy.com/)有很多运算符可以进行一些数学运算，但是要处理复杂的问题是不是所有[代码](http://www.iplaypy.com/code/)都要自己一行一行的来编写呢？

![python math模块](http://www.iplaypy.com/uploads/allimg/160303/2-160303145F91Y.jpg)

[玩蛇网](http://www.iplaypy.com/)提醒大家，这个时候，最先想到的就应该是[python 模块](http://www.iplaypy.com/module/)有没有这样的内置库，**math模块**提供了很多特别的数学运算功能。

在很多数字运算中，我们都会用到一些特别的常量，例如 圆周率π (pi)和自然常数e，下面我们用*math模块来输出圆周率π (pi)和自然常数e的值*：
```
>>> import math
>>> print("圆周率π: %.30f"%math.pi)  #字符串替换方法，取小数点后30位的值。
>>>
>>> print("自然常数e :%.30f"%math.e) #方法同上，这里我们用print，在python函数体内我们要用python return来返回值。
>>>

输出结果：
圆周率π :  3.141592653589793115997963468544
自然常数e: 2.718281828459045090795598298428
```
math模块处理正号和负号
```
>>> import math
>>> print(math.fabs(-1.1))
>>> print(math.fabs(-1.0))
>>>

输出结果：
1.1
1.0
```
另外，math模块还包含了一些其它的方法，下面只简单列出一些常用的：

1. math.ceil(i)  #这个方法对i向上取整，i = 1.3 ，返回值为2

2. math.floor(i)  #正好与上面相反，是向下取整。i = 1.4，返回1
3. math.pow(a, b)  # 返回a的b次方
4. math.sqrt(i)  #返回i的平方根

其它方法大家可以查看官方库文档，或者用系统命令[help()](http://www.iplaypy.com/jichu/help.html) ，[dir()](http://www.iplaypy.com/jichu/dir.html)来查看更多方法和参数的一些规范。