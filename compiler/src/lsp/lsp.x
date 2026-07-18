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
//
// See implementation.
// See implementation.
// See implementation.
// capabilities）、initialized、textDocument/didOpen、didChange、didSave、didClose、
//
// See implementation.
// ymbol、
// semanticTokens、rename、shutdown、exit、$/cancelRequest、workspace/didChangeConfiguration。
// See implementation.

// Cap-T001 / LANG-007 S0: exports that call C glue or lsp_io surface use
// whole-body unsafe (PLATFORM: SHARED). M1 typeck for T KPI.

const lsp_io = import("lsp_io");

/** See implementation for details. */
let LSP_BODY_CAP: i32 = 1048576;

/* See implementation. */
let LSP_STATE_SIZE: i32 = 4 + 8192 * 2;

/** See implementation for details. */
let LSP_DIAG_RESP_CAP: i32 = 32768;
let LSP_REF_RESP_CAP: i32 = 8192;
let LSP_FORMAT_RESP_CAP: i32 = 262144;

/* See implementation. */
export extern function lsp_state_buf_ptr(): *u8;

/* See implementation. */
export extern function lsp_write_all(fd: i32, ptr: *u8, len: i32): i32;

/* See implementation. */
export extern function lsp_build_initialize_result(id_val: i32, out_buf: *u8, out_cap: i32): i32;
/** See implementation for details. */
export extern function lsp_build_diagnostics_response(id_val: i32, source: *u8, source_len: i32, out_buf:
*u8, out_cap: i32): i32;
/** See implementation for details. */
export extern function lsp_build_definition_response(id_val: i32, body: *u8, body_len: i32, doc_buf: *u8,
doc_len: i32, out_buf: *u8, out_cap: i32): i32;
/** See implementation for details. */
export extern function lsp_build_references_response(id_val: i32, body: *u8, body_len: i32, doc_buf: *u8,
doc_len: i32, out_buf: *u8, out_cap: i32): i32;
/** See implementation for details. */
export extern function lsp_build_hover_response(id_val: i32, body: *u8, body_len: i32, doc_buf: *u8,
doc_len: i32, out_buf: *u8, out_cap: i32): i32;
/** See implementation for details. */
export extern function lsp_build_formatting_response(id_val: i32, body: *u8, body_len: i32, doc_buf: *u8,
doc_len: i32, out_buf: *u8, out_cap: i32): i32;
/** See implementation for details. */
export extern function lsp_build_completion_response(id_val: i32, body: *u8, body_len: i32, doc_buf: *u8,
doc_len: i32, out_buf: *u8, out_cap: i32): i32;
/** See implementation for details. */
export extern function lsp_build_document_symbol_response(id_val: i32, body: *u8, body_len: i32, doc_buf:
*u8, doc_len: i32, out_buf: *u8, out_cap: i32): i32;
/** See implementation for details. */
export extern function lsp_build_semantic_tokens_response(id_val: i32, doc_buf: *u8, doc_len: i32,
out_buf: *u8, out_cap: i32): i32;
/* See implementation. */
export extern function lsp_build_rename_response(id_val: i32, body: *u8, body_len: i32, doc_buf: *u8,
doc_len: i32, out_buf: *u8, out_cap: i32): i32;
/* See implementation. */
export extern function lsp_diag_invalidate_cache(): void;
/** See implementation for details. */
export extern function lsp_build_response_with_result(id_val: i32, result_ptr: *u8, result_len: i32,
out_buf: *u8, out_cap: i32): i32;
/** See implementation for details. */
export extern function lsp_set_document_from_body(body: *u8, body_len: i32): void;
/* See implementation. */
export extern function lsp_get_document_ptr(): *u8;
/* See implementation. */
export extern function lsp_get_document_len(): i32;

/** Exported function `lsp_body_contains_initialize`.
 * Implements `lsp_body_contains_initialize`.
 * @param body *u8
 * @param len i32
 * @return i32
 */
