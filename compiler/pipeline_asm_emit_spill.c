/**
 * pipeline_asm_emit_spill.c — asm ELF 7.3 live / Chaitin spill Cap residual
 * (BC 8.3.1).
 *
 * wave156 pure-owned cohesive slices live in runtime_pipeline_abi pure
 * (#[no_mangle]; seed cold twins under #ifndef FROM_X):
 *   · INDEX assign-addr cache BSS + clear/hit
 *   · glue_emit_bulk_mem_copy_spills_elf_c
 *   · glue_index_assign_finish_store / load_from_cached / try_block_let_index_init
 *   · glue_enc_swap_rax_rbx_arm64_elf_c
 *   · glue_expr_kind_is_assign_like_ord + glue_binop_kill_assign_lhs_slots_elf_c
 *
 * wave157 pure-owned frame-sum cluster (same pure TU):
 *   · glue_asm_sum_block_call_spill_bytes
 *   · glue_sum_block_slice_reent_dc_bytes_c
 *   · w157_sum_expr_call_spill_bytes (private walk)
 *
 * Cap residual authority remaining in this host leaf (same TU #include):
 *   · binop VAR slot cache BSS + accessors
 *   · 7.3 live_fwd / CFG merge / phi / break/continue
 *   · Chaitin K=6 coloring + stack-spill preference + evict
 *   · index scratch spill methods + binop_stack_spill bodies
 *     (CAP statics in pipeline_asm_emit_index_helpers.c)
 *
 * G.7: do not re-define pure-owned faces above in this file.
 * Not a separate .o — #included from pipeline_glue.c after index_helpers.
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 *   · LINUX+MACOS x86_64 SysV — spill/reload
 *   · MACOS|ARM64 AAPCS64 — x10–x15 linear scan + index scratch stack
 */


/* wave156 pure-owned faces (extern; live in runtime_pipeline_abi pure).
 * G.7: definitions must not reappear in this Cap residual leaf. PLATFORM: SHARED. */
void glue_index_assign_addr_cache_clear(void);
int32_t glue_index_assign_addr_cache_hit(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                         int32_t base_ref, int32_t idx_ref, int32_t esz);
int32_t glue_emit_bulk_mem_copy_spills_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t src_spill,
                                            int32_t dst_spill, int32_t esz, int32_t ta);
int32_t glue_index_assign_finish_store_elf_c(struct ast_ASTArena *arena,
                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                            struct backend_AsmFuncCtx *ctx, int32_t base_ref,
                                            int32_t idx_ref, int32_t esz, int32_t ta);
int32_t glue_index_load_from_cached_assign_addr_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                     int32_t esz, int32_t ta);
int32_t glue_try_block_let_index_init_from_assign_cache_elf_c(struct ast_ASTArena *arena,
                                                             struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                             struct backend_AsmFuncCtx *ctx,
                                                             int32_t init_ref, int32_t ta);
int32_t glue_enc_swap_rax_rbx_arm64_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t glue_expr_kind_is_assign_like_ord(int32_t ko);
void glue_binop_kill_assign_lhs_slots_elf_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                            int32_t assign_expr_ref);

/* wave156: restore Cap residual structural INDEX keys (used by index-scratch methods;
 * pure owns assign-addr cache which has its own pure key helpers). PLATFORM: SHARED. */
/** Mix one byte/word into a stable 64-bit INDEX addr cache key. */
static uint64_t glue_index_addr_key_mix64(uint64_t h, uint64_t v) {
  return h * 1315423911u + v + 0x9e3779b97f4a7c15ULL;
}

/**
 * Structural hash of an index sub-expression (VAR/LIT/ADD/SUB/MUL); unrelated shapes fall back to ref id.
 */
static uint64_t glue_index_expr_struct_key_elf_c(struct ast_ASTArena *arena, int32_t ref) {
  int32_t ko;
  int32_t left_ref;
  int32_t right_ref;
  uint8_t name[128];
  int32_t nlen;
  int32_t i;
  uint64_t h;
  if (!arena || ref <= 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, ref);
  h = glue_index_addr_key_mix64(0, (uint64_t)(uint32_t)ko);
  if (ko == 0)
    return glue_index_addr_key_mix64(h, (uint64_t)(uint32_t)pipeline_expr_int_val_at(arena, ref));
  if (ko == 3) {
    nlen = pipeline_expr_var_name_len(arena, ref);
    if (nlen <= 0 || nlen > 127)
      return h;
    pipeline_expr_var_name_into(arena, ref, name);
    for (i = 0; i < nlen; i++)
      h = glue_index_addr_key_mix64(h, name[i]);
    return h;
  }
  if (ko >= 4 && ko <= 6) {
    left_ref = pipeline_expr_binop_left_ref_at(arena, ref);
    right_ref = pipeline_expr_binop_right_ref_at(arena, ref);
    h = glue_index_addr_key_mix64(h, glue_index_expr_struct_key_elf_c(arena, left_ref));
    return glue_index_addr_key_mix64(h, glue_index_expr_struct_key_elf_c(arena, right_ref));
  }
  return glue_index_addr_key_mix64(h, (uint64_t)(uint32_t)ref);
}

/** Cache key for INDEX base (VAR name hash; otherwise pool ref). */
static uint64_t glue_index_base_struct_key_elf_c(struct ast_ASTArena *arena, int32_t base_ref) {
  if (!arena || base_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, base_ref) == 3)
    return glue_index_expr_struct_key_elf_c(arena, base_ref);
  return glue_index_addr_key_mix64(1, (uint64_t)(uint32_t)base_ref);
}




/* Forward decls / callees defined elsewhere in the same TU:
 * - glue_var_expr_stack_off_elf_c (def after assign/index includes)
 * - glue_emit_index_eff_addr_scaled_elf_c (runtime_pipeline_abi pure wave147)
 * - pipeline_asm_emit_expr_elf_rec / backend_enc_* / asm_ctx_local_*
 * - CAP statics: glue_binop_stack_spill_* arrays, glue_index_scratch_stack_depth,
 *   glue_index_minus_pair_cache, glue_index_subadd3_sum_cache
 *   (pipeline_asm_emit_index_helpers.c, earlier in TU)
 * - g_pipeline_asm_emit_module / g_pipeline_asm_emit_func_index
 *
 * Note: method bodies for binop_stack_spill / index scratch live here;
 * CAP statics stay in index_helpers (shared depth with try_index forest).
 */


/**
 * 7.3 block-level binop VAR 槽缓存：rbx/rax 已装入的栈槽 off，跨连续 let binop 免重复 ldur。
 * 仅用于 glue_try_binop_load_operand_elf_c 的 EXPR_VAR 快路径。
 */
typedef struct {
  int32_t valid_rax;
  int32_t valid_rbx;
  /** arm64：线性 scan spill VAR 槽（x10；|live|max≥5→x11 … ≥9→x15）。 */
  int32_t valid_x10;
  int32_t valid_x11;
  int32_t valid_x12;
  int32_t valid_x13;
  int32_t valid_x14;
  int32_t valid_x15;
  size_t ctx_key;
  int32_t rax_off;
  int32_t rbx_off;
  int32_t x10_off;
  int32_t x11_off;
  int32_t x12_off;
  int32_t x13_off;
  int32_t x14_off;
  int32_t x15_off;
} GlueBinopVarSlotCache;

static GlueBinopVarSlotCache glue_binop_var_slot_cache;

/** 清空 binop VAR 槽缓存（块入口 / slow binop / 按位结果写 rbx 等）。 */
void glue_binop_var_slot_cache_clear(void) {
  glue_binop_var_slot_cache.valid_rax = 0;
  glue_binop_var_slot_cache.valid_rbx = 0;
  glue_binop_var_slot_cache.valid_x10 = 0;
  glue_binop_var_slot_cache.valid_x11 = 0;
  glue_binop_var_slot_cache.valid_x12 = 0;
  glue_binop_var_slot_cache.valid_x13 = 0;
  glue_binop_var_slot_cache.valid_x14 = 0;
  glue_binop_var_slot_cache.valid_x15 = 0;
}

/** 二元结果在 rax 时失效 rax 槽（rbx 仍可保留右 VAR，如 add 后 a+b 再 a&b）。 */
/* wave149 Cap residual: pure binop leave (was static). PLATFORM: SHARED. */
void glue_binop_var_slot_cache_invalidate_rax(void) {
  glue_binop_var_slot_cache.valid_rax = 0;
}

/** rbx 将装入非 VAR 操作数（如字面量）时失效 rbx 槽。 */
/* wave137 Cap residual for cmp pure leave: non-static face. */
void glue_binop_var_slot_cache_invalidate_rbx(void) {
  glue_binop_var_slot_cache.valid_rbx = 0;
}

/*
 * wave149 Cap residual: pure binop leave field accessors for spill-owned cache BSS.
 * Pure cannot see static GlueBinopVarSlotCache; single authority stays in spill residual.
 * PLATFORM: SHARED freestanding dual-slot cache.
 */
int32_t glue_binop_var_slot_cache_ctx_matches(void *ctx) {
  return glue_binop_var_slot_cache.ctx_key == (size_t)ctx ? 1 : 0;
}
int32_t glue_binop_var_slot_cache_hit_rax(void *ctx, int32_t off) {
  return (glue_binop_var_slot_cache.valid_rax && glue_binop_var_slot_cache.ctx_key == (size_t)ctx &&
          glue_binop_var_slot_cache.rax_off == off)
             ? 1
             : 0;
}
int32_t glue_binop_var_slot_cache_hit_rbx(void *ctx, int32_t off) {
  return (glue_binop_var_slot_cache.valid_rbx && glue_binop_var_slot_cache.ctx_key == (size_t)ctx &&
          glue_binop_var_slot_cache.rbx_off == off)
             ? 1
             : 0;
}
int32_t glue_binop_var_slot_cache_valid_rax_get(void) { return glue_binop_var_slot_cache.valid_rax; }
int32_t glue_binop_var_slot_cache_valid_rbx_get(void) { return glue_binop_var_slot_cache.valid_rbx; }
int32_t glue_binop_var_slot_cache_rax_off_get(void) { return glue_binop_var_slot_cache.rax_off; }
int32_t glue_binop_var_slot_cache_rbx_off_get(void) { return glue_binop_var_slot_cache.rbx_off; }
void glue_binop_var_slot_cache_set_ctx_key(void *ctx) {
  glue_binop_var_slot_cache.ctx_key = (size_t)ctx;
}
void glue_binop_var_slot_cache_set_rax(void *ctx, int32_t off) {
  glue_binop_var_slot_cache.ctx_key = (size_t)ctx;
  glue_binop_var_slot_cache.valid_rax = 1;
  glue_binop_var_slot_cache.rax_off = off;
}
void glue_binop_var_slot_cache_set_rbx(void *ctx, int32_t off) {
  glue_binop_var_slot_cache.ctx_key = (size_t)ctx;
  glue_binop_var_slot_cache.valid_rbx = 1;
  glue_binop_var_slot_cache.rbx_off = off;
}
void glue_binop_var_slot_cache_set_valid_rax(int32_t v) { glue_binop_var_slot_cache.valid_rax = v; }
void glue_binop_var_slot_cache_set_valid_rbx(int32_t v) { glue_binop_var_slot_cache.valid_rbx = v; }
void glue_binop_var_slot_cache_set_rax_off(int32_t off) { glue_binop_var_slot_cache.rax_off = off; }
void glue_binop_var_slot_cache_set_rbx_off(int32_t off) { glue_binop_var_slot_cache.rbx_off = off; }

/** arm64：交换 rax/x0 与 rbx/x1（交换律 VAR 槽命中后对齐 add 操作数序）。 */

/** 栈槽 var 被写入后失效对应 rax/rbx 缓存项。 */
void glue_binop_var_slot_cache_invalidate_slot(int32_t off) {
  if (glue_binop_var_slot_cache.valid_rax && glue_binop_var_slot_cache.rax_off == off)
    glue_binop_var_slot_cache.valid_rax = 0;
  if (glue_binop_var_slot_cache.valid_rbx && glue_binop_var_slot_cache.rbx_off == off)
    glue_binop_var_slot_cache.valid_rbx = 0;
  if (glue_binop_var_slot_cache.valid_x10 && glue_binop_var_slot_cache.x10_off == off)
    glue_binop_var_slot_cache.valid_x10 = 0;
  if (glue_binop_var_slot_cache.valid_x11 && glue_binop_var_slot_cache.x11_off == off)
    glue_binop_var_slot_cache.valid_x11 = 0;
  if (glue_binop_var_slot_cache.valid_x12 && glue_binop_var_slot_cache.x12_off == off)
    glue_binop_var_slot_cache.valid_x12 = 0;
  if (glue_binop_var_slot_cache.valid_x13 && glue_binop_var_slot_cache.x13_off == off)
    glue_binop_var_slot_cache.valid_x13 = 0;
  if (glue_binop_var_slot_cache.valid_x14 && glue_binop_var_slot_cache.x14_off == off)
    glue_binop_var_slot_cache.valid_x14 = 0;
  if (glue_binop_var_slot_cache.valid_x15 && glue_binop_var_slot_cache.x15_off == off)
    glue_binop_var_slot_cache.valid_x15 = 0;
  glue_binop_stack_spill_drop_off(off);
}

/**
 * 7.3 定义点活跃性：let/assign 写栈槽后 kill 该槽缓存并失效 rax（结果已落栈）。
 */
void glue_binop_var_slot_cache_kill_def_at_slot(int32_t off) {
  if (off >= 0)
    glue_binop_var_slot_cache_invalidate_slot(off);
  glue_binop_var_slot_cache_invalidate_rax();
}


/** Forward decl: rec emit 是否会 clobber rbx（定义见 binop 活跃性 helpers）。 */
int32_t glue_expr_emit_may_clobber_rbx_elf_c(struct ast_ASTArena *arena, int32_t expr_ref);

/** Drop cached INDEX effective address (rbx no longer trusted for reuse). */

