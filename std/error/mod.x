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
// See implementation.
//
// See implementation.
// See implementation.
// Rust: Result<T,E>、std::error::Error、Option；
// See implementation.
//
// See implementation.
const _core_result = import("core.result");

/** Exported function `ok`.
 * Implements `ok`.
 * @return i32
 */
export function ok(): i32 { return 0; }

/** Exported function `code_alloc_fail`.
 * Memory management helper `code_alloc_fail`.
 * @return i32
 */
export function code_alloc_fail(): i32 { return -1; }

/** Exported function `code_invalid`.
 * Implements `code_invalid`.
 * @return i32
 */
export function code_invalid(): i32 { return -2; }

/** Exported function `code_not_found`.
 * Implements `code_not_found`.
 * @return i32
 */
export function code_not_found(): i32 { return -3; }

/* See implementation. */
export struct Error {
  code: i32;
}

/** Exported function `ok_value`.
 * Implements `ok_value`.
 * @return Error
 */
export function ok_value(): Error {
  return Error { code: 0 };
}

/** Exported function `from_code`.
 * Implements `from_code`.
 * @param code i32
 * @return Error
 */
export function from_code(code: i32): Error {
  return Error { code: code };
}

/** Exported function `code`.
 * Implements `code`.
 * @param e Error
 * @return i32
 */
export function code(e: Error): i32 { return e.code; }

/** Exported function `is_ok`.
 * Query helper `is_ok`.
 * @param e Error
 * @return i32
 */
export function is_ok(e: Error): i32 {
  if (e.code == 0) { return 1; }
  return 0;
}

/** Exported function `is_err`.
 * Query helper `is_err`.
 * @param e Error
 * @return i32
 */
export function is_err(e: Error): i32 {
  if (e.code != 0) { return 1; }
  return 0;
}

// See implementation.

/** Exported function `base_io`.
 * Implements `base_io`.
 * @return i32
 */
export function base_io(): i32 { return -1000; }

/** Exported function `io_err_timeout`.
 * Implements `io_err_timeout`.
 * @return i32
 */
export function io_err_timeout(): i32 { return -1001; }

/** Exported function `io_err_cancelled`.
 * Implements `io_err_cancelled`.
 * @return i32
 */
export function io_err_cancelled(): i32 { return -1002; }

/** Exported function `io_err_generic`.
 * Implements `io_err_generic`.
 * @param ) i32 { return base_io(
 * @return void
 */
export function io_err_generic(): i32 { return base_io(); }

/** Exported function `base_net`.
 * Implements `base_net`.
 * @return i32
 */
export function base_net(): i32 { return -1200; }

/** Exported function `net_err_timeout`.
 * Implements `net_err_timeout`.
 * @return i32
 */
export function net_err_timeout(): i32 { return -1201; }

/** Exported function `net_err_cancelled`.
 * Implements `net_err_cancelled`.
 * @return i32
 */
export function net_err_cancelled(): i32 { return -1202; }

/** Exported function `net_err_generic`.
 * Implements `net_err_generic`.
 * @param ) i32 { return base_net(
 * @return void
 */
export function net_err_generic(): i32 { return base_net(); }

/** Exported function `base_async`.
 * Implements `base_async`.
 * @return i32
 */
export function base_async(): i32 { return -1300; }

/** Exported function `async_err_generic`.
 * Implements `async_err_generic`.
 * @param ) i32 { return base_async(
 * @return void
 */
export function async_err_generic(): i32 { return base_async(); }

/** Exported function `base_coll`.
 * Implements `base_coll`.
 * @return i32
 */
export function base_coll(): i32 { return -1400; }

/** Exported function `coll_err_generic`.
 * Implements `coll_err_generic`.
 * @param ) i32 { return base_coll(
 * @return void
 */
export function coll_err_generic(): i32 { return base_coll(); }

/** Exported function `base_fs`.
 * Implements `base_fs`.
 * @return i32
 */
export function base_fs(): i32 { return -1100; }

/** Exported function `fs_err_not_found`.
 * Implements `fs_err_not_found`.
 * @return i32
 */
export function fs_err_not_found(): i32 { return -1101; }

