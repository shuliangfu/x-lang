// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: Apache-2.0
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// Full text: LICENSE.Apache-2.0

// See implementation.
//
// See implementation.
// See implementation.

export const ELF_OK: i32 = 0;
export const ELF_ERR_NULL: i32 = -1;
export const ELF_ERR_SHORT: i32 = -2;
export const ELF_ERR_MAGIC: i32 = -3;
export const ELF_ERR_CLASS: i32 = -4;
export const ELF_ERR_ENDIAN: i32 = -5;
export const ELF_ERR_INDEX: i32 = -6;
export const ELF_ERR_NOT_FOUND: i32 = -7;

export const ELF_MACHINE_X86_64: i32 = 62;
export const ELF_TYPE_EXEC: i32 = 2;
export const ELF_PT_LOAD: i32 = 1;
export const ELF_SHT_PROGBITS: i32 = 1;
export const ELF_SHT_SYMTAB: i32 = 2;
export const ELF_R_X86_64_64: i32 = 1;

allow(padding) struct Elf64Hdr {
  e_type: i32
  machine: i32
  entry: u64
  phoff: u64
  phnum: i32
  shnum: i32
  shoff: u64
  shstrndx: i32
}

allow(padding) struct Elf64Phdr {
  p_type: i32
  p_flags: i32
  offset: u64
  vaddr: u64
  filesz: u64
  memsz: u64
}

allow(padding) struct Elf64Sec {
  name_off: i32
  sh_type: i32
  addr: u64
  offset: u64
  size: u64
}

allow(padding) struct Elf64Sym {
  name_off: i32
  bind: i32
  sym_type: i32
  shndx: i32
  value: u64
  size: u64
}

allow(padding) struct Elf64Rela {
  offset: u64
  sym_idx: i32
  reloc_type: i32
  addend: i64
}

extern function elf64_parse_hdr_c(ptr: *u8, len: i32, out: *Elf64Hdr): i32;
extern function elf64_read_phdr_c(ptr: *u8, len: i32, phoff: u64, phnum: i32, idx: i32, out: *Elf64Phdr): i32;
extern function elf64_read_shdr_c(ptr: *u8, len: i32, shoff: u64, shnum: i32, idx: i32, out: *Elf64Sec): i32;
extern function elf64_sec_name_c(ptr: *u8, len: i32, str_off: u64, str_size: u64, name_off: i32, buf: *u8, buf_len: i32): i32;
extern function elf64_find_section_c(ptr: *u8, len: i32, shoff: u64, shnum: i32, shstrndx: i32, want: *u8, out_idx: *i32): i32;
extern function elf64_read_sec_byte_c(ptr: *u8, len: i32, sec_off: u64, sec_size: u64, at: u64, out: *u8): i32;
extern function elf64_read_sym_c(ptr: *u8, len: i32, sym_off: u64, sym_size: u64, idx: i32, out: *Elf64Sym): i32;
extern function elf64_read_rela_c(ptr: *u8, len: i32, rela_off: u64, rela_size: u64, idx: i32, out: *Elf64Rela): i32;
extern function elf64_write_min_reloc_size_c(text_len: i32): i32;
extern function elf64_write_min_reloc_c(buf: *u8, cap: i32, text: *u8, text_len: i32, out_len: *i32): i32;
extern function elf64_write_smoke_c(): i32;
extern function elf64_parse_smoke_c(): i32;

/** Exported function `is_implemented`.
 * Query helper `is_implemented`.
 * @return i32
 */
export function is_implemented(): i32 { return 1; }

/** Exported function `parse_hdr`.
 * Implements `parse_hdr`.
 * @param ptr *u8
 * @param len i32
 * @param out *Elf64Hdr
 * @return i32
 */
export function parse_hdr(ptr: *u8, len: i32, out: *Elf64Hdr): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = elf64_parse_hdr_c(ptr, len, out); }
  return _rc;
}

/** Exported function `read_section`.
 * Read path helper `read_section`.
 * @param ptr *u8
 * @param len i32
 * @param hdr *Elf64Hdr
 * @param idx i32
 * @param out *Elf64Sec
 * @return i32
 */
export function read_section(ptr: *u8, len: i32, hdr: *Elf64Hdr, idx: i32, out: *Elf64Sec): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = elf64_read_shdr_c(ptr, len, hdr.shoff, hdr.shnum, idx, out); }
  return _rc;
}

/** Exported function `sec_name`.
 * Implements `sec_name`.
 * @param ptr *u8
 * @param len i32
 * @param strtab *Elf64Sec
 * @param name_off i32
 * @param buf *u8
 * @param buf_len i32
 * @return i32
 */
export function sec_name(ptr: *u8, len: i32, strtab: *Elf64Sec, name_off: i32, buf: *u8, buf_len: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = elf64_sec_name_c(ptr, len, strtab.offset, strtab.size, name_off, buf, buf_len); }
  return _rc;
}

