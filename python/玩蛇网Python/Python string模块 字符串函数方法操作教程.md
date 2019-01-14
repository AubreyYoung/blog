# Python string模块 字符串函数方法操作教程

我们在[Python](http://www.iplaypy.com/)编程过程中，经常会处理一些[字符串](http://www.iplaypy.com/jichu/str.html)的相关操作，例如：查找、替换、分隔、截取以及英文的大小写转换等，这个时候Python程序员首选的一定是 **string模块** 。

![python srting模块](http://www.iplaypy.com/uploads/allimg/160329/2-160329144620409.jpg)

[TOC]

## 一、string模块简单介绍

它适用于Python1.4以后的版本，当然现在大家一般都在用2.5以上的版本了，string模块基本上可以解决我们需要操作字符串的所有需要。

## 二、string模块字符串处理方法

1 )、英文字符串的大小写转换

```
>>> import string 
```
[^注意]: python2.0以后的版本， string模块不需要再调用了，它的方法改成用S.method()的形式调用，只要变量S是一个字符串对象就可以可以直接使用它的函数方法，不需要额外的 import 再导入。

```
>>> s = "IplayPython"
>>> print(s)
>>> IplayPython 
>>>
>>> s.lower() # 全部字符串转换为小写
>>> 'iplaypython'
>>> s.upper() #全部字符串转换为大写
>>> 'IPLAYPYTHON'
>>>
>>> s.capitalize() #首字母大写
>>> 'Iplaypython'

>>> s.swapcase() # 大小写互换
'iPLAYpYTHON'
>>>
```
还有一个首字母大写的方法叫做 s.title()，大家有兴趣的话可以去测试一下，看一下官方文档，它与上面的首字母大写的capitalize()方法有什么不同之处。


2 )、查找统计和替换字符串
```
>>> s = "IplayPython" #创建字符串
>>>
>>> s.find('I') # 用find方法来查找子串‘I’，如果找到就返回匹配的第一个索引值。
0
>>> s.find('P') # 这个同上
5
>>> s.find('k') # 我们查找字母‘K’，s字符串中没有，所以返回了一个 -1。
-1
>>>
```
另一个方法，叫做 index()方法，与上面功能类似，但是它如果查找的子串不存在，会直接报错，抛出[Python异常](http://www.iplaypy.com/jichu/exception.html)，rindex()方法可以返回匹配的最后一次的索引值。
```
>>> s = "IplayPython"
>>>
>>> s.count('p') # 查找子串在字符串中的匹配次数
1
>>>

>>> s.replace("play", "love") #字符串替换方法，前面第一个参数放需要替换的子串，后面放替换后的内容。
'IlovePython'
>>>

>>> s = "0IplayPython0"
>>> s.strip('0') # strip()方法作用是删除头部和尾部的匹配字符。
'IplayPython'
>>>
```
strip()方法还有几个近亲，lstrip()与rstrip()，左边匹配删除，和右边匹配删除，一般我们用这些功能是删除空格、回车等。

## 三 、string模块使用注意事项

上面玩蛇网介绍了string模块的一些最基本最常用的方法，以后我们会更新更多的关于这个模块的方法和教程。

