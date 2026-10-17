// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// Call-arg entry for `{ xs: [1.0, 2.0] }.xs` passed to a []T formal.
// Let-init already durables that ARRAY_LIT and stores N. The call-arg
// path emits the FIELD through the general expr emitter, which returns
// -1 (CG002) once the base is a struct literal. This prefix durables
// the matching field literal by emitting that ARRAY_LIT under the
// slice formal. The existing literal emitter writes {data, length}
// and leaves the fat's address in x0, which is what a []T parameter
// loads. Every other argument calls the previous object. Name copies
// clear 256 bytes.
// PLATFORM: MACOS|ARM64 · LINUX x86_64. The alias of the previous
// body is the Darwin link step.

export extern function glue_emit_one_call_arg_elf_c_prev(arena: *u8, elf_ctx: *u8, call_expr_ref: i32, arg_ref: i32, arg_index: i32, ctx: *u8, ta: i32): i32;
export extern function glue_call_param_type_ref_at(arena: *u8, call_expr_ref: i32, param_index: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, tr: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern function pipeline_expr_struct_lit_num_fields(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_struct_lit_field_name_len(arena: *u8, expr_ref: i32, j: i32): i32;
export extern function pipeline_expr_struct_lit_field_name_into(arena: *u8, expr_ref: i32, j: i32, out: *u8): void;
export extern function pipeline_expr_struct_lit_init_ref(arena: *u8, expr_ref: i32, j: i32): i32;
export extern function pipeline_expr_array_lit_num_elems_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern function glue_array_lit_force_esz_from_elem_type_c(arena: *u8, et: i32): i32;
export extern function glue_asm_emit_array_lit_durable_ptr_rax_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, force_esz: i32, ta: i32, ctx: *u8, dest_elem_ty: i32): i32;
export extern function pipe_asm_ctx_off_next_offset(): i32;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function glue_align_next_offset(ctx: *u8): void;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_mov_imm64_to_rax_arch(elf_ctx: *u8, lo: i32, hi: i32, ta: i32): i32;
export extern function glue_slice_dual_gp_length_off_c(data_home: i32, ta: i32): i32;

/**
 * Emit one call argument. A slice formal whose argument is a struct
 * literal's array field is a durable pointer plus N. Anything else is
 * the previous emitter.
 * @param arena *u8 — caller expression pool; null defers to the previous body
 * @param elf_ctx *u8 — object writer; null defers
 * @param call_expr_ref i32 — the call; not positive defers
 * @param arg_ref i32 — the argument expr; not positive defers
 * @param arg_index i32 — formal index; negative defers
 * @param ctx *u8 — asm function context; null defers
 * @param ta i32 — 1 is arm64 (length in x1); any other target uses rdx
 * @return i32 — 0 when x0 holds the address of the {data, length} fat;
 *   -1 when the durable pointer or a store fails; the previous body's
 *   result for every other argument
 * The formal must be TYPE_SLICE (11). The base must be STRUCT_LIT (45)
 * and the named field's initializer must be ARRAY_LIT (46). N is 1..1024.
 * The fat home is the same next_offset bump a local [N]T argument uses:
 * data at home, length at the dual-GP length slot, x0 is lea of home.
 * A []T parameter loads length from that object, not from x1. A miss
 * does not emit. PLATFORM: SHARED.
 */
#[no_mangle]
export function glue_emit_one_call_arg_elf_c(arena: *u8, elf_ctx: *u8, call_expr_ref: i32, arg_ref: i32, arg_index: i32, ctx: *u8, ta: i32): i32 {
  // PLATFORM: SHARED — slice formal of a struct-literal array field.
  unsafe {
    let ord_field: i32 = 44;
    let ord_struct: i32 = 45;
    let ord_array_lit: i32 = 46;
    let ord_slice: i32 = 11;
    let pty: i32 = 0;
    let pk: i32 = 0;
    let ko: i32 = 0;
    let base_er: i32 = 0;
    let base_k: i32 = 0;
    let fa_len: i32 = 0;
    let nf: i32 = 0;
    let fj: i32 = 0;
    let sl_len: i32 = 0;
    let bi: i32 = 0;
    let same: i32 = 0;
    let init_f: i32 = 0;
    let lit: i32 = 0;
    let n_lit: i32 = 0;
    let elem_ty: i32 = 0;
    let esz: i32 = 0;
    let base_off: i32 = 0;
    let home: i32 = 0;
    let len_off: i32 = 0;
    let rc: i32 = 0;
    let fa_name: u8[256] = [];
    let sl_name: u8[256] = [];
    if (arena == 0 as *u8) {
      return glue_emit_one_call_arg_elf_c_prev(arena, elf_ctx, call_expr_ref, arg_ref, arg_index, ctx, ta);
    }
    if (elf_ctx == 0 as *u8) {
      return glue_emit_one_call_arg_elf_c_prev(arena, elf_ctx, call_expr_ref, arg_ref, arg_index, ctx, ta);
    }
    if (ctx == 0 as *u8) {
      return glue_emit_one_call_arg_elf_c_prev(arena, elf_ctx, call_expr_ref, arg_ref, arg_index, ctx, ta);
    }
    if (call_expr_ref <= 0) {
      return glue_emit_one_call_arg_elf_c_prev(arena, elf_ctx, call_expr_ref, arg_ref, arg_index, ctx, ta);
    }
    if (arg_ref <= 0) {
      return glue_emit_one_call_arg_elf_c_prev(arena, elf_ctx, call_expr_ref, arg_ref, arg_index, ctx, ta);
    }
    if (arg_index < 0) {
      return glue_emit_one_call_arg_elf_c_prev(arena, elf_ctx, call_expr_ref, arg_ref, arg_index, ctx, ta);
    }
    pty = glue_call_param_type_ref_at(arena, call_expr_ref, arg_index);
    if (pty > 0) {
      pk = pipeline_type_kind_ord_at(arena, pty);
    }
    if (pk == ord_slice) {
      ko = pipeline_expr_kind_ord_at(arena, arg_ref);
      if (ko == ord_field) {
        base_er = pipeline_expr_field_access_base_ref(arena, arg_ref);
        if (base_er > 0) {
          base_k = pipeline_expr_kind_ord_at(arena, base_er);
        }
        if (base_k == ord_struct) {
          fa_len = pipeline_expr_field_access_name_len(arena, arg_ref);
          if (fa_len > 0) {
            if (fa_len <= 255) {
              pipeline_expr_field_access_name_into(arena, arg_ref, &fa_name[0]);
              nf = pipeline_expr_struct_lit_num_fields(arena, base_er);
              fj = 0;
              lit = 0;
              while (fj < nf) {
                if (lit == 0) {
                  sl_len = pipeline_expr_struct_lit_field_name_len(arena, base_er, fj);
                  if (sl_len == fa_len) {
                    pipeline_expr_struct_lit_field_name_into(arena, base_er, fj, &sl_name[0]);
                    bi = 0;
                    same = 1;
                    while (bi < fa_len) {
                      if (fa_name[bi] != sl_name[bi]) {
                        same = 0;
                      }
                      bi = bi + 1;
                    }
                    if (same != 0) {
                      init_f = pipeline_expr_struct_lit_init_ref(arena, base_er, fj);
                      if (init_f > 0) {
                        if (pipeline_expr_kind_ord_at(arena, init_f) == ord_array_lit) {
                          lit = init_f;
                        }
                      }
                    }
                  }
                }
                fj = fj + 1;
              }
              if (lit > 0) {
                n_lit = pipeline_expr_array_lit_num_elems_at(arena, lit);
                if (n_lit > 0) {
                  if (n_lit <= 1024) {
                    // Reserve the fat before the literal write. Same
                    // next_offset step as a local [N]T passed to []T.
                    // arm64 keeps 16 bytes past the length slot; SysV
                    // keeps 8. PLATFORM: MACOS|ARM64 · LINUX x86_64.
                    base_off = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
                    if ((base_off % 8) != 0) {
                      base_off = (base_off + 7) / 8 * 8;
                    }
                    home = base_off + 16;
                    if (ta == 1) {
                      pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), home + 16);
                    } else {
                      pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), home + 8);
                    }
                    glue_align_next_offset(ctx);
                    elem_ty = pipeline_type_elem_ref_at(arena, pty);
                    esz = glue_array_lit_force_esz_from_elem_type_c(arena, elem_ty);
                    if (glue_asm_emit_array_lit_durable_ptr_rax_elf_c(arena, elf_ctx, lit, esz, ta, ctx, elem_ty) != 0) {
                      return 0 - 1;
                    }
                    rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta);
                    if (rc != 0) {
                      return 0 - 1;
                    }
                    rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_lit, 0, ta);
                    if (rc != 0) {
                      return 0 - 1;
                    }
                    len_off = glue_slice_dual_gp_length_off_c(home, ta);
                    rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, len_off, ta);
                    if (rc != 0) {
                      return 0 - 1;
                    }
                    rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta);
                    if (rc != 0) {
                      return 0 - 1;
                    }
                    return 0;
                  }
                }
              }
            }
          }
        }
      }
    }
    return glue_emit_one_call_arg_elf_c_prev(arena, elf_ctx, call_expr_ref, arg_ref, arg_index, ctx, ta);
  }
}
