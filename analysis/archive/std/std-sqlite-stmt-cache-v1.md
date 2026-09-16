# STD-070：std.db.sqlite 预编译 bind + stmt 缓存 v1

> 更新时间：2026-06-18  
> 状态：**可用**  
> 前置：STD-067 `std-sqlite-next-row-v1.md`  
> 关联：STD-010 D2 查询执行、EXC-003

---

## 1. 目标

在列值游标基础上实现 **预编译语句 + 参数绑定 + 连接级 stmt 缓存**。

验收：`tests/run-std-sqlite-stmt-cache-gate.sh` 绿；报告 `run=`／`obs=`／`skip=`（host-C／tip 残＝obs）。

---

## 2. stmt API（v1）

产品门面（`std/db/sqlite/mod.x`；化石名 `stmt_*` 已收敛为 overload）：

| API | v1 行为 |
|-----|---------|
| `prepare` | `sqlite3_prepare_v2`，独立 finalize |
| `prepare_cached` | 同连接同 SQL 复用 stmt；`close` 时自动释放 |
| `bind`（i32／text overload） | `sqlite3_bind_*`（idx 从 1 起） |
| `step` | 同 `next_row`：1=有行，0=完成 |
| `reset` | 重置以便再次 bind |
| `finalize` | finalize 并从缓存移除 |
| `cache_clear` | 清空连接缓存 |
| `col`／`col_text` | 读当前行列值 |

烟测：`db_sqlite_stmt_bind_smoke_c`（C）、`stmt_bind_roundtrip.x`（.x）。

---

## 3. 金样向量

| step_id | 操作 | 期望 |
|---------|------|------|
| `bind_insert` | INSERT(?,?) 两次 bind+step | 两行写入 |
| `cache_hit` | 两次 `prepare_cached` 同 SQL | 同一 handle |
| `bind_select` | SELECT WHERE k=? bind 10/20 | 读 alice / bob |

向量表：`tests/baseline/std-sqlite-stmt-cache-vectors.tsv`。

---

## Gate

Honesty soft→硬绿（2026-08-28）：prefer product `xlang_asm`；钉 `XLANG_LINK_XLANG`；显式坏／缺 native 硬 die；host-C 仅 prebuilt `sqlite.o`＝obs（拒 soft `std_sqlite_build_o`／ensure／auto-make）；check＝obs（暂停）；tip 产品 `-o` SEGV／UNDEF＝obs（产品另案）。无 `libsqlite3`／缺 prebuilt＝obs（**不是** soft SKIP→OK）。报告 `run=`／`obs=`／`skip=`（退役 `bind_c=`／`bind_x=`）。

```bash
./tests/run-std-sqlite-stmt-cache-gate.sh
```

```
xlang: [XLANG_STD070_DB_STMT] status=ok run=N obs=M skip=K
```

PLATFORM: SHARED archaeology — Ubuntu gold still required.

---

## 5. 非目标（v2）

- 连接池
- blob 参数绑定
- LRU 精细驱逐策略
- 跨线程 stmt 共享
