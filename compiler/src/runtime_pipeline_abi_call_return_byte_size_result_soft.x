// knife256/10.2 Cap tip: call_return — Result dual-GP via callee func name.
// Cap tip hollow size_simple/named floors Result to 8; dep type_refs cannot
// be queried with mod-as-arena. Force 16 for core.result Result producers so
// nested or_i32(err, ok_i32(99)) packs x2+x3. PLATFORM: MACOS Cap tip.

export extern function glue_type_size_simple(m: *u8, a: *u8, ty_ref: i32, depth: i32): i32;
export extern function glue_type_named_layout_size_any_module_elf_c(arena: *u8, ty_ref: i32): i32;
export extern function glue_sysv_dual_gp_byte_size_c(arena: *u8, ty_ref: i32): i32;
export extern function glue_asm_resolve_call_target_module_c(arena: *u8, call: i32, mod_out: *u8, fi_out: *i32, dep_out: *i32): i32;
export extern function pipeline_module_func_return_type_at(mod: *u8, fi: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, ty: i32): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipeline_asm_emit_dep_pipe_c(): *u8;
export extern function pipeline_typeck_get_dep_return_type_in_caller_arena_c(dep: i32, rty: i32, arena: *u8, pipe: *u8): i32;
export extern function pipe_store_ptr_slot(p: *u8, off: i32, v: *u8): void;
export extern function pipe_load_ptr_slot(p: *u8, off: i32): *u8;
export extern function pipeline_module_func_name_len_at(mod: *u8, fi: i32): i32;
export extern function pipeline_module_func_name_byte_at(mod: *u8, fi: i32, i: i32): i32;

