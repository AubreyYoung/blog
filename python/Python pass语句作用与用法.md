# Python pass语句作用与用法

[Python](http://www.iplaypy.com/)中的**pass语句作用是什么**？表示它不做任何事情，一般用做占位语句。pass语句具体作用及使用方法，我们往下看。

![Python pass语句使用方法](http://www.iplaypy.com/uploads/allimg/160127/2-16012H13241109.jpg)

## pass语句在函数中的作用

当你在编写一个程序时，执行语句部分思路还没有完成，这时你可以用pass语句来占位，也可以当做是一个标记，是要过后来完成的代码。比如下面这样：
\>>>def iplaypython():
\>>>       pass
定义一个[函数](http://www.iplaypy.com/jichu/function.html)iplaypython，但函数体部分暂时还没有完成，又不能空着不写内容，因此可以用pass来替代占个位置。

## pass语句在循环中的作用

pass也常用于为复合语句编写一个空的主体，比如说你想一个[while语句](http://www.iplaypy.com/jinjie/while.html)的无限循环，每次迭代时不需要任何操作，你可以这样写：
\>>>while True:
\>>>    pass
以上只是举个例子，现实中最好不要写这样的代码，因为执行代码块为pass也就是空什么也不做，这时python会进入死循环。

## pass语句用法总结

1、空语句，什么也不做
2、在特别的时候用来保证格式或是语义的完整性