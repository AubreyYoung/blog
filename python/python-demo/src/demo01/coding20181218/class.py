#class
class Iplaypython:
    def fname(self, name):
          self.name = name

#import
import math
math.floor(1.512232123)

from math import floor
floor(1.8321321)

#help
help('sys')
help('str')

a = [1,2,3]
help(a)
help(a.append)

#open
f = open('a.txt', 'w')
f.write('hello,')
f.write('iplaypython')
f.close()

f = open('a.txt', 'r')
f.read(5)