/** CFG 写槽扫描所需 AST 块 API（定义见本文件后部；须先于 glue_cfg_collect_block_def_offs）。 */
int32_t ast_ast_block_num_consts(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_lets(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_stmt_order(struct ast_ASTArena *a, int32_t br);
uint8_t ast_ast_block_stmt_order_kind(struct ast_ASTArena *a, int32_t br, int32_t si);
int32_t ast_ast_block_stmt_order_idx(struct ast_ASTArena *a, int32_t br, int32_t si);
int32_t ast_ast_block_num_loops(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_for_loops(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_if_stmts(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_regions(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_region_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ri);
int32_t ast_ast_block_num_expr_stmts(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_final_expr_ref(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_while_body_ref(struct ast_ASTArena *a, int32_t br, int32_t wi);
int32_t ast_ast_block_while_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t wi);
int32_t ast_ast_block_for_body_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
int32_t ast_ast_block_for_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
int32_t ast_ast_block_for_step_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
int32_t ast_pipeline_block_if_then_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
int32_t ast_pipeline_block_if_else_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
int32_t ast_pipeline_block_expr_stmt_ref(struct ast_ASTArena *a, int32_t br, int32_t ei);
int32_t ast_pipeline_block_const_init_ref(struct ast_ASTArena *a, int32_t br, int32_t ci);
int32_t ast_pipeline_block_let_init_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
struct ast_Block *pipeline_arena_block_ptr(struct ast_ASTArena *a, int32_t block_ref);

/** CFG 汇合点收集的写槽 off 上限（块内 let/assign 并集）。 */
#define GLUE_CFG_DEF_OFFS_CAP 32

/** 写槽列表是否已含 off。 */
static int32_t glue_cfg_def_offs_contains(const int32_t *buf, int32_t n, int32_t off) {
  int32_t i;
  for (i = 0; i < n; i++) {
    if (buf[i] == off)
      return 1;
  }
  return 0;
}

/** 向写槽并集追加一项（去重）。 */
static void glue_cfg_def_offs_add(int32_t *buf, int32_t cap, int32_t *n, int32_t off) {
  if (!buf || !n || off < 0 || *n >= cap)
    return;
  if (glue_cfg_def_offs_contains(buf, *n, off))
    return;
  buf[(*n)++] = off;
}

/**
 * 7.3：扫描块 stmt_order，收集本块（含嵌套 if/while/for 体）内被定义的栈槽 off。
 * let/const 初值写槽与 assign-like 左值 VAR 均视为定义点。
 */
static void glue_cfg_collect_block_def_offs_elf_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                   int32_t block_ref, int32_t *buf, int32_t cap, int32_t *n) {
  int32_t nso;
  int32_t i;
  int32_t slot_base;
  int32_t nconst;
  int32_t nlet;
  if (!arena || !ctx || block_ref <= 0 || !buf || !n || cap <= 0)
    return;
  nso = ast_ast_block_num_stmt_order(arena, block_ref);
  slot_base = backend_block_slot_base_for(ctx, arena, block_ref);
  nconst = ast_ast_block_num_consts(arena, block_ref);
  nlet = ast_ast_block_num_lets(arena, block_ref);
  for (i = 0; i < nso; i++) {
    uint8_t item_kind = ast_ast_block_stmt_order_kind(arena, block_ref, i);
    int32_t idx = ast_ast_block_stmt_order_idx(arena, block_ref, i);
    if (item_kind == 0) {
      if (idx >= 0 && idx < nconst)
        glue_cfg_def_offs_add(buf, cap, n, backend_asm_ctx_slot_offset(ctx, slot_base + idx));
    } else if (item_kind == 1) {
      if (idx >= 0 && idx < nlet)
        glue_cfg_def_offs_add(buf, cap, n, backend_asm_ctx_slot_offset(ctx, slot_base + nconst + idx));
    } else if (item_kind == 2) {
      if (idx >= 0 && idx < ast_ast_block_num_expr_stmts(arena, block_ref)) {
        int32_t expr_ref = ast_pipeline_block_expr_stmt_ref(arena, block_ref, idx);
        int32_t left_ref;
        int32_t off;
        if (expr_ref > 0 && glue_expr_kind_is_assign_like_ord(pipeline_expr_kind_ord_at(arena, expr_ref))) {
          left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
          if (left_ref > 0 && pipeline_expr_kind_ord_at(arena, left_ref) == GLUE_EXPR_KIND_VAR) {
            off = glue_var_expr_stack_off_elf_c(arena, ctx, left_ref);
            glue_cfg_def_offs_add(buf, cap, n, off);
          }
        }
      }
    } else if (item_kind == 3) {
      if (idx >= 0 && idx < ast_ast_block_num_loops(arena, block_ref)) {
        int32_t body_ref = ast_ast_block_while_body_ref(arena, block_ref, idx);
        if (body_ref > 0)
          glue_cfg_collect_block_def_offs_elf_c(arena, ctx, body_ref, buf, cap, n);
      }
    } else if (item_kind == 4) {
      if (idx >= 0 && idx < ast_ast_block_num_for_loops(arena, block_ref)) {
        int32_t body_ref = ast_ast_block_for_body_ref(arena, block_ref, idx);
        if (body_ref > 0)
          glue_cfg_collect_block_def_offs_elf_c(arena, ctx, body_ref, buf, cap, n);
      }
    } else if (item_kind == 5) {
      if (idx >= 0 && idx < ast_ast_block_num_if_stmts(arena, block_ref)) {
        int32_t then_ref = ast_pipeline_block_if_then_body_ref(arena, block_ref, idx);
        int32_t else_ref = ast_pipeline_block_if_else_body_ref(arena, block_ref, idx);
        if (then_ref > 0)
          glue_cfg_collect_block_def_offs_elf_c(arena, ctx, then_ref, buf, cap, n);
        if (else_ref > 0)
          glue_cfg_collect_block_def_offs_elf_c(arena, ctx, else_ref, buf, cap, n);
      }
    } else if (item_kind == 6) {
      /** M-3 / MEM-C1：region 与 with_arena 共用 kind=6；运行时等价嵌套块体。 */
      if (idx >= 0 && idx < ast_ast_block_num_regions(arena, block_ref)) {
        int32_t reg_body = ast_ast_block_region_body_ref(arena, block_ref, idx);
        if (reg_body > 0)
          glue_cfg_collect_block_def_offs_elf_c(arena, ctx, reg_body, buf, cap, n);
      }
    }
  }
}

/** 按 off 列表失效 binop 槽命中，并清空 rax 缓存位。 */
static void glue_binop_invalidate_slots_in_list(const int32_t *offs, int32_t n) {
  int32_t i;
  glue_binop_var_slot_cache_invalidate_rax();
  for (i = 0; i < n; i++)
    glue_binop_var_slot_cache_invalidate_slot(offs[i]);
}

/**
 * 7.3 CFG 汇合点：按分支写槽并集选择性失效 binop 槽；INDEX 址 cache 仍保守清空。
 * branch_b_ref==0 时仅扫描 branch_a（用于 while/for 单入口体）。
 */
/* wave129 Cap residual: pure block_if leave + residual fold/while (was static).
 * PLATFORM: SHARED freestanding emit. */
void glue_asm_cache_invalidate_at_cfg_merge_selective(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                      int32_t branch_a_ref, int32_t branch_b_ref) {
  int32_t offs[GLUE_CFG_DEF_OFFS_CAP];
  int32_t n = 0;
  glue_index_assign_addr_cache_clear();
  if (branch_a_ref > 0)
    glue_cfg_collect_block_def_offs_elf_c(arena, ctx, branch_a_ref, offs, GLUE_CFG_DEF_OFFS_CAP, &n);
  if (branch_b_ref > 0)
    glue_cfg_collect_block_def_offs_elf_c(arena, ctx, branch_b_ref, offs, GLUE_CFG_DEF_OFFS_CAP, &n);
  if (n == 0)
    glue_binop_var_slot_cache_clear();
  else
    glue_binop_invalidate_slots_in_list(offs, n);
}

/**
 * 7.3 if φ（最小）：then/else 均定义同一栈槽时显式失效 binop cache（两路径版本合并）。
 * 与 selective 并集 kill 互补：强调「双支写」槽不可沿用汇合前 rax/rbx 中的旧值。
 */
/* wave129 Cap residual: pure block_if leave (was static). PLATFORM: SHARED. */
void glue_asm_if_phi_invalidate_both_branch_defs(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                 int32_t then_ref, int32_t else_ref) {
  int32_t then_offs[GLUE_CFG_DEF_OFFS_CAP];
  int32_t else_offs[GLUE_CFG_DEF_OFFS_CAP];
  int32_t then_n;
  int32_t else_n;
  int32_t i;
  int32_t j;
  if (!arena || !ctx || then_ref <= 0 || else_ref <= 0)
    return;
  then_n = 0;
  else_n = 0;
  glue_cfg_collect_block_def_offs_elf_c(arena, ctx, then_ref, then_offs, GLUE_CFG_DEF_OFFS_CAP, &then_n);
  glue_cfg_collect_block_def_offs_elf_c(arena, ctx, else_ref, else_offs, GLUE_CFG_DEF_OFFS_CAP, &else_n);
  for (i = 0; i < then_n; i++) {
    for (j = 0; j < else_n; j++) {
      if (then_offs[i] == else_offs[j] && then_offs[i] >= 0)
        glue_binop_var_slot_cache_invalidate_slot(then_offs[i]);
    }
  }
  if (then_n > 0 && else_n > 0)
    glue_binop_var_slot_cache_invalidate_rax();
}

/** 无分支体信息时回退为整表清空。 */
static void glue_asm_cache_invalidate_at_cfg_merge(void) {
  glue_index_assign_addr_cache_clear();
  glue_binop_var_slot_cache_clear();
}

/** 7.3 基本块前向活跃集：仅用于无 if/while/for 的 stmt_order 线性块。 */
typedef struct {
  int32_t offs[GLUE_CFG_DEF_OFFS_CAP];
  int32_t n;
} GlueBlockLiveFwd;

static GlueBlockLiveFwd glue_block_live_fwd;
static GlueBlockLiveFwd glue_block_live_at_stmt[32];
/** if/while/for 进入前父块活跃集快照（顺序 stmt 复用）。 */
static GlueBlockLiveFwd glue_live_snap_before_if;
/** 刚发射完的子块出口活跃集（含体内 if/while 汇合后的前向集）。 */
static GlueBlockLiveFwd glue_block_live_sub_exit_snap;
/** 循环体内 break 出口活跃集（按嵌套深度栈，与 loop label 栈对齐）。 */
#define GLUE_LOOP_BREAK_LIVE_DEPTH 8
static GlueBlockLiveFwd glue_loop_break_exit_live_stack[GLUE_LOOP_BREAK_LIVE_DEPTH];
/** continue 跳回头部时的活跃集（保守并入 loop 出口 ∪，利于槽 cache 正确性）。 */
static GlueBlockLiveFwd glue_loop_continue_head_live_stack[GLUE_LOOP_BREAK_LIVE_DEPTH];
static int32_t glue_loop_break_exit_depth;
static int32_t glue_block_live_fwd_active;
/** 父块含 if/while/for：用前向维护 glue_block_live_fwd + if 汇合 union。 */
static int32_t glue_block_live_cfg_parent;
/** 当前线性块 stmt 边界最大 |live_in|（7.3 线性 scan 第一步诊断）。 */
static int32_t glue_asm73_linear_max_live_n;
/** 正在发射的 stmt_order 下标（final_expr 前设为 nso，供表达式内压力驱逐）。 */
static int32_t glue_block_emit_stmt_i;
/** 7.3 着色原型：峰值活跃 stmt 上 next-use 最近的几枚栈槽，spill 覆盖时优先保护。 */
static int32_t glue_asm73_pin_spill_off[6];
/** 7.3 K=6 干涉着色：峰值同时活跃栈槽 → 固定 x10–x15 偏好（着色表最多 16 项/块）。 */
/** 着色表容量：覆盖十四元 return + cfg 子块 let（原 12 不足则 which=6 无法入表）。 */
#define GLUE_ASM73_SPILL_COLOR_MAP_CAP 16
static int32_t glue_asm73_spill_color_off[GLUE_ASM73_SPILL_COLOR_MAP_CAP];
static int8_t glue_asm73_spill_color_which[GLUE_ASM73_SPILL_COLOR_MAP_CAP];
static int32_t glue_asm73_spill_color_n;
/** 1=cfg 父块发射中：next-use 用前向 stmt 扫描（非反向 live_in）。 */
static int32_t glue_asm73_cfg_coloring_active;
static GlueBlockLiveFwd glue_asm73_cfg_peak_live;
static int32_t glue_asm73_cfg_peak_stmt_i;
/** cfg 父块 final_expr 直接引用的 VAR 槽数（长 return 链阈值；非整块 |live|）。 */
static int32_t glue_asm73_cfg_final_expr_use_n;

/**
 * 7.3：binop 压力驱逐的 |live| 阈值（默认 3 保留 repeat_add；块 max≥6 提到 4）。
 */
static int32_t glue_asm73_pressure_live_thresh(void) {
  if (glue_asm73_linear_max_live_n >= 12)
    return 8;
  if (glue_asm73_linear_max_live_n >= 9)
    return 7;
  if (glue_asm73_linear_max_live_n >= 8)
    return 6;
  if (glue_asm73_linear_max_live_n >= 7)
    return 5;
  if (glue_asm73_linear_max_live_n >= 6)
    return 4;
  return 3;
}
/** 线性 scan 第二步：预计算 live_in 时缓存块上下文，供 next-use 距离查询。 */
static struct ast_ASTArena *glue_asm73_linear_arena;
static struct backend_AsmFuncCtx *glue_asm73_linear_ctx;
static int32_t glue_asm73_linear_block_ref;
static int32_t glue_asm73_linear_slot_base;
static int32_t glue_asm73_linear_nconst;
static int32_t glue_asm73_linear_nlet;
static int32_t glue_asm73_linear_nso;

void glue_live_fwd_clear(GlueBlockLiveFwd *live) {
  if (live)
    live->n = 0;
}

static int32_t glue_live_fwd_contains(const GlueBlockLiveFwd *live, int32_t off) {
  int32_t i;
  if (!live || off < 0)
    return 0;
  for (i = 0; i < live->n; i++) {
    if (live->offs[i] == off)
      return 1;
  }
  return 0;
}

void glue_live_fwd_add(GlueBlockLiveFwd *live, int32_t off) {
  if (!live || off < 0)
    return;
  glue_cfg_def_offs_add(live->offs, GLUE_CFG_DEF_OFFS_CAP, &live->n, off);
}

/** 拷贝活跃集（stmt 边界 live_in 快照）。
 * wave129 Cap residual: pure block_if leave may Cap residual via *u8 alias.
 * PLATFORM: SHARED. */
void glue_live_fwd_copy(GlueBlockLiveFwd *dst, const GlueBlockLiveFwd *src) {
  if (!dst || !src)
    return;
  dst->n = src->n;
  if (src->n > 0)
    memcpy(dst->offs, src->offs, (size_t)src->n * sizeof(int32_t));
}

/**
 * Copy glue_live_snap_before_if into opaque live buffer (sizeof GlueBlockLiveFwd).
 * wave129 Cap residual: pure block_if leave no-else path (parent snap → else_end).
 * @param dst void* - GlueBlockLiveFwd* overlay; null → no-op
 * PLATFORM: SHARED freestanding emit.
 */
void glue_live_fwd_copy_from_snap_before_if(void *dst) {
  if (!dst)
    return;
  glue_live_fwd_copy((GlueBlockLiveFwd *)dst, &glue_live_snap_before_if);
}

/** 将 addend 中活跃槽并入 dst（并集，用于 if 汇合）。 */
static void glue_live_fwd_union_into(GlueBlockLiveFwd *dst, const GlueBlockLiveFwd *addend) {
  int32_t i;
  if (!dst || !addend)
    return;
  for (i = 0; i < addend->n; i++)
    glue_live_fwd_add(dst, addend->offs[i]);
}

/** 进入循环：清空当前层 break/continue 活跃累积。 */
/* wave155: un-static for pure fold_count leave Cap residual. PLATFORM: SHARED. */
void glue_loop_break_exit_push(void) {
  if (glue_loop_break_exit_depth < GLUE_LOOP_BREAK_LIVE_DEPTH) {
    glue_live_fwd_clear(&glue_loop_break_exit_live_stack[glue_loop_break_exit_depth]);
    glue_live_fwd_clear(&glue_loop_continue_head_live_stack[glue_loop_break_exit_depth]);
    glue_loop_break_exit_depth++;
  }
}

/** 离开循环：弹出 break 出口栈（须在 loop 汇合之后调用）。 */
/* wave155: un-static for pure fold_count leave Cap residual. PLATFORM: SHARED. */
void glue_loop_break_exit_pop(void) {
  if (glue_loop_break_exit_depth > 0)
    glue_loop_break_exit_depth--;
}

/**
 * 7.3 break：把当前（或子块快照）活跃集并入本层 loop 的 break 出口 ∪，供循环汇合使用。
 */
static void glue_loop_break_exit_note_current(void) {
  int32_t d;
  if (glue_loop_break_exit_depth <= 0)
    return;
  d = glue_loop_break_exit_depth - 1;
  if (glue_block_live_fwd_active)
    glue_live_fwd_union_into(&glue_loop_break_exit_live_stack[d], &glue_block_live_fwd);
  else
    glue_live_fwd_union_into(&glue_loop_break_exit_live_stack[d], &glue_block_live_sub_exit_snap);
}

/** EXPR_BREAK：记录出口活跃集并跳转当前循环 exit 标签（ctx.break_label）。 */
static int32_t pipeline_asm_emit_break_elf_impl(struct ast_ASTArena *arena,
                                                struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                struct backend_AsmFuncCtx *ctx, int32_t ta) {
  pipeline_glue_AsmFuncCtxLayout *ly;
  (void)arena;
  ly = pipeline_asm_ctx_layout(ctx);
  if (ly->break_len <= 0)
    return -1;
  glue_loop_break_exit_note_current();
  return backend_enc_jmp_arch(elf_ctx, ly->break_label, ly->break_len, ta);
}

/**
 * 7.3 continue：把当前活跃集并入本层 loop 的 continue 头部 ∪（保守参与出口汇合）。
 */
static void glue_loop_continue_head_note_current(void) {
  int32_t d;
  if (glue_loop_break_exit_depth <= 0)
    return;
  d = glue_loop_break_exit_depth - 1;
  if (glue_block_live_fwd_active)
    glue_live_fwd_union_into(&glue_loop_continue_head_live_stack[d], &glue_block_live_fwd);
  else
    glue_live_fwd_union_into(&glue_loop_continue_head_live_stack[d], &glue_block_live_sub_exit_snap);
}

/** EXPR_CONTINUE：记录头部活跃集并跳转当前循环 head 标签（ctx.continue_label）。 */
static int32_t pipeline_asm_emit_continue_elf_impl(struct ast_ASTArena *arena,
                                                   struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                   struct backend_AsmFuncCtx *ctx, int32_t ta) {
  pipeline_glue_AsmFuncCtxLayout *ly;
  (void)arena;
  ly = pipeline_asm_ctx_layout(ctx);
  if (ly->continue_len <= 0)
    return -1;
  glue_loop_continue_head_note_current();
  return backend_enc_jmp_arch(elf_ctx, ly->continue_label, ly->continue_len, ta);
}

/**
 * EXPR_BREAK / EXPR_CONTINUE ELF faces (X emit_expr_elf single-line delegates).
 * wave1014 G.7: folded from pipeline_glue residual next to static impls.
 * PLATFORM: SHARED — product residual C; same TU as break/continue *_elf_impl.
 */
int32_t pipeline_asm_emit_break_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                      struct backend_AsmFuncCtx *ctx, int32_t ta) {
  return pipeline_asm_emit_break_elf_impl(arena, elf_ctx, ctx, ta);
}

int32_t pipeline_asm_emit_continue_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                         struct backend_AsmFuncCtx *ctx, int32_t ta) {
  return pipeline_asm_emit_continue_elf_impl(arena, elf_ctx, ctx, ta);
}

static void glue_live_fwd_remove(GlueBlockLiveFwd *live, int32_t off) {
  int32_t i;
  int32_t j;
  if (!live || off < 0)
    return;
  for (i = 0; i < live->n; i++) {
    if (live->offs[i] == off) {
      for (j = i + 1; j < live->n; j++)
        live->offs[j - 1] = live->offs[j];
      live->n--;
      return;
    }
  }
}

/** 块 stmt_order 是否含 if/while/for/goto（有则不做线性前向活跃）。 */
int32_t glue_block_stmt_order_has_cfg(struct ast_ASTArena *arena, int32_t block_ref) {
  int32_t nso;
  int32_t i;
  if (!arena || block_ref <= 0)
    return 0;
  nso = ast_ast_block_num_stmt_order(arena, block_ref);
  for (i = 0; i < nso; i++) {
    uint8_t k = ast_ast_block_stmt_order_kind(arena, block_ref, i);
    /* wave387: kind 7 labeled/goto is control flow (same class as if/while/for). */
    if (k == 3 || k == 4 || k == 5 || k == 7)
      return 1;
  }
  return 0;
}

/**
 * 收集表达式中出现的 VAR 栈槽（用于 gen 集）；仅 VAR/二元/RETURN 操作数，够覆盖 binop 块测例。
 */
void glue_live_fwd_collect_expr_uses(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                            int32_t expr_ref, GlueBlockLiveFwd *gen) {
  int32_t ko;
  int32_t left_ref;
  int32_t right_ref;
  int32_t op_ref;
  int32_t off;
  if (!arena || !ctx || !gen || expr_ref <= 0)
    return;
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ko == GLUE_EXPR_KIND_VAR) {
    off = glue_var_expr_stack_off_elf_c(arena, ctx, expr_ref);
    glue_live_fwd_add(gen, off);
    return;
  }
  if (ko >= 4 && ko <= 21) {
    left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    glue_live_fwd_collect_expr_uses(arena, ctx, left_ref, gen);
    glue_live_fwd_collect_expr_uses(arena, ctx, right_ref, gen);
    return;
  }
  if (ko == 41) {
    op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    glue_live_fwd_collect_expr_uses(arena, ctx, op_ref, gen);
  }
}

/** 按当前前向活跃集修剪 binop 槽缓存（死槽不再命中 rax/rbx）。 */
void glue_binop_cache_intersect_live_fwd(void) {
  int32_t i;
  if (!glue_block_live_fwd_active)
    return;
  if (glue_binop_var_slot_cache.valid_rax &&
      !glue_live_fwd_contains(&glue_block_live_fwd, glue_binop_var_slot_cache.rax_off))
    glue_binop_var_slot_cache.valid_rax = 0;
  if (glue_binop_var_slot_cache.valid_rbx &&
      !glue_live_fwd_contains(&glue_block_live_fwd, glue_binop_var_slot_cache.rbx_off))
    glue_binop_var_slot_cache.valid_rbx = 0;
  if (glue_binop_var_slot_cache.valid_x10 &&
      !glue_live_fwd_contains(&glue_block_live_fwd, glue_binop_var_slot_cache.x10_off))
    glue_binop_var_slot_cache.valid_x10 = 0;
  if (glue_binop_var_slot_cache.valid_x11 &&
      !glue_live_fwd_contains(&glue_block_live_fwd, glue_binop_var_slot_cache.x11_off))
    glue_binop_var_slot_cache.valid_x11 = 0;
  if (glue_binop_var_slot_cache.valid_x12 &&
      !glue_live_fwd_contains(&glue_block_live_fwd, glue_binop_var_slot_cache.x12_off))
    glue_binop_var_slot_cache.valid_x12 = 0;
  if (glue_binop_var_slot_cache.valid_x13 &&
      !glue_live_fwd_contains(&glue_block_live_fwd, glue_binop_var_slot_cache.x13_off))
    glue_binop_var_slot_cache.valid_x13 = 0;
  if (glue_binop_var_slot_cache.valid_x14 &&
      !glue_live_fwd_contains(&glue_block_live_fwd, glue_binop_var_slot_cache.x14_off))
    glue_binop_var_slot_cache.valid_x14 = 0;
  if (glue_binop_var_slot_cache.valid_x15 &&
      !glue_live_fwd_contains(&glue_block_live_fwd, glue_binop_var_slot_cache.x15_off))
    glue_binop_var_slot_cache.valid_x15 = 0;
  for (i = 0; i < glue_binop_stack_spill_n; ) {
    if (glue_live_fwd_contains(&glue_block_live_fwd, glue_binop_stack_spill_off[i])) {
      i++;
      continue;
    }
    glue_binop_stack_spill_drop_off(glue_binop_stack_spill_off[i]);
  }
}

/**
 * 为 stmt_order[i] 填 gen/kill（kill 为定义槽，gen 为右值/初值使用的 VAR 槽）。
 */
static void glue_block_stmt_gen_kill(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx, int32_t block_ref,
                                     int32_t slot_base, int32_t nconst, int32_t nlet, int32_t stmt_i,
                                     GlueBlockLiveFwd *gen, GlueBlockLiveFwd *kill) {
  uint8_t item_kind;
  int32_t idx;
  int32_t expr_ref;
  int32_t left_ref;
  int32_t off;
  if (!arena || !ctx || !gen || !kill)
    return;
  glue_live_fwd_clear(gen);
  glue_live_fwd_clear(kill);
  item_kind = ast_ast_block_stmt_order_kind(arena, block_ref, stmt_i);
  idx = ast_ast_block_stmt_order_idx(arena, block_ref, stmt_i);
  if (item_kind == 0) {
    if (idx >= 0 && idx < nconst) {
      glue_live_fwd_add(kill, backend_asm_ctx_slot_offset(ctx, slot_base + idx));
      glue_live_fwd_collect_expr_uses(arena, ctx, ast_pipeline_block_const_init_ref(arena, block_ref, idx), gen);
    }
  } else if (item_kind == 1) {
    if (idx >= 0 && idx < nlet) {
      glue_live_fwd_add(kill, backend_asm_ctx_slot_offset(ctx, slot_base + nconst + idx));
      glue_live_fwd_collect_expr_uses(arena, ctx, ast_pipeline_block_let_init_ref(arena, block_ref, idx), gen);
    }
  } else if (item_kind == 2) {
    if (idx >= 0 && idx < ast_ast_block_num_expr_stmts(arena, block_ref)) {
      expr_ref = ast_pipeline_block_expr_stmt_ref(arena, block_ref, idx);
      if (expr_ref > 0) {
        if (glue_expr_kind_is_assign_like_ord(pipeline_expr_kind_ord_at(arena, expr_ref))) {
          left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
          if (left_ref > 0 && pipeline_expr_kind_ord_at(arena, left_ref) == GLUE_EXPR_KIND_VAR) {
            off = glue_var_expr_stack_off_elf_c(arena, ctx, left_ref);
            glue_live_fwd_add(kill, off);
          }
          glue_live_fwd_collect_expr_uses(arena, ctx, pipeline_expr_binop_right_ref_at(arena, expr_ref), gen);
        } else {
          glue_live_fwd_collect_expr_uses(arena, ctx, expr_ref, gen);
        }
      }
    }
  }
}

/**
 * 7.3 线性块：反向数据流预计算每条 stmt 的 live_in（存入 glue_block_live_at_stmt[]）。
 */
/** 对 live 应用 stmt 的 gen/kill（kill 槽先删再加回，表示定义后仍活跃）。 */
static void glue_live_fwd_apply_stmt_gen_kill(GlueBlockLiveFwd *live, const GlueBlockLiveFwd *gen,
                                               const GlueBlockLiveFwd *kill) {
  int32_t i;
  if (!live || !gen || !kill)
    return;
  for (i = 0; i < kill->n; i++)
    glue_live_fwd_remove(live, kill->offs[i]);
  for (i = 0; i < gen->n; i++)
    glue_live_fwd_add(live, gen->offs[i]);
  for (i = 0; i < kill->n; i++)
    glue_live_fwd_add(live, kill->offs[i]);
}

static void glue_asm73_compute_spill_color_chaitin(int32_t peak_i, const GlueBlockLiveFwd *peak_live);
static int32_t glue_asm73_stack_spill_enabled(void);

/** 7.3 Chaitin 原型：干涉图顶点（栈槽 off）与邻接位图（最多 32 槽）。 */
#define GLUE_ASM73_INTERF_MAX 32
static int32_t glue_asm73_interf_n;
static int32_t glue_asm73_interf_off[GLUE_ASM73_INTERF_MAX];
static uint32_t glue_asm73_interf_adj[GLUE_ASM73_INTERF_MAX];
/** 子块模拟时保存父块干涉图（then/else/loop 体递归前后 push/pop 合并）。 */
#define GLUE_ASM73_INTERF_STACK_DEPTH 8
static int32_t glue_asm73_interf_stack_depth;
static int32_t glue_asm73_interf_stack_n[GLUE_ASM73_INTERF_STACK_DEPTH];
static int32_t glue_asm73_interf_stack_off[GLUE_ASM73_INTERF_STACK_DEPTH][GLUE_ASM73_INTERF_MAX];
static uint32_t glue_asm73_interf_stack_adj[GLUE_ASM73_INTERF_STACK_DEPTH][GLUE_ASM73_INTERF_MAX];

/** 清空干涉图（块入口着色前调用）。 */
static void glue_asm73_interf_clear(void) {
  glue_asm73_interf_n = 0;
}

/** 将 src 干涉图并入 dst（按栈 off 对齐顶点，合并邻接边）；返回合并后顶点数。 */
static int32_t glue_asm73_interf_merge_into(int32_t dst_n, int32_t *dst_off, uint32_t *dst_adj, int32_t src_n,
                                             const int32_t *src_off, const uint32_t *src_adj) {
  int32_t map[GLUE_ASM73_INTERF_MAX];
  int32_t i;
  int32_t j;
  int32_t di;
  int32_t dj;
  int32_t dn;
  if (!dst_off || !dst_adj)
    return dst_n;
  dn = dst_n;
  if (src_n <= 0 || !src_off || !src_adj)
    return dn;
  for (i = 0; i < src_n; i++) {
    for (j = 0; j < dn; j++) {
      if (dst_off[j] == src_off[i]) {
        map[i] = j;
        goto found;
      }
    }
    if (dn >= GLUE_ASM73_INTERF_MAX)
      return dn;
    dst_off[dn] = src_off[i];
    dst_adj[dn] = 0;
    map[i] = dn;
    dn++;
  found:;
  }
  for (i = 0; i < src_n; i++) {
    di = map[i];
    for (j = 0; j < src_n; j++) {
      if (!(src_adj[i] & (uint32_t)(1u << j)))
        continue;
      dj = map[j];
      dst_adj[di] |= (uint32_t)(1u << dj);
      dst_adj[dj] |= (uint32_t)(1u << di);
    }
  }
  return dn;
}

/** 进入子块模拟：保存父干涉图并清空当前层。 */
static void glue_asm73_interf_push(void) {
  int32_t d;
  if (glue_asm73_interf_stack_depth >= GLUE_ASM73_INTERF_STACK_DEPTH)
    return;
  d = glue_asm73_interf_stack_depth;
  glue_asm73_interf_stack_n[d] = glue_asm73_interf_n;
  memcpy(glue_asm73_interf_stack_off[d], glue_asm73_interf_off, sizeof(glue_asm73_interf_off));
  memcpy(glue_asm73_interf_stack_adj[d], glue_asm73_interf_adj, sizeof(glue_asm73_interf_adj));
  glue_asm73_interf_stack_depth++;
  glue_asm73_interf_clear();
}

/** 子块模拟结束：将子图并入保存的父图并恢复为当前干涉图。 */
static void glue_asm73_interf_pop_merge(void) {
  int32_t d;
  int32_t merged_n;
  int32_t child_n;
  if (glue_asm73_interf_stack_depth <= 0)
    return;
  glue_asm73_interf_stack_depth--;
  d = glue_asm73_interf_stack_depth;
  child_n = glue_asm73_interf_n;
  merged_n = glue_asm73_interf_merge_into(glue_asm73_interf_stack_n[d], glue_asm73_interf_stack_off[d],
                                           glue_asm73_interf_stack_adj[d], child_n, glue_asm73_interf_off,
                                           glue_asm73_interf_adj);
  glue_asm73_interf_n = merged_n;
  memcpy(glue_asm73_interf_off, glue_asm73_interf_stack_off[d], sizeof(glue_asm73_interf_off));
  memcpy(glue_asm73_interf_adj, glue_asm73_interf_stack_adj[d], sizeof(glue_asm73_interf_adj));
}

/** 返回 off 在干涉图中的下标；-1 表示表满。 */
static int32_t glue_asm73_interf_index(int32_t off) {
  int32_t i;
  if (off < 0)
    return -1;
  for (i = 0; i < glue_asm73_interf_n; i++) {
    if (glue_asm73_interf_off[i] == off)
      return i;
  }
  if (glue_asm73_interf_n >= GLUE_ASM73_INTERF_MAX)
    return -1;
  i = glue_asm73_interf_n;
  glue_asm73_interf_off[i] = off;
  glue_asm73_interf_adj[i] = 0;
  glue_asm73_interf_n++;
  return i;
}

/** 记录 live 集中任意两槽在同一程序点同时活跃（无向边）。 */
static void glue_asm73_interf_add_live_set(const GlueBlockLiveFwd *live) {
  int32_t i;
  int32_t j;
  int32_t ii;
  int32_t jj;
  if (!live)
    return;
  for (i = 0; i < live->n; i++) {
    ii = glue_asm73_interf_index(live->offs[i]);
    if (ii < 0)
      return;
    for (j = i + 1; j < live->n; j++) {
      jj = glue_asm73_interf_index(live->offs[j]);
      if (jj < 0)
        return;
      glue_asm73_interf_adj[ii] |= (uint32_t)(1u << jj);
      glue_asm73_interf_adj[jj] |= (uint32_t)(1u << ii);
    }
  }
}

/**
 * 7.3 cfg 模拟：记录 |live| 全局 max；cfg_peak_live 仅 final_expr（stmt_i>=nso）快照，供 Chaitin/栈帧 spill。
 */
static void glue_asm73_note_cfg_live_peak(const GlueBlockLiveFwd *live, int32_t stmt_i, int32_t nso,
                                           int32_t add_interf_edges) {
  if (!live)
    return;
  if (add_interf_edges)
    glue_asm73_interf_add_live_set(live);
  if (live->n > glue_asm73_linear_max_live_n)
    glue_asm73_linear_max_live_n = live->n;
  if (add_interf_edges && stmt_i >= nso && live->n >= glue_asm73_cfg_peak_live.n) {
    glue_live_fwd_copy(&glue_asm73_cfg_peak_live, live);
    glue_asm73_cfg_peak_stmt_i = stmt_i;
  }
}

/**
 * 7.3：cfg 父块前向模拟活跃集（递归子块；while/for 保守 ∪ 入口与体尾）。
 */
static void glue_block_simulate_cfg_live(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                        int32_t block_ref, const GlueBlockLiveFwd *live_in, GlueBlockLiveFwd *live_out,
                                        int32_t depth) {
  struct ast_Block *blk;
  GlueBlockLiveFwd live;
  GlueBlockLiveFwd gen;
  GlueBlockLiveFwd kill;
  GlueBlockLiveFwd snap;
  GlueBlockLiveFwd sub_end;
  GlueBlockLiveFwd else_end;
  GlueBlockLiveFwd merged;
  int32_t slot_base;
  int32_t nconst;
  int32_t nlet;
  int32_t nso;
  int32_t i;
  uint8_t item_kind;
  int32_t idx;
  if (!arena || !ctx || !live_out || block_ref <= 0 || depth > 8) {
    if (live_out && live_in)
      glue_live_fwd_copy(live_out, live_in);
    return;
  }
  glue_live_fwd_copy(&live, live_in);
  slot_base = backend_block_slot_base_for(ctx, arena, block_ref);
  nconst = ast_ast_block_num_consts(arena, block_ref);
  nlet = ast_ast_block_num_lets(arena, block_ref);
  nso = ast_ast_block_num_stmt_order(arena, block_ref);
  if (nso > 32)
    nso = 32;
  if (!glue_block_stmt_order_has_cfg(arena, block_ref)) {
    for (i = 0; i < nso; i++) {
      glue_block_stmt_gen_kill(arena, ctx, block_ref, slot_base, nconst, nlet, i, &gen, &kill);
      glue_live_fwd_apply_stmt_gen_kill(&live, &gen, &kill);
      glue_asm73_note_cfg_live_peak(&live, i, nso, 1);
    }
    blk = pipeline_arena_block_ptr(arena, block_ref);
    if (blk && blk->final_expr_ref > 0) {
      glue_live_fwd_clear(&gen);
      glue_live_fwd_collect_expr_uses(arena, ctx, blk->final_expr_ref, &gen);
      glue_asm73_cfg_final_expr_use_n = gen.n;
      for (i = 0; i < gen.n; i++)
        glue_live_fwd_add(&live, gen.offs[i]);
      glue_asm73_note_cfg_live_peak(&live, nso, nso, 1);
    }
    glue_live_fwd_copy(live_out, &live);
    return;
  }
  for (i = 0; i < nso; i++) {
    item_kind = ast_ast_block_stmt_order_kind(arena, block_ref, i);
    idx = ast_ast_block_stmt_order_idx(arena, block_ref, i);
    if (item_kind <= 2) {
      glue_block_stmt_gen_kill(arena, ctx, block_ref, slot_base, nconst, nlet, i, &gen, &kill);
      glue_live_fwd_apply_stmt_gen_kill(&live, &gen, &kill);
      glue_asm73_note_cfg_live_peak(&live, i, nso, 1);
    } else if (item_kind == 5 && idx >= 0 && idx < ast_ast_block_num_if_stmts(arena, block_ref)) {
      int32_t then_ref = ast_pipeline_block_if_then_body_ref(arena, block_ref, idx);
      int32_t else_ref = ast_pipeline_block_if_else_body_ref(arena, block_ref, idx);
      glue_live_fwd_copy(&snap, &live);
      glue_live_fwd_clear(&merged);
      glue_live_fwd_union_into(&merged, &snap);
      if (then_ref > 0) {
        glue_asm73_interf_push();
        glue_block_simulate_cfg_live(arena, ctx, then_ref, &snap, &sub_end, depth + 1);
        glue_asm73_interf_pop_merge();
        glue_live_fwd_union_into(&merged, &sub_end);
      }
      if (else_ref > 0) {
        glue_asm73_interf_push();
        glue_block_simulate_cfg_live(arena, ctx, else_ref, &snap, &else_end, depth + 1);
        glue_asm73_interf_pop_merge();
        glue_live_fwd_union_into(&merged, &else_end);
      } else
        glue_live_fwd_union_into(&merged, &snap);
      glue_live_fwd_copy(&live, &merged);
      glue_asm73_note_cfg_live_peak(&live, i, nso, 0);
    } else if (item_kind == 3 && idx >= 0 && idx < ast_ast_block_num_loops(arena, block_ref)) {
      int32_t body_ref = ast_ast_block_while_body_ref(arena, block_ref, idx);
      int32_t cond_ref = ast_ast_block_while_cond_ref(arena, block_ref, idx);
      int32_t j;
      glue_live_fwd_copy(&snap, &live);
      if (cond_ref > 0) {
        glue_live_fwd_clear(&gen);
        glue_live_fwd_collect_expr_uses(arena, ctx, cond_ref, &gen);
        for (j = 0; j < gen.n; j++)
          glue_live_fwd_add(&live, gen.offs[j]);
      }
      glue_live_fwd_clear(&merged);
      glue_live_fwd_union_into(&merged, &snap);
      if (body_ref > 0) {
        glue_asm73_interf_push();
        glue_block_simulate_cfg_live(arena, ctx, body_ref, &snap, &sub_end, depth + 1);
        glue_asm73_interf_pop_merge();
        glue_live_fwd_union_into(&merged, &sub_end);
      }
      glue_live_fwd_copy(&live, &merged);
      glue_asm73_note_cfg_live_peak(&live, i, nso, 0);
    } else if (item_kind == 4 && idx >= 0 && idx < ast_ast_block_num_for_loops(arena, block_ref)) {
      int32_t body_ref = ast_ast_block_for_body_ref(arena, block_ref, idx);
      int32_t cond_ref = ast_ast_block_for_cond_ref(arena, block_ref, idx);
      int32_t step_ref = ast_ast_block_for_step_ref(arena, block_ref, idx);
      int32_t j;
      glue_live_fwd_copy(&snap, &live);
      if (cond_ref > 0) {
        glue_live_fwd_clear(&gen);
        glue_live_fwd_collect_expr_uses(arena, ctx, cond_ref, &gen);
        for (j = 0; j < gen.n; j++)
          glue_live_fwd_add(&live, gen.offs[j]);
      }
      glue_live_fwd_clear(&merged);
      glue_live_fwd_union_into(&merged, &snap);
      if (body_ref > 0) {
        glue_asm73_interf_push();
        glue_block_simulate_cfg_live(arena, ctx, body_ref, &snap, &sub_end, depth + 1);
        glue_asm73_interf_pop_merge();
        glue_live_fwd_union_into(&merged, &sub_end);
      }
      if (step_ref > 0) {
        glue_live_fwd_clear(&gen);
        glue_live_fwd_collect_expr_uses(arena, ctx, step_ref, &gen);
        for (j = 0; j < gen.n; j++)
          glue_live_fwd_add(&live, gen.offs[j]);
      }
      glue_live_fwd_copy(&live, &merged);
      glue_asm73_note_cfg_live_peak(&live, i, nso, 0);
    }
  }
  blk = pipeline_arena_block_ptr(arena, block_ref);
  if (blk && blk->final_expr_ref > 0) {
    glue_live_fwd_clear(&gen);
    glue_live_fwd_collect_expr_uses(arena, ctx, blk->final_expr_ref, &gen);
    glue_asm73_cfg_final_expr_use_n = gen.n;
    for (i = 0; i < gen.n; i++)
      glue_live_fwd_add(&live, gen.offs[i]);
    glue_asm73_note_cfg_live_peak(&live, nso, nso, 1);
  }
  glue_live_fwd_copy(live_out, &live);
}

/** 7.3：cfg 父块入口——前向峰值 live + 设置线性上下文并做 Chaitin 着色。 */
void glue_block_compute_cfg_peak_live_and_color(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                        int32_t block_ref, int32_t slot_base, int32_t nconst,
                                                        int32_t nlet) {
  GlueBlockLiveFwd live_start;
  GlueBlockLiveFwd live_end;
  int32_t nso;
  glue_asm73_interf_clear();
  glue_asm73_interf_stack_depth = 0;
  glue_asm73_linear_max_live_n = 0;
  glue_asm73_cfg_peak_stmt_i = 0;
  glue_asm73_cfg_final_expr_use_n = 0;
  glue_live_fwd_clear(&glue_asm73_cfg_peak_live);
  glue_live_fwd_clear(&live_start);
  glue_block_simulate_cfg_live(arena, ctx, block_ref, &live_start, &live_end, 0);
  nso = ast_ast_block_num_stmt_order(arena, block_ref);
  if (nso > 32)
    nso = 32;
  glue_asm73_linear_arena = arena;
  glue_asm73_linear_ctx = ctx;
  glue_asm73_linear_block_ref = block_ref;
  glue_asm73_linear_slot_base = slot_base;
  glue_asm73_linear_nconst = nconst;
  glue_asm73_linear_nlet = nlet;
  glue_asm73_linear_nso = nso;
  glue_asm73_cfg_coloring_active = 1;
  glue_asm73_compute_spill_color_chaitin(glue_asm73_cfg_peak_stmt_i, &glue_asm73_cfg_peak_live);
  glue_asm73_cfg_coloring_active = 0;
}

void glue_block_compute_linear_live_in(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                               int32_t block_ref, int32_t slot_base, int32_t nconst, int32_t nlet) {
  struct ast_Block *blk;
  GlueBlockLiveFwd live_out;
  GlueBlockLiveFwd gen;
  GlueBlockLiveFwd kill;
  int32_t nso;
  int32_t i;
  int32_t j;
  if (!arena || !ctx || block_ref <= 0)
    return;
  nso = ast_ast_block_num_stmt_order(arena, block_ref);
  if (nso > 32)
    nso = 32;
  glue_asm73_linear_arena = arena;
  glue_asm73_linear_ctx = ctx;
  glue_asm73_linear_block_ref = block_ref;
  glue_asm73_linear_slot_base = slot_base;
  glue_asm73_linear_nconst = nconst;
  glue_asm73_linear_nlet = nlet;
  glue_asm73_linear_nso = nso;
  glue_live_fwd_clear(&live_out);
  blk = pipeline_arena_block_ptr(arena, block_ref);
  if (blk && blk->final_expr_ref > 0)
    glue_live_fwd_collect_expr_uses(arena, ctx, blk->final_expr_ref, &live_out);
  for (i = nso - 1; i >= 0; i--) {
    glue_block_stmt_gen_kill(arena, ctx, block_ref, slot_base, nconst, nlet, i, &gen, &kill);
    for (j = 0; j < kill.n; j++)
      glue_live_fwd_remove(&live_out, kill.offs[j]);
    for (j = 0; j < gen.n; j++)
      glue_live_fwd_add(&live_out, gen.offs[j]);
    /** live_out 现为 stmt i-1 之后的状态，即进入 stmt i 前的活跃集。 */
    glue_live_fwd_copy(&glue_block_live_at_stmt[i], &live_out);
  }
  glue_asm73_linear_max_live_n = 0;
  for (i = 0; i < nso; i++) {
    if (glue_block_live_at_stmt[i].n > glue_asm73_linear_max_live_n)
      glue_asm73_linear_max_live_n = glue_block_live_at_stmt[i].n;
  }
}

/**
 * 7.3：线性子块出口活跃集（无控制流 stmt_order）；含 cfg 则清空 out。
 */
void glue_block_compute_live_end_linear(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                int32_t block_ref, GlueBlockLiveFwd *out) {
  struct ast_Block *blk;
  GlueBlockLiveFwd live_out;
  GlueBlockLiveFwd gen;
  GlueBlockLiveFwd kill;
  int32_t slot_base;
  int32_t nconst;
  int32_t nlet;
  int32_t nso;
  int32_t i;
  int32_t j;
  if (!out)
    return;
  glue_live_fwd_clear(out);
  if (!arena || !ctx || block_ref <= 0)
    return;
  if (glue_block_stmt_order_has_cfg(arena, block_ref))
    return;
  slot_base = backend_block_slot_base_for(ctx, arena, block_ref);
  nconst = ast_ast_block_num_consts(arena, block_ref);
  nlet = ast_ast_block_num_lets(arena, block_ref);
  nso = ast_ast_block_num_stmt_order(arena, block_ref);
  if (nso > 32)
    nso = 32;
  glue_live_fwd_clear(&live_out);
  blk = pipeline_arena_block_ptr(arena, block_ref);
  if (blk && blk->final_expr_ref > 0)
    glue_live_fwd_collect_expr_uses(arena, ctx, blk->final_expr_ref, &live_out);
  for (i = nso - 1; i >= 0; i--) {
    glue_block_stmt_gen_kill(arena, ctx, block_ref, slot_base, nconst, nlet, i, &gen, &kill);
    for (j = 0; j < kill.n; j++)
      glue_live_fwd_remove(&live_out, kill.offs[j]);
    for (j = 0; j < gen.n; j++)
      glue_live_fwd_add(&live_out, gen.offs[j]);
  }
  glue_live_fwd_copy(out, &live_out);
}

/**
 * 7.3 子块出口活跃集：无 cfg 用反向线性；含 cfg 用发射结束时 glue_block_live_sub_exit_snap（非空线性重算）。
 */
/* wave129 Cap residual: pure block_if leave (was static). PLATFORM: SHARED. */
void glue_block_fill_live_end_for_merge(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                        int32_t block_ref, GlueBlockLiveFwd *out) {
  glue_live_fwd_clear(out);
  if (!out || !arena || !ctx || block_ref <= 0)
    return;
  if (glue_block_stmt_order_has_cfg(arena, block_ref))
    glue_live_fwd_copy(out, &glue_block_live_sub_exit_snap);
  else
    glue_block_compute_live_end_linear(arena, ctx, block_ref, out);
}

/**
 * 7.3 含 cfg 父块：单条 def 后前向更新 glue_block_live_fwd（live = (live-kill)∪gen∪{def}）。
 */
void glue_live_fwd_forward_after_def(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                             int32_t def_off, int32_t gen_expr) {
  GlueBlockLiveFwd gen;
  int32_t i;
  if (!glue_block_live_cfg_parent || def_off < 0)
    return;
  gen.n = 0;
  if (gen_expr > 0)
    glue_live_fwd_collect_expr_uses(arena, ctx, gen_expr, &gen);
  glue_live_fwd_remove(&glue_block_live_fwd, def_off);
  for (i = 0; i < gen.n; i++)
    glue_live_fwd_add(&glue_block_live_fwd, gen.offs[i]);
  glue_live_fwd_add(&glue_block_live_fwd, def_off);
}

/**
 * 7.3 if 汇合：写槽选择性失效后，合并 then/else 出口活跃集（调用方须在 else 发射前保存 then_end）。
 */
/* wave129 Cap residual: pure block_if leave (was static). PLATFORM: SHARED. */
void glue_asm_if_merge_live_union_from_ends(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                            const GlueBlockLiveFwd *then_end,
                                            const GlueBlockLiveFwd *else_end) {
  GlueBlockLiveFwd merged;
  (void)arena;
  (void)ctx;
  glue_live_fwd_clear(&merged);
  if (then_end)
    glue_live_fwd_union_into(&merged, then_end);
  if (else_end)
    glue_live_fwd_union_into(&merged, else_end);
  glue_live_fwd_copy(&glue_block_live_fwd, &merged);
  glue_block_live_fwd_active = 1;
  glue_binop_cache_intersect_live_fwd();
}

/*
 * 7.3 全图寄存器（TODO，不阻塞原型门禁）：
 * - SSA/φ：if 双支同槽写、loop 携带 redefine（已接最小 φ cache 失效，见 glue_asm_if/loop_phi_*）；
 * - 图着色（建议顺序）：① 以基本块 live 集为输入；② 线性 scan 优先（低延迟）或 Chaitin 备选；
 *   ③ 保留 rax/rbx 给二元快路径，x9-x15 作 spill/第三操作数；④ 与 peephole 协同消 mov；
 * 第一步（已接）：线性块 |live_in|>3 且存在未进 cache 的活跃槽时驱逐 binop cache。
 * 第二步（已接）：压力下按 next-use 距离只失效 rax 或 rbx 其一（保留更近使用者）。
 * 第三步（已接）：arm64 spill x10/x11/x12（|live|max≥5/7）；最远 next-use 覆盖；压力阈值随 max 升高。
 * 左结合链（已接）：add/mul/&/|/^ 的 ((…){op}VAR) 装 rbx 前 glue_asm73_left_assoc_spill_rbx_*。
 * 第四步（已接）：峰值 |live| stmt 上取 next-use 最近两槽为 pin，覆盖 spill 时不踢掉更急的 pinned 槽。
 * 第五步（已接）：峰值 |live|≥5 时第三 pin；K=3 贪心着色（峰值 clique 上最近三槽 → x10/x11/x12 偏好）。
 * 第六步（已接）：含 if/while/for 父块前向模拟峰值 live + K=3 着色；发射期 cfg 前向 next-use。
 * 第七步（已接）：|live|max≥7 时第四 spill 槽 x13；八元 return 链（binop_return_eight_add）。
 * 第八步（已接）：全块 live 快照建干涉边 + 贪心 Chaitin（K=4→x10–x13 固定家园）；pin 按色保护。
 * 第九步（已接）：子块干涉图 push/pop 合并；cfg 汇合 live 仅记峰值不加假边。
 * 第十步（已接）：|live|max≥8 时第五 spill x14；Chaitin K=5；pin 可被更近 next-use 抢占。
 * 第十一步（已接）：peephole_elf 消除 x10–x14↔x0/x1 连续往返 mov（8 字节对，见 peephole.x）。
 * 第十二步（已接）：Chaitin 无法着色 → which=6；线性块 |live|max≥15 时栈帧 spill（push rax/rbx）；十～十四元走 x10–x15 驱逐。
 * 第十三步（已接）：cfg_peak_live 仅 final_expr 快照（Chaitin/阈值更准）；binop_if_return_twelve_add。
 * 第十四步（已接）：|live|max≥9 时第六 spill x15；Chaitin K=6；栈帧家园 which=6；线性 |live|max≥15 栈帧 spill。
 * 第十五步（已接）：cfg final_expr VAR≥12 启栈帧 spill；着色表 16 项；if 子块继承着色/不 wipe；binop_if_return_fourteen_add。
 * 第十六步（已接）：while 父块长 return 链（binop_while_return_fourteen_add）；if thirteen（91）；cfg-merge 双端验栈 push。
 * 第十七步（已接）：for 父块长 return 链（binop_for_return_fourteen_add）；cfg-merge if/while/for 三端验栈 push。
 * 第十八步（已接）：嵌套 cfg if+while 长 return；嵌套 cfg 子块在 saved_cfg_color_active 时不重算 Chaitin。
 * 第十九步（已接）：if 双支 φ + 十四元 return（binop_if_phi_return_fourteen_add，exit 105）；长链栈 push 门禁不含 φ 路径。
 * 第二十步（已接）：while loop φ + 十四元 return（binop_while_phi_return_fourteen_add）；7.3 寄存器/φ 阶段性收束（更深 SSA 非阻塞）。
 * 第二十一步（已接）：run-asm-73-gate 并入 run-bootstrap-bstrict-ci.sh（CI 三平台 bstrict-ci 覆盖 7.3）。
 * 第二十二步（已接）：run-asm-vector-var 并入 run-asm-73-gate（向量 lane VAR binop 无 push，P3/7.3 合门禁）。
 * 第二十三步（已接）：run-asm-call-inline.sh（struct try_inline_*，4 例 _main 无 bl）；并入 run-asm-73-gate / CI。
 * 门禁：run-asm-73-gate.sh；run-bootstrap-bstrict-ci.sh；run-pre-push-p0.sh。
 */

/**
 * 7.3 loop φ（最小）：循环入口活跃且循环体内 redefine 的栈槽，汇合后失效 binop cache（携带重定义）。
 */
/* wave155: un-static for pure fold_count leave Cap residual. PLATFORM: SHARED. */
void glue_asm_loop_phi_invalidate_carried_defs(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                       int32_t body_ref) {
  int32_t body_offs[GLUE_CFG_DEF_OFFS_CAP];
  int32_t n;
  int32_t i;
  int32_t hit;
  if (!arena || !ctx || body_ref <= 0)
    return;
  n = 0;
  glue_cfg_collect_block_def_offs_elf_c(arena, ctx, body_ref, body_offs, GLUE_CFG_DEF_OFFS_CAP, &n);
  hit = 0;
  for (i = 0; i < n; i++) {
    if (body_offs[i] >= 0 && glue_live_fwd_contains(&glue_live_snap_before_if, body_offs[i])) {
      glue_binop_var_slot_cache_invalidate_slot(body_offs[i]);
      hit = 1;
    }
  }
  if (hit)
    glue_binop_var_slot_cache_invalidate_rax();
}

/**
 * 7.3 while/for 出口活跃汇合：break/continue/体尾/入口 ∪，并做单轮回边 head 精炼。
 * exit_live = snap_before ∪ body_end ∪ break_exit ∪ continue_head；
 * head_1round = snap_before ∪ body_end ∪ continue_head（近似下一迭代入口）；
 * 最终 merged = exit_live ∪ head_1round（保守，利于含 continue 的 cfg 体）。
 */
/* wave155: un-static for pure fold_count leave Cap residual. PLATFORM: SHARED. */
void glue_asm_loop_merge_live_union(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                            int32_t body_ref) {
  GlueBlockLiveFwd body_end;
  GlueBlockLiveFwd merged;
  GlueBlockLiveFwd head_one_round;
  int32_t d;
  (void)arena;
  (void)ctx;
  glue_live_fwd_clear(&merged);
  glue_live_fwd_union_into(&merged, &glue_live_snap_before_if);
  if (body_ref > 0)
    glue_block_fill_live_end_for_merge(arena, ctx, body_ref, &body_end);
  else
    glue_live_fwd_clear(&body_end);
  glue_live_fwd_union_into(&merged, &body_end);
  if (glue_loop_break_exit_depth > 0) {
    d = glue_loop_break_exit_depth - 1;
    glue_live_fwd_union_into(&merged, &glue_loop_break_exit_live_stack[d]);
    glue_live_fwd_union_into(&merged, &glue_loop_continue_head_live_stack[d]);
    /** 单轮回边：入口 ∪ 体尾 ∪ continue 头部，补全 cfg 体在 continue 边定义的活跃槽。 */
    glue_live_fwd_clear(&head_one_round);
    glue_live_fwd_union_into(&head_one_round, &glue_live_snap_before_if);
    glue_live_fwd_union_into(&head_one_round, &body_end);
    glue_live_fwd_union_into(&head_one_round, &glue_loop_continue_head_live_stack[d]);
    glue_live_fwd_union_into(&merged, &head_one_round);
  }
  glue_live_fwd_copy(&glue_block_live_fwd, &merged);
  glue_block_live_fwd_active = 1;
  glue_binop_cache_intersect_live_fwd();
}

/**
 * 7.3 for step 表达式对出口活跃集的前向修正（step 在回跳前已执行，仅更新追踪集）。
 */
/* wave155: un-static for pure fold_count leave Cap residual. PLATFORM: SHARED. */
void glue_live_fwd_apply_expr_effect(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                             int32_t expr_ref) {
  int32_t ko;
  int32_t left_ref;
  int32_t off;
  GlueBlockLiveFwd gen;
  int32_t i;
  if (!expr_ref || !arena || !ctx)
    return;
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (glue_expr_kind_is_assign_like_ord(ko)) {
    left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    if (left_ref > 0 && pipeline_expr_kind_ord_at(arena, left_ref) == GLUE_EXPR_KIND_VAR) {
      off = glue_var_expr_stack_off_elf_c(arena, ctx, left_ref);
      glue_live_fwd_forward_after_def(arena, ctx, off, pipeline_expr_binop_right_ref_at(arena, expr_ref));
    }
    return;
  }
  gen.n = 0;
  glue_live_fwd_collect_expr_uses(arena, ctx, expr_ref, &gen);
  for (i = 0; i < gen.n; i++)
    glue_live_fwd_add(&glue_block_live_fwd, gen.offs[i]);
}

/**
 * 7.3 cfg 父块：从 from_stmt 起前向扫描顶层 stmt_order/final_expr 的下次使用距离。
 */
static int32_t glue_asm73_cfg_forward_next_use_dist(int32_t from_stmt, int32_t off) {
  struct ast_ASTArena *arena;
  struct backend_AsmFuncCtx *ctx;
  int32_t block_ref;
  GlueBlockLiveFwd gen;
  GlueBlockLiveFwd kill;
  int32_t s;
  struct ast_Block *blk;
  if (off < 0 || from_stmt < 0 || !glue_asm73_linear_arena || !glue_asm73_linear_ctx)
    return 9999;
  arena = glue_asm73_linear_arena;
  ctx = glue_asm73_linear_ctx;
  block_ref = glue_asm73_linear_block_ref;
  if (block_ref <= 0)
    return 9999;
  for (s = from_stmt; s < glue_asm73_linear_nso; s++) {
    glue_block_stmt_gen_kill(arena, ctx, block_ref, glue_asm73_linear_slot_base, glue_asm73_linear_nconst,
                             glue_asm73_linear_nlet, s, &gen, &kill);
    if (glue_live_fwd_contains(&gen, off))
      return s - from_stmt;
  }
  blk = pipeline_arena_block_ptr(arena, block_ref);
  if (blk && blk->final_expr_ref > 0) {
    glue_live_fwd_clear(&gen);
    glue_live_fwd_collect_expr_uses(arena, ctx, blk->final_expr_ref, &gen);
    if (glue_live_fwd_contains(&gen, off))
      return glue_asm73_linear_nso - from_stmt;
  }
  return 9999;
}

/**
 * 7.3 线性 scan：从 stmt from_stmt 起（含）到块尾/final_expr，栈槽 off 的下次使用距离；无使用返回 9999。
 */
static int32_t glue_asm73_linear_next_use_dist(int32_t from_stmt, int32_t off) {
  struct ast_ASTArena *arena;
  struct backend_AsmFuncCtx *ctx;
  int32_t block_ref;
  GlueBlockLiveFwd gen;
  GlueBlockLiveFwd kill;
  int32_t s;
  struct ast_Block *blk;
  if (off < 0 || from_stmt < 0 || !glue_asm73_linear_arena || !glue_asm73_linear_ctx)
    return 9999;
  if (glue_asm73_cfg_coloring_active)
    return glue_asm73_cfg_forward_next_use_dist(from_stmt, off);
  arena = glue_asm73_linear_arena;
  ctx = glue_asm73_linear_ctx;
  block_ref = glue_asm73_linear_block_ref;
  if (block_ref <= 0)
    return 9999;
  for (s = from_stmt; s < glue_asm73_linear_nso; s++) {
    glue_block_stmt_gen_kill(arena, ctx, block_ref, glue_asm73_linear_slot_base, glue_asm73_linear_nconst,
                             glue_asm73_linear_nlet, s, &gen, &kill);
    if (glue_live_fwd_contains(&gen, off))
      return s - from_stmt;
  }
  blk = pipeline_arena_block_ptr(arena, block_ref);
  if (blk && blk->final_expr_ref > 0) {
    glue_live_fwd_clear(&gen);
    glue_live_fwd_collect_expr_uses(arena, ctx, blk->final_expr_ref, &gen);
    if (glue_live_fwd_contains(&gen, off))
      return glue_asm73_linear_nso - from_stmt;
  }
  return 9999;
}

/** 7.3：栈槽 off 是否为当前块 spill 着色 pin（更近 next-use，不宜被远槽覆盖）。 */
static int32_t glue_asm73_off_is_spill_pin(int32_t off) {
  if (off < 0)
    return 0;
  return off == glue_asm73_pin_spill_off[0] || off == glue_asm73_pin_spill_off[1] ||
         off == glue_asm73_pin_spill_off[2] || off == glue_asm73_pin_spill_off[3] ||
         off == glue_asm73_pin_spill_off[4] || off == glue_asm73_pin_spill_off[5];
}

/** 清空本块 spill 着色表。 */
void glue_asm73_clear_spill_color_map(void) {
  glue_asm73_spill_color_n = 0;
}

/**
 * 记录栈槽 off 的 spill 偏好（0=x10 … 5=x15，6=栈帧 spill）；表满则忽略。
 */
static void glue_asm73_set_spill_color(int32_t off, int32_t which) {
  int32_t i;
  if (off < 0 || which < 0 || which > GLUE_ASM73_SPILL_WHICH_STACK)
    return;
  for (i = 0; i < glue_asm73_spill_color_n; i++) {
    if (glue_asm73_spill_color_off[i] == off) {
      glue_asm73_spill_color_which[i] = (int8_t)which;
      return;
    }
  }
  if (glue_asm73_spill_color_n >= GLUE_ASM73_SPILL_COLOR_MAP_CAP)
    return;
  glue_asm73_spill_color_off[glue_asm73_spill_color_n] = off;
  glue_asm73_spill_color_which[glue_asm73_spill_color_n] = (int8_t)which;
  glue_asm73_spill_color_n++;
}

/** 返回 off 的偏好 spill 槽；-1 表示未着色。 */
static int32_t glue_asm73_off_spill_color_which(int32_t off) {
  int32_t i;
  if (off < 0)
    return -1;
  for (i = 0; i < glue_asm73_spill_color_n; i++) {
    if (glue_asm73_spill_color_off[i] == off)
      return (int32_t)glue_asm73_spill_color_which[i];
  }
  return -1;
}

/**
 * 7.3 Chaitin 原型（K=6）：在已建干涉图上按峰值 next-use 升序贪心着色，绑定 x10–x15 家园并设 pin。
 */
static void glue_asm73_compute_spill_color_chaitin(int32_t peak_i, const GlueBlockLiveFwd *peak_live) {
  int32_t peak;
  int32_t order[GLUE_ASM73_INTERF_MAX];
  int32_t dist[GLUE_ASM73_INTERF_MAX];
  int8_t color_of[GLUE_ASM73_INTERF_MAX];
  int32_t n;
  int32_t i;
  int32_t j;
  int32_t k;
  int32_t idx;
  int32_t off;
  int32_t c;
  uint32_t used;
  int32_t best_off;
  int32_t best_d;
  int32_t d;
  glue_asm73_pin_spill_off[0] = -1;
  glue_asm73_pin_spill_off[1] = -1;
  glue_asm73_pin_spill_off[2] = -1;
  glue_asm73_pin_spill_off[3] = -1;
  glue_asm73_pin_spill_off[4] = -1;
  glue_asm73_pin_spill_off[5] = -1;
  glue_asm73_clear_spill_color_map();
  if (!peak_live || glue_asm73_linear_nso <= 0 || glue_asm73_interf_n <= 0)
    return;
  peak = peak_live->n;
  /** cfg 父块 peak 在 final_expr；单变量块不着色。 */
  if (peak < 2)
    return;
  n = glue_asm73_interf_n;
  for (i = 0; i < n; i++) {
    order[i] = i;
    dist[i] = glue_asm73_linear_next_use_dist(peak_i, glue_asm73_interf_off[i]);
    color_of[i] = -1;
  }
  for (i = 0; i < n - 1; i++) {
    for (j = i + 1; j < n; j++) {
      if (dist[order[j]] < dist[order[i]]) {
        k = order[i];
        order[i] = order[j];
        order[j] = k;
      }
    }
  }
  for (i = 0; i < n; i++) {
    idx = order[i];
    used = 0;
    for (j = 0; j < n; j++) {
      if (j == idx)
        continue;
      if (!(glue_asm73_interf_adj[idx] & (uint32_t)(1u << j)))
        continue;
      if (color_of[j] >= 0)
        used |= (uint32_t)(1u << color_of[j]);
    }
    for (c = 0; c < 6; c++) {
      if (!(used & (uint32_t)(1u << c))) {
        color_of[idx] = (int8_t)c;
        glue_asm73_set_spill_color(glue_asm73_interf_off[idx], c);
        break;
      }
    }
    if (color_of[idx] < 0)
      glue_asm73_set_spill_color(glue_asm73_interf_off[idx], GLUE_ASM73_SPILL_WHICH_STACK);
  }
  for (c = 0; c < 6; c++) {
    if (c == 2 && peak < 5)
      continue;
    if (c == 3 && peak < 6)
      continue;
    if (c == 4 && peak < 8)
      continue;
    if (c == 5 && peak < 9)
      continue;
    best_off = -1;
    best_d = 9999;
    for (j = 0; j < peak_live->n; j++) {
      off = peak_live->offs[j];
      if (glue_asm73_off_spill_color_which(off) != c)
        continue;
      d = glue_asm73_linear_next_use_dist(peak_i, off);
      if (d < best_d) {
        best_d = d;
        best_off = off;
      }
    }
    glue_asm73_pin_spill_off[c] = best_off;
  }
}

/** 7.3 线性块：全块 live_in 建干涉图后 Chaitin 着色。 */
void glue_asm73_compute_spill_color_pins(void) {
  int32_t peak;
  int32_t peak_i;
  int32_t i;
  glue_asm73_interf_clear();
  for (i = 0; i < glue_asm73_linear_nso; i++)
    glue_asm73_interf_add_live_set(&glue_block_live_at_stmt[i]);
  peak = 0;
  peak_i = 0;
  for (i = 0; i < glue_asm73_linear_nso; i++) {
    if (glue_block_live_at_stmt[i].n > peak) {
      peak = glue_block_live_at_stmt[i].n;
      peak_i = i;
    }
  }
  if (peak < 2)
    return;
  glue_asm73_compute_spill_color_chaitin(peak_i, &glue_block_live_at_stmt[peak_i]);
}

/** 返回 spill 槽 which（0=x10…5=x15）当前保存的栈 off；-1 表示空。 */
static int32_t glue_asm73_spill_slot_held_off(int32_t which) {
  if (which == 5 && glue_binop_var_slot_cache.valid_x15)
    return glue_binop_var_slot_cache.x15_off;
  if (which == 4 && glue_binop_var_slot_cache.valid_x14)
    return glue_binop_var_slot_cache.x14_off;
  if (which == 3 && glue_binop_var_slot_cache.valid_x13)
    return glue_binop_var_slot_cache.x13_off;
  if (which == 2 && glue_binop_var_slot_cache.valid_x12)
    return glue_binop_var_slot_cache.x12_off;
  if (which == 1 && glue_binop_var_slot_cache.valid_x11)
    return glue_binop_var_slot_cache.x11_off;
  if (which == 0 && glue_binop_var_slot_cache.valid_x10)
    return glue_binop_var_slot_cache.x10_off;
  return -1;
}

/**
 * 7.3：是否启用栈帧 spill（which=6，sub sp,#16 + str）。
 * 线性块：|live|max≥15（十～十四元 block-var 走 x10–x15 驱逐）。
 * cfg 父块：final_expr 直接 VAR 使用数≥12（长 return 加链；binop_var_fast 仅 9 个操作数不启）。
 */
static int32_t glue_asm73_stack_spill_enabled(void) {
  if (glue_block_live_cfg_parent)
    return glue_asm73_cfg_final_expr_use_n >= 12 ? 1 : 0;
  return glue_asm73_linear_max_live_n >= 15 ? 1 : 0;
}

/** 7.3：Chaitin 标为栈帧家园（which=6）且块级阈值满足时走实栈 spill。 */
/* wave149 Cap residual: pure binop leave (was static). PLATFORM: SHARED. */
int32_t glue_asm73_var_prefers_stack_spill(int32_t off) {
  if (off < 0 || !glue_asm73_stack_spill_enabled())
    return 0;
  return glue_asm73_off_spill_color_which(off) == GLUE_ASM73_SPILL_WHICH_STACK ? 1 : 0;
}

/**
 * 7.3：是否允许用新溢出槽 new_off 覆盖物理 spill 槽 which（已考虑最远 next-use 与 pin）。
 */
static int32_t glue_asm73_spill_overwrite_ok(int32_t which, int32_t stmt_i, int32_t new_off, int32_t dist_new,
                                               int32_t dist_far) {
  int32_t held;
  int32_t dist_held;
  if (dist_new <= dist_far)
    return 0;
  held = glue_asm73_spill_slot_held_off(which);
  if (held < 0)
    return 1;
  if (!glue_asm73_off_is_spill_pin(held))
    return 1;
  dist_held = glue_asm73_linear_next_use_dist(stmt_i, held);
  /** pin 可被 next-use 更近的新槽抢占（Chaitin 第十步）。 */
  return glue_asm73_linear_next_use_dist(stmt_i, new_off) < dist_held;
}

/**
 * 7.3：arm64 将 rax/rbx 写入 spill 物理寄存器；spill_which：0=x10 … 5=x15。0=OK，-1=错。
 */
static int32_t glue_binop_spill_mov_reg_to_spill_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta,
                                                         int32_t off, int32_t from_rbx, int32_t spill_which) {
  if (ta != 1 || off < 0 || !elf_ctx)
    return 0;
  if (spill_which == 5) {
    if (from_rbx != 0) {
      if (arch_arm64_enc_enc_mov_rbx_to_x15(elf_ctx) != 0)
        return -1;
    } else if (arch_arm64_enc_enc_mov_rax_to_x15(elf_ctx) != 0) {
      return -1;
    }
    glue_binop_var_slot_cache.valid_x15 = 1;
    glue_binop_var_slot_cache.x15_off = off;
    return 0;
  }
  if (spill_which == 4) {
    if (from_rbx != 0) {
      if (arch_arm64_enc_enc_mov_rbx_to_x14(elf_ctx) != 0)
        return -1;
    } else if (arch_arm64_enc_enc_mov_rax_to_x14(elf_ctx) != 0) {
      return -1;
    }
    glue_binop_var_slot_cache.valid_x14 = 1;
    glue_binop_var_slot_cache.x14_off = off;
    return 0;
  }
  if (spill_which == 3) {
    if (from_rbx != 0) {
      if (arch_arm64_enc_enc_mov_rbx_to_x13(elf_ctx) != 0)
        return -1;
    } else if (arch_arm64_enc_enc_mov_rax_to_x13(elf_ctx) != 0) {
      return -1;
    }
    glue_binop_var_slot_cache.valid_x13 = 1;
    glue_binop_var_slot_cache.x13_off = off;
    return 0;
  }
  if (spill_which == 2) {
    if (from_rbx != 0) {
      if (arch_arm64_enc_enc_mov_rbx_to_x12(elf_ctx) != 0)
        return -1;
    } else if (arch_arm64_enc_enc_mov_rax_to_x12(elf_ctx) != 0) {
      return -1;
    }
    glue_binop_var_slot_cache.valid_x12 = 1;
    glue_binop_var_slot_cache.x12_off = off;
    return 0;
  }
  if (spill_which == 1) {
    if (from_rbx != 0) {
      if (arch_arm64_enc_enc_mov_rbx_to_x11(elf_ctx) != 0)
        return -1;
    } else if (arch_arm64_enc_enc_mov_rax_to_x11(elf_ctx) != 0) {
      return -1;
    }
    glue_binop_var_slot_cache.valid_x11 = 1;
    glue_binop_var_slot_cache.x11_off = off;
    return 0;
  }
  if (from_rbx != 0) {
    if (arch_arm64_enc_enc_mov_rbx_to_x10(elf_ctx) != 0)
      return -1;
  } else if (arch_arm64_enc_enc_mov_rax_to_x10(elf_ctx) != 0) {
    return -1;
  }
  glue_binop_var_slot_cache.valid_x10 = 1;
  glue_binop_var_slot_cache.x10_off = off;
  return 0;
}

/** 7.3：偏好物理 spill 槽若空闲则直接占用；0=已写入，-1=须走默认填充/驱逐。 */
static int32_t glue_asm73_try_spill_to_colored_slot(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta,
                                                     int32_t off, int32_t from_rbx) {
  int32_t pref;
  if (ta != 1 || off < 0 || !elf_ctx)
    return -1;
  pref = glue_asm73_off_spill_color_which(off);
  if (pref < 0)
    return -1;
  if (pref == 0 && !glue_binop_var_slot_cache.valid_x10)
    return glue_binop_spill_mov_reg_to_spill_elf_c(elf_ctx, ta, off, from_rbx, 0);
  if (pref == 1 && glue_asm73_linear_max_live_n >= 5 && !glue_binop_var_slot_cache.valid_x11)
    return glue_binop_spill_mov_reg_to_spill_elf_c(elf_ctx, ta, off, from_rbx, 1);
  if (pref == 2 && glue_asm73_linear_max_live_n >= 6 && !glue_binop_var_slot_cache.valid_x12)
    return glue_binop_spill_mov_reg_to_spill_elf_c(elf_ctx, ta, off, from_rbx, 2);
  if (pref == 3 && glue_asm73_linear_max_live_n >= 7 && !glue_binop_var_slot_cache.valid_x13)
    return glue_binop_spill_mov_reg_to_spill_elf_c(elf_ctx, ta, off, from_rbx, 3);
  if (pref == 4 && glue_asm73_linear_max_live_n >= 8 && !glue_binop_var_slot_cache.valid_x14)
    return glue_binop_spill_mov_reg_to_spill_elf_c(elf_ctx, ta, off, from_rbx, 4);
  if (pref == 5 && glue_asm73_linear_max_live_n >= 9 && !glue_binop_var_slot_cache.valid_x15)
    return glue_binop_spill_mov_reg_to_spill_elf_c(elf_ctx, ta, off, from_rbx, 5);
  if (pref == GLUE_ASM73_SPILL_WHICH_STACK && glue_asm73_stack_spill_enabled())
    return glue_binop_stack_spill_push_elf_c(elf_ctx, ta, off, from_rbx);
  return -1;
}

/** 7.3：返回 next-use 最远的已占用 spill 槽（0=x10…5=x15），无则 -1。 */
static int32_t glue_asm73_spill_slot_farthest(int32_t stmt_i) {
  int32_t which;
  int32_t best_dist;
  int32_t d;
  which = -1;
  best_dist = -1;
  if (glue_binop_var_slot_cache.valid_x10) {
    which = 0;
    best_dist = glue_asm73_linear_next_use_dist(stmt_i, glue_binop_var_slot_cache.x10_off);
  }
  if (glue_asm73_linear_max_live_n >= 5 && glue_binop_var_slot_cache.valid_x11) {
    d = glue_asm73_linear_next_use_dist(stmt_i, glue_binop_var_slot_cache.x11_off);
    if (d > best_dist) {
      which = 1;
      best_dist = d;
    }
  }
  if (glue_asm73_linear_max_live_n >= 6 && glue_binop_var_slot_cache.valid_x12) {
    d = glue_asm73_linear_next_use_dist(stmt_i, glue_binop_var_slot_cache.x12_off);
    if (d > best_dist) {
      which = 2;
      best_dist = d;
    }
  }
  if (glue_asm73_linear_max_live_n >= 7 && glue_binop_var_slot_cache.valid_x13) {
    d = glue_asm73_linear_next_use_dist(stmt_i, glue_binop_var_slot_cache.x13_off);
    if (d > best_dist) {
      which = 3;
      best_dist = d;
    }
  }
  if (glue_asm73_linear_max_live_n >= 8 && glue_binop_var_slot_cache.valid_x14) {
    d = glue_asm73_linear_next_use_dist(stmt_i, glue_binop_var_slot_cache.x14_off);
    if (d > best_dist) {
      which = 4;
      best_dist = d;
    }
  }
  if (glue_asm73_linear_max_live_n >= 9 && glue_binop_var_slot_cache.valid_x15) {
    d = glue_asm73_linear_next_use_dist(stmt_i, glue_binop_var_slot_cache.x15_off);
    if (d > best_dist) {
      which = 5;
      best_dist = d;
    }
  }
  return which;
}

/**
 * 7.3：三槽均满时选可覆盖的驱逐目标；优先踢非 new_off 着色家园的槽，再按最远 next-use。
 */
static int32_t glue_asm73_spill_pick_evict_which(int32_t stmt_i, int32_t new_off, int32_t dist_new) {
  int32_t pref;
  int32_t which;
  int32_t held;
  int32_t dist_held;
  int32_t best_which;
  int32_t best_dist;
  int32_t home_which;
  int32_t home_dist;
  best_which = -1;
  best_dist = -1;
  home_which = -1;
  home_dist = -1;
  pref = glue_asm73_off_spill_color_which(new_off);
  for (which = 0; which <= 5; which++) {
    if (which == 1 && glue_asm73_linear_max_live_n < 5)
      continue;
    if (which == 2 && glue_asm73_linear_max_live_n < 6)
      continue;
    if (which == 3 && glue_asm73_linear_max_live_n < 7)
      continue;
    if (which == 4 && glue_asm73_linear_max_live_n < 8)
      continue;
    if (which == 5 && glue_asm73_linear_max_live_n < 9)
      continue;
    if (which == 0 && !glue_binop_var_slot_cache.valid_x10)
      continue;
    if (which == 1 && !glue_binop_var_slot_cache.valid_x11)
      continue;
    if (which == 2 && !glue_binop_var_slot_cache.valid_x12)
      continue;
    if (which == 3 && !glue_binop_var_slot_cache.valid_x13)
      continue;
    if (which == 4 && !glue_binop_var_slot_cache.valid_x14)
      continue;
    if (which == 5 && !glue_binop_var_slot_cache.valid_x15)
      continue;
    if (which == 0)
      held = glue_binop_var_slot_cache.x10_off;
    else if (which == 1)
      held = glue_binop_var_slot_cache.x11_off;
    else if (which == 2)
      held = glue_binop_var_slot_cache.x12_off;
    else if (which == 3)
      held = glue_binop_var_slot_cache.x13_off;
    else if (which == 4)
      held = glue_binop_var_slot_cache.x14_off;
    else
      held = glue_binop_var_slot_cache.x15_off;
    dist_held = glue_asm73_linear_next_use_dist(stmt_i, held);
    if (!glue_asm73_spill_overwrite_ok(which, stmt_i, new_off, dist_new, dist_held))
      continue;
    if (pref >= 0 && which == pref) {
      if (dist_held > home_dist) {
        home_which = which;
        home_dist = dist_held;
      }
      continue;
    }
    if (dist_held > best_dist) {
      best_which = which;
      best_dist = dist_held;
    }
  }
  if (best_which >= 0)
    return best_which;
  return home_which;
}

/**
 * 7.3：arm64 将当前 rax/rbx 中的 VAR 溢出到 spill（x10→…→x15；均满则覆盖最远 next-use 槽）。
 * 0=OK，-1=错。
 */
static int32_t glue_binop_spill_reg_to_spill_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta,
                                                     int32_t off, int32_t from_rbx, int32_t stmt_i) {
  int32_t dist_new;
  int32_t which;
  int32_t colored;
  if (ta != 1 || off < 0 || !elf_ctx)
    return 0;
  colored = glue_asm73_try_spill_to_colored_slot(elf_ctx, ta, off, from_rbx);
  if (colored == 0)
    return 0;
  if (!glue_binop_var_slot_cache.valid_x10)
    return glue_binop_spill_mov_reg_to_spill_elf_c(elf_ctx, ta, off, from_rbx, 0);
  if (glue_asm73_linear_max_live_n >= 5 && !glue_binop_var_slot_cache.valid_x11)
    return glue_binop_spill_mov_reg_to_spill_elf_c(elf_ctx, ta, off, from_rbx, 1);
  if (glue_asm73_linear_max_live_n >= 6 && !glue_binop_var_slot_cache.valid_x12)
    return glue_binop_spill_mov_reg_to_spill_elf_c(elf_ctx, ta, off, from_rbx, 2);
  if (glue_asm73_linear_max_live_n >= 7 && !glue_binop_var_slot_cache.valid_x13)
    return glue_binop_spill_mov_reg_to_spill_elf_c(elf_ctx, ta, off, from_rbx, 3);
  if (glue_asm73_linear_max_live_n >= 8 && !glue_binop_var_slot_cache.valid_x14)
    return glue_binop_spill_mov_reg_to_spill_elf_c(elf_ctx, ta, off, from_rbx, 4);
  if (glue_asm73_linear_max_live_n >= 9 && !glue_binop_var_slot_cache.valid_x15)
    return glue_binop_spill_mov_reg_to_spill_elf_c(elf_ctx, ta, off, from_rbx, 5);
  dist_new = glue_asm73_linear_next_use_dist(stmt_i, off);
  which = glue_asm73_spill_pick_evict_which(stmt_i, off, dist_new);
  if (which < 0)
    which = glue_asm73_spill_slot_farthest(stmt_i);
  if (which < 0) {
    if (glue_asm73_stack_spill_enabled())
      return glue_binop_stack_spill_push_elf_c(elf_ctx, ta, off, from_rbx);
    return 0;
  }
  return glue_binop_spill_mov_reg_to_spill_elf_c(elf_ctx, ta, off, from_rbx, which);
}

