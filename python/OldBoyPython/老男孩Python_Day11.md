# 老男孩Python_Day11

## 装饰器

不想修改函数的调用方式,但是还想在原来的函数前后添加功能

装饰器的本质:闭包函数

## 装饰器形成的过程

## 装饰器的作用

不修改函数的调用方式,但是还在原来的函数前后添加功能

## 编程的原则

- 依赖倒置原则
- 开放封闭原则
  - 开放:对扩展是开放的
  - 封闭:对修改是封闭的

封版   修改---->重构

**语法糖**: @timmer == "func = timmer(func)"

## 装饰器的固定模式

```python
def wrapper(func):
    def inner(*args,**kwargs):
        '''在被装饰函数之前要做的事'''
        ret =func(*args,**kwargs)
        '''在被装饰函数之后要做的事'''
        return  ret
    return inner

@wrapper
def func(*args,**kwargs):
    pass
    return 0
```

