/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
/* wave149: pipeline_asm_emit_binop pure-owned leave cold twins (void* style).
 * PLATFORM: SHARED freestanding cold twin.
 */

/* wave149 cold twin glue_binop_as_needs_full_emit_elf_c. PLATFORM: SHARED. */
int32_t glue_binop_as_needs_full_emit_elf_c(void *arena, int32_t expr_ref) {
  int32_t op_ref;
  int32_t tgt;
  int32_t tgt_k;
  int32_t src_tr;
  int32_t src_k;
  int32_t op_ko;
  if (!arena || expr_ref <= 0 || !glue_expr_is_x_as_cast_at_c(arena, expr_ref))
    return 0;
  op_ref = pipeline_expr_as_operand_ref_at(arena, expr_ref);
  if (op_ref <= 0)
    return 0;
  tgt = pipeline_expr_as_target_type_ref_at(arena, expr_ref);
  if (tgt <= 0)
    return 0;
  tgt_k = pipeline_type_kind_ord_at(arena, tgt);
  if (tgt_k == 14 || tgt_k == 15)
    return 1;
  src_tr = pipeline_expr_resolved_type_ref(arena, op_ref);
  src_k = src_tr > 0 ? pipeline_type_kind_ord_at(arena, src_tr) : -1;
  op_ko = pipeline_expr_kind_ord_at(arena, op_ref);
  /* kind 1 = EXPR_FLOAT_LIT — often unresolved or f64 default. */
  if (src_k == 14 || src_k == 15 ||
      (src_k <= 0 && op_ko == 1))
    return 1;
  return 0;
}

/* XLANG_PABI_BINOP_BLOCK_PEEL_THIN_BEGIN */
#include <stdint.h>
extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_block_ref_at(void *arena, int32_t expr_ref);
extern int32_t ast_ast_block_num_lets(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_loops(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_expr_stmts(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_final_expr_ref(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_stmt_order(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_stmt_order_kind(void *arena, int32_t block_ref, int32_t si);
extern int32_t ast_ast_block_stmt_order_idx(void *arena, int32_t block_ref, int32_t si);
extern int32_t pipeline_block_region_body_ref(void *arena, int32_t block_ref, int32_t ri);
extern int32_t glue_var_expr_stack_off_elf_c(void *arena, void *ctx, int32_t var_ref);
extern int32_t pipeline_expr_var_name_len(void *arena, int32_t expr_ref);
extern void pipeline_expr_var_name_into(void *arena, int32_t expr_ref, uint8_t *out);
extern void *pipeline_asm_emit_module_ref_c(void);
extern int32_t asm_module_top_level_const_lit_i32(void *mod, void *arena, uint8_t *name, int32_t nlen, int32_t *out);
extern int32_t backend_enc_mov_imm32_to_rbx_arch(void *elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_mov_imm32_to_w0_arch(void *elf_ctx, int32_t imm, int32_t ta);
extern void glue_asm73_evict_cache_if_live_pressure_elf_c(int32_t ta, void *elf_ctx);
extern int32_t glue_binop_var_slot_cache_hit_rbx(void *ctx, int32_t off);
extern int32_t glue_binop_try_reload_spill_off_elf_c(void *elf_ctx, void *ctx, int32_t off, int32_t ta, int32_t to_rbx);
extern int32_t glue_var_decl_type_ref_elf_c(void *arena, void *ctx, int32_t expr_ref);
extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t type_ref);
extern int32_t glue_load_f32_var_slot_to_rbx_elf_c(void *elf_ctx, void *arena, void *ctx, int32_t expr_ref, int32_t off, int32_t ta);
extern int32_t backend_enc_load_rbp_to_rbx_arch(void *elf_ctx, int32_t off, int32_t ta);
extern int32_t glue_asm73_var_prefers_stack_spill(int32_t off);
extern int32_t glue_binop_stack_spill_push_elf_c(void *elf_ctx, int32_t ta, int32_t off, int32_t which);
extern void glue_binop_var_slot_cache_set_ctx_key(void *ctx);
extern void glue_binop_var_slot_cache_set_rbx(void *ctx, int32_t off);
extern int32_t glue_binop_var_slot_cache_hit_rax(void *ctx, int32_t off);
extern int32_t glue_load_f32_var_slot_to_rax_elf_c(void *elf_ctx, void *arena, void *ctx, int32_t expr_ref, int32_t off, int32_t ta);
extern int32_t backend_enc_load_rbp_to_rax_arch(void *elf_ctx, int32_t off, int32_t ta);
extern void glue_binop_var_slot_cache_set_rax(void *ctx, int32_t off);
extern int32_t pipeline_expr_field_access_is_enum_variant(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_base_ref(void *arena, int32_t expr_ref);
extern void glue_binop_var_slot_cache_clear(void);
extern int32_t pipeline_asm_emit_expr_elf_fast(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(void *elf_ctx, int32_t ta);
extern int32_t pipeline_asm_emit_field_access_elf_fast_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_index_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_deref_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t glue_expr_is_await_at_c(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_unary_operand_ref_at(void *arena, int32_t expr_ref);
extern int32_t glue_expr_is_x_as_cast_at_c(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_as_operand_ref_at(void *arena, int32_t expr_ref);
extern int32_t glue_binop_as_needs_full_emit_elf_c(void *arena, int32_t expr_ref);
extern int32_t pipeline_asm_emit_as_elf_impl(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_expr_index_base_is_slice_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_index_base_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_resolved_type_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_index_index_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_asm_expr_lit_i32_at_c(void *arena, int32_t expr_ref, int32_t *out);

/* Transparent EXPR_BLOCK value for binop dual-slot.
 * `unsafe { e }` / `{ e }` is EXPR_BLOCK (26). Load_operand used to return
 * -2, so `x + unsafe { *q }` fell to emit_expr(BLOCK) after ARM64 rax
 * frame-spill → CG002. Peel a single value expr with no lets/loops.
 * G.7: one peel helper (same role as await/AS). Walkers recurse.
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 exposes CG002. */
int32_t glue_expr_block_transparent_value_ref_at(void *arena, int32_t expr_ref) {
  int32_t ko;
  int32_t br;
  int32_t nlet;
  int32_t nloop;
  int32_t nexpr;
  int32_t nso;
  int32_t so_k;
  int32_t so_idx;
  int32_t inner;
  int32_t fin;
  if (!arena || expr_ref <= 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  /* EXPR_BLOCK = 26 */
  if (ko != 26)
    return 0;
  br = pipeline_expr_block_ref_at(arena, expr_ref);
  if (br <= 0)
    return 0;
  nlet = ast_ast_block_num_lets(arena, br);
  nloop = ast_ast_block_num_loops(arena, br);
  nexpr = ast_ast_block_num_expr_stmts(arena, br);
  nso = ast_ast_block_num_stmt_order(arena, br);
  fin = ast_ast_block_final_expr_ref(arena, br);
  if (nlet != 0 || nloop != 0)
    return 0;
  /* `unsafe { e }` primary: wrapper + stmt_order kind 6 (region pool). */
  if (nso == 1 && nexpr == 0 && fin <= 0) {
    so_k = ast_ast_block_stmt_order_kind(arena, br, 0);
    so_idx = ast_ast_block_stmt_order_idx(arena, br, 0);
    if (so_k == 6 && so_idx >= 0) {
      inner = pipeline_block_region_body_ref(arena, br, so_idx);
      if (inner > 0) {
        nlet = ast_ast_block_num_lets(arena, inner);
        nloop = ast_ast_block_num_loops(arena, inner);
        fin = ast_ast_block_final_expr_ref(arena, inner);
        if (nlet == 0 && nloop == 0 && fin > 0)
          return fin;
      }
    }
    return 0;
  }
  if (nexpr <= 1 && fin > 0)
    return fin;
  return 0;
}

/* wave149 cold twin glue_try_binop_load_operand_elf_c. PLATFORM: SHARED. */
int32_t glue_try_binop_load_operand_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta, int32_t to_rbx) {
  int32_t ko;
  int32_t off;
  int32_t vr;
  int32_t base_ref;
  int32_t blk_inner;
  if (!arena || !elf_ctx || !ctx || expr_ref <= 0)
    return -2;
  /* Peel unsafe { e } / { e } so DEREF/INDEX load as themselves (not BLOCK). */
  blk_inner = glue_expr_block_transparent_value_ref_at(arena, expr_ref);
  if (blk_inner > 0)
    return glue_try_binop_load_operand_elf_c(arena, elf_ctx, blk_inner, ctx, ta, to_rbx);
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ko == 3) {
    off = glue_var_expr_stack_off_elf_c(arena, ctx, expr_ref);
    if (off < 0) {
      /*
       * Stage 12.2.6: module-level export const has no stack slot. Left-assoc
       * binop paths (A+B)+C call load_operand(to_rbx) after emitting left@rax;
       * returning -2 made `!= 0` fail hard → CG002 on non-first funcs (first
       * often const-folds the whole tree; later funcs still need multi-const
       * nested binops). Align with pipeline_asm_emit_expr_elf_fast VAR path:
       * materialize top-level const lit as imm into rax/rbx.
       * PLATFORM: SHARED freestanding emit.
       */
      uint8_t vname[256];
      int32_t vlen;
      int32_t mod_imm;
      void *mod;
      vlen = pipeline_expr_var_name_len(arena, expr_ref);
      if (vlen <= 0)
        return -2;
      pipeline_expr_var_name_into(arena, expr_ref, vname);
      mod = pipeline_asm_emit_module_ref_c();
      if (mod && asm_module_top_level_const_lit_i32(mod, arena, vname, vlen, &mod_imm) != 0) {
        if (to_rbx != 0) {
          if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, mod_imm, ta) != 0)
            return -1;
        } else {
          if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, mod_imm, ta) != 0)
            return -1;
        }
        return 0;
      }
      /* wave745: mutable file-level let — load the global via emit_expr. */
      glue_binop_var_slot_cache_clear();
      vr = pipeline_asm_emit_expr_elf_fast(arena, elf_ctx, expr_ref, ctx, ta);
      if (vr == -99)
        return -2;
      if (vr != 0)
        return -1;
      if (to_rbx != 0 && backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
        return -1;
      return 0;
    }
    glue_asm73_evict_cache_if_live_pressure_elf_c(ta, elf_ctx);
    if (to_rbx != 0) {
      if ((glue_binop_var_slot_cache_hit_rbx(ctx, off) != 0))
        return 0;
      vr = glue_binop_try_reload_spill_off_elf_c(elf_ctx, ctx, off, ta, 1);
      if (vr < 0)
        return -1;
      if (vr != 0)
        return 0;
      {
        int32_t vtr = glue_var_decl_type_ref_elf_c(arena, ctx, expr_ref);
        if (vtr > 0 && pipeline_type_kind_ord_at(arena, vtr) == 14) {
          if (glue_load_f32_var_slot_to_rbx_elf_c(elf_ctx, arena, ctx, expr_ref, off, ta) != 0)
            return -1;
        } else if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, off, ta) != 0) {
          return -1;
        }
      }
      if (glue_asm73_var_prefers_stack_spill(off) != 0) {
        if (glue_binop_stack_spill_push_elf_c(elf_ctx, ta, off, 1) != 0)
          return -1;
        glue_binop_var_slot_cache_set_ctx_key(ctx);
        return 0;
      }
      glue_binop_var_slot_cache_set_rbx(ctx, off);
      return 0;
    }
    if ((glue_binop_var_slot_cache_hit_rax(ctx, off) != 0))
      return 0;
    vr = glue_binop_try_reload_spill_off_elf_c(elf_ctx, ctx, off, ta, 0);
    if (vr < 0)
      return -1;
    if (vr != 0)
      return 0;
    {
      int32_t vtr = glue_var_decl_type_ref_elf_c(arena, ctx, expr_ref);
      if (vtr > 0 && pipeline_type_kind_ord_at(arena, vtr) == 14) {
        if (glue_load_f32_var_slot_to_rax_elf_c(elf_ctx, arena, ctx, expr_ref, off, ta) != 0)
          return -1;
      } else if (backend_enc_load_rbp_to_rax_arch(elf_ctx, off, ta) != 0) {
        return -1;
      }
    }
    if (glue_asm73_var_prefers_stack_spill(off) != 0) {
      if (glue_binop_stack_spill_push_elf_c(elf_ctx, ta, off, 0) != 0)
        return -1;
      glue_binop_var_slot_cache_set_ctx_key(ctx);
      return 0;
    }
    glue_binop_var_slot_cache_set_rax(ctx, off);
    return 0;
  }
  if (ko == 44) {
    if (pipeline_expr_field_access_is_enum_variant(arena, expr_ref) != 0)
      return -2;
    base_ref = pipeline_expr_field_access_base_ref(arena, expr_ref);
    /** DOD-S1：SoA `arr[i].field` 作 binop 右值须 field_access fast（含 stride/load_sz），勿 -2 落 INDEX imul AoS。 */
    if (base_ref > 0 && pipeline_expr_kind_ord_at(arena, base_ref) == 47) {
      glue_binop_var_slot_cache_clear();
      vr = pipeline_asm_emit_expr_elf_fast(arena, elf_ctx, expr_ref, ctx, ta);
      if (vr == -99)
        return -2;
      if (vr != 0)
        return -1;
      if (to_rbx != 0 && backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
        return -1;
      return 0;
    }
    if (base_ref <= 0 || pipeline_expr_kind_ord_at(arena, base_ref) != 3)
      return -2;
    glue_binop_var_slot_cache_clear();
    /** TokenKind/ExprKind 枚举须在 field_access fast 回落，勿仅 var_field_access（binop RHS 比较）。 */
    vr = pipeline_asm_emit_field_access_elf_fast_c(arena, elf_ctx, expr_ref, ctx, ta);
    if (vr == -99)
      return -2;
    if (vr != 0)
      return -1;
    if (to_rbx != 0 && backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    return 0;
  }
  if (ko == 47) {
    glue_binop_var_slot_cache_clear();
    vr = pipeline_asm_emit_index_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    if (vr != 0)
      return -2;
    if (to_rbx != 0 && backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    return 0;
  }
  /** wave323: *p as binop operand — emit load [ptr], not pointer bits. */
  if (ko == 52) {
    glue_binop_var_slot_cache_clear();
    vr = pipeline_asm_emit_deref_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    if (vr != 0)
      return -1;
    if (to_rbx != 0 && backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    return 0;
  }
  /** u8[i] as i32 等：剥 EXPR_AS 再 load 标量操作数；C await(54) 剥 unary 操作数。 */
  if (glue_expr_is_await_at_c(arena, expr_ref)) {
    int32_t await_op;
    await_op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    if (await_op <= 0)
      return -2;
    return glue_try_binop_load_operand_elf_c(arena, elf_ctx, await_op, ctx, ta, to_rbx);
  }
  if (glue_expr_is_x_as_cast_at_c(arena, expr_ref)) {
    int32_t op_ref;
    op_ref = pipeline_expr_as_operand_ref_at(arena, expr_ref);
    if (op_ref <= 0)
      return -2;
    /*
     * wave301 Cap residual pure: peel only integer-result AS (e.g. u8[i] as i32).
     * Float-target AS must not peel — dual-slot would load raw integer/source bits
     * and skip cvtsi2ss / cvtsi2sd / cvtsd2ss / cvtss2sd from pipeline_asm_emit_as_elf.
     * Soft residual after wave299/300: `(u64 as f32) * f32_var` run=0 while bare
     * `(u64 as f32) as i32` stayed green. G.7: complete loader authority next to
     * emit_as (reuse pipeline_asm_emit_as_elf_impl; no new encoder / no second cast path).
     * PLATFORM: SHARED cast semantics / LINUX+MACOS x86_64 freestanding exposes; mac host-gcc hid.
     *
     * wave620 Cap residual pure: float→int AS must not peel either.
     * Top-level `return z as i32` hits pipeline_asm_emit_as_elf_impl (cvttss2si green),
     * but dual-slot binop `(x as i32)+(y as i32)` / `(a[0] as i32)+(a[1] as i32)` peeled
     * AS → integer ADD of IEEE bits (mac/Ubuntu pure-asm run=0 via 8-bit $?; host-C hid).
     * G.7: glue_binop_as_needs_full_emit_elf_c + same full-AS authority — no second path.
     * PLATFORM: SHARED freestanding dual-slot; LINUX x86_64 + MACOS|ARM64 both expose.
     */
    if (glue_binop_as_needs_full_emit_elf_c(arena, expr_ref) != 0) {
      glue_binop_var_slot_cache_clear();
      if (pipeline_asm_emit_as_elf_impl(arena, elf_ctx, expr_ref, ctx, ta) != 0)
        return -1;
      if (to_rbx != 0 && backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
        return -1;
      return 0;
    }
    return glue_try_binop_load_operand_elf_c(arena, elf_ctx, op_ref, ctx, ta, to_rbx);
  }
  return -2;
}

/* wave149 cold twin glue_binop_operand_index_addr_clobbers_rbx_elf_c. PLATFORM: SHARED. */
int32_t glue_binop_operand_index_addr_clobbers_rbx_elf_c(void *arena, int32_t expr_ref) {
  int32_t ko;
  int32_t op_ref;
  if (!arena || expr_ref <= 0)
    return 0;
  op_ref = glue_expr_block_transparent_value_ref_at(arena, expr_ref);
  if (op_ref > 0)
    return glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena, op_ref);
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (glue_expr_is_await_at_c(arena, expr_ref)) {
    op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    return op_ref > 0 ? glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena, op_ref) : 0;
  }
  if (glue_expr_is_x_as_cast_at_c(arena, expr_ref)) {
    op_ref = pipeline_expr_as_operand_ref_at(arena, expr_ref);
    return op_ref > 0 ? glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena, op_ref) : 0;
  }
  /* wave625: FIELD of INDEX still runs INDEX bounds/addr in rbx (a[i].x dual-slot). */
  if (ko == 44) {
    op_ref = pipeline_expr_field_access_base_ref(arena, expr_ref);
    return op_ref > 0 ? glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena, op_ref) : 0;
  }
  /* DEREF of INDEX / slice: lvalue emits the operand pointer; INDEX
   * / slice operand uses rbx. Walk the operand (same as FIELD).
   * DEREF of VAR is rax-only. Same-commit twin of mega .x.
   * PLATFORM: SHARED — park dest before DEREF-of-INDEX lvalue. */
  if (ko == 52) {
    op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    return op_ref > 0 ? glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena, op_ref) : 0;
  }
  if (ko == 47) {
    int32_t idx_ref;
    int32_t lit_dummy;
        int32_t base_ref;
    int32_t base_ty;
    int32_t base_ko;
    if (pipeline_expr_index_base_is_slice_at(arena, expr_ref) != 0)
      return 1;
    base_ref = pipeline_expr_index_base_ref(arena, expr_ref);
    if (base_ref > 0) {
      base_ty = pipeline_expr_resolved_type_ref(arena, base_ref);
      if (base_ty > 0 && pipeline_type_kind_ord_at(arena, base_ty) == 11)
        return 1;
      /*
       * Materializing bases park payload/home in rbx while writing temps.
       * ARRAY_LIT (46): emit_array_lit mov rax→rbx for store loop.
       * STRUCT_LIT (45) / CALL (48) / METHOD (49): call_base / struct temp same.
       * Nested INDEX (47) / FIELD (44) of those: recurse via base walk below.
       * Only VAR / pure FIELD-of-VAR can take base+imm*esz without touching rbx.
       */
      base_ko = pipeline_expr_kind_ord_at(arena, base_ref);
      if (base_ko == 46 || base_ko == 45 || base_ko == 48 || base_ko == 49)
        return 1;
      if (base_ko == 47)
        return 1;
      if (base_ko == 44) {
        int32_t fa_base = pipeline_expr_field_access_base_ref(arena, base_ref);
        if (fa_base > 0) {
          int32_t fa_ko = pipeline_expr_kind_ord_at(arena, fa_base);
          /* FIELD of materializing root (Wrap{}.xs[i] dual-slot) also parks rbx. */
          if (fa_ko == 46 || fa_ko == 45 || fa_ko == 48 || fa_ko == 49 || fa_ko == 47)
            return 1;
        }
      }
    }
    idx_ref = pipeline_expr_index_index_ref(arena, expr_ref);
    /* Fixed TYPE_ARRAY + lit index on VAR/FIELD base: base+imm*esz, bounds CTFE — no rbx. */
    if (idx_ref > 0 && pipeline_asm_expr_lit_i32_at_c(arena, idx_ref, &lit_dummy))
      return 0;
    return 1;
  }
  return 0;
}

/* wave149 cold twin glue_binop_operand_load_to_rbx_clobbers_rax_elf_c. PLATFORM: SHARED. */
int32_t glue_binop_operand_load_to_rbx_clobbers_rax_elf_c(void *arena, int32_t expr_ref) {
  int32_t ko;
  int32_t op_ref;
  if (!arena || expr_ref <= 0)
    return 1;
  op_ref = glue_expr_block_transparent_value_ref_at(arena, expr_ref);
  if (op_ref > 0)
    return glue_binop_operand_load_to_rbx_clobbers_rax_elf_c(arena, op_ref);
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ko == 3)
    return 0;
  /** 立即数直 mov 到 rbx，不经 rax。 */
  if (ko == 0 || ko == 2)
    return 0;
  if (ko == 44 || ko == 47)
    return 1;
  if (glue_expr_is_await_at_c(arena, expr_ref)) {
    op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    return op_ref > 0 ? glue_binop_operand_load_to_rbx_clobbers_rax_elf_c(arena, op_ref) : 1;
  }
  if (glue_expr_is_x_as_cast_at_c(arena, expr_ref)) {
    /*
     * wave620: full-AS (float↔int) always materializes via rax then mov→rbx when
     * to_rbx=1 — peels as VAR would claim "no clobber" and destroy a live left in rax.
     */
    if (glue_binop_as_needs_full_emit_elf_c(arena, expr_ref) != 0)
      return 1;
    op_ref = pipeline_expr_as_operand_ref_at(arena, expr_ref);
    return op_ref > 0 ? glue_binop_operand_load_to_rbx_clobbers_rax_elf_c(arena, op_ref) : 1;
  }
  return 1;
}

/* wave149 cold twin glue_expr_emit_may_clobber_rbx_elf_c. PLATFORM: SHARED. */
int32_t glue_expr_emit_may_clobber_rbx_elf_c(void *arena, int32_t expr_ref) {
  int32_t ko;
  int32_t op_ref;
  if (!arena || expr_ref <= 0)
    return 1;
  op_ref = glue_expr_block_transparent_value_ref_at(arena, expr_ref);
  if (op_ref > 0)
    return glue_expr_emit_may_clobber_rbx_elf_c(arena, op_ref);
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ko == 3 || ko == 0 || ko == 2)
    return 0;
  if (ko == 44 || ko == 47)
    return 1;
  if (glue_expr_is_await_at_c(arena, expr_ref)) {
    op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    return op_ref > 0 ? glue_expr_emit_may_clobber_rbx_elf_c(arena, op_ref) : 1;
  }
  if (glue_expr_is_x_as_cast_at_c(arena, expr_ref)) {
    /* Full-AS may walk INDEX/FIELD operands that park temps in rbx. */
    if (glue_binop_as_needs_full_emit_elf_c(arena, expr_ref) != 0) {
      op_ref = pipeline_expr_as_operand_ref_at(arena, expr_ref);
      return op_ref > 0 ? glue_expr_emit_may_clobber_rbx_elf_c(arena, op_ref) : 1;
    }
    op_ref = pipeline_expr_as_operand_ref_at(arena, expr_ref);
    return op_ref > 0 ? glue_expr_emit_may_clobber_rbx_elf_c(arena, op_ref) : 1;
  }
  return 1;
}
/* XLANG_PABI_BINOP_BLOCK_PEEL_THIN_END */

/* wave149 cold twin glue_binop_preserve_rbx_for_index_elf_c. PLATFORM: SHARED. */
int32_t glue_binop_preserve_rbx_for_index_elf_c(void *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_mov_rbx_to_x2(elf_ctx);
  return backend_enc_push_rbx_arch(elf_ctx, ta);
}

/* wave149 cold twin glue_binop_restore_rbx_after_index_elf_c. PLATFORM: SHARED. */
int32_t glue_binop_restore_rbx_after_index_elf_c(void *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_mov_x2_to_rbx(elf_ctx);
  return backend_enc_pop_rbx_arch(elf_ctx, ta);
}

/* wave149 cold twin glue_binop_preserve_rax_for_rbx_load_elf_c. PLATFORM: SHARED. */
int32_t glue_binop_preserve_rax_for_rbx_load_elf_c(void *elf_ctx, int32_t ta, void *ctx) {
  if (ta != 1)
    return backend_enc_push_rax_arch(elf_ctx, ta);
  {
    void *ly;
    int32_t base_off;
    int32_t home;
    if (!elf_ctx || !ctx)
      return -1;
    if (glue_binop_rax_frame_spill_depth() >= 16)
      return -1;
    ly = pipeline_asm_ctx_layout(ctx);
    if (!ly)
      return -1;
    /* PLATFORM: MACOS|ARM64 low-end home (wave402): home=off, next=off+8. */
    base_off = pipe_load_i32_le(ly, 4);
    if ((base_off % 8) != 0)
      base_off = (base_off + 7) / 8 * 8;
    home = base_off;
    pipe_store_i32_le(ly, 4, base_off + 8);
    glue_align_next_offset(ctx);
    if (glue_binop_rax_frame_spill_push(home) != 0)
      return -1;
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta) != 0)
      return -1;
    return 0;
  }
}

