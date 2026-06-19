/**
 * std/cache/cache.c — LRU/TTL 缓存与通用对象池（STD-087）
 *
 * 【文件职责】
 * i64 键值 LRU 缓存（容量淘汰 + TTL 惰性过期）；通用 i64 资源池
 * acquire/release/health；命中率统计；供 mod.sx 与 gate 烟测调用。
 *
 * 【所属模块】标准库 std.cache；与 std/cache/mod.sx 同属一模块。
 * 【依赖】std/time/time.c（单调时钟 time_now_monotonic_ns_c）。
 */

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

enum {
    CACHE_OK = 0,
    CACHE_ERR_NULL = -1,
    CACHE_ERR_NOT_FOUND = -2,
    CACHE_ERR_FULL = -3,
    CACHE_ERR_INVALID = -4,
};

#define LRU_MAX_NODES 64
#define POOL_MAX_SLOTS 32

extern int64_t time_now_monotonic_ns_c(void);

typedef struct lru_node {
    int64_t key;
    int64_t value;
    int64_t expire_ns; /* 0 = 永不过期 */
    int32_t prev;
    int32_t next;
    int32_t used;
} lru_node_t;

typedef struct lru_cache {
    lru_node_t nodes[LRU_MAX_NODES];
    int32_t capacity;
    int32_t count;
    int32_t head;
    int32_t tail;
    int64_t hits;
    int64_t misses;
    int64_t evictions;
} lru_cache_t;

typedef struct pool_slot {
    int64_t resource;
    int32_t idle;
    int32_t healthy;
} pool_slot_t;

typedef struct obj_pool {
    pool_slot_t slots[POOL_MAX_SLOTS];
    int32_t max_slots;
    int32_t idle_count;
    int64_t acquire_count;
    int64_t release_count;
    int64_t health_fail;
} obj_pool_t;

static lru_cache_t *lru_from_handle(int64_t h) {
    if (h == 0) return NULL;
    return (lru_cache_t *)(uintptr_t)h;
}

static obj_pool_t *pool_from_handle(int64_t h) {
    if (h == 0) return NULL;
    return (obj_pool_t *)(uintptr_t)h;
}

/** 从空闲链分配节点索引；无空闲返回 -1。 */
static int32_t lru_alloc_node(lru_cache_t *c) {
    int32_t i;
    for (i = 0; i < LRU_MAX_NODES; i++) {
        if (!c->nodes[i].used) return i;
    }
    return -1;
}

/** 将节点 idx 移到 MRU（head）。 */
static void lru_touch(lru_cache_t *c, int32_t idx) {
    int32_t p;
    int32_t n;
    if (idx < 0 || !c->nodes[idx].used) return;
    if (c->head == idx) return;
    p = c->nodes[idx].prev;
    n = c->nodes[idx].next;
    if (p >= 0) c->nodes[p].next = n;
    if (n >= 0) c->nodes[n].prev = p;
    if (c->tail == idx) c->tail = p;
    c->nodes[idx].prev = -1;
    c->nodes[idx].next = c->head;
    if (c->head >= 0) c->nodes[c->head].prev = idx;
    c->head = idx;
    if (c->tail < 0) c->tail = idx;
}

/** 按 key 查找节点索引；不存在 -1。 */
static int32_t lru_find(lru_cache_t *c, int64_t key) {
    int32_t i;
    for (i = 0; i < LRU_MAX_NODES; i++) {
        if (c->nodes[i].used && c->nodes[i].key == key) return i;
    }
    return -1;
}

/** 移除节点 idx。 */
static void lru_remove_node(lru_cache_t *c, int32_t idx) {
    int32_t p;
    int32_t n;
    if (idx < 0 || !c->nodes[idx].used) return;
    p = c->nodes[idx].prev;
    n = c->nodes[idx].next;
    if (p >= 0) c->nodes[p].next = n;
    else c->head = n;
    if (n >= 0) c->nodes[n].prev = p;
    else c->tail = p;
    memset(&c->nodes[idx], 0, sizeof(c->nodes[idx]));
    c->count--;
}

/** 淘汰 LRU 尾节点；返回 0 成功，-1 空。 */
static int32_t lru_evict_lru(lru_cache_t *c) {
    int32_t idx = c->tail;
    if (idx < 0) return -1;
    lru_remove_node(c, idx);
    c->evictions++;
    return 0;
}

/** 检查条目是否过期；过期则删除并返回 1。 */
static int32_t lru_expire_if_needed(lru_cache_t *c, int32_t idx) {
    int64_t now;
    if (idx < 0 || !c->nodes[idx].used) return 0;
    if (c->nodes[idx].expire_ns == 0) return 0;
    now = time_now_monotonic_ns_c();
    if (now >= c->nodes[idx].expire_ns) {
        lru_remove_node(c, idx);
        return 1;
    }
    return 0;
}

/** 创建 LRU 缓存；capacity 须 1..LRU_MAX_NODES。 */
int64_t cache_lru_create_c(int32_t capacity) {
    lru_cache_t *c;
    if (capacity <= 0 || capacity > LRU_MAX_NODES) return 0;
    c = (lru_cache_t *)calloc(1, sizeof(lru_cache_t));
    if (!c) return 0;
    c->capacity = capacity;
    c->head = -1;
    c->tail = -1;
    return (int64_t)(uintptr_t)c;
}