/**
 * 7.3：VAR 栈槽 off 若已在 spill（x10–x15）则装入 rax/rbx；1=命中，0=未命中，-1=错。
 */
/* wave149 Cap residual: pure binop leave (was static). PLATFORM: SHARED. */
int32_t glue_binop_try_reload_spill_off_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                      struct backend_AsmFuncCtx *ctx, int32_t off, int32_t ta,
                                                      int32_t to_rbx) {
  int32_t stk;
  if (ta != 1 || off < 0 || !elf_ctx || !ctx || glue_binop_var_slot_cache.ctx_key != (size_t)ctx)
    return 0;
  stk = glue_binop_stack_spill_try_reload_elf_c(elf_ctx, ta, off, to_rbx);
  if (stk != 0)
    return stk;
  if (glue_binop_var_slot_cache.valid_x15 && glue_binop_var_slot_cache.x15_off == off) {
    if (to_rbx != 0) {
      if (arch_arm64_enc_enc_mov_x15_to_rbx(elf_ctx) != 0)
        return -1;
      glue_binop_var_slot_cache.valid_x15 = 0;
      glue_binop_var_slot_cache.valid_rbx = 1;
      glue_binop_var_slot_cache.rbx_off = off;
    } else {
      if (arch_arm64_enc_enc_mov_x15_to_rax(elf_ctx) != 0)
        return -1;
      glue_binop_var_slot_cache.valid_x15 = 0;
      glue_binop_var_slot_cache.valid_rax = 1;
      glue_binop_var_slot_cache.rax_off = off;
    }
    return 1;
  }
  if (glue_binop_var_slot_cache.valid_x14 && glue_binop_var_slot_cache.x14_off == off) {
    if (to_rbx != 0) {
      if (arch_arm64_enc_enc_mov_x14_to_rbx(elf_ctx) != 0)
        return -1;
      glue_binop_var_slot_cache.valid_x14 = 0;
      glue_binop_var_slot_cache.valid_rbx = 1;
      glue_binop_var_slot_cache.rbx_off = off;
    } else {
      if (arch_arm64_enc_enc_mov_x14_to_rax(elf_ctx) != 0)
        return -1;
      glue_binop_var_slot_cache.valid_x14 = 0;
      glue_binop_var_slot_cache.valid_rax = 1;
      glue_binop_var_slot_cache.rax_off = off;
    }
    return 1;
  }
  if (glue_binop_var_slot_cache.valid_x13 && glue_binop_var_slot_cache.x13_off == off) {
    if (to_rbx != 0) {
      if (arch_arm64_enc_enc_mov_x13_to_rbx(elf_ctx) != 0)
        return -1;
      glue_binop_var_slot_cache.valid_x13 = 0;
      glue_binop_var_slot_cache.valid_rbx = 1;
      glue_binop_var_slot_cache.rbx_off = off;
    } else {
      if (arch_arm64_enc_enc_mov_x13_to_rax(elf_ctx) != 0)
        return -1;
      glue_binop_var_slot_cache.valid_x13 = 0;
      glue_binop_var_slot_cache.valid_rax = 1;
      glue_binop_var_slot_cache.rax_off = off;
    }
    return 1;
  }
  if (glue_binop_var_slot_cache.valid_x10 && glue_binop_var_slot_cache.x10_off == off) {
    if (to_rbx != 0) {
      if (arch_arm64_enc_enc_mov_x10_to_rbx(elf_ctx) != 0)
        return -1;
      glue_binop_var_slot_cache.valid_x10 = 0;
      glue_binop_var_slot_cache.valid_rbx = 1;
      glue_binop_var_slot_cache.rbx_off = off;
    } else {
      if (arch_arm64_enc_enc_mov_x10_to_rax(elf_ctx) != 0)
        return -1;
      glue_binop_var_slot_cache.valid_x10 = 0;
      glue_binop_var_slot_cache.valid_rax = 1;
      glue_binop_var_slot_cache.rax_off = off;
    }
    return 1;
  }
  if (glue_binop_var_slot_cache.valid_x11 && glue_binop_var_slot_cache.x11_off == off) {
    if (to_rbx != 0) {
      if (arch_arm64_enc_enc_mov_x11_to_rbx(elf_ctx) != 0)
        return -1;
      glue_binop_var_slot_cache.valid_x11 = 0;
      glue_binop_var_slot_cache.valid_rbx = 1;
      glue_binop_var_slot_cache.rbx_off = off;
    } else {
      if (arch_arm64_enc_enc_mov_x11_to_rax(elf_ctx) != 0)
        return -1;
      glue_binop_var_slot_cache.valid_x11 = 0;
      glue_binop_var_slot_cache.valid_rax = 1;
      glue_binop_var_slot_cache.rax_off = off;
    }
    return 1;
  }
  if (glue_binop_var_slot_cache.valid_x12 && glue_binop_var_slot_cache.x12_off == off) {
    if (to_rbx != 0) {
      if (arch_arm64_enc_enc_mov_x12_to_rbx(elf_ctx) != 0)
        return -1;
      glue_binop_var_slot_cache.valid_x12 = 0;
      glue_binop_var_slot_cache.valid_rbx = 1;
      glue_binop_var_slot_cache.rbx_off = off;
    } else {
      if (arch_arm64_enc_enc_mov_x12_to_rax(elf_ctx) != 0)
        return -1;
      glue_binop_var_slot_cache.valid_x12 = 0;
      glue_binop_var_slot_cache.valid_rax = 1;
      glue_binop_var_slot_cache.rax_off = off;
    }
    return 1;
  }
  return 0;
}

