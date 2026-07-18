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

// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.

/* See implementation. */
export extern function main_run_compiler_x_path_impl(argc: i32, argv: *u8): i32;

/** See implementation for details. */
export extern function driver_build_build_x(): i32;

/**
* See implementation.
* See implementation.
*/
export function cmd_build(argc: i32, argv: *u8): i32 {
  unsafe {
    if (argc < 2) {
      return driver_build_build_x();
    }
    return main_run_compiler_x_path_impl(argc, argv);
  }
  return 0;
}
