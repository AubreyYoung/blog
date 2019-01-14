# Python linecache模块缓存读取大文件指定行

**linecache模块**的作用是将[文件](http://www.iplaypy.com/sys/open.html)内容读取到内存中，进行缓存，而不是每次都要从硬盘中读取，这样效率提高很多，又省去了对硬盘IO控制器的频繁操作。

## 一、linecache模块简介

我们看一下这个模块的名字叫做linecache，行-缓存，这对于读取内容非常多的文件，效果甚好，而且它还可以读取指定的行内容。

## 二、linecache模块函数讲解

1. *linecache.getline(filename, lineno[, module_globals])* 

   这个方法从filename也就是文件中读取内容，得到第 lineno行，注意没有去掉换行符，它将包含在行内。

2. *linecache.clearcache()* 

   清除现有的文件缓存。

3. *linecache.checkcache([filename])* ，

   参数是文件名，作用是检查缓存内容的有效性，可能硬盘内容发生了变化，更新了，如果不提供参数，将检查缓存中所有的项。

## 三 、linecache模块源码演示

```python
# coding=utf-8

import os
import linecache

def get_content(path):
    '''读取缓存中文件内容，以字符串形式返回'''
    if os.path.exists(path):
        content = ''
        cache_data = linecache.getlines(path)
        for line in range(len(cache_data)):
            content += cache_data[line]
        return content
    else:
        print('the path [{}] is not exist!'.format(path))

def main():
    path = 'c:\\test.txt'
    content = get_content(path)
    print(content)

if __name__ == '__main__':
    main()
```
## 四 、linecache模块注意事项

​	linecache里面最常用到的就是getline方法，简单实用可以直接从内容中读到指定的行.

​	日常编程中如果涉及读取大文件，一定要使用首选linecache模块，相比[open](http://www.iplaypy.com/sys/open.html)那种方法要快N倍，它是你读取文件的效率之源。