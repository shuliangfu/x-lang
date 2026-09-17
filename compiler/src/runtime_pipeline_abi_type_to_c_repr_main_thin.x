// Thin pure: ttc REST pipeline_codegen_type_to_c_repr dispatcher only.
// G.7: body MUST match type_to_c_repr_thin / mega (ARRAY/SLICE/NAMED delegated).
// wave428: Darwin -c ~10124B; LINUX HARD BAN (Ubuntu asm empty .o RC=0).
// wave434: LINUX PREFER — NAMED/ARRAY/SLICE via peer thins (co-file XT001/empty).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_arena_num_types(arena: *u8): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_array_size_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_codegen_type_kind_copy(dst: *u8, cap: i32, kind: i32): i32;
export extern function pipeline_codegen_vector_type_copy(dst: *u8, cap: i32, elem_kind: i32, lanes: i32): i32;
export extern function cg_ttc_write_bytes(dst: *u8, cap: i32, src: *u8, n: i32): i32;
export extern function cg_ttc_write_named_tag(arena: *u8, scratch: *u8, cap: i32, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32;
export extern function cg_ttc_write_array_tag(arena: *u8, scratch: *u8, cap: i32, elem_ref: i32, arr_sz: i32, struct_prefix: *u8, struct_prefix_len: i32): i32;
export extern function cg_ttc_write_slice_tag(arena: *u8, scratch: *u8, cap: i32, elem_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32;

/**
 * Recursive type_to_c_repr: write C type name for type_ref into scratch (no NUL).
 * @param arena *u8 - ASTArena* (opaque)
 * @param scratch *u8 - destination
 * @param cap i32 - capacity; <16 rejects
 * @param type_ref i32 - type pool index
 * @param struct_prefix *u8 - optional NAMED struct prefix; null ok
 * @param struct_prefix_len i32 - prefix length
 * @return i32 - byte count, or -1 on overflow
 * wave434: ARRAY/SLICE/NAMED delegated to peer thins.
 * PLATFORM: SHARED host-C type_to_c_repr authority.
 */
export function pipeline_codegen_type_to_c_repr(arena: *u8, scratch: *u8, cap: i32, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32 {
  unsafe {
    let inner: u8[896] = [];
    let nt: i32 = 0;
    let tk: i32 = 0;
    let elem_ref: i32 = 0;
    let arr_sz: i32 = 0;
    let n: i32 = 0;
    let elem_kind: i32 = 0;
    if (cap < 16) {
      return -1;
    }
    if (scratch == 0 as *u8) {
      return -1;
    }
    if (arena != 0 as *u8) {
      unsafe {
        nt = pipeline_arena_num_types(arena);
      }
    }
    if (arena == 0 as *u8 || type_ref <= 0 || type_ref > nt) {
      return cg_ttc_write_bytes(scratch, cap, "int32_t", 7);
    }
    unsafe {
      tk = pipeline_type_kind_ord_at(arena, type_ref);
      elem_ref = pipeline_type_elem_ref_at(arena, type_ref);
      arr_sz = pipeline_type_array_size_at(arena, type_ref);
    }
    if (tk == 9 && elem_ref > 0) {
      n = pipeline_codegen_type_to_c_repr(arena, &inner[0], 896, elem_ref, struct_prefix, struct_prefix_len);
      if (n < 0 || n + 2 >= cap) {
        return -1;
      }
      if (cg_ttc_write_bytes(scratch, cap, &inner[0], n) < 0) {
        return -1;
      }
      unsafe {
        scratch[n] = 32;
        scratch[n + 1] = 42;
      }
      return n + 2;
    }
    if (tk == 10 && elem_ref > 0) {
      return cg_ttc_write_array_tag(arena, scratch, cap, elem_ref, arr_sz, struct_prefix, struct_prefix_len);
    }
    if (tk == 13 && elem_ref > 0) {
      unsafe {
        elem_kind = pipeline_type_kind_ord_at(arena, elem_ref);
      }
      n = pipeline_codegen_vector_type_copy(scratch, cap, elem_kind, arr_sz);
      if (n >= 0) {
        return n;
      }
      return pipeline_codegen_type_kind_copy(scratch, cap, 0);
    }
    if (tk == 12 && elem_ref > 0) {
      return pipeline_codegen_type_to_c_repr(arena, scratch, cap, elem_ref, struct_prefix, struct_prefix_len);
    }
    if (tk == 17) {
      return cg_ttc_write_bytes(scratch, cap, "struct xlang_dyn_obj", 20);
    }
    if (tk == 18) {
      return cg_ttc_write_bytes(scratch, cap, "uint8_t *", 9);
    }
    if (tk == 11 && elem_ref > 0) {
      return cg_ttc_write_slice_tag(arena, scratch, cap, elem_ref, struct_prefix, struct_prefix_len);
    }
    if (tk == 8) {
      n = cg_ttc_write_named_tag(arena, scratch, cap, type_ref, struct_prefix, struct_prefix_len);
      if (n >= 0) {
        return n;
      }
    }
    n = pipeline_codegen_type_kind_copy(scratch, cap, tk);
    if (n > 0) {
      return n;
    }
    return pipeline_codegen_type_kind_copy(scratch, cap, 0);
  }
}
