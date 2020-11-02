# coding=utf-8

import os
import linecache

def get_content(path):
    '''读取缓存中文件内容，以字符串形式返回'''
    if os.path.exists(path):
        content = ''
        cache_data = linecache.getlines(path)
        print(len(cache_data))
        for line in range(len(cache_data)):
            content += cache_data[line]
        return content
    else:
        print('the path [{}] is not exist!'.format(path))

def main():
    path = 'd:\\test.txt'
    content = get_content(path)
    print(content)

if __name__ == '__main__':
    main()