/* wave149 cold twin glue_binop_restore_rax_after_rbx_load_elf_c. PLATFORM: SHARED. */
int32_t glue_binop_restore_rax_after_rbx_load_elf_c(void *elf_ctx, int32_t ta) {
  if (ta != 1)
    return backend_enc_pop_rax_arch(elf_ctx, ta);
  {
    int32_t home;
    if (!elf_ctx || glue_binop_rax_frame_spill_depth() <= 0)
      return -1;
    home = glue_binop_rax_frame_spill_pop();
    if (home < 0)
      return -1;
    return backend_enc_load_rbp_to_rax_arch(elf_ctx, home, ta);
  }
}

/* wave149 cold twin glue_try_binop_commutative_var_var_slot_cached_elf_c. PLATFORM: SHARED. */
int32_t glue_try_binop_commutative_var_var_slot_cached_elf_c(void *arena, void *elf_ctx, int32_t left_ref, int32_t right_ref, void *ctx, int32_t ta) {
  int32_t loff;
  int32_t roff;
  int32_t rax_hit_l;
  int32_t rax_hit_r;
  int32_t rbx_hit_l;
  int32_t rbx_hit_r;
  if (!arena || !elf_ctx || !ctx)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, left_ref) != 3 ||
      pipeline_expr_kind_ord_at(arena, right_ref) != 3)
    return -2;
  loff = glue_var_expr_stack_off_elf_c(arena, ctx, left_ref);
  roff = glue_var_expr_stack_off_elf_c(arena, ctx, right_ref);
  if (loff < 0 || roff < 0)
    return -2;
  if (glue_binop_var_slot_cache_ctx_matches(ctx) == 0)
    return -2;
  rax_hit_l = (glue_binop_var_slot_cache_valid_rax_get() != 0 && glue_binop_var_slot_cache_rax_off_get() == loff);
  rax_hit_r = (glue_binop_var_slot_cache_valid_rax_get() != 0 && glue_binop_var_slot_cache_rax_off_get() == roff);
  rbx_hit_l = (glue_binop_var_slot_cache_valid_rbx_get() != 0 && glue_binop_var_slot_cache_rbx_off_get() == loff);
  rbx_hit_r = (glue_binop_var_slot_cache_valid_rbx_get() != 0 && glue_binop_var_slot_cache_rbx_off_get() == roff);
  /** 目标：rax=left(loff)，rbx=right(roff)。 */
  if (rax_hit_l && rbx_hit_r)
    return 0;
  if (rax_hit_l) {
    if (glue_try_binop_load_operand_elf_c(arena, elf_ctx, right_ref, ctx, ta, 1) != 0)
      return -1;
    return 0;
  }
  if (rbx_hit_r) {
    if (glue_try_binop_load_operand_elf_c(arena, elf_ctx, left_ref, ctx, ta, 0) != 0)
      return -1;
    return 0;
  }
  /** 左操作数已在 rbx（如上一笔 a+b 后 b+a 的 b）。 */
  if (rbx_hit_l) {
    if (glue_try_binop_load_operand_elf_c(arena, elf_ctx, left_ref, ctx, ta, 1) != 0)
      return -1;
    if (glue_try_binop_load_operand_elf_c(arena, elf_ctx, right_ref, ctx, ta, 0) != 0)
      return -1;
    if (glue_enc_swap_rax_rbx_arm64_elf_c(elf_ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_set_valid_rax(1);
    glue_binop_var_slot_cache_set_rax_off(loff);
    glue_binop_var_slot_cache_set_valid_rbx(1);
    glue_binop_var_slot_cache_set_rbx_off(roff);
    return 0;
  }
  if (rax_hit_r) {
    if (glue_try_binop_load_operand_elf_c(arena, elf_ctx, right_ref, ctx, ta, 0) != 0)
      return -1;
    if (glue_try_binop_load_operand_elf_c(arena, elf_ctx, left_ref, ctx, ta, 1) != 0)
      return -1;
    if (glue_enc_swap_rax_rbx_arm64_elf_c(elf_ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_set_valid_rax(1);
    glue_binop_var_slot_cache_set_rax_off(loff);
    glue_binop_var_slot_cache_set_valid_rbx(1);
    glue_binop_var_slot_cache_set_rbx_off(roff);
    return 0;
  }
  return -2;
}

/* wave149 cold twin glue_try_binop_commutative_rax_rbx_elf_c. PLATFORM: SHARED. */
int32_t glue_try_binop_commutative_rax_rbx_elf_c(void *arena, void *elf_ctx, int32_t left_ref, int32_t right_ref, void *ctx, int32_t ta) {
  int32_t r;
  int32_t cr;
  if (!arena || !elf_ctx || !ctx)
    return -2;
  cr = glue_try_binop_commutative_var_var_slot_cached_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
  if (cr == 0)
    return 0;
  if (cr == -1)
    return -1;
  /*
   * wave660 rbx-park guard: only take a simple-operand-first branch when the
   * opposite side cannot stage temps into rbx while being emitted. Loading
   * right->rbx first and then emitting a complex left (nested binop staging
   * a literal through backend_enc_mov_imm32_to_rbx_arch, calls, INDEX/FIELD
   * addressing) silently overwrites the parked operand: `(cn*4) + (nargs as
   * usize)` emitted cn*4+4, shifting g_call_typearg_lens rows (pure-asm
   * bound_method T001). wave338 fixed the ADD face for a bare-VAR right only;
   * this shared commutative authority covers cast-wrapped VAR operands and
   * every commutative op. Skipping falls to the left-first tail below.
   */
  if (glue_expr_emit_may_clobber_rbx_elf_c(arena, left_ref) == 0) {
    r = glue_try_binop_load_operand_elf_c(arena, elf_ctx, right_ref, ctx, ta, 1);
    if (r == 0) {
      int32_t save_rbx;
      save_rbx = glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena, left_ref);
      if (save_rbx != 0 && glue_binop_preserve_rbx_for_index_elf_c(elf_ctx, ta) != 0)
        return -1;
      r = glue_try_binop_load_operand_elf_c(arena, elf_ctx, left_ref, ctx, ta, 0);
      if (save_rbx != 0 && glue_binop_restore_rbx_after_index_elf_c(elf_ctx, ta) != 0)
        return -1;
      if (r != -2)
        return r;
    } else if (r == -1) {
      return -1;
    }
  }
  if (glue_expr_emit_may_clobber_rbx_elf_c(arena, right_ref) == 0) {
    r = glue_try_binop_load_operand_elf_c(arena, elf_ctx, left_ref, ctx, ta, 1);
    if (r == 0) {
      int32_t save_rbx;
      save_rbx = glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena, right_ref);
      if (save_rbx != 0 && glue_binop_preserve_rbx_for_index_elf_c(elf_ctx, ta) != 0)
        return -1;
      r = glue_try_binop_load_operand_elf_c(arena, elf_ctx, right_ref, ctx, ta, 0);
      if (save_rbx != 0 && glue_binop_restore_rbx_after_index_elf_c(elf_ctx, ta) != 0)
        return -1;
      if (r != -2)
        return r;
    } else if (r == -1) {
      return -1;
    }
  }
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
    return -1;
  {
    int32_t save_rax;
    save_rax = glue_binop_operand_load_to_rbx_clobbers_rax_elf_c(arena, right_ref);
    if (save_rax != 0 && glue_binop_preserve_rax_for_rbx_load_elf_c(elf_ctx, ta, ctx) != 0)
      return -1;
    r = glue_try_binop_load_operand_elf_c(arena, elf_ctx, right_ref, ctx, ta, 1);
    if (r == -1) {
      if (save_rax != 0)
        (void)glue_binop_restore_rax_after_rbx_load_elf_c(elf_ctx, ta);
      return -1;
    }
    if (r == -2) {
      if (save_rax == 0 && glue_binop_preserve_rax_for_rbx_load_elf_c(elf_ctx, ta, ctx) != 0)
        return -1;
      if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
        return -1;
      if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
        return -1;
      save_rax = 1;
    }
    if (save_rax != 0 && glue_binop_restore_rax_after_rbx_load_elf_c(elf_ctx, ta) != 0)
      return -1;
  }
  return 0;
}

/* wave149 cold twin glue_finish_binop_commutative_slow_rax_rbx_elf_c. PLATFORM: SHARED. */
int32_t glue_finish_binop_commutative_slow_rax_rbx_elf_c(void *arena, void *elf_ctx, int32_t left_ref, int32_t right_ref, void *ctx, int32_t ta) {
  glue_binop_var_slot_cache_clear();
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  return 0;
}

/* wave149 cold twin glue_try_binop_left_rax_right_rbx_elf_c. PLATFORM: SHARED. */
int32_t glue_try_binop_left_rax_right_rbx_elf_c(void *arena, void *elf_ctx, int32_t left_ref, int32_t right_ref, void *ctx, int32_t ta) {
  int32_t r;
  if (!arena || !elf_ctx || !ctx)
    return -2;
  /** 非交换：左 rax 右 rbx；FIELD/INDEX 时先装 rbx 再装 rax。 */
  r = glue_try_binop_load_operand_elf_c(arena, elf_ctx, right_ref, ctx, ta, 1);
  if (r == 0) {
    int32_t save_rbx;
    save_rbx = glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena, left_ref);
    if (save_rbx != 0 && glue_binop_preserve_rbx_for_index_elf_c(elf_ctx, ta) != 0)
      return -1;
    r = glue_try_binop_load_operand_elf_c(arena, elf_ctx, left_ref, ctx, ta, 0);
    if (save_rbx != 0 && glue_binop_restore_rbx_after_index_elf_c(elf_ctx, ta) != 0)
      return -1;
    if (r != -2)
      return r;
    {
      int32_t save_rbx_emit;
      /** 右已在 rbx；左 slow emit 可能 clobber rbx（与 cmp 右 slow emit 对称）。 */
      save_rbx_emit = glue_expr_emit_may_clobber_rbx_elf_c(arena, left_ref);
      if (save_rbx_emit != 0 && glue_binop_preserve_rbx_for_index_elf_c(elf_ctx, ta) != 0)
        return -1;
      if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
        return -1;
      if (save_rbx_emit != 0 && glue_binop_restore_rbx_after_index_elf_c(elf_ctx, ta) != 0)
        return -1;
    }
    return 0;
  } else if (r == -1) {
    return -1;
  }
  r = glue_try_binop_load_operand_elf_c(arena, elf_ctx, left_ref, ctx, ta, 0);
  if (r == 0) {
    int32_t save_rbx;
    save_rbx = glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena, right_ref);
    if (save_rbx != 0 && glue_binop_preserve_rbx_for_index_elf_c(elf_ctx, ta) != 0)
      return -1;
    r = glue_try_binop_load_operand_elf_c(arena, elf_ctx, right_ref, ctx, ta, 1);
    if (save_rbx != 0 && glue_binop_restore_rbx_after_index_elf_c(elf_ctx, ta) != 0)
      return -1;
    if (r != -2)
      return r;
    /** 左已在 rax；右 slow emit 须 x2 暂存 rax 再 mov 到 rbx。 */
    if (glue_binop_preserve_rax_for_rbx_load_elf_c(elf_ctx, ta, ctx) != 0)
      return -1;
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (glue_binop_restore_rax_after_rbx_load_elf_c(elf_ctx, ta) != 0)
      return -1;
    return 0;
  }
  if (r == -1)
    return -1;
  r = glue_try_binop_load_operand_elf_c(arena, elf_ctx, right_ref, ctx, ta, 1);
  if (r == 0) {
    int32_t save_rbx_emit;
    save_rbx_emit = glue_expr_emit_may_clobber_rbx_elf_c(arena, left_ref);
    if (save_rbx_emit != 0 && glue_binop_preserve_rbx_for_index_elf_c(elf_ctx, ta) != 0)
      return -1;
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    if (save_rbx_emit != 0 && glue_binop_restore_rbx_after_index_elf_c(elf_ctx, ta) != 0)
      return -1;
    return 0;
  }
  if (r == -1)
    return -1;
  return -2;
}

/* wave149 cold twin glue_try_binop_cmp_rbx_rax_elf_c. PLATFORM: SHARED. */
int32_t glue_try_binop_cmp_rbx_rax_elf_c(void *arena, void *elf_ctx, int32_t left_ref, int32_t right_ref, void *ctx, int32_t ta) {
  int32_t r;
  if (!arena || !elf_ctx || !ctx)
    return -2;
  r = glue_try_binop_load_operand_elf_c(arena, elf_ctx, left_ref, ctx, ta, 1);
  if (r == 0) {
    int32_t save_rbx;
    save_rbx = glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena, right_ref);
    if (save_rbx != 0 && glue_binop_preserve_rbx_for_index_elf_c(elf_ctx, ta) != 0)
      return -1;
    r = glue_try_binop_load_operand_elf_c(arena, elf_ctx, right_ref, ctx, ta, 0);
    if (save_rbx != 0 && glue_binop_restore_rbx_after_index_elf_c(elf_ctx, ta) != 0)
      return -1;
    if (r != -2)
      return r;
    {
      int32_t save_rbx_emit;
      save_rbx_emit = glue_expr_emit_may_clobber_rbx_elf_c(arena, right_ref);
      if (save_rbx_emit != 0 && glue_binop_preserve_rbx_for_index_elf_c(elf_ctx, ta) != 0)
        return -1;
      if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
        return -1;
      if (save_rbx_emit != 0 && glue_binop_restore_rbx_after_index_elf_c(elf_ctx, ta) != 0)
        return -1;
    }
    return 0;
  }
  if (r == -1)
    return -1;
  r = glue_try_binop_load_operand_elf_c(arena, elf_ctx, right_ref, ctx, ta, 0);
  if (r == 0) {
    /* emit left writes rax — drop stale "right VAR still in rax" cache hit. */
    glue_binop_var_slot_cache_invalidate_rax();
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    /* rbx now holds left (often a lit), not a cached right VAR slot. */
    glue_binop_var_slot_cache_invalidate_rbx();
    return glue_try_binop_load_operand_elf_c(arena, elf_ctx, right_ref, ctx, ta, 0);
  }
  if (r == -1)
    return -1;
  return -2;
}

/* wave149 cold twin glue_type_ref_is_scalar_f32_c. PLATFORM: SHARED. */
int32_t glue_type_ref_is_scalar_f32_c(void *arena, int32_t type_ref) {
  if (!arena || type_ref <= 0)
    return 0;
  return pipeline_type_kind_ord_at(arena, type_ref) == 14 ? 1 : 0;
}

/* wave149 cold twin glue_type_ref_is_scalar_f64_c moved to file-scope
 * leftover-PE emit_as callee OR (after truncated-cmp close). Leaving the
 * body here dual-defs !FROM_X. PLATFORM: SHARED. */

/* wave149 cold twin glue_expr_resolved_is_scalar_f32_c. PLATFORM: SHARED. */
int32_t glue_expr_resolved_is_scalar_f32_c(void *arena, int32_t expr_ref) {
  return glue_type_ref_is_scalar_f32_c(arena, pipeline_expr_resolved_type_ref(arena, expr_ref));
}

/* wave149 cold twin glue_expr_resolved_is_scalar_f64_c moved to file-scope
 * leftover-PE emit_as callee OR (after truncated-cmp close). Leaving the
 * body here dual-defs !FROM_X. PLATFORM: SHARED. */

