/**
 * ast_pool_block.c — ASTArena block-pool append / region / defer domain (BC 8.3.2).
 *
 * Same-TU #include from ast_pool.c (itself #include'd into pipeline_glue /
 * pipeline_x). Not a separate .o.
 *
 * Domain (block pool append + region/with_arena/unsafe + defer cold APIs):
 * - static block_pool_append_pos (insert-and-shift continuity helper)
 * - pipeline_block_append_{const,let,if,region,with_arena,unsafe,defer}
 * - static block_region_at / block_defer_body_ref_at
 * - pipeline_block_region_{with_arena_cap_ref,is_unsafe,body_ref,label_len,label_copy64}
 * - pipeline_block_defer_body_ref
 *
 * Left in core (next residual / other domains):
 * - pipeline_block_append_{expr_stmt,stmt_order,while,for,labeled}
 * - block_const/let/if/while/for_at + const/let/if/while/for getters
 * - fill_*_from_onefunc / stmt_order rebuild / parent patch / resolve residual
 * - pipeline_onefunc_append_defer / labeled (OneFunc residual)
 *
 * Depends on same-TU statics: block_at, arena_sidecar_get, grow_vec_*,
 * link_abi_getenv, diag_reportf, pipeline_expr_kind_ord_at.
 * Later core append_* still call static block_pool_append_pos (same TU).
 *
 * PLATFORM: SHARED — host-cc Cap residual; parser/typeck/codegen call these.
 * Wave: 988 · no semantic change · pin stays 77b334842.
 */

/**
 * 维持 per-block 池条目连续性的核心辅助函数（insert-and-shift 策略）。
 *
 * 【Why 逻辑根源】block_let_at / block_const_at 等 reader 用 `base + li` 索引全局池，假设
 *   同一 block 的条目在池中物理连续。但嵌套 parse_block_into 递归会在父块首次 append 后、
 *   后续 append 前向池尾 push 子块条目，破坏父块连续性；导致父块 `base + li` 读到子块条目
 *   （数据错乱）或越界（SIGSEGV）。与 pipeline_block_stmt_order_insert_at 既有策略同源。
 *
 * 【Invariant 状态不变量】调用后，br 对应 block 的 `base .. base+num_before` 区间在池中物理连续，
 *   且同 arena 内所有 block 的对应 base 字段被同步修正以维持各自的连续性。
 *
 * 【Asm/Perf 性能预期】无间隙时 O(1)（仅 push）；有间隙时 O(N+M) memmove（N=被搬移条目数，
 *   M=同 arena block 数）。间隙仅在嵌套块交错追加时出现，属低频路径，热路径无影响。
 *
 * 参数：
 *   a          — ASTArena
 *   br         — 目标 block ref（1-based）
 *   pool       — 目标侧车池（&sc->lets / &sc->consts / ...）
 *   base_off   — block 内 base 字段的 offsetof 偏移（offsetof(struct ast_Block, let_base) 等）
 *   num_before — 调用前 block 内该类条目的已有数量（b->num_lets 等）
 * 返回：池中绝对下标（>=0）成功；-1 失败。调用方负责写入条目数据并递增 num_* 计数。
 */
static int32_t block_pool_append_pos(struct ast_ASTArena *a, int32_t br, GrowVec *pool,
                                     size_t base_off, int32_t num_before) {
  struct ast_Block *b;
  int32_t *base_field;
  int32_t abs_pos;
  if (!a || !pool || !(b = block_at(a, br)))
    return -1;
  base_field = (int32_t *)((uint8_t *)b + base_off);
  if (num_before == 0) {
    /* 首次追加：直接 push 到池尾并锚定 base；abs_pos 在尾后，不影响其他 block 的既有 base */
    abs_pos = grow_vec_push(pool);
    if (abs_pos < 0)
      return -1;
    *base_field = abs_pos;
    return abs_pos;
  }
  /* 后续追加：期望位置 = base + num_before（维持连续性的物理位置） */
  abs_pos = *base_field + num_before;
  if (abs_pos >= pool->len) {
    /* 无间隙：期望位置在池尾或超出，直接 push 即可，不破坏既有连续性 */
    abs_pos = grow_vec_push(pool);
    if (abs_pos < 0)
      return -1;
    return abs_pos;
  }
  /* 有间隙：abs_pos 处当前被嵌套块条目占据，须 insert-and-shift */
  {
    size_t esz;
    int32_t move_count;
    int32_t bi;
    if (!grow_vec_ensure(pool))
      return -1;
    esz = pool->elem_sz;
    move_count = pool->len - abs_pos;
    if (move_count > 0) {
      memmove(pool->data + (size_t)(abs_pos + 1) * esz,
              pool->data + (size_t)abs_pos * esz,
              (size_t)move_count * esz);
    }
    memset(pool->data + (size_t)abs_pos * esz, 0, esz);
    pool->len++;
    /* 修正同 arena 内所有 block 的同名字段：base >= abs_pos 者 +1（其条目被 memmove 推后一位） */
    for (bi = 1; bi <= a->num_blocks; bi++) {
      struct ast_Block *ob = block_at(a, bi);
      if (ob && bi != br) {
        int32_t *ob_field = (int32_t *)((uint8_t *)ob + base_off);
        if (*ob_field >= abs_pos)
          (*ob_field)++;
      }
    }
  }
  return abs_pos;
}

