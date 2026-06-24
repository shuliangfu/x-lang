# 核心库 API 命名规范

> **硬性规则**：核心库方法名不得出现类型名（`i32` `u32` `i64` `usize` `u8` `f32` `f64` `bool` 等）。
> 类型通过参数/返回值/泛型/重载表达，不写进方法名。
> 模块 11 · API 240

---

## 一、核心原则

1. 绑定导入后去模块前缀：`bytes_view_len` → `str.len(...)`。
2. 去类型后缀：`assert_eq_i32` / `assert_eq_u32` → `assert_eq`。
3. 去参数位数后缀：`format_2` / `format_3` → `format`（若存在）。
4. 对象前缀最小化：`view_*` / `iter_*` / `ordering_*` 按语义压缩。

## 二、推荐绑定名

- `core.builtin` → `builtin`
- `core.cmp` → `cmp`
- `core.debug` → `dbg`
- `core.fmt` → `fmt`
- `core.iterator` → `iter`
- `core.mem` → `mem`
- `core.option` → `opt`
- `core.result` → `res`
- `core.slice` → `slice`
- `core.str` → `str`
- `core.types` → `types`

---

## 三、各模块 API 清单

### core.builtin

`core/builtin/mod.sx` · 13 APIs · `const builtin = import("core.builtin")`

| 当前名称 | 简化名称 | 说明 | 绑定调用 |
|---|---|---|---|
| `copy` | `copy` | 已符合命名 | `builtin.copy(...)` |
| `unreachable` | `unreachable` | 已符合命名 | `builtin.unreachable(...)` |
| `abort` | `abort` | 已符合命名 | `builtin.abort(...)` |
| `min_i32` | `min` | 去前缀+去类型名+去位数后缀 | `builtin.min(...)` |
| `max_i32` | `max` | 去前缀+去类型名+去位数后缀 | `builtin.max(...)` |
| `min_u32` | `min` | 去前缀+去类型名+去位数后缀 | `builtin.min(...)` |
| `max_u32` | `max` | 去前缀+去类型名+去位数后缀 | `builtin.max(...)` |
| `clz_u32` | `clz` | 去前缀+去类型名+去位数后缀 | `builtin.clz(...)` |
| `ctz_u32` | `ctz` | 去前缀+去类型名+去位数后缀 | `builtin.ctz(...)` |
| `popcount_u32` | `popcount` | 去前缀+去类型名+去位数后缀 | `builtin.popcount(...)` |
| `bswap_u32` | `bswap` | 去前缀+去类型名+去位数后缀 | `builtin.bswap(...)` |
| `rotl_u32` | `rotl` | 去前缀+去类型名+去位数后缀 | `builtin.rotl(...)` |
| `rotr_u32` | `rotr` | 去前缀+去类型名+去位数后缀 | `builtin.rotr(...)` |

### core.cmp

`core/cmp/mod.sx` · 12 APIs · `const cmp = import("core.cmp")`

| 当前名称 | 简化名称 | 说明 | 绑定调用 |
|---|---|---|---|
| `ordering_less` | `less` | 去前缀+去类型名+去位数后缀 | `cmp.less(...)` |
| `ordering_equal` | `equal` | 去前缀+去类型名+去位数后缀 | `cmp.equal(...)` |
| `ordering_greater` | `greater` | 去前缀+去类型名+去位数后缀 | `cmp.greater(...)` |
| `is_lt` | `is_lt` | 已符合命名 | `cmp.is_lt(...)` |
| `is_eq` | `is_eq` | 已符合命名 | `cmp.is_eq(...)` |
| `is_gt` | `is_gt` | 已符合命名 | `cmp.is_gt(...)` |
| `reverse` | `reverse` | 已符合命名 | `cmp.reverse(...)` |
| `then` | `then` | 已符合命名 | `cmp.then(...)` |
| `ordering_from_i32` | `from` | 去前缀+去类型名+去位数后缀 | `cmp.from(...)` |
| `cmp_i32` | `cmp` | 去前缀+去类型名+去位数后缀 | `cmp.cmp(...)` |
| `cmp_u8` | `cmp` | 去前缀+去类型名+去位数后缀 | `cmp.cmp(...)` |
| `cmp_ptr` | `cmp_ptr` | 已符合命名 | `cmp.cmp_ptr(...)` |

