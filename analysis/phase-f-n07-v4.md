# 阶段 F-NL-07 完成标准 v4（bootstrap nostdlib 全链试跑）

> **NL-07 v4**：在 v3 烟测硬绿之上，**可选** 在 `shux_asm` 已构建时以 `SHUX_BOOTSTRAP_NOSTDLIB=1` 重跑 `build_shux_asm` 并记录链接结果。

## v4 首层（🟡 track）

| 项 | 标准 | 产物 |
|----|------|------|
| NL-07 v4 文档 | 本文件 | `analysis/phase-f-n07-v4.md` |
| POSIX 桩扩展 | open/read/close/fstat/waitpid/fopen | `bootstrap_nostdlib_stubs.c` |
| shux-c 冷链修复 | runtime_pipeline_abi X 符号弱桩 | `runtime_pipeline_abi_shux_c_stubs.c` |
| runtime_io_abi | `#include <stdint.h>`（INT32_MAX） | `runtime_io_abi.c` |
| v4 build gate | manifest + 可选全链试跑 | `tests/run-nolibc-n07-v4-build-gate.sh` |

## 全链试跑（v4）

```bash
# 前置：bootstrap-driver-bstrict 已产出 shux_asm
make -C compiler bootstrap-driver-seed
make -C compiler bootstrap-driver-bstrict

# nostdlib 重链
cd compiler && SHUX_BOOTSTRAP_NOSTDLIB=1 ./scripts/build_shux_asm.sh

# v4 gate（Linux x86_64 + shux_asm 存在时硬试跑）
SHUX_NOLIBC_N07_V4_TRY_BUILD=1 SHUX_NOLIBC_N07_V4_FAIL=1 ./tests/run-nolibc-n07-v4-build-gate.sh
```

## Docker amd64 冷启动

```bash
make -C compiler bootstrap-driver-seed
make -C compiler bootstrap-driver-bstrict
```

## 2026-07-17 try 记录（Ubuntu · tip `a0a0fc0e`）

| 项 | 结果 |
|----|------|
| 命令 | `SHUX_NOLIBC_N07_V4_TRY_BUILD=1 SHUX_NOLIBC_N07_V4_FAIL=1 ./tests/run-nolibc-n07-v4-build-gate.sh` |
| 日志 | `/tmp/ubuntu_n07_v4_try_a0a0fc0e.log` · `compiler/build_asm/.bootstrap_nostdlib_link_err` |
| 机械根修 | `build_shux_asm.sh`：`bootstrap_link_tail_crt0/driver` 内 `ensure_*` 进度改 **stderr**（commit **`a0a0fc0e`**）。此前 `$(tail)` 吞进 `echo " cc -c ..."` → 链行假失败，**掩盖**真 UNDEF |
| gate | **OK**（track：`build_shux_asm` exit 0 + **libc fallback**） |
| nostdlib crt0 | **红** — 无 `bootstrap nostdlib crt0 link OK` |
| 产物 | `ldd shux_asm` 仍 **`libc.so.6`**（≠ 零 libc 硬绿） |

### 修后真 residual（crt0 nostdlib 链 · 分层地图）

> **禁止** 一波搅多债。硬绿按层推进；权威仍 `build_shux_asm.sh` + freestanding/stubs + 产品对象拓扑。

| 层 | 现象 | 方向 |
|----|------|------|
| **拓扑 / multi-def** | ~~strict_minimal ∩ standalone；preprocess_if_stack_only ∩ standalone~~ | ✅ **L1 @ `e3d63a68`**：`filter_crt0_asm_objs`；Ubuntu multi **0** |
| **stdio 桩** | ~~`fflush` UNDEF~~ | ✅ **L2 @ `6a945f5b`**：`bootstrap_nostdlib_stubs` 补全 `fflush`（G.7；**非** freestanding_io） |
| **backend enc** | ~~大量 `backend_enc_*` / arch_emit / try_inline / simd~~ | ✅ **L3 @ `b613f58e`**：crt0 追加 `BSTRICT_DISPATCH_OBJS`+simd（与 experimental 同权威） |
| **backend emit** | ~~`backend_emit_*`（10 · L3 后 head）~~ | ✅ **L3b @ `57fa657d`**：seed `backend_emit_*` partial export（非整颗 seed；避 multi-def） |
| **typeck / driver / lsp** | ~~`typeck_*` · `driver_*` 主簇 · `lsp_*` 主簇~~ | ✅ **L4+ @ `94f0ae11`**：experimental 同源 companion；`typeck_x` 仅 bag 未自举 |
| **codegen / parser** | ~~`codegen_*` · `parser_*` · residual lsp sizes~~ | ✅ **L5 @ `0d51a264`**：residual-only partial（L3b 模式；禁 full mega multi-def） |
| **nostdlib libc 面** | ~~`fileno` / `isatty` / `puts` / `strerror` / `fread` / `ferror` / `stdin` / `remove` / `__ctype_b_loc`~~ | ✅ **L6 @ `2742bafa`**：`bootstrap_nostdlib_stubs` 补全（G.7；**非** freestanding_io） |

