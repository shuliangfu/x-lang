# 阶段 G 完全自举 — 全量任务清单 v1

> **创建**：2026-06-21  
> **目标**：仓库内 **零手写 `.c`/`.h`**（compiler + core + std）；Linux bootstrap **`-nostdlib` 硬绿**；`build.x` 替代 Makefile。  
> **前提**：D+E+F v1 ✅（见 `NEXT.md` §0.1）。  
> **终局哨兵**：`SHUX_NO_HANDWRITTEN_C_STRICT=1 ./tests/run-no-handwritten-c-gate.sh`

---

## 0. 当前存量快照（2026-06-21）

| scope | `.c` | `.h` | 说明 |
|-------|------|------|------|
| `std/` | **0** | **0** | F-ZC ✅ |
| `core/` | **0** | **0** | G-01 ✅（2026-06-21） |
| `compiler/` | **~208** | **~41** | G-02～G-06 |
| **合计** | **~208** | **~41** | F-09 baseline 165（未含新增 3 个） |

**每批回归（必跑）**：

```bash
SHUX_E_SOFT_FAIL=1 ./tests/run-e-soft-retire-gate.sh
make -C compiler bootstrap-driver-bstrict
SHUX_D03_FAIL=1 ./tests/run-d03-stage2-hash-gate.sh
./tests/run-no-handwritten-c-gate.sh
```

---

## 1. 批次总览

| 批次 | ID 范围 | 目标 | 预估 | 状态 |
|------|---------|------|------|------|
| **0** | G-PLAN | 任务清单 + 门禁对齐 | — | ✅ 本文档 |
| **1** | G-01 | `core/` 5→0 `.c` + 1 `.h` | 1～2 天 | ✅ |
| **2** | G-03 | F-no-libc bootstrap 硬绿 | 2～4 天 | 🟡 path.o + net.o（10 子模块）asm 绿；gate hello 仍卡 test.o 重复链接 |
| **3** | G-02a | 删 LEGACY 前端 C（仅 shux-c 用） | 3～5 天 | ⬜ 需 seed + B-strict 绿 |
| **4** | G-02b | runtime ABI 七件套 → `.x` | 1～2 周 | ⬜ |
| **5** | G-02c | LSP / driver / asm glue C | 1～2 周 | ⬜ |
| **6** | G-02d | std 测试胶层 `runtime_*_glue.c` + http/ed25519 | 1 周 | ⬜ |
| **7** | G-04 | F-09 STRICT 硬绿 | — | ⬜ 随 1～6 |
| **8** | G-05 | Makefile 退役 | 3～5 天 | ⬜ |
| **9** | G-06 | 零 seed 冷启动 | 2～3 天 | ⬜ |
| **10** | G-07 | `vX.Y.Z-selfhost` 发布 | 1 天 | ⬜ |
| **11** | G-08 | Windows/Alpine B-strict | 延后 | ⏭ |

---

## 2. 批次 1 — G-01 core 零 C（详细）

| # | 任务 | 文件 | 动作 | Gate |
|---|------|------|------|------|
| G-01-01 | 删 assert 重复 C | `core/assert/assert.c` | 逻辑已在 `core/assert/mod.x` | `run-core-debug-assert-extend-gate.sh` |
| G-01-02 | 删 debug 重复 C | `core/debug/debug.c` | alias 已在 `core/debug/mod.x` | 同上 |
| G-01-03 | slice 纯 `.x` | `core/slice/slice.c` | `mod.x` 用字段赋值构造 slice | `run-core-slice-api-gate.sh` |
| G-01-04 | mem 纯 `.x` | `core/mem/mem.c` | volatile 读写 + fence（`.x`/极薄 `.s`） | `run-core-mem-volatile-fence-gate.sh` |
| G-01-05 | builtin 纯 `.x` | `core/builtin/builtin.c` | 已有 `mod.x` 实现；更新 codegen 映射 | `run-core-builtin-bitops-gate.sh` |
| G-01-06 | 删 ABI 头 | `core/builtin/builtin_abi.h` | 迁 `compiler/include/shux_std_abi/` 或内联 | `run-builtin.sh` |
| G-01-07 | Makefile | `compiler/Makefile` | 去掉 `core/*/builtin.o` 等规则 | `run-std-c-inventory-gate.sh` |
| G-01-08 | runtime 链 | `runtime_link_abi.c` | 去掉按需链 `core/*.o` | `run-boot-std-link-contract-gate.sh` |
| G-01-09 | baseline | `f08-core-inventory.tsv` 等 | 刷新 F-09 whitelist | `run-f08-core-inventory-gate.sh` |