/* wave149 cold twin glue_binop_operand_is_scalar_f32_elf_c. PLATFORM: SHARED. */
int32_t glue_binop_operand_is_scalar_f32_elf_c(void *arena, void *ctx, int32_t expr_ref) {
  int32_t ko;
  int32_t tr;
  int32_t base_ref;
  if (!arena || expr_ref <= 0)
    return 0;
  if (glue_expr_resolved_is_scalar_f32_c(arena, expr_ref))
    return 1;
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ko == 3 && ctx) {
    tr = glue_var_decl_type_ref_elf_c(arena, ctx, expr_ref);
    return glue_type_ref_is_scalar_f32_c(arena, tr);
  }
  /** AoS arr[i].x：FIELD_ACCESS 回落字段类型（SoA 外堆/栈 f32 列扫描须 addss）。 */
  if (ko == 44) {
    tr = glue_field_access_field_type_ref_c(arena, pipeline_asm_emit_module_ref_c(), expr_ref);
    if (glue_type_ref_is_scalar_f32_c(arena, tr))
      return 1;
    tr = pipeline_expr_resolved_type_ref(arena, expr_ref);
    return glue_type_ref_is_scalar_f32_c(arena, tr);
  }
  if (ko == 47) {
    tr = pipeline_expr_resolved_type_ref(arena, expr_ref);
    if (glue_type_ref_is_scalar_f32_c(arena, tr))
      return 1;
    if (pipeline_asm_index_elem_byte_sz_c(arena, expr_ref) != 4)
      return 0;
    base_ref = pipeline_expr_index_base_ref(arena, expr_ref);
    if (base_ref > 0 && pipeline_expr_kind_ord_at(arena, base_ref) == 44) {
      tr = glue_field_access_field_type_ref_c(arena, pipeline_asm_emit_module_ref_c(), base_ref);
      if (tr > 0 && pipeline_type_kind_ord_at(arena, tr) == 9) {
        tr = pipeline_type_elem_ref_at(arena, tr);
        return glue_type_ref_is_scalar_f32_c(arena, tr);
      }
    }
  }
  if (ko == 1)
    return glue_type_ref_is_scalar_f32_c(arena, pipeline_expr_resolved_type_ref(arena, expr_ref));
  /* CALL/METHOD_CALL: same return-kind fallback as f64 (G.7 single authority). */
  if (ko == 48 || ko == 49) {
    int32_t rk = pipeline_asm_call_return_type_kind_ord_c(arena, expr_ref);
    return rk == 14 ? 1 : 0;
  }
  /** f32 加法链：(t.x+t.y)+t.z 左子为 ADD 时 skip typeck 无 resolved_type，须递归判定。 */
  if (ko == 4) {
    int32_t lr = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    int32_t rr = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    if (lr > 0 && rr > 0 &&
        glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, lr) &&
        glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, rr))
      return 1;
  }
  return 0;
}

/* wave149 cold twin glue_binop_operand_is_scalar_f64_elf_c moved to
 * file-scope leftover-PE emit_as callee OR (after truncated-cmp close).
 * Leaving the body here dual-defs !FROM_X. PLATFORM: SHARED. */

/* wave149 cold twin glue_try_emit_mixed_f32_f64_arith_elf_c. PLATFORM: SHARED. */
int32_t glue_try_emit_mixed_f32_f64_arith_elf_c(void *arena, void *elf_ctx, void *ctx, int32_t left_ref, int32_t right_ref, int32_t ta, int32_t op_kind) {
  int32_t lf32;
  int32_t rf32;
  int32_t lf64;
  int32_t rf64;
  int32_t mixed;
  if (ta != 0 || !arena || !elf_ctx || !ctx)
    return -2;
  if (op_kind != 4 && op_kind != 5 && op_kind != 6 && op_kind != 7)
    return -2;
  lf32 = glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref);
  rf32 = glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, right_ref);
  lf64 = glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref);
  rf64 = glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, right_ref);
  /* Pure same-class: not mixed (caller uses addss/addsd/mulss/mulsd/…). */
  if (lf32 && rf32)
    return -2;
  if (lf64 && rf64 && !lf32 && !rf32)
    return -2;
  mixed = ((lf32 && rf64) || (lf64 && rf32)) ? 1 : 0;
  if (!mixed)
    return -2;

  if (op_kind == 7) {
    /* DIV: left=rax, right=rbx (matches pure f64 divsd path). */
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
      return -1;
    /* Promote f32 side(s) to f64 IEEE bits in place. */
    if (lf32) {
      if (backend_enc_cvtss2sd_rax_from_f32_bits_arch(elf_ctx, ta) != 0)
        return -1;
    }
    if (rf32) {
      if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_cvtss2sd_rax_from_f32_bits_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
        return -1;
    }
    if (backend_enc_divsd_rax_rbx_arch(elf_ctx, ta) != 0)
      return -1;
  } else {
    /* ADD/SUB/MUL: left=rbx, right=rax (wave296 mul placement). */
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    /* Promote f32 side to f64 IEEE bits (cvtss2sd authority = wave293 encoder). */
    if (lf32) {
      if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_cvtss2sd_rax_from_f32_bits_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
        return -1;
    }
    if (rf32) {
      if (backend_enc_cvtss2sd_rax_from_f32_bits_arch(elf_ctx, ta) != 0)
        return -1;
    }
    if (op_kind == 4) {
      if (backend_enc_addsd_rax_rbx_arch(elf_ctx, ta) != 0)
        return -1;
    } else if (op_kind == 5) {
      if (backend_enc_subsd_rbx_rax_arch(elf_ctx, ta) != 0)
        return -1;
    } else {
      /* op_kind == 6 MUL */
      if (backend_enc_mulsd_rax_rbx_arch(elf_ctx, ta) != 0)
        return -1;
    }
  }
  glue_binop_var_slot_cache_invalidate_rax();
  return 0;
}

/* wave149 cold twin glue_expr_type_is_ptr_c. PLATFORM: SHARED. */
int32_t glue_expr_type_is_ptr_c(void *arena, int32_t expr_ref) {
  int32_t tr;
  if (!arena || expr_ref <= 0)
    return 0;
  tr = pipeline_expr_resolved_type_ref(arena, expr_ref);
  if (tr <= 0)
    return 0;
  return pipeline_type_kind_ord_at(arena, tr) == 9 ? 1 : 0;
}

/* wave149 cold twin glue_ptr_expr_pointee_byte_sz_c. PLATFORM: SHARED. */
int32_t glue_ptr_expr_pointee_byte_sz_c(void *arena, int32_t ptr_expr_ref) {
  int32_t tr;
  int32_t esz;
  if (!arena || ptr_expr_ref <= 0)
    return 0;
  tr = pipeline_expr_resolved_type_ref(arena, ptr_expr_ref);
  if (tr <= 0 || pipeline_type_kind_ord_at(arena, tr) != 9)
    return 0;
  esz = glue_index_elem_byte_sz_from_type_ref_c(arena, tr);
  return esz > 0 ? esz : 0;
}

/* wave149 cold twin glue_ptr_arith_scale_rbx_offset_if_left_ptr_c. PLATFORM: SHARED. */
int32_t glue_ptr_arith_scale_rbx_offset_if_left_ptr_c(void *arena, void *elf_ctx, int32_t left_ref, int32_t right_ref, int32_t ta) {
  int32_t esz;
  if (!glue_expr_type_is_ptr_c(arena, left_ref))
    return 0;
  if (glue_expr_type_is_ptr_c(arena, right_ref))
    return 0;
  esz = glue_ptr_expr_pointee_byte_sz_c(arena, left_ref);
  if (esz <= 1)
    return 0;
  return backend_enc_mul_imm_to_rbx_arch(elf_ctx, esz, ta);
}

/* wave149 cold twin glue_try_emit_ptr_arith_scaled_elf_c. PLATFORM: SHARED. */
int32_t glue_try_emit_ptr_arith_scaled_elf_c(void *arena, void *elf_ctx, void *ctx, int32_t left_ref, int32_t right_ref, int32_t ta, int32_t is_sub) {
  int32_t lp;
  int32_t rp;
  int32_t ptr_ref;
  int32_t off_ref;
  int32_t esz;
  int32_t lit_imm;
  int32_t scaled;
  if (!arena || !elf_ctx || !ctx || left_ref <= 0 || right_ref <= 0)
    return -2;
  lp = glue_expr_type_is_ptr_c(arena, left_ref);
  rp = glue_expr_type_is_ptr_c(arena, right_ref);
  if (is_sub) {
    /* ptr - ptr → element count (byte diff / esz). */
    if (lp && rp) {
      esz = glue_ptr_expr_pointee_byte_sz_c(arena, left_ref);
      if (esz <= 0)
        return -1;
      if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
        return -1;
      if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
        return -1;
      if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_sub_rax_rbx_arch(elf_ctx, ta) != 0)
        return -1;
      if (esz != 1) {
        glue_binop_var_slot_cache_invalidate_rbx();
        if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, esz, ta) != 0)
          return -1;
        if (backend_enc_idiv_rbx_arch(elf_ctx, ta) != 0)
          return -1;
      }
      glue_binop_var_slot_cache_invalidate_rax();
      glue_binop_var_slot_cache_invalidate_rbx();
      return 0;
    }
    /* ptr - int only (int - ptr rejected at typeck). */
    if (!(lp && !rp))
      return -2;
    ptr_ref = left_ref;
    off_ref = right_ref;
  } else {
    /* ADD: exactly one pointer (ptr+int or int+ptr). */
    if (lp == rp)
      return -2;
    ptr_ref = lp ? left_ref : right_ref;
    off_ref = lp ? right_ref : left_ref;
  }
  esz = glue_ptr_expr_pointee_byte_sz_c(arena, ptr_ref);
  if (esz <= 0)
    return -1;
  /* ptr → rax */
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, ptr_ref, ctx, ta) != 0)
    return -1;
  glue_binop_var_slot_cache_invalidate_rax();
  /* offset → rbx, pre-scale when literal (avoid imul on 1*esz). */
  if (pipeline_asm_expr_lit_i32_at_c(arena, off_ref, &lit_imm)) {
    scaled = lit_imm;
    if (esz != 1) {
      /* Small probes; overflow → still best-effort int32 product. */
      scaled = lit_imm * esz;
    }
    glue_binop_var_slot_cache_invalidate_rbx();
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, scaled, ta) != 0)
      return -1;
  } else {
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, off_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (esz > 1 && backend_enc_mul_imm_to_rbx_arch(elf_ctx, esz, ta) != 0)
      return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
      return -1;
  }
  if (is_sub) {
    /* ptr-int / ptr-ptr: x86 REX.W sub is 64-bit; arm64 enc_sub is 32-bit W
     * residual for large offsets. PLATFORM: SHARED. */
    if (backend_enc_sub_rax_rbx_arch(elf_ctx, ta) != 0)
      return -1;
  } else {
    /* Stage 12.0.5 root: ptr+int must use 64-bit ADD (scale1), NOT 32-bit
     * backend_enc_add_rax_rbx_arch (arm64 ADD W truncates Darwin pointers →
     * pure-asm hybrid runtime_io_abi `buf + off` IO001). G.7 有则补全 twin of
     * .x glue_try_emit_ptr_arith_scaled. PLATFORM: SHARED. */
    if (backend_enc_rax_plus_rbx_scale1_arch(elf_ctx, ta) != 0)
      return -1;
  }
  glue_binop_var_slot_cache_invalidate_rax();
  return 0;
}

/*
 * wave149 cold twin glue_emit_binop_add_rax_rbx_elf_c.
 * Stage 12.0.5: usize/i64/u64/isize/ptr → 64-bit ADD (rax_plus_rbx_scale1);
 * i32/u32 remain 32-bit ADD W. Matches pure: path_last_sep base+off must not
 * truncate Darwin pointers. PLATFORM: SHARED.
 */
int32_t glue_emit_binop_add_rax_rbx_elf_c(void *arena, void *elf_ctx, void *ctx, int32_t left_ref, int32_t right_ref, int32_t ta) {
  int32_t is_64bit;
  if ((ta == 0 || ta == 1) && glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref) &&
      glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, right_ref))
    return backend_enc_addsd_rax_rbx_arch(elf_ctx, ta);
  if ((ta == 0 || ta == 1) && glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref) &&
      glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, right_ref))
    return backend_enc_addss_rax_rbx_arch(elf_ctx, ta);
  /* wave642: assign `p += n` — left@rax right@rbx; scale integer offset. */
  if (glue_ptr_arith_scale_rbx_offset_if_left_ptr_c(arena, elf_ctx, left_ref, right_ref, ta) != 0)
    return -1;
  is_64bit = glue_binop_operand_is_64bit_elf_c(arena, ctx, left_ref, right_ref);
  if (is_64bit)
    return backend_enc_rax_plus_rbx_scale1_arch(elf_ctx, ta);
  return backend_enc_add_rax_rbx_arch(elf_ctx, ta);
}

/* wave149 cold twin pipeline_asm_emit_binop_add_elf_c. PLATFORM: SHARED. */
int32_t pipeline_asm_emit_binop_add_elf_c(void *arena, void *elf_ctx, int32_t left_ref, int32_t right_ref, void *ctx, int32_t ta) {
  int32_t lit_imm;
  int32_t vr;
  int32_t inl;
  int32_t mixed_rc;
  int32_t ptr_rc;
  /**
   * wave297: mixed f32+f64 before commutative/left-assoc (placement not fixed there).
   * Promote f32 side (cvtss2sd) then addsd; typeck result is f64 (f64-before-f32).
   */
  mixed_rc = glue_try_emit_mixed_f32_f64_arith_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta, 4);
  if (mixed_rc == 0)
    return 0;
  if (mixed_rc == -1)
    return -1;
  /**
   * wave642: ptr+int / int+ptr with C pointee scale before integer lit/var paths
   * (those paths raw-add byte offsets).
   */
  ptr_rc = glue_try_emit_ptr_arith_scaled_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta, 0);
  if (ptr_rc == 0)
    return 0;
  if (ptr_rc == -1)
    return -1;
  /** WPO-S3：p.a + p.b 同 VAR 字段求和（cross_ret 等 import struct）。 */
  inl = try_inline_var_field_sum_binop_elf(arena, elf_ctx, left_ref, right_ref, ctx, ta);
  if (inl != 0)
    return inl < 0 ? -1 : 0;
  if (pipeline_asm_expr_lit_i32_at_c(arena, left_ref, &lit_imm)) {
    /** 先 emit 右子树再装左字面量到 w1，避免嵌套 MUL 等把 w1 覆盖（如 1+2*3）。 */
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rbx();
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    if (glue_emit_binop_add_rax_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    return 0;
  }
  if (pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm)) {
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rbx();
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    if (glue_emit_binop_add_rax_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    return 0;
  }
  /**
   * 7.3 / wave338: left-assoc dual-slot when right is VAR and left may clobber rbx.
   * Emit left fully (result@rax) then load right@rbx — never leave a stale
   * binop slot-cache hit on rbx after nested mul/sub/… mov_imm→rbx.
   *
   * Prior gate was only left ADD/SUB (same-op chains). Missed cross-op
   * `(n*100)+v`: commutative loaded v→rbx, nested mul did `mov $100,%ebx`
   * without invalidate, cache still claimed rbx=v → Ubuntu freestanding
   * `add %rbx,%rax` used 100 → run=200 (expect 120). Host-C / arm64 hid.
   *
   * Authority (G.7): single left-first path for any left that
   * glue_expr_emit_may_clobber_rbx_elf_c (nested binop/call/index/…); pure
   * VAR+VAR still uses commutative cache path below.
   * PLATFORM: SHARED freestanding emit; LINUX x86_64 exposes; MACOS arm64 may hide.
   */
  if (pipeline_expr_kind_ord_at(arena, right_ref) == 3 &&
      glue_expr_emit_may_clobber_rbx_elf_c(arena, left_ref) != 0) {
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    glue_binop_var_slot_cache_invalidate_rbx();
    glue_asm73_left_assoc_spill_rbx_before_var_load_elf_c(arena, ctx, right_ref, ta, elf_ctx);
    if (glue_try_binop_load_operand_elf_c(arena, elf_ctx, right_ref, ctx, ta, 1) != 0)
      return -1;
    if (glue_emit_binop_add_rax_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    return 0;
  }
  vr = glue_try_binop_commutative_rax_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
  if (vr == 0) {
    if (glue_emit_binop_add_rax_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    return 0;
  }
  if (vr == -1)
    return -1;
  if (glue_finish_binop_commutative_slow_rax_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta) != 0)
    return -1;
  if (glue_emit_binop_add_rax_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta) != 0)
    return -1;
  glue_binop_var_slot_cache_invalidate_rax();
  return 0;
}

/* wave149 cold twin glue_emit_binop_sub_rbx_minus_rax_elf_c. PLATFORM: SHARED.
 * P0-4: skip trailing sxt when 64-bit (pure leave twin). */
int32_t glue_emit_binop_sub_rbx_minus_rax_elf_c(void *arena, void *elf_ctx, void *ctx, int32_t left_ref, int32_t right_ref, int32_t ta) {
  int32_t rc;
  int32_t is_64bit = 0;
  if ((ta == 0 || ta == 1) && glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref) &&
      glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, right_ref))
    return backend_enc_subsd_rbx_rax_arch(elf_ctx, ta);
  if ((ta == 0 || ta == 1) && glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref) &&
      glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, right_ref))
    return backend_enc_subss_rbx_rax_arch(elf_ctx, ta);
  is_64bit = glue_binop_operand_is_64bit_elf_c(arena, ctx, left_ref, right_ref);
  if (is_64bit && ta == 1) {
    static const uint8_t subx[4] = {0x20, 0x00, 0x00, 0xcb};
    rc = pipeline_elf_ctx_append_bytes(elf_ctx, (uint8_t *)subx, 4);
  } else {
    rc = backend_enc_sub_rbx_rax_then_mov_arch(elf_ctx, ta);
  }
  if (rc != 0)
    return rc;
  if (is_64bit)
    return 0;
  return 0; /* seed cold: no maybe_sxt face; pure leave owns sxt */
}

/* wave149 cold twin glue_emit_binop_sub_rax_minus_rbx_elf_c. PLATFORM: SHARED.
 * P0-4: 64-bit SUB when wide lit / i64; ban 32-bit subl + cdqe class. */
int32_t glue_emit_binop_sub_rax_minus_rbx_elf_c(void *arena, void *elf_ctx, void *ctx, int32_t left_ref, int32_t right_ref, int32_t ta) {
  int32_t rc;
  int32_t is_64bit = 0;
  if ((ta == 0 || ta == 1) && glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref) &&
      glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, right_ref))
    return backend_enc_subsd_rax_rbx_arch(elf_ctx, ta);
  if ((ta == 0 || ta == 1) && glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref) &&
      glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, right_ref))
    return backend_enc_subss_rax_rbx_arch(elf_ctx, ta);
  if (glue_ptr_arith_scale_rbx_offset_if_left_ptr_c(arena, elf_ctx, left_ref, right_ref, ta) != 0)
    return -1;
  is_64bit = glue_binop_operand_is_64bit_elf_c(arena, ctx, left_ref, right_ref);
  if (is_64bit) {
    if (ta == 0) {
      static const uint8_t subq[3] = {0x48, 0x29, 0xd8};
      rc = pipeline_elf_ctx_append_bytes(elf_ctx, (uint8_t *)subq, 3);
    } else if (ta == 1) {
      static const uint8_t subx[4] = {0x00, 0x00, 0x01, 0xcb};
      rc = pipeline_elf_ctx_append_bytes(elf_ctx, (uint8_t *)subx, 4);
    } else {
      rc = backend_enc_sub_rax_rbx_arch(elf_ctx, ta);
    }
  } else {
    rc = backend_enc_sub_rax_rbx_arch(elf_ctx, ta);
  }
  if (rc != 0)
    return rc;
  if (is_64bit)
    return 0;
  return 0; /* seed cold: pure leave owns i32 sxt */
}

/* wave149 cold twin glue_emit_binop_mul_rax_rbx_elf_c. PLATFORM: SHARED. */
int32_t glue_emit_binop_mul_rax_rbx_elf_c(void *arena, void *elf_ctx, void *ctx, int32_t left_ref, int32_t right_ref, int32_t ta) {
  if ((ta == 0 || ta == 1) && glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref) &&
      glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, right_ref))
    return backend_enc_mulsd_rax_rbx_arch(elf_ctx, ta);
  if ((ta == 0 || ta == 1) && glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref) &&
      glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, right_ref))
    return backend_enc_mulss_rax_rbx_arch(elf_ctx, ta);
  return backend_enc_imul_rbx_rax_arch(elf_ctx, ta);
}

