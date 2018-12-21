# Python 字典setdefault()方法步骤

**字典dictr的setdefault()方法如何使用？**是本文主要为大家讲解的内容。

在[python基础知识](http://www.iplaypy.com/jichu/)中有说过，[字典](http://www.iplaypy.com/jichu/dict.html)是可变的[数据类型](http://www.iplaypy.com/jichu/data-type.html)，其参数又是键对值。setdefault()方法和字典的get()方法在一些地方比较相像，都可以得到给定键对应的值。但setdefault()方法可以在字典中并不包含有给定键的情况下，为给定键设定相应的值。

在学习python字典操作方法时，感觉setdefault()方法，比字典的其它基本操作方法更难理解的同学比较多，仔细看下面[注释](http://www.iplaypy.com/jichu/note.html)文字内容就会容易理解很多了。
```
>>> a = { }                            #新建一个空字典
>>> a['name'] = 'amy'             	   #为字典添入参数
>>> a                                  #输出字典a
{'name': 'amy'}
>>> a.setdefault('name','lili')    	   #因为键名name存在，则返回键对应的值‘amy’
'amy'
>>> a.setdefault('name1','lili')       #因键名name1不存在，程序把('name1','lili')当做项添加到字典a中，并返回其值。
'lili'
>>> a
{'name': 'amy', 'name1': 'lili'}

setdefault(key[, default])是字典setdefault()方法的标准格式，默认值为None
>>> x = { }
>>> x.setdefault('www.iplaypy.com')
>>> x
{'www.iplaypy.com': None}
```

