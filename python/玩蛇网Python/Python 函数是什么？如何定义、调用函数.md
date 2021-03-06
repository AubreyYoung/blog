# Python 函数是什么？如何定义、调用函数

**函数function**是[python](http://www.iplaypy.com/)编程核心内容之一，也是比较重要的一块。在本文中主要介绍下函数的概念和基础函数相关知识点。函数是什么？有什么作用、定义函数的方法及如何调用函数。

![Python  函数定义与调用](http://www.iplaypy.com/uploads/allimg/160219/2-16021915302Q54.jpg)

## 函数function是什么？函数的作用

函数是可以实现一些特定功能的小方法或是小程序。在Python中有很多内建函数，当然随着学习的深入，你也可以学会创建对自己有用的函数。简单的理解下函数的概念，就是你编写了一些语句，为了方便使用这些语句，把这些语句组合在一起，给它起一个名字。使用的时候只要调用这个名字，就可以实现语句组的功能了。

在没用过函数之前，我们要计算一个数的幂时会用到\**，方法是这样的：
\>>>2\*\*3
8 #此处为[**python 函数返回值**](http://www.iplaypy.com/jinjie/return.html)
现在知道了函数，就可以用内建函数pow来计算乘方了：
\>>>pow(2,3)
8

## 什么是python内建函数，如何调用函数

python系统中自带的一些函数就叫做内建函数，比如：[dir()](http://www.iplaypy.com/jichu/dir.html)、[type()](http://www.iplaypy.com/jichu/type.html)等等，不需要我们自己编写。还有一种是第三方函数，就是其它程序员编好的一些函数，共享给大家使用。前面说的这两种函数都是拿来就可以直接使用的。最后就是我们自己编些的方便自己工作学习用的函数，就叫做自定义函数了。

函数调用的方法虽然没讲解，但以前面的案例中已经使用过了。pow()就是一个内建函数，系统自带的。只要正确使用函数名，并添写好参数就可以使用了。

## 定义函数function的方法

定义函数需要用到def语句，具体的定义函数语法格式如图所示：

> def 函数名(参数):
>
> ​	代码块

定义函数需要注意的几个事项：
​	1、def开头，代表定义函数
​	2、def和函数名中间要敲一个空格
​	3、之后是函数名，这个名字用户自己起的，方便自己使用就好
​	4、函数名后跟圆括号()，代表定义的是函数，里边可加参数
​	5、圆括号()后一定要加冒号: 这个很重要，不要忘记了
​	6、代码块部分，是由语句组成，要有缩进
​	7、函数要有返回值return

下面写个完整个的函数范例给大家参考：

```python
def hello(name):
    return 'hello,'+name+'!'
print (hello('iplaypython.com'))
```
图中我们定义了一个名为hello的新函数，它要实现的是返回一个将参数作为名字的语句。用print来调用这个函数，hello函数()内添入需要的name参数，这里写的是iplaypython.com，当然也可换成你需要的参数。

函数的基础知识点就先讲这些，函数在python学习过程中是一个比较重要的环节，需要学的还有很多。例如参数修改，作用域等等。在高级篇的文章中会更详细的为大家介绍函数function更多要点。 