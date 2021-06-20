---
title: Learning Rust
date: 2021-06-16 00:39:24
tags:
    - rust
    - language
    - learn-note
categories: Language
toc: true
---

闲着没事干，学学 rust，另外计划用 rust 写写算法~，此篇笔记为阅读  [rust online book](https://doc.rust-lang.org/book/) 时记录的，希望能坚持看完，在此给予自己最大的鼓励！

<!-- more -->

Rust具有安全高效等语言特性，提供了3个工具：

- cargo: 依赖管理和构建工具
- rustfmt: 代码风格
- Rust Language Server

# 一、开始学习rust

## hello, world

``` rust
// main.rs
fn main() {
    println!("hello, world!");
}
```

对于这个起点程序，和C语言类似，main 函数是 rust 程序的入口，函数体使用 '{}' 包围，将左大括号和函数声明放在一行是 rust 推荐的编程习惯,此外，rust 语言风格使用 4 个空格来缩进，而非 TAB，且使用分号作为每个语句表达的结束。可以使用 rustfmt 工具格式化代码为官方推荐的格式

``` shell
> rustfmt main.rs
```

和c语言有所区别的是，用于输出的语句 "println!" 非函数，而是 Rust macro，它和函数的直观上的区别在于是否有 "!"，若 "func_name" 则为一个普通的函数

对于简单的 rust 程序，可以使用 rustc 进行编译，并得到可运行的二进制文件

``` shell
> rustc main.rs
```

然而对于复杂的工程，使用 cargo 来管理项目则是更好的选择。

## 使用 Cargo

Cargo 是 Rust 语言系统中的依赖管理和构建工具。利用cargo创建新的项目，并创建所需的文件项，同时在非 git 仓库中将同时初始化 git 并添加 gitignore 文件。

``` shell
> cargo new hello_cargo
> tree hello_cargo
  |- Cargo.toml
  |- src
    |- main.rs

```

在 Cargo.toml 文件中记录了项目相关信息和依赖项目，文件为TOML (Tom’s Obvious, Minimal Language) 格式。Cargo 设计希望将源码放到 src目录中，顶层目录放置 README、LICENSE 等。

构建和运行使用 Cargo 创建的项目很简单，在第一次构建完成后，在顶层目录将创建一个 Cargo.lock 文件用以记录依赖，无需手工管理。

``` shell
> cd hello_cargo
# write binary file into target/
> cargo build 
# exec the program
> cargo run
# or exec the binary file direcly
> ./target/debug/hello_cargo
```

此外 Cargo 提供了快速检测代码但不生成二进制文件的命令，其速度快于 build，所以经常 check 一下刚刚写的代码是个很好的习惯。 

``` shell
> cargo check
```

当程序发版使用时，使用带有 --release 参数的 build 命令生成 release 版本，编译器优化将使程序具备更高效的运行效率，但是编译时间会更长。

``` shell
> cargo build --release
```

# 二、猜数程序实践

实践永远是学习新东西最快的方法。下面使用熟知的猜数游戏学习一些新的语言规则。

首先，使用在上一章 hello world 程序的基础上，引入了一些新的知识点：

``` rust
// main.rs
use std::io;

fn main() {
    println!("Guess the number!");
    println!("Please input your guess.");

    let mut guess = String::new();
    io::stdin()
        .read_line(&mut guess)
        .expect("Failed to read line");
    println!("Your guessd is: {}", guess);
}
```

默认情况下 rust 只引入了少量的类型，为了获取用户的输入输出，需要使用 use 引入 std::io 到作用域中，std 表示 io 是标准库的一部分。

rust 使用 let 关键字创建变量和常量，默认情况下，rust 提供的变量是不可变的，若需要可变的变量需要显式使用 mut 关键字指出。

``` rust
let foo = bar;     // immutable
let mut foo = bar; // mutable
```

let mut guess = String::new() 语句中，guess 变量绑定到 String::new() 的返回结果，String 是标准库提供的可变的、utf-8 格式的字符串类型，"::" 表示 new 是 String 的一个关联函数，其无需实例化即可调用，类似其他语言的静态函数。new() 方法将创建一个新的 String 空实例。

为了和用户交互，使用了 std::io，io::stdin() 将返回 std::io::Stdin，即标准 I/O 的一个句柄，read_line 函数将从终端获取用户输入，并**追加**到 guess 字符串变量后，因此，guess 必须是一个可变对象。"&" 表示使用了对象的引用，使用引用以避免对变量的重复拷贝。默认情况下，引用和变量相同，均为不可变，因此需要使用 "&mut guess" 而非 "&guess"。

'.expect("...")' 对函数返回结果的潜在风险进行处理。read_line 函数读取用户输入，并返回一个 io::Result 类型的数据。Result 类型广泛存在于 rust 的多个模块中，其实质是一个枚举类型，其值包括 Err、Ok，若得到的返回值为 Err，则将导致程序 crash 并使用expect提供的信息，若得到 Ok，则返回其携带的数值。若为使用 expect 函数，在编译过程中，rust 将给出警告。

rust 使用 "{}" 作为程序格式化输出的占位符：

``` rust
let x = 5;
let y = 6;
println!("x={}, y={}", x, y);
```

其次，为了完成猜数游戏，需要学习如何获得随机数。rust 的标准库中并不提供随机数的支持，不过其拥有丰富的 crates 作为语言的扩展支持，修改 Cargo.toml 引入 rand 模块的依赖

```
[dependencies]
rand = "0.8.3"
```

cargo 在执行 build 时将自动构建对应的依赖关系，包括 rand 模块本身的依赖内容。其版本号符合 SemVer 标准，表明项目依赖的 rand 模块需要在 0.8.3 到 0.9.0 之间，高于或等于 0.9.0 则无法保证 api 的一致性。cargo build 将只对程序修改内容进行编译，引入的 crates 只会编译一次。Cargo.lock 指明了依赖项目的版本，从而保证任何时间、任何人都可以成功编译这份项目代码。在 crates 有可升级的版本时，请在项目根目录下执行 cargo update。若需要大版本的更新，请修改 Cargo.toml 文件。

下面使用 rand 生成 1 到 100 的随机数：

``` rust
use rand::Rng;

fn main() {
    let secret_number = rand::thread_rng().gen_range(1..101);
}
```

Rng trait 中定义了很多关于随机数生成方法的接口，为了使用这些方法，首先使用 use 引入。rand::thread_rng 提供了随机数生成器：在当前线程中并使用系统种子运行。利用 gen_range 生成 1 到 100 之间的随机数，范围左闭右开，当然，也可使用 "1..=100" 作为左闭右闭的参数。

当使用一个新的 crate 时，可以在项目目录中使用命令 cargo doc --open 查看当前项目中所有模块的文档。

接下来，需要对用户输入和随机数字进行比较：

``` rust
use std::cmp::Ordering;

fn main() {
    let guess = 2;
    let secret_number = 3;
    match guess.cmp(&secret_number) {
        Ordering::Less => println!("Too small!"),
        Ordering::Greater => println!("Too big!"),
        Ordering::Equal => {
            println!("You win!")
            // more
        },
    }
}

```

为了进行结果的比较，需要引入 Ordering，类似于 Result，其亦为枚举类型，不过其内包含 Greater、Less、Equal 三个元素。使用变量的内联方法 cmp 对两个数值结果进行比较，其将返回一个 Ordering 类型的结果，使用 match 对该结果进行分支比较，依次比较 3 种 Ordering 的可能值，当匹配成功则执行 => 后的语句，可以使用 "{}" 执行多条语句。

不过 cmp 函数需要比较相同的类型，如整数和 string 执行 cmp，将无法通过编译。rust 内置了一些基本的类型，比如数字的 i32，u32，i64，u64 等，分别表示有符号和无符号的 32 位和 64 位整形数据，在定义变量时可明确指出：

``` rust
{
    let secret_number = 3;
    let mut guess = String::new();
    let guess: u32 = guess.trim().parse().expect("Please input number!");
    // get input from terminal here
    match guess.cmp(secret_number) {
        // arms here
    }
}
```

在 rust 中，可以重复定义一个变量，这在将一个数据类型转换为其他数据类型的情况下很有用，无需定义两个不同类型的相同变量。trim 函数将去除字符串前后的空白字符，parse 函数则解析字符串并转换为数字，定义变量时通过 ": u32" 指明 guess 为无符号32位整型数据，因此，rust 在执行 cmp 时，即可隐式推断 secret_number 为一个 u32 类型数据。

rust 可以使用 loop 进行循环，并使用 break 和 continue 实现循环的跳转。

``` rust
fn main() {
    loop {
        // loop body
        // break;
        // continue;
    }
}
```

最后，可以为标准 io 提供更健壮的错误处理方式:

``` rust
fn main() {
    loop {
        // ...
        io::stdin()
            .read_line(&mut guess)
            .expect("Failed to read line");

        let guess: u32 = match guess.trim().parse() {
            Ok(num) => num,
            Err(\_) => continue,
        };
        // ...
    }
}
```

Ok(num) 匹配附带一个参数的 Ok 枚举值，Err(\_) 匹配附带任意参数的错误结果。完整程序如下：

``` rust
use std::io;
use std::cmp::Ordering;
use rand::Rng;

fn main() {
    println!("Guess the number!");

    let secret_number = rand::thread_rng().gen_range(1..=100);

    loop {
        println!("Please input your guess.");
        let mut guess = String::new();

        io::stdin()
            .read_line(&mut guess)
            .expect("Failed to read line");

        // let guess: u32 = guess.trim().parse()
        //                        .expect("Please input a number!");

        let guess: u32 = match guess.trim().parse() {
            Ok(num) => num,
            Err(_) => continue,
        };

        println!("Your guessd is: {}", guess);

        match guess.cmp(&secret_number) {
            Ordering::Less => println!("Too small!"),
            Ordering::Greater => println!("Too Big!"),
            Ordering::Equal => { 
                println!("You win!");
                break;
            },
        }
    }
}
```

# 三、语言基础

在这一部分，主要学习 rust 语言的基础知识，如变量、数据类型、函数、注释以及控制流。

学习之前，请首先[了解 rust 保留的关键字](https://doc.rust-lang.org/book/appendix-01-keywords.html)，在后续程序的编写过程中以避免使用这些关键字来定义自己的名称。

## 变量及其可变性

正如第二章提到的，默认情况下，rust 定义的变量都是不可变的，这与其他语言有所区别，也同样因此使 rust 更具安全性和并发性。当然，也可以根据需要，令定义的变量可变。

如之前所提到的，rust 使用 let 来定义一个变量，如果该变量是不可变的，一旦这个变量绑定到某个值后，其值将不能被改变，当尝试编译如下的程序时，将会失败，并给出 " cannot assign twice to immutable variable" 的警告。

``` rust
fn main() {
    let x = 5;
    println!("x is {}", x);
    x = 6;
    println!("x is {}", x);
}
```

rust 保证了声明为不可变的变量一旦绑定了数值后将永远不再改变，对于这种变量，无需考虑其在何时、何处以及怎样发生改变。

如果需要可变的变量，需要使用 mut 关键字显式声明，只需将 mut 放在变量名前即可。此时我们修改上述程序即可正常编译并运行，因为我们操纵的是一个可变的变量。使用变量的可变性是对错误和效率等问题的权衡和折中，不可变行提供了更高的安全性，而可变变量则可能避免了新变量的反复创建和拷贝等。

``` rust
fn main() {
    // let x = 5;
    let mut x = 5;
    println!("x is {}", x);
    x = 6;
    println!("x is {}", x);
}
```

在其他语言中，有常量（constant）的概念，类似于 rust 的不可变变量，但是 rust 的常量和变量存在一些区别：

- 不允许将 mut 和常量一起使用，因为常量是永远的恒值，而非默认为恒值；
- 当使用 const 而不是 let 来声明一个常量时，必须指明数据类型；
- const 可以声明在任意作用域中，包括全局作用，而 let 无法声明在全局作用域中；
- 常量的值只能是常量表达式，不能是任意一个运行时获取的值。

下面声明了两个常量，rust 建议使用大写作为常量的名称，否则将在编译器给出警告。

``` rust
const MAX: u32 = 123;
fn main() {
    let x = 5;
    const MIN: u32 = 123;
    println!("x is {}, MAX is {}, MIN is {}", x, MAX, MIN);
}
```

除变量不可变的特性外，变量与其他语言仍有一个明显的特点：rust 支持对已定义的变量进行覆盖（常量不具有这样的特性，rust 将其称为 Shadowing），即在已定义的变量后，可以重新定义一个同名的变量来覆盖，如下面给出的程序，最后 x 的值为 7。

``` rust
fn main() {
    let x = 5;
    let x = x + 1;
    let x = x + 1;
    println!("x is {}", x);
}
```

Shadowing 和 mut 是不同的，若没有 let 关键字，这种 "x = x + 1" 对变量的操作是不允许的，通过Shadowing 可以对已有变量进行一些转换并得到新的不可变变量。

除了上述特性外，Shadowing 也可以实现不同类型的转换，这和 mut 是不同的：

``` rust
let spaces = "  ";        // String
let spaces = space.len(); // integer
```

如果使用 mut 来定义 spaces，则无法通过编译，即我们不能改变 mut 变量名的类型。

## 基本数据类型

rust 是静态类型语言，在编译期必须明确各个变量的数据类型。数据类型可以在代码中明确指定，除此外，也可以通过上下文推断。如猜数游戏中，定义 guess 必须指定其类型为 "u32"，否则，parse 函数通过编译。

``` rust
let guess: u32 = "42".parse().expect("Not a number!");
```

下面介绍 rust 数据类型的两个子集：标量类型和复合类型。

### 标量类型

rust 中的标量类型，即在其他语言中常见的如整型、浮点类型、布尔类型和字符类型。

#### 整型

在 rust 表示整形的方法为 "u/i位长度"，u 表示无符号数，i表示有符号整数，包括：

| 长度 | 有符号 | 无符号 |
| :-----: | :----: | :----: |
| 8-bits | i8 | u8 |
| 16-bits | i16 | u16 |
| 32-bits | i32 | u32 |
| 64-bits | i64 | u64 |
| 128-bits | i128 | u128 |
| arch | isize | usize |

可以使用 "i/usize" 使用操作系统支持的整形长度，在对集合进行索引时常常使用到这种类型。此外，rust 支持多种进制的字面值表示：

| 字面值类型 | 表示 |
| :-----: | :----: |
| 10进制 | 123_456_789 |
| 16进制 | 0xABCD |
| 8进制 | 0o77 |
| 2进制 | 0b1111_0000 |
| 字符(u8) | b'A'


#### 浮点类型

rust 使用 f32 和 f64 分别表示 32 位浮点数和 64 位浮点数，rust 默认使用 64 位浮点数。

``` rust
fn main() {
    let a = 1.0;        // f64
    let x: f32 = 1.2;   // f32
    let y: f64 = 2.2;   // f64
}
```

#### 数值操作

同样，rust 为数值类型提供了加减乘除的操作符，其计算结果绑定到一个变量上：

``` rust
fn main() {
    let sum = 1 + 2;
    let dif = 2 - 1;
    let mul = 1 * 2;
    let div = 2 / 1;
    let m   = 2 % 1;
}
```

#### 布尔类型

rust 使用 true、false 作为布尔值 bool 的字面值：

``` rust
fn main() {
    let t = true;
    let f: bool = false; // with explicit type annotation
}
```

#### 字符类型

rust 的 char 类型为 4 字节的长度的 unicode 支持的常量值，能够表示包括中文、日文等多种字符。使用单引号表示：

``` rust
fn main() {
    let c = 'z';
    let z = 'ℤ';
    let heart_eyed_cat = '😻';
}
```

### 复合类型

rust 的复合类型可以将多个数值集合到一个数据类型中来表示，主要有两种：元组（tuples）和数组（arrays）。

#### 元组

元组是一种将多种不同类型数据集合到一起的常用的方法，其一旦创建，长度固定不可修改，元组使用圆括号表示：

``` rust
fn main() {
    let tup: (i32, f64, u8) = (500, 6.4, 1);
}
```

使用元组，有方便的方法对其中的每个元素解包：

``` rust
fn main() {
    let tup = (500, 6.4, 1);

    let (x, y, z) = tup;

    println!("The value of y is: {}", y);
}
```

除此之外，可以通过元组索引来访问其中任意元素，使用 "tuple.index" 实现，其索引范围从 0 开始：

``` rust
fn main() {
    let x: (i32, f64, u8) = (500, 6.4, 1);

    let five_hundred = x.0;

    let six_point_four = x.1;

    let one = x.2;
}
```

#### 数组

数组中的每一个元素的数据类型必须相同，其长度是固定的，使用方括号表示：

``` rust
fn main() {
    let a = [1, 2, 3, 4, 5];
}
```

当所需数据集合为相同类型且希望将数据分配在堆上而不是栈上或始终需要固定数量的数据时，使用数据可能是一个选择，不过，其不如 vector （标准库提供，后续介绍）灵活，后者可动态扩容。若无法明确使用数组或 vector，请使用 vector。

如，程序需要固定的一些信息，使用 array：

``` rust
fn main() {
    let months = ["January", "February", "March", "April", "May", "June", "July",
                "August", "September", "October", "November", "December"];
}
```

声明数组时，也可指明元素类型和长度：

``` rust
let a: [i32; 5] = [1, 2, 3, 4, 5];
```

可以创建一个有相同元素的数组：

``` rust
let a = [3; 5];
```

a 的值为 [3, 3, 3, 3, 3]。

数组的元素值可以使用索引访问：

``` rust
let a = [1, 2, 3, 4, 5];
let first = a[0];
let end   = a[4];
```

在程序中，如果潜在索引越界，程序是可以编译成功的，但当运行时遇到越界问题，将导致程序运行失败。在其他语言中，当遇到越界问题时，程序会继续运行，而 rust 将阻止这种情况的发生，通过立即退出来阻止对非法内存的访问，这里利用所学的语言特性提供了例子

``` rust
use std::io;

fn main() {
    let a = [1, 2, 3, 4, 5];

    println!("input index:");

    let mut index = String::new();

    io::stdin()
        .read_line(&mut index)
        .expect("Faile to read line");

    let index : usize = index.trim().parse().expect("Index not a number"); 

    let element = a[index];

    println!("value is {}, index is {}", element, index);
}
```

## 函数

rust 使用 fn 关键字来定义函数，如所见的 main 函数，我们同样可以定义其他函数，包括无参数函数、有参数函数等，函数参数必须指明数据类型，当然各个参数可以有各自的类型。

``` rust
fn main() {
    test();
    test_args(x: i32, y: i32);
}

fn test() {
    println!("This is test fn");
}

fn test_args(x: i32, y: i32) {
    println!("The arg is x:{}, y:{}", x, y);
}
```

## 程序注释

## 控制流
