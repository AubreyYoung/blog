# Python help函数命令怎么使用

**help函数**是[python](http://www.iplaypy.com/)的一个内置函数，在python基础知识中介绍过什么是内置函数，它是python自带的函数，任何时候都可以被使。help函数能作什么、怎么使用help函数查看[python模块学习](http://www.iplaypy.com/module/)中函数的用法，和使用help函数时需要注意哪些问题，下面来简单的说一下。

![python help函数使用方法](http://www.iplaypy.com/uploads/allimg/160127/2-16012H12T6392.jpg)

## help函数能作什么

在使用python来编写代码时，会经常使用[python 调用函数](http://www.iplaypy.com/jichu/function.html)自带函数或模块，一些不常用的函数或是模块的用途不是很清楚，这时候就需要用到help函数来查看帮助。

这里要注意下，help()函数是查看函数或模块用途的详细说明，而dir()函数是查看函数或模块内的操作方法都有什么，输出的是方法列表。

## 怎么使用help函数查看python模块中函数的用法

help( )括号内填写参数，操作方法很简单。

## 使用help函数查看帮助时需要注意哪些问题

在写help()函数使用方法时说过，括号中填写参数，那在这里要注意参数的形式：

1、查看一个模块的帮助
\>>>help('sys')
之后它回打开这个模块的帮助文档

2、查看一个数据类型的帮助
\>>>help('str')
返回字符串的方法及详细说明

\>>>a = [1,2,3]
\>>>help(a)
这时help(a)则会打开list的操作方法
\>>>help(a.append)
会显示list的append方法的帮助