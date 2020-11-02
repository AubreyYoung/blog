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
@file: oldboy_python_day02_homework.py
@Date:2019/1/16 16:54
-------------------------------------------------
"""


# 1.判断下列逻辑语句的True,False
# 1) 1>1 or 3 < 4 or 4 > 5 and 2 > 1 and 9 > 8 or 7 < 6
#      f   or t     or   f   or  f =  t
print(1>1 or 3 < 4 or 4 > 5 and 2 > 1 and 9 > 8 or 7 < 6)
# 2) not 2 > 1 and 3 < 4 or 4 > 5  and 2 > 1 and 9 > 8 or 7 < 6
#     f  or  f     or  f   = f
print(not 2 > 1 and 3 < 4 or 4 > 5  and 2 > 1 and 9 > 8 or 7 < 6)
# 3) 1 > 2 and 3 < 4 or 4 > 5 and 2 > 1 or 9 < 8 and 4 > 6 or 3 < 2
#      f    or  f   or  f   or  f = f
print(1 > 2 and 3 < 4 or 4 > 5 and 2 > 1 or 9 < 8 and 4 > 6 or 3 < 2)

# 2. 求出下列逻辑语句的值
# 1) 8 or 3 and  4 or  2 and 0 or 9 and 7
# 8 or 4 or 0 or 7 = 8
print(8 or 3 and  4 or  2 and 0 or 9 and 7)
# 2) 0 or 2 and 3 and 4 or 6 and 0 or 3
# 0 or 4 or 0 or 3 =4
print(0 or 2 and 3 and 4 or 6 and 0 or 3)
# 3) 5 and 9 or 10  and 2 or 3 and 5  or 4 or 5
# 9 or 2 or 5  or 4 or 5 =9
print(5 and 9 or 10  and 2 or 3 and 5  or 4 or 5)

# 3. 下列结果是什么?
# 1) 6 or 2 > 1
# 6 or t = 6
print(6 or 2 > 1)
# 2) 3 or 2 > 1
# 3 or t = 3
print(3 or 2 > 1)
# 3) 0 or 5 < 4
# 0 or f = 0 == false ==
print(0 or 5 < 4)
# 4) 5 < 4 or 3
# f or 3 = 3
print(5 < 4 or 3)
# 5) 2 > 1 or 6
# t or 6 = t
print(2 > 1 or 6)
# 6) 3 and 2 > 1
# 3 and  t = t
print(3 and 2 > 1)
# 7) 0 and 3 > 1
# 0 and t = 0
print(0 and 3 > 1)
# 8) 2 > 1 and 3
# t and 3 = 3
print(2 > 1 and 3)
# 9) 3 > 1 and 0
# t and 0 = 0
print( 3 > 1 and 0)
# 10) 3 > 1 and 2 or 2 < 3 and 4 or 3 > 2
# 2 or 4 or t =  2
print(3 > 1 and 2 or 2 < 3 and 4 or 3 > 2)

# 4.简述变量命名规范
# 5.name=input(">>>") name变量是什么数据类型 字符串
# 6. if条件语句的基本结构?
# 7. while循环语句基本结构
# 8. 写代码:计算 1-2+3...+99中除了88以外所有的合?
count = 1
sum = 0

while count < 100:
    if count % 2 == 1:
        sum += count
    else:
        if count != 88:
            sum -= count
        else:
            sum = sum + 0
    count += count
print(sum)

# 9.用户登录(三次输错机会)且每次输错误时显示剩余错误次数(使用字符串格式换)
count = 0

while count < 3:
    UserName = input('请输入姓名:')
    Password = input('请输入密码:')
    if UserName == 'Aubrey' and Password == 'password':
        print('登录成功!')
        break
    else:
        print('登录失败!请重新输入!')
        print('您还有%s次尝试机会!' %(str( 2 - count )))
# 10.简述ascii、Unicode、utf-8编码关系？

# 11.简述位和字节的关系?

#.写代码:计算 1-2+3...-99中除了88以外所有的合?
count = 1
sum = 0

while count < 100:
    if count != 88:
        sum = sum + count*(-1)**(count-1)
    else:
        sum = sum
    count += count
print(sum)

# 12."老男孩"使用utf-8编码占用几个字节?使用GBK编码占用几个字节?
# 3 * 3 = 9,3 * 2 = 6
# 13.制作趣味模板 程序需求:等待用户输入名字,地点,爱好,
# 根据用户的名字和爱好进行任意实现如:敬爱可亲的XXX,最喜欢在XXX地方干XXX
Name = input("请输入姓名:")
Where = input("请输入地点:")
Hobbies = input("请输入爱好")
print("敬爱可亲的%s,最喜欢在%s地方干%s" %(Name,Where,Hobbies))

# 14.等待用户输入内容,检测用户输入内容中是否包含敏感字符?
# 如如果存在敏感字符提示"存在敏感字符请重新输入",并允许用户重新输入并打印
# 敏感字符:"小粉嫩","大铁锤"
Char = input("请输入字符:")

while Char in ("小粉嫩","大铁锤"):
    print("请重新输入!")
    Char = input("请输入字符:")
else:
    print(Char)
# 15. 单行注释以及多行注释
''' '''
# 注释
""" """
# 16.简述你所知道的Python 3 与Python 2的区别?

# 17. 看代码书写结果:
a = 1 > 2 or 4 < 7 and 8==8  # a = f or t and t = f or t = t
print(a)

# 18. continue 和break 区别?

# 19. 看代码书写结果:
a = 12 & 127  # & 表示or
print(a)

a = 12 and 127
print(a)


