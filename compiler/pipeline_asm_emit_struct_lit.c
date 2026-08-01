/**
 * pipeline_asm_emit_struct_lit.c — asm ELF STRUCT_LIT emit domain (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega freestanding EXPR_STRUCT_LIT field
 * materialization into a stack temp / sret home / DEST_IN_RBX:
 * - glue_struct_lit_field_store_sz (per-field store width; ZST / dual-GP / f32)
 * - pipeline_expr_struct_lit_field_store_sz (X/asm partial public wrapper)
 * - GLUE_ASM_MAX_STRUCT_LIT_FIELDS / DEST_IN_RBX / REHOME_CPU_STACK sentinels
 * - glue_struct_lit_rehome_dest_rbx_elf_c (dest re-home for sret_direct fields)
 * - pipeline_asm_emit_struct_lit_fields_elf_c (per-field emit + store loop)
 * - pipeline_asm_emit_struct_lit_elf_c (public entry; stack_slot_off=-1 temp)
 *
 * G.7: single product-mega STRUCT_LIT ELF face — do not open a second field
 * store width path or second DEST_IN_RBX / rehome geometry. Fixed TYPE_ARRAY
 * field store (glue_struct_lit_store_fixed_array_field_elf_c) and vector /
 * array flat let-init live in pipeline_asm_emit_vector_let.c (same TU).
 *
 * Callers: emit_expr leaf STRUCT_LIT; assign INDEX STRUCT_LIT; call-arg
 * STRUCT_LIT packing; array_lit / vector_let >8B named elem paths.
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c at the former
 * STRUCT_LIT field-store body site (after dual-GP / fixed-array forwards;
 * before array_lit leaf peel / vector_let_init).
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 *   · LINUX+MACOS x86_64 SysV dual-GP 9–16B / ZST 0B store
 *   · MACOS|ARM64 AAPCS64 sret_direct / high-end x86 field frame mag via callees
 */

/* Forward decls / callees defined elsewhere in the same TU:
 * - glue_sysv_dual_gp_byte_size_c / glue_type_named_layout_size_any_module_elf_c
 * - glue_type_size_simple
 * - glue_struct_lit_store_fixed_array_field_elf_c (pipeline_asm_emit_vector_let.c)
 * - glue_struct_field_frame_mag_c / glue_field_access_effective_offset_c
 * - glue_call_return_byte_size_c / glue_store_retval_pair_to_rbp_elf_c
 * - glue_emit_struct_type_let_init_elf_c / glue_emit_sret_memcpy_rbx_to_home
 * - pipeline_asm_emit_expr_elf_rec / backend_enc_* / g_pipeline_asm_emit_*
 *
 * wave1032 G.7 fold: glue_type_is_empty_struct_c is now defined at the top
 * of this file (sole in-TU leaf consumer + residual glue.c callers after
 * this #include site).
 * wave1035 G.7 fold: pipeline_expr_struct_lit_field_offset_at +
 * pipeline_expr_struct_lit_field_type_ref_at are now defined at the top of
 * this file (sole in-TU leaf consumer: 2 callsites each at L119/L276/L278;
 * residual glue.c wrappers codegen_/backend_ at L17076/L17084 after this
 * #include site; seed backend_try_inline_dispatch consumes via extern —
 * symbol still in pipeline_x.o).
 * Requires static forward decls for glue_struct_layout_compute_field_offset_c
 * and glue_struct_layout_index_by_type_name_c (defined later in TU at
 * glue.c:3788/3892, after this #include at glue.c:2172).
 */

/* wave1035 G.7: static forward decls — definitions later in TU (glue.c:3788/3892).
 * wave1044: glue_struct_layout_compute_field_offset_c migrated here (definition
 * at EOF); forward decl retained for callsites at L152/L158.
 * wave1049: glue_struct_layout_index_by_type_name_c migrated here (definition
 * at EOF below); forward decl retained for callsite at L162. */
static int32_t glue_struct_layout_compute_field_offset_c(struct ast_Module *m, struct ast_ASTArena *a, int32_t li,
                                                          int32_t fj);
static int32_t glue_struct_layout_index_by_type_name_c(struct ast_Module *m, uint8_t *struct_name, int32_t nlen);

/* wave1054 G.7: forward decl — glue_type_align_simple is defined at EOF
 * below (migrated from glue.c:2917). Consumed by glue_struct_layout_compute
 * _field_offset_c (L726) + glue_struct_layout_metrics_c (L1040), both
 * before the EOF definition. Mutually recursive with metrics (defined
 * earlier at EOF). glue.c:2787 retains its own fwd decl for callsites
 * in pipeline_struct_layout_next_field_offset_ex + soa.c via #include. */
static int32_t glue_type_align_simple(struct ast_Module *m, struct ast_ASTArena *a, int32_t ty_ref, int32_t depth);

/* wave1051 G.7: forward decl — glue_struct_layout_metrics_c defined at EOF
 * below (wave1053 migrated from glue.c:2794). Consumed by
 * pipeline_expr_struct_lit_value_bytes (L855) + typeck_typeck_struct_layout_metrics
 * public wrapper (EOF) + glue.c:3050 (glue_type_align_simple recursive call)
 * + glue.c:16645/16658/16670 (typeck_validate_* wrappers). */
static int32_t glue_struct_layout_metrics_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t li,
                                            int32_t depth, int32_t check_pad, int32_t *out_sz, int32_t *out_al);

/* wave1053 G.7: forward decl — glue_type_size_simple defined later in TU
 * (glue.c:3064); consumed by glue_struct_layout_metrics_c (EOF). */
static int32_t glue_type_size_simple(struct ast_Module *m, struct ast_ASTArena *a, int32_t ty_ref, int32_t depth);

/* wave1053 G.7: extern decls — driver diagnostics for struct padding checks.
 * Defined in driver glue (extern); visible at glue.c:691 (driver_asm_build_skip_typeck)
 * but padding/trailing/field_bad_size are declared at glue.c:2781-2784 > #include
 * at L2095, so struct_lit.c must declare them locally for metrics body. */
extern void driver_diagnostic_typeck_struct_padding_before(uint8_t *sname, int32_t sname_len, int32_t gap,
                                                           uint8_t *fname, int32_t fname_len);
extern void driver_diagnostic_typeck_struct_padding_trailing(uint8_t *sname, int32_t sname_len, int32_t gap);
extern void driver_diagnostic_typeck_struct_field_bad_size(uint8_t *sname, int32_t sname_len, uint8_t *fname,
                                                           int32_t fname_len);

/* wave1124 G.7: extern fwd decl — pipeline_typeck_type_refs_equal_c is
 * defined at glue.c:7861 (fwd decl at L7782), both after this file's
 * #include at L2051. Required by typeck_struct_layouts_same_shape_c. */
extern int32_t pipeline_typeck_type_refs_equal_c(struct ast_ASTArena *arena, int32_t a, int32_t b);

/* wave1052 G.7: forward decl — glue_sync_struct_layout_field_offsets_c is
 * defined at EOF below (migrated from glue.c:3665). glue.c:11850 callsite
 * retains its own forward decl at glue.c:3655 (same TU; visible via #include
 * at glue.c:2095). Consumed only by glue.c fill_struct_layouts (module
 * layout finalization pass — struct layout registry domain). */
static void glue_sync_struct_layout_field_offsets_c(struct ast_Module *m, struct ast_ASTArena *a);

/**
 * Check whether a TYPE_NAMED refers to an empty struct (ZST).
 *
 * Why: wave366/368 — TYPE_NAMED ZST has layout nf==0, or every field is
 * itself an empty ZST (empty-of-empty nest). Mirrors typeck.x
 * typeck_type_is_empty_struct as the G.7 twin in the glue metrics path.
 * Used by struct_lit field store_sz to skip 0-byte stores for ZST fields
 * (prior default 8 stored a temp pointer into mid Nest/Empty and shifted
 * later field offsets → Ubuntu freestanding nest_mid garbage exit).
 *
 * Contract: returns 1 if ty_ref is a TYPE_NAMED whose struct layout has
 * nf==0 or all fields are themselves empty ZSTs; returns 0 otherwise
 * (including non-TYPE_NAMED, invalid ref, depth > 64). Recursive on
 * field type refs with depth+1.
 *
 * PLATFORM: SHARED — host sizeof Empty / NestEmpty==0; empty-of-empty
 * must not trigger T001. Consumed by struct_lit field store_sz (this
 * file) + residual glue.c layout metrics / call return size paths.
 */
static int32_t glue_type_is_empty_struct_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t ty_ref,
                                          int32_t depth) {
  uint8_t name[128];
  int32_t nlen;
  int32_t k;
  int32_t j;
  int32_t nf;
  int32_t fi;
  int32_t ftr;
  if (!module || !arena || ty_ref <= 0 || ty_ref > arena->num_types || depth > 64)
    return 0;
  if (pipeline_type_kind_ord_at(arena, ty_ref) != GLUE_TYPE_NAMED)
    return 0;
  nlen = pipeline_type_named_name_into(arena, ty_ref, name);
  if (nlen <= 0 || nlen > 127)
    return 0;
  for (k = 0; k < (int32_t)module->num_struct_layouts; k++) {
    int32_t ln = pipeline_module_struct_layout_name_len(module, k);
    int32_t eq = 1;
    if (ln != nlen)
      continue;
    for (j = 0; j < nlen; j++) {
      if (pipeline_module_struct_layout_name_byte_at(module, k, j) != name[j]) {
        eq = 0;
        break;
      }
    }
    if (!eq)
      continue;
    nf = pipeline_module_struct_layout_num_fields(module, k);
    /* wave366: bare empty struct. */
    if (nf == 0)
      return 1;
    /* wave368: all fields empty ZSTs → empty-of-empty nest is also ZST. */
    for (fi = 0; fi < nf; fi++) {
      ftr = pipeline_module_struct_layout_field_type_ref(module, k, fi);
      if (glue_type_is_empty_struct_c(module, arena, ftr, depth + 1) == 0)
        return 0;
    }
    return 1;
  }
  return 0;
}

