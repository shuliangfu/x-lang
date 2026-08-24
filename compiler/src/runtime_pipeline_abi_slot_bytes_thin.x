// Thin pure override: asm_local_slot_bytes NL-04 dep-max product entry.
// G.7: bodies MUST match pipe_slot_bytes_named_in_mod /
// pipe_local_slot_bytes_mod / asm_fixed_array_total_bytes_mod /
// asm_local_slot_bytes in runtime_pipeline_abi.x (same exported symbol).
// Product hybrid is thin-first WEAK mega + seed rest; without this inject,
// inject-only g05 can keep a stale WEAK slot sizer (metrics 16 vs dep 24B
// PageMmapHeap) — freestanding fs smoke exit=5. Seed-first merge was
// tried and dropped driver_diag on Ubuntu GNU ld; this strong thin
// first-wins ld -r over WEAK pure without reordering hybrid.
// ensure injects via pipeline_abi_inject_slot_bytes_thin.
// PLATFORM: SHARED freestanding slot sizing · LINUX gold · MACOS co-path.

export extern function pipeline_type_named_name_into(arena: *u8, type_ref: i32, out: *u8): i32;
export extern function pipeline_module_num_struct_layouts_at(mod: *u8): i32;
export extern function pipeline_module_struct_layout_name_len(mod: *u8, k: i32): i32;
export extern function pipeline_module_struct_layout_name_byte_at(mod: *u8, k: i32, j: i32): i32;
export extern function typeck_typeck_struct_layout_metrics(mod: *u8, arena: *u8, k: i32, a: i32, b: i32, sz: *i32, al: *i32): i32;
export extern function pipeline_module_struct_layout_num_fields(mod: *u8, k: i32): i32;
export extern function pipeline_module_struct_layout_field_offset_at(mod: *u8, k: i32, j: i32): i32;
export extern function pipeline_module_struct_layout_field_type_ref(mod: *u8, k: i32, j: i32): i32;
export extern function pipeline_arena_num_types(arena: *u8): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, ref: i32): i32;
export extern function pipeline_type_array_size_at(arena: *u8, ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, ref: i32): i32;
export extern function pipeline_asm_glue_emit_module_ref(): *u8;
export extern function typeck_soa_array_storage_size_glue(module: *u8, arena: *u8, elem_type_ref: i32, array_len: i32, depth: i32): i32;
export extern function typeck_x_type_size_from_layout_glue(module: *u8, arena: *u8, li: i32, depth: i32): i32;
export extern function pipeline_asm_emit_dep_pipe_c(): *u8;
export extern function pipeline_dep_ctx_ndep(ctx: *u8): i32;
export extern function pipeline_dep_ctx_module_at(ctx: *u8, idx: i32): *u8;
export extern function pipeline_dep_ctx_arena_at(ctx: *u8, idx: i32): *u8;
export extern function glue_fixed_array_total_bytes_c(arena: *u8, type_ref: i32, depth: i32): i32;
export extern function glue_type_size_simple(mod: *u8, arena: *u8, type_ref: i32, depth: i32): i32;
export extern function asm_type_is_simd_vector_spelling(arena: *u8, type_ref: i32): i32;

/**
 * TYPE_NAMED struct layout stack slot bytes in one module.
 * Metrics OK + sz==0 => true ZST (return 0); metrics fail => invent last_off+fsz.
 * Strips trailing module prefix after last '.' before layout name match.
 *
 * NL-04 (2026-08-24): when metrics succeed, also raise sz to cover stored
 * field offsets (max_j foff_j+fsz_j). Import STRUCT_LIT can leave thin
 * field types (i32 from untyped 0) while glue_sync / dep merge stamps
 * wide AoS offsets (e.g. PageMmapHeap off@16) — metrics then return 16
 * while stores write 24B and smash the previous local (freestanding
 * fs smoke exit=5). G.7: single sizing authority must respect offsets.
 *
 * @param arena *u8 - ASTArena*
 * @param type_ref i32 - TYPE_NAMED type ref
 * @param mod *u8 - Module*; null -> 0
 * @return i32 - padded slot bytes >0; 0 miss or ZST
 * wave268 pure: G.7 authority (was static asm_slot_bytes_named_in_mod).
 * PLATFORM: SHARED freestanding nest ZST · LINUX gold.
 */
