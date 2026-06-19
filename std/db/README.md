# std.db — 数据库与存储

> **布局**：`std/db/` 统一收纳数据库相关模块。

| 子模块 | 导入路径 | 说明 |
|--------|----------|------|
| **sqlite** | `import("std.db.sqlite")` | SQLite3 SQL 引擎（可选 `-lsqlite3`） |
| **kv** | `import("std.db.kv")` | mmap LSM Append-Only KV / 时序底座（无 SQL） |
| **arrow** | `import("std.db.arrow")` | 零拷贝列式内存（64B 对齐，配合 std.simd） |

## 迁移说明

- 原 `std/sqlite/` 已迁至 **`std/db/sqlite/`**。
- `import("std.sqlite")` 仍可用（deprecated 兼容层，见 `std/sqlite/mod.sx`）。
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
make -C compiler ../std/db/arrow/arrow.o     # Arrow 列式
make -C compiler ../std/sys/mmap.o             # sys mmap
```

## 测试

- `./tests/run-std-db-kv-arrow-gate.sh`
