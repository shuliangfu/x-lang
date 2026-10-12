// knife 254 / 9.2 struct_lit_*: Darwin tip authority for
//   win_emit_struct_lit_fields_into_parked_rbx
//   pipeline_asm_emit_struct_lit_fields_elf_c
//   pipeline_asm_emit_struct_lit_elf_c
// Fields/elf bodies match seeds/runtime_pipeline_abi.windows_link_stubs.c
// (reserve home, park rbx, call win_emit, materialize ≤16B into GP).
// Do not take these T from archive_leaf (stale CG002). Rebuild every
// Darwin relink with _g05_pure_overlay (no PREFER). Pipe cells hold
// every extern result. No integer / or %.
// PLATFORM: MACOS|DARWIN tip cold.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_emit_module_from_ctx(ctx: *u8): *u8;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipeline_expr_struct_lit_num_fields(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_struct_lit_init_ref(arena: *u8, expr_ref: i32, fi: i32): i32;
export extern function pipeline_expr_struct_lit_field_offset_at(arena: *u8, mod: *u8, expr_ref: i32, fi: i32): i32;
export extern function pipeline_expr_struct_lit_field_type_ref_at(arena: *u8, mod: *u8, expr_ref: i32, fi: i32): i32;
export extern function pipeline_expr_struct_lit_value_bytes(a: *u8, m: *u8, expr_ref: i32): i32;
export extern function glue_struct_lit_field_store_sz(arena: *u8, expr_ref: i32, fi: i32): i32;
export extern function pipeline_asm_emit_expr_elf_rec(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_push_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbx_offset_arch(elf_ctx: *u8, off: i32, load_sz: i32, ta: i32): i32;
export extern function backend_enc_append_u32_le_c(elf_ctx: *u8, w: u32): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, off: i32, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, off: i32, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rbx_arch(elf_ctx: *u8, off: i32, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rdx_arch(elf_ctx: *u8, off: i32, ta: i32): i32;
export extern function glue_type_named_layout_size_any_module_elf_c(arena: *u8, ty_ref: i32): i32;
export extern function glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx: *u8, slot_off: i32, sz: i32, ta: i32): i32;
export extern function pipe_asm_ctx_off_next_offset(): i32;
export extern function pipe_load_i32_le(p: *u8, off: i32): i32;
export extern function pipe_store_i32_le(p: *u8, off: i32, v: i32): void;

function w254_sl_cell_i32(base: *u8): i32 {
  unsafe {
    return pipe_load_i32_le(base, 0);
  }
}

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
  let cell: u8[8];
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || lit_ref <= 0) {
    return 0 - 1;
  }
  if (base_off < 0 || base_off > 4096) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, 0);
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
      pipe_store_i32_le(&cell[0], 0, pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, iref, ctx, ta));
      if (w254_sl_cell_i32(&cell[0]) != 0) {
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
        add_x19 = (2432696947 as u32) | ((store_off as u32) * 1024);
        if (wide > 16) {
          unsafe {
            pipe_store_i32_le(&cell[0], 0, backend_enc_pop_rbx_arch(elf_ctx, ta));
            if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
            pipe_store_i32_le(&cell[0], 0, backend_enc_push_rbx_arch(elf_ctx, ta));
            if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
            pipe_store_i32_le(&cell[0], 0, backend_enc_append_u32_le_c(elf_ctx, 2852193267 as u32));
            if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
            if (store_off > 0) {
              pipe_store_i32_le(&cell[0], 0, backend_enc_append_u32_le_c(elf_ctx, add_x19));
              if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
            }
            pipe_store_i32_le(&cell[0], 0, glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, 0 - 3, wide, ta));
            if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
          }
          fi = fi + 1;
          continue;
        }
        unsafe {
          pipe_store_i32_le(&cell[0], 0, backend_enc_append_u32_le_c(elf_ctx, 2847868896 as u32));
          if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
          pipe_store_i32_le(&cell[0], 0, backend_enc_append_u32_le_c(elf_ctx, 4181724147 as u32));
          if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
          if (store_off > 0) {
            pipe_store_i32_le(&cell[0], 0, backend_enc_append_u32_le_c(elf_ctx, add_x19));
            if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
          }
          pipe_store_i32_le(&cell[0], 0, backend_enc_append_u32_le_c(elf_ctx, 2432697312 as u32));
          if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
          pipe_store_i32_le(&cell[0], 0, glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, 0 - 3, wide, ta));
          if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
          pipe_store_i32_le(&cell[0], 0, backend_enc_append_u32_le_c(elf_ctx, 2432713727 as u32));
          if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
        }
        fi = fi + 1;
        continue;
      }
    }
    unsafe {
      pipe_store_i32_le(&cell[0], 0, backend_enc_pop_rbx_arch(elf_ctx, ta));
      if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
      pipe_store_i32_le(&cell[0], 0, backend_enc_push_rbx_arch(elf_ctx, ta));
      if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
    }
    if (fsz > 8) {
      fsz = 8;
    }
    unsafe {
      pipe_store_i32_le(&cell[0], 0, backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, store_off, fsz, ta));
      if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
    }
    fi = fi + 1;
  }
  return 0;
}

/**
 * STRUCT_LIT field store into a stack home or dest-in-rbx (-3).
 * Twin of windows_link_stubs leftover; tip first-wins over archive_leaf.
 */
