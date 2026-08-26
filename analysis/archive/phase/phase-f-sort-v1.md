# 阶段 F-sort v1（std.sort 去 C）

> **F-sort v1**：删除 **`sort.c`**；快排/稳定归并全在 **`sort.x`**；**零胶层 C**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `sort.c`（qsort + malloc） | `sort.x`（快排 + 归并 + libc malloc/free extern） |
| `sort.o` | `cc -c sort.c` | `xlang -backend asm sort.x` |
| 比较器 | C 函数指针地址 | v1 **内建 cmp id**（`usize` 1/2/3；与 `cmp_*_fn()` 配套） |
| 存量 | std 89 `.c` | std **88** `.c` |

## 已删除（须保持 absent）

| 文件 | 说明 |
|------|------|
| ~~`std/sort/sort.c`~~ | v1 删除 |

## 构建

```bash
./xbuild  # was: make -C compiler ../std/sort/sort.o
```

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_SORT_V1_FAIL` retired. Delegates STD-060 sort-stable-cmp + STD-150 sort-key-cmp hard (full, not manifest-only).

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-sort-v1-gate.sh
./tests/run-std-sort-stable-cmp-gate.sh
./tests/run-std-sort-key-cmp-gate.sh
```

## 下一项

- **F-base64 v1** / **F-string v1** 等其它 std 去 C（多已硬绿）
