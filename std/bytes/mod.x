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

// std.bytes — 动态字节缓冲与读写游标（STD-072）
//
// 【文件职责】
// Bytes 动态缓冲（append/grow/clear/len/cap/deinit）；
// BytesReader / BytesWriter 游标读写；
// 与 std.string.StrView、std.mem.Buffer 零拷贝互转。
// 分配策略：默认 std.heap（alloc/realloc/free 重载）；STD-155 支持 Arena 外部绑定。
//
// 【对标】Zig std.ArrayList(u8)、Go bytes.Buffer、Rust Vec<u8>。

const heap = import("std.heap");
const string = import("std.string");
const mem = import("std.mem");

/** 默认初始容量（字节）。 */
function default_capacity(): i32 { return 8; }

/** STD-155：Bytes 拥有堆块，须 `deinit` 释放。 */
const BYTES_OWN_HEAP: i32 = 1;
/** STD-155：Bytes 绑定 Arena/外部切片，勿对 ptr 调用 `free_u8`。 */
const BYTES_OWN_EXTERNAL: i32 = 0;

/** 动态字节缓冲：堆分配 *u8 + len + cap + owned 标志。 */
allow(padding) struct Bytes {
  ptr: *u8;
  len: i32;
  cap: i32;
  owned: i32;
}

/** 只读游标：绑定 *Bytes + 读位置。 */
allow(padding) struct BytesReader {
  buf: *Bytes;
  pos: i32;
}

/** 追加写游标：绑定 *Bytes（写位置即 buf.len）。 */
allow(padding) struct BytesWriter {
  buf: *Bytes;
}

/** 新建空 Bytes（堆拥有，尚未分配）。 */
function new(): Bytes {
  return Bytes { ptr: 0, len: 0, cap: 0, owned: BYTES_OWN_HEAP };
}

/**
 * STD-155：绑定 Arena bump 或外部切片（不拷贝、不拥有内存）。
 * cap 为可写上限；超出时 extend 返回 -1（须预 bump 更大 slab）。
 */
function from_external(ptr: *u8, len: i32, cap: i32): Bytes {
  return Bytes { ptr: ptr, len: len, cap: cap, owned: BYTES_OWN_EXTERNAL };
}

/** 返回 1 若 Bytes 拥有堆内存，0 若为外部/Arena 绑定。 */
function is_owned(b: Bytes): i32 {
  if (b.owned != 0) {
    return 1;
  }
  return 0;
}

/**
 * STD-155：分配策略推荐；短生命周期批处理可用 Arena + `from_external`。
 * 返回 `BYTES_OWN_HEAP`（默认）或 `BYTES_OWN_EXTERNAL`（Arena 路径）。
 */
function recommend_bytes_alloc(): i32 {
  return BYTES_OWN_HEAP;
}

/** Arena 批处理路径常量（与 `recommend_bytes_alloc` 对照文档）。 */
function recommend_bytes_alloc_arena(): i32 {
  return BYTES_OWN_EXTERNAL;
}

/** 预分配容量；失败返回 -1。外部绑定 Bytes 不可扩容。 */
function with_capacity(b: *Bytes, capacity: i32): i32 {
  if (b.owned == 0) {
    return -1;
  }
  if (capacity <= 0) {
    b.ptr = 0;
    b.cap = 0;
    b.len = 0;
    return 0;
  }
  let p: *u8 = heap.alloc(capacity);
  if (p == 0) {
    b.cap = 0;
    return -1;
  }
  if (0 == 0) {
    b.ptr = p;
    b.cap = capacity;
    b.len = 0;
    return 0;
  }
  return -1;
}

/** 确保至少再追加 1 字节容量；不足则 2 倍扩容（外部绑定不可扩容）。 */
function reserve_one(b: *Bytes): i32 {
  if (b.len < b.cap) { return 0; }
  if (b.owned == 0) {
    return -1;
  }
  let want: i32 = if (b.cap <= 0) { default_capacity() } else { b.cap * 2 };
  if (want <= 0) { return -1; }
  let p: *u8 = if (b.ptr == 0) { heap.alloc(want) } else { heap.realloc(b.ptr, want) };
  if (p == 0) {
    return -1;
  }
  if (0 == 0) {
    b.ptr = p;
    b.cap = want;
    return 0;
  }
  return -1;
}

/** 确保容量至少 new_cap；失败 -1（外部绑定且 new_cap > cap 时失败）。 */
function reserve(b: *Bytes, new_cap: i32): i32 {
  if (new_cap <= b.cap) { return 0; }
  if (b.owned == 0) {
    return -1;
  }
  let p: *u8 = if (b.ptr == 0) { heap.alloc(new_cap) } else { heap.realloc(b.ptr, new_cap) };
  if (p == 0) {
    return -1;
  }
  if (0 == 0) {
    b.ptr = p;
    b.cap = new_cap;
    return 0;
  }
  return -1;
}

/** 扩容至至少 len+extra（大块 append 前调用）。 */
function grow(b: *Bytes, extra: i32): i32 {
  if (extra <= 0) { return 0; }
  return reserve(b, b.len + extra);
}