#[no_mangle]
export function pipeline_asm_emit_struct_lit_fields_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32
): i32 {
  let dest_in_rbx: i32 = 0;
  let home: i32 = 0;
  let nbytes: i32 = 0;
  let reserve: i32 = 0;
  let mod: *u8 = 0 as *u8;
  let cell: u8[8];
  let nf2: i32 = 0;
  let fi2: i32 = 0;
  let foff2: i32 = 0;
  let fsz2: i32 = 0;
  let end2: i32 = 0;
  let ko: i32 = 0;
  /* Module-level array/struct init may pass a null ctx; fall back via
   * pipeline_asm_emit_module_ref_c like win_emit. Do not require ctx. */
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || expr_ref <= 0) {
    return 0 - 1;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  if (ko != 45) {
    return 0 - 1;
  }
  if (stack_slot_off == 0 - 3) {
    dest_in_rbx = 1;
  } else {
    dest_in_rbx = 0;
  }
  home = stack_slot_off;
  unsafe {
    mod = glue_emit_module_from_ctx(ctx);
  }
  if (mod == (0 as *u8)) {
    unsafe {
      mod = pipeline_asm_emit_module_ref_c();
    }
  }
  nbytes = 0;
  if (mod != (0 as *u8)) {
    unsafe {
      nbytes = pipeline_expr_struct_lit_value_bytes(arena, mod, expr_ref);
    }
  }
  if (nbytes <= 0) {
    nbytes = 8;
  }
  if (nbytes > 4096) {
    return 0 - 1;
  }
  if (dest_in_rbx == 0) {
    if (home < 0) {
      reserve = (nbytes + 7) & (0 - 8);
      if (reserve < 8) {
        reserve = 8;
      }
      unsafe {
        pipe_store_i32_le(&cell[0], 0, pipe_asm_ctx_off_next_offset());
        home = pipe_load_i32_le(ctx, w254_sl_cell_i32(&cell[0]));
      }
      if ((home & 7) != 0) {
        home = (home + 7) & (0 - 8);
      }
      if (ta == 1) {
        unsafe {
          pipe_store_i32_le(&cell[0], 0, pipe_asm_ctx_off_next_offset());
          pipe_store_i32_le(ctx, w254_sl_cell_i32(&cell[0]), home + reserve);
        }
      } else {
        home = home + reserve;
        unsafe {
          pipe_store_i32_le(&cell[0], 0, pipe_asm_ctx_off_next_offset());
          pipe_store_i32_le(ctx, w254_sl_cell_i32(&cell[0]), home);
        }
      }
    }
    if (home < 0) {
      return 0 - 1;
    }
    unsafe {
      pipe_store_i32_le(&cell[0], 0, backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta));
      if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
      pipe_store_i32_le(&cell[0], 0, backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta));
      if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
    }
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, backend_enc_push_rbx_arch(elf_ctx, ta));
    if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
  }
  if (win_emit_struct_lit_fields_into_parked_rbx(arena, elf_ctx, expr_ref, ctx, ta, 0) != 0) {
    unsafe {
      pipe_store_i32_le(&cell[0], 0, backend_enc_pop_rbx_arch(elf_ctx, ta));
    }
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, backend_enc_pop_rbx_arch(elf_ctx, ta));
    if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
  }
  if (dest_in_rbx == 0) {
    unsafe {
      nf2 = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
    }
    if (nf2 < 0) {
      nf2 = 0;
    }
    fi2 = 0;
    while (fi2 < nf2) {
      if (fi2 >= 64) {
        break;
      }
      foff2 = 0;
      if (mod != (0 as *u8)) {
        unsafe {
          foff2 = pipeline_expr_struct_lit_field_offset_at(arena, mod, expr_ref, fi2);
        }
      }
      if (foff2 < 0) {
        foff2 = 0;
      }
      unsafe {
        fsz2 = glue_struct_lit_field_store_sz(arena, expr_ref, fi2);
      }
      if (fsz2 <= 0) {
        fi2 = fi2 + 1;
        continue;
      }
      if (fsz2 > 8) {
        fsz2 = 8;
      }
      end2 = foff2 + fsz2;
      if (end2 > nbytes) {
        nbytes = end2;
      }
      fi2 = fi2 + 1;
    }
    if (nbytes <= 8) {
      unsafe {
        pipe_store_i32_le(&cell[0], 0, backend_enc_load_rbp_to_rax_arch(elf_ctx, home, ta));
        if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
      }
    } else {
      if (nbytes <= 16) {
        unsafe {
          pipe_store_i32_le(&cell[0], 0, backend_enc_load_rbp_to_rax_arch(elf_ctx, home, ta));
          if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
        }
        if (ta == 1) {
          unsafe {
            pipe_store_i32_le(&cell[0], 0, backend_enc_load_rbp_to_rbx_arch(elf_ctx, home + 8, ta));
            if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
          }
        } else {
          unsafe {
            pipe_store_i32_le(&cell[0], 0, backend_enc_load_rbp_to_rdx_arch(elf_ctx, home - 8, ta));
            if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
          }
        }
      } else {
        unsafe {
          pipe_store_i32_le(&cell[0], 0, backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta));
          if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
        }
      }
    }
  }
  return 0;
}

/**
 * EXPR_STRUCT_LIT public entry: temp slot stack_slot_off=-1.
 */
#[no_mangle]
export function pipeline_asm_emit_struct_lit_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32
): i32 {
  return pipeline_asm_emit_struct_lit_fields_elf_c(arena, elf_ctx, expr_ref, ctx, ta, 0 - 1);
}

/**
 * STRUCT_LIT let-init: forward to fields with the given stack home.
 * Twin of windows_link_stubs; tip first-wins over archive_leaf.
 */
#[no_mangle]
export function pipeline_asm_emit_struct_let_init_elf_c(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32
): i32 {
  let ko: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || init_ref <= 0) {
    return 0 - 1;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, init_ref);
  }
  if (ko != 45) {
    return 0 - 1;
  }
  return pipeline_asm_emit_struct_lit_fields_elf_c(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
}