// See implementation.

/** Exported function `mod_tag_io`.
 * Implements `mod_tag_io`.
 * @return i32
 */
export function mod_tag_io(): i32 { return 1; }

/** Exported function `mod_tag_fs`.
 * Implements `mod_tag_fs`.
 * @return i32
 */
export function mod_tag_fs(): i32 { return 2; }

/** Exported function `mod_tag_db`.
 * Implements `mod_tag_db`.
 * @return i32
 */
export function mod_tag_db(): i32 { return 3; }

/** Exported function `sidecar_none`.
 * Implements `sidecar_none`.
 * @return i32
 */
export function sidecar_none(): i32 { return 0; }

/** Exported function `sidecar_errno`.
 * Implements `sidecar_errno`.
 * @return i32
 */
export function sidecar_errno(): i32 { return 1; }

/** Exported function `sidecar_db_struct`.
 * Implements `sidecar_db_struct`.
 * @return i32
 */
export function sidecar_db_struct(): i32 { return 2; }

/** Exported function `code_to_module_base`.
 * Implements `code_to_module_base`.
 * @param code i32
 * @return i32
 */
export function code_to_module_base(code: i32): i32 {
  if (code == 0) { return 0; }
  if (code <= base_io() && code > base_fs()) { return base_io(); }
  if (code <= base_fs() && code > base_net()) { return base_fs(); }
  if (code <= base_net() && code > base_async()) { return base_net(); }
  if (code <= base_async() && code > base_coll()) { return base_async(); }
  if (code <= base_coll() && code > base_coll() - 100) { return base_coll(); }
  return 0;
}

/**
 * See implementation.
 * See implementation.
 */
export function code_in_global_range(code: i32): i32 {
  if (code >= code_not_found() && code <= code_alloc_fail()) {
    return 1;
  }
  return 0;
}

/**
 * See implementation.
 * See implementation.
 */
export function code_in_module_span(code: i32, base: i32): i32 {
  if (code == 0) { return 0; }
  if (code <= base && code > base - 100) { return 1; }
  return 0;
}

/**
 * See implementation.
 * See implementation.
 */
export function code_is_platform_errno(code: i32): i32 {
  if (code > 0) { return 1; }
  return 0;
}

/** Exported function `mod_tag_from_base`.
 * Implements `mod_tag_from_base`.
 * @param base i32
 * @return i32
 */
export function mod_tag_from_base(base: i32): i32 {
  if (base == base_io()) { return mod_tag_io(); }
  if (base == base_fs()) { return mod_tag_fs(); }
  return 0;
}

/** Exported function `mod_base_from_tag`.
 * Implements `mod_base_from_tag`.
 * @param tag i32
 * @return i32
 */
export function mod_base_from_tag(tag: i32): i32 {
  if (tag == mod_tag_io()) { return base_io(); }
  if (tag == mod_tag_fs()) { return base_fs(); }
  return 0;
}

/** Exported function `module_sidecar_kind`.
 * Implements `module_sidecar_kind`.
 * @param tag i32
 * @return i32
 */
export function module_sidecar_kind(tag: i32): i32 {
  if (tag == mod_tag_io()) { return sidecar_none(); }
  if (tag == mod_tag_fs()) { return sidecar_errno(); }
  if (tag == mod_tag_db()) { return sidecar_db_struct(); }
  return sidecar_none();
}

// See implementation.

/** Exported function `sem_none`.
 * Implements `sem_none`.
 * @return i32
 */
export function sem_none(): i32 { return 0; }

/** Exported function `sem_timeout`.
 * Implements `sem_timeout`.
 * @return i32
 */
export function sem_timeout(): i32 { return 1; }

/** Exported function `sem_cancelled`.
 * Implements `sem_cancelled`.
 * @return i32
 */
export function sem_cancelled(): i32 { return 2; }

/** Exported function `sem_not_found`.
 * Implements `sem_not_found`.
 * @return i32
 */
export function sem_not_found(): i32 { return 3; }

/** Exported function `http_err_timeout`.
 * Implements `http_err_timeout`.
 * @return i32
 */
export function http_err_timeout(): i32 { return -1203; }