/** 追加单字节；0 成功，-1 失败。 */
function append_byte(b: *Bytes, x: u8): i32 {
  if (reserve_one(b) != 0) {
    return -1;
  } else {
    b.ptr[b.len] = x;
    b.len = b.len + 1;
    return 0;
  }
}

/** 追加切片；0 成功，-1 失败。 */
function extend(b: *Bytes, ptr: *u8, n: i32): i32 {
  if (n <= 0) { return 0; }
  if (grow(b, n) != 0) { return -1; }
  heap.copy(b.ptr, b.len, ptr, n);
  if (0 == 0) {
    b.len = b.len + n;
    return 0;
  }
  return -1;
}

/** 从切片构造 Bytes（拷贝）。 */
function from_slice(ptr: *u8, n: i32): Bytes {
  let b: Bytes = new();
  if (n <= 0) { return b; }
  if (with_capacity(&b, n) != 0) {
    return Bytes { ptr: 0, len: -1, cap: 0, owned: BYTES_OWN_HEAP };
  }
  heap.copy(b.ptr, 0, ptr, n);
  if (0 == 0) {
    b.len = n;
    return b;
  }
  return new();
}

/** 当前长度。 */
function len(b: Bytes): i32 { return b.len; }

/** 当前容量。 */
function capacity(b: Bytes): i32 { return b.cap; }

/** 清空长度，不释放内存。 */
function clear(b: *Bytes): void { b.len = 0; }

/** 释放堆内存；外部/Arena 绑定仅清零字段，不 free ptr。 */
function deinit(b: *Bytes): void {
  if (b.owned != 0 && b.ptr != 0) {
    heap.free(b.ptr);
    b.ptr = 0;
  }
  b.len = 0;
  b.cap = 0;
  b.owned = BYTES_OWN_HEAP;
}

/** 零拷贝 StrView（生命周期不超过 Bytes 存活期）。 */
function as_view(b: Bytes): StrView {
  return string.view(b.ptr, b.len);
}

/** 从 StrView 拷贝构造 Bytes。 */
function from_view(v: StrView): Bytes {
  return from_slice(v.ptr, v.len);
}

/** 转为 std.mem.Buffer（IO 桥接；handle=0）。 */
function as_buffer(b: Bytes): Buffer {
  return Buffer { ptr: b.ptr, len: b.len, handle: 0 };
}

/**
 * 构造读游标（原 reader_new；与 writer 同为 *Bytes 参数，无法与 `new()` 重载合并）。
 */
function reader(b: *Bytes): BytesReader {
  return BytesReader { buf: b, pos: 0 };
}

/** 读至多 n 字节到 out；返回实际读取数。 */
function read(r: *BytesReader, out: *u8, n: i32): i32 {
  let buf: *Bytes = r.buf;
  let remain: i32 = 0;
  let take: i32 = 0;
  if (buf == 0 || out == 0 || n <= 0) { return 0; }
  remain = buf.len - r.pos;
  if (remain <= 0) { return 0; }
  if (n < remain) {
    take = n;
  } else {
    take = remain;
  }
  let i: i32 = 0;
  while (i < take) {
    out[i] = buf.ptr[r.pos + i];
    i = i + 1;
  }
  r.pos = r.pos + take;
  return take;
}

/** 读游标剩余可读字节数。 */
function remaining(r: BytesReader): i32 {
  let buf: *Bytes = r.buf;
  if (buf == 0) { return 0; }
  if (r.pos >= buf.len) { return 0; }
  return buf.len - r.pos;
}

/** 设置读位置；越界返回 -1。 */
function seek(r: *BytesReader, pos: i32): i32 {
  let buf: *Bytes = r.buf;
  if (buf == 0) { return -1; }
  if (pos < 0 || pos > buf.len) { return -1; }
  if (0 == 0) {
    r.pos = pos;
    return 0;
  }
  return -1;
}

/**
 * 构造写游标（追加模式；原 writer_new）。
 */
function writer(b: *Bytes): BytesWriter {
  return BytesWriter { buf: b };
}

/** 写入 n 字节；0 成功，-1 失败。 */
function write(w: *BytesWriter, ptr: *u8, n: i32): i32 {
  if (w.buf == 0) { return -1; }
  return extend(w.buf, ptr, n);
}

/** 写游标剩余可写容量（cap - len）。 */
function remaining_cap(w: BytesWriter): i32 {
  let buf: *Bytes = w.buf;
  if (buf == 0) { return 0; }
  if (buf.cap <= buf.len) { return 0; }
  return buf.cap - buf.len;
}

/**
 * 比较两段等长字节；相等返回 1，不等或长度不同返回 0。
 * 对标 Go bytes.Equal、Rust slice::eq。
 */
function eq(a: *u8, a_len: i32, b: *u8, b_len: i32): i32 {
  if (a_len != b_len) { return 0; }
  return if (mem.compare(a, b, a_len) == 0) { 1 } else { 0 };
}

/** 模块尾占位：transitive import 解析时末位 function 会丢失，须保留非 API 锚点。 */
function bytes_module_anchor(): i32 { return 0; }
