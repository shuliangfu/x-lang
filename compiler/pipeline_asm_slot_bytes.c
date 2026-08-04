
/* ============================================================================
 * pipeline_asm_slot_bytes.c — backend asm slot bytes + ensure_block_locals
 *
 * wave1253 BC 8.3.2 G.7 same-TU domain fold from ast_pool.c:
 *   asm_slot_bytes_named_in_mod + asm_fixed_array_total_bytes_mod
 *   + asm_ctx_module_ref + asm_local_slot_bytes_mod + asm_local_slot_bytes
 *   + asm_ctx_ensure_block_locals
 *
 * Stack slot byte calculation for const/let locals + lazy block-local fill.
 * Included from ast_pool.c (replaces former inline body). Not a separate .o.
 * Depends on GrowVec sidecar (pipeline_asm_locals.c) + typeck layout glues
 * + ast_pool_bootstrap_glue.c (asm_type_is_simd_vector_spelling).
 *
 * PLATFORM: SHARED.
 * ============================================================================ */
/** 前向声明：实现在下文（ensure_block_locals 须按类型步进栈槽）。 */
int32_t asm_local_slot_bytes(struct ast_ASTArena *arena, int32_t type_ref);
extern struct ast_Module *pipeline_asm_glue_emit_module_ref(void);
extern int32_t asm_bump_off_before_struct_local(struct ast_ASTArena *arena, int32_t type_ref, int32_t off);
extern int32_t asm_bump_off_align_for_local(struct ast_ASTArena *arena, int32_t type_ref, int32_t off);
extern int32_t asm_local_slot_reg_offset(struct ast_ASTArena *arena, int32_t type_ref, int32_t off,
                                         int32_t *inout_off);
extern int32_t pipeline_asm_let_init_stack_reserve_bytes(struct ast_ASTArena *arena, int32_t type_ref,
                                                         int32_t init_ref);
extern int32_t typeck_soa_array_storage_size_glue(struct ast_Module *module, struct ast_ASTArena *arena,
                                                  int32_t elem_type_ref, int32_t array_len, int32_t depth);
extern int32_t typeck_x_type_size_from_layout_glue(struct ast_Module *module, struct ast_ASTArena *arena,
                                                    int32_t li, int32_t depth);
/* Metrics RC distinguishes true ZST (size 0, rc=0) from metrics failure (rc!=0, size_from_layout also 0). */
extern int32_t typeck_typeck_struct_layout_metrics(struct ast_Module *module, struct ast_ASTArena *arena, int32_t li,
                                                   int32_t depth, int32_t check_pad, int32_t *out_sz, int32_t *out_al);
extern struct ast_PipelineDepCtx *pipeline_asm_emit_dep_pipe_c(void);
/* Defined in ast_pool_bootstrap_glue.c (#included near EOF in host TU). */
extern int32_t asm_type_is_simd_vector_spelling(struct ast_ASTArena *arena, int32_t type_ref);

static int32_t asm_local_slot_bytes_mod(struct ast_ASTArena *arena, int32_t type_ref, struct ast_Module *mod);

/**
 * Look up TYPE_NAMED struct layout stack slot bytes in one module.
 *
 * Why: typeck-skip entry modules may lack dep layouts (e.g. PageMmapHeap); without
 * dep walk, slot defaults to 8B while real layout is 24B and trailing fields clobber
 * neighbors.
 *
 * wave369 Cap residual pure (PLATFORM: SHARED freestanding stack layout · LINUX gold):
 *   typeck_x_type_size_from_layout_glue returns 0 both for true ZST (Empty / empty-of-empty
 *   Nest, metrics rc==0) and for metrics failure (rc!=0). Prior `sz<=0` invent path used
 *   last_field_off+fsz → Nest became 8, parent Box became 24, mid Nest field store/load
 *   offsets garbage (Ubuntu freestanding nest_mid exit ≠ 42; mac arm64 often folded away).
 *   G.7: call metrics once; rc==0 && sz==0 → return 0 (true ZST, do not invent); rc!=0 keep
 *   legacy invent for incomplete skip-typeck layouts.
 *
 * Invariant: only scans mod->num_struct_layouts. Return >0 hit (padded to 8), 0 miss or ZST.
 * Asm/Perf: dep walk only when entry miss; entry-module struct hot path is zero-cost.
 */
