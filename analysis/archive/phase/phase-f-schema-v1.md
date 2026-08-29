# 阶段 F-schema v1（std.schema 去 C）

> **F-schema v1**：删除 **`schema.c`**；锚点 **`schema.x`**；typed decode 在 **`schema_glue.c`**（v2 已删 glue，逻辑在 `.x`）。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `schema.c`（680 行） | `schema.x`（v2 全量） |
| `schema.o` | `cc -c` | 纯 `.x` |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_SCHEMA_V1_FAIL` retired. Static + ensure hard. STD-090 observational (fossil `schema_new` vs live mod.x `new`/`add_field`).

**2026-08-30 leftover XLANG fallthrough 已收**（f-schema-v1：`for cand in "${XLANG:-}"` 退役；prefer asm＋`XLANG_LINK_XLANG`；显式坏 XLANG 先硬 die；缺 native 硬 die；leftover nested xlang_compiler_make／std-schema 不重写）。

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-schema-v1-gate.sh
```

## 下一项

- **F-socketio v1** ✅