### core.debug

`core/debug/mod.sx` · 14 APIs · `const dbg = import("core.debug")`

| 当前名称 | 简化名称 | 说明 | 绑定调用 |
|---|---|---|---|
| `assert` | `assert` | 已符合命名 | `dbg.assert(...)` |
| `debug_assert` | `assert` | 去前缀+去类型名+去位数后缀 | `dbg.assert(...)` |
| `assert_eq_i32` | `assert_eq` | 去前缀+去类型名+去位数后缀 | `dbg.assert_eq(...)` |
| `assert_ne_i32` | `assert_ne` | 去前缀+去类型名+去位数后缀 | `dbg.assert_ne(...)` |
| `assert_eq_u32` | `assert_eq` | 去前缀+去类型名+去位数后缀 | `dbg.assert_eq(...)` |
| `assert_ne_u32` | `assert_ne` | 去前缀+去类型名+去位数后缀 | `dbg.assert_ne(...)` |
| `assert_eq_bool` | `assert_eq` | 去前缀+去类型名+去位数后缀 | `dbg.assert_eq(...)` |
| `assert_ne_bool` | `assert_ne` | 去前缀+去类型名+去位数后缀 | `dbg.assert_ne(...)` |
| `assert_eq_u64` | `assert_eq` | 去前缀+去类型名+去位数后缀 | `dbg.assert_eq(...)` |
| `assert_ne_u64` | `assert_ne` | 去前缀+去类型名+去位数后缀 | `dbg.assert_ne(...)` |
| `assert_eq_ptr` | `assert_eq_ptr` | 已符合命名 | `dbg.assert_eq_ptr(...)` |
| `assert_ne_ptr` | `assert_ne_ptr` | 已符合命名 | `dbg.assert_ne_ptr(...)` |
| `debug_assert_eq_i32_diag` | `assert_eq_diag` | 去前缀+去类型名+去位数后缀 | `dbg.assert_eq_diag(...)` |
| `debug_diag_store` | `diag_store` | 去前缀+去类型名+去位数后缀 | `dbg.diag_store(...)` |

### core.fmt

`core/fmt/mod.sx` · 25 APIs · `const fmt = import("core.fmt")`

