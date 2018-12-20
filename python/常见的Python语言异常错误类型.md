# 常见的Python语言异常错误类型

在运行或编写一个程序时常会遇到[错误异常](http://www.iplaypy.com/jichu/exception.html)，这时[python](http://www.iplaypy.com/)会给你一个错误提示类名，告诉出现了什么样的问题（Python是面向对象语言，所以程序抛出的异常也是类）。能很好的理解这些错误提示类名所代表的意思，可以帮助你在最快的时间内找到问题所在，从而解决程序上的问题是非常有帮助的。

玩蛇网python学习分享平台为大家搜集了一些python最重要的内建异常类名，并做了简单的介绍：

**AttributeErro**r：属性错误，特性引用和赋值失败时会引发属性错误

**NameError**：试图访问的[变量](http://www.iplaypy.com/jichu/var.html)名不存在

**SyntaxError**：语法错误，代码形式错误

**Exception**：所有异常的基类，因为所有python异常类都是基类Exception的其中一员，异常都是从基类Exception继承的，并且都在exceptions [python 模块](http://www.iplaypy.com/module/)中定义。

**IOError**：[python ioerror](http://www.iplaypy.com/jinjie/ioerror.html)，一般常见于打开不存在文件时会引发IOError错误，也可以解理为输出输入错误

**KeyError**：使用了[映射](http://www.iplaypy.com/jichu/dict.html)中不存在的关键字（键）时引发的关键字错误

**IndexError**：索引错误，使用的索引不存在，常索引超出序列范围，[什么是索引](http://www.iplaypy.com/jinjie/jj106.html)、[python list index](http://www.iplaypy.com/jinjie/jj90.html)

**TypeError**：类型错误，内建操作或是函数应于在了错误类型的对象时会引发类型错误

**ZeroDivisonError**：除数为0，在用除法操作时，第二个参数为0时引发了该错误

**ValueError**：值错误，传给对象的参数类型不正确，像是给int()函数传入了[字符串](http://www.iplaypy.com/jichu/str.html)数据类型的参数。