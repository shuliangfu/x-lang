// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: Apache-2.0
// knife256/10.2: Cap tip soft — widen named layout >16 (String byref).
// PLATFORM: SHARED.

export extern function pipeline_asm_call_arg_value_byte_size_c(arena: *u8, ctx: *u8, arg_ref: i32, pty: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, er: i32): i32;
export extern function pipeline_asm_type_ref_byte_size_c(arena: *u8, ty: i32): i32;
export extern function glue_type_named_layout_size_any_module_elf_c(arena: *u8, ty: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, er: i32): i32;
export extern function glue_call_return_byte_size_c(arena: *u8, call: i32): i32;
export extern function glue_sysv_dual_gp_byte_size_c(arena: *u8, ty: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, ty: i32): i32;
/** Win64-only mid size; Cap tip soft stub (Darwin/Linux → 0). */
function w1545_arg_mid_sz(arena: *u8, pty: i32, arg_ref: i32): i32 {
  if (arena == 0 as *u8) { return 0; }
  if (pty < 0) { return 0; }
  if (arg_ref < 0) { return 0; }
  return 0;
}

#[no_mangle]
export function glue_sysv_arg_byte_size_c(arena: *u8, ctx: *u8, pty: i32, arg_ref: i32): i32 {
  // LANG-007: pure-asm typeck keeps allow_legacy_extern off, so the
  // body-less extern calls in this function sit in one unsafe block.
  unsafe {
  let sz: i32 = 0;
  let alt: i32 = 0;
  let ko: i32 = 0;
  let tr: i32 = 0;
  if (arena != 0 as *u8) {
    sz = pipeline_asm_call_arg_value_byte_size_c(arena, ctx, arg_ref, pty);
  }
  // Preserve call_arg SLICE/ARRAY→8 pointer packing for VAR/FIELD/etc.
  // Widen nested CALL/METHOD when soft (≤16): formal/resolved named layout +
  // callee return (ErrorChain 20B). Widen non-CALL soft only to MEMORY (>16).
  // PLATFORM: SHARED freestanding · MACOS|ARM64 host-indirect · LINUX SysV.
  if (arg_ref > 0) {
    if (arena != 0 as *u8) {
      ko = pipeline_expr_kind_ord_at(arena, arg_ref);
      if (ko == 48 || ko == 49) {
        if (sz <= 16) {
          if (pty > 0) {
            alt = pipeline_asm_type_ref_byte_size_c(arena, pty);
            if (alt > sz) { sz = alt; }
            alt = glue_type_named_layout_size_any_module_elf_c(arena, pty);
            if (alt > sz) { sz = alt; }
          }
          tr = pipeline_expr_resolved_type_ref(arena, arg_ref);
          if (tr > 0) {
            alt = pipeline_asm_type_ref_byte_size_c(arena, tr);
            if (alt > sz) { sz = alt; }
            alt = glue_type_named_layout_size_any_module_elf_c(arena, tr);
            if (alt > sz) { sz = alt; }
          }
          alt = glue_call_return_byte_size_c(arena, arg_ref);
          if (alt > sz) { sz = alt; }
        }
      } else {
        // Non-CALL VAR/FIELD/…: soft sz≤8 must recover 9–16 INTEGER dual-GP.
        // knife256/10.2 Cap tip: local struct Lex and TYPE_NAMED Lexer both
        // soft-floor to 8; kind==8-only gate missed non-NAMED layouts so Cap
        // tip still 1-GP packed (lexpack probe). Widen via named_layout /
        // type_ref / dual_gp when result is 9–16 only (ARRAY E* pack stays
        // ≤8). PLATFORM: SHARED · LINUX SysV gold · MACOS|ARM64 Cap tip.
        if (sz <= 8) {
          // knife256/10.2: widen 9–16 (dual-GP) AND >16 (AAPCS64 byref /
          // SysV MEMORY). Prior alt<=16-only left String(260) at soft 8 →
          // Cap tip loaded first qword into x0 for length(s) → SEGV.
          // ARRAY/SLICE/PTR still forced to 8 below. PLATFORM: SHARED.
          if (pty > 0) {
            alt = glue_type_named_layout_size_any_module_elf_c(arena, pty);
            if (alt > 8) {
              if (alt > sz) { sz = alt; }
            }
            if (sz <= 8) {
              alt = pipeline_asm_type_ref_byte_size_c(arena, pty);
              if (alt > 8) {
                if (alt > sz) { sz = alt; }
              }
            }
            alt = glue_sysv_dual_gp_byte_size_c(arena, pty);
            if (alt > sz) { sz = alt; }
          }
          tr = pipeline_expr_resolved_type_ref(arena, arg_ref);
          if (tr > 0) {
            alt = glue_type_named_layout_size_any_module_elf_c(arena, tr);
            if (alt > 8) {
              if (alt > sz) { sz = alt; }
            }
            if (sz <= 8) {
              alt = pipeline_asm_type_ref_byte_size_c(arena, tr);
              if (alt > 8) {
                if (alt > sz) { sz = alt; }
              }
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
  // knife256/10.2: ARRAY/SLICE/PTR call-arg is always E* (8B). named_layout /
  // type_ref_byte_size on u8[12] return 12 and undid call_arg_value decay
  // (print packed x0=ptr,x1=ptr,x2=len). Gate after widen. PLATFORM: SHARED.
  if (arena != 0 as *u8) {
    if (arg_ref > 0) {
      tr = pipeline_expr_resolved_type_ref(arena, arg_ref);
      if (tr > 0) {
        ko = pipeline_type_kind_ord_at(arena, tr);
        // TYPE_PTR=9 TYPE_ARRAY=10 TYPE_SLICE=11
        if (ko == 9 || ko == 10 || ko == 11) { return 8; }
      }
    }
    if (pty > 0) {
      ko = pipeline_type_kind_ord_at(arena, pty);
      if (ko == 9 || ko == 10 || ko == 11) { return 8; }
    }
  }
  if (sz <= 0) { return 8; }
  // w1545 (10.72): Win64 9–16B named struct goes by reference like > 16B.
  // 24 is the by-reference class size (drives the w1521 > 16 machinery:
  // caller copy, pointer in one GP/stack word); the copy itself uses the
  // real layout size (w1521_win_mem_arg_addr_to_rax_c). PLATFORM: WINDOWS.
  if (sz <= 16) {
    if (w1545_arg_mid_sz(arena, pty, arg_ref) > 0) { return 24; }
  }
  return sz;

  }
}
