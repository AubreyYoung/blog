# Python type()函数用途及使用方法

[python](http://www.iplaypy.com/)语言中的**type()函数**在python中是即简单又实用的一种对象[数据类型](http://www.iplaypy.com/jichu/data-type.html)查询方法，本文主要介绍type()[函数](http://www.iplaypy.com/jichu/function.html)用途及使用方法。

## type()函数可以做什么

在介绍数据类型的文章中提到过，要怎么样查看对像的数据类型。type()就是一个最实用又简单的查看数据类型的方法。type()是一个内建的函数，调用它就能够得到一个反回值，从而知道想要查询的对像类型信息。

## type()函数怎么使用

type()的使用方法：type(对象)
type（）是接收一个对象当做参考，之后反回对象的相应类型。
\>>>type(1)
<type 'int'>              #[整型](http://www.iplaypy.com/jichu/int.html)

\>>>type('iplaypython')
<type 'str'>             #[字符串](http://www.iplaypy.com/jichu/str.html)

## type()返回值是什么类型

\>>>type(type(1))
<type 'type'>          #type 类型
原来这些返回值本身也是有类型的，它是type类型。