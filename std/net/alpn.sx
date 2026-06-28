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

// std.net.alpn — F-04 v10：ALPN 线格式（RFC 7301 h2 + http/1.1）
//
// 【文件职责】
// 从 net.c 迁出 net_tls_alpn_h2_http1_wire_c；ws/openssl/mbedtls 共用。
//
// 【依赖】无（直写 out 缓冲，避免库模块顶层/局部 u8[N] 字面量 asm emit 失败）

/**
 * 写入 h2/http/1.1 ALPN 线格式；成功返回字节数，缓冲不足返回 -1。
 * RFC 7301 字节序列：\x02h2\x08http/1.1
 */
function net_tls_alpn_h2_http1_wire_c(out: *u8, out_cap: i32): i32 {
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
