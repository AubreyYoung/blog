# Python OS模块常用功能 中文图文详解

![Python os模块](http://www.iplaypy.com/uploads/allimg/160301/2-16030121091L03.jpg)

[TOC]

## 一、Python OS模块介绍

OS模块简单的来说它是一个Python的[系统编程](http://www.iplaypy.com/sys/)的操作模块，可以处理文件和目录这些我们日常手动需要做的操作。

### 可以查看OS模块的帮助文档：

\>>> import os #导入os模块
\>>> help(os)   #查看os模块帮助文档，里面详细的模块相关函数和使用方法

## 二、OS模块重要[函数](http://www.iplaypy.com/jichu/function.html)和[变量](http://www.iplaypy.com/jichu/var.html):


1 )、os.sep 更改[操作系统](http://www.iplaypy.com/sys/)中的路径分隔符。
2 )、os.getcwd()获取当前路径，这个在[Python代码](http://www.iplaypy.com/code/)中比较常用。
3 )、os.listdir() 列出当前目录下的所有文件和文件夹。
4 )、os.remove() 方法可以删除指定的文件。
5 )、os.system() 方法用来运行shell命令。
6 )、os.chdir() 改变当前目录，到指定目录中。

## 三、OS模块函数作用详解

os.system函数可以运行shell命令，[Linux系统](http://www.iplaypy.com/linux/)中就是终端模拟器中的命令。
也有一些函数可以执行外部程序，包括exe()，它会退出Python解释器，并且将控制权交给被执行的程序。

os.sep变量主要用于系统路径中的分隔符。
Windows系统通过是“\\”，Linux类系统如Ubuntu的分隔符是“/”，而苹果Mac OS系统中是“:”。

## 四、OS模块案例代码演示

```
#coding=UTF-8
import os
print(os.getcwd())
print(os.listdir('D:\\'))
print(os.mkdir('D:\\test'))
print(os.mkdir('D:\\c'))
print(os.rmdir('D:\\test'))

print(os.rename('D:\\test1.txt','D:\\test2.txt'))
```



说明：以上玩蛇网Leo只做了几种简单的os模块操作目录和[文件](http://www.iplaypy.com/sys/open.html)的演示，如果有兴趣了解更复杂、更巧妙的方法可以参加我们的[Python培训课程](http://peixun.iplaypython.com/)。

总结：**OS模块**在系统文件和目录操作中使用的比较多，也是我们的常用模块，大家一定要掌握的知识，这是Python标准库中一个典型的跨平台模块，支持Windows和Linux等系统操作，无需修改任何代码，也不会产生错误。