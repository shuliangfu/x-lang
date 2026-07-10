/**
 * runtime_sync_lock_diag_tls.c — STD-111 锁诊断 TLS + 元数据表（F-sync-lock-diag v2）
 *
 * 【文件职责】
 * __thread 持有 mutex 栈（最大 16）与锁诊断可变状态、元数据表、快照/烟测。
 * seed asm 暂不支持全局写与含全局的 if/while，诊断逻辑集中本 C 文件；
 * sync.x 保留 API 锚点与版本标记供 gate/manifest 校验。
 *
 * 【所属模块】std.sync；与 sync.o、runtime_sync_os.o 一并链入 exe。
 */

#include <stddef.h>
#include <stdint.h>

#define SYNC_LOCK_DIAG_ERR_RECURSIVE (-1)
#define SYNC_LOCK_DIAG_ERR_ORDER (-2)
#define SYNC_LOCK_DIAG_ERR_UNLOCK (-3)
#define SYNC_LOCK_DIAG_ERR_TABLE (-4)
#define SYNC_LOCK_DIAG_MAX_META 64
#define SYNC_LOCK_DIAG_MAX_HELD 16

/** 单槽元数据：mutex 指针 + 锁序 id。 */
typedef struct {
    void *mutex;
    int32_t order;
} sync_meta_slot_t;

static sync_meta_slot_t g_sync_meta[SYNC_LOCK_DIAG_MAX_META];
static int32_t g_sync_ld_meta_n;
static int32_t g_sync_ld_enabled;
static int32_t g_sync_ld_last_err;
static int32_t g_sync_ld_acquires;
static int32_t g_sync_ld_contentions;

#if defined(_MSC_VER)
static __declspec(thread) void *t_held_mutex[SYNC_LOCK_DIAG_MAX_HELD];
static __declspec(thread) int32_t t_held_order[SYNC_LOCK_DIAG_MAX_HELD];
static __declspec(thread) int32_t t_held_n;
#else
static __thread void *t_held_mutex[SYNC_LOCK_DIAG_MAX_HELD];
static __thread int32_t t_held_order[SYNC_LOCK_DIAG_MAX_HELD];
static __thread int32_t t_held_n;
#endif

/** Mutex OS 胶层（runtime_sync_os.c）。 */
extern void *sync_mutex_new_c(void);
extern int32_t sync_mutex_lock_c(void *m);
extern int32_t sync_mutex_unlock_c(void *m);
extern void sync_mutex_free_c(void *m);

/** 查找 mutex 对应元数据索引；不存在 -1。 */
static int32_t sync_lock_diag_find_meta_idx(void *m) {
    int32_t i;
    if (m == NULL) {
        return -1;
    }
    for (i = 0; i < g_sync_ld_meta_n; i++) {
        if (g_sync_meta[i].mutex == m) {
            return i;
        }
    }
    return -1;
}

/** 读取 mutex 绑定的锁序 id；未绑定返回 0。 */
static int32_t sync_lock_diag_get_order(void *m) {
    int32_t idx = sync_lock_diag_find_meta_idx(m);
    if (idx < 0) {
        return 0;
    }
    return g_sync_meta[idx].order;
}

/** 入栈；满返回 -1。 */
int32_t sync_lock_diag_tls_push_c(void *m, int32_t order_id) {
    if (t_held_n >= SYNC_LOCK_DIAG_MAX_HELD) {
        return -1;
    }
    t_held_mutex[t_held_n] = m;
    t_held_order[t_held_n] = order_id;
    t_held_n++;
    return 0;
}

/** 出栈（栈空无操作）。 */
void sync_lock_diag_tls_pop_c(void) {
    if (t_held_n > 0) {
        t_held_n--;
    }
}

/**
 * 查询 m 在持有栈中的状态。
 * 0=未持有；1=持有但非栈顶；2=持有且为栈顶（LIFO 解锁目标）。
 */
int32_t sync_lock_diag_tls_has_c(void *m) {
    int32_t i;
    for (i = 0; i < t_held_n; i++) {
        if (t_held_mutex[i] == m) {
            if (i == t_held_n - 1) {
                return 2;
            }
            return 1;
        }
    }
    return 0;
}

/** 当前线程已持有锁的最大 order id。 */
int32_t sync_lock_diag_tls_max_order_c(void) {
    int32_t mx = 0;
    int32_t i;
    for (i = 0; i < t_held_n; i++) {
        if (t_held_order[i] > mx) {
            mx = t_held_order[i];
        }
    }
    return mx;
}

/** 当前线程持有栈深度。 */
int32_t sync_lock_diag_tls_count_c(void) {
    return t_held_n;
}

/** 清空当前线程持有栈。 */
void sync_lock_diag_tls_clear_c(void) {
    t_held_n = 0;
}