static int32_t asm_slot_bytes_named_in_mod(struct ast_ASTArena *arena, int32_t type_ref, struct ast_Module *mod) {
  uint8_t name[128];
  int32_t nlen;
  int32_t k;
  if (!arena || type_ref <= 0 || !mod)
    return 0;
  nlen = pipeline_type_named_name_into(arena, type_ref, name);
  if (nlen <= 0 || nlen > 127)
    return 0;
  /** 【Why】type name 可能带模块前缀（如 "heap.PageMmapHeap"），而 struct layout
   *  name 是裸名（"PageMmapHeap"）；比较时取最后一个 "." 之后的部分。
   * 【Invariant】仅修改本地 name buf，不影响 arena 内 type name。 */
  {
    int32_t dot = -1;
    int32_t j;
    for (j = 0; j < nlen; j++) {
      if (name[j] == '.')
        dot = j;
    }
    if (dot >= 0) {
      int32_t base_off = dot + 1;
      int32_t base_len = nlen - base_off;
      if (base_len <= 0)
        return 0;
      for (j = 0; j < base_len; j++)
        name[j] = name[base_off + j];
      nlen = base_len;
    }
  }
  for (k = 0; k < (int32_t)mod->num_struct_layouts; k++) {
    int32_t ln = pipeline_module_struct_layout_name_len(mod, k);
    int32_t j;
    int32_t eq = 1;
    int32_t sz;
    int32_t al;
    int32_t mrc;
    if (ln != nlen)
      continue;
    for (j = 0; j < nlen; j++) {
      if (pipeline_module_struct_layout_name_byte_at(mod, k, j) != name[j]) {
        eq = 0;
        break;
      }
    }
    if (!eq)
      continue;
    /* Prefer metrics RC so size 0 ZST is not confused with metrics failure. */
    sz = 0;
    al = 1;
    mrc = typeck_typeck_struct_layout_metrics(mod, arena, k, 0, 0, &sz, &al);
    if (link_abi_getenv("XLANG_ASM_EMIT_TRACE")) {
      uint8_t dbg_nm[128];
      int32_t dbg_nl = pipeline_module_struct_layout_name_len(mod, k);
      int32_t dbg_nf = pipeline_module_struct_layout_num_fields(mod, k);
      int32_t di;
      if (dbg_nl > 127)
        dbg_nl = 63;
      for (di = 0; di < dbg_nl; di++)
        dbg_nm[di] = pipeline_module_struct_layout_name_byte_at(mod, k, di);
      dbg_nm[dbg_nl] = 0;
      fprintf(stderr, "xlang: slot_metrics name=%.*s li=%d nf=%d mrc=%d sz=%d al=%d\n", (int)dbg_nl, dbg_nm,
              (int)k, (int)dbg_nf, (int)mrc, (int)sz, (int)al);
      for (di = 0; di < dbg_nf && di < 8; di++) {
        int32_t ftr = pipeline_module_struct_layout_field_type_ref(mod, k, di);
        int32_t foff = pipeline_module_struct_layout_field_offset_at(mod, k, di);
        fprintf(stderr, "xlang:   field[%d] ftr=%d foff=%d\n", (int)di, (int)ftr, (int)foff);
      }
    }
    if (mrc == 0) {
      /* Metrics OK: sz==0 is legal Empty / empty-of-empty Nest ZST (wave366/368/369). */
      if (sz <= 0)
        return 0;
      if (sz % 8 != 0)
        sz += 8 - (sz % 8);
      return sz;
    }
    /* Metrics failed (incomplete layout / skip typeck): legacy invent last_off+fsz. */
    {
      int32_t nf = pipeline_module_struct_layout_num_fields(mod, k);
      if (nf > 0) {
        int32_t last = nf - 1;
        int32_t foff = pipeline_module_struct_layout_field_offset_at(mod, k, last);
        int32_t fty = pipeline_module_struct_layout_field_type_ref(mod, k, last);
        int32_t fsz = asm_local_slot_bytes_mod(arena, fty, mod);
        if (fsz <= 0)
          fsz = 4;
        sz = foff + fsz;
        if (link_abi_getenv("XLANG_ASM_EMIT_TRACE"))
          fprintf(stderr, "xlang: slot_invent last_foff=%d fty=%d fsz=%d sz=%d\n", (int)foff, (int)fty, (int)fsz,
                  (int)sz);
      } else {
        /* Bare empty layout with failed metrics still ZST. */
        return 0;
      }
    }
    if (sz > 0) {
      if (sz % 8 != 0)
        sz += 8 - (sz % 8);
      return sz;
    }
  }
  return 0;
}

