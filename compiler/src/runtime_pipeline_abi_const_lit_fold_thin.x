// 记211 probe: nuclear const_lit always imm -1 when asked.
// Isolates whether Cap emit receives fold. PLATFORM: SHARED tip overlay.

#[no_mangle]
export function asm_module_top_level_const_lit_i32(m: *u8, a: *u8, name: *u8, name_len: i32, out_imm: *i32): i32 {
  unsafe {
    if (m == 0 as *u8 || a == 0 as *u8 || name == 0 as *u8 || name_len <= 0 || out_imm == 0 as *i32) {
      return 0;
    }
    *out_imm = 0 - 1;
    return 1;
  }
}
