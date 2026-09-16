# std.sort

排序：不稳定快排 + 稳定归并；`stable_by_key` 按 KeyTag.key 稳定排序；自定义比较器（usize 内建 id）。

## API

| API | 说明 |
|-----|------|
| `sort` (`*i32` / `*u8`) | 不稳定升序 |
| `stable` (`*i32` / `*u8`) | 稳定升序 |
| `cmp` | 稳定排序 + `cmp_desc_fn` / `cmp_asc_fn` |
| `stable_by_key` | KeyTag 按 key 稳定排序（`cmp_key_fn`） |

## F-sort v1（去 C）

- **`sort.c` 已删除**；实现见 `sort.x`（零胶层 C）
- 构建：`make -C compiler ../std/sort/sort.o`
- 门禁：`./tests/run-f-sort-v1-gate.sh`

## Gate

```bash
./tests/run-std-sort-stable-cmp-gate.sh
./tests/run-std-sort-key-cmp-gate.sh
XLANG_F_SORT_V1_FAIL=1 ./tests/run-f-sort-v1-gate.sh
```
