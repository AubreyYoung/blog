# Python random模块sample、randint、shuffle、choice随机函数

**random模块**作用是返回随机数，只要跟随机元素相关的，都可以使用它。

![Python random模块使用方法](http://www.iplaypy.com/uploads/allimg/160127/2-16012G62642162.jpg)
[TOC]
## 一、random模块简介

[Python标准库](http://www.iplaypy.com/module/)中的random函数，可以生成随机浮点数、[整数](http://www.iplaypy.com/jichu/int.html)、[字符串](http://www.iplaypy.com/jichu/str.html)，甚至帮助你随机选择[列表](http://www.iplaypy.com/jichu/list.html)序列中的一个元素，打乱一组数据等。

## 二、random模块重要函数

1. random() 返回0<=n<1之间的随机实数n；

2. choice(seq) 从序列seq中返回随机的元素；
3. getrandbits(n) 以长整型形式返回n个随机位；
4. shuffle(seq[, random]) 打乱指定seq序列；
5. sample(seq, n) 从序列seq中选择n个随机且独立的元素；

## 三、random模块方法说明

**random.random()**

函数是这个模块中最常用的方法了，它会生成一个随机的浮点数，范围是在0.0~1.0之间。

**random.uniform()**

正好弥补了上面函数的不足，它可以设定浮点数的范围，一个是上限，一个是下限。

​	如果a < b，则生成的随机数n: b>= n >= a。

​	如果 a >b，则生成的随机数n: a>= n >= b。

```
>>> print(random.uniform(10,20))
18.515197899622052
>>> print(random.uniform(30,25))
25.346609432144394
```

**random.randint()**

随机生一个整数int类型，可以指定这个整数的范围，同样有上限和下限值。

random.randint(a, b)，用于生成一个指定范围内的整数。其中参数a是下限，参数b是上限，生成的随机数n: a <= n <= b

```
>>> print(random.randint(1, 10))
3

```

**random.choice()**

可以从任何序列，比如list列表中，选取一个随机的元素返回，可以用于字符串、列表、[元组](http://www.iplaypy.com/jichu/tuple.html)等。

**random.shuffle()**

如果你想将一个序列中的元素，随机打乱的话可以用这个函数方法。

```
>>> p = ["Python", "is", "powerful", "simple", "and so on..."]
>>>
>>> random.shuffle(p)
>>>
>>> print(p)
['powerful', 'is', 'and so on...', 'Python', 'simple']

```

**random.sample()**

可以从指定的序列中，随机的截取指定长度的片断，不作原地修改。

```
>>> list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10,11,12]
>>> slice = random.sample(list,6)
>>> print(slice)
[3, 1, 12, 9, 8, 10]
>>> print(list)
[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
```

**random.randrange**

random.randrange([start], stop[, step])，从指定范围内，按指定基数递增的集合中 获取一个随机数。

如：random.randrange(10, 100, 2)，结果相当于从[10, 12, 14, 16, ... 96, 98]序列中获取一个随机数。

## 四、random模块教程总结

玩蛇网python之家提示：[Python](http://www.iplaypy.com/)中任何与随机相关的问题，都可以首先考虑random模块，熟悉掌握其中的常用方法，是一个对程序员的最基本要求。