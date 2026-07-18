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
// See implementation.

/* See implementation. */
extern "C" function WSAStartup(wVersionRequested: u16, lpWSAData: *u8): i32;

/* See implementation. */
extern "C" function WSACleanup(): i32;

/** MAKEWORD(2, 2) = 0x0202。 */
export const WIN32_WSA_VERSION_2_2: u16 = 0x0202;

/* See implementation. */
export const WIN32_WSA_DATA_BYTES: i32 = 512;

/**
 * See implementation.
 * See implementation.
 */
export function win32_net_available(): i32 {
  let wsa: u8[512] = [];
  unsafe {
    if (WSAStartup(WIN32_WSA_VERSION_2_2, &wsa[0]) != 0) {
      return 0;
    }
    WSACleanup();
  }
  return 1;
}
