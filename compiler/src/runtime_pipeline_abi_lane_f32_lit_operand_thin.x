// Live body of glue_emit_vector_operand_lane_elf_c.
// The copy in runtime_pipeline_abi.x is an extern. pabi_weak still has
// the old strong definition and is weakened at link. That copy emits a
// FLOAT_LIT through pipeline_asm_emit_expr, which moves the f64 bits
// into x0. The low half of f64 4.0 and f64 2.0 is 0, so an f32 lane
// div of those literals stored 0. When the f32-literal gate is set,
// a FLOAT_LIT, or a chain of EXPR_NEG over one, at lane size 4 is
// narrowed with the existing glue_ieee_f64_bits_to_f32_bits and moved
// as imm32. The same peel covers a VAR, a FIELD, and add/sub/mul/div.
// An odd count xors the f32 sign. One peel handles every depth. The
// 128 stop is only for a chain that does not end. When the gate stays
// 0, one recursion walks a chain of negation and bitwise not from the
// inside out. The core may be a VAR, a FIELD, or a lane scalar binop
// of kinds 4..13 (mod, shifts, and, or, xor). Kind 23 uses the
// existing not encoder. A signed i32 lane is then sign-extended,
// because lane div is a 64-bit sdiv and a 32-bit not zeros the high
// half. A u32 lane stays zero-extended. Kind 22 uses neg w0 and then
// the same sign-extend as before. Kind 24, kind 51, and an i32 INT_LIT
// stay on emit_expr. A transparent block, a nested block, and
// unsafe { e } are one recursion over the existing
// glue_expr_block_transparent_value_ref_at. The lane op then sees the
// inner value. A block that still has lets is one recursion:
// lane_emit_block_lets_value_ref emits those lets, and this function
// continues on the value expr. The helper does not emit the value.
// An INDEX with an
// integer-literal index loads one lane from the base frame. Nested
// indexes are that same recursion. The stride is the existing index
// element size. A non-literal index loads one lane from the address
// the existing scaled index emitter leaves in rax. Nested indexes are
// that emitter. A call base and a block base stay on emit_expr. A FIELD whose
// root is a STRUCT_LIT has no VAR frame. The existing field
// materializer already fills a temp and leaves that field's address
// in rax. One recursion finds that root. A transparent block under a
// field is peeled by one recursion before that materializer. Nested
// fields are the same recursion. A block with lets is not peeled
// away. That recursion calls lane_emit_block_lets_value_ref, then
// retargets the field at the value expr so the existing materializer
// emits the value once.
// The lane is then the existing indirect i32 load at lane * esz. A
// call or method root stays on emit_expr. The 128 stop is only for a
// chain that does not end. This
// file then matches the old body. Do not add a second divss.
// PLATFORM: SHARED.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_float_bits_lo_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_float_bits_hi_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_array_lit_elem_ref(arena: *u8, expr_ref: i32, lane: i32): i32;
export extern function pipeline_expr_binop_left_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_binop_right_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_ieee_f64_bits_to_f32_bits(lo: i32, hi: i32): i32;
export extern function glue_lane_f32_lit_dest_get(): i32;
export extern function glue_asm_local_var_stack_off_scoped(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function glue_vector_var_lane_stack_off_elf_c(
  arena: *u8, ctx: *u8, var_expr_ref: i32, lane: i32, esz: i32, ta: i32
): i32;
export extern function glue_is_vector_lane_scalar_binop_ko(ko: i32): i32;
export extern function glue_emit_vector_lane_scalar_binop_elf_c(
  arena: *u8, elf_ctx: *u8, binop_ko: i32, left_ref: i32, right_ref: i32,
  lane: i32, esz: i32, ctx: *u8, ta: i32
): i32;
export extern function pipeline_asm_emit_expr_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32
): i32;
export extern function backend_enc_load_rbp_lane_to_rax_arch(
  elf_ctx: *u8, offset: i32, esz: i32, ta: i32
): i32;
export extern function backend_enc_mov_imm32_to_w0_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function backend_enc_mov_imm32_to_rbx_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function backend_enc_xor_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_neg_eax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_not_eax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function glue_enc_sxt_i32_result_to_rax_elf_c(elf_ctx: *u8, ta: i32): i32;
export extern function pipeline_lane_shr_is_arith(
  arena: *u8, ctx: *u8, left_ref: i32, right_ref: i32
): i32;
export extern function glue_expr_block_transparent_value_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_index_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_index_elem_byte_sz_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_int_val_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32; // Cap-fn-ptr (stage10 10.3.2 slice0): LEA of same-module #[no_mangle] fn into rax/x0. // G.7: reuse backend_enc_dispatch authority (vtable LEA co-path); no second encoder. export extern "C" function backend_enc_lea_sym_to_reg_arch(elf_ctx: *u8, reg: i32, name: *u8, name_len: i32, ta: i32): i32; export extern "C" function backend_enc_mov_rax_to_arg_reg_arch(elf_ctx: *u8, k: i32, ta: i32): i32; export extern "C" function backend_enc_call_arch(elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32; // wave123 Cap residual: lea_common pure leave callees (pipeline_elf_ctx still host-cc). // PLATFORM: SHARED freestanding emit · append_bytes / code_len / reloc (+typed PAGE21/12). // wave273 pure-owned: pipeline_elf_ctx_append_bytes live at EOF (#[no_mangle]). // G.7 dual-export ban — was Cap residual export extern. // wave273 pure-owned: pipeline_elf_ctx_emit_code_len live at EOF (#[no_mangle]). // G.7 dual-export ban — was Cap residual export extern. // wave273 pure-owned: pipeline_elf_ctx_append_reloc live at EOF (#[no_mangle]). // G.7 dual-export ban — was Cap residual export extern. // wave273 pure-owned: pipeline_elf_ctx_append_reloc_typed live at EOF (#[no_mangle]). // G.7 dual-export ban — was Cap residual export extern. // wave124 Cap residual: var_decl pure leave callees (still host-cc residual / context). // PLATFORM: SHARED — pure owns VAR type-ref + lazy block-let append faces only. export extern "C" function asm_ctx_scope_block_ref_at(ctx: *u8): i32; export extern "C" function pipeline_block_resolve_var_type_ref(arena: *u8, block_ref: i32, vname: *u8, vlen: i32): i32; export extern "C" function pipeline_block_parent_block_ref_at(arena: *u8, block_ref: i32): i32; export extern "C" function pipeline_module_func_param_type_ref_for_name(module: *u8, func_index: i32, var_name: *u8, name_len: i32): i32; export extern "C" function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32; // wave141: module_ref_c / func_index_c pure export below (emit-context leave). // wave267: asm_ctx_local_find_offset pure (asm_locals leave; dual-export ban). // wave267: asm_ctx_block_slot_get pure (asm_locals leave; dual-export ban). export extern "C" function pipeline_block_let_type_ref(arena: *u8, block_ref: i32, let_idx: i32): i32; export extern "C" function asm_local_slot_reg_offset(arena: *u8, type_ref: i32, off: i32, inout_off: *i32): i32; // wave267: asm_ctx_local_append pure (asm_locals leave; dual-export ban). // wave267: asm_ctx_local_count pure (asm_locals leave; dual-export ban). // wave126 Cap residual: next_offset pure leave callees. // wave143: glue_array_temp_bytes_for_let_init pure-owned (array_lit leave) — no Cap residual. // wave127 Cap residual: panic pure leave callees (encoder + expr emit still host-cc / asm). // PLATFORM: SHARED freestanding emit — pure owns PANIC / div-zero ELF face only. // Use public pipeline_asm_emit_expr_elf_c (not static _rec) for msg operand emit. export extern "C" function backend_enc_mov_imm32_to_w0_arch(elf_ctx: *u8, imm: i32, ta: i32): i32; export extern "C" function backend_enc_test_rbx_rbx_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_jne_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32; export extern "C" function backend_enc_label_arch(elf_ctx: *u8, name: *u8, name_len: i32, is_global: i32, ta: i32): i32; // wave288: body live in seed ALWAYS (WAVE288_ASM_LABEL_FORMAT_ALWAYS); dual-export ban. // PLATFORM: SHARED freestanding Cap leave — pure does not re-define. export extern "C" function pipeline_asm_emit_next_label_c(ctx: *u8, buf: *u8, buf_size: i32): i32; export extern "C" function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32; // wave128 Cap residual: logand/logor pure leave callees (binop faces + short-circuit encoders). // PLATFORM: SHARED freestanding emit — pure owns LOGAND/LOGOR ELF face only. // Operand emit uses public pipeline_asm_emit_expr_elf_c (→ host-cc _rec); do not Cap residual // the static _rec symbol (G.7 public face only). export extern "C" function pipeline_expr_binop_left_ref_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_binop_right_ref_at(arena: *u8, expr_ref: i32): i32; // wave136 Cap residual: fold_primitives pure leave (AST pattern detectors). // Pool faces + residual static→extern helpers (vector_simd / as). // PLATFORM: SHARED — pure owns 13 fold detection faces; residual owns pool + as/param helpers. export extern "C" function pipeline_block_let_name_len(arena: *u8, block_ref: i32, let_idx: i32): i32; export extern "C" function pipeline_block_let_name_copy64(arena: *u8, block_ref: i32, let_idx: i32, dst: *u8): void; export extern "C" function pipeline_block_let_init_ref(arena: *u8, block_ref: i32, let_idx: i32): i32; export extern "C" function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_field_access_name_len(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_field_access_name_into(arena: *u8, expr_ref: i32, out: *u8): void; export extern "C" function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_index_index_ref(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_as_operand_ref_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_call_num_args_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_call_arg_ref(arena: *u8, expr_ref: i32, idx: i32): i32; // wave148 pure leave: glue_expr_is_func_param_at_c + glue_fold_func_return_operand_ref_c live in this file. // wave138: glue_expr_is_x_as_cast_at_c is pure export (#[no_mangle]) — was Cap residual for // fold_primitives leave when as.c still host-cc; do not re-declare export extern "C" or // pure call sites mangle to _glue_expr_is_x_as_cast_at_c_u8_ptr_i32_reti32 (G.7 single face). // wave137 Cap residual: cmp pure leave callees (operand placement + encoders + CTFE accessors). // PLATFORM: SHARED freestanding emit — pure owns CMP ELF + typekind tag + cc maps. export extern "C" function pipeline_expr_const_folded_valid_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_const_folded_val_at(arena: *u8, expr_ref: i32): i32; // wave151 pure-owned leave: pipeline_expr_enum_namespace_field_tag lives in EOF wave151 section. // wave196 pure-owned: pipeline_asm_call_return_type_kind_ord_c body at EOF (#[no_mangle]). // G.7 ban dual export extern + pure export for the same symbol. // wave149 pure-owned faces: bodies in EOF section (#[no_mangle] export; no dual export extern). // wave188 pure-owned leave: glue_var_expr_stack_off_elf_c lives in EOF wave188 section // (#[no_mangle] export; dual-export ban — do not re-declare export extern "C"). /* wave210 pure-owned: glue_binop_var_slot_cache_invalidate_rbx at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ export extern "C" function backend_enc_ucomisd_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_ucomiss_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_fp_cmp_setcc_movzbl_arch(elf_ctx: *u8, cc: i32, ta: i32): i32; // wave138 Cap residual: as pure leave callees (pool float bits + IEEE pack + // cast encoders + try cleanup + as target type + array lit elem type). // PLATFORM: SHARED freestanding emit — pure owns as/await/try/float-lit faces. export extern "C" function pipeline_expr_float_bits_lo_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_float_bits_hi_at(arena: *u8, expr_ref: i32): i32; export extern "C" function glue_ieee_f64_bits_to_f32_bits(lo: i32, hi: i32): i32; export extern "C" function glue_ieee_f32_bits_to_f64_lo(fb: i32): i32; export extern "C" function glue_ieee_f32_bits_to_f64_hi(fb: i32): i32; // wave152 Cap residual: int→IEEE pack for pure expr_elf_fast CTFE / EXPR_LIT float stamp (G.7 next to ieee_*). export extern "C" function glue_i32_to_f32_bits(v: i32): i32; export extern "C" function glue_i64_to_f32_bits(v: i64): i32; export extern "C" function glue_i64_to_f64_bits(v: i64, lo: *i32, hi: *i32): void; export extern "C" function pipeline_expr_as_target_type_ref_at(arena: *u8, expr_ref: i32): i32; // wave143 pure leave: pipeline_asm_array_lit_elem_type_ref live in this file. /* wave169: pure owns glue_index_scratch_spills_cleanup_all_elf_c (#[no_mangle] below). */ /* wave207 pure-owned: glue_index_scratch_stack_depth_get/set at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave171: pure owns glue_enc_pop_index_scratch_stack_arm64_elf_c (#[no_mangle] below). */ /* wave209 pure-owned: glue_index_scratch_caches_hit_var at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave208 pure-owned: glue_binop_stack_spill_append_at_depth / cap_get at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave209 pure-owned: minus_pair/subadd3 CAP cache BSS thin faces at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave172: pure owns minus_pair/subadd3 cache spill helpers (#[no_mangle] below). */ export extern "C" function arch_x86_64_enc_enc_test_edx_edx(elf_ctx: *u8): i32; export extern "C" function backend_enc_cvttss2si_eax_from_f32_bits_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cvttsd2si_eax_from_f64_bits_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cvttss2si_rax_from_f32_bits_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cvttsd2si_rax_from_f64_bits_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cvtsi2ss_eax_from_i32_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cvtsi2ss_eax_from_i64_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cvtsi2ss_eax_from_u64_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cvtsd2ss_eax_from_f64_bits_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cvtsi2sd_rax_from_u64_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cvtsi2sd_rax_from_i64_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cvtsi2sd_rax_from_i32_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cvtss2sd_rax_from_f32_bits_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cmp_setcc_movzbl_arch(elf_ctx: *u8, cc: i32, ta: i32): i32; export extern "C" function backend_enc_load_rbp_to_rbx_arch(elf_ctx: *u8, offset: i32, ta: i32): i32; export extern "C" function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32; export extern "C" function backend_enc_mov_imm32_to_rbx_arch(elf_ctx: *u8, imm: i32, ta: i32): i32; export extern "C" function backend_enc_pop_rbx_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_test_eax_eax_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_jz_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32; export extern "C" function backend_enc_jnz_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32; export extern "C" function backend_enc_jmp_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32; // wave153 Cap residual: block_body pure leave callees (host-cc residual live/spill/CAP). // PLATFORM: SHARED freestanding emit — pure owns body_sync + defer + final_expr + if_arm. // wave212 pure owns color/pin BSS; wave213 pure owns live control scalars + // interf graph BSS + linear_ctx bind + pressure thresh (#[no_mangle] EOF). // wave214 pure owns live set arrays + opaque u8 overlay thins (#[no_mangle] EOF). /* wave212 pure-owned: glue_asm73_cfg_coloring_active_get/set at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave213 pure-owned: glue_block_live_cfg_parent_* / active_* / emit_stmt_i_* * at EOF (#[no_mangle]). G.7 ban dual export. */ /* wave214 pure-owned: glue_block_live_fwd_as_u8 + live set BSS thins at EOF. * G.7 ban dual export extern + pure export for the same symbol. */ /* wave212 pure-owned: glue_asm73_pin_spill_off_clear_all at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave214 pure-owned: glue_asm73_cfg_peak_live_n_get / peak_* / live_fwd_* at EOF. */ // wave176 pure-owned: glue_block_compute_live_end_linear_to_sub_exit_snap (#[no_mangle] below). /* wave214 pure-owned: glue_live_fwd_n_get/off_at/clear_u8/add_u8 at EOF. */ // wave154 pure-owned: pipeline_expr_struct_lit_num_fields body in EOF section. export extern "C" function pipeline_expr_struct_lit_init_ref(arena: *u8, expr_ref: i32, j: i32): i32; /* wave167: pure owns glue_block_compute_cfg_peak_live_and_color + note_cfg_live_peak (#[no_mangle] below). */ // wave176 pure-owned: glue_block_compute_linear_live_in (#[no_mangle] below). /* wave213 pure-owned: glue_asm73_cfg_interf_prepare at EOF (#[no_mangle]). * wave214 pure-owned: glue_asm73_cfg_peak_clear (peak_live BSS pure). */ /* wave168: pure owns glue_block_simulate_cfg_live + from_empty (#[no_mangle] below). */ /* wave213 pure-owned: glue_asm73_linear_ctx_bind + linear_* getters at EOF. */ /* wave214 pure-owned: glue_asm73_cfg_peak_stmt_i_get / peak_live_as_u8 / * peak_snapshot_from_u8 / glue_live_fwd_copy_u8 at EOF. */ /* wave213 pure-owned: glue_asm73_interf_add_live_set_u8 / linear_max_* at EOF. */ // wave176 pure-owned: glue_block_stmt_gen_kill_u8 + glue_live_fwd_apply_stmt_gen_kill_u8 (#[no_mangle] below). /* wave213 pure-owned: glue_asm73_interf_push / pop_merge at EOF (#[no_mangle]). */ /* wave212 pure-owned: glue_asm73_cfg_final_expr_use_n_set at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave165: pure owns glue_asm73_compute_spill_color_pins (#[no_mangle] below). */ /* wave212 pure-owned: glue_asm73_clear_spill_color_map at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave173: pure owns glue_block_live_fwd_before_stmt + apply_top_stmt (#[no_mangle] below). */ // wave176 pure-owned: glue_live_fwd_forward_after_def (#[no_mangle] below). /* wave163: pure owns glue_binop_cache_intersect_live_fwd (#[no_mangle] below). */ /* wave214 pure-owned: glue_block_live_fwd_contains_off at EOF. */ /* wave213 pure-owned: interf_n_get / off_at / has_edge / clear / add_live_at_stmt * + linear_nso_get at EOF (#[no_mangle]). G.7 ban dual export. */ // wave176 pure-owned: glue_asm73_linear_next_use_dist (#[no_mangle] below). /* wave212 pure-owned: glue_asm73_set_spill_color / off_spill_color_which / * pin_spill_off_set at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave164: pure owns glue_asm73_compute_spill_color_chaitin (#[no_mangle] below). */ /* wave214 pure-owned: live_at_stmt[] BSS + n_get / as_u8 at EOF. */ /* wave213 pure-owned: glue_asm73_pressure_live_thresh_get at EOF (#[no_mangle]). */ /* wave208 pure-owned: glue_binop_stack_spill_find_depth at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave174: pure owns glue_asm73_evict_rax|rbx_cache_entry (#[no_mangle] below). */ /* wave166: pure owns pressure eviction faces (#[no_mangle] below). */ /* wave175: pure owns mov_reg_to_spill / try_colored / farthest / pick_evict (#[no_mangle] below). */ /* wave212 pure-owned: glue_asm73_stack_spill_enabled / off_is_spill_pin at EOF * (#[no_mangle]). wave213: stack_spill_enabled reads pure cfg_parent + max_live. */ /* wave210 pure-owned: glue_binop_var_slot_cache_set_spill_slot at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave214 pure-owned: remove/contains_u8 / live_at_stmt_copy / sub_exit / * fwd remove/add_off at EOF. */ /* wave213 pure-owned: linear_arena/ctx/block_ref/slot_base/nconst/nlet getters * + linear_max_live_n_set at EOF (#[no_mangle]). G.7 ban dual export. */ /* wave210 pure-owned: glue_binop_var_slot_cache x10–x15 valid/off getters + * set_valid_x* at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave208 pure-owned: glue_binop_stack_spill_n_get / off_at / drop_off / clear at EOF * (#[no_mangle]). G.7 ban dual export extern + pure export for the same symbol. */ // wave159 pure-owned: glue_block_stmt_order_has_cfg body in EOF section (was Cap residual spill). // wave156 pure-owned: glue_expr_kind_is_assign_like_ord + try_block_let_index_init + kill_assign_lhs in EOF. /* wave209 pure-owned: glue_index_subadd3_sum_cache_clear / minus_pair_cache_clear at EOF. * G.7 ban dual export extern + pure export for the same symbol. */ // wave207 pure-owned: glue_binop_rax_frame_spill_n_set + glue_index_scratch_stack_depth_set at EOF. // G.7 ban dual export extern + pure export for the same symbol. // wave208 pure-owned: glue_binop_stack_spill_clear at EOF (#[no_mangle]). // wave220 pure-owned: glue_if_expr_arm_emit_depth_get/set + pure BSS at EOF // (#[no_mangle]). G.7 ban dual export extern + pure export for the same symbol. /* wave261 pure-owned: glue_block_body_bind_module_dep_from_ctx body at EOF * (#[no_mangle]). G.7 ban dual export extern + pure export for the same symbol. */ export extern "C" function backend_block_slot_base_for(ctx: *u8, arena: *u8, block_ref: i32): i32; // wave155 pure-owned leave: backend_emit_while_loop_elf_sync(arena: *u8, elf_ctx: *u8, block_ref: i32, loop_idx: i32, ctx: *u8, ta: i32): i32; body in EOF section. // wave155 pure-owned leave: backend_emit_for_loop_elf_sync body in EOF section. export extern "C" function pipeline_block_region_with_arena_cap_ref(arena: *u8, block_ref: i32, ri: i32): i32; export extern "C" function pipeline_block_labeled_is_goto(arena: *u8, block_ref: i32, li: i32): i32; export extern "C" function pipeline_block_labeled_label_len(arena: *u8, block_ref: i32, li: i32): i32; export extern "C" function pipeline_block_labeled_label_copy32(arena: *u8, block_ref: i32, li: i32, dst: *u8): void; export extern "C" function pipeline_block_labeled_goto_target_len(arena: *u8, block_ref: i32, li: i32): i32; export extern "C" function pipeline_block_labeled_goto_target_copy32(arena: *u8, block_ref: i32, li: i32, dst: *u8): void; // wave129 Cap residual: block_if pure leave callees (host-cc residual live/scope/body faces). // PLATFORM: SHARED freestanding emit — pure owns block-level if ELF + if_then_block_body face. // Cond operand uses public pipeline_asm_emit_expr_elf_c (→ host-cc _rec). Live buffers are // opaque u8[136] overlays of GlueBlockLiveFwd (offs[32]+n; Cap residual casts). export extern "C" function ast_pipeline_block_if_cond_ref(arena: *u8, block_ref: i32, if_idx: i32): i32; export extern "C" function ast_pipeline_block_if_then_body_ref(arena: *u8, block_ref: i32, if_idx: i32): i32; export extern "C" function ast_pipeline_block_if_else_body_ref(arena: *u8, block_ref: i32, if_idx: i32): i32; /* wave261 pure-owned: glue_asm_ctx_set_scope_block body at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave282: per-ctx scope_block_ref seed ALWAYS (bootstrap leave). */ export extern "C" function asm_ctx_set_scope_block(ctx: *u8, block_ref: i32): void; // wave133: glue_enc_jz_after_bool_in_eax is pure export below (unary leave). // Was Cap residual when host leaf owned the face; block_if / async_cps call pure. export extern "C" function backend_ensure_block_local_slots(ctx: *u8, arena: *u8, block_ref: i32): void; // wave145 pure leave: pipeline_asm_fill_block_locals_tree live in this file. // wave153 pure-owned: pipeline_asm_emit_block_body_sync_elf body in EOF section. /* wave214 pure-owned: glue_block_fill_live_end_for_merge at EOF. */ // wave153 pure-owned: glue_block_stmt_order_has_return body in EOF section. /* wave214 pure-owned: glue_live_fwd_copy_from_snap_before_if at EOF. */ // wave158 pure-owned: glue_asm_cache_invalidate_at_cfg_merge_selective + // glue_asm_if_phi_invalidate_both_branch_defs + glue_cfg_collect/add/contains // live in EOF section (was Cap residual spill). // wave159 pure-owned: glue_asm_loop_phi_invalidate_carried_defs body in EOF. // wave160 pure-owned: glue_asm_if_merge_live_union_from_ends + // glue_asm_loop_merge_live_union body in EOF (was Cap residual spill). // wave161 pure-owned: glue_live_fwd_apply_expr_effect body in EOF (was Cap residual). // wave162 pure-owned: pipeline_asm_emit_break_elf_c / continue_elf_c body in EOF. // wave155 Cap residual (spill un-static): break push/pop (step effect → pure wave161). /* wave214 pure-owned: glue_loop_break_exit_push/pop at EOF. */ // wave176 pure-owned: glue_live_fwd_collect_expr_uses (#[no_mangle] below). // wave160 Cap residual thin accessors for pure live-merge leave (BSS still spill). /* wave214 pure-owned: glue_block_live_fwd_copy_from_u8 at EOF. */ // wave161 Cap residual: union opaque gen into global block_live_fwd. /* wave214 pure-owned: glue_block_live_fwd_union_from_u8 at EOF. */ /* wave214 pure-owned: loop break/continue depth + union_into_u8 at EOF. */ // wave162 Cap residual thin: note live at break/continue into stack BSS. /* wave214 pure-owned: loop break/continue note_current at EOF. */ // wave141: pipeline_asm_fill_local_slots pure export below (emit-context leave). // wave153 pure-owned: backend_emit_block_body_sync_elf body in EOF section. // wave131 Cap residual: async_cps pure leave callees (encoders + async_asm_pool + local offset). // PLATFORM: SHARED freestanding emit — pure owns CPS bag + entry/end/await/phase_reset faces. // async_asm_pool_build_layout already pure (async_asm_pool.x); Cap as link face. // push/pop/load32/mov_rbx/cmp/jeq are backend_enc_dispatch pure; Cap residual for this TU. export extern "C" function async_asm_pool_build_layout(arena: *u8, mod: *u8, func_index: i32, out: *u8): i32; export extern "C" function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32; // wave202 Cap residual: arm64 MEMORY-by-value SP store (backend_enc_dispatch pure). export extern "C" function backend_enc_store_x0_sp_offset_arch(elf_ctx: *u8, off_bytes: i32, ta: i32): i32; export extern "C" function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_load_32_from_rax_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cmp_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_jeq_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32; // wave132 Cap residual: struct_let pure leave callees (struct lit fields + CALL sizing/store + // try_inline + expected-ret + module_from_ctx). lea/mov_arg already Cap residual above; // glue_arm64_mov_x0_to_x8_elf_c is pure export (lea_common leave); emit_expr uses public // pipeline_asm_emit_expr_elf_c (not static _rec). PLATFORM: SHARED freestanding emit. // wave154 pure-owned: pipeline_asm_emit_struct_lit_fields_elf_c body in EOF section. export extern "C" function try_inline_struct_lit_return_call_to_slot_elf(arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32): i32; export extern "C" function try_inline_const_struct_lit_return_call_to_slot_elf(arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32): i32; // wave206 pure-owned: pipeline_asm_set/call_expected_ret_ty_c + pure BSS at EOF. // G.7 ban dual export extern + pure export for the same symbol. // wave194 pure-owned: glue_call_return_byte_size_c body at EOF (#[no_mangle]). // wave195 pure-owned: pipeline_asm_call_arg_value_byte_size_c body at EOF (#[no_mangle]). // wave196 pure-owned: pipeline_asm_call_return_type_kind_ord_c body at EOF (#[no_mangle]). // wave197 pure-owned: pipeline_asm_call_struct16_ret_needs_rax_deref_c + // pipeline_asm_deref_struct16_rax_ptr_elf_c bodies at EOF (#[no_mangle]). // wave198 pure-owned: pipeline_asm_call_param_type_ref_at_c body at EOF (#[no_mangle]). // wave199 pure-owned: glue_asm_resolve_call_target_module_c body at EOF (#[no_mangle]). // G.7 ban dual export extern + pure export for the same symbol. // Resolve callees (Cap residual / pool): typeck resolve + find_func + call resolved_* . export extern "C" function pipeline_expr_call_resolved_func_index_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_call_resolved_dep_index_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_typeck_resolve_call_func_index_for_emit_c(m: *u8, a: *u8, call_expr_ref: i32): i32; export extern "C" function pipeline_typeck_find_func_return_type_in_module_by_name_c( mod: *u8, caller_arena: *u8, name: *u8, name_len: i32, from_dep_index: i32, ctx: *u8, func_index_out: *i32): i32; export extern "C" function pipeline_typeck_find_func_return_type_in_module_c( mod: *u8, mod_arena: *u8, caller_arena: *u8, callee_arena: *u8, callee_expr_ref: i32, from_dep_index: i32, ctx: *u8, func_index_out: *i32): i32; export extern "C" function pipeline_typeck_get_dep_return_type_in_caller_arena_c(from_dep_index: i32, dep_return_type_ref: i32, caller_arena: *u8, ctx: *u8): i32; // wave198: slow-path dep type_ref → caller-arena map (Cap residual method_call). // PLATFORM: SHARED — param formal type_ref must never cross arenas raw. export extern "C" function pipeline_typeck_dep_return_type_to_caller_arena_c(dep_arena: *u8, dep_return_type_ref: i32, caller_arena: *u8): i32; // wave154 pure-owned: glue_type_size_simple body in EOF section. // wave191 pure-owned: glue_type_named_layout_size_any_module_elf_c lives at EOF (#[no_mangle]). // G.7 ban dual export extern + pure export for the same symbol. // wave204 pure-owned: glue_store_retval_pair_to_rbp_elf_c + private // glue_copy_large_struct_from_rax_ptr_elf_c bodies at EOF (#[no_mangle] public). // wave205 pure-owned: glue_slice_let_reent_deep_copy_after_dual_gp_elf_c at EOF // (#[no_mangle] public). G.7 ban dual export extern + pure export. // wave189 pure-owned: glue_emit_module_from_ctx live at EOF (#[no_mangle]). // G.7 ban dual export extern + pure export for the same symbol. // wave133 Cap residual: unary pure leave callees (operand emit + float classifiers + // int64 lit + arch encoders). glue_var_decl_type_ref_elf_c is pure (var_decl leave). // PLATFORM: SHARED freestanding emit — pure owns NEG/LOGNOT/BITNOT + sxt + jz faces. // wave149 pure-owned faces: bodies in EOF section (#[no_mangle] export; no dual export extern). export extern "C" function pipeline_expr_int64_val_at(arena: *u8, expr_ref: i32): i64; export extern "C" function backend_enc_neg_eax_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_not_eax_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_setz_movzbl_eax_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function arch_arm64_enc_enc_u32_le(elf_ctx: *u8, val: i32): i32; // wave134 Cap residual: match pure leave callees (MATCH/EXPR_IF arm faces + if_arm + // struct layout for subject field-bind). Enc jmp/jne/label/mov/cmp + next_label + // emit_expr_elf_c + module/func_index getters already Cap residual above. // PLATFORM: SHARED freestanding emit — pure owns match_elf + expr_if_elf + subject BSS. export extern "C" function pipeline_expr_match_matched_ref_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_match_num_arms_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_match_arm_is_wildcard(arena: *u8, expr_ref: i32, i: i32): i32; export extern "C" function pipeline_expr_match_arm_guard_ref(arena: *u8, expr_ref: i32, i: i32): i32; export extern "C" function pipeline_expr_match_arm_result_ref(arena: *u8, expr_ref: i32, i: i32): i32; export extern "C" function pipeline_expr_match_arm_is_enum_variant(arena: *u8, expr_ref: i32, i: i32): i32; export extern "C" function pipeline_expr_match_arm_variant_index(arena: *u8, expr_ref: i32, i: i32): i32; export extern "C" function pipeline_expr_match_arm_lit_val(arena: *u8, expr_ref: i32, i: i32): i32; export extern "C" function pipeline_expr_if_cond_ref_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_if_then_ref_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_if_else_ref_at(arena: *u8, expr_ref: i32): i32; // wave153 pure-owned: pipeline_asm_emit_expr_if_arm_elf_c body in EOF section. // wave154 Cap residual: struct_lit pure leave callees (size glue + diagnostics + dual-GP). // wave266: pipeline_module_struct_layout_* / num_struct_layouts_at pure (struct_layout leave; dual-export ban). export extern "C" function typeck_x_type_size_from_layout_glue(module: *u8, arena: *u8, li: i32, depth: i32): i32; export extern "C" function typeck_soa_array_storage_size_glue(module: *u8, arena: *u8, elem_type_ref: i32, array_len: i32, depth: i32): i32; export extern "C" function pipeline_typeck_type_refs_equal_c(arena: *u8, a: i32, b: i32): i32; export extern "C" function backend_enc_load_qword_rbx8_to_rdx_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function driver_diagnostic_typeck_struct_padding_before(sname: *u8, sname_len: i32, gap: i32, fname: *u8, fname_len: i32): void; export extern "C" function driver_diagnostic_typeck_struct_padding_trailing(sname: *u8, sname_len: i32, gap: i32): void; export extern "C" function driver_diagnostic_typeck_struct_field_bad_size(sname: *u8, sname_len: i32, fname: *u8, fname_len: i32): void; export extern "C" function driver_diagnostic_warn_pad_fields_same_cache_line(sname: *u8, sname_len: i32, f0: *u8, f0_len: i32, f1: *u8, f1_len: i32): void; export extern "C" function driver_diagnostic_hint_unused_binding(line: i32, col: i32, name: *u8, name_len: i32): void; export extern "C" function driver_diagnostic_warn_hot_reorder_field(sname: *u8, sname_len: i32, hot: *u8, hot_len: i32, cold: *u8, cold_len: i32): void; /* wave235 G.7: env via public pure thin link_abi_getenv (wave222 -> _impl host getenv); * not raw libc getenv. Cap residual host getenv stays only link_abi_getenv_impl. * Used by pipeline_asm_debug_enabled + pipeline_debug_trace_named_func_bodies_impl. * PLATFORM: SHARED - product hybrid pipeline_abi pure uses same face as cold seed. */ export extern "C" function link_abi_getenv(name: *u8): *u8; export extern function link_abi_host_is_windows(): i32; /* wave1222: extern declarations for parser_parse_into_init body. * These mirror the C authority in parser_gen.c L6318-6331 to ensure the * .x strong symbol performs identical AST arena/module state reset. * Without this, the empty .x body overrode the C init, causing AST arena * state leakage between file checks in directory mode (T001 cascades). * PLATFORM: SHARED - all externs are platform-agnostic arena/module reset. */ // wave276: ast_ast_arena_init pure-owned at EOF (dual-export ban; no Cap residual) export extern "C" function ast_pool_module_reset(module: *u8): void; export extern "C" function ast_pool_arena_reset(arena: *u8): void; export extern "C" function parser_onefunc_result_layout_prime(): void; export extern "C" function parser_onefunc_result_layout_prime_b(): void; export extern "C" function parser_onefunc_result_layout_prime_c(): void; export extern "C" function parser_onefunc_result_layout_prime_d(): void; export extern "C" function parser_onefunc_result_layout_prime_d_b(): void; export extern "C" function parser_onefunc_result_layout_prime_e(): void; export extern "C" function parser_onefunc_result_layout_prime_f(): void; export extern "C" function parser_pipeline_module_reset_parse_counters(module: *u8): void; export extern "C" function pipeline_parser_set_match_module(module: *u8): void; /* wave1222: trait registry + generic bound source stash (mirrors C impl_c). * Without these, directory-mode check leaks trait/generic state across files, * causing the parser to misbehave (e.g. num_funcs drops from 356 to 104 for * runtime_pipeline_abi.x when checked after other files). * PLATFORM: SHARED - pure delegation to platform-agnostic externs. */ export extern "C" function xlang_trait_reg_reset_c(arena: *u8): void; export extern "C" function xlang_generic_bound_stash_source_buf_c(data: *u8, len: i32): void; /* wave1223: extern declarations for pipeline_parse_set_main_from_buf_c body. * Live G.7 authority is this .x / runtime_pipeline_abi seed (historical C twin * in deleted ast_pool.c left wave309). Keep parse + main_idx set identical to * the pre-leave contract so directory mode does not skip files. * Without this, an empty .x body (return 0) overrode the prior C impl, causing * pipeline_run_x_pipeline to skip parsing entirely in directory mode * (num_funcs=190 instead of 377 for runtime_driver_abi_thin.x). * PLATFORM: SHARED - all externs are platform-agnostic parse/diag helpers. */ // wave121: pipeline_lint_set_source_buf + pipeline_module_set_main_func_index pure below. // (lint_meta pure-owned leave) export extern "C" function driver_diagnostic_parse_fail(main_idx: i32, num_funcs: i32, arena_num_types: i32): void; // wave276: pipeline_arena_num_types pure-owned at EOF (dual-export ban) /* wave112: pipeline_parse_into_with_init_buf_scalars is pure export below * (parse_typeck_dispatch leave). Cap residual unpack is * pipeline_parse_into_with_init_buf_impl_rc (pipeline_parse_orch.c) over * Cap-struct-return impl_c / strict_parse_into_init. */ /** * G.7: parser_x owns parser_parse_into_init. This TU must not emit a * competing T — FORCE mega previously first-won (g05 pabi is #8, * parser_x.o is #20) with hoist-target modlet seed dumped into the * wrapper (1744B lea COMMON inits, then the 13 calls). Product Ubuntu * already used parser_x (pabi W); Darwin pabi T was the duplicate. * PLATFORM: SHARED — link-name contract; parser_x.o provides the body. */ export extern function parser_parse_into_init(module: *u8, arena: *u8): void; /** * G.7: parser_x owns parser_get_module_num_imports. Mega's `return 0` * stub first-wins under FORCE and reports zero imports. * PLATFORM: SHARED — parser_x.o provides the body. */ export extern function parser_get_module_num_imports(module: *u8): i32; /** * G.7: leftover WAVE274 / asm_wpo_thin owns PGO emit-order prepare. * FORCE mega T first-won a smashed body (call-next-insn / emit_n imm 0); * mega_body then called emit_order_at which returned -1 for every slot * so w393_mega_emit_one hit `if (i < 0) return 0` and wrote no text * (CG002 code_len=0). This TU must not emit a competing T. * PLATFORM: SHARED — leftover from_x WAVE274 provides the body. */ export extern function pipeline_asm_wpo_pgo_emit_order_prepare(m: *u8): void; /** * G.7: leftover WAVE274 owns emit-order count (pairs with prepare/at). * FORCE mega T of count happened to load emit_n=2 while at() used imm 0. * PLATFORM: SHARED — leftover from_x WAVE274 provides the body. */ export extern function pipeline_asm_wpo_pgo_emit_order_count(m: *u8): i32; /** * G.7: leftover WAVE274 owns emit-order at (func index or -1). * FORCE mega/thin asm lowered `order_index >= g_aw_pgo_emit_n` to * `mov $0, %eax` (no reloc); leftover gcc keeps RIP load of emit_n. * PLATFORM: SHARED — leftover from_x WAVE274 provides the body. */ export extern function pipeline_asm_wpo_pgo_emit_order_at(m: *u8, order_index: i32): i32; /** * G.7: leftover WAVE153 gcc owns two-pass stmt_order block-body ELF emit. * FORCE mega T first-won a smash (`sub $0x5228`, cltq on i32 block_ref) * over leftover W 0x22c6. parse_orch emit_one#2 then failed in * w499_mega_emit_body_sync (backend_emit_block_body_sync_elf mega T * `sub $0x8a8` / call-next-insn). Mega must not emit a competing T. * PLATFORM: SHARED — leftover from_x WAVE153 provides the body. */ export extern function pipeline_asm_emit_block_body_sync_elf(arena: *u8, elf_ctx: *u8, block_ref: i32, ctx: *u8, ta: i32): i32; /** * G.7: leftover WAVE153 gcc owns backend.x body_sync entry (84B wrapper: * diverged_set + bind_module_dep + inner emit). FORCE mega T smash * (`sub $0x8a8`) first-won leftover W 0x54. * PLATFORM: SHARED — leftover from_x WAVE153 provides the body. */ export extern function backend_emit_block_body_sync_elf(arena: *u8, elf_ctx: *u8, block_ref: i32, ctx: *u8, ta: i32): i32; /** * G.7: leftover WAVE152 gcc owns emit_expr_elf fast path (LIT / const_fold / * VAR / binop). FORCE mega T first-won smash (`sub $0x2e98` / cltq) over * leftover W 0x1200. parse_orch emit_one#2 then failed innermost at * pipeline_asm_emit_expr_elf_fast#63 eax=-1 after leftover body_sync W * was already live. Mega must not emit a competing T. * Same-TU callers (binop load_operand / emit_expr_elf_rec) stay in unsafe. * PLATFORM: SHARED — leftover from_x WAVE152 provides the body. */ export extern function pipeline_asm_emit_expr_elf_fast(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32; /** * G.7: leftover WAVE273 gcc overlay owns F7 data-section length. * FORCE mega T smash (`sub $0x888`) first-won leftover W 0x22 and RIP-loads * mega `g_pipe_elf_data_len`, not leftover `g_pipeline_elf_data_len`. * Same-TU localize of mega T still binds prepare's CALL to mega local t. * Mega must emit U so leftover gcc W is the sole global. * wave744: leftover-gcc sidecar first-wins this weak T and writes both BSS * homes so compact macho_write (inlines leftover C) emits __DATA. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_emit_data_len(ctx_bytes: *u8): i32; /** * G.7: leftover WAVE273 gcc overlay owns F7 append-zeros (grows data_len). * FORCE mega T smash (`sub $0x898` / cltq) first-won leftover W 0xa2. * gdb asm_wpo: mega smash append $rip, leftover gcc poke then sees data_len=0. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_append_data_zeros(ctx_bytes: *u8, n: i32): i32; /** * G.7: leftover WAVE273 gcc overlay owns F7 data poke (0x4c, RIP data_len). * FORCE mega T first-won smash poke; leftover gcc poke requires leftover * gcc append to have grown the same BSS. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_data_poke_u8(ctx_bytes: *u8, off: i32, b: i32): i32; /** * G.7: leftover smash T of bake_scalar_imm_to_data is the working body * (product gdb eax=0; mega smash `sub $0x8c8` eax=-1). No leftover gcc W * of this face. Same-TU localize still binds mega prepare to mega local t. * Mega must emit U so leftover T (weaken→W) is the sole global. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover pabi T provides the body. */ export extern function pipe_modlet_bake_scalar_imm_to_data( elf_ctx: *u8, data_off: i32, imm: i32, csz: i32 ): i32; /** * G.7: leftover WAVE273 gcc overlay owns add_sym (W 0x22d, endbr64). * FORCE mega T smash first-won leftover W. leftover gcc add_common_sym * CALLs this face; mega smash add_sym RIP-loads `g_pipe_elf_*` sidecar * while leftover gcc uses `g_pipeline_elf_*` + leftover ctx layout. * Same-TU localize of mega T still binds mega prepare's CALL to local t. * Mega must emit U so leftover gcc W is the sole global. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_add_sym( ctx_bytes: *u8, name: *u8, name_len: i32, offset: i32 ): i32; /** * G.7: leftover WAVE273 gcc overlay owns add_common_sym (W 0x138, endbr64). * FORCE mega T smash first-won leftover W. Dual BSS: mega * `g_pipe_elf_sym_is_common` ≠ leftover `g_pipeline_elf_sym_is_common`. * leftover gcc add_common_sym calls leftover gcc add_sym (same family). * Do not leftover-first smash-only `modlet_prepare` (layout mismatch). * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_add_common_sym( ctx_bytes: *u8, name: *u8, name_len: i32, sym_size: i32, sym_align: i32 ): i32; /** * G.7: leftover WAVE273 gcc overlay owns add_label (W 0x1f0, endbr64). * FORCE mega T smash first-won leftover W. Dual BSS: mega * `g_pipe_elf_label_shndx` ≠ leftover `g_pipeline_elf_label_shndx`. * leftover gcc add_label uses leftover STATIC current_shndx / * label_shndx_set (not first-win-able). leftover gcc ensure_label * CALLs leftover gcc add_label (same family). Same-TU localize of * mega T still binds mega prepare's CALL to local t. Mega must emit * U so leftover gcc W is the sole global. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_add_label( ctx_bytes: *u8, name: *u8, name_len: i32, offset: i32 ): i32; /** * G.7: leftover WAVE273 gcc overlay owns ensure_label (W 0xd5, endbr64). * FORCE mega T smash first-won leftover W. leftover gcc ensure_label * CALLs leftover gcc add_label; leftover-first both faces together. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_ensure_label( ctx_bytes: *u8, name: *u8, name_len: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_assign_elf_c (W 0x4b79, endbr64). * FORCE mega T smash first-won leftover W. leftover gcc VAR assign CALLs leftover * gcc glue_emit_assign_rhs_to_rax_elf_c (W 0x59b); leftover gcc rhs_to_rax * plain (ako==28) CALLs leftover gcc glue_emit_assign_rhs_elf_c (W 0xd6). * Same-TU localize of mega T still binds mega CALL to local t. Mega must emit * U so leftover gcc W is the sole global. Family leftover-first all three. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_assign_elf_c( arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_emit_assign_rhs_to_rax_elf_c (W 0x59b, endbr64). * leftover gcc emit_assign VAR/fallback CALLs this. Family with emit_assign. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_emit_assign_rhs_to_rax_elf_c( arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_emit_assign_rhs_elf_c (W 0xd6, endbr64). * leftover gcc rhs_to_rax plain (ako==28) CALLs this; leftover gcc then * pipeline_asm_emit_expr_elf_c (already leftover-first emit_fast/rec). * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_emit_assign_rhs_elf_c( arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_expr_elf_for_call_args * (W 0x2c4f, endbr64 sub $0x248). FORCE mega T smash (sub $0x5c38 / cltq) * first-won leftover W. Same-TU localize of mega T still binds mega CALL * to local t. Mega must emit U so leftover gcc W is the sole global. * backend_call_dispatch already export-externs this face; localize * for_call_args_thin so thin W cannot first-win leftover gcc W. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_expr_elf_for_call_args( arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns asm_parser_emit_heavy_safe_helper * (W 0x22d7, endbr64 sub $0x10). FORCE mega T smash (sub $0x87c8) * first-won leftover W. Same-TU caller asm_skip_heavy_module_func_body * is already in unsafe. Do not leftover-first skip_heavy itself * (wave650 FORCE_FULL_BODIES escape). Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_parser_emit_heavy_safe_helper( m: *u8, func_index: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_emit_struct_type_let_init_elf_c * (W 0x20c9, endbr64 sub $0x3b8). FORCE mega T smash first-won leftover W. * leftover gcc STRUCT_LIT path CALLs leftover gcc * pipeline_asm_emit_struct_let_init_elf_c (W 0xa0) which CALLs leftover gcc * pipeline_asm_emit_struct_lit_fields_elf_c (W 0x169e). leftover gcc * emit_expr STRUCT_LIT CALLs leftover gcc pipeline_asm_emit_struct_lit_elf_c * (W 0x44). Family leftover-first all four so leftover gcc parent CALLs * leftover gcc children. Same-TU callers already in unsafe. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_emit_struct_type_let_init_elf_c( arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, let_ty_ref: i32, stack_slot_off: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_struct_let_init_elf_c * (W 0xa0, endbr64 sub $0x40). leftover gcc glue_emit_struct_type_let_init * CALLs this for STRUCT_LIT. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_struct_let_init_elf_c( arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_struct_lit_fields_elf_c * (W 0x169e, endbr64 sub $0xb8). leftover gcc struct_let_init / emit_struct_lit * CALL this. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_struct_lit_fields_elf_c( arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_struct_lit_elf_c * (W 0x44, endbr64 sub $0x20). leftover gcc emit_expr STRUCT_LIT CALLs this * wrapper, which CALLs leftover gcc struct_lit_fields. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_struct_lit_elf_c( arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns asm_parser_m8_tail_thin_delegate_c_name * (W 0x1f1a, endbr64 sub $0x20). FORCE mega T smash first-won leftover W. * leftover gcc skip_heavy_or_thin_stub / resolve_call_to_glue CALL this. * Do not leftover-first asm_skip_heavy_module_func_body (FORCE_FULL_BODIES * dual env). Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_parser_m8_tail_thin_delegate_c_name( m: *u8, func_index: i32, out: *u8, out_cap: i32, out_len: *i32 ): i32; /** * G.7: leftover gcc overlay owns asm_wpo_collect_walk * (W 0x1e56, endbr64 sub $0x210). FORCE mega T smash first-won leftover W. * Mega wrappers collect_edges_from_expr / collect_from_block CALL this. * asm_wpo_thin also has a body — localize so thin W cannot first-win. * Do not leftover-first asm_skip_heavy_module_func_body (FORCE_FULL_BODIES * dual env). Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_wpo_collect_walk( is_block: i32, a: *u8, ref: i32, caller_id: i32, caller_mod: *u8, ctx: *u8, depth: i32 ): void; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_return_elf_impl * (W 0x1a7e, endbr64 sub $0x1e8). FORCE mega T smash first-won leftover W. * Mega wrapper pipeline_asm_emit_return_elf_c and expr_rec CALL this. * arr_return_thin / fixed_array_copy_thin also have a body — localize so * thin W cannot first-win. HARD BAN product PREFER of return_elf_impl_thin * (FORCE user -c of that thin is T001). Do not leftover-first * asm_skip_heavy_module_func_body (FORCE_FULL_BODIES dual env). Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_return_elf_impl( arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: runtime_pipeline_abi_parser_thin_delegate_thin.x owns * asm_parser_func_is_thin_delegate. The egg copy stays weak behind that * overlay (was W 0x12d3). Mega skip_heavy CALLs this (already unsafe). * Do not add a second body here. Mega must emit U. * PLATFORM: SHARED — overlay first-wins; egg table is not the linked body. */ export extern function asm_parser_func_is_thin_delegate(m: *u8, func_index: i32): i32; /** * G.7: leftover gcc overlay owns asm_backend_m8_tail_thin_delegate_c_name * (W 0xa62, endbr64 sub $0x20). FORCE mega T smash first-won leftover W. * Mega skip_heavy_or_thin_stub CALLs this (already unsafe). No thin copy. * Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_backend_m8_tail_thin_delegate_c_name( m: *u8, func_index: i32, out: *u8, out_cap: i32, out_len: *i32 ): i32; /** * G.7: leftover gcc overlay owns asm_pipeline_m8_tail_thin_delegate_c_name * (W 0x130, endbr64 sub $0x20). FORCE mega T smash first-won leftover W. * Mega skip_heavy_or_thin_stub CALLs this (already unsafe). No thin copy. * Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_pipeline_m8_tail_thin_delegate_c_name( m: *u8, func_index: i32, out: *u8, out_cap: i32, out_len: *i32 ): i32; /** * G.7: leftover gcc overlay owns asm_typeck_m8_tail_thin_delegate_c_name * (W 0xed, endbr64 sub $0x30). FORCE mega T smash first-won leftover W. * Mega skip_heavy_or_thin_stub CALLs this (already unsafe). No thin copy. * Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_typeck_m8_tail_thin_delegate_c_name( m: *u8, func_index: i32, out: *u8, out_cap: i32, out_len: *i32 ): i32; /** * G.7: leftover gcc overlay owns asm_driver_m8_tail_thin_delegate_c_name * (W 0x64, endbr64 sub $0x20). FORCE mega T smash first-won leftover W. * Mega skip_heavy_or_thin_stub CALLs this (already unsafe). No thin copy. * Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_driver_m8_tail_thin_delegate_c_name( m: *u8, func_index: i32, out: *u8, out_cap: i32, out_len: *i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_lvalue_eff_addr_elf_c * (W 0x890, endbr64 sub $0x170). FORCE mega T smash first-won leftover W. * leftover gcc emit_assign (w710) CALLs leftover gcc this face for FIELD/INDEX * /DEREF lvalues. Thins export-extern (no body). Mega same-TU callers already * unsafe. Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_lvalue_eff_addr_elf_c( arena: *u8, elf_ctx: *u8, lval_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_enc_local_slot_ptr_or_addr_elf_c * (W 0x82, endbr64 sub $0x40). FORCE mega T smash sub $0x8b8 first-won leftover W. * leftover gcc emit_assign CALLs leftover gcc this face (field_assign HIT smash). * Thins export-extern (no body). Mega same-TU callers already unsafe. * Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_enc_local_slot_ptr_or_addr_elf_c( arena: *u8, elf_ctx: *u8, var_ref: i32, var_off: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_index_elem_byte_sz_c * (W 0x1103). FORCE mega T smash first-won leftover W. leftover gcc INDEX * / lvalue_eff_addr CALLs leftover gcc this face. Thins export-extern * (no body). Mega same-TU callers wrapped unsafe. Do not leftover-first * skip_heavy or skip_heavy_or_thin_stub parent. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_index_elem_byte_sz_c( arena: *u8, expr_ref: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_emit_index_eff_addr_scaled_elf_c * (W 0x73e). FORCE mega T smash first-won leftover W. leftover gcc INDEX * / lvalue_eff_addr / assign CALLs leftover gcc this face (index_i32 gdb * HIT). Thins export-extern (no body). Mega same-TU callers already unsafe. * Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_emit_index_eff_addr_scaled_elf_c( arena: *u8, elf_ctx: *u8, ix_ref: i32, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_try_index_var_or_field_base_to_rax_elf_c * (W 0xe0c). FORCE mega T smash first-won leftover W. leftover gcc INDEX * scaled (w725) CALLs leftover gcc this face (INDEX lit path). Thins * export-extern (no body). Mega same-TU callers wrapped unsafe. Do not * leftover-first skip_heavy, skip_heavy_or_thin_stub parent, rbx twin, * or wrapper pipeline_asm_index_elem_byte_sz. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_try_index_var_or_field_base_to_rax_elf_c( arena: *u8, elf_ctx: *u8, base_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_try_index_rvalue_slice_once_elf_c * (W 0xd2e). FORCE mega T smash first-won leftover W. leftover gcc INDEX * scaled (w725) CALLs leftover gcc this face (CALL/METHOD/INDEX/DEREF * TYPE_SLICE rvalue-once). No thin defines this symbol. Mega same-TU * remaining callers after scaled leftover-first: 0. Do not leftover-first * skip_heavy, skip_heavy_or_thin_stub parent, rbx twin, bounds_guard, * or wrapper pipeline_asm_index_elem_byte_sz. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_try_index_rvalue_slice_once_elf_c( arena: *u8, elf_ctx: *u8, ix_ref: i32, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_emit_index_bounds_guard_elf_c * (W 0x90f). FORCE mega T smash first-won leftover W. leftover gcc INDEX * scaled (w725) CALLs leftover gcc this face (INDEX bounds). No thin * defines this symbol. Mega same-TU remaining callers after scaled * leftover-first: 0. Do not leftover-first skip_heavy, skip_heavy_or_thin_stub * parent, rbx twin, rax_plus_rbx_scaled, or wrapper * pipeline_asm_index_elem_byte_sz. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_emit_index_bounds_guard_elf_c( arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32, ix_ref: i32, base_ref: i32, idx_ref: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_try_index_var_or_field_base_to_rbx_elf_c * (W 0x7dc). FORCE mega T smash first-won leftover W. leftover gcc INDEX * assign-addr→rbx forest CALLs leftover gcc this face (INDEX assign base). * No thin defines this symbol. Mega same-TU remaining callers: 18 (already * unsafe). Do not leftover-first skip_heavy, skip_heavy_or_thin_stub * parent, rax_plus_rbx_scaled, local_slot rbx twin, or wrapper * pipeline_asm_index_elem_byte_sz. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_try_index_var_or_field_base_to_rbx_elf_c( arena: *u8, elf_ctx: *u8, base_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_local_var_slot_needs_ptr_load_elf_c * (W 0x542). FORCE mega T smash first-won leftover W. leftover gcc local_slot * (w723 W 0x82) CALLs leftover gcc this face. Thin param_ptr_slot_thin HAS a * body (W 0x8dc) — must localize or thin W first-wins leftover gcc. Mega * same-TU remaining callers: 4. Do not leftover-first skip_heavy, * skip_heavy_or_thin_stub parent, rax_plus_rbx_scaled, local_slot rbx twin, * or wrapper pipeline_asm_index_elem_byte_sz. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_local_var_slot_needs_ptr_load_elf_c( arena: *u8, var_expr_ref: i32, stack_off: i32, ctx: *u8 ): i32; /** * G.7: leftover gcc overlay owns glue_copy_large_struct_from_rax_ptr_elf_c * (W 0x482). FORCE mega T smash first-won leftover W. leftover gcc * store_retval_pair (W 0x2bb) CALLs leftover gcc this face (>16B CALL * memcpy). Thins assign_thin / assign_deref_* export-extern (no body) * — still localize. Mega same-TU remaining callers: 5. Do not leftover-first * skip_heavy, skip_heavy_or_thin_stub parent, rax_plus_rbx_scaled, * local_slot rbx twin, wrapper pipeline_asm_index_elem_byte_sz, or * store_retval_pair itself. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_copy_large_struct_from_rax_ptr_elf_c( elf_ctx: *u8, slot_off: i32, sz: i32, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_emit_vector_type_let_init_elf_c * (W 0x2c5). FORCE mega T smash first-won leftover W. leftover gcc * let-init / assign SIMD paths CALL leftover gcc this face (non-vector * returns -2). Thins assign_thin / assign_var_try_let / * assign_index_simd_body / assign_field_var_simd / * assign_deref_vec_call / for_call_args export-extern (no body) * — still localize. Mega same-TU remaining callers: 5. Do not leftover-first * skip_heavy, skip_heavy_or_thin_stub parent, rax_plus_rbx_scaled, * local_slot rbx twin, wrapper pipeline_asm_index_elem_byte_sz, * store_retval_pair, or vector children (vector_let_init / var_copy / * binop / simd_try_inline_*). Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_emit_vector_type_let_init_elf_c( arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, type_ref: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_vector_let_init_elf_c * (W 0x73f). FORCE mega T smash first-won leftover W (`sub $0x13a8`). * leftover gcc vector_type_let_init (w732 W 0x2c5) CALLs leftover gcc this * face for ARRAY_LIT. Thin fixed_array_copy / arr_struct_lit_arrlit * export-extern (no body) — still localize. Mega same-TU remaining callers: 1. * Do not leftover-first skip_heavy, skip_heavy_or_thin_stub parent, * rax_plus_rbx_scaled, local_slot rbx twin, wrapper, store_retval_pair, * or other vector children (var_copy / binop / simd_try_inline_*). * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_vector_let_init_elf_c( arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_simd_try_inline_select_call_elf_c * (W 0x691). FORCE mega T smash first-won leftover W (`sub $0x13f8`). * leftover gcc vector_type_let_init (w732 W 0x2c5) CALLs leftover gcc this * face for CALL/METHOD simd.select. Mega same-TU remaining callers: 0 * (parent leftover-first). No thin defines this symbol — still localize. * Do not leftover-first skip_heavy, skip_heavy_or_thin_stub parent, * rax_plus_rbx_scaled, local_slot rbx twin, wrapper, store_retval_pair, * or other vector children (var_copy / binop / splat / shuffle / fma / * identity / binop2). Mega may not emit U (unused export-extern). * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_simd_try_inline_select_call_elf_c( arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, type_ref: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_simd_try_inline_shuffle_call_elf_c * (W 0x4ca). FORCE mega T smash first-won leftover W (`sub $0xd78`). * leftover gcc vector_type_let_init (w732 W 0x2c5) CALLs leftover gcc this * face for CALL/METHOD simd.shuffle. Mega same-TU remaining callers: 0 * (parent leftover-first). No thin defines this symbol — still localize. * Do not leftover-first skip_heavy, skip_heavy_or_thin_stub parent, * rax_plus_rbx_scaled, local_slot rbx twin, wrapper, store_retval_pair, * or other vector children (var_copy / binop / splat / fma / * identity / binop2). Mega may not emit U (unused export-extern). * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_simd_try_inline_shuffle_call_elf_c( arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, type_ref: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_simd_try_inline_fma3_call_elf_c * (W 0x47e). FORCE mega T smash first-won leftover W (`sub $0xcf8`). * leftover gcc vector_type_let_init (w732 W 0x2c5) CALLs leftover gcc this * face for CALL/METHOD simd.fma. Mega same-TU remaining callers: 0 * (parent leftover-first). No thin defines this symbol — still localize. * Do not leftover-first skip_heavy, skip_heavy_or_thin_stub parent, * rax_plus_rbx_scaled, local_slot rbx twin, wrapper, store_retval_pair, * or other vector children (var_copy / binop / splat / identity / binop2). * Mega may not emit U (unused export-extern). * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_simd_try_inline_fma3_call_elf_c( arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, type_ref: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_simd_try_inline_splat_call_elf_c * (W 0x423). FORCE mega T smash first-won leftover W (`sub $0xbb8`). * leftover gcc vector_type_let_init (w732 W 0x2c5) CALLs leftover gcc this * face for CALL/METHOD simd.splat. Mega same-TU remaining callers: 1 * (glue_simd_select_arg_stack_off_c, wrapped unsafe). No thin defines this * symbol — still localize. * Do not leftover-first skip_heavy, skip_heavy_or_thin_stub parent, * rax_plus_rbx_scaled, local_slot rbx twin, wrapper, store_retval_pair, * or other vector children (var_copy / binop / identity / binop2). * Mega may emit U (remaining caller). * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_simd_try_inline_splat_call_elf_c( arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, type_ref: i32 ): i32; /** * G.7: parser_x owns parser_get_module_import_path. * PLATFORM: SHARED — parser_x.o provides the body. */ export extern function parser_get_module_import_path(module: *u8, idx: i32, path_buf: *u8): void; /** * Copy import path at index i into out[0..64) (NUL-terminated) and return path length. * @param module *u8 - opaque AST module; null -> out[0]=0 when out valid, return 0 * @param i i32 - import index (negative / OOB handled by G.7 path_copy / ImportEntry) * @param out *u8 - destination buffer; capacity 64 bytes including NUL; null -> 0 * @return i32 - byte length of path excluding NUL; 0 on null/missing path * wave99 pure Cap residual close: G.7 single product authority for path64 surface. * Body ≡ historical parser_gen: pipeline_module_import_path_copy(..., 64) + scan NUL. * wave110: path_copy storage is pure ImportEntry map (not Cap residual). * PLATFORM: SHARED - parser_gen path64 demoted weak cold twin; product pure hybrid owns. */ #[no_mangle] export function parser_copy_module_import_path64(module: *u8, i: i32, out: *u8): i32;
export extern function backend_enc_mov_rax_to_arg_reg_arch(elf_ctx: *u8, k: i32, ta: i32): i32; export extern "C" function backend_enc_call_arch(elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32; // wave123 Cap residual: lea_common pure leave callees (pipeline_elf_ctx still host-cc). // PLATFORM: SHARED freestanding emit · append_bytes / code_len / reloc (+typed PAGE21/12). // wave273 pure-owned: pipeline_elf_ctx_append_bytes live at EOF (#[no_mangle]). // G.7 dual-export ban — was Cap residual export extern. // wave273 pure-owned: pipeline_elf_ctx_emit_code_len live at EOF (#[no_mangle]). // G.7 dual-export ban — was Cap residual export extern. // wave273 pure-owned: pipeline_elf_ctx_append_reloc live at EOF (#[no_mangle]). // G.7 dual-export ban — was Cap residual export extern. // wave273 pure-owned: pipeline_elf_ctx_append_reloc_typed live at EOF (#[no_mangle]). // G.7 dual-export ban — was Cap residual export extern. // wave124 Cap residual: var_decl pure leave callees (still host-cc residual / context). // PLATFORM: SHARED — pure owns VAR type-ref + lazy block-let append faces only. export extern "C" function asm_ctx_scope_block_ref_at(ctx: *u8): i32; export extern "C" function pipeline_block_resolve_var_type_ref(arena: *u8, block_ref: i32, vname: *u8, vlen: i32): i32; export extern "C" function pipeline_block_parent_block_ref_at(arena: *u8, block_ref: i32): i32; export extern "C" function pipeline_module_func_param_type_ref_for_name(module: *u8, func_index: i32, var_name: *u8, name_len: i32): i32; export extern "C" function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32; // wave141: module_ref_c / func_index_c pure export below (emit-context leave). // wave267: asm_ctx_local_find_offset pure (asm_locals leave; dual-export ban). // wave267: asm_ctx_block_slot_get pure (asm_locals leave; dual-export ban). export extern "C" function pipeline_block_let_type_ref(arena: *u8, block_ref: i32, let_idx: i32): i32; export extern "C" function asm_local_slot_reg_offset(arena: *u8, type_ref: i32, off: i32, inout_off: *i32): i32; // wave267: asm_ctx_local_append pure (asm_locals leave; dual-export ban). // wave267: asm_ctx_local_count pure (asm_locals leave; dual-export ban). // wave126 Cap residual: next_offset pure leave callees. // wave143: glue_array_temp_bytes_for_let_init pure-owned (array_lit leave) — no Cap residual. // wave127 Cap residual: panic pure leave callees (encoder + expr emit still host-cc / asm). // PLATFORM: SHARED freestanding emit — pure owns PANIC / div-zero ELF face only. // Use public pipeline_asm_emit_expr_elf_c (not static _rec) for msg operand emit. export extern "C" function backend_enc_mov_imm32_to_w0_arch(elf_ctx: *u8, imm: i32, ta: i32): i32; export extern "C" function backend_enc_test_rbx_rbx_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_jne_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32; export extern "C" function backend_enc_label_arch(elf_ctx: *u8, name: *u8, name_len: i32, is_global: i32, ta: i32): i32; // wave288: body live in seed ALWAYS (WAVE288_ASM_LABEL_FORMAT_ALWAYS); dual-export ban. // PLATFORM: SHARED freestanding Cap leave — pure does not re-define. export extern "C" function pipeline_asm_emit_next_label_c(ctx: *u8, buf: *u8, buf_size: i32): i32; export extern "C" function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32; // wave128 Cap residual: logand/logor pure leave callees (binop faces + short-circuit encoders). // PLATFORM: SHARED freestanding emit — pure owns LOGAND/LOGOR ELF face only. // Operand emit uses public pipeline_asm_emit_expr_elf_c (→ host-cc _rec); do not Cap residual // the static _rec symbol (G.7 public face only). export extern "C" function pipeline_expr_binop_left_ref_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_binop_right_ref_at(arena: *u8, expr_ref: i32): i32; // wave136 Cap residual: fold_primitives pure leave (AST pattern detectors). // Pool faces + residual static→extern helpers (vector_simd / as). // PLATFORM: SHARED — pure owns 13 fold detection faces; residual owns pool + as/param helpers. export extern "C" function pipeline_block_let_name_len(arena: *u8, block_ref: i32, let_idx: i32): i32; export extern "C" function pipeline_block_let_name_copy64(arena: *u8, block_ref: i32, let_idx: i32, dst: *u8): void; export extern "C" function pipeline_block_let_init_ref(arena: *u8, block_ref: i32, let_idx: i32): i32; export extern "C" function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_field_access_name_len(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_field_access_name_into(arena: *u8, expr_ref: i32, out: *u8): void; export extern "C" function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_index_index_ref(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_as_operand_ref_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_call_num_args_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_call_arg_ref(arena: *u8, expr_ref: i32, idx: i32): i32; // wave148 pure leave: glue_expr_is_func_param_at_c + glue_fold_func_return_operand_ref_c live in this file. // wave138: glue_expr_is_x_as_cast_at_c is pure export (#[no_mangle]) — was Cap residual for // fold_primitives leave when as.c still host-cc; do not re-declare export extern "C" or // pure call sites mangle to _glue_expr_is_x_as_cast_at_c_u8_ptr_i32_reti32 (G.7 single face). // wave137 Cap residual: cmp pure leave callees (operand placement + encoders + CTFE accessors). // PLATFORM: SHARED freestanding emit — pure owns CMP ELF + typekind tag + cc maps. export extern "C" function pipeline_expr_const_folded_valid_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_const_folded_val_at(arena: *u8, expr_ref: i32): i32; // wave151 pure-owned leave: pipeline_expr_enum_namespace_field_tag lives in EOF wave151 section. // wave196 pure-owned: pipeline_asm_call_return_type_kind_ord_c body at EOF (#[no_mangle]). // G.7 ban dual export extern + pure export for the same symbol. // wave149 pure-owned faces: bodies in EOF section (#[no_mangle] export; no dual export extern). // wave188 pure-owned leave: glue_var_expr_stack_off_elf_c lives in EOF wave188 section // (#[no_mangle] export; dual-export ban — do not re-declare export extern "C"). /* wave210 pure-owned: glue_binop_var_slot_cache_invalidate_rbx at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ export extern "C" function backend_enc_ucomisd_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_ucomiss_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_fp_cmp_setcc_movzbl_arch(elf_ctx: *u8, cc: i32, ta: i32): i32; // wave138 Cap residual: as pure leave callees (pool float bits + IEEE pack + // cast encoders + try cleanup + as target type + array lit elem type). // PLATFORM: SHARED freestanding emit — pure owns as/await/try/float-lit faces. export extern "C" function pipeline_expr_float_bits_lo_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_float_bits_hi_at(arena: *u8, expr_ref: i32): i32; export extern "C" function glue_ieee_f64_bits_to_f32_bits(lo: i32, hi: i32): i32; export extern "C" function glue_ieee_f32_bits_to_f64_lo(fb: i32): i32; export extern "C" function glue_ieee_f32_bits_to_f64_hi(fb: i32): i32; // wave152 Cap residual: int→IEEE pack for pure expr_elf_fast CTFE / EXPR_LIT float stamp (G.7 next to ieee_*). export extern "C" function glue_i32_to_f32_bits(v: i32): i32; export extern "C" function glue_i64_to_f32_bits(v: i64): i32; export extern "C" function glue_i64_to_f64_bits(v: i64, lo: *i32, hi: *i32): void; export extern "C" function pipeline_expr_as_target_type_ref_at(arena: *u8, expr_ref: i32): i32; // wave143 pure leave: pipeline_asm_array_lit_elem_type_ref live in this file. /* wave169: pure owns glue_index_scratch_spills_cleanup_all_elf_c (#[no_mangle] below). */ /* wave207 pure-owned: glue_index_scratch_stack_depth_get/set at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave171: pure owns glue_enc_pop_index_scratch_stack_arm64_elf_c (#[no_mangle] below). */ /* wave209 pure-owned: glue_index_scratch_caches_hit_var at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave208 pure-owned: glue_binop_stack_spill_append_at_depth / cap_get at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave209 pure-owned: minus_pair/subadd3 CAP cache BSS thin faces at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave172: pure owns minus_pair/subadd3 cache spill helpers (#[no_mangle] below). */ export extern "C" function arch_x86_64_enc_enc_test_edx_edx(elf_ctx: *u8): i32; export extern "C" function backend_enc_cvttss2si_eax_from_f32_bits_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cvttsd2si_eax_from_f64_bits_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cvttss2si_rax_from_f32_bits_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cvttsd2si_rax_from_f64_bits_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cvtsi2ss_eax_from_i32_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cvtsi2ss_eax_from_i64_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cvtsi2ss_eax_from_u64_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cvtsd2ss_eax_from_f64_bits_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cvtsi2sd_rax_from_u64_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cvtsi2sd_rax_from_i64_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cvtsi2sd_rax_from_i32_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cvtss2sd_rax_from_f32_bits_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cmp_setcc_movzbl_arch(elf_ctx: *u8, cc: i32, ta: i32): i32; export extern "C" function backend_enc_load_rbp_to_rbx_arch(elf_ctx: *u8, offset: i32, ta: i32): i32; export extern "C" function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32; export extern "C" function backend_enc_mov_imm32_to_rbx_arch(elf_ctx: *u8, imm: i32, ta: i32): i32; export extern "C" function backend_enc_pop_rbx_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_test_eax_eax_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_jz_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32; export extern "C" function backend_enc_jnz_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32; export extern "C" function backend_enc_jmp_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32; // wave153 Cap residual: block_body pure leave callees (host-cc residual live/spill/CAP). // PLATFORM: SHARED freestanding emit — pure owns body_sync + defer + final_expr + if_arm. // wave212 pure owns color/pin BSS; wave213 pure owns live control scalars + // interf graph BSS + linear_ctx bind + pressure thresh (#[no_mangle] EOF). // wave214 pure owns live set arrays + opaque u8 overlay thins (#[no_mangle] EOF). /* wave212 pure-owned: glue_asm73_cfg_coloring_active_get/set at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave213 pure-owned: glue_block_live_cfg_parent_* / active_* / emit_stmt_i_* * at EOF (#[no_mangle]). G.7 ban dual export. */ /* wave214 pure-owned: glue_block_live_fwd_as_u8 + live set BSS thins at EOF. * G.7 ban dual export extern + pure export for the same symbol. */ /* wave212 pure-owned: glue_asm73_pin_spill_off_clear_all at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave214 pure-owned: glue_asm73_cfg_peak_live_n_get / peak_* / live_fwd_* at EOF. */ // wave176 pure-owned: glue_block_compute_live_end_linear_to_sub_exit_snap (#[no_mangle] below). /* wave214 pure-owned: glue_live_fwd_n_get/off_at/clear_u8/add_u8 at EOF. */ // wave154 pure-owned: pipeline_expr_struct_lit_num_fields body in EOF section. export extern "C" function pipeline_expr_struct_lit_init_ref(arena: *u8, expr_ref: i32, j: i32): i32; /* wave167: pure owns glue_block_compute_cfg_peak_live_and_color + note_cfg_live_peak (#[no_mangle] below). */ // wave176 pure-owned: glue_block_compute_linear_live_in (#[no_mangle] below). /* wave213 pure-owned: glue_asm73_cfg_interf_prepare at EOF (#[no_mangle]). * wave214 pure-owned: glue_asm73_cfg_peak_clear (peak_live BSS pure). */ /* wave168: pure owns glue_block_simulate_cfg_live + from_empty (#[no_mangle] below). */ /* wave213 pure-owned: glue_asm73_linear_ctx_bind + linear_* getters at EOF. */ /* wave214 pure-owned: glue_asm73_cfg_peak_stmt_i_get / peak_live_as_u8 / * peak_snapshot_from_u8 / glue_live_fwd_copy_u8 at EOF. */ /* wave213 pure-owned: glue_asm73_interf_add_live_set_u8 / linear_max_* at EOF. */ // wave176 pure-owned: glue_block_stmt_gen_kill_u8 + glue_live_fwd_apply_stmt_gen_kill_u8 (#[no_mangle] below). /* wave213 pure-owned: glue_asm73_interf_push / pop_merge at EOF (#[no_mangle]). */ /* wave212 pure-owned: glue_asm73_cfg_final_expr_use_n_set at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave165: pure owns glue_asm73_compute_spill_color_pins (#[no_mangle] below). */ /* wave212 pure-owned: glue_asm73_clear_spill_color_map at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave173: pure owns glue_block_live_fwd_before_stmt + apply_top_stmt (#[no_mangle] below). */ // wave176 pure-owned: glue_live_fwd_forward_after_def (#[no_mangle] below). /* wave163: pure owns glue_binop_cache_intersect_live_fwd (#[no_mangle] below). */ /* wave214 pure-owned: glue_block_live_fwd_contains_off at EOF. */ /* wave213 pure-owned: interf_n_get / off_at / has_edge / clear / add_live_at_stmt * + linear_nso_get at EOF (#[no_mangle]). G.7 ban dual export. */ // wave176 pure-owned: glue_asm73_linear_next_use_dist (#[no_mangle] below). /* wave212 pure-owned: glue_asm73_set_spill_color / off_spill_color_which / * pin_spill_off_set at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave164: pure owns glue_asm73_compute_spill_color_chaitin (#[no_mangle] below). */ /* wave214 pure-owned: live_at_stmt[] BSS + n_get / as_u8 at EOF. */ /* wave213 pure-owned: glue_asm73_pressure_live_thresh_get at EOF (#[no_mangle]). */ /* wave208 pure-owned: glue_binop_stack_spill_find_depth at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave174: pure owns glue_asm73_evict_rax|rbx_cache_entry (#[no_mangle] below). */ /* wave166: pure owns pressure eviction faces (#[no_mangle] below). */ /* wave175: pure owns mov_reg_to_spill / try_colored / farthest / pick_evict (#[no_mangle] below). */ /* wave212 pure-owned: glue_asm73_stack_spill_enabled / off_is_spill_pin at EOF * (#[no_mangle]). wave213: stack_spill_enabled reads pure cfg_parent + max_live. */ /* wave210 pure-owned: glue_binop_var_slot_cache_set_spill_slot at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave214 pure-owned: remove/contains_u8 / live_at_stmt_copy / sub_exit / * fwd remove/add_off at EOF. */ /* wave213 pure-owned: linear_arena/ctx/block_ref/slot_base/nconst/nlet getters * + linear_max_live_n_set at EOF (#[no_mangle]). G.7 ban dual export. */ /* wave210 pure-owned: glue_binop_var_slot_cache x10–x15 valid/off getters + * set_valid_x* at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave208 pure-owned: glue_binop_stack_spill_n_get / off_at / drop_off / clear at EOF * (#[no_mangle]). G.7 ban dual export extern + pure export for the same symbol. */ // wave159 pure-owned: glue_block_stmt_order_has_cfg body in EOF section (was Cap residual spill). // wave156 pure-owned: glue_expr_kind_is_assign_like_ord + try_block_let_index_init + kill_assign_lhs in EOF. /* wave209 pure-owned: glue_index_subadd3_sum_cache_clear / minus_pair_cache_clear at EOF. * G.7 ban dual export extern + pure export for the same symbol. */ // wave207 pure-owned: glue_binop_rax_frame_spill_n_set + glue_index_scratch_stack_depth_set at EOF. // G.7 ban dual export extern + pure export for the same symbol. // wave208 pure-owned: glue_binop_stack_spill_clear at EOF (#[no_mangle]). // wave220 pure-owned: glue_if_expr_arm_emit_depth_get/set + pure BSS at EOF // (#[no_mangle]). G.7 ban dual export extern + pure export for the same symbol. /* wave261 pure-owned: glue_block_body_bind_module_dep_from_ctx body at EOF * (#[no_mangle]). G.7 ban dual export extern + pure export for the same symbol. */ export extern "C" function backend_block_slot_base_for(ctx: *u8, arena: *u8, block_ref: i32): i32; // wave155 pure-owned leave: backend_emit_while_loop_elf_sync(arena: *u8, elf_ctx: *u8, block_ref: i32, loop_idx: i32, ctx: *u8, ta: i32): i32; body in EOF section. // wave155 pure-owned leave: backend_emit_for_loop_elf_sync body in EOF section. export extern "C" function pipeline_block_region_with_arena_cap_ref(arena: *u8, block_ref: i32, ri: i32): i32; export extern "C" function pipeline_block_labeled_is_goto(arena: *u8, block_ref: i32, li: i32): i32; export extern "C" function pipeline_block_labeled_label_len(arena: *u8, block_ref: i32, li: i32): i32; export extern "C" function pipeline_block_labeled_label_copy32(arena: *u8, block_ref: i32, li: i32, dst: *u8): void; export extern "C" function pipeline_block_labeled_goto_target_len(arena: *u8, block_ref: i32, li: i32): i32; export extern "C" function pipeline_block_labeled_goto_target_copy32(arena: *u8, block_ref: i32, li: i32, dst: *u8): void; // wave129 Cap residual: block_if pure leave callees (host-cc residual live/scope/body faces). // PLATFORM: SHARED freestanding emit — pure owns block-level if ELF + if_then_block_body face. // Cond operand uses public pipeline_asm_emit_expr_elf_c (→ host-cc _rec). Live buffers are // opaque u8[136] overlays of GlueBlockLiveFwd (offs[32]+n; Cap residual casts). export extern "C" function ast_pipeline_block_if_cond_ref(arena: *u8, block_ref: i32, if_idx: i32): i32; export extern "C" function ast_pipeline_block_if_then_body_ref(arena: *u8, block_ref: i32, if_idx: i32): i32; export extern "C" function ast_pipeline_block_if_else_body_ref(arena: *u8, block_ref: i32, if_idx: i32): i32; /* wave261 pure-owned: glue_asm_ctx_set_scope_block body at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave282: per-ctx scope_block_ref seed ALWAYS (bootstrap leave). */ export extern "C" function asm_ctx_set_scope_block(ctx: *u8, block_ref: i32): void; // wave133: glue_enc_jz_after_bool_in_eax is pure export below (unary leave). // Was Cap residual when host leaf owned the face; block_if / async_cps call pure. export extern "C" function backend_ensure_block_local_slots(ctx: *u8, arena: *u8, block_ref: i32): void; // wave145 pure leave: pipeline_asm_fill_block_locals_tree live in this file. // wave153 pure-owned: pipeline_asm_emit_block_body_sync_elf body in EOF section. /* wave214 pure-owned: glue_block_fill_live_end_for_merge at EOF. */ // wave153 pure-owned: glue_block_stmt_order_has_return body in EOF section. /* wave214 pure-owned: glue_live_fwd_copy_from_snap_before_if at EOF. */ // wave158 pure-owned: glue_asm_cache_invalidate_at_cfg_merge_selective + // glue_asm_if_phi_invalidate_both_branch_defs + glue_cfg_collect/add/contains // live in EOF section (was Cap residual spill). // wave159 pure-owned: glue_asm_loop_phi_invalidate_carried_defs body in EOF. // wave160 pure-owned: glue_asm_if_merge_live_union_from_ends + // glue_asm_loop_merge_live_union body in EOF (was Cap residual spill). // wave161 pure-owned: glue_live_fwd_apply_expr_effect body in EOF (was Cap residual). // wave162 pure-owned: pipeline_asm_emit_break_elf_c / continue_elf_c body in EOF. // wave155 Cap residual (spill un-static): break push/pop (step effect → pure wave161). /* wave214 pure-owned: glue_loop_break_exit_push/pop at EOF. */ // wave176 pure-owned: glue_live_fwd_collect_expr_uses (#[no_mangle] below). // wave160 Cap residual thin accessors for pure live-merge leave (BSS still spill). /* wave214 pure-owned: glue_block_live_fwd_copy_from_u8 at EOF. */ // wave161 Cap residual: union opaque gen into global block_live_fwd. /* wave214 pure-owned: glue_block_live_fwd_union_from_u8 at EOF. */ /* wave214 pure-owned: loop break/continue depth + union_into_u8 at EOF. */ // wave162 Cap residual thin: note live at break/continue into stack BSS. /* wave214 pure-owned: loop break/continue note_current at EOF. */ // wave141: pipeline_asm_fill_local_slots pure export below (emit-context leave). // wave153 pure-owned: backend_emit_block_body_sync_elf body in EOF section. // wave131 Cap residual: async_cps pure leave callees (encoders + async_asm_pool + local offset). // PLATFORM: SHARED freestanding emit — pure owns CPS bag + entry/end/await/phase_reset faces. // async_asm_pool_build_layout already pure (async_asm_pool.x); Cap as link face. // push/pop/load32/mov_rbx/cmp/jeq are backend_enc_dispatch pure; Cap residual for this TU. export extern "C" function async_asm_pool_build_layout(arena: *u8, mod: *u8, func_index: i32, out: *u8): i32; export extern "C" function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32; // wave202 Cap residual: arm64 MEMORY-by-value SP store (backend_enc_dispatch pure). export extern "C" function backend_enc_store_x0_sp_offset_arch(elf_ctx: *u8, off_bytes: i32, ta: i32): i32; export extern "C" function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_load_32_from_rax_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cmp_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_jeq_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32; // wave132 Cap residual: struct_let pure leave callees (struct lit fields + CALL sizing/store + // try_inline + expected-ret + module_from_ctx). lea/mov_arg already Cap residual above; // glue_arm64_mov_x0_to_x8_elf_c is pure export (lea_common leave); emit_expr uses public // pipeline_asm_emit_expr_elf_c (not static _rec). PLATFORM: SHARED freestanding emit. // wave154 pure-owned: pipeline_asm_emit_struct_lit_fields_elf_c body in EOF section. export extern "C" function try_inline_struct_lit_return_call_to_slot_elf(arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32): i32; export extern "C" function try_inline_const_struct_lit_return_call_to_slot_elf(arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32): i32; // wave206 pure-owned: pipeline_asm_set/call_expected_ret_ty_c + pure BSS at EOF. // G.7 ban dual export extern + pure export for the same symbol. // wave194 pure-owned: glue_call_return_byte_size_c body at EOF (#[no_mangle]). // wave195 pure-owned: pipeline_asm_call_arg_value_byte_size_c body at EOF (#[no_mangle]). // wave196 pure-owned: pipeline_asm_call_return_type_kind_ord_c body at EOF (#[no_mangle]). // wave197 pure-owned: pipeline_asm_call_struct16_ret_needs_rax_deref_c + // pipeline_asm_deref_struct16_rax_ptr_elf_c bodies at EOF (#[no_mangle]). // wave198 pure-owned: pipeline_asm_call_param_type_ref_at_c body at EOF (#[no_mangle]). // wave199 pure-owned: glue_asm_resolve_call_target_module_c body at EOF (#[no_mangle]). // G.7 ban dual export extern + pure export for the same symbol. // Resolve callees (Cap residual / pool): typeck resolve + find_func + call resolved_* . export extern "C" function pipeline_expr_call_resolved_func_index_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_call_resolved_dep_index_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_typeck_resolve_call_func_index_for_emit_c(m: *u8, a: *u8, call_expr_ref: i32): i32; export extern "C" function pipeline_typeck_find_func_return_type_in_module_by_name_c( mod: *u8, caller_arena: *u8, name: *u8, name_len: i32, from_dep_index: i32, ctx: *u8, func_index_out: *i32): i32; export extern "C" function pipeline_typeck_find_func_return_type_in_module_c( mod: *u8, mod_arena: *u8, caller_arena: *u8, callee_arena: *u8, callee_expr_ref: i32, from_dep_index: i32, ctx: *u8, func_index_out: *i32): i32; export extern "C" function pipeline_typeck_get_dep_return_type_in_caller_arena_c(from_dep_index: i32, dep_return_type_ref: i32, caller_arena: *u8, ctx: *u8): i32; // wave198: slow-path dep type_ref → caller-arena map (Cap residual method_call). // PLATFORM: SHARED — param formal type_ref must never cross arenas raw. export extern "C" function pipeline_typeck_dep_return_type_to_caller_arena_c(dep_arena: *u8, dep_return_type_ref: i32, caller_arena: *u8): i32; // wave154 pure-owned: glue_type_size_simple body in EOF section. // wave191 pure-owned: glue_type_named_layout_size_any_module_elf_c lives at EOF (#[no_mangle]). // G.7 ban dual export extern + pure export for the same symbol. // wave204 pure-owned: glue_store_retval_pair_to_rbp_elf_c + private // glue_copy_large_struct_from_rax_ptr_elf_c bodies at EOF (#[no_mangle] public). // wave205 pure-owned: glue_slice_let_reent_deep_copy_after_dual_gp_elf_c at EOF // (#[no_mangle] public). G.7 ban dual export extern + pure export. // wave189 pure-owned: glue_emit_module_from_ctx live at EOF (#[no_mangle]). // G.7 ban dual export extern + pure export for the same symbol. // wave133 Cap residual: unary pure leave callees (operand emit + float classifiers + // int64 lit + arch encoders). glue_var_decl_type_ref_elf_c is pure (var_decl leave). // PLATFORM: SHARED freestanding emit — pure owns NEG/LOGNOT/BITNOT + sxt + jz faces. // wave149 pure-owned faces: bodies in EOF section (#[no_mangle] export; no dual export extern). export extern "C" function pipeline_expr_int64_val_at(arena: *u8, expr_ref: i32): i64; export extern "C" function backend_enc_neg_eax_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_not_eax_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_setz_movzbl_eax_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function arch_arm64_enc_enc_u32_le(elf_ctx: *u8, val: i32): i32; // wave134 Cap residual: match pure leave callees (MATCH/EXPR_IF arm faces + if_arm + // struct layout for subject field-bind). Enc jmp/jne/label/mov/cmp + next_label + // emit_expr_elf_c + module/func_index getters already Cap residual above. // PLATFORM: SHARED freestanding emit — pure owns match_elf + expr_if_elf + subject BSS. export extern "C" function pipeline_expr_match_matched_ref_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_match_num_arms_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_match_arm_is_wildcard(arena: *u8, expr_ref: i32, i: i32): i32; export extern "C" function pipeline_expr_match_arm_guard_ref(arena: *u8, expr_ref: i32, i: i32): i32; export extern "C" function pipeline_expr_match_arm_result_ref(arena: *u8, expr_ref: i32, i: i32): i32; export extern "C" function pipeline_expr_match_arm_is_enum_variant(arena: *u8, expr_ref: i32, i: i32): i32; export extern "C" function pipeline_expr_match_arm_variant_index(arena: *u8, expr_ref: i32, i: i32): i32; export extern "C" function pipeline_expr_match_arm_lit_val(arena: *u8, expr_ref: i32, i: i32): i32; export extern "C" function pipeline_expr_if_cond_ref_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_if_then_ref_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_if_else_ref_at(arena: *u8, expr_ref: i32): i32; // wave153 pure-owned: pipeline_asm_emit_expr_if_arm_elf_c body in EOF section. // wave154 Cap residual: struct_lit pure leave callees (size glue + diagnostics + dual-GP). // wave266: pipeline_module_struct_layout_* / num_struct_layouts_at pure (struct_layout leave; dual-export ban). export extern "C" function typeck_x_type_size_from_layout_glue(module: *u8, arena: *u8, li: i32, depth: i32): i32; export extern "C" function typeck_soa_array_storage_size_glue(module: *u8, arena: *u8, elem_type_ref: i32, array_len: i32, depth: i32): i32; export extern "C" function pipeline_typeck_type_refs_equal_c(arena: *u8, a: i32, b: i32): i32; export extern "C" function backend_enc_load_qword_rbx8_to_rdx_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function driver_diagnostic_typeck_struct_padding_before(sname: *u8, sname_len: i32, gap: i32, fname: *u8, fname_len: i32): void; export extern "C" function driver_diagnostic_typeck_struct_padding_trailing(sname: *u8, sname_len: i32, gap: i32): void; export extern "C" function driver_diagnostic_typeck_struct_field_bad_size(sname: *u8, sname_len: i32, fname: *u8, fname_len: i32): void; export extern "C" function driver_diagnostic_warn_pad_fields_same_cache_line(sname: *u8, sname_len: i32, f0: *u8, f0_len: i32, f1: *u8, f1_len: i32): void; export extern "C" function driver_diagnostic_hint_unused_binding(line: i32, col: i32, name: *u8, name_len: i32): void; export extern "C" function driver_diagnostic_warn_hot_reorder_field(sname: *u8, sname_len: i32, hot: *u8, hot_len: i32, cold: *u8, cold_len: i32): void; /* wave235 G.7: env via public pure thin link_abi_getenv (wave222 -> _impl host getenv); * not raw libc getenv. Cap residual host getenv stays only link_abi_getenv_impl. * Used by pipeline_asm_debug_enabled + pipeline_debug_trace_named_func_bodies_impl. * PLATFORM: SHARED - product hybrid pipeline_abi pure uses same face as cold seed. */ export extern "C" function link_abi_getenv(name: *u8): *u8; export extern function link_abi_host_is_windows(): i32; /* wave1222: extern declarations for parser_parse_into_init body. * These mirror the C authority in parser_gen.c L6318-6331 to ensure the * .x strong symbol performs identical AST arena/module state reset. * Without this, the empty .x body overrode the C init, causing AST arena * state leakage between file checks in directory mode (T001 cascades). * PLATFORM: SHARED - all externs are platform-agnostic arena/module reset. */ // wave276: ast_ast_arena_init pure-owned at EOF (dual-export ban; no Cap residual) export extern "C" function ast_pool_module_reset(module: *u8): void; export extern "C" function ast_pool_arena_reset(arena: *u8): void; export extern "C" function parser_onefunc_result_layout_prime(): void; export extern "C" function parser_onefunc_result_layout_prime_b(): void; export extern "C" function parser_onefunc_result_layout_prime_c(): void; export extern "C" function parser_onefunc_result_layout_prime_d(): void; export extern "C" function parser_onefunc_result_layout_prime_d_b(): void; export extern "C" function parser_onefunc_result_layout_prime_e(): void; export extern "C" function parser_onefunc_result_layout_prime_f(): void; export extern "C" function parser_pipeline_module_reset_parse_counters(module: *u8): void; export extern "C" function pipeline_parser_set_match_module(module: *u8): void; /* wave1222: trait registry + generic bound source stash (mirrors C impl_c). * Without these, directory-mode check leaks trait/generic state across files, * causing the parser to misbehave (e.g. num_funcs drops from 356 to 104 for * runtime_pipeline_abi.x when checked after other files). * PLATFORM: SHARED - pure delegation to platform-agnostic externs. */ export extern "C" function xlang_trait_reg_reset_c(arena: *u8): void; export extern "C" function xlang_generic_bound_stash_source_buf_c(data: *u8, len: i32): void; /* wave1223: extern declarations for pipeline_parse_set_main_from_buf_c body. * Live G.7 authority is this .x / runtime_pipeline_abi seed (historical C twin * in deleted ast_pool.c left wave309). Keep parse + main_idx set identical to * the pre-leave contract so directory mode does not skip files. * Without this, an empty .x body (return 0) overrode the prior C impl, causing * pipeline_run_x_pipeline to skip parsing entirely in directory mode * (num_funcs=190 instead of 377 for runtime_driver_abi_thin.x). * PLATFORM: SHARED - all externs are platform-agnostic parse/diag helpers. */ // wave121: pipeline_lint_set_source_buf + pipeline_module_set_main_func_index pure below. // (lint_meta pure-owned leave) export extern "C" function driver_diagnostic_parse_fail(main_idx: i32, num_funcs: i32, arena_num_types: i32): void; // wave276: pipeline_arena_num_types pure-owned at EOF (dual-export ban) /* wave112: pipeline_parse_into_with_init_buf_scalars is pure export below * (parse_typeck_dispatch leave). Cap residual unpack is * pipeline_parse_into_with_init_buf_impl_rc (pipeline_parse_orch.c) over * Cap-struct-return impl_c / strict_parse_into_init. */ /** * G.7: parser_x owns parser_parse_into_init. This TU must not emit a * competing T — FORCE mega previously first-won (g05 pabi is #8, * parser_x.o is #20) with hoist-target modlet seed dumped into the * wrapper (1744B lea COMMON inits, then the 13 calls). Product Ubuntu * already used parser_x (pabi W); Darwin pabi T was the duplicate. * PLATFORM: SHARED — link-name contract; parser_x.o provides the body. */ export extern function parser_parse_into_init(module: *u8, arena: *u8): void; /** * G.7: parser_x owns parser_get_module_num_imports. Mega's `return 0` * stub first-wins under FORCE and reports zero imports. * PLATFORM: SHARED — parser_x.o provides the body. */ export extern function parser_get_module_num_imports(module: *u8): i32; /** * G.7: leftover WAVE274 / asm_wpo_thin owns PGO emit-order prepare. * FORCE mega T first-won a smashed body (call-next-insn / emit_n imm 0); * mega_body then called emit_order_at which returned -1 for every slot * so w393_mega_emit_one hit `if (i < 0) return 0` and wrote no text * (CG002 code_len=0). This TU must not emit a competing T. * PLATFORM: SHARED — leftover from_x WAVE274 provides the body. */ export extern function pipeline_asm_wpo_pgo_emit_order_prepare(m: *u8): void; /** * G.7: leftover WAVE274 owns emit-order count (pairs with prepare/at). * FORCE mega T of count happened to load emit_n=2 while at() used imm 0. * PLATFORM: SHARED — leftover from_x WAVE274 provides the body. */ export extern function pipeline_asm_wpo_pgo_emit_order_count(m: *u8): i32; /** * G.7: leftover WAVE274 owns emit-order at (func index or -1). * FORCE mega/thin asm lowered `order_index >= g_aw_pgo_emit_n` to * `mov $0, %eax` (no reloc); leftover gcc keeps RIP load of emit_n. * PLATFORM: SHARED — leftover from_x WAVE274 provides the body. */ export extern function pipeline_asm_wpo_pgo_emit_order_at(m: *u8, order_index: i32): i32; /** * G.7: leftover WAVE153 gcc owns two-pass stmt_order block-body ELF emit. * FORCE mega T first-won a smash (`sub $0x5228`, cltq on i32 block_ref) * over leftover W 0x22c6. parse_orch emit_one#2 then failed in * w499_mega_emit_body_sync (backend_emit_block_body_sync_elf mega T * `sub $0x8a8` / call-next-insn). Mega must not emit a competing T. * PLATFORM: SHARED — leftover from_x WAVE153 provides the body. */ export extern function pipeline_asm_emit_block_body_sync_elf(arena: *u8, elf_ctx: *u8, block_ref: i32, ctx: *u8, ta: i32): i32; /** * G.7: leftover WAVE153 gcc owns backend.x body_sync entry (84B wrapper: * diverged_set + bind_module_dep + inner emit). FORCE mega T smash * (`sub $0x8a8`) first-won leftover W 0x54. * PLATFORM: SHARED — leftover from_x WAVE153 provides the body. */ export extern function backend_emit_block_body_sync_elf(arena: *u8, elf_ctx: *u8, block_ref: i32, ctx: *u8, ta: i32): i32; /** * G.7: leftover WAVE152 gcc owns emit_expr_elf fast path (LIT / const_fold / * VAR / binop). FORCE mega T first-won smash (`sub $0x2e98` / cltq) over * leftover W 0x1200. parse_orch emit_one#2 then failed innermost at * pipeline_asm_emit_expr_elf_fast#63 eax=-1 after leftover body_sync W * was already live. Mega must not emit a competing T. * Same-TU callers (binop load_operand / emit_expr_elf_rec) stay in unsafe. * PLATFORM: SHARED — leftover from_x WAVE152 provides the body. */ export extern function pipeline_asm_emit_expr_elf_fast(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32; /** * G.7: leftover WAVE273 gcc overlay owns F7 data-section length. * FORCE mega T smash (`sub $0x888`) first-won leftover W 0x22 and RIP-loads * mega `g_pipe_elf_data_len`, not leftover `g_pipeline_elf_data_len`. * Same-TU localize of mega T still binds prepare's CALL to mega local t. * Mega must emit U so leftover gcc W is the sole global. * wave744: leftover-gcc sidecar first-wins this weak T and writes both BSS * homes so compact macho_write (inlines leftover C) emits __DATA. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_emit_data_len(ctx_bytes: *u8): i32; /** * G.7: leftover WAVE273 gcc overlay owns F7 append-zeros (grows data_len). * FORCE mega T smash (`sub $0x898` / cltq) first-won leftover W 0xa2. * gdb asm_wpo: mega smash append $rip, leftover gcc poke then sees data_len=0. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_append_data_zeros(ctx_bytes: *u8, n: i32): i32; /** * G.7: leftover WAVE273 gcc overlay owns F7 data poke (0x4c, RIP data_len). * FORCE mega T first-won smash poke; leftover gcc poke requires leftover * gcc append to have grown the same BSS. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_data_poke_u8(ctx_bytes: *u8, off: i32, b: i32): i32; /** * G.7: leftover smash T of bake_scalar_imm_to_data is the working body * (product gdb eax=0; mega smash `sub $0x8c8` eax=-1). No leftover gcc W * of this face. Same-TU localize still binds mega prepare to mega local t. * Mega must emit U so leftover T (weaken→W) is the sole global. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover pabi T provides the body. */ export extern function pipe_modlet_bake_scalar_imm_to_data( elf_ctx: *u8, data_off: i32, imm: i32, csz: i32 ): i32; /** * G.7: leftover WAVE273 gcc overlay owns add_sym (W 0x22d, endbr64). * FORCE mega T smash first-won leftover W. leftover gcc add_common_sym * CALLs this face; mega smash add_sym RIP-loads `g_pipe_elf_*` sidecar * while leftover gcc uses `g_pipeline_elf_*` + leftover ctx layout. * Same-TU localize of mega T still binds mega prepare's CALL to local t. * Mega must emit U so leftover gcc W is the sole global. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_add_sym( ctx_bytes: *u8, name: *u8, name_len: i32, offset: i32 ): i32; /** * G.7: leftover WAVE273 gcc overlay owns add_common_sym (W 0x138, endbr64). * FORCE mega T smash first-won leftover W. Dual BSS: mega * `g_pipe_elf_sym_is_common` ≠ leftover `g_pipeline_elf_sym_is_common`. * leftover gcc add_common_sym calls leftover gcc add_sym (same family). * Do not leftover-first smash-only `modlet_prepare` (layout mismatch). * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_add_common_sym( ctx_bytes: *u8, name: *u8, name_len: i32, sym_size: i32, sym_align: i32 ): i32; /** * G.7: leftover WAVE273 gcc overlay owns add_label (W 0x1f0, endbr64). * FORCE mega T smash first-won leftover W. Dual BSS: mega * `g_pipe_elf_label_shndx` ≠ leftover `g_pipeline_elf_label_shndx`. * leftover gcc add_label uses leftover STATIC current_shndx / * label_shndx_set (not first-win-able). leftover gcc ensure_label * CALLs leftover gcc add_label (same family). Same-TU localize of * mega T still binds mega prepare's CALL to local t. Mega must emit * U so leftover gcc W is the sole global. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_add_label( ctx_bytes: *u8, name: *u8, name_len: i32, offset: i32 ): i32; /** * G.7: leftover WAVE273 gcc overlay owns ensure_label (W 0xd5, endbr64). * FORCE mega T smash first-won leftover W. leftover gcc ensure_label * CALLs leftover gcc add_label; leftover-first both faces together. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_ensure_label( ctx_bytes: *u8, name: *u8, name_len: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_assign_elf_c (W 0x4b79, endbr64). * FORCE mega T smash first-won leftover W. leftover gcc VAR assign CALLs leftover * gcc glue_emit_assign_rhs_to_rax_elf_c (W 0x59b); leftover gcc rhs_to_rax * plain (ako==28) CALLs leftover gcc glue_emit_assign_rhs_elf_c (W 0xd6). * Same-TU localize of mega T still binds mega CALL to local t. Mega must emit * U so leftover gcc W is the sole global. Family leftover-first all three. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_assign_elf_c( arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_emit_assign_rhs_to_rax_elf_c (W 0x59b, endbr64). * leftover gcc emit_assign VAR/fallback CALLs this. Family with emit_assign. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_emit_assign_rhs_to_rax_elf_c( arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_emit_assign_rhs_elf_c (W 0xd6, endbr64). * leftover gcc rhs_to_rax plain (ako==28) CALLs this; leftover gcc then * pipeline_asm_emit_expr_elf_c (already leftover-first emit_fast/rec). * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_emit_assign_rhs_elf_c( arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_expr_elf_for_call_args * (W 0x2c4f, endbr64 sub $0x248). FORCE mega T smash (sub $0x5c38 / cltq) * first-won leftover W. Same-TU localize of mega T still binds mega CALL * to local t. Mega must emit U so leftover gcc W is the sole global. * backend_call_dispatch already export-externs this face; localize * for_call_args_thin so thin W cannot first-win leftover gcc W. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_expr_elf_for_call_args( arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns asm_parser_emit_heavy_safe_helper * (W 0x22d7, endbr64 sub $0x10). FORCE mega T smash (sub $0x87c8) * first-won leftover W. Same-TU caller asm_skip_heavy_module_func_body * is already in unsafe. Do not leftover-first skip_heavy itself * (wave650 FORCE_FULL_BODIES escape). Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_parser_emit_heavy_safe_helper( m: *u8, func_index: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_emit_struct_type_let_init_elf_c * (W 0x20c9, endbr64 sub $0x3b8). FORCE mega T smash first-won leftover W. * leftover gcc STRUCT_LIT path CALLs leftover gcc * pipeline_asm_emit_struct_let_init_elf_c (W 0xa0) which CALLs leftover gcc * pipeline_asm_emit_struct_lit_fields_elf_c (W 0x169e). leftover gcc * emit_expr STRUCT_LIT CALLs leftover gcc pipeline_asm_emit_struct_lit_elf_c * (W 0x44). Family leftover-first all four so leftover gcc parent CALLs * leftover gcc children. Same-TU callers already in unsafe. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_emit_struct_type_let_init_elf_c( arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, let_ty_ref: i32, stack_slot_off: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_struct_let_init_elf_c * (W 0xa0, endbr64 sub $0x40). leftover gcc glue_emit_struct_type_let_init * CALLs this for STRUCT_LIT. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_struct_let_init_elf_c( arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_struct_lit_fields_elf_c * (W 0x169e, endbr64 sub $0xb8). leftover gcc struct_let_init / emit_struct_lit * CALL this. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_struct_lit_fields_elf_c( arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_struct_lit_elf_c * (W 0x44, endbr64 sub $0x20). leftover gcc emit_expr STRUCT_LIT CALLs this * wrapper, which CALLs leftover gcc struct_lit_fields. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_struct_lit_elf_c( arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns asm_parser_m8_tail_thin_delegate_c_name * (W 0x1f1a, endbr64 sub $0x20). FORCE mega T smash first-won leftover W. * leftover gcc skip_heavy_or_thin_stub / resolve_call_to_glue CALL this. * Do not leftover-first asm_skip_heavy_module_func_body (FORCE_FULL_BODIES * dual env). Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_parser_m8_tail_thin_delegate_c_name( m: *u8, func_index: i32, out: *u8, out_cap: i32, out_len: *i32 ): i32; /** * G.7: leftover gcc overlay owns asm_wpo_collect_walk * (W 0x1e56, endbr64 sub $0x210). FORCE mega T smash first-won leftover W. * Mega wrappers collect_edges_from_expr / collect_from_block CALL this. * asm_wpo_thin also has a body — localize so thin W cannot first-win. * Do not leftover-first asm_skip_heavy_module_func_body (FORCE_FULL_BODIES * dual env). Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_wpo_collect_walk( is_block: i32, a: *u8, ref: i32, caller_id: i32, caller_mod: *u8, ctx: *u8, depth: i32 ): void; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_return_elf_impl * (W 0x1a7e, endbr64 sub $0x1e8). FORCE mega T smash first-won leftover W. * Mega wrapper pipeline_asm_emit_return_elf_c and expr_rec CALL this. * arr_return_thin / fixed_array_copy_thin also have a body — localize so * thin W cannot first-win. HARD BAN product PREFER of return_elf_impl_thin * (FORCE user -c of that thin is T001). Do not leftover-first * asm_skip_heavy_module_func_body (FORCE_FULL_BODIES dual env). Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_return_elf_impl( arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: runtime_pipeline_abi_parser_thin_delegate_thin.x owns * asm_parser_func_is_thin_delegate. The egg copy stays weak behind that * overlay (was W 0x12d3). Mega skip_heavy CALLs this (already unsafe). * Do not add a second body here. Mega must emit U. * PLATFORM: SHARED — overlay first-wins; egg table is not the linked body. */ export extern function asm_parser_func_is_thin_delegate(m: *u8, func_index: i32): i32; /** * G.7: leftover gcc overlay owns asm_backend_m8_tail_thin_delegate_c_name * (W 0xa62, endbr64 sub $0x20). FORCE mega T smash first-won leftover W. * Mega skip_heavy_or_thin_stub CALLs this (already unsafe). No thin copy. * Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_backend_m8_tail_thin_delegate_c_name( m: *u8, func_index: i32, out: *u8, out_cap: i32, out_len: *i32 ): i32; /** * G.7: leftover gcc overlay owns asm_pipeline_m8_tail_thin_delegate_c_name * (W 0x130, endbr64 sub $0x20). FORCE mega T smash first-won leftover W. * Mega skip_heavy_or_thin_stub CALLs this (already unsafe). No thin copy. * Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_pipeline_m8_tail_thin_delegate_c_name( m: *u8, func_index: i32, out: *u8, out_cap: i32, out_len: *i32 ): i32; /** * G.7: leftover gcc overlay owns asm_typeck_m8_tail_thin_delegate_c_name * (W 0xed, endbr64 sub $0x30). FORCE mega T smash first-won leftover W. * Mega skip_heavy_or_thin_stub CALLs this (already unsafe). No thin copy. * Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_typeck_m8_tail_thin_delegate_c_name( m: *u8, func_index: i32, out: *u8, out_cap: i32, out_len: *i32 ): i32; /** * G.7: leftover gcc overlay owns asm_driver_m8_tail_thin_delegate_c_name * (W 0x64, endbr64 sub $0x20). FORCE mega T smash first-won leftover W. * Mega skip_heavy_or_thin_stub CALLs this (already unsafe). No thin copy. * Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_driver_m8_tail_thin_delegate_c_name( m: *u8, func_index: i32, out: *u8, out_cap: i32, out_len: *i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_lvalue_eff_addr_elf_c * (W 0x890, endbr64 sub $0x170). FORCE mega T smash first-won leftover W. * leftover gcc emit_assign (w710) CALLs leftover gcc this face for FIELD/INDEX * /DEREF lvalues. Thins export-extern (no body). Mega same-TU callers already * unsafe. Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_lvalue_eff_addr_elf_c( arena: *u8, elf_ctx: *u8, lval_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_enc_local_slot_ptr_or_addr_elf_c * (W 0x82, endbr64 sub $0x40). FORCE mega T smash sub $0x8b8 first-won leftover W. * leftover gcc emit_assign CALLs leftover gcc this face (field_assign HIT smash). * Thins export-extern (no body). Mega same-TU callers already unsafe. * Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_enc_local_slot_ptr_or_addr_elf_c( arena: *u8, elf_ctx: *u8, var_ref: i32, var_off: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_index_elem_byte_sz_c * (W 0x1103). FORCE mega T smash first-won leftover W. leftover gcc INDEX * / lvalue_eff_addr CALLs leftover gcc this face. Thins export-extern * (no body). Mega same-TU callers wrapped unsafe. Do not leftover-first * skip_heavy or skip_heavy_or_thin_stub parent. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_index_elem_byte_sz_c( arena: *u8, expr_ref: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_emit_index_eff_addr_scaled_elf_c * (W 0x73e). FORCE mega T smash first-won leftover W. leftover gcc INDEX * / lvalue_eff_addr / assign CALLs leftover gcc this face (index_i32 gdb * HIT). Thins export-extern (no body). Mega same-TU callers already unsafe. * Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_emit_index_eff_addr_scaled_elf_c( arena: *u8, elf_ctx: *u8, ix_ref: i32, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_try_index_var_or_field_base_to_rax_elf_c * (W 0xe0c). FORCE mega T smash first-won leftover W. leftover gcc INDEX * scaled (w725) CALLs leftover gcc this face (INDEX lit path). Thins * export-extern (no body). Mega same-TU callers wrapped unsafe. Do not * leftover-first skip_heavy, skip_heavy_or_thin_stub parent, rbx twin, * or wrapper pipeline_asm_index_elem_byte_sz. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_try_index_var_or_field_base_to_rax_elf_c( arena: *u8, elf_ctx: *u8, base_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_try_index_rvalue_slice_once_elf_c * (W 0xd2e). FORCE mega T smash first-won leftover W. leftover gcc INDEX * scaled (w725) CALLs leftover gcc this face (CALL/METHOD/INDEX/DEREF * TYPE_SLICE rvalue-once). No thin defines this symbol. Mega same-TU * remaining callers after scaled leftover-first: 0. Do not leftover-first * skip_heavy, skip_heavy_or_thin_stub parent, rbx twin, bounds_guard, * or wrapper pipeline_asm_index_elem_byte_sz. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_try_index_rvalue_slice_once_elf_c( arena: *u8, elf_ctx: *u8, ix_ref: i32, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_emit_index_bounds_guard_elf_c * (W 0x90f). FORCE mega T smash first-won leftover W. leftover gcc INDEX * scaled (w725) CALLs leftover gcc this face (INDEX bounds). No thin * defines this symbol. Mega same-TU remaining callers after scaled * leftover-first: 0. Do not leftover-first skip_heavy, skip_heavy_or_thin_stub * parent, rbx twin, rax_plus_rbx_scaled, or wrapper * pipeline_asm_index_elem_byte_sz. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_emit_index_bounds_guard_elf_c( arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32, ix_ref: i32, base_ref: i32, idx_ref: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_try_index_var_or_field_base_to_rbx_elf_c * (W 0x7dc). FORCE mega T smash first-won leftover W. leftover gcc INDEX * assign-addr→rbx forest CALLs leftover gcc this face (INDEX assign base). * No thin defines this symbol. Mega same-TU remaining callers: 18 (already * unsafe). Do not leftover-first skip_heavy, skip_heavy_or_thin_stub * parent, rax_plus_rbx_scaled, local_slot rbx twin, or wrapper * pipeline_asm_index_elem_byte_sz. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_try_index_var_or_field_base_to_rbx_elf_c( arena: *u8, elf_ctx: *u8, base_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_local_var_slot_needs_ptr_load_elf_c * (W 0x542). FORCE mega T smash first-won leftover W. leftover gcc local_slot * (w723 W 0x82) CALLs leftover gcc this face. Thin param_ptr_slot_thin HAS a * body (W 0x8dc) — must localize or thin W first-wins leftover gcc. Mega * same-TU remaining callers: 4. Do not leftover-first skip_heavy, * skip_heavy_or_thin_stub parent, rax_plus_rbx_scaled, local_slot rbx twin, * or wrapper pipeline_asm_index_elem_byte_sz. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_local_var_slot_needs_ptr_load_elf_c( arena: *u8, var_expr_ref: i32, stack_off: i32, ctx: *u8 ): i32; /** * G.7: leftover gcc overlay owns glue_copy_large_struct_from_rax_ptr_elf_c * (W 0x482). FORCE mega T smash first-won leftover W. leftover gcc * store_retval_pair (W 0x2bb) CALLs leftover gcc this face (>16B CALL * memcpy). Thins assign_thin / assign_deref_* export-extern (no body) * — still localize. Mega same-TU remaining callers: 5. Do not leftover-first * skip_heavy, skip_heavy_or_thin_stub parent, rax_plus_rbx_scaled, * local_slot rbx twin, wrapper pipeline_asm_index_elem_byte_sz, or * store_retval_pair itself. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_copy_large_struct_from_rax_ptr_elf_c( elf_ctx: *u8, slot_off: i32, sz: i32, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_emit_vector_type_let_init_elf_c * (W 0x2c5). FORCE mega T smash first-won leftover W. leftover gcc * let-init / assign SIMD paths CALL leftover gcc this face (non-vector * returns -2). Thins assign_thin / assign_var_try_let / * assign_index_simd_body / assign_field_var_simd / * assign_deref_vec_call / for_call_args export-extern (no body) * — still localize. Mega same-TU remaining callers: 5. Do not leftover-first * skip_heavy, skip_heavy_or_thin_stub parent, rax_plus_rbx_scaled, * local_slot rbx twin, wrapper pipeline_asm_index_elem_byte_sz, * store_retval_pair, or vector children (vector_let_init / var_copy / * binop / simd_try_inline_*). Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_emit_vector_type_let_init_elf_c( arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, type_ref: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_vector_let_init_elf_c * (W 0x73f). FORCE mega T smash first-won leftover W (`sub $0x13a8`). * leftover gcc vector_type_let_init (w732 W 0x2c5) CALLs leftover gcc this * face for ARRAY_LIT. Thin fixed_array_copy / arr_struct_lit_arrlit * export-extern (no body) — still localize. Mega same-TU remaining callers: 1. * Do not leftover-first skip_heavy, skip_heavy_or_thin_stub parent, * rax_plus_rbx_scaled, local_slot rbx twin, wrapper, store_retval_pair, * or other vector children (var_copy / binop / simd_try_inline_*). * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_vector_let_init_elf_c( arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_simd_try_inline_select_call_elf_c * (W 0x691). FORCE mega T smash first-won leftover W (`sub $0x13f8`). * leftover gcc vector_type_let_init (w732 W 0x2c5) CALLs leftover gcc this * face for CALL/METHOD simd.select. Mega same-TU remaining callers: 0 * (parent leftover-first). No thin defines this symbol — still localize. * Do not leftover-first skip_heavy, skip_heavy_or_thin_stub parent, * rax_plus_rbx_scaled, local_slot rbx twin, wrapper, store_retval_pair, * or other vector children (var_copy / binop / splat / shuffle / fma / * identity / binop2). Mega may not emit U (unused export-extern). * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_simd_try_inline_select_call_elf_c( arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, type_ref: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_simd_try_inline_shuffle_call_elf_c * (W 0x4ca). FORCE mega T smash first-won leftover W (`sub $0xd78`). * leftover gcc vector_type_let_init (w732 W 0x2c5) CALLs leftover gcc this * face for CALL/METHOD simd.shuffle. Mega same-TU remaining callers: 0 * (parent leftover-first). No thin defines this symbol — still localize. * Do not leftover-first skip_heavy, skip_heavy_or_thin_stub parent, * rax_plus_rbx_scaled, local_slot rbx twin, wrapper, store_retval_pair, * or other vector children (var_copy / binop / splat / fma / * identity / binop2). Mega may not emit U (unused export-extern). * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_simd_try_inline_shuffle_call_elf_c( arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, type_ref: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_simd_try_inline_fma3_call_elf_c * (W 0x47e). FORCE mega T smash first-won leftover W (`sub $0xcf8`). * leftover gcc vector_type_let_init (w732 W 0x2c5) CALLs leftover gcc this * face for CALL/METHOD simd.fma. Mega same-TU remaining callers: 0 * (parent leftover-first). No thin defines this symbol — still localize. * Do not leftover-first skip_heavy, skip_heavy_or_thin_stub parent, * rax_plus_rbx_scaled, local_slot rbx twin, wrapper, store_retval_pair, * or other vector children (var_copy / binop / splat / identity / binop2). * Mega may not emit U (unused export-extern). * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_simd_try_inline_fma3_call_elf_c( arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, type_ref: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_simd_try_inline_splat_call_elf_c * (W 0x423). FORCE mega T smash first-won leftover W (`sub $0xbb8`). * leftover gcc vector_type_let_init (w732 W 0x2c5) CALLs leftover gcc this * face for CALL/METHOD simd.splat. Mega same-TU remaining callers: 1 * (glue_simd_select_arg_stack_off_c, wrapped unsafe). No thin defines this * symbol — still localize. * Do not leftover-first skip_heavy, skip_heavy_or_thin_stub parent, * rax_plus_rbx_scaled, local_slot rbx twin, wrapper, store_retval_pair, * or other vector children (var_copy / binop / identity / binop2). * Mega may emit U (remaining caller). * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_simd_try_inline_splat_call_elf_c( arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, type_ref: i32 ): i32; /** * G.7: parser_x owns parser_get_module_import_path. * PLATFORM: SHARED — parser_x.o provides the body. */ export extern function parser_get_module_import_path(module: *u8, idx: i32, path_buf: *u8): void; /** * Copy import path at index i into out[0..64) (NUL-terminated) and return path length. * @param module *u8 - opaque AST module; null -> out[0]=0 when out valid, return 0 * @param i i32 - import index (negative / OOB handled by G.7 path_copy / ImportEntry) * @param out *u8 - destination buffer; capacity 64 bytes including NUL; null -> 0 * @return i32 - byte length of path excluding NUL; 0 on null/missing path * wave99 pure Cap residual close: G.7 single product authority for path64 surface. * Body ≡ historical parser_gen: pipeline_module_import_path_copy(..., 64) + scan NUL. * wave110: path_copy storage is pure ImportEntry map (not Cap residual). * PLATFORM: SHARED - parser_gen path64 demoted weak cold twin; product pure hybrid owns. */ #[no_mangle] export function parser_copy_module_import_path64(module: *u8, i: i32, out: *u8): i32;
export extern function glue_align_next_offset(ctx: *u8): void;
export extern function glue_arm64_mov_x0_to_x8_elf_c(elf_ctx: *u8): i32;
export extern function glue_call_return_byte_size_c(arena: *u8, call_expr_ref: i32): i32;
export extern function glue_field_access_call_arg_struct_by_addr_elf_c(arena: *u8, fa_ref: i32): i32;
export extern function glue_field_access_effective_offset_c(arena: *u8, mod: *u8, fa_ref: i32): i32;
export extern function glue_field_access_emit_scalar_load_from_rax_elf_c(elf_ctx: *u8, load_sz: i32, ta: i32): i32;
export extern function glue_field_call_arg_try_load_agg_from_rax_elf_c(arena: *u8, elf_ctx: *u8, fa_ref: i32, ta: i32): i32;
export extern function glue_field_chain_mid_auto_deref_ptr_rax_elf_c(arena: *u8, elf_ctx: *u8, fa_ref: i32, ta: i32): i32;
export extern function glue_store_retval_pair_to_rbp_elf_c(m: *u8, arena: *u8, elf_ctx: *u8, ty_ref: i32, slot_off: i32, ta: i32, init_ref: i32, ctx: *u8): i32;
export extern function glue_sysv_dual_gp_byte_size_c(arena: *u8, ty_ref: i32): i32;
export extern function glue_type_named_layout_size_any_module_elf_c(arena: *u8, ty_ref: i32): i32;
export extern function glue_type_size_simple(m: *u8, a: *u8, ty_ref: i32, depth: i32): i32;
export extern function pipe_asm_ctx_off_next_offset(): i32;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipeline_asm_ctx_layout(ctx: *u8): *u8;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipeline_asm_emit_set_call_sret_reg_shift_c(shift: i32): void;
export extern function pipeline_asm_emit_struct_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32): i32;
export extern function pipeline_asm_set_call_expected_ret_ty_c(type_ref: i32): void;
export extern function pipeline_expr_field_access_is_enum_variant(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_load_byte_sz(a: *u8, m: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32; // wave141: module_ref_c / func_index_c pure export below (emit-context leave). // wave267: asm_ctx_local_find_offset pure (asm_locals leave; dual-export ban). // wave267: asm_ctx_block_slot_get pure (asm_locals leave; dual-export ban). export extern "C" function pipeline_block_let_type_ref(arena: *u8, block_ref: i32, let_idx: i32): i32; export extern "C" function asm_local_slot_reg_offset(arena: *u8, type_ref: i32, off: i32, inout_off: *i32): i32; // wave267: asm_ctx_local_append pure (asm_locals leave; dual-export ban). // wave267: asm_ctx_local_count pure (asm_locals leave; dual-export ban). // wave126 Cap residual: next_offset pure leave callees. // wave143: glue_array_temp_bytes_for_let_init pure-owned (array_lit leave) — no Cap residual. // wave127 Cap residual: panic pure leave callees (encoder + expr emit still host-cc / asm). // PLATFORM: SHARED freestanding emit — pure owns PANIC / div-zero ELF face only. // Use public pipeline_asm_emit_expr_elf_c (not static _rec) for msg operand emit. export extern "C" function backend_enc_mov_imm32_to_w0_arch(elf_ctx: *u8, imm: i32, ta: i32): i32; export extern "C" function backend_enc_test_rbx_rbx_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_jne_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32; export extern "C" function backend_enc_label_arch(elf_ctx: *u8, name: *u8, name_len: i32, is_global: i32, ta: i32): i32; // wave288: body live in seed ALWAYS (WAVE288_ASM_LABEL_FORMAT_ALWAYS); dual-export ban. // PLATFORM: SHARED freestanding Cap leave — pure does not re-define. export extern "C" function pipeline_asm_emit_next_label_c(ctx: *u8, buf: *u8, buf_size: i32): i32; export extern "C" function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32; // wave128 Cap residual: logand/logor pure leave callees (binop faces + short-circuit encoders). // PLATFORM: SHARED freestanding emit — pure owns LOGAND/LOGOR ELF face only. // Operand emit uses public pipeline_asm_emit_expr_elf_c (→ host-cc _rec); do not Cap residual // the static _rec symbol (G.7 public face only). export extern "C" function pipeline_expr_binop_left_ref_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_binop_right_ref_at(arena: *u8, expr_ref: i32): i32; // wave136 Cap residual: fold_primitives pure leave (AST pattern detectors). // Pool faces + residual static→extern helpers (vector_simd / as). // PLATFORM: SHARED — pure owns 13 fold detection faces; residual owns pool + as/param helpers. export extern "C" function pipeline_block_let_name_len(arena: *u8, block_ref: i32, let_idx: i32): i32; export extern "C" function pipeline_block_let_name_copy64(arena: *u8, block_ref: i32, let_idx: i32, dst: *u8): void; export extern "C" function pipeline_block_let_init_ref(arena: *u8, block_ref: i32, let_idx: i32): i32; export extern "C" function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_field_access_name_len(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_field_access_name_into(arena: *u8, expr_ref: i32, out: *u8): void; export extern "C" function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_index_index_ref(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_as_operand_ref_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_call_num_args_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_call_arg_ref(arena: *u8, expr_ref: i32, idx: i32): i32; // wave148 pure leave: glue_expr_is_func_param_at_c + glue_fold_func_return_operand_ref_c live in this file. // wave138: glue_expr_is_x_as_cast_at_c is pure export (#[no_mangle]) — was Cap residual for // fold_primitives leave when as.c still host-cc; do not re-declare export extern "C" or // pure call sites mangle to _glue_expr_is_x_as_cast_at_c_u8_ptr_i32_reti32 (G.7 single face). // wave137 Cap residual: cmp pure leave callees (operand placement + encoders + CTFE accessors). // PLATFORM: SHARED freestanding emit — pure owns CMP ELF + typekind tag + cc maps. export extern "C" function pipeline_expr_const_folded_valid_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_const_folded_val_at(arena: *u8, expr_ref: i32): i32; // wave151 pure-owned leave: pipeline_expr_enum_namespace_field_tag lives in EOF wave151 section. // wave196 pure-owned: pipeline_asm_call_return_type_kind_ord_c body at EOF (#[no_mangle]). // G.7 ban dual export extern + pure export for the same symbol. // wave149 pure-owned faces: bodies in EOF section (#[no_mangle] export; no dual export extern). // wave188 pure-owned leave: glue_var_expr_stack_off_elf_c lives in EOF wave188 section // (#[no_mangle] export; dual-export ban — do not re-declare export extern "C"). /* wave210 pure-owned: glue_binop_var_slot_cache_invalidate_rbx at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ export extern "C" function backend_enc_ucomisd_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_ucomiss_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_fp_cmp_setcc_movzbl_arch(elf_ctx: *u8, cc: i32, ta: i32): i32; // wave138 Cap residual: as pure leave callees (pool float bits + IEEE pack + // cast encoders + try cleanup + as target type + array lit elem type). // PLATFORM: SHARED freestanding emit — pure owns as/await/try/float-lit faces. export extern "C" function pipeline_expr_float_bits_lo_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_float_bits_hi_at(arena: *u8, expr_ref: i32): i32; export extern "C" function glue_ieee_f64_bits_to_f32_bits(lo: i32, hi: i32): i32; export extern "C" function glue_ieee_f32_bits_to_f64_lo(fb: i32): i32; export extern "C" function glue_ieee_f32_bits_to_f64_hi(fb: i32): i32; // wave152 Cap residual: int→IEEE pack for pure expr_elf_fast CTFE / EXPR_LIT float stamp (G.7 next to ieee_*). export extern "C" function glue_i32_to_f32_bits(v: i32): i32; export extern "C" function glue_i64_to_f32_bits(v: i64): i32; export extern "C" function glue_i64_to_f64_bits(v: i64, lo: *i32, hi: *i32): void; export extern "C" function pipeline_expr_as_target_type_ref_at(arena: *u8, expr_ref: i32): i32; // wave143 pure leave: pipeline_asm_array_lit_elem_type_ref live in this file. /* wave169: pure owns glue_index_scratch_spills_cleanup_all_elf_c (#[no_mangle] below). */ /* wave207 pure-owned: glue_index_scratch_stack_depth_get/set at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave171: pure owns glue_enc_pop_index_scratch_stack_arm64_elf_c (#[no_mangle] below). */ /* wave209 pure-owned: glue_index_scratch_caches_hit_var at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave208 pure-owned: glue_binop_stack_spill_append_at_depth / cap_get at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave209 pure-owned: minus_pair/subadd3 CAP cache BSS thin faces at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave172: pure owns minus_pair/subadd3 cache spill helpers (#[no_mangle] below). */ export extern "C" function arch_x86_64_enc_enc_test_edx_edx(elf_ctx: *u8): i32; export extern "C" function backend_enc_cvttss2si_eax_from_f32_bits_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cvttsd2si_eax_from_f64_bits_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cvttss2si_rax_from_f32_bits_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cvttsd2si_rax_from_f64_bits_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cvtsi2ss_eax_from_i32_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cvtsi2ss_eax_from_i64_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cvtsi2ss_eax_from_u64_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cvtsd2ss_eax_from_f64_bits_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cvtsi2sd_rax_from_u64_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cvtsi2sd_rax_from_i64_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cvtsi2sd_rax_from_i32_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cvtss2sd_rax_from_f32_bits_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cmp_setcc_movzbl_arch(elf_ctx: *u8, cc: i32, ta: i32): i32; export extern "C" function backend_enc_load_rbp_to_rbx_arch(elf_ctx: *u8, offset: i32, ta: i32): i32; export extern "C" function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32; export extern "C" function backend_enc_mov_imm32_to_rbx_arch(elf_ctx: *u8, imm: i32, ta: i32): i32; export extern "C" function backend_enc_pop_rbx_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_test_eax_eax_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_jz_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32; export extern "C" function backend_enc_jnz_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32; export extern "C" function backend_enc_jmp_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32; // wave153 Cap residual: block_body pure leave callees (host-cc residual live/spill/CAP). // PLATFORM: SHARED freestanding emit — pure owns body_sync + defer + final_expr + if_arm. // wave212 pure owns color/pin BSS; wave213 pure owns live control scalars + // interf graph BSS + linear_ctx bind + pressure thresh (#[no_mangle] EOF). // wave214 pure owns live set arrays + opaque u8 overlay thins (#[no_mangle] EOF). /* wave212 pure-owned: glue_asm73_cfg_coloring_active_get/set at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave213 pure-owned: glue_block_live_cfg_parent_* / active_* / emit_stmt_i_* * at EOF (#[no_mangle]). G.7 ban dual export. */ /* wave214 pure-owned: glue_block_live_fwd_as_u8 + live set BSS thins at EOF. * G.7 ban dual export extern + pure export for the same symbol. */ /* wave212 pure-owned: glue_asm73_pin_spill_off_clear_all at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave214 pure-owned: glue_asm73_cfg_peak_live_n_get / peak_* / live_fwd_* at EOF. */ // wave176 pure-owned: glue_block_compute_live_end_linear_to_sub_exit_snap (#[no_mangle] below). /* wave214 pure-owned: glue_live_fwd_n_get/off_at/clear_u8/add_u8 at EOF. */ // wave154 pure-owned: pipeline_expr_struct_lit_num_fields body in EOF section. export extern "C" function pipeline_expr_struct_lit_init_ref(arena: *u8, expr_ref: i32, j: i32): i32; /* wave167: pure owns glue_block_compute_cfg_peak_live_and_color + note_cfg_live_peak (#[no_mangle] below). */ // wave176 pure-owned: glue_block_compute_linear_live_in (#[no_mangle] below). /* wave213 pure-owned: glue_asm73_cfg_interf_prepare at EOF (#[no_mangle]). * wave214 pure-owned: glue_asm73_cfg_peak_clear (peak_live BSS pure). */ /* wave168: pure owns glue_block_simulate_cfg_live + from_empty (#[no_mangle] below). */ /* wave213 pure-owned: glue_asm73_linear_ctx_bind + linear_* getters at EOF. */ /* wave214 pure-owned: glue_asm73_cfg_peak_stmt_i_get / peak_live_as_u8 / * peak_snapshot_from_u8 / glue_live_fwd_copy_u8 at EOF. */ /* wave213 pure-owned: glue_asm73_interf_add_live_set_u8 / linear_max_* at EOF. */ // wave176 pure-owned: glue_block_stmt_gen_kill_u8 + glue_live_fwd_apply_stmt_gen_kill_u8 (#[no_mangle] below). /* wave213 pure-owned: glue_asm73_interf_push / pop_merge at EOF (#[no_mangle]). */ /* wave212 pure-owned: glue_asm73_cfg_final_expr_use_n_set at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave165: pure owns glue_asm73_compute_spill_color_pins (#[no_mangle] below). */ /* wave212 pure-owned: glue_asm73_clear_spill_color_map at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave173: pure owns glue_block_live_fwd_before_stmt + apply_top_stmt (#[no_mangle] below). */ // wave176 pure-owned: glue_live_fwd_forward_after_def (#[no_mangle] below). /* wave163: pure owns glue_binop_cache_intersect_live_fwd (#[no_mangle] below). */ /* wave214 pure-owned: glue_block_live_fwd_contains_off at EOF. */ /* wave213 pure-owned: interf_n_get / off_at / has_edge / clear / add_live_at_stmt * + linear_nso_get at EOF (#[no_mangle]). G.7 ban dual export. */ // wave176 pure-owned: glue_asm73_linear_next_use_dist (#[no_mangle] below). /* wave212 pure-owned: glue_asm73_set_spill_color / off_spill_color_which / * pin_spill_off_set at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave164: pure owns glue_asm73_compute_spill_color_chaitin (#[no_mangle] below). */ /* wave214 pure-owned: live_at_stmt[] BSS + n_get / as_u8 at EOF. */ /* wave213 pure-owned: glue_asm73_pressure_live_thresh_get at EOF (#[no_mangle]). */ /* wave208 pure-owned: glue_binop_stack_spill_find_depth at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave174: pure owns glue_asm73_evict_rax|rbx_cache_entry (#[no_mangle] below). */ /* wave166: pure owns pressure eviction faces (#[no_mangle] below). */ /* wave175: pure owns mov_reg_to_spill / try_colored / farthest / pick_evict (#[no_mangle] below). */ /* wave212 pure-owned: glue_asm73_stack_spill_enabled / off_is_spill_pin at EOF * (#[no_mangle]). wave213: stack_spill_enabled reads pure cfg_parent + max_live. */ /* wave210 pure-owned: glue_binop_var_slot_cache_set_spill_slot at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave214 pure-owned: remove/contains_u8 / live_at_stmt_copy / sub_exit / * fwd remove/add_off at EOF. */ /* wave213 pure-owned: linear_arena/ctx/block_ref/slot_base/nconst/nlet getters * + linear_max_live_n_set at EOF (#[no_mangle]). G.7 ban dual export. */ /* wave210 pure-owned: glue_binop_var_slot_cache x10–x15 valid/off getters + * set_valid_x* at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave208 pure-owned: glue_binop_stack_spill_n_get / off_at / drop_off / clear at EOF * (#[no_mangle]). G.7 ban dual export extern + pure export for the same symbol. */ // wave159 pure-owned: glue_block_stmt_order_has_cfg body in EOF section (was Cap residual spill). // wave156 pure-owned: glue_expr_kind_is_assign_like_ord + try_block_let_index_init + kill_assign_lhs in EOF. /* wave209 pure-owned: glue_index_subadd3_sum_cache_clear / minus_pair_cache_clear at EOF. * G.7 ban dual export extern + pure export for the same symbol. */ // wave207 pure-owned: glue_binop_rax_frame_spill_n_set + glue_index_scratch_stack_depth_set at EOF. // G.7 ban dual export extern + pure export for the same symbol. // wave208 pure-owned: glue_binop_stack_spill_clear at EOF (#[no_mangle]). // wave220 pure-owned: glue_if_expr_arm_emit_depth_get/set + pure BSS at EOF // (#[no_mangle]). G.7 ban dual export extern + pure export for the same symbol. /* wave261 pure-owned: glue_block_body_bind_module_dep_from_ctx body at EOF * (#[no_mangle]). G.7 ban dual export extern + pure export for the same symbol. */ export extern "C" function backend_block_slot_base_for(ctx: *u8, arena: *u8, block_ref: i32): i32; // wave155 pure-owned leave: backend_emit_while_loop_elf_sync(arena: *u8, elf_ctx: *u8, block_ref: i32, loop_idx: i32, ctx: *u8, ta: i32): i32; body in EOF section. // wave155 pure-owned leave: backend_emit_for_loop_elf_sync body in EOF section. export extern "C" function pipeline_block_region_with_arena_cap_ref(arena: *u8, block_ref: i32, ri: i32): i32; export extern "C" function pipeline_block_labeled_is_goto(arena: *u8, block_ref: i32, li: i32): i32; export extern "C" function pipeline_block_labeled_label_len(arena: *u8, block_ref: i32, li: i32): i32; export extern "C" function pipeline_block_labeled_label_copy32(arena: *u8, block_ref: i32, li: i32, dst: *u8): void; export extern "C" function pipeline_block_labeled_goto_target_len(arena: *u8, block_ref: i32, li: i32): i32; export extern "C" function pipeline_block_labeled_goto_target_copy32(arena: *u8, block_ref: i32, li: i32, dst: *u8): void; // wave129 Cap residual: block_if pure leave callees (host-cc residual live/scope/body faces). // PLATFORM: SHARED freestanding emit — pure owns block-level if ELF + if_then_block_body face. // Cond operand uses public pipeline_asm_emit_expr_elf_c (→ host-cc _rec). Live buffers are // opaque u8[136] overlays of GlueBlockLiveFwd (offs[32]+n; Cap residual casts). export extern "C" function ast_pipeline_block_if_cond_ref(arena: *u8, block_ref: i32, if_idx: i32): i32; export extern "C" function ast_pipeline_block_if_then_body_ref(arena: *u8, block_ref: i32, if_idx: i32): i32; export extern "C" function ast_pipeline_block_if_else_body_ref(arena: *u8, block_ref: i32, if_idx: i32): i32; /* wave261 pure-owned: glue_asm_ctx_set_scope_block body at EOF (#[no_mangle]). * G.7 ban dual export extern + pure export for the same symbol. */ /* wave282: per-ctx scope_block_ref seed ALWAYS (bootstrap leave). */ export extern "C" function asm_ctx_set_scope_block(ctx: *u8, block_ref: i32): void; // wave133: glue_enc_jz_after_bool_in_eax is pure export below (unary leave). // Was Cap residual when host leaf owned the face; block_if / async_cps call pure. export extern "C" function backend_ensure_block_local_slots(ctx: *u8, arena: *u8, block_ref: i32): void; // wave145 pure leave: pipeline_asm_fill_block_locals_tree live in this file. // wave153 pure-owned: pipeline_asm_emit_block_body_sync_elf body in EOF section. /* wave214 pure-owned: glue_block_fill_live_end_for_merge at EOF. */ // wave153 pure-owned: glue_block_stmt_order_has_return body in EOF section. /* wave214 pure-owned: glue_live_fwd_copy_from_snap_before_if at EOF. */ // wave158 pure-owned: glue_asm_cache_invalidate_at_cfg_merge_selective + // glue_asm_if_phi_invalidate_both_branch_defs + glue_cfg_collect/add/contains // live in EOF section (was Cap residual spill). // wave159 pure-owned: glue_asm_loop_phi_invalidate_carried_defs body in EOF. // wave160 pure-owned: glue_asm_if_merge_live_union_from_ends + // glue_asm_loop_merge_live_union body in EOF (was Cap residual spill). // wave161 pure-owned: glue_live_fwd_apply_expr_effect body in EOF (was Cap residual). // wave162 pure-owned: pipeline_asm_emit_break_elf_c / continue_elf_c body in EOF. // wave155 Cap residual (spill un-static): break push/pop (step effect → pure wave161). /* wave214 pure-owned: glue_loop_break_exit_push/pop at EOF. */ // wave176 pure-owned: glue_live_fwd_collect_expr_uses (#[no_mangle] below). // wave160 Cap residual thin accessors for pure live-merge leave (BSS still spill). /* wave214 pure-owned: glue_block_live_fwd_copy_from_u8 at EOF. */ // wave161 Cap residual: union opaque gen into global block_live_fwd. /* wave214 pure-owned: glue_block_live_fwd_union_from_u8 at EOF. */ /* wave214 pure-owned: loop break/continue depth + union_into_u8 at EOF. */ // wave162 Cap residual thin: note live at break/continue into stack BSS. /* wave214 pure-owned: loop break/continue note_current at EOF. */ // wave141: pipeline_asm_fill_local_slots pure export below (emit-context leave). // wave153 pure-owned: backend_emit_block_body_sync_elf body in EOF section. // wave131 Cap residual: async_cps pure leave callees (encoders + async_asm_pool + local offset). // PLATFORM: SHARED freestanding emit — pure owns CPS bag + entry/end/await/phase_reset faces. // async_asm_pool_build_layout already pure (async_asm_pool.x); Cap as link face. // push/pop/load32/mov_rbx/cmp/jeq are backend_enc_dispatch pure; Cap residual for this TU. export extern "C" function async_asm_pool_build_layout(arena: *u8, mod: *u8, func_index: i32, out: *u8): i32; export extern "C" function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32; // wave202 Cap residual: arm64 MEMORY-by-value SP store (backend_enc_dispatch pure). export extern "C" function backend_enc_store_x0_sp_offset_arch(elf_ctx: *u8, off_bytes: i32, ta: i32): i32; export extern "C" function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_load_32_from_rax_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_cmp_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_jeq_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32; // wave132 Cap residual: struct_let pure leave callees (struct lit fields + CALL sizing/store + // try_inline + expected-ret + module_from_ctx). lea/mov_arg already Cap residual above; // glue_arm64_mov_x0_to_x8_elf_c is pure export (lea_common leave); emit_expr uses public // pipeline_asm_emit_expr_elf_c (not static _rec). PLATFORM: SHARED freestanding emit. // wave154 pure-owned: pipeline_asm_emit_struct_lit_fields_elf_c body in EOF section. export extern "C" function try_inline_struct_lit_return_call_to_slot_elf(arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32): i32; export extern "C" function try_inline_const_struct_lit_return_call_to_slot_elf(arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32): i32; // wave206 pure-owned: pipeline_asm_set/call_expected_ret_ty_c + pure BSS at EOF. // G.7 ban dual export extern + pure export for the same symbol. // wave194 pure-owned: glue_call_return_byte_size_c body at EOF (#[no_mangle]). // wave195 pure-owned: pipeline_asm_call_arg_value_byte_size_c body at EOF (#[no_mangle]). // wave196 pure-owned: pipeline_asm_call_return_type_kind_ord_c body at EOF (#[no_mangle]). // wave197 pure-owned: pipeline_asm_call_struct16_ret_needs_rax_deref_c + // pipeline_asm_deref_struct16_rax_ptr_elf_c bodies at EOF (#[no_mangle]). // wave198 pure-owned: pipeline_asm_call_param_type_ref_at_c body at EOF (#[no_mangle]). // wave199 pure-owned: glue_asm_resolve_call_target_module_c body at EOF (#[no_mangle]). // G.7 ban dual export extern + pure export for the same symbol. // Resolve callees (Cap residual / pool): typeck resolve + find_func + call resolved_* . export extern "C" function pipeline_expr_call_resolved_func_index_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_call_resolved_dep_index_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_typeck_resolve_call_func_index_for_emit_c(m: *u8, a: *u8, call_expr_ref: i32): i32; export extern "C" function pipeline_typeck_find_func_return_type_in_module_by_name_c( mod: *u8, caller_arena: *u8, name: *u8, name_len: i32, from_dep_index: i32, ctx: *u8, func_index_out: *i32): i32; export extern "C" function pipeline_typeck_find_func_return_type_in_module_c( mod: *u8, mod_arena: *u8, caller_arena: *u8, callee_arena: *u8, callee_expr_ref: i32, from_dep_index: i32, ctx: *u8, func_index_out: *i32): i32; export extern "C" function pipeline_typeck_get_dep_return_type_in_caller_arena_c(from_dep_index: i32, dep_return_type_ref: i32, caller_arena: *u8, ctx: *u8): i32; // wave198: slow-path dep type_ref → caller-arena map (Cap residual method_call). // PLATFORM: SHARED — param formal type_ref must never cross arenas raw. export extern "C" function pipeline_typeck_dep_return_type_to_caller_arena_c(dep_arena: *u8, dep_return_type_ref: i32, caller_arena: *u8): i32; // wave154 pure-owned: glue_type_size_simple body in EOF section. // wave191 pure-owned: glue_type_named_layout_size_any_module_elf_c lives at EOF (#[no_mangle]). // G.7 ban dual export extern + pure export for the same symbol. // wave204 pure-owned: glue_store_retval_pair_to_rbp_elf_c + private // glue_copy_large_struct_from_rax_ptr_elf_c bodies at EOF (#[no_mangle] public). // wave205 pure-owned: glue_slice_let_reent_deep_copy_after_dual_gp_elf_c at EOF // (#[no_mangle] public). G.7 ban dual export extern + pure export. // wave189 pure-owned: glue_emit_module_from_ctx live at EOF (#[no_mangle]). // G.7 ban dual export extern + pure export for the same symbol. // wave133 Cap residual: unary pure leave callees (operand emit + float classifiers + // int64 lit + arch encoders). glue_var_decl_type_ref_elf_c is pure (var_decl leave). // PLATFORM: SHARED freestanding emit — pure owns NEG/LOGNOT/BITNOT + sxt + jz faces. // wave149 pure-owned faces: bodies in EOF section (#[no_mangle] export; no dual export extern). export extern "C" function pipeline_expr_int64_val_at(arena: *u8, expr_ref: i32): i64; export extern "C" function backend_enc_neg_eax_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_not_eax_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_setz_movzbl_eax_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function arch_arm64_enc_enc_u32_le(elf_ctx: *u8, val: i32): i32; // wave134 Cap residual: match pure leave callees (MATCH/EXPR_IF arm faces + if_arm + // struct layout for subject field-bind). Enc jmp/jne/label/mov/cmp + next_label + // emit_expr_elf_c + module/func_index getters already Cap residual above. // PLATFORM: SHARED freestanding emit — pure owns match_elf + expr_if_elf + subject BSS. export extern "C" function pipeline_expr_match_matched_ref_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_match_num_arms_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_match_arm_is_wildcard(arena: *u8, expr_ref: i32, i: i32): i32; export extern "C" function pipeline_expr_match_arm_guard_ref(arena: *u8, expr_ref: i32, i: i32): i32; export extern "C" function pipeline_expr_match_arm_result_ref(arena: *u8, expr_ref: i32, i: i32): i32; export extern "C" function pipeline_expr_match_arm_is_enum_variant(arena: *u8, expr_ref: i32, i: i32): i32; export extern "C" function pipeline_expr_match_arm_variant_index(arena: *u8, expr_ref: i32, i: i32): i32; export extern "C" function pipeline_expr_match_arm_lit_val(arena: *u8, expr_ref: i32, i: i32): i32; export extern "C" function pipeline_expr_if_cond_ref_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_if_then_ref_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_if_else_ref_at(arena: *u8, expr_ref: i32): i32; // wave153 pure-owned: pipeline_asm_emit_expr_if_arm_elf_c body in EOF section. // wave154 Cap residual: struct_lit pure leave callees (size glue + diagnostics + dual-GP). // wave266: pipeline_module_struct_layout_* / num_struct_layouts_at pure (struct_layout leave; dual-export ban). export extern "C" function typeck_x_type_size_from_layout_glue(module: *u8, arena: *u8, li: i32, depth: i32): i32; export extern "C" function typeck_soa_array_storage_size_glue(module: *u8, arena: *u8, elem_type_ref: i32, array_len: i32, depth: i32): i32; export extern "C" function pipeline_typeck_type_refs_equal_c(arena: *u8, a: i32, b: i32): i32; export extern "C" function backend_enc_load_qword_rbx8_to_rdx_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function driver_diagnostic_typeck_struct_padding_before(sname: *u8, sname_len: i32, gap: i32, fname: *u8, fname_len: i32): void; export extern "C" function driver_diagnostic_typeck_struct_padding_trailing(sname: *u8, sname_len: i32, gap: i32): void; export extern "C" function driver_diagnostic_typeck_struct_field_bad_size(sname: *u8, sname_len: i32, fname: *u8, fname_len: i32): void; export extern "C" function driver_diagnostic_warn_pad_fields_same_cache_line(sname: *u8, sname_len: i32, f0: *u8, f0_len: i32, f1: *u8, f1_len: i32): void; export extern "C" function driver_diagnostic_hint_unused_binding(line: i32, col: i32, name: *u8, name_len: i32): void; export extern "C" function driver_diagnostic_warn_hot_reorder_field(sname: *u8, sname_len: i32, hot: *u8, hot_len: i32, cold: *u8, cold_len: i32): void; /* wave235 G.7: env via public pure thin link_abi_getenv (wave222 -> _impl host getenv); * not raw libc getenv. Cap residual host getenv stays only link_abi_getenv_impl. * Used by pipeline_asm_debug_enabled + pipeline_debug_trace_named_func_bodies_impl. * PLATFORM: SHARED - product hybrid pipeline_abi pure uses same face as cold seed. */ export extern "C" function link_abi_getenv(name: *u8): *u8; export extern function link_abi_host_is_windows(): i32; /* wave1222: extern declarations for parser_parse_into_init body. * These mirror the C authority in parser_gen.c L6318-6331 to ensure the * .x strong symbol performs identical AST arena/module state reset. * Without this, the empty .x body overrode the C init, causing AST arena * state leakage between file checks in directory mode (T001 cascades). * PLATFORM: SHARED - all externs are platform-agnostic arena/module reset. */ // wave276: ast_ast_arena_init pure-owned at EOF (dual-export ban; no Cap residual) export extern "C" function ast_pool_module_reset(module: *u8): void; export extern "C" function ast_pool_arena_reset(arena: *u8): void; export extern "C" function parser_onefunc_result_layout_prime(): void; export extern "C" function parser_onefunc_result_layout_prime_b(): void; export extern "C" function parser_onefunc_result_layout_prime_c(): void; export extern "C" function parser_onefunc_result_layout_prime_d(): void; export extern "C" function parser_onefunc_result_layout_prime_d_b(): void; export extern "C" function parser_onefunc_result_layout_prime_e(): void; export extern "C" function parser_onefunc_result_layout_prime_f(): void; export extern "C" function parser_pipeline_module_reset_parse_counters(module: *u8): void; export extern "C" function pipeline_parser_set_match_module(module: *u8): void; /* wave1222: trait registry + generic bound source stash (mirrors C impl_c). * Without these, directory-mode check leaks trait/generic state across files, * causing the parser to misbehave (e.g. num_funcs drops from 356 to 104 for * runtime_pipeline_abi.x when checked after other files). * PLATFORM: SHARED - pure delegation to platform-agnostic externs. */ export extern "C" function xlang_trait_reg_reset_c(arena: *u8): void; export extern "C" function xlang_generic_bound_stash_source_buf_c(data: *u8, len: i32): void; /* wave1223: extern declarations for pipeline_parse_set_main_from_buf_c body. * Live G.7 authority is this .x / runtime_pipeline_abi seed (historical C twin * in deleted ast_pool.c left wave309). Keep parse + main_idx set identical to * the pre-leave contract so directory mode does not skip files. * Without this, an empty .x body (return 0) overrode the prior C impl, causing * pipeline_run_x_pipeline to skip parsing entirely in directory mode * (num_funcs=190 instead of 377 for runtime_driver_abi_thin.x). * PLATFORM: SHARED - all externs are platform-agnostic parse/diag helpers. */ // wave121: pipeline_lint_set_source_buf + pipeline_module_set_main_func_index pure below. // (lint_meta pure-owned leave) export extern "C" function driver_diagnostic_parse_fail(main_idx: i32, num_funcs: i32, arena_num_types: i32): void; // wave276: pipeline_arena_num_types pure-owned at EOF (dual-export ban) /* wave112: pipeline_parse_into_with_init_buf_scalars is pure export below * (parse_typeck_dispatch leave). Cap residual unpack is * pipeline_parse_into_with_init_buf_impl_rc (pipeline_parse_orch.c) over * Cap-struct-return impl_c / strict_parse_into_init. */ /** * G.7: parser_x owns parser_parse_into_init. This TU must not emit a * competing T — FORCE mega previously first-won (g05 pabi is #8, * parser_x.o is #20) with hoist-target modlet seed dumped into the * wrapper (1744B lea COMMON inits, then the 13 calls). Product Ubuntu * already used parser_x (pabi W); Darwin pabi T was the duplicate. * PLATFORM: SHARED — link-name contract; parser_x.o provides the body. */ export extern function parser_parse_into_init(module: *u8, arena: *u8): void; /** * G.7: parser_x owns parser_get_module_num_imports. Mega's `return 0` * stub first-wins under FORCE and reports zero imports. * PLATFORM: SHARED — parser_x.o provides the body. */ export extern function parser_get_module_num_imports(module: *u8): i32; /** * G.7: leftover WAVE274 / asm_wpo_thin owns PGO emit-order prepare. * FORCE mega T first-won a smashed body (call-next-insn / emit_n imm 0); * mega_body then called emit_order_at which returned -1 for every slot * so w393_mega_emit_one hit `if (i < 0) return 0` and wrote no text * (CG002 code_len=0). This TU must not emit a competing T. * PLATFORM: SHARED — leftover from_x WAVE274 provides the body. */ export extern function pipeline_asm_wpo_pgo_emit_order_prepare(m: *u8): void; /** * G.7: leftover WAVE274 owns emit-order count (pairs with prepare/at). * FORCE mega T of count happened to load emit_n=2 while at() used imm 0. * PLATFORM: SHARED — leftover from_x WAVE274 provides the body. */ export extern function pipeline_asm_wpo_pgo_emit_order_count(m: *u8): i32; /** * G.7: leftover WAVE274 owns emit-order at (func index or -1). * FORCE mega/thin asm lowered `order_index >= g_aw_pgo_emit_n` to * `mov $0, %eax` (no reloc); leftover gcc keeps RIP load of emit_n. * PLATFORM: SHARED — leftover from_x WAVE274 provides the body. */ export extern function pipeline_asm_wpo_pgo_emit_order_at(m: *u8, order_index: i32): i32; /** * G.7: leftover WAVE153 gcc owns two-pass stmt_order block-body ELF emit. * FORCE mega T first-won a smash (`sub $0x5228`, cltq on i32 block_ref) * over leftover W 0x22c6. parse_orch emit_one#2 then failed in * w499_mega_emit_body_sync (backend_emit_block_body_sync_elf mega T * `sub $0x8a8` / call-next-insn). Mega must not emit a competing T. * PLATFORM: SHARED — leftover from_x WAVE153 provides the body. */ export extern function pipeline_asm_emit_block_body_sync_elf(arena: *u8, elf_ctx: *u8, block_ref: i32, ctx: *u8, ta: i32): i32; /** * G.7: leftover WAVE153 gcc owns backend.x body_sync entry (84B wrapper: * diverged_set + bind_module_dep + inner emit). FORCE mega T smash * (`sub $0x8a8`) first-won leftover W 0x54. * PLATFORM: SHARED — leftover from_x WAVE153 provides the body. */ export extern function backend_emit_block_body_sync_elf(arena: *u8, elf_ctx: *u8, block_ref: i32, ctx: *u8, ta: i32): i32; /** * G.7: leftover WAVE152 gcc owns emit_expr_elf fast path (LIT / const_fold / * VAR / binop). FORCE mega T first-won smash (`sub $0x2e98` / cltq) over * leftover W 0x1200. parse_orch emit_one#2 then failed innermost at * pipeline_asm_emit_expr_elf_fast#63 eax=-1 after leftover body_sync W * was already live. Mega must not emit a competing T. * Same-TU callers (binop load_operand / emit_expr_elf_rec) stay in unsafe. * PLATFORM: SHARED — leftover from_x WAVE152 provides the body. */ export extern function pipeline_asm_emit_expr_elf_fast(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32; /** * G.7: leftover WAVE273 gcc overlay owns F7 data-section length. * FORCE mega T smash (`sub $0x888`) first-won leftover W 0x22 and RIP-loads * mega `g_pipe_elf_data_len`, not leftover `g_pipeline_elf_data_len`. * Same-TU localize of mega T still binds prepare's CALL to mega local t. * Mega must emit U so leftover gcc W is the sole global. * wave744: leftover-gcc sidecar first-wins this weak T and writes both BSS * homes so compact macho_write (inlines leftover C) emits __DATA. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_emit_data_len(ctx_bytes: *u8): i32; /** * G.7: leftover WAVE273 gcc overlay owns F7 append-zeros (grows data_len). * FORCE mega T smash (`sub $0x898` / cltq) first-won leftover W 0xa2. * gdb asm_wpo: mega smash append $rip, leftover gcc poke then sees data_len=0. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_append_data_zeros(ctx_bytes: *u8, n: i32): i32; /** * G.7: leftover WAVE273 gcc overlay owns F7 data poke (0x4c, RIP data_len). * FORCE mega T first-won smash poke; leftover gcc poke requires leftover * gcc append to have grown the same BSS. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_data_poke_u8(ctx_bytes: *u8, off: i32, b: i32): i32; /** * G.7: leftover smash T of bake_scalar_imm_to_data is the working body * (product gdb eax=0; mega smash `sub $0x8c8` eax=-1). No leftover gcc W * of this face. Same-TU localize still binds mega prepare to mega local t. * Mega must emit U so leftover T (weaken→W) is the sole global. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover pabi T provides the body. */ export extern function pipe_modlet_bake_scalar_imm_to_data( elf_ctx: *u8, data_off: i32, imm: i32, csz: i32 ): i32; /** * G.7: leftover WAVE273 gcc overlay owns add_sym (W 0x22d, endbr64). * FORCE mega T smash first-won leftover W. leftover gcc add_common_sym * CALLs this face; mega smash add_sym RIP-loads `g_pipe_elf_*` sidecar * while leftover gcc uses `g_pipeline_elf_*` + leftover ctx layout. * Same-TU localize of mega T still binds mega prepare's CALL to local t. * Mega must emit U so leftover gcc W is the sole global. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_add_sym( ctx_bytes: *u8, name: *u8, name_len: i32, offset: i32 ): i32; /** * G.7: leftover WAVE273 gcc overlay owns add_common_sym (W 0x138, endbr64). * FORCE mega T smash first-won leftover W. Dual BSS: mega * `g_pipe_elf_sym_is_common` ≠ leftover `g_pipeline_elf_sym_is_common`. * leftover gcc add_common_sym calls leftover gcc add_sym (same family). * Do not leftover-first smash-only `modlet_prepare` (layout mismatch). * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_add_common_sym( ctx_bytes: *u8, name: *u8, name_len: i32, sym_size: i32, sym_align: i32 ): i32; /** * G.7: leftover WAVE273 gcc overlay owns add_label (W 0x1f0, endbr64). * FORCE mega T smash first-won leftover W. Dual BSS: mega * `g_pipe_elf_label_shndx` ≠ leftover `g_pipeline_elf_label_shndx`. * leftover gcc add_label uses leftover STATIC current_shndx / * label_shndx_set (not first-win-able). leftover gcc ensure_label * CALLs leftover gcc add_label (same family). Same-TU localize of * mega T still binds mega prepare's CALL to local t. Mega must emit * U so leftover gcc W is the sole global. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_add_label( ctx_bytes: *u8, name: *u8, name_len: i32, offset: i32 ): i32; /** * G.7: leftover WAVE273 gcc overlay owns ensure_label (W 0xd5, endbr64). * FORCE mega T smash first-won leftover W. leftover gcc ensure_label * CALLs leftover gcc add_label; leftover-first both faces together. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_ensure_label( ctx_bytes: *u8, name: *u8, name_len: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_assign_elf_c (W 0x4b79, endbr64). * FORCE mega T smash first-won leftover W. leftover gcc VAR assign CALLs leftover * gcc glue_emit_assign_rhs_to_rax_elf_c (W 0x59b); leftover gcc rhs_to_rax * plain (ako==28) CALLs leftover gcc glue_emit_assign_rhs_elf_c (W 0xd6). * Same-TU localize of mega T still binds mega CALL to local t. Mega must emit * U so leftover gcc W is the sole global. Family leftover-first all three. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_assign_elf_c( arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_emit_assign_rhs_to_rax_elf_c (W 0x59b, endbr64). * leftover gcc emit_assign VAR/fallback CALLs this. Family with emit_assign. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_emit_assign_rhs_to_rax_elf_c( arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_emit_assign_rhs_elf_c (W 0xd6, endbr64). * leftover gcc rhs_to_rax plain (ako==28) CALLs this; leftover gcc then * pipeline_asm_emit_expr_elf_c (already leftover-first emit_fast/rec). * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_emit_assign_rhs_elf_c( arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_expr_elf_for_call_args * (W 0x2c4f, endbr64 sub $0x248). FORCE mega T smash (sub $0x5c38 / cltq) * first-won leftover W. Same-TU localize of mega T still binds mega CALL * to local t. Mega must emit U so leftover gcc W is the sole global. * backend_call_dispatch already export-externs this face; localize * for_call_args_thin so thin W cannot first-win leftover gcc W. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_expr_elf_for_call_args( arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns asm_parser_emit_heavy_safe_helper * (W 0x22d7, endbr64 sub $0x10). FORCE mega T smash (sub $0x87c8) * first-won leftover W. Same-TU caller asm_skip_heavy_module_func_body * is already in unsafe. Do not leftover-first skip_heavy itself * (wave650 FORCE_FULL_BODIES escape). Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_parser_emit_heavy_safe_helper( m: *u8, func_index: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_emit_struct_type_let_init_elf_c * (W 0x20c9, endbr64 sub $0x3b8). FORCE mega T smash first-won leftover W. * leftover gcc STRUCT_LIT path CALLs leftover gcc * pipeline_asm_emit_struct_let_init_elf_c (W 0xa0) which CALLs leftover gcc * pipeline_asm_emit_struct_lit_fields_elf_c (W 0x169e). leftover gcc * emit_expr STRUCT_LIT CALLs leftover gcc pipeline_asm_emit_struct_lit_elf_c * (W 0x44). Family leftover-first all four so leftover gcc parent CALLs * leftover gcc children. Same-TU callers already in unsafe. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_emit_struct_type_let_init_elf_c( arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, let_ty_ref: i32, stack_slot_off: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_struct_let_init_elf_c * (W 0xa0, endbr64 sub $0x40). leftover gcc glue_emit_struct_type_let_init * CALLs this for STRUCT_LIT. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_struct_let_init_elf_c( arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_struct_lit_fields_elf_c * (W 0x169e, endbr64 sub $0xb8). leftover gcc struct_let_init / emit_struct_lit * CALL this. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_struct_lit_fields_elf_c( arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_struct_lit_elf_c * (W 0x44, endbr64 sub $0x20). leftover gcc emit_expr STRUCT_LIT CALLs this * wrapper, which CALLs leftover gcc struct_lit_fields. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_struct_lit_elf_c( arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns asm_parser_m8_tail_thin_delegate_c_name * (W 0x1f1a, endbr64 sub $0x20). FORCE mega T smash first-won leftover W. * leftover gcc skip_heavy_or_thin_stub / resolve_call_to_glue CALL this. * Do not leftover-first asm_skip_heavy_module_func_body (FORCE_FULL_BODIES * dual env). Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_parser_m8_tail_thin_delegate_c_name( m: *u8, func_index: i32, out: *u8, out_cap: i32, out_len: *i32 ): i32; /** * G.7: leftover gcc overlay owns asm_wpo_collect_walk * (W 0x1e56, endbr64 sub $0x210). FORCE mega T smash first-won leftover W. * Mega wrappers collect_edges_from_expr / collect_from_block CALL this. * asm_wpo_thin also has a body — localize so thin W cannot first-win. * Do not leftover-first asm_skip_heavy_module_func_body (FORCE_FULL_BODIES * dual env). Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_wpo_collect_walk( is_block: i32, a: *u8, ref: i32, caller_id: i32, caller_mod: *u8, ctx: *u8, depth: i32 ): void; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_return_elf_impl * (W 0x1a7e, endbr64 sub $0x1e8). FORCE mega T smash first-won leftover W. * Mega wrapper pipeline_asm_emit_return_elf_c and expr_rec CALL this. * arr_return_thin / fixed_array_copy_thin also have a body — localize so * thin W cannot first-win. HARD BAN product PREFER of return_elf_impl_thin * (FORCE user -c of that thin is T001). Do not leftover-first * asm_skip_heavy_module_func_body (FORCE_FULL_BODIES dual env). Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_return_elf_impl( arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: runtime_pipeline_abi_parser_thin_delegate_thin.x owns * asm_parser_func_is_thin_delegate. The egg copy stays weak behind that * overlay (was W 0x12d3). Mega skip_heavy CALLs this (already unsafe). * Do not add a second body here. Mega must emit U. * PLATFORM: SHARED — overlay first-wins; egg table is not the linked body. */ export extern function asm_parser_func_is_thin_delegate(m: *u8, func_index: i32): i32; /** * G.7: leftover gcc overlay owns asm_backend_m8_tail_thin_delegate_c_name * (W 0xa62, endbr64 sub $0x20). FORCE mega T smash first-won leftover W. * Mega skip_heavy_or_thin_stub CALLs this (already unsafe). No thin copy. * Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_backend_m8_tail_thin_delegate_c_name( m: *u8, func_index: i32, out: *u8, out_cap: i32, out_len: *i32 ): i32; /** * G.7: leftover gcc overlay owns asm_pipeline_m8_tail_thin_delegate_c_name * (W 0x130, endbr64 sub $0x20). FORCE mega T smash first-won leftover W. * Mega skip_heavy_or_thin_stub CALLs this (already unsafe). No thin copy. * Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_pipeline_m8_tail_thin_delegate_c_name( m: *u8, func_index: i32, out: *u8, out_cap: i32, out_len: *i32 ): i32; /** * G.7: leftover gcc overlay owns asm_typeck_m8_tail_thin_delegate_c_name * (W 0xed, endbr64 sub $0x30). FORCE mega T smash first-won leftover W. * Mega skip_heavy_or_thin_stub CALLs this (already unsafe). No thin copy. * Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_typeck_m8_tail_thin_delegate_c_name( m: *u8, func_index: i32, out: *u8, out_cap: i32, out_len: *i32 ): i32; /** * G.7: leftover gcc overlay owns asm_driver_m8_tail_thin_delegate_c_name * (W 0x64, endbr64 sub $0x20). FORCE mega T smash first-won leftover W. * Mega skip_heavy_or_thin_stub CALLs this (already unsafe). No thin copy. * Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_driver_m8_tail_thin_delegate_c_name( m: *u8, func_index: i32, out: *u8, out_cap: i32, out_len: *i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_lvalue_eff_addr_elf_c * (W 0x890, endbr64 sub $0x170). FORCE mega T smash first-won leftover W. * leftover gcc emit_assign (w710) CALLs leftover gcc this face for FIELD/INDEX * /DEREF lvalues. Thins export-extern (no body). Mega same-TU callers already * unsafe. Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_lvalue_eff_addr_elf_c( arena: *u8, elf_ctx: *u8, lval_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_enc_local_slot_ptr_or_addr_elf_c * (W 0x82, endbr64 sub $0x40). FORCE mega T smash sub $0x8b8 first-won leftover W. * leftover gcc emit_assign CALLs leftover gcc this face (field_assign HIT smash). * Thins export-extern (no body). Mega same-TU callers already unsafe. * Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_enc_local_slot_ptr_or_addr_elf_c( arena: *u8, elf_ctx: *u8, var_ref: i32, var_off: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_index_elem_byte_sz_c * (W 0x1103). FORCE mega T smash first-won leftover W. leftover gcc INDEX * / lvalue_eff_addr CALLs leftover gcc this face. Thins export-extern * (no body). Mega same-TU callers wrapped unsafe. Do not leftover-first * skip_heavy or skip_heavy_or_thin_stub parent. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_index_elem_byte_sz_c( arena: *u8, expr_ref: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_emit_index_eff_addr_scaled_elf_c * (W 0x73e). FORCE mega T smash first-won leftover W. leftover gcc INDEX * / lvalue_eff_addr / assign CALLs leftover gcc this face (index_i32 gdb * HIT). Thins export-extern (no body). Mega same-TU callers already unsafe. * Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_emit_index_eff_addr_scaled_elf_c( arena: *u8, elf_ctx: *u8, ix_ref: i32, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_try_index_var_or_field_base_to_rax_elf_c * (W 0xe0c). FORCE mega T smash first-won leftover W. leftover gcc INDEX * scaled (w725) CALLs leftover gcc this face (INDEX lit path). Thins * export-extern (no body). Mega same-TU callers wrapped unsafe. Do not * leftover-first skip_heavy, skip_heavy_or_thin_stub parent, rbx twin, * or wrapper pipeline_asm_index_elem_byte_sz. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_try_index_var_or_field_base_to_rax_elf_c( arena: *u8, elf_ctx: *u8, base_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_try_index_rvalue_slice_once_elf_c * (W 0xd2e). FORCE mega T smash first-won leftover W. leftover gcc INDEX * scaled (w725) CALLs leftover gcc this face (CALL/METHOD/INDEX/DEREF * TYPE_SLICE rvalue-once). No thin defines this symbol. Mega same-TU * remaining callers after scaled leftover-first: 0. Do not leftover-first * skip_heavy, skip_heavy_or_thin_stub parent, rbx twin, bounds_guard, * or wrapper pipeline_asm_index_elem_byte_sz. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_try_index_rvalue_slice_once_elf_c( arena: *u8, elf_ctx: *u8, ix_ref: i32, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_emit_index_bounds_guard_elf_c * (W 0x90f). FORCE mega T smash first-won leftover W. leftover gcc INDEX * scaled (w725) CALLs leftover gcc this face (INDEX bounds). No thin * defines this symbol. Mega same-TU remaining callers after scaled * leftover-first: 0. Do not leftover-first skip_heavy, skip_heavy_or_thin_stub * parent, rbx twin, rax_plus_rbx_scaled, or wrapper * pipeline_asm_index_elem_byte_sz. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_emit_index_bounds_guard_elf_c( arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32, ix_ref: i32, base_ref: i32, idx_ref: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_try_index_var_or_field_base_to_rbx_elf_c * (W 0x7dc). FORCE mega T smash first-won leftover W. leftover gcc INDEX * assign-addr→rbx forest CALLs leftover gcc this face (INDEX assign base). * No thin defines this symbol. Mega same-TU remaining callers: 18 (already * unsafe). Do not leftover-first skip_heavy, skip_heavy_or_thin_stub * parent, rax_plus_rbx_scaled, local_slot rbx twin, or wrapper * pipeline_asm_index_elem_byte_sz. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_try_index_var_or_field_base_to_rbx_elf_c( arena: *u8, elf_ctx: *u8, base_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_local_var_slot_needs_ptr_load_elf_c * (W 0x542). FORCE mega T smash first-won leftover W. leftover gcc local_slot * (w723 W 0x82) CALLs leftover gcc this face. Thin param_ptr_slot_thin HAS a * body (W 0x8dc) — must localize or thin W first-wins leftover gcc. Mega * same-TU remaining callers: 4. Do not leftover-first skip_heavy, * skip_heavy_or_thin_stub parent, rax_plus_rbx_scaled, local_slot rbx twin, * or wrapper pipeline_asm_index_elem_byte_sz. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_local_var_slot_needs_ptr_load_elf_c( arena: *u8, var_expr_ref: i32, stack_off: i32, ctx: *u8 ): i32; /** * G.7: leftover gcc overlay owns glue_copy_large_struct_from_rax_ptr_elf_c * (W 0x482). FORCE mega T smash first-won leftover W. leftover gcc * store_retval_pair (W 0x2bb) CALLs leftover gcc this face (>16B CALL * memcpy). Thins assign_thin / assign_deref_* export-extern (no body) * — still localize. Mega same-TU remaining callers: 5. Do not leftover-first * skip_heavy, skip_heavy_or_thin_stub parent, rax_plus_rbx_scaled, * local_slot rbx twin, wrapper pipeline_asm_index_elem_byte_sz, or * store_retval_pair itself. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_copy_large_struct_from_rax_ptr_elf_c( elf_ctx: *u8, slot_off: i32, sz: i32, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_emit_vector_type_let_init_elf_c * (W 0x2c5). FORCE mega T smash first-won leftover W. leftover gcc * let-init / assign SIMD paths CALL leftover gcc this face (non-vector * returns -2). Thins assign_thin / assign_var_try_let / * assign_index_simd_body / assign_field_var_simd / * assign_deref_vec_call / for_call_args export-extern (no body) * — still localize. Mega same-TU remaining callers: 5. Do not leftover-first * skip_heavy, skip_heavy_or_thin_stub parent, rax_plus_rbx_scaled, * local_slot rbx twin, wrapper pipeline_asm_index_elem_byte_sz, * store_retval_pair, or vector children (vector_let_init / var_copy / * binop / simd_try_inline_*). Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_emit_vector_type_let_init_elf_c( arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, type_ref: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_vector_let_init_elf_c * (W 0x73f). FORCE mega T smash first-won leftover W (`sub $0x13a8`). * leftover gcc vector_type_let_init (w732 W 0x2c5) CALLs leftover gcc this * face for ARRAY_LIT. Thin fixed_array_copy / arr_struct_lit_arrlit * export-extern (no body) — still localize. Mega same-TU remaining callers: 1. * Do not leftover-first skip_heavy, skip_heavy_or_thin_stub parent, * rax_plus_rbx_scaled, local_slot rbx twin, wrapper, store_retval_pair, * or other vector children (var_copy / binop / simd_try_inline_*). * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_vector_let_init_elf_c( arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_simd_try_inline_select_call_elf_c * (W 0x691). FORCE mega T smash first-won leftover W (`sub $0x13f8`). * leftover gcc vector_type_let_init (w732 W 0x2c5) CALLs leftover gcc this * face for CALL/METHOD simd.select. Mega same-TU remaining callers: 0 * (parent leftover-first). No thin defines this symbol — still localize. * Do not leftover-first skip_heavy, skip_heavy_or_thin_stub parent, * rax_plus_rbx_scaled, local_slot rbx twin, wrapper, store_retval_pair, * or other vector children (var_copy / binop / splat / shuffle / fma / * identity / binop2). Mega may not emit U (unused export-extern). * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_simd_try_inline_select_call_elf_c( arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, type_ref: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_simd_try_inline_shuffle_call_elf_c * (W 0x4ca). FORCE mega T smash first-won leftover W (`sub $0xd78`). * leftover gcc vector_type_let_init (w732 W 0x2c5) CALLs leftover gcc this * face for CALL/METHOD simd.shuffle. Mega same-TU remaining callers: 0 * (parent leftover-first). No thin defines this symbol — still localize. * Do not leftover-first skip_heavy, skip_heavy_or_thin_stub parent, * rax_plus_rbx_scaled, local_slot rbx twin, wrapper, store_retval_pair, * or other vector children (var_copy / binop / splat / fma / * identity / binop2). Mega may not emit U (unused export-extern). * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_simd_try_inline_shuffle_call_elf_c( arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, type_ref: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_simd_try_inline_fma3_call_elf_c * (W 0x47e). FORCE mega T smash first-won leftover W (`sub $0xcf8`). * leftover gcc vector_type_let_init (w732 W 0x2c5) CALLs leftover gcc this * face for CALL/METHOD simd.fma. Mega same-TU remaining callers: 0 * (parent leftover-first). No thin defines this symbol — still localize. * Do not leftover-first skip_heavy, skip_heavy_or_thin_stub parent, * rax_plus_rbx_scaled, local_slot rbx twin, wrapper, store_retval_pair, * or other vector children (var_copy / binop / splat / identity / binop2). * Mega may not emit U (unused export-extern). * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_simd_try_inline_fma3_call_elf_c( arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, type_ref: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_simd_try_inline_splat_call_elf_c * (W 0x423). FORCE mega T smash first-won leftover W (`sub $0xbb8`). * leftover gcc vector_type_let_init (w732 W 0x2c5) CALLs leftover gcc this * face for CALL/METHOD simd.splat. Mega same-TU remaining callers: 1 * (glue_simd_select_arg_stack_off_c, wrapped unsafe). No thin defines this * symbol — still localize. * Do not leftover-first skip_heavy, skip_heavy_or_thin_stub parent, * rax_plus_rbx_scaled, local_slot rbx twin, wrapper, store_retval_pair, * or other vector children (var_copy / binop / identity / binop2). * Mega may emit U (remaining caller). * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_simd_try_inline_splat_call_elf_c( arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, type_ref: i32 ): i32; /** * G.7: parser_x owns parser_get_module_import_path. * PLATFORM: SHARED — parser_x.o provides the body. */ export extern function parser_get_module_import_path(module: *u8, idx: i32, path_buf: *u8): void; /** * Copy import path at index i into out[0..64) (NUL-terminated) and return path length. * @param module *u8 - opaque AST module; null -> out[0]=0 when out valid, return 0 * @param i i32 - import index (negative / OOB handled by G.7 path_copy / ImportEntry) * @param out *u8 - destination buffer; capacity 64 bytes including NUL; null -> 0 * @return i32 - byte length of path excluding NUL; 0 on null/missing path * wave99 pure Cap residual close: G.7 single product authority for path64 surface. * Body ≡ historical parser_gen: pipeline_module_import_path_copy(..., 64) + scan NUL. * wave110: path_copy storage is pure ImportEntry map (not Cap residual). * PLATFORM: SHARED - parser_gen path64 demoted weak cold twin; product pure hybrid owns. */ #[no_mangle] export function parser_copy_module_import_path64(module: *u8, i: i32, out: *u8): i32;
export extern function pipeline_expr_struct_lit_value_bytes(a: *u8, m: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, ref: i32): i32;
export extern function try_inline_const_struct_lit_return_call_to_slot_elf(arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32): i32; // wave206 pure-owned: pipeline_asm_set/call_expected_ret_ty_c + pure BSS at EOF. // G.7 ban dual export extern + pure export for the same symbol. // wave194 pure-owned: glue_call_return_byte_size_c body at EOF (#[no_mangle]). // wave195 pure-owned: pipeline_asm_call_arg_value_byte_size_c body at EOF (#[no_mangle]). // wave196 pure-owned: pipeline_asm_call_return_type_kind_ord_c body at EOF (#[no_mangle]). // wave197 pure-owned: pipeline_asm_call_struct16_ret_needs_rax_deref_c + // pipeline_asm_deref_struct16_rax_ptr_elf_c bodies at EOF (#[no_mangle]). // wave198 pure-owned: pipeline_asm_call_param_type_ref_at_c body at EOF (#[no_mangle]). // wave199 pure-owned: glue_asm_resolve_call_target_module_c body at EOF (#[no_mangle]). // G.7 ban dual export extern + pure export for the same symbol. // Resolve callees (Cap residual / pool): typeck resolve + find_func + call resolved_* . export extern "C" function pipeline_expr_call_resolved_func_index_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_call_resolved_dep_index_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_typeck_resolve_call_func_index_for_emit_c(m: *u8, a: *u8, call_expr_ref: i32): i32; export extern "C" function pipeline_typeck_find_func_return_type_in_module_by_name_c( mod: *u8, caller_arena: *u8, name: *u8, name_len: i32, from_dep_index: i32, ctx: *u8, func_index_out: *i32): i32; export extern "C" function pipeline_typeck_find_func_return_type_in_module_c( mod: *u8, mod_arena: *u8, caller_arena: *u8, callee_arena: *u8, callee_expr_ref: i32, from_dep_index: i32, ctx: *u8, func_index_out: *i32): i32; export extern "C" function pipeline_typeck_get_dep_return_type_in_caller_arena_c(from_dep_index: i32, dep_return_type_ref: i32, caller_arena: *u8, ctx: *u8): i32; // wave198: slow-path dep type_ref → caller-arena map (Cap residual method_call). // PLATFORM: SHARED — param formal type_ref must never cross arenas raw. export extern "C" function pipeline_typeck_dep_return_type_to_caller_arena_c(dep_arena: *u8, dep_return_type_ref: i32, caller_arena: *u8): i32; // wave154 pure-owned: glue_type_size_simple body in EOF section. // wave191 pure-owned: glue_type_named_layout_size_any_module_elf_c lives at EOF (#[no_mangle]). // G.7 ban dual export extern + pure export for the same symbol. // wave204 pure-owned: glue_store_retval_pair_to_rbp_elf_c + private // glue_copy_large_struct_from_rax_ptr_elf_c bodies at EOF (#[no_mangle] public). // wave205 pure-owned: glue_slice_let_reent_deep_copy_after_dual_gp_elf_c at EOF // (#[no_mangle] public). G.7 ban dual export extern + pure export. // wave189 pure-owned: glue_emit_module_from_ctx live at EOF (#[no_mangle]). // G.7 ban dual export extern + pure export for the same symbol. // wave133 Cap residual: unary pure leave callees (operand emit + float classifiers + // int64 lit + arch encoders). glue_var_decl_type_ref_elf_c is pure (var_decl leave). // PLATFORM: SHARED freestanding emit — pure owns NEG/LOGNOT/BITNOT + sxt + jz faces. // wave149 pure-owned faces: bodies in EOF section (#[no_mangle] export; no dual export extern). export extern "C" function pipeline_expr_int64_val_at(arena: *u8, expr_ref: i32): i64; export extern "C" function backend_enc_neg_eax_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_not_eax_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_setz_movzbl_eax_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function arch_arm64_enc_enc_u32_le(elf_ctx: *u8, val: i32): i32; // wave134 Cap residual: match pure leave callees (MATCH/EXPR_IF arm faces + if_arm + // struct layout for subject field-bind). Enc jmp/jne/label/mov/cmp + next_label + // emit_expr_elf_c + module/func_index getters already Cap residual above. // PLATFORM: SHARED freestanding emit — pure owns match_elf + expr_if_elf + subject BSS. export extern "C" function pipeline_expr_match_matched_ref_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_match_num_arms_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_match_arm_is_wildcard(arena: *u8, expr_ref: i32, i: i32): i32; export extern "C" function pipeline_expr_match_arm_guard_ref(arena: *u8, expr_ref: i32, i: i32): i32; export extern "C" function pipeline_expr_match_arm_result_ref(arena: *u8, expr_ref: i32, i: i32): i32; export extern "C" function pipeline_expr_match_arm_is_enum_variant(arena: *u8, expr_ref: i32, i: i32): i32; export extern "C" function pipeline_expr_match_arm_variant_index(arena: *u8, expr_ref: i32, i: i32): i32; export extern "C" function pipeline_expr_match_arm_lit_val(arena: *u8, expr_ref: i32, i: i32): i32; export extern "C" function pipeline_expr_if_cond_ref_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_if_then_ref_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_if_else_ref_at(arena: *u8, expr_ref: i32): i32; // wave153 pure-owned: pipeline_asm_emit_expr_if_arm_elf_c body in EOF section. // wave154 Cap residual: struct_lit pure leave callees (size glue + diagnostics + dual-GP). // wave266: pipeline_module_struct_layout_* / num_struct_layouts_at pure (struct_layout leave; dual-export ban). export extern "C" function typeck_x_type_size_from_layout_glue(module: *u8, arena: *u8, li: i32, depth: i32): i32; export extern "C" function typeck_soa_array_storage_size_glue(module: *u8, arena: *u8, elem_type_ref: i32, array_len: i32, depth: i32): i32; export extern "C" function pipeline_typeck_type_refs_equal_c(arena: *u8, a: i32, b: i32): i32; export extern "C" function backend_enc_load_qword_rbx8_to_rdx_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function driver_diagnostic_typeck_struct_padding_before(sname: *u8, sname_len: i32, gap: i32, fname: *u8, fname_len: i32): void; export extern "C" function driver_diagnostic_typeck_struct_padding_trailing(sname: *u8, sname_len: i32, gap: i32): void; export extern "C" function driver_diagnostic_typeck_struct_field_bad_size(sname: *u8, sname_len: i32, fname: *u8, fname_len: i32): void; export extern "C" function driver_diagnostic_warn_pad_fields_same_cache_line(sname: *u8, sname_len: i32, f0: *u8, f0_len: i32, f1: *u8, f1_len: i32): void; export extern "C" function driver_diagnostic_hint_unused_binding(line: i32, col: i32, name: *u8, name_len: i32): void; export extern "C" function driver_diagnostic_warn_hot_reorder_field(sname: *u8, sname_len: i32, hot: *u8, hot_len: i32, cold: *u8, cold_len: i32): void; /* wave235 G.7: env via public pure thin link_abi_getenv (wave222 -> _impl host getenv); * not raw libc getenv. Cap residual host getenv stays only link_abi_getenv_impl. * Used by pipeline_asm_debug_enabled + pipeline_debug_trace_named_func_bodies_impl. * PLATFORM: SHARED - product hybrid pipeline_abi pure uses same face as cold seed. */ export extern "C" function link_abi_getenv(name: *u8): *u8; export extern function link_abi_host_is_windows(): i32; /* wave1222: extern declarations for parser_parse_into_init body. * These mirror the C authority in parser_gen.c L6318-6331 to ensure the * .x strong symbol performs identical AST arena/module state reset. * Without this, the empty .x body overrode the C init, causing AST arena * state leakage between file checks in directory mode (T001 cascades). * PLATFORM: SHARED - all externs are platform-agnostic arena/module reset. */ // wave276: ast_ast_arena_init pure-owned at EOF (dual-export ban; no Cap residual) export extern "C" function ast_pool_module_reset(module: *u8): void; export extern "C" function ast_pool_arena_reset(arena: *u8): void; export extern "C" function parser_onefunc_result_layout_prime(): void; export extern "C" function parser_onefunc_result_layout_prime_b(): void; export extern "C" function parser_onefunc_result_layout_prime_c(): void; export extern "C" function parser_onefunc_result_layout_prime_d(): void; export extern "C" function parser_onefunc_result_layout_prime_d_b(): void; export extern "C" function parser_onefunc_result_layout_prime_e(): void; export extern "C" function parser_onefunc_result_layout_prime_f(): void; export extern "C" function parser_pipeline_module_reset_parse_counters(module: *u8): void; export extern "C" function pipeline_parser_set_match_module(module: *u8): void; /* wave1222: trait registry + generic bound source stash (mirrors C impl_c). * Without these, directory-mode check leaks trait/generic state across files, * causing the parser to misbehave (e.g. num_funcs drops from 356 to 104 for * runtime_pipeline_abi.x when checked after other files). * PLATFORM: SHARED - pure delegation to platform-agnostic externs. */ export extern "C" function xlang_trait_reg_reset_c(arena: *u8): void; export extern "C" function xlang_generic_bound_stash_source_buf_c(data: *u8, len: i32): void; /* wave1223: extern declarations for pipeline_parse_set_main_from_buf_c body. * Live G.7 authority is this .x / runtime_pipeline_abi seed (historical C twin * in deleted ast_pool.c left wave309). Keep parse + main_idx set identical to * the pre-leave contract so directory mode does not skip files. * Without this, an empty .x body (return 0) overrode the prior C impl, causing * pipeline_run_x_pipeline to skip parsing entirely in directory mode * (num_funcs=190 instead of 377 for runtime_driver_abi_thin.x). * PLATFORM: SHARED - all externs are platform-agnostic parse/diag helpers. */ // wave121: pipeline_lint_set_source_buf + pipeline_module_set_main_func_index pure below. // (lint_meta pure-owned leave) export extern "C" function driver_diagnostic_parse_fail(main_idx: i32, num_funcs: i32, arena_num_types: i32): void; // wave276: pipeline_arena_num_types pure-owned at EOF (dual-export ban) /* wave112: pipeline_parse_into_with_init_buf_scalars is pure export below * (parse_typeck_dispatch leave). Cap residual unpack is * pipeline_parse_into_with_init_buf_impl_rc (pipeline_parse_orch.c) over * Cap-struct-return impl_c / strict_parse_into_init. */ /** * G.7: parser_x owns parser_parse_into_init. This TU must not emit a * competing T — FORCE mega previously first-won (g05 pabi is #8, * parser_x.o is #20) with hoist-target modlet seed dumped into the * wrapper (1744B lea COMMON inits, then the 13 calls). Product Ubuntu * already used parser_x (pabi W); Darwin pabi T was the duplicate. * PLATFORM: SHARED — link-name contract; parser_x.o provides the body. */ export extern function parser_parse_into_init(module: *u8, arena: *u8): void; /** * G.7: parser_x owns parser_get_module_num_imports. Mega's `return 0` * stub first-wins under FORCE and reports zero imports. * PLATFORM: SHARED — parser_x.o provides the body. */ export extern function parser_get_module_num_imports(module: *u8): i32; /** * G.7: leftover WAVE274 / asm_wpo_thin owns PGO emit-order prepare. * FORCE mega T first-won a smashed body (call-next-insn / emit_n imm 0); * mega_body then called emit_order_at which returned -1 for every slot * so w393_mega_emit_one hit `if (i < 0) return 0` and wrote no text * (CG002 code_len=0). This TU must not emit a competing T. * PLATFORM: SHARED — leftover from_x WAVE274 provides the body. */ export extern function pipeline_asm_wpo_pgo_emit_order_prepare(m: *u8): void; /** * G.7: leftover WAVE274 owns emit-order count (pairs with prepare/at). * FORCE mega T of count happened to load emit_n=2 while at() used imm 0. * PLATFORM: SHARED — leftover from_x WAVE274 provides the body. */ export extern function pipeline_asm_wpo_pgo_emit_order_count(m: *u8): i32; /** * G.7: leftover WAVE274 owns emit-order at (func index or -1). * FORCE mega/thin asm lowered `order_index >= g_aw_pgo_emit_n` to * `mov $0, %eax` (no reloc); leftover gcc keeps RIP load of emit_n. * PLATFORM: SHARED — leftover from_x WAVE274 provides the body. */ export extern function pipeline_asm_wpo_pgo_emit_order_at(m: *u8, order_index: i32): i32; /** * G.7: leftover WAVE153 gcc owns two-pass stmt_order block-body ELF emit. * FORCE mega T first-won a smash (`sub $0x5228`, cltq on i32 block_ref) * over leftover W 0x22c6. parse_orch emit_one#2 then failed in * w499_mega_emit_body_sync (backend_emit_block_body_sync_elf mega T * `sub $0x8a8` / call-next-insn). Mega must not emit a competing T. * PLATFORM: SHARED — leftover from_x WAVE153 provides the body. */ export extern function pipeline_asm_emit_block_body_sync_elf(arena: *u8, elf_ctx: *u8, block_ref: i32, ctx: *u8, ta: i32): i32; /** * G.7: leftover WAVE153 gcc owns backend.x body_sync entry (84B wrapper: * diverged_set + bind_module_dep + inner emit). FORCE mega T smash * (`sub $0x8a8`) first-won leftover W 0x54. * PLATFORM: SHARED — leftover from_x WAVE153 provides the body. */ export extern function backend_emit_block_body_sync_elf(arena: *u8, elf_ctx: *u8, block_ref: i32, ctx: *u8, ta: i32): i32; /** * G.7: leftover WAVE152 gcc owns emit_expr_elf fast path (LIT / const_fold / * VAR / binop). FORCE mega T first-won smash (`sub $0x2e98` / cltq) over * leftover W 0x1200. parse_orch emit_one#2 then failed innermost at * pipeline_asm_emit_expr_elf_fast#63 eax=-1 after leftover body_sync W * was already live. Mega must not emit a competing T. * Same-TU callers (binop load_operand / emit_expr_elf_rec) stay in unsafe. * PLATFORM: SHARED — leftover from_x WAVE152 provides the body. */ export extern function pipeline_asm_emit_expr_elf_fast(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32; /** * G.7: leftover WAVE273 gcc overlay owns F7 data-section length. * FORCE mega T smash (`sub $0x888`) first-won leftover W 0x22 and RIP-loads * mega `g_pipe_elf_data_len`, not leftover `g_pipeline_elf_data_len`. * Same-TU localize of mega T still binds prepare's CALL to mega local t. * Mega must emit U so leftover gcc W is the sole global. * wave744: leftover-gcc sidecar first-wins this weak T and writes both BSS * homes so compact macho_write (inlines leftover C) emits __DATA. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_emit_data_len(ctx_bytes: *u8): i32; /** * G.7: leftover WAVE273 gcc overlay owns F7 append-zeros (grows data_len). * FORCE mega T smash (`sub $0x898` / cltq) first-won leftover W 0xa2. * gdb asm_wpo: mega smash append $rip, leftover gcc poke then sees data_len=0. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_append_data_zeros(ctx_bytes: *u8, n: i32): i32; /** * G.7: leftover WAVE273 gcc overlay owns F7 data poke (0x4c, RIP data_len). * FORCE mega T first-won smash poke; leftover gcc poke requires leftover * gcc append to have grown the same BSS. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_data_poke_u8(ctx_bytes: *u8, off: i32, b: i32): i32; /** * G.7: leftover smash T of bake_scalar_imm_to_data is the working body * (product gdb eax=0; mega smash `sub $0x8c8` eax=-1). No leftover gcc W * of this face. Same-TU localize still binds mega prepare to mega local t. * Mega must emit U so leftover T (weaken→W) is the sole global. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover pabi T provides the body. */ export extern function pipe_modlet_bake_scalar_imm_to_data( elf_ctx: *u8, data_off: i32, imm: i32, csz: i32 ): i32; /** * G.7: leftover WAVE273 gcc overlay owns add_sym (W 0x22d, endbr64). * FORCE mega T smash first-won leftover W. leftover gcc add_common_sym * CALLs this face; mega smash add_sym RIP-loads `g_pipe_elf_*` sidecar * while leftover gcc uses `g_pipeline_elf_*` + leftover ctx layout. * Same-TU localize of mega T still binds mega prepare's CALL to local t. * Mega must emit U so leftover gcc W is the sole global. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_add_sym( ctx_bytes: *u8, name: *u8, name_len: i32, offset: i32 ): i32; /** * G.7: leftover WAVE273 gcc overlay owns add_common_sym (W 0x138, endbr64). * FORCE mega T smash first-won leftover W. Dual BSS: mega * `g_pipe_elf_sym_is_common` ≠ leftover `g_pipeline_elf_sym_is_common`. * leftover gcc add_common_sym calls leftover gcc add_sym (same family). * Do not leftover-first smash-only `modlet_prepare` (layout mismatch). * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_add_common_sym( ctx_bytes: *u8, name: *u8, name_len: i32, sym_size: i32, sym_align: i32 ): i32; /** * G.7: leftover WAVE273 gcc overlay owns add_label (W 0x1f0, endbr64). * FORCE mega T smash first-won leftover W. Dual BSS: mega * `g_pipe_elf_label_shndx` ≠ leftover `g_pipeline_elf_label_shndx`. * leftover gcc add_label uses leftover STATIC current_shndx / * label_shndx_set (not first-win-able). leftover gcc ensure_label * CALLs leftover gcc add_label (same family). Same-TU localize of * mega T still binds mega prepare's CALL to local t. Mega must emit * U so leftover gcc W is the sole global. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_add_label( ctx_bytes: *u8, name: *u8, name_len: i32, offset: i32 ): i32; /** * G.7: leftover WAVE273 gcc overlay owns ensure_label (W 0xd5, endbr64). * FORCE mega T smash first-won leftover W. leftover gcc ensure_label * CALLs leftover gcc add_label; leftover-first both faces together. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_ensure_label( ctx_bytes: *u8, name: *u8, name_len: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_assign_elf_c (W 0x4b79, endbr64). * FORCE mega T smash first-won leftover W. leftover gcc VAR assign CALLs leftover * gcc glue_emit_assign_rhs_to_rax_elf_c (W 0x59b); leftover gcc rhs_to_rax * plain (ako==28) CALLs leftover gcc glue_emit_assign_rhs_elf_c (W 0xd6). * Same-TU localize of mega T still binds mega CALL to local t. Mega must emit * U so leftover gcc W is the sole global. Family leftover-first all three. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_assign_elf_c( arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_emit_assign_rhs_to_rax_elf_c (W 0x59b, endbr64). * leftover gcc emit_assign VAR/fallback CALLs this. Family with emit_assign. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_emit_assign_rhs_to_rax_elf_c( arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_emit_assign_rhs_elf_c (W 0xd6, endbr64). * leftover gcc rhs_to_rax plain (ako==28) CALLs this; leftover gcc then * pipeline_asm_emit_expr_elf_c (already leftover-first emit_fast/rec). * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_emit_assign_rhs_elf_c( arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_expr_elf_for_call_args * (W 0x2c4f, endbr64 sub $0x248). FORCE mega T smash (sub $0x5c38 / cltq) * first-won leftover W. Same-TU localize of mega T still binds mega CALL * to local t. Mega must emit U so leftover gcc W is the sole global. * backend_call_dispatch already export-externs this face; localize * for_call_args_thin so thin W cannot first-win leftover gcc W. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_expr_elf_for_call_args( arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns asm_parser_emit_heavy_safe_helper * (W 0x22d7, endbr64 sub $0x10). FORCE mega T smash (sub $0x87c8) * first-won leftover W. Same-TU caller asm_skip_heavy_module_func_body * is already in unsafe. Do not leftover-first skip_heavy itself * (wave650 FORCE_FULL_BODIES escape). Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_parser_emit_heavy_safe_helper( m: *u8, func_index: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_emit_struct_type_let_init_elf_c * (W 0x20c9, endbr64 sub $0x3b8). FORCE mega T smash first-won leftover W. * leftover gcc STRUCT_LIT path CALLs leftover gcc * pipeline_asm_emit_struct_let_init_elf_c (W 0xa0) which CALLs leftover gcc * pipeline_asm_emit_struct_lit_fields_elf_c (W 0x169e). leftover gcc * emit_expr STRUCT_LIT CALLs leftover gcc pipeline_asm_emit_struct_lit_elf_c * (W 0x44). Family leftover-first all four so leftover gcc parent CALLs * leftover gcc children. Same-TU callers already in unsafe. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_emit_struct_type_let_init_elf_c( arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, let_ty_ref: i32, stack_slot_off: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_struct_let_init_elf_c * (W 0xa0, endbr64 sub $0x40). leftover gcc glue_emit_struct_type_let_init * CALLs this for STRUCT_LIT. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_struct_let_init_elf_c( arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_struct_lit_fields_elf_c * (W 0x169e, endbr64 sub $0xb8). leftover gcc struct_let_init / emit_struct_lit * CALL this. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_struct_lit_fields_elf_c( arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_struct_lit_elf_c * (W 0x44, endbr64 sub $0x20). leftover gcc emit_expr STRUCT_LIT CALLs this * wrapper, which CALLs leftover gcc struct_lit_fields. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_struct_lit_elf_c( arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns asm_parser_m8_tail_thin_delegate_c_name * (W 0x1f1a, endbr64 sub $0x20). FORCE mega T smash first-won leftover W. * leftover gcc skip_heavy_or_thin_stub / resolve_call_to_glue CALL this. * Do not leftover-first asm_skip_heavy_module_func_body (FORCE_FULL_BODIES * dual env). Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_parser_m8_tail_thin_delegate_c_name( m: *u8, func_index: i32, out: *u8, out_cap: i32, out_len: *i32 ): i32; /** * G.7: leftover gcc overlay owns asm_wpo_collect_walk * (W 0x1e56, endbr64 sub $0x210). FORCE mega T smash first-won leftover W. * Mega wrappers collect_edges_from_expr / collect_from_block CALL this. * asm_wpo_thin also has a body — localize so thin W cannot first-win. * Do not leftover-first asm_skip_heavy_module_func_body (FORCE_FULL_BODIES * dual env). Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_wpo_collect_walk( is_block: i32, a: *u8, ref: i32, caller_id: i32, caller_mod: *u8, ctx: *u8, depth: i32 ): void; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_return_elf_impl * (W 0x1a7e, endbr64 sub $0x1e8). FORCE mega T smash first-won leftover W. * Mega wrapper pipeline_asm_emit_return_elf_c and expr_rec CALL this. * arr_return_thin / fixed_array_copy_thin also have a body — localize so * thin W cannot first-win. HARD BAN product PREFER of return_elf_impl_thin * (FORCE user -c of that thin is T001). Do not leftover-first * asm_skip_heavy_module_func_body (FORCE_FULL_BODIES dual env). Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_return_elf_impl( arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: runtime_pipeline_abi_parser_thin_delegate_thin.x owns * asm_parser_func_is_thin_delegate. The egg copy stays weak behind that * overlay (was W 0x12d3). Mega skip_heavy CALLs this (already unsafe). * Do not add a second body here. Mega must emit U. * PLATFORM: SHARED — overlay first-wins; egg table is not the linked body. */ export extern function asm_parser_func_is_thin_delegate(m: *u8, func_index: i32): i32; /** * G.7: leftover gcc overlay owns asm_backend_m8_tail_thin_delegate_c_name * (W 0xa62, endbr64 sub $0x20). FORCE mega T smash first-won leftover W. * Mega skip_heavy_or_thin_stub CALLs this (already unsafe). No thin copy. * Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_backend_m8_tail_thin_delegate_c_name( m: *u8, func_index: i32, out: *u8, out_cap: i32, out_len: *i32 ): i32; /** * G.7: leftover gcc overlay owns asm_pipeline_m8_tail_thin_delegate_c_name * (W 0x130, endbr64 sub $0x20). FORCE mega T smash first-won leftover W. * Mega skip_heavy_or_thin_stub CALLs this (already unsafe). No thin copy. * Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_pipeline_m8_tail_thin_delegate_c_name( m: *u8, func_index: i32, out: *u8, out_cap: i32, out_len: *i32 ): i32; /** * G.7: leftover gcc overlay owns asm_typeck_m8_tail_thin_delegate_c_name * (W 0xed, endbr64 sub $0x30). FORCE mega T smash first-won leftover W. * Mega skip_heavy_or_thin_stub CALLs this (already unsafe). No thin copy. * Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_typeck_m8_tail_thin_delegate_c_name( m: *u8, func_index: i32, out: *u8, out_cap: i32, out_len: *i32 ): i32; /** * G.7: leftover gcc overlay owns asm_driver_m8_tail_thin_delegate_c_name * (W 0x64, endbr64 sub $0x20). FORCE mega T smash first-won leftover W. * Mega skip_heavy_or_thin_stub CALLs this (already unsafe). No thin copy. * Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_driver_m8_tail_thin_delegate_c_name( m: *u8, func_index: i32, out: *u8, out_cap: i32, out_len: *i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_lvalue_eff_addr_elf_c * (W 0x890, endbr64 sub $0x170). FORCE mega T smash first-won leftover W. * leftover gcc emit_assign (w710) CALLs leftover gcc this face for FIELD/INDEX * /DEREF lvalues. Thins export-extern (no body). Mega same-TU callers already * unsafe. Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_lvalue_eff_addr_elf_c( arena: *u8, elf_ctx: *u8, lval_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_enc_local_slot_ptr_or_addr_elf_c * (W 0x82, endbr64 sub $0x40). FORCE mega T smash sub $0x8b8 first-won leftover W. * leftover gcc emit_assign CALLs leftover gcc this face (field_assign HIT smash). * Thins export-extern (no body). Mega same-TU callers already unsafe. * Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_enc_local_slot_ptr_or_addr_elf_c( arena: *u8, elf_ctx: *u8, var_ref: i32, var_off: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_index_elem_byte_sz_c * (W 0x1103). FORCE mega T smash first-won leftover W. leftover gcc INDEX * / lvalue_eff_addr CALLs leftover gcc this face. Thins export-extern * (no body). Mega same-TU callers wrapped unsafe. Do not leftover-first * skip_heavy or skip_heavy_or_thin_stub parent. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_index_elem_byte_sz_c( arena: *u8, expr_ref: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_emit_index_eff_addr_scaled_elf_c * (W 0x73e). FORCE mega T smash first-won leftover W. leftover gcc INDEX * / lvalue_eff_addr / assign CALLs leftover gcc this face (index_i32 gdb * HIT). Thins export-extern (no body). Mega same-TU callers already unsafe. * Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_emit_index_eff_addr_scaled_elf_c( arena: *u8, elf_ctx: *u8, ix_ref: i32, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_try_index_var_or_field_base_to_rax_elf_c * (W 0xe0c). FORCE mega T smash first-won leftover W. leftover gcc INDEX * scaled (w725) CALLs leftover gcc this face (INDEX lit path). Thins * export-extern (no body). Mega same-TU callers wrapped unsafe. Do not * leftover-first skip_heavy, skip_heavy_or_thin_stub parent, rbx twin, * or wrapper pipeline_asm_index_elem_byte_sz. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_try_index_var_or_field_base_to_rax_elf_c( arena: *u8, elf_ctx: *u8, base_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_try_index_rvalue_slice_once_elf_c * (W 0xd2e). FORCE mega T smash first-won leftover W. leftover gcc INDEX * scaled (w725) CALLs leftover gcc this face (CALL/METHOD/INDEX/DEREF * TYPE_SLICE rvalue-once). No thin defines this symbol. Mega same-TU * remaining callers after scaled leftover-first: 0. Do not leftover-first * skip_heavy, skip_heavy_or_thin_stub parent, rbx twin, bounds_guard, * or wrapper pipeline_asm_index_elem_byte_sz. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_try_index_rvalue_slice_once_elf_c( arena: *u8, elf_ctx: *u8, ix_ref: i32, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_emit_index_bounds_guard_elf_c * (W 0x90f). FORCE mega T smash first-won leftover W. leftover gcc INDEX * scaled (w725) CALLs leftover gcc this face (INDEX bounds). No thin * defines this symbol. Mega same-TU remaining callers after scaled * leftover-first: 0. Do not leftover-first skip_heavy, skip_heavy_or_thin_stub * parent, rbx twin, rax_plus_rbx_scaled, or wrapper * pipeline_asm_index_elem_byte_sz. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_emit_index_bounds_guard_elf_c( arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32, ix_ref: i32, base_ref: i32, idx_ref: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_try_index_var_or_field_base_to_rbx_elf_c * (W 0x7dc). FORCE mega T smash first-won leftover W. leftover gcc INDEX * assign-addr→rbx forest CALLs leftover gcc this face (INDEX assign base). * No thin defines this symbol. Mega same-TU remaining callers: 18 (already * unsafe). Do not leftover-first skip_heavy, skip_heavy_or_thin_stub * parent, rax_plus_rbx_scaled, local_slot rbx twin, or wrapper * pipeline_asm_index_elem_byte_sz. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_try_index_var_or_field_base_to_rbx_elf_c( arena: *u8, elf_ctx: *u8, base_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_local_var_slot_needs_ptr_load_elf_c * (W 0x542). FORCE mega T smash first-won leftover W. leftover gcc local_slot * (w723 W 0x82) CALLs leftover gcc this face. Thin param_ptr_slot_thin HAS a * body (W 0x8dc) — must localize or thin W first-wins leftover gcc. Mega * same-TU remaining callers: 4. Do not leftover-first skip_heavy, * skip_heavy_or_thin_stub parent, rax_plus_rbx_scaled, local_slot rbx twin, * or wrapper pipeline_asm_index_elem_byte_sz. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_local_var_slot_needs_ptr_load_elf_c( arena: *u8, var_expr_ref: i32, stack_off: i32, ctx: *u8 ): i32; /** * G.7: leftover gcc overlay owns glue_copy_large_struct_from_rax_ptr_elf_c * (W 0x482). FORCE mega T smash first-won leftover W. leftover gcc * store_retval_pair (W 0x2bb) CALLs leftover gcc this face (>16B CALL * memcpy). Thins assign_thin / assign_deref_* export-extern (no body) * — still localize. Mega same-TU remaining callers: 5. Do not leftover-first * skip_heavy, skip_heavy_or_thin_stub parent, rax_plus_rbx_scaled, * local_slot rbx twin, wrapper pipeline_asm_index_elem_byte_sz, or * store_retval_pair itself. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_copy_large_struct_from_rax_ptr_elf_c( elf_ctx: *u8, slot_off: i32, sz: i32, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_emit_vector_type_let_init_elf_c * (W 0x2c5). FORCE mega T smash first-won leftover W. leftover gcc * let-init / assign SIMD paths CALL leftover gcc this face (non-vector * returns -2). Thins assign_thin / assign_var_try_let / * assign_index_simd_body / assign_field_var_simd / * assign_deref_vec_call / for_call_args export-extern (no body) * — still localize. Mega same-TU remaining callers: 5. Do not leftover-first * skip_heavy, skip_heavy_or_thin_stub parent, rax_plus_rbx_scaled, * local_slot rbx twin, wrapper pipeline_asm_index_elem_byte_sz, * store_retval_pair, or vector children (vector_let_init / var_copy / * binop / simd_try_inline_*). Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_emit_vector_type_let_init_elf_c( arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, type_ref: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_vector_let_init_elf_c * (W 0x73f). FORCE mega T smash first-won leftover W (`sub $0x13a8`). * leftover gcc vector_type_let_init (w732 W 0x2c5) CALLs leftover gcc this * face for ARRAY_LIT. Thin fixed_array_copy / arr_struct_lit_arrlit * export-extern (no body) — still localize. Mega same-TU remaining callers: 1. * Do not leftover-first skip_heavy, skip_heavy_or_thin_stub parent, * rax_plus_rbx_scaled, local_slot rbx twin, wrapper, store_retval_pair, * or other vector children (var_copy / binop / simd_try_inline_*). * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_vector_let_init_elf_c( arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_simd_try_inline_select_call_elf_c * (W 0x691). FORCE mega T smash first-won leftover W (`sub $0x13f8`). * leftover gcc vector_type_let_init (w732 W 0x2c5) CALLs leftover gcc this * face for CALL/METHOD simd.select. Mega same-TU remaining callers: 0 * (parent leftover-first). No thin defines this symbol — still localize. * Do not leftover-first skip_heavy, skip_heavy_or_thin_stub parent, * rax_plus_rbx_scaled, local_slot rbx twin, wrapper, store_retval_pair, * or other vector children (var_copy / binop / splat / shuffle / fma / * identity / binop2). Mega may not emit U (unused export-extern). * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_simd_try_inline_select_call_elf_c( arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, type_ref: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_simd_try_inline_shuffle_call_elf_c * (W 0x4ca). FORCE mega T smash first-won leftover W (`sub $0xd78`). * leftover gcc vector_type_let_init (w732 W 0x2c5) CALLs leftover gcc this * face for CALL/METHOD simd.shuffle. Mega same-TU remaining callers: 0 * (parent leftover-first). No thin defines this symbol — still localize. * Do not leftover-first skip_heavy, skip_heavy_or_thin_stub parent, * rax_plus_rbx_scaled, local_slot rbx twin, wrapper, store_retval_pair, * or other vector children (var_copy / binop / splat / fma / * identity / binop2). Mega may not emit U (unused export-extern). * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_simd_try_inline_shuffle_call_elf_c( arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, type_ref: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_simd_try_inline_fma3_call_elf_c * (W 0x47e). FORCE mega T smash first-won leftover W (`sub $0xcf8`). * leftover gcc vector_type_let_init (w732 W 0x2c5) CALLs leftover gcc this * face for CALL/METHOD simd.fma. Mega same-TU remaining callers: 0 * (parent leftover-first). No thin defines this symbol — still localize. * Do not leftover-first skip_heavy, skip_heavy_or_thin_stub parent, * rax_plus_rbx_scaled, local_slot rbx twin, wrapper, store_retval_pair, * or other vector children (var_copy / binop / splat / identity / binop2). * Mega may not emit U (unused export-extern). * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_simd_try_inline_fma3_call_elf_c( arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, type_ref: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_simd_try_inline_splat_call_elf_c * (W 0x423). FORCE mega T smash first-won leftover W (`sub $0xbb8`). * leftover gcc vector_type_let_init (w732 W 0x2c5) CALLs leftover gcc this * face for CALL/METHOD simd.splat. Mega same-TU remaining callers: 1 * (glue_simd_select_arg_stack_off_c, wrapped unsafe). No thin defines this * symbol — still localize. * Do not leftover-first skip_heavy, skip_heavy_or_thin_stub parent, * rax_plus_rbx_scaled, local_slot rbx twin, wrapper, store_retval_pair, * or other vector children (var_copy / binop / identity / binop2). * Mega may emit U (remaining caller). * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_simd_try_inline_splat_call_elf_c( arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, type_ref: i32 ): i32; /** * G.7: parser_x owns parser_get_module_import_path. * PLATFORM: SHARED — parser_x.o provides the body. */ export extern function parser_get_module_import_path(module: *u8, idx: i32, path_buf: *u8): void; /** * Copy import path at index i into out[0..64) (NUL-terminated) and return path length. * @param module *u8 - opaque AST module; null -> out[0]=0 when out valid, return 0 * @param i i32 - import index (negative / OOB handled by G.7 path_copy / ImportEntry) * @param out *u8 - destination buffer; capacity 64 bytes including NUL; null -> 0 * @return i32 - byte length of path excluding NUL; 0 on null/missing path * wave99 pure Cap residual close: G.7 single product authority for path64 surface. * Body ≡ historical parser_gen: pipeline_module_import_path_copy(..., 64) + scan NUL. * wave110: path_copy storage is pure ImportEntry map (not Cap residual). * PLATFORM: SHARED - parser_gen path64 demoted weak cold twin; product pure hybrid owns. */ #[no_mangle] export function parser_copy_module_import_path64(module: *u8, i: i32, out: *u8): i32;
export extern function try_inline_struct_lit_return_call_to_slot_elf(arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32): i32; export extern "C" function try_inline_const_struct_lit_return_call_to_slot_elf(arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32): i32; // wave206 pure-owned: pipeline_asm_set/call_expected_ret_ty_c + pure BSS at EOF. // G.7 ban dual export extern + pure export for the same symbol. // wave194 pure-owned: glue_call_return_byte_size_c body at EOF (#[no_mangle]). // wave195 pure-owned: pipeline_asm_call_arg_value_byte_size_c body at EOF (#[no_mangle]). // wave196 pure-owned: pipeline_asm_call_return_type_kind_ord_c body at EOF (#[no_mangle]). // wave197 pure-owned: pipeline_asm_call_struct16_ret_needs_rax_deref_c + // pipeline_asm_deref_struct16_rax_ptr_elf_c bodies at EOF (#[no_mangle]). // wave198 pure-owned: pipeline_asm_call_param_type_ref_at_c body at EOF (#[no_mangle]). // wave199 pure-owned: glue_asm_resolve_call_target_module_c body at EOF (#[no_mangle]). // G.7 ban dual export extern + pure export for the same symbol. // Resolve callees (Cap residual / pool): typeck resolve + find_func + call resolved_* . export extern "C" function pipeline_expr_call_resolved_func_index_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_call_resolved_dep_index_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_typeck_resolve_call_func_index_for_emit_c(m: *u8, a: *u8, call_expr_ref: i32): i32; export extern "C" function pipeline_typeck_find_func_return_type_in_module_by_name_c( mod: *u8, caller_arena: *u8, name: *u8, name_len: i32, from_dep_index: i32, ctx: *u8, func_index_out: *i32): i32; export extern "C" function pipeline_typeck_find_func_return_type_in_module_c( mod: *u8, mod_arena: *u8, caller_arena: *u8, callee_arena: *u8, callee_expr_ref: i32, from_dep_index: i32, ctx: *u8, func_index_out: *i32): i32; export extern "C" function pipeline_typeck_get_dep_return_type_in_caller_arena_c(from_dep_index: i32, dep_return_type_ref: i32, caller_arena: *u8, ctx: *u8): i32; // wave198: slow-path dep type_ref → caller-arena map (Cap residual method_call). // PLATFORM: SHARED — param formal type_ref must never cross arenas raw. export extern "C" function pipeline_typeck_dep_return_type_to_caller_arena_c(dep_arena: *u8, dep_return_type_ref: i32, caller_arena: *u8): i32; // wave154 pure-owned: glue_type_size_simple body in EOF section. // wave191 pure-owned: glue_type_named_layout_size_any_module_elf_c lives at EOF (#[no_mangle]). // G.7 ban dual export extern + pure export for the same symbol. // wave204 pure-owned: glue_store_retval_pair_to_rbp_elf_c + private // glue_copy_large_struct_from_rax_ptr_elf_c bodies at EOF (#[no_mangle] public). // wave205 pure-owned: glue_slice_let_reent_deep_copy_after_dual_gp_elf_c at EOF // (#[no_mangle] public). G.7 ban dual export extern + pure export. // wave189 pure-owned: glue_emit_module_from_ctx live at EOF (#[no_mangle]). // G.7 ban dual export extern + pure export for the same symbol. // wave133 Cap residual: unary pure leave callees (operand emit + float classifiers + // int64 lit + arch encoders). glue_var_decl_type_ref_elf_c is pure (var_decl leave). // PLATFORM: SHARED freestanding emit — pure owns NEG/LOGNOT/BITNOT + sxt + jz faces. // wave149 pure-owned faces: bodies in EOF section (#[no_mangle] export; no dual export extern). export extern "C" function pipeline_expr_int64_val_at(arena: *u8, expr_ref: i32): i64; export extern "C" function backend_enc_neg_eax_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_not_eax_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function backend_enc_setz_movzbl_eax_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function arch_arm64_enc_enc_u32_le(elf_ctx: *u8, val: i32): i32; // wave134 Cap residual: match pure leave callees (MATCH/EXPR_IF arm faces + if_arm + // struct layout for subject field-bind). Enc jmp/jne/label/mov/cmp + next_label + // emit_expr_elf_c + module/func_index getters already Cap residual above. // PLATFORM: SHARED freestanding emit — pure owns match_elf + expr_if_elf + subject BSS. export extern "C" function pipeline_expr_match_matched_ref_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_match_num_arms_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_match_arm_is_wildcard(arena: *u8, expr_ref: i32, i: i32): i32; export extern "C" function pipeline_expr_match_arm_guard_ref(arena: *u8, expr_ref: i32, i: i32): i32; export extern "C" function pipeline_expr_match_arm_result_ref(arena: *u8, expr_ref: i32, i: i32): i32; export extern "C" function pipeline_expr_match_arm_is_enum_variant(arena: *u8, expr_ref: i32, i: i32): i32; export extern "C" function pipeline_expr_match_arm_variant_index(arena: *u8, expr_ref: i32, i: i32): i32; export extern "C" function pipeline_expr_match_arm_lit_val(arena: *u8, expr_ref: i32, i: i32): i32; export extern "C" function pipeline_expr_if_cond_ref_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_if_then_ref_at(arena: *u8, expr_ref: i32): i32; export extern "C" function pipeline_expr_if_else_ref_at(arena: *u8, expr_ref: i32): i32; // wave153 pure-owned: pipeline_asm_emit_expr_if_arm_elf_c body in EOF section. // wave154 Cap residual: struct_lit pure leave callees (size glue + diagnostics + dual-GP). // wave266: pipeline_module_struct_layout_* / num_struct_layouts_at pure (struct_layout leave; dual-export ban). export extern "C" function typeck_x_type_size_from_layout_glue(module: *u8, arena: *u8, li: i32, depth: i32): i32; export extern "C" function typeck_soa_array_storage_size_glue(module: *u8, arena: *u8, elem_type_ref: i32, array_len: i32, depth: i32): i32; export extern "C" function pipeline_typeck_type_refs_equal_c(arena: *u8, a: i32, b: i32): i32; export extern "C" function backend_enc_load_qword_rbx8_to_rdx_arch(elf_ctx: *u8, ta: i32): i32; export extern "C" function driver_diagnostic_typeck_struct_padding_before(sname: *u8, sname_len: i32, gap: i32, fname: *u8, fname_len: i32): void; export extern "C" function driver_diagnostic_typeck_struct_padding_trailing(sname: *u8, sname_len: i32, gap: i32): void; export extern "C" function driver_diagnostic_typeck_struct_field_bad_size(sname: *u8, sname_len: i32, fname: *u8, fname_len: i32): void; export extern "C" function driver_diagnostic_warn_pad_fields_same_cache_line(sname: *u8, sname_len: i32, f0: *u8, f0_len: i32, f1: *u8, f1_len: i32): void; export extern "C" function driver_diagnostic_hint_unused_binding(line: i32, col: i32, name: *u8, name_len: i32): void; export extern "C" function driver_diagnostic_warn_hot_reorder_field(sname: *u8, sname_len: i32, hot: *u8, hot_len: i32, cold: *u8, cold_len: i32): void; /* wave235 G.7: env via public pure thin link_abi_getenv (wave222 -> _impl host getenv); * not raw libc getenv. Cap residual host getenv stays only link_abi_getenv_impl. * Used by pipeline_asm_debug_enabled + pipeline_debug_trace_named_func_bodies_impl. * PLATFORM: SHARED - product hybrid pipeline_abi pure uses same face as cold seed. */ export extern "C" function link_abi_getenv(name: *u8): *u8; export extern function link_abi_host_is_windows(): i32; /* wave1222: extern declarations for parser_parse_into_init body. * These mirror the C authority in parser_gen.c L6318-6331 to ensure the * .x strong symbol performs identical AST arena/module state reset. * Without this, the empty .x body overrode the C init, causing AST arena * state leakage between file checks in directory mode (T001 cascades). * PLATFORM: SHARED - all externs are platform-agnostic arena/module reset. */ // wave276: ast_ast_arena_init pure-owned at EOF (dual-export ban; no Cap residual) export extern "C" function ast_pool_module_reset(module: *u8): void; export extern "C" function ast_pool_arena_reset(arena: *u8): void; export extern "C" function parser_onefunc_result_layout_prime(): void; export extern "C" function parser_onefunc_result_layout_prime_b(): void; export extern "C" function parser_onefunc_result_layout_prime_c(): void; export extern "C" function parser_onefunc_result_layout_prime_d(): void; export extern "C" function parser_onefunc_result_layout_prime_d_b(): void; export extern "C" function parser_onefunc_result_layout_prime_e(): void; export extern "C" function parser_onefunc_result_layout_prime_f(): void; export extern "C" function parser_pipeline_module_reset_parse_counters(module: *u8): void; export extern "C" function pipeline_parser_set_match_module(module: *u8): void; /* wave1222: trait registry + generic bound source stash (mirrors C impl_c). * Without these, directory-mode check leaks trait/generic state across files, * causing the parser to misbehave (e.g. num_funcs drops from 356 to 104 for * runtime_pipeline_abi.x when checked after other files). * PLATFORM: SHARED - pure delegation to platform-agnostic externs. */ export extern "C" function xlang_trait_reg_reset_c(arena: *u8): void; export extern "C" function xlang_generic_bound_stash_source_buf_c(data: *u8, len: i32): void; /* wave1223: extern declarations for pipeline_parse_set_main_from_buf_c body. * Live G.7 authority is this .x / runtime_pipeline_abi seed (historical C twin * in deleted ast_pool.c left wave309). Keep parse + main_idx set identical to * the pre-leave contract so directory mode does not skip files. * Without this, an empty .x body (return 0) overrode the prior C impl, causing * pipeline_run_x_pipeline to skip parsing entirely in directory mode * (num_funcs=190 instead of 377 for runtime_driver_abi_thin.x). * PLATFORM: SHARED - all externs are platform-agnostic parse/diag helpers. */ // wave121: pipeline_lint_set_source_buf + pipeline_module_set_main_func_index pure below. // (lint_meta pure-owned leave) export extern "C" function driver_diagnostic_parse_fail(main_idx: i32, num_funcs: i32, arena_num_types: i32): void; // wave276: pipeline_arena_num_types pure-owned at EOF (dual-export ban) /* wave112: pipeline_parse_into_with_init_buf_scalars is pure export below * (parse_typeck_dispatch leave). Cap residual unpack is * pipeline_parse_into_with_init_buf_impl_rc (pipeline_parse_orch.c) over * Cap-struct-return impl_c / strict_parse_into_init. */ /** * G.7: parser_x owns parser_parse_into_init. This TU must not emit a * competing T — FORCE mega previously first-won (g05 pabi is #8, * parser_x.o is #20) with hoist-target modlet seed dumped into the * wrapper (1744B lea COMMON inits, then the 13 calls). Product Ubuntu * already used parser_x (pabi W); Darwin pabi T was the duplicate. * PLATFORM: SHARED — link-name contract; parser_x.o provides the body. */ export extern function parser_parse_into_init(module: *u8, arena: *u8): void; /** * G.7: parser_x owns parser_get_module_num_imports. Mega's `return 0` * stub first-wins under FORCE and reports zero imports. * PLATFORM: SHARED — parser_x.o provides the body. */ export extern function parser_get_module_num_imports(module: *u8): i32; /** * G.7: leftover WAVE274 / asm_wpo_thin owns PGO emit-order prepare. * FORCE mega T first-won a smashed body (call-next-insn / emit_n imm 0); * mega_body then called emit_order_at which returned -1 for every slot * so w393_mega_emit_one hit `if (i < 0) return 0` and wrote no text * (CG002 code_len=0). This TU must not emit a competing T. * PLATFORM: SHARED — leftover from_x WAVE274 provides the body. */ export extern function pipeline_asm_wpo_pgo_emit_order_prepare(m: *u8): void; /** * G.7: leftover WAVE274 owns emit-order count (pairs with prepare/at). * FORCE mega T of count happened to load emit_n=2 while at() used imm 0. * PLATFORM: SHARED — leftover from_x WAVE274 provides the body. */ export extern function pipeline_asm_wpo_pgo_emit_order_count(m: *u8): i32; /** * G.7: leftover WAVE274 owns emit-order at (func index or -1). * FORCE mega/thin asm lowered `order_index >= g_aw_pgo_emit_n` to * `mov $0, %eax` (no reloc); leftover gcc keeps RIP load of emit_n. * PLATFORM: SHARED — leftover from_x WAVE274 provides the body. */ export extern function pipeline_asm_wpo_pgo_emit_order_at(m: *u8, order_index: i32): i32; /** * G.7: leftover WAVE153 gcc owns two-pass stmt_order block-body ELF emit. * FORCE mega T first-won a smash (`sub $0x5228`, cltq on i32 block_ref) * over leftover W 0x22c6. parse_orch emit_one#2 then failed in * w499_mega_emit_body_sync (backend_emit_block_body_sync_elf mega T * `sub $0x8a8` / call-next-insn). Mega must not emit a competing T. * PLATFORM: SHARED — leftover from_x WAVE153 provides the body. */ export extern function pipeline_asm_emit_block_body_sync_elf(arena: *u8, elf_ctx: *u8, block_ref: i32, ctx: *u8, ta: i32): i32; /** * G.7: leftover WAVE153 gcc owns backend.x body_sync entry (84B wrapper: * diverged_set + bind_module_dep + inner emit). FORCE mega T smash * (`sub $0x8a8`) first-won leftover W 0x54. * PLATFORM: SHARED — leftover from_x WAVE153 provides the body. */ export extern function backend_emit_block_body_sync_elf(arena: *u8, elf_ctx: *u8, block_ref: i32, ctx: *u8, ta: i32): i32; /** * G.7: leftover WAVE152 gcc owns emit_expr_elf fast path (LIT / const_fold / * VAR / binop). FORCE mega T first-won smash (`sub $0x2e98` / cltq) over * leftover W 0x1200. parse_orch emit_one#2 then failed innermost at * pipeline_asm_emit_expr_elf_fast#63 eax=-1 after leftover body_sync W * was already live. Mega must not emit a competing T. * Same-TU callers (binop load_operand / emit_expr_elf_rec) stay in unsafe. * PLATFORM: SHARED — leftover from_x WAVE152 provides the body. */ export extern function pipeline_asm_emit_expr_elf_fast(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32; /** * G.7: leftover WAVE273 gcc overlay owns F7 data-section length. * FORCE mega T smash (`sub $0x888`) first-won leftover W 0x22 and RIP-loads * mega `g_pipe_elf_data_len`, not leftover `g_pipeline_elf_data_len`. * Same-TU localize of mega T still binds prepare's CALL to mega local t. * Mega must emit U so leftover gcc W is the sole global. * wave744: leftover-gcc sidecar first-wins this weak T and writes both BSS * homes so compact macho_write (inlines leftover C) emits __DATA. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_emit_data_len(ctx_bytes: *u8): i32; /** * G.7: leftover WAVE273 gcc overlay owns F7 append-zeros (grows data_len). * FORCE mega T smash (`sub $0x898` / cltq) first-won leftover W 0xa2. * gdb asm_wpo: mega smash append $rip, leftover gcc poke then sees data_len=0. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_append_data_zeros(ctx_bytes: *u8, n: i32): i32; /** * G.7: leftover WAVE273 gcc overlay owns F7 data poke (0x4c, RIP data_len). * FORCE mega T first-won smash poke; leftover gcc poke requires leftover * gcc append to have grown the same BSS. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_data_poke_u8(ctx_bytes: *u8, off: i32, b: i32): i32; /** * G.7: leftover smash T of bake_scalar_imm_to_data is the working body * (product gdb eax=0; mega smash `sub $0x8c8` eax=-1). No leftover gcc W * of this face. Same-TU localize still binds mega prepare to mega local t. * Mega must emit U so leftover T (weaken→W) is the sole global. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover pabi T provides the body. */ export extern function pipe_modlet_bake_scalar_imm_to_data( elf_ctx: *u8, data_off: i32, imm: i32, csz: i32 ): i32; /** * G.7: leftover WAVE273 gcc overlay owns add_sym (W 0x22d, endbr64). * FORCE mega T smash first-won leftover W. leftover gcc add_common_sym * CALLs this face; mega smash add_sym RIP-loads `g_pipe_elf_*` sidecar * while leftover gcc uses `g_pipeline_elf_*` + leftover ctx layout. * Same-TU localize of mega T still binds mega prepare's CALL to local t. * Mega must emit U so leftover gcc W is the sole global. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_add_sym( ctx_bytes: *u8, name: *u8, name_len: i32, offset: i32 ): i32; /** * G.7: leftover WAVE273 gcc overlay owns add_common_sym (W 0x138, endbr64). * FORCE mega T smash first-won leftover W. Dual BSS: mega * `g_pipe_elf_sym_is_common` ≠ leftover `g_pipeline_elf_sym_is_common`. * leftover gcc add_common_sym calls leftover gcc add_sym (same family). * Do not leftover-first smash-only `modlet_prepare` (layout mismatch). * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_add_common_sym( ctx_bytes: *u8, name: *u8, name_len: i32, sym_size: i32, sym_align: i32 ): i32; /** * G.7: leftover WAVE273 gcc overlay owns add_label (W 0x1f0, endbr64). * FORCE mega T smash first-won leftover W. Dual BSS: mega * `g_pipe_elf_label_shndx` ≠ leftover `g_pipeline_elf_label_shndx`. * leftover gcc add_label uses leftover STATIC current_shndx / * label_shndx_set (not first-win-able). leftover gcc ensure_label * CALLs leftover gcc add_label (same family). Same-TU localize of * mega T still binds mega prepare's CALL to local t. Mega must emit * U so leftover gcc W is the sole global. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_add_label( ctx_bytes: *u8, name: *u8, name_len: i32, offset: i32 ): i32; /** * G.7: leftover WAVE273 gcc overlay owns ensure_label (W 0xd5, endbr64). * FORCE mega T smash first-won leftover W. leftover gcc ensure_label * CALLs leftover gcc add_label; leftover-first both faces together. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_elf_ctx_ensure_label( ctx_bytes: *u8, name: *u8, name_len: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_assign_elf_c (W 0x4b79, endbr64). * FORCE mega T smash first-won leftover W. leftover gcc VAR assign CALLs leftover * gcc glue_emit_assign_rhs_to_rax_elf_c (W 0x59b); leftover gcc rhs_to_rax * plain (ako==28) CALLs leftover gcc glue_emit_assign_rhs_elf_c (W 0xd6). * Same-TU localize of mega T still binds mega CALL to local t. Mega must emit * U so leftover gcc W is the sole global. Family leftover-first all three. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_assign_elf_c( arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_emit_assign_rhs_to_rax_elf_c (W 0x59b, endbr64). * leftover gcc emit_assign VAR/fallback CALLs this. Family with emit_assign. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_emit_assign_rhs_to_rax_elf_c( arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_emit_assign_rhs_elf_c (W 0xd6, endbr64). * leftover gcc rhs_to_rax plain (ako==28) CALLs this; leftover gcc then * pipeline_asm_emit_expr_elf_c (already leftover-first emit_fast/rec). * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_emit_assign_rhs_elf_c( arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_expr_elf_for_call_args * (W 0x2c4f, endbr64 sub $0x248). FORCE mega T smash (sub $0x5c38 / cltq) * first-won leftover W. Same-TU localize of mega T still binds mega CALL * to local t. Mega must emit U so leftover gcc W is the sole global. * backend_call_dispatch already export-externs this face; localize * for_call_args_thin so thin W cannot first-win leftover gcc W. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_expr_elf_for_call_args( arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns asm_parser_emit_heavy_safe_helper * (W 0x22d7, endbr64 sub $0x10). FORCE mega T smash (sub $0x87c8) * first-won leftover W. Same-TU caller asm_skip_heavy_module_func_body * is already in unsafe. Do not leftover-first skip_heavy itself * (wave650 FORCE_FULL_BODIES escape). Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_parser_emit_heavy_safe_helper( m: *u8, func_index: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_emit_struct_type_let_init_elf_c * (W 0x20c9, endbr64 sub $0x3b8). FORCE mega T smash first-won leftover W. * leftover gcc STRUCT_LIT path CALLs leftover gcc * pipeline_asm_emit_struct_let_init_elf_c (W 0xa0) which CALLs leftover gcc * pipeline_asm_emit_struct_lit_fields_elf_c (W 0x169e). leftover gcc * emit_expr STRUCT_LIT CALLs leftover gcc pipeline_asm_emit_struct_lit_elf_c * (W 0x44). Family leftover-first all four so leftover gcc parent CALLs * leftover gcc children. Same-TU callers already in unsafe. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_emit_struct_type_let_init_elf_c( arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, let_ty_ref: i32, stack_slot_off: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_struct_let_init_elf_c * (W 0xa0, endbr64 sub $0x40). leftover gcc glue_emit_struct_type_let_init * CALLs this for STRUCT_LIT. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_struct_let_init_elf_c( arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_struct_lit_fields_elf_c * (W 0x169e, endbr64 sub $0xb8). leftover gcc struct_let_init / emit_struct_lit * CALL this. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_struct_lit_fields_elf_c( arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_struct_lit_elf_c * (W 0x44, endbr64 sub $0x20). leftover gcc emit_expr STRUCT_LIT CALLs this * wrapper, which CALLs leftover gcc struct_lit_fields. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_struct_lit_elf_c( arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns asm_parser_m8_tail_thin_delegate_c_name * (W 0x1f1a, endbr64 sub $0x20). FORCE mega T smash first-won leftover W. * leftover gcc skip_heavy_or_thin_stub / resolve_call_to_glue CALL this. * Do not leftover-first asm_skip_heavy_module_func_body (FORCE_FULL_BODIES * dual env). Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_parser_m8_tail_thin_delegate_c_name( m: *u8, func_index: i32, out: *u8, out_cap: i32, out_len: *i32 ): i32; /** * G.7: leftover gcc overlay owns asm_wpo_collect_walk * (W 0x1e56, endbr64 sub $0x210). FORCE mega T smash first-won leftover W. * Mega wrappers collect_edges_from_expr / collect_from_block CALL this. * asm_wpo_thin also has a body — localize so thin W cannot first-win. * Do not leftover-first asm_skip_heavy_module_func_body (FORCE_FULL_BODIES * dual env). Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_wpo_collect_walk( is_block: i32, a: *u8, ref: i32, caller_id: i32, caller_mod: *u8, ctx: *u8, depth: i32 ): void; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_return_elf_impl * (W 0x1a7e, endbr64 sub $0x1e8). FORCE mega T smash first-won leftover W. * Mega wrapper pipeline_asm_emit_return_elf_c and expr_rec CALL this. * arr_return_thin / fixed_array_copy_thin also have a body — localize so * thin W cannot first-win. HARD BAN product PREFER of return_elf_impl_thin * (FORCE user -c of that thin is T001). Do not leftover-first * asm_skip_heavy_module_func_body (FORCE_FULL_BODIES dual env). Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_return_elf_impl( arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: runtime_pipeline_abi_parser_thin_delegate_thin.x owns * asm_parser_func_is_thin_delegate. The egg copy stays weak behind that * overlay (was W 0x12d3). Mega skip_heavy CALLs this (already unsafe). * Do not add a second body here. Mega must emit U. * PLATFORM: SHARED — overlay first-wins; egg table is not the linked body. */ export extern function asm_parser_func_is_thin_delegate(m: *u8, func_index: i32): i32; /** * G.7: leftover gcc overlay owns asm_backend_m8_tail_thin_delegate_c_name * (W 0xa62, endbr64 sub $0x20). FORCE mega T smash first-won leftover W. * Mega skip_heavy_or_thin_stub CALLs this (already unsafe). No thin copy. * Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_backend_m8_tail_thin_delegate_c_name( m: *u8, func_index: i32, out: *u8, out_cap: i32, out_len: *i32 ): i32; /** * G.7: leftover gcc overlay owns asm_pipeline_m8_tail_thin_delegate_c_name * (W 0x130, endbr64 sub $0x20). FORCE mega T smash first-won leftover W. * Mega skip_heavy_or_thin_stub CALLs this (already unsafe). No thin copy. * Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_pipeline_m8_tail_thin_delegate_c_name( m: *u8, func_index: i32, out: *u8, out_cap: i32, out_len: *i32 ): i32; /** * G.7: leftover gcc overlay owns asm_typeck_m8_tail_thin_delegate_c_name * (W 0xed, endbr64 sub $0x30). FORCE mega T smash first-won leftover W. * Mega skip_heavy_or_thin_stub CALLs this (already unsafe). No thin copy. * Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_typeck_m8_tail_thin_delegate_c_name( m: *u8, func_index: i32, out: *u8, out_cap: i32, out_len: *i32 ): i32; /** * G.7: leftover gcc overlay owns asm_driver_m8_tail_thin_delegate_c_name * (W 0x64, endbr64 sub $0x20). FORCE mega T smash first-won leftover W. * Mega skip_heavy_or_thin_stub CALLs this (already unsafe). No thin copy. * Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function asm_driver_m8_tail_thin_delegate_c_name( m: *u8, func_index: i32, out: *u8, out_cap: i32, out_len: *i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_lvalue_eff_addr_elf_c * (W 0x890, endbr64 sub $0x170). FORCE mega T smash first-won leftover W. * leftover gcc emit_assign (w710) CALLs leftover gcc this face for FIELD/INDEX * /DEREF lvalues. Thins export-extern (no body). Mega same-TU callers already * unsafe. Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_lvalue_eff_addr_elf_c( arena: *u8, elf_ctx: *u8, lval_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_enc_local_slot_ptr_or_addr_elf_c * (W 0x82, endbr64 sub $0x40). FORCE mega T smash sub $0x8b8 first-won leftover W. * leftover gcc emit_assign CALLs leftover gcc this face (field_assign HIT smash). * Thins export-extern (no body). Mega same-TU callers already unsafe. * Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_enc_local_slot_ptr_or_addr_elf_c( arena: *u8, elf_ctx: *u8, var_ref: i32, var_off: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_index_elem_byte_sz_c * (W 0x1103). FORCE mega T smash first-won leftover W. leftover gcc INDEX * / lvalue_eff_addr CALLs leftover gcc this face. Thins export-extern * (no body). Mega same-TU callers wrapped unsafe. Do not leftover-first * skip_heavy or skip_heavy_or_thin_stub parent. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_index_elem_byte_sz_c( arena: *u8, expr_ref: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_emit_index_eff_addr_scaled_elf_c * (W 0x73e). FORCE mega T smash first-won leftover W. leftover gcc INDEX * / lvalue_eff_addr / assign CALLs leftover gcc this face (index_i32 gdb * HIT). Thins export-extern (no body). Mega same-TU callers already unsafe. * Do not leftover-first skip_heavy or skip_heavy_or_thin_stub parent. * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_emit_index_eff_addr_scaled_elf_c( arena: *u8, elf_ctx: *u8, ix_ref: i32, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_try_index_var_or_field_base_to_rax_elf_c * (W 0xe0c). FORCE mega T smash first-won leftover W. leftover gcc INDEX * scaled (w725) CALLs leftover gcc this face (INDEX lit path). Thins * export-extern (no body). Mega same-TU callers wrapped unsafe. Do not * leftover-first skip_heavy, skip_heavy_or_thin_stub parent, rbx twin, * or wrapper pipeline_asm_index_elem_byte_sz. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_try_index_var_or_field_base_to_rax_elf_c( arena: *u8, elf_ctx: *u8, base_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_try_index_rvalue_slice_once_elf_c * (W 0xd2e). FORCE mega T smash first-won leftover W. leftover gcc INDEX * scaled (w725) CALLs leftover gcc this face (CALL/METHOD/INDEX/DEREF * TYPE_SLICE rvalue-once). No thin defines this symbol. Mega same-TU * remaining callers after scaled leftover-first: 0. Do not leftover-first * skip_heavy, skip_heavy_or_thin_stub parent, rbx twin, bounds_guard, * or wrapper pipeline_asm_index_elem_byte_sz. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_try_index_rvalue_slice_once_elf_c( arena: *u8, elf_ctx: *u8, ix_ref: i32, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_emit_index_bounds_guard_elf_c * (W 0x90f). FORCE mega T smash first-won leftover W. leftover gcc INDEX * scaled (w725) CALLs leftover gcc this face (INDEX bounds). No thin * defines this symbol. Mega same-TU remaining callers after scaled * leftover-first: 0. Do not leftover-first skip_heavy, skip_heavy_or_thin_stub * parent, rbx twin, rax_plus_rbx_scaled, or wrapper * pipeline_asm_index_elem_byte_sz. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_emit_index_bounds_guard_elf_c( arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32, ix_ref: i32, base_ref: i32, idx_ref: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_try_index_var_or_field_base_to_rbx_elf_c * (W 0x7dc). FORCE mega T smash first-won leftover W. leftover gcc INDEX * assign-addr→rbx forest CALLs leftover gcc this face (INDEX assign base). * No thin defines this symbol. Mega same-TU remaining callers: 18 (already * unsafe). Do not leftover-first skip_heavy, skip_heavy_or_thin_stub * parent, rax_plus_rbx_scaled, local_slot rbx twin, or wrapper * pipeline_asm_index_elem_byte_sz. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_try_index_var_or_field_base_to_rbx_elf_c( arena: *u8, elf_ctx: *u8, base_ref: i32, ctx: *u8, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_local_var_slot_needs_ptr_load_elf_c * (W 0x542). FORCE mega T smash first-won leftover W. leftover gcc local_slot * (w723 W 0x82) CALLs leftover gcc this face. Thin param_ptr_slot_thin HAS a * body (W 0x8dc) — must localize or thin W first-wins leftover gcc. Mega * same-TU remaining callers: 4. Do not leftover-first skip_heavy, * skip_heavy_or_thin_stub parent, rax_plus_rbx_scaled, local_slot rbx twin, * or wrapper pipeline_asm_index_elem_byte_sz. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_local_var_slot_needs_ptr_load_elf_c( arena: *u8, var_expr_ref: i32, stack_off: i32, ctx: *u8 ): i32; /** * G.7: leftover gcc overlay owns glue_copy_large_struct_from_rax_ptr_elf_c * (W 0x482). FORCE mega T smash first-won leftover W. leftover gcc * store_retval_pair (W 0x2bb) CALLs leftover gcc this face (>16B CALL * memcpy). Thins assign_thin / assign_deref_* export-extern (no body) * — still localize. Mega same-TU remaining callers: 5. Do not leftover-first * skip_heavy, skip_heavy_or_thin_stub parent, rax_plus_rbx_scaled, * local_slot rbx twin, wrapper pipeline_asm_index_elem_byte_sz, or * store_retval_pair itself. Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_copy_large_struct_from_rax_ptr_elf_c( elf_ctx: *u8, slot_off: i32, sz: i32, ta: i32 ): i32; /** * G.7: leftover gcc overlay owns glue_emit_vector_type_let_init_elf_c * (W 0x2c5). FORCE mega T smash first-won leftover W. leftover gcc * let-init / assign SIMD paths CALL leftover gcc this face (non-vector * returns -2). Thins assign_thin / assign_var_try_let / * assign_index_simd_body / assign_field_var_simd / * assign_deref_vec_call / for_call_args export-extern (no body) * — still localize. Mega same-TU remaining callers: 5. Do not leftover-first * skip_heavy, skip_heavy_or_thin_stub parent, rax_plus_rbx_scaled, * local_slot rbx twin, wrapper pipeline_asm_index_elem_byte_sz, * store_retval_pair, or vector children (vector_let_init / var_copy / * binop / simd_try_inline_*). Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function glue_emit_vector_type_let_init_elf_c( arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, type_ref: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_emit_vector_let_init_elf_c * (W 0x73f). FORCE mega T smash first-won leftover W (`sub $0x13a8`). * leftover gcc vector_type_let_init (w732 W 0x2c5) CALLs leftover gcc this * face for ARRAY_LIT. Thin fixed_array_copy / arr_struct_lit_arrlit * export-extern (no body) — still localize. Mega same-TU remaining callers: 1. * Do not leftover-first skip_heavy, skip_heavy_or_thin_stub parent, * rax_plus_rbx_scaled, local_slot rbx twin, wrapper, store_retval_pair, * or other vector children (var_copy / binop / simd_try_inline_*). * Mega must emit U. * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_emit_vector_let_init_elf_c( arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_simd_try_inline_select_call_elf_c * (W 0x691). FORCE mega T smash first-won leftover W (`sub $0x13f8`). * leftover gcc vector_type_let_init (w732 W 0x2c5) CALLs leftover gcc this * face for CALL/METHOD simd.select. Mega same-TU remaining callers: 0 * (parent leftover-first). No thin defines this symbol — still localize. * Do not leftover-first skip_heavy, skip_heavy_or_thin_stub parent, * rax_plus_rbx_scaled, local_slot rbx twin, wrapper, store_retval_pair, * or other vector children (var_copy / binop / splat / shuffle / fma / * identity / binop2). Mega may not emit U (unused export-extern). * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_simd_try_inline_select_call_elf_c( arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, type_ref: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_simd_try_inline_shuffle_call_elf_c * (W 0x4ca). FORCE mega T smash first-won leftover W (`sub $0xd78`). * leftover gcc vector_type_let_init (w732 W 0x2c5) CALLs leftover gcc this * face for CALL/METHOD simd.shuffle. Mega same-TU remaining callers: 0 * (parent leftover-first). No thin defines this symbol — still localize. * Do not leftover-first skip_heavy, skip_heavy_or_thin_stub parent, * rax_plus_rbx_scaled, local_slot rbx twin, wrapper, store_retval_pair, * or other vector children (var_copy / binop / splat / fma / * identity / binop2). Mega may not emit U (unused export-extern). * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_simd_try_inline_shuffle_call_elf_c( arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, type_ref: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_simd_try_inline_fma3_call_elf_c * (W 0x47e). FORCE mega T smash first-won leftover W (`sub $0xcf8`). * leftover gcc vector_type_let_init (w732 W 0x2c5) CALLs leftover gcc this * face for CALL/METHOD simd.fma. Mega same-TU remaining callers: 0 * (parent leftover-first). No thin defines this symbol — still localize. * Do not leftover-first skip_heavy, skip_heavy_or_thin_stub parent, * rax_plus_rbx_scaled, local_slot rbx twin, wrapper, store_retval_pair, * or other vector children (var_copy / binop / splat / identity / binop2). * Mega may not emit U (unused export-extern). * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_simd_try_inline_fma3_call_elf_c( arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, type_ref: i32 ): i32; /** * G.7: leftover gcc overlay owns pipeline_asm_simd_try_inline_splat_call_elf_c * (W 0x423). FORCE mega T smash first-won leftover W (`sub $0xbb8`). * leftover gcc vector_type_let_init (w732 W 0x2c5) CALLs leftover gcc this * face for CALL/METHOD simd.splat. Mega same-TU remaining callers: 1 * (glue_simd_select_arg_stack_off_c, wrapped unsafe). No thin defines this * symbol — still localize. * Do not leftover-first skip_heavy, skip_heavy_or_thin_stub parent, * rax_plus_rbx_scaled, local_slot rbx twin, wrapper, store_retval_pair, * or other vector children (var_copy / binop / identity / binop2). * Mega may emit U (remaining caller). * PLATFORM: LINUX gold FORCE leftover-weaken — leftover overlay provides the body. */ export extern function pipeline_asm_simd_try_inline_splat_call_elf_c( arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, type_ref: i32 ): i32; /** * G.7: parser_x owns parser_get_module_import_path. * PLATFORM: SHARED — parser_x.o provides the body. */ export extern function parser_get_module_import_path(module: *u8, idx: i32, path_buf: *u8): void; /** * Copy import path at index i into out[0..64) (NUL-terminated) and return path length. * @param module *u8 - opaque AST module; null -> out[0]=0 when out valid, return 0 * @param i i32 - import index (negative / OOB handled by G.7 path_copy / ImportEntry) * @param out *u8 - destination buffer; capacity 64 bytes including NUL; null -> 0 * @return i32 - byte length of path excluding NUL; 0 on null/missing path * wave99 pure Cap residual close: G.7 single product authority for path64 surface. * Body ≡ historical parser_gen: pipeline_module_import_path_copy(..., 64) + scan NUL. * wave110: path_copy storage is pure ImportEntry map (not Cap residual). * PLATFORM: SHARED - parser_gen path64 demoted weak cold twin; product pure hybrid owns. */ #[no_mangle] export function parser_copy_module_import_path64(module: *u8, i: i32, out: *u8): i32;
export extern function pipeline_expr_field_access_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_name_into(
  arena: *u8, expr_ref: i32, out: *u8
): void;
export extern function pipeline_expr_set_field_access_c(
  arena: *u8, expr_ref: i32, base_ref: i32, nm: *u8, nlen: i32
): void;
export extern function pipeline_expr_block_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function ast_ast_block_final_expr_ref(arena: *u8, block_ref: i32): i32;
export extern function typeck_block_expr_value_ref(arena: *u8, block_ref: i32): i32;
export extern function backend_ensure_block_local_slots(ctx: *u8, arena: *u8, block_ref: i32): void;
export extern function pipeline_asm_emit_block_prefix_elf(
  arena: *u8, elf_ctx: *u8, block_ref: i32, ctx: *u8, ta: i32
): i32;
export extern function glue_asm_ctx_set_scope_block(ctx: *u8, block_ref: i32): void;
export extern function backend_enc_add_imm_to_rax_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function backend_enc_load_i32_indirect_to_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function glue_emit_index_eff_addr_scaled_elf_c(
  arena: *u8, elf_ctx: *u8, ix_ref: i32, base_ref: i32, idx_ref: i32,
  ctx: *u8, ta: i32, esz: i32
): i32;

/**
 * Flip bit 31 of the f32 lane already in rax.
 * @param elf_ctx *u8 — emit buffer. The caller has just filled rax.
 * @param ta i32 — 1 arm64, else x86.
 * @return i32 — 0 when rax holds the flipped lane, -1 when an encode fails.
 * The immediate is the same host constant the FLOAT_LIT peel xors into
 * the f64 high half. rbx is scratch. PLATFORM: SHARED.
 */
function lane_f32_xor_sign_rax(elf_ctx: *u8, ta: i32): i32 {
  let rc: i32 = 0;
  unsafe {
    rc = backend_enc_mov_imm32_to_rbx_arch(elf_ctx, 0 - 2147483647 - 1, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_xor_rbx_rax_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  return 0;
}

/**
 * Load one VAR lane into rax.
 * @param arena *u8 — expression arena.
 * @param elf_ctx *u8 — emit buffer.
 * @param var_ref i32 — VAR expr. A missing frame home returns -1.
 * @param lane i32 — lane index.
 * @param esz i32 — lane bytes.
 * @param ctx *u8 — asm ctx.
 * @param ta i32 — 1 arm64, else x86. Arm64 lane slots grow up from rbp.
 * @return i32 — the load encoder result, or -1 when the home is missing.
 * PLATFORM: SHARED.
 */
function lane_f32_load_var_lane(
  arena: *u8, elf_ctx: *u8, var_ref: i32, lane: i32, esz: i32, ctx: *u8, ta: i32
): i32 {
  let off: i32 = 0;
  unsafe {
    off = glue_asm_local_var_stack_off_scoped(arena, ctx, var_ref);
  }
  if (off < 0) {
    return 0 - 1;
  }
  if (ta == 1) {
    unsafe {
      return backend_enc_load_rbp_lane_to_rax_arch(elf_ctx, off + lane * esz, esz, ta);
    }
  }
  unsafe {
    return backend_enc_load_rbp_lane_to_rax_arch(elf_ctx, off - lane * esz, esz, ta);
  }
}

/**
 * Load one FIELD lane into rax.
 * @param arena *u8 — expression arena.
 * @param elf_ctx *u8 — emit buffer.
 * @param field_ref i32 — FIELD expr. No frame home returns -2.
 * @param lane i32 — lane index.
 * @param esz i32 — lane bytes.
 * @param ctx *u8 — asm ctx.
 * @param ta i32 — 1 arm64, else x86. The field helper already applies
 *   lane polarity, so this load does not add lane * esz again.
 * @return i32 — 0 when rax holds the lane, -1 when the load encode
 *   fails, -2 when the field has no frame home.
 * PLATFORM: SHARED.
 */
function lane_f32_load_field_lane(
  arena: *u8, elf_ctx: *u8, field_ref: i32, lane: i32, esz: i32, ctx: *u8, ta: i32
): i32 {
  let off: i32 = 0;
  unsafe {
    off = glue_vector_var_lane_stack_off_elf_c(arena, ctx, field_ref, lane, esz, ta);
  }
  if (off < 0) {
    return 0 - 2;
  }
  unsafe {
    return backend_enc_load_rbp_lane_to_rax_arch(elf_ctx, off, esz, ta);
  }
}

/**
 * Count a leading EXPR_NEG chain.
 * @param arena *u8 — expression arena.
 * @param expr_ref i32 — current expr. Not positive returns 0.
 * @param budget i32 — peels still allowed. The first call passes 128.
 *   Zero stops without reading another node. That stop is only for a
 *   chain that does not end. Every shorter nest is this one function.
 * @return i32 — how many kind-22 nodes were peeled, or -1 when a NEG
 *   has no operand.
 * One call peels one NEG and recurses on that operand. The lane sign
 * is this count modulo 2. Kind 23 is not kind 22 and stops the count.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function lane_f32_neg_depth(arena: *u8, expr_ref: i32, budget: i32): i32 {
  let ko: i32 = 0;
  let op: i32 = 0;
  let n: i32 = 0;
  if (budget <= 0 || expr_ref <= 0) {
    return 0;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  if (ko != 22) {
    return 0;
  }
  unsafe {
    op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  }
  if (op <= 0) {
    return 0 - 1;
  }
  n = lane_f32_neg_depth(arena, op, budget - 1);
  if (n < 0) {
    return n;
  }
  return n + 1;
}

/**
 * Expr under n leading EXPR_NEG nodes.
 * @param arena *u8 — expression arena.
 * @param expr_ref i32 — outer expr.
 * @param n i32 — peels from lane_f32_neg_depth. Zero returns expr_ref.
 * @return i32 — the core expr, or 0 when an operand is missing.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function lane_f32_neg_core(arena: *u8, expr_ref: i32, n: i32): i32 {
  let op: i32 = 0;
  if (n <= 0) {
    return expr_ref;
  }
  if (expr_ref <= 0) {
    return 0;
  }
  unsafe {
    op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  }
  if (op <= 0) {
    return 0;
  }
  return lane_f32_neg_core(arena, op, n - 1);
}

/**
 * True when a NEG count leaves the f32 sign set.
 * @param n i32 — peel count. Zero is even.
 * @return i32 — 1 when n is odd, 0 when n is even.
 * PLATFORM: SHARED.
 */
function lane_f32_neg_is_odd(n: i32): i32 {
  let q: i32 = 0;
  q = n / 2;
  q = q * 2;
  if (n != q) {
    return 1;
  }
  return 0;
}

/**
 * Move one f32 lane immediate for a FLOAT_LIT, or a NEG chain over one.
 * @param arena *u8 — expression arena. Null is not a literal.
 * @param elf_ctx *u8 — emit buffer.
 * @param expr_ref i32 — operand expr.
 * @param ta i32 — 1 arm64, else x86.
 * @return i32 — 1 when w0 holds the f32 bits, 0 when this is not that
 *   shape, -1 when the move fails.
 * The f64 sign bit is xored into the high half before the existing
 * narrow when the peel count is odd. A VAR, a FIELD, a binop, or kind
 * 23 is not kind 1. A chain that does not end within 128 peels leaves
 * the core as kind 22 and returns 0.
 * PLATFORM: SHARED.
 */
function lane_f32_emit_lit_lane(arena: *u8, elf_ctx: *u8, expr_ref: i32, ta: i32): i32 {
  let ko: i32 = 0;
  let op: i32 = 0;
  let neg: i32 = 0;
  let lo: i32 = 0;
  let hi: i32 = 0;
  let bits: i32 = 0;
  let rc: i32 = 0;
  let n: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || expr_ref <= 0) {
    return 0;
  }
  // One recursive peel. The core must be a FLOAT_LIT. PLATFORM: SHARED.
  n = lane_f32_neg_depth(arena, expr_ref, 128);
  if (n < 0) {
    return 0;
  }
  op = lane_f32_neg_core(arena, expr_ref, n);
  if (op <= 0) {
    return 0;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, op);
  }
  if (ko != 1) {
    return 0;
  }
  neg = lane_f32_neg_is_odd(n);
  unsafe {
    lo = pipeline_expr_float_bits_lo_at(arena, op);
    hi = pipeline_expr_float_bits_hi_at(arena, op);
  }
  if (neg != 0) {
    // f64 sign bit. 0x80000000 does not fit in a positive i32 literal.
    hi = hi ^ (0 - 2147483647 - 1);
  }
  unsafe {
    bits = glue_ieee_f64_bits_to_f32_bits(lo, hi);
    rc = backend_enc_mov_imm32_to_w0_arch(elf_ctx, bits, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  return 1;
}

/**
 * Replace a transparent block chain with its value expr.
 * @param arena *u8 — expression arena. Null returns expr_ref.
 * @param expr_ref i32 — current expr. Not positive returns expr_ref.
 * @param budget i32 — blocks still allowed. The first call passes 128.
 *   Zero returns expr_ref without reading. That stop is only for a
 *   chain that does not end. Every shorter nest is this one function.
 * @return i32 — the expr under every transparent `{ e }` and
 *   `unsafe { e }`, or expr_ref when the node is not one of those.
 * One call asks the existing glue_expr_block_transparent_value_ref_at
 * and recurses on that inner expr. This does not walk lets, loops, or
 * statement counts itself. A block with lets makes that helper return
 * 0, so this returns the block unchanged. PLATFORM: SHARED.
 */
function lane_operand_unwrap_block(arena: *u8, expr_ref: i32, budget: i32): i32 {
  let inner: i32 = 0;
  if (budget <= 0) {
    return expr_ref;
  }
  if (arena == (0 as *u8)) {
    return expr_ref;
  }
  if (expr_ref <= 0) {
    return expr_ref;
  }
  unsafe {
    inner = glue_expr_block_transparent_value_ref_at(arena, expr_ref);
  }
  if (inner <= 0) {
    return expr_ref;
  }
  return lane_operand_unwrap_block(arena, inner, budget - 1);
}

/**
 * Keep this field's name and point its base at new_base.
 * @param arena *u8 — expression arena. Null returns without writing.
 * @param field_ref i32 — FIELD expr. Not positive returns without writing.
 * @param new_base i32 — expr that replaces the base. Not positive returns
 *   without writing.
 * The existing pipeline_expr_set_field_access_c keeps the field name.
 * The name buffer dies with this call, before the chain recurses.
 * PLATFORM: SHARED.
 */
function field_chain_retarget(arena: *u8, field_ref: i32, new_base: i32): void {
  let nlen: i32 = 0;
  let name: u8[256] = [];
  if (arena == (0 as *u8)) {
    return;
  }
  if (field_ref <= 0) {
    return;
  }
  if (new_base <= 0) {
    return;
  }
  unsafe {
    nlen = pipeline_expr_field_access_name_len(arena, field_ref);
  }
  if (nlen < 0) {
    nlen = 0;
  }
  if (nlen > 255) {
    nlen = 255;
  }
  unsafe {
    pipeline_expr_field_access_name_into(arena, field_ref, &name[0]);
    pipeline_expr_set_field_access_c(arena, field_ref, new_base, &name[0], nlen);
  }
}

/**
 * Emit one block's lets and return the value expr.
 * @param arena *u8 — expression arena. Null returns -1.
 * @param elf_ctx *u8 — emit buffer. Null returns -1.
 * @param expr_ref i32 — EXPR_BLOCK that unwrap left in place. Not
 *   positive returns -1.
 * @param ctx *u8 — asm function context. Null returns -1.
 * @param ta i32 — 1 arm64, else x86.
 * @return i32 — the block's value expr. -1 when the prefix fails, the
 *   block has no value, or the value is this same expr.
 * This does not emit the value. The caller emits it once: a field
 * retargets onto it, and a lane operand continues on it. The lets use
 * pipeline_asm_emit_block_prefix_elf, the same slots as body_sync.
 * Calling this and the full body_sync on the same block emits the lets
 * twice. A lane walk calls this again for each lane. That stores the
 * same slots again, which is the existing per-lane rematerialize.
 * The prefix restores the caller's asm scope on its way out. This
 * function then publishes br again and does not restore it: the caller
 * emits the value, and that value (a call argument, a binop) must still
 * resolve the lets just emitted. The enclosing body_sync re-asserts its
 * own block before its next statement and restores the scope it saved
 * when it returns. PLATFORM: SHARED.
 */
function lane_emit_block_lets_value_ref(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32
): i32 {
  let br: i32 = 0;
  let fin: i32 = 0;
  let rc: i32 = 0;
  if (arena == (0 as *u8)) {
    return 0 - 1;
  }
  if (elf_ctx == (0 as *u8)) {
    return 0 - 1;
  }
  if (ctx == (0 as *u8)) {
    return 0 - 1;
  }
  if (expr_ref <= 0) {
    return 0 - 1;
  }
  unsafe {
    br = pipeline_expr_block_ref_at(arena, expr_ref);
  }
  if (br <= 0) {
    return 0 - 1;
  }
  unsafe {
    backend_ensure_block_local_slots(ctx, arena, br);
    rc = pipeline_asm_emit_block_prefix_elf(arena, elf_ctx, br, ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    // Prefix restored the caller. Leave this block published so the
    // value emit that follows this return can see the lets above.
    glue_asm_ctx_set_scope_block(ctx, br);
    fin = ast_ast_block_final_expr_ref(arena, br);
  }
  // `unsafe { e }` on a block that also has lets is a region, not
  // final_expr. final_expr stays empty, and returning -1 here drops
  // the lets already written. typeck_block_expr_value_ref is the
  // reader for that region and returns the inner expr. A block that
  // already has a final_expr does not call it. PLATFORM: SHARED.
  if (fin <= 0) {
    unsafe {
      fin = typeck_block_expr_value_ref(arena, br);
    }
  }
  if (fin <= 0) {
    return 0 - 1;
  }
  if (fin == expr_ref) {
    return 0 - 1;
  }
  return fin;
}

/**
 * Emit every nested let-block and return the value under them.
 * @param arena *u8 — expression arena. Null is passed through to the
 *   one-block helper, which returns -1.
 * @param elf_ctx *u8 — emit buffer.
 * @param expr_ref i32 — current expr. A non-block returns expr_ref.
 * @param ctx *u8 — asm function context.
 * @param ta i32 — 1 arm64, else x86.
 * @param budget i32 — blocks still allowed. The first call passes 128.
 *   Zero returns -1 without reading. That stop is only for a chain
 *   that does not end. Every shorter nest is this one function.
 * @return i32 — the expr under the let-blocks, or -1 on failure.
 * One call emits one block's lets and recurses on that block's value.
 * `{ let a; { let b; ~b } }` is this function, not a second walker.
 * PLATFORM: SHARED.
 */
function lane_operand_emit_let_block_chain(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, budget: i32
): i32 {
  let ko: i32 = 0;
  let fin: i32 = 0;
  if (budget <= 0) {
    return 0 - 1;
  }
  if (expr_ref <= 0) {
    return 0 - 1;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  if (ko != 26) {
    return expr_ref;
  }
  fin = lane_emit_block_lets_value_ref(arena, elf_ctx, expr_ref, ctx, ta);
  if (fin <= 0) {
    return 0 - 1;
  }
  return lane_operand_emit_let_block_chain(
    arena, elf_ctx, fin, ctx, ta, budget - 1);
}

/**
 * Point each field in a chain at the value under its base block.
 * @param arena *u8 — expression arena. Null returns 0 without writing.
 * @param elf_ctx *u8 — emit buffer. Used when a base still has lets.
 * @param field_ref i32 — FIELD expr, or a base that is not a field.
 *   Not positive returns 0 without writing.
 * @param ctx *u8 — asm function context. Used when a base still has lets.
 * @param ta i32 — 1 arm64, else x86.
 * @param budget i32 — nodes still allowed. The first call passes 128.
 *   Zero returns 0 without reading. That stop is only for a chain that
 *   does not end. Every shorter nest is this one function.
 * @return i32 — 0 when the chain is retargeted, -1 when a let block
 *   cannot be emitted or has no value expr.
 * One call peels transparent `{ e }` and `unsafe { e }` with
 * lane_operand_unwrap_block. A block that still has lets is not
 * transparent: lane_emit_block_lets_value_ref emits that block's
 * consts, lets, and statements, then this retargets the base at the
 * value expr and recurses. A nested block or a nested field is that
 * same call. The value expr itself is not emitted here.
 * PLATFORM: SHARED.
 */
function field_chain_peel_block(
  arena: *u8, elf_ctx: *u8, field_ref: i32, ctx: *u8, ta: i32, budget: i32
): i32 {
  let base_ref: i32 = 0;
  let inner: i32 = 0;
  let ko: i32 = 0;
  let fin: i32 = 0;
  if (budget <= 0) {
    return 0;
  }
  if (arena == (0 as *u8)) {
    return 0;
  }
  if (field_ref <= 0) {
    return 0;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, field_ref);
  }
  if (ko != 44) {
    return 0;
  }
  unsafe {
    base_ref = pipeline_expr_field_access_base_ref(arena, field_ref);
  }
  if (base_ref <= 0) {
    return 0;
  }
  inner = lane_operand_unwrap_block(arena, base_ref, budget);
  if (inner > 0) {
    if (inner != base_ref) {
      field_chain_retarget(arena, field_ref, inner);
      base_ref = inner;
    }
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, base_ref);
  }
  if (ko == 44) {
    return field_chain_peel_block(arena, elf_ctx, base_ref, ctx, ta, budget - 1);
  }
  if (ko != 26) {
    return 0;
  }
  // EXPR_BLOCK that unwrap left in place still has lets or loops.
  // The helper emits those and returns the value expr. Recurse so
  // `{ let a; { let b; H { v: a + b } } }.v` is the same function.
  fin = lane_emit_block_lets_value_ref(arena, elf_ctx, base_ref, ctx, ta);
  if (fin <= 0) {
    return 0 - 1;
  }
  field_chain_retarget(arena, field_ref, fin);
  return field_chain_peel_block(arena, elf_ctx, field_ref, ctx, ta, budget - 1);
}

/**
 * Materialize a field rvalue, after peeling transparent block bases.
 * @param arena *u8 — expression arena.
 * @param elf_ctx *u8 — emit buffer.
 * @param expr_ref i32 — FIELD expr.
 * @param ctx *u8 — asm ctx.
 * @param ta i32 — 1 arm64, else x86.
 * @param leave_addr i32 — 1 leaves the field address in rax. 0 loads
 *   the field value, which is what the existing body already does.
 * @return i32 — the demoted materializer's result. -99 means it did
 *   not take the call, method, or struct-literal root.
 * The demoted body is the mega materializer (same TU, above). Cap tip
 * product used a link rename; phase1 cold defines __demoted here.
 * This public symbol peels first, then calls demoted. A block with lets
 * is emitted by field_chain_peel_block, which retargets this field at
 * the value expr. The demoted body then emits that value once.
 * Leaving a block as the base used to return -99, and the field fast
 * path then loaded some other slot. If a block is still the base,
 * return -1 so the function is dropped instead of publishing that
 * slot. A peeled struct literal or variable still goes to the demoted
 * body. That body returns -99 when the byte count is above 4096, for
 * a call, a method, and a struct literal alike. The literal writer
 * already accepts a STRUCT_LIT up to 16MB, and the frame walk counts
 * that temp. The product cave at the 4096 compare continues only when
 * the root kind is 45, so a call or a method above 4096 still returns
 * -99. PLATFORM: SHARED. The rename is Mach-O Cap tip only. The cave
 * is MACOS|ARM64.
 */
/* knife256/10.2: Cap tip demoted body lived in mega and was renamed at
 * Cap tip link. Phase1 cold has no that rename (egg inject first-wins the
 * peel wrapper over mega). Ship the mega materializer as __demoted here so
 * the peel wrapper below stays the public symbol. PLATFORM: SHARED.
 */
#[no_mangle]
export function glue_field_access_call_base_rvalue_elf_c__demoted(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, leave_addr: i32): i32 {
  let base_ref: i32 = 0;
  let base_ko: i32 = 0;
  let base_ty: i32 = 0;
  let ret_sz: i32 = 0;
  let alloc_sz: i32 = 0;
  let home: i32 = 0;
  let base_off: i32 = 0;
  let load_sz: i32 = 0;
  let emit_rc: i32 = 0;
  let agg: i32 = 0;
  let materialised: i32 = 0;
  let cur_fa: i32 = 0;
  let chain_depth: i32 = 0;
  let chain_fa: i32[16] = [];
  let chain_n: i32 = 0;
  let ci: i32 = 0;
  let ly: *u8 = 0 as *u8;
  let mod: *u8 = 0 as *u8;
  let next_base: i32 = 0;
  let nsz: i32 = 0;
  let inl: i32 = 0;
  let fo: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8) || expr_ref <= 0) {
    return 0 - 99;
  }
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, expr_ref) != 44) {
      return 0 - 99;
    }
    if (pipeline_expr_field_access_is_enum_variant(arena, expr_ref) != 0) {
      return 0 - 99;
    }
    mod = pipeline_asm_emit_module_ref_c();
  }
  cur_fa = expr_ref;
  base_ref = 0;
  base_ko = 0;
  chain_depth = 0;
  chain_n = 0;
  while (chain_depth < 16) {
    unsafe {
      if (pipeline_expr_field_access_is_enum_variant(arena, cur_fa) != 0) {
        return 0 - 99;
      }
    }
    if (chain_n >= 16) {
      return 0 - 99;
    }
    chain_fa[chain_n] = cur_fa;
    chain_n = chain_n + 1;
    unsafe {
      next_base = pipeline_expr_field_access_base_ref(arena, cur_fa);
    }
    if (next_base <= 0) {
      return 0 - 99;
    }
    unsafe {
      base_ko = pipeline_expr_kind_ord_at(arena, next_base);
    }
    if (base_ko == 48 || base_ko == 49 || base_ko == 45) {
      base_ref = next_base;
      break;
    }
    if (base_ko == 44) {
      cur_fa = next_base;
      chain_depth = chain_depth + 1;
      continue;
    }
    return 0 - 99;
  }
  if (base_ref <= 0 || chain_n <= 0) {
    return 0 - 99;
  }
  unsafe {
    base_ty = pipeline_expr_resolved_type_ref(arena, base_ref);
    ret_sz = 0;
    if (base_ty > 0) {
      ret_sz = glue_type_size_simple(mod, arena, base_ty, 0);
    }
    // CALL=48 METHOD_CALL=49: same callee-return size when type_size missed.
    if (ret_sz <= 0 && (base_ko == 48 || base_ko == 49)) {
      ret_sz = glue_call_return_byte_size_c(arena, base_ref);
    }
    if (ret_sz <= 0 && base_ko == 45) {
      ret_sz = pipeline_expr_struct_lit_value_bytes(arena, mod, base_ref);
    }
    if (ret_sz <= 0 && base_ty > 0) {
      ret_sz = glue_type_named_layout_size_any_module_elf_c(arena, base_ty);
    }
    if (ret_sz <= 0) {
      ret_sz = 8;
    }
    if (base_ty > 0 && ret_sz <= 16) {
      nsz = glue_sysv_dual_gp_byte_size_c(arena, base_ty);
      if (nsz > ret_sz) {
        ret_sz = nsz;
      }
    }
  }
  if (ret_sz > 4096) {
    return 0 - 99;
  }
  if (ret_sz <= 8) {
    alloc_sz = 8;
  } else {
    if (ret_sz <= 16) {
      alloc_sz = 16;
    } else {
      alloc_sz = ret_sz + ((8 - (ret_sz % 8)) % 8);
    }
  }
  unsafe {
    ly = pipeline_asm_ctx_layout(ctx);
  }
  if (ly == (0 as *u8)) {
    return 0 - 1;
  }
  unsafe {
    base_off = pipe_load_i32_le(ly, pipe_asm_ctx_off_next_offset());
  }
  if ((base_off % 8) != 0) {
    base_off = (base_off + 7) / 8 * 8;
  }
  if (ta == 1) {
    home = base_off;
    unsafe {
      pipe_store_i32_le(ly, pipe_asm_ctx_off_next_offset(), base_off + alloc_sz);
    }
  } else {
    home = base_off + alloc_sz;
    unsafe {
      pipe_store_i32_le(ly, pipe_asm_ctx_off_next_offset(), home);
    }
  }
  unsafe {
    glue_align_next_offset(ctx);
  }
  materialised = 0;
  if (base_ko == 45) {
    unsafe {
      if (pipeline_asm_emit_struct_let_init_elf_c(arena, elf_ctx, base_ref, ctx, ta, home) != 0) {
        return 0 - 1;
      }
    }
    materialised = 1;
  }
  // METHOD shares the attempt; inliner returns 0 on kind!=48 then sret/dual-GP.
  if (materialised == 0 && (base_ko == 48 || base_ko == 49)) {
    unsafe {
      inl = try_inline_struct_lit_return_call_to_slot_elf(arena, elf_ctx, base_ref, ctx, ta, home);
    }
    if (inl == 1) {
      materialised = 1;
    }
    if (materialised == 0) {
      unsafe {
        inl = try_inline_const_struct_lit_return_call_to_slot_elf(arena, elf_ctx, base_ref, ctx, ta, home);
      }
      if (inl == 1) {
        materialised = 1;
      }
    }
  }
  if (materialised == 0 && ret_sz > 16) {
    if (ta != 0 && ta != 1) {
      return 0 - 99;
    }
    unsafe {
      if (base_ty > 0) {
        pipeline_asm_set_call_expected_ret_ty_c(base_ty);
      } else {
        pipeline_asm_set_call_expected_ret_ty_c(0);
      }
      if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta) != 0) {
        pipeline_asm_set_call_expected_ret_ty_c(0);
        return 0 - 1;
      }
      if (ta == 0) {
        if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0) {
          pipeline_asm_set_call_expected_ret_ty_c(0);
          return 0 - 1;
        }
        pipeline_asm_emit_set_call_sret_reg_shift_c(1);
      } else {
        if (glue_arm64_mov_x0_to_x8_elf_c(elf_ctx) != 0) {
          pipeline_asm_set_call_expected_ret_ty_c(0);
          return 0 - 1;
        }
      }
      // Cap residual: public expr face (expr_elf_rec is static same-TU only).
      emit_rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, base_ref, ctx, ta);
      pipeline_asm_emit_set_call_sret_reg_shift_c(0);
      pipeline_asm_set_call_expected_ret_ty_c(0);
      if (emit_rc != 0) {
        return 0 - 1;
      }
    }
    materialised = 1;
  } else {
    if (materialised == 0) {
      unsafe {
        emit_rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, base_ref, ctx, ta);
        if (emit_rc != 0) {
          return 0 - 1;
        }
        if (base_ty > 0) {
          if (glue_store_retval_pair_to_rbp_elf_c(mod, arena, elf_ctx, base_ty, home, ta, base_ref, ctx) != 0) {
            return 0 - 1;
          }
        } else {
          if (glue_store_retval_pair_to_rbp_elf_c(mod, arena, elf_ctx, 0, home, ta, base_ref, ctx) != 0) {
            return 0 - 1;
          }
        }
      }
      materialised = 1;
    }
  }
  if (materialised == 0) {
    return 0 - 1;
  }
  unsafe {
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta) != 0) {
      return 0 - 1;
    }
  }
  ci = chain_n - 1;
  while (ci >= 0) {
    unsafe {
      fo = glue_field_access_effective_offset_c(arena, mod, chain_fa[ci]);
    }
    if (fo < 0) {
      fo = 0;
    }
    if (fo != 0) {
      unsafe {
        if (backend_enc_add_imm_to_rax_arch(elf_ctx, fo, ta) != 0) {
          return 0 - 1;
        }
      }
    }
    // Intermediate FIELD only: *T auto-deref. Never peel TYPE_SLICE mid-fat
    // (would break nested by-value slice fields e.g. Split.left.length).
    if (ci > 0) {
      unsafe {
        if (glue_field_chain_mid_auto_deref_ptr_rax_elf_c(arena, elf_ctx, chain_fa[ci], ta) != 0) {
          return 0 - 1;
        }
      }
    }
    ci = ci - 1;
  }
  if (leave_addr != 0) {
    return 0;
  }
  unsafe {
    if (glue_field_access_call_arg_struct_by_addr_elf_c(arena, expr_ref) != 0) {
      return 0;
    }
    // Positive: 9–16B field already dereferenced into the return pair.
    // Zero: scalar load below. PLATFORM: SHARED.
    agg = glue_field_call_arg_try_load_agg_from_rax_elf_c(arena, elf_ctx, expr_ref, ta);
    if (agg < 0) {
      return 0 - 1;
    }
    if (agg > 0) {
      return 0;
    }
    load_sz = pipeline_expr_field_access_load_byte_sz(arena, mod, expr_ref);
    // 记212: TYPE_U32 field → sentinel 40 (zext), not LDRSW.
    {
      let _tr_u32: i32 = 0;
      let _ko_u32: i32 = 0;
      unsafe { _tr_u32 = pipeline_expr_resolved_type_ref(arena, expr_ref); }
      if (_tr_u32 > 0) {
        unsafe { _ko_u32 = pipeline_type_kind_ord_at(arena, _tr_u32); }
        if (_ko_u32 == 3) { load_sz = 40; }
      }
    }
    // Cap residual 4-byte cells: LDRSW (wave1008). Align INDEX/SoA.
    return glue_field_access_emit_scalar_load_from_rax_elf_c(elf_ctx, load_sz, ta);
  }
}

