# CORE-004 切片泛型 API v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` Phase 2 CORE-004、`core/slice/mod.sx`

---

## 1. 目标

在**尚无泛型切片字面量**与**完整 `T[]` .data 全类型**的前提下，为 `i32[]` / `u8[]` / **`u64[]`**（CORE-157）交付边界安全的 **subslice**、**split_at**、**chunks** API，支撑 std/编译器零拷贝子视图路径。

| API | 语义 |
|-----|------|
| `subslice_*` | `s[start..start+len)`，start/len 钳制；零拷贝 |
| `split_at_*` | `(left, right)` 在 `at` 分裂 |
| `chunks_len_*` | 固定 `chunk_size` 的块数 |
| `chunk_*` | 第 `index` 块（0-based） |
| `is_empty_*` / `first_*` / `last_*` | 轻量边界工具（CORE-157）；如 `is_empty_i32` |
| `len_u64` / `get_u64` / `subslice_u64` | `u64[]` 完整镜像 API（CORE-157；typeck `.data` 已扩展） |

---

## 2. 类型与实现约束

- v1 支持 `u8[]`、`i32[]`、**`u64[]`**（CORE-157）；typeck 已扩展。
- 空切片：`empty_*()` 用栈上 1 元素缓冲 + `length=0`，禁止解引用。
- 子切片构造：勿 `let out = s`（形参 slice 在 C ABI 为指针）；用 `scratch` 数组初始化再写 `.data`/`.length`。
- 与 `core.option` 的 `get_*` 互补：`get` 处理单元素越界；`subslice` 处理区间钳制。
- **CORE-157**：`is_empty_*` / `first_*` / `last_*` 轻量工具；`Option_u64` 供 `get_u64`。

---

## 3. 边界行为（金样）

| 场景 | 期望 |
|------|------|
| `subslice(s, 1, 2)` on len=4 | len=2，元素与原数组 [1..3) 一致 |
| `subslice(s, 10, 5)` | 空切片 length=0 |
| `split_at(s, 2)` on len=4 | left len=2，right len=2 |
| `split_at(s, 99)` | left=全文，right 空 |
| `chunks_len(s, 2)` on len=5 | 3 |
| `chunk(s, 2, 2)` on len=5 | 最后一块 len=1 |
| `chunk(s, 2, 99)` | 空 |
| `chunks_len(s, 0)` | 0 |

---

## 4. 验收

- manifest：`tests/baseline/core-slice-api.tsv`
- typeck：`shux check tests/slice/subslice_split_chunks.sx`
- runnable：`tests/run-slice.sh` 扩展子集
- 报告：`shux: [SHUX_CORE_SLICE_API] status=ok`

---

## 5. 演进

- 泛型 `subslice<T>` / `Iterator`（CORE-006）就绪后收敛命名。
- 扩展 `f64[]` .data 与 API 镜像 `_*_f64` 族。
