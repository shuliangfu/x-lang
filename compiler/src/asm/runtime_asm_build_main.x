// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// runtime_asm_build_main — Darwin arm64 process entry for
// src/asm/runtime_asm_build.o. A translation unit that defines main
// emits only main, so this file stays separate from
// src/asm/runtime_asm_build.x. The ensure step merges the two objects.
// main forwards argc and argv to xlang_forward_main_to_main_entry.
// This file is not asm_experimental_symbol_bridge.o.
// Linux and Windows keep host cc of seeds/runtime_asm_build.from_x.c.
// PLATFORM: MACOS|DARWIN arm64.

extern "C" function xlang_forward_main_to_main_entry(argc: i32, argv: **u8): i32;

/**
 * Process entry merged into runtime_asm_build.o.
 * @param argc i32 — process argc from crt
 * @param argv **u8 — process argv; null is forwarded, not checked here
 * @return i32 — the value xlang_forward_main_to_main_entry returns
 * PLATFORM: MACOS|DARWIN arm64.
 */
function main(argc: i32, argv: **u8): i32 {
  unsafe {
    let r: i32 = xlang_forward_main_to_main_entry(argc, argv);
    return r;
  }
  return 0;
}
