import UIKit


//MARK: 1.1 泛型作用
/*
 泛型作用：使用泛型我们不仅可以避免重复的代码而且能以更加清晰抽象的函数实现方式
 */
// 例子 1 交换函数
func exchangeInt(_ a: inout Int, _ b: inout Int) {
    let temp = a
    a = b
    b = temp
}

func exchangeString(_ a: inout String, _ b: inout String) {
    let temp = a
    a = b
    b = temp
}

func exchangeDouble(_ a: inout Double, _ b: inout Double) {
    let temp = a
    a = b
    b = temp
}

/// 将上述通过泛型函数实现
func exchangeValue<T>(_ a : inout T, _  b : inout T) {
    let temp = a
    a = b
    b = temp
}

func exchangeTest() {
    var a = "hello"
    var b = "world"
    exchangeValue(&a, &b)
    print(a,b)
}

/// 调用
exchangeTest()


// 例子2 多个泛型例子
class ZQArray<K, V> {
    var keys = [K]()
    var values = [V]()
    
    func pushKey(_ item: K){
        keys.append(item)
    }
    
    func popKey() -> K {
        return keys.removeLast()
    }
    
    func pushVaule(_ item: V){
        values.append(item)
    }
    
    func popVaule() -> V {
        return values.removeLast()
    }
}

//MARK: 1.2 泛型的参数类型
/*
 例如：Dictionary <Key，Value>中的Key、Value 以及 Array <Element> 中的 Element
 */

/// 定义泛型类型参数
struct Stack<Element> {
    var items = [Element]()
    mutating func push(_ item:Element){
        items.append(item)
    }
    mutating func pop(_ item:Element) -> Element {
        return items.removeLast()
    }
}

func stackTest() {
    var stack_int = Stack<Int>()
    stack_int.push(7)
    stack_int.push(3)
    stack_int.push(2)
    print(stack_int)
    
    var stack_string = Stack<String>()
    stack_string.push("hello")
    stack_string.push("world")
    print(stack_string)
}

/// 调用
stackTest()

//MARK: 1.3 泛型类型的扩展
extension Stack {
    var lastItem : Element? {
        items.last
    }
}

func stactTest2() {
    //调用
    var stack_string = Stack<Int>()
    stack_string.push(1)
    stack_string.push(2)
    if let lastItem = stack_string.lastItem {
       print(lastItem)
    }
}
stactTest2()

//MARK: 1.4 泛型类型约束
/*
 Swift中 Dictionary 的 Key 便被约束为必须遵守 hashable 协议
 */
/// T 需遵守 Equatable 协议
func findIndex<T: Equatable>(of valueToFind: T, in array:[T]) -> Int? {
    for (index, value) in array.enumerated() {
        if value == valueToFind {
            return index
        }
    }
    return nil
}

findIndex(of: 5, in: [1,2,3,4,5,5,5,5,6])


//MARK: 1.5 类型关联
/*
 关联类型的作用，关联类型使用关键字 associatedtype指 定,在定义协议的时候可以使用
 */

//定义协议使用类型关联
protocol Container {
    
    associatedtype Item
    // 关联类型需要遵循 Equatable 协议
//    associatedtype Item: Equatable
    mutating func append(_ item : Item)
    var count : Int{get}
    subscript(i:Int)->Item{get}
    
    /// 与 SuffixableContainer suffix 函数作用一致
    func suffix2(_ size : Int) -> Self
}

//定义泛型 Stack 类型
struct ZQStack<Element: Equatable> : SuffixableContainer {
    //实现协议
    typealias Item = Element
    
    var items = [Element]()
    mutating func push(_ item:Element){
        items.append(item)
    }
    mutating func pop(_ item:Element) -> Element {
        return items.removeLast()
    }
    
    //自动提示为`Element`
    mutating func append(_ item: Element) {
        push(item)
    }
    var count: Int {
        items.count
    }
    
    /// 获取下标对应元素
    subscript(i: Int) -> Element {
        items[i]
    }
    
    func suffix2(_ size: Int) -> Self {
        var result = ZQStack()
        for index in (count-size)..<count {
            result.append(self[index])
        }
        return result
    }
    
    func suffix(_ size: Int) -> Self {
        var result = ZQStack()
        for index in (count-size)..<count {
            result.append(self[index])
        }
        return result
    }
}


protocol SuffixableContainer : Container {
    /*约束条件有两个：
     1.实现此协议时指定的`suffix`的类型必须是实现`SuffixableContainer`协议的类型
     2.此`suffix`占位的容器类型的存储项类型`Item`必须与当前实现此协议的存储项保持一致。
     */
    associatedtype suffix : SuffixableContainer where suffix.Item == Item
    
    /*`item`关联类型的实际类型由泛型类型的占位类型决定。*/
    func suffix(_ size : Int) -> suffix
    
}

