# CORE-002/003 Option/Result 类型族与组合子 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` Phase 2、`analysis/exc-result-error-v1-rfc.md`（EXC-001）

---

## 1. 目标

在**尚无函数类型**与**泛型 struct 字面量**的前提下，交付可自举的 Option/Result **具象类型族**与 **eager 组合子**，满足 std/编译器热路径使用。

| ID | 交付 |
|----|------|
| CORE-002 | `Option_i32` / `Option_u8` / `Option_ptr_u8` + `map_*` / `and_then_*` + 泛型 `unwrap_or<T>` |
| CORE-003 | `Result_i32` / `Result_u8` + `map_*` / `and_then_*` / `or_else_*`（含 `or_else_i32`） |

---

## 2. 类型族

### 2.1 Option（`core/option/mod.sx`）

| 类型 | 用途 |
|------|------|
| `Option_i32` | 可空 i32 |
| `Option_u8` | 可空 u8（切片 get） |
| `Option_ptr_u8` | 可空 `*u8` 指针 |

### 2.2 Result（`core/result/mod.sx`）

| 类型 | 用途 |
|------|------|
| `Result_i32` | 值 i32 + err i32（16B 双寄存器 ABI） |
| `Result_u8` | 值 u8 + err i32 |

---

## 3. 组合子语义（eager v1）

语言实参求值先于函数调用，故 v1 **不传回调**：

| 组合子 | 语义 | 惰性版（待 fn 类型） |
|--------|------|----------------------|
| `map_*(opt/r, mapped)` | 有值/Ok 则包入 `mapped` | `f(x)` 回调 |
| `and_then_*(opt/r, next)` | 等价 `and_*` | `f(x)->Option/Result` |
| `or_else_*(r, fallback)` | 等价 `or_*` | `f(err)->Result` |

调用方须在分支内自行计算 `mapped`/`next`，或接受 eager 求值。

### 3.1 泛型辅助

```su
function unwrap_or<T>(is_some: bool, value: T, default_val: T): T
```

与各 `Option_*` 字段联用：`unwrap_or<i32>(opt.is_some, opt.value, 0)`。

---

## 4. 验收

- manifest：`tests/baseline/core-option-result.tsv`
- typeck：`shux check tests/option/main.sx`、`tests/result/main.sx`
- runnable：`tests/run-option.sh`、`tests/run-result.sh`（本机可链接时）
- 报告：`shux: [SHUX_CORE_OPTION_RESULT] status=ok`

---

## 5. 演进

- `struct Option<T>` / `Result<T,E>` 字面量就绪后，逐步替换类型族重复。
- 函数类型就绪后，`map`/`and_then` 增加回调重载，保留 eager 重载兼容。
