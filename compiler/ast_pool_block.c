/**
 * ast_pool_block.c — ASTArena block-pool domain (BC 8.3.2).
 *
 * Same-TU #include from ast_pool.c (itself #include'd into pipeline_glue /
 * pipeline_x). Not a separate .o.
 *
 * Domain (block pool append + region/defer + loop/labeled + cold getters +
 * parent patch + name resolve + stmt_order rebuild/fixup):
 * - static block_pool_append_pos (insert-and-shift continuity helper)
 * - pipeline_block_append_{const,let,if,region,with_arena,unsafe,defer}
 * - pipeline_block_append_{expr_stmt,stmt_order,while,for,labeled}
 * - static block_{const,let,if,while,for}_at + block_region_at / block_defer_body_ref_at
 * - pipeline_block_region_{with_arena_cap_ref,is_unsafe,body_ref,label_len,label_copy64}
 * - pipeline_block_defer_body_ref
 * - while/for/labeled cold getters + labeled_* helpers
 * - const/let/if/expr_stmt/stmt_order cold getters + set_let/const_type_ref
 * - pipeline_patch_block_parent_links + expr_has_inner_block + set_parent_if_zero
 * - pipeline_block_resolve_var_type_ref / name_binding_kind / find_var_decl_block_ref
 * - pipeline_block_local_name_redecl_c
 * - wave992 residual 有则补全:
 *   - static pipeline_block_stmt_order_insert_at / prepend_lets
 *   - pipeline_block_stmt_order_fix_prefix_lets
 *   - pipeline_block_with_arena_fixup_stmt_order
 *   - pipeline_block_stmt_order_rebuild_sparse_ifs
 *   - pipeline_module_fixup_with_arena_stmt_orders (module walk → block fixups)
 *
 * Left in other domains (same TU after this include):
 * - fill_*_from_onefunc → onefunc slice (wave991)
 * - module_top_level_name_is_const + hoist_top_level_lets_into_main +
 *   asm_hoist_target / sum_module_top_level_lets_stack →
 *   top_level slice (wave993–994; hoist calls static prepend_lets here)
 *
 * Depends on same-TU statics: block_at, arena_sidecar_get, grow_vec_*,
 * link_abi_getenv, diag_reportf, pipeline_expr_kind_ord_at,
 * pipeline_arena_expr_ptr, pipeline_module_func_*.
 * fill helpers (onefunc) and hoist (top_level) call these exports same TU.
 *
 * PLATFORM: SHARED — host-cc Cap residual; parser/typeck/codegen call these.
 * Wave: 988–990 + 992 residual · no semantic change · pin stays 77b334842.
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

int32_t pipeline_block_append_expr_stmt(struct ast_ASTArena *a, int32_t br, int32_t expr_ref) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  int32_t idx;
  int32_t *pr;
  if (!a || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)))
    return -1;
  idx = block_pool_append_pos(a, br, &sc->expr_stmt_refs, offsetof(struct ast_Block, expr_stmt_base), b->num_expr_stmts);
  if (idx < 0)
    return -1;
  pr = (int32_t *)grow_vec_at(&sc->expr_stmt_refs, idx);
  *pr = expr_ref;
  b->num_expr_stmts++;
  return idx - b->expr_stmt_base;
}

int32_t pipeline_block_append_stmt_order(struct ast_ASTArena *a, int32_t br, uint8_t kind, int32_t idx_val) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  struct ast_StmtOrderItem *so;
  int32_t idx;
  if (!a || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)))
    return -1;
  idx = block_pool_append_pos(a, br, &sc->stmt_order, offsetof(struct ast_Block, stmt_order_base), b->num_stmt_order);
  if (idx < 0)
    return -1;
  so = (struct ast_StmtOrderItem *)grow_vec_at(&sc->stmt_order, idx);
  so->kind = kind;
  so->idx = idx_val;
  b->num_stmt_order++;
  return idx - b->stmt_order_base;
}

static struct ast_ConstDecl *block_const_at(struct ast_ASTArena *a, int32_t br, int32_t ci) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  int32_t abs;
  if (!a || !(sc = arena_sidecar_get(a, 0)) || !(b = block_at(a, br)))
    return NULL;
  if (ci < 0 || ci >= b->num_consts)
    return NULL;
  abs = b->const_base + ci;
  return (struct ast_ConstDecl *)grow_vec_at(&sc->consts, abs);
}

static struct ast_LetDecl *block_let_at(struct ast_ASTArena *a, int32_t br, int32_t li) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  int32_t abs;
  if (!a || !(sc = arena_sidecar_get(a, 0)) || !(b = block_at(a, br)))
    return NULL;
  if (li < 0 || li >= b->num_lets)
    return NULL;
  abs = b->let_base + li;
  return (struct ast_LetDecl *)grow_vec_at(&sc->lets, abs);
}

static struct ast_IfStmt *block_if_at(struct ast_ASTArena *a, int32_t br, int32_t ii) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  int32_t abs;
  if (!a || !(sc = arena_sidecar_get(a, 0)) || !(b = block_at(a, br)))
    return NULL;
  if (ii < 0 || ii >= b->num_if_stmts)
    return NULL;
  abs = b->if_base + ii;
  return (struct ast_IfStmt *)grow_vec_at(&sc->ifs, abs);
}

static struct ast_WhileLoop *block_while_at(struct ast_ASTArena *a, int32_t br, int32_t wi) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  int32_t abs;
  if (!a || !(sc = arena_sidecar_get(a, 0)) || !(b = block_at(a, br)))
    return NULL;
  if (wi < 0 || wi >= b->num_loops)
    return NULL;
  abs = b->loop_base + wi;
  return (struct ast_WhileLoop *)grow_vec_at(&sc->loops, abs);
}

static struct ast_ForLoop *block_for_at(struct ast_ASTArena *a, int32_t br, int32_t fi) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  int32_t abs;
  if (!a || !(sc = arena_sidecar_get(a, 0)) || !(b = block_at(a, br)))
    return NULL;
  if (fi < 0 || fi >= b->num_for_loops)
    return NULL;
  abs = b->for_loop_base + fi;
  return (struct ast_ForLoop *)grow_vec_at(&sc->for_loops, abs);
}

/** Block 池：追加 while 循环；返回块内相对下标，失败 -1。 */
int32_t pipeline_block_append_while(struct ast_ASTArena *a, int32_t br, int32_t cond_ref, int32_t body_ref) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  struct ast_WhileLoop *wl;
  int32_t idx;
  if (!a || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)))
    return -1;
  idx = block_pool_append_pos(a, br, &sc->loops, offsetof(struct ast_Block, loop_base), b->num_loops);
  if (idx < 0)
    return -1;
  wl = (struct ast_WhileLoop *)grow_vec_at(&sc->loops, idx);
  if (!wl)
    return -1;
  memset(wl, 0, sizeof(*wl));
  wl->cond_ref = cond_ref;
  wl->body_ref = body_ref;
  if (link_abi_getenv("XLANG_ASM_DEBUG"))
    fprintf(stderr, "xlang: append_while br=%d cond=%d body=%d wi=%d\n", (int)br, (int)cond_ref, (int)body_ref,
            (int)(idx - b->loop_base));
  b->num_loops++;
  return idx - b->loop_base;
}

