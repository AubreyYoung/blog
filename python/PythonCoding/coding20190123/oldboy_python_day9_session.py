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
@file: oldboy_python_day9_session.py
@Date:2019/1/23 20:57
-------------------------------------------------
"""

# Python基础
# 基础数据类型
# 流程控制 条件判断和各种循环
# 文件处理
# 函数
# 面向对象和模块
# 网络编程
# 并发编程

# 文件处理


# 修改文件
# open 调用OS命令,windows gbk编码

with open('test1.txt', mode='r', encoding='utf-8') as file1, open('test2', mode='w', encoding='utf-8') as file2:
    for line in file1:
        if 'aaa' in line:
            line = line.replace('aaa', 'bbb')
    # 写文件
    file2.write(line)

# 删除文件,重命名文件
import os

os.remove('test1')
os.rename('test2', 'test1')

# len
s = 'adadqwd'


# len(s)
# i = 0
# for k in s:
#     i += 1
# print(i)

# 函数
# 定义了之后,可以在任何需要的地方调用
# 没有返回长度,只是单纯的打印
# 返回的重要性
def my_len():
    i = 0
    for k in s:
        i += 1
    return i


s = 'adadqwd'

# my_len()

length = my_len()

print(length)


# 返回值的3种情况
#     没有返回值 ---- 默认返回None
#         不写return
#         只写return:结束一个函数的继续,不再执行后边的代码
#         return None ---- 不常用
#     返回一个值
#         可以返回任何数据类型
#         只要返回就可接收到
#         如果在一个程序中有多个return,那么只执行第一个
#     返回多个值
#         多个返回值用多个变量接受,有多少返回值就用多少变量接受
#         用一个变量接受,得到的是一个元祖


def func():
    l = ['a', 'b']
    for i in l:
        print(i)


def func():
    l = ['a', 'b']
    for i in l:
        print(i)
        if i == 'a':
            return  # 后边的代码不再执行


ret = func()
print(ret)


def func():
    l = ['a', 'b']
    for i in l:
        print(i)
        if i == 'a':
            break
    print('*' * 30)


ret = func()
print(ret)


def func2():
    return 1, 2, 3


def func2():
    return (1, 2, 3)


# 传参
def my_len(s):  # 接受参数,形式参数,形参
    i = 0
    for k in s:
        i += 1
    return i


my_len(s)  # 传递参数,传参,实际参数,实参


# 参数
#     没有参数
#         定义函数和调用函数时括号里都不写内容
#     有一个参数
#         传什么就是什么
#     有多个参数
#         位置参数

def my_sum(a, b):
    res = a + b
    return res


ret = my_sum(1, 2)
ret = my_sum(b=1, a=2)
ret = my_sum(1, b=2)
print(ret)


# 站在实参的角度上:
#   按照位置传参
#   按照关键字传参
#   混着用可用,但是必须先按照位置传参,再按照关键字传参;不能给同一个变量传多个值

# 站在形参的角度上:
#   位置参数:必须传,且有一个参数就传几个值
#   默认参数:可以不传,如果不传就使用默认的参数,如果传了就使用传的

def classmate(name, sex):
    print('{}:{}'.format(name, sex='5'))


classmate('a', '1')
classmate('b', '2')
classmate('c', '3')
classmate('d')
classmate('e', '0')


# 只有调用函数的时候:
#   按照位置传:直接写参数的值.
#   按照关键字:关键字 = 值

# 定义函数的时候:
#   位置参数,直接定义参数
#   默认参数,关键字参数:参数名 = '默认值'
#   动态参数:可以接受任意多个参数;参数名之前加*,习惯参数名args;参数名之前加**,习惯参数名**kwargs
#   顺序:必须先定义位置参数,*args,然后再定义默认参数,最后是**kwargs

def my_sum(*args):
    n = 0
    # print(args)
    for i in args:
        n += i
    return n


print(my_sum(1, 2, 33, 34))


def func(**kwargs):
    print(args)

func(a=1,b=2,c=3)
func(a=1,b=2)
func(a=1)

# 动态参数有两种:可以接受任意各参数
#   *args：接收的是按照位置参数传参的值，组织成一个元祖
#   **kwargs：接收的是按照关键字传参的值，组织成一个字典
#   *args必须在**kwargs之前

def func(*args,**kwargs):
    print(args,kwargs)
    # return args,kwargs

print(func(1, 2, 34, 566, a='12321', b=23213))


# 动态参数的另一种传参方式
def func(*args):  # 站在实参的角度上,给变量加上*,就是组合所有传来的值
    print(args)


func(1,2,3,4,5)
l = [1,2,3,4,5]
func(*l)  # 站在实参的角度上,给一个序列加上*,就是讲这个序列按照顺序打散


def  func(**kwargs):
    print(kwargs)

func(a=1,b=2)
d = {'a'=1,'b'=2}  # 定义一个字典d
func(**d)

# 函数的注释
def func():
    '''
    这个函数实现了什么功能
    参数1:
    参数2:
    :return:返回值的含义
    '''
    pass

#默认参数的陷阱

# 函数
# 函数的定义
# 函数的调用
# 函数的返回值 return
# 函数的参数:
# 形参:位置参数:必须传,*args:可以接收任意多个位置参数,默认参数:可以不传,**kwargs:可以接受多个关键字参数
# 实参:按照位置传参,按照关键字传参