/**
 * Byte offset of STRUCT_LIT field field_ix within its struct layout.
 *
 * Why: asm emit must store each field at its layout offset (not fi*8) to
 * honour C-compatible padding / mixed-size fields. When the struct name
 * is missing (anonymous single-layout module, e.g. DOD-CL-S1), fall back
 * to the single layout entry directly. When the name is present, look up
 * the layout index by type name, then compute the cumulative offset up
 * to field_ix. Returns field_ix*8 as a safe fallback on any miss.
 *
 * Contract: returns field_ix*8 for invalid arena/module/ref/ix or
 * non-EXPR_STRUCT_LIT; otherwise returns the layout byte offset.
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 */
int32_t pipeline_expr_struct_lit_field_offset_at(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref,
                                                 int32_t field_ix) {
  struct ast_Expr *ex;
  int32_t nlen;
  uint8_t name[128];
  int32_t k;
  if (!a || !m || expr_ref <= 0 || field_ix < 0)
    return field_ix * 8;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex || ex->kind != ast_ExprKind_EXPR_STRUCT_LIT)
    return field_ix * 8;
  nlen = ex->struct_lit_struct_name_len;
  if (nlen <= 0 || nlen > 127) {
    /** Single-layout module fallback when type name is missing (DOD-CL-S1). */
    if (m->num_struct_layouts == 1 && field_ix < pipeline_module_struct_layout_num_fields(m, 0))
      return glue_struct_layout_compute_field_offset_c(m, a, 0, field_ix);
    return field_ix * 8;
  }
  memcpy(name, ex->struct_lit_struct_name, (size_t)nlen);
  k = glue_struct_layout_index_by_type_name_c(m, name, nlen);
  if (k >= 0 && field_ix < pipeline_module_struct_layout_num_fields(m, k))
    return glue_struct_layout_compute_field_offset_c(m, a, k, field_ix);
  return field_ix * 8;
}

/**
 * Type ref of STRUCT_LIT field field_ix within its struct layout.
 *
 * Why: asm emit needs the per-field type ref to select the correct store
 * width / register class (scalar / dual-GP / ZST). Walks module struct
 * layouts by name match; returns 0 on any miss (caller falls back to
 * default 8-byte store).
 *
 * Contract: returns 0 for invalid arena/module/ref/ix, non-EXPR_STRUCT_LIT,
 * missing struct name, or layout not found; otherwise returns the field
 * type_ref from the matched layout.
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 */
int32_t pipeline_expr_struct_lit_field_type_ref_at(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref,
                                                   int32_t field_ix) {
  struct ast_Expr *ex;
  int32_t nlen;
  uint8_t name[128];
  int32_t k;
  if (!a || !m || expr_ref <= 0 || field_ix < 0)
    return 0;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex || ex->kind != ast_ExprKind_EXPR_STRUCT_LIT)
    return 0;
  nlen = ex->struct_lit_struct_name_len;
  if (nlen <= 0 || nlen > 127)
    return 0;
  memcpy(name, ex->struct_lit_struct_name, (size_t)nlen);
  for (k = 0; k < (int32_t)m->num_struct_layouts; k++) {
    int32_t ln;
    int32_t j;
    int32_t eq;
    ln = pipeline_module_struct_layout_name_len(m, k);
    if (ln != nlen)
      continue;
    eq = 1;
    for (j = 0; j < nlen; j++) {
      if (pipeline_module_struct_layout_name_byte_at(m, k, j) != name[j]) {
        eq = 0;
        break;
      }
    }
    if (!eq)
      continue;
    if (field_ix < pipeline_module_struct_layout_num_fields(m, k))
      return pipeline_module_struct_layout_field_type_ref(m, k, field_ix);
    return 0;
  }
  return 0;
}

/**
 * STRUCT_LIT per-field store width (matches glue_field_access_load_bytes_for_type_ref for scalars).
 * wave369 Cap residual pure: empty / empty-of-empty TYPE_NAMED ZST fields store 0 bytes.
 * Prior default 8 stored nested STRUCT_LIT temp pointer into mid Nest/Empty and shifted later
 * field offsets (Ubuntu freestanding nest_mid garbage exit; host-C gcc path OK).
 * PLATFORM: SHARED freestanding · LINUX+MACOS x86_64 SysV dual-GP 9–16B still 16.
 */
static int32_t glue_struct_lit_field_store_sz(struct ast_ASTArena *arena, int32_t expr_ref, int32_t fi) {
  int32_t ty;
  int32_t kind_ord;
  int32_t nsz;
  ty = pipeline_expr_struct_lit_field_type_ref_at(arena, g_pipeline_asm_emit_module, expr_ref, fi);
  if (ty <= 0)
    return 8;
  /* wave369: ZST named field — no store (Empty / Nest { e: Empty }). */
  if (g_pipeline_asm_emit_module && glue_type_is_empty_struct_c(g_pipeline_asm_emit_module, arena, ty, 0) != 0)
    return 0;
  kind_ord = pipeline_type_kind_ord_at(arena, ty);
  if (kind_ord == 2 || kind_ord == 1)
    return 1;
  /** f32(14) 须 4B store；勿 8B mov 覆盖相邻 f32 字段。 */
  if (kind_ord == 0 || kind_ord == 3 || kind_ord == 13 || kind_ord == 14)
    return 4;
  /* SysV INTEGER dual-GP field (Allocator etc.): full 16B, not truncated to 8. */
  nsz = glue_sysv_dual_gp_byte_size_c(arena, ty);
  if (nsz > 8 && nsz <= 16)
    return nsz;
  nsz = glue_type_named_layout_size_any_module_elf_c(arena, ty);
  if (nsz > 8 && nsz <= 16)
    return nsz;
  /* Named layout size 0 that is not classified empty still must not default to 8. */
  nsz = glue_type_size_simple(g_pipeline_asm_emit_module, arena, ty, 0);
  if (nsz == 0)
    return 0;
  if (nsz > 0 && nsz <= 8)
    return nsz;
  return 8;
}

/** X/asm partial 可调用的 STRUCT_LIT 字段 store 宽度（勿在 backend.x 直链 pipeline_type_kind_ord_at）。 */
int32_t pipeline_expr_struct_lit_field_store_sz(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref,
                                                int32_t field_ix) {
  struct ast_Module *prev;
  int32_t sz;
  prev = g_pipeline_asm_emit_module;
  g_pipeline_asm_emit_module = m;
  sz = glue_struct_lit_field_store_sz(a, expr_ref, field_ix);
  g_pipeline_asm_emit_module = prev;
  return sz;
}

/** struct_lit 逐字段 emit 上限（与 grow 池 many_fields 等边界用例对齐，旧硬顶 8）。 */
#define GLUE_ASM_MAX_STRUCT_LIT_FIELDS 64
/**
 * wave628: stack_slot_off sentinel — caller already placed element/dest address in rbx
 * (e.g. INDEX assign with runtime index). Field stores use sret_direct geometry
 * (store_rax_to_rbx_offset) without lea rbp / next_offset materialize.
 * PLATFORM: SHARED freestanding INDEX STRUCT_LIT assign.
 */
#define GLUE_STRUCT_LIT_DEST_IN_RBX (-3)
/**
 * wave629: rehome_off sentinel — dest pointer lives on the CPU stack (push rbx at
 * DEST_IN_RBX entry), not at a frame magnitude. Frame next_offset spill can alias
 * later locals (TYPE_SLICE durable + i/j: first spill overwrote j → bounds panic 0).
 */
#define GLUE_STRUCT_LIT_REHOME_CPU_STACK (-4)
/**
 * Re-home dest address into rbx for sret_direct / DEST_IN_RBX field stores.
 * rehome_off >= 0 → load from rbp magnitude; REHOME_CPU_STACK → pop dest then
 * push it back (caller must have value already popped from stack, or value not
 * yet pushed — see call sites).
 * @return 0 ok, -1 fail
 */
