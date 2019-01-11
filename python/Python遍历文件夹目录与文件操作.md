# Python遍历文件夹目录与文件操作

经常需要检查一个“目录或文件夹”内部有没有我们想要的**文件**或者文件夹，就需要我们循环迭代出所有文件和子文件夹，那么如何用**Python遍历文件夹目录与文件**？

## 遍历文件夹目录与文件

一想到解决的方法，我们首先应该看一看[Python标准库](http://www.iplaypy.com/module/)中会不会有这样的方法或者模块，其实这个操作我们的[os模块](http://www.iplaypy.com/module/os.html)中的生成器os.walk方法就可以轻松解决这个问题，我们将它封装成为自己的一个[函数](http://www.iplaypy.com/jichu/function.html)来使用。

### 代码演示：
```
import os
import fnmatch

def all_files(root,patterns='*',single_level=False,yield_folders=False):
    "遍历文件夹目录和文件"
    patterns = patterns.split(';')

    for path,subdirs,files in os.walk(root):
        if yield_folders:
            files.extend(subdirs)
        files.sort()

    for name in files:
        for pattern in patterns:
            if fnmatch.fnmatch(name,pattern):
                yield os.path.join(path,name)
                break
        if single_level:
            break
for path in all_files('D:\\Git\\','*.py;*.png;*htm'):
    print(path)
```
**Python遍历文件夹目录**

按照玩蛇网上面的Python遍历文件夹目录与文件源代码运行之后就可以得到所在目录，所有你需要的文件[类型](http://www.iplaypy.com/jichu/data-type.html)的列表了，当然无论是[Linux](http://www.iplaypy.com/linux/)类操作系统还是Windows系统平台，都需要把代码中的路径部分，改填成你自己的目录路径，Windows与Linux路径填写规则不同，还请新手朋友们注意。

标准库模块fnmatch的作用是检查文件名的匹配模式，Windows平台不在乎大小写，但像Ubuntu这种linux风格的系统平台是区分大小写的，我们像上面那样提供参数的时候，提供多个模式，用“；”分号来将它们连接起来（中间不要有空格，否则会报错），分号本身不是模式的一部分。

我们可以轻松的获得Ubuntu系统下/tmp临时目录的所有Python文件和网页html文件的[列表](http://www.iplaypy.com/jichu/list.html)：
```
>>> files_list = list(all_file('/tmp', '*.py;*.html'))
```
还可以像上面我们源代码图片中那样，用[for循环](http://www.iplaypy.com/jinjie/for.html)来输出我们遍历文件夹目录来，想要的文件。说到遍历，你还可以学习下[python 遍历元组](http://www.iplaypy.com/jichu/tuple.html)相关知识。