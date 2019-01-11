# Python 文件对象常用内建方法

学习[python教程](http://www.iplaypy.com/)文件操作时，除了**python open函数**外还会用到一些内建方法。为方便查找，下面把一些经常会用到的python基础文件内建方法集合在一起，并为每一种方法做了注解，供初学者参考。

## 文件对象读取内容

file.read(size)：size为读字节的长度，默认为-1。

file.readline(size)：逐行读取，如果定义了size参数，则会按照设定的值来读。这里的size代表行数，如果有换行有可能返回的只是一行的一部分

file.readlines(size)：把文件内的每一行，分别作为[列表list](http://www.iplaypy.com/jichu/list.html)的一个成员，并返回这个列表。

## 文件对象写入内容


file.write(str)：文件写入的操作方法，把[字符串str](http://www.iplaypy.com/jichu/str.html)写到文件中。

file.writelines(seq) ：向文件内写入字符串[序列](http://www.iplaypy.com/jinjie/jj106.html)方法，也可以理解为一次性写入多行操作。

## 文件对象其它操作


file.close()：关闭文件。学习python初期要养成关闭的好习惯。

file.flush()：把缓冲区内容写入到硬盘中。

file.fileno()：返回文件描述符（文件标签）

file.isatty()：对文件是否是一个终端设备文件做判断

file.tell()：以文件开头为起始点，返回文件操作标记的当前位置。

file.next()：返回文件的下一行，同时会将文件的操作标记位置移到下一行。

file.seek(off, whence=0)：从文件中移动off个操作标记（文件指针），正往结束方向移动，负往开始方向移动。如果设定了whence参数，就以whence设定的起始位为准，0代表从头开始，1代表当前位置，2代表文件最末尾位置。

file.truncate(size=file.tell())：截取文件最大字节，截取范围以当前文件操作标记的位置为准。

除了Python文件对象常用内建方法外，[python模块库](http://www.iplaypy.com/module/)方面还有对文件、文件夹操作函数会涉及到[os模块](http://www.iplaypy.com/module/os.html)和shutil模块，玩蛇网过后也会为大家做个简单的总结。