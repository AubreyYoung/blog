# -*- coding: utf-8 -*-
"""
-------------------------------------------------
@version: 0.1
@Author: yangguang02
@license: Apache Licence
@contact: yangguang1900@163.com
@site: https://github.com/AubreyYoung/blog
@software: PyCharm
@file: demo01_numpy
@ProjectName: python-demo
@Date: 2020/11/12 19:41
-------------------------------------------------
"""

import numpy as np

arr1 = np.array([1, 2, 3, 4, 5])

print(arr1)
print(arr1.dtype)

arr2 = np.array([1.1, 2.2, 3.3, 4.4, 5.5])

print(arr2)
print(arr2.dtype)

print(arr1 + arr2)

print(arr2 * 20)

data1 = [[1, 2, 3], [4, 5, 6]]

arr3 = np.array(data1)

print(arr3)

print(arr3.dtype)

print(np.zeros(10))

print(np.zeros([3, 5]))

print(np.ones([4, 6]))

print(np.empty([2, 3, 2]))

arr4 = np.arange(10)
print(arr4)
print(arr4[5:8])

arr4[5:8] = 10
print(arr4)

arr_slice = arr4[5:8].copy()
arr_slice[:] = 15
print(arr4)
print(arr_slice)