/**
 * T[N] 定长数组总字节宽：SoA 列主序或 AoS N×struct layout（与 typeck typeck_x_type_size 一致）。
 * 非 struct 元素或 layout 未命中时返回 0，由调用方回落 esz 启发式。
 */
static int32_t asm_fixed_array_total_bytes_mod(struct ast_ASTArena *arena, int32_t type_ref, struct ast_Module *mod) {
  struct ast_Type *t;
  int32_t elem_ref;
  int32_t soa_sz;
  if (!arena || type_ref <= 0 || type_ref > arena->num_types)
    return 0;
  t = pipeline_arena_type_ptr(arena, type_ref);
  if (!t || pipeline_type_kind_ord_at(arena, type_ref) != 10 || t->array_size <= 0)
    return 0;
  elem_ref = t->elem_type_ref;
  if (elem_ref <= 0)
    return 0;
  if (!mod)
    mod = pipeline_asm_glue_emit_module_ref();
  if (!mod || pipeline_type_kind_ord_at(arena, elem_ref) != 8)
    return 0;
  soa_sz = typeck_soa_array_storage_size_glue(mod, arena, elem_ref, t->array_size, 0);
  if (soa_sz > 0)
    return soa_sz;
  {
    uint8_t ename[128];
    int32_t elen = pipeline_type_named_name_into(arena, elem_ref, ename);
    if (elen > 0 && elen <= 63) {
      int32_t lk;
      for (lk = 0; lk < (int32_t)mod->num_struct_layouts; lk++) {
        int32_t ln = pipeline_module_struct_layout_name_len(mod, lk);
        int32_t j;
        int32_t eq = 1;
        int32_t es;
        if (ln != elen)
          continue;
        for (j = 0; j < elen; j++) {
          if (pipeline_module_struct_layout_name_byte_at(mod, lk, j) != ename[j]) {
            eq = 0;
            break;
          }
        }
        if (!eq)
          continue;
        es = typeck_x_type_size_from_layout_glue(mod, arena, lk, 0);
        if (es > 0)
          return t->array_size * es;
      }
    }
  }
  return 0;
}

/**
 * 从 AsmFuncCtx 前缀读取 module_ref（偏移 16，与 backend.x / pipeline_glue 布局一致）。
 * fill_block_locals_tree 早于 emit 设置 global 时仍可按 layout 算 struct 栈槽宽。
 */
static struct ast_Module *asm_ctx_module_ref(uint8_t *ctx) {
  if (!ctx)
    return NULL;
  return *(struct ast_Module **)(ctx + 16);
}

/**
 * 单个 const/let 栈槽字节；mod 优先，否则回落 g_pipeline_asm_emit_module。
 */
