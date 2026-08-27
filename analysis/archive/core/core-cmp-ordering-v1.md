# CORE-005 core.cmp 三路比较与 Ordering v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` Phase 2 CORE-005、`std/sort` 比较器约定
> **Honesty 2026-08-24 #11:** top-level DOC retired; live = archive/core/. check smoke observational SKIP (check gate paused 2026-08-05).

---

## 1. 目标

交付无 OS 依赖的**三路比较**基元，供排序、容器、字典序组合使用。

| API | 语义 |
|-----|------|
| `Ordering` | `code` ∈ {-1, 0, 1} |
| `cmp_i32` / `cmp_u8` | 标量三路比较 |
| `cmp_ptr` | `*u8` 按地址序比较 |
| `reverse` / `then` | 翻转与链式比较 |

---

## 2. Ordering 编码

| 常量 | code | 含义 |
|------|------|------|
| `ORD_LESS` | -1 | a < b |
| `ORD_EQUAL` | 0 | a == b |
| `ORD_GREATER` | 1 | a > b |

与 C `memcmp` / `qsort` 符号约定一致，便于与 `std.sort` 回调互操作。

---

## 3. 边界行为（金样）

| 场景 | 期望 |
|------|------|
| `cmp_i32(1, 2)` | Less |
| `cmp_i32(5, 5)` | Equal |
| `cmp_u8(255, 0)` | Greater |
| `cmp_ptr(&a[0], &a[1])` on 数组 | Less |
| `cmp_ptr(p, p)` | Equal |
| `then(Equal, Greater)` | Greater |
| `reverse(Less)` | Greater |

---

## 4. 验收

- manifest：`tests/baseline/core-cmp-ordering.tsv`
- typeck：`xlang check tests/cmp/main.x`
- runnable：gate 内链接烟测
- 报告：`xlang: [XLANG_CORE_CMP_ORDERING] status=ok`

---


## Gate

```bash
./tests/run-core-cmp-ordering-gate.sh
```

**Honesty (2026-08-28)**：prefer asm + `XLANG_LINK_XLANG`；显式坏 XLANG／缺 native 硬 die；拒 soft SKIP→OK／soft auto-make／prefer-c；产品 `-o` 硬绿（或 tip 残＝obs）；`xlang check`＝obs（暂停闸）；报告 `run=`／`obs=`／`skip=`。

**gate report**：stdout 须含 `core-cmp-ordering gate OK`；失败打印 `core-cmp-ordering gate FAIL:` 行。

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/archive/core/core-cmp-ordering-v1.md` |
| manifest | `tests/baseline/core-cmp-ordering.tsv` |

**状态：定版 ✅（honesty soft→硬绿）**

## 5. 演进

- 泛型 `cmp<T>` / `PartialOrd` trait 待函数类型与泛型就绪。
- `cmp_ptr` 扩展 `*i32` / `usize` 镜像族。
