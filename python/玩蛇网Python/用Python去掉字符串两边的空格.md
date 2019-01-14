# 用Python去掉字符串两边的空格

我们经常在处理[字符串](http://www.iplaypy.com/jichu/str.html)时遇到有很多空格的问题，一个一个的去手动删除不是我们程序员应该做的事情，今天这篇技巧的文章玩蛇网就来给大家讲一下，如果**用Python去除字符串两边的空格**。

我们先创建一个左右都有N个空格的字符串[变量](http://www.iplaypy.com/jichu/var.html)，看代码：
```
>>> s = "   iplaypython    "
```
去除字符串空格，在Python里面有它的内置方法，不需要我们自己去造轮子了。

## lstrip
这个字符串方法，会删除字符串s开始位置前的空格。
```
>>> s.lstrip()
'iplaypython   '
```
## rstrip
这个内置方法可以删除字符串末尾的所有空格，看下面演示代码：
```
>>> s.rstrip()
'    iplaypython'
```
## strip
有的时候我们[读取文件](http://www.iplaypy.com/sys/s95.html)中的内容，每行2边都有空格，能不能一次性全部去掉呢，字符符有一个内置的strip()方法可以做到。
```
>>> s = “   iplaypython    ”
>>> s.strip()
'iplaypython'
```
提示：大家可以用 [dir(str)](http://www.iplaypy.com/jichu/dir.html) 这个方法，获得 str字符串的所有方法名单。

