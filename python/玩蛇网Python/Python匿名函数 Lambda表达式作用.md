# Python匿名函数 Lambda表达式作用

在Python这门优美的编程语言中，支持一种有趣的语法格式(表达式)，可以让我们在单行内创建一个最小的[函数](http://www.iplaypy.com/jichu/function.html)—**python lambda匿名函数**。

据说是借鉴了Lisp语言中lambda表达式，它可以使用在任何需要使用函数的地方，因为没有名字所以叫做匿名函数，所以不会污染python代码的命名空间。

玩蛇网斯巴达今天就来讲一讲关于*Python Lambda表达式*的相关知识，提示：想要精通或者深入学习了解lambda的妙用，还需要在更多实践作业中积累经验，加入自己的理解才能更好掌握。

## Python Lambda表达式



在Python语言中除了[def语句](http://www.iplaypy.com/jichu/function.html)用来定义函数之外，还可以使用**匿名函数lambda**，它是Python一种生成函数对象的表达式形式。匿名函数通常是创建了可以被调用的函数，它返回了函数，而并没有将这个函数命名。lambda有时被叫做匿名函数也就是这个原因，需要一个函数，又不想动脑筋去想名字，这就是匿名函数。

```
`#-*- coding:utf-8 -*-``#__author__ = "www.iplaypy.com"` `# 普通python函数``def` `func(a,b,c):``    ``return` `a``+``b``+``c` `print` `func(``1``,``2``,``3``)``# 返回值为6` `# lambda匿名函数``f ``=` `lambda` `a,b,c:a``+``b``+``c` `print` `f(``1``,``2``,``3``)``# 返回结果为6`
```

\# 大家注意观察上面的Python示例代码，f = lambda a,b,c:a+b+c 中的关键字lambda表示匿名函数，
\# 冒号:之前的a,b,c表示它们是这个函数的参数。
\# 匿名函数不需要[return](http://www.iplaypy.com/jinjie/return.html)来返回值，表达式本身结果就是返回值。

## Python匿名函数作用

lambda是一个表达式，而并非语句

因为lambda是一个表达式，所以在python语言中可以出现在def语句所不能出现的位置上；
lambda与def语句相比较，后者必须在一开始就要将新函数命名；而前者返回一个新函数，可以有选择性的[赋值变量名](http://www.iplaypy.com/jichu/var.html)。

lambda主体只是单个表达式，并而一个代码块

lambda与普通函数function定义方法来比较它的功能更小，它只是一个为简单函数所服务的对象，而def能处理更大型的数据任务。

为什么要使用lambda？

用python学习手册中的一段话来回答这个问题非常好“lambda有起到速写函数的作用，允许在使用的代码内嵌入一个函数的定义。在仅需要嵌入一小段可执行代码的情况 下，就可以带来更简洁的代码结构。”lambda的使用在python基础知识学习中就会遇到，但真正应用时还是在python进阶的阶段，这时需要你做更深入学习。

## Lambda Python 3

Python2与Python3中lambda使用没有差别，对于单行代码函数，用lambda会让代码更简洁优美，提高性能。

以上只是玩蛇网python学习与分享平台，为大家对Python Lambda表达式的作用做了一个简单的介绍，它的使用技巧和注意事项还有很多。但不要把lambda想象的很可怕，在python中你只要把它当做是个关键字，一个用来引入表达式的语法而已。除去以上的不同之处，def和lambda可以完相同的工作，它也比你想象中更容易使用。