function pipe_slot_bytes_named_in_mod(arena: *u8, type_ref: i32, mod: *u8): i32 {
  let name: u8[128] = [];
  let nlen: i32 = 0;
  let k: i32 = 0;
  let nlayouts: i32 = 0;
  let ln: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let b: i32 = 0;
  let sz: i32 = 0;
  let al: i32 = 0;
  let mrc: i32 = 0;
  let sz_slot: i32[1] = [];
  let al_slot: i32[1] = [];
  let nf: i32 = 0;
  let last: i32 = 0;
  let foff: i32 = 0;
  let fty: i32 = 0;
  let fsz: i32 = 0;
  let dot: i32 = 0;
  let base_off: i32 = 0;
  let base_len: i32 = 0;
  if (arena == 0 as *u8 || type_ref <= 0 || mod == 0 as *u8) {
    return 0;
  }
  unsafe {
    nlen = pipeline_type_named_name_into(arena, type_ref, &name[0]);
  }
  if (nlen <= 0 || nlen > 127) {
    return 0;
  }
  // Strip module prefix: "heap.PageMmapHeap" -> "PageMmapHeap".
  dot = 0 - 1;
  j = 0;
  while (j < nlen) {
    if (name[j] == 46) {
      dot = j;
    }
    j = j + 1;
  }
  if (dot >= 0) {
    base_off = dot + 1;
    base_len = nlen - base_off;
    if (base_len <= 0) {
      return 0;
    }
    j = 0;
    while (j < base_len) {
      name[j] = name[base_off + j];
      j = j + 1;
    }
    nlen = base_len;
  }
  unsafe {
    nlayouts = pipeline_module_num_struct_layouts_at(mod);
  }
  k = 0;
  while (k < nlayouts) {
    unsafe {
      ln = pipeline_module_struct_layout_name_len(mod, k);
    }
    if (ln == nlen) {
      eq = 1;
      j = 0;
      while (j < nlen) {
        unsafe {
          b = pipeline_module_struct_layout_name_byte_at(mod, k, j);
        }
        if (b != (name[j] as i32)) {
          eq = 0;
          j = nlen;
        } else {
          j = j + 1;
        }
      }
      if (eq != 0) {
        sz_slot[0] = 0;
        al_slot[0] = 1;
        unsafe {
          mrc = typeck_typeck_struct_layout_metrics(mod, arena, k, 0, 0, &sz_slot[0], &al_slot[0]);
        }
        sz = sz_slot[0];
        // TRACE soft-dropped.
        unsafe {
          nf = pipeline_module_struct_layout_num_fields(mod, k);
        }
        if (mrc == 0) {
          if (sz <= 0) {
            return 0;
          }
          // Raise to stored-offset extent (NL-04 import lit thin types).
          if (nf > 0) {
            j = 0;
            while (j < nf) {
              unsafe {
                foff = pipeline_module_struct_layout_field_offset_at(mod, k, j);
                fty = pipeline_module_struct_layout_field_type_ref(mod, k, j);
              }
              fsz = pipe_local_slot_bytes_mod(arena, fty, mod);
              if (fsz <= 0) {
                fsz = 8;
              }
              if ((foff + fsz) > sz) {
                sz = foff + fsz;
              }
              j = j + 1;
            }
          }
          if (sz % 8 != 0) {
            sz = sz + (8 - (sz % 8));
          }
          return sz;
        }
        // Metrics failed: invent last_off + field slot bytes.
        if (nf > 0) {
          last = nf - 1;
          unsafe {
            foff = pipeline_module_struct_layout_field_offset_at(mod, k, last);
            fty = pipeline_module_struct_layout_field_type_ref(mod, k, last);
          }
          fsz = pipe_local_slot_bytes_mod(arena, fty, mod);
          if (fsz <= 0) {
            fsz = 4;
          }
          sz = foff + fsz;
        } else {
          return 0;
        }
        if (sz > 0) {
          if (sz % 8 != 0) {
            sz = sz + (8 - (sz % 8));
          }
          return sz;
        }
      }
    }
    k = k + 1;
  }
  return 0;
}


