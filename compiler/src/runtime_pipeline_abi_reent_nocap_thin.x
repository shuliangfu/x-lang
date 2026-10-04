// Thin pure override of glue_slice_let_reent_deep_copy_after_dual_gp_elf_c.
// w2056: one rule for a CALL-returned slice, replacing the w1544 split
//   (deep-copy up to 1024 elements into a frame / COMMON buffer, alias
//   anything longer). After the call returns, the emitted code checks at
//   run time where fat.data points:
//   - not inside the callee's released stack (the 8MiB just below the
//     caller's sp): the slice is left as-is, no copy;
//   - inside it: the full payload (length * esz bytes, no cap) is copied
//     into a fresh malloc block and fat.data is retargeted to it.
//   Before malloc runs, sp is moved below the payload so neither the call
//   nor the saved registers overwrite the bytes still to be copied. No
//   frame slot, no COMMON buffer and no push happens before that point.
// Built by g05_relink_env.sh _g05_pure_overlay on every relink.
// PLATFORM: SHARED freestanding. LINUX gold. MACOS. WINDOWS.

export extern function glue_index_elem_byte_sz_from_type_ref_c(arena: *u8, tr: i32): i32;
export extern function glue_slice_dual_gp_length_off_c(data_home: i32, ta: i32): i32;
export extern function pipeline_asm_emit_next_label_c(ctx: *u8, buf: *u8, buf_size: i32): i32;
export extern function backend_enc_append_u8_c(elf_ctx: *u8, byte: i32): i32;
export extern function backend_enc_append_u32_le_c(elf_ctx: *u8, word: u32): i32;
export extern function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_jge_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32;
export extern function backend_enc_jmp_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32;
export extern function backend_enc_label_arch(elf_ctx: *u8, name: *u8, name_len: i32, is_global: i32, ta: i32): i32;
export extern function backend_enc_call_arch(elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32;
export extern function glue_binop_var_slot_cache_invalidate_rax(): void;
export extern function glue_binop_var_slot_cache_invalidate_rbx(): void;

/** 1 when the x86_64 target uses the Win64 call convention. PLATFORM: WINDOWS. */
#[cfg(target_os = "windows")]
function rdc_win64(): i32 {
  return 1;
}

/** 0 on SysV / AAPCS64 targets. PLATFORM: SHARED non-Windows. */
#[cfg(not(target_os = "windows"))]
function rdc_win64(): i32 {
  return 0;
}

/**
 * Append n (1..6) raw x86_64 bytes.
 * @param elf_ctx *u8 — object writer context
 * @param n i32 — how many of b0..b5 to append
 * @return i32 — 0 ok, -1 on append failure
 * PLATFORM: SHARED x86_64.
 */
function rdc_x86(elf_ctx: *u8, n: i32, b0: i32, b1: i32, b2: i32, b3: i32, b4: i32, b5: i32): i32 {
  unsafe {
    if (n > 0 && backend_enc_append_u8_c(elf_ctx, b0) != 0) { return 0 - 1; }
    if (n > 1 && backend_enc_append_u8_c(elf_ctx, b1) != 0) { return 0 - 1; }
    if (n > 2 && backend_enc_append_u8_c(elf_ctx, b2) != 0) { return 0 - 1; }
    if (n > 3 && backend_enc_append_u8_c(elf_ctx, b3) != 0) { return 0 - 1; }
    if (n > 4 && backend_enc_append_u8_c(elf_ctx, b4) != 0) { return 0 - 1; }
    if (n > 5 && backend_enc_append_u8_c(elf_ctx, b5) != 0) { return 0 - 1; }
  }
  return 0;
}

/**
 * Append one raw arm64 instruction word.
 * @param elf_ctx *u8 — object writer context
 * @param w u32 — instruction word
 * @return i32 — 0 ok, -1 on append failure
 * PLATFORM: SHARED arm64.
 */
function rdc_a64(elf_ctx: *u8, w: u32): i32 {
  unsafe {
    return backend_enc_append_u32_le_c(elf_ctx, w);
  }
  return 0 - 1;
}

/**
 * x86_64 body. On entry nothing is parked; fat.data / length are at home.
 * Registers: r10 = data, r11 = length then byte count, r8 = saved rsp,
 * r9 = new block. rsi / rdi are pushed around rep movsb (Win64 keeps them).
 * @return i32 — 0 ok, -1 on encode failure
 * PLATFORM: LINUX x86_64 SysV. WINDOWS x86_64 Win64.
 */
function rdc_emit_x86(elf_ctx: *u8, home: i32, len_off: i32, esz: i32,
    skip_lbl: *u8, skip_len: i32, rest_lbl: *u8, rest_len: i32, mname: *u8): i32 {
  let win: i32 = rdc_win64();
  unsafe {
    // r10 = fat.data, r11 = fat.length
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, home, 0) != 0) { return 0 - 1; }
    if (rdc_x86(elf_ctx, 3, 73, 137, 194, 0, 0, 0) != 0) { return 0 - 1; }      // mov r10, rax
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, len_off, 0) != 0) { return 0 - 1; }
    if (rdc_x86(elf_ctx, 3, 73, 137, 195, 0, 0, 0) != 0) { return 0 - 1; }      // mov r11, rax
    // data >= rsp: caller-owned / heap / static above the stack top → alias
    if (rdc_x86(elf_ctx, 3, 76, 137, 208, 0, 0, 0) != 0) { return 0 - 1; }      // mov rax, r10
    if (rdc_x86(elf_ctx, 3, 72, 137, 227, 0, 0, 0) != 0) { return 0 - 1; }      // mov rbx, rsp
    if (rdc_x86(elf_ctx, 3, 72, 57, 216, 0, 0, 0) != 0) { return 0 - 1; }       // cmp rax, rbx
    if (backend_enc_jge_arch(elf_ctx, skip_lbl, skip_len, 0) != 0) { return 0 - 1; }
    // rsp - 8MiB >= data: not the released callee stack → alias
    if (rdc_x86(elf_ctx, 3, 72, 137, 224, 0, 0, 0) != 0) { return 0 - 1; }      // mov rax, rsp
    if (rdc_x86(elf_ctx, 6, 72, 45, 0, 0, 128, 0) != 0) { return 0 - 1; }       // sub rax, 0x800000
    if (rdc_x86(elf_ctx, 3, 76, 137, 211, 0, 0, 0) != 0) { return 0 - 1; }      // mov rbx, r10
    if (rdc_x86(elf_ctx, 3, 72, 57, 216, 0, 0, 0) != 0) { return 0 - 1; }       // cmp rax, rbx
    if (backend_enc_jge_arch(elf_ctx, skip_lbl, skip_len, 0) != 0) { return 0 - 1; }
    // 0 >= length → nothing to copy
    if (rdc_x86(elf_ctx, 2, 49, 192, 0, 0, 0, 0) != 0) { return 0 - 1; }        // xor eax, eax
    if (rdc_x86(elf_ctx, 3, 76, 137, 219, 0, 0, 0) != 0) { return 0 - 1; }      // mov rbx, r11
    if (rdc_x86(elf_ctx, 3, 72, 57, 216, 0, 0, 0) != 0) { return 0 - 1; }       // cmp rax, rbx
    if (backend_enc_jge_arch(elf_ctx, skip_lbl, skip_len, 0) != 0) { return 0 - 1; }
    // r11 = length * esz (bytes)
    if (rdc_x86(elf_ctx, 3, 77, 105, 219, 0, 0, 0) != 0) { return 0 - 1; }      // imul r11, r11, imm32
    if (rdc_x86(elf_ctx, 4, esz & 255, (esz / 256) & 255, (esz / 65536) & 255, (esz / 16777216) & 255, 0, 0) != 0) { return 0 - 1; }
    // r8 = rsp; rsp = (data - 128) & -16 (below the payload)
    if (rdc_x86(elf_ctx, 3, 73, 137, 224, 0, 0, 0) != 0) { return 0 - 1; }      // mov r8, rsp
    if (rdc_x86(elf_ctx, 3, 76, 137, 208, 0, 0, 0) != 0) { return 0 - 1; }      // mov rax, r10
    if (rdc_x86(elf_ctx, 6, 72, 45, 128, 0, 0, 0) != 0) { return 0 - 1; }       // sub rax, 128
    if (rdc_x86(elf_ctx, 4, 72, 131, 224, 240, 0, 0) != 0) { return 0 - 1; }    // and rax, -16
    if (rdc_x86(elf_ctx, 3, 72, 137, 196, 0, 0, 0) != 0) { return 0 - 1; }      // mov rsp, rax
    // keep r8 / r10 / r11 across malloc (4 pushes keep 16-byte alignment)
    if (rdc_x86(elf_ctx, 2, 65, 80, 0, 0, 0, 0) != 0) { return 0 - 1; }         // push r8
    if (rdc_x86(elf_ctx, 2, 65, 82, 0, 0, 0, 0) != 0) { return 0 - 1; }         // push r10
    if (rdc_x86(elf_ctx, 2, 65, 83, 0, 0, 0, 0) != 0) { return 0 - 1; }         // push r11
    if (rdc_x86(elf_ctx, 2, 65, 83, 0, 0, 0, 0) != 0) { return 0 - 1; }         // push r11
    if (win != 0) {
      if (rdc_x86(elf_ctx, 3, 76, 137, 217, 0, 0, 0) != 0) { return 0 - 1; }    // mov rcx, r11
      if (rdc_x86(elf_ctx, 4, 72, 131, 236, 32, 0, 0) != 0) { return 0 - 1; }   // sub rsp, 32
    } else {
      if (rdc_x86(elf_ctx, 3, 76, 137, 223, 0, 0, 0) != 0) { return 0 - 1; }    // mov rdi, r11
    }
    if (backend_enc_call_arch(elf_ctx, mname, 6, 0) != 0) { return 0 - 1; }
    if (win != 0) {
      if (rdc_x86(elf_ctx, 4, 72, 131, 196, 32, 0, 0) != 0) { return 0 - 1; }   // add rsp, 32
    }
    if (rdc_x86(elf_ctx, 2, 65, 91, 0, 0, 0, 0) != 0) { return 0 - 1; }         // pop r11
    if (rdc_x86(elf_ctx, 2, 65, 91, 0, 0, 0, 0) != 0) { return 0 - 1; }         // pop r11
    if (rdc_x86(elf_ctx, 2, 65, 90, 0, 0, 0, 0) != 0) { return 0 - 1; }         // pop r10
    if (rdc_x86(elf_ctx, 2, 65, 88, 0, 0, 0, 0) != 0) { return 0 - 1; }         // pop r8
    // malloc returned 0 → restore rsp, keep the alias
    if (rdc_x86(elf_ctx, 3, 72, 137, 195, 0, 0, 0) != 0) { return 0 - 1; }      // mov rbx, rax
    if (rdc_x86(elf_ctx, 2, 49, 192, 0, 0, 0, 0) != 0) { return 0 - 1; }        // xor eax, eax
    if (rdc_x86(elf_ctx, 3, 72, 57, 216, 0, 0, 0) != 0) { return 0 - 1; }       // cmp rax, rbx
    if (backend_enc_jge_arch(elf_ctx, rest_lbl, rest_len, 0) != 0) { return 0 - 1; }
    // copy r11 bytes from r10 to the block
    if (rdc_x86(elf_ctx, 3, 73, 137, 217, 0, 0, 0) != 0) { return 0 - 1; }      // mov r9, rbx
    if (rdc_x86(elf_ctx, 1, 86, 0, 0, 0, 0, 0) != 0) { return 0 - 1; }          // push rsi
    if (rdc_x86(elf_ctx, 1, 87, 0, 0, 0, 0, 0) != 0) { return 0 - 1; }          // push rdi
    if (rdc_x86(elf_ctx, 3, 76, 137, 214, 0, 0, 0) != 0) { return 0 - 1; }      // mov rsi, r10
    if (rdc_x86(elf_ctx, 3, 76, 137, 207, 0, 0, 0) != 0) { return 0 - 1; }      // mov rdi, r9
    if (rdc_x86(elf_ctx, 3, 76, 137, 217, 0, 0, 0) != 0) { return 0 - 1; }      // mov rcx, r11
    if (rdc_x86(elf_ctx, 3, 252, 243, 164, 0, 0, 0) != 0) { return 0 - 1; }     // cld; rep movsb
    if (rdc_x86(elf_ctx, 1, 95, 0, 0, 0, 0, 0) != 0) { return 0 - 1; }          // pop rdi
    if (rdc_x86(elf_ctx, 1, 94, 0, 0, 0, 0, 0) != 0) { return 0 - 1; }          // pop rsi
    if (rdc_x86(elf_ctx, 3, 76, 137, 196, 0, 0, 0) != 0) { return 0 - 1; }      // mov rsp, r8
    if (rdc_x86(elf_ctx, 3, 76, 137, 200, 0, 0, 0) != 0) { return 0 - 1; }      // mov rax, r9
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home, 0) != 0) { return 0 - 1; }
    if (backend_enc_jmp_arch(elf_ctx, skip_lbl, skip_len, 0) != 0) { return 0 - 1; }
    if (backend_enc_label_arch(elf_ctx, rest_lbl, rest_len, 0, 0) != 0) { return 0 - 1; }
    if (rdc_x86(elf_ctx, 3, 76, 137, 196, 0, 0, 0) != 0) { return 0 - 1; }      // mov rsp, r8
  }
  return 0;
}

