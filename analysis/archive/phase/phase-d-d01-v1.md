# 阶段 D-01 完成标准 v1（NEXT §7）

> **D-01 v1**：**Stage 0**（C/seed：`bootstrap-driver-seed` / `xlang-c` 冷启动）→ **Stage 1**（`xlang_asm` B-strict asm 链编译器）。

## v1 完成（✅）

> **Honesty 2026-08-24 #12 / 2026-08-27:** top-level DOC + soft `XLANG_D01_FAIL` retired (missing `compiler/Makefile` was portable false-green). Live = this archive path + `./xbuild` + `bootstrap_driver_bstrict.sh`.

| 项 | 标准 | Gate |
|----|------|------|
| Stage 0 | `./xbuild` seed / `bootstrap.sh` 产出 seed `xlang` | manifest 登记 |
| Stage 1 | `./xbuild bootstrap-driver-bstrict` → `compiler/xlang_asm` | `run-d01-stage0-to-stage1-gate.sh` |
| 拓扑 | `XLANG_ASM_EXPERIMENTAL_SKIP_GEN=1` + B-strict 日志标记 | 同上 + C-03 衔接 |
| 发布 | `xlang_asm` → `compiler/xlang`（D-05） | 委托 D-05 gate 登记 |

## Gate

```bash
./tests/run-d01-stage0-to-stage1-gate.sh
# Optional:
#   ./xbuild bootstrap-driver-bstrict 2>&1 | tee /tmp/build_bstrict.log
#   XLANG_D01_BUILD_LOG=/tmp/build_bstrict.log ./tests/run-d01-stage0-to-stage1-gate.sh
# Report: doc=/bstrict=/native=/skip=
# Soft XLANG_D01_FAIL + soft SKIP-when-no-native + Makefile anchors retired (die always hard).
```

PLATFORM: SHARED archaeology.

## track-only（不阻塞 v1 ✅）

- Stage1 仍链 **少量 C seed / runtime_panic / ast_seed**（完全无 C 属阶段 E）
- Windows / 非 Linux：B-hybrid 路径见 C-03 track

## 延后（D-01 v2）

- Stage1 **零** C 前端 `.o`（与 E-03 对齐）
- Stage1 与 `xlang-c` 输出能力 **字节级** diff（非 v1 范围）
