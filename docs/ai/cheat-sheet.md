# X language · Agent cheat-sheet（一页）

> **真源**：完整规则见 [`docs/`](../README.md)。本页是**精摘**，冲突以 docs + 编译器为准。  
> **扩展名**：`.x` · **CLI**：`xlang`  
> **更新**：2026-08-06 · 与 AI 友好材料同波（仅文档）

---

## 1. 最小可运行

```x
const fmt = import("std.fmt");

function main(): void {
  fmt.println("Hello World");
}
```

权威产品示例：[`examples/hello.x`](../../examples/hello.x)。

- `main(): void` → 正常结束等价 exit 0。  
- 需要退出码：`function main(): i32 { return 1; }`。

---

## 2. 标准形（只记这一套）

| 结构 | 写法 |
|------|------|
| 函数 | `function name(a: i32, b: i32): i32 { return a + b; }` |
| 导出 | `export function …` / `export struct …` |
| 变量 | `let x: i32 = 0;`（**类型必写**） |
| 常量 | `const N: i32 = 1;` |
| 结构体 | `struct Point { x: i32; y: i32; }` |
| 字面量 | `Point { x: 0, y: 0 }` |
| 字段 | `p.x`（**指针也用 `.`，没有 `->`**） |
| 模块 | `const io = import("std.io");` → `io.something(...)` |
| 不安全 | `unsafe { … }`（裸指针解引用等） |
| 属性 | `#[cfg(...)]` · `#[no_mangle]` · `#[repr(C)]` … |
| 注释 | `//` · `/* */` · 公开 API 用英文 `/** … */`（JSDoc：`@param` / `@return`） |

**没有**：`fn` · `func` · `use` · `package` · `crate::` · `obj->field` · 无类型 `let x = 1`。

---

## 3. 类型速查

| 类 | 写法 |
|----|------|
| 整数 | `i8` `i16` `i32` `i64` · `u8` `u16` `u32` `u64` · `usize` `isize` |
| 浮点 / 布尔 | `f32` `f64` · `bool` |
| 指针 | `*T` · `*u8`（C 字符串常见） |
| 数组 / 切片 | `T[N]` · `T[]`（带长度；**不是** `[]T` / Rust `&[u8]`） |
| 文本现状 | 字面量常当 `*u8`；拥有串走库 **`std.string`**（`String` / `StrView`），**非**语言关键字 `string`（语言级 string 自举后另议） |

---

## 4. import / 模块

```x
const fmt = import("std.fmt");
const io = import("std.io");
// 相对路径：const h = import("./helper.x");
```

- **只能** `import("…")` 绑定到 `const`；不能 `import foo`。  
- 跨模块用公开符号须 **`export`**（strict 默认）。  
- 逻辑名如 `"std.fs"` → 目录 `std/fs/…`（见 docs/05）。

---

## 5. 控制流（最短）

`if` / `else` · `while` · `loop` · `for (init; cond; step)` · `break` / `continue` · `return` · `match` · `defer { … }` · `panic` / `panic(msg)` · `goto`（少用）。

语句：`let` / `const` / `return` / 表达式语句等需 **`;`**（块以 `}` 结束的写法见 docs/08；实现与 ASI 细节以编译器为准，**新代码建议始终写分号**）。

---

## 6. 安全边界

| 默认 | 危险操作 |
|------|----------|
| 安全子集 | 裸指针解引用、部分 FFI/asm 等 → **`unsafe { … }`** |
| 错误 | 优先显式返回码 / `core.result` 风格，少 silent null |

---

## 7. 常用模块（入口，不是完整 API）

| 需求 | 先看 |
|------|------|
| 打印 | `std.fmt` |
| 读写 / 批 IO | `std.io` |
| 文件 | `std.fs` · 路径 `std.path` |
| 堆 / 缓冲 | `std.heap` · `std.mem` |
| 字符串库 | `std.string` · 字节视图 `core.str` |
| 断言 | `core.debug`（`assert` / `assert_eq_*`） |
| 进程 | `std.process` |
| 网络 | `std.net` |

完整表：[`docs/07-内置与标准库.md`](../07-内置与标准库.md)。**禁止编造**不存在的 `println!` / `fmt.Println`。

---

## 8. Agent 强制纪律（应用轨）

| Do | Don't |
|----|-------|
| 小步生成，改完用真 `xlang` 验 | 一次喷 200 行靠「感觉」 |
| 字段只用 `.` | 写 `->` |
| `function` + 返回类型 + `let` 类型 | `fn` / 省略类型 |
| API 查 docs/07 或源码 `export` | 发明 std 函数名 |
| 公开 API 写英文 `/** */` | 用中文当唯一规格 |
| 应用项目用 check/build | 把自举 L4 全擦当写 hello 的步骤 |

修幻觉对照表 → [anti-patterns.md](./anti-patterns.md)。  
完整模板 → [canonical-shape.md](./canonical-shape.md)。
