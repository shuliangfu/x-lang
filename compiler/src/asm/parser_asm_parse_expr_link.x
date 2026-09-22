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

// parser_asm_parse_expr_link.x — G-02f-333 / Class AG
// Class AG: Cap getenv debug gate retired (always off). Seed rest keeps
// parse_expr_into bridge without Cap IO.
// PLATFORM: SHARED freestanding.

/** Doc anchor (keeps TU non-empty for cold tooling). */
export function parser_asm_parse_expr_link_x_doc_anchor(): i32 {
  return 0;
}

/**
 * Whether XLANG_PARSER_ASM_DEBUG enables parser-asm parse_expr debug.
 * Class AG: always 0 — Cap link_abi_getenv face retired from this leaf.
 * @return i32 — always 0
 * PLATFORM: SHARED
 */
#[no_mangle]
export function parser_asm_parse_expr_debug_enabled(): i32 {
  return 0;
}
