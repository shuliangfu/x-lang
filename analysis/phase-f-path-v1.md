# 阶段 F-path v1（std.path 去 C）

> **F-path v1**：删除 **`path.c`**；`path_sep_c` 内联至 **`mod.sx`**（`#[cfg(target_os = "windows")]`）；`path.o` 由 `mod.sx` 编译。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| `path_sep_c` | `path.c` + extern | `mod.sx` cfg 内联 |
| `path.o` | `cc -c path.c` | `shux -backend asm mod.sx` |
| 存量 | std 91 `.c` | std **90** `.c` |

## 已删除（须保持 absent）

| 文件 | 说明 |
|------|------|
| ~~`std/path/path.c`~~ | v1 删除（仅 16 行平台分隔符） |

## 保留

| 文件 | 原因 |
|------|------|
| `std/path/path_abi.h` | codegen 生成 C 时 `#include`（path_empty_len 宏） |
| `std/path/mod.sx` | 全量 path API |

## 构建

```bash
make -C compiler ../std/path/path.o
```

## 门禁

```bash
SHUX_F_PATH_V1_FAIL=1 ./tests/run-f-path-v1-gate.sh
./tests/run-std-path-extreme-gate.sh
./tests/run-std-path-fs-windows-gate.sh
```

## 下一项

- **F-path v1 ✅**：`path.c` 删除；见 `phase-f-path-v1.md`
- **F-process v1**：`process.c` → `.sx` + OS FFI 胶层
- 刷新 F-09 baseline：`SHUX_NO_HANDWRITTEN_C_UPDATE=1 ./tests/run-no-handwritten-c-gate.sh`
