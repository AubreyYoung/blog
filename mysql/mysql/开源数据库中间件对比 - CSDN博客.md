# 开源数据库中间件对比 - CSDN博客

# 开源数据库中间件对比

2017年04月16日 14:52:31 阅读数：8873更多

Proxy式架构和客户端式架构的优劣

|

Proxy式架构

|

客户端式架构  
  
---|---|---  
  
优点

|

1， 集中式管理监控和升级维护方便

2， 解决连接数问题

|

1\. 应用直连数据库性能高

2\. 无需中间层集群，没有额外成本开销  
  
劣势

|

1， 需要中间层集群，有硬件成本开销

2， 多一跳(hop)有一定性能损失

3，中间层做数据合并，需要做隔离机制

|

1\. 客户端和应用耦合，管理监控和升级维护麻烦

2\. 不解决连接数问题  
  
Measure

Measure


---
### ATTACHMENTS
[b9bca4e9b2156bd84b522f759831909c]: media/开源数据库中间件对比_-_CSDN博客.png
[开源数据库中间件对比_-_CSDN博客.png](media/开源数据库中间件对比_-_CSDN博客.png)
[ddd3b9e14dc5a42cbebbb4d210fbbacd]: media/开源数据库中间件对比_-_CSDN博客-2.png
[开源数据库中间件对比_-_CSDN博客-2.png](media/开源数据库中间件对比_-_CSDN博客-2.png)
---
### NOTE ATTRIBUTES
>Created Date: 2018-09-03 02:37:17  
>Last Evernote Update Date: 2018-10-01 15:35:36  
>source: web.clip7  
>source-url: https://blog.csdn.net/odailidong/article/details/70195525  
>source-application: WebClipper 7  