/**
 * 7.3 线性 scan 第三步：arm64 驱逐 rax/rbx 前将被踢槽 mov 到 spill；ta!=1 仅 invalidate。
 */
static void glue_asm73_evict_rax_cache_entry(int32_t stmt_i, int32_t ta,
                                              struct platform_elf_ElfCodegenCtx *elf_ctx) {
  int32_t off;
  if (!glue_binop_var_slot_cache.valid_rax)
    return;
  off = glue_binop_var_slot_cache.rax_off;
  if (ta == 1 && elf_ctx && off >= 0)
    (void)glue_binop_spill_reg_to_spill_elf_c(elf_ctx, ta, off, 0, stmt_i);
  glue_binop_var_slot_cache_invalidate_rax();
}

static void glue_asm73_evict_rbx_cache_entry(int32_t stmt_i, int32_t ta,
                                              struct platform_elf_ElfCodegenCtx *elf_ctx) {
  int32_t off;
  if (!glue_binop_var_slot_cache.valid_rbx)
    return;
  off = glue_binop_var_slot_cache.rbx_off;
  if (ta == 1 && elf_ctx && off >= 0)
    (void)glue_binop_spill_reg_to_spill_elf_c(elf_ctx, ta, off, 1, stmt_i);
  glue_binop_var_slot_cache_invalidate_rbx();
}

