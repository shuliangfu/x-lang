# 阶段 F-NL-07 完成标准 v1（编译器 bootstrap 去 libc 准备）

> **NL-07 v1**：在 NL-06 v1 之上，登记并审计 **编译器 bootstrap** 仍依赖 `-lc/-lm` 与 `cc -c std/*.c` 的链入点；**不**改编译器链接行为，仅 manifest + track gate。

## v1 完成（✅ 准备层）

| 项 | 标准 | 产物 |
|----|------|------|
| NL-07 专文档 | 本文件 | `analysis/phase-f-n07-v1.md` |
| 准备 manifest | bootstrap 链入 / 阻塞项登记 | `tests/baseline/nolibc-n07-bootstrap-prep.tsv` |
| -lc 基线 | `build_shux_asm.sh` 链接行计数 | `tests/baseline/nolibc-n07-bootstrap-lc-track.tsv` |
| 审计库 | marker / lc 计数 / std cc 审计 | `tests/lib/nolibc-n07-bootstrap-audit.sh` |
| NL-07 专 gate | manifest + marker + 基线 + B-32 委托 | `tests/run-nolibc-n07-bootstrap-prep-gate.sh` |
| 聚合 gate | NL-07 委托 | `tests/run-no-libc-gate.sh` |

## v1 登记阻塞项（bootstrap 仍须 libc）

| 层 | 路径 | 说明 |
|----|------|------|
| 链接 | `compiler/scripts/build_shux_asm.sh` | crt0 / experimental / strict 链仍 `-lm -lc` |
| std C 编译 | `ensure_std_fs_io_heap_objs` | **F-06 v1 ✅** 空实现；不再 `cc -c std/*.c` |
| Makefile seed | `bootstrap-driver-seed` | **F-06 v1 ✅** 无 `../std/fs/fs.o` 等；改链 shim + runtime_io_abi |
| 浮点 | `typeck_f64_bits.o` + `-lm` | 消除 libm 为 NL-07 v2 |
| io_uring | `PIPELINE_LIBS=-luring -lpthread` | experimental 链；非 libc 但 hosted OS 库 |

## NL-07 marker（track）

`build_shux_asm.sh` 中 **F-no-libc NL-07 BEGIN/END** 块记录目标 nostdlib 链命令与前置条件；gate 审计该块存在且含 `-nostdlib` 目标描述。

## 复现

```bash
# NL-07 专 gate（任意平台 manifest OK）
SHUX_NOLIBC_N07_FAIL=1 ./tests/run-nolibc-n07-bootstrap-prep-gate.sh

# 全链聚合（含 NL-07 track）
SHUX_NOLIBC_FAIL=1 ./tests/run-no-libc-gate.sh
```

## 延后（NL-07 v2+）

- 实际启用 bootstrap `-nostdlib` 链（替换 crt0_x86_64 → crt0_user + freestanding_io）
- `ensure_std_fs_io_heap_objs` 改为编译 freestanding `.sx` 模块
- `bootstrap-driver-seed` Makefile 改链 `.sx` 产物
- 与阶段 F **F-06/F-07**（runtime 按需链、禁止 cc 编 std）对齐
