// knife256/10.2 Cap tip get_dep trampoline (path/name softs elsewhere).
// PLATFORM: SHARED — Cap tip L2 sidecar.
export extern "C" function typeck_get_dep_return_type_in_caller_arena__demoted(from_dep_index: i32,
dep_return_type_ref: i32, caller_arena: *u8, ctx: *u8): i32;

#[no_mangle]
export function typeck_get_dep_return_type_in_caller_arena(from_dep_index: i32,
dep_return_type_ref: i32, caller_arena: *u8, ctx: *u8): i32 {
  unsafe {
    return typeck_get_dep_return_type_in_caller_arena__demoted(from_dep_index,
      dep_return_type_ref, caller_arena, ctx);
  }
}
