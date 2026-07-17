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

| 层 | 现象 | 方向（未做） |
|----|------|----------------|
| **拓扑 / multi-def** | `pipeline_glue_strict_minimal` ∩ `pipeline_glue_standalone`；`preprocess_if_stack_only` 与 standalone 重定义 | crt0 对象集去重；与 libc 成功链对齐 |
| **stdio 桩** | `fflush` UNDEF（crt0 `_start` + stubs `bootstrap_flush_stdio_and_exit`） | freestanding_io 或 nostdlib stubs **补全** fflush（G.7 有则补全） |
| **backend** | 大量 `backend_enc_*` / emit（≈前缀最大） | 入链真 enc `.o` 或兼容桩表完整化 |
| **typeck / driver / lsp** | `typeck_*` · `driver_diagnostic_*` · `lsp_*` | 与 experimental/strict 同源 companion 入链；禁第三套 |
| **diag / parser / codegen** | 次级 UNDEF 簇 | 随拓扑闭合自然降 |

unique UNDEF（修污染后 err 文件）≈ **291**。

## 延后（v4 硬绿 / v5）

- 全链 nostdlib **硬绿**（experimental/strict 无 undefined reference）— **本 try 未达**
- 默认 `SHUX_BOOTSTRAP_NOSTDLIB=1`
- pthread/io_uring 去系统库
