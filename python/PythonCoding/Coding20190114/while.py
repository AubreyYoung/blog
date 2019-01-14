"""
1、使用while循环输入 1 2 3 4 5 6     8 9 10

2、求1-100的所有数的和


3、输出 1-100 内的所有奇数

4、输出 1-100 内的所有偶数

5、求1-2+3-4+5 ... 99的所有数的和

6、用户登陆（三次机会重试）

"""
count = 1

while count <= 10:
    if count == 7:
        count = count + 1
        continue
    print(count)
    count = count + 1


"""
count = 1
sum = 0

while count <= 100:
    sum = sum + count
    count = count + 1

print(sum)
"""

'''
count = 1
while count <= 100:
    if count%2 == 1:
        print(count)
    count = count +1

'''

'''
count = 1
while count <= 100:
    if count%2 == 0:
        print(count)
    count = count +1
'''
# count = 1
# sum = 0
# while count <= 100:
#     if count%2 == 1:
#         sum = sum + count
#     else:
#         sum = sum - count
#     count = count + 1
# print(sum)

# count  = 1
# while count <= 3:
#     name = input('您的用户名：')
#     passwd = input('您的密码：')
#     count = count +1