static int32_t asm_local_slot_bytes_mod(struct ast_ASTArena *arena, int32_t type_ref, struct ast_Module *mod) {
  struct ast_Type *t;
  int32_t elem_ref;
  int32_t esz;
  int32_t lanes;
  int32_t bytes;
  if (!arena || type_ref <= 0 || type_ref > arena->num_types)
    return 8;
  t = pipeline_arena_type_ptr(arena, type_ref);
  if (!t)
    return 8;
  /** 与 pipeline_type_kind_ord_at / glue_type_size_simple 一致，勿直接读 t->kind。 */
  if (pipeline_type_kind_ord_at(arena, type_ref) == 8) {
    if (!mod)
      mod = pipeline_asm_glue_emit_module_ref();
    {
      int32_t sz = asm_slot_bytes_named_in_mod(arena, type_ref, mod);
      if (sz > 0) {
        if (link_abi_getenv("XLANG_ASM_EMIT_TRACE")) {
          uint8_t nm[128];
          int32_t nl = pipeline_type_named_name_into(arena, type_ref, nm);
          fprintf(stderr, "xlang: local_slot struct %.*s sz=%d\n", (int)nl, nm, (int)sz);
        }
        return sz;
      }
    }
    /** 【Why】typeck skip 时入口模块无 dep struct 的 layout（PageMmapHeap 定义在
     *  std.heap.page_mmap），须遍历 dep_ctx 查找；否则栈槽算成默认 8B，实际 24B，
     *  struct 末字段（off）越界覆盖相邻局部变量（path 数组被 h.off 破坏）。
     * 【Invariant】仅入口模块未命中时触发；dep 模块按 import 顺序线性扫描。
     * 【Asm/Perf】dep struct 局部变量为低频路径（freestanding gate），遍历开销可忽略。 */
    {
      struct ast_PipelineDepCtx *dep = pipeline_asm_emit_dep_pipe_c();
      if (dep) {
        int32_t nd = pipeline_dep_ctx_ndep(dep);
        int32_t di;
        for (di = 0; di < nd; di++) {
          struct ast_Module *dm = pipeline_dep_ctx_module_at(dep, di);
          if (!dm || dm == mod)
            continue;
          {
            int32_t sz = asm_slot_bytes_named_in_mod(arena, type_ref, dm);
            if (sz > 0)
              return sz;
          }
        }
      }
    }
  }
  /** 定长数组 T[N] 按值内联栈槽；SoA 列主序 / AoS N×layout，勿误用 esz=8 指针宽。 */
  if (pipeline_type_kind_ord_at(arena, type_ref) == 10 && t->array_size > 0) {
    elem_ref = t->elem_type_ref;
    {
      int32_t arr_sz = asm_fixed_array_total_bytes_mod(arena, type_ref, mod);
      if (arr_sz > 0) {
        if (arr_sz % 8 != 0)
          arr_sz += 8 - (arr_sz % 8);
        return arr_sz;
      }
    }
    /*
     * wave357 Cap residual pure: multi-dim T[N][M] slot = N × unpadded sizeof(inner).
     * Prior: elem TYPE_ARRAY fell through esz=4 default → [2][3]i32 slot=8, overflow + SIGSEGV.
     * Unpadded row stride matches INDEX/init (glue_fixed_array_total_bytes); pad only outer.
     * PLATFORM: SHARED freestanding stack layout · LINUX gold.
     */
    if (elem_ref > 0 && elem_ref <= arena->num_types &&
        pipeline_type_kind_ord_at(arena, elem_ref) == 10) {
      /* Recursively peel nested TYPE_ARRAY dims to a scalar esz, product of all sizes. */
      int32_t cur = type_ref;
      int32_t prod = 1;
      int32_t d;
      int32_t leaf_esz = 4;
      for (d = 0; d < 8; d++) {
        struct ast_Type *ct = pipeline_arena_type_ptr(arena, cur);
        int32_t cn;
        int32_t ce;
        if (!ct || pipeline_type_kind_ord_at(arena, cur) != 10)
          break;
        cn = ct->array_size;
        ce = ct->elem_type_ref;
        if (cn <= 0 || ce <= 0)
          break;
        prod *= cn;
        if (pipeline_type_kind_ord_at(arena, ce) != 10) {
          int32_t lek = pipeline_type_kind_ord_at(arena, ce);
          if (lek == 2 || lek == 1)
            leaf_esz = 1;
          else if (lek == 15 || lek == 4 || lek == 5 || lek == 6 || lek == 7 ||
                   lek == 9 /* TYPE_PTR */)
            leaf_esz = 8;
          else if (lek == 8) {
            int32_t ssz = asm_slot_bytes_named_in_mod(arena, ce, mod);
            leaf_esz = ssz > 0 ? ssz : 8;
          } else
            leaf_esz = 4;
          bytes = prod * leaf_esz;
          if (bytes < 8)
            bytes = 8;
          if (bytes % 8 != 0)
            bytes = bytes + (8 - (bytes % 8));
          return bytes;
        }
        cur = ce;
      }
    }
    /*
     * wave637 Cap residual pure: T[N] element TYPE_PTR → esz 8 (`*i32[2]` slot 16).
     * Prior only named/u64/i64/usize → PTR defaulted 4 → 8B slot, a[1] clobbered y
     * on LINUX|x86 high-end (INDEX stride already 8 after INDEX result PTR fix).
     * G.7: same PTR=8 as glue_fixed_array_total_bytes_c / array_lit_elem_byte_sz.
     * PLATFORM: SHARED freestanding stack · LINUX gold · MACOS|ARM64 co-path.
     */
    esz = 4;
    if (elem_ref > 0 && elem_ref <= arena->num_types) {
      int32_t ek = pipeline_type_kind_ord_at(arena, elem_ref);
      if (ek == 2 || ek == 1)
        esz = 1;
      else if (ek == 14 || ek == 0 || ek == 3 || ek == 13)
        esz = 4;
      else if (ek == 8 || ek == 4 || ek == 5 || ek == 6 || ek == 7 || ek == 15 || ek == 9)
        esz = 8;
    }
    bytes = t->array_size * esz;
    if (bytes < 8)
      bytes = 8;
    if (bytes % 8 != 0)
      bytes = bytes + (8 - (bytes % 8));
    return bytes;
  }
  /** T[] 切片：{ data: *T, length: usize } 16 字节（对齐 codegen.c AST_TYPE_SLICE size）。 */
  if (pipeline_type_kind_ord_at(arena, type_ref) == 11)
    return 16;
  /* TYPE_VECTOR ord==13；或 NAMED i32x4 等拼写（lex IDENT 回落）。 */
  if (!asm_type_is_simd_vector_spelling(arena, type_ref) && pipeline_type_kind_ord_at(arena, type_ref) != 13)
    return 8;
  if (pipeline_type_kind_ord_at(arena, type_ref) != 13) {
    /** NAMED 拼写：lane 数由类型名 x4/x8/x16 或 Vec8i 推断。 */
    lanes = 4;
    if (t->name_len == 5 && t->name[4] == 56)
      lanes = 8;
    if (t->name_len == 6 && t->name[4] == 49 && t->name[5] == 54)
      lanes = 16;
    if (t->name_len == 5 && memcmp(t->name, "Vec8i", 5) == 0)
      lanes = 8;
    esz = 4;
    bytes = lanes * esz;
    if (bytes < 8)
      bytes = 8;
    if (bytes % 8 != 0)
      bytes = bytes + (8 - (bytes % 8));
    return bytes;
  }
  lanes = t->array_size > 0 ? t->array_size : 4;
  esz = 4;
  elem_ref = t->elem_type_ref;
  if (elem_ref > 0 && elem_ref <= arena->num_types) {
    struct ast_Type *et = pipeline_arena_type_ptr(arena, elem_ref);
    if (et) {
      if ((int32_t)et->kind == 2)
        esz = 1;
      else if ((int32_t)et->kind == 14)
        esz = 4;
      else if ((int32_t)et->kind == 8 || (int32_t)et->kind == 4 || (int32_t)et->kind == 5 ||
               (int32_t)et->kind == 6)
        esz = 8;
    }
  }
  bytes = lanes * esz;
  if (bytes < 8)
    bytes = 8;
  if (bytes % 8 != 0)
    bytes = bytes + (8 - (bytes % 8));
  return bytes;
}

