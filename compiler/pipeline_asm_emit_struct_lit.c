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
 * - glue_type_is_empty_struct_c / glue_type_size_simple
 * - glue_struct_lit_store_fixed_array_field_elf_c (pipeline_asm_emit_vector_let.c)
 * - glue_struct_field_frame_mag_c / glue_field_access_effective_offset_c
 * - glue_call_return_byte_size_c / glue_store_retval_pair_to_rbp_elf_c
 * - glue_emit_struct_type_let_init_elf_c / glue_emit_sret_memcpy_rbx_to_home
 * - pipeline_asm_emit_expr_elf_rec / backend_enc_* / g_pipeline_asm_emit_*
 */

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
