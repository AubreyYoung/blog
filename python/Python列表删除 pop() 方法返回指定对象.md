# Python列表删除 pop() 方法返回指定对象

**列表的pop()方法**，是[python列表list](http://www.iplaypy.com/jichu/list.html)类型的内建[函数](http://www.iplaypy.com/jichu/function.html)，主要用来做删除列表中的指定对象（如果没有指定对象，默认是最后一个值）。

## 方法特点

一般删除对象方法会直接将元素删除，而pop()方法在删除指定对象时，会返回要删除元素的值。可以理解为一个提示作用，提示你删除的是哪一个元素。

## 调用格式

list.pop(index=-1)
pop()括号内参数是，要删除对象的[python list 索引](http://www.iplaypy.com/jinjie/jj90.html)。如果为空则默认为-1最后一项。

```
>>> a = [1,2,3,4,5]
>>> print(a.pop())
5
>>> print(a)
[1, 2, 3, 4]
```

上图中没有为pop()方法指定索引位置，默认删除了列表中的-1项，也就是最后一个元素5

```
>>> a = [1,2,3,4,5]
>>> print(a.pop(3))
4
>>> print(a)
[1, 2, 3, 5]
```

此图中为pop()指定删除对象的索引位置，要删除列表a中索引3对应的元素。运行结果是输出了索引3的[python int](http://www.iplaypy.com/jichu/int.html)数据整型4，同时删除此元素。