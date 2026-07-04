# 阶段 E-04 v26（driver_dep_* 槽位迁入 runtime_pipeline_abi）

> **E-04 v26**：自 `runtime.c` 将 pipeline dep 全局槽 **`driver_dep_*`** 迁入 **`runtime_pipeline_abi.c/h`**；`driver_typeck_dep_sidecar_clear` 仍留 runtime.c 作 typeck 侧车钩子。

## v26 完成（✅）

| 符号 | 说明 |
|------|------|
| `driver_dep_seeded_get/set` | dep 槽 seeded 标志 |
| `driver_dep_seed_slots` / `driver_dep_publish_slot` | C 侧预填 dep |
| `driver_dep_slot_for_path` | 按 import 路径查槽 |
| `driver_dep_seeded_clear_all` | 清槽 + 调 typeck 侧车 |
| `driver_dep_arena_buf` / `driver_dep_module_buf` | pipeline.x getter |
| `typeck_driver_dep_*` | typeck.x 转发 |
| `SHUX_DRIVER_DEP_SLOT_MAX` | 槽数量常量 32 |

## 复现

```bash
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
make -C compiler src/runtime_pipeline_abi.o src/runtime_driver_no_c.o
```

## 延后（E-04 v27+）

- `load_one_import` / `run_compiler_c` 主体继续拆分
- Cygwin 专用 crt0（若需与 MinGW 分轨）
