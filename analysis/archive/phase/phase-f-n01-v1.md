# 阶段 F-NL-01 完成标准 v1（F-no-libc 准备）

> **NL-01 v1**：零 libc 路线的**准备层**——路线图、策略 manifest、专 gate 与聚合 gate 登记；**不**改编译器行为，仅可审计、可复验。

## v1 完成（✅）

| 项 | 标准 | 产物 |
|----|------|------|
| 总览文档 | F-no-libc 目标与 NL-02～06 顺序 | `analysis/phase-f-no-libc-v1.md` |
| NL-01 专文档 | 本文件 | `analysis/phase-f-n01-v1.md` |
| 准备 manifest | 登记 doc/gate/roadmap/policy/基础设施 | `tests/baseline/nolibc-n01-preparation.tsv` |
| 路线图 | syscall/std 模块进度 | `tests/baseline/no-libc-roadmap.tsv` |
| 链接策略 | 用户 vs 编译器 bootstrap 分工 | `tests/baseline/no-libc-link-policy.tsv` |
| NL-01 专 gate | manifest + 基础设施审计 | `tests/run-nolibc-n01-preparation-gate.sh` |
| 聚合 gate | NL-01 委托 + NL-02～05 子 gate | `tests/run-no-libc-gate.sh` |

## 基础设施（NL-01 登记，NL-02 前已有）

| 层 | 路径 | 说明 |
|----|------|------|
| crt0 | `compiler/src/asm/crt0_user_x86_64.s` | 用户 `_start` |
| syscall .s | `compiler/src/asm/freestanding_io_x86_64.s` | IO/mmap/socket |
| sys 门面 | `std/sys/linux.x`、`std/sys/mod.x` | extern + 薄封装 |
| S4 烟测 | `tests/run-freestanding-hello.sh` | 基线 freestanding |

## 子 gate 委托链（NL-01 聚合，非 NL-01 本体）

| NL | 子 gate | 说明 |
|----|---------|------|
| NL-02 | `run-no-libc-socket-gate.sh` | socket syscall |
| NL-03 | `run-no-libc-heap-gate.sh` | mmap bump 堆 |
| NL-04 | `run-no-libc-fs-gate.sh` | freestanding 读文件 |
| NL-05 | `run-no-libc-link-gate.sh` | runtime 无 `-lc` 审计 |

## 复现

```bash
# NL-01 专 gate（任意平台 manifest OK）
SHUX_NOLIBC_N01_FAIL=1 ./tests/run-nolibc-n01-preparation-gate.sh

# 仅 manifest（不跑子 gate）
SHUX_NOLIBC_N01_MANIFEST_ONLY=1 ./tests/run-nolibc-n01-preparation-gate.sh

# 全链聚合（Linux x86_64 硬绿）
SHUX_NOLIBC_FAIL=1 ./tests/run-no-libc-gate.sh
```

## track-only（不阻塞 NL-01 ✅）

- 编译器 bootstrap（`build_shux_asm.sh`）仍 `-lc/-lm` → F-07
- hosted 程序仍链 libc → 与 freestanding 路径正交

## 后续（NL-07 起）

- **NL-07 v1**：编译器 bootstrap 去 `-lc` 准备 → `analysis/phase-f-n07-v1.md`
- **NL-06 v2+ / NL-07 v2**：全 std `.c` 迁移 + 启用 bootstrap nostdlib 链
