# 阶段 F-06 v2（Stage2 验证脚本 legacy std .o 清场）

> **F-06 v2**：`verify-selfhost-stage2.sh` 不再链接已删除的 **`../std/fs/fs.o`** / **`io.o`** / **`heap.o`**（F-03 纯 .sx）；IO/堆由 **`lsp_io_std_heap_sx.o`** 等 seed 桥提供。

## v2 完成

| 项 | 说明 |
|----|------|
| `verify-selfhost-stage2.sh` | Step 4 链接行移除 legacy fs/io/heap `.o` |
| `run-f06-runtime-std-o-cleanup-gate.sh` | 校验 stage2 脚本无 legacy 路径 |

## 复现

```bash
SHUX_F06_RUNTIME_CLEANUP_FAIL=1 ./tests/run-f06-runtime-std-o-cleanup-gate.sh
```

## 下一项（终局）

- `runtime.c` 其余模块按需链 `.sx` 产物 `.o`（随 F v2 迁移逐项 NULL / std_sx）
