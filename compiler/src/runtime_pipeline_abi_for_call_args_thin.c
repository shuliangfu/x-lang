/* Source-faithful pipeline_asm_emit_expr_elf_for_call_args twin
 * (compiler/src/runtime_pipeline_abi_for_call_args_thin.x).
 * s162 hello-build residual: uninstrumented compile_rc=3221225477
 * (0xC0000005) in ~0.39s, no output. first-chance / DEBUG_ONLY_THIS_PROCESS
 * plus HW write watch (armed after typool glue_sysv_x86_call_n_stack_c
 * returned) pinned first-wins typool pipeline_asm_emit_expr_elf_for_call_args
 * T 0x14007d160 at +0x2be (0x14007d41e...): typool prologue stack-probes
 * 0xb318, then lea rax,[rbp-0x50]; mov rbx,rax, then expanded
 * mov BYTE PTR [rbx+imm8], al with al=0 through saved rbp and the
 * return slot at rbp+8=0x103eea48 (rsp at crash 0x103eea50), then
 * execute-at-0 (write=8 DEP, RIP=0). Family is typool u8[N]=[]
 * shallow-lea zeroing expansion (same class as emit_method_body / s52).
 * typool n_stack entered and returned normally and was not folded.
 * typool lookup / typool note / typool enc_* / typool store-or-load /
 * typool glue_module_func_index_by_name / typool
 * glue_asm_build_call_export_sym_c / typool glue_asm_build_dep_export_sym_c
 * were not this writer and were not folded. Later arms in this same
 * function are included only because they live in the proven typool
 * symbol, not as a batch fold of cousins. Host-cc memset/loops for
 * = [] slots; keep the frame pad but do not zero the whole pad.
 * Do not idx8. Do not rewrite the existing .x into a stub.
 */
#include <stdint.h>
#include <string.h>

