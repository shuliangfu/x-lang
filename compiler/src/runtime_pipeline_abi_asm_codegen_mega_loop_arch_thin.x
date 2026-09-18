// Thin pure: wave456 M2 — mega LOOP ELF arch defaults peer.
// Export: pipeline_asm_mega_set_elf_arch_c.
// wave456 probe: tip PREFER alone OK to inject; with loop -E → L2 0/5
//   BLD001 no main. HARD BAN product overlay; keep as Cap leave peer stub.
// PLATFORM: SHARED freestanding Cap leave / LINUX gold / MACOS co-path.

export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_elf_off_e_machine(): i32;
export extern function pipe_elf_off_reloc_type_r_pc32(): i32;

/**
 * Set ElfCodegenCtx e_machine + reloc_type_r_pc32 from DepCtx target_arch.
 * ta: 1=arm64 (183/283), 2=riscv (243/32), else x86_64 (62/2).
 * @param elfb *u8 — ElfCodegenCtx* bytes
 * @param ta i32 — pipeline_dep_ctx_target_arch
 * @return void
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS.
 */
#[no_mangle]
export function pipeline_asm_mega_set_elf_arch_c(elfb: *u8, ta: i32): void {
  unsafe {
    if (elfb == (0 as *u8)) {
      return;
    }
    if (ta == 1) {
      pipe_store_i32_le(elfb, pipe_elf_off_e_machine(), 183);
      pipe_store_i32_le(elfb, pipe_elf_off_reloc_type_r_pc32(), 283);
      return;
    }
    if (ta == 2) {
      pipe_store_i32_le(elfb, pipe_elf_off_e_machine(), 243);
      pipe_store_i32_le(elfb, pipe_elf_off_reloc_type_r_pc32(), 32);
      return;
    }
    pipe_store_i32_le(elfb, pipe_elf_off_e_machine(), 62);
    pipe_store_i32_le(elfb, pipe_elf_off_reloc_type_r_pc32(), 2);
  }
}