| 当前名称 | 简化名称 | 说明 | 绑定调用 |
|---|---|---|---|
| `fmt_i32` | `format` | 去前缀+去类型名+去位数后缀 | `fmt.format(...)` |
| `fmt_i32_to_buf` | `to_buf` | 去前缀+去类型名+去位数后缀 | `fmt.to_buf(...)` |
| `fmt_u32_to_buf` | `to_buf` | 去前缀+去类型名+去位数后缀 | `fmt.to_buf(...)` |
| `fmt_u64_to_buf` | `to_buf` | 去前缀+去类型名+去位数后缀 | `fmt.to_buf(...)` |
| `fmt_i64_to_buf` | `to_buf` | 去前缀+去类型名+去位数后缀 | `fmt.to_buf(...)` |
| `fmt_bool_to_buf` | `to_buf` | 去前缀+去类型名+去位数后缀 | `fmt.to_buf(...)` |
| `fmt_u32_hex_to_buf` | `hex_to_buf` | 去前缀+去类型名+去位数后缀 | `fmt.hex_to_buf(...)` |
| `fmt_u64_hex_to_buf` | `hex_to_buf` | 去前缀+去类型名+去位数后缀 | `fmt.hex_to_buf(...)` |
| `fmt_append_i32_to_buf` | `append_to_buf` | 去前缀+去类型名+去位数后缀 | `fmt.append_to_buf(...)` |
| `fmt_append_i64_to_buf` | `append_to_buf` | 去前缀+去类型名+去位数后缀 | `fmt.append_to_buf(...)` |
| `fmt_f64_is_nan` | `is_nan` | 去前缀+去类型名+去位数后缀 | `fmt.is_nan(...)` |
| `fmt_f64_is_inf` | `is_inf` | 去前缀+去类型名+去位数后缀 | `fmt.is_inf(...)` |
| `fmt_f64_write_special` | `write_special` | 去前缀+去类型名+去位数后缀 | `fmt.write_special(...)` |
| `fmt_f64_to_buf_prec` | `to_buf_prec` | 去前缀+去类型名+去位数后缀 | `fmt.to_buf_prec(...)` |
| `fmt_f64_to_buf` | `to_buf` | 去前缀+去类型名+去位数后缀 | `fmt.to_buf(...)` |
| `fmt_scalar_to_buf` | `scalar_to_buf` | 去前缀+去类型名+去位数后缀 | `fmt.scalar_to_buf(...)` |
| `fmt_scalar_to_buf` | `scalar_to_buf` | 去前缀+去类型名+去位数后缀 | `fmt.scalar_to_buf(...)` |
| `fmt_scalar_to_buf` | `scalar_to_buf` | 去前缀+去类型名+去位数后缀 | `fmt.scalar_to_buf(...)` |
| `fmt_scalar_to_buf` | `scalar_to_buf` | 去前缀+去类型名+去位数后缀 | `fmt.scalar_to_buf(...)` |
| `fmt_scalar_to_buf` | `scalar_to_buf` | 去前缀+去类型名+去位数后缀 | `fmt.scalar_to_buf(...)` |
| `fmt_scalar_to_buf` | `scalar_to_buf` | 去前缀+去类型名+去位数后缀 | `fmt.scalar_to_buf(...)` |
| `fmt_usize_to_buf` | `to_buf` | 去前缀+去类型名+去位数后缀 | `fmt.to_buf(...)` |
| `fmt_isize_to_buf` | `to_buf` | 去前缀+去类型名+去位数后缀 | `fmt.to_buf(...)` |
| `fmt_ptr_to_buf` | `ptr_to_buf` | 去前缀+去类型名+去位数后缀 | `fmt.ptr_to_buf(...)` |
| `fmt_module_anchor` | `module_anchor` | 去前缀+去类型名+去位数后缀 | `fmt.module_anchor(...)` |

### core.iterator

`core/iterator/mod.sx` · 10 APIs · `const iter = import("core.iterator")`

| 当前名称 | 简化名称 | 说明 | 绑定调用 |
|---|---|---|---|
| `iter_i32` | `iter` | 去前缀+去类型名+去位数后缀 | `iter.iter(...)` |
| `iter_u8` | `iter` | 去前缀+去类型名+去位数后缀 | `iter.iter(...)` |
| `next_i32` | `next` | 去前缀+去类型名+去位数后缀 | `iter.next(...)` |
| `next_u8` | `next` | 去前缀+去类型名+去位数后缀 | `iter.next(...)` |
| `iter_remaining_i32` | `remaining` | 去前缀+去类型名+去位数后缀 | `iter.remaining(...)` |
| `iter_remaining_u8` | `remaining` | 去前缀+去类型名+去位数后缀 | `iter.remaining(...)` |
| `iterator_protocol_version` | `protocol_version` | 去前缀+去类型名+去位数后缀 | `iter.protocol_version(...)` |
| `iter_u64_from_buf` | `from_buf` | 去前缀+去类型名+去位数后缀 | `iter.from_buf(...)` |
| `next_u64` | `next` | 去前缀+去类型名+去位数后缀 | `iter.next(...)` |
| `iter_remaining_u64` | `remaining` | 去前缀+去类型名+去位数后缀 | `iter.remaining(...)` |

### core.mem

`core/mem/mod.sx` · 40 APIs · `const mem = import("core.mem")`

