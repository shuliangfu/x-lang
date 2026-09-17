// Thin pure: ttc REST pipeline_codegen_type_to_c_repr only.
// G.7: body MUST match type_to_c_repr_thin / mega.
// wave428: Darwin -c ~10124B; LINUX HARD BAN (Ubuntu asm empty .o RC=0).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_arena_num_types(arena: *u8): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_array_size_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_named_name_into(arena: *u8, ref: i32, out64: *u8): i32;
export extern function pipeline_codegen_type_kind_copy(dst: *u8, cap: i32, kind: i32): i32;
export extern function pipeline_codegen_vector_type_copy(dst: *u8, cap: i32, elem_kind: i32, lanes: i32): i32;
export extern function pipeline_codegen_type_kind_append(scratch: *u8, cap: i32, w: i32, kind: i32): i32;
export extern function cg_ttc_write_bytes(dst: *u8, cap: i32, src: *u8, n: i32): i32;
export extern function cg_ttc_write_uint_at(dst: *u8, cap: i32, off: i32, v: i32): i32;

/**
 * Recursive type_to_c_repr: write C type name for type_ref into scratch (no NUL).
 * @param arena *u8 - ASTArena* (opaque)
 * @param scratch *u8 - destination
 * @param cap i32 - capacity; <16 rejects
 * @param type_ref i32 - type pool index
 * @param struct_prefix *u8 - optional NAMED struct prefix (e.g. dep module); null ok
 * @param struct_prefix_len i32 - prefix length; 0 => bare NAMED (entry module)
 * @return i32 - byte count, or -1 on overflow
 * wave109 pure: G.7 single product authority (was type_to_c_repr_inner + entry).
 * Uses stack inner/eb for recursive SLICE/PTR (wave691; no static re-entry).
 * TYPE_ARRAY writes `xlang_arr<N>_<elem>` so `[][N]T` is not `xlang_slice_<T>`.
 * Scratch family is 896: nest 52 i32 tag is 638; nest 53 is 650 (overflows
 * 640); nest 63 is 770 (overflows 768); nest 64 is 782 (12*64+14). Product
 * freeze at 64. Do not raise nest past 64 this leaf.
 * PLATFORM: SHARED host-C type_to_c_repr authority.
 */
