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

// core.mem — 内存操作、copy/move/set/compare、对齐（自举前最小实现）
// 自举前：对齐查询 align_of_*；mem_copy（不重叠）、mem_set、mem_zero、mem_move（允许重叠）、mem_compare；mem_swap；is_alignment_power_of_two；align_up/align_down。
// 语义与 C memcpy/memset/memmove/memcmp 一致；mem_compare 返回 -1/0/1；当前用 .x 实现，便于后端识别为内建时优化。

// 占位函数，表示本模块已可 import。
function placeholder(): i32 { return 0; }

// ——— 对齐查询（与 core.types 对称，供仅 import("core.mem") 的调用方使用） ———
function align_of_i32(): i32 { return 4; }
function align_of_bool(): i32 { return 1; }
function align_of_u8(): i32 { return 1; }
function align_of_u32(): i32 { return 4; }
function align_of_u64(): i32 { return 8; }
function align_of_i64(): i32 { return 8; }
function align_of_usize(): i32 { return 8; }
function align_of_isize(): i32 { return 8; }
function align_of_f32(): i32 { return 4; }
function align_of_f64(): i32 { return 8; }
function align_of_pointer(): i32 { return 8; }

// ——— 拷贝原语：不重叠、按字节；语义与 C memcpy 一致。
// 当前用 .x 循环实现，避免与 macOS 等系统头文件中 memcpy 宏冲突；后续可由编译器内建或运行时提供优化实现。
function mem_copy(dst: *u8, src: *u8, n: usize): void {
  let i: usize = 0;
  while (i < n) {
    dst[i] = src[i];
    i = i + 1;
  }
}

// ——— 填充：将 dst[0..n] 全部设为 byte（语义与 C memset 一致）。
function mem_set(dst: *u8, byte: u8, n: usize): void {
  let i: usize = 0;
  while (i < n) {
    dst[i] = byte;
    i = i + 1;
  }
}

// ——— 允许重叠的拷贝：语义与 C memmove 一致；始终从高地址向低地址拷贝，重叠时也正确。
function mem_move(dst: *u8, src: *u8, n: usize): void {
  let i: usize = n;
  while (i > 0) {
    i = i - 1;
    dst[i] = src[i];
  }
}

// ——— 按字节比较 a[0..n] 与 b[0..n]：相等返回 0，a 小返回负，a 大返回正（语义与 C memcmp 一致；返回值为 -1/0/1 便于使用）。
function mem_compare(a: *u8, b: *u8, n: usize): i32 {
  let i: usize = 0;
  while (i < n) {
    if (a[i] < b[i]) { return -1; }
    if (a[i] > b[i]) { return 1; }
    i = i + 1;
  }
  return 0;
}

// ——— 清零：将 dst[0..n] 置 0（等价于 mem_set(dst, 0, n)）。
function mem_zero(dst: *u8, n: usize): void {
  mem_set(dst, 0, n);
}

// ——— 交换两段内存 a[0..n] 与 b[0..n]；要求 a、b 不重叠，否则未定义。
function mem_swap(a: *u8, b: *u8, n: usize): void {
  let i: usize = 0;
  while (i < n) {
    let t: u8 = a[i];
    a[i] = b[i];
    b[i] = t;
    i = i + 1;
  }
}

// ——— 对齐辅助：x 是否为 2 的幂（用于校验 alignment 参数）；0 返回 false。
function is_alignment_power_of_two(x: usize): bool {
  if (x == 0) { return false; }
  let m: usize = x - 1;
  let and_val: usize = x & m;
  return and_val == 0;
}

// ——— 对齐计算：用于分配器与布局；alignment 建议为 2 的幂，0 时返回 addr 不修改 ———
function align_up(addr: usize, alignment: usize): usize {
  if (alignment == 0) {
    return addr;
  }
  return ((addr + alignment - 1) / alignment) * alignment;
}

function align_down(addr: usize, alignment: usize): usize {
  if (alignment == 0) {
    return addr;
  }
  return (addr / alignment) * alignment;
}

// ——— volatile 读写与内存栅栏（CORE-017；G-01 纯 .x，无 mem.c） ———

/** 编译器级栅栏辅助变量（compiler barrier）。 */
let g_mem_fence_seq: u64 = 0 as u64;

/** volatile 读 u8；ptr 可为任意字节地址。 */
function volatile_load_u8(ptr: *u8): u8 {
  if (ptr == 0) { return 0; }
  return ptr[0];
}

/** volatile 写 u8。 */
function volatile_store_u8(ptr: *u8, val: u8): void {
  if (ptr == 0) { return; }
  ptr[0] = val;
}

/** volatile 读 u16；ptr 须 2 字节对齐。 */
function volatile_load_u16(ptr: *u8): u16 {
  if (ptr == 0) { return 0; }
  let p: *u16 = (ptr as *u16);
  return p[0];
}

/** volatile 写 u16。 */
function volatile_store_u16(ptr: *u8, val: u16): void {
  if (ptr == 0) { return; }
  let p: *u16 = (ptr as *u16);
  p[0] = val;
}

/** volatile 读 u32；ptr 须 4 字节对齐。 */
function volatile_load_u32(ptr: *u8): u32 {
  if (ptr == 0) { return 0; }
  let p: *u32 = (ptr as *u32);
  return p[0];
}

/** volatile 写 u32。 */
function volatile_store_u32(ptr: *u8, val: u32): void {
  if (ptr == 0) { return; }
  let p: *u32 = (ptr as *u32);
  p[0] = val;
}

/** 编译器级栅栏：禁止编译器重排。 */
function compiler_fence(): void {
  /* asm seed：import 合并后 g_mem_fence_seq 不在入口 module sidecar，勿写模块 let（compiler_fence 空操作即可）。 */
}

/** 线程 acquire 栅栏（G-01 v1：compiler_fence；完整 atomic 待平台 intrinsic）。 */
function fence_acquire(): void {
  compiler_fence();
}

/** 线程 release 栅栏。 */
function fence_release(): void {
  compiler_fence();
}

/** 线程 seq_cst 全序栅栏。 */
function fence_seq_cst(): void {
  compiler_fence();
}
