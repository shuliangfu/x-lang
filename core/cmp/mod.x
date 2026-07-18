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

// note
// note
// note

/* note */
export struct Ordering {
  code: i32;
}

/** Less：a < b。 */
export const ORD_LESS: i32 = -1;

/** Equal：a == b。 */
export const ORD_EQUAL: i32 = 0;

/** Greater：a > b。 */
export const ORD_GREATER: i32 = 1;

/** `ordering_less`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function ordering_less(): Ordering {
  return Ordering { code: ORD_LESS };
}

/** `ordering_equal`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function ordering_equal(): Ordering {
  return Ordering { code: ORD_EQUAL };
}

/** `ordering_greater`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function ordering_greater(): Ordering {
  return Ordering { code: ORD_GREATER };
}

/** `is_lt`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function is_lt(o: Ordering): bool {
  return o.code == ORD_LESS;
}

/** `is_eq`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function is_eq(o: Ordering): bool {
  return o.code == ORD_EQUAL;
}

/** `is_gt`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function is_gt(o: Ordering): bool {
  return o.code == ORD_GREATER;
}

/** `reverse`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function reverse(o: Ordering): Ordering {
  if (o.code == ORD_LESS) { return ordering_greater(); }
  if (o.code == ORD_GREATER) { return ordering_less(); }
  return ordering_equal();
}

/** `then`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function then(o: Ordering, other: Ordering): Ordering {
  if (o.code != ORD_EQUAL) { return o; }
  return other;
}

/** `ordering_from_i32`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function ordering_from_i32(code: i32): Ordering {
  if (code < 0) { return ordering_less(); }
  if (code > 0) { return ordering_greater(); }
  return ordering_equal();
}

/** `cmp_i32`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function cmp_i32(a: i32, b: i32): Ordering {
  if (a < b) { return ordering_less(); }
  if (a > b) { return ordering_greater(); }
  return ordering_equal();
}

/** `cmp_u8`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function cmp_u8(a: u8, b: u8): Ordering {
  let ai: i32 = a as i32;
  let bi: i32 = b as i32;
  if (ai < bi) { return ordering_less(); }
  if (ai > bi) { return ordering_greater(); }
  return ordering_equal();
}

/** `cmp_ptr`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function cmp_ptr(a: *u8, b: *u8): Ordering {
  let ua: usize = a as usize;
  let ub: usize = b as usize;
  if (ua < ub) { return ordering_less(); }
  if (ua > ub) { return ordering_greater(); }
  return ordering_equal();
}

