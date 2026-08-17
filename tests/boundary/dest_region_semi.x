// dest extra-arm `region label { … }; dest` (optional compound ASI).
// MATCH / IF extra-arm `region foo { k = 1 }; { dest }` used to drop the
// whole function (P001). No-semi dest extra-arm region is already green
// (isolate dest_reg_nosemi). dest extra-arm `defer { k = 1 }; dest`
// used to keep dest and drop the defer (asm leftover 71): defer lives
// only in the defer pool (no stmt_order), dest-in-rbx never ran
// language defers. Same dest extra-arm dest-in-rbx emit now runs
// glue_emit_run_language_defers_elf. Gate lives here so dest-park
// leftover is not this leaf. Leftover codes stay in 1..255.
// Expected exit 0.
// PLATFORM: SHARED dest extra-arm region / defer compound ASI.

allow(padding) struct Holder { v: i32x4 }

allow(padding) struct Wrap { h: Holder }

/**
 * Gate dest extra-arm `region` / `defer` optional compound ASI.
 * Stacks MATCH / IF / field-bind / no-semi (region + defer).
 * @return i32 — 0 ok; 70..91 leftover lanes
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
  return 0;
}
