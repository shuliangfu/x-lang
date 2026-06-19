# CORE-013 core.types i16/u16 与标量宽度表 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` CORE-013、`core/types/mod.sx`、`compiler/src/typeck/typeck.c`、`compiler/src/codegen/codegen.c`

---

## 1. 目标

补齐 16 位整数 `size_of_*` / `align_of_*`，并发布与 codegen 布局挂钩一致的**标量宽度表**。

| API | 返回值 |
|-----|--------|
| `size_of_i16()` / `size_of_u16()` | 2 |
| `align_of_i16()` / `align_of_u16()` | 2 |

`size_of<i16>()` / `align_of<i16>()` 泛型折叠：typeck/codegen 在 NAMED `"i16"`/`"u16"` 路径返回 2（为后续语言级 i16 预留）。

---

## 2. 标量宽度表（64 位目标 · v1）

| 类型 | size（B） | align（B） | 备注 |
|------|-----------|------------|------|
| `u8` | 1 | 1 | |
| `bool` | 1 | 1 | core.types 逻辑宽度；codegen 存储可能按 4B（见 LANG ABI） |
| `i16` / `u16` | 2 | 2 | **CORE-013** |
| `i32` / `u32` / `f32` | 4 | 4 | |
| `i64` / `u64` / `f64` / `usize` / `isize` | 8 | 8 | |
| `*T` | 8 | 8 | 64 位指针 |

---

## 3. 编译器挂钩（CORE-013）

| 阶段 | 位置 | 行为 |
|------|------|------|
| typeck | `type_size_of` / `type_align_of` NAMED | `"i16"`/`"u16"` → 2 |
| codegen | `codegen_type_size_of` / `codegen_type_align_of` NAMED | 同上 |

与 CORE-001 泛型 `size_of<T>()` 折叠共用路径。

---

## 4. 金样

`tests/core-types-size/i16_u16_width.sx`：

- `size_of_i16() == size_of_u16() == 2`
- `align_of_i16() == align_of_u16() == 2`
- 与 `main.sx` 标量回归联动

---

## 5. Gate

```bash
./tests/run-core-types-i16-u16-gate.sh
```

manifest：`tests/baseline/core-types-i16-u16.tsv`  
报告：`shux: [SHUX_CORE_TYPES_I16_U16] status=ok`

---

## 6. 演进

- 语言级 `i16`/`u16` 变量与字面量（LANG）落地后，`size_of<i16>()` 烟测纳入 generic_layout。
- `i8`/`u128` 等宽度按同一表扩展（非 CORE-013）。
