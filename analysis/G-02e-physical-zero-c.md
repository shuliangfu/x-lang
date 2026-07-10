# G-02e：compiler 物理去 C（终局清场）

> **目标**：仓库内手写 `.c/.h` → 0（允许：平台 `.s` crt0、预编译 seed 二进制、`*_gen.c` 由 .x 再生后不再入库）。  
> **现状（2026-07-10）**：`compiler/src` 手写 C **104**（G-04 permanent 白名单）；产品 G05 链 **53** objs，其中约半数仍源自 C。

## 1. 分层（务必按层砍，禁止无回归乱删）

| 层 | 内容 | 产品 G05 是否链接 | 去 C 策略 |
|----|------|-------------------|-----------|
| **P0 产品薄桩** | `typeck_f64_bits`、`pipeline_abi_f32_xmm`、link_alias、shims | ✅ | **优先**：`.s` / `.x` / 并入已有 .x |
| **P1 产品大块 runtime** | `runtime.c`、`runtime_link_abi.c`、`runtime_pipeline_abi.c`、ABI 七件套 | ✅ | 分 TU 迁 .x；argv/`getenv`/`waitpid` 等语言限制 → 先 asm/syscall 桥 |
| **P2 产品 asm 后端 C** | `backend_*_dispatch.c`、`simd_*.c`、`pipeline_glue_strict_minimal.c` | ✅ | 与 `.x` backend 合并；glue 随 pipeline .x 固定点收口 |
| **P3 冷启动 / std 胶** | `runtime_http_glue`、ed25519、http `.inc.c`、build_tool C | ❌ 编译器本体 | 迁 std `.x` 或预编译 `.o` seed；build 走 `build.x` |
| **P4 gen / seeds** | `*_gen.c`、`seeds/*.c` | 间接 | 固定点后不再提交 gen；冷启动用二进制 seed |

## 2. 产品路径必须留下的 C（迁完才算「编译器无 C」）

约 **35** 个 `compiler/src/**/*.c` 出现在 G05 链接图（见 `g05_relink_env.sh`）。最大项：

- `runtime.c` (~349KB)
- `runtime_link_abi.c` (~233KB)
- `pipeline_glue_strict_minimal.c` (~108KB)
- `backend_*_dispatch.c` 四件套
- `seed_link_compat.c`、`runtime_pipeline_abi.c`、`diag.c`、`simd_*.c`

`*_gen.c` / `typeck_x.o` 等是 .x 降级产物，**不算手写 C 终局**（终局应 asm 直接产 .o）。

## 3. 已完成

| 批次 | 项 | 提交/状态 |
|------|-----|-----------|
| G-02e-0 | **typeck_f64_bits.c → 全平台 .s**（Darwin arm64 / Linux x86_64 / Linux aarch64 ELF） | ✅ 176→175 |
| G-02e-1 | **合并薄 TU**：`pipeline_abi_f32_xmm.c`→`backend_call_dispatch.c`；`std_fs_shim.c`+`std_sys_shim.c`→`runtime_io_abi.c`；G05 70→67 objs | ✅ 175→172 |
| G-02e-2 | 删 `lsp_heap_bootstrap.c`（改链 `runtime_heap_user.o`）；`typeck_one_function` 并入 strict_glue_stubs，G05 去掉 `typeck_c_module_stubs.o`；G05 67→66 objs | ✅ 172→171 |
| G-02e-3 | **include 碎片改名**：`*.inc.c` / `parser_asm_*_slice.c` / ed25519 被 include 的 `.c` → **`.inc`**（不再计入手写 C 审计）；逻辑仍由 glue TU 编译 | ✅ 171→113 |
| G-02e-4 | `runtime_proc_abi.c`→`runtime_link_abi.c`；g05_ensure 自动补编缺失产品 `.o`；G05 −1 obj | ✅ 113→112 |
| G-02e-5 | `runtime_abi.c`→`runtime_link_abi.c`（argv/target + nostdlib weak）；G05 −1 obj | ✅ 112→111 |
| G-02e-6 | `codegen_pipeline_stubs.c`→`runtime_driver_strict_glue_stubs.c`；G05 −1 obj | ✅ 111→110 |
| G-02e-7 | `parser_asm_link_alias.c`→`parser_asm_parse_expr_link.c`；G05 −1 obj | ✅ 110→109 |
| G-02e-8 | 3×`*_x_link_alias`→`x_frontend_link_alias.c`；`lsp_diag_x_alias`→`lsp_diag_pipeline_ctx`；G05 −3 objs | ✅ 109→108 src；G05 62→59 |
| G-02e-9 | `bootstrap_seed_io_stubs`→`x_seed_bridge`；`lsp_state`→`lsp_diag_pipeline_ctx`；G05 −2 objs | ✅ 108→106 src；G05 59→57 |
| G-02e-10 | `_stubs_driver`→`runtime_driver_strict_glue_stubs`；产品链去掉 NO_WRAPPER orch 占位 TU；G05 −2 objs | ✅ src 106；G05 57→55 |
| G-02e-11 | `lsp_codegen_extern.c`→`runtime_driver_strict_glue_stubs.c`；G05 −1 obj | ✅ 106→105 src；G05 55→54 |
| G-02e-12 | `runtime_pipeline_abi_shux_c_stubs.c`→`runtime_driver_strict_glue_stubs.c`；G05 −1 obj | ✅ 105→104 src；G05 54→53 |

## 4. 建议下一刀（工作量升序）

1. **其它 G05 薄 companion**（`runtime_heap_user` 需同步 link_abi 用户链路径；`ast_pool_l5_bridge` 等）  
2. **拆 `runtime_link_abi` / `runtime.c`**：先抽纯逻辑到 `.x`，C 只留 `posix_spawn`/`stat`  
3. **backend dispatch / simd**：asm.x 固定点后删 C dispatch  
4. **P3 整批**：http `.inc` + ed25519 改预编译 seed 或 .x，permanent 批量摘牌  


每批门禁：

```bash
SHUX_NO_HANDWRITTEN_C_STRICT=1 ./tests/run-no-handwritten-c-gate.sh
SHUX=./compiler/shux SHUX_SKIP_SUBSCRIPT_MAKE=1 ./tests/run-lang-unsafe-gate.sh
# 产品：
cd compiler && sh scripts/g05_prepare_and_relink.sh
./shux check tests/return-value/main.x && ./shux -backend c -L . tests/return-value/main.x -o /tmp/rv && /tmp/rv; echo $?
```

## 5. 完成判据

- [ ] `summary_total_c == 0`（strict gate，无 permanent 例外）**或** permanent 仅剩文档约定的「不可消」且移出 `compiler/src` 到 `third_party/`  
- [ ] G05 产品链 **0 个手写 .c.o**（仅 `.s` + `.x`→.o + seed partial）  
- [ ] macOS arm64 + Linux x86_64 双平台 lang-unsafe + return-value 42  
