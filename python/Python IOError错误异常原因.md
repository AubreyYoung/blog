# Python IOError错误异常原因

python语言IOError错误一般多发生在对文件操作报错时，表示要打开的文件不存在，当然能引发IOError错误错误异常的原因也并不只有这一种情况。下面来列举一些常会引发IOError错误的示例，并简单的说下**解决IOError错误的方法**。

1、**python ioerror**的出现：打开一个不存在的文件，示例中有意输入了一个不存在的文件名，并试图打开它。程序找不到这个文件名所以引发了IOError

```
`Traceback (most recent call last):``  ``File` `"<stdin>"``, line ``1``, ``in` `<module>``IOError: [Errno ``2``] No such ``file` `or` `directory: ``'a.txt'`
```

2、文件写入时遇到python error错误原因？有同学遇到了IOError Errno 0 错误的情况，在用a+方式打开文件，之后读取该文件内容。修改读取的内容后重新写入文件，在写入时程序也遇到了IOError错误。这时要注意在读取文件之后记得要把文件关闭，当你需要写入文件时，要再将文件以w+方式打开写入。加深学习[Python open()函数文件打开、读、写基础操作](http://www.iplaypy.com/sys/open.html)，可以减少类似情况发生。

3、当你不能满足被访问文件所设置的权限时，也会引发IO Error错误，类似这样IOError: [Errno 13] Permission denied: 'c:/a.txt'     python permission denied 从字面意思来理解就可以知道原因了，是因为我们执行的命令（运行python文件等），没有权限，给一个超级管理员权限就可以了。

以上是可以引发python ioerror错误异常最常见原因中几种，还有很多情况报这个内建异常类名。[常见的Python语言异常错误类型](http://www.iplaypy.com/jinjie/jj158.html)还有哪些？仔细理解错误提示的内容，英文不好的同学可以去翻译一下，就能很容易的知道问题所在并解决这个问题。