static int32_t glue_struct_lit_rehome_dest_rbx_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t rehome_off,
                                                      int32_t ta) {
  if (rehome_off == GLUE_STRUCT_LIT_REHOME_CPU_STACK) {
    if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_push_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    return 0;
  }
  if (rehome_off < 0)
    return -1;
  return backend_enc_load_rbp_to_rbx_arch(elf_ctx, rehome_off, ta);
}
static int32_t pipeline_asm_emit_struct_lit_fields_elf_c(struct ast_ASTArena *arena,
                                                         struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref,
                                                         struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                         int32_t stack_slot_off) {
  int32_t nf;
  int32_t fi;
  int32_t base_off;
  int32_t init_ref;
  int32_t foff;
  int32_t fsz;
  int32_t sret_direct;
  int32_t dest_ptr_home;
  int32_t rehome_off;
  int32_t dest_on_cpu_stack;
  pipeline_glue_AsmFuncCtxLayout *ly;
  nf = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
  sret_direct = 0;
  dest_ptr_home = -1;
  dest_on_cpu_stack = 0;
  ly = pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return -1;
  if (link_abi_getenv("XLANG_ASM_EMIT_TRACE"))
    fprintf(stderr, "xlang: struct_lit_c expr=%d nf=%d slot_off=%d temp_off=%d\n", (int)expr_ref, (int)nf,
            (int)stack_slot_off, (int)ly->next_offset);
  /**
   * wave366 Cap residual pure: empty struct lit `Empty {}` has nf==0 (ZST).
   * Prior `nf <= 0` → -1 → freestanding CG002 (code_len tiny / no main).
   * G.7: materialize base address (lea/sret) with zero field stores — host C emits
   * `{}` for empty; sizeof remains 0. PLATFORM: SHARED freestanding + host layout.
   */
  if (nf < 0 || nf > GLUE_ASM_MAX_STRUCT_LIT_FIELDS)
    return -1;
  /**
   * return + sret: rbx points at caller hidden dest ([sret_home]), not a small
   * rbp+next_offset temp (field offsets can overrun saved fp → SIGSEGV).
   * PLATFORM: LINUX+MACOS x86_64 SysV · MACOS|ARM64 AAPCS64 (wave591).
   *
   * wave628/629: GLUE_STRUCT_LIT_DEST_IN_RBX — dest already in rbx (INDEX
   * elem home). Field-value emits clobber rbx, so spill dest:
   *   wave628 used ly->next_offset frame slot — aliases locals when next_offset
   *   sits on i/j (TYPE_SLICE durable + two var-index assigns → Ubuntu panic:0).
   *   wave629: push rbx on the CPU stack; re-home via pop/push (no frame alias).
   * Do NOT reload g_pipeline_asm_sret_home_off (unset → garbage / smash).
   */
  base_off = 0;
  if (stack_slot_off == GLUE_STRUCT_LIT_DEST_IN_RBX) {
    sret_direct = 1;
    dest_on_cpu_stack = 1;
    dest_ptr_home = GLUE_STRUCT_LIT_REHOME_CPU_STACK;
    if (backend_enc_push_rbx_arch(elf_ctx, ta) != 0)
      return -1;
  } else if (stack_slot_off < 0 && (ta == 0 || ta == 1) && g_pipeline_asm_func_sret_active &&
             g_pipeline_asm_sret_home_off >= 0) {
    if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, g_pipeline_asm_sret_home_off, ta) != 0)
      return -1;
    sret_direct = 1;
  } else {
    base_off = stack_slot_off >= 0 ? stack_slot_off : ly->next_offset;
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, base_off, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
  }
  /* sret_home / dest-ptr frame spill / CPU-stack dest — unified re-home. */
  if (dest_on_cpu_stack)
    rehome_off = GLUE_STRUCT_LIT_REHOME_CPU_STACK;
  else
    rehome_off = dest_ptr_home >= 0 ? dest_ptr_home : g_pipeline_asm_sret_home_off;
  if (nf == 0) {
    if (dest_on_cpu_stack && backend_enc_pop_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    return 0;
  }
  for (fi = 0; fi < nf; fi++) {
    init_ref = pipeline_expr_struct_lit_init_ref(arena, expr_ref, fi);
    if (link_abi_getenv("XLANG_ASM_EMIT_TRACE"))
      fprintf(stderr, "xlang: struct_lit_c fi=%d init_ref=%d ko=%d\n", (int)fi, (int)init_ref,
              (int)(init_ref > 0 ? pipeline_expr_kind_ord_at(arena, init_ref) : -1));
    if (init_ref != 0) {
      int32_t fty;
      int32_t arr_st;
      foff = pipeline_expr_struct_lit_field_offset_at(arena, g_pipeline_asm_emit_module, expr_ref, fi);
      fsz = glue_struct_lit_field_store_sz(arena, expr_ref, fi);
      fty = pipeline_expr_struct_lit_field_type_ref_at(arena, g_pipeline_asm_emit_module, expr_ref, fi);
      /*
       * wave369 Cap residual pure: empty / empty-of-empty ZST field — no payload store.
       * Nested `Nest { e: Empty {} }` as mid field must not write a temp pointer at foff
       * (that was store_sz default 8). Skip emit+store; parent layout keeps fsize 0.
       * PLATFORM: SHARED freestanding · LINUX gold.
       */
      if (fsz == 0 || (fty > 0 && g_pipeline_asm_emit_module &&
                       glue_type_is_empty_struct_c(g_pipeline_asm_emit_module, arena, fty, 0) != 0))
        continue;
      /*
       * wave349 Cap residual pure: fixed TYPE_ARRAY field must store inline payload.
       * Generic emit_array_lit → rax=temp-ptr then store 8B overwrites field[0..7] with a
       * pointer; Ubuntu freestanding b.a[i] / field→slice then reads garbage (host-C OK).
       * G.7: glue_struct_lit_store_fixed_array_field_elf_c reuses vector_let_init / wave334.
       * PLATFORM: SHARED freestanding · LINUX gold.
       */
      if (fty > 0 && pipeline_type_kind_ord_at(arena, fty) == (int32_t)ast_TypeKind_TYPE_ARRAY) {
        arr_st = glue_struct_lit_store_fixed_array_field_elf_c(arena, elf_ctx, init_ref, ctx, ta, sret_direct,
                                                              base_off, foff, fty);
        if (arr_st == 0)
          continue;
        if (arr_st == -1)
          return -1;
        /* arr_st == -2: unsupported init form → fall through to generic store */
      }
      /*
       * wave595 Cap residual pure: nested STRUCT_LIT field must materialize in-place
       * at the parent field's frame home (or sret dest+foff via temp copy).
       *
       * Root: prior path emitted nested lit via emit_expr_elf_rec with slot_off=-1,
       * which reused ly->next_offset (== parent base). Nested field stores overwrote
       * earlier parent fields; then 9–16B dual-GP store of the nested *value* always
       * wrote 16B at foff (even when fsz=12) → past Outer end → stack smash / SIGSEGV
       * (Ubuntu pure-asm nest3); arm64 also returned a stack pointer for 9–16B Outer
       * (dual-GP return was ta==0 only) → wrong field loads.
       *
       * Frame home of nested field is arch-aware (G.8):
       *   PLATFORM: MACOS|ARM64 low-end — lea [x29,#base]; field@base+foff
       *   PLATFORM: LINUX|x86 high-end — lea -base(%rbp) is byte0; field@byte0+foff
       *     is frame magnitude base-foff (not base+foff: that places nest *below*
       *     Outer and clobbers a when nested writes +foff upward).
       *
       * G.7: same authority as let_init stack_slot_off path — nested STRUCT_LIT writes
       * fields at the destination address; no dual-GP value round-trip for the nest.
       * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 co-path.
       */
      if (pipeline_expr_kind_ord_at(arena, init_ref) == 45) {
        if (!sret_direct) {
          int32_t nest_slot;
          /* wave652: G.7 single polarity helper (≡ fixed array field dest). */
          nest_slot = glue_struct_field_frame_mag_c(base_off, foff, ta);
          if (nest_slot < 0)
            return -1;
          if (pipeline_asm_emit_struct_lit_fields_elf_c(arena, elf_ctx, init_ref, ctx, ta,
                                                         nest_slot) != 0)
            return -1;
          continue;
        }
        /*
         * sret_direct: dest is *[sret_home]; emit nest to frame temp then copy fsz.
         *
         * wave597 Cap residual pure: x86 high-end nest temp polarity.
         * Root: nest_off = next_offset then load_rbp(nest_off+cop) + nest fields via
         * lea(-nest_off)+foff. On x86, lea -nest(%rbp) is byte0 and +foff grows toward
         * rbp (lower magnitudes) — Mid2 fsz=16 at nest=24 writes [rbp-24..rbp-8) and
         * clobbers sret_home@16; copy of cop=8 loaded [rbp-32] (uninit) not [rbp-16].
         * Ubuntu pure-asm nest4/ptr_nest_call SIGSEGV; arm64 low-end (byte0 grows +off)
         * stayed green. G.7: same frame geometry as non-sret nest_slot (base-foff).
         * PLATFORM: LINUX|x86 high-end · MACOS|ARM64 low-end (unchanged +cop).
         */
        {
          int32_t nest_off;
          int32_t nest_alloc;
          int32_t cop;
          int32_t chunk;
          int32_t load_off;
          nest_off = ly->next_offset;
          if ((nest_off % 8) != 0)
            nest_off = (nest_off + 7) / 8 * 8;
          nest_alloc = (fsz + 7) & ~7;
          if (nest_alloc < 8)
            nest_alloc = 8;
          if (ta == 1) {
            /* PLATFORM: MACOS|ARM64 low-end — byte0 @ nest_off, grows +foff. */
            ly->next_offset = nest_off + nest_alloc;
          } else {
            /*
             * PLATFORM: LINUX|x86 (and macOS x86) high-end — byte0 @ nest_off via
             * lea -nest(%rbp); field@+foff uses magnitudes nest_off down through
             * nest_off-fsz+1. Lift base by nest_alloc so the range sits above prior
             * slots (sret_home lives at a smaller magnitude).
             */
            nest_off = nest_off + nest_alloc;
            ly->next_offset = nest_off;
          }
          if (pipeline_asm_emit_struct_lit_fields_elf_c(arena, elf_ctx, init_ref, ctx, ta, nest_off) !=
              0)
            return -1;
          cop = 0;
          while (cop < fsz) {
            chunk = (fsz - cop >= 8) ? 8 : ((fsz - cop >= 4) ? 4 : 1);
            /* x86 high-end: byte cop is at magnitude nest_off - cop; arm64: nest_off + cop. */
            load_off = (ta == 1) ? (nest_off + cop) : (nest_off - cop);
            if (load_off < 0)
              return -1;
            if (backend_enc_load_rbp_to_rax_arch(elf_ctx, load_off, ta) != 0)
              return -1;
            /* wave628/629: rehome_off is dest_ptr frame / sret_home / CPU stack. */
            if (glue_struct_lit_rehome_dest_rbx_elf_c(elf_ctx, rehome_off, ta) != 0)
              return -1;
            if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, foff + cop, chunk, ta) != 0)
              return -1;
            cop += chunk;
          }
          continue;
        }
      }
      /** f32 字段 + 浮点字面量：imm32 位型（skip typeck 时常无 resolved_type）。 */
      if (pipeline_expr_kind_ord_at(arena, init_ref) == 1 && fty > 0 &&
          pipeline_type_kind_ord_at(arena, fty) == 14) {
        if (glue_emit_float_lit_to_rax_elf_c(arena, elf_ctx, init_ref, ta, fty, 0) != 0)
          return -1;
      } else if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, init_ref, ctx, ta) != 0) {
        return -1;
      }
      /**
       * 【Why】递归 emit（嵌套 struct_lit / binop）会 clobber rbx 为子 temp 区基址；
       *        不重载则 store 写入子 temp 区而非父栈槽，字段值丢失。
       * 【Invariant】rax（+rdx for 9–16B SysV）含字段值；spill 到 frame 后再重载 rbx。
       * PLATFORM: LINUX+MACOS x86_64 — dual-GP CALL/VAR field init must keep rdx half.
       * wave595: clamp dual store to fsz (not always 16) so 9–12B fields do not smash.
       * wave628/629: sret_direct re-home uses rehome_off (frame spill / sret / CPU stack).
       */
      if (ta == 0 && fsz > 8 && fsz <= 16) {
        int32_t spill = ly->next_offset + 16;
        int32_t high_sz;
        if (spill < 16)
          spill = 16;
        if (backend_enc_store_rax_to_rbp_arch(elf_ctx, spill, ta) != 0)
          return -1;
        if (backend_enc_store_rdx_to_rbp_arch(elf_ctx, spill - 8, ta) != 0)
          return -1;
        if (sret_direct) {
          if (glue_struct_lit_rehome_dest_rbx_elf_c(elf_ctx, rehome_off, ta) != 0)
            return -1;
        } else {
          if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, base_off, ta) != 0)
            return -1;
          if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
            return -1;
        }
        if (backend_enc_load_rbp_to_rax_arch(elf_ctx, spill, ta) != 0)
          return -1;
        if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, foff, 8, ta) != 0)
          return -1;
        high_sz = fsz - 8;
        if (high_sz > 0) {
          if (high_sz > 8)
            high_sz = 8;
          if (backend_enc_load_rbp_to_rax_arch(elf_ctx, spill - 8, ta) != 0)
            return -1;
          if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, foff + 8, high_sz, ta) != 0)
            return -1;
        }
      } else if (dest_on_cpu_stack) {
        /*
         * wave629: dest on CPU stack (entry push); value in rax after emit.
         * pop dest → rbx, push dest back, store [rbx+foff]=rax.
         * (Cannot rehome via helper after push value — would pop value as dest.)
         */
        if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0)
          return -1;
        if (backend_enc_push_rbx_arch(elf_ctx, ta) != 0)
          return -1;
        if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, foff, fsz, ta) != 0)
          return -1;
      } else {
        if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
          return -1;
        if (sret_direct) {
          if (glue_struct_lit_rehome_dest_rbx_elf_c(elf_ctx, rehome_off, ta) != 0)
            return -1;
        } else {
          if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, base_off, ta) != 0)
            return -1;
          if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
            return -1;
        }
        if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
          return -1;
        if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, foff, fsz, ta) != 0)
          return -1;
      }
    }
  }
  if (link_abi_getenv("XLANG_ASM_EMIT_TRACE"))
    fprintf(stderr, "xlang: struct_lit_c done expr=%d\n", (int)expr_ref);
  /* let-init home or wave628/629 INDEX dest-in-rbx: fields already stored; no rvalue. */
  if (stack_slot_off >= 0 || stack_slot_off == GLUE_STRUCT_LIT_DEST_IN_RBX) {
    if (dest_on_cpu_stack && backend_enc_pop_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    return 0;
  }
  /**
   * return 路径：小 struct（≤8B）按值经 rax 返回（mov rbx→rax 再 load [rax]）；
   * 勿 mov rbx→rax 单独返回栈地址（跨模块 call 后悬空）。
   *
   * wave595: nested in-place leaves rbx on the last nested field home — re-home
   * to this lit's base_off before by-value load (x86 load_qword_from_rbx* and
   * ≤8 mov_rbx_to_rax both require rbx = Outer byte0).
   */
  if (!sret_direct) {
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, base_off, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
  }
  {
    int32_t vb;
    vb = pipeline_expr_struct_lit_value_bytes(arena, g_pipeline_asm_emit_module, expr_ref);
    if (vb > 0 && vb <= 8) {
      if (backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (vb == 8)
        return backend_enc_load_64_from_rax_arch(elf_ctx, ta);
      if (vb == 4)
        return backend_enc_load_32_from_rax_arch(elf_ctx, ta);
    }
    /**
     * 9–16B dual-GP by value — do not return a stack pointer.
     * PLATFORM: LINUX+MACOS x86_64 SysV — rax + rdx from [rbx]/[rbx+8]
     *   after re-home above.
     * PLATFORM: MACOS|ARM64 AAPCS64 (wave595) — x0 + x1 from frame home
     *   (base_off). load_qword_* is x86-only; arm64 rbx==x1 would clobber the
     *   second return reg if we loaded half2 from [x1+8] after moving base.
     *   Frame loads: x0=[home], x1=[home+8] via load_rbp_to_rax/rbx.
     */
    if (vb > 8 && vb <= 16) {
      if (ta == 0) {
        if (backend_enc_load_qword_from_rbx_to_rax_arch(elf_ctx, ta) != 0)
          return -1;
        if (backend_enc_load_qword_rbx8_to_rdx_arch(elf_ctx, ta) != 0)
          return -1;
        return 0;
      }
      if (ta == 1) {
        if (backend_enc_load_rbp_to_rax_arch(elf_ctx, base_off, ta) != 0)
          return -1;
        if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, base_off + 8, ta) != 0)
          return -1;
        return 0;
      }
    }
    /**
     * >16B sret: already wrote caller dest, or memcpy from stack temp.
     * PLATFORM: LINUX+MACOS x86_64 SysV · MACOS|ARM64 AAPCS64 (wave591).
     */
    if (vb > 16 && (ta == 0 || ta == 1) && sret_direct)
      return 0;
    if (vb > 16 && (ta == 0 || ta == 1) && g_pipeline_asm_func_sret_active)
      return glue_emit_sret_memcpy_rbx_to_home_elf_c(elf_ctx, vb, ta);
  }
  return backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta);
}

