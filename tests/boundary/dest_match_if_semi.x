// dest wrap IF dest: MATCH extra-arm last dest is IF dest
// `*p = match { if (c) { dest } else { y } }`.
// parse_block TOKEN_IF used to always append if-stmt, so dest-in-rbx
// peel missed dest (CG002 `.Lf0_2`) and host-C GNU stmt-expr was
// void assigned to dest. Last dest is now parse_if_expr_into
// (same as `*p = if`). Own main: dest-park leftover is not this
// leaf. Leftover codes stay in 1..255.
// Expected exit 0.
// PLATFORM: SHARED dest wrap IF dest.

allow(padding) struct Holder { v: i32x4 }

allow(padding) struct Wrap { h: Holder }

/**
 * Gate dest wrap IF dest (MATCH extra-arm last dest is IF dest).
 * Stacks MATCH / IF / field-bind / no-semi.
 * Own file so dest-park leftover is not this leaf.
 * @return i32 — 0 ok; 148..155 leftover lanes
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
  let dsth: Holder = { v: z };
  let ph: *Holder = &dsth;

  // MATCH dest wrap IF dest leftover 148..149
  unsafe {
    *p = match tag {
      1 => { if (tag == 1) { { h: { v: a } } } else { y } };
      _ => y;
    }
  }
  if (dst.h.v[0] != 1) { return 148; }
  if (dst.h.v[3] != 4) { return 149; }

  // IF dest wrap IF dest leftover 150..151
  unsafe {
    *p = if (tag == 1) {
      if (tag == 1) { { h: { v: b } } } else { y }
    } else {
      y
    }
  }
  if (dst.h.v[0] != 5) { return 150; }
  if (dst.h.v[3] != 8) { return 151; }

  // MATCH field-bind dest wrap IF dest leftover 152..153
  unsafe {
    *ph = match w {
      Wrap { h } => { if (tag == 1) { h } else { dsth } };
    }
  }
  if (dsth.v[0] != 1) { return 152; }
  if (dsth.v[3] != 4) { return 153; }

  // no-semi MATCH dest wrap IF dest leftover 154..155
  unsafe {
    *p = match tag {
      1 => {
        if (tag == 1) { { h: { v: a } } } else { y }
      };
      _ => y;
    }
  }
  if (dst.h.v[0] != 1) { return 154; }
  if (dst.h.v[3] != 4) { return 155; }
  return 0;
}