/** 加锁前诊断：递归/锁序违规返回 -1（供 runtime_sync_os 调用）。 */
int32_t sync_lock_diag_before_lock(void *m) {
    int32_t oid;
    int32_t maxo;
    if (g_sync_ld_enabled == 0) {
        return 0;
    }
    if (sync_lock_diag_tls_has_c(m) != 0) {
        g_sync_ld_last_err = SYNC_LOCK_DIAG_ERR_RECURSIVE;
        return -1;
    }
    oid = sync_lock_diag_get_order(m);
    if (oid != 0) {
        maxo = sync_lock_diag_tls_max_order_c();
        if (maxo > 0 && oid <= maxo) {
            g_sync_ld_last_err = SYNC_LOCK_DIAG_ERR_ORDER;
            g_sync_ld_contentions++;
            return -1;
        }
    }
    return 0;
}

/** 加锁成功后记录持有栈。 */
void sync_lock_diag_after_lock(void *m) {
    int32_t oid;
    if (g_sync_ld_enabled == 0) {
        return;
    }
    oid = sync_lock_diag_get_order(m);
    if (sync_lock_diag_tls_push_c(m, oid) != 0) {
        g_sync_ld_last_err = SYNC_LOCK_DIAG_ERR_TABLE;
        return;
    }
    g_sync_ld_acquires++;
    g_sync_ld_last_err = 0;
}

/** 解锁前诊断：须 LIFO 释放。 */
int32_t sync_lock_diag_before_unlock(void *m) {
    if (g_sync_ld_enabled == 0) {
        return 0;
    }
    if (sync_lock_diag_tls_count_c() <= 0 || sync_lock_diag_tls_has_c(m) != 2) {
        g_sync_ld_last_err = SYNC_LOCK_DIAG_ERR_UNLOCK;
        return -1;
    }
    return 0;
}

/** 解锁成功后弹出持有栈。 */
void sync_lock_diag_after_unlock(void *m) {
    (void)m;
    if (g_sync_ld_enabled == 0) {
        return;
    }
    sync_lock_diag_tls_pop_c();
    g_sync_ld_last_err = 0;
}

/** 开启/关闭锁诊断。 */
void sync_lock_diag_set_enabled_c(int32_t on) {
    g_sync_ld_enabled = (on != 0) ? 1 : 0;
}

/** 查询锁诊断是否开启。 */
int32_t sync_lock_diag_is_enabled_c(void) {
    return (g_sync_ld_enabled != 0) ? 1 : 0;
}

/** 为 mutex 绑定锁序 id；0=跳过锁序检查。 */
int32_t sync_lock_diag_mutex_set_id_c(void *m, int32_t id) {
    int32_t idx;
    if (m == NULL) {
        return -1;
    }
    idx = sync_lock_diag_find_meta_idx(m);
    if (idx >= 0) {
        g_sync_meta[idx].order = id;
        return 0;
    }
    if (g_sync_ld_meta_n >= SYNC_LOCK_DIAG_MAX_META) {
        g_sync_ld_last_err = SYNC_LOCK_DIAG_ERR_TABLE;
        return -1;
    }
    idx = g_sync_ld_meta_n;
    g_sync_meta[idx].mutex = m;
    g_sync_meta[idx].order = id;
    g_sync_ld_meta_n++;
    return 0;
}

/** 最近诊断错误码。 */
int32_t sync_lock_diag_last_err_c(void) {
    return g_sync_ld_last_err;
}

/** 清空元数据、统计与当前线程持有栈。 */
void sync_lock_diag_clear_c(void) {
    g_sync_ld_last_err = 0;
    g_sync_ld_acquires = 0;
    g_sync_ld_contentions = 0;
    g_sync_ld_meta_n = 0;
    sync_lock_diag_tls_clear_c();
}

/** 向 out[pos] 追加单字节；满则 -1。 */
static int32_t sync_lock_diag_append_byte(uint8_t *out, int32_t pos, int32_t cap, uint8_t b) {
    if (out == NULL || pos < 0 || pos >= cap) {
        return -1;
    }
    out[pos] = b;
    return pos + 1;
}

/** 向 out 追加 n 字节字面量。 */
static int32_t sync_lock_diag_append_lit(uint8_t *out, int32_t pos, int32_t cap,
                                         const uint8_t *s, int32_t n) {
    int32_t i;
    for (i = 0; i < n; i++) {
        pos = sync_lock_diag_append_byte(out, pos, cap, s[i]);
        if (pos < 0) {
            return -1;
        }
    }
    return pos;
}

/** 将 i32 十进制追加到 out；失败 -1。 */
static int32_t sync_lock_diag_append_i32(uint8_t *out, int32_t pos, int32_t cap, int32_t v) {
    uint8_t tmp[16];
    int32_t n = 0;
    int32_t x = v;
    if (out == NULL || pos < 0 || cap <= pos) {
        return -1;
    }
    if (x == 0) {
        return sync_lock_diag_append_byte(out, pos, cap, (uint8_t)'0');
    }
    if (x < 0) {
        pos = sync_lock_diag_append_byte(out, pos, cap, (uint8_t)'-');
        if (pos < 0) {
            return -1;
        }
        x = -x;
    }
    while (x > 0) {
        tmp[n] = (uint8_t)('0' + (x % 10));
        n++;
        x = x / 10;
    }
    while (n > 0) {
        n--;
        pos = sync_lock_diag_append_byte(out, pos, cap, tmp[n]);
        if (pos < 0) {
            return -1;
        }
    }
    return pos;
}

