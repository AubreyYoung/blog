# Python 集合set()添加删除、交集、并集、集合操作详解

在**Python set**是[基本数据类型](http://www.iplaypy.com/jichu/data-type.html)的一种**集合**类型，它有可变集合(set())和不可变集合(frozenset)两种。创建**集合set**、**集合set添加**、**集合删除**、**交集**、**并集**、**差集**的操作都是非常实用的方法。
玩蛇网python之家提示: 推荐在[Linux系统](http://www.iplaypy.com/linux/)下编写python程序，会养成一个非常好的编码习惯。

## 创建集合set

python set类是在python的sets[模块](http://www.iplaypy.com/module/)中，大家现在使用的python2.7.x中，不需要导入sets模块可以直接创建集合。
\>>>set('boy')
set(['y', 'b', 'o'])

## 集合添加、删除

python 集合的添加有两种常用方法，分别是add和update。
集合add方法：是把要传入的元素做为一个整个添加到集合中，例如：
\>>> a = set('boy')
\>>> a.add('python')
\>>> a
set(['y', 'python', 'b', 'o'])

集合update方法：是把要传入的元素拆分，做为个体传入到集合中，例如：
\>>> a = set('boy')
\>>> a.update('python')
\>>> a
set(['b', 'h', 'o', 'n', 'p', 't', 'y'])

集合删除操作方法：remove
set(['y', 'python', 'b', 'o'])
\>>> a.remove('python')
\>>> a
set(['y', 'b', 'o'])

## python set() 集合操作符号、数学符号

集合的交集、合集（并集）、差集，了解python集合set与[列表list](http://www.iplaypy.com/jichu/list.html)的这些非常好用的功能前，要先了解一些集合操作符号

![python 集合操作符号](http://www.iplaypy.com/uploads/allimg/131215/2-131215203406215.jpg)

简单的演示下差集、交集和合集的概念：
![集合的交集、合集、差集](http://www.iplaypy.com/uploads/allimg/131215/2-13121520401H47.jpg)

可变集合python set是初期python学习中比较能接触到的。像[列表](http://www.iplaypy.com/jichu/list.html)、[字典](http://www.iplaypy.com/jichu/dict.html)、[字符串](http://www.iplaypy.com/jichu/str.html)这类可迭代的对像都可以做为集合的参数。set集合是无序的，不能通过索引和切片来做一些操作。