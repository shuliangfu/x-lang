# Canonical X Shape（官方生成模板）

> **目的**：人与 AI **只抄这一族形状**，降低写法分叉与幻觉。  
> **真源语法**：[`docs/05`](../05-函数与模块.md) · [`docs/06`](../06-变量与常量.md) · [`docs/02`](../02-类型定义.md)。  
> **可运行锚点**：[`examples/hello.x`](../../examples/hello.x)。  
> **维护**：新增官方示例 / Skill / MCP prompt 时 **对齐本文**；勿另起第二套「更像 Rust」的示例方言。

---

## 0. 形状纪律

1. 关键字用全称：`function` / `struct` / `import` / `export` / `unsafe`。  
2. 所有 `let` / 参数 / 返回值 **显式类型**。  
3. 字段访问 **只有 `.`**。  
4. 模块访问：`const m = import("…");` 再 `m.name`。  
5. 跨模块公开 API：`export` + 英文 JSDoc（G.9 风格）。  
6. 模板里的 `…` 表示省略；**不要**把省略号写进真实源文件。

---

## 1. 程序入口

### 1.1 void main（推荐 Hello）

```x
const fmt = import("std.fmt");

function main(): void {
  fmt.println("Hello World");
}
```

### 1.2 退出码 main

```x
function main(): i32 {
  return 0;
}
```

---

## 2. 函数

### 2.1 模块私有

```x
function add(a: i32, b: i32): i32 {
  return a + b;
}
```

### 2.2 导出 + 文档（公开 API 标准形）

```x
/**
 * Add two integers.
 * @param a i32 — left operand
 * @param b i32 — right operand
 * @return i32 — sum a + b
 */
export function add(a: i32, b: i32): i32 {
  return a + b;
}
```

### 2.3 无返回值

```x
export function log_ok(): void {
  return;
}
```

---

## 3. 变量与常量

```x
function demo(): i32 {
  const answer: i32 = 42;
  let n: i32 = 0;
  n = n + 1;
  return n + answer;
}
```

**错误形（不要生成）**：`let n = 0;`（缺类型）。

---

## 4. 结构体

```x
export struct Point {
  x: i32;
  y: i32;
}

export function origin(): Point {
  return Point { x: 0, y: 0 };
}

export function point_x(p: Point): i32 {
  return p.x;
}
```

指针接收者同样用 `.`：

```x
export function set_x(p: *Point, v: i32): void {
  unsafe {
    p.x = v;
  }
}
```

（具体哪些操作必须 `unsafe` 以 typeck 为准；**宁多包一层 unsafe 也不要省略**。）

---

## 5. import 与调用

```x
const io = import("std.io");
const process = import("std.process");

function main(): i32 {
  // 使用 io / process 的 export API（以模块源码为准，勿编造名字）
  return process.getpid();
}
```

多模块：

```x
const fmt = import("std.fmt");
const path = import("std.path");
```

相对路径模块：

```x
const helper = import("./helper.x");
```

---

## 6. 控制流骨架

```x
function abs_i32(x: i32): i32 {
  if (x < 0) {
    return 0 - x;
  }
  return x;
}

function sum_to(n: i32): i32 {
  let i: i32 = 0;
  let s: i32 = 0;
  while (i < n) {
    s = s + i;
    i = i + 1;
  }
  return s;
}
```

`match`（表达式；臂以 `;` 结束，见 docs/03）：

```x
function classify(x: i32): i32 {
  return match x {
    0 => 0;
    1 => 1;
    _ => 2;
  };
}
```

语句位 match（臂可 `return`）：

```x
function early(x: i32): i32 {
  match x {
    1 => return 2;
    _ => return 0;
  }
}
```

---

## 7. 切片 / 缓冲区（常见应用形）

```x
// 固定数组
let buf: u8[16] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

// 切片类型写作 T[]（不是 []T）
// 具体构造/传参以 docs/02 与 std API 为准
```

字节串字面量常见路径：`*u8` + 长度参数（看函数签名），或 `std.string` 类型。

---

## 8. 条件编译（属性形优先）

```x
#[cfg(target_os = "linux")]
export function only_linux(): i32 {
  return 1;
}

#[cfg(target_os = "macos")]
export function only_macos(): i32 {
  return 1;
}
```

详见 [`docs/09-条件编译.md`](../09-条件编译.md)。

---

## 9. 链接属性（系统 / FFI 常见）

```x
/**
 * Surface short name for linker.
 * PLATFORM: SHARED — keep in sync with callers
 */
#[no_mangle]
export function my_c_name(x: i32): i32 {
  return x;
}
```

---

## 10. 库模块形（无 main）

```x
/**
 * Double an i32.
 * @param x i32 — input
 * @return i32 — x * 2
 */
export function double(x: i32): i32 {
  return x + x;
}
```

调用方：

```x
const lib = import("./lib.x");

function main(): i32 {
  return lib.double(21);
}
```

---

## 11. 生成检查清单（Agent 贴完自检）

- [ ] 无 `fn` / `->` / `use` / `package` / `crate`  
- [ ] 每个 `let` 与参数有类型  
- [ ] 每个函数有返回类型  
- [ ] import 只有 `const x = import("…");`  
- [ ] 跨文件符号已 `export`  
- [ ] 公开 API 有英文 `/**` 块（`@param` 含类型）  
- [ ] 未编造 std 函数名  
- [ ] 已用真编译器对改动文件跑 check/build（应用项目）  

失败对照：[anti-patterns.md](./anti-patterns.md)。
