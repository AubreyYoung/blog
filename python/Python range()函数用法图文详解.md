# Python range()函数用法图文详解

**python内置range()函数的作用是什么**？它能返回一系列连续增加的[整数](http://www.iplaypy.com/jichu/int.html)，它的工作方式类似于分片，可以生成一个[列表](http://www.iplaypy.com/jichu/list.html)对象。range[函数](http://www.iplaypy.com/jichu/function.html)大多数时常出现在[for循环](http://www.iplaypy.com/jinjie/for.html)中，在for循环中可做为索引使用。其实它也可以出现在任何需要整数列表的环境中，在python 3.0中range函数是一个迭代器。

## python range函数使用方法

range()函数内只有一个参数，则表示会产生从0开始计数的整数列表：
```
>>> range(4)
[0, 4] #python 返回值
range(0,4)		#Python3.x显示结果
```
python range中，当传入两个参数时，则将第一个参数做为起始位，第二个参数为结束位：
```
>>> range(0,5)
[0, 5]
range(0,5) 		#Python3.x显示结果
```
range()函数内可以填入三个参数，第三个参数是步进值（步进值默认为1）：
```
>>> range(0,10,3)
[0, 3, 6, 9]
range(0,10,3)	#Python3.x显示结果
```
range函数的参数和结果也并非一定要是正数或是递增的，好比下面两个例子：
```
>>> range(-4,4)
[-4, -3, -2, -1, 0, 1, 2, 3]
range(-4, 4)	#Python3.x显示结果
>>> range(4,-4,-1)
[4, 3, 2, 1, 0, -1, -2, -3]
range(4,-4,-1)	#Python3.x显示结果
```
## range()在for循环中的作用及技巧

range可以根据给定的次数，重复动作，来看一个range与for循环最简单的例子：


在一些时候也会用range间接的来迭代序列，一般是你想在for循环中使用手动索引才会这样做：
```
>>> x = 'iplaypython'
>>> for i in x:
...     print(i)
...
i
p
l
a
y
p
y
t
h
o
n


>>> for i in range(len(x)):
...     print(x[i])
...
i
p
l
a
y
p
y
t
h
o
n

>>> for i in range(len(x)):
...     print(i)
...
0
1
2
3
4
5
6
7
8
9
10
```
需要注意，第二种方式range(len(x))分部的值是什么，为什么还需要x[i]呢？这都是需要值得去思考的问题。想知道切片和len()更详细的信息，请查看什么是序列。