/** Block 池：追加 for 循环；返回块内相对下标，失败 -1。 */
int32_t pipeline_block_append_for(struct ast_ASTArena *a, int32_t br, int32_t init_ref, int32_t cond_ref,
                                   int32_t step_ref, int32_t body_ref) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  struct ast_ForLoop *fl;
  int32_t idx;
  if (!a || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)))
    return -1;
  idx = block_pool_append_pos(a, br, &sc->for_loops, offsetof(struct ast_Block, for_loop_base), b->num_for_loops);
  if (idx < 0)
    return -1;
  fl = (struct ast_ForLoop *)grow_vec_at(&sc->for_loops, idx);
  if (!fl)
    return -1;
  fl->init_ref = init_ref;
  fl->cond_ref = cond_ref;
  fl->step_ref = step_ref;
  fl->body_ref = body_ref;
  b->num_for_loops++;
  return idx - b->for_loop_base;
}

int32_t pipeline_block_while_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t wi) {
  struct ast_WhileLoop *wl = block_while_at(a, br, wi);
  return wl ? (int32_t)wl->cond_ref : 0;
}

int32_t pipeline_block_while_body_ref(struct ast_ASTArena *a, int32_t br, int32_t wi) {
  struct ast_WhileLoop *wl = block_while_at(a, br, wi);
  return wl ? (int32_t)wl->body_ref : 0;
}

int32_t pipeline_block_for_init_ref(struct ast_ASTArena *a, int32_t br, int32_t fi) {
  struct ast_ForLoop *fl = block_for_at(a, br, fi);
  return fl ? (int32_t)fl->init_ref : 0;
}

int32_t pipeline_block_for_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t fi) {
  struct ast_ForLoop *fl = block_for_at(a, br, fi);
  return fl ? (int32_t)fl->cond_ref : 0;
}

int32_t pipeline_block_for_step_ref(struct ast_ASTArena *a, int32_t br, int32_t fi) {
  struct ast_ForLoop *fl = block_for_at(a, br, fi);
  return fl ? (int32_t)fl->step_ref : 0;
}

int32_t pipeline_block_for_body_ref(struct ast_ASTArena *a, int32_t br, int32_t fi) {
  struct ast_ForLoop *fl = block_for_at(a, br, fi);
  return fl ? (int32_t)fl->body_ref : 0;
}

/** Block 池：追加 labeled 语句（label 可为空，用于 library 形态 return expr）。 */
int32_t pipeline_block_append_labeled(struct ast_ASTArena *a, int32_t br, int32_t label_len, int32_t is_goto,
                                       int32_t goto_target_len, int32_t return_expr_ref) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  struct ast_LabeledStmt *ls;
  int32_t idx;
  if (!a || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)))
    return -1;
  idx = block_pool_append_pos(a, br, &sc->labeled_stmts, offsetof(struct ast_Block, labeled_base), b->num_labeled_stmts);
  if (idx < 0)
    return -1;
  ls = (struct ast_LabeledStmt *)grow_vec_at(&sc->labeled_stmts, idx);
  if (!ls)
    return -1;
  memset(ls, 0, sizeof(*ls));
  ls->label_len = label_len;
  ls->is_goto = is_goto;
  ls->goto_target_len = goto_target_len;
  ls->return_expr_ref = return_expr_ref;
  b->num_labeled_stmts++;
  return idx - b->labeled_base;
}

/** 取 block 内第 li 条 labeled 语句指针；无效返回 NULL。 */
struct ast_LabeledStmt *pipeline_block_labeled_ptr(struct ast_ASTArena *a, int32_t br, int32_t li) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  int32_t abs;
  if (!a || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)))
    return NULL;
  if (li < 0 || li >= b->num_labeled_stmts)
    return NULL;
  abs = b->labeled_base + li;
  return (struct ast_LabeledStmt *)grow_vec_at(&sc->labeled_stmts, abs);
}

int32_t pipeline_block_labeled_return_expr_ref(struct ast_ASTArena *a, int32_t br, int32_t li) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  struct ast_LabeledStmt *ls;
  int32_t abs;
  if (!a || !(sc = arena_sidecar_get(a, 0)) || !(b = block_at(a, br)))
    return 0;
  if (li < 0 || li >= b->num_labeled_stmts)
    return 0;
  abs = b->labeled_base + li;
  ls = (struct ast_LabeledStmt *)grow_vec_at(&sc->labeled_stmts, abs);
  return ls ? (int32_t)ls->return_expr_ref : 0;
}

/** wave379: count of labeled stmts in block (stmt_order kind=7). PLATFORM: SHARED. */
int32_t pipeline_block_num_labeled_stmts(struct ast_ASTArena *a, int32_t br) {
  struct ast_Block *b;
  if (!a || !(b = block_at(a, br)))
    return 0;
  return b->num_labeled_stmts;
}

/**
 * wave379: is_goto flag for labeled stmt li (1 = bare `goto target;`, 0 = label def / labeled return).
 * PLATFORM: SHARED — host-C emit stmt_order kind=7.
 */
int32_t pipeline_block_labeled_is_goto(struct ast_ASTArena *a, int32_t br, int32_t li) {
  struct ast_LabeledStmt *ls = pipeline_block_labeled_ptr(a, br, li);
  return ls ? ls->is_goto : 0;
}

/** wave379: label name length for `L:` definition (0 when bare goto has empty label). */
int32_t pipeline_block_labeled_label_len(struct ast_ASTArena *a, int32_t br, int32_t li) {
  struct ast_LabeledStmt *ls = pipeline_block_labeled_ptr(a, br, li);
  return ls ? ls->label_len : 0;
}

/** wave379/wave586: copy label name into dst (ABI *copy32; payload 128, content ≤127). */
void pipeline_block_labeled_label_copy32(struct ast_ASTArena *a, int32_t br, int32_t li, uint8_t *dst) {
  struct ast_LabeledStmt *ls;
  if (!dst)
    return;
  /* wave586 Cap residual: ABI name *copy32; payload 128 (match LabeledStmt.label[128]). */
  memset(dst, 0, 128);
  ls = pipeline_block_labeled_ptr(a, br, li);
  if (!ls || ls->label_len <= 0)
    return;
  {
    int32_t n = ls->label_len;
    if (n > 127)
      n = 127;
    memcpy(dst, ls->label, (size_t)n);
  }
}

/** wave379: goto target name length for `goto T;`. */
int32_t pipeline_block_labeled_goto_target_len(struct ast_ASTArena *a, int32_t br, int32_t li) {
  struct ast_LabeledStmt *ls = pipeline_block_labeled_ptr(a, br, li);
  return ls ? ls->goto_target_len : 0;
}

/** wave379/wave586: copy goto target into dst (ABI *copy32; payload 128, content ≤127). */
void pipeline_block_labeled_goto_target_copy32(struct ast_ASTArena *a, int32_t br, int32_t li, uint8_t *dst) {
  struct ast_LabeledStmt *ls;
  if (!dst)
    return;
  /* wave586 Cap residual: ABI name *copy32; payload 128 (match LabeledStmt.goto_target[128]). */
  memset(dst, 0, 128);
  ls = pipeline_block_labeled_ptr(a, br, li);
  if (!ls || ls->goto_target_len <= 0)
    return;
  {
    int32_t n = ls->goto_target_len;
    if (n > 127)
      n = 127;
    memcpy(dst, ls->goto_target, (size_t)n);
  }
}

