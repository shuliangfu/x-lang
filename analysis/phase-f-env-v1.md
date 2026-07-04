# 阶段 F-env v1（std.env 去 C）

> **F-env v1**：删除 **`env.c`**；KV 解析/烟测/args_iter 在 **`env.x`**；OS getenv/setenv/iter 在 **`compiler/src/asm/runtime_env_os.c`**（F-ZC）。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `env.c`（424 行） | `env.x` + `runtime_env_os.c` |
| `env.o` | `cc -c env.c` | 纯 `shux -backend asm env.x` |
| OS 胶层 | `std/env/env_os_glue.c` | `compiler/runtime_env_os.o`（与 env.o 同链） |
| 存量 | std 83 `.c` | std **56** `.c`（env_os_glue 已迁出 std） |

## 门禁

```bash
SHUX_F_ENV_V1_FAIL=1 ./tests/run-f-env-v1-gate.sh
./tests/run-std-env-iter-gate.sh
./tests/run-std-env-platform-encoding-gate.sh
```

## 下一项

- **F-log v1**