/**
 * arm64 body. Registers: x10 = data, x11 = length then byte count,
 * x12 = saved sp, x13 = new block, x14 = index, x15 = byte.
 * @return i32 — 0 ok, -1 on encode failure
 * PLATFORM: MACOS arm64 AAPCS64.
 */
function rdc_emit_a64(elf_ctx: *u8, ctx: *u8, home: i32, len_off: i32, esz: i32,
    skip_lbl: *u8, skip_len: i32, rest_lbl: *u8, rest_len: i32, mname: *u8): i32 {
  let loop_lbl: u8[32] = [];
  let done_lbl: u8[32] = [];
  let loop_len: i32 = 0;
  let done_len: i32 = 0;
  unsafe {
    loop_len = pipeline_asm_emit_next_label_c(ctx, &loop_lbl[0], 32);
    done_len = pipeline_asm_emit_next_label_c(ctx, &done_lbl[0], 32);
  }
  if (loop_len <= 0 || done_len <= 0) {
    return 0 - 1;
  }
  unsafe {
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, home, 1) != 0) { return 0 - 1; }
    if (rdc_a64(elf_ctx, 2852127722 as u32) != 0) { return 0 - 1; }   // mov x10, x0
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, len_off, 1) != 0) { return 0 - 1; }
    if (rdc_a64(elf_ctx, 2852127723 as u32) != 0) { return 0 - 1; }   // mov x11, x0
    if (rdc_a64(elf_ctx, 2432697324 as u32) != 0) { return 0 - 1; }   // mov x12, sp
    // data >= sp → alias
    if (rdc_a64(elf_ctx, 2852783072 as u32) != 0) { return 0 - 1; }   // mov x0, x10
    if (rdc_a64(elf_ctx, 3943432223 as u32) != 0) { return 0 - 1; }   // cmp x0, x12
    if (backend_enc_jge_arch(elf_ctx, skip_lbl, skip_len, 1) != 0) { return 0 - 1; }
    // sp - 8MiB >= data → alias
    if (rdc_a64(elf_ctx, 3512729984 as u32) != 0) { return 0 - 1; }   // sub x0, x12, #0x800, lsl #12
    if (rdc_a64(elf_ctx, 3943301151 as u32) != 0) { return 0 - 1; }   // cmp x0, x10
    if (backend_enc_jge_arch(elf_ctx, skip_lbl, skip_len, 1) != 0) { return 0 - 1; }
    // 0 >= length → nothing to copy
    if (rdc_a64(elf_ctx, 3531603968 as u32) != 0) { return 0 - 1; }   // mov x0, #0
    if (rdc_a64(elf_ctx, 3943366687 as u32) != 0) { return 0 - 1; }   // cmp x0, x11
    if (backend_enc_jge_arch(elf_ctx, skip_lbl, skip_len, 1) != 0) { return 0 - 1; }
    // x11 = length * esz (bytes)
    if (rdc_a64(elf_ctx, (3531603977 as u32) + ((esz * 32) as u32)) != 0) { return 0 - 1; }   // movz x9, #esz
    if (rdc_a64(elf_ctx, 2601090411 as u32) != 0) { return 0 - 1; }   // mul x11, x11, x9
    // sp = (data - 128) & -16 (below the payload)
    if (rdc_a64(elf_ctx, 3506569536 as u32) != 0) { return 0 - 1; }   // sub x0, x10, #128
    if (rdc_a64(elf_ctx, 2457660416 as u32) != 0) { return 0 - 1; }   // and x0, x0, #-16
    if (rdc_a64(elf_ctx, 2432696351 as u32) != 0) { return 0 - 1; }   // mov sp, x0
    // keep x10 / x11 / x12 across malloc
    if (rdc_a64(elf_ctx, 2847813610 as u32) != 0) { return 0 - 1; }   // stp x10, x11, [sp, #-32]!
    if (rdc_a64(elf_ctx, 4177529836 as u32) != 0) { return 0 - 1; }   // str x12, [sp, #16]
    if (rdc_a64(elf_ctx, 2852848608 as u32) != 0) { return 0 - 1; }   // mov x0, x11
    if (backend_enc_call_arch(elf_ctx, mname, 6, 1) != 0) { return 0 - 1; }
    if (rdc_a64(elf_ctx, 4181724140 as u32) != 0) { return 0 - 1; }   // ldr x12, [sp, #16]
    if (rdc_a64(elf_ctx, 2831298538 as u32) != 0) { return 0 - 1; }   // ldp x10, x11, [sp], #32
    // malloc returned 0 → restore sp, keep the alias
    if (rdc_a64(elf_ctx, 2852127725 as u32) != 0) { return 0 - 1; }   // mov x13, x0
    if (rdc_a64(elf_ctx, 3531603968 as u32) != 0) { return 0 - 1; }   // mov x0, #0
    if (rdc_a64(elf_ctx, 3943497759 as u32) != 0) { return 0 - 1; }   // cmp x0, x13
    if (backend_enc_jge_arch(elf_ctx, rest_lbl, rest_len, 1) != 0) { return 0 - 1; }
    // byte copy x11 bytes from x10 to x13
    if (rdc_a64(elf_ctx, 3531603982 as u32) != 0) { return 0 - 1; }   // mov x14, #0
    if (backend_enc_label_arch(elf_ctx, &loop_lbl[0], loop_len, 0, 1) != 0) { return 0 - 1; }
    if (rdc_a64(elf_ctx, 3943367135 as u32) != 0) { return 0 - 1; }   // cmp x14, x11
    if (backend_enc_jge_arch(elf_ctx, &done_lbl[0], done_len, 1) != 0) { return 0 - 1; }
    if (rdc_a64(elf_ctx, 946760015 as u32) != 0) { return 0 - 1; }    // ldrb w15, [x10, x14]
    if (rdc_a64(elf_ctx, 942565807 as u32) != 0) { return 0 - 1; }    // strb w15, [x13, x14]
    if (rdc_a64(elf_ctx, 2432697806 as u32) != 0) { return 0 - 1; }   // add x14, x14, #1
    if (backend_enc_jmp_arch(elf_ctx, &loop_lbl[0], loop_len, 1) != 0) { return 0 - 1; }
    if (backend_enc_label_arch(elf_ctx, &done_lbl[0], done_len, 0, 1) != 0) { return 0 - 1; }
    if (rdc_a64(elf_ctx, 2432696735 as u32) != 0) { return 0 - 1; }   // mov sp, x12
    if (rdc_a64(elf_ctx, 2852979680 as u32) != 0) { return 0 - 1; }   // mov x0, x13
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home, 1) != 0) { return 0 - 1; }
    if (backend_enc_jmp_arch(elf_ctx, skip_lbl, skip_len, 1) != 0) { return 0 - 1; }
    if (backend_enc_label_arch(elf_ctx, rest_lbl, rest_len, 0, 1) != 0) { return 0 - 1; }
    if (rdc_a64(elf_ctx, 2432696735 as u32) != 0) { return 0 - 1; }   // mov sp, x12
  }
  return 0;
}

