# STD-154：std.db.sqlite 文档与示例统一 v1

> 更新时间：2026-06-19  
> 状态：**定版（v1）**  
> 关联：STD-120 `std.db` 门面、STD-057 SQLite3 后端

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-154 | `docs/07` 主表收录 `std.db.sqlite`；stub 构建说明；推荐 `import("std.db.sqlite")` |

---

## 2. docs/07 必含关键字

| 关键字 | 含义 |
|--------|------|
| `std.db.sqlite` | 主模块名（§一 已完善表） |
| `prepare_cached` | STD-070 stmt 缓存 |
| `pool_acquire` | STD-084 连接池 |
| `DB_NOT_IMPL` | stub 回退错误码 |
| `sqlite-o-stub` | 无 libsqlite3 构建目标 |
| `run-std-sqlite-gate.sh` | 主 gate 入口 |

---

## 3. 禁止项

- `docs/07` **不得**将 `std.db.sqlite` 仅列于「预研/占位」且无 §一 主表条目
- 用户文档不得保留已删除的 `import("std.sqlite")` 兼容层说明

---

## 4. Gate

```bash
./tests/run-std-sqlite-docs-sync-gate.sh
```

manifest：`tests/baseline/std-sqlite-docs-sync-manifest.tsv`

报告：`shux: [SHUX_STD154_SQLITE_DOCS]`

---

## 5. 参考

- 模块 README：`std/db/sqlite/README.md`
- 门面：`std/db/README.md`
- 后端 RFC：`analysis/std-sqlite-v1.md`
