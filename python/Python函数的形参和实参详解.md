# Python函数的形参和实参详解

在这篇文章玩蛇网将给大家介绍[**Python函数**](http://www.iplaypy.com/jichu/function.html)的两种类型参数，一种是函数定义里的**形参**，一种是调用函数时传入的**实参**。

经常在使用一些内置函数的时候，我们需要传入参数，比如：调用math.sin时，需要传入一个[整型数字](http://www.iplaypy.com/jichu/int.html)作为实参，还有的函数需要多个参数，像math.pow就需要2个参数，一个是基数（base）和指数（exponent）。

在函数的内部，实参会被赋值给形参，下面的例子是一个用户自定义的函数，接收一个实参：

```
`#coding=utf-8` `def` `print_twice(bruce):``    ``print` `bruce``    ``print` `bruce ``#<a href="http://www.iplaypy.com/jinjie/return.html" target="_blank" title="python 返回值 return">python 函数返回值可以用return</a>`
```

这个函数的作用是：在调用的时候会把实参的值，给形参bruce，并将其输出2次。

这个函数对任何可以[print输出](http://www.iplaypy.com/jichu/print.html)的值都可用。

```
`>>> print_twice(``'Spam'``)``Spam``Spam``>>> print_twice(``17``)``17``17``>>> pirnt_twice(math.pi)``3.14159265359``3.14159265359`
```

内置函数的组合规则，在用户自定义函数上也同样可用，所以我们可以对print_twice使用任何表达式作为实参：

```
`>>> print_twice(``'Sapm'` `*``4``)``Spam Sapm Spam Sapm``Spam Sapm Spam Sapm` `>>> ``import` `math``>>> print_twice(math.cos(math.pi))``-``1.0``-``1.0`
```

作为实参的表达式，会在函数调用之前先执行，所以在上面例子里面，表达式’Spam’*4和math.cos(math.pi)都只执行一次。

你也可以使用[变量](http://www.iplaypy.com/jichu/var.html)作为实参：

```
`>>> michael ``=` `"Eric, the half a bee."``>>> print_twice(michael)``Eric, the half abee.``Eric, the half abee.`
```

作为实参传入到函数的变量名称和函数定义里形参的名字没有关系。函数里面只关心形参的值，而不去关心它在调用前叫什么名字，在print_twice函数内部，大家都叫bruce.