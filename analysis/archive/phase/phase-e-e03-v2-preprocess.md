# 阶段 E-03 v2（preprocess.c 软退役 — 首刀）

> **E-03 v2 preprocess**：默认 bootstrap / shux-x / bootstrap-driver-seed **不链** `preprocess_for_driver.o`；`runtime preprocess()` 在 `SHUX_USE_X_PIPELINE` 下走 `preprocess.x`（`su_preprocess_raw_to_malloc`）。`preprocess.c` 文件保留。

## v2 preprocess 完成（✅）

| 项 | 标准 | 产物 |
|----|------|------|
| runtime | `SHUX_USE_X_PIPELINE` 默认走 X；`SHUX_LEGACY_PREPROCESS_C` 走 C | `compiler/src/runtime.c` |
| Makefile | `PREPROCESS_LINK_O` 默认空；考古开关 | `compiler/Makefile` |
| 文件头 | Phase E soft-retired 标记 | `compiler/src/preprocess.c` |
| Gate | manifest + Makefile 审计 | `tests/run-e03-preprocess-soft-gate.sh` |

## 复现

```bash
SHUX_E03_PREPROCESS_FAIL=1 ./tests/run-e03-preprocess-soft-gate.sh
make -C compiler bootstrap-driver-seed   # 默认不链 preprocess_for_driver.o
SHUX_LEGACY_PREPROCESS_C=1 make -C compiler bootstrap-driver-seed  # 考古 C 路径
```

## 仍 active（E-03 v2 后续）

| 路径 | 说明 |
|------|------|
| `build_shux_asm` SEED | `asm_driver_seed/preprocess.o` 考古 C 对象（strict relink） |

## 延后（E-03 v3+）
- `OBJS_CORE`（shux-c）改默认 X preprocess
- `build_shux_asm` strict 路径去 `SEED_O/preprocess.o`