/**
 * T[N] fixed array total bytes: SoA storage or AoS N*layout (struct elem only).
 * @param arena *u8 - ASTArena*
 * @param type_ref i32 - TYPE_ARRAY type ref
 * @param mod *u8 - Module*; null falls back to emit module
 * @return i32 - total bytes; 0 miss (caller uses esz heuristic)
 * wave268 pure: G.7 single product authority (was static asm_fixed_array_total_bytes_mod).
 * Cap residual host-cc: pipeline_asm_block_tree.c asm_fixed_array_temp_bytes consumer.
 * PLATFORM: SHARED freestanding array layout.
 */
#[no_mangle]
export function asm_fixed_array_total_bytes_mod(arena: *u8, type_ref: i32, mod: *u8): i32 {
  let nt: i32 = 0;
  let asz: i32 = 0;
  let elem_ref: i32 = 0;
  let ek: i32 = 0;
  let soa_sz: i32 = 0;
  let ename: u8[128] = [];
  let elen: i32 = 0;
  let nlayouts: i32 = 0;
  let lk: i32 = 0;
  let ln: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let b: i32 = 0;
  let es: i32 = 0;
  if (arena == 0 as *u8 || type_ref <= 0) {
    return 0;
  }
  unsafe {
    nt = pipeline_arena_num_types(arena);
  }
  if (type_ref > nt) {
    return 0;
  }
  unsafe {
    if (pipeline_type_kind_ord_at(arena, type_ref) != 10) {
      return 0;
    }
    asz = pipeline_type_array_size_at(arena, type_ref);
    elem_ref = pipeline_type_elem_ref_at(arena, type_ref);
  }
  if (asz <= 0 || elem_ref <= 0) {
    return 0;
  }
  if (mod == 0 as *u8) {
    mod = pipeline_asm_glue_emit_module_ref();
  }
  if (mod == 0 as *u8) {
    return 0;
  }
  unsafe {
    ek = pipeline_type_kind_ord_at(arena, elem_ref);
  }
  // elem must be TYPE_NAMED (8) for SoA/layout path.
  if (ek != 8) {
    return 0;
  }
  unsafe {
    soa_sz = typeck_soa_array_storage_size_glue(mod, arena, elem_ref, asz, 0);
  }
  if (soa_sz > 0) {
    return soa_sz;
  }
  unsafe {
    elen = pipeline_type_named_name_into(arena, elem_ref, &ename[0]);
  }
  if (elen <= 0 || elen > 63) {
    return 0;
  }
  unsafe {
    nlayouts = pipeline_module_num_struct_layouts_at(mod);
  }
  lk = 0;
  while (lk < nlayouts) {
    unsafe {
      ln = pipeline_module_struct_layout_name_len(mod, lk);
    }
    if (ln == elen) {
      eq = 1;
      j = 0;
      while (j < elen) {
        unsafe {
          b = pipeline_module_struct_layout_name_byte_at(mod, lk, j);
        }
        if (b != (ename[j] as i32)) {
          eq = 0;
          j = elen;
        } else {
          j = j + 1;
        }
      }
      if (eq != 0) {
        unsafe {
          es = typeck_x_type_size_from_layout_glue(mod, arena, lk, 0);
        }
        if (es > 0) {
          return asz * es;
        }
      }
    }
    lk = lk + 1;
  }
  return 0;
}


/**
 * Single const/let stack slot bytes; mod preferred else emit module + dep walk.
 * @param arena *u8 - ASTArena*
 * @param type_ref i32 - type ref; invalid -> 8
 * @param mod *u8 - Module* or null
 * @return i32 - slot bytes (>=8 for non-ZST scalars)
 * wave268 pure: G.7 authority (was static asm_local_slot_bytes_mod).
 * PLATFORM: SHARED freestanding stack · LINUX gold · MACOS co-path.
 */
