// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Note-kind bytes and the note reporter for the ELF ctx diagnostic.
// The 192-byte message buffer lives in rt_pipeline_elf_diag_note.x.
// PLATFORM: SHARED.
// w1137: this file stays separate from the message buffer so pure asm emits.

export extern "C" function diag_report_with_code(
  file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void;

/** Write ASCII "note" + NUL into kind[0..4]. Caller must provide at least 5 bytes.
 * PLATFORM: SHARED. */
#[no_mangle]
export function rt_elf_note_kind(kind: *u8): void {
  kind[0] = 110;
  kind[1] = 111;
  kind[2] = 116;
  kind[3] = 101;
  kind[4] = 0;
}

/** Emit a note-level diagnostic with msg (no file/line/code).
 * PLATFORM: SHARED. */
#[no_mangle]
export function rt_elf_report_note(msg: *u8): void {
  let kind: u8[8] = [];
  // Pad so the frame covers the diag_report argument slots. Without it the
  // compiler stores at [x29, #0x70] with a 0x70 frame and smashes the caller.
  let pad: u8[80] = [];
  let kp: *u8 = &kind[0];
  pad[0] = 0;
  rt_elf_note_kind(kp);
  unsafe {
    diag_report_with_code(0 as *u8, 0, 0, kp, 0 as *u8, msg, 0 as *u8);
  }
}

