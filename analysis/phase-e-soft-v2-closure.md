# 阶段 E 闭合（E-soft v2 — gate 全绿）

> **2026-06-20**：阶段 E（编译器本体 C/H **软退役**）在 **gate 验收口径下闭合**。C/H **文件仍保留在仓库**；默认 `bootstrap-driver-seed` / B-strict **不链、不 cc -c** 已登记的前端 C。

## 闭合标准（与 NEXT §8 一致）

| 子项 | 验收 | gate |
|------|------|------|
| E-soft 聚合 | manifest + Makefile 默认 no_c frontend | `run-e-soft-retire-gate.sh` |
| E-01 | extern `.h` 已内嵌，不参与编译 | `run-e01-extern-h-soft-gate.sh` |
| E-02 | `lsp_diag.c` 默认 stubs | `run-e02-lsp-diag-soft-gate.sh` |
| E-03 | parser/typeck/codegen/preprocess/lexer/ast 默认不链 | E-03 v2/v3 gates |
| E-04 | 默认 `runtime_driver_no_c.o` + `runtime_*_abi` 薄壳 | `run-e04-runtime-soft-gate.sh`（v35 止，不再强制拆 runtime） |
| E-05 | 头文件 inventory + runtime NO_C include 守卫 | `run-e05-include-soft-gate.sh` |
| E-06 | B-strict 段无 `cc -c` 编译器前端 `.c` | `run-e06-no-compiler-frontend-cc-gate.sh` |

## 一键复现（全绿）

```bash
SHUX_E_SOFT_FAIL=1 ./tests/run-e-soft-retire-gate.sh
```

## 刻意 **不在** 阶段 E 的范围（勿与 E 全绿混淆）

| 项 | 说明 | 归属 |
|----|------|------|
| 物理删除 `runtime.c` / `parser.c` 等 | E-soft 策略为**文件保留** | 非 E 阻塞项 |
| 继续 E-04 v36+ 拆 `runtime.c` | v35 ABI 薄壳已满足 gate；主体留作 driver glue | 维护性优化，非 E |
| `OBJS_CORE` 去掉 C 前端 | 仅 `shux-c` 冷启动 / LEGACY 需要 | E-03 track，阶段 F 前可选 |
| `build_shux_asm` SEED 仍 cc -c lexer/ast | strict relink 考古路径 | E-03 track-only |
| std / include 全清 C | **完全自举终局** | **阶段 F（§9）** |

## E-04 最终形态（v1～v35）

- 默认链：`runtime_driver_no_c.o` + `runtime_{abi,io,proc,link,driver,pipeline,driver_diagnostic,c_import}.o`
- `runtime.c`：**active**（FFI/driver 胶水 + `shux-c` 路径），**不是** E 未完成标志
- 详细拆分记录：`analysis/phase-e-e04-v*.md`（v35 为最后一档 **gate 必需** 迁移）

## 下一阶段

- **主线**：阶段 F（std 无 C、`runtime` 链 `.x` 产物 .o）
- **可选维护**：E-02 v2（LSP 全 `.x`）、E-03 v4（SEED 拓扑）