/**
 * EXPR_STRUCT_LIT：temp 区逐字段 emit（字段 init 走 rec 快速路径，含枚举 FIELD_ACCESS）。
 */
int32_t pipeline_asm_emit_struct_lit_elf_c(struct ast_ASTArena *arena,
                                                  struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref,
                                                  struct backend_AsmFuncCtx *ctx, int32_t ta) {
  return pipeline_asm_emit_struct_lit_fields_elf_c(arena, elf_ctx, expr_ref, ctx, ta, -1);
}

/**
 * Compute the byte offset of field index fj within struct layout li.
 *
 * Why: §11.1 + field_align(N) dynamic layout — the authoritative offset
 * must account for per-field alignment (not just fj*8). Used by struct_lit
 * field store offset (L152/L158) and glue.c layout sync/metrics (L3759/
 * 3772/3774/3804, after #include 2092 — visible via forward decl at top
 * of this file).
 *
 * Invariant: li >= 0 && li < module->num_struct_layouts && fj >= 0 &&
 * fj < nf. Returns fj*8 fallback when layout/field not found.
 *
 * Asm/Perf: single forward pass over fields [0..fj] accumulating offset
 * with alignment gap; O(fj) per call, bounded by struct field count.
 *
 * PLATFORM: SHARED — pure layout computation, arch-agnostic.
 */
static int32_t glue_struct_layout_compute_field_offset_c(struct ast_Module *m, struct ast_ASTArena *a, int32_t li,
                                                       int32_t fj) {
  int32_t current;
  int32_t j;
  int32_t nf;
  if (!m || !a || li < 0 || li >= pipeline_module_num_struct_layouts_at(m) || fj < 0)
    return fj >= 0 ? fj * 8 : 0;
  nf = pipeline_module_struct_layout_num_fields(m, li);
  if (fj >= nf)
    return fj * 8;
  current = 0;
  for (j = 0; j <= fj; j++) {
    int32_t ftr = pipeline_module_struct_layout_field_type_ref(m, li, j);
    int32_t A = glue_type_align_simple(m, a, ftr, 0);
    int32_t fa;
    int32_t rem;
    int32_t gap;
    int32_t fsize;
    if (A <= 0)
      A = 1;
    fa = pipeline_module_struct_layout_field_align_at(m, li, j);
    if (fa > A)
      A = fa;
    rem = current % A;
    gap = A - rem;
    gap = gap % A;
    if (j == fj)
      return current + gap;
    current = current + gap;
    fsize = glue_type_size_simple(m, a, ftr, 0);
    /* wave366/368: keep 0 for empty / empty-of-empty ZST; unknown size -> 4. */
    if (fsize < 0 || (fsize == 0 && glue_type_is_empty_struct_c(m, a, ftr, 0) == 0))
      fsize = 4;
    current = current + fsize;
  }
  return fj * 8;
}

/* wave1049 G.7 fold: glue_struct_layout_index_by_type_name_c migrated here
 * from pipeline_glue.c (definition was at glue.c:3727). Same-TU #include at
 * glue.c:2095 makes it visible to field_access.c:830/882 (field_access.c
 * #include at L2419 > struct_lit.c L2095). struct_lit.c:59 fwd decl retained
 * for struct_lit.c:162 callsite (definition at EOF below). glue.c has zero
 * self-callsites — pure leaf consumed by struct_lit + field_access. */

/**
 * Look up struct layout index by type name (single-layout fallback to 0).
 *
 * Why: §11.1 struct layout registry — the authoritative name→index lookup
 * consumed by struct_lit field offset (L162, via glue_struct_layout_compute
 * _field_offset_c above) and field_access effective offset (field_access.c
 * L830/882, via glue_field_access_effective_offset_c). Returns 0 for the
 * single-layout module fallback (DOD-CL-S1 anonymous struct) so callers do
 * not need to special-case missing type names.
 *
 * Invariant: returns -1 for invalid module/name/nlen (nlen > 127) or when
 * no layout matches; returns the first matching layout index k otherwise;
 * returns 0 when the module has exactly one layout (single-layout fallback).
 *
 * Asm/Perf: O(nlayouts * nlen) — linear scan over layouts with byte-by-byte
 * name comparison. Bounded by module struct count (typically small).
 *
 * PLATFORM: SHARED — pure layout registry query; arch-agnostic.
 */
static int32_t glue_struct_layout_index_by_type_name_c(struct ast_Module *m, uint8_t *struct_name, int32_t nlen) {
  int32_t k;
  int32_t j;
  if (!m || !struct_name || nlen <= 0 || nlen > 127)
    return -1;
  for (k = 0; k < (int32_t)m->num_struct_layouts; k++) {
    int32_t ln = pipeline_module_struct_layout_name_len(m, k);
    int32_t eq = 1;
    if (ln != nlen)
      continue;
    for (j = 0; j < nlen; j++) {
      if (pipeline_module_struct_layout_name_byte_at(m, k, j) != struct_name[j]) {
        eq = 0;
        break;
      }
    }
    if (eq)
      return k;
  }
  /* Single-layout module fallback (DOD-CL-S1 anonymous struct). */
  if (m->num_struct_layouts == 1)
    return 0;
  return -1;
}

