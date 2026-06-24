# 阶段 E-04 v3（runtime I/O ABI 薄壳）

> **E-04 v3**：自 `runtime.c` 拆出 **`runtime_io_abi.c`**，承载 POSIX 读/写文件原语；`runtime.c` 经 `#define read_file runtime_read_file_malloc` 调用。

## v3 完成（✅）

| 符号 | 说明 |
|------|------|
| `runtime_read_file_malloc` | 整文件读入堆缓冲（原 static read_file） |
| `shux_read_file_into_path` | ast_pool / pipeline 读文件前缀 |
| `shux_write_path_bytes` | fmt / 调试写文件 |

| 链接 | 说明 |
|------|------|
| `DRIVER_SEED_OBJS` | 含 `src/runtime_io_abi.o` |
| `OBJS_CORE`（shux-c） | 含 `src/runtime_io_abi.o`（供 ast_pool 符号） |
| B-strict | `ensure_runtime_io_abi_obj` |

## 复现

```bash
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
make -C compiler src/runtime_io_abi.o src/runtime_driver_no_c.o
```

## 延后（E-04 v4）

- 见 `analysis/phase-e-e04-v4.md`（v4 已拆 runtime_proc_abi.c）
