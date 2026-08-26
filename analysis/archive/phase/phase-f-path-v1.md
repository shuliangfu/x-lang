# 阶段 F-path v1（std.path 去 C）

> **F-path v1**：删除 **`path.c`**；`path_sep_c` 内联至 **`mod.x`**（`#[cfg(target_os = "windows")]`）；`path.o` 由 `mod.x` 编译。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| `path_sep_c` | `path.c` + extern | `mod.x` cfg 内联 |
| `path.o` | `cc -c path.c` | `xlang -backend asm mod.x` |
| 存量 | std 91 `.c` | std **90** `.c` |

## 已删除（须保持 absent）

| 文件 | 说明 |
|------|------|
| ~~`std/path/path.c`~~ | v1 删除（仅 16 行平台分隔符） |

## 保留

| 文件 | 原因 |
|------|------|
| `compiler/include/xlang_std_abi/path_abi.h` | codegen ABI（F-ZC 迁出后权威） |
| `std/path/mod.x` | 全量 path API |

## 构建

```bash
./xbuild  # was: make -C compiler ../std/path/path.o
```

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_PATH_V1_FAIL` retired. Delegates STD-140 path-extreme + STD-021／022 path-fs-windows hard.

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-path-v1-gate.sh
./tests/run-std-path-extreme-gate.sh
./tests/run-std-path-fs-windows-gate.sh
```

## 下一项

- **F-path v1 ✅**：`path.c` 删除；见 `phase-f-path-v1.md`
- 刷新 F-09 baseline：`XLANG_NO_HANDWRITTEN_C_UPDATE=1 ./tests/run-no-handwritten-c-gate.sh`