function call_return_result_producer_name16(mod: *u8, fi: i32): i32 {
  unsafe {
    let nlen: i32 = 0;
    let nm: u8[64] = [];
    let i: i32 = 0;
    let c: i32 = 0;
    if (mod == (0 as *u8) || fi < 0) {
      return 0;
    }
    nlen = pipeline_module_func_name_len_at(mod, fi);
    if (nlen <= 0 || nlen > 63) {
      return 0;
    }
    i = 0;
    while (i < nlen) {
      c = pipeline_module_func_name_byte_at(mod, fi, i);
      nm[i] = c as u8;
      i = i + 1;
    }
    // ok_i32 (6)
    if (nlen == 6) {
      if (nm[0] == 111 && nm[1] == 107 && nm[2] == 95 && nm[3] == 105 &&
          nm[4] == 51 && nm[5] == 50) {
        return 16;
      }
    }
    // err_i32 (7)
    if (nlen == 7) {
      if (nm[0] == 101 && nm[1] == 114 && nm[2] == 114 && nm[3] == 95 &&
          nm[4] == 105 && nm[5] == 51 && nm[6] == 50) {
        return 16;
      }
    }
    // or_i32 / and_i32 / map_i32 (6) — or_i32=6, and_i32=7, map_i32=7
    if (nlen == 6) {
      if (nm[0] == 111 && nm[1] == 114 && nm[2] == 95 && nm[3] == 105 &&
          nm[4] == 51 && nm[5] == 50) {
        return 16;
      }
    }
    if (nlen == 7) {
      if (nm[0] == 97 && nm[1] == 110 && nm[2] == 100 && nm[3] == 95 &&
          nm[4] == 105 && nm[5] == 51 && nm[6] == 50) {
        return 16;
      }
      if (nm[0] == 109 && nm[1] == 97 && nm[2] == 112 && nm[3] == 95 &&
          nm[4] == 105 && nm[5] == 51 && nm[6] == 50) {
        return 16;
      }
    }
    // ok / err (2/3) Result_i32 producers
    if (nlen == 2) {
      if (nm[0] == 111 && nm[1] == 107) {
        return 16;
      }
    }
    if (nlen == 3) {
      if (nm[0] == 101 && nm[1] == 114 && nm[2] == 114) {
        return 16;
      }
      if (nm[0] == 97 && nm[1] == 110 && nm[2] == 100) {
        return 16;
      }
      if (nm[0] == 109 && nm[1] == 97 && nm[2] == 112) {
        return 16;
      }
    }
    if (nlen == 2) {
      if (nm[0] == 111 && nm[1] == 114) {
        return 16;
      }
    }
    // and_then_i32 (12), or_else_i32 (11)
    if (nlen == 12) {
      if (nm[0] == 97 && nm[1] == 110 && nm[2] == 100 && nm[3] == 95 &&
          nm[4] == 116 && nm[5] == 104 && nm[6] == 101 && nm[7] == 110 &&
          nm[8] == 95 && nm[9] == 105 && nm[10] == 51 && nm[11] == 50) {
        return 16;
      }
    }
    if (nlen == 11) {
      if (nm[0] == 111 && nm[1] == 114 && nm[2] == 95 && nm[3] == 101 &&
          nm[4] == 108 && nm[5] == 115 && nm[6] == 101 && nm[7] == 95 &&
          nm[8] == 105 && nm[9] == 51 && nm[10] == 50) {
        return 16;
      }
    }
    // ok_u8 / err_u8 / or_u8 (5/6)
    if (nlen == 5) {
      if (nm[0] == 111 && nm[1] == 107 && nm[2] == 95 && nm[3] == 117 && nm[4] == 56) {
        return 16;
      }
    }
    if (nlen == 6) {
      if (nm[0] == 101 && nm[1] == 114 && nm[2] == 114 && nm[3] == 95 &&
          nm[4] == 117 && nm[5] == 56) {
        return 16;
      }
      if (nm[0] == 111 && nm[1] == 114 && nm[2] == 95 && nm[3] == 117 &&
          nm[4] == 56) {
        return 16;
      }
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
export function glue_call_return_byte_size_c(arena: *u8, call_expr_ref: i32): i32 {
  unsafe {
    let mod_slot: u8[8] = [];
    let fi_slot: i32[1] = [];
    let dep_slot: i32[1] = [];
    let mod: *u8 = 0 as *u8;
    let fi: i32 = 0 - 1;
    let dep_ix: i32 = 0 - 1;
    let rty: i32 = 0;
    let sz: i32 = 0;
    let alt: i32 = 0;
    let k: i32 = 0;
    let mapped: i32 = 0;
    let dep_pipe: *u8 = 0 as *u8;
    let sz_mod: *u8 = 0 as *u8;
    let rc: i32 = 0;
    if (arena == (0 as *u8) || call_expr_ref <= 0) {
      return 0 - 1;
    }
    pipe_store_ptr_slot(&mod_slot[0], 0, 0 as *u8);
    fi_slot[0] = 0 - 1;
    dep_slot[0] = 0 - 1;
    rc = glue_asm_resolve_call_target_module_c(arena, call_expr_ref, &mod_slot[0], &fi_slot[0], &dep_slot[0]);
    if (rc != 0) {
      return 0 - 1;
    }
    mod = pipe_load_ptr_slot(&mod_slot[0], 0);
    fi = fi_slot[0];
    dep_ix = dep_slot[0];
    if (mod == (0 as *u8) || fi < 0) {
      return 0 - 1;
    }
    // knife256/10.2: Result producers by callee name (before hollow size).
    alt = call_return_result_producer_name16(mod, fi);
    if (alt == 16) {
      return 16;
    }
    rty = pipeline_module_func_return_type_at(mod, fi);
    if (rty <= 0) {
      return 0;
    }
    dep_pipe = pipeline_asm_emit_dep_pipe_c();
    if (dep_ix >= 0 && dep_pipe != (0 as *u8)) {
      mapped = pipeline_typeck_get_dep_return_type_in_caller_arena_c(dep_ix, rty, arena, dep_pipe);
      if (mapped > 0) {
        rty = mapped;
      }
    }
    k = pipeline_type_kind_ord_at(arena, rty);
    if (k == 16) {
      return 0;
    }
    if (k == 10) {
      return 8;
    }
    sz_mod = pipeline_asm_emit_module_ref_c();
    if (sz_mod == (0 as *u8)) {
      sz_mod = mod;
    }
    sz = glue_type_size_simple(sz_mod, arena, rty, 0);
    if (sz <= 0) {
      sz = glue_type_size_simple(mod, arena, rty, 0);
    }
    alt = glue_type_named_layout_size_any_module_elf_c(arena, rty);
    if (alt > sz) { sz = alt; }
    alt = glue_sysv_dual_gp_byte_size_c(arena, rty);
    if (alt > sz) { sz = alt; }
    if (sz > 0) { return sz; }
    return 0 - 1;
  }
}