int32_t pipeline_block_const_init_ref(struct ast_ASTArena *a, int32_t br, int32_t ci) {
  struct ast_ConstDecl *cd = block_const_at(a, br, ci);
  return cd ? (int32_t)cd->init_ref : 0;
}

int32_t pipeline_block_const_type_ref(struct ast_ASTArena *a, int32_t br, int32_t ci) {
  struct ast_ConstDecl *cd = block_const_at(a, br, ci);
  return cd ? (int32_t)cd->type_ref : 0;
}

int32_t pipeline_block_const_name_len(struct ast_ASTArena *a, int32_t br, int32_t ci) {
  struct ast_ConstDecl *cd = block_const_at(a, br, ci);
  return cd ? (int32_t)cd->name_len : 0;
}

void pipeline_block_const_name_copy64(struct ast_ASTArena *a, int32_t br, int32_t ci, uint8_t *dst) {
  struct ast_ConstDecl *cd;
  int32_t nlen;
  if (!dst)
    return;
  cd = block_const_at(a, br, ci);
  /* wave581 Cap residual: ABI name *copy64; payload 128 (match LetDecl / AST name[128]). */
  memset(dst, 0, 128);
  if (!cd)
    return;
  nlen = cd->name_len;
  if (nlen < 0)
    nlen = 0;
  if (nlen > 127)
    nlen = 127;
  if (nlen > 0)
    memcpy(dst, cd->name, (size_t)nlen);
}

int32_t pipeline_block_let_init_ref(struct ast_ASTArena *a, int32_t br, int32_t li) {
  struct ast_LetDecl *ld = block_let_at(a, br, li);
  return ld ? (int32_t)ld->init_ref : 0;
}

int32_t pipeline_block_let_type_ref(struct ast_ASTArena *a, int32_t br, int32_t li) {
  struct ast_LetDecl *ld = block_let_at(a, br, li);
  return ld ? (int32_t)ld->type_ref : 0;
}

/** M-3：region 内 stamp 须换新 type_ref，禁止 in-place 改共享 T[] 池节点。 */
int32_t pipeline_block_set_let_type_ref(struct ast_ASTArena *a, int32_t br, int32_t li, int32_t type_ref) {
  struct ast_LetDecl *ld = block_let_at(a, br, li);
  if (!ld)
    return -1;
  ld->type_ref = type_ref;
  return 0;
}

/**
 * wave423 Cap residual pure: stamp block const type after inference from init.
 * Used when parser left type_ref=0 for `const name = init` (docs/06 type-optional).
 * G.7 twin of pipeline_block_set_let_type_ref; typeck_check_block_one_const calls this.
 * PLATFORM: SHARED typeck/AST.
 */
int32_t pipeline_block_set_const_type_ref(struct ast_ASTArena *a, int32_t br, int32_t ci, int32_t type_ref) {
  struct ast_ConstDecl *cd = block_const_at(a, br, ci);
  if (!cd)
    return -1;
  cd->type_ref = type_ref;
  return 0;
}

int32_t pipeline_block_let_name_len(struct ast_ASTArena *a, int32_t br, int32_t li) {
  struct ast_LetDecl *ld = block_let_at(a, br, li);
  return ld ? (int32_t)ld->name_len : 0;
}

void pipeline_block_let_name_copy64(struct ast_ASTArena *a, int32_t br, int32_t li, uint8_t *dst) {
  struct ast_LetDecl *ld;
  int32_t nlen;
  if (!dst)
    return;
  ld = block_let_at(a, br, li);
  if (!ld) {
    memset(dst, 0, 128);
    return;
  }
  /* wave577 Cap: 拷贝 name_len 字节（≤127），余下清零；与 AST name[128] 对齐避免截断。 */
  nlen = ld->name_len;
  if (nlen < 0)
    nlen = 0;
  if (nlen > 127)
    nlen = 127;
  memset(dst, 0, 128);
  if (nlen > 0)
    memcpy(dst, ld->name, (size_t)nlen);
}

int32_t pipeline_block_expr_stmt_ref(struct ast_ASTArena *a, int32_t br, int32_t ei) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  int32_t abs;
  int32_t *pr;
  if (!a || !(sc = arena_sidecar_get(a, 0)) || !(b = block_at(a, br)))
    return 0;
  if (ei < 0 || ei >= b->num_expr_stmts)
    return 0;
  abs = b->expr_stmt_base + ei;
  pr = (int32_t *)grow_vec_at(&sc->expr_stmt_refs, abs);
  return pr ? *pr : 0;
}

uint8_t pipeline_block_stmt_order_kind(struct ast_ASTArena *a, int32_t br, int32_t si) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  struct ast_StmtOrderItem *so;
  int32_t abs;
  if (!a || !(sc = arena_sidecar_get(a, 0)) || !(b = block_at(a, br)))
    return 0;
  if (si < 0 || si >= b->num_stmt_order)
    return 0;
  abs = b->stmt_order_base + si;
  so = (struct ast_StmtOrderItem *)grow_vec_at(&sc->stmt_order, abs);
  return so ? so->kind : 0;
}

int32_t pipeline_block_stmt_order_idx(struct ast_ASTArena *a, int32_t br, int32_t si) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  struct ast_StmtOrderItem *so;
  int32_t abs;
  if (!a || !(sc = arena_sidecar_get(a, 0)) || !(b = block_at(a, br)))
    return 0;
  if (si < 0 || si >= b->num_stmt_order)
    return 0;
  abs = b->stmt_order_base + si;
  so = (struct ast_StmtOrderItem *)grow_vec_at(&sc->stmt_order, abs);
  return so ? (int32_t)so->idx : 0;
}

int32_t pipeline_block_if_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t ii) {
  struct ast_IfStmt *is = block_if_at(a, br, ii);
  return is ? (int32_t)is->cond_ref : 0;
}

int32_t pipeline_block_if_then_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii) {
  struct ast_IfStmt *is = block_if_at(a, br, ii);
  return is ? (int32_t)is->then_body_ref : 0;
}

int32_t pipeline_block_if_else_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii) {
  struct ast_IfStmt *is = block_if_at(a, br, ii);
  return is ? (int32_t)is->else_body_ref : 0;
}


/* -------------------------------------------------------------------------- */
/* BC 8.3.2 wave990: parent patch + name resolve residual (有则补全).           */
/* Moved from ast_pool.c core; COUNT stays 45 (no new leaf).                   */
/* Uses pipeline_arena_expr_ptr (not glue_arena_expr_at_ref static).           */
/* -------------------------------------------------------------------------- */

/**
 * 为嵌套块补 parent_block_ref（while/for/if 体）；显式栈遍历，避免递归栈溢出。
 * 与 ast.x::ast_arena_patch_block_parent_links 一致；typeck 在 check_block 前调用。
 */
static int32_t expr_has_inner_block(struct ast_ASTArena *a, int32_t expr_ref, int32_t parent_block, int32_t depth);
static void patch_block_expr_parents(struct ast_ASTArena *a, int32_t block_ref);

