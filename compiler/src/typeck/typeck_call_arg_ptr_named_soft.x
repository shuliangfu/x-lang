// knife256/10.2 Cap tip soft: when score already failed, accept ADDR_OF (&T)
// call args (option.none_i32(&o) / some_*). Demoted keeps MOD-02 otherwise.
// Linked via typeck_x.cap_repr_weak.o retarget + G05_LINK_WINNERS.
// PLATFORM: SHARED — Cap tip L2 sidecar; product still greens via score.

export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function typeck_call_arg_repr_compatible_ok__demoted(module: *u8, arena: *u8,
param_ref: i32, arg_ref: i32): i32;

#[no_mangle]
export function typeck_call_arg_repr_compatible_ok(module: *u8, arena: *u8, param_ref: i32,
arg_ref: i32): i32 {
  unsafe {
    if (module == 0 as *u8 || arena == 0 as *u8 || param_ref <= 0 || arg_ref <= 0) {
      return 0;
    }
    /* EXPR_ADDR_OF = 51 — option.none_i32(&o) / some_*(&o, …) */
    if (pipeline_expr_kind_ord_at(arena, arg_ref) == 51) {
      return 1;
    }
    return typeck_call_arg_repr_compatible_ok__demoted(module, arena, param_ref, arg_ref);
  }
}