function pipe_local_slot_bytes_mod(arena: *u8, type_ref: i32, mod: *u8): i32 {
  let nt: i32 = 0;
  let ko: i32 = 0;
  let sz: i32 = 0;
  let dep: *u8 = 0 as *u8;
  let nd: i32 = 0;
  let di: i32 = 0;
  let dm: *u8 = 0 as *u8;
  let elem_ref: i32 = 0;
  let arr_sz: i32 = 0;
  let asz: i32 = 0;
  let esz: i32 = 0;
  let ek: i32 = 0;
  let bytes: i32 = 0;
  let lanes: i32 = 0;
  let name: u8[128] = [];
  let nlen: i32 = 0;
  let cur: i32 = 0;
  let prod: i32 = 0;
  let d: i32 = 0;
  let leaf_esz: i32 = 0;
  let cn: i32 = 0;
  let ce: i32 = 0;
  let lek: i32 = 0;
  let ssz: i32 = 0;
  let simd: i32 = 0;
  let da: *u8 = 0 as *u8;
  let nlayouts2: i32 = 0;
  let k2: i32 = 0;
  let ln2: i32 = 0;
  let eq2: i32 = 0;
  let j2: i32 = 0;
  let b2: i32 = 0;
  let sz2: i32 = 0;
  let dot2: i32 = 0;
  let bo: i32 = 0;
  let bl: i32 = 0;
  let ji: i32 = 0;
  if (arena == 0 as *u8 || type_ref <= 0) {
    return 8;
  }
  unsafe {
    nt = pipeline_arena_num_types(arena);
  }
  if (type_ref > nt) {
    return 8;
  }
  unsafe {
    ko = pipeline_type_kind_ord_at(arena, type_ref);
  }
  /* F7: TYPE_DYN (17) fat {void* data; void* vtable;} is 16 bytes.
   * Default 8-byte fallback stored only the data word and left .vtable
   * unallocated — dispatch ldr [x0,#8] then SIGSEGV. PLATFORM: SHARED. */
  if (ko == 17) {
    return 16;
  }
  // TYPE_NAMED = 8: layout metrics + dep walk.
  // NL-04: never return the first emit-module hit alone. Import STRUCT_LIT
  // can register a thin-typed PageMmapHeap (metrics 16) while the defining
  // dep keeps the authoritative 24B layout that FIELD_ACCESS / lit stores
  // already use — take max(emit, dep) so the stack slot covers the stores.
  // PLATFORM: SHARED freestanding · LINUX gold.
  if (ko == 8) {
    if (mod == 0 as *u8) {
      mod = pipeline_asm_glue_emit_module_ref();
    }
    sz = pipe_slot_bytes_named_in_mod(arena, type_ref, mod);
    dep = pipeline_asm_emit_dep_pipe_c();
    if (dep != 0 as *u8) {
      unsafe {
        nd = pipeline_dep_ctx_ndep(dep);
        nlen = pipeline_type_named_name_into(arena, type_ref, &name[0]);
      }
      // Strip one module prefix so "heap.PageMmapHeap" matches dep "PageMmapHeap".
      if (nlen > 0 && nlen <= 127) {
        dot2 = 0 - 1;
        ji = 0;
        while (ji < nlen) {
          if (name[ji] == 46) {
            dot2 = ji;
          }
          ji = ji + 1;
        }
        if (dot2 >= 0) {
          bo = dot2 + 1;
          bl = nlen - bo;
          if (bl > 0) {
            ji = 0;
            while (ji < bl) {
              name[ji] = name[bo + ji];
              ji = ji + 1;
            }
            nlen = bl;
          }
        }
      }
      di = 0;
      while (di < nd) {
        unsafe {
          dm = pipeline_dep_ctx_module_at(dep, di);
          da = pipeline_dep_ctx_arena_at(dep, di);
        }
        if (dm != 0 as *u8 && da != 0 as *u8 && dm != mod && nlen > 0) {
          unsafe {
            nlayouts2 = pipeline_module_num_struct_layouts_at(dm);
          }
          k2 = 0;
          while (k2 < nlayouts2) {
            unsafe {
              ln2 = pipeline_module_struct_layout_name_len(dm, k2);
            }
            if (ln2 == nlen) {
              eq2 = 1;
              j2 = 0;
              while (j2 < nlen) {
                unsafe {
                  b2 = pipeline_module_struct_layout_name_byte_at(dm, k2, j2);
                }
                if (b2 != (name[j2] as i32)) {
                  eq2 = 0;
                  j2 = nlen;
                } else {
                  j2 = j2 + 1;
                }
              }
              if (eq2 != 0) {
                unsafe {
                  sz2 = typeck_x_type_size_from_layout_glue(dm, da, k2, 0);
                }
                if (sz2 > sz) {
                  sz = sz2;
                }
              }
            }
            k2 = k2 + 1;
          }
        }
        di = di + 1;
      }
    }
    if (sz > 0) {
      if (sz % 8 != 0) {
        sz = sz + (8 - (sz % 8));
      }
      return sz;
    }
  }
  // TYPE_ARRAY = 10 fixed T[N].
  if (ko == 10) {
    unsafe {
      asz = pipeline_type_array_size_at(arena, type_ref);
      elem_ref = pipeline_type_elem_ref_at(arena, type_ref);
    }
    if (asz > 0) {
      arr_sz = asm_fixed_array_total_bytes_mod(arena, type_ref, mod);
      if (arr_sz > 0) {
        if (arr_sz % 8 != 0) {
          arr_sz = arr_sz + (8 - (arr_sz % 8));
        }
        return arr_sz;
      }
      /* SoA/layout miss: SIMD named `[N]i32x4` has no struct layout, so
       * asm_fixed_array_total_bytes_mod returns 0. The scalar heuristic
       * below then treats TYPE_NAMED as 8B. `[2]i32x4` became 16B and
       * `[1]i32x4` became 8B; dest `arr[0]=a` wrote 16B, then
       * `let one:[1]i32x4=[a]` wrote 16B from a high-end 8B home and
       * planted a[2]=3 at arr[0][0] (Ubuntu n2lit=3).
       * G.7: reuse glue_fixed_array_total_bytes_c (TYPE_NAMED →
       * glue_type_size_simple lanes*esz). Do not add an i32x4 name table.
       * PLATFORM: SHARED — LINUX|x86 high-end is the live overlap;
       * MACOS|ARM64 low-end was false-green. */
      arr_sz = glue_fixed_array_total_bytes_c(arena, type_ref, 0);
      if (arr_sz > 0) {
        if (arr_sz % 8 != 0) {
          arr_sz = arr_sz + (8 - (arr_sz % 8));
        }
        return arr_sz;
      }
      // Multi-dim T[N][M]: product of dims * leaf esz; pad outer only.
      if (elem_ref > 0 && elem_ref <= nt) {
        unsafe {
          ek = pipeline_type_kind_ord_at(arena, elem_ref);
        }
        if (ek == 10) {
          cur = type_ref;
          prod = 1;
          leaf_esz = 4;
          d = 0;
          while (d < 8) {
            unsafe {
              if (pipeline_type_kind_ord_at(arena, cur) != 10) {
                d = 8;
              } else {
                cn = pipeline_type_array_size_at(arena, cur);
                ce = pipeline_type_elem_ref_at(arena, cur);
              }
            }
            if (d >= 8) {
              // broken by inner break set
            } else {
              if (cn <= 0 || ce <= 0) {
                d = 8;
              } else {
                prod = prod * cn;
                unsafe {
                  lek = pipeline_type_kind_ord_at(arena, ce);
                }
                if (lek != 10) {
                  if (lek == 2 || lek == 1) {
                    leaf_esz = 1;
                  } else {
                    if (lek == 11) {
                      // TYPE_SLICE fat leaf: [N][]T is n*16, not n*4.
                      // PLATFORM: SHARED freestanding.
                      leaf_esz = 16;
                    } else {
                    if (lek == 15 || lek == 4 || lek == 5 || lek == 6 || lek == 7 || lek == 9) {
                      leaf_esz = 8;
                    } else {
                      if (lek == 8) {
                        ssz = pipe_slot_bytes_named_in_mod(arena, ce, mod);
                        if (ssz <= 0) {
                          /* Same SIMD-named miss as 1D: layout 0 → size_simple. */
                          if (mod == (0 as *u8)) {
                            mod = pipeline_asm_glue_emit_module_ref();
                          }
                          ssz = glue_type_size_simple(mod, arena, ce, 0);
                        }
                        if (ssz > 0) {
                          leaf_esz = ssz;
                        } else {
                          leaf_esz = 8;
                        }
                      } else {
                        leaf_esz = 4;
                      }
                    }
                    }
                  }
                  bytes = prod * leaf_esz;
                  if (bytes < 8) {
                    bytes = 8;
                  }
                  if (bytes % 8 != 0) {
                    bytes = bytes + (8 - (bytes % 8));
                  }
                  return bytes;
                }
                cur = ce;
                d = d + 1;
              }
            }
          }
        }
      }
      // Scalar/elem esz heuristic (PTR=8 wave637).
      esz = 4;
      if (elem_ref > 0 && elem_ref <= nt) {
        unsafe {
          ek = pipeline_type_kind_ord_at(arena, elem_ref);
        }
        if (ek == 2 || ek == 1) {
          esz = 1;
        } else {
          if (ek == 11) {
            // TYPE_SLICE fat element.
            // PLATFORM: SHARED freestanding.
            esz = 16;
          } else {
          if (ek == 14 || ek == 0 || ek == 3 || ek == 13) {
            esz = 4;
          } else {
            if (ek == 8) {
              /* TYPE_NAMED leftover after total_bytes miss: size_simple
               * (SIMD 16), not pointer-sized 8. */
              if (mod == (0 as *u8)) {
                mod = pipeline_asm_glue_emit_module_ref();
              }
              ssz = glue_type_size_simple(mod, arena, elem_ref, 0);
              if (ssz > 0) {
                esz = ssz;
              } else {
                esz = 8;
              }
            } else {
              if (ek == 4 || ek == 5 || ek == 6 || ek == 7 || ek == 15 || ek == 9) {
                esz = 8;
              }
            }
          }
          }
        }
      }
      bytes = asz * esz;
      if (bytes < 8) {
        bytes = 8;
      }
      if (bytes % 8 != 0) {
        bytes = bytes + (8 - (bytes % 8));
      }
      return bytes;
    }
  }
  // TYPE_SLICE = 11 → {data,len} 16B.
  if (ko == 11) {
    return 16;
  }
  // VECTOR ord==13 or NAMED i32x4 spelling.
  unsafe {
    simd = asm_type_is_simd_vector_spelling(arena, type_ref);
  }
  if (simd == 0 && ko != 13) {
    return 8;
  }
  if (ko != 13) {
    // NAMED spelling: lanes from name x4/x8/x16 or Vec8i.
    lanes = 4;
    unsafe {
      nlen = pipeline_type_named_name_into(arena, type_ref, &name[0]);
    }
    if (nlen == 5 && name[4] == 56) {
      lanes = 8;
    }
    if (nlen == 6 && name[4] == 49 && name[5] == 54) {
      lanes = 16;
    }
    // "Vec8i"
    if (nlen == 5 && name[0] == 86 && name[1] == 101 && name[2] == 99 && name[3] == 56 && name[4] == 105) {
      lanes = 8;
    }
    esz = 4;
    bytes = lanes * esz;
    if (bytes < 8) {
      bytes = 8;
    }
    if (bytes % 8 != 0) {
      bytes = bytes + (8 - (bytes % 8));
    }
    return bytes;
  }
  // TYPE_VECTOR = 13.
  unsafe {
    asz = pipeline_type_array_size_at(arena, type_ref);
    elem_ref = pipeline_type_elem_ref_at(arena, type_ref);
  }
  if (asz > 0) {
    lanes = asz;
  } else {
    lanes = 4;
  }
  esz = 4;
  if (elem_ref > 0 && elem_ref <= nt) {
    unsafe {
      ek = pipeline_type_kind_ord_at(arena, elem_ref);
    }
    if (ek == 2) {
      esz = 1;
    } else {
      if (ek == 14) {
        esz = 4;
      } else {
        if (ek == 8 || ek == 4 || ek == 5 || ek == 6) {
          esz = 8;
        }
      }
    }
  }
  bytes = lanes * esz;
  if (bytes < 8) {
    bytes = 8;
  }
  if (bytes % 8 != 0) {
    bytes = bytes + (8 - (bytes % 8));
  }
  return bytes;
}


/**
 * Public stack slot bytes for const/let (no ctx; emit module + dep walk).
 * @param arena *u8 - ASTArena*
 * @param type_ref i32 - type ref
 * @return i32 - slot bytes
 * wave268 pure: G.7 single product authority (was pipeline_asm_slot_bytes.c).
 * PLATFORM: SHARED freestanding stack layout · LINUX gold · MACOS co-path.
 */
#[no_mangle]
export function asm_local_slot_bytes(arena: *u8, type_ref: i32): i32 {
  return pipe_local_slot_bytes_mod(arena, type_ref, 0 as *u8);
}

