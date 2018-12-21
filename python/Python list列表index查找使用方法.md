# Python list列表index查找使用方法

本文主要讲**列表的index方法**，当你需要知道某个值在[**Python列表list**](http://www.iplaypy.com/jichu/list.html)中的索引位置时候，你可以使用index()方法，其返回值是要查值的索引。

## pyton list index()方法标准格式

index()方法和列表或是其它[python内置数据类型](http://www.iplaypy.com/jichu/data-type.html)方法的调用格式一样：

[变量](http://www.iplaypy.com/jichu/var.html)名.方法(参数)

## 查找演示操作
```
>>> a = ['www','iplaypython','com']   #新建设变量名a的列表
>>> a.index('iplaypython')			  #查找字符串‘iplaypython’在列表a中的位置
1									  #返回1，表示要查找参数在列表中的索引下标位置是1
```
再来查找一个不存在的参数，看看会有什么样结果

```
>>> a.index('hello')
Traceback (most recent call last):
File "<stdin>", line 1, in <module>
ValueError: 'hello' is not in list
```
当查找字符串‘iplaypython’时，返回了它的索引位置；而查找'hello'时则引发了一个[错误异常](http://www.iplaypy.com/jichu/exception.html)，并报错说'hello' is not in list，字符串'hello'不在列表中。

## 总结

用列表的index()方法查找参数时：如果参数存在，返回索引位置；如果参数不存在，则报错。