/* wave149 cold twin pipeline_asm_emit_binop_sub_elf_c. PLATFORM: SHARED. */
int32_t pipeline_asm_emit_binop_sub_elf_c(void *arena, void *elf_ctx, int32_t left_ref, int32_t right_ref, void *ctx, int32_t ta) {
  int32_t lit_imm;
  int32_t mixed_rc;
  int32_t ptr_rc;
  /**
   * wave297: mixed f32-f64 / f64-f32 before lit/var paths (placement not fixed there).
   * Promote f32 side then subsd_rbx_rax (left − right); typeck result f64.
   */
  mixed_rc = glue_try_emit_mixed_f32_f64_arith_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta, 5);
  if (mixed_rc == 0)
    return 0;
  if (mixed_rc == -1)
    return -1;
  /**
   * wave642: ptr-int (scale) / ptr-ptr (byte diff / esz) before integer lit/var paths.
   */
  ptr_rc = glue_try_emit_ptr_arith_scaled_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta, 1);
  if (ptr_rc == 0)
    return 0;
  if (ptr_rc == -1)
    return -1;
  /** 左字面量：先 emit 右子树，再 rbx=左立即数，结果 rbx-rax（如 42-i）。 */
  if (pipeline_asm_expr_lit_i32_at_c(arena, left_ref, &lit_imm)) {
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
      return -1;
    /* wave338: imm→rbx clobbers dual-slot cache. */
    glue_binop_var_slot_cache_invalidate_rbx();
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    return glue_emit_binop_sub_rbx_minus_rax_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta);
  }
  /** 右字面量：rax=左子树，rbx=立即数，结果 rax-rbx（如 i-1）。 */
  if (pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm)) {
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    /* wave338: imm→rbx clobbers dual-slot cache. */
    glue_binop_var_slot_cache_invalidate_rbx();
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    return glue_emit_binop_sub_rax_minus_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta);
  }
  {
    int32_t loff;
    int32_t roff;
    loff = glue_var_expr_stack_off_elf_c(arena, ctx, left_ref);
    roff = glue_var_expr_stack_off_elf_c(arena, ctx, right_ref);
    if (loff >= 0 && roff >= 0) {
      if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, loff, ta) != 0)
        return -1;
      if (backend_enc_load_rbp_to_rax_arch(elf_ctx, roff, ta) != 0)
        return -1;
      return glue_emit_binop_sub_rbx_minus_rax_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta);
    }
    if (loff >= 0) {
      /** 左 VAR、右复合：先 emit 右子树到 rax，再 rax=i、rbx=右，sub rax-rbx（如 i-(j+k)）。 */
      if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
        return -1;
      glue_binop_var_slot_cache_invalidate_rax();
      glue_binop_var_slot_cache_invalidate_rbx();
      if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_load_rbp_to_rax_arch(elf_ctx, loff, ta) != 0)
        return -1;
      return glue_emit_binop_sub_rax_minus_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta);
    }
    if (roff >= 0) {
      if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
        return -1;
      if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_load_rbp_to_rax_arch(elf_ctx, roff, ta) != 0)
        return -1;
      return glue_emit_binop_sub_rbx_minus_rax_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta);
    }
  }
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  return glue_emit_binop_sub_rbx_minus_rax_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta);
}

/* wave149 cold twin pipeline_asm_emit_binop_mul_elf_c. PLATFORM: SHARED. */
int32_t pipeline_asm_emit_binop_mul_elf_c(void *arena, void *elf_ctx, int32_t left_ref, int32_t right_ref, void *ctx, int32_t ta) {
  int32_t lit_imm;
  int32_t vr;
  int32_t mixed_rc;
  /**
   * wave296/wave297: mixed f32*f64 before commutative/left-assoc (placement not fixed there).
   * Promote f32 side (cvtss2sd) then mulsd; typeck result is f64 (f64-before-f32).
   * Authority: glue_try_emit_mixed_f32_f64_arith_elf_c (G.7 complete arith leaf).
   */
  mixed_rc = glue_try_emit_mixed_f32_f64_arith_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta, 6);
  if (mixed_rc == 0)
    return 0;
  if (mixed_rc == -1)
    return -1;
  /**
   * Integer lit fast path only when neither side is scalar f32/f64
   * (else mulss/mulsd need full IEEE bits in GPRs).
   */
  if (pipeline_asm_expr_lit_i32_at_c(arena, left_ref, &lit_imm) &&
      !(glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref) ||
        glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, right_ref) ||
        glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref) ||
        glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, right_ref))) {
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
      return -1;
    /* wave338: imm→rbx clobbers dual-slot; drop stale VAR cache (G.7 with add lit path). */
    glue_binop_var_slot_cache_invalidate_rbx();
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    if (glue_emit_binop_mul_rax_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    return 0;
  }
  if (pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm) &&
      !(glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref) ||
        glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, right_ref) ||
        glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref) ||
        glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, right_ref))) {
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    /* wave338: imm→rbx clobbers dual-slot; drop stale VAR cache (G.7 with add lit path). */
    glue_binop_var_slot_cache_invalidate_rbx();
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    if (glue_emit_binop_mul_rax_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    return 0;
  }
  /**
   * 7.3 / wave338: left-assoc mul when right is VAR and left may clobber rbx.
   * Same cross-op rule as add (e.g. (a+b)*c); same-op ((…)*VAR) included.
   */
  if (pipeline_expr_kind_ord_at(arena, right_ref) == 3 &&
      glue_expr_emit_may_clobber_rbx_elf_c(arena, left_ref) != 0) {
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    glue_binop_var_slot_cache_invalidate_rbx();
    glue_asm73_left_assoc_spill_rbx_before_var_load_elf_c(arena, ctx, right_ref, ta, elf_ctx);
    if (glue_try_binop_load_operand_elf_c(arena, elf_ctx, right_ref, ctx, ta, 1) != 0)
      return -1;
    if (glue_emit_binop_mul_rax_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    return 0;
  }
  vr = glue_try_binop_commutative_rax_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
  if (vr == 0) {
    if (glue_emit_binop_mul_rax_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    return 0;
  }
  if (vr == -1)
    return -1;
  if (glue_finish_binop_commutative_slow_rax_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta) != 0)
    return -1;
  if (glue_emit_binop_mul_rax_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta) != 0)
    return -1;
  glue_binop_var_slot_cache_invalidate_rax();
  return 0;
}

/* wave149 cold twin glue_binop_operand_is_unsigned_elf_c. PLATFORM: SHARED. */
int32_t glue_binop_operand_is_unsigned_elf_c(void *arena, void *ctx, int32_t left_ref, int32_t right_ref) {
  int32_t tr = 0;
  int32_t kind_ord;
  if (!arena)
    return 0;
  if (left_ref > 0) {
    tr = pipeline_expr_resolved_type_ref(arena, left_ref);
    if (tr <= 0 && ctx)
      tr = glue_var_decl_type_ref_elf_c(arena, ctx, left_ref);
  }
  if (tr <= 0 && right_ref > 0) {
    tr = pipeline_expr_resolved_type_ref(arena, right_ref);
    if (tr <= 0 && ctx)
      tr = glue_var_decl_type_ref_elf_c(arena, ctx, right_ref);
  }
  if (tr <= 0)
    return 0;
  kind_ord = pipeline_type_kind_ord_at(arena, tr);
  /* TYPE_U8=2, TYPE_U32=3, TYPE_U64=4, TYPE_USIZE=6 */
  if (kind_ord == 2 || kind_ord == 3 || kind_ord == 4 || kind_ord == 6)
    return 1;
  return 0;
}

/* P0-4: wide INT_LIT outside i32. PLATFORM: SHARED. */
static int32_t glue_binop_expr_is_wide_int_lit_elf_c(void *arena, int32_t expr_ref) {
  int32_t ko;
  int64_t v64;
  if (!arena || expr_ref <= 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  /* EXPR_LIT = 0 */
  if (ko != 0)
    return 0;
  v64 = pipeline_expr_int64_val_at(arena, expr_ref);
  if (v64 < (int64_t)INT32_MIN || v64 > (int64_t)INT32_MAX)
    return 1;
  return 0;
}

/* wave149 cold twin glue_binop_operand_is_64bit_elf_c. PLATFORM: SHARED.
 * P0-4: also wide INT_LIT + nested ADD..BITXOR that inherit 64-bit width. */
int32_t glue_binop_operand_is_64bit_elf_c(void *arena, void *ctx, int32_t left_ref, int32_t right_ref) {
  int32_t tr = 0;
  int32_t kind_ord;
  int32_t ko;
  int32_t l;
  int32_t r;
  if (!arena)
    return 0;
  if (left_ref > 0) {
    tr = pipeline_expr_resolved_type_ref(arena, left_ref);
    if (tr <= 0 && ctx)
      tr = glue_var_decl_type_ref_elf_c(arena, ctx, left_ref);
  }
  if (tr <= 0 && right_ref > 0) {
    tr = pipeline_expr_resolved_type_ref(arena, right_ref);
    if (tr <= 0 && ctx)
      tr = glue_var_decl_type_ref_elf_c(arena, ctx, right_ref);
  }
  if (tr > 0) {
    kind_ord = pipeline_type_kind_ord_at(arena, tr);
    /* TYPE_U64=4, TYPE_I64=5, TYPE_USIZE=6, TYPE_ISIZE=7, TYPE_PTR=9 */
    if (kind_ord == 4 || kind_ord == 5 || kind_ord == 6 || kind_ord == 7 || kind_ord == 9)
      return 1;
  }
  if (glue_binop_expr_is_wide_int_lit_elf_c(arena, left_ref))
    return 1;
  if (glue_binop_expr_is_wide_int_lit_elf_c(arena, right_ref))
    return 1;
  if (left_ref > 0) {
    ko = pipeline_expr_kind_ord_at(arena, left_ref);
    if (ko >= 4 && ko <= 13) {
      l = pipeline_expr_binop_left_ref_at(arena, left_ref);
      r = pipeline_expr_binop_right_ref_at(arena, left_ref);
      if (glue_binop_operand_is_64bit_elf_c(arena, ctx, l, r))
        return 1;
    }
  }
  if (right_ref > 0) {
    ko = pipeline_expr_kind_ord_at(arena, right_ref);
    if (ko >= 4 && ko <= 13) {
      l = pipeline_expr_binop_left_ref_at(arena, right_ref);
      r = pipeline_expr_binop_right_ref_at(arena, right_ref);
      if (glue_binop_operand_is_64bit_elf_c(arena, ctx, l, r))
        return 1;
    }
  }
  return 0;
}

/* wave149 cold twin pipeline_asm_emit_binop_div_elf_c. PLATFORM: SHARED. */
int32_t pipeline_asm_emit_binop_div_elf_c(void *arena, void *elf_ctx, int32_t left_ref, int32_t right_ref, void *ctx, int32_t ta) {
  int32_t lit_imm;
  int32_t vr;
  int32_t is_unsigned;
  int32_t mixed_rc;
  /**
   * wave297: mixed f32/f64 before pure-f64/f32 or integer idiv.
   * Promote f32 then divsd; no integer div-zero panic (IEEE Inf/NaN).
   */
  mixed_rc = glue_try_emit_mixed_f32_f64_arith_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta, 7);
  if (mixed_rc == 0)
    return 0;
  if (mixed_rc == -1)
    return -1;
  /** PLATFORM: SHARED — f64 / must use IEEE divsd, not idiv of bit patterns (same residual as mulsd).
   * Skip integer lit imm32 path (truncates float bits) and integer div-zero panic (IEEE → Inf/NaN). */
  if ((ta == 0 || ta == 1) && glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref) &&
      glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, right_ref)) {
    vr = glue_try_binop_left_rax_right_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
    if (vr == -1)
      return -1;
    if (vr == 0)
      return backend_enc_divsd_rax_rbx_arch(elf_ctx, ta);
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
      return -1;
    return backend_enc_divsd_rax_rbx_arch(elf_ctx, ta);
  }
  /**
   * wave298 Cap residual pure: pure f32 `/` → divss (not idiv of IEEE bits).
   * Placement left=rax right=rbx matches pure f64 divsd path. IEEE Inf/NaN on /0.
   * G.7: complete f32 scalar arith next to mulss/addss/subss.
   */
  if ((ta == 0 || ta == 1) && glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref) &&
      glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, right_ref)) {
    vr = glue_try_binop_left_rax_right_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
    if (vr == -1)
      return -1;
    if (vr == 0)
      return backend_enc_divss_rax_rbx_arch(elf_ctx, ta);
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
      return -1;
    return backend_enc_divss_rax_rbx_arch(elf_ctx, ta);
  }
  is_unsigned = glue_binop_operand_is_unsigned_elf_c(arena, ctx, left_ref, right_ref);
  if (pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm)) {
    if (lit_imm == 0)
      return pipeline_asm_emit_panic_int_div_zero_elf_c(elf_ctx, ta);
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rbx();
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    /* idiv leaves quotient in rax — drop slot-cache (sibling a%b must reload). */
    if ((is_unsigned ? backend_enc_div_rbx_arch(elf_ctx, ta) : backend_enc_idiv_rbx_arch(elf_ctx, ta)) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    glue_binop_var_slot_cache_invalidate_rbx();
    return 0;
  }
  vr = glue_try_binop_left_rax_right_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
  if (vr == -1)
    return -1;
  if (vr == 0) {
    if (pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx, ctx, ta) != 0)
      return -1;
    if ((is_unsigned ? backend_enc_div_rbx_arch(elf_ctx, ta) : backend_enc_idiv_rbx_arch(elf_ctx, ta)) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    glue_binop_var_slot_cache_invalidate_rbx();
    return 0;
  }
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx, ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if ((is_unsigned ? backend_enc_div_rbx_arch(elf_ctx, ta) : backend_enc_idiv_rbx_arch(elf_ctx, ta)) != 0)
    return -1;
  glue_binop_var_slot_cache_invalidate_rax();
  glue_binop_var_slot_cache_invalidate_rbx();
  return 0;
}