unique UNDEF（L6 后 err）= **0**（L5=9；L4+ ≈41；L3b ≈147；L3 ≈156；L2 ≈283；L1 ≈284；L0 try ≈291）。

## 2026-07-17 L1（Ubuntu · tip `e3d63a68`）

| 项 | 结果 |
|----|------|
| 根修 | `filter_crt0_asm_objs`：standalone 在 bag 时 drop `pipeline_glue_strict_minimal` + `preprocess_if_stack_only` |
| 日志 | `/tmp/ubuntu_n07_l1_e3d63a68.log` · err multi=**0** |
| nostdlib crt0 | **仍红**（UNDEF 主导；当时 head 为 `fflush`） |
| 产品 | `function main(): i32 { return 42; }` **rv=42** |

## 2026-07-17 L2（Ubuntu · tip `6a945f5b`）

| 项 | 结果 |
|----|------|
| 根修 | `seeds/bootstrap_nostdlib_stubs.from_x.c` 定义 `int fflush(FILE*)`（unbuffered stub no-op）；权威仅本 TU（nostdlib-only） |
| 日志 | `/tmp/ubuntu_n07_l2_6a945f5b.log` · err **fflush 行=0** · multi=**0** |
| nostdlib crt0 bag | **仍红** unique UNDEF≈**283**（head `backend_enc_*`）；**无** `bootstrap nostdlib crt0 link OK` |
| gate | **OK**（匹配 `bootstrap nostdlib final link OK`；**≠** crt0 全绿） |
| 产品 | `function main(): i32 { return 42; }` **rv=42** |

## 2026-07-17 L3（Ubuntu · tip `b613f58e`）

| 项 | 结果 |
|----|------|
| 根修 | `ensure_crt0_backend_companion_objs`：crt0 链 `backend_enc_dispatch` + `backend_x86_64_enc_c` + arch_emit / try_inline / call + simd_*（G.7 = `BSTRICT_DISPATCH_OBJS` 权威） |
| 日志 | `/tmp/ubuntu_n07_l3_b613f58e.log` · err **backend_enc=0** · multi=**0** · unique UNDEF **283→156** |
| nostdlib crt0 bag | **仍红**（head `backend_emit_*`×10 → typeck/driver）；**无** `bootstrap nostdlib crt0 link OK` |
| gate | **OK**（final-link loose；**≠** crt0 全绿） |
| 产品 | `function main(): i32 { return 42; }` **rv=42** |

## 2026-07-17 L3b（Ubuntu · tip `57fa657d`）

| 项 | 结果 |
|----|------|
| 根修 | `ensure_crt0_backend_emit_seed_partial_obj`：从 `seed_host/asm_backend_partial.o` **仅** export `backend_emit_*` T+W → `crt0_backend_emit_seed_partial.o`（G.7；禁整颗 seed / 第二套桩表） |
| 日志 | `/tmp/ubuntu_n07_l3b_57fa657d.log` · err **backend_emit=0** · multi=**0** · unique UNDEF **156→147** |
| nostdlib crt0 bag | **仍红**（head `driver_*` / typeck / codegen）；**无** `bootstrap nostdlib crt0 link OK` |
| gate | **OK**（final-link loose；**≠** crt0 全绿） |
| **双端产品** | mac g05 矩阵 rv/opt/hello/si **绿**；Ubuntu g05 矩阵 **绿**（日志 mac `/tmp/mac_g05_n07_l3b.log` · Ubuntu `/tmp/ubuntu_g05_n07_l3b.log`） |

## 2026-07-17 L4+（Ubuntu · tip `94f0ae11`）

| 项 | 结果 |
|----|------|
| 根修 | `ensure_crt0_typeck_driver_lsp_companion_objs`：crt0 链 runtime_driver_* + abi + diag + driver_*_x + lsp_*_x + lsp_diag seed + rt_* slices；`typeck_x` 仅 bag typeck 未自举（G.7 experimental 同源；禁整行 experimental multi-def） |
| 日志 | `/tmp/ubuntu_n07_l4p_94f0ae11.log` · err **typeck=0** · multi=**0** · unique UNDEF **147→41** |
| nostdlib crt0 bag | **仍红**（head `parser_*` / `codegen_*` / residual lsp sizes）；**无** `bootstrap nostdlib crt0 link OK` |
| gate | **OK**（final-link loose；**≠** crt0 全绿） |
| **双端产品** | mac g05 矩阵 rv/opt/hello/si **绿**；Ubuntu g05 矩阵 **绿**（日志 mac `/tmp/mac_g05_n07_l4p.log` · Ubuntu `/tmp/ubuntu_g05_n07_l4p.log`） |

## 2026-07-17 L5（Ubuntu · tip `0d51a264`）

