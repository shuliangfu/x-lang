# 阶段 E-04 v33（C import 加载 + 顶层 import 检测迁入独立 TU / ABI）

> **E-04 v33**：自 `runtime.c` 将 **C 前端 import 递归加载** 拆至 **`runtime_c_import.c/h`**（仅 OBJS_CORE）；**顶层 import 检测** 与 **dep 路径去重** 迁入 driver/pipeline ABI。

## v33 完成（✅）

| 符号 | TU | 说明 |
|------|-----|------|
| `shu_c_resolve_and_load_imports` | runtime_c_import.c | C 前端 resolve+load+typeck import 链 |
| `shu_lsp_resolve_and_load_imports` | runtime_c_import.c | LSP import 加载（原 runtime.c） |
| `driver_source_has_top_level_import` | runtime_driver_abi.c | 预处理后源码顶层 import 扫描 |
| `driver_source_has_top_level_import_path` | runtime_driver_abi.c | compile.sx asm 分派降级探测 |
| `shux_merge_deps_path_already_out` | runtime_pipeline_abi.c | asm dep layout merge 去重 |

## 仍留 runtime.c

- `run_compiler_c` / `run_compiler_sx_path` 主体
- `load_direct_imports_for_asm_layout` 等 asm layout 辅助
- driver 诊断已迁至 v34（`runtime_driver_diagnostic.c`）

## 复现

```bash
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
make -C compiler src/runtime_c_import.o src/runtime_pipeline_abi.o src/runtime_driver_abi.o src/runtime_driver_no_c.o
wc -l compiler/src/runtime.c compiler/src/runtime_c_import.c
```

## 延后（E-04 v34+）

- `run_compiler_c` 继续拆分（v34 已完成 driver_diagnostic）
- Cygwin 专用 crt0（若需与 MinGW 分轨）
