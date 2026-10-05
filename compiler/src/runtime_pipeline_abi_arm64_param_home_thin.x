/**
 * runtime_pipeline_abi_arm64_param_home_thin.x — AAPCS64 param home (w2060).
 *
 * Leftover pabi_weak pipeline_asm_emit_param_home_elf_c treats aggregates
 * >16B as SysV-style MEMORY (copy words from the incoming stack). AAPCS64
 * passes those by reference in one GP (or one stack pointer slot). Tip
 * callers that lea a pointer into xn then SEGV in memcpy (parser
 * lex_from_next_into / LexerResult 72B). This thin owns the Darwin ARM64
 * body and homes >16B via GP pointer + copy into the frame slot.
 * PLATFORM: MACOS|DARWIN ARM64 (ta==1). ta!=1 returns 0 without emitting.
 */
export extern function backend_enc_add_imm_to_rax_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function backend_enc_load_64_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_x29_pos_to_rax_arch(elf_ctx: *u8, off_pos: i32, ta: i32): i32;
export extern function backend_enc_mov_xmm_arg_reg_to_rax_arch(elf_ctx: *u8, k: i32, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_store_x_reg_to_rbp_arch(elf_ctx: *u8, reg: i32, offset: i32, ta: i32): i32;
export extern function glue_arm64_stack_arg_advance_pos(pos: i32, nbytes: i32, apple: i32): i32;
export extern function glue_arm64_stack_arg_align_pos(pos: i32, nbytes: i32, apple: i32): i32;
export extern function glue_enc_arm64_mov_xn_to_x0_elf_c(elf_ctx: *u8, n: i32): i32;
export extern function arch_arm64_enc_enc_mov_rax_to_x9(elf_ctx: *u8): i32;
export extern function glue_enc_canonicalize_param_in_rax_elf_c(elf_ctx: *u8, arena: *u8, mod: *u8, func_index: i32, i: i32, ta: i32): i32;
export extern function glue_func_param_agg_byte_size_c(arena: *u8, mod: *u8, func_index: i32, i: i32): i32;
export extern function glue_func_param_home_width_c(arena: *u8, mod: *u8, func_index: i32, i: i32): i32;
export extern function pipe_asm_ctx_off_frame_size(): i32;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipeline_asm_emit_ctx_arena_get(): *u8;
export extern function pipeline_asm_emit_ctx_sret_active_get(): i32;
export extern function pipeline_asm_emit_ctx_sret_home_off_get(): i32;
export extern function pipeline_asm_emit_set_func_index(func_index: i32): void;
export extern function pipeline_asm_module_func_num_params_at(mod: *u8, func_index: i32): i32;
export extern function pipeline_module_func_param_type_ref_at(mod: *u8, func_index: i32, i: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, ty_ref: i32): i32;
export extern function xlang_host_is_apple_aarch64(): i32;

/** Copy w bytes from pointer in GP gp (or x0 if gp==0) into home (ascending).
 * When gp==0, park the pointer in x9 (not x1): x1..x7 may still hold later
 * formals (e.g. expr_with_kind(Expr, kind) — kind lives in x1 until this
 * param finishes). Using x1 as scratch wrote &Expr into the kind home. */
function w2060_a64_ph_copy_byref(elf_ctx: *u8, gp: i32, home: i32, w: i32, ta: i32): i32 {
  unsafe {
  let k: i32 = 0;
  let rc: i32 = 0;
  let base_gp: i32 = gp;
  if (gp == 0) {
    unsafe {
      rc = arch_arm64_enc_enc_mov_rax_to_x9(elf_ctx);
    }
    if (rc != 0) {
      return -1;
    }
    base_gp = 9;
  }
  while (k < w) {
    if (base_gp != 0) {
      rc = glue_enc_arm64_mov_xn_to_x0_elf_c(elf_ctx, base_gp);
      if (rc != 0) {
        return -1;
      }
    }
    if (k > 0) {
      unsafe {
        rc = backend_enc_add_imm_to_rax_arch(elf_ctx, k, ta);
      }
      if (rc != 0) {
        return -1;
      }
    }
    unsafe {
      rc = backend_enc_load_64_from_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return -1;
    }
    unsafe {
      rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, home + k, ta);
    }
    if (rc != 0) {
      return -1;
    }
    k = k + 8;
  }
  return 0;
  }
}