/* wave149 cold twin pipeline_asm_emit_binop_and_elf_c. PLATFORM: SHARED. */
int32_t pipeline_asm_emit_binop_and_elf_c(void *arena, void *elf_ctx, int32_t left_ref, int32_t right_ref, void *ctx, int32_t ta) {
  int32_t lit_imm;
  int32_t vr;
  if (pipeline_asm_expr_lit_i32_at_c(arena, left_ref, &lit_imm)) {
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rbx();
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    if (backend_enc_and_rbx_rax_arch(elf_ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    return 0;
  }
  if (pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm)) {
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rbx();
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    if (backend_enc_and_rbx_rax_arch(elf_ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    return 0;
  }
  /** 7.3 / wave338: left-assoc & when right is VAR and left may clobber rbx. */
  if (pipeline_expr_kind_ord_at(arena, right_ref) == 3 &&
      glue_expr_emit_may_clobber_rbx_elf_c(arena, left_ref) != 0) {
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    glue_binop_var_slot_cache_invalidate_rbx();
    glue_asm73_left_assoc_spill_rbx_before_var_load_elf_c(arena, ctx, right_ref, ta, elf_ctx);
    if (glue_try_binop_load_operand_elf_c(arena, elf_ctx, right_ref, ctx, ta, 1) != 0)
      return -1;
    if (backend_enc_and_rbx_rax_arch(elf_ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    return 0;
  }
  vr = glue_try_binop_commutative_rax_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
  if (vr == 0) {
    if (backend_enc_and_rbx_rax_arch(elf_ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    return 0;
  }
  if (vr == -1)
    return -1;
  if (glue_finish_binop_commutative_slow_rax_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_and_rbx_rax_arch(elf_ctx, ta) != 0)
    return -1;
  glue_binop_var_slot_cache_invalidate_rax();
  return 0;
}

/* wave149 cold twin pipeline_asm_emit_binop_bitwise_elf_c. PLATFORM: SHARED. */
int32_t pipeline_asm_emit_binop_bitwise_elf_c(void *arena, void *elf_ctx, int32_t left_ref, int32_t right_ref, void *ctx, int32_t ta, int32_t is_xor) {
  int32_t lit_imm;
  int32_t vr;
  if (pipeline_asm_expr_lit_i32_at_c(arena, left_ref, &lit_imm)) {
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rbx();
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    if (is_xor) {
      if (backend_enc_xor_rbx_rax_arch(elf_ctx, ta) != 0)
        return -1;
    } else if (backend_enc_or_rbx_rax_arch(elf_ctx, ta) != 0) {
      return -1;
    }
    glue_binop_var_slot_cache_invalidate_rax();
    return 0;
  }
  if (pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm)) {
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rbx();
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    if (is_xor) {
      if (backend_enc_xor_rbx_rax_arch(elf_ctx, ta) != 0)
        return -1;
    } else if (backend_enc_or_rbx_rax_arch(elf_ctx, ta) != 0) {
      return -1;
    }
    glue_binop_var_slot_cache_invalidate_rax();
    return 0;
  }
  /** 7.3 / wave338: left-assoc |/^ when right is VAR and left may clobber rbx. */
  if (pipeline_expr_kind_ord_at(arena, right_ref) == 3 &&
      glue_expr_emit_may_clobber_rbx_elf_c(arena, left_ref) != 0) {
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    glue_binop_var_slot_cache_invalidate_rbx();
    glue_asm73_left_assoc_spill_rbx_before_var_load_elf_c(arena, ctx, right_ref, ta, elf_ctx);
    if (glue_try_binop_load_operand_elf_c(arena, elf_ctx, right_ref, ctx, ta, 1) != 0)
      return -1;
    if (is_xor) {
      if (backend_enc_xor_rbx_rax_arch(elf_ctx, ta) != 0)
        return -1;
    } else if (backend_enc_or_rbx_rax_arch(elf_ctx, ta) != 0) {
      return -1;
    }
    glue_binop_var_slot_cache_invalidate_rax();
    return 0;
  }
  vr = glue_try_binop_commutative_rax_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
  if (vr == 0) {
    if (is_xor) {
      if (backend_enc_xor_rbx_rax_arch(elf_ctx, ta) != 0)
        return -1;
    } else if (backend_enc_or_rbx_rax_arch(elf_ctx, ta) != 0) {
      return -1;
    }
    glue_binop_var_slot_cache_invalidate_rax();
    return 0;
  }
  if (vr == -1)
    return -1;
  glue_binop_var_slot_cache_clear();
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (is_xor) {
    if (backend_enc_xor_rbx_rax_arch(elf_ctx, ta) != 0)
      return -1;
  } else if (backend_enc_or_rbx_rax_arch(elf_ctx, ta) != 0) {
    return -1;
  }
  glue_binop_var_slot_cache_clear();
  return 0;
}

/* wave149 cold twin pipeline_asm_emit_binop_shift_elf_c. PLATFORM: SHARED. */
int32_t pipeline_asm_emit_binop_shift_elf_c(void *arena, void *elf_ctx, int32_t left_ref, int32_t right_ref, void *ctx, int32_t ta, int32_t op) {
  int32_t lit_imm;
  int32_t vr;
  int32_t is_64bit;
  int32_t is_unsigned;
  /* i64/u64/usize/isize/ptr need 64-bit shift forms (REX.W / sf=1). */
  is_64bit = glue_binop_operand_is_64bit_elf_c(arena, ctx, left_ref, right_ref);
  /* Left operand width decides arithmetic vs logical right shift. */
  is_unsigned = glue_binop_operand_is_unsigned_elf_c(arena, ctx, left_ref, right_ref);
  if (pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm)) {
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rbx();
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
  } else {
    vr = glue_try_binop_left_rax_right_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
    if (vr == -1)
      return -1;
    if (vr == -2) {
      if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
        return -1;
      if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
        return -1;
      if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
        return -1;
    }
  }
  glue_binop_var_slot_cache_clear();
  if (backend_enc_mov_rbx_to_ecx_arch(elf_ctx, ta) != 0)
    return -1;
  if (op == 0)
    return is_64bit ? backend_enc_shl_cl_rax_arch(elf_ctx, ta) : backend_enc_shl_cl_eax_arch(elf_ctx, ta);
  /* op==1 right shift: signed arithmetic, unsigned logical. */
  if (is_unsigned)
    return is_64bit ? backend_enc_shr_cl_rax_arch(elf_ctx, ta) : backend_enc_shr_cl_eax_arch(elf_ctx, ta);
  return is_64bit ? backend_enc_sar_cl_rax_arch(elf_ctx, ta) : backend_enc_sar_cl_eax_arch(elf_ctx, ta);
}

/* wave149 cold twin pipeline_asm_emit_binop_mod_elf_c. PLATFORM: SHARED. */
int32_t pipeline_asm_emit_binop_mod_elf_c(void *arena, void *elf_ctx, int32_t left_ref, int32_t right_ref, void *ctx, int32_t ta) {
  int32_t lit_imm;
  int32_t vr;
  int32_t is_unsigned;
  is_unsigned = glue_binop_operand_is_unsigned_elf_c(arena, ctx, left_ref, right_ref);
  if (pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm)) {
    if (lit_imm == 0)
      return pipeline_asm_emit_panic_int_div_zero_elf_c(elf_ctx, ta);
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rbx();
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    /* rem leaves remainder in rax — drop slot-cache (twin of div). */
    if ((is_unsigned ? backend_enc_rem_mod_unsigned_arch(elf_ctx, ta) : backend_enc_rem_mod_arch(elf_ctx, ta)) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    glue_binop_var_slot_cache_invalidate_rbx();
    return 0;
  }
  vr = glue_try_binop_left_rax_right_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
  if (vr == -1)
    return -1;
  if (vr == 0) {
    if (pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx, ctx, ta) != 0)
      return -1;
    if ((is_unsigned ? backend_enc_rem_mod_unsigned_arch(elf_ctx, ta) : backend_enc_rem_mod_arch(elf_ctx, ta)) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    glue_binop_var_slot_cache_invalidate_rbx();
    return 0;
  }
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx, ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if ((is_unsigned ? backend_enc_rem_mod_unsigned_arch(elf_ctx, ta) : backend_enc_rem_mod_arch(elf_ctx, ta)) != 0)
    return -1;
  glue_binop_var_slot_cache_invalidate_rax();
  glue_binop_var_slot_cache_invalidate_rbx();
  return 0;
}


/* ========================================================================
 * wave151 cold twins: pipeline_asm_emit_field_access pure-owned leave.
 * Faithful C bodies under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * PLATFORM: SHARED freestanding emit · LINUX gold · MACOS co-path.
 * ======================================================================== */

/* Cap residual BSS / helpers (same product link as residual mega-TU faces). */
extern void *g_pipeline_asm_emit_module;
extern int32_t g_pipeline_asm_emit_call_param_ty_ref;
extern int32_t g_pipeline_asm_emit_func_index;
extern int32_t g_pipeline_asm_emit_scope_block;
extern void *g_pipeline_asm_emit_dep_pipe;

/* Cap residual callees (non-static product faces). */
extern int32_t pipeline_asm_emit_call_arg_active_c(void);
extern int32_t glue_call_param_named_struct_pass_addr_elf_c(void *arena, int32_t pty);
extern int32_t glue_field_access_field_type_ref_c(void *arena, void *mod, int32_t fa_ref);
extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t ref);
extern int32_t pipeline_expr_resolved_type_ref(void *arena, int32_t expr_ref);
extern int32_t glue_type_named_layout_size_any_module_elf_c(void *arena, int32_t ty_ref);
extern int32_t glue_type_size_simple(void *m, void *a, int32_t ty_ref, int32_t depth);
extern int32_t pipeline_asm_deref_struct16_rax_ptr_elf_c(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_load_64_from_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_load_32_from_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_load_zext8_from_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_load_i32_indirect_to_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_lea_rbp_to_rax_arch(void *elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_add_imm_to_rax_arch(void *elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_mov_imm32_to_w0_arch(void *elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_mov_imm64_to_rax_arch(void *elf_ctx, int32_t lo, int32_t hi, int32_t ta);
extern int32_t backend_enc_load_rbp_to_rax_arch(void *elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_mov_rax_to_arg_reg_arch(void *elf_ctx, int32_t k, int32_t ta);
extern int32_t glue_arm64_mov_x0_to_x8_elf_c(void *elf_ctx);
extern void pipeline_asm_set_call_expected_ret_ty_c(int32_t type_ref);
extern void pipeline_asm_emit_set_call_sret_reg_shift_c(int32_t shift);
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t glue_store_retval_pair_to_rbp_elf_c(void *m, void *arena, void *elf_ctx, int32_t ty_ref, int32_t slot_off, int32_t ta, int32_t init_ref, void *ctx);
extern int32_t try_inline_struct_lit_return_call_to_slot_elf(void *arena, void *elf_ctx, int32_t call_ref, void *ctx, int32_t ta, int32_t stack_slot_off);
extern int32_t try_inline_const_struct_lit_return_call_to_slot_elf(void *arena, void *elf_ctx, int32_t call_ref, void *ctx, int32_t ta, int32_t stack_slot_off);
extern int32_t pipeline_asm_emit_struct_let_init_elf_c(void *arena, void *elf_ctx, int32_t init_ref, void *ctx, int32_t ta, int32_t stack_slot_off);
extern int32_t glue_index_deref_ptr_field_slot_rax_elf_c(void *arena, void *elf_ctx, int32_t fa_ref, int32_t ta);
extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_base_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_name_len(void *arena, int32_t expr_ref);
extern void pipeline_expr_field_access_name_into(void *arena, int32_t expr_ref, uint8_t *out);
extern int32_t pipeline_expr_resolved_type_ref(void *arena, int32_t expr_ref);
extern int32_t glue_call_return_byte_size_c(void *arena, int32_t call_expr_ref);
extern int32_t pipeline_expr_struct_lit_value_bytes(void *arena, void *mod, int32_t expr_ref);
extern int32_t glue_sysv_dual_gp_byte_size_c(void *arena, int32_t ty_ref);
extern void *pipeline_asm_ctx_layout(void *ctx);
extern void glue_align_next_offset(void *ctx);
extern int32_t pipeline_expr_var_name_len(void *arena, int32_t expr_ref);
extern void pipeline_expr_var_name_into(void *arena, int32_t expr_ref, uint8_t *out);
extern int32_t asm_ctx_local_find_offset_scoped(void *ctx, void *arena, uint8_t *name, int32_t name_len);
extern int32_t asm_ctx_local_find_offset(void *ctx, uint8_t *name, int32_t name_len);
extern int32_t glue_var_expr_type_ref_with_decl_fallback_c(void *arena, int32_t var_ref);
extern int32_t glue_local_var_slot_needs_ptr_load_elf_c(void *arena, int32_t var_expr_ref, int32_t stack_off, void *ctx);
extern int32_t glue_slice_dual_gp_length_off_c(int32_t var_off, int32_t ta);
extern int32_t glue_enc_local_slot_ptr_or_addr_elf_c(void *arena, void *elf_ctx, int32_t var_ref, int32_t var_off, void *ctx, int32_t ta);
extern int32_t pipeline_expr_enum_variant_tag_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_type_array_size_at(void *arena, int32_t ref);
extern int32_t pipeline_expr_field_access_soa_stride(void *arena, int32_t expr_ref);
extern int32_t typeck_soa_field_soa_index(void *module, void *arena, int32_t expr_ref, int32_t base_ref);
extern int32_t glue_emit_soa_index_field_addr_elf_c(void *arena, void *elf_ctx, int32_t base_ref, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_lvalue_eff_addr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_typekind_variant_tag(uint8_t *field_buf, int32_t flen);
extern int32_t pipeline_module_struct_layout_num_fields(void *module, int32_t layout_idx);
extern int32_t pipeline_module_struct_layout_field_name_len(void *module, int32_t layout_idx, int32_t fi);
extern void pipeline_module_struct_layout_field_name_into(void *module, int32_t layout_idx, int32_t fi, uint8_t *out64);
extern int32_t pipeline_module_struct_layout_field_type_ref(void *module, int32_t li, int32_t j);
extern int32_t pipeline_module_struct_layout_field_offset_at(void *module, int32_t li, int32_t j);
extern int32_t pipeline_module_num_struct_layouts_at(void *module);
extern int32_t pipeline_module_struct_layout_name_len(void *module, int32_t idx);
extern int32_t pipeline_module_struct_layout_name_byte_at(void *module, int32_t idx, int32_t off);
extern int32_t pipeline_module_func_param_type_ref_for_name(void *module, int32_t func_index, uint8_t *var_name, int32_t name_len);
extern int32_t pipeline_block_resolve_var_type_ref(void *arena, int32_t block_ref, uint8_t *vname, int32_t vlen);
extern int32_t pipeline_module_func_body_ref_at(void *module, int32_t fi);
extern int32_t pipeline_module_num_funcs(void *module);
extern void *pipeline_arena_type_ptr(void *a, int32_t ty_ref);
extern void *glue_arena_expr_at_ref(void *a, int32_t expr_ref);
extern void *pipeline_arena_expr_ptr(void *a, int32_t expr_ref);
extern int32_t typeck_get_field_offset_from_layout_deps(void *module, void *ctx, uint8_t *type_name, int32_t type_name_len, uint8_t *field_name, int32_t field_name_len);
extern int32_t pipeline_dep_ctx_ndep(void *ctx);
extern void *pipeline_dep_ctx_module_at(void *ctx, int32_t idx);
extern int32_t glue_struct_layout_compute_field_offset_c(void *m, void *a, int32_t li, int32_t j);
extern int32_t glue_struct_layout_index_by_type_name_c(void *m, uint8_t *struct_name, int32_t nlen);
extern int32_t pipeline_type_named_name_into(void *arena, int32_t ref, uint8_t *out64);
extern int32_t pipeline_module_enum_variant_tag_for_names(void *m, uint8_t *enum_name, int32_t enum_len, uint8_t *variant_name, int32_t variant_len);
extern char *link_abi_getenv(const char *name);

#ifndef PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED
#define PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED (-99)
#endif
#ifndef GLUE_TYPE_NAMED
#define GLUE_TYPE_NAMED 8
#endif
#ifndef GLUE_TYPE_KIND_SLICE
#define GLUE_TYPE_KIND_SLICE 11
#endif
#ifndef GLUE_TYPE_KIND_ARRAY
#define GLUE_TYPE_KIND_ARRAY 10
#endif
/* ast TypeKind enums used via numeric kind field when peels Type* */
#ifndef ast_TypeKind_TYPE_PTR
#define ast_TypeKind_TYPE_PTR 9
#endif
#ifndef ast_TypeKind_TYPE_NAMED
#define ast_TypeKind_TYPE_NAMED 8
#endif
#ifndef ast_ExprKind_EXPR_FIELD_ACCESS
#define ast_ExprKind_EXPR_FIELD_ACCESS 44
#endif


/* Minimal LP64 mirrors for cold twin field peels (wave151). PLATFORM: SHARED. */
typedef struct w151_ExprMirror {
  int32_t kind;
  int32_t resolved_type_ref;
  int32_t line;
  int32_t col;
  int64_t int_val;
  double float_val;
  uint8_t var_name[256];
  int32_t var_name_len;
  int32_t binop_left_ref;
  int32_t binop_right_ref;
  int32_t unary_operand_ref;
  int32_t if_cond_ref;
  int32_t if_then_ref;
  int32_t if_else_ref;
  int32_t block_ref;
  int32_t match_matched_ref;
  int32_t match_arm_base;
  int32_t match_num_arms;
  int32_t field_access_base_ref;
  uint8_t field_access_field_name[256];
  int32_t field_access_field_len;
  int32_t field_access_is_enum_variant;
  int32_t field_access_offset;
  int32_t field_access_soa_stride;
  int32_t index_base_ref;
  int32_t index_index_ref;
  int32_t index_base_is_slice;
  int32_t call_callee_ref;
  int32_t call_arg_base;
  int32_t call_num_args;
  int32_t call_num_type_args;
  int32_t method_call_base_ref;
  uint8_t method_call_name[256];
  int32_t method_call_name_len;
  int32_t method_call_arg_base;
  int32_t method_call_num_args;
  int32_t const_folded_val;
  int32_t const_folded_valid;
  int32_t index_proven_in_bounds;
  uint8_t struct_lit_struct_name[256];
  int32_t struct_lit_struct_name_len;
  int32_t struct_lit_field_base;
  int32_t struct_lit_num_fields;
  int32_t array_lit_elem_base;
  int32_t array_lit_num_elems;
  int32_t float_bits_lo;
  int32_t float_bits_hi;
  int32_t enum_variant_tag;
} w151_ExprMirror;

typedef struct w151_TypeMirror {
  int32_t kind;
  uint8_t name[256];
  int32_t name_len;
  int32_t elem_type_ref;
} w151_TypeMirror;

typedef struct w151_LyMirror {
  int32_t frame_size;
  int32_t next_offset;
} w151_LyMirror;

int32_t pipeline_token_kind_variant_tag(const uint8_t *variant_name, int32_t variant_len) {
  /* Keep in lockstep with include/token.h TokenKind enum order; import
   * token.x without registered sidecar falls back to this fast path. */
  static const char *const names[] = {
      "TOKEN_EOF",       "TOKEN_FUNCTION",  "TOKEN_LET",         "TOKEN_CONST",      "TOKEN_IF",
      "TOKEN_ELSE",      "TOKEN_WHILE",     "TOKEN_LOOP",        "TOKEN_FOR",        "TOKEN_BREAK",
      "TOKEN_CONTINUE",  "TOKEN_RETURN",    "TOKEN_PANIC",       "TOKEN_DEFER",      "TOKEN_MATCH",
      "TOKEN_STRUCT",    "TOKEN_PACKED",    "TOKEN_ENUM",        "TOKEN_GOTO",       "TOKEN_TRAIT",
      "TOKEN_IMPL",      "TOKEN_SELF",      "TOKEN_UNDERSCORE",  "TOKEN_IMPORT",     "TOKEN_EXTERN",
      "TOKEN_IDENT",     "TOKEN_I32",       "TOKEN_BOOL",        "TOKEN_U8",         "TOKEN_U32",
      "TOKEN_U64",       "TOKEN_I64",       "TOKEN_USIZE",       "TOKEN_ISIZE",      "TOKEN_I32X4",
      "TOKEN_I32X8",     "TOKEN_I32X16",    "TOKEN_U32X4",       "TOKEN_U32X8",      "TOKEN_U32X16",
      "TOKEN_F32X4",     "TOKEN_TRUE",      "TOKEN_FALSE",     "TOKEN_F32",         "TOKEN_F64",        "TOKEN_VOID",
      "TOKEN_INT",       "TOKEN_FLOAT",     "TOKEN_LPAREN",      "TOKEN_RPAREN",     "TOKEN_LBRACE",
      "TOKEN_RBRACE",    "TOKEN_LBRACKET",  "TOKEN_RBRACKET",    "TOKEN_ARROW",      "TOKEN_FATARROW",
      "TOKEN_COMMA",     "TOKEN_COLON",     "TOKEN_DOT",         "TOKEN_SEMICOLON",  "TOKEN_PLUS",
      "TOKEN_MINUS",     "TOKEN_STAR",      "TOKEN_SLASH",       "TOKEN_PERCENT",    "TOKEN_AMP",
      "TOKEN_PIPE",      "TOKEN_CARET",     "TOKEN_LSHIFT",      "TOKEN_RSHIFT",     "TOKEN_PLUS_EQ",
      "TOKEN_MINUS_EQ",  "TOKEN_STAR_EQ",   "TOKEN_SLASH_EQ",    "TOKEN_PERCENT_EQ", "TOKEN_AMP_EQ",
      "TOKEN_PIPE_EQ",   "TOKEN_CARET_EQ",  "TOKEN_LSHIFT_EQ",   "TOKEN_RSHIFT_EQ",  "TOKEN_TILDE",
      "TOKEN_ASSIGN",    "TOKEN_EQ",        "TOKEN_NE",          "TOKEN_LT",         "TOKEN_GT",
      "TOKEN_LE",        "TOKEN_GE",        "TOKEN_AMPAMP",      "TOKEN_PIPEPIPE",   "TOKEN_BANG",
      "TOKEN_QUESTION",  "TOKEN_AS",        "TOKEN_AT",
  };
  int32_t i;
  int32_t nlen;
  if (!variant_name || variant_len <= 0)
    return -1;
  for (i = 0; i < (int32_t)(sizeof(names) / sizeof(names[0])); i++) {
    nlen = (int32_t)strlen(names[i]);
    if (nlen == variant_len && memcmp(variant_name, names[i], (size_t)variant_len) == 0)
      return i;
  }
  return -1;
}

/**
 * layout 扫描：按字段名在 module struct 表查 field type_ref（glue_field_access_field_type_ref 失败时回落）。
 */
int32_t glue_field_access_layout_field_type_ref_by_name_c(void *arena,
                                                                  void *mod, int32_t fa_ref) {
  w151_ExprMirror *ex;
  int32_t flen;
  uint8_t field_name[256];
  int32_t k;
  int32_t j;
  if (!arena || !mod || fa_ref <= 0)
    return 0;
  ex = (w151_ExprMirror *)pipeline_arena_expr_ptr(arena, fa_ref);
  if (!ex)
    return 0;
  flen = ex->field_access_field_len;
  if (flen <= 0 || flen > 255)
    return 0;
  memcpy(field_name, ex->field_access_field_name, (size_t)flen);
  for (k = 0; k < pipeline_module_num_struct_layouts_at(mod); k++) {
    for (j = 0; j < pipeline_module_struct_layout_num_fields(mod, k); j++) {
      int32_t fnlen = pipeline_module_struct_layout_field_name_len(mod, k, j);
      int32_t feq = 1;
      int32_t fi;
      if (fnlen != flen)
        continue;
      for (fi = 0; fi < fnlen; fi++) {
        uint8_t fb[256];
        pipeline_module_struct_layout_field_name_into(mod, k, j, fb);
        if (fb[fi] != field_name[fi]) {
          feq = 0;
          break;
        }
      }
      if (feq)
        return pipeline_module_struct_layout_field_type_ref(mod, k, j);
    }
  }
  return 0;
}

/**
 * CALL 实参 FIELD_ACCESS：仅 MEMORY class（>16B）leave address in rax.
 * PLATFORM: LINUX+MACOS x86_64 SysV —
 * 9–16B INTEGER (Allocator/StrView) is by-value dual-GP — must dual-load, not lea.
 * G.7: matches glue_call_param_named_struct_pass_addr_elf_c + dual-GP param home.
 */
int32_t glue_field_access_call_arg_struct_by_addr_elf_c(void *arena, int32_t fa_ref) {
  int32_t fty;
  if (!pipeline_asm_emit_call_arg_active_c())
    return 0;
  if (g_pipeline_asm_emit_call_param_ty_ref > 0)
    return glue_call_param_named_struct_pass_addr_elf_c(arena, g_pipeline_asm_emit_call_param_ty_ref);
  fty = glue_field_access_field_type_ref_c(arena, g_pipeline_asm_emit_module, fa_ref);
  if (fty <= 0 && g_pipeline_asm_emit_module)
    fty = glue_field_access_layout_field_type_ref_by_name_c(arena, g_pipeline_asm_emit_module, fa_ref);
  if (fty > 0)
    return glue_call_param_named_struct_pass_addr_elf_c(arena, fty);
  return 0;
}

/**
 * After field lvalue address is in rax: load CALL-arg aggregate by SysV class.
 * PLATFORM: LINUX+MACOS x86_64 SysV — 9–16B dual-load rax+rdx; ≤8B load 64.
 * Returns 1 if handled, 0 if not a call-arg aggregate (use scalar load_sz), -1 on emit error.
 */
int32_t glue_field_call_arg_try_load_agg_from_rax_elf_c(void *arena,
                                                               void *elf_ctx,
                                                               int32_t fa_ref, int32_t ta) {
  int32_t fty;
  int32_t sz;
  if (!pipeline_asm_emit_call_arg_active_c() || !arena || !elf_ctx)
    return 0;
  fty = 0;
  if (g_pipeline_asm_emit_call_param_ty_ref > 0 &&
      pipeline_type_kind_ord_at(arena, g_pipeline_asm_emit_call_param_ty_ref) == GLUE_TYPE_NAMED)
    fty = g_pipeline_asm_emit_call_param_ty_ref;
  if (fty <= 0)
    fty = glue_field_access_field_type_ref_c(arena, g_pipeline_asm_emit_module, fa_ref);
  if (fty <= 0 && g_pipeline_asm_emit_module)
    fty = glue_field_access_layout_field_type_ref_by_name_c(arena, g_pipeline_asm_emit_module, fa_ref);
  if (fty <= 0 || pipeline_type_kind_ord_at(arena, fty) != GLUE_TYPE_NAMED)
    return 0;
  sz = glue_type_named_layout_size_any_module_elf_c(arena, fty);
  if (sz <= 0)
    sz = glue_type_size_simple(g_pipeline_asm_emit_module, arena, fty, 0);
  if (sz <= 0)
    return 0;
  if (sz > 16)
    return 0; /* MEMORY: address already in rax via by_addr path */
  if (sz > 8)
    return pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta) != 0 ? -1 : 1;
  if (backend_enc_load_64_from_rax_arch(elf_ctx, ta) != 0)
    return -1;
  return 1;
}

/**
 * wave589 Cap residual pure: freestanding FIELD_ACCESS on CALL/METHOD_CALL return
 * (`mk().x` / long-field `mk().f…`).
 * wave590: extend >16B MEMORY/sret rvalue field (was soft leave after wave589).
 * wave593: (1) nested chain `mk().i.f` — walk FIELD bases to CALL/METHOD root and
 *          sum AoS field offsets; (2) ≤16B STRUCT_LIT-return CALL.field — try_inline
 *          first (same order as glue_emit_struct_type_let_init). Prior ≤16 path only
 *          did emit CALL + store_retval_pair; mid-size (9–16B) dual-GP CALL.field
 *          CG002 on arm64 freestanding while let inlined and green; >16 already inlined.
 *
 * wave608 Cap residual pure: freestanding FIELD_ACCESS on STRUCT_LIT rvalue base
 * (`Big { a: 40, b: 2 }.a` / paren twin). Root: chain walk only accepted CALL/METHOD
 * (48/49); STRUCT_LIT (45) fell through → lvalue_eff_addr UNHANDLED → CG002 while
 * host-C temporary `.` stayed green. G.7: same materialise-then-load authority —
 * STRUCT_LIT root via pipeline_asm_emit_struct_let_init_elf_c (≡ wave605 MEMORY
 * call-arg / let s: Big = Big{…}), then field offset load (no second field path).
 *
 * wave609 Cap residual pure: INDEX base on materialised field (`Wrap{…}.xs[1]` /
 * `mk().xs[i]`). Prior leave_addr=0 loaded first array word; INDEX then treated
 * that value as pointer → freestanding SIGSEGV (host-C green). leave_addr=1 stops
 * after lea home+field_off (INDEX authority in glue_try_index_var_or_field_base_*).
 *
 * Root: field_access fast fell through to lvalue_eff_addr, which only handles
 * VAR / nested FIELD / INDEX / DEREF. CALL/STRUCT_LIT base returns -1 → UNHANDLED
 * → CG002 (host-C emits temporary `.` access; Ubuntu pure-asm gold exposes). Nested
 * `mk().i.f` base is FIELD not CALL → same UNHANDLED before wave593.
 *
 * G.7 authority (same as `let s = mk()` / glue_emit_struct_type_let_init):
 *   materialise CALL/METHOD/STRUCT_LIT root once into frame temp:
 *     0) STRUCT_LIT (45): emit fields into home (struct_let_init)
 *     1) try_inline STRUCT_LIT return (any size; CALL+METHOD attempt;
 *        inliner still no-ops kind!=48)
 *     2) >16B: sret (x86 SysV rdi+shift / arm64 AAPCS64 x8)
 *     3) ≤16B: emit CALL/METHOD + glue_store_retval_pair_to_rbp_elf_c
 *   then lea home+sum(field_offs); leave_addr ? return addr : load outermost field.
 *
 * Soft residual: frame temps ≥512 scratch.
 * wave611: ARRAY_LIT base INDEX parse+typeck closed; wave612: dual INDEX binop
 *   rbx clobber classifier closed (see glue_binop_operand_index_addr_clobbers_rbx).
 * wave599: dual-GP param field extract (take_m) closed — arm64 param_home +
 *   fill_param low-end polarity (was soft leave after wave593).
 *
 * wave596: pointer intermediate on CALL chain (`mk().p.f` / `mk().m.p.f`) —
 * pure offset-sum skipped *T loads (same root as VAR-chain lvalue). Now walk
 * chain root→outer and load at each *T/*slice intermediate (G.7 + lvalue twin).
 *
 * @param leave_addr 0=load field rvalue; 1=leave field slot address in rax (INDEX)
 * @return 0 success, -1 emit error, PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED not
 *   CALL/METHOD/STRUCT_LIT-rooted chain
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 co-path (ta layout;
 *   sret gate: x86_64 SysV + arm64 AAPCS64 x8 (wave591))
 */
int32_t glue_field_access_call_base_rvalue_elf_c(void *arena,
                                                        void *elf_ctx, int32_t expr_ref,
                                                        void *ctx, int32_t ta, int32_t leave_addr) {
  int32_t base_ref;
  int32_t base_ko;
  int32_t base_ty;
  int32_t ret_sz;
  int32_t alloc_sz;
  int32_t home;
  int32_t base_off;
  int32_t load_sz;
  int32_t emit_rc;
  int32_t agg;
  int32_t materialised;
  int32_t cur_fa;
  int32_t chain_depth;
  int32_t chain_fa[16];
  int32_t chain_n;
  int32_t ci;
  w151_LyMirror *ly;
  void *mod;

  if (!arena || !elf_ctx || !ctx || expr_ref <= 0)
    return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
  if (pipeline_expr_kind_ord_at(arena, expr_ref) != (int32_t)ast_ExprKind_EXPR_FIELD_ACCESS)
    return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
  if (pipeline_expr_field_access_is_enum_variant(arena, expr_ref) != 0)
    return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;

  /*
   * wave593: walk FIELD_ACCESS chain to CALL/METHOD root.
   * wave596: keep FA refs (outer→inner) so *T intermediate can load; pure
   * offset sum is wrong when a mid-field is a pointer (`mk().p.f`).
   * Cap depth 16 — pathological nest falls through UNHANDLED (use let).
   */
  mod = g_pipeline_asm_emit_module;
  cur_fa = expr_ref;
  base_ref = 0;
  base_ko = 0;
  chain_depth = 0;
  chain_n = 0;
  while (chain_depth < 16) {
    int32_t next_base;
    if (pipeline_expr_field_access_is_enum_variant(arena, cur_fa) != 0)
      return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
    if (chain_n >= 16)
      return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
    chain_fa[chain_n++] = cur_fa;
    next_base = pipeline_expr_field_access_base_ref(arena, cur_fa);
    if (next_base <= 0)
      return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
    base_ko = pipeline_expr_kind_ord_at(arena, next_base);
    /* EXPR_STRUCT_LIT=45, EXPR_CALL=48, EXPR_METHOD_CALL=49, EXPR_FIELD_ACCESS=44 */
    if (base_ko == 48 || base_ko == 49 || base_ko == 45) {
      base_ref = next_base;
      break;
    }
    if (base_ko == 44) {
      cur_fa = next_base;
      chain_depth++;
      continue;
    }
    return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
  }
  if (base_ref <= 0 || chain_n <= 0)
    return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;

  base_ty = pipeline_expr_resolved_type_ref(arena, base_ref);
  ret_sz = 0;
  if (base_ty > 0)
    ret_sz = glue_type_size_simple(mod, arena, base_ty, 0);
  /* CALL=48 METHOD_CALL=49: same callee-return size when type_size missed. */
  if (ret_sz <= 0 && (base_ko == 48 || base_ko == 49))
    ret_sz = glue_call_return_byte_size_c(arena, base_ref);
  if (ret_sz <= 0 && base_ko == 45)
    ret_sz = pipeline_expr_struct_lit_value_bytes(arena, mod, base_ref);
  if (ret_sz <= 0 && base_ty > 0)
    ret_sz = glue_type_named_layout_size_any_module_elf_c(arena, base_ty);
  if (ret_sz <= 0)
    ret_sz = 8;
  if (base_ty > 0 && ret_sz <= 16) {
    int32_t nsz = glue_sysv_dual_gp_byte_size_c(arena, base_ty);
    if (nsz > ret_sz)
      ret_sz = nsz;
  }
  /*
   * Cap frame temp: compute_frame_size scratch is ≥512; refuse pathological
   * aggregates rather than silent SP overrun (use let binding for huge types).
   */
  if (ret_sz > 4096)
    return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;

  alloc_sz = (ret_sz <= 8) ? 8 : ((ret_sz <= 16) ? 16 : ((ret_sz + 7) & ~7));
  ly = (w151_LyMirror *)pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return -1;
  base_off = ly->next_offset;
  if ((base_off % 8) != 0)
    base_off = (base_off + 7) / 8 * 8;
  /*
   * PLATFORM: MACOS|ARM64 low-end home=off (wave402); LINUX|x86 high-end
   * home=off+alloc (store_retval dual-GP: low@home, high@home-8; sret byte0@home).
   */
  if (ta == 1) {
    home = base_off;
    ly->next_offset = base_off + alloc_sz;
  } else {
    home = base_off + alloc_sz;
    ly->next_offset = home;
  }
  glue_align_next_offset(ctx);

  /*
   * Materialise root CALL/METHOD/STRUCT_LIT into home — same order as let_init (G.7):
   * STRUCT_LIT fields → inline STRUCT_LIT return CALL/METHOD → sret if >16 → dual-GP if ≤16.
   * wave593: pull try_inline out of >16-only so 9–16B STRUCT_LIT CALL.field greens.
   * wave608: bare STRUCT_LIT.field (not only CALL-return inline).
   * METHOD shares ret_sz + try_inline attempt; inliner still no-ops kind!=48.
   */
  materialised = 0;
  if (base_ko == 45) {
    /* PLATFORM: SHARED — reuse wave605 MEMORY / let struct_let_init (G.7 one path). */
    if (pipeline_asm_emit_struct_let_init_elf_c(arena, elf_ctx, base_ref, ctx, ta, home) != 0)
      return -1;
    materialised = 1;
  }
  if (materialised == 0 && (base_ko == 48 || base_ko == 49)) {
    int32_t inl;
    inl = try_inline_struct_lit_return_call_to_slot_elf(arena, elf_ctx, base_ref, ctx, ta, home);
    if (inl == 1)
      materialised = 1;
    if (materialised == 0) {
      inl = try_inline_const_struct_lit_return_call_to_slot_elf(arena, elf_ctx, base_ref, ctx, ta, home);
      if (inl == 1)
        materialised = 1;
    }
  }
  if (materialised == 0 && ret_sz > 16) {
    /*
     * Non-inline large CALL/METHOD: materialise via sret into home.
     * PLATFORM: LINUX+MACOS x86_64 SysV — hidden dest in rdi + GP shift.
     * PLATFORM: MACOS|ARM64 AAPCS64 (wave591) — dest in x8; no GP shift.
     * try_inline no-ops METHOD (kind!=48); this sret path then covers it.
     */
    if (ta != 0 && ta != 1)
      return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
    pipeline_asm_set_call_expected_ret_ty_c(base_ty > 0 ? base_ty : 0);
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta) != 0) {
      pipeline_asm_set_call_expected_ret_ty_c(0);
      return -1;
    }
    if (ta == 0) {
      if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0) {
        pipeline_asm_set_call_expected_ret_ty_c(0);
        return -1;
      }
      pipeline_asm_emit_set_call_sret_reg_shift_c(1);
    } else {
      if (glue_arm64_mov_x0_to_x8_elf_c(elf_ctx) != 0) {
        pipeline_asm_set_call_expected_ret_ty_c(0);
        return -1;
      }
    }
    emit_rc = pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, base_ref, ctx, ta);
    pipeline_asm_emit_set_call_sret_reg_shift_c(0);
    pipeline_asm_set_call_expected_ret_ty_c(0);
    if (emit_rc != 0)
      return -1;
    materialised = 1;
  } else if (materialised == 0) {
    emit_rc = pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, base_ref, ctx, ta);
    if (emit_rc != 0)
      return -1;
    if (glue_store_retval_pair_to_rbp_elf_c(mod, arena, elf_ctx, base_ty > 0 ? base_ty : 0, home, ta, base_ref,
                                            ctx) != 0)
      return -1;
    materialised = 1;
  }
  if (materialised == 0)
    return -1;

  /*
   * Walk chain root→outer (chain_fa is outer→inner): add each field offset;
   * auto-deref *T / fat-slice intermediate (wave596) before the next hop.
   * Outermost load uses load_sz of expr_ref (chain_fa[0]).
   */
  if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta) != 0)
    return -1;
  for (ci = chain_n - 1; ci >= 0; ci--) {
    int32_t fo = glue_field_access_effective_offset_c(arena, mod, chain_fa[ci]);
    if (fo < 0)
      fo = 0;
    if (fo != 0 && backend_enc_add_imm_to_rax_arch(elf_ctx, fo, ta) != 0)
      return -1;
    if (ci > 0) {
      /* Intermediate FA: if field is *T or slice fat, load pointer before next offset. */
      if (glue_index_deref_ptr_field_slot_rax_elf_c(arena, elf_ctx, chain_fa[ci], ta) != 0)
        return -1;
    }
  }
  /* wave609: INDEX base needs field slot address only (TYPE_ARRAY / *T[] home). */
  if (leave_addr != 0)
    return 0;
  if (glue_field_access_call_arg_struct_by_addr_elf_c(arena, expr_ref) != 0)
    return 0;
  agg = glue_field_call_arg_try_load_agg_from_rax_elf_c(arena, elf_ctx, expr_ref, ta);
  if (agg < 0)
    return -1;
  if (agg > 0)
    return 0;
  load_sz = pipeline_expr_field_access_load_byte_sz(arena, mod, expr_ref);
  if (load_sz == 1)
    return backend_enc_load_zext8_from_rax_arch(elf_ctx, ta);
  if (load_sz == 8)
    return backend_enc_load_64_from_rax_arch(elf_ctx, ta);
  return backend_enc_load_32_from_rax_arch(elf_ctx, ta);
}

/**
 * VAR 基底字段访问（lex.pos、l.line 等）：经 asm_ctx 查栈槽 + 字段偏移 load，勿落 backend slow 的 ast_arena_expr_get 按值拷贝。
 */
int32_t pipeline_asm_emit_var_field_access_elf_c(void *arena,
                                                        void *elf_ctx, int32_t expr_ref,
                                                        void *ctx, int32_t ta) {
  int32_t base_ref;
  int32_t vlen;
  int32_t var_off;
  int32_t field_off;
  int32_t load_sz;
  uint8_t vname[256];

  base_ref = pipeline_expr_field_access_base_ref(arena, expr_ref);
  if (base_ref <= 0 || pipeline_expr_kind_ord_at(arena, base_ref) != 3)
    return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
  vlen = pipeline_expr_var_name_len(arena, base_ref);
  if (vlen <= 0 || vlen > 255)
    return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
  pipeline_expr_var_name_into(arena, base_ref, vname);
  var_off = asm_ctx_local_find_offset_scoped((uint8_t *)ctx, arena, vname, vlen);
  /** while/for 体内访问外层 let：scoped min_slot 可能排除形参/外层槽，退化为全表搜索。 */
  if (var_off < 0)
    var_off = asm_ctx_local_find_offset((uint8_t *)ctx, vname, vlen);
  if (var_off < 0) {
    /* Class AY: Cap XLANG_ASM_EMIT_TRACE note retired. */
    return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
  }
  /*
   * wave393 Cap residual pure: freestanding TYPE_SLICE dual-GP local home.
   * wave394: length half offset is arch-aware (glue_slice_dual_gp_length_off_c)
   * so memory order is always C fat; arm64 home+8, x86 home-8.
   * slice* params still fat*+8 via needs_ptr_load path below.
   * G.7: match INDEX bounds `glue_emit_slice_length_to_rbx_elf_c` dual-GP load.
   * PLATFORM: SHARED freestanding · LINUX+MACOS (arm64/x86_64); host-C untouched.
   */
  {
    int32_t base_ty_sl = glue_var_expr_type_ref_with_decl_fallback_c(arena, base_ref);
    int32_t flen_sl = pipeline_expr_field_access_name_len(arena, expr_ref);
    if (base_ty_sl > 0 && flen_sl > 0 && flen_sl <= 63 &&
        pipeline_type_kind_ord_at(arena, base_ty_sl) == GLUE_TYPE_KIND_SLICE &&
        glue_local_var_slot_needs_ptr_load_elf_c(arena, base_ref, var_off, ctx) == 0) {
      uint8_t fn_sl[256];
      pipeline_expr_field_access_name_into(arena, expr_ref, fn_sl);
      if (flen_sl == 6 && memcmp(fn_sl, "length", 6) == 0)
        return backend_enc_load_rbp_to_rax_arch(elf_ctx, glue_slice_dual_gp_length_off_c(var_off, ta),
                                               ta);
      if (flen_sl == 4 && memcmp(fn_sl, "data", 4) == 0)
        return backend_enc_load_rbp_to_rax_arch(elf_ctx, var_off, ta);
    }
  }
  field_off = glue_field_access_effective_offset_c(arena, g_pipeline_asm_emit_module, expr_ref);
  if (glue_enc_local_slot_ptr_or_addr_elf_c(arena, elf_ctx, base_ref, var_off, ctx, ta) != 0)
    return -1;
  if (field_off != 0 && backend_enc_add_imm_to_rax_arch(elf_ctx, field_off, ta) != 0)
    return -1;
  if (glue_field_access_call_arg_struct_by_addr_elf_c(arena, expr_ref) != 0)
    return 0;
  {
    int32_t agg = glue_field_call_arg_try_load_agg_from_rax_elf_c(arena, elf_ctx, expr_ref, ta);
    if (agg < 0)
      return -1;
    if (agg > 0)
      return 0;
  }
  load_sz = pipeline_expr_field_access_load_byte_sz(arena, g_pipeline_asm_emit_module, expr_ref);
  if (load_sz == 1)
    return backend_enc_load_zext8_from_rax_arch(elf_ctx, ta);
  if (load_sz == 8)
    return backend_enc_load_64_from_rax_arch(elf_ctx, ta);
  return backend_enc_load_32_from_rax_arch(elf_ctx, ta);
}

/**
 * EXPR_FIELD_ACCESS 快速路径：枚举 TokenKind/ExprKind/TypeKind、VAR 字段（lex.pos），勿落 backend slow。
 */
/* wave149 Cap residual: pure binop leave (was static). PLATFORM: SHARED. */
int32_t pipeline_asm_emit_field_access_elf_fast_c(void *arena,
                                                           void *elf_ctx,
                                                           int32_t expr_ref, void *ctx,
                                                           int32_t ta) {
  int32_t fa_base2;
  int32_t blen2;
  if (pipeline_expr_field_access_is_enum_variant(arena, expr_ref) != 0)
    return backend_enc_mov_imm32_to_w0_arch(elf_ctx, pipeline_expr_enum_variant_tag_at(arena, expr_ref), ta);
  /*
   * wave346 Cap residual pure: fixed TYPE_ARRAY / TYPE_VECTOR `.length` → imm N in rax.
   * Prior: var_field_access loaded base+0 (first elem) when field_offset stayed 0
   * (typeck only stamped fat-slice length@+8). G.7: match host ((size_t)N) + typeck usize.
   * PLATFORM: SHARED freestanding emit (LINUX gold; mac host-C co-path).
   */
  {
    int32_t flen_arr = pipeline_expr_field_access_name_len(arena, expr_ref);
    if (flen_arr == 6) {
      uint8_t fn_arr[256];
      int32_t base_ref_arr;
      int32_t base_ty_arr;
      int32_t bk_arr;
      int32_t asz_arr;
      pipeline_expr_field_access_name_into(arena, expr_ref, fn_arr);
      if (memcmp(fn_arr, "length", 6) == 0) {
        base_ref_arr = pipeline_expr_field_access_base_ref(arena, expr_ref);
        base_ty_arr = glue_var_expr_type_ref_with_decl_fallback_c(arena, base_ref_arr);
        if (base_ty_arr <= 0)
          base_ty_arr = pipeline_expr_resolved_type_ref(arena, base_ref_arr);
        if (base_ty_arr > 0) {
          bk_arr = pipeline_type_kind_ord_at(arena, base_ty_arr);
          if (bk_arr == GLUE_TYPE_KIND_ARRAY || bk_arr == 13 /* TYPE_VECTOR */) {
            asz_arr = pipeline_type_array_size_at(arena, base_ty_arr);
            if (asz_arr > 0)
              return backend_enc_mov_imm64_to_rax_arch(elf_ctx, asz_arr, 0, ta);
          }
        }
      }
    }
  }
  fa_base2 = pipeline_expr_field_access_base_ref(arena, expr_ref);
  /** DOD-S1：SoA `arr[i].field` 读路径（列基址 + index*stride；失败/无 stride 时回落 lvalue 寻址）。 */
  if (fa_base2 > 0 && pipeline_expr_kind_ord_at(arena, fa_base2) == 47) {
    int32_t load_sz;
    /** emit 时 stride 仍缺：再跑 SoA typeck（skip .x typeck / 形参 T[N] 回填遗漏）。 */
    if (pipeline_expr_field_access_soa_stride(arena, expr_ref) <= 0 && g_pipeline_asm_emit_module != 0)
      /* 8.3.3 host-cc leave: typeck.x authority (no pipeline_typeck_soa.c thin). */
      {
        (void)typeck_soa_field_soa_index(g_pipeline_asm_emit_module, arena, expr_ref, fa_base2);
      }
    if (pipeline_expr_field_access_soa_stride(arena, expr_ref) > 0) {
      if (glue_emit_soa_index_field_addr_elf_c(arena, elf_ctx, fa_base2, expr_ref, ctx, ta) != 0 &&
          pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, expr_ref, ctx, ta) != 0)
        return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
    } else if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, expr_ref, ctx, ta) != 0) {
      return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
    }
    load_sz = pipeline_expr_field_access_load_byte_sz(arena, g_pipeline_asm_emit_module, expr_ref);
    if (load_sz == 1)
      return backend_enc_load_zext8_from_rax_arch(elf_ctx, ta);
    if (load_sz == 8)
      return backend_enc_load_64_from_rax_arch(elf_ctx, ta);
    return backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta);
  }
  /**
   * wave589: CALL/METHOD_CALL rvalue base (`mk().x`) before VAR / chain lvalue.
   * PLATFORM: SHARED freestanding · LINUX gold.
   */
  {
    int32_t call_fa = glue_field_access_call_base_rvalue_elf_c(arena, elf_ctx, expr_ref, ctx, ta, 0);
    if (call_fa != PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED)
      return call_fa;
  }
  /** 局部/形参 struct 字段（listener.fd 等）；枚举 TokenKind/TypeKind/ExprKind 须先于 var_field_access（skip typeck 无 is_enum_variant）。 */
  if (fa_base2 > 0 && pipeline_expr_kind_ord_at(arena, fa_base2) == 3) {
    blen2 = pipeline_expr_var_name_len(arena, fa_base2);
    if (blen2 >= 9) {
      uint8_t bn[256];
      uint8_t fb[256];
      int32_t flen2 = pipeline_expr_field_access_name_len(arena, expr_ref);
      int32_t tk;
      pipeline_expr_var_name_into(arena, fa_base2, bn);
      if (memcmp(bn, "TokenKind", 9) == 0 && flen2 > 0) {
        pipeline_expr_field_access_name_into(arena, expr_ref, fb);
        tk = pipeline_token_kind_variant_tag(fb, flen2);
        if (tk < 0) {
          /** parser 偶发 field_len 多 1（含尾零）；前缀一致再试 NUL 终止长。 */
          int32_t sl = (int32_t)strlen((const char *)fb);
          if (sl > 0 && sl < flen2)
            tk = pipeline_token_kind_variant_tag(fb, sl);
        }
        if (tk >= 0)
          return backend_enc_mov_imm32_to_w0_arch(elf_ctx, tk, ta);
      }
    }
    if (blen2 >= 8) {
      uint8_t bn[256];
      uint8_t fb[256];
      int32_t flen2 = pipeline_expr_field_access_name_len(arena, expr_ref);
      int32_t ev_tag;
      pipeline_expr_var_name_into(arena, fa_base2, bn);
      if (memcmp(bn, "TypeKind", 8) == 0 && flen2 > 0) {
        pipeline_expr_field_access_name_into(arena, expr_ref, fb);
        ev_tag = pipeline_asm_typekind_variant_tag(fb, flen2);
        if (ev_tag >= 0)
          return backend_enc_mov_imm32_to_w0_arch(elf_ctx, ev_tag, ta);
      }
      if (memcmp(bn, "ExprKind", 8) == 0 && flen2 > 0) {
        ev_tag = pipeline_expr_enum_namespace_field_tag(arena, expr_ref);
        if (ev_tag >= 0)
          return backend_enc_mov_imm32_to_w0_arch(elf_ctx, ev_tag, ta);
      }
    }
    {
      int32_t vr = pipeline_asm_emit_var_field_access_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
      if (vr != PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED)
        return vr;
    }
  }
  /** skip typeck：enum namespace 未标 is_enum_variant 时的最后回落。 */
  {
    int32_t ns_tag = pipeline_expr_enum_namespace_field_tag(arena, expr_ref);
    if (ns_tag >= 0)
      return backend_enc_mov_imm32_to_w0_arch(elf_ctx, ns_tag, ta);
  }
  /** 链式 FIELD_ACCESS（v.al.kind 等）：lvalue 寻址 + load；勿落 backend slow（与 rec 互递归 SIGSEGV）。 */
  {
    int32_t load_sz;
    int32_t agg;
    if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, expr_ref, ctx, ta) != 0)
      return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
    if (glue_field_access_call_arg_struct_by_addr_elf_c(arena, expr_ref) != 0)
      return 0;
    agg = glue_field_call_arg_try_load_agg_from_rax_elf_c(arena, elf_ctx, expr_ref, ta);
    if (agg < 0)
      return -1;
    if (agg > 0)
      return 0;
    load_sz = pipeline_expr_field_access_load_byte_sz(arena, g_pipeline_asm_emit_module, expr_ref);
    if (load_sz == 1)
      return backend_enc_load_zext8_from_rax_arch(elf_ctx, ta);
    if (load_sz == 8)
      return backend_enc_load_64_from_rax_arch(elf_ctx, ta);
    return backend_enc_load_32_from_rax_arch(elf_ctx, ta);
  }
}

