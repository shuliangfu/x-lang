// knife256 / 10.2: strong pipeline_elf_ctx_add_{label,sym} for Darwin phase1.
// Hollow return-0 stubs first-won; tip elf_ctx_thin.o missing (tip_now SEGV).
// Helpers (label_at / off_* / name_eq / shndx_set) are live in the egg.
// PLATFORM: MACOS phase1 hollow companion · SHARED logic with elf_ctx_thin.

export extern function pipe_elf_current_shndx(ctx: *u8): i32;
export extern function pipe_elf_off_num_labels(): i32;
export extern function pipe_elf_off_num_syms(): i32;
export extern function pipe_elf_label_cap(): i32;
export extern function pipe_elf_table_cap(): i32;
export extern function pipe_elf_label_at(ctx: *u8, i: i32): *u8;
export extern function pipe_elf_sym_at(ctx: *u8, i: i32): *u8;
export extern function pipe_elf_lab_off_name(): i32;
export extern function pipe_elf_lab_off_name_len(): i32;
export extern function pipe_elf_lab_off_offset(): i32;
export extern function pipe_elf_sym_off_name_len(): i32;
export extern function pipe_elf_sym_off_offset(): i32;
export extern function pipe_elf_name_eq(a: *u8, a_len: i32, b: *u8, b_len: i32): i32;
export extern function pipe_elf_label_shndx_set(ctx: *u8, i: i32, shndx: i32): void;
export extern function pipe_elf_sym_shndx_set(ctx: *u8, i: i32, shndx: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;

function p1_memcpy(dst: *u8, src: *u8, n: i32): void {
  let i: i32 = 0;
  while (i < n) {
    unsafe { dst[i] = src[i]; }
    i = i + 1;
  }
}

#[no_mangle]
export function pipeline_elf_ctx_add_label(ctx: *u8, name: *u8, name_len: i32, offset: i32): i32 {
  if (ctx == 0 as *u8 || name == 0 as *u8 || name_len < 0) {
    return 0 - 1;
  }
  unsafe {
    let shndx: i32 = pipe_elf_current_shndx(ctx);
    let nl: i32 = pipe_load_i32_le(ctx, pipe_elf_off_num_labels());
    let name_off: i32 = pipe_elf_lab_off_name();
    let len_off: i32 = pipe_elf_lab_off_name_len();
    let disp_off: i32 = pipe_elf_lab_off_offset();
    let l: i32 = 0;
    while (l < nl) {
      let lab: *u8 = pipe_elf_label_at(ctx, l);
      let llen: i32 = pipe_load_i32_le(lab, len_off);
      if (pipe_elf_name_eq(lab + (name_off as usize), llen, name, name_len) != 0) {
        pipe_store_i32_le(lab, disp_off, offset);
        pipe_elf_label_shndx_set(ctx, l, shndx);
        return 0;
      }
      l = l + 1;
    }
    if (nl >= pipe_elf_label_cap()) {
      return 0 - 1;
    }
    let lab2: *u8 = pipe_elf_label_at(ctx, nl);
    let n: i32 = name_len;
    if (n > 255) { n = 255; }
    if (n < 0) { n = 0; }
    if (n > 0) {
      p1_memcpy(lab2 + (name_off as usize), name, n);
    }
    pipe_store_i32_le(lab2, len_off, n);
    pipe_store_i32_le(lab2, disp_off, offset);
    pipe_elf_label_shndx_set(ctx, nl, shndx);
    pipe_store_i32_le(ctx, pipe_elf_off_num_labels(), nl + 1);
  }
  return 0;
}

#[no_mangle]
export function pipeline_elf_ctx_add_sym(ctx: *u8, name: *u8, name_len: i32, offset: i32): i32 {
  if (ctx == 0 as *u8 || name == 0 as *u8 || name_len < 0) {
    return 0 - 1;
  }
  unsafe {
    let shndx: i32 = pipe_elf_current_shndx(ctx);
    let ns: i32 = pipe_load_i32_le(ctx, pipe_elf_off_num_syms());
    let name_off: i32 = pipe_elf_lab_off_name();
    let len_off: i32 = pipe_elf_sym_off_name_len();
    let disp_off: i32 = pipe_elf_sym_off_offset();
    let s: i32 = 0;
    while (s < ns) {
      let sym: *u8 = pipe_elf_sym_at(ctx, s);
      let slen: i32 = pipe_load_i32_le(sym, len_off);
      if (pipe_elf_name_eq(sym + (name_off as usize), slen, name, name_len) != 0) {
        pipe_store_i32_le(sym, disp_off, offset);
        pipe_elf_sym_shndx_set(ctx, s, shndx);
        return 0;
      }
      s = s + 1;
    }
    if (ns >= pipe_elf_table_cap()) {
      return 0 - 1;
    }
    let sym2: *u8 = pipe_elf_sym_at(ctx, ns);
    let n: i32 = name_len;
    if (n > 255) { n = 255; }
    if (n < 0) { n = 0; }
    if (n > 0) {
      p1_memcpy(sym2 + (name_off as usize), name, n);
    }
    pipe_store_i32_le(sym2, len_off, n);
    pipe_store_i32_le(sym2, disp_off, offset);
    pipe_elf_sym_shndx_set(ctx, ns, shndx);
    pipe_store_i32_le(ctx, pipe_elf_off_num_syms(), ns + 1);
  }
  return 0;
}
