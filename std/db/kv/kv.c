/**
 * std/db/kv/kv.c — mmap LSM KV v2：WAL + 多级 SST + 压实（无 SQL）
 *
 * 【分层】
 * - L0 WAL（*.wal）：热写路径
 * - L1 Main（数据文件）：wal_flush 合并后的可变 SST
 * - L2+ Frozen（*.sst.N）：compact 后冻结的不可变 SST
 *
 * 【记录】rec_magic | rec_len | ts_ns | key_len | val_len | key | val
 */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if defined(__linux__) || defined(__APPLE__)
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>
#endif

#define KV_MAGIC "SHUKV01"
#define KV_WAL_MAGIC "SHUWAL01"
#define KV_SST_MAGIC "SHUSST02"
#define KV_SECTOR 4096u
#define KV_VERSION 3u
#define KV_REC_MAGIC 0x00434552u
#define KV_MAX_KEY 4096u
#define KV_MAX_VAL (16u * 1024u * 1024u)
#define KV_ARENA_CAP (256u * 1024u)
#define KV_MT_CAP 8192u
#define KV_PATH_MAX 512u
#define KV_SST_SLOTS 3u
#define KV_LAYER_MAIN 0u
#define KV_LAYER_WAL 1u
#define KV_LAYER_SST_BASE 10u

typedef struct {
    char magic[8];
    uint32_t version;
    uint32_t sector;
    uint64_t capacity;
    uint64_t write_pos;
    uint64_t record_count;
    uint64_t compact_gen;
    uint32_t sst_count;
    uint32_t _pad_sst;
} kv_header_t;

typedef struct {
    char magic[8];
    uint64_t capacity;
    uint64_t write_pos;
    uint64_t record_count;
} kv_wal_header_t;

typedef struct {
    char magic[8];
    uint32_t slot;
    uint32_t _pad;
    uint64_t capacity;
    uint64_t write_pos;
    uint64_t frozen_compact_gen;
} kv_sst_header_t;

typedef struct {
    uint64_t off;
    uint32_t key_len;
    uint32_t key_hash;
    uint8_t layer;
    uint8_t _pad[3];
} kv_mt_entry_t;

typedef struct {
    void *map;
    size_t map_size;
    kv_header_t *hdr;
    void *wal_map;
    size_t wal_map_size;
    kv_wal_header_t *wal_hdr;
    void *sst_map[KV_SST_SLOTS];
    size_t sst_map_size[KV_SST_SLOTS];
    kv_sst_header_t *sst_hdr[KV_SST_SLOTS];
    char data_path[KV_PATH_MAX];
    kv_mt_entry_t mt[KV_MT_CAP];
    uint32_t mt_count;
    uint8_t arena[KV_ARENA_CAP];
    size_t arena_off;
} kv_store_t;

static const uint8_t *kv_layer_base_cap(kv_store_t *s, uint8_t layer, uint64_t *out_cap);

static uint32_t kv_hash_key(const uint8_t *key, uint32_t len) {
    uint32_t h = 2166136261u;
    uint32_t i;
    for (i = 0; i < len; i++) {
        h ^= (uint32_t)key[i];
        h *= 16777619u;
    }
    return h;
}

static int kv_keys_equal(const uint8_t *a, uint32_t alen, const uint8_t *b, uint32_t blen) {
    return alen == blen && memcmp(a, b, alen) == 0;
}

static void kv_mt_clear(kv_store_t *s) {
    s->mt_count = 0;
}

static void kv_mt_put_ex(kv_store_t *s, uint64_t off, const uint8_t *key, uint32_t key_len, uint8_t layer) {
    uint32_t h = kv_hash_key(key, key_len);
    uint32_t i;
    for (i = 0; i < s->mt_count; i++) {
        if (s->mt[i].key_hash == h && s->mt[i].key_len == key_len) {
            const uint8_t *base;
            uint64_t cap;
            const uint8_t *p;
            uint32_t klen;
            base = kv_layer_base_cap(s, s->mt[i].layer, &cap);
            if (base && s->mt[i].off + 24 <= cap) {
                p = base + s->mt[i].off;
                memcpy(&klen, p + 16, 4);
                if (klen == key_len && kv_keys_equal(p + 24, klen, key, key_len)) {
                    s->mt[i].off = off;
                    s->mt[i].layer = layer;
                    return;
                }
            }
        }
    }
    for (i = 0; i < s->mt_count; i++) {
        if (s->mt[i].key_hash == h && s->mt[i].key_len == key_len) {
            s->mt[i].off = off;
            s->mt[i].layer = layer;
            return;
        }
    }
    if (s->mt_count < KV_MT_CAP) {
        s->mt[s->mt_count].off = off;
        s->mt[s->mt_count].key_len = key_len;
        s->mt[s->mt_count].key_hash = h;
        s->mt[s->mt_count].layer = layer;
        s->mt_count++;
    }
}

