/* Source-faithful w1521_emit_call_body twin
 * (compiler/src/asm/backend_call_dispatch.x, committed HEAD
 * function only, lines 7765-8083).
 * s168 hello-build residual: uninstrumented compile ~0.40s,
 * RC 0xC0000005, fault at a null address. Live path on the
 * s168 no-ASLR image:
 * typool backend_call_dispatch_w1521_sret_wrap T 0x1404402a4
 * -> typool w1521_body T 0x14043fbc0
 * -> typool w1521_emit_call_body T 0x140440c64
 * (prologue 55 48 89 e5 53 b8 88 2b 00 00..., typool body
 * size 0x5368). emit_method_body did not enter.
 * Already-folded s42 thin w1545_win_mid_ret_call 0x14001b210
 * is used on this path; typool leftover w1545 0x14040775c is
 * not this live path and was not folded.
 * Hardware watch on the typool emit_call_body return slot
 * (third entry slot 0x103f3c68, original return 0x14043fc88
 * = w1521_body+0xc8): a KERNELBASE local zero at [rsp+0x38]
 * landed on that slot because typool framed the function
 * wrong (callee rsp 0x103f3c30). Same residual class as
 * already-landed s163 (for_call_args) and earlier
 * emit_method_body / s52: typool incorrect stack frame /
 * u8[N]=[] shallow expansion. Host-cc memset / empty-array
 * initialization for = [] slots; do not invent a stub, do
 * not hardcode names or byte positions, and do not change
 * typool source. docs-only .x, do not idx8.
 * typool exports this function as backend_call_dispatch_w1521_emit_call_body
 * (same-TU prefix). The thin uses that name so first-wins lowest VA wins
 * over the typool leftover of the same typool-prefixed name.
 * typool prefixes these same-TU helpers with backend_call_dispatch_
 * on the DIG image (they are not export in the .x); the thin calls
 * those real first-wins symbols rather than inventing stubs:
 * try_fold_size_align_of_call_elf, try_emit_raw_syscall_call_elf_c,
 * try_emit_va_cap_builtin_call_elf_c, try_emit_atomic_builtin_call_elf_c,
 * try_emit_simd_lang_builtin_call_elf_c, glue_sysv_spill_rax_rdx_to_frame_c.
 */
#include <stdint.h>
#include <string.h>

/* typool same-TU prefix; body names stay source-faithful. */
#define try_fold_size_align_of_call_elf backend_call_dispatch_try_fold_size_align_of_call_elf
#define try_emit_raw_syscall_call_elf_c backend_call_dispatch_try_emit_raw_syscall_call_elf_c
#define try_emit_va_cap_builtin_call_elf_c backend_call_dispatch_try_emit_va_cap_builtin_call_elf_c
#define try_emit_atomic_builtin_call_elf_c backend_call_dispatch_try_emit_atomic_builtin_call_elf_c
#define try_emit_simd_lang_builtin_call_elf_c backend_call_dispatch_try_emit_simd_lang_builtin_call_elf_c
#define glue_sysv_spill_rax_rdx_to_frame_c backend_call_dispatch_glue_sysv_spill_rax_rdx_to_frame_c

