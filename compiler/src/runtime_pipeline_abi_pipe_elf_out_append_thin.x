// Thin: pipe_elf_out_append with CodegenOutBuf length@0 / data@+4 (10.94).
// Cap tip pabi_weak.bak_cap still carries data@0 append; demote that and
// first-win this export. PLATFORM: SHARED freestanding.

export extern function codegen_out_buf_len(out: *u8): i32;
export extern function codegen_out_buf_set_len(out: *u8, n: i32): void;
export extern function pipe_elf_codegen_out_cap(): i32;

/**
 * Append n bytes into CodegenOutBuf (length@0 + data@+4).
 * @return i32 — 0 ok, -1 overflow / bad args
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipe_elf_out_append(out: *u8, p: *u8, n: i32): i32 {
  if (out == 0 as *u8 || p == 0 as *u8 || n < 0) {
    return 0 - 1;
  }
  let len: i32 = 0;
  let cap: i32 = 0;
  unsafe {
    len = codegen_out_buf_len(out);
    cap = pipe_elf_codegen_out_cap();
  }
  if (len + n > cap) {
    return 0 - 1;
  }
  let i: i32 = 0;
  while (i < n) {
    unsafe {
      out[4 + len + i] = p[i];
    }
    i = i + 1;
  }
  unsafe {
    codegen_out_buf_set_len(out, len + n);
  }
  return 0;
}
