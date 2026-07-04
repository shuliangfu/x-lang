# 阶段 F-tar v1（std.tar 去 C）

> **F-tar v1**：删除 **`tar.c`**；模块锚点在 **`tar.x`**；UStar/Pax 在 **`tar_glue.c`**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `tar.c`（479 行） | `tar.x` + `tar_glue.c` |
| `tar.o` | `cc -c` | `ld -r` 合并 |

## 门禁

```bash
SHUX_F_TAR_V1_FAIL=1 ./tests/run-f-tar-v1-gate.sh
./tests/run-std-tar-ustar-gate.sh
./tests/run-std-tar-extended-gate.sh
```

## 下一项

- **F-channel v1** ✅ / **F-atomic v1** ✅