| 项 | 结果 |
|----|------|
| 根修 | `ensure_crt0_codegen_parser_companion_objs`：residual-only partial export（codegen_x / x_frontend / strict_glue / fmt_check / lsp_ctx / strict_minimal / parser_x cascade keep-global / thin_glue `parser_*_glue`）+ lexer_x / cfg_eval / lsp sizes nostub / process_argv / parse_expr_link；parser/pipeline 仅 bag 未自举（G.7；禁 full mega multi-def） |
| 日志 | `/tmp/ubuntu_n07_l5d_0d51a264.log` · err multi=**0** · unique UNDEF **41→9** |
| nostdlib crt0 bag | **仍红**（**仅** libc 面 9 符号）；**无** `bootstrap nostdlib crt0 link OK` |
| gate | **OK**（final-link loose；**≠** crt0 全绿） |
| **双端产品** | mac g05 矩阵 rv/opt/hello/si **绿**；Ubuntu g05 矩阵 **绿**（日志 mac `/tmp/mac_g05_n07_l5.log` · Ubuntu `/tmp/ubuntu_g05_n07_l5.log`） |

## 2026-07-17 L6（Ubuntu · tip `2742bafa`）

| 项 | 结果 |
|----|------|
| 根修 | `seeds/bootstrap_nostdlib_stubs.from_x.c`：`stdin` + `fileno`/`ferror`/`fread`/`puts`/`isatty`/`strerror`/`remove`/`__ctype_b_loc`（glibc little-endian `_ISbit` 表）；权威仅本 TU（与 L2 fflush 同 G.7 面；**非** freestanding_io） |
| 日志 | `/tmp/ubuntu_n07_l6_2742bafa.log` · err multi=**0** · unique UNDEF **9→0**（err 文件 0 字节） |
| nostdlib crt0 bag | ✅ **`bootstrap nostdlib crt0 link OK`**（no libc/libm）；`ldd`：静态 / 非动态可执行文件 |
| gate | ✅ **OK**（full-chain try completed；**crt0 path**） |
| **双端产品** | mac g05 矩阵 rv/opt/hello/si **绿**；Ubuntu g05 矩阵 **绿**（日志 mac `/tmp/mac_g05_n07_l6.log` · Ubuntu `/tmp/ubuntu_g05_n07_l6.log`） |
| 备注 | 构建期 postlink smoke 偶发 WARN→experimental 回退；链后复测 `shux_asm_postlink_smoke` **OK**（-c + asm -o exit=42）。纯 static 产品路径 hello 曾见 f64 发射 `g.0`（g05 绿；**运行时/发射质量 residual，≠ 链接 UNDEF**） |

## 2026-07-17 L7（Ubuntu · tip `fffc0d59` · 运行时质量）

| 项 | 结果 |
|----|------|
| 根修 | ① `bootstrap_nostdlib_stubs` vsnprintf：`%g/%G/%e/%E/%F` → `bootstrap_format_double`（`156d01f9`；修 `g.0`）② crt0 入链 `preprocess_x.o` + export `preprocess_eval_condition_c`（`5adee364`；修弱桩 PP002）③ crt0 入链 `user_asm_seed_bridge.o`（`fffc0d59`；修弱桩 CG002） |
| 日志 | `/tmp/ubuntu_n07_l7c_fffc0d59.log` · multi=**0** · err 空 |
| nostdlib crt0 bag | ✅ **crt0 link OK** 保持；**postlink smoke OK 无 experimental/compiler fallback**（`NO_POSTLINK_FALLBACK=1` 下仍绿；复测×3） |
| 纯 static 探针 | f64 lit → `1.500000`（非 `g.0`）；rv=42（c + default asm -o） |
| pure static residual | hello / option / stdlib-import **XT001** check_block（import 面；→ L7+） |
| **双端 g05** | mac + Ubuntu rv/opt/hello/si **绿**（`/tmp/mac_g05_n07_l7b.log`） |

## 2026-07-17 L7+（Ubuntu · tip `de6846af` · pure static import typeck）

| 项 | 结果 |
|----|------|
| 根修 | L5 `crt0_l5_parser_partial` keep-global 补 `parser_get_module_num_imports` + `parser_get_module_import_path`（`de6846af`）；权威 `parser_x.o`；禁弱桩第二套（G.7） |
| 根因 | keep-global 漏列 → 真体 demote local → pipeline U-ref 绑 experimental_symbol_bridge 弱桩（num=0）→ 不 open dep → XT001 |
| 日志 | `/tmp/ubuntu_n07_l7p_de6846af.log` · multi/global_T_multi=**0** · crt0 OK · smoke OK |
| pure static | **XT001 关**；opt -o **绿** run=102；hello/si **typeck OK**；strace open `std/fmt` 等 |
| pure static residual | hello **-o** `std_io_print_u8_ptr_usize` UNDEF；si **-o** host cc dep emit 序（**非** XT001） |
| **双端 g05** | mac rv/opt/hello/si **绿**（`/tmp/mac_g05_n07_l7p.log`） |

## 延后（v4 运行时硬绿 / v5）

- 链接层 crt0 bag **无 undefined reference** — ✅ **L6 已达**
- 构建期 smoke 稳定无 fallback — ✅ **L7 已达**（pure crt0 路径）
- 纯 static f64 发射 — ✅ **L7 已达**
- pure static import typeck — ✅ **L7+ 已达**；hello/si **-o** 后层 residual
- 默认 `SHUX_BOOTSTRAP_NOSTDLIB=1`
- pthread/io_uring 去系统库

