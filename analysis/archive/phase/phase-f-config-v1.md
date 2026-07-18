# 阶段 F-config v1（std.config 去 C）

> **F-config v1**：删除 **`config.c`**；锚点 **`config.x`**；TOML/YAML/ENV 在 **`config_glue.c`**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `config.c`（1070 行） | `config.x` + `config_glue.c` |
| `config.o` | `cc -c` | `ld -r` 合并 |

## 门禁

```bash
SHUX_F_CONFIG_V1_FAIL=1 ./tests/run-f-config-v1-gate.sh
./tests/run-std-config-gate.sh
./tests/run-std-config-yaml-gate.sh
```

## 下一项

- **F-datetime v1** ✅ / **F-elf v1** ✅
