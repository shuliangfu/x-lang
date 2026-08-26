# 阶段 F-06 v2（Stage2 验证脚本 legacy std .o 清场）

> **F-06 v2**：`verify-selfhost-stage2.sh` 不再链接已删除的 **`../std/fs/fs.o`** / **`io.o`** / **`heap.o`**（F-03 纯 .x）；IO/堆由 **`lsp_io_std_heap_x.o`** 等 seed 桥提供。

## v2 完成

| 项 | 说明 |
|----|------|
| `verify-selfhost-stage2.sh` | Step 4 链接行移除 legacy fs/io/heap `.o` |
| `run-f06-runtime-std-o-cleanup-gate.sh` | 校验 stage2 脚本无 legacy 路径 |

## Gate

Honesty gate (2026-08-26): same as v1 — prefer `xlang_asm`, pin
`XLANG_LINK_XLANG`, hard-fail static + link_abi + bootstrap + stage2 +
boot contract. Soft `XLANG_F06_RUNTIME_CLEANUP_FAIL` retired. Report
`static=` / `link_abi=` / `bootstrap=` / `stage2=` / `contract=` /
`skip=`.

```bash
./tests/run-f06-runtime-std-o-cleanup-gate.sh
XLANG=./compiler/xlang_asm ./tests/run-f06-runtime-std-o-cleanup-gate.sh
```

## 复现

Same as **## Gate** (soft FAIL path retired; gate always hard).

## 下一项（终局）

- `runtime.c` 其余模块按需链 `.x` 产物 `.o`（随 F v2 迁移逐项 NULL / std_x）
