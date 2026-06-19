# BOOT-016 shux_asm std 符号完整性 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：BOOT-014（链接契约）、BOOT-015（heap smoke）、BOOT-008（parser thin glue 符号）

---

## 1. 目标

扩展 **shux_asm** 用户程序链接路径（`asm_ld_append_std_objs`）的 **Top-N std `.o` 符号完整性** gate：每个关键模块 `.o` 须可构建且 `nm` 可见锚点 C 符号，防止链入空壳或截断对象。

验收：`tests/run-boot-016-std-asm-symbols-gate.sh` 绿；`min_top_n=12`。

---

## 2. runtime.c 路径

与 BOOT-014 一致：`runtime.c` 中 `get_std_*_o_path` + `shux_asm_ld_try_under_lib_roots("std/…/….o")` 须覆盖 manifest 各行 `obj_rel`。

---

## 3. Top-12 锚点（wave 1）

| 模块 | `.o` | 锚点符号 |
|------|------|----------|
| std.io | `std/io/io.o` | `io_read` |
| std.fs | `std/fs/fs.o` | `fs_open_read_c` |
| std.heap | `std/heap/heap.o` | `heap_alloc_c` |
| std.process | `std/process/process.o` | `process_getpid_c` |
| std.string | `std/string/string.o` | `shux_string_memcmp_c` |
| std.path | `std/path/path.o` | `path_sep_c` |
| std.runtime | `std/runtime/runtime.o` | `runtime_panic` |
| std.env | `std/env/env.o` | `env_iter_count_c` |
| std.json | `std/json/json.o` | `json_skip_value_c` |
| std.net | `std/net/net.o` | `net_tcp_listen_c` |
| std.sync | `std/sync/sync.o` | `sync_mutex_new_c` |
| std.channel | `std/channel/channel.o` | `channel_i32_bounded_c` |

纯 `.sx` 模块（`std.vec` / `std.map`）由 BOOT-015 语义 smoke 覆盖，本 gate 仅验 **C 后端 `.o`**。

---

## 4. Gate 与 report

```bash
./tests/run-boot-016-std-asm-symbols-gate.sh
```

manifest：`tests/baseline/boot-016-std-asm-symbols.tsv`

```
shux: [SHUX_BOOT016] status=ok obj_ok=12 sym_miss=0 runtime_miss=0 skip=0
```

---

## 5. 维护

新增 std C 模块进入 `asm_ld_append_std_objs` 时：

1. 更新 `boot-std-link-contract.tsv`（BOOT-014）  
2. 视优先级加入本 manifest `std_obj` 行并选定稳定导出符号  
3. 跑 `run-boot-016-std-asm-symbols-gate.sh`
