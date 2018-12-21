# Python 字典get方法，访问项并可以返回设定参数

python语言[字典dict](http://www.iplaypy.com/jichu/dict.html)是无序的，通过键对值来存取访问，这在玩蛇网python字典基础知识中有说过。今天来讲一种同样可以访问到字典项的方法，它就是**Python字典get()方法**。

## 字典get()方法作用 python get的参数

它可以返回设定字典中键名对应的值，这好像没什么稀奇。它的特殊作用是，如果当设定键名并不存在在字典中时，它会返回一个空值None。如果你不喜欢None，可以设定一个自己想要返回参数。

## get()操作方法及参数设置

首先新建一个字典info，用正常键对值的方式访问一个不存在的键，看下会返回什么
```
>>> info = {'name':'kimi'}
>>> print info['age']
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
KeyError: 'age'
```
> 提示我们KeyError，表示要查代的内容不存在

再来用python 字典 get函数同样访问一个不存在的键，再看下get()方法获取的返回值是什么
```
>>> print info.get('age')
None
```
就像我们前面说的一样，字典get()方法访问不存在的键，回返回一个None

现在要来讲讲get()方法的特殊作用了，如果键名不存在，不想返回None就给它设定一个自己想要的返回参数
```
>>> print(info.get('age','键不存在'))
#键不存在,其实这个设定的返回参数，可以当它是一个注释，告诉自己出了什么样的错误。
```
## 总结

字典get()方法，可以访问字典中键对应的值。key存在则返回对应value，键不存在返回None，也可以设定自己的返回参数，设置的方法是：[变量](http://www.iplaypy.com/jichu/)名.get（键名,参数）。