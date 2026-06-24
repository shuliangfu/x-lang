# std.db — 数据库与存储

> **布局**：`std/db/` 统一收纳数据库相关模块。

| 子模块 | 导入路径 | 说明 |
|--------|----------|------|
| **sqlite** | `import("std.db.sqlite")` | SQLite3 SQL 引擎（可选 `-lsqlite3`） |
| **kv** | `import("std.db.kv")` | mmap LSM Append-Only KV / 时序底座（无 SQL） |
| **arrow** | `import("std.db.arrow")` | 零拷贝列式内存（`arrow.sx` + SIMD 胶层，F-05 v1） |

## 迁移说明

- SQLite 实现位于 **`std/db/sqlite/`**（`mod.sx` + `sqlite.sx` + `sqlite_glue.c`）。
- 新代码请使用 `import("std.db.sqlite")` 或 `import("std.db")` 门面。

## kv — 高频时序 / 权重流

- **WAL 分层**（`*.wal`）：热写 Append-Only；`wal_flush` 合并入主文件（L1）
- **多级 SST**：`compact` 后冻结 L2/L3/L4 侧车 `*.sst.N`；槽满时 **去重合并** 级联；`sst_level_count`
- Arena bump 序列化；mmap 4096 扇区；API：`open` / `append_ts` / `get` / `wal_flush` / `compact` / `sync`

## arrow — 列式零拷贝

- **I32 / F32 / F64** 64B 对齐列；**null bitmap**（bit=1 有效）
- **`column_adopt_f32` / `column_adopt_i32`**：零拷贝接管网卡 DMA buffer（destroy 不释放外部内存）
- **null_bitmap**（bit=1 有效）；**SIMD** 归约（含 null-aware `column_f32_sum_valid`）

## 链接（runtime 按需）

引用 `db_kv_*` / `arrow_column_*` 符号时，C/asm 链接器自动链入 `kv.o` / `arrow.o`（见 `boot-std-link-contract.tsv`）。

## 构建

```bash
make -C compiler ../std/db/sqlite/sqlite.o   # SQLite 后端
make -C compiler ../std/db/kv/kv.o           # KV 引擎
make -C compiler ../std/db/arrow/arrow.o     # Arrow 列式（F-05 v1：arrow.sx + 胶层）
# F-02 v1：std.sys.mmap 已纯 .sx，无需单独 make mmap.o
```

## F-05 闭合（v4）

- 三后端业务逻辑均在 **`.sx`**；仅 **3 个胶层 `.c`**（SIMD / mmap / libsqlite3）
- 文档：`analysis/phase-f-f05-v4-closure.md`
- 聚合 gate：`./tests/run-f05-std-db-closure-gate.sh`

## 测试

- `./tests/run-f05-std-db-closure-gate.sh`
- `./tests/run-std-db-kv-arrow-gate.sh`
