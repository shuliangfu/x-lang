// dest extra-arm `region label { … }; dest` (optional compound ASI).
// MATCH / IF extra-arm `region foo { k = 1 }; { dest }` used to drop the
// whole function (P001). No-semi dest extra-arm region is already green
// (isolate dest_reg_nosemi). dest extra-arm `defer { k = 1 }; dest`
// used to keep dest and drop the defer (asm leftover 71): defer lives
// only in the defer pool (no stmt_order), dest-in-rbx never ran
// language defers. Same dest extra-arm dest-in-rbx emit now runs
// glue_emit_run_language_defers_elf. dest extra-arm extra wrap
// `{ { let t; dest } }` used to keep dest in dest-in-rbx (peel BLOCK)
// and drop the value on host-C (`(void)({...})` assigned to dest).
// parse_block last nested block is now final_expr. dest-from-region
// dest-region-body `with_arena { defer { k = 1 }; dest }` used to
// keep dest and drop the dest-region defer (asm leftover 53):
// dest-from-region overwrites br; extra-arm defer_br is empty.
// Same dest-in-rbx now runs glue_emit_run_language_defers_elf on
// the dest region body. dest-from-region intermediate
// `unsafe { defer { k = 1 }; with_arena { dest } }` used to
// keep dest last on host-C as `(k=1)` (GNU stmt-expr last
// value assigned to Wrap). emit_block now runs wrapping
// defers before last so_k==6 dest. Gate lives here so
// dest-park leftover is not this leaf. Leftover codes
// stay in 1..255.
// Expected exit 0.
// PLATFORM: SHARED dest extra-arm region / defer / extra-wrap /
// dest-from-region dest-region-body defer /
// dest-from-region intermediate stmt-expr last-value.

allow(padding) struct Holder { v: i32x4 }

allow(padding) struct Wrap { h: Holder }

/**
 * Gate dest extra-arm `region` / `defer` optional compound ASI
 * plus dest-from-region dest-region-body defer plus
 * dest-from-region intermediate stmt-expr last-value.
 * Stacks MATCH / IF / field-bind / no-semi (region + defer +
 * extra wrap + dest-from-region dest-region-body defer +
 * dest-from-region intermediate defer).
 * @return i32 — 0 ok; 70..123 leftover lanes
 */
