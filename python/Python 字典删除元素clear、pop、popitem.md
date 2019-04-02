# Python 字典删除元素clear、pop、popitem

 同其它python内建[数据类型](http://www.iplaypy.com/jichu/data-type.html)一样，[字典dict](http://www.iplaypy.com/jichu/dict.html)也是有一些实用的操作方法。这里我们要说的是**字典删除方法**：clear()、pop()和popitem()，这三种方法的作用不同，操作方法及返回值都不相同。接下来就来查看下这些字典特定方法的具体用法是什么。

## 字典clear()方法

clear()方法是用来清除字典中的所有数据，因为是原地操作，所以返回None（也可以理解为没有返回值）
```
>>> x
{'age': 20, 'name': 'lili'}
>>> returned_value = x.clear()
>>> x
{ }
>>> print(returned_value)
None
```
字典的clear()方法有什么特点：
```
>>> f = {'key':'value'}
>>> a = f
>>> a
{'key': 'value'}
>>> f.clear()
>>> f
{}
>>> a
{}
```
当原字典被引用时，想清空原字典中的元素，用clear()方法，a字典中的元素也同时被清除了。

## 字典pop()方法

移除字典数据pop()方法的作用是：删除指定给定键所对应的值，返回这个值并从字典中把它移除。注意字典pop()方法与[列表pop()方法](http://www.iplaypy.com/jinjie/list-pop.html)作用完全不同。
```
>>> x = {'a':1,'b':2}
>>> x.pop('a')
1
>>> x
{'b': 2}
```
## 字典popitem()方法

字典popitem()方法作用是：随机返回并删除字典中的一对键和值（项）。为什么是随机删除呢？因为字典是无序的，没有所谓的“最后一项”或是其它顺序。在工作时如果遇到需要逐一删除项的工作，用popitem()方法效率很高。
[python iteritems()](http://www.iplaypy.com/jinjie/items-iteritems.html)

```python
>>> x
{'url': 'www.iplaypy.com', 'title': 'python web site'}
>>> x.popitem()
('url', 'www.iplaypy.com')
>>> x
{'title': 'python web site'}
```