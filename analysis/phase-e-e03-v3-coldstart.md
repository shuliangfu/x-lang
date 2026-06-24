# 阶段 E-03 v3（shux-c 冷启动 / asm SEED — track-only）

> **E-03 v3**：**不改动** `OBJS_CORE`（`shux-c`）与 `build_shux_asm` 的 `asm_driver_seed/*.o` 考古 C 编译；用 manifest + gate **登记对照**：默认 `bootstrap-driver-seed` 已不链 E-03 软退役 TU，冷启动仍保留 C 路径。

## v3 完成（✅ track gate）

| 轨道 | 仍 `cc -c` 的 C | 默认 bootstrap 已不链 |
|------|-----------------|----------------------|
| shux-c | `OBJS_CORE`（parser/typeck/codegen/preprocess/lexer/ast/lsp_diag…） | `DRIVER_SEED_OBJS` + `*_LINK_O` 变量 |
| asm SEED | `ensure_asm_driver_seed_c_objs` | B-strict 主链 `*_sx.o` / `runtime_driver_asm_strict.o` |

## 复现

```bash
SHUX_E03_V3_FAIL=1 ./tests/run-e03-v3-coldstart-track-gate.sh
```

## 延后（E-03 v4 / E-02 v2 / E-06）

- `OBJS_CORE` 改默认 SX 拓扑（须保留 `shux-c` 冷启动故事或新 seed 文档）
- `build_shux_asm` strict 去 `SEED_O/preprocess.o` 等 C 对象
- E-06：bootstrap CI 硬禁 `cc -c compiler/src/**/*.c`（链接 ld 除外）
