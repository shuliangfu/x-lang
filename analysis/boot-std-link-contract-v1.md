# BOOT-014 std 模块链接契约 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`compiler/src/runtime.c`、`compiler/Makefile`、`BOOT-013`

---

## 1. 目标

| ID | 交付 |
|----|------|
| BOOT-014 | `runtime.c` 链入规则与 **manifest gate 自动同步** |
| 验收 | 新增/移动 std `.o` 时 gate 失败，迫使同步更新 TSV + runtime |

---

## 2. 链接路径（runtime.c）

### 2.1 默认全量（`asm_ld_append_std_objs`）

`-backend asm -o exe` 或 C 前端 `invoke_cc` 链接时，按固定顺序追加 **33 个 std 模块** + `io.o` + `runtime_panic.o` + `runtime_asm_io_stubs.o`（路径存在才链入）。

实现：`get_std_*_o_path` / `get_io_o_path` + `shux_asm_ld_try_under_lib_roots("std/…/….o")`。

### 2.2 按需（`asm_ld_append_on_demand_user_objs`）

| 模块 | 触发 | 探测 |
|------|------|------|
| `std/async/scheduler.o` | `shu_async_*` / `shu_io_*_async_*` 等 | `nm -u` 用户 `.o`（`asm_user_o_needs_async_scheduler`） |

C 后端：`generated_c_needs_async_scheduler` 扫描生成 `.c` 后链入 `scheduler.o`。

### 2.3 Freestanding（Linux x86_64）

| 对象 | 触发 |
|------|------|
| `compiler/freestanding_io.o` | `shux_sys_write`（`freestanding_user_o_needs_io`） |
| `compiler/runtime_panic.o` | `shux_panic_`（`freestanding_user_o_needs_panic` / `freestanding_o_needs_undef_sym`） |

### 2.4 平台库标志（`ShuAsmLdStdLinkFlags`）

| 标志 | 追加 |
|------|------|
| `have_thread` / `have_sync` / `have_channel` | `-lpthread` |
| `have_math` | `-lm` |
| `have_compress` | `-lz`、`-lzstd` |
| `have_dynlib` | `-ldl` |
| `have_io`（Linux） | `-luring`、`-lpthread` |

---

## 3. Makefile 契约

`compiler/Makefile` 中 `STD_AND_PANIC_O` 须包含所有 **std_always** 条目（不含 `scheduler.o`）。

`scheduler.o` 由 `make ../std/async/scheduler.o` 单独构建，按需链入。

---

## 4. 烟测

| 脚本 | 验证 |
|------|------|
| `tests/json/object_array_parse.x` | `std/json/json.o` 全量链入 |
| `tests/async/await_scheduler_mod.x` | `import("std.async")` → 按需 `scheduler.o` |

---

## 5. 门禁

```bash
./tests/run-boot-std-link-contract-gate.sh
```

manifest：`tests/baseline/boot-std-link-contract.tsv`

校验项：

1. 每个 `getter` / `obj_rel` / `trigger` 在 `runtime.c` 存在  
2. `STD_AND_PANIC_O` 与 manifest 一致  
3. 可选：native `shux-c` 链接烟测  

---

## 6. 变更流程

新增 std 模块时须 **同 PR** 更新：

1. `std/<mod>/<mod>.c` + `compiler/Makefile` 目标  
2. `runtime.c`：`get_std_<mod>_o_path` + `asm_ld_append_std_objs` 一行  
3. `tests/baseline/boot-std-link-contract.tsv` 一行  
4. 跑 `run-boot-std-link-contract-gate.sh` 全绿  
