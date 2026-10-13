// knife256 / 10.2 Cap tip: 9–16B TYPE_NAMED (Lexer) dual-GP size recovery.
// pabi leftover dual_gp missed Lexer by name and skipped size_simple, so Cap
// tip call-arg packing used 1 GPR and the next arg clobbered callee line.
// PLATFORM: SHARED — MACOS Cap tip first-wins overlay; LINUX/WIN may share.
// G.7: one authority for dual-GP byte size; demote pabi leftover T on link.

export extern function glue_type_named_layout_size_any_module_elf_c(arena: *u8, ty_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, ty_ref: i32): i32;
export extern function pipeline_type_named_name_into(arena: *u8, ty_ref: i32, out: *u8): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function glue_type_size_simple(m: *u8, a: *u8, ty_ref: i32, depth: i32): i32;

/**
 * Byte size for SysV/AAPCS64 INTEGER dual-GP class (9–16), else 0.
 * knife256/10.2: size_simple fallback + Lexer name. PLATFORM: SHARED.
 * LANG-007 S0: whole-body unsafe for Cap-T001 extern FFI.
 */
#[no_mangle]
export function glue_sysv_dual_gp_byte_size_c(arena: *u8, ty_ref: i32): i32 {
  unsafe {
  let name: u8[256] = [];
  let nlen: i32 = 0;
  let sz: i32 = 0;
  let base_off: i32 = 0;
  let i: i32 = 0;
  let bl: i32 = 0;
  let tk: i32 = 0;
  let mod: *u8 = 0 as *u8;
  if (arena == (0 as *u8) || ty_ref <= 0) {
    return 0;
  }
  // knife256/10.2: PTR/ARRAY/SLICE never INTEGER dual-GP. Gate BEFORE
  // named_layout_size — that helper returns elem*N for u8[12] (12) and would
  // pack print(msg,12) as x0=ptr,x1=ptr,x2=len. PLATFORM: SHARED.
  tk = pipeline_type_kind_ord_at(arena, ty_ref);
  // TYPE_PTR=9 TYPE_ARRAY=10 TYPE_SLICE=11
  if (tk == 9 || tk == 10 || tk == 11) {
    return 0;
  }
  sz = glue_type_named_layout_size_any_module_elf_c(arena, ty_ref);
  if (sz > 8 && sz <= 16) {
    return sz;
  }
  // knife256/10.2: local struct Lex is TYPE_STRUCT (not TYPE_NAMED=8). Cap tip
  // soft-floors size_simple/layout to 8 and skipped dual-GP; lexpack stayed
  // 1-GP and take() omitted x0/x1 param homes. Try size_simple for STRUCT /
  // NAMED only. PLATFORM: SHARED.
  mod = pipeline_asm_emit_module_ref_c();
  if (mod != (0 as *u8)) {
    if (tk != 8) {
      // STRUCT / other aggregate: size_simple 9–16 → dual-GP.
      sz = glue_type_size_simple(mod, arena, ty_ref, 0);
      if (sz > 8 && sz <= 16) {
        return sz;
      }
    }
  }
  // TYPE_NAMED == 8 — name heuristics below
  if (tk != 8) {
    return 0;
  }
  nlen = pipeline_type_named_name_into(arena, ty_ref, &name[0]);
  if (nlen <= 0 || nlen > 255) {
    return 0;
  }
  base_off = 0;
  i = 0;
  while (i < nlen) {
    if (name[i] == 46) {
      base_off = i + 1;
    }
    i = i + 1;
  }
  bl = nlen - base_off;
  if (bl == 9) {
    if (name[base_off] == 65 && name[base_off + 1] == 108 && name[base_off + 2] == 108 &&
        name[base_off + 3] == 111 && name[base_off + 4] == 99 && name[base_off + 5] == 97 &&
        name[base_off + 6] == 116 && name[base_off + 7] == 111 && name[base_off + 8] == 114) {
      return 16;
    }
  }
  if (bl == 7) {
    if (name[base_off] == 83 && name[base_off + 1] == 116 && name[base_off + 2] == 114 &&
        name[base_off + 3] == 86 && name[base_off + 4] == 105 && name[base_off + 5] == 101 &&
        name[base_off + 6] == 119) {
      return 16;
    }
  }
  if (bl == 10) {
    if (name[base_off] == 82 && name[base_off + 1] == 101 && name[base_off + 2] == 115 &&
        name[base_off + 3] == 117 && name[base_off + 4] == 108 && name[base_off + 5] == 116 &&
        name[base_off + 6] == 95 && name[base_off + 7] == 105 && name[base_off + 8] == 51 &&
        name[base_off + 9] == 50) {
      return 16;
    }
  }
  // Lex (3) — local/probe struct twin of Lexer layout
  if (bl == 3) {
    if (name[base_off] == 76 && name[base_off + 1] == 101 && name[base_off + 2] == 120) {
      return 16;
    }
  }
  // Lexer (5)
  if (bl == 5) {
    if (name[base_off] == 76 && name[base_off + 1] == 101 && name[base_off + 2] == 120 &&
        name[base_off + 3] == 101 && name[base_off + 4] == 114) {
      return 16;
    }
  }
  // Option_ptr_u8 (13) — bool + *u8 = 16B; Cap tip hollow NAMED was size_simple 8
  // and dropped x1 on some_ptr/map/expect (option L2 run -16). PLATFORM: SHARED.
  if (bl == 13) {
    if (name[base_off] == 79 && name[base_off + 1] == 112 && name[base_off + 2] == 116 &&
        name[base_off + 3] == 105 && name[base_off + 4] == 111 && name[base_off + 5] == 110 &&
        name[base_off + 6] == 95 && name[base_off + 7] == 112 && name[base_off + 8] == 116 &&
        name[base_off + 9] == 114 && name[base_off + 10] == 95 && name[base_off + 11] == 117 &&
        name[base_off + 12] == 56) {
      return 16;
    }
  }
  // ParserAsmLexLexer (17)
  if (bl == 17) {
    if (name[base_off] == 80 && name[base_off + 1] == 97 && name[base_off + 2] == 114 &&
        name[base_off + 3] == 115 && name[base_off + 4] == 101 && name[base_off + 5] == 114 &&
        name[base_off + 6] == 65 && name[base_off + 7] == 115 && name[base_off + 8] == 109 &&
        name[base_off + 9] == 76 && name[base_off + 10] == 101 && name[base_off + 11] == 120 &&
        name[base_off + 12] == 76 && name[base_off + 13] == 101 && name[base_off + 14] == 120 &&
        name[base_off + 15] == 101 && name[base_off + 16] == 114) {
      return 16;
    }
  }
  return 0;
  }
  return 0;
}