void pipeline_patch_block_parent_links(struct ast_ASTArena *a, int32_t block_ref, int32_t parent_ref) {
  int32_t stack_blk[256];
  int32_t stack_par[256];
  int32_t sp;
  int32_t cur;
  int32_t par;
  int32_t i;
  struct ast_Block *b;
  int32_t wb;
  int32_t fb;
  int32_t tb;
  int32_t eb;
  int32_t rgb;
  if (!a || block_ref <= 0 || block_ref > a->num_blocks)
    return;
  sp = 0;
  stack_blk[sp] = block_ref;
  stack_par[sp] = parent_ref;
  sp++;
  while (sp > 0) {
    sp--;
    cur = stack_blk[sp];
    par = stack_par[sp];
    if (cur <= 0 || cur > a->num_blocks)
      continue;
    if (par != 0) {
      b = block_at(a, cur);
      if (b && b->parent_block_ref == 0) {
        b->parent_block_ref = par;
      }
    }
    b = block_at(a, cur);
    if (!b)
      continue;
    for (i = 0; i < b->num_loops; i++) {
      wb = pipeline_block_while_body_ref(a, cur, i);
      if (wb > 0 && sp < 256) {
        stack_blk[sp] = wb;
        stack_par[sp] = cur;
        sp++;
      }
    }
    for (i = 0; i < b->num_for_loops; i++) {
      fb = pipeline_block_for_body_ref(a, cur, i);
      if (fb > 0 && sp < 256) {
        stack_blk[sp] = fb;
        stack_par[sp] = cur;
        sp++;
      }
    }
    for (i = 0; i < b->num_if_stmts; i++) {
      tb = pipeline_block_if_then_body_ref(a, cur, i);
      if (tb > 0 && sp < 256) {
        stack_blk[sp] = tb;
        stack_par[sp] = cur;
        sp++;
      }
      eb = pipeline_block_if_else_body_ref(a, cur, i);
      if (eb > 0 && sp < 256) {
        stack_blk[sp] = eb;
        stack_par[sp] = cur;
        sp++;
      }
    }
    /** M-3：region 体块须挂 parent，否则块内可访问外层 let（如 region_block_escape 的 outer）。 */
    for (i = 0; i < b->num_regions; i++) {
      rgb = pipeline_block_region_body_ref(a, cur, i);
      if (rgb > 0 && sp < 256) {
        stack_blk[sp] = rgb;
        stack_par[sp] = cur;
        sp++;
      }
    }
    /* G-02f-477: patch block expression (EXPR_BLOCK) parent links. */
    patch_block_expr_parents(a, cur);
  }
}

/**
 * 扫描所有 block 的表达式语句与尾表达式，为 EXPR_BLOCK 补设 parent_block_ref。
 */
static int32_t expr_has_inner_block(struct ast_ASTArena *a, int32_t expr_ref, int32_t parent_block, int32_t depth);

static void patch_block_expr_parents(struct ast_ASTArena *a, int32_t block_ref) {
  struct ast_Block *b;
  int32_t i, ne, nf;
  if (!a || block_ref <= 0 || block_ref > a->num_blocks) return;
  b = block_at(a, block_ref);
  if (!b) return;
  ne = b->num_expr_stmts;
  for (i = 0; i < ne; i++) {
    int32_t es_ref = pipeline_block_expr_stmt_ref(a, block_ref, i);
    if (es_ref > 0 && es_ref <= a->num_exprs) {
      expr_has_inner_block(a, es_ref, block_ref, 0);
    }
  }
  nf = b->final_expr_ref;
  if (nf > 0 && nf <= a->num_exprs) {
    expr_has_inner_block(a, nf, block_ref, 0);
  }
}

static int32_t expr_has_inner_block(struct ast_ASTArena *a, int32_t expr_ref, int32_t parent_block, int32_t depth) {
  struct ast_Expr *ex;
  int32_t kind;
  int32_t inner_blk;
  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs || depth > 64) return 0;
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!ex) return 0;
  kind = (int32_t)ex->kind;
  if (kind == 26) {
    inner_blk = ex->block_ref;
    if (inner_blk > 0 && inner_blk <= a->num_blocks) {
      struct ast_Block *ib = block_at(a, inner_blk);
      if (ib && ib->parent_block_ref == 0) {
        ib->parent_block_ref = parent_block;
      }
      patch_block_expr_parents(a, inner_blk);
    }
  }
  if (ex->binop_left_ref > 0) expr_has_inner_block(a, ex->binop_left_ref, parent_block, depth + 1);
  if (ex->binop_right_ref > 0) expr_has_inner_block(a, ex->binop_right_ref, parent_block, depth + 1);
  if (ex->unary_operand_ref > 0) expr_has_inner_block(a, ex->unary_operand_ref, parent_block, depth + 1);
  if (ex->if_then_ref > 0) expr_has_inner_block(a, ex->if_then_ref, parent_block, depth + 1);
  if (ex->if_else_ref > 0) expr_has_inner_block(a, ex->if_else_ref, parent_block, depth + 1);
  if (ex->block_ref > 0 && kind != 26) expr_has_inner_block(a, ex->block_ref, parent_block, depth + 1);
  if (ex->call_callee_ref > 0) expr_has_inner_block(a, ex->call_callee_ref, parent_block, depth + 1);
  return 0;
}

/**
 * 显式设置 block 的 parent_block_ref（仅在为 0 时）。
 *
 * 【Why】pipeline_patch_block_parent_links 遍历 while/for/if/region body 设置 parent，
 *   但无法覆盖块表达式（ord_block 表达式关联的块）——块表达式通过表达式树关联
 *   （pipeline_expr_block_ref_at），不在块的子块列表中。typeck_check_block_impl
 *   在进入每个块时调用此函数，利用 saved_block_ref（= 直接父块）补设 parent。
 *
 * 【Invariant】仅在 parent_block_ref==0 时设置；已由 patch 设置的块不受影响。
 *
 * 【Asm/Perf】O(1) 操作，仅在 typeck check_block 入口调用一次，无性能影响。
 *
 * 返回 1=已设置，0=无需设置或无效。
 */
int32_t pipeline_block_set_parent_if_zero(struct ast_ASTArena *a, int32_t block_ref, int32_t parent_ref) {
  struct ast_Block *b;
  if (!a || block_ref <= 0 || block_ref > a->num_blocks || parent_ref <= 0)
    return 0;
  b = block_at(a, block_ref);
  if (!b)
    return 0;
  if (b->parent_block_ref == 0) {
    b->parent_block_ref = parent_ref;
    return 1;
  }
  return 0;
}

/**
 * Read block parent_block_ref (0 if unset / invalid).
 * Why: typeck.x freestanding cannot touch ast_Block layout; scope-borrow
 * strict-ancestor walk and residual twin need a single G.7 face.
 * Contract: returns 0 for null arena, out-of-range block_ref, or missing block.
 * PLATFORM: SHARED — pure block-pool getter; typeck + residual consumers.
 */
int32_t pipeline_block_parent_block_ref_at(struct ast_ASTArena *a, int32_t block_ref) {
  struct ast_Block *b;
  if (!a || block_ref <= 0 || block_ref > a->num_blocks)
    return 0;
  b = block_at(a, block_ref);
  if (!b)
    return 0;
  return b->parent_block_ref;
}