/** 公开入口：无 ctx 时仅依赖 g_pipeline_asm_emit_module。 */
int32_t asm_local_slot_bytes(struct ast_ASTArena *arena, int32_t type_ref) {
  return asm_local_slot_bytes_mod(arena, type_ref, NULL);
}

/**
 * 懒登记 block 内 const/let 到 asm 局部 sidecar（C 实现，避免 .x 生成代码在 if+while 双路径组合时崩溃）。
 * inout_next_offset / inout_num_locals 对应 AsmFuncCtx.next_offset / num_locals。
 * 与 pipeline_asm_fill_local_slots 一致：struct 前 16 字节对齐 + layout 真实槽宽。
 */
void asm_ctx_ensure_block_locals(uint8_t *ctx, struct ast_ASTArena *arena, int32_t block_ref,
                                 int32_t *inout_next_offset, int32_t *inout_num_locals) {
  struct ast_Block *b;
  struct ast_Module *mod;
  int32_t i, off, base, nlen, type_ref, init_ref;
  uint8_t name_buf[128];
  if (!ctx || !arena || !inout_next_offset || !inout_num_locals || block_ref <= 0)
    return;
  if (asm_ctx_block_slot_get(ctx, block_ref) >= 0)
    return;
  b = block_at(arena, block_ref);
  if (!b)
    return;
  mod = asm_ctx_module_ref(ctx);
  if (!mod)
    mod = pipeline_asm_glue_emit_module_ref();
  base = asm_ctx_local_count(ctx);
  asm_ctx_block_slot_set(ctx, block_ref, base);
  off = *inout_next_offset;
  for (i = 0; i < b->num_consts; i++) {
    nlen = pipeline_block_const_name_len(arena, block_ref, i);
    if (nlen <= 0)
      continue;
    pipeline_block_const_name_copy64(arena, block_ref, i, name_buf);
    type_ref = pipeline_block_const_type_ref(arena, block_ref, i);
    {
      int32_t slot_off = asm_local_slot_reg_offset(arena, type_ref, off, &off);
      if (asm_ctx_local_append(ctx, name_buf, nlen, slot_off) < 0)
        return;
    }
    init_ref = pipeline_block_const_init_ref(arena, block_ref, i);
    off += pipeline_asm_let_init_stack_reserve_bytes(arena, type_ref, init_ref);
  }
  for (i = 0; i < b->num_lets; i++) {
    nlen = pipeline_block_let_name_len(arena, block_ref, i);
    if (nlen <= 0)
      continue;
    pipeline_block_let_name_copy64(arena, block_ref, i, name_buf);
    type_ref = pipeline_block_let_type_ref(arena, block_ref, i);
    {
      int32_t slot_off = asm_local_slot_reg_offset(arena, type_ref, off, &off);
      if (asm_ctx_local_append(ctx, name_buf, nlen, slot_off) < 0)
        return;
    }
    init_ref = pipeline_block_let_init_ref(arena, block_ref, i);
    off += pipeline_asm_let_init_stack_reserve_bytes(arena, type_ref, init_ref);
  }
  *inout_next_offset = off;
  *inout_num_locals = asm_ctx_local_count(ctx);
}

