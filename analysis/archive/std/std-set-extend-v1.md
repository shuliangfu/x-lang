# STD-015 std.set Set_u64 / Set_str 扩展 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` STD-015、`std.hash`、`std.heap`

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-015 | `Set_u64`、`Set_str`（insert/contains/remove/deinit） |

与 `Set_i32` 同构开放寻址表；**槽位哈希经 std.hash**（u64 用 SipHash write/finish，str 用 `hash_bytes`）。

---

## 2. API

### 2.1 `Set_u64`

- 结构：`keys: *u64`、`occupied: *u8`、`cap`、`len`
- 槽位：`hash_start` → `hash_write_u64` → `hash_finish` → `% cap`
- API：`new` / `with_capacity` / `insert` / `contains` / `remove` / `len` / `deinit`

### 2.2 `Set_str`

- 键 `(ptr: *u8, len: i32)`；每槽 `set_str_key_cap()`（32）字节扁平存储
- 槽位：`hash_bytes(key, len) % cap`
- `key_len > 32` 时 `insert` 返回 -1

---

## 3. 边界行为（金样）

> 2026-08-25: scenario names use **product** symbols (`insert` / `str_insert` /
> `remove` / `str_remove`); legacy `set_u64_insert`-style labels were TSV drift.

| 场景 | 期望 |
|------|------|
| `insert`（Set_u64）重复键 | len 不变 |
| `remove`（Set_u64）不存在 | 返回 0 |
| `str_insert` 前缀键 | 与不同 len 区分 |
| `str_insert` len=33 | -1 |
| 扩容后 contains 仍命中 | rehash 正确 |

---

## 4. 验收

- manifest：`tests/baseline/std-set-extend.tsv`
- typeck：`tests/set/extend.x`
- 报告：`xlang: [XLANG_STD_SET_EXTEND] status=ok`

**Honesty (2026-08-29 residual auto-make)**：leftover `tests/run-set.sh`（`xlang_compiler_make … heap.o/set.o` + collection gcc fallback + bootstrap-link wrap）retired. Prefer asm + `XLANG_LINK_XLANG`；explicit-bad XLANG hard die；missing native FAIL；product `-o` `tests/set/main.x` hard；check＝obs；report `run=`／`obs=`／`skip=`。leftover runner report prefix `xlang: [SET]`。Do not add a new `## Gate` heading here（STD-015 live gate already honesty-closed）。

---

## 5. 演进

- 与 `Map_str` 共享可变长键；trait Hasher 注入槽位函数。
