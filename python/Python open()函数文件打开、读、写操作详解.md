# Python open()函数文件打开、读、写操作详解

[**python**](http://www.iplaypy.com/)的文件读写和打开操作都有自己特定的[函数](http://www.iplaypy.com/jichu/function.html)和方法，操作起来很简单。下面就来简单的了解下python文件的文件基本操作方法有哪些。

![Python open函数方法](http://www.iplaypy.com/uploads/allimg/160127/2-16012G52024328.jpg)

## 一、Python open()函数文件打开操作

打开文件会用到open函数，标准的python打开文件语法如下：
open(name[,mode[,buffering]])
open函数的文件名是必须的，而模式和缓冲参数都是可选的。比如说有个a.txt的文本文件，存放在c:\text下，那么你要打开它可以这样操作：
\>>>x = open(r 'c:\text\a.txt')
用读的模式打开这个路径下的对应文本文件，如果要打开对像不存在，程序会报错。

## 二、open()函数文件打开模式参数常用值有哪些？

刚才打开文件过程中用到了‘r’这个参数，在文件打开过程中还会用到很多操作方法，都有不同的参数来表示。'r'读模式、'w'写模式、'a'追加模式、'b'二进制模式、'+'读/写模式。

## 三、python文件写入操作

\>>>f = open('a.txt', 'w')
\>>>f.write('hello,')
\>>>f.write('iplaypython')
\>>>f.close()
第一行：用写的方式打开a.txt这个文件，并赋给f ([python变量命名规则](http://www.iplaypy.com/jichu/var.html))
第二行：f.write方法写入( )括号内的内容
第三行：同第二行意义相同，重点要说明下f.write写入的内容会追加到文件中已存在的数据后，也就是就此时的'iplaypython'是在'hello,'后边显示的。
第四行：最后调用close方法关闭文件，有打开就要有关闭。

## 四、python文件读取操作方法

要进行读文件操作，只需要把模式换成'r'就可以，也可以把模式为空不写参数，也是读的意思，因为程序默认是为'r'的。
\>>>f = open('a.txt', 'r')
\>>>f.read(5)
'hello'
\>>> f.read(10)
 ',iplaypyth'

read( )是读文件的方法，括号内填入要读取的[字符](http://www.iplaypy.com/jichu/str.html)数，这里填写的字符数是5，如果填写的是1那么输出的就应该是‘h’。

打开文件文件读取还有一些常用到的技巧方法，像下边这两种：
1、read( )：表示读取全部内容
2、readline( )：表示逐行读取

Python open()函数文件打开、读、写基础操作就先介绍这些，更深入的文件操作方法在今后的文章中会逐一单独介绍。