/** Exported function `find_section_idx`.
 * Implements `find_section_idx`.
 * @param ptr *u8
 * @param len i32
 * @param hdr *Elf64Hdr
 * @param want *u8
 * @param out_idx *i32
 * @return i32
 */
export function find_section_idx(ptr: *u8, len: i32, hdr: *Elf64Hdr, want: *u8, out_idx: *i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = elf64_find_section_c(ptr, len, hdr.shoff, hdr.shnum, hdr.shstrndx, want, out_idx); }
  return _rc;
}

/** Exported function `read_sec_byte`.
 * Read path helper `read_sec_byte`.
 * @param ptr *u8
 * @param len i32
 * @param sec *Elf64Sec
 * @param at u64
 * @param out *u8
 * @return i32
 */
export function read_sec_byte(ptr: *u8, len: i32, sec: *Elf64Sec, at: u64, out: *u8): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = elf64_read_sec_byte_c(ptr, len, sec.offset, sec.size, at, out); }
  return _rc;
}

/** Exported function `read_phdr`.
 * Read path helper `read_phdr`.
 * @param ptr *u8
 * @param len i32
 * @param hdr *Elf64Hdr
 * @param idx i32
 * @param out *Elf64Phdr
 * @return i32
 */
export function read_phdr(ptr: *u8, len: i32, hdr: *Elf64Hdr, idx: i32, out: *Elf64Phdr): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = elf64_read_phdr_c(ptr, len, hdr.phoff, hdr.phnum, idx, out); }
  return _rc;
}

/** Exported function `read_sym`.
 * Read path helper `read_sym`.
 * @param ptr *u8
 * @param len i32
 * @param sec *Elf64Sec
 * @param idx i32
 * @param out *Elf64Sym
 * @return i32
 */
export function read_sym(ptr: *u8, len: i32, sec: *Elf64Sec, idx: i32, out: *Elf64Sym): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = elf64_read_sym_c(ptr, len, sec.offset, sec.size, idx, out); }
  return _rc;
}

/** Exported function `sym_name`.
 * Implements `sym_name`.
 * @param ptr *u8
 * @param len i32
 * @param strtab *Elf64Sec
 * @param name_off i32
 * @param buf *u8
 * @param buf_len i32
 * @return i32
 */
export function sym_name(ptr: *u8, len: i32, strtab: *Elf64Sec, name_off: i32, buf: *u8, buf_len: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = elf64_sec_name_c(ptr, len, strtab.offset, strtab.size, name_off, buf, buf_len); }
  return _rc;
}

/** Exported function `symtab_entry_count`.
 * Implements `symtab_entry_count`.
 * @param sec *Elf64Sec
 * @return i32
 */
export function symtab_entry_count(sec: *Elf64Sec): i32 {
  let sz: u64 = 0;
  unsafe {
    sz = sec.size;
  }
  let n: i64 = sz / 24;
  return n as i32;
}

/** Exported function `read_rela`.
 * Read path helper `read_rela`.
 * @param ptr *u8
 * @param len i32
 * @param sec *Elf64Sec
 * @param idx i32
 * @param out *Elf64Rela
 * @return i32
 */
export function read_rela(ptr: *u8, len: i32, sec: *Elf64Sec, idx: i32, out: *Elf64Rela): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = elf64_read_rela_c(ptr, len, sec.offset, sec.size, idx, out); }
  return _rc;
}

/** Exported function `rela_entry_count`.
 * Implements `rela_entry_count`.
 * @param sec *Elf64Sec
 * @return i32
 */
export function rela_entry_count(sec: *Elf64Sec): i32 {
  let sz: u64 = 0;
  unsafe {
    sz = sec.size;
  }
  let n: i64 = sz / 24;
  return n as i32;
}

/** Exported function `write_err_ok`.
 * Write path helper `write_err_ok`.
 * @return i32
 */
export function write_err_ok(): i32 {
  return ELF_OK;
}

/** Exported function `write_min_reloc_size`.
 * Write path helper `write_min_reloc_size`.
 * @param text_len i32
 * @return i32
 */
export function write_min_reloc_size(text_len: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = elf64_write_min_reloc_size_c(text_len); }
  return _rc;
}

/** Exported function `write_min_reloc`.
 * Write path helper `write_min_reloc`.
 * @param buf *u8
 * @param cap i32
 * @param text *u8
 * @param text_len i32
 * @param out_len *i32
 * @return i32
 */
export function write_min_reloc(buf: *u8, cap: i32, text: *u8, text_len: i32, out_len: *i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = elf64_write_min_reloc_c(buf, cap, text, text_len, out_len); }
  return _rc;
}

/** Exported function `write_smoke`.
 * Write path helper `write_smoke`.
 * @return i32
 */
export function write_smoke(): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = elf64_write_smoke_c(); }
  return _rc;
}

/** Exported function `parse_smoke`.
 * Implements `parse_smoke`.
 * @return i32
 */
export function parse_smoke(): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = elf64_parse_smoke_c(); }
  return _rc;
}