/** 按名查块内 const/let 类型 ref。 */
int32_t pipeline_block_resolve_var_type_ref(struct ast_ASTArena *a, int32_t block_ref, uint8_t *vname,
                                             int32_t vlen) {
  struct ast_Block *b;
  int32_t cur;
  int32_t depth;
  if (!a || !vname || vlen <= 0)
    return 0;
  cur = block_ref;
  depth = 0;
  while (cur > 0 && cur <= a->num_blocks && depth < 128) {
    int32_t i;
    b = block_at(a, cur);
    if (!b)
      break;
    for (i = 0; i < b->num_consts; i++) {
      struct ast_ConstDecl *cd = block_const_at(a, cur, i);
      if (cd && cd->type_ref != 0 && cd->name_len == vlen &&
          memcmp(cd->name, vname, (size_t)vlen) == 0) {
        return (int32_t)cd->type_ref;
      }
    }
    for (i = 0; i < b->num_lets; i++) {
      struct ast_LetDecl *ld = block_let_at(a, cur, i);
      if (ld && ld->type_ref != 0 && ld->name_len == vlen && memcmp(ld->name, vname, (size_t)vlen) == 0) {
        return (int32_t)ld->type_ref;
      }
    }
    cur = b->parent_block_ref;
    depth++;
  }
  return 0;
}

/**
 * wave678 Cap residual: classify first name match on the block parent chain.
 * Walk order matches pipeline_block_resolve_var_type_ref (inner-first; const
 * before let within a block). Used by assign hard-fail so `const x = …; x = 1`
 * cannot typeck-green (docs/06: const is immutable).
 *
 * @param a *ASTArena
 * @param block_ref i32 — current block (0 → not found)
 * @param vname *u8 — binding name bytes
 * @param vlen i32 — name length
 * @return i32 — 1 const binding, 0 let binding, -1 not found in block chain
 * PLATFORM: SHARED — typeck assign authority helper; dual L2 mac+Ubuntu.
 */
int32_t pipeline_block_name_binding_kind(struct ast_ASTArena *a, int32_t block_ref, uint8_t *vname,
                                         int32_t vlen) {
  struct ast_Block *b;
  int32_t cur;
  int32_t depth;
  if (!a || !vname || vlen <= 0)
    return -1;
  cur = block_ref;
  depth = 0;
  while (cur > 0 && cur <= a->num_blocks && depth < 128) {
    int32_t i;
    b = block_at(a, cur);
    if (!b)
      break;
    for (i = 0; i < b->num_consts; i++) {
      struct ast_ConstDecl *cd = block_const_at(a, cur, i);
      /* Name match only (type_ref may still be 0 before stamp); still const. */
      if (cd && cd->name_len == vlen && memcmp(cd->name, vname, (size_t)vlen) == 0)
        return 1;
    }
    for (i = 0; i < b->num_lets; i++) {
      struct ast_LetDecl *ld = block_let_at(a, cur, i);
      if (ld && ld->name_len == vlen && memcmp(ld->name, vname, (size_t)vlen) == 0)
        return 0;
    }
    cur = b->parent_block_ref;
    depth++;
  }
  return -1;
}

/**
 * wave680 Cap residual: same-block local name redecl (let/const) or param clash.
 *
 * Host-C redefinition soft residual: typeck accepted `let x; let x` / `const x` twice /
 * `let`+`const` same name / function-body `let` shadowing a formal → BLD001.
 * Nested-block shadowing stays legal (C nested scopes).
 *
 * @param a *ASTArena
 * @param block_ref i32 — block containing the declaration under check
 * @param vname *u8 — declaration name
 * @param vlen i32 — name length
 * @param kind i32 — 0 = checking a let at idx; 1 = checking a const at idx
 * @param idx i32 — index of the current let/const in that block
 * @param m *Module — optional; when non-null with func_index>=0, also reject
 *   name equal to a formal of that function **only if** block_ref is that
 *   function's body (not a nested if/while block).
 * @param func_index i32 — current function index, or -1 to skip param scan
 * @return i32 — 1 conflict (hard-fail), 0 ok
 * PLATFORM: SHARED — G.7 single authority for typeck one_let/one_const gates.
 */
int32_t pipeline_block_local_name_redecl_c(struct ast_ASTArena *a, int32_t block_ref, uint8_t *vname,
                                          int32_t vlen, int32_t kind, int32_t idx, struct ast_Module *m,
                                          int32_t func_index) {
  struct ast_Block *b;
  int32_t i;
  int32_t nl;
  int32_t nlet;
  int32_t nconst;
  if (!a || !vname || vlen <= 0 || block_ref <= 0)
    return 0;
  b = block_at(a, block_ref);
  if (!b)
    return 0;
  nlet = b->num_lets;
  nconst = b->num_consts;
  /* Prior / peer same-block lets and consts (exclude self). */
  for (i = 0; i < nlet; i++) {
    struct ast_LetDecl *ld;
    if (kind == 0 && i == idx)
      continue;
    ld = block_let_at(a, block_ref, i);
    if (!ld || ld->name_len != vlen)
      continue;
    if (memcmp(ld->name, vname, (size_t)vlen) == 0)
      return 1;
  }
  for (i = 0; i < nconst; i++) {
    struct ast_ConstDecl *cd;
    if (kind == 1 && i == idx)
      continue;
    cd = block_const_at(a, block_ref, i);
    if (!cd || cd->name_len != vlen)
      continue;
    if (memcmp(cd->name, vname, (size_t)vlen) == 0)
      return 1;
  }
  /* Function body only: param and body local share C scope (no shadow). */
  if (m && func_index >= 0) {
    int32_t body = pipeline_module_func_body_ref_at(m, func_index);
    int32_t np;
    int32_t pi;
    if (body == block_ref) {
      np = pipeline_module_func_num_params_at(m, func_index);
      for (pi = 0; pi < np; pi++) {
        nl = pipeline_module_func_param_name_len_at(m, func_index, pi);
        if (nl != vlen)
          continue;
        {
          /* wave585: copy32 ABI buffer is 128 bytes. */
          uint8_t pbuf[128];
          int32_t k;
          if (nl > 127)
            nl = 127;
          pipeline_module_func_param_name_copy32(m, func_index, pi, pbuf);
          for (k = 0; k < nl; k++) {
            if (pbuf[k] != vname[k])
              break;
          }
          if (k == nl)
            return 1;
        }
      }
    }
  }
  return 0;
}

/**
 * 按名查块内 const/let 的**声明块** ref（自 block_ref 沿 parent 链向内层优先匹配）。
 * 与 pipeline_block_resolve_var_type_ref 遍历顺序一致，但返回 block ref 而非 type ref。
 */
int32_t pipeline_block_find_var_decl_block_ref(struct ast_ASTArena *a, int32_t block_ref, uint8_t *vname,
                                               int32_t vlen) {
  struct ast_Block *b;
  int32_t cur;
  int32_t depth;
  if (!a || !vname || vlen <= 0)
    return 0;
  cur = block_ref;
  depth = 0;
  while (cur > 0 && cur <= a->num_blocks && depth < 128) {
    int32_t i;
    b = block_at(a, cur);
    if (!b)
      break;
    for (i = 0; i < b->num_consts; i++) {
      struct ast_ConstDecl *cd = block_const_at(a, cur, i);
      if (cd && cd->name_len == vlen && memcmp(cd->name, vname, (size_t)vlen) == 0)
        return cur;
    }
    for (i = 0; i < b->num_lets; i++) {
      struct ast_LetDecl *ld = block_let_at(a, cur, i);
      if (ld && ld->name_len == vlen && memcmp(ld->name, vname, (size_t)vlen) == 0)
        return cur;
    }
    cur = b->parent_block_ref;
    depth++;
  }
  return 0;
}