/** Block 池 append/read — const */
int32_t pipeline_block_append_const(struct ast_ASTArena *a, int32_t br, uint8_t *name, int32_t name_len,
                                    int32_t type_ref, int32_t init_ref) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  struct ast_ConstDecl *cd;
  int32_t idx;
  if (!a || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)))
    return -1;
  idx = block_pool_append_pos(a, br, &sc->consts, offsetof(struct ast_Block, const_base), b->num_consts);
  if (idx < 0)
    return -1;
  cd = (struct ast_ConstDecl *)grow_vec_at(&sc->consts, idx);
  memset(cd, 0, sizeof(*cd));
  /* wave581 Cap residual: ConstDecl.name is u8[128]; copy up to 127 content bytes. */
  if (name_len > 0 && name)
    memcpy(cd->name, name, (size_t)(name_len > 127 ? 127 : name_len));
  cd->name_len = name_len > 127 ? 127 : name_len;
  cd->type_ref = type_ref;
  cd->init_ref = init_ref;
  b->num_consts++;
  return idx - b->const_base;
}

int32_t pipeline_block_append_let(struct ast_ASTArena *a, int32_t br, uint8_t *name, int32_t name_len,
                                 int32_t type_ref, int32_t init_ref) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  struct ast_LetDecl *ld;
  int32_t idx;
  const char *dbg_append_block;
  if (!a || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)))
    return -1;
  dbg_append_block = link_abi_getenv("XLANG_DEBUG_APPEND_BLOCK");
  idx = block_pool_append_pos(a, br, &sc->lets, offsetof(struct ast_Block, let_base), b->num_lets);
  if (idx < 0)
    return -1;
  ld = (struct ast_LetDecl *)grow_vec_at(&sc->lets, idx);
  memset(ld, 0, sizeof(*ld));
  /* wave581 Cap residual: LetDecl.name is u8[128]; copy up to 127 content bytes (was 64 truncate). */
  if (name_len > 0 && name)
    memcpy(ld->name, name, (size_t)(name_len > 127 ? 127 : name_len));
  ld->name_len = name_len > 127 ? 127 : name_len;
  ld->type_ref = type_ref;
  ld->init_ref = init_ref;
  if (dbg_append_block && dbg_append_block[0] && atoi(dbg_append_block) == br) {
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "append let debug: block=%d rel_idx=%d name=%.*s init_ref=%d init_kind=%d type_ref=%d",
                 (int)br, (int)b->num_lets, name_len > 0 ? (int)name_len : 0, (const char *)(name ? name : (uint8_t *)""),
                 (int)init_ref, (int)pipeline_expr_kind_ord_at(a, init_ref), (int)type_ref);
  }
  b->num_lets++;
  return idx - b->let_base;
}

int32_t pipeline_block_append_if(struct ast_ASTArena *a, int32_t br, int32_t cond_ref, int32_t then_ref,
                                  int32_t else_ref) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  struct ast_IfStmt *is;
  int32_t idx;
  if (!a || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)))
    return -1;
  idx = block_pool_append_pos(a, br, &sc->ifs, offsetof(struct ast_Block, if_base), b->num_if_stmts);
  if (idx < 0)
    return -1;
  is = (struct ast_IfStmt *)grow_vec_at(&sc->ifs, idx);
  is->cond_ref = cond_ref;
  is->then_body_ref = then_ref;
  is->else_body_ref = else_ref;
  b->num_if_stmts++;
  return idx - b->if_base;
}

/** M-3：向块追加 region label { body }；返回块内 region 下标，失败 -1。 */
int32_t pipeline_block_append_region(struct ast_ASTArena *a, int32_t br, uint8_t *label, int32_t label_len,
                                     int32_t body_ref) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  RegionBlockEntry *rb;
  int32_t idx;
  if (!a || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)) || !label || label_len <= 0 || label_len > 127)
    return -1;
  idx = block_pool_append_pos(a, br, &sc->regions, offsetof(struct ast_Block, region_base), b->num_regions);
  if (idx < 0)
    return -1;
  rb = (RegionBlockEntry *)grow_vec_at(&sc->regions, idx);
  memset(rb, 0, sizeof(*rb));
  memcpy(rb->label, label, (size_t)label_len);
  rb->label_len = label_len;
  rb->body_ref = body_ref;
  rb->with_arena_cap_ref = 0;
  b->num_regions++;
  return idx - b->region_base;
}

/**
 * MEM-C1：向块追加 with_arena(cap) { body }；复用 regions 池，with_arena_cap_ref>0 区分 region。
 * 返回块内下标（与 region 共用 idx 空间），失败 -1。
 */