int32_t backend_enc_blr_arch(uint8_t *elf_ctx, int32_t reg, int32_t ta);
int32_t backend_enc_call_stack_cleanup_arch(uint8_t *elf_ctx, int32_t nbytes, int32_t ta);
int32_t backend_enc_ldr_xreg_xreg_imm_arch(uint8_t *elf_ctx, int32_t dt, int32_t base, int32_t imm, int32_t ta);
int32_t backend_enc_load_rbp_to_rax_arch(uint8_t *elf_ctx, int32_t offset, int32_t ta);
uint8_t *call_dispatch_load_ptr_le(uint8_t *p, int32_t off);
int32_t glue_asm_build_call_export_sym_c(uint8_t *arena, int32_t call_expr_ref, int32_t callee_ref, uint8_t *mod, uint8_t *dep_pipe, uint8_t *out, int32_t out_cap);
int32_t glue_asm_call_stack_cleanup_bytes(int32_t ta, int32_t nargs);
int32_t glue_asm_emit_call_with_cleanup(uint8_t *arena, uint8_t *elf_ctx, int32_t expr_ref, uint8_t *ctx, int32_t ta, int32_t nargs, uint8_t *cname, int32_t clen);
int32_t glue_asm_enc_call_redirected(uint8_t *elf_ctx, uint8_t *name, int32_t name_len, int32_t ta);
int32_t glue_asm_fill_c_prefix_from_module_import(uint8_t *mod, int32_t ix, uint8_t *pre);
int32_t glue_asm_import_binding_name_equal(uint8_t *mod, int32_t ix, uint8_t *nm, int32_t nlen);
int32_t glue_asm_mangle_import_binding_call_sym_c(uint8_t *arena, uint8_t *ctx, int32_t expr_ref, uint8_t *mod_ref, int32_t imp_j, uint8_t *pre_buf, int32_t pre_len, uint8_t *field_name, int32_t field_len, int32_t is_method, uint8_t *sym_flat);
int32_t glue_asm_try_emit_fmt_any_import_call_elf_c(uint8_t *arena, uint8_t *elf_ctx, int32_t call_expr_ref, uint8_t *ctx, int32_t ta, uint8_t *pre_buf, int32_t pre_len, uint8_t *field_name, int32_t field_len);
int32_t glue_asm_try_emit_fmt_string_lit_import_call_elf_c(uint8_t *arena, uint8_t *elf_ctx, int32_t call_expr_ref, uint8_t *ctx, int32_t ta, uint8_t *pre_buf, int32_t pre_len, uint8_t *field_name, int32_t field_len);
int32_t glue_sysv_spill_rax_rdx_to_frame_c(uint8_t *elf, uint8_t *ctx, int32_t ta, int32_t gp_units);
uint8_t *link_abi_getenv(uint8_t *name);
int32_t parser_get_module_num_imports(uint8_t *mod);
uint8_t *pipeline_asm_emit_dep_pipe_c(void);
int32_t pipeline_asm_emit_call_args_elf_c(uint8_t *arena, uint8_t *elf_ctx, int32_t expr_ref, uint8_t *ctx, int32_t ta, int32_t nargs);
int32_t pipeline_asm_emit_expr_elf_c(uint8_t *arena, uint8_t *elf_ctx, int32_t expr_ref, uint8_t *ctx, int32_t ta);
int32_t pipeline_asm_resolve_whole_import_qualified_symbol_c(uint8_t *arena, uint8_t *cur_mod, int32_t callee_expr_ref, uint8_t *sym_flat, int32_t *out_match_imp_j);
int32_t pipeline_codegen_call_num_args_override(uint8_t *pre, int32_t plen, uint8_t *field, int32_t flen, int32_t nargs);
int32_t pipeline_expr_call_callee_ref_at(uint8_t *arena, int32_t expr_ref);
int32_t pipeline_expr_call_num_args_at(uint8_t *arena, int32_t expr_ref);
int32_t pipeline_expr_field_access_base_ref(uint8_t *arena, int32_t er);
void pipeline_expr_field_access_name_into(uint8_t *arena, int32_t er, uint8_t *out);
int32_t pipeline_expr_field_access_name_len(uint8_t *arena, int32_t er);
int32_t pipeline_expr_kind_ord_at(uint8_t *arena, int32_t expr_ref);
int32_t pipeline_expr_resolved_type_ref(uint8_t *arena, int32_t expr_ref);
int32_t pipeline_expr_unary_operand_ref_at(uint8_t *arena, int32_t expr_ref);
void pipeline_expr_var_name_into(uint8_t *arena, int32_t expr_ref, uint8_t *out64);
int32_t pipeline_expr_var_name_len(uint8_t *arena, int32_t expr_ref);
int32_t pipeline_module_import_kind_at(uint8_t *mod, int32_t ix);
int32_t pipeline_type_elem_ref_at(uint8_t *arena, int32_t type_ref);
int32_t pipeline_type_kind_ord_at(uint8_t *arena, int32_t type_ref);
int32_t try_call_wpo_mono_symbol_elf(uint8_t *arena, uint8_t *elf_ctx, int32_t expr_ref, uint8_t *ctx, int32_t ta);
int32_t try_call_wpo_mono_vector_lane_of_binop_call_elf(uint8_t *arena, uint8_t *elf_ctx, int32_t expr_ref, uint8_t *ctx, int32_t ta);
int32_t try_emit_atomic_builtin_call_elf_c(uint8_t *arena, uint8_t *elf_ctx, int32_t expr_ref, uint8_t *ctx, int32_t ta);
int32_t try_emit_raw_syscall_call_elf_c(uint8_t *arena, uint8_t *elf_ctx, int32_t expr_ref, uint8_t *ctx, int32_t ta);
int32_t try_emit_simd_lang_builtin_call_elf_c(uint8_t *arena, uint8_t *elf_ctx, int32_t expr_ref, uint8_t *ctx, int32_t ta);
int32_t try_emit_va_cap_builtin_call_elf_c(uint8_t *arena, uint8_t *elf_ctx, int32_t expr_ref, uint8_t *ctx, int32_t ta);
int32_t try_fold_size_align_of_call_elf(uint8_t *arena, uint8_t *elf_ctx, int32_t expr_ref, uint8_t *mod_ref, int32_t ta);
int32_t try_inline_param0_field_sum_call_elf(uint8_t *arena, uint8_t *elf_ctx, int32_t expr_ref, uint8_t *ctx, int32_t ta);
int32_t try_inline_param0_single_field_call_elf(uint8_t *arena, uint8_t *elf_ctx, int32_t expr_ref, uint8_t *ctx, int32_t ta);
int32_t try_inline_wpo_const_scalar_binop_call_elf(uint8_t *arena, uint8_t *elf_ctx, int32_t expr_ref, uint8_t *ctx, int32_t ta);
int32_t try_inline_wpo_const_vector_lane_of_binop_call_elf(uint8_t *arena, uint8_t *elf_ctx, int32_t expr_ref, uint8_t *ctx, int32_t ta);
int32_t try_inline_x_plus_k_call_elf(uint8_t *arena, uint8_t *elf_ctx, int32_t expr_ref, uint8_t *ctx, int32_t ta);

