# Python 列表list的append添加方法

**Python列表append添加方法**是本文主要为初学者们讲解的知识点。[*python列表list*](http://www.iplaypy.com/jichu/list.html)添加方法常用有三种，还有extend、[python insert](http://www.iplaypy.com/jinjie/list-insert.html)都是可以实现把元素添加到列表中，但与append添加方法从使用方法和效果上都是有很大区别的，我们会把这两种方法单独做讲解。先来看看最常用的append方法如何操作。

## python 列表append添加方法格式

列表append添加方法的调用方式和一般方法调用方式是一样的：
对象.方法(参数)
对象放在方法前，之后用点号隔开，括号内填写参数。

## python append添加操作方法

```
>>> a = [1,2,3]
>>> a.append(4)
>>> a
[1,2,3,4]
```
用列表append方法把参数[数字整型](http://www.iplaypy.com/jichu/int.html)4添加到[变量](http://www.iplaypy.com/jichu/var.html)a中，输出a得到添加后的结果；如果有需要添加的参数[python基本数据类型](http://www.iplaypy.com/jichu/data-type.html)可以是[字符串](http://www.iplaypy.com/jichu/str.html)，列表，[元组](http://www.iplaypy.com/jichu/tuple.html)，[字典](http://www.iplaypy.com/jichu/dict.html)等。

## 列表append添加方法与extend、insert有什么不同？

append列表添加方法被调用后，返回的列表不仅仅是一个添加过元素后的新列表，而是把原有的列表做了修改，id不变。并且新添加的元素是追加到原列表数据的末尾，append方法也被叫做列表追加操作。
只要知道append方法与extend、insert各自有哪些特性，就知道它们有什么不同和更适合用在什么地方。