export function lsp_body_contains_initialize(body: *u8, len: i32): i32 {
  let i: i32 = 0;
  while (i + 10 <= len) {
    if (body[i] == 105 && body[i + 1] == 110 && body[i + 2] == 105 && body[i + 3] == 116 && body[i
    + 4] == 105 && body[i + 5] == 97 && body[i + 6] == 108 && body[i + 7] == 105 && body[i + 8] ==
    122 && body[i + 9] == 101) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

/** Exported function `lsp_body_contains_initialized`.
 * Implements `lsp_body_contains_initialized`.
 * @param body *u8
 * @param len i32
 * @return i32
 */
export function lsp_body_contains_initialized(body: *u8, len: i32): i32 {
  let i: i32 = 0;
  while (i + 11 <= len) {
    if (body[i] == 105 && body[i + 1] == 110 && body[i + 2] == 105 && body[i + 3] == 116 && body[i
    + 4] == 105 && body[i + 5] == 97 && body[i + 6] == 108 && body[i + 7] == 105 && body[i + 8] ==
    122 && body[i + 9] == 101 && body[i + 10] == 100) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

/** Exported function `lsp_body_contains_shutdown`.
 * Implements `lsp_body_contains_shutdown`.
 * @param body *u8
 * @param len i32
 * @return i32
 */
export function lsp_body_contains_shutdown(body: *u8, len: i32): i32 {
  let i: i32 = 0;
  while (i + 8 <= len) {
    if (body[i] == 115 && body[i + 1] == 104 && body[i + 2] == 117 && body[i + 3] == 116 && body[i
    + 4] == 100 && body[i + 5] == 111 && body[i + 6] == 119 && body[i + 7] == 110) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

/** Exported function `lsp_body_contains_did_open`.
 * Implements `lsp_body_contains_did_open`.
 * @param body *u8
 * @param len i32
 * @return i32
 */
export function lsp_body_contains_did_open(body: *u8, len: i32): i32 {
  let i: i32 = 0;
  while (i + 19 <= len) {
    if (body[i] == 116 && body[i + 1] == 101 && body[i + 2] == 120 && body[i + 3] == 116 && body[i
    + 4] == 68 && body[i + 5] == 111 && body[i + 6] == 99 && body[i + 7] == 117 && body[i + 8] ==
    109 && body[i + 9] == 101 && body[i + 10] == 110 && body[i + 11] == 116 && body[i + 12] == 47
    && body[i + 13] == 100 && body[i + 14] == 105 && body[i + 15] == 100 && body[i + 16] == 79 &&
    body[i + 17] == 112 && body[i + 18] == 101 && body[i + 19] == 110) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

/** Exported function `lsp_body_contains_did_change`.
 * Implements `lsp_body_contains_did_change`.
 * @param body *u8
 * @param len i32
 * @return i32
 */
export function lsp_body_contains_did_change(body: *u8, len: i32): i32 {
  let i: i32 = 0;
  while (i + 21 <= len) {
    if (body[i] == 116 && body[i + 1] == 101 && body[i + 2] == 120 && body[i + 3] == 116 && body[i
    + 4] == 68 && body[i + 5] == 111 && body[i + 6] == 99 && body[i + 7] == 117 && body[i + 8] ==
    109 && body[i + 9] == 101 && body[i + 10] == 110 && body[i + 11] == 116 && body[i + 12] == 47
    && body[i + 13] == 100 && body[i + 14] == 105 && body[i + 15] == 100 && body[i + 16] == 67 &&
    body[i + 17] == 104 && body[i + 18] == 97 && body[i + 19] == 110 && body[i + 20] == 103 &&
    body[i + 21] == 101) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

/** Exported function `lsp_body_contains_did_save`.
 * Implements `lsp_body_contains_did_save`.
 * @param body *u8
 * @param len i32
 * @return i32
 */
export function lsp_body_contains_did_save(body: *u8, len: i32): i32 {
  let i: i32 = 0;
  while (i + 19 <= len) {
    if (body[i] == 116 && body[i+1] == 101 && body[i+2] == 120 && body[i+3] == 116 && body[i+4] ==
    68 && body[i+5] == 111 && body[i+6] == 99 && body[i+7] == 117 && body[i+8] == 109 && body[i+9]
    == 101 && body[i+10] == 110 && body[i+11] == 116 && body[i+12] == 47 && body[i+13] == 100 &&
    body[i+14] == 105 && body[i+15] == 100 && body[i+16] == 83 && body[i+17] == 97 && body[i+18] ==
    118 && body[i+19] == 101) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

/** Exported function `lsp_body_contains_diagnostic`.
 * Implements `lsp_body_contains_diagnostic`.
 * @param body *u8
 * @param len i32
 * @return i32
 */
export function lsp_body_contains_diagnostic(body: *u8, len: i32): i32 {
  let i: i32 = 0;
  while (i + 23 <= len) {
    if (body[i] == 116 && body[i+1] == 101 && body[i+2] == 120 && body[i+3] == 116 && body[i+4] ==
    68 && body[i+5] == 111 && body[i+6] == 99 && body[i+7] == 117 && body[i+8] == 109 && body[i+9]
    == 101 && body[i+10] == 110 && body[i+11] == 116 && body[i+12] == 47 && body[i+13] == 100 &&
    body[i+14] == 105 && body[i+15] == 97 && body[i+16] == 103 && body[i+17] == 110 && body[i+18]
    == 111 && body[i+19] == 115 && body[i+20] == 116 && body[i+21] == 105 && body[i+22] == 99) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

// lsp_body_contains_completion: see function docblock below.
/** Exported function `lsp_body_contains_completion`.
 * Implements `lsp_body_contains_completion`.
 * @param body *u8
 * @param len i32
 * @return i32
 */
export function lsp_body_contains_completion(body: *u8, len: i32): i32 {
  let i: i32 = 0;
  while (i + 23 <= len) {
    if (body[i] == 116 && body[i+1] == 101 && body[i+2] == 120 && body[i+3] == 116 && body[i+4] ==
    68 && body[i+5] == 111 && body[i+6] == 99 && body[i+7] == 117 && body[i+8] == 109 && body[i+9]
    == 101 && body[i+10] == 110 && body[i+11] == 116 && body[i+12] == 47 && body[i+13] == 99 &&
    body[i+14] == 111 && body[i+15] == 109 && body[i+16] == 112 && body[i+17] == 108 && body[i+18]
    == 101 && body[i+19] == 116 && body[i+20] == 105 && body[i+21] == 111 && body[i+22] == 110) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

// lsp_body_contains_document_symbol: see function docblock below.
/** Exported function `lsp_body_contains_document_symbol`.
 * Implements `lsp_body_contains_document_symbol`.
 * @param body *u8
 * @param len i32
 * @return i32
 */
export function lsp_body_contains_document_symbol(body: *u8, len: i32): i32 {
  let i: i32 = 0;
  while (i + 27 <= len) {
    if (body[i] == 116 && body[i+1] == 101 && body[i+2] == 120 && body[i+3] == 116 && body[i+4] ==
    68 && body[i+5] == 111 && body[i+6] == 99 && body[i+7] == 117 && body[i+8] == 109 && body[i+9]
    == 101 && body[i+10] == 110 && body[i+11] == 116 && body[i+12] == 47 && body[i+13] == 100 &&
    body[i+14] == 111 && body[i+15] == 99 && body[i+16] == 117 && body[i+17] == 109 && body[i+18]
    == 101 && body[i+19] == 110 && body[i+20] == 116 && body[i+21] == 83 && body[i+22] == 121 &&
    body[i+23] == 109 && body[i+24] == 98 && body[i+25] == 111 && body[i+26] == 108) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

// lsp_body_contains_semantic_tokens: see function docblock below.
/** Exported function `lsp_body_contains_semantic_tokens`.
 * Implements `lsp_body_contains_semantic_tokens`.
 * @param body *u8
 * @param len i32
 * @return i32
 */
export function lsp_body_contains_semantic_tokens(body: *u8, len: i32): i32 {
  let i: i32 = 0;
  while (i + 28 <= len) {
    if (body[i] == 116 && body[i+1] == 101 && body[i+2] == 120 && body[i+3] == 116 && body[i+4] ==
    68 && body[i+5] == 111 && body[i+6] == 99 && body[i+7] == 117 && body[i+8] == 109 && body[i+9]
    == 101 && body[i+10] == 110 && body[i+11] == 116 && body[i+12] == 47 && body[i+13] == 115 &&
    body[i+14] == 101 && body[i+15] == 109 && body[i+16] == 97 && body[i+17] == 110 && body[i+18]
    == 116 && body[i+19] == 105 && body[i+20] == 99 && body[i+21] == 84 && body[i+22] == 111 &&
    body[i+23] == 107 && body[i+24] == 101 && body[i+25] == 110 && body[i+26] == 115) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

// lsp_body_contains_rename: see function docblock below.
/** Exported function `lsp_body_contains_rename`.
 * Implements `lsp_body_contains_rename`.
 * @param body *u8
 * @param len i32
 * @return i32
 */
export function lsp_body_contains_rename(body: *u8, len: i32): i32 {
  let i: i32 = 0;
  while (i + 20 <= len) {
    if (body[i] == 116 && body[i+1] == 101 && body[i+2] == 120 && body[i+3] == 116 && body[i+4] ==
    68 && body[i+5] == 111 && body[i+6] == 99 && body[i+7] == 117 && body[i+8] == 109 && body[i+9]
    == 101 && body[i+10] == 110 && body[i+11] == 116 && body[i+12] == 47 && body[i+13] == 114 &&
    body[i+14] == 101 && body[i+15] == 110 && body[i+16] == 97 && body[i+17] == 109 && body[i+18]
    == 101) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

// lsp_body_contains_did_close: see function docblock below.
/** Exported function `lsp_body_contains_did_close`.
 * Implements `lsp_body_contains_did_close`.
 * @param body *u8
 * @param len i32
 * @return i32
 */
export function lsp_body_contains_did_close(body: *u8, len: i32): i32 {
  let i: i32 = 0;
  while (i + 20 <= len) {
    if (body[i] == 116 && body[i+1] == 101 && body[i+2] == 120 && body[i+3] == 116 && body[i+4] ==
    68 && body[i+5] == 111 && body[i+6] == 99 && body[i+7] == 117 && body[i+8] == 109 && body[i+9]
    == 101 && body[i+10] == 110 && body[i+11] == 116 && body[i+12] == 47 && body[i+13] == 100 &&
    body[i+14] == 105 && body[i+15] == 100 && body[i+16] == 67 && body[i+17] == 108 && body[i+18]
    == 111 && body[i+19] == 115 && body[i+20] == 101) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

// lsp_body_contains_cancel: see function docblock below.
/** Exported function `lsp_body_contains_cancel`.
 * Implements `lsp_body_contains_cancel`.
 * @param body *u8
 * @param len i32
 * @return i32
 */
export function lsp_body_contains_cancel(body: *u8, len: i32): i32 {
  let i: i32 = 0;
  while (i + 14 <= len) {
    if (body[i] == 36 && body[i+1] == 47 && body[i+2] == 99 && body[i+3] == 97 && body[i+4] == 110
    && body[i+5] == 99 && body[i+6] == 101 && body[i+7] == 108 && body[i+8] == 82 && body[i+9] ==
    101 && body[i+10] == 113 && body[i+11] == 117 && body[i+12] == 101 && body[i+13] == 115 &&
    body[i+14] == 116) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

// lsp_body_contains_did_change_config: see function docblock below.
/** Exported function `lsp_body_contains_did_change_config`.
 * Implements `lsp_body_contains_did_change_config`.
 * @param body *u8
 * @param len i32
 * @return i32
 */
export function lsp_body_contains_did_change_config(body: *u8, len: i32): i32 {
  let i: i32 = 0;
  while (i + 35 <= len) {
    if (body[i] == 119 && body[i+1] == 111 && body[i+2] == 114 && body[i+3] == 107 && body[i+4] ==
    115 && body[i+5] == 112 && body[i+6] == 97 && body[i+7] == 99 && body[i+8] == 101 && body[i+9]
    == 47 && body[i+10] == 100 && body[i+11] == 105 && body[i+12] == 100 && body[i+13] == 67 &&
    body[i+14] == 104 && body[i+15] == 97 && body[i+16] == 110 && body[i+17] == 103 && body[i+18]
    == 101 && body[i+19] == 67 && body[i+20] == 111 && body[i+21] == 110 && body[i+22] == 102 &&
    body[i+23] == 105 && body[i+24] == 103 && body[i+25] == 117 && body[i+26] == 114 && body[i+27]
    == 97 && body[i+28] == 116 && body[i+29] == 105 && body[i+30] == 111 && body[i+31] == 110) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

/** Exported function `lsp_body_contains_definition`.
 * Implements `lsp_body_contains_definition`.
 * @param body *u8
 * @param len i32
 * @return i32
 */
export function lsp_body_contains_definition(body: *u8, len: i32): i32 {
  let i: i32 = 0;
  while (i + 22 < len) {
    if (body[i] == 116 && body[i+1] == 101 && body[i+2] == 120 && body[i+3] == 116 && body[i+4] ==
    68 && body[i+5] == 111 && body[i+6] == 99 && body[i+7] == 117 && body[i+8] == 109 && body[i+9]
    == 101 && body[i+10] == 110 && body[i+11] == 116 && body[i+12] == 47 && body[i+13] == 100 &&
    body[i+14] == 101 && body[i+15] == 102 && body[i+16] == 105 && body[i+17] == 110 && body[i+18]
    == 105 && body[i+19] == 116 && body[i+20] == 105 && body[i+21] == 111 && body[i+22] == 110) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

/** Exported function `lsp_body_contains_references`.
 * Implements `lsp_body_contains_references`.
 * @param body *u8
 * @param len i32
 * @return i32
 */
export function lsp_body_contains_references(body: *u8, len: i32): i32 {
  let i: i32 = 0;
  while (i + 23 < len) {
    if (body[i] == 116 && body[i+1] == 101 && body[i+2] == 120 && body[i+3] == 116 && body[i+4] ==
    68 && body[i+5] == 111 && body[i+6] == 99 && body[i+7] == 117 && body[i+8] == 109 && body[i+9]
    == 101 && body[i+10] == 110 && body[i+11] == 116 && body[i+12] == 47 && body[i+13] == 114 &&
    body[i+14] == 101 && body[i+15] == 102 && body[i+16] == 101 && body[i+17] == 114 && body[i+18]
    == 101 && body[i+19] == 110 && body[i+20] == 99 && body[i+21] == 101 && body[i+22] == 115 &&
    body[i+23] == 115) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

/** Exported function `lsp_body_contains_hover`.
 * Implements `lsp_body_contains_hover`.
 * @param body *u8
 * @param len i32
 * @return i32
 */
export function lsp_body_contains_hover(body: *u8, len: i32): i32 {
  let i: i32 = 0;
  while (i + 17 <= len) {
    if (body[i] == 116 && body[i+1] == 101 && body[i+2] == 120 && body[i+3] == 116 && body[i+4] ==
    68 && body[i+5] == 111 && body[i+6] == 99 && body[i+7] == 117 && body[i+8] == 109 && body[i+9]
    == 101 && body[i+10] == 110 && body[i+11] == 116 && body[i+12] == 47 && body[i+13] == 104 &&
    body[i+14] == 111 && body[i+15] == 118 && body[i+16] == 101 && body[i+17] == 114) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

/** Exported function `lsp_body_contains_formatting`.
 * Implements `lsp_body_contains_formatting`.
 * @param body *u8
 * @param len i32
 * @return i32
 */
export function lsp_body_contains_formatting(body: *u8, len: i32): i32 {
  let i: i32 = 0;
  while (i + 23 <= len) {
    if (body[i] == 116 && body[i+1] == 101 && body[i+2] == 120 && body[i+3] == 116 && body[i+4] ==
    68 && body[i+5] == 111 && body[i+6] == 99 && body[i+7] == 117 && body[i+8] == 109 && body[i+9]
    == 101 && body[i+10] == 110 && body[i+11] == 116 && body[i+12] == 47 && body[i+13] == 102 &&
    body[i+14] == 111 && body[i+15] == 114 && body[i+16] == 109 && body[i+17] == 97 && body[i+18]
    == 116 && body[i+19] == 116 && body[i+20] == 105 && body[i+21] == 110 && body[i+22] == 103) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

/** Exported function `lsp_body_contains_exit`.
 * Implements `lsp_body_contains_exit`.
 * @param body *u8
 * @param len i32
 * @return i32
 */
export function lsp_body_contains_exit(body: *u8, len: i32): i32 {
  let i: i32 = 0;
  while (i + 4 <= len) {
    if (body[i] == 101 && body[i + 1] == 120 && body[i + 2] == 105 && body[i + 3] == 116) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

/** Exported function `lsp_parse_id`.
 * Implements `lsp_parse_id`.
 * @param body *u8
 * @param len i32
 * @param id_buf *u8
 * @param id_buf_len i32
 * @return i32
 */
export function lsp_parse_id(body: *u8, len: i32, id_buf: *u8, id_buf_len: i32): i32 {
  let i: i32 = 0;
  while (i + 6 <= len) {
    if (body[i] == 34 && body[i + 1] == 105 && body[i + 2] == 100 && body[i + 3] == 34 && body[i +
    4] == 58) {
      i = i + 5;
      while (i < len && (body[i] == 32 || body[i] == 9)) {
        i = i + 1;
      }
      if (i >= len) {
        return -1;
      }
      let val: i32 = 0;
      let j: i32 = 0;
      while (i < len && j < id_buf_len - 1) {
        let c: u8 = body[i];
        if (c >= 48 && c <= 57) {
          val = val * 10 + (c as i32) - 48;
          id_buf[j] = c;
          j = j + 1;
          i = i + 1;
        } else {
          break;
        }
      }
      id_buf[j] = 0;
      return val;
    }
    i = i + 1;
  }
  return -1;
}

/**
 * Send one LSP response on fd (stdout=1) with Content-Length framing via lsp_write_all.
 * PLATFORM: SHARED — Cap-T001 whole-body unsafe (C write glue).
 */
export function lsp_send_response(fd: i32, body: *u8, body_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: whole-body unsafe FFI gate (Cap-T001).
  // Covers export-extern C glue and lsp_io import surface calls.
  unsafe {
  let header: u8[64] = [];
  header[0] = 67;
  header[1] = 111;
  header[2] = 110;
  header[3] = 116;
  header[4] = 101;
  header[5] = 110;
  header[6] = 116;
  header[7] = 45;
  header[8] = 76;
  header[9] = 101;
  header[10] = 110;
  header[11] = 103;
  header[12] = 116;
  header[13] = 104;
  header[14] = 58;
  header[15] = 32;
  let n: i32 = body_len;
  let k: i32 = 16;
  if (n == 0) {
    header[k] = 48;
    k = k + 1;
  } else {
    let digits: i32[12] = [];
    let d: i32 = 0;
    let n2: i32 = n;
    while (n2 > 0) {
      digits[d] = n2 % 10;
      n2 = n2 / 10;
      d = d + 1;
    }
    let idx: i32 = d - 1;
    while (idx >= 0) {
      header[k] = (digits[idx] + 48) as u8;
      k = k + 1;
      idx = idx - 1;
    }
  }
  header[k] = 13;
  k = k + 1;
  header[k] = 10;
  k = k + 1;
  header[k] = 13;
  k = k + 1;
  header[k] = 10;
  k = k + 1;
  let w: i32 = lsp_write_all(fd, header, k);
  if (w != 0) {
    return -1;
  }
  if (body_len > 0) {
    let w2: i32 = lsp_write_all(fd, body, body_len);
    if (w2 != 0) {
      return -1;
    }
  }
  return 0;
  }
  return 0;
}

/** See implementation for details. */
/**
 * LSP main loop: read messages, dispatch methods, write JSON-RPC responses.
 * Host may wrap this on a large-stack pthread (see lsp_state.c typeck_lsp_main).
 * PLATFORM: SHARED — Cap-T001 whole-body unsafe (C glue + lsp_io surface).
 */
export function lsp_main_impl(): i32 {
  // PLATFORM: SHARED — LANG-007 S0: whole-body unsafe FFI gate (Cap-T001).
  // Covers export-extern C glue and lsp_io import surface calls.
  unsafe {
  let stdin_fd: i32 = 0;
  let stdout_fd: i32 = 1;
  let line_buf: u8[256] = [];
  let out_buf: u8[4096] = [];
  let shutdown_requested: i32 = 0;
  let id_buf: u8[32] = [];
  let state_ptr: *u8 = lsp_state_buf_ptr();
  let diag_ptr: *u8 = lsp_io.lsp_alloc(LSP_DIAG_RESP_CAP as usize);
  let ref_ptr: *u8 = lsp_io.lsp_alloc(LSP_REF_RESP_CAP as usize);
  let format_ptr: *u8 = lsp_io.lsp_alloc(LSP_FORMAT_RESP_CAP as usize);
  if (lsp_io.lsp_is_null(state_ptr) != 0 || lsp_io.lsp_is_null(diag_ptr) != 0
  || lsp_io.lsp_is_null(ref_ptr) != 0 || lsp_io.lsp_is_null(format_ptr) != 0) {
    if (lsp_io.lsp_is_null(diag_ptr) == 0) { lsp_io.lsp_free(diag_ptr); }
    if (lsp_io.lsp_is_null(ref_ptr) == 0) { lsp_io.lsp_free(ref_ptr); }
    if (lsp_io.lsp_is_null(format_ptr) == 0) { lsp_io.lsp_free(format_ptr); }
    return -1;
  }
  while (true) {
    let body_ptr: *u8 = lsp_io.lsp_alloc(LSP_BODY_CAP as usize);
    if (lsp_io.lsp_is_null(body_ptr) != 0) {
      continue;
    }
    let msg_len: isize = lsp_io.read_message(stdin_fd, body_ptr, LSP_BODY_CAP, state_ptr);
    if (msg_len < 0) {
      lsp_io.lsp_free(body_ptr);
      break;
    }
    if (msg_len == 0) {
      lsp_io.lsp_free(body_ptr);
      continue;
    }
    let content_len: i32 = msg_len as i32;
    if (content_len > LSP_BODY_CAP) {
      lsp_io.lsp_free(body_ptr);
      continue;
    }
    /* See implementation. */
    */
    if (lsp_body_contains_did_open(body_ptr, content_len) != 0) {
      lsp_set_document_from_body(body_ptr, content_len);
      lsp_io.lsp_free(body_ptr);
      continue;
    }
    if (lsp_body_contains_did_change(body_ptr, content_len) != 0) {
      lsp_set_document_from_body(body_ptr, content_len);
      lsp_io.lsp_free(body_ptr);
      continue;
    }
    if (lsp_body_contains_did_save(body_ptr, content_len) != 0) {
      lsp_io.lsp_free(body_ptr);
      continue;
    }
    if (lsp_body_contains_did_close(body_ptr, content_len) != 0) {
      /* See implementation. */
      lsp_diag_invalidate_cache();
      lsp_io.lsp_free(body_ptr);
      continue;
    }
    if (lsp_body_contains_cancel(body_ptr, content_len) != 0) {
      /* See implementation. */
      lsp_io.lsp_free(body_ptr);
      continue;
    }
    if (lsp_body_contains_did_change_config(body_ptr, content_len) != 0) {
      /* See implementation. */
      lsp_diag_invalidate_cache();
      lsp_io.lsp_free(body_ptr);
      continue;
    }
    if (lsp_body_contains_exit(body_ptr, content_len) != 0 && shutdown_requested != 0) {
      lsp_io.lsp_free(body_ptr);
      break;
    }
    if (lsp_body_contains_shutdown(body_ptr, content_len) != 0) {
      shutdown_requested = 1;
      let sid: i32 = lsp_parse_id(body_ptr, content_len, id_buf, 32);
      if (sid < 0) { sid = 1; }
      let null_val: u8[4] = [110, 117, 108, 108];
      let resp_len: i32 = lsp_build_response_with_result(sid, null_val, 4, out_buf, 4096);
      if (resp_len > 0) {
        lsp_send_response(stdout_fd, out_buf, resp_len);
      }
      lsp_io.lsp_free(body_ptr);
      continue;
    }
    if (lsp_body_contains_initialized(body_ptr, content_len) != 0) {
      lsp_io.lsp_free(body_ptr);
      continue;
    }
    if (lsp_body_contains_initialize(body_ptr, content_len) != 0) {
      let sid: i32 = lsp_parse_id(body_ptr, content_len, id_buf, 32);
      if (sid < 0) {
        sid = 1;
      }
      /* See implementation. */
      let out_len: i32 = lsp_build_initialize_result(sid, diag_ptr, LSP_DIAG_RESP_CAP);
      if (out_len > 0) {
        lsp_send_response(stdout_fd, diag_ptr, out_len);
      }
      lsp_io.lsp_free(body_ptr);
      continue;
    }
    /* Parse request id; result buffer obtained from C-side dynamic allocation. */
    let req_id: i32 = lsp_parse_id(body_ptr, content_len, id_buf, 32);
    let doc_ptr: *u8 = lsp_get_document_ptr();
    let doc_len: i32 = lsp_get_document_len();
    if (req_id >= 0) {
      let empty_arr: u8[2] = [91, 93];
      let null_val: u8[4] = [110, 117, 108, 108];
      if (lsp_body_contains_diagnostic(body_ptr, content_len) != 0) {
        let resp_len: i32 = lsp_build_diagnostics_response(req_id, doc_ptr, doc_len, diag_ptr,
        LSP_DIAG_RESP_CAP);
        if (resp_len > 0) {
          lsp_send_response(stdout_fd, diag_ptr, resp_len);
        } else {
          let fallback_len: i32 = lsp_build_response_with_result(req_id, empty_arr, 2, out_buf,
          4096);
          if (fallback_len > 0) {
            lsp_send_response(stdout_fd, out_buf, fallback_len);
          }
        }
        lsp_io.lsp_free(body_ptr);
        continue;
      }
      if (lsp_body_contains_definition(body_ptr, content_len) != 0) {
        let resp_len: i32 = lsp_build_definition_response(req_id, body_ptr, content_len, doc_ptr,
        doc_len, out_buf, 4096);
        if (resp_len > 0) {
          lsp_send_response(stdout_fd, out_buf, resp_len);
        } else {
          let fallback_len: i32 = lsp_build_response_with_result(req_id, null_val, 4, out_buf,
          4096);
          if (fallback_len > 0) {
            lsp_send_response(stdout_fd, out_buf, fallback_len);
          }
        }
        lsp_io.lsp_free(body_ptr);
        continue;
      }
      if (lsp_body_contains_references(body_ptr, content_len) != 0) {
        let resp_len: i32 = lsp_build_references_response(req_id, body_ptr, content_len, doc_ptr,
        doc_len, ref_ptr, LSP_REF_RESP_CAP);
        if (resp_len > 0) {
          lsp_send_response(stdout_fd, ref_ptr, resp_len);
        } else {
          let fallback_len: i32 = lsp_build_response_with_result(req_id, empty_arr, 2, out_buf,
          4096);
          if (fallback_len > 0) {
            lsp_send_response(stdout_fd, out_buf, fallback_len);
          }
        }
        lsp_io.lsp_free(body_ptr);
        continue;
      }
      if (lsp_body_contains_hover(body_ptr, content_len) != 0) {
        let resp_len: i32 = lsp_build_hover_response(req_id, body_ptr, content_len, doc_ptr,
        doc_len, out_buf, 4096);
        if (resp_len > 0) {
          lsp_send_response(stdout_fd, out_buf, resp_len);
        } else {
          let fallback_len: i32 = lsp_build_response_with_result(req_id, null_val, 4, out_buf,
          4096);
          if (fallback_len > 0) {
            lsp_send_response(stdout_fd, out_buf, fallback_len);
          }
        }
        lsp_io.lsp_free(body_ptr);
        continue;
      }
      if (lsp_body_contains_formatting(body_ptr, content_len) != 0) {
        let resp_len: i32 = lsp_build_formatting_response(req_id, body_ptr, content_len, doc_ptr,
        doc_len, format_ptr, LSP_FORMAT_RESP_CAP);
        if (resp_len > 0) {
          lsp_send_response(stdout_fd, format_ptr, resp_len);
        } else {
          let fallback_len: i32 = lsp_build_response_with_result(req_id, empty_arr, 2, out_buf,
          4096);
          if (fallback_len > 0) {
            lsp_send_response(stdout_fd, out_buf, fallback_len);
          }
        }
        lsp_io.lsp_free(body_ptr);
        continue;
      }
      if (lsp_body_contains_completion(body_ptr, content_len) != 0) {
        let resp_len: i32 = lsp_build_completion_response(req_id, body_ptr, content_len, doc_ptr,
        doc_len, format_ptr, LSP_FORMAT_RESP_CAP);
        if (resp_len > 0) {
          lsp_send_response(stdout_fd, format_ptr, resp_len);
        } else {
          let fallback_len: i32 = lsp_build_response_with_result(req_id, empty_arr, 2, out_buf,
          4096);
          if (fallback_len > 0) {
            lsp_send_response(stdout_fd, out_buf, fallback_len);
          }
        }
        lsp_io.lsp_free(body_ptr);
        continue;
      }
      if (lsp_body_contains_document_symbol(body_ptr, content_len) != 0) {
        let resp_len: i32 = lsp_build_document_symbol_response(req_id, body_ptr, content_len,
        doc_ptr, doc_len, format_ptr, LSP_FORMAT_RESP_CAP);
        if (resp_len > 0) {
          lsp_send_response(stdout_fd, format_ptr, resp_len);
        } else {
          let fallback_len: i32 = lsp_build_response_with_result(req_id, empty_arr, 2, out_buf,
          4096);
          if (fallback_len > 0) {
            lsp_send_response(stdout_fd, out_buf, fallback_len);
          }
        }
        lsp_io.lsp_free(body_ptr);
        continue;
      }
      if (lsp_body_contains_semantic_tokens(body_ptr, content_len) != 0) {
        let resp_len: i32 = lsp_build_semantic_tokens_response(req_id, doc_ptr, doc_len,
        format_ptr, LSP_FORMAT_RESP_CAP);
        if (resp_len > 0) {
          lsp_send_response(stdout_fd, format_ptr, resp_len);
        } else {
          let fallback_len: i32 = lsp_build_response_with_result(req_id, empty_arr, 2, out_buf,
          4096);
          if (fallback_len > 0) {
            lsp_send_response(stdout_fd, out_buf, fallback_len);
          }
        }
        lsp_io.lsp_free(body_ptr);
        continue;
      }
      if (lsp_body_contains_rename(body_ptr, content_len) != 0) {
        let resp_len: i32 = lsp_build_rename_response(req_id, body_ptr, content_len, doc_ptr,
        doc_len, format_ptr, LSP_FORMAT_RESP_CAP);
        if (resp_len > 0) {
          lsp_send_response(stdout_fd, format_ptr, resp_len);
        } else {
          let fallback_len: i32 = lsp_build_response_with_result(req_id, null_val, 4, out_buf,
          4096);
          if (fallback_len > 0) {
            lsp_send_response(stdout_fd, out_buf, fallback_len);
          }
        }
        lsp_io.lsp_free(body_ptr);
        continue;
      }
    }
    lsp_io.lsp_free(body_ptr);
  }
  lsp_io.lsp_free(diag_ptr);
  lsp_io.lsp_free(ref_ptr);
  lsp_io.lsp_free(format_ptr);
  return 0;
  }
  return 0;
}
