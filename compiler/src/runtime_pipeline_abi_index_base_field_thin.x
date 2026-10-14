// Thin pure overlay (w1521, 终局待办 10.57): INDEX base effective address
// for `v.p[i]` where p is a *T struct field. The pabi body peels the pointer
// field once inside the FIELD branch (glue_index_deref_ptr_field_slot_rax_elf_c)
// and then again in the trailing non-slice arm (base_ko == 44), so the element
// load read *(*(v.p)) (read_ptr_view_smoke / p_pv: address = string bytes).
// Same body as runtime_pipeline_abi.x glue_emit_index_eff_addr_base_elf_c,
// except the trailing FIELD peel is skipped when the field type is PTR (9):
// that peel already happened. SLICE fields and every other base are unchanged.
// Why an overlay: the impl lives in runtime_pipeline_abi.x (pabi, frozen;
// Darwin / Linux / Win link the pabi_weak object). Merge back list: 10.26.
// Linked by g05_relink_env (_g05_pure_overlay index_base_field) before
// seeds; pabi_weak.o _glue_emit_index_eff_addr_base_elf_c weakened.
// PLATFORM: SHARED (ELF / Mach-O / COFF emit, all ta).

export extern function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_is_enum_variant(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function glue_field_access_effective_offset_c(arena: *u8, mod: *u8, fa_ref: i32): i32;
export extern function pipeline_expr_var_name_len(arena: *u8, er: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, er: i32, out: *u8): void;
export extern function asm_ctx_local_find_offset_scoped(ctx: *u8, arena: *u8, name: *u8, name_len: i32): i32;
export extern function glue_enc_local_slot_ptr_or_addr_elf_c(
  arena: *u8, elf_ctx: *u8, var_ref: i32, var_off: i32, ctx: *u8, ta: i32
): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_add_imm_to_rax_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function glue_index_deref_ptr_field_slot_rax_elf_c(arena: *u8, elf_ctx: *u8, fa_ref: i32, ta: i32): i32;
export extern function pipeline_asm_emit_lvalue_eff_addr_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32
): i32;
export extern function pipeline_asm_modlet_load_to_rax_elf_c(elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32;
export extern function glue_var_expr_type_ref_with_decl_fallback_c(arena: *u8, base_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function backend_enc_load_64_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function glue_field_access_field_type_ref_c(arena: *u8, mod: *u8, fa_ref: i32): i32;
export extern function pipeline_asm_emit_ctx_module_get(): *u8;

/**
 * 1 when FIELD_ACCESS fa_ref has a PTR (9) field type, else 0.
 * PLATFORM: SHARED.
 */
function w1521_ib_field_is_ptr(arena: *u8, fa_ref: i32): i32 {
  let mod: *u8 = 0 as *u8;
  let ftr: i32 = 0;
  let fk: i32 = 0;
  unsafe {
    mod = pipeline_asm_emit_ctx_module_get();
    ftr = glue_field_access_field_type_ref_c(arena, mod, fa_ref);
  }
  if (ftr <= 0) {
    return 0;
  }
  unsafe {
    fk = pipeline_type_kind_ord_at(arena, ftr);
  }
  if (fk == 9) {
    return 1;
  }
  return 0;
}

/**
 * INDEX base effective address into x0.
 * A VAR field base (`h.v[i]`) is the local slot address plus the field
 * offset. A nested FIELD base (`w.h.v[i]`) uses the lvalue address of
 * the parent field. emit_expr of that parent loads the by-value bits, and
 * the lane load then uses those bits as a pointer (Darwin `w.h.v[0]`
 * exit 10). A PTR parent stays on emit_expr: that rvalue is already the
 * pointee address. An INDEX base (`arr[0][i]`) uses the lvalue address
 * of that inner INDEX. emit_expr of the inner INDEX loads the by-value
 * element, and the outer lane load then uses those bits as a pointer
 * (Darwin `arr[0][0]` exit 1). PTR and SLICE elements stay on emit_expr.
 * CALL and DEREF bases stay on emit_expr. Slice and pointer fields of
 * the indexed field still peel through
 * glue_index_deref_ptr_field_slot_rax_elf_c.
 * @param arena *u8 — AST arena; null is not expected (callers checked)
 * @param elf_ctx *u8 — encoder context
 * @param ix_ref i32 — INDEX expression; base ref <= 0 returns -1
 * @param ctx *u8 — asm function context; null is not expected
 * @param ta i32 — 0 x86_64, 1 arm64
 * @return i32 — 0 when x0 holds the element base address; -1 on a bad
 *   base or an encoder error
 * PLATFORM: SHARED body. Darwin ARM64 measured the nested-FIELD fail
 * and the nested-INDEX fail.
 */
#[no_mangle]
export function glue_emit_index_eff_addr_base_elf_c(arena: *u8, elf_ctx: *u8, ix_ref: i32, ctx: *u8, ta: i32): i32 {
  let base_ref: i32 = 0;
  let base_ko: i32 = 0;
  let tr: i32 = 0;
  let trk: i32 = 0;
  let fb_ref: i32 = 0;
  let field_off: i32 = 0;
  let vname: u8[256] = [];
  let vlen: i32 = 0;
  let off: i32 = 0;
  let is_enum: i32 = 0;
  let fb_ko: i32 = 0;
  let mod: *u8 = 0 as *u8;
  let rc: i32 = 0;
  let peeled_ptr: i32 = 0;
  unsafe {
    base_ref = pipeline_expr_index_base_ref(arena, ix_ref);
  }
  if (base_ref <= 0) {
    return 0 - 1;
  }
  unsafe {
    base_ko = pipeline_expr_kind_ord_at(arena, base_ref);
  }
  if (base_ko == 44) {
    unsafe {
      is_enum = pipeline_expr_field_access_is_enum_variant(arena, base_ref);
    }
  }
  if (base_ko == 44 && is_enum == 0) {
    unsafe {
      mod = pipeline_asm_emit_module_ref_c();
      fb_ref = pipeline_expr_field_access_base_ref(arena, base_ref);
      field_off = glue_field_access_effective_offset_c(arena, mod, base_ref);
    }
    if (fb_ref > 0) {
      unsafe {
        fb_ko = pipeline_expr_kind_ord_at(arena, fb_ref);
      }
    } else {
      fb_ko = 0;
    }
    if (fb_ref > 0 && fb_ko == 3) {
      unsafe {
        vlen = pipeline_expr_var_name_len(arena, fb_ref);
      }
      if (vlen <= 0 || vlen > 255) {
        return 0 - 1;
      }
      unsafe {
        pipeline_expr_var_name_into(arena, fb_ref, &vname[0]);
        off = asm_ctx_local_find_offset_scoped(ctx, arena, &vname[0], vlen);
      }
      if (off < 0) {
        return 0 - 1;
      }
      unsafe {
        rc = glue_enc_local_slot_ptr_or_addr_elf_c(arena, elf_ctx, fb_ref, off, ctx, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
    } else {
      if (fb_ref <= 0) {
        return 0 - 1;
      }
      // Nested FIELD only. CALL and DEREF stay rvalues.
      // PTR parent: emit_expr is the pointee address. By-value parent:
      // lvalue address, then the field offset below. Do not call lvalue
      // on base_ref itself — that already includes this field's offset.
      // PLATFORM: SHARED. Darwin ARM64 measured w.h.v[0].
      tr = 0;
      trk = 0;
      if (fb_ko == 44) {
        unsafe {
          tr = glue_field_access_field_type_ref_c(arena, mod, fb_ref);
        }
        if (tr > 0) {
          unsafe {
            trk = pipeline_type_kind_ord_at(arena, tr);
          }
        }
      }
      if (fb_ko == 44 && trk != 9) {
        unsafe {
          rc = pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, fb_ref, ctx, ta);
        }
      } else {
        unsafe {
          rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, fb_ref, ctx, ta);
        }
      }
      if (rc != 0) {
        return 0 - 1;
      }
    }
    if (field_off != 0) {
      unsafe {
        rc = backend_enc_add_imm_to_rax_arch(elf_ctx, field_off, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
    }
    unsafe {
      rc = glue_index_deref_ptr_field_slot_rax_elf_c(arena, elf_ctx, base_ref, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    peeled_ptr = w1521_ib_field_is_ptr(arena, base_ref);
  } else {
    if (base_ko == 3) {
      unsafe {
        vlen = pipeline_expr_var_name_len(arena, base_ref);
      }
      if (vlen <= 0 || vlen > 255) {
        return 0 - 1;
      }
      unsafe {
        pipeline_expr_var_name_into(arena, base_ref, &vname[0]);
        off = asm_ctx_local_find_offset_scoped(ctx, arena, &vname[0], vlen);
      }
      if (off < 0) {
        unsafe {
          rc = pipeline_asm_modlet_load_to_rax_elf_c(elf_ctx, &vname[0], vlen, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
      } else {
        unsafe {
          rc = glue_enc_local_slot_ptr_or_addr_elf_c(arena, elf_ctx, base_ref, off, ctx, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
      }
    } else {
      // INDEX base (`arr[0][i]`). emit_expr loads the by-value element
      // into x0:x1; the outer lane load then uses those bits as a
      // pointer. lvalue of the inner INDEX is its element address
      // (scaled lea). The inner base is not this INDEX, so this does
      // not recurse. PTR (9) and SLICE (11) stay on emit_expr: that
      // rvalue is already the pointee or the header the trailing peel
      // loads. CALL and DEREF stay rvalues.
      // PLATFORM: SHARED. Darwin ARM64 measured arr[0][0].
      tr = 0;
      trk = 0;
      if (base_ko == 47) {
        unsafe {
          tr = pipeline_expr_resolved_type_ref(arena, base_ref);
        }
        if (tr <= 0) {
          unsafe {
            tr = glue_var_expr_type_ref_with_decl_fallback_c(arena, base_ref);
          }
        }
        if (tr > 0) {
          unsafe {
            trk = pipeline_type_kind_ord_at(arena, tr);
          }
        }
      }
      if (base_ko == 47 && trk != 9 && trk != 11) {
        unsafe {
          rc = pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, base_ref, ctx, ta);
        }
      } else {
        unsafe {
          rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, base_ref, ctx, ta);
        }
      }
      if (rc != 0) {
        return 0 - 1;
      }
    }
  }
  if (peeled_ptr != 0) {
    return 0;
  }
  unsafe {
    tr = glue_var_expr_type_ref_with_decl_fallback_c(arena, base_ref);
  }
  if (tr <= 0) {
    unsafe {
      tr = pipeline_expr_resolved_type_ref(arena, base_ref);
    }
  }
  if (tr > 0) {
    unsafe {
      trk = pipeline_type_kind_ord_at(arena, tr);
    }
  } else {
    trk = 0;
  }
  if (tr > 0 && trk == 11) {
    unsafe {
      rc = backend_enc_load_64_from_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
  } else {
    if (base_ko == 44) {
      unsafe {
        rc = glue_index_deref_ptr_field_slot_rax_elf_c(arena, elf_ctx, base_ref, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
    }
  }
  return 0;
}
