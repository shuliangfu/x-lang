# CORE-001 core.types 泛型 size_of / align_of v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`CORE-008`（mem intrinsic）、`NEXT.md` P0

---

## 1. 目标

| ID | 交付 |
|----|------|
| CORE-001 | `size_of<T>()` / `align_of<T>()` 泛型布局 API |
| 验收 | typeck + 金样覆盖标量/指针/结构体/数组；gate 全绿 |

---

## 2. API

```su
import("core.types");

let n: i32 = size_of<i32>();      // 4
let a: i32 = align_of<*u8>();     // 8（64 位）
let s: i32 = size_of<MyStruct>(); // 结构体布局
```

- 标量 `size_of_i32()` 等保留（自举/无泛型调用路径）。
- 泛型调用 **无值实参**；编译器在 typeck/codegen **compile-time** 折叠为 `i32` 常量。

---

## 3. 编译器挂钩

| 阶段 | 行为 |
|------|------|
| typeck | `size_of<T>()` / `align_of<T>()` → `type_size_of` / `type_align_of` |
| codegen 调用点 | 直接发射整型字面量 |
| codegen 单态化体 | `return <常量>;` |

---

## 4. 金样

`tests/core-types-size/generic_layout.sx`：

- `i32` / `u8` 标量
- `*u8` 指针
- 本地 `struct Pair { a: i32; b: i32; }`
- `[4]u8` 定长数组

---

## 5. Gate

```bash
./tests/run-core-types-generic-layout-gate.sh
```

manifest：`tests/baseline/core-types-generic-layout.tsv`