/* wave1051 G.7 fold: pipeline_expr_struct_lit_value_bytes migrated here from
 * pipeline_glue.c (definition was at glue.c:3777). Public (non-static) —
 * glue.c:1693 forward decl retained (public symbol declaration). Consumed by
 * struct_lit.c:612 (this leaf) + field_access.c:330 (field_access.c #include
 * at glue.c:2419 > struct_lit.c L2095, so definition is visible there). glue.c
 * has zero self-callsites — pure leaf consumed by struct_lit + field_access.
 *
 * glue_struct_layout_metrics_c (called by the body) is defined in glue.c:2794
 * (static; forward decl at L69 above — struct_lit.c #include at L2095 < 2794,
 * so the forward decl is needed for visibility). */

/**
 * Compute the byte size of an EXPR_STRUCT_LIT value based on the module's
 * struct layouts. Used by asm to pass small structs by value via x0 (<=8).
 * Returns 0 when no layout matches, letting the backend fall back to
 * pointer semantics.
 *
 * Why: §11.1 struct layout registry — the authoritative STRUCT_LIT total
 * size lookup consumed by struct_lit emit (L612, for ≤8B by-value return
 * via sret_direct) and field_access CALL-arg (field_access.c:330, for
 * MEMORY class >16B pass-by-addr gate). Walks module struct layouts by
 * name match; on match delegates to glue_struct_layout_metrics_c for the
 * cumulative size + alignment computation (handles packed / nested /
 * mixed-size fields). Returns 0 on any miss so callers fall back to
 * pointer semantics.
 *
 * Invariant: returns 0 for invalid arena/module/ref or non-EXPR_STRUCT_LIT;
 * returns 0 when struct name is missing/oversized or no layout matches;
 * otherwise returns the layout's total byte size (>=0).
 *
 * Asm/Perf: O(nlayouts * nlen) — linear scan over layouts with byte-by-byte
 * name comparison, plus one glue_struct_layout_metrics_c call on match.
 * Bounded by module struct count (typically small).
 *
 * PLATFORM: SHARED — pure layout registry query; arch-agnostic.
 */
int32_t pipeline_expr_struct_lit_value_bytes(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref) {
  struct ast_Expr *ex;
  int32_t nlen;
  uint8_t name[128];
  int32_t k;
  int32_t sz_out;
  int32_t al_out;
  if (!a || !m || expr_ref <= 0)
    return 0;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex || ex->kind != ast_ExprKind_EXPR_STRUCT_LIT)
    return 0;
  nlen = ex->struct_lit_struct_name_len;
  if (nlen <= 0 || nlen > 127)
    return 0;
  memcpy(name, ex->struct_lit_struct_name, (size_t)nlen);
  for (k = 0; k < (int32_t)m->num_struct_layouts; k++) {
    int32_t ln;
    int32_t j;
    int32_t eq;
    ln = pipeline_module_struct_layout_name_len(m, k);
    if (ln != nlen)
      continue;
    eq = 1;
    for (j = 0; j < nlen; j++) {
      if (pipeline_module_struct_layout_name_byte_at(m, k, j) != name[j]) {
        eq = 0;
        break;
      }
    }
    if (!eq)
      continue;
    sz_out = 0;
    al_out = 1;
    if (glue_struct_layout_metrics_c(m, a, k, 0, 0, &sz_out, &al_out) != 0)
      return 0;
    return sz_out > 0 ? sz_out : 0;
  }
  return 0;
}

/* wave1052 G.7 fold: glue_sync_struct_layout_field_offsets_c migrated here
 * from pipeline_glue.c (definition was at glue.c:3665). glue.c:11850 callsite
 * (fill_struct_layouts) needs the function — forward decl at glue.c:3655
 * retained (or use the one at struct_lit.c:77 via same-TU #include at
 * glue.c:2095). glue.c has 1 callsite (L11850) — non-leaf but struct layout
 * registry domain; migrating colocates with glue_struct_layout_compute_field
 * _offset_c (wave1044) + pipeline_expr_struct_lit_value_bytes (wave1051).
 *
 * glue_struct_layout_compute_field_offset_c (called by the body) is defined
 * earlier in this file (wave1044 fold). link_abi_getenv / fprintf / memset
 * already used by struct_lit.c (L335-336/389-390/593-594). */

/**
 * Sync each module struct layout's field_offset entries to the result of
 * glue_struct_layout_compute_field_offset_c. Called before asm emit when
 * .x typeck is skipped, so that align(64) and other field offsets are
 * materialized (DOD-CL-S1).
 *
 * Why: §11.1 struct layout registry — module struct layouts store per-field
 * offsets that must match the cumulative §11.1 alignment computation. When
 * the .x typeck pass is skipped (asm-only path), the offsets are not yet
 * materialized; this function walks all layouts and writes the computed
 * offset back via pipeline_module_struct_layout_set_field_offset. The debug
 * branch logs layout0's first two fields when XLANG_ASM_DEBUG is set.
 *
 * Invariant: no-op for invalid module/arena; otherwise iterates all layouts
 * and all fields, writing computed offsets. Debug log is gated on env var
 * and only for layout index 0.
 *
 * Asm/Perf: O(nlayouts * nf) — linear scan over layouts and fields, each
 * field invokes glue_struct_layout_compute_field_offset_c (O(nf) cumulative
 * offset walk). Bounded by module struct count (typically small).
 *
 * PLATFORM: SHARED — pure layout registry sync; arch-agnostic.
 */
static void glue_sync_struct_layout_field_offsets_c(struct ast_Module *m, struct ast_ASTArena *a) {
  int32_t li;
  int32_t nf;
  int32_t j;
  if (!m || !a)
    return;
  for (li = 0; li < pipeline_module_num_struct_layouts_at(m); li++) {
    nf = pipeline_module_struct_layout_num_fields(m, li);
    for (j = 0; j < nf; j++) {
      int32_t off = glue_struct_layout_compute_field_offset_c(m, a, li, j);
      pipeline_module_struct_layout_set_field_offset(m, li, j, off);
    }
    if (link_abi_getenv("XLANG_ASM_DEBUG") && li == 0) {
      uint8_t fn0[128];
      uint8_t fn1[128];
      memset(fn0, 0, sizeof(fn0));
      memset(fn1, 0, sizeof(fn1));
      if (nf > 0)
        pipeline_module_struct_layout_field_name_into(m, li, 0, fn0);
      if (nf > 1)
        pipeline_module_struct_layout_field_name_into(m, li, 1, fn1);
      fprintf(stderr, "xlang: layout0 nf=%d f0=%.4s off0=%d fa0=%d f1=%.4s off1=%d fa1=%d\n", (int)nf, fn0,
              (int)glue_struct_layout_compute_field_offset_c(m, a, li, 0),
              (int)pipeline_module_struct_layout_field_align_at(m, li, 0), fn1,
              nf > 1 ? (int)glue_struct_layout_compute_field_offset_c(m, a, li, 1) : -1,
              nf > 1 ? (int)pipeline_module_struct_layout_field_align_at(m, li, 1) : -1);
    }
  }
}

/* wave1053 G.7 fold: glue_struct_layout_metrics_c migrated here from
 * pipeline_glue.c (definition was at glue.c:2794). Struct layout registry
 * domain — computes total size + alignment for a layout index, colocated
 * with wave1044 (compute_field_offset) + wave1049 (index_by_type_name) +
 * wave1051 (value_bytes) + wave1052 (sync_field_offsets).
 *
 * glue_struct_layout_metrics_c is mutually recursive with glue_type_align_simple
 * (glue.c:3006) — metrics calls align for per-field alignment, align calls
 * metrics for nested TYPE_NAMED struct alignment at depth+1. Both static
 * fwd decls at top of this file (L65/L72); definitions are split across
 * struct_lit.c (metrics) and glue.c (align) but same TU via #include.
 *
 * Public wrapper typeck_typeck_struct_layout_metrics (below) also migrated —
 * thin delegate; extern-called by ast_pool.c:8151 (same pipeline_x.o symbol).
 * glue.c:16645/16658/16670 callsites (typeck_validate_* wrappers) see the
 * definition via same-TU #include at glue.c:2095. */

/**
 * Compute struct layout total size and alignment (C twin of typeck.x
 * typeck_struct_layout_metrics).
 *
 * Why: asm stack-slot width / frame_size hot path uses this C implementation
 * to avoid the gen2 self-hosted X typeck_struct_layout_metrics being
 * pathologically slow on Stage2 (hang). Walks each field, accumulates size
 * with alignment padding, and optionally reports padding violations via
 * driver diagnostics. Packed layouts skip implicit padding (align=1).
 *
 * Invariant: returns -1 on invalid inputs (null module/arena/out pointers,
 * li out of range, depth > 64); otherwise writes *out_sz / *out_al and
 * returns 0. Empty / empty-of-empty ZST fields (size 0) are valid
 * (wave366/368) — not treated as unknown. check_pad=0 path silently fails
 * on bad field size to avoid million-line spam on Token literals (harness
 * TIMEOUT); check_pad=1 path reports via driver diagnostics.
 *
 * Asm/Perf: O(nf) — linear scan over layout fields; each field invokes
 * glue_type_size_simple + glue_type_align_simple (which may recurse on
 * nested TYPE_NAMED via glue_struct_layout_metrics_c at depth+1). Bounded
 * by depth limit 64. Hot path — called from asm emit frame sizing and
 * typeck validation.
 *
 * PLATFORM: SHARED — pure layout computation; arch-agnostic.
 */
