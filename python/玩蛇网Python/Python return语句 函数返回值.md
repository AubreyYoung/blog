# Python return语句 函数返回值

**return语句**是从[python 函数](http://www.iplaypy.com/jichu/function.html)返回一个值，在讲到定义函数的时候有讲过，每个函数都要有一个返回值。Python中的return语句有什么作用，今天就来仔细的讲解一下。

python 函数返回值 return，函数中一定要有return返回值才是完整的函数。如果你没有[python 定义函数](http://www.iplaypy.com/jichu/function.html)返回值，那么会得到一个结果是None对象，而None表示没有任何值。

![Python return语句使用方法](http://www.iplaypy.com/uploads/allimg/160127/2-16012G52444a0.jpg)

## 函数中的return语句和print语句的区别

return是返回数值的意思，比如定义两个函数，一个是有返回值，另一个用[print语句](http://www.iplaypy.com/jichu/print.html)，看看结果有什么不同。

def fnc1(x,y):
​       print x+y

当函数没有显式return，默认返回None值，你可以测试一下：

\>>> result = fnc1(2, 3)
\>>> result is None
True

另一个有返回值return的函数

def fnc2(x,y):
​       return x+y #python函数返回值
```
>>> result =fnc2(3,3)
>>> print (result)
```
传入参数后得到的结果不是None值，可以用同样方法测式。

return的用法没有什么特别之处，玩蛇网python初学者只要记住函数要有返回值就可以了，可以多做练习，对知识点的掌握很有帮助。