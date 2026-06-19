# STD-013/014 map/vec 常用类型扩展 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` Phase 2、`std.heap` 分配原语

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-013 | `Map_u64_i32`、`Map_str_i32`（insert/get/remove/contains） |
| STD-014 | `Vec_u64`、`Vec_f64`（append_slice / from_slice round-trip） |

---

## 2. STD-013：`std.map`

### 2.1 `Map_u64_i32`

- 开放寻址哈希表，与 `Map_i32_i32` 同构；查找走 `map_u64_i32_find_c`（`heap.o`）。
- API：`new` / `with_capacity` / `insert` / `get` / `contains` / `remove` / `deinit`。

### 2.2 `Map_str_i32`

- 键为 `(ptr: *u8, len: i32)`；每槽扁平存储 `map_str_key_cap()`（32）字节。
- `key_len > 32` 时 `insert` 返回 -1。
- 查找：djb2 哈希 + 线性探测 + 逐字节比较。

---

## 3. STD-014：`std.vec`

### 3.1 `Vec_u64` / `Vec_f64`

- 与 `Vec_i32` 同构；堆分配经 `alloc_u64` / `alloc_f64`（`heap.c`）。
- `append_slice` / `from_slice` 走 `copy_u64_at` / `copy_f64_at`（≥8 元素 memcpy 快路径与 i32 一致）。

---

## 4. 验收

- manifest：`tests/baseline/std-map-vec-extend.tsv`
- typeck：`tests/map/boundary.sx`、`tests/vec/append_roundtrip.sx`
- runnable：`tests/run-std-map-vec-extend-gate.sh`
- 报告：`shux: [SHUX_STD_MAP_VEC_EXTEND] status=ok`

---

## 5. 演进

- `Map_str_*` 超长键：StrView / Arena 键；或可变长堆键。
- 更多值类型：`Map_u64_u64`、`Map_str_u64` 等按 manifest 增量添加。
