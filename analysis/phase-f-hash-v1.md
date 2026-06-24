# 阶段 F-hash v1（std.hash 去 C）

> **F-hash v1**：删除 **`hash.c`**；模块锚点在 **`hash.sx`**；v2 后算法全在 **`hash.sx`**（已删 `hash_glue.c`）。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `hash.c`（440 行） | `hash.sx`（v2 纯 .sx） |
| `hash.o` | `cc -c` | 纯 shux（v2） |

## 门禁

```bash
SHUX_F_HASH_V1_FAIL=1 ./tests/run-f-hash-v1-gate.sh
./tests/run-std-hash-hasher-trait-gate.sh
./tests/run-std-hash-xxhash-gate.sh
./tests/run-std-hash-default-strategy-gate.sh
```

## 下一项

- **F-dynlib v1** ✅ / **F-backtrace v1** ✅
