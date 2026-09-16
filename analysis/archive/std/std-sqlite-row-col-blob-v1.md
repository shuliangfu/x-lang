# STD-069：std.db.sqlite col_blob BLOB 列 v1

> 更新时间：2026-08-28  
> 状态：**可用**  
> 前置：STD-068 `std-sqlite-row-col-text-v1.md`  
> 关联：STD-010 D2 查询执行、EXC-003

---

## 1. 目标

在 STD-068 文本列基础上实现 **BLOB 列读取原型**：`col_blob` 将当前行 `col` 列二进制数据拷贝到调用方缓冲（C：`db_row_col_blob_c`）。

验收：`tests/run-std-sqlite-row-col-blob-gate.sh` 绿。

---

## 2. col_blob API（v1）

| API | v1 行为 |
|-----|---------|
| `col_blob` | `sqlite3_column_blob` + `sqlite3_column_bytes` 拷贝到 `out` |
| NULL / 空 BLOB | 返回 **0**（不写缓冲） |
| 缓冲不足 | `DB_ERR_EXEC` |

烟测入口：`db_sqlite_row_col_blob_smoke_c`（C）、`row_col_blob_roundtrip.x`（.x）。大对象分块见 STD-137 `col_blob_len`／`col_blob_read`。

---

## 3. 金样向量

| step_id | 操作 | 期望 |
|---------|------|------|
| `blob_row1` | `next_row` + `col_blob(0)` | **0x01 0x02 0x03**（3 字节） |
| `blob_row2` | 第二次 `next_row` + `col_blob(0)` | **0x0a 0x0b 0x0c 0x0d**（4 字节） |
| `blob_done` | 第三次 `next_row` | `DB_ROW_DONE` |

向量表：`tests/baseline/std-sqlite-row-col-blob-vectors.tsv`。

---

## Gate

Honesty soft→硬绿（2026-08-28）：prefer product `xlang_asm`；钉 `XLANG_LINK_XLANG`；显式坏／缺 native 硬 die；host-C 仅 prebuilt `std/db/sqlite/sqlite.o`＝obs（拒 soft `ensure_std_c_o`／`std_sqlite_build_o`／auto-make／prefer-c／SKIP→OK）；check＝obs（暂停）；tip 产品 `-o` SEGV／UNDEF＝obs（产品另案）。报告 `run=`／`obs=`／`skip=`（退役 `blob_c=`／`blob_x=`）。API 权威对齐 `col_blob`（拒化石 `row_col_blob`）。

```bash
./tests/run-std-sqlite-row-col-blob-gate.sh
```

```
xlang: [XLANG_STD069_DB_BLOB_COL] status=ok run=N obs=M skip=K
```

PLATFORM: SHARED archaeology — Ubuntu gold still required.

---

## 5. 联动

- manifest：`tests/baseline/std-sqlite-row-col-blob.tsv`
- 父门禁：STD-068 col_text（本波同 honesty）
- 下游：STD-137 blob-stream
- CI：`tests/run-portable-suite.sh`

---

## 6. 非目标（v2）

- 零拷贝 BLOB 视图
- 预编译语句缓存
- 并发只读连接池
