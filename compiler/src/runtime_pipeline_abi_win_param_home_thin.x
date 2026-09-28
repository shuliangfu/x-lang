// Thin pure override: Windows formal-parameter homing with narrow-scalar
// canonicalization (pipeline_asm_emit_param_home_elf_c).
// w1500 (终局待办 10.23): pure .x replacement for the former host-cc sidecar
// seeds/runtime_pipeline_abi_win_param_home_overlay.c (w1497, 10.17 root).
// The Windows egg mega_body calls its same-TU leftover-PE copy, which homes
// each GP formal with a plain 64-bit move; a C caller passing an i32 on the
// stack writes only the low 32 bits, so the first 64-bit use read garbage.
// This body matches the egg slot layout and calls
// glue_enc_canonicalize_param_in_rax_elf_c for 1-slot formals, like the
// Linux/Darwin tip bodies.
// Windows only: g05_relink_env.sh compiles it with the current product (pure
// asm, no host cc), weakens the egg T in pabi_weak, and
// scripts/win_patch_body_sync_jmp.py patches the egg W and local (t) copies
// to jmp here. Darwin/Linux keep their tip bodies and never link this file.
// PLATFORM: WINDOWS x86_64 ONLY.

export extern function pipeline_asm_emit_ctx_sret_active_get(): i32;
export extern function pipeline_asm_emit_ctx_sret_home_off_get(): i32;
export extern function pipeline_asm_module_func_num_params_at(mod: *u8, func_index: i32): i32;
export extern function pipeline_asm_emit_ctx_arena_get(): *u8;
export extern function glue_func_param_home_width_c(arena: *u8, mod: *u8, func_index: i32, param_index: i32): i32;
export extern function glue_asm_call_reg_max(ta: i32): i32;
export extern function backend_enc_mov_arg_reg_to_rax_arch(elf_ctx: *u8, k: i32, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, off: i32, ta: i32): i32;
export extern function glue_enc_canonicalize_param_in_rax_elf_c(elf_ctx: *u8, arena: *u8, mod: *u8, func_index: i32, param_index: i32, ta: i32): i32;

/** Move arg register k to rax and store it at rbp slot off. PLATFORM: WINDOWS. */
function w1500_ph_mov_store(elf_ctx: *u8, k: i32, off: i32, ta: i32): i32 {
  let rc: i32 = 0;
  unsafe {
    rc = backend_enc_mov_arg_reg_to_rax_arch(elf_ctx, k, ta);
  }
  if (rc != 0) {
    return -1;
  }
  unsafe {
    rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, off, ta);
  }
  if (rc != 0) {
    return -1;
  }
  return 0;
}

/**
 * Home every GP formal of func_index into its rbp slot (Windows x86_64).
 * @return 0 ok, -1 encode error. PLATFORM: WINDOWS.
 */
#[no_mangle]
export function pipeline_asm_emit_param_home_elf_c(elf_ctx: *u8, ctx: *u8, mod: *u8, func_index: i32, ta: i32): i32 {
  let np: i32 = 0;
  let i: i32 = 0;
  let home: i32 = 16;
  let sret_act: i32 = 0;
  let sret_off: i32 = 0;
  let gp: i32 = 0;
  let reg_max: i32 = 0;
  let w: i32 = 0;
  let wide_home: i32 = 0;
  let rc: i32 = 0;
  let arena_ph: *u8 = 0 as *u8;
  if (elf_ctx == (0 as *u8) || mod == (0 as *u8) || func_index < 0) {
    return -1;
  }
  if (ta != 0) {
    return 0;
  }
  unsafe {
    sret_act = pipeline_asm_emit_ctx_sret_active_get();
    sret_off = pipeline_asm_emit_ctx_sret_home_off_get();
  }
  if (sret_act != 0 && sret_off >= 0) {
    if (w1500_ph_mov_store(elf_ctx, 0, sret_off, ta) != 0) {
      return -1;
    }
  }
  unsafe {
    np = pipeline_asm_module_func_num_params_at(mod, func_index);
  }
  if (np <= 0) {
    return 0;
  }
  if (sret_act != 0) {
    gp = 1;
  }
  unsafe {
    reg_max = glue_asm_call_reg_max(ta);
  }
  if (reg_max < 1) {
    reg_max = 6;
  }
  i = 0;
  while (i < np && gp < reg_max) {
    unsafe {
      arena_ph = pipeline_asm_emit_ctx_arena_get();
      w = glue_func_param_home_width_c(arena_ph, mod, func_index, i);
    }
    if (w <= 0) {
      w = 8;
    }
    if (w > 8 && w <= 16) {
      wide_home = home + w;
      if (w1500_ph_mov_store(elf_ctx, gp, wide_home, ta) != 0) {
        return -1;
      }
      gp = gp + 1;
      if (gp >= reg_max) {
        return -1;
      }
      if (w1500_ph_mov_store(elf_ctx, gp, wide_home - 8, ta) != 0) {
        return -1;
      }
      gp = gp + 1;
      home = wide_home + 8;
    } else {
      unsafe {
        rc = backend_enc_mov_arg_reg_to_rax_arch(elf_ctx, gp, ta);
      }
      if (rc != 0) {
        return -1;
      }
      if (arena_ph != (0 as *u8)) {
        unsafe {
          rc = glue_enc_canonicalize_param_in_rax_elf_c(elf_ctx, arena_ph, mod, func_index, i, ta);
        }
        if (rc != 0) {
          return -1;
        }
      }
      unsafe {
        rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta);
      }
      if (rc != 0) {
        return -1;
      }
      gp = gp + 1;
      home = home + 8;
    }
    i = i + 1;
  }
  return 0;
}
