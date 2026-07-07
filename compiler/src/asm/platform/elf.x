// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// elf.x — ELF64 可重定位 .o 写出（7.4 完整功能）
//
// 职责：将 backend 产出的机器码字节 + 符号/重定位信息写成 ELF64 ET_REL
// 文件；
// 支持多函数、局部标签补丁（jz/jmp）、call 重定位（.rela.text）。
// 依赖：codegen_outbuf_abi（CodegenOutBuf 作 ELF 输出缓冲）；由 backend 在「出
// .o」路径下填充 ElfCodegenCtx。
//

const codegen_outbuf_abi = import("codegen_outbuf_abi");

/** elf.x：大 struct 字段写入 sidecar（ast_pool.c）；键 = *ElfCodegenCtx 转 *u8。 */
extern function pipeline_elf_ctx_append_patch(ctx: *u8, rel32_offset: i32, name: *u8, name_len:
i32, imm_bits: i32): i32;
extern function pipeline_elf_ctx_append_reloc(ctx: *u8, offset: i32, name: *u8, name_len: i32): i32;
extern function pipeline_elf_ctx_add_label(ctx: *u8, name: *u8, name_len: i32, offset: i32): i32;
extern function pipeline_elf_ctx_ensure_label(ctx: *u8, name: *u8, name_len: i32): i32;
/** macho/elf：reloc_sym_names 行读写 glue，避免大 ElfCodegenCtx 二维数组下标
* typeck/asm 失败。 */
extern function pipeline_elf_ctx_reloc_sym_name_ptr(ctx: *u8, idx: i32): *u8;
extern function pipeline_elf_ctx_reloc_sym_name_copy64(ctx: *u8, idx: i32, dst: *u8): void;
extern function pipeline_elf_ctx_reloc_name_len(ctx: *u8, idx: i32): i32;
/** sidecar 读 patch_imm_bits，避免 .x 大 struct patches[] 字段偏移与 C
* 写入不一致。 */
extern function pipeline_elf_ctx_patch_imm_bits_at(ctx: *u8, patch_idx: i32): i32;
/** sidecar：heap reloc offset 读写（idx 可 >= 2048）。 */
extern function pipeline_elf_ctx_reloc_offset_at(ctx: *u8, idx: i32): i32;
extern function pipeline_elf_ctx_reloc_offset_set(ctx: *u8, idx: i32, offset: i32): void;
extern function pipeline_elf_ctx_reloc_sidecar_reset(ctx: *u8): void;
/** 统一经 ast_pool C 实现解析 patch（与 append_patch 同布局，避免 gen C 与
* PipelineElfCtxAccess 不一致）。 */
extern function pipeline_elf_ctx_resolve_patches(ctx: *u8): i32;
extern function pipeline_elf_ctx_reloc_shndx_at(ctx: *u8, idx: i32): i32;
extern function pipeline_elf_ctx_sym_shndx_at(ctx: *u8, idx: i32): i32;
extern function pipeline_elf_pgo_hot_enabled(): i32;
extern function pipeline_elf_ctx_set_emit_hot(ctx: *u8, hot: i32): void;
extern function pipeline_elf_ctx_append_bytes(ctx: *u8, ptr: *u8, n: i32): i32;
extern function pipeline_elf_ctx_code_data_ptr(ctx: *u8): *u8;
extern function pipeline_elf_write_o_pgo_to_buf(ctx: *u8, out: *CodegenOutBuf): i32;
/** 标准 ELF64 .o 写出：经 ast_pool.c 从 glue code_data 读机器码（X 直读 ctx.code_data[] 在 seed partial 会 __text 全零/损坏）。 */
extern function pipeline_elf_write_o_standard_to_buf_c(ctx: *u8, out: *CodegenOutBuf): i32;
/** 诊断：elf_resolve_patches 找不到目标标签时打印补丁名。 */
extern function driver_diagnostic_asm_elf_unresolved_patch(name: *u8, name_len: i32): void;
/** 诊断：补丁名在 labels 表中的匹配情况（sidecar 扫描）。 */
extern function pipeline_elf_log_unresolved_patch(ctx: *ElfCodegenCtx, patch_idx: i32): void;

/** 局部标签：名称与在 .text 中的偏移（用于 jz/jmp 补丁）。 */
struct ElfLabelEntry {
  name: u8[64];
  name_len: i32;
  offset: i32;
}

