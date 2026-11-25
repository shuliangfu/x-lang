/* Source-faithful w1521_emit_method_body twin
 * (compiler/src/asm/backend_call_dispatch.x, committed HEAD
 * wrapper + w1521_emit_method_body_tail, lines 4923-6217, plus the
 * same-TU helpers the typool image inlined into that one body:
 * w1521_emit_method_early, w1521_try_emit_method_field_fn, and the
 * small w1521_method_base_* / emit_*_method_base helpers at
 * lines 4614-4922). No typool global leftover exists for those
 * helpers; they are compiled in this TU rather than stubbed.
 * typool leftover backend_call_dispatch_w1521_emit_method_body
 * T 0x140425d7c on the s169 no-ASLR image lowers `let name: u8[256] = []`
 * as lea rbx,[rbp-0x98] then 256 byte stores [rbx+0]..[rbx+0xff]
 * (0x140425e6c-0x140426466). That range is [rbp-0x98, rbp+0x67] and
 * includes the incoming return at [rbp+8]. The stores that wipe the
 * live typool w1521_body return (body+0x8a = 0x1404410ea at 0x103f4128)
 * are [rbx+0xa0]..[rbx+0xa7]. typool did allocate 0xd038 (including the
 * 16384-byte pad, which HEAD touches only at [0] and does not =[]),
 * but the lea for name[] is only 0x98 below rbp. Host-cc memset /
 * empty-array initialization for =[] slots stays in-frame. Do not
 * invent a stub, do not hardcode names or byte positions, and do not
 * change typool source. docs-only .x, do not idx8.
 * typool exports this function as backend_call_dispatch_w1521_emit_method_body
 * (same-TU prefix). The thin uses that name so first-wins lowest VA
 * wins over the typool leftover.
 */
#include <stdint.h>
#include <string.h>

int32_t backend_enc_add_rax_rbx_arch(uint8_t * elf, int32_t ta);
int32_t backend_enc_blr_arch(uint8_t * elf, int32_t reg, int32_t ta);
int32_t backend_enc_call_stack_cleanup_arch(uint8_t * elf, int32_t nbytes, int32_t ta);
int32_t backend_enc_call_stack_reserve_arch(uint8_t * elf, int32_t nbytes, int32_t ta);
int32_t backend_enc_ldr_xreg_xreg_imm_arch(uint8_t * elf, int32_t dst, int32_t base, int32_t off, int32_t ta);
int32_t backend_enc_load_rbp_to_rax_arch(uint8_t * elf, int32_t off, int32_t ta);
int32_t backend_enc_mov_eax_to_xmm_arg_reg_arch(uint8_t * elf, int32_t k, int32_t ta);
int32_t backend_enc_mov_imm32_to_w0_arch(uint8_t * elf, int32_t imm, int32_t ta);
int32_t backend_enc_mov_rax_to_arg_reg_arch(uint8_t * elf, int32_t k, int32_t ta);
int32_t backend_enc_mov_rax_to_rbx_arch(uint8_t * elf, int32_t ta);
int32_t backend_enc_mov_rax_to_xmm_arg_reg_arch(uint8_t * elf, int32_t k, int32_t ta);
int32_t backend_enc_mov_xmm_arg_reg_to_eax_arch(uint8_t * elf_ctx, int32_t k, int32_t ta);
int32_t backend_enc_mov_xmm_arg_reg_to_rax_arch(uint8_t * elf_ctx, int32_t k, int32_t ta);
int32_t backend_enc_push_rax_arch(uint8_t * elf, int32_t ta);
int32_t backend_enc_store_arg_sp_offset_arch(uint8_t * elf, int32_t off_bytes, int32_t nbytes, int32_t ta);
int32_t backend_enc_store_x_reg_to_rbp_arch(uint8_t * elf, int32_t reg, int32_t off, int32_t ta);
int32_t call_dispatch_load_i32_le(uint8_t * p, int32_t off);
uint8_t * call_dispatch_load_ptr_le(uint8_t * p, int32_t off);
void call_dispatch_store_i32_le(uint8_t * p, int32_t off, int32_t v);
int32_t codegen_find_impl_method_for_type(uint8_t * module, uint8_t * arena, uint8_t * method_name, int32_t method_name_len, int32_t receiver_type_ref);
int32_t backend_call_dispatch_glue_aapcs64_arg_is_byref_c(uint8_t * arena, uint8_t * ctx, int32_t ty, int32_t sz);
int32_t backend_call_dispatch_glue_aapcs64_hfa_nregs_c(uint8_t * arena, uint8_t * ctx, int32_t ty);
int32_t backend_call_dispatch_glue_arg_ref_is_f64_width_c(uint8_t * arena, uint8_t * ctx, int32_t arg_ref, int32_t pty);
int32_t backend_call_dispatch_glue_arg_ref_is_sse_float_c(uint8_t * arena, int32_t arg_ref, int32_t pty);
int32_t glue_asm_build_func_export_sym_c(uint8_t * m, uint8_t * a, int32_t func_ix, uint8_t * out, int32_t out_cap);
int32_t glue_asm_call_reg_max(int32_t ta);
int32_t glue_asm_call_stack_cleanup_bytes(int32_t ta, int32_t nargs);
int32_t glue_asm_enc_call_redirected(uint8_t * elf_ctx, uint8_t * name, int32_t name_len, int32_t ta);
int32_t glue_asm_fill_c_prefix_from_module_import(uint8_t * mod, int32_t ix, uint8_t * pre);
int32_t glue_asm_harvest_call_ret_to_gpr_c(uint8_t * arena, uint8_t * elf_ctx, int32_t call_expr_ref, int32_t ta);
int32_t glue_asm_import_binding_name_equal(uint8_t * mod, int32_t ix, uint8_t * nm, int32_t nlen);
int32_t glue_asm_mangle_import_binding_call_sym_c(uint8_t * arena, uint8_t * ctx, int32_t expr_ref, uint8_t * mod_ref, int32_t imp_j, uint8_t * pre_buf, int32_t pre_len, uint8_t * field_name, int32_t field_len, int32_t is_method, uint8_t * sym_flat);
int32_t glue_asm_try_emit_fmt_any_import_call_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t call_expr_ref, uint8_t * ctx, int32_t ta, uint8_t * pre_buf, int32_t pre_len, uint8_t * field_name, int32_t field_len);
int32_t glue_asm_try_emit_fmt_string_lit_import_call_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t call_expr_ref, uint8_t * ctx, int32_t ta, uint8_t * pre_buf, int32_t pre_len, uint8_t * field_name, int32_t field_len);
int32_t glue_call_param_type_ref_at(uint8_t * arena, int32_t call, int32_t pix);
int32_t backend_call_dispatch_glue_call_stk_extra_advance(int32_t pos, int32_t nbytes, int32_t ta);
int32_t backend_call_dispatch_glue_call_stk_extra_align(int32_t pos, int32_t nbytes, int32_t ta);
int32_t backend_call_dispatch_glue_emit_arm64_host_mem_arg_addr_to_rax_c(uint8_t * arena, uint8_t * elf_ctx, uint8_t * ctx, int32_t arg_ref, int32_t sz, int32_t ta);
int32_t glue_emit_one_call_arg_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t call_expr_ref, int32_t arg_ref, int32_t arg_index, uint8_t * ctx, int32_t ta);
int32_t glue_sysv_arg_byte_size_c(uint8_t * arena, uint8_t * ctx, int32_t pty, int32_t arg_ref);
int32_t glue_sysv_arg_gp_units_from_size_c(int32_t sz);
int32_t backend_call_dispatch_glue_sysv_arg_is_memory_by_value_c(int32_t sz);
int32_t backend_call_dispatch_glue_sysv_arg_stack_words_c(int32_t sz, int32_t gp_units);
int32_t backend_call_dispatch_glue_sysv_load_spill_to_arg_regs_elf_c(uint8_t * elf, int32_t ta, int32_t spill_off, int32_t gp, int32_t gp_units);
int32_t backend_call_dispatch_glue_sysv_push_int_stack_arg_elf_c(uint8_t * elf, int32_t ta, int32_t gp_units);
int32_t backend_call_dispatch_glue_sysv_spill_rax_rdx_to_frame_c(uint8_t * elf, uint8_t * ctx, int32_t ta, int32_t gp_units);
uint8_t * link_abi_getenv(uint8_t * name);
int32_t link_abi_host_is_windows(void);
int32_t parser_get_module_num_imports(uint8_t * mod);
int32_t pipeline_asm_call_return_type_kind_ord_c(uint8_t * arena, int32_t call_expr_ref);
int32_t pipeline_asm_emit_call_sret_reg_shift_c(void);
uint8_t * pipeline_asm_emit_dep_pipe_c(void);
int32_t pipeline_asm_emit_expr_elf_for_call_args(uint8_t * arena, uint8_t * elf, int32_t ar, uint8_t * ctx, int32_t ta);
int32_t pipeline_asm_emit_lvalue_eff_addr_elf_c(uint8_t * a, uint8_t * elf, int32_t lr, uint8_t * ctx, int32_t ta);
void pipeline_asm_module_func_name_copy64(uint8_t * m, int32_t fi, uint8_t * dst);
int32_t pipeline_asm_module_func_name_len_at(uint8_t * m, int32_t fi);
int32_t pipeline_asm_push_sysv_memory_by_value_elf_c(uint8_t * arena, uint8_t * elf, uint8_t * ctx, int32_t arg_ref, int32_t sz, int32_t ta);
int32_t pipeline_asm_store_memory_by_value_to_sp_elf_c(uint8_t * arena, uint8_t * elf, uint8_t * ctx, int32_t arg_ref, int32_t sz, int32_t ta, int32_t sp_off);
int32_t pipeline_codegen_call_num_args_override(uint8_t * pre, int32_t plen, uint8_t * field, int32_t flen, int32_t nargs);
uint8_t * pipeline_dep_ctx_arena_at(uint8_t * dep, int32_t j);
uint8_t * pipeline_dep_ctx_module_at(uint8_t * dep, int32_t j);
int32_t pipeline_expr_call_resolved_dep_index_at(uint8_t * arena, int32_t call);
int32_t pipeline_expr_call_resolved_func_index_at(uint8_t * arena, int32_t er);
int32_t pipeline_expr_kind_ord_at(uint8_t * arena, int32_t er);
int32_t pipeline_expr_method_call_arg_ref(uint8_t * a, int32_t er, int32_t idx);
int32_t pipeline_expr_method_call_base_ref_at(uint8_t * a, int32_t er);
void pipeline_expr_method_call_name_into(uint8_t * a, int32_t er, uint8_t * out);
int32_t pipeline_expr_method_call_name_len(uint8_t * a, int32_t er);
int32_t pipeline_expr_method_call_num_args_at(uint8_t * a, int32_t er);
int32_t pipeline_expr_resolved_type_ref(uint8_t * a, int32_t er);
void pipeline_expr_var_name_into(uint8_t * arena, int32_t er, uint8_t * out);
int32_t pipeline_expr_var_name_len(uint8_t * arena, int32_t er);
int32_t pipeline_module_func_num_params_at(uint8_t * m, int32_t fi);
int32_t pipeline_module_func_param_type_ref_at(uint8_t * m, int32_t fi, int32_t pi);
int32_t pipeline_module_import_kind_at(uint8_t * m, int32_t j);
int32_t pipeline_module_num_funcs(uint8_t * m);
int32_t pipeline_module_num_struct_layouts_at(uint8_t * m);
void pipeline_module_struct_layout_field_name_into(uint8_t * m, int32_t li, int32_t j, uint8_t * out);
int32_t pipeline_module_struct_layout_field_name_len(uint8_t * m, int32_t li, int32_t j);
int32_t pipeline_module_struct_layout_field_offset_at(uint8_t * m, int32_t li, int32_t j);
int32_t pipeline_module_struct_layout_field_type_ref(uint8_t * m, int32_t li, int32_t j);
void pipeline_module_struct_layout_name_into(uint8_t * m, int32_t idx, uint8_t * out);
int32_t pipeline_module_struct_layout_name_len(uint8_t * m, int32_t idx);
int32_t pipeline_module_struct_layout_num_fields(uint8_t * m, int32_t li);
int32_t pipeline_type_elem_ref_at(uint8_t * a, int32_t tr);
int32_t pipeline_type_kind_ord_at(uint8_t * arena, int32_t type_ref);
int32_t pipeline_type_named_name_into(uint8_t * a, int32_t tr, uint8_t * out);
int32_t pipeline_typeck_type_refs_equal_c(uint8_t * a, int32_t x, int32_t y);
int32_t try_call_wpo_mono_symbol_elf(uint8_t * a, uint8_t * elf, int32_t er, uint8_t * ctx, int32_t ta);
int32_t try_call_wpo_mono_vector_lane_of_binop_call_elf(uint8_t * a, uint8_t * elf, int32_t er, uint8_t * ctx, int32_t ta);
int32_t backend_call_dispatch_try_emit_atomic_builtin_call_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta);
int32_t backend_call_dispatch_try_emit_raw_syscall_call_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta);
int32_t backend_call_dispatch_try_emit_simd_lang_builtin_call_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta);
int32_t backend_call_dispatch_try_emit_va_cap_builtin_call_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta);
int32_t try_inline_param0_field_sum_call_elf(uint8_t * a, uint8_t * elf, int32_t er, uint8_t * ctx, int32_t ta);
int32_t try_inline_param0_single_field_call_elf(uint8_t * a, uint8_t * elf, int32_t er, uint8_t * ctx, int32_t ta);
int32_t try_inline_wpo_const_scalar_binop_call_elf(uint8_t * a, uint8_t * elf, int32_t er, uint8_t * ctx, int32_t ta);
int32_t try_inline_wpo_const_vector_lane_of_binop_call_elf(uint8_t * a, uint8_t * elf, int32_t er, uint8_t * ctx, int32_t ta);
int32_t try_inline_x_plus_k_call_elf(uint8_t * a, uint8_t * elf, int32_t er, uint8_t * ctx, int32_t ta);
int32_t backend_call_dispatch_w1521_callee_is_xlang(uint8_t * arena, int32_t expr_ref);
int32_t backend_call_dispatch_w1545_pend_is(int32_t expr_ref);
int32_t backend_call_dispatch_w1545_pend_rcx_emit(uint8_t * elf_ctx, int32_t expr_ref);
int32_t backend_call_dispatch_w1546_park_call_sret_arg0(uint8_t * elf_ctx, uint8_t * ctx, int32_t ta);
int32_t backend_call_dispatch_w1546_reload_call_sret_arg0(uint8_t * elf_ctx, int32_t park, int32_t ta);
void w1547_win_place_float(int32_t * gp_inout, int32_t * out_use_xmm, int32_t * out_slot);