int32_t pipeline_block_append_with_arena(struct ast_ASTArena *a, int32_t br, int32_t cap_ref, int32_t body_ref) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  RegionBlockEntry *rb;
  int32_t idx;
  if (!a || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)) || cap_ref <= 0 || body_ref <= 0)
    return -1;
  idx = block_pool_append_pos(a, br, &sc->regions, offsetof(struct ast_Block, region_base), b->num_regions);
  if (idx < 0)
    return -1;
  rb = (RegionBlockEntry *)grow_vec_at(&sc->regions, idx);
  memset(rb, 0, sizeof(*rb));
  rb->with_arena_cap_ref = cap_ref;
  rb->body_ref = body_ref;
  b->num_regions++;
  return idx - b->region_base;
}

/**
 * LANG-007 v2：向块追加 unsafe { body }；复用 regions 池，with_arena_cap_ref=-1 区分 region/with_arena。
 * 返回块内下标（与 region 共用 idx 空间），失败 -1。
 */
int32_t pipeline_block_append_unsafe(struct ast_ASTArena *a, int32_t br, int32_t body_ref) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  RegionBlockEntry *rb;
  int32_t idx;
  if (!a || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)) || body_ref <= 0)
    return -1;
  idx = block_pool_append_pos(a, br, &sc->regions, offsetof(struct ast_Block, region_base), b->num_regions);
  if (idx < 0)
    return -1;
  rb = (RegionBlockEntry *)grow_vec_at(&sc->regions, idx);
  memset(rb, 0, sizeof(*rb));
  rb->with_arena_cap_ref = -1;
  rb->body_ref = body_ref;
  b->num_regions++;
  return idx - b->region_base;
}

static RegionBlockEntry *block_region_at(struct ast_ASTArena *a, int32_t br, int32_t ri) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  int32_t abs;
  if (!a || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)) || ri < 0 || ri >= b->num_regions)
    return NULL;
  abs = b->region_base + ri;
  return (RegionBlockEntry *)grow_vec_at(&sc->regions, abs);
}

/** MEM-C1：块内第 ri 个 region/with_arena 条目的 cap ref；0 表示非 with_arena。 */
int32_t pipeline_block_region_with_arena_cap_ref(struct ast_ASTArena *a, int32_t br, int32_t ri) {
  RegionBlockEntry *rb = block_region_at(a, br, ri);
  return rb && rb->with_arena_cap_ref > 0 ? rb->with_arena_cap_ref : 0;
}

/** LANG-007 v2：块内第 ri 个条目是否为 unsafe { } 块（with_arena_cap_ref==-1）。 */
int32_t pipeline_block_region_is_unsafe(struct ast_ASTArena *a, int32_t br, int32_t ri) {
  RegionBlockEntry *rb = block_region_at(a, br, ri);
  return rb && rb->with_arena_cap_ref == -1 ? 1 : 0;
}

/** M-3：读块内第 ri 个 region 的 body 块 ref；无效时 0。 */
int32_t pipeline_block_region_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ri) {
  RegionBlockEntry *rb = block_region_at(a, br, ri);
  return rb ? rb->body_ref : 0;
}

/** M-3：读块内 region 域标签长度；无效时 0。 */
int32_t pipeline_block_region_label_len(struct ast_ASTArena *a, int32_t br, int32_t ri) {
  RegionBlockEntry *rb = block_region_at(a, br, ri);
  return rb && rb->label_len > 0 ? rb->label_len : 0;
}

/** M-3：拷贝 region 域标签到 dst[64]（不保证 NUL 结尾）。 */
void pipeline_block_region_label_copy64(struct ast_ASTArena *a, int32_t br, int32_t ri, uint8_t *dst) {
  RegionBlockEntry *rb;
  if (!dst)
    return;
  rb = block_region_at(a, br, ri);
  if (!rb || rb->label_len <= 0) {
    memset(dst, 0, 64);
    return;
  }
  memset(dst, 0, 64);
  memcpy(dst, rb->label, (size_t)rb->label_len);
}

/** MEM-B0：向块追加 defer { body }；返回块内 defer 下标，失败 -1。 */
int32_t pipeline_block_append_defer(struct ast_ASTArena *a, int32_t br, int32_t body_ref) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  int32_t idx;
  int32_t *pr;
  if (!a || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)) || body_ref <= 0)
    return -1;
  idx = block_pool_append_pos(a, br, &sc->defer_block_refs, offsetof(struct ast_Block, defer_base), b->num_defers);
  if (idx < 0)
    return -1;
  pr = (int32_t *)grow_vec_at(&sc->defer_block_refs, idx);
  *pr = body_ref;
  b->num_defers++;
  return idx - b->defer_base;
}

static int32_t block_defer_body_ref_at(struct ast_ASTArena *a, int32_t br, int32_t di) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  int32_t abs;
  int32_t *pr;
  if (!a || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)) || di < 0 || di >= b->num_defers)
    return 0;
  abs = b->defer_base + di;
  pr = (int32_t *)grow_vec_at(&sc->defer_block_refs, abs);
  return pr ? *pr : 0;
}

/** MEM-B0：读块内第 di 个 defer 的 body 块 ref；无效时 0。 */
int32_t pipeline_block_defer_body_ref(struct ast_ASTArena *a, int32_t br, int32_t di) {
  return block_defer_body_ref_at(a, br, di);
}
