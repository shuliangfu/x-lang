/**
 * std/hash/hash.c — SipHash-2-4 Hasher（对标 Zig std.hash、Rust std::hash::Hasher）
 *
 * 【文件职责】
 * Hasher 状态：hash_sip_new_c（默认 key）、hash_sip_write_u32/u64/bytes、hash_sip_finish_c、hash_sip_free_c。
 * 算法 SipHash-2-4，64-bit 输出；与 HashMap 等可复用。
 * STD-056：统一 Hasher 工厂（SipHash / FNV-1a64 占位 aHash）+ SHUX_HASH_ALGO。
 *
 * 【所属模块/组件】
 * 标准库 std.hash；与 std/hash/mod.sx 同属一模块。无外部依赖。
 */

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

void hash_sip_write_bytes_c(void *h, const uint8_t *ptr, int32_t len);

#define ROTL64(x, s) (((x) << (s)) | ((x) >> (64 - (s))))

#define SIPROUND do { \
  v0 += v1; v2 += v3; \
  v1 = ROTL64(v1, 13); v3 = ROTL64(v3, 16); \
  v1 ^= v0; v3 ^= v2; \
  v0 = ROTL64(v0, 32); \
  v2 += v1; v0 += v3; \
  v1 = ROTL64(v1, 17); v3 = ROTL64(v3, 21); \
  v1 ^= v2; v3 ^= v0; \
  v2 = ROTL64(v2, 32); \
} while (0)

typedef struct {
  uint64_t v0, v1, v2, v3;
  uint8_t  buf[8];
  int      buflen;
  uint64_t total_len; /* 已写入总字节数，用于 finish 时编码长度 */
} hash_sip_ctx_t;

static uint64_t read64le(const uint8_t *p) {
  return (uint64_t)p[0] | ((uint64_t)p[1]<<8) | ((uint64_t)p[2]<<16) | ((uint64_t)p[3]<<24)
       | ((uint64_t)p[4]<<32) | ((uint64_t)p[5]<<40) | ((uint64_t)p[6]<<48) | ((uint64_t)p[7]<<56);
}

static void sip_compress(hash_sip_ctx_t *ctx, uint64_t m) {
  uint64_t v0 = ctx->v0, v1 = ctx->v1, v2 = ctx->v2, v3 = ctx->v3;
  v3 ^= m;
  SIPROUND; SIPROUND;
  v0 ^= m;
  ctx->v0 = v0; ctx->v1 = v1; ctx->v2 = v2; ctx->v3 = v3;
}

/** 创建 Hasher 状态；默认 key (0,0)。失败返回 NULL。 */
void *hash_sip_new_c(void) {
  hash_sip_ctx_t *ctx = (hash_sip_ctx_t *)malloc(sizeof(hash_sip_ctx_t));
  if (!ctx) return NULL;
  /* SipHash 初始向量 ^ key (k0=0, k1=0) */
  ctx->v0 = 0x736f6d6570736575ULL;
  ctx->v1 = 0x646f72616e646f6dULL;
  ctx->v2 = 0x6c7967656e657261ULL;
  ctx->v3 = 0x7465646279746573ULL;
  ctx->buflen = 0;
  ctx->total_len = 0;
  return (void *)ctx;
}

/** 写入 4 字节（小端）。 */
void hash_sip_write_u32_c(void *h, uint32_t x) {
  hash_sip_ctx_t *ctx = (hash_sip_ctx_t *)h;
  if (!ctx) return;
  uint8_t b[4];
  b[0] = (uint8_t)(x); b[1] = (uint8_t)(x>>8); b[2] = (uint8_t)(x>>16); b[3] = (uint8_t)(x>>24);
  hash_sip_write_bytes_c(h, b, 4);
}