/** 待补丁的 rel32：写入位置与目标标签名（补丁时查 LabelEntry 得到目标
* offset）。x86：32 位 rel32；arm64：patch_imm_bits 26=B/BL，19=B.cond/CBZ/CBNZ。 */
struct ElfPatchEntry {
  rel32_offset: i32;
  name: u8[64];
  name_len: i32;
  /** 0=x86 写 32 位 rel32；26=arm64 写指令低 26 位；19=arm64 写指令 imm19。 */
  patch_imm_bits: i32;
}

/**
* 对外符号重定位：call 目标等，需写入 .rela.text。
* 符号名字节放在 ElfCodegenCtx.reloc_sym_names[同下标]，避免经 -E 后
* &relocs[i].name[0] 变成对「?:」临时 struct 取址（悬空）。
*/
struct ElfRelocEntry {
  offset: i32;
  name_len: i32;
}

struct ElfRelocSymName64 {
  bytes: u8[64];
}

/** 导出符号（函数）：名称与在 .text 中的偏移。 */
struct ElfSymEntry {
  name: u8[64];
  name_len: i32;
  offset: i32;
  /** ELF st_shndx：1=.text，2=.text.hot（PGO-Lite）。 */
  sym_shndx: i32;
}

/**
* ELF 代码生成上下文：大块 code_data、sym_name_data 置于末尾，便于自举 typeck
* 在 *ElfCodegenCtx 上解析前几项标量字段；
* 行为与旧嵌套 ElfCodeBuf 等价（code_len + code_data[0..len-1]）；符号名见
* sym_name_data + elf_sym_name_ptr。
*/
allow(padding) struct ElfCodegenCtx {
  code_len: i32;
  /**
  * 多函数 + 分支/循环标签；asm_codegen_elf_o 将各 dep 与入口编入同一
  * .text，累计标签/补丁/重定位易超过旧上限 512/2048。
  * 与下行 patches/relocs/syms/reloc_sym_names 行数保持一致（内联 16384，与 ast_pool.c PIPELINE_ELF_CTX_TABLE_CAP 同步）。
  */
  labels: ElfLabelEntry[16384];
  num_labels: i32;
  patches: ElfPatchEntry[16384];
  num_patches: i32;
  relocs: ElfRelocEntry[16384];
  reloc_sym_names: ElfRelocSymName64[16384];
  num_relocs: i32;
  syms: ElfSymEntry[16384];
  num_syms: i32;
  /** sym_name_data 中已写入的符号名字节总数；与 num_syms 一起在 elf_ctx_reset
  * 中清零。 */
  sym_name_len: i32;
  /** ELF e_machine：62=EM_X86_64，183=EM_AARCH64；write_elf_o_to_buf 写入 ehdr[18..19]。 */
  e_machine: i32;
  /** .rela.text 中 PC 相对重定位类型：2=R_X86_64_PC32，283=R_AARCH64_CALL26；由
  * backend 按架构设置。 */
  reloc_type_r_pc32: i32;
  /** arm64 用：enc_prologue 写入，enc_epilogue 读出以发射 add sp, sp,
  * #current_frame_size。 */
  current_frame_size: i32;
  /**
  * Mach-O（Darwin）：导出符号与 call 重定位使用 leading `_`，与 ld64 / libc
  * 符号一致；
  * ELF/COFF 路径保持 0。由 asm_codegen_elf_o 在 use_macho_o 时置 1，elf_ctx_reset
  * 清零。
  */
  macho_leading_underscore: i32;
  /** PGO-Lite：.text.hot 段已编码字节数（与 code_hot_data 同步）。 */
  code_hot_len: i32;
  /** 当前 emit 目标：0=.text，非 0=.text.hot（须 SHUX_WPO_PGO_HOT=1）。 */
  emit_hot: i32;
  /** 已编码机器码字节；与 ast_pool.c PIPELINE_ELF_CTX_CODE_BUF_CAP 同步。 */
  code_data: u8[8716288];
  /** PGO-Lite 热路径机器码缓冲（1MiB；大程序热段仍主要由 WPO reach 控制）。 */
  code_hot_data: u8[1048576];
  /** 导出符号名字节池；1379 func EMIT_HEAVY 须 >32768（约 48KiB 名字总量）。 */
  sym_name_data: u8[131072];
}

