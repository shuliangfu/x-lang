# 阶段 F-context v2（std.context 节点存储 .x 下沉）

> **F-context v2**：**ctx_node 分配/原子/value 槽** 全量在 **`context.x`**；**删除 `context_node_glue.c`**；`context.o` 纯 `.x` 编译（同 cache v2）。

## 变更

| 项 | v1 | v2 |
|----|----|-----|
| 节点/原子 | `context_node_glue.c`（139 行） | **`context.x`** |
| `context.o` | `ld -r` glue + x | **纯 xlang → context.o** |
| cancelled | C11 atomic | `extern atomic_load/store_i32_c` |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_CONTEXT_V2_FAIL` retired. Delegates STD-071 context hard.

**2026-08-30 leftover XLANG fallthrough 已收**（f-context-v2：`for cand in "${XLANG:-}"` 退役；prefer asm＋`XLANG_LINK_XLANG`；显式坏 XLANG 先硬 die；缺 native 硬 die；leftover nested xlang_compiler_make／std-context 不重写）。

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-context-v2-gate.sh
./tests/run-std-context-gate.sh
```

## 下一项

- **F-sync v1**（已有）/ 其余 std 胶层继续 v2 化
