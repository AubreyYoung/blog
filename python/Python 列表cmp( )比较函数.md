# Python 列表cmp( )比较函数

在讲[列表排序方法](http://www.iplaypy.com/jinjie/jj114.html)时，还有一种列表高级排序方法没有讲，它就是我们今天的主题**列表cmp( )比较函数操作方法**。
cmp( )函数作用：
​	它是一个自定义的比较[函数](http://www.iplaypy.com/jichu/function.html)，cmp()函数通常是做为列表sort( )排序方法的参数使用的，当不想按照sort()函数默认方式排序，需要一个自己排序方式时最适合使用比较函数cmp()。
cmp()函数规则：cmp(x ,y) ，当x<y会返回负数、当x>y会返回正数、当x=y则返回0。
cmp()比较函数定义操作方法：

```
>>> cmp(11,56)
-1
>>> cmp(56,11)
1
>>> cmp(11,11)
0
>>> cmp('abc','b')
-1
```

最后一个例题传入的参数是[字符串](http://www.iplaypy.com/jichu/str.html)，cmp()函数会先比较第一个字符，之后按照顺序比较第二个字符....来判断大小。
与sort()函数搭配使用时，只需要把cmp()函数做为参数添加到sort()中就可以。

```
>>> num = [6,3,8,7] 
>>> num.sort(cmp)
>>> num
[3, 6, 7, 8]
```
在很多情况下cmp参数可以用于sort和sorted函数，在排序时使用cmp()方法是非常有用的。

==Python 3.x中 cmp()均已废弃==