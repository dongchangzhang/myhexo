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
# Learning Rust

Rust具有安全高效等语言特性，提供了3个工具：

- cargo: 依赖管理和构建工具
- rustfmt: 代码风格
- Rust Language Server

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

## Cargo

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

## 猜数程序

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

rust 使用 let 关键字创建变量和常量，默认情况下变量是不可变的，若需要可变的变量需要显示用 mut 关键字指出。

``` rust
let foo = bar;     // immutable
let mut foo = bar; // mutable
```

let mut guess = String::new() 语句中，guess 变量绑定到 String::new() 的返回结果，String 是标准库提供的可变的、utf-8 格式的字符串类型，"::" 表示 new 是 String 的一个关联函数，其无需实例化即可调用，类似其他语言的静态函数。new() 方法将创建一个新的 String 空实例。

为了和用户交互，使用了 std::io，io::stdin(&mut guess) 将返回 std::io::Stdin，即标准I/O的一个句柄，read_line 函数将从终端获取用户输入，并**追加**到 guess 字符串变量后，因此，guess必须是一个可变对象。"&" 表示使用了对象的引用，使用引用以避免对变量的重复拷贝。默认情况下，引用和变量相同，均为不可变，因此需要使用 "&mut guess" 而非 "&guess"。

'.expect("...")' 对函数返回结果的潜在风险进行处理。read_line 函数读取用户输入，并返回一个 io::Result 类型的数据。Result 类型广泛存在于多种模块中，其实质是一个枚举类型，其值包括 Err、Ok，若得到的返回值为 Err，则将导致程序 crash 并使用expect提供的信息，若得到 Ok，则返回其携带的数值。若为使用 expect 函数，在编译过程中，rust 将给出警告。

rust 使用 "{}" 作为程序格式化输出的占位符：

``` rust
let x = 5;
let y = 6;
println!("x={}, y={}", x, y);
```

其次，为了完成猜数游戏，需要学习如果获得随机数。rust 的标准库中并不提供随机数的支持，不过其拥有丰富的 crates 作为语言的扩展支持，修改 Cargo.toml 引入 rand 模块的依赖

```
[dependencies]
rand = "0.8.3"
```

cargo 在执行 build 时将自动构建对应的依赖关系，包括 rand 模块本身的依赖内容。其版本号符合 SemVer 标准，表明项目依赖的 rand 模块需要在 0.8.3 到 0.9.0 之间，高于或等于 0.9.0 则无法保证 api 的一致性。cargo build 将只对程序修改内容进行编译，引入的 crates 只会编译一次。Cargo.lock 指明了依赖项目的版本，从而保证任何时间、任何人都可以成功编译这份项目。在 crates 有可升级的版本时，请在项目根目录下执行 cargo update。若需要大版本的更新，请修改 Cargo.toml 文件。

下面使用 rand 生成 1 到 100 的随机数：

``` rust
use rand::Rng;

fn main() {
    let secret_number = rand::thread_rng().gen_range(1..101);
}
```

Rng trait 中定义了很多关于随机数生成方法的接口，为了使用这些方法，首先使用 use 引入。rand::thread_rng 提供了随机数生成器：在当前线程并使用系统种子运行。利用 gen_range 生成 1 到 100 之间的随机数，范围左闭右开，当然，也可 "1..=100"。

当使用一个新的 crate 时，可以在项目目录中使用命令 cargo doc --open 查看所有模块的文档。

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

为了进行结果的比较，需要引入 Ordering，类似于 Result，其亦为枚举类型，不过其包含 Greater、Less、Equal 三个元素。使用变量的内联方法 cmp 对两个数值结果进行比较，其将返回一个 Ordering 类型的结果，使用 match 对该结果进行分支比较，其依次比较 3 种 Ordering 的可能值，当匹配成功则执行 => 后的语句，可以使用 "{}" 执行多条语句。

不过 cmp 函数需要比较相同的类型，如整数和 string 执行 cmp，只能得到无法通过编译的结果。rust 内置了一些基本的类型，比如数字的 i32，u32，i64，u64 等，分别表示有符号和无符号的 32 位和 64 位整形数据，在定义变量时可明确指出：

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

rust 可以使用 loop 进行循环

``` rust
fn main() {
    loop {
        // loop body
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
            Err(_) => continue,
        };
        // ...
    }
}
```

完整程序如下：

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
