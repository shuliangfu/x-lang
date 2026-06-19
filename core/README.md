# core/ — 标准库 core（无 OS 依赖）

**标准库的 core 层**：不依赖操作系统，可在裸机、内核、嵌入式环境使用。

- **用途**：用户通过 `const m = import("core.xxx");` 引用；编译器解析到本目录下对应模块（如 `core/types/mod.sx`）。
- **原则**：不依赖 libc/OS；按需链接，用不到的模块不进入最终二进制。嵌入式目标仅链接 core（及可选最小 std）。
- **Phase 2 路线图**：根目录 `NEXT.md`；横切门禁 `tests/run-core-api-gate.sh`（CORE-014）。

## core 模块（11 个 · 与 docs/07 同步）

| 模块 | 说明 |
|------|------|
| `core.types` | 标量 `size_of_*` / `align_of_*`；泛型 `size_of<T>` / `align_of<T>` |
| `core.mem` | `mem_copy` / `mem_set` / `mem_compare` / `mem_zero`；`__builtin_*` 热路径 |
| `core.option` | `Option_*` 与 `map` / `and_then` / `unwrap_or<T>` |
| `core.result` | `Result_*` 与 `map` / `and_then` / `or_else` |
| `core.slice` | 切片 `subslice` / `split_at` / `chunks` |
| `core.fmt` | `fmt_*_to_buf`；usize/isize/指针与 f64 特殊值 |
| `core.builtin` | `clz/ctz/popcount` + `bswap/rotl/rotr`；`copy` |
| `core.debug` | `assert_*`；诊断辅助 |
| `core.cmp` | `Ordering`；`cmp_i32` / `cmp_u8` / `cmp_ptr` |
| `core.iterator` | `SliceIter_*` / `next_*` 迭代协议 |
| `core.str` | `BytesView`；`bytes_view_index_of*` / `starts_with` |

详见 [`docs/07-内置与标准库.md`](../docs/07-内置与标准库.md) 与 `analysis/core-readme-sync-v1.md`（CORE-015 gate）。
