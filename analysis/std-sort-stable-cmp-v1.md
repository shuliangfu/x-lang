# STD-060：std.sort 稳定排序与自定义比较器 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`std/sort/sort.c`、STD-054（`usize` 函数指针惯例）

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4 |
| 2 | `tests/baseline/std-sort-stable-cmp.tsv` |
| 3 | `./tests/run-std-sort-stable-cmp-gate.sh` |

---

## 2. API

| API | 稳定性 | 说明 |
|-----|--------|------|
| `sort_i32` / `sort_u8` | 不稳定 | 既有 qsort 路径（兼容） |
| `sort_stable_i32` / `sort_stable_u8` | **稳定** | 归并排序，默认升序 |
| `sort_i32_cmp(ptr, len, cmp_fn)` | **稳定** | 自定义比较器 |
| `cmp_i32_desc_fn()` | — | 返回降序比较器 `usize` |

### 2.1 比较器 RFC（v1）

与 `std.test` 的 `bench_run(fn: usize)` 一致：

- `.sx` 侧比较器以 **`usize`** 承载 C 函数指针
- C 签名：`int32_t (*)(const void *a, const void *b)`，语义同 `qsort`
- v1 **仅 i32 元素**；泛型 / `elem_size` 参数留待后续

---

## 3. 金样

| case | 输入 | 期望 |
|------|------|------|
| `stable_dup` | keys `3,1,3,2` + seq `0,1,2,3` | 相等 key 的 seq 保持 `0` 在 `2` 前 |
| `cmp_desc` | `3,1,4,2` + 降序 cmp | `4,3,2,1` |

烟测：`tests/std-sort/stable_smoke_ok.c`、`stable_i32.sx`、`cmp_desc.sx`。

---

## 4. 门禁

```bash
./tests/run-std-sort-stable-cmp-gate.sh
```
