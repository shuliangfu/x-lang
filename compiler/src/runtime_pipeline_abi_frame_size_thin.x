// Thin pure override: prologue frame size (pipeline_asm_compute_frame_size_c).
// w1500 (终局待办 10.23): pure .x replacement for the former host-cc sidecar
// seeds/runtime_pipeline_abi_compute_frame_size_overlay.c. Same rules:
//   w1032/w1033/w1040/w1042 call-spill scratch (leaf 0, small measured,
//     medium +64 pad and +64 trailer, heavy 2048 floor);
//   w1043 48-byte cap for param-home-only forwarders (num_params <= 4);
//   w1047 x86_64 forwarders with 5+ formals reserve shadow + stack args;
//   w1484 arm64 doubles the call-spill budget (16-byte temp slots);
//   w1490 locals of blocks reached only through EXPR_IF / EXPR_BLOCK /
//     EXPR_MATCH (final expr, expr stmts, let initializers) are registered;
//   w1497 Windows x86_64 adds 32 + 8*max(0, gp-4), 16-aligned, when the body
//     has a call (gp from glue_asm_last_call_max_gp_units_c). The host check
//     is link_abi_host_is_windows() at run time instead of #ifdef _WIN32.
// src/runtime_pipeline_abi.x is not edited (pabi is not rebuilt).
// g05_relink_env.sh compiles this with the current product (pure asm, no host
// cc) and links it ahead of pabi; Windows weakens the pabi_weak T.
// PLATFORM: SHARED freestanding frame-size · MACOS|ARM64 · LINUX x86_64 · WINDOWS x86_64.

