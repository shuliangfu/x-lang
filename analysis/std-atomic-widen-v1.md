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

| 宽度 | 公开 API（*T 重载） |
|------|----------|
| **i16** | `load` / `store` / `compare_exchange` / `fetch_add`（`*i16`） |
| **u16** | `load` / `store` / `compare_exchange` / `fetch_add`（`*u16`） |
| **i64** | `compare_exchange` / `fetch_sub`（`*i64`，补齐） |
| **u64** | `fetch_add` / `fetch_sub` / `compare_exchange`（`*u64`，补齐） |

---

## 3. Gate

```bash
./tests/run-std-atomic-widen-gate.sh
```

烟测：`tests/atomic/widen_16_64.sx`

报告：`shux: [SHUX_STD146_ATOMIC_WIDEN]`