static int32_t glue_struct_layout_metrics_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t li,
                                            int32_t depth, int32_t check_pad, int32_t *out_sz, int32_t *out_al) {
  int32_t nf;
  int32_t allow;
  int32_t layout_nlen;
  int32_t current;
  int32_t max_align;
  int32_t j;
  uint8_t layout_nm[128];
  uint8_t field_nm[128];
  if (!module || !arena || !out_sz || !out_al)
    return -1;
  if (li < 0 || li >= pipeline_module_num_struct_layouts_at(module) || depth > 64)
    return -1;
  nf = pipeline_module_struct_layout_num_fields(module, li);
  allow = pipeline_module_struct_layout_allow_padding_at(module, li);
  layout_nlen = pipeline_module_struct_layout_name_len(module, li);
  pipeline_module_struct_layout_name_into(module, li, layout_nm);
  current = 0;
  max_align = 1;
  /** packed: no implicit padding, struct align=1 (matches typeck.x typeck_struct_layout_metrics). */
  if (pipeline_module_struct_layout_packed_at(module, li)) {
    for (j = 0; j < nf; j++) {
      int32_t ftr;
      int32_t flen;
      int32_t fsize;
      ftr = pipeline_module_struct_layout_field_type_ref(module, li, j);
      pipeline_module_struct_layout_field_name_into(module, li, j, field_nm);
      flen = pipeline_module_struct_layout_field_name_len(module, li, j);
      fsize = glue_type_size_simple(module, arena, ftr, depth);
      /* wave366/368: fsize==0 OK for empty / empty-of-empty nested ZST. */
      if (fsize < 0 || (fsize == 0 && glue_type_is_empty_struct_c(module, arena, ftr, depth) == 0)) {
        if (driver_asm_build_skip_typeck() == 0 && check_pad != 0)
          driver_diagnostic_typeck_struct_field_bad_size(layout_nm, layout_nlen, field_nm, flen);
        return -1;
      }
      current = current + fsize;
    }
    *out_sz = current;
    *out_al = 1;
    return 0;
  }
  for (j = 0; j < nf; j++) {
    int32_t ftr;
    int32_t flen;
    int32_t A;
    int32_t rem;
    int32_t gap;
    int32_t fsize;
    ftr = pipeline_module_struct_layout_field_type_ref(module, li, j);
    pipeline_module_struct_layout_field_name_into(module, li, j, field_nm);
    flen = pipeline_module_struct_layout_field_name_len(module, li, j);
    {
      int32_t fa = pipeline_module_struct_layout_field_align_at(module, li, j);
      A = glue_type_align_simple(module, arena, ftr, depth);
      if (A <= 0)
        A = 1;
      if (fa > A)
        A = fa;
    }
    rem = current % A;
    gap = A - rem;
    gap = gap % A;
    if (check_pad != 0 && gap > 0 && allow == 0) {
      driver_diagnostic_typeck_struct_padding_before(layout_nm, layout_nlen, gap, field_nm, flen);
      return -1;
    }
    current = current + gap;
    fsize = glue_type_size_simple(module, arena, ftr, depth);
    if (fsize < 0 || (fsize == 0 && glue_type_is_empty_struct_c(module, arena, ftr, depth) == 0)) {
      /**
       * check_pad!=0: zero-padding validation path reports bad field size.
       * check_pad==0: size query silently fails (avoid million-line spam on
       * every Token literal -> harness TIMEOUT).
       * wave366: empty named field size 0 is valid — do not treat as unknown.
       */
      if (check_pad != 0 && driver_asm_build_skip_typeck() == 0)
        driver_diagnostic_typeck_struct_field_bad_size(layout_nm, layout_nlen, field_nm, flen);
      return -1;
    }
    current = current + fsize;
    if (A > max_align)
      max_align = A;
  }
  if (max_align > 0 && (current % max_align) != 0) {
    int32_t end_pad = max_align - (current % max_align);
    if (check_pad != 0 && end_pad > 0 && allow == 0) {
      driver_diagnostic_typeck_struct_padding_trailing(layout_nm, layout_nlen, end_pad);
      return -1;
    }
    current = current + end_pad;
  }
  *out_sz = current;
  *out_al = max_align > 0 ? max_align : 1;
  return 0;
}

/**
 * typeck.x / asm glue unified entry: delegates to C metrics.
 * Do NOT call gen2 self-hosted X typeck_struct_layout_metrics (Stage2 hang).
 *
 * PLATFORM: SHARED — public symbol; extern-called by ast_pool.c:8151.
 */
int32_t typeck_typeck_struct_layout_metrics(struct ast_Module *module, struct ast_ASTArena *arena, int32_t li,
                                            int32_t depth, int32_t check_pad, int32_t *out_sz, int32_t *out_al) {
  return glue_struct_layout_metrics_c(module, arena, li, depth, check_pad, out_sz, out_al);
}

/* wave1054 G.7 fold: glue_type_align_simple migrated here from pipeline_glue.c
 * (definition was at glue.c:2917). Struct layout registry domain — type
 * alignment computation, colocated with wave1053 (metrics) + wave1044
 * (compute_field_offset) + wave1049 (index_by_name) + wave1051 (value_bytes)
 * + wave1052 (sync_field_offsets).
 *
 * Mutually recursive with glue_struct_layout_metrics_c (defined above):
 *   - align_simple calls metrics for TYPE_NAMED struct alignment at depth+1
 *   - metrics calls align_simple for per-field alignment
 * Both static fwd decls at top of this file (L65/L72); definitions are
 * colocated here (align_simple after metrics at EOF).
 *
 * glue.c retains static fwd decl at L2787 for callsites in
 * pipeline_struct_layout_next_field_offset_ex body + soa.c:94/140 via
 * #include at glue.c:11697 (fwd decl visible before #include site). */

/**
 * Compute the alignment of a type (C twin of typeck.x typeck_x_type_align).
 *
 * Why: §11.1 layout step — asm frame sizing and struct field offset
 * computation need the alignment of each type to insert correct padding.
 * Scalar types return their natural width (bool/u8=1, i32/u32/f32=4,
 * i64/u64/usize/isize/ptr/slice=8). ARRAY/VECTOR/LINEAR recurse on the
 * element type. TYPE_NAMED looks up the struct layout by name and delegates
 * to glue_struct_layout_metrics_c for the struct's max_align.
 *
 * Invariant: returns 1 for invalid inputs (null arena, ty_ref out of range,
 * depth > 64) or unknown kinds; otherwise returns the alignment (1/4/8 or
 * struct max_align). f32 (kind_ord 14) must return 4, NOT 8 — otherwise
 * AoS three-f32 fields land at 0/8/16 instead of 0/4/8 (wave369 fix).
 *
 * Asm/Perf: O(1) for scalars; O(depth) for ARRAY/VECTOR recursion;
 * O(nlayouts * nf) for TYPE_NAMED via glue_struct_layout_metrics_c.
 * Bounded by depth limit 64. Hot path — called from struct layout metrics
 * and field offset computation.
 *
 * PLATFORM: SHARED — pure type alignment computation; arch-agnostic.
 */
static int32_t glue_type_align_simple(struct ast_Module *m, struct ast_ASTArena *a, int32_t ty_ref, int32_t depth) {
  int32_t kind_ord;
  if (!a || ty_ref <= 0 || ty_ref > a->num_types || depth > 64)
    return 1;
  kind_ord = pipeline_type_kind_ord_at(a, ty_ref);
  if (kind_ord == 2)
    return 1;
  /* i32/u32/u8/f32 align 4; do NOT treat f32(14) as 8 (AoS 3xf32 fields
   * would land at 0/8/16 instead of 0/4/8). */
  if (kind_ord == 0 || kind_ord == 3 || kind_ord == 1 || kind_ord == 14)
    return 4;
  if (kind_ord == 5 || kind_ord == 4 || kind_ord == 6 || kind_ord == 7 || kind_ord == 15 || kind_ord == 9)
    return 8;
  if (kind_ord == 11)
    return 8;
  /* ARRAY / LINEAR / VECTOR: alignment follows element type (matches
   * typeck.x ko==10/12/13). */
  if (kind_ord == 10 || kind_ord == 12 || kind_ord == 13) {
    int32_t elem_ref = pipeline_type_elem_ref_at(a, ty_ref);
    if (elem_ref <= 0)
      return 1;
    return glue_type_align_simple(m, a, elem_ref, depth + 1);
  }
  if (kind_ord == 8) {
    int32_t sz_out = 0;
    int32_t al_out = 1;
    int32_t nlen;
    uint8_t name[128];
    int32_t k;
    nlen = pipeline_type_named_name_into(a, ty_ref, name);
    if (nlen <= 0 || nlen > 127)
      return 4;
    for (k = 0; m && k < (int32_t)m->num_struct_layouts; k++) {
      int32_t ln = pipeline_module_struct_layout_name_len(m, k);
      int32_t j;
      int32_t eq = 1;
      if (ln != nlen)
        continue;
      for (j = 0; j < nlen; j++) {
        if (pipeline_module_struct_layout_name_byte_at(m, k, j) != name[j]) {
          eq = 0;
          break;
        }
      }
      if (!eq)
        continue;
      if (glue_struct_layout_metrics_c(m, a, k, depth + 1, 0, &sz_out, &al_out) != 0)
        return 1;
      return al_out > 0 ? al_out : 1;
    }
    return 4;
  }
  return 1;
}

/* wave1056 G.7: extern decl — typeck_soa_array_storage_size_glue defined in
 * pipeline_typeck_soa.c (glue.c:11651 #include); extern decl at glue.c:2925
 * is after this #include at L2095, so declare locally for size_simple body. */
extern int32_t typeck_soa_array_storage_size_glue(struct ast_Module *module, struct ast_ASTArena *arena,
                                                  int32_t elem_type_ref, int32_t array_len, int32_t depth);

