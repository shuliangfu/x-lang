# CORE-007 core.str 字节串视图 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` Phase 2 CORE-007、`analysis/std-strview-zc4-v1.md`（STD-016）
> **Honesty 2026-08-24 #11:** top-level DOC retired; live = archive/core/. check smoke observational SKIP (check gate paused 2026-08-05).
> **Honesty 2026-08-25:** runnable hard-green — prefer `xlang_asm`; smoke exit 0 + Cookbook `core_str_index` exit 0 hard-fail (no soft SKIP on product path).

---

## 1. 目标

交付 **无 OS 依赖**的只读字节视图 `BytesView`，语义与 `std.string.StrView` 对齐，供 core/编译器路径零拷贝使用。

| core.str | std.string | 说明 |
|----------|------------|------|
| `BytesView` | `StrView` | `(ptr, len)` 布局一致 |
| `bytes_view` | `string_view` | 包装已有缓冲 |
| `bytes_view_from_slice` | — | 从 `u8[]` 构造 |
| `bytes_view_subview` | `string_view_subview` | 钳制子区间 |
| `bytes_view_eq` | `string_view_eq` | 字节相等 |
| `bytes_view_eq_bytes` | `string_view_eq_slice` | 与裸缓冲比较 |

---

## 2. 生命周期（与 STD-016 一致）

| 来源 | 有效区间 |
|------|----------|
| 栈数组 `bytes_view(&buf[0], n)` | `buf` 栈帧存活期 |
| `u8[]` `bytes_view_from_slice(s)` | 底层切片来源存活期 |
| 子视图 `bytes_view_subview` | 不超过父视图生命周期 |

**不拥有内存**；父失效则子失效。

---

## 3. 边界行为（金样）

| 场景 | 期望 |
|------|------|
| `bytes_view_is_empty(len=0)` | 1 |
| `subview(off=2,len=3)` on len=7 | len=3，内容一致 |
| `subview(off=99,len=1)` | 空视图 |
| `subview(off=5,len=99)` on len=7 | 钳制为 len=2 |
| `eq` 相同/不同字节 | 1 / 0 |

---

## 4. Cookbook

- `examples/cookbook/core_str_index.x`（CSTR-01）：`bytes_view_index_of` / `index_of_byte` / `starts_with`；成功分 **0**

---

## 5. 验收

- manifest：`tests/baseline/core-str-view.tsv`
- typeck（观测）+ runnable hard：`tests/str/bytes_view.x`（exit 0）
- Cookbook runnable hard：`core_str_index.x`（exit 0）
- 报告：`xlang: [XLANG_CORE_STR_VIEW] status=ok check=… run=… cookbook=… skip=…`

---

## 6. 演进

- `std.string` 可选薄封装转调 `core.str`（避免重复逻辑）。
- UTF-8 校验/码点遍历留在 `std.unicode`。