| 当前名称 | 简化名称 | 说明 | 绑定调用 |
|---|---|---|---|
| `align_of_i32` | `align_of` | 去前缀+去类型名+去位数后缀 | `mem.align_of(...)` |
| `align_of_bool` | `align_of` | 去前缀+去类型名+去位数后缀 | `mem.align_of(...)` |
| `align_of_u8` | `align_of` | 去前缀+去类型名+去位数后缀 | `mem.align_of(...)` |
| `align_of_u32` | `align_of` | 去前缀+去类型名+去位数后缀 | `mem.align_of(...)` |
| `align_of_u64` | `align_of` | 去前缀+去类型名+去位数后缀 | `mem.align_of(...)` |
| `align_of_i64` | `align_of` | 去前缀+去类型名+去位数后缀 | `mem.align_of(...)` |
| `align_of_usize` | `align_of` | 去前缀+去类型名+去位数后缀 | `mem.align_of(...)` |
| `align_of_isize` | `align_of` | 去前缀+去类型名+去位数后缀 | `mem.align_of(...)` |
| `align_of_f32` | `align_of` | 去前缀+去类型名+去位数后缀 | `mem.align_of(...)` |
| `align_of_f64` | `align_of` | 去前缀+去类型名+去位数后缀 | `mem.align_of(...)` |
| `align_of_pointer` | `align_of_ptr` | 去前缀+去类型名+去位数后缀 | `mem.align_of_ptr(...)` |
| `mem_copy` | `copy` | 去前缀+去类型名+去位数后缀 | `mem.copy(...)` |
| `mem_set` | `set` | 去前缀+去类型名+去位数后缀 | `mem.set(...)` |
| `mem_move` | `move` | 去前缀+去类型名+去位数后缀 | `mem.move(...)` |
| `mem_compare` | `compare` | 去前缀+去类型名+去位数后缀 | `mem.compare(...)` |
| `mem_zero` | `zero` | 去前缀+去类型名+去位数后缀 | `mem.zero(...)` |
| `mem_swap` | `swap` | 去前缀+去类型名+去位数后缀 | `mem.swap(...)` |
| `is_alignment_power_of_two` | `is_power_of_two` | 去前缀+去类型名+去位数后缀 | `mem.is_power_of_two(...)` |
| `align_up` | `align_up` | 已符合命名 | `mem.align_up(...)` |
| `align_down` | `align_down` | 已符合命名 | `mem.align_down(...)` |
| `mem_volatile_load_u8_c` | `volatile_load` | 去前缀+去类型名+去位数后缀 | `mem.volatile_load(...)` |
| `mem_volatile_store_u8_c` | `volatile_store` | 去前缀+去类型名+去位数后缀 | `mem.volatile_store(...)` |
| `mem_volatile_load_u16_c` | `volatile_load` | 去前缀+去类型名+去位数后缀 | `mem.volatile_load(...)` |
| `mem_volatile_store_u16_c` | `volatile_store` | 去前缀+去类型名+去位数后缀 | `mem.volatile_store(...)` |
| `mem_volatile_load_u32_c` | `volatile_load` | 去前缀+去类型名+去位数后缀 | `mem.volatile_load(...)` |
| `mem_volatile_store_u32_c` | `volatile_store` | 去前缀+去类型名+去位数后缀 | `mem.volatile_store(...)` |
| `mem_compiler_fence_c` | `compiler_fence` | 去前缀+去类型名+去位数后缀 | `mem.compiler_fence(...)` |
| `mem_fence_acquire_c` | `fence_acquire` | 去前缀+去类型名+去位数后缀 | `mem.fence_acquire(...)` |
| `mem_fence_release_c` | `fence_release` | 去前缀+去类型名+去位数后缀 | `mem.fence_release(...)` |
| `mem_fence_seq_cst_c` | `fence_seq_cst` | 去前缀+去类型名+去位数后缀 | `mem.fence_seq_cst(...)` |
| `volatile_load_u8` | `volatile_load` | 去前缀+去类型名+去位数后缀 | `mem.volatile_load(...)` |
| `volatile_store_u8` | `volatile_store` | 去前缀+去类型名+去位数后缀 | `mem.volatile_store(...)` |
| `volatile_load_u16` | `volatile_load` | 去前缀+去类型名+去位数后缀 | `mem.volatile_load(...)` |
| `volatile_store_u16` | `volatile_store` | 去前缀+去类型名+去位数后缀 | `mem.volatile_store(...)` |
| `volatile_load_u32` | `volatile_load` | 去前缀+去类型名+去位数后缀 | `mem.volatile_load(...)` |
| `volatile_store_u32` | `volatile_store` | 去前缀+去类型名+去位数后缀 | `mem.volatile_store(...)` |
| `compiler_fence` | `compiler_fence` | 已符合命名 | `mem.compiler_fence(...)` |
| `fence_acquire` | `fence_acquire` | 已符合命名 | `mem.fence_acquire(...)` |
| `fence_release` | `fence_release` | 已符合命名 | `mem.fence_release(...)` |
| `fence_seq_cst` | `fence_seq_cst` | 已符合命名 | `mem.fence_seq_cst(...)` |