int32_t asm_ctx_scope_block_ref_at(uint8_t *ctx);
int32_t asm_type_is_simd_vector_spelling(uint8_t *arena, int32_t type_ref);
int32_t backend_enc_add_imm_to_rax_arch(uint8_t *elf_ctx, int32_t imm, int32_t ta);
int32_t backend_enc_lea_rbp_to_rax_arch(uint8_t *elf_ctx, int32_t offset, int32_t ta);
int32_t backend_enc_load_64_from_rax_arch(uint8_t *elf_ctx, int32_t ta);
int32_t backend_enc_load_i32_indirect_to_rax_arch(uint8_t *elf_ctx, int32_t ta);
int32_t backend_enc_load_rbp_to_rax_arch(uint8_t *elf_ctx, int32_t offset, int32_t ta);
int32_t backend_enc_load_rbp_to_rdx_arch(uint8_t *elf_ctx, int32_t offset, int32_t ta);
int32_t backend_enc_load_zext8_from_rax_arch(uint8_t *elf_ctx, int32_t ta);
int32_t backend_enc_mov_imm64_to_rax_arch(uint8_t *elf_ctx, int32_t lo, int32_t hi, int32_t ta);
int32_t backend_enc_mov_rax_to_arg_reg_arch(uint8_t *elf_ctx, int32_t k, int32_t ta);
int32_t backend_enc_mov_rax_to_rbx_arch(uint8_t *elf_ctx, int32_t ta);
int32_t backend_enc_pop_rax_arch(uint8_t *elf_ctx, int32_t ta);
int32_t backend_enc_push_rax_arch(uint8_t *elf_ctx, int32_t ta);
int32_t backend_enc_store_rax_to_rbp_arch(uint8_t *elf_ctx, int32_t offset, int32_t ta);
int32_t backend_enc_store_rax_to_rbx_offset_arch(uint8_t *elf_ctx, int32_t off, int32_t load_sz, int32_t ta);
int32_t backend_enc_store_rdx_to_rbp_arch(uint8_t *elf_ctx, int32_t slot_off, int32_t ta);
void glue_align_next_offset(uint8_t *ctx);
int32_t glue_array_lit_force_esz_from_elem_type_c(uint8_t *arena, int32_t et);
int32_t glue_asm_emit_array_lit_durable_ptr_rax_elf_c(uint8_t *arena, uint8_t *elf_ctx, int32_t expr_ref, int32_t force_esz, int32_t ta, uint8_t *ctx, int32_t dest_elem_ty);
int32_t glue_asm_resolve_call_target_module_c(uint8_t *arena, int32_t call_expr_ref, uint8_t *mod_out, int32_t *func_ix_out, int32_t *dep_ix_out);
int32_t glue_call_arg_resolve_var_stack_off_elf_c(uint8_t *arena, uint8_t *ctx, int32_t var_expr_ref);
int32_t glue_call_arg_var_use_lea_not_load_elf_c(uint8_t *arena, int32_t expr_ref, uint8_t *ctx);
int32_t glue_call_param_named_struct_pass_addr_elf_c(uint8_t *arena, int32_t pty);
int32_t glue_emit_float_lit_to_rax_elf_c(uint8_t *arena, uint8_t *elf_ctx, int32_t expr_ref, int32_t ta, int32_t force_ty_ref, int32_t call_abi_widen_f64);
int32_t glue_emit_func_param_is_indirect_array_slot_c(uint8_t *arena, uint8_t *mod, int32_t var_expr_ref);
int32_t glue_emit_index_eff_addr_scaled_elf_c(uint8_t *arena, uint8_t *elf_ctx, int32_t ix_ref, int32_t base_ref, int32_t idx_ref, uint8_t *ctx, int32_t ta, int32_t esz);
int32_t glue_emit_vector_type_let_init_elf_c(uint8_t *arena, uint8_t *elf_ctx, int32_t init_ref, uint8_t *ctx, int32_t ta, int32_t stack_slot_off, int32_t type_ref);
int32_t glue_enc_local_slot_ptr_or_addr_elf_c(uint8_t *arena, uint8_t *elf_ctx, int32_t var_ref, int32_t var_off, uint8_t *ctx, int32_t ta);
int32_t glue_field_access_field_type_ref_c(uint8_t *arena, uint8_t *mod, int32_t fa_ref);
int32_t glue_fixed_array_total_bytes_c(uint8_t *arena, int32_t ty_ref, int32_t depth);
int32_t glue_emit_bulk_mem_copy_spills_elf_c(uint8_t *elf_ctx, int32_t src_spill, int32_t dst_spill, int32_t nbytes, int32_t ta);
int32_t glue_index_elem_byte_sz_from_type_ref_c(uint8_t *arena, int32_t tr);
int32_t glue_load_f32_var_slot_to_rax_elf_c(uint8_t *elf_ctx, uint8_t *arena, uint8_t *ctx, int32_t var_expr_ref, int32_t off, int32_t ta);
int32_t glue_load_var_as_value_to_rax_rdx_elf_c(uint8_t *elf_ctx, uint8_t *arena, uint8_t *ctx, int32_t var_expr_ref, int32_t off, int32_t ta);
int32_t glue_peel_as_array_slice_ascription_c(uint8_t *arena, int32_t expr_ref);
void glue_slice_dual_gp_bump_past_home_c(uint8_t *ctx, int32_t data_home, int32_t ta);
int32_t glue_slice_dual_gp_length_off_c(int32_t data_home, int32_t ta);
int32_t glue_slice_let_reent_deep_copy_after_dual_gp_elf_c(uint8_t *arena, uint8_t *elf_ctx, uint8_t *ctx, int32_t ta, int32_t home, int32_t ty_ref, int32_t use_frame);
int32_t glue_try_index_var_or_field_base_to_rax_elf_c(uint8_t *arena, uint8_t *elf_ctx, int32_t base_ref, uint8_t *ctx, int32_t ta);
int32_t glue_type_is_fixed_array(uint8_t *arena, int32_t type_ref);
int32_t glue_vector_type_lanes_esz_c(uint8_t *arena, int32_t type_ref, int32_t *out_lanes, int32_t *out_esz);
int32_t pipe_asm_ctx_off_next_offset();
int32_t pipe_load_i32_le(uint8_t *base, int32_t off);
uint8_t *pipe_load_ptr_slot(uint8_t *base, int32_t i);
void pipe_store_i32_le(uint8_t *base, int32_t off, int32_t v);
void pipe_store_ptr_slot(uint8_t *base, int32_t i, uint8_t *val);
int32_t pipeline_asm_abi_f32_xmm_enabled_c();
void pipeline_asm_bump_next_offset_for_array_lit(uint8_t *arena, int32_t expr_ref, uint8_t *ctx);
int32_t pipeline_asm_call_return_type_kind_ord_c(uint8_t *arena, int32_t call_expr_ref);
int32_t pipeline_asm_emit_array_lit_force_esz_elf_c(uint8_t *arena, uint8_t *elf_ctx, int32_t expr_ref, uint8_t *ctx, int32_t ta, int32_t force_esz);
int32_t pipeline_asm_emit_ctx_call_param_ty_get();
uint8_t *pipeline_asm_emit_dep_pipe_c();
int32_t pipeline_asm_emit_expr_elf_rec(uint8_t *arena, uint8_t *elf_ctx, int32_t expr_ref, uint8_t *ctx, int32_t ta);
int32_t pipeline_asm_emit_lvalue_eff_addr_elf_c(uint8_t *arena, uint8_t *elf_ctx, int32_t lval_ref, uint8_t *ctx, int32_t ta);
uint8_t *pipeline_asm_emit_module_ref_c();
int32_t pipeline_block_resolve_var_type_ref(uint8_t *arena, int32_t block_ref, uint8_t *vname, int32_t vlen);
int32_t pipeline_expr_array_lit_num_elems_at(uint8_t *arena, int32_t expr_ref);
int32_t pipeline_expr_index_base_ref(uint8_t *arena, int32_t expr_ref);
int32_t pipeline_expr_index_index_ref(uint8_t *arena, int32_t expr_ref);
int32_t pipeline_expr_binop_left_ref_at(uint8_t *arena, int32_t expr_ref);
int32_t pipeline_expr_binop_right_ref_at(uint8_t *arena, int32_t expr_ref);
int32_t pipeline_expr_block_ref_at(uint8_t *arena, int32_t expr_ref);
int32_t pipeline_expr_kind_ord_at(uint8_t *arena, int32_t expr_ref);
int32_t pipeline_expr_resolved_type_ref(uint8_t *arena, int32_t expr_ref);
int32_t pipeline_expr_unary_operand_ref_at(uint8_t *arena, int32_t expr_ref);
int32_t ast_ast_block_final_expr_ref(uint8_t *arena, int32_t block_ref);
int32_t glue_is_vector_lane_scalar_binop_ko(int32_t ko);
void pipeline_expr_var_name_into(uint8_t *arena, int32_t expr_ref, uint8_t *out64);
int32_t pipeline_expr_var_name_len(uint8_t *arena, int32_t expr_ref);
int32_t pipeline_module_func_return_type_at(uint8_t *mod, int32_t fi);
int32_t pipeline_type_array_size_at(uint8_t *arena, int32_t ref);
int32_t pipeline_type_elem_ref_at(uint8_t *arena, int32_t ref);
int32_t pipeline_type_kind_ord_at(uint8_t *arena, int32_t ref);
int32_t pipeline_typeck_get_dep_return_type_in_caller_arena_c(int32_t from_dep_index, int32_t dep_return_type_ref, uint8_t *caller_arena, uint8_t *ctx);

