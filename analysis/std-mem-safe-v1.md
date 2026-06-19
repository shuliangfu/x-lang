# STD-144：std.mem 安全边界封装 v1

> 状态：**定版（v1）**  
> 关联：`STD-018` 职责边界、`std.bytes` / `std.io` Buffer 桥接

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-144 | 有界 `copy`/`set`/`compare` + `buffer_from` + 边界烟测 + gate |

在 std 层提供**显式容量检查**，避免 n 越界静默写；不改变 STD-018 core/std 分轨。

---

## 2. 有界 API

| API | 说明 |
|-----|------|
| `copy_bounded(dst, dst_cap, src, n)` | n>cap 返回 -1；否则 copy 并返回 n |
| `set_bounded(ptr, cap, byte, n)` | n>cap 返回 -1；否则 set 并返回 n |
| `compare_bounded(a, a_len, b, b_len)` | 先比公共前缀，再按长度决胜 |
| `buffer_from(ptr, len)` | 构造 `Buffer { ptr, len, handle=0 }` |

---

## 3. Gate

```bash
./tests/run-std-mem-safe-gate.sh
```

烟测：`tests/mem/mem_safe_boundary.sx`

报告：`shux: [SHUX_STD144_MEM_SAFE]`