### core.option

`core/option/mod.sx` · 29 APIs · `const opt = import("core.option")`

| 当前名称 | 简化名称 | 说明 | 绑定调用 |
|---|---|---|---|
| `none_i32` | `none` | 去前缀+去类型名+去位数后缀 | `opt.none(...)` |
| `some_i32` | `some` | 去前缀+去类型名+去位数后缀 | `opt.some(...)` |
| `unwrap_or_i32` | `unwrap_or` | 去前缀+去类型名+去位数后缀 | `opt.unwrap_or(...)` |
| `is_some_i32` | `is_some` | 去前缀+去类型名+去位数后缀 | `opt.is_some(...)` |
| `is_none_i32` | `is_none` | 去前缀+去类型名+去位数后缀 | `opt.is_none(...)` |
| `expect_i32` | `expect` | 去前缀+去类型名+去位数后缀 | `opt.expect(...)` |
| `or_i32` | `or` | 去前缀+去类型名+去位数后缀 | `opt.or(...)` |
| `and_i32` | `and` | 去前缀+去类型名+去位数后缀 | `opt.and(...)` |
| `none_u8` | `none` | 去前缀+去类型名+去位数后缀 | `opt.none(...)` |
| `some_u8` | `some` | 去前缀+去类型名+去位数后缀 | `opt.some(...)` |
| `unwrap_or_u8` | `unwrap_or` | 去前缀+去类型名+去位数后缀 | `opt.unwrap_or(...)` |
| `is_some_u8` | `is_some` | 去前缀+去类型名+去位数后缀 | `opt.is_some(...)` |
| `is_none_u8` | `is_none` | 去前缀+去类型名+去位数后缀 | `opt.is_none(...)` |
| `expect_u8` | `expect` | 去前缀+去类型名+去位数后缀 | `opt.expect(...)` |
| `or_u8` | `or` | 去前缀+去类型名+去位数后缀 | `opt.or(...)` |
| `and_u8` | `and` | 去前缀+去类型名+去位数后缀 | `opt.and(...)` |
| `none_u64` | `none` | 去前缀+去类型名+去位数后缀 | `opt.none(...)` |
| `some_u64` | `some` | 去前缀+去类型名+去位数后缀 | `opt.some(...)` |
| `map_i32` | `map` | 去前缀+去类型名+去位数后缀 | `opt.map(...)` |
| `map_u8` | `map` | 去前缀+去类型名+去位数后缀 | `opt.map(...)` |
| `and_then_i32` | `and_then` | 去前缀+去类型名+去位数后缀 | `opt.and_then(...)` |
| `unwrap_or` | `unwrap_or` | 已符合命名 | `opt.unwrap_or(...)` |
| `none_ptr_u8` | `none` | 去前缀+去类型名+去位数后缀 | `opt.none(...)` |
| `some_ptr_u8` | `some` | 去前缀+去类型名+去位数后缀 | `opt.some(...)` |
| `map_ptr_u8` | `map` | 去前缀+去类型名+去位数后缀 | `opt.map(...)` |
| `is_some_ptr_u8` | `is_some_ptr` | 去前缀+去类型名+去位数后缀 | `opt.is_some_ptr(...)` |
| `is_none_ptr_u8` | `is_none_ptr` | 去前缀+去类型名+去位数后缀 | `opt.is_none_ptr(...)` |
| `expect_ptr_u8` | `expect` | 去前缀+去类型名+去位数后缀 | `opt.expect(...)` |
| `option_module_anchor` | `option_module_anchor` | 已符合命名 | `opt.option_module_anchor(...)` |

### core.result

`core/result/mod.sx` · 23 APIs · `const res = import("core.result")`

