#!/usr/bin/env python  
# -*- coding: utf-8 -*-
""" 
@author: Aubrey
@license: Apache Licence 
@file: numpy01.py
@version: 0.1
@time: 2021/06/09
@contact: yangguang1900@163.com
@site:  
@software: PyCharm 
@ProjectName: python-demo

# code is far away from bugs with the god animal protecting
    I love animals. They taste delicious.
              ┏┓      ┏┓
            ┏┛┻━━━┛┻┓
            ┃      ☃      ┃
            ┃  ┳┛  ┗┳  ┃
            ┃      ┻      ┃
            ┗━┓      ┏━┛
                ┃      ┗━━━┓
                ┃  神兽保佑    ┣┓
                ┃　永无BUG！   ┏┛
                ┗┓┓┏━┳┓┏┛
                  ┃┫┫  ┃┫┫
                  ┗┻┛  ┗┻┛ 
  -----------------------------------------------------------------
  """
import numpy as np

list = [1, 2, 3, 4]
arr = np.array(list)
print(arr)

print(np.zeros((8, 8)))

print(np.ones((4, 4)))

print(np.arange(7))

arr = np.arange(2, 6, dtype=np.float)
print(arr)
print("Array Data Type :", arr.dtype)

print(np.linspace(1., 4., 4))

print(np.matrix('1 2; 3 4'))

mat = np.matrix('1 2; 3 4')
print(mat.H)
print(mat.T)
