# STD-066：std.db query_rows 行计数原型 v1

> 更新时间：2026-08-28  
> 状态：**定版（v1）＋ honesty Gate**  
> 前置：STD-065 `std-sqlite-exec-deep-v1.md`  
> 关联：STD-010 D2 查询执行、EXC-003、STD-067 next_row

---

## 1. 目标

在 STD-065 事务 exec 基础上实现 **行计数原型**：`sqlite3_exec` 回调计数，返回 SELECT 匹配行数。

产品导出权威是 **`rows`**（化石名 `query_rows` 已退役；C 符号仍 `db_query_rows_c`）。非游标句柄；列值迭代见 STD-067。

验收：`tests/run-std-sqlite-query-rows-gate.sh` 绿；`min_query_apis=1`。

---

## 2. query_rows API（v1）

| API | v1 行为 |
|-----|---------|
| `rows` | 执行 SELECT，返回**行数**（≥0）；失败返回 `DB_ERR_*` |

非游标句柄；列值迭代留待 STD-067 `begin`／`next_row`／`col`／`end`。

烟测入口：`db_sqlite_query_rows_smoke_c`（C）、`query_rows_roundtrip.x`（.x，调用 `sqlite.rows`）。

---

## 3. 金样向量

| step_id | SQL | 期望行数 |
|---------|-----|----------|
| `rows_all` | `SELECT k FROM t;` | 2 |
| `rows_filter` | `SELECT k FROM t WHERE k=1;` | 1 |

向量表：`tests/baseline/std-sqlite-query-rows-vectors.tsv`。

---

## Gate

Honesty soft→硬绿（2026-08-28）：prefer product `xlang_asm`；钉 `XLANG_LINK_XLANG`；显式坏／缺 native 硬 die；host-C 仅 prebuilt `std/db/sqlite/sqlite.o`＝obs（拒 soft `ensure_std_c_o`／`std_sqlite_build_o`／auto-make／prefer-c／SKIP→OK）；check＝obs（暂停）；tip 产品 `-o` SEGV／UNDEF＝obs（产品另案）。报告 `run=`／`obs=`／`skip=`（退役 `rows_c=`／`rows_x=`）。API 权威对齐 `rows`（拒化石导出名 `query_rows`）。

```bash
./tests/run-std-sqlite-query-rows-gate.sh
```

```
xlang: [XLANG_STD066_DB_ROWS] status=ok run=N obs=M skip=K
```

PLATFORM: SHARED archaeology — Ubuntu gold still required.

---

## 5. 联动

- manifest：`tests/baseline/std-sqlite-query-rows.tsv`
- 父门禁：STD-065 exec-deep（本波仅文件存在）
- 子门禁：STD-067 next_row／STD-068 col_text／STD-069 col_blob
- CI：`tests/run-portable-suite.sh`

---

## 6. 非目标（v2）

- 列值游标见 STD-067 `next_row`
- 文本列见 STD-068 `col_text`
- BLOB 列见 STD-069 `col_blob`
- 预编译语句缓存／连接池
