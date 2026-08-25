# STD-150：std.sort 复杂 key 比较器策略 v1

> 状态：**定版（v1）** · soft→硬绿 honesty（2026-08-25）  
> 关联：`STD-060` 稳定排序与 `usize` 比较器

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-150 | `KeyTag` + `stable_by_key` + `cmp_key_fn` + 策略表 + gate |

v1 复杂 key 采用 **key+tag 对**；比较器仅读 `key`，稳定排序保留相等 key 的 `tag` 顺序。

Fossil→product API rename (gate/TSV/README aligned):
`sort_stable_by_key`→`stable_by_key`, `cmp_key_i32_fn`→`cmp_key_fn`,
`cmp_i32_asc_fn`→`cmp_asc_fn`, `sort_stable_key_tag_c`→`stable_key_tag`.

---

## 2. 比较器策略表

| 场景 | API | 比较器 |
|------|-----|--------|
| 原始 i32 升序（快） | `sort` (`*i32`) | 内建升序 |
| 稳定升序 | `stable` (`*i32`) | 内建升序 |
| 自定义全元素顺序 | `cmp` | `cmp_desc_fn` / `cmp_asc_fn` |
| **key+payload** | `stable_by_key` | `cmp_key_fn`（仅 key） |

函数指针一律 **usize** 传入 C（与 STD-060 一致）。

---

## 3. KeyTag

```su
struct KeyTag { key: i32, tag: i32 }
stable_by_key(&items[0], len);
```

---

## 4. Gate

```bash
./tests/run-std-sort-key-cmp-gate.sh
```

Acceptance: prefer `xlang_asm` + pin `XLANG_LINK_XLANG`; `check` observational
(paused 2026-08-05); `key_stable.x` runnable exit 0 hard-fail (no soft SKIP when
no native xlang). C smoke is observational host-C archaeology only.
Report: `xlang: [XLANG_STD150_SORT_KEY_CMP] status=ok check=N run=1 skip=0`
