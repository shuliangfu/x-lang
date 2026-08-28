# STD-065：std.db SQLite exec 深化 v1

> 更新时间：2026-08-28  
> 状态：**定版（v1）＋ honesty Gate**  
> 前置：STD-057 `std-sqlite-v1.md`  
> 关联：STD-010 事务层 D3、EXC-003

---

## 1. 目标

在 STD-057 单条 `exec` 往返上扩展 **事务 exec 烟测**：`begin_tx` / `commit` / `rollback` 与 `changes` 联动。

验收：`tests/run-std-sqlite-exec-deep-gate.sh` 绿；`min_tx_apis=3`。C 烟测／tip 产品 `-o`＝obs（拒 soft `tx_c=1` 硬绑）。

---

## 2. 事务 Exec API（深化）

| API | 深化行为 |
|-----|----------|
| `begin_tx` | `BEGIN IMMEDIATE` 后允许 DML |
| `commit` | 提交后 `changes` 保留 |
| `rollback` | 回滚后无残留写入 |

烟测入口：`db_sqlite_tx_exec_smoke_c`（C）、`exec_tx_roundtrip.x`（.x）。

---

## 3. 金样向量

| step_id | 操作 | 期望 |
|---------|------|------|
| `tx_begin` | `begin_tx` | `DB_OK` |
| `tx_insert` | `exec INSERT` | `DB_OK`，`changes=1` |
| `tx_commit` | `commit` | `DB_OK` |
| `tx_rollback` | `begin` + `INSERT` + `rollback` | `DB_OK` |

向量表：`tests/baseline/std-sqlite-exec-deep-vectors.tsv`。

---

## 4. Gate

Honesty soft→硬绿（2026-08-28）：prefer product `xlang_asm`；钉 `XLANG_LINK_XLANG`；显式坏／缺 native 硬 die；host-C 仅 prebuilt `std/db/sqlite/sqlite.o`＝obs（拒 soft `ensure_std_c_o`／`std_sqlite_build_o`／auto-make／prefer-c／SKIP→OK）；check＝obs（暂停）；tip 产品 `-o` SEGV／UNDEF＝obs（产品另案）。报告 `run=`／`obs=`／`skip=`（退役 `tx_c=`／`tx_x=`）。API 权威对齐 `begin_tx`／`commit`／`rollback`。父 STD-057 MANIFEST_ONLY 硬委托（已诚实收口）。

```bash
./tests/run-std-sqlite-exec-deep-gate.sh
```

```
xlang: [XLANG_STD065_DB_EXEC] status=ok run=N obs=M skip=K
```

PLATFORM: SHARED archaeology — Ubuntu gold still required.

---

## 5. 联动

- manifest：`tests/baseline/std-sqlite-exec-deep.tsv`
- 父门禁：STD-057 sqlite（本波 MANIFEST_ONLY 硬委托）
- 子门禁：STD-066 query-rows／STD-067 next_row
- CI：`tests/run-portable-suite.sh`

---

## 6. 非目标（v2）

- `query_rows` 行迭代
- 并发 / WAL 模式
- 文件库持久化 bench
