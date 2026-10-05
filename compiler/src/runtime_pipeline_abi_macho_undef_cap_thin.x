// Thin pure: Mach-O unique-undef row cap (pipe_elf_macho_undef_cap).
// This is the only definition of the cap. The Mach-O writer
// (runtime_pipeline_abi_macho_write_thin.x) calls it and sizes its two
// index tables (2048 i32 slots) to match.
// w2055: the Darwin pabi object keeps an old C copy that returns 256.
// parser.x has more than 256 unique undefined relocs, so the writer
// returned -1 (CG002, out_len=0). Darwin compiles this file with the
// current product, weakens the pabi copy, and links it first.
// PLATFORM: SHARED source; MACOS|DARWIN sidecar (Linux/Windows do not
// write Mach-O).

/**
 * Unique undefined symbol rows the Mach-O writer can record.
 * @return i32 - 2048 (matches the writer's index tables)
 */
#[no_mangle]
export function pipe_elf_macho_undef_cap(): i32 {
  return 2048;
}