/**
 * 7.3：左结合交换律链 ((…){op}VAR) — 右 VAR 装入 rbx 前，若 rbx 仍缓存其它活跃槽则 spill 到 x10。
 */
/* wave149 Cap residual: pure binop leave (was static). PLATFORM: SHARED. */
void glue_asm73_left_assoc_spill_rbx_before_var_load_elf_c(struct ast_ASTArena *arena,
                                                                   struct backend_AsmFuncCtx *ctx,
                                                                   int32_t right_ref, int32_t ta,
                                                                   struct platform_elf_ElfCodegenCtx *elf_ctx) {
  int32_t roff;
  roff = glue_var_expr_stack_off_elf_c(arena, ctx, right_ref);
  if (roff >= 0 && glue_binop_var_slot_cache.valid_rbx && glue_binop_var_slot_cache.ctx_key == (size_t)ctx &&
      glue_binop_var_slot_cache.rbx_off != roff && glue_block_live_fwd_active && !glue_block_live_cfg_parent &&
      glue_live_fwd_contains(&glue_block_live_fwd, glue_binop_var_slot_cache.rbx_off))
    glue_asm73_evict_rbx_cache_entry(glue_block_emit_stmt_i, ta, elf_ctx);
}

/** 发射 stmt i 前：套用预计算的 live_in 并修剪 binop 槽缓存。 */
/**
 * 7.3 线性 scan：|live|>thresh 且 rax/rbx 已占两槽时，另有活跃槽装不下则驱逐 cache。
 * 默认 thresh=3（repeat_add）；块 |live|max≥6 时 thresh=4。
 * 驱逐策略：失效 next-use 更远的一路（rax/rbx）；距离相同则双清（保守）。
 */
