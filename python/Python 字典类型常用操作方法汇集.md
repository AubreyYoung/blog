# Python 字典类型常用操作方法汇集

本篇文章内容适合开始学习python有一小段时间，最少是学过[python基础](http://www.iplaypy.com/jichu/)知识的同学们。

**字典类型常用操作方法有哪些**？

集合了python语言中字典数据类型的一些常见又实用的操作方法，对加深字典的学习很有帮助。

## 字典类型常用操作方法如下：

1、空字典：d={ }

2、新建字典：d = { 'key' : 'Value' }

3、嵌套：d = { 'fruit' :{ 'apple':2 , 'bananas':6}}

==4、创建并返回一个新字典：d = dict.fromkeys(sequence,value=None)，以序列sequence中元素做字典的键key，value为字典所有键对应的初始值(默认为None)。==

5、以键为索引，访问键对应的值：d[ 'key' ]

6、成员关系：‘key name’ in d ，判断键名是否在字典中，返回值为True / False

==7、包含字典所有键的列表：d.keys()==

==8、包含字典所有值的列表：d.values()==

9、生成一个字典容器：d.items() ，[python dict iteritems](http://www.iplaypy.com/jinjie/items-iteritems.html)

10、字典副本：d.copy()

11、访问字典项的方法：d.get( key , defaults) ，[字典get()操作方法](http://www.iplaypy.com/jinjie/dict-get.html)

12、合并字典：d.update(d2)

13、[python 字典删除key ](http://www.iplaypy.com/jinjie/jj116.html)
​	方法一：d.pop(key)
​	方法二：del d[key]

14、项的数量：len(d)

另有一些python 3.0字典视图及字典解析操作方法，请关注玩蛇网python教学课程。