/** 将 i32 截断为 u8（低 8 位；与同义写法 val & 255 一致）。
* 旧实现 let 巨型 u8[256] 字面量表会令 parse_into_buf 跳过首函数以致 dep module
* 残缺。
* 「let lo = …; return lo as u8」双语句在 dep 路径上首函数仍可能未写入
* funcs；单句 return … as u8 避免该边角。
*/
function elf_to_u8(val: i32): u8 {
  return val as u8;
}

/** 取 i64 按无符号 u32 解释后的第 byte_idx 字节（0..3）；避免高位为 1
* 时有符号 >> 污染 ARM/x86 机器码。val 高于 32 位部分被截断。 */
function elf_u32_byte_at(val: i64, byte_idx: i32): u8 {
  let u: u32 = val as u32;
  if (byte_idx == 0) {
    return (u & 255) as u8;
  }
  if (byte_idx == 1) {
    return ((u >> 8) & 255) as u8;
  }
  if (byte_idx == 2) {
    return ((u >> 16) & 255) as u8;
  }
  return ((u >> 24) & 255) as u8;
}

/**
* 将 ptr 指向的 64 字节置 0。
* 用于 Mach-O strtab 前对 reloc 槽名缓冲清零；用 ptr[i] 写，避免嵌套 struct
* 成员数组下标经 -E 到 C 时错误更新。
*/
function elf_clear_u8_64(ptr: *u8): void {
  let i: i32 = 0;
  while (i < 64) {
    ptr[i] = 0;
    i = i + 1;
  }
}

/**
* 将 src 前 n 字节拷入 dst（两侧各最多 64 字节）。
* 专用 *u8 + 下标赋值，避免形如 ctx.relocs[r].name[k] = name[k] 展开后在 C
* 后端写成错误槽，导致 Darwin .o 中 UND 符号名为空串。
*/
function elf_copy_u8_n(dst: *u8, src: *u8, n: i32): void {
  let i: i32 = 0;
  while (i < n && i < 64) {
    dst[i] = src[i];
    i = i + 1;
  }
}

/** 多 Module 顺序写入同一 elf_ctx
* 时，局部标签全局前缀计数器（ast_pool.c）。 */
extern function pipeline_elf_label_mod_scope_reset(): void;

/** 重置 elf_ctx，用于新一轮编码前。e_machine 不在此清零，由 backend
* 在编码前设置。 */
function elf_ctx_reset(ctx: *ElfCodegenCtx): void {
  ctx.code_len = 0;
  ctx.code_hot_len = 0;
  ctx.emit_hot = 0;
  ctx.num_labels = 0;
  ctx.num_patches = 0;
  ctx.num_relocs = 0;
  ctx.num_syms = 0;
  ctx.sym_name_len = 0;
  ctx.macho_leading_underscore = 0;
  pipeline_elf_label_mod_scope_reset();
  pipeline_elf_ctx_reloc_sidecar_reset(ctx as *u8);
}

/** 当前 emit 段内已写字节数（PGO 路由 .text / .text.hot）。 */
function elf_section_code_len(ctx: *ElfCodegenCtx): i32 {
  if (pipeline_elf_pgo_hot_enabled() != 0 && ctx.emit_hot != 0) {
    return ctx.code_hot_len;
  }
  return ctx.code_len;
}

/** 向当前 emit 段追加 n 字节；经 C 路由 .text / .text.hot（PGO-Lite）。 */
function append_elf_bytes(ctx: *ElfCodegenCtx, ptr: *u8, n: i32): i32 {
  return pipeline_elf_ctx_append_bytes(ctx as *u8, ptr, n);
}

/** Mach-O arm64 要求函数入口 4 字节对齐；在 is_func 标签前填充 0 字节至
* code_len%4==0。 */
function elf_pad_code_to_4(ctx: *ElfCodegenCtx): i32 {
  let pad: u8[1] = [0];
  while (elf_section_code_len(ctx) % 4 != 0) {
    if (append_elf_bytes(ctx, pad, 1) != 0) {
      return -1;
    }
  }
  return 0;
}

/** 记录标签：名称为 name[0..name_len-1]，当前段内偏移；同名则更新偏移。 */
function elf_add_label(ctx: *ElfCodegenCtx, name: *u8, name_len: i32): i32 {
  return pipeline_elf_ctx_add_label(ctx as *u8, name, name_len, elf_section_code_len(ctx));
}