#[no_mangle]
export function glue_field_access_call_base_rvalue_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, leave_addr: i32
): i32 {
  let base_ref: i32 = 0;
  let ko: i32 = 0;
  let rc: i32 = 0;
  rc = field_chain_peel_block(arena, elf_ctx, expr_ref, ctx, ta, 128);
  if (rc != 0) {
    return 0 - 1;
  }
  if (arena != (0 as *u8)) {
    if (expr_ref > 0) {
      unsafe {
        ko = pipeline_expr_kind_ord_at(arena, expr_ref);
      }
      if (ko == 44) {
        unsafe {
          base_ref = pipeline_expr_field_access_base_ref(arena, expr_ref);
        }
        if (base_ref > 0) {
          unsafe {
            ko = pipeline_expr_kind_ord_at(arena, base_ref);
          }
          if (ko == 26) {
            return 0 - 1;
          }
        }
      }
    }
  }
  unsafe {
    return glue_field_access_call_base_rvalue_elf_c__demoted(
      arena, elf_ctx, expr_ref, ctx, ta, leave_addr);
  }
}

/**
 * True when a field chain is rooted at a STRUCT_LIT.
 * @param arena *u8 — expression arena. Null returns 0.
 * @param expr_ref i32 — FIELD, STRUCT_LIT, or a block around one of
 *   those. Not positive returns 0.
 * @param budget i32 — nodes still allowed. The first call passes 128.
 *   Zero returns 0 without reading. That stop is only for a chain
 *   that does not end. Every shorter nest is this one function.
 * @return i32 — 1 when the root is kind 45, else 0.
 * One call peels one transparent block, one FIELD, or one block's
 * value expr, and recurses. A block that has lets is not transparent,
 * so the value expr is read here without emitting. The field
 * materializer emits those lets. A VAR, CALL, or METHOD root returns
 * 0 so the caller does not materialize those. This does not allocate
 * a frame slot and does not walk field offsets. PLATFORM: SHARED.
 */
