# 阶段 F-tar v2（std.tar 逻辑 .sx 下沉）

> **F-tar v2**：UStar/Pax 读写/遍历/烟测全量迁入 **`tar.sx`**；**纯 .sx**（无 OS/pthread/malloc；仅 extern memcpy/memcmp/memset）。

## 变更

| 项 | v1 | v2 |
|----|----|-----|
| UStar/Pax 实现 | `tar_glue.c`（~478 行） | **`tar.sx`** |
| `tar.o` | `ld -r` glue + sx | **仅 sx（`tar_main.o`）** |
| mod.sx | extern tar_*_c | **不变** |

## 门禁

```bash
SHUX_F_TAR_V2_FAIL=1 ./tests/run-f-tar-v2-gate.sh
./tests/run-std-tar-ustar-gate.sh
./tests/run-std-tar-extended-gate.sh
SHUX_F_STD_DE_C_BATCH_FAIL=1 ./tests/run-f-std-de-c-batch-gate.sh
SHUX_STD_C_INVENTORY_FAIL=1 ./tests/run-std-c-inventory-gate.sh
```

## 下一项

- 继续阶段 F std 去 C（http / async / channel 等胶层）
