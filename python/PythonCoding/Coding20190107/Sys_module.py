#coding=UTF-8
import sys
# [^Errors]: print参数值换行未实现，代码报错！！
print('Name is :',sys.argv[0])

print('Path has :',sys.path)

def dump(module):
    print(module,"==>",
    if module in sys.builtin_module_names:
        print("内建模块")
    else:
        module = __import__(module)
        print(module.__file__) )
dump("os")