| 当前名称 | 简化名称 | 说明 | 绑定调用 |
|---|---|---|---|
| `ok_i32` | `ok` | 去前缀+去类型名+去位数后缀 | `res.ok(...)` |
| `err_i32` | `err` | 去前缀+去类型名+去位数后缀 | `res.err(...)` |
| `unwrap_or_i32` | `unwrap_or` | 去前缀+去类型名+去位数后缀 | `res.unwrap_or(...)` |
| `is_ok_i32` | `is_ok` | 去前缀+去类型名+去位数后缀 | `res.is_ok(...)` |
| `is_ok_gen` | `is_ok_gen` | 已符合命名 | `res.is_ok_gen(...)` |
| `unwrap_or_gen` | `unwrap_or_gen` | 已符合命名 | `res.unwrap_or_gen(...)` |
| `is_err_i32` | `is_err` | 去前缀+去类型名+去位数后缀 | `res.is_err(...)` |
| `expect_i32` | `expect` | 去前缀+去类型名+去位数后缀 | `res.expect(...)` |
| `expect_i32_or_panic` | `expect_or_panic` | 去前缀+去类型名+去位数后缀 | `res.expect_or_panic(...)` |
| `or_i32` | `or` | 去前缀+去类型名+去位数后缀 | `res.or(...)` |
| `and_i32` | `and` | 去前缀+去类型名+去位数后缀 | `res.and(...)` |
| `map_i32` | `map` | 去前缀+去类型名+去位数后缀 | `res.map(...)` |
| `and_then_i32` | `and_then` | 去前缀+去类型名+去位数后缀 | `res.and_then(...)` |
| `or_else_i32` | `or_else` | 去前缀+去类型名+去位数后缀 | `res.or_else(...)` |
| `ok_u8` | `ok` | 去前缀+去类型名+去位数后缀 | `res.ok(...)` |
| `err_u8` | `err` | 去前缀+去类型名+去位数后缀 | `res.err(...)` |
| `unwrap_or_u8` | `unwrap_or` | 去前缀+去类型名+去位数后缀 | `res.unwrap_or(...)` |
| `is_ok_u8` | `is_ok` | 去前缀+去类型名+去位数后缀 | `res.is_ok(...)` |
| `is_err_u8` | `is_err` | 去前缀+去类型名+去位数后缀 | `res.is_err(...)` |
| `expect_u8_or_panic` | `expect_or_panic` | 去前缀+去类型名+去位数后缀 | `res.expect_or_panic(...)` |
| `map_u8` | `map` | 去前缀+去类型名+去位数后缀 | `res.map(...)` |
| `or_else_u8` | `or_else` | 去前缀+去类型名+去位数后缀 | `res.or_else(...)` |
| `result_module_anchor` | `result_module_anchor` | 已符合命名 | `res.result_module_anchor(...)` |

### core.slice

`core/slice/mod.sx` · 34 APIs · `const slice = import("core.slice")`

