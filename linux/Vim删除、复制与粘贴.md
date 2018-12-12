# Vim删除、复制与粘贴

![对比](\Git\blog\linux\pictures\对比.png)



```
:reg
--- 寄存器 ---
""                (tablespace_usedsize_kb -^J
"0                (tablespace_usedsize_kb -^J
"1                  group by substr(rtime, 1, 10)) t2 where t2.rtime = tmp.rtime;^J
"2                   from tmp^J
"3                (select min(rtime) rtime^J
"4           from tmp,^J
"5                LAGtablespace_usedsize_kb, 1, NULL) OVER(ORDER BY tmp.rtime)) AS DIFF_KB^J
"6   ^J  <li><li>^J
"7   ^J  <li><li>^J
"8   ^J
"9   ^I       <F3<ul><F3><F3><F3<ul><F3><F3><F3></ul>></ul>>^J
"-   (
"*   增值税专用发票开票信息.md^J
":   reg
"%   README.md
"/   g

```

```
"a yy						//命名寄存器a，保存复制内容
```

![对比](D:\Git\blog\linux\pictures\对比.png)

![寄存器分类1](D:\Git\blog\linux\pictures\寄存器1.png)

![集群器分类2](D:\Git\blog\linux\pictures\寄存器2.png)

![](D:\Git\blog\linux\pictures\CRUD操作1.png)

![](D:\Git\blog\linux\pictures\CRUD操作2.png)

![调换字符](D:\Git\blog\linux\pictures\调换字符.png)

![](D:\Git\blog\linux\pictures\行剪贴粘贴.png)

![](D:\Git\blog\linux\pictures\行复制粘贴.png)

![](D:\Git\blog\linux\pictures\组合删除1.png)

![](D:\Git\blog\linux\pictures\组合删除2.png)