static int32_t w1521_emit_method_early(uint8_t *arena, uint8_t *elf_ctx, int32_t expr_ref, uint8_t *ctx, int32_t ta);
static int32_t w1521_try_emit_method_field_fn(uint8_t *arena, uint8_t *elf_ctx, int32_t expr_ref, uint8_t *ctx, int32_t ta);
static int32_t w1521_emit_method_body_tail(uint8_t *arena, uint8_t *elf_ctx, int32_t expr_ref, uint8_t *ctx, int32_t ta);
static int32_t w1521_method_base_ref(uint8_t *arena, int32_t expr_ref);
static int32_t w1521_method_base_nz(uint8_t *arena, int32_t expr_ref);
static int32_t w1521_method_base_gt0(uint8_t *arena, int32_t expr_ref);
static int32_t w1521_method_base_kind_ord(uint8_t *arena, int32_t expr_ref);
static int32_t w1521_method_base_var_name_len(uint8_t *arena, int32_t expr_ref);
static int32_t w1521_method_base_var_name_into(uint8_t *arena, int32_t expr_ref, uint8_t *dst);
static int32_t w1521_method_base_resolved_type(uint8_t *arena, int32_t expr_ref);
static int32_t w1521_emit_lvalue_method_base(uint8_t *arena, uint8_t *elf_ctx, int32_t expr_ref, uint8_t *ctx, int32_t ta);
static int32_t w1521_emit_expr_method_base(uint8_t *arena, uint8_t *elf_ctx, int32_t expr_ref, uint8_t *ctx, int32_t ta);
static int32_t w1521_glue_emit_one_call_arg_method_base(uint8_t *arena, uint8_t *elf_ctx, int32_t expr_ref, uint8_t *ctx, int32_t ta);

static int32_t w1521_emit_method_early(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta) {
  if (arena == ((uint8_t *)0)) { return 0 - 1; }
  if (elf_ctx == 0) { return 0 - 1; }
  if (ctx == ((uint8_t *)0)) { return 0 - 1; }
  {
    int32_t nargs = pipeline_expr_method_call_num_args_at(arena, expr_ref);
    if (nargs < 0) { return 0 - 1; }
    if (nargs > 96) { return 0 - 1; }
    int32_t name_len = pipeline_expr_method_call_name_len(arena, expr_ref);
    if (name_len <= 0) { return 0 - 1; }
    if (name_len > 255) { return 0 - 1; }
    uint8_t name[256]; memset(name, 0, sizeof(name));
    pipeline_expr_method_call_name_into(arena, expr_ref, &name[0]);
    int32_t rs_mc = backend_call_dispatch_try_emit_raw_syscall_call_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    if (rs_mc < 0) { return 0 - 1; }
    if (rs_mc > 0) { return 1; }
    int32_t va_mc = backend_call_dispatch_try_emit_va_cap_builtin_call_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    if (va_mc < 0) { return 0 - 1; }
    if (va_mc > 0) { return 1; }
    int32_t at_mc = backend_call_dispatch_try_emit_atomic_builtin_call_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    if (at_mc < 0) { return 0 - 1; }
    if (at_mc > 0) { return 1; }
    int32_t sd_mc = backend_call_dispatch_try_emit_simd_lang_builtin_call_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    if (sd_mc < 0) { return 0 - 1; }
    if (sd_mc > 0) { return 1; }
    return 0;
  }
  return 0 - 1;
}

// typool of w1521_emit_method_body_tail stores method base_ref at one slot
// (-0x1e8) and later passes/compares a different uninitialized slot (-0x4050,
// live 246). The same class stored ff_ok = 0 in the -0x1f8 cluster and then
// set/compared ff_ok at -0x4b10, so the Cap/TYPE_FN field arm fired on
// leftover stack garbage. Compute those scalars in small-frame helpers;
// typool of `if (helper() != 0)` uses %eax, and each helper stores and
// passes the same slot.
static int32_t w1521_method_base_ref(uint8_t * arena, int32_t expr_ref) {
  {

    return pipeline_expr_method_call_base_ref_at(arena, expr_ref);
  }
  return 0;
}

static int32_t w1521_method_base_nz(uint8_t * arena, int32_t expr_ref) {
  {

    int32_t br = pipeline_expr_method_call_base_ref_at(arena, expr_ref);
    if (br != 0) { return 1; }
    return 0;
  }
  return 0;
}

static int32_t w1521_method_base_gt0(uint8_t * arena, int32_t expr_ref) {
  {

    int32_t br = pipeline_expr_method_call_base_ref_at(arena, expr_ref);
    if (br > 0) { return 1; }
    return 0;
  }
  return 0;
}

static int32_t w1521_method_base_kind_ord(uint8_t * arena, int32_t expr_ref) {
  {

    int32_t br = pipeline_expr_method_call_base_ref_at(arena, expr_ref);
    return pipeline_expr_kind_ord_at(arena, br);
  }
  return 0;
}

static int32_t w1521_method_base_var_name_len(uint8_t * arena, int32_t expr_ref) {
  {

    int32_t br = pipeline_expr_method_call_base_ref_at(arena, expr_ref);
    return pipeline_expr_var_name_len(arena, br);
  }
  return 0;
}

static int32_t w1521_method_base_var_name_into(uint8_t * arena, int32_t expr_ref, uint8_t * dst) {
  {

    int32_t br = pipeline_expr_method_call_base_ref_at(arena, expr_ref);
    pipeline_expr_var_name_into(arena, br, dst);
    return br;
  }
  return 0;
}

static int32_t w1521_method_base_resolved_type(uint8_t * arena, int32_t expr_ref) {
  {

    int32_t br = pipeline_expr_method_call_base_ref_at(arena, expr_ref);
    return pipeline_expr_resolved_type_ref(arena, br);
  }
  return 0;
}

static int32_t w1521_emit_lvalue_method_base(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta) {
  {

    int32_t br = pipeline_expr_method_call_base_ref_at(arena, expr_ref);
    return pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, br, ctx, ta);
  }
  return 0 - 1;
}

static int32_t w1521_emit_expr_method_base(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta) {
  {

    int32_t br = pipeline_expr_method_call_base_ref_at(arena, expr_ref);
    return pipeline_asm_emit_expr_elf_for_call_args(arena, elf_ctx, br, ctx, ta);
  }
  return 0 - 1;
}

static int32_t w1521_glue_emit_one_call_arg_method_base(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta) {
  {

    int32_t br = pipeline_expr_method_call_base_ref_at(arena, expr_ref);
    return glue_emit_one_call_arg_elf_c(arena, elf_ctx, expr_ref, br, 0, ctx, ta);
  }
  return 0 - 1;
}

