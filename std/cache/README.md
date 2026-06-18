# std.cache — LRU/TTL 缓存与通用对象池（STD-087）

## API

| API | 说明 |
|-----|------|
| `lru_new` / `lru_free` | LRU 缓存生命周期 |
| `lru_get` / `lru_put` / `lru_remove` | 键值读写与删除 |
| `lru_purge_expired` | TTL 惰性清理 |
| `lru_stats` | hits/misses/evictions/size |
| `pool_new` / `pool_free` | 对象池生命周期 |
| `pool_add` / `pool_acquire` / `pool_release` | 资源注册与借还 |
| `pool_mark_unhealthy` | 健康检查失败标记 |
| `pool_idle` / `pool_stats` | 池观测 |

## Gate

```bash
./tests/run-std-cache-gate.sh
```

## v1 限制

- LRU 键值均为 `i64`；最大 64 条目
- 对象池最大 32 槽；资源为 opaque `i64` 句柄
- 单线程；并发安全为后续版本