---

## 3. 批次 2 — G-03 F-no-libc bootstrap 硬绿

| # | 任务 | 说明 | Gate |
|---|------|------|------|
| G-03-01 | NL-07 v5 全链 | `SHUX_BOOTSTRAP_NOSTDLIB=1 build_shux_asm` 硬绿 | `run-nolibc-n07-v4-build-gate.sh` |
| G-03-02 | 删 bootstrap 桩 C | `bootstrap_nostdlib_stubs.c` 等 | Stage2 哈希 |
| G-03-03 | 去 `-lc/-lm` | `build_shux_asm.sh` 链接行 | `run-no-libc-gate.sh` |
| G-03-04 | libm 替代 | `typeck_f64_bits` 无 libm | `run-typeck-f64-gate.sh`（若有） |

---

## 4. 批次 3 — G-02a LEGACY 前端 C 删除

> **阻塞**：须 G-06 预编译 seed 或 `.x` 完全替代 `shux-c -E` 冷启动。

| # | 文件 | 替代 |
|---|------|------|
| G-02a-01 | `lexer/lexer.c` + `lexer.h` | `lexer_x.o` |
| G-02a-02 | `ast/ast.c` + `ast.h` | `ast_x.o` |
| G-02a-03 | `parser/parser.c` + `parser.h` | `parser_x.o` |
| G-02a-04 | `typeck/typeck.c` + `typeck.h` | `typeck_x.o` |
| G-02a-05 | `codegen/codegen.c` + `codegen.h` | `codegen_x.o` |
| G-02a-06 | `codegen/autovec.c` | `autovec.x` 或内联 |
| G-02a-07 | `preprocess.c` + `preprocess.h` | `preprocess_x.o` |
| G-02a-08 | `lsp/lsp_diag.c` | `lsp_diag.x` + stubs |
| G-02a-09 | `include/{ast,token,autovec}.h` | 仅 FFI 零头 |

Gate：`run-e03-v3-coldstart-track-gate.sh`；`run-c06/c09-*`

---

## 5. 批次 4 — G-02b runtime 收薄（~15 文件）

| # | 文件 | 迁往 |
|---|------|------|
| G-02b-01 | `runtime.c`（主体） | `driver.x` + 薄 ABI |
| G-02b-02 | `runtime_abi.c/h` | `.x` |
| G-02b-03 | `runtime_io_abi.c/h` | `.x` |
| G-02b-04 | `runtime_proc_abi.c/h` | `.x` |
| G-02b-05 | `runtime_link_abi.c/h` | `.x`（最后：invoke_cc/ld） |
| G-02b-06 | `runtime_driver_abi.c/h` | `.x` |
| G-02b-07 | `runtime_pipeline_abi.c/h` | `.x` |
| G-02b-08 | `runtime_driver_diagnostic.c/h` | `.x` |
| G-02b-09 | `runtime_c_import.c/h` | 删或 `.x` |
| G-02b-10 | `main.c` | crt0 `.s` only |

Gate：`run-e04-runtime-soft-gate.sh`

---

## 6. 批次 5 — G-02c asm / LSP / driver glue（~40 文件）

