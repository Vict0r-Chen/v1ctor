---
title: IOS开发之Swift学习笔记
tags:
  - IOS
  - Swift
categories:
  - IOS
abbrlink: 744023512
date: 2022-11-27 01:05:33
---

为了一个小想法，没想到我竟然花了688￥（一年）注册Apple开发者😂这属实是冲动消费了，希望一年内能上一两个APP值回票价吧！

{% asset_img iosdeveloper.png %}

周五晚上付款，本以为半小时就能审核通过，没想到现在周日凌晨1点了还在审核中。（Update: 最终是到周一下午时提醒我上传身份证，上传后几分钟立刻就通过了）

一开始是打算用Flutter来实现，后面想着我主要是考虑在IOS端使用，于是换成Swift了（虽然这两种语言我都不会🤣）。

所以在审核期间先多学习下Swift的基础知识，本文便用作学习记录~

<!-- more -->

---

# 资源

## 网站

* [Replit](https://replit.com/languages/swift/) - 在线执行Swift代码，运行速度快
* [Swift-book](https://docs.swift.org/swift-book/GuidedTour/GuidedTour.html) - 官方教程（英文）
* [The Swift Programming Language](https://swiftgg.gitbook.io/swift/) - 官方文档翻译
* [菜鸟教程](https://www.runoob.com/swift/swift-tutorial.html) - 第三方中文教程，比较简洁

# 基础语法

## 属性

``` swift
class sample {
    //self 属性: 类型的每一个实例都有一个隐含属性叫做self，self 完全等同于该实例本身

    //静态属性 sample.Version
    static var Version: String = "1.0.0";
    //实例属性
    var no1 = 0.0, no2 = 0.0
    var length = 300.0, breadth = 150.0
    //计算属性 可写可读
    var middle: (Double, Double) {
        get{
            return (length / 2, breadth / 2)
        }
        set(axis){
            //此处的axis是此计算属性传入的(Double, Double)， axis.0即是第0个属性
            no1 = axis.0 - (length / 2)
            no2 = axis.1 - (breadth / 2)
        }
    }
    //计算属性 只读（字典[Double:Double]集合）
    var readonlyProp: [String:Double] {
        return [
            "no1": self.no1,
            "no2": self.no2
        ]
    }
    //属性观察器
    //存储属性在构造器中赋值时，它们的值是被直接设置的，不会触发任何属性观测器。
    var counter: Int = 0{
        willSet(newTotal){
          print("counter willSet: \(newTotal)")
        }
        didSet{
          print("counter didSet, newValue: \(counter), oldValue: \(oldValue)")
        }
    }
}

var result = sample()
print(result.middle)//(150.0, 75.0)
result.middle = (0.0, 10.0)

print(result.no1)//-150.0
print(result.no2)//-65.0

print(result.readonlyProp)//["no2": -65.0, "no1": -150.0]

print(sample.Version)//"1.0.0"

result.counter = 100
/* 输出
counter willSet: 100
counter didSet, newValue: 100, oldValue: 0
*/
result.counter = 800
/* 输出
counter willSet: 800
counter didSet, newValue: 800, oldValue: 100
*/
```

## 下标脚本

与C#的索引器差不多，但不得不承认的是这个更灵活、强大，也更复杂：
* 下标脚本允许任意数量的入参索引，并且每个入参类型也没有限制。
* 下标脚本的返回值也可以是任何类型。
* 下标脚本可以使用变量参数和可变参数。
* 一个类或结构体可以根据自身需要提供多个下标脚本实现，在定义下标脚本时通过传入参数的类型进行区分，使用下标脚本时会自动匹配合适的下标脚本实现运行，这就是下标脚本的重载。

``` swift
struct Matrix {
    let rows: Int, columns: Int
    var print: [Double]
    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        print = Array(repeating: 0.0, count: rows * columns)
    }
    subscript(row: Int, column: Int) -> Double {
        get {
            return print[(row * columns) + column]
        }
        set {
            print[(row * columns) + column] = newValue
        }
    }
}
// 创建了一个新的 3 行 3 列的Matrix实例
var mat = Matrix(rows: 3, columns: 3)

// 通过下标脚本设置值
mat[0,0] = 1.0
mat[0,1] = 2.0
mat[1,0] = 3.0
mat[1,1] = 5.0

// 通过下标脚本获取值
print("\(mat[0,0])")//1.0
print("\(mat[0,1])")//2.0
print("\(mat[1,0])")//3.0
print("\(mat[1,1])")//5.0
```

## 访问控制

* `public` - 可以访问自己模块中源文件里的任何实体，别人也可以通过引入该模块来访问源文件里的所有实体。
* `internal` - 可以访问自己模块中源文件里的任何实体，但是别人不能访问该模块中源文件里的实体。
* `fileprivate` - 文件内私有，只能在当前源文件中使用。
* `private` - 只能在类中访问，离开了这个类或者结构体的作用域外面就无法访问。


## more...

更多的下次补充...