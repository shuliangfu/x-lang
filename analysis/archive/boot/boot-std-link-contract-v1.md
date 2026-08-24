# BOOT-014 std 模块链接契约 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）** · **honesty 2026-08-24 #3**  
> 关联（历史）：`compiler/src/runtime.c`、`compiler/Makefile`、`BOOT-013`  
> **honesty 2026-08-24**：archived; gate default = `analysis/archive/.../`; live roadmap = `analysis/自举进度.md` (`NEXT.md` left).  
> **honesty 2026-08-24 #3**：monofile `seeds/runtime.from_x.c` retired wave321; `get_*_o_path` retired E-04; `compiler/Makefile` deleted MG wave941. Live authorities below.

---

## 1. 目标

| ID | 交付 |
|----|------|
| BOOT-014 | 链入规则与 **manifest gate 自动同步** |
| 验收 | 新增/移动 std `.o` 时 gate 失败，迫使同步更新 TSV + live path seeds / mk |

---

## 2. 链接路径（live labi）

### 2.1 默认全量（`asm_ld_append_std_objs`）

`-backend asm -o exe` 或 C 前端 `invoke_cc` 链接时，按固定计划追加 std 模块 + panic / asm IO stubs 等（路径存在才链入）。

**Live path inventory（space-separated union）**：

- `compiler/seeds/labi_std_list.from_x.c`
- `compiler/seeds/labi_ondemand_list.from_x.c`
- `compiler/seeds/labi_ensure_list.from_x.c`
- `compiler/seeds/labi_path_pure.from_x.c`
- `compiler/seeds/labi_freestanding_list.from_x.c`

实现：labi plan / `xlang_asm_ld_try_under_lib_roots("std/…/….o")`；死 `get_std_*_o_path` / `get_io_o_path` 不再作为契约列（TSV getter=`-`）。活 companion 仍可列 `xlang_runtime_*_o_path`。

### 2.2 按需（`asm_ld_append_on_demand_user_objs`）

| 模块 | 触发 | 探测 |
|------|------|------|
| `std/async/scheduler.o` | `xlang_async_*` 等 | `nm -u` 用户 `.o`（`asm_user_o_needs_async_scheduler`） |
| `core/mem/mem.o` | live needles e.g. `core_mem_mem_copy` | labi_od_core_mem_sym_* |
| queue / db kv·arrow·sqlite glues | 对应用户 UNDEF | on_demand（**不在** `STD_AND_PANIC_O`） |

C 后端：`generated_c_needs_async_scheduler` 等扫描生成 `.c` 后链入。

### 2.3 Freestanding（Linux x86_64）

| 对象 | 触发 |
|------|------|
| `compiler/freestanding_io.o` | `xlang_sys_write`（`freestanding_o_needs` / user UNDEF） |
| `compiler/runtime_panic.o` | `xlang_panic_` |

### 2.4 平台库标志（`ShuAsmLdStdLinkFlags`）

| 标志 | 追加 |
|------|------|
| `have_thread` / `have_sync` / `have_channel` | `-lpthread` |
| `have_math` | `-lm` |
| `have_compress` | `-lz`、`-lzstd` |
| `have_dynlib` | `-ldl` |
| `have_io`（Linux） | `-luring`、`-lpthread` |

---

## 3. STD_AND_PANIC_O 契约

**Live authority**：`compiler/mk/std_and_panic_objs.mk`（wave813 B7B；Makefile 仅曾 include，MG 后 Makefile 已物理删除）。

`STD_AND_PANIC_O` 须包含所有 **std_always** 与 always-linked **compiler** 条目。  
`scheduler.o` / `core/mem` / queue·db glues 为 on_demand（TSV `std_on_demand`），不强制出现在 always 表。

---

## 4. 烟测

| 脚本 | 验证 | 闸门 |
|------|------|------|
| `tests/json/object_array_parse.x` | `std/json/json.o` 全量链入 | **硬**（always） |
| `tests/async/await_scheduler_mod.x` | `import("std.async")` → 按需 `scheduler.o` | 观测（mangle residual 可红；deferred） |
| `tests/core-mem/volatile_fence.x` | 按需 `core/mem/mem.o` | 观测（on_demand ensure residual 可红；deferred） |

**honesty 2026-08-24 #3**：契约门 = labi／mk／manifest + json always 烟测。on_demand 两烟测不挡门（产品 mangle／ensure 另债）。

---

## 5. 门禁

```bash
./tests/run-boot-std-link-contract-gate.sh
```

manifest：`tests/baseline/boot-std-link-contract.tsv`

校验项：

1. 每个非 `-` 的 `getter` / `obj_rel` / 非 flag `trigger` 在 live labi 并集存在  
2. `STD_AND_PANIC_O`（mk）与 manifest always 条目一致  
3. 可选：native `xlang-c` 链接烟测  

---

## 6. 变更流程

新增 std 模块时须 **同 PR** 更新：

1. `std/<mod>/…` 产品目标（xbuild / catalog）  
2. 对应 labi path seed（obj 字符串 + 按需 needle）  
3. 若 always-linked：`compiler/mk/std_and_panic_objs.mk`  
4. `tests/baseline/boot-std-link-contract.tsv` 一行  
5. 跑 `run-boot-std-link-contract-gate.sh` 全绿  
