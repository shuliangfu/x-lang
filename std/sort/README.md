# std.sort — 排序

对标 **Zig** `std.sort`、**Rust** `slice::sort`。

## API

| API | 说明 |
|-----|------|
| `sort_i32` / `sort_u8` | 不稳定升序（qsort） |
| `sort_stable_i32` / `sort_stable_u8` | 稳定升序（归并） |
| `sort_i32_cmp` | 稳定排序 + 自定义比较器（usize fn ptr） |

## 比较器策略（STD-150）

| 场景 | API | 比较器 |
|------|-----|--------|
| 原始 i32 快路径 | `sort_i32` | 内建 |
| 稳定升序 | `sort_stable_i32` | 内建 |
| 自定义顺序 | `sort_i32_cmp` | `cmp_i32_desc_fn` / `cmp_i32_asc_fn` |
| key+payload | `sort_stable_by_key` | `cmp_key_i32_fn`（仅 `KeyTag.key`） |

```su
struct KeyTag { key: i32, tag: i32 }
sort_stable_by_key(&items[0], len);
```

RFC：`analysis/std-sort-stable-cmp-v1.md`（STD-060）· `analysis/std-sort-key-cmp-v1.md`（STD-150）

## Gate

```bash
./tests/run-std-sort-stable-cmp-gate.sh
./tests/run-std-sort-key-cmp-gate.sh
```