/** 写入 8 字节（小端）。 */
void hash_sip_write_u64_c(void *h, uint64_t x) {
  hash_sip_ctx_t *ctx = (hash_sip_ctx_t *)h;
  if (!ctx) return;
  uint8_t b[8];
  b[0] = (uint8_t)(x); b[1] = (uint8_t)(x>>8); b[2] = (uint8_t)(x>>16); b[3] = (uint8_t)(x>>24);
  b[4] = (uint8_t)(x>>32); b[5] = (uint8_t)(x>>40); b[6] = (uint8_t)(x>>48); b[7] = (uint8_t)(x>>56);
  hash_sip_write_bytes_c(h, b, 8);
}

/** 写入任意字节。 */
void hash_sip_write_bytes_c(void *h, const uint8_t *ptr, int32_t len) {
  hash_sip_ctx_t *ctx = (hash_sip_ctx_t *)h;
  if (!ctx || !ptr || len <= 0) return;
  ctx->total_len += (uint64_t)len;
  int i = 0;
  if (ctx->buflen > 0) {
    while (ctx->buflen < 8 && i < len) { ctx->buf[ctx->buflen++] = ptr[i++]; }
    if (ctx->buflen == 8) {
      sip_compress(ctx, read64le(ctx->buf));
      ctx->buflen = 0;
    }
  }
  while (i + 8 <= len) {
    sip_compress(ctx, read64le(ptr + i));
    i += 8;
  }
  while (i < len) ctx->buf[ctx->buflen++] = ptr[i++];
}

/** 完成哈希，返回 64-bit 结果；调用后 ctx 仍有效可继续写（如需多次 finish 则需重置或新建）。 */
uint64_t hash_sip_finish_c(void *h) {
  hash_sip_ctx_t *ctx = (hash_sip_ctx_t *)h;
  if (!ctx) return 0;
  uint64_t len_bits = ctx->total_len * 8;
  int i;
  for (i = ctx->buflen; i < 8; i++)
    ctx->buf[i] = (uint8_t)(len_bits >> (i * 8));
  sip_compress(ctx, read64le(ctx->buf));
  {
    uint64_t v0 = ctx->v0, v1 = ctx->v1, v2 = ctx->v2, v3 = ctx->v3;
    v2 ^= 0xff;
    SIPROUND; SIPROUND; SIPROUND; SIPROUND;
    return v0 ^ v1 ^ v2 ^ v3;
  }
}

/** 释放 Hasher 状态。 */
void hash_sip_free_c(void *h) {
  free(h);
}

/** 单次调用：对 ptr[0..len) 做 SipHash-2-4，key 默认 0,0，返回 u64。 */
uint64_t hash_sip_bytes_c(const uint8_t *ptr, int32_t len) {
  void *h = hash_sip_new_c();
  if (!h) return 0;
  hash_sip_write_bytes_c(h, ptr, len);
  uint64_t r = hash_sip_finish_c(h);
  hash_sip_free_c(h);
  return r;
}

/** Hasher 算法枚举（与 mod.sx HASHER_* 一致）。 */
#define HASHER_SIPHASH 0
#define HASHER_AHASH 1
#define HASHER_XXHASH 2

/** xxHash64 常量（STD-105）。 */
#define XXH64_PRIME1 11400714785074694791ULL
#define XXH64_PRIME2 14029467366897019727ULL
#define XXH64_PRIME3 1609587929392839161ULL
#define XXH64_PRIME4 9650029242287828579ULL
#define XXH64_PRIME5 2870177450012600261ULL

/** xxHash64 流式状态。 */
typedef struct {
  uint64_t total_len;
  uint64_t v1;
  uint64_t v2;
  uint64_t v3;
  uint64_t v4;
  uint64_t mem64;
  uint32_t memsize;
  uint64_t seed;
} hash_xxh64_ctx_t;

/** 统一 Hasher 上下文。 */
typedef struct {
  int32_t algo;
  union {
    hash_sip_ctx_t sip;
    uint64_t fnv;
    hash_xxh64_ctx_t xxh;
  } st;
} hash_unified_ctx_t;

static uint64_t hash_xxh64_rotl(uint64_t x, int r) {
  return (x << r) | (x >> (64 - r));
}