function lane_field_root_is_struct_lit(arena: *u8, expr_ref: i32, budget: i32): i32 {
  let ko: i32 = 0;
  let cur: i32 = 0;
  let base_ref: i32 = 0;
  let br: i32 = 0;
  let fin: i32 = 0;
  if (budget <= 0) {
    return 0;
  }
  if (arena == (0 as *u8)) {
    return 0;
  }
  if (expr_ref <= 0) {
    return 0;
  }
  cur = lane_operand_unwrap_block(arena, expr_ref, budget);
  if (cur <= 0) {
    return 0;
  }
  if (cur != expr_ref) {
    return lane_field_root_is_struct_lit(arena, cur, budget - 1);
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  if (ko == 45) {
    return 1;
  }
  // EXPR_BLOCK whose value is the struct literal. Lets stay for the
  // materializer. Nested blocks are this same call. PLATFORM: SHARED.
  if (ko == 26) {
    unsafe {
      br = pipeline_expr_block_ref_at(arena, expr_ref);
    }
    if (br <= 0) {
      return 0;
    }
    unsafe {
      fin = ast_ast_block_final_expr_ref(arena, br);
    }
    if (fin <= 0) {
      return 0;
    }
    if (fin == expr_ref) {
      return 0;
    }
    return lane_field_root_is_struct_lit(arena, fin, budget - 1);
  }
  if (ko != 44) {
    return 0;
  }
  unsafe {
    base_ref = pipeline_expr_field_access_base_ref(arena, expr_ref);
  }
  if (base_ref <= 0) {
    return 0;
  }
  return lane_field_root_is_struct_lit(arena, base_ref, budget - 1);
}

/**
 * Load one lane of a STRUCT_LIT field into rax.
 * @param arena *u8 — expression arena. Null returns -2.
 * @param elf_ctx *u8 — emit buffer. Null returns -2.
 * @param field_ref i32 — FIELD expr. A root that is not a STRUCT_LIT
 *   returns -2 and the caller keeps emit_expr.
 * @param lane i32 — lane index. Negative returns -2.
 * @param esz i32 — lane bytes. Anything other than 4 returns -2.
 *   The indirect load is the same signed 32-bit load the frame lane
 *   uses. A wider lane stays on emit_expr.
 * @param ctx *u8 — asm ctx. Null returns -2.
 * @param ta i32 — 1 arm64, else x86.
 * @return i32 — 0 when rax holds the lane, -1 when the materializer
 *   or an encode fails, -2 when this is not a 4-byte STRUCT_LIT field.
 * The existing glue_field_access_call_base_rvalue_elf_c with
 * leave_addr 1 fills the temp and leaves the field address in rax.
 * Lane bytes sit at that address plus lane * esz on every target,
 * because rax is a pointer, not an rbp frame slot. This does not
 * allocate a second home and does not walk field offsets.
 * PLATFORM: SHARED.
 */
function lane_load_struct_lit_field_lane(
  arena: *u8, elf_ctx: *u8, field_ref: i32, lane: i32, esz: i32, ctx: *u8, ta: i32
): i32 {
  let rc: i32 = 0;
  let lit: i32 = 0;
  if (arena == (0 as *u8)) {
    return 0 - 2;
  }
  if (elf_ctx == (0 as *u8)) {
    return 0 - 2;
  }
  if (ctx == (0 as *u8)) {
    return 0 - 2;
  }
  if (field_ref <= 0) {
    return 0 - 2;
  }
  if (lane < 0) {
    return 0 - 2;
  }
  if (esz != 4) {
    return 0 - 2;
  }
  lit = lane_field_root_is_struct_lit(arena, field_ref, 128);
  if (lit != 1) {
    return 0 - 2;
  }
  unsafe {
    rc = glue_field_access_call_base_rvalue_elf_c(
      arena, elf_ctx, field_ref, ctx, ta, 1);
  }
  if (rc == (0 - 99)) {
    return 0 - 2;
  }
  if (rc != 0) {
    return 0 - 1;
  }
  if (lane != 0) {
    unsafe {
      rc = backend_enc_add_imm_to_rax_arch(elf_ctx, lane * esz, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
  }
  unsafe {
    return backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta);
  }
}

/**
 * Frame offset of one lane of an indexed vector.
 * @param arena *u8 — expression arena. Null returns -1.
 * @param ctx *u8 — asm ctx. Null returns -1.
 * @param expr_ref i32 — INDEX, or the VAR / FIELD base under one.
 *   Not positive returns -1.
 * @param lane i32 — lane inside the indexed element. Negative returns -1.
 *   A recursive call on the base passes 0.
 * @param esz i32 — lane bytes. Not positive returns -1. A recursive
 *   call on the base passes the element stride instead.
 * @param ta i32 — 1 arm64, else x86. Arm64 adds the lane. x86 subtracts.
 * @param budget i32 — indexes still allowed. The first call passes 128.
 *   Zero returns -1 without reading. That stop is only for a chain
 *   that does not end. Every shorter nest is this one function.
 * @return i32 — rbp offset of the lane, or -1 when the home is missing,
 *   the index is not an integer literal, or the base is not a VAR,
 *   FIELD, or another such INDEX.
 * One call peels one INDEX. The element stride is the existing
 * pipeline_asm_index_elem_byte_sz_c. The literal value is the existing
 * pipeline_expr_int_val_at. The base home is this function again.
 * A FIELD base uses the existing glue_vector_var_lane_stack_off_elf_c
 * and does not walk fields here. A negative offset is no home, same
 * as the field loader. PLATFORM: SHARED.
 */
function lane_indexed_lane_off(
  arena: *u8, ctx: *u8, expr_ref: i32, lane: i32, esz: i32, ta: i32, budget: i32
): i32 {
  let ko: i32 = 0;
  let cur: i32 = 0;
  let off: i32 = 0;
  let base_ref: i32 = 0;
  let idx_ref: i32 = 0;
  let elem_sz: i32 = 0;
  let imm: i32 = 0;
  let base_off: i32 = 0;
  if (budget <= 0) {
    return 0 - 1;
  }
  if (arena == (0 as *u8)) {
    return 0 - 1;
  }
  if (ctx == (0 as *u8)) {
    return 0 - 1;
  }
  if (expr_ref <= 0) {
    return 0 - 1;
  }
  if (lane < 0) {
    return 0 - 1;
  }
  if (esz <= 0) {
    return 0 - 1;
  }
  cur = lane_operand_unwrap_block(arena, expr_ref, budget);
  if (cur <= 0) {
    return 0 - 1;
  }
  if (cur != expr_ref) {
    return lane_indexed_lane_off(arena, ctx, cur, lane, esz, ta, budget - 1);
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  if (ko == 3) {
    unsafe {
      off = glue_asm_local_var_stack_off_scoped(arena, ctx, expr_ref);
    }
    if (off < 0) {
      return 0 - 1;
    }
    if (ta == 1) {
      return off + lane * esz;
    }
    return off - lane * esz;
  }
  if (ko == 44) {
    unsafe {
      return glue_vector_var_lane_stack_off_elf_c(arena, ctx, expr_ref, lane, esz, ta);
    }
  }
  if (ko != 47) {
    return 0 - 1;
  }
  unsafe {
    base_ref = pipeline_expr_index_base_ref(arena, expr_ref);
    idx_ref = pipeline_expr_index_index_ref(arena, expr_ref);
    elem_sz = pipeline_asm_index_elem_byte_sz_c(arena, expr_ref);
  }
  if (base_ref <= 0) {
    return 0 - 1;
  }
  if (idx_ref <= 0) {
    return 0 - 1;
  }
  if (elem_sz <= 0) {
    return 0 - 1;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, idx_ref);
  }
  if (ko != 0) {
    return 0 - 1;
  }
  unsafe {
    imm = pipeline_expr_int_val_at(arena, idx_ref);
  }
  // Lane 0 of the base is the start of this array. This level then
  // adds the literal element and the caller's lane. PLATFORM: SHARED.
  base_off = lane_indexed_lane_off(arena, ctx, base_ref, 0, elem_sz, ta, budget - 1);
  if (base_off < 0) {
    return 0 - 1;
  }
  if (ta == 1) {
    return base_off + imm * elem_sz + lane * esz;
  }
  return base_off - imm * elem_sz - lane * esz;
}

/**
 * True when an index chain needs the scaled address emitter.
 * @param arena *u8 — expression arena. Null returns 0.
 * @param expr_ref i32 — INDEX, FIELD, or VAR. A transparent block
 *   returns 0. The scaled emitter does not peel blocks.
 * @param budget i32 — nodes still allowed. The first call passes 128.
 *   Zero returns 0 without reading. That stop is only for a chain
 *   that does not end. Every shorter nest is this one function.
 * @param saw_scale i32 — 1 when an outer index was not an integer
 *   literal. The first call passes 0.
 * @return i32 — 1 when a non-literal index sits on a VAR or FIELD
 *   root, else 0. A CALL, METHOD, or STRUCT_LIT root returns 0.
 * One call peels one INDEX or one FIELD and recurses on the base.
 * This does not emit and does not compute a stride. PLATFORM: SHARED.
 */
function lane_index_wants_scaled(
  arena: *u8, expr_ref: i32, budget: i32, saw_scale: i32
): i32 {
  let ko: i32 = 0;
  let cur: i32 = 0;
  let base_ref: i32 = 0;
  let idx_ref: i32 = 0;
  if (budget <= 0) {
    return 0;
  }
  if (arena == (0 as *u8)) {
    return 0;
  }
  if (expr_ref <= 0) {
    return 0;
  }
  cur = lane_operand_unwrap_block(arena, expr_ref, budget);
  if (cur <= 0) {
    return 0;
  }
  if (cur != expr_ref) {
    return 0;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  if (ko == 3) {
    return saw_scale;
  }
  if (ko == 44) {
    unsafe {
      base_ref = pipeline_expr_field_access_base_ref(arena, expr_ref);
    }
    if (base_ref <= 0) {
      return 0;
    }
    return lane_index_wants_scaled(arena, base_ref, budget - 1, saw_scale);
  }
  if (ko != 47) {
    return 0;
  }
  unsafe {
    base_ref = pipeline_expr_index_base_ref(arena, expr_ref);
    idx_ref = pipeline_expr_index_index_ref(arena, expr_ref);
  }
  if (base_ref <= 0) {
    return 0;
  }
  if (idx_ref <= 0) {
    return 0;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, idx_ref);
  }
  if (ko != 0) {
    saw_scale = 1;
  }
  return lane_index_wants_scaled(arena, base_ref, budget - 1, saw_scale);
}

/**
 * Load one lane of an indexed vector into rax.
 * @param arena *u8 — expression arena.
 * @param elf_ctx *u8 — emit buffer.
 * @param expr_ref i32 — INDEX expr.
 * @param lane i32 — lane index.
 * @param esz i32 — lane bytes.
 * @param ctx *u8 — asm ctx.
 * @param ta i32 — 1 arm64, else x86.
 * @return i32 — 0 when rax holds the lane, -1 when the scaled
 *   address or an encode fails, -2 when there is no home.
 * A literal index uses lane_indexed_lane_off. That offset already
 * includes lane polarity, so the frame load does not add lane * esz
 * again. A non-literal index on a VAR or FIELD root calls
 * glue_emit_index_eff_addr_scaled_elf_c. That leaves the element
 * address in rax. Lane bytes sit at that address plus lane * esz,
 * because rax is a pointer, not an rbp frame slot. The element
 * stride is the existing index size, not the lane size. A call base
 * and a block base return -2. PLATFORM: SHARED.
 */
function lane_load_indexed_lane(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, lane: i32, esz: i32, ctx: *u8, ta: i32
): i32 {
  let off: i32 = 0;
  let rc: i32 = 0;
  let want: i32 = 0;
  let base_ref: i32 = 0;
  let idx_ref: i32 = 0;
  let elem_sz: i32 = 0;
  off = lane_indexed_lane_off(arena, ctx, expr_ref, lane, esz, ta, 128);
  if (off >= 0) {
    unsafe {
      return backend_enc_load_rbp_lane_to_rax_arch(elf_ctx, off, esz, ta);
    }
  }
  if (esz != 4) {
    return 0 - 2;
  }
  if (lane < 0) {
    return 0 - 2;
  }
  want = lane_index_wants_scaled(arena, expr_ref, 128, 0);
  if (want != 1) {
    return 0 - 2;
  }
  unsafe {
    base_ref = pipeline_expr_index_base_ref(arena, expr_ref);
    idx_ref = pipeline_expr_index_index_ref(arena, expr_ref);
    elem_sz = pipeline_asm_index_elem_byte_sz_c(arena, expr_ref);
  }
  if (base_ref <= 0) {
    return 0 - 2;
  }
  if (idx_ref <= 0) {
    return 0 - 2;
  }
  if (elem_sz <= 0) {
    return 0 - 2;
  }
  unsafe {
    rc = glue_emit_index_eff_addr_scaled_elf_c(
      arena, elf_ctx, expr_ref, base_ref, idx_ref, ctx, ta, elem_sz);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  if (lane != 0) {
    unsafe {
      rc = backend_enc_add_imm_to_rax_arch(elf_ctx, lane * esz, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
  }
  unsafe {
    return backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta);
  }
}

/**
 * Emit a NEG chain's core lane into rax.
 * @param arena *u8 — expression arena.
 * @param elf_ctx *u8 — emit buffer.
 * @param expr_ref i32 — outer EXPR_NEG, or a transparent block around one.
 * @param lane i32 — lane index.
 * @param esz i32 — lane bytes.
 * @param ctx *u8 — asm ctx.
 * @param ta i32 — 1 arm64, else x86.
 * @param budget i32 — nodes still allowed. The first call passes 128.
 *   Zero returns -2 without reading. That stop is only for a chain
 *   that does not end.
 * @return i32 — 0 when rax holds the lane, -1 when a load or encode
 *   fails, -2 when this chain is not a VAR, FIELD, or add/sub/mul/div.
 *   A missing field home and a chain that does not end also return -2.
 * The peel is lane_f32_neg_depth. An odd count xors the f32 sign.
 * A transparent block around this node, or under the negation chain,
 * is the same lane_operand_unwrap_block recursion. A negation inside
 * that block is this function again, then this chain's sign is applied.
 * Kinds 8..13 and kind 23 return -2 so the caller falls through.
 * PLATFORM: SHARED.
 */
function lane_f32_emit_neg_core(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, lane: i32, esz: i32, ctx: *u8, ta: i32,
  budget: i32
): i32 {
  let n: i32 = 0;
  let core: i32 = 0;
  let peeled: i32 = 0;
  let cur: i32 = 0;
  let ko: i32 = 0;
  let rc: i32 = 0;
  let left_ref: i32 = 0;
  let right_ref: i32 = 0;
  let odd: i32 = 0;
  if (budget <= 0) {
    return 0 - 2;
  }
  cur = lane_operand_unwrap_block(arena, expr_ref, budget);
  if (cur <= 0) {
    return 0 - 2;
  }
  if (cur != expr_ref) {
    return lane_f32_emit_neg_core(
      arena, elf_ctx, cur, lane, esz, ctx, ta, budget - 1);
  }
  n = lane_f32_neg_depth(arena, expr_ref, budget);
  if (n <= 0) {
    return 0 - 2;
  }
  core = lane_f32_neg_core(arena, expr_ref, n);
  if (core <= 0) {
    return 0 - 2;
  }
  odd = lane_f32_neg_is_odd(n);
  // The value under the negation may itself be { e } or unsafe { e }.
  // A negation inside that block is this function again. The sign of
  // this chain is applied after that, because the two counts add.
  // PLATFORM: SHARED.
  peeled = lane_operand_unwrap_block(arena, core, budget);
  if (peeled <= 0) {
    return 0 - 2;
  }
  if (peeled != core) {
    unsafe {
      ko = pipeline_expr_kind_ord_at(arena, peeled);
    }
    if (ko == 22) {
      rc = lane_f32_emit_neg_core(
        arena, elf_ctx, peeled, lane, esz, ctx, ta, budget - 1);
      if (rc != 0) {
        return rc;
      }
      if (odd != 0) {
        return lane_f32_xor_sign_rax(elf_ctx, ta);
      }
      return 0;
    }
    core = peeled;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, core);
  }
  if (ko == 3) {
    rc = lane_f32_load_var_lane(arena, elf_ctx, core, lane, esz, ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    if (odd != 0) {
      return lane_f32_xor_sign_rax(elf_ctx, ta);
    }
    return 0;
  }
  // No VAR frame is -2. A STRUCT_LIT root then loads from the
  // temp the existing materializer already filled. Still -2 falls
  // through. PLATFORM: SHARED.
  if (ko == 44) {
    rc = lane_f32_load_field_lane(arena, elf_ctx, core, lane, esz, ctx, ta);
    if (rc == (0 - 2)) {
      rc = lane_load_struct_lit_field_lane(
        arena, elf_ctx, core, lane, esz, ctx, ta);
    }
    if (rc == (0 - 2)) {
      return 0 - 2;
    }
    if (rc != 0) {
      return 0 - 1;
    }
    if (odd != 0) {
      return lane_f32_xor_sign_rax(elf_ctx, ta);
    }
    return 0;
  }
  // INDEX=47. No literal home is -2 and falls through. PLATFORM: SHARED.
  if (ko == 47) {
    rc = lane_load_indexed_lane(arena, elf_ctx, core, lane, esz, ctx, ta);
    if (rc == (0 - 2)) {
      return 0 - 2;
    }
    if (rc != 0) {
      return 0 - 1;
    }
    if (odd != 0) {
      return lane_f32_xor_sign_rax(elf_ctx, ta);
    }
    return 0;
  }
  // Kinds 8..13 are not 4..7. Kind 23 does not enter. PLATFORM: SHARED.
  rc = 0;
  if (ko == 4) {
    rc = 1;
  }
  if (ko == 5) {
    rc = 1;
  }
  if (ko == 6) {
    rc = 1;
  }
  if (ko == 7) {
    rc = 1;
  }
  if (rc == 0) {
    return 0 - 2;
  }
  unsafe {
    left_ref = pipeline_expr_binop_left_ref_at(arena, core);
    right_ref = pipeline_expr_binop_right_ref_at(arena, core);
  }
  unsafe {
    rc = glue_emit_vector_lane_scalar_binop_elf_c(
      arena, elf_ctx, ko, left_ref, right_ref, lane, esz, ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  if (odd != 0) {
    return lane_f32_xor_sign_rax(elf_ctx, ta);
  }
  return 0;
}

/**
 * 1 when a bitwise complement of this lane must sign-extend.
 * @param arena *u8 — expression arena. Null returns 0.
 * @param ctx *u8 — asm ctx. Forwarded to the signed-lane helper.
 * @param expr_ref i32 — current expr. Not positive returns 0.
 * @param budget i32 — nodes still allowed. The first call passes 128.
 *   Zero returns 0 without reading. That stop is only for a chain
 *   that does not end.
 * @return i32 — 1 when the lane is a signed i32, 0 otherwise.
 * One call asks the existing pipeline_lane_shr_is_arith. A transparent
 * block is replaced first by lane_operand_unwrap_block, so the sign
 * is the inner value's sign. A negation or a bitwise not has often no
 * resolved type, so a 0 walks to the operand and asks again. A lane
 * binop walks to its left. Kind 51 does not. A u32 name stays 0, so
 * the complement is left zero-extended. This does not copy the
 * spelling test. PLATFORM: SHARED.
 */
function lane_i32_not_is_signed(arena: *u8, ctx: *u8, expr_ref: i32, budget: i32): i32 {
  let ko: i32 = 0;
  let op: i32 = 0;
  let signed_lane: i32 = 0;
  let left_ref: i32 = 0;
  let arith: i32 = 0;
  let step: i32 = 0;
  let cur: i32 = 0;
  if (budget <= 0) {
    return 0;
  }
  if (arena == (0 as *u8)) {
    return 0;
  }
  if (expr_ref <= 0) {
    return 0;
  }
  cur = lane_operand_unwrap_block(arena, expr_ref, budget);
  if (cur <= 0) {
    return 0;
  }
  if (cur != expr_ref) {
    return lane_i32_not_is_signed(arena, ctx, cur, budget - 1);
  }
  unsafe {
    signed_lane = pipeline_lane_shr_is_arith(arena, ctx, expr_ref, 0);
  }
  if (signed_lane != 0) {
    return 1;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  if (ko == 22) {
    step = 1;
  }
  if (ko == 23) {
    step = 1;
  }
  if (step != 0) {
    unsafe {
      op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    }
    if (op <= 0) {
      return 0;
    }
    return lane_i32_not_is_signed(arena, ctx, op, budget - 1);
  }
  arith = 0;
  unsafe {
    arith = glue_is_vector_lane_scalar_binop_ko(ko);
  }
  if (ko == 51) {
    arith = 0;
  }
  if (arith != 0) {
    unsafe {
      left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    }
    if (left_ref <= 0) {
      return 0;
    }
    return lane_i32_not_is_signed(arena, ctx, left_ref, budget - 1);
  }
  return 0;
}

/**
 * Emit one i32 negation or bitwise-not chain into rax.
 * @param arena *u8 — expression arena.
 * @param elf_ctx *u8 — emit buffer.
 * @param expr_ref i32 — current expr. The first call is the outer
 *   kind 22 or kind 23.
 * @param lane i32 — lane index.
 * @param esz i32 — lane bytes. Caller passes 4.
 * @param ctx *u8 — asm ctx.
 * @param ta i32 — 1 arm64, else x86.
 * @param budget i32 — nodes still allowed. The first call passes 128.
 *   Zero returns -2 without reading. That stop is only for a chain
 *   that does not end.
 * @return i32 — 0 when rax holds the lane, -1 when a load or encode
 *   fails, -2 when the core is not a VAR, FIELD, or a lane scalar
 *   binop of kinds 4..13. An INT_LIT core returns -2 so the existing
 *   literal path stays. A missing field home returns -2. Kind 24
 *   returns -2. A block whose lets were emitted and whose value this
 *   core does not handle returns -1, so the caller does not emit the
 *   unary again.
 * One call peels one node and recurses on its operand, then applies
 * this node on the way out. A transparent block is not a negation or
 * a complement: lane_operand_unwrap_block replaces it, then this walk
 * continues on the inner value. A block with lets is
 * lane_emit_block_lets_value_ref, then this same call on the value.
 * Nested blocks are that call. Negation and bitwise not do not
 * commute, so the walk
 * does not count them apart. Kind 23 emits the existing not encoder.
 * A signed i32 complement is then sign-extended: mvn w0 zeros the
 * high half, and the lane div is sdiv x0. A u32 complement is not
 * sign-extended. Kind 22 emits neg w0 and then the existing
 * sign-extend, matching the previous odd negation. Kinds 4..13 use
 * the existing lane binop. Kind 51 is not applied. This is not the
 * f32 sign-bit xor. The f32 gate must be 0 here. PLATFORM: SHARED.
 */
function lane_i32_emit_neg_core(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, lane: i32, esz: i32, ctx: *u8, ta: i32,
  budget: i32
): i32 {
  let ko: i32 = 0;
  let op: i32 = 0;
  let rc: i32 = 0;
  let left_ref: i32 = 0;
  let right_ref: i32 = 0;
  let arith: i32 = 0;
  let step: i32 = 0;
  let signed_lane: i32 = 0;
  let cur: i32 = 0;
  let fin: i32 = 0;
  if (budget <= 0) {
    return 0 - 2;
  }
  if (expr_ref <= 0) {
    return 0 - 2;
  }
  cur = lane_operand_unwrap_block(arena, expr_ref, budget);
  if (cur <= 0) {
    return 0 - 2;
  }
  if (cur != expr_ref) {
    return lane_i32_emit_neg_core(
      arena, elf_ctx, cur, lane, esz, ctx, ta, budget - 1);
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  if (ko == 22) {
    step = 22;
  }
  if (ko == 23) {
    step = 23;
  }
  if (step != 0) {
    unsafe {
      op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    }
    if (op <= 0) {
      return 0 - 1;
    }
    rc = lane_i32_emit_neg_core(
      arena, elf_ctx, op, lane, esz, ctx, ta, budget - 1);
    if (rc != 0) {
      return rc;
    }
    if (step == 23) {
      // mvn w0 zeros the high half. Sign-extend only a signed i32
      // so u32 ~4 / 2 stays the zero-extended quotient.
      // PLATFORM: SHARED.
      unsafe {
        rc = backend_enc_not_eax_arch(elf_ctx, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      signed_lane = lane_i32_not_is_signed(arena, ctx, expr_ref, 128);
      if (signed_lane != 0) {
        unsafe {
          return glue_enc_sxt_i32_result_to_rax_elf_c(elf_ctx, ta);
        }
      }
      return 0;
    }
    // neg w0 zeros the high half. The following lane div is sdiv x0.
    // Sign-extend so a negative lane stays negative. PLATFORM: SHARED.
    unsafe {
      rc = backend_enc_neg_eax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      return glue_enc_sxt_i32_result_to_rax_elf_c(elf_ctx, ta);
    }
  }
  // EXPR_BLOCK that unwrap left in place still has lets or loops.
  // The existing helper emits those lets and returns the value expr.
  // This same function then walks that value, so ~{ let k; k + k }
  // and a block nested under another block are one call. The value
  // itself is not emitted here. If that walk returns -2, the lets are
  // already in the frame: return -1 so the caller does not emit this
  // unary a second time. PLATFORM: SHARED.
  if (ko == 26) {
    fin = lane_emit_block_lets_value_ref(arena, elf_ctx, expr_ref, ctx, ta);
    if (fin <= 0) {
      return 0 - 1;
    }
    rc = lane_i32_emit_neg_core(
      arena, elf_ctx, fin, lane, esz, ctx, ta, budget - 1);
    if (rc == (0 - 2)) {
      return 0 - 1;
    }
    return rc;
  }
  if (ko == 3) {
    rc = lane_f32_load_var_lane(arena, elf_ctx, expr_ref, lane, esz, ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    return 0;
  }
  if (ko == 44) {
    rc = lane_f32_load_field_lane(arena, elf_ctx, expr_ref, lane, esz, ctx, ta);
    if (rc == (0 - 2)) {
      rc = lane_load_struct_lit_field_lane(
        arena, elf_ctx, expr_ref, lane, esz, ctx, ta);
    }
    if (rc == (0 - 2)) {
      return 0 - 2;
    }
    if (rc != 0) {
      return 0 - 1;
    }
    return 0;
  }
  // INDEX=47. No home is -2 and keeps emit_expr.
  // PLATFORM: SHARED.
  if (ko == 47) {
    rc = lane_load_indexed_lane(arena, elf_ctx, expr_ref, lane, esz, ctx, ta);
    if (rc == (0 - 2)) {
      return 0 - 2;
    }
    if (rc != 0) {
      return 0 - 1;
    }
    return 0;
  }
  // Kinds 4..13, including mod, shifts, and, or, xor. Kind 51 stays
  // out. INT_LIT and kind 24 return -2. PLATFORM: SHARED.
  arith = 0;
  unsafe {
    arith = glue_is_vector_lane_scalar_binop_ko(ko);
  }
  if (ko == 51) {
    arith = 0;
  }
  if (arith == 0) {
    return 0 - 2;
  }
  unsafe {
    left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
  }
  unsafe {
    rc = glue_emit_vector_lane_scalar_binop_elf_c(
      arena, elf_ctx, ko, left_ref, right_ref, lane, esz, ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  return 0;
}

/**
 * Emit one vector operand lane into rax.
 * @param arena *u8 — expression arena. Null returns -1.
 * @param elf_ctx *u8 — emit buffer. Null returns -1.
 * @param expr_ref i32 — operand. Not positive returns -1.
 * @param lane i32 — lane index. Negative returns -1.
 * @param esz i32 — lane bytes. A FLOAT_LIT narrows only when this is 4
 *   and the f32-literal gate is set.
 * @param ctx *u8 — asm ctx. Null returns -1.
 * @param ta i32 — 1 arm64, else x86. Arm64 lane slots grow up from rbp.
 * @return i32 — 0 when rax holds the lane, -1 on failure.
 * VAR, FIELD, ARRAY_LIT, and nested binop match the previous body.
 * A chain of negation or bitwise not over a VAR, a FIELD, or a lane
 * scalar binop (kinds 4..13) is one recursion. A transparent block
 * around that operand is lane_operand_unwrap_block, then this function
 * again on the inner value, so `{ e }`, nested blocks, and unsafe { e }
 * share the arms below. A block that still has lets is
 * lane_operand_emit_let_block_chain: one recursion emits each block's
 * lets and this function then loads the value expr. When the f32
 * gate is set, an odd negation count xors the f32 sign and kinds 8..13
 * stay out of that xor. When the gate is 0, each negation is neg w0
 * then a sign-extend, and each bitwise not uses the existing not
 * encoder. A signed i32 complement is sign-extended so the 64-bit lane
 * div sees it. A u32 complement is not. A FLOAT_LIT chain is the
 * literal peel above. An i32 INT_LIT chain stays on emit_expr. Kind 24
 * and a chain that does not end stay on emit_expr. PLATFORM: SHARED.
 */
#[no_mangle]
export function glue_emit_vector_operand_lane_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, lane: i32, esz: i32, ctx: *u8, ta: i32
): i32 {
  let ko: i32 = 0;
  let elem_ref: i32 = 0;
  let left_ref: i32 = 0;
  let right_ref: i32 = 0;
  let rc: i32 = 0;
  let lit: i32 = 0;
  let cur: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8) || expr_ref <= 0 || lane < 0) {
    return 0 - 1;
  }
  // One recursion. The helper already stripped every transparent
  // block, so this tail call sees the inner kind. PLATFORM: SHARED.
  cur = lane_operand_unwrap_block(arena, expr_ref, 128);
  if (cur <= 0) {
    return 0 - 1;
  }
  if (cur != expr_ref) {
    return glue_emit_vector_operand_lane_elf_c(
      arena, elf_ctx, cur, lane, esz, ctx, ta);
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  // EXPR_BLOCK that unwrap left in place still has lets or loops.
  // One recursion emits those lets and returns the value expr. This
  // tail call then uses the arms below, so i32 and f32 share it.
  // `{ let a; { let b; ~b } } / 2` is that one function. The value is
  // not emitted by the helper. PLATFORM: SHARED.
  if (ko == 26) {
    cur = lane_operand_emit_let_block_chain(
      arena, elf_ctx, expr_ref, ctx, ta, 128);
    if (cur <= 0) {
      return 0 - 1;
    }
    return glue_emit_vector_operand_lane_elf_c(
      arena, elf_ctx, cur, lane, esz, ctx, ta);
  }
  // Gate is 1 for an f32 dest on add, sub, mul, div, and compare.
  // A 4-byte FLOAT_LIT is then the f32 pattern, not the f64 bits.
  // i32 lanes skip this.
  // PLATFORM: SHARED.
  if (esz == 4) {
    unsafe {
      lit = glue_lane_f32_lit_dest_get();
    }
    if (lit != 0) {
      lit = lane_f32_emit_lit_lane(arena, elf_ctx, expr_ref, ta);
      if (lit == 1) {
        return 0;
      }
      if (lit < 0) {
        return 0 - 1;
      }
      // One recursive peel. An odd count xors the f32 sign.
      // -2 falls through: no field home, kind 23, kinds 8..13, or a
      // chain that does not end. i32 leaves the gate at 0.
      // PLATFORM: SHARED.
      if (ko == 22) {
        rc = lane_f32_emit_neg_core(
          arena, elf_ctx, expr_ref, lane, esz, ctx, ta, 128);
        if (rc != (0 - 2)) {
          return rc;
        }
      }
    }
  }
  // i32 lane. The f32 gate stays 0, so the sign-xor peel did not run.
  // One recursion walks kind 22 and kind 23 from the inside out.
  // Kind 22 is neg w0 then sign-extend. Kind 23 is the existing not
  // encoder, then a sign-extend only for a signed i32 lane. Kind 51,
  // kind 24, and an INT_LIT core return -2 and keep the existing path.
  // PLATFORM: SHARED.
  if (ko == 22) {
    if (esz == 4) {
      unsafe {
        lit = glue_lane_f32_lit_dest_get();
      }
      if (lit == 0) {
        rc = lane_i32_emit_neg_core(
          arena, elf_ctx, expr_ref, lane, esz, ctx, ta, 128);
        if (rc != (0 - 2)) {
          return rc;
        }
      }
    }
  }
  if (ko == 23) {
    if (esz == 4) {
      unsafe {
        lit = glue_lane_f32_lit_dest_get();
      }
      if (lit == 0) {
        rc = lane_i32_emit_neg_core(
          arena, elf_ctx, expr_ref, lane, esz, ctx, ta, 128);
        if (rc != (0 - 2)) {
          return rc;
        }
      }
    }
  }
  if (ko == 3) {
    return lane_f32_load_var_lane(arena, elf_ctx, expr_ref, lane, esz, ctx, ta);
  }
  // FIELD=44. The helper's offset already includes lane polarity.
  // No VAR frame tries the STRUCT_LIT temp. Still no home falls
  // through. PLATFORM: SHARED.
  if (ko == 44) {
    rc = lane_f32_load_field_lane(arena, elf_ctx, expr_ref, lane, esz, ctx, ta);
    if (rc == (0 - 2)) {
      rc = lane_load_struct_lit_field_lane(
        arena, elf_ctx, expr_ref, lane, esz, ctx, ta);
    }
    if (rc != (0 - 2)) {
      return rc;
    }
  }
  // INDEX=47. The offset already includes the lane. No literal home
  // falls through. PLATFORM: SHARED.
  if (ko == 47) {
    rc = lane_load_indexed_lane(arena, elf_ctx, expr_ref, lane, esz, ctx, ta);
    if (rc != (0 - 2)) {
      return rc;
    }
  }
  if (ko == 46) {
    unsafe {
      elem_ref = pipeline_expr_array_lit_elem_ref(arena, expr_ref, lane);
    }
    if (elem_ref == 0) {
      unsafe {
        return backend_enc_mov_imm32_to_w0_arch(elf_ctx, 0, ta);
      }
    }
    if (esz == 4) {
      unsafe {
        lit = glue_lane_f32_lit_dest_get();
      }
      if (lit != 0) {
        lit = lane_f32_emit_lit_lane(arena, elf_ctx, elem_ref, ta);
        if (lit == 1) {
          return 0;
        }
        if (lit < 0) {
          return 0 - 1;
        }
      }
    }
    unsafe {
      return pipeline_asm_emit_expr_elf_c(arena, elf_ctx, elem_ref, ctx, ta);
    }
  }
  unsafe {
    rc = glue_is_vector_lane_scalar_binop_ko(ko);
  }
  if (rc != 0) {
    unsafe {
      left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
      right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    }
    unsafe {
      return glue_emit_vector_lane_scalar_binop_elf_c(
        arena, elf_ctx, ko, left_ref, right_ref, lane, esz, ctx, ta);
    }
  }
  unsafe {
    return pipeline_asm_emit_expr_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  }
}
