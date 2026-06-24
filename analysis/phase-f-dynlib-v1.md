# 阶段 F-dynlib v1（std.dynlib 去 C）

> **F-dynlib v1**：删除 **`dynlib.c`**；模块锚点在 **`dynlib.sx`**；dlopen/LoadLibrary 在 **`dynlib_glue.c`**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `dynlib.c`（173 行） | `dynlib.sx` + `dynlib_glue.c` |
| `dynlib.o` | `cc -c` | `ld -r` 合并 |

## 门禁

```bash
SHUX_F_DYNLIB_V1_FAIL=1 ./tests/run-f-dynlib-v1-gate.sh
./tests/run-std-dynlib-windows-gate.sh
./tests/run-std-dynlib-last-error-gate.sh
```

## 下一项

- **F-backtrace v1** ✅ / **F-http v1**
