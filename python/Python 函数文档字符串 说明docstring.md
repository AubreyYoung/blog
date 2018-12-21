# Python 函数文档字符串 说明docstring

**Python的函数文档字符串**是在[函数](http://www.iplaypy.com/jichu/function.html)开头，用来解释其接口的[字符串](http://www.iplaypy.com/jichu/str.html)，
举例说明：

```
`#-*- coding: utf-8 -*-``#测试代码，没有实际用途` `def` `fun_doc(t, n ,length, angle):``    ``"""``    ``绘制n个线段，给定长度和角度，单位是：度。``    ``"""``    ``for` `i ``in` `range``(n):``        ``fd(t, length)``        ``lt(t, angle)`
```

这里的文档字符串是一个使用三引号括起来的字符串，三引号字符串又称为多行字符串，因为三个引号允许Python的字符串可以多行的展示。

虽然有时函数的文档字符串文字很少，但是已经包含了其他人需要知道的关于函数的基础信息和功能简介，文档与我们之前讲的[单行注释](http://www.iplaypy.com/jichu/note.html)概念不太一样。它精确的解释了这个函数提供了什么功能（玩蛇网提示：至于如何实现这个函数的等信息，不要写在这里面。）它解释了每个形参对函数行为的影响效果以及每个形参应有的[类型](http://www.iplaypy.com/jichu/data-type.html)。

编写这类函数文档是接口设计的重要部分，一个设计良好的接口，也应当很简单就能解释清楚；==如果你发现解释一个函数真的不太容易的话，很可能表示它的接口设计有改进的空间==。