/* wave1056 G.7 fold: glue_type_size_simple migrated here from pipeline_glue.c
 * (definition was at glue.c:2929). Type sizing domain — completes the struct
 * layout registry triad: size (wave1056) + align (wave1054) + metrics
 * (wave1053). All three colocated in struct_lit.c EOF.
 *
 * glue_type_size_simple is the C twin of typeck.x typeck_x_type_size. It is
 * the G.7 authority for type byte-width computation across all asm emit
 * domains (frame sizing, sret activation, call-arg packing, index stride,
 * array_lit temp, struct_lit field store).
 *
 * Dependencies (all visible before this #include site at glue.c:2095):
 * - typeck_x_type_size_from_layout_glue (extern; glue.c:233 < 2095 visible)
 * - typeck_soa_array_storage_size_glue (extern; declared locally above —
 *   glue.c:2925 > 2095 not visible)
 * - g_pipeline_asm_emit_dep_pipe (static global; glue.c:184 < 2095 visible)
 * - pipeline_dep_ctx_* / pipeline_type_* / pipeline_module_struct_layout_*
 *   (all public; visible)
 *
 * Forward decls retained:
 * - glue.c:1887 (before all #includes; serves return.c #include at L1957 +
 *   glue.c callsites before L2095)
 * - struct_lit.c:81 (local; for struct_lit.c callsites L286/746/1019/1058
 *   before EOF definition)
 * - array_lit.c:35 / struct_let.c:95 / index_helpers.c:122 / index.c:35
 *   (redundant after migration but harmless; cleanup deferred to avoid
 *   multi-file churn in one wave)
 *
 * Recursion: glue_type_size_simple calls itself for ARRAY/VECTOR element
 * sizing (L2954); also calls typeck_soa_array_storage_size_glue for SoA
 * column-major array storage and typeck_x_type_size_from_layout_glue for
 * TYPE_NAMED struct layout sizing. Mutually consistent with
 * glue_type_align_simple (wave1054) + glue_struct_layout_metrics_c
 * (wave1053) — all three share the same kind_ord dispatch table. */

/**
 * Compute the byte size of a type (C twin of typeck.x typeck_x_type_size).
 *
 * Why: §11.1 layout step — asm frame sizing, sret activation, call-arg
 * packing, index stride, array_lit temp, and struct_lit field store all
 * need the byte width of each type. Scalars return their natural width
 * (bool/u8=1, i32/u32/f32=4, i64/u64/usize/isize/ptr/f64=8, slice=16,
 * vector=16). ARRAY/VECTOR recurse on element type and multiply by
 * array_size, checking SoA column-major storage first. TYPE_NAMED looks
 * up the struct layout by name and delegates to
 * typeck_x_type_size_from_layout_glue; if not found locally, searches
 * dep modules via g_pipeline_asm_emit_dep_pipe for cross-module layout
 * sizing (field type_refs are dep-arena indices — must size with
 * pipeline_dep_ctx_arena_at, not caller arena, or Option_u8→24 false sret).
 *
 * Invariant: returns 0 for invalid inputs (null arena, ty_ref out of
 * range, depth > 64) or unknown kinds; otherwise returns the byte size
 * (1/4/8/16 or struct layout size). f32 (kind_ord 14) must return 4, NOT
 * 8 — matches glue_type_align_simple (wave1054) scalar table. SoA arrays
 * return column-major storage size when typeck_soa_array_storage_size_glue
 * > 0, else fall back to AoS (array_size * elem_sz). Dep module lookup
 * uses exact name match (not bare-suffix) — qualified import names
 * (heap.Allocator) use glue_type_named_layout_size_any_module_elf_c instead.
 *
 * Asm/Perf: O(1) for scalars; O(depth) for ARRAY/VECTOR recursion;
 * O(nlayouts * nf) for TYPE_NAMED via typeck_x_type_size_from_layout_glue;
 * O(ndep * nlayouts * nf) for dep module search. Bounded by depth limit 64.
 * Hot path — called from frame sizing, sret activation, call-arg packing,
 * index stride, array_lit temp, struct_lit field store.
 *
 * PLATFORM: SHARED — pure type sizing; arch-agnostic. Dep module search
 * is SHARED (cross-module layout resolution; dep-arena indices require
 * pipeline_dep_ctx_arena_at for correct field type sizing).
 */
static int32_t glue_type_size_simple(struct ast_Module *m, struct ast_ASTArena *a, int32_t ty_ref, int32_t depth) {
  int32_t kind_ord;
  if (!a || ty_ref <= 0 || ty_ref > a->num_types || depth > 64)
    return 0;
  kind_ord = pipeline_type_kind_ord_at(a, ty_ref);
  if (kind_ord == 16)
    return 0;
  if (kind_ord == 2)
    return 1;
  if (kind_ord == 0 || kind_ord == 3 || kind_ord == 1 || kind_ord == 13 || kind_ord == 14)
    return 4;
  if (kind_ord == 5 || kind_ord == 4 || kind_ord == 6 || kind_ord == 7 || kind_ord == 15 || kind_ord == 9)
    return 8;
  if (kind_ord == 11)
    return 16;
  if (kind_ord == 10 || kind_ord == 12) {
    int32_t elem_ref = pipeline_type_elem_ref_at(a, ty_ref);
    int32_t asz = pipeline_type_array_size_at(a, ty_ref);
    int32_t es;
    int32_t soa_sz;
    if (elem_ref <= 0 || asz <= 0)
      return 0;
    soa_sz = typeck_soa_array_storage_size_glue(m, a, elem_ref, asz, depth + 1);
    if (soa_sz > 0)
      return soa_sz;
    es = glue_type_size_simple(m, a, elem_ref, depth + 1);
    return es > 0 ? asz * es : 0;
  }
  if (kind_ord == 8) {
    uint8_t name[128];
    int32_t nlen;
    int32_t k;
    int32_t di;
    int32_t nd;
    struct ast_Module *dm;
    nlen = pipeline_type_named_name_into(a, ty_ref, name);
    if (nlen <= 0 || nlen > 127)
      return 4;
    for (k = 0; m && k < (int32_t)m->num_struct_layouts; k++) {
      int32_t ln = pipeline_module_struct_layout_name_len(m, k);
      int32_t j;
      int32_t eq = 1;
      if (ln != nlen)
        continue;
      for (j = 0; j < nlen; j++) {
        if (pipeline_module_struct_layout_name_byte_at(m, k, j) != name[j]) {
          eq = 0;
          break;
        }
      }
      if (!eq)
        continue;
      return typeck_x_type_size_from_layout_glue(m, a, k, depth + 1);
    }
    /* Dep exact-name layout only here. Qualified import names (heap.Allocator)
     * use glue_type_named_layout_size_any_module_elf_c bare-suffix match for
     * SysV dual-GP store/load/call — not size_simple (freestanding std.vec
     * co-emit CG002 if bare size walks inflate nested layout sizes
     * inconsistently).
     *
     * PLATFORM: SHARED — field type_refs on dep layouts are dep-arena indices.
     * Must size with pipeline_dep_ctx_arena_at, not caller arena
     * (Option_u8→24 false sret). */
    if (g_pipeline_asm_emit_dep_pipe) {
      nd = pipeline_dep_ctx_ndep(g_pipeline_asm_emit_dep_pipe);
      for (di = 0; di < nd; di++) {
        struct ast_ASTArena *da;
        dm = pipeline_dep_ctx_module_at(g_pipeline_asm_emit_dep_pipe, di);
        da = pipeline_dep_ctx_arena_at(g_pipeline_asm_emit_dep_pipe, di);
        if (!dm || !da)
          continue;
        for (k = 0; k < (int32_t)dm->num_struct_layouts; k++) {
          int32_t ln = pipeline_module_struct_layout_name_len(dm, k);
          int32_t j;
          int32_t eq = 1;
          int32_t sz;
          if (ln != nlen)
            continue;
          for (j = 0; j < nlen; j++) {
            if (pipeline_module_struct_layout_name_byte_at(dm, k, j) != name[j]) {
              eq = 0;
              break;
            }
          }
          if (!eq)
            continue;
          sz = typeck_x_type_size_from_layout_glue(dm, da, k, depth + 1);
          if (sz > 0)
            return sz;
        }
      }
    }
    return 4;
  }
  return 0;
}

/**
 * Check whether XLANG_PAD_FIELDS=1 env is set (DOD-CL pad-fields warning gate).
 *
 * Why: pipeline_typeck_pad_fields_warn_layout must early-exit when the user has
 * not opted into the false-sharing cache-line warning, to keep default builds
 * silent. Centralizing the env probe avoids scattering link_abi_getenv calls.
 *
 * Invariant: returns 1 only when XLANG_PAD_FIELDS is exactly "1"; 0 otherwise
 * (including unset, empty, or any other value).
 *
 * Asm/Perf: O(1) — one getenv + two byte checks. Cold path — called once per
 * struct layout in pipeline_typeck_pad_fields_warn_layout (glue.c:2828).
 *
 * PLATFORM: SHARED — env probe is platform-independent.
 *
 * wave1070 G.7: migrated from glue.c:2805 (body 3 LOC). Static (non-extern):
 * same-TU visibility — struct_lit.c #include at L2095 < def EOF < sole callsite
 * glue.c:2828. Dependencies: link_abi_getenv (extern).
 */
static int glue_pad_fields_warn_enabled(void) {
  const char *e = link_abi_getenv("XLANG_PAD_FIELDS");
  return e && e[0] == '1' && e[1] == '\0';
}

/**
 * Classify a field type as atomic-sized (4 or 8 bytes: u32/i32/u64/i64).
 *
 * Why: DOD-CL pad-fields warning (pipeline_typeck_pad_fields_warn_layout) must
 * only flag adjacent fields where at least one is an atomic counter candidate
 * (4/8B scalar). This helper centralizes the size gate so the warning logic
 * does not repeat glue_type_size_simple calls inline.
 *
 * Invariant: returns 0 for NULL module/arena or invalid type_ref; returns 1
 * iff glue_type_size_simple yields exactly 4 or 8.
 *
 * Asm/Perf: O(1) — one glue_type_size_simple call. Cold path — called per
 * field pair in pipeline_typeck_pad_fields_warn_layout (glue.c:2847).
 *
 * PLATFORM: SHARED — type size classification is platform-independent.
 *
 * wave1071 G.7: migrated from glue.c:2811 (body 6 LOC). Static (non-extern):
 * same-TU — struct_lit.c #include L2095 < def EOF < callsite glue.c:2847.
 * Dependencies: glue_type_size_simple (static, same file EOF wave1056).
 */
static int glue_field_type_atomic_sized(struct ast_Module *m, struct ast_ASTArena *a, int32_t ftr) {
  int32_t sz;
  if (!m || !a || ftr <= 0)
    return 0;
  sz = glue_type_size_simple(m, a, ftr, 0);
  return sz == 4 || sz == 8;
}

