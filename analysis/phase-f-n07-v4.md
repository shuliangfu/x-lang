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

## 延后（v4 硬绿 / v5）

- 全链 nostdlib **硬绿**（experimental/strict 无 undefined reference）
- 默认 `SHUX_BOOTSTRAP_NOSTDLIB=1`
- pthread/io_uring 去系统库
