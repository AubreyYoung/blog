# Python sys模块 argv path常用方法图文详解

**SYS模块**是[Python标准库](http://www.iplaypy.com/module/)中自带了一个模块。

sys模块包括了一组非常实用的服务，内含很多[函数](http://www.iplaypy.com/jichu/function.html)方法和[变量](http://www.iplaypy.com/jichu/var.html)，用来处理Python运行时配置以及资源，从而可以与当前程序之外的系统环境交互，如：[Python解释器](http://www.iplaypy.com/jichu/interpreter.html)。

![python sys模块方法](http://www.iplaypy.com/uploads/allimg/160303/2-16030315012C13.jpg)

[TOC]

## 一、导入sys模块操作

首先，打开终端模拟器进入[Python](http://www.iplaypy.com/jichu/interpreter.html)[解释器](http://www.iplaypy.com/jichu/interpreter.html)或者打开IDE编辑器创建一个新的.py后缀名的Python程序文件。

下面，以解释器中的操作举例：

```
>>> import sys   #导入sys模块
>>> dir(sys)     #dir()方法查看模块中可用的方法
```

[^注意]: 如果是在[编辑器](http://www.iplaypy.com/editor/)，一定要注意要事先声明代码的编码方式，否则中文会乱码。

## 二、sys模块重要函数变量

1. sys.stdin 标准输入流。
2. sys.stdout 标准输出流。
3. sys.stderr 标准错误流。
4. sys.path 查找模块所在目录的目录名列表。

```
>>> sys.path
['', '/usr/local/lib/python37.zip', '/usr/local/lib/python3.7', '/usr/local/lib/python3.7/lib-dynload', '/usr/local/lib/python3.7/site-packages']
```
5. sys.argv 命令行的参数，包括脚本名称。
6. sys.platform 返回当前系统平台，如：win32、Linux等。

## 三、sys常用方法使用说明

sys.exit方法可以退出当前的程序，可以提供一个整数类型，通常我们用0表示功能，做为这个方法的参数，
当然也可以用[字符串](http://www.iplaypy.com/jichu/str.html)参数，表示错误不成功的报错信息。

sys.modules方法可以将模块的名字映射到实际存在的模块上，它只应用于目前导入的模块。

上面有3个模块变量：sys.stdin、sys.stdout、sys.stderr它们都是[类](http://www.iplaypy.com/jichu/class.html)文件(file-like)流对象。

## 四、sys模块案例代码演示

```
#coding=UTF-8
import sys

print('Name is :',sys.argv[0])

print('Path has :',sys.path)

def dump(module):
    print(module,"==>",
    if module in sys.builtin_module_names:
        print("内建模块")
    else:
        module = __import__(module)
        print(module.__file__) )
dump("os")
```

==[^Errors]: print参数值换行未实现，代码报错！！==

**上面是Python sys模块的演示代码，下面灰色部分是输出结果。**

## 五、sys模块教程总结：

玩蛇网的所有教程[Python源代码](http://www.iplaypy.com/code/)都是在LInux的Ubuntu系统中测试运行的，如遇代码不可运行或出错，请加入 QQ群：2041942提问，也可以自行调试，提高自己的动手解决问题的能力。

sys和[os模块](http://www.iplaypy.com/module/os.html)都是我们日常中进行操作系统编辑中经常被用到的，是必知必会的知识，大家要多加练习。