/**
 * Retarget a CALL-returned slice per the w2056 rule (see file header).
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — object writer context
 * @param ctx *u8 — emit context (labels)
 * @param ta i32 — 0 = x86_64, 1 = arm64
 * @param home i32 — fat data home (rbp-relative)
 * @param ty_ref i32 — TYPE_SLICE type ref
 * @param use_frame i32 — kept for the caller ABI; both paths share one rule
 * @return i32 — 0 on success, negative on failure
 * The filename contains "pipeline", so the entry-module prefix would emit
 * pipeline_glue_slice_let_reent_deep_copy_after_dual_gp_elf_c. The egg and
 * g05 both require the bare name.
 * PLATFORM: SHARED freestanding. LINUX gold. MACOS. WINDOWS.
 */
#[no_mangle]
export function glue_slice_let_reent_deep_copy_after_dual_gp_elf_c(
    arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32, home: i32, ty_ref: i32, use_frame: i32): i32 {
  let esz: i32 = 4;
  let len_off: i32 = 0;
  let rc: i32 = 0;
  let skip_lbl: u8[32] = [];
  let rest_lbl: u8[32] = [];
  let skip_len: i32 = 0;
  let rest_len: i32 = 0;
  let mname: u8[8] = [];

  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8) || home < 0 || ty_ref <= 0) {
    return 0 - 1;
  }
  if (ta != 0 && ta != 1) {
    return 0 - 1;
  }
  /*
   * Outer element stride of this TYPE_SLICE = index esz of ty_ref itself
   * (nested [][]T → fat 16, not the inner 4; 4.2.7).
   */
  unsafe {
    esz = glue_index_elem_byte_sz_from_type_ref_c(arena, ty_ref);
  }
  if (esz <= 0) {
    esz = 4;
  }
  // wave632: esz>8 large NAMED / nested fat(16) kept; weird mid widths 3/5/6/7 fall to 4.
  if (esz != 1 && esz != 2 && esz != 4 && esz != 8 && esz <= 8) {
    esz = 4;
  }
  // arm64 loads esz with one movz (16-bit immediate).
  if (esz > 65535) {
    return 0 - 1;
  }
  unsafe {
    len_off = glue_slice_dual_gp_length_off_c(home, ta);
  }
  unsafe {
    skip_len = pipeline_asm_emit_next_label_c(ctx, &skip_lbl[0], 32);
    rest_len = pipeline_asm_emit_next_label_c(ctx, &rest_lbl[0], 32);
  }
  if (skip_len <= 0 || rest_len <= 0) {
    return 0 - 1;
  }
  // "malloc"
  mname[0] = 109 as u8;
  mname[1] = 97 as u8;
  mname[2] = 108 as u8;
  mname[3] = 108 as u8;
  mname[4] = 111 as u8;
  mname[5] = 99 as u8;
  mname[6] = 0 as u8;
  if (ta == 1) {
    rc = rdc_emit_a64(elf_ctx, ctx, home, len_off, esz, &skip_lbl[0], skip_len, &rest_lbl[0], rest_len, &mname[0]);
  } else {
    rc = rdc_emit_x86(elf_ctx, home, len_off, esz, &skip_lbl[0], skip_len, &rest_lbl[0], rest_len, &mname[0]);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_label_arch(elf_ctx, &skip_lbl[0], skip_len, 0, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  // Raw bytes above clobber rax / rbx behind the var-slot cache's back.
  unsafe {
    glue_binop_var_slot_cache_invalidate_rax();
    glue_binop_var_slot_cache_invalidate_rbx();
  }
  if (use_frame < 0) {
    return 0 - 1;
  }
  return 0;
}
