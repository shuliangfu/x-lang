# 阶段 F-process v1（std.process 去 C）

> **F-process v1**：删除 **`process.c`**；**`process.x`** + **`process_os_glue.c`** + **`runtime_process_argv.c`**（compiler）；`ld -r` 合并为 **`process.o`**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `process.c`（574 行 monolith） | `process.x`（args）+ os 胶层 + runtime argv |
| `process.o` | `cc -c process.c` | `ld -r(os_glue + process.x)` + `runtime_process_argv.o` 链入 |
| argc/argv | process.c 全局 | `runtime_process_argv.c` 全局 + `process.x` 薄封装 |
| OS | 同文件 | `process_os_glue.c`（getenv/spawn/getcwd 等） |
| 存量 | std 88 `.c` | std **89** `.c`（+5 胶层，-4 monolith） |

## 已删除（须保持 absent）

| 文件 | 说明 |
|------|------|
| ~~`std/process/process.c`~~ | v1 删除 |
| ~~`std/process/process_arg_glue.c`~~ | F-ZC 迁入 `compiler/src/asm/runtime_process_argv.c` |

## 构建

```bash
make -C compiler ../std/process/process.o
```

## 门禁

```bash
SHUX_F_PROCESS_V1_FAIL=1 ./tests/run-f-process-v1-gate.sh
./tests/run-std-process-xplat-gate.sh
```

## 下一项

- **F-process v2**：getcwd/self_exe 缓存迁 `.x`
- **F-base64 v1** 等其它 std 去 C
