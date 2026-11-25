// knife256/10.2 Cap tip soft: real add_common_sym over m8 hollow ret0.
export extern function pipeline_elf_ctx_add_sym(ctx: *u8, name: *u8, name_len: i32, sym_size: i32): i32;
export extern function pipe_elf_common_sidecar_reset(ctx: *u8): void;
export extern function pipe_elf_off_num_syms(): i32;
export extern function pipe_elf_table_cap(): i32;
export extern function pipe_elf_sym_at(ctx: *u8, i: i32): *u8;
export extern function pipe_elf_sym_off_shndx(): i32;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;

// Sidecar tables live in elf_ctx_thin; expose via existing reset + is_common query path.
// We set shndx=65522 (SHN_COMMON) on the sym entry; macho_write checks shndx OR is_common.
// Also poke is_common via pipeline helpers if available.
export extern function pipeline_elf_ctx_sym_is_common_at(ctx: *u8, s: i32): i32;

#[no_mangle]
export function pipeline_elf_ctx_add_common_sym(ctx_bytes: *u8, name: *u8, name_len: i32, sym_size: i32, sym_align: i32): i32 {
  unsafe {
    let al: i32 = 0;
    let si: i32 = 0;
    let se: *u8 = 0 as *u8;
    let nsyms: i32 = 0;
    if (ctx_bytes == 0 as *u8 || name == 0 as *u8 || name_len <= 0 || sym_size <= 0) {
      return 0 - 1;
    }
    al = sym_align;
    if (al <= 0) { al = 8; }
    pipe_elf_common_sidecar_reset(ctx_bytes);
    if (pipeline_elf_ctx_add_sym(ctx_bytes, name, name_len, sym_size) != 0) {
      return 0 - 1;
    }
    // num_syms is a function returning offset? Check - on tip pipe_elf_off_num_syms returns OFFSET
    // Looking at nm: pipe_elf_off_num_syms is T - returns offset constant
    nsyms = pipe_load_i32_le(ctx_bytes, pipe_elf_off_num_syms());
    si = nsyms - 1;
    if (si < 0 || si >= pipe_elf_table_cap()) {
      return 0 - 1;
    }
    se = pipe_elf_sym_at(ctx_bytes, si);
    if (se == 0 as *u8) { return 0 - 1; }
    pipe_store_i32_le(se, pipe_elf_sym_off_shndx(), 65522);
    return 0;
  }
}
