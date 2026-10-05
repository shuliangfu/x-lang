// w2060: Darwin sidecar — win_emit_struct_lit_fields_into_parked_rbx with
// CALL/VAR/FIELD/INDEX wide copy (ta 0|1). Leftover body stores min(fsz,8).
// PLATFORM: MACOS|DARWIN.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_emit_module_from_ctx(ctx: *u8): *u8;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipeline_expr_struct_lit_num_fields(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_struct_lit_init_ref(arena: *u8, expr_ref: i32, fi: i32): i32;
export extern function pipeline_expr_struct_lit_field_offset_at(arena: *u8, mod: *u8, expr_ref: i32, fi: i32): i32;
export extern function pipeline_expr_struct_lit_field_type_ref_at(arena: *u8, mod: *u8, expr_ref: i32, fi: i32): i32;
export extern function glue_struct_lit_field_store_sz(arena: *u8, expr_ref: i32, fi: i32): i32;
export extern function pipeline_asm_emit_expr_elf_rec(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_push_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbx_offset_arch(elf_ctx: *u8, off: i32, load_sz: i32, ta: i32): i32;
export extern function backend_enc_append_u32_le_c(elf_ctx: *u8, w: u32): i32;
export extern function glue_type_named_layout_size_any_module_elf_c(arena: *u8, ty_ref: i32): i32;
export extern function glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx: *u8, slot_off: i32, sz: i32, ta: i32): i32;

#[no_mangle]
export function win_emit_struct_lit_fields_into_parked_rbx(arena: *u8, elf_ctx: *u8, lit_ref: i32, ctx: *u8, ta: i32, base_off: i32): i32 {
  let nf: i32 = 0;
  let fi: i32 = 0;
  let iref: i32 = 0;
  let foff: i32 = 0;
  let fsz: i32 = 0;
  let store_off: i32 = 0;
  let iko: i32 = 0;
  let fty: i32 = 0;
  let wide: i32 = 0;
  let add_x19: u32 = 0;
  let mod: *u8 = 0 as *u8;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || lit_ref <= 0) {
    return 0 - 1;
  }
  if (base_off < 0 || base_off > 4096) {
    return 0 - 1;
  }
  unsafe {
    mod = glue_emit_module_from_ctx(ctx);
  }
  if (mod == (0 as *u8)) {
    unsafe {
      mod = pipeline_asm_emit_module_ref_c();
    }
  }
  unsafe {
    nf = pipeline_expr_struct_lit_num_fields(arena, lit_ref);
  }
  if (nf < 0) {
    nf = 0;
  }
  if (nf > 64) {
    return 0 - 1;
  }
  fi = 0;
  while (fi < nf) {
    unsafe {
      iref = pipeline_expr_struct_lit_init_ref(arena, lit_ref, fi);
    }
    if (iref <= 0) {
      return 0 - 1;
    }
    foff = 0;
    if (mod != (0 as *u8)) {
      unsafe {
        foff = pipeline_expr_struct_lit_field_offset_at(arena, mod, lit_ref, fi);
      }
    }
    if (foff < 0) {
      foff = 0;
    }
    store_off = foff + base_off;
    if (store_off > 4096) {
      return 0 - 1;
    }
    unsafe {
      iko = pipeline_expr_kind_ord_at(arena, iref);
    }
    if (iko == 45) {
      if (win_emit_struct_lit_fields_into_parked_rbx(arena, elf_ctx, iref, ctx, ta, store_off) != 0) {
        return 0 - 1;
      }
      fi = fi + 1;
      continue;
    }
    unsafe {
      fsz = glue_struct_lit_field_store_sz(arena, lit_ref, fi);
    }
    if (fsz <= 0) {
      fi = fi + 1;
      continue;
    }
    unsafe {
      if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, iref, ctx, ta) != 0) {
        return 0 - 1;
      }
    }
    if ((ta == 0 || ta == 1) && (iko == 3 || iko == 44 || iko == 47 || iko == 48 || iko == 49)) {
      fty = 0;
      wide = 0;
      if (mod != (0 as *u8)) {
        unsafe {
          fty = pipeline_expr_struct_lit_field_type_ref_at(arena, mod, lit_ref, fi);
        }
      }
      if (fty > 0) {
        unsafe {
          wide = glue_type_named_layout_size_any_module_elf_c(arena, fty);
        }
      }
      if (wide > 8) {
        if (store_off < 0 || store_off > 4095) {
          return 0 - 1;
        }
        /* add x19, x19, #store_off — 0x91000273 | (imm12<<10) */
        add_x19 = (2432696947 as u32) | ((store_off as u32) * 1024);
        if (wide > 16) {
          unsafe {
            if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0) {
              return 0 - 1;
            }
            if (backend_enc_push_rbx_arch(elf_ctx, ta) != 0) {
              return 0 - 1;
            }
            if (backend_enc_append_u32_le_c(elf_ctx, 2852209651 as u32) != 0) {
              return 0 - 1;
            }
            if (store_off > 0) {
              if (backend_enc_append_u32_le_c(elf_ctx, add_x19) != 0) {
                return 0 - 1;
              }
            }
            if (glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, 0 - 3, wide, ta) != 0) {
              return 0 - 1;
            }
          }
          fi = fi + 1;
          continue;
        }
        unsafe {
          if (backend_enc_append_u32_le_c(elf_ctx, 2848827360 as u32) != 0) {
            return 0 - 1;
          }
          if (backend_enc_append_u32_le_c(elf_ctx, 4181724147 as u32) != 0) {
            return 0 - 1;
          }
          if (store_off > 0) {
            if (backend_enc_append_u32_le_c(elf_ctx, add_x19) != 0) {
              return 0 - 1;
            }
          }
          if (backend_enc_append_u32_le_c(elf_ctx, 2432697312 as u32) != 0) {
            return 0 - 1;
          }
          if (glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, 0 - 3, wide, ta) != 0) {
            return 0 - 1;
          }
          if (backend_enc_append_u32_le_c(elf_ctx, 2432713727 as u32) != 0) {
            return 0 - 1;
          }
        }
        fi = fi + 1;
        continue;
      }
    }
    unsafe {
      if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0) {
        return 0 - 1;
      }
      if (backend_enc_push_rbx_arch(elf_ctx, ta) != 0) {
        return 0 - 1;
      }
    }
    if (fsz > 8) {
      fsz = 8;
    }
    unsafe {
      if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, store_off, fsz, ta) != 0) {
        return 0 - 1;
      }
    }
    fi = fi + 1;
  }
  return 0;
}