func stackTest2() {
    var stack = ZQStack<Int>()
    for index in 1...5 {
        stack.append(index)
    }
    print(stack)
    print("count: \(stack.count)")
    print(stack.suffix(2))
    print(stack.suffix2(2))
}

stackTest2()


//MARK: 1.6 泛型的where闭包
/*
 where闭包能要求关联类型必须遵守某个特定的协议，或特定的类型参数与关联类型必须相等
 */
func containerIsEqual<C1: Container,C2: Container>(
    _ someContainer : C1 ,
    _ anotherContainer : C2) -> Bool where C1.Item == C2.Item, C1.Item: Equatable {
    /*
      where闭包对于关联类型的约束：
      1.容器元素类型一致，
      2.元素的类型遵守`Equatable`协议
     */
    if someContainer.count != anotherContainer.count {
        return false
    }
    for i in 0..<someContainer.count {
        if someContainer[i] != anotherContainer[i] {
            return false
        }
    }
    return true
}

//MARK: 1.7 使用where闭包扩展泛型
/*
通过类扩展来限制 Item 需要遵循 Equatable
*/
extension ZQStack where Element: Equatable {
    func isTop(_ item: Element) -> Bool {
        guard let topItem = items.last else {
            return false
        }
        return topItem == item
    }
}
//调用
struct NotEquatable: Equatable {
}
// ZQStack 元素类型需要遵循 Equatable 协议
var notEquatableStack = ZQStack<NotEquatable>()
let notEquatableValue = NotEquatable()
notEquatableStack.push(notEquatableValue)
notEquatableStack.isTop(notEquatableValue)

/*
通过扩展协议来限制 Item 需要遵循 Equatable，
这样的好处：不必强制 ZQStack 的元素都遵循了 Equatable
*/
extension Container where Item: Equatable {
//若`startsWith`函数名不与`container`中要求重名，则`startsWith`便是为遵守此协议的类型增加了新的方法。
    func startsWith(_ item: Item) -> Bool {
        return count >= 1 && self[0] == item
    }
}

//MARK: 1.8 关联类型使用泛型 where闭包。
protocol Container2 {
    associatedtype Item
    mutating func append(_ item: Item)
    var count: Int { get }
    subscript(i: Int) -> Item { get }
    
    associatedtype Iterator : IteratorProtocol where Iterator.Element == Item
    func makeIterator() -> Iterator
}

//构建迭代器
struct Iterator<T> : IteratorProtocol{
    var stack : ZQStack2<T>
    var count = 0
    
    init(_ stack : ZQStack2<T>) {
        self.stack = stack
    }
    
    typealias Element = T

    mutating func next() -> T? {
        let next = stack.count - 1 - count
        guard next >= 0 else {
            return nil
        }
        count += 1
        return stack[next]
    }
}

//我们的泛型`Stack`需要实现`Sequence`协议
struct ZQStack2<Element> : Container2, Sequence {
    
    //container只能用作泛型约束。
    var items = [Element]()
    mutating func push(_ item:Element){
        items.append(item)
    }
    mutating func pop(_ item:Element) -> Element {
        return items.removeLast()
    }
    //实现协议
    typealias Item = Element
    //自动提示为`Element`
    mutating func append(_ item: Element) {
        push(item)
    }
    var count: Int {
        items.count
    }
    subscript(i: Int) -> Element {
        items[i]
    }
    //迭代器的实现
    typealias IteratorType = Iterator<Element>
    func makeIterator() -> IteratorType {
        return Iterator.init(self)
    }
}

func stack2Test() {
    //调用
    var stack_int = ZQStack2<Int>()
    stack_int.push(7)
    stack_int.push(3)
    stack_int.push(2)
    stack_int.append(4)
    for item in stack_int {
        print(item)
    }
}
stack2Test()

//MARK: 2.1 通过泛型实现 Array map fliter
/*
 2.1 通过泛型实现 Array map fliter
 */
extension Array {
    /// 实现 map 函数
    func zqMap<T>(transform: (Element) -> T) -> [T] {
        var result: [T] = []
        for x in self {
            result.append(transform(x))
        }
        return result
    }
    
    func zqFilter(includeElement: (Element) -> Bool) -> [Element] {
        var result: [Element] = []
        for x in self {
            if includeElement(x) {
                result.append(x)
            }
        }
        return result
    }
    
    func zqReduce<T>(initialValue: T, combine: (T, Element) -> T) -> T {
        var result = initialValue
        for x in self {
            result = combine(result, x)
        }
        return result
    }
}

func arrayTest()  {
    let a = [1,2,3,4,5]
    let a2 = a.zqMap { String($0) }
    let a3 = a.zqFilter { $0>=3 }
    let a4 = a.zqReduce(initialValue: 10) { $0+$1 }
    
    print("\(a2)")
    print("\(a3)")
    print("\(a4)")
}

arrayTest()