/** 释放 LRU 缓存。 */
void cache_lru_free_c(int64_t handle) {
    lru_cache_t *c = lru_from_handle(handle);
    if (c) free(c);
}

/** 读取键；0 成功，-2 未命中/过期。 */
int32_t cache_lru_get_c(int64_t handle, int64_t key, int64_t *out_value) {
    lru_cache_t *c = lru_from_handle(handle);
    int32_t idx;
    if (!c || !out_value) return CACHE_ERR_NULL;
    idx = lru_find(c, key);
    if (idx < 0) {
        c->misses++;
        return CACHE_ERR_NOT_FOUND;
    }
    if (lru_expire_if_needed(c, idx)) {
        c->misses++;
        return CACHE_ERR_NOT_FOUND;
    }
    *out_value = c->nodes[idx].value;
    lru_touch(c, idx);
    c->hits++;
    return CACHE_OK;
}

/** 写入键值；ttl_ns=0 永不过期。 */
int32_t cache_lru_put_c(int64_t handle, int64_t key, int64_t value, int64_t ttl_ns) {
    lru_cache_t *c = lru_from_handle(handle);
    int32_t idx;
    int64_t expire = 0;
    if (!c) return CACHE_ERR_NULL;
    if (ttl_ns > 0) expire = time_now_monotonic_ns_c() + ttl_ns;
    idx = lru_find(c, key);
    if (idx >= 0) {
        c->nodes[idx].value = value;
        c->nodes[idx].expire_ns = expire;
        lru_touch(c, idx);
        return CACHE_OK;
    }
    while (c->count >= c->capacity) {
        if (lru_evict_lru(c) != 0) return CACHE_ERR_FULL;
    }
    idx = lru_alloc_node(c);
    if (idx < 0) return CACHE_ERR_FULL;
    c->nodes[idx].key = key;
    c->nodes[idx].value = value;
    c->nodes[idx].expire_ns = expire;
    c->nodes[idx].used = 1;
    c->nodes[idx].prev = -1;
    c->nodes[idx].next = c->head;
    if (c->head >= 0) c->nodes[c->head].prev = idx;
    c->head = idx;
    if (c->tail < 0) c->tail = idx;
    c->count++;
    return CACHE_OK;
}

/** 删除键；0 成功，-2 不存在。 */
int32_t cache_lru_remove_c(int64_t handle, int64_t key) {
    lru_cache_t *c = lru_from_handle(handle);
    int32_t idx;
    if (!c) return CACHE_ERR_NULL;
    idx = lru_find(c, key);
    if (idx < 0) return CACHE_ERR_NOT_FOUND;
    lru_remove_node(c, idx);
    return CACHE_OK;
}

/** 惰性清理所有过期条目；返回删除数。 */
int32_t cache_lru_purge_expired_c(int64_t handle) {
    lru_cache_t *c = lru_from_handle(handle);
    int32_t i;
    int32_t n = 0;
    if (!c) return CACHE_ERR_NULL;
    for (i = 0; i < LRU_MAX_NODES; i++) {
        if (c->nodes[i].used && c->nodes[i].expire_ns > 0) {
            if (lru_expire_if_needed(c, i)) n++;
        }
    }
    return n;
}

/** 读取统计；任意 out 可为 NULL。 */
void cache_lru_stats_c(int64_t handle, int64_t *hits, int64_t *misses, int64_t *evictions, int32_t *size) {
    lru_cache_t *c = lru_from_handle(handle);
    if (!c) return;
    if (hits) *hits = c->hits;
    if (misses) *misses = c->misses;
    if (evictions) *evictions = c->evictions;
    if (size) *size = c->count;
}

/** 创建对象池；max_slots 须 1..POOL_MAX_SLOTS。 */
int64_t cache_pool_create_c(int32_t max_slots) {
    obj_pool_t *p;
    if (max_slots <= 0 || max_slots > POOL_MAX_SLOTS) return 0;
    p = (obj_pool_t *)calloc(1, sizeof(obj_pool_t));
    if (!p) return 0;
    p->max_slots = max_slots;
    return (int64_t)(uintptr_t)p;
}

/** 释放对象池。 */
void cache_pool_free_c(int64_t handle) {
    obj_pool_t *p = pool_from_handle(handle);
    if (p) free(p);
}

/** 向池注册空闲资源；0 成功。 */
int32_t cache_pool_add_c(int64_t handle, int64_t resource) {
    obj_pool_t *p = pool_from_handle(handle);
    int32_t i;
    if (!p || resource == 0) return CACHE_ERR_NULL;
    if (p->idle_count >= p->max_slots) return CACHE_ERR_FULL;
    for (i = 0; i < POOL_MAX_SLOTS; i++) {
        if (p->slots[i].resource == resource) return CACHE_ERR_INVALID;
    }
    for (i = 0; i < POOL_MAX_SLOTS; i++) {
        if (p->slots[i].resource == 0) {
            p->slots[i].resource = resource;
            p->slots[i].idle = 1;
            p->slots[i].healthy = 1;
            p->idle_count++;
            return CACHE_OK;
        }
    }
    return CACHE_ERR_FULL;
}

