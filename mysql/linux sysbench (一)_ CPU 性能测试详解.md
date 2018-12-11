> 网上 sysbench 教材众多，但没有一篇中文教材对 cpu 测试参数和结果进行详解。 本文旨在能够让读者对 sysbench 的 cpu 有一定了解。
## 1.sysbench 基础知识
sysbench 的 cpu 测试是在指定时间内，循环进行素数计算
> 素数（也叫质数）就是从 1 开始的自然数中，无法被整除的数，比如 2、3、5、7、11、13、17 等。编程公式：对正整数 n，如果用 2 到根号 n 之间的所有整数去除，均无法整除，则 n 为素数。
## 2.sysbench 安装
#CentOS7下可使用yum安装
yum install sysbench
## 3.CPU 压测命令
#默认参数，素数上限10000，时间10秒，单线程
sysbench cpu run
## 4. 常用参数
​        **--cpu-max-prime**: 素数生成数量的上限
- 若设置为3，则表示2、3、5（这样要计算1-5共5次）
- 若设置为10，则表示2、3、5、7、11、13、17、19、23、29（这样要计算1-29共29次）
- 默认值为10000
**--threads**: 线程数
- 若设置为1，则sysbench仅启动1个线程进行素数的计算
- 若设置为2，则sysbench会启动2个线程，同时分别进行素数的计算
- 默认值为1
**--time**: 运行时长，单位秒
- 若设置为5，则sysbench会在5秒内循环往复进行素数计算，从输出结果可以看到在5秒内完成了几次，比如配合--cpu-max-prime=3，则表示第一轮算得3个素数，如果时间还有剩就再进行一轮素数计算，直到时间耗尽。每完成一轮就叫一个event
- 默认值为10
- 相同时间，比较的是谁完成的event多
**--events**: event 上限次数
- 若设置为100，则表示当完成100次event后，即使时间还有剩，也停止运行
- 默认值为0，则表示不限event次数
- 相同event次数，比较的是谁用时更少
## 5\. 案例结果分析
**执行命令**
#素数上限2万，时间10秒，2个线程
sysbench cpu --cpu-max-prime=20000 --threads=2 run
**结果分析**
```
sysbench 1.0.9 (using system LuaJIT 2.0.4)`
Running the test with following options:`
Number of threads: 2 // 指定线程数为2`
Initializing random number generator from current time`
Prime numbers limit: 20000 // 每个线程产生的素数上限均为2万个`
Initializing worker threads...`
Threads started!`
CPU speed:`
events per second: 650.74 // 所有线程每秒完成了650.74次event`
General statistics:`
total time: 10.0017s // 共耗时10秒`
total number of events: 6510 // 10秒内所有线程一共完成了6510次event`
Latency (ms):`
min: 3.03 // 完成1次event的最少耗时3.03秒`
avg: 3.07 // 所有event的平均耗时3.07毫秒`
max: 3.27 // 完成1次event的最多耗时3.27毫秒`
95th percentile: 3.13 // 95%次event在3.13秒毫秒内完成`
sum: 19999.91 // 每个线程耗时10秒，2个线程叠加耗时就是20秒`
Threads fairness:`
events (avg/stddev): 3255.0000/44.00 // 平均每个线程完成3255次event，标准差为44`
execution time (avg/stddev): 10.0000/0.00 // 每个线程平均耗时10秒，标准差为0`
```
> **event**: 完成了几轮的素数计算
> **stddev(标准差)**: 在相同时间内，多个线程分别完成的素数计算次数是否稳定，如果数值越低，则表示多个线程的结果越接近 (即越稳定)。该参数对于单线程无意义。
## 6\. 结果分析
如果有 2 台服务器进行 CPU 性能对比，当素数上限和线程数一致时：
*   相同时间，比较 event
*   相同 event，比较时间
*   时间和 event 都相同，比较 stddev(标准差)