// Cap/TYPE_FN field method arm. idx8 tail typool stored ff_ok init and
// base_ref in one band and later compared/passed different slots, so
// is_none_i32 entered this arm with r8=246 into emit_lvalue. Keep this
// helper's frame small: same-slot scalars, return -1 / 1 emitted / 0
// fall through (including stack-arg Cap, which must keep UFCS).
static int32_t w1521_try_emit_method_field_fn(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta) {
  {

    if (arena == ((uint8_t *)0)) { return 0 - 1; }
    if (elf_ctx == 0) { return 0 - 1; }
    if (ctx == ((uint8_t *)0)) { return 0 - 1; }
    uint8_t * mod_ref = call_dispatch_load_ptr_le(ctx, 16);
    int32_t nargs = pipeline_expr_method_call_num_args_at(arena, expr_ref);
    int32_t base_ref = pipeline_expr_method_call_base_ref_at(arena, expr_ref);
    int32_t name_len = pipeline_expr_method_call_name_len(arena, expr_ref);
    uint8_t name[256]; memset(name, 0, sizeof(name));
    pipeline_expr_method_call_name_into(arena, expr_ref, &name[0]);
    /*
     * 10.3.3 slice3: METHOD_CALL `h.f(args)` when `f` is Cap/TYPE_FN field.
     * typeck stamps ret; emit loads field into rax/x0 then Cap blr (no self arg).
     * G.7: reuse spill / emit_expr_for_call_args / mov_rax_to_arg_reg / blr.
     * PLATFORM: SHARED · LINUX x86_64 call *r · MACOS|ARM64 blr.
     */
    {
      int32_t ff_base_ty = 0;
      int32_t ff_ty = 0;
      int32_t ff_ko = 0;
      int32_t ff_er = 0;
      int32_t ff_eko = 0;
      int32_t ff_ok = 0;
      int32_t ff_nlen = 0;
      int32_t ff_li = 0;
      int32_t ff_nf = 0;
      int32_t ff_j = 0;
      int32_t ff_fnl = 0;
      int32_t ff_foff = 0;
      int32_t ff_hit = 0;
      int32_t ff_eq = 0;
      int32_t ff_k = 0;
      int32_t ff_nlays = 0;
      int32_t ff_fi = 0;
      int32_t ff_spill = 0;
      int32_t ff_reg_max = 0;
      uint8_t ff_nm[256]; memset(ff_nm, 0, sizeof(ff_nm));
      uint8_t ff_fnm[256]; memset(ff_fnm, 0, sizeof(ff_fnm));
      uint8_t ff_lnm[256]; memset(ff_lnm, 0, sizeof(ff_lnm));
      ff_base_ty = pipeline_expr_resolved_type_ref(arena, base_ref);
      if (ff_base_ty > 0) {
        ff_ty = ff_base_ty;
        ff_ko = pipeline_type_kind_ord_at(arena, ff_ty);
        if (ff_ko == 9) {
          ff_er = pipeline_type_elem_ref_at(arena, ff_ty);
          if (ff_er > 0) {
            ff_ty = ff_er;
            ff_ko = pipeline_type_kind_ord_at(arena, ff_ty);
          }
        }
        if (ff_ko == 8 && mod_ref != ((uint8_t *)0)) {
          ff_nlen = pipeline_type_named_name_into(arena, ff_ty, &ff_nm[0]);
          if (ff_nlen > 0 && ff_nlen <= 255) {
            ff_nlays = pipeline_module_num_struct_layouts_at(mod_ref);
            ff_li = 0;
            while (ff_li < ff_nlays && ff_hit == 0) {
              int32_t ln = pipeline_module_struct_layout_name_len(mod_ref, ff_li);
              ff_eq = 1;
              if (ln != ff_nlen) {
                ff_eq = 0;
              } else {
                pipeline_module_struct_layout_name_into(mod_ref, ff_li, &ff_lnm[0]);
                ff_k = 0;
                while (ff_k < ff_nlen) {
                  if (ff_lnm[ff_k] != ff_nm[ff_k]) {
                    ff_eq = 0;
                  }
                  ff_k = ff_k + 1;
                }
              }
              if (ff_eq != 0) {
                ff_nf = pipeline_module_struct_layout_num_fields(mod_ref, ff_li);
                ff_j = 0;
                while (ff_j < ff_nf && ff_hit == 0) {
                  ff_fnl = pipeline_module_struct_layout_field_name_len(mod_ref, ff_li, ff_j);
                  if (ff_fnl == name_len && ff_fnl > 0 && ff_fnl <= 255) {
                    pipeline_module_struct_layout_field_name_into(mod_ref, ff_li, ff_j, &ff_fnm[0]);
                    ff_eq = 1;
                    ff_k = 0;
                    while (ff_k < ff_fnl) {
                      if (ff_fnm[ff_k] != name[ff_k]) {
                        ff_eq = 0;
                      }
                      ff_k = ff_k + 1;
                    }
                    if (ff_eq != 0) {
                      ff_er = pipeline_module_struct_layout_field_type_ref(mod_ref, ff_li, ff_j);
                      ff_foff = pipeline_module_struct_layout_field_offset_at(mod_ref, ff_li, ff_j);
                      ff_hit = 1;
                    }
                  }
                  ff_j = ff_j + 1;
                }
              }
              ff_li = ff_li + 1;
            }
          }
        }
        if (ff_hit != 0 && ff_er > 0) {
          ff_ko = pipeline_type_kind_ord_at(arena, ff_er);
          if (ff_ko == 18) {
            ff_ok = 1;
          } else if (ff_ko == 9) {
            int32_t ff_pointee = pipeline_type_elem_ref_at(arena, ff_er);
            if (ff_pointee > 0) {
              ff_eko = pipeline_type_kind_ord_at(arena, ff_pointee);
              if (ff_eko == 2) {
                ff_ok = 1;
              }
            }
          }
        }
        if (ff_ok != 0) {
          /* rax = &receiver; load field qword at offset. */
          if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, base_ref, ctx, ta) != 0) {
            return 0 - 1;
          }
          if (backend_enc_ldr_xreg_xreg_imm_arch(elf_ctx, 0, 0, ff_foff, ta) != 0) {
            return 0 - 1;
          }
          if (nargs == 0) {
            if (backend_enc_blr_arch(elf_ctx, 0, ta) != 0) { return 0 - 1; }
            return 1;
          }
          ff_reg_max = glue_asm_call_reg_max(ta);
          if (ff_reg_max < 1) { ff_reg_max = 6; }
          if (nargs > ff_reg_max) {
            /* Stack-arg Cap via METHOD_CALL residual — keep UFCS fallthrough. */
            ff_ok = 0;
          }
        }
        if (ff_ok != 0 && nargs > 0) {
          ff_spill = backend_call_dispatch_glue_sysv_spill_rax_rdx_to_frame_c(elf_ctx, ctx, ta, 1);
          if (ff_spill < 0) { return 0 - 1; }
          ff_fi = 0;
          while (ff_fi < nargs) {
            int32_t ff_ar = pipeline_expr_method_call_arg_ref(arena, expr_ref, ff_fi);
            if (ff_ar <= 0) { return 0 - 1; }
            if (pipeline_asm_emit_expr_elf_for_call_args(arena, elf_ctx, ff_ar, ctx, ta) != 0) {
              return 0 - 1;
            }
            if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, ff_fi, ta) != 0) {
              return 0 - 1;
            }
            ff_fi = ff_fi + 1;
          }
          /* PLATFORM: MACOS|ARM64 uses non-arg volatile scratch x9 (ta==1)
           * so reloading the fn ptr does not clobber argument x0. SysV x86_64
           * uses rax (ta==0) as rax is not an argument register. */
          if (ta == 1) {
            if (backend_enc_ldr_xreg_xreg_imm_arch(elf_ctx, 9, 29, ff_spill, ta) != 0) {
              return 0 - 1;
            }
            if (backend_enc_blr_arch(elf_ctx, 9, ta) != 0) { return 0 - 1; }
          } else {
            if (backend_enc_load_rbp_to_rax_arch(elf_ctx, ff_spill, ta) != 0) {
              return 0 - 1;
            }
            if (backend_enc_blr_arch(elf_ctx, 0, ta) != 0) { return 0 - 1; }
          }
          return 1;
        }
      }
    }
    return 0;
  }
  return 0 - 1;
}

// Hooked symbol: keep this a small-frame wrapper so typool's 3-way on `st`
// stores and compares the same slot. Heavy work is in early + field-fn +
// tail. Field-fn must not stay in the large tail: typool passed the wrong
// base_ref slot (246) and compared the wrong ff_ok slot.
int32_t backend_call_dispatch_w1521_emit_method_body(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta) {
  if (arena == ((uint8_t *)0)) { return 0 - 1; }
  if (elf_ctx == 0) { return 0 - 1; }
  if (ctx == ((uint8_t *)0)) { return 0 - 1; }
  int32_t st = w1521_emit_method_early(arena, elf_ctx, expr_ref, ctx, ta);
  if (st < 0) { return 0 - 1; }
  if (st > 0) { return 0; }
  st = w1521_try_emit_method_field_fn(arena, elf_ctx, expr_ref, ctx, ta);
  if (st < 0) { return 0 - 1; }
  if (st > 0) { return 0; }
  return w1521_emit_method_body_tail(arena, elf_ctx, expr_ref, ctx, ta);
}