/* ========================================================================
 * wave1026 G.7 fold: field_access layout/offset helpers
 * (from pipeline_glue residual after this #include). Same-TU static.
 * Callers: this leaf (var_field_access / call_base_rvalue / field_access_fast);
 * index_helpers / assign / index_eff_addr / vector_let leaves (via forward
 * decls kept in glue: glue_field_access_effective_offset_c @2500;
 * pipeline_expr_field_access_layout_offset / load_byte_sz @1726-1727 public).
 * PLATFORM: SHARED freestanding · LINUX+MACOS x86_64 · MACOS|ARM64 AAPCS64.
 * ======================================================================== */

/* wave1026: forward decls for helpers defined later in this TU (after
 * field_access.c #include at glue:2847). Needed by layout/offset helpers.
 * wave1050: glue_struct_layout_field_offset_by_name_c migrated here (definition
 * at EOF below); forward decl retained for callsites at L811/L832/L866/L884
 * (all in this leaf, before the definition). glue.c has zero self-callsites —
 * pure leaf consumed only by field_access.c. */
/* wave138: Cap residual in ast_pool_arena.c (non-static). */
void *glue_arena_expr_at_ref(void *a, int32_t expr_ref);
/* wave1179: pipeline_expr_enum_field_tag_via_module migrated to this file's
 * EOF; fwd decl here so pipeline_expr_enum_namespace_field_tag (also migrated)
 * can call it before its definition. */
