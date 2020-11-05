# -*- coding: utf-8 -*-
"""
-------------------------------------------------
@version: 0.1
@Author: yangguang02
@license: Apache Licence 
@contact: yangguang1900@163.com
@site: https://github.com/AubreyYoung/blog
@software: PyCharm
@file: CreateImage
@ProjectName: python-demo
@Date: 2020/11/5 9:26
-------------------------------------------------
"""

import ctypes

# Windows 锁屏
from ctypes import WinDLL

user32: WinDLL = ctypes.windll.LoadLibrary('user32.dll')
user32.LockWorkStation()
