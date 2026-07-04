# std.elf

ELF64 只读解析与最小 reloc 写入（STD-058+）。实现：**纯 `elf.x`**（F-elf v2 + F-ZC；fixture 经 `fs_open_read_c`）。

## API

- `parse_hdr` / `read_section` / `sec_name` / `find_section_idx` / `read_sec_byte`
- `read_phdr` — program header
- `read_sym` / `read_rela` / `sym_name` / `symtab_entry_count` / `rela_entry_count`
- `write_min_reloc` / `write_min_reloc_size` / `write_smoke`
- `elf_is_implemented()` → `1`

常量：`ELF_MACHINE_X86_64`、`ELF_ERR_*`、`ELF_SHT_*` 等见 `mod.x`。
