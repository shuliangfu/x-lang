# 阶段 E-03 v3（xlang-c 冷启动 / asm SEED — track-only）

> **E-03 v3**：**不改动**历史 `OBJS_CORE`（`xlang-c`）与 `build_xlang_asm` 的 `asm_driver_seed/*.o` 考古 C 编译故事；用 manifest + gate **登记对照**：默认 bootstrap 已不链 E-03 软退役 TU，冷启动走 **G-06 `bootstrap_xlangc`**；SEED 默认 **G-02a omit C frontend**。
>
> **Honesty（2026-08-27）**：顶层 `analysis/phase-e-e03-v3-coldstart.md` 与 `compiler/Makefile` 已退役（MG wave941）；活权威 = 本 archive DOC + `mk/driver_seed_*.mk` + `build_xlang_asm.sh`。soft `XLANG_E03_V3_FAIL` 已退役（die always hard）。

## v3 完成（✅ track gate）

| 轨道 | 仍可考古的 C | 默认 bootstrap 已不链 |
|------|-----------------|----------------------|
| 冷启动 | G-06 `bootstrap_xlangc`（替代 OBJS_CORE） | `DRIVER_SEED_OBJS`（mk）无 C parser/lexer/ast_seed |
| asm SEED | `ensure_asm_driver_seed_c_objs`（LEGACY 逃生） | G-02a omit → B-strict 主链 `*_x.o` |

## Gate

```bash
./tests/run-e03-v3-coldstart-track-gate.sh
# Manifest-only:
#   XLANG_E03_V3_MANIFEST_ONLY=1 ./tests/run-e03-v3-coldstart-track-gate.sh
# Report: doc=/g06=/seed=/mk=/c06=/skip=
# Soft XLANG_E03_V3_FAIL + top-level DOC/Makefile anchors retired (die always hard).
# Delegate: C-06 x-frontend-default (already hard).
```

PLATFORM: SHARED archaeology.

## 延后（E-03 v4 / E-02 v2 / E-06）

- `build_xlang_asm` strict 去 `SEED_O/preprocess.o` 等 C 对象（LEGACY 外）
- E-06：bootstrap CI 硬禁 `cc -c compiler/src/**/*.c`（链接 ld 除外）— 已 honesty 硬绿
