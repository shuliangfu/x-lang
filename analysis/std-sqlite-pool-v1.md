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

| API | 行为 |
|-----|------|
| `pool_open(path, max_conns)` | 创建池（不预建连接；max≤8） |
| `pool_acquire` | 借连接；耗尽返回 handle=0 + `DB_ERR_BUSY` |
| `pool_release` | 归还 idle |
| `pool_idle` | idle 数量 |
| `pool_close` | 关闭全部 idle（借出未还则 `DB_ERR_BUSY`） |

烟测：`db_sqlite_pool_smoke_c`、`pool_roundtrip.sx`。

---

## 3. 金样向量

| step_id | 期望 |
|---------|------|
| `reuse_handle` | release 后再 acquire 同一 handle |
| `exhausted` | max=1 时第二次 acquire 失败 |

---

## 4. Gate

```bash
./tests/run-std-sqlite-pool-gate.sh
```

```
shux: [SHUX_STD084_DB_POOL] status=ok pool_c=1 pool_sx=1 skip=0
```

---

## 5. 非目标（v2）

- 跨线程池
- `:memory:` 多连接共享（需 URI shared cache）
- 与 `std.cache` 通用抽象合并
