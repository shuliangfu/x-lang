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

// std.error — 错误类型与传播（对标 Zig std.mem.Allocator.Error、Rust Result/error、Go error）
//
// 【文件职责】
// 提供错误码类型 Error、ok/from_code/code/is_ok/is_err、与 io/fs
// 等返回的错误码约定一致；EXC-004 ErrorChain 上下文链。
//
// 【对标】
// Zig: 错误集、Allocator.Error、anyerror；
// Rust: Result<T,E>、std::error::Error、Option；
// Go: error 接口、errors.New、nil。
//
// import core.result — ErrorChain 与 Result_i32 互操作（EXC-004）
const _core_result = import("core.result");

/** 错误码 0 表示无错误；非 0 表示错误（正/负由各模块约定，如 io/fs 用负表示错误）。 */
function ok(): i32 { return 0; }

/** 常用错误码：分配失败（与 std.heap/vec/map 一致）。 */
function code_alloc_fail(): i32 { return -1; }

/** 常用错误码：无效参数或越界。 */
function code_invalid(): i32 { return -2; }

/** 常用错误码：未找到（如 map get 无默认、文件不存在等）。 */
function code_not_found(): i32 { return -3; }

/** 错误类型：仅含 code（i32）；0 表示成功。 */
struct Error {
  code: i32;
}

/** 构造“无错误”。 */
function ok_value(): Error {
  return Error { code: 0 };
}

/** 从错误码构造 Error。 */
function from_code(code: i32): Error {
  return Error { code: code };
}

/** 取错误码。 */
function code(e: Error): i32 { return e.code; }

/** 是否表示成功（code == 0）。返回 1 是，0 否。 */
function is_ok(e: Error): i32 {
  if (e.code == 0) { return 1; }
  return 0;
}

/** 是否表示错误（code != 0）。返回 1 是，0 否。 */
function is_err(e: Error): i32 {
  if (e.code != 0) { return 1; }
  return 0;
}

// ——— B 层模块错误码（STD-091/092 Context 联动；完整分层见 EXC-003） ———

/** std.io 模块错误段起点。 */
function base_io(): i32 { return -1000; }

/** I/O 超时（Context deadline 或 wait 超时）。 */
function io_err_timeout(): i32 { return -1001; }

/** I/O 已取消（Context cancel）。 */
function io_err_cancelled(): i32 { return -1002; }

/** std.io 模块通用错误码（段起点占位，STD-011 / EXC-003）。 */
function io_err_generic(): i32 { return base_io(); }

/** std.net 模块错误段起点。 */
function base_net(): i32 { return -1200; }

/** 网络操作超时。 */
function net_err_timeout(): i32 { return -1201; }

/** 网络操作已取消。 */
function net_err_cancelled(): i32 { return -1202; }

/** std.net 模块通用错误码（段起点占位，STD-011）。 */
function net_err_generic(): i32 { return base_net(); }

/** std.async 模块错误段起点（EXC-003）。 */
function base_async(): i32 { return -1300; }

/** std.async 模块通用错误码占位。 */
function async_err_generic(): i32 { return base_async(); }

/** std.coll（vec/map/heap）模块错误段起点（EXC-003）。 */
function base_coll(): i32 { return -1400; }

/** std.coll 模块通用错误码占位。 */
function coll_err_generic(): i32 { return base_coll(); }

/** std.fs 模块错误段起点。 */
function base_fs(): i32 { return -1100; }

/** 文件/路径不存在。 */
function fs_err_not_found(): i32 { return -1101; }

// ——— STD-020：错误码 → 模块 base / 侧车种类 ———

/** 模块标签：std.io。 */
function mod_tag_io(): i32 { return 1; }

/** 模块标签：std.fs。 */
function mod_tag_fs(): i32 { return 2; }

/** 模块标签：std.db（无 B 层 base v1）。 */
function mod_tag_db(): i32 { return 3; }

/** 侧车种类：无。 */
function sidecar_none(): i32 { return 0; }

/** 侧车种类：errno i32（如 fs_last_error）。 */
function sidecar_errno(): i32 { return 1; }

/** 侧车种类：DbError 结构体。 */
function sidecar_db_struct(): i32 { return 2; }

/** 负码 → 所属 base_*；L 层/未知 → 0。 */
function code_to_module_base(code: i32): i32 {
  if (code == 0) { return 0; }
  if (code <= base_io() && code > base_fs()) { return base_io(); }
  if (code <= base_fs() && code > base_net()) { return base_fs(); }
  if (code <= base_net() && code > base_async()) { return base_net(); }
  if (code <= base_async() && code > base_coll()) { return base_async(); }
  if (code <= base_coll() && code > base_coll() - 100) { return base_coll(); }
  return 0;
}

/**
 * L 层全局码区间判定：-3..-1（code_alloc_fail/invalid/not_found）。
 * 返回 1 在区间内，0 否。
 */
function code_in_global_range(code: i32): i32 {
  if (code >= code_not_found() && code <= code_alloc_fail()) {
    return 1;
  }
  return 0;
}

/**
 * B 层模块段判定：code 落在 (base-100, base]。
 * 返回 1 在段内，0 否。
 */
function code_in_module_span(code: i32, base: i32): i32 {
  if (code == 0) { return 0; }
  if (code <= base && code > base - 100) { return 1; }
  return 0;
}

/**
 * S 层平台 errno 判定：正整数视为宿主 errno（如 fs_last_error）。
 * 返回 1 是 errno，0 否。
 */
function code_is_platform_errno(code: i32): i32 {
  if (code > 0) { return 1; }
  return 0;
}

