# STD-067：std.db.sqlite next_row 列值游标 v1

> 更新时间：2026-08-28  
> 状态：**可用**  
> 前置：STD-066 `std-sqlite-query-rows-v1.md`  
> 关联：STD-010 D2 查询执行、EXC-003

---

## 1. 目标

在 STD-066 行计数基础上实现 **列值游标原型**：`begin` / `next_row` / `col` / `end`（C 侧仍为 `db_query_begin_c`／`db_next_row_c`／`db_row_col_i32_c`／`db_query_end_c`）。

验收：`tests/run-std-sqlite-next-row-gate.sh` 绿。

---

## 2. next_row API（v1）

| API | v1 行为 |
|-----|---------|
| `begin` | `sqlite3_prepare_v2`，返回 `DbRowCursor`（C：`db_query_begin_c`） |
| `next_row` | `sqlite3_step`：`DB_ROW_OK`(1) 有行，`DB_ROW_DONE`(0) 结束 |
| `col` | 读当前行第 `col` 列整型值（C：`db_row_col_i32_c`） |
| `end` | `sqlite3_finalize` 释放游标（C：`db_query_end_c`） |

烟测入口：`db_sqlite_next_row_smoke_c`（C）、`next_row_roundtrip.x`（.x）。

---

## 3. 金样向量

| step_id | 操作 | 期望 |
|---------|------|------|
| `cursor_row1` | `next_row` + `col(0)` | 值 **1** |
| `cursor_row2` | 第二次 `next_row` + `col(0)` | 值 **2** |
| `cursor_done` | 第三次 `next_row` | `DB_ROW_DONE` |

向量表：`tests/baseline/std-sqlite-next-row-vectors.tsv`。

---

## Gate

Honesty soft→硬绿（2026-08-28）：prefer product `xlang_asm`；钉 `XLANG_LINK_XLANG`；显式坏／缺 native 硬 die；host-C 仅 prebuilt `std/db/sqlite/sqlite.o`＝obs（拒 soft `ensure_std_c_o`／`std_sqlite_build_o`／auto-make／prefer-c／SKIP→OK）；check＝obs（暂停）；tip 产品 `-o` SEGV／UNDEF＝obs（产品另案）。报告 `run=`／`obs=`／`skip=`（退役 `cursor_c=`／`cursor_x=`）。API 权威对齐 `begin`／`next_row`／`col`／`end`（拒化石 `query_begin`／`row_col_i32`／`query_end`）。

```bash
./tests/run-std-sqlite-next-row-gate.sh
```

```
xlang: [XLANG_STD067_DB_CURSOR] status=ok run=N obs=M skip=K
```

PLATFORM: SHARED archaeology — Ubuntu gold still required.

---

## 5. 联动

- manifest：`tests/baseline/std-sqlite-next-row.tsv`
- 父门禁：STD-066 query-rows（本波仅文件存在；soft residual 另案）
- CI：`tests/run-portable-suite.sh`

---

## 6. 非目标（v2）

- 文本列见 STD-068 `col_text`
- BLOB 列见 STD-069 `col_blob`
- 预编译语句缓存／连接池