/** 写入文本快照；返回写入字节数，失败 -1。 */
int32_t sync_lock_diag_snapshot_c(uint8_t *out, int32_t cap) {
    static const uint8_t lit_enabled[] = {'e', 'n', 'a', 'b', 'l', 'e', 'd', '=', 0};
    static const uint8_t lit_held[] = {' ', 'h', 'e', 'l', 'd', '=', 0};
    static const uint8_t lit_acquires[] = {' ', 'a', 'c', 'q', 'u', 'i', 'r', 'e', 's', '=', 0};
    static const uint8_t lit_contentions[] = {' ', 'c', 'o', 'n', 't', 'e', 'n', 't', 'i', 'o', 'n', 's', '=', 0};
    static const uint8_t lit_last_err[] = {' ', 'l', 'a', 's', 't', '_', 'e', 'r', 'r', '=', 0};
    int32_t pos = 0;
    if (out == NULL || cap <= 0) {
        return -1;
    }
    pos = sync_lock_diag_append_lit(out, pos, cap, lit_enabled, 8);
    if (pos < 0) {
        return -1;
    }
    pos = sync_lock_diag_append_i32(out, pos, cap, g_sync_ld_enabled);
    if (pos < 0) {
        return -1;
    }
    pos = sync_lock_diag_append_lit(out, pos, cap, lit_held, 6);
    if (pos < 0) {
        return -1;
    }
    pos = sync_lock_diag_append_i32(out, pos, cap, sync_lock_diag_tls_count_c());
    if (pos < 0) {
        return -1;
    }
    pos = sync_lock_diag_append_lit(out, pos, cap, lit_acquires, 10);
    if (pos < 0) {
        return -1;
    }
    pos = sync_lock_diag_append_i32(out, pos, cap, g_sync_ld_acquires);
    if (pos < 0) {
        return -1;
    }
    pos = sync_lock_diag_append_lit(out, pos, cap, lit_contentions, 13);
    if (pos < 0) {
        return -1;
    }
    pos = sync_lock_diag_append_i32(out, pos, cap, g_sync_ld_contentions);
    if (pos < 0) {
        return -1;
    }
    pos = sync_lock_diag_append_lit(out, pos, cap, lit_last_err, 10);
    if (pos < 0) {
        return -1;
    }
    pos = sync_lock_diag_append_i32(out, pos, cap, g_sync_ld_last_err);
    if (pos < 0 || pos >= cap) {
        return -1;
    }
    return pos;
}

/** C 烟测：锁序/递归/快照场景。 */
int32_t sync_lock_diag_smoke_c(void) {
    void *m1;
    void *m2;
    uint8_t snap[96];
    m1 = sync_mutex_new_c();
    m2 = sync_mutex_new_c();
    if (m1 == NULL || m2 == NULL) {
        sync_mutex_free_c(m1);
        sync_mutex_free_c(m2);
        return 1;
    }
    sync_lock_diag_clear_c();
    sync_lock_diag_set_enabled_c(1);
    if (sync_lock_diag_mutex_set_id_c(m1, 1) != 0 || sync_lock_diag_mutex_set_id_c(m2, 2) != 0) {
        return 2;
    }
    if (sync_mutex_lock_c(m1) != 0 || sync_mutex_lock_c(m2) != 0) {
        return 3;
    }
    if (sync_mutex_unlock_c(m2) != 0 || sync_mutex_unlock_c(m1) != 0) {
        return 4;
    }
    if (sync_mutex_lock_c(m2) != 0) {
        return 5;
    }
    if (sync_mutex_lock_c(m1) != -1 || sync_lock_diag_last_err_c() != SYNC_LOCK_DIAG_ERR_ORDER) {
        sync_mutex_unlock_c(m2);
        return 6;
    }
    sync_mutex_unlock_c(m2);
    if (sync_mutex_lock_c(m1) != 0) {
        return 7;
    }
    if (sync_mutex_lock_c(m1) != -1 || sync_lock_diag_last_err_c() != SYNC_LOCK_DIAG_ERR_RECURSIVE) {
        sync_mutex_unlock_c(m1);
        return 8;
    }
    sync_mutex_unlock_c(m1);
    if (sync_lock_diag_snapshot_c(snap, 96) <= 0) {
        return 9;
    }
    sync_lock_diag_set_enabled_c(0);
    if (sync_mutex_lock_c(m1) != 0 || sync_mutex_unlock_c(m1) != 0) {
        return 10;
    }
    sync_mutex_free_c(m1);
    sync_mutex_free_c(m2);
    return 0;
}
