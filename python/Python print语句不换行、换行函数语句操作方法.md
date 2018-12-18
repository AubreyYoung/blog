# Python print语句不换行、换行函数语句操作方法

**print语句**用法很简单，它就是告诉计算机你要做什么操作。python中print语句在开始学习时就会用到，通常情况下想查看[变量](http://www.iplaypy.com/jichu/var.html)结果或是内容时，在代码中会用到print输出；而在[交互式解释器](http://www.iplaypy.com/jichu/interpreter.html)中使用print语句则会显示变量的[字符串](http://www.iplaypy.com/jichu/str.html)，或者查看变量值。听起来好像比较难理解，那下面做几个print语句不换行、换行函数语句操作方法的实例就方便理解了。

## print语句操作方法

创建一个字符串变量a，分别用print，和变量名来显示，看看效果有什么不一样。
```
>>> >>> a = 'iplaypython'
>>>
>>> print a
iplaypython
>>>
>>> a
'iplaypython'
```
print变量名a，是直接输出了变量a的内容。而没用print语句，只用变量名输出的结果是用单引号括起来的。

## print格式化输出（字符串、整数）

python的print语句和字符串操作符%一起结合使用，可以实现替换的可能。方法很巧妙，应用范围也比较多，操作方法如下：
```
>>> print ("%s is %d old" % ("she",20))
she is 20 old
```
这里的%s和%d是占位符，分别是为字符串类型和[整型](http://www.iplaypy.com/jichu/int.html)来服务的。在占位符相关文章中过详细的来讲解。

## print语句自动换行操作

print语句换行与不换行如何操作？
如果想让多个变量数据在同一行显示，操作起来很简单，只需要在变量名后边加逗号就可以了，像下面这样操作：
```
>>> a = 1
>>> b = 2
>>> c = 3
>>> print (a,b,c)
1 2 3
```
在Python 3.0中，print不再是语句而是一个[函数](http://www.iplaypy.com/jichu/function.html)，它的基本功能是不变的。