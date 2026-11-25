/**
 * Thin twin of get_dep_return_type_in_caller_arena (logic matches the .c).
 * Root (s44 SI check T001 ok_i32): typool/gcc of this face always overwrote
 *   the ctx dep arena with driver_dep_arena_buf, so typeref 67 (Result_i32)
 *   was decoded against a 30-type driver arena and mapping returned 0.
 * The Windows fold vehicle is the .c; bind the typool entry-module BSS VA
 *   there. idx8 of thins with calls AVs in typool va_cap.
 * Fold the short, typool-mangled, and typeck_ stub names. Do not split pend BSS.
 * PLATFORM: SHARED — keep ctx arena when it is not the driver module.
 */
export extern function typeck_scratch64_slot(i: i32): *u8;
export extern function pipeline_dep_ctx_arena_at(ctx: *u8, i: i32): *u8;
export extern function pipeline_get_dep_arena_slot(i: i32): *u8;
export extern function typeck_driver_dep_arena_buf(i: i32): *u8;
export extern function pipeline_dep_ctx_module_at(ctx: *u8, i: i32): *u8;
export extern function typeck_driver_dep_module_buf(i: i32): *u8;
export extern function pipeline_module_num_funcs(mod: *u8): i32;
export extern function pipeline_dep_ctx_ndep(ctx: *u8): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_named_name_into(arena: *u8, type_ref: i32, out: *u8): i32;
export extern function typeck_map_import_binding_named_to_caller(entry_mod: *u8, dep_ix: i32,
  caller_arena: *u8, nm: *u8, nlen: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern function typeck_find_or_alloc_ptr_type_ref(arena: *u8, elem_ref: i32): i32;
export extern function typeck_find_or_alloc_linear_type_ref(arena: *u8, elem_ref: i32): i32;
export extern function pipeline_type_region_label_len_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_region_label_into(arena: *u8, type_ref: i32, out: *u8): i32;
export extern function pipeline_type_find_or_alloc_slice(arena: *u8, elem_ref: i32, rlab: *u8, rlen: i32): i32;
export extern function typeck_dep_return_type_to_caller_arena(dep_arena: *u8, typeref: i32, caller: *u8): i32;
export extern function g_typeck_entry_module_for_dep_map_get(): *u8;

#[no_mangle]
export function get_dep_return_type_in_caller_arena(from_dep_index: i32, dep_return_type_ref: i32,
caller_arena: *u8, ctx: *u8): i32 {
  /* Authority lives in the host-cc .c fold vehicle. This .x keeps the name. */
  return 0;
}