/** 前向跳转：补丁已记录但标签尚未落点时占位（offset=-1，enc_label 会 upsert
* 真实偏移）。 */
function elf_ensure_label_slot(ctx: *ElfCodegenCtx, name: *u8, name_len: i32): i32 {
  return pipeline_elf_ctx_ensure_label(ctx as *u8, name, name_len);
}

/** 记录待补丁：rel32 应写入的位置与目标标签名（x86
* 用，patch_imm_bits=0）。name 为符号名字节指针。 */
function elf_add_patch(ctx: *ElfCodegenCtx, rel32_offset: i32, name: *u8, name_len: i32): i32 {
  return elf_add_patch_with_bits(ctx, rel32_offset, name, name_len, 0);
}

/** 记录待补丁（arm64 用）：imm_bits 26=B/BL，19=CBZ/CBNZ/B.cond。 */
function elf_add_patch_with_bits(ctx: *ElfCodegenCtx, rel32_offset: i32, name: *u8, name_len: i32,
imm_bits: i32): i32 {
  return pipeline_elf_ctx_append_patch(ctx as *u8, rel32_offset, name, name_len, imm_bits);
}

/** 记录重定位：offset 为 .text 内 rel32 位置，name 为符号名字节指针。 */
function elf_add_reloc(ctx: *ElfCodegenCtx, offset: i32, name: *u8, name_len: i32): i32 {
  return pipeline_elf_ctx_append_reloc(ctx as *u8, offset, name, name_len);
}

/**
* 返回第 sym_idx 个导出符号名称在 sym_name_data
* 中的起始指针（按顺序拼接，长度见 syms[sym_idx].name_len）。
* 要求 0 <= sym_idx < ctx.num_syms。
*/
function elf_sym_name_ptr(ctx: *ElfCodegenCtx, sym_idx: i32): *u8 {
  let off: i32 = 0;
  let i: i32 = 0;
  while (i < sym_idx) {
    off = off + ctx.syms[i].name_len;
    i = i + 1;
  }
  return &ctx.sym_name_data[off];
}

/**
* 记录导出符号（函数）：名将写入 sym_name_data，syms[].name 不填充；.text
* 偏移写入 offset。
* name_len 与历史行为一致，实际最多拷贝 64 字节入池。
*/
function elf_add_sym(ctx: *ElfCodegenCtx, name: *u8, name_len: i32, offset: i32): i32 {
  if (ctx.num_syms >= 16384) {
    return -1;
  }
  let copy_len: i32 = name_len;
  if (copy_len > 64) {
    copy_len = 64;
  }
  if (copy_len < 0) {
    copy_len = 0;
  }
  if (ctx.sym_name_len + copy_len > 131072) {
    return -1;
  }
  let k: i32 = 0;
  while (k < copy_len) {
    ctx.sym_name_data[ctx.sym_name_len] = name[k];
    ctx.sym_name_len = ctx.sym_name_len + 1;
    k = k + 1;
  }
  ctx.syms[ctx.num_syms].name_len = copy_len;
  ctx.syms[ctx.num_syms].offset = offset;
  if (pipeline_elf_pgo_hot_enabled() != 0 && ctx.emit_hot != 0) {
    ctx.syms[ctx.num_syms].sym_shndx = 2;
  } else if (pipeline_elf_pgo_hot_enabled() != 0) {
    ctx.syms[ctx.num_syms].sym_shndx = 3;
  } else {
    ctx.syms[ctx.num_syms].sym_shndx = 1;
  }
  ctx.num_syms = ctx.num_syms + 1;
  return 0;
}

