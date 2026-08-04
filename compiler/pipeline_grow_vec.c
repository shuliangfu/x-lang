/* pipeline_grow_vec.c — GrowVec 可增长定长元素向量（自 ast_pool.c 抽出）
 *
 * 大块 (>= GROW_VEC_MMAP_THRESH 1MiB) 走匿名 mmap，grow_vec_free 可 munmap 立即归还 RSS
 * （xlang check 峰值内存根因修复）；小块留 malloc/calloc。
 * alloc_bytes/dealloc_bytes/init/free/ensure/at/push/copy_append。
 * 纯叶工具：仅依赖 mmap/malloc/calloc/realloc/memcpy/memset（先于此 include）。
 * 同 TU #include（ast_pool 早期声明区，所有 sidecar typedef 与 GrowVec 用户在其后）。 */

/**
 * Growable vector of fixed-size elements.
 *
 * PLATFORM: SHARED — large buffers (>= GROW_VEC_MMAP_THRESH) use anonymous
 * mmap so grow_vec_free can munmap and return RSS immediately. Small buffers
 * stay on malloc/calloc. This is the root fix for `xlang check` peak RSS:
 * sequential mega-dep parses must not leave multi-GB high-water on macOS
 * (system free keeps pages) or Ubuntu (zone freelist).
 */
typedef struct {
  uint8_t *data;
  int32_t cap;
  int32_t len;
  size_t elem_sz;
  /** 1 = data from mmap(MAP_ANON); free via munmap. 0 = malloc/calloc/realloc. */
  int32_t mmap_backed;
} GrowVec;

/** Byte size at which GrowVec switches to mmap (1 MiB). */
#ifndef GROW_VEC_MMAP_THRESH
#define GROW_VEC_MMAP_THRESH ((size_t)(1024 * 1024))
#endif

/**
 * Allocate nbytes for a GrowVec. Uses mmap for large blocks.
 * @param nbytes size in bytes; must be > 0
 * @param out_mmap set to 1 if mmap, 0 if calloc
 * @return pointer or NULL
 */
static void *grow_vec_alloc_bytes(size_t nbytes, int32_t *out_mmap) {
  if (out_mmap)
    *out_mmap = 0;
  if (nbytes == 0)
    return NULL;
#if defined(__APPLE__) || defined(__linux__)
  if (nbytes >= GROW_VEC_MMAP_THRESH) {
    void *p = mmap(NULL, nbytes, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANON, -1, 0);
    if (p != MAP_FAILED) {
      if (out_mmap)
        *out_mmap = 1;
      return p;
    }
    /* fall through to calloc on mmap failure */
  }
#endif
  return calloc(1, nbytes);
}

/**
 * Deallocate GrowVec data (mmap munmap or free).
 * @param p data pointer; may be null
 * @param nbytes size when mmap_backed (ignored for free)
 * @param mmap_backed 1 if p is mmap
 */
static void grow_vec_dealloc_bytes(void *p, size_t nbytes, int32_t mmap_backed) {
  if (!p)
    return;
#if defined(__APPLE__) || defined(__linux__)
  if (mmap_backed) {
    if (nbytes > 0)
      (void)munmap(p, nbytes);
    return;
  }
#else
  (void)nbytes;
  (void)mmap_backed;
#endif
  free(p);
}

static int grow_vec_init(GrowVec *v, size_t elem_sz, int32_t initial_cap) {
  size_t nbytes;
  int32_t mm = 0;
  v->data = NULL;
  v->cap = 0;
  v->len = 0;
  v->elem_sz = elem_sz;
  v->mmap_backed = 0;
  /* Default to the smaller INIT_CAP (256) instead of the grow step (4096)
   * so that fresh pools do not zerofill 4.3 MB per ArenaSidecar. Pools that
   * outgrow INIT_CAP will realloc by AST_POOL_GROW (4096) elements. */
  if (initial_cap <= 0)
    initial_cap = AST_POOL_INIT_CAP;
  nbytes = (size_t)initial_cap * elem_sz;
  v->data = (uint8_t *)grow_vec_alloc_bytes(nbytes, &mm);
  if (!v->data)
    return 0;
  v->mmap_backed = mm;
  v->cap = initial_cap;
  return 1;
}