/* wave1026: extern decls for typeck/dep helpers declared after this #include
 * in glue (5653-5657); duplicated here for visibility. Compatible redecls OK. */

/**
 * dep 编译单元 struct layout 中按字段名查偏移（caller 无 layout 时，如 stack_promote_cross_ret）。
 */
int32_t glue_dep_layout_field_offset_by_name_c(void *ctx, uint8_t *field_name,
                                                        int32_t flen) {
  int32_t nd;
  int32_t di;
  int32_t k;
  int32_t j;
  if (!ctx || !field_name || flen <= 0)
    return -1;
  nd = pipeline_dep_ctx_ndep(ctx);
  di = 0;
  while (di < nd) {
    void *dm = pipeline_dep_ctx_module_at(ctx, di);
    if (dm) {
      for (k = 0; k < pipeline_module_num_struct_layouts_at(dm); k++) {
        for (j = 0; j < pipeline_module_struct_layout_num_fields(dm, k); j++) {
          int32_t fnlen = pipeline_module_struct_layout_field_name_len(dm, k, j);
          int32_t feq = 1;
          int32_t fi;
          if (fnlen != flen)
            continue;
          for (fi = 0; fi < fnlen; fi++) {
            uint8_t fb[256];
            pipeline_module_struct_layout_field_name_into(dm, k, j, fb);
            if (fb[fi] != field_name[fi]) {
              feq = 0;
              break;
            }
          }
          if (!feq)
            continue;
          {
            int32_t stored = pipeline_module_struct_layout_field_offset_at(dm, k, j);
            int32_t computed;
            void *da;
            if (stored != 0)
              return stored;
            da = pipeline_dep_ctx_arena_at(ctx, di);
            if (da) {
              computed = glue_struct_layout_compute_field_offset_c(dm, da, k, j);
              if (computed != 0)
                return computed;
            }
            if (j == 0)
              return 0;
          }
        }
      }
    }
    di = di + 1;
  }
  return -1;
}

/**
 * VAR 基址 FIELD_ACCESS：按 base 的 struct 类型名 + 字段名查 layout 偏移。
 * emit 时 resolved_type 常缺失，须回落 module 形参 *T 类型；勿全局按字段名扫 layout（易误命中 path_buf 等）。
 * 命中返回 offset，未命中返回 -1。
 */
int32_t glue_field_layout_offset_for_var_base_field(void *a, void *m,
                                                           int32_t base_var_ref, uint8_t *field_name,
                                                           int32_t flen) {
  int32_t base_ty;
  int32_t fi;
  uint8_t vname[256];
  int32_t vlen;
  w151_TypeMirror *tp;
  uint8_t struct_name[256];
  int32_t nlen;
  int32_t k;
  int32_t j;
  if (!a || !m || base_var_ref <= 0 || !field_name || flen <= 0 || flen > 255)
    return -1;
  base_ty = 0;
  /** emit 中 VAR 形参：优先当前函数 param 表，勿信 fill 误写的 resolved_type（同名 v 跨函数覆盖）。 */
  if (pipeline_expr_kind_ord_at(a, base_var_ref) == 3) {
    fi = g_pipeline_asm_emit_func_index;
    vlen = pipeline_expr_var_name_len(a, base_var_ref);
    if (fi >= 0 && fi < pipeline_module_num_funcs(m) && vlen > 0 && vlen <= 63) {
      pipeline_expr_var_name_into(a, base_var_ref, vname);
      base_ty = pipeline_module_func_param_type_ref_for_name(m, fi, vname, vlen);
    }
  }
  if (base_ty <= 0)
    base_ty = pipeline_expr_resolved_type_ref(a, base_var_ref);
  /** while/for 体内 let p: Pair 等：skip typeck 时 resolved_type 常缺，从 scope 块链查 let 声明类型。 */
  if (base_ty <= 0 && pipeline_expr_kind_ord_at(a, base_var_ref) == 3 && g_pipeline_asm_emit_scope_block > 0) {
    vlen = pipeline_expr_var_name_len(a, base_var_ref);
    if (vlen > 0 && vlen <= 63) {
      pipeline_expr_var_name_into(a, base_var_ref, vname);
      base_ty = pipeline_block_resolve_var_type_ref(a, g_pipeline_asm_emit_scope_block, vname, vlen);
    }
  }
  /** final_expr 等无 scope sidecar：从当前 emit 函数体查 let p: Pair 类型。 */
  if (base_ty <= 0 && pipeline_expr_kind_ord_at(a, base_var_ref) == 3 && g_pipeline_asm_emit_func_index >= 0 &&
      g_pipeline_asm_emit_func_index < pipeline_module_num_funcs(m)) {
    vlen = pipeline_expr_var_name_len(a, base_var_ref);
    if (vlen > 0 && vlen <= 63) {
      int32_t body_ref = pipeline_module_func_body_ref_at(m, g_pipeline_asm_emit_func_index);
      pipeline_expr_var_name_into(a, base_var_ref, vname);
      if (body_ref > 0)
        base_ty = pipeline_block_resolve_var_type_ref(a, body_ref, vname, vlen);
    }
  }
  /** skip typeck：单 layout 入口模块按字段名查 offset（cl_align64 Ring64 等）。 */
  if (base_ty <= 0 && pipeline_module_num_struct_layouts_at(m) == 1) {
    int32_t off = glue_struct_layout_field_offset_by_name_c(m, a, 0, field_name, flen);
    if (off >= 0)
      return off;
  }
  if (base_ty <= 0)
    return -1;
  tp = (w151_TypeMirror *)pipeline_arena_type_ptr(a, base_ty);
  if (!tp)
    return -1;
  if (tp->kind == ast_TypeKind_TYPE_PTR && tp->elem_type_ref > 0) {
    base_ty = tp->elem_type_ref;
    tp = (w151_TypeMirror *)pipeline_arena_type_ptr(a, base_ty);
  }
  if (!tp || tp->kind != ast_TypeKind_TYPE_NAMED)
    return -1;
  nlen = tp->name_len;
  if (nlen <= 0 || nlen > 255)
    return -1;
  memcpy(struct_name, tp->name, (size_t)nlen);
  k = glue_struct_layout_index_by_type_name_c(m, struct_name, nlen);
  if (k >= 0) {
    int32_t off = glue_struct_layout_field_offset_by_name_c(m, a, k, field_name, flen);
    if (off >= 0)
      return off;
    /* Caller layout miss (j>0 stored/computed 0): fall through to dep arena. */
  }
  /** import Pair 等：struct layout 在 dep 编译单元（stack_promote_cross_ret 的 p.a/p.b）。 */
  if (g_pipeline_asm_emit_dep_pipe) {
    int32_t nd = pipeline_dep_ctx_ndep(g_pipeline_asm_emit_dep_pipe);
    int32_t di;
    for (di = 0; di < nd; di++) {
      void *dm = pipeline_dep_ctx_module_at(g_pipeline_asm_emit_dep_pipe, di);
      void *da = pipeline_dep_ctx_arena_at(g_pipeline_asm_emit_dep_pipe, di);
      int32_t k2;
      int32_t off;
      if (!dm || !da)
        continue;
      k2 = glue_struct_layout_index_by_type_name_c(dm, struct_name, nlen);
      if (k2 < 0)
        continue;
      off = glue_struct_layout_field_offset_by_name_c(dm, da, k2, field_name, flen);
      if (off >= 0)
        return off;
    }
    {
      int32_t dep_off;
      dep_off = typeck_get_field_offset_from_layout_deps(m, g_pipeline_asm_emit_dep_pipe, struct_name, nlen, field_name,
                                                         flen);
      if (dep_off >= 0)
        return dep_off;
    }
  }
  return -1;
}

/**
 * FIELD_ACCESS 基址 expr：按 base 的 struct 类型名 + 字段名查 layout 偏移。
 * VAR 走 glue_field_layout_offset_for_var_base_field（形参/let 回落）；其余走 resolved *T/NAMED + dep 池。
 * 命中返回 offset，未命中返回 -1。
 * Link surface: non-static so typeck_soa_fill_field_access_for_asm_emit
 * (typeck_x.o) can call after 8.3.3 R2 migration. PLATFORM: SHARED.
 */
int32_t glue_field_layout_offset_for_base_field(void *a, void *m, int32_t base_ref,
                                                uint8_t *field_name, int32_t flen) {
  int32_t base_ty;
  w151_TypeMirror *tp;
  uint8_t struct_name[256];
  int32_t nlen;
  int32_t k;
  if (!a || !m || base_ref <= 0 || !field_name || flen <= 0 || flen > 255)
    return -1;
  if (pipeline_expr_kind_ord_at(a, base_ref) == 3)
    return glue_field_layout_offset_for_var_base_field(a, m, base_ref, field_name, flen);
  base_ty = pipeline_expr_resolved_type_ref(a, base_ref);
  if (base_ty <= 0 && pipeline_module_num_struct_layouts_at(m) == 1)
    return glue_struct_layout_field_offset_by_name_c(m, a, 0, field_name, flen);
  if (base_ty <= 0)
    return -1;
  tp = (w151_TypeMirror *)pipeline_arena_type_ptr(a, base_ty);
  if (!tp)
    return -1;
  if (tp->kind == ast_TypeKind_TYPE_PTR && tp->elem_type_ref > 0) {
    base_ty = tp->elem_type_ref;
    tp = (w151_TypeMirror *)pipeline_arena_type_ptr(a, base_ty);
  }
  if (!tp || tp->kind != ast_TypeKind_TYPE_NAMED)
    return -1;
  nlen = tp->name_len;
  if (nlen <= 0 || nlen > 255)
    return -1;
  memcpy(struct_name, tp->name, (size_t)nlen);
  k = glue_struct_layout_index_by_type_name_c(m, struct_name, nlen);
  if (k >= 0) {
    int32_t off = glue_struct_layout_field_offset_by_name_c(m, a, k, field_name, flen);
    if (off >= 0)
      return off;
  }
  if (g_pipeline_asm_emit_dep_pipe) {
    int32_t nd = pipeline_dep_ctx_ndep(g_pipeline_asm_emit_dep_pipe);
    int32_t di;
    for (di = 0; di < nd; di++) {
      void *dm = pipeline_dep_ctx_module_at(g_pipeline_asm_emit_dep_pipe, di);
      void *da = pipeline_dep_ctx_arena_at(g_pipeline_asm_emit_dep_pipe, di);
      int32_t k2;
      int32_t off;
      if (!dm || !da)
        continue;
      k2 = glue_struct_layout_index_by_type_name_c(dm, struct_name, nlen);
      if (k2 < 0)
        continue;
      off = glue_struct_layout_field_offset_by_name_c(dm, da, k2, field_name, flen);
      if (off >= 0)
        return off;
    }
    {
      int32_t dep_off = typeck_get_field_offset_from_layout_deps(m, g_pipeline_asm_emit_dep_pipe, struct_name, nlen,
                                                                 field_name, flen);
      if (dep_off >= 0)
        return dep_off;
    }
  }
  return -1;
}

/**
 * FIELD_ACCESS 有效字节偏移：typed layout → typeck stored；勿全局字段名首匹配（len/cap 误中 Vec_i32）。
 */
int32_t glue_field_access_effective_offset_c(void *arena, void *mod,
                                                     int32_t fa_ref) {
  return pipeline_expr_field_access_layout_offset(arena, mod, fa_ref);
}

/**
 * FIELD_ACCESS 字节偏移：优先 module struct layout 中字段 offset（strict typeck 未填 field_access_offset 时），
 * 否则回落 expr 上 typeck 写入的 field_access_offset。
 *
 * TYPE_SLICE built-in fat layout (G.7 with pipeline_typeck_field_slice_c): data@0, length@8.
 * PLATFORM: SHARED — both backends; asm uses this for lea+add when typeck offset missing.
 */
int32_t pipeline_expr_field_access_layout_offset(void *a, void *m, int32_t expr_ref) {
  w151_ExprMirror *ex;
  int32_t flen;
  uint8_t field_name[256];
  int32_t stored;
  int32_t typed_off;
  if (!a || expr_ref <= 0)
    return 0;
  ex = (w151_ExprMirror *)glue_arena_expr_at_ref(a, expr_ref);
  if (!ex)
    return 0;
  stored = ex->field_access_offset;
  flen = ex->field_access_field_len;
  if (flen <= 0 || flen > 255)
    return stored;
  memcpy(field_name, ex->field_access_field_name, (size_t)flen);
  /** import 入口无本地 layout：dep 池按字段名查 Pair.a/b 等（cross_ret final_expr）。 */
  if (m && pipeline_module_num_struct_layouts_at(m) == 0 && g_pipeline_asm_emit_dep_pipe) {
    int32_t dep_off = glue_dep_layout_field_offset_by_name_c(g_pipeline_asm_emit_dep_pipe, field_name, flen);
    if (dep_off >= 0)
      return dep_off;
  }
  /** *T 形参/局部或具名基址：按 struct 类型查字段；禁全局 len/cap 首匹配误中 Vec_i32（覆盖 col_y）。 */
  if (ex->field_access_base_ref > 0) {
    typed_off = glue_field_layout_offset_for_base_field(a, m, ex->field_access_base_ref, field_name, flen);
    if (typed_off >= 0)
      return typed_off;
    /** Built-in T[] fat pointer — not a named struct layout.
     * Base may be VAR (`sub.length`) or FIELD_ACCESS (`sp.left.length` → left is TYPE_SLICE). */
    {
      int32_t base_ref = ex->field_access_base_ref;
      int32_t base_ty = glue_var_expr_type_ref_with_decl_fallback_c(a, base_ref);
      if (base_ty <= 0)
        base_ty = pipeline_expr_resolved_type_ref(a, base_ref);
      if (base_ty <= 0 && pipeline_expr_kind_ord_at(a, base_ref) == 44)
        base_ty = glue_field_access_field_type_ref_c(a, m, base_ref);
      if (base_ty > 0 && pipeline_type_kind_ord_at(a, base_ty) == GLUE_TYPE_KIND_SLICE) {
        if (flen == 4 && memcmp(field_name, "data", 4) == 0)
          return 0;
        if (flen == 6 && memcmp(field_name, "length", 6) == 0)
          return 8;
      }
    }
  }
  /** typeck layout_deps 已写入 offset 时回落 stored，勿再扫 module 全 layout 按字段名首匹配。 */
  if (stored != 0)
    return stored;
  return 0;
}

