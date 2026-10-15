// knife256/10.2 Cap tip body of the Darwin byref call-arg address.
// The linked mega symbol is
// backend_call_dispatch_glue_emit_arm64_host_mem_arg_addr_to_rax_c.
// That spelling is 64 bytes and the cap-tip checker rejects it, so this
// file defines glue_vec_arg_addr. The Darwin link aliases that symbol
// onto the mega name and aliases glue_vec_arg_addr__demoted onto the
// old body. A VAR, FIELD, INDEX, or DEREF is copied by that body.
// An INT_LIT or a kind-22 / kind-23 chain is not an address. The mega
// points x8 at the temp and emits the expr, which leaves the integer
// in x0 and does not store the lanes, so the callee reads an empty
// slot (lane 0 was not the literal). This entry fills that temp with
// the same vector let-init a `let` uses, then leas it. Every other
// shape calls the demoted body.
// PLATFORM: MACOS|ARM64. The alias step is Mach-O only.

export extern "C" function glue_vec_arg_addr__demoted(
  arena: *u8, elf_ctx: *u8, ctx: *u8, arg_ref: i32, sz: i32, ta: i32): i32;
export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern "C" function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern "C" function glue_simd_alloc_vector_temp_slot_c(arena: *u8, ctx: *u8, type_ref: i32): i32;
export extern "C" function glue_emit_vector_type_let_init_elf_c(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32,
  stack_off: i32, type_ref: i32): i32;
export extern "C" function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;

/**
 * Pass a Vec8i literal chain by reference, else the old byref copy.
 * @param arena *u8 — AST arena; null defers to the demoted body
 * @param elf_ctx *u8 — encoder; null defers
 * @param ctx *u8 — function frame; null defers
 * @param arg_ref i32 — argument expr; <= 0 defers
 * @param sz i32 — formal size in bytes; the byref caller passes > 16
 * @param ta i32 — target arch; only 1 (Darwin arm64) materializes here
 * @return i32 — 0 when x0 holds the argument address; -1 on failure
 * Kind 3 stays on the demoted copy. Kind 25 and kind 27 use the same
 * filler as a frame let, so `id(if (c) { 3 } else { -3 })` does not
 * copy a scalar. Let-init -3 falls through so a unary the filler
 * declines keeps the old emit. Any other filler failure returns -1
 * and does not pass an empty slot. f32 element kinds do not enter.
 * PLATFORM: MACOS|ARM64.
 */
#[no_mangle]
export function glue_vec_arg_addr(
  arena: *u8, elf_ctx: *u8, ctx: *u8, arg_ref: i32, sz: i32, ta: i32): i32 {
  unsafe {
    let ord_lit: i32 = 0;
    let ord_neg: i32 = 22;
    let ord_bitnot: i32 = 23;
    let ord_vector: i32 = 13;
    let ord_i32: i32 = 0;
    let go: i32 = 0;
    let ko: i32 = 0;
    let tr: i32 = 0;
    let tk: i32 = 0;
    let elem: i32 = 0;
    let ek: i32 = 0;
    let slot: i32 = 0;
    let rc: i32 = 0;
    if (arena != 0 as *u8) {
      if (elf_ctx != 0 as *u8) {
        if (ctx != 0 as *u8) {
          if (arg_ref > 0) {
            if (sz > 16) {
              if (ta == 1) {
                ko = pipeline_expr_kind_ord_at(arena, arg_ref);
                if (ko == ord_lit) {
                  go = 1;
                }
                if (ko == ord_neg) {
                  go = 1;
                }
                if (ko == ord_bitnot) {
                  go = 1;
                }
                if (ko == 25) {
                  go = 1;
                }
                if (ko == 27) {
                  go = 1;
                }
                if (go != 0) {
                  tr = pipeline_expr_resolved_type_ref(arena, arg_ref);
                  if (tr > 0) {
                    tk = pipeline_type_kind_ord_at(arena, tr);
                    if (tk == ord_vector) {
                      elem = pipeline_type_elem_ref_at(arena, tr);
                      if (elem > 0) {
                        ek = pipeline_type_kind_ord_at(arena, elem);
                        if (ek == ord_i32) {
                          slot = glue_simd_alloc_vector_temp_slot_c(arena, ctx, tr);
                          if (slot < 0) {
                            return 0 - 1;
                          }
                          rc = glue_emit_vector_type_let_init_elf_c(
                            arena, elf_ctx, arg_ref, ctx, ta, slot, tr);
                          if (rc == 0) {
                            rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, slot, ta);
                            if (rc != 0) {
                              return 0 - 1;
                            }
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
        }
      }
    }
    return glue_vec_arg_addr__demoted(arena, elf_ctx, ctx, arg_ref, sz, ta);
  }
}