/* wave149 Cap residual helper (was static); pure uses wrapper below. PLATFORM: SHARED. */
static void glue_asm73_linear_scan_evict_cache_if_pressure_live(const GlueBlockLiveFwd *live, int32_t stmt_i,
                                                                int32_t ta,
                                                                struct platform_elf_ElfCodegenCtx *elf_ctx) {
  int32_t i;
  int32_t off;
  int32_t has_uncached_live;
  int32_t dist_rax;
  int32_t dist_rbx;
  int32_t thresh;
  thresh = glue_asm73_pressure_live_thresh();
  if (!live || live->n <= thresh)
    return;
  if (!glue_binop_var_slot_cache.valid_rax || !glue_binop_var_slot_cache.valid_rbx)
    return;
  has_uncached_live = 0;
  for (i = 0; i < live->n; i++) {
    off = live->offs[i];
    if (off >= 0 && off != glue_binop_var_slot_cache.rax_off && off != glue_binop_var_slot_cache.rbx_off &&
        (!glue_binop_var_slot_cache.valid_x10 || off != glue_binop_var_slot_cache.x10_off) &&
        (!glue_binop_var_slot_cache.valid_x11 || off != glue_binop_var_slot_cache.x11_off) &&
        (!glue_binop_var_slot_cache.valid_x12 || off != glue_binop_var_slot_cache.x12_off) &&
        (!glue_binop_var_slot_cache.valid_x13 || off != glue_binop_var_slot_cache.x13_off) &&
        (!glue_binop_var_slot_cache.valid_x14 || off != glue_binop_var_slot_cache.x14_off) &&
        (!glue_binop_var_slot_cache.valid_x15 || off != glue_binop_var_slot_cache.x15_off) &&
        glue_binop_stack_spill_find_depth(off) < 0) {
      has_uncached_live = 1;
      break;
    }
  }
  if (!has_uncached_live)
    return;
  dist_rax = glue_asm73_linear_next_use_dist(stmt_i, glue_binop_var_slot_cache.rax_off);
  dist_rbx = glue_asm73_linear_next_use_dist(stmt_i, glue_binop_var_slot_cache.rbx_off);
  if (dist_rax > dist_rbx)
    glue_asm73_evict_rax_cache_entry(stmt_i, ta, elf_ctx);
  else if (dist_rbx > dist_rax)
    glue_asm73_evict_rbx_cache_entry(stmt_i, ta, elf_ctx);
  else
    glue_binop_var_slot_cache_clear();
}