/** 获取空闲健康资源；0 成功，-2 无可用。 */
int32_t cache_pool_acquire_c(int64_t handle, int64_t *out_resource) {
    obj_pool_t *p = pool_from_handle(handle);
    int32_t i;
    if (!p || !out_resource) return CACHE_ERR_NULL;
    for (i = 0; i < POOL_MAX_SLOTS; i++) {
        if (p->slots[i].resource != 0 && p->slots[i].idle && p->slots[i].healthy) {
            p->slots[i].idle = 0;
            p->idle_count--;
            *out_resource = p->slots[i].resource;
            p->acquire_count++;
            return CACHE_OK;
        }
    }
    return CACHE_ERR_NOT_FOUND;
}

/** 归还资源；0 成功，-2 未知资源。 */
int32_t cache_pool_release_c(int64_t handle, int64_t resource) {
    obj_pool_t *p = pool_from_handle(handle);
    int32_t i;
    if (!p || resource == 0) return CACHE_ERR_NULL;
    for (i = 0; i < POOL_MAX_SLOTS; i++) {
        if (p->slots[i].resource == resource) {
            if (p->slots[i].idle) return CACHE_ERR_INVALID;
            if (!p->slots[i].healthy) {
                p->slots[i].resource = 0;
                p->health_fail++;
                return CACHE_OK;
            }
            p->slots[i].idle = 1;
            p->idle_count++;
            p->release_count++;
            return CACHE_OK;
        }
    }
    return CACHE_ERR_NOT_FOUND;
}

/** 标记资源不健康；归还时丢弃。 */
int32_t cache_pool_mark_unhealthy_c(int64_t handle, int64_t resource) {
    obj_pool_t *p = pool_from_handle(handle);
    int32_t i;
    if (!p || resource == 0) return CACHE_ERR_NULL;
    for (i = 0; i < POOL_MAX_SLOTS; i++) {
        if (p->slots[i].resource == resource) {
            p->slots[i].healthy = 0;
            return CACHE_OK;
        }
    }
    return CACHE_ERR_NOT_FOUND;
}

/** 空闲资源数。 */
int32_t cache_pool_idle_c(int64_t handle) {
    obj_pool_t *p = pool_from_handle(handle);
    if (!p) return CACHE_ERR_NULL;
    return p->idle_count;
}

/** 池统计。 */
void cache_pool_stats_c(int64_t handle, int32_t *idle, int32_t *in_use, int32_t *unhealthy, int64_t *acquires) {
    obj_pool_t *p = pool_from_handle(handle);
    int32_t i;
    int32_t used = 0;
    int32_t bad = 0;
    if (!p) return;
    for (i = 0; i < POOL_MAX_SLOTS; i++) {
        if (p->slots[i].resource == 0) continue;
        if (!p->slots[i].healthy) bad++;
        else if (!p->slots[i].idle) used++;
    }
    if (idle) *idle = p->idle_count;
    if (in_use) *in_use = used;
    if (unhealthy) *unhealthy = bad;
    if (acquires) *acquires = p->acquire_count;
}

/** C 烟测：LRU 淘汰 + TTL + 对象池 acquire/release/health。 */
int32_t cache_smoke_c(void) {
    int64_t lru = cache_lru_create_c(2);
    int64_t pool = cache_pool_create_c(2);
    int64_t v = 0;
    int64_t r = 0;
    int32_t purged = 0;
    if (lru == 0 || pool == 0) return 1;
    if (cache_lru_put_c(lru, 1, 100, 0) != CACHE_OK) return 2;
    if (cache_lru_put_c(lru, 2, 200, 0) != CACHE_OK) return 3;
    if (cache_lru_put_c(lru, 3, 300, 0) != CACHE_OK) return 4;
    if (cache_lru_get_c(lru, 1, &v) != CACHE_ERR_NOT_FOUND) return 5;
    if (cache_lru_get_c(lru, 2, &v) != CACHE_OK || v != 200) return 6;
    if (cache_lru_put_c(lru, 4, 400, 1000000) != CACHE_OK) return 7;
    purged = cache_lru_purge_expired_c(lru);
    (void)purged;
    if (cache_pool_add_c(pool, 101) != CACHE_OK) return 8;
    if (cache_pool_add_c(pool, 102) != CACHE_OK) return 9;
    if (cache_pool_acquire_c(pool, &r) != CACHE_OK || r == 0) return 10;
    if (cache_pool_release_c(pool, r) != CACHE_OK) return 11;
    if (cache_pool_acquire_c(pool, &r) != CACHE_OK) return 12;
    if (cache_pool_mark_unhealthy_c(pool, r) != CACHE_OK) return 13;
    if (cache_pool_release_c(pool, r) != CACHE_OK) return 14;
    if (cache_pool_idle_c(pool) != 1) return 15;
    cache_lru_free_c(lru);
    cache_pool_free_c(pool);
    return 0;
}