/** Exported function `http_err_cancelled`.
 * Implements `http_err_cancelled`.
 * @return i32
 */
export function http_err_cancelled(): i32 { return -1204; }

/** Exported function `semantic_class`.
 * Implements `semantic_class`.
 * @param code i32
 * @return i32
 */
export function semantic_class(code: i32): i32 {
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

/** Exported function `is_timeout`.
 * Query helper `is_timeout`.
 * @param code i32
 * @return i32
 */
export function is_timeout(code: i32): i32 {
  if (semantic_class(code) == sem_timeout()) { return 1; }
  return 0;
}

/** Exported function `is_cancelled`.
 * Query helper `is_cancelled`.
 * @param code i32
 * @return i32
 */
export function is_cancelled(code: i32): i32 {
  if (semantic_class(code) == sem_cancelled()) { return 1; }
  return 0;
}

/** Exported function `is_not_found`.
 * Query helper `is_not_found`.
 * @param code i32
 * @return i32
 */
export function is_not_found(code: i32): i32 {
  if (semantic_class(code) == sem_not_found()) { return 1; }
  return 0;
}

/** Exported function `recommend_retry`.
 * Implements `recommend_retry`.
 * @param code i32
 * @return i32
 */
export function recommend_retry(code: i32): i32 {
  if (is_timeout(code) != 0) { return 1; }
  return 0;
}

// See implementation.

/** Exported function `chain_max_depth`.
 * Implements `chain_max_depth`.
 * @return i32
 */
export function chain_max_depth(): i32 { return 4; }

/* See implementation. */
export struct ErrorChain {
  depth: i32;
  c0: i32;
  c1: i32;
  c2: i32;
  c3: i32;
}

/** Exported function `chain_empty`.
 * Implements `chain_empty`.
 * @return ErrorChain
 */
export function chain_empty(): ErrorChain {
  return ErrorChain { depth: 0, c0: 0, c1: 0, c2: 0, c3: 0 };
}

/** Exported function `chain_from_code`.
 * Implements `chain_from_code`.
 * @param code i32
 * @return ErrorChain
 */
export function chain_from_code(code: i32): ErrorChain {
  return ErrorChain { depth: 1, c0: code, c1: 0, c2: 0, c3: 0 };
}

/** Exported function `chain_from_result`.
 * Implements `chain_from_result`.
 * @param r Result_i32
 * @return ErrorChain
 */
export function chain_from_result(r: Result_i32): ErrorChain {
  return chain_from_code(r.err);
}

/** Exported function `chain_depth`.
 * Implements `chain_depth`.
 * @param chain ErrorChain
 * @return i32
 */
export function chain_depth(chain: ErrorChain): i32 {
  return chain.depth;
}

/** Exported function `chain_root`.
 * Implements `chain_root`.
 * @param chain ErrorChain
 * @return i32
 */
export function chain_root(chain: ErrorChain): i32 {
  if (chain.depth <= 0) { return 0; }
  return chain.c0;
}

/** Exported function `chain_code_at`.
 * Implements `chain_code_at`.
 * @param chain ErrorChain
 * @param idx i32
 * @return i32
 */
export function chain_code_at(chain: ErrorChain, idx: i32): i32 {
  if (idx == 0) { return chain.c0; }
  if (idx == 1) { return chain.c1; }
  if (idx == 2) { return chain.c2; }
  if (idx == 3) { return chain.c3; }
  return 0;
}

/** Exported function `chain_leaf`.
 * Implements `chain_leaf`.
 * @param chain ErrorChain
 * @return i32
 */
export function chain_leaf(chain: ErrorChain): i32 {
  let d: i32 = chain.depth;
  if (d <= 0) { return 0; }
  if (d == 1) { return chain.c0; }
  if (d == 2) { return chain.c1; }
  if (d == 3) { return chain.c2; }
  return chain.c3;
}

/**
 * See implementation.
 * See implementation.
 */
export function chain_wrap(chain: ErrorChain, wrapper: i32): ErrorChain {
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

/** Exported function `error_module_anchor`.
 * Implements `error_module_anchor`.
 * @return i32
 */
export function error_module_anchor(): i32 { return 0; }