static uint64_t kv_mt_get_off(kv_store_t *s, const uint8_t *key, uint32_t key_len) {
    uint32_t h = kv_hash_key(key, key_len);
    uint32_t i;
    for (i = 0; i < s->mt_count; i++) {
        if (s->mt[i].key_hash == h && s->mt[i].key_len == key_len) {
            return s->mt[i].off;
        }
    }
    return 0;
}

static uint8_t *kv_arena_alloc(kv_store_t *s, size_t n, size_t align) {
    size_t off = s->arena_off;
    size_t mask = align - 1;
    if ((align & mask) != 0) {
        return NULL;
    }
    off = (off + mask) & ~mask;
    if (off + n > KV_ARENA_CAP) {
        return NULL;
    }
    s->arena_off = off + n;
    return s->arena + off;
}

static void kv_arena_reset(kv_store_t *s) {
    s->arena_off = 0;
}

#if defined(__linux__) || defined(__APPLE__)
static void *kv_mmap_file(const char *path, size_t min_size, size_t *out_size) {
    int fd;
    struct stat st;
    void *p;
    size_t len;
    fd = open(path, O_RDWR | O_CREAT, (mode_t)0644);
    if (fd < 0) {
        return NULL;
    }
    if (fstat(fd, &st) != 0) {
        close(fd);
        return NULL;
    }
    len = (size_t)st.st_size;
    if (len < min_size) {
        if (ftruncate(fd, (off_t)min_size) != 0) {
            close(fd);
            return NULL;
        }
        len = min_size;
    }
    p = mmap(NULL, len, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    close(fd);
    if (p == MAP_FAILED) {
        return NULL;
    }
    *out_size = len;
    return p;
}

static void kv_build_wal_path(const char *data_path, char *wal_path, size_t wal_cap) {
    (void)snprintf(wal_path, wal_cap, "%s.wal", data_path);
}

/** 构造冻结 SST 侧车路径：{data}.sst.N */
static void kv_build_sst_path(const char *data_path, uint32_t slot, char *out, size_t out_cap) {
    (void)snprintf(out, out_cap, "%s.sst.%u", data_path, (unsigned)slot);
}

/** 按 layer 取映射基址与容量；layer=KV_LAYER_SST_BASE+slot 为冻结 SST。 */
static const uint8_t *kv_layer_base_cap(kv_store_t *s, uint8_t layer, uint64_t *out_cap) {
    if (!s || !out_cap) {
        return NULL;
    }
    if (layer == KV_LAYER_WAL) {
        *out_cap = s->wal_hdr ? s->wal_hdr->capacity : 0;
        return (const uint8_t *)s->wal_map;
    }
    if (layer == KV_LAYER_MAIN) {
        *out_cap = s->hdr ? s->hdr->capacity : 0;
        return (const uint8_t *)s->map;
    }
    if (layer >= KV_LAYER_SST_BASE) {
        uint32_t slot = (uint32_t)layer - KV_LAYER_SST_BASE;
        if (slot < KV_SST_SLOTS && s->sst_hdr[slot]) {
            *out_cap = s->sst_hdr[slot]->capacity;
            return (const uint8_t *)s->sst_map[slot];
        }
    }
    return NULL;
}

static int32_t kv_read_at_map(const uint8_t *base, uint64_t cap, uint64_t off, const uint8_t *key,
                              uint32_t key_len, uint8_t *out, uint32_t out_cap) {
    const uint8_t *p;
    uint32_t rmagic, rlen, klen, vlen;
    if (off + 24 > cap) {
        return -1;
    }
    p = base + off;
    memcpy(&rmagic, p + 0, 4);
    memcpy(&rlen, p + 4, 4);
    if (rmagic != KV_REC_MAGIC || rlen < 24) {
        return -2;
    }
    memcpy(&klen, p + 16, 4);
    memcpy(&vlen, p + 20, 4);
    if (klen != key_len || off + 24u + klen + vlen > cap) {
        return -3;
    }
    if (!kv_keys_equal(p + 24, klen, key, key_len)) {
        return -4;
    }
    if (vlen > out_cap) {
        return -5;
    }
    memcpy(out, p + 24 + klen, vlen);
    return (int32_t)vlen;
}

/** 正向扫描映射区，返回指定 key 最后一次写入的值（LSM 最新胜）。 */
static int32_t kv_find_latest_in_map(const uint8_t *base, uint64_t map_cap, uint64_t end_off, uint64_t min_off,
                                     const uint8_t *key, uint32_t key_len, uint8_t *out, uint32_t out_cap,
                                     uint64_t *found_off) {
    uint64_t off = min_off;
    int32_t last_r = -6;
    while (off < end_off) {
        const uint8_t *p = base + off;
        uint32_t rmagic, rlen;
        int32_t r;
        if (off + 24 > map_cap) {
            break;
        }
        memcpy(&rmagic, p, 4);
        memcpy(&rlen, p + 4, 4);
        if (rmagic != KV_REC_MAGIC || rlen < 24 || off + rlen > end_off || off + rlen > map_cap) {
            break;
        }
        r = kv_read_at_map(base, map_cap, off, key, key_len, out, out_cap);
        if (r >= 0) {
            last_r = r;
            if (found_off) {
                *found_off = off;
            }
        }
        off += rlen;
    }
    return last_r;
}

/** 按顺序扫描映射区，重建 memtable（同 key 后者覆盖前者）。 */
static void kv_rebuild_mt_from_map(kv_store_t *s, const uint8_t *base, uint64_t map_cap, uint64_t end_off,
                                   uint8_t layer) {
    uint64_t off = KV_SECTOR;
    while (off < end_off) {
        const uint8_t *p = base + off;
        uint32_t rmagic, rlen, klen;
        if (off + 24 > map_cap) {
            break;
        }
        memcpy(&rmagic, p, 4);
        memcpy(&rlen, p + 4, 4);
        if (rmagic != KV_REC_MAGIC || rlen < 24 || off + rlen > end_off || off + rlen > map_cap) {
            break;
        }
        memcpy(&klen, p + 16, 4);
        if (klen > 0 && klen <= KV_MAX_KEY && off + 24u + klen <= map_cap) {
            kv_mt_put_ex(s, off, p + 24, klen, layer);
        }
        off += rlen;
    }
}

/** 向指定映射区顺序追加一条记录；返回写入偏移。 */
static int64_t kv_write_record_to_map(uint8_t *base, uint64_t cap, uint64_t *write_pos, uint8_t *rec,
                                      size_t rec_len) {
    uint64_t off = *write_pos;
    if (off + rec_len > cap) {
        return -1;
    }
    memcpy(base + off, rec, rec_len);
    *write_pos = off + (uint64_t)rec_len;
    return (int64_t)off;
}

static int32_t kv_serialize_record(kv_store_t *s, const uint8_t *key, uint32_t key_len, const uint8_t *val,
                                   uint32_t val_len, uint64_t ts_ns, uint8_t **out_rec, size_t *out_len) {
    uint8_t *base;
    uint32_t payload;
    uint32_t rec_len;
    size_t total;
    uint32_t magic = KV_REC_MAGIC;
    if (!s || !key || !val || key_len == 0 || key_len > KV_MAX_KEY || val_len > KV_MAX_VAL) {
        return -1;
    }
    payload = 8u + 4u + 4u + key_len + val_len;
    rec_len = 4u + 4u + payload;
    total = (size_t)rec_len;
    kv_arena_reset(s);
    base = kv_arena_alloc(s, total, 8);
    if (!base) {
        return -2;
    }
    memcpy(base + 0, &magic, 4);
    memcpy(base + 4, &rec_len, 4);
    memcpy(base + 8, &ts_ns, 8);
    memcpy(base + 16, &key_len, 4);
    memcpy(base + 20, &val_len, 4);
    memcpy(base + 24, key, key_len);
    memcpy(base + 24 + key_len, val, val_len);
    *out_rec = base;
    *out_len = total;
    return 0;
}

/** mmap 已存在的冻结 SST 侧车（open 时调用）。 */
static int32_t kv_open_sst_slots(kv_store_t *s) {
    uint32_t i;
    char path[KV_PATH_MAX];
    if (!s || !s->hdr) {
        return -1;
    }
    if (s->hdr->sst_count > KV_SST_SLOTS) {
        s->hdr->sst_count = KV_SST_SLOTS;
    }
    for (i = 0; i < s->hdr->sst_count; i++) {
        kv_build_sst_path(s->data_path, i, path, sizeof(path));
        s->sst_map[i] = kv_mmap_file(path, (size_t)s->hdr->capacity, &s->sst_map_size[i]);
        if (!s->sst_map[i]) {
            return -2;
        }
        s->sst_hdr[i] = (kv_sst_header_t *)s->sst_map[i];
        if (memcmp(s->sst_hdr[i]->magic, KV_SST_MAGIC, 7) != 0) {
            memset(s->sst_hdr[i], 0, sizeof(*s->sst_hdr[i]));
            memcpy(s->sst_hdr[i]->magic, KV_SST_MAGIC, 8);
            s->sst_hdr[i]->slot = i;
            s->sst_hdr[i]->capacity = (uint64_t)s->sst_map_size[i];
            s->sst_hdr[i]->write_pos = KV_SECTOR;
            s->sst_hdr[i]->frozen_compact_gen = 0;
        }
        if (s->sst_hdr[i]->write_pos < KV_SECTOR) {
            s->sst_hdr[i]->write_pos = KV_SECTOR;
        }
    }
    return 0;
}

/**
 * 两层 SST 去重合并：先扫 src 再扫 dst，同 key 后者胜；结果写入 dst，清空 src。
 */
static int32_t kv_sst_merge_dedup(kv_store_t *s, uint32_t src_slot, uint32_t dst_slot) {
    uint32_t i;
    uint32_t live_n;
    uint64_t *live_offs;
    uint8_t *live_layers;
    uint8_t *dst_base;
    uint8_t *out_buf;
    size_t out_len;
    size_t out_cap;
    if (!s || src_slot >= KV_SST_SLOTS || dst_slot >= KV_SST_SLOTS || src_slot == dst_slot) {
        return -1;
    }
    if (!s->sst_hdr[src_slot] || !s->sst_hdr[dst_slot] || !s->sst_map[src_slot] || !s->sst_map[dst_slot]) {
        return 0;
    }
    kv_mt_clear(s);
    kv_rebuild_mt_from_map(s, (const uint8_t *)s->sst_map[src_slot], s->sst_hdr[src_slot]->capacity,
                           s->sst_hdr[src_slot]->write_pos, (uint8_t)(KV_LAYER_SST_BASE + src_slot));
    kv_rebuild_mt_from_map(s, (const uint8_t *)s->sst_map[dst_slot], s->sst_hdr[dst_slot]->capacity,
                           s->sst_hdr[dst_slot]->write_pos, (uint8_t)(KV_LAYER_SST_BASE + dst_slot));
    live_n = s->mt_count;
    if (live_n == 0) {
        s->sst_hdr[src_slot]->write_pos = KV_SECTOR;
        return 0;
    }
    live_offs = (uint64_t *)calloc(live_n, sizeof(uint64_t));
    live_layers = (uint8_t *)calloc(live_n, 1);
    if (!live_offs || !live_layers) {
        free(live_offs);
        free(live_layers);
        return -2;
    }
    for (i = 0; i < live_n; i++) {
        live_offs[i] = s->mt[i].off;
        live_layers[i] = s->mt[i].layer;
    }
    out_cap = (size_t)(s->sst_hdr[dst_slot]->capacity - KV_SECTOR);
    out_buf = (uint8_t *)malloc(out_cap);
    if (!out_buf) {
        free(live_offs);
        free(live_layers);
        return -2;
    }
    out_len = 0;
    for (i = 0; i < live_n; i++) {
        const uint8_t *base;
        uint64_t cap;
        const uint8_t *p;
        uint32_t rlen;
        base = kv_layer_base_cap(s, live_layers[i], &cap);
        if (!base || live_offs[i] + 24 > cap) {
            continue;
        }
        p = base + live_offs[i];
        memcpy(&rlen, p + 4, 4);
        if (rlen >= 24 && out_len + rlen <= out_cap) {
            memcpy(out_buf + out_len, p, rlen);
            out_len += rlen;
        }
    }
    free(live_offs);
    free(live_layers);
    dst_base = (uint8_t *)s->sst_map[dst_slot];
    memset(dst_base + KV_SECTOR, 0, (size_t)(s->sst_hdr[dst_slot]->capacity - KV_SECTOR));
    memcpy(dst_base + KV_SECTOR, out_buf, out_len);
    free(out_buf);
    s->sst_hdr[dst_slot]->write_pos = KV_SECTOR + (uint64_t)out_len;
    memset((uint8_t *)s->sst_map[src_slot] + KV_SECTOR, 0, (size_t)(s->sst_hdr[src_slot]->capacity - KV_SECTOR));
    s->sst_hdr[src_slot]->write_pos = KV_SECTOR;
    return msync(s->sst_map[dst_slot], s->sst_map_size[dst_slot], MS_SYNC) == 0 ? 0 : -3;
}

/**
 * compact 后将 L1 主文件冻结为 L2+ SST 侧车。
 * 槽满时 L3 去重合并（slot0→slot1→slot2 级联）后写入最新层。
 */
static int32_t kv_freeze_main_to_sst(kv_store_t *s) {
    uint64_t data_len;
    uint32_t slot;
    char path[KV_PATH_MAX];
    uint8_t *main_base;
    uint8_t *sst_base;
    if (!s || !s->hdr) {
        return -1;
    }
    data_len = s->hdr->write_pos - KV_SECTOR;
    if (data_len == 0) {
        return 0;
    }
    if (s->hdr->sst_count >= KV_SST_SLOTS) {
        if (kv_sst_merge_dedup(s, 0, 1) != 0) {
            return -5;
        }
        if (kv_sst_merge_dedup(s, 1, 2) != 0) {
            return -5;
        }
        s->sst_hdr[0]->write_pos = KV_SECTOR;
        s->sst_hdr[1]->write_pos = KV_SECTOR;
        s->hdr->sst_count = 2;
        slot = 2;
    } else {
        slot = s->hdr->sst_count;
    }
    kv_build_sst_path(s->data_path, slot, path, sizeof(path));
    if (!s->sst_map[slot]) {
        s->sst_map[slot] = kv_mmap_file(path, (size_t)s->hdr->capacity, &s->sst_map_size[slot]);
        if (!s->sst_map[slot]) {
            return -2;
        }
        s->sst_hdr[slot] = (kv_sst_header_t *)s->sst_map[slot];
        memset(s->sst_hdr[slot], 0, sizeof(*s->sst_hdr[slot]));
        memcpy(s->sst_hdr[slot]->magic, KV_SST_MAGIC, 8);
        s->sst_hdr[slot]->slot = slot;
        s->sst_hdr[slot]->capacity = (uint64_t)s->sst_map_size[slot];
        s->sst_hdr[slot]->write_pos = KV_SECTOR;
    }
    main_base = (uint8_t *)s->map;
    sst_base = (uint8_t *)s->sst_map[slot];
    if (KV_SECTOR + data_len > s->sst_hdr[slot]->capacity) {
        return -3;
    }
    memcpy(sst_base + KV_SECTOR, main_base + KV_SECTOR, (size_t)data_len);
    s->sst_hdr[slot]->write_pos = KV_SECTOR + data_len;
    s->sst_hdr[slot]->frozen_compact_gen = s->hdr->compact_gen;
    if (slot >= s->hdr->sst_count) {
        s->hdr->sst_count = slot + 1;
    }
    memset(main_base + KV_SECTOR, 0, (size_t)(s->hdr->capacity - KV_SECTOR));
    s->hdr->write_pos = KV_SECTOR;
    s->hdr->record_count = 0;
    if (msync(s->sst_map[slot], s->sst_map_size[slot], MS_SYNC) != 0) {
        return -4;
    }
    return 0;
}
#endif

int64_t db_kv_open_c(uint8_t *path, uint64_t capacity_bytes) {
#if defined(__linux__) || defined(__APPLE__)
    kv_store_t *s;
    char wal_path[KV_PATH_MAX];
    size_t cap;
    size_t map_sz;
    size_t wal_sz;
    uint32_t i;
    if (!path || capacity_bytes < KV_SECTOR) {
        return 0;
    }
    cap = (size_t)capacity_bytes;
    if (cap % KV_SECTOR != 0) {
        cap = ((cap / KV_SECTOR) + 1) * KV_SECTOR;
    }
    s = (kv_store_t *)calloc(1, sizeof(*s));
    if (!s) {
        return 0;
    }
    (void)snprintf(s->data_path, sizeof(s->data_path), "%s", (const char *)path);
    s->map = kv_mmap_file((const char *)path, cap, &map_sz);
    if (!s->map) {
        free(s);
        return 0;
    }
    s->map_size = map_sz;
    s->hdr = (kv_header_t *)s->map;
    if (memcmp(s->hdr->magic, KV_MAGIC, 7) != 0) {
        memset(s->hdr, 0, sizeof(*s->hdr));
        memcpy(s->hdr->magic, KV_MAGIC, 8);
        s->hdr->version = KV_VERSION;
        s->hdr->sector = KV_SECTOR;
        s->hdr->capacity = (uint64_t)map_sz;
        s->hdr->write_pos = KV_SECTOR;
        s->hdr->record_count = 0;
        s->hdr->compact_gen = 0;
        s->hdr->sst_count = 0;
    }
    if (s->hdr->version < KV_VERSION) {
        s->hdr->sst_count = 0;
        s->hdr->version = KV_VERSION;
    }
    if (s->hdr->write_pos < KV_SECTOR) {
        s->hdr->write_pos = KV_SECTOR;
    }
    kv_build_wal_path(s->data_path, wal_path, sizeof(wal_path));
    s->wal_map = kv_mmap_file(wal_path, cap, &wal_sz);
    if (!s->wal_map) {
        munmap(s->map, s->map_size);
        free(s);
        return 0;
    }
    s->wal_map_size = wal_sz;
    s->wal_hdr = (kv_wal_header_t *)s->wal_map;
    if (memcmp(s->wal_hdr->magic, KV_WAL_MAGIC, 7) != 0) {
        memset(s->wal_hdr, 0, sizeof(*s->wal_hdr));
        memcpy(s->wal_hdr->magic, KV_WAL_MAGIC, 8);
        s->wal_hdr->capacity = (uint64_t)wal_sz;
        s->wal_hdr->write_pos = KV_SECTOR;
        s->wal_hdr->record_count = 0;
    }
    if (s->wal_hdr->write_pos < KV_SECTOR) {
        s->wal_hdr->write_pos = KV_SECTOR;
    }
    if (kv_open_sst_slots(s) != 0) {
        munmap(s->wal_map, s->wal_map_size);
        munmap(s->map, s->map_size);
        free(s);
        return 0;
    }
    kv_rebuild_mt_from_map(s, (const uint8_t *)s->map, s->hdr->capacity, s->hdr->write_pos, KV_LAYER_MAIN);
    kv_rebuild_mt_from_map(s, (const uint8_t *)s->wal_map, s->wal_hdr->capacity, s->wal_hdr->write_pos, KV_LAYER_WAL);
    for (i = 0; i < s->hdr->sst_count; i++) {
        if (s->sst_hdr[i]) {
            kv_rebuild_mt_from_map(s, (const uint8_t *)s->sst_map[i], s->sst_hdr[i]->capacity, s->sst_hdr[i]->write_pos,
                                   (uint8_t)(KV_LAYER_SST_BASE + i));
        }
    }
    return (int64_t)(uintptr_t)s;
#else
    (void)path;
    (void)capacity_bytes;
    return 0;
#endif
}

int32_t db_kv_close_c(int64_t handle) {
#if defined(__linux__) || defined(__APPLE__)
    kv_store_t *s = (kv_store_t *)(uintptr_t)handle;
    uint32_t i;
    if (!s) {
        return -1;
    }
    if (s->wal_map) {
        munmap(s->wal_map, s->wal_map_size);
    }
    for (i = 0; i < KV_SST_SLOTS; i++) {
        if (s->sst_map[i]) {
            munmap(s->sst_map[i], s->sst_map_size[i]);
        }
    }
    if (s->map) {
        munmap(s->map, s->map_size);
    }
    free(s);
    return 0;
#else
    (void)handle;
    return -1;
#endif
}

int32_t db_kv_sync_c(int64_t handle) {
#if defined(__linux__) || defined(__APPLE__)
    kv_store_t *s = (kv_store_t *)(uintptr_t)handle;
    uint32_t i;
    if (!s || !s->map) {
        return -1;
    }
    if (s->wal_map && msync(s->wal_map, s->wal_map_size, MS_SYNC) != 0) {
        return -1;
    }
    for (i = 0; i < s->hdr->sst_count && i < KV_SST_SLOTS; i++) {
        if (s->sst_map[i] && msync(s->sst_map[i], s->sst_map_size[i], MS_SYNC) != 0) {
            return -1;
        }
    }
    return msync(s->map, s->map_size, MS_SYNC) == 0 ? 0 : -1;
#else
    (void)handle;
    return -1;
#endif
}

static int32_t db_kv_append_wal(kv_store_t *s, const uint8_t *key, uint32_t key_len, const uint8_t *val,
                                uint32_t val_len, uint64_t ts_ns) {
    uint8_t *rec;
    size_t rec_len;
    int64_t off;
    if (!s || !s->wal_hdr || !s->wal_map) {
        return -1;
    }
    if (kv_serialize_record(s, key, key_len, val, val_len, ts_ns, &rec, &rec_len) != 0) {
        return -2;
    }
    off = kv_write_record_to_map((uint8_t *)s->wal_map, s->wal_hdr->capacity, &s->wal_hdr->write_pos, rec, rec_len);
    if (off < 0) {
        return -3;
    }
    s->wal_hdr->record_count++;
    kv_mt_put_ex(s, (uint64_t)off, key, key_len, KV_LAYER_WAL);
    return 0;
}

int32_t db_kv_put_c(int64_t handle, uint8_t *key, uint32_t key_len, uint8_t *val, uint32_t val_len) {
    return db_kv_append_wal((kv_store_t *)(uintptr_t)handle, key, key_len, val, val_len, 0);
}

int32_t db_kv_append_ts_c(int64_t handle, uint8_t *key, uint32_t key_len, uint8_t *val, uint32_t val_len,
                          uint64_t ts_ns) {
    return db_kv_append_wal((kv_store_t *)(uintptr_t)handle, key, key_len, val, val_len, ts_ns);
}

int32_t db_kv_get_c(int64_t handle, uint8_t *key, uint32_t key_len, uint8_t *out, uint32_t out_cap) {
#if defined(__linux__) || defined(__APPLE__)
    kv_store_t *s = (kv_store_t *)(uintptr_t)handle;
    uint64_t off;
    int32_t r;
    uint32_t i;
    const uint8_t *base;
    uint64_t cap;
    uint64_t end_off;
    if (!s || !key || !out || key_len == 0) {
        return -1;
    }
    off = kv_mt_get_off(s, key, key_len);
    if (off != 0) {
        uint32_t j;
        uint8_t layer = KV_LAYER_MAIN;
        uint32_t h = kv_hash_key(key, key_len);
        for (j = 0; j < s->mt_count; j++) {
            if (s->mt[j].key_hash == h && s->mt[j].key_len == key_len) {
                layer = s->mt[j].layer;
                off = s->mt[j].off;
                break;
            }
        }
        base = kv_layer_base_cap(s, layer, &cap);
        if (base) {
            r = kv_read_at_map(base, cap, off, key, key_len, out, out_cap);
            if (r >= 0) {
                return r;
            }
        }
    }
    r = kv_find_latest_in_map((const uint8_t *)s->wal_map, s->wal_hdr->capacity, s->wal_hdr->write_pos, KV_SECTOR,
                              key, key_len, out, out_cap, &off);
    if (r >= 0) {
        kv_mt_put_ex(s, off, key, key_len, KV_LAYER_WAL);
        return r;
    }
    r = kv_find_latest_in_map((const uint8_t *)s->map, s->hdr->capacity, s->hdr->write_pos, KV_SECTOR, key, key_len,
                              out, out_cap, &off);
    if (r >= 0) {
        kv_mt_put_ex(s, off, key, key_len, KV_LAYER_MAIN);
        return r;
    }
    for (i = s->hdr->sst_count; i > 0; i--) {
        uint32_t slot = i - 1;
        if (!s->sst_hdr[slot]) {
            continue;
        }
        end_off = s->sst_hdr[slot]->write_pos;
        r = kv_find_latest_in_map((const uint8_t *)s->sst_map[slot], s->sst_hdr[slot]->capacity, end_off, KV_SECTOR,
                                    key, key_len, out, out_cap, &off);
        if (r >= 0) {
            kv_mt_put_ex(s, off, key, key_len, (uint8_t)(KV_LAYER_SST_BASE + slot));
            return r;
        }
    }
    return -6;
#else
    (void)handle;
    (void)key;
    (void)key_len;
    (void)out;
    (void)out_cap;
    return -9;
#endif
}

/** WAL 刷入主文件（分层合并：L0 WAL → L1 main）。 */
int32_t db_kv_wal_flush_c(int64_t handle) {
#if defined(__linux__) || defined(__APPLE__)
    kv_store_t *s = (kv_store_t *)(uintptr_t)handle;
    uint64_t off;
    uint8_t *wal_base;
    uint32_t i;
    if (!s || !s->wal_hdr || s->wal_hdr->write_pos <= KV_SECTOR) {
        return 0;
    }
    wal_base = (uint8_t *)s->wal_map;
    off = KV_SECTOR;
    while (off < s->wal_hdr->write_pos) {
        const uint8_t *p = wal_base + off;
        uint32_t rmagic, rlen;
        memcpy(&rmagic, p, 4);
        memcpy(&rlen, p + 4, 4);
        if (rmagic != KV_REC_MAGIC || rlen < 24 || off + rlen > s->wal_hdr->write_pos) {
            break;
        }
        if (off + rlen > s->hdr->capacity) {
            return -3;
        }
        memcpy((uint8_t *)s->map + s->hdr->write_pos, p, rlen);
        s->hdr->write_pos += rlen;
        s->hdr->record_count++;
        off += rlen;
    }
    s->wal_hdr->write_pos = KV_SECTOR;
    s->wal_hdr->record_count = 0;
    kv_mt_clear(s);
    kv_rebuild_mt_from_map(s, (const uint8_t *)s->map, s->hdr->capacity, s->hdr->write_pos, KV_LAYER_MAIN);
    for (i = 0; i < s->hdr->sst_count; i++) {
        if (s->sst_hdr[i]) {
            kv_rebuild_mt_from_map(s, (const uint8_t *)s->sst_map[i], s->sst_hdr[i]->capacity, s->sst_hdr[i]->write_pos,
                                   (uint8_t)(KV_LAYER_SST_BASE + i));
        }
    }
    return msync(s->map, s->map_size, MS_SYNC) == 0 ? 0 : -4;
#else
    (void)handle;
    return -9;
#endif
}

/** LSM 压实：主文件去重保留最新 key，清空 WAL。 */
int32_t db_kv_compact_c(int64_t handle) {
#if defined(__linux__) || defined(__APPLE__)
    kv_store_t *s = (kv_store_t *)(uintptr_t)handle;
    uint64_t *live_offs;
    uint32_t live_n;
    uint32_t i;
    uint8_t *main_base;
    uint8_t *compact_buf;
    size_t compact_len;
    size_t compact_cap;
    if (!s || !s->hdr) {
        return -1;
    }
    (void)db_kv_wal_flush_c(handle);
    kv_mt_clear(s);
    kv_rebuild_mt_from_map(s, (const uint8_t *)s->map, s->hdr->capacity, s->hdr->write_pos, KV_LAYER_MAIN);
    live_offs = (uint64_t *)calloc(KV_MT_CAP, sizeof(uint64_t));
    if (!live_offs) {
        return -2;
    }
    live_n = s->mt_count;
    for (i = 0; i < s->mt_count; i++) {
        live_offs[i] = s->mt[i].off;
    }
    compact_cap = (size_t)(s->hdr->write_pos - KV_SECTOR);
    if (compact_cap == 0) {
        free(live_offs);
        return 0;
    }
    compact_buf = (uint8_t *)malloc(compact_cap);
    if (!compact_buf) {
        free(live_offs);
        return -2;
    }
    compact_len = 0;
    main_base = (uint8_t *)s->map;
    for (i = 0; i < live_n; i++) {
        const uint8_t *p = main_base + live_offs[i];
        uint32_t rlen;
        memcpy(&rlen, p + 4, 4);
        if (rlen >= 24 && compact_len + rlen <= compact_cap) {
            memcpy(compact_buf + compact_len, p, rlen);
            compact_len += rlen;
        }
    }
    free(live_offs);
    memset(main_base + KV_SECTOR, 0, (size_t)(s->hdr->capacity - KV_SECTOR));
    memcpy(main_base + KV_SECTOR, compact_buf, compact_len);
    free(compact_buf);
    s->hdr->write_pos = KV_SECTOR + (uint64_t)compact_len;
    s->hdr->record_count = live_n;
    s->hdr->compact_gen++;
    kv_mt_clear(s);
    kv_rebuild_mt_from_map(s, main_base, s->hdr->capacity, s->hdr->write_pos, KV_LAYER_MAIN);
    if (kv_freeze_main_to_sst(s) != 0) {
        return -4;
    }
    kv_mt_clear(s);
    kv_rebuild_mt_from_map(s, main_base, s->hdr->capacity, s->hdr->write_pos, KV_LAYER_MAIN);
    for (i = 0; i < s->hdr->sst_count; i++) {
        if (s->sst_hdr[i]) {
            kv_rebuild_mt_from_map(s, (const uint8_t *)s->sst_map[i], s->sst_hdr[i]->capacity, s->sst_hdr[i]->write_pos,
                                   (uint8_t)(KV_LAYER_SST_BASE + i));
        }
    }
    if (s->wal_hdr) {
        s->wal_hdr->write_pos = KV_SECTOR;
        s->wal_hdr->record_count = 0;
    }
    return msync(s->map, s->map_size, MS_SYNC) == 0 ? 0 : -3;
#else
    (void)handle;
    return -9;
#endif
}

uint64_t db_kv_compact_gen_c(int64_t handle) {
    kv_store_t *s = (kv_store_t *)(uintptr_t)handle;
    return s && s->hdr ? s->hdr->compact_gen : 0;
}

uint64_t db_kv_wal_bytes_c(int64_t handle) {
    kv_store_t *s = (kv_store_t *)(uintptr_t)handle;
    if (!s || !s->wal_hdr || s->wal_hdr->write_pos <= KV_SECTOR) {
        return 0;
    }
    return s->wal_hdr->write_pos - KV_SECTOR;
}

/** 当前已冻结 SST 层数（L2+ 侧车 *.sst.N）。 */
uint32_t db_kv_sst_level_count_c(int64_t handle) {
    kv_store_t *s = (kv_store_t *)(uintptr_t)handle;
    return s && s->hdr ? s->hdr->sst_count : 0;
}

int32_t db_kv_smoke_c(uint8_t *path) {
#if defined(__linux__) || defined(__APPLE__)
    int64_t h;
    uint8_t key[4] = {'t', 'i', 'c', 'k'};
    uint8_t val[8] = {1, 2, 3, 4, 5, 6, 7, 8};
    uint8_t out[16];
    int32_t n;
    h = db_kv_open_c(path, 65536);
    if (h == 0) {
        return -1;
    }
    if (db_kv_append_ts_c(h, key, 4, val, 8, 123456789u) != 0) {
        db_kv_close_c(h);
        return -2;
    }
    n = db_kv_get_c(h, key, 4, out, 16);
    if (n != 8 || memcmp(out, val, 8) != 0) {
        db_kv_close_c(h);
        return -3;
    }
    if (db_kv_wal_flush_c(h) != 0) {
        db_kv_close_c(h);
        return -4;
    }
    if (db_kv_compact_c(h) != 0) {
        db_kv_close_c(h);
        return -5;
    }
    if (db_kv_sst_level_count_c(h) == 0) {
        db_kv_close_c(h);
        return -8;
    }
    n = db_kv_get_c(h, key, 4, out, 16);
    if (n != 8 || memcmp(out, val, 8) != 0) {
        db_kv_close_c(h);
        return -6;
    }
    /* 第二轮写入 → compact → 验证多级 SST 仍可读 */
    val[0] = 42;
    if (db_kv_append_ts_c(h, key, 4, val, 8, 999u) != 0) {
        db_kv_close_c(h);
        return -9;
    }
    if (db_kv_wal_flush_c(h) != 0 || db_kv_compact_c(h) != 0) {
        db_kv_close_c(h);
        return -10;
    }
    n = db_kv_get_c(h, key, 4, out, 16);
    if (n != 8 || out[0] != 42) {
        db_kv_close_c(h);
        return -11;
    }
    if (db_kv_sync_c(h) != 0) {
        db_kv_close_c(h);
        return -7;
    }
    db_kv_close_c(h);
    return 0;
#else
    (void)path;
    return -9;
#endif
}

int32_t db_kv_wal_compact_smoke_c(uint8_t *path) {
    return db_kv_smoke_c(path);
}
