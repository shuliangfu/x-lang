# STD-060：std.sort 稳定排序与自定义比较器 v1

> 更新时间：2026-08-25（honesty：fossil→product）  
> 状态：**定版（v1）+ 产品诚实化**  
> 关联：`std/sort/sort.x`、STD-054（`usize` 函数指针惯例）、STD-150（key cmp）

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
| `sort` (`*i32` / `*u8`) | 不稳定 | 既有 qsort 路径（兼容） |
| `stable` (`*i32` / `*u8`) | **稳定** | 归并排序，默认升序（原 `sort_stable_i32` / `sort_stable_u8`） |
| `cmp(ptr, len, cmp_fn)` | **稳定** | 自定义比较器（原 `sort_i32_cmp`） |
| `cmp_desc_fn()` / `cmp_asc_fn()` | — | 返回降序/升序比较器 `usize`（原 `cmp_i32_desc_fn`） |

### 2.1 比较器 RFC（v1）

与 `std.test` 的 `bench_run(fn: usize)` 一致：

- `.x` 侧比较器以 **`usize`** 承载 C 函数指针
- C 签名：`int32_t (*)(const void *a, const void *b)`，语义同 `qsort`
- v1 **仅 i32 元素**；泛型 / `elem_size` 参数留待后续

---

## 3. 金样

| case | 输入 | 期望 |
|------|------|------|
| `stable_dup` | keys `3,1,3,2` + seq `0,1,2,3` | 相等 key 的 seq 保持 `0` 在 `2` 前 |
| `cmp_desc` | `3,1,4,2` + 降序 cmp | `4,3,2,1` |

烟测：`tests/std-sort/stable_smoke_ok.c`（C archaeology）、`stable_i32.x`、`cmp_desc.x`（产品硬绿）。

---

## 4. 门禁

```bash
./tests/run-std-sort-stable-cmp-gate.sh
```

**Acceptance (2026-08-25 honesty)**：

- Prefer `xlang_asm`；`XLANG_LINK_XLANG` pin；`check` observational（自举期暂停闸门）
- `stable_i32.x` + `cmp_desc.x` exit 0 **hard-fail**（有 native xlang 时禁止 soft SKIP）
- C smoke observational only
- Manifest anchors = product names (`stable` / `cmp` / `cmp_desc_fn`)
