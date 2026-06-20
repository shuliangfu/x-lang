# STD-087 std.cache v1

> 更新时间：2026-06-18  
> 状态：**可用** — LRU + TTL + 对象池 + 统计 + gate

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 API |
| 2 | `tests/baseline/std-cache-manifest.tsv` |
| 3 | `./tests/run-std-cache-gate.sh` |

---

## 2. API

| API | 说明 |
|-----|------|
| `lru_new` / `lru_get` / `lru_put` | LRU 容量淘汰 |
| `lru_purge_expired` | TTL 惰性过期 |
| `lru_stats` | 命中率统计 |
| `pool_new` / `pool_acquire` / `pool_release` | 通用资源池 |
| `pool_mark_unhealthy` | health 失败丢弃 |
| `pool_stats` | 池观测 |

实现：`std/cache/mod.sx` + `std/cache/cache.c`；依赖 `std/time` 单调时钟。

---

## 3. Gate

```
shux: [SHUX_STD_CACHE] status=ok c_smoke=1 su=1 skip=0
std-cache gate OK
```

---

## 4. 后续（非 v1 阻塞）

- 与 `std.db.sqlite` DbPool / `std.net` 客户端池统一抽象  
- 并发安全（mutex 包装）  
- 字符串键 / 自定义 value 析构回调  
