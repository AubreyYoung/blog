# Python continue控制流语句使用教程

[Python](http://www.iplaypy.com/)中的**python continue**语句作用及使用方法，同其它高级语言中的continue用途基本相同，可以放在[while循环语句](http://www.iplaypy.com/jinjie/while.html)和[for循环](http://www.iplaypy.com/jinjie/for.html)中使用。continue语句要比[break语句](http://www.iplaypy.com/jinjie/break.html)更少被使用，只有当循环体很大并且足够复杂的时候，用continue语句是比较适合的。

![python continue语言使用方法](http://www.iplaypy.com/uploads/allimg/160127/2-16012H04535517.jpg)

## python continue语句作用

简单的总结python continue语句作用：跳过剩余循环体，但并不结束循环，跳到最近所在循环体首行。
在运行一个程序时，如果遇到continue语句，程序会停止当次（当前）循环，python continue语句后边剩余的语句会被忽略，程序回到循环的顶端。

## continue语句工作原理

接着python continue语句作用来讲，在开始下一次迭代之前，如果是条件性的while循环，会验证下条件表达式，而如果是迭代的for循环，就会看看是否还有元素可以进行迭代。只有满足条件了，才会开始下一次程序的执行(下一次迭代)。continue语句在下一次循环前先决条件不能被满足时，整体循环会结束。

## python continue语句在循环中怎么用

下面做个简单的求偶数的例题，来看看continue语句在循环中的具体作用是如何的。

例题要求：求比10小且大于或等于0的偶数，%是求余数的。
```
>>>x = 10
>>>while x:
>>>    x = x-1
>>>    if x % 2 != 0:
>>>        continue
>>>    print x
8
6
4
2
0
```
这道例题的重点在if x % 2 != 0:这里，意思是：如果x对2求余不等于0，则python continue跳过下面的print x部分，并返回循环顶端，开始下一次循环。

玩蛇网提醒你：要思考下print为什么要放在这里，对理解continue的用法很有帮助。

continue语句在初学python的时候不要过多使用，初学python时不会涉及到过繁琐的代码，有很多方法都可以解决问题，不妨多试试不同方法来解决。