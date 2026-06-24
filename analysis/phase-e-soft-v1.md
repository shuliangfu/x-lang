# 阶段 E 软删除 v1（编译器去 C/H — 文件保留、链路与调用停用）

> **E-soft v1**：C/H **不物理删除**；默认 **B-strict / bootstrap-driver-seed** 构建与运行路径**不再链入、不再调用**已登记模块；冷启动 / 考古路径可用 `SHUX_LEGACY_C_FRONTEND=1` 或 `shux-c` 恢复。

## 原则

| 原则 | 说明 |
|------|------|
| **文件保留** | `compiler/src/**/*.c` 仍在仓库；仅加 `Phase E soft-retired` 文件头标记 |
| **默认不链** | `DRIVER_SEED_OBJS` 默认不含 C parser/typeck/codegen（C-06 ✅） |
| **gate 审计** | manifest 登记 + 子 gate 委托；回归时 `-lc` 前端未悄悄回到默认链 |
| **分步 E-01～E-06** | 与 `完全去掉C与H-前置清单.md` 程度 1～4 对齐 |

## v1 完成（✅ 准备 + 首批发软退役）

| 项 | 标准 | 产物 |
|----|------|------|
| E-soft 专文档 | 本文件 | `analysis/phase-e-soft-v1.md` |
| 软退役 manifest | C/H 路径 / 状态 / 替代 `.sx` | `tests/baseline/phase-e-soft-retire.tsv` |
| 审计库 | manifest / marker / Makefile 审计 | `tests/lib/phase-e-soft-audit.sh` |
| E-soft 聚合 gate | E-01 + C-03/C-04/C-06/C-09 委托 | `tests/run-e-soft-retire-gate.sh` |
| E-01 专 gate | extern `.h` 不再参与编译 | `tests/run-e01-extern-h-soft-gate.sh` |
| E-02 专 gate | `lsp_diag.c` 默认不链 | `tests/run-e02-lsp-diag-soft-gate.sh` |
| E-03 v2 专 gate | `preprocess.c` 默认不链 preprocess_for_driver | `tests/run-e03-preprocess-soft-gate.sh` |
| E-03 v2 专 gate | `lexer.c` / `ast_seed` 默认不链 | `tests/run-e03-lexer-ast-soft-gate.sh` |
| E-03 v3/v4 专 gate | 冷启动 track + OBJS_CORE ABI 对齐 | `tests/run-e03-v3-coldstart-track-gate.sh` |
| E-04 v1/v3 专 gate | runtime_abi + runtime_io_abi 薄壳 | `tests/run-e04-runtime-soft-gate.sh` |
| E-06 v1/v2/v3/v4 专 gate | B-strict 禁前端 cc -c + SEED SX skip（strict / gen_driver） | `tests/run-e06-no-compiler-frontend-cc-gate.sh` |
| E-05 v1/v2 专 gate | 头文件 inventory + runtime NO_C include 守卫 | `tests/run-e05-include-soft-gate.sh` |

## v1 已软退役（默认 bootstrap 不链 / 不 -include）

| E | 路径 | 替代 | 说明 |
|---|------|------|------|
| E-01 | `lsp_io_extern.h` / `lsp_gen_extern.h` | `lsp_codegen_extern.c` 内嵌块 | 文件已不存在；C-04 `-E-extern` 自带 extern |
| E-02 | `lsp_diag.c` | `lsp_diag_stubs_no_c.o` + `lsp_diag_sx.o` | `LSP_DIAG_LINK_O`；`SHUX_LEGACY_LSP_DIAG_C=1` 考古 |
| E-03 | `parser.c` / `typeck.c` / `codegen.c` / `preprocess.c` / `lexer.c` / `ast.c` | `*_sx.o` + bridge | C-06 + E-03 v2 默认 seed 不链 C 辅助 TU |

## 仍 active（v1 不阻塞，后续 E-04 软退役）

| 路径 | 说明 |
|------|------|
| `runtime.c` / `runtime_driver*.o` | E-04 v6：compress/net TLS 链辅助拆 runtime_link_abi.c；invoke_cc/ld 主体仍 active |
| `main.c` | 极薄入口；E-04 |
| asm 桥接 / stub `.c` | backend `extern *_c` 仍活跃；E-03 v4+ |
| `lsp_diag.c` | 仅 `SHUX_LEGACY_LSP_DIAG_C=1` / `shux-c` OBJS_CORE |
| `preprocess.c` / `lexer.c` / `ast.c` | 仅 LEGACY 开关 / `shux-c` OBJS |
| `include/*.h` / `src/**/*.h` | E-05 v2：C 前端头 soft_retired；runtime NO_C 不 include |

## 复现

```bash
# E-soft 聚合（任意平台 manifest OK）
SHUX_E_SOFT_FAIL=1 ./tests/run-e-soft-retire-gate.sh

# E-01 专 gate
SHUX_E01_FAIL=1 ./tests/run-e01-extern-h-soft-gate.sh

# E-02 lsp_diag.c 软退役（默认 stubs）
SHUX_E02_FAIL=1 ./tests/run-e02-lsp-diag-soft-gate.sh

# E-03 v2 preprocess.c 软退役（默认不链 preprocess_for_driver.o）
SHUX_E03_PREPROCESS_FAIL=1 ./tests/run-e03-preprocess-soft-gate.sh

# E-03 v2 lexer/ast 软退役（默认不链 lexer.o / ast_seed.o）
SHUX_E03_LEXER_AST_FAIL=1 ./tests/run-e03-lexer-ast-soft-gate.sh

# E-03 v3 冷启动 track（OBJS_CORE / asm SEED 对照默认 bootstrap）
SHUX_E03_V3_FAIL=1 ./tests/run-e03-v3-coldstart-track-gate.sh

# E-04 v1/v2 runtime 路径 + ABI 薄壳
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh

# E-06 v1 B-strict 禁 cc -c 编译器前端 .c
SHUX_E06_FAIL=1 ./tests/run-e06-no-compiler-frontend-cc-gate.sh

# E-05 v1/v2 头文件 inventory
SHUX_E05_FAIL=1 ./tests/run-e05-include-soft-gate.sh
```

## v2 闭合（✅ gate 全绿，2026-06-20）

- **E-01～E-06** 子 gate + `run-e-soft-retire-gate.sh` 在 `SHUX_*_FAIL=1` 下全部通过。
- 详见 **`analysis/phase-e-soft-v2-closure.md`**（闭合标准 / 非 E 范围 / 下一阶段 F）。

```bash
SHUX_E_SOFT_FAIL=1 ./tests/run-e-soft-retire-gate.sh
```

## 延后（阶段 F / 可选维护，非 E 阻塞）

- **阶段 F**：std/core 去 C、`runtime` 按需链 `.sx` 产物（完全自举终局）
- E-02 v2：definition/hover 全 `.sx`，OBJS_CORE 去 `lsp_diag.o`
- E-03 v4 / E-03 v5：`OBJS_CORE` / SEED 改默认 SX 拓扑（`shux-c` 冷启动另议）
- E-04 v36+：**不再作为 E 项**；runtime 主体拆分属维护性，gate 已在 v35 满足
