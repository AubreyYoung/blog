# python assert 断言详细用法格式

使用assert断言是学习**python**一个非常好的习惯，python **assert 断言**语句格式及用法很简单。在没完善一个程序之前，我们不知道程序在哪里会出错，与其让它在运行最崩溃，不如在出现错误条件时就崩溃，这时候就需要assert断言的帮助。本文主要是讲assert断言的基础知识。

![python assert断言用法](http://www.iplaypy.com/uploads/allimg/160127/2-16012G63R2L0.jpg)

## python assert断言的作用

python assert断言是声明其布尔值必须为真的判定，如果发生异常就说明表达示为假。可以理解assert断言语句为raise-if-not，用来测试表示式，其返回值为假，就会触发[异常](http://www.iplaypy.com/jichu/exception.html)。

## assert断言语句的语法格式

assert python 怎么用？

> assert 表达式

下面做一些assert用法的语句供参考：
```
assert 1==1
assert 2+2==2*2
assert len(['my boy',12])<10
assert range(4)==[0,1,2,3]
```
## 如何为assert断言语句添加异常参数

assert的异常参数，其实就是在断言表达式后添加[字符串](http://www.iplaypy.com/jichu/str.html)信息，用来解释断言并更好的知道是哪里出了问题。格式如下：
assert expression [, arguments]
assert 表达式 [, 参数]