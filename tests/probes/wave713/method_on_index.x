// wave713 · 4.2.15 impl method on INDEX · 探针
// 验证 a[i].method() / s[i].method() 模式（INDEX 表达式作 method call 接收者）
// 期望：return 0
// 路径：host-C + pure-asm + freestanding 三套

struct S { v: i32 }

impl S {
    fn get(self: S) -> i32 { self.v }
    fn add(self: S, dx: i32) -> i32 { self.v + dx }
}

fn main() -> i32 {
    // 1. fixed array INDEX 接收者
    let a: [S; 2] = [S{v:10}, S{v:32}]
    let i: i32 = 1
    let r1: i32 = a[i].get()           // var-index INDEX 接收者, 期望 32
    let r2: i32 = a[0].add(5)          // INT_LIT INDEX + 多参, 期望 15

    // 2. slice INDEX 接收者
    let s: []S = [S{v:1}, S{v:2}, S{v:3}]
    let r3: i32 = s[2].get()           // slice INDEX 接收者, 期望 3

    // 3. 嵌套 INDEX 作方法实参
    let r4: i32 = a[1].add(s[0].get()) // 期望 32 + 1 = 33

    return r1 + r2 + r3 + r4 - 83      // 32 + 15 + 3 + 33 - 83 = 0
}
