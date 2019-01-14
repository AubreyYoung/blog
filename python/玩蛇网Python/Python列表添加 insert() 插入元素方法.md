# Python列表添加 insert() 插入元素方法

**列表insert()方法**是用来将对象插入到[python列表](http://www.iplaypy.com/jichu/list.html)中，相当于列表添加操作。insert()也是列表list众多内建函数中的一种，属于常用的基础方法。

## 特点

与[列表extend()追加方法](http://www.iplaypy.com/jinjie/list-extend.html)和[python append](http://www.iplaypy.com/jinjie/list-append.html)不同，insert()方法是可以将要添加的对象，插入到指定的位置中。

## 标准格式

list.insert(index,obj)
列表与方法之间用点号相隔，括号内需要添入的参数分别是索引和要插入的元素。

## python 列表insert()操作方法

首先新建一个新列表numbers=[1,2,3,4,6,7,8,9] ，要将[字符串](http://www.iplaypy.com/jichu/str.html)‘ls’插入到列表中，操作方法如下图：
```
>>> num = [1,2,3,4,5,6,7]
>>> num.insert(3,'ls')
>>> print(num)
[1, 2, 3, 'ls', 4, 5, 6, 7]
```
insert()方法是一个偏技巧型的方法，使用的时候需要注意索引参数的正解性。