static uint64_t hash_xxh64_round(uint64_t acc, uint64_t input) {
  acc += input * XXH64_PRIME2;
  acc = hash_xxh64_rotl(acc, 31);
  acc *= XXH64_PRIME1;
  return acc;
}

static uint64_t hash_xxh64_merge_round(uint64_t acc, uint64_t val) {
  val = hash_xxh64_round(0, val);
  acc ^= val;
  acc = acc * XXH64_PRIME1 + XXH64_PRIME4;
  return acc;
}

static uint64_t hash_xxh64_avalanche(uint64_t h64) {
  h64 ^= h64 >> 33;
  h64 *= XXH64_PRIME2;
  h64 ^= h64 >> 29;
  h64 *= XXH64_PRIME3;
  h64 ^= h64 >> 32;
  return h64;
}

/** 重置 xxHash64 流式状态。 */
static void hash_xxh64_reset(hash_xxh64_ctx_t *s, uint64_t seed) {
  s->seed = seed;
  s->v1 = seed + XXH64_PRIME1 + XXH64_PRIME2;
  s->v2 = seed + XXH64_PRIME2;
  s->v3 = seed;
  s->v4 = seed - XXH64_PRIME1;
  s->total_len = 0;
  s->memsize = 0;
  s->mem64 = 0;
}

/** xxHash64 流式更新。 */
static void hash_xxh64_update(hash_xxh64_ctx_t *s, const uint8_t *input, size_t len) {
  size_t p = 0;
  if (!s || (!input && len > 0)) return;
  s->total_len += len;
  if (s->memsize + len < 32) {
    memcpy(((uint8_t *)&s->mem64) + s->memsize, input, len);
    s->memsize += (uint32_t)len;
    return;
  }
  if (s->memsize > 0) {
    uint8_t buf[32];
    memcpy(buf, &s->mem64, s->memsize);
    memcpy(buf + s->memsize, input, 32 - s->memsize);
    s->v1 = hash_xxh64_round(s->v1, read64le(buf));
    s->v2 = hash_xxh64_round(s->v2, read64le(buf + 8));
    s->v3 = hash_xxh64_round(s->v3, read64le(buf + 16));
    s->v4 = hash_xxh64_round(s->v4, read64le(buf + 24));
    p = 32 - s->memsize;
    s->memsize = 0;
  }
  while (p + 32 <= len) {
    s->v1 = hash_xxh64_round(s->v1, read64le(input + p));
    s->v2 = hash_xxh64_round(s->v2, read64le(input + p + 8));
    s->v3 = hash_xxh64_round(s->v3, read64le(input + p + 16));
    s->v4 = hash_xxh64_round(s->v4, read64le(input + p + 24));
    p += 32;
  }
  if (p < len) {
    s->memsize = (uint32_t)(len - p);
    memcpy(&s->mem64, input + p, s->memsize);
  }
}

/** xxHash64 流式完成。 */
static uint64_t hash_xxh64_digest(const hash_xxh64_ctx_t *s) {
  uint64_t h64;
  const uint8_t *p;
  int i;
  if (!s) return 0;
  if (s->total_len >= 32) {
    h64 = hash_xxh64_rotl(s->v1, 1) + hash_xxh64_rotl(s->v2, 7) + hash_xxh64_rotl(s->v3, 12) +
          hash_xxh64_rotl(s->v4, 18);
    h64 = hash_xxh64_merge_round(h64, s->v1);
    h64 = hash_xxh64_merge_round(h64, s->v2);
    h64 = hash_xxh64_merge_round(h64, s->v3);
    h64 = hash_xxh64_merge_round(h64, s->v4);
  } else {
    h64 = s->seed + XXH64_PRIME5;
  }
  h64 += (uint64_t)s->total_len;
  p = (const uint8_t *)&s->mem64;
  i = 0;
  while (i + 8 <= (int)s->memsize) {
    h64 = hash_xxh64_round(h64, read64le(p + i));
    i += 8;
  }
  if (i + 4 <= (int)s->memsize) {
    h64 ^= (uint64_t)read64le(p + i) & 0xffffffffULL;
    h64 = hash_xxh64_rotl(h64, 23) * XXH64_PRIME2 + XXH64_PRIME3;
    i += 4;
  }
  while (i < (int)s->memsize) {
    h64 ^= (uint64_t)p[i] * XXH64_PRIME5;
    h64 = hash_xxh64_rotl(h64, 11) * XXH64_PRIME1;
    i++;
  }
  return hash_xxh64_avalanche(h64);
}

