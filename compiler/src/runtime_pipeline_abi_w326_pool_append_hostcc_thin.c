/*
 * DIG s225: host-cc twin for w326_pool_append_pos.
 *
 * Tip-asm of runtime_pipeline_abi_block_domain_thin.x computes the
 * three memmove args with complex i64 casts; tipU clobbers them
 * (observed: esz/data/len correct, but dst/src/n wrong → SIGBUS with
 * n≈84KB while dst-src != esz). Blocks tip -E src/parser/parser.x
 * after s224 got past import park/commit.
 *
 * Authority matches seeds/runtime_pipeline_abi.from_x.c
 * block_pool_append_pos + GrowVec LE layout data@0 cap@8 len@12
 * elem_sz@16. PLATFORM: SHARED host-cc first-wins.
 */
#include <stdint.h>
#include <string.h>

typedef struct {
  uint8_t *data;
  int32_t cap;
  int32_t len;
  size_t elem_sz;
  int32_t mmap_backed;
} GrowVec;

extern uint8_t *pipeline_arena_block_ptr(uint8_t *a, int32_t ref);
extern int32_t grow_vec_push(GrowVec *v);
extern int32_t grow_vec_ensure(GrowVec *v);

enum {
  W326_ARENA_NUM_BLOCKS = 8,
  W326_GV_LEN = 12
};

/**
 * LE i32 load at byte offset (matches tip w326_load).
 */
static int32_t w326_load_i32(uint8_t *base, int32_t off) {
  int32_t v;
  if (base == 0) {
    return 0;
  }
  memcpy(&v, base + (size_t)off, sizeof(v));
  return v;
}

/**
 * LE i32 store at byte offset (matches tip w326_store).
 */
static void w326_store_i32(uint8_t *base, int32_t off, int32_t v) {
  if (base == 0) {
    return;
  }
  memcpy(base + (size_t)off, &v, sizeof(v));
}

/**
 * Insert-and-shift pool append for per-block contiguous ranges.
 * @param a arena bytes
 * @param br 1-based block ref
 * @param pool GrowVec* as bytes (stmt_order / lets / …)
 * @param base_off byte offset of the block's base field
 * @param num_before current count in this block's range
 * @return absolute pool index, or -1 on failure
 */
int32_t w326_pool_append_pos(uint8_t *a, int32_t br, uint8_t *pool,
                             int32_t base_off, int32_t num_before) {
  GrowVec *gv;
  uint8_t *b;
  uint8_t *ob;
  int32_t base_field;
  int32_t abs_pos;
  int32_t move_count;
  int32_t bi;
  int32_t nblocks;
  int32_t ob_base;
  size_t esz;

  if (a == 0 || pool == 0 || br <= 0) {
    return -1;
  }
  b = pipeline_arena_block_ptr(a, br);
  if (b == 0) {
    return -1;
  }
  gv = (GrowVec *)(void *)pool;
  base_field = w326_load_i32(b, base_off);
  if (num_before == 0) {
    abs_pos = grow_vec_push(gv);
    if (abs_pos < 0) {
      return -1;
    }
    w326_store_i32(b, base_off, abs_pos);
    return abs_pos;
  }
  abs_pos = base_field + num_before;
  if (abs_pos >= gv->len) {
    abs_pos = grow_vec_push(gv);
    if (abs_pos < 0) {
      return -1;
    }
    return abs_pos;
  }
  if (grow_vec_ensure(gv) == 0) {
    return -1;
  }
  esz = gv->elem_sz;
  move_count = gv->len - abs_pos;
  if (move_count > 0 && gv->data != 0 && esz > 0) {
    memmove(gv->data + (size_t)(abs_pos + 1) * esz,
            gv->data + (size_t)abs_pos * esz,
            (size_t)move_count * esz);
  }
  if (gv->data != 0 && esz > 0) {
    memset(gv->data + (size_t)abs_pos * esz, 0, esz);
  }
  gv->len = gv->len + 1;
  nblocks = w326_load_i32(a, W326_ARENA_NUM_BLOCKS);
  bi = 1;
  while (bi <= nblocks) {
    if (bi != br) {
      ob = pipeline_arena_block_ptr(a, bi);
      if (ob != 0) {
        ob_base = w326_load_i32(ob, base_off);
        if (ob_base >= abs_pos) {
          w326_store_i32(ob, base_off, ob_base + 1);
        }
      }
    }
    bi = bi + 1;
  }
  (void)W326_GV_LEN;
  return abs_pos;
}
