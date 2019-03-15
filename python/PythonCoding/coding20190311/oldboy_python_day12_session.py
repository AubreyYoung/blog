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
@file: oldboy_python_day12_session.py.py
@Date:2019/3/11 10:48
-------------------------------------------------
"""

def wrapper(f):
    def inner(*args,**kargs):
        '''在被装饰函数之前要做的事'''
        ret = func(*args,**kargs)
        '''在被装饰函数之后要做的事'''
        return  ret
    return  inner

@wrapper
def func(*args,**kargs):
    pass


func()


def outer(*args,**kargs):
    print(args)
    print(*args)

outer(1,2,3,4)

def oracle():
    '''
    一个打印Oracle的函数
    :return:
    '''
    print('oracle')

print(oracle.__name__)  # 查看字符串格式的函数名
print(oracle.__doc__)  # document

print(func.__name__)   # 报错


from functools import wraps
def wrapper(f):
    @wraps(func)
    def inner(*args,**kargs):
        '''在被装饰函数之前要做的事'''
        ret = func(*args,**kargs)
        '''在被装饰函数之后要做的事'''
        return  ret
    return  inner

@wrapper
def func(*args,**kargs):
    pass

func()
print(func.__name__)


