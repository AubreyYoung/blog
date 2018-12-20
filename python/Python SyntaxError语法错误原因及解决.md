# Python SyntaxError语法错误原因及解决

**Python SyntaxError语法错误原因及解决方法**，Python中的SyntaxError错误是常见Python语言异常错误类型中的一种，表示语法错误，一般是代码出现错误才会报SyntaxError错误。

下面示例是SyntaxError被引发，并告知了检测到的[错误异常](http://www.iplaypy.com/jichu/exception.html)位置：

```
`>>> priint ``'www.iplaypy.com'``  ``File` `"<stdin>"``, line ``1``    ``priint ``'www.iplaypy.com'``                               ``^``SyntaxError: invalid syntax`
```

看示例中python错误提示最后一行SyntaxError: invalid syntax，表示语法错误：无效的语法。

**SyntaxError错误解决方法**：解决SyntaxError错误办法很简单，知道它代表的意思是语法错误，那就要检查一下代码拼写是否有错。

其实Python语言异常错误提示还是非常人性化的，它会帮你检测哪里出现了问题，就像示例中的 File "<stdin>", line 1，其实就是告诉了你出现问题的位置。

```
`>>> ``print` `'www.iplaypy.com'``www.iplaypy.com`
```

上面示例中的[print语句](http://www.iplaypy.com/jichu/print.html)拼写错误，只要正确拼写就可以解决SyntaxError错误了。[python ioerror](http://www.iplaypy.com/jinjie/ioerror.html)通常是很容易可以解决的。