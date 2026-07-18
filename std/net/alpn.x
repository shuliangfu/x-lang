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
//
// See implementation.

/**
 * See implementation.
 * See implementation.
 */
export function net_tls_alpn_h2_http1_wire_c(out: *u8, out_cap: i32): i32 {
  if (out == 0 || out_cap < 12) {
    return -1;
  }
  out[0] = 2;
  out[1] = 104;
  out[2] = 50;
  out[3] = 8;
  out[4] = 104;
  out[5] = 116;
  out[6] = 116;
  out[7] = 112;
  out[8] = 47;
  out[9] = 49;
  out[10] = 46;
  out[11] = 49;
  return 12;
}
