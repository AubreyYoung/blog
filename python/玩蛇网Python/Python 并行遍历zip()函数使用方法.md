# Python 并行遍历zip()函数使用方法

今天我们要讲主题是**python并行遍历zip()函数使用方法**。在讲[range()函数使用方法](http://www.iplaypy.com/jinjie/range.html)时我们知道了，range()可以在[for循环](http://www.iplaypy.com/jinjie/for.html)中是以非完备的方式遍历序列，那么zip()并行遍历又是怎么工作的呢？它和[python遍历元祖](http://www.iplaypy.com/jichu/tuple.html)有什么样的不同呢，下面一起来看下。

zip()函数在运算时，会以一个或多个[序列](http://www.iplaypy.com/jinjie/jj106.html)做为参数，返回一个元组的列表。同时将这些序列中并排的元素配对。

## zip()基本操作方法

例如，有两个列表：
```
a = [1,2,3]
b = [4,5,6]
```
使用zip()函数来可以把列表合并，并创建一个元组对的列表
```
zip(a,b)
[(1, 4), (2, 5), (3, 6)]
```
在python 3.0中zip()是可迭代对象，使用时必须将其包含在一个list中，方便一次性显示出所有结果
```
list(zip(a,b))
[(1, 4), (2, 5), (3, 6)]
```
zip()参数可以接受任何类型的序列，同时也可以有两个以上的参数;当传入参数的长度不同时，zip能自动以最短序列长度为准进行截取，获得元组。
```
>>> l1,l2,l3 = (1,2,3),(4,5,6),(7,8,9)
>>> zip(l1,l2,l3)
[(1, 4, 7), (2, 5, 8), (3, 6, 9)]
>>> str1 = 'abc'
>>> str2 = 'def123'
>>> zip(str1,str2)
[('a', 'd'), ('b', 'e'), ('c', 'f')]
```
## 搭配for循环，支持并行迭代操作方法

zip()方法用在for循环中，就会支持并行迭代：
```
l1 = [2,3,4]
l2 = [4,5,6]
 
for (x,y) in zip(l1,l2):
    print(x,y,'--',x*y)
 
2 4 -- 8
3 5 -- 15
4 6 -- 24
```
其实它的工作原理就是使用了zip()的结果，在for循环里解包zip结果中的元组，用元组赋值运算。就好像(x,y)=(2,6)，[赋值、序列解包操作](http://www.iplaypy.com/jinjie/jj105.html)。在对文件的操作中我们也会用到遍历，例如[Python遍历文件夹目录与文件操作](http://www.iplaypy.com/sys/s104.html)，就是很方便实用的。