/** 比较两段名字是否相等（按 name_len 长度）。 */
function elf_name_eq(a: u8[64], a_len: i32, b: u8[64], b_len: i32): i32 {
  if (a_len != b_len) {
    return 0;
  }
  let i: i32 = 0;
  while (i < a_len) {
    if (a[i] != b[i]) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

/**
* 比较 u8[64] 名字与 sym_name_data 池中的一段（pool[0..pool_len-1]）是否相同。
* 用于 relocs 与扁平符号名匹配。
*/
function elf_name_eq_arr_to_pool(name: u8[64], name_len: i32, pool: *u8, pool_len: i32): i32 {
  if (name_len != pool_len) {
    return 0;
  }
  let i: i32 = 0;
  while (i < name_len) {
    if (name[i] != pool[i]) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

/** reloc 目标是否已在 ctx.syms（本 .o 定义）中。 */
function elf_reloc_target_is_defined(ctx: *ElfCodegenCtx, reloc_idx: i32): i32 {
  let m: i32 = 0;
  let r_sym_buf: u8[64] = [];
  pipeline_elf_ctx_reloc_sym_name_copy64(ctx as *u8, reloc_idx, &r_sym_buf[0]);
  let rlen: i32 = pipeline_elf_ctx_reloc_name_len(ctx as *u8, reloc_idx);
  while (m < ctx.num_syms) {
    if (elf_name_eq_arr_to_pool(r_sym_buf, rlen, elf_sym_name_ptr(ctx, m), ctx.syms[m].name_len) != 0) {
      return 1;
    }
    m = m + 1;
  }
  return 0;
}

/**
 * 从 .text 占位指令推断 arm64 patch 位宽；imm_bits/e_machine 丢失时避免误走 x86
* rel32 写成 udf。
* 返回 19（cbz/cbnz/b.cond）、26（b/bl）或 0（未知，仍走 x86 rel32）。
*/
function elf_infer_patch_imm_bits_from_code(ctx: *ElfCodegenCtx, rel32_offset: i32): i32 {
  if (rel32_offset < 0 || rel32_offset + 3 >= ctx.code_len) {
    return 0;
  }
  /** arm64 指令小端存储，最高字节在 [rel32_offset+3]。 */
  let op8: i32 = ctx.code_data[rel32_offset + 3] & 255;
  if (op8 == 52 || op8 == 53) {
    return 19;
  }
  if (op8 == 84) {
    return 19;
  }
  if (op8 == 20 || op8 == 148) {
    return 26;
  }
  return 0;
}

/**
* 从 ctx.code_data 读 little-endian u32；分步移位，避免 -E 生成 C 时 `& 255 << 8`
* 优先级错误。
*/
function elf_read_u32_le(ctx: *ElfCodegenCtx, off: i32): i32 {
  if (off < 0 || off + 3 >= ctx.code_len) {
    return 0;
  }
  let b0: i32 = ctx.code_data[off] & 255;
  let b1: i32 = ctx.code_data[off + 1] & 255;
  let b2: i32 = ctx.code_data[off + 2] & 255;
  let b3: i32 = ctx.code_data[off + 3] & 255;
  let w1: i32 = b1 << 8;
  let w2: i32 = b2 << 16;
  let w3: i32 = b3 << 24;
  return b0 | w1 | w2 | w3;
}

/** 向 ctx.code_data 写 little-endian u32。 */
function elf_write_u32_le(ctx: *ElfCodegenCtx, off: i32, word: i32): void {
  if (off < 0 || off + 3 >= ctx.code_len) {
    return;
  }
  ctx.code_data[off] = elf_u32_byte_at(word, 0);
  ctx.code_data[off + 1] = elf_u32_byte_at(word, 1);
  ctx.code_data[off + 2] = elf_u32_byte_at(word, 2);
  ctx.code_data[off + 3] = elf_u32_byte_at(word, 3);
}

/** 根据 patches 与 labels 将 .text 占位写回；实现委托 ast_pool.c（与 append_patch
* 同一 ctx 视图）。 */
function elf_resolve_patches(ctx: *ElfCodegenCtx): i32 {
  return pipeline_elf_ctx_resolve_patches(ctx as *u8);
}

/** 向 out 追加 ptr[0..n-1]，返回 0 成功，-1 缓冲区满。 */
function elf_append(out: *CodegenOutBuf, ptr: *u8, n: i32): i32 {
  let i: i32 = 0;
  while (i < n && out.len < 9437184) {
    out.data[out.len] = ptr[i];
    out.len = out.len + 1;
    i = i + 1;
  }
  if (i < n) {
    return -1;
  }
  return 0;
}

/** 将 ELF64 可重定位 .o 写入 out；调用前需已执行 elf_resolve_patches。返回写入字节数，失败返回 -1。 */
function write_elf_o_to_buf(ctx: *ElfCodegenCtx, out: *CodegenOutBuf): i32 {
  return pipeline_elf_write_o_standard_to_buf_c(ctx as *u8, out);
}
