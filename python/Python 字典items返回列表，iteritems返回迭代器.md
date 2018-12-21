# Python 字典items返回列表，iteritems返回迭代器

字典items()方法和iteritems()方法，是python字典的内建[函数](http://www.iplaypy.com/jichu/function.html)，分别会返回[Python列表](http://www.iplaypy.com/jichu/list.html)和迭代器，下面一起来看下字典items()和iteritems()的具体操作方法。

## 作用

**python字典的items方法作用**：是可以将字典中的所有项，以列表方式返回。如果对字典项的概念不理解，可以查看[Python映射类型字典](http://www.iplaypy.com/jichu/dict.html)基础知识一文。因为字典是无序的，所以用items方法返回字典的所有项，也是没有顺序的。
**python字典的iteritems方法作用**：与items方法相比作用大致相同，只是它的返回值不是列表，而是一个迭代器。

## 调用格式

字典items()与iteritems()都是函数，调用标准格式和其它函数格式是一样的：[变量](http://www.iplaypy.com/jichu/var.html).方法()

## 操作方法

字典items()操作方法：
```
>>> x = {'title':'python web site','url':'www.iplaypy.com'}
>>> x.items()
[('url', 'www.iplaypy.com'), ('title', 'python web site')]
```
从结果中可以看到，items()方法是将字典中的每个项分别做为元组，添加到一个列表中，形成了一个新的类容器。如果有需要也可以将返回的结果赋值给新变量，这个新的变量就会是一个类。
```
>>> x = {'title':'python web site','url':'www.iplaypy.com'}
>>> x.items()
dict_items([('title', 'python web site'), ('url', 'www.iplaypy.com')])
>>> a=x.items()
>>> type(a)
<class 'dict_items'>
```
dict iteritems()操作方法：==Python 3.7已无此用法==
```
>>> f = x.iteritems()
>>> f
<dictionary-itemiterator object at 0xb74d5e3c>
>>> type(f)
<type 'dictionary-itemiterator'>    #字典项的迭代器
>>> list(f)
[('url', 'www.iplaypy.com'), ('title', 'python web site')]
```
字典.iteritems()方法在需要迭代结果的时候使用最适合，而且它的工作效率非常的高。