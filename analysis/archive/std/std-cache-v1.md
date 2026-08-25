# STD-087 std.cache v1

> 更新时间：2026-08-25  
> 状态：**可用** — LRU + TTL + 对象池 + 统计 + gate honesty

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
| `new_lru` / `get` / `put` | LRU 容量淘汰 |
| `remove` / `purge` | 删键 / TTL 惰性过期 |
| `stats`（`*LruCache`） | 命中率统计 |
| `new` / `add` / `acquire` / `release` | 通用资源池 |
| `mark_unhealthy` | health 失败丢弃 |
| `idle` / `stats`（`*ObjPool`） | 池观测 |

实现：`std/cache/mod.x` + `std/cache/cache.x`（formal_mod：`mod|1` + bare-impl `*_c`）；依赖 `std/time` 单调时钟。

---

## 3. Gate

Honesty（2026-08-25）：prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`；`check` 观测；`lru_pool_smoke.x` exit0 硬失败；C smoke 仅观测；报告 `check=`／`run=`／`skip=`。

```
xlang: [XLANG_STD_CACHE] status=ok check=1 run=1 skip=0
std-cache gate OK
```

（Darwin 上 `check=0` 观测亦可；硬绿信号是 `run=1`。）

---

## 4. Changelog

- 2026-08-25：formal_mod 补全 `mod.x`+`cache.x`（根治 `std_cache_*` UNDEF）；闸／TSV／DOC 假权威诚实化；钉盘不升。
- 2026-06-18：v1 初版（LRU + 池 + gate）。

---

## 5. 后续（非 v1 阻塞）

- 与 `std.db.sqlite` DbPool / `std.net` 客户端池统一抽象  
- 并发安全（mutex 包装）  
- 字符串键 / 自定义 value 析构回调  
