# 阶段 F-hash v2（std.hash 逻辑 .x 下沉）

> **F-hash v2**：SipHash-2-4 / FNV-1a64 / xxHash64 全量在 **`hash.x`**；**删除 `hash_glue.c`**；`hash.o` 纯 `.x` 编译（同 cache/schema）。

## 变更

| 项 | v1 | v2 |
|----|----|-----|
| 算法实现 | `hash_glue.c`（438 行） | **`hash.x`** |
| `hash.o` | `ld -r` glue + x | **纯 shux → hash.o** |
| 依赖 | libc malloc/free/strcmp/getenv | `extern` 同上 |

## 门禁

```bash
SHUX_F_HASH_V2_FAIL=1 ./tests/run-f-hash-v2-gate.sh
./tests/run-std-hash-hasher-trait-gate.sh
./tests/run-std-hash-xxhash-gate.sh
./tests/run-std-hash-default-strategy-gate.sh
SHUX_F_STD_DE_C_BATCH_FAIL=1 ./tests/run-f-std-de-c-batch-gate.sh
```

## 下一项

- **F-dynlib v2** / **F-http v2** 等 std 胶层继续下沉