/**
 * 在 block 的 stmt_order 下标 pos 处插入 n_items 条记录，并修正同 arena 内后续 block 的 stmt_order_base。
 * Same insert-and-shift continuity strategy as block_pool_append_pos.
 */
static void pipeline_block_stmt_order_insert_at(struct ast_ASTArena *a, int32_t br, int32_t pos,
                                                const struct ast_StmtOrderItem *items, int32_t n_items) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  int32_t abs;
  int32_t move_count;
  int32_t bi;
  size_t esz;
  uint8_t *data;
  int32_t i;
  if (!a || br <= 0 || !items || n_items <= 0 || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)))
    return;
  if (pos < 0)
    pos = 0;
  if (pos > b->num_stmt_order)
    pos = b->num_stmt_order;
  abs = b->stmt_order_base + pos;
  move_count = sc->stmt_order.len - abs;
  esz = sizeof(struct ast_StmtOrderItem);
  data = sc->stmt_order.data;
  for (i = 0; i < n_items; i++) {
    if (!grow_vec_ensure(&sc->stmt_order))
      return;
    data = sc->stmt_order.data;
  }
  if (move_count > 0 && data)
    memmove(data + (size_t)(abs + n_items) * esz, data + (size_t)abs * esz, (size_t)move_count * esz);
  for (i = 0; i < n_items; i++) {
    struct ast_StmtOrderItem *so = (struct ast_StmtOrderItem *)(data + (size_t)(abs + i) * esz);
    *so = items[i];
  }
  sc->stmt_order.len += n_items;
  b->num_stmt_order += n_items;
  for (bi = 1; bi <= a->num_blocks; bi++) {
    struct ast_Block *ob = block_at(a, bi);
    if (ob && bi != br && ob->stmt_order_base >= abs)
      ob->stmt_order_base += n_items;
  }
}

/**
 * Prepend count let-init stmt_order items (kind=1, idx = let_start_idx + i).
 * wave265: non-static Cap residual face — pure hoist
 * (pipeline_module_hoist_top_level_lets_into_main on runtime_pipeline_abi) calls this.
 * PLATFORM: SHARED — block stmt_order GrowVec authority stays Cap residual.
 */
void pipeline_block_stmt_order_prepend_lets(struct ast_ASTArena *a, int32_t br, int32_t let_start_idx,
                                           int32_t let_count) {
  struct ast_StmtOrderItem ins[64];
  int32_t li;
  if (!a || br <= 0 || let_count <= 0 || let_count > 64)
    return;
  for (li = 0; li < let_count; li++) {
    ins[li].kind = 1;
    ins[li].idx = let_start_idx + li;
  }
  pipeline_block_stmt_order_insert_at(a, br, 0, ins, let_count);
}

/**
 * 块首 parse_body_lets 产生的 let（idx < prefix_n）须在 stmt_order 中先于 if/loop；
 * parser 偶发乱序（with_arena 内连续 if）时原地重排，不改变条目数量。
 */
void pipeline_block_stmt_order_fix_prefix_lets(struct ast_ASTArena *a, int32_t br, int32_t prefix_n) {
  struct ast_Block *b;
  ArenaSidecar *sc;
  struct ast_StmtOrderItem old[512];
  struct ast_StmtOrderItem neu[512];
  int32_t nso;
  int32_t i;
  int32_t nn;
  int32_t pi;
  int32_t lets_seen;
  int32_t need_fix;
  int32_t abs;
  if (!a || br <= 0 || prefix_n <= 0 || prefix_n > 64)
    return;
  b = block_at(a, br);
  sc = arena_sidecar_get(a, 1);
  if (!b || !sc || b->num_stmt_order <= 0)
    return;
  nso = b->num_stmt_order;
  if (nso > 512)
    return;
  for (i = 0; i < nso; i++) {
    old[i].kind = pipeline_block_stmt_order_kind(a, br, i);
    old[i].idx = (int32_t)pipeline_block_stmt_order_idx(a, br, i);
  }
  need_fix = 0;
  lets_seen = 0;
  for (i = 0; i < nso; i++) {
    if (old[i].kind == 0)
      continue;
    if (old[i].kind == 1 && old[i].idx >= 0 && old[i].idx < prefix_n) {
      if (lets_seen != old[i].idx)
        need_fix = 1;
      lets_seen++;
      continue;
    }
    if (lets_seen < prefix_n)
      need_fix = 1;
    break;
  }
  if (!need_fix && lets_seen >= prefix_n)
    return;
  nn = 0;
  for (i = 0; i < nso; i++) {
    if (old[i].kind == 0)
      neu[nn++] = old[i];
  }
  for (pi = 0; pi < prefix_n; pi++) {
    neu[nn].kind = 1;
    neu[nn].idx = pi;
    nn++;
  }
  for (i = 0; i < nso; i++) {
    if (old[i].kind == 0)
      continue;
    if (old[i].kind == 1 && old[i].idx >= 0 && old[i].idx < prefix_n)
      continue;
    neu[nn++] = old[i];
  }
  if (nn != nso)
    return;
  abs = b->stmt_order_base;
  for (i = 0; i < nn; i++) {
    struct ast_StmtOrderItem *so = (struct ast_StmtOrderItem *)grow_vec_at(&sc->stmt_order, abs + i);
    if (so)
      *so = neu[i];
  }
}

/**
 * with_arena 块：stmt_order 须含 kind=6(region) 供 asm init/body/deinit；
 * parse_one_function 偶发只把内层 let/if 扁平写入函数体 stmt_order 而漏 kind=6（with_arena_vec gate 仅 emit 前 2 条 push）。
 * 若本块有 with_arena region 且 stmt_order 无 kind=6，则改为仅保留 region 项（内层 body 块已由 parse_block_into 填好）。
 */
