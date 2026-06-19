# CORE-006 core.iterator 最小迭代协议 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` Phase 2 CORE-006、`core.option`、`core.slice`

---

## 1. 目标

在无 trait / 无泛型 `Iterator<T>` 前提下，交付可自举的**切片迭代器**与 `next` 协议。

| 类型 | API |
|------|-----|
| `SliceIter_i32` | `iter_i32` / `next_i32` / `iter_remaining_i32` |
| `SliceIter_u8` | `iter_u8` / `next_u8` / `iter_remaining_u8` |

`next_*` 返回 `Option_*`：有元素为 `some`，耗尽为 `none`（与 Rust `Iterator::next` 对齐）。

---

## 2. 协议语义

- 迭代器通过 `*SliceIter_*` 可变游标推进（`index` 递增）。
- 状态为 `ptr + length + index`（非嵌套 `[]T`），规避 slice 形参 C ABI 下 struct 字段赋值问题。
- 不拷贝底层数据；生命周期由调用方保证切片有效。
- `iter_remaining_*` 为 O(1) 查询剩余长度。

---

## 3. 边界行为（金样）

| 场景 | 期望 |
|------|------|
| 空切片 `next` | 首次即 `none` |
| 3 元素切片连续 `next` 3 次 | 依次 some(10,20,30) |
| 第 4 次 `next` | `none` |
| 消费 1 个后 `iter_remaining` on len=3 | 2 |

---

## 4. Cookbook

- `examples/cookbook/iter_slice_sum.sx`（ITER-01）：`next_i32` 循环求和

---

## 5. 验收

- manifest：`tests/baseline/core-iterator-protocol.tsv`
- typeck：`shux check tests/iterator/main.sx`
- Cookbook typeck：gate 内校验 `iter_slice_sum.sx`
- 报告：`shux: [SHUX_CORE_ITERATOR] status=ok`

---

## 6. 演进

- `for item in slice` 语法糖对接本协议。
- 泛型 `Iterator<T>` trait + `map`/`filter` 惰性适配器。
