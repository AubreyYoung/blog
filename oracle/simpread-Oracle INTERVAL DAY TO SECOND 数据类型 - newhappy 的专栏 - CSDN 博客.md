> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://blog.csdn.net/newhappy2008/article/details/6201465 版权声明：本文为博主原创文章，未经博主允许不得转载。 https://blog.csdn.net/newhappy2008/article/details/6201465 <link rel="stylesheet" href="https://csdnimg.cn/release/phoenix/template/css/ck_htmledit_views-d7e2a68c7c.css"> INTERVAL DAY TO SECOND 数据类型
Oracle 语法:
INTERVAL '{integer | integer time_expr | time_expr}'
{{ DAY | HOUR | MINUTE} [ ( leading_precision ) ]
| SECOND [( leading_precision [, fractional_seconds_precision] ) ] }
[TO { DAY | HOUR | MINUTE | SECOND [ (fractional_seconds_precision) ] } ]
leading_precision 值的范围是 0 到 9, 默认是 2\. time_expr 的格式为: HH[:MI[:SS[.n]]] or MI[:SS[.n]] or SS[.n], n 表示微秒.
该类型与 INTERVAL YEAR TO MONTH 有很多相似的地方, 建议先看 INTERVAL YEAR TO MONTH 再看该文.
范围值:
HOUR:    0 to 23
MINUTE: 0 to 59
SECOND: 0 to 59.999999999
eg:
INTERVAL '4 5:12:10.222' DAY TO SECOND(3)
表示: 4 天 5 小时 12 分 10.222 秒
INTERVAL '4 5:12' DAY TO MINUTE
表示: 4 天 5 小时 12 分
INTERVAL '400 5' DAY(3) TO HOUR
表示: 400 天 5 小时, 400 为 3 为精度, 所以 "DAY(3)", 注意默认值为 2\.
INTERVAL '400' DAY(3)
表示: 400 天
INTERVAL '11:12:10.2222222' HOUR TO SECOND(7)
表示: 11 小时 12 分 10.2222222 秒
INTERVAL '11:20' HOUR TO MINUTE
表示: 11 小时 20 分
INTERVAL '10' HOUR
表示: 10 小时
INTERVAL '10:22' MINUTE TO SECOND
表示: 10 分 22 秒
INTERVAL '10' MINUTE
表示: 10 分
INTERVAL '4' DAY
表示: 4 天
INTERVAL '25' HOUR
表示: 25 小时
INTERVAL '40' MINUTE
表示: 40 分
INTERVAL '120' HOUR(3)
表示: 120 小时
INTERVAL '30.12345' SECOND(2,4)    
表示: 30.1235 秒, 因为该地方秒的后面精度设置为 4, 要进行四舍五入.
INTERVAL '20' DAY - INTERVAL '240' HOUR = INTERVAL '10-0' DAY TO SECOND
表示: 20 天 - 240 小时 = 10 天 0 秒
==================
该部分来源：http://www.oraclefans.cn/forum/showblog.jsp?rootid=140
INTERVAL DAY TO SECOND 类型存储两个 TIMESTAMP 之间的时间差异，用日期、小时、分钟、秒钟形式表示。该数据类型的内部代码是 183，长度位 11 字节：
l         4 个字节表示天数（增加 0X80000000 偏移量）
l         小时、分钟、秒钟各用一个字节表示（增加 60 偏移量）
l         4 个字节表示秒钟的小时差异（增加 0X80000000 偏移量）
以下是一个例子：
SQL> alter table testTimeStamp add f interval day to second ;
表已更改。
SQL> update testTimeStamp set f=(select interval '5' day + interval '10' second from dual);
已更新 3 行。
SQL> commit;
提交完成。
SQL> select dump(f,16) from testTimeStamp;
DUMP(F,16)
--------------------------------------------------------------------------------
Typ=183 Len=11: 80,0,0,5,3c,3c,46,80,0,0,0
Typ=183 Len=11: 80,0,0,5,3c,3c,46,80,0,0,0
Typ=183 Len=11: 80,0,0,5,3c,3c,46,80,0,0,0
日期：0X80000005-0X80000000=5
小时：60－60＝0
分钟：60－60＝0
秒钟：70－60＝10
秒钟小数部分：0X80000000-0X80000000=0