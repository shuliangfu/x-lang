# STD-084：std.db.sqlite 连接池 v1

> 更新时间：2026-06-18  
> 状态：**可用**  
> 前置：STD-070 `std-sqlite-stmt-cache-v1.md`

---

## 1. 目标

实现 **惰性建连 + acquire/release 复用** 连接池（v1 单线程）。

验收：`tests/run-std-sqlite-pool-gate.sh` 绿。

---

## 2. pool API（v1）

产品门面（`std/db/sqlite/mod.x`；化石名 `pool_*` 已收敛）：

| API | 行为 |
|-----|------|
| `open(path, max_conns)` | 创建池（DbPool overload；不预建连接；max≤8） |
| `acquire` | 借连接；耗尽返回 handle=0 + `DB_ERR_BUSY` |
| `release` | 归还 idle |
| `idle` | idle 数量 |
| `close(pool)` | 关闭全部 idle（借出未还则 `DB_ERR_BUSY`） |

烟测：`db_sqlite_pool_smoke_c`、`pool_roundtrip.x`。

---

## 3. 金样向量

| step_id | 期望 |
|---------|------|
| `reuse_handle` | release 后再 acquire 同一 handle |
| `exhausted` | max=1 时第二次 acquire 失败 |

---

## Gate

Honesty soft→硬绿（2026-08-28）：prefer product `xlang_asm`；钉 `XLANG_LINK_XLANG`；显式坏／缺 native 硬 die；host-C 仅 prebuilt `sqlite.o`＝obs（拒 soft `std_sqlite_build_o`／ensure／auto-make）；check＝obs（暂停）；tip 产品 `-o` SEGV／UNDEF＝obs（产品另案）。报告 `run=`／`obs=`／`skip=`（退役 `pool_c=`／`pool_x=`）。

```bash
./tests/run-std-sqlite-pool-gate.sh
```

```
xlang: [XLANG_STD084_DB_POOL] status=ok run=N obs=M skip=K
```

PLATFORM: SHARED archaeology — Ubuntu gold still required.

---

## 5. 非目标（v2）

- 跨线程池
- `:memory:` 多连接共享（需 URI shared cache）
- 与 `std.cache` 通用抽象合并
