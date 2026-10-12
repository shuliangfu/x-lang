// Identity emit order for Windows PE.
// The egg's pipeline_asm_wpo_pgo_emit_order_{prepare,count,at} is this
// same fill, so same-TU calls inside that object already do the right
// work. src/runtime_pipeline_abi_asm_wpo_thin.o is linked later and
// defines the same three names with a WPO filter and a depth sort.
// PE first-wins, so g05 links this object ahead of that thin.
// This file does not call pipeline_asm_wpo_should_emit_func and it
// does not sort. Do not switch runtime_pipeline_abi_asm_wpo_thin.x on
// in its place. The order table is 4096 i32, matching ASM_WPO_MAX_FUNCS
// in seeds/win_wpo_pgo_emit_override.c. That .c is not a build input.
// Null module: prepare stores a null and a zero count; count returns 0
// and does not prepare; at returns -1.
// PLATFORM: WINDOWS | MSYS | MINGW. g05 rebuilds this file into
// build_asm/selfhost_pabi/wpo_pgo_emit_win.o. Do not link it on Linux
// or Darwin. Do not PREFER it into runtime_pipeline_abi.o.

export extern function pipeline_module_num_funcs(m: *u8): i32;
export extern function pipeline_asm_module_func_is_extern_at(m: *u8, fi: i32): i32;

// BSS homes. The product emits these as Lxml commons. The names stay
// off the asm_wpo thin's g_aw_pgo_emit_* symbols.
let g_win_pgo_emit_order: i32[4096] = [];
let g_win_pgo_emit_n: i32 = 0;
let g_win_pgo_emit_mod: *u8 = 0 as *u8;

/**
 * Fill emit order with every non-extern function index, in index order.
 * @param m *u8 — ast module; null clears the count and the saved module
 * @return void
 * Capacity is 4096. A later index past that cap is not stored and does
 * not grow the count. No divide. PLATFORM: WINDOWS.
 */
#[no_mangle]
export function pipeline_asm_wpo_pgo_emit_order_prepare(m: *u8): void {
  unsafe {
    g_win_pgo_emit_mod = m;
    g_win_pgo_emit_n = 0;
    if (m == 0 as *u8) {
      return;
    }
    let nf: i32 = pipeline_module_num_funcs(m);
    let fi: i32 = 0;
    let n: i32 = 0;
    while (fi < nf) {
      // Skip extern. There is no continue in this language.
      if (pipeline_asm_module_func_is_extern_at(m, fi) == 0) {
        if (n < 4096) {
          g_win_pgo_emit_order[n] = fi;
          n = n + 1;
        }
      }
      fi = fi + 1;
    }
    g_win_pgo_emit_n = n;
  }
}

/**
 * Return how many non-extern functions prepare stored for this module.
 * @param m *u8 — ast module; null returns 0 and does not prepare
 * @return i32 — count, or 0 when m is null
 * A different module pointer prepares again. PLATFORM: WINDOWS.
 */
#[no_mangle]
export function pipeline_asm_wpo_pgo_emit_order_count(m: *u8): i32 {
  unsafe {
    if (m == 0 as *u8) {
      return 0;
    }
    if (m != g_win_pgo_emit_mod) {
      pipeline_asm_wpo_pgo_emit_order_prepare(m);
    }
    return g_win_pgo_emit_n;
  }
}

/**
 * Return the function index at one emit-order slot.
 * @param m *u8 — ast module; null returns -1
 * @param order_index i32 — slot; negative or past the count returns -1
 * @return i32 — function index, or -1
 * Also rejects an index at or past 4096. PLATFORM: WINDOWS.
 */
#[no_mangle]
export function pipeline_asm_wpo_pgo_emit_order_at(m: *u8, order_index: i32): i32 {
  unsafe {
    if (m == 0 as *u8 || order_index < 0) {
      return -1;
    }
    if (m != g_win_pgo_emit_mod) {
      pipeline_asm_wpo_pgo_emit_order_prepare(m);
    }
    if (order_index >= g_win_pgo_emit_n || order_index >= 4096) {
      return -1;
    }
    return g_win_pgo_emit_order[order_index];
  }
}