/** 一次性 xxHash64（指定 seed）。 */
uint64_t hash_xxhash64_seed_bytes_c(const uint8_t *ptr, int32_t len, uint64_t seed) {
  hash_xxh64_ctx_t s;
  hash_xxh64_reset(&s, seed);
  if (len > 0 && ptr) hash_xxh64_update(&s, ptr, (size_t)len);
  return hash_xxh64_digest(&s);
}

/** 一次性 xxHash64（seed=0）。 */
uint64_t hash_xxhash64_bytes_c(const uint8_t *ptr, int32_t len) {
  return hash_xxhash64_seed_bytes_c(ptr, len, 0);
}

/** FNV-1a64 单块写入（aHash 占位）。 */
static void hash_fnv_write_bytes(uint64_t *h, const uint8_t *ptr, int32_t len) {
  const uint64_t prime = 1099511628211ULL;
  int32_t i;
  if (!h || !ptr || len <= 0) return;
  for (i = 0; i < len; i++) {
    *h ^= (uint64_t)ptr[i];
    *h *= prime;
  }
}

/** 读取 SHUX_HASH_ALGO 环境变量；默认 HASHER_SIPHASH。 */
int32_t hash_default_algo_c(void) {
  const char *v = getenv("SHUX_HASH_ALGO");
  if (!v || !v[0]) return HASHER_SIPHASH;
  if (strcmp(v, "1") == 0 || strcmp(v, "ahash") == 0) return HASHER_AHASH;
  if (strcmp(v, "2") == 0 || strcmp(v, "xxhash") == 0 || strcmp(v, "x") == 0) return HASHER_XXHASH;
  return HASHER_SIPHASH;
}

/** Map/Set 推荐 Hasher：SipHash（STD-148）。 */
int32_t hash_recommend_hasher_map_c(void) { return HASHER_SIPHASH; }

/** 内部去重/快速路径推荐：xxHash64（STD-148）。 */
int32_t hash_recommend_hasher_fast_c(void) { return HASHER_XXHASH; }

/** 按算法创建统一 Hasher；失败 NULL。 */
void *hash_unified_new_c(int32_t algo) {
  hash_unified_ctx_t *u = (hash_unified_ctx_t *)malloc(sizeof(hash_unified_ctx_t));
  if (!u) return NULL;
  u->algo = algo;
  if (algo == HASHER_SIPHASH) {
    u->st.sip.v0 = 0x736f6d6570736575ULL;
    u->st.sip.v1 = 0x646f72616e646f6dULL;
    u->st.sip.v2 = 0x6c7967656e657261ULL;
    u->st.sip.v3 = 0x7465646279746573ULL;
    u->st.sip.buflen = 0;
    u->st.sip.total_len = 0;
  } else if (algo == HASHER_AHASH) {
    u->st.fnv = 14695981039346656037ULL;
  } else if (algo == HASHER_XXHASH) {
    hash_xxh64_reset(&u->st.xxh, 0);
  } else {
    free(u);
    return NULL;
  }
  return (void *)u;
}

/** 统一 Hasher 写入字节。 */
void hash_unified_write_bytes_c(void *h, const uint8_t *ptr, int32_t len) {
  hash_unified_ctx_t *u = (hash_unified_ctx_t *)h;
  if (!u || !ptr || len <= 0) return;
  if (u->algo == HASHER_SIPHASH) {
    hash_sip_write_bytes_c(&u->st.sip, ptr, len);
  } else if (u->algo == HASHER_AHASH) {
    hash_fnv_write_bytes(&u->st.fnv, ptr, len);
  } else if (u->algo == HASHER_XXHASH) {
    hash_xxh64_update(&u->st.xxh, ptr, (size_t)len);
  }
}