export extern "C" function memset(dst: *u8, c: i32, n: usize): *u8;
export extern function pipe_store_ptr_slot(base: *u8, i: i32, val: *u8): void;
export extern function pipeline_asm_emit_ctx_module_get(): *u8;
export extern function pipeline_asm_emit_ctx_module_set(mod: *u8): void;
export extern function asm_ctx_local_reset(ctx: *u8): void;
export extern function pipeline_asm_host_is_arm64_c(): i32;
export extern function link_abi_host_is_windows(): i32;
export extern function glue_func_param_home_width_c(arena: *u8, mod: *u8, func_index: i32, pi: i32): i32;
export extern function glue_func_return_byte_size_c(mod: *u8, arena: *u8, func_index: i32): i32;
export extern function pipeline_asm_hoist_target_func_index(mod: *u8): i32;
export extern function pipeline_asm_sum_module_top_level_lets_stack(arena: *u8, mod: *u8, next_off: i32): i32;
export extern function asm_ctx_fill_locals_block_tree(ctx: *u8, arena: *u8, block_ref: i32, next_off: *i32, num_loc: *i32): void;
export extern function asm_ctx_ensure_block_locals(ctx: *u8, arena: *u8, block_ref: i32, next_off: *i32, num_loc: *i32): void;
export extern function asm_sum_block_array_temp_bytes(arena: *u8, block_ref: i32): i32;
export extern function glue_asm_sum_block_call_spill_bytes(arena: *u8, block_ref: i32): i32;
export extern function glue_asm_last_call_max_gp_units_c(): i32;
export extern function asm_sum_block_wa_temp_bytes(arena: *u8, block_ref: i32): i32;
export extern function glue_sum_block_slice_reent_dc_bytes_c(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_loops(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_for_loops(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_if_stmts(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_regions(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_lets(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_expr_stmts(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_final_expr_ref(arena: *u8, block_ref: i32): i32;
export extern function pipeline_block_while_body_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function pipeline_block_for_body_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function ast_pipeline_block_if_then_body_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function ast_pipeline_block_if_else_body_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function pipeline_block_region_body_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function pipeline_block_let_init_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function ast_pipeline_block_expr_stmt_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_block_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_if_then_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_if_else_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_match_num_arms_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_match_arm_result_ref(arena: *u8, expr_ref: i32, i: i32): i32;

// w1490 block stack (512 entries): block ref and hidden flag (1 = reached
// only through an expression edge, so its locals must be ensured here).
let w1500_fs_blk: i32[512] = [];
let w1500_fs_hid: i32[512] = [];
// Expression stack for one w1500_fs_push_expr call (256 entries).
let w1500_fs_es: i32[256] = [];

/** Push one block; full stack or b <= 0 is a no-op. PLATFORM: SHARED. */
function w1500_fs_push(sp: i32, b: i32, hid: i32): i32 {
  if (b <= 0 || sp < 0 || sp >= 512) {
    return sp;
  }
  w1500_fs_blk[sp] = b;
  w1500_fs_hid[sp] = hid;
  return sp + 1;
}

/** Push blocks reachable from expression e through IF/BLOCK/MATCH. PLATFORM: SHARED. */
function w1500_fs_push_expr(arena: *u8, sp0: i32, e: i32): i32 {
  let sp: i32 = sp0;
  let esp: i32 = 0;
  let steps: i32 = 0;
  let cur: i32 = 0;
  let ko: i32 = 0;
  let t: i32 = 0;
  let el: i32 = 0;
  let na: i32 = 0;
  let ai: i32 = 0;
  let r: i32 = 0;
  if (e <= 0) {
    return sp;
  }
  w1500_fs_es[0] = e;
  esp = 1;
  while (esp > 0 && steps < 4096) {
    esp = esp - 1;
    cur = w1500_fs_es[esp];
    steps = steps + 1;
    if (cur > 0) {
      unsafe {
        ko = pipeline_expr_kind_ord_at(arena, cur);
      }
      if (ko == 26) {
        unsafe {
          t = pipeline_expr_block_ref_at(arena, cur);
        }
        sp = w1500_fs_push(sp, t, 1);
      } else if (ko == 25) {
        unsafe {
          t = pipeline_expr_if_then_ref_at(arena, cur);
          el = pipeline_expr_if_else_ref_at(arena, cur);
        }
        if (t > 0 && esp < 256) {
          w1500_fs_es[esp] = t;
          esp = esp + 1;
        }
        if (el > 0 && esp < 256) {
          w1500_fs_es[esp] = el;
          esp = esp + 1;
        }
      } else if (ko == 43) {
        unsafe {
          na = pipeline_expr_match_num_arms_at(arena, cur);
        }
        ai = 0;
        while (ai < na && ai < 1024) {
          unsafe {
            r = pipeline_expr_match_arm_result_ref(arena, cur, ai);
          }
          if (r > 0 && esp < 256) {
            w1500_fs_es[esp] = r;
            esp = esp + 1;
          }
          ai = ai + 1;
        }
      }
    }
  }
  return sp;
}

/** w1490: ensure locals of expression-nested blocks. PLATFORM: SHARED. */
function w1500_fs_fill_nested(ctx: *u8, arena: *u8, root: i32, next_off: *i32, num_loc: *i32): void {
  let sp: i32 = 0;
  let visits: i32 = 0;
  let cur: i32 = 0;
  let hid: i32 = 0;
  let n: i32 = 0;
  let i: i32 = 0;
  let b: i32 = 0;
  sp = w1500_fs_push(0, root, 0);
  while (sp > 0 && visits < 8192) {
    sp = sp - 1;
    cur = w1500_fs_blk[sp];
    hid = w1500_fs_hid[sp];
    visits = visits + 1;
    if (cur > 0) {
      if (hid != 0) {
        unsafe {
          asm_ctx_ensure_block_locals(ctx, arena, cur, next_off, num_loc);
        }
      }
      unsafe {
        n = ast_ast_block_num_loops(arena, cur);
      }
      i = 0;
      while (i < n) {
        unsafe {
          b = pipeline_block_while_body_ref(arena, cur, i);
        }
        sp = w1500_fs_push(sp, b, hid);
        i = i + 1;
      }
      unsafe {
        n = ast_ast_block_num_for_loops(arena, cur);
      }
      i = 0;
      while (i < n) {
        unsafe {
          b = pipeline_block_for_body_ref(arena, cur, i);
        }
        sp = w1500_fs_push(sp, b, hid);
        i = i + 1;
      }
      unsafe {
        n = ast_ast_block_num_if_stmts(arena, cur);
      }
      i = 0;
      while (i < n) {
        unsafe {
          b = ast_pipeline_block_if_then_body_ref(arena, cur, i);
        }
        sp = w1500_fs_push(sp, b, hid);
        unsafe {
          b = ast_pipeline_block_if_else_body_ref(arena, cur, i);
        }
        sp = w1500_fs_push(sp, b, hid);
        i = i + 1;
      }
      unsafe {
        n = ast_ast_block_num_regions(arena, cur);
      }
      i = 0;
      while (i < n) {
        unsafe {
          b = pipeline_block_region_body_ref(arena, cur, i);
        }
        sp = w1500_fs_push(sp, b, hid);
        i = i + 1;
      }
      unsafe {
        n = ast_ast_block_num_lets(arena, cur);
      }
      i = 0;
      while (i < n) {
        unsafe {
          b = pipeline_block_let_init_ref(arena, cur, i);
        }
        sp = w1500_fs_push_expr(arena, sp, b);
        i = i + 1;
      }
      unsafe {
        n = ast_ast_block_num_expr_stmts(arena, cur);
      }
      i = 0;
      while (i < n) {
        unsafe {
          b = ast_pipeline_block_expr_stmt_ref(arena, cur, i);
        }
        sp = w1500_fs_push_expr(arena, sp, b);
        i = i + 1;
      }
      unsafe {
        b = ast_ast_block_final_expr_ref(arena, cur);
      }
      sp = w1500_fs_push_expr(arena, sp, b);
    }
  }
}

/** Frame size before the Windows outgoing area (w1497 core). PLATFORM: SHARED. */
function w1500_fs_core(num_params: i32, arena: *u8, block_ref: i32, mod: *u8, func_index: i32): i32 {
  let ctx_buf: u8[256] = [];
  let next_off: i32 = 16;
  let num_loc: i32 = 0;
  let size: i32 = 0;
  let arr_temp: i32 = 0;
  let call_spill: i32 = 0;
  let scratch: i32 = 0;
  let prev_mod: *u8 = 0 as *u8;
  let wa_temp: i32 = 0;
  let reent_dc: i32 = 0;
  let is_arm: i32 = 0;
  let pi: i32 = 0;
  let w: i32 = 0;
  let ret_sz: i32 = 0;
  let hoist: i32 = 0;
  let rem: i32 = 0;
  if (arena == (0 as *u8) || block_ref <= 0) {
    return 64;
  }
  unsafe {
    memset(&ctx_buf[0], 0, 128 as usize);
  }
  unsafe {
    pipe_store_ptr_slot(&ctx_buf[0], 2, mod);
    prev_mod = pipeline_asm_emit_ctx_module_get();
    pipeline_asm_emit_ctx_module_set(mod);
    asm_ctx_local_reset(&ctx_buf[0]);
    is_arm = pipeline_asm_host_is_arm64_c();
  }
  if (num_params > 0 && mod != (0 as *u8) && func_index >= 0) {
    pi = 0;
    while (pi < num_params) {
      unsafe {
        w = glue_func_param_home_width_c(arena, mod, func_index, pi);
      }
      if (is_arm != 0) {
        if (w > 8) {
          next_off = next_off + w;
        } else {
          next_off = next_off + 8;
        }
      } else {
        if (w > 8) {
          next_off = next_off + w + 8;
        } else {
          next_off = next_off + 8;
        }
      }
      pi = pi + 1;
    }
  } else {
    if (num_params > 0) {
      next_off = 16 + num_params * 8;
    }
  }
  if (mod != (0 as *u8) && func_index >= 0) {
    unsafe {
      ret_sz = glue_func_return_byte_size_c(mod, arena, func_index);
    }
    if (ret_sz > 16) {
      next_off = next_off + 8;
    }
    unsafe {
      hoist = pipeline_asm_hoist_target_func_index(mod);
    }
    if (func_index != hoist) {
      unsafe {
        next_off = pipeline_asm_sum_module_top_level_lets_stack(arena, mod, next_off);
      }
    }
  }
  num_loc = 0;
  unsafe {
    asm_ctx_fill_locals_block_tree(&ctx_buf[0], arena, block_ref, &next_off, &num_loc);
  }
  w1500_fs_fill_nested(&ctx_buf[0], arena, block_ref, &next_off, &num_loc);
  unsafe {
    arr_temp = asm_sum_block_array_temp_bytes(arena, block_ref);
    call_spill = glue_asm_sum_block_call_spill_bytes(arena, block_ref);
  }
  // w1484: arm64 gives every call temp its own 16-byte slot. MACOS|ARM64.
  if (is_arm != 0) {
    call_spill = call_spill * 2;
  }
  unsafe {
    pipeline_asm_emit_ctx_module_set(prev_mod);
    wa_temp = asm_sum_block_wa_temp_bytes(arena, block_ref);
    reent_dc = glue_sum_block_slice_reent_dc_bytes_c(arena, block_ref);
  }
  size = next_off + arr_temp + wa_temp + reent_dc;
  if (size > 0) {
    rem = size % 16;
    if (rem != 0) {
      size = size + (16 - rem);
    }
  }
  scratch = call_spill;
  if (call_spill > 0) {
    if (call_spill >= 1024) {
      if (scratch < 2048) {
        scratch = 2048;
      }
    } else if (call_spill >= 256) {
      scratch = call_spill + 64;
    }
  }
  size = size + scratch;
  if (call_spill >= 256) {
    return size + 64;
  }
  // w1047: x86_64 forwarders with 5+ formals keep outgoing stack args off homes.
  if (is_arm == 0 && call_spill == 0 && num_params > 4) {
    let n_stack: i32 = num_params - 4;
    let out_need: i32 = 32 + n_stack * 8;
    let min_sz: i32 = next_off + out_need;
    let rem2: i32 = min_sz % 16;
    if (rem2 != 0) {
      min_sz = min_sz + (16 - rem2);
    }
    if (size < min_sz) {
      size = min_sz;
    }
  }
  // w1043: param-home-only forwarders cap at 48 (num_params <= 4).
  if (call_spill == 0 && arr_temp == 0 && wa_temp == 0 && reent_dc == 0) {
    if (num_params <= 4 && size > 48 && size <= 64) {
      return 48;
    }
  }
  return size;
}

/**
 * Frame size for a function prologue.
 * Windows x86_64 (w1497): reserve 32 + 8*max(0, gp-4), 16-aligned, below the
 * frame when the body has a call. Linux/macOS return the core size.
 * PLATFORM: SHARED · WINDOWS x86_64 outgoing area.
 */
#[no_mangle]
export function pipeline_asm_compute_frame_size_c(num_params: i32, arena: *u8, block_ref: i32, mod: *u8, func_index: i32): i32 {
  let size: i32 = 0;
  let win: i32 = 0;
  let arm: i32 = 0;
  let gp: i32 = 0;
  let out: i32 = 0;
  let rem: i32 = 0;
  size = w1500_fs_core(num_params, arena, block_ref, mod, func_index);
  if (arena == (0 as *u8) || block_ref <= 0) {
    return size;
  }
  unsafe {
    win = link_abi_host_is_windows();
    arm = pipeline_asm_host_is_arm64_c();
  }
  if (win != 0 && arm == 0) {
    unsafe {
      gp = glue_asm_last_call_max_gp_units_c();
    }
    if (gp >= 0) {
      out = 32;
      if (gp > 4) {
        out = out + (gp - 4) * 8;
      }
      rem = out % 16;
      if (rem != 0) {
        out = out + (16 - rem);
      }
      size = size + out;
    }
  }
  return size;
}