/* wave149 Cap residual: pure binop leave — no live-fwd pointer across pure/C.
 * Folds glue_block_live_fwd_active + glue_block_emit_stmt_i + live set.
 * PLATFORM: SHARED freestanding 7.3 pressure eviction.
 */
void glue_asm73_evict_cache_if_live_pressure_elf_c(int32_t ta, struct platform_elf_ElfCodegenCtx *elf_ctx) {
  if (glue_block_live_fwd_active)
    glue_asm73_linear_scan_evict_cache_if_pressure_live(&glue_block_live_fwd, glue_block_emit_stmt_i, ta, elf_ctx);
}

static void glue_asm73_linear_scan_evict_cache_if_pressure(int32_t stmt_i, int32_t ta,
                                                            struct platform_elf_ElfCodegenCtx *elf_ctx) {
  if (stmt_i < 0)
    return;
  if (glue_block_live_cfg_parent) {
    if (glue_block_live_fwd_active)
      glue_asm73_linear_scan_evict_cache_if_pressure_live(&glue_block_live_fwd, stmt_i, ta, elf_ctx);
    return;
  }
  if (stmt_i < 32)
    glue_asm73_linear_scan_evict_cache_if_pressure_live(&glue_block_live_at_stmt[stmt_i], stmt_i, ta, elf_ctx);
}

/** 7.3 cfg 父块：顶层 const/let/expr_stmt 发射后前向更新 glue_block_live_fwd。 */
void glue_block_live_fwd_apply_top_stmt(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                int32_t block_ref, int32_t slot_base, int32_t nconst, int32_t nlet,
                                                int32_t stmt_i) {
  GlueBlockLiveFwd gen;
  GlueBlockLiveFwd kill;
  if (!glue_block_live_cfg_parent || stmt_i < 0)
    return;
  glue_block_stmt_gen_kill(arena, ctx, block_ref, slot_base, nconst, nlet, stmt_i, &gen, &kill);
  glue_live_fwd_apply_stmt_gen_kill(&glue_block_live_fwd, &gen, &kill);
}

void glue_block_live_fwd_before_stmt(int32_t stmt_i, int32_t ta,
                                              struct platform_elf_ElfCodegenCtx *elf_ctx) {
  if (!glue_block_live_fwd_active)
    return;
  if (!glue_block_live_cfg_parent && stmt_i >= 0 && stmt_i < 32) {
    glue_live_fwd_copy(&glue_block_live_fwd, &glue_block_live_at_stmt[stmt_i]);
    glue_asm73_linear_scan_evict_cache_if_pressure(stmt_i, ta, elf_ctx);
  } else if (glue_block_live_cfg_parent)
    glue_asm73_linear_scan_evict_cache_if_pressure(stmt_i, ta, elf_ctx);
  glue_binop_cache_intersect_live_fwd();
}

/** Return 1 when rbx still holds the effective addr for the same INDEX lvalue shape. */


/**
 * 7.3：上一笔 INDEX assign 已在 rbx 留下有效址时，EXPR_INDEX 读直接 ldr，免重算 eff_addr。
 * 慢路径仍走 glue_emit_index_eff_addr_scaled_elf_c 并在入口清 cache。
 */


/**
 * 7.3 block-level (i-j+k) subexpr spill cache: push sum in w2 on real stack for cross-stmt reuse.
 */

/** Clear (i-j+k) spill cache metadata (does not emit stack cleanup). */
void glue_index_subadd3_sum_cache_clear(void) {
  glue_index_subadd3_sum_cache.valid = 0;
  glue_index_subadd3_sum_cache.slot_depth = 0;
}

/** Clear (i-j) spill cache metadata (does not emit stack cleanup). */
void glue_index_minus_pair_cache_clear(void) {
  glue_index_minus_pair_cache.valid = 0;
  glue_index_minus_pair_cache.slot_depth = 0;
}

/** arm64: push primary index scratch (x2) on real stack for cross-stmt reuse. */
static int32_t glue_enc_push_index_scratch_arm64_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta != 1)
    return 0;
  /** sub sp, sp, #16 — 同 enc_push_rax */
  if (arch_arm64_enc_enc_u32_le(elf_ctx, 3506455551) != 0)
    return -1;
  /** str x2, [sp] — Rt=x2 */
  if (arch_arm64_enc_enc_u32_le(elf_ctx, 4177527778) != 0)
    return -1;
  glue_index_scratch_stack_depth++;
  return 0;
}

/** arm64: reload primary index scratch from stack slot without popping. */
static int32_t glue_enc_reload_index_scratch_from_stack_arm64_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                     int32_t ta) {
  if (ta != 1)
    return 0;
  /** ldr x2, [sp] */
  return arch_arm64_enc_enc_u32_le(elf_ctx, 4181722082);
}

/** arm64: balance one prior push_index_scratch (add sp, #16). */
static int32_t glue_enc_pop_index_scratch_stack_arm64_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta != 1)
    return 0;
  /** add sp, sp, #16 — 同 enc_pop_rax */
  return arch_arm64_enc_enc_u32_le(elf_ctx, 2432713727);
}

/** Reload w2 from stack slot recorded at slot_depth (1=first push from current top). */
static int32_t glue_index_reload_scratch_slot_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta,
                                                     int32_t slot_depth) {
  int32_t off_bytes;
  int32_t imm12;
  if (slot_depth <= 0 || glue_index_scratch_stack_depth < slot_depth)
    return -1;
  off_bytes = (glue_index_scratch_stack_depth - slot_depth) * 16;
  if (off_bytes == 0)
    return glue_enc_reload_index_scratch_from_stack_arm64_elf_c(elf_ctx, ta);
  if (ta != 1)
    return 0;
  imm12 = off_bytes >> 3;
  /** ldr x2, [sp, #off] — 基底 4181722082 == ldr x2,[sp,#0] */
  return arch_arm64_enc_enc_u32_le(elf_ctx, 4181722082 | ((uint32_t)imm12 << 10));
}

