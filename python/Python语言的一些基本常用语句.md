# Python语言的一些基本常用语句

在学习玩蛇网[python](http://www.iplaypy.com/)教程高级篇之前，大家接触过许多python语句，在本文中我们将Python一些基本的常用语句做了汇总，并简单介绍下这些python常用语句的用途和标准格式，放在一起方便大家参考回顾。

(1)、赋值：创建变量引用值
```
a,b,c='aa','bb','cc'
```
(2)、调用：执行函数
```
log.write('spam,name')
#打印、输出：调用打印对象，[print 语句]
print('abc')
```
(3）if、elif、else：选择条件语句，[if语句](http://www.iplaypy.com/jinjie/if.html)、[else与elif语句](http://www.iplaypy.com/jinjie/else-elif.html)

```
if 'iplaypython' in text:
    print(text)
```

(4）[for](http://www.iplaypy.com/jinjie/for.html)、else：序列迭代

```
for x in list:
    print(x)
```

(5)、[while](http://www.iplaypy.com/jinjie/while.html)、else：一般循环语句

```
while a > b :
    print('hello')
```

(6)、pass：占位符(空）

```
while True:
    pass
```

(7)、[break](http://www.iplaypy.com/jinjie/break.html)：退出循环

```
while True:
    if exit:
        break
```

(8)、[continue](http://www.iplaypy.com/jinjie/continue.html)：跳过当前循环，循环继续

```
while True:
    if skip:
        continue
```

下面的语句是相对比较大的程序中会用到，有关函数、类、异常以及模块，同样只是简单介绍方法用途和格式。

(9)、def：定义[函数](http://www.iplaypy.com/jichu/function.html)和方法

```
def info(a,b,c=3,*d):
    print(a+b+c+d[1])
```

(10)、return：函数返回值

```
def info(a,b,c=3,*d):
    return(a+b+c+d[1])
```

(11)、[python global](http://www.iplaypy.com/jinjie/global.html)：命名空间、作用域

```
x = 'a'
def function():
    global x ; x = 'b'
```

(12)、import：访问、导入模块

```
import sys
```

(13)、from：属性访问

```
from sys import stdin
```

(14)、class：创建对象，[类class定义方法](http://www.iplaypy.com/jichu/class.html)

```
class Person:
    def setName(self,name):
        self.name = name
    def getName(self):
        return self.name
    def greet(self):
        print 'hello,%s' % self.nameclass Person:
    def setName(self,name):
        self.name = name
    def getName(self):
        return self.name
    def greet(self):
        print 'hello,%s' % self.names
```

(15)、try、except、finally：[python 捕获异常](http://www.iplaypy.com/jichu/exception.html)

```
try:
    action()
except:
    print ('action error')
```

(16)、raise：触发异常

```
raise Endsearch (location)
```

(17)、assert：[python 断言](http://www.iplaypy.com/jinjie/assert.html)、检查调试

```
assert a>b ,'a roo small'
```

以上是为有基础的同学们做的方法概要，对于python初学者，可以点击语句查看具体操作方法介绍。