export function pipeline_codegen_type_to_c_repr(arena: *u8, scratch: *u8, cap: i32, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32 {
  unsafe {
    let inner: u8[896] = [];
    let eb: u8[896] = [];
    let nm: u8[256] = [];
    if (cap < 16) {
      return -1;
    }
    if (scratch == 0 as *u8) {
      return -1;
    }
    // Fallback int32_t when arena/type_ref invalid (matches host residual).
    let nt: i32 = 0;
    if (arena != 0 as *u8) {
      unsafe {
        nt = pipeline_arena_num_types(arena);
      }
    }
    if (arena == 0 as *u8 || type_ref <= 0 || type_ref > nt) {
      return cg_ttc_write_bytes(scratch, cap, "int32_t", 7);
    }
    let tk: i32 = 0;
    let elem_ref: i32 = 0;
    let arr_sz: i32 = 0;
    unsafe {
      tk = pipeline_type_kind_ord_at(arena, type_ref);
      elem_ref = pipeline_type_elem_ref_at(arena, type_ref);
      arr_sz = pipeline_type_array_size_at(arena, type_ref);
    }
    // TYPE_PTR (9): elem " *"
    if (tk == 9 && elem_ref > 0) {
      let n: i32 = pipeline_codegen_type_to_c_repr(arena, &inner[0], 896, elem_ref, struct_prefix, struct_prefix_len);
      if (n < 0 || n + 2 >= cap) {
        return -1;
      }
      let j: i32 = 0;
      while (j < n) {
        unsafe {
          scratch[j] = inner[j];
        }
        j = j + 1;
      }
      unsafe {
        scratch[n] = 32;
        scratch[n + 1] = 42;
      }
      return n + 2;
    }
    // TYPE_ARRAY (10): sanitizable tag `xlang_arr<N>_<elemC>` (no `[]` / `*` in names).
    // Prior: decayed to the leaf so `[][2]i32` became `struct xlang_slice_int32_t`
    // and host-C INDEX `(x).data[0][1]` was `i32[1]` (BLD001). Slice-of-array
    // layouts use this tag; `data` is `E (*)[N]` so INDEX needs no consume patch.
    // arr_sz<=0 keeps the old decay (unsized / invalid).
    // PLATFORM: SHARED host-C type_to_c_repr. G.7 complete same authority.
    if (tk == 10 && elem_ref > 0) {
      if (arr_sz <= 0) {
        return pipeline_codegen_type_to_c_repr(arena, scratch, cap, elem_ref, struct_prefix, struct_prefix_len);
      }
      let n_el: i32 = pipeline_codegen_type_to_c_repr(arena, &eb[0], 896, elem_ref, struct_prefix, struct_prefix_len);
      if (n_el < 0 || n_el >= 896) {
        return -1;
      }
      let sp_el: i32 = 0;
      if (n_el >= 7) {
        let is_st: i32 = 0;
        unsafe {
          if (eb[0] == 115 && eb[1] == 116 && eb[2] == 114 && eb[3] == 117 && eb[4] == 99 && eb[5] == 116 && eb[6] == 32) {
            is_st = 1;
          }
        }
        if (is_st != 0) {
          sp_el = 7;
          while (sp_el < n_el) {
            let chs: u8 = 0;
            unsafe {
              chs = eb[sp_el];
            }
            if (chs != 32) {
              break;
            }
            sp_el = sp_el + 1;
          }
        }
      }
      // "xlang_arr" = 9 bytes
      if (9 >= cap) {
        return -1;
      }
      let hdr_ar: u8[9] = [120, 108, 97, 110, 103, 95, 97, 114, 114];
      let w_ar: i32 = 0;
      while (w_ar < 9) {
        unsafe {
          scratch[w_ar] = hdr_ar[w_ar];
        }
        w_ar = w_ar + 1;
      }
      w_ar = cg_ttc_write_uint_at(scratch, cap, w_ar, arr_sz);
      if (w_ar < 0 || w_ar + 1 >= cap) {
        return -1;
      }
      unsafe {
        scratch[w_ar] = 95;
      }
      w_ar = w_ar + 1;
      // Copy elem tag: keep [A-Za-z0-9_]; map `*` → `_p`; skip spaces / brackets.
      let pi_el: i32 = sp_el;
      while (pi_el < n_el) {
        let ch: u8 = 0;
        unsafe {
          ch = eb[pi_el];
        }
        if (ch == 42) {
          if (w_ar + 2 >= cap) {
            return -1;
          }
          unsafe {
            scratch[w_ar] = 95;
            scratch[w_ar + 1] = 112;
          }
          w_ar = w_ar + 2;
        } else {
          let keep: i32 = 0;
          if (ch >= 48 && ch <= 57) {
            keep = 1;
          }
          if (ch >= 65 && ch <= 90) {
            keep = 1;
          }
          if (ch >= 97 && ch <= 122) {
            keep = 1;
          }
          if (ch == 95) {
            keep = 1;
          }
          if (keep != 0) {
            if (w_ar >= cap) {
              return -1;
            }
            unsafe {
              scratch[w_ar] = ch;
            }
            w_ar = w_ar + 1;
          }
        }
        pi_el = pi_el + 1;
      }
      if (w_ar <= 10) {
        return -1;
      }
      return w_ar;
    }
    // TYPE_VECTOR (13)
    if (tk == 13 && elem_ref > 0) {
      let elem_kind: i32 = 0;
      unsafe {
        elem_kind = pipeline_type_kind_ord_at(arena, elem_ref);
      }
      let n: i32 = pipeline_codegen_vector_type_copy(scratch, cap, elem_kind, arr_sz);
      if (n >= 0) {
        return n;
      }
      return pipeline_codegen_type_kind_copy(scratch, cap, 0);
    }
    // TYPE_LINEAR (12): decay to elem
    if (tk == 12 && elem_ref > 0) {
      return pipeline_codegen_type_to_c_repr(arena, scratch, cap, elem_ref, struct_prefix, struct_prefix_len);
    }
    // TYPE_DYN (17): fat trait object {data*, vtable*} — not incomplete struct Trait.
    // PLATFORM: SHARED host-C. G.7: same authority; empty-struct Trait paint banned.
    // 20 bytes = strlen("struct xlang_dyn_obj"); twin of emit_type_kind TYPE_DYN branch.
    if (tk == 17) {
      return cg_ttc_write_bytes(scratch, cap, "struct xlang_dyn_obj", 20);
    }
    /*
     * 10.3.1: TYPE_FN (18) — Cap opaque fn-ptr ABI on host-C (`uint8_t *`).
     * Twin of codegen emit_type_kind TYPE_FN. Full Ret(*)(args) residual.
     * PLATFORM: SHARED host-C. G.7 single type_to_c_repr authority.
     */
    if (tk == 18) {
      return cg_ttc_write_bytes(scratch, cap, "uint8_t *", 9);
    }
    // TYPE_SLICE (11): `struct xlang_slice_<elemTag>`.
    // Strip leading "struct " then sanitize like TYPE_ARRAY: keep [A-Za-z0-9_],
    // map `*` → `_p`, skip spaces / brackets. Prior raw copy made `[]*i32` →
    // `struct xlang_slice_int32_t *` (a pointer type, not a tag) so locals
    // `T * p = { .data, .length }` and params `(p)->data` failed host-C.
    // Named local / UFCS / dyn extra all sit-red on this tag. ARRAY already
    // sanitizes; complete the same authority. Layout companion for PTR elems
    // is codegen_emit_slice_of_fixed_array_layouts. PLATFORM: SHARED host-C.
    if (tk == 11 && elem_ref > 0) {
      let n: i32 = pipeline_codegen_type_to_c_repr(arena, &eb[0], 896, elem_ref, struct_prefix, struct_prefix_len);
      if (n < 0 || n >= 896) {
        return -1;
      }
      let sp: i32 = 0;
      if (n >= 7) {
        let is_struct: i32 = 0;
        unsafe {
          if (eb[0] == 115 && eb[1] == 116 && eb[2] == 114 && eb[3] == 117 && eb[4] == 99 && eb[5] == 116 && eb[6] == 32) {
            is_struct = 1;
          }
        }
        if (is_struct != 0) {
          sp = 7;
          while (sp < n) {
            let ch: u8 = 0;
            unsafe {
              ch = eb[sp];
            }
            if (ch != 32) {
              break;
            }
            sp = sp + 1;
          }
        }
      }
      let plen: i32 = n - sp;
      // Header needs 19 bytes. `*` → `_p` growth is the write-loop
      // `w_sl+2>=cap` below. leftover 19+2*plen rejected nest 64 i32
      // (tag=782 fits 896; 2*plen of nest 63 ≈ 1545). PLATFORM: SHARED.
      if (plen <= 0 || 19 >= cap) {
        return -1;
      }
      // "struct xlang_slice_" = 19 bytes
      let hi: i32 = 0;
      let hdr: u8[19] = [115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95];
      while (hi < 19) {
        unsafe {
          scratch[hi] = hdr[hi];
        }
        hi = hi + 1;
      }
      let w_sl: i32 = 19;
      let pi_sl: i32 = 0;
      while (pi_sl < plen) {
        let ch_sl: u8 = 0;
        unsafe {
          ch_sl = eb[sp + pi_sl];
        }
        if (ch_sl == 42) {
          if (w_sl + 2 >= cap) {
            return -1;
          }
          unsafe {
            scratch[w_sl] = 95;
            scratch[w_sl + 1] = 112;
          }
          w_sl = w_sl + 2;
        } else {
          let keep_sl: i32 = 0;
          if (ch_sl >= 48 && ch_sl <= 57) {
            keep_sl = 1;
          }
          if (ch_sl >= 65 && ch_sl <= 90) {
            keep_sl = 1;
          }
          if (ch_sl >= 97 && ch_sl <= 122) {
            keep_sl = 1;
          }
          if (ch_sl == 95) {
            keep_sl = 1;
          }
          if (keep_sl != 0) {
            if (w_sl >= cap) {
              return -1;
            }
            unsafe {
              scratch[w_sl] = ch_sl;
            }
            w_sl = w_sl + 1;
          }
        }
        pi_sl = pi_sl + 1;
      }
      if (w_sl <= 19) {
        return -1;
      }
      return w_sl;
    }
    // TYPE_NAMED (8) or named short ints / struct tags
    let name_len: i32 = 0;
    unsafe {
      name_len = pipeline_type_named_name_into(arena, type_ref, &nm[0]);
    }
    if (tk == 8 && name_len > 0) {
      // short ints without TypeKind (wave313 i8/i16/u16) -> stdint C names
      if (name_len == 2) {
        let a: u8 = 0;
        let b: u8 = 0;
        unsafe {
          a = nm[0];
          b = nm[1];
        }
        if (a == 105 && b == 56) {
          // i8
          return cg_ttc_write_bytes(scratch, cap, "int8_t", 6);
        }
      }
      if (name_len == 3) {
        let a: u8 = 0;
        let b: u8 = 0;
        let c: u8 = 0;
        unsafe {
          a = nm[0];
          b = nm[1];
          c = nm[2];
        }
        if (a == 105 && b == 49 && c == 54) {
          // i16
          return cg_ttc_write_bytes(scratch, cap, "int16_t", 7);
        }
        if (a == 117 && b == 49 && c == 54) {
          // u16
          return cg_ttc_write_bytes(scratch, cap, "uint16_t", 8);
        }
      }
      // "struct " + optional prefix + name
      let w: i32 = 0;
      let h: i32 = 0;
      let hdr2: u8[7] = [115, 116, 114, 117, 99, 116, 32];
      while (h < 7) {
        if (w >= cap - 1) {
          return -1;
        }
        unsafe {
          scratch[w] = hdr2[h];
        }
        w = w + 1;
        h = h + 1;
      }
      if (struct_prefix != 0 as *u8 && struct_prefix_len > 0) {
        let pi: i32 = 0;
        while (pi < struct_prefix_len) {
          if (w >= cap - 1) {
            return -1;
          }
          unsafe {
            scratch[w] = struct_prefix[pi];
          }
          w = w + 1;
          pi = pi + 1;
        }
      }
      // empty prefix -> bare name (entry module; wave624)
      let pi2: i32 = 0;
      while (pi2 < name_len && pi2 < 64) {
        if (w >= cap - 1) {
          return -1;
        }
        unsafe {
          scratch[w] = nm[pi2];
        }
        w = w + 1;
        pi2 = pi2 + 1;
      }
      return w;
    }
    let sn: i32 = pipeline_codegen_type_kind_copy(scratch, cap, tk);
    if (sn > 0) {
      return sn;
    }
    return pipeline_codegen_type_kind_copy(scratch, cap, 0);
  }
}
