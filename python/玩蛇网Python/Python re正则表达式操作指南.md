# Python re正则表达式操作指南

**PYTHON正则表达式指南**

**![python正则表达式操作方法](http://www.iplaypy.com/uploads/allimg/160322/2-160322094P0246.jpg)**

**python re**正则表达式模块中文简介：

python re模块(Regular Expression正则表达式)提供了与Perl等编程语言类似的正则匹配操作，
它是一个处理[python字符串](http://www.iplaypy.com/jichu/str.html)的强有力工具，有自己的语法和独立的处理引擎。几乎所有的编程语言中，正则表达式的语法都是一样的，区别只在于它们实现支持的正则表达式语法的数量不一样。

## 一、python re正则表表达式语法

### 1、匹配字符

**.**   匹配任意除换行符，也就是“\n”以外的任何字符。
\\  转义符，改变原来符号含义，后面会有演示。
\[ \]  中括号用来创建一个字符集，第一个出现字符如果是^，表示反向匹配。

### 2、预定义字符集
\\d    匹配数字，如：[0-9]
\\D   与上面正好相反，匹配所有非数字字符。
\\s     空白字符，如：空格，\t\r\n\f\v等。
\\S    非空白字符。
\\w    单词字符，如：大写A~Z，小写a~z，数字0~9。
\\W   非上面这些字符。

### 3、可选项与重复子模式

\*       匹配前一个字符0次或无限次数。
\+       匹配前一个字符1次或无限次数。
?         匹配前一个字符0次或1次。
{m}    匹配前一个字符m次。
{m,n} 匹配前一个字符m至n次。

![Python正则表达式](D:\Git\blog\python\Pictures\Python正则表达式.png)



## 二、python re模块重要函数变量

1. compile() 根据正则表达式字符串，创建模式的对象。
2. search() 在字符串中寻找模式。
3. match() 在字符串开始处匹配模式。
4. split() 根据模式的匹配项来分割字符串。
5. findall() 显示出字符串中模式的所有匹配项。
6. sub(old,new) 方法的功能是，用将所有old的匹配项用new替换掉。
7. escape() 将字符串中所有特殊正则表达式字符转义。

## 三、python re模块的主要功能

**re.compile()方法**

将正则表达式转换为re的模式对象，更高效率的匹配字符串。

**re.search() 方法**

在给定的字符串中，寻找第一个匹配的正则表达式子串。[函数](http://www.iplaypy.com/jichu/function.html)找到子字符串的话会返回MatchObject，值为 True，找不到会返回None，值为False。

**re.match() 函数**

在字符串的最开始部分进行匹配。

**re.split() 函数**

根据模式的匹配项来分割字符串，类似于我们字符串的split方法，不过它是用完整的正则表达式来替代了固定的分隔符。

**re.findall()** 

以列表的形式返回给定模式的所有匹配项。

**re.escape()**

一个很实用的函数，它可以对我们要查找的字符串中所有可能会被解释为正则运算符的字符进行转义。

## 四、python re模块实例源码演示

==待补充~~==

## 五、python re正则模块小结

​	以上玩蛇网[www.iplaypy.com](http://www.iplaypy.com/)只介绍了一些python正则表达式指南，在我们编程过程中的方方面面，都会被使用到，所以，它也是我们每一个编程爱好者必会的一种技能，尤其是网络抓取，匹配我们需要的信息，如：汉字、标题、邮箱、电话、产品价格等信息时，更会突出它的作用。