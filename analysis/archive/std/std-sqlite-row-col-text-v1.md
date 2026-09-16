# STD-068：std.db.sqlite col_text 文本列 v1

> 更新时间：2026-08-28  
> 状态：**可用**  
> 前置：STD-067 `std-sqlite-next-row-v1.md`  
> 关联：STD-010 D2 查询执行、EXC-003

---

## 1. 目标

在 STD-067 列值游标基础上实现 **文本列读取原型**：`col_text` 将当前行 `col` 列 UTF-8 文本拷贝到调用方缓冲（C：`db_row_col_text_c`）。

验收：`tests/run-std-sqlite-row-col-text-gate.sh` 绿。

---

## 2. col_text API（v1）

| API | v1 行为 |
|-----|---------|
| `col_text` | `sqlite3_column_text` 拷贝到 `out`；成功返回字节长度（不含 NUL） |
| NULL 列 | 写入空串，返回 **0** |
| 缓冲不足 | `DB_ERR_EXEC`（须容纳 NUL 终止符） |

烟测入口：`db_sqlite_row_col_text_smoke_c`（C）、`row_col_text_roundtrip.x`（.x）。

---

## 3. 金样向量

| step_id | 操作 | 期望 |
|---------|------|------|
| `text_row1` | `next_row` + `col_text(0)` | **"alpha"**（5 字节） |
| `text_row2` | 第二次 `next_row` + `col_text(0)` | **"beta"**（4 字节） |
| `text_done` | 第三次 `next_row` | `DB_ROW_DONE` |

向量表：`tests/baseline/std-sqlite-row-col-text-vectors.tsv`。

---

## Gate

Honesty soft→硬绿（2026-08-28）：prefer product `xlang_asm`；钉 `XLANG_LINK_XLANG`；显式坏／缺 native 硬 die；host-C 仅 prebuilt `std/db/sqlite/sqlite.o`＝obs（拒 soft `ensure_std_c_o`／`std_sqlite_build_o`／auto-make／prefer-c／SKIP→OK）；check＝obs（暂停）；tip 产品 `-o` SEGV／UNDEF＝obs（产品另案）。报告 `run=`／`obs=`／`skip=`（退役 `text_c=`／`text_x=`）。API 权威对齐 `col_text`（拒化石 `row_col_text`）。

```bash
./tests/run-std-sqlite-row-col-text-gate.sh
```

```
xlang: [XLANG_STD068_DB_TEXT_COL] status=ok run=N obs=M skip=K
```

PLATFORM: SHARED archaeology — Ubuntu gold still required.

---

## 5. 联动

- manifest：`tests/baseline/std-sqlite-row-col-text.tsv`
- 父门禁：STD-067 next-row（本波同 honesty）
- CI：`tests/run-portable-suite.sh`

---

## 6. 非目标（v2）

- BLOB 列见 STD-069 `col_blob`
- 预编译语句缓存
- 并发只读连接池
