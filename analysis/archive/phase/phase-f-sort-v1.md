# 阶段 F-sort v1（std.sort 去 C）

> **F-sort v1**：删除 **`sort.c`**；快排/稳定归并全在 **`sort.x`**；**零胶层 C**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `sort.c`（qsort + malloc） | `sort.x`（快排 + 归并 + libc malloc/free extern） |
| `sort.o` | `cc -c sort.c` | `shux -backend asm sort.x` |
| 比较器 | C 函数指针地址 | v1 **内建 cmp id**（`usize` 1/2/3；与 `cmp_*_fn()` 配套） |
| 存量 | std 89 `.c` | std **88** `.c` |

## 已删除（须保持 absent）

| 文件 | 说明 |
|------|------|
| ~~`std/sort/sort.c`~~ | v1 删除 |

## 构建

```bash
make -C compiler ../std/sort/sort.o
```

## 门禁

```bash
SHUX_F_SORT_V1_FAIL=1 ./tests/run-f-sort-v1-gate.sh
./tests/run-std-sort-stable-cmp-gate.sh
./tests/run-std-sort-key-cmp-gate.sh
```

## 下一项

- **F-base64 v1** / **F-string v1** 等其它 std 去 C
- **F-process v2**：getcwd/self_exe 缓存迁 `.x`