/** Reload stack-spilled index scratch (x2) into rbx/x1 for INDEX read fast paths. */
static int32_t glue_index_reload_scratch_slot_to_rbx_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta,
                                                              int32_t slot_depth) {
  if (glue_index_reload_scratch_slot_elf_c(elf_ctx, ta, slot_depth) != 0)
    return -1;
  if (ta == 1)
    return arch_arm64_enc_enc_mov_x2_to_rbx(elf_ctx);
  return 0;
}

/** Pop all INDEX scratch spills (LIFO) and clear cache metadata. */
/* wave138 Cap residual for pure try_propagate leave: non-static face. */
int32_t glue_index_scratch_spills_cleanup_all_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  while (glue_index_scratch_stack_depth > 0) {
    if (glue_enc_pop_index_scratch_stack_arm64_elf_c(elf_ctx, ta) != 0)
      return -1;
    glue_index_scratch_stack_depth--;
  }
  glue_index_subadd3_sum_cache_clear();
  glue_index_minus_pair_cache_clear();
  return 0;
}

/** 清空 7.3 binop 栈帧 spill 元数据（块入口；物理 pop 由 glue_index_scratch_spills_cleanup_all_elf_c）。 */
void glue_binop_stack_spill_clear(void) {
  glue_binop_stack_spill_n = 0;
}

/** 从栈帧 spill 表移除栈槽 off（不 pop 实栈，块尾统一清理）。 */
static void glue_binop_stack_spill_drop_off(int32_t off) {
  int32_t i;
  int32_t j;
  if (off < 0)
    return;
  for (i = 0; i < glue_binop_stack_spill_n; i++) {
    if (glue_binop_stack_spill_off[i] != off)
      continue;
    for (j = i + 1; j < glue_binop_stack_spill_n; j++) {
      glue_binop_stack_spill_off[j - 1] = glue_binop_stack_spill_off[j];
      glue_binop_stack_spill_at_depth[j - 1] = glue_binop_stack_spill_at_depth[j];
    }
    glue_binop_stack_spill_n--;
    return;
  }
}

/** 返回 off 在栈帧 spill 表中的 push 深度（1=最近一次 push）；无则 -1。 */
static int32_t glue_binop_stack_spill_find_depth(int32_t off) {
  int32_t i;
  if (off < 0)
    return -1;
  for (i = 0; i < glue_binop_stack_spill_n; i++) {
    if (glue_binop_stack_spill_off[i] == off)
      return glue_binop_stack_spill_at_depth[i];
  }
  return -1;
}

/**
 * 7.3：将 rax/rbx 中 VAR 压入实栈（sub sp,#16 + str x0/x1,[sp]），记录 off 与深度。
 * 0=OK，-1=错。
 */
/* wave149 Cap residual: pure binop leave (was static). PLATFORM: SHARED. */
int32_t glue_binop_stack_spill_push_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta, int32_t off,
                                                  int32_t from_rbx) {
  if (ta != 1 || off < 0 || !elf_ctx)
    return 0;
  if (glue_binop_stack_spill_find_depth(off) >= 0)
    return 0;
  if (glue_binop_stack_spill_n >= GLUE_BINOP_STACK_SPILL_CAP)
    return -1;
  if (from_rbx != 0) {
    if (backend_enc_push_rbx_arch(elf_ctx, ta) != 0)
      return -1;
  } else if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) {
    return -1;
  }
  glue_index_scratch_stack_depth++;
  glue_binop_stack_spill_off[glue_binop_stack_spill_n] = off;
  glue_binop_stack_spill_at_depth[glue_binop_stack_spill_n] = glue_index_scratch_stack_depth;
  glue_binop_stack_spill_n++;
  return 0;
}

/**
 * 7.3：若 off 已在栈帧 spill 表，则从对应 [sp,#slot*16] 装入 rax/rbx；1=命中，0=未命中，-1=错。
 */
static int32_t glue_binop_stack_spill_try_reload_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta,
                                                        int32_t off, int32_t to_rbx) {
  int32_t at_depth;
  int32_t slot;
  if (ta != 1 || off < 0 || !elf_ctx)
    return 0;
  at_depth = glue_binop_stack_spill_find_depth(off);
  if (at_depth < 0)
    return 0;
  if (glue_index_scratch_stack_depth < at_depth)
    return 0;
  slot = glue_index_scratch_stack_depth - at_depth;
  if (to_rbx != 0) {
    if (arch_arm64_enc_enc_ldr_sp_slot_to_xreg(elf_ctx, slot, 1) != 0)
      return -1;
    glue_binop_var_slot_cache.valid_rbx = 1;
    glue_binop_var_slot_cache.rbx_off = off;
  } else {
    if (arch_arm64_enc_enc_ldr_sp_slot_to_xreg(elf_ctx, slot, 0) != 0)
      return -1;
    glue_binop_var_slot_cache.valid_rax = 1;
    glue_binop_var_slot_cache.rax_off = off;
  }
  return 1;
}

/** Pop only the top spill when it holds a stale (i-j+k) sum. */
static int32_t glue_index_subadd3_spill_pop_top_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (!glue_index_subadd3_sum_cache.valid ||
      glue_index_subadd3_sum_cache.slot_depth != glue_index_scratch_stack_depth)
    return 0;
  glue_index_subadd3_sum_cache_clear();
  if (glue_enc_pop_index_scratch_stack_arm64_elf_c(elf_ctx, ta) != 0)
    return -1;
  glue_index_scratch_stack_depth--;
  return 0;
}

/** Backward compat alias: full spill stack cleanup. */
static int32_t glue_index_subadd3_sum_cache_stack_cleanup_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                 int32_t ta) {
  return glue_index_scratch_spills_cleanup_all_elf_c(elf_ctx, ta);
}

/** Invalidate scratch spills when i/j/k (or i/j) locals are assigned. */
void glue_index_scratch_spill_invalidate_var(struct ast_ASTArena *arena,
                                                     struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                     struct backend_AsmFuncCtx *ctx, int32_t var_ref,
                                                     int32_t ta) {
  uint64_t vkey;
  int32_t hit;
  if (!arena || var_ref <= 0)
    return;
  vkey = glue_index_expr_struct_key_elf_c(arena, var_ref);
  hit = 0;
  if (glue_index_subadd3_sum_cache.valid &&
      (vkey == glue_index_subadd3_sum_cache.i_key || vkey == glue_index_subadd3_sum_cache.j_key ||
       vkey == glue_index_subadd3_sum_cache.k_key))
    hit = 1;
  if (glue_index_minus_pair_cache.valid &&
      (vkey == glue_index_minus_pair_cache.i_key || vkey == glue_index_minus_pair_cache.j_key))
    hit = 1;
  if (hit)
    (void)glue_index_scratch_spills_cleanup_all_elf_c(elf_ctx, ta);
  (void)ctx;
}

/** After sub w2=w2-w3 yields (i-j), push w2 and remember keys. */
static int32_t glue_index_minus_pair_cache_spill_after_sub_elf_c(struct ast_ASTArena *arena,
                                                                  struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                  struct backend_AsmFuncCtx *ctx, int32_t i_ref,
                                                                  int32_t j_ref, int32_t ta) {
  if (ta != 1)
    return 0;
  if (glue_enc_push_index_scratch_arm64_elf_c(elf_ctx, ta) != 0)
    return -1;
  glue_index_minus_pair_cache.valid = 1;
  glue_index_minus_pair_cache.ctx_key = (size_t)ctx;
  glue_index_minus_pair_cache.i_key = glue_index_expr_struct_key_elf_c(arena, i_ref);
  glue_index_minus_pair_cache.j_key = glue_index_expr_struct_key_elf_c(arena, j_ref);
  glue_index_minus_pair_cache.slot_depth = glue_index_scratch_stack_depth;
  return 0;
}

/** Return 1 when spilled (i-j) matches var pair. */
static int32_t glue_index_minus_pair_cache_hit(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                int32_t i_ref, int32_t j_ref, int32_t ta) {
  if (ta != 1 || !glue_index_minus_pair_cache.valid)
    return 0;
  if (glue_index_minus_pair_cache.ctx_key != (size_t)ctx)
    return 0;
  if (glue_index_minus_pair_cache.slot_depth <= 0 ||
      glue_index_minus_pair_cache.slot_depth > glue_index_scratch_stack_depth)
    return 0;
  if (glue_index_minus_pair_cache.i_key != glue_index_expr_struct_key_elf_c(arena, i_ref))
    return 0;
  if (glue_index_minus_pair_cache.j_key != glue_index_expr_struct_key_elf_c(arena, j_ref))
    return 0;
  return 1;
}

/** Invalidate when a subadd3 operand local is assigned. */
static void glue_index_subadd3_sum_cache_invalidate_var(struct ast_ASTArena *arena,
                                                         struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                         struct backend_AsmFuncCtx *ctx, int32_t var_ref,
                                                         int32_t ta) {
  glue_index_scratch_spill_invalidate_var(arena, elf_ctx, ctx, var_ref, ta);
}

/** Return 1 when spilled (i-j+k) sum matches i/j/k var refs. */
static int32_t glue_index_subadd3_sum_cache_hit(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                 int32_t i_ref, int32_t j_ref, int32_t k_ref, int32_t ta) {
  if (ta != 1 || !glue_index_subadd3_sum_cache.valid)
    return 0;
  if (glue_index_subadd3_sum_cache.ctx_key != (size_t)ctx)
    return 0;
  if (glue_index_subadd3_sum_cache.slot_depth <= 0 ||
      glue_index_subadd3_sum_cache.slot_depth > glue_index_scratch_stack_depth)
    return 0;
  if (glue_index_subadd3_sum_cache.i_key != glue_index_expr_struct_key_elf_c(arena, i_ref))
    return 0;
  if (glue_index_subadd3_sum_cache.j_key != glue_index_expr_struct_key_elf_c(arena, j_ref))
    return 0;
  if (glue_index_subadd3_sum_cache.k_key != glue_index_expr_struct_key_elf_c(arena, k_ref))
    return 0;
  return 1;
}

/** Reserve one i32 temp below rbp via ctx->next_offset (8-byte aligned). */
static int32_t glue_index_subadd3_sum_cache_spill_store_elf_c(struct ast_ASTArena *arena,
                                                               struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                               struct backend_AsmFuncCtx *ctx, int32_t i_ref,
                                                               int32_t j_ref, int32_t k_ref, int32_t ta) {
  (void)arena;
  (void)ctx;
  if (ta != 1)
    return 0;
  if (glue_enc_push_index_scratch_arm64_elf_c(elf_ctx, ta) != 0)
    return -1;
  glue_index_subadd3_sum_cache.valid = 1;
  glue_index_subadd3_sum_cache.ctx_key = (size_t)ctx;
  glue_index_subadd3_sum_cache.i_key = glue_index_expr_struct_key_elf_c(arena, i_ref);
  glue_index_subadd3_sum_cache.j_key = glue_index_expr_struct_key_elf_c(arena, j_ref);
  glue_index_subadd3_sum_cache.k_key = glue_index_expr_struct_key_elf_c(arena, k_ref);
  glue_index_subadd3_sum_cache.slot_depth = glue_index_scratch_stack_depth;
  return 0;
}

/* wave157: frame-sum pure-owned leave (runtime_pipeline_abi pure).
 * G.7: do not re-define glue_asm_sum_block_call_spill_bytes /
 * glue_sum_block_slice_reent_dc_bytes_c / w157_sum_expr walk here.
 * Keep residual TU externs that frame-sum historically provided for later
 * same-TU consumers (wpo / index). PLATFORM: SHARED — residual shell only. */
extern int32_t pipeline_expr_method_call_base_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_method_call_num_args_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_method_call_arg_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_block_while_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t wi);
extern int32_t pipeline_block_while_body_ref(struct ast_ASTArena *a, int32_t br, int32_t wi);
extern int32_t pipeline_block_for_init_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
extern int32_t pipeline_block_for_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
extern int32_t pipeline_block_for_step_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
extern int32_t pipeline_block_for_body_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
extern int32_t pipeline_block_region_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ri);
extern int32_t ast_pipeline_block_if_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);

/* ========================================================================== *
 * wave153 Cap residual: block_body pure leave BSS / live global accessors.
 * Pure owns block_body_sync / defer / final_expr / if_arm faces; residual keeps
 * GlueBlockLiveFwd BSS + Chaitin maps (G.7 single authority for spill domain).
 * PLATFORM: SHARED freestanding emit · host-cc residual shell.
 * ========================================================================== */

int32_t glue_asm73_cfg_coloring_active_get(void) {
  return glue_asm73_cfg_coloring_active;
}

void glue_asm73_cfg_coloring_active_set(int32_t v) {
  glue_asm73_cfg_coloring_active = v ? 1 : 0;
}

int32_t glue_block_live_cfg_parent_get(void) {
  return glue_block_live_cfg_parent;
}

void glue_block_live_cfg_parent_set(int32_t v) {
  glue_block_live_cfg_parent = v ? 1 : 0;
}

int32_t glue_block_live_fwd_active_get(void) {
  return glue_block_live_fwd_active;
}

void glue_block_live_fwd_active_set(int32_t v) {
  glue_block_live_fwd_active = v ? 1 : 0;
}

void glue_block_emit_stmt_i_set(int32_t v) {
  glue_block_emit_stmt_i = v;
}

int32_t glue_block_emit_stmt_i_get(void) {
  return glue_block_emit_stmt_i;
}

void glue_asm73_pin_spill_off_clear_all(void) {
  glue_asm73_pin_spill_off[0] = -1;
  glue_asm73_pin_spill_off[1] = -1;
  glue_asm73_pin_spill_off[2] = -1;
  glue_asm73_pin_spill_off[3] = -1;
  glue_asm73_pin_spill_off[4] = -1;
  glue_asm73_pin_spill_off[5] = -1;
}

int32_t glue_asm73_cfg_peak_live_n_get(void) {
  return glue_asm73_cfg_peak_live.n;
}

void glue_block_live_fwd_clear_global(void) {
  glue_live_fwd_clear(&glue_block_live_fwd);
}

void glue_live_snap_before_if_copy_from_block_live_fwd(void) {
  glue_live_fwd_copy(&glue_live_snap_before_if, &glue_block_live_fwd);
}

void glue_block_live_sub_exit_snap_clear(void) {
  glue_live_fwd_clear(&glue_block_live_sub_exit_snap);
}

void glue_block_live_sub_exit_snap_copy_from_block_live_fwd(void) {
  glue_live_fwd_copy(&glue_block_live_sub_exit_snap, &glue_block_live_fwd);
}

/**
 * wave153 Cap residual: compute linear live_end into global sub_exit snap.
 * PLATFORM: SHARED freestanding emit.
 */
void glue_block_compute_live_end_linear_to_sub_exit_snap(struct ast_ASTArena *arena,
                                                        struct backend_AsmFuncCtx *ctx,
                                                        int32_t block_ref) {
  glue_block_compute_live_end_linear(arena, ctx, block_ref, &glue_block_live_sub_exit_snap);
}

/**
 * wave153 Cap residual: clear global live_fwd then collect uses of final_expr.
 * PLATFORM: SHARED freestanding emit.
 */
void glue_block_live_fwd_set_from_expr_uses(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                           int32_t expr_ref) {
  glue_live_fwd_clear(&glue_block_live_fwd);
  if (expr_ref > 0)
    glue_live_fwd_collect_expr_uses(arena, ctx, expr_ref, &glue_block_live_fwd);
}

/**
 * wave153 Cap residual: live buffer n / offs accessors for pure defer fixpoint
 * (opaque u8[136] overlays of GlueBlockLiveFwd).
 * PLATFORM: SHARED freestanding emit.
 */
int32_t glue_live_fwd_n_get(const void *live) {
  if (!live)
    return 0;
  return ((const GlueBlockLiveFwd *)live)->n;
}

int32_t glue_live_fwd_off_at(const void *live, int32_t i) {
  const GlueBlockLiveFwd *lv = (const GlueBlockLiveFwd *)live;
  if (!lv || i < 0 || i >= lv->n)
    return -1;
  return lv->offs[i];
}

/* wave153 Cap residual: void* overloads for pure *u8 live buffers (same ABI). */
void glue_live_fwd_clear_u8(void *live) {
  glue_live_fwd_clear((GlueBlockLiveFwd *)live);
}

void glue_live_fwd_add_u8(void *live, int32_t off) {
  glue_live_fwd_add((GlueBlockLiveFwd *)live, off);
}