/** base → 模块标签；未知 base → 0。 */
function mod_tag_from_base(base: i32): i32 {
  if (base == base_io()) { return mod_tag_io(); }
  if (base == base_fs()) { return mod_tag_fs(); }
  return 0;
}

/** 标签 → base；db 等无 B 层段 → 0。 */
function mod_base_from_tag(tag: i32): i32 {
  if (tag == mod_tag_io()) { return base_io(); }
  if (tag == mod_tag_fs()) { return base_fs(); }
  return 0;
}

/** 模块标签 → last_error 侧车种类。 */
function module_sidecar_kind(tag: i32): i32 {
  if (tag == mod_tag_io()) { return sidecar_none(); }
  if (tag == mod_tag_fs()) { return sidecar_errno(); }
  if (tag == mod_tag_db()) { return sidecar_db_struct(); }
  return sidecar_none();
}

// ——— STD-158：跨模块语义类 ———

/** 语义类：无/未知。 */
function sem_none(): i32 { return 0; }

/** 语义类：超时。 */
function sem_timeout(): i32 { return 1; }

/** 语义类：取消。 */
function sem_cancelled(): i32 { return 2; }

/** 语义类：未找到。 */
function sem_not_found(): i32 { return 3; }

/** std.http 超时（映射 net 段）。 */
function http_err_timeout(): i32 { return -1203; }

/** std.http 取消（映射 net 段）。 */
function http_err_cancelled(): i32 { return -1204; }

/** 错误码 → 跨模块语义类。 */
function semantic_class(code: i32): i32 {
  if (code == io_err_timeout() || code == net_err_timeout() || code == http_err_timeout()) {
    return sem_timeout();
  }
  if (code == io_err_cancelled() || code == net_err_cancelled() || code == http_err_cancelled()) {
    return sem_cancelled();
  }
  if (code == fs_err_not_found() || code == code_not_found()) {
    return sem_not_found();
  }
  return sem_none();
}

/** 是否为超时语义（1/0）。 */
function is_timeout(code: i32): i32 {
  if (semantic_class(code) == sem_timeout()) { return 1; }
  return 0;
}

/** 是否为取消语义（1/0）。 */
function is_cancelled(code: i32): i32 {
  if (semantic_class(code) == sem_cancelled()) { return 1; }
  return 0;
}

/** 是否为未找到语义（1/0）。 */
function is_not_found(code: i32): i32 {
  if (semantic_class(code) == sem_not_found()) { return 1; }
  return 0;
}

/** v1：仅超时建议重试（1/0）。 */
function recommend_retry(code: i32): i32 {
  if (is_timeout(code) != 0) { return 1; }
  return 0;
}

// ——— EXC-004：ErrorChain 固定深度错误链（零堆 v1） ———

/** ErrorChain 最大深度（栈上 c0..c3）。 */
function chain_max_depth(): i32 { return 4; }

/** 错误链：c0 为 root（最近 wrap），向内至 leaf。 */
struct ErrorChain {
  depth: i32;
  c0: i32;
  c1: i32;
  c2: i32;
  c3: i32;
}

/** 空链（depth=0）。 */
function chain_empty(): ErrorChain {
  return ErrorChain { depth: 0, c0: 0, c1: 0, c2: 0, c3: 0 };
}

/** 单码链。 */
function chain_from_code(code: i32): ErrorChain {
  return ErrorChain { depth: 1, c0: code, c1: 0, c2: 0, c3: 0 };
}

/** 自 Result_i32.err 构造单节点链。 */
function chain_from_result(r: Result_i32): ErrorChain {
  return chain_from_code(r.err);
}

/** 链深度 0..max。 */
function chain_depth(chain: ErrorChain): i32 {
  return chain.depth;
}

/** 最外层码（c0）；空链返回 0。 */
function chain_root(chain: ErrorChain): i32 {
  if (chain.depth <= 0) { return 0; }
  return chain.c0;
}

/** 按外→内下标取码；越界返回 0。 */
function chain_code_at(chain: ErrorChain, idx: i32): i32 {
  if (idx == 0) { return chain.c0; }
  if (idx == 1) { return chain.c1; }
  if (idx == 2) { return chain.c2; }
  if (idx == 3) { return chain.c3; }
  return 0;
}

/** 最内层根因码；空链返回 0。 */
function chain_leaf(chain: ErrorChain): i32 {
  let d: i32 = chain.depth;
  if (d <= 0) { return 0; }
  if (d == 1) { return chain.c0; }
  if (d == 2) { return chain.c1; }
  if (d == 3) { return chain.c2; }
  return chain.c3;
}

/**
 * 在 root 侧追加 wrapper；超深时丢弃最旧 leaf（c3 侧）。
 * 顺序：root=c0（新 wrapper）→ … → leaf。
 */
function chain_wrap(chain: ErrorChain, wrapper: i32): ErrorChain {
  let d: i32 = chain.depth;
  let max_d: i32 = chain_max_depth();
  if (d <= 0) {
    return chain_from_code(wrapper);
  }
  if (d >= max_d) {
    return ErrorChain {
      depth: max_d,
      c0: wrapper,
      c1: chain.c0,
      c2: chain.c1,
      c3: chain.c2,
    };
  }
  if (d == 1) {
    return ErrorChain { depth: 2, c0: wrapper, c1: chain.c0, c2: 0, c3: 0 };
  }
  if (d == 2) {
    return ErrorChain { depth: 3, c0: wrapper, c1: chain.c0, c2: chain.c1, c3: 0 };
  }
  return ErrorChain { depth: 4, c0: wrapper, c1: chain.c0, c2: chain.c1, c3: chain.c2 };
}

/** 模块尾占位：transitive import 解析时末位 function 会丢失，须保留非 API 锚点。 */
function error_module_anchor(): i32 { return 0; }
