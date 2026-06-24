# 阶段 E-04 v16（retire get_std_*_o_path → shux_rel_o_path_from_argv0）

> **E-04 v16**：删除 `runtime.c` 内 47 个重复的 **`get_std_*_o_path`** 静态函数（~790 行）；`invoke_cc` 路径收集与内部按需链入改调 **`shux_rel_o_path_from_argv0`**；`invoke_cc` fork/exec 主体仍留 runtime.c。

## v16 完成（✅）

| 变更 | 说明 |
|------|------|
| 删除 `get_std_*_o_path` | fs/process/string/…/win32 等 47 个静态路径解析 |
| 统一 `shux_rel_o_path_from_argv0` | invoke_cc 三处路径块 + invoke_cc 内 db_kv/db_arrow/socketio/win32 |

## 复现

```bash
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
make -C compiler src/runtime_link_abi.o src/runtime_driver_no_c.o
```

## 延后（E-04 v18+）

- `main.c` → crt0 / main.sx 全入口