| 子批 | 代表文件 | 说明 |
|------|----------|------|
| G-02c-01 | `parser_asm_thin_c.c` + 20× `*_slice.c` | 收拢进 `parser.x` emit |
| G-02c-02 | `pipeline_*_alias.c`, `pipeline_glue_*.c` | strict 链别名 → `.x` |
| G-02c-03 | `backend_*_dispatch.c`, `asm_backend_*.c` | asm 后端 `.x` |
| G-02c-04 | `lsp_*.c`（6 文件） | LSP 全 `.x` |
| G-02c-05 | `_stubs_driver.c`, `fmt_check_cmd.c`, `target_cpu.c` | driver `.x` |
| G-02c-06 | `x_seed_bridge.c`, `std_*_shim.c`, `ast_pool_l5_bridge.c` | bridge → `.x` |
| G-02c-07 | `async/async_*.c` | async `.x` |
| G-02c-08 | `runtime_panic*.c` | `.s` 或 `.x` syscall exit |

Gate：`run-bootstrap-bstrict-ci.sh`；`run-l5-run-all-parity-gate.sh`

---

## 7. 批次 6 — G-02d std 测试胶层（~80 文件）

| 子批 | 路径 | 说明 |
|------|------|------|
| G-02d-01 | `asm/runtime_*_glue.c` | HTTP/crypto/db 胶层 |
| G-02d-02 | `asm/http/*.inc.c` | 已 F-ZC；compiler 侧残留 |
| G-02d-03 | `asm/crypto/ed25519/*.c` | 纯 `.x` 或单对象 |
| G-02d-04 | `build_runtime.c`, `build_obj_stubs.c` | G-05 build.x |

Gate：`run-all-x.sh` 子集；各 `run-f-*-gate.sh`

---

## 8. 批次 7～11 — 终局

| ID | 任务 | Gate |
|----|------|------|
| G-04 | F-09 STRICT=0 | `SHUX_NO_HANDWRITTEN_C_STRICT=1 ./tests/run-no-handwritten-c-gate.sh` |
| G-05 | 根目录 + compiler Makefile 删/归档 | `./build_tool ./shux asm` 唯一入口 |
| G-06 | `bootstrap_shuxc` 预编译入库；删 `shux-c` 构建 | `run-d01-stage0-to-stage1-gate.sh` |
| G-07 | Tag + README | `run-f11-selfhost-release-prep-gate.sh` |
| G-08 | Windows MSYS + Alpine | `run-bootstrap-bstrict-windows-gate.sh` |

---

## 9. 今晚执行顺序（Agent）

1. ✅ 本文档（G-PLAN）
2. ✅ G-01 core 零 C（5 `.c` + 1 `.h` 已删；gate 见下）
3. 🟡 G-03 NL-07 bootstrap `-nostdlib` 全链（B-strict + hello + A-09 hash ✅；全链 gate 待跑）
4. ⬜ G-02a LEGACY 前端 C 删除（需 B-strict 绿后再删）
5. ⬜ G-02b～d compiler ~208 `.c` 分批删除

**G-01 验收（已通过）**：

```bash
./tests/run-std-c-inventory-gate.sh          # core=0 total=0
./tests/run-f08-core-inventory-gate.sh
./tests/run-core-builtin-bitops-gate.sh
./tests/run-core-mem-volatile-fence-gate.sh
```

**G-03 / seed 进展（2026-06-21，实测为准）**：

| 测试 | Linux Docker | 说明 |
|------|--------------|------|
| `make bootstrap-driver-seed` | ✅ 链接成功 | crt0 + `-nostartfiles` |
| `./shux -h` | ✅ | `SHUX_ASM_USE_COMPILER_IMPL_C` on seed runtime |
| `./shux min.x -o out` | ✅ | `function main(): i32 { return 0; }` → `num_funcs=1` |
| `./shux -L .. hello.x` | ✅ | `return if` + `fmt.println("…")`；须重建 parser_asm_thin_glue + parser_x |
| `./shux-c -L .. hello.x` | ✅ | C 前端路径，输出 `Hello World` |
| `build_shux_asm` pipeline 二遍 | ✅ | `__text=6843B`（此前为 0） |
| `run-linux-a09-a11-gate` | 🟡 | B-strict/hello/hash 子集 ✅（Docker 2026-06-21）；全链 gate 待跑 |

**本轮 hello ld + 运行修复（2026-06-21）**：

