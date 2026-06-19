# STD-120 std.db 兼容层 v1

> 更新时间：2026-06-18  
> 状态：**可用** — deprecated 转发至 std.sqlite + gate

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 迁移说明 |
| 2 | `tests/baseline/std-db-compat-manifest.tsv` |
| 3 | `./tests/run-std-db-compat-gate.sh` |

---

## 2. 迁移说明

| 旧路径 | 新路径 |
|--------|--------|
| `import("std.db")` | `import("std.sqlite")`（推荐） |
| `std.db.open` | `std.sqlite.open` 或 `std.db.open`（转发） |

`std/db/mod.sx` 与 std.sqlite 共享 `std/sqlite/sqlite.o` C 实现；API 对齐。

检测废弃：`db_is_deprecated()` 恒返回 1。

---

## 3. Gate

```
shux: [SHUX_STD120_DB_COMPAT] status=ok su=1 skip=0
std-db-compat gate OK
```

向量：`tests/baseline/std-db-compat-vectors.tsv`。
