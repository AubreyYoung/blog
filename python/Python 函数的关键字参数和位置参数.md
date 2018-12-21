# Python 函数的关键字参数和位置参数

目前我们python学习过程中用到的参数都是位置参数，显然参数的位置是很重要的。本文我们再来讲一种关键参数，它可以不按照位置传入参数，在大规模的程序中这个关键字参数会比位置参数更有用。**关键字参数和位置参数使用方法有什么不同**？我们往下看。

## 位置参数

先观察下面两个函数，看看什么是位置参数：
```
>>>def a1(x,y,z):
>>>    return(x,y,)
>>>print(a1(1,2,3))
(1,2,3)

>>>def a2(x,y,z):
>>>    return(x,z,y)
>>>print(a2(1,2,3))
(1,3,2)
```
两个函数在定义时的参数名一样，调用时传入的参数也一样，为什么结果不同呢？问题就在return返回的参数位置上。定义函数时参数名的位置，与调用时所传参数位置是相对应的，也就是这两个函数中x=1，y=2，z=3，至于输出结果是什么则由return中的顺序来决定。想一下，如果调用a2函数时传入的参数是（1,3,2）会得到什么样的结果？

位置参数还需要注意：定义函数时写了几个位置参数，在调用传参时就要传入同样数量的参数。==return返回值有很多个时，在输出时会集合为元组展现==。

## 关键字参数

关键字参数有什么用？在程序比较繁琐的时候，参数顺序是很难能记住的，为了让程序简单不出错，会为参数起一个名字，这就是关键字参数的作用。好比下面这个函数：
```
>>>def x(name,Profession):
>>>    return()'%s is %s' %(name,Profession))
>>>print(x(name='Amy',Profession='Student'))
Amy is Student

>>>print x(Profession='Student',name='Amy')
Amy is Student
```
第二次调用x函数时，虽然传参数时把参数位置调换了，但结果还是没有变。这是因为把参数名与值绑定在一起，使用参数名提供的参数叫做关键字参数。

关键字参数还有一个特殊的作用，就是可以在定义函数时设置关键字参数默认值：
```
>>>def info(name='Amy',Profession='Student'):
>>>    return('%s is %s' %(name,Profession))
>>>print(info())
Amy is Student
```
在函数设置了参数默认值是，调用的时候可以不传入参数了。当然你也可在传入一个或是所有的新参数：
```
>>>print(info('lili'))
lili is Student

>>>print(info('lili','Teacher'))
lili is Teacher
```
如果只想提供职业Profession参数，而名字用默认值，应该怎么操作呢？想深入学习的同学们可以关注玩蛇网python学习视频哦。

```
>>> print(info(Profession='BOSS'))
Amy is BOSS
```

