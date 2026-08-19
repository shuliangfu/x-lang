# X language · Anti-patterns（AI 幻觉对照表）

> **用途**：生成前自检 / 修编译错误 / 审 diff。  
> **编号**：与 [`analysis/AI友好特性分析.md`](../../analysis/AI友好特性分析.md) **H01–H16** 对齐。  
> **真源**：正确语法以 [`docs/`](../README.md) 为准；本表只给**最短**错→对。  
> **维护**：增删 H 编号时同步 AI 友好分析文 §1.2。

图例：

```text
✗  模型常写（错误 / 非 X）
✓  X 正确写法
→  修复提示（给人/Agent）
```

---

## H01 · 成员访问用了 `->`

```text
✗  p->x
✓  p.x
→  源语言只有 `.`；指针也用 `.`。C 的 `->` 由 codegen 决定，不要写在 .x 里。
```

---

## H02 · 用了 `fn` / `func`

```text
✗  fn add(a: i32, b: i32) -> i32 { … }
✗  func add(…)
✓  function add(a: i32, b: i32): i32 { return a + b; }
→  关键字是 function；返回类型用 `: T`，不是 `-> T`。
```

---

## H03 · `let` 省略类型

```text
✗  let n = 0;
✓  let n: i32 = 0;
→  产品路径要求类型注解（常见 P010 类诊断）。始终写 `let name: Type = expr;`。
```

---

## H04 · 错误 import

```text
✗  import std.io;
✗  use std::io;
✗  import "std.io";
✗  const io = @import("std.io");
✓  const io = import("std.io");
→  只有绑定 import：const 名 = import("路径");
```

---

## H05 · 假包管理 / 模块声明

```text
✗  package main
✗  mod foo { … }
✗  crate::foo
✓  一文件一模块；目录布局 + mod.x；用 import("…") 引用
→  新项目用官方布局（见 examples/ 与将来 scaffold），勿 invent cargo/go module 语法。
```

---

## H06 · 切片 / 字符串写成外文形

```text
✗  []u8
✗  &[u8]
✗  let s: string = "hi";          // 语言级 string 非当前默认产品面
✓  u8[] · u8[N] · *u8
✓  拥有串 / 视图走 std.string（String / StrView）或 core.str（BytesView）
→  查函数签名要 *u8+len 还是库类型；勿抄 Rust/Go 字面语法。
```

---

## H07 · 编造打印 / std API

```text
✗  println!("hi");
✗  fmt.Println("hi");
✗  console.log("hi");
✓  const fmt = import("std.fmt");
   fmt.println("hi");             // 以 std.fmt 实际 export 为准
→  禁止编造；查 docs/07 或 std 源码 export 列表。
```

---

## H08 · 跨模块用了未 export 符号

```text
✗  // a.x
   function helper(): i32 { return 1; }
   // b.x
   const a = import("./a.x");
   a.helper();                    // strict 下不可见
✓  export function helper(): i32 { return 1; }
→  公开 API 一律 export；或把调用放进同一模块。
```

---

## H09 · 安全上下文里做危险操作

```text
✗  let v: i32 = *p;               // 若 typeck 要求 unsafe
✓  let v: i32 = 0;
   unsafe { v = *p; }             // 以当前规则为准
→  裸指针解引用 / 部分 FFI / asm 放进 unsafe { }；不要指望编译器静默允许。
```

---

## H10 · 混入 Rust 生命周期 / 外文注解

```text
✗  function f<'a>(x: &'a i32)
✗  // lifetime 'a must outlive …
✓  用 X 的类型与 region/借用规则（见安全相关 docs/analysis）；注释写英文 G.9，不写 'a 语法
→  不要把 Rust 生命周期语法当 X 代码。
```

---

## H11 · 过度承诺 async 模型

```text
✗  假设「完全无色 / 任意 async fn 染色」与某文不一致的写法
✓  按现行 std.async / 文档与可编译 cookbook 示例
→  async 以仓库现行实现与 analysis 异步专文为准；禁止按 Tokio/Rust 臆造。
```

---

## H12 · 分号乱省

```text
✗  依赖「随便省分号一定能过」
✓  let x: i32 = 1;
   return x;
→  新代码：语句后写 `;`。设计上仅部分以 `}` 结尾的形式可省；实现 ASI 细节以编译器为准，省分号易人机/文档不一致。
```

---

## H13 · 公开 API 只有中文注释或无注释

```text
✗  // 把 a 和 b 加起来
   export function add(a: i32, b: i32): i32 { … }
✓  /**
    * Add two integers.
    * @param a i32 — left
    * @param b i32 — right
    * @return i32 — sum
    */
   export function add(a: i32, b: i32): i32 { … }
→  产品约定：.x 公开方法英文 JSDoc（G.9）；便于 Agent few-shot 与将来 xlang doc。
```

---

## H14 · 一次生成过大且不验证

```text
✗  单次输出整仓 / 十余文件，声称「应该能编译」
✓  一次一个函数或一个文件 → xlang check/build → 再扩
→  无闭环的准确率不可接受。应用轨禁止跳过真编译器。
```

---

## H15 · 无视诊断码 / 编造错误含义

```text
✗  不看 code，乱改无关代码「碰绿」
✓  读 path/line/code/message → 必要时 explain CODE → 最小 diff
→  诊断 code 稳定优先；对照本文 H 表与 docs。
```

---

## H16 · 类型位写了 `dyn Trait`

```text
✗  let x: dyn Clone = a;
✗  function take(x: dyn Clone): i32 { … }
✓  let x: Clone = a;
✓  function take(x: Clone): i32 { … }
→  类型位只写 trait 名；`dyn` 前缀是 P013。Rust `dyn Trait` 语感不要带进 X。
```

---

## 快速自检（贴代码前 15 秒）

| # | 问 |
|---|----|
| 1 | 有没有 `fn` / `->` / `use` / `package`？ |
| 2 | 每个 `let` 和参数有类型吗？ |
| 3 | import 是不是 `const x = import("…");`？ |
| 4 | 字段是不是都是 `.`？ |
| 5 | std 函数名是查过的还是编的？ |
| 6 | 跨文件符号 export 了吗？ |
| 7 | 准备跑真 check/build 了吗？ |
| 8 | trait 对象是不是写了 `dyn Trait`？（应写 trait 名） |

---

## 正例锚点

| 需求 | 打开 |
|------|------|
| Hello | [`examples/hello.x`](../../examples/hello.x) |
| 模板族 | [canonical-shape.md](./canonical-shape.md) |
| 一页速查 | [cheat-sheet.md](./cheat-sheet.md) |
| 完整语法 | [`docs/README.md`](../README.md) |