int32_t pipeline_asm_emit_expr_elf_for_call_args(
    uint8_t *arena, uint8_t *elf_ctx, int32_t expr_ref, uint8_t *ctx, int32_t ta) {
  {
  // note743y.5: tip under-counts nested-block homes (frame was 0xd98, slots to
  // -0x1a00); slice_hit/tk_* landed past rsp and became non-zero → false lea.
  // Function-scope pad forces tip frame ≥ deepest slot. Do not remove.
  // Official typool of `u8[16384] = []` can unroll 256 zero-bytes from a
  // shallow slot through the return address (same class as emit_method_body).
  // Keep the pad allocation; do not zero-init the whole array. Touch only [0].
  uint8_t _frame_pad_y5[16384];
  _frame_pad_y5[0] = 0;
  int32_t pty = 0;
  int32_t call_abi_widen_f64 = 1;
  int32_t tr = 0;
  int32_t ko = 0;
  int32_t off = 0;
  int32_t vlen = 0;
  uint8_t vname[256];
  memset(vname, 0, sizeof(vname));
  int32_t want_slice = 0;
  int32_t arg_ty = 0;
  int32_t decl_ty = 0;
  int32_t arr_sz = 0;
  int32_t scope_br = 0;
  int32_t home = 0;
  int32_t base_off = 0;
  int32_t rc = 0;
  uint8_t *emit_mod = ((uint8_t *)0);
  int32_t fty = 0;
  int32_t rty = 0;
  int32_t want_arr = 0;
  int32_t is_arr = 0;
  int32_t br = 0;
  int32_t use_lea = 0;
  int32_t slice_ty = 0;
  int32_t n_arr = 0;
  int32_t force_esz = 0;
  int32_t durable = 0;
  int32_t esz = 4;
  int32_t payload_bytes = 0;
  int32_t past = 0;
  int32_t ret_kind = 0 - 1;
  uint8_t *rmod = ((uint8_t *)0);
  int32_t rfi = 0 - 1;
  int32_t rdep = 0 - 1;
  int32_t rrty = 0;
  int32_t mapped = 0;
  uint8_t mod_slot[8];
  memset(mod_slot, 0, sizeof(mod_slot));
  int32_t fi_slot[1];
  memset(fi_slot, 0, sizeof(fi_slot));
  int32_t dep_slot[1];
  memset(dep_slot, 0, sizeof(dep_slot));
  uint8_t *dep_pipe = ((uint8_t *)0);
  int32_t spill_off = 0;
  int32_t payload_off = 0;
  int32_t ai = 0;
  int32_t elem_tr = 0;
  int32_t simd_ty = 0;
  int32_t lanes = 0;
  int32_t vec_nbytes = 0;
  int32_t vec_reserve = 0;
  int32_t walk_cur = 0;
  int32_t walk_fin = 0;
  int32_t walk_sp = 0;
  int32_t walk_steps = 0;
  int32_t walk_cand = 0;
  int32_t walk_br = 0;
  int32_t walk_child = 0;
  int32_t walk_ko = 0;
  int32_t walk_push = 0;
  int32_t walk_stk[128];
  memset(walk_stk, 0, sizeof(walk_stk));
  // Kind ords (ast_ExprKind / TypeKind single authority).
  int32_t kind_int_lit = 1;
  int32_t kind_var = 3;
  int32_t kind_field = 44;
  int32_t kind_array_lit = 46;
  int32_t kind_index = 47;
  int32_t kind_call = 48;
  int32_t kind_method = 49;
  int32_t type_ptr = 9;
  int32_t type_array = 10;
  int32_t type_slice = 11;
  int32_t type_f32 = 14; // GLUE_TYPE_KIND_F32_ORD
  int32_t array_lit_max = 1024;

  // XLANG_ABI_F32_XMM=1 → native f32 bits; else legacy f64 widen via gp.
  {
    int32_t f32_xmm = 0;
    { f32_xmm = pipeline_asm_abi_f32_xmm_enabled_c(); }
    if (f32_xmm != 0) {
      call_abi_widen_f64 = 0;
    } else {
      call_abi_widen_f64 = 1;
    }
  }

  // --- f32 INT_LIT / float lit as f32 formal ---
  if (arena != ((uint8_t *)0)) {
    { ko = pipeline_expr_kind_ord_at(arena, expr_ref); }
    if (ko == kind_int_lit) {
      { tr = pipeline_expr_resolved_type_ref(arena, expr_ref); }
      if (tr > 0) {
        { rc = pipeline_type_kind_ord_at(arena, tr); }
        if (rc == type_f32) {
          return glue_emit_float_lit_to_rax_elf_c(arena, elf_ctx, expr_ref, ta, tr, call_abi_widen_f64);
        }
      }
      { pty = pipeline_asm_emit_ctx_call_param_ty_get(); }
      if (pty > 0) {
        { rc = pipeline_type_kind_ord_at(arena, pty); }
        if (rc == type_f32) {
          return glue_emit_float_lit_to_rax_elf_c(arena, elf_ctx, expr_ref, ta, pty, call_abi_widen_f64);
        }
      }
    }
  }

  { pty = pipeline_asm_emit_ctx_call_param_ty_get(); }

  // Identity ARRAY/SLICE ascription: take(a as [2]i32) must see VAR/INDEX.
  // G.7 reuse glue_peel. Scalar 5 as i32 stays wrapped.
  // PLATFORM: SHARED freestanding.
  if (arena != ((uint8_t *)0) && expr_ref > 0) {
    { br = glue_peel_as_array_slice_ascription_c(arena, expr_ref); }
    if (br > 0) {
      expr_ref = br;
    }
  }

  // --- VAR local stack home packing ---
  if (arena != ((uint8_t *)0) && ctx != ((uint8_t *)0)) {
    { ko = pipeline_expr_kind_ord_at(arena, expr_ref); }
    if (ko == kind_var) {
      off = glue_call_arg_resolve_var_stack_off_elf_c(arena, ctx, expr_ref);
      if (off >= 0) {
        { vlen = pipeline_expr_var_name_len(arena, expr_ref); }
        if (vlen > 0 && vlen <= 63) {
          { pipeline_expr_var_name_into(arena, expr_ref, &vname[0]); }
          // wave395: fixed TYPE_ARRAY local as TYPE_SLICE formal → dual-GP fat + lea.
          want_slice = 0;
          if (pty > 0) {
            { rc = pipeline_type_kind_ord_at(arena, pty); }
            if (rc == type_slice) { want_slice = 1; }
          }
          { arg_ty = pipeline_expr_resolved_type_ref(arena, expr_ref); }
          decl_ty = 0;
          { scope_br = asm_ctx_scope_block_ref_at(ctx); }
          if (scope_br > 0) {
            { decl_ty = pipeline_block_resolve_var_type_ref(arena, scope_br, &vname[0], vlen); }
          }
          if (decl_ty <= 0) { decl_ty = arg_ty; }
          arr_sz = 0;
          if (decl_ty > 0 && glue_type_is_fixed_array(arena, decl_ty) != 0) {
            { arr_sz = pipeline_type_array_size_at(arena, decl_ty); }
          }
          if (arr_sz <= 0 && arg_ty > 0) {
            { rc = pipeline_type_kind_ord_at(arena, arg_ty); }
            if (rc == type_array) {
              { arr_sz = pipeline_type_array_size_at(arena, arg_ty); }
            }
          }
          if (want_slice != 0 && arr_sz > 0) {
            if (elf_ctx == ((uint8_t *)0)) { return 0 - 1; }
            base_off = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
            if ((base_off % 8) != 0) { base_off = (base_off + 7) / 8 * 8; }
            home = base_off + 16;
            if (ta == 1) { pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), home + 16); }
            else { pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), home + 8); }
            glue_align_next_offset(ctx);
            { rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, off, ta); }
            if (rc != 0) { return 0 - 1; }
            { rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta); }
            if (rc != 0) { return 0 - 1; }
            { rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, arr_sz, 0, ta); }
            if (rc != 0) { return 0 - 1; }
            { rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(home, ta), ta); }
            if (rc != 0) { return 0 - 1; }
            { rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta); }
            if (rc != 0) { return 0 - 1; }
            return 0;
          }
          if (glue_call_arg_var_use_lea_not_load_elf_c(arena, expr_ref, ctx) != 0) {
            { return backend_enc_lea_rbp_to_rax_arch(elf_ctx, off, ta); }
          }
          if (pty > 0) {
            { rc = pipeline_type_kind_ord_at(arena, pty); }
            if (rc == type_f32) {
              return glue_load_f32_var_slot_to_rax_elf_c(elf_ctx, arena, ctx, expr_ref, off, ta);
            }
          }
          // wave417: T[N] formal home is E* — load pointer only.
          emit_mod = pipeline_asm_emit_module_ref_c();
          if (emit_mod != ((uint8_t *)0) && glue_emit_func_param_is_indirect_array_slot_c(arena, emit_mod, expr_ref) != 0) {
            { return backend_enc_load_rbp_to_rax_arch(elf_ctx, off, ta); }
          }
          // TYPE_SLICE formal, or a VAR whose resolved type is TYPE_SLICE:
          // fat pointer via local_slot ptr-or-addr (wave401).
          // Two statements, not `||`. The right-hand `==` of one `||` was
          // compared with the left sete result left in eax. That result is
          // 0 when the formal is not a slice, and TYPE_I32's ordinal is 0,
          // so every i32 argument took the address path. Each statement
          // reloads type_slice on its own.
          // PLATFORM: SHARED — x86_64 SysV, x86_64 Win64, ARM64.
          {
            int32_t tk_pty = 0;
            int32_t tk_arg = 0;
            int32_t slice_hit = 0;
            if (pty > 0) {
              { tk_pty = pipeline_type_kind_ord_at(arena, pty); }
            }
            if (arg_ty > 0) {
              { tk_arg = pipeline_type_kind_ord_at(arena, arg_ty); }
            }
            if (tk_pty == type_slice) { slice_hit = 1; }
            if (tk_arg == type_slice) { slice_hit = 1; }
            if (slice_hit != 0) {
              return glue_enc_local_slot_ptr_or_addr_elf_c(arena, elf_ctx, expr_ref, off, ctx, ta);
            }
          }
          return glue_load_var_as_value_to_rax_rdx_elf_c(elf_ctx, arena, ctx, expr_ref, off, ta);
        }
      }
    }
  }

  // --- FIELD_ACCESS fixed TYPE_ARRAY as TYPE_SLICE formal (wave396/649) ---
  if (arena != ((uint8_t *)0) && ctx != ((uint8_t *)0) && elf_ctx != ((uint8_t *)0)) {
    { ko = pipeline_expr_kind_ord_at(arena, expr_ref); }
    if (ko == kind_field) {
      want_slice = 0;
      if (pty > 0) {
        { rc = pipeline_type_kind_ord_at(arena, pty); }
        if (rc == type_slice) { want_slice = 1; }
      }
      if (want_slice != 0) {
        emit_mod = pipeline_asm_emit_module_ref_c();
        fty = glue_field_access_field_type_ref_c(arena, emit_mod, expr_ref);
        arr_sz = 0;
        if (fty > 0 && glue_type_is_fixed_array(arena, fty) != 0) {
          { arr_sz = pipeline_type_array_size_at(arena, fty); }
        }
        { rty = pipeline_expr_resolved_type_ref(arena, expr_ref); }
        if (arr_sz <= 0 && rty > 0) {
          { rc = pipeline_type_kind_ord_at(arena, rty); }
          if (rc == type_array) {
            { arr_sz = pipeline_type_array_size_at(arena, rty); }
          }
        }
        if (arr_sz > 0) {
          base_off = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
          if ((base_off % 8) != 0) { base_off = (base_off + 7) / 8 * 8; }
          home = base_off + 16;
          if (ta == 1) { pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), home + 16); }
          else { pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), home + 8); }
          glue_align_next_offset(ctx);
          br = glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
          if (br != 0) { return 0 - 1; }
          { rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta); }
          if (rc != 0) { return 0 - 1; }
          { rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, arr_sz, 0, ta); }
          if (rc != 0) { return 0 - 1; }
          { rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(home, ta), ta); }
          if (rc != 0) { return 0 - 1; }
          { rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta); }
          if (rc != 0) { return 0 - 1; }
          return 0;
        }
      }
    }
  }

  // --- INDEX of [K][N]T / [][N]T as TYPE_SLICE formal ---
  // take(a[i]): N+esz from INDEX resolved TYPE_ARRAY, else base elem.
  // lea via scaled (do not emit_index — dest-SLICE stamp would load a 16B fat).
  // Caller-frame fat* in rax. PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
  if (arena != ((uint8_t *)0) && ctx != ((uint8_t *)0) && elf_ctx != ((uint8_t *)0)) {
    { ko = pipeline_expr_kind_ord_at(arena, expr_ref); }
    if (ko == kind_index) {
      want_slice = 0;
      if (pty > 0) {
        { rc = pipeline_type_kind_ord_at(arena, pty); }
        if (rc == type_slice) { want_slice = 1; }
      }
      if (want_slice != 0) {
        arr_sz = 0;
        force_esz = 0;
        { rty = pipeline_expr_resolved_type_ref(arena, expr_ref); }
        if (rty > 0) {
          { rc = pipeline_type_kind_ord_at(arena, rty); }
          if (rc == type_array) {
            { arr_sz = pipeline_type_array_size_at(arena, rty); }
            force_esz = glue_fixed_array_total_bytes_c(arena, rty, 0);
          }
        }
        if (arr_sz <= 0 || force_esz <= 0) {
          { br = pipeline_expr_index_base_ref(arena, expr_ref); }
          if (br > 0) {
            { fty = pipeline_expr_resolved_type_ref(arena, br); }
            if (fty > 0) {
              { rc = pipeline_type_kind_ord_at(arena, fty); }
              if (rc == type_array || rc == type_slice) {
                { fty = pipeline_type_elem_ref_at(arena, fty); }
                if (fty > 0) {
                  { rc = pipeline_type_kind_ord_at(arena, fty); }
                  if (rc == type_array) {
                    { arr_sz = pipeline_type_array_size_at(arena, fty); }
                    force_esz = glue_fixed_array_total_bytes_c(arena, fty, 0);
                  }
                }
              }
            }
          }
        }
        if (arr_sz > 0 && force_esz > 0) {
          { br = pipeline_expr_index_base_ref(arena, expr_ref); }
          { n_arr = pipeline_expr_index_index_ref(arena, expr_ref); }
          if (br > 0 && n_arr > 0) {
            base_off = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
            if ((base_off % 8) != 0) { base_off = (base_off + 7) / 8 * 8; }
            home = base_off + 16;
            if (ta == 1) { pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), home + 16); }
            else { pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), home + 8); }
            glue_align_next_offset(ctx);
            {
              rc = glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, expr_ref, br, n_arr, ctx, ta, force_esz);
            }
            if (rc != 0) { return 0 - 1; }
            { rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta); }
            if (rc != 0) { return 0 - 1; }
            { rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, arr_sz, 0, ta); }
            if (rc != 0) { return 0 - 1; }
            { rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(home, ta), ta); }
            if (rc != 0) { return 0 - 1; }
            { rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta); }
            if (rc != 0) { return 0 - 1; }
            return 0;
          }
        }
      }
    }
  }

  // --- FIELD_ACCESS fixed TYPE_ARRAY as TYPE_ARRAY formal E* (wave610/651) ---
  if (arena != ((uint8_t *)0) && ctx != ((uint8_t *)0) && elf_ctx != ((uint8_t *)0)) {
    { ko = pipeline_expr_kind_ord_at(arena, expr_ref); }
    if (ko == kind_field) {
      want_arr = 0;
      if (pty > 0) {
        { rc = pipeline_type_kind_ord_at(arena, pty); }
        if (rc == type_array || glue_type_is_fixed_array(arena, pty) != 0) { want_arr = 1; }
      }
      if (want_arr != 0) {
        emit_mod = pipeline_asm_emit_module_ref_c();
        fty = glue_field_access_field_type_ref_c(arena, emit_mod, expr_ref);
        is_arr = 0;
        if (fty > 0 && glue_type_is_fixed_array(arena, fty) != 0) { is_arr = 1; }
        { rty = pipeline_expr_resolved_type_ref(arena, expr_ref); }
        if (is_arr == 0 && rty > 0) {
          { rc = pipeline_type_kind_ord_at(arena, rty); }
          if (rc == type_array) { is_arr = 1; }
        }
        if (is_arr != 0) {
          br = glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
          if (br == 0) { return 0; }
          if (br == (0 - 1)) { return 0 - 1; }
          // -2: fall through
        }
      }
    }
  }

  // --- FIELD_ACCESS fixed TYPE_ARRAY as TYPE_PTR formal: array decay ---
  // `f(s.a)` / `f(ps.a)` / `f(o.in.a)` with `a: E[N]` and formal `*E`
  // passes the address of the first element, never the first 8 bytes of
  // the array. The generic FIELD rvalue path scalar-loads the field, so
  // take the field lvalue address here. Register and stack (7th+) args
  // both pack through this function. PLATFORM: SHARED — x86_64 SysV,
  // x86_64 Win64 (same ta == 0 packer) and ARM64 AAPCS64.
  if (arena != ((uint8_t *)0) && ctx != ((uint8_t *)0) && elf_ctx != ((uint8_t *)0) && pty > 0) {
    { ko = pipeline_expr_kind_ord_at(arena, expr_ref); }
    if (ko == kind_field) {
      { rc = pipeline_type_kind_ord_at(arena, pty); }
      if (rc == type_ptr) {
        emit_mod = pipeline_asm_emit_module_ref_c();
        fty = glue_field_access_field_type_ref_c(arena, emit_mod, expr_ref);
        is_arr = 0;
        if (fty > 0 && glue_type_is_fixed_array(arena, fty) != 0) { is_arr = 1; }
        { rty = pipeline_expr_resolved_type_ref(arena, expr_ref); }
        if (is_arr == 0 && rty > 0) {
          { rc = pipeline_type_kind_ord_at(arena, rty); }
          if (rc == type_array) { is_arr = 1; }
        }
        if (is_arr != 0) {
          return pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
        }
      }
    }
  }

  // --- FIELD_ACCESS named struct pass-by-addr (>16B MEMORY) ---
  if (arena != ((uint8_t *)0) && ctx != ((uint8_t *)0)) {
    { ko = pipeline_expr_kind_ord_at(arena, expr_ref); }
    if (ko == kind_field) {
      use_lea = 0;
      if (pty > 0 && glue_call_param_named_struct_pass_addr_elf_c(arena, pty) != 0) { use_lea = 1; }
      if (use_lea == 0) {
        emit_mod = pipeline_asm_emit_module_ref_c();
        fty = glue_field_access_field_type_ref_c(arena, emit_mod, expr_ref);
        if (fty > 0 && glue_call_param_named_struct_pass_addr_elf_c(arena, fty) != 0) { use_lea = 1; }
      }
      if (use_lea != 0) {
        return pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
      }
    }
  }

  // --- ARRAY_LIT as TYPE_SLICE formal (wave332/622/625) ---
  if (arena != ((uint8_t *)0) && ctx != ((uint8_t *)0) && elf_ctx != ((uint8_t *)0)) {
    { ko = pipeline_expr_kind_ord_at(arena, expr_ref); }
    if (ko == kind_array_lit) {
      slice_ty = 0;
      if (pty > 0) {
        { rc = pipeline_type_kind_ord_at(arena, pty); }
        if (rc == type_slice) { slice_ty = pty; }
      }
      { rty = pipeline_expr_resolved_type_ref(arena, expr_ref); }
      if (slice_ty == 0 && rty > 0) {
        { rc = pipeline_type_kind_ord_at(arena, rty); }
        if (rc == type_slice) { slice_ty = rty; }
      }
      if (slice_ty > 0) {
        int32_t et = 0;
        { n_arr = pipeline_expr_array_lit_num_elems_at(arena, expr_ref); }
        if (n_arr < 0 || n_arr > array_lit_max) { return 0 - 1; }
        { et = pipeline_type_elem_ref_at(arena, slice_ty); }
        force_esz = glue_array_lit_force_esz_from_elem_type_c(arena, et);
        base_off = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
        if ((base_off % 8) != 0) { base_off = (base_off + 7) / 8 * 8; }
        home = base_off + 16;
        esz = 4;
        if (force_esz > 0) { esz = force_esz; }
        if (ta == 1) { past = home + 16; } else { past = home + 8; }
        payload_bytes = n_arr * esz;
        if (payload_bytes < 0) { payload_bytes = 0; }
        if (payload_bytes > 0 && home + payload_bytes > past) { past = home + payload_bytes; }
        pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), past);
        glue_align_next_offset(ctx);
        durable = 0;
        if ((ta == 0 || ta == 1) && glue_asm_emit_array_lit_durable_ptr_rax_elf_c(arena, elf_ctx, expr_ref, force_esz, ta, ctx, et) == 0) {
          durable = 1;
        } else {
          if (pipeline_asm_emit_array_lit_force_esz_elf_c(arena, elf_ctx, expr_ref, ctx, ta, force_esz) != 0) {
            return 0 - 1;
          }
        }
        { rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta); }
        if (rc != 0) { return 0 - 1; }
        { rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_arr, 0, ta); }
        if (rc != 0) { return 0 - 1; }
        { rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(home, ta), ta); }
        if (rc != 0) { return 0 - 1; }
        if (durable == 0 && n_arr > 0) {
          pipeline_asm_bump_next_offset_for_array_lit(arena, expr_ref, ctx);
        }
        glue_slice_dual_gp_bump_past_home_c(ctx, home, ta);
        { rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta); }
        if (rc != 0) { return 0 - 1; }
        return 0;
      }
      /*
       * ARRAY_LIT as SIMD/VECTOR formal (i32x4 / f32x4 / NAMED spelling).
       * G.7 complete of this function's ARRAY_LIT family: slice route is
       * above; rec would lea a stack array (pointer in rax) while the
       * callee expects 9–16B INTEGER dual-GP (same as VAR i32x4).
       * Reuse glue_emit_vector_type_let_init (let `a: i32x4 = [lit]`).
       * METHOD receiver also enters here with pty often unset — also
       * accept resolved SIMD stamp. >16B (i32x8) stays rec / MEMORY.
       * PLATFORM: SHARED freestanding · LINUX+MACOS x86 high-end ·
       * MACOS|ARM64 AAPCS64 low-end (same polarity as vector let-init).
       */
      simd_ty = 0;
      if (pty > 0) {
        { rc = asm_type_is_simd_vector_spelling(arena, pty); }
        if (rc != 0) { simd_ty = pty; }
      }
      { rty = pipeline_expr_resolved_type_ref(arena, expr_ref); }
      if (simd_ty == 0 && rty > 0) {
        { rc = asm_type_is_simd_vector_spelling(arena, rty); }
        if (rc != 0) { simd_ty = rty; }
      }
      if (simd_ty > 0) {
        lanes = 0;
        esz = 0;
        if (glue_vector_type_lanes_esz_c(arena, simd_ty, &lanes, &esz) != 0) {
          return 0 - 1;
        }
        if (lanes <= 0 || esz <= 0) { return 0 - 1; }
        vec_nbytes = lanes * esz;
        if (vec_nbytes > 0 && vec_nbytes <= 16) {
          vec_reserve = (vec_nbytes + 7) & (0 - 8);
          if (vec_reserve < 8) { vec_reserve = 8; }
          base_off = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
          if ((base_off % 8) != 0) { base_off = (base_off + 7) / 8 * 8; }
          if (ta == 1) {
            home = base_off;
            pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), base_off + vec_reserve);
          } else {
            home = base_off + vec_reserve;
            pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), home);
          }
          glue_align_next_offset(ctx);
          if (glue_emit_vector_type_let_init_elf_c(arena, elf_ctx, expr_ref, ctx, ta, home, simd_ty) != 0) {
            return 0 - 1;
          }
          if (vec_nbytes > 8) {
            if (ta == 1) {
              { rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, home + 8, ta); }
              if (rc != 0) { return 0 - 1; }
              { rc = backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 1, ta); }
              if (rc != 0) { return 0 - 1; }
              { rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, home, ta); }
              if (rc != 0) { return 0 - 1; }
            } else {
              { rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, home, ta); }
              if (rc != 0) { return 0 - 1; }
              { rc = backend_enc_load_rbp_to_rdx_arch(elf_ctx, home - 8, ta); }
              if (rc != 0) { return 0 - 1; }
            }
          } else {
            { rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, home, ta); }
            if (rc != 0) { return 0 - 1; }
          }
          return 0;
        }
      }
    }
  }

  // --- CALL/METHOD returning slice or fixed array as slice* formal ---
  if (arena != ((uint8_t *)0) && ctx != ((uint8_t *)0) && elf_ctx != ((uint8_t *)0)) {
    { ko = pipeline_expr_kind_ord_at(arena, expr_ref); }
    if (ko == kind_call || ko == kind_method) {
      slice_ty = 0;
      if (pty > 0) {
        { rc = pipeline_type_kind_ord_at(arena, pty); }
        if (rc == type_slice) { slice_ty = pty; }
      }
      { rty = pipeline_expr_resolved_type_ref(arena, expr_ref); }
      if (slice_ty == 0 && rty > 0) {
        { rc = pipeline_type_kind_ord_at(arena, rty); }
        if (rc == type_slice) { slice_ty = rty; }
      }
      arr_sz = 0;
      ret_kind = 0 - 1;
      if (rty > 0 && glue_type_is_fixed_array(arena, rty) != 0) {
        { arr_sz = pipeline_type_array_size_at(arena, rty); }
        ret_kind = type_array;
      }
      if (arr_sz <= 0 && slice_ty > 0) {
        // Resolve callee return type (may be TYPE_ARRAY while resolved is PTR).
        fi_slot[0] = 0 - 1;
        dep_slot[0] = 0 - 1;
        pipe_store_ptr_slot(&mod_slot[0], 0, ((uint8_t *)0));
        if (glue_asm_resolve_call_target_module_c(arena, expr_ref, &mod_slot[0], &fi_slot[0], &dep_slot[0]) == 0) {
          rmod = pipe_load_ptr_slot(&mod_slot[0], 0);
          rfi = fi_slot[0];
          rdep = dep_slot[0];
          if (rmod != ((uint8_t *)0) && rfi >= 0) {
            { rrty = pipeline_module_func_return_type_at(rmod, rfi); }
            if (rrty > 0 && rdep >= 0) {
              dep_pipe = pipeline_asm_emit_dep_pipe_c();
              if (dep_pipe != ((uint8_t *)0)) {
                { mapped = pipeline_typeck_get_dep_return_type_in_caller_arena_c(rdep, rrty, arena, dep_pipe); }
                if (mapped > 0) { rrty = mapped; }
              }
            }
            if (rrty > 0) {
              {
                int32_t tk_rr = 0;
                { tk_rr = pipeline_type_kind_ord_at(arena, rrty); }
                if (glue_type_is_fixed_array(arena, rrty) != 0 || tk_rr == type_array) {
                { arr_sz = pipeline_type_array_size_at(arena, rrty); }
                ret_kind = type_array;
                if (rty <= 0 || glue_type_is_fixed_array(arena, rty) == 0) { rty = rrty; }
                } else {
                { ret_kind = pipeline_type_kind_ord_at(arena, rrty); }
                }
              }
            }
          }
        }
      }
      if (ret_kind < 0 && rty > 0) {
        { ret_kind = pipeline_type_kind_ord_at(arena, rty); }
      }
      if (ret_kind < 0) {
        ret_kind = pipeline_asm_call_return_type_kind_ord_c(arena, expr_ref);
      }
      // wave404: TYPE_ARRAY return → slice* formal with caller-frame payload copy.
      if (slice_ty > 0 && arr_sz > 0) {
        esz = 4;
        if (rty > 0) {
          { elem_tr = pipeline_type_elem_ref_at(arena, rty); }
          if (elem_tr > 0) {
            esz = glue_index_elem_byte_sz_from_type_ref_c(arena, elem_tr);
            if (esz <= 0) { esz = 4; }
          }
        }
        base_off = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
        if ((base_off % 8) != 0) { base_off = (base_off + 7) / 8 * 8; }
        spill_off = base_off + 8;
        home = spill_off + 16;
        if (ta == 1) {
          payload_off = home + 16;
          past = payload_off + arr_sz * esz;
        } else {
          payload_off = home + arr_sz * esz;
          if (payload_off < home + 8) { payload_off = home + 8; }
          if ((payload_off % 8) != 0) { payload_off = (payload_off + 7) / 8 * 8; }
          past = payload_off;
          if (past < home + 8) { past = home + 8; }
        }
        if (past < payload_off || past < home) { return 0 - 1; }
        pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), past);
        glue_align_next_offset(ctx);
        if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, expr_ref, ctx, ta) != 0) { return 0 - 1; }
        { rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, spill_off, ta); }
        if (rc != 0) { return 0 - 1; }
        ai = 0;
        while (ai < arr_sz) {
          { rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, spill_off, ta); }
          if (rc != 0) { return 0 - 1; }
          if (ai * esz != 0) {
            { rc = backend_enc_add_imm_to_rax_arch(elf_ctx, ai * esz, ta); }
            if (rc != 0) { return 0 - 1; }
          }
          if (esz == 1) {
            { rc = backend_enc_load_zext8_from_rax_arch(elf_ctx, ta); }
          } else {
            if (esz == 8) {
              { rc = backend_enc_load_64_from_rax_arch(elf_ctx, ta); }
            } else {
              { rc = backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta); }
            }
          }
          if (rc != 0) { return 0 - 1; }
          { rc = backend_enc_push_rax_arch(elf_ctx, ta); }
          if (rc != 0) { return 0 - 1; }
          { rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, payload_off, ta); }
          if (rc != 0) { return 0 - 1; }
          { rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta); }
          if (rc != 0) { return 0 - 1; }
          { rc = backend_enc_pop_rax_arch(elf_ctx, ta); }
          if (rc != 0) { return 0 - 1; }
          { rc = backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, ai * esz, esz, ta); }
          if (rc != 0) { return 0 - 1; }
          ai = ai + 1;
        }
        { rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, payload_off, ta); }
        if (rc != 0) { return 0 - 1; }
        { rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta); }
        if (rc != 0) { return 0 - 1; }
        { rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, arr_sz, 0, ta); }
        if (rc != 0) { return 0 - 1; }
        { rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(home, ta), ta); }
        if (rc != 0) { return 0 - 1; }
        { rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta); }
        if (rc != 0) { return 0 - 1; }
        return 0;
      }
      // True TYPE_SLICE return → dual-GP fat + reent deep-copy (use_frame=0 COMMON).
      if (slice_ty > 0) {
        base_off = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
        if ((base_off % 8) != 0) { base_off = (base_off + 7) / 8 * 8; }
        home = base_off + 16;
        if (ta == 1) { pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), home + 16); }
        else { pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), home + 8); }
        glue_align_next_offset(ctx);
        if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, expr_ref, ctx, ta) != 0) { return 0 - 1; }
        { rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta); }
        if (rc != 0) { return 0 - 1; }
        { rc = backend_enc_store_rdx_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(home, ta), ta); }
        if (rc != 0) { return 0 - 1; }
        if (glue_slice_let_reent_deep_copy_after_dual_gp_elf_c(arena, elf_ctx, ctx, ta, home, slice_ty, 0) != 0) {
          return 0 - 1;
        }
        { rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta); }
        if (rc != 0) { return 0 - 1; }
        return 0;
      }
      /* CALL/METHOD result is a fixed array wider than 16 bytes, and
       * the formal is that array. emit leaves a pointer into the
       * callee frame. sum2(from_param(w)) then calls sum2, whose
       * prologue reuses that stack. Copy into a caller slot first
       * and pass that address. 16 bytes or less stays on rec. A
       * slice formal is the arm above. The byte count is the formal,
       * then the call's resolved array type. PLATFORM: MACOS|ARM64. */
      if (ta == 1 && slice_ty == 0 && pty > 0) {
        want_arr = 0;
        { rc = pipeline_type_kind_ord_at(arena, pty); }
        if (rc == type_array || glue_type_is_fixed_array(arena, pty) != 0) { want_arr = 1; }
        if (want_arr != 0) {
          payload_bytes = glue_fixed_array_total_bytes_c(arena, pty, 0);
          if (payload_bytes <= 0 && rty > 0) {
            payload_bytes = glue_fixed_array_total_bytes_c(arena, rty, 0);
          }
          if (payload_bytes > 16 && payload_bytes <= 4096 && (payload_bytes % 8) == 0) {
            base_off = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
            if ((base_off % 8) != 0) { base_off = (base_off + 7) / 8 * 8; }
            spill_off = base_off;
            home = base_off + 16;
            past = home + payload_bytes;
            if (past < home) { return 0 - 1; }
            pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), past);
            glue_align_next_offset(ctx);
            if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, expr_ref, ctx, ta) != 0) { return 0 - 1; }
            { rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, spill_off, ta); }
            if (rc != 0) { return 0 - 1; }
            { rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta); }
            if (rc != 0) { return 0 - 1; }
            { rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, spill_off + 8, ta); }
            if (rc != 0) { return 0 - 1; }
            if (glue_emit_bulk_mem_copy_spills_elf_c(elf_ctx, spill_off, spill_off + 8, payload_bytes, ta) != 0) {
              return 0 - 1;
            }
            { rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta); }
            if (rc != 0) { return 0 - 1; }
            return 0;
          }
        }
      }
    }
  }

  // SIMD wider than 16 bytes is a memory argument: the callee
  // receives the address, the same lea a VAR already returns.
  // A binop, a block, or an array literal has no address. rec
  // left lane 0 of `id(a + a)` unset. The formal type ref and the
  // binop's resolved type are not a spelling-ok SIMD ref, so the
  // fill never ran. One walk, budget 128, peels BLOCK to its final
  // expr, descends lane binops (kinds 4..13) and unary NEG/BITNOT,
  // and keeps the first VAR whose resolved or declared type spells
  // as SIMD. Kind 51 is an address and is not descended. The fill
  // still receives the original expr_ref, so vector let-init emits
  // the lets once. -3 means that function stored nothing, so rec
  // still runs. Any other decline already wrote or refused, and
  // must not be emitted again. Kind 52 stays on that decline.
  // An array literal has no VAR operand; it still needs the formal.
  // PLATFORM: SHARED freestanding. Slot polarity matches the <=16
  // SIMD arm (MACOS|ARM64 low-end, x86 high-end).
  simd_ty = 0;
  if (arena != ((uint8_t *)0)) {
    if (ctx != ((uint8_t *)0)) {
      if (elf_ctx != ((uint8_t *)0)) {
        if (pty > 0) {
          { rc = asm_type_is_simd_vector_spelling(arena, pty); }
          if (rc != 0) { simd_ty = pty; }
        }
        if (simd_ty == 0) {
          { rty = pipeline_expr_resolved_type_ref(arena, expr_ref); }
          if (rty > 0) {
            { rc = asm_type_is_simd_vector_spelling(arena, rty); }
            if (rc != 0) { simd_ty = rty; }
          }
        }
        // Type lives on a VAR operand. Queries only: do not emit here.
        // PLATFORM: SHARED freestanding.
        if (simd_ty == 0) {
          walk_sp = 0;
          walk_steps = 0;
          walk_br = 0;
          walk_stk[0] = expr_ref;
          walk_sp = 1;
          while (walk_sp > 0) {
            if (walk_steps >= 128) {
              walk_sp = 0;
            } else {
              walk_steps = walk_steps + 1;
              walk_sp = walk_sp - 1;
              walk_cur = walk_stk[walk_sp];
              if (walk_cur > 0) {
                { walk_ko = pipeline_expr_kind_ord_at(arena, walk_cur); }
                if (walk_ko == 26) {
                  { walk_child = pipeline_expr_block_ref_at(arena, walk_cur); }
                  if (walk_child > 0) {
                    walk_br = walk_child;
                    { walk_fin = ast_ast_block_final_expr_ref(arena, walk_child); }
                    if (walk_fin > 0) {
                      if (walk_fin != walk_cur) {
                        if (walk_sp < 128) {
                          walk_stk[walk_sp] = walk_fin;
                          walk_sp = walk_sp + 1;
                        }
                      }
                    }
                  }
                } else {
                  if (walk_ko == 3) {
                    walk_cand = 0;
                    { walk_cand = pipeline_expr_resolved_type_ref(arena, walk_cur); }
                    if (walk_cand > 0) {
                      { rc = asm_type_is_simd_vector_spelling(arena, walk_cand); }
                      if (rc == 0) { walk_cand = 0; }
                    }
                    if (walk_cand == 0) {
                      { vlen = pipeline_expr_var_name_len(arena, walk_cur); }
                      if (vlen > 0) {
                        if (vlen <= 255) {
                          { pipeline_expr_var_name_into(arena, walk_cur, &vname[0]); }
                          scope_br = walk_br;
                          if (scope_br <= 0) {
                            { scope_br = asm_ctx_scope_block_ref_at(ctx); }
                          }
                          if (scope_br > 0) {
                            {
                              walk_cand = pipeline_block_resolve_var_type_ref(
                                arena, scope_br, &vname[0], vlen);
                            }
                          }
                          if (walk_cand > 0) {
                            { rc = asm_type_is_simd_vector_spelling(arena, walk_cand); }
                            if (rc == 0) { walk_cand = 0; }
                          }
                          if (walk_cand == 0) {
                            { scope_br = asm_ctx_scope_block_ref_at(ctx); }
                            if (scope_br > 0) {
                              if (scope_br != walk_br) {
                                {
                                  walk_cand = pipeline_block_resolve_var_type_ref(
                                    arena, scope_br, &vname[0], vlen);
                                }
                              }
                            }
                            if (walk_cand > 0) {
                              { rc = asm_type_is_simd_vector_spelling(arena, walk_cand); }
                              if (rc == 0) { walk_cand = 0; }
                            }
                          }
                        }
                      }
                    }
                    if (walk_cand > 0) {
                      simd_ty = walk_cand;
                      walk_sp = 0;
                    }
                  } else {
                    walk_push = 0;
                    if (walk_ko == 22) { walk_push = 1; }
                    if (walk_ko == 23) { walk_push = 1; }
                    if (walk_push != 0) {
                      { walk_fin = pipeline_expr_unary_operand_ref_at(arena, walk_cur); }
                      if (walk_fin > 0) {
                        if (walk_sp < 128) {
                          walk_stk[walk_sp] = walk_fin;
                          walk_sp = walk_sp + 1;
                        }
                      }
                    } else {
                      { rc = glue_is_vector_lane_scalar_binop_ko(walk_ko); }
                      if (rc != 0) {
                        if (walk_ko != 51) {
                          { walk_fin = pipeline_expr_binop_right_ref_at(arena, walk_cur); }
                          { walk_child = pipeline_expr_binop_left_ref_at(arena, walk_cur); }
                          if (walk_fin > 0) {
                            if (walk_sp < 128) {
                              walk_stk[walk_sp] = walk_fin;
                              walk_sp = walk_sp + 1;
                            }
                          }
                          if (walk_child > 0) {
                            if (walk_sp < 128) {
                              walk_stk[walk_sp] = walk_child;
                              walk_sp = walk_sp + 1;
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
        if (simd_ty > 0) {
          lanes = 0;
          esz = 0;
          { rc = glue_vector_type_lanes_esz_c(arena, simd_ty, &lanes, &esz); }
          if (rc == 0) {
            if (lanes > 0) {
              if (esz > 0) {
                vec_nbytes = lanes * esz;
                if (vec_nbytes > 16) {
                  vec_reserve = (vec_nbytes + 15) & (0 - 16);
                  base_off = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
                  if ((base_off % 16) != 0) {
                    base_off = (base_off + 15) / 16 * 16;
                  }
                  if (ta == 1) {
                    home = base_off;
                    pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), base_off + vec_reserve);
                  } else {
                    home = base_off + vec_reserve;
                    pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), home);
                  }
                  glue_align_next_offset(ctx);
                  {
                    rc = glue_emit_vector_type_let_init_elf_c(
                      arena, elf_ctx, expr_ref, ctx, ta, home, simd_ty);
                  }
                  if (rc == 0) {
                    { rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta); }
                    if (rc != 0) { return 0 - 1; }
                    return 0;
                  }
                  if (rc != (0 - 3)) {
                    return 0 - 1;
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  return pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, expr_ref, ctx, ta);
  }
}