/**
 * Field-access load width by type_ref (bool/u8=1, i32/u32/f32=4, i64/ptr/TYPE_FN=8).
 * Twin of runtime_pipeline_abi.x glue_field_access_load_bytes_for_type_ref.
 * 10.3.3: TYPE_FN (18) is opaque Cap-fn-ptr ABI — pointer-sized, not scalar miss→4.
 * PLATFORM: SHARED.
 */
int32_t glue_field_access_load_bytes_for_type_ref(void *a, int32_t ty_ref) {
  int32_t kind_ord;
  if (!a || ty_ref <= 0 || ty_ref > ((int32_t *)a)[0])
    return 8;
  kind_ord = pipeline_type_kind_ord_at(a, ty_ref);
  if (kind_ord == 2 || kind_ord == 1)
    return 1;
  if (kind_ord == 0 || kind_ord == 3 || kind_ord == 13 || kind_ord == 14)
    return 4;
  /* i64/u64/usize/isize/f64/ptr/TYPE_FN → 8 */
  if (kind_ord == 5 || kind_ord == 4 || kind_ord == 6 || kind_ord == 7 || kind_ord == 15
      || kind_ord == 9 || kind_ord == 18)
    return 8;
  if (kind_ord == 8)
    return 8;
  return 4;
}

/**
 * resolved_type_ref 缺失或误为聚合/指针时：按 module struct layout + 字段名推断 load 宽度。
 * 修复 strict backend 编 core.option 时 opt.is_some 误 ldr x0（应为 ldrb）导致 option 测试失败。
 */
int32_t pipeline_expr_field_access_load_byte_sz(void *a, void *m, int32_t expr_ref) {
  w151_ExprMirror *ex;
  int32_t tr;
  int32_t base_tr;
  uint8_t struct_name[256];
  int32_t nlen;
  int32_t flen;
  uint8_t field_name[256];
  int32_t k;
  int32_t j;
  int32_t ftr;
  int32_t kind_ord;
  static const uint8_t nm_is_some[7] = { 105, 115, 95, 115, 111, 109, 101 };
  static const uint8_t nm_is_none[7] = { 105, 115, 95, 110, 111, 110, 101 };
  if (!a || expr_ref <= 0)
    return 8;
  ex = (w151_ExprMirror *)glue_arena_expr_at_ref(a, expr_ref);
  if (!ex || ex->field_access_base_ref <= 0)
    return 8;
  flen = ex->field_access_field_len;
  if (flen <= 0 || flen > 255)
    return 8;
  memcpy(field_name, ex->field_access_field_name, (size_t)flen);
  /* TYPE_FN=18 / TYPE_PTR=9 field load is pointer-sized. Consult FIELD
   * resolved_type BEFORE scanning every layout for a matching field name
   * (`f` as i32 in an earlier layout stole width 4 → cltq + call * truncated).
   * PLATFORM: WINDOWS leftover-PE / SHARED Cap ABI. */
  tr = pipeline_expr_resolved_type_ref(a, expr_ref);
  if (tr > 0) {
    kind_ord = pipeline_type_kind_ord_at(a, tr);
    if (kind_ord == 9 || kind_ord == 18)
      return 8;
    if (kind_ord != 8 && kind_ord != 10 && kind_ord != 11 && kind_ord != 12)
      return glue_field_access_load_bytes_for_type_ref(a, tr);
  }
  /* 任意 struct layout 中按字段名匹配（base resolved_type_ref 缺失时仍可用，如 core.option 形参 opt）。 */
  if (m) {
    for (k = 0; k < (int32_t)pipeline_module_num_struct_layouts_at(m); k++) {
      for (j = 0; j < pipeline_module_struct_layout_num_fields(m, k); j++) {
        int32_t fnlen = pipeline_module_struct_layout_field_name_len(m, k, j);
        int32_t feq = 1;
        int32_t fi;
        if (fnlen != flen)
          continue;
        for (fi = 0; fi < fnlen; fi++) {
          uint8_t fb[256];
          pipeline_module_struct_layout_field_name_into(m, k, j, fb);
          if (fb[fi] != field_name[fi]) {
            feq = 0;
            break;
          }
        }
        if (!feq)
          continue;
        ftr = pipeline_module_struct_layout_field_type_ref(m, k, j);
        return glue_field_access_load_bytes_for_type_ref(a, ftr);
      }
    }
  }
  base_tr = pipeline_expr_resolved_type_ref(a, ex->field_access_base_ref);
  /* PLATFORM: SHARED — peel TYPE_PTR base (s: *S) so the layout match runs.
   * Mirrors the .x / thin-slice twins. */
  if (base_tr > 0 && pipeline_type_kind_ord_at(a, base_tr) == 9) {
    int32_t elem_tr = pipeline_type_elem_ref_at(a, base_tr);
    if (elem_tr > 0)
      base_tr = elem_tr;
  }
  if (base_tr > 0 && pipeline_type_kind_ord_at(a, base_tr) == 8) {
    nlen = pipeline_type_named_name_into(a, base_tr, struct_name);
    if (nlen > 0 && nlen <= 63 && m) {
      for (k = 0; k < (int32_t)pipeline_module_num_struct_layouts_at(m); k++) {
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
        if (!eq)
          continue;
        for (j = 0; j < pipeline_module_struct_layout_num_fields(m, k); j++) {
          int32_t fnlen = pipeline_module_struct_layout_field_name_len(m, k, j);
          int32_t feq = 1;
          int32_t fi;
          if (fnlen != flen)
            continue;
          for (fi = 0; fi < fnlen; fi++) {
            uint8_t fb[256];
            pipeline_module_struct_layout_field_name_into(m, k, j, fb);
            if (fb[fi] != field_name[fi]) {
              feq = 0;
              break;
            }
          }
          if (!feq)
            continue;
          ftr = pipeline_module_struct_layout_field_type_ref(m, k, j);
          return glue_field_access_load_bytes_for_type_ref(a, ftr);
        }
      }
    }
  }
  tr = pipeline_expr_resolved_type_ref(a, expr_ref);
  if (tr > 0) {
    kind_ord = pipeline_type_kind_ord_at(a, tr);
    if (kind_ord != 8 && kind_ord != 10 && kind_ord != 11 && kind_ord != 12)
      return glue_field_access_load_bytes_for_type_ref(a, tr);
  }
  if (flen == 7 && memcmp(field_name, nm_is_some, 7) == 0)
    return 1;
  if (flen == 7 && memcmp(field_name, nm_is_none, 7) == 0)
    return 1;
  return 8;
}

/* wave1050 G.7 fold: glue_struct_layout_field_offset_by_name_c migrated here
 * from pipeline_glue.c (definition was at glue.c:3698). Same-TU #include at
 * glue.c:2419 makes the forward decl at L708 above visible to all 4 callsites
 * in this leaf (L811/L832/L866/L884 — all before this definition). glue.c has
 * zero self-callsites — pure leaf consumed only by field_access.c.
 *
 * glue_struct_layout_compute_field_offset_c (called by the body) is defined
 * in pipeline_asm_emit_struct_lit.c (wave1044 fold; struct_lit.c #include at
 * glue.c:2095 < field_access.c #include at glue.c:2419, so visible here). */

/**
 * Look up a struct field's dynamic byte offset by field name within a layout.
 *
 * Why: §11.1 struct layout registry — the authoritative name→offset lookup
 * consumed by field_access effective offset (4 callsites above: L811 single-
 * layout fallback; L832 named-layout; L866 single-layout fallback return;
 * L884 named-layout). Walks layout li fields comparing names byte-by-byte;
 * on match returns the cumulative offset computed by
 * glue_struct_layout_compute_field_offset_c (handles packed / aligned /
 * mixed-size fields). Returns -1 on any miss so callers fall back to the
 * fast-path offset table or default 8-byte stride.
 *
 * Invariant: returns -1 for invalid module/arena/li/name or flen<=0; returns
 * -1 when no field name matches; otherwise returns the cumulative byte offset
 * of the matched field within layout li.
 *
 * Asm/Perf: O(nf * flen) — linear scan over fields with byte-by-byte name
 * comparison. Bounded by struct field count (typically small).
 *
 * PLATFORM: SHARED — pure layout registry query; arch-agnostic.
 */
int32_t glue_struct_layout_field_offset_by_name_c(void *m, void *a, int32_t li,
                                                         uint8_t *field_name, int32_t flen) {
  int32_t j;
  if (!m || !a || li < 0 || !field_name || flen <= 0)
    return -1;
  for (j = 0; j < pipeline_module_struct_layout_num_fields(m, li); j++) {
    int32_t fnlen = pipeline_module_struct_layout_field_name_len(m, li, j);
    int32_t feq = 1;
    int32_t fi;
    if (fnlen != flen)
      continue;
    for (fi = 0; fi < fnlen; fi++) {
      uint8_t fb[256];
      pipeline_module_struct_layout_field_name_into(m, li, j, fb);
      if (fb[fi] != field_name[fi]) {
        feq = 0;
        break;
      }
    }
    if (!feq)
      continue;
    /* Prefer synced table. Import merge copies stored offsets; remapped
     * field type_refs often miss in the caller arena so recompute returns 0
     * (gzip ZStream zalloc → next_in, libz deflateInit2_ SEGV).
     * PLATFORM: SHARED. */
    {
      int32_t stored = pipeline_module_struct_layout_field_offset_at(m, li, j);
      int32_t computed = glue_struct_layout_compute_field_offset_c(m, a, li, j);
      if (stored != 0)
        return stored;
      if (computed != 0)
        return computed;
      if (j == 0)
        return 0;
      return -1;
    }
  }
  return -1;
}

/**
 * Enum variant name prefix match: parser occasionally emits field_len with +1
 * trailing zero; flen >= expected length and prefix match → hit.
 *
 * Why: pipeline_expr_enum_namespace_field_tag resolves FIELD_ACCESS on enum
 * namespace (e.g. `ExprKind.EXPR_LIT`) by comparing the field name against
 * known enum variant strings. The parser may include a trailing NUL byte in
 * the field buffer, so exact-length comparison would miss valid matches.
 * This helper centralizes the lenient prefix match so the caller does not
 * repeat strlen/memcmp pairs for every variant check.
 *
 * Invariant: returns 0 for NULL field_buf/expect or flen <= 0; returns 1 iff
 * flen >= strlen(expect) and the first strlen(expect) bytes match exactly.
 *
 * Asm/Perf: O(elen) — one strlen + one memcmp. Cold path — called per enum
 * variant probe in pipeline_expr_enum_namespace_field_tag (glue.c:4402+).
 *
 * PLATFORM: SHARED — string comparison is platform-independent.
 *
 * wave1074 G.7: migrated from glue.c:4359 (body 8 LOC). Static (non-extern):
 * same-TU — field_access.c #include at L2419 < def EOF < all callsites
 * glue.c:4402+. Dependencies: strlen / memcmp (libc, global).
 */
int glue_enum_field_name_equal(const uint8_t *field_buf, int32_t flen, const char *expect) {
  int32_t elen;
  if (!field_buf || !expect || flen <= 0)
    return 0;
  elen = (int32_t)strlen(expect);
  if (flen < elen)
    return 0;
  return memcmp(field_buf, expect, (size_t)elen) == 0;
}

/* wave1179 G.7: field_access enum/soa setter cluster (4 fns) migrated from
 * pipeline_glue.c L3155-3184 + L3203-3206 + L3217-3309. Colocated with
 * FIELD_ACCESS emit domain — all read/write ast_Expr field_access_* struct
 * fields for typeck.x and asm emit.
 *
 * Dependencies:
 * - glue_arena_expr_at_ref (static fwd decl at L712 above; defined in glue.c
 *   L2340 < field_access.c #include L2111 — wait, L2340 > L2111, so the fwd
 *   decl at L712 is required; resolved at link time via same-TU).
 * - pipeline_expr_kind_ord_at / pipeline_expr_var_name_len /
 *   pipeline_expr_var_name_into / pipeline_expr_field_access_name_len /
 *   pipeline_expr_field_access_name_into (fwd decls at L1554-1565 in glue.c
 *   < field_access.c #include L2111).
 * - pipeline_token_kind_variant_tag (extern fwd decl glue.c L1773).
 * - pipeline_expr_enum_field_tag_via_module (extern fwd decl glue.c L3208,
 *   removed and migrated below in this same wave).
 * - glue_enum_field_name_equal (static at L1169 above).
 * - g_pipeline_asm_emit_module (static global glue.c L132 — but accessed via
 *   pipeline_expr_enum_field_tag_via_module which is migrated below).
 *
 * No glue.c callsites for any of these 4 fns (sole callers are typeck_gen.c
 * / codegen_gen.c seeds via extern).
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/**
 * Write expr.field_access_is_enum_variant and enum_variant_tag.
 * Why: typeck_coerce_init_expr_to_decl X-emit must write these flags via C
 *      helper to avoid X Expr struct field assignment typeck failures.
 * Contract: no-op when arena null, expr_ref out of range, or expr ptr null.
 */
void pipeline_expr_set_field_access_enum_variant(void *a, int32_t expr_ref, int32_t tag) {
  w151_ExprMirror *ex;

  if (!a || expr_ref <= 0 || expr_ref > ((int32_t *)a)[1])
    return;
  ex = (w151_ExprMirror *)glue_arena_expr_at_ref(a, expr_ref);
  if (!ex)
    return;
  ex->field_access_is_enum_variant = 1;
  ex->enum_variant_tag = tag;
}

/** DOD-S1: write FIELD_ACCESS SoA stride (paired with field_access_offset column base). */
void pipeline_expr_set_field_access_soa_stride(void *a, int32_t expr_ref, int32_t stride) {
  void *ex = (w151_ExprMirror *)glue_arena_expr_at_ref(a, expr_ref);
  if (ex)
    ex->field_access_soa_stride = stride;
}

/** Read expr.field_access_is_enum_variant flag (1 if set, 0 otherwise). */
int32_t pipeline_expr_field_access_is_enum_variant(void *a, int32_t expr_ref) {
  void *ex = (w151_ExprMirror *)glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->field_access_is_enum_variant : 0;
}

/**
 * Look up enum variant tag for FIELD_ACCESS on enum namespace base
 * (e.g. ExprKind.EXPR_LIT, TypeKind.TYPE_I32, TokenKind.TOKEN_EOF).
 * Why: typeck/asm-emit FIELD_ACCESS on enum-typed base VAR must resolve the
 *      variant tag at compile time; this scans ExprKind/TypeKind/TokenKind
 *      built-in tables + module enum sidecar via pipeline_expr_enum_field_tag_via_module.
 * Contract: returns -1 when arena null, expr_ref out of range, expr kind != 44
 *           (FIELD_ACCESS), base ref invalid, base kind != 3 (VAR), or no
 *           matching enum variant found.
 * Dependencies: pipeline_expr_kind_ord_at + pipeline_expr_var_name_len/into
 *               + pipeline_expr_field_access_name_len/into + glue_enum_field_name_equal
 *               + pipeline_token_kind_variant_tag + pipeline_expr_enum_field_tag_via_module.
 */
int32_t pipeline_expr_enum_namespace_field_tag(void *a, int32_t expr_ref) {
  w151_ExprMirror *ex;
  uint8_t base_buf[32];
  uint8_t field_buf[256];
  int32_t blen, flen;
  if (!a || expr_ref <= 0 || pipeline_expr_kind_ord_at(a, expr_ref) != 44)
    return -1;
  ex = (w151_ExprMirror *)glue_arena_expr_at_ref(a, expr_ref);
  if (!ex)
    return -1;
  if (ex->field_access_base_ref <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(a, ex->field_access_base_ref) != 3)
    return -1;
  blen = pipeline_expr_var_name_len(a, ex->field_access_base_ref);
  if (blen <= 0 || blen > 31)
    return -1;
  pipeline_expr_var_name_into(a, ex->field_access_base_ref, base_buf);
  flen = pipeline_expr_field_access_name_len(a, expr_ref);
  if (flen <= 0 || flen > 255)
    return -1;
  pipeline_expr_field_access_name_into(a, expr_ref, field_buf);
  /* Class AY: Cap XLANG_ASM_EMIT_TRACE note retired. */
  if (blen == 8 && memcmp(base_buf, "ExprKind", 8) == 0) {
    if (glue_enum_field_name_equal(field_buf, flen, "EXPR_LIT"))
      return 0;
    if (glue_enum_field_name_equal(field_buf, flen, "EXPR_FIELD_ACCESS"))
      return 44;
    if (glue_enum_field_name_equal(field_buf, flen, "EXPR_CALL"))
      return 48;
    if (glue_enum_field_name_equal(field_buf, flen, "EXPR_VAR"))
      return 3;
    if (glue_enum_field_name_equal(field_buf, flen, "EXPR_BLOCK"))
      return 26;
  }
  if (blen == 8 && memcmp(base_buf, "TypeKind", 8) == 0) {
    if (glue_enum_field_name_equal(field_buf, flen, "TYPE_I32"))
      return 0;
    if (glue_enum_field_name_equal(field_buf, flen, "TYPE_BOOL"))
      return 1;
    if (glue_enum_field_name_equal(field_buf, flen, "TYPE_U8"))
      return 2;
    if (glue_enum_field_name_equal(field_buf, flen, "TYPE_U32"))
      return 3;
    if (glue_enum_field_name_equal(field_buf, flen, "TYPE_U64"))
      return 4;
    if (glue_enum_field_name_equal(field_buf, flen, "TYPE_I64"))
      return 5;
    if (glue_enum_field_name_equal(field_buf, flen, "TYPE_USIZE"))
      return 6;
    if (glue_enum_field_name_equal(field_buf, flen, "TYPE_ISIZE"))
      return 7;
    if (glue_enum_field_name_equal(field_buf, flen, "TYPE_NAMED"))
      return 8;
    if (glue_enum_field_name_equal(field_buf, flen, "TYPE_PTR"))
      return 9;
    if (glue_enum_field_name_equal(field_buf, flen, "TYPE_ARRAY"))
      return 10;
    if (glue_enum_field_name_equal(field_buf, flen, "TYPE_SLICE"))
      return 11;
    if (glue_enum_field_name_equal(field_buf, flen, "TYPE_VECTOR"))
      return 12;
    if (glue_enum_field_name_equal(field_buf, flen, "TYPE_F32"))
      return 13;
    if (glue_enum_field_name_equal(field_buf, flen, "TYPE_F64"))
      return 14;
    if (glue_enum_field_name_equal(field_buf, flen, "TYPE_VOID"))
      return 15;
  }
  /** import token.x TokenKind: fast path via pipeline_token_kind_variant_tag; here only module sidecar fallback. */
  if (blen == 9 && memcmp(base_buf, "TokenKind", 9) == 0) {
    int32_t tk = pipeline_token_kind_variant_tag(field_buf, flen);
    if (tk >= 0)
      return tk;
  }
  {
    int32_t mod_tag = pipeline_expr_enum_field_tag_via_module(base_buf, blen, field_buf, flen);
    /* Class AY: Cap XLANG_ASM_EMIT_TRACE note retired. */
    if (mod_tag >= 0)
      return mod_tag;
  }
  return -1;
}

/* wave1179 G.7: pipeline_expr_enum_field_tag_via_module migrated from
 * pipeline_glue.c L3419-3425. Colocated with FIELD_ACCESS emit domain —
 * called only by pipeline_expr_enum_namespace_field_tag above (now in same
 * file). Reads g_pipeline_asm_emit_module to look up enum variant tag via
 * module enum sidecar.
 *
 * Dependencies: g_pipeline_asm_emit_module (static global in glue.c L132 <
 *   field_access.c #include L2111 — visible via same-TU) +
 *   pipeline_module_enum_variant_tag_for_names (fwd decl glue.c L129).
 * No glue.c callsites other than the forward decl at L3208 (also removed).
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/** Look up enum variant tag by module enum sidecar (e.g. TokenKind.TOKEN_EOF); -1 if not found. */
int32_t pipeline_expr_enum_field_tag_via_module(uint8_t *enum_name, int32_t enum_len, uint8_t *variant_name,
                                                int32_t variant_len) {
  if (!g_pipeline_asm_emit_module)
    return -1;
  return pipeline_module_enum_variant_tag_for_names(g_pipeline_asm_emit_module, enum_name, enum_len, variant_name,
                                                   variant_len);
}