static void grow_vec_free(GrowVec *v) {
  if (v && v->data) {
    size_t nbytes = (size_t)v->cap * v->elem_sz;
    grow_vec_dealloc_bytes(v->data, nbytes, v->mmap_backed);
    v->data = NULL;
  }
  if (v) {
    v->cap = 0;
    v->len = 0;
    v->mmap_backed = 0;
  }
}

/**
 * Ensure capacity for one more element. Returns 1 on success.
 *
 * Growth policy (PLATFORM: SHARED):
 * - Small heap buffers: linear step AST_POOL_GROW (realloc often in-place).
 * - mmap-backed / large: **double** capacity (geometric). mmap cannot grow
 *   in place; linear +4096 caused O(n^2) full-array memcpy and made
 *   `xlang check main.x` appear hung (codegen dep ~1.2M exprs → ~100GB copy).
 * wave1242b: geometric mmap growth fix after wave1242 mmap RSS work.
 */
static int grow_vec_ensure(GrowVec *v) {
  int32_t need;
  int32_t nc;
  int32_t old_cap;
  int32_t mm = 0;
  size_t old_bytes;
  size_t new_bytes;
  uint8_t *p;
  if (!v)
    return 0;
  need = v->len + 1;
  if (need <= v->cap)
    return 1;
  old_cap = v->cap;
  nc = v->cap > 0 ? v->cap : AST_POOL_GROW;
  /* Will this resize be mmap-path? Prefer geometric growth then. */
  if (v->mmap_backed ||
      (size_t)need * v->elem_sz >= GROW_VEC_MMAP_THRESH ||
      (size_t)nc * v->elem_sz >= GROW_VEC_MMAP_THRESH) {
    while (nc < need) {
      if (nc > 1073741823) { /* prevent i32 overflow */
        nc = need;
        break;
      }
      nc = nc * 2;
    }
    if (nc < need)
      nc = need;
  } else {
    while (nc < need)
      nc += AST_POOL_GROW;
  }
  old_bytes = (size_t)old_cap * v->elem_sz;
  new_bytes = (size_t)nc * v->elem_sz;
  /*
   * Large path: mmap so free can munmap (RSS). Always alloc+copy+dealloc
   * (no realloc on mmap). Geometric nc above keeps total copy O(n).
   */
  if (v->mmap_backed || new_bytes >= GROW_VEC_MMAP_THRESH) {
    p = (uint8_t *)grow_vec_alloc_bytes(new_bytes, &mm);
    if (!p)
      return 0;
    if (v->data && old_bytes > 0)
      memcpy(p, v->data, old_bytes);
    /* new tail already zero from mmap/calloc */
    grow_vec_dealloc_bytes(v->data, old_bytes, v->mmap_backed);
    v->data = p;
    v->mmap_backed = mm;
    v->cap = nc;
    return 1;
  }
  p = (uint8_t *)realloc(v->data, new_bytes);
  if (!p)
    return 0;
  memset(p + old_bytes, 0, new_bytes - old_bytes);
  v->data = p;
  v->mmap_backed = 0;
  v->cap = nc;
  return 1;
}

static void *grow_vec_at(GrowVec *v, int32_t idx) {
  if (!v || !v->data || idx < 0 || idx >= v->len)
    return NULL;
  return v->data + (size_t)idx * v->elem_sz;
}

/** 追加零初始化元素，返回新下标；失败返回 -1。 */
static int32_t grow_vec_push(GrowVec *v) {
  int32_t idx;
  if (!grow_vec_ensure(v))
    return -1;
  idx = v->len;
  memset(v->data + (size_t)idx * v->elem_sz, 0, v->elem_sz);
  v->len++;
  return idx;
}

/** Append all elements of src onto dst (caller may reset dst first).
 *  PLATFORM: SHARED — used by onefunc_copy_sidecar + dep_ctx empty_param backup. */
static void grow_vec_copy_append(GrowVec *dst, GrowVec *src) {
  int32_t i;
  if (!dst || !src)
    return;
  for (i = 0; i < src->len; i++) {
    void *ps = grow_vec_at(src, i);
    void *pd;
    if (grow_vec_push(dst) < 0)
      return;
    pd = grow_vec_at(dst, dst->len - 1);
    if (ps && pd)
      memcpy(pd, ps, src->elem_sz);
  }
}
