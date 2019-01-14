# Python for循环控制语句一般格式及方法

**for循环语句**是[python](http://www.iplaypy.com/)中的一个循环控制语句，任何有序的序列对象内的元素都可以遍历，比如[字符串](http://www.iplaypy.com/jichu/str.html)、[列表List](http://www.iplaypy.com/jichu/list.html)、[元组](http://www.iplaypy.com/jichu/tuple.html)等可迭代对像。之前讲过的[if语句](http://www.iplaypy.com/jinjie/if.html)虽然和for语句用法不同，但可以用在for语句下做条件语句使用。

![python for循环用法](http://www.iplaypy.com/uploads/allimg/160127/2-16012H1544OC.jpg)

## for语句的基本格式

python for循环的一般格式：第一行是要先定义一个赋值目标（迭代变量），和要遍历（迭代）的对像；首行后面是要执行的语句块。

> for 目标 in 对像:
> ​	print 赋值目标

## for循环一个字符串操作方法
```
>>>a = 'iplaypython.com'
>>>for i in a:
>>>    print i
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
.
c
o
m
```
如果想让目标在一行输出，可以这样写
```
>>>print i,
i p l a y p y t h o n . c o m
```
案例中的 i 相当于目标，字符串变量a是遍历（迭代）对像。当运行for循环语句时，每一次迭代时，i 都会从遍历（迭代）对像a中接收一个新值输出。结束循环后，目标（迭代变量）会保留最后一个值，这里可以先忽略理解，会在else语句中详细来讲解。

## for循环列表操作方法
```
>>>a = [1,2,3,4]
>>>for i in a:
>>>    print i,
1 2 3 4
```
## for循环元组赋值
```
>>>x =[('hello','python'),('very','good')]
>>>for (a,b) in x:
>>>    print (a,b)
('hello', 'python')
('very', 'good')
```
Python for循环控制语句基本组成部分还有break、continue、else，每一种都会有单独文章来介绍。