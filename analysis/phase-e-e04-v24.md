# 阶段 E-04 v24（import 路径解析迁入 runtime_pipeline_abi）

> **E-04 v24**：自 `runtime.c` 拆出 **`runtime_pipeline_abi.c/h`**，承载 import 路径到 `.x` 文件路径的解析；`load_one_import` / dep 预读仍留 runtime.c。

## v24 完成（✅）

| 符号 | 说明 |
|------|------|
| `shux_import_path_to_file_path` | 逻辑 import → `lib_root/.../*.x` |
| `shux_get_entry_dir` | 入口 `.x` 所在目录 |
| `shux_import_path_is_file_path` | 是否为文件路径 import |
| `shux_resolve_file_import_path` | 相对/绝对路径 → 可读 `.x` |
| `shux_resolve_import_file_path_multi` | `-L` + entry_dir 多规则 resolve |

## 复现

```bash
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
make -C compiler src/runtime_pipeline_abi.o src/runtime_driver_no_c.o
```

## 延后（E-04 v27+）

- `load_one_import` / `run_compiler_c` 主体继续拆分
- Cygwin 专用 crt0（若需与 MinGW 分轨）