void pipeline_block_with_arena_fixup_stmt_order(struct ast_ASTArena *a, int32_t br) {
  struct ast_Block *b;
  ArenaSidecar *sc;
  int32_t ri;
  int32_t wa_ri;
  int32_t inner;
  int32_t i;
  int32_t abs;
  struct ast_StmtOrderItem *so;
  if (!a || br <= 0)
    return;
  b = block_at(a, br);
  sc = arena_sidecar_get(a, 1);
  if (!b || !sc || b->num_regions <= 0)
    return;
  wa_ri = -1;
  inner = 0;
  for (ri = 0; ri < b->num_regions; ri++) {
    if (pipeline_block_region_with_arena_cap_ref(a, br, ri) > 0) {
      wa_ri = ri;
      inner = pipeline_block_region_body_ref(a, br, ri);
      break;
    }
  }
  if (wa_ri < 0 || inner <= 0 || inner == br) {
    if (link_abi_getenv("XLANG_ASM_DEBUG") && b->num_regions > 0)
      fprintf(stderr, "xlang: wa_fixup skip br=%d wa_ri=%d inner=%d nso=%d\n", (int)br, (int)wa_ri, (int)inner,
              (int)b->num_stmt_order);
    return;
  }
  for (i = 0; i < b->num_stmt_order; i++) {
    if (pipeline_block_stmt_order_kind(a, br, i) == 6) {
      if (link_abi_getenv("XLANG_ASM_DEBUG")) {
        struct ast_Block *ib = inner > 0 ? block_at(a, inner) : NULL;
        fprintf(stderr, "xlang: wa_fixup ok br=%d inner=%d in_nso=%d in_nif=%d\n", (int)br, (int)inner,
                ib ? (int)ib->num_stmt_order : -1, ib ? (int)ib->num_if_stmts : -1);
      }
      return;
    }
  }
  if (link_abi_getenv("XLANG_ASM_DEBUG"))
    fprintf(stderr, "xlang: wa_fixup apply br=%d wa_ri=%d inner=%d old_nso=%d\n", (int)br, (int)wa_ri, (int)inner,
            (int)b->num_stmt_order);
  abs = b->stmt_order_base;
  if (abs < 0)
    return;
  b->num_stmt_order = 1;
  so = (struct ast_StmtOrderItem *)grow_vec_at(&sc->stmt_order, abs);
  if (!so)
    return;
  so->kind = 6;
  so->idx = wa_ri;
}

/**
 * 若 stmt_order 中 if(kind=5) 条目少于 num_if_stmts，按侧车池 0..n-1 重建（去掉误解析的 expr kind=2）。
 * with_arena 内层块 parse 偶发 `(push!=0)` expr + 仅前 2 条 if kind=5。
 */
void pipeline_block_stmt_order_rebuild_sparse_ifs(struct ast_ASTArena *a, int32_t br) {
  struct ast_Block *b;
  ArenaSidecar *sc;
  struct ast_StmtOrderItem neu[512];
  int32_t nso;
  int32_t nif;
  int32_t i;
  int32_t nn;
  int32_t if_in_order;
  int32_t abs;
  if (!a || br <= 0)
    return;
  b = block_at(a, br);
  sc = arena_sidecar_get(a, 1);
  if (!b || !sc || b->num_if_stmts <= 0)
    return;
  nso = b->num_stmt_order;
  nif = b->num_if_stmts;
  if (nso > 512)
    return;
  if_in_order = 0;
  for (i = 0; i < nso; i++) {
    if (pipeline_block_stmt_order_kind(a, br, i) == 5)
      if_in_order++;
  }
  if (if_in_order >= nif)
    return;
  nn = 0;
  for (i = 0; i < b->num_consts; i++) {
    neu[nn].kind = 0;
    neu[nn].idx = i;
    nn++;
  }
  for (i = 0; i < b->num_lets; i++) {
    neu[nn].kind = 1;
    neu[nn].idx = i;
    nn++;
  }
  for (i = 0; i < nif; i++) {
    neu[nn].kind = 5;
    neu[nn].idx = i;
    nn++;
  }
  for (i = 0; i < nso; i++) {
    uint8_t k = pipeline_block_stmt_order_kind(a, br, i);
    int32_t idx = pipeline_block_stmt_order_idx(a, br, i);
    if (k == 0 || k == 1 || k == 5)
      continue;
    if (k == 2)
      continue; /* 丢弃误解析 cond 片段 expr */
    neu[nn].kind = k;
    neu[nn].idx = idx;
    nn++;
  }
  abs = b->stmt_order_base;
  if (abs < 0)
    return;
  b->num_stmt_order = nn;
  for (i = 0; i < nn; i++) {
    struct ast_StmtOrderItem *so = (struct ast_StmtOrderItem *)grow_vec_at(&sc->stmt_order, abs + i);
    if (so)
      *so = neu[i];
  }
  if (link_abi_getenv("XLANG_ASM_DEBUG"))
    fprintf(stderr, "xlang: if_rebuild br=%d nif=%d old_if_in_order=%d new_nso=%d\n", (int)br, (int)nif, (int)if_in_order,
            (int)nn);
}

/** 对 module 全部函数体块执行 with_arena stmt_order 修补（parse 后/typeck 前调用）。 */
void pipeline_module_fixup_with_arena_stmt_orders(struct ast_Module *m, struct ast_ASTArena *a) {
  int32_t fi;
  if (!m || !a)
    return;
  for (fi = 0; fi < m->num_funcs; fi++) {
    int32_t br = pipeline_module_func_body_ref_at(m, fi);
    struct ast_Block *b;
    int32_t ri;
    if (br <= 0)
      continue;
    b = block_at(a, br);
    if (link_abi_getenv("XLANG_ASM_DEBUG") && b && b->num_regions > 0)
      fprintf(stderr, "xlang: wa_fixup scan fi=%d br=%d nreg=%d nso=%d\n", (int)fi, (int)br, (int)b->num_regions,
              (int)b->num_stmt_order);
    pipeline_block_with_arena_fixup_stmt_order(a, br);
    pipeline_block_stmt_order_rebuild_sparse_ifs(a, br);
    if (b) {
      for (ri = 0; ri < b->num_regions; ri++) {
        int32_t inner = pipeline_block_region_body_ref(a, br, ri);
        if (inner > 0 && inner != br) {
          pipeline_block_stmt_order_fix_prefix_lets(a, inner, block_at(a, inner) ? block_at(a, inner)->num_lets : 0);
          pipeline_block_stmt_order_rebuild_sparse_ifs(a, inner);
        }
      }
    }
  }
}


/* wave1183 G.7: ast_ast_arena_patch + ast_ast_block_* getters + control flow
 * cluster (31 fns) migrated from pipeline_glue.c to this file's EOF.
 *
 * Why colocate: ast.x / typeck.x / codegen.x / backend.x resolve extern
 * pipeline_block_* / pipeline_patch_block_parent_links symbols with an ast_
 * module prefix at codegen time (e.g. ast_ast_block_num_consts), but the
 * authoritative implementations live in ast_pool_block.c with unprefixed
 * C names (pipeline_block_num_consts). These 31 thin forwarders exist
 * solely to satisfy the linker name-mangling gap; colocating them here
 * keeps pipeline_glue.c focused on real glue logic.
 *
 * Sub-clusters:
 *  - ast_ast_arena_patch_block_parent_links (1 fn: delegate to pipeline_patch)
 *  - ast_ast_block_num_* (7 fns: consts/lets/loops/for_loops/if_stmts/
 *    regions/expr_stmts/stmt_order -- read Block.num_X via arena_block_get)
 *  - ast_ast_block_*_ref (13 fns: region_body/const_init/const_type/
 *    let_init/let_type/expr_stmt/final_expr/while_cond/while_body/
 *    for_init/for_cond/for_step/for_body/if_cond/if_then/if_else/
 *    resolve_var_to_type_ref -- pure forwarders to pipeline_block_*)
 *  - ast_ast_block_stmt_order_kind/idx (2 fns: pure forwarders)
 *  - ast_ast_expr_disallows_implicit_tail (1 fn: delegate to implicit_tail)
 *  - ast_ast_expr_apply_call_resolve (1 fn: delegate to pipeline_expr_apply)
 *
 * Contract: every function here is a pure pass-through -- no state mutation,
 *   no branch (except num_* getters which do NULL/bounds check for safety),
 *   single tail call to the underlying pipeline_* impl.
 *
 * PLATFORM: SHARED -- forwarders are platform-agnostic.
 */