function main(): i32 {
  let a: i32x4 = [1, 2, 3, 4];
  let b: i32x4 = [5, 6, 7, 8];
  let z: i32x4 = [0, 0, 0, 0];
  let w: Wrap = { h: { v: a } };
  let y: Wrap = { h: { v: b } };
  let dst: Wrap = { h: { v: z } };
  let p: *Wrap = &dst;
  let tag: i32 = 1;
  let k: i32 = 0;

  // MATCH extra-arm region + trailing STRUCT_LIT
  unsafe { *p = match tag { 1 => { region foo { k = 1 }; { h: { v: a } } }; _ => y; } }
  if (dst.h.v[0] != 1) { return 70; }
  if (dst.h.v[3] != 4) { return 71; }
  if (k != 1) { return 72; }

  // IF extra-arm region + trailing STRUCT_LIT
  k = 0;
  unsafe {
    *p = if (tag == 1) {
      region bar { k = 1 };
      { h: { v: b } }
    } else {
      y
    }
  }
  if (dst.h.v[0] != 5) { return 73; }
  if (dst.h.v[3] != 8) { return 74; }
  if (k != 1) { return 75; }

  // MATCH field-bind extra-arm region + dest field
  k = 0;
  let dsth: Holder = { v: z };
  let ph: *Holder = &dsth;
  unsafe { *ph = match w { Wrap { h } => { region baz { k = 1 }; h }; } }
  if (dsth.v[0] != 1) { return 76; }
  if (dsth.v[3] != 4) { return 77; }
  if (k != 1) { return 78; }

  // no-semi MATCH extra-arm region still a stmt head
  k = 0;
  unsafe {
    *p = match tag {
      1 => {
        region qux { k = 1 }
        { h: { v: a } }
      };
      _ => y;
    }
  }
  if (dst.h.v[0] != 1) { return 79; }
  if (k != 1) { return 80; }

  // MATCH extra-arm defer + trailing STRUCT_LIT
  k = 0;
  unsafe { *p = match tag { 1 => { defer { k = 1 }; { h: { v: a } } }; _ => y; } }
  if (dst.h.v[0] != 1) { return 81; }
  if (dst.h.v[3] != 4) { return 82; }
  if (k != 1) { return 83; }

  // IF extra-arm defer + trailing STRUCT_LIT
  k = 0;
  unsafe {
    *p = if (tag == 1) {
      defer { k = 1 };
      { h: { v: b } }
    } else {
      y
    }
  }
  if (dst.h.v[0] != 5) { return 84; }
  if (dst.h.v[3] != 8) { return 85; }
  if (k != 1) { return 86; }

  // MATCH field-bind extra-arm defer + dest field
  k = 0;
  unsafe { *ph = match w { Wrap { h } => { defer { k = 1 }; h }; } }
  if (dsth.v[0] != 1) { return 87; }
  if (dsth.v[3] != 4) { return 88; }
  if (k != 1) { return 89; }

  // no-semi MATCH extra-arm defer still a stmt head
  k = 0;
  unsafe {
    *p = match tag {
      1 => {
        defer { k = 1 }
        { h: { v: a } }
      };
      _ => y;
    }
  }
  if (dst.h.v[0] != 1) { return 90; }
  if (k != 1) { return 91; }

  // MATCH extra-arm extra wrap `{ { let t; dest } }`
  unsafe { *p = match tag { 1 => { { let t: i32 = 1; { h: { v: a } } } }; _ => y; } }
  if (dst.h.v[0] != 1) { return 92; }
  if (dst.h.v[3] != 4) { return 93; }

  // IF extra-arm extra wrap `{ { let t; dest } }`
  unsafe {
    *p = if (tag == 1) {
      { let t: i32 = 1; { h: { v: b } } }
    } else {
      y
    }
  }
  if (dst.h.v[0] != 5) { return 94; }
  if (dst.h.v[3] != 8) { return 95; }

  // MATCH field-bind extra wrap `{ { let t; dest-field } }`
  unsafe { *ph = match w { Wrap { h } => { { let t: i32 = 1; h } }; } }
  if (dsth.v[0] != 1) { return 96; }
  if (dsth.v[3] != 4) { return 97; }

  // no-semi MATCH extra wrap of STRUCT_LIT `{ { dest } }`
  unsafe {
    *p = match tag {
      1 => {
        { { h: { v: a } } }
      };
      _ => y;
    }
  }
  if (dst.h.v[0] != 1) { return 98; }
  if (dst.h.v[3] != 4) { return 99; }

  // MATCH dest-from-region dest-region-body defer leftover 100..102
  k = 0;
  unsafe { *p = match tag { 1 => { with_arena(64) { defer { k = 1 }; { h: { v: a } } } }; _ => y; } }
  if (dst.h.v[0] != 1) { return 100; }
  if (dst.h.v[3] != 4) { return 101; }
  if (k != 1) { return 102; }

  // IF dest-from-region dest-region-body defer leftover 103..105
  k = 0;
  unsafe {
    *p = if (tag == 1) {
      with_arena(64) { defer { k = 1 }; { h: { v: b } } }
    } else {
      y
    }
  }
  if (dst.h.v[0] != 5) { return 103; }
  if (dst.h.v[3] != 8) { return 104; }
  if (k != 1) { return 105; }

  // MATCH field-bind dest-from-region dest-region-body defer leftover 106..108
  k = 0;
  unsafe { *ph = match w { Wrap { h } => { with_arena(64) { defer { k = 1 }; h } }; } }
  if (dsth.v[0] != 1) { return 106; }
  if (dsth.v[3] != 4) { return 107; }
  if (k != 1) { return 108; }

  // no-semi MATCH dest-from-region dest-region-body defer leftover 109..111
  k = 0;
  unsafe {
    *p = match tag {
      1 => {
        with_arena(64) { defer { k = 1 }; { h: { v: a } } }
      };
      _ => y;
    }
  }
  if (dst.h.v[0] != 1) { return 109; }
  if (dst.h.v[3] != 4) { return 110; }
  if (k != 1) { return 111; }

  // MATCH dest-from-region intermediate-region defer leftover 112..114
  k = 0;
  unsafe { *p = match tag { 1 => { unsafe { defer { k = 1 }; with_arena(64) { { h: { v: a } } } } }; _ => y; } }
  if (dst.h.v[0] != 1) { return 112; }
  if (dst.h.v[3] != 4) { return 113; }
  if (k != 1) { return 114; }

  // IF dest-from-region intermediate-region defer leftover 115..117
  k = 0;
  unsafe {
    *p = if (tag == 1) {
      unsafe { defer { k = 1 }; with_arena(64) { { h: { v: b } } } }
    } else {
      y
    }
  }
  if (dst.h.v[0] != 5) { return 115; }
  if (dst.h.v[3] != 8) { return 116; }
  if (k != 1) { return 117; }

  // MATCH field-bind dest-from-region intermediate leftover 118..120
  k = 0;
  unsafe { *ph = match w { Wrap { h } => { unsafe { defer { k = 1 }; with_arena(64) { h } } }; } }
  if (dsth.v[0] != 1) { return 118; }
  if (dsth.v[3] != 4) { return 119; }
  if (k != 1) { return 120; }

  // no-semi MATCH dest-from-region intermediate leftover 121..123
  k = 0;
  unsafe {
    *p = match tag {
      1 => {
        unsafe { defer { k = 1 }; with_arena(64) { { h: { v: a } } } }
      };
      _ => y;
    }
  }
  if (dst.h.v[0] != 1) { return 121; }
  if (dst.h.v[3] != 4) { return 122; }
  if (k != 1) { return 123; }
  return 0;
}