static int32_t w1521_emit_method_body_tail(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta) {
  if (arena == ((uint8_t *)0)) { return 0 - 1; }
  if (elf_ctx == 0) { return 0 - 1; }
  if (ctx == ((uint8_t *)0)) { return 0 - 1; }
  {
    // note743y.5: tip frame was 0x18e8 while locals used to -0x34b0 (SEGV in
    // import METHOD). Pad so tip-emitted prologue covers nested spill arrays.
    // Official typool of `u8[16384] = []` unrolls 256 zero-bytes from a
    // shallow -0x98(%rbp) through saved rbx/rbp and the return address
    // (option/SI build SIGSEGV RIP=0 after emit_method_body). Keep the
    // pad allocation; do not zero-init the whole array. Touch only [0].
    uint8_t _frame_pad_y5_m[16384];
    _frame_pad_y5_m[0] = 0;
    uint8_t * mod_ref = call_dispatch_load_ptr_le(ctx, 16);
    /** Product parses core.xlang_io_submit_*_batch as METHOD_CALL with >5 args; seed _impl is authority. */
    // nargs/name_len/try_emit early-outs already ran in w1521_emit_method_early
    // (small frame). Re-fetch scalars and the name buffer for later uses here.
    int32_t nargs = pipeline_expr_method_call_num_args_at(arena, expr_ref);
    int32_t base_ref = pipeline_expr_method_call_base_ref_at(arena, expr_ref);
    int32_t name_len = pipeline_expr_method_call_name_len(arena, expr_ref);
    uint8_t name[256]; memset(name, 0, sizeof(name));
    pipeline_expr_method_call_name_into(arena, expr_ref, &name[0]);
    // Cap/TYPE_FN field-fn arm lives in w1521_try_emit_method_field_fn
    // (small frame). The wrapper already ran it and 3-way-branched.
    // wave359: bootstrap i32.double → 2*x when not UFCS-resolved free fn.
    int32_t r_fn = pipeline_expr_call_resolved_func_index_at(arena, expr_ref);
    /*
     * F7: dyn Trait dispatch via vtable indirect call.
     * typeck sets call_resolved_dep_index = DYN_DISPATCH_DEP_SENTINEL (-2) when
     * the receiver is TYPE_DYN (kind=17), and stores the trait method slot
     * index in call_resolved_func_index (r_fn here). The dyn_obj layout is
     * { void* data; void* vtable; } (16 bytes), so:
     *   1. receiver addr in x0 (base_ref expression emit)
     *   2. ldr x1, [x0, #8]      — x1 = dyn_obj.vtable
     *   3. ldr x2, [x1, #slot*8] — x2 = vtable[slot] (wrapper fn ptr)
     *   4. ldr x0, [x0, #0]      — x0 = dyn_obj.data (self arg to wrapper)
     *   5. extras: GP 1..(reg_max-1) and/or xmm0–7 (x86 SysV); overflow
     *      extras go on the stack (UFCS/CALL same SysV/AAPCS words)
     *   6. blr x2 (or scratch)   — indirect call through wrapper fn ptr
     * Extra args must be packed after data: `x.add(3)` is wrapper(data, 3);
     * `x.add(3.0)` f64 is wrapper(data) + xmm0 (SysV). Do NOT use
     * glue_emit_one_call_arg here — resolved_func_index is the vtable slot,
     * not an impl func, so formal lookup would alias func[slot].
     * G.7: emit_expr_elf_for_call_args + backend_call_dispatch_glue_arg_ref_is_sse_float_c
     * (same classifier as UFCS leave; xmm only when ta==0 — local callee)
     * + glue_asm_call_reg_max for the GP file (not a hardcoded 5).
     * Without this branch, dyn calls fall into try_inline_param0_single_field_call_elf
     * which reads dyn_obj.data low 4 bytes as a value → SIGBUS on later blr.
     */
    int32_t dep_idx = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
    if (dep_idx == -2) {
      int32_t slot = r_fn;
      if (slot < 0) { return 0 - 1; }
      /*
       * Emit extras first (x0 not live yet), spill each to the frame.
       * Classify SSE from the extra expr (FLOAT_LIT / resolved f32/f64).
       * Cannot look up impl formals: r_fn is the vtable slot.
       * GP file after self: 1..reg_max-1 (x86=5, ARM64=7). Overflow → stack.
       * PLATFORM: LINUX x86_64 SysV xmm · MACOS ARM64 extras stay GP.
       */
      int32_t extra_off[96]; memset(extra_off, 0, sizeof(extra_off));
      int32_t is_sse_e[96]; memset(is_sse_e, 0, sizeof(is_sse_e));
      int32_t is_f64_e[96]; memset(is_f64_e, 0, sizeof(is_f64_e));
      int32_t place_e[96]; memset(place_e, 0, sizeof(place_e));
      int32_t on_stk_e[96]; memset(on_stk_e, 0, sizeof(on_stk_e));
      int32_t sz_e[96]; memset(sz_e, 0, sizeof(sz_e));
      int32_t xmm_cur = 0;
      int32_t gp_cur = 1;
      int32_t n_stk = 0;
      int32_t reg_max_e = glue_asm_call_reg_max(ta);
      if (reg_max_e < 2) { reg_max_e = 6; }
      int32_t ei = 0;
      while (ei < nargs) {
        extra_off[ei] = 0 - 1;
        is_sse_e[ei] = 0;
        is_f64_e[ei] = 0;
        place_e[ei] = 0;
        on_stk_e[ei] = 0;
        /* wave614: arg byte size for the natural stack-extras cursor.
           +1 skips self: the impl method's param table has self at 0 while
           this loop's ei counts user args (self rides x0 separately). */
        sz_e[ei] = 8;
        int32_t arg_ex = pipeline_expr_method_call_arg_ref(arena, expr_ref, ei);
        if (arg_ex == 0) { return 0 - 1; }
        {
          int32_t pty_e = glue_call_param_type_ref_at(arena, expr_ref, ei + 1);
          int32_t sz_ei = glue_sysv_arg_byte_size_c(arena, ctx, pty_e, arg_ex);
          if (sz_ei > 0) {
            sz_e[ei] = sz_ei;
          }
        }
        /* PLATFORM: LINUX|x86_64 SysV — f32/f64 extras go xmm0–7 then stack.
         * PLATFORM: MACOS|ARM64 AAPCS64 — f32 and f64 extras take v-slots.
         * Param home reads kind 14 and kind 15 from sK/dK, so a named f32
         * in a GP misses the formal. */
        if (ta == 0) {
          is_sse_e[ei] = backend_call_dispatch_glue_arg_ref_is_sse_float_c(arena, arg_ex, 0);
          is_f64_e[ei] = backend_call_dispatch_glue_arg_ref_is_f64_width_c(arena, ctx, arg_ex, 0);
        } else {
          is_f64_e[ei] = backend_call_dispatch_glue_arg_ref_is_f64_width_c(arena, ctx, arg_ex, 0);
          is_sse_e[ei] = backend_call_dispatch_glue_arg_ref_is_sse_float_c(arena, arg_ex, 0);
          if (is_f64_e[ei] != 0) { is_sse_e[ei] = 1; }
        }
        if (is_sse_e[ei] != 0) {
          // PLATFORM: WINDOWS x86_64 — extras share the positional cursor
          // (self already took slot 0). Slot >= 4 stays off the SysV push
          // list so the GP encoder writes the stack home.
          // PLATFORM: LINUX x86_64 SysV · MACOS|ARM64 AAPCS64 — xmm/v file.
          int32_t win_e = 0;
          if (ta == 0) {
            {
              if (link_abi_host_is_windows() != 0) { win_e = 1; }
            }
          }
          if (win_e != 0) {
            int32_t use_xmm_e = 0;
            int32_t slot_e = 0;
            w1547_win_place_float(&gp_cur, &use_xmm_e, &slot_e);
            place_e[ei] = slot_e;
            if (use_xmm_e == 0) {
              is_sse_e[ei] = 0;
            }
          } else if (xmm_cur < 8) {
            place_e[ei] = xmm_cur;
            xmm_cur = xmm_cur + 1;
          } else {
            on_stk_e[ei] = 1;
            place_e[ei] = n_stk;
            n_stk = n_stk + 1;
          }
        } else {
          if (gp_cur < reg_max_e) {
            place_e[ei] = gp_cur;
            gp_cur = gp_cur + 1;
          } else {
            on_stk_e[ei] = 1;
            place_e[ei] = n_stk;
            n_stk = n_stk + 1;
          }
        }
        if (pipeline_asm_emit_expr_elf_for_call_args(arena, elf_ctx, arg_ex, ctx, ta) != 0) {
          return 0 - 1;
        }
        int32_t so_ex = backend_call_dispatch_glue_sysv_spill_rax_rdx_to_frame_c(elf_ctx, ctx, ta, 1);
        if (so_ex < 0) { return 0 - 1; }
        extra_off[ei] = so_ex;
        ei = ei + 1;
      }
      /* F7: x0 must be &dyn_obj, not the loaded .data word. VAR/lvalue
       * receivers use the existing lvalue-LEA authority (G.7). emit_expr
       * would load the first 8 bytes (data ptr) and [x0,#8] would then
       * read past the concrete payload — SIGSEGV / exit=112 false-green. */
      if (w1521_emit_lvalue_method_base(arena, elf_ctx, expr_ref, ctx, ta) != 0) {
        return 0 - 1;
      }
      /* x0 = &dyn_obj; load vtable ptr from dyn_obj+8 into x1. */
      if (backend_enc_ldr_xreg_xreg_imm_arch(elf_ctx, 1, 0, 8, ta) != 0) { return 0 - 1; }
      /* x1 = vtable; load method slot fn ptr from vtable+slot*8 into x2. */
      if (backend_enc_ldr_xreg_xreg_imm_arch(elf_ctx, 2, 1, slot * 8, ta) != 0) { return 0 - 1; }
      /* x2 = wrapper fn ptr; load data ptr from dyn_obj+0 into x0 (self arg). */
      if (backend_enc_ldr_xreg_xreg_imm_arch(elf_ctx, 0, 0, 0, ta) != 0) { return 0 - 1; }
      /* SysV first arg is rdi, not rax. ARM64 x0 is already arg0. Do not change. */
      if (ta == 0) {
        if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0) { return 0 - 1; }
      }
      if (nargs <= 0) {
        if (backend_enc_blr_arch(elf_ctx, 2, ta) != 0) { return 0 - 1; }
        return 0;
      }
      /* Spill data (rax/x0 still holds the pointer). Extra loads go through rax. */
      int32_t data_off = backend_call_dispatch_glue_sysv_spill_rax_rdx_to_frame_c(elf_ctx, ctx, ta, 1);
      if (data_off < 0) { return 0 - 1; }
      /* nargs>=2 extras occupy rdx/x2; park the fn ptr first. */
      int32_t fn_off = (0 - 1);
      if (nargs >= 2) {
        int32_t cur_fn = call_dispatch_load_i32_le(ctx, 4);
        fn_off = cur_fn + 16;
        if (fn_off < 16) { fn_off = 16; }
        if (backend_enc_store_x_reg_to_rbp_arch(elf_ctx, 2, fn_off, ta) != 0) {
          return 0 - 1;
        }
        call_dispatch_store_i32_le(ctx, 4, fn_off + 16);
      }
      /*
       * Stack extras from spills. x86: pad then push right-to-left (UFCS).
       * ARM64: reserve + store [sp+slot] before GP reload.
       * PLATFORM: LINUX x86_64 SysV push · MACOS|ARM64 AAPCS64 [sp].
       */
      int32_t stk_bytes = 0;
      if (n_stk > 0) {
        if (ta == 0) {
          if ((n_stk & 1) != 0) {
            if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, 0, ta) != 0) { return 0 - 1; }
            if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) { return 0 - 1; }
            stk_bytes = stk_bytes + 8;
          }
          ei = nargs - 1;
          while (ei >= 0) {
            if (on_stk_e[ei] != 0) {
              if (backend_enc_load_rbp_to_rax_arch(elf_ctx, extra_off[ei], ta) != 0) {
                return 0 - 1;
              }
              if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) { return 0 - 1; }
              stk_bytes = stk_bytes + 8;
            }
            ei = ei - 1;
          }
        } else {
          stk_bytes = n_stk * 8;
          stk_bytes = (stk_bytes + 15) & (0 - 16);
          if (backend_enc_call_stack_reserve_arch(elf_ctx, stk_bytes, ta) != 0) {
            return 0 - 1;
          }
          int32_t stk_pos = 0;
          ei = 0;
          while (ei < nargs) {
            if (on_stk_e[ei] != 0) {
              if (backend_enc_load_rbp_to_rax_arch(elf_ctx, extra_off[ei], ta) != 0) {
                return 0 - 1;
              }
              /* wave614: natural-packing cursor (see glue_call_stk_extra_*). */
              int32_t aoff_e = backend_call_dispatch_glue_call_stk_extra_align(stk_pos, sz_e[ei], ta);
              if (backend_enc_store_arg_sp_offset_arch(elf_ctx, aoff_e, sz_e[ei], ta) != 0) {
                return 0 - 1;
              }
              stk_pos = backend_call_dispatch_glue_call_stk_extra_advance(aoff_e, sz_e[ei], ta);
            }
            ei = ei + 1;
          }
        }
      }
      ei = 0;
      while (ei < nargs) {
        if (on_stk_e[ei] == 0) {
          if (is_sse_e[ei] != 0) {
            /* Reload bits then movd/movq into xmm[k] (≡ UFCS leave / seed _impl). */
            if (backend_enc_load_rbp_to_rax_arch(elf_ctx, extra_off[ei], ta) != 0) {
              return 0 - 1;
            }
            if (is_f64_e[ei] != 0) {
              if (backend_enc_mov_rax_to_xmm_arg_reg_arch(elf_ctx, place_e[ei], ta) != 0) {
                return 0 - 1;
              }
            } else if (backend_enc_mov_eax_to_xmm_arg_reg_arch(elf_ctx, place_e[ei], ta) != 0) {
              return 0 - 1;
            }
          } else if (backend_call_dispatch_glue_sysv_load_spill_to_arg_regs_elf_c(elf_ctx, ta, extra_off[ei], place_e[ei], 1) != 0) {
            return 0 - 1;
          }
        }
        ei = ei + 1;
      }
      if (backend_call_dispatch_glue_sysv_load_spill_to_arg_regs_elf_c(elf_ctx, ta, data_off, 0, 1) != 0) {
        return 0 - 1;
      }
      if (nargs >= 2) {
        /* Non-arg scratch: x86 r11 (hw 11) / ARM64 x9. PLATFORM: LINUX x86 · MACOS ARM64. */
        if (ta == 0) {
          if (backend_enc_ldr_xreg_xreg_imm_arch(elf_ctx, 11, 5, 0 - fn_off, ta) != 0) {
            return 0 - 1;
          }
          if (backend_enc_blr_arch(elf_ctx, 11, ta) != 0) { return 0 - 1; }
        } else {
          if (backend_enc_ldr_xreg_xreg_imm_arch(elf_ctx, 9, 29, fn_off, ta) != 0) {
            return 0 - 1;
          }
          if (backend_enc_blr_arch(elf_ctx, 9, ta) != 0) { return 0 - 1; }
        }
      } else {
        /* nargs==1: extra in rsi/x1; fn still in rdx/x2. */
        if (backend_enc_blr_arch(elf_ctx, 2, ta) != 0) { return 0 - 1; }
      }
      if (stk_bytes > 0) {
        if (backend_enc_call_stack_cleanup_arch(elf_ctx, stk_bytes, ta) != 0) {
          return 0 - 1;
        }
      }
      return 0;
    }
    if (r_fn < 0) {
      if (nargs == 0) {
        if (name_len == 6) {
          if (w1521_method_base_nz(arena, expr_ref) != 0) {
            if (name[0] == 100) {
              if (name[1] == 111) {
                if (name[2] == 117) {
                  if (name[3] == 98) {
                    if (name[4] == 108) {
                      if (name[5] == 101) {
                        if (w1521_emit_expr_method_base(arena, elf_ctx, expr_ref, ctx, ta) != 0) {
                          return 0 - 1;
                        }
                        if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) { return 0 - 1; }
                        if (backend_enc_add_rax_rbx_arch(elf_ctx, ta) != 0) { return 0 - 1; }
                        return 0;
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
    if (mod_ref != 0) {
      if (w1521_method_base_gt0(arena, expr_ref) != 0) {
        if (w1521_method_base_kind_ord(arena, expr_ref) == 3) {
          int32_t base_len = w1521_method_base_var_name_len(arena, expr_ref);
          if (base_len > 0) {
            // wave580 Cap: import binding name content cap 255.
            if (base_len <= 255) {
              uint8_t base_name[256]; memset(base_name, 0, sizeof(base_name));
              w1521_method_base_var_name_into(arena, expr_ref, &base_name[0]);
              int32_t j = 0;
              int32_t nimp = parser_get_module_num_imports(mod_ref);
              while (j < nimp) {
                if (pipeline_module_import_kind_at(mod_ref, j) == 1) {
                  if (glue_asm_import_binding_name_equal(mod_ref, j, &base_name[0], base_len) != 0) {
                    uint8_t pre_buf[128]; memset(pre_buf, 0, sizeof(pre_buf));
                    int32_t pre_len = glue_asm_fill_c_prefix_from_module_import(mod_ref, j, &pre_buf[0]);
                    if (pre_len <= 0) { return 0 - 1; }
                    // PLATFORM: SHARED — fmt.println string lit (METHOD_CALL). G.7 seed _impl same leaf.
                    int32_t fmt_lit = glue_asm_try_emit_fmt_string_lit_import_call_elf_c(
                      arena, elf_ctx, expr_ref, ctx, ta, &pre_buf[0], pre_len, &name[0], name_len);
                    if (fmt_lit < 0) { return 0 - 1; }
                    if (fmt_lit > 0) { return 0; }
                    /* PLATFORM: SHARED — fmt.println(composite) JSON any (print_any). */
                    int32_t fmt_any = glue_asm_try_emit_fmt_any_import_call_elf_c(
                      arena, elf_ctx, expr_ref, ctx, ta, &pre_buf[0], pre_len, &name[0], name_len);
                    if (fmt_any < 0) { return 0 - 1; }
                    if (fmt_any > 0) { return 0; }
                    uint8_t sym_flat[256]; memset(sym_flat, 0, sizeof(sym_flat));
                    /*
                     * PLATFORM: SHARED — import METHOD mangle (G.7 ≡ seed).
                     * Bare pre+name → U std_string_length / std_string_is_empty while
                     * string.o exports length_String / is_empty_String. Seed
                     * glue_asm_mangle_import_binding_call_sym_c is authority; pure PREFER
                     * must call the same surface (not bare build).
                     */
                    int32_t sym_len = glue_asm_mangle_import_binding_call_sym_c(
                      arena, ctx, expr_ref, mod_ref, j, &pre_buf[0], pre_len, &name[0], name_len, 1, &sym_flat[0]
                    );
                    if (sym_len <= 0) { return 0 - 1; }
                    int32_t n_ov = pipeline_codegen_call_num_args_override(&pre_buf[0], pre_len, &name[0], name_len, nargs);
                    /*
                     * PLATFORM: SHARED freestanding multi-arg · MACOS|ARM64 AAPCS64 + LINUX x86 SysV.
                     * Root (mac option residual): import-binding METHOD_CALL must spill-then-load
                     * (same as pipeline_asm_emit_call_args_elf_c / seed wave602). Direct place via
                     * x0 temp after nested CALL clobbers Option in x0 (unwrap_or(some(42),0)→0).
                     * Root (run-result 173 residual): pure import METHOD path hard-coded gp_units=1
                     * and used arg index as GP index → Result_i32 (16B INTEGER dual-GP) only packed
                     * lows into x0/x1; host core_result_or_i32 expects x0:x1 + x2:x3 → return -3.
                     * Free CALL already uses size→units + gp_start; import METHOD must match.
                     * Root (run-slice subslice_split_chunks SEGV): pure import METHOD started
                     * gp_cur at 0 while let-init sret had already placed hidden dest in rdi and
                     * set call_sret_reg_shift=1. Args overwrote rdi with arg0 → callee
                     * core_slice_split_at_i32 (sret, slice*, at) read at-as-pointer → SEGV.
                     * Seed twin already starts gp_cur at sret_sh; pure .x must match.
                     * G.7: one discipline for free CALL and import METHOD_CALL (dual-GP + sret).
                     */
                    {
                      int32_t spill_off_m[96]; memset(spill_off_m, 0, sizeof(spill_off_m));
                      int32_t gp_start_m[96]; memset(gp_start_m, 0, sizeof(gp_start_m));
                      int32_t gp_units_m[96]; memset(gp_units_m, 0, sizeof(gp_units_m));
                      // is_mem_m: 0=reg/int, 1=x86 SysV MEMORY stack, 2=arm64 host-indirect lea.
                      int32_t is_mem_m[96]; memset(is_mem_m, 0, sizeof(is_mem_m));
                      int32_t is_sse_m[96]; memset(is_sse_m, 0, sizeof(is_sse_m));
                      int32_t is_f64_m[96]; memset(is_f64_m, 0, sizeof(is_f64_m));
                      int32_t arg_sz_m[96]; memset(arg_sz_m, 0, sizeof(arg_sz_m));
                      int32_t i_m = 0;
                      int32_t mem_stack_m = 0;
                      int32_t xmm_cur_m = 0;
                      // PLATFORM: SHARED — SysV 6 (rdi..r9) / AAPCS64 8 (x0–x7).
                      // Seed twin pipeline_asm_emit_method_call_elf_c_impl must call this
                      // (not hardcode 6): Darwin product L2 is the seed; csv.parse_row's
                      // 7th GP is x6. Free CALL / UFCS already use glue_asm_call_reg_max.
                      int32_t reg_max_m = glue_asm_call_reg_max(ta);
                      // SysV hidden sret consumes rdi (GP0); shift formals by sret_sh.
                      // PLATFORM: SHARED — LINUX+MACOS x86_64 SysV; AAPCS64 uses x8 (sret_sh=0).
                      int32_t sret_sh_m = 0;
                      int32_t sret_park_m = (0 - 2);
                      if (ta == 0) {
                        sret_sh_m = pipeline_asm_emit_call_sret_reg_shift_c();
                        if (sret_sh_m == 0) { sret_sh_m = backend_call_dispatch_w1545_pend_is(expr_ref); }
                        // Same flag scope as free CALL. Nested args must not
                        // inherit rdi/rcx. PLATFORM: LINUX+WINDOWS x86_64.
                        sret_park_m = backend_call_dispatch_w1546_park_call_sret_arg0(elf_ctx, ctx, ta);
                        if (sret_park_m == (0 - 1)) { return 0 - 1; }
                      }
                      int32_t gp_cur_m = sret_sh_m;
                      if (reg_max_m < 1) { reg_max_m = 6; }
                      // w1521: arm64 X-to-X import METHOD (std .x bodies) → stack MEMORY.
                      int32_t x_callee_m = 0;
                      if (ta == 1) {
                        x_callee_m = backend_call_dispatch_w1521_callee_is_xlang(arena, expr_ref);
                      }
                      /*
                       * Classify large POD for import METHOD → host-C std .o (string.o):
                       * - PLATFORM: LINUX|x86_64 SysV — MEMORY by-value on stack (gcc formals
                       *   at [rbp+0x10..]; run-string length(String) residual when lea→rdi).
                       * - PLATFORM: MACOS|ARM64 AAPCS64 — large composite as pointer in GP
                       *   (lea; host-C std_string_length_String takes x0=&String).
                       * Pure→pure UFCS still uses MEMORY stack on its own path (wave602).
                       * G.7: one authority with seed is_mem=1 (x86) / is_mem=2 (arm64).
                       */
                      while (i_m < nargs) {
                        int32_t ar_m = pipeline_expr_method_call_arg_ref(arena, expr_ref, i_m);
                        int32_t pty_m = glue_call_param_type_ref_at(arena, expr_ref, i_m);
                        int32_t sz_m = glue_sysv_arg_byte_size_c(arena, ctx, pty_m, ar_m);
                        int32_t u_m = glue_sysv_arg_gp_units_from_size_c(sz_m);
                        spill_off_m[i_m] = 0 - 1;
                        is_mem_m[i_m] = 0;
                        is_sse_m[i_m] = 0;
                        is_f64_m[i_m] = 0;
                        arg_sz_m[i_m] = sz_m;
                        gp_start_m[i_m] = 0 - 1;
                        gp_units_m[i_m] = 0;
                        // PLATFORM: LINUX+MACOS x86_64 SysV — f32/f64 extras go xmm0–7.
                        // PLATFORM: MACOS|ARM64 AAPCS64 — same extras go s0–s7 / d0–d7
                        // (host-C gcc reads FP regs). Encoder now has fmov sK,w0.
                        // Param home reads f32 (kind 14) and f64 (kind 15) from
                        // sK/dK. Import METHOD, UFCS, the free CALL packer,
                        // and param home all use v-slots for both widths.
                        if (ta == 0 || ta == 1) {
                          is_sse_m[i_m] = backend_call_dispatch_glue_arg_ref_is_sse_float_c(arena, ar_m, pty_m);
                          is_f64_m[i_m] = backend_call_dispatch_glue_arg_ref_is_f64_width_c(arena, ctx, ar_m, pty_m);
                        }
                        if (is_sse_m[i_m] != 0) {
                          // PLATFORM: WINDOWS x86_64 — positional slot. gp_cur_m
                          // already includes the sret shift. Slot >= 4 clears
                          // is_sse so it is not a System V push.
                          // PLATFORM: LINUX+MACOS x86_64 SysV · MACOS|ARM64 — xmm/v file.
                          int32_t win_m = 0;
                          if (ta == 0) {
                            {
                              if (link_abi_host_is_windows() != 0) { win_m = 1; }
                            }
                          }
                          if (win_m != 0) {
                            int32_t use_xmm_m = 0;
                            int32_t slot_m = 0;
                            w1547_win_place_float(&gp_cur_m, &use_xmm_m, &slot_m);
                            gp_start_m[i_m] = slot_m;
                            gp_units_m[i_m] = 1;
                            if (use_xmm_m == 0) {
                              is_sse_m[i_m] = 0;
                            }
                          } else {
                            if (xmm_cur_m >= 8) { return 0 - 1; }
                            gp_start_m[i_m] = xmm_cur_m;
                            gp_units_m[i_m] = 1;
                            xmm_cur_m = xmm_cur_m + 1;
                          }
                        } else {
                          if (u_m < 1) { u_m = 1; }
                          if (u_m > 2) { u_m = 2; }
                          if (backend_call_dispatch_glue_sysv_arg_is_memory_by_value_c(sz_m) != 0) {
                            if (ta == 0) {
                              // x86 SysV MEMORY: stack only (not lea into GP).
                              is_mem_m[i_m] = 1;
                              gp_start_m[i_m] = 0 - 1;
                              gp_units_m[i_m] = 0;
                            } else {
                              // w2060: ta==1 — HFA -> V regs; else byref helper.
                              int32_t hn_m = backend_call_dispatch_glue_aapcs64_hfa_nregs_c(arena, ctx, pty_m);
                              if (hn_m != 0) {
                                is_mem_m[i_m] = 0;
                                is_sse_m[i_m] = 1;
                                is_f64_m[i_m] = 1;
                                if (xmm_cur_m + hn_m <= 8) {
                                  gp_start_m[i_m] = xmm_cur_m;
                                  gp_units_m[i_m] = hn_m;
                                  xmm_cur_m = xmm_cur_m + hn_m;
                                } else {
                                  return 0 - 1;
                                }
                              } else if (backend_call_dispatch_glue_aapcs64_arg_is_byref_c(arena, ctx, pty_m, sz_m) != 0) {
                                is_mem_m[i_m] = 2;
                                if (gp_cur_m + 1 <= reg_max_m) {
                                  gp_start_m[i_m] = gp_cur_m;
                                  gp_units_m[i_m] = 1;
                                  gp_cur_m = gp_cur_m + 1;
                                } else {
                                  gp_start_m[i_m] = 0 - 1;
                                  gp_units_m[i_m] = 1;
                                }
                              } else {
                                return 0 - 1;
                              }
                            }
                          } else if (gp_cur_m + u_m <= reg_max_m) {
                            gp_start_m[i_m] = gp_cur_m;
                            gp_units_m[i_m] = u_m;
                            gp_cur_m = gp_cur_m + u_m;
                          } else {
                            gp_start_m[i_m] = 0 - 1;
                            gp_units_m[i_m] = u_m;
                          }
                        }
                        i_m = i_m + 1;
                      }
                      // x86: MEMORY multi-word + excess integer stack (high→low) before reg load.
                      // PLATFORM: LINUX+MACOS x86_64 SysV — pad first for 16-align (seed twin).
                      if (ta == 0) {
                        int32_t raw_mem = 0;
                        int32_t pushed_total = 0;
                        i_m = 0;
                        while (i_m < nargs) {
                          if (is_mem_m[i_m] == 1) {
                            raw_mem = raw_mem + ((arg_sz_m[i_m] + 7) & (0 - 8));
                          } else if (gp_start_m[i_m] < 0) {
                            // A 9–16B INTEGER that missed the GP file is two
                            // eightbytes, matching the push below.
                            // PLATFORM: LINUX+MACOS x86_64 SysV.
                            if (gp_units_m[i_m] >= 2) {
                              raw_mem = raw_mem + 16;
                            } else {
                              raw_mem = raw_mem + 8;
                            }
                          }
                          i_m = i_m + 1;
                        }
                        while (((raw_mem + pushed_total) & 15) != 0) {
                          if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, 0, ta) != 0) { return 0 - 1; }
                          if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) { return 0 - 1; }
                          pushed_total = pushed_total + 8;
                        }
                        i_m = nargs - 1;
                        while (i_m >= 0) {
                          if (is_mem_m[i_m] == 1) {
                            int32_t arg_mem = pipeline_expr_method_call_arg_ref(arena, expr_ref, i_m);
                            int32_t pushed = 0;
                            if (arg_mem == 0) { return 0 - 1; }
                            pushed = pipeline_asm_push_sysv_memory_by_value_elf_c(
                              arena, elf_ctx, ctx, arg_mem, arg_sz_m[i_m], ta);
                            if (pushed < 0) { return 0 - 1; }
                            pushed_total = pushed_total + pushed;
                          } else if (gp_start_m[i_m] < 0) {
                            int32_t arg_stk = pipeline_expr_method_call_arg_ref(arena, expr_ref, i_m);
                            if (arg_stk != 0) {
                              if (glue_emit_one_call_arg_elf_c(arena, elf_ctx, expr_ref, arg_stk, i_m, ctx, ta) != 0) {
                                return 0 - 1;
                              }
                              int32_t nb_m = backend_call_dispatch_glue_sysv_push_int_stack_arg_elf_c(elf_ctx, ta, gp_units_m[i_m]);
                              if (nb_m < 0) { return 0 - 1; }
                              pushed_total = pushed_total + nb_m;
                            }
                          }
                          i_m = i_m - 1;
                        }
                        mem_stack_m = pushed_total;
                      }
                      // Emit + spill register-class args (dual-GP; arm64 >16B → lea).
                      i_m = 0;
                      while (i_m < nargs) {
                        if (gp_start_m[i_m] >= 0) {
                          int32_t arg_ref_m = pipeline_expr_method_call_arg_ref(arena, expr_ref, i_m);
                          if (arg_ref_m != 0) {
                            if (is_mem_m[i_m] == 2) {
                              // PLATFORM: MACOS|ARM64 — host-C large POD addr into GP
                              // (VAR lea / nested CALL sret→temp+lea; save outer x8).
                              if (backend_call_dispatch_glue_emit_arm64_host_mem_arg_addr_to_rax_c(
                                    arena, elf_ctx, ctx, arg_ref_m, arg_sz_m[i_m], ta) != 0) {
                                return 0 - 1;
                              }
                            } else if (glue_emit_one_call_arg_elf_c(arena, elf_ctx, expr_ref, arg_ref_m, i_m, ctx, ta) != 0) {
                              return 0 - 1;
                            }
                            int32_t so_m = backend_call_dispatch_glue_sysv_spill_rax_rdx_to_frame_c(elf_ctx, ctx, ta, gp_units_m[i_m]);
                            if (so_m < 0) { return 0 - 1; }
                            spill_off_m[i_m] = so_m;
                          }
                        }
                        i_m = i_m + 1;
                      }
                      // arm64 excess: place on [sp] via x0 *before* final GP load (do not clobber GPs).
                      // Skip is_mem==2 (already in GP); only true excess integer stack.
                      // w1521: is_mem==3 (X-to-X MEMORY) reserves + stores like UFCS wave606.
                      if (ta == 1) {
                        int32_t stk_pos_m = 0;
                        int32_t nw_m = 0;
                        int32_t any3_m = 0;
                        i_m = 0;
                        while (i_m < nargs) {
                          if (is_mem_m[i_m] == 3) {
                            any3_m = 1;
                            nw_m = nw_m + backend_call_dispatch_glue_sysv_arg_stack_words_c(arg_sz_m[i_m], 0);
                          } else if (gp_start_m[i_m] < 0 && is_mem_m[i_m] != 2) {
                            nw_m = nw_m + 1;
                          }
                          i_m = i_m + 1;
                        }
                        if (any3_m != 0) {
                          mem_stack_m = (nw_m * 8 + 15) & (0 - 16);
                          if (backend_enc_call_stack_reserve_arch(elf_ctx, mem_stack_m, ta) != 0) { return 0 - 1; }
                        }
                        i_m = 0;
                        while (i_m < nargs) {
                          if (is_mem_m[i_m] == 3) {
                            int32_t arg_m3 = pipeline_expr_method_call_arg_ref(arena, expr_ref, i_m);
                            if (arg_m3 == 0) { return 0 - 1; }
                            int32_t moff_m3 = backend_call_dispatch_glue_call_stk_extra_align(stk_pos_m, arg_sz_m[i_m], ta);
                            int32_t st_m3 = pipeline_asm_store_memory_by_value_to_sp_elf_c(
                              arena, elf_ctx, ctx, arg_m3, arg_sz_m[i_m], ta, moff_m3);
                            if (st_m3 < 0) { return 0 - 1; }
                            stk_pos_m = backend_call_dispatch_glue_call_stk_extra_advance(moff_m3, st_m3, ta);
                          } else if (gp_start_m[i_m] < 0) {
                            if (is_mem_m[i_m] != 2) {
                              int32_t arg_stk_a = pipeline_expr_method_call_arg_ref(arena, expr_ref, i_m);
                              if (arg_stk_a != 0) {
                                if (glue_emit_one_call_arg_elf_c(arena, elf_ctx, expr_ref, arg_stk_a, i_m, ctx, ta) != 0) {
                                  return 0 - 1;
                                }
                                /* wave614: natural-packing cursor (see
                                 * glue_call_stk_extra_*). */
                                int32_t aoff_m = backend_call_dispatch_glue_call_stk_extra_align(stk_pos_m, arg_sz_m[i_m], ta);
                                if (backend_enc_store_arg_sp_offset_arch(elf_ctx, aoff_m, arg_sz_m[i_m], ta) != 0) {
                                  return 0 - 1;
                                }
                                stk_pos_m = backend_call_dispatch_glue_call_stk_extra_advance(aoff_m, arg_sz_m[i_m], ta);
                              }
                            }
                          }
                          i_m = i_m + 1;
                        }
                      }
                      // Load high→low so x0/rax temp does not wipe lower final GPs.
                      // Dual-GP: load into gp_start_m and gp_start_m+1 (not bare arg index).
                      // SSE: reload bits then movd/movq into xmm[k] (≡ seed _impl).
                      i_m = nargs - 1;
                      while (i_m >= 0) {
                        if (spill_off_m[i_m] >= 0) {
                          if (is_sse_m[i_m] != 0) {
                            if (backend_enc_load_rbp_to_rax_arch(elf_ctx, spill_off_m[i_m], ta) != 0) {
                              return 0 - 1;
                            }
                            if (is_f64_m[i_m] != 0) {
                              if (backend_enc_mov_rax_to_xmm_arg_reg_arch(elf_ctx, gp_start_m[i_m], ta) != 0) {
                                return 0 - 1;
                              }
                            } else if (backend_enc_mov_eax_to_xmm_arg_reg_arch(elf_ctx, gp_start_m[i_m], ta) != 0) {
                              return 0 - 1;
                            }
                          } else if (backend_call_dispatch_glue_sysv_load_spill_to_arg_regs_elf_c(elf_ctx, ta, spill_off_m[i_m], gp_start_m[i_m], gp_units_m[i_m]) != 0) {
                            return 0 - 1;
                          }
                        }
                        i_m = i_m - 1;
                      }
                      if (backend_call_dispatch_w1546_reload_call_sret_arg0(elf_ctx, sret_park_m, ta) != 0) { return 0 - 1; }
                      if (backend_call_dispatch_w1545_pend_rcx_emit(elf_ctx, expr_ref) != 0) { return 0 - 1; }
                      if (glue_asm_enc_call_redirected(elf_ctx, &sym_flat[0], sym_len, ta) != 0) { return 0 - 1; }
                      // Cleanup: MEMORY multi-word bytes when tracked; else nargs-based.
                      {
                        int32_t cln_m = mem_stack_m;
                        if (cln_m <= 0) {
                          cln_m = glue_asm_call_stack_cleanup_bytes(ta, n_ov);
                        }
                        if (cln_m < 0) { return 0 - 1; }
                        if (cln_m > 0) {
                          if (backend_enc_call_stack_cleanup_arch(elf_ctx, cln_m, ta) != 0) { return 0 - 1; }
                        }
                      }
                    }
                    /*
                     * PLATFORM: SHARED freestanding — after import METHOD_CALL, harvest
                     * ret into full GPR (i32 sxtw / u32 zxt / f32 xmm). G.7 complete:
                     * seed _impl always harvests here; pure .x previously returned after
                     * cleanup only → AAPCS64 `ldr w0` zero-extends -1 to 0xFFFFFFFF,
                     * then full-x0 signed cmp (`call() >= 0`) is true (run-mem exit 8).
                     * Free CALL already harvests via glue_asm_emit_call_with_cleanup;
                     * import METHOD must match (same authority glue_asm_harvest_call_ret_to_gpr_c).
                     */
                    if (glue_asm_harvest_call_ret_to_gpr_c(arena, elf_ctx, expr_ref, ta) != 0) {
                      return 0 - 1;
                    }
                    // PLATFORM: MACOS|ARM64 AAPCS64 — host-C returns f32/f64 in s0/d0.
                    // Shared harvest is x86-only so local xlang f32 CALL stays GP-in/GP-out.
                    // Import METHOD callee is gcc: move s0/d0 → w0/x0 after the no-op harvest.
                    if (ta == 1) {
                      int32_t rk_m = pipeline_asm_call_return_type_kind_ord_c(arena, expr_ref);
                      if (rk_m == 14) {
                        if (backend_enc_mov_xmm_arg_reg_to_eax_arch(elf_ctx, 0, ta) != 0) {
                          return 0 - 1;
                        }
                      } else if (rk_m == 15) {
                        if (backend_enc_mov_xmm_arg_reg_to_rax_arch(elf_ctx, 0, ta) != 0) {
                          return 0 - 1;
                        }
                      }
                    }
                    return 0;
                  }
                }
                j = j + 1;
              }
            }
          }
        }
      }
    }
    // G.7: same param0.field / field-sum / x+K / wpo_mono-symbol / wpo_mono-vector_lane
    // / wpo_const-scalar / vector_lane folds as CALL emit
    // (recv.first() ≡ take_a(recv); recv.pair_sum() ≡ field_sum(recv);
    //  recv.plus_one() ≡ add_one(recv); recv.fold_add(K) ≡ fold_add_call(recv, K);
    //  XLANG_WPO_MONO: recv.fold_add(K) ≡ fold_add_call(recv, K) via zero-arg thunk;
    //  XLANG_WPO_MONO: recv.lane0() ≡ lane0_call(recv) via zero-arg thunk
    //  when recv is const vec_binop;
    //  recv.lane0() ≡ lane0_call(recv) when recv is const vec_binop).
    // After import-binding: import methods must not enter lookup/fold (option/si SEGV).
    // extra mismatch / fold miss / PTR → 0, fall through to UFCS CALL.
    {
      int32_t inline_sf = try_inline_param0_single_field_call_elf(arena, elf_ctx, expr_ref, ctx, ta);
      if (inline_sf != 0) {
        if (inline_sf < 0) { return 0 - 1; }
        return 0;
      }
    }
    {
      int32_t inline_fs = try_inline_param0_field_sum_call_elf(arena, elf_ctx, expr_ref, ctx, ta);
      if (inline_fs != 0) {
        if (inline_fs < 0) { return 0 - 1; }
        return 0;
      }
    }
    {
      int32_t inline_xk = try_inline_x_plus_k_call_elf(arena, elf_ctx, expr_ref, ctx, ta);
      if (inline_xk != 0) {
        if (inline_xk < 0) { return 0 - 1; }
        return 0;
      }
    }
    // Same order as CALL emit: mono symbol then vector_lane mono
    // (both self-gate on XLANG_WPO_MONO) then const fold only when
    // neither mono nor no-fold env is set.
    {
      int32_t inline_ms = try_call_wpo_mono_symbol_elf(arena, elf_ctx, expr_ref, ctx, ta);
      if (inline_ms != 0) {
        if (inline_ms < 0) { return 0 - 1; }
        return 0;
      }
    }
    {
      int32_t inline_mv = try_call_wpo_mono_vector_lane_of_binop_call_elf(arena, elf_ctx, expr_ref, ctx, ta);
      if (inline_mv != 0) {
        if (inline_mv < 0) { return 0 - 1; }
        return 0;
      }
    }
    // Same env gate as CALL emit: XLANG_WPO_MONO / XLANG_WPO_NO_FOLD skip const fold.
    // Order matches CALL emit: vector_lane then scalar.
    if (link_abi_getenv((uint8_t *)"XLANG_WPO_MONO") == 0) {
      if (link_abi_getenv((uint8_t *)"XLANG_WPO_NO_FOLD") == 0) {
        int32_t inline_vl = try_inline_wpo_const_vector_lane_of_binop_call_elf(arena, elf_ctx, expr_ref, ctx, ta);
        if (inline_vl != 0) {
          if (inline_vl < 0) { return 0 - 1; }
          return 0;
        }
        int32_t inline_wc = try_inline_wpo_const_scalar_binop_call_elf(arena, elf_ctx, expr_ref, ctx, ta);
        if (inline_wc != 0) {
          if (inline_wc < 0) { return 0 - 1; }
          return 0;
        }
      }
    }
    // wave360 + ARRAY_LIT SIMD self: UFCS places [receiver, extra0..] (seed wave602).
    // PLATFORM: SHARED — LINUX+MACOS x86_64 SysV dual-GP; MACOS|ARM64 AAPCS64 spill.
    {
      int32_t has_recv = 0;
      int32_t n_place = 0;
      int32_t need_aref = 0;
      int32_t spill_off_u[96]; memset(spill_off_u, 0, sizeof(spill_off_u));
      int32_t gp_start_u[96]; memset(gp_start_u, 0, sizeof(gp_start_u));
      int32_t gp_units_u[96]; memset(gp_units_u, 0, sizeof(gp_units_u));
      int32_t is_mem_u[96]; memset(is_mem_u, 0, sizeof(is_mem_u));
      int32_t is_sse_u[96]; memset(is_sse_u, 0, sizeof(is_sse_u));
      int32_t is_f64_u[96]; memset(is_f64_u, 0, sizeof(is_f64_u));
      int32_t arg_sz_u[96]; memset(arg_sz_u, 0, sizeof(arg_sz_u));
      int32_t i_u = 0;
      int32_t mem_stack_u = 0;
      int32_t xmm_cur_u = 0;
      int32_t reg_max_u = glue_asm_call_reg_max(ta);
      int32_t sret_sh_u = 0;
      int32_t sret_park_u = (0 - 2);
      int32_t gp_cur_u = 0;
      if (w1521_method_base_nz(arena, expr_ref) != 0) { has_recv = 1; }
      /*
       * Associated Type.method(): resolved callee nparams == nargs (no implicit
       * self). `P.mk()` / `P.id(7)` / `P.get(p)` — type-name receiver is not
       * an argument. Instance `p.get()` keeps nparams == nargs+1 so has_recv
       * stays 1. PLATFORM: SHARED — G.7 complete UFCS leave (C seed twin
       * deleted in w1524).
       */
      if (has_recv != 0) {
        int32_t assoc_fn = pipeline_expr_call_resolved_func_index_at(arena, expr_ref);
        int32_t assoc_dep = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
        if (assoc_fn >= 0) {
          if (assoc_dep < 0) {
            if (mod_ref != ((uint8_t *)0)) {
              int32_t assoc_np = pipeline_module_func_num_params_at(mod_ref, assoc_fn);
              if (assoc_np == nargs) {
                has_recv = 0;
              }
            }
          }
        }
      }
      n_place = has_recv + nargs;
      if (n_place < 0) { return 0 - 1; }
      if (n_place > 96) { return 0 - 1; }
      if (has_recv != 0) {
        int32_t r_fn2 = pipeline_expr_call_resolved_func_index_at(arena, expr_ref);
        int32_t r_dep2 = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
        if (r_fn2 >= 0) {
          if (r_dep2 < 0) {
            if (mod_ref != 0) {
              int32_t p0 = pipeline_module_func_param_type_ref_at(mod_ref, r_fn2, 0);
              int32_t bty = w1521_method_base_resolved_type(arena, expr_ref);
              if (p0 > 0) {
                if (bty > 0) {
                  // TYPE_PTR kind ord = 9
                  if (pipeline_type_kind_ord_at(arena, p0) == 9) {
                    if (pipeline_typeck_type_refs_equal_c(arena, bty, p0) == 0) {
                      int32_t pe = pipeline_type_elem_ref_at(arena, p0);
                      if (pe > 0) {
                        if (pipeline_typeck_type_refs_equal_c(arena, bty, pe) != 0) {
                          need_aref = 1;
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
      if (ta == 0) {
        sret_sh_u = pipeline_asm_emit_call_sret_reg_shift_c();
        if (sret_sh_u == 0) { sret_sh_u = backend_call_dispatch_w1545_pend_is(expr_ref); }
        // Same flag scope as free CALL. PLATFORM: LINUX+WINDOWS x86_64.
        sret_park_u = backend_call_dispatch_w1546_park_call_sret_arg0(elf_ctx, ctx, ta);
        if (sret_park_u == (0 - 1)) { return 0 - 1; }
      }
      gp_cur_u = sret_sh_u;
      if (reg_max_u < 1) { reg_max_u = 6; }
      while (i_u < n_place) {
        int32_t ar_u = 0;
        int32_t pty_u = glue_call_param_type_ref_at(arena, expr_ref, i_u);
        int32_t sz_u = 0;
        int32_t u_u = 0;
        if (has_recv != 0) {
          if (i_u == 0) {
            ar_u = w1521_method_base_ref(arena, expr_ref);
          } else {
            ar_u = pipeline_expr_method_call_arg_ref(arena, expr_ref, i_u - has_recv);
          }
        } else {
          ar_u = pipeline_expr_method_call_arg_ref(arena, expr_ref, i_u);
        }
        if (has_recv != 0) {
          if (i_u == 0) {
            if (need_aref != 0) {
              sz_u = 8;
            } else {
              sz_u = glue_sysv_arg_byte_size_c(arena, ctx, pty_u, ar_u);
            }
          } else {
            sz_u = glue_sysv_arg_byte_size_c(arena, ctx, pty_u, ar_u);
          }
        } else {
          sz_u = glue_sysv_arg_byte_size_c(arena, ctx, pty_u, ar_u);
        }
        u_u = glue_sysv_arg_gp_units_from_size_c(sz_u);
        spill_off_u[i_u] = 0 - 1;
        is_mem_u[i_u] = 0;
        is_sse_u[i_u] = 0;
        is_f64_u[i_u] = 0;
        arg_sz_u[i_u] = sz_u;
        gp_start_u[i_u] = 0 - 1;
        gp_units_u[i_u] = 0;
        // Same-layer twin of import METHOD SSE classify (G.7 有则补全).
        // PLATFORM: MACOS|ARM64 AAPCS64 — f32 and f64 take v-slots. Param
        // home reads kind 14 and kind 15 from sK/dK.
        if (ta == 0) {
          is_sse_u[i_u] = backend_call_dispatch_glue_arg_ref_is_sse_float_c(arena, ar_u, pty_u);
          is_f64_u[i_u] = backend_call_dispatch_glue_arg_ref_is_f64_width_c(arena, ctx, ar_u, pty_u);
        } else {
          is_f64_u[i_u] = backend_call_dispatch_glue_arg_ref_is_f64_width_c(arena, ctx, ar_u, pty_u);
          is_sse_u[i_u] = backend_call_dispatch_glue_arg_ref_is_sse_float_c(arena, ar_u, pty_u);
          if (is_f64_u[i_u] != 0) { is_sse_u[i_u] = 1; }
        }
        if (is_sse_u[i_u] != 0) {
          // PLATFORM: WINDOWS x86_64 — same positional float as import METHOD.
          // Slot >= 4 clears is_sse so the GP encoder writes the stack home.
          // PLATFORM: LINUX+MACOS x86_64 SysV · MACOS|ARM64 AAPCS64 — xmm/v file.
          int32_t win_u = 0;
          if (ta == 0) {
            {
              if (link_abi_host_is_windows() != 0) { win_u = 1; }
            }
          }
          if (win_u != 0) {
            int32_t use_xmm_u = 0;
            int32_t slot_u = 0;
            w1547_win_place_float(&gp_cur_u, &use_xmm_u, &slot_u);
            gp_start_u[i_u] = slot_u;
            gp_units_u[i_u] = 1;
            if (use_xmm_u == 0) {
              is_sse_u[i_u] = 0;
            }
          } else {
            if (xmm_cur_u >= 8) { return 0 - 1; }
            gp_start_u[i_u] = xmm_cur_u;
            gp_units_u[i_u] = 1;
            xmm_cur_u = xmm_cur_u + 1;
          }
        } else {
          if (u_u < 1) { u_u = 1; }
          if (u_u > 2) { u_u = 2; }
          if (backend_call_dispatch_glue_sysv_arg_is_memory_by_value_c(sz_u) != 0) {
            if (ta == 1) {
              /* w2060: HFA -> V; byref via helper. */
              int32_t hn_u = backend_call_dispatch_glue_aapcs64_hfa_nregs_c(arena, ctx, pty_u);
              if (hn_u != 0) {
                is_mem_u[i_u] = 0;
                is_sse_u[i_u] = 1;
                is_f64_u[i_u] = 1;
                if (xmm_cur_u + hn_u <= 8) {
                  gp_start_u[i_u] = xmm_cur_u;
                  gp_units_u[i_u] = hn_u;
                  xmm_cur_u = xmm_cur_u + hn_u;
                } else {
                  return 0 - 1;
                }
              } else if (backend_call_dispatch_glue_aapcs64_arg_is_byref_c(arena, ctx, pty_u, sz_u) != 0) {
                is_mem_u[i_u] = 2;
                if (gp_cur_u + 1 <= reg_max_u) {
                  gp_start_u[i_u] = gp_cur_u;
                  gp_units_u[i_u] = 1;
                  gp_cur_u = gp_cur_u + 1;
                } else {
                  gp_start_u[i_u] = 0 - 1;
                  gp_units_u[i_u] = 1;
                }
              } else {
                return 0 - 1;
              }
            } else {
              /* wave606: X-to-X MEMORY stack-only on SysV x86_64. */
              is_mem_u[i_u] = 1;
              gp_start_u[i_u] = 0 - 1;
              gp_units_u[i_u] = 0;
            }
          } else if (gp_cur_u + u_u <= reg_max_u) {
            gp_start_u[i_u] = gp_cur_u;
            gp_units_u[i_u] = u_u;
            gp_cur_u = gp_cur_u + u_u;
          } else {
            gp_start_u[i_u] = 0 - 1;
            gp_units_u[i_u] = u_u;
          }
        }
        i_u = i_u + 1;
      }
      // x86: MEMORY multi-word + excess integer stack (high→low) before reg load.
      if (ta == 0) {
        int32_t raw_mem = 0;
        int32_t pushed_total = 0;
        i_u = 0;
        while (i_u < n_place) {
          if (is_mem_u[i_u] == 1) {
            raw_mem = raw_mem + ((arg_sz_u[i_u] + 7) & (0 - 8));
          } else if (gp_start_u[i_u] < 0) {
            // Same two-eightbyte charge as the import METHOD packer.
            // PLATFORM: LINUX+MACOS x86_64 SysV.
            if (gp_units_u[i_u] >= 2) {
              raw_mem = raw_mem + 16;
            } else {
              raw_mem = raw_mem + 8;
            }
          }
          i_u = i_u + 1;
        }
        while (((raw_mem + pushed_total) & 15) != 0) {
          if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, 0, ta) != 0) { return 0 - 1; }
          if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) { return 0 - 1; }
          pushed_total = pushed_total + 8;
        }
        i_u = n_place - 1;
        while (i_u >= 0) {
          int32_t arg_pl = 0;
          if (has_recv != 0) {
            if (i_u == 0) {
              arg_pl = w1521_method_base_ref(arena, expr_ref);
            } else {
              arg_pl = pipeline_expr_method_call_arg_ref(arena, expr_ref, i_u - has_recv);
            }
          } else {
            arg_pl = pipeline_expr_method_call_arg_ref(arena, expr_ref, i_u);
          }
          if (is_mem_u[i_u] == 1) {
            int32_t pushed = 0;
            if (arg_pl == 0) { return 0 - 1; }
            pushed = pipeline_asm_push_sysv_memory_by_value_elf_c(
              arena, elf_ctx, ctx, arg_pl, arg_sz_u[i_u], ta);
            if (pushed < 0) { return 0 - 1; }
            pushed_total = pushed_total + pushed;
          } else if (gp_start_u[i_u] < 0) {
            if (arg_pl != 0) {
              if (has_recv != 0) {
                if (i_u == 0) {
                  if (need_aref != 0) {
                    if (w1521_emit_lvalue_method_base(arena, elf_ctx, expr_ref, ctx, ta) != 0) {
                      return 0 - 1;
                    }
                  } else if (w1521_glue_emit_one_call_arg_method_base(arena, elf_ctx, expr_ref, ctx, ta) != 0) {
                    return 0 - 1;
                  }
                } else if (glue_emit_one_call_arg_elf_c(arena, elf_ctx, expr_ref, arg_pl, i_u, ctx, ta) != 0) {
                  return 0 - 1;
                }
              } else if (glue_emit_one_call_arg_elf_c(arena, elf_ctx, expr_ref, arg_pl, i_u, ctx, ta) != 0) {
                return 0 - 1;
              }
              int32_t nb_u = backend_call_dispatch_glue_sysv_push_int_stack_arg_elf_c(elf_ctx, ta, gp_units_u[i_u]);
              if (nb_u < 0) { return 0 - 1; }
              pushed_total = pushed_total + nb_u;
            }
          }
          i_u = i_u - 1;
        }
        mem_stack_u = pushed_total;
      }
      if (ta == 1) {
        int32_t nw_u = 0;
        int32_t stack_reserve_u = 0;
        i_u = 0;
        while (i_u < n_place) {
          if (is_mem_u[i_u] == 1) {
            nw_u = nw_u + backend_call_dispatch_glue_sysv_arg_stack_words_c(arg_sz_u[i_u], 0);
          } else if (gp_start_u[i_u] < 0) {
            if (is_mem_u[i_u] != 2) {
              nw_u = nw_u + 1;
            }
          }
          i_u = i_u + 1;
        }
        stack_reserve_u = nw_u * 8;
        if (stack_reserve_u > 0) {
          stack_reserve_u = (stack_reserve_u + 15) & (0 - 16);
        }
        mem_stack_u = stack_reserve_u;
        if (backend_enc_call_stack_reserve_arch(elf_ctx, stack_reserve_u, ta) != 0) { return 0 - 1; }
      }
      // Emit + spill register-class places (receiver uses pty=formal0 via glue_emit_one_call_arg).
      i_u = 0;
      while (i_u < n_place) {
        if (gp_start_u[i_u] >= 0) {
          int32_t arg_rg = 0;
          if (has_recv != 0) {
            if (i_u == 0) {
              arg_rg = w1521_method_base_ref(arena, expr_ref);
            } else {
              arg_rg = pipeline_expr_method_call_arg_ref(arena, expr_ref, i_u - has_recv);
            }
          } else {
            arg_rg = pipeline_expr_method_call_arg_ref(arena, expr_ref, i_u);
          }
          if (arg_rg != 0) {
            if (is_mem_u[i_u] == 2) {
              // PLATFORM: MACOS|ARM64 — host-indirect (nested CALL safe).
              if (backend_call_dispatch_glue_emit_arm64_host_mem_arg_addr_to_rax_c(
                    arena, elf_ctx, ctx, arg_rg, arg_sz_u[i_u], ta) != 0) {
                return 0 - 1;
              }
            } else if (has_recv != 0) {
              if (i_u == 0) {
                if (need_aref != 0) {
                  if (w1521_emit_lvalue_method_base(arena, elf_ctx, expr_ref, ctx, ta) != 0) {
                    return 0 - 1;
                  }
                } else if (w1521_glue_emit_one_call_arg_method_base(arena, elf_ctx, expr_ref, ctx, ta) != 0) {
                  return 0 - 1;
                }
              } else if (glue_emit_one_call_arg_elf_c(arena, elf_ctx, expr_ref, arg_rg, i_u, ctx, ta) != 0) {
                return 0 - 1;
              }
            } else if (glue_emit_one_call_arg_elf_c(arena, elf_ctx, expr_ref, arg_rg, i_u, ctx, ta) != 0) {
              return 0 - 1;
            }
            int32_t so_u = backend_call_dispatch_glue_sysv_spill_rax_rdx_to_frame_c(elf_ctx, ctx, ta, gp_units_u[i_u]);
            if (so_u < 0) { return 0 - 1; }
            spill_off_u[i_u] = so_u;
          }
        }
        i_u = i_u + 1;
      }
      // arm64 MEMORY / excess integer stack *before* final GP load.
      // wave606: MEMORY multi-word via store_to_sp (≡ free CALL wave603).
      // PLATFORM: MACOS|ARM64 AAPCS64 natural · LINUX 8-slot.
      if (ta == 1) {
        int32_t stk_pos_u = 0;
        i_u = 0;
        while (i_u < n_place) {
          if (gp_start_u[i_u] < 0) {
            int32_t arg_sk = 0;
            if (has_recv != 0) {
              if (i_u == 0) {
                arg_sk = w1521_method_base_ref(arena, expr_ref);
              } else {
                arg_sk = pipeline_expr_method_call_arg_ref(arena, expr_ref, i_u - has_recv);
              }
            } else {
              arg_sk = pipeline_expr_method_call_arg_ref(arena, expr_ref, i_u);
            }
            if (is_mem_u[i_u] == 1) {
              if (arg_sk == 0) { return 0 - 1; }
              int32_t moff_u = backend_call_dispatch_glue_call_stk_extra_align(stk_pos_u, arg_sz_u[i_u], ta);
              int32_t stored_u = pipeline_asm_store_memory_by_value_to_sp_elf_c(
                arena, elf_ctx, ctx, arg_sk, arg_sz_u[i_u], ta, moff_u);
              if (stored_u < 0) { return 0 - 1; }
              stk_pos_u = backend_call_dispatch_glue_call_stk_extra_advance(moff_u, stored_u, ta);
            } else if (is_mem_u[i_u] != 2) {
              if (arg_sk != 0) {
                if (has_recv != 0) {
                  if (i_u == 0) {
                    if (need_aref != 0) {
                      if (w1521_emit_lvalue_method_base(arena, elf_ctx, expr_ref, ctx, ta) != 0) {
                        return 0 - 1;
                      }
                    } else if (w1521_glue_emit_one_call_arg_method_base(arena, elf_ctx, expr_ref, ctx, ta) != 0) {
                      return 0 - 1;
                    }
                  } else if (glue_emit_one_call_arg_elf_c(arena, elf_ctx, expr_ref, arg_sk, i_u, ctx, ta) != 0) {
                    return 0 - 1;
                  }
                } else if (glue_emit_one_call_arg_elf_c(arena, elf_ctx, expr_ref, arg_sk, i_u, ctx, ta) != 0) {
                  return 0 - 1;
                }
                /* wave614: natural-packing cursor (see glue_call_stk_extra_*). */
                int32_t aoff_u = backend_call_dispatch_glue_call_stk_extra_align(stk_pos_u, arg_sz_u[i_u], ta);
                if (backend_enc_store_arg_sp_offset_arch(elf_ctx, aoff_u, arg_sz_u[i_u], ta) != 0) {
                  return 0 - 1;
                }
                stk_pos_u = backend_call_dispatch_glue_call_stk_extra_advance(aoff_u, arg_sz_u[i_u], ta);
              }
            }
          }
          i_u = i_u + 1;
        }
      }
      // Load high→low so rax/x0 temp does not wipe lower GPs. Dual-GP uses gp_start+units.
      // SSE: reload bits then movd/movq into xmm[k] (≡ import METHOD / seed _impl).
      i_u = n_place - 1;
      while (i_u >= 0) {
        if (spill_off_u[i_u] >= 0) {
          if (is_sse_u[i_u] != 0) {
            if (backend_enc_load_rbp_to_rax_arch(elf_ctx, spill_off_u[i_u], ta) != 0) {
              return 0 - 1;
            }
            if (is_f64_u[i_u] != 0) {
              if (backend_enc_mov_rax_to_xmm_arg_reg_arch(elf_ctx, gp_start_u[i_u], ta) != 0) {
                return 0 - 1;
              }
            } else if (backend_enc_mov_eax_to_xmm_arg_reg_arch(elf_ctx, gp_start_u[i_u], ta) != 0) {
              return 0 - 1;
            }
          } else if (backend_call_dispatch_glue_sysv_load_spill_to_arg_regs_elf_c(elf_ctx, ta, spill_off_u[i_u], gp_start_u[i_u], gp_units_u[i_u]) != 0) {
            return 0 - 1;
          }
        }
        i_u = i_u - 1;
      }
      if (backend_call_dispatch_w1546_reload_call_sret_arg0(elf_ctx, sret_park_u, ta) != 0) { return 0 - 1; }
      if (backend_call_dispatch_w1545_pend_rcx_emit(elf_ctx, expr_ref) != 0) { return 0 - 1; }
      // wave683: overload-safe export-sym (get_S / take0) — bare name UNDEF on Ubuntu.
      {
        int32_t r_fn_call = pipeline_expr_call_resolved_func_index_at(arena, expr_ref);
        int32_t r_dep_call = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
        uint8_t call_sym[256]; memset(call_sym, 0, sizeof(call_sym));
        int32_t call_sym_len = (0 - 1);
        if (r_fn_call >= 0) {
          if (r_dep_call < 0) {
            if (mod_ref != 0) {
              call_sym_len = glue_asm_build_func_export_sym_c(mod_ref, arena, r_fn_call, &call_sym[0], 256);
            }
          } else {
            uint8_t * dep_pipe_u = pipeline_asm_emit_dep_pipe_c();
            if (dep_pipe_u != ((uint8_t *)0)) {
              uint8_t * dm_u = pipeline_dep_ctx_module_at(dep_pipe_u, r_dep_call);
              uint8_t * da_u = pipeline_dep_ctx_arena_at(dep_pipe_u, r_dep_call);
              if (dm_u != ((uint8_t *)0)) {
                if (da_u == ((uint8_t *)0)) { da_u = arena; }
                call_sym_len = glue_asm_build_func_export_sym_c(dm_u, da_u, r_fn_call, &call_sym[0], 256);
              }
            }
          }
        }
        // Bound-method / LANG-005: typeck leaves func_ix=-1 (C6 mono on C
        // backend). Asm has no mono_active; bare method name then hits libc
        // (clone→clone@GLIBC, run=255). Prefer same-module name+arity
        // (self+extras == n_place) export sym, then find_impl on concrete
        // receiver, then bare name. PLATFORM: SHARED.
        if (call_sym_len <= 0 && mod_ref != ((uint8_t *)0) && name_len > 0) {
          int32_t nfunc_bm = pipeline_module_num_funcs(mod_ref);
          int32_t fi_bm = 0;
          uint8_t fname_bm[256]; memset(fname_bm, 0, sizeof(fname_bm));
          while (fi_bm < nfunc_bm) {
            int32_t fl_bm = pipeline_asm_module_func_name_len_at(mod_ref, fi_bm);
            int32_t np_bm = pipeline_module_func_num_params_at(mod_ref, fi_bm);
            int32_t match_bm = 0;
            int32_t bi_bm = 0;
            if (fl_bm == name_len && np_bm == n_place) {
              pipeline_asm_module_func_name_copy64(mod_ref, fi_bm, &fname_bm[0]);
              match_bm = 1;
              bi_bm = 0;
              while (bi_bm < name_len) {
                if (fname_bm[bi_bm] != name[bi_bm]) {
                  match_bm = 0;
                  bi_bm = name_len;
                } else {
                  bi_bm = bi_bm + 1;
                }
              }
            }
            if (match_bm != 0) {
              call_sym_len = glue_asm_build_func_export_sym_c(mod_ref, arena, fi_bm, &call_sym[0], 256);
              fi_bm = nfunc_bm;
            } else {
              fi_bm = fi_bm + 1;
            }
          }
        }
        if (call_sym_len <= 0 && mod_ref != ((uint8_t *)0) && name_len > 0 && w1521_method_base_nz(arena, expr_ref) != 0) {
          int32_t recv_ty_bm = w1521_method_base_resolved_type(arena, expr_ref);
          if (recv_ty_bm > 0) {
            int32_t impl_fi_bm = codegen_find_impl_method_for_type(mod_ref, arena, &name[0], name_len, recv_ty_bm);
            if (impl_fi_bm >= 0) {
              call_sym_len = glue_asm_build_func_export_sym_c(mod_ref, arena, impl_fi_bm, &call_sym[0], 256);
            }
          }
        }
        if (call_sym_len > 0) {
          if (glue_asm_enc_call_redirected(elf_ctx, &call_sym[0], call_sym_len, ta) != 0) { return 0 - 1; }
        } else if (glue_asm_enc_call_redirected(elf_ctx, &name[0], name_len, ta) != 0) {
          return 0 - 1;
        }
      }
      if (mem_stack_u > 0) {
        if (backend_enc_call_stack_cleanup_arch(elf_ctx, mem_stack_u, ta) != 0) { return 0 - 1; }
      }
      if (glue_asm_harvest_call_ret_to_gpr_c(arena, elf_ctx, expr_ref, ta) != 0) { return 0 - 1; }
      return 0;
    }
  }
  return 0 - 1;
}

// pipeline_asm_emit_call_elf_c: see function docblock below.
/** Exported function `pipeline_asm_emit_call_elf_c`.
 * Implements `pipeline_asm_emit_call_elf_c`.
 * @param arena *u8
 * @param elf_ctx *u8
 * @param expr_ref i32
 * @param ctx *u8
 * @param ta i32
 * @return i32
 */
/**
 * CORE-001 asm twin of codegen_try_emit_size_align_of_call (host-C sizeof/_Alignof).
 * Fold `size_of<T>()` / `align_of<T>()` (free or import-qualified) to imm in w0/eax.
 * Without this, zero-arg generics skip mono → bare `core_types_size_of` → BLD001 UNDEF.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF/Mach-O codegen ctx
 * @param expr_ref i32 — EXPR_CALL site
 * @param mod_ref *u8 — caller module (named-struct layouts)
 * @param ta i32 — target arch
 * @return i32 — 1 folded, 0 not applicable, -1 emit error
 * PLATFORM: SHARED — layout via glue_type_size_simple / glue_type_align_simple
 */
