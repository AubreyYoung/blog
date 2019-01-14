# Python list列表extend()使用方法

[Python列表](http://www.iplaypy.com/jichu/list.html)的基本操作方法，之前有介绍过[列表list的append()方法](http://www.iplaypy.com/jinjie/list-append.html)，今天来介绍列表的另一种非常有用的extend()方法。list的extend()方法是把新参数添加到原有列表中，id不变，相当于原地修改。

## extend()使用方法

与一般[函数](http://www.iplaypy.com/jichu/function.html)调用格式一样，变量名.方法名(参数)

[python变量命名规则](http://www.iplaypy.com/jichu/var.html)

extend方法可以在列表尾部追加包含多个值的另一个序列，而list的append()只能添加一个值。可以说list的extend方法是有扩展列表的作用：
```
>>> list1 = [1,2,3]
>>> list2 = [7,8,9]
>>> list1.extend(list2)
>>> list1
[1, 2, 3, 7, 8, 9]
```
list2中包含多个元素，被一次性添加到了list1中。

## extend()和加号+连接操作符的区别

这个操作结果和用+号连接操作很像，但两者是有本质区别的。extend方法是把元素添加到了list1中，相当于扩展（修改）list1的数据，但id没有改变。如果用+号连接的话，它返回的是一个新生成的列表：
```
>>> list1 = [1,2,3]
>>> list2 = [7,8,9]
>>> list1 + list2
[1, 2, 3, 7, 8, 9]
>>> list1
[1, 2, 3]
```
list1 + list2虽然看上去显示的结果和extend方法一样，但其实它得到的是一个新列表，不能被引用的值。
如果要引用这个list1 + list2的结果需要将它赋一个变量名，比如：list1 = list1 + list2，此时再输出list1的结果就会是[1, 2, 3, 7, 8, 9]了。但它的工作效果远不如extend方法高。