void ast_ast_arena_patch_block_parent_links(struct ast_ASTArena *arena, int32_t block_ref, int32_t parent_ref) {
  pipeline_patch_block_parent_links(arena, block_ref, parent_ref);
}

int32_t ast_ast_block_num_consts(struct ast_ASTArena *a, int32_t br) {
  struct ast_Block blk;
  if (!a || br <= 0 || br > a->num_blocks)
    return 0;
  blk = ast_ast_arena_block_get(a, br);
  return blk.num_consts;
}
int32_t ast_ast_block_num_lets(struct ast_ASTArena *a, int32_t br) {
  struct ast_Block blk;
  if (!a || br <= 0 || br > a->num_blocks)
    return 0;
  blk = ast_ast_arena_block_get(a, br);
  return blk.num_lets;
}
int32_t ast_ast_block_num_loops(struct ast_ASTArena *a, int32_t br) {
  struct ast_Block blk;
  if (!a || br <= 0 || br > a->num_blocks)
    return 0;
  blk = ast_ast_arena_block_get(a, br);
  return blk.num_loops;
}
int32_t ast_ast_block_num_for_loops(struct ast_ASTArena *a, int32_t br) {
  struct ast_Block blk;
  if (!a || br <= 0 || br > a->num_blocks)
    return 0;
  blk = ast_ast_arena_block_get(a, br);
  return blk.num_for_loops;
}
int32_t ast_ast_block_num_if_stmts(struct ast_ASTArena *a, int32_t br) {
  struct ast_Block blk;
  if (!a || br <= 0 || br > a->num_blocks)
    return 0;
  blk = ast_ast_arena_block_get(a, br);
  return blk.num_if_stmts;
}
/** M-3: typeck/codegen.x reads Block.num_regions via ast_ prefix. */
int32_t ast_ast_block_num_regions(struct ast_ASTArena *a, int32_t br) {
  struct ast_Block blk;
  if (!a || br <= 0 || br > a->num_blocks)
    return 0;
  blk = ast_ast_arena_block_get(a, br);
  return blk.num_regions;
}
int32_t ast_ast_block_region_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ri) {
  return pipeline_block_region_body_ref(a, br, ri);
}
int32_t ast_ast_block_num_expr_stmts(struct ast_ASTArena *a, int32_t br) {
  struct ast_Block blk;
  if (!a || br <= 0 || br > a->num_blocks)
    return 0;
  blk = ast_ast_arena_block_get(a, br);
  return blk.num_expr_stmts;
}
int32_t ast_ast_block_num_stmt_order(struct ast_ASTArena *a, int32_t br) {
  struct ast_Block blk;
  if (!a || br <= 0 || br > a->num_blocks)
    return 0;
  blk = ast_ast_arena_block_get(a, br);
  return blk.num_stmt_order;
}
uint8_t ast_ast_block_stmt_order_kind(struct ast_ASTArena *a, int32_t br, int32_t si) {
  return pipeline_block_stmt_order_kind(a, br, si);
}
int32_t ast_ast_block_stmt_order_idx(struct ast_ASTArena *a, int32_t br, int32_t si) {
  return pipeline_block_stmt_order_idx(a, br, si);
}
int32_t ast_ast_block_const_init_ref(struct ast_ASTArena *a, int32_t br, int32_t ci) {
  return pipeline_block_const_init_ref(a, br, ci);
}
int32_t ast_ast_block_const_type_ref(struct ast_ASTArena *a, int32_t br, int32_t ci) {
  return pipeline_block_const_type_ref(a, br, ci);
}
int32_t ast_ast_block_let_init_ref(struct ast_ASTArena *a, int32_t br, int32_t li) {
  return pipeline_block_let_init_ref(a, br, li);
}
int32_t ast_ast_block_let_type_ref(struct ast_ASTArena *a, int32_t br, int32_t li) {
  return pipeline_block_let_type_ref(a, br, li);
}
int32_t ast_ast_block_expr_stmt_ref(struct ast_ASTArena *a, int32_t br, int32_t ei) {
  return pipeline_block_expr_stmt_ref(a, br, ei);
}
int32_t ast_ast_block_final_expr_ref(struct ast_ASTArena *a, int32_t br) {
  struct ast_Block blk;
  if (!a || br <= 0 || br > a->num_blocks)
    return 0;
  blk = ast_ast_arena_block_get(a, br);
  return blk.final_expr_ref;
}

/* ast_ast_block_* control flow + ast_ast_expr_* apply cluster (11 fns):
 * while/for/if cond/body/init/step/then/else ref forwarders +
 * resolve_var_to_type_ref + disallows_implicit_tail + apply_call_resolve.
 * All pure pass-through to pipeline_block_ / pipeline_expr_ impls above. */
int32_t ast_ast_block_while_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t wi) {
  return pipeline_block_while_cond_ref(a, br, wi);
}
int32_t ast_ast_block_while_body_ref(struct ast_ASTArena *a, int32_t br, int32_t wi) {
  return pipeline_block_while_body_ref(a, br, wi);
}
int32_t ast_ast_block_for_init_ref(struct ast_ASTArena *a, int32_t br, int32_t fi) {
  return pipeline_block_for_init_ref(a, br, fi);
}
int32_t ast_ast_block_for_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t fi) {
  return pipeline_block_for_cond_ref(a, br, fi);
}
int32_t ast_ast_block_for_step_ref(struct ast_ASTArena *a, int32_t br, int32_t fi) {
  return pipeline_block_for_step_ref(a, br, fi);
}
int32_t ast_ast_block_for_body_ref(struct ast_ASTArena *a, int32_t br, int32_t fi) {
  return pipeline_block_for_body_ref(a, br, fi);
}
int32_t ast_ast_block_if_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t ii) {
  return pipeline_block_if_cond_ref(a, br, ii);
}
int32_t ast_ast_block_if_then_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii) {
  return pipeline_block_if_then_body_ref(a, br, ii);
}
int32_t ast_ast_block_if_else_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii) {
  return pipeline_block_if_else_body_ref(a, br, ii);
}
int32_t ast_ast_block_resolve_var_to_type_ref(struct ast_ASTArena *a, int32_t block_ref, uint8_t *vname, int32_t vlen) {
  return pipeline_block_resolve_var_type_ref(a, block_ref, vname, vlen);
}
int ast_ast_expr_disallows_implicit_tail(struct ast_ASTArena *a, int32_t expr_ref) {
  return implicit_tail_expr_disallowed_by_glue(a, expr_ref);
}
void ast_ast_expr_apply_call_resolve(struct ast_ASTArena *a, int32_t call_expr_ref, int32_t dep_ix, int32_t func_ix) {
  pipeline_expr_apply_call_resolve(a, call_expr_ref, dep_ix, func_ix);
}

/* Forward declarations for ast_ast_arena_block_get (defined in ast_pool_arena.c
 * via wave1183 migration below); needed because num_* getters call it before
 * its definition in the same TU. */
struct ast_Block ast_ast_arena_block_get(struct ast_ASTArena *a, int32_t ref);