| 当前名称 | 简化名称 | 说明 | 绑定调用 |
|---|---|---|---|
| `core_slice_i32_from_ptr_c` | `core_slice_from_ptr` | 去前缀+去类型名+去位数后缀 | `slice.core_slice_from_ptr(...)` |
| `core_subslice_i32_c` | `core_subslice` | 去前缀+去类型名+去位数后缀 | `slice.core_subslice(...)` |
| `core_slice_u8_from_ptr_c` | `core_slice_from_ptr` | 去前缀+去类型名+去位数后缀 | `slice.core_slice_from_ptr(...)` |
| `core_subslice_u8_c` | `core_subslice` | 去前缀+去类型名+去位数后缀 | `slice.core_subslice(...)` |
| `core_slice_u64_from_ptr_c` | `core_slice_from_ptr` | 去前缀+去类型名+去位数后缀 | `slice.core_slice_from_ptr(...)` |
| `core_subslice_u64_c` | `core_subslice` | 去前缀+去类型名+去位数后缀 | `slice.core_subslice(...)` |
| `len_i32` | `len` | 去前缀+去类型名+去位数后缀 | `slice.len(...)` |
| `get_i32` | `get` | 去前缀+去类型名+去位数后缀 | `slice.get(...)` |
| `get_i32_unchecked` | `get_unchecked` | 去前缀+去类型名+去位数后缀 | `slice.get_unchecked(...)` |
| `is_empty_i32` | `is_empty` | 去前缀+去类型名+去位数后缀 | `slice.is_empty(...)` |
| `first_i32` | `first` | 去前缀+去类型名+去位数后缀 | `slice.first(...)` |
| `last_i32` | `last` | 去前缀+去类型名+去位数后缀 | `slice.last(...)` |
| `subslice_i32` | `subslice` | 去前缀+去类型名+去位数后缀 | `slice.subslice(...)` |
| `split_at_i32` | `split_at` | 去前缀+去类型名+去位数后缀 | `slice.split_at(...)` |
| `chunks_len_i32` | `chunks_len` | 去前缀+去类型名+去位数后缀 | `slice.chunks_len(...)` |
| `chunk_i32` | `chunk` | 去前缀+去类型名+去位数后缀 | `slice.chunk(...)` |
| `len_u8` | `len` | 去前缀+去类型名+去位数后缀 | `slice.len(...)` |
| `get_u8` | `get` | 去前缀+去类型名+去位数后缀 | `slice.get(...)` |
| `get_u8_unchecked` | `get_unchecked` | 去前缀+去类型名+去位数后缀 | `slice.get_unchecked(...)` |
| `is_empty_u8` | `is_empty` | 去前缀+去类型名+去位数后缀 | `slice.is_empty(...)` |
| `first_u8` | `first` | 去前缀+去类型名+去位数后缀 | `slice.first(...)` |
| `subslice_u8` | `subslice` | 去前缀+去类型名+去位数后缀 | `slice.subslice(...)` |
| `split_at_u8` | `split_at` | 去前缀+去类型名+去位数后缀 | `slice.split_at(...)` |
| `chunks_len_u8` | `chunks_len` | 去前缀+去类型名+去位数后缀 | `slice.chunks_len(...)` |
| `chunk_u8` | `chunk` | 去前缀+去类型名+去位数后缀 | `slice.chunk(...)` |
| `len_u64` | `len` | 去前缀+去类型名+去位数后缀 | `slice.len(...)` |
| `get_u64` | `get` | 去前缀+去类型名+去位数后缀 | `slice.get(...)` |
| `is_empty_u64` | `is_empty` | 去前缀+去类型名+去位数后缀 | `slice.is_empty(...)` |
| `first_u64` | `first` | 去前缀+去类型名+去位数后缀 | `slice.first(...)` |
| `last_u64` | `last` | 去前缀+去类型名+去位数后缀 | `slice.last(...)` |
| `subslice_u64` | `subslice` | 去前缀+去类型名+去位数后缀 | `slice.subslice(...)` |
| `split_at_u64` | `split_at` | 去前缀+去类型名+去位数后缀 | `slice.split_at(...)` |
| `chunks_len_u64` | `chunks_len` | 去前缀+去类型名+去位数后缀 | `slice.chunks_len(...)` |
| `chunk_u64` | `chunk` | 去前缀+去类型名+去位数后缀 | `slice.chunk(...)` |

### core.str

`core/str/mod.sx` · 12 APIs · `const str = import("core.str")`

| 当前名称 | 简化名称 | 说明 | 绑定调用 |
|---|---|---|---|
| `bytes_view` | `view` | 去前缀+去类型名+去位数后缀 | `str.view(...)` |
| `bytes_view_from_slice` | `from_slice` | 去前缀+去类型名+去位数后缀 | `str.from_slice(...)` |
| `bytes_view_len` | `len` | 去前缀+去类型名+去位数后缀 | `str.len(...)` |
| `bytes_view_is_empty` | `is_empty` | 去前缀+去类型名+去位数后缀 | `str.is_empty(...)` |
| `bytes_view_get` | `get` | 去前缀+去类型名+去位数后缀 | `str.get(...)` |
| `bytes_view_subview` | `subview` | 去前缀+去类型名+去位数后缀 | `str.subview(...)` |
| `bytes_view_eq` | `eq` | 去前缀+去类型名+去位数后缀 | `str.eq(...)` |
| `bytes_view_eq_bytes` | `eq_bytes` | 去前缀+去类型名+去位数后缀 | `str.eq_bytes(...)` |
| `bytes_view_index_of_byte` | `index_of_byte` | 去前缀+去类型名+去位数后缀 | `str.index_of_byte(...)` |
| `bytes_view_index_of` | `index_of` | 去前缀+去类型名+去位数后缀 | `str.index_of(...)` |
| `bytes_view_contains_byte` | `contains_byte` | 去前缀+去类型名+去位数后缀 | `str.contains_byte(...)` |
| `bytes_view_starts_with` | `starts_with` | 去前缀+去类型名+去位数后缀 | `str.starts_with(...)` |

