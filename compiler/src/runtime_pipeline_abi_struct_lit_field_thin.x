// Thin pure override: STRUCT_LIT field i -> layout field by NAME.
// w1510 (终局待办 10.29): pabi's pipeline_expr_struct_lit_field_offset_at /
// _field_type_ref_at used the literal's field index as the layout field
// index. Typeck matches literal fields by name, so `S { a: 7, t: "x", b: 9 }`
// against `struct S { t: *u8, a: i32, b: i32 }` passed typeck and then stored
// every value at the wrong offset with the wrong type: local and module
// structs read back garbage, module *u8 fields SEGV, and module struct arrays
// with a *u8 field failed with CG002 (all three targets). The field order in
// the literal does not matter in the language, so the accessors now look the
// literal field's name up in the layout (fast path: same index, same name).
// glue_struct_lit_field_store_sz is overridden with it: its bool/u8 pad rule
// read "the next field" as literal field fi+1; it now takes the nearest
// higher layout offset, which is the same thing for in-order literals.
// src/runtime_pipeline_abi.x and its seeds may not be rebuilt (mega ban), so
// this file redefines the three exported symbols; merge back under 10.26.
// g05_relink_env.sh compiles this with the current product (pure asm, no
// host cc) and links it ahead of pabi: Darwin pabi copies are weak, Linux is
// first-wins, Windows weakens pabi_weak and jmp-patches leftovers.
// PLATFORM: SHARED.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_struct_lit_type_name_len(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_struct_lit_type_name_into(a: *u8, expr_ref: i32, out64: *u8): void;
export extern function pipeline_expr_struct_lit_num_fields(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_struct_lit_field_name_len(a: *u8, expr_ref: i32, j: i32): i32;
export extern function pipeline_expr_struct_lit_field_name_into(a: *u8, expr_ref: i32, j: i32, out64: *u8): void;
export extern function pipeline_expr_struct_lit_value_bytes(a: *u8, m: *u8, expr_ref: i32): i32;
export extern function pipeline_module_num_struct_layouts_at(m: *u8): i32;
export extern function pipeline_module_struct_layout_name_len(m: *u8, k: i32): i32;
export extern function pipeline_module_struct_layout_name_byte_at(m: *u8, k: i32, j: i32): i32;
export extern function pipeline_module_struct_layout_num_fields(m: *u8, idx: i32): i32;
export extern function pipeline_module_struct_layout_field_name_len(m: *u8, li: i32, j: i32): i32;
export extern function pipeline_module_struct_layout_field_name_into(m: *u8, li: i32, j: i32, out64: *u8): void;
export extern function pipeline_module_struct_layout_field_type_ref(m: *u8, li: i32, j: i32): i32;
export extern function glue_struct_layout_index_by_type_name_c(m: *u8, struct_name: *u8, nlen: i32): i32;
export extern function glue_struct_layout_compute_field_offset_c(m: *u8, a: *u8, li: i32, fj: i32): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function glue_type_is_empty_struct_c(module: *u8, arena: *u8, ty_ref: i32, depth: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function glue_sysv_dual_gp_byte_size_c(arena: *u8, ty_ref: i32): i32;
export extern function glue_type_named_layout_size_any_module_elf_c(arena: *u8, ty_ref: i32): i32;
export extern function glue_type_size_simple(m: *u8, a: *u8, ty_ref: i32, depth: i32): i32;

/**
 * Exact layout index for a struct name (no single-layout fallback).
 * @param m *u8 — Module
 * @param name *u8 — type name bytes
 * @param nlen i32 — name length (1..255)
 * @return i32 — layout index, or -1
 * PLATFORM: SHARED.
 */
function w1510_sl_find_exact(m: *u8, name: *u8, nlen: i32): i32 {
  let nl: i32 = 0;
  let k: i32 = 0;
  let ln: i32 = 0;
  let j: i32 = 0;
  let b: i32 = 0;
  let c: i32 = 0;
  let eq: i32 = 0;
  unsafe {
    nl = pipeline_module_num_struct_layouts_at(m);
  }
  while (k < nl) {
    unsafe {
      ln = pipeline_module_struct_layout_name_len(m, k);
    }
    if (ln == nlen) {
      eq = 1;
      j = 0;
      while (j < nlen && eq == 1) {
        unsafe {
          b = pipeline_module_struct_layout_name_byte_at(m, k, j);
          c = *(name + j) as i32;
        }
        // Loaded into a local first: arm64 `var != (*(p + i) as i32)`
        // clobbers the lhs register while computing the address (10.47).
        unsafe {
          if (b != c) {
            eq = 0;
          }
        }
        j = j + 1;
      }
      if (eq == 1) {
        return k;
      }
    }
    k = k + 1;
  }
  return 0 - 1;
}

/**
 * Layout index of a STRUCT_LIT. by_name=1 keeps the offset accessor's
 * rules (index_by_type_name, single-layout fallback, anonymous literal in a
 * single-layout module); by_name=0 is the type accessor's exact name match.
 * @return i32 — layout index, or -1
 * PLATFORM: SHARED.
 */
function w1510_sl_layout(a: *u8, m: *u8, er: i32, by_name: i32): i32 {
  let ko: i32 = 0;
  let nlen: i32 = 0;
  let name: u8[256] = [];
  let nl: i32 = 0;
  if (a == (0 as *u8) || m == (0 as *u8) || er <= 0) {
    return 0 - 1;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(a, er);
  }
  if (ko != 45) {
    return 0 - 1;
  }
  unsafe {
    nlen = pipeline_expr_struct_lit_type_name_len(a, er);
  }
  if (nlen <= 0 || nlen > 255) {
    if (by_name == 1) {
      unsafe {
        nl = pipeline_module_num_struct_layouts_at(m);
      }
      if (nl == 1) {
        return 0;
      }
    }
    return 0 - 1;
  }
  unsafe {
    pipeline_expr_struct_lit_type_name_into(a, er, &name[0]);
  }
  if (by_name == 1) {
    unsafe {
      return glue_struct_layout_index_by_type_name_c(m, &name[0], nlen);
    }
  }
  return w1510_sl_find_exact(m, &name[0], nlen);
}

/**
 * 1 when layout k field j is named nm[0..ln).
 * PLATFORM: SHARED.
 */
function w1510_sl_field_is(m: *u8, k: i32, j: i32, nm: *u8, ln: i32): i32 {
  let fl: i32 = 0;
  let fb: u8[256] = [];
  let i: i32 = 0;
  let x: i32 = 0;
  let y: i32 = 0;
  unsafe {
    fl = pipeline_module_struct_layout_field_name_len(m, k, j);
  }
  if (fl != ln) {
    return 0;
  }
  unsafe {
    pipeline_module_struct_layout_field_name_into(m, k, j, &fb[0]);
  }
  while (i < ln) {
    unsafe {
      x = fb[i] as i32;
      y = *(nm + i) as i32;
    }
    if (x != y) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

/**
 * Layout field index of literal field fi (by name). Falls back to fi when
 * the literal field has no name or no layout field matches.
 * @return i32 — layout field index
 * PLATFORM: SHARED.
 */
function w1510_sl_map(a: *u8, m: *u8, er: i32, k: i32, fi: i32): i32 {
  let nf: i32 = 0;
  let ln: i32 = 0;
  let lb: u8[256] = [];
  let j: i32 = 0;
  unsafe {
    nf = pipeline_module_struct_layout_num_fields(m, k);
    ln = pipeline_expr_struct_lit_field_name_len(a, er, fi);
  }
  if (ln <= 0 || ln > 255) {
    return fi;
  }
  unsafe {
    pipeline_expr_struct_lit_field_name_into(a, er, fi, &lb[0]);
  }
  if (fi < nf && w1510_sl_field_is(m, k, fi, &lb[0], ln) == 1) {
    return fi;
  }
  while (j < nf) {
    if (w1510_sl_field_is(m, k, j, &lb[0], ln) == 1) {
      return j;
    }
    j = j + 1;
  }
  return fi;
}

/**
 * Byte offset of STRUCT_LIT field field_ix (layout field with its name).
 * @return i32 — offset; field_ix*8 when no layout (unchanged fallback)
 * PLATFORM: SHARED.
 */
export function pipeline_expr_struct_lit_field_offset_at(a: *u8, m: *u8, expr_ref: i32, field_ix: i32): i32 {
  let k: i32 = 0;
  let nf: i32 = 0;
  let j: i32 = 0;
  if (a == (0 as *u8) || m == (0 as *u8) || expr_ref <= 0 || field_ix < 0) {
    return field_ix * 8;
  }
  k = w1510_sl_layout(a, m, expr_ref, 1);
  if (k < 0) {
    return field_ix * 8;
  }
  unsafe {
    nf = pipeline_module_struct_layout_num_fields(m, k);
  }
  j = w1510_sl_map(a, m, expr_ref, k, field_ix);
  if (j < nf) {
    unsafe {
      return glue_struct_layout_compute_field_offset_c(m, a, k, j);
    }
  }
  return field_ix * 8;
}

/**
 * Type ref of STRUCT_LIT field field_ix (layout field with its name).
 * @return i32 — type ref; 0 on miss
 * PLATFORM: SHARED.
 */
export function pipeline_expr_struct_lit_field_type_ref_at(a: *u8, m: *u8, expr_ref: i32, field_ix: i32): i32 {
  let k: i32 = 0;
  let nf: i32 = 0;
  let j: i32 = 0;
  if (a == (0 as *u8) || m == (0 as *u8) || expr_ref <= 0 || field_ix < 0) {
    return 0;
  }
  k = w1510_sl_layout(a, m, expr_ref, 0);
  if (k < 0) {
    return 0;
  }
  unsafe {
    nf = pipeline_module_struct_layout_num_fields(m, k);
  }
  j = w1510_sl_map(a, m, expr_ref, k, field_ix);
  if (j < nf) {
    unsafe {
      return pipeline_module_struct_layout_field_type_ref(m, k, j);
    }
  }
  return 0;
}

/**
 * Nearest layout offset above foff (the field after this one in memory), or
 * the struct size when foff is the last field.
 * PLATFORM: SHARED.
 */
function w1510_sl_next_off(a: *u8, m: *u8, er: i32, fi: i32, foff: i32): i32 {
  let k: i32 = 0;
  let nf: i32 = 0;
  let j: i32 = 0;
  let o: i32 = 0;
  let best: i32 = 0 - 1;
  let lnf: i32 = 0;
  let fn1: i32 = fi + 1;
  k = w1510_sl_layout(a, m, er, 1);
  if (k < 0) {
    unsafe {
      lnf = pipeline_expr_struct_lit_num_fields(a, er);
    }
    if (fn1 < lnf) {
      return pipeline_expr_struct_lit_field_offset_at(a, m, er, fn1);
    }
    unsafe {
      return pipeline_expr_struct_lit_value_bytes(a, m, er);
    }
  }
  unsafe {
    nf = pipeline_module_struct_layout_num_fields(m, k);
  }
  while (j < nf) {
    unsafe {
      o = glue_struct_layout_compute_field_offset_c(m, a, k, j);
    }
    if (o > foff) {
      if (best < 0 || o < best) {
        best = o;
      }
    }
    j = j + 1;
  }
  if (best < 0) {
    unsafe {
      best = pipeline_expr_struct_lit_value_bytes(a, m, er);
    }
  }
  return best;
}

/**
 * Per-field store width for STRUCT_LIT (ZST=0, dual-GP 9-16, scalar 1/4/8).
 * bool/u8: store 4 when the pad up to the next field in memory (or the
 * struct end) is at least 4 bytes, so inlined Option tags read as a word see
 * zero pad; packed neighbours (gap < 4) stay 1 byte. Same body as pabi's,
 * except the next field comes from the layout instead of literal order.
 * @return i32 — store width in bytes
 * PLATFORM: SHARED.
 */
export function glue_struct_lit_field_store_sz(arena: *u8, expr_ref: i32, fi: i32): i32 {
  let ty: i32 = 0;
  let kind_ord: i32 = 0;
  let nsz: i32 = 0;
  let foff: i32 = 0;
  let next_off: i32 = 0;
  let lim: i32 = 0;
  let mod: *u8 = 0 as *u8;
  unsafe {
    mod = pipeline_asm_emit_module_ref_c();
  }
  ty = pipeline_expr_struct_lit_field_type_ref_at(arena, mod, expr_ref, fi);
  if (ty <= 0) {
    return 8;
  }
  if (mod != (0 as *u8)) {
    unsafe {
      if (glue_type_is_empty_struct_c(mod, arena, ty, 0) != 0) {
        return 0;
      }
    }
  }
  unsafe {
    kind_ord = pipeline_type_kind_ord_at(arena, ty);
  }
  if (kind_ord == 2 || kind_ord == 1) {
    if (mod != (0 as *u8)) {
      foff = pipeline_expr_struct_lit_field_offset_at(arena, mod, expr_ref, fi);
      next_off = w1510_sl_next_off(arena, mod, expr_ref, fi, foff);
      lim = foff + 4;
      if (foff >= 0 && next_off >= lim) {
        return 4;
      }
    }
    return 1;
  }
  if (kind_ord == 0 || kind_ord == 3 || kind_ord == 13 || kind_ord == 14) {
    return 4;
  }
  unsafe {
    nsz = glue_sysv_dual_gp_byte_size_c(arena, ty);
  }
  if (nsz > 8 && nsz <= 16) {
    return nsz;
  }
  unsafe {
    nsz = glue_type_named_layout_size_any_module_elf_c(arena, ty);
  }
  if (nsz > 8 && nsz <= 16) {
    return nsz;
  }
  unsafe {
    nsz = glue_type_size_simple(mod, arena, ty, 0);
  }
  if (nsz == 0) {
    return 0;
  }
  if (nsz > 0 && nsz <= 16) {
    return nsz;
  }
  return 8;
}
