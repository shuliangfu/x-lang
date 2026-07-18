# 阶段 C-08 完成标准 v1（NEXT §6）

> **目标**：`main.c` 仅保留进程入口；驱动/构建编排迁 `.x`（`main.x` + `src/driver/*.x` + 根 `build.x`）；`runtime.c` 仅 ABI/C glue。

## v1 完成（✅）

| 项 | 标准 | Gate |
|----|------|------|
| main.c 薄入口 | `main()` 仅调 `main_entry`；行数 ≤ 20 | `run-c08-main-entry-gate.sh` |
| main.x 驱动 | `main_entry` + 子命令分发 | 同上 |
| driver/*.x | fmt/check/test/compile/build/run/emit 七模块 | `run-c08-driver-x-gate.sh` |
| build.x | 根构建策略 + `build_tool` 路径 | `run-c08-build-x-gate.sh` |
| runtime 盘点 | `runtime.c` 大块仍 C；`.x` 已接 SHUX_USE_X_DRIVER | `run-c08-runtime-inventory-gate.sh` |

## 已迁 .x（v1 登记）

- **入口**：`main.x` → `main_entry`、`-E`/`-backend`/子命令
- **子命令**：`compiler/src/driver/{fmt,check,test,compile,build,run,emit}.x`
- **构建策略**：根 `build.x` + `compiler/src/build_runtime.c`

## 仍留 C（不阻塞 v1 ✅）

- **runtime.c**：pipeline 桥接、ld 链接、read_file、LSP glue、asm -o `fopen`（B-20 track）
- **main.c**：3 行有效代码 + 文件头注释
- **fmt_check_cmd.c** 等 driver C 实现（driver.x 为薄委托）

## 延后（C-08 v2+）

- runtime.c 删至仅 ABI（程度 4 / 阶段 E）
- Makefile 默认入口改 `build.x` 单源（去 Makefile 策略重复）
