# 用Python计算昨天、今天和明天的日期时间

​	经常获得了一个用户提交的当前日期，我们需要以这个日期为依据返回它的前一天，或者后一天的日期。用[Python](http://www.iplaypy.com/)可以非常简单的解决这个关于日期计算的问题。

不管何时何地，只要我们编程时遇到了跟时间有关的问题，都要想到 datetime 这个[标准库模块](http://www.iplaypy.com/module/)，今天我们就用它内部的时间差方法，比如**python获取昨天日期**，利用当前日期取出昨天和明天的日期。

## 用Python计算昨天和明天的日期：
```
import datetime
today = datetime.date.today()
print(today)
yesterday = today - datetime.timedelta(days=1)
print(yesterday)
tommorrow = today + datetime.timedelta(days=1)
print(tommorrow)

print("昨天：%s，今天：%s，明天：%s" %(yesterday,today,tommorrow))
```

