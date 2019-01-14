# ==Python __str__类的特殊方法==

[^注]: ==暂未搞明白==

**__str__方法**和__init__方法类似，都是一些特殊方法，所以前后都有双下划线，它用来返回对象的[字符串](http://www.iplaypy.com/jichu/str.html)表达式。

例如，下面是一个时间对象的str方法：

\#玩蛇网提示：代码用来讲解__str__的概念，初学者请先了解类[class的](http://www.iplaypy.com/jichu/class.html)概念。

```
#类内部的一个函数
    def __str__(self):
        return('%.2d:%.2d:%.2d' % (self.hour, self.minute, self.second))
```

当你用print打印输出的时候，Python会调用它的str方法，如下：

```
>>> time = Time(9, 45)
>>> print time
09:45:23
```

在我们编写一个新的Python类的时候，总是在最开始位置写一个初始化方法__init__，以便初始化对象，然后会写一个__str__方法，方面我们调试程序。