// Thin pure override: parser bootstrap mega-name allow list.
// w1558: egg asm_parser_bootstrap_mega_emit_allowed returns 1 only for
// parse_into_buf, parse_into, parse_into_init, parse_into_set_main_index,
// and collect_imports_buf. Under XLANG_ASM_PARSER_PARSE_BOOTSTRAP_EMIT the
// other mega names stay 24-byte ret0: parse, parse_one_function_impl,
// parse_expr_into, parse_block_into, parse_body_lets_into. Probes on the
// live image emitted those bodies once XLANG_ASM_PARSER_MEGA_BISECT named
// them (spans far above the 24-byte stub), so the slot cap is not the gate.
// asm_skip_heavy_parser_mega_entry calls this symbol with R_X86_64_PLT32.
// g05_relink_env.sh compiles this file with the current product and links
// it ahead of pabi. The egg copy stays weak and is not rebuilt.
// MINIMAL still allows only parse_into_init and parse_into_set_main_index.
// asm_skip_typeck_entry_whitelist is a different caller and is not this
// overlay. Do not set XLANG_ASM_ENTRY_EMIT_HEAVY on a product rebuild.
// PLATFORM: SHARED — Linux first-wins, Darwin weak egg, Windows weaken.

export extern "C" function link_abi_getenv(name: *u8): *u8;
export extern "C" function pipeline_module_func_name_equal_at(module: *u8, fi: i32, name: *u8, name_len: i32): i32;

/**
 * Allow a parser mega name to emit when bootstrap emit is set.
 * @param m *u8 — Module*; null returns 0
 * @param func_index i32 — function index; negative returns 0
 * @param name *u8 — candidate name bytes; compared only when len matches
 * @param len i32 — byte length of name
 * @return i32 — 1 when this mega name may emit, else 0
 * PLATFORM: SHARED — sole linked body; egg weak copy is the short list.
 */
#[no_mangle]
export function asm_parser_bootstrap_mega_emit_allowed(m: *u8, func_index: i32, name: *u8, len: i32): i32 {
  unsafe {
    if (m == 0 as *u8 || func_index < 0) {
      return 0;
    }
    // Presence check (null only). An empty string still enables bootstrap.
    if (link_abi_getenv("XLANG_ASM_PARSER_PARSE_BOOTSTRAP_EMIT") == 0 as *u8) {
      return 0;
    }
    if (pipeline_module_func_name_equal_at(m, func_index, name, len) == 0) {
      return 0;
    }
    if (link_abi_getenv("XLANG_ASM_PARSER_PARSE_BOOTSTRAP_EMIT_MINIMAL") != 0 as *u8) {
      if (len == 15) {
        if (pipeline_module_func_name_equal_at(m, func_index, "parse_into_init", 15) != 0) {
          return 1;
        }
      }
      if (len == 25) {
        if (pipeline_module_func_name_equal_at(m, func_index, "parse_into_set_main_index", 25) != 0) {
          return 1;
        }
      }
      return 0;
    }
    if (len == 14) {
      if (pipeline_module_func_name_equal_at(m, func_index, "parse_into_buf", 14) != 0) {
        return 1;
      }
    }
    if (len == 10) {
      if (pipeline_module_func_name_equal_at(m, func_index, "parse_into", 10) != 0) {
        return 1;
      }
    }
    // parse_into_init and parse_expr_into are both 15 bytes.
    if (len == 15) {
      if (pipeline_module_func_name_equal_at(m, func_index, "parse_into_init", 15) != 0) {
        return 1;
      }
      if (pipeline_module_func_name_equal_at(m, func_index, "parse_expr_into", 15) != 0) {
        return 1;
      }
    }
    if (len == 25) {
      if (pipeline_module_func_name_equal_at(m, func_index, "parse_into_set_main_index", 25) != 0) {
        return 1;
      }
    }
    if (len == 19) {
      if (pipeline_module_func_name_equal_at(m, func_index, "collect_imports_buf", 19) != 0) {
        return 1;
      }
    }
    if (len == 5) {
      if (pipeline_module_func_name_equal_at(m, func_index, "parse", 5) != 0) {
        return 1;
      }
    }
    if (len == 23) {
      if (pipeline_module_func_name_equal_at(m, func_index, "parse_one_function_impl", 23) != 0) {
        return 1;
      }
    }
    if (len == 16) {
      if (pipeline_module_func_name_equal_at(m, func_index, "parse_block_into", 16) != 0) {
        return 1;
      }
    }
    if (len == 20) {
      if (pipeline_module_func_name_equal_at(m, func_index, "parse_body_lets_into", 20) != 0) {
        return 1;
      }
    }
    return 0;
  }
}
