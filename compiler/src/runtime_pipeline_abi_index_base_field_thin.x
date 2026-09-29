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
 * INDEX lvalue base effective address into rax/x0 (ELF / Mach-O / COFF).
 * @return i32 - 0 ok; -1 error. PLATFORM: SHARED.
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
      unsafe {
        rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, fb_ref, ctx, ta);
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
      unsafe {
        rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, base_ref, ctx, ta);
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