/** 统一 Hasher 写入 u32（小端）。 */
void hash_unified_write_u32_c(void *h, uint32_t x) {
  uint8_t b[4];
  b[0] = (uint8_t)(x);
  b[1] = (uint8_t)(x >> 8);
  b[2] = (uint8_t)(x >> 16);
  b[3] = (uint8_t)(x >> 24);
  hash_unified_write_bytes_c(h, b, 4);
}

/** 统一 Hasher 完成并返回 u64 摘要。 */
uint64_t hash_unified_finish_c(void *h) {
  hash_unified_ctx_t *u = (hash_unified_ctx_t *)h;
  if (!u) return 0;
  if (u->algo == HASHER_SIPHASH) return hash_sip_finish_c(&u->st.sip);
  if (u->algo == HASHER_AHASH) return u->st.fnv;
  if (u->algo == HASHER_XXHASH) return hash_xxh64_digest(&u->st.xxh);
  return 0;
}

/** 释放统一 Hasher。 */
void hash_unified_free_c(void *h) {
  free(h);
}

/** STD-056 C 烟测：aHash("abc") 金样 + SipHash ≠ aHash。 */
int32_t hash_hasher_switch_smoke_c(void) {
  const uint8_t abc[] = "abc";
  void *ha;
  void *hs;
  uint64_t ra;
  uint64_t rs;
  ha = hash_unified_new_c(HASHER_AHASH);
  if (!ha) return 1;
  hash_unified_write_bytes_c(ha, abc, 3);
  ra = hash_unified_finish_c(ha);
  hash_unified_free_c(ha);
  if (ra != 0xe71fa2190541574bULL) return 2;
  hs = hash_unified_new_c(HASHER_SIPHASH);
  if (!hs) return 3;
  hash_unified_write_bytes_c(hs, abc, 3);
  rs = hash_unified_finish_c(hs);
  hash_unified_free_c(hs);
  if (rs == ra) return 4;
  return 0;
}

/** STD-105 C 烟测：xxHash64 空串与 abc 金样。 */
int32_t hash_xxhash_smoke_c(void) {
  const uint8_t abc[] = "abc";
  if (hash_xxhash64_bytes_c(NULL, 0) != 0xef46db3751d8e999ULL) return 1;
  if (hash_xxhash64_bytes_c(abc, 3) != 0x44bc2cf5ad770999ULL) return 2;
  return 0;
}

/** STD-148 C 烟测：推荐 Hasher + 三族摘要互异。 */
int32_t hash_default_strategy_smoke_c(void) {
  const uint8_t abc[] = "abc";
  void *hs;
  void *ha;
  void *hx;
  uint64_t rs;
  uint64_t ra;
  uint64_t rx;
  if (hash_recommend_hasher_map_c() != HASHER_SIPHASH) return 1;
  if (hash_recommend_hasher_fast_c() != HASHER_XXHASH) return 2;
  if (hash_default_algo_c() != HASHER_SIPHASH) return 3;
  hs = hash_unified_new_c(HASHER_SIPHASH);
  ha = hash_unified_new_c(HASHER_AHASH);
  hx = hash_unified_new_c(HASHER_XXHASH);
  if (!hs || !ha || !hx) return 4;
  hash_unified_write_bytes_c(hs, abc, 3);
  hash_unified_write_bytes_c(ha, abc, 3);
  hash_unified_write_bytes_c(hx, abc, 3);
  rs = hash_unified_finish_c(hs);
  ra = hash_unified_finish_c(ha);
  rx = hash_unified_finish_c(hx);
  hash_unified_free_c(hs);
  hash_unified_free_c(ha);
  hash_unified_free_c(hx);
  if (rs == 0 || ra == 0 || rx == 0) return 5;
  if (rs == ra || rs == rx || ra == rx) return 6;
  if (hash_xxhash64_bytes_c(abc, 3) != rx) return 7;
  return 0;
}
