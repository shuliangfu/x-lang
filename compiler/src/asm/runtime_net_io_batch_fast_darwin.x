// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
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

// runtime_net_io_batch_fast_darwin.x — Darwin arm64 UDP batch bridges.
//
// The cold ensure path pure-asms src/asm/runtime_net_io_batch_fast.x
// (public wrappers and the weak io_* defaults) and this file, then
// ld -r. Linux keeps recvmmsg and sendmmsg in the C seed. Darwin has
// no recvmmsg or sendmmsg; both bridges return -1, matching that seed.
//
// PLATFORM: MACOS|DARWIN arm64.

/** Darwin UDP batch receive. recvmmsg is Linux-only, so this returns -1.
 * The thin wrapper already rejected n outside 1..8 and null buffers.
 * @param fd UDP socket; ignored
 * @param bufs Buffer slice pointer; ignored
 * @param n buffer count; ignored
 * @param timeout_ms wait in milliseconds; ignored
 * @param out_sizes received sizes; ignored
 * @param out_addrs source addresses; ignored
 * @param out_ports source ports; ignored
 * @return -1
 * PLATFORM: MACOS|DARWIN arm64
 */
#[no_mangle]
export function net_udp_recv_many_buf_impl_c(fd: i32, bufs: *u8, n: i32, timeout_ms: u32, out_sizes: *i32, out_addrs: *u32, out_ports: *u32): i32 {
  return 0 - 1;
}

/** Darwin UDP batch send. sendmmsg is Linux-only, so this returns -1.
 * The thin wrapper already rejected n outside 1..8 and null buffers.
 * @param fd UDP socket; ignored
 * @param addrs destination addresses; ignored
 * @param ports destination ports; ignored
 * @param bufs Buffer slice pointer; ignored
 * @param n buffer count; ignored
 * @return -1
 * PLATFORM: MACOS|DARWIN arm64
 */
#[no_mangle]
export function net_udp_send_many_buf_impl_c(fd: i32, addrs: *u32, ports: *u32, bufs: *u8, n: i32): i32 {
  return 0 - 1;
}
