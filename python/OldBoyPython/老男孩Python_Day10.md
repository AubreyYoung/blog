# 老男孩Python_Day10

```
#!/usr/bin/env python
# _*_ coding:utf-8 _*_


"""
-------------------------------------------------
@version: 0.1
@Author:AubreyYoung
@license: Apache Licence
@contact: yangguang1900@163.com
@site: https://github.com/AubreyYoung/blog
@software: PyCharm
@file: oldboy_python_day10_session.py
@Date:2019/1/24 20:34
-------------------------------------------------
"""


# 函数
# 可读性强,复用性强

def 函数名():
    函数体
    return 返回值


# 所有的函数,只定义不调用就一定不执行
# 先定义函数后调用

函数名()  # 函数调用,不接收返回值
返回值(变量名) = 函数名()  # 接受接收返回值


# 默认参数的陷阱
def func(l1=[]):
    l1.append(1)
    print(l1)


func()
func([])


# 如果默认参数的值是一个可变数据类型,那么每一次调用函数的时候,
# 如果不传值就公用这个类型的资源

def func(k, l={}):
    l[k] = 'v'
    print(l)


func(1)
func(2)
func(3)
func(1)

# 命名空间和作用域

a = 1


def func():
    print(a)


func()


def func():
    a = 1


func()
print(a)


# 命名空间 有三种
# 内置命名空间 --Python解释器
#       就是Python解释器一启动就可使用的名字存储在内置命名空间中
#       内置的名字在启动解释器的时候被加载进内存里
# 全局命名空间  --我们写的代码但不是函数中的代码
#       是在程序从上到下被执行的过程中依次加载进内存的
#       防止了我们设置的所有变量名和函数名
# 局部命名空间  -- 函数
#       就是函数内部定义的名字
#       当调用函数的时候,才会产生这个命名空间,随着函数执行的结束,这个命名空间就又消失了

# 在局部:可以使用全局,内置命名空间中的名字
# 在全局:可以使用内置命名空间中的名字,但不能使用局部命名空间中的名字
# 在内置:不能使用全局,内置命名空间中的名字

# 依赖倒置原则
	高层级的模块不应该依赖于低层次的模块，它应该依赖于低层次模块的抽象
	抽象不应该依赖于具体，具体应该依赖于抽象

def max():
    print('aqa')


max()
max([12,, 3234244, 554])

# 在正常情况下,直接使用内置的名字
# 当我们在全局定义了和内置命名空间中同名的名字时,会使用全局的名字
# 当我自己有的时候,我就不找上一级要
# 如果自己没有,就找上一级要,上一级没有再找上一级;如果内置的命名空间都没有就报错
# 多个函数应该拥有多个独立的局部命名空间,不互相共享

def input():
    print('adad')


def func():
    # input = 1
    print(input)


func()

print(input)  # 打印函数的内存地址


# 作用域
#       全局作用域:作用在全局:内置,全局命名空间中的名字都属于全局作用域
#       局部作用域:作用在局部:函数(,局部命名空间中的名字属于局部作用域)

def func():
    a += 1


# 对于不可变数据类型,在局部可以查看全局作用域中的变量,但是不能直接修改
# 如果想要修改,需要在程序的一开始添加global声明
# 如果在一个局部(函数)内声明了一个global变量,那么这个变量在局部的所有操作将对全局的变量有效
a = 1


def func():
    global a
    a += 1


func()
print(a)

a = 1
b = 2


def func():
    x = 'aaa'
    y = 'bbb'
    print(locals())  # 查看局部命名空间中的名字
    print(globals())  # 查看局部命名空间中的名字


func()

print(globals())  # 查看全局,内部命名空间中的名字
print(locals())


# globals() 用于打印全局的名字
# locals() 输出什么,根据locals所在的位置


def max(a, b):
    return a if a > b else b


def the_max(a, b, c):
    z = max(a, b)  # 函数的嵌套调用
    return max(c, z)


print(the_max(45, 6566, 2332))


# 函数的嵌套定义
# 内部函数可以使用外部函数的变量

a = 1
def outer():
    a = 1

    def inner():
        b = 2
        print(a)
        print('aaa')

        def inner2():
            # global  a
            nonlocal  a  # 声明了一个上面第一层局部变量变量
            a += 1  # 不可变数据类型的修改
            print(a, b)
            print('inner2')

        inner2()
    inner()
    print('aaa:',a)


outer()
print(a)

# nonlocal 只能用于局部变量,找上层中离当前函数最近一层的局部变量
# 声明了nonlocal的内部函数的变量修改会影响到离当前函数最近一层的局部变量
# 对全局无效
# 对局部 也只是最近的一层有影响

# 函数名的本质
def func():
    print(123)

func()  # 函数名就是内存地址
func2 = func #函数名可以赋值
func2()
l = [func,func2]
print(l)
for i in l:  # 函数名可以作为容器类型的元素
    i()

#
def func():
    print(123)

def func2(f):
    f()
    return  f  # 函数名可以作为函数的返回值

b = func2(func)  # 函数名可以作为函数的参数
b()

# 函数名 ----第一类对象
#       1.可在运行期创建
#       2.可用作函数参数或返回值
#       3.可存入变量的实体。

# 闭包,嵌套函数,内部函数调用外部函数的变量

def outer():
    a = 1
    def inner():
        print(a)
    # print(inner.__closure__)
    return  inner

inn = outer()
inn()

# import  urllib
from urllib.request import  urlopen
def get_rul():
    url = 'https://www.cnblogs.com/Eva-J/articles/7156261.html'
    ret = urlopen(url).read()
    print(ret)

get_rul()

from urllib.request import  urlopen
def get_rul():
    url = 'https://www.cnblogs.com/Eva-J/articles/7156261.html'
    def get():
        ret = urlopen(url).read()
        print(ret)
    return  get

get_func = get_rul()
get_func()
```