int32_t backend_call_dispatch_w1521_emit_call_body(uint8_t *arena, uint8_t *elf_ctx, int32_t expr_ref, uint8_t *ctx, int32_t ta) {

  if (arena == (uint8_t *)0) { return 0 - 1; }
  if (elf_ctx == 0) { return 0 - 1; }
  if (ctx == (uint8_t *)0) { return 0 - 1; }
  {
    int32_t callee_ref = pipeline_expr_call_callee_ref_at(arena, expr_ref);
    if (callee_ref <= 0) { return 0 - 1; }
    uint8_t *mod_ref = call_dispatch_load_ptr_le(ctx, 16);
    // PLATFORM: SHARED LP64 — dep_pipe@1384 (pipeline_abi authority; not 1256).
    // Fallback: process-local set by pipeline_asm_emit_set_dep_pipe (try_inline twin).
    uint8_t *dep_pipe = call_dispatch_load_ptr_le(ctx, 1384);
    if (dep_pipe == (uint8_t *)0) {
      dep_pipe = pipeline_asm_emit_dep_pipe_c();
    }
    int32_t callee_ko = pipeline_expr_kind_ord_at(arena, callee_ref);
    /* CORE-001: size_of<T>/align_of<T> → imm (before import mangle → core_types_size_of). */
    {
      int32_t sa_rc = try_fold_size_align_of_call_elf(arena, elf_ctx, expr_ref, mod_ref, ta);
      if (sa_rc < 0) { return 0 - 1; }
      if (sa_rc > 0) { return 0; }
    }
    /* stage10 S3.1 slice2 (10.1.1): raw_syscall0..6 → direct syscall
     * (before import mangle; same slot as the size_of fold). */
    {
      int32_t rs_rc = try_emit_raw_syscall_call_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
      if (rs_rc < 0) { return 0 - 1; }
      if (rs_rc > 0) { return 0; }
    }
    /* Cap 10.7.1 slice12–16: va_start/end/va_arg_{i32,i64,ptr}/va_arg<T> Cap (GP+FP). */
    {
      int32_t va_rc = try_emit_va_cap_builtin_call_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
      if (va_rc < 0) { return 0 - 1; }
      if (va_rc > 0) { return 0; }
    }
    /* 10.4.1 slice1: atomic_load/store/cas_i32 CALL (x86_64 only). */
    {
      int32_t at_rc = try_emit_atomic_builtin_call_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
      if (at_rc < 0) { return 0 - 1; }
      if (at_rc > 0) { return 0; }
    }
    /* 10.5.1 slice0: add_f32x4 / mul_f32x4 language SIMD builtins (x86 SSE). */
    {
      int32_t sd_rc = try_emit_simd_lang_builtin_call_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
      if (sd_rc < 0) { return 0 - 1; }
      if (sd_rc > 0) { return 0; }
    }
    /*
     * Cap-fn-ptr (10.3.2) / TYPE_FN (10.3.1): CALL through *u8 or TYPE_FN.
     * typeck stamps Cap as TYPE_PTR(u8) or TYPE_FN(18). Emit callee → rax/x0,
     * then blr / call *reg (G.7 reuse backend_enc_blr_arch; same as F7 dyn).
     * slice1: 0-arg. slice2: GP args via spill fn + pipeline_asm_emit_call_args_elf_c
     * then reload fn (args would otherwise clobber rax before blr).
     * PLATFORM: SHARED · LINUX x86_64 call *r · MACOS|ARM64 blr xN.
     */
    {
      int32_t cap_tr = 0;
      int32_t cap_ko = 0;
      int32_t cap_er = 0;
      int32_t cap_eko = 0;
      int32_t cap_nargs = 0;
      int32_t cap_eff = callee_ref;
      int32_t cap_fn_off = 0;
      int32_t cap_ok = 0;
      if (callee_ko == 51 || callee_ko == 52) {
        /* EXPR_ADDR_OF / EXPR_DEREF — peel so Cap *u8 / TYPE_FN VAR is visible.
         * (*f)() → DEREF(VAR); Cap ≡ f() (emit pointer value, not u8 load). */
        int32_t inn = pipeline_expr_unary_operand_ref_at(arena, callee_ref);
        if (inn > 0) { cap_eff = inn; }
      }
      cap_tr = pipeline_expr_resolved_type_ref(arena, cap_eff);
      if (cap_tr > 0) {
        cap_ko = pipeline_type_kind_ord_at(arena, cap_tr);
        /* TYPE_FN (18) shares Cap opaque fn-ptr ABI with *u8. */
        if (cap_ko == 18) {
          cap_ok = 1;
        } else if (cap_ko == 9) {
          cap_er = pipeline_type_elem_ref_at(arena, cap_tr);
          if (cap_er > 0) {
            cap_eko = pipeline_type_kind_ord_at(arena, cap_er);
            if (cap_eko == 2) {
              cap_ok = 1;
            }
          }
        }
        if (cap_ok != 0) {
              cap_nargs = pipeline_expr_call_num_args_at(arena, expr_ref);
              if (cap_nargs < 0) { return 0 - 1; }
              /*
               * Cap opaque *u8 / TYPE_FN: reuse pipeline_asm_emit_call_args_elf_c
               * for GP regs + stack spill (SysV 6 / AAPCS64 8). slice2 was
               * reg-only; slice4 lifts the reg_max hard-fail (G.7 same packer
               * as direct CALL). PLATFORM: SHARED.
               */
              if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, cap_eff, ctx, ta) != 0) {
                return 0 - 1;
              }
              if (cap_nargs == 0) {
                /* rax/x0 = Cap-fn-ptr; indirect call. */
                if (backend_enc_blr_arch(elf_ctx, 0, ta) != 0) { return 0 - 1; }
                return 0;
              }
              /* Spill fn, pack args into ABI regs, reload fn, blr. */
              cap_fn_off = glue_sysv_spill_rax_rdx_to_frame_c(elf_ctx, ctx, ta, 1);
              if (cap_fn_off < 0) { return 0 - 1; }
              if (pipeline_asm_emit_call_args_elf_c(arena, elf_ctx, expr_ref, ctx, ta, cap_nargs) != 0) {
                return 0 - 1;
              }
              /* PLATFORM: MACOS|ARM64 uses non-arg volatile scratch x9 (ta==1)
               * so reloading the fn ptr does not clobber argument x0. SysV x86_64
               * uses rax (ta==0) as rax is not an argument register. */
              if (ta == 1) {
                if (backend_enc_ldr_xreg_xreg_imm_arch(elf_ctx, 9, 29, cap_fn_off, ta) != 0) {
                  return 0 - 1;
                }
                if (backend_enc_blr_arch(elf_ctx, 9, ta) != 0) { return 0 - 1; }
              } else {
                if (backend_enc_load_rbp_to_rax_arch(elf_ctx, cap_fn_off, ta) != 0) {
                  return 0 - 1;
                }
                if (backend_enc_blr_arch(elf_ctx, 0, ta) != 0) { return 0 - 1; }
              }
              return 0;
        }
      }
    }
    // See implementation.
    if (callee_ko == 44) {
      uint8_t pre_fmt[16];
      memset(pre_fmt, 0, sizeof(pre_fmt));
      pre_fmt[0] = 115; pre_fmt[1] = 116; pre_fmt[2] = 100; pre_fmt[3] = 95;
      pre_fmt[4] = 102; pre_fmt[5] = 109; pre_fmt[6] = 116; pre_fmt[7] = 95;
      uint8_t fn_println[16];
      memset(fn_println, 0, sizeof(fn_println));
      fn_println[0] = 112; fn_println[1] = 114; fn_println[2] = 105; fn_println[3] = 110;
      fn_println[4] = 116; fn_println[5] = 108; fn_println[6] = 110;
      int32_t fa_lit = glue_asm_try_emit_fmt_string_lit_import_call_elf_c(
        arena, elf_ctx, expr_ref, ctx, ta, &pre_fmt[0], 8, &fn_println[0], 7
      );
      if (fa_lit < 0) { return 0 - 1; }
      if (fa_lit > 0) { return 0; }
      uint8_t fn_print[16];
      memset(fn_print, 0, sizeof(fn_print));
      fn_print[0] = 112; fn_print[1] = 114; fn_print[2] = 105; fn_print[3] = 110; fn_print[4] = 116;
      fa_lit = glue_asm_try_emit_fmt_string_lit_import_call_elf_c(
        arena, elf_ctx, expr_ref, ctx, ta, &pre_fmt[0], 8, &fn_print[0], 5
      );
      if (fa_lit < 0) { return 0 - 1; }
      if (fa_lit > 0) { return 0; }
    }
    // import binding + binding.field(args)
    if (mod_ref != 0) {
      if (callee_ko == 44) {
        int32_t base_ref = pipeline_expr_field_access_base_ref(arena, callee_ref);
        if (base_ref > 0) {
          if (pipeline_expr_kind_ord_at(arena, base_ref) == 3) {
            int32_t base_len = pipeline_expr_var_name_len(arena, base_ref);
            if (base_len > 0) {
              // wave580 Cap: binding/field name content cap 255 (AST u8[256]).
              if (base_len <= 255) {
                uint8_t base_name[256];
                memset(base_name, 0, sizeof(base_name));
                pipeline_expr_var_name_into(arena, base_ref, &base_name[0]);
                int32_t field_len = pipeline_expr_field_access_name_len(arena, callee_ref);
                if (field_len > 0) {
                  if (field_len <= 255) {
                    uint8_t field_name[256];
                    memset(field_name, 0, sizeof(field_name));
                    pipeline_expr_field_access_name_into(arena, callee_ref, &field_name[0]);
                    int32_t j = 0;
                    int32_t nimp = parser_get_module_num_imports(mod_ref);
                    while (j < nimp) {
                      if (pipeline_module_import_kind_at(mod_ref, j) == 1) {
                        if (glue_asm_import_binding_name_equal(mod_ref, j, &base_name[0], base_len) != 0) {
                          uint8_t pre_buf[128];
                          memset(pre_buf, 0, sizeof(pre_buf));
                          int32_t pre_len = glue_asm_fill_c_prefix_from_module_import(mod_ref, j, &pre_buf[0]);
                          if (pre_len <= 0) { return 0 - 1; }
                          uint8_t sym_flat[256];
                          memset(sym_flat, 0, sizeof(sym_flat));
                          /* PLATFORM: SHARED — G.7 import-binding CALL mangle (same as METHOD). */
                          int32_t sym_len = glue_asm_mangle_import_binding_call_sym_c(
                            arena, ctx, expr_ref, mod_ref, j, &pre_buf[0], pre_len,
                            &field_name[0], field_len, 0, &sym_flat[0]
                          );
                          if (sym_len <= 0) { return 0 - 1; }
                          int32_t fmt_lit = glue_asm_try_emit_fmt_string_lit_import_call_elf_c(
                            arena, elf_ctx, expr_ref, ctx, ta, &pre_buf[0], pre_len, &field_name[0], field_len
                          );
                          if (fmt_lit < 0) { return 0 - 1; }
                          if (fmt_lit > 0) { return 0; }
                          int32_t fmt_any_c = glue_asm_try_emit_fmt_any_import_call_elf_c(
                            arena, elf_ctx, expr_ref, ctx, ta, &pre_buf[0], pre_len, &field_name[0], field_len
                          );
                          if (fmt_any_c < 0) { return 0 - 1; }
                          if (fmt_any_c > 0) { return 0; }
                          int32_t call_nargs = pipeline_expr_call_num_args_at(arena, expr_ref);
                          int32_t n_ov = pipeline_codegen_call_num_args_override(
                            &pre_buf[0], pre_len, &field_name[0], field_len, call_nargs
                          );
                          if (pipeline_asm_emit_call_args_elf_c(arena, elf_ctx, expr_ref, ctx, ta, n_ov) != 0) {
                            return 0 - 1;
                          }
                          if (glue_asm_enc_call_redirected(elf_ctx, &sym_flat[0], sym_len, ta) != 0) {
                            return 0 - 1;
                          }
                          int32_t cln = glue_asm_call_stack_cleanup_bytes(ta, n_ov);
                          if (cln < 0) { return 0 - 1; }
                          if (backend_enc_call_stack_cleanup_arch(elf_ctx, cln, ta) != 0) { return 0 - 1; }
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
        }
      }
    }
    // See implementation.
    if (mod_ref != 0) {
      if (callee_ko == 44) {
        int32_t imp_elt = 0;
        uint8_t sym_eh[256];
        memset(sym_eh, 0, sizeof(sym_eh));
        int32_t elen = pipeline_asm_resolve_whole_import_qualified_symbol_c(
          arena, mod_ref, callee_ref, &sym_eh[0], &imp_elt
        );
        if (elen > 0) {
          if (imp_elt >= 0) {
            if (imp_elt < parser_get_module_num_imports(mod_ref)) {
              int32_t field_len2 = pipeline_expr_field_access_name_len(arena, callee_ref);
              if (field_len2 <= 0) { return 0 - 1; }
              if (field_len2 > 127) { return 0 - 1; }
              uint8_t field_name2[256];
              memset(field_name2, 0, sizeof(field_name2));
              pipeline_expr_field_access_name_into(arena, callee_ref, &field_name2[0]);
              uint8_t pre_eb[128];
              memset(pre_eb, 0, sizeof(pre_eb));
              int32_t pre_el = glue_asm_fill_c_prefix_from_module_import(mod_ref, imp_elt, &pre_eb[0]);
              if (pre_el <= 0) { return 0 - 1; }
              int32_t call_nargs2 = pipeline_expr_call_num_args_at(arena, expr_ref);
              int32_t n_wo_elf = pipeline_codegen_call_num_args_override(
                &pre_eb[0], pre_el, &field_name2[0], field_len2, call_nargs2
              );
              if (pipeline_asm_emit_call_args_elf_c(arena, elf_ctx, expr_ref, ctx, ta, n_wo_elf) != 0) {
                return 0 - 1;
              }
              if (glue_asm_enc_call_redirected(elf_ctx, &sym_eh[0], elen, ta) != 0) { return 0 - 1; }
              int32_t cln2 = glue_asm_call_stack_cleanup_bytes(ta, n_wo_elf);
              if (cln2 < 0) { return 0 - 1; }
              if (backend_enc_call_stack_cleanup_arch(elf_ctx, cln2, ta) != 0) { return 0 - 1; }
              return 0;
            }
          }
        }
      }
    }
    // See implementation.
    if (callee_ko != 3) { return 0 - 1; }
    int32_t nargs = pipeline_expr_call_num_args_at(arena, expr_ref);
    if (nargs < 0) { return 0 - 1; }
    if (nargs > 96) { return 0 - 1; }
    int32_t inline_rc = try_inline_param0_single_field_call_elf(arena, elf_ctx, expr_ref, ctx, ta);
    if (inline_rc != 0) {
      if (inline_rc < 0) { return 0 - 1; }
      return 0;
    }
    inline_rc = try_inline_param0_field_sum_call_elf(arena, elf_ctx, expr_ref, ctx, ta);
    if (inline_rc != 0) {
      if (inline_rc < 0) { return 0 - 1; }
      return 0;
    }
    inline_rc = try_inline_x_plus_k_call_elf(arena, elf_ctx, expr_ref, ctx, ta);
    if (inline_rc != 0) {
      if (inline_rc < 0) { return 0 - 1; }
      return 0;
    }
    inline_rc = try_call_wpo_mono_symbol_elf(arena, elf_ctx, expr_ref, ctx, ta);
    if (inline_rc != 0) {
      if (inline_rc < 0) { return 0 - 1; }
      return 0;
    }
    inline_rc = try_call_wpo_mono_vector_lane_of_binop_call_elf(arena, elf_ctx, expr_ref, ctx, ta);
    if (inline_rc != 0) {
      if (inline_rc < 0) { return 0 - 1; }
      return 0;
    }
    // See implementation.
    uint8_t kmono[16];
    memset(kmono, 0, sizeof(kmono));
    kmono[0] = 83; kmono[1] = 72; kmono[2] = 85; kmono[3] = 88; kmono[4] = 95;
    kmono[5] = 87; kmono[6] = 80; kmono[7] = 79; kmono[8] = 95;
    kmono[9] = 77; kmono[10] = 79; kmono[11] = 78; kmono[12] = 79; kmono[13] = 0;
    uint8_t knofold[20];
    memset(knofold, 0, sizeof(knofold));
    knofold[0] = 83; knofold[1] = 72; knofold[2] = 85; knofold[3] = 88; knofold[4] = 95;
    knofold[5] = 87; knofold[6] = 80; knofold[7] = 79; knofold[8] = 95;
    knofold[9] = 78; knofold[10] = 79; knofold[11] = 95;
    knofold[12] = 70; knofold[13] = 79; knofold[14] = 76; knofold[15] = 68; knofold[16] = 0;
    // wave231 G.7: XLANG_WPO_MONO / XLANG_WPO_NO_FOLD via link_abi_getenv (not raw getenv).
    // Const fold only when neither mono nor no-fold env is set.
    if (link_abi_getenv(&kmono[0]) == 0) {
      if (link_abi_getenv(&knofold[0]) == 0) {
        inline_rc = try_inline_wpo_const_vector_lane_of_binop_call_elf(arena, elf_ctx, expr_ref, ctx, ta);
        if (inline_rc != 0) {
          if (inline_rc < 0) { return 0 - 1; }
          return 0;
        }
        inline_rc = try_inline_wpo_const_scalar_binop_call_elf(arena, elf_ctx, expr_ref, ctx, ta);
        if (inline_rc != 0) {
          if (inline_rc < 0) { return 0 - 1; }
          return 0;
        }
      }
    }
    int32_t clen0 = pipeline_expr_var_name_len(arena, callee_ref);
    if (clen0 <= 0) { return 0 - 1; }
    // Cap 4.2.8: AST name content cap 255 (was wave580 hard-reject >127 → asm -o CG002).
    if (clen0 > 255) { return 0 - 1; }
    uint8_t cname[256];
    memset(cname, 0, sizeof(cname));
    // Cap 4.2.8: out_cap must match cname[256] / AST name content cap 255 (was 128).
    // PLATFORM: SHARED — Darwin '_' is applied in enc_call/enc_label, not here.
    int32_t clen = glue_asm_build_call_export_sym_c(arena, expr_ref, callee_ref, mod_ref, dep_pipe, &cname[0], 256);
    if (clen <= 0) { return 0 - 1; }
    return glue_asm_emit_call_with_cleanup(arena, elf_ctx, expr_ref, ctx, ta, nargs, &cname[0], clen);
  }
  return 0 - 1;
}
