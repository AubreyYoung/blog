# Python logging日志模块level配置操作说明

**Python logging日志记录**模块的使用与配置教程。

## 一、logging模块简介

logging模块我们不需要单独再安装，经常要调试程序，记录程序运行过程中的一些信息，手工记录调试信息很麻烦，[Python](http://www.iplaypy.com/)的logging模块，会把你想记录的日志信息保存到一个自己设定格式的文件中。

## 二、logging模块日志级别

1. Level:  **CRITICAL** Numeric value: 50 
2. Level:  **ERROR**     Numeric value: 40
3. Level:  **WARNING** Numeric value: 30 
4. Level:  **INFO**          Numeric value: 20
5. Level:  **DEBUG**      Numeric value: 10
6. Level:  **NOTSET**    Numeric value: 0

## 三 、logging模块源码演示

```
import logging
logging.basicConfig(level=logging.INFO)
logging.debug('debug message')
logging.info('info message')
logging.warning('warn message')
logging.error('error message')
logging.critical('critical message')
```

## 四 、logging模块注意事项

提示：该[python模块](http://www.iplaypy.com/module/)的日志对象对于不同的级别的信息，它会提供不同的函数进行输出，如：info(), error(), debug()等方法。在我们写入日志的时候，小于指定级别的信息将会被忽略掉。

程序员要配置logging模块，将一些调试消息按自己的意愿存到指定格式的文件中，或者输出到屏幕上，可以采用不同的详细程度记录消息，或者记录到不同的目标。可以将日志消息写入文件、Http GET或者POST位置、通过SMTP写入Email邮件、通用套接字或采用操作系统特定的日志机制，logging模块中这些功能应有尽有了。