/**
 * Check whether XLANG_HOT_REORDER=1 env is set (DOD-CL-S2 hot-reorder hint gate).
 *
 * Why: pipeline_typeck_hot_reorder_warn_layout must early-exit when the user
 * has not opted into the hot-field placement hint, to keep default builds
 * silent. Centralizing the env probe avoids scattering link_abi_getenv calls.
 *
 * Invariant: returns 1 only when XLANG_HOT_REORDER is exactly "1"; 0 otherwise.
 *
 * Asm/Perf: O(1) — one getenv + two byte checks. Cold path — called once per
 * struct layout in pipeline_typeck_hot_reorder_warn_layout (glue.c:2875).
 *
 * PLATFORM: SHARED — env probe is platform-independent.
 *
 * wave1072 G.7: migrated from glue.c:2860 (body 3 LOC). Static (non-extern):
 * same-TU — struct_lit.c #include L2095 < def EOF < callsite glue.c:2875.
 * Dependencies: link_abi_getenv (extern).
 */
static int glue_hot_reorder_warn_enabled(void) {
  const char *e = link_abi_getenv("XLANG_HOT_REORDER");
  return e && e[0] == '1' && e[1] == '\0';
}

/* ─────────────────────────────────────────────────────────────────────────── */
/* wave1113-1114 G.7: struct layout name lookup domain (2 fns) migrated from
 * pipeline_glue.c L10130-10157 and L11114-11144. These are struct layout
 * registry name-match helpers — natural co-located with the struct layout
 * registry authority already in struct_lit.c (wave1044/1049/1051/1052/1053).
 * Static (non-extern): same-TU visibility via #include order — struct_lit.c
 * #include at L2051 < all callsites (L10189+ / L11213+ / L11240+ / L11363+).
 * PLATFORM: SHARED — pure name match, no arch dependency. */

/**
 * Return 1 if ty_ref is a TYPE_NAMED that matches a registered struct_layout
 * in module m. Returns 0 otherwise (including non-NAMED, empty name, or no
 * matching layout).
 *
 * Why: WPO-S3 stack-escape analysis and call ptr-struct compatibility both
 * need to know whether a type is a module-local struct. Centralizing this
 * check in the struct layout registry avoids duplicating the name-scan loop.
 *
 * Contract: m and a must be non-NULL, ty_ref > 0. Returns 0/1 only.
 *
 * PLATFORM: SHARED — pure name comparison, no arch dependency.
 */
static int32_t typeck_type_is_named_struct_c(struct ast_Module *m, struct ast_ASTArena *a, int32_t ty_ref) {
  uint8_t name[128];
  int32_t nlen;
  int32_t k;
  int32_t j;
  if (!m || !a || ty_ref <= 0)
    return 0;
  if (pipeline_type_kind_ord_at(a, ty_ref) != (int32_t)ast_TypeKind_TYPE_NAMED)
    return 0;
  nlen = pipeline_type_named_name_into(a, ty_ref, name);
  if (nlen <= 0 || nlen > 127)
    return 0;
  for (k = 0; k < (int32_t)m->num_struct_layouts; k++) {
    int32_t ln = pipeline_module_struct_layout_name_len(m, k);
    int32_t eq = 1;
    if (ln != nlen)
      continue;
    for (j = 0; j < nlen; j++) {
      if (pipeline_module_struct_layout_name_byte_at(m, k, j) != name[j]) {
        eq = 0;
        break;
      }
    }
    if (eq)
      return 1;
  }
  return 0;
}

/**
 * Find the struct_layout index for a TYPE_NAMED type_ref. Returns -1 if not
 * found or not a TYPE_NAMED.
 *
 * Why: call-arg repr-compatibility check (wave703) needs the layout index to
 * compare field shapes between two struct types. Co-located with the struct
 * layout registry to keep all name→index lookups in one authority.
 *
 * Contract: m and a must be non-NULL, ty_ref > 0. Returns -1 on miss.
 *
 * PLATFORM: SHARED — pure name scan, no arch dependency.
 */
static int32_t typeck_layout_index_for_named_type_c(struct ast_Module *m, struct ast_ASTArena *a, int32_t ty_ref) {
  uint8_t name[128];
  int32_t nlen;
  int32_t k;
  int32_t j;
  if (!m || !a || ty_ref <= 0)
    return -1;
  if (pipeline_type_kind_ord_at(a, ty_ref) != (int32_t)ast_TypeKind_TYPE_NAMED)
    return -1;
  nlen = pipeline_type_named_name_into(a, ty_ref, name);
  if (nlen <= 0 || nlen > 127)
    return -1;
  for (k = 0; k < (int32_t)m->num_struct_layouts; k++) {
    int32_t ln = pipeline_module_struct_layout_name_len(m, k);
    int32_t eq = 1;
    if (ln != nlen)
      continue;
    for (j = 0; j < nlen; j++) {
      if (pipeline_module_struct_layout_name_byte_at(m, k, j) != name[j]) {
        eq = 0;
        break;
      }
    }
    if (eq)
      return k;
  }
  return -1;
}

/* ─────────────────────────────────────────────────────────────────────────── */
/* wave1124 G.7: struct layout same-shape comparator (1 fn) migrated from
 * pipeline_glue.c L10924. Co-located with the struct layout registry domain
 * (typeck_type_is_named_struct_c wave1113 / typeck_layout_index_for_named_type_c
 * wave1114 / glue_struct_layout_metrics_c wave1053). Static (non-extern):
 * same-TU — struct_lit.c #include at glue.c L2051 < callsite L10996 (inside
 * pipeline_typeck_call_arg_repr_compatible_ok_c). Deps:
 * pipeline_module_struct_layout_* (extern) + pipeline_typeck_type_refs_equal_c
 * (public). PLATFORM: SHARED. */

/**
 * MOD-02: return 1 if two struct layouts have identical field count,
 * field offsets, and field types. Returns 0 otherwise.
 *
 * Why: wave703 #[repr(compatible)] ptr-coerce path needs to verify that
 * *StructA and *StructB have the same memory shape before allowing the
 * cast. Centralizing this comparator in the struct layout registry
 * avoids duplicating the field-by-field walk in the call-arg compat gate.
 *
 * Contract: m and a must be non-NULL, la and lb >= 0. Returns 0 if
 * either layout has 0 fields or field counts differ.
 *
 * PLATFORM: SHARED — pure layout comparison, no arch dependency.
 */
static int32_t typeck_struct_layouts_same_shape_c(struct ast_Module *m, struct ast_ASTArena *a, int32_t la,
                                                  int32_t lb) {
  int32_t nfa;
  int32_t nfb;
  int32_t j;
  if (!m || !a || la < 0 || lb < 0)
    return 0;
  nfa = pipeline_module_struct_layout_num_fields(m, la);
  nfb = pipeline_module_struct_layout_num_fields(m, lb);
  if (nfa != nfb || nfa <= 0)
    return 0;
  for (j = 0; j < nfa; j++) {
    if (pipeline_module_struct_layout_field_offset_at(m, la, j) !=
        pipeline_module_struct_layout_field_offset_at(m, lb, j))
      return 0;
    if (!pipeline_typeck_type_refs_equal_c(a, pipeline_module_struct_layout_field_type_ref(m, la, j),
                                           pipeline_module_struct_layout_field_type_ref(m, lb, j)))
      return 0;
  }
  return 1;
}

/*
 * wave1164 G.7: struct_lit accessor cluster (4 fns:
 * pipeline_expr_struct_lit_num_fields / type_name_len / type_name_into /
 * type_name_set) migrated from pipeline_glue.c (was L2450-2497). Colocated
 * with STRUCT_LIT emit domain — all read/write Expr struct_lit_* fields via
 * glue_arena_expr_at_ref (static fwd decl in pipeline_asm_emit_as.c L41,
 * visible to this file via #include chain as.c L1843 < struct_lit.c L1959).
 * Forward decl for num_fields retained at glue.c L1540 (harmless).
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU.
 */

/**
 * Read EXPR_STRUCT_LIT field count (number of named fields in the literal).
 * Returns 0 for invalid ref / non-STRUCT_LIT expr.
 */
int32_t pipeline_expr_struct_lit_num_fields(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->struct_lit_num_fields : 0;
}

/**
 * Read struct_lit type name length (byte count of struct_lit_struct_name).
 * Returns 0 for invalid ref.
 */
int32_t pipeline_expr_struct_lit_type_name_len(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->struct_lit_struct_name_len : 0;
}

/**
 * Copy struct_lit type name into out64 (128 bytes, NUL-padded).
 * For invalid ref, writes 128 zero bytes to out64.
 * wave577 Cap: copies full 128-byte struct_lit_struct_name array.
 */
void pipeline_expr_struct_lit_type_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out64) {
  struct ast_Expr *ex;
  if (!out64)
    return;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex) {
    memset(out64, 0, 128);
    return;
  }
  memcpy(out64, ex->struct_lit_struct_name, 128); /* wave577 Cap */
}

/**
 * Backfill struct_lit_struct_name on an anonymous struct literal expression
 * from the contextual return type (resolved through type alias).
 *
 * Why: anonymous `{ a: 1, b: 2 }` literals have empty struct_lit_struct_name;
 *      codegen then emits `(struct <module>_){...}` → cc "incomplete type" error.
 *      typeck backfills the name so codegen emits `(struct <module>_Pair){...}`.
 * Contract: name_len must be in [1, 127]; null/invalid arena/ref is a no-op.
 * PLATFORM: SHARED — called from typeck.x contextual typing backfill path.
 */
void pipeline_expr_struct_lit_type_name_set(struct ast_ASTArena *a, int32_t expr_ref,
                                            uint8_t *name, int32_t name_len) {
  struct ast_Expr *ex;
  if (!a || !name || expr_ref <= 0 || expr_ref > a->num_exprs)
    return;
  if (name_len < 0 || name_len > 127)
    return;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex)
    return;
  memset(ex->struct_lit_struct_name, 0, sizeof(ex->struct_lit_struct_name)); /* wave577 Cap */
  memcpy(ex->struct_lit_struct_name, name, (size_t)name_len);
  ex->struct_lit_struct_name_len = name_len;
}