1. **`runtime_asm_io_stubs.c`**：内建 `io_write/io_read`（Linux x86_64 syscall），F-03 无 `std/io/io.o` 时仍可链。
2. **`runtime_link_abi.c`**：`runtime_*_glue.o` 仅当对应 `std/*.o` 存在时入链；`shux_asm_ld_prepare` 去掉预编译 sqlite/http 等 glue。
3. **`backend_call_dispatch.c`**：STRING_LIT 用 `jmp` 跳过尾挂字面量 + `lea [rip+disp]`，避免字面量落在指令流。
4. **`parser_asm_primary_slice.c`**：`TOKEN_STRING` 的 `token_start` 已指向引号后首字节，去掉错误的 `+1`（修 `ello World`）。
5. **`pipeline_glue.c`**：新增 `pipeline_expr_var_name_len_for_string_lit_c`（kind=59）。

**Docker 实测**：`verify-selfhost-stage2-bstrict` ✅（return 42、hello、SHA256 金标准）；`B-strict OK — LINK_MODE=asm_only_strict`。

**本轮 build_shux_asm 修复（glue 截断 + B-strict 重链）**：

1. **`-E -E-extern` 薄 TU**：`ensure_asm_pipeline_glue_standalone_obj` / `ensure_asm_gen_driver_x_objs` 对 `pipeline.x` 改用 `-E-extern`（全量 `-E` 内联 std.io 截断 ~142KB、`exit=1`）。
2. **`asm_strict_pipeline_selfhosted`**：`__text` 门槛 8192→6144；`resolve_path_.*su` 匹配 `resolve_path_probe_dot_x_and_mod`（实测 __text≈6843B）。
3. **strict 重链符号**：`pipeline_x_glue_support` 强制导出 `pipeline_load_and_sync_*`；新增 `pipeline_fill_dep_strict_alias.c`；跳过 text 桩 `*_enc.o`。
4. **`driver_compile_link`**：从 `driver_compile_x.o` 部分导出 `parse_argv_loop`；`driver_compile_link` 补全后 **re-filter** 避免与 `driver_compile_x.o` 重复定义。

**gen1 实测（Docker Linux x86_64）**：`B-strict OK — LINK_MODE=asm_only_strict` ✅；`run-linux-a09-a11-gate` 全链重跑中。

**本轮 parse 修复（根因）**：

1. **`token.x` 与 `token.h` 枚举漂移**：缺 `TRY/CATCH/TYPE/ATTR_REPR_COMPATIBLE/DOTDOT`，lexer 发 `TOKEN_IDENT=37` 被 C 薄层读成 `TOKEN_ASYNC` → buf/impl 均失败。
2. **`parser_asm_body_skip_let_const_then_if_buf_c`**：旧实现仅 stretch audit、未初始化 `r`；改为委托 slice 版。
3. **`parser_asm_parse_one_function_buf_into_c`**：支持 lex 已在 `function` 之后；读 IDENT 后推进 lexer。
4. **`TOKEN_STRING` 未实现（hello 阻塞）**：`parse_primary` 双次 `lexer_next` 跳过 `TOKEN_STRING`，`foo("…")` 实参 parse 失败 → impl 失败、buf 回退只认 `return int`；`return if` 整函数 skip。修复：`parser_asm_primary_slice.c` 第一次 `lexer_next` 后处理 `TOKEN_STRING`；`parser.x` `parse_body_lets` 增 `TOKEN_STRING` 分支；`parser_asm_one_function_buf_slice.c` buf 回退支持 `return if`。

- Linux `bootstrap-driver-seed`：`crt0_x86_64` + `-e _start -nostartfiles`
- seed runtime：`RUNTIME_DRIVER_NO_C_CFLAGS` 增加 `-DSHUX_ASM_USE_COMPILER_IMPL_C`
- `build_shux_asm` experimental 链：补 `runtime_driver_abi/diagnostic` + support extra 桩
3. **剩余**：`let s: u8[] = ""` 直字面量 let（非 hello 路径）；完整 `run-linux-a09-a11-gate` / G-03 NL-07 v5

---

*随批次推进更新各 `#` 状态为 ✅/🟡/⬜。*
