# Python编程语言的条件链

在很多的时候，我们编写的[Python](http://www.iplaypy.com/)代码需要有多种可能的条件，所以我们需要更多的分支语句。表达这种计算形式的词语叫做“**条件链**”。

```
`if` `x < y:``    ``print` `"x 小于 y"``elif` `x > y:``    ``print` `"x 大于 y"``else``:``    ``print` `"x 等于 y"`
```

elif语句是”[else if](http://www.iplaypy.com/jinjie/else-elif.html)”的一个缩写形式，上面的分支中，只有一个会被真正的执行，elif语句的数量是没有限制的，如果有一个else语句，那么它必须要放在最后面，也可以没有else语句的。

```
`choice ``=` `'b'` `if` `choice ``=``=` `'a'``:``    ``print` `'a'``elif` `choice``=``=` `'b'``:``    ``print` `'b'``elif` `choice ``=``=` `'c'``:``    ``print` `c`
```

每个条件都是按顺序进行检查的，如果第一个状态是 False，则检查下一个分支，如果有一个条件为True，就执行这个分支的语句，整个语句结束，==就算有多个分支为True，那么也只执行第一个为真的分支内容==。