/**
 * Home every formal of func_index into its frame slot on AAPCS64.
 * Aggregates >16B arrive as a pointer in one GP (or one stack word).
 * PLATFORM: MACOS|DARWIN ARM64. ta!=1 returns 0.
 */
#[no_mangle]
export function pipeline_asm_emit_param_home_elf_c(elf_ctx: *u8, ctx: *u8, mod: *u8, func_index: i32, ta: i32): i32 {
  unsafe {
  let np: i32 = 0;
  let reg_max: i32 = 8;
  let i: i32 = 0;
  let sret_act: i32 = 0;
  let sret_off: i32 = 0;
  let rc: i32 = 0;
  let arena: *u8 = 0 as *u8;
  let gp: i32 = 0;
  let fp_cur: i32 = 0;
  let is_f64_p: i32 = 0;
  let pty_h: i32 = 0;
  let stack_pos: i32 = 16;
  let cur: i32 = 16;
  let psz: i32 = 0;
  let home_w: i32 = 0;
  let home: i32 = 0;
  let nbytes: i32 = 0;
  let fs: i32 = 0;
  let apple: i32 = 0;
  if (elf_ctx == (0 as *u8) || ctx == (0 as *u8) || mod == (0 as *u8) || func_index < 0) {
    return -1;
  }
  if (ta != 1) {
    return 0;
  }
  pipeline_asm_emit_set_func_index(func_index);
  unsafe {
    np = pipeline_asm_module_func_num_params_at(mod, func_index);
    sret_act = pipeline_asm_emit_ctx_sret_active_get();
    sret_off = pipeline_asm_emit_ctx_sret_home_off_get();
  }
  if (sret_act != 0 && sret_off >= 0) {
    unsafe {
      rc = backend_enc_store_x_reg_to_rbp_arch(elf_ctx, 8, sret_off, ta);
    }
    if (rc != 0) {
      return -1;
    }
  }
  if (np <= 0) {
    return 0;
  }
  unsafe {
    arena = pipeline_asm_emit_ctx_arena_get();
  }
  if (arena == (0 as *u8)) {
    return -1;
  }
  unsafe {
    apple = xlang_host_is_apple_aarch64();
  }
  gp = 0;
  stack_pos = 16;
  cur = 16;
  if (ctx != (0 as *u8)) {
    fs = pipe_load_i32_le(ctx, pipe_asm_ctx_off_frame_size());
    if (fs > 16) {
      stack_pos = fs;
    }
  }
  if ((stack_pos & 15) != 0) {
    stack_pos = stack_pos + (16 - (stack_pos & 15));
  }
  stack_pos = stack_pos + 16;
  i = 0;
  while (i < np) {
    unsafe {
      psz = glue_func_param_agg_byte_size_c(arena, mod, func_index, i);
      home_w = glue_func_param_home_width_c(arena, mod, func_index, i);
    }
    home = cur;
    is_f64_p = 0;
    unsafe {
      pty_h = pipeline_module_func_param_type_ref_at(mod, func_index, i);
    }
    if (pty_h > 0) {
      unsafe {
        if (pipeline_type_kind_ord_at(arena, pty_h) == 15) {
          is_f64_p = 1;
        }
      }
    }
    if (is_f64_p != 0 && fp_cur < reg_max) {
      unsafe {
        rc = backend_enc_mov_xmm_arg_reg_to_rax_arch(elf_ctx, fp_cur, ta);
      }
      if (rc != 0) {
        return -1;
      }
      unsafe {
        rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta);
      }
      if (rc != 0) {
        return -1;
      }
      fp_cur = fp_cur + 1;
    } else if (is_f64_p != 0) {
      stack_pos = glue_arm64_stack_arg_align_pos(stack_pos, 8, apple);
      unsafe {
        rc = backend_enc_load_x29_pos_to_rax_arch(elf_ctx, stack_pos, ta);
      }
      if (rc != 0) {
        return -1;
      }
      unsafe {
        rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta);
      }
      if (rc != 0) {
        return -1;
      }
      stack_pos = glue_arm64_stack_arg_advance_pos(stack_pos, 8, apple);
    } else if (psz > 16) {
      /* w2060: AAPCS64 >16B by reference — one GP (or stack) pointer. */
      nbytes = (psz + 7) & (~7);
      if (home_w > nbytes) {
        nbytes = home_w;
      }
      if (gp < reg_max) {
        if (w2060_a64_ph_copy_byref(elf_ctx, gp, home, nbytes, ta) != 0) {
          return -1;
        }
        gp = gp + 1;
      } else {
        stack_pos = glue_arm64_stack_arg_align_pos(stack_pos, 8, apple);
        unsafe {
          rc = backend_enc_load_x29_pos_to_rax_arch(elf_ctx, stack_pos, ta);
        }
        if (rc != 0) {
          return -1;
        }
        /* pointer now in x0; copy like gp==0 path */
        if (w2060_a64_ph_copy_byref(elf_ctx, 0, home, nbytes, ta) != 0) {
          return -1;
        }
        stack_pos = glue_arm64_stack_arg_advance_pos(stack_pos, 8, apple);
      }
    } else if (psz > 8) {
      if (gp + 2 <= reg_max) {
        unsafe {
          rc = backend_enc_store_x_reg_to_rbp_arch(elf_ctx, gp, home, ta);
        }
        if (rc != 0) {
          return -1;
        }
        unsafe {
          rc = backend_enc_store_x_reg_to_rbp_arch(elf_ctx, gp + 1, home + 8, ta);
        }
        if (rc != 0) {
          return -1;
        }
        gp = gp + 2;
      } else {
        stack_pos = glue_arm64_stack_arg_align_pos(stack_pos, 16, apple);
        unsafe {
          rc = backend_enc_load_x29_pos_to_rax_arch(elf_ctx, stack_pos, ta);
        }
        if (rc != 0) {
          return -1;
        }
        unsafe {
          rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta);
        }
        if (rc != 0) {
          return -1;
        }
        unsafe {
          rc = backend_enc_load_x29_pos_to_rax_arch(elf_ctx, stack_pos + 8, ta);
        }
        if (rc != 0) {
          return -1;
        }
        unsafe {
          rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, home + 8, ta);
        }
        if (rc != 0) {
          return -1;
        }
        stack_pos = glue_arm64_stack_arg_advance_pos(stack_pos, 16, apple);
      }
    } else {
      if (gp < reg_max) {
        if (gp != 0) {
          rc = glue_enc_arm64_mov_xn_to_x0_elf_c(elf_ctx, gp);
          if (rc != 0) {
            return -1;
          }
        }
        rc = glue_enc_canonicalize_param_in_rax_elf_c(elf_ctx, arena, mod, func_index, i, ta);
        if (rc != 0) {
          return -1;
        }
        unsafe {
          rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta);
        }
        if (rc != 0) {
          return -1;
        }
        gp = gp + 1;
      } else {
        stack_pos = glue_arm64_stack_arg_align_pos(stack_pos, psz, apple);
        unsafe {
          rc = backend_enc_load_x29_pos_to_rax_arch(elf_ctx, stack_pos, ta);
        }
        if (rc != 0) {
          return -1;
        }
        rc = glue_enc_canonicalize_param_in_rax_elf_c(elf_ctx, arena, mod, func_index, i, ta);
        if (rc != 0) {
          return -1;
        }
        unsafe {
          rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta);
        }
        if (rc != 0) {
          return -1;
        }
        stack_pos = glue_arm64_stack_arg_advance_pos(stack_pos, psz, apple);
      }
    }
    if (home_w > 8) {
      cur = cur + home_w;
    } else {
      cur = cur + 8;
    }
    i = i + 1;
  }
  return 0;
  }
}
