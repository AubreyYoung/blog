# Python global全局变量语句使用方法

玩蛇网在讲到[python](http://www.iplaypy.com/)作用域时一定要讲讲**global语句的作用及在函数中的使用方法**。global语句可以起到声明变量作用域，可以理解为能修改重新定义**全局变量**的作用。

![python global全局变量](http://www.iplaypy.com/uploads/allimg/160219/2-160219154544922.jpg)

什么是[python 变量定义](http://www.iplaypy.com/jichu/var.html)？

接下玩蛇网python学习分享平台来详细的说一下global语句在[函数](http://www.iplaypy.com/jichu/function.html)中的使用方法。

## global语句的作用

在编写程序的时候，如果想为一个在函数外的变量重新赋值，并且这个变量会作用于许多函数中时，就需要告诉python这个变量的作用域是全局变量。此时用global语句就可以变成这个任务，也就是说没有用global语句的情况下，是不能修改全局变量的。

## 如何使用global语句

用global语句的使用方法很简单，基本格式是：关键字global，后跟一个或多个变量名
```
>>>x = 6
>>>def func():
>>>    global x
>>>    x = 1
>>>
>>>func()
>>>print x
1
```
用print语句输出x的值，此时的全局变量x值被重新定义为1

python中的global语句是被用来声明是全局的，所以在函数内把全局变量重新赋值时，这个新值也反映在引用了这个变量的其它函数中。
```
>>>def fun2():
>>>    return x
>>>fun2()
>>>print x
1
```
这里看到fun2函数return返回值是全局变量x，想下它的值为什么是这个？

当然如果有需要可以使用同一个global语句，指定多个全局变量，只要在变量名之间用逗号分开就好。