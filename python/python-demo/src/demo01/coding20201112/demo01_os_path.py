# -*- coding: utf-8 -*-
"""
-------------------------------------------------
@version: 0.1
@Author: yangguang02
@license: Apache Licence 
@contact: yangguang1900@163.com
@site: https://github.com/AubreyYoung/blog
@software: PyCharm
@file: demo01_os_path
@ProjectName: python-demo
@Date: 2020/11/17 16:56
-------------------------------------------------
"""

import os

print(os.path.abspath('.'))
print(os.path.abspath('..'))
print(os.path.exists('D:\Github'))
print(os.path.isdir('D:\Github\blog\python\python-demo\src\demo01\coding20201112'))
print(os.path.join('D:\Github','coding20201112'))

import pathlib
