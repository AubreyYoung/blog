#!/usr/bin/env python
#_*_ coding:utf-8 _*_


"""
-------------------------------------------------
@version: 0.1
@Author:AubreyYoung
@license: Apache Licence 
@contact: yangguang1900@163.com
@site: https://github.com/AubreyYoung/blog
@software: PyCharm
@file: oldboy_python_day11_session.py.py
@Date:2019/3/11 10:47
-------------------------------------------------
"""

import time
# print(time.time())
# time.sleep(5)
# print('MySQL')
# print('Aubrey')

def  func():
    start = time.time()
    print('Oracle')
    end = time.time()
    print(end - start)

func()

import time

def timmer():
    start = time.time()
    func()
    end = time.time()
    print(end - start)

def func():
    print('Oracle')

timmer()

import time
def timmer(f):
    start = time.time()
    f()
    end = time.time()
    print(end - start)

def func():
    print('Oracle')

timmer(func)

import time
def timmer(f):  # 装饰器函数
    def inner():
        start = time.time()
        ret = f()  # 被装饰的函数
        end = time.time()
        print(end - start)
        return  ret
    return  inner

@timmer  # 语法糖
def func():
    print('Oracle')
    return  'Hello'

# func = timmer(func)
ret = func()
print(ret)

# 装饰器带参数
import time
def timmer(f):  # 装饰器函数
    def inner(*args,**kargs):
        start = time.time()
        ret = f(*args,**kargs)  # 被装饰的函数
        end = time.time()
        print(end - start)
        return  ret
    return  inner

@timmer  # 语法糖 @装饰器函数名
def func(*args,**kargs):
    print('Oracle',*args,**kargs)
    return  'Hello'

# func = timmer(func)
ret = func(1,'a')
print(ret)

# 装饰器固定模式
def wrapper(func):
    def inner(*args,**kwargs):
        '''在被装饰函数之前要做的事'''
        ret =func(*args,**kwargs)
        '''在被装饰函数之后要做的事'''
        return  ret
    return inner

@wrapper  # func = wrapper(func)
def func(*args,**kwargs):
    pass
    return 0