### core.types

`core/types/mod.sx` · 28 APIs · `const types = import("core.types")`

| 当前名称 | 简化名称 | 说明 | 绑定调用 |
|---|---|---|---|
| `size_of_i32` | `size_of` | 去前缀+去类型名+去位数后缀 | `types.size_of(...)` |
| `size_of_bool` | `size_of` | 去前缀+去类型名+去位数后缀 | `types.size_of(...)` |
| `size_of_u8` | `size_of` | 去前缀+去类型名+去位数后缀 | `types.size_of(...)` |
| `size_of_i16` | `size_of` | 去前缀+去类型名+去位数后缀 | `types.size_of(...)` |
| `size_of_u16` | `size_of` | 去前缀+去类型名+去位数后缀 | `types.size_of(...)` |
| `size_of_u32` | `size_of` | 去前缀+去类型名+去位数后缀 | `types.size_of(...)` |
| `size_of_u64` | `size_of` | 去前缀+去类型名+去位数后缀 | `types.size_of(...)` |
| `size_of_i64` | `size_of` | 去前缀+去类型名+去位数后缀 | `types.size_of(...)` |
| `size_of_usize` | `size_of` | 去前缀+去类型名+去位数后缀 | `types.size_of(...)` |
| `size_of_isize` | `size_of` | 去前缀+去类型名+去位数后缀 | `types.size_of(...)` |
| `size_of_f32` | `size_of` | 去前缀+去类型名+去位数后缀 | `types.size_of(...)` |
| `size_of_f64` | `size_of` | 去前缀+去类型名+去位数后缀 | `types.size_of(...)` |
| `size_of_pointer` | `size_of_ptr` | 去前缀+去类型名+去位数后缀 | `types.size_of_ptr(...)` |
| `align_of_pointer` | `align_of_ptr` | 去前缀+去类型名+去位数后缀 | `types.align_of_ptr(...)` |
| `align_of_i32` | `align_of` | 去前缀+去类型名+去位数后缀 | `types.align_of(...)` |
| `align_of_bool` | `align_of` | 去前缀+去类型名+去位数后缀 | `types.align_of(...)` |
| `align_of_u8` | `align_of` | 去前缀+去类型名+去位数后缀 | `types.align_of(...)` |
| `align_of_i16` | `align_of` | 去前缀+去类型名+去位数后缀 | `types.align_of(...)` |
| `align_of_u16` | `align_of` | 去前缀+去类型名+去位数后缀 | `types.align_of(...)` |
| `align_of_u32` | `align_of` | 去前缀+去类型名+去位数后缀 | `types.align_of(...)` |
| `align_of_u64` | `align_of` | 去前缀+去类型名+去位数后缀 | `types.align_of(...)` |
| `align_of_i64` | `align_of` | 去前缀+去类型名+去位数后缀 | `types.align_of(...)` |
| `align_of_usize` | `align_of` | 去前缀+去类型名+去位数后缀 | `types.align_of(...)` |
| `align_of_isize` | `align_of` | 去前缀+去类型名+去位数后缀 | `types.align_of(...)` |
| `align_of_f32` | `align_of` | 去前缀+去类型名+去位数后缀 | `types.align_of(...)` |
| `align_of_f64` | `align_of` | 去前缀+去类型名+去位数后缀 | `types.align_of(...)` |
| `size_of` | `size_of` | 已符合命名 | `types.size_of(...)` |
| `align_of` | `align_of` | 已符合命名 | `types.align_of(...)` |

## 四、审计结论

- 简化名审计通过：当前清单中未发现类型 token。
- 下一步建议：先在 `core.str`、`core.slice`、`core.debug` 增加无类型后缀别名，再逐步迁移调用点。

