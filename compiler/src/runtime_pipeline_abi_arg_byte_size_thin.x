// knife256/10.2 Cap tip: ARRAY/SLICE/PTR call-arg → 8B E*; nested Result CALL → 16.
// PLATFORM: SHARED — MACOS Cap tip first-wins.
export extern function pipeline_asm_call_arg_value_byte_size_c(arena: *u8, ctx: *u8, arg_ref: i32, pty: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, arg_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, ty_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, arg_ref: i32): i32;
export extern function glue_type_named_layout_size_any_module_elf_c(arena: *u8, ty_ref: i32): i32;
export extern function asm_local_slot_bytes(arena: *u8, type_ref: i32): i32;
export extern function pipeline_asm_type_ref_byte_size_c(arena: *u8, ty_ref: i32): i32;
export extern function glue_sysv_dual_gp_byte_size_c(arena: *u8, ty_ref: i32): i32;
export extern function glue_call_return_byte_size_c(arena: *u8, arg_ref: i32): i32;

#[no_mangle]
export function glue_sysv_arg_byte_size_c(arena: *u8, ctx: *u8, pty: i32, arg_ref: i32): i32 {
  unsafe {
  let sz: i32 = 0;
  let alt: i32 = 0;
  let ko: i32 = 0;
  let tr: i32 = 0;
  if (arena != 0 as *u8) {
    sz = pipeline_asm_call_arg_value_byte_size_c(arena, ctx, arg_ref, pty);
  }
  if (arena != 0 as *u8) {
    if (arg_ref > 0) {
      tr = pipeline_expr_resolved_type_ref(arena, arg_ref);
      if (tr > 0) {
        ko = pipeline_type_kind_ord_at(arena, tr);
        if (ko == 9 || ko == 10 || ko == 11) {
          return 8;
        }
      }
    }
    if (pty > 0) {
      ko = pipeline_type_kind_ord_at(arena, pty);
      if (ko == 9 || ko == 10 || ko == 11) {
        return 8;
      }
    }
  }
  if (arg_ref > 0) {
    if (arena != 0 as *u8) {
      ko = pipeline_expr_kind_ord_at(arena, arg_ref);
      if (ko == 48 || ko == 49) {
        // Nested Result CALL arg: call_return (mod-arena) → 16.
        alt = glue_call_return_byte_size_c(arena, arg_ref);
        if (alt == 16) { return 16; }
        // knife256/10.2: return named layout even when >16 (String byref).
        if (alt > 8) {
          return alt;
        }
        if (pty > 0) {
          alt = glue_sysv_dual_gp_byte_size_c(arena, pty);
          if (alt > 8) {
            return alt;
          }
        }
        tr = pipeline_expr_resolved_type_ref(arena, arg_ref);
        if (tr > 0) {
          alt = glue_sysv_dual_gp_byte_size_c(arena, tr);
          if (alt > 8) {
            return alt;
          }
        }
        // knife256/10.2: Cap tip TYPE_NAMED name often empty at call-arg size —
  // named_layout miss leaves sz=8. asm_local_slot_bytes still sees layout
  // (String 260 / Option_i32 8). PLATFORM: SHARED Cap tip.
  if (sz <= 8) {
    if (arena != 0 as *u8) {
      if (arg_ref > 0) {
        tr = pipeline_expr_resolved_type_ref(arena, arg_ref);
        if (tr > 0) {
          ko = pipeline_type_kind_ord_at(arena, tr);
          if (ko == 8) {
            alt = asm_local_slot_bytes(arena, tr);
            // Only >16 → AAPCS64 byref (String). 9–16 stay dual-GP (Result).
            if (alt > 16) {
              if (alt > sz) { sz = alt; }
            }
          }
        }
      }
      if (sz <= 8) {
        if (pty > 0) {
          ko = pipeline_type_kind_ord_at(arena, pty);
          if (ko == 8) {
            alt = asm_local_slot_bytes(arena, pty);
            if (alt > 16) {
              if (alt > sz) { sz = alt; }
            }
          }
        }
      }
    }
  }
  if (sz <= 0) { return 8; }
        return sz;
      } else {
        if (sz <= 8) {
          if (pty > 0) {
            alt = glue_type_named_layout_size_any_module_elf_c(arena, pty);
            // knife256/10.2: allow >16 (String byref), not only 9–16 dual-GP.
            if (alt > 8) {
              if (alt > sz) { sz = alt; }
            }
            alt = glue_sysv_dual_gp_byte_size_c(arena, pty);
            if (alt > sz) { sz = alt; }
          }
          tr = pipeline_expr_resolved_type_ref(arena, arg_ref);
          if (tr > 0) {
            alt = glue_type_named_layout_size_any_module_elf_c(arena, tr);
            // knife256/10.2: allow >16 (String byref), not only 9–16 dual-GP.
            if (alt > 8) {
              if (alt > sz) { sz = alt; }
            }
            alt = glue_sysv_dual_gp_byte_size_c(arena, tr);
            if (alt > sz) { sz = alt; }
          }
        }
      }
    }
  } else if (sz <= 0) {
    if (pty > 0) {
      if (arena != 0 as *u8) {
        sz = pipeline_asm_type_ref_byte_size_c(arena, pty);
      }
    }
  }
  if (sz <= 0) { return 8; }
  return sz;
  }
}
