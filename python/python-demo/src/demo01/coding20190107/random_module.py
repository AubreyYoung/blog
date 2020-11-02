#coding UTF-8

import random

print(random.random())
print(random.choice('adwrwsfefgssefwf'))


list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10,11,12]
slice = random.sample(list,6)
print(slice)
print(list)
