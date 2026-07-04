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

// std.sys.win32_net — B-18 v1 / F-02 v2：Windows 网络栈探测（WSA；async IOCP 见 std.io）
//
// 【文件职责】
// std.sys 层 win32 网络可用性门面；不实现完整 socket/IOCP。
//
// 【链接】
// F-02 v2：直接 extern ws2_32.dll（无 win32_net.inc.c）。

/** winsock2 WSAStartup；0 成功。 */
extern function WSAStartup(wVersionRequested: u16, lpWSAData: *u8): i32;

/** winsock2 WSACleanup；0 成功。 */
extern function WSACleanup(): i32;

/** MAKEWORD(2, 2) = 0x0202。 */
const WIN32_WSA_VERSION_2_2: u16 = 0x0202;

/** WSADATA 栈缓冲字节数（大于 Winsock2 结构体实际尺寸）。 */
const WIN32_WSA_DATA_BYTES: i32 = 512;

/**
 * 返回 1 表示 Windows 网络栈（WSA）可用。
 * 探测：WSAStartup → WSACleanup 成功即视为可用。
 */
function win32_net_available(): i32 {
  let wsa: u8[512] = [];
  unsafe {
    if (WSAStartup(WIN32_WSA_VERSION_2_2, &wsa[0]) != 0) {
      return 0;
    }
    WSACleanup();
  }
  return 1;
}
