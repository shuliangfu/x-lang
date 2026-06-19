# STD-146：std.atomic 16/64 位扩展 v1

> 状态：**定版（v1）**  
> 关联：`STD-046` ordering/fence、`tests/atomic/main.sx` 基础回归

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-146 | i16/u16 load/store/CAS/fetch_add + i64/u64 CAS/fetch_sub/fetch_add + gate |

v1 仍默认 **seq_cst**；未新增带 Ordering 参数的重载。

---

## 2. 16/64 API

| 宽度 | 新增 API |
|------|----------|
| **i16** | `load_i16` / `store_i16` / `compare_exchange_i16` / `fetch_add_i16` |
| **u16** | `load_u16` / `store_u16` / `compare_exchange_u16` / `fetch_add_u16` |
| **i64** | `compare_exchange_i64` / `fetch_sub_i64`（补齐） |
| **u64** | `fetch_add_u64` / `fetch_sub_u64` / `compare_exchange_u64`（补齐） |

---

## 3. Gate

```bash
./tests/run-std-atomic-widen-gate.sh
```

烟测：`tests/atomic/widen_16_64.sx`

报告：`shux: [SHUX_STD146_ATOMIC_WIDEN]`
