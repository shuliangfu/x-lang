# BOOT-016 xlang_asm std 符号完整性 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：BOOT-014（链接契约）、BOOT-015（heap smoke）、BOOT-008（parser thin glue 符号）
> **honesty 2026-08-24**：archived; gate default = `analysis/archive/.../`; live roadmap = `analysis/自举进度.md` (`NEXT.md` left).
> **honesty 2026-08-24 #2**：monofile `seeds/runtime.from_x.c` retired wave321; path
> inventory = `labi_std_list.from_x.c` + `labi_ondemand_list.from_x.c` (union covers
> Top-12 `obj_rel`); `get_*_o_path` getters retired (E-04) — manifest getter = `-`;
> anchors = live exports after pure-.x / formal surface mangle (`std_*` / `path_sep_c`).

---

## 1. 目标

扩展 **xlang_asm** 用户程序链接路径（`asm_ld_append_std_objs`）的 **Top-N std `.o` 符号完整性** gate：每个关键模块 `.o` 须可构建且 `nm` 可见锚点 C 符号，防止链入空壳或截断对象。

验收：`tests/run-boot-016-std-asm-symbols-gate.sh` 绿；`min_top_n=12`。

---

## 2. live labi path seeds

Path string authority (post-wave321): `compiler/seeds/labi_std_list.from_x.c`
(`labi_std_default_std_rel_at`) + `compiler/seeds/labi_ondemand_list.from_x.c`
(`labi_od_rel_*`). Gate verifies each manifest `obj_rel` appears in that union.
Orchestration entry remains `xlang_asm_ld_append_std_objs` / `_for_user`
(`runtime_link_abi` + `labi_invoke_ld_list`). Do **not** resurrect monofile
`runtime.from_x.c` or dead `get_*_o_path` getters.

---

## 3. Top-12 锚点（live exports · honesty 2026-08-24）

| 模块 | `.o` | 锚点符号 |
|------|------|----------|
| std.io | `std/io/io.o` | `std_io_read_ctx` |
| std.fs | `std/fs/fs.o` | `std_fs_fs_open_read_c` |
| std.heap | `std/heap/heap.o` | `std_heap_libc_heap_alloc_c` |
| std.process | `std/process/process.o` | `process_getpid_c` |
| std.string | `std/string/string.o` | `xlang_string_memcmp_c` |
| std.path | `std/path/path.o` | `path_sep_c` |
| std.runtime | `std/runtime/runtime.o` | `std_runtime_ready` |
| std.env | `std/env/env.o` | `std_env_iter_count` |
| std.json | `std/json/json.o` | `json_skip_value_c` |
| std.net | `std/net/net.o` | `net_tcp_listen_c` |
| std.sync | `std/sync/sync.o` | `std_sync_new_mutex` |
| std.channel | `std/channel/channel.o` | `std_channel_bounded` |

纯 `.x` 模块（`std.vec` / `std.map`）由 BOOT-015 语义 smoke 覆盖，本 gate 仅验 **已构建的产品 `.o`**。

---

## 4. Gate 与 report

```bash
./tests/run-boot-016-std-asm-symbols-gate.sh
```

manifest：`tests/baseline/boot-016-std-asm-symbols.tsv`

```
xlang: [XLANG_BOOT016] status=ok obj_ok=12 sym_miss=0 runtime_miss=0 skip=0
```

---

## 5. 维护

新增 std C 模块进入 `asm_ld_append_std_objs` 时：

1. 更新 `boot-std-link-contract.tsv`（BOOT-014）  
2. 视优先级加入本 manifest `std_obj` 行并选定稳定导出符号  
3. 跑 `run-boot-016-std-asm-symbols-gate.sh`
