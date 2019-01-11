# Python file.seek()文件游标移动操作方法

在[python文件对象常用内建方法](http://www.iplaypy.com/sys/s107.html)一文中曾简单介绍过file.seek()函数的作用，知道了它可以将文件游标移动到文件的任意位置，具体的**file.seek()文件游标移动操作方法**则是本文主要为大家讲解的知识点。

学过C语言的人看到python的seek()方法，一定会想到C语言中的fseek()方法。在python语言中没有fseek()方法，因为它被seek()方法取代了。

**file.seek()方法标准格式**是：seek(offset,whence=0)

offset：开始的偏移量，也就是代表需要移动偏移的字节数

whence：给offset参数一个定义，表示要从哪个位置开始偏移；0代表从文件开头开始算起，1代表从当前位置开始算起，2代表从文件末尾算起。

**file.seek()操作方法示例**：

```
`>>> x ``=` `file``(``'a.txt'``,``'r'``)``>>> x.tell()      ``#显示当前游标位置在文件开头``0``>>> x.seek(``3``)     ``#移动3个字节，whence没有设置默认为从文件开头开始``>>> x.tell()``3``>>> x.seek(``5``,``1``)   ``#移动5个字节，1代表从当前位置开始``>>> x.tell()``8``>>> x.seek(``1``,``2``)``>>> x.tell()``57`
```

示例中用了file.seek()方法移动游标，但有的同学不知道当前文件游标在哪里呢、怎么看？示例中的file.tell()方法的返回值就告诉大家当前文件游标的位置。

python言语的file.seek()方法，括号内的参数只有一个时，会默认为是offset偏移数量的值，而whence值为空没设置时会默认为0。python学习玩蛇网python函数[关键字参数和位置参数](http://www.iplaypy.com/jinjie/jj130.html)有更详细函数参数设置规则介绍。