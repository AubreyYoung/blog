# 第三方时间日期库 Python Arrow模块

在玩蛇网前面的文章中，我们介绍过时间的模块，一个是datatime，还有一个就是[time模块](http://www.iplaypy.com/module/time.html)，今天给大家推荐一个非常轻量级别的时间日期模块，它叫做**Arrow**。

这个Arrow模块也算的上一个非常标准的时间和日期的第3方库了，提供了一种合理、智能的方式来创建、操作、格式化、转换时间日期的格式，据说它的设计灵感主要来源于moment.js。

**为何要有Arrow？**

[Python标准库](http://www.iplaypy.com/module/)和一些其它模块都提供了这些功能和[函数](http://www.iplaypy.com/jichu/function.html)方法，为什么还有这个Arrow模块，我们使用其它日期时间模块，经常应用功能过于强大，方法太复杂，不能高效的应用到工作中，而Arrow解决了这些问题。
- 模块太多：日期、时间、日历、datetuil、pytz等等。
- 时区和时间戳格式转换起来非常麻烦，还要计算转换。
- 时区是显式的，比较容易理解。
- 方法差距：ISO-8601解析、时间跨度、不够人性化等。

**Arrow主要功能**：
1. 时区转换
2. 简单的时间戳操作
3. 时间跨度
4. 非常人性化，支持越来越多的语言环境
5. 实现datetime接口
6. 支持[Python 2.6、2.7和3.3](http://www.iplaypy.com/wenda/python2-python3.html)
7. 默认采用TZ-aware和UTC
8. 创建简洁、智能的接口
9. 可以轻松更换和改变属性
10. 丰富的解析和格式化选项
11. 可扩展的工厂架构来支持自定义Arrow派生类型

**Arrow安装方法**
进入终端，输入：$ pip install arrow 
Arrow官方网站：<http://crsmithdev.com/arrow/>
GitHub托管的地址：<https://github.com/crsmithdev/arrow>
以上就是Arrow时间日期这个轻量级模块库的介绍了，有什么不明白，大家可以留言，或者加入玩蛇网QQ群。