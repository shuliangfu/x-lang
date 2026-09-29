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
export extern function backend_enc_add_imm_to_rax_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function backend_enc_load_64_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_ctx_module_set(mod: *u8): void;
export extern function pipeline_asm_module_func_param_name_copy32(mod: *u8, func_index: i32, param_index: i32, dst: *u8): void;
export extern function pipeline_asm_module_func_param_name_len_at(mod: *u8, func_index: i32, param_index: i32): i32;
export extern function asm_ctx_local_append(ctx: *u8, name: *u8, name_len: i32, offset: i32): i32;
export extern function asm_ctx_local_count(ctx: *u8): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_asm_ctx_off_num_locals(): i32;
export extern function pipe_asm_ctx_off_next_offset(): i32;
export extern function w1521_win_note_func_c(mod: *u8, func_index: i32): void;

/**
 * w1521 (终局待办 10.57): Windows formal slot table matching the tip x86
 * branch. The egg body gave a >16B by-value formal a single 8-byte slot, so
 * `sum(x, s, y)` put x/s/y at -0x10/-0x18/-0x20 and s.b/s.c read x and the
 * saved rbx. A formal wider than 8 bytes now owns [off+8, off+width] with the
 * slot at off+width (lowest address = field 0), like Linux/Darwin x86 tip.
 * PLATFORM: WINDOWS x86_64 ONLY.
 */
#[no_mangle]
export function pipeline_asm_fill_param_slots(ctx: *u8, mod: *u8, func_index: i32): void {
  let off: i32 = 16;
  let np: i32 = 0;
  let i: i32 = 0;
  let pname_buf: u8[256] = [];
  let plen: i32 = 0;
  let arena: *u8 = 0 as *u8;
  let width: i32 = 0;
  let slot_off: i32 = 0;
  let ap: i32 = 0;
  let nloc: i32 = 0;
  if (ctx == (0 as *u8) || mod == (0 as *u8)) {
    return;
  }
  unsafe {
    pipeline_asm_emit_ctx_module_set(mod);
    arena = pipeline_asm_emit_ctx_arena_get();
    np = pipeline_asm_module_func_num_params_at(mod, func_index);
  }
  i = 0;
  while (i < np) {
    unsafe {
      pipeline_asm_module_func_param_name_copy32(mod, func_index, i, &pname_buf[0]);
      plen = pipeline_asm_module_func_param_name_len_at(mod, func_index, i);
    }
    width = 8;
    if (arena != (0 as *u8)) {
      unsafe {
        width = glue_func_param_home_width_c(arena, mod, func_index, i);
      }
    }
    if (width > 8) {
      slot_off = off + width;
    } else {
      slot_off = off;
    }
    unsafe {
      ap = asm_ctx_local_append(ctx, &pname_buf[0], plen, slot_off);
    }
    if (ap < 0) {
      return;
    }
    unsafe {
      nloc = asm_ctx_local_count(ctx);
      pipe_store_i32_le(ctx, pipe_asm_ctx_off_num_locals(), nloc);
    }
    if (width > 8) {
      off = slot_off + 8;
    } else {
      off = off + 8;
    }
    i = i + 1;
  }
  unsafe {
    pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), off);
  }
}

/**
 * w1521 (10.57): copy a Win64 by-reference >16B formal (address in arg
 * register gp) into its slot [slot-w+8 .. slot], qword k at slot - k.
 * @return 0 ok, -1 encode error. PLATFORM: WINDOWS x86_64.
 */
function w1521_ph_copy_byref(elf_ctx: *u8, gp: i32, slot: i32, w: i32, ta: i32): i32 {
  let k: i32 = 0;
  let rc: i32 = 0;
  while (k < w) {
    unsafe {
      rc = backend_enc_mov_arg_reg_to_rax_arch(elf_ctx, gp, ta);
    }
    if (rc != 0) {
      return -1;
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
      rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, slot - k, ta);
    }
    if (rc != 0) {
      return -1;
    }
    k = k + 8;
  }
  return 0;
}

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
    w1521_win_note_func_c(mod, func_index);
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
    if (w > 16) {
      // w1521 (10.57): Win64 passes >16B by value as a pointer in one GP.
      wide_home = home + w;
      if (w1521_ph_copy_byref(elf_ctx, gp, wide_home, w, ta) != 0) {
        return -1;
      }
      gp = gp + 1;
      home = wide_home + 8;
    } else if (w > 8 && w <= 16) {
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
