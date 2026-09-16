# 阶段 F-json v2（std.json 逻辑 .x 下沉）

> **F-json v2**：解析/游标/序列化/类型化 decode 全量迁入 **`json.x`**；**纯 .x**（无 OS/pthread/malloc；仅 extern memcmp）。

## 变更

| 项 | v1 | v2 |
|----|----|-----|
| 解析/游标/序列化 | `json_parse_glue.c`（~883 行） | **`json.x`** |
| `json.o` | `ld -r` glue + x | **仅 x（`json_main.o`）** |
| mod.x | extern json_*_c | **不变** |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_JSON_V2_FAIL` retired. Delegates STD-008 json＋object-array＋serialize hard; typed-decode product residual observational.

**2026-08-30 leftover XLANG fallthrough 已收**（f-json-v2：`for cand in "${XLANG:-}"` 退役；prefer asm＋`XLANG_LINK_XLANG`；显式坏 XLANG 先硬 die；缺 native 硬 die；leftover nested xlang_compiler_make／std-json／std-json-object-array／std-json-serialize／std-json-typed-decode 不重写）。

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-json-v2-gate.sh
./tests/run-std-json-gate.sh
./tests/run-std-json-object-array-gate.sh
./tests/run-std-json-serialize-gate.sh
./tests/run-std-json-typed-decode-gate.sh
```

## 下一项

- 继续阶段 F std 去 C（http / async / channel 等胶层）
