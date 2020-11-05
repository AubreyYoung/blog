# -*- coding: utf-8 -*-
"""
-------------------------------------------------
@version: 0.1
@Author: yangguang02
@license: Apache Licence 
@contact: yangguang1900@163.com
@site: https://github.com/AubreyYoung/blog
@software: PyCharm
@file: CreateWindows
@ProjectName: python-demo
@Date: 2020/11/5 9:35
-------------------------------------------------
"""

# 导入turtle包的所有内容:
import turtle

# 设置笔刷宽度:
turtle.width(4)

# 前进:
turtle.forward(200)
# 右转90度:
turtle.right(90)

# 笔刷颜色:
turtle.pencolor('red')
turtle.forward(100)
turtle.right(90)

turtle.pencolor('green')
turtle.forward(200)
turtle.right(90)

turtle.pencolor('blue')
turtle.forward(100)
turtle.right(90)

# 调用done()使得窗口等待被关闭，否则将立刻关闭窗口:
turtle.done()