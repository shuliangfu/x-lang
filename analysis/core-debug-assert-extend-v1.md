# CORE-012 core.debug 断言类型扩展 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` CORE-012、`core/debug/mod.sx`

---

## 1. 目标

在既有 `assert_eq_i32` / `assert_eq_u32` / `assert_eq_bool` 基础上，补齐测试与自举常用类型的相等/不等断言。

| API | 类型 | 行为 |
|-----|------|------|
| `assert_eq_u64` / `assert_ne_u64` | u64 | 按值比较 |
| `assert_ne_bool` | bool | 补全 bool 不等断言 |
| `assert_eq_ptr` / `assert_ne_ptr` | `*u8` | 按地址比较；`null == null` |

所有函数条件不满足时调用 `panic()`；成功返回 `0`（与既有 API 一致）。

---

## 2. 金样向量

| 场景 | 期望 |
|------|------|
| `assert_eq_u64(0, 0)` | 通过 |
| `assert_eq_u64(18446744073709551615, 18446744073709551615)` | U64_MAX 通过 |
| `assert_ne_u64(1, 2)` | 通过 |
| `assert_eq_bool(true, true)` | 通过（既有） |
| `assert_ne_bool(true, false)` | 通过 |
| `assert_eq_ptr(&x[0], &x[0])` | 同址通过 |
| `assert_eq_ptr(null, null)` | null 通过 |
| `assert_ne_ptr(&x[0], &x[2])` | 异址通过 |

---

## 3. 设计约束

- **零 OS 依赖**：仅比较 + `panic()`，无格式化输出。
- **指针语义**：`assert_eq_ptr` 比较地址，不解引用；与 `core.fmt.fmt_ptr_to_buf` 调试用途一致。
- **扩展方向**：i64/usize 等等价族留待后续；v1 聚焦 NEXT 验收项 u64/bool/指针。

---

## 4. Gate

- manifest：`tests/baseline/core-debug-assert-extend.tsv`
- typeck：`shux check tests/debug/assert_extend.sx`
- 报告：`shux: [SHUX_CORE_DEBUG_ASSERT_EXTEND] status=ok`

---

## 5. 演进

- 泛型 `assert_eq<T>` 或宏化留待语言能力就绪。
- `assert_eq_usize` / `assert_eq_i64